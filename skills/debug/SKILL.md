---
name: debug
description: Scientific debugging. Reproduce → investigate → prove root cause. Finds all bugs.
---

## Activate When
- `/godmode:debug`, "why is this happening?", "this doesn't work"

## The Loop
```
failing_count = run_tests()  # test_cmd (from stack detection), count failures
current_iteration = 0
WHILE failing_count > 0:
    current_iteration += 1
    # 1. REPRODUCE — run failing command 3x. Consistent failure = real bug. Intermittent = add to flaky list.
    # 2. SELECT TECHNIQUE:
         Stack trace → Trace Analysis | "Used to work" → `git bisect` | Regression → `git log -20`
         Intermittent/Wrong results → State Inspection | Unknown → Binary Search (eliminate half)
    # 3. INVESTIGATE — add logging/prints at suspect points. Collect: variable values, call stack, actual vs expected.
    # 4. PROVE — file:line + data evidence + reproduce cmd. Guesses rejected.
         Chain: Symptom → Why? → Why? → Root cause → Fix (file:line + diff). Min 3 'why's.
    # 5. FIX if one-line change, else → `/godmode:fix` with root cause from step 4
    # 6. VERIFY — re-run failing test. Then run full suite to check for regressions.
    # 7. LOG to .godmode/debug-findings.tsv: iteration, symptom, root_cause, file:line, status(fixed/skipped)
    # 8. STATUS every 3: "{found} found, {failing_count} remaining"
    failing_count = run_tests()
```

## Rules
1. Reproduce first. Never investigate unseen bugs. Never guess — run the code and read the output.
2. Evidence required: file:line + data proof + reproduce command. No guesses.
3. One bug at a time. Don't fix during debug (one-line fixes excepted). If stuck 3 iterations on same bug, skip it.
