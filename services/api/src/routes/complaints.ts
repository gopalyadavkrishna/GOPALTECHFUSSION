import { Router } from "express";
import {
  type DocumentData,
  FieldValue,
  GeoPoint,
  Timestamp,
} from "firebase-admin/firestore";
import { z } from "zod";

import {
  assertComplaintTransition,
  complaintStatuses,
  type ComplaintStatus,
} from "../domain/workflows.js";
import { db } from "../firebase.js";
import { writeAudit } from "../lib/audit.js";
import {
  idempotencyContext,
  idempotencyExpiry,
  replay,
} from "../lib/idempotency.js";
import { notifyUser } from "../lib/notifications.js";
import { ApiError } from "../lib/problem.js";
import { pathParam } from "../lib/request.js";
import { assertProviderAccess } from "../lib/tenancy.js";
import {
  actor,
  authenticate,
  requireRoles,
} from "../middleware/auth.js";
import { validateBody } from "../middleware/validate.js";

const issueTypes = [
  "noPower",
  "lowVoltage",
  "transformerFault",
  "poleDamage",
  "wireDamage",
  "streetLight",
  "meterIssue",
  "other",
] as const;

const createComplaintSchema = z
  .object({
    areaId: z.string().min(1),
    issueType: z.enum(issueTypes),
    description: z.string().trim().min(10).max(1000),
    latitude: z.number().min(-90).max(90),
    longitude: z.number().min(-180).max(180),
    attachmentPaths: z.array(z.string().min(1).max(500)).max(8).default([]),
  })
  .strict();

const assignComplaintSchema = z
  .object({
    technicianId: z.string().min(1),
    note: z.string().trim().max(500).optional(),
  })
  .strict();

const updateComplaintStatusSchema = z
  .object({
    status: z.enum(complaintStatuses),
    note: z.string().trim().min(3).max(500),
    repairPhotoPaths: z.array(z.string().min(1).max(500)).max(8).default([]),
  })
  .strict();

type ComplaintCommandResult = {
  id: string;
  status: ComplaintStatus;
};

export const complaintsRouter = Router();

complaintsRouter.use(authenticate);

complaintsRouter.post(
  "/complaints",
  requireRoles("consumer"),
  validateBody(createComplaintSchema),
  async (request, response) => {
    const principal = actor(request);
    const body = createComplaintSchema.parse(request.body);
    assertAttachmentOwnership(body.attachmentPaths, principal.uid);
    const complaint = db.collection("complaints").doc();
    const idempotency =
      idempotencyContext<ComplaintCommandResult>(request);

    const result = await db.runTransaction(async (transaction) => {
      const previous = await replay(
        transaction,
        idempotency.reference,
        idempotency.requestHash,
      );
      if (previous) return previous;

      const area = await transaction.get(
        db.collection("areas").doc(body.areaId),
      );
      if (!area.exists) {
        throw new ApiError(400, "INVALID_AREA", "The selected area is invalid.");
      }
      const areaData = area.data()!;
      const providerId = String(areaData.providerId);
      const document = {
        userId: principal.uid,
        providerId,
        areaId: body.areaId,
        areaName: String(areaData.name ?? "Unknown area"),
        issueType: body.issueType,
        description: body.description,
        attachmentPaths: body.attachmentPaths,
        location: new GeoPoint(body.latitude, body.longitude),
        priority: priorityFor(body.issueType),
        technicianId: null,
        status: "submitted" as ComplaintStatus,
        createdAt: FieldValue.serverTimestamp(),
        createdBy: principal.uid,
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: principal.uid,
      };
      transaction.create(complaint, document);
      transaction.create(complaint.collection("timeline").doc(), {
        fromStatus: null,
        toStatus: "submitted",
        note: "Complaint submitted",
        actorId: principal.uid,
        actorRole: principal.role,
        createdAt: FieldValue.serverTimestamp(),
      });
      writeAudit(transaction, {
        actorId: principal.uid,
        actorRole: principal.role,
        action: "complaint.create",
        resource: "complaints",
        resourceId: complaint.id,
        requestId: request.requestId,
        after: document,
      });
      const commandResult = {
        id: complaint.id,
        status: "submitted" as const,
      };
      transaction.create(idempotency.reference, {
        actorId: principal.uid,
        requestHash: idempotency.requestHash,
        result: commandResult,
        createdAt: Timestamp.now(),
        expiresAt: idempotencyExpiry(),
      });
      return commandResult;
    });

    response.status(201).json(result);
  },
);

