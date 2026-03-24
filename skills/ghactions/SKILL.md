---
name: ghactions
description: GitHub Actions workflows, custom actions, CI/CD on GitHub, matrix builds. Use when user mentions GitHub Actions, workflow, .github/workflows, actions, CI pipeline on GitHub, matrix strategy.
---

# GHACTIONS — GitHub Actions Expert

## When to Activate
- User invokes `/godmode:ghactions`
- User says "create workflow", "add GitHub Actions", "fix Actions", "Actions is slow"
- User says "matrix build", "reusable workflow", "composite action"
- User mentions `.github/workflows/`, `action.yml`, or `workflow_call`
- Project needs CI/CD specifically on GitHub Actions

## Workflow

### Step 1: Discover Repository Context
```
REPOSITORY CONTEXT:
  Existing Workflows: <list .github/workflows/*.yml>
  Language: <detected>  Package Manager: <npm|pnpm|yarn|pip|go mod>
  Test Framework: <jest|vitest|pytest|go test>  Linter: <eslint|ruff|etc.>
  Monorepo: <yes/no>  Environments: <staging|production>
```

### Step 2: Triggers
Key triggers: `push` (CI on merge), `pull_request` (PR checks), `schedule` (nightly), `workflow_dispatch` (manual with inputs), `workflow_call` (reusable), `release` (publish). Use `paths`/`paths-ignore` to skip irrelevant workflows.

### Step 3: Jobs, Steps, Matrix
```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm' }
      - run: npm ci && npm run lint && npm run type-check

  test:
    needs: lint
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest]
        node-version: [18, 20, 22]
    services:
      postgres:
        image: postgres:16
        env: { POSTGRES_PASSWORD: test }
        ports: ['5432:5432']
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '${{ matrix.node-version }}', cache: 'npm' }
      - run: npm ci && npm test
```

### Step 4: Reusable Workflows
Create DRY workflows with `workflow_call`. Define inputs, secrets, outputs. Call from multiple workflows or monorepo packages.

### Step 5: Composite Actions
Encapsulate multi-step logic in `.github/actions/<name>/action.yml` with `using: composite`. Reuse setup steps across workflows.

### Step 6: Caching
Use built-in caching via setup actions (`cache: 'npm'`). For custom caching: `actions/cache@v4` with lockfile hash keys and restore-keys fallback. Docker layers via BuildKit GHA backend.

### Step 7: Secrets & Environments
Use environment-scoped secrets and protection rules. Production: required reviewers + wait timer + branch restriction. Prefer OIDC for cloud providers (no long-lived secrets).

### Step 8: Artifacts
`actions/upload-artifact@v4` / `download-artifact@v4` to pass data between jobs. Set `retention-days` on every upload. 500 MB per artifact, 10 GB per repo.

### Step 9: Optimization
```yaml
# Cancel redundant runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```
Shallow clone (`fetch-depth: 1`), path filters, timeout every job, skip duplicate runs, test sharding via matrix.

### Step 10: Security Hardening
```yaml
# Pin actions to SHA, minimal permissions, safe interpolation
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
permissions:
  contents: read
# NEVER interpolate in run: — use env: variables instead
env:
  PR_TITLE: ${{ github.event.pull_request.title }}
```
Restrict fork access to secrets. Run OpenSSF Scorecard weekly.

### Step 11: Deployment with Approvals
Staging auto-deploys, production requires manual approval via environment protection rules. Blue-green deploy with rollback on failure. Slack notification on completion.

### Step 12: Commit and Report
```
Save in .github/workflows/ and .github/actions/
Commit: "ci: <description> — GitHub Actions (<N> jobs, <estimated time>)"
```

## Key Behaviors
1. **Least privilege permissions.** Never use `permissions: write-all`.
2. **Pin actions to SHA.** Tags are mutable. Use Dependabot for updates.
3. **Cancel redundant runs.** Concurrency groups on every workflow.
4. **Cache everything.** Dependencies, Docker layers, build outputs.
5. **Fail fast on cheap checks.** Lint -> type-check -> test.
6. **Environments gate production.** Staging auto, production manual approval.
7. **Timeouts on every job.** 15 minutes default.

