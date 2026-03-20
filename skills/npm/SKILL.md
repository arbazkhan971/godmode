---
name: npm
description: |
  Package management skill. Activates when user needs to manage JavaScript/TypeScript dependencies, compare package managers (npm, yarn, pnpm, bun), manage lock files, configure workspaces and monorepos, publish packages, run security audits, or resolve version conflicts. Triggers on: /godmode:npm, "npm install", "package manager", "lock file", "monorepo workspace", "publish package", "npm audit", "dependency conflict", "version resolution", or when managing project dependencies.
---

# NPM — Package Management

## When to Activate
- User invokes `/godmode:npm`
- User says "npm install", "package manager", "dependency management"
- User says "lock file", "version conflict", "dependency resolution"
- User says "monorepo workspace", "publish package", "npm audit"
- User says "pnpm", "yarn", "bun", "package manager comparison"
- User encounters dependency conflicts or version mismatches
- User needs to set up a monorepo with workspaces
- Pre-ship check identifies dependency vulnerabilities
- Godmode orchestrator detects outdated or vulnerable dependencies

## Workflow

### Step 1: Assess Package Management Context
Understand the project's dependency landscape:

```
PACKAGE MANAGEMENT CONTEXT:
Project:
  Type: <application | library | monorepo | CLI tool>
  Language: <TypeScript | JavaScript | both>
  Runtime: <Node.js | Deno | Bun | browser-only>
  Framework: <React | Next.js | Express | NestJS | etc.>

Package manager:
  Current: <npm | yarn (classic) | yarn (berry) | pnpm | bun>
  Version: <version>
  Lock file: <package-lock.json | yarn.lock | pnpm-lock.yaml | bun.lockb>
  Lock file committed: <yes | no>

Dependencies:
  Production: <N packages>
  Development: <N packages>
  Total (with transitive): <N packages>
  Outdated: <N packages>
  Vulnerable: <N advisories (N critical, N high, N moderate)>
  Duplicate: <N duplicate packages>

Workspace/Monorepo:
  Workspaces: <yes (N packages) | no>
  Tool: <npm workspaces | yarn workspaces | pnpm workspaces | Turborepo | Nx | Lerna>
  Shared dependencies: <hoisted | isolated | both>

Registry:
  Source: <npmjs.com | private registry | GitHub Packages>
  Scoped: <@scope/ prefix | none>
  Publishing: <public | private | not applicable>
```

### Step 2: Package Manager Selection
Choose the right package manager for the project:

```
PACKAGE MANAGER COMPARISON:
┌───────────────┬──────────┬──────────┬──────────┬──────────┐
│ Feature       │ npm      │ yarn     │ pnpm     │ bun      │
├───────────────┼──────────┼──────────┼──────────┼──────────┤
│ Speed         │ Moderate │ Fast     │ Fastest  │ Fastest  │
│ Disk usage    │ High     │ High     │ Low      │ Low      │
│ node_modules  │ Flat     │ Flat/PnP │ Symlinked│ Flat     │
│ Strictness    │ Loose    │ Loose    │ Strict   │ Loose    │
│ Monorepo      │ Basic    │ Good     │ Best     │ Basic    │
│ Lock file     │ JSON     │ YAML     │ YAML     │ Binary   │
│ Ecosystem     │ Default  │ Mature   │ Growing  │ Growing  │
│ Plug'n'Play   │ No       │ Yes      │ No       │ No       │
│ Content-addr. │ No       │ No       │ Yes      │ No       │
│ Maturity      │ Oldest   │ Mature   │ Mature   │ Newest   │
│ Built-in      │ Node.js  │ Corepack │ Corepack │ Bun      │
└───────────────┴──────────┴──────────┴──────────┴──────────┘

RECOMMENDATION MATRIX:
┌─────────────────────────────────┬────────────────────────────┐
│ Scenario                        │ Recommended                │
├─────────────────────────────────┼────────────────────────────┤
│ New project, simple             │ npm (zero setup)           │
│ New project, performance focus  │ pnpm (fast + strict)       │
│ Monorepo                        │ pnpm (best workspace mgmt) │
│ Existing Yarn project           │ Keep yarn (migration cost) │
│ Full-stack with Bun runtime     │ bun (native integration)   │
│ Open source library             │ npm (widest compatibility)  │
│ Enterprise / large team         │ pnpm (strict, disk-efficient)│
│ Rapid prototyping               │ bun (fastest install)      │
└─────────────────────────────────┴────────────────────────────┘

WHY PNPM IS OFTEN THE BEST CHOICE:
  1. Content-addressable storage — each version stored once globally
  2. Strict node_modules — no phantom dependencies
  3. Symlinked structure — faster installs, less disk space
  4. Best monorepo support — workspace protocol, catalogs
  5. Compatible with all npm packages
  6. Growing ecosystem adoption (Vue, Vite, SvelteKit, etc.)

MIGRATION COMMANDS:
  npm to pnpm:   pnpm import    # Converts package-lock.json
  yarn to pnpm:  pnpm import    # Converts yarn.lock
  npm to yarn:   yarn import    # Converts package-lock.json
  npm to bun:    bun install    # Creates bun.lockb from package.json
```

