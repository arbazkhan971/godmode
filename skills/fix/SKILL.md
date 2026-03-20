---
name: fix
description: Fix loop. One fix per commit, auto-revert on regression, until zero errors.
---

## Activate When
- `/godmode:fix`, "fix this", "tests failing", "fix errors", "fix bugs", "broken build", "lint errors"
- Build, lint, or test commands return non-zero exit codes
- Called by other skills (`/godmode:build`, `/godmode:ship`) when checks fail

## Auto-Detection
The godmode orchestrator routes here when:
- `build_cmd` exits non-zero (compile errors, type errors)
- `lint_cmd` exits non-zero (linting violations)
- `test_cmd` exits non-zero (test failures)
- User pastes error output or stack traces
- Another skill hits a check failure and delegates with "fix max N"

## Step-by-step Workflow
```
error_count = run_all_checks()  # build_cmd + lint_cmd + test_cmd (build first — can't lint/test broken code)
original = error_count
current_iteration = 0
skipped_list = []
attempt_count = {}  # tracks attempts per unique error signature

IF error_count == 0:
    Print: "Fix: all checks pass. 0 errors found."
    STOP

WHILE error_count > 0:
    current_iteration += 1

    # 1. TRIAGE — Run build_cmd first. If it fails, only fix build errors.
    #    If build passes, run lint_cmd. If lint fails, fix lint errors.
    #    If both pass, run test_cmd. Fix test failures last.
    #    Priority: build > type > lint > test. Each layer unblocks the next.
    check_output = run_failing_check()
    errors = parse_errors(check_output)

    # 2. PICK — Select highest-priority error not in skipped_list.
    #    Parse file:line:column and error code from output.
    #    Create error_signature = "{file}:{line}:{error_code}".
    error = pick_highest_priority(errors, skipped_list)
    IF error is None: BREAK

    # 3. ANALYZE — Read FULL error output (all lines, not just first).
    #    Read source at error file:line ±15 lines. Read imports, types, callers.
    #    Name the mismatch: "expected X, got Y because Z".
    #    If error references another file (e.g., type mismatch from import), read that file too.

    # 4. FIX — Change ≤5 lines for ONE error. Fix the cause, not the symptom.
    #    No workarounds: no `any` casts, no `// @ts-ignore`, no `eslint-disable`, no empty catch blocks.
    #    If fix requires >5 lines, check if the real fix is in a different file (common with type errors).

    # 5. REGRESSION TEST — If fixing a logic bug (not just a type/lint error),
    #    add a minimal test in the same commit that would have caught this bug.
    #    Test file: colocate with source (e.g., foo.test.ts next to foo.ts).

    # 6. COMMIT — `git add {changed_files} && git commit -m "fix({module}): {description}"`
    #    Commit BEFORE verify so revert is clean.

    # 7. VERIFY — new_count = run_all_checks()
    IF new_count >= error_count:
        `git reset --hard HEAD~1`
        attempt_count[error_signature] += 1
        IF attempt_count[error_signature] >= 3:
            skipped_list.append(error_signature)
            Print: "Skipping {error_signature} after 3 failed attempts"
        CONTINUE
    ELSE:
        error_count = new_count

    # 8. LOG — Append to .godmode/fix-results.tsv
    #    iteration, error_type, file, line, fix_description, lines_changed, status(kept/reverted)

    # 9. STATUS — Every 5 iterations:
    IF current_iteration % 5 == 0:
        Print: "{error_count} remaining (from {original}). Kept: {kept}. Reverted: {reverted}."

Print: "Fixed: {original} → {error_count} in {current_iteration} iters. Skipped: {skipped_list}."
IF len(skipped_list) > 0:
    Print: "Recommend: /godmode:debug for skipped errors."
