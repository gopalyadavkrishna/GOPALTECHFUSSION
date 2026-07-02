import type { Request } from "express";

import { ApiError } from "./problem.js";

export function pathParam(request: Request, name: string): string {
  const value = request.params[name];
  if (typeof value !== "string" || value.length === 0) {
    throw new ApiError(
      400,
      "INVALID_PATH_PARAMETER",
      `Path parameter ${name} is required.`,
    );
  }
  return value;
}
