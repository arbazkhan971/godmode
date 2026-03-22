---
name: ratelimit
description: Rate limiting algorithms, quota management, throttling, API protection. Use when user mentions rate limit, throttle, quota, API protection, token bucket, sliding window, DDoS protection.
---

# Rate Limit -- Rate Limiting & Throttling

## When to Activate
- User invokes `/godmode:ratelimit`
- User says "rate limit", "throttle", "API quota", "token bucket", "sliding window"
- User says "DDoS protection", "abuse prevention", "429", "retry-after"
- When `/godmode:api` identifies endpoints without rate limits
- When `/godmode:secure` recommends abuse prevention controls

## Workflow

### Step 1: Rate Limiting Assessment
Identify what needs rate limiting and current exposure:

```
RATE LIMIT ASSESSMENT:
Project: <name>
Current: None | Basic (nginx) | App-level | Multi-layer
API Surface: public endpoints <N>, authenticated <N>, internal <N>

TRAFFIC ANALYSIS: For each endpoint group, note avg QPS, peak QPS, auth method.
RISK ASSESSMENT: Unauthenticated abuse risk, API key abuse risk, cost-sensitive endpoints, data exfiltration risk.
```

If unspecified, ask: "Which endpoints are public-facing? Any expensive operations (uploads, AI inference, payments) needing stricter limits?"

### Step 2: Algorithm Selection

**Token Bucket** — Bucket holds N tokens (burst capacity), refilled at fixed rate. Each request consumes 1 token. Allows bursts up to bucket size. USE WHEN: burst tolerance needed, mobile/batch clients. Most common — start here.

**Leaky Bucket** — Requests enter a fixed-size queue, processed at constant rate. Smooths out bursts. USE WHEN: need perfectly smooth output rate, traffic shaping, protecting downstream services.

**Fixed Window Counter** — Time divided into fixed windows, counter per window, deny if over limit. Simple but has boundary problem (2x burst at window edges). USE WHEN: simplicity matters more than precision.

**Sliding Window Log** — Store timestamp of every request in sorted set, count within window. Exact accuracy but O(n) memory per client. USE WHEN: precision critical (billing, security). DO NOT USE for high-volume clients.

**Sliding Window Counter (RECOMMENDED DEFAULT)** — Weighted average of current and previous window counters. Near-perfect accuracy with O(1) memory. Used by Cloudflare, Stripe, most major APIs. USE WHEN: good balance of accuracy and efficiency at any traffic volume.

**Algorithm comparison**: Token Bucket (Good accuracy, O(1), allows burst), Leaky Bucket (Exact, O(1), no burst), Fixed Window (Low accuracy, O(1), edge burst), Sliding Window Log (Exact, O(n), no burst), Sliding Window Counter (High accuracy, O(1), no burst — RECOMMENDED).

### Step 3: Rate Limit Tier Design

```
TIERS: Anonymous (20/min, burst 5, 1K/day), Free (60/min, burst 15, 10K/day),
       Basic/$29 (300/min, burst 50, 100K/day), Pro/$99 (1K/min, burst 200, 1M/day),
       Enterprise/Custom (5K/min, burst 1K, unlimited), Internal (no limit)

ENDPOINT OVERRIDES (stricter than tier):
  POST /auth/login: 5/min (brute force), POST /auth/register: 3/min,
  POST /auth/forgot-pw: 3/hour, POST /upload: 10/hour (storage cost),
  POST /ai/generate: 20/min (compute cost), GET /export: 5/hour (exfiltration),
  POST /payment: 10/min (fraud), GET /search: 30/min (DB load)

RESOLUTION ORDER: endpoint-specific (strictest) → user tier → global/IP → most restrictive wins
```

### Step 4: Response Headers & Client Communication

Standard headers (IETF draft): `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset`. Legacy: `X-RateLimit-*`. On 429: add `Retry-After` header.

429 response body: `{ "error": { "code": "RATE_LIMIT_EXCEEDED", "message": "...", "retry_after": N, "limit": N, "docs_url": "..." } }`

