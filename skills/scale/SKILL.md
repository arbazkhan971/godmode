---
name: scale
description: |
  Scalability engineering skill. Activates when user needs horizontal vs vertical scaling decisions, auto-scaling configuration, database read replicas and write splitting, connection pooling at scale, rate limiting and backpressure, or capacity planning methodology. Triggers on: /godmode:scale, "scaling", "auto-scale", "read replica", "connection pool", "rate limiting", "backpressure", "capacity planning", "horizontal scaling", "vertical scaling", or when the orchestrator detects scalability work.
---

# Scale -- Scalability Engineering

## When to Activate
- User invokes `/godmode:scale`
- User says "scaling", "auto-scale", "read replica", "rate limiting", "capacity planning"
- User says "too slow", "can't handle load", "need more throughput"
- When load testing reveals bottlenecks or observability alerts on saturation

## Workflow

### Step 1: Scalability Assessment
```
SCALABILITY CONTEXT:
Current Architecture: Monolith | Microservices | Serverless
Current Scale: <RPS, concurrent users, data volume>
Target Scale: <target RPS, users, volume>
Bottleneck: <CPU | Memory | I/O | Network | Database | External API>
SLA: <latency p50/p99, availability>
Database: <type, size, read/write ratio>
Peak vs Baseline: <ratio>
```

### Step 2: Horizontal vs Vertical Decision
Scale UP when: single-threaded workload, DB write bottleneck, quick fix needed, not at instance ceiling. Scale OUT when: at ceiling, stateless app tier, read-heavy, need fault tolerance, high peak-to-baseline ratio.

### Step 3: Auto-Scaling
```
POLICIES:
  Scale out:  CPU >70% for 3min -> +2 instances
  Scale fast: CPU >90% for 1min -> +4 instances
  Scale in:   CPU <30% for 10min -> -1 instance
  Scheduled:  Pre-warm for known traffic patterns
```

K8s HPA: target CPU 70%, memory 80%, custom metrics (RPS). Scale-up stabilization 60s, scale-down 300s. KEDA for event-driven (queue depth, Prometheus metrics).

### Step 4: Database Read Replicas & Write Splitting
```
Primary (Writer) -> Replica 1, 2, 3 (Read)
  Writes -> primary | Strong reads -> primary
  Eventually-consistent reads -> replica (round-robin)
  Read-after-write -> primary for N seconds, then replica
```
Monitor replication lag. Circuit breaker: if lag > threshold, route reads to primary temporarily. Use PgBouncer/ProxySQL/RDS Proxy for connection multiplexing.

### Step 5: Connection Pooling at Scale
```
Formula: pool_size = (core_count * 2) + 1
Rule: Start small (10-20), monitor wait time, increase only if justified
Problem: 100 instances * 20 pool = 2000 connections (exceeds DB max)
Solution: Connection proxy multiplexes 2000 app -> 100 DB connections
```

PgBouncer: transaction-level pooling (`pool_mode = transaction`), `default_pool_size = 50`, `max_client_conn = 2000`, `max_db_connections = 100`.

### Step 6: Rate Limiting & Backpressure
```
RATE LIMITING:
  API Gateway: Token bucket, 1000 req/min per API key
  Per-user:    Sliding window, 100 req/min
  Per-endpoint: Fixed window, 50 req/min
  Global:      Leaky bucket, 10000 req/min

RECOMMENDED: Token bucket (controlled burst)
  100 tokens/sec refill, bucket size 200 -> sustained 100 RPS, burst 200
```

Response: `429 Too Many Requests` + `Retry-After` + `X-RateLimit-*` headers.

**Backpressure:** Bounded queues (reject when full), load shedding (priority: health > auth > critical > standard > background > analytics), circuit breaker on failing dependencies.

### Step 7: Capacity Planning
```
1. Measure baseline metrics under normal load
2. Project growth (3/6/12 month)
3. Identify capacity ceiling per component
4. Calculate runway (when each component hits 70%/90%)
5. Plan scaling actions with cost estimates
6. Execute in priority order
```

### Step 8: Caching Strategy
```
LAYERS: CDN (static 24h, API 60s) | Application cache (Redis, TTL-based) | Query cache (in-process 30s)
PATTERNS: Cache-aside (lazy) | Write-through | Write-behind | Read-through
```
Target >95% hit rate. Stampede prevention: locking, probabilistic early refresh, stale-while-revalidate.

### Step 9: Scaling Checklist
Check: app tier stateless, session externalized, auto-scaling configured, read replicas, connection pooling, rate limiting, backpressure, caching, CDN, capacity plan, load tested at 2x peak, graceful degradation.

