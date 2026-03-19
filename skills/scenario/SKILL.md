---
name: scenario
description: |
  Edge case exploration. Stress-test a design across 12 dimensions. Score by likelihood x impact. Generate test skeletons.
---

# Scenario — Edge Case Exploration

## Activate When
- `/godmode:scenario`, "what could go wrong?", "edge cases", "failure modes"
- Invoked by `/godmode:think` for robustness check

## Workflow

### 1. Read the Design
Read spec or proposal. Identify: inputs, outputs, dependencies, state transitions.

### 2. Explore 12 Dimensions
1. Invalid Input
2. Boundary Values
3. Concurrency
4. Network
5. Data Integrity
6. Auth & Security
7. Time
8. Scale
9. Failure Modes
10. Migration
11. User Error
12. External Deps

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
