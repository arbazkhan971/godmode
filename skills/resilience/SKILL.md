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
┌──────────────────────────────────────────────────────────────┐
│  Pattern            │ Status    │ Coverage │ Implementation   │
│  ─────────────────────────────────────────────────────────── │
│  Circuit Breakers   │ NONE      │ 0%       │ —                │
│  Retries            │ BASIC     │ 30%      │ Simple retry x3  │
│  Timeouts           │ PARTIAL   │ 50%      │ HTTP only        │
│  Bulkheads          │ NONE      │ 0%       │ —                │
│  Rate Limiting      │ BASIC     │ 40%      │ Global only      │
│  Health Checks      │ MINIMAL   │ 20%      │ /health only     │
│  Graceful Degrade   │ NONE      │ 0%       │ —                │
│  Fallbacks          │ NONE      │ 0%       │ —                │
│  Load Shedding      │ NONE      │ 0%       │ —                │
├──────────────────────────────────────────────────────────────┤
│  Overall Score: 2/10 — FRAGILE                               │
│  Priority: Circuit breakers + timeouts for external deps     │
└──────────────────────────────────────────────────────────────┘

Dependency map:
  Service A → [Database, Cache, Service B, Payment API, Email API]
  Critical path: Service A → Database, Service A → Payment API
  Degradable: Email API (queue and retry), Cache (fall through to DB)
```

### Step 2: Circuit Breaker Pattern
Implement circuit breakers for all external dependencies:

#### Circuit Breaker State Machine
```
CIRCUIT BREAKER STATE MACHINE:

     ┌─────────┐   failure threshold   ┌──────┐
     │ CLOSED  │ ───────────────────→  │ OPEN │
     │ (normal)│                        │(fail)│
     └────┬────┘                        └──┬───┘
          ↑                                │
          │    success threshold           │ timeout expires
          │                                ↓
          │                          ┌──────────┐
          └───────────────────────── │ HALF-OPEN│
                                     │ (testing) │
                                     └───────────┘

States:
  CLOSED   — Requests pass through. Failures counted. Normal operation.
  OPEN     — Requests fail immediately. No load on dependency. Fast failure.
  HALF-OPEN— Limited requests pass through to test if dependency recovered.

Transitions:
  CLOSED → OPEN:      failure_count >= threshold within window
  OPEN → HALF-OPEN:   timeout_duration elapsed
  HALF-OPEN → CLOSED: success_count >= threshold (recovery confirmed)
  HALF-OPEN → OPEN:   any failure (dependency still unhealthy)
```

#### Circuit Breaker Configuration
```
CIRCUIT BREAKER CONFIG:
Dependency: <service name>
Failure threshold: <N failures> in <window> (e.g., 5 in 30s)
Success threshold: <N successes> in half-open (e.g., 3)
Timeout duration: <time before retry> (e.g., 60s)
Half-open max requests: <N> (e.g., 3)
Monitored exceptions: [ConnectionTimeout, ServiceUnavailable, TooManyRequests]
Ignored exceptions: [BadRequest, NotFound, ValidationError]
Fallback: <fallback strategy>
```

#### Implementation — Node.js (opossum)
```javascript
const CircuitBreaker = require('opossum');

// Define the function to protect
async function callPaymentAPI(orderId, amount) {
  const response = await fetch('https://api.payment.com/charge', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ orderId, amount }),
    signal: AbortSignal.timeout(5000), // hard timeout
  });
  if (!response.ok) throw new Error(`Payment failed: ${response.status}`);
  return response.json();
}

// Wrap with circuit breaker
const paymentBreaker = new CircuitBreaker(callPaymentAPI, {
  timeout: 5000,           // 5s — if function takes longer, count as failure
  errorThresholdPercentage: 50,  // open after 50% failure rate
  resetTimeout: 30000,     // 30s — try again after this long
  rollingCountTimeout: 10000,    // 10s — failure counting window
  rollingCountBuckets: 10,       // granularity of rolling window
  volumeThreshold: 5,      // minimum calls before breaker can trip
});

// Fallback when circuit is open
paymentBreaker.fallback((orderId, amount) => {
  // Queue for later processing
  return { status: 'queued', message: 'Payment will be processed shortly' };
});

// Events for monitoring
paymentBreaker.on('open', () => {
  metrics.increment('circuit_breaker.payment.opened');
  logger.warn('Payment circuit breaker OPENED — falling back to queue');
});

paymentBreaker.on('halfOpen', () => {
  logger.info('Payment circuit breaker HALF-OPEN — testing recovery');
});

paymentBreaker.on('close', () => {
  metrics.increment('circuit_breaker.payment.closed');
  logger.info('Payment circuit breaker CLOSED — recovered');
});

// Usage
async function processOrder(order) {
  const result = await paymentBreaker.fire(order.id, order.amount);
  return result;
}
```

#### Implementation — Go (sony/gobreaker)
```go
package resilience

import (
    "fmt"
    "net/http"
    "time"

    "github.com/sony/gobreaker"
)

func NewPaymentBreaker() *gobreaker.CircuitBreaker {
    settings := gobreaker.Settings{
        Name:        "payment-api",
        MaxRequests: 3,              // max requests in half-open
        Interval:    10 * time.Second, // rolling window
        Timeout:     30 * time.Second, // time in open before half-open
        ReadyToTrip: func(counts gobreaker.Counts) bool {
            failureRatio := float64(counts.TotalFailures) / float64(counts.Requests)
            return counts.Requests >= 5 && failureRatio >= 0.5
        },
        OnStateChange: func(name string, from, to gobreaker.State) {
            log.Printf("Circuit breaker %s: %s → %s", name, from, to)
            metrics.Gauge("circuit_breaker.state", float64(to),
                "breaker:"+name)
        },
    }
    return gobreaker.NewCircuitBreaker(settings)
}

