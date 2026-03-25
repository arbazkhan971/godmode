---
name: ship
description: >
  Ship workflow. Checklist, dry-run, ship, verify.
  PR, deploy, or release.
---

## Activate When
- `/godmode:ship`, "ship it", "deploy", "release"
- "merge", "push to prod", "create a PR"
- All checks pass and user wants to deliver

## Workflow
```bash
# 1. INVENTORY — What's being shipped?
git log main..HEAD --oneline
git diff main..HEAD --stat
```
```
commits = git log main..HEAD --oneline
IF commits is empty:
    Print: "Nothing to ship." STOP
ship_type = detect: PR | release | deploy
Print: "{N} commits, {M} files. Type: {ship_type}."
```
```bash
# 2. PRE-SHIP CHECKLIST
{build_cmd}; echo "build:$?"
{lint_cmd}; echo "lint:$?"
{test_cmd}; echo "test:$?"
grep -rn 'API_KEY\|SECRET\|PASSWORD\|TOKEN=' \
  $(git diff main..HEAD --name-only) 2>/dev/null
grep -rn '<<<<<<<\|>>>>>>>' \
  $(git diff main..HEAD --name-only) 2>/dev/null
```
```
FOR each (name, result) in checks:
    Print: "  [{PASS|FAIL}] {name}"
IF build OR lint OR test FAILED:
    delegate to /godmode:fix (max 3 rounds)
    Re-run checklist. IF still failing -> STOP.
IF secrets found:
    "BLOCKED: secrets in diff." STOP.
IF conflict markers found:
    "BLOCKED: merge conflicts." STOP.
IF only TODOs found:
    "WARNING: TODOs found. Proceeding."
```

### Ship by Type

| Phase | PR | Release | Deploy |
|-------|-----|---------|--------|
| Target | title + body | version + tag | config |
| Ship | git push; gh pr create | git tag; gh release | fly deploy |
| Verify | gh pr checks --watch | gh release view | curl health |
| Rollback | gh pr close | git tag -d + push | fly rollback |

```
# 4. DRY-RUN: Print commands + rollback.
#    Require user types 'yes' to proceed.
# 5. SHIP: Execute commands. Print URL.
# 6. VERIFY: Check result. On deploy failure:
#    execute rollback immediately.
```

### Pre-Flight Gates
```
CODE QUALITY: test + lint + build exit 0
SECURITY: no secrets, no .env, no conflict markers
  npm audit -> 0 critical/high
READINESS: branch up-to-date, CI green

IF any CODE QUALITY or SECURITY fails: BLOCKED
IF COMPLETENESS fails: WARNING (proceed + ack)
```

### Rollback Plan
```
PR MERGE: git revert <sha>. Time: <5min.
RELEASE: git tag -d {tag} && git push :tag. <5min.
DEPLOY: fly releases rollback | kubectl rollout undo
  Time: <10min. Verify: health check 200.
IF rollback impossible (destructive migration):
  WARN + require explicit user confirmation.
```

### Post-Ship Monitoring
```
PR: monitor CI 10 minutes
Release: monitor downloads 30 minutes
Deploy: monitor health 15 minutes
  CHECK every 60s: health 200, error rate, latency
  P0 (health down, errors >10x): IMMEDIATE ROLLBACK
  P1 (errors >2x, latency >3x): ROLLBACK in 15min
  P2 (new errors, health OK): INVESTIGATE
  P3 (cosmetic): DOCUMENT, fix forward
```

## TSV Logging
Append to `.godmode/ship-results.tsv`:
`timestamp\tship_type\tcommit_sha\tbranch\toutcome\turl\trollback_cmd`

## Output Format
Print: `Ship: {type} completed. {outcome}. URL: {url}.`

## Hard Rules
1. Never ship with failing build, lint, or test.
2. Always show dry-run + rollback before executing.
3. One ship per invocation: PR, release, or deploy.
4. Every ship must have a known rollback command.
5. Always verify after shipping.
6. Never ask to continue. Loop autonomously.

## Keep/Discard Discipline
```
KEEP if: post-ship verification passes
DISCARD if: verification fails OR rollback triggered
  On discard: execute rollback_cmd immediately.
```

## Stop Conditions
```
STOP when FIRST of:
  - Ship completed + verification passed
  - 3 rounds of fix failed to resolve blockers
  - Same check keeps failing after fix attempts
```