```

## Output Format
Each stage prints structured output:
- **Triage:** `Fix triage: {build|lint|test} failing with {N} errors`
- **Pick:** `Fixing [{iteration}/{original}]: {error_type} at {file}:{line}`
- **Analyze:** `Root cause: {expected} vs {actual} because {reason}`
- **Verify (kept):** `KEPT: error count {before} → {after}`
- **Verify (reverted):** `REVERTED: error count did not decrease (attempt {N}/3)`
- **Status (every 5):** `Fix status: {remaining} remaining (from {original}). Kept: {kept}. Reverted: {reverted}.`
- **Final:** `Fixed: {original} → {error_count} in {N} iters. Skipped: {skipped_list}.`

## TSV Logging
Append to `.godmode/fix-results.tsv` after every fix attempt. Columns:
```
iteration	error_type	file	line	fix_description	lines_changed	status
1	type_error	src/api/handler.ts	42	add null check for user.id	2	kept
2	lint_error	src/utils/format.ts	18	remove unused import	1	kept
3	test_failure	src/auth/login.ts	97	fix off-by-one in token expiry	3	reverted
```

## Success Criteria
- [ ] `build_cmd && lint_cmd && test_cmd` all exit 0
- [ ] Every kept fix is a separate commit with message `fix({module}): {description}`
- [ ] No fix introduced new errors (verified by full check suite after each commit)
- [ ] Skipped errors (if any) are logged with error signatures for `/godmode:debug`
- [ ] `.godmode/fix-results.tsv` has one row per fix attempt
- [ ] No test files were modified (fixes go in source, regression tests are new files)

## Error Recovery
- **If build_cmd is not configured or exits with "command not found":** Run stack detection (`package.json`, `Cargo.toml`, `go.mod`, `pom.xml`). Set `build_cmd` from detected stack. If no build step exists (e.g., Python), skip build and proceed to lint.
- **If the same error keeps reappearing after a successful fix:** The error is likely in a generated file. Check for codegen (`prisma generate`, `protoc`, `openapi-generator`). Run the generator, then re-verify.
- **If error count increases after revert:** The working tree is dirty. Run `git status` and `git stash` uncommitted changes, then `git reset --hard HEAD` to reach a known-good state. Re-run checks.
- **If a fix requires modifying a test file:** The test is wrong, not the code, only if the spec explicitly changed. In that case, commit the test change separately with `test({module}): update test for {spec_change}`. Otherwise, fix the source code to match the test.
- **If all errors are in skipped_list and error_count > 0:** Stop the loop. Print the full skipped list with file:line and error messages. Recommend `/godmode:debug` to investigate root causes.

## Anti-Patterns
1. **Suppressing errors instead of fixing them.** Never add `// @ts-ignore`, `# type: ignore`, `eslint-disable`, `@SuppressWarnings`, `try/catch` around broken code, or cast to `any`. These hide the bug.
2. **Fixing multiple errors in one commit.** Each commit must fix exactly one error. This ensures clean reverts and makes the TSV log accurate.
3. **Modifying test expectations to match broken code.** Tests define correct behavior. If a test fails, the source is wrong unless the spec changed.
4. **Guessing without reading the full error.** Always parse the entire error output. Truncated stack traces lead to wrong fixes. Read stderr completely.
5. **Fixing symptoms downstream instead of the root cause.** If a type error appears in file B because file A exports the wrong type, fix file A. Trace the error to its origin.

## Examples

### Example 1: TypeScript build errors
```
$ /godmode:fix
Fix triage: build failing with 3 errors
Fixing [1/3]: TS2345 at src/api/users.ts:42
  Root cause: argument type 'string | undefined' not assignable to 'string' because req.query.id can be undefined
  KEPT: error count 3 → 2
Fixing [2/3]: TS2339 at src/models/user.ts:18
  Root cause: property 'email' does not exist on type 'BaseUser' because interface was not extended
  KEPT: error count 2 → 1
Fixing [3/3]: TS7006 at src/utils/format.ts:7
  Root cause: parameter 'value' implicitly has 'any' type because noImplicitAny is enabled
  KEPT: error count 1 → 0
Fixed: 3 → 0 in 3 iters. Skipped: [].
```

### Example 2: Mixed errors with a revert
```
$ /godmode:fix
Fix triage: build failing with 1 error
Fixing [1/1]: build error at src/index.ts:1
  Root cause: Cannot find module './config' — file was deleted
  KEPT: error count 1 → 0
Fix triage: lint failing with 2 errors
Fixing [1/2]: no-unused-vars at src/api/handler.ts:3
  Root cause: import { Response } is imported but never used
  KEPT: error count 2 → 1
Fixing [2/2]: no-explicit-any at src/api/handler.ts:15
  Root cause: parameter typed as 'any' instead of 'Request'
  REVERTED: error count did not decrease (attempt 1/3)
  REVERTED: error count did not decrease (attempt 2/3)
  REVERTED: error count did not decrease (attempt 3/3)
  Skipping src/api/handler.ts:15:no-explicit-any after 3 failed attempts
Fixed: 3 → 1 in 5 iters. Skipped: [src/api/handler.ts:15:no-explicit-any].
Recommend: /godmode:debug for skipped errors.
```

### Example 3: Test failures after a build task
```
$ /godmode:fix   # called by /godmode:build after merge
Fix triage: test failing with 2 errors
Fixing [1/2]: FAIL src/auth/login.test.ts — "should reject expired tokens"
  Root cause: token expiry check uses `<` instead of `<=` at src/auth/login.ts:97
  Added regression test: src/auth/login.edge.test.ts — "should reject token at exact expiry time"
  KEPT: error count 2 → 1
Fixing [2/2]: FAIL src/api/users.test.ts — "should return 404 for missing user"
  Root cause: handler returns 500 because findUser throws instead of returning null at src/models/user.ts:34
  KEPT: error count 1 → 0
Fixed: 2 → 0 in 2 iters. Skipped: [].
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- The fix skill is inherently sequential (one fix at a time), so no parallel dispatch is needed.
- Execute the loop exactly as written: pick error, fix, commit, verify, revert if regression.
- Use `git reset --hard HEAD~1` for reverts — this works on all platforms.
- TSV logging, skip logic, and status printing remain identical.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
