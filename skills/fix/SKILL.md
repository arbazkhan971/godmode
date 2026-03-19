---
name: fix
description: |
  Autonomous error fixing skill. Activates when there are known bugs, failing tests, lint errors, or type errors to fix. Runs a loop: pick the next error, fix it, verify the fix, add a regression test, repeat until zero errors remain. Triggers on: /godmode:fix, "fix this", "tests are failing", or when debug skill completes with a root cause. Also handles lint/type error remediation.
---

# Fix — Autonomous Error Remediation

## When to Activate
- User invokes `/godmode:fix`
- Debug skill completes with a root cause analysis
- Tests are failing and the cause is known
- Lint or type errors need remediation
- User says "fix this," "fix the tests," "fix the errors"
- Build skill encounters failures during execution

## Workflow

### Step 1: Inventory All Errors
Collect every error that needs fixing:

```bash
# Failing tests
<test command> 2>&1 | tee /tmp/test-output.txt

# Lint errors
<lint command> 2>&1 | tee /tmp/lint-output.txt

# Type errors
<type check command> 2>&1 | tee /tmp/type-output.txt
```

```
ERROR INVENTORY:
Test failures: <N>
Lint errors: <N>
Type errors: <N>
Total: <N> errors to fix

Priority order:
1. Type errors (foundation — everything else depends on types)
2. Lint errors (quick wins — usually auto-fixable)
3. Test failures (most complex — one at a time)
```

### Step 1b: Fix Priority Scoring

After inventory, score each error using this formula:

```
PRIORITY SCORE = severity x blast_radius x fixability
```

| Factor | 1 (Low) | 2 (Medium) | 3 (High) |
|--------|---------|------------|----------|
| **severity** | Cosmetic / warning | Incorrect behavior | Crash / data loss |
| **blast_radius** | 1 file affected | 1 module affected | Cross-module / whole app |
| **fixability** | Unknown cause, complex | Known cause, multi-file | Known cause, single line |

```
PRIORITY SCORING:
#  Error                                      Sev  Blast  Fix  Score
1  Type 'string' != 'number' (user.ts:12)      2    3     3    18   ← FIX FIRST
2  Missing null check (api.ts:45)               3    2     3    18   ← FIX FIRST (tie)
3  Unused import (utils.ts:1)                   1    1     3     3   ← FIX LAST
4  Test "creates user" fails (user.test.ts:30)  2    2     2     8
5  ESLint no-any violation (types.ts:15)        1    1     3     3
```

Fix in descending score order. Ties are broken by: type errors > test failures > lint errors.

### Step 2: Fix Loop (One Error Per Iteration)
For EACH error, run this cycle:

#### 2a: Select Next Error
Pick the highest-priority unfixed error:
```
FIX ITERATION <N>:
Error: <exact error message>
Location: <file:line>
Category: <test failure | lint error | type error>
Root cause: <if known from /godmode:debug, otherwise analyze now>
```

#### 2b: Analyze (if root cause unknown)
If this error hasn't been investigated by `/godmode:debug`:
1. Read the error message carefully
2. Read the code at the error location
3. Read surrounding context (callers, dependencies)
4. Form a hypothesis about the cause

```
ANALYSIS:
Error: "Property 'email' does not exist on type 'User'"
Location: src/services/user.ts:34
Cause: User type was updated in types.ts to use 'emailAddress'
       but this file still references the old 'email' field
Fix: Change 'user.email' to 'user.emailAddress' on line 34
```

#### 2c: Apply Fix
Make the minimum change to fix the error:
```
1. Apply the fix
2. ONLY fix the specific error — do not refactor, improve, or "while I'm here" anything else
3. If the fix requires changes in multiple files, that's fine — but ONLY changes needed for THIS fix
```

Commit: `"fix: <brief description of what was fixed>"`

#### 2d: Add Regression Test
For test failures and logical bugs (not lint/type errors):
```
1. Write a test that would FAIL if the bug came back
2. Run the test — it must PASS now
3. Temporarily revert the fix — the test must FAIL
4. Re-apply the fix — the test must PASS
```

Commit: `"test: regression test for <bug description>"`

#### 2e: Verify Fix
```bash
# Run the specific failing test/check
<specific verify command>

# Run ALL tests (catch regressions)
<full test command>

# Run ALL lint
<lint command>

# Run ALL type checks
<type check command>
```

```
FIX VERIFICATION:
Specific error: ✓ FIXED
Full test suite: ✓ <N>/<N> passing (no regressions)
Lint: ✓ clean
Types: ✓ clean

Error <M> of <total> fixed. <remaining> remaining.
```

If the fix introduces new errors: revert and re-analyze.

#### 2e-ii: Cascading Fix Detection

