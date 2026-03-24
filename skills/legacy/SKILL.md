---
name: legacy
description: |
  Legacy code modernization skill. Activates when a developer needs to understand, stabilize, and incrementally modernize legacy codebases. Covers legacy code characterization, adding tests to untested code (Approval Testing, Golden Master, Characterization Tests), incremental modernization strategies, dependency upgrade paths, technology obsolescence assessment, and dead code removal. Triggers on: /godmode:legacy, "understand this legacy code", "add tests to old code", "modernize", "upgrade dependencies", "tech debt", "dead code", or when working with codebases that lack tests, use deprecated APIs, or have outdated dependencies.
---

# Legacy -- Legacy Code Modernization

## When to Activate
- User invokes `/godmode:legacy`
- User says "understand this legacy code", "add tests to untested code"
- User says "modernize this", "reduce tech debt", "upgrade dependencies", "dead code"
- Codebase has no tests, deprecated APIs, EOL dependencies, or unclear intent

## Workflow

### Step 1: Legacy Code Characterization
Never modify legacy code without first understanding it.

```
LEGACY CODE ASSESSMENT:
  Language/Framework: <detected>  Age: <from git>  Size: <files, LOC>
  Contributors: <active/total>  Last meaningful change: <date>
  Test coverage: <% or "none">  Linter/CI/CD: <present/absent>
  Dependencies: <total>, <outdated minor/major>, <deprecated/EOL>, <vulnerabilities>
  Code quality: Dead code <LOC>, deprecated APIs, god classes (>500 LOC), circular deps
  Change confidence: HIGH | MEDIUM | LOW | NONE
```

Detection: `git log` analysis, `npm audit`/`pip-audit`, coverage tools, `madge --circular`.

### Step 2: Understanding Legacy Code
**Code Archaeology:** Git blame (who, when, why), dependency tracing (callers/callees/side effects), runtime observation (logging entry/exit), comment analysis (accurate or misleading?), existing test reverse-engineering.

### Step 3: Adding Tests to Untested Code
The most critical step. Tests before any changes.

**Characterization Tests:** Capture CURRENT behavior, not intended. Run code with known inputs, record actual outputs — these become expected values. The test PASSES today by definition and FAILS if behavior changes.

```typescript
it('processes a standard order (characterization)', () => {
  const result = processOrder(standardInput);
  // Values captured from running system — documents what code DOES
  expect(result).toMatchInlineSnapshot(`{ "total": 58.8404, "status": "pending" }`);
});

it('handles null customer (characterization)', () => {
  expect(() => processOrder({ ...input, customer: null })).toThrow(TypeError);
});
```

**Golden Master:** For complex outputs (HTML, PDFs, reports). Save entire output as golden master file, compare future outputs against it. Update with `UPDATE_GOLDEN=true`.

**Approval Testing:** Jest snapshots as approval tests. First run creates, subsequent runs compare, update with `-u`.

### Step 4: Incremental Modernization
```
PRIORITY:
  P0 (urgent):  Security — patch vulns, fix auth, remove hardcoded secrets
  P1 (high):    Stability — tests on critical paths, error handling, logging
  P2 (medium):  Maintainability — extract god classes, reduce complexity, types, remove dead code
  P3 (normal):  Performance — optimize hot paths, caching, fix N+1
  P4 (low):     Modernization — upgrade frameworks, new patterns, DX
```

**Safe refactoring techniques:** Extract Method, Extract Class, Replace Conditional with Polymorphism, Introduce Parameter Object, Wrap External Dependency, Sprout Method/Class (new tested code called from legacy, legacy unchanged).

### Step 5: Dependency Upgrades
Categorize: PATCH (safe, batch), MINOR (one at a time, read changelog), MAJOR (one at a time, read migration guide). Order: security vulns first, then patch, minor, major.

### Step 6: Technology Obsolescence
Assess each technology: EOL (no updates), Security (patches only), Maintenance (bugs+security), Active LTS (recommended), Current (latest). Flag EOL for urgent migration, Security for planning.

### Step 7: Dead Code Removal
Detect with: static analysis (ESLint, Ruff), coverage analysis, dependency analysis (depcheck), git history (files untouched for years), runtime tracking. Verify with multiple signals. Remove in dedicated commits. Deploy and monitor.

### Step 8: Report
```
LEGACY MODERNIZATION REPORT:
  Change confidence: <level>
  Critical issues: <vulns, EOL deps>
  Phase 1 (Stabilize): characterization tests, fix vulns, set up CI
  Phase 2 (Strengthen): replace deprecated deps, remove dead code, extract god classes
  Phase 3 (Modernize): upgrade major deps, add types, improve DX
```

