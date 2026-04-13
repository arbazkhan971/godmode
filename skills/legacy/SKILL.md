---
name: legacy
description: |
  Legacy code modernization skill. Characterization
  tests, golden master, incremental modernization,
  dependency upgrades, dead code removal.
  Triggers on: /godmode:legacy, "legacy code",
  "modernize", "tech debt", "dead code".
---

# Legacy — Legacy Code Modernization

## Activate When
- User invokes `/godmode:legacy`
- User says "understand this legacy code"
- User says "modernize", "tech debt", "dead code"
- Codebase has no tests, deprecated APIs, EOL deps

## Workflow

### Step 1: Legacy Code Characterization

```bash
# Assess codebase age and activity
git log --format='%ai' --reverse | head -1
git shortlog -sn --all | head -10
git log --since="6 months ago" --oneline | wc -l

# Check test coverage
ls -d test/ tests/ spec/ __tests__/ 2>/dev/null
npx jest --coverage 2>/dev/null || \
  pytest --cov 2>/dev/null || echo "No test runner"

# Audit dependencies
npm audit 2>/dev/null || pip-audit 2>/dev/null
npm outdated 2>/dev/null || pip list --outdated 2>/dev/null

# Find complexity hotspots
find . -name "*.ts" -o -name "*.py" -o -name "*.js" \
  | xargs wc -l 2>/dev/null | sort -rn | head -10
```

```
LEGACY ASSESSMENT:
  Language: <detected>, Age: <from git>
  Size: <files, LOC>
  Contributors: <active/total>
  Test coverage: <% or "none">
  Dependencies: <total>, <outdated>, <EOL>, <vulns>
  Dead code: <estimated LOC>
  Change confidence: HIGH | MEDIUM | LOW | NONE

CONFIDENCE LEVELS:
  Tests + CI + Types = HIGH
  Tests only = MEDIUM
  No tests = LOW
  Nothing = NONE

IF confidence == NONE: add characterization tests first
IF vulns > 0: prioritize security patches
IF EOL deps > 0: flag for urgent migration planning
IF files > 500 LOC: identify god classes to extract
```

### Step 2: Understanding Legacy Code
**Code Archaeology:**
- Git blame: who, when, why for each section
- Dependency tracing: callers, callees, side effects
- Runtime observation: add logging at entry/exit
- Comment analysis: accurate or misleading?

### Step 3: Adding Tests to Untested Code
The most critical step. Tests before any changes.

```
TEST STRATEGIES:
| Strategy          | When to Use              |
|-------------------|--------------------------|
| Characterization  | Capture current behavior |
| Golden Master     | Complex outputs (HTML)   |
| Approval Testing  | Snapshots as approval    |

CHARACTERIZATION TEST:
  Run code with known input
  Record actual output as expected value
  Test PASSES today by definition
  Test FAILS if behavior changes

THRESHOLDS:
  Critical paths: 100% must have tests before change
  Min characterization tests per module: 5
  Golden master update: requires UPDATE_GOLDEN=true
  IF test captures a bug: document, fix separately
```

### Step 4: Incremental Modernization

```
PRIORITY ORDER:
  P0 (urgent): Security — patch vulns, fix auth
  P1 (high): Stability — tests on critical paths
  P2 (medium): Maintainability — extract god classes
  P3 (normal): Performance — optimize hot paths
  P4 (low): Modernization — upgrade frameworks

SAFE REFACTORING TECHNIQUES:
  Extract Method, Extract Class
  Replace Conditional with Polymorphism
  Introduce Parameter Object
  Wrap External Dependency
  Sprout Method/Class (new tested code from legacy)

THRESHOLDS:
  Max change size per PR: 200 lines
  Each change must be independently revertable
  IF change breaks characterization test: revert
```

### Step 5: Dependency Upgrades

```
ORDER: security vulns → PATCH → MINOR → MAJOR

RULES:
  PATCH: safe to batch, apply all at once
  MINOR: one at a time, read changelog
  MAJOR: one at a time, read migration guide

THRESHOLDS:
  IF dep has known CVE: upgrade within 48 hours
  IF dep is EOL: plan migration within 2 weeks
  IF major upgrade breaks > 5 tests: pause, plan
  Run full test suite between each major upgrade
```

### Step 6: Dead Code Removal

```
DETECTION (require 2+ signals):
  Static analysis: ESLint no-unused, Ruff
  Coverage analysis: 0% coverage = likely dead
  Dependency analysis: depcheck/madge
  Git history: untouched for > 1 year
  Runtime tracking: instrumented but never called

PROCESS:
  1. Identify with static analysis
  2. Verify with git log (last touched date)
  3. Confirm with runtime tracking if available
  4. Remove in dedicated commit
  5. Deploy and monitor for errors
  6. IF errors: revert immediately

THRESHOLDS:
  Require 2+ signals before removing
  File untouched > 2 years: likely dead
  Export with 0 importers: likely dead
```

### Step 7: Report
```
LEGACY MODERNIZATION REPORT:
  Confidence: <before> → <after>
  Critical issues: <vulns, EOL deps>
  Phase 1: characterization tests + fix vulns
  Phase 2: replace deprecated, remove dead code
  Phase 3: upgrade major deps, add types
```

Commit: `"legacy: <action> — <target> (<impact>)"`

## Key Behaviors
Never ask to continue. Loop autonomously until done.

1. **Understand before changing.** Git blame first.
2. **Tests before refactoring.** Characterization tests.
3. **Small, reversible steps.** Every change revertable.
4. **Security first.** Patch vulns before refactoring.
5. **Dead code is a liability.** Remove it.
6. **Replace deprecated deps proactively.**

## HARD RULES
1. Never modify legacy code without tests in place.
2. Never rewrite from scratch — takes 2-3x longer.
3. Never fix bugs in characterization tests.
4. Never upgrade all dependencies at once.
5. Never remove code without 2+ signals it's dead.
6. Never modernize code scheduled for replacement.
7. Always make small, reversible changes.
8. Always prioritize: security > stability >
   maintainability > performance > modernization.

## Auto-Detection
```
1. Git history: activity, contributors, age
2. Test coverage: test dirs, config, run coverage
3. Dependency health: audit, outdated, deprecated
4. Complexity: files > 500 LOC, circular deps
5. Confidence: Tests+CI+Types=HIGH, None=NONE
```

<!-- tier-3 -->

## Quality Targets
- Target: >60% test coverage before major refactor
- Max function complexity: <20 cyclomatic complexity
- Target: <500 lines per file after extraction

## Output Format
Print: `Legacy: {files} modernized. Dead: {removed}.
  Tests added: {N}. Deps upgraded: {M}.
  Confidence: {before} -> {after}. Status: {status}.`

## TSV Logging
```
timestamp	project	language	age_years	loc	coverage_pct	confidence	vulns	deprecated	dead_loc	verdict
```

## Keep/Discard Discipline
```
KEEP if: existing tests pass AND characterization
  tests cover changed code AND no behavior change
DISCARD if: tests break OR behavior changed
  OR dead code removal causes errors
On discard: revert, add more tests, retry.
```

## Stop Conditions
```
STOP when ALL of:
  - Characterization tests cover modified paths
  - Dead code removed and verified
  - Dependencies upgraded to supported versions
  - No behavior changes unless approved
```

## Error Recovery
- Zero tests, wants to refactor: block, add tests first.
- Characterization captures bug: document, fix separately.
- Dep upgrade breaks tests: revert, read migration guide.
- Dead code removal errors: revert, add runtime tracking.
- God class extraction breaks callers: use facade pattern.
- No one understands code: archaeology + characterization.

