# Recipe: Making Your App 10x Faster

> From sluggish to blazing fast. A complete Godmode workflow for systematic performance optimization with a 100-iteration autonomous run.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `perf → webperf → query → cache → optimize → loadtest → verify` |
| **Timeline** | 1-3 days for significant improvements |
| **Team size** | 1-2 engineers |
| **Example project** | "DataHub" — an analytics dashboard with 8-second page loads |

---

## The Scenario

Your analytics dashboard is painfully slow:
- Dashboard page load: 8.2 seconds
- API response time (p95): 4.7 seconds
- Database query time: 3.1 seconds average
- Frontend bundle: 2.4 MB (uncompressed)
- Lighthouse performance score: 23/100
- Users are churning because "the app is too slow"

Your target: sub-1-second page loads, p95 API response under 200ms.

---

## Phase 1: Measure Everything (Day 1 Morning)

### Step 1: Perf — Profile the Full Stack

```
> /godmode:perf

Godmode: Profiling full application stack...

PERFORMANCE PROFILE:

Frontend waterfall:
  DNS + TCP + TLS:        120ms
  HTML document:          340ms (server-side render)
  CSS (3 files):          180ms (render-blocking)
  JavaScript (5 bundles): 1,200ms download + 2,100ms parse/execute
  API calls (4 parallel): 4,700ms (waiting for backend)
  DOM rendering:          1,560ms (after data arrives)
  TOTAL:                  ~8,200ms

Backend breakdown (GET /api/dashboard):
  Auth middleware:         12ms
  Database queries:        3,100ms (7 queries, 3 are slow)
  Business logic:          890ms (aggregation in application code)
  Serialization:           340ms (large payload)
  Network transfer:        358ms (1.8 MB JSON response)
  TOTAL:                   ~4,700ms

Database slow queries:
  1. Dashboard summary: 1,400ms (full table scan, 2M rows)
  2. Revenue by month: 980ms (GROUP BY without index)
  3. Top customers: 720ms (subquery, no materialized view)

Memory profile:
  Server RSS: 840 MB (Node.js heap)
  Database connections: 45/50 (near limit)
  Redis cache: not configured

BOTTLENECK RANKING (by impact):
  1. Database queries (3,100ms — 66% of backend time)
  2. Frontend JS bundle (3,300ms download + parse)
  3. Application-layer aggregation (890ms — should be in DB)
  4. Payload size (1.8 MB — massive over-fetching)
  5. No caching layer (every request hits the database)

Saved: docs/performance/datahub-profile.md
```

### Step 2: WebPerf — Frontend Performance Audit

```
> /godmode:webperf

Godmode: Running frontend performance audit...

LIGHTHOUSE REPORT:
  Performance: 23/100
  FCP (First Contentful Paint): 3.2s
  LCP (Largest Contentful Paint): 7.8s
  TBT (Total Blocking Time): 2,890ms
  CLS (Cumulative Layout Shift): 0.34

BUNDLE ANALYSIS:
  Total: 2.4 MB (uncompressed), 680 KB (gzipped)
  Breakdown:
    chart-library.js:    890 KB (37%) — full library, only using 3 charts
    moment.js:           560 KB (23%) — with all locales
    lodash.js:           340 KB (14%) — full library, using 4 functions
    app-code.js:         410 KB (17%) — including inline SVGs
    vendor-misc.js:      200 KB (8%)  — polyfills not needed for target browsers

CRITICAL ISSUES:
  1. No code splitting — entire app loaded upfront
  2. No tree shaking — full libraries bundled
  3. Render-blocking CSS (3 external stylesheets)
  4. No image optimization (dashboard logos are 4K PNGs)
  5. No preconnect hints for API domain
  6. No service worker / caching strategy
  7. Layout shifts from chart placeholders

Saved: docs/performance/datahub-webperf-audit.md
```

### Step 3: Query — Database Query Optimization

