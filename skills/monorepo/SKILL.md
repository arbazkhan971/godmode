---
name: monorepo
description: |
  Monorepo management skill. Activates when the user needs to set up, configure, or optimize a monorepo architecture. Covers tool selection and configuration (Turborepo, Nx, Lerna, Bazel, Rush), package boundary enforcement, selective builds and testing, dependency graph management, shared configuration patterns, and workspace optimization. Every recommendation considers CI/CD impact and developer experience. Triggers on: /godmode:monorepo, "monorepo", "workspace", "package boundary", "selective build", "dependency graph", "shared config", or when multi-package projects need structural improvement.
---

# Monorepo — Monorepo Architecture & Management

## When to Activate
- User invokes `/godmode:monorepo`
- User says "monorepo", "workspace setup", "manage packages"
- User asks about "selective builds", "dependency graph", "package boundaries"
- Multi-package project has slow CI, tangled deps, or inconsistent configs
- Migrating from multi-repo to monorepo (or vice versa)

## Workflow

### Step 1: Assessment
```
MONOREPO ASSESSMENT:
Repository: <name>, Structure: <monorepo|multi-repo|hybrid>
Packages: <N>, Languages: <list>, Build tool: <current|none>
Package manager: <npm|pnpm|yarn|bun>
CI time: <N min> (full) / <N min> (affected only)
Boundary violations: <N>, Shared configs: <N> duplicated, Circular deps: <N>
Health: HEALTHY | NEEDS ATTENTION | CRITICAL
```

### Step 2: Tool Selection

```
TOOL COMPARISON:
  Turborepo: Zero-config caching, simple setup. Best for JS/TS, small-medium. Learning: LOW.
  Nx: Rich plugins, code generation, dep graph UI. Best for enterprise, large. Learning: MEDIUM.
  Lerna: Publishing workflow, changelogs. Best for npm package authors. Learning: LOW.
  Bazel: Language-agnostic, hermetic. Best for Google-scale, multi-language. Learning: HIGH.
  Rush: Strict dep management, phantom dep prevention. Best for strict policies. Learning: MEDIUM-HIGH.
  pnpm workspaces: Lightweight, no extra tooling. Pair with Turbo or Nx for caching. Learning: LOW.

DECISION TREE:
  Multi-language? → Bazel (or Nx custom executors)
  Need codegen + rich tooling? → Nx
  Publishing npm packages? → Lerna + pnpm workspaces
  Prefer minimal config? → Turborepo + pnpm workspaces
  Strict policies needed? → Rush
```

### Step 3: Package Structure

```
<repo>/
├── apps/          # Deployable applications (web, api, admin)
├── packages/      # Shared libraries (ui, config, utils, types)
├── tools/         # Build tools, scripts, generators
├── package.json   # Root workspaces + devDependencies
├── pnpm-workspace.yaml / turbo.json / nx.json
└── tsconfig.base.json

NAMING: @<org>/<package-name>, lowercase kebab-case, scoped.
Apps: "private": true. Packages: publishable unless purely internal.
```

### Step 4: Boundary Enforcement

```
RULES:
  apps/ can import packages/ — ALLOWED
  packages/ can import other packages/ — ALLOWED (if declared)
  apps/ CANNOT import other apps/ — BLOCKED
  packages/ CANNOT import apps/ — BLOCKED
  No circular dependencies — BLOCKED
  Declare all cross-package deps explicitly — ENFORCED

ENFORCEMENT:
  Nx: @nx/enforce-module-boundaries with sourceTag/onlyDependOnLibsWithTags
  Turborepo: turbo.json pipeline with dependsOn: ["^build"] + custom boundary checker script
```

### Step 5: Selective Builds & Caching

```
AFFECTED DETECTION:
  Turborepo: npx turbo run build --filter=...[origin/main]
  Nx: npx nx affected --target=build --base=origin/main

CI: Use path-based triggers (dorny/paths-filter) to run only affected package builds.

REMOTE CACHING:
  Turborepo: npx turbo login + npx turbo link (Vercel)
  Nx: npx nx connect-to-nx-cloud
  Impact: 15-min build → 30 seconds with cache hit
```

### Step 6: Dependency Graph Health

```
VISUALIZE: turbo run build --graph or npx nx graph

HEALTH CHECKS:
  Circular dependencies → extract shared code into new package
  Hub packages (>5 dependents) → split into focused packages
  Orphan packages (0 dependents) → remove or archive
  Deep chains (4+ levels) → flatten where possible
```

### Step 7: Shared Configuration

Centralize in `packages/config/`:
- **TypeScript**: base.json (strict, declarations), nextjs.json (extends base), library.json (extends base)
- **ESLint**: base.js (recommended+prettier), react.js (extends base+react)
- **Prettier**: shared config

