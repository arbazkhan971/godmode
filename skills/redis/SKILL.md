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
Deployment:      <Standalone | Sentinel | Cluster | Managed HA>
Current role:    <Cache | Queue | Pub/Sub | Session Store | Rate Limiter | Primary Store | Multi-role>
Data volume:     <keys count, memory usage>
Throughput:      <ops/sec, read/write ratio>
Latency target:  <p50, p99 requirements>
Persistence:     <None | RDB | AOF | Both>
Client library:  <ioredis | redis-py | Jedis | Lettuce | go-redis | StackExchange.Redis>
Pain points:     <what is driving the need for Redis expertise>
```

Gather current state:
```bash
# Redis info overview
redis-cli INFO server | grep redis_version
redis-cli INFO memory | grep -E "used_memory_human|maxmemory_human|maxmemory_policy|mem_fragmentation"
redis-cli INFO keyspace
redis-cli INFO stats | grep -E "total_commands|instantaneous_ops|keyspace_hits|keyspace_misses"
redis-cli INFO replication | grep -E "role|connected_slaves|master_link_status"

# Key count and memory by pattern (use SCAN, never KEYS in production)
redis-cli --scan --pattern "cache:*" | wc -l
redis-cli --scan --pattern "session:*" | wc -l

# Slow log
redis-cli SLOWLOG GET 10

# Memory analysis
redis-cli MEMORY DOCTOR
redis-cli INFO memory
```

### Step 2: Data Structure Selection

Choose the right Redis data structure for each use case:

#### Strings
```
USE WHEN: Simple key-value, counters, flags, cached JSON, distributed locks

EXAMPLES:
SET user:1234:profile '{"name":"Alice","email":"..."}' EX 3600  # Cache with TTL
INCR api:rate:user:1234:2025-01-15T10                          # Rate counter
SET lock:order:5678 "owner-uuid" NX EX 30                      # Distributed lock
MGET user:1:name user:2:name user:3:name                       # Batch fetch

MEMORY: ~90 bytes overhead per key + value size
        Use MSET/MGET for batch operations (fewer round trips)

ENCODING:
  - int: values that look like integers (0 bytes overhead)
  - embstr: strings <= 44 bytes (single allocation)
  - raw: strings > 44 bytes (two allocations)
```

#### Hashes
```
USE WHEN: Objects with fields, partial updates, memory-efficient small objects

EXAMPLES:
HSET user:1234 name "Alice" email "alice@example.com" plan "pro" last_login "2025-01-15"
HGET user:1234 email                                            # Single field
HMGET user:1234 name email plan                                  # Multiple fields
HINCRBY user:1234 login_count 1                                  # Atomic field increment
HGETALL user:1234                                                # All fields (careful with large hashes)

MEMORY OPTIMIZATION:
  - hash-max-listpack-entries 128  (default)
  - hash-max-listpack-value 64    (default)
  When entries <= 128 AND all values <= 64 bytes:
    Redis uses listpack encoding (~10x more memory-efficient)
  When exceeded: hashtable encoding (more memory, O(1) access)

PATTERN -- Hash as namespace (memory-efficient for many small values):
  Instead of: SET user:1:name "Alice", SET user:1:email "..."  (2 keys, ~180 bytes overhead)
  Use:        HSET user:1 name "Alice" email "..."              (1 key, ~90 bytes overhead)
```

#### Lists
```
USE WHEN: Queues, stacks, recent items, activity feeds, bounded collections

EXAMPLES:
# Queue (FIFO)
LPUSH queue:emails '{"to":"alice@...","subject":"Welcome"}'    # Enqueue
BRPOP queue:emails 30                                           # Blocking dequeue (30s timeout)

# Recent items (bounded)
LPUSH user:1234:recent_views "product:5678"
LTRIM user:1234:recent_views 0 49                               # Keep last 50

# Stack (LIFO)
LPUSH stack:undo '{"action":"delete","item":"..."}'
LPOP stack:undo

MEMORY: listpack when entries <= 128 AND each <= 64 bytes, else quicklist (doubly-linked list of listpacks)

PATTERNS:
  Reliable queue:  RPOPLPUSH source dest (atomic move between lists)
  Blocking queue:  BRPOP (blocks until item available or timeout)
  Capped list:     LPUSH + LTRIM (bounded collection)
```

#### Sets
```
USE WHEN: Unique collections, tags, membership testing, set operations

EXAMPLES:
SADD product:1234:tags "electronics" "sale" "featured"          # Add tags
SISMEMBER product:1234:tags "sale"                               # Membership test O(1)
SMEMBERS product:1234:tags                                       # All members (small sets only)
SINTER user:1:interests user:2:interests                         # Common interests
SUNION tag:electronics tag:sale                                  # All products in either tag
SDIFF user:1:following user:2:following                          # Users 1 follows but 2 doesn't

MEMORY: listpack when entries <= 128 AND all <= 64 bytes, else hashtable

WARNING: SMEMBERS on large sets is O(N). Use SSCAN for iteration.
```

#### Sorted Sets
```
USE WHEN: Rankings, leaderboards, priority queues, time-based indexes, rate limiting

