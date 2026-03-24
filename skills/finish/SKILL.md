---
name: finish
description: Branch finalization. Validate, squash-merge, PR, keep, or discard. Clean state enforced.
---

## Activate When
- `/godmode:finish`, "done with branch", "merge this", "clean up branch", "finalize", "wrap up", "close this out"
- A feature branch has commits ahead of main and the user signals the work is complete
- Another skill (build, fix, test) completes and the branch is ready for integration

## Auto-Detection
The godmode orchestrator routes here when:
- `git log main..HEAD --oneline` returns 1+ commits AND user says "done", "merge", "finish", "wrap up"
- `/godmode:build` completes all tasks and all checks pass
- User explicitly invokes `/godmode:finish`

## Step-by-step Workflow

### 1. Snapshot Branch State
```
branch=$(git branch --show-current)
commits=$(git log main..HEAD --oneline | wc -l | tr -d ' ')
files_changed=$(git diff main..HEAD --stat | tail -1)
```
Print: `Branch: {branch} | {commits} commits ahead of main | {files_changed}`

If `branch == main`: STOP. Print `ERROR: Already on main. Nothing to finish. Switch to a feature branch first.`

### 2. Enforce Clean Worktree
```
staged=$(git diff --cached --name-only)
unstaged=$(git diff --name-only)
untracked=$(git ls-files --others --exclude-standard)
```
- If `staged` is non-empty: STOP. Print `ERROR: Staged but uncommitted changes. Commit or stash before finishing.`
- If `unstaged` is non-empty: STOP. Print `ERROR: Unstaged changes detected. Commit, stash, or discard before finishing.`
- If `untracked` has files: WARN. Print `WARNING: {N} untracked files. They will NOT be included in the merge. List: {files}`

### 3. Run Full Guard Suite
```
build_cmd && lint_cmd && test_cmd
```
Capture exit code and output of each command separately. Print per-check result:
```
Build:  PASS (0.8s)
Lint:   PASS (1.2s)
Tests:  PASS (47/47, 3.1s)
```
- ANY failure: STOP. Print `Guard failed: {which_check}. Run /godmode:fix first.` Do NOT proceed to merge/PR with failing checks.
- If `test_cmd` is unknown (no test runner detected): WARN and continue, but note `Tests: SKIPPED (no test runner detected)` in output.

### 4. Check for Merge Conflicts (pre-flight)
```
git fetch origin main
git merge-tree $(git merge-base HEAD origin/main) origin/main HEAD
```
If conflicts detected: print `WARNING: Merge conflicts detected with main. Files: {conflict_list}. Resolve before merging.` Recommend `git rebase origin/main` or manual resolution.

### 5. Determine Outcome
Evaluate in this order (first match wins):
- **DISCARD**: User explicitly says "discard", "abandon", "throw away". Requires confirmation.
- **KEEP**: User says "keep", "not yet", "park it", or worktree is dirty (caught in step 2 — already stopped).
- **PR**: Default when branch has commits, all checks pass, and user has not explicitly said "merge".
- **MERGE**: User explicitly says "merge", "squash merge", or all checks pass AND a review/approval exists (`gh pr view --json reviewDecision -q '.reviewDecision'` == "APPROVED").

### 6. Execute Outcome

**MERGE:**
```bash
git checkout main
git pull origin main
git merge --squash {branch}
git commit -m "feat({module}): {title}

Squashed {N} commits from {branch}.
Changes: {one_line_summary}"
git branch -d {branch}
```
Print: `MERGED: {branch} → main (squash). {N} commits → 1. Branch deleted.`

**PR:**
```bash
pr_body=$(git log main..HEAD --format='- %s')
test_summary="{pass}/{total} tests passing"
gh pr create --title "feat({module}): {title}" --body "## Changes
${pr_body}

## Tests
${test_summary}

## Guard Results
Build: PASS | Lint: PASS | Tests: PASS"
```
Print: `PR created: {url}. Branch: {branch}. Commits: {N}.`

**KEEP:**
Print: `KEPT: Branch {branch} stays. {N} commits ahead of main. Resume with /godmode:build or /godmode:finish later.`

**DISCARD:**
```
# Require explicit confirmation
echo "CONFIRM: Delete branch {branch} with {N} commits? This is irreversible. Type 'yes' to confirm."
# After confirmation:
git checkout main
git branch -D {branch}
```
Print: `DISCARDED: Branch {branch} deleted. {N} commits lost.`

### 7. Post-Finalization Verify
- **After MERGE**: Run `build_cmd && test_cmd` on main. If fails: `git revert HEAD` immediately. Print `ROLLBACK: Merge reverted. Main is clean.`
- **After PR**: Run `gh pr checks {pr_number} --watch` if CI exists. Print check status.
- **After DISCARD**: Verify branch is gone: `git branch --list {branch}` should return empty.

