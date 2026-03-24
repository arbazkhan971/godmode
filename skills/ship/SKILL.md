---
name: ship
description: Ship workflow. Checklist, dry-run, ship, verify. PR, deploy, or release.
---

## Activate When
- `/godmode:ship`, "ship it", "deploy", "release", "merge", "push to prod", "create a PR"
- All checks pass and user wants to deliver the work
- Called after `/godmode:build` + `/godmode:review` complete successfully

## Auto-Detection
The godmode orchestrator routes here when:
- User says "ship", "deploy", "release", "merge", "push", "PR", "publish"
- The branch has commits ahead of main and all checks pass
- Another skill completes and the user signals readiness to deliver

## Step-by-step Workflow
```
# 1. INVENTORY — What's being shipped?
commits = `git log main..HEAD --oneline`
IF commits is empty:
    Print: "Ship: nothing to ship. No commits ahead of main."
    STOP
diff_stat = `git diff main..HEAD --stat`
ship_type = detect_type()  # PR if branch != main, release if tag requested, deploy if deploy config exists
Print: "Ship inventory: {len(commits)} commits, {files_changed} files changed. Type: {ship_type}."

# 2. PRE-SHIP CHECKLIST — Run all checks, report PASS/FAIL for each.
checks = []
checks.append(("build",    run(build_cmd)))
checks.append(("lint",     run(lint_cmd)))
checks.append(("test",     run(test_cmd)))
checks.append(("secrets",  run("grep -rn 'API_KEY\|SECRET\|PASSWORD\|PRIVATE_KEY\|TOKEN=' $(git diff main..HEAD --name-only)")))
checks.append(("todos",    run("grep -n 'TODO\|FIXME\|HACK\|XXX' $(git diff main..HEAD --name-only)")))
checks.append(("conflict", run("grep -rn '<<<<<<<\|>>>>>>>\|=======' $(git diff main..HEAD --name-only)")))

FOR each (name, result) in checks:
    Print: "  [{PASS|FAIL}] {name}"
passing = count(PASS in checks)
Print: "Checklist: {passing}/{len(checks)} passed."

IF any check FAILED:
    IF build or lint or test failed:
        Print: "Blocking failure. Running /godmode:fix..."
        delegate to /godmode:fix (max 3 rounds)
        Re-run checklist. If still failing → STOP.
    IF secrets found:
        Print: "BLOCKED: secrets detected in diff. Remove before shipping."
        List each file:line with the match. STOP.
    IF conflict markers found:
        Print: "BLOCKED: merge conflict markers in source. Resolve before shipping."
        STOP.
    IF only todos found:
        Print: "WARNING: TODOs found. Proceeding (non-blocking)."
        List each file:line.

# 3-6. DETERMINE TARGET, DRY-RUN, SHIP, VERIFY — per ship_type:
#
# | Phase     | pr                                | release                           | deploy                              |
# |--|--|--|--|
# | Target    | title from commits, body=summary  | version from manifest, tag=v{ver} | config from Dockerfile/fly/vercel/k8s|
# | Rollback  | gh pr close {number}              | git tag -d {tag} && push :tag     | fly releases rollback / kubectl undo|
# | Ship cmds | git push -u; gh pr create         | git tag; git push tag; gh release | fly deploy / vercel --prod / kubectl|
# | Verify    | gh pr checks --watch → CI status  | gh release view {tag}             | curl -sf {health_url} → 200 or rollback|
#
# 4. DRY-RUN: Print commands + rollback. Require user types 'yes' to proceed.
# 5. SHIP: Execute the commands for the detected ship_type. Print result URL.
# 6. VERIFY: Run the verify check. On failure for deploy: execute rollback immediately.

# 7. LOG — Append to .godmode/ship-results.tsv
append_tsv(timestamp, ship_type, commit_sha, outcome, url)

Print: "Ship: {ship_type} completed. {outcome}. URL: {url}."
```

