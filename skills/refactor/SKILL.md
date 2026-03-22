---
name: refactor
description: |
  Large-scale refactoring skill. Activates when code needs structural transformation — extracting, inlining, moving, renaming, or reorganizing code at scale. Performs impact analysis before changes, uses a pattern library of proven refactoring techniques, plans migration strategies for large changes, and verifies correctness with test suites after every transformation. Triggers on: /godmode:refactor, "refactor this", "extract", "rename", "move", "reorganize", or when /godmode:review identifies maintainability issues.
---

# Refactor — Large-Scale Code Transformation

## When to Activate
- User invokes `/godmode:refactor`
- User says "refactor this", "clean this up", "reorganize"
- User asks to "extract", "inline", "move", "rename" code
- Review skill identifies maintainability score < 6/10
- Optimize skill identifies structural issues blocking performance
- User says "this code is messy", "tech debt", "needs cleanup"

## Workflow

### Step 1: Assess Refactoring Scope
Understand what needs to change and how risky it is:

```bash
# Measure current state
find . -name "*.ts" -o -name "*.js" -o -name "*.py" | xargs wc -l | sort -rn | head -20

# Find the target code
grep -rn "<pattern>" --include="*.ts" --include="*.js"

# ... (condensed)
```

```
REFACTORING ASSESSMENT:
┌──────────────────────────────────────────────────────┐
│  Target: <file or module>                             │
├──────────────────┬───────────────────────────────────┤
│  Lines of code   │  <N>                              │
│  Complexity      │  <cyclomatic complexity if avail> │
│  Test coverage   │  <N%>                             │
│  Dependents      │  <N files import this>            │
│  Dependencies    │  <N modules this imports>         │
│  Last modified   │  <date and by whom>               │
│  Risk level      │  <LOW | MEDIUM | HIGH | CRITICAL> │
└──────────────────┴───────────────────────────────────┘
```

Risk assessment:
```
LOW:     <10 dependents, >80% test coverage, isolated module
MEDIUM:  10-30 dependents, 50-80% test coverage
HIGH:    30+ dependents, <50% test coverage
CRITICAL: Core module, <30% test coverage, many dependents
```

### Step 2: Select Refactoring Pattern
Choose from the pattern library:

```
REFACTORING PATTERN LIBRARY:

EXTRACT PATTERNS:
├── Extract Function    — Pull code block into named function
├── Extract Class       — Split class responsibilities
├── Extract Interface   — Define contract from implementation
├── Extract Module      — Split file into multiple modules
├── Extract Variable    — Name complex expressions
└── Extract Parameter   — Make hardcoded value configurable

INLINE PATTERNS:
├── Inline Function     — Replace function with its body (too simple to be useful)
├── Inline Variable     — Replace variable with expression (unnecessary indirection)
└── Inline Class        — Merge class that does too little

```

### Step 3: Impact Analysis
Before making any changes, analyze the blast radius:

```bash
# Find all files that will be affected
grep -rl "<symbol-being-changed>" --include="*.ts" --include="*.js"

# Map the dependency graph
# For each affected file, check what ELSE depends on it

# ... (condensed)
```

```
IMPACT ANALYSIS:
┌──────────────────────────────────────────────────────────────┐
│  Refactoring: Extract UserService from UserController        │
├──────────────────────────────────────────────────────────────┤
│  DIRECTLY AFFECTED:                                           │
│  ✎ src/controllers/user.controller.ts  — extract methods     │
│  + src/services/user.service.ts         — new file            │
│  ✎ src/controllers/user.controller.spec.ts — update imports  │
│  + src/services/user.service.spec.ts    — new test file       │
│                                                               │
│  INDIRECTLY AFFECTED:                                         │
│  ✎ src/routes/user.routes.ts  — may need new injection       │
│  ✎ src/middleware/auth.ts     — uses UserController method   │
│                                                               │
│  NOT AFFECTED:                                                │
│  - src/controllers/product.controller.ts (no shared code)    │
│  - src/models/ (no interface changes)                        │
│                                                               │
│  TOTAL: 4 files modified, 2 files created, 2 files unchanged │
└──────────────────────────────────────────────────────────────┘
```

### Step 4: Ensure Safety Net
Verify tests exist and pass BEFORE refactoring:

```bash
# Run all tests
npm test 2>&1 | tail -10

# Run tests specific to the target
npx jest --testPathPattern="<target>" 2>&1

# ... (condensed)
```

