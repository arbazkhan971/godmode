---
name: scenario
description: Edge case exploration. 12 dimensions, scored by likelihood x impact. Runnable tests for HIGH+.
---

## Activate When
- `/godmode:scenario`, "what could go wrong?", "edge cases", "failure modes", "break this", "stress test the design"
- Before shipping a new feature that handles user input, external APIs, or state mutations
- After `/godmode:plan` or `/godmode:build` when the feature has no edge case coverage yet

## Auto-Detection
The godmode orchestrator routes here when:
- A new feature touches input validation, auth, payments, or data persistence
- User asks "what if", "what happens when", "could this break"
- `/godmode:test` completed but coverage is only on happy paths (no error/boundary tests)
- A feature interacts with external services (APIs, databases, queues, file systems)

## Step-by-step Workflow

### 1. Read the Design
Read the spec, plan (`.godmode/plan.yaml` if exists), and implementation code. Trace the complete data flow:
```
User Input → Validation → Transform → Business Logic → Persist → Side Effects → Response
```
For each stage, list:
- **External calls**: API endpoints, DB queries, file I/O, queue publishes
- **State mutations**: What gets created, updated, deleted
- **Side effects**: Emails sent, webhooks fired, cache invalidated, events emitted
- **Trust boundaries**: Where untrusted data enters, where privilege escalation is possible

Print: `[scenario:read] Feature: {name} | {N} external calls | {N} state mutations | {N} side effects | {N} trust boundaries`

### 2. Identify the Feature Scope
Define the boundary of the exploration:
- **Entry points**: API routes, CLI commands, UI events, cron triggers, queue consumers
- **Dependencies**: Services, databases, caches, third-party APIs this feature calls
- **Data shapes**: Input schemas, output schemas, persisted models

Print: `[scenario:scope] {N} entry points | {N} dependencies | {N} data shapes`

### 3. Explore All 12 Dimensions
For EACH dimension, generate 2-5 specific scenarios. Every scenario MUST reference a code path (file:line) or spec section.

| # | Dimension | What to explore |
|--|--|--|
| 1 | **Invalid Input** | Malformed JSON, wrong types, SQL injection, XSS, oversized strings (>64KB), unicode (ZWJ, RTL, null bytes), negative IDs, NaN |
| 2 | **Boundary** | 0, 1, -1, MAX_INT, MAX_INT+1, empty string/array, null, undefined, exactly-at-limit |
| 3 | **Concurrency** | Race conditions, deadlocks, double-submit, read-your-writes, lost updates |

For each dimension, if truly not applicable, state why in one sentence. "N/A" alone is not acceptable.

Print per dimension: `[scenario:{dimension}] {N} scenarios found`

### 4. Score Every Scenario
For each scenario, assign:
- **Likelihood (L)**: 1 = nearly impossible, 2 = rare, 3 = occasional, 4 = likely, 5 = certain
- **Impact (I)**: 1 = cosmetic, 2 = degraded UX, 3 = feature broken, 4 = data loss/security breach, 5 = system down/compliance violation

Score = L x I. Severity thresholds:
- **CRITICAL**: Score >= 20 (e.g., L=5 x I=4, or L=4 x I=5)
- **HIGH**: Score 12-19
- **MEDIUM**: Score 6-11
- **LOW**: Score 1-5

Minimum valid score is 1x1=1. Score of 0 is invalid — every scenario has nonzero likelihood and nonzero impact.

Print: `[scenario:score] {total} scenarios scored: {critical} CRITICAL, {high} HIGH, {medium} MEDIUM, {low} LOW`

### 5. Sort and Prioritize
Sort all scenarios by score descending. Within the same score, prioritize:
1. Data loss / security breach scenarios first
2. Scenarios affecting the most users second
3. Scenarios with easiest reproduction third

Print the full table:
```
DIMENSION       | SCENARIO                           | L | I | SCORE | SEVERITY | CODE REF
Invalid Input   | SQL injection in search query       | 4 | 5 | 20    | CRITICAL | src/search.ts:42
Concurrency     | Race condition on balance update    | 3 | 5 | 15    | HIGH     | src/wallet.ts:88
...
```

### 6. Generate Test Skeletons for HIGH+ Scenarios
For every scenario scored HIGH (12+) or CRITICAL (20+), generate a runnable test file:
- Use the project's existing test framework (detect from package.json, pytest.ini, Cargo.toml, etc.)
- Follow ARRANGE / ACT / ASSERT structure
- Use real values from the codebase (actual route paths, actual model names, actual field names)
- Include setup and teardown (create test data, clean up after)
- Save to `tests/scenarios/{feature}.scenario.test.{ext}`

