---
name: cache
description: |
  Caching strategy skill. Activates when user needs to design cache layers (CDN, application, database, session), implement cache invalidation strategies (TTL, event-based, write-through, write-behind), configure Redis/Memcached/Varnish, or prevent cache stampedes. Triggers on: /godmode:cache, "add caching", "cache invalidation", "Redis setup", "cache strategy", "CDN configuration", "cache stampede", or when the orchestrator detects caching opportunities.
---

# Cache -- Caching Strategy

## When to Activate
- User invokes `/godmode:cache`
- User says "add caching", "cache this", "improve response time with cache"
- User says "cache invalidation", "stale data", "cache consistency"
- User says "Redis setup", "Memcached config", "CDN configuration", "Varnish setup"
- User says "cache stampede", "thundering herd", "hot key"
- When `/godmode:perf` identifies slow queries or high latency that caching would solve
- When `/godmode:optimize` recommends adding a cache layer
- When `/godmode:observe` shows high database load or repeated identical queries

## Workflow

### Step 1: Cache Opportunity Assessment
Identify what to cache and where the biggest impact is:

```
CACHE ASSESSMENT:
Project: <name and purpose>
Current Caching: None | CDN only | App-level | Multi-layer
Performance Baseline:
  P50 latency: <current>  ->  <target>
  P95 latency: <current>  ->  <target>
  Database QPS: <current>  ->  <target after caching>
  Cache hit rate: <current or N/A>  ->  <target>

HOT PATH ANALYSIS:
+--------------------------------------------------------------+
|  Endpoint / Query       | QPS    | Latency | Cacheable | TTL  |
+--------------------------------------------------------------+
|  GET /api/products      | 2,000  | 120ms   | YES       | 5m   |
|  GET /api/products/:id  | 5,000  | 45ms    | YES       | 10m  |
|  GET /api/users/:id     | 3,000  | 30ms    | YES       | 5m   |
|  POST /api/orders       | 500    | 200ms   | NO        | --   |
|  GET /api/search?q=...  | 1,500  | 350ms   | YES       | 1m   |
|  Dashboard aggregation  | 100    | 2,000ms | YES       | 15m  |
+--------------------------------------------------------------+

CACHE IMPACT ESTIMATE:
  Estimated hit rate: 85-95%
  Estimated latency reduction: 60-90% on cached endpoints
  Estimated DB load reduction: 70-80%
```

If the user has not specified what to cache, ask: "What are the slowest or most-called endpoints? What data changes infrequently but is read frequently?"

### Step 2: Cache Layer Design
Design a multi-layer caching architecture:

```
CACHE ARCHITECTURE:

Layer 1: CDN / Edge Cache
+--------------------------------------------------------------+
|  CDN (Cloudflare, CloudFront, Fastly)                         |
|  Purpose: Static assets, public API responses                  |
|  TTL: 1h-24h for assets, 1m-5m for API responses             |
|  Invalidation: Purge API or tag-based purge                   |
|  Hit rate target: 95%+ for static, 80%+ for API              |
+--------------------------------------------------------------+
            |
            v (cache miss)
Layer 2: Application Cache
+--------------------------------------------------------------+
|  Redis / Memcached                                             |
|  Purpose: Database query results, computed values, sessions    |
|  TTL: 1m-30m depending on data volatility                     |
|  Invalidation: Event-based + TTL fallback                     |
|  Hit rate target: 90%+                                         |
+--------------------------------------------------------------+
            |
            v (cache miss)
Layer 3: Database Query Cache
+--------------------------------------------------------------+
|  Database-level (pg_stat_statements, MySQL query cache)        |
|  Purpose: Repeated identical queries                           |
|  TTL: Automatic (invalidated on table write)                  |
|  Note: MySQL query cache deprecated in 8.0, use app cache     |
+--------------------------------------------------------------+
            |
            v (cache miss)
Layer 4: Source of Truth
+--------------------------------------------------------------+
|  Database (PostgreSQL, MySQL, MongoDB)                         |
|  Always authoritative                                          |
+--------------------------------------------------------------+
```