EXAMPLES:
# Leaderboard
ZADD leaderboard 1500 "player:alice" 1200 "player:bob" 1800 "player:charlie"
ZREVRANGE leaderboard 0 9 WITHSCORES                            # Top 10
ZREVRANK leaderboard "player:alice"                              # Alice's rank
ZINCRBY leaderboard 50 "player:alice"                            # Add 50 points

# Time-based index (score = timestamp)
ZADD events:user:1234 1705334400 "event:login:uuid1"
ZRANGEBYSCORE events:user:1234 1705248000 1705334400             # Events in time range

# Sliding window rate limiter
ZADD rate:user:1234 <now_ms> <request_uuid>
ZREMRANGEBYSCORE rate:user:1234 0 <now_ms - window_ms>
ZCARD rate:user:1234                                             # Count in window

# Priority queue
ZADD priority_queue <priority> <task_id>
ZPOPMIN priority_queue                                           # Dequeue lowest priority

MEMORY: listpack when entries <= 128 AND all <= 64 bytes, else skiplist + hashtable
```

#### Streams
```
USE WHEN: Event sourcing, message queues with consumer groups, activity logs, audit trails

EXAMPLES:
# Produce events
XADD events:orders * action "created" order_id "ord-123" amount "99.99"
XADD events:orders * action "paid" order_id "ord-123" payment_id "pay-456"

# Consumer groups (each message delivered to one consumer in the group)
XGROUP CREATE events:orders order-processors $ MKSTREAM

# Consumer reads (blocking)
XREADGROUP GROUP order-processors consumer-1 COUNT 10 BLOCK 5000 STREAMS events:orders >

# Acknowledge processed messages
XACK events:orders order-processors <message-id>

# Check pending (unacknowledged) messages
XPENDING events:orders order-processors - + 10

# Claim stuck messages (consumer died without ACK)
XAUTOCLAIM events:orders order-processors consumer-2 60000 0-0
# Claims messages pending > 60s from any consumer

# Trim stream (cap at 10K entries or by time)
XTRIM events:orders MAXLEN ~ 10000
XTRIM events:orders MINID ~ <timestamp-based-id>

STREAMS vs PUB/SUB vs LISTS:
+--------------------------------------------------------------+
|  Feature           | Streams       | Pub/Sub    | Lists       |
+--------------------------------------------------------------+
|  Persistence       | Yes           | No         | Yes         |
|  Consumer groups   | Yes           | No         | No          |
|  Message replay    | Yes           | No         | No          |
|  Acknowledgment    | Yes           | No         | Manual      |
|  Fan-out           | Per group     | All subs   | One consumer|
|  Backpressure      | Yes (BLOCK)   | No         | Yes (BRPOP) |
|  Best for          | Event sourcing| Real-time  | Job queues  |
|                    | Activity logs | Broadcasts | Task queues |
+--------------------------------------------------------------+
```

#### Data Structure Decision Matrix
```
DATA STRUCTURE SELECTION:
+--------------------------------------------------------------+
|  Use Case                    | Structure     | Key Pattern     |
+--------------------------------------------------------------+
|  Cache JSON/HTML/API         | String        | cache:<type>:<id>|
|  User profile / object       | Hash          | user:<id>        |
|  Counter / rate limit        | String (INCR) | count:<type>:<id>|
|  Feature flag                | String (bit)  | flag:<name>      |
|  Queue (FIFO)                | List          | queue:<name>     |
|  Recent items (bounded)      | List          | recent:<user>    |
|  Tags / membership           | Set           | tags:<entity>    |
|  Leaderboard / ranking       | Sorted Set    | lb:<name>        |
|  Time-series index           | Sorted Set    | ts:<metric>      |
|  Event log / audit           | Stream        | events:<domain>  |
|  Pub/Sub broadcast           | Pub/Sub       | channel:<topic>  |
|  Session store               | Hash          | session:<token>  |
|  Distributed lock            | String (NX)   | lock:<resource>  |
|  Geospatial (nearby)         | Geo (sorted)  | geo:<type>       |
|  Bit flags / bloom           | String (bits) | bits:<name>      |
+--------------------------------------------------------------+
```

### Step 3: Redis as Cache

#### Caching Strategies

```
CACHE-ASIDE (Lazy Loading):
1. App checks Redis for key
2. Cache HIT: return cached value
3. Cache MISS: query database, write to Redis with TTL, return value

Code pattern:
  async function getUser(id) {
    const cached = await redis.get(`user:${id}`);
    if (cached) return JSON.parse(cached);

    const user = await db.users.findById(id);
    await redis.set(`user:${id}`, JSON.stringify(user), 'EX', 3600);
    return user;
  }

Pros: Only caches what is actually read, simple
Cons: Cache miss penalty (extra round trip), stale data until TTL

WRITE-THROUGH:
1. App writes to database AND Redis simultaneously
2. Reads always hit cache (no miss penalty)

