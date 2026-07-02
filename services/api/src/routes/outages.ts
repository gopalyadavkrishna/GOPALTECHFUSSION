import { Router } from "express";
import {
  FieldValue,
  Timestamp,
  type Transaction,
} from "firebase-admin/firestore";
import { z } from "zod";

import {
  assertOutageTransition,
  outageStatuses,
  type OutageStatus,
} from "../domain/workflows.js";
import { db } from "../firebase.js";
import { writeAudit } from "../lib/audit.js";
import {
  idempotencyExpiry,
  idempotencyContext,
  replay,
} from "../lib/idempotency.js";
import { notifyArea } from "../lib/notifications.js";
import { ApiError } from "../lib/problem.js";
import { pathParam } from "../lib/request.js";
import { assertProviderAccess } from "../lib/tenancy.js";
import {
  actor,
  authenticate,
  requireRoles,
} from "../middleware/auth.js";
import { validateBody } from "../middleware/validate.js";

const createOutageSchema = z
  .object({
    providerId: z.string().min(1).optional(),
    areaIds: z.array(z.string().min(1)).min(1).max(100),
    reason: z.string().trim().min(3).max(300),
    severity: z.enum(["low", "medium", "high", "critical"]),
    priority: z.enum(["normal", "urgent", "emergency"]),
    startTime: z.iso.datetime(),
    estimatedRestoreTime: z.iso.datetime().optional(),
    affectedPopulation: z.number().int().nonnegative(),
    feederId: z.string().max(100).optional(),
    transformerId: z.string().max(100).optional(),
  })
  .strict();

const updateStatusSchema = z
  .object({
    status: z.enum(outageStatuses),
    message: z.string().trim().min(3).max(500),
    estimatedRestoreTime: z.iso.datetime().optional(),
  })
  .strict();

type CommandResult = { id: string; status: OutageStatus };

export const outagesRouter = Router();

outagesRouter.use(authenticate);

outagesRouter.post(
  "/outages",
  requireRoles("providerStaff", "superAdmin"),
  validateBody(createOutageSchema),
  async (request, response) => {
    const principal = actor(request);
    const body = createOutageSchema.parse(request.body);
    const providerId = body.providerId ?? principal.providerId;
    if (!providerId) {
      throw new ApiError(
        400,
        "PROVIDER_REQUIRED",
        "A provider is required for this outage.",
      );
    }
    assertProviderAccess(principal, providerId);

    const outage = db.collection("outages").doc();
    const idempotency = idempotencyContext<CommandResult>(request);
    const result = await db.runTransaction(async (transaction) => {
      const previous = await replay(
        transaction,
        idempotency.reference,
        idempotency.requestHash,
      );
      if (previous) return previous;

      await validateAreas(transaction, body.areaIds, providerId);
      const status: OutageStatus =
        body.priority === "emergency" ? "emergency" : "reported";
      const document = {
        providerId,
        areaIds: [...new Set(body.areaIds)],
        reason: body.reason,
        severity: body.severity,
        priority: body.priority,
        status,
        startTime: Timestamp.fromDate(new Date(body.startTime)),
        estimatedRestoreTime: body.estimatedRestoreTime
          ? Timestamp.fromDate(new Date(body.estimatedRestoreTime))
          : null,
        affectedPopulation: body.affectedPopulation,
        feederId: body.feederId ?? null,
        transformerId: body.transformerId ?? null,
        progress: 0,
        createdAt: FieldValue.serverTimestamp(),
        createdBy: principal.uid,
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: principal.uid,
      };
      transaction.create(outage, document);
      writeAudit(transaction, {
        actorId: principal.uid,
        actorRole: principal.role,
        action: "outage.create",
        resource: "outages",
        resourceId: outage.id,
        requestId: request.requestId,
        after: document,
      });
      const commandResult = { id: outage.id, status };
      transaction.create(idempotency.reference, {
        actorId: principal.uid,
        requestHash: idempotency.requestHash,
        result: commandResult,
        createdAt: Timestamp.now(),
        expiresAt: idempotencyExpiry(),
      });
      return commandResult;
    });

    if (result.id === outage.id) {
      await Promise.allSettled(
        body.areaIds.map((areaId) =>
          notifyArea(areaId, {
            title: "Power outage reported",
            body: body.reason,
            data: {
              category: "powerOutage",
              outageId: result.id,
              areaId,
            },
          }),
        ),
      );
    }
    response.status(201).json(result);
  },
);