#### Cache-Aside (Lazy Loading) Pattern
```
CACHE-ASIDE PATTERN:

Read path:
  1. Check cache for key
  2. If HIT: return cached value
  3. If MISS: query database
  4. Store result in cache with TTL
  5. Return result

Write path:
  1. Write to database
  2. Invalidate cache key (delete, not update)
  3. Next read will repopulate cache

PSEUDOCODE:
async function getProduct(id):
  // Check cache
  cached = await redis.get(`product:${id}`)
  if (cached):
    metrics.increment("cache.hit", { entity: "product" })
    return JSON.parse(cached)

  // Cache miss -- fetch from database
  metrics.increment("cache.miss", { entity: "product" })
  product = await db.query("SELECT * FROM products WHERE id = $1", [id])

  // Populate cache
  await redis.setex(`product:${id}`, 600, JSON.stringify(product))  // 10m TTL

  return product

async function updateProduct(id, data):
  // Write to database
  await db.query("UPDATE products SET ... WHERE id = $1", [id, ...data])

  // Invalidate cache (do NOT update -- delete)
  await redis.del(`product:${id}`)
  await redis.del("products:list:*")  // Invalidate list caches too

USE WHEN:
- Read-heavy workloads (read:write ratio > 10:1)
- Data that can tolerate brief staleness
- Most common caching pattern -- start here
```

### Step 3: Cache Invalidation Strategies
Choose the right invalidation approach for each data type:

#### TTL-Based Invalidation (Time-to-Live)
```
TTL STRATEGY:
+--------------------------------------------------------------+
|  Data Type              | TTL     | Rationale                  |
+--------------------------------------------------------------+
|  Static config          | 24h     | Changes rarely             |
|  Product catalog        | 10m     | Updates few times per day  |
|  User profile           | 5m      | Moderate change frequency  |
|  Search results         | 1m      | Frequently changing data   |
|  Session data           | 30m     | Security requirement       |
|  Real-time pricing      | 10s     | Changes constantly         |
|  Feature flags          | 30s     | Needs fast propagation     |
+--------------------------------------------------------------+

RULES:
- TTL = max acceptable staleness
- Shorter TTL = more DB load, fresher data
- Longer TTL = less DB load, staler data
- Always set a TTL -- never cache indefinitely
```

#### Event-Based Invalidation
```
EVENT-BASED INVALIDATION:

When data changes, publish an event that triggers cache invalidation:

Product updated:
  1. Product Service updates database
  2. Product Service publishes ProductUpdated event
  3. Cache Invalidation Consumer receives event
  4. Consumer deletes product:{id} from Redis
  5. Consumer purges CDN cache for /api/products/{id}

IMPLEMENTATION:
async function handleProductUpdated(event):
  const { product_id } = event.data

  // Invalidate all cache layers
  await redis.del(`product:${product_id}`)
  await redis.del(`product:${product_id}:details`)

  // Invalidate collection caches
  const categoryId = event.data.category_id
  await redis.del(`products:category:${categoryId}`)
  await redis.del("products:featured")

  // Purge CDN
  await cdn.purge(`/api/v1/products/${product_id}`)
  await cdn.purgeTag(`category:${categoryId}`)

ADVANTAGES:
- Near-real-time invalidation (sub-second)
- Precise invalidation (only affected keys)
- Works across distributed cache nodes

USE WHEN:
- Data consistency is important
- Change events are already being published
- Can tolerate brief inconsistency during propagation
```

#### Write-Through Cache
```
WRITE-THROUGH PATTERN:

Write path:
  1. Write to cache AND database synchronously
  2. Both must succeed (or both fail)
  3. Cache always has latest data

Read path:
  1. Always read from cache
  2. Cache miss: fetch from DB, populate cache

PSEUDOCODE:
async function updateProduct(id, data):
  // Write to database first
  const product = await db.query(
    "UPDATE products SET ... WHERE id = $1 RETURNING *",
    [id, ...data]
  )

  // Write to cache (synchronous)
  await redis.setex(`product:${id}`, 600, JSON.stringify(product))

  return product

ADVANTAGES:
- Cache always consistent with database
- No stale reads after writes
- Simpler than event-based invalidation

DISADVANTAGES:
- Write latency increases (DB + cache write)
- Cache filled with data that may never be read
- Single point of failure if cache is unavailable

USE WHEN:
- Write latency is acceptable
- Read-after-write consistency is critical
- Data is read soon after being written
```

