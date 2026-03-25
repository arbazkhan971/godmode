---
name: test
description: >
  TDD loop. RED-GREEN-REFACTOR until coverage
  target met.
---

## Activate When
- `/godmode:test`, "write tests", "test coverage"

## The Loop
```bash
# Measure current coverage
npx vitest --coverage 2>&1 | tail -5
# Or: pytest --cov=src --cov-report=term | grep TOTAL
# Or: go test -cover ./...
```
```
coverage = measure_coverage()
target = user_target OR 80
current_iteration = 0

WHILE coverage < target:
    current_iteration += 1
    # 1. FIND — coverage report, untested lines
    #    Priority: happy > error > edge > integration
    # 2. RED — write ONE test. It MUST fail.
    #    IF passes immediately: wrong test, delete
    # 3. GREEN — write minimum code -> PASS
    # 4. REFACTOR — remove test duplication
    #    Run ALL tests. IF unrelated breaks -> revert
    # 5. COMMIT: git add {file} && git commit
    # 6. MEASURE: coverage = measure_coverage()
    # 7. LOG to .godmode/test-results.tsv
    IF current_iteration % 5 == 0:
        print "Iter {N}: {coverage}% (target: {target}%)"

Print: "Coverage: {start}% -> {final}% in {N} iters"
```

## Output Format
Print: `Test: coverage {start}% -> {final}% (target: {target}%). {N} tests added in {iters} iterations. Status: {DONE|PARTIAL}.`

## Hard Rules
1. RED first -- test must fail before implementation.
   If passes immediately: wrong test, delete.
2. One test per iteration -- atomic, revertable.
3. No mocking unless external I/O (network, fs, clock).
   Test names: `should_{verb}_when_{condition}`.
4. Min 1 assertion per test; 3+ recommended.
5. Priority: happy_path > error_path > edge_case.
6. Never keep a test that does not increase coverage.
7. Never ask to continue. Loop autonomously.

## Keep/Discard Discipline
```
KEEP if: coverage increased AND all existing tests pass
DISCARD if: coverage unchanged OR existing test broke
  On discard: git reset --hard HEAD~1
  Log reason. Move to next uncovered path.
```

## Stop Conditions
```
STOP when FIRST of:
  - coverage >= target (default 80%)
  - 50 iterations reached (safety limit)
  - 3 consecutive iterations with <0.5% gain
  - >5 consecutive discards on different paths
```

## Error Recovery
| Failure | Action |
|---------|--------|
| Test passes immediately | Delete. Rewrite to test specific uncovered behavior. |
| Coverage unchanged | Check coverage report line-by-line. May hit covered paths. |
| Unrelated test breaks | Revert. Check shared state or import side effects. Fix isolation. |
| Coverage plateaus | Switch to integration tests. Check for dead code inflating denominator. |

## TSV Logging
Append to `.godmode/test-results.tsv`:
`iteration\ttest_file\tlines_covered\tcoverage_before\tcoverage_after\tdelta\tstatus`
Status: kept, discarded, plateau.