func ChargePayment(cb *gobreaker.CircuitBreaker, orderID string, amount float64) (interface{}, error) {
    result, err := cb.Execute(func() (interface{}, error) {
        client := &http.Client{Timeout: 5 * time.Second}
        resp, err := client.Post(
            "https://api.payment.com/charge",
            "application/json",
            buildPayload(orderID, amount),
        )
        if err != nil {
            return nil, err
        }
        defer resp.Body.Close()

        if resp.StatusCode >= 500 {
            return nil, fmt.Errorf("payment service error: %d", resp.StatusCode)
        }
        return parseResponse(resp)
    })

    if err != nil {
        // Circuit is open — use fallback
        if err == gobreaker.ErrOpenState || err == gobreaker.ErrTooManyRequests {
            return queueForLaterProcessing(orderID, amount)
        }
        return nil, err
    }
    return result, nil
}
```

#### Implementation — Python (pybreaker)
```python
import pybreaker
import requests
import logging

logger = logging.getLogger(__name__)

# Define listeners for monitoring
class PaymentBreakerListener(pybreaker.CircuitBreakerListener):
    def state_change(self, cb, old_state, new_state):
        logger.warning(f"Circuit breaker '{cb.name}': {old_state.name} → {new_state.name}")
        metrics.gauge("circuit_breaker.state", new_state.value, tags={"breaker": cb.name})

    def failure(self, cb, exc):
        logger.error(f"Circuit breaker '{cb.name}' recorded failure: {exc}")

    def success(self, cb):
        logger.debug(f"Circuit breaker '{cb.name}' recorded success")

# Create the breaker
payment_breaker = pybreaker.CircuitBreaker(
    fail_max=5,                    # open after 5 failures
    reset_timeout=30,              # try again after 30s
    exclude=[ValueError,           # don't count client errors
             requests.exceptions.HTTPError],
    listeners=[PaymentBreakerListener()],
    name="payment-api",
)

@payment_breaker
def charge_payment(order_id: str, amount: float) -> dict:
    response = requests.post(
        "https://api.payment.com/charge",
        json={"order_id": order_id, "amount": amount},
        timeout=5,
    )
    response.raise_for_status()
    return response.json()

def process_order(order):
    try:
        return charge_payment(order.id, order.amount)
    except pybreaker.CircuitBreakerError:
        logger.warning("Payment circuit open — queueing for later")
        return queue_for_later(order.id, order.amount)
```

### Step 3: Retry Strategies
Design retry policies with exponential backoff and jitter:

#### Retry Strategy Decision Matrix
```
RETRY DECISION MATRIX:
┌──────────────────────────────────────────────────────────────┐
│  Error Type           │ Retry? │ Strategy    │ Max Attempts  │
│  ─────────────────────────────────────────────────────────── │
│  Connection refused   │ YES    │ Exp backoff │ 3             │
│  Connection timeout   │ YES    │ Exp backoff │ 3             │
│  HTTP 429 (rate limit)│ YES    │ Respect     │ 3             │
│                       │        │ Retry-After │               │
│  HTTP 500             │ YES    │ Exp backoff │ 3             │
│  HTTP 502/503/504     │ YES    │ Exp backoff │ 3             │
│  HTTP 400             │ NO     │ —           │ —             │
│  HTTP 401/403         │ NO*    │ Refresh tok │ 1             │
│  HTTP 404             │ NO     │ —           │ —             │
│  HTTP 409 (conflict)  │ MAYBE  │ Read-modify │ 2             │
│                       │        │ -write      │               │
│  DNS resolution fail  │ YES    │ Exp backoff │ 3             │
│  TLS handshake fail   │ YES    │ Exp backoff │ 2             │
│  Request body too big │ NO     │ —           │ —             │
│  Deserialization err  │ NO     │ —           │ —             │
│  Business logic error │ NO     │ —           │ —             │
└──────────────────────────────────────────────────────────────┘
```

#### Exponential Backoff with Jitter
```
BACKOFF FORMULA:

Base delay:    base_ms (e.g., 100ms)
Max delay:     max_ms (e.g., 30000ms)
Attempt:       n (0-indexed)

Strategies:
  Full jitter (recommended):
    delay = random(0, min(max_ms, base_ms * 2^n))

  Equal jitter:
    temp = min(max_ms, base_ms * 2^n)
    delay = temp/2 + random(0, temp/2)

  Decorrelated jitter:
    delay = min(max_ms, random(base_ms, prev_delay * 3))

  No jitter (dangerous — thundering herd):
    delay = min(max_ms, base_ms * 2^n)

Example (full jitter, base=100ms):
  Attempt 0: random(0, 100ms)    → e.g., 67ms
  Attempt 1: random(0, 200ms)    → e.g., 143ms
  Attempt 2: random(0, 400ms)    → e.g., 289ms
  Attempt 3: random(0, 800ms)    → e.g., 612ms
  Attempt 4: random(0, 1600ms)   → e.g., 1104ms

Why jitter matters:
  Without jitter, all clients retry at the same time after a failure,
  creating a "thundering herd" that re-overloads the recovering service.
  Jitter spreads retries across time, giving the service room to recover.
