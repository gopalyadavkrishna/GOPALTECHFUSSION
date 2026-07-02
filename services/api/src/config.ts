import { z } from "zod";

const schema = z.object({
  NODE_ENV: z
    .enum(["development", "test", "production"])
    .default("development"),
  PORT: z.coerce.number().int().positive().default(8080),
  GCP_PROJECT_ID: z.string().min(1).default("power-alert-development"),
  CORS_ORIGINS: z.string().default("http://localhost:3000"),
  APP_CHECK_ENFORCED: z
    .enum(["true", "false"])
    .default("false")
    .transform((value) => value === "true"),
  LOG_LEVEL: z
    .enum(["fatal", "error", "warn", "info", "debug", "trace"])
    .default("info"),
});

export const config = schema.parse(process.env);

export const corsOrigins = new Set(
  config.CORS_ORIGINS.split(",")
    .map((origin) => origin.trim())
    .filter(Boolean),
);
