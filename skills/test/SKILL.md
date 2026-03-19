---
name: test
description: |
  TDD enforcement skill. Activates when user needs to write tests, improve test coverage, or add missing test cases. Enforces RED-GREEN-REFACTOR discipline. Can generate tests from specs, scenarios, or existing code. Triggers on: /godmode:test, "write tests", "add test coverage", "test this", or when build skill needs test writing guidance.
---

# Test — TDD Enforcement

## When to Activate
- User invokes `/godmode:test`
- User asks "write tests for X" or "add test coverage"
- Build skill needs guidance on test structure
- Test coverage is below target after a build
- User wants to add regression tests for a bug fix

## Workflow

### Step 1: Assess Current Test State
Understand what tests exist and what's missing:

```bash
# Find test files
find . -name "*.test.*" -o -name "*.spec.*" -o -name "test_*"

# Run existing tests with coverage
<test command with coverage flag>

# Check for untested code
<coverage report>
```

```
TEST STATE:
Test framework: <jest/pytest/go test/etc.>
Test command: <exact command>
Total tests: <N>
Passing: <N>
Failing: <N>
Coverage: <X>%
Uncovered files: <list>
```

### Step 2: Determine Test Strategy
Based on what's needed:

**If writing tests for new code (from spec/plan):**
1. Read the spec for expected behaviors
2. Read the scenario matrix for edge cases
3. Write tests BEFORE implementation (RED phase)

**If adding coverage to existing code:**
1. Read the uncovered code
2. Identify untested branches, functions, and edge cases
3. Write tests that exercise uncovered paths

**If writing regression tests for bugs:**
1. Understand the bug (reproduce it)
2. Write a test that fails with the bug present
3. Confirm the test passes after the fix

### Step 3: Write Tests Using RED-GREEN-REFACTOR

For each test case:

#### Structure
```
GIVEN: <initial state/preconditions>
WHEN: <action taken>
THEN: <expected outcome>
```

