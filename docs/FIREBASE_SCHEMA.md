# Firebase schema

All timestamps are Firestore `Timestamp` values. All write paths include
`createdAt`, `createdBy`, `updatedAt`, and `updatedBy` where applicable.

| Collection | Key fields |
| --- | --- |
| `users/{uid}` | `name`, `phone`, `email`, `role`, `providerId`, `regionIds`, `locale`, `consentVersion`, `disabled` |
| `users/{uid}/savedLocations/{id}` | `label`, `areaId`, `position`, `isFavorite`, `notificationEnabled` |
| `users/{uid}/devices/{id}` | `fcmToken`, `platform`, `appVersion`, `lastSeenAt` |
| `providers/{id}` | `name`, `regionIds`, `contact`, `status`, `slaMinutes` |
| `areas/{id}` | `name`, `regionId`, `providerId`, `geohash`, `center`, `polygonRef` |
| `outages/{id}` | `providerId`, `areaIds`, `reason`, `severity`, `priority`, `status`, `startTime`, `estimatedRestoreTime`, `affectedPopulation`, `location`, `geohash` |
| `outages/{id}/updates/{id}` | `status`, `message`, `estimatedRestoreTime`, `createdAt`, `createdBy` |
| `outages/{id}/followers/{uid}` | `createdAt` |
| `complaints/{id}` | `userId`, `providerId`, `areaId`, `issueType`, `description`, `attachmentPaths`, `location`, `priority`, `technicianId`, `status` |
| `complaints/{id}/timeline/{id}` | `fromStatus`, `toStatus`, `note`, `actorId`, `actorRole`, `createdAt` |
| `maintenance/{id}` | `providerId`, `areaIds`, `title`, `description`, `startTime`, `endTime`, `status` |
| `technicians/{uid}` | `providerId`, `name`, `phone`, `availability`, `skills`, `currentLocation`, `completionRate` |
| `notifications/{id}` | `userId`, `areaId`, `category`, `title`, `message`, `data`, `readAt`, `createdAt` |
| `riskPredictions/{id}` | `areaId`, `modelVersion`, `riskScore`, `drivers`, `validFrom`, `validUntil`, `generatedAt` |
| `analyticsDaily/{yyyy-MM-dd}` | pre-aggregated platform and provider metrics |
| `auditLogs/{id}` | `actorId`, `actorRole`, `action`, `resource`, `resourceId`, `requestId`, `beforeHash`, `afterHash`, `createdAt` |
| `idempotencyKeys/{hash}` | `actorId`, `requestHash`, `result`, `createdAt`, `expiresAt` (24-hour TTL) |

## Status state machines

### Outage

`reported -> investigating -> identified -> repairing -> restoring -> restored`

`scheduled` is used for maintenance. `cancelled` is terminal.

### Complaint

`submitted -> verified -> assigned -> repairStarted -> restoring -> resolved`

`rejected` and `cancelled` are terminal and require a reason.

State transitions are enforced by the API, not only by the client.

## Retention

- Device tokens: delete after 90 days without activity.
- Notifications: user-visible records expire after 180 days.
- Raw technician location: retain only as required for active work and policy.
- Audit logs: route to immutable log storage before Firestore TTL deletion.
- Attachments: malware-scan on finalize and quarantine failed objects.
