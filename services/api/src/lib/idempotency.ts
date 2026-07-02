import { createHash } from "node:crypto";

import type { Request } from "express";
import type {
  DocumentReference,
  Transaction,
} from "firebase-admin/firestore";
import { Timestamp } from "firebase-admin/firestore";

import { db } from "../firebase.js";
import { ApiError } from "./problem.js";

type CommandRecord<T> = {
  actorId: string;
  requestHash: string;
  result: T;
  createdAt: Timestamp;
  expiresAt: Timestamp;
};

export function idempotencyExpiry(): Timestamp {
  return Timestamp.fromMillis(Date.now() + 24 * 60 * 60 * 1000);
}

export function idempotencyContext<T>(request: Request): {
  reference: DocumentReference<CommandRecord<T>>;
  requestHash: string;
} {
  const key = request.header("idempotency-key");
  if (!key || key.length < 16 || key.length > 128) {
    throw new ApiError(
      400,
      "IDEMPOTENCY_KEY_REQUIRED",
      "A valid Idempotency-Key header is required.",
    );
  }
  const uid = request.auth?.uid;
  if (!uid) {
    throw new ApiError(401, "AUTH_REQUIRED", "Authentication is required.");
  }
  const identity = createHash("sha256").update(`${uid}:${key}`).digest("hex");
  const requestHash = createHash("sha256")
    .update(
      JSON.stringify({
        method: request.method,
        path: request.path,
        body: request.body,
      }),
    )
    .digest("hex");
  return {
    reference: db
      .collection("idempotencyKeys")
      .doc(identity) as DocumentReference<CommandRecord<T>>,
    requestHash,
  };
}

export async function replay<T>(
  transaction: Transaction,
  reference: DocumentReference<CommandRecord<T>>,
  requestHash: string,
): Promise<T | null> {
  const snapshot = await transaction.get(reference);
  if (!snapshot.exists) return null;
  const stored = snapshot.data() as CommandRecord<T>;
  if (stored.requestHash !== requestHash) {
    throw new ApiError(
      409,
      "IDEMPOTENCY_CONFLICT",
      "This idempotency key was used for a different request.",
    );
  }
  return stored.result;
}