#### Write-Behind (Write-Back) Cache
```
WRITE-BEHIND PATTERN:

Write path:
  1. Write to cache immediately (fast)
  2. Asynchronously flush to database (batched)
  3. Client gets immediate response

PSEUDOCODE:
async function updateProduct(id, data):
  // Write to cache immediately
  await redis.setex(`product:${id}`, 600, JSON.stringify(data))

  // Queue async database write
  await writeQueue.enqueue({
    operation: "UPDATE",
    table: "products",
    id: id,
    data: data,
    timestamp: Date.now()
  })

  return data  // Return immediately

// Background worker
async function flushWriteQueue():
  const batch = await writeQueue.dequeueMany(100)
  await db.batchWrite(batch)

ADVANTAGES:
- Very fast writes (cache-speed)
- Absorbs write spikes (database writes are batched)
- Reduces database write load

DISADVANTAGES:
- Risk of data loss if cache fails before flush
- Complex failure handling
- Eventual consistency on reads from other systems

USE WHEN:
- Write-heavy workloads (analytics, logs, counters)
- Write latency is critical
- Temporary data loss is acceptable
```

```
INVALIDATION DECISION:
  Simple/low writes: TTL-based | Strong consistency: Write-through
  High write throughput: Write-behind | Event system exists: Event-based + TTL fallback
  RECOMMENDED DEFAULT: Cache-aside + TTL + event-based invalidation
```

### Step 4: Redis Configuration
Configure Redis for production caching:

```
REDIS CONFIGURATION:

DEPLOYMENT MODE:
+--------------------------------------------------------------+
|  Mode            | Use When                | Availability      |
+--------------------------------------------------------------+
|  Standalone      | Development, testing    | No HA             |
|  Sentinel        | Simple HA needs         | Automatic failover|
|  Cluster         | Large datasets, high    | Sharding + HA     |
|                  | throughput              |                   |
+--------------------------------------------------------------+

REDIS CLUSTER TOPOLOGY:
  Nodes: 6 (3 masters + 3 replicas)
  Hash slots: 16,384 distributed across masters
  Replication: Each master has 1 replica
  Failover: Automatic (replica promotes to master)

MEMORY POLICY:
  maxmemory: 4gb                        # Set based on available RAM
  maxmemory-policy: allkeys-lru         # Evict least-recently-used
  # Alternatives:
  # volatile-lru    -- evict keys with TTL only
  # allkeys-lfu     -- evict least-frequently-used
  # volatile-ttl    -- evict keys closest to expiry
  # noeviction      -- return errors when full

CONNECTION POOLING:
  pool_size: 20                          # Connections per app instance
  min_idle: 5                            # Keep 5 connections warm
  connect_timeout: 3s                    # Connection timeout
  command_timeout: 1s                    # Operation timeout
  retry_attempts: 3                      # Retry on connection failure

KEY NAMING CONVENTION:
  {entity}:{id}                          # product:123
  {entity}:{id}:{field}                  # product:123:details
  {entity}:list:{filter}                 # product:list:category:electronics
  {entity}:count:{scope}                 # product:count:active
  session:{session_id}                   # session:abc-def-123
  rate:{client_id}:{window}             # rate:api-key-xyz:minute

KEY EXPIRATION:
  All keys MUST have a TTL -- never store without expiry
  Use SETEX or SET with EX option (atomic set + expire)
  Audit for keys without TTL: redis-cli --scan | xargs -I{} redis-cli TTL {}
```

#### Redis Data Structure Selection
```
REDIS DATA STRUCTURES:
+--------------------------------------------------------------+
|  Use Case                 | Structure  | Example              |
+--------------------------------------------------------------+
|  Single object cache      | STRING     | SET product:123 json |
|  Object with fields       | HASH       | HSET user:123 name.. |
|  Leaderboard/ranking      | SORTED SET | ZADD leaderboard ... |
|  Unique visitors          | SET / HLL  | PFADD visitors uid   |
|  Recent activity feed     | LIST       | LPUSH feed:uid event |
|  Rate limiting            | STRING+TTL | INCR rate:ip:minute  |
|  Session storage          | HASH       | HSET sess:id key val |
|  Pub/Sub notifications    | PUB/SUB    | PUBLISH channel msg  |
|  Distributed lock         | STRING+NX  | SET lock:res NX EX 5 |
|  Geospatial queries       | GEO        | GEOADD locations ... |
+--------------------------------------------------------------+
```

### Step 5: Memcached vs Redis

```
USE MEMCACHED WHEN: simple key-value only, multi-threaded perf needed, no persistence
USE REDIS WHEN: data structures needed, persistence, pub/sub, replication, Lua scripting
Both: consistent hashing for distribution, connection pooling, 1s connect timeout
```