Commit: `"legacy: <action> -- <target> (<impact>)"`

## Key Behaviors
1. **Understand before changing.** Git blame, dependency tracing, runtime observation first.
2. **Tests before refactoring.** Characterization tests are the safety net.
3. **Characterization tests document reality.** Expected exception on null IS correct.
4. **Golden master for complex outputs.**
5. **Small, reversible steps.** Every change reviewable and revertable.
6. **Security first.** Patch vulns before refactoring.
7. **Dead code is a liability.** Remove it.
8. **Replace deprecated deps proactively.** The longer you wait, the harder it gets.

## Flags & Options

| Flag | Description |
|--|--|
| `--assess` | Full codebase health assessment |
| `--characterize <path>` | Add characterization tests to module |
| `--golden-master <path>` | Create golden master tests |
| `--deps` | Dependency health check |
| `--dead-code` | Detect dead code |
| `--roadmap` | Generate modernization roadmap |
| `--understand <path>` | Deep analysis of specific module |

## HARD RULES
1. NEVER modify legacy code without characterization tests in place.
2. NEVER rewrite from scratch — rewrites take 2-3x longer and lose accumulated fixes.
3. NEVER fix bugs in characterization tests — document bug in comment, fix separately.
4. NEVER upgrade all dependencies at once — one major at a time.
5. NEVER remove code you're "pretty sure" is dead — verify with static + runtime + git.
6. NEVER modernize code scheduled for replacement.
7. ALWAYS make small, reversible changes.
8. ALWAYS prioritize: security > stability > maintainability > performance > modernization.

## Auto-Detection
```
1. Git history: activity, contributors, age
2. Test coverage: test dirs, config, run coverage
3. Dependency health: audit, outdated, deprecated
4. Code quality: linter, CI, types
5. Complexity: files >500 LOC, circular deps, TODO/FIXME count
6. Confidence: Tests+CI+Types=HIGH, Tests only=MEDIUM, None=LOW, Nothing=NONE
```

## Modernization Loop
```
ASSESS -> STABILIZE (characterization tests + fix vulns per critical module)
  -> STRENGTHEN (replace deprecated deps, remove dead code, extract god classes)
  -> MODERNIZE (upgrade major deps, add types, improve DX)
```

## Multi-Agent Dispatch
```
Agent 1 (legacy-assess): Full health assessment (read-only)
Agent 2 (legacy-tests): Characterization tests for top 10 critical modules
Agent 3 (legacy-deps): Patch vulns, replace deprecated packages
Agent 4 (legacy-cleanup): Dead code removal, god class extraction
MERGE ORDER: assess -> tests -> deps -> cleanup
```

## TSV Logging
Log to `.godmode/legacy-results.tsv`: `timestamp\tproject\tlanguage\tage_years\tloc\ttest_coverage_pct\tchange_confidence\tvulns\tdeprecated_deps\tdead_code_loc\tphases\tverdict`

## Success Criteria
1. Full assessment before any modifications.
2. Characterization tests on critical paths before refactoring.
3. CRITICAL/HIGH vulnerabilities addressed first.
4. Dead code verified with 2+ signals before removal.
5. Each step small enough to review and revertable.
6. Dependency upgrades one major at a time with test suite between.
7. Priority order followed: security > stability > maintainability.

## Error Recovery
- **Zero tests, user wants to refactor:** Block. Add characterization tests first.
- **Characterization test captures a bug:** Correct — document in comment, fix in separate commit.
- **Dep upgrade breaks tests:** Revert, read migration guide, fix code first, re-apply.
- **Dead code removal causes errors:** Revert, add runtime tracking for 1 week, re-attempt.
- **God class extraction breaks callers:** Create facade, migrate callers incrementally.
- **No one understands the code:** Prioritize understanding over changing. Code archaeology + characterization tests as documentation.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-legacy-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `Legacy: {files} files modernized. Dead code: {removed}. Tests added: {N}. Deps upgraded: {M}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH legacy modernization step:
  KEEP if: all existing tests pass AND characterization tests cover changed code AND no behavior change
  DISCARD if: existing tests break OR behavior changed without explicit approval OR dead code removal causes errors
  On discard: revert. Add more characterization tests before retrying.
```

## Autonomy
Never ask to continue. Loop autonomously. Loop until target or budget. Never pause. Measure before/after. Guard: test_cmd && lint_cmd. On failure: git reset --hard HEAD~1.

## Stop Conditions
```
STOP when ALL of:
  - Characterization tests cover all modified code paths
  - Dead code removed and verified with runtime tracking
  - Dependencies upgraded to supported versions
  - No behavior changes (unless explicitly approved)
```
