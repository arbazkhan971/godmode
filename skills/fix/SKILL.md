---
name: fix
description: Fix loop. One fix per commit, auto-revert on regression, until zero errors.
---

## Activate When
- `/godmode:fix`, "fix this", "tests failing", "fix errors"

## The Loop
```
error_count = run_all_checks()  # build_cmd + lint_cmd + test_cmd (build first — can't lint/test broken code)
original = error_count
current_iteration = 0
WHILE error_count > 0:
    current_iteration += 1
    # 1. PICK: build errors > type errors > lint > test failures (each layer unblocks the next)
    # 2. ANALYZE — read FULL error message (not just first line) + surrounding code (±10 lines). Identify the exact mismatch.
    # 3. FIX — smallest change for ONE error. Prefer fixing root cause over suppressing symptoms.
    # 4. COMMIT `fix({module}): {description}` BEFORE verify
    # 5. VERIFY: new_count = run_all_checks()
    IF new_count > error_count: git reset --hard HEAD~1 (max 3, then skip this error, move to next)
    ELSE: error_count = new_count
    # 6. LOG to .godmode/fix-log.tsv: iteration, error, file, fix_description, status(kept/reverted)
    # 7. STATUS every 5: "{error_count} remaining (from {original})"
Print: "Fixed: {original} → {error_count} errors in {N} iterations. Skipped: {skipped_list}"
```

## Rules
1. Loop until zero errors. One fix per commit.
2. Max 3 attempts per error. Skip and move to next. Print skipped errors at end.
3. Never modify tests to make them pass. Never suppress errors with try/catch. Add regression test for every fix.