outagesRouter.patch(
  "/outages/:outageId/status",
  requireRoles("providerStaff", "superAdmin"),
  validateBody(updateStatusSchema),
  async (request, response) => {
    const principal = actor(request);
    const body = updateStatusSchema.parse(request.body);
    const outage = db
      .collection("outages")
      .doc(pathParam(request, "outageId"));
    const idempotency = idempotencyContext<CommandResult>(request);
    const result = await db.runTransaction(async (transaction) => {
      const previous = await replay(
        transaction,
        idempotency.reference,
        idempotency.requestHash,
      );
      if (previous) return previous;

      const snapshot = await transaction.get(outage);
      if (!snapshot.exists) {
        throw new ApiError(404, "OUTAGE_NOT_FOUND", "Outage was not found.");
      }
      const current = snapshot.data()!;
      assertProviderAccess(principal, String(current.providerId));
      assertOutageTransition(
        current.status as OutageStatus,
        body.status,
      );

      const patch = {
        status: body.status,
        estimatedRestoreTime: body.estimatedRestoreTime
          ? Timestamp.fromDate(new Date(body.estimatedRestoreTime))
          : current.estimatedRestoreTime,
        progress: progressFor(body.status),
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: principal.uid,
      };
      transaction.update(outage, patch);
      transaction.create(outage.collection("updates").doc(), {
        fromStatus: current.status,
        status: body.status,
        message: body.message,
        estimatedRestoreTime: patch.estimatedRestoreTime,
        createdAt: FieldValue.serverTimestamp(),
        createdBy: principal.uid,
      });
      writeAudit(transaction, {
        actorId: principal.uid,
        actorRole: principal.role,
        action: "outage.status.update",
        resource: "outages",
        resourceId: outage.id,
        requestId: request.requestId,
        before: current,
        after: { ...current, ...patch },
      });
      const commandResult = { id: outage.id, status: body.status };
      transaction.create(idempotency.reference, {
        actorId: principal.uid,
        requestHash: idempotency.requestHash,
        result: commandResult,
        createdAt: Timestamp.now(),
        expiresAt: idempotencyExpiry(),
      });
      return {
        result: commandResult,
        areaIds: current.areaIds as string[],
      };
    });

    if ("areaIds" in result) {
      await Promise.allSettled(
        result.areaIds.map((areaId) =>
          notifyArea(areaId, {
            title:
              body.status === "restored"
                ? "Power restored"
                : "Outage update",
            body: body.message,
            data: {
              category:
                body.status === "restored"
                  ? "powerRestored"
                  : "powerOutage",
              outageId: result.result.id,
              areaId,
            },
          }),
        ),
      );
      response.json(result.result);
      return;
    }
    response.json(result);
  },
);

async function validateAreas(
  transaction: Transaction,
  areaIds: string[],
  providerId: string,
): Promise<void> {
  const uniqueIds = [...new Set(areaIds)];
  const snapshots = await Promise.all(
    uniqueIds.map((areaId) =>
      transaction.get(db.collection("areas").doc(areaId)),
    ),
  );
  for (const snapshot of snapshots) {
    if (!snapshot.exists || snapshot.data()?.providerId !== providerId) {
      throw new ApiError(
        400,
        "INVALID_AREA",
        "One or more areas do not belong to the selected provider.",
      );
    }
  }
}

function progressFor(status: OutageStatus): number {
  return (
    {
      reported: 0.05,
      investigating: 0.2,
      identified: 0.35,
      repairing: 0.6,
      restoring: 0.85,
      restored: 1,
      scheduled: 0,
      emergency: 0.05,
      cancelled: 0,
    } satisfies Record<OutageStatus, number>
  )[status];
}
