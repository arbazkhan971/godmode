---
name: legacy
description: |
  Legacy code modernization skill. Activates when a developer needs to understand, stabilize, and incrementally modernize legacy codebases. Covers legacy code characterization, adding tests to untested code (Approval Testing, Golden Master, Characterization Tests), incremental modernization strategies, dependency upgrade paths, technology obsolescence assessment, and dead code removal. Triggers on: /godmode:legacy, "understand this legacy code", "add tests to old code", "modernize", "upgrade dependencies", "tech debt", "dead code", or when working with codebases that lack tests, use deprecated APIs, or have outdated dependencies.
---

# Legacy -- Legacy Code Modernization

## When to Activate
- User invokes `/godmode:legacy`
- User says "understand this legacy code", "what does this code do"
- User says "add tests to untested code", "this has no test coverage"
- User says "modernize this", "reduce tech debt", "upgrade dependencies"
- User says "is this dependency still maintained?", "dead code"
- User encounters code with no tests, no documentation, and unclear intent
- Codebase has dependencies with known vulnerabilities or EOL status
- Project uses deprecated APIs, frameworks, or language features
- Code review reveals patterns that indicate legacy concerns

## Workflow

### Step 1: Legacy Code Characterization
Understand the codebase before changing anything. Never modify legacy code without first understanding it.

```
LEGACY CODE ASSESSMENT:
+---------------------------------------------------------+
|  Codebase overview:                                      |
|    Language/Framework: <detected>                         |
|    Age:               <estimated from git history>       |
|    Size:              <files, LOC>                        |
|    Contributors:      <active / total from git log>      |
|    Last meaningful change: <date>                        |
+---------------------------------------------------------+
|  Health indicators:                                      |
|    Test coverage:     <percentage or "none detected">    |
|    Linter config:     <present / absent>                 |
|    CI/CD:             <present / absent>                 |
|    Documentation:     <present / minimal / absent>       |
|    Type safety:       <typed / untyped / partial>        |
+---------------------------------------------------------+
|  Dependency health:                                      |
|    Total dependencies:    <N>                            |
|    Outdated (minor):      <N>                            |
|    Outdated (major):      <N>                            |
|    Deprecated/EOL:        <N> (list names)               |
|    Known vulnerabilities: <N> (CRITICAL/HIGH/MEDIUM)     |
+---------------------------------------------------------+
|  Code quality signals:                                   |
|    Dead code detected:    <yes/no, estimated LOC>        |
|    Deprecated API usage:  <list>                         |
|    God classes/functions: <files with > 500 LOC>         |
|    Circular dependencies: <detected / none>              |
|    Copy-paste patterns:   <duplicated blocks detected>   |
+---------------------------------------------------------+
|  Risk assessment:                                        |
|    Change confidence:     <HIGH | MEDIUM | LOW | NONE>   |
|    Reason:                <why this confidence level>     |
+---------------------------------------------------------+
```

Detection commands:
```bash
# Git history analysis
git log --oneline --since="1 year ago" | wc -l         # Recent activity
git log --format="%aN" | sort -u | wc -l               # Total contributors
git log --format="%aN" --since="6 months ago" | sort -u # Active contributors

# Test coverage
npx jest --coverage --silent 2>/dev/null                # Node.js
pytest --cov --quiet 2>/dev/null                        # Python
go test -cover ./... 2>/dev/null                        # Go

# Dependency health
npm audit 2>/dev/null                                   # Node.js vulns
npm outdated 2>/dev/null                                # Node.js outdated
pip-audit 2>/dev/null                                   # Python vulns
pip list --outdated 2>/dev/null                         # Python outdated

# Code complexity
npx madge --circular src/ 2>/dev/null                   # Circular deps (Node.js)
```

### Step 2: Understanding Legacy Code

Before adding tests or making changes, build a mental model of the code:

#### Code Archaeology
```
CODE ARCHAEOLOGY TECHNIQUES:
+---------------------------------------------------------+
|  1. Git blame analysis                                   |
|     - Who wrote this code and when?                      |
|     - What was the original commit message?              |
|     - Has it been modified since? By whom?               |
|                                                          |
|  2. Dependency tracing                                   |
|     - What calls this function/class?                    |
|     - What does this function/class call?                |
|     - Draw the call graph for critical paths             |
|                                                          |
|  3. Runtime behavior observation                         |
|     - Add logging at entry/exit points                   |
|     - Capture actual inputs and outputs                  |
|     - Identify which code paths are actually exercised   |
|                                                          |
|  4. Comment and naming analysis                          |
|     - Do names reflect current behavior or original      |
|       intent that has since drifted?                     |
|     - Are comments accurate or misleading?               |
|     - What do TODO/FIXME/HACK comments reveal?           |
|                                                          |
|  5. Test reverse-engineering                             |
|     - If tests exist, what do they reveal about          |
|       expected behavior?                                 |
|     - What edge cases do tests cover (or miss)?          |
+---------------------------------------------------------+
```

