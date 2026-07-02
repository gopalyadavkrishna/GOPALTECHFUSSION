# Security baseline

## Identity and authorization

- Firebase Authentication is the identity provider.
- The API verifies ID tokens and App Check tokens on every protected request.
- Roles are custom claims issued only by trusted server code.
- Provider access is tenant-scoped with `providerId` and `regionIds` claims.
- Sensitive role or tenancy changes revoke refresh tokens immediately.
- Admin accounts require MFA and short session lifetimes.

## API controls

- HTTPS only, HSTS at the edge, strict CORS allowlist, request size limits.
- Cloud Run permits network invocation because Firebase bearer tokens are
  verified inside Express; every non-health API route still requires a valid
  ID token, and production additionally enforces App Check.
- Rate limits by user, IP, and endpoint risk.
- Zod validation rejects unknown fields.
- Idempotency keys protect ticket and outage command retries.
- Audit events include request ID and actor identity, but never tokens or PII.
- Error responses use stable codes and do not expose stack traces.

## Mobile controls

- Use Android Play Integrity through Firebase App Check.
- Store only refresh-safe preferences locally; use platform secure storage for
  secrets that cannot be avoided.
- Enable network security configuration and certificate pinning only with a
  documented backup-pin rotation plan.
- Restrict Maps API keys by package name and SHA-256 certificate.
- Obfuscation is defense in depth, not an authorization boundary.

## Data protection

- Collect explicit, versioned consent for location and notification use.
- Apply least-retention rules and Firestore TTL policies.
- Avoid exact location in analytics and logs.
- Encrypt data in transit and rely on Google-managed encryption at rest;
  consider customer-managed keys where policy requires them.
- Scan uploads, verify MIME from bytes, and strip image metadata.

## Production checklist

- Separate Google Cloud projects for dev, staging, and production.
- Workload Identity Federation for CI; no long-lived service account keys.
- Secret Manager for API secrets.
- Cloud Armor, budget alerts, audit log sinks, and Security Command Center.
- Backup and restore drills with documented RPO and RTO.
- Threat model and independent penetration test before public launch.
