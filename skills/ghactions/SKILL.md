---
name: ghactions
description: |
  GitHub Actions workflows, custom actions, CI/CD.
  Matrix builds, reusable workflows, composite
  actions, caching, security hardening.
  Triggers on: /godmode:ghactions, "GitHub Actions",
  "workflow", ".github/workflows", "matrix build".
---

# GHACTIONS — GitHub Actions Expert

## When to Activate
- User invokes `/godmode:ghactions`
- User says "create workflow", "add GitHub Actions"
- User says "matrix build", "reusable workflow"
- User mentions `.github/workflows/` or `action.yml`
- Project needs CI/CD on GitHub Actions

## Workflow

### Step 1: Discover Repository Context

```bash
# Detect existing workflows
ls .github/workflows/*.yml 2>/dev/null

# Audit current actions
grep -rh "uses:" .github/workflows/ 2>/dev/null \
  | sort -u

# Find unpinned actions (security risk)
grep -rn "uses:.*@v[0-9]" .github/workflows/ 2>/dev/null

# Find missing permissions declarations
grep -L "permissions:" .github/workflows/*.yml 2>/dev/null

# Find missing timeouts
grep -L "timeout-minutes:" .github/workflows/*.yml 2>/dev/null
```

```
REPOSITORY CONTEXT:
  Workflows: <list>
  Language: <detected>, Package Manager: <npm|pnpm>
  Test: <jest|vitest|pytest>, Linter: <eslint|ruff>
  Monorepo: yes/no, Environments: staging|production

IF no workflows: create from scratch
IF unpinned actions: pin to SHA immediately
IF missing permissions: add explicit per-job
IF missing timeouts: add to every job
```

### Step 2: Triggers & Filtering

```
KEY TRIGGERS:
  push (CI on merge), pull_request (PR checks)
  schedule (nightly), workflow_dispatch (manual)
  workflow_call (reusable), release (publish)

RULES:
  Use paths/paths-ignore to skip irrelevant workflows
  IF docs-only change: skip test workflow
  IF monorepo: trigger per-package via paths
```

### Step 3: Job Structure & Matrix

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@<SHA>
      - uses: actions/setup-node@<SHA>
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci && npm run lint

  test:
    needs: lint
    runs-on: ${{ matrix.os }}
    timeout-minutes: 15
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest]
        node-version: [18, 20, 22]
```

### Step 4: Caching & Optimization

```yaml
# Cancel redundant runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

```
OPTIMIZATION:
  Shallow clone: fetch-depth: 1
  Dependency caching: via setup action cache param
  Docker layers: BuildKit GHA backend
  Test sharding: matrix strategy

THRESHOLDS:
  PR pipeline target: < 10 minutes total
  Individual job timeout: 15 minutes default
  Cache hit rate target: > 90%
  IF pipeline > 15min: split jobs, add sharding
```

### Step 5: Security Hardening

```yaml
# Pin to SHA, minimal permissions
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
permissions:
  contents: read
# NEVER interpolate untrusted input in run:
env:
  PR_TITLE: ${{ github.event.pull_request.title }}
```

```
SECURITY CHECKLIST:
  Pin all actions to full commit SHA
  Declare minimum permissions per job
  Never interpolate untrusted input in run: blocks
  Restrict fork access to secrets
  Use OIDC for cloud providers (no long-lived secrets)
  Run OpenSSF Scorecard weekly

IF write-all permissions: CRITICAL — restrict now
IF unpinned actions: HIGH — pin to SHA
IF untrusted interpolation in run: CRITICAL
```

### Step 6: Deployment & Environments

```
ENVIRONMENTS:
  Staging: auto-deploy on push to main
  Production: manual approval required

PROTECTION RULES:
  Required reviewers: 1+
  Wait timer: optional (e.g., 5min for monitoring)
  Branch restriction: main only
  IF deploy fails: auto-rollback
```

### Step 7: Commit
```
Save in .github/workflows/ and .github/actions/
Commit: "ci: <description> — GitHub Actions
  (<N> jobs, <estimated time>)"
```

## Key Behaviors
Never ask to continue. Loop autonomously until done.

1. **Least privilege permissions.** Per-job, not global.
2. **Pin actions to SHA.** Use Dependabot for updates.
3. **Cancel redundant runs.** Concurrency groups.
4. **Cache everything.** Dependencies, Docker, builds.
5. **Fail fast on cheap checks.** Lint → test.
6. **Environments gate production.**
7. **Timeouts on every job.** 15 minutes default.

## HARD RULES
1. Never use `permissions: write-all`.
2. Never pin actions to mutable tags — use SHA.
3. Never interpolate untrusted input in `run:`.
4. Never share secrets with fork PRs.
5. Always set `timeout-minutes` on every job.
6. Always use concurrency groups.
7. Always set `retention-days` on artifact uploads.
8. Never use `continue-on-error: true` for flaky tests.

## Auto-Detection
```bash
ls .github/workflows/*.yml 2>/dev/null
grep -rh "uses:" .github/workflows/ | sort -u
grep -rn "uses:.*@v[0-9]" .github/workflows/
grep -L "permissions:" .github/workflows/*.yml
grep -L "timeout-minutes:" .github/workflows/*.yml
```

## Quality Targets
- Target: <10min CI workflow runtime
- Target: >95% workflow success rate over 30 days
- Cache hit rate: >80% for dependency caching

## Output Format
Print: `GHActions: {N} workflows, {M} jobs.
  Cache: {active|missing}. Concurrency: {status}.
  Security: {pinned|unpinned}. Status: {status}.`

## TSV Logging
```
iteration	workflow	jobs	duration_before	duration_after	cache_hit_rate	security_fixes	status
```

## Keep/Discard Discipline
```
KEEP if: workflow passes on test PR
  AND no secret exposure AND cache hit maintained
DISCARD if: workflow fails OR secrets leaked
  OR build time increased > 20%
```

## Stop Conditions
```
STOP when ALL of:
  - All workflows pass on clean PR
  - Caching configured for dependencies
  - Concurrency groups prevent stale runs
  - Secrets in repository settings only
```

## Error Recovery
- Syntax error: run `actionlint` locally.
- Permission denied: add to permissions block.
- Cache miss: verify key matches lockfile path.
- Pipeline too long: add timeout, split jobs.
- Concurrency cancels needed runs: disable for deploys.