#### Dependency Graph
```
DEPENDENCY GRAPH for <module>:
+---------------------------------------------------------+
|  Callers (who depends on this):                          |
|    <- module_a.function_x()                              |
|    <- module_b.class_y.method_z()                        |
|    <- route_handler /api/endpoint                        |
|                                                          |
|  Callees (what this depends on):                         |
|    -> database.query()                                   |
|    -> external_api.fetch()                               |
|    -> utils.helper_function()                            |
|                                                          |
|  Side effects:                                           |
|    - Writes to database table X                          |
|    - Sends email via SMTP                                |
|    - Modifies global state Y                             |
+---------------------------------------------------------+
```

### Step 3: Adding Tests to Untested Code

The most critical step in legacy modernization. You must have tests before you can safely change anything.

#### Characterization Tests (Golden Master / Approval Testing)
Characterization tests capture the CURRENT behavior of the code, not the INTENDED behavior. They answer: "What does this code actually do right now?"

```
CHARACTERIZATION TEST STRATEGY:
+---------------------------------------------------------+
|  Purpose: Capture current behavior as a safety net       |
|  NOT to validate correctness — to detect changes         |
+---------------------------------------------------------+
|                                                          |
|  Step 1: Identify critical paths                         |
|    - Which functions are called most often?              |
|    - Which functions handle money, auth, or data?        |
|    - Which functions have the most callers?              |
|                                                          |
|  Step 2: Capture inputs and outputs                      |
|    - Run the code with known inputs                      |
|    - Record the actual outputs (return values,           |
|      side effects, database writes, API calls)           |
|    - These become your expected values                   |
|                                                          |
|  Step 3: Write the characterization test                 |
|    - Input: the known input you captured                 |
|    - Expected: the actual output you observed            |
|    - The test PASSES today (by definition)               |
|    - The test FAILS if someone changes behavior          |
|                                                          |
|  Step 4: Edge case discovery                             |
|    - Pass NULL, empty string, zero, negative numbers     |
|    - Pass boundary values (MAX_INT, very long strings)   |
|    - Record what happens (even if it's an exception)     |
|    - Write tests for these edge cases too                |
+---------------------------------------------------------+
```

#### Characterization Test Templates

**JavaScript/TypeScript:**
```typescript
describe('LegacyOrderProcessor', () => {
  // Characterization test: captures CURRENT behavior
  // DO NOT change expected values unless you intentionally change behavior

  it('processes a standard order (characterization)', () => {
    const input = {
      items: [{ id: 'SKU-001', qty: 2, price: 29.99 }],
      customer: { id: 'CUST-100', tier: 'gold' },
      coupon: null,
    };

    const result = processOrder(input);

    // These values were captured from the running system
    // They document what the code DOES, not what it SHOULD do
    expect(result).toMatchInlineSnapshot(`
      {
        "subtotal": 59.98,
        "discount": 5.998,
        "tax": 4.8584,
        "total": 58.8404,
        "status": "pending",
      }
    `);
  });

  it('handles empty cart (characterization)', () => {
    const input = { items: [], customer: { id: 'CUST-100', tier: 'basic' }, coupon: null };
    const result = processOrder(input);

    // Current behavior: returns zero totals, not an error
    expect(result.total).toBe(0);
    expect(result.status).toBe('pending');
  });

  it('handles null customer (characterization)', () => {
    const input = { items: [{ id: 'SKU-001', qty: 1, price: 10 }], customer: null, coupon: null };

    // Current behavior: throws TypeError
    expect(() => processOrder(input)).toThrow(TypeError);
  });
});
```

**Python:**
```python
class TestLegacyOrderProcessor:
    """Characterization tests — capture CURRENT behavior."""

    def test_standard_order(self):
        """Characterization: standard order processing."""
        order = {
            "items": [{"id": "SKU-001", "qty": 2, "price": 29.99}],
            "customer": {"id": "CUST-100", "tier": "gold"},
            "coupon": None,
        }

        result = process_order(order)

        # Captured from running system — documents actual behavior
        assert result["subtotal"] == pytest.approx(59.98)
        assert result["discount"] == pytest.approx(5.998)
        assert result["total"] == pytest.approx(58.8404)
        assert result["status"] == "pending"

    def test_empty_cart(self):
        """Characterization: empty cart returns zero, not error."""
        order = {"items": [], "customer": {"id": "CUST-100", "tier": "basic"}, "coupon": None}
        result = process_order(order)
        assert result["total"] == 0

    def test_null_customer(self):
        """Characterization: null customer raises AttributeError."""
        order = {"items": [{"id": "SKU-001", "qty": 1, "price": 10}], "customer": None, "coupon": None}
        with pytest.raises(AttributeError):
            process_order(order)
```