```
SAFETY NET:
┌──────────────────────────────────────────────────────┐
│  Pre-Refactoring Test Status                          │
├──────────────────┬───────────────────────────────────┤
│  Total tests     │  147 passing, 0 failing           │
│  Target coverage │  78% (src/controllers/user.*)     │
│  Gaps identified │  No test for error path line 89   │
├──────────────────┴───────────────────────────────────┤
│  RECOMMENDATION: Write 1 characterization test for   │
│  the error path before proceeding                    │
└──────────────────────────────────────────────────────┘
```

If coverage is below 60% for the target code:
1. STOP refactoring
2. Write characterization tests that capture current behavior
3. Commit the tests: `"test: characterization tests for <target> before refactoring"`
4. Then proceed with the refactoring

### Step 5: Execute Refactoring
Apply the transformation in small, verifiable steps:

**Rule: One transformation per commit.** Never combine multiple refactoring patterns in a single commit.

For each step:
1. Apply the transformation
2. Run the full test suite
3. If tests pass, commit: `"refactor: <pattern> — <description>"`
4. If tests fail, revert and investigate

```
EXECUTION LOG:
Step 1: Extract getUserById, createUser, updateUser into UserService
  → Tests: 147 passing ✓
  → Commit: "refactor: extract UserService from UserController"

Step 2: Update UserController to inject UserService
  → Tests: 147 passing ✓
  → Commit: "refactor: inject UserService into UserController"

Step 3: Update auth middleware to use UserService directly
  → Tests: 147 passing ✓
  → Commit: "refactor: update auth middleware to use UserService"

Step 4: Move user validation to UserService
  → Tests: 145 passing, 2 failing ✗
  → REVERT — validation depends on request context
  → Revised approach: keep validation in controller, pass clean data to service
  → Tests: 147 passing ✓
  → Commit: "refactor: clarify validation boundary between controller and service"
```

### Step 6: Migration Strategy (for large refactors)
For refactoring that affects many dependents, use a phased migration:

```
MIGRATION STRATEGY: Strangler Pattern

Phase 1: CREATE new structure alongside old
  - Create UserService with methods extracted from UserController
  - Both old and new paths work
  - Commit and deploy

Phase 2: MIGRATE dependents one at a time
  - Update auth middleware to use UserService
  - Update admin routes to use UserService
  - Each migration is a separate commit
  - Tests pass after each migration

Phase 3: REMOVE old code paths
  - Delete extracted methods from UserController
```

### Step 7: Post-Refactoring Verification
After all transformations are complete:

```bash
# Run full test suite
npm test

# Check that no functionality changed
# Compare test count: should be same or higher
# Compare coverage: should be same or higher
# ... (condensed)
```

```
POST-REFACTORING REPORT:
┌──────────────────────────────────────────────────────┐
│  Refactoring Complete                                 │
├──────────────────┬───────────────────────────────────┤
│  Pattern used    │  Extract Service                  │
│  Commits         │  5 (all atomic, all green)        │
│  Tests before    │  147 passing                      │
│  Tests after     │  152 passing (+5 new)             │
│  Coverage before │  78%                              │
│  Coverage after  │  82%                              │
│  Files modified  │  4                                │
│  Files created   │  2                                │
│  Files deleted   │  0                                │
│  Dead code       │  None detected                    │
│  Behavior change │  None (refactor only)             │
└──────────────────┴───────────────────────────────────┘
```

## Key Behaviors

1. **Tests MUST pass after every step.** Refactoring means changing structure without changing behavior. If tests fail, the behavior changed. Revert.
2. **One pattern per commit.** "Extract and rename and move" is three commits, not one. Each commit should be independently revertable.
3. **Impact analysis before touching code.** Know the blast radius before you start. Surprises during refactoring mean you didn't analyze well enough.
4. **Low coverage = write tests first.** Never refactor code with <60% test coverage. Write characterization tests first.
5. **Strangler over big bang.** For large refactors, migrate incrementally. Never rewrite a module in one commit.
6. **Revert fast.** If a step breaks tests and the fix isn't obvious in 5 minutes, revert. Think more, then try again.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive refactoring with full analysis |
| `--extract <type>` | Extract function/class/module/interface |
| `--inline <target>` | Inline function/variable/class |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check for test framework: jest.config, vitest.config, pytest.ini, go test files
2. Check test coverage: look for coverage reports, nyc, c8, istanbul configs
3. Detect language/framework: package.json, tsconfig.json, pyproject.toml, go.mod
4. Scan for code quality tools: .eslintrc, .prettierrc, biome.json, ruff.toml
5. Check for CI pipeline: .github/workflows, .gitlab-ci.yml (refactoring needs green CI)
6. Detect monorepo structure: lerna.json, pnpm-workspace.yaml, nx.json, turborepo
7. Estimate codebase size: count files by extension, identify largest modules
```

## Iterative Refactoring Loop

```
current_iteration = 0
max_iterations = 15
refactor_targets = [list of files/modules to refactor, ordered by dependency depth]

