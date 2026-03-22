---
name: ratelimit
description: Rate limiting algorithms, quota management, throttling, API protection. Use when user mentions rate limit, throttle, quota, API protection, token bucket, sliding window, DDoS protection.
---

# Rate Limit -- Rate Limiting & Throttling

## When to Activate
- User invokes `/godmode:ratelimit`
- User says "rate limit", "rate limiting", "throttle", "throttling"
- User says "API quota", "request quota", "usage limits"
- User says "token bucket", "leaky bucket", "sliding window"
- User says "DDoS protection", "abuse prevention", "API protection"
- User says "too many requests", "429", "retry-after"
- When `/godmode:api` identifies endpoints without rate limits
- When `/godmode:secure` recommends abuse prevention controls
- When `/godmode:scale` detects traffic spikes overwhelming services

## Workflow

### Step 1: Rate Limiting Assessment
Identify what needs rate limiting and the current exposure:

```
RATE LIMIT ASSESSMENT:
Project: <name and purpose>
Current Rate Limiting: None | Basic (nginx) | App-level | Multi-layer
API Surface:
  Public endpoints: <count>
  Authenticated endpoints: <count>
  Internal/service endpoints: <count>

TRAFFIC ANALYSIS:
+--------------------------------------------------------------+
|  Endpoint / Group       | QPS (avg) | QPS (peak) | Auth     |
+--------------------------------------------------------------+
|  POST /api/auth/login   | 50        | 500        | Public   |
|  GET /api/products      | 2,000     | 8,000      | API Key  |
|  POST /api/orders       | 200       | 1,000      | User JWT |
|  GET /api/search        | 1,500     | 6,000      | API Key  |
|  POST /api/upload       | 30        | 100        | User JWT |
|  Internal service calls | 10,000    | 40,000     | mTLS     |
+--------------------------------------------------------------+

RISK ASSESSMENT:
  Unauthenticated abuse risk: HIGH | MEDIUM | LOW
  API key abuse risk: HIGH | MEDIUM | LOW
  Cost-sensitive endpoints: <list endpoints with expensive compute or third-party costs>
  Data exfiltration risk: <list endpoints that expose bulk data>
```

If the user has not specified what to rate limit, ask: "Which endpoints are public-facing? Are there any expensive operations (file uploads, AI inference, payment processing) that need stricter limits?"

### Step 2: Algorithm Selection
Choose the right rate limiting algorithm for each use case:

#### Token Bucket Algorithm
```
TOKEN BUCKET:

How it works:
  - Bucket holds up to N tokens (burst capacity)
  - Tokens are added at a fixed rate (refill rate)
  - Each request consumes 1 token
  - Request denied if bucket is empty
  - Allows bursts up to bucket size

Parameters:
  bucket_size: 100       # Max burst capacity
  refill_rate: 10/sec    # Steady-state rate

Behavior:
  Time 0:   Bucket = 100 tokens (full)
  Burst:    100 requests instantly = OK (bucket = 0)
  Time 1s:  Bucket = 10 tokens (refilled)
  Time 10s: Bucket = 100 tokens (full again)

  +-----------------------------------------------------+
  |  Tokens                                              |
  |  100|****                    ****                     |
  |     |    \                  /    \                    |
  |   50|     \      **       /      \       **          |
  |     |      \    /  \     /        \     /  \         |
  |    0|-------\--/----\---/----------\---/----\-----   |
  |     0    2    4    6    8    10   12   14   16  sec   |
  |         burst     burst          burst               |
  +-----------------------------------------------------+

PSEUDOCODE:
class TokenBucket:
  def __init__(self, capacity, refill_rate):
    self.capacity = capacity
    self.tokens = capacity
    self.refill_rate = refill_rate        # tokens per second
    self.last_refill = now()

  def allow(self):
    self._refill()
    if self.tokens >= 1:
      self.tokens -= 1
      return True
    return False

  def _refill(self):
    elapsed = now() - self.last_refill
    new_tokens = elapsed * self.refill_rate
    self.tokens = min(self.capacity, self.tokens + new_tokens)
    self.last_refill = now()

USE WHEN:
- You want to allow short bursts above the average rate
- API clients need burst tolerance (mobile apps, batch jobs)
- Most common algorithm -- start here

REDIS IMPLEMENTATION (Lua script for atomicity):
-- KEYS[1] = rate limit key
-- ARGV[1] = bucket capacity
-- ARGV[2] = refill rate (tokens/sec)
-- ARGV[3] = current timestamp (seconds, float)
local key = KEYS[1]
local capacity = tonumber(ARGV[1])
local refill_rate = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

local bucket = redis.call("HMGET", key, "tokens", "last_refill")
local tokens = tonumber(bucket[1]) or capacity
local last_refill = tonumber(bucket[2]) or now

-- Refill tokens
local elapsed = now - last_refill
local new_tokens = elapsed * refill_rate
tokens = math.min(capacity, tokens + new_tokens)

-- Try to consume a token
local allowed = 0
if tokens >= 1 then
  tokens = tokens - 1
  allowed = 1
end

-- Store state
redis.call("HMSET", key, "tokens", tokens, "last_refill", now)
redis.call("EXPIRE", key, math.ceil(capacity / refill_rate) * 2)

return { allowed, math.floor(tokens) }
```

#### Leaky Bucket Algorithm
```
LEAKY BUCKET:

How it works:
  - Requests enter a queue (bucket) of fixed size
  - Requests are processed at a constant rate (leak rate)
  - New requests are rejected if the queue is full
  - Smooths out bursts -- output rate is always constant

Parameters:
  bucket_size: 100       # Max queue depth
  leak_rate: 10/sec      # Processing rate (constant)

Behavior:
  +-----------------------------------------------------+
  |  Output Rate                                         |
  |  20 |                                                |
  |     |                                                |
  |  10 |========================================        |
  |     |  constant output regardless of input bursts    |
  |   0 |____________________________________________    |
  |     0    2    4    6    8    10   12   14   16  sec   |
  +-----------------------------------------------------+

  vs Token Bucket:
  +-----------------------------------------------------+
  |  Output Rate                                         |
  |  100|**                                              |
  |     |  \                                             |
  |  10 |   =========================================    |
  |     |   allows bursts then settles to steady rate    |
  |   0 |____________________________________________    |
  |     0    2    4    6    8    10   12   14   16  sec   |
  +-----------------------------------------------------+

PSEUDOCODE:
class LeakyBucket:
  def __init__(self, capacity, leak_rate):
    self.capacity = capacity
    self.water = 0
    self.leak_rate = leak_rate            # requests per second
    self.last_leak = now()

  def allow(self):
    self._leak()
    if self.water < self.capacity:
      self.water += 1
      return True
    return False

  def _leak(self):
    elapsed = now() - self.last_leak
    leaked = elapsed * self.leak_rate
    self.water = max(0, self.water - leaked)
    self.last_leak = now()

USE WHEN:
- You need a perfectly smooth output rate
- Protecting downstream services from burst traffic
- Traffic shaping at network/proxy level (e.g., nginx)
- Queue-based processing where order matters
```