#### Golden Master Testing
For complex outputs (HTML rendering, report generation, file processing):

```
GOLDEN MASTER PATTERN:
+---------------------------------------------------------+
|  1. Run the legacy code with a representative input set  |
|  2. Save the output as the "golden master" file          |
|  3. Write a test that runs the same input and compares   |
|     output to the golden master                          |
|  4. Any deviation from the golden master fails the test  |
+---------------------------------------------------------+

File structure:
  tests/
    golden-masters/
      report-generator/
        input-standard.json          # Input fixture
        output-standard.golden.html  # Golden master output
      pdf-processor/
        input-invoice.pdf
        output-invoice.golden.txt
```

```typescript
describe('ReportGenerator (golden master)', () => {
  it('matches golden master for standard report', () => {
    const input = readFixture('report-generator/input-standard.json');
    const goldenMaster = readFixture('report-generator/output-standard.golden.html');

    const result = generateReport(input);

    expect(result).toBe(goldenMaster);
  });

  // To update golden master after intentional change:
  // UPDATE_GOLDEN=true npm test
  if (process.env.UPDATE_GOLDEN) {
    it('updates golden master', () => {
      const input = readFixture('report-generator/input-standard.json');
      const result = generateReport(input);
      writeFixture('report-generator/output-standard.golden.html', result);
    });
  }
});
```

#### Approval Testing
Using approval testing libraries for snapshot-based verification:

```typescript
// Using jest snapshots as approval tests
describe('LegacyEmailFormatter', () => {
  it('formats welcome email (approval)', () => {
    const result = formatWelcomeEmail({
      name: 'Jane Doe',
      plan: 'pro',
      trialDays: 14,
    });

    // First run: creates snapshot
    // Subsequent runs: compares to snapshot
    // Update: npm test -- -u
    expect(result).toMatchSnapshot();
  });
});
```

### Step 4: Incremental Modernization Strategies

After tests are in place, modernize the code incrementally:

```
MODERNIZATION PRIORITY MATRIX:
+---------------------------------------------------------+
|  Priority | Category          | Actions                  |
|  --------------------------------------------------------|
|  P0       | Security          | Patch vulnerable deps,   |
|  (urgent) |                   | fix auth issues, remove  |
|           |                   | hardcoded secrets         |
|  --------------------------------------------------------|
|  P1       | Stability         | Add tests to critical    |
|  (high)   |                   | paths, fix error handling,|
|           |                   | add logging               |
|  --------------------------------------------------------|
|  P2       | Maintainability   | Extract god classes,     |
|  (medium) |                   | reduce complexity, add   |
|           |                   | types, remove dead code   |
|  --------------------------------------------------------|
|  P3       | Performance       | Optimize hot paths,      |
|  (normal) |                   | add caching, fix N+1     |
|           |                   | queries                   |
|  --------------------------------------------------------|
|  P4       | Modernization     | Upgrade frameworks,      |
|  (low)    |                   | adopt new patterns,      |
|           |                   | improve DX                |
+---------------------------------------------------------+
```

#### Refactoring Patterns for Legacy Code
```
SAFE REFACTORING TECHNIQUES:
+---------------------------------------------------------+
|  1. Extract Method                                       |
|     - Identify a block of code that does one thing       |
|     - Extract it into a named function                   |
|     - Replace original code with function call           |
|     - Run characterization tests: must still pass        |
|                                                          |
|  2. Extract Class                                        |
|     - God class with 1000+ LOC and 20+ methods          |
|     - Group related methods and data                     |
|     - Extract into a focused class                       |
|     - Original class delegates to new class              |
|                                                          |
|  3. Replace Conditional with Polymorphism                |
|     - Giant switch/case or if/else chain                 |
|     - Create interface + implementations for each case   |
|     - Route to correct implementation via factory        |
|                                                          |
|  4. Introduce Parameter Object                           |
|     - Function with 6+ parameters                       |
|     - Group related parameters into an object/struct     |
|     - Pass the object instead of individual params       |
|                                                          |
|  5. Wrap External Dependency                             |
|     - Direct calls to database, API, filesystem          |
|     - Create wrapper/adapter with clean interface        |
|     - Replace direct calls with wrapper                  |
|     - Now testable with mocks                            |
|                                                          |
|  6. Sprout Method / Sprout Class                         |
|     - New feature needed in legacy code                  |
|     - Do NOT modify the legacy function                  |
|     - Create new function with tests                     |
|     - Call new function from legacy code                  |
|     - Legacy code is unchanged; new code is tested       |
+---------------------------------------------------------+
```