Set headers on EVERY response (success and 429).

### Step 5: Distributed Rate Limiting with Redis

Use Redis Lua scripts for atomic sliding window counter. Without shared state, N instances with 100/min limit = N*100/min (WRONG).

Lua script pattern: compute `current_window = floor(now/window)`, get prev and curr counts, weight = `(window - time_in_window) / window`, estimate = `prev_count * weight + curr_count`. If >= limit, deny. Otherwise INCR current window key with 2x TTL. Returns `{allowed, limit, remaining, reset_at}`.

Load script once via `SCRIPT LOAD`, call via `EVALSHA`. Works identically in Node.js (ioredis), Python (redis-py), Go (go-redis).

### Step 6: Middleware Implementations

For Express.js, FastAPI, Django, Go: implement middleware that resolves client key (API key or IP), resolves tier-based limit, calls Redis Lua script, sets headers on every response, returns 429 with Retry-After when denied. Skip health checks and internal paths.

Key patterns: `keyGenerator(req)` for client identification, `tierResolver(req)` for dynamic limits, `skipIf(req)` for bypass conditions.

### Step 7: Graceful Degradation & Bypass

**RULE: Rate limiter failure must NEVER cause application failure. Fail OPEN when Redis is down.**

Fail-open pattern: try Redis, catch error → allow request, log warning, increment `ratelimit.failopen` metric. Optional local fallback: in-memory per-instance limiter (less accurate but prevents total bypass).

Internal service bypass methods: internal token header (low complexity), IP allowlist, mTLS certificate (high security), service mesh.

### Step 8: API Key Quota Management

Rate limit = short window (100/min). Quota = long window (10K/day, 1M/month). Enforce both.

Daily quota: `INCR quota:{key}:{date}` with 2-day TTL. Monthly: `INCR quota:monthly:{key}:{month}` with 35-day TTL.

Quota headers: `X-Quota-Limit`, `X-Quota-Remaining`, `X-Quota-Reset`. Send warning notifications at 75%, 90%, 100%. Optional overage billing.

### Step 9: Monitoring & Observability

Key metrics: `ratelimit_requests_total`, `ratelimit_rejected_total` (alert >100/min), `ratelimit_rejected_ratio` (alert >10%), `ratelimit_latency_seconds` (P95 alert >5ms), `ratelimit_redis_errors_total`, `ratelimit_failopen_total` (alert >0), `quota_usage_percent` (alert >90%).

### Step 10: Validation Checklist
All public endpoints have rate limits, auth endpoints have strict limits, headers on all responses, 429 includes Retry-After, atomic ops (Lua script), fail-open on Redis failure, internal bypass configured, tier limits set, quotas tracked, metrics exported.

### Step 11: Commit
```
Commit: "ratelimit: <system> -- <algorithm>, <tiers configured>, <quota tracking>"
Artifacts: Lua scripts, middleware, tier config, monitoring dashboard
```

## Key Behaviors

1. **Rate limit every public endpoint.** Unprotected endpoint = open door for abuse.
2. **Use sliding window counter as default.** Excellent accuracy with O(1) memory.
3. **Atomic operations only.** Use Redis Lua scripts. Non-atomic = race condition = bypass.
4. **Always return rate limit headers.** Clients need them to self-throttle.
5. **Fail open, not closed.** Broken rate limiter must not become an outage.
6. **Separate rate limits from quotas.** Rate limits prevent bursts; quotas prevent sustained overuse.
7. **Tiered limits by user class.** Anonymous through enterprise should differ. Internal bypasses entirely.
8. **Monitor rejection rates.** High = too strict or attack. Zero = too loose.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full rate limiting strategy design |
| `--algorithm` | Select and implement algorithm |
| `--tiers` | Design user tier configuration |
| `--redis` | Distributed rate limiting with Redis |
| `--quota` | API key daily/monthly quota tracking |
| `--middleware` | Generate middleware for your framework |
| `--monitor` | Rate limit monitoring and alerting |

## HARD RULES

