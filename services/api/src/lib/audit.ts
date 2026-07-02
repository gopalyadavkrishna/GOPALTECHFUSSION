import { createHash } from "node:crypto";

import type { Transaction } from "firebase-admin/firestore";
import { FieldValue } from "firebase-admin/firestore";

import { db } from "../firebase.js";
import type { AppRole } from "../middleware/auth.js";

export function writeAudit(
  transaction: Transaction,
  input: {
    actorId: string;
    actorRole: AppRole;
    action: string;
    resource: string;
    resourceId: string;
    requestId: string;
    before?: unknown;
    after?: unknown;
  },
): void {
  const hash = (value: unknown) =>
    value === undefined
      ? null
      : createHash("sha256").update(JSON.stringify(value)).digest("hex");
  transaction.create(db.collection("auditLogs").doc(), {
    actorId: input.actorId,
    actorRole: input.actorRole,
    action: input.action,
    resource: input.resource,
    resourceId: input.resourceId,
    requestId: input.requestId,
    beforeHash: hash(input.before),
    afterHash: hash(input.after),
    createdAt: FieldValue.serverTimestamp(),
  });
}
