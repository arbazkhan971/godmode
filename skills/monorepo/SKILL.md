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
- User wants to "share configuration", "enforce boundaries", "optimize CI"
- Multi-package project has slow CI, tangled dependencies, or inconsistent configs
- Migrating from multi-repo to monorepo (or vice versa)
- New monorepo needs initial structure and tooling

## Workflow

### Step 1: Monorepo Assessment
Evaluate the current monorepo or plan a new one:

```
MONOREPO ASSESSMENT:
┌──────────────────────────────────────────────────────────────┐
│  Repository: <name>                                           │
│  Structure: <monorepo | multi-repo | hybrid>                  │
├──────────────────┬───────────────────────────────────────────┤
│  Packages         │ <N> packages                              │
│  Languages        │ <list>                                    │
│  Build tool       │ <current or none>                         │
│  Package manager  │ <npm | pnpm | yarn | bun>                 │
│  CI time          │ <N min> (full) / <N min> (affected only)  │
│  Boundary issues  │ <N> cross-package violations              │
│  Shared configs   │ <N> duplicated config files               │
│  Circular deps    │ <N> cycles detected                       │
├──────────────────┴───────────────────────────────────────────┤
│  Health: <HEALTHY | NEEDS ATTENTION | CRITICAL>               │
└──────────────────────────────────────────────────────────────┘
```

### Step 2: Tool Selection
Choose the right monorepo tool for the project:

```
MONOREPO TOOL COMPARISON:
┌──────────────┬───────────────────────────────────────────────────────┐
│  Tool         │ Strengths                                             │
├──────────────┼───────────────────────────────────────────────────────┤
│  Turborepo    │ Zero-config caching, simple setup, fast adoption      │
│               │ Best for: JS/TS projects, small-medium monorepos      │
│               │ Caching: Local + remote (Vercel)                      │
│               │ Learning curve: LOW                                   │
├──────────────┼───────────────────────────────────────────────────────┤
│  Nx           │ Rich plugin ecosystem, code generation, dep graph UI  │
│               │ Best for: Enterprise, Angular/React, large monorepos  │
│               │ Caching: Local + Nx Cloud (remote)                    │
│               │ Learning curve: MEDIUM                                │
├──────────────┼───────────────────────────────────────────────────────┤
│  Lerna        │ Publishing workflow, changelog generation              │
│               │ Best for: Library authors, npm package publishing      │
│               │ Caching: Via Nx integration (Lerna 6+)                │
│               │ Learning curve: LOW                                   │
├──────────────┼───────────────────────────────────────────────────────┤
│  Bazel        │ Language-agnostic, hermetic builds, massive scale     │
│               │ Best for: Google-scale, multi-language, 1000+ devs    │
│               │ Caching: Remote execution + remote cache              │
│               │ Learning curve: HIGH                                  │
├──────────────┼───────────────────────────────────────────────────────┤
│  Rush         │ Strict dependency management, phantom dep prevention  │
│               │ Best for: Large JS/TS monorepos with strict policies  │
│               │ Caching: cobuild (distributed)                        │
│               │ Learning curve: MEDIUM-HIGH                           │
├──────────────┼───────────────────────────────────────────────────────┤
│  pnpm          │ Workspace protocol, strict node_modules, fast installs│
│  workspaces   │ Best for: Lightweight, no extra tooling needed        │
│               │ Caching: None built-in (pair with Turbo or Nx)        │
│               │ Learning curve: LOW                                   │
└──────────────┴───────────────────────────────────────────────────────┘
```

#### Selection Decision Tree
```
Is the project multi-language (Go + TypeScript + Python)?
  YES → Bazel (or Nx with custom executors)
  NO → Continue

Does the team need code generation and rich tooling?
  YES → Nx
  NO → Continue

Is the primary goal publishing npm packages?
  YES → Lerna + pnpm workspaces
  NO → Continue

Does the team prefer minimal configuration?
  YES → Turborepo + pnpm workspaces
  NO → Rush (if strict policies needed) or Nx
```