#### Fixed Window Counter
```
FIXED WINDOW COUNTER:

How it works:
  - Time is divided into fixed windows (e.g., 1-minute intervals)
  - Each window has a counter
  - Request increments the counter for the current window
  - Request denied if counter exceeds limit

Parameters:
  window_size: 60s       # Window duration
  max_requests: 100      # Requests per window

Behavior:
  Window 1 (00:00-01:00): count = 87  -> all allowed
  Window 2 (01:00-02:00): count = 100 -> limit reached at request 100
  Window 3 (02:00-03:00): count = 0   -> counter resets

  BOUNDARY PROBLEM:
  +-----------------------------------------------------+
  | Window 1          | Window 2          |              |
  | limit: 100        | limit: 100        |              |
  |             90 req | 90 req            |              |
  |            [======]|[======]           |              |
  |    00:30  00:59  01:00  01:30          |              |
  |                                                      |
  | 180 requests in 60 seconds around the boundary!      |
  | (90 at end of window 1 + 90 at start of window 2)   |
  +-----------------------------------------------------+

REDIS IMPLEMENTATION:
async function fixedWindowRateLimit(client_id, limit, window_sec):
  const window_key = `rate:${client_id}:${Math.floor(Date.now() / 1000 / window_sec)}`
  const count = await redis.incr(window_key)
  if (count === 1):
    await redis.expire(window_key, window_sec)
  return count <= limit

USE WHEN:
- Simplicity is more important than precision
- The boundary spike problem is acceptable
- You need exact reset times (e.g., "100 requests per calendar minute")
- Memory efficiency matters (1 counter per window per client)

DO NOT USE WHEN:
- Traffic must be strictly limited (boundary problem is unacceptable)
- Precision is important for billing or security
```

#### Sliding Window Log
```
SLIDING WINDOW LOG:

How it works:
  - Store timestamp of every request in a sorted set
  - For each request, remove timestamps older than the window
  - Count remaining timestamps
  - Deny if count exceeds limit

Parameters:
  window_size: 60s       # Sliding window duration
  max_requests: 100      # Requests per window

Behavior:
  +-----------------------------------------------------+
  |  <------ 60 second window slides with time ------>  |
  |                                                      |
  |  00:00  00:15  00:30  00:45  01:00  01:15  01:30    |
  |  |============================|                      |
  |          window at T=01:00                           |
  |         |============================|               |
  |                 window at T=01:15                    |
  +-----------------------------------------------------+

  No boundary problem -- every request sees exactly the last 60 seconds

REDIS IMPLEMENTATION (Sorted Set):
async function slidingWindowLog(client_id, limit, window_sec):
  const key = `rate:${client_id}`
  const now = Date.now()
  const window_start = now - (window_sec * 1000)

  // Atomic pipeline
  const pipe = redis.pipeline()
  pipe.zremrangebyscore(key, 0, window_start)     // Remove old entries
  pipe.zadd(key, now, `${now}:${uuid()}`)         // Add current request
  pipe.zcard(key)                                  // Count requests in window
  pipe.expire(key, window_sec)                     // Set TTL for cleanup

  const results = await pipe.exec()
  const count = results[2]

  return count <= limit

USE WHEN:
- Precision is critical (billing, security-sensitive endpoints)
- Traffic volume per client is low-to-moderate

DO NOT USE WHEN:
- High-volume clients (memory grows with request count per window)
- Memory efficiency is critical
```

#### Sliding Window Counter (Recommended Default)
```
SLIDING WINDOW COUNTER:

How it works:
  - Combines fixed window counter with sliding window accuracy
  - Uses weighted average of current and previous window counters
  - Near-perfect accuracy with fixed window memory efficiency

Parameters:
  window_size: 60s       # Window duration
  max_requests: 100      # Requests per window

Calculation:
  previous_window_count = 42
  current_window_count = 18
  time_into_current_window = 15s (out of 60s)
  window_weight = (60 - 15) / 60 = 0.75

  estimated_count = (42 * 0.75) + 18 = 49.5
  -> 49.5 < 100, so request is ALLOWED

  +-----------------------------------------------------+
  | Prev Window (42 req) | Current Window (18 req)      |
  | [=====...............]|[===........................] |
  |                     ^ |                              |
  |                 boundary                             |
  |                                                      |
  |  Sliding estimate = 42 * 0.75 + 18 = 49.5           |
  |  (75% of prev window + 100% of current)              |
  +-----------------------------------------------------+

REDIS IMPLEMENTATION (Lua script):
-- KEYS[1] = rate limit key prefix
-- ARGV[1] = limit
-- ARGV[2] = window size in seconds
-- ARGV[3] = current timestamp
local prefix = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

local current_window = math.floor(now / window)
local prev_window = current_window - 1
local time_into_window = now - (current_window * window)
local weight = (window - time_into_window) / window

local prev_count = tonumber(redis.call("GET", prefix .. ":" .. prev_window) or "0")
local curr_count = tonumber(redis.call("GET", prefix .. ":" .. current_window) or "0")

local estimated = (prev_count * weight) + curr_count

if estimated >= limit then
  return { 0, math.ceil(estimated), limit }
end

-- Increment current window
redis.call("INCR", prefix .. ":" .. current_window)
redis.call("EXPIRE", prefix .. ":" .. current_window, window * 2)

return { 1, math.ceil(estimated) + 1, limit }

USE WHEN:
- You need a good balance of accuracy and memory efficiency
- This is the RECOMMENDED DEFAULT for most APIs
- Works well at any traffic volume
- Used by Cloudflare, Stripe, and most major APIs

ALGORITHM COMPARISON:
+--------------------------------------------------------------+
|  Algorithm            | Accuracy | Memory   | Burst  | Use    |
+--------------------------------------------------------------+
|  Token Bucket         | Good     | O(1)     | Yes    | APIs   |
|  Leaky Bucket         | Exact    | O(1)     | No     | Shaping|
|  Fixed Window         | Low      | O(1)     | Edge*  | Simple |
|  Sliding Window Log   | Exact    | O(n)     | No     | Billing|
|  Sliding Window Ctr   | High     | O(1)     | No     | Default|
+--------------------------------------------------------------+
* Fixed window allows 2x burst at window boundaries
```

### Step 3: Rate Limit Tier Design
Design rate limits by user tier and endpoint sensitivity:

```
RATE LIMIT TIERS:
+--------------------------------------------------------------+
|  Tier          | Rate (req/min) | Burst | Daily Quota | Cost  |
+--------------------------------------------------------------+
|  Anonymous     | 20             | 5     | 1,000       | Free  |
|  Free Tier     | 60             | 15    | 10,000      | Free  |
|  Basic Plan    | 300            | 50    | 100,000     | $29   |
|  Pro Plan      | 1,000          | 200   | 1,000,000   | $99   |
|  Enterprise    | 5,000          | 1,000 | Unlimited   | Custom|
|  Internal      | No limit       | --    | --          | --    |
+--------------------------------------------------------------+

ENDPOINT-SPECIFIC LIMITS (override tier defaults):
+--------------------------------------------------------------+
|  Endpoint              | Limit       | Reason                  |
+--------------------------------------------------------------+
|  POST /auth/login      | 5/min       | Brute force prevention  |
|  POST /auth/register   | 3/min       | Abuse prevention        |
|  POST /auth/forgot-pw  | 3/hour      | Email flooding          |
|  POST /upload           | 10/hour     | Storage cost            |
|  POST /ai/generate     | 20/min      | Compute cost            |
|  GET  /export           | 5/hour      | Data exfiltration       |
|  POST /payment          | 10/min      | Fraud prevention        |
|  GET  /search           | 30/min      | Database load           |
+--------------------------------------------------------------+

TIER RESOLUTION ORDER:
  1. Check endpoint-specific limit (strictest)
  2. Check user tier limit
  3. Check global/IP limit
  4. Apply most restrictive limit that matches

PSEUDOCODE:
async function resolveRateLimit(request):
  const client = identifyClient(request)  // API key, JWT, IP
  const tier = await getTier(client)       // free, basic, pro, enterprise
  const endpoint = request.path + ":" + request.method

  // Check endpoint-specific override first
  const endpointLimit = ENDPOINT_LIMITS[endpoint]
  if (endpointLimit):
    if (!await checkLimit(`rate:endpoint:${client.id}:${endpoint}`, endpointLimit)):
      return { allowed: false, reason: "endpoint_limit" }

  // Check tier limit
  const tierLimit = TIER_LIMITS[tier]
  if (!await checkLimit(`rate:tier:${client.id}`, tierLimit)):
    return { allowed: false, reason: "tier_limit" }

  // Check global IP limit (catch-all for abuse)
  const ipLimit = { requests: 1000, window: 60 }
  if (!await checkLimit(`rate:ip:${request.ip}`, ipLimit)):
    return { allowed: false, reason: "ip_limit" }

  return { allowed: true }
```

