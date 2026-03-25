---
name: fix
description: |
  Fix loop. One fix per commit, auto-revert on
  regression, until zero errors. Max 3 attempts
  per error.
  Triggers on: /godmode:fix, "fix this", "tests
  failing", "broken build", "lint errors".
---

## Activate When
- `/godmode:fix`, "fix this", "tests failing"
- Build, lint, or test returns non-zero exit code
- Called by other skills when checks fail

## Fix vs Debug Handoff
`/godmode:fix` assumes root cause is KNOWN.
If root cause unknown: route to `/godmode:debug`.

## Workflow

```bash
# Detect stack and run checks
build_cmd 2>&1; echo "EXIT: $?"
lint_cmd 2>&1; echo "EXIT: $?"
test_cmd 2>&1; echo "EXIT: $?"
```

```
LOOP:
  error_count = run_all_checks()
  original = error_count
  IF error_count == 0: STOP — all checks pass

  WHILE error_count > 0:
    1. TRIAGE — priority: build > type > lint > test
       Run failing check, parse errors
    2. PICK — highest priority, not in skipped_list
       Create signature: "{file}:{line}:{error_code}"
    3. ANALYZE — read FULL error output (all lines)
       Read source at file:line +/- 15 lines
       Name mismatch: "expected X, got Y because Z"
    4. FIX — change <= 5 lines for ONE error
       Fix cause, not symptom
    5. COMMIT — git add + commit before verify
    6. VERIFY — new_count = run_all_checks()
       IF new_count >= error_count:
         git reset --hard HEAD~1
         attempt_count[signature] += 1
         IF attempt_count >= 3: skip error
       ELSE: error_count = new_count
    7. LOG — append to .godmode/fix-results.tsv

THRESHOLDS:
  Max attempts per error: 3
  Max lines changed per fix: 5
  Status report: every 5 iterations
  Consecutive reverts to stop: 5
  IF all errors skipped: recommend /godmode:debug
```

## One Fix Per Iteration
Fix ONE error per iteration. Verify. Commit. Next.
Never batch-fix multiple errors in one commit.
Each fix independently verifiable and revertable.

## Output Format
```
Triage: {build|lint|test} failing with {N} errors
Pick: Fixing [{iter}/{original}]: {type} at {file}:{line}
Analyze: Root cause: {expected} vs {actual}
Verify (kept): KEPT: count {before} → {after}
Verify (revert): REVERTED: attempt {N}/3
Status: {remaining} remaining (from {original})
Final: Fixed: {original} → {count} in {N} iters.
  Skipped: {list}.
```

## TSV Logging
```
iteration	error_type	file	line	fix_description	lines_changed	status
```

## Hard Rules
1. Fix ONE error per iteration — commit before verify.
2. Never suppress errors (@ts-ignore, eslint-disable,
   any cast, empty catch) — fix the root cause.
3. Max 3 attempts per unique error, then skip.
4. Priority: build > type > lint > test.
5. Read FULL error output before fixing.

## Anti-Patterns
1. Suppressing errors instead of fixing them.
2. Fixing multiple errors in one commit.
3. Modifying test expectations to match broken code.
4. Guessing without reading full error output.
5. Fixing symptoms downstream instead of root cause.

## Quality Targets
- Fix success rate: >80% kept vs reverted
- Lines changed per fix: <5 maximum
- Attempts per error: <3 before skip

## Success Criteria
- `build_cmd && lint_cmd && test_cmd` all exit 0
- Every kept fix is a separate commit
- No fix introduced new errors
- Skipped errors logged for /godmode:debug
- No test files modified (fixes go in source)

## Keep/Discard Discipline
```
KEEP if: error count decreased AND no new errors
DISCARD if: count did not decrease OR new errors
On discard: git reset --hard HEAD~1.
  After 3 attempts, skip error.
```

## Stop Conditions
```
STOP when FIRST of:
  - error_count == 0 (all checks pass)
  - All errors either fixed or in skipped_list
  - 3 consecutive iterations with 0 fixed
  - > 5 consecutive reverts across different errors
```

## Error Recovery
- build_cmd not found: detect stack, set from config.
- Same error reappears: check for codegen (prisma,
  protoc). Run generator, then re-verify.
- Error count increases after revert: git stash,
  git reset --hard HEAD to known-good state.
- Fix requires test change: only if spec changed,
  commit separately as test({module}): update.
- All errors skipped: stop loop, print full list,
  recommend /godmode:debug.
