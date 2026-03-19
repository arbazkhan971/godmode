---
name: debug
description: |
  Scientific debugging. Reproduce → investigate → prove root cause with evidence. Finds ALL bugs, not just one.
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

    # 1. REPRODUCE — run the failing command, observe output yourself
    # 2. SELECT TECHNIQUE (auto, based on signal):
         Stack trace available    → Trace Analysis
         "It used to work"       → git bisect
         Intermittent            → State Inspection + logging
         Wrong results           → State Inspection (expected vs actual at each step)
         Unknown                 → Binary Search (eliminate half the code)
    # 3. INVESTIGATE — follow the technique, collect evidence
    # 4. PROVE ROOT CAUSE:
         MUST have: file:line, data evidence (actual vs expected), reproduce command
         "I think it's in auth.ts" → NOT ACCEPTABLE
         "auth.ts:47 — req.user undefined, JWT middleware missing from chain" → ACCEPTABLE
    # 5. FIX (if trivial) or hand off to /godmode:fix
    # 6. VERIFY — re-run tests, confirm fix works
    # 7. LOG to .godmode/debug-findings.tsv:
         iteration  bug  file  line  root_cause  technique  fix  commit
    # 8. STATUS every 3 bugs:
         "Debug iter {N}: {found} bugs found, {failing_count} remaining"

    failing_count = run_tests()
```

## The 7 Techniques

1. **Binary Search (git bisect)** — find the breaking commit
2. **Minimal Reproduction** — strip components until bug disappears
3. **Trace Analysis** — read stack trace bottom-to-top, log at decision points
4. **State Inspection** — dump actual state at checkpoints, compare to expected
5. **Dependency Isolation** — mock externals one at a time
6. **Diff Analysis** — `git diff HEAD~5..HEAD`, review each change
7. **Rubber Duck** — read code line by line, explain each line's state

## Root Cause Chain

Every bug must have a full chain:
```
Symptom:    → what the user sees
Proximate:  → the immediate technical failure
Root cause: → the underlying reason
Fix:        → exact file:line and change needed
```

## Rules

1. **Reproduce first.** Never investigate a bug you haven't seen yourself.
2. **Evidence, not intuition.** Every root cause needs file:line + data proof.
3. **One bug at a time.** Find second bugs? Note them, finish the first.
4. **Don't fix during debug.** Debug FINDS. Fix FIXES. (Exception: trivial one-liners.)
5. **Loop until all bugs found.** Don't stop at one.