### Step 4: Response Headers & Client Communication
Implement standard rate limit response headers:

```
RATE LIMIT RESPONSE HEADERS:

Standard Headers (IETF draft-ietf-httpapi-ratelimit-headers):
+--------------------------------------------------------------+
|  Header                   | Example    | Description          |
+--------------------------------------------------------------+
|  RateLimit-Limit          | 100        | Max requests in win  |
|  RateLimit-Remaining      | 73         | Requests left        |
|  RateLimit-Reset          | 1672531260 | Unix time of reset   |
|  Retry-After              | 30         | Seconds until retry  |
+--------------------------------------------------------------+

Legacy Headers (still widely used):
+--------------------------------------------------------------+
|  Header                   | Example    | Description          |
+--------------------------------------------------------------+
|  X-RateLimit-Limit        | 100        | Max requests allowed |
|  X-RateLimit-Remaining    | 73         | Requests remaining   |
|  X-RateLimit-Reset        | 1672531260 | Window reset time    |
+--------------------------------------------------------------+

SUCCESS RESPONSE (200 OK):
  HTTP/1.1 200 OK
  RateLimit-Limit: 100
  RateLimit-Remaining: 73
  RateLimit-Reset: 1672531260
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 73
  X-RateLimit-Reset: 1672531260

RATE LIMITED RESPONSE (429 Too Many Requests):
  HTTP/1.1 429 Too Many Requests
  RateLimit-Limit: 100
  RateLimit-Remaining: 0
  RateLimit-Reset: 1672531260
  Retry-After: 30
  Content-Type: application/json

  {
    "error": {
      "code": "RATE_LIMIT_EXCEEDED",
      "message": "Rate limit exceeded. Try again in 30 seconds.",
      "retry_after": 30,
      "limit": 100,
      "window": "1m",
      "docs_url": "https://api.example.com/docs/rate-limits"
    }
  }

HEADER IMPLEMENTATION:
function setRateLimitHeaders(res, limitInfo):
  const { limit, remaining, reset_at } = limitInfo

  // Modern headers (IETF standard)
  res.setHeader("RateLimit-Limit", limit)
  res.setHeader("RateLimit-Remaining", Math.max(0, remaining))
  res.setHeader("RateLimit-Reset", Math.ceil(reset_at / 1000))

  // Legacy headers (backwards compatibility)
  res.setHeader("X-RateLimit-Limit", limit)
  res.setHeader("X-RateLimit-Remaining", Math.max(0, remaining))
  res.setHeader("X-RateLimit-Reset", Math.ceil(reset_at / 1000))

  if (remaining <= 0):
    const retry_after = Math.ceil((reset_at - Date.now()) / 1000)
    res.setHeader("Retry-After", Math.max(1, retry_after))
```

### Step 5: Distributed Rate Limiting with Redis
Implement rate limiting that works across multiple application instances:

```
DISTRIBUTED RATE LIMITING:

Challenge:
  App Instance 1 --\
  App Instance 2 ---+-- Shared Redis --> consistent limit enforcement
  App Instance 3 --/

  Without shared state, each instance enforces independently
  -> 3 instances with 100 req/min limit = 300 req/min total (WRONG)

REDIS-BASED SLIDING WINDOW COUNTER (Production-Ready Lua):
-- ratelimit.lua
-- Atomic sliding window counter rate limiter
-- KEYS[1] = rate limit key
-- ARGV[1] = max requests per window
-- ARGV[2] = window size in seconds
-- ARGV[3] = current timestamp (milliseconds)

local key = KEYS[1]
local limit = tonumber(ARGV[1])
local window = tonumber(ARGV[2])
local now = tonumber(ARGV[3])

local current_window = math.floor(now / 1000 / window)
local prev_window = current_window - 1
local time_in_window = (now / 1000) - (current_window * window)
local weight = (window - time_in_window) / window

local curr_key = key .. ":" .. current_window
local prev_key = key .. ":" .. prev_window

local prev_count = tonumber(redis.call("GET", prev_key) or "0")
local curr_count = tonumber(redis.call("GET", curr_key) or "0")

local estimated = math.floor(prev_count * weight) + curr_count

if estimated >= limit then
  local reset_at = (current_window + 1) * window * 1000
  return { 0, limit, 0, reset_at }  -- denied
end

local new_count = redis.call("INCR", curr_key)
if new_count == 1 then
  redis.call("EXPIRE", curr_key, window * 2)
end

local remaining = limit - (math.floor(prev_count * weight) + new_count)
local reset_at = (current_window + 1) * window * 1000

return { 1, limit, math.max(0, remaining), reset_at }
-- Returns: { allowed, limit, remaining, reset_at }

LOADING AND CALLING THE LUA SCRIPT:
// Node.js / ioredis
const fs = require("fs")
const luaScript = fs.readFileSync("ratelimit.lua", "utf8")

// Load script once (Redis caches it by SHA)
const scriptSha = await redis.script("LOAD", luaScript)

async function rateLimit(clientId, limit, windowSec):
  const key = `rate:${clientId}`
  const now = Date.now()

  const [allowed, max, remaining, resetAt] = await redis.evalsha(
    scriptSha, 1, key, limit, windowSec, now
  )

  return {
    allowed: allowed === 1,
    limit: max,
    remaining: remaining,
    reset_at: resetAt
  }

// Python / redis-py
import redis
import time

r = redis.Redis()
lua_script = r.register_script(open("ratelimit.lua").read())

def rate_limit(client_id, limit, window_sec):
    key = f"rate:{client_id}"
    now = int(time.time() * 1000)
    result = lua_script(keys=[key], args=[limit, window_sec, now])
    allowed, max_limit, remaining, reset_at = result
    return {
        "allowed": bool(allowed),
        "limit": int(max_limit),
        "remaining": int(remaining),
        "reset_at": int(reset_at),
    }

WHY LUA SCRIPTS:
- Atomic: entire script executes without interruption
- No race conditions between INCR and EXPIRE
- Network efficient: one round trip instead of multiple commands
- Redis caches compiled scripts by SHA for performance
```

### Step 6: Middleware Implementations
Rate limiting middleware for popular frameworks:

#### Express.js (Node.js)
```
EXPRESS RATE LIMITER:

// middleware/rateLimit.js
const Redis = require("ioredis")
const redis = new Redis({ host: "redis", port: 6379 })

// Load Lua script
const LUA_SCRIPT = `<sliding window counter script from Step 5>`
let scriptSha = null

async function loadScript():
  scriptSha = await redis.script("LOAD", LUA_SCRIPT)

function rateLimit(options = {}):
  const {
    limit = 100,               // requests per window
    window = 60,               // window in seconds
    keyGenerator = (req) => req.ip,
    tierResolver = null,       // optional: resolve user tier
    skipIf = null,             // optional: skip rate limit condition
    onLimited = null,          // optional: custom 429 handler
  } = options

  return async (req, res, next) => {
    // Skip rate limiting for certain conditions
    if (skipIf && skipIf(req)):
      return next()

    // Resolve client key
    const clientKey = keyGenerator(req)

    // Resolve tier-based limits
    let effectiveLimit = limit
    if (tierResolver):
      const tier = await tierResolver(req)
      effectiveLimit = tier.limit || limit

    // Check rate limit
    if (!scriptSha) await loadScript()
    const [allowed, max, remaining, resetAt] = await redis.evalsha(
      scriptSha, 1, `rate:${clientKey}`, effectiveLimit, window, Date.now()
    )

    // Set headers on every response
    res.set("RateLimit-Limit", String(max))
    res.set("RateLimit-Remaining", String(Math.max(0, remaining)))
    res.set("RateLimit-Reset", String(Math.ceil(resetAt / 1000)))
    res.set("X-RateLimit-Limit", String(max))
    res.set("X-RateLimit-Remaining", String(Math.max(0, remaining)))
    res.set("X-RateLimit-Reset", String(Math.ceil(resetAt / 1000)))

    if (allowed):
      return next()

    // Rate limited
    const retryAfter = Math.max(1, Math.ceil((resetAt - Date.now()) / 1000))
    res.set("Retry-After", String(retryAfter))

    if (onLimited):
      return onLimited(req, res, next)

    res.status(429).json({
      error: {
        code: "RATE_LIMIT_EXCEEDED",
        message: `Rate limit exceeded. Try again in ${retryAfter} seconds.`,
        retry_after: retryAfter,
        limit: max,
      }
    })
  }

// Usage:
const app = express()

// Global rate limit: 100 req/min per IP
app.use(rateLimit({ limit: 100, window: 60 }))

// Stricter limit on auth endpoints: 5 req/min per IP
app.use("/api/auth", rateLimit({
  limit: 5,
  window: 60,
  keyGenerator: (req) => `auth:${req.ip}`,
}))

// Tier-based limit on API endpoints
app.use("/api/v1", rateLimit({
  limit: 100,
  window: 60,
  keyGenerator: (req) => req.headers["x-api-key"] || req.ip,
  tierResolver: async (req) => {
    const apiKey = req.headers["x-api-key"]
    if (!apiKey) return { limit: 20 }  // anonymous
    const tier = await db.query("SELECT tier FROM api_keys WHERE key = $1", [apiKey])
    return TIER_LIMITS[tier] || { limit: 60 }
  },
}))

// Skip rate limiting for internal services
app.use("/internal", rateLimit({
  limit: 10000,
  window: 60,
  skipIf: (req) => req.headers["x-internal-token"] === process.env.INTERNAL_TOKEN,
}))
```

#### FastAPI (Python)
```
FASTAPI RATE LIMITER:

# middleware/rate_limit.py
import time
import redis.asyncio as redis
from fastapi import Request, Response, HTTPException
from starlette.middleware.base import BaseHTTPMiddleware

pool = redis.ConnectionPool.from_url("redis://redis:6379", max_connections=20)

LUA_SCRIPT = """<sliding window counter script from Step 5>"""

class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, default_limit=100, window=60):
        super().__init__(app)
        self.default_limit = default_limit
        self.window = window
        self.script_sha = None
        self.redis = redis.Redis(connection_pool=pool)

    async def _load_script(self):
        if not self.script_sha:
            self.script_sha = await self.redis.script_load(LUA_SCRIPT)

    async def dispatch(self, request: Request, call_next):
        # Skip health checks
        if request.url.path in ("/healthz", "/readyz"):
            return await call_next(request)

        client_key = self._get_client_key(request)
        limit = await self._resolve_limit(request)

        await self._load_script()
        result = await self.redis.evalsha(
            self.script_sha, 1, f"rate:{client_key}",
            limit, self.window, int(time.time() * 1000)
        )
        allowed, max_limit, remaining, reset_at = result

        # Set headers
        headers = {
            "RateLimit-Limit": str(max_limit),
            "RateLimit-Remaining": str(max(0, remaining)),
            "RateLimit-Reset": str(reset_at // 1000),
            "X-RateLimit-Limit": str(max_limit),
            "X-RateLimit-Remaining": str(max(0, remaining)),
            "X-RateLimit-Reset": str(reset_at // 1000),
        }

        if not allowed:
            retry_after = max(1, (reset_at - int(time.time() * 1000)) // 1000)
            headers["Retry-After"] = str(retry_after)
            raise HTTPException(
                status_code=429,
                detail={
                    "code": "RATE_LIMIT_EXCEEDED",
                    "message": f"Rate limit exceeded. Try again in {retry_after}s.",
                    "retry_after": retry_after,
                },
                headers=headers,
            )

        response = await call_next(request)
        for key, value in headers.items():
            response.headers[key] = value
        return response

    def _get_client_key(self, request: Request) -> str:
        api_key = request.headers.get("x-api-key")
        if api_key:
            return f"key:{api_key}"
        return f"ip:{request.client.host}"

    async def _resolve_limit(self, request: Request) -> int:
        # Endpoint-specific limits
        endpoint_limits = {
            ("POST", "/api/auth/login"): 5,
            ("POST", "/api/auth/register"): 3,
            ("POST", "/api/upload"): 10,
        }
        key = (request.method, request.url.path)
        if key in endpoint_limits:
            return endpoint_limits[key]
        return self.default_limit

# Usage:
# app = FastAPI()
# app.add_middleware(RateLimitMiddleware, default_limit=100, window=60)

# Decorator-based rate limiting for specific routes:
from functools import wraps

def rate_limit(limit: int, window: int = 60):
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, request: Request, **kwargs):
            r = redis.Redis(connection_pool=pool)
            client_key = request.headers.get("x-api-key") or request.client.host
            # ... check rate limit ...
            return await func(*args, request=request, **kwargs)
        return wrapper
    return decorator

@app.post("/api/ai/generate")
@rate_limit(limit=20, window=60)
async def generate(request: Request):
    ...
```