### Step 3: Package Structure
Define the monorepo directory layout:

```
RECOMMENDED STRUCTURE:
<repo>/
├── apps/                    # Deployable applications
│   ├── web/                 # Frontend application
│   │   ├── package.json
│   │   ├── tsconfig.json    # Extends shared config
│   │   └── src/
│   ├── api/                 # Backend API
│   │   ├── package.json
│   │   └── src/
│   └── admin/               # Admin dashboard
│       ├── package.json
│       └── src/
├── packages/                # Shared libraries
│   ├── ui/                  # Shared UI components
│   │   ├── package.json
│   │   └── src/
│   ├── config/              # Shared configuration
│   │   ├── eslint/
│   │   ├── tsconfig/
│   │   └── prettier/
│   ├── utils/               # Shared utilities
│   │   ├── package.json
│   │   └── src/
│   └── types/               # Shared TypeScript types
│       ├── package.json
│       └── src/
├── tools/                   # Build tools, scripts, generators
│   └── generators/
├── package.json             # Root — workspaces, devDependencies
├── pnpm-workspace.yaml      # Workspace definition
├── turbo.json               # Build pipeline (if Turborepo)
├── nx.json                  # Workspace config (if Nx)
└── tsconfig.base.json       # Root TypeScript config
```

#### Package Naming Convention
```
NAMING CONVENTION:
@<org>/<package-name>

Examples:
  @acme/ui          — Shared UI components
  @acme/utils       — Shared utilities
  @acme/config      — Shared configuration
  @acme/types       — Shared TypeScript types
  @acme/web         — Web application (private, not published)
  @acme/api         — API server (private, not published)

Rules:
  - Lowercase, kebab-case
  - Scoped to org (@acme/)
  - apps/ packages: "private": true in package.json
  - packages/ packages: publishable unless purely internal
```

### Step 4: Package Boundary Enforcement
Prevent unauthorized cross-package dependencies:

#### Dependency Rules
```
BOUNDARY RULES:
┌──────────────────────────────────────────────────────────────┐
│  Rule                                    │ Enforcement        │
├──────────────────────────────────────────┼────────────────────┤
│  apps/ can import packages/              │ ALLOWED            │
│  packages/ can import other packages/    │ ALLOWED (if declared)│
│  apps/ CANNOT import other apps/         │ BLOCKED            │
│  packages/ CANNOT import apps/           │ BLOCKED            │
│  No circular dependencies                │ BLOCKED            │
│  tools/ CANNOT be imported at runtime    │ BLOCKED            │
│  All cross-package deps must be explicit │ ENFORCED           │
└──────────────────────────────────────────┴────────────────────┘
```

#### Nx Boundary Enforcement
```json
// nx.json or .eslintrc.json
{
  "rules": {
    "@nx/enforce-module-boundaries": [
      "error",
      {
        "depConstraints": [
          { "sourceTag": "type:app", "onlyDependOnLibsWithTags": ["type:lib", "type:util"] },
          { "sourceTag": "type:lib", "onlyDependOnLibsWithTags": ["type:lib", "type:util"] },
          { "sourceTag": "type:util", "onlyDependOnLibsWithTags": ["type:util"] },
          { "sourceTag": "scope:web", "onlyDependOnLibsWithTags": ["scope:web", "scope:shared"] },
          { "sourceTag": "scope:api", "onlyDependOnLibsWithTags": ["scope:api", "scope:shared"] }
        ],
        "allow": [],
        "enforceBuildableLibDependency": true
      }
    ]
  }
}
```

#### Turborepo Boundary Enforcement
```jsonc
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["^build"]
    },
    "lint": {
      "outputs": []
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "outputs": []
    }
  }
}
```

