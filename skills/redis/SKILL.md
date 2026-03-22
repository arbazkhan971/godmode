---
name: redis
description: |
  Redis architecture and design skill. Activates when a developer needs to design Redis-based systems including caching strategies, message queues, pub/sub, session stores, rate limiters, and leaderboards. Covers data structure selection, Redis Cluster and Sentinel, memory optimization, eviction policies, Lua scripting, Redis Functions, streams, and operational best practices. Triggers on: /godmode:redis, "redis architecture", "design a cache", "redis cluster", "pub/sub", "rate limiting with redis", "session store", or when the orchestrator detects Redis design work.
---

# Redis -- Redis Architecture & System Design

## When to Activate
- User invokes `/godmode:redis`
- User says "design a cache", "caching strategy", "cache invalidation"
- User asks about Redis data structures, pub/sub, streams, or queues
- User says "redis cluster", "sentinel", "redis replication"
- User says "rate limiting", "session store", "leaderboard"
- User needs to optimize Redis memory usage or configure eviction
- User says "Lua scripting", "Redis Functions", "atomic operations"
- When `/godmode:cache` identifies Redis as the caching layer
- When `/godmode:scale` identifies Redis as a scaling component

## Workflow

### Step 1: Redis Use Case Assessment

Determine the role Redis plays in the architecture:

```
REDIS CONTEXT:
Version:         <Redis 6 | 7 | 8 | Valkey 7+>
Hosting:         <Self-managed | ElastiCache | MemoryDB | Upstash | Redis Cloud | Dragonfly>
```

Gather current state:
```bash
# Redis info overview
redis-cli INFO server | grep redis_version
redis-cli INFO memory | grep -E "used_memory_human|maxmemory_human|maxmemory_policy|mem_fragmentation"
```

### Step 2: Data Structure Selection

Choose the right Redis data structure for each use case:

#### Strings
```
USE WHEN: Simple key-value, counters, flags, cached JSON, distributed locks

EXAMPLES:
```

#### Hashes
```
USE WHEN: Objects with fields, partial updates, memory-efficient small objects

EXAMPLES:
```

#### Lists
```
USE WHEN: Queues, stacks, recent items, activity feeds, bounded collections

EXAMPLES:
```

#### Sets
```
USE WHEN: Unique collections, tags, membership testing, set operations

EXAMPLES:
```

#### Sorted Sets
```
USE WHEN: Rankings, leaderboards, priority queues, time-based indexes, rate limiting

EXAMPLES:
```

#### Streams
```
USE WHEN: Event sourcing, message queues with consumer groups, activity logs, audit trails

EXAMPLES:
```

#### Data Structure Decision Matrix
```
DATA STRUCTURE SELECTION:
+--------------------------------------------------------------+
|  Use Case                    | Structure     | Key Pattern     |
```

### Step 3: Redis as Cache

#### Caching Strategies

```
CACHE-ASIDE (Lazy Loading):
1. App checks Redis for key
2. Cache HIT: return cached value
```

#### Cache Stampede Prevention

```
STAMPEDE SCENARIO:
  Popular key expires -> 1000 requests simultaneously miss -> 1000 DB queries

```

### Step 4: Redis as Queue and Pub/Sub

#### Reliable Queue with Lists

```
SIMPLE QUEUE:
  Producer: LPUSH queue:tasks '{"type":"email","to":"alice@..."}'
  Consumer: BRPOP queue:tasks 30  (blocking pop, 30s timeout)
```

#### Pub/Sub

```
PUB/SUB DESIGN:
  Publisher:  PUBLISH channel:orders '{"event":"created","id":"ord-123"}'
  Subscriber: SUBSCRIBE channel:orders
```

#### Session Store

```
SESSION STORE DESIGN:

# Store session as hash (efficient partial reads/writes)
```

### Step 5: Redis Cluster, Sentinel, and Replication

#### Redis Sentinel (High Availability)

```
SENTINEL:
Purpose:  Automatic failover for master-replica setups
Use when: You need HA with < 100K ops/sec and data fits in single node
```

