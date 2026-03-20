---
name: test
description: TDD loop. RED-GREEN-REFACTOR until coverage target met.
---

## Activate When
- `/godmode:test`, "write tests", "test coverage", "add tests"

## The Loop
```
coverage = measure_coverage()  # e.g. vitest --coverage, pytest --cov, go test -cover
target = user_target OR 80
current_iteration = 0
WHILE coverage < target:
    current_iteration += 1
    # 1. FIND — use coverage report to identify untested lines. Priority: happy path > error path > edge case > integration
    # 2. RED — write ONE test for the identified uncovered path. It must FAIL.
    # 3. GREEN — run test → must FAIL. If passes: test is wrong, rewrite. Write minimum code → must PASS.
    # 4. REFACTOR — remove duplication in test code. Run ALL tests. If unrelated test breaks → revert, investigate.
    # 5. COMMIT: git commit -m "test({module}): {what_behavior_is_tested}"
    # 6. MEASURE: coverage = measure_coverage()
    # 7. LOG to .godmode/test-results.tsv: iteration, test_file, coverage_before, coverage_after, delta
    IF current_iteration % 5 == 0:
        "Test iter {N}: coverage {coverage}% (target: {target}%)"
Print: "Coverage: {start}% → {coverage}% in {N} iterations"
```

## Rules
1. RED first. Test must fail before code. If test passes immediately → the test is wrong or testing nothing.
2. One test per iteration. Assert observable behavior (return values, side effects), not internal calls.
3. No mocking unless external I/O (network, filesystem, time). Every test: ≥1 assertion + descriptive test name.
