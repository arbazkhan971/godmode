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

### HARD RULE: Autonomous Test Generation Loop

```
DO NOT stop after writing one test. Loop until coverage target is met (default 80%).

LOOP:
  1. Measure current coverage (run test suite with coverage flag)
  2. Find uncovered lines/branches (parse coverage report)
  3. Write ONE test for the most critical uncovered path
  4. git commit BEFORE running the test
     Commit: "test: add test for <uncovered path> [WIP]"
  5. Run tests — new test must FAIL first (RED), then pass after code exists (GREEN)
  6. Re-measure coverage
  7. Log to .godmode/test-results.tsv
     Format: timestamp \t file \t test_name \t coverage_before \t coverage_after \t status
  8. If coverage < target → GOTO 1
  9. If coverage >= target → print summary and proceed to mutation testing

This loop is NON-NEGOTIABLE. You keep writing tests until the target is met.
```

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

### Step 7: Commit Checkpoint
1. Commit tests: `"test: <feature> — <N> new tests, coverage <X>% -> <Y>%"`
2. If coverage target met: proceed to Step 8 (property-based testing)
3. If coverage target not met: "Coverage is <Y>%, target is <T>%. Continuing autonomous loop..."

### Step 8: Multi-Agent Test Generation

For large codebases, dispatch parallel test-writing agents to cover different modules simultaneously. Each agent focuses on a specific directory or module.

```
DISPATCH PARALLEL AGENTS:

Agent 1: Write unit tests for src/services/
  - Skill: unittest
  - Target: All exported functions in services
  - Mock: External dependencies (DB, HTTP, filesystem)

Agent 2: Write unit tests for src/middleware/
  - Skill: unittest
  - Target: All middleware functions
  - Mock: Request/response objects, next()

Agent 3: Write integration tests for src/controllers/
  - Skill: integration
  - Target: API endpoint handlers
  - Mock: Only external services (not DB)

Agent 4: Write edge case tests from scenario matrix
  - Skill: edge-cases
  - Target: Boundary conditions from /godmode:scenario output
  - Mock: Minimal — test real behavior

COORDINATION:
- Each agent writes to its own test file (no conflicts)
- Each agent commits independently
- After all agents finish, run FULL test suite to catch cross-module issues
- Merge coverage reports: combined coverage must meet target
```

When to use multi-agent:
- Project has 5+ modules/directories with code
- Coverage gap is >30% (need many tests fast)
- Different modules need different test strategies (unit vs integration)

When NOT to use multi-agent:
- Small project (< 10 files)
- Coverage gap is <10% (surgical precision needed)
- Tightly coupled code (agents would write conflicting tests)

### Step 9: Property-Based Testing

For pure functions (no side effects, deterministic output for given input), generate property-based tests. These find edge cases that example-based tests miss.

```
IDENTIFY PURE FUNCTIONS:
Scan codebase for functions that:
- Take input, return output (no side effects)
- Don't modify external state (no DB writes, no file writes)
- Are deterministic (same input = same output)

FOR EACH PURE FUNCTION:
1. Identify the properties that should ALWAYS hold:
   - Invariants: "output is always positive", "length never exceeds input length"
   - Round-trip: "decode(encode(x)) === x"
   - Idempotency: "f(f(x)) === f(x)"
   - Commutativity: "f(a, b) === f(b, a)" (if applicable)
   - Monotonicity: "if a > b then f(a) >= f(b)" (if applicable)

2. Write property-based test using appropriate library:
   JavaScript/TypeScript: fast-check
   Python: hypothesis
   Rust: proptest
   Go: testing/quick or gopter
   Java: jqwik

3. Configure generators for input types:
   - Strings: arbitrary strings, unicode, empty, very long
   - Numbers: integers, floats, negative, zero, MAX_SAFE_INTEGER
   - Arrays: empty, single, large, nested
   - Objects: with missing fields, extra fields, null values
```

Example (TypeScript with fast-check):
```typescript
import * as fc from 'fast-check';

describe('Property-based: encodeBase64', () => {
  it('round-trips for any string', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        expect(decodeBase64(encodeBase64(input))).toEqual(input);
      })
    );
  });

  it('output is always longer than or equal to input', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        expect(encodeBase64(input).length).toBeGreaterThanOrEqual(input.length);
      })
    );
  });

  it('output contains only base64 characters', () => {
    fc.assert(
      fc.property(fc.string(), (input) => {
        expect(encodeBase64(input)).toMatch(/^[A-Za-z0-9+/=]*$/);
      })
    );
  });
});
```