```

#### Implementation — Node.js
```javascript
class RetryPolicy {
  constructor(options = {}) {
    this.maxAttempts = options.maxAttempts || 3;
    this.baseDelay = options.baseDelay || 100;
    this.maxDelay = options.maxDelay || 30000;
    this.jitterStrategy = options.jitter || 'full'; // full | equal | decorrelated
    this.retryableErrors = options.retryableErrors || [
      'ECONNREFUSED', 'ECONNRESET', 'ETIMEDOUT', 'EPIPE',
    ];
    this.retryableStatuses = options.retryableStatuses || [429, 500, 502, 503, 504];
    this.onRetry = options.onRetry || (() => {});
  }

  calculateDelay(attempt, previousDelay) {
    switch (this.jitterStrategy) {
      case 'full':
        return Math.random() * Math.min(this.maxDelay, this.baseDelay * 2 ** attempt);

      case 'equal': {
        const temp = Math.min(this.maxDelay, this.baseDelay * 2 ** attempt);
        return temp / 2 + Math.random() * (temp / 2);
      }

      case 'decorrelated':
        return Math.min(
          this.maxDelay,
          this.baseDelay + Math.random() * ((previousDelay || this.baseDelay) * 3 - this.baseDelay)
        );

      default:
        return Math.min(this.maxDelay, this.baseDelay * 2 ** attempt);
    }
  }

  isRetryable(error) {
    if (error.code && this.retryableErrors.includes(error.code)) return true;
    if (error.status && this.retryableStatuses.includes(error.status)) return true;
    if (error.response?.status && this.retryableStatuses.includes(error.response.status)) return true;
    return false;
  }

