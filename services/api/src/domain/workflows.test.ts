import { describe, expect, it } from "vitest";

import {
  assertComplaintTransition,
  assertOutageTransition,
} from "./workflows.js";

describe("outage workflow", () => {
  it("allows forward restoration progress", () => {
    expect(() => assertOutageTransition("repairing", "restoring")).not.toThrow();
    expect(() => assertOutageTransition("restoring", "restored")).not.toThrow();
  });

  it("rejects reopening a restored outage", () => {
    expect(() => assertOutageTransition("restored", "repairing")).toThrow();
  });
});

describe("complaint workflow", () => {
  it("supports the documented lifecycle", () => {
    expect(() => assertComplaintTransition("submitted", "verified")).not.toThrow();
    expect(() => assertComplaintTransition("verified", "assigned")).not.toThrow();
    expect(() =>
      assertComplaintTransition("assigned", "repairStarted"),
    ).not.toThrow();
  });

  it("rejects skipping from submitted to resolved", () => {
    expect(() => assertComplaintTransition("submitted", "resolved")).toThrow();
  });
});
