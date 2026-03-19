---
name: fix
description: Fix loop. One fix per commit, auto-revert on regression, until zero errors.
---

# Fix — Autonomous Error Remediation

## Activate When
- `/godmode:fix`, "fix this", "tests failing", "fix errors"

## The Loop
```
error_count = run_all_checks()  # tests + lint + types
original = error_count
current_iteration = 0
WHILE error_count > 0:
    current_iteration += 1
    # 1. PICK highest priority: types > lint > tests (cascading fixes)
    # 2. ANALYZE — read error + code, form hypothesis
    # 3. FIX — minimum change for ONE error
    # 4. COMMIT "fix: {description}" BEFORE verify
    # 5. VERIFY: new_count = run_all_checks()
    IF new_count > error_count: git reset --hard HEAD~1 (max 3 retries)
    ELSE: error_count = new_count
    # 6. LOG to .godmode/fix-log.tsv
    # 7. STATUS every 5: "{error_count} remaining (from {original})"
Print: "{original} → 0 in {N} iterations"
```

## Rules
1. Loop until zero. Don't stop after one fix.
2. One fix per commit. Commit before verify. Revert on regression.
3. Max 3 attempts per error. Then flag for human, move on.
4. Never modify tests to make code pass.
5. Regression test for every bug fix.
