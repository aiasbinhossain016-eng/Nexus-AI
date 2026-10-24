# ADR 0001: Windows-first architecture

Status: Accepted (approved by the project owner)

## Decisions

1. **Windows client:** Electron with React and TypeScript (Vite). `contextIsolation` on,
   `nodeIntegration` off, sandboxed renderer, strict CSP, typed and validated IPC only.
2. **Backend:** FastAPI with SQLite (SQLAlchemy 2, Alembic). For the MVP it runs as a local
   sidecar bound to `127.0.0.1` with a per-launch auth token.
3. **Provider keys:** each user's own key, stored with Electron `safeStorage`. The renderer
   never sees it. Logs redact it.
4. **Firebase:** not used.
5. **Android:** deferred until the Windows MVP passes review.

## Tooling baseline (verified 22 Oct 2026)

- Node.js 24 LTS for tooling. Electron embeds its own Node runtime.
- Python 3.14 for the backend. Python 3.15.0 was released on 9 Oct 2026; adopt it only after
  FastAPI, Pydantic and the packaging tool are confirmed to support it.
- Exact dependency versions are resolved at install time and recorded in lockfiles
  (`package-lock.json`, `uv.lock`). They are never guessed in documentation.

## Known risk

Bundling a Python sidecar into the Windows installer is the hardest packaging problem
(size, antivirus false positives, signing). An installer spike is scheduled in milestone M4
before feature work builds on top of it.
