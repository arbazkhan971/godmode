---
name: finish
description: |
  Branch finalization. Merge, PR, keep, or discard. Ensures clean state.
---

# Finish — Branch Finalization

## Activate When
- `/godmode:finish`, "done with branch", "merge", "clean up"
- After ship phase

## Workflow

### 1. Pre-Check
```bash
git status          # clean working tree?
git diff --stat     # uncommitted changes?
<test_cmd>          # all tests pass?
<lint_cmd>          # no lint errors?
```
If anything fails → fix first, don't finalize broken code.

### 2. Choose Outcome

```
MERGE:   git checkout main && git merge --squash {branch} && git commit && git branch -d {branch}
PR:      gh pr create --title "{title}" --body "{body}"
KEEP:    do nothing, branch stays for later
DISCARD: git checkout main && git branch -D {branch}
```

**Decision tree:**
- Tests pass + reviewed → MERGE or PR
- Tests pass + not reviewed → PR
- Work in progress → KEEP
- Abandoned experiment → DISCARD

### 3. Post-Finalization
- Log to `.godmode/session-log.tsv`
- Print: `"Branch {name}: {outcome}"`

## Rules

1. **Clean state before finalize.** No uncommitted changes. Tests must pass.
2. **Squash-merge for clean history.** One commit per feature on main.
3. **Never force-delete without confirmation.** DISCARD is destructive.
4. **PR body from git log.** Auto-generate from commit history.