  async execute(fn) {
    let lastError;
    let previousDelay = this.baseDelay;

    for (let attempt = 0; attempt <= this.maxAttempts; attempt++) {
      try {
        return await fn(attempt);
      } catch (error) {
        lastError = error;

        if (attempt >= this.maxAttempts || !this.isRetryable(error)) {
          throw error;
        }

        // Respect Retry-After header for 429s
        let delay;
        const retryAfter = error.response?.headers?.['retry-after'];
        if (retryAfter) {
          delay = isNaN(retryAfter)
            ? new Date(retryAfter).getTime() - Date.now()
            : parseInt(retryAfter, 10) * 1000;
        } else {
          delay = this.calculateDelay(attempt, previousDelay);
        }

        previousDelay = delay;
        this.onRetry({ attempt, delay, error });

        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    throw lastError;
  }
}

// Usage
const retrier = new RetryPolicy({
  maxAttempts: 3,
  baseDelay: 100,
  maxDelay: 10000,
  jitter: 'full',
  onRetry: ({ attempt, delay, error }) => {
    logger.warn(`Retry ${attempt + 1}`, { delay, error: error.message });
    metrics.increment('http.retries', { reason: error.code || error.status });
  },
});

const result = await retrier.execute(async (attempt) => {
  return fetch('https://api.service.com/data', {
    headers: { 'X-Retry-Attempt': String(attempt) },
  });
});
```

#### Implementation — Go
```go
package resilience

import (
    "context"
    "math"
    "math/rand"
    "net/http"
    "strconv"
    "time"
)

type RetryPolicy struct {
    MaxAttempts  int
    BaseDelay    time.Duration
    MaxDelay     time.Duration
    RetryableFn  func(error, *http.Response) bool
    OnRetry      func(attempt int, delay time.Duration, err error)
}

func DefaultRetryPolicy() *RetryPolicy {
    return &RetryPolicy{
        MaxAttempts: 3,
        BaseDelay:   100 * time.Millisecond,
        MaxDelay:    30 * time.Second,
        RetryableFn: func(err error, resp *http.Response) bool {
            if err != nil {
                return true // network errors are retryable
            }
            if resp != nil {
                switch resp.StatusCode {
                case 429, 500, 502, 503, 504:
                    return true
                }
            }
            return false
        },
    }
}

func (rp *RetryPolicy) fullJitterDelay(attempt int) time.Duration {
    maxDelay := float64(rp.BaseDelay) * math.Pow(2, float64(attempt))
    if maxDelay > float64(rp.MaxDelay) {
        maxDelay = float64(rp.MaxDelay)
    }
    return time.Duration(rand.Float64() * maxDelay)
}

func (rp *RetryPolicy) Execute(ctx context.Context, fn func() (*http.Response, error)) (*http.Response, error) {
    var lastErr error
    var lastResp *http.Response

    for attempt := 0; attempt <= rp.MaxAttempts; attempt++ {
        resp, err := fn()
        if err == nil && resp.StatusCode < 500 && resp.StatusCode != 429 {
            return resp, nil
        }

        lastErr = err
        lastResp = resp

        if attempt >= rp.MaxAttempts || !rp.RetryableFn(err, resp) {
            if err != nil {
                return nil, err
            }
            return resp, nil
        }

        // Respect Retry-After header
        delay := rp.fullJitterDelay(attempt)
        if resp != nil {
            if ra := resp.Header.Get("Retry-After"); ra != "" {
                if seconds, parseErr := strconv.Atoi(ra); parseErr == nil {
                    delay = time.Duration(seconds) * time.Second
                }
            }
        }

        if rp.OnRetry != nil {
            rp.OnRetry(attempt, delay, err)
        }

        select {
        case <-ctx.Done():
            return nil, ctx.Err()
        case <-time.After(delay):
        }
    }

    if lastErr != nil {
        return nil, lastErr
    }
    return lastResp, nil
}
```

### Step 4: Bulkhead Pattern
Isolate failure domains so one failing dependency does not consume all resources:

#### Bulkhead Design
```
BULKHEAD PATTERN:

Purpose: Prevent a single slow/failing dependency from exhausting the
entire application's thread pool, connection pool, or memory.

Analogy: Ship bulkheads. If one compartment floods, the others stay dry.

Types:
  Thread pool bulkhead: Separate thread/worker pools per dependency
  Semaphore bulkhead: Limit concurrent requests per dependency
  Connection pool bulkhead: Separate connection pools per service

┌────────────────────────────────────────────────┐
│                  Application                    │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Pool: 10 │  │ Pool: 20 │  │ Pool: 5  │     │
│  │ Payment  │  │ Database │  │ Email    │     │
│  │ API      │  │          │  │ Service  │     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       │              │              │            │
└───────┼──────────────┼──────────────┼────────────┘
        ↓              ↓              ↓
   Payment API    PostgreSQL     Email SaaS

If Payment API hangs:
  - Only 10 threads blocked (not all 50)
  - Database queries and email sends continue normally
  - Application remains partially functional
```

#### Implementation — Node.js (Semaphore Bulkhead)
```javascript
class Bulkhead {
  constructor(name, maxConcurrent, maxQueue = 0) {
    this.name = name;
    this.maxConcurrent = maxConcurrent;
    this.maxQueue = maxQueue;
    this.active = 0;
    this.queue = [];
  }

  async execute(fn) {
    if (this.active >= this.maxConcurrent) {
      if (this.queue.length >= this.maxQueue) {
        metrics.increment('bulkhead.rejected', { name: this.name });
        throw new BulkheadRejectedError(
          `Bulkhead '${this.name}' full: ${this.active} active, ${this.queue.length} queued`
        );
      }

      // Wait in queue
      await new Promise((resolve, reject) => {
        const timeout = setTimeout(() => {
          const idx = this.queue.indexOf(entry);
          if (idx !== -1) this.queue.splice(idx, 1);
          reject(new BulkheadTimeoutError(`Bulkhead '${this.name}' queue timeout`));
        }, 30000);

        const entry = { resolve, reject, timeout };
        this.queue.push(entry);
      });
    }

    this.active++;
    metrics.gauge('bulkhead.active', this.active, { name: this.name });

    try {
      return await fn();
    } finally {
      this.active--;
      metrics.gauge('bulkhead.active', this.active, { name: this.name });

      if (this.queue.length > 0) {
        const next = this.queue.shift();
        clearTimeout(next.timeout);
        next.resolve();
      }
    }
  }
}

// Usage: separate bulkheads per dependency
const paymentBulkhead = new Bulkhead('payment', 10, 20);
const databaseBulkhead = new Bulkhead('database', 20, 50);
const emailBulkhead = new Bulkhead('email', 5, 100);

async function chargePayment(order) {
  return paymentBulkhead.execute(() => paymentAPI.charge(order));
}

async function queryUsers(filter) {
  return databaseBulkhead.execute(() => db.users.find(filter));
}
```

### Step 5: Rate Limiting
Protect services from being overwhelmed by too many requests:

#### Rate Limiting Strategies
```
RATE LIMITING STRATEGIES:
┌──────────────────────────────────────────────────────────────┐
│  Algorithm       │ Behavior           │ Best For              │
│  ─────────────────────────────────────────────────────────── │
│  Fixed window    │ N reqs per window  │ Simple quotas         │
│  Sliding window  │ Smoothed rate      │ Even distribution     │
│  Token bucket    │ Burst + sustained  │ APIs with burst needs │
│  Leaky bucket    │ Constant rate      │ Predictable throughput│
│  Concurrency     │ N simultaneous     │ Resource protection   │
└──────────────────────────────────────────────────────────────┘

Rate limit dimensions:
  - Per user/API key: prevent single user from monopolizing
  - Per IP: prevent DDoS and scraping
  - Per endpoint: protect expensive operations
  - Global: protect overall system capacity
  - Per tenant (multi-tenant): isolation between customers
```

#### Token Bucket Implementation — Node.js
```javascript
class TokenBucket {
  constructor(options) {
    this.capacity = options.capacity;        // max tokens (burst size)
    this.refillRate = options.refillRate;     // tokens per second
    this.tokens = options.capacity;           // start full
    this.lastRefill = Date.now();
  }

  tryConsume(tokens = 1) {
    this.refill();

    if (this.tokens >= tokens) {
      this.tokens -= tokens;
      return {
        allowed: true,
        remaining: Math.floor(this.tokens),
        retryAfter: null,
      };
    }

    const deficit = tokens - this.tokens;
    const retryAfter = Math.ceil(deficit / this.refillRate);

    return {
      allowed: false,
      remaining: 0,
      retryAfter,
    };
  }

  refill() {
    const now = Date.now();
    const elapsed = (now - this.lastRefill) / 1000;
    this.tokens = Math.min(this.capacity, this.tokens + elapsed * this.refillRate);
    this.lastRefill = now;
  }
}

// Distributed rate limiting with Redis
class RedisRateLimiter {
  constructor(redis, options) {
    this.redis = redis;
    this.windowMs = options.windowMs || 60000;
    this.maxRequests = options.maxRequests || 100;
    this.keyPrefix = options.keyPrefix || 'ratelimit';
  }

  async check(identifier) {
    const key = `${this.keyPrefix}:${identifier}`;
    const now = Date.now();
    const windowStart = now - this.windowMs;

    // Sliding window using sorted set
    const pipeline = this.redis.pipeline();
    pipeline.zremrangebyscore(key, 0, windowStart);  // remove old entries
    pipeline.zadd(key, now, `${now}:${Math.random()}`);  // add current
    pipeline.zcard(key);  // count in window
    pipeline.pexpire(key, this.windowMs);  // auto-cleanup

    const results = await pipeline.exec();
    const count = results[2][1];

    return {
      allowed: count <= this.maxRequests,
      remaining: Math.max(0, this.maxRequests - count),
      retryAfter: count > this.maxRequests
        ? Math.ceil(this.windowMs / 1000)
        : null,
      limit: this.maxRequests,
    };
  }
}

// Express middleware
function rateLimitMiddleware(limiter) {
  return async (req, res, next) => {
    const identifier = req.user?.id || req.ip;
    const result = await limiter.check(identifier);

    res.set('X-RateLimit-Limit', result.limit);
    res.set('X-RateLimit-Remaining', result.remaining);

    if (!result.allowed) {
      res.set('Retry-After', result.retryAfter);
      return res.status(429).json({
        error: 'rate_limit_exceeded',
        message: 'Too many requests',
        retryAfter: result.retryAfter,
      });
    }

    next();
  };
}
```

### Step 6: Graceful Degradation
Design fallback behavior when dependencies are unavailable:

#### Degradation Strategy Matrix
```
GRACEFUL DEGRADATION MATRIX:
┌──────────────────────────────────────────────────────────────┐
│  Dependency        │ Degradation Strategy │ User Experience   │
│  ─────────────────────────────────────────────────────────── │
│  Search service    │ Fallback to DB query │ Slower, less      │
│                    │ (simpler results)    │ relevant results  │
│  Recommendation    │ Show popular items   │ Generic but       │
│  engine            │ (cached list)        │ functional        │
│  Payment gateway   │ Queue and retry      │ "Processing..."   │
│                    │ asynchronously       │ confirmation later│
│  Email service     │ Queue to dead letter │ Delayed emails    │
│                    │ for later delivery   │                   │
│  Cache (Redis)     │ Fall through to DB   │ Higher latency    │
│  CDN               │ Serve from origin    │ Slower assets     │
│  Analytics         │ Drop events silently │ No user impact    │
│  Feature flags     │ Use cached/default   │ Stale flags       │
│  Auth provider     │ Use cached tokens    │ New logins blocked│
│  Image processing  │ Serve original       │ No thumbnails     │
└──────────────────────────────────────────────────────────────┘

Degradation levels:
  LEVEL 0 — Full functionality (all services healthy)
  LEVEL 1 — Non-critical features disabled (analytics, recommendations)
  LEVEL 2 — Degraded experience (cached data, slower responses)
  LEVEL 3 — Core functionality only (read-only mode, basic features)
  LEVEL 4 — Maintenance mode (static page with status)
```

#### Implementation — Feature Degradation
```javascript
class DegradationManager {
  constructor() {
    this.levels = {
      analytics: { level: 0, fallback: () => {} },  // silent drop
      recommendations: { level: 1, fallback: () => this.getPopularItems() },
      search: { level: 1, fallback: (q) => this.basicSearch(q) },
      notifications: { level: 1, fallback: (msg) => this.queueNotification(msg) },
      imageProcessing: { level: 2, fallback: (url) => url },  // return original
      payments: { level: 2, fallback: (order) => this.queuePayment(order) },
      auth: { level: 3, fallback: () => this.cachedAuth() },
    };
    this.currentLevel = 0;
  }

  async withDegradation(feature, primaryFn, ...args) {
    const config = this.levels[feature];
    if (!config) return primaryFn(...args);

    try {
      return await primaryFn(...args);
    } catch (error) {
      if (this.isTransient(error)) {
        logger.warn(`Degrading ${feature}`, { error: error.message });
        metrics.increment('degradation.activated', { feature });
        return config.fallback(...args);
      }
      throw error;  // non-transient errors propagate
    }
  }

  setLevel(level) {
    this.currentLevel = level;
    logger.warn(`Degradation level changed to ${level}`);
    metrics.gauge('degradation.level', level);
  }

  isFeatureAvailable(feature) {
    const config = this.levels[feature];
    return config ? config.level <= this.currentLevel : true;
  }
}

// Usage
const degradation = new DegradationManager();

app.get('/products', async (req, res) => {
  const products = await db.products.list(req.query);

  // Recommendations degrade gracefully
  const recs = await degradation.withDegradation(
    'recommendations',
    () => recommendationService.getForUser(req.user.id)
  );

  // Search degrades to basic DB query
  const searchResults = req.query.q
    ? await degradation.withDegradation(
        'search',
        () => searchService.query(req.query.q),
        req.query.q
      )
    : null;

  res.json({ products, recommendations: recs, search: searchResults });
});
```

### Step 7: Health Check Implementation
Design comprehensive health checks for container orchestration:

#### Health Check Types
```
HEALTH CHECK TYPES:
┌──────────────────────────────────────────────────────────────┐
│  Type        │ Purpose                │ Failure Action        │
│  ─────────────────────────────────────────────────────────── │
│  Liveness    │ Is the process alive?  │ Kill and restart pod  │
│              │ (not deadlocked)       │                       │
│  Readiness   │ Can it serve traffic?  │ Remove from load      │
│              │ (dependencies ready)   │ balancer              │
│  Startup     │ Has it finished        │ Wait longer before    │
│              │ initializing?          │ liveness/readiness    │
└──────────────────────────────────────────────────────────────┘

CRITICAL RULES:
  1. Liveness probes must be CHEAP and FAST (no dependency checks!)
     A database outage should NOT cause your pod to restart.
  2. Readiness probes check dependencies (DB, cache, downstream services)
     A database outage SHOULD remove the pod from the load balancer.
  3. Startup probes prevent premature liveness checks during init
     Migrations, cache warming, and connection setup take time.
  4. Never share logic between liveness and readiness probes.
```

#### Implementation — Express.js
```javascript
const express = require('express');

class HealthChecker {
  constructor() {
    this.startupComplete = false;
    this.checks = new Map();
  }

  registerCheck(name, checkFn, options = {}) {
    this.checks.set(name, {
      fn: checkFn,
      critical: options.critical !== false,  // critical by default
      timeout: options.timeout || 5000,
      cached: null,
      cacheExpiry: 0,
      cacheTTL: options.cacheTTL || 10000,  // cache for 10s
    });
  }

  // LIVENESS: Is the process alive and not deadlocked?
  // NEVER check external dependencies here
  livenessHandler() {
    return (req, res) => {
      // Check if event loop is responsive
      const start = process.hrtime.bigint();
      setImmediate(() => {
        const elapsed = Number(process.hrtime.bigint() - start) / 1e6;
        if (elapsed > 1000) {
          // Event loop blocked for > 1s — likely deadlocked
          return res.status(503).json({
            status: 'fail',
            reason: 'event_loop_blocked',
            latency_ms: elapsed,
          });
        }
        res.json({ status: 'ok', uptime: process.uptime() });
      });
    };
  }

  // READINESS: Can this instance handle traffic?
  readinessHandler() {
    return async (req, res) => {
      if (!this.startupComplete) {
        return res.status(503).json({ status: 'not_ready', reason: 'startup_incomplete' });
      }

      const results = {};
      let healthy = true;

      for (const [name, check] of this.checks) {
        const now = Date.now();

        // Return cached result if fresh
        if (check.cached && now < check.cacheExpiry) {
          results[name] = check.cached;
          if (!check.cached.ok && check.critical) healthy = false;
          continue;
        }

        try {
          const checkPromise = check.fn();
          const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('timeout')), check.timeout)
          );
          await Promise.race([checkPromise, timeoutPromise]);

          check.cached = { ok: true, latency_ms: Date.now() - now };
        } catch (error) {
          check.cached = { ok: false, error: error.message, latency_ms: Date.now() - now };
          if (check.critical) healthy = false;
        }

        check.cacheExpiry = now + check.cacheTTL;
        results[name] = check.cached;
      }

      res.status(healthy ? 200 : 503).json({
        status: healthy ? 'ready' : 'not_ready',
        checks: results,
      });
    };
  }

  // STARTUP: Has initialization completed?
  startupHandler() {
    return (req, res) => {
      if (this.startupComplete) {
        return res.json({ status: 'started' });
      }
      res.status(503).json({ status: 'starting' });
    };
  }

  markStartupComplete() {
    this.startupComplete = true;
    logger.info('Startup complete — readiness checks now active');
  }
}

