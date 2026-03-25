---
name: npm
description: Package management (npm/yarn/pnpm/bun).
---

## Activate When
- `/godmode:npm`, "npm install", "package manager"
- "lock file", "version conflict", "dependency resolution"
- "monorepo workspace", "publish package", "npm audit"

## Workflow

### 1. Assess Context
```bash
# Detect package manager
ls package-lock.json yarn.lock pnpm-lock.yaml \
  bun.lockb 2>/dev/null
# Count dependencies
cat package.json | grep -c '":'
```
```
Type: application|library|monorepo|CLI
Manager: npm|yarn|yarn berry|pnpm|bun
Lock file: committed|missing
Deps: <N> prod, <N> dev, <N> total transitive
```

### 2. Package Manager Selection
```
| Feature | npm | yarn | pnpm | bun |
| Speed | Moderate | Fast | Fastest | Fastest |
| Disk | High | High | Low | Low |
| Strictness | Loose | Loose | Strict | Loose |
| Monorepo | Basic | Good | Best | Basic |
```
IF new project: prefer pnpm (strict, fast, disk-efficient).
IF existing project: keep current unless pain points.
IF monorepo: pnpm workspaces + Turborepo.

### 3. Lock File Rules
```
1. ALWAYS commit lock files to version control
2. NEVER manually edit lock files
3. Use `ci` commands in CI (npm ci, pnpm --frozen)
4. One package manager per project
5. Review lock file changes in PRs
6. Regenerate if corrupted: delete lock + node_modules
```
IF multiple lock files found: delete all but one,
  standardize on single manager.

### 4. Workspace Configuration
```
| Tool | Task | Cache | Affected |
| npm workspaces | Basic | No | No |
| pnpm workspaces | Basic | No | --filter |
| Turborepo | Advanced | Local+Remote | Yes |
| Nx | Advanced | Local+Remote | Yes |
```
IF < 5 packages: pnpm workspaces sufficient.
IF > 5 packages: add Turborepo for caching.

### 5. Publishing
```
Checklist:
[ ] package.json: name, version, main, types, exports
[ ] TypeScript declarations (.d.ts)
[ ] Dual ESM/CJS exports configured
[ ] README with usage examples
[ ] CHANGELOG updated
[ ] Tests passing
[ ] .npmignore or "files" field (only needed files)
[ ] Version bumped (semver)
```
```bash
npm publish --dry-run  # Always dry-run first
npm pack  # Inspect what ships
```

### 6. Security Audit
```bash
npm audit          # or pnpm audit / yarn audit
npm audit --json   # Detailed report
npm audit fix      # Auto-fix compatible
npm outdated       # Check for updates
```
IF critical/high vulns in direct deps: update immediately.
IF critical/high in transitive: add override or update parent.
IF no fix available: assess exploitability, document risk.

### 7. Version Resolution
```
| Problem | Solution |
| Conflicting peers | --legacy-peer-deps or update |
| Duplicates | npm dedupe / pnpm dedupe |
| Phantom deps | Switch to pnpm (strict mode) |
| Build fails | Delete node_modules + lock, reinstall |
```

## Hard Rules
1. ALWAYS commit lock files.
2. ALWAYS --frozen-lockfile in CI.
3. NEVER mix package managers in one project.
4. NEVER manually edit lock files.
5. NEVER use * or "latest" as version ranges.

## TSV Logging
Append `.godmode/npm-results.tsv`:
```
timestamp	action	packages_affected	vulns_fixed	status
```

## Keep/Discard
```
KEEP if: audit clean AND build green AND tests pass.
DISCARD if: new vuln introduced OR build fails.
Never keep override without documented removal date.
```

## Stop Conditions
```
STOP when FIRST of:
  - Zero critical/high vulns + lock committed
  - No unused deps + no duplicates
  - CI uses frozen install
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Critical vuln | npm install pkg@latest or override |
| Lock merge conflict | git checkout --theirs, npm install |
| Phantom dep | Switch to pnpm or add explicitly |
