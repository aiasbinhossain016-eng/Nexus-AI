import { describe, expect, it } from "vitest";

import { isHealthResponse } from "./index";

describe("isHealthResponse", () => {
  it("accepts a well-formed response", () => {
    expect(isHealthResponse({ status: "ok", version: "0.0.0" })).toBe(true);
  });

  it("rejects a wrong status", () => {
    expect(isHealthResponse({ status: "error", version: "0.0.0" })).toBe(false);
  });

  it("rejects a missing or non-string version", () => {
    expect(isHealthResponse({ status: "ok" })).toBe(false);
    expect(isHealthResponse({ status: "ok", version: 1 })).toBe(false);
  });

  it("rejects non-objects", () => {
    expect(isHealthResponse(null)).toBe(false);
    expect(isHealthResponse("ok")).toBe(false);
    expect(isHealthResponse(undefined)).toBe(false);
  });
});
