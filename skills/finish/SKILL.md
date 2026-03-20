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

## Anti-Patterns
1. **Never merge with failing tests.** "Tests are flaky" is not an excuse. Fix or skip the flaky test explicitly before merging.
2. **Never force-push main.** Use `git revert`, never `git reset --hard` on main after a bad merge.
3. **Never create merge commits.** Always `--squash`. One clean commit per feature on main.
4. **Never skip the post-merge verify.** A merge that breaks main is worse than no merge at all.
5. **Never delete a branch without confirmation for DISCARD.** MERGE and PR can auto-delete because the work is preserved. DISCARD is destructive.

## Examples

### Example 1: Clean PR creation
```
> /godmode:finish

[finish:snapshot]  Branch: feature/user-search | 4 commits ahead of main | 6 files changed
[finish:worktree]  Clean worktree confirmed
[finish:guard]     Build: PASS (0.9s) | Lint: PASS (0.4s) | Tests: 112/112 PASS (4.2s)
[finish:preflight] No merge conflicts with main
[finish:outcome]   Outcome: PR (default)
[finish:execute]   PR created: https://github.com/acme/app/pull/87
[finish:log]       Logged to .godmode/finish-results.tsv

Branch feature/user-search: PR. 4 commits squashed. Tests: 112/112. Guard: ALL PASS.
```

### Example 2: Squash merge with post-verify
```
> /godmode:finish merge

[finish:snapshot]  Branch: fix/null-pointer | 2 commits ahead of main | 3 files changed
[finish:worktree]  Clean worktree confirmed
[finish:guard]     Build: PASS | Lint: PASS | Tests: 89/89 PASS
[finish:preflight] No merge conflicts with main
[finish:outcome]   Outcome: MERGE (user requested)
[finish:execute]   MERGED: fix/null-pointer → main (squash). 2 commits → 1. Branch deleted.
[finish:verify]    Post-merge: Build PASS | Tests 89/89 PASS
[finish:log]       Logged to .godmode/finish-results.tsv

Branch fix/null-pointer: MERGE. 2 commits squashed. Tests: 89/89. Guard: ALL PASS.
```

### Example 3: Guard failure blocks finish
```
> /godmode:finish

[finish:snapshot]  Branch: feature/payments | 11 commits ahead of main | 22 files changed
[finish:worktree]  Clean worktree confirmed
[finish:guard]     Build: PASS | Lint: FAIL (3 errors) | Tests: SKIPPED (lint failed)

Guard failed: lint. Run /godmode:fix first.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
This skill does not dispatch parallel agents, so no sequential translation is needed.
All commands (`git`, `gh`, `build_cmd`, `test_cmd`) run in the current session.
If `gh` CLI is unavailable: skip PR creation and print the PR body to stdout for manual creation.
See `adapters/shared/sequential-dispatch.md` for the general protocol.
