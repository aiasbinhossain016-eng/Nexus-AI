# ADR 0002: Tooling baseline and the TypeScript exception

Status: Accepted (24 Oct 2026)

## Versions checked against the npm and PyPI registries on 24 Oct 2026

| Tool                 | Version               |
| -------------------- | --------------------- |
| Electron             | 45.0.0 (`latest` tag) |
| Vite                 | 8.3.5                 |
| React                | 19.3.1                |
| Vitest               | 5.0.5                 |
| ESLint               | 10.13.0               |
| typescript-eslint    | 8.72.0                |
| Prettier             | 3.9.10                |
| electron-vite        | 6.0.0                 |
| electron-builder     | 26.15.3               |
| @vitejs/plugin-react | 6.1.2                 |

Python tools (resolved by `uv` and recorded in `backend/uv.lock`): ruff, pytest,
pytest-asyncio, pyright. Backend runtime libraries are added in milestone M2.

## Exception: TypeScript 6.0.x instead of 7.x

The newest TypeScript is 7.0.2, but typescript-eslint 8.72.0 declares the peer range
`typescript >=4.8.4 <6.1.0`. Type-aware linting is a main safety net for the Electron
security rules, so the project uses TypeScript **6.0.3** (newest 6.0.x).

Exit condition: move to TypeScript 7 as soon as typescript-eslint declares support for it.

## Node.js

Node 24 LTS for tooling and CI. Node 26 becomes LTS on 28 Oct 2026; revisit after the
Electron 45 embedded Node version is confirmed in milestone M4.