WHILE refactor_targets is not empty AND current_iteration < max_iterations:
    target = refactor_targets.pop(0)
    1. Run full test suite — MUST be green before touching anything
    2. Analyze target: complexity score, coupling, number of dependents
    3. Plan transformation (extract, inline, move, rename, simplify)
    4. Apply transformation — ONE pattern per iteration
    5. Run type check (if applicable): tsc --noEmit / mypy / go vet
    6. Run tests: full suite if < 60s, else affected tests only
    7. IF tests fail → revert immediately, diagnose, try smaller step
    8. IF tests pass → commit: "refactor: <pattern> in <target>"
    9. current_iteration += 1

POST-LOOP: Run full test suite + coverage comparison (must not decrease)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER refactor without a green test suite first. No exceptions.
2. NEVER combine refactoring with behavior changes in the same commit.
3. ONE refactoring pattern per commit. Extract OR rename OR move — never all at once.
4. NEVER skip the impact analysis step. Know every caller before changing a signature.
5. NEVER delete code without verifying zero references (grep + type checker).
6. ALWAYS run tests after every transformation. No batching "I'll test at the end."
7. NEVER force-push refactoring branches. Every step must be revertable.
8. IF tests fail after a transformation, REVERT first, THEN diagnose. Do not debug forward.
9. Coverage MUST NOT decrease after refactoring. If it does, add tests before proceeding.
10. EVERY renamed symbol must be updated in comments, docs, and error messages — not just code.
```

## Output Format

After each refactoring skill invocation, emit a structured report:

```
REFACTORING REPORT:
┌──────────────────────────────────────────────────────┐
│  Pattern used        │  <Extract | Inline | Move | Rename | Simplify> │
│  Target              │  <file or module>              │
│  Commits             │  <N> (all atomic, all green)   │
│  Tests before        │  <N> passing                   │
│  Tests after         │  <N> passing (+<N> new)        │
│  Coverage before     │  <N>%                          │
│  Coverage after      │  <N>%                          │
│  Files modified      │  <N>                           │
│  Files created       │  <N>                           │
│  Files deleted       │  <N>                           │
│  Dead code           │  <N> unused exports detected   │
│  Behavior change     │  NONE (refactor only)          │
│  Verdict             │  PASS | REVERTED               │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every refactoring step for tracking:

```
timestamp	skill	target	pattern	tests_before	tests_after	coverage_before	coverage_after	status
2026-03-20T14:00:00Z	refactor	UserController	extract_service	147	152	78	82	pass
2026-03-20T14:30:00Z	refactor	auth.ts	rename_symbol	152	152	82	82	pass
```

## Success Criteria

The refactor skill is complete when ALL of the following are true:
1. All tests pass after every transformation step (no batching)
2. Test count is the same or higher than before refactoring
3. Test coverage is the same or higher than before refactoring
4. No behavior change (refactoring changes structure, not behavior)
5. Each transformation is a separate, revertable commit
6. No dead code left behind (verified with ts-prune or equivalent)
7. All renamed symbols are updated in comments, docs, and error messages
8. Impact analysis was performed before making changes

## Error Recovery

```
IF tests fail after a transformation:
  1. REVERT immediately — do not debug forward
  2. Investigate what the transformation changed that affected behavior
  3. Plan a smaller, more targeted transformation
  4. Apply the smaller step and re-run tests

IF coverage decreases after refactoring:
  1. Identify which lines/branches lost coverage
  2. Write tests for the uncovered paths BEFORE continuing
  3. Commit the new tests separately: "test: add coverage for <target>"
  4. Resume refactoring only after coverage is restored

IF dead code is detected after refactoring:
  1. Verify zero references with grep AND type checker
  2. Check for dynamic references (reflection, string-based imports)
```

