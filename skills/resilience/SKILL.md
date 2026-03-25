---
name: resilience
description: System resilience -- circuit breakers, retries,
  bulkheads, graceful degradation, health checks.
---

## Activate When
- `/godmode:resilience`, "circuit breaker", "retry"
- "rate limiting", "bulkhead", "graceful degradation"
- "health check", "timeout", "what if service is down"
- Ship skill needs resilience validation

## Workflow

### 1. Resilience Assessment
```bash
grep -r "circuitBreaker\|CircuitBreaker\|opossum\|gobreaker" \
  --include="*.ts" --include="*.js" --include="*.go" \
  -l 2>/dev/null
grep -r "retry\|backoff\|Retry" \
  --include="*.ts" --include="*.go" -l 2>/dev/null
```
Evaluate: circuit breakers, retries, timeouts,
bulkheads, rate limits, fallbacks, health checks.

### 2. Circuit Breaker
States: CLOSED -> OPEN (on threshold) -> HALF-OPEN
(after cooldown) -> test one request -> CLOSED/OPEN.
```
Config per dependency:
  Failure threshold: 5 failures in 30s
  Half-open timeout: 30s
  Success threshold: 3 (to close from half-open)
  Monitored exceptions: 5xx, timeout, connection error
  Fallback: cached data | default | error
```
IF no circuit breaker on external call: add one.
IF circuit opens too often: tune threshold up.

### 3. Retry Strategy
```
Formula: min(base_ms * 2^attempt + jitter, max_ms)
Retryable: network timeout, 5xx, DB connection, 429
Non-retryable: 4xx validation, auth, deserialization
Max attempts: 3 (default), 5 (critical operations)
```
NEVER retry non-idempotent operations without
idempotency key. ALWAYS add jitter to prevent
thundering herd.

### 4. Bulkhead Pattern
Isolate failure domains. Separate connection pools
or semaphores per dependency. One slow dependency
must not exhaust all resources.
```
Config: max concurrent per dependency
  Payment API: 20 concurrent, queue 10
  Email service: 10 concurrent, queue 5
  Search: 30 concurrent, queue 20
```

### 5. Rate Limiting
Token bucket for burst tolerance. Sliding window
counter for steady limits. See `/godmode:ratelimit`
for full implementation.

### 6. Graceful Degradation
Define fallback per dependency:
```
Recommendation engine down -> show popular items
Search down -> show cached results + apology
Payment down -> queue order, process later
Analytics down -> skip tracking silently
```
Levels: NORMAL -> DEGRADED -> MINIMAL -> MAINTENANCE.

### 7. Health Checks
- **Liveness**: is process alive? (restart if fail)
  Internal only -- no external deps.
- **Readiness**: can accept traffic? (remove from LB)
  Check DB, cache, critical deps.
- **Startup**: initialization complete? (delay probes)
```yaml
livenessProbe:
  httpGet: { path: /health/live, port: 8080 }
  periodSeconds: 10
  failureThreshold: 3
readinessProbe:
  httpGet: { path: /health/ready, port: 8080 }
  periodSeconds: 5
  failureThreshold: 2
```

### 8. Timeout Management
```
Client request: 30s total
  -> API gateway: 25s
    -> Service call: 5s (connect 1s + read 4s)
    -> DB query: 3s
    -> External API: 10s
```
Each layer timeout < parent timeout.
Use timeout budget: pass remaining time downstream.

### 9. Verification
```
[ ] Circuit breaker on all external deps
[ ] Retry with exponential backoff + jitter
[ ] Bulkhead isolation between deps
[ ] Fallback for every circuit breaker
[ ] Health checks (liveness + readiness)
[ ] Timeouts on all calls (connect + read)
[ ] Rate limiting at API boundary
```

## Hard Rules
1. NEVER retry non-idempotent without idempotency key.
2. EVERY retry: exponential backoff WITH jitter.
3. EVERY external call: timeout (connect + read).
4. NEVER cascade failures (bulkhead isolation).
5. Health liveness: NEVER depend on external services.
6. ALWAYS define fallback for circuit breakers.
7. Timeout per layer < parent layer timeout.

## TSV Logging
Append `.godmode/resilience-results.tsv`:
```
timestamp	pattern	target	dependency	config	test_result	status
```

## Keep/Discard
```
KEEP if: dependency failure triggers graceful
  degradation AND circuit opens AND fallback works.
DISCARD if: failure cascades OR no fallback
  OR timeout not configured.
```

## Stop Conditions
```
STOP when ALL of:
  - All critical deps have circuit breakers
  - All retries use backoff + jitter
  - All calls have timeouts
  - All circuit breakers have fallbacks
  - Verification checklist passes
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Circuit never opens | Check threshold, include timeouts |
| Retry storm | Add backoff+jitter, circuit breaker first |
| Stale fallback data | Set max staleness, alert on primary |
| Bulkhead rejects too many | Tune pool size, check downstream |