After verifying a fix, **re-inventory all errors** and compare to the previous count:

```
CASCADING FIX CHECK:
Before fix: 9 errors (2 type, 0 lint, 7 test failures)
After fix:  6 errors (1 type, 0 lint, 5 test failures)
Direct fix: 1 type error
Cascade:    2 test failures resolved by type fix cascade

Log: "3 errors resolved in iteration 2 (1 direct + 2 cascade)"
```

Cascading fixes are common when:
- Fixing type errors resolves downstream test failures
- Fixing a shared utility resolves errors in multiple consumers
- Fixing a config error resolves multiple integration tests

Always log cascades separately — they indicate the fix addressed a root cause, not just a symptom.

#### 2e-iii: Max 3 Attempts Per Error

If an error cannot be fixed in **3 attempts** (3 apply-verify-revert cycles), stop trying and flag it:

```
MAX ATTEMPTS REACHED:
Error: "Race condition in WebSocket reconnection" (ws.test.ts:89)
Attempts: 3/3
  Attempt 1: Added mutex lock → new deadlock error → reverted
  Attempt 2: Used event queue → still intermittent → reverted
  Attempt 3: Added retry with backoff → still fails 1/10 runs → reverted

FLAGGED FOR HUMAN REVIEW.
Moving on to next error.

Remaining: flagged in .godmode/fix-log.tsv with status=NEEDS_HUMAN_REVIEW
```

This prevents infinite loops on genuinely hard bugs. The fix skill is for mechanical remediation. If 3 attempts fail, the error likely needs architectural discussion or domain knowledge that the agent does not have.

#### 2f: Log and Continue
```
# File: .godmode/fix-log.tsv
iteration	error_type	error_message	file	fix_description	regression_test	commit_sha
1	type	Property 'email' does not exist	src/services/user.ts:34	Renamed email to emailAddress	N/A (type error)	abc1234
2	test	Expected 200, got 401	tests/api/auth.test.ts:45	Added auth header to test setup	tests/api/auth-regression.test.ts	def5678
```

Repeat from Step 2a until zero errors remain.

### Step 2-parallel: Multi-Agent Parallel Fix

When errors are **independent** (in different files/modules with no shared dependencies), dispatch parallel fix agents using worktrees:

```
MULTI-AGENT FIX DISPATCH:

Condition: Errors span 3+ independent modules with no shared imports.

Agent 1: Fix type errors in src/services/     (worktree: wt-fix-1)
Agent 2: Fix lint errors in src/controllers/   (worktree: wt-fix-2)
Agent 3: Fix test failures in tests/           (worktree: wt-fix-3)
```

Each agent:
1. Creates a worktree from the current branch
2. Fixes only errors in its assigned scope
3. Commits fixes independently
4. Reports results back

After all agents complete, merge results:
```bash
# Merge agent worktree results back
git merge wt-fix-1 --no-edit
git merge wt-fix-2 --no-edit
git merge wt-fix-3 --no-edit

# Run full verification on merged result
<test command> && <lint command> && <type check command>
```

```
MULTI-AGENT FIX RESULTS:
Agent 1 (types):  ✓ 4 type errors fixed in 2 files
Agent 2 (lint):   ✓ 12 lint errors fixed (auto-fix)
Agent 3 (tests):  ✓ 3 test failures fixed, 3 regression tests added
Merge conflicts:  0
Post-merge verify: ✓ All clean
```

**When NOT to parallelize:**
- Errors share the same root cause (fix one, cascade fixes the rest)
- Errors are in the same file (merge conflicts guaranteed)
- Type errors exist (fix types first — they cascade into other categories)

### Step 3: Final Verification
After all errors are fixed:

```bash
# One final complete run
<test command>
<lint command>
<type check command>
```

```
┌─────────────────────────────────────────────────────┐
│  FIX COMPLETE                                       │
├─────────────────────────────────────────────────────┤
│  Errors fixed: <N>                                  │
│  Type errors: <N> fixed                             │
│  Lint errors: <N> fixed                             │
│  Test failures: <N> fixed                           │
│  Regression tests added: <N>                        │
│                                                     │
│  Final state:                                       │
│  ✓ Tests: <N>/<N> passing                           │
│  ✓ Lint: clean                                      │
│  ✓ Types: clean                                     │
│                                                     │
│  Fix log: .godmode/fix-log.tsv                      │
├─────────────────────────────────────────────────────┤
│  Next:                                              │
│  → /godmode:optimize — Continue improving           │
│  → /godmode:review — Review all fixes               │
│  → /godmode:ship — Ship if ready                    │
└─────────────────────────────────────────────────────┘
```

## Autonomous Loop Enforcement — HARD RULES

These are mechanical constraints, not suggestions.

