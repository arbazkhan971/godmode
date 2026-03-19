---
name: quality
description: |
  Code quality & analysis skill. Activates when code needs structural improvement, technical debt assessment, or dependency health checks. Covers code duplication detection, cyclomatic/cognitive complexity analysis, technical debt identification, dependency analysis with circular dependency detection, and license compliance checking. Every finding includes location, severity, and actionable remediation. Triggers on: /godmode:quality, "code quality", "technical debt", "code smell", "complexity analysis", "dependency check", "license audit".
---

# Quality — Code Quality & Analysis

## When to Activate
- User invokes `/godmode:quality`
- User says "code quality", "code smells", "technical debt", "complexity"
- User asks "is this code maintainable?", "find duplicates", "check dependencies"
- Before major refactoring to understand current state
- After rapid prototyping to identify cleanup needed
- When onboarding to an unfamiliar codebase
- As part of pre-ship quality gate in `/godmode:ship` workflow

## Workflow

### Step 1: Define Analysis Scope
Determine what code to analyze:

```
QUALITY ANALYSIS SCOPE:
Target: <feature/module/entire project>
Files in scope: <list of files/directories>
Language(s): <detected languages>
Lines of code: <total LOC>
Test coverage: <percentage if available>

Analysis modules:
  [ ] Duplication detection
  [ ] Complexity analysis
  [ ] Technical debt identification
  [ ] Dependency analysis
  [ ] License compliance
```

### Step 2: Code Duplication Detection
Find duplicated code blocks that should be consolidated:

```
DUPLICATION ANALYSIS:
Method: AST-based structural comparison (not just text matching)
Minimum clone size: 6 lines / 50 tokens
Clone types detected:
  - Type 1: Exact clones (identical code)
  - Type 2: Parameterized clones (same structure, different identifiers)
  - Type 3: Structural clones (similar logic, different implementation)
```

For each duplication cluster found:
```
CLONE CLUSTER <N>:
Type: <1 | 2 | 3>
Instances: <count>
Lines per instance: <count>
Total duplicated lines: <instances x lines>

Locations:
  1. <file>:<start_line>-<end_line>
  2. <file>:<start_line>-<end_line>
  3. <file>:<start_line>-<end_line>

Representative code:
```<language>
<the duplicated code block>
```

Remediation strategy:
  - <EXTRACT FUNCTION | EXTRACT BASE CLASS | USE TEMPLATE | PARAMETERIZE>
  - Target location: <where the shared code should live>
  - Estimated effort: <LOW | MEDIUM | HIGH>

Proposed extraction:
```<language>
<the consolidated code>
```
```

#### Duplication Metrics
```
DUPLICATION SUMMARY:
Total clone clusters: <N>
Total duplicated lines: <N> / <total LOC> (<percentage>)
Duplication ratio: <percentage>

Thresholds:
  < 3%:   EXCELLENT — minimal duplication
  3-5%:   GOOD — acceptable for most projects
  5-10%:  WARNING — consolidation recommended
  10-20%: POOR — significant maintenance burden
  > 20%:  CRITICAL — high risk of inconsistent bug fixes
```

### Step 3: Complexity Analysis
Measure cyclomatic complexity and cognitive complexity for every function:

#### Cyclomatic Complexity
Counts linearly independent paths through the code:
```
Each +1:
  - if / else if / else
  - for / while / do-while
  - case (in switch)
  - catch
  - && / || (boolean operators)
  - ? : (ternary)
```

#### Cognitive Complexity
Measures how difficult code is for a human to understand:
```
Each +1 (fundamentals):
  - if, else if, else
  - for, while, do-while, for...in, for...of
  - catch
  - switch
  - Sequences of logical operators (a && b && c = +1, not +2)
  - goto, break/continue to label

Each +1 (nesting increment, adds to nesting level):
  - Nested control structures add their nesting depth
  - Lambda/closure adds nesting
  - Recursion adds +1 per recursive call
```