```
> /godmode:query

Godmode: Analyzing database queries...

QUERY ANALYSIS:

Query 1: Dashboard Summary (1,400ms)
  SELECT COUNT(*), SUM(revenue), AVG(response_time)
  FROM events
  WHERE created_at > NOW() - INTERVAL '30 days'

  EXPLAIN ANALYZE:
    Seq Scan on events (rows=2,145,832, actual time=1,398.234ms)
    No index on created_at for this table

  FIX: Add index on events(created_at) + partial index for last 30 days
  EXPECTED: 1,400ms → 15ms

Query 2: Revenue by Month (980ms)
  SELECT DATE_TRUNC('month', created_at) as month, SUM(amount)
  FROM transactions
  GROUP BY 1
  ORDER BY 1 DESC
  LIMIT 12

  EXPLAIN ANALYZE:
    Sort + HashAggregate on 890,234 rows
    Index exists on created_at but not covering for amount

  FIX: Add covering index on transactions(created_at, amount) +
       materialized view refreshed hourly
  EXPECTED: 980ms → 3ms (from materialized view)

Query 3: Top Customers (720ms)
  SELECT c.name, SUM(t.amount) as total
  FROM customers c
  JOIN transactions t ON t.customer_id = c.id
  WHERE t.created_at > NOW() - INTERVAL '30 days'
  GROUP BY c.id, c.name
  ORDER BY total DESC
  LIMIT 10

  EXPLAIN ANALYZE:
    Hash Join + Seq Scan on transactions
    Suboptimal join order, missing composite index

  FIX: Add index on transactions(customer_id, created_at, amount) +
       materialized view refreshed hourly
  EXPECTED: 720ms → 5ms (from materialized view)

N+1 DETECTION:
  Found 4 N+1 patterns in dashboard API:
    1. Loading customer details per transaction (N queries)
    2. Loading product details per line item (N queries)
    3. Loading user preferences per dashboard widget (N queries)
    4. Loading permission checks per data source (N queries)

TOTAL EXPECTED IMPROVEMENT: 3,100ms → ~50ms (98% reduction)

Saved: docs/performance/datahub-query-analysis.md
```

---

## Phase 2: The 100-Iteration Optimization Run (Day 1 Afternoon - Day 2)

### Step 4: Optimize — Backend (50 iterations)

```
> /godmode:optimize \
    --goal "reduce GET /api/dashboard response time" \
    --verify "curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/dashboard" \
    --target "< 0.2" \
    --iterations 50

Godmode: Starting 50-iteration backend optimization...

Baseline (3 runs): 4,712ms | 4,698ms | 4,723ms → Median: 4,712ms

ITERATION  HYPOTHESIS                               BEFORE    AFTER    CHANGE  VERDICT
─────────────────────────────────────────────────────────────────────────────────────────
 1         Add index on events(created_at)          4,712ms   3,298ms  -30.0%  KEEP
 2         Add index on transactions(created_at,    3,298ms   2,340ms  -29.1%  KEEP
           amount)
 3         Add composite index on transactions      2,340ms   1,890ms  -19.2%  KEEP
           (customer_id, created_at, amount)
 4         Fix N+1: eager load customer details     1,890ms   1,234ms  -34.7%  KEEP
 5         Fix N+1: eager load product details      1,234ms     987ms  -20.0%  KEEP
 6         Fix N+1: batch load user preferences       987ms     892ms   -9.6%  KEEP
 7         Fix N+1: batch load permission checks      892ms     845ms   -5.3%  KEEP
 8         Create materialized view for monthly       845ms     612ms  -27.6%  KEEP
           revenue
 9         Create materialized view for top            612ms     498ms  -18.6%  KEEP
           customers
10         Move aggregation from JS to SQL             498ms     342ms  -31.3%  KEEP
           (SUM/AVG in query)
11         Add Redis cache (60s TTL) for dashboard     342ms     45ms   -86.8%  KEEP
           summary
12         Reduce JSON payload: select only needed      45ms     38ms   -15.6%  KEEP
           fields
13         Add response compression (gzip)              38ms     32ms   -15.8%  KEEP
14         Connection pool: 50 → 100 connections        32ms     31ms    -3.1%  KEEP
15         Enable prepared statements                   31ms     28ms    -9.7%  KEEP
16         Add HTTP cache headers (max-age=30)          28ms     28ms     0.0%  REVERT
           (no effect on server-side measurement)
17         Move to streaming JSON serialization         28ms     26ms    -7.1%  KEEP
18         Precompute dashboard for active users        26ms     25ms    -3.8%  KEEP
19-50      [further micro-optimizations: diminishing returns detected at iteration 22]

EARLY STOP at iteration 22 (3 consecutive iterations with < 1% improvement)

BACKEND OPTIMIZATION COMPLETE:
  Baseline:      4,712ms
  Final:            24ms
  Improvement:   99.5%
  Target:        < 200ms ✓ ACHIEVED (exceeded by 176ms)
  Iterations:    22 used of 50 allocated
  Kept:          19 (86%)
  Reverted:       3 (14%)

Top 5 improvements:
  1. Redis caching (60s TTL)               -86.8%  (342ms → 45ms)
  2. Fix N+1 queries (4 patterns)          -53.3%  (1,890ms → 845ms cumulative)
  3. Database indexes (3 indexes)          -50.3%  (4,712ms → 2,340ms cumulative)
  4. Materialized views (2 views)          -41.1%  (845ms → 498ms cumulative)
  5. Move aggregation to SQL               -31.3%  (498ms → 342ms)
```