### Step 3: Lock File Management
Handle lock files correctly:

```
LOCK FILE RULES:
┌─────────────────────────────────────────────────────────────┐
│ Rule                                                         │
├─────────────────────────────────────────────────────────────┤
│ 1. ALWAYS commit lock files to version control               │
│ 2. NEVER manually edit lock files                            │
│ 3. Use `ci` commands in CI (npm ci, pnpm install --frozen)   │
│ 4. One package manager per project (never mix lock files)    │
│ 5. Review lock file changes in PRs (they can hide threats)   │
│ 6. Regenerate if corrupted: delete lock + node_modules       │
└─────────────────────────────────────────────────────────────┘

INSTALL COMMANDS:
┌───────────────────┬──────────────────────────────────────────┐
│ Intent            │ Command                                  │
├───────────────────┼──────────────────────────────────────────┤
│ Install from lock │ npm ci                                   │
│ (CI/CD, deploy)   │ pnpm install --frozen-lockfile            │
│                   │ yarn install --frozen-lockfile             │
│                   │ bun install --frozen-lockfile              │
│                   │                                          │
│ Install + update  │ npm install                              │
│ lock (dev only)   │ pnpm install                              │
│                   │ yarn install                              │
│                   │ bun install                               │
│                   │                                          │
│ Add dependency    │ npm install <pkg>                        │
│                   │ pnpm add <pkg>                            │
│                   │ yarn add <pkg>                            │
│                   │ bun add <pkg>                             │
│                   │                                          │
│ Add dev dep       │ npm install -D <pkg>                     │
│                   │ pnpm add -D <pkg>                         │
│                   │ yarn add -D <pkg>                         │
│                   │ bun add -d <pkg>                          │
│                   │                                          │
│ Remove            │ npm uninstall <pkg>                      │
│                   │ pnpm remove <pkg>                         │
│                   │ yarn remove <pkg>                         │
│                   │ bun remove <pkg>                          │
└───────────────────┴──────────────────────────────────────────┘

LOCK FILE CONFLICTS (during merge):
  Option 1: Regenerate (safest)
    rm -rf node_modules package-lock.json
    npm install

  Option 2: Accept theirs and reinstall
    git checkout --theirs package-lock.json
    npm install

  Option 3: Use npm's built-in resolution
    npm install   # Resolves most conflicts automatically

  NEVER try to manually resolve lock file merge conflicts.
```

### Step 4: Workspace and Monorepo Configuration
Set up multi-package repositories:

```
MONOREPO TOOLS COMPARISON:
┌──────────────┬───────────┬───────────┬───────────┬───────────┐
│ Feature      │ npm       │ pnpm      │ Turborepo │ Nx        │
│              │ workspaces│ workspaces│           │           │
├──────────────┼───────────┼───────────┼───────────┼───────────┤
│ Task running │ Basic     │ Basic     │ Advanced  │ Advanced  │
│ Caching      │ No        │ No        │ Local+Rem │ Local+Rem │
│ Dependency   │ Hoisted   │ Strict    │ (uses npm │ (uses npm │
│ management   │           │           │ /pnpm)    │ /pnpm)    │
│ Task graph   │ No        │ No        │ Yes       │ Yes       │
│ Affected cmd │ No        │ --filter  │ Yes       │ Yes       │
│ Generators   │ No        │ No        │ No        │ Yes       │
│ Learning     │ Low       │ Low       │ Medium    │ High      │
│ Overhead     │ None      │ None      │ Small     │ Medium    │
└──────────────┴───────────┴───────────┴───────────┴───────────┘

PNPM WORKSPACE SETUP (recommended):
  # pnpm-workspace.yaml
  packages:
    - "packages/*"
    - "apps/*"

  # Directory structure
  monorepo/
  ├── pnpm-workspace.yaml
  ├── package.json            # Root scripts, shared dev deps
  ├── turbo.json              # Optional: Turborepo config
  ├── apps/
  │   ├── web/                # Next.js frontend
  │   │   └── package.json
  │   └── api/                # Express backend
  │       └── package.json
  └── packages/
      ├── shared/             # Shared utilities
      │   └── package.json
      ├── ui/                 # Shared UI components
      │   └── package.json
      └── config/             # Shared ESLint, TS configs
          └── package.json

WORKSPACE PROTOCOL (internal references):
  # In apps/web/package.json
  {
    "dependencies": {
      "@myorg/shared": "workspace:*",    # Latest from workspace
      "@myorg/ui": "workspace:^1.0.0"    # Semver from workspace
    }
  }

WORKSPACE COMMANDS:
┌─────────────────────────────────┬────────────────────────────┐
│ Action                          │ Command                    │
├─────────────────────────────────┼────────────────────────────┤
│ Install all workspaces          │ pnpm install               │
│ Run script in one package       │ pnpm --filter web dev      │
│ Run script in all packages      │ pnpm -r run build          │
│ Add dep to specific package     │ pnpm --filter api add cors │
│ Add shared dev dep to root      │ pnpm add -Dw eslint        │
│ List all packages               │ pnpm -r list               │
│ Run only affected packages      │ pnpm --filter ...[HEAD~1]  │
│                                 │ run test                   │
└─────────────────────────────────┴────────────────────────────┘

TURBOREPO CONFIGURATION (task orchestration):
  // turbo.json
  {
    "$schema": "https://turbo.build/schema.json",
    "tasks": {
      "build": {
        "dependsOn": ["^build"],      // Build dependencies first
        "outputs": ["dist/**", ".next/**"]
      },
      "test": {
        "dependsOn": ["build"],
        "cache": true
      },
      "lint": {
        "cache": true
      },
      "dev": {
        "persistent": true,
        "cache": false
      }
    }
  }
```

### Step 5: Publishing Packages
Publish libraries to npm or private registries:

```
PUBLISHING CHECKLIST:
┌─────────────────────────────────────────────────────────────┐
│ Step                              │ Status                   │
├───────────────────────────────────┼──────────────────────────┤
│ 1. package.json fields complete   │ name, version, desc,     │
│                                   │ main, types, exports,    │
│                                   │ files, license, repo     │
│ 2. TypeScript declarations        │ .d.ts files generated    │
│ 3. Dual ESM/CJS exports           │ exports field configured │
│ 4. README with usage examples     │ README.md exists         │
│ 5. CHANGELOG updated              │ CHANGELOG.md updated     │
│ 6. Tests passing                  │ All green                │
│ 7. .npmignore or "files" field    │ Only needed files ship   │
│ 8. Version bumped                 │ Follows semver           │
│ 9. Git tag created                │ v<version>               │
│ 10. npm publish --dry-run         │ Verify contents          │
└───────────────────────────────────┴──────────────────────────┘

PACKAGE.JSON FOR PUBLISHING:
  {
    "name": "@myorg/utils",
    "version": "1.2.0",
    "description": "Shared utility functions",
    "type": "module",
    "main": "./dist/index.cjs",
    "module": "./dist/index.mjs",
    "types": "./dist/index.d.ts",
    "exports": {
      ".": {
        "types": "./dist/index.d.ts",
        "import": "./dist/index.mjs",
        "require": "./dist/index.cjs"
      },
      "./package.json": "./package.json"
    },
    "files": [
      "dist",
      "README.md",
      "CHANGELOG.md"
    ],
    "scripts": {
      "build": "tsup src/index.ts --format cjs,esm --dts",
      "prepublishOnly": "npm run build && npm test"
    },
    "publishConfig": {
      "access": "public",
      "registry": "https://registry.npmjs.org/"
    },
    "engines": {
      "node": ">=18"
    },
    "sideEffects": false,
    "license": "MIT",
    "repository": {
      "type": "git",
      "url": "https://github.com/myorg/utils.git"
    },
    "keywords": ["utilities"]
  }

VERSIONING STRATEGY:
┌──────────────┬───────────────────────────────────────────────┐
│ Change Type  │ Version Bump                                  │
├──────────────┼───────────────────────────────────────────────┤
│ Bug fix      │ PATCH: 1.2.0 -> 1.2.1                        │
│ New feature  │ MINOR: 1.2.0 -> 1.3.0                        │
│ Breaking     │ MAJOR: 1.2.0 -> 2.0.0                        │
│ Pre-release  │ 1.3.0-beta.1, 1.3.0-rc.1                     │
└──────────────┴───────────────────────────────────────────────┘

AUTOMATED PUBLISHING (CI):
  # Release workflow:
  npm version patch -m "release: v%s"    # Bump, commit, tag
  git push && git push --tags            # Push to remote
  npm publish                            # Publish to registry

  # Or use changesets for monorepo:
  npx changeset                          # Create changeset
  npx changeset version                  # Bump versions
  npx changeset publish                  # Publish all changed
```

### Step 6: Security Auditing
Scan and fix dependency vulnerabilities:

```
SECURITY AUDIT WORKFLOW:
┌─────────────────────────────────────────────────────────────┐
│ Step                          │ Command                      │
├───────────────────────────────┼──────────────────────────────┤
│ 1. Run audit                  │ npm audit                    │
│                               │ pnpm audit                   │
│                               │ yarn audit                   │
│ 2. See detailed report        │ npm audit --json             │
│ 3. Auto-fix (compatible)      │ npm audit fix                │
│ 4. Force-fix (breaking)       │ npm audit fix --force        │
│ 5. Check specific package     │ npm audit --package <pkg>    │
│ 6. Check for outdated         │ npm outdated                 │
└───────────────────────────────┴──────────────────────────────┘

AUDIT SEVERITY LEVELS:
┌──────────┬───────────────────────────────────────────────────┐
│ Severity │ Action Required                                    │
├──────────┼───────────────────────────────────────────────────┤
│ CRITICAL │ Fix immediately. Block deploy. Patch today.        │
│ HIGH     │ Fix within 24 hours. Block deploy if exploitable. │
│ MODERATE │ Fix within 1 week. Track in issue tracker.        │
│ LOW      │ Fix when convenient. Include in next maintenance.  │
│ INFO     │ Informational. No action required.                │
└──────────┴───────────────────────────────────────────────────┘

WHEN npm audit fix IS NOT ENOUGH:
  1. Check if the vulnerable package is a direct or transitive dependency
     npm ls <vulnerable-package>

  2. If transitive: override the version
     // package.json (npm)
     "overrides": {
       "<vulnerable-package>": ">=<fixed-version>"
     }
     // package.json (pnpm)
     "pnpm": {
       "overrides": {
         "<vulnerable-package>": ">=<fixed-version>"
       }
     }

  3. If no fix available: assess actual risk
     - Is the vulnerability exploitable in your context?
     - Is the affected code path reachable?
     - Document the risk and set a reminder to check for fixes

  4. Consider replacing the dependency
     - Is there an alternative package without vulnerabilities?
     - Can you implement the functionality yourself?

SUPPLY CHAIN SECURITY:
  # Use exact versions for critical dependencies
  npm install --save-exact <pkg>

  # Enable npm provenance (proves package came from CI)
  npm publish --provenance

  # Check package provenance
  npm audit signatures

  # Use Socket.dev for deeper supply chain analysis
  npx socket scan
```