// Setup
const health = new HealthChecker();

health.registerCheck('database', async () => {
  await db.query('SELECT 1');
}, { critical: true, timeout: 3000 });

health.registerCheck('redis', async () => {
  await redis.ping();
}, { critical: true, timeout: 2000 });

health.registerCheck('payment-api', async () => {
  const resp = await fetch('https://api.payment.com/health', {
    signal: AbortSignal.timeout(3000),
  });
  if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
}, { critical: false, timeout: 5000 });  // non-critical

app.get('/health/live', health.livenessHandler());
app.get('/health/ready', health.readinessHandler());
app.get('/health/startup', health.startupHandler());

// During startup
async function initialize() {
  await runMigrations();
  await warmCaches();
  await connectToServices();
  health.markStartupComplete();
}
```

#### Kubernetes Probe Configuration
```yaml
# Kubernetes health probe configuration
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
spec:
  template:
    spec:
      containers:
        - name: my-service
          ports:
            - containerPort: 3000

          # Startup probe: wait for initialization (migrations, cache warming)
          startupProbe:
            httpGet:
              path: /health/startup
              port: 3000
            failureThreshold: 30     # 30 * 10s = 5 minutes max startup
            periodSeconds: 10

          # Liveness probe: is the process alive?
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 0   # startup probe handles delay
            periodSeconds: 10
            timeoutSeconds: 3
            failureThreshold: 3      # 3 consecutive failures → restart

          # Readiness probe: can it serve traffic?
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            periodSeconds: 5
            timeoutSeconds: 5
            failureThreshold: 2      # 2 failures → remove from LB
            successThreshold: 1      # 1 success → add back to LB
