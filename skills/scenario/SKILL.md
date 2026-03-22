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
Define the boundary of what is being explored:
- **Entry points**: API routes, CLI commands, UI events, cron triggers, queue consumers
- **Dependencies**: Services, databases, caches, third-party APIs this feature calls
- **Data shapes**: Input schemas, output schemas, persisted models

Print: `[scenario:scope] {N} entry points | {N} dependencies | {N} data shapes`

### 3. Explore All 12 Dimensions
For EACH dimension, generate 2-5 specific scenarios. Every scenario MUST reference a code path (file:line) or spec section.

| # | Dimension | What to explore |
|---|-----------|-----------------|
| 1 | **Invalid Input** | Malformed JSON, wrong types, SQL injection, XSS, oversized strings (>64KB), unicode (ZWJ, RTL, null bytes), negative IDs, NaN |
| 2 | **Boundary** | 0, 1, -1, MAX_INT, MAX_INT+1, empty string/array, null, undefined, exactly-at-limit |
| 3 | **Concurrency** | Race conditions, deadlocks, double-submit, read-your-writes, lost updates |
| 4 | **Network** | Timeout, 5xx, DNS failure, partial response, retry storms, TLS expiry |
| 5 | **Data Integrity** | Corrupt DB data, stale cache, missing FK, orphaned records, encoding mismatch |
| 6 | **Auth & Authz** | Expired token, privilege escalation, IDOR, missing auth header, forged JWT, CSRF |
| 7 | **Time & Timezone** | DST, leap seconds, year 2038, date rollover, clock skew between services |
| 8 | **Scale** | 10x load, 100x data, N+1 queries, unbounded lists, pagination overflow, OOM |
| 9 | **Failure & Recovery** | Crash mid-transaction, OOM kill, disk full, partial write, retry idempotency |
| 10 | **Migration** | Schema migration with live traffic, backward-incompatible API, rollback after partial migration |
| 11 | **User Error** | Double-click submit, back button after POST, hidden chars in paste, bookmark stale URL |
| 12 | **Dependencies** | Third-party API down, unexpected response schema, rate-limited, breaking dep upgrade |

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

Each test must be runnable with the project's test command. No stubs, no TODOs, no `// implement later`.

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
[scenario:deps] 2 scenarios found
[scenario:score]   30 scenarios scored: 2 CRITICAL, 5 HIGH, 15 MEDIUM, 8 LOW
[scenario:tests]   7 test files generated for 7 HIGH+ scenarios
[scenario:verify]  6/7 scenario tests executable. 1 real bug discovered.

