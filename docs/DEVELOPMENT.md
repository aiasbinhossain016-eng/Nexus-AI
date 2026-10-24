# NexusAI

Windows-first AI companion. Electron + React + TypeScript client, local FastAPI backend.
Android comes after the Windows MVP.

## Repository layout

```text
.
├── apps/desktop/           Electron main, preload and React renderer (M4, M5)
├── backend/                FastAPI backend and tests (M2, M3)
├── packages/api-contracts/ TypeScript types shared with the backend
├── docs/adr/               Architecture decision records
├── scripts/                Repository checks and helper scripts
└── .github/workflows/      Continuous integration
```

## Prerequisites (Windows 10/11)

- Git
- Node.js 24 LTS (see `.node-version`)
- [uv](https://docs.astral.sh/uv/) (installs and manages Python)

## First-time setup (PowerShell)

```powershell
node -v          # must print v24.x or newer
npm install
cd backend
uv sync
cd ..
```

## Everyday commands

| Command                           | What it does                                              |
| --------------------------------- | --------------------------------------------------------- |
| `npm run verify`                  | Structure check, format check, lint, type check and tests |
| `npm run format`                  | Format all files with Prettier                            |
| `npm run lint`                    | Lint with ESLint                                          |
| `npm run typecheck`               | Type-check every workspace package                        |
| `npm test`                        | Run unit tests with Vitest                                |
| `cd backend; uv run ruff check .` | Python lint                                               |
| `cd backend; uv run pyright`      | Python type check                                         |
| `cd backend; uv run pytest`       | Python tests                                              |

## Status

| Milestone | Scope                                             | State       |
| --------- | ------------------------------------------------- | ----------- |
| M1        | Repository skeleton                               | Done        |
| M1b       | Lint, types, tests and CI                         | In progress |
| M2        | Backend core                                      | Not started |
| M3        | AI adapters                                       | Not started |
| M4        | Hardened Electron shell, installer spike          | Not started |
| M5        | Chat UI                                           | Not started |
| M6-M9     | Memory, tools, voice and modes, release hardening | Not started |

## Security rules

- Never commit `.env`, API keys, certificates (`*.pfx`, `*.pem`, `*.key`) or databases.
- Provider keys are entered in the app and stored with Electron `safeStorage`.
