import type { NextFunction, Request, Response } from "express";

import { config } from "../config.js";
import { appCheck, auth } from "../firebase.js";
import { ApiError } from "../lib/problem.js";

export type AppRole =
  | "consumer"
  | "providerStaff"
  | "technician"
  | "superAdmin";

export async function authenticate(
  request: Request,
  _response: Response,
  next: NextFunction,
): Promise<void> {
  const authorization = request.header("authorization");
  if (!authorization?.startsWith("Bearer ")) {
    throw new ApiError(401, "AUTH_REQUIRED", "Authentication is required.");
  }

  const idToken = authorization.slice("Bearer ".length);
  try {
    request.auth = await auth.verifyIdToken(idToken, true);
  } catch {
    throw new ApiError(401, "INVALID_TOKEN", "The session is invalid.");
  }

  const appCheckToken = request.header("x-firebase-appcheck");
  if (config.APP_CHECK_ENFORCED && !appCheckToken) {
    throw new ApiError(401, "APP_CHECK_REQUIRED", "App verification failed.");
  }
  if (appCheckToken) {
    try {
      await appCheck.verifyToken(appCheckToken);
    } catch {
      throw new ApiError(401, "INVALID_APP_CHECK", "App verification failed.");
    }
  }
  next();
}

export function requireRoles(...roles: AppRole[]) {
  return (request: Request, _response: Response, next: NextFunction): void => {
    const role = (request.auth?.role as AppRole | undefined) ?? "consumer";
    if (!role || !roles.includes(role)) {
      throw new ApiError(
        403,
        "INSUFFICIENT_ROLE",
        "You do not have access to this operation.",
      );
    }
    next();
  };
}

export function actor(request: Request): {
  uid: string;
  role: AppRole;
  providerId?: string;
} {
  const token = request.auth;
  if (!token) {
    throw new ApiError(401, "AUTH_REQUIRED", "Authentication is required.");
  }
  const role = (token.role as AppRole | undefined) ?? "consumer";
  return {
    uid: token.uid,
    role,
    ...(typeof token.providerId === "string"
      ? { providerId: token.providerId }
      : {}),
  };
}