Scenario Analysis: user-creation
30 scenarios across 12 dimensions
2 CRITICAL | 5 HIGH | 15 MEDIUM | 8 LOW
7 tests generated | 1 bug found
Test file: tests/scenarios/user-creation.scenario.test.ts
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

         GENERATE edge cases by type:
         IF type == "string":
           - Empty string ""
           - Single character "a"
           - Maximum length string (fill to limit)
           - Over-maximum-length string (limit + 1)
           - Unicode: emoji, RTL text, ZWJ sequences, null bytes (\x00)
           - HTML/script injection: "<script>alert(1)</script>"
           - SQL injection: "'; DROP TABLE users; --"
           - Path traversal: "../../etc/passwd"
           - Whitespace-only: "   \t\n"
           - Leading/trailing whitespace: " value "

         IF type == "number":
           - Zero (0)
           - Negative (-1)
           - MAX_SAFE_INTEGER (9007199254740991)
           - MAX_SAFE_INTEGER + 1
           - MIN_SAFE_INTEGER
           - NaN
           - Infinity, -Infinity
           - Floating point: 0.1 + 0.2 (IEEE 754 precision)
           - Very small: 0.0000001
           - Scientific notation: 1e308

         IF type == "array":
           - Empty array []
           - Single element [1]
           - Very large array (10000 elements)
           - Nested arrays [[[[]]]]
           - Array with mixed types [1, "two", null, undefined]
           - Array with duplicates [1, 1, 1]
           - Sparse array (holes)

         IF type == "object":
           - Empty object {}
           - Nested deeply (10+ levels)
           - Circular reference
           - Prototype pollution: {"__proto__": {"admin": true}}
           - Very large object (1000+ keys)
           - Object with symbol keys
           - Object with numeric keys

         IF type == "date":
           - Epoch (1970-01-01T00:00:00Z)
           - Far future (9999-12-31)
           - Far past (0001-01-01)
           - Leap day (2024-02-29)
           - DST transition time
           - Timezone boundary (23:59:59 UTC vs 00:00:00 UTC+1)
           - Invalid date (2024-02-30)

         IF type == "boolean":
           - true, false
           - Truthy but not true: 1, "true", "yes", "1"
           - Falsy but not false: 0, "", null, undefined

    2. FILTER by relevance:
       Remove edge cases that cannot reach the code path
       Keep all edge cases that CAN reach the code path
       Score remaining by likelihood x impact

  IF phase == "boundary_testing":
    PURPOSE: Test at exact boundaries where behavior changes.

    1. IDENTIFY boundaries from code analysis:
       FOR each conditional in feature.code:
         IF condition is numeric comparison (x < 10, x >= 0, x == MAX):
           boundary_values = [threshold - 1, threshold, threshold + 1]
         IF condition is string length check:
           boundary_values = [max_length - 1, max_length, max_length + 1]
         IF condition is array size check:
           boundary_values = [limit - 1, limit, limit + 1, 0]
         IF condition is date comparison:
           boundary_values = [date - 1ms, date, date + 1ms]
         IF condition is null/undefined check:
           boundary_values = [null, undefined, "", 0, false]

    2. GENERATE boundary test matrix:
       BOUNDARY TEST MATRIX:
       ┌──────────────────────────┬───────────────┬──────────────┬──────────┐
       │  Boundary                │  Below        │  At          │  Above   │
       ├──────────────────────────┼───────────────┼──────────────┼──────────┤
       │  Max retries (3)         │  2 retries    │  3 retries   │  4 retries│
       │  Rate limit (100/min)    │  99 requests  │  100 requests│  101 req │
       │  Password min (8 chars)  │  7 chars      │  8 chars     │  9 chars │
       │  Page size (50)          │  49 items     │  50 items    │  51 items│
       │  Timeout (30s)           │  29s          │  30s         │  31s     │
       └──────────────────────────┴───────────────┴──────────────┴──────────┘

    3. FOR each boundary: generate test with ARRANGE/ACT/ASSERT
       Each test asserts different expected behavior on each side of the boundary

  IF phase == "chaos_testing":
    PURPOSE: Test system resilience to unexpected failures and adverse conditions.

    1. DEFINE chaos scenarios based on feature dependencies:

       INFRASTRUCTURE CHAOS:
       - Database connection drops mid-transaction
       - Redis cache becomes unavailable
       - DNS resolution fails for external API
       - Disk fills up during file write
       - Memory pressure causes GC pauses
       - Network partition between services

       TIMING CHAOS:
       - Request arrives during deployment (code hot-swap)
       - Clock skew between servers (NTP drift)
       - Cron job runs twice (duplicate execution)
       - Long GC pause causes timeout
       - Slow database query blocks connection pool

       DATA CHAOS:
       - Corrupted data in database (invalid JSON, wrong encoding)
       - Cache contains stale data from previous schema
       - Queue message delivered out of order
       - Duplicate message delivered (at-least-once semantics)
       - Message delivered after consumer restart (replay)

       DEPENDENCY CHAOS:
       - Third-party API returns unexpected schema
       - Third-party API returns 429 (rate limited)
       - Third-party API returns 500 (internal error)
       - Third-party API times out after 30 seconds
       - Third-party API returns partial response

    2. SCORE each chaos scenario:
       Likelihood: 1-5 (how often this happens in production)
       Impact: 1-5 (severity when it happens)
       Recovery: automatic / manual / impossible
       MTTR: estimated time to recover

    3. FOR each HIGH+ chaos scenario:
       Generate a test that simulates the failure:
       - Use dependency injection to inject failures
       - Use mock/stub to simulate timeout, error, unexpected response
       - Use chaos monkey approach for infrastructure tests
       - Verify the system degrades gracefully (not catastrophically)

    4. REPORT:
       CHAOS TEST RESULTS:
       ┌──────────────────────────┬───────┬────────────┬─────────────┐
       │  Chaos Scenario          │ Score │ Recovery   │ Test Status │
       ├──────────────────────────┼───────┼────────────┼─────────────┤
       │  DB connection drop      │ 15    │ automatic  │ PASS        │
       │  Cache unavailable       │ 12    │ automatic  │ PASS        │
       │  External API timeout    │ 20    │ manual     │ FAIL (BUG)  │
       │  Duplicate message       │ 10    │ automatic  │ PASS        │
       └──────────────────────────┴───────┴────────────┴─────────────┘

  IF phase == "regression_scenario_bank":
    PURPOSE: Build a persistent library of scenarios that protect against past bugs.

    1. SCAN git history for bug fixes:
       git log --oneline --grep="fix" --grep="bug" --grep="regression" --since="6 months ago"

    2. FOR each bug fix commit:
       a. Read the commit message and diff
       b. Identify the failure condition (what triggered the bug)
       c. Check if a regression test was added
       d. IF no regression test: generate one

    3. MAINTAIN scenario bank:
       File: tests/scenarios/regression-bank.test.{ext}
       Each test:
       - References the original bug fix commit SHA
       - Describes the failure condition
       - Tests the specific edge case that caused the bug
       - Prevents future regression

    4. REPORT:
       REGRESSION BANK:
       - Bug fixes in last 6 months: <N>
       - With regression tests: <N>
       - Missing regression tests: <N> (generated in this session)
       - Total scenarios in bank: <N>

  IF phase == "coverage_gap_analysis":
    PURPOSE: Find untested code paths that represent risk.

    1. RUN coverage with branch analysis:
       {coverage_cmd} --branch (or equivalent for the test framework)

    2. IDENTIFY uncovered branches:
       FOR each file in changed_files:
         uncovered_branches = branches with 0 executions
         FOR each uncovered_branch:
           - Read the code at that branch point
           - Determine what condition triggers this branch
           - Classify: error handling, edge case, feature flag, dead code

    3. PRIORITIZE coverage gaps by risk:
       HIGH:   Uncovered error handling (catch blocks, error callbacks)
       HIGH:   Uncovered authentication/authorization checks
       MEDIUM: Uncovered business logic branches
       MEDIUM: Uncovered validation paths
       LOW:    Uncovered logging/telemetry branches
       SKIP:   Dead code (unreachable branches)

    4. GENERATE targeted tests for HIGH and MEDIUM gaps:
       One test per uncovered branch, focusing on:
       - Error scenarios (what makes the error path execute?)
       - Edge cases (what input hits the uncovered branch?)
       - Boundary conditions (what value triggers the else clause?)

    5. REPORT:
       COVERAGE GAP ANALYSIS:
       ┌──────────────────────┬──────────┬──────────────┬────────────┐
       │  Gap Type            │  Count   │  Risk        │  Tests Gen │
       ├──────────────────────┼──────────┼──────────────┼────────────┤
       │  Error handling      │  <N>     │  HIGH        │  <N>       │
       │  Auth checks         │  <N>     │  HIGH        │  <N>       │
       │  Business logic      │  <N>     │  MEDIUM      │  <N>       │
       │  Validation paths    │  <N>     │  MEDIUM      │  <N>       │
       │  Logging/telemetry   │  <N>     │  LOW         │  0         │
       │  Dead code           │  <N>     │  SKIP        │  0         │
       └──────────────────────┴──────────┴──────────────┴────────────┘

  REPORT: "Phase {current_iteration}/{max_iterations}: {phase} — {N} scenarios, {M} tests generated"

FINAL SCENARIO TESTING SUMMARY:
┌──────────────────────────────────────────────────────────┐
│  SCENARIO TESTING AUDIT                                   │
├──────────────────────┬────────┬───────────────────────────┤
│  Phase               │ Count  │ Key Finding                │
├──────────────────────┼────────┼───────────────────────────┤
│  Edge case gen       │  <N>   │  <N> per input parameter   │
│  Boundary testing    │  <N>   │  <N> boundaries tested     │
│  Chaos testing       │  <N>   │  <N> failures simulated    │
│  Regression bank     │  <N>   │  <N> missing tests added   │
│  Coverage gaps       │  <N>   │  <N> HIGH gaps found       │
├──────────────────────┼────────┼───────────────────────────┤
│  Total scenarios     │  <N>   │  <M> bugs discovered       │
│  Tests generated     │  <N>   │  All runnable (verified)   │
└──────────────────────┴────────┴───────────────────────────┘
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
This skill does not dispatch parallel agents, so no sequential translation is needed.
All analysis runs in the current session. Test generation uses the detected test framework.
If the test runner is unavailable, skip step 7 (test verification) and note `UNVERIFIED` in the status column.
See `adapters/shared/sequential-dispatch.md` for the general protocol.
