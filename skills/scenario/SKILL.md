---
name: scenario
description: |
  Edge case exploration. Stress-test a design across 12 dimensions. Score by likelihood × impact. Generate test skeletons.
---

# Scenario — Edge Case Exploration

## Activate When
- `/godmode:scenario`, "what could go wrong?", "edge cases", "failure modes"
- Invoked by `/godmode:think` for robustness check

## Workflow

### 1. Read the Design
Read spec or proposal. Identify: inputs, outputs, dependencies, state transitions.

### 2. Explore 12 Dimensions

```
1. Invalid Input      — null, empty, huge, malformed, unicode, injection
2. Boundary Values    — zero, one, max, overflow, underflow
3. Concurrency        — race conditions, deadlocks, double-submit
4. Network            — timeout, DNS fail, partial response, retry storms
5. Data Integrity     — corrupt, duplicate, orphaned, schema drift
6. Auth & Security    — expired token, privilege escalation, CSRF
7. Time               — timezone, DST, leap year, stale cache, clock skew
8. Scale              — 10x traffic, 100x data, slow consumers
9. Failure Modes      — OOM, disk full, dependency down, cascading failure
10. Migration         — backward compat, rollback, partial migration
11. User Error        — wrong order, double-click, back button, stale tab
12. External Deps     — API version change, rate limit, deprecation
```

### 3. Score Each Scenario

```
Priority = Likelihood (1-5) × Impact (1-5)
CRITICAL: 20-25 | HIGH: 12-19 | MEDIUM: 6-11 | LOW: 1-5
```

### 4. Generate Test Skeletons

For every HIGH/CRITICAL scenario, generate a test skeleton:
```
describe("{scenario}") {
    it("should handle {condition}") {
        // ARRANGE: set up {condition}
        // ACT: trigger the behavior
        // ASSERT: verify {expected outcome}
        throw new Error("TODO: implement")
    }
}
```

Save to `tests/scenarios/{feature}.scenario.test.{ext}`

### 5. Output

```
Scenarios explored: {N}
Critical: {N} | High: {N} | Medium: {N} | Low: {N}
Test skeletons generated: {N}
```

## Rules

1. **All 12 dimensions.** Don't skip any.
2. **Score every scenario.** Gut feel is not a priority.
3. **Test skeletons for HIGH+.** Real tests, not comments.
4. **Cite specific code.** "The payment handler at pay.ts:34 doesn't check for negative amounts."