complaintsRouter.post(
  "/complaints/:complaintId/assign",
  requireRoles("providerStaff", "superAdmin"),
  validateBody(assignComplaintSchema),
  async (request, response) => {
    const principal = actor(request);
    const body = assignComplaintSchema.parse(request.body);
    const complaint = db
      .collection("complaints")
      .doc(pathParam(request, "complaintId"));
    const technician = db.collection("technicians").doc(body.technicianId);
    const idempotency =
      idempotencyContext<ComplaintCommandResult>(request);

    const outcome = await db.runTransaction(async (transaction) => {
      const previous = await replay(
        transaction,
        idempotency.reference,
        idempotency.requestHash,
      );
      if (previous) return { result: previous, userId: null };

      const [complaintSnapshot, technicianSnapshot] = await Promise.all([
        transaction.get(complaint),
        transaction.get(technician),
      ]);
      if (!complaintSnapshot.exists) {
        throw new ApiError(
          404,
          "COMPLAINT_NOT_FOUND",
          "Complaint was not found.",
        );
      }
      if (!technicianSnapshot.exists) {
        throw new ApiError(
          400,
          "TECHNICIAN_NOT_FOUND",
          "Technician was not found.",
        );
      }
      const current = complaintSnapshot.data()!;
      const technicianData = technicianSnapshot.data()!;
      const providerId = String(current.providerId);
      assertProviderAccess(principal, providerId);
      if (technicianData.providerId !== providerId) {
        throw new ApiError(
          400,
          "TECHNICIAN_PROVIDER_MISMATCH",
          "Technician belongs to another provider.",
        );
      }
      if (!["verified", "assigned"].includes(current.status)) {
        throw new ApiError(
          409,
          "COMPLAINT_NOT_ASSIGNABLE",
          "Complaint is not in an assignable state.",
        );
      }

      const patch = {
        technicianId: body.technicianId,
        status: "assigned" as ComplaintStatus,
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: principal.uid,
      };
      transaction.update(complaint, patch);
      transaction.create(complaint.collection("timeline").doc(), {
        fromStatus: current.status,
        toStatus: "assigned",
        note: body.note ?? "Technician assigned",
        actorId: principal.uid,
        actorRole: principal.role,
        createdAt: FieldValue.serverTimestamp(),
      });
      writeAudit(transaction, {
        actorId: principal.uid,
        actorRole: principal.role,
        action: "complaint.assign",
        resource: "complaints",
        resourceId: complaint.id,
        requestId: request.requestId,
        before: current,
        after: { ...current, ...patch },
      });
      const commandResult = {
        id: complaint.id,
        status: "assigned" as const,
      };
      transaction.create(idempotency.reference, {
        actorId: principal.uid,
        requestHash: idempotency.requestHash,
        result: commandResult,
        createdAt: Timestamp.now(),
        expiresAt: idempotencyExpiry(),
      });
      return { result: commandResult, userId: String(current.userId) };
    });

    if (outcome.userId) {
      await Promise.allSettled([
        notifyUser(outcome.userId, {
          title: "Complaint assigned",
          body: "A technician has been assigned to your complaint.",
          data: {
            category: "complaintUpdate",
            complaintId: outcome.result.id,
          },
        }),
        notifyUser(body.technicianId, {
          title: "New job assigned",
          body: `Complaint ${outcome.result.id} is ready for action.`,
          data: {
            category: "jobAssigned",
            complaintId: outcome.result.id,
          },
        }),
      ]);
    }
    response.json(outcome.result);
  },
);