#### Django Middleware
```
DJANGO RATE LIMITER:

# middleware/rate_limit.py
import time
import json
import django_redis
from django.http import JsonResponse

class RateLimitMiddleware:
    ENDPOINT_LIMITS = {
        "POST:/api/auth/login/": {"limit": 5, "window": 60},
        "POST:/api/auth/register/": {"limit": 3, "window": 60},
    }

    def __init__(self, get_response):
        self.get_response = get_response
        self.redis = django_redis.get_redis_connection("default")
        self.default_limit = 100
        self.default_window = 60

    def __call__(self, request):
        # Skip admin and static
        if request.path.startswith(("/admin/", "/static/")):
            return self.get_response(request)

        client_key = self._get_client_key(request)
        limit, window = self._resolve_limit(request)

        allowed, info = self._check_rate_limit(client_key, limit, window)

        if not allowed:
            response = JsonResponse({
                "error": {
                    "code": "RATE_LIMIT_EXCEEDED",
                    "message": f"Rate limit exceeded. Try again in {info['retry_after']}s.",
                    "retry_after": info["retry_after"],
                }
            }, status=429)
            response["Retry-After"] = str(info["retry_after"])
        else:
            response = self.get_response(request)

        response["RateLimit-Limit"] = str(info["limit"])
        response["RateLimit-Remaining"] = str(info["remaining"])
        response["RateLimit-Reset"] = str(info["reset_at"])
        return response

    def _get_client_key(self, request):
        api_key = request.META.get("HTTP_X_API_KEY")
        if api_key:
            return f"key:{api_key}"
        ip = request.META.get("HTTP_X_FORWARDED_FOR", request.META.get("REMOTE_ADDR"))
        return f"ip:{ip.split(',')[0].strip()}"

    def _resolve_limit(self, request):
        key = f"{request.method}:{request.path}"
        endpoint = self.ENDPOINT_LIMITS.get(key)
        if endpoint:
            return endpoint["limit"], endpoint["window"]
        return self.default_limit, self.default_window

    def _check_rate_limit(self, client_key, limit, window):
        # Sliding window counter (inline for simplicity)
        now = time.time()
        current_window = int(now // window)
        prev_window = current_window - 1
        time_in_window = now - (current_window * window)
        weight = (window - time_in_window) / window

        curr_key = f"rate:{client_key}:{current_window}"
        prev_key = f"rate:{client_key}:{prev_window}"

        pipe = self.redis.pipeline()
        pipe.get(prev_key)
        pipe.incr(curr_key)
        pipe.expire(curr_key, window * 2)
        prev_count, curr_count, _ = pipe.execute()

        prev_count = int(prev_count or 0)
        estimated = int(prev_count * weight) + curr_count
        remaining = max(0, limit - estimated)
        reset_at = (current_window + 1) * window

        allowed = estimated <= limit
        retry_after = max(1, int(reset_at - now)) if not allowed else 0

        return allowed, {
            "limit": limit,
            "remaining": remaining,
            "reset_at": int(reset_at),
            "retry_after": retry_after,
        }

# settings.py:
# MIDDLEWARE = [
#     "middleware.rate_limit.RateLimitMiddleware",
#     ...
# ]
```

#### Go (net/http)
```
GO RATE LIMITER:

// middleware/ratelimit.go
package middleware

import (
    "context"
    "encoding/json"
    "fmt"
    "math"
    "net/http"
    "strconv"
    "time"

    "github.com/redis/go-redis/v9"
)

var luaScript = redis.NewScript(`
    -- Sliding window counter (same Lua script from Step 5)
    local key = KEYS[1]
    local limit = tonumber(ARGV[1])
    local window = tonumber(ARGV[2])
    local now = tonumber(ARGV[3])
    local current_window = math.floor(now / 1000 / window)
    local prev_window = current_window - 1
    local time_in_window = (now / 1000) - (current_window * window)
    local weight = (window - time_in_window) / window
    local curr_key = key .. ":" .. current_window
    local prev_key = key .. ":" .. prev_window
    local prev_count = tonumber(redis.call("GET", prev_key) or "0")
    local curr_count = tonumber(redis.call("GET", curr_key) or "0")
    local estimated = math.floor(prev_count * weight) + curr_count
    if estimated >= limit then
        local reset_at = (current_window + 1) * window * 1000
        return { 0, limit, 0, reset_at }
    end
    local new_count = redis.call("INCR", curr_key)
    if new_count == 1 then
        redis.call("EXPIRE", curr_key, window * 2)
    end
    local remaining = limit - (math.floor(prev_count * weight) + new_count)
    local reset_at = (current_window + 1) * window * 1000
    return { 1, limit, math.max(0, remaining), reset_at }
`)

type RateLimiter struct {
    rdb          *redis.Client
    defaultLimit int
    windowSec    int
}

func NewRateLimiter(rdb *redis.Client, limit, window int) *RateLimiter {
    return &RateLimiter{rdb: rdb, defaultLimit: limit, windowSec: window}
}

func (rl *RateLimiter) Middleware(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        clientKey := resolveClientKey(r)
        limit := rl.defaultLimit
        now := time.Now().UnixMilli()

        result, err := luaScript.Run(
            context.Background(), rl.rdb,
            []string{fmt.Sprintf("rate:%s", clientKey)},
            limit, rl.windowSec, now,
        ).Int64Slice()

        if err != nil {
            // Fail open: allow request if Redis is down
            next.ServeHTTP(w, r)
            return
        }

        allowed, maxLimit, remaining, resetAt := result[0], result[1], result[2], result[3]

        w.Header().Set("RateLimit-Limit", strconv.FormatInt(maxLimit, 10))
        w.Header().Set("RateLimit-Remaining", strconv.FormatInt(remaining, 10))
        w.Header().Set("RateLimit-Reset", strconv.FormatInt(resetAt/1000, 10))

        if allowed == 0 {
            retryAfter := int(math.Max(1, float64(resetAt-now)/1000))
            w.Header().Set("Retry-After", strconv.Itoa(retryAfter))
            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusTooManyRequests)
            json.NewEncoder(w).Encode(map[string]interface{}{
                "error": map[string]interface{}{
                    "code":        "RATE_LIMIT_EXCEEDED",
                    "message":     fmt.Sprintf("Rate limit exceeded. Try again in %ds.", retryAfter),
                    "retry_after": retryAfter,
                },
            })
            return
        }

        next.ServeHTTP(w, r)
    })
}

func resolveClientKey(r *http.Request) string {
    apiKey := r.Header.Get("X-API-Key")
    if apiKey != "" {
        return "key:" + apiKey
    }
    ip := r.Header.Get("X-Forwarded-For")
    if ip == "" {
        ip = r.RemoteAddr
    }
    return "ip:" + ip
}

// Usage:
// rdb := redis.NewClient(&redis.Options{Addr: "redis:6379"})
// rl := middleware.NewRateLimiter(rdb, 100, 60)
// mux := http.NewServeMux()
// handler := rl.Middleware(mux)
// http.ListenAndServe(":8080", handler)
```

### Step 7: Graceful Degradation & Bypass
Handle rate limiter failures and internal service bypass:

```
GRACEFUL DEGRADATION:

Rule: Rate limiter failure must NEVER cause application failure.
      When Redis is down, ALLOW requests (fail open).

FAIL-OPEN PATTERN:
async function checkRateLimit(clientKey, limit, window):
  try:
    return await redis.evalsha(scriptSha, 1, `rate:${clientKey}`, limit, window, Date.now())
  catch (error):
    // Redis is down -- fail open
    logger.warn("Rate limiter unavailable, failing open", { error: error.message })
    metrics.increment("ratelimit.failopen")

    // Return an "allowed" response with unknown remaining
    return { allowed: true, limit: limit, remaining: -1, reset_at: 0 }

LOCAL FALLBACK (in-memory rate limiter):
  When Redis is unavailable, fall back to per-instance in-memory limiter.
  Less accurate (per-instance, not global) but prevents total bypass.

  const localLimiter = new Map()  // clientKey -> { count, window_start }

  function localRateLimit(clientKey, limit, windowSec):
    const now = Date.now()
    const entry = localLimiter.get(clientKey)

    if (!entry || now - entry.window_start > windowSec * 1000):
      localLimiter.set(clientKey, { count: 1, window_start: now })
      return { allowed: true, remaining: limit - 1 }

    entry.count++
    if (entry.count > limit):
      return { allowed: false, remaining: 0 }

    return { allowed: true, remaining: limit - entry.count }

  // Cleanup stale entries every minute
  setInterval(() => {
    const cutoff = Date.now() - 120000
    for (const [key, entry] of localLimiter):
      if (entry.window_start < cutoff):
        localLimiter.delete(key)
  }, 60000)

INTERNAL SERVICE BYPASS:
  Internal services (service-to-service calls) should bypass rate limits
  to prevent cascading failures in microservice architectures.

  BYPASS METHODS:
  +--------------------------------------------------------------+
  |  Method               | Security    | Complexity              |
  +--------------------------------------------------------------+
  |  Internal token header| Medium      | Low                     |
  |  IP allowlist         | Medium      | Low                     |
  |  mTLS certificate     | High        | Medium                  |
  |  Service mesh (Istio) | High        | High                    |
  +--------------------------------------------------------------+

  // Internal token bypass
  function shouldBypassRateLimit(req):
    // Method 1: Internal token
    if (req.headers["x-internal-token"] === process.env.INTERNAL_SECRET):
      return true

    // Method 2: IP allowlist (internal CIDRs)
    const internalCIDRs = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
    if (isInCIDR(req.ip, internalCIDRs)):
      return true

    // Method 3: mTLS client certificate
    if (req.socket.getPeerCertificate()?.subject?.CN?.endsWith(".internal")):
      return true

    return false
```