```

### Step 8: Timeout Management
Design a comprehensive timeout strategy:

#### Timeout Hierarchy
```
TIMEOUT HIERARCHY:
┌──────────────────────────────────────────────────────────────┐
│  Layer                 │ Timeout  │ Rationale                │
│  ─────────────────────────────────────────────────────────── │
│  Load balancer         │ 60s      │ Longest acceptable wait  │
│  Reverse proxy (nginx) │ 30s      │ Kill before LB timeout   │
│  Application server    │ 25s      │ Kill before proxy timeout│
│  HTTP client (outbound)│ 10s      │ Individual call limit    │
│  Database query        │ 5s       │ Queries shouldn't be slow│
│  Cache (Redis) lookup  │ 500ms    │ Cache misses are fast    │
│  DNS resolution        │ 2s       │ Cached after first call  │
│  Health check          │ 3s       │ Fast or fail             │
└──────────────────────────────────────────────────────────────┘

RULE: Each layer's timeout < parent layer's timeout.
  If DB timeout > HTTP timeout, the DB timeout is meaningless.
  If HTTP client timeout > app server timeout, the app will kill
  the request before the HTTP client gives up.

TIMEOUT BUDGET:
  Total request budget: 25 seconds (application server timeout)
  - Auth check:     500ms (cached token validation)
  - DB query 1:     5s (main data fetch)
  - External API:   10s (enrichment call)
  - DB query 2:     5s (write result)
  - Processing:     4.5s (remaining budget)

  If external API takes 10s, only 10s remains for everything else.
  Budget tracking prevents unbounded request duration.