Code pattern:
  async function updateUser(id, data) {
    await db.users.update(id, data);
    await redis.set(`user:${id}`, JSON.stringify(data), 'EX', 3600);
  }

Pros: Cache always fresh, no miss penalty on reads
Cons: Write latency increased, caches data that may never be read

WRITE-BEHIND (Write-Back):
1. App writes to Redis only
2. Background process flushes to database asynchronously

Pros: Fastest writes, batch database updates
Cons: Risk of data loss if Redis crashes before flush, complex

CACHE INVALIDATION PATTERNS:
+--------------------------------------------------------------+
|  Pattern          | How                    | When              |
+--------------------------------------------------------------+
|  TTL-based        | SET key val EX 3600    | Tolerate staleness|
|  Event-based      | DELETE key on write    | Strong consistency|
|  Version-based    | key = user:1:v3        | Immutable cache   |
|  Tag-based        | Track keys by tag,     | Related entities  |
|                   | invalidate by tag      |                   |
+--------------------------------------------------------------+

CACHE KEY DESIGN:
  Format:    <entity>:<id>[:<field>]   e.g., user:1234:profile
  Namespace: <service>:<entity>:<id>    e.g., api:user:1234
  Version:   <entity>:<id>:v<N>         e.g., config:global:v3
  Wild:      Never use KEYS for lookup -- use hash tags or secondary index
```

#### Cache Stampede Prevention

```
STAMPEDE SCENARIO:
  Popular key expires -> 1000 requests simultaneously miss -> 1000 DB queries

SOLUTIONS:

1. Probabilistic early expiration (best for most cases):
   Refresh cache before TTL expires with some randomness
   actual_ttl = base_ttl - (base_ttl * random(0, 0.1))

2. Distributed lock on cache miss:
   Only one request queries DB, others wait for cache fill

   async function getWithLock(key) {
     let value = await redis.get(key);
     if (value) return JSON.parse(value);

     const lockKey = `lock:${key}`;
     const acquired = await redis.set(lockKey, '1', 'NX', 'EX', 10);

     if (acquired) {
       value = await fetchFromDB(key);
       await redis.set(key, JSON.stringify(value), 'EX', 3600);
       await redis.del(lockKey);
       return value;
     }

     // Another process is rebuilding -- wait and retry
     await sleep(100);
     return getWithLock(key);
   }

3. Background refresh (never expire):
   Keep cache forever, background job refreshes periodically
   No stampede possible -- cache always has a value
```

### Step 4: Redis as Queue and Pub/Sub

#### Reliable Queue with Lists

```
SIMPLE QUEUE:
  Producer: LPUSH queue:tasks '{"type":"email","to":"alice@..."}'
  Consumer: BRPOP queue:tasks 30  (blocking pop, 30s timeout)

RELIABLE QUEUE (with processing list):
  -- Consumer moves item to processing list atomically
  BRPOPLPUSH queue:tasks queue:tasks:processing 30

  -- After processing, remove from processing list
  LREM queue:tasks:processing 1 <task>

  -- Recovery: check processing list for stuck tasks
  -- If task has been in processing list > timeout, move back to queue

PRIORITY QUEUE (with sorted sets):
  ZADD queue:priority <priority_score> <task_json>
  -- Lower score = higher priority
  ZPOPMIN queue:priority  -- Dequeue highest priority
```

#### Pub/Sub

```
PUB/SUB DESIGN:
  Publisher:  PUBLISH channel:orders '{"event":"created","id":"ord-123"}'
  Subscriber: SUBSCRIBE channel:orders

  Pattern subscribe: PSUBSCRIBE channel:orders:*

USE CASES:
  - Real-time notifications (chat, presence, typing indicators)
  - Cache invalidation broadcasts
  - Configuration change propagation
  - Live dashboard updates

LIMITATIONS:
  - Fire-and-forget: no persistence, no replay
  - No acknowledgment: if subscriber is down, message is lost
  - No consumer groups: every subscriber gets every message
  - Memory: messages buffer in publisher if subscriber is slow

FOR RELIABLE MESSAGING: Use Streams instead of Pub/Sub
```

#### Session Store

```
SESSION STORE DESIGN:

# Store session as hash (efficient partial reads/writes)
HSET session:<token> user_id "1234" role "admin" created_at "2025-01-15T10:00:00Z" ip "1.2.3.4"
EXPIRE session:<token> 86400  # 24h TTL

# Read session
HGETALL session:<token>

# Update session field
HSET session:<token> last_active "2025-01-15T12:30:00Z"

# Slide expiration on activity
EXPIRE session:<token> 86400

# Invalidate session
DEL session:<token>

# Invalidate all sessions for a user (need secondary index)
SADD user:1234:sessions <token1> <token2>
-- On "logout everywhere":
SMEMBERS user:1234:sessions  # Get all tokens
DEL session:<token1> session:<token2>  # Delete sessions
DEL user:1234:sessions  # Clean up index
```

### Step 5: Redis Cluster, Sentinel, and Replication

#### Redis Sentinel (High Availability)

```
SENTINEL:
Purpose:  Automatic failover for master-replica setups
Use when: You need HA with < 100K ops/sec and data fits in single node

