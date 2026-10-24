/** Response body of the backend `GET /health` endpoint (added in milestone M2). */
export interface HealthResponse {
  status: "ok";
  version: string;
}

/** Runtime check for untrusted JSON: true only for a well-formed health response. */
export function isHealthResponse(value: unknown): value is HealthResponse {
  if (typeof value !== "object" || value === null) {
    return false;
  }
  const { status, version } = value as { status?: unknown; version?: unknown };
  return status === "ok" && typeof version === "string";
}
