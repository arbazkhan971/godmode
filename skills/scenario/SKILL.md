---
name: scenario
description: Edge case exploration. 12 dimensions, scored by likelihood x impact.
---

# Scenario — Edge Case Exploration

## Activate When
- `/godmode:scenario`, "what could go wrong?", "edge cases", "failure modes"

## Workflow
### 1. Read the Design
Read spec or proposal. Identify: inputs, outputs, dependencies, state transitions.
### 2. Explore 12 Dimensions
Invalid Input, Boundary Values, Concurrency, Network, Data Integrity, Auth & Security, Time, Scale, Failure Modes, Migration, User Error, External Deps.
### 3. Score Each Scenario
Priority = Likelihood (1-5) x Impact (1-5). CRITICAL: 20-25 | HIGH: 12-19 | MEDIUM: 6-11 | LOW: 1-5.
### 4. Generate Test Skeletons
For every HIGH/CRITICAL scenario, generate a test skeleton with ARRANGE/ACT/ASSERT structure and a TODO placeholder. Save to `tests/scenarios/{feature}.scenario.test.{ext}`.
### 5. Output
Report: scenarios explored, count per priority tier, test skeletons generated.

## Rules
1. All 12 dimensions. Don't skip any.
2. Score every scenario. Gut feel is not a priority.
3. Test skeletons for HIGH+. Real tests, not comments.
4. Cite specific code paths for each scenario.
