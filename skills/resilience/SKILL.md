---
name: resilience
description: |
  System resilience skill. Activates when user needs to design fault-tolerant systems using circuit breakers, retry strategies, bulkheads, rate limiting, graceful degradation, and health checks. Covers timeout management, fallback patterns, load shedding, and production hardening. Triggers on: /godmode:resilience, "circuit breaker", "retry strategy", "rate limiting", "graceful degradation", "health check", "timeout", "bulkhead", or when ship skill needs resilience validation.
---

# Resilience — System Resilience Engineering

## When to Activate
- User invokes `/godmode:resilience`
- User says "circuit breaker", "retry strategy", "exponential backoff"
- User says "rate limiting", "bulkhead", "graceful degradation"
- User asks "how do I handle failures?" or "what happens when this service is down?"
- User needs health checks (liveness, readiness, startup probes)
- User wants timeout management or fallback strategies
- Ship skill needs resilience validation before production deployment
- Post-incident review reveals missing resilience patterns

## Workflow

### Step 1: Resilience Assessment
Evaluate the current resilience posture of the system:

```
RESILIENCE ASSESSMENT:
| Pattern | Status | Coverage | Implementation |
```

### Step 2: Circuit Breaker Pattern
Implement circuit breakers for all external dependencies:

#### Circuit Breaker State Machine
```
CIRCUIT BREAKER STATE MACHINE:

     ┌─────────┐   failure threshold   ┌──────┐
```

#### Circuit Breaker Configuration
```
CIRCUIT BREAKER CONFIG:
Dependency: <service name>
Failure threshold: <N failures> in <window> (e.g., 5 in 30s)
```

#### Implementation — Node.js (opossum)
```javascript
const CircuitBreaker = require('opossum');

// Define the function to protect
```

#### Implementation — Go (sony/gobreaker)
```go
package resilience

import (
```

#### Implementation — Python (pybreaker)
```python
import pybreaker
import requests
import logging
```

### Step 3: Retry Strategies
Design retry policies with exponential backoff and jitter:

#### Retry Strategy Decision Matrix
```
RETRY DECISION MATRIX:
| Error Type | Retry? | Strategy | Max Attempts |
```

#### Exponential Backoff with Jitter
```
BACKOFF FORMULA:

Base delay:    base_ms (e.g., 100ms)
```

#### Implementation — Node.js
```javascript
class RetryPolicy {
  constructor(options = {}) {
    this.maxAttempts = options.maxAttempts || 3;
```

#### Implementation — Go
```go
package resilience

import (
```

### Step 4: Bulkhead Pattern
Isolate failure domains so one failing dependency does not consume all resources:

#### Bulkhead Design
```
BULKHEAD PATTERN:

Purpose: Prevent a single slow/failing dependency from exhausting the
```

#### Implementation — Node.js (Semaphore Bulkhead)
```javascript
class Bulkhead {
  constructor(name, maxConcurrent, maxQueue = 0) {
    this.name = name;
```

### Step 5: Rate Limiting
Protect services from being overwhelmed by too many requests:

#### Rate Limiting Strategies
```
RATE LIMITING STRATEGIES:
| Algorithm | Behavior | Best For |
```

#### Token Bucket Implementation — Node.js
```javascript
class TokenBucket {
  constructor(options) {
    this.capacity = options.capacity;        // max tokens (burst size)
```

### Step 6: Graceful Degradation
Design fallback behavior when dependencies are unavailable:

#### Degradation Strategy Matrix
```
GRACEFUL DEGRADATION MATRIX:
| Dependency | Degradation Strategy | User Experience |
```

#### Implementation — Feature Degradation
```javascript
class DegradationManager {
  constructor() {
    this.levels = {
```

### Step 7: Health Check Implementation
Design comprehensive health checks for container orchestration:

#### Health Check Types
```
HEALTH CHECK TYPES:
| Type | Purpose | Failure Action |
```

#### Implementation — Express.js
```javascript
const express = require('express');

class HealthChecker {
```

#### Kubernetes Probe Configuration
```yaml
# Kubernetes health probe configuration
apiVersion: apps/v1
kind: Deployment
```

### Step 8: Timeout Management
Design a comprehensive timeout strategy:

#### Timeout Hierarchy
```
TIMEOUT HIERARCHY:
| Layer | Timeout | Rationale |
```