1. NEVER use non-atomic check-and-increment. Separate GET then INCR has race conditions — 10x bypass under concurrency.
2. NEVER fail closed when Redis is unavailable. Rate limiter outage must not become app outage.
3. ALWAYS return standard rate limit headers on every response.
4. NEVER apply same limits to authenticated and unauthenticated traffic.
5. ALWAYS use sliding window or token bucket for user-facing limits. Fixed window allows 2x burst at boundaries.
6. NEVER store rate limit state in application memory for multi-instance deployments.
7. ALWAYS exempt internal service-to-service traffic from public rate limits.
8. NEVER log rate-limited request bodies — abuse magnets that fill disks.

## Auto-Detection

```bash
grep -r "rate.limit\|ratelimit\|throttle\|express-rate-limit" package.json requirements.txt Gemfile go.mod 2>/dev/null
grep -r "redis\|ioredis\|memcached\|upstash" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
grep -r "rateLim\|throttle\|RateLimit" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
```

## TSV Logging
```
Fields: timestamp	project	algorithm	storage	tiers_count	endpoint_overrides	quota_tracking	degradation	commit_sha
```

## Success Criteria
1. All public endpoints have rate limits with correct response headers.
2. Auth endpoints have strict limits (<=5/min).
3. 429 response includes Retry-After and structured error body.
4. Atomic operations (Lua script or equivalent).
5. Fail-open on Redis/store failure.
6. Tiered limits by user class.
7. API key quotas tracked (daily/monthly).
8. Internal services can bypass limits.
9. Rate limit metrics exported.

## Error Recovery
- **Redis unavailable**: Fail open immediately. Log. Fall back to in-memory per-instance limiter. Alert ops.
- **Clients bypassing limits**: Check for non-atomic ops (race condition). Check API key rotation abuse (add IP secondary limit). Verify X-Forwarded-For trusted only from known proxies.
- **429 missing Retry-After**: Add to response handler. Calculate from reset_at timestamp.
- **Limits too strict**: Check tier config. Analyze traffic patterns. Increase burst allowance.
- **Limits too loose**: Add endpoint-specific overrides. Tighten anonymous tier. Add IP-based secondary check.
- **Lua script errors**: Check Redis version compatibility. Re-load script on NOSCRIPT error.

## Iteration Protocol
```
FOR each public endpoint:
  1. Classify: auth | read | write | expensive | internal
  2. Set rate limit based on classification and tier
  3. Add middleware/decorator
  4. Verify headers in response, test 429 with Retry-After
THEN: configure Redis Lua script, fail-open degradation, monitoring
```

## Keep/Discard Discipline
```
KEEP if: limit enforced atomically, headers present, fail-open on Redis down
DISCARD if: race condition allows bypass OR 429 missing Retry-After OR fail-closed
```

## Stop Conditions
```
STOP when: all public endpoints protected, tiers configured, fail-open verified, or user stops
DO NOT STOP just because: dashboards not built or monthly quotas not yet enforced
```

## Anti-Patterns
- Do NOT hardcode limits — must be configurable per tier/endpoint without deploy.
- Do NOT trust X-Forwarded-For blindly — only from known proxy IPs.
- Do NOT apply same limit to all endpoints — login=5/min, products=1000/min.
- Do NOT forget quotas — 99 req/min for 24h = 142K requests.

## Multi-Agent Dispatch
```
Agent 1 (ratelimit-core): Redis Lua script, middleware, fail-open degradation
Agent 2 (ratelimit-tiers): Tier config, endpoint overrides, quota tracking, notifications
Agent 3 (ratelimit-monitoring): Prometheus metrics, dashboard, alerts, integration tests
MERGE: core → tiers → monitoring
```

## Platform Fallback
Run sequentially: core middleware → tier config → monitoring. Branch per task.

## Output Format
Print: `RateLimit: {endpoints} endpoints protected. Algorithm: {token_bucket|sliding_window|fixed_window}. Store: {redis|memory}. Status: {DONE|PARTIAL}.`