TOPOLOGY:
+-------------------+     +-------------------+     +-------------------+
|  Sentinel 1       |     |  Sentinel 2       |     |  Sentinel 3       |
|  (monitor + vote) |     |  (monitor + vote) |     |  (monitor + vote) |
+-------------------+     +-------------------+     +-------------------+
          |                         |                         |
          +------------+------------+
                       |
              +--------+--------+
              |                 |
      +-------v------+  +------v-------+
      |  Master      |  |  Replica     |
      |  (read/write)|  |  (read-only) |
      +--------------+  +--------------+

SENTINEL CONFIGURATION (sentinel.conf):
sentinel monitor mymaster <master-ip> 6379 2
  # "2" = quorum: number of sentinels that must agree master is down
sentinel down-after-milliseconds mymaster 5000
  # Consider master down after 5s of no response
sentinel failover-timeout mymaster 60000
  # Failover timeout: 60s
sentinel parallel-syncs mymaster 1
  # Only 1 replica syncs from new master at a time

CLIENT CONNECTION (via Sentinel):
  // ioredis (Node.js)
  const redis = new Redis({
    sentinels: [
      { host: 'sentinel-1', port: 26379 },
      { host: 'sentinel-2', port: 26379 },
      { host: 'sentinel-3', port: 26379 },
    ],
    name: 'mymaster',
  });

RULES:
- Minimum 3 sentinels for reliable quorum
- Sentinels on different machines/availability zones
- Quorum = (num_sentinels / 2) + 1 for split-brain prevention
```

#### Redis Cluster

```
REDIS CLUSTER:
Purpose:  Horizontal scaling across multiple nodes with automatic sharding
Use when: Data exceeds single node memory, or need > 100K ops/sec

TOPOLOGY:
+--------------------------------------------+
|               Redis Cluster                |
|                                            |
|  +--------+  +--------+  +--------+       |
|  |Master 1|  |Master 2|  |Master 3|       |
|  |0-5460  |  |5461-   |  |10923-  |       |
|  |slots   |  |10922   |  |16383   |       |
|  +---+----+  +---+----+  +---+----+       |
|      |           |           |             |
|  +---v----+  +---v----+  +---v----+       |
|  |Replica |  |Replica |  |Replica |       |
|  |1a      |  |2a      |  |3a      |       |
|  +--------+  +--------+  +--------+       |
+--------------------------------------------+

16384 hash slots distributed across masters
Key -> CRC16(key) % 16384 -> slot -> node

HASH TAGS (force keys to same slot):
  {user:1234}:profile  and  {user:1234}:sessions
  Both hash on "user:1234" -> same slot -> same node
  Required for multi-key operations (MGET, transactions, Lua)

CLUSTER SETUP:
  redis-cli --cluster create \
    node1:6379 node2:6379 node3:6379 \
    node4:6379 node5:6379 node6:6379 \
    --cluster-replicas 1

CLUSTER COMMANDS:
  CLUSTER INFO           # Cluster state and stats
  CLUSTER NODES          # Node list with slot assignments
  CLUSTER SLOTS          # Slot-to-node mapping
  CLUSTER KEYSLOT <key>  # Which slot a key maps to

CLIENT CONNECTION:
  // ioredis cluster mode
  const cluster = new Redis.Cluster([
    { host: 'node1', port: 6379 },
    { host: 'node2', port: 6379 },
    { host: 'node3', port: 6379 },
  ], {
    redisOptions: { password: 'secret' },
    scaleReads: 'slave',  // Read from replicas
    natMap: { ... },      // NAT/Docker port mapping
  });

CLUSTER LIMITATIONS:
- Multi-key operations only within same hash slot
- No multi-database (only db 0)
- Pub/Sub: messages broadcast to all nodes (network cost)
- Lua scripts: all keys must be in same slot
- Transactions: all keys must be on same node
```

#### Replication
```
REPLICATION:
  Primary: handles all writes
  Replicas: async copies, handle reads

  REPLICAOF <master-ip> <master-port>    # Make this node a replica

  # In redis.conf:
  replicaof <master-ip> 6379
  masterauth <password>
  replica-read-only yes

REPLICATION MODES:
+--------------------------------------------------------------+
|  Mode            | How                     | Trade-off         |
+--------------------------------------------------------------+
|  Async (default) | Replica may lag behind  | Best performance  |
|  WAIT N timeout  | Wait for N replicas     | Stronger durability|
|                  | to ACK write            | Higher latency    |
+--------------------------------------------------------------+

EXAMPLE:
  SET key value
  WAIT 1 1000  # Wait for 1 replica to ACK within 1000ms
               # Returns number of replicas that ACKed
```

### Step 6: Memory Optimization

```
MEMORY OPTIMIZATION STRATEGIES:

1. Use appropriate data structures:
   - Hash for small objects (listpack encoding < 128 entries)
   - Sorted Set for bounded ranked data
   - Avoid storing large JSON strings -- use Hash fields instead