Example (Python with hypothesis):
```python
from hypothesis import given, strategies as st

@given(st.text())
def test_encode_decode_roundtrip(s):
    assert decode_base64(encode_base64(s)) == s

@given(st.integers(min_value=0))
def test_factorial_is_positive(n):
    assume(n <= 20)  # avoid overflow
    assert factorial(n) > 0
```

### Step 10: Mutation Testing

After coverage target is met, run mutation testing to verify test quality. High coverage with weak assertions is a false sense of security.

```
MUTATION TESTING:

Purpose: Verify that tests actually DETECT bugs, not just EXECUTE code.
A mutant is a small change to the source code (e.g., change > to >=).
If tests still pass after a mutation, the tests are WEAK for that code path.

TOOLS:
  JavaScript/TypeScript: Stryker (npx stryker run)
  Python: mutmut (mutmut run)
  Java: PIT (pitest)
  Go: go-mutesting

PROCESS:
1. Run mutation testing tool on source code
2. Collect mutation score: (killed mutants / total mutants) * 100
3. For each SURVIVING mutant (test didn't catch the change):
   a. Read the mutation (what changed)
   b. Write a test that would catch this mutation
   c. Add the test and re-run mutation testing
4. Target: mutation score >= 70%

MUTATION SCORE INTERPRETATION:
  >= 80%: Strong tests — mutations are caught, assertions are meaningful
  60-79%: Decent tests — some weak spots to shore up
  40-59%: Weak tests — high coverage but low detection, fix assertions
  < 40%:  Tests are decorative — rewrite with stronger assertions

LOG:
  .godmode/mutation-results.tsv
  Format: timestamp \t file \t mutants_total \t mutants_killed \t score
```

IMPORTANT: Mutation testing is CPU-intensive. For large codebases, run it on changed files only (not the entire project) unless the user explicitly requests a full mutation run.

### Step 11: Final Commit and Transition
1. Commit all tests: `"test: <feature> — <N> tests, coverage <X>% -> <Y>%, mutation score <Z>%"`
2. Log final results to `.godmode/test-results.tsv`
3. If coverage target met AND mutation score >= 70%: "Tests complete. Strong coverage and mutation score. Ready to proceed."
4. If coverage target met BUT mutation score < 70%: "Coverage met (<Y>%) but mutation score is low (<Z>%). Tests execute code but don't verify behavior well. Consider strengthening assertions."
5. If coverage target not met: "Coverage is <Y>%, target is <T>%. <N> more tests recommended for: <uncovered areas>"

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
| (none) | Assess state and write needed tests using autonomous loop |
| `--coverage` | Focus on increasing coverage of existing code |
| `--coverage-target <N>` | Set coverage target percentage (default: 80) |
| `--for <file>` | Write tests for a specific file |
| `--from-scenarios` | Generate tests from scenario matrix |
| `--regression <bug>` | Write regression test for a specific bug |
| `--red-only` | Write failing tests only (for TDD RED phase) |
| `--property` | Generate property-based tests for pure functions |
| `--mutation` | Run mutation testing after coverage target is met |
| `--parallel` | Use multi-agent test generation for large codebases |
| `--full` | Run entire pipeline: unit + property + mutation testing |

## Anti-Patterns

- **Do NOT write tests after implementation.** That's test-after development, not TDD. Tests come first.
- **Do NOT test private methods.** Test the public interface. If private methods need direct tests, the design might be wrong.
- **Do NOT mock everything.** Over-mocking makes tests pass but proves nothing. Mock external boundaries, not internal logic.
- **Do NOT write flaky tests.** A test that fails 1 in 100 runs is worse than no test. Fix the non-determinism.
- **Do NOT chase 100% coverage.** 100% line coverage doesn't mean correct code. Focus on meaningful behavioral coverage, not line counting.
- **Do NOT duplicate test logic.** If multiple tests share complex setup, extract a factory or fixture. But keep each test readable independently.