### 8. Log Result
Append to `.godmode/finish-results.tsv`:
```
{ISO-8601 timestamp}\t{branch}\t{outcome}\t{commits_squashed}\t{files_changed_count}\t{tests_pass}/{tests_total}\t{guard_status}\t{pr_url_or_na}
```

Print final summary:
```
Branch {branch}: {OUTCOME}. {N} commits squashed. Tests: {pass}/{total}. Guard: ALL PASS.
```

## Output Format
Each stage prints a single status line:
```
[finish:snapshot]  Branch: feature/auth | 7 commits ahead of main | 12 files changed
[finish:worktree]  Clean worktree confirmed
[finish:guard]     Build: PASS | Lint: PASS | Tests: 47/47 PASS
[finish:preflight] No merge conflicts with main
[finish:outcome]   Outcome: PR (default — no explicit merge request)
[finish:execute]   PR created: https://github.com/org/repo/pull/42
[finish:verify]    CI checks: pending
[finish:log]       Logged to .godmode/finish-results.tsv
```

## TSV Logging
File: `.godmode/finish-results.tsv`
Columns:
```
timestamp	branch	outcome	commits_squashed	files_changed	tests_result	guard_status	pr_url
```
Example row:
```
2026-03-20T14:30:00Z	feature/auth	PR	7	12	47/47	ALL_PASS	https://github.com/org/repo/pull/42
```

## Success Criteria
- [ ] Worktree is clean (no staged, unstaged, or untracked files that matter)
- [ ] All three guard checks (build, lint, test) pass before any merge/PR action
- [ ] Outcome is one of: MERGE, PR, KEEP, DISCARD — no partial states
- [ ] After MERGE: main passes build + test. If not, auto-reverted.
- [ ] After PR: PR URL is printed and reachable
- [ ] After DISCARD: branch no longer exists locally
- [ ] TSV row appended with all columns populated
- [ ] Final summary line printed with branch name, outcome, commit count, test results

## Error Recovery
- **If guard suite fails**: Do NOT proceed. Print which check failed and its output. Recommend `/godmode:fix`. Re-run `/godmode:finish` after fix completes.
- **If merge conflicts exist**: Print conflicting files. Recommend `git fetch origin main && git rebase origin/main`. After resolving, re-run `/godmode:finish`.
- **If `gh pr create` fails (no remote, auth issues)**: Fall back to printing the PR body to stdout. Print `FALLBACK: gh CLI unavailable. PR body printed above. Create PR manually.`
- **If post-merge tests fail on main**: Immediately `git revert HEAD --no-edit`. Print `ROLLBACK: Merge broke main. Reverted. Branch work was correct but integration failed. Debug the conflict.`
- **If branch has already been merged**: Detect via `git branch --merged main | grep {branch}`. Print `Branch {branch} already merged to main. Deleting stale branch.` Then `git branch -d {branch}`.

## Hard Rules
1. Never merge with failing tests — "tests are flaky" is not an excuse.
2. Never force-push main — use `git revert`, never `git reset --hard` on main.
3. Always `--squash` merge — one clean commit per feature on main.
4. Never skip post-merge verify — a merge that breaks main is worse than no merge.
5. Never delete a branch on DISCARD without explicit user confirmation.

## Completion Verification Protocol
```
FOR EACH dimension in [test_suite, coverage, docs, lint, pr_readiness, integration]:
  test_suite: Run full suite, compare vs main baseline, check new code has tests.
  coverage: Check overall >= target (80%), changed files >= 60%, no coverage drop > 2%.
  docs: Check API docs match routes, new exports documented, config docs updated.
  lint: Run lint + type check. Grep for TODO/FIXME/debugger in changed files.
  pr_readiness: Clean commits, rebased on main, diff < 400 lines.
  integration: Check merge conflicts, dependent packages, migration compatibility.

DECISION: ALL PASS → ship. ANY FAIL → block, fix first. WARN only → proceed with acknowledgment.
```
## Keep/Discard Discipline
```
After EACH finalization attempt:
  KEEP if: all guard checks pass AND outcome is one of MERGE/PR/KEEP/DISCARD
  DISCARD if: any guard check fails OR post-merge tests fail on main
  On discard: git revert HEAD (for merges) or re-run /godmode:fix. Log failure reason.
  Never merge a branch with failing guards.
```

## Stop Conditions
```
Loop until target or budget. Never ask to continue — loop autonomously.
On failure: git reset --hard HEAD~1.

STOP when FIRST of:
  - target_reached: branch finalized (MERGED, PR created, KEPT, or DISCARDED)
  - budget_exhausted: guard suite re-run 3 times with no improvement
  - diminishing_returns: same guard failure persists after /godmode:fix
  - stuck: >5 failed finalization attempts
```
