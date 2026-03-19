---
name: ship
description: |
  Shipping workflow skill. Activates when code is ready to deploy or merge. Runs an 8-phase shipping workflow: inventory changes, run checklist, prepare artifacts, dry-run, execute ship, verify deployment, log results, and post-ship monitoring. Triggers on: /godmode:ship, "ship it", "deploy", "release", "merge to main", or when optimize/secure phases complete successfully.
---

# Ship — Structured Shipping Workflow

## When to Activate
- User invokes `/godmode:ship`
- User says "ship it," "deploy this," "release," "merge to main"
- Optimize phase completes with target met
- Security audit passes
- All review findings are resolved

## Workflow

### Phase 1: Inventory
Catalog everything that will be shipped:

```bash
# Changes since branching from main
git log main..HEAD --oneline
git diff main..HEAD --stat
```

```
SHIP INVENTORY:
Branch: <branch name>
Base: <main/master>
Commits: <N>
Files changed: <N> (+<added> / -<removed>)

New features:
- <feature 1>: <brief description>
- <feature 2>: <brief description>

Modified:
- <module 1>: <what changed>
- <module 2>: <what changed>

Config changes:
- <env vars, config files, migrations>

Dependencies:
- Added: <new deps>
- Updated: <updated deps>
- Removed: <removed deps>
```

### Phase 2: Pre-Ship Checklist
Verify everything is ready:

```
PRE-SHIP CHECKLIST:
Code Quality:
[ ] All tests passing
[ ] Lint clean
[ ] Type check clean
[ ] Coverage ≥ target
[ ] No TODO/FIXME/HACK comments in new code
[ ] No console.log/print debugging

Security:
[ ] Security audit passed (/godmode:secure)
[ ] No secrets in code or config
[ ] Dependencies have no critical vulnerabilities
[ ] Input validation on all new endpoints

Documentation:
[ ] API changes documented
[ ] README updated (if needed)
[ ] CHANGELOG updated
[ ] Migration guide (if breaking changes)

Git Hygiene:
[ ] Commits are clean and descriptive
[ ] No merge commits (rebased on latest main)
[ ] Branch is up to date with main
[ ] No untracked files that should be committed
```

If any item fails, stop shipping and fix it first.

### Phase 3: Prepare
Prepare the release artifacts:

```bash
# Ensure branch is up to date
git fetch origin main
git rebase origin/main

# Run tests one final time after rebase
<test command>

# Build production artifacts (if applicable)
<build command>

# Generate changelog entry
<changelog generation>
```

```
PREPARATION:
✓ Rebased on latest main (no conflicts)
✓ Tests pass after rebase
✓ Build succeeds
✓ Artifacts ready
```

If rebase has conflicts: resolve them, re-run tests, then continue.

### Phase 4: Dry Run
Simulate the ship without actually shipping:

```bash
# Dry-run deploy (if applicable)
<deploy command --dry-run>

# Dry-run migration (if applicable)
<migration command --dry-run>

# Dry-run PR creation
gh pr create --title "<title>" --body "<body>" --draft --dry-run
```

```
DRY RUN RESULTS:
Deploy: ✓ Would succeed (no errors in dry run)
Migration: ✓ Would apply 2 migrations
PR: ✓ Ready to create
```

If dry run fails: fix the issue before proceeding.

### Phase 5: Ship
Execute the actual shipping operation:

**For PR-based workflows:**
```bash
# Create the pull request
gh pr create \
  --title "<feature>: <brief description>" \
  --body "$(cat <<'BODY'
## Summary
<What this PR does>

## Changes
<Bulleted list of changes>

## Testing
<How it was tested>

## Checklist
- [x] Tests passing
- [x] Security audit passed
- [x] Code review passed
BODY
)"

# Request reviewers (if configured)
gh pr edit <PR_NUMBER> --add-reviewer <reviewers>
```

**For direct deploy workflows:**
```bash
# Deploy to staging first
<deploy to staging command>

# Verify staging
<staging verification command>

# Deploy to production
<deploy to production command>
```

**For release workflows:**
```bash
# Tag the release
git tag -a v<version> -m "<release notes>"
git push origin v<version>

# Create GitHub release
gh release create v<version> --title "v<version>" --notes "<notes>"
```

### Phase 6: Verify
After shipping, verify everything works:

```bash
# For PR: Check CI status
gh pr checks <PR_NUMBER>

# For deploy: Run smoke tests
<smoke test command>

# For deploy: Check health endpoint
curl -s <production-url>/health

# For deploy: Check error rates
<monitoring command>
```

```
POST-SHIP VERIFICATION:
[ ] CI passing on PR
[ ] Smoke tests pass
[ ] Health check OK
[ ] Error rates normal
[ ] No new errors in logs
```

### Phase 7: Log
Record the shipment:

```
# File: .godmode/ship-log.tsv
timestamp	branch	type	target	status	pr_url	deploy_url	notes
2024-01-15T14:30:00Z	feat/rate-limiter	PR	main	CREATED	https://github.com/org/repo/pull/123		Awaiting review
```

### Phase 8: Post-Ship (if deployed)
Monitor for 15 minutes after deployment:

```
POST-SHIP MONITORING (15 min window):
T+0:  ✓ Deploy successful
T+1:  ✓ Health check OK, error rate 0.01%
T+5:  ✓ Health check OK, error rate 0.01%
T+10: ✓ Health check OK, error rate 0.02%
T+15: ✓ All clear. Ship confirmed stable.
```

If errors spike during monitoring:
```
⚠ ERROR RATE SPIKE: 0.01% → 2.3% at T+7
Triggering rollback...
<rollback command>
Rollback complete. Investigate with /godmode:debug.
```

### Ship Complete Report

```
┌─────────────────────────────────────────────────────┐
│  SHIP COMPLETE                                      │
├─────────────────────────────────────────────────────┤
│  Feature: <name>                                    │
│  Branch:  <branch>                                  │
│  Type:    <PR | Deploy | Release>                   │
│  Status:  <SUCCESS | ROLLED BACK>                   │
│                                                     │
│  Summary:                                           │
│  - <N> commits, <N> files changed                   │
│  - Tests: <N> passing                               │
│  - Coverage: <X>%                                   │
│  - Security: PASSED                                 │
│  - Review: APPROVED                                 │
│                                                     │
│  Artifacts:                                         │
│  - PR: <url>                                        │
│  - Deploy: <url>                                    │
│  - Release: <url>                                   │
│                                                     │
│  Ship log: .godmode/ship-log.tsv                    │
└─────────────────────────────────────────────────────┘
```

## Multi-Agent Pre-Ship Verification

Before Phase 5 (Ship) proceeds, dispatch **four parallel verification agents**. ALL must pass.

```
MULTI-AGENT VERIFICATION:

Agent 1: Run full test suite        → skill: test
Agent 2: Run security audit         → skill: secure
Agent 3: Run lint + type check      → skill: lint
Agent 4: Performance benchmark      → skill: perf

Status:
  Agent 1 (test):   ✓ 214/214 passing     [completed 42s]
  Agent 2 (secure): ✓ No vulnerabilities   [completed 38s]
  Agent 3 (lint):   ✓ 0 errors, 0 warnings [completed 15s]
  Agent 4 (perf):   ✓ p95 < 200ms          [completed 51s]

VERDICT: ALL PASSED → Ship may proceed.
```

If ANY agent fails, ship is **blocked**. Fix the failures before retrying:
```
  Agent 2 (secure): ✗ 1 critical vulnerability in lodash@4.17.20
  VERDICT: BLOCKED → Run /godmode:secure to remediate, then retry /godmode:ship.
```

Each agent runs in its own worktree so they execute in true parallel without interference.

## Rollback Protocol

Before shipping, prepare the rollback plan. Know exactly how to undo the ship.

**For git merge rollbacks:**
```bash
# Revert the merge commit (keeps history, undoes changes)
git revert <merge-commit> --no-edit
git push origin main
```

**For Kubernetes deployments:**
```bash
# Roll back to the previous deployment revision
kubectl rollout undo deployment/<name>
# Verify rollback succeeded
kubectl rollout status deployment/<name>
```

**For Vercel/Netlify/Serverless:**
```bash
# Vercel: promote the previous deployment
vercel promote <previous-deployment-url>

# Netlify: restore previous deploy
netlify deploy --prod --dir=<previous-build-dir>

# Or via dashboard: click "Publish deploy" on the previous deployment
```

**For npm/package releases:**
```bash
# Deprecate the broken version
npm deprecate <package>@<broken-version> "Known issue, use <previous-version>"
# Publish a patch with the revert
npm publish
```

The rollback command MUST be determined and documented **before** Phase 5 executes. If you cannot define a rollback procedure, **do not ship**.

## Post-Ship Monitoring Loop

After shipping (deploy only, not PRs), enter an automated monitoring loop:

```
POST-SHIP MONITORING LOOP (10 iterations, ~1 minute apart):

Iteration 1/10:
  Health endpoint:  ✓ 200 OK (latency: 45ms)
  Error rate:       ✓ 0.02% (baseline: 0.01%)
  p95 latency:      ✓ 120ms (baseline: 115ms)
  Status: HEALTHY

Iteration 5/10:
  Health endpoint:  ✓ 200 OK (latency: 48ms)
  Error rate:       ⚠ 1.8% (baseline: 0.01%) — ELEVATED
  p95 latency:      ⚠ 450ms (baseline: 115ms) — ELEVATED
  Status: DEGRADED — monitoring closely

Iteration 6/10:
  Health endpoint:  ✗ 503 Service Unavailable
  Error rate:       ✗ 5.2% — CRITICAL
  p95 latency:      ✗ 2100ms — CRITICAL
  Status: DEGRADED → AUTO-ROLLBACK TRIGGERED
```

