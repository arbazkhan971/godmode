---
name: debug
description: |
  Scientific debugging. Reproduce -> investigate -> prove root cause with evidence. Finds ALL bugs, not just one.
---

# Debug — Scientific Bug Investigation

## Activate When
- `/godmode:debug`, "why is this happening?", "this doesn't work"
- Stack trace or error message in conversation
- Tests failing with unclear reasons

## The Loop
```
failing_count = run_tests()
current_iteration = 0

WHILE failing_count > 0:
    current_iteration += 1

    # 1. REPRODUCE — run failing command, observe output
    # 2. SELECT TECHNIQUE by signal:
         Stack trace → Trace Analysis | "Used to work" → git bisect
         Intermittent → State Inspection + logging | Wrong results → State Inspection
         Unknown → Binary Search (eliminate half)
    # 3. INVESTIGATE — follow technique, collect evidence
    # 4. PROVE ROOT CAUSE — must have file:line + data evidence + reproduce command. Vague guesses rejected.
    # 5. FIX if trivial, else hand off to /godmode:fix
    # 6. VERIFY — re-run tests
    # 7. LOG to .godmode/debug-findings.tsv:
         iteration  bug  file  line  root_cause  technique  fix  commit
    # 8. STATUS every 3 bugs: "Debug iter {N}: {found} found, {failing_count} remaining"

    failing_count = run_tests()
```

## Techniques
Binary Search/bisect (breaking commit), Minimal Reproduction (strip until gone), Trace Analysis (stack bottom-to-top),
State Inspection (actual vs expected at checkpoints), Dependency Isolation (mock externals), Diff Analysis (git diff review), Rubber Duck (line-by-line explain).

## Root Cause Chain
Every bug: Symptom -> Proximate -> Root cause -> Fix (file:line + change).

## Rules
1. Reproduce first. Never investigate unseen bugs.
2. Evidence, not intuition. Every root cause needs file:line + data proof.
3. One bug at a time. Note others, finish current first.
4. Don't fix during debug. Exception: trivial one-liners.
5. Loop until all bugs found.
