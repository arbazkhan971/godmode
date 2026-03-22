# Resilience Patterns Reference

Comprehensive guide to building fault-tolerant distributed systems with circuit breakers, retry strategies, bulkheads, timeouts, and fallback mechanisms.

---

## Table of Contents

1. [Circuit Breaker](#circuit-breaker)
2. [Retry Patterns](#retry-patterns)
3. [Bulkhead](#bulkhead)
4. [Timeout Patterns](#timeout-patterns)
5. [Fallback Strategies](#fallback-strategies)
6. [Rate Limiting for Resilience](#rate-limiting-for-resilience)
7. [Load Shedding](#load-shedding)
8. [Health Endpoint Monitoring](#health-endpoint-monitoring)
9. [Resilience Testing](#resilience-testing)
10. [Pattern Combinations](#pattern-combinations)

---

## Circuit Breaker

### State Machine

```
         success   │    CLOSED          │   failure_count++
      (reset count)│    (normal flow)   │
            ┌──────│                    │──────┐
|  | failure_count |  |
|  | < threshold |  |
|  | failure_count |
|  | >= threshold |
  ▼
|  | OPEN |  |
|  | (fail fast) |  |
|  | All requests |  |
|  | rejected |  |
|  | immediately |  |
|  | timeout |
|  | expires |
  ▼
            └──────│   HALF-OPEN       │──────┘
  (probe)
  Allow limited
  requests through
  to test recovery
```

### Configuration Parameters

```
  Circuit Breaker Configuration
  CLOSED → OPEN Transition:
  failure_threshold:        5        # failures to trip
  failure_rate_threshold:   50%      # or percentage
  sliding_window_size:      10       # requests to eval
  sliding_window_type:      count    # count | time
  minimum_calls:            5        # min before eval
  slow_call_threshold:      3s       # slow = failure?
  slow_call_rate:           80%      # slow call % limit
  OPEN State:
  wait_duration_in_open:    30s      # before half-open
  fallback:                 cached   # or default/error
  HALF-OPEN State:
  permitted_calls:          3        # probe requests
  success_threshold:        2        # to close again
  failure_threshold:        1        # to re-open
  Monitoring:
  metrics_enabled:          true
  event_consumer:           logger + metrics
```

### Implementation Patterns

#### Count-Based Sliding Window

```
Window size: 5

Requests:  [S] [S] [F] [F] [F]  →  failure_rate = 60%
            ▼   ▼   ▼   ▼   ▼
Ring:      [0] [1] [2] [3] [4]

New request arrives (Success):
Ring:      [S] [1] [2] [3] [4]  →  recalculate rate
            ▲
         overwrites oldest

Efficient: O(1) per request, O(n) memory for window
```

#### Time-Based Sliding Window

```
Window: 60 seconds, divided into 6 buckets of 10s each

Time:    [00-10] [10-20] [20-30] [30-40] [40-50] [50-60]
Fails:   [  1  ] [  0  ] [  2  ] [  1  ] [  0  ] [  3  ]
Total:   [  5  ] [  4  ] [  6  ] [  5  ] [  3  ] [  7  ]

Failure rate = 7/30 = 23.3% (current 60s window)

Advantage: adapts to varying request rates
```

### Per-Service Circuit Breaker Registry

```
  Circuit Breaker Registry
|  | Service | State | Failures | Last Trip |  |
|  | payment-svc | CLOSED | 1/5 | 2h ago |  |
|  | inventory-svc | OPEN | 5/5 | 30s ago |  |
|  | shipping-svc | HALF | 2/3 OK | 25s ago |  |
|  | notification-svc | CLOSED | 0/5 | never |  |
|  | user-svc | CLOSED | 0/5 | 5d ago |  |
  Key: Separate circuit breaker per downstream service
  Never share breakers between different targets
```

### Circuit Breaker with Request Flow

```
Incoming Request
      ▼
  Check CB State
 CLOSED  OPEN      HALF-OPEN
    ▼    ▼             ▼
  Call  Return      Allow if
  Downstream  fallback   under limit
|  | ┌────┼────┐ |
    ▼    │     success  failure
 Result  │        │       │
|  | Close   Re-open |
|  | circuit  circuit |
    ▼    │        │       │
Record   │        ▼       ▼
result   │     Normal   Fallback
|  | response  response |
    ▼    ▼
 Check threshold
    ├─ threshold breached → OPEN circuit
    └─ within limits → continue CLOSED
```

---

## Retry Patterns

### Simple Retry

```
| Client |  | Service |
  ──── request ──────────────────▶
  ◀─── 503 error ────────────────
  ──── retry 1 ─────────────────▶
  ◀─── 503 error ────────────────
  ──── retry 2 ─────────────────▶
  ◀─── 200 OK ──────────────────

Config:
  max_retries:    3
  retry_on:       [503, 429, timeout]
  no_retry_on:    [400, 401, 403, 404]
```

### Exponential Backoff

```
  Exponential Backoff Timeline
  Attempt 1    Attempt 2       Attempt 3
  ▼            ▼               ▼
  ├──1s──┤     ├────2s────┤    ├────────4s────────┤
  X fail  wait  X fail     wait  X fail            wait
  Formula: delay = base_delay * 2^(attempt - 1)
| Attempt | Delay |
  ────────┼──────
| 1 | 1s |
| 2 | 2s |
| 3 | 4s |
| 4 | 8s |
| 5 | 16s |
| 6 | 32s   ← often capped (max_delay) |
  max_delay:  30s (cap to prevent infinite waits)
  max_retries: 5
```

### Exponential Backoff with Jitter

```
  Exponential Backoff with Jitter
  WITHOUT JITTER (thundering herd):
  Client A: ──X──1s──X──2s──X──4s──
  Client B: ──X──1s──X──2s──X──4s──
  Client C: ──X──1s──X──2s──X──4s──
  ▲       ▲       ▲
  all retry simultaneously
  WITH FULL JITTER:
  Client A: ──X──0.7s──X──1.3s──X──3.8s──
  Client B: ──X──0.3s──X──1.8s──X──2.1s──
  Client C: ──X──0.9s──X──0.5s──X──3.2s──
  ▲        ▲        ▲
  retries spread out
  Jitter Strategies:
  Full Jitter:
  delay = random(0, base * 2^attempt)
  Equal Jitter:
  half = (base * 2^attempt) / 2
  delay = half + random(0, half)
  Decorrelated Jitter:
  delay = random(base, previous_delay * 3)
```

### Hedged Requests

```
  Hedged Requests
  Send duplicate requests to multiple replicas;
  use the first response, cancel the rest.
|  | Client |  |
  ├──── request ──────▶ Replica A ── 200ms ──┐
|  | (after P95 threshold, e.g., 50ms) |  |
| ├──── hedged req ──▶ Replica B ── 30ms ──┐ |  |
|  | ◀────── use first response ────────────┘ |  |
|  | cancel Replica A ──────────────────┘ |
  Strategy:
  1. Send primary request
  2. If no response within P95 latency → send hedge
  3. Return whichever responds first
  4. Cancel the slower one
  Overhead:  ~5% extra requests (if hedging at P95)
  Benefit:   Eliminates tail latency
  Risk:      Amplifies load during outages
  → only hedge if backend is healthy
```

### Retry Budget

```
  Retry Budget
  Problem: retries can amplify failure
  Without budget (retry storm):
  100 requests × 3 retries = 300 requests to backend
  Backend at 50% failure → 150 retries → 450 total
  → cascading failure
  With retry budget:
  Allow retries up to 10% of successful request rate
  Successful rate: 500 req/sec
  Retry budget:    50 retries/sec max
  Over budget:     drop retry, return error immediately
  Implementation:
|  | Token Bucket for Retries |  |
|  | capacity:   50 tokens |  |
|  | refill:     50 tokens/sec |  |
|  | cost:       1 token per retry |  |
|  | if bucket.try_consume(1): |  |
|  | perform_retry() |  |
|  | else: |  |
|  | return_error_immediately() |  |
```

### Retry Decision Matrix

```
| Error Type | Retry? | Notes |
| 400 Bad Request | NO | Client error; won't change |
| 401 Unauthorized | NO* | *Unless token refresh |
| 403 Forbidden | NO | Permission issue |
| 404 Not Found | NO | Resource missing |
| 408 Timeout | YES | Transient |
| 409 Conflict | MAYBE | Retry with backoff + read |
| 429 Too Many Req | YES | Use Retry-After header |
| 500 Internal Err | YES | Transient server issue |
| 502 Bad Gateway | YES | Upstream issue |
| 503 Unavailable | YES | Temporary overload |
| 504 Gateway Timeout | YES | Upstream timeout |
| Connection refused | YES | Service restarting |
| Connection reset | YES | Network blip |
| DNS resolution | YES | Transient DNS issue |
| TLS handshake | MAYBE | Could be cert issue |

Key principle: Only retry IDEMPOTENT operations, or operations
with idempotency keys, to avoid duplicates.
```

---

## Bulkhead

### Thread Pool Bulkhead

```
  Thread Pool Isolation
  Without Bulkhead:
|  | Shared Thread Pool (100 threads) |  |
|  | ┌────┐┌────┐┌────┐┌────┐ ... ┌────┐ |  |
|  |  | A |  | A |  | A |  | A |  | A |  |  |
|  | └────┘└────┘└────┘└────┘     └────┘ |  |
|  | ← Service A is slow, consumes ALL threads → |  |
|  | Service B, C: NO THREADS AVAILABLE |  |
  With Bulkhead:
|  | Pool A (40) |  | Pool B |  | Pool C (30) |  |
|  | ┌──┐┌──┐┌──┐┌──┐ |  | (30) |  | ┌──┐┌──┐┌──┐ |  |
|  |  |  |  |  |  |  |  |  |  |  | ┌──┐┌──┐ |  |  |  |  |  |  |  |  |  |
|  | └──┘└──┘└──┘└──┘ |  |  |  |  |  |  |  | └──┘└──┘└──┘ |  |
|  | Service A calls |  | └──┘└──┘ |  | Service C |  |
|  | (isolated) |  | Svc B |  | (isolated) |  |
  Service A exhausts its pool → B and C unaffected
```

### Semaphore Bulkhead

```
  Semaphore Isolation
  Semaphore: limits concurrent calls without a thread pool
|  | Service A Semaphore: 10 permits |  |
|  | Permits: [■][■][■][■][■][■][■][□][□][□] |
|  | used=7        available=3 |  |
|  | New request: |  |
|  | if permits > 0: |  |
|  | acquire permit |  |
|  | call service A |  |
|  | release permit |  |
|  | else: |  |
|  | reject immediately (fallback) |  |
  Comparison:
|  | Aspect | Thread Pool | Semaphore |  |
|  | Isolation | Full | Partial |  |
|  | Overhead | Higher | Lower |  |
|  | Timeout support | Native | Needs wrapping |  |
|  | Async support | Limited | Natural |  |
|  | Queue behavior | Has queue | Reject only |  |
|  | Resource cost | Thread/pool | Counter only |  |
|  | Best for | Blocking IO | Non-blocking |  |
```

### Bulkhead Configuration

```
Per-Service Bulkhead Settings:

  payment_service:
    type:                thread_pool
    max_concurrent:      25
    queue_capacity:      10
    queue_timeout:       500ms
    metrics:             true

  inventory_service:
    type:                semaphore
    max_concurrent:      50
    fallback:            return_cached
    metrics:             true

  notification_service:
    type:                semaphore
    max_concurrent:      100     # non-critical, high volume
    fallback:            drop    # OK to lose some notifications
    metrics:             true

Sizing Guidelines:
  max_concurrent = (requests_per_sec * avg_latency_sec) * 1.5
  Example: 100 req/s * 0.2s * 1.5 = 30 concurrent permits
```

### Bulkhead at Infrastructure Level

```
  Infrastructure-Level Bulkheads
  Level 1: Process Isolation
|  | Container A |  | Container B |  | Container C |  |
|  | CPU: 2 |  | CPU: 1 |  | CPU: 4 |  |
|  | Mem: 4GB |  | Mem: 2GB |  | Mem: 8GB |  |
  Level 2: Network Isolation
|  | VPC: Public |  | VPC: Private |  |
|  | ┌──────┐ ┌──────┐ |  | ┌──────┐ ┌──────┐ |  |
|  |  | API |  | Web |  |  |  | DB |  | Queue |  |  |
|  | └──────┘ └──────┘ |  | └──────┘ └──────┘ |  |
  Level 3: Cluster Isolation
|  | Cluster: Prod |  | Cluster: Batch |  |
|  | (user-facing) |  | (background) |  |
```

---

## Timeout Patterns

### Timeout Types

```
  Timeout Layers
  Client                     Server
|  | ┌─── Connection Timeout ───┐ |  |
|  |  | Time to establish |  |  |
|  |  | TCP connection |  |  |
|  |  | Typical: 1-5s |  |  |
|  | └──────────────────────────┘ |  |
|  | ┌─── TLS Handshake Timeout ─┐ |  |
|  |  | Time for TLS negotiation |  |  |
|  |  | Typical: 2-5s |  |  |
|  | └───────────────────────────┘ |  |
|  | ┌─── Request/Write Timeout ──┐ |  |
|  |  | Time to send request |  |  |
|  |  | body to server |  |  |
|  |  | Typical: 10-30s |  |  |
|  | └────────────────────────────┘ |  |
|  | ┌─── Read/Response Timeout ──┐ |  |
|  |  | Time waiting for first |  |  |
|  |  | byte of response |  |  |
|  |  | Typical: 5-30s |  |  |
|  | └────────────────────────────┘ |  |
|  | ┌─── Total/Overall Timeout ──────────────┐ |  |
|  |  | End-to-end for entire operation |  |  |
|  |  | Typical: 30-60s |  |  |
|  | └────────────────────────────────────────┘ |  |
```

### Timeout Budget (Deadline Propagation)

```
  Timeout Budget Propagation
  Client sets total deadline: 5000ms
  Client ──▶ API Gateway ──▶ Order Svc ──▶ Payment Svc
  5000ms     -200ms          -300ms        remaining
  4800ms          4500ms         4500ms
  Timeline:
  ├──────────────────────────── 5000ms ───────────────┤
|  | Gateway | Order Service | Payment Service |  |
|  | 200ms | 300ms | ≤4500ms |  |
|  |  |  | If 4500ms left, |  |
|  |  |  | Payment Svc uses |  |
|  |  |  | min(own_timeout, |  |
|  |  |  | remaining) |  |
|  |  |  | = min(3000, 4500) |  |
|  |  |  | = 3000ms |  |
  Implementation: gRPC deadline propagation
  Header: grpc-timeout: 4500m
  or
  Header: X-Request-Deadline: 1705312800.000
```

### Adaptive Timeout

```
  Adaptive Timeout
  Static timeout: fixed value (e.g., 5s)
  Problem: too short = false failures, too long = waste
  Adaptive: based on observed latency distribution
  Latency histogram:
  Count
|  | ██ |
|  | ██ ██ |
|  | ██ ██ ██ |
|  | ██ ██ ██ ██ |
|  | ██ ██ ██ ██ ██ |
|  | ██ ██ ██ ██ ██ ██ |
|  | ██ ██ ██ ██ ██ ██ ██ ██ |
  └──┬──┬──┬──┬──┬──┬──┬──┬──────▶ Latency
  50 100 150 200 250 300 500 1000ms
  P50           P95      P99.9
  ▲
  Timeout = P99 * 1.5
  = 300ms * 1.5 = 450ms
  Recalculated every 60 seconds over sliding window
  Floor: 100ms  Ceiling: 5000ms
```

### Timeout Configuration by Service Type

```
| Service Type | Connect | Read | Write | Total |
| Internal API | 500ms | 2s | 2s | 5s |
| External API | 2s | 10s | 10s | 30s |
| Database | 1s | 5s | 5s | 10s |
| Cache (Redis) | 200ms | 500ms | 500ms | 1s |
| Message Queue | 1s | 5s | 1s | 10s |
| File Upload | 2s | 60s | 60s | 120s |
| Search (ES) | 1s | 5s | N/A | 10s |
| ML Inference | 2s | 30s | N/A | 60s |
| Health Check | 500ms | 1s | N/A | 2s |

Rules of thumb:
  - Connection timeout < Read timeout < Total timeout
  - Internal < External
  - Reads < Writes (usually)
  - Cache < Database < External API
```

---

## Fallback Strategies

### Fallback Decision Tree

```
Primary call fails
      ▼
  Is data critical
  for this request?
| YES |  | NO |
    ▼    │                  ▼
┌────────┴──┐         ┌───────────┐
| Is stale |  | Omit the |
| data OK? |  | data |
└─────┬─────┘         │  (degraded │
|  | response) |
  ┌───┼───┐           └───────────┘
  YES    NO
  ▼      ▼
| Cache |  | Default |
| Fall |  | Value or |
| back |  | Queue for |
|  |  | retry |
```

### Cache Fallback

```
  Cache Fallback
  Normal flow:
  Client ──▶ Service ──▶ Downstream ──▶ Response
  Cache response
  ▼
|  | Cache |  |
|  | (Redis) |  |
|  | TTL=5m |  |
  Fallback flow (downstream fails):
  Client ──▶ Service ──X Downstream
  └──▶ Cache ──▶ Stale Response
  (with header:
  X-Cache-Fallback: true
  X-Cache-Age: 300)
  Multi-tier cache fallback:
  1. L1: Local in-memory (Caffeine) — 30s TTL
  2. L2: Distributed cache (Redis) — 5min TTL
  3. L3: Persistent cache (DB snapshot) — 1hr TTL
  4. Default value (hardcoded/config)
  Each tier: progressively more stale but more available
```

### Default Value Fallback

```
  Default Value Fallback
  Scenario: Recommendation service is down
  Normal response:
  {
  "recommendations": [
  {"id": "prod_123", "score": 0.95},
  {"id": "prod_456", "score": 0.87},
  {"id": "prod_789", "score": 0.82}
  ],
  "source": "ml_model_v3"
  }
  Fallback response:
  {
  "recommendations": [
  {"id": "bestseller_1"},
  {"id": "bestseller_2"},
  {"id": "bestseller_3"}
  ],
  "source": "fallback_bestsellers",
  "fallback": true
  }
  Default value sources:
|  | Feature | Default Fallback |  |
|  | Recommendations | Top bestsellers |  |
|  | User preferences | Sensible defaults |  |
|  | Pricing | Last known price |  |
|  | Feature flags | Conservative (off) |  |
|  | Rate limits | Strict defaults |  |
|  | Config | Hardcoded safe values |  |
```

### Degraded Response Fallback

```
  Graceful Degradation
  Full response (all services healthy):
|  | Product Page |  |
|  | ┌────────────┐  ┌───────────────────┐ |  |
|  |  | Product |  | Reviews (★★★★☆) |  |  |
|  |  | Details |  | 142 reviews |  |  |
|  |  | ✓ In Stock | └───────────────────┘ |  |
|  | └────────────┘  ┌───────────────────┐ |  |
|  | ┌────────────┐ | Recommendations |  |  |
|  |  | Price |  | [prod1] [prod2] |  |  |
|  |  | $49.99 | └───────────────────┘ |  |
|  | └────────────┘  ┌───────────────────┐ |  |
|  |  | Shipping Est. |  |  |
|  |  | Arrives Jan 20 |  |  |
|  | └───────────────────┘ |  |
  Degraded response (review + recommendation svc down):
|  | Product Page |  |
|  | ┌────────────┐  ┌───────────────────┐ |  |
|  |  | Product |  | Reviews |  |  |
|  |  | Details |  | (temporarily |  |  |
|  |  | ✓ In Stock |  | unavailable) |  |  |
|  | └────────────┘  └───────────────────┘ |  |
|  | ┌────────────┐  ┌───────────────────┐ |  |
|  |  | Price |  | Popular Items |  |  |
|  |  | $49.99 |  | [best1] [best2] |  |  |
|  | └────────────┘  └───────────────────┘ |  |
|  | ┌───────────────────┐ |  |
|  |  | Shipping Est. |  |  |
|  |  | Arrives Jan 20 |  |  |
|  | └───────────────────┘ |  |
  Priority: core data (product, price, stock) ALWAYS
  enrichment (reviews, recs) can degrade
```

### Fallback Chain

```
  Fallback Chain
  try:
  1. Primary: call downstream service
  ├── success → return response
  ├── fail → try fallback 1
  2. Fallback 1: read from distributed cache
  ├── cache hit → return (stale OK)
  ├── cache miss → try fallback 2
  3. Fallback 2: read from local cache
  ├── cache hit → return (very stale OK)
  ├── cache miss → try fallback 3
  4. Fallback 3: return default value
  └── always succeeds
  Guarantee: at least one level always returns a response
  Pseudocode:
  response = primary.call()
  .recover(cache_distributed.get())
  .recover(cache_local.get())
  .recover(default_value())
```

---

## Rate Limiting for Resilience

### Client-Side Rate Limiting

```
  Client-Side Rate Limiting
  Purpose: protect downstream from being overwhelmed
  by YOUR service during retries/bursts
|  | Your Service |  |
|  | ┌──────────────────────┐ |
|  |  | Client Rate Limiter |  |
|  |  | max: 100 req/sec |  |
|  |  | to: payment-svc |  |
|  | └──────────┬───────────┘ |
|  | if under limit: |
|  | forward request → payment-svc |
|  | else: |
|  | reject locally (no network call) |
  Benefits:
  - Prevents retry storms from overwhelming downstream
  - Faster failure (no network round-trip)
  - Protects shared infrastructure
```

---

## Load Shedding

### Priority-Based Load Shedding

```
  Load Shedding
  When system is overloaded, reject low-priority requests
  to preserve capacity for critical ones.
  Priority Levels:
|  | Level | Request Type | Shed At |  |
|  | P0 | Health checks | Never (keep alive) |  |
|  | P1 | Payment processing | >95% capacity |  |
|  | P2 | Order creation | >85% capacity |  |
|  | P3 | Search queries | >75% capacity |  |
|  | P4 | Recommendations | >60% capacity |  |
|  | P5 | Analytics tracking | >50% capacity |  |
  Load at 80%:
|  | [P0 ✓] [P1 ✓] [P2 ✓] [P3 ✓] |  |
|  | [P4 ✗ SHED] [P5 ✗ SHED] |  |
  Response to shed request: 503 with Retry-After header
  Implementation:
  - Monitor: CPU, memory, queue depth, active requests
  - Signal: current_load / max_capacity = load_factor
  - Decision: shed if priority > shed_threshold(load)
```

---

## Health Endpoint Monitoring

### Multi-Level Health Check

```
  Health Check Levels
  GET /health/live
|  | Liveness: Is the process alive? |  |
|  | Check: process running, not deadlocked |  |
|  | Action on fail: restart container |  |
|  | Response: 200 {"status": "alive"} |  |
|  | Speed: <10ms (no dependency checks) |  |
  GET /health/ready
|  | Readiness: Can it handle requests? |  |
|  | Check: DB connected, cache warm, config OK |  |
|  | Action on fail: remove from load balancer |  |
|  | Response: 200 {"status": "ready"} |  |
|  | Speed: <500ms (shallow dependency checks) |  |
  GET /health/deep
|  | Deep: Are all dependencies healthy? |  |
|  | Check: all downstream services + data |  |
|  | Action on fail: alert, investigate |  |
|  | Response: 200 {"status": "healthy", |  |
|  | "dependencies": {...}} |  |
|  | Speed: <2s (full dependency scan) |  |
|  | Frequency: less often (every 30s) |  |
```

---

## Resilience Testing

### Chaos Engineering Principles

```
  Chaos Engineering Experiments
  Failure Injection Types:
|  | Injection | Tool / Method |  |
|  | Kill instance | Chaos Monkey |  |
|  | Network latency | tc netem, Toxiproxy |  |
|  | Network partition | iptables, Chaos Mesh |  |
|  | CPU stress | stress-ng |  |
|  | Memory pressure | stress-ng |  |
|  | Disk failure | Chaos Mesh |  |
|  | DNS failure | Chaos DNS |  |
|  | Clock skew | libfaketime |  |
|  | Dependency failure | Service mesh fault inject |  |
  Experiment Template:
  1. Hypothesis: "When payment-svc goes down, orders
  degrade gracefully with cached pricing"
  2. Steady state: order success rate = 99.9%
  3. Injection: kill 2/3 payment-svc instances
  4. Observe: order success rate, latency, error types
  5. Verify: rate stays >95%, errors are graceful
  6. Rollback: automatic after 5 minutes
  Blast Radius Progression:
  Dev → Staging → Canary prod → Full prod
```

---

## Pattern Combinations

### Recommended Pattern Stack

```
  Resilience Pattern Stack (Outside → Inside)
  Layer 1: Rate Limiter (outermost)
  └─ Protect from excessive load
  Layer 2: Timeout
  └─ Bound the total request duration
  Layer 3: Bulkhead
  └─ Isolate per-dependency resources
  Layer 4: Circuit Breaker
  └─ Fail fast when dependency is down
  Layer 5: Retry (with backoff + jitter)
  └─ Handle transient failures
  Layer 6: Fallback (innermost)
  └─ Provide degraded response when all else fails
  Execution order (request path):
  Rate Limit → Timeout → Bulkhead → Circuit Breaker →
  Retry (with backoff) → Call → (fail?) → Fallback
  Pseudocode:
  RateLimiter.wrap(
  Timeout.wrap(30s,
  Bulkhead.wrap(25 permits,
  CircuitBreaker.wrap(
  Retry.wrap(3 attempts, exp_backoff,
  HttpClient.call(downstream)
  ).fallback(cache_or_default)
  )
  )
  )
  )
```

### Pattern Interaction Matrix

```
|  | Retry | CB | Timeout | Bulkhead | Fallback |
| Retry | -- | Inside | Inside | Inside | Wraps |
| Circuit Brkr | Outside | -- | Inside | Inside | Wraps |
| Timeout | Outside | Outside | -- | Either | Wraps |
| Bulkhead | Outside | Outside | Either | -- | Wraps |
| Fallback | On fail | On open | On exp. | On full | -- |

Reading: "Retry is INSIDE Circuit Breaker" means the retry
happens before the circuit breaker evaluates the result.

CB ──▶ Retry ──▶ call
       retry 1 fail ─┐
       retry 2 fail ──┤── CB records ONE failure
       retry 3 fail ─┘   (not three)
```

### Resilience Configuration Template

```yaml
# Per-service resilience configuration

downstream_services:
  payment-service:
    timeout:
      connection: 1s
      read: 5s
      total: 10s
    retry:
      max_attempts: 3
      backoff: exponential
      base_delay: 200ms
      max_delay: 5s
      jitter: full
      retry_on: [503, 429, timeout]
    circuit_breaker:
      failure_threshold: 5
      window_size: 10
      wait_duration: 30s
      half_open_permits: 3
    bulkhead:
      type: semaphore
      max_concurrent: 25
    fallback:
      strategy: cache
      cache_ttl: 300s
      default_value: null

  inventory-service:
    timeout:
      connection: 500ms
      read: 2s
      total: 5s
    retry:
      max_attempts: 2
      backoff: exponential
      base_delay: 100ms
      max_delay: 2s
      jitter: equal
      retry_on: [503, timeout]
    circuit_breaker:
      failure_threshold: 3
      window_size: 10
      wait_duration: 15s
      half_open_permits: 2
    bulkhead:
      type: semaphore
      max_concurrent: 50
    fallback:
      strategy: default
      default_value: {"available": true, "quantity": -1}

  notification-service:
    timeout:
      connection: 1s
      read: 3s
      total: 5s
    retry:
      max_attempts: 1
      backoff: none
    circuit_breaker:
      failure_threshold: 10
      window_size: 20
      wait_duration: 60s
    bulkhead:
      type: semaphore
      max_concurrent: 100
    fallback:
      strategy: drop
      # non-critical: OK to lose notifications temporarily
```
