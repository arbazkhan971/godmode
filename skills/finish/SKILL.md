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

## Completion Verification Protocol

Systematic protocol ensuring all quality dimensions are met before a branch is considered truly finished:

```
COMPLETION VERIFICATION PROTOCOL:
current_iteration = 0
max_iterations = 6
verification_dimensions = [test_suite, coverage_threshold, docs_updated, lint_clean, pr_readiness, integration_check]

WHILE current_iteration < max_iterations:
  dimension = verification_dimensions[current_iteration]
  current_iteration += 1

  IF dimension == "test_suite":
    1. RUN full test suite:
       result = run({test_cmd})
       total_tests = parse test count from output
       passing_tests = parse passing count
       failing_tests = parse failing count
       skipped_tests = parse skipped count

    2. COMPARE against baseline:
       baseline_tests = count from main branch (git stash, run tests on main, restore)
       new_tests = total_tests - baseline_tests
       IF new_tests < 0: FAIL — "Tests were deleted. Verify this is intentional."

    3. VERIFY no regressions:
       IF failing_tests > 0: FAIL — "{N} tests failing. Fix before finishing."
       IF skipped_tests > baseline_skipped: WARN — "{N} new skipped tests. Verify intentional."

    4. VERIFY new code has tests:
       new_files = git diff --name-only main..HEAD --diff-filter=A | filter source files
       test_files = git diff --name-only main..HEAD --diff-filter=A | filter test files
       untested_files = new_files without corresponding test files
       IF untested_files is not empty: WARN — "{N} new source files without tests: {list}"

    5. SCORE:
       [ ] All tests pass: {YES/NO}
       [ ] No test regressions: {YES/NO}
       [ ] New code has tests: {YES/NO/PARTIAL}
       [ ] No new skips: {YES/NO}

  IF dimension == "coverage_threshold":
    1. RUN coverage measurement:
       IF coverage_cmd exists:
         result = run({coverage_cmd})
         overall_coverage = parse percentage
         file_coverages = parse per-file coverage

    2. CHECK thresholds:
       project_target = read from config (default: 80%)
       IF overall_coverage < project_target:
         WARN — "Coverage {overall_coverage}% is below target {project_target}%"

    3. CHECK coverage on changed files specifically:
       changed_files = git diff --name-only main..HEAD | filter source files
       FOR each changed_file:
         file_coverage = coverage for this specific file
         IF file_coverage < 60%:
           FAIL — "{file} has {coverage}% coverage (minimum: 60% for changed files)"

    4. CHECK coverage delta:
       previous_coverage = coverage on main branch
       delta = overall_coverage - previous_coverage
       IF delta < -2%: FAIL — "Coverage dropped by {delta}%. Add tests before finishing."
       IF delta < 0: WARN — "Coverage decreased slightly by {delta}%."
       IF delta > 0: PASS — "Coverage improved by +{delta}%."

    5. SCORE:
       [ ] Overall >= target: {YES/NO}
       [ ] Changed files >= 60%: {YES/NO}
       [ ] Coverage not decreased: {YES/NO}

  IF dimension == "docs_updated":
    1. DETECT if documentation updates are needed:
       changed_files = git diff --name-only main..HEAD

       needs_doc_update = FALSE
       reasons = []

       IF changed_files contains API route files:
         check if openapi.yaml or API docs were also updated
         IF NOT: needs_doc_update = TRUE; reasons.append("API routes changed but API docs not updated")

       IF changed_files contains new public exports:
         check if JSDoc/docstrings were added
         IF NOT: needs_doc_update = TRUE; reasons.append("New public exports without documentation")

       IF changed_files contains config changes:
         check if .env.example or config docs were updated
         IF NOT: needs_doc_update = TRUE; reasons.append("Config changed but docs not updated")

       IF changed_files contains database migrations:
         check if schema docs or data model docs were updated
         IF NOT: needs_doc_update = TRUE; reasons.append("Schema changed but model docs not updated")

    2. CHECK README freshness:
       IF significant feature added (>100 lines, new entry point):
         check if README.md was modified in this branch
         IF NOT: WARN — "Significant feature added. Update README."

    3. SCORE:
       [ ] API docs match code: {YES/NO/N/A}
       [ ] New exports documented: {YES/NO/N/A}
       [ ] Config docs updated: {YES/NO/N/A}
       [ ] README current: {YES/NO/N/A}

  IF dimension == "lint_clean":
    1. RUN full lint suite:
       lint_result = run({lint_cmd})
       IF lint fails: FAIL — "Fix lint errors before finishing."

    2. RUN type check (if applicable):
       typecheck_result = run({typecheck_cmd})
       IF typecheck fails: FAIL — "Fix type errors before finishing."

    3. CHECK for code quality signals:
       - grep for TODO/FIXME/HACK/XXX in changed files
       - grep for console.log/print/debugger in changed files
       - grep for commented-out code blocks in changed files

    4. SCORE:
       [ ] Lint passes: {YES/NO}
       [ ] Type check passes: {YES/NO/N/A}
       [ ] No debug statements: {YES/NO}
       [ ] No TODO/FIXME in new code: {YES/NO}

  IF dimension == "pr_readiness":
    1. CHECK PR metadata readiness:
       [ ] Branch has descriptive name (matches convention)
       [ ] Commits are clean (no WIP, fixup, or merge commits)
       [ ] Commit messages follow convention
       [ ] Branch is rebased on latest main (no conflicts)
       [ ] Diff size is within limits (< 400 lines preferred)

    2. IF commits need cleanup:
       RECOMMEND: "Run interactive rebase to clean up {N} WIP commits before PR."
       PROVIDE: exact rebase command

    3. IF branch is behind main:
       RECOMMEND: "Rebase onto latest main: git fetch origin main && git rebase origin/main"

    4. GENERATE PR readiness summary:
       PR READINESS:
| Check | Status |
|---|---|
| Branch naming convention | OK/FAIL |
| Clean commit history | OK/FAIL |
| Commit message convention | OK/FAIL |
| Rebased on latest main | OK/FAIL |
| Diff size within limits | OK/WARN |

  IF dimension == "integration_check":
    1. CHECK for integration issues:
       a. Fetch latest main and check for conflicts:
          git fetch origin main
          conflict_check = git merge-tree $(git merge-base HEAD origin/main) origin/main HEAD
          IF conflicts: WARN — "Merge conflicts detected. Resolve before finishing."

       b. Check if dependent services/packages still work:
          IF monorepo: run tests in dependent packages
          IF microservice: check API contract compatibility

       c. Check migration compatibility:
          IF database changes present:
            verify migration applies cleanly on main's schema
            verify rollback works
            verify application starts with migrated schema

    2. SCORE:
       [ ] No merge conflicts: {YES/NO}
       [ ] Dependent packages pass: {YES/NO/N/A}
       [ ] Migrations clean: {YES/NO/N/A}

  REPORT: "Dimension {current_iteration}/{max_iterations}: {dimension} — {PASS | FAIL | WARN}"

FINAL COMPLETION VERIFICATION:
  COMPLETION VERIFICATION SUMMARY
| Dimension | Status | Details |
|---|---|---|
| Test suite | PASS | 112/112 pass, +8 new |
| Coverage threshold | PASS | 84% (+2% vs main) |
| Docs updated | WARN | API docs need update |
| Lint clean | PASS | 0 errors, 0 warnings |
| PR readiness | PASS | Clean commits, rebased |
| Integration check | PASS | No conflicts, migration OK |
| Overall | READY | 1 warning (docs) |
| Recommendation |  | Update API docs, then ship |

DECISION:
  IF all PASS: → proceed to /godmode:ship or /godmode:finish (PR/merge)
  IF any FAIL: → BLOCK. Fix failures first, re-run verification.
  IF only WARN: → proceed with acknowledgment. Warnings logged.
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
STOP when FIRST of:
  - target_reached: branch finalized (MERGED, PR created, KEPT, or DISCARDED)
  - budget_exhausted: guard suite re-run 3 times with no improvement
  - diminishing_returns: same guard failure persists after /godmode:fix
  - stuck: >5 failed finalization attempts
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
This skill does not dispatch parallel agents, so no sequential translation is needed.
All commands (`git`, `gh`, `build_cmd`, `test_cmd`) run in the current session.
If `gh` CLI is unavailable: skip PR creation and print the PR body to stdout for manual creation.
See `adapters/shared/sequential-dispatch.md` for the general protocol.