### Step 5: Dependency Upgrade Paths

Upgrade outdated dependencies safely:

```
DEPENDENCY UPGRADE STRATEGY:
+---------------------------------------------------------+
|  Step 1: Audit current dependencies                      |
|    npm outdated / pip list --outdated / go list -m -u    |
|    npm audit / pip-audit / govulncheck                   |
|                                                          |
|  Step 2: Categorize updates                              |
|    PATCH (x.y.Z): Bug fixes — safe, apply immediately   |
|    MINOR (x.Y.z): New features, backward compatible —   |
|                    apply after reading changelog          |
|    MAJOR (X.y.z): Breaking changes — requires migration  |
|                    plan per dependency                    |
|                                                          |
|  Step 3: Upgrade order                                   |
|    1. Security vulnerabilities (CRITICAL/HIGH first)     |
|    2. Patch updates (batch, low risk)                    |
|    3. Minor updates (one at a time, run tests)           |
|    4. Major updates (one at a time, read migration guide)|
|                                                          |
|  Step 4: For each major update                           |
|    - Read the changelog and migration guide              |
|    - Identify breaking changes that affect your code     |
|    - Update code to handle breaking changes              |
|    - Run full test suite                                 |
|    - Commit: "deps: upgrade <pkg> from <old> to <new>"  |
+---------------------------------------------------------+
```

#### Dependency Health Check
```
DEPENDENCY HEALTH REPORT:
+---------------------------------------------------------+
|  Package          | Current | Latest | Status            |
|  --------------------------------------------------------|
|  express          | 4.18.2  | 4.19.2 | OUTDATED (patch)  |
|  lodash           | 4.17.21 | 4.17.21| UP TO DATE        |
|  moment           | 2.29.4  | 2.30.1 | DEPRECATED (use   |
|                   |         |        | date-fns or luxon)|
|  request          | 2.88.2  | —      | EOL (use axios    |
|                   |         |        | or node-fetch)    |
|  webpack          | 4.46.0  | 5.91.0 | OUTDATED (major)  |
|  react            | 17.0.2  | 19.0.0 | OUTDATED (major)  |
+---------------------------------------------------------+
|  VULNERABILITIES:                                        |
|  - lodash < 4.17.21: Prototype Pollution (CRITICAL)     |
|  - express < 4.19.2: Path traversal (HIGH)              |
+---------------------------------------------------------+
|  RECOMMENDATIONS:                                        |
|  1. URGENT: Patch express (security)                     |
|  2. Replace moment with date-fns (deprecated)            |
|  3. Replace request with axios (EOL)                     |
|  4. Plan webpack 4 -> 5 migration                       |
|  5. Plan React 17 -> 19 migration                        |
+---------------------------------------------------------+
```

### Step 6: Technology Obsolescence Assessment

Evaluate whether technologies in the stack are nearing end-of-life:

```
TECHNOLOGY OBSOLESCENCE ASSESSMENT:
+---------------------------------------------------------+
|  Technology     | Status      | EOL Date    | Action     |
|  --------------------------------------------------------|
|  Node.js 16     | EOL         | 2023-09-11 | MIGRATE    |
|  Node.js 18     | Maintenance | 2025-04-30 | PLAN       |
|  Node.js 20     | Active LTS  | 2026-04-30 | CURRENT    |
|  Node.js 22     | Current     | 2027-04-30 | AVAILABLE  |
|  --------------------------------------------------------|
|  Python 3.8     | EOL         | 2024-10-14 | MIGRATE    |
|  Python 3.9     | Security    | 2025-10-05 | PLAN       |
|  Python 3.12    | Active      | 2028-10-02 | CURRENT    |
|  --------------------------------------------------------|
|  React 17       | Maintenance | —          | PLAN       |
|  React 18       | Active      | —          | CURRENT    |
|  React 19       | Latest      | —          | AVAILABLE  |
|  --------------------------------------------------------|
|  jQuery          | Legacy     | Community   | REPLACE    |
|  AngularJS (1.x) | EOL       | 2021-12-31 | URGENT     |
|  Moment.js       | Deprecated | —          | REPLACE    |
+---------------------------------------------------------+
|                                                          |
|  Status definitions:                                     |
|    EOL:         No longer receiving ANY updates          |
|    Security:    Only receiving security patches           |
|    Maintenance: Receiving bug fixes and security patches  |
|    Active LTS:  Recommended for production use           |
|    Current:     Latest features, may not be LTS yet      |
+---------------------------------------------------------+
```

