---
name: finish
description: |
  Branch finalization. Validate, squash-merge, PR,
  keep, or discard. Clean state enforced.
  Triggers on: /godmode:finish, "done with branch",
  "merge this", "finalize", "wrap up".
---

## Activate When
- `/godmode:finish`, "done", "merge", "finalize"
- Feature branch has commits ahead of main
- Another skill completes and branch is ready

## Auto-Detection
Routes here when:
- `git log main..HEAD --oneline` returns 1+ commits
  AND user says "done", "merge", "finish"
- `/godmode:build` completes all tasks
- User explicitly invokes `/godmode:finish`

## Workflow

### 1. Snapshot Branch State

```bash
branch=$(git branch --show-current)
commits=$(git log main..HEAD --oneline | wc -l | tr -d ' ')
files_changed=$(git diff main..HEAD --stat | tail -1)
echo "Branch: $branch | $commits commits | $files_changed"

# Check if on main
if [ "$branch" = "main" ]; then
  echo "ERROR: Already on main. Nothing to finish."
  exit 1
fi
```

### 2. Enforce Clean Worktree

```bash
staged=$(git diff --cached --name-only)
unstaged=$(git diff --name-only)
untracked=$(git ls-files --others --exclude-standard)
```

```
IF staged non-empty: STOP — commit or stash first
IF unstaged non-empty: STOP — commit, stash, or discard
IF untracked files: WARN — won't be in merge
```

### 3. Run Full Guard Suite

```bash
build_cmd && lint_cmd && test_cmd
```

```
THRESHOLDS:
  Build: must exit 0
  Lint: must exit 0 with --max-warnings=0
  Tests: 100% pass rate required
  IF any failure: STOP, run /godmode:fix first
  IF no test runner: WARN, continue
```

### 4. Check Merge Conflicts

```bash
git fetch origin main
git merge-tree \
  $(git merge-base HEAD origin/main) origin/main HEAD
```

IF conflicts: print files, recommend rebase.

### 5. Determine Outcome

```
PRIORITY (first match wins):
  DISCARD: user says "discard", "abandon" (confirm)
  KEEP: user says "keep", "not yet", "park it"
  MERGE: user says "merge" OR PR approved
  PR: default when checks pass
```

### 6. Execute Outcome

**MERGE:**
```bash
git checkout main && git pull origin main
git merge --squash {branch}
git commit -m "feat({module}): {title}

Squashed {N} commits from {branch}."
git branch -d {branch}
```

**PR:**
```bash
gh pr create --title "feat({module}): {title}" \
  --body "## Changes
$(git log main..HEAD --format='- %s')

## Guard Results
Build: PASS | Lint: PASS | Tests: PASS"
```

**DISCARD:** Require confirmation, then `git branch -D`.

### 7. Post-Finalization Verify

```
IF MERGE: run build+test on main.
  IF fails: git revert HEAD immediately.
IF PR: watch CI checks with gh pr checks.
IF DISCARD: verify branch is gone.
```

### 8. Log Result
Append to `.godmode/finish-results.tsv`.

## Output Format
```
[finish:snapshot]  Branch: {branch} | {N} commits
[finish:worktree]  Clean worktree confirmed
[finish:guard]     Build: PASS | Lint: PASS | Tests: PASS
[finish:preflight] No merge conflicts
[finish:outcome]   Outcome: {PR|MERGE|KEEP|DISCARD}
[finish:execute]   {result URL or status}
[finish:verify]    {verification result}
```

## TSV Logging
```
timestamp	branch	outcome	commits_squashed	files_changed	tests_result	guard_status	pr_url
```

## Completion Verification Protocol
```
FOR EACH dimension in [tests, coverage, lint, pr]:
  tests: full suite pass, new code has tests
  coverage: overall >= 80%, changed files >= 60%
  lint: zero violations, no TODO/FIXME in diff
  pr: rebased on main, diff < 400 lines

DECISION: ALL PASS → ship. ANY FAIL → block.
```

## Quality Targets
- Pre-merge checks: >99% passing rate
- CI pipeline: <5min full completion
- TODO/FIXME density: <1 per 1000 lines committed

## Hard Rules
1. Never merge with failing tests.
2. Never force-push main — use git revert.
3. Always squash merge — one commit per feature.
4. Never skip post-merge verify.
5. Never delete branch on DISCARD without confirmation.

## Keep/Discard Discipline
```
KEEP if: all guard checks pass AND outcome valid
DISCARD if: guard fails OR post-merge tests fail
On discard: git revert HEAD for merges.
```

## Stop Conditions
```
STOP when FIRST of:
  - Branch finalized (MERGED, PR, KEPT, DISCARDED)
  - Guard suite re-run 3 times with no improvement
  - > 5 failed finalization attempts
```

## Error Recovery
- Guard fails: do not proceed, run /godmode:fix.
- Merge conflicts: fetch, rebase, resolve, re-finish.
- gh CLI fails: print PR body to stdout as fallback.
- Post-merge tests fail: git revert HEAD immediately.
- Branch already merged: detect, delete stale branch.