**Auto-rollback thresholds:**
- Error rate > 2x baseline → Warning
- Error rate > 5x baseline → Auto-rollback
- Health endpoint returns non-200 → Auto-rollback
- p95 latency > 3x baseline → Auto-rollback

On auto-rollback:
```
⚠ DEGRADATION DETECTED at T+6 min
  Error rate: 5.2% (25x baseline)
  Executing rollback...
  <rollback command from Rollback Protocol>
  Rollback complete. Verifying...
  Health endpoint: ✓ 200 OK
  Error rate: 0.01% (back to baseline)

  SHIP ROLLED BACK. Investigate with /godmode:debug.
```

## Ship Log

Every ship operation is appended to `.godmode/ship-log.tsv` for audit trail:

```
# File: .godmode/ship-log.tsv
# Format: timestamp	branch	commit	type	outcome	url	notes
2024-01-15T14:30:00Z	feat/rate-limiter	abc1234	PR	SUCCESS	https://github.com/org/repo/pull/123	Awaiting review
2024-01-16T09:00:00Z	feat/rate-limiter	def5678	DEPLOY	SUCCESS	https://app.example.com	Stable after 10 min monitoring
2024-01-17T11:15:00Z	feat/webhooks	ghi9012	DEPLOY	ROLLED_BACK	https://app.example.com	Error rate spike at T+6, auto-rollback
2024-01-18T10:00:00Z	v2.1.0	jkl3456	RELEASE	SUCCESS	https://github.com/org/repo/releases/tag/v2.1.0	npm publish + GitHub release
```

Fields:
- **timestamp** — ISO 8601 UTC
- **branch** — branch name or tag
- **commit** — short SHA of the shipped commit
- **type** — `PR`, `DEPLOY`, or `RELEASE`
- **outcome** — `SUCCESS`, `ROLLED_BACK`, `FAILED`, `PENDING`
- **url** — PR URL, deploy URL, or release URL
- **notes** — freeform context

The ship log is written automatically at Phase 7. It is never manually edited.

## Key Behaviors

1. **The checklist is non-negotiable.** Do not ship with failing tests, security issues, or missing documentation.
2. **Dry run first.** Always simulate before executing. Catches issues before they affect production.
3. **Verify after shipping.** Creating a PR or deploying is not "done." Verify it works.
4. **Rollback plan ready.** Before deploying, know exactly how to roll back. If you can't roll back, don't deploy.
5. **Monitor after deploy.** 15 minutes of monitoring catches the issues that tests don't.
6. **Log everything.** The ship log is the history of what went to production and when.
7. **Multi-agent verification is mandatory.** All four agents (test, secure, lint, perf) must pass before ship proceeds.
8. **Auto-rollback on degradation.** Post-ship monitoring will automatically roll back if health degrades beyond thresholds.

## Example Usage

### Creating a PR
```
User: /godmode:ship Create a PR for the rate limiter

Ship: Starting shipping workflow...

Phase 1: Inventory...
Branch: feat/rate-limiter (14 commits, 8 files, +342/-12 lines)
New: rate limit middleware, Redis store, configuration

Phase 2: Checklist...
✓ Tests: 51/51 passing
✓ Lint: clean
✓ Security: audit passed
✓ Coverage: 87%
✓ No TODOs in new code
✓ No debug logging

Phase 3: Prepare...
✓ Rebased on latest main
✓ Tests pass after rebase

Phase 4: Dry run...
✓ PR would be created with no issues

Phase 5: Ship...
Creating PR...
PR #123 created: https://github.com/org/repo/pull/123

Phase 6: Verify...
✓ CI running on PR
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full 8-phase shipping workflow |
| `--pr` | Create a pull request (default for feature branches) |
| `--deploy <env>` | Deploy to environment (staging/production) |
| `--release <version>` | Create a tagged release |
| `--skip-checklist` | Skip pre-ship checklist (NOT RECOMMENDED) |
| `--rollback` | Roll back the last deployment |
| `--status` | Show status of last shipment |

## Anti-Patterns

- **Do NOT ship with failing tests.** Ever. Not even "just this once." Fix them first.
- **Do NOT skip the dry run.** "It'll be fine" is the last thing said before every production incident.
- **Do NOT forget the rollback plan.** If you can't answer "how do I undo this?", you're not ready to ship.
- **Do NOT skip post-deploy monitoring.** The first 15 minutes after deploy are when problems surface.
- **Do NOT ship on Fridays.** (This is a suggestion, not enforced. But seriously.)
- **Do NOT ship multiple features at once.** One branch, one feature, one PR. If something breaks, you know what caused it.