### Step 7: Version Resolution Strategies
Resolve dependency conflicts and version mismatches:

```
VERSION RESOLUTION:
┌─────────────────────────────────────────────────────────────┐
│ Problem                  │ Solution                          │
├──────────────────────────┼───────────────────────────────────┤
│ Conflicting peer deps    │ --legacy-peer-deps or update      │
│                          │ parent package                    │
│ Duplicate packages       │ npm dedupe / pnpm dedupe          │
│ Wrong version installed  │ Check overrides/resolutions       │
│ Phantom dependencies     │ Switch to pnpm (strict mode)      │
│ Version not found        │ Clear cache: npm cache clean      │
│ Build fails after update │ Delete node_modules + lock file,  │
│                          │ reinstall from scratch             │
└──────────────────────────┴───────────────────────────────────┘

PEER DEPENDENCY CONFLICTS:
  # See the conflict
  npm ls <conflicting-package>

  # Option 1: Update the parent package
  npm install <parent-package>@latest

  # Option 2: Override the peer dependency
  "overrides": {
    "<parent-package>": {
      "<peer-dep>": "$<peer-dep>"   # Use root version
    }
  }

  # Option 3: Force install (last resort)
  npm install --legacy-peer-deps

DEDUPLICATION:
  # Check for duplicates
  npm ls --all | grep <package>

  # Deduplicate
  npm dedupe
  pnpm dedupe

  # Visualize dependency tree
  npx npm-why <package>         # Why was this installed?
  npx depcheck                  # Find unused dependencies

DEPENDENCY MAINTENANCE ROUTINE:
  Weekly:
    npm outdated                 # Check for updates
    npm audit                    # Check for vulnerabilities

  Monthly:
    npx npm-check-updates -u     # Update all to latest
    npm test                     # Verify nothing broke
    npx depcheck                 # Remove unused deps

  Quarterly:
    Review major version updates
    Evaluate alternative packages
    Clean up dev dependencies
```

### Step 8: Package Management Report

```
┌────────────────────────────────────────────────────────────┐
│  PACKAGE MANAGEMENT REPORT                                 │
├────────────────────────────────────────────────────────────┤
│  Package manager: <npm | pnpm | yarn | bun>               │
│  Version: <version>                                        │
│  Lock file: <committed | missing>                          │
│                                                            │
│  Dependencies:                                             │
│    Production: <N>                                         │
│    Development: <N>                                        │
│    Total (transitive): <N>                                 │
│                                                            │
│  Health:                                                   │
│    Outdated: <N packages>                                  │
│    Vulnerabilities: <N> (C:<N> H:<N> M:<N> L:<N>)         │
│    Duplicates: <N>                                         │
│    Unused: <N>                                             │
│                                                            │
│  Workspace: <configured | N/A>                             │
│    Packages: <N>                                           │
│    Shared deps: <hoisted | strict>                         │
│                                                            │
│  Actions taken:                                            │
│    - <list of changes>                                     │
│                                                            │
│  Recommendations:                                          │
│    - <list of suggestions>                                 │
│                                                            │
│  Ready for: /godmode:build or /godmode:secure              │
└────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Commit dependency changes: `"deps: <add|update|remove> <package> — <reason>"`
2. Commit workspace config: `"build: configure <pnpm|npm> workspaces — <N> packages"`
3. After package management: "Dependencies configured. Use `/godmode:build` to start coding or `/godmode:secure` for security audit."

## Key Behaviors

1. **Lock files are sacred.** Always commit lock files. Always use `ci`/`--frozen-lockfile` in CI. Never manually edit them. They are the single source of truth for dependency versions.
2. **Choose one package manager.** The whole team uses the same package manager. Mixing npm and yarn creates conflicts, duplicate lock files, and inconsistent installs.
3. **Security auditing is continuous.** Run `npm audit` in CI. Block deploys on CRITICAL/HIGH vulnerabilities. Schedule weekly dependency reviews.
4. **Strict mode prevents phantom dependencies.** pnpm's strict node_modules structure catches imports that work locally but fail in production. Prefer pnpm for new projects.
5. **Workspaces eliminate dependency hell.** In monorepos, use the workspace protocol to reference internal packages. Shared dependencies are managed once, not N times.
6. **Publish deliberately.** Use `npm publish --dry-run` before every real publish. Check the package contents. Set up `prepublishOnly` scripts. Use `files` field to whitelist.
7. **Overrides are temporary.** Dependency overrides (`overrides`/`resolutions`) are patches, not solutions. Set a reminder to remove them when the upstream fix is available.

## Example Usage

### Setting up a pnpm monorepo
```
User: /godmode:npm We have a Next.js frontend, Express API, and shared utils.
      Set up a monorepo.

