---
name: monorepo
description: Monorepo architecture and management --
  Turborepo, Nx, Lerna, Bazel, boundaries, caching.
---

## Activate When
- `/godmode:monorepo`, "monorepo", "workspace setup"
- "selective builds", "dependency graph", "boundaries"
- Multi-package project with slow CI or tangled deps

## Workflow

### 1. Assessment
```bash
ls turbo.json nx.json lerna.json \
  pnpm-workspace.yaml 2>/dev/null
find . -name "package.json" -maxdepth 3 | wc -l
```
```
Packages: <N> | Languages: <list>
Build tool: <current|none>
Package manager: <npm|pnpm|yarn|bun>
CI time: <N min> full / <N min> affected
Boundary violations: <N> | Circular deps: <N>
```

### 2. Tool Selection
```
Turborepo: zero-config caching, simple. JS/TS.
  Learning: LOW.
Nx: rich plugins, codegen, dep graph UI.
  Enterprise, large. Learning: MEDIUM.
Lerna: publishing workflow, changelogs.
  npm package authors. Learning: LOW.
Bazel: language-agnostic, hermetic.
  Google-scale. Learning: HIGH.
Rush: strict dep management, phantom prevention.
  Learning: MEDIUM-HIGH.
```
IF multi-language: Bazel or Nx custom executors.
IF prefer minimal config: Turborepo + pnpm.
IF publishing npm packages: Lerna + pnpm.

### 3. Package Structure
```
<repo>/
  apps/       # Deployable applications
  packages/   # Shared libraries
  tools/      # Build tools, scripts
  package.json, turbo.json/nx.json
```
Naming: `@<org>/<package>`, lowercase kebab-case.
Apps: `"private": true`. Packages: publishable.

### 4. Boundary Enforcement
- apps/ can import packages/ (ALLOWED)
- packages/ can import packages/ if declared
- apps/ CANNOT import other apps/ (BLOCKED)
- packages/ CANNOT import apps/ (BLOCKED)
- No circular dependencies (BLOCKED)

### 5. Selective Builds & Caching
```bash
npx turbo run build --filter=...[origin/main]
npx nx affected --target=build --base=origin/main
```
Remote caching: Turborepo (Vercel) or Nx Cloud.
Impact: 15-min build -> 30 seconds with cache hit.

### 6. Dependency Graph Health
Visualize: `turbo run build --graph` or `npx nx graph`.
Fix: circular deps -> extract shared package.
Hub packages (>5 dependents) -> split.
Orphan packages (0 dependents) -> remove.
Deep chains (4+ levels) -> flatten.

### 7. Shared Configuration
Centralize in `packages/config/`: TypeScript base,
ESLint, Prettier. All packages extend shared config.

## Quality Targets
- Target: <30s affected-package detection
- Target: <120s incremental build for changed packages
- Target: >80% cache hit rate across CI runs

## Hard Rules
1. NEVER monorepo without build orchestrator.
2. EVERY package: explicit dependencies, no phantom.
3. NEVER allow circular dependencies.
4. apps/ MUST NOT import other apps/.
5. ALWAYS commit lock file. --frozen-lockfile in CI.
6. EVERY PR: build/test affected packages only.
7. CENTRALIZE shared config in packages/config/.
8. NEVER hoist all deps to root.

## TSV Logging
Append `.godmode/monorepo-results.tsv`:
```
timestamp	action	packages	boundary_violations	ci_time_min	status
```

## Keep/Discard
```
KEEP if: build passes AND violations = 0
  AND circular deps = 0.
DISCARD if: build fails OR new violation
  OR new circular dep.
```

## Stop Conditions
```
STOP when ALL of:
  - Orchestrator configured
  - Zero violations and circular deps
  - Remote caching enabled
  - Selective builds in CI
  - Affected-only CI < 3 min
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Circular dep | Extract shared into new package |
| CI too slow | Verify selective builds, check cache |
| Boundary violation | Extract to packages/ library |
| New package fails | Verify workspace config, install |
