# /godmode:ratelimit

Design and implement rate limiting strategies. Configures algorithms (token bucket, sliding window), distributed rate limiting with Redis, user-tier-based limits, API key quotas, response headers, graceful degradation, and framework middleware (Express, FastAPI, Django, Go).

## Usage

```
/godmode:ratelimit                         # Full rate limiting strategy design
/godmode:ratelimit --assess                # Assess current rate limit coverage
/godmode:ratelimit --algorithm             # Select and implement algorithm
/godmode:ratelimit --tiers                 # Design user tier rate limits
/godmode:ratelimit --redis                 # Distributed rate limiting with Redis
/godmode:ratelimit --quota                 # API key daily/monthly quota tracking
/godmode:ratelimit --headers               # Configure rate limit response headers
/godmode:ratelimit --middleware            # Generate rate limit middleware
/godmode:ratelimit --bypass                # Configure internal service bypass
/godmode:ratelimit --monitor               # Set up monitoring and alerting
/godmode:ratelimit --validate              # Validate rate limit configuration
/godmode:ratelimit --test                  # Load test rate limits
```

## What It Does

1. Assesses API surface and identifies endpoints needing rate limits
2. Selects the right algorithm (token bucket, leaky bucket, fixed window, sliding window log, sliding window counter)
3. Designs user-tier-based limits (anonymous, free, pro, enterprise)
4. Implements distributed rate limiting with Redis Lua scripts (atomic operations)
5. Configures API key quota tracking (daily and monthly)
6. Sets up standard response headers (RateLimit-Limit, RateLimit-Remaining, RateLimit-Reset, Retry-After)
7. Generates framework-specific middleware (Express, FastAPI, Django, Go)
8. Configures graceful degradation (fail-open) and internal service bypass
9. Sets up monitoring (rejection rate, Redis latency, fail-open events)
10. Validates configuration against 14 best-practice checks

## Output
- Rate limit design doc at `docs/ratelimit/<system>-ratelimit-strategy.md`
- Redis Lua scripts at `infra/ratelimit/scripts/`
- Rate limit middleware at `src/middleware/rateLimit.ts`
- Tier configuration at `src/config/rateLimitTiers.ts`
- Monitoring dashboard at `monitoring/dashboards/ratelimit.json`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"ratelimit: <system> -- <algorithm>, <tiers>, <quota tracking>"`

## Next Step
After rate limit design: `/godmode:loadtest` to test under concurrency, `/godmode:secure` for security audit, or `/godmode:observe` to monitor rejection rates.

## Examples

```
/godmode:ratelimit Add rate limiting to our public REST API
/godmode:ratelimit --redis                 # Distributed Redis rate limiter
/godmode:ratelimit --tiers                 # Configure per-tier limits
/godmode:ratelimit --middleware            # Generate Express/FastAPI middleware
/godmode:ratelimit --quota                 # Set up API key quota tracking
/godmode:ratelimit --assess                # Audit existing rate limit coverage
```