NPM: Assessing project context...

PACKAGE MANAGEMENT CONTEXT:
Type: monorepo (3 packages)
Packages: web (Next.js), api (Express), shared (utilities)
Current: npm with separate repos

Recommendation: pnpm workspaces + Turborepo

Setting up monorepo...

1. Package manager: pnpm (strict, fast, best monorepo support)
2. Workspace config (pnpm-workspace.yaml):
   - apps/web, apps/api, packages/shared

3. Internal dependencies:
   - apps/web depends on @myorg/shared (workspace:*)
   - apps/api depends on @myorg/shared (workspace:*)

4. Turborepo for task orchestration:
   - build: dependency-aware (shared builds first)
   - test: cached, parallel
   - dev: persistent, no cache

5. Shared configurations:
   - packages/config/eslint for shared ESLint
   - packages/config/tsconfig for shared TypeScript

Structure created. Run: pnpm install && pnpm dev
```

### Resolving a dependency vulnerability
```
User: /godmode:npm npm audit shows 3 critical vulnerabilities. Help!

NPM: Running security audit...

AUDIT RESULTS:
  Critical: 3
  - lodash (prototype pollution) — in express > body-parser
  - node-fetch (redirect bypass) — direct dependency
  - minimatch (ReDoS) — in eslint > glob

REMEDIATION:
  1. node-fetch: Direct dependency
     npm install node-fetch@latest     # Update to fixed version

  2. lodash: Transitive via body-parser
     npm install body-parser@latest    # Parent has fixed dep

  3. minimatch: Transitive via eslint
     "overrides": { "minimatch": ">=3.1.2" }  # Override

  After fixes: 0 critical, 0 high vulnerabilities
  Commit: "security: fix 3 critical dependency vulnerabilities"
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full package management assessment |
| `--audit` | Run security audit with remediation |
| `--outdated` | Check for outdated dependencies |
| `--dedupe` | Find and resolve duplicate packages |
| `--workspace` | Configure monorepo workspaces |
| `--publish` | Prepare and publish a package |
| `--migrate <to>` | Migrate package manager (npm/pnpm/yarn/bun) |
| `--compare` | Compare package managers for this project |
| `--cleanup` | Remove unused dependencies |
| `--lockfix` | Regenerate corrupted lock file |
| `--overrides` | Manage version overrides/resolutions |
| `--ci` | CI-friendly output (exit code 1 on issues) |

## Auto-Detection

```
IF package-lock.json exists:
  DETECT manager = "npm"
  version = parse lockfileVersion from package-lock.json

IF yarn.lock exists:
  DETECT manager = "yarn"
  IF .yarnrc.yml exists: manager = "yarn berry"

IF pnpm-lock.yaml exists:
  DETECT manager = "pnpm"

IF bun.lockb exists:
  DETECT manager = "bun"

IF multiple lock files exist (e.g., package-lock.json AND yarn.lock):
  WARN "Multiple lock files detected! Pick one package manager. Activate /godmode:npm?"

IF node_modules/ does not exist AND lock file exists:
  SUGGEST "Dependencies not installed. Run install with detected manager."

ON git pull/merge with lock file changes:
  SUGGEST "Lock file changed. Run {manager} install to sync."

ON npm audit OR pnpm audit returning critical/high:
  SUGGEST "Security vulnerabilities detected. Activate /godmode:npm --audit?"

IF package.json has no "engines" field AND is a library:
  SUGGEST "Missing engines field in library package.json. Activate /godmode:npm?"
```

