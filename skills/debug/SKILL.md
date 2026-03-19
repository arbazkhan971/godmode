---
name: debug
description: Scientific debugging. Reproduce → investigate → prove root cause. Finds all bugs.
---

## Activate When
- `/godmode:debug`, "why is this happening?", "this doesn't work"

## The Loop
```
failing_count = run_tests()
current_iteration = 0
WHILE failing_count > 0:
    current_iteration += 1
    # 1. REPRODUCE — run failing command, observe output
    # 2. SELECT TECHNIQUE:
         Stack trace → Trace Analysis | "Used to work" → git bisect
         Intermittent → State Inspection | Wrong results → State Inspection
         Unknown → Binary Search (eliminate half)
    # 3. INVESTIGATE — collect evidence using technique
    # 4. PROVE — file:line + data evidence + reproduce cmd. Guesses rejected.
         Chain: Symptom → Proximate → Root cause → Fix (file:line + change)
    # 5. FIX if trivial, else → /godmode:fix
    # 6. VERIFY — re-run tests
    # 7. LOG to .godmode/debug-findings.tsv
    # 8. STATUS every 3: "{found} found, {failing_count} remaining"
    failing_count = run_tests()
```

## Rules
1. Reproduce first. Never investigate unseen bugs.
2. Evidence required: file:line + data proof. No guesses.
3. One bug at a time. Don't fix during debug (trivial one-liners excepted).
