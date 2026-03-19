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
target = user_target OR 80
current_iteration = 0
WHILE coverage < target:
    current_iteration += 1
    # 1. FIND — highest-impact uncovered path (unit > integration > edge > error)
    # 2. RED — write test that FAILS
    # 3. GREEN — verify fail, then verify pass (write minimum code if needed)
    # 4. REFACTOR — clean up, re-run all tests
    # 5. COMMIT: git commit -m "test: {description}"
    # 6. MEASURE: coverage = measure_coverage()
    # 7. LOG to .godmode/test-results.tsv:
         iteration  test_file  coverage_before  coverage_after  delta
    IF current_iteration % 5 == 0:
        "Test iter {N}: coverage {coverage}% (target: {target}%)"
Print: "Coverage: {start}% → {coverage}% in {N} iterations"
```

## Rules
1. RED first. Test must fail before code exists.
2. One test per iteration. Commit after each passes.
3. Test behavior, not implementation. No mocking unless necessary (external services only).
4. Every test has an assertion. Commit before moving on.