## Keep/Discard Discipline
```
After EACH refactoring transformation:
  1. MEASURE: Run full test suite — do all tests pass? Did coverage decrease?
  2. COMPARE: Did cyclomatic or cognitive complexity decrease?
  3. DECIDE:
     - KEEP if: tests pass AND complexity reduced AND coverage maintained or increased
     - DISCARD if: tests fail OR both complexity metrics unchanged/increased OR coverage dropped
  4. COMMIT kept changes. REVERT discarded changes immediately — do not debug forward.

Never keep a refactoring that decreases test coverage.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All target modules below complexity thresholds (cyclomatic <= 10, cognitive <= 15)
  - Test count and coverage are same or higher than before
  - Zero dead code detected
  - User explicitly requests stop

DO NOT STOP just because:
  - Non-target modules still have high complexity (scope to what was requested)
  - A single transformation was discarded (try a different pattern)
```

## Refactoring Complexity Reduction Loop

Track cyclomatic and cognitive complexity before and after each refactoring, with explicit keep/discard decisions per transformation:

```
COMPLEXITY REDUCTION LOOP:

current_iteration = 0
max_iterations = 20
complexity_targets = [files/functions sorted by complexity, highest first]
total_complexity_before = measure_total_complexity()
reductions = []

WHILE complexity_targets is not empty AND current_iteration < max_iterations:
    current_iteration += 1
    target = complexity_targets.pop(0)

    # Measure BEFORE
    cyclomatic_before = measure_cyclomatic(target)
    cognitive_before = measure_cognitive(target)
```

### Complexity Metrics

```
COMPLEXITY MEASUREMENT:
┌──────────────────────────────────────────────────────────────┐
│  Metric               │ Threshold   │ Tool                   │
├───────────────────────┼─────────────┼────────────────────────┤
│  Cyclomatic complexity│ ≤ 10 per    │ eslint complexity rule │
│  (decision paths      │ function    │ radon (Python)         │
│  through a function)  │             │ gocyclo (Go)           │
│                       │             │ checkstyle (Java)      │
├───────────────────────┼─────────────┼────────────────────────┤
│  Cognitive complexity │ ≤ 15 per    │ SonarQube/SonarLint    │
│  (how hard it is for  │ function    │ eslint sonarjs plugin  │
│  a human to understand│             │ cognitive_complexity   │
│  the control flow)    │             │ (Python)               │
├───────────────────────┼─────────────┼────────────────────────┤
│  Lines of code (LOC)  │ ≤ 50 per   │ wc -l (raw)            │
```

### Keep/Discard Decision Matrix

```
KEEP/DISCARD CRITERIA:
┌──────────────────────────────────────────────────────────────┐
│  Condition                              │ Decision           │
├─────────────────────────────────────────┼────────────────────┤
│  Tests fail after transformation        │ DISCARD (always)   │
├─────────────────────────────────────────┼────────────────────┤
│  Cyclomatic AND cognitive both reduced  │ KEEP               │
├─────────────────────────────────────────┼────────────────────┤
│  Cyclomatic reduced, cognitive neutral  │ KEEP               │
├─────────────────────────────────────────┼────────────────────┤
│  Cognitive reduced, cyclomatic neutral  │ KEEP               │
├─────────────────────────────────────────┼────────────────────┤
│  Both metrics unchanged or increased    │ DISCARD            │
├─────────────────────────────────────────┼────────────────────┤
│  LOC increased > 30% without complexity │ DISCARD            │
```

### Complexity Reduction Report

```
COMPLEXITY REDUCTION REPORT:
┌──────────────────────────────────────────────────────────────┐
│  Target              │ Transformation     │ Before │ After   │
│                      │                    │ CC/Cog │ CC/Cog  │
├──────────────────────┼────────────────────┼────────┼─────────┤
│  <file:function>     │ <transformation>   │ <N>/<N>│ <N>/<N> │
│  Decision: KEEP|DISCARD — <reason>                           │
├──────────────────────┼────────────────────┼────────┼─────────┤
│  <file:function>     │ <transformation>   │ <N>/<N>│ <N>/<N> │
│  Decision: KEEP|DISCARD — <reason>                           │
├──────────────────────┴────────────────────┴────────┴─────────┤
│  SUMMARY                                                      │
│  Transformations attempted: <N>                               │
│  Transformations kept: <N>                                    │
│  Transformations discarded: <N>                               │
```

