---
name: finish
description: Branch finalization. Merge, PR, keep, or discard.
---

## Activate When
- `/godmode:finish`, "done with branch", "merge", "clean up"

## Workflow
### 1. Pre-Check
Run: `git status` (clean?), `test_cmd` (pass?), `lint_cmd` (pass?). Any failure → `/godmode:fix` first.
### 2. Choose Outcome
- **MERGE:** `git checkout main && git merge --squash {branch} && git commit -m "feat: {title}"`, then `git branch -d {branch}`
- **PR:** `gh pr create --title '{feature}' --body "$(git log main..HEAD --format='- %s')"`
- **KEEP:** branch stays for later
- **DISCARD:** delete branch (confirm first — destructive)
Auto-decide: tests pass + `/godmode:review` done → MERGE. Tests pass + unreviewed → PR. Uncommitted changes → KEEP. User says abandon → DISCARD.
### 3. Post-Finalization
Log to `.godmode/session-log.tsv`. Print: `"Branch {name}: {outcome}. Commits: {N}. Tests: {pass}/{total}."`.

## Rules
1. Clean state before finalize. No uncommitted changes, tests must pass.
2. One commit per feature on main (squash-merge). Never force-delete. Never merge with failing tests.
3. PR body auto-generated from `git log`. No manual summaries.
