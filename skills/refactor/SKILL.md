---
name: refactor
description: Large-scale code refactoring and transformation.
---

## Activate When
- `/godmode:refactor`, "refactor this", "clean up"
- "extract", "inline", "move", "rename", "reorganize"
- Review skill identifies maintainability score < 6/10

## Workflow

### 1. Assess Refactoring Scope
```bash
find . -name "*.ts" -o -name "*.js" -o -name "*.py" \
  | xargs wc -l | sort -rn | head -20
grep -rn "<pattern>" --include="*.ts" --include="*.js"
```
```
Target: <file or module>
Lines: <N> | Complexity: <cyclomatic> | Coverage: <N%>
Dependents: <N files> | Risk: LOW|MEDIUM|HIGH|CRITICAL
```
Risk levels:
- LOW: <10 dependents, >80% coverage, isolated
- MEDIUM: 10-30 dependents, 50-80% coverage
- HIGH: 30+ dependents, <50% coverage
- CRITICAL: core module, <30% coverage, many dependents

IF coverage < 60%: write characterization tests first.
IF dependents > 30: use strangler pattern migration.

### 2. Select Refactoring Pattern
Extract (Function, Class, Interface, Module, Variable,
Parameter), Inline (Function, Variable), Move (Function,
Field), Rename (Symbol, File), Simplify (Conditional,
Loop, Guard Clause), Replace (Inheritance with Composition,
Conditional with Polymorphism).

### 3. Impact Analysis
```bash
grep -rl "<symbol>" --include="*.ts" --include="*.js"
```
Map directly affected (modified), indirectly affected
(imports changed), and not affected files.

### 4. Verify Safety Net
```bash
npm test 2>&1 | tail -10
npx jest --testPathPattern="<target>" 2>&1
```
IF coverage < 60%: STOP, write characterization tests,
commit them separately, then proceed.

### 5. Execute Refactoring
One transformation per commit. For each step:
1. Apply transformation
2. Run full test suite
3. Pass -> commit: `"refactor: <pattern> -- <desc>"`
4. Fail -> revert and investigate

IF tests fail after transformation: revert first,
then diagnose. Never debug forward.

### 6. Migration Strategy (Large Refactors)
Strangler pattern: create new alongside old, migrate
dependents one at a time, each migration = separate
commit, remove old code only after zero references.

IF >5 dependents: phase the migration over multiple PRs.

### 7. Post-Refactoring Verification
```bash
npm test
```
Compare: test count same or higher, coverage same or
higher, no behavior change. Report pattern used, commits,
files modified/created/deleted.

## Hard Rules
1. NEVER refactor without green test suite first.
2. NEVER combine refactoring with behavior changes.
3. ONE pattern per commit.
4. NEVER skip impact analysis.
5. NEVER delete code without verifying zero references.
6. ALWAYS run tests after every transformation.
7. NEVER force-push refactoring branches.
8. IF tests fail: REVERT first, THEN diagnose.
9. Coverage MUST NOT decrease after refactoring.
10. EVERY renamed symbol: update comments, docs, errors.

## Complexity Thresholds
```
Cyclomatic: <= 10/function (eslint, radon, gocyclo)
Cognitive:  <= 15/function (SonarQube, eslint sonarjs)
LOC:        <= 50/function (wc -l)
```

## TSV Logging
Append `.godmode/refactor.tsv`:
```
timestamp	target	pattern	tests_before	tests_after	coverage_before	coverage_after	status
```

## Keep/Discard
```
KEEP if: tests pass AND complexity reduced
  AND coverage maintained or increased.
DISCARD if: tests fail OR complexity unchanged
  OR coverage dropped.
```

## Stop Conditions
```
STOP when FIRST of:
  - All targets below thresholds
    (cyclomatic <= 10, cognitive <= 15)
  - Test count and coverage same or higher
  - Zero dead code detected
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Tests fail after transform | Revert, plan smaller step |
| Coverage decreases | Write tests before continuing |
| Circular dependency | Extract shared into new module |
