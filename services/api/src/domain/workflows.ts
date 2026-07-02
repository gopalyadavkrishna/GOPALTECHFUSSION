import { ApiError } from "../lib/problem.js";

export const outageStatuses = [
  "reported",
  "investigating",
  "identified",
  "repairing",
  "restoring",
  "restored",
  "scheduled",
  "emergency",
  "cancelled",
] as const;

export type OutageStatus = (typeof outageStatuses)[number];

export const complaintStatuses = [
  "submitted",
  "verified",
  "assigned",
  "repairStarted",
  "restoring",
  "resolved",
  "rejected",
  "cancelled",
] as const;

export type ComplaintStatus = (typeof complaintStatuses)[number];

const outageTransitions: Record<OutageStatus, ReadonlySet<OutageStatus>> = {
  reported: new Set(["investigating", "identified", "cancelled"]),
  investigating: new Set(["identified", "repairing", "cancelled"]),
  identified: new Set(["repairing", "cancelled"]),
  repairing: new Set(["restoring", "cancelled"]),
  restoring: new Set(["restored", "repairing"]),
  restored: new Set(),
  scheduled: new Set(["investigating", "repairing", "cancelled"]),
  emergency: new Set(["investigating", "identified", "repairing", "cancelled"]),
  cancelled: new Set(),
};

const complaintTransitions: Record<
  ComplaintStatus,
  ReadonlySet<ComplaintStatus>
> = {
  submitted: new Set(["verified", "rejected", "cancelled"]),
  verified: new Set(["assigned", "rejected", "cancelled"]),
  assigned: new Set(["repairStarted", "verified", "cancelled"]),
  repairStarted: new Set(["restoring", "assigned", "cancelled"]),
  restoring: new Set(["resolved", "repairStarted"]),
  resolved: new Set(),
  rejected: new Set(),
  cancelled: new Set(),
};

export function assertOutageTransition(
  from: OutageStatus,
  to: OutageStatus,
): void {
  if (from === to) return;
  if (!outageTransitions[from].has(to)) {
    throw new ApiError(
      409,
      "INVALID_OUTAGE_TRANSITION",
      `Outage cannot move from ${from} to ${to}.`,
    );
  }
}

export function assertComplaintTransition(
  from: ComplaintStatus,
  to: ComplaintStatus,
): void {
  if (from === to) return;
  if (!complaintTransitions[from].has(to)) {
    throw new ApiError(
      409,
      "INVALID_COMPLAINT_TRANSITION",
      `Complaint cannot move from ${from} to ${to}.`,
    );
  }
}
