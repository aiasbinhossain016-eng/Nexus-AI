#!/usr/bin/env node
// Verifies that the repository skeleton is intact and follows the agreed rules.
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const problems = [];
const fail = (message) => problems.push(message);
const read = (relativePath) => readFileSync(join(root, relativePath), "utf8");

const requiredFiles = [
  ".gitignore",
  ".gitattributes",
  ".editorconfig",
  ".npmrc",
  ".node-version",
  ".env.example",
  "package.json",
  "README.md",
  "backend/pyproject.toml",
  "backend/.python-version",
  "docs/adr/0001-windows-first-architecture.md",
  "docs/adr/0002-tooling-baseline.md",
  ".prettierrc.json",
  "tsconfig.base.json",
  "eslint.config.mjs",
  "vitest.config.mjs",
  ".github/workflows/ci.yml",
];
for (const file of requiredFiles) {
  if (!existsSync(join(root, file))) fail(`Missing file: ${file}`);
}

const requiredDirs = [
  "apps/desktop",
  "packages/api-contracts",
  "backend/app",
  "backend/tests",
  "docs/adr",
  "scripts",
];
for (const dir of requiredDirs) {
  const full = join(root, dir);
  if (!existsSync(full) || !statSync(full).isDirectory()) fail(`Missing directory: ${dir}`);
}

// .gitignore must protect secrets and local data.
if (existsSync(join(root, ".gitignore"))) {
  const lines = new Set(
    read(".gitignore")
      .split(/\r?\n/)
      .map((line) => line.trim()),
  );
  for (const entry of [
    ".env",
    ".env.*",
    "!.env.example",
    "node_modules/",
    ".venv/",
    "*.pfx",
    "*.pem",
    "*.key",
    "*.sqlite3",
    "*.db",
  ]) {
    if (!lines.has(entry)) fail(`.gitignore is missing the entry: ${entry}`);
  }
}

// .env.example must never contain something that looks like a real secret.
if (existsSync(join(root, ".env.example"))) {
  const secretLike = /(sk-[A-Za-z0-9]|AIza[0-9A-Za-z_-]{10}|api[_-]?key\s*=\s*\S+)/i;
  if (secretLike.test(read(".env.example")))
    fail(".env.example appears to contain a secret or API key.");
}

// Workspace packages: private, scoped, and exact dependency versions only.
const exactVersion = /^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$/;
const dependencyFields = [
  "dependencies",
  "devDependencies",
  "optionalDependencies",
  "peerDependencies",
];

function checkPackage(relativePath, { scoped }) {
  let pkg;
  try {
    pkg = JSON.parse(read(relativePath));
  } catch (error) {
    fail(`${relativePath} is not valid JSON: ${error.message}`);
    return;
  }
  if (pkg.private !== true) fail(`${relativePath} must set "private": true`);
  if (scoped && !String(pkg.name ?? "").startsWith("@nexus/"))
    fail(`${relativePath} name must start with @nexus/`);
  for (const field of dependencyFields) {
    for (const [name, spec] of Object.entries(pkg[field] ?? {})) {
      if (name.startsWith("@nexus/")) continue; // local workspace link
      if (!exactVersion.test(spec))
        fail(`${relativePath}: ${field}.${name} must be an exact version, found "${spec}"`);
    }
  }
  return pkg;
}

if (existsSync(join(root, "package.json"))) {
  const rootPkg = checkPackage("package.json", { scoped: false });
  for (const pattern of rootPkg?.workspaces ?? []) {
    if (!pattern.endsWith("/*")) {
      fail(`Unsupported workspace pattern: ${pattern}`);
      continue;
    }
    const base = pattern.slice(0, -2);
    const baseDir = join(root, base);
    if (!existsSync(baseDir)) continue;
    for (const entry of readdirSync(baseDir)) {
      const relative = `${base}/${entry}/package.json`;
      if (statSync(join(baseDir, entry)).isDirectory()) {
        if (existsSync(join(root, relative))) checkPackage(relative, { scoped: true });
        else fail(`Workspace folder ${base}/${entry} has no package.json`);
      }
    }
  }
}

// Backend manifest basics (full TOML validation happens in uv).
if (existsSync(join(root, "backend/pyproject.toml"))) {
  const toml = read("backend/pyproject.toml");
  if (!/^requires-python\s*=/m.test(toml))
    fail("backend/pyproject.toml is missing requires-python");
  if (!/^dependencies\s*=/m.test(toml))
    fail("backend/pyproject.toml is missing a dependencies list");
}

if (problems.length > 0) {
  console.error(
    `Structure check FAILED (${problems.length} problem${problems.length === 1 ? "" : "s"}):`,
  );
  for (const problem of problems) console.error(`  - ${problem}`);
  process.exit(1);
}
console.log("Structure check passed.");