#### Test Quality Checklist
Every test must:
- [ ] Test ONE behavior (single assertion focus)
- [ ] Have a descriptive name that reads like a sentence
- [ ] Be independent (no test depends on another test's state)
- [ ] Be deterministic (same result every run, no flaky tests)
- [ ] Be fast (under 100ms for unit tests)
- [ ] Clean up after itself (no leftover state)

#### Naming Convention
```
// Good names — describe behavior, not implementation
"returns 429 when rate limit exceeded"
"creates user with hashed password"
"retries failed request up to 3 times"
"throws ValidationError for negative quantity"

// Bad names — describe implementation details
"test calculateRateLimit function"
"test user creation"
"test retry logic"
"test validation"
```

### Step 4: Test Categories
Organize tests into categories based on scope:

#### Unit Tests (70% of tests)
Test individual functions/methods in isolation.
```
- Mock external dependencies
- Test pure logic
- Fast (< 100ms each)
- Example: "rate limit calculator returns correct remaining count"
```

#### Integration Tests (20% of tests)
Test how components work together.
```
- Use real database (test instance) or in-memory alternatives
- Test API endpoints end-to-end
- Test service interactions
- Medium speed (< 1s each)
- Example: "POST /api/orders creates order and decrements inventory"
```

#### Edge Case Tests (10% of tests)
Test boundary conditions and failure modes.
```
- From the scenario matrix (/godmode:scenario output)
- Null, empty, boundary values
- Error conditions
- Concurrency issues
- Example: "handles concurrent orders for last item in stock"
```

### Step 5: Test File Template

```typescript
// tests/<module>/<feature>.test.ts
import { describe, it, expect, beforeEach, afterEach } from '<test-framework>';

describe('<Feature/Module Name>', () => {
  // Setup
  beforeEach(() => {
    // Initialize clean state for each test
  });

  afterEach(() => {
    // Clean up — restore mocks, clear data
  });

  describe('<method or behavior group>', () => {
    // Happy path first
    it('does the expected thing with valid input', () => {
      // GIVEN
      const input = createValidInput();

      // WHEN
      const result = doTheThing(input);

      // THEN
      expect(result).toEqual(expectedOutput);
    });

    // Then edge cases
    it('returns error for empty input', () => {
      // GIVEN
      const input = {};

      // WHEN / THEN
      expect(() => doTheThing(input)).toThrow(ValidationError);
    });

    // Then boundaries
    it('handles exactly at the limit', () => {
      // GIVEN
      const input = createInputAtLimit();

      // WHEN
      const result = doTheThing(input);

      // THEN
      expect(result.allowed).toBe(true);
    });
  });
});
```

### Step 6: Run and Verify

```
1. Run the new tests — ALL must fail (RED)
   If any pass, the test is wrong or feature already exists

2. Implement the code (or confirm existing code)

3. Run the new tests — ALL must pass (GREEN)

4. Run the FULL test suite — nothing else broke

5. Check coverage — did it improve?
```

```
TEST RESULTS:
New tests: <N> written
All passing: <YES/NO>
Coverage before: <X>%
Coverage after: <Y>%
Coverage delta: +<Z>%
Uncovered remaining: <list of still-uncovered areas>
```

### Step 7: Commit and Transition
1. Commit tests: `"test: <feature> — <N> new tests, coverage <X>%→<Y>%"`
2. If coverage target met: "Tests complete. Ready to proceed."
3. If coverage target not met: "Coverage is <Y>%, target is <T>%. <N> more tests recommended for: <uncovered areas>"

## Key Behaviors

1. **Test BEHAVIOR, not implementation.** Test what the code does, not how it does it. Tests that break on refactor are bad tests.
2. **One assertion per test.** A test with 10 assertions is 10 tests crammed into one. Split them.
3. **Descriptive names.** Someone reading only the test names should understand the feature's behavior.
4. **No test interdependence.** Each test runs in isolation. Shared state between tests causes flaky tests.
5. **Fast tests.** Unit tests under 100ms. If a test is slow, it's probably an integration test — label it as such.
6. **Test the unhappy path.** Happy path coverage is easy. The value is in testing what happens when things go wrong.
7. **Deterministic always.** No `Math.random()`, no `Date.now()`, no network calls in unit tests. Mock them.

## Example Usage

### Writing tests for a new module
```
User: /godmode:test Write tests for the rate limiter service

Test: Analyzing the rate limiter code...

Found: src/services/rate-limiter.ts
Spec: docs/specs/rate-limiter.md
Scenarios: docs/scenarios/rate-limiter-scenarios.md

Creating test file: tests/services/rate-limiter.test.ts

describe('RateLimiter', () => {
  describe('checkLimit', () => {
    it('allows request when under limit', ...);
    it('blocks request when limit exceeded', ...);
    it('resets count after window expires', ...);
    it('returns correct retryAfter seconds', ...);
    it('handles first request (no prior history)', ...);
    it('handles concurrent requests atomically', ...);
    it('returns 0 remaining at exact limit', ...);
  });

  describe('configuration', () => {
    it('uses default window of 60 seconds', ...);
    it('accepts custom window size', ...);
    it('throws for negative max requests', ...);
  });
});

Writing 10 tests... all should FAIL (no implementation yet).
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Assess state and write needed tests |
| `--coverage` | Focus on increasing coverage of existing code |
| `--for <file>` | Write tests for a specific file |
| `--from-scenarios` | Generate tests from scenario matrix |
| `--regression <bug>` | Write regression test for a specific bug |
| `--red-only` | Write failing tests only (for TDD RED phase) |

## Anti-Patterns

- **Do NOT write tests after implementation.** That's test-after development, not TDD. Tests come first.
- **Do NOT test private methods.** Test the public interface. If private methods need direct tests, the design might be wrong.
- **Do NOT mock everything.** Over-mocking makes tests pass but proves nothing. Mock external boundaries, not internal logic.
- **Do NOT write flaky tests.** A test that fails 1 in 100 runs is worse than no test. Fix the non-determinism.
- **Do NOT chase 100% coverage.** 100% line coverage doesn't mean correct code. Focus on meaningful behavioral coverage, not line counting.
- **Do NOT duplicate test logic.** If multiple tests share complex setup, extract a factory or fixture. But keep each test readable independently.