### Step 5: Optimize — Frontend (50 iterations)

```
> /godmode:optimize \
    --goal "reduce Lighthouse performance score gap" \
    --verify "npx lighthouse http://localhost:3000/dashboard --output=json --quiet | jq '.categories.performance.score * 100'" \
    --target "> 90" \
    --iterations 50

Godmode: Starting 50-iteration frontend optimization...

Baseline: Lighthouse score 23

ITERATION  HYPOTHESIS                               BEFORE  AFTER   CHANGE   VERDICT
──────────────────────────────────────────────────────────────────────────────────────
 1         Replace moment.js with date-fns           23      31     +8 pts   KEEP
           (560 KB → 12 KB)
 2         Replace full lodash with lodash-es         31      35     +4 pts   KEEP
           cherry-pick (340 KB → 8 KB)
 3         Tree-shake chart library (import only      35      44     +9 pts   KEEP
           used charts) (890 KB → 120 KB)
 4         Remove unnecessary polyfills               44      48     +4 pts   KEEP
           (200 KB → 0)
 5         Enable code splitting (route-based          48      56     +8 pts   KEEP
           lazy loading)
 6         Extract and inline critical CSS             56      62     +6 pts   KEEP
 7         Add preconnect hints for API domain         62      64     +2 pts   KEEP
 8         Compress images (PNG → WebP, add            64      69     +5 pts   KEEP
           srcset)
 9         Add loading skeletons (reduce CLS)          69      73     +4 pts   KEEP
10         Defer non-critical JavaScript               73      78     +5 pts   KEEP
11         Enable Brotli compression on static         78      81     +3 pts   KEEP
           assets
12         Add resource hints (prefetch dashboard      81      83     +2 pts   KEEP
           API)
13         Virtualize long lists (only render          83      86     +3 pts   KEEP
           visible rows)
14         Move chart rendering to Web Worker          86      88     +2 pts   KEEP
15         Add service worker for static asset         88      91     +3 pts   KEEP
           caching
16         Optimize SVG icons (inline → sprite)        91      92     +1 pt    KEEP
17         Implement stale-while-revalidate for        92      93     +1 pt    KEEP
           API responses
18-50      [diminishing returns, early stop at iteration 20]

FRONTEND OPTIMIZATION COMPLETE:
  Baseline:      23/100
  Final:         93/100
  Improvement:   +70 points
  Target:        > 90 ✓ ACHIEVED
  Iterations:    20 used of 50 allocated
  Kept:          17 (85%)
  Reverted:       3 (15%)

Web Vitals:
               Before    After     Target    Status
  FCP:         3.2s      0.8s      < 1.8s    ✓
  LCP:         7.8s      1.2s      < 2.5s    ✓
  TBT:         2,890ms   120ms     < 200ms   ✓
  CLS:         0.34      0.04      < 0.1     ✓

Bundle size:
  Before: 2.4 MB (680 KB gzipped)
  After:  340 KB (98 KB gzipped)
  Reduction: 85.6%
```

---

## Phase 3: Validate Under Load (Day 2)

### Step 6: Cache — Implement Caching Strategy

