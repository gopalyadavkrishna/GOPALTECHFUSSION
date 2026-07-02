import { randomUUID } from "node:crypto";

import type { NextFunction, Request, Response } from "express";

export function requestContext(
  request: Request,
  response: Response,
  next: NextFunction,
): void {
  const supplied = request.header("x-request-id");
  request.requestId =
    supplied && /^[a-zA-Z0-9._-]{8,128}$/.test(supplied)
      ? supplied
      : randomUUID();
  response.setHeader("x-request-id", request.requestId);
  next();
}