complaintsRouter.patch(
  "/complaints/:complaintId/status",
  requireRoles("providerStaff", "technician", "superAdmin"),
  validateBody(updateComplaintStatusSchema),
  async (request, response) => {
    const principal = actor(request);
    const body = updateComplaintStatusSchema.parse(request.body);
    const complaint = db
      .collection("complaints")
      .doc(pathParam(request, "complaintId"));
    const idempotency =
      idempotencyContext<ComplaintCommandResult>(request);

    const outcome = await db.runTransaction(async (transaction) => {
      const previous = await replay(
        transaction,
        idempotency.reference,
        idempotency.requestHash,
      );
      if (previous) return { result: previous, userId: null };

      const snapshot = await transaction.get(complaint);
      if (!snapshot.exists) {
        throw new ApiError(
          404,
          "COMPLAINT_NOT_FOUND",
          "Complaint was not found.",
        );
      }
      const current = snapshot.data()!;
      authorizeComplaintUpdate(principal, current);
      assertComplaintTransition(
        current.status as ComplaintStatus,
        body.status,
      );
      if (body.status === "assigned") {
        throw new ApiError(
          409,
          "USE_ASSIGNMENT_COMMAND",
          "Assign a technician with the assignment endpoint.",
        );
      }
      if (
        principal.role === "technician" &&
        !["repairStarted", "restoring", "resolved"].includes(body.status)
      ) {
        throw new ApiError(
          403,
          "TECHNICIAN_STATUS_FORBIDDEN",
          "Technicians cannot set this complaint status.",
        );
      }
      assertRepairPhotoOwnership(
        body.repairPhotoPaths,
        principal.uid,
        complaint.id,
      );

      const patch = {
        status: body.status,
        repairPhotoPaths: body.repairPhotoPaths,
        resolvedAt:
          body.status === "resolved" ? FieldValue.serverTimestamp() : null,
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: principal.uid,
      };
      transaction.update(complaint, patch);
      transaction.create(complaint.collection("timeline").doc(), {
        fromStatus: current.status,
        toStatus: body.status,
        note: body.note,
        actorId: principal.uid,
        actorRole: principal.role,
        createdAt: FieldValue.serverTimestamp(),
      });
      writeAudit(transaction, {
        actorId: principal.uid,
        actorRole: principal.role,
        action: "complaint.status.update",
        resource: "complaints",
        resourceId: complaint.id,
        requestId: request.requestId,
        before: current,
        after: { ...current, ...patch },
      });
      const commandResult = { id: complaint.id, status: body.status };
      transaction.create(idempotency.reference, {
        actorId: principal.uid,
        requestHash: idempotency.requestHash,
        result: commandResult,
        createdAt: Timestamp.now(),
        expiresAt: idempotencyExpiry(),
      });
      return { result: commandResult, userId: String(current.userId) };
    });

    if (outcome.userId) {
      await Promise.allSettled([
        notifyUser(outcome.userId, {
          title:
            body.status === "resolved"
              ? "Complaint resolved"
              : "Complaint update",
          body: body.note,
          data: {
            category: "complaintUpdate",
            complaintId: outcome.result.id,
            status: body.status,
          },
        }),
      ]);
    }
    response.json(outcome.result);
  },
);

function authorizeComplaintUpdate(
  principal: ReturnType<typeof actor>,
  complaint: DocumentData,
): void {
  if (principal.role === "technician") {
    if (complaint.technicianId !== principal.uid) {
      throw new ApiError(
        403,
        "JOB_SCOPE_VIOLATION",
        "This complaint is assigned to another technician.",
      );
    }
    return;
  }
  assertProviderAccess(principal, String(complaint.providerId));
}

function assertAttachmentOwnership(paths: string[], userId: string): void {
  if (paths.some((path) => !path.startsWith(`complaints/${userId}/`))) {
    throw new ApiError(
      400,
      "INVALID_ATTACHMENT_PATH",
      "Complaint attachment path is invalid.",
    );
  }
}

function assertRepairPhotoOwnership(
  paths: string[],
  technicianId: string,
  complaintId: string,
): void {
  if (
    paths.some(
      (path) =>
        !path.startsWith(
          `technician-jobs/${technicianId}/${complaintId}/`,
        ),
    )
  ) {
    throw new ApiError(
      400,
      "INVALID_REPAIR_PHOTO_PATH",
      "Repair photo path is invalid.",
    );
  }
}

function priorityFor(issueType: (typeof issueTypes)[number]): string {
  return ["poleDamage", "wireDamage", "transformerFault"].includes(issueType)
    ? "urgent"
    : "normal";
}