Run each test with the project's test command. No stubs, no TODOs, no `// implement later`.

```
# Example test structure (Jest):
describe('Search — SQL Injection', () => {
  it('should reject SQL injection in query parameter', async () => {
    // ARRANGE
    const maliciousQuery = "'; DROP TABLE users; --";
    // ACT
    const response = await request(app).get('/api/search').query({ q: maliciousQuery });
    // ASSERT
    expect(response.status).toBe(400);
    expect(response.body.error).toMatch(/invalid/i);
  });
});
```

Print: `[scenario:tests] {N} test files generated for {N} HIGH+ scenarios`

### 7. Verify Generated Tests Run
Run the generated test files to confirm they are syntactically valid and executable:
```bash
test_cmd -- tests/scenarios/{feature}.scenario.test.{ext}
```
- If a test fails to compile/parse: fix the syntax immediately.
- If a test fails because the scenario is a real bug: flag it as `BUG_FOUND` in the output table.
- If a test passes: the edge case is already handled — update severity to note "mitigated".

Print: `[scenario:verify] {passing}/{total} scenario tests executable. {bugs_found} real bugs discovered.`

### 8. Output Summary
Print the final summary:
```
Scenario Analysis: {feature}
{total} scenarios across 12 dimensions
{critical} CRITICAL | {high} HIGH | {medium} MEDIUM | {low} LOW
{tests_generated} tests generated | {bugs_found} bugs found
Test file: tests/scenarios/{feature}.scenario.test.{ext}
```

### 9. Log to TSV
Append each scenario as a row to `.godmode/scenario-log.tsv`.

## Output Format
Each stage prints a tagged line: `[scenario:{stage}] {details}`. Stages: `read`, `scope`, one per dimension, `score`, `tests`, `verify`. Final summary:
```
Scenario Analysis: {feature}
{total} scenarios across 12 dimensions
{critical} CRITICAL | {high} HIGH | {medium} MEDIUM | {low} LOW
{tests_generated} tests generated | {bugs_found} bugs found
Test file: tests/scenarios/{feature}.scenario.test.{ext}
```

## TSV Logging
File: `.godmode/scenario-log.tsv`
Columns:
```
timestamp	feature	dimension	scenario	likelihood	impact	score	severity	test_file	code_ref	status
```
Example row:
```
2026-03-20T14:30:00Z	user-search	Invalid Input	SQL injection in search query	4	5	20	CRITICAL	tests/scenarios/user-search.scenario.test.ts	src/search.ts:42	BUG_FOUND
```
Status values: `TEST_PASS` (edge case is handled), `TEST_FAIL` (bug found), `NO_TEST` (MEDIUM/LOW, no test generated), `BUG_FOUND` (test revealed a real vulnerability).

## Success Criteria
- [ ] All 12 dimensions explored — none skipped without a one-sentence justification
- [ ] Every scenario has a code reference (file:line) or spec section (heading)
- [ ] Every scenario is scored: L(1-5) x I(1-5) = S. No unscored rows. No zero scores.
- [ ] All CRITICAL and HIGH scenarios have runnable tests — not stubs, not TODOs
- [ ] Tests use the project's actual test framework and real code paths
- [ ] Generated tests are syntactically valid (confirmed by running them)
- [ ] Full scenario table printed with all columns
- [ ] TSV row appended per scenario with all columns populated
- [ ] Summary line printed with dimension count, severity breakdown, and test count

## Error Recovery
- **If no code exists yet (only a spec/plan)**: Generate scenarios from the spec. Use hypothetical file:line references like `{planned_file}:TBD`. Skip test generation (no code to test). Print `NOTE: Scenarios based on spec only. Re-run after /godmode:build.`
- **If the test framework is not detected**: Ask the user which framework to use. Fall back to pseudocode test skeletons with a comment `// Adapt to your test framework` at the top.
- **If a generated test has syntax errors**: Fix the syntax error in-place. If the error persists after 2 attempts, write the test as a comment block with `TODO: fix syntax` and flag it in the output.
- **If a dimension genuinely does not apply**: State why in one sentence in the scenario table. Example: "Time & Timezone: N/A — feature has no date/time logic, no scheduled jobs, no TTLs." This is acceptable. Leaving the dimension blank or writing only "N/A" is not.
- **If the feature is too large (>20 files)**: Break it into sub-features. Run scenario analysis per sub-feature. Merge results into one table and one TSV log.