#### Redis Cluster

```
REDIS CLUSTER:
Purpose:  Horizontal scaling across multiple nodes with automatic sharding
Use when: Data exceeds single node memory, or need > 100K ops/sec
```

#### Replication
```
REPLICATION:
  Primary: handles all writes
  Replicas: async copies, handle reads
```

### Step 6: Memory Optimization

```
MEMORY OPTIMIZATION STRATEGIES:

1. Use appropriate data structures:
```

#### Eviction Policies

```
EVICTION POLICIES:
+--------------------------------------------------------------+
|  Policy              | Behavior                | Use When       |
```

### Step 7: Lua Scripting and Redis Functions

#### Lua Scripting
```lua
-- Atomic rate limiter (sliding window)
-- KEYS[1] = rate limit key
-- ARGV[1] = window size in ms
```

```bash
# Execute Lua script
redis-cli EVAL "$(cat rate_limit.lua)" 1 "rate:user:1234" 60000 100 1705334400000 "req-uuid"

```

#### Redis Functions (Redis 7+)
```lua
-- Register a function library
#!lua name=mylib

```

```bash
# Load function library
cat mylib.lua | redis-cli -x FUNCTION LOAD REPLACE

```

### Step 8: Common Redis Patterns

#### Rate Limiter
```
SLIDING WINDOW RATE LIMITER (Sorted Set):
  Key:    rate:<resource>:<identifier>
  Score:  timestamp (ms)
```

#### Distributed Lock (Redlock)
```
SINGLE-NODE LOCK:
  SET lock:<resource> <owner-uuid> NX EX 30
  -- NX = only set if not exists
```

#### Leaderboard
```
LEADERBOARD:
  # Add/update score
  ZADD lb:game:weekly <score> <player_id>
```

### Step 9: Persistence and Durability

```
PERSISTENCE OPTIONS:
+--------------------------------------------------------------+
|  Option  | How                      | Trade-off               |
```

### Step 10: Report and Transition

```
+------------------------------------------------------------+
|  REDIS ARCHITECTURE -- <description>                        |
+------------------------------------------------------------+
```

Commit: `"redis: <description> -- <key outcome>"`

## Key Behaviors

1. **Choose the right data structure.** Redis has 10+ data structures. Using the wrong one (e.g., String for a leaderboard instead of Sorted Set) wastes memory and makes operations harder.
2. **Always set TTL.** Data without TTL grows forever until maxmemory eviction kicks in. Explicit TTL on every key is a hygiene requirement.
3. **Use pipelining for batch operations.** Sending 100 commands one at a time takes 100 round trips. Pipeline them into one round trip.
4. **Avoid O(N) commands on large collections.** KEYS *, SMEMBERS on a 1M-member set, HGETALL on a 10K-field hash. Use SCAN, SSCAN, HSCAN for iteration.
5. **Use Lua/Functions for atomicity.** Keep multi-step operations (check-and-set, rate limiting) atomic. Lua scripts execute on the server without interleaving.
6. **Hash tags for multi-key operations in Cluster.** MGET, transactions, and Lua scripts require all keys on the same node. Use {hash-tag} in key names.
7. **Sentinel for HA, Cluster for scaling.** If data fits in one node, use Sentinel for failover. If data exceeds one node or you need > 100K ops/sec, use Cluster.
8. **Monitor memory fragmentation.** mem_fragmentation_ratio > 1.5 indicates fragmentation. Use MEMORY PURGE or restart Redis to reclaim.
9. **Never use KEYS in production.** KEYS blocks the entire Redis instance. Use SCAN with COUNT hint instead.
10. **Streams over Pub/Sub for reliability.** Pub/Sub is fire-and-forget. Streams persist messages, support consumer groups, acknowledgment, and replay.

## Iterative Implementation Loop

