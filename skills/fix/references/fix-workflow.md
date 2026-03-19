# Fix Workflow — Full Reference

## Error Prioritization Matrix

When multiple errors exist, fix them in this order:

| Priority | Error Type | Reason | Auto-fixable? |
|----------|-----------|--------|---------------|
| 1 | Syntax errors | Nothing runs until these are fixed | Sometimes |
| 2 | Type errors | Cascade to cause other errors | No |
| 3 | Lint errors (auto-fixable) | Quick wins, clean the noise | Yes |
| 4 | Lint errors (manual) | Need human judgment | No |
| 5 | Test failures (unit) | Isolated, easy to diagnose | No |
| 6 | Test failures (integration) | Complex, may have multiple causes | No |
| 7 | Runtime errors | Need reproduction first | No |

## Auto-Fix Commands by Language

### JavaScript/TypeScript
```bash
# ESLint auto-fix
npx eslint --fix src/

# Prettier auto-format
npx prettier --write src/

# TypeScript fix (sort imports, etc.)
npx organize-imports-cli src/**/*.ts
```

### Python
```bash
# Black auto-format
black src/

# isort (import sorting)
isort src/

# autopep8
autopep8 --in-place --recursive src/

# Ruff auto-fix
ruff check --fix src/
```

### Rust
```bash
# Rustfmt
cargo fmt

# Clippy with auto-fix
cargo clippy --fix --allow-dirty
```

### Go
```bash
# gofmt
gofmt -w .

# goimports
goimports -w .
```

## Fix Iteration Protocol

### One Fix Per Commit
Every fix is a single commit. This ensures:
- Each fix can be reverted independently
- The git log shows exactly what was fixed and when
- Code review can examine fixes individually

### Commit Message Format
```
fix: <brief description of what was fixed>

What: <file:line — the change made>
Why: <root cause explanation>
Test: <regression test added? yes/no>
```

Examples:
```
fix: handle null user in profile endpoint

What: src/controllers/user.ts:47 — added null check after db.findById()
Why: findById returns null for deleted users, causing TypeError
Test: yes — tests/controllers/user.test.ts "returns 404 for deleted user"
```

```
fix: update User type after database migration

What: src/types/user.ts:5 — changed id from number to string
Why: Migration 003 changed user.id to UUID, type definition was stale
Test: no — type error, existing tests cover the behavior
```

## Regression Test Protocol

### When to Write a Regression Test
| Error Type | Regression Test Required? |
|------------|--------------------------|
| Type error | No — type system catches recurrence |
| Lint error | No — linter catches recurrence |
| Syntax error | No — parser catches recurrence |
| Logic bug | YES |
| Runtime error | YES |
| Integration failure | YES |
| Security vulnerability | YES |

### Regression Test Structure
```
1. Arrange: Set up the EXACT conditions that triggered the bug
2. Act: Perform the operation that was failing
3. Assert: Verify the CORRECT behavior (not just absence of error)
4. Verify: Temporarily revert the fix, confirm the test FAILS
5. Restore: Re-apply the fix, confirm the test PASSES
```

### Regression Test Naming
```
// Format: "handles <condition that caused the bug>"
"handles null user returned from database"
"handles concurrent requests for last inventory item"
"handles expired JWT token in authorization header"
"handles email with unicode characters in local part"
```

## Cascade Detection

Sometimes fixing one error resolves others. Track this:

```
FIX CASCADE LOG:
Fix: Updated User.id type from number to string (types/user.ts:5)
Direct fix: 1 type error
Cascade resolved:
  - 2 more type errors in user.service.ts (same type mismatch)
  - 1 test failure in user.test.ts (comparison with number literal)

Total: 1 fix resolved 4 errors
```

### When to Check for Cascades
After every fix, re-run ALL error checks:
```bash
<type check command>  # How many type errors remain?
<lint command>        # How many lint errors remain?
<test command>        # How many test failures remain?
```

Compare the counts to the pre-fix inventory. If more errors disappeared than the one you fixed, document the cascade.

## Difficult Fix Patterns

### Pattern: Circular Dependencies
```
Symptom: Import errors, "cannot access X before initialization"
Diagnosis: Module A imports B, B imports A
Fix options:
  1. Extract shared types to a third module C
  2. Use dependency injection instead of direct imports
  3. Lazy imports (import inside function, not at top level)
```

### Pattern: Test Environment Mismatch
```
Symptom: Tests pass locally, fail in CI
Diagnosis: Environment-specific behavior
Fix options:
  1. Mock environment-specific dependencies
  2. Add environment variable for test configuration
  3. Use docker-compose for consistent test environment
```

### Pattern: Stale Fixtures/Snapshots
```
Symptom: Tests fail after schema change
Diagnosis: Test fixtures reference old schema
Fix options:
  1. Update all fixtures to match new schema
  2. Use factory functions instead of static fixtures
  3. Update snapshots: npm test -- -u (with caution)
```

### Pattern: Race Condition in Tests
```
Symptom: Tests fail intermittently (flaky)
Diagnosis: Non-deterministic timing
Fix options:
  1. Add proper async/await handling
  2. Use test framework's async utilities (waitFor, eventually)
  3. Mock time-dependent operations
  4. Add proper setup/teardown to prevent test pollution
```

## Verification Protocol

After every fix:

```
VERIFICATION CHECKLIST:
[ ] Specific error is resolved (re-run the exact failing command)
[ ] No new errors introduced (run full test suite)
[ ] Regression test passes (if applicable)
[ ] Regression test fails without the fix (if applicable)
[ ] Lint clean
[ ] Types clean
[ ] No unrelated changes in the diff (git diff should show ONLY the fix)
```

## Fix Log Format

```tsv
# .godmode/fix-log.tsv
iteration	timestamp	error_type	error_message	file_location	fix_description	cascade_count	regression_test	commit_sha
1	2024-01-15T10:23:00Z	type	"Property 'email' does not exist on type 'User'"	src/services/user.ts:34	"Renamed email to emailAddress"	2	N/A	abc1234
2	2024-01-15T10:28:00Z	test	"Expected 200, received 401"	tests/api/auth.test.ts:45	"Added auth token to test setup"	0	tests/api/auth-regression.test.ts	def5678
3	2024-01-15T10:33:00Z	lint	"'email' is defined but never used"	src/controllers/user.ts:12	"Removed unused import"	0	N/A	ghi9012
```
