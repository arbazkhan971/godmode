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
    # 3. GREEN — run test → must FAIL first. If passes immediately: test is wrong, delete and rewrite. Then write minimum code → PASS.
    # 4. REFACTOR — remove duplication in test code. Run ALL tests. If unrelated test breaks → revert, investigate.
    # 5. COMMIT: `git add {test_file} && git commit -m "test({module}): {what_behavior_is_tested}"`
    # 6. MEASURE: coverage = measure_coverage()
    # 7. APPEND .godmode/test-results.tsv: iteration, test_file, lines_covered, coverage_before, coverage_after, delta
    IF current_iteration % 5 == 0:
        "Test iter {N}: coverage {coverage}% (target: {target}%)"
Print: "Coverage: {start}% → {coverage}% in {N} iterations"
```

## Output Format
Print: `Test: coverage {start}% → {final}% (target: {target}%). {N} tests added in {iters} iterations. Status: {DONE|PARTIAL}.`

## Rules
1. RED first — test must fail before implementation. If test passes immediately → the test is wrong, delete and rewrite.
2. One test per iteration (atomic, revertable). Assert return values, thrown errors, or side effects — never mock internals.
3. No mocking unless external I/O (network, filesystem, clock). Test names: `should_{verb}_when_{condition}`.
4. Min 1 assertion per test; 3+ recommended.
5. Priority: happy_path > error_path > edge_case > integration.
6. Assert behavior, not implementation details.

## Iteration Budget
Stop when FIRST of:
- Coverage >= target.
- 50 iterations reached (safety limit).
- Coverage plateaus (3 consecutive iterations with < 0.5% gain): stop, report partial coverage.