#### Implementation — Timeout Budget
```javascript
class TimeoutBudget {
  constructor(totalMs) {
    this.totalMs = totalMs;
```

### Step 9: Resilience Testing Checklist

```
RESILIENCE VERIFICATION CHECKLIST:
| Category | Test | Pass? |
```

## Autonomous Operation
- Loop until all critical dependencies have circuit breakers, timeouts, and fallbacks or budget exhausted. Never pause.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Output
- Resilience design at `docs/resilience/<service>-resilience.md`
- Implementation files in service source directory
- Commit: `"resilience: <service> -- <patterns applied> (<coverage>)"`

## Chaining
- **From `/godmode:chaos`:** Chaos tests reveal missing resilience patterns → fix with `/godmode:resilience`
- **From `/godmode:resilience` to `/godmode:observe`:** After adding resilience patterns, add monitoring for circuit breaker states, retry counts, and degradation events
- **From `/godmode:resilience` to `/godmode:loadtest`:** Validate resilience under load
- **From `/godmode:incident`:** Post-mortem reveals resilience gaps → implement with `/godmode:resilience`

## Iterative Resilience Implementation Loop

```
current_iteration = 0
max_iterations = 12
dependencies = [list of external dependencies/services to protect]
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER retry non-idempotent operations. POST that creates a resource = no retry without idempotency key.
2. EVERY retry must use exponential backoff WITH jitter. Linear retry = thundering herd.
```

## Anti-Patterns

```
RESILIENCE ANTI-PATTERNS:
| Anti-Pattern | Why It's Dangerous |
```

## Output Format
Print on completion: `Resilience: {pattern_count} patterns implemented. Circuit breakers: {cb_count}. Retry policies: {retry_count}. Timeouts: {timeout_count}. Fallbacks: {fallback_count}. Bulkheads: {bulkhead_count}. Verdict: {verdict}.`

## TSV Logging
Log every resilience pattern implementation to `.godmode/resilience-results.tsv`:
```
iteration	pattern	target_service	dependency	config	test_result	status
1	circuit_breaker	api-gateway	payment-api	threshold:5,timeout:30s	verified	implemented
2	retry	order-service	inventory-api	max:3,backoff:exponential	verified	implemented
```
Columns: iteration, pattern, target_service, dependency, config, test_result, status(implemented/verified/failed).

## Success Criteria
- All external dependencies have timeouts configured (connect + read).
- All retriable operations have retry policies with exponential backoff and jitter.
- Circuit breakers configured for all external service calls.
- Bulkhead isolation between independent dependencies (separate connection pools/thread pools).
- Fallback behavior defined for every circuit breaker (cached data, degraded response, or graceful error).
- All resilience patterns tested under failure conditions (dependency down, slow, error).
- Health checks do not depend on external dependencies (liveness checks internal only).
- Rate limiting configured at API boundaries.

## Keep/Discard Discipline
```
After EACH resilience pattern implementation:
  1. MEASURE: Simulate dependency failure — does the application degrade gracefully?
  2. COMPARE: Is the system more resilient than before? (circuit opens, retries work, fallback activates)
```

## Stuck Recovery
```
IF >3 consecutive iterations fail to get a resilience pattern working:
  1. Check the library documentation — circuit breaker configuration varies significantly between libraries.
  2. Simplify: implement a basic timeout-only protection first, then add circuit breaker on top.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All critical dependencies have circuit breakers, timeouts, and fallbacks
  - Resilience verification checklist passes for all categories
```

## Simplicity Criterion
```
PREFER the simpler resilience approach:
  - Timeouts before circuit breakers (timeouts are always needed; circuit breakers add complexity)
  - Static fallback values before cached fallback (if a default is acceptable)
```


## Error Recovery
| Failure | Action |
|--|--|
| Circuit breaker never opens | Check failure threshold configuration. Verify error counting includes timeouts. Test with forced failures. |
| Retry storm amplifies outage | Add exponential backoff with jitter. Set max retries. Add circuit breaker before retry logic. Monitor retry rate. |
| Fallback returns stale data too long | Set max staleness on cached fallback. Add monitoring for fallback activation. Alert when primary stays down >threshold. |
| Bulkhead rejects too many requests | Tune semaphore/thread pool size. Check for slow downstream services consuming all slots. Add timeout to bulkhead operations. |