2. Key naming (shorter = less memory):
   BAD:  user_profile_cache:user_id:1234:full_profile
   GOOD: u:1234:p

3. TTL on everything:
   Always set expiration. Data without TTL grows forever.
   SET key value EX 3600  # Always include TTL

4. Compression:
   Compress large values before storing:
   SET key (gzip(JSON.stringify(data))) EX 3600
   Saves 50-80% for large JSON/text values

5. Listpack thresholds (tune for your data):
   hash-max-listpack-entries 128    # Increase if hashes have more fields
   hash-max-listpack-value 64      # Increase if values are slightly larger
   zset-max-listpack-entries 128
   list-max-listpack-size -2       # -2 = 8KB per listpack node

6. Memory analysis:
   redis-cli MEMORY USAGE <key>     # Bytes used by specific key
   redis-cli --bigkeys               # Find largest keys by type
   redis-cli --memkeys                # Find keys using most memory
   redis-cli MEMORY DOCTOR            # General memory health check

MEMORY REPORT:
+--------------------------------------------------------------+
|  Category            | Memory    | % Total  | Action          |
+--------------------------------------------------------------+
|  Strings (cache)     | 2.1 GB    | 42%      | Review TTLs     |
|  Hashes (sessions)   | 1.4 GB    | 28%      | OK              |
|  Sorted Sets (LBs)   | 0.8 GB    | 16%      | OK              |
|  Overhead            | 0.5 GB    | 10%      | Normal          |
|  Fragmentation       | 0.2 GB    | 4%       | < 1.5 ratio OK  |
+--------------------------------------------------------------+
|  Total               | 5.0 GB    | 100%     |                 |
|  maxmemory           | 6.0 GB    |          | 83% utilized    |
+--------------------------------------------------------------+
```

#### Eviction Policies

```
EVICTION POLICIES:
+--------------------------------------------------------------+
|  Policy              | Behavior                | Use When       |
+--------------------------------------------------------------+
|  noeviction          | Return error on full    | Primary store  |
|  allkeys-lru         | Evict least recently    | General cache  |
|                      | used from ALL keys      | (most common)  |
|  volatile-lru        | LRU only among keys     | Mix of cache   |
|                      | with TTL set            | + persistent   |
|  allkeys-lfu         | Evict least frequently  | Popularity-    |
|                      | used from ALL keys      | based cache    |
|  volatile-lfu        | LFU only among keys     | Mix + frequency|
|                      | with TTL set            |                |
|  allkeys-random      | Random eviction         | Uniform access |
|  volatile-random     | Random among TTL keys   | Uniform + mix  |
|  volatile-ttl        | Evict keys with nearest | Short-lived    |
|                      | TTL first               | data preferred |
+--------------------------------------------------------------+

RECOMMENDATION:
- Cache only:       allkeys-lfu (best hit rate for most workloads)
- Cache + data:     volatile-lfu (only evict keys with TTL)
- Session store:    volatile-ttl (expire oldest sessions first)
- Primary store:    noeviction (never lose data silently)

CONFIGURATION:
maxmemory 6gb
maxmemory-policy allkeys-lfu
maxmemory-samples 10          # Higher = more accurate LRU/LFU, more CPU
```

### Step 7: Lua Scripting and Redis Functions

#### Lua Scripting
```lua
-- Atomic rate limiter (sliding window)
-- KEYS[1] = rate limit key
-- ARGV[1] = window size in ms
-- ARGV[2] = max requests
-- ARGV[3] = current timestamp in ms
-- ARGV[4] = unique request ID

local key = KEYS[1]
local window = tonumber(ARGV[1])
local limit = tonumber(ARGV[2])
local now = tonumber(ARGV[3])
local request_id = ARGV[4]

-- Remove expired entries
redis.call('ZREMRANGEBYSCORE', key, 0, now - window)

-- Count current entries
local current = redis.call('ZCARD', key)

if current < limit then
    -- Under limit: add request and allow
    redis.call('ZADD', key, now, request_id)
    redis.call('PEXPIRE', key, window)
    return {1, limit - current - 1}  -- allowed, remaining
else
    -- Over limit: reject
    local oldest = redis.call('ZRANGE', key, 0, 0, 'WITHSCORES')
    local retry_after = window - (now - tonumber(oldest[2]))
    return {0, retry_after}  -- denied, retry after ms
end
```

```bash
# Execute Lua script
redis-cli EVAL "$(cat rate_limit.lua)" 1 "rate:user:1234" 60000 100 1705334400000 "req-uuid"

# Cache script for reuse (EVALSHA is faster than EVAL)
redis-cli SCRIPT LOAD "$(cat rate_limit.lua)"
# Returns SHA1 hash
redis-cli EVALSHA <sha1> 1 "rate:user:1234" 60000 100 1705334400000 "req-uuid"
```

#### Redis Functions (Redis 7+)
```lua
-- Register a function library
#!lua name=mylib

