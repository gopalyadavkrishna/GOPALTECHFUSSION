import { ApiError } from "./problem.js";

export function assertProviderAccess(
  actor: { role: string; providerId?: string },
  providerId: string,
): void {
  if (actor.role === "superAdmin") return;
  if (!actor.providerId || actor.providerId !== providerId) {
    throw new ApiError(
      403,
      "PROVIDER_SCOPE_VIOLATION",
      "The resource belongs to another provider.",
    );
  }
}