```typescript
// tools/check-boundaries.ts — Custom boundary checker
import { readFileSync, readdirSync } from 'fs';
import { join } from 'path';

interface Violation {
  source: string;
  target: string;
  rule: string;
}

function checkBoundaries(root: string): Violation[] {
  const violations: Violation[] = [];
  const apps = readdirSync(join(root, 'apps'));
  const packages = readdirSync(join(root, 'packages'));

  for (const app of apps) {
    const pkg = JSON.parse(readFileSync(join(root, 'apps', app, 'package.json'), 'utf-8'));
    for (const dep of Object.keys(pkg.dependencies || {})) {
      // Check if app imports another app
      if (apps.some(a => dep.includes(a) && a !== app)) {
        violations.push({
          source: `apps/${app}`,
          target: dep,
          rule: 'apps/ cannot import other apps/',
        });
      }
    }
  }
  return violations;
}
```

### Step 5: Selective Builds & Testing
Only build and test what changed:

#### Change Detection
```bash
# Turborepo — automatic affected detection
npx turbo run build --filter=...[origin/main]
npx turbo run test --filter=...[HEAD~1]

# Nx — affected commands
npx nx affected --target=build --base=origin/main
npx nx affected --target=test --base=origin/main

# Manual detection with git
git diff --name-only origin/main...HEAD | xargs -I{} dirname {} | sort -u
```

#### CI Configuration for Selective Builds
```yaml
# .github/workflows/ci.yml
name: CI
on:
  pull_request:
    branches: [main]

jobs:
  detect:
    runs-on: ubuntu-latest
    outputs:
      packages: ${{ steps.filter.outputs.changes }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            web:
              - 'apps/web/**'
              - 'packages/ui/**'
              - 'packages/utils/**'
            api:
              - 'apps/api/**'
              - 'packages/utils/**'
              - 'packages/types/**'

  build-web:
    needs: detect
    if: contains(needs.detect.outputs.packages, 'web')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo run build --filter=@acme/web...

  build-api:
    needs: detect
    if: contains(needs.detect.outputs.packages, 'api')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm install --frozen-lockfile
      - run: pnpm turbo run build --filter=@acme/api...
```

#### Remote Caching
```bash
# Turborepo remote caching
npx turbo login
npx turbo link
# Builds now share cache across CI runs and developers

# Nx Cloud
npx nx connect-to-nx-cloud
# Or self-hosted: set NX_CLOUD_AUTH_TOKEN and NX_CLOUD_API
```

### Step 6: Dependency Graph Management
Visualize and maintain the dependency graph:

```bash
# Turborepo — dependency graph
npx turbo run build --graph=dependency-graph.html

# Nx — interactive dependency graph
npx nx graph

# Custom — generate from package.json files
node tools/dep-graph.js > docs/dependency-graph.mmd
```

#### Dependency Graph Health Checks
```
DEPENDENCY GRAPH HEALTH:
┌──────────────────────────────────────────────────────────────┐
│  Total packages: <N>                                          │
│  Total edges: <N>                                             │
│  Max depth: <N> levels                                        │
│  Circular dependencies: <N>                                   │
│  Orphan packages (no dependents): <N>                         │
│  Hub packages (> 5 dependents): <N>                           │
├──────────────────────────────────────────────────────────────┤
│  ISSUES:                                                      │
│  [ ] Circular: @acme/utils <-> @acme/types                    │
│  [ ] Hub risk: @acme/utils has 12 dependents (fragile)        │
│  [ ] Orphan: @acme/legacy-helpers has 0 dependents            │
│  [ ] Deep chain: web -> ui -> theme -> tokens (4 levels)      │
├──────────────────────────────────────────────────────────────┤
│  RECOMMENDATIONS:                                             │
│  1. Break circular dep: extract shared types to @acme/shared  │
│  2. Split @acme/utils into focused packages                   │
│  3. Remove or archive @acme/legacy-helpers                    │
└──────────────────────────────────────────────────────────────┘
```