For each function above threshold:
```
COMPLEXITY FINDING <N>:
Function: <name>
Location: <file>:<line>
Cyclomatic complexity: <value> (threshold: 10)
Cognitive complexity: <value> (threshold: 15)

Breakdown:
  Line <N>: if statement (+1 cyclomatic, +1 cognitive)
  Line <N>: nested for loop (+1 cyclomatic, +2 cognitive — nesting level 2)
  Line <N>: && operator (+1 cyclomatic, +1 cognitive)

Code:
```<language>
<the complex function with annotations>
```

Remediation:
  Strategy: <EXTRACT METHOD | REPLACE CONDITIONAL WITH POLYMORPHISM |
             DECOMPOSE CONDITIONAL | INTRODUCE GUARD CLAUSES |
             REPLACE LOOP WITH PIPELINE | STATE PATTERN>

  Refactored:
```<language>
<the simplified code>
```

  After refactoring:
    Cyclomatic: <old> → <new>
    Cognitive: <old> → <new>
```

#### Complexity Summary
```
COMPLEXITY SUMMARY:
Functions analyzed: <N>

Cyclomatic complexity distribution:
  1-5   (simple):     <N> functions (<percentage>)
  6-10  (moderate):   <N> functions (<percentage>)
  11-20 (complex):    <N> functions (<percentage>)
  21-50 (very complex): <N> functions (<percentage>)
  > 50  (untestable): <N> functions (<percentage>)

Average cyclomatic: <value>
Average cognitive: <value>
Worst offenders (top 5):
  1. <function> in <file> — CC: <N>, Cog: <N>
  2. <function> in <file> — CC: <N>, Cog: <N>
  3. <function> in <file> — CC: <N>, Cog: <N>
  4. <function> in <file> — CC: <N>, Cog: <N>
  5. <function> in <file> — CC: <N>, Cog: <N>
```

### Step 4: Technical Debt Identification
Systematically catalog technical debt across categories:

```
TECHNICAL DEBT INVENTORY:

Category 1: Code Smells
  For each finding:
  - Smell: <name — e.g., Long Method, God Class, Feature Envy, Data Clump>
  - Location: <file>:<line>
  - Severity: CRITICAL | HIGH | MEDIUM | LOW
  - Description: <what makes this a smell>
  - Remediation: <specific refactoring technique>
  - Estimated effort: <hours>

Category 2: Architecture Debt
  - Layering violations (UI calling database directly)
  - Missing abstractions (duplicated patterns without interface)
  - Inappropriate coupling (modules that change together but shouldn't)
  - Circular dependencies (A depends on B depends on A)

Category 3: Test Debt
  - Untested critical paths
  - Brittle tests (tests that break on non-behavioral changes)
  - Missing edge case coverage
  - Slow test suite (test execution time vs acceptable threshold)

Category 4: Documentation Debt
  - Public APIs without documentation
  - Outdated documentation that contradicts code
  - Missing architectural decision records
  - Complex algorithms without explanation

Category 5: Dependency Debt
  - Outdated dependencies with available updates
  - Dependencies with known vulnerabilities
  - Unused dependencies still in manifest
  - Pinned versions preventing security patches
```

#### Debt Prioritization Matrix
```
PRIORITIZATION:
Score = Impact x Likelihood x (1 / Effort)

  Impact: How much does this debt slow down development?
    5 — Blocks feature development
    4 — Causes frequent bugs
    3 — Slows down new developers
    2 — Minor inconvenience
    1 — Cosmetic only

  Likelihood: How likely is this to cause problems soon?
    5 — Actively causing issues now
    4 — Will cause issues within the sprint
    3 — Will cause issues within the quarter
    2 — Might cause issues eventually
    1 — Unlikely to cause issues

  Effort: How hard is it to fix?
    1 — Minutes (rename, extract variable)
    2 — Hours (extract method, add tests)
    3 — Days (refactor module, add abstraction)
    4 — Weeks (redesign component)
    5 — Months (rewrite subsystem)

PRIORITY RANKING:
1. <debt item> — Score: <N> (Impact: <N>, Likelihood: <N>, Effort: <N>)
2. <debt item> — Score: <N>
3. <debt item> — Score: <N>
...
```

### Step 5: Dependency Analysis
Map the dependency graph and identify structural issues:

```
DEPENDENCY GRAPH ANALYSIS:
Total modules/packages: <N>
Total dependencies: <N> edges
Average fan-in: <N> (how many modules depend on this one)
Average fan-out: <N> (how many modules this one depends on)

High fan-out modules (> <threshold>): <fragile, depend on too many things>
  - <module>: fan-out <N> — depends on: <list>
  - <module>: fan-out <N> — depends on: <list>

High fan-in modules (> <threshold>): <critical, many things depend on this>
  - <module>: fan-in <N> — depended on by: <list>
  - <module>: fan-in <N> — depended on by: <list>

Instability index per module:
  I = fan-out / (fan-in + fan-out)
  I = 0: maximally stable (many dependents, no dependencies)
  I = 1: maximally unstable (no dependents, many dependencies)

  Stable Abstract Principle violations:
  - Abstract modules that are unstable: <list>
  - Concrete modules that are stable: <list> (hard to change)
```

#### Circular Dependency Detection
```
CIRCULAR DEPENDENCIES FOUND:

Cycle <N>:
  <module A> → <module B> → <module C> → <module A>

  Impact: <why this is problematic>

  Breaking strategy:
    Option A: Dependency Inversion — extract interface in <module>,
              have <other module> depend on abstraction
    Option B: Extract shared module — move common code to new module
    Option C: Event-based decoupling — replace direct call with event/callback

  Recommended: <option>
  Files to modify: <list>
```

### Step 6: License Compliance
Audit all dependencies for license compatibility:

```
LICENSE COMPLIANCE AUDIT:

Project license: <project's own license>
Compatible licenses: <list of licenses compatible with project license>
Incompatible licenses: <list of licenses that conflict>

Dependency license inventory:
  MIT: <N> packages — COMPATIBLE
  Apache-2.0: <N> packages — COMPATIBLE
  BSD-2-Clause: <N> packages — COMPATIBLE
  BSD-3-Clause: <N> packages — COMPATIBLE
  ISC: <N> packages — COMPATIBLE
  GPL-2.0: <N> packages — <COMPATIBLE | INCOMPATIBLE depending on project license>
  GPL-3.0: <N> packages — <COMPATIBLE | INCOMPATIBLE>
  LGPL-2.1: <N> packages — CONDITIONAL (dynamic linking OK, static may not be)
  AGPL-3.0: <N> packages — WARNING (network use triggers copyleft)
  UNLICENSED: <N> packages — RISK (no license = no permission)
  UNKNOWN: <N> packages — RISK (license not detected, manual review needed)
```

For each compliance issue:
```
LICENSE ISSUE <N>:
Package: <name>@<version>
License: <detected license>
Conflict: <why this is a problem>
Used by: <which of our modules imports this>
Risk level: HIGH | MEDIUM | LOW

Remediation options:
  1. Replace with compatible alternative: <alternative package>
  2. Obtain commercial license: <if dual-licensed>
  3. Isolate usage: <if LGPL, ensure dynamic linking>
  4. Remove dependency: <if functionality can be implemented internally>
```

### Step 7: Quality Report