## Flags & Options

| Flag | Description |
|--|--|
| `--create` | Generate new workflow from scratch |
| `--deploy` | Add deployment with environments |
| `--matrix` | Set up matrix builds |
| `--harden` | Security audit and hardening |
| `--optimize` | Speed and cost optimization |
| `--fix` | Diagnose and fix failing workflow |

## HARD RULES
1. **NEVER use `permissions: write-all`.** Declare minimum permissions per job.
2. **NEVER pin actions to mutable tags.** Pin to full commit SHA.
3. **NEVER interpolate untrusted input in `run:` blocks.** Use `env:` variables.
4. **NEVER share secrets with fork PRs.** Gate with repo fullname check.
5. **ALWAYS set `timeout-minutes` on every job.**
6. **ALWAYS use concurrency groups.**
7. **ALWAYS set `retention-days` on artifact uploads.**
8. **NEVER use `continue-on-error: true` to mask flaky tests.**

## Auto-Detection
```bash
ls .github/workflows/*.yml 2>/dev/null              # Existing workflows
grep -rh "uses:" .github/workflows/ | sort -u        # Actions used
grep -rn "uses:.*@v[0-9]" .github/workflows/        # Unpinned actions
grep -L "permissions:" .github/workflows/*.yml       # Missing permissions
grep -L "timeout-minutes:" .github/workflows/*.yml   # Missing timeouts
```

## Iterative Loop Protocol
```
FOR EACH workflow:
  1. AUDIT: permissions, pinned versions, timeouts, caching, secrets
  2. FIX security issues
  3. OPTIMIZE performance
  4. VALIDATE with actionlint
  5. LOG to .godmode/ghactions-results.tsv
```

## Multi-Agent Dispatch
```
Agent 1 (ghactions-security): Pin actions, restrict permissions, fix secrets
Agent 2 (ghactions-perf): Caching, concurrency, parallel jobs
Agent 3 (ghactions-reusable): Extract composite actions and reusable workflows
MERGE ORDER: security -> perf -> reusable
```

## TSV Logging
Log to `.godmode/ghactions-results.tsv`: `iteration\tworkflow\tjobs\tduration_before\tduration_after\tcache_hit_rate\tsecurity_fixes\tstatus`

## Success Criteria
- All workflows have explicit `permissions:` (no write-all)
- All actions pinned to full commit SHA
- All jobs have `timeout-minutes`
- Concurrency groups configured
- Dependency caching enabled
- No untrusted input in `run:` blocks
- Total pipeline under 10 minutes for PR checks

## Error Recovery
- **Syntax error:** Run `actionlint` locally. Check YAML indentation.
- **Permission denied:** Add required permission to `permissions:` block.
- **Cache miss:** Verify key matches lockfile path.
- **Too long:** Add timeout, split jobs, enable test sharding.
- **Concurrency cancels needed runs:** Use `cancel-in-progress: false` for deploys.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-ghactions-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `GHActions: {workflows} workflows, {jobs} jobs. Cache: {active|missing}. Concurrency: {configured|none}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH workflow change:
  KEEP if: workflow passes on test PR AND no secret exposure AND cache hit rate maintained
  DISCARD if: workflow fails OR secrets leaked OR build time increased >20%
  On discard: revert. Test workflow changes in a draft PR first.
```

## Stop Conditions
```
Loop until target or budget. Never ask to continue — loop autonomously.
Measure before/after. Guard: test_cmd && lint_cmd.
On failure: git reset --hard HEAD~1.

STOP when ALL of:
  - All workflows pass on clean PR
  - Caching configured for dependencies
  - Concurrency groups prevent stale runs
  - Secrets in repository settings (not in workflow files)
```
