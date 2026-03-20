---
name: scenario
description: Edge case exploration. 12 dimensions, scored by likelihood x impact.
---

## Activate When
- `/godmode:scenario`, "what could go wrong?", "edge cases", "failure modes"

## Workflow
### 1. Read the Design
Read spec. Trace data flow: inputs → validation → processing → storage → output. List external deps and state mutations.
### 2. Explore 12 Dimensions
Invalid Input, Boundary (0, 1, MAX_INT, empty, null), Concurrency (race, deadlock), Network (timeout, 5xx, DNS), Data (corrupt, stale, missing), Auth, Time (TZ, DST, leap), Scale (10x), Failure (crash, OOM, disk full), Migration, User Error, Deps (down, slow, changed API).
### 3. Score Each Scenario
Score = Likelihood (1-5) × Impact (1-5). ≥20 CRITICAL | 12-19 HIGH | 6-11 MEDIUM | ≤5 LOW.
### 4. Generate Test Skeletons
For HIGH/CRITICAL: generate runnable test (ARRANGE/ACT/ASSERT). Use real values, not 'example'. Save to `tests/scenarios/{feature}.scenario.test.{ext}`.
### 5. Output
Output: `DIMENSION | SCENARIO | L×I | SCORE | TEST`. Print: `{total} scenarios, {critical} critical, {high} high, {tests} tests generated`.

## Rules
1. All 12 dimensions. Don't skip any. 'N/A' requires justification — most dimensions apply to most features.
2. Score every scenario numerically. No unscored scenarios in output.
3. HIGH+ scenarios get runnable tests. Stubs and TODOs are not tests.
4. Cite specific code paths (file:line). If code doesn't exist yet, cite the spec section instead.