## Output Format
Each stage prints structured output:
- **Inventory:** `Ship inventory: {N} commits, {M} files changed. Type: {pr|release|deploy}.`
- **Checklist:** `Checklist: {passing}/{total} passed.` with `[PASS]`/`[FAIL]` per check
- **Dry-run:** Block showing exact commands, target, and rollback command
- **Ship:** `PR created: {url}` or `Release created: {url}` or `Deployed: {url}`
- **Verify:** `CI: {passing|failing}` or `Health: {ok|failed}`
- **Final:** `Ship: {type} completed. {shipped|rolled-back|failed}. URL: {url}.`

## TSV Logging
Append to `.godmode/ship-results.tsv` after every ship attempt. Columns:
```
timestamp	ship_type	commit_sha	branch	outcome	url	rollback_cmd
2024-01-15T10:30:00Z	pr	a1b2c3d	feat/auth	shipped	https://github.com/org/repo/pull/42	gh pr close 42
2024-01-16T14:00:00Z	release	d4e5f6a	main	shipped	https://github.com/org/repo/releases/tag/v1.2.0	git tag -d v1.2.0
2024-01-17T09:15:00Z	deploy	f7a8b9c	main	rolled-back	https://app.fly.dev	fly releases rollback
```

## Success Criteria
- [ ] Pre-ship checklist passes 100% (build, lint, test, no secrets, no conflict markers)
- [ ] Dry-run printed and user confirmed with "yes"
- [ ] Ship action executed without errors
- [ ] Post-ship verification passed (CI green, health check OK, or release visible)
- [ ] `.godmode/ship-results.tsv` has one row for this ship
- [ ] If verification failed, rollback was executed and logged

## Error Recovery
- **If `git push` fails with "rejected" (remote ahead):** Run `git pull --rebase origin {branch}`. Re-run checklist after rebase (rebase can introduce conflicts). Then retry push.
- **If `gh pr create` fails with "already exists":** Run `gh pr list --head {branch}` to find existing PR. Print the URL. Ask user: update existing PR or create new branch.
- **If CI fails after PR creation:** Run `gh pr checks {number}` to get failing check names. Delegate to `/godmode:fix` for fixable errors. Push fixes to same branch. CI will re-run.
- **If health check fails after deploy:** Execute rollback command immediately. Log outcome as "rolled-back". Print the rollback command that was run. Do not retry deploy — user must investigate.
- **If `gh` CLI is not installed or not authenticated:** Print: "Install GitHub CLI: `brew install gh && gh auth login`". Fall back to `git push` only and print manual PR creation URL: `https://github.com/{org}/{repo}/compare/main...{branch}`.

## Shipping Checklist Loop

Comprehensive pre-flight, rollback, and monitoring protocol for production-grade shipping:

```
SHIPPING CHECKLIST LOOP:
current_iteration = 0
max_iterations = 5
checklist_phases = [pre_flight_checks, rollback_plan, ship_execution, post_ship_monitoring, incident_readiness]

WHILE current_iteration < max_iterations:
  phase = checklist_phases[current_iteration]
  current_iteration += 1

  IF phase == "pre_flight_checks":
    1. CODE QUALITY GATE:
       [ ] All tests pass: {test_cmd} → exit 0
       [ ] Lint clean: {lint_cmd} → exit 0
       [ ] Type check: {typecheck_cmd} → exit 0 (if applicable)
       [ ] Build succeeds: {build_cmd} → exit 0
       [ ] No regressions: test count >= previous test count

    2. SECURITY GATE:
       [ ] No secrets in diff: scan for API_KEY, SECRET, PASSWORD, TOKEN, PRIVATE_KEY
       [ ] No .env files in diff: check for accidental .env commits
       [ ] Dependency audit clean: npm audit → 0 critical/high
       [ ] No conflict markers: grep for <<<<<<<, =======, >>>>>>>
       [ ] Permissions check: no 777 file modes in diff

    3. COMPLETENESS GATE:
       [ ] Documentation updated for API/behavior changes
       [ ] CHANGELOG entry added for user-facing changes
       [ ] Migration tested (if database changes present)
       [ ] Feature flag configured (if partial/gradual rollout)
       [ ] Backward compatibility verified (API versioning correct)

    4. READINESS GATE:
       [ ] Branch is up to date with base (rebased on latest main)
       [ ] PR description complete (all template sections filled)
       [ ] Required approvals received
       [ ] CI pipeline green on latest commit

    5. SCORE:
       gates_passed = count(all checks passed per gate)
       total_gates = 4
       IF any check in CODE QUALITY or SECURITY fails: BLOCKED
       IF any check in COMPLETENESS fails: WARNING (proceed with acknowledgment)
       IF any check in READINESS fails: BLOCKED

    REPORT:
    PRE-FLIGHT CHECKLIST:
| Gate | Status | Details |
|--|--|--|
| Code quality | PASS | 4/4 checks passed |
| Security | PASS | 5/5 checks passed |
| Completeness | WARN | 3/5 — docs missing |
| Readiness | PASS | 4/4 checks passed |
| Overall | READY | 1 warning, 0 blockers |

  IF phase == "rollback_plan":
    1. DETERMINE rollback strategy based on ship type:

       PR MERGE:
         Rollback: git revert <merge_commit_sha>
         Time to rollback: < 5 minutes
         Data impact: none (code-only change)
         Verification: tests pass on reverted main

       RELEASE (tag/version):
         Rollback: git tag -d {tag} && git push origin :refs/tags/{tag}
         Or: gh release delete {tag} --yes
         Time to rollback: < 5 minutes
         Verification: gh release list shows no {tag}

       DEPLOY (production):
         Rollback command: {detected rollback command}
           Fly.io:      fly releases rollback
           Vercel:       vercel rollback
           Kubernetes:   kubectl rollout undo deployment/{name}
           AWS ECS:      aws ecs update-service --force-new-deployment (to prev task def)
           Heroku:       heroku releases:rollback
           Docker:       docker service rollback {service}
         Time to rollback: < 10 minutes
         Verification: health check URL returns 200

       DATABASE MIGRATION:
         Rollback: {migrate_down_cmd} (tool-specific down migration)
         Time to rollback: varies (seconds for small tables, minutes for large)
         CRITICAL: if migration is destructive (DROP COLUMN), rollback may not fully restore
         Pre-requisite: backup taken BEFORE migration

    2. DOCUMENT rollback plan:
       ROLLBACK PLAN:
  Ship type:       {pr | release | deploy}
  Rollback command: {exact command}
  Time to rollback: < {N} minutes
  Data impact:     {none | possible | guaranteed}
  Verification:    {verification command}
  Escalation:      {who to contact if rollback fails}
  Backup taken:    {YES / NO / N/A}

    3. IF rollback is impossible (destructive migration, external API notify):
       WARN: "This ship has NO rollback path. Require explicit user confirmation."
       REQUIRE: user types "I understand there is no rollback" to proceed

  IF phase == "ship_execution":
    1. EXECUTE ship with observability:
       a. Record pre-ship state:
          - Current commit SHA on main
          - Current deployment version (if deploy)
          - Baseline metrics (error rate, latency, if available)
       b. Execute ship command (as defined in main workflow)
       c. Record post-ship state:
          - New commit SHA on main
          - New deployment version
          - Timestamp of ship completion

    2. LOG to TSV with full context (extends main workflow logging)

  IF phase == "post_ship_monitoring":
    1. DEFINE monitoring window:
       PR merge:  monitor CI for 10 minutes (all checks pass on main)
       Release:   monitor download/install for 30 minutes
       Deploy:    monitor health for 15 minutes minimum

    2. MONITOR during window:
       FOR deploy type:
         CHECK every 60 seconds:
         [ ] Health endpoint returns 200: curl -sf {health_url}
         [ ] Error rate is not elevated: compare against baseline
         [ ] Latency is within bounds: p50 < {threshold}, p99 < {threshold}
         [ ] No new error log patterns: check for new ERROR/FATAL entries

       FOR PR merge type:
         CHECK once:
         [ ] CI passes on main: gh pr checks or gh run list
         [ ] No new test failures introduced

    3. IF monitoring detects issues:
       SEVERITY CLASSIFICATION:
         P0 (Critical): health endpoint down, error rate >10x baseline → IMMEDIATE ROLLBACK
         P1 (High): error rate >2x baseline, latency >3x baseline → ROLLBACK within 15 min
         P2 (Medium): new error patterns but health OK → INVESTIGATE, prepare rollback
         P3 (Low): cosmetic issues, non-critical warnings → DOCUMENT, fix forward

       IF P0 or P1:
         a. Execute rollback command immediately
         b. Verify rollback succeeded (health check returns 200)
         c. Log incident: timestamp, severity, symptom, rollback outcome
         d. Create incident ticket for investigation

    4. REPORT:
       POST-SHIP MONITORING:
  Monitoring window:  <N> minutes
  Health checks:      <N>/<N> passed
  Error rate:         {normal | elevated | critical}
  Latency:            {normal | elevated | critical}
  New error patterns: {none | <N> detected}
  Rollback triggered: {NO | YES — reason}
  Status:             {STABLE | DEGRADED | ROLLED BACK}

  IF phase == "incident_readiness":
    1. VERIFY incident response infrastructure:
       [ ] Rollback command is documented and tested
       [ ] On-call contact is identified
       [ ] Monitoring alerts are configured for the affected service
       [ ] Runbook exists for common failure modes
       [ ] Communication channel established (Slack channel, PagerDuty, etc.)

    2. FOR high-risk ships (database migration, breaking API change, new infrastructure):
       [ ] Announce in team channel before shipping
       [ ] Schedule ship during low-traffic window
       [ ] Have a second engineer available for verification
       [ ] Pre-write rollback commands (copy-pasteable, not improvised)
       [ ] Set calendar reminder to check metrics 1 hour post-ship

  REPORT: "Phase {current_iteration}/{max_iterations}: {phase} — {PASS | FAIL | WARNING}"

FINAL SHIPPING READINESS:
  SHIP READINESS SUMMARY
| Phase | Status | Details |
|--|--|--|
| Pre-flight checks | PASS | 16/17 checks (1 warning) |
| Rollback plan | READY | Command documented |
| Ship execution | DONE | Shipped at {timestamp} |
| Post-ship monitor | STABLE | 15 min, all green |
| Incident readiness | PASS | Runbook + on-call ready |
| Overall | SHIPPED | Stable in production |
```
## Hard Rules
1. Never ship with failing build, lint, or test checks — fix first, ship second.
2. Always show dry-run with exact commands and rollback plan before executing.
3. One ship per invocation: one PR, one release, or one deploy — never combine.
4. Every ship action must have a known rollback command printed in the dry-run.
5. Always verify after shipping — CI for PRs, health check for deploys, `gh release view` for releases.
6. Measure before/after. Guard: test_cmd && lint_cmd.
7. Never ask to continue. Loop autonomously until shipped or budget exhausted.

## Keep/Discard Discipline
```
After EACH ship action:
  KEEP if: post-ship verification passes (CI green, health check OK, release visible)
  DISCARD if: verification fails OR rollback triggered
  On discard: execute rollback_cmd immediately. Log rolled-back status in ship-results.tsv.
  Never keep a ship action that fails post-ship verification.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: ship completed and post-ship verification passed
  - budget_exhausted: 3 rounds of /godmode:fix failed to resolve blocking checks
  - diminishing_returns: same check keeps failing after fix attempts
  - stuck: >5 pre-ship checklist failures with no progress
```
