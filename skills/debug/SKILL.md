---
name: debug
description: Scientific debugging. Reproduce → investigate → prove root cause. Finds all bugs.
---

## Activate When
- `/godmode:debug`, "why is this happening?", "this doesn't work"

## Lessons Integration

Before investigation: read `.godmode/lessons.md` for known root causes and debugging shortcuts.
After session: append lessons about root cause patterns discovered.

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

## Reflective Diagnosis on Stuck
```
On 3+ iterations without finding root cause:
  Read all attempted techniques and their outputs.
  Write diagnosis: "Techniques X, Y, Z all assume {wrong assumption}.
  The actual constraint is {insight}."
  Use diagnosis to select the next technique.
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

## Keep/Discard Discipline
```
After EACH bug investigation:
  KEEP if: root cause proven with file:line + actual vs expected values
  DISCARD if: root cause not found after all techniques exhausted
  On discard: log bug as skipped with reason_stuck. Move to next bug.
  Never keep an unproven hypothesis as a root cause.
```

## Stop Conditions
```
Loop until target or budget. Never ask to continue — loop autonomously.
On failure: git reset --hard HEAD~1.

STOP when FIRST of:
  - target_reached: failing_count == 0 (all bugs fixed or handed off)
  - budget_exhausted: max iterations reached
  - diminishing_returns: 3 consecutive bugs produce no fix
  - stuck: >5 skipped bugs (skipped >= 3 already triggers stop)
```

## Hard Rules
1. Reproduce before investigating — no reproduce = no bug. Run the code, read stdout+stderr.
2. Evidence required: file:line + actual vs expected values + reproduce command.
3. One bug at a time. If stuck 3 iterations on same bug, skip it and move on.
4. Max 5 min per technique. All techniques exhausted on a bug = discard it.
5. Hand off specific root causes to `/godmode:fix`, not vague descriptions.

```bash
# Common debug commands
npm test 2>&1 | tail -20
git bisect start HEAD HEAD~20
git log --oneline -10
```

IF test failures > 10: prioritize by severity, fix critical first.
WHEN intermittent failure (< 50% reproduce rate): add to flaky list.
IF stuck > 3 iterations on one bug: skip, move to next.

## Workflow
1. Run `test_cmd`, count failures — this is the starting bug count.
2. Pick highest-severity bug, reproduce it 3x to confirm it is real (not flaky).
3. Select investigation technique: stack trace, git bisect, state inspection, or binary search.
4. Prove root cause with "5 whys" chain — minimum 3 levels. State file:line, actual vs expected.
5. Hand off to `/godmode:fix` or apply one-line fix. Verify by re-running failing test + full suite.

## Rules
1. Reproduce before investigating. No reproduce = no bug. Run the code, read stdout+stderr, paste the output.
2. Evidence: file:line + actual vs expected values + reproduce command. Found root cause → `/godmode:fix`.
3. One bug at a time. Don't fix during debug (one-line fixes excepted). If stuck 3 iterations on same bug, skip it.
4. Max 5 min per technique. No progress → abandon technique, try next. All techniques exhausted → discard bug.
5. Hand off specific root causes, not vague descriptions. Include file:line, variable state, and reproduce steps.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Cannot reproduce the bug | Run failing command 3x. If intermittent, add to flaky list with timestamp and environment details. Move to next bug. |
| `git bisect` fails (no good commit) | Fall back to `git log -20` manual inspection. Check for config or environment drift rather than code changes. |
| Debug logs produce no useful output | Increase log granularity — log variable values, not only "reached here". Add caller info and stack depth. |
| Root cause spans multiple files | Use the "5 whys" chain. Trace data flow from symptom backward. Document each hop in the chain. |

## Success Criteria
1. Every reported bug has a proven root cause with file:line and actual-vs-expected values.
2. Fix verified by re-running the originally failing test/command.
3. Full test suite passes after all fixes (no regressions introduced).
4. Skipped bugs documented with reason_stuck and root_cause_unknown.

## TSV Logging
Append to `.godmode/debug-findings.tsv`:
```
iteration	bug_id	symptom	root_cause	file_line	fix_commit	status	reason_stuck
```
One row per bug investigated. Status: fixed, skipped, handed_off.

## Failure Classification
On bug SKIP: classify and append to `.godmode/debug-failures.tsv` with reason.
Failure classes: `unreproducible`, `environment_dependent`, `insufficient_context`, `tooling_gap`, `intermittent`.