```
current_iteration = 0
max_iterations = 10
redis_tasks = [list of Redis features to implement/optimize]
```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER use KEYS command in production. Use SCAN with cursor.
2. NEVER store values > 100KB. Compress or split.
3. NEVER create a key without a TTL unless it is permanent reference data.
4. NEVER use SELECT (multi-database). Use key prefixes for namespacing.
5. NEVER use Pub/Sub for reliable messaging. Use Streams with consumer groups.
6. NEVER connect without a connection pool. One connection per request kills throughput.
7. EVERY Lua script stays idempotent. Scripts may retry on MOVED errors in Cluster mode.
8. EVERY key must follow the naming convention: {service}:{entity}:{id}[:{field}].
9. NEVER run O(N) commands on large collections without SCAN or pagination.
10. ALWAYS set maxmemory and maxmemory-policy. An unbounded Redis is a ticking bomb.
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER use KEYS command in production. Use SCAN with cursor.
2. NEVER store values > 100KB. Compress or split.
3. NEVER create a key without a TTL unless it is permanent reference data.
4. NEVER use SELECT (multi-database). Use key prefixes for namespacing.
5. NEVER use Pub/Sub for reliable messaging. Use Streams with consumer groups.
6. NEVER connect without a connection pool. One connection per request kills throughput.
7. EVERY Lua script stays idempotent. Scripts may retry on MOVED errors in Cluster mode.
8. EVERY key must follow the naming convention: {service}:{entity}:{id}[:{field}].
9. NEVER run O(N) commands on large collections without SCAN or pagination.
10. ALWAYS set maxmemory and maxmemory-policy. An unbounded Redis is a ticking bomb.
```

## Output Format

```
┌─ REDIS RESULT ─────────────────────────────────────┐
│ Operation : cache-aside setup for user sessions     │
│ Data Structure : STRING with EX (TTL)               │
│ Key Pattern : app:session:{session_id}              │
│ TTL : 1800s (30 min)                                │
│ Eviction Policy : allkeys-lru                       │
│ Memory Est. : ~50MB for 100K sessions               │
│ Persistence : AOF (appendfsync everysec)            │
│ Verdict : READY                                     │

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
timestamp	operation	data_structure	key_pattern	ttl	eviction_policy	memory_estimate	persistence	verdict
2026-03-20T14:30:00Z	cache-aside	STRING	app:session:{id}	1800	allkeys-lru	50MB	AOF	READY
2026-03-20T14:35:00Z	rate-limiter	SORTED_SET	ratelimit:{ip}	60	noeviction	10MB	none	READY
```

## Success Criteria

**HEALTHY** (verify all):
- `used_memory` < 80% of `maxmemory`
- `mem_fragmentation_ratio` between 1.0 and 1.5
- `connected_clients` < 80% of `maxclients`
- `keyspace_hit_ratio` > 90% (hits / (hits + misses))
- `instantaneous_ops_per_sec` within expected baseline
- Zero `rejected_connections` in the monitoring window
- All keys follow `{service}:{entity}:{id}` naming convention
- Every cache key has an explicit TTL
- `maxmemory-policy` is explicitly set (not default `noeviction` unless intentional)
- Persistence (RDB or AOF) is enabled for any non-ephemeral data

## Cache Optimization Loop

```
CACHE OPTIMIZATION LOOP:
max_iterations = 15

```

## Keep/Discard Discipline
```
After EACH implementation or optimization change:
  1. MEASURE: Run tests / validate the change produces correct output.
  2. COMPARE: Is the result better than before? (faster, safer, more correct)
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All identified tasks are complete and validated
  - User explicitly requests stop
```


## Error Recovery
| Failure | Action |
|---------|--------|
| Redis connection refused | Check if Redis is running. Verify host/port configuration. Check firewall rules. Test with `redis-cli ping`. |
| Cache stampede (thundering herd) | Use lock-based cache refresh. Add jitter to TTLs. Implement stale-while-revalidate pattern. |
| Memory limit reached (OOM) | Check `maxmemory-policy`. Use LRU/LFU eviction. Audit key sizes with `redis-cli --bigkeys`. Set TTLs on all cache keys. |
| Key naming collisions | Use namespace prefixes (`app:service:entity:id`). Never use generic names. Document key naming convention. |