## Hard Rules
1. All 12 dimensions must be explored — skipping requires a one-sentence justification.
2. Every scenario must have a code reference (file:line) or spec section heading.
3. Every scenario must be scored: L(1-5) x I(1-5). No zero scores, no unscored rows.
4. All CRITICAL and HIGH scenarios must have runnable tests — not stubs, not TODOs.
5. Generated tests must use the project's actual test framework and real code paths.
6. Measure before/after. Guard: test_cmd && lint_cmd.
7. On failure: git reset --hard HEAD~1.
8. Never ask to continue. Loop autonomously.

## Anti-Patterns
1. **Never skip a dimension without justification.** All 12 dimensions apply to most features. "Not relevant" requires a one-sentence explanation of why.
2. **Never leave a scenario unscored.** Every row needs L, I, and Score. Guessing is better than omitting — you can always note "estimate" in the TSV.
3. **Never write stub tests.** `it('should handle X', () => { /* TODO */ })` is not a test. Either write a complete ARRANGE/ACT/ASSERT or don't generate the file.
4. **Never generate scenarios without code references.** "SQL injection could happen" is useless. "SQL injection at `src/search.ts:42` where `req.query.q` is interpolated into `db.query()`" is actionable.
5. **Never confuse likelihood with impact.** A meteor destroying the datacenter is L=1, I=5. A missing null check on a required field is L=5, I=3. Score them separately.

## Examples

### Example 1: API endpoint scenario analysis
```
> /godmode:scenario POST /api/users

[scenario:read]    Feature: user-creation | 1 external call (DB) | 2 state mutations | 1 side effect (welcome email) | 1 trust boundary
[scenario:scope]   1 entry point | 2 dependencies | 2 data shapes
[scenario:invalid] 5 scenarios found
[scenario:boundary] 3 scenarios found
[scenario:concurrency] 2 scenarios found
[scenario:network] 2 scenarios found
[scenario:data] 3 scenarios found
[scenario:auth] 4 scenarios found
[scenario:time] 1 scenario found
[scenario:scale] 2 scenarios found
[scenario:failure] 3 scenarios found
[scenario:migration] 1 scenario found
[scenario:user-error] 2 scenarios found
```

### Example 2: Scenario table excerpt (payment checkout)
```
DIMENSION     | SCENARIO                                     | L | I | SCORE | SEVERITY
Invalid Input | Negative payment amount                      | 4 | 5 | 20    | CRITICAL
Concurrency   | Double-charge on rapid double-click           | 4 | 5 | 20    | CRITICAL
Network       | Payment gateway timeout after charge          | 3 | 5 | 15    | HIGH
Auth          | Expired session during checkout redirect      | 4 | 3 | 12    | HIGH
Failure       | Crash after charge, before order created      | 2 | 5 | 10    | MEDIUM
Time          | N/A — no date logic (TTLs handled by gateway) |   |   |       |
```

### Example 3: Scenario revealing a real bug
```
> /godmode:scenario "user search"

[scenario:verify]  4/6 scenario tests executable. 2 real bugs discovered.

BUG_FOUND: SQL injection at src/search.ts:42 — query parameter interpolated directly into SQL string.
BUG_FOUND: Unbounded result set at src/search.ts:58 — no LIMIT clause, returns all matching rows.

Recommend: /godmode:fix for the 2 bugs found, then re-run /godmode:scenario to confirm fixes.
```

## Scenario Testing Loop

Extended protocol for systematic edge case generation, boundary testing, and chaos testing:

```
SCENARIO TESTING LOOP:
current_iteration = 0
max_iterations = 5
testing_phases = [edge_case_generation, boundary_testing, chaos_testing, regression_scenario_bank, coverage_gap_analysis]

WHILE current_iteration < max_iterations:
  phase = testing_phases[current_iteration]
  current_iteration += 1

  IF phase == "edge_case_generation":
    PURPOSE: Systematically generate edge cases that developers commonly miss.

    1. ANALYZE each input to the feature:
       FOR each input_param in feature.inputs:
         type = detect_type(input_param)  # string, number, array, object, boolean, date, enum
```

## Keep/Discard Discipline
```
After EACH scenario test generation:
  KEEP if: test is syntactically valid AND uses real code paths AND follows ARRANGE/ACT/ASSERT
  DISCARD if: test has syntax errors after 2 fix attempts OR references nonexistent code
  On discard: log scenario as NO_TEST with reason. Do not write stub tests.
  Never keep a test skeleton with TODOs or placeholder assertions.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: all 12 dimensions explored AND all HIGH+ scenarios have tests
  - budget_exhausted: max iterations across all dimensions
  - diminishing_returns: 3 consecutive dimensions produce 0 HIGH+ scenarios
  - stuck: >5 test generation failures with no runnable output
```