### Step 7: Dead Code Removal

Identify and safely remove code that is never executed:

```
DEAD CODE DETECTION:
+---------------------------------------------------------+
|  Technique           | Tool                | Catches     |
|  --------------------------------------------------------|
|  Static analysis     | ESLint, Ruff,       | Unused      |
|                      | golangci-lint       | imports,    |
|                      |                     | variables,  |
|                      |                     | functions   |
|  --------------------------------------------------------|
|  Coverage analysis   | Jest --coverage,    | Code paths  |
|                      | pytest-cov,         | never       |
|                      | go test -cover      | executed    |
|  --------------------------------------------------------|
|  Dependency analysis  | depcheck, dpdm,    | Unused      |
|                      | npm-check           | packages    |
|  --------------------------------------------------------|
|  Git history          | git log --diff-     | Files not   |
|                      | filter=A -- <path>  | modified in |
|                      |                     | years       |
|  --------------------------------------------------------|
|  Runtime tracking    | Code instrumentation| Functions   |
|                      | in production       | never       |
|                      |                     | called      |
+---------------------------------------------------------+

SAFE REMOVAL PROCESS:
  1. Identify candidate dead code
  2. Verify with multiple signals (static + runtime + git history)
  3. Check for dynamic references (reflection, eval, config-driven)
  4. Remove in a dedicated commit (one concern per commit)
  5. Deploy and monitor for errors
  6. If errors appear, revert the commit
```

### Step 8: Modernization Roadmap and Report

```
LEGACY MODERNIZATION REPORT:
+---------------------------------------------------------+
|  Codebase:       <project name>                          |
|  Assessment date: <date>                                 |
|  Change confidence: <HIGH | MEDIUM | LOW | NONE>         |
+---------------------------------------------------------+
|  Critical issues (fix immediately):                      |
|  - <security vulnerability 1>                            |
|  - <EOL dependency 1>                                    |
+---------------------------------------------------------+
|  Modernization roadmap:                                  |
|                                                          |
|  Phase 1: Stabilize (1-2 weeks)                          |
|  - Add characterization tests to critical paths          |
|  - Fix security vulnerabilities                          |
|  - Set up CI/CD if absent                                |
|  - Add linting and formatting                            |
|                                                          |
|  Phase 2: Strengthen (2-4 weeks)                         |
|  - Replace deprecated dependencies                      |
|  - Extract god classes / long functions                  |
|  - Remove dead code                                      |
|  - Increase test coverage to 60%+                        |
|                                                          |
|  Phase 3: Modernize (ongoing)                            |
|  - Upgrade major dependencies                            |
|  - Adopt modern language features                        |
|  - Add type safety                                       |
|  - Improve error handling and logging                    |
+---------------------------------------------------------+
|  Files created:                                          |
|  - docs/legacy/<project>-assessment.md                   |
|  - docs/legacy/<project>-roadmap.md                      |
|  - tests/ (characterization tests)                       |
+---------------------------------------------------------+
```

Commit: `"legacy: <action> -- <target> (<impact>)"`

## Key Behaviors

1. **Understand before changing.** Never modify legacy code without first understanding what it does. Use git blame, dependency tracing, and runtime observation. Changing code you do not understand creates bugs.
2. **Tests before refactoring.** The first action on any legacy codebase is adding characterization tests. These tests capture current behavior, not intended behavior. They are the safety net that makes all subsequent changes possible.
3. **Characterization tests document reality.** A characterization test that expects an exception on null input is not a bug in the test. It documents what the code actually does. Fix the behavior later, after you have the safety net.
4. **Golden master for complex outputs.** When the output is too complex to assert field by field (HTML, PDFs, reports), save the entire output as a golden master file and compare future outputs against it.
5. **Small, reversible steps.** Every modernization change must be small enough to review in one sitting and reversible with a single `git revert`. Large refactoring PRs hide bugs.
6. **Security first, then stability, then maintainability.** Patch vulnerabilities before refactoring. Add tests before upgrading. Upgrade dependencies before adopting new patterns.
7. **Dead code is a liability.** Every line of dead code is a line that misleads future developers, triggers false positives in searches, and increases cognitive load. Remove it.
8. **Replace deprecated dependencies proactively.** A deprecated dependency is a ticking clock. The longer you wait, the harder the replacement becomes as the ecosystem moves on.