-- Atomic distributed lock with fencing token
redis.register_function('acquire_lock', function(keys, args)
    local lock_key = keys[1]
    local owner = args[1]
    local ttl_ms = tonumber(args[2])

    local current = redis.call('GET', lock_key)
    if current == false then
        redis.call('SET', lock_key, owner, 'PX', ttl_ms)
        local token = redis.call('INCR', lock_key .. ':token')
        return {1, token}  -- acquired, fencing token
    elseif current == owner then
        redis.call('PEXPIRE', lock_key, ttl_ms)  -- extend
        local token = redis.call('GET', lock_key .. ':token')
        return {1, tonumber(token)}  -- extended, same token
    else
        return {0, 0}  -- not acquired
    end
end)

redis.register_function('release_lock', function(keys, args)
    local lock_key = keys[1]
    local owner = args[1]

    local current = redis.call('GET', lock_key)
    if current == owner then
        redis.call('DEL', lock_key)
        return 1  -- released
    end
    return 0  -- not owner
end)
```

```bash
# Load function library
cat mylib.lua | redis-cli -x FUNCTION LOAD REPLACE

# Call function
redis-cli FCALL acquire_lock 1 "lock:order:123" "worker-uuid" 30000
redis-cli FCALL release_lock 1 "lock:order:123" "worker-uuid"

# List loaded functions
redis-cli FUNCTION LIST

# Functions vs Lua scripts:
# Functions: Named, persistent across restarts, library-based, Redis 7+
# Scripts:   Anonymous (SHA-based), lost on restart, EVAL/EVALSHA
# Prefer Functions for production; use scripts for one-off operations
```

### Step 8: Common Redis Patterns

#### Rate Limiter
```
SLIDING WINDOW RATE LIMITER (Sorted Set):
  Key:    rate:<resource>:<identifier>
  Score:  timestamp (ms)
  Member: unique request ID

  1. ZREMRANGEBYSCORE -- remove expired entries
  2. ZCARD -- count current window
  3. If under limit: ZADD + PEXPIRE
  4. If over limit: return retry-after

  Use Lua script for atomicity (see Step 7)

FIXED WINDOW (simpler, less accurate):
  Key:    rate:<resource>:<identifier>:<window>
  INCR rate:api:user:1234:2025-01-15T10
  EXPIRE rate:api:user:1234:2025-01-15T10 60
  -- Check if count > limit

TOKEN BUCKET (smooth rate):
  Use sorted set with refill logic in Lua
  Smoother than fixed window, handles bursts better
```

#### Distributed Lock (Redlock)
```
SINGLE-NODE LOCK:
  SET lock:<resource> <owner-uuid> NX EX 30
  -- NX = only set if not exists
  -- EX 30 = auto-expire after 30s (prevents deadlock)

  -- Release (must verify ownership):
  if redis.call("GET", KEYS[1]) == ARGV[1] then
      return redis.call("DEL", KEYS[1])
  end
  -- Use Lua to make GET+DEL atomic

REDLOCK (multi-node):
  For when single Redis node is not reliable enough:
  1. Acquire lock on N/2+1 out of N independent Redis nodes
  2. Must acquire all within lock TTL
  3. Use fencing tokens for correctness

  WARNING: Redlock is controversial. For most applications,
  a single-node lock with proper TTL is sufficient.
  For strong correctness, use Zookeeper/etcd instead.
```

#### Leaderboard
```
LEADERBOARD:
  # Add/update score
  ZADD lb:game:weekly <score> <player_id>

  # Top 10
  ZREVRANGE lb:game:weekly 0 9 WITHSCORES

  # Player rank (0-indexed)
  ZREVRANK lb:game:weekly <player_id>

  # Player score
  ZSCORE lb:game:weekly <player_id>

  # Players around a specific rank (contextual leaderboard)
  ZREVRANGE lb:game:weekly <rank-5> <rank+5> WITHSCORES

  # Weekly reset
  RENAME lb:game:weekly lb:game:weekly:archive:<week>
  -- Or just DEL and recreate
```

### Step 9: Persistence and Durability

```
PERSISTENCE OPTIONS:
+--------------------------------------------------------------+
|  Option  | How                      | Trade-off               |
+--------------------------------------------------------------+
|  None    | No persistence           | Fastest, data loss risk |
|  RDB     | Point-in-time snapshots  | Good perf, up to N min  |
|          | at intervals             | of data loss            |
|  AOF     | Append every write to    | Durable, larger files   |
|          | log file                 | slower restart          |
|  RDB+AOF | Both (recommended)       | Best of both            |
+--------------------------------------------------------------+

RDB CONFIGURATION:
save 900 1       # Snapshot after 900s if >= 1 key changed
save 300 10      # Snapshot after 300s if >= 10 keys changed
save 60 10000    # Snapshot after 60s if >= 10000 keys changed
rdbcompression yes
rdbchecksum yes

AOF CONFIGURATION:
appendonly yes
appendfsync everysec   # fsync every second (good balance)
  # always:   fsync every write (safest, slowest)
  # everysec: fsync every second (recommended)
  # no:       OS decides when to fsync (fastest, risk)

