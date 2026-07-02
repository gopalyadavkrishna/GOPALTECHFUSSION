# Operations

## Service objectives

| Signal | Target |
| --- | --- |
| API availability | 99.95% monthly |
| P95 read latency | under 300 ms |
| P95 command latency | under 800 ms, excluding uploads |
| FCM accepted by provider | over 98% |
| Crash-free users | over 99.5% |
| Consumer app cold start | under 2 seconds on target devices |

## Alerts

- Error rate above 2% for 5 minutes
- P95 command latency above 1.5 seconds for 10 minutes
- Firestore denied writes from server code
- FCM failure ratio above 5%
- Complaint backlog or restoration SLA burn rate
- Prediction input freshness outside its expected window
- App crash-free users below 99.5%

## Incident response

1. Identify affected providers, regions, and command paths.
2. Freeze unsafe mutations with a server-side feature flag.
3. Keep read-only status and emergency guidance available.
4. Communicate with exact timestamps and provider-scoped impact.
5. Reconcile idempotency records, audit logs, and notifications.
6. Publish a blameless review with corrective actions and owners.

## Backups

- Schedule Firestore exports to a separate protected bucket.
- Apply bucket retention and object versioning.
- Test restoration into an isolated project every quarter.
- Keep configuration, rules, indexes, and infrastructure definitions in source
  control.