```
> /godmode:cache

Godmode: Designing caching strategy...

CACHING ARCHITECTURE:

Layer 1: Browser Cache
  Static assets: Cache-Control: max-age=31536000, immutable (hashed filenames)
  API responses: Cache-Control: max-age=30, stale-while-revalidate=300
  Service worker: Stale-while-revalidate for dashboard API

Layer 2: CDN (CloudFront)
  Static assets: Edge-cached globally
  API responses: Not cached at CDN (personalized data)

Layer 3: Application Cache (Redis)
  Dashboard summary: 60-second TTL, per-tenant key
  Monthly revenue: 1-hour TTL (matches materialized view refresh)
  Top customers: 1-hour TTL (matches materialized view refresh)
  User preferences: 5-minute TTL
  Cache invalidation: On data mutation (order created, payment received)

Layer 4: Database Cache
  Materialized views: Refreshed hourly via pg_cron
  Connection pooling: PgBouncer with 200 connections
  Query plan cache: Prepared statements

Cache hit rates (projected):
  Dashboard summary: 95% (refreshed every 60s, requested every 2s)
  Revenue/customers: 99% (refreshed hourly, requested constantly)
  Overall API cache hit: ~92%

Commit: "perf: implement 4-layer caching — browser, CDN, Redis, database"
```

### Step 7: LoadTest — Stress Test the Optimized System

```
> /godmode:loadtest

Godmode: Running load test suite...

LOAD TEST CONFIGURATION:
  Tool: k6
  Target: GET /api/dashboard
  Duration: 10 minutes per scenario

SCENARIO 1: Normal Load (100 concurrent users)
  Requests/sec:    850
  p50 latency:     28ms
  p95 latency:     67ms
  p99 latency:     142ms
  Error rate:      0.00%
  Verdict:         ✓ PASS

SCENARIO 2: Peak Load (500 concurrent users)
  Requests/sec:    2,340
  p50 latency:     45ms
  p95 latency:     189ms
  p99 latency:     342ms
  Error rate:      0.02%
  Verdict:         ✓ PASS

SCENARIO 3: Spike (0 → 1000 users in 30 seconds)
  Peak requests/sec: 3,100
  p50 latency:       89ms
  p95 latency:       456ms
  p99 latency:       890ms
  Error rate:        0.15%
  Verdict:           ✓ PASS (p99 elevated but within budget)

SCENARIO 4: Soak (200 users for 1 hour)
  Requests/sec:    1,200 (stable)
  p50 latency:     32ms → 34ms (no degradation)
  Memory:          420 MB → 435 MB (stable, no leak)
  Error rate:      0.01%
  Verdict:         ✓ PASS (no memory leak, stable latency)

SCENARIO 5: Cache-miss storm (Redis flush + 500 users)
  p99 latency:     1,200ms (first 10 seconds while cache rebuilds)
  p99 latency:     145ms (after cache warms)
  Error rate:      0.00%
  Verdict:         ✓ PASS (graceful degradation)

LOAD TEST SUMMARY:
  All 5 scenarios passed.
  System handles 10x current production traffic.
  No memory leaks detected in 1-hour soak.
  Cache miss scenario degrades gracefully.

Saved: docs/performance/datahub-loadtest-report.md
```

### Step 8: Verify — Final Verification

```
> /godmode:verify

Godmode: Running full verification...

PERFORMANCE VERIFICATION:

Backend API:
  ✓ GET /api/dashboard: 24ms (target: < 200ms)
  ✓ Cached response: 4ms
  ✓ Under 500-user load: p95 189ms (target: < 200ms)

Frontend:
  ✓ Lighthouse score: 93 (target: > 90)
  ✓ LCP: 1.2s (target: < 2.5s)
  ✓ Bundle size: 98 KB gzipped (was 680 KB)

Functional:
  ✓ All 247 tests passing
  ✓ No regressions detected
  ✓ Data accuracy verified (dashboard numbers match raw queries)

VERDICT: All targets met. Performance verified under load.
```

---

## Before and After Summary

