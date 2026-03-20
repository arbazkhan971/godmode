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
    # 2. ANALYZE — read FULL error output (all lines, not just first). Read source at error file:line ±10 lines. Name the mismatch.
    # 3. FIX — change ≤5 lines for ONE error. Fix the cause, not the symptom. No workarounds.
    # 4. COMMIT `fix({module}): {description}` BEFORE verify
    # 5. VERIFY: new_count = run_all_checks()
    IF new_count >= error_count: `git reset --hard HEAD~1`. Max 3 attempts per error, then skip + log to skipped_list.
    ELSE: error_count = new_count
    # 6. LOG to .godmode/fix-log.tsv: iteration, error, file, fix_description, status(kept/reverted)
    # 7. STATUS every 5: "{error_count} remaining (from {original})"
Print: `Fixed: {original} → {error_count} in {N} iters. Skipped: {skipped_list}`. If skipped > 0 → `/godmode:debug`.
```

## Rules
1. Loop until zero errors. One fix per commit.
2. Max 3 attempts per error. Skip and move to next. Print skipped errors at end.
3. Never modify tests. Never suppress with try/catch or `// @ts-ignore`. Every fix gets a regression test in same commit.