### Step 10: Artifacts
```
Artifacts: scaling plan, capacity plan, auto-scaling config, rate limit config
Commit: "scale: <system> -- <strategy>, <target capacity>"
Next: /godmode:loadtest, /godmode:observe, /godmode:cost
```

## Key Behaviors
1. **Measure before scaling.** Profile, identify bottleneck, scale the bottleneck.
2. **Scale the bottleneck, not everything.** Wrong component = wasted money.
3. **Stateless is a prerequisite.** Externalize all state before horizontal scaling.
4. **Auto-scaling needs tuning.** Defaults are rarely optimal.
5. **Connection pools are the hidden bottleneck.** Use proxies to multiplex.
6. **Rate limiting is protection, not punishment.**
7. **Capacity planning is continuous.** Quarterly review.
8. **Cache with purpose.** Measure hit rates, cache only the working set.

## Flags & Options

| Flag | Description |
|------|-------------|
| `--assess` | Current capacity assessment |
| `--autoscale` | Auto-scaling configuration |
| `--database` | DB scaling (replicas, pooling) |
| `--cache` | Caching strategy design |
| `--ratelimit` | Rate limiting design |
| `--capacity` | Capacity planning with projections |

## HARD RULES
1. NEVER scale without measuring the bottleneck first.
2. NEVER store state in application instances. Externalize all.
3. EVERY auto-scaling policy must have a cooldown period.
4. NEVER set pool size * instances >= DB max_connections.
5. ALWAYS load test at 2x projected peak.
6. EVERY scaling change must include a cost estimate.
7. NEVER scale an unoptimized hot path. Optimize first.
8. Rate limits MUST include X-RateLimit-* and Retry-After headers.
9. EVERY read replica must handle stale reads correctly.

## Auto-Detection
```
Check: docker-compose/k8s/terraform, database configs, Redis/Memcached/CDN,
load balancer (nginx/ALB), auto-scaling (HPA/ASG), message queues,
connection pooling (pgbouncer/ProxySQL), N+1 queries, missing indexes
```

## Iterative Loop
```
FOR EACH bottleneck:
  1. Measure -> 2. Choose strategy -> 3. Implement -> 4. Load test at 2x peak
  5. Measure improvement -> 6. Verify cost impact
  IF improvement < 20%: wrong bottleneck, re-measure
  IF improvement >= 20%: commit
```

## Multi-Agent Dispatch
```
Agent 1 (scale-app): Stateless services, pools, caching
Agent 2 (scale-data): Read replicas, sharding, indexes, queries
Agent 3 (scale-infra): Auto-scaling, load balancers, CDN, queues
MERGE ORDER: data -> app -> infra
```

## TSV Logging
Log to `.godmode/scale-results.tsv`: `timestamp\tsystem\tcurrent_rps\ttarget_rps\tbottleneck\tdirection\tphases\tcost_delta_pct\tverdict`

## Success Criteria
1. Bottleneck identified with profiling evidence.
2. Scaling direction justified with measurements.
3. App tier verified stateless.
4. Auto-scaling with scale-out trigger, scale-in cooldown, warm-up.
5. Pool sizes: pool * instances < max_connections * 0.8.
6. Rate limiting with headers and per-tier limits.
7. Load test at 2x peak passes.
8. Cost estimate per phase.

## Error Recovery
- **Unknown bottleneck:** Require metrics before recommending. Do NOT guess.
- **<20% improvement:** Re-measure, real bottleneck is elsewhere. Optimize before scaling.
- **Auto-scaling flaps:** Increase stabilization window, adjust threshold +-10%.
- **Pool exhaustion:** Increase temporarily, add proxy, check for leaked connections.
- **Cost exceeds budget:** Optimize first (caching, queries, CDN), then reserved/spot instances.
- **Replica lag causes stale reads:** Route to primary for N seconds after write, monitor lag, circuit breaker.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-scale-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `Scale: {bottleneck} identified. Strategy: {horizontal|vertical|caching}. Capacity: {before} -> {after}. Cost: {estimate}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH scaling change:
  KEEP if: capacity improved AND latency maintained or improved AND cost within budget
  DISCARD if: latency regressed OR cost exceeds budget OR auto-scaler flapping
  On discard: revert. Optimize (caching, queries) before adding infrastructure.
```

## Stop Conditions
```
STOP when ALL of:
  - Target capacity met with acceptable latency
  - Auto-scaling configured and tested
  - Cost within budget with headroom for spikes
  - Monitoring and alerts active for capacity metrics
```