```

#### Implementation — Timeout Budget
```javascript
class TimeoutBudget {
  constructor(totalMs) {
    this.totalMs = totalMs;
    this.startTime = Date.now();
    this.spent = [];
  }

  remaining() {
    return Math.max(0, this.totalMs - (Date.now() - this.startTime));
  }

  expired() {
    return this.remaining() <= 0;
  }

  // Get a timeout for a sub-operation, respecting the budget
  allocate(maxMs, label) {
    const rem = this.remaining();
    if (rem <= 0) {
      throw new TimeoutBudgetExhaustedError(
        `Timeout budget exhausted (${this.totalMs}ms). ` +
        `Spent: ${this.spent.map(s => `${s.label}=${s.ms}ms`).join(', ')}`
      );
    }
    const allocated = Math.min(maxMs, rem);
    return {
      ms: allocated,
      signal: AbortSignal.timeout(allocated),
      record: () => {
        this.spent.push({ label, ms: Date.now() - this.startTime });
      },
    };
  }
}

// Usage in request handler
app.get('/api/order/:id', async (req, res) => {
  const budget = new TimeoutBudget(25000); // 25s total

  try {
    // Auth: 500ms budget
    const auth = budget.allocate(500, 'auth');
    const user = await verifyToken(req.headers.authorization, { signal: auth.signal });
    auth.record();

    // Database: 5s budget
    const dbTimeout = budget.allocate(5000, 'db-read');
    const order = await db.orders.findById(req.params.id, { timeout: dbTimeout.ms });
    dbTimeout.record();

    // External API: 10s budget
    const apiTimeout = budget.allocate(10000, 'enrichment');
    const enriched = await enrichmentAPI.enrich(order, { signal: apiTimeout.signal });
    apiTimeout.record();

    res.json({ order: enriched, budget_remaining_ms: budget.remaining() });
  } catch (error) {
    if (error instanceof TimeoutBudgetExhaustedError) {
      res.status(504).json({ error: 'request_timeout', message: 'Request took too long' });
    } else {
      throw error;
    }
  }
});
```

### Step 9: Resilience Testing Checklist

```
RESILIENCE VERIFICATION CHECKLIST:
┌──────────────────────────────────────────────────────────────┐
│  Category          │ Test                            │ Pass? │
│  ─────────────────────────────────────────────────────────── │
│  Circuit Breakers  │                                 │       │
│    [ ] Breaker opens after N failures                │       │
│    [ ] Breaker returns fallback when open            │       │
│    [ ] Breaker transitions to half-open after timeout│       │
│    [ ] Breaker closes after successful probe         │       │
│    [ ] Breaker state changes emit metrics            │       │
│  ─────────────────────────────────────────────────────────── │
│  Retries           │                                 │       │
│    [ ] Retries use exponential backoff               │       │
│    [ ] Retries include jitter                        │       │
│    [ ] Retries respect Retry-After headers           │       │
│    [ ] Non-retryable errors fail immediately         │       │
│    [ ] Max retry count is enforced                   │       │
│    [ ] Retry attempts are logged with attempt number │       │
│  ─────────────────────────────────────────────────────────── │
│  Bulkheads         │                                 │       │
│    [ ] Concurrent requests limited per dependency    │       │
│    [ ] Overflow requests are rejected (not queued    │       │
│        indefinitely)                                 │       │
│    [ ] One failing dependency doesn't starve others  │       │
│  ─────────────────────────────────────────────────────────── │
│  Rate Limiting     │                                 │       │
│    [ ] Rate limits enforced per user/API key         │       │
│    [ ] 429 responses include Retry-After header      │       │
│    [ ] Rate limit headers in all responses           │       │
│    [ ] Distributed rate limiting works across nodes  │       │
│  ─────────────────────────────────────────────────────────── │
│  Health Checks     │                                 │       │
│    [ ] Liveness probe does NOT check dependencies    │       │
│    [ ] Readiness probe checks all critical deps      │       │
│    [ ] Startup probe delays liveness checks          │       │
│    [ ] Failed readiness removes pod from LB          │       │
│    [ ] Health checks are fast (< 3s timeout)         │       │
│  ─────────────────────────────────────────────────────────── │
│  Timeouts          │                                 │       │
│    [ ] Every external call has a timeout             │       │
│    [ ] Timeout hierarchy is monotonically decreasing │       │
│    [ ] Timeout budget tracked per request            │       │
│    [ ] Timed-out requests return useful error msgs   │       │
│  ─────────────────────────────────────────────────────────── │
│  Degradation       │                                 │       │
│    [ ] Non-critical features degrade gracefully      │       │
│    [ ] Fallbacks tested and verified                 │       │
│    [ ] Degradation is observable (metrics + logs)    │       │
│    [ ] Recovery from degraded state is automatic     │       │
└──────────────────────────────────────────────────────────────┘
```

## Output
- Resilience design at `docs/resilience/<service>-resilience.md`
- Implementation files in service source directory
- Commit: `"resilience: <service> — <patterns applied> (<coverage>)"`

## Chaining
- **From `/godmode:chaos`:** Chaos tests reveal missing resilience patterns → fix with `/godmode:resilience`
- **From `/godmode:resilience` to `/godmode:observe`:** After adding resilience patterns, add monitoring for circuit breaker states, retry counts, and degradation events
- **From `/godmode:resilience` to `/godmode:loadtest`:** Validate resilience under load
- **From `/godmode:incident`:** Post-mortem reveals resilience gaps → implement with `/godmode:resilience`

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check for HTTP client libraries: axios, got, node-fetch, requests, net/http
2. Detect existing resilience patterns: grep for circuitBreaker, retry, bulkhead, rateLimit
3. Check for resilience libraries: cockatiel, polly, resilience4j, hystrix, gobreaker
4. Detect service mesh: istio, linkerd, envoy configs (may handle retries/circuit breaking)
5. Check for health checks: /health, /ready endpoints, kubernetes probes
6. Detect timeout configuration: grep for timeout, connectTimeout, requestTimeout
7. Scan for fallback patterns: grep for fallback, degraded, cached response
8. Check infrastructure: docker-compose for multiple services, k8s for multi-pod deployments
```

