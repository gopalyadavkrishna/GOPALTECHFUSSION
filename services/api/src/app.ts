import cors from "cors";
import express, { type Express } from "express";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import pino from "pino";
import { pinoHttp } from "pino-http";

import { config, corsOrigins } from "./config.js";
import { errorHandler, notFound } from "./lib/problem.js";
import { requestContext } from "./middleware/request-context.js";
import { adminRouter } from "./routes/admin.js";
import { complaintsRouter } from "./routes/complaints.js";
import { healthRouter } from "./routes/health.js";
import { outagesRouter } from "./routes/outages.js";

const logger = pino({
  level: config.LOG_LEVEL,
  redact: {
    paths: [
      "req.headers.authorization",
      "req.headers.x-firebase-appcheck",
      "req.body.phone",
      "req.body.email",
    ],
    censor: "[REDACTED]",
  },
});

export function createApp(): Express {
  const app = express();
  app.disable("x-powered-by");
  app.set("trust proxy", 1);
  app.use(requestContext);
  app.use(pinoHttp({ logger }));
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: "same-site" },
    }),
  );
  app.use(
    cors({
      origin(origin, callback) {
        if (!origin || corsOrigins.has(origin)) {
          callback(null, true);
          return;
        }
        callback(null, false);
      },
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
      allowedHeaders: [
        "Authorization",
        "Content-Type",
        "Idempotency-Key",
        "X-Firebase-AppCheck",
        "X-Request-Id",
      ],
      maxAge: 86400,
    }),
  );
  app.use(express.json({ limit: "1mb" }));
  app.use(
    rateLimit({
      windowMs: 60_000,
      limit: 120,
      standardHeaders: "draft-8",
      legacyHeaders: false,
      skip: (request) => request.path === "/v1/health",
    }),
  );

  app.use("/v1", healthRouter);
  app.use("/v1", outagesRouter);
  app.use("/v1", complaintsRouter);
  app.use("/v1", adminRouter);
  app.use(notFound);
  app.use(errorHandler);
  return app;
}