### Step 8: API Key Quota Management
Track and enforce daily/monthly quotas per API key:

```
API KEY QUOTA MANAGEMENT:

QUOTA vs RATE LIMIT:
  Rate limit: Max requests per SHORT window (e.g., 100/min)
  Quota: Max requests per LONG window (e.g., 10,000/day or 1M/month)

  Both should be enforced. Rate limits prevent spikes.
  Quotas prevent total overuse.

QUOTA TRACKING (Redis):
// Daily quota
async function checkQuota(apiKey, dailyLimit):
  const today = new Date().toISOString().split("T")[0]  // "2024-01-15"
  const key = `quota:${apiKey}:${today}`

  const pipe = redis.pipeline()
  pipe.incr(key)
  pipe.expire(key, 86400 * 2)  // TTL: 2 days (cleanup buffer)
  const [count] = await pipe.exec()

  return {
    allowed: count <= dailyLimit,
    used: count,
    limit: dailyLimit,
    remaining: Math.max(0, dailyLimit - count),
    resets_at: getEndOfDay(),
  }

// Monthly quota with daily pre-aggregation
async function checkMonthlyQuota(apiKey, monthlyLimit):
  const month = new Date().toISOString().slice(0, 7)  // "2024-01"
  const key = `quota:monthly:${apiKey}:${month}`

  const count = await redis.incr(key)
  if (count === 1):
    await redis.expire(key, 86400 * 35)  // TTL: 35 days

  return {
    allowed: count <= monthlyLimit,
    used: count,
    limit: monthlyLimit,
    remaining: Math.max(0, monthlyLimit - count),
    resets_at: getEndOfMonth(),
  }

QUOTA RESPONSE HEADERS:
  X-Quota-Limit: 10000
  X-Quota-Remaining: 7234
  X-Quota-Reset: 2024-01-16T00:00:00Z

QUOTA WARNING NOTIFICATIONS:
  async function checkQuotaWithAlerts(apiKey, limit):
    const quota = await checkQuota(apiKey, limit)
    const usagePercent = (quota.used / quota.limit) * 100

    if (usagePercent >= 100):
      await notify(apiKey, "quota_exceeded", quota)
    else if (usagePercent >= 90):
      await notify(apiKey, "quota_90_percent", quota)
    else if (usagePercent >= 75):
      await notify(apiKey, "quota_75_percent", quota)

    return quota

QUOTA BILLING INTEGRATION:
  // Overage billing: allow requests beyond quota but charge extra
  async function checkQuotaWithOverage(apiKey, plan):
    const quota = await getQuotaUsage(apiKey)

    if (quota.used <= plan.included):
      return { allowed: true, overage: false }

    if (plan.allow_overage):
      const overageUnits = quota.used - plan.included
      await billing.recordOverage(apiKey, overageUnits, plan.overage_rate)
      return { allowed: true, overage: true, overage_units: overageUnits }

    return { allowed: false, overage: false }
```

### Step 9: Monitoring & Observability
Track rate limiting metrics for operational visibility:

```
RATE LIMIT METRICS:
+--------------------------------------------------------------+
|  Metric                         | Type      | Alert Threshold |
+--------------------------------------------------------------+
|  ratelimit_requests_total       | Counter   | --              |
|  ratelimit_rejected_total       | Counter   | > 100/min       |
|  ratelimit_rejected_ratio       | Gauge     | > 10%           |
|  ratelimit_latency_seconds      | Histogram | P95 > 5ms       |
|  ratelimit_redis_errors_total   | Counter   | > 0             |
|  ratelimit_failopen_total       | Counter   | > 0 (alert)     |
|  quota_usage_percent            | Gauge     | > 90%           |
|  quota_exceeded_total           | Counter   | > 0             |
+--------------------------------------------------------------+

PROMETHEUS METRICS EXAMPLE:
  // Instrument the rate limiter
  const rateLimitChecks = new Counter({
    name: "ratelimit_requests_total",
    help: "Total rate limit checks",
    labelNames: ["result", "tier", "endpoint"],
  })

  const rateLimitLatency = new Histogram({
    name: "ratelimit_latency_seconds",
    help: "Rate limit check latency",
    buckets: [0.001, 0.002, 0.005, 0.01, 0.025, 0.05],
  })

  // In middleware:
  const timer = rateLimitLatency.startTimer()
  const result = await checkRateLimit(clientKey, limit, window)
  timer()
  rateLimitChecks.inc({ result: result.allowed ? "allowed" : "rejected", tier, endpoint })

RATE LIMIT DASHBOARD:
+--------------------------------------------------------------+
|  ROW 1: Overview                                              |
|  +------------------+ +------------------+ +----------------+ |
|  | Total Requests   | | Rejected (429)   | | Reject Rate    | |
|  |  125,432/min     | |  342/min (0.3%)  | |  0.27%         | |
|  +------------------+ +------------------+ +----------------+ |
|                                                               |
|  ROW 2: Top Rate-Limited Clients                              |
|  +------------------------------------------------------+    |
|  | Client           | Rejected | Tier   | Limit          |    |
|  | api-key-abc      | 89       | free   | 60/min         |    |
|  | 203.0.113.42     | 67       | anon   | 20/min         |    |
|  | api-key-def      | 34       | basic  | 300/min        |    |
|  +------------------------------------------------------+    |
|                                                               |
|  ROW 3: Rate Limiter Health                                   |
|  +------------------+ +------------------+ +----------------+ |
|  | Redis Latency    | | Fail-Open Count  | | Error Rate     | |
|  | P50: 0.3ms       | |  0 (healthy)     | |  0%            | |
|  | P95: 1.2ms       | |                  | |                | |
|  +------------------+ +------------------+ +----------------+ |
+--------------------------------------------------------------+
```

### Step 10: Validation
Validate the rate limiting configuration against best practices:

```
RATE LIMIT VALIDATION:
+--------------------------------------------------------------+
|  Check                                    | Status             |
+--------------------------------------------------------------+
|  All public endpoints have rate limits    | PASS | FAIL        |
|  Auth endpoints have strict limits        | PASS | FAIL        |
|  Rate limit headers returned on all resp  | PASS | FAIL        |
|  429 response includes Retry-After        | PASS | FAIL        |
|  429 response body has error details      | PASS | FAIL        |
|  Distributed limiter uses atomic ops      | PASS | FAIL        |
|  Graceful degradation on Redis failure    | PASS | FAIL        |
|  Internal services can bypass limits      | PASS | FAIL        |
|  User tier limits configured              | PASS | FAIL        |
|  API key quotas tracked (daily/monthly)   | PASS | FAIL        |
|  Quota warning notifications configured   | PASS | FAIL        |
|  Rate limit metrics exported              | PASS | FAIL        |
|  Rate limit dashboard configured          | PASS | FAIL        |
|  Lua scripts used for Redis atomicity     | PASS | FAIL        |
+--------------------------------------------------------------+

VERDICT: <PASS | NEEDS REVISION>
```

