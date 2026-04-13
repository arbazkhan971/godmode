---
name: cache
description: |
  Caching strategy skill. Activates when user needs to design cache layers (CDN, application, database, session),
    implement cache invalidation strategies (TTL, event-based, write-through, write-behind), configure
    Redis/Memcached/Varnish, or prevent cache stampedes. Triggers on: /godmode:cache, "add caching", "cache
    invalidation", "Redis setup", "cache strategy", "CDN configuration", "cache stampede", or when the orchestrator
    detects caching opportunities.
---

# Cache -- Caching Strategy

## Activate When
- User invokes `/godmode:cache`
- User says "add caching", "cache invalidation", "stale data", "cache consistency"
- User says "Redis setup", "Memcached config", "CDN configuration"
- User says "cache stampede", "thundering herd", "hot key"
- When `/godmode:perf` identifies slow queries or high latency

## Workflow

### Step 1: Cache Opportunity Assessment
```
CACHE ASSESSMENT:
Project: <name>
Current Caching: None | CDN only | App-level | Multi-layer
Performance Baseline: P50/P95 latency, Database QPS, Cache hit rate
HOT PATH ANALYSIS: Endpoint, QPS, Latency, Cacheable (Y/N), TTL
IMPACT ESTIMATE: Hit rate, latency reduction, DB load reduction
```

### Step 2: Cache Layer Design
Multi-layer architecture: CDN/Edge -> Application (Redis/Memcached) -> DB Query Cache -> Source of Truth (Database).

**Cache-Aside Pattern (Default):**
- Read: check cache -> HIT: return | MISS: query DB, store in cache with TTL, return
- Write: write to DB, then delete cache key (not update). Next read repopulates.
- Use when: read-heavy (10:1+), brief staleness OK. Start here.

### Step 3: Cache Invalidation Strategies

**TTL-Based:** TTL = max acceptable staleness. Static config: 24h. Product catalog: 10m. Search results: 1m. Real-time pricing: 10s. Always set a TTL.

**Event-Based:** On data change, publish event -> consumer deletes cache keys + purges CDN. Near-real-time, precise.

**Write-Through:** Write to cache AND DB synchronously. Always consistent. Higher write latency.

**Write-Behind:** Write to cache immediately, async flush to DB. Fast writes. Risk of data loss.

**Default recommendation:** Cache-aside + TTL + event-based invalidation.

### Step 4: Redis Configuration
- **Deployment:** Standalone (dev), Sentinel (simple HA), Cluster (large/high throughput)
- **Memory policy:** `allkeys-lru` (recommended). Set `maxmemory`.
- **Connection pooling:** pool_size 20, min_idle 5, connect_timeout 3s, command_timeout 1s
- **Key naming:** `{entity}:{id}`, `{entity}:{id}:{field}`, `{entity}:list:{filter}`
- **All keys MUST have a TTL** — use SETEX or SET with EX option

**Data structures:** STRING (single objects), HASH (objects with fields), SORTED SET (leaderboards), SET/HLL (unique counts), LIST (feeds), STRING+TTL (rate limiting), STRING+NX (distributed locks).

### Step 5: CDN / HTTP Cache Configuration
- Only cache GET/HEAD. Do not cache authenticated requests.
- Strip tracking params. Set Cache-Control, Surrogate-Control, Vary, ETag, Surrogate-Key.
- Use stale-while-revalidate (1h grace). Do not cache 5xx errors.

### Step 6: Cache Stampede Prevention
Problem: Popular key expires -> thousands of concurrent DB queries.

1. **Mutex/Lock:** One request fetches, others wait. Low complexity.
2. **Probabilistic Early Expiration (PER):** Random refresh before TTL. No latency impact.
3. **Stale-While-Revalidate:** Return stale immediately, refresh in background.
4. **Pre-warming:** Scheduled job refreshes popular keys before expiry.

### Step 7: Monitoring
Track: cache_hit_ratio (alert < 80%), cache_latency_seconds (P95 > 10ms), cache_eviction_total (> 100/min),
cache_memory_bytes (> 85%), cache_error_total (> 0).

### Step 8: Validation
```
CACHE STRATEGY VALIDATION:
- All cache keys have TTL: PASS | FAIL
- Invalidation strategy defined: PASS | FAIL
- Stampede prevention on hot keys: PASS | FAIL
- Hit rate monitoring configured: PASS | FAIL
- Memory eviction policy configured: PASS | FAIL
- Key naming consistent: PASS | FAIL
- Sensitive data not cached unencrypted: PASS | FAIL
- Graceful degradation on cache failure: PASS | FAIL
VERDICT: <PASS | NEEDS REVISION>
```


