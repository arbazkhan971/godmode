---
name: fix
description: |
  Autonomous error fixing. Loops until zero errors remain. One fix per commit, auto-revert on regression.
---

# Fix — Autonomous Error Remediation

## Activate When
- `/godmode:fix`, "fix this", "tests failing", "fix errors"
- Debug skill completes with root cause
- Build produces failures

## The Loop
```
error_count = run_all_checks()  # tests + lint + types
original_count = error_count
current_iteration = 0
WHILE error_count > 0:
    current_iteration += 1
    # 1. INVENTORY — run tests + lint + types, count errors
    # 2. PICK highest priority: types > lint > tests
    # 3. ANALYZE — read error + code at location, form hypothesis
    # 4. FIX — minimum change for ONE error
    # 5. COMMIT — git commit -m "fix: {description}" BEFORE verify
    # 6. VERIFY:
    new_count = run_all_checks()
    IF new_count > error_count:
        git reset --hard HEAD~1  # revert regression, retry (max 3 per error)
    ELSE: error_count = new_count
    # 7. LOG to .godmode/fix-log.tsv
    # 8. STATUS every 5 iters: "Fix iter {N}: {error_count} remaining (from {original})"
Print: "Fix complete: {original} → 0 errors in {N} iterations"
```

## Priority
Types first (cascade fixes). Lint second (`--fix` when available). Tests last (one at a time + regression test).

## Rules
1. Loop until zero. Don't stop after one fix.
2. One fix per commit. Commit before verify. Rollback = `git reset --hard HEAD~1`.
3. Auto-revert on regression. New errors -> revert -> re-analyze.
4. Max 3 attempts per error. Then flag for human, move on.
5. Never modify tests to make code pass.
6. Regression test for every bug fix. Type/lint exempt.
