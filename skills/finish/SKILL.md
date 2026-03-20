---
name: finish
description: Branch finalization. Merge, PR, keep, or discard.
---

## Activate When
- `/godmode:finish`, "done with branch", "merge", "clean up"

## Workflow
### 1. Pre-Check
Run: `git diff --cached` (nothing staged?), `git status` (clean?), `test_cmd`, `lint_cmd`. Any failure → `/godmode:fix`.
### 2. Choose Outcome
- **MERGE:** `git checkout main && git merge --squash {branch} && git commit -m "feat: {title}"`, then `git branch -d {branch}`
- **PR:** `gh pr create --title '{feature}' --body "$(git log main..HEAD --format='- %s')"`
- **KEEP:** branch stays for later
- **DISCARD:** delete branch (confirm first — destructive)
Auto: tests pass + reviewed → MERGE. Tests pass + unreviewed → PR. Dirty worktree → KEEP. User confirms abandon → DISCARD.
### 3. Post-Finalization
Log to `.godmode/session-log.tsv`. Print: `"Branch {name}: {outcome}. Commits: {N}. Tests: {pass}/{total}."`.

## Rules
1. Clean state before finalize. `git status` must show nothing to commit. All tests must pass.
2. Squash-merge: one commit per feature on main. Never `git branch -D`. Never merge with failing tests.
3. PR body auto-generated from `git log main..HEAD --format='- %s'`. No manual summaries.