```
┌────────────────────────────────────────────────────────────────┐
│  CODE QUALITY REPORT — <project>                               │
├────────────────────────────────────────────────────────────────┤
│  Duplication:                                                  │
│    Ratio: <N>% (<EXCELLENT | GOOD | WARNING | POOR | CRITICAL>)│
│    Clone clusters: <N>                                         │
│    Duplicated lines: <N>                                       │
│                                                                │
│  Complexity:                                                   │
│    Avg cyclomatic: <N>                                         │
│    Avg cognitive: <N>                                          │
│    Functions > threshold: <N>                                  │
│    Worst: <function> (CC: <N>, Cog: <N>)                       │
│                                                                │
│  Technical Debt:                                               │
│    Total items: <N>                                            │
│    CRITICAL: <N>  HIGH: <N>  MEDIUM: <N>  LOW: <N>            │
│    Estimated total effort: <hours/days>                        │
│                                                                │
│  Dependencies:                                                 │
│    Circular dependencies: <N>                                  │
│    High fan-out modules: <N>                                   │
│    High fan-in modules: <N>                                    │
│                                                                │
│  License Compliance:                                           │
│    Status: <PASS | ISSUES FOUND | FAIL>                        │
│    Incompatible: <N>  Unknown: <N>                             │
│                                                                │
│  Overall: <A | B | C | D | F>                                  │
│    A: Excellent — minimal debt, low complexity, clean deps     │
│    B: Good — some debt, manageable complexity                  │
│    C: Fair — notable debt, complexity hotspots                 │
│    D: Poor — significant debt, high complexity                 │
│    F: Critical — urgent remediation needed                     │
├────────────────────────────────────────────────────────────────┤
│  Priority actions:                                             │
│  1. <highest priority debt item>                               │
│  2. <second priority debt item>                                │
│  3. <third priority debt item>                                 │
│                                                                │
│  Next: /godmode:fix — Fix identified issues                    │
│        /godmode:optimize — Optimize high-complexity functions  │
└────────────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Save report as `docs/quality/<project>-quality-report.md`
2. Commit: `"quality: <project> — grade <grade> (<N> findings)"`
3. If grade D/F: "Significant quality issues found. Run `/godmode:fix` to address priority items."
4. If grade A/B/C: "Quality analysis complete. Run `/godmode:optimize` to improve hotspots or `/godmode:ship` to proceed."

## Auto-Detection

Before prompting the user, automatically detect project context:

```
AUTO-DETECT SEQUENCE:
1. Detect language and framework:
   - package.json -> JavaScript/TypeScript (check for React, Vue, Next.js, etc.)
   - Gemfile -> Ruby (check for Rails, Sinatra)
   - requirements.txt / pyproject.toml -> Python (check for Django, Flask, FastAPI)
   - go.mod -> Go
   - Cargo.toml -> Rust
2. Detect existing quality tools:
   - ESLint, Prettier, Biome -> JS/TS linting
   - Rubocop -> Ruby linting
   - Ruff, flake8, black, mypy -> Python linting
   - golangci-lint -> Go linting
   - clippy -> Rust linting
3. Detect test infrastructure:
   - Jest, Vitest, Mocha -> JS/TS testing
   - RSpec, Minitest -> Ruby testing
   - pytest, unittest -> Python testing
   - go test -> Go testing
4. Measure baseline metrics:
   - LOC count by language (cloc or tokei if available)
   - Test coverage from CI artifacts or coverage config
   - Existing complexity reports
5. Detect dependency management:
   - package-lock.json / yarn.lock / pnpm-lock.yaml
   - Gemfile.lock / Pipfile.lock / poetry.lock
   - go.sum / Cargo.lock
```

## Explicit Loop Protocol

For iterative quality remediation:

```
QUALITY IMPROVEMENT LOOP:
current_iteration = 0
max_iterations = 5
quality_grade = run_full_analysis()

WHILE current_iteration < max_iterations AND quality_grade < target_grade:
  current_iteration += 1

  1. IDENTIFY top finding:
     - Pick highest-priority item from quality report
     - Priority order: CRITICAL > circular deps > complexity > duplication > debt

  2. APPLY remediation:
     - Extract function / break cycle / consolidate duplicate / add test
     - One remediation per iteration (isolate impact)

  3. RE-ANALYZE:
     - Re-run affected analysis module (complexity, duplication, etc.)
     - Verify fix did not introduce regressions

  4. EVALUATE:
     - Record: { iteration, finding, fix, metric_before, metric_after }
     - IF quality_grade reached target: STOP
     - IF diminishing returns (improvement < 5%): STOP
     - ELSE: continue to next finding

  OUTPUT:
  Iteration | Finding | Fix | Before | After
  1         | CC=34   | extract method | CC=34 | CC=8
  2         | cycle   | DI pattern     | 2 cycles | 0 cycles
  ...
```

## Multi-Agent Dispatch

For large codebase quality analysis:

```
PARALLEL AGENTS:
Agent 1 — Duplication & Complexity (worktree: quality-code)
  - Run duplication detection across all source files
  - Calculate cyclomatic and cognitive complexity per function
  - Generate consolidated findings with remediation

Agent 2 — Dependency Analysis (worktree: quality-deps)
  - Map internal module dependency graph
  - Detect circular dependencies
  - Identify high fan-in/fan-out modules
  - Check for license compliance

Agent 3 — Technical Debt Inventory (worktree: quality-debt)
  - Scan for TODO/FIXME/HACK comments
  - Identify code smells (god class, long method, feature envy)
  - Catalog architecture violations
  - Score each item with Impact x Likelihood / Effort