### Step 6: Varnish / CDN Configuration
Configure edge caching for HTTP responses:

```
VARNISH/CDN KEY RULES:
  - Only cache GET/HEAD requests
  - Do not cache authenticated requests (Authorization header, session cookies)
  - Strip tracking params (utm_*, fbclid, gclid) before cache key
  - Do not cache 5xx errors
  - Set grace period for stale-while-revalidate (1h recommended)

CDN CACHE HEADERS:
+--------------------------------------------------------------+
|  Header                    | Value          | Purpose          |
+--------------------------------------------------------------+
|  Cache-Control             | public,        | Cacheable by CDN |
|                            | max-age=300    | and browser (5m) |
|  Cache-Control             | private,       | Browser only     |
|                            | max-age=0      | (not CDN)        |
|  Cache-Control             | no-store       | Never cache      |
|  Surrogate-Control         | max-age=3600   | CDN-specific TTL |
|  Vary                      | Accept-Encoding| Cache per encoding|
|  ETag                      | "abc123"       | Conditional req  |
|  Surrogate-Key             | product:123    | Tag-based purge  |
+--------------------------------------------------------------+

APPLICATION CACHE HEADER GENERATION:
function setCacheHeaders(res, options):
  if (options.private):
    res.setHeader("Cache-Control", "private, no-cache")
    return

  if (options.noStore):
    res.setHeader("Cache-Control", "no-store")
    return

  const directives = ["public"]
  directives.push(`max-age=${options.browserTTL || 0}`)
  directives.push(`s-maxage=${options.cdnTTL || 300}`)
  if (options.staleWhileRevalidate):
    directives.push(`stale-while-revalidate=${options.staleWhileRevalidate}`)

  res.setHeader("Cache-Control", directives.join(", "))
  if (options.tags):
    res.setHeader("Surrogate-Key", options.tags.join(" "))
```

### Step 7: Cache Stampede Prevention
Prevent thundering herd problems when popular cache keys expire:

```
CACHE STAMPEDE PATTERNS:

Problem:
  Popular key expires -> 1000 concurrent requests all miss cache
  -> 1000 identical database queries simultaneously -> database overload

SOLUTION 1: Locking (Mutex)
  Only one request fetches from DB; others wait for cache repopulation

  async function getWithLock(key, fetchFn, ttl):
    value = await redis.get(key)
    if (value):
      return JSON.parse(value)

    // Try to acquire lock
    lockAcquired = await redis.set(`lock:${key}`, "1", "NX", "EX", 10)

    if (lockAcquired):
      try:
        value = await fetchFn()
        await redis.setex(key, ttl, JSON.stringify(value))
        return value
      finally:
        await redis.del(`lock:${key}`)
    else:
      // Wait and retry (another process is fetching)
      await sleep(50)
      return getWithLock(key, fetchFn, ttl)  // Retry

SOLUTION 2: Probabilistic Early Expiration (PER)
  Randomly refresh cache before TTL expires

  async function getWithPER(key, fetchFn, ttl):
    const entry = await redis.get(key)
    if (entry):
      const { value, expiry, delta } = JSON.parse(entry)
      const now = Date.now()

      // Probabilistically refresh before actual expiry
      const beta = 1  // Tuning parameter
      const randomExpiry = now - delta * beta * Math.log(Math.random())

      if (randomExpiry < expiry):
        return value  // Not time to refresh yet

    // Fetch fresh data
    const start = Date.now()
    const value = await fetchFn()
    const delta = Date.now() - start  // Measure fetch time

    await redis.setex(key, ttl, JSON.stringify({
      value: value,
      expiry: Date.now() + (ttl * 1000),
      delta: delta
    }))

    return value

SOLUTION 3: Stale-While-Revalidate
  Return stale data immediately, refresh in background

  async function getWithSWR(key, fetchFn, ttl, staleTTL):
    const value = await redis.get(key)

    if (value):
      const parsed = JSON.parse(value)

      if (parsed.fresh_until > Date.now()):
        return parsed.data  // Fresh data

      // Data is stale but usable -- return it and refresh in background
      refreshInBackground(key, fetchFn, ttl, staleTTL)
      return parsed.data  // Return stale data immediately

    // No data at all -- must wait for fresh fetch
    return await fetchAndCache(key, fetchFn, ttl, staleTTL)

  async function refreshInBackground(key, fetchFn, ttl, staleTTL):
    // Only one background refresh at a time
    const lock = await redis.set(`refresh:${key}`, "1", "NX", "EX", 30)
    if (!lock): return

    const data = await fetchFn()
    await redis.setex(key, staleTTL, JSON.stringify({
      data: data,
      fresh_until: Date.now() + (ttl * 1000)
    }))

SOLUTION 4: Pre-warming
  Proactively refresh cache before expiry

  // Scheduled job: refresh popular keys
  async function prewarmCache():
    const hotKeys = await getHotKeys()  // From metrics
    for (const key of hotKeys):
      const ttl = await redis.ttl(key)
      if (ttl < 60):  // Less than 1 minute to expiry
        const value = await fetchFromDB(key)
        await redis.setex(key, 600, JSON.stringify(value))

STAMPEDE PREVENTION SELECTION:
+--------------------------------------------------------------+
|  Pattern            | Complexity | Latency Impact | Best For  |
+--------------------------------------------------------------+
|  Mutex/Lock         | Low        | Some wait      | General   |
|  Probabilistic (PER)| Medium     | None           | High-QPS  |
|  Stale-while-reval  | Medium     | None           | Read-heavy|
|  Pre-warming        | Low        | None           | Predict.  |
+--------------------------------------------------------------+
```