### Step 11: Artifacts & Commit
Generate the deliverables:

```
RATE LIMIT STRATEGY COMPLETE:

Artifacts:
- Rate limit design doc: docs/ratelimit/<system>-ratelimit-strategy.md
- Redis Lua scripts: infra/ratelimit/scripts/
- Rate limit middleware: src/middleware/rateLimit.ts (or equivalent)
- Tier configuration: src/config/rateLimitTiers.ts
- Monitoring dashboard: monitoring/dashboards/ratelimit.json
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:loadtest -- Load test rate limits under high concurrency
-> /godmode:secure -- Review rate limits as part of security audit
-> /godmode:observe -- Monitor rejection rates and quota usage
-> /godmode:scale -- Ensure rate limiter scales with traffic growth
```

Commit: `"ratelimit: <system> -- <algorithm>, <tiers configured>, <quota tracking>"`

## Key Behaviors

1. **Rate limit every public endpoint.** An unprotected endpoint is an open door for abuse, scraping, and DDoS. Apply limits by default, loosen selectively.
2. **Use the sliding window counter as the default algorithm.** It provides excellent accuracy with O(1) memory per client. Token bucket is the second choice when burst tolerance is needed.
3. **Atomic operations only.** Use Redis Lua scripts for check-and-increment operations. Non-atomic implementations have race conditions that allow limit bypass under concurrency.
4. **Always return rate limit headers.** Clients need RateLimit-Limit, RateLimit-Remaining, RateLimit-Reset on every response, and Retry-After on 429 responses. This is the contract.
5. **Fail open, not closed.** If Redis is down, allow the request. A broken rate limiter must not become an outage. Log and alert, but serve traffic.
6. **Separate rate limits from quotas.** Rate limits protect against burst abuse (100/min). Quotas protect against sustained overuse (10,000/day). Enforce both.
7. **Tiered limits by user class.** Anonymous, free, paid, and enterprise users should have different limits. Internal services should bypass rate limits entirely.
8. **Monitor rejection rates.** A high rejection rate means either limits are too strict or someone is attacking. A zero rejection rate may mean limits are too loose. Both need investigation.

## Example Usage

### Designing rate limiting for a public API
```
User: /godmode:ratelimit Add rate limiting to our public REST API

Ratelimit: Assessing API surface...

TRAFFIC ANALYSIS:
  POST /api/auth/login     50 QPS   -> 5/min per IP (brute force protection)
  GET  /api/products       2,000 QPS -> tier-based (60-5000/min)
  POST /api/orders         200 QPS   -> 30/min per user
  POST /api/ai/generate    100 QPS   -> 20/min per user (compute cost)

DESIGN:
  Algorithm: Sliding window counter (Redis Lua script)
  Storage: Redis Cluster (shared across 4 app instances)
  Tiers: anonymous (20/min), free (60/min), pro (1000/min), enterprise (5000/min)
  Quotas: free (10K/day), pro (1M/day), enterprise (unlimited)
  Degradation: fail-open with in-memory fallback
  Bypass: internal services via mTLS certificate

MIDDLEWARE: Express.js rate limit middleware with tier resolver
HEADERS: RateLimit-Limit, RateLimit-Remaining, RateLimit-Reset, Retry-After
```

### Troubleshooting rate limit bypass
```
User: /godmode:ratelimit Clients are exceeding our rate limits somehow

Ratelimit: Investigating bypass vectors...

DIAGNOSIS:
  1. Rate limit check uses GET + INCR (not atomic) -> race condition
     Fix: Use Lua script for atomic check-and-increment
  2. Clients rotate API keys to multiply their limit
     Fix: Add IP-based rate limit as secondary check
  3. X-Forwarded-For header is spoofable, bypasses IP limit
     Fix: Trust X-Forwarded-For only from known proxy IPs
  4. WebSocket connections bypass HTTP middleware
     Fix: Add rate limiting to WebSocket message handler

ESTIMATED LEAK: 3x-5x above intended limit
AFTER FIXES: Rate limits enforced within 1-2% tolerance
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full rate limiting strategy design workflow |
| `--assess` | Assess current rate limit coverage and exposure |
| `--algorithm` | Select and implement rate limiting algorithm |
| `--tiers` | Design user tier rate limit configuration |
| `--redis` | Implement distributed rate limiting with Redis |
| `--quota` | Set up API key daily/monthly quota tracking |
| `--headers` | Configure rate limit response headers |
| `--middleware` | Generate rate limit middleware for your framework |
| `--bypass` | Configure internal service bypass rules |
| `--monitor` | Set up rate limit monitoring and alerting |
| `--validate` | Validate rate limit configuration |
| `--test` | Load test rate limits under concurrency |

## HARD RULES

1. NEVER use non-atomic check-and-increment operations. Separate GET then INCR has a race condition. Under concurrency, clients bypass limits by 10x or more. Use Lua scripts or atomic commands.
2. NEVER fail closed when the rate limit backend (Redis, etc.) is unavailable. A rate limiter outage must not become an application outage. Fail open, log, and alert.
3. ALWAYS return standard rate limit headers (`X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`, `Retry-After`). Clients cannot self-throttle without this information.
4. NEVER apply the same limits to authenticated and unauthenticated traffic. Authenticated users have an identity and a billing relationship. Anonymous traffic should have stricter limits.
5. ALWAYS use sliding window or token bucket algorithms for user-facing limits. Fixed window algorithms allow 2x burst at window boundaries.
6. NEVER store rate limit state in application memory for multi-instance deployments. Use a shared store (Redis, Memcached). In-process counters allow N-times bypass where N is the number of instances.
7. ALWAYS exempt internal service-to-service traffic from public rate limits. Internal calls should use a separate bypass mechanism with its own monitoring.
8. NEVER log rate-limited request bodies. Rate-limited endpoints are abuse magnets. Logging payloads at volume fills disks and may capture sensitive data.

## Auto-Detection

Before implementing, detect existing rate limiting infrastructure:

```bash
# Detect existing rate limiting
echo "=== Rate Limit Libraries ==="
grep -r "rate.limit\|ratelimit\|throttle\|express-rate-limit\|bottleneck" package.json requirements.txt Gemfile go.mod 2>/dev/null

# Detect Redis or cache layer
echo "=== Cache/Store Infrastructure ==="
grep -r "redis\|ioredis\|memcached\|upstash" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -5

# Detect existing middleware
echo "=== Rate Limit Middleware ==="
grep -r "rateLim\|throttle\|RateLimit\|rate_limit" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" -l 2>/dev/null | head -5

# Detect API gateway configuration
echo "=== API Gateway ==="
ls -la nginx.conf kong.yml traefik.yml gateway.yaml 2>/dev/null
grep -r "rate_limit\|throttling" --include="*.yaml" --include="*.yml" -l 2>/dev/null | head -5

