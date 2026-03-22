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
skipped = 0

WHILE failing_count > 0 AND skipped < 3:
    current_iteration += 1
    bug = pick_highest_severity(remaining_bugs)
    technique_index = 0
    techniques = [stack_trace, git_bisect, state_inspection, binary_search]

    # 1. REPRODUCE — run failing command 3x. Consistent failure = real bug. Intermittent = add to flaky list.
    # 2. SELECT TECHNIQUE (max 5 min each):
         Stack trace → Trace Analysis | "Used to work" → `git bisect` | Regression → `git log -20`
         Intermittent/Wrong results → State Inspection | Unknown → Binary Search (eliminate half)
    # 3. INVESTIGATE — insert print/log at suspect file:line. Log: variable name=value, caller, actual vs expected.
    # 4. PROVE — state: "Bug is at {file}:{line} because {variable}={actual}, expected {expected}. Reproduce: {cmd}."
         Chain: Symptom → Why? → Why? → Root cause → Fix (file:line + diff). Min 3 'why's.
    #    Root cause found → KEEP (fix or hand off)
    #    Root cause NOT found → try next technique (step 2)
    #    All techniques exhausted → DISCARD bug (skip++), log reason_stuck + root_cause_unknown
    # 5. FIX OR HAND OFF — see Fix Handoff Protocol below
    # 6. VERIFY — re-run failing test. Then run full suite to check for regressions.
    # 7. APPEND .godmode/debug-findings.tsv: iteration, bug_id, symptom, root_cause, file:line, fix_commit, status(fixed/skipped), reason_stuck
    # 8. STATUS every 3: "{found} found, {failing_count} remaining, {skipped} skipped"
    failing_count = run_tests()

IF skipped >= 3: STOP, report partial results
```

## Stuck Criteria
```
IF stuck >3 iterations on same bug:
  → Discard bug, move to next
  → Log: bug_id, reason_stuck, root_cause_unknown, skipped=true
  → Max skipped bugs: 3. After 3 skipped → stop, report partial
```

## Timeout Per Technique
```
Max 5 min per technique:
  - Stack trace: read stderr, follow call chain once
  - git bisect: binary search to <10 commits, then manual
  - State inspection: add 1-3 logs, reproduce 3x
If >5 min without progress → abandon technique, try next
```

## Fix Handoff Protocol
```
After proving root cause at file:line:
  IF one-line fix: fix it, verify, commit, log
  ELSE: call /godmode:fix with proven root cause as context

Hand off SPECIFIC: "Null user.id at src/auth/login.ts:42 when session expires mid-request"
NOT vague: "auth is broken"
```

## Output Format
Print: `Debug: {found} bugs found, {fixed} fixed, {remaining} remaining in {N} iterations. Skipped: {skipped_list}.`

## Rules
1. Reproduce before investigating. No reproduce = no bug. Run the code, read stdout+stderr, paste the output.
2. Evidence: file:line + actual vs expected values + reproduce command. Found root cause → `/godmode:fix`.
3. One bug at a time. Don't fix during debug (one-line fixes excepted). If stuck 3 iterations on same bug, skip it.
4. Max 5 min per technique. No progress → abandon technique, try next. All techniques exhausted → discard bug.
5. Hand off specific root causes, not vague descriptions. Include file:line, variable state, and reproduce steps.