All packages extend: `"extends": "@acme/config/tsconfig/base.json"`

Root scripts: `build`, `test`, `lint`, `typecheck`, `clean`, `format`, `check-boundaries`, `graph`.

### Step 8: Commit
```
"monorepo: <project> — initialize <tool> with <N> packages"
"monorepo: <project> — enforce package boundaries"
"monorepo: <project> — selective builds and remote caching"
"monorepo: <project> — shared tsconfig, eslint, prettier"
```

## Key Behaviors

1. **Choose the right tool for scale.** Turborepo for simplicity, Nx for features, Bazel for massive scale.
2. **Enforce boundaries from day one.** Unrestricted imports create untangleable messes.
3. **Build only what changed.** Full rebuilds are the #1 monorepo pain point.
4. **Remote caching is transformative.** 15-min → 30 seconds.
5. **Shared configs reduce drift.** Centralize and extend.
6. **Visualize the dependency graph regularly.** Spaghetti = architecture problem.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full assessment and optimization |
| `--init <tool>` | Initialize new monorepo |
| `--audit` | Audit existing health |
| `--boundaries` | Check/enforce boundaries |
| `--graph` | Dependency graph visualization |
| `--selective` | Configure selective builds |
| `--cache` | Set up remote caching |
| `--shared-config` | Create shared configs |
| `--migrate` | Multi-repo to monorepo |
| `--ci` | Generate CI configuration |

## Auto-Detection
```
Detect: pnpm-workspace.yaml, turbo.json, nx.json, lerna.json, package.json workspaces,
apps/+packages/ directories, multiple package.json files at depth 2+.
```

## HARD RULES

1. NEVER use a monorepo without a build orchestrator.
2. EVERY package MUST declare explicit dependencies. No phantom deps. Use pnpm strict.
3. NEVER allow circular dependencies.
4. apps/ MUST NOT import other apps/.
5. ALWAYS commit lock file. Use --frozen-lockfile in CI.
6. EVERY PR: only build/test affected packages.
7. CENTRALIZE shared config in packages/config/.
8. NEVER hoist all deps to root. Causes phantom dependency problems.

## Iterative Health Protocol
```
CHECKS: circular_deps → boundary_violations → config_duplication → orphan_packages →
  hub_package_risk → ci_optimization → cache_configuration
FOR EACH: diagnose, generate fix, apply, verify.
POST: Report issues found/fixed, measure CI time improvement, generate dep graph.
```

## Multi-Agent Dispatch
```
Agent 1 (structure): Package layout, package.json files, workspace refs
Agent 2 (shared-config): TypeScript, ESLint, Prettier configs
Agent 3 (ci-pipeline): Selective builds, remote caching, CI workflows
Agent 4 (boundary-enforcement): Boundary checker, lint rules, fix violations
MERGE: Verify configs extend correctly, CI detects all packages, boundaries consistent.
```

## Output Format
```
MONOREPO REPORT:
Repository: <name>, Tool: <name>, Package manager: <name>
Packages: <N> (apps: <N>, libs: <N>)
Boundary violations: <N>/<N> fixed, Circular deps: <N>/<N> fixed
CI time: <full> / <affected> / <cached>
Remote caching: ENABLED | NOT CONFIGURED
Verdict: HEALTHY | NEEDS ATTENTION
```

## TSV Logging
Append to `.godmode/monorepo-results.tsv`: `timestamp	skill	action	packages	boundary_violations	ci_time_min	status`

## Success Criteria
1. Build orchestrator configured. 2. Zero boundary violations. 3. Zero circular deps. 4. Shared configs centralized. 5. CI uses selective builds. 6. Remote caching configured. 7. Lock file committed + --frozen-lockfile in CI. 8. All packages have explicit deps.

## Error Recovery
```
Circular dep → extract shared into new package C. Update A and B to import C.
CI too slow → verify selective builds, check cache hit rate, split large packages.
Boundary violation → extract shared code to packages/ library, add lint rule.
New package fails → verify workspace config, package.json name/scope, run install.
```

## Keep/Discard Discipline
```
KEEP if build passes AND boundary violations = 0 AND circular deps = 0.
DISCARD if build fails OR new violation OR new circular dep.
```

## Stop Conditions
```
STOP when: orchestrator configured AND zero violations AND zero circular deps AND remote caching
  AND shared configs AND selective builds AND CI affected-only < 3 min
  OR user requests stop OR max 10 iterations
```

## Platform Fallback
Run sequentially if `Agent()` unavailable. Branch per task. See `adapters/shared/sequential-dispatch.md`.
