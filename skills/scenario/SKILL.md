---
name: scenario
description: >
  Edge case exploration. 12 dimensions,
  scored by likelihood x impact. Runnable tests for HIGH+.
---

## Activate When
- `/godmode:scenario`, "edge cases", "failure modes"
- "what could go wrong?", "break this", "stress test"
- Before shipping features with user input or APIs
- After build when no edge case coverage exists

## Workflow

### 1. Read the Design
Read spec, plan, and code. Trace the data flow:
```
Input -> Validation -> Transform -> Logic -> Persist
  -> Side Effects -> Response
```
For each stage list:
- **External calls**: API endpoints, DB queries, file I/O
- **State mutations**: created, updated, deleted
- **Side effects**: emails, webhooks, cache invalidation
- **Trust boundaries**: where untrusted data enters

Print: `[scenario:read] Feature: {name} | {N} calls | {N} mutations | {N} side effects | {N} boundaries`

### 2. Identify Feature Scope
```
Entry points: API routes, CLI, UI events, cron, queues
Dependencies: services, DBs, caches, third-party APIs
Data shapes: input schemas, output schemas, models
```

### 3. Explore All 12 Dimensions
For EACH dimension, generate 2-5 specific scenarios.
Every scenario MUST reference a code path (file:line).

| # | Dimension | What to explore |
|--|--|--|
| 1 | Invalid Input | SQL injection, XSS, >64KB strings |
| 2 | Boundary | 0, -1, MAX_INT+1, empty, null |
| 3 | Concurrency | Race conditions, double-submit |
| 4 | Network | Timeout, partial response, DNS |
| 5 | Data Integrity | Orphans, constraint violations |
| 6 | Auth | Expired tokens, privilege escalation |
| 7 | Time | Timezone, DST, leap seconds, TTL |
| 8 | Scale | 10x load, large payloads, N+1 |
| 9 | Failure | Crash mid-write, OOM, disk full |
| 10 | Migration | Schema change, data backfill |
| 11 | User Error | Double-click, back button, paste |
| 12 | Config | Missing env var, wrong region |

IF dimension truly N/A: one-sentence justification.
"N/A" alone is not acceptable.

### 4. Score Every Scenario
- **Likelihood (L)**: 1-5 (impossible to inevitable)
- **Impact (I)**: 1-5 (cosmetic to system down)
- Score = L x I

```
CRITICAL: Score >= 20 (e.g., L=5 x I=4)
HIGH:     Score 12-19
MEDIUM:   Score 6-11
LOW:      Score 1-5
Minimum valid score is 1. Zero is invalid.
```

IF scenario covers <80% of edge cases: add more.
WHEN risk score >7: escalate to team lead.

### 5. Sort and Prioritize
Sort by score descending. Within same score:
1. Data loss / security breach first
2. Most users affected second
3. Easiest reproduction third

```
DIMENSION     | SCENARIO              | L | I | SCORE
Invalid Input | SQL injection search  | 4 | 5 | 20
Concurrency   | Race on balance       | 3 | 5 | 15
```

### 6. Generate Tests for HIGH+ Scenarios
For every scenario scored 12+:
```bash
# Detect test framework
ls package.json pytest.ini Cargo.toml 2>/dev/null
cat package.json 2>/dev/null | grep -E "vitest|jest|mocha"

# Run generated tests
npx vitest run tests/scenarios/ 2>&1
```
- Use project's test framework (auto-detect)
- ARRANGE / ACT / ASSERT structure
- Real code paths, no stubs, no TODOs
- Save to `tests/scenarios/{feature}.scenario.test.{ext}`

### 7. Verify Tests Run
```bash
test_cmd -- tests/scenarios/{feature}.scenario.test.{ext}
```
- IF test fails to compile: fix syntax immediately
- IF test fails because real bug: flag as `BUG_FOUND`
- IF test passes: edge case is mitigated

### 8. Output Summary
```
Scenario Analysis: {feature}
{total} scenarios across 12 dimensions
{critical} CRITICAL | {high} HIGH | {medium} MEDIUM
{tests} tests generated | {bugs} bugs found
```

## TSV Logging
File: `.godmode/scenario-log.tsv`
```
timestamp	feature	dimension	scenario	L	I	score	severity	test_file	code_ref	status
```
Status: `TEST_PASS`, `TEST_FAIL`, `BUG_FOUND`, `NO_TEST`

<!-- tier-3 -->

## Quality Targets
- Target: >90% of critical user paths covered
- Scenario execution: <60s per end-to-end scenario
- Target: 0 flaky scenarios (quarantine >1% failure rate)

## Hard Rules
1. Explore all 12 dimensions. Skip needs justification.
2. Every scenario needs file:line or spec heading.
3. Score every scenario: L(1-5) x I(1-5). No zeros.
4. HIGH+ scenarios must have runnable tests.
5. Tests use project's actual framework, real paths.
6. Guard: test_cmd && lint_cmd.
7. On failure: git reset --hard HEAD~1.
8. Never ask to continue. Loop autonomously.

## Keep/Discard Discipline
```
KEEP if: test is valid AND uses real code paths
  AND follows ARRANGE/ACT/ASSERT
DISCARD if: syntax errors after 2 fixes
  OR references nonexistent code
  On discard: log as NO_TEST. No stub tests.
```

## Stop Conditions
```
STOP when FIRST of:
  - All 12 dimensions explored AND HIGH+ have tests
  - 3 consecutive dimensions produce 0 HIGH+ scenarios
  - >5 test generation failures with no output
```