## Example Usage

### Understanding legacy code
```
User: /godmode:legacy I need to understand the payment processing module

Legacy: Analyzing codebase...

LEGACY CODE ASSESSMENT:
  Language: JavaScript (Node.js, no TypeScript)
  Module: src/payments/ (8 files, 2,400 LOC)
  Test coverage: 0% (no test files found)
  Last modified: 14 months ago
  Contributors: 2 (both inactive)
  Change confidence: LOW

CODE ARCHAEOLOGY:
  - processPayment() is 340 lines with 12 nested conditionals
  - Direct Stripe API calls (no abstraction layer)
  - Error handling: bare try/catch with console.log
  - Global state: modifies shared `paymentCache` object
  - 3 TODO comments marked "HACK" from 2022

DEPENDENCY GRAPH:
  Callers: routes/checkout.js, routes/subscription.js, cron/retry-failed.js
  Callees: stripe SDK, database.query(), emailService.send()
  Side effects: writes to payments table, sends email, modifies global cache

RECOMMENDATION:
  1. Add characterization tests before any changes
  2. Wrap Stripe calls in adapter (for testability)
  3. Extract processPayment() into smaller functions
  4. Add proper error handling with typed errors

Start with characterization tests? [Y/n]
```

### Adding tests to untested code
```
User: /godmode:legacy Add tests to the report generator, it has zero coverage

Legacy: Analyzing src/reports/generator.js...

Module: generateReport() — 280 LOC, 0% coverage
Complexity: HIGH (cyclomatic complexity: 24)
Approach: Golden Master testing (output is complex HTML)

Step 1: Capturing golden masters...
  - Input: standard monthly report -> captured 4.2KB HTML output
  - Input: empty data set -> captured 800B HTML output
  - Input: single item -> captured 1.1KB HTML output

Step 2: Writing characterization tests...

Created: tests/reports/generator.characterization.test.js
  - 6 characterization tests covering:
    - Standard report (golden master comparison)
    - Empty data (golden master comparison)
    - Single item (golden master comparison)
    - Null input (captures current error behavior)
    - Invalid date range (captures current error behavior)
    - Large dataset (performance baseline: 240ms)

Created: tests/reports/golden-masters/
  - standard-report.golden.html
  - empty-report.golden.html
  - single-item-report.golden.html

All 6 tests passing. You now have a safety net for refactoring.
```

### Modernization assessment
```
User: /godmode:legacy Assess our codebase for tech debt and modernization

Legacy: Running full assessment...

TECHNOLOGY OBSOLESCENCE:
  Node.js 16: EOL (migrate to 20 LTS)
  express 4.17: Outdated (4.19 available, security fix)
  moment.js: Deprecated (replace with date-fns)
  request: EOL (replace with axios)

DEPENDENCY HEALTH:
  3 CRITICAL vulnerabilities (npm audit)
  12 outdated packages (7 patch, 3 minor, 2 major)

CODE QUALITY:
  Dead code: ~1,200 LOC across 8 files
  God classes: 3 files > 500 LOC
  Test coverage: 34% (target: 80%)
  No TypeScript (untyped codebase)

MODERNIZATION ROADMAP:
  Phase 1 (this sprint): Patch 3 critical vulns, upgrade Node to 20
  Phase 2 (next 2 weeks): Replace moment + request, remove dead code
  Phase 3 (next month): Add tests to reach 60%, extract god classes
  Phase 4 (ongoing): TypeScript migration, full modernization

Created: docs/legacy/assessment.md
Created: docs/legacy/modernization-roadmap.md
```

## HARD RULES
1. NEVER modify legacy code without characterization tests in place — tests MUST exist before any change.
2. NEVER rewrite from scratch — rewrites take 2-3x longer than estimated and lose years of accumulated bug fixes.
3. NEVER fix bugs in characterization tests — if the code returns 58.84 instead of 58.85, the test expects 58.84. Fix the bug separately.
4. NEVER upgrade all dependencies at once — one major dependency at a time, with full test suite run between each.
5. NEVER remove code you're "pretty sure" is dead — verify with static analysis AND runtime coverage AND git history.
6. NEVER modernize code scheduled for replacement — don't spend 2 weeks polishing code that dies in 3 months.
7. ALWAYS understand code before changing it — git blame, dependency tracing, runtime observation first.
8. ALWAYS make small, reversible changes — every change must be reviewable in one sitting and revertable with `git revert`.
9. ALWAYS prioritize security > stability > maintainability > performance > modernization.
10. ALWAYS commit dead code removal in dedicated commits — one concern per commit for easy revert.