# Detect response headers already set
echo "=== Existing Headers ==="
grep -r "X-RateLimit\|Retry-After\|x-rate" --include="*.ts" --include="*.js" --include="*.py" -l 2>/dev/null | head -5
```

## Keep/Discard Discipline
```
After EACH rate limit configuration change:
  1. MEASURE: Send requests at the configured limit — does the (N+1)th request return 429?
  2. COMPARE: Are headers correct (RateLimit-Limit, Remaining, Reset, Retry-After)?
  3. DECIDE:
     - KEEP if: limit enforced atomically, headers present, fail-open on Redis down
     - DISCARD if: race condition allows bypass OR 429 missing Retry-After OR fail-closed on backend outage
  4. COMMIT kept changes. Run `git reset --hard` on discarded changes before configuring the next tier.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All public endpoints have rate limits with correct response headers
  - Tiered limits configured for all user classes (anonymous through enterprise)
  - Fail-open degradation verified (Redis down = requests allowed + alert)
  - User explicitly requests stop

DO NOT STOP just because:
  - Monitoring dashboards are not yet built (metrics export is sufficient)
  - Daily/monthly quotas are not yet enforced (per-minute rate limits are higher priority)
```

## Anti-Patterns

- **Do NOT hardcode limits.** Limits must be configurable per tier, per endpoint, and changeable without a deploy. Use a configuration file or database, not constants in code.
- **Do NOT trust X-Forwarded-For blindly.** Clients can spoof this header. Only trust it from known reverse proxy IPs. Otherwise, use the direct connection IP.
- **Do NOT apply the same limit to all endpoints.** Login should be 5/min. Product listing should be 1000/min. A single global limit is either too strict for reads or too loose for sensitive operations.
- **Do NOT forget quotas.** Rate limits prevent bursts, but a client making 99 req/min for 24 hours consumes 142,560 requests. Daily and monthly quotas catch sustained abuse.

## Output Format

```
RATE LIMIT STRATEGY COMPLETE:
  Algorithm: <sliding window counter | token bucket | leaky bucket>
  Storage: <Redis | Memcached | in-memory | API gateway>
  Tiers: <N> tiers configured (anonymous → enterprise)
  Endpoint overrides: <N> endpoints with specific limits
  Quotas: daily <on|off>, monthly <on|off>
  Headers: RateLimit-Limit, RateLimit-Remaining, RateLimit-Reset, Retry-After
  Degradation: <fail-open | fail-open + local fallback>
  Internal bypass: <mTLS | token | IP allowlist | none>
  Monitoring: <metrics + dashboard | metrics only | none>

TIER SUMMARY:
+--------------------------------------------------------------+
|  Tier          | Rate (req/min) | Burst | Daily Quota | Bypass |
+--------------------------------------------------------------+
|  Anonymous     | 20             | 5     | 1,000       | no     |
|  Free          | 60             | 15    | 10,000      | no     |
|  Pro           | 1,000          | 200   | 1,000,000   | no     |
|  Internal      | unlimited      | --    | --          | yes    |
+--------------------------------------------------------------+
```

## TSV Logging

Log every rate limiting session to `.godmode/ratelimit-results.tsv`:

```
Fields: timestamp\tproject\talgorithm\tstorage\ttiers_count\tendpoint_overrides\tquota_tracking\tdegradation\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-api\tsliding-window\tredis\t4\t8\tdaily+monthly\tfail-open\tabc1234
```

Append after every completed rate limiting design pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
RATE LIMIT SUCCESS CRITERIA:
+--------------------------------------------------------------+
|  Criterion                                  | Required         |
+--------------------------------------------------------------+
|  All public endpoints have rate limits      | YES              |
|  Auth endpoints have strict limits (<=5/min)| YES              |
|  Rate limit headers on every response       | YES              |
|  429 response includes Retry-After          | YES              |
|  429 response body has structured error     | YES              |
|  Atomic operations (Lua script or equiv)    | YES              |
|  Fail-open on Redis/store failure           | YES              |
|  Tiered limits by user class                | YES              |
|  API key quotas tracked (daily/monthly)     | YES              |
|  Internal services can bypass limits        | YES              |
|  Rate limit metrics exported                | YES              |
|  Monitoring dashboard configured            | RECOMMENDED      |
+--------------------------------------------------------------+

VERDICT: ALL required criteria must PASS. Any FAIL → fix before commit.
```

## Error Recovery

```
ERROR RECOVERY — RATE LIMITING:
1. Redis unavailable (rate limiter backend down):
   → Fail open immediately (allow all requests). Log the failure. Fall back to in-memory per-instance limiter if configured. Alert ops team. Never block traffic because the limiter is down.
2. Clients bypassing rate limits (exceeding configured limits):
   → Check for non-atomic check-and-increment (race condition). Verify Lua script is used. Check for API key rotation abuse (add IP-based secondary limit). Verify X-Forwarded-For is trusted only from known proxies.
3. 429 responses missing Retry-After header:
   → Add Retry-After to the rate-limited response handler. Calculate from reset_at timestamp. Clients cannot self-throttle without this header.
4. Rate limit too strict (legitimate users blocked):
   → Check tier configuration. Verify user is in correct tier. Analyze traffic patterns (burst vs sustained). Increase burst allowance or upgrade the tier limit.
5. Rate limit too loose (abuse not caught):
   → Add endpoint-specific overrides for sensitive endpoints. Tighten anonymous tier. Add IP-based rate limit as secondary check. Monitor rejection rate (if 0%, limits are too loose).
6. Lua script errors in Redis:
   → Check Redis version compatibility. Verify script SHA matches loaded script. Re-load script on NOSCRIPT error. Log full error for debugging.
```

## Explicit Loop Protocol

```
RATE LIMIT ENDPOINT LOOP:
current_iteration = 0
endpoints = detect_public_endpoints()  // e.g., [/auth/login, /api/products, /api/search, ...]

WHILE current_iteration < len(endpoints) AND NOT user_says_stop:
  endpoint = endpoints[current_iteration]
  current_iteration += 1

  1. Classify endpoint: auth | read | write | expensive | internal
  2. Set rate limit based on classification and tier
  3. Configure endpoint-specific override if needed (auth: 5/min, upload: 10/hr)
  4. Add rate limit middleware/decorator to endpoint
  5. Verify rate limit headers appear in response
  6. Test 429 response with Retry-After header
  7. REPORT: "Endpoint {current_iteration}/{total}: {path} — {limit}/min, tier-based: {yes|no}, override: {yes|no}"

ON COMPLETION:
  Configure Redis Lua script for atomic enforcement
  Set up fail-open degradation
  Configure monitoring (rejection rate, latency)
  REPORT: "{N} endpoints protected, {M} tiers, {K} overrides, degradation: fail-open"
```

## Multi-Agent Dispatch

```
PARALLEL RATE LIMIT AGENTS:
When implementing rate limiting across a large API surface:

Agent 1 (worktree: ratelimit-core):
  - Implement Redis Lua script (sliding window counter)
  - Create rate limit middleware with tier resolution
  - Configure fail-open degradation with local fallback
  - Add rate limit response headers to all endpoints

Agent 2 (worktree: ratelimit-tiers):
  - Design tier configuration (anonymous, free, pro, enterprise)
  - Implement endpoint-specific overrides for sensitive endpoints
  - Build API key quota tracking (daily + monthly)
  - Configure quota warning notifications (75%, 90%, 100%)

Agent 3 (worktree: ratelimit-monitoring):
  - Add Prometheus/StatsD metrics (requests, rejections, latency)
  - Create monitoring dashboard (rejection rate, top limited clients)
  - Configure alerts (Redis down, high rejection rate, quota exceeded)
  - Write rate limit integration tests (under concurrency)

MERGE: Core merges first. Tiers rebase onto core.
  Monitoring rebases onto tiers. Final: load test under concurrency.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run rate limiting tasks sequentially: core middleware, then tier configuration, then monitoring.
- Use branch isolation per task: `git checkout -b godmode-ratelimit-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