auto-aof-rewrite-percentage 100  # Rewrite when AOF doubles in size
auto-aof-rewrite-min-size 64mb   # Minimum size before considering rewrite

RECOMMENDATION:
- Cache only:     RDB (or no persistence)
- Session store:  AOF (everysec)
- Primary store:  RDB + AOF
- Queue/Stream:   AOF (everysec) + replication
```

### Step 10: Report and Transition

```
+------------------------------------------------------------+
|  REDIS ARCHITECTURE -- <description>                        |
+------------------------------------------------------------+
|  Version:         <version>                                 |
|  Deployment:      <Standalone | Sentinel | Cluster>         |
|  Memory:          <used> / <maxmemory>                      |
|  Eviction:        <policy>                                  |
+------------------------------------------------------------+
|  Data structures used:                                      |
|  - <structure>: <use case> (<key pattern>)                  |
|  - <structure>: <use case> (<key pattern>)                  |
|                                                             |
|  Patterns implemented:                                      |
|  - <pattern>: <description>                                 |
|                                                             |
|  Performance:                                               |
|  - Ops/sec:    <throughput>                                  |
|  - Latency:    <p50>ms / <p99>ms                            |
|  - Hit rate:   <pct>                                        |
+------------------------------------------------------------+
```

Commit: `"redis: <description> -- <key outcome>"`

## Key Behaviors

1. **Choose the right data structure.** Redis has 10+ data structures. Using the wrong one (e.g., String for a leaderboard instead of Sorted Set) wastes memory and makes operations harder.
2. **Always set TTL.** Data without TTL grows forever until maxmemory eviction kicks in. Explicit TTL on every key is a hygiene requirement.
3. **Use pipelining for batch operations.** Sending 100 commands one at a time takes 100 round trips. Pipeline them into one round trip.
4. **Avoid O(N) commands on large collections.** KEYS *, SMEMBERS on a 1M-member set, HGETALL on a 10K-field hash. Use SCAN, SSCAN, HSCAN for iteration.
5. **Use Lua/Functions for atomicity.** Multi-step operations (check-and-set, rate limiting) must be atomic. Lua scripts execute on the server without interleaving.
6. **Hash tags for multi-key operations in Cluster.** MGET, transactions, and Lua scripts require all keys on the same node. Use {hash-tag} in key names.
7. **Sentinel for HA, Cluster for scaling.** If data fits in one node, use Sentinel for failover. If data exceeds one node or you need > 100K ops/sec, use Cluster.
8. **Monitor memory fragmentation.** mem_fragmentation_ratio > 1.5 indicates fragmentation. Use MEMORY PURGE or restart Redis to reclaim.
9. **Never use KEYS in production.** KEYS blocks the entire Redis instance. Use SCAN with COUNT hint instead.
10. **Streams over Pub/Sub for reliability.** Pub/Sub is fire-and-forget. Streams persist messages, support consumer groups, acknowledgment, and replay.

## Example Usage

### Designing a caching layer
```
User: /godmode:redis Design a caching strategy for our API

Redis: Assessing use case...

REDIS CONTEXT:
  Version: Redis 7, ElastiCache
  Role: API response cache
  Throughput: 5K req/sec, 80% read

CACHE DESIGN:
  Strategy: Cache-aside with stampede prevention
  Key pattern: cache:api:<endpoint>:<hash(params)>
  TTL: 300s (5 min) with probabilistic early refresh
  Eviction: allkeys-lfu (best hit rate)

  Data structures:
  - String: cached JSON responses (SET + EX)
  - Sorted Set: cache key index by last access (for warm-up)

  Stampede prevention: Distributed lock on cache miss
  Invalidation: Event-based DELETE on write + TTL fallback

  Expected hit rate: > 95%
  Memory estimate: 2.1 GB for 500K cached responses
```

### Setting up Redis Cluster
```
User: /godmode:redis We need to scale Redis beyond 32GB

Redis: Designing cluster...

CLUSTER DESIGN:
  6 nodes: 3 masters + 3 replicas
  Hash slots: 16384 evenly distributed
  Memory per node: 16GB (total effective: 48GB)

  Hash tags for related keys:
  - {user:1234}:profile, {user:1234}:sessions
  - {order:5678}:data, {order:5678}:items

  Client: ioredis Cluster mode with scaleReads: 'slave'
  Persistence: RDB + AOF on all nodes
```

### Implementing a rate limiter
```
User: /godmode:redis Build a rate limiter: 100 req/min per user

Redis: Implementing sliding window...

RATE LIMITER:
  Data structure: Sorted Set
  Key: rate:api:<user_id>
  Score: timestamp (ms)
  Member: request UUID
  Window: 60000ms, Limit: 100

  Lua script for atomicity (ZREMRANGEBYSCORE + ZCARD + ZADD)
  Returns: {allowed: bool, remaining: int, retry_after_ms: int}

  Response headers:
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: <N>
  X-RateLimit-Reset: <epoch>
  Retry-After: <seconds> (on 429)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive Redis architecture workflow |
