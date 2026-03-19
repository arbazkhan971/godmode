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
    # 2. PICK — highest priority error (types first, then tests, then lint)
    # 3. ANALYZE — read error, read code at location, form hypothesis
    # 4. FIX — minimum change to fix ONE error
    # 5. COMMIT — git commit -m "fix: {description}" BEFORE verify
    # 6. VERIFY — run all checks again
    new_count = run_all_checks()
    IF new_count > error_count:
        git reset --hard HEAD~1  # fix introduced regression
        Try different approach (max 3 attempts per error)
    ELSE:
        error_count = new_count
    # 7. LOG to .godmode/fix-log.tsv
    # 8. STATUS every 5 iterations:
    IF current_iteration % 5 == 0:
        "Fix iter {N}: {error_count} remaining (from {original})"

Print: "Fix complete: {original} → 0 errors in {N} iterations"
```

## Priority Order

1. **Type errors** — fix first, they cascade (fixing types often fixes tests)
2. **Lint errors** — use `--fix` auto-fix when available
3. **Test failures** — one at a time, add regression test for each

## Rules

1. **Loop until zero.** Don't stop after one fix. Don't ask.
2. **One fix per commit.** If you fix two things, you can't revert one.
3. **Commit before verify.** Rollback = `git reset --hard HEAD~1`.
4. **Auto-revert on regression.** New errors → revert → re-analyze.
5. **Max 3 attempts per error.** After 3 failures, flag for human review, move on.
6. **Never modify tests to make code pass.** Fix the code.
7. **Regression test for every bug fix.** Type/lint errors exempt.