### Step 7: Shared Configuration Patterns
Eliminate configuration duplication across packages:

#### Shared TypeScript Config
```jsonc
// packages/config/tsconfig/base.json
{
  "$schema": "https://json.schemastore.org/tsconfig",
  "compilerOptions": {
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}

// packages/config/tsconfig/nextjs.json
{
  "extends": "./base.json",
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "module": "esnext",
    "moduleResolution": "bundler",
    "jsx": "preserve",
    "plugins": [{ "name": "next" }]
  }
}

// packages/config/tsconfig/library.json
{
  "extends": "./base.json",
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "outDir": "./dist"
  }
}
```

```jsonc
// apps/web/tsconfig.json — consuming shared config
{
  "extends": "@acme/config/tsconfig/nextjs.json",
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*.ts", "src/**/*.tsx"],
  "exclude": ["node_modules"]
}
```

#### Shared ESLint Config
```javascript
// packages/config/eslint/base.js
module.exports = {
  extends: ['eslint:recommended', 'prettier'],
  env: { node: true, es2022: true },
  parserOptions: { ecmaVersion: 'latest', sourceType: 'module' },
  rules: {
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
  },
};

// packages/config/eslint/react.js
module.exports = {
  extends: ['./base.js', 'plugin:react/recommended', 'plugin:react-hooks/recommended'],
  settings: { react: { version: 'detect' } },
  rules: {
    'react/prop-types': 'off', // Using TypeScript
    'react/react-in-jsx-scope': 'off', // React 17+
  },
};
```

#### Root package.json Scripts
```jsonc
// package.json (root)
{
  "private": true,
  "workspaces": ["apps/*", "packages/*"],
  "scripts": {
    "build": "turbo run build",
    "test": "turbo run test",
    "lint": "turbo run lint",
    "typecheck": "turbo run typecheck",
    "clean": "turbo run clean && rm -rf node_modules",
    "format": "prettier --write \"**/*.{ts,tsx,js,json,md}\"",
    "check-boundaries": "node tools/check-boundaries.js",
    "graph": "turbo run build --graph=docs/dep-graph.html"
  },
  "devDependencies": {
    "turbo": "^2.0.0",
    "prettier": "^3.0.0"
  }
}
```

### Step 8: Commit and Transition
1. Commit monorepo config: `"monorepo: <project> — initialize <tool> with <N> packages"`
2. Commit boundary rules: `"monorepo: <project> — enforce package boundaries"`
3. Commit CI pipeline: `"monorepo: <project> — selective builds and remote caching"`
4. Commit shared configs: `"monorepo: <project> — shared tsconfig, eslint, prettier"`

## Key Behaviors

1. **Choose the right tool for the scale.** Turborepo for simplicity, Nx for features, Bazel for massive scale. Do not use Bazel for a 5-package monorepo.
2. **Enforce boundaries from day one.** Letting packages import anything from anywhere creates an untangleable mess. Set rules before writing code.
3. **Build only what changed.** Full rebuilds in CI are the #1 monorepo pain point. Selective builds are not optional.
4. **Remote caching is transformative.** A 15-minute CI build that hits cache drops to 30 seconds. Configure remote caching early.
5. **Shared configs reduce drift.** Every duplicated tsconfig.json or .eslintrc is a potential inconsistency. Centralize and extend.
6. **The dependency graph is your map.** Visualize it regularly. If it looks like spaghetti, the architecture needs work.

## Example Usage

