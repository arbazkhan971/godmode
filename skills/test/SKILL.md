---
name: test
description: TDD loop. RED-GREEN-REFACTOR until coverage target met.
---

## Activate When
- `/godmode:test`, "write tests", "test coverage", "add tests"

## The Loop
```
coverage = measure_coverage()  # test_cmd --coverage (from stack detection)
target = user_target OR 80
current_iteration = 0
WHILE coverage < target:
    current_iteration += 1
    # 1. FIND — highest-impact uncovered path. Priority: happy path > error path > edge case > integration
    # 2. RED — write test that FAILS
    # 3. GREEN — run test → must FAIL. If passes: test is wrong, rewrite. Write minimum code → must PASS.
    # 4. REFACTOR — remove duplication in test code, re-run ALL tests (not just new one)
    # 5. COMMIT: git commit -m "test: {description}"
    # 6. MEASURE: coverage = measure_coverage()
    # 7. LOG to .godmode/test-results.tsv:
         iteration  test_file  coverage_before  coverage_after  delta
    IF current_iteration % 5 == 0:
        "Test iter {N}: coverage {coverage}% (target: {target}%)"
Print: "Coverage: {start}% → {coverage}% in {N} iterations"
```

## Rules
1. RED first. Test must fail before code.
2. One test per iteration. Assert observable behavior (return values, side effects), not internal calls.
3. No mocking unless external services. Every test has an assertion.
