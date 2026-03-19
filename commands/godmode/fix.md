# /godmode:fix

Autonomous error remediation loop. Inventories all errors (tests, lint, types), fixes them one at a time with minimum changes, adds regression tests, and repeats until zero errors remain.

## Usage

```
/godmode:fix                        # Fix all errors autonomously
/godmode:fix --tests-only           # Only fix failing tests
/godmode:fix --lint-only            # Only fix lint errors (auto-fix when possible)
/godmode:fix --types-only           # Only fix type errors
/godmode:fix --file src/user.ts     # Only fix errors in a specific file
/godmode:fix --max 20               # Maximum fix iterations
/godmode:fix --dry-run              # Show what would be fixed
/godmode:fix --from-debug           # Accept root cause from /godmode:debug
```

## What It Does

1. Inventories all current errors (test failures, lint errors, type errors)
2. Prioritizes: type errors first, then lint, then test failures
3. For each error:
   - Analyzes the root cause (or uses analysis from `/godmode:debug`)
   - Applies the minimum fix
   - Adds a regression test (for logical bugs)
   - Verifies no regressions
   - Commits
4. Repeats until zero errors remain

## Output
- Fixed code with one commit per fix
- Regression tests for each bug fix
- Fix log: `.godmode/fix-log.tsv`
- Summary report

## Next Step
After fix: `/godmode:optimize` to continue improving, or `/godmode:review` to review fixes.

## Examples

```
/godmode:fix                         # Fix everything
/godmode:fix --tests-only            # Just fix the failing tests
/godmode:fix --lint-only             # Auto-fix lint issues
```
