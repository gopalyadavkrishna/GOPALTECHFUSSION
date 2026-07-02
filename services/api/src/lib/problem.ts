import type { NextFunction, Request, Response } from "express";
import { ZodError } from "zod";

export class ApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
  }
}

export function notFound(
  request: Request,
  response: Response,
  _next: NextFunction,
): void {
  response.status(404).type("application/problem+json").json({
    type: "https://poweralert.example/problems/not-found",
    title: "Resource not found",
    status: 404,
    code: "NOT_FOUND",
    requestId: request.requestId,
  });
}

export function errorHandler(
  error: unknown,
  request: Request,
  response: Response,
  _next: NextFunction,
): void {
  const apiError =
    error instanceof ApiError
      ? error
      : error instanceof ZodError
        ? new ApiError(400, "VALIDATION_FAILED", error.issues[0]?.message ?? "")
        : new ApiError(500, "INTERNAL", "An unexpected error occurred.");

  request.log?.error(
    {
      err: error,
      requestId: request.requestId,
      code: apiError.code,
    },
    "request failed",
  );

  response.status(apiError.status).type("application/problem+json").json({
    type: `https://poweralert.example/problems/${apiError.code.toLowerCase()}`,
    title: apiError.message,
    status: apiError.status,
    code: apiError.code,
    requestId: request.requestId,
  });
}