### Step 8: Cache Monitoring & Observability

```
CACHE METRICS TO TRACK:
  cache_hit_ratio (Gauge): alert < 80% warning, < 60% critical
  cache_latency_seconds (Histogram): alert P95 > 10ms
  cache_eviction_total (Counter): alert > 100/min
  cache_memory_bytes (Gauge): alert > 85% capacity
  cache_error_total (Counter): alert > 0

DASHBOARD: hit rate (overall + per layer), latency (cache vs DB), memory/keys/evictions
```

### Step 9: Validation
Validate the caching strategy against best practices:

```
CACHE STRATEGY VALIDATION:
+--------------------------------------------------------------+
|  Check                                    | Status             |
+--------------------------------------------------------------+
|  All cache keys have TTL set              | PASS | FAIL        |
|  Cache invalidation strategy defined      | PASS | FAIL        |
|  Cache-aside pattern correctly implemented| PASS | FAIL        |
|  Stampede prevention on hot keys          | PASS | FAIL        |
|  Cache hit rate monitoring configured     | PASS | FAIL        |
|  Redis/Memcached cluster properly sized   | PASS | FAIL        |
|  Memory eviction policy configured        | PASS | FAIL        |
|  Connection pooling configured            | PASS | FAIL        |
|  Key naming convention consistent         | PASS | FAIL        |
|  CDN cache headers set correctly          | PASS | FAIL        |
|  Sensitive data not cached without encrypt| PASS | FAIL        |
|  Cache failure graceful degradation       | PASS | FAIL        |
|  Serialization format consistent (JSON)   | PASS | FAIL        |
|  Cache warming strategy for cold starts   | PASS | FAIL        |
+--------------------------------------------------------------+

VERDICT: <PASS | NEEDS REVISION>
```

### Step 10: Artifacts & Commit
Generate the deliverables:

```
CACHE STRATEGY COMPLETE:

Artifacts:
- Cache design doc: docs/caching/<system>-cache-strategy.md
- Redis/Memcached config: infra/cache/ or k8s/cache/
- Cache utility module: src/lib/cache.ts (or equivalent)
- CDN/Varnish config: infra/cdn/ or infra/varnish/
- Monitoring dashboard: monitoring/dashboards/cache.json
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:perf -- Benchmark cache performance improvement
-> /godmode:observe -- Monitor cache hit rates and latency
-> /godmode:loadtest -- Test cache under high concurrency
-> /godmode:deploy -- Deploy cache infrastructure changes
```

Commit: `"cache: <system> -- <layers configured>, <invalidation strategy>, <hit rate target>"`

## Key Behaviors

