---
name: ratelimit
description: Rate limiting algorithms, quota management,
  throttling, API protection.
---

## Activate When
- `/godmode:ratelimit`, "rate limit", "throttle"
- "API quota", "token bucket", "sliding window"
- "DDoS protection", "abuse prevention", "429"

## Workflow

### 1. Assessment
```bash
grep -r "rate.limit\|ratelimit\|throttle" \
  package.json requirements.txt go.mod 2>/dev/null
grep -r "rateLim\|throttle\|RateLimit" \
  --include="*.ts" --include="*.py" -l 2>/dev/null
```
```
Current: None | Basic (nginx) | App-level | Multi-layer
API Surface: public <N>, authenticated <N>, internal <N>
Risk: unauthenticated abuse, cost-sensitive endpoints
```

### 2. Algorithm Selection
- **Token Bucket**: burst tolerance, most common.
  Start here. Bucket holds N tokens, refilled at rate.
- **Leaky Bucket**: smooth output rate, traffic shaping.
- **Fixed Window Counter**: simple but 2x burst at edges.
- **Sliding Window Log**: exact, O(n) memory. Billing.
- **Sliding Window Counter (RECOMMENDED)**: weighted
  average of current+previous window. O(1) memory.
  Used by Cloudflare, Stripe.

IF unsure: use sliding window counter.
IF burst tolerance needed: use token bucket.

### 3. Tier Design
```
Anonymous:   20/min, burst 5, 1K/day
Free:        60/min, burst 15, 10K/day
Basic/$29:   300/min, burst 50, 100K/day
Pro/$99:     1K/min, burst 200, 1M/day
Enterprise:  5K/min, burst 1K, unlimited
Internal:    no limit (bypass)
```
Endpoint overrides (stricter):
- POST /auth/login: 5/min (brute force)
- POST /auth/register: 3/min
- POST /upload: 10/hour (storage cost)
- POST /ai/generate: 20/min (compute cost)
- GET /export: 5/hour (exfiltration)

Resolution: endpoint > user tier > global IP.

### 4. Response Headers
Standard: `RateLimit-Limit`, `RateLimit-Remaining`,
`RateLimit-Reset`. On 429: add `Retry-After`.
Set headers on EVERY response (success and 429).

### 5. Distributed Rate Limiting (Redis)
Lua script for atomic sliding window counter.
Without shared state, N instances * limit = N*limit.
Load script via `SCRIPT LOAD`, call via `EVALSHA`.

### 6. Middleware
Resolve client key (API key or IP), resolve tier,
call Redis Lua, set headers, return 429 when denied.
Skip health checks and internal paths.

### 7. Graceful Degradation
RULE: Rate limiter failure NEVER causes app failure.
Fail OPEN when Redis is down. Log warning. Optional
local in-memory fallback (less accurate).

### 8. Quota Management
Rate limit = short window (100/min).
Quota = long window (10K/day, 1M/month).
`INCR quota:{key}:{date}` with 2-day TTL.
Warn at 75%, 90%, 100%. Optional overage billing.

### 9. Monitoring
Metrics: requests_total, rejected_total (>100/min),
rejected_ratio (>10%), latency P95 (>5ms),
redis_errors, failopen_total (>0), quota_usage (>90%).

### 10. Validation
All public endpoints protected, auth endpoints strict
(<=5/min), headers on all responses, 429 has
Retry-After, atomic ops, fail-open, tier limits set.

## Hard Rules
1. NEVER non-atomic check-and-increment (race bypass).
2. NEVER fail closed when Redis unavailable.
3. ALWAYS return rate limit headers on every response.
4. NEVER same limits for authed and unauthed traffic.
5. ALWAYS sliding window or token bucket for users.
6. NEVER app-memory state for multi-instance deploys.
7. ALWAYS exempt internal service traffic.
8. NEVER log rate-limited request bodies.

## TSV Logging
Append `.godmode/ratelimit.tsv`:
```
timestamp	algorithm	storage	tiers	endpoint_overrides	quota	status
```

## Keep/Discard
```
KEEP if: limit enforced atomically AND headers present
  AND fail-open on Redis down.
DISCARD if: race condition allows bypass
  OR 429 missing Retry-After OR fail-closed.
```

## Stop Conditions
```
STOP when FIRST of:
  - All public endpoints protected
  - Tiers configured
  - Fail-open verified
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Redis unavailable | Fail open, in-memory fallback |
| Clients bypassing | Check atomic ops, add IP limit |
| 429 no Retry-After | Add to response handler |
| Limits too strict | Analyze traffic, increase burst |
| Lua script errors | Check Redis version, reload |
