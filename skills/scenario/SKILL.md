---
name: scenario
description: Edge case exploration. 12 dimensions, scored by likelihood x impact.
---

## Activate When
- `/godmode:scenario`, "what could go wrong?", "edge cases", "failure modes"

## Workflow
### 1. Read the Design
Read spec. Map: user inputs → processing → outputs. List external deps and state mutations.
### 2. Explore 12 Dimensions
Invalid Input, Boundary Values, Concurrency, Network, Data Integrity, Auth & Security, Time, Scale, Failure Modes, Migration, User Error, External Deps.
### 3. Score Each Scenario
Priority = Likelihood (1-5) x Impact (1-5). CRITICAL: 20-25 | HIGH: 12-19 | MEDIUM: 6-11 | LOW: 1-5.
### 4. Generate Test Skeletons
For HIGH/CRITICAL: generate test with ARRANGE (setup) / ACT (trigger) / ASSERT (verify). Save to `tests/scenarios/{feature}.scenario.test.{ext}`.
### 5. Output
Report: scenarios explored, count per priority tier, test skeletons generated.

## Rules
1. All 12 dimensions. Don't skip any.
2. Score every scenario. Gut feel is not a priority.
3. HIGH+ scenarios get runnable tests. Stubs and TODOs are not tests.
4. Cite specific code paths for each scenario.