### Setting up a new Turborepo monorepo
```
User: /godmode:monorepo Set up a monorepo for our web app, API, and shared component library

Monorepo: Analyzing project requirements...

RECOMMENDATION: Turborepo + pnpm workspaces
Reason: 3 packages, TypeScript-only, team prefers minimal config

STRUCTURE:
  apps/web       — Next.js frontend
  apps/api       — Express API
  packages/ui    — Shared React components
  packages/utils — Shared utilities
  packages/types — Shared TypeScript types
  packages/config — Shared tsconfig, eslint, prettier

SETUP:
1. Initialized pnpm workspace with 6 packages
2. Configured turbo.json pipeline (build -> test -> lint)
3. Set up shared TypeScript, ESLint, and Prettier configs
4. Created boundary check script
5. Added CI with selective builds and remote caching

CI IMPACT:
  Full build: 4.2 min
  Affected only (typical PR): 1.1 min
  With remote cache hit: 0.3 min
```

### Optimizing an existing monorepo
```
User: /godmode:monorepo Our CI takes 25 minutes and developers are frustrated

Monorepo: Auditing current monorepo...

ASSESSMENT:
  Packages: 23
  Tool: npm workspaces (no build orchestrator)
  CI time: 24.7 min (builds everything, no caching)
  Boundary violations: 7 (apps importing other apps)
  Shared configs: 0 (23 duplicated tsconfig.json files)
  Circular deps: 2 cycles

IMPROVEMENT PLAN:
1. Add Turborepo for task orchestration and caching
2. Fix 7 boundary violations
3. Break 2 circular dependency cycles
4. Centralize 23 tsconfig.json files into shared config
5. Enable remote caching

RESULT:
  CI time: 24.7 min → 3.2 min (affected only) / 0.8 min (cache hit)
  Boundary violations: 7 → 0
  Circular deps: 2 → 0
  Config duplication: 23 files → 3 shared + 23 extending
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full monorepo assessment and optimization |
| `--init <tool>` | Initialize new monorepo (turborepo, nx, lerna, rush) |
| `--audit` | Audit existing monorepo health |
| `--boundaries` | Check and enforce package boundaries |
| `--graph` | Generate dependency graph visualization |
| `--selective` | Configure selective builds and testing |
| `--cache` | Set up remote caching |
| `--shared-config` | Create shared configuration packages |
| `--migrate` | Migrate from multi-repo to monorepo |
| `--ci` | Generate CI configuration for monorepo |

## Auto-Detection

```
IF pnpm-workspace.yaml exists:
  packages = parse workspace packages
  DETECT tool = "pnpm workspaces"
  SUGGEST "pnpm monorepo detected ({len(packages)} packages). Activate /godmode:monorepo?"

IF turbo.json exists:
  DETECT tool = "Turborepo"
  SUGGEST "Turborepo monorepo detected. Activate /godmode:monorepo?"

IF nx.json exists:
  DETECT tool = "Nx"
  SUGGEST "Nx monorepo detected. Activate /godmode:monorepo?"

IF lerna.json exists:
  DETECT tool = "Lerna"
  SUGGEST "Lerna monorepo detected. Activate /godmode:monorepo?"

IF package.json has "workspaces" field:
  packages = parse workspaces glob
  IF len(packages) > 1:
    SUGGEST "npm/yarn workspaces detected ({len(packages)} packages). Activate /godmode:monorepo?"

IF apps/ AND packages/ directories exist:
  SUGGEST "Monorepo directory structure detected. Activate /godmode:monorepo?"

IF multiple package.json files exist at depth 2+:
  count = count_package_jsons()
  IF count > 3:
    SUGGEST "Multi-package project detected ({count} package.json files). Activate /godmode:monorepo?"
```

## Iterative Monorepo Health Protocol

```
WHEN auditing or improving an existing monorepo:

current_check = 0
checks = [
  "circular_dependencies",
  "boundary_violations",
  "config_duplication",
  "orphan_packages",
  "hub_package_risk",
  "ci_optimization",
  "cache_configuration"
]
total_checks = len(checks)
issues_found = []
fixes_applied = []

WHILE current_check < total_checks:
  check = checks[current_check]

  1. RUN diagnostic for {check}
  2. IF issues detected:
       issues_found.append({check: check, count: issue_count, details: details})
       3. GENERATE fix for each issue
       4. APPLY fix
       5. VERIFY fix resolved the issue
       fixes_applied.append({check: check, fix: fix_description})

  current_check += 1
  REPORT "Audit progress: {current_check}/{total_checks} checks complete"

