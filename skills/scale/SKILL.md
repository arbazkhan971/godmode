---
name: scale
description: >
  Scalability engineering. Horizontal/vertical decisions,
  auto-scaling, read replicas, connection pooling,
  rate limiting, capacity planning.
---

# Scale -- Scalability Engineering

## Activate When
- `/godmode:scale`, "scaling", "auto-scale", "read replica"
- "rate limiting", "capacity planning", "too slow"
- Load testing reveals bottlenecks or saturation alerts

## Workflow

### Step 1: Scalability Assessment
```
SCALABILITY CONTEXT:
Architecture: Monolith | Microservices | Serverless
Current Scale: <RPS, concurrent users, data volume>
Target Scale: <target RPS, users, volume>
Bottleneck: CPU | Memory | I/O | Network | DB | API
SLA: <latency p50/p99, availability>
Database: <type, size, read/write ratio>
Peak vs Baseline: <ratio>
```

### Step 2: Horizontal vs Vertical Decision
```
IF single-threaded workload: scale UP
IF DB write bottleneck AND not at ceiling: scale UP
IF at instance ceiling: scale OUT
IF stateless app tier AND read-heavy: scale OUT
IF peak-to-baseline ratio > 5x: scale OUT
IF need fault tolerance: scale OUT
WHEN quick fix needed AND below ceiling: scale UP first
```

### Step 3: Auto-Scaling
```bash
# K8s HPA — target CPU 70%, memory 80%
kubectl autoscale deployment myapp \
  --cpu-percent=70 --min=2 --max=20

# Check current HPA status
kubectl get hpa myapp -o wide
```
```
POLICIES:
  Scale out:  CPU >70% for 3min -> +2 instances
  Scale fast: CPU >90% for 1min -> +4 instances
  Scale in:   CPU <30% for 10min -> -1 instance
  Stabilization: scale-up 60s, scale-down 300s
  KEDA for event-driven (queue depth, Prometheus)
```

### Step 4: DB Read Replicas & Write Splitting
```
Primary (Writer) -> Replica 1, 2, 3 (Read)
  Writes -> primary | Strong reads -> primary
  Eventually-consistent reads -> replica (round-robin)
  Read-after-write -> primary for 5s, then replica
IF replication lag > 500ms: route reads to primary
IF lag > 2s: circuit breaker, alert, investigate
```

### Step 5: Connection Pooling at Scale
```
Formula: pool_size = (core_count * 2) + 1
Start small (10-20), monitor wait time
Problem: 100 instances * 20 pool = 2000 connections
Solution: PgBouncer multiplexes 2000 app -> 100 DB
  pool_mode = transaction
  default_pool_size = 50
  max_client_conn = 2000
  max_db_connections = 100
```

### Step 6: Rate Limiting & Backpressure
```
RATE LIMITING:
  API Gateway: Token bucket, 1000 req/min per key
  Per-user:    Sliding window, 100 req/min
  Per-endpoint: Fixed window, 50 req/min
  Global:      Leaky bucket, 10000 req/min
  Burst: 100 tokens/sec refill, bucket 200

BACKPRESSURE:
  Bounded queues (reject when full)
  Load shedding priority:
    health > auth > critical > standard > background
  Circuit breaker on failing dependencies
```

Response: `429` + `Retry-After` + `X-RateLimit-*` headers.

### Step 7: Capacity Planning
```bash
# Measure current utilization
kubectl top pods --sort-by=cpu
kubectl top nodes

# Project headroom
echo "At 70% CPU threshold, runway = ..."
```
```
1. Measure baseline under normal load
2. Project growth (3/6/12 month)
3. Identify ceiling per component
4. Calculate runway (when each hits 70%/90%)
5. Plan scaling actions with cost estimates
```

### Step 8: Caching Strategy
```
LAYERS:
  CDN: static 24h, API 60s
  Application: Redis, TTL-based
  Query: in-process 30s
PATTERNS: Cache-aside | Write-through | Write-behind
Target >95% hit rate
Stampede: locking, probabilistic early refresh
```

## Key Behaviors
1. **Measure before scaling.** Profile the bottleneck.
2. **Scale the bottleneck, not everything.**
3. **Stateless is prerequisite.** Externalize state.
4. **Auto-scaling needs tuning.** Defaults are bad.
5. **Connection pools are the hidden bottleneck.**
6. **Cache with purpose.** Measure hit rates.
7. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER scale without measuring the bottleneck first.
2. NEVER store state in application instances.
3. EVERY auto-scaling policy must have cooldown.
4. NEVER set pool_size * instances >= DB max_connections.
5. ALWAYS load test at 2x projected peak.
6. EVERY scaling change must include cost estimate.
7. Rate limits MUST include X-RateLimit-* headers.

## Auto-Detection
```bash
ls docker-compose.yml k8s/ terraform/ 2>/dev/null
grep -r "pgbouncer\|ProxySQL\|redis\|memcached" . \
  --include="*.yml" --include="*.yaml" -l 2>/dev/null
kubectl get hpa 2>/dev/null
```

## Iterative Loop
```
FOR EACH bottleneck:
  1. Measure -> 2. Choose strategy -> 3. Implement
  4. Load test at 2x peak -> 5. Measure improvement
  IF improvement < 20%: wrong bottleneck, re-measure
  IF improvement >= 20%: commit
  IF cost exceeds budget: optimize first
```

## TSV Logging
Log to `.godmode/scale-results.tsv`:
`timestamp\tsystem\tcurrent_rps\ttarget_rps\tbottleneck\tdirection\tcost_delta_pct\tverdict`

## Output Format
Print: `Scale: {bottleneck}. Strategy: {horizontal|vertical|caching}. Capacity: {before} -> {after}. Cost: {est}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
KEEP if: capacity improved AND latency maintained
  AND cost within budget
DISCARD if: latency regressed OR cost exceeds budget
  OR auto-scaler flapping. Revert on discard.
```

## Stop Conditions
```
STOP when ALL of:
  - Target capacity met with acceptable latency
  - Auto-scaling configured and tested
  - Cost within budget with headroom for spikes
```
