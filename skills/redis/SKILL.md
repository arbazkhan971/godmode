---
name: redis
description: Redis architecture and system design.
---

## Activate When
- `/godmode:redis`, "design a cache", "redis cluster"
- "pub/sub", "rate limiting", "session store"
- "leaderboard", "Lua scripting", "redis streams"

## Workflow

### 1. Use Case Assessment
```bash
redis-cli INFO server | grep redis_version
redis-cli INFO memory | grep -E \
  "used_memory_human|maxmemory_human|maxmemory_policy"
redis-cli INFO stats | grep keyspace_hit
```
```
Version: Redis 6|7|8|Valkey 7+
Hosting: self-managed|ElastiCache|Upstash|Redis Cloud
Use cases: cache|queue|pub-sub|session|rate-limit|lock
```

### 2. Data Structure Selection
```
| Use Case | Structure | Key Pattern |
| Cache | String/Hash | cache:{entity}:{id} |
| Counter | String (INCR) | count:{entity}:{id} |
| Session | Hash | session:{token} |
| Queue | List (LPUSH/BRPOP) | queue:{name} |
| Unique set | Set | set:{entity}:{scope} |
| Leaderboard | Sorted Set | lb:{game}:{period} |
| Events/log | Stream | stream:{topic} |
| Lock | String (SET NX EX) | lock:{resource} |
```
IF using wrong structure (String for leaderboard):
  wastes memory and complicates operations.

### 3. Caching Strategies
```
Cache-aside: app checks Redis, miss->DB->store.
Write-through: write DB+cache simultaneously.
Write-behind: write cache, async flush to DB.
Stampede prevention: lock-based refresh OR
  stale-while-revalidate with jitter on TTL.
```
IF popular key expires and 1000 concurrent requests:
  use lock-based cache refresh to prevent stampede.

### 4. Queue and Pub/Sub
```
Simple queue: LPUSH + BRPOP (30s timeout)
Reliable queue: BRPOPLPUSH + processing list
Pub/Sub: fire-and-forget (no persistence)
Streams: persistent, consumer groups, ack, replay
```
IF message must not be lost: use Streams, not Pub/Sub.
IF consumer crashes: Streams with XACK survive it.

### 5. Cluster and Sentinel
```
Sentinel: HA with automatic failover
  WHEN: < 100K ops/sec, data fits single node
Cluster: horizontal scaling + auto-sharding
  WHEN: data > single node, > 100K ops/sec
  Use {hash-tag} for multi-key operations
Replication: primary writes, replicas read
```
IF mem_fragmentation_ratio > 1.5: MEMORY PURGE or restart.

### 6. Memory Optimization
```
Set maxmemory and maxmemory-policy ALWAYS.
| Policy | Use When |
| allkeys-lru | General cache |
| volatile-lru | Mix of cache + permanent data |
| allkeys-lfu | Frequency-based (hot data) |
| noeviction | Queue/lock (never lose data) |
```
IF used_memory > 80% maxmemory: audit with --bigkeys.
IF values > 100KB: compress or split.

### 7. Lua Scripting
```lua
-- Atomic rate limiter (sliding window)
-- KEYS[1]=key, ARGV[1]=window_ms, ARGV[2]=limit
local count = redis.call('ZCARD', KEYS[1])
if count >= tonumber(ARGV[2]) then return 0 end
redis.call('ZADD', KEYS[1], ARGV[3], ARGV[4])
redis.call('PEXPIRE', KEYS[1], ARGV[1])
return 1
```
```bash
redis-cli EVAL "$(cat rate_limit.lua)" 1 \
  "rate:user:1234" 60000 100
```
Lua scripts MUST be idempotent (may retry on MOVED).

### 8. Common Patterns
```
Rate limiter: Sorted Set, score=timestamp
  ZREMRANGEBYSCORE + ZCARD + ZADD + PEXPIRE
Distributed lock: SET key uuid NX EX 30
  Release: Lua check uuid before DEL
Leaderboard: ZADD lb score player
  ZREVRANGE lb 0 9 WITHSCORES (top 10)
```


```bash
# Redis diagnostics
redis-cli INFO memory | grep used_memory_human
redis-cli --latency -i 1
redis-cli DBSIZE
```

```bash
# Redis diagnostics
redis-cli INFO memory | grep used_memory_human
redis-cli DBSIZE
```

```bash
# Redis health check
curl -s http://localhost:8080/health/redis
grep -r "redis" config/ | head -5
```

## Hard Rules
1. NEVER use KEYS in production (blocks). Use SCAN.
2. NEVER store values > 100KB. Compress or split.
3. NEVER create key without TTL (unless permanent).
4. NEVER use SELECT (multi-DB). Use key prefixes.
5. NEVER Pub/Sub for reliable messaging. Use Streams.
6. NEVER connect without connection pool.
7. ALWAYS set maxmemory and maxmemory-policy.
8. ALWAYS follow naming: {service}:{entity}:{id}.
9. NEVER O(N) on large collections without SCAN.

## TSV Logging
Append `.godmode/redis.tsv`:
```
timestamp	operation	data_structure	key_pattern	ttl	verdict
```

## Keep/Discard
```
KEEP if: tests pass AND metrics improved.
DISCARD if: tests fail OR regression detected.
```

## Stop Conditions
```
STOP when FIRST of:
  - used_memory < 80% maxmemory
  - keyspace_hit_ratio > 90%
  - All keys follow naming convention with TTLs
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Connection refused | Check running, host/port, firewall |
| Cache stampede | Lock-based refresh, jitter TTLs |
| OOM | Check maxmemory-policy, audit --bigkeys |