FINAL:
  REPORT "Issues found: {len(issues_found)}, Fixes applied: {len(fixes_applied)}"
  MEASURE CI time improvement: before vs after
  GENERATE dependency graph visualization
```

## Multi-Agent Dispatch

```
WHEN setting up or restructuring a monorepo with many packages:

DISPATCH parallel agents in worktrees:

  Agent 1 (structure):
    - Design package directory layout
    - Create package.json for each package
    - Configure workspace references
    - Output: directory structure + package.json files

  Agent 2 (shared-config):
    - Create shared TypeScript config (base, nextjs, library)
    - Create shared ESLint config (base, react)
    - Create shared Prettier config
    - Output: packages/config/ with all shared configs

  Agent 3 (ci-pipeline):
    - Configure selective builds (affected-only)
    - Set up remote caching (Turborepo/Nx Cloud)
    - Create CI workflow with path-based triggers
    - Output: .github/workflows/ + turbo.json/nx.json

  Agent 4 (boundary-enforcement):
    - Create boundary check script
    - Configure lint rules for module boundaries
    - Scan for and fix existing violations
    - Output: tools/check-boundaries.ts + lint config

MERGE:
  - Verify shared configs are correctly extended by all packages
  - Verify CI pipeline detects changes in all packages
  - Verify boundary rules are consistent with package structure
  - Run full build to validate everything works together
```

## HARD RULES

```
1. NEVER use a monorepo without a build orchestrator (Turborepo, Nx, Bazel).
   Running sequential builds across 20 packages is not a monorepo strategy.

2. EVERY package MUST declare its dependencies explicitly.
   No phantom dependencies. Use pnpm strict mode.

3. NEVER allow circular dependencies between packages.
   If A imports B and B imports A, extract shared code into C.

4. apps/ packages MUST NOT import other apps/ packages.
   Only packages/ can be shared. Apps are deployment boundaries.

5. ALWAYS commit the lock file. Use --frozen-lockfile in CI.
   Non-reproducible installs cause "works on my machine" bugs.

6. EVERY PR MUST only build and test affected packages.
   Full rebuilds on every PR defeat the purpose of a monorepo.

7. Shared configuration (tsconfig, eslint, prettier) MUST be centralized
   in a packages/config/ package. No duplicated config files.

8. NEVER hoist all dependencies to root. Hoisting causes phantom
   dependency problems. Use strict node_modules (pnpm default).
```

## Anti-Patterns

- **Do NOT use a monorepo without a build orchestrator.** Running `npm run build` in 20 packages sequentially is not a monorepo strategy. Use Turborepo, Nx, or Bazel.
- **Do NOT skip boundary enforcement.** Without boundaries, every package eventually imports every other package, creating a distributed monolith.
- **Do NOT rebuild everything on every PR.** Selective builds are the entire point of a monorepo build tool. Configure them.
- **Do NOT duplicate configuration.** 20 identical tsconfig.json files means 20 files that will drift apart. Centralize and extend.
- **Do NOT create circular dependencies.** If package A imports package B and package B imports package A, extract the shared code into package C.
- **Do NOT use a monorepo just because it's trendy.** If your services are truly independent with different teams, deployment schedules, and languages, separate repos might be simpler.
- **Do NOT ignore the dependency graph.** A monorepo without a clear dependency graph is just a directory full of code. Visualize it, maintain it, enforce it.
- **Do NOT hoist all dependencies to root.** Hoisting causes phantom dependency problems where packages use dependencies they didn't declare. Use strict mode (pnpm default).


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run monorepo tasks sequentially: structure, then shared config, then CI pipeline.
- Use branch isolation per task: `git checkout -b godmode-monorepo-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