## Iterative Resilience Implementation Loop

```
current_iteration = 0
max_iterations = 12
dependencies = [list of external dependencies/services to protect]

WHILE dependencies is not empty AND current_iteration < max_iterations:
    dep = dependencies.pop(0)
    1. Map the dependency: protocol, expected latency, failure modes, criticality
    2. Choose patterns: circuit breaker (if remote), retry (if idempotent), bulkhead (if shared pool)
    3. Configure timeouts: connect < request < circuit breaker < caller's timeout
    4. Implement circuit breaker with thresholds (5 failures / 60s → open, 30s half-open)
    5. Implement retry with exponential backoff + jitter (max 3 retries)
    6. Add fallback: cached response, default value, or graceful degradation
    7. Add observability: circuit state metric, retry count, fallback activation
    8. Test: simulate dependency failure, verify graceful degradation
    9. IF degradation is not graceful → fix fallback logic
    10. IF passing → commit: "resilience: protect <dep> (circuit breaker + retry + fallback)"
    11. current_iteration += 1

POST-LOOP: Chaos test all dependencies failing simultaneously
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "resilience-patterns": circuit breakers, retries, bulkheads, rate limiters
  Agent 2 — "resilience-fallbacks": fallback handlers, cached responses, degradation logic
  Agent 3 — "resilience-observability": metrics, dashboards, alerts for resilience state

MERGE ORDER: patterns → fallbacks → observability
CONFLICT ZONES: HTTP client wrappers, middleware chains (agree on wrapper API first)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER retry non-idempotent operations. POST that creates a resource = no retry without idempotency key.
2. EVERY retry must use exponential backoff WITH jitter. Linear retry = thundering herd.
3. Timeout hierarchy MUST be monotonically decreasing: caller > gateway > service > dependency.
4. Circuit breaker MUST have half-open state. Open → half-open → test → closed/open.
5. NEVER use the same thread/connection pool for all dependencies. Bulkhead per dependency.
6. EVERY fallback must be tested independently. An untested fallback is no fallback.
7. NEVER catch all exceptions for retry. Only retry transient failures (5xx, timeout, connection reset).
8. Rate limiting MUST return 429 with Retry-After header. Silent dropping is hostile.
9. EVERY resilience pattern must emit metrics. Invisible resilience is untunable resilience.
10. Liveness probes MUST NOT check external dependencies. Liveness = process alive. Readiness = deps available.
```

## Anti-Patterns

```
RESILIENCE ANTI-PATTERNS:
┌──────────────────────────────────────────────────────────────┐
│  Anti-Pattern              │ Why It's Dangerous              │
│  ─────────────────────────────────────────────────────────── │
│  Retry without backoff     │ Thundering herd overwhelms the  │
│                            │ recovering service              │
│  Retry non-idempotent ops  │ Duplicate charges, double posts │
│  Liveness checks deps      │ DB outage restarts all pods,    │
│                            │ making things worse             │
│  No timeout on HTTP calls  │ Thread pool exhaustion, cascade │
│  Same pool for all deps    │ One slow dep starves others     │
│  Retry after circuit open  │ Defeats the purpose of circuit  │
│                            │ breakers                        │
│  Fallback calls same dep   │ Fallback fails the same way     │
│  Infinite retry queue      │ Memory exhaustion during outage │
│  Rate limit without 429    │ Clients can't adapt behavior    │
│  Catch-all exception retry │ Retrying programming errors     │
└──────────────────────────────────────────────────────────────┘
```