1. **Cache the right things.** Cache frequently-read, rarely-changed data. Do not cache data that changes every request or data that is unique per user without clear benefit.
2. **Always set a TTL.** Every cached value must expire. A cache without TTL is a memory leak that eventually serves stale data forever.
3. **Invalidation is harder than caching.** The two hard problems in computer science: cache invalidation, naming things, and off-by-one errors. Design invalidation first, caching second.
4. **Cache-aside is the default.** Start with cache-aside (lazy loading) unless you have a specific reason for write-through or write-behind. It is the simplest and most forgiving pattern.
5. **Delete on write, not update.** When data changes, delete the cache key. Do not try to update it. Deletion is idempotent and avoids race conditions.
6. **Monitor hit rates religiously.** A cache with a 50% hit rate is wasting memory and adding latency on misses. Target 85%+ for application cache, 95%+ for CDN.
7. **Plan for cache failure.** The application must work without the cache -- just slower. Never let a cache outage become an application outage.
8. **Prevent stampedes on hot keys.** One expired popular key can trigger thousands of simultaneous database queries. Use locking, PER, or stale-while-revalidate.

## Example Usage

### Designing a caching strategy for an API
```
User: /godmode:cache Design caching for our product catalog API

Cache: Assessing cache opportunities...

HOT PATH ANALYSIS:
  GET /api/products       2,000 QPS  120ms -> cacheable (5m TTL)
  GET /api/products/:id   5,000 QPS  45ms  -> cacheable (10m TTL)
  GET /api/categories     500 QPS    30ms  -> cacheable (1h TTL)
  GET /api/search?q=...   1,500 QPS  350ms -> cacheable (1m TTL)

CACHE DESIGN:
  Layer 1: CloudFront CDN (public endpoints, 5m TTL)
  Layer 2: Redis Cluster (3 masters, 3 replicas, 4GB per node)
  Invalidation: Event-based (ProductUpdated events) + TTL fallback
  Stampede prevention: Mutex lock on popular keys
  Key pattern: product:{id}, products:list:{page}, search:{hash}

ESTIMATED IMPACT:
  Hit rate: 92%
  P50 latency: 120ms -> 3ms (cached), 120ms (miss)
  DB QPS: 8,500 -> ~680 (92% reduction)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full caching strategy design workflow |
| `--assess` | Assess current caching and identify opportunities |
| `--redis` | Design and configure Redis caching layer |
| `--memcached` | Design and configure Memcached caching layer |
| `--cdn` | Design CDN / edge caching strategy |
| `--varnish` | Configure Varnish HTTP accelerator |
| `--invalidation` | Design cache invalidation strategy only |
| `--stampede` | Implement cache stampede prevention |
| `--monitor` | Set up cache monitoring and alerting |
| `--warmup` | Design cache warming strategy |
| `--validate` | Validate existing cache configuration |
| `--benchmark` | Benchmark cache performance |

## Auto-Detection

```
1. Cache infra: grep for redis, ioredis, memcached; check docker-compose
2. CDN: cloudflare, cloudfront, fastly configs; Cache-Control headers
3. Patterns: grep for .get(, .set(, .setex( in service code
4. Key naming: extract patterns from redis calls, check consistency
5. Monitoring: grep for cache_hit, cache_miss metrics
6. Auto-configure: no cache → recommend; no monitoring → flag; no TTLs → HIGH issue
```

## Anti-Patterns

- **Do NOT cache without a TTL.** Keys without expiry serve stale data until eviction kicks in randomly.
- **Do NOT update cache on write.** Delete on write. Updates create race conditions.
- **Do NOT cache everything.** Cache high-read, low-write data only.
- **Do NOT ignore cache stampedes.** Use mutex locks or probabilistic refresh for hot keys.
- **Do NOT treat cache as primary data store.** Application must work without cache (just slower).
- **Do NOT skip monitoring.** Unknown hit rate = production incident waiting to happen.
- **Do NOT cache sensitive data without encryption.** Plaintext PII in Redis is a vulnerability.
- **Do NOT use inconsistent key naming.** Pick a convention (`entity:id:field`) and enforce it.

## Keep/Discard Discipline

After each caching pass, evaluate:
- **KEEP** if: every cached key has a TTL, invalidation strategy defined per key pattern, stampede prevention on hot keys, cache-aside pattern uses delete-on-write, hit rate monitoring configured, graceful degradation to DB when cache is down.
- **DISCARD** if: keys without TTL detected, cache updated instead of deleted on write, no stampede prevention for high-QPS endpoints, sensitive data cached without encryption, or hit rate below 60%.
- Measure hit rate before and after changes. Revert if hit rate decreases.
- Audit key patterns with SCAN periodically to enforce naming conventions.

## Stop Conditions

Stop the cache skill when:
1. Every cached key has a TTL set.
2. Invalidation strategy is defined and implemented for each key pattern.
3. Stampede prevention is in place for high-traffic keys.
4. Cache hit rate monitoring and eviction alerts are configured.
5. Application degrades gracefully (falls back to DB) when cache is unavailable.

## Output Format

```
CACHE STRATEGY COMPLETE:
  Cache layers: <L1 in-process | L2 Redis | L3 CDN> — <N> layers configured
  Cache technology: <Redis | Memcached | Varnish | CloudFront | other>
  Keys designed: <N> key patterns
  Invalidation: <TTL | event-based | write-through | write-behind>
  Stampede prevention: <mutex | PER | none>
  Hit rate target: <N>% (measured baseline: <M>%)
  TTLs: <range> (shortest: <N>s, longest: <M>s)
  Memory budget: <N> MB estimated

KEY PATTERN SUMMARY:
+--------------------------------------------------------------+
|  Key Pattern             | TTL    | Invalidation | Stampede   |
+--------------------------------------------------------------+
|  <entity>:<id>           | 300s   | event-based  | mutex      |
+--------------------------------------------------------------+
```

## TSV Logging

Log every caching session to `.godmode/cache-results.tsv`:

```
Fields: timestamp\tproject\tcache_technology\tkeys_designed\tinvalidation_strategy\tstampede_prevention\thit_rate_before\thit_rate_after\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-app\tredis\t8\tevent-based\tmutex\t0\t92\tabc1234
```

Append after every completed caching design or optimization pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
CACHE SUCCESS CRITERIA:
+--------------------------------------------------------------+
|  Criterion                                  | Required         |
+--------------------------------------------------------------+
|  Every cached key has a TTL                 | YES              |
|  Invalidation strategy defined per key      | YES              |
|  Stampede prevention on hot keys            | YES              |
|  Cache-aside pattern (delete on write)      | YES              |
|  Key naming convention consistent           | YES              |
|  Hit rate monitoring configured             | YES              |
|  Eviction policy set (allkeys-lru or equiv) | YES              |
|  Memory limit configured                    | YES              |
|  No sensitive data cached without encryption| YES              |
|  Fallback to DB when cache is down          | YES              |
+--------------------------------------------------------------+

VERDICT: ALL required criteria must PASS. Any FAIL → fix before commit.
```

## Error Recovery

```
ERROR RECOVERY — CACHE:
1. Cache hit rate below target:
   → Check TTLs (too short = low hits). Check key granularity (too specific = low hits). Check eviction rate (memory too small). Add monitoring for miss reasons.
2. Cache stampede detected (DB spike on key expiry):
   → Implement mutex/lock-based refresh (only one request refreshes, others wait). Or use probabilistic early refresh (PER). Never let all requests hit DB simultaneously.
3. Stale data served after write:
   → Verify invalidation fires on every write path (including bulk updates, admin tools, migrations). Use event-based invalidation, not just TTL.
4. Redis connection failures:
   → Verify connection pool configuration. Check max connections vs concurrent requests. Implement circuit breaker. Ensure application falls back to DB gracefully (fail open).
5. Memory limit exceeded (evictions spiking):
   → Audit key sizes (redis-cli --bigkeys). Reduce TTLs on large keys. Move large objects to separate Redis instance. Consider compression for large values.
6. Inconsistent key naming causing partial invalidation:
   → Audit all cache keys with SCAN. Standardize naming to <entity>:<id>:<field> pattern. Refactor all cache writes and invalidations to use the standard pattern.
```

## Explicit Loop Protocol

```
FOR each cacheable entity (detect high-read entities):
  1. Identify read/write ratio, design key pattern, set TTL
  2. Choose invalidation (TTL-only, event-based, write-through)
  3. Add stampede prevention if high-traffic
  4. Implement cache-aside wrapper, add hit/miss metrics
ON COMPLETION: Configure memory limits, eviction policy, monitoring dashboard
```

## Multi-Agent Dispatch

```
Agent 1 (cache-design): key patterns, TTLs, invalidation strategies, warming strategy
Agent 2 (cache-infra): Redis/Memcached config, cache-aside wrappers, stampede prevention, CDN
Agent 3 (cache-monitoring): hit/miss metrics, dashboards, alerts, invalidation tests
MERGE: design -> infra -> monitoring. Verify hit rates with load test.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run caching tasks sequentially: cache design, then infrastructure setup, then monitoring.
- Use branch isolation per task: `git checkout -b godmode-cache-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
