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

## Key Behaviors

1. **The checklist is non-negotiable.** Do not ship with failing tests, security issues, or missing documentation.
2. **Dry run first.** Always simulate before executing. Catches issues before they affect production.
3. **Verify after shipping.** Creating a PR or deploying is not "done." Verify it works.
4. **Rollback plan ready.** Before deploying, know exactly how to roll back. If you can't roll back, don't deploy.
5. **Monitor after deploy.** 15 minutes of monitoring catches the issues that tests don't.
6. **Log everything.** The ship log is the history of what went to production and when.

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