## Auto-Detection
On activation, detect legacy codebase context automatically:
```
AUTO-DETECT:
1. Assess codebase age and activity:
   - git log --oneline --since="1 year ago" | wc -l (recent activity)
   - git log --format="%aN" --since="6 months ago" | sort -u (active contributors)
   - First commit date (codebase age)
2. Detect test coverage:
   - Look for test directories: tests/, test/, spec/, __tests__/
   - Check for test config: jest.config, pytest.ini, phpunit.xml
   - Run coverage if tool available: --coverage flag
3. Detect dependency health:
   - npm audit / pip-audit / govulncheck (vulnerabilities)
   - npm outdated / pip list --outdated (outdated packages)
   - Check for known deprecated packages (moment, request, etc.)
4. Detect code quality signals:
   - Linter config present? (.eslintrc, .flake8, .golangci.yml)
   - CI/CD present? (.github/workflows/, .gitlab-ci.yml, Jenkinsfile)
   - Type safety? (tsconfig.json, mypy.ini, type hints)
5. Detect complexity:
   - Files > 500 LOC (god classes/modules)
   - Circular dependency detection (madge --circular)
   - TODO/FIXME/HACK comment count
6. Classify change confidence:
   - Tests + CI + Types → HIGH
   - Tests but no CI → MEDIUM
   - No tests → LOW
   - No tests + no docs + no active contributors → NONE
```

## Incremental Modernization Loop
Legacy modernization is iterative — stabilize, test, improve, repeat:
```
current_phase = "assess"
phases = ["assess", "stabilize", "strengthen", "modernize"]

WHILE current_phase != "complete":
  IF current_phase == "assess":
    1. Run full codebase health assessment
    2. Generate dependency health report
    3. Identify critical paths (most-called, handles money/auth/data)
    4. Classify change confidence level
    5. current_phase = "stabilize"

  IF current_phase == "stabilize":
    current_module = 0
    critical_modules = [sorted by risk: highest first]
    WHILE current_module < len(critical_modules):
      module = critical_modules[current_module]
      1. ADD characterization tests (capture current behavior)
      2. FIX security vulnerabilities in this module
      3. ADD error handling if missing
      4. VERIFY: all characterization tests still pass
      5. COMMIT: "legacy: stabilize {module} — {N} characterization tests"
      6. current_module += 1
    current_phase = "strengthen"

  IF current_phase == "strengthen":
    1. Replace deprecated dependencies (one at a time, test between each)
    2. Remove verified dead code
    3. Extract god classes into focused modules
    4. Increase test coverage to 60%+
    5. current_phase = "modernize"

  IF current_phase == "modernize":
    1. Upgrade major dependencies (one at a time)
    2. Adopt modern language features (types, async/await)
    3. Improve DX (linting, formatting, editor config)
    4. current_phase = "complete"

EXIT when user-defined scope is complete
```

## Multi-Agent Dispatch
For large legacy codebases, parallelize assessment and stabilization:
```
DISPATCH parallel agents (one per concern):

Agent 1 (worktree: legacy-assess):
  - Full codebase health assessment
  - Scope: entire codebase (read-only analysis)
  - Output: Assessment report, dependency health, dead code report

Agent 2 (worktree: legacy-tests):
  - Add characterization tests to critical paths
  - Scope: top 10 most-called modules
  - Output: Characterization + golden master tests

Agent 3 (worktree: legacy-deps):
  - Patch security vulnerabilities, replace deprecated packages
  - Scope: package.json/requirements.txt/go.mod
  - Output: Updated dependencies with passing tests

Agent 4 (worktree: legacy-cleanup):
  - Dead code removal and god class extraction
  - Scope: files identified by assessment agent
  - Output: Smaller, focused modules with tests

MERGE ORDER: assess (report only, no merge) → tests → deps → cleanup
CONFLICT RESOLUTION: tests branch must pass before deps or cleanup merge
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive legacy assessment and modernization |
| `--assess` | Full codebase health assessment |
| `--characterize <path>` | Add characterization tests to a specific module |
| `--golden-master <path>` | Create golden master tests for complex outputs |
| `--deps` | Dependency health check and upgrade recommendations |
| `--obsolescence` | Technology obsolescence assessment |
| `--dead-code` | Detect and report dead code |
| `--roadmap` | Generate modernization roadmap |
| `--coverage` | Analyze test coverage gaps and prioritize |
| `--understand <path>` | Deep analysis of a specific module or function |
| `--dry-run` | Show modernization plan without making changes |

## Output Format
Print on completion:
```
LEGACY ASSESSMENT: {project_name}
Language/Framework: {language} | Age: {years} | Size: {files} files, {loc} LOC
Test coverage: {percentage}% | Change confidence: {HIGH|MEDIUM|LOW|NONE}
Dependencies: {total} total, {outdated} outdated, {deprecated} deprecated, {vulns} vulnerabilities
Dead code: ~{loc} LOC identified across {files} files
God classes: {N} files > 500 LOC
Modernization priority: {P0_count} urgent, {P1_count} high, {P2_count} medium
Roadmap: {N} phases over {timeline}
Artifacts: {list of files created}
```

## TSV Logging
Log every legacy session to `.godmode/legacy-results.tsv`:
```
timestamp	project	language	age_years	loc	test_coverage_pct	change_confidence	vulns	deprecated_deps	dead_code_loc	phases	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. Full codebase health assessment completed before any modifications.
2. Characterization tests added to critical paths before any refactoring.
3. Security vulnerabilities (CRITICAL/HIGH) addressed before any modernization work.
4. Dead code verified with at least 2 signals (static analysis + git history or runtime coverage) before removal.
5. Each refactoring step is small enough to review in one sitting and revertable with `git revert`.
6. Dependency upgrades done one major version at a time with full test suite run between each.
7. Modernization roadmap follows priority order: security > stability > maintainability > performance > modernization.
8. Every characterization test expects actual behavior, not intended behavior.