## Iterative Dependency Management Protocol

```
WHEN performing a full dependency audit and cleanup:

phases = ["audit_security", "check_outdated", "remove_unused", "deduplicate", "verify_build"]
current_phase = 0
total_phases = len(phases)
changes_made = []

WHILE current_phase < total_phases:
  phase = phases[current_phase]

  IF phase == "audit_security":
    1. RUN {manager} audit
    2. FOR each CRITICAL/HIGH vulnerability:
       - Check if direct or transitive dependency
       - IF direct: update to fixed version
       - IF transitive: update parent OR add override
       - IF no fix available: assess actual exploitability
    3. VERIFY: 0 critical, 0 high vulnerabilities
    changes_made.append(fixes)

  IF phase == "check_outdated":
    1. RUN {manager} outdated
    2. CATEGORIZE: patch updates, minor updates, major updates
    3. APPLY patch updates (safe)
    4. APPLY minor updates (test after)
    5. FLAG major updates for manual review
    changes_made.append(updates)

  IF phase == "remove_unused":
    1. RUN depcheck to find unused dependencies
    2. VERIFY each "unused" dependency isn't used dynamically
    3. REMOVE confirmed unused packages
    changes_made.append(removals)

  IF phase == "deduplicate":
    1. RUN {manager} dedupe
    2. CHECK for duplicate packages in lock file
    3. RESOLVE duplicates via version alignment
    changes_made.append(dedup_results)

  IF phase == "verify_build":
    1. DELETE node_modules and lock file
    2. RUN fresh install
    3. RUN build
    4. RUN tests
    IF build_or_tests_fail:
      ROLLBACK last changes
      REPORT "Build verification failed. Rolling back."

  current_phase += 1
  REPORT "Phase {current_phase}/{total_phases}: {phase} complete"

FINAL:
  REPORT dependency health: vulnerabilities, outdated, unused, duplicates
  REPORT total changes made
```

## Multi-Agent Dispatch

```
WHEN setting up a monorepo with workspace configuration:

DISPATCH parallel agents in worktrees:

  Agent 1 (workspace-structure):
    - Create package directories (apps/, packages/)
    - Configure workspace protocol references
    - Set up pnpm-workspace.yaml or equivalent
    - Output: directory structure + package.json files

  Agent 2 (dependency-audit):
    - Run security audit across all packages
    - Identify outdated dependencies
    - Find and remove unused dependencies
    - Deduplicate shared dependencies
    - Output: audit report + fixed package.json files

  Agent 3 (publish-config):
    - Configure package.json exports (ESM/CJS dual)
    - Set up tsup/unbuild for library builds
    - Configure changesets for versioning
    - Set up prepublishOnly scripts
    - Output: build configs + publish-ready package.json

  Agent 4 (ci-pipeline):
    - Configure Turborepo/Nx task pipeline
    - Set up selective builds in CI
    - Configure remote caching
    - Output: turbo.json + CI workflow

MERGE:
  - Verify workspace references resolve correctly
  - Verify all packages build and test
  - Verify publish dry-run succeeds for public packages
  - Run full audit: 0 critical/high vulnerabilities
```

## HARD RULES

```
1. ALWAYS commit lock files to version control.
   Without a committed lock file, every install produces different versions.

2. ALWAYS use --frozen-lockfile (or npm ci) in CI/CD.
   npm install in CI can update the lock file, causing non-reproducible builds.

3. NEVER mix package managers in one project.
   One lock file, one package manager. Delete the others.

4. NEVER manually edit lock files.
   Let the package manager resolve versions. Manual edits cause corruption.

5. NEVER use * or "latest" as version ranges in package.json.
   Always specify semver ranges. Unbounded versions break builds.

6. NEVER run npm audit fix --force without reviewing each change.
   Force-fixing can jump major versions and introduce breaking changes.

7. ALWAYS run npm publish --dry-run before real publish.
   Verify package contents. npm publish is effectively irreversible.

8. Build tools, test frameworks, and linters MUST be in devDependencies.
   Production deployments should never install dev packages.
```

