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

# 3. DETERMINE SHIP TARGET
IF ship_type == "pr":
    title = generate from commit log (under 70 chars)
    body = summarize changes + test plan
    base_branch = "main"
    rollback_cmd = "gh pr close {pr_number}"
ELIF ship_type == "release":
    version = detect from package.json/Cargo.toml/pyproject.toml or ask user
    tag = "v{version}"
    rollback_cmd = "git tag -d {tag} && git push origin :refs/tags/{tag}"
ELIF ship_type == "deploy":
    target = detect from deploy config (Dockerfile, fly.toml, vercel.json, k8s manifests)
    rollback_cmd = detect rollback (e.g., "fly releases rollback", "kubectl rollout undo")

# 4. DRY-RUN — Show exactly what will happen. User must confirm.
Print: "--- DRY RUN ---"
Print: "Action: {ship_type}"
Print: "Commands:"
FOR each cmd in ship_commands:
    Print: "  $ {cmd}"
Print: "Rollback: {rollback_cmd}"
Print: "Type 'yes' to proceed."
IF user != "yes": STOP

# 5. SHIP — Execute the ship action.
IF ship_type == "pr":
    `git push -u origin HEAD`
    `gh pr create --title "{title}" --body "{body}"`
    pr_url = parse output
    Print: "PR created: {pr_url}"
ELIF ship_type == "release":
    `git tag {tag}`
    `git push origin {tag}`
    `gh release create {tag} --generate-notes`
    release_url = parse output
    Print: "Release created: {release_url}"
ELIF ship_type == "deploy":
    run deploy command (e.g., `fly deploy`, `vercel --prod`, `kubectl apply -f`)
    deploy_url = parse output
    Print: "Deployed: {deploy_url}"

# 6. VERIFY — Post-ship check.
IF ship_type == "pr":
    `gh pr checks {pr_number} --watch`  # wait for CI
    ci_status = parse output
    Print: "CI: {ci_status}"
ELIF ship_type == "deploy":
    health_url = detect from config or ask user
    IF health_url:
        result = `curl -sf {health_url}`
        IF result fails:
            Print: "VERIFY FAILED. Rolling back: {rollback_cmd}"
            run(rollback_cmd)
            Print: "Rollback complete."
ELIF ship_type == "release":
    `gh release view {tag}`
    Print: "Release verified: {tag}"

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

## Anti-Patterns
1. **Shipping with failing checks.** Never bypass the checklist. If checks fail, fix them first. The only non-blocking check is TODOs/FIXMEs.
2. **Skipping dry-run.** Always show the user exactly what commands will run and the rollback plan before executing. No silent deploys.
3. **Shipping multiple things at once.** One ship per invocation: one PR, one release, or one deploy. Never combine (e.g., PR + deploy in same run).
4. **Deploying without a rollback plan.** Every ship action must have a known rollback command printed in the dry-run. If no rollback is possible, warn the user explicitly.
5. **Ignoring post-ship verification.** Always verify after shipping. A shipped PR needs CI to pass. A deploy needs a health check. A release needs `gh release view` confirmation.

## Examples

### Example 1: Ship as PR
```
$ /godmode:ship
Ship inventory: 4 commits, 7 files changed. Type: pr.
  [PASS] build
  [PASS] lint
  [PASS] test
  [PASS] secrets
  [PASS] todos
  [PASS] conflict
Checklist: 6/6 passed.
--- DRY RUN ---
Action: pr
Commands:
  $ git push -u origin HEAD
  $ gh pr create --title "feat(auth): add JWT refresh token rotation" --body "## Summary..."
Rollback: gh pr close {pr_number}
Type 'yes' to proceed.
> yes
PR created: https://github.com/org/repo/pull/42
CI: all checks passed
Ship: pr completed. shipped. URL: https://github.com/org/repo/pull/42.
```

### Example 2: Ship as release with version detection
```
$ /godmode:ship release
Ship inventory: 12 commits, 23 files changed. Type: release.
  [PASS] build
  [PASS] lint
  [PASS] test
  [PASS] secrets
  [WARN] todos — 2 found (non-blocking)
    src/api/handler.ts:42: TODO: add rate limiting
    src/utils/cache.ts:18: FIXME: TTL not configurable
  [PASS] conflict
Checklist: 5/6 passed (1 warning).
Detected version: 1.3.0 from package.json
--- DRY RUN ---
Action: release
Commands:
  $ git tag v1.3.0
  $ git push origin v1.3.0
  $ gh release create v1.3.0 --generate-notes
Rollback: git tag -d v1.3.0 && git push origin :refs/tags/v1.3.0
Type 'yes' to proceed.
> yes
Release created: https://github.com/org/repo/releases/tag/v1.3.0
Release verified: v1.3.0
Ship: release completed. shipped. URL: https://github.com/org/repo/releases/tag/v1.3.0.
```

### Example 3: Ship as deploy with failed health check
```
$ /godmode:ship deploy
Ship inventory: 3 commits, 5 files changed. Type: deploy.
  [PASS] build
  [PASS] lint
  [PASS] test
  [PASS] secrets
  [PASS] todos
  [PASS] conflict
Checklist: 6/6 passed.
Detected: fly.toml (Fly.io)
--- DRY RUN ---
Action: deploy
Commands:
  $ fly deploy
Rollback: fly releases rollback
Type 'yes' to proceed.
> yes
Deployed: https://myapp.fly.dev
Health check: curl -sf https://myapp.fly.dev/health ... FAILED (HTTP 502)
VERIFY FAILED. Rolling back: fly releases rollback
Rollback complete.
Ship: deploy completed. rolled-back. URL: https://myapp.fly.dev.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- The ship skill is inherently sequential (checklist → dry-run → ship → verify), so no parallel dispatch is needed.
- If `gh` CLI is unavailable, use `git push` and construct the PR URL manually: `https://github.com/{org}/{repo}/compare/main...{branch}`.
- For releases without `gh`: `git tag {tag} && git push origin {tag}`. Release notes must be added manually on GitHub.
- TSV logging, checklist logic, and dry-run printing remain identical.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
