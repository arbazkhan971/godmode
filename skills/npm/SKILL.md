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
```

### Step 2: Package Manager Selection
Choose the right package manager for the project:

```
PACKAGE MANAGER COMPARISON:
| Feature | npm | yarn | pnpm | bun |
|---|---|---|---|---|
| Speed | Moderate | Fast | Fastest | Fastest |
| Disk usage | High | High | Low | Low |
| node_modules | Flat | Flat/PnP | Symlinked | Flat |
| Strictness | Loose | Loose | Strict | Loose |
| Monorepo | Basic | Good | Best | Basic |
| Lock file | JSON | YAML | YAML | Binary |
| Ecosystem | Default | Mature | Growing | Growing |
| Plug'n'Play | No | Yes | No | No |
| Content-addr. | No | No | Yes | No |
| Maturity | Oldest | Mature | Mature | Newest |
| Built-in | Node.js | Corepack | Corepack | Bun |
```

### Step 3: Lock File Management
Handle lock files correctly:

```
LOCK FILE RULES:
  Rule
  1. ALWAYS commit lock files to version control
  2. NEVER manually edit lock files
  3. Use `ci` commands in CI (npm ci, pnpm install --frozen)
  4. One package manager per project (never mix lock files)
  5. Review lock file changes in PRs (they can hide threats)
  6. Regenerate if corrupted: delete lock + node_modules

INSTALL COMMANDS:
| Intent | Command |
```

### Step 4: Workspace and Monorepo Configuration
Set up multi-package repositories:

```
MONOREPO TOOLS COMPARISON:
| Feature | npm | pnpm | Turborepo | Nx |
|  | workspaces | workspaces |  |  |
| Task running | Basic | Basic | Advanced | Advanced |
| Caching | No | No | Local+Rem | Local+Rem |
| Dependency | Hoisted | Strict | (uses npm | (uses npm |
| management |  |  | /pnpm) | /pnpm) |
| Task graph | No | No | Yes | Yes |
| Affected cmd | No | --filter | Yes | Yes |
| Generators | No | No | No | Yes |
| Learning | Low | Low | Medium | High |
| Overhead | None | None | Small | Medium |
```

### Step 5: Publishing Packages
Publish libraries to npm or private registries:

```
PUBLISHING CHECKLIST:
| Step | Status |
|---|---|
| 1. package.json fields complete | name, version, desc, |
|  | main, types, exports, |
|  | files, license, repo |
| 2. TypeScript declarations | .d.ts files generated |
| 3. Dual ESM/CJS exports | exports field configured |
| 4. README with usage examples | README.md exists |
| 5. CHANGELOG updated | CHANGELOG.md updated |
| 6. Tests passing | All green |
| 7. .npmignore or "files" field | Only needed files ship |
| 8. Version bumped | Follows semver |
| 9. Git tag created | v<version> |
```

### Step 6: Security Auditing
Scan and fix dependency vulnerabilities:

```
SECURITY AUDIT WORKFLOW:
| Step | Command |
|---|---|
| 1. Run audit | npm audit |
|  | pnpm audit |
|  | yarn audit |
| 2. See detailed report | npm audit --json |
| 3. Auto-fix (compatible) | npm audit fix |
| 4. Force-fix (breaking) | npm audit fix --force |
| 5. Check specific package | npm audit --package <pkg> |
| 6. Check for outdated | npm outdated |

AUDIT SEVERITY LEVELS:
```

### Step 7: Version Resolution Strategies
Resolve dependency conflicts and version mismatches:

```
VERSION RESOLUTION:
| Problem | Solution |
|---|---|
| Conflicting peer deps | --legacy-peer-deps or update |
|  | parent package |
| Duplicate packages | npm dedupe / pnpm dedupe |
| Wrong version installed | Check overrides/resolutions |
| Phantom dependencies | Switch to pnpm (strict mode) |
| Version not found | Clear cache: npm cache clean |
| Build fails after update | Delete node_modules + lock file, |
|  | reinstall from scratch |

PEER DEPENDENCY CONFLICTS:
```

### Step 8: Package Management Report

```
  PACKAGE MANAGEMENT REPORT
  Package manager: <npm | pnpm | yarn | bun>
  Version: <version>
  Lock file: <committed | missing>
  Dependencies:
  Production: <N>
  Development: <N>
  Total (transitive): <N>
  Health:
  Outdated: <N packages>
  Vulnerabilities: <N> (C:<N> H:<N> M:<N> L:<N>)
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

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full package management assessment |
| `--audit` | Run security audit with remediation |
| `--outdated` | Check for outdated dependencies |

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
```

## Iterative Dependency Management Protocol

```
PHASES (run in order):
  1. audit_security: Run audit, fix critical/high (direct: update, transitive: update parent or override)
  2. check_outdated: Run outdated, apply patch (safe), apply minor (test after), flag major for review
  3. remove_unused: Run depcheck, verify not dynamically imported, remove confirmed unused
  4. deduplicate: Run dedupe, resolve version alignment
  5. verify_build: Delete node_modules + lock, fresh install, build, test. Rollback on failure.
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

```

## Output Format

After each npm skill invocation, emit a structured report:

```
PACKAGE MANAGEMENT REPORT:
| Package manager | <npm | pnpm | yarn | bun> |
|---|---|---|---|---|
| Lock file | COMMITTED / MISSING |
| Dependencies | <N> prod / <N> dev |
| Total (transitive) | <N> |
| Vulnerabilities | C:<N> H:<N> M:<N> L:<N> |
| Outdated | <N> packages |
| Unused | <N> packages |
| Duplicates | <N> packages |
| Workspace | <N> packages / N/A |
| Actions taken | <list> |
| Verdict | HEALTHY | NEEDS ATTENTION |
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
```

## Keep/Discard Discipline
```
After EACH dependency change:
  1. MEASURE: Run npm audit, npm test, npm run build.
  2. COMPARE: Are critical/high vulns = 0 AND build passes AND tests pass?
  3. DECIDE:
     - KEEP if audit clean AND build green AND tests pass.
     - DISCARD if new vulnerability introduced OR build fails OR test fails.
  4. COMMIT kept changes. Revert discarded changes before the next fix.

Never keep a version bump that introduces a critical or high vulnerability.
Never keep a dependency override without documenting the reason and a removal date.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Zero critical/high vulnerabilities AND lock file committed AND CI uses frozen install
  - No unused dependencies AND no duplicate packages AND semver ranges on all deps
  - User explicitly requests stop
  - Max iterations (6) reached
```

