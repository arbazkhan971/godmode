---
name: test
description: |
  TDD enforcement. RED-GREEN-REFACTOR. Generates tests from specs, measures coverage, loops until target met.
---

# Test — TDD Enforcement

## Activate When
- `/godmode:test`, "write tests", "test coverage", "add tests"
- Build phase needs test writing

## The Loop

```
coverage = measure_coverage()
target = user_target OR 80  # default 80%
current_iteration = 0

WHILE coverage < target:
    current_iteration += 1

    # 1. FIND uncovered code — read coverage report, pick highest-impact uncovered path
    # 2. RED — write test that FAILS (assert expected behavior of untested code)
    # 3. GREEN — verify test fails, then verify existing code makes it pass
         IF code doesn't exist yet → write minimum code to pass
    # 4. REFACTOR — clean up test and code, re-run all tests
    # 5. COMMIT: git commit -m "test: {description}"
    # 6. MEASURE: coverage = measure_coverage()
    # 7. LOG to .godmode/test-results.tsv:
         iteration  test_file  coverage_before  coverage_after  delta

    IF current_iteration % 5 == 0:
        "Test iter {N}: coverage at {coverage}% (target: {target}%)"

Print: "Coverage: {start}% → {coverage}% in {N} iterations"
```

## Test Types (by priority)

1. **Unit tests** — pure functions, business logic
2. **Integration tests** — API endpoints, database queries
3. **Edge cases** — null inputs, empty arrays, boundary values
4. **Error paths** — what happens when things fail

## Rules

1. **RED first.** Write the test before the code. Test must fail initially.
2. **One test per iteration.** Commit after each test passes.
3. **Test behavior, not implementation.** Tests survive refactors.
4. **No mocking unless necessary.** Real deps > mocks. Mock only external services.
5. **Every test has an assertion.** No `console.log` tests.
6. **Commit before moving on.** `git commit -m "test: ..."` after each passing test.