### Backend Performance

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| API response (p50) | 4,712ms | 24ms | 99.5% faster |
| API response (p95) | 6,200ms | 67ms | 98.9% faster |
| Database query time | 3,100ms | 8ms (cache miss) | 99.7% faster |
| Cache hit rate | 0% (no cache) | 92% | N/A |
| Max throughput | 80 req/s | 2,340 req/s | 29x higher |

### Frontend Performance

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Lighthouse score | 23/100 | 93/100 | +70 points |
| First Contentful Paint | 3.2s | 0.8s | 75% faster |
| Largest Contentful Paint | 7.8s | 1.2s | 85% faster |
| Total Blocking Time | 2,890ms | 120ms | 96% faster |
| Cumulative Layout Shift | 0.34 | 0.04 | 88% better |
| Bundle size (gzipped) | 680 KB | 98 KB | 86% smaller |

### Overall Page Load

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Full page load | 8.2s | 0.9s | **9.1x faster** |
| Time to interactive | 6.5s | 1.1s | **5.9x faster** |
| Perceived load (skeleton) | N/A | 0.3s | Instant feel |

---

## The 100-Iteration Optimization Log

Combined results from both backend (22 iterations) and frontend (20 iterations):

```
FULL OPTIMIZATION RUN: 42 iterations (of 100 allocated)

Backend iterations:  22 (19 kept, 3 reverted)
Frontend iterations: 20 (17 kept, 3 reverted)
Total changes kept:  36 (85.7%)
Total reverted:       6 (14.3%)
Early stopped:       Yes (diminishing returns on both)

Key insight: 80% of the improvement came from the first 10 iterations
on each side. The remaining iterations provided valuable but incremental
gains. The optimization loop correctly identified diminishing returns
and stopped early rather than burning through 100 iterations.

Full log: .godmode/optimize-results.tsv
```

---

## Optimization Playbook by Category

### Database Optimizations (typically largest impact)

```
/godmode:query                           # Analyze slow queries
/godmode:optimize --goal "query time"    # Fix N+1, add indexes

Common wins:
  - Add missing indexes (30-90% improvement per query)
  - Fix N+1 queries (50-95% improvement)
  - Materialized views for aggregations (95-99% improvement)
  - Connection pooling (reduces latency under load)
  - Move aggregation from app code to SQL (30-50% improvement)
```

### Caching Optimizations (biggest multiplier)

```
/godmode:cache                           # Design caching strategy
/godmode:optimize --goal "cache hit rate"

Common wins:
  - Redis for frequently-read, rarely-changed data (80-99% reduction)
  - HTTP cache headers for static assets (eliminates requests)
  - CDN for global distribution (50-90% latency reduction for remote users)
  - Service worker for offline-first (eliminates network on repeat visits)
```

### Frontend Optimizations (user-perceived speed)

```
/godmode:webperf                         # Audit frontend performance
/godmode:optimize --goal "Lighthouse"

Common wins:
  - Bundle size reduction via tree shaking (50-80% smaller)
  - Code splitting (only load what you need)
  - Image optimization (WebP, srcset, lazy loading)
  - Critical CSS inlining (faster first paint)
  - Loading skeletons (perceived instant load)
```

### Infrastructure Optimizations (capacity)

```
/godmode:loadtest                        # Find breaking points
/godmode:optimize --goal "throughput"

Common wins:
  - Horizontal scaling (auto-scale on CPU/memory)
  - CDN for static assets (offload origin server)
  - Read replicas for database (distribute read load)
  - Queue heavy operations (don't block request/response)
```

---

## Custom Chain for Performance Work

```yaml
# .godmode/chains.yaml
chains:
  perf-full:
    description: "Complete performance optimization workflow"
    steps:
      - perf       # profile the full stack
      - webperf    # audit frontend specifically
      - query      # analyze database queries
      - optimize:
          args: "--iterations 50"
      - cache      # implement caching strategy
      - loadtest   # validate under load
      - verify     # confirm targets met
      - ship

  perf-quick:
    description: "Quick backend optimization"
    steps:
      - query
      - optimize:
          args: "--iterations 20"
      - verify
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Optimization Example](../examples/optimization.md) — Single endpoint optimization walkthrough
- [Greenfield SaaS Recipe](greenfield-saas.md) — Build fast from the start
- [Incident Response Recipe](incident-response.md) — When slow becomes down