Agent 4 — Test Quality (worktree: quality-tests)
  - Measure test coverage
  - Identify untested critical paths
  - Detect brittle tests
  - Measure test suite execution time

MERGE ORDER: All agents run independently, merge reports into unified quality grade.
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. EVERY finding MUST include exact file path and line number.
2. EVERY finding MUST include a concrete remediation — not just "this is bad."
3. NEVER report complexity without showing the specific lines that contribute.
4. NEVER fix all debt at once — address one finding per iteration, verify, continue.
5. NEVER treat all duplication as bad — evaluate if both copies serve the same purpose.
6. NEVER reduce complexity by splitting into incoherent micro-functions.
7. ALWAYS check license compliance — GPL in an MIT project is a legal emergency.
8. ALWAYS measure before and after — no unverified quality claims.
9. NEVER conflate test coverage percentage with test quality.
10. ALWAYS prioritize circular dependency breakage before other refactoring.
```

## Key Behaviors

1. **Measure, don't guess.** Every complexity score is calculated, every duplication is located, every dependency is mapped. No subjective assessments.
2. **Prioritize ruthlessly.** Not all debt is worth fixing. Use the Impact x Likelihood / Effort matrix to focus on what matters.
3. **Show the code.** Every finding references exact file and line. Every remediation shows the specific refactoring.
4. **Check licenses early.** A GPL dependency discovered at launch is a legal emergency. Check licenses as part of every quality audit.
5. **Circular dependencies are urgent.** They make testing, deployment, and reasoning about code significantly harder. Break them first.
6. **Complexity is a leading indicator.** High complexity today means bugs tomorrow. Track it as a metric over time.

## Example Usage

### Analyzing a Node.js API project
```
User: /godmode:quality Analyze the quality of our API

Quality: Scanning codebase...

QUALITY ANALYSIS:
Target: src/
Language: TypeScript
LOC: 12,847
Test coverage: 67%

Duplication: 7.2% (WARNING)
  12 clone clusters, 924 duplicated lines
  Worst: validation logic duplicated across 5 controllers

Complexity:
  Avg cyclomatic: 6.3
  Avg cognitive: 8.1
  12 functions above threshold
  Worst: processOrder() — CC: 34, Cog: 47

Technical debt: 23 items
  CRITICAL: 2 (circular dependency, untested payment flow)
  HIGH: 5 (god class, missing error handling)
  MEDIUM: 9
  LOW: 7

Dependencies:
  2 circular dependency cycles
  3 high fan-out modules

License: PASS (all MIT/Apache-2.0/ISC)

Overall grade: C

Priority actions:
1. Break circular dependency: OrderService ↔ InventoryService
2. Refactor processOrder() (CC: 34 → target < 10)
3. Extract shared validation logic (924 duplicated lines)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full quality analysis (all modules) |
| `--duplication` | Duplication detection only |
| `--complexity` | Complexity analysis only |
| `--debt` | Technical debt identification only |
| `--deps` | Dependency analysis only |
| `--licenses` | License compliance audit only |
| `--threshold <N>` | Set complexity threshold (default: CC=10, Cog=15) |
| `--report` | Generate report without remediation suggestions |
| `--trend` | Compare against previous quality report |

## Anti-Patterns

- **Do NOT fix everything at once.** Quality improvement is iterative. Fix the highest-priority item, verify, then move to the next.
- **Do NOT treat all duplication as bad.** Sometimes two similar-looking functions serve different business purposes and should evolve independently. Use judgment.
- **Do NOT reduce complexity by just extracting random methods.** The goal is comprehensibility, not lower numbers. A function split into 12 tiny methods with no cohesion is worse than one clear 20-line function.
- **Do NOT ignore license compliance.** "We'll deal with it later" becomes "we need to rewrite this module before launch." Check early.
- **Do NOT skip dependency analysis.** Circular dependencies are silent killers — they make every change harder and every test more brittle.
- **Do NOT conflate coverage with quality.** 100% test coverage with bad tests is worse than 70% coverage with good tests. Quality of tests matters more than quantity.
- **Do NOT report findings without remediation.** "This function is too complex" is not actionable. "Extract the validation block on lines 45-67 into a validateInput() function" is actionable.