```bash
# Inspect cache status and flush
redis-cli INFO stats | grep hit
curl -s http://localhost:8080/cache/stats
```

## Key Behaviors

```bash
# Cache diagnostics
redis-cli INFO stats | grep -E "hits|misses|evicted"
redis-cli --bigkeys
redis-cli DBSIZE
redis-cli MEMORY USAGE <key>
```

IF cache hit rate < 80%: audit key design and TTL values.
WHEN eviction rate > 100/min: increase maxmemory or audit key sizes.
IF P95 cache latency > 10ms: check network, connection pooling, key sizes.

1. **Cache the right things.** Frequently-read, rarely-changed data only.
2. **Always set a TTL.** A cache without TTL is a memory leak.
3. **Invalidation first.** Design invalidation before caching.
4. **Cache-aside is the default.** Simplest and most forgiving.
5. **Delete on write, not update.** Deletion is idempotent.
6. **Monitor hit rates.** Target 85%+ app, 95%+ CDN.
7. **Plan for cache failure.** App must work without cache.
8. **Prevent stampedes.** Use locking or PER for hot keys.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full caching strategy design |
| `--assess` | Assess current caching |
| `--redis` | Configure Redis layer |
| `--cdn` | Design CDN strategy |
| `--invalidation` | Design invalidation only |
| `--stampede` | Implement stampede prevention |
| `--monitor` | Set up monitoring |

## HARD RULES

Never ask to continue. Loop autonomously until cache hit rate meets target and invalidation is verified.

1. NEVER cache without a TTL.
2. NEVER update cache on write — delete it.
3. NEVER cache everything — high-read, low-write only.
4. NEVER ignore stampedes on hot keys.
5. NEVER treat cache as primary data store.
6. NEVER skip monitoring.
7. NEVER cache sensitive data without encryption.
8. NEVER use inconsistent key naming.

## Output Format

```
CACHE STRATEGY COMPLETE:
Cache layers: <N> configured
Technology: <Redis | Memcached | CloudFront | other>
Keys designed: <N> patterns
Invalidation: <TTL | event-based | write-through>
Stampede prevention: <mutex | PER | none>
Hit rate target: <N>%
```

## Auto-Detection

```
1. Cache infra: grep for redis, ioredis, memcached; check docker-compose
2. CDN: cloudflare, cloudfront configs; Cache-Control headers
3. Patterns: grep for .get(, .set(, .setex( in service code
4. Monitoring: grep for cache_hit, cache_miss metrics
```

<!-- tier-3 -->

## Platform Fallback (Gemini CLI, OpenCode, Codex)
Run caching tasks sequentially: design, then infrastructure, then monitoring.

## Error Recovery
| Failure | Action |
|--|--|
| Cache stampede (thundering herd) | Use lock-based refresh or stale-while-revalidate. Add jitter to TTLs. Never let all keys expire simultaneously. |
| Cache poisoning (wrong data cached) | Add cache key versioning. Invalidate on write. Verify cache content matches source on critical paths. |
| Redis OOM | Set `maxmemory-policy` to `allkeys-lru`. Audit key sizes with `--bigkeys`. Set TTLs on all cache keys. |
| Cache hit rate too low | Check key design matches query patterns. Verify TTL is long enough. Monitor which keys are evicted most. |

## Success Criteria
1. Cache hit rate meets target (target: >80% for application cache).
2. No stale data served beyond defined TTL.
3. Cache invalidation works on all write paths.
4. No cache stampede under load (verified with concurrent test).

## TSV Logging
Append to `.godmode/cache-results.tsv`:
```
timestamp	layer	strategy	hit_rate	ttl_seconds	invalidation_method	status
```
One row per cache layer configured. Never overwrite previous rows.

## Keep/Discard Discipline
```
After EACH cache change:
  KEEP if: hit rate improved AND no stale data AND invalidation works on writes
  DISCARD if: stale data served OR cache stampede possible OR hit rate decreased
  On discard: revert. Fix invalidation logic before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - Cache hit rate meets target
  - Invalidation verified on all write paths
  - No stale data beyond TTL
  - Stampede protection active
```