| `--cache` | Design a caching strategy with invalidation |
| `--queue` | Design a reliable queue with Redis Lists or Streams |
| `--pubsub` | Configure pub/sub or Streams for messaging |
| `--session` | Design a session store with Redis Hashes |
| `--rate-limit` | Implement rate limiting with sliding window |
| `--leaderboard` | Design a leaderboard with Sorted Sets |
| `--cluster` | Set up Redis Cluster for horizontal scaling |
| `--sentinel` | Configure Redis Sentinel for high availability |
| `--memory` | Analyze and optimize memory usage |
| `--lua` | Write Lua scripts or Redis Functions |
| `--lock` | Implement distributed locking |
| `--streams` | Design event streaming with Redis Streams |
| `--diagnose` | Run full Redis diagnostic (memory, slowlog, info) |
| `--persistence` | Configure RDB/AOF persistence |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check package.json/requirements.txt/go.mod for redis client (ioredis, redis, redis-py, go-redis)
2. Check docker-compose.yml / docker-compose.yaml for redis service definition
3. Detect Redis connection config: grep for REDIS_URL, REDIS_HOST, redis://, rediss://
4. Check for existing caching layer: grep for cache.get, cache.set, cacheManager
5. Detect usage patterns: pub/sub (subscribe, publish), streams (XADD, XREAD), queues (BRPOP, LPUSH)
6. Check for Redis Sentinel/Cluster config: sentinel.conf, cluster-enabled
7. Scan for rate limiting middleware: grep for rateLimit, slidingWindow, tokenBucket
```

## Iterative Implementation Loop

```
current_iteration = 0
max_iterations = 10
redis_tasks = [list of Redis features to implement/optimize]

WHILE redis_tasks is not empty AND current_iteration < max_iterations:
    task = redis_tasks.pop(0)
    1. Analyze current data access pattern for this feature
    2. Choose optimal Redis data structure (String, Hash, Set, Sorted Set, Stream, etc.)
    3. Implement with proper key naming: {service}:{entity}:{id}:{field}
    4. Set TTL on every cache key (no immortal keys)
    5. Add error handling for Redis unavailability (degrade gracefully)
    6. Test: verify data correctness, TTL expiry, memory usage
    7. Benchmark: redis-benchmark or custom load test for this pattern
    8. IF performance target missed → optimize (pipeline, Lua script, structure change)
    9. IF passing → commit: "redis: implement <feature> (<data structure>)"
    10. current_iteration += 1

POST-LOOP: Run INFO memory, check fragmentation ratio, verify maxmemory policy
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "redis-cache": caching layer, invalidation, TTL policies
  Agent 2 — "redis-data": queues, pub/sub, streams, rate limiting
  Agent 3 — "redis-ops": Sentinel/Cluster config, monitoring, persistence settings

MERGE ORDER: ops (infra) → data (core) → cache (application layer)
CONFLICT ZONES: connection config, key namespace conventions (agree on prefix schema first)
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
7. EVERY Lua script must be idempotent. Scripts may be retried on MOVED errors in Cluster mode.
8. EVERY key must follow the naming convention: {service}:{entity}:{id}[:{field}].
9. NEVER run O(N) commands on large collections without SCAN or pagination.
10. ALWAYS set maxmemory and maxmemory-policy. An unbounded Redis is a ticking bomb.
```

## Anti-Patterns

- **Do NOT use KEYS in production.** KEYS * blocks the entire Redis instance (single-threaded). Use SCAN with a cursor and COUNT hint.
- **Do NOT store large values (> 100KB).** Large values block Redis during serialization. Compress before storing, or split into smaller keys.
- **Do NOT use Redis as a primary database without persistence.** If Redis restarts without RDB/AOF, all data is lost. Enable persistence for any data you cannot regenerate.
- **Do NOT forget TTL on cache keys.** Keys without TTL accumulate until maxmemory forces eviction, which may evict important keys instead.
- **Do NOT use SELECT (multiple databases).** Redis databases (0-15) share the same memory and single thread. Use key prefixes for namespacing instead.
- **Do NOT use Pub/Sub for reliable messaging.** Pub/Sub is fire-and-forget. If a subscriber is down, messages are lost. Use Streams for reliable delivery.
- **Do NOT run O(N) commands on large collections without understanding the cost.** LRANGE 0 -1 on a 1M-element list, SMEMBERS on a 500K set, HGETALL on a 50K-field hash -- all block Redis.
- **Do NOT use Redis transactions (MULTI/EXEC) expecting rollback.** Redis transactions are not atomic in the ACID sense. All commands execute sequentially, but if one fails, the others still run. Use Lua for true atomicity.
- **Do NOT ignore memory fragmentation.** mem_fragmentation_ratio > 1.5 wastes 50%+ of allocated memory. Monitor and address with MEMORY PURGE or jemalloc tuning.
- **Do NOT connect directly from many application instances.** Use connection pooling in your client library. Each Redis connection has overhead, and max_clients has a limit.