## Error Recovery
```
IF codebase has zero tests and user wants to refactor:
  → Block: "Add characterization tests to critical paths before any changes"
  → Identify top 5 most-called functions via dependency tracing
  → Write characterization tests for those 5 functions first
  → Only then allow refactoring to proceed

IF characterization test captures a bug as expected behavior:
  → This is correct — the test documents CURRENT behavior
  → Add a comment: "// BUG: returns 58.84, should be 58.85 (floating point). Fix in separate commit."
  → Fix the bug in a separate commit AFTER the characterization test is in place

IF dependency upgrade breaks tests:
  → Revert the upgrade: git revert
  → Read the migration guide for the specific dependency
  → Identify breaking changes that affect the codebase
  → Apply code fixes first, then re-apply the upgrade
  → Never upgrade multiple dependencies in the same commit

IF dead code removal causes runtime errors:
  → Immediate: git revert the removal commit
  → Investigate: the code was called via reflection, dynamic dispatch, or configuration
  → Add runtime tracking (instrument the function) for 1 week to confirm zero calls
  → Re-attempt removal only after runtime verification

IF god class extraction breaks existing callers:
  → Create a facade that delegates to the new focused classes
  → Old callers continue using the facade (no changes needed)
  → Migrate callers to use focused classes directly over time
  → Remove facade when all callers are migrated

IF team has no active contributors familiar with the legacy code:
  → Prioritize understanding over changing: code archaeology first
  → Add extensive inline comments documenting discovered behavior
  → Write characterization tests as documentation of current behavior
  → Do NOT modernize modules that no one understands yet
```

## Anti-Patterns

- **Do NOT refactor without tests.** Changing untested legacy code is gambling. You have no way to know if you broke something until users report it. Add characterization tests first, always.
- **Do NOT rewrite from scratch.** The urge to "just rewrite it" is the most dangerous impulse in software engineering. Rewrites take 2-3x longer than estimated and lose years of accumulated bug fixes and edge case handling.
- **Do NOT fix bugs in characterization tests.** If the code returns 58.84 instead of 58.85 due to a floating point issue, the characterization test should expect 58.84. Fix the bug after you have the safety net, in a separate commit.
- **Do NOT upgrade all dependencies at once.** Upgrading 15 packages in one commit means any test failure could be caused by any of 15 changes. Upgrade one major dependency at a time.
- **Do NOT remove code you are "pretty sure" is dead.** Verify with multiple signals: static analysis AND runtime coverage AND git history. Code called via reflection, configuration, or dynamic dispatch will not appear in static analysis.
- **Do NOT modernize code that is being replaced.** If a module is scheduled for replacement in 3 months, spending 2 weeks modernizing it is wasted effort. Focus modernization on code that will live for years.
- **Do NOT ignore the human factor.** Legacy code was written by people who had reasons for their decisions. Understand the constraints they faced before judging their code. Blame is counterproductive.
- **Do NOT skip the dependency audit.** A codebase running on EOL Node.js with 3 critical vulnerabilities is a security incident waiting to happen. Fix security first, modernize second.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run legacy modernization tasks sequentially: assessment, then tests, then deps, then cleanup.
- Use branch isolation per task: `git checkout -b godmode-legacy-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
