import { Router } from "express";
import { FieldValue } from "firebase-admin/firestore";
import { z } from "zod";

import { auth, db } from "../firebase.js";
import { writeAudit } from "../lib/audit.js";
import { ApiError } from "../lib/problem.js";
import { pathParam } from "../lib/request.js";
import {
  actor,
  authenticate,
  requireRoles,
} from "../middleware/auth.js";
import { validateBody } from "../middleware/validate.js";

const updateRoleSchema = z
  .object({
    role: z.enum([
      "consumer",
      "providerStaff",
      "technician",
      "superAdmin",
    ]),
    providerId: z.string().min(1).nullable().optional(),
    regionIds: z.array(z.string().min(1)).max(100).default([]),
  })
  .strict()
  .superRefine((value, context) => {
    if (
      ["providerStaff", "technician"].includes(value.role) &&
      !value.providerId
    ) {
      context.addIssue({
        code: "custom",
        path: ["providerId"],
        message: "Provider staff and technicians require a providerId.",
      });
    }
  });

export const adminRouter = Router();

adminRouter.use(authenticate, requireRoles("superAdmin"));

adminRouter.put(
  "/admin/users/:userId/role",
  validateBody(updateRoleSchema),
  async (request, response) => {
    const principal = actor(request);
    const body = updateRoleSchema.parse(request.body);
    const userId = pathParam(request, "userId");
    if (userId === principal.uid && body.role !== "superAdmin") {
      throw new ApiError(
        409,
        "SELF_DEMOTION_FORBIDDEN",
        "Administrators cannot remove their own admin role.",
      );
    }

    const userRecord = await auth.getUser(userId).catch(() => null);
    if (!userRecord) {
      throw new ApiError(404, "USER_NOT_FOUND", "User was not found.");
    }
    const claims = {
      role: body.role,
      providerId: body.providerId ?? null,
      regionIds: body.regionIds,
    };
    await auth.setCustomUserClaims(userId, claims);
    try {
      const user = db.collection("users").doc(userId);
      await db.runTransaction(async (transaction) => {
        const snapshot = await transaction.get(user);
        const before = snapshot.data();
        transaction.set(
          user,
          {
            role: body.role,
            providerId: body.providerId ?? null,
            regionIds: body.regionIds,
            updatedAt: FieldValue.serverTimestamp(),
            updatedBy: principal.uid,
          },
          { merge: true },
        );
        writeAudit(transaction, {
          actorId: principal.uid,
          actorRole: principal.role,
          action: "user.role.update",
          resource: "users",
          resourceId: userId,
          requestId: request.requestId,
          before,
          after: claims,
        });
      });
      await auth.revokeRefreshTokens(userId);
    } catch (error) {
      await auth.setCustomUserClaims(
        userId,
        userRecord.customClaims ?? null,
      );
      throw error;
    }

    response.json({
      id: userId,
      ...claims,
      sessionsRevoked: true,
    });
  },
);