### RULE 1: LOOP UNTIL ZERO ERRORS REMAIN

Do NOT stop after one fix. Do NOT ask "should I continue?" Do NOT summarize after each fix.

```
LOOP:
  1. Inventory errors (run tests + lint + types)
  2. If zero errors → STOP, print final summary
  3. Pick highest-priority error
  4. Analyze root cause
  5. Apply minimum fix
  6. git commit BEFORE verification
  7. Verify (full suite)
  8. If fix introduced new errors → git reset --hard HEAD~1, re-analyze
  9. If fix worked → log to .godmode/fix-log.tsv
  10. GOTO 1
```

### RULE 2: Git Commit BEFORE Verify

```bash
git add <changed-files>
git commit -m "fix: <description>"
# THEN run full test suite
<test command>
# If new errors introduced:
git reset --hard HEAD~1
```

### RULE 3: One Fix Per Commit — No Exceptions

ONE error. ONE fix. ONE commit. If you fix two things, you can't cleanly revert one.

### RULE 4: Automatic Revert on Regression

If your fix introduces ANY new errors that weren't there before:
```bash
git reset --hard HEAD~1
```
Then re-analyze. The fix was wrong.

### RULE 5: Metric = Error Count (Lower is Better)

```
Verify: <test command> 2>&1 | grep -c "FAIL\|ERROR\|error"
Direction: lower is better
Target: 0
```

Track the error count after each iteration. Log it.

### RULE 6: Status Print Every 5 Iterations

```
Fix iteration 10: 3 errors remaining (from 12), 7 fixed, 2 reverted
```

## Key Behaviors

1. **One fix per iteration.** Never fix multiple errors at once. One fix, one verify, one commit.
2. **Minimum change.** Fix the error with the smallest possible change. Do not refactor, do not improve, do not "clean up while you're here."
3. **Regression tests for bugs.** Every logical bug fix gets a regression test. Type/lint errors don't need regression tests.
4. **Verify after every fix.** Run the full suite after each fix. A fix that breaks something else is not a fix.
5. **Type errors first.** Type errors cascade — fixing types often resolves other errors automatically.
6. **Lint auto-fix when possible.** Many lint errors can be auto-fixed: `eslint --fix`, `prettier --write`, `black`, `gofmt`. Use them.
7. **Don't guess at fixes.** If you don't understand the error, investigate first with `/godmode:debug`. Blind fixes create new bugs.

## Example Usage

### Fixing multiple test failures
```
User: /godmode:fix Our tests are failing after the database migration

Fix: Inventorying all errors...

ERROR INVENTORY:
Test failures: 7
Lint errors: 0
Type errors: 2
Total: 9 errors

Starting with type errors...

FIX ITERATION 1:
Error: Type 'string' is not assignable to type 'number' (user.ts:12)
Cause: Migration changed user.id from auto-increment integer to UUID string
Fix: Update User type to use string for id field
[fixes, commits, verifies — no regressions]

FIX ITERATION 2:
Error: Type 'string' is not assignable to type 'number' (order.ts:8)
Cause: Same — order.userId references User.id which is now string
Fix: Update Order type userId to string
[fixes, commits, verifies — 3 test failures resolved by type fix cascade]

FIX ITERATION 3:
Error: Test "finds user by ID" expects 1, gets "abc-123"
Cause: Test hardcodes numeric ID, but IDs are now UUIDs
Fix: Update test to use UUID format
Regression test: "handles both old numeric and new UUID IDs"
[fixes, commits, verifies]

...

FIX COMPLETE:
9 errors fixed in 6 iterations (3 resolved by cascade).
4 regression tests added.
✓ All 52 tests passing
✓ Lint clean
✓ Types clean
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Fix all errors autonomously |
| `--tests-only` | Only fix failing tests |
| `--lint-only` | Only fix lint errors (use auto-fix when available) |
| `--types-only` | Only fix type errors |
| `--file <path>` | Only fix errors in a specific file |
| `--max <N>` | Maximum fix iterations (default: 50) |
| `--dry-run` | Show what would be fixed without making changes |
| `--from-debug` | Accept root cause analysis from debug skill |

## Anti-Patterns

- **Do NOT fix errors you don't understand.** If the error message is unclear, debug first, then fix.
- **Do NOT fix multiple errors in one commit.** One fix, one commit. This makes reverting safe.
- **Do NOT refactor while fixing.** "While I'm in this file, let me also clean up..." NO. Fix the bug, that's it.
- **Do NOT skip the regression test.** The whole point of fix is to ensure the bug never comes back.
- **Do NOT ignore cascading fixes.** When you fix a type error and 3 test failures disappear, count them but verify they're truly fixed.
- **Do NOT continue if a fix introduces new errors.** Revert and re-analyze. The fix is wrong.