## Output Format

After each npm skill invocation, emit a structured report:

```
PACKAGE MANAGEMENT REPORT:
┌──────────────────────────────────────────────────────┐
│  Package manager     │  <npm | pnpm | yarn | bun>     │
│  Lock file           │  COMMITTED / MISSING           │
│  Dependencies        │  <N> prod / <N> dev            │
│  Total (transitive)  │  <N>                           │
│  Vulnerabilities     │  C:<N> H:<N> M:<N> L:<N>       │
│  Outdated            │  <N> packages                  │
│  Unused              │  <N> packages                  │
│  Duplicates          │  <N> packages                  │
│  Workspace           │  <N> packages / N/A            │
│  Actions taken       │  <list>                        │
│  Verdict             │  HEALTHY | NEEDS ATTENTION     │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every package management action for tracking:

```
timestamp	skill	action	packages_affected	vulnerabilities_fixed	status
2026-03-20T14:00:00Z	npm	audit_fix	3	3 critical	fixed
2026-03-20T14:10:00Z	npm	deduplicate	8	0	clean
```

## Success Criteria

The npm skill is complete when ALL of the following are true:
1. Lock file is committed to version control
2. CI uses --frozen-lockfile (or npm ci) for reproducible builds
3. Zero critical or high vulnerabilities (npm audit clean)
4. No unused dependencies (verified with depcheck)
5. No duplicate packages in lock file (deduplicated)
6. All packages use semver ranges (no * or latest)
7. Build tools and test frameworks are in devDependencies (not dependencies)
8. One package manager per project (no mixed lock files)

## Error Recovery

```
IF npm audit shows critical vulnerabilities:
  1. Run npm audit to identify the vulnerable packages
  2. For direct dependencies: npm install <pkg>@latest
  3. For transitive dependencies: add overrides in package.json
  4. If no fix available: assess actual exploitability and document the risk

IF lock file merge conflict occurs:
  1. Do NOT manually resolve lock file conflicts
  2. Accept theirs: git checkout --theirs package-lock.json
  3. Run npm install to regenerate the lock file
  4. Commit the resolved lock file

IF phantom dependency is detected (works locally, fails in CI):
  1. Switch to pnpm (strict node_modules prevents phantom deps)
  2. Or: add the missing dependency explicitly to package.json
  3. Verify with a clean install: rm -rf node_modules && npm ci
  4. Test in CI to confirm the fix

IF npm publish fails:
  1. Run npm publish --dry-run first to verify package contents
  2. Check npm auth: npm whoami (must be logged in)
  3. Verify the version number is not already published
  4. Check the files field in package.json (needed files must be included)
```

## Anti-Patterns

- **Do NOT use `npm install` in CI/CD.** Use `npm ci` (or `pnpm install --frozen-lockfile`). `install` can update the lock file, causing non-reproducible builds.
- **Do NOT omit lock files from version control.** Without a committed lock file, every install can produce different dependency versions. This causes "works on my machine" bugs.
- **Do NOT mix package managers.** Having both `package-lock.json` and `yarn.lock` in the same repo means no one knows which one is authoritative. Pick one and delete the others.
- **Do NOT use `npm audit fix --force` blindly.** Force-fixing can introduce breaking changes by jumping major versions. Review each fix individually.
- **Do NOT ignore peer dependency warnings.** Peer dependency conflicts indicate version incompatibilities that will cause runtime errors. Resolve them properly.
- **Do NOT publish without `--dry-run` first.** npm publish is irreversible (within 72 hours with unpublish, but consumers may already depend on it). Always verify contents first.
- **Do NOT install everything as a regular dependency.** Build tools, test frameworks, and linters belong in `devDependencies`. Production images should not include dev packages.
- **Do NOT use `*` or `latest` as version ranges.** Always specify semver ranges. `*` means any version, which will eventually break your build when a breaking change is published.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run npm tasks sequentially: workspace structure, then dependency audit, then publish config.
- Use branch isolation per task: `git checkout -b godmode-npm-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
