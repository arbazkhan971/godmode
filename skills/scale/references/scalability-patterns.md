# Scalability Patterns Reference

Comprehensive guide to horizontal scaling, database sharding, caching strategies, CDN architecture, and connection optimization for high-throughput systems.

---

## Table of Contents

1. [Horizontal Scaling Patterns](#horizontal-scaling-patterns)
2. [Database Sharding Strategies](#database-sharding-strategies)
3. [Caching Strategies](#caching-strategies)
4. [CDN Architecture Patterns](#cdn-architecture-patterns)
5. [Connection Pooling and Optimization](#connection-pooling-and-optimization)
6. [Data Partitioning](#data-partitioning)
7. [Read Replicas](#read-replicas)
8. [Async Processing](#async-processing)
9. [Auto-Scaling](#auto-scaling)
10. [Capacity Planning](#capacity-planning)

---

## Horizontal Scaling Patterns

### Vertical vs Horizontal Scaling

```
  Vertical vs Horizontal Scaling
  VERTICAL (Scale Up):           HORIZONTAL (Scale Out):
|  |  |  | S1 |  | S2 |  | S3 |  |
|  |  | └────┘ └────┘ └────┘ |
|  | BIGGER |  |
|  | SERVER | ┌────┐ ┌────┐ ┌────┐ |
|  |  | ──▶ | S4 |  | S5 |  | S6 |  |
|  | 64 CPU | └────┘ └────┘ └────┘ |
|  | 512 GB RAM |  |
|  | 10 TB SSD | ┌────┐ ┌────┐ ┌────┐ |
|  |  |  | S7 |  | S8 |  | S9 |  |
|  | Aspect | Vertical | Horizontal |  |
|  | Complexity | Low | High |  |
|  | Cost | Expensive HW | Commodity HW |  |
|  | Limit | Hardware cap | Near-infinite |  |
|  | Downtime | Yes (upgrade) | No (add nodes) |  |
|  | Fault tolerance | SPOF | Redundant |  |
|  | Data consistency | Simple | Complex |  |
|  | Session mgmt | Simple | External store |  |
```

### Stateless Service Scaling

```
  Stateless Horizontal Scaling
  Requirement: No local state in application servers
|  | Load Balancer |  |
  ┌──────▼──────┐ ┌──▼──────────┐ ┌▼────────────┐
|  | App Srv 1 |  | App Srv 2 |  | App Srv 3 |  |
|  | (stateless) |  | (stateless) |  | (stateless) |  |
  └──────┬──────┘ └──┬──────────┘ └┬────────────┘
  ┌──────▼──────┐ ┌─────▼──────┐ ┌──────▼──────┐
|  | Session |  | Database |  | File |  |
|  | Store |  | Cluster |  | Storage |  |
|  | (Redis) |  | (MySQL) |  | (S3) |  |
  State externalized to:
  - Sessions → Redis / JWT
  - Data → Database
  - Files → Object storage
  - Cache → Distributed cache
  - Config → Config server / env vars
  Any request can go to any server.
  Servers are interchangeable.
```

### Stateful Service Scaling

```
  Stateful Horizontal Scaling
  When state MUST live on the server (WebSocket, caches):
  Strategy 1: Sticky Sessions
|  | Load Balancer | route by: IP hash, cookie, header |
  User A ──▶ always goes to Server 1
  User B ──▶ always goes to Server 2
  User C ──▶ always goes to Server 3
  Problem: uneven distribution, failover loses state
  Strategy 2: Consistent Hashing (preferred)
|  | Hash Ring |  |
|  | User_123 → hash → Node B |  |
|  | User_456 → hash → Node A |  |
|  | User_789 → hash → Node C |  |
|  | Node failure: only affected users move |  |
|  | Node addition: minimal redistribution |  |
  Strategy 3: State Replication
|  | Each node replicates state to N peers |  |
|  | Node A ←sync→ Node B ←sync→ Node C |  |
|  | Failover: peer takes over |  |
|  | Cost: replication overhead |  |
```

### Database Scaling Patterns Overview

```
  Database Scaling Progression
  Stage 1: Single Server
|  | App + DB | capacity: ~1K QPS |
  ▼
  Stage 2: Read Replicas
|  | Primary | ──▶ | Replica |  | Replica | capacity: ~5K QPS |
|  | (writes) |  | (reads) |  | (reads) |  |
  ▼
  Stage 3: Caching Layer
|  | Primary |  | Replicas |  | Redis | capacity: ~50K QPS |
| └────────┘   └────────┘ | Cache |  |
  ▼
  Stage 4: Vertical Partitioning (by table/feature)
|  | Users |  | Orders |  | Products | capacity: ~100K QPS |
|  | DB |  | DB |  | DB |  |
  ▼
  Stage 5: Horizontal Sharding
|  | Shard |  | Shard |  | Shard |  | Shard | capacity: ~1M+ QPS |
|  | 0 |  | 1 |  | 2 |  | 3 |  |
```

---

## Database Sharding Strategies

### Hash-Based Sharding

```
  Hash-Based Sharding
  shard_id = hash(shard_key) % num_shards
  Example: shard_key = user_id
  hash("user_001") % 4 = 2  →  Shard 2
  hash("user_002") % 4 = 0  →  Shard 0
  hash("user_003") % 4 = 3  →  Shard 3
  hash("user_004") % 4 = 1  →  Shard 1
|  | Shard 0 |  | Shard 1 |  | Shard 2 |  | Shard 3 |  |
|  | user_002 |  | user_004 |  | user_001 |  | user_003 |  |
|  | user_006 |  | user_008 |  | user_005 |  | user_007 |  |
  Pros:
  ✓ Even distribution (good hash function)
  ✓ Simple to implement
  ✓ Any shard key works
  Cons:
  ✗ Resharding is expensive (all data moves)
  ✗ Range queries across shards impossible
  ✗ Hot spots if shard key has skewed access
  Consistent Hashing Alternative:
  shard = consistent_hash(key) → virtual node → physical node
  Adding shard: only K/N keys move (not all)
```

### Range-Based Sharding

```
  Range-Based Sharding
  Partition data by key ranges:
|  | Shard 0 |  | Shard 1 |  |
|  | user_id: A-F |  | user_id: G-L |  |
|  | 150K users |  | 180K users |  |
|  | Shard 2 |  | Shard 3 |  |
|  | user_id: M-R |  | user_id: S-Z |  |
|  | 200K users |  | 170K users |  |
  Time-based range (logs, events):
|  | Jan 2024 |  | Feb 2024 |  | Mar 2024 |  | Apr 2024 |  |
|  | (cold) |  | (cold) |  | (warm) |  | (hot) |  |
  Pros:
  ✓ Range queries efficient (single shard)
  ✓ Easy to understand and manage
  ✓ Natural for time-series data
  ✓ Easy to archive old shards
  Cons:
  ✗ Uneven distribution (some ranges are denser)
  ✗ Hot spots (latest time range gets all writes)
  ✗ Requires monitoring and rebalancing
```

### Geographic Sharding

```
  Geographic Sharding
  Route data to geographically closest shard:
|  | Global Router |  |
|  | (GeoDNS / App-level) |  |
  ┌──────▼──────┐ ┌───▼─────────┐ ┌▼────────────┐
|  | US Shard |  | EU Shard |  | APAC Shard |  |
|  | Region: |  | Region: |  | Region: |  |
|  | us-east-1 |  | eu-west-1 |  | ap-south-1 |  |
|  | Users: |  | Users: |  | Users: |  |
|  | Americas |  | Europe |  | Asia-Pac |  |
|  | 10M users |  | 8M users |  | 12M users |  |
  Routing Decision:
|  | Signal | Routing |  |
|  | User country | Registration-time assignment |  |
|  | IP geolocation | Runtime routing |  |
|  | User preference | Explicit selection |  |
|  | Phone prefix | +1 → US, +44 → EU |  |
  Pros:
  ✓ Low latency (data near users)
  ✓ Data residency compliance (GDPR, sovereignty)
  ✓ Natural failure isolation
  Cons:
  ✗ Cross-region queries are expensive
  ✗ Traveling users hit remote shard
  ✗ Global aggregations require scatter-gather
  ✗ Uneven geographic distribution
```

### Shard Key Selection Guide

```
  Shard Key Selection
  Good Shard Keys:
|  | Domain | Shard Key |  |
|  | Social network | user_id (user data co-located) |  |
|  | E-commerce | customer_id (orders + profile) |  |
|  | Multi-tenant | tenant_id (full isolation) |  |
|  | IoT | device_id + time_bucket |  |
|  | Chat | conversation_id (messages together) |  |
|  | Gaming | game_region_id |  |
  Shard Key Properties Checklist:
  [✓] High cardinality (many distinct values)
  [✓] Even distribution (avoids hot spots)
  [✓] Frequently used in queries (avoids scatter)
  [✓] Immutable (changing key = moving data)
  [✓] Aligns with access patterns
  Anti-patterns:
  [✗] Low cardinality (e.g., country: only ~200 values)
  [✗] Monotonically increasing (auto-increment → all hot)
  [✗] Frequently changing (email, status)
  [✗] Null values (where do nulls go?)
```

### Cross-Shard Operations

```
  Cross-Shard Query Patterns
  Problem: query needs data from multiple shards
  Pattern 1: Scatter-Gather
|  | Coordinator |  |
|  | 1. Send query to ALL shards |  |
|  | 2. Each shard returns partial results |  |
|  | 3. Coordinator merges results |  |
|  | Coordinator |  |
|  | ├──query──▶ Shard 0 ──▶ [partial] |  |
|  | ├──query──▶ Shard 1 ──▶ [partial] |  |
|  | ├──query──▶ Shard 2 ──▶ [partial] |  |
|  | └──merge results ──▶ [final] |  |
|  | Cost: O(num_shards) per query |  |
  Pattern 2: Global Index
|  | Maintain a separate global index: |  |
|  | Global Index (Elasticsearch): |  |
|  | email:alice@example.com → shard_2, user_123 |  |
|  | 1. Query global index → get shard + key |  |
|  | 2. Query specific shard only |  |
|  | Cost: additional storage + sync overhead |  |
  Pattern 3: Denormalization / Data Duplication
|  | Store data redundantly so each shard has |  |
|  | what it needs: |  |
|  | Order shard: {order, user_name, product_name} |  |
|  | → No cross-shard JOINs needed |  |
|  | Cost: storage + consistency management |  |
```

---

## Caching Strategies

### Cache-Aside (Lazy Loading)

```
  Cache-Aside Pattern
  READ:
  ┌─────┐   1.get   ┌───────┐
|  | App | ──────────▶ | Cache |  |
|  |  | ◀────────── |  |  |
|  |  | 2a.hit   └───────┘ |
|  |  | (return cached value) |
|  |  | 2b.miss |
|  |  | ──────────▶┌───────┐ |
|  |  | 3.query | DB |  |
|  |  | ◀────────── |  |  |
|  |  | 4.result └───────┘ |
|  |  | ──────────▶┌───────┐ |
|  |  | 5.set | Cache |  |
  WRITE:
  ┌─────┐  1.write  ┌───────┐
|  | App | ──────────▶ | DB |  |
|  |  | └───────┘ |
|  |  | 2.invalidate |
|  |  | ──────────▶┌───────┐ |
|  |  | (delete) | Cache |  |
  Pros: Only requested data cached, app controls logic
  Cons: Cache miss penalty, stale data between invalidations
  Best for: General purpose, read-heavy workloads
```

### Read-Through

```
  Read-Through Pattern
  ┌─────┐   1.get   ┌───────┐   2.miss   ┌───────┐
|  | App | ──────────▶ | Cache | ───────────▶ | DB |  |
|  |  | ◀────────── |  | ◀─────────── |  |  |
|  |  | 3.return | (auto | (auto |  |  |
| └─────┘ | load) | fetch)   └───────┘ |
  Cache itself fetches from DB on miss.
  App only talks to cache — never directly to DB for reads.
  Pros: Simpler app code, cache handles loading
  Cons: First request always slow, cache must know DB schema
  Best for: ORM-level caching, CDN origin fetch
  Implementation: cache configured with a "loader" function
  cache.get(key, loader=lambda k: db.query(k))
```

### Write-Through

```
  Write-Through Pattern
  ┌─────┐  1.write  ┌───────┐  2.write  ┌───────┐
|  | App | ──────────▶ | Cache | ──────────▶ | DB |  |
|  |  | ◀────────── |  | ◀────────── |  |  |
|  |  | 3.ack | (sync) | (sync) |  |  |
  Every write goes through cache to DB (synchronous).
  Cache is always consistent with DB.
  Pros: Cache always fresh, no stale reads
  Cons: Write latency (cache + DB), unused data cached
  Best for: Strong consistency requirements
  Often paired with Read-Through:
  Read → cache (auto-load from DB on miss)
  Write → cache → DB (synchronous)
  = Cache is always the source of truth for reads
```

### Write-Behind (Write-Back)

```
  Write-Behind Pattern
  ┌─────┐  1.write  ┌───────┐
|  | App | ──────────▶ | Cache | ← immediate ack |
|  |  | ◀────────── |  |  |
|  |  | 2.ack |  |  |
  └─────┘           └───┬───┘
  (async batch flush)
  ┌────▼────┐
|  | DB | ← delayed write |
  Writes buffered in cache, flushed to DB asynchronously.
  Flush strategies:
|  | Strategy | Mechanism |  |
|  | Time-based | Flush every N seconds |  |
|  | Count-based | Flush every N writes |  |
|  | Size-based | Flush when buffer > N MB |  |
|  | Hybrid | Whichever threshold hit first |  |
  Pros: Very fast writes, batch optimization, absorbs spikes
  Cons: Data loss risk (cache crash before flush), complexity
  Best for: Write-heavy workloads, analytics, counters
  Data loss mitigation:
  - Redis AOF persistence
  - Write-ahead log in cache
  - Replicated cache cluster
```

### Cache Invalidation Strategies

```
  Cache Invalidation Strategies
  "There are only two hard things in CS:
  cache invalidation and naming things." — Phil Karlton
  Strategy 1: TTL (Time-To-Live)
  SET key value EX 300   (expire in 5 minutes)
  Pros: Simple, automatic cleanup
  Cons: Stale data until expiry
  Strategy 2: Event-Driven Invalidation
  On DB change → publish event → subscriber deletes cache key
  Pros: Near real-time freshness
  Cons: Infrastructure complexity, race conditions
  Strategy 3: Version-Based
  Key: "user:123:v5"
  On update: increment version counter
  Old cached data naturally ignored (new key)
  Pros: No explicit invalidation needed
  Cons: Orphaned old entries (rely on TTL cleanup)
  Strategy 4: Write-Invalidate
  On write to DB: immediately DELETE cache key
  Next read: cache miss → load from DB → populate cache
  Pros: Simple, strong consistency after invalidation
  Cons: Thundering herd on popular keys
  Strategy 5: Write-Update
  On write to DB: also SET new value in cache
  Pros: No cache miss after write
  Cons: Race condition if concurrent writes
  Thundering Herd Protection:
|  | Problem: popular key expires → 1000 |  |
|  | concurrent requests hit DB |  |
|  | Solution 1: Lock/Mutex |  |
|  | First request acquires lock, loads DB |  |
|  | Others wait for cache to be populated |  |
|  | Solution 2: Stale-While-Revalidate |  |
|  | Serve stale data, refresh in background |  |
|  | TTL=300s, soft_ttl=240s |  |
|  | After 240s: serve stale + async refresh |  |
|  | After 300s: hard miss (lock + refresh) |  |
|  | Solution 3: Probabilistic Early Expiry |  |
|  | Each request has small chance of |  |
|  | refreshing before TTL |  |
```

### Multi-Level Cache

```
  Multi-Level Cache Architecture
|  | App | ──▶ | L1: In-Process | ──▶ | L2: Distrib. | ─▶ | L3: DB |  |
|  |  | ◀── | Cache | ◀── | Cache (Redis) | ◀─ |  |  |
  L1: In-Process (Caffeine, Guava)
|  | Location:   Same JVM / process |  |
|  | Latency:    ~1 microsecond |  |
|  | Size:       100MB - 1GB |  |
|  | TTL:        30s - 5min (short) |  |
|  | Scope:      Per-instance (not shared) |  |
|  | Eviction:   LRU, LFU, size-based |  |
|  | Use case:   Hot data, config, reference |  |
  L2: Distributed Cache (Redis, Memcached)
|  | Location:   Network (same region) |  |
|  | Latency:    ~1 millisecond |  |
|  | Size:       10GB - 1TB (cluster) |  |
|  | TTL:        5min - 1hr |  |
|  | Scope:      Shared across all instances |  |
|  | Eviction:   LRU + maxmemory policy |  |
|  | Use case:   Session, user data, API results |  |
  L3: Database (source of truth)
|  | Location:   Persistent storage |  |
|  | Latency:    5-50 milliseconds |  |
|  | Size:       Unlimited |  |
|  | Use case:   Authoritative data |  |
  Hit rate target by level:
  L1: 60-80% (frequent items)
  L2: 15-30% (less frequent)
  L3: 5-10% (cache misses)
  Overall: >95%
```

### Caching Strategy Selection

```
| Pattern | Best For | Consistency |
| Cache-Aside | General | Eventual (TTL-based) |
| Read-Through | Read-heavy | Eventual (auto-load) |
| Write-Through | Consistency | Strong (sync write) |
| Write-Behind | Write-heavy | Eventual (async flush) |
| Refresh-Ahead | Predictable | Near real-time |
```

---

## CDN Architecture Patterns

### CDN Request Flow

```
  CDN Request Flow
  User (Tokyo) requests: cdn.example.com/image.jpg
  1. DNS Resolution
  cdn.example.com → GeoDNS → nearest PoP IP
  (Tokyo edge: 203.0.113.50)
  2. Edge Cache Check
|  | Tokyo Edge PoP |  |
|  | Cache HIT? |  |
|  | ├── YES → return | ──▶ User (latency: 5ms) |
|  | └── NO → step 3 |  |
  3. Mid-Tier Cache (Regional Shield)
|  | APAC Shield |  |
|  | (Singapore) |  |
|  | Cache HIT? |  |
|  | ├── YES → return | ──▶ Edge → User (latency: 30ms) |
|  | └── NO → step 4 |  |
  4. Origin Fetch
|  | Origin Server |  |
|  | (US-East) |  |
|  | Return response | ──▶ Shield → Edge → User |
|  | + cache headers | (latency: 200ms, cached for next) |
  Cache-Control headers from origin:
  Cache-Control: public, max-age=86400, s-maxage=31536000
  ETag: "abc123"
  Vary: Accept-Encoding
```

### Static vs Dynamic CDN

```
  Static vs Dynamic Content CDN
  STATIC CONTENT:
|  | Images, CSS, JS, fonts, videos |  |
|  | Cache-Control: max-age=31536000 (1 year) |  |
|  | Versioned URLs: /assets/style.a1b2c3.css |  |
|  | CDN caches indefinitely, busted by URL change |  |
|  | Hit ratio: >99% |  |
  DYNAMIC CONTENT:
|  | API responses, personalized pages |  |
|  | Strategy 1: Edge compute (Cloudflare Workers) |  |
|  | Strategy 2: Short TTL (5-60s) + SWR |  |
|  | Strategy 3: Cache by segment (country, lang) |  |
|  | Strategy 4: ESI (Edge Side Includes) |  |
|  | Hit ratio: 30-70% |  |
  EDGE SIDE INCLUDES (ESI):
|  | Page template (cached): |  |
|  | <html> |  |
|  | <header>...</header> |  |
|  | <esi:include src="/api/user/cart"/> |  |
|  | ← dynamic fragment, fetched at edge |  |
|  | <footer>...</footer> |  |
|  | </html> |  |
|  | Cache static shell, fetch dynamic fragments |  |
```

### Multi-CDN Architecture

```
  Multi-CDN Architecture
  Use multiple CDN providers for resilience and performance:
|  | DNS / Traffic |  |
|  | Manager |  |
|  | (Cedexis/NS1) |  |
  ┌────▼────┐ ┌────▼────┐ ┌───▼─────┐
|  | CDN A |  | CDN B |  | CDN C |  |
|  | (Cloud |  | (Akamai) |  | (Fast |  |
|  | Front) |  |  |  | ly) |  |
  Routing Strategies:
|  | Strategy | Mechanism |  |
|  | Performance-based | Route to fastest CDN per region |  |
|  | Cost-based | Cheapest CDN for each region |  |
|  | Availability-based | Failover on CDN outage |  |
|  | Content-based | Video→CDN A, images→CDN B |  |
|  | Weighted | 60% CDN A, 40% CDN B |  |
```

---

## Connection Pooling and Optimization

### Database Connection Pooling

```
  Database Connection Pool
  WITHOUT POOL:
|  | Request → open connection → query → |  |
|  | close connection |  |
|  | Cost per request: |  |
|  | TCP handshake:    ~1ms |  |
|  | TLS handshake:    ~5ms |  |
|  | Auth:             ~2ms |  |
|  | Query:            ~3ms |  |
|  | Close:            ~1ms |  |
|  | Total:           ~12ms |  |
  WITH POOL:
|  | Request → borrow from pool → query → |  |
|  | return to pool |  |
|  | Cost per request: |  |
|  | Borrow:           ~0.01ms |  |
|  | Query:            ~3ms |  |
|  | Return:           ~0.01ms |  |
|  | Total:            ~3ms (75% faster) |  |
  Pool Architecture:
|  | Connection Pool (HikariCP / PgBouncer) |  |
|  | ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ |  |
|  |  | C1 |  | C2 |  | C3 |  | C4 |  | C5 |  |  |
|  |  | idle |  | busy |  | busy |  | idle |  | idle |  |  |
|  | └────┘ └────┘ └────┘ └────┘ └────┘ |  |
|  | min_size:      5 |  |
|  | max_size:      20 |  |
|  | idle_timeout:  300s |  |
|  | max_lifetime:  1800s |  |
|  | connection_timeout: 5s |  |
|  | validation_query: "SELECT 1" |  |
|  | leak_detection:  30s |  |
```

### Pool Sizing Formula

```
  Connection Pool Sizing
  Formula (PostgreSQL recommended):
  pool_size = (core_count * 2) + effective_spindle_count
  Example:
  4 CPU cores, SSD (1 spindle) = (4 * 2) + 1 = 9
  8 CPU cores, SSD             = (8 * 2) + 1 = 17
  General formula:
  pool_size = concurrent_requests * avg_query_time / avg_think_time
  Example:
  100 concurrent requests
  5ms avg query time
  50ms avg think time (app processing between queries)
  pool_size = 100 * 5 / 50 = 10 connections
  Multi-Instance Consideration:
|  | DB max_connections: 100 |  |
|  | App instances: 5 |  |
|  | Pool per instance: 100 / 5 = 20 |  |
|  | With safety margin: 100 / 5 * 0.8 = 16 |  |
|  | Reserve for admin/monitoring: 5 |  |
|  | Available: (100 - 5) / 5 = 19 |  |
  WARNING: More connections != more throughput
  10 connections can outperform 100 connections
  because less context switching and lock contention
```

### Connection Pool for External Services

```
  HTTP Connection Pool (to external APIs)
|  | HTTP Client Connection Pool |  |
|  | Per-Host Pool: |  |
|  | ┌───────────────┬──────┬──────────────────┐ |  |
|  |  | Host | Pool | Configuration |  |  |
|  | ├───────────────┼──────┼──────────────────┤ |  |
|  |  | api.stripe.com | 20 | keepalive=30s |  |  |
|  |  | api.twilio.com | 10 | keepalive=30s |  |  |
|  |  | svc-internal | 50 | keepalive=60s |  |  |
|  | └───────────────┴──────┴──────────────────┘ |  |
|  | Global Settings: |  |
|  | max_total_connections:    200 |  |
|  | max_per_host:             50 |  |
|  | connection_timeout:       5s |  |
|  | socket_timeout:           30s |  |
|  | keepalive_timeout:        60s |  |
|  | max_idle_connections:     100 |  |
|  | idle_timeout:             90s |  |
  HTTP/2 Multiplexing:
|  | HTTP/1.1: 1 request per connection at a time |  |
|  | ┌────┐ ┌────┐ ┌────┐ ┌────┐ |  |
|  |  | req1 |  | req2 |  | req3 |  | req4 | 4 connections |  |
|  | └────┘ └────┘ └────┘ └────┘ |  |
|  | HTTP/2: many requests per connection (streams) |  |
|  | ┌──────────────────────────────┐ |  |
|  |  | req1 req2 req3 req4 req5 ... | 1 connection |  |
|  |  | (multiplexed streams) |  |  |
|  | └──────────────────────────────┘ |  |
|  | Fewer connections needed with HTTP/2 |  |
```

### Connection Pooling with PgBouncer

```
  PgBouncer (External Connection Pooler)
  Problem: 100 app instances × 20 connections = 2000
  PostgreSQL max_connections: ~300 (practical limit)
  Solution: PgBouncer as connection multiplexer
|  | App 1 |  | App 2 |  | App N |  | PgBouncer |  |
|  | 20conn |  | 20conn |  | 20conn | ──────▶ |  |  |
| └──────┘ └──────┘ └──────┘  2000 | Pool: 50 |  |
| conns | connections |  |
|  | 50 real |
|  | connections |
  ┌──────▼───────┐
|  | PostgreSQL |  |
|  | (50 conns) |  |
  Pooling Modes:
|  | Mode | Description |  |
|  | Session | Conn assigned for session lifetime |  |
|  |  | (least benefit, most compatible) |  |
|  | Transaction | Conn assigned per transaction |  |
|  |  | (best balance of benefit/compat) |  |
|  | Statement | Conn assigned per statement |  |
|  |  | (most aggressive, breaks multi-stmt) |  |
```

---

## Data Partitioning

### Vertical Partitioning

```
  Vertical Partitioning
  Split tables by columns (features):
  BEFORE (monolithic table):
|  | users |  |
|  | ┌─────┬──────┬───────┬───────┬──────┬────────┐ |  |
|  |  | id | name | email | bio | avatar | prefs |  |  |
|  |  |  |  |  | (10KB) | (URL) | (JSON) |  |  |
|  | └─────┴──────┴───────┴───────┴──────┴────────┘ |  |
  AFTER (vertically partitioned):
|  | user_core (hot data) |  | user_profile |  |
|  | ┌─────┬──────┬───────┐ |  | (cold data) |  |
|  |  | id | name | email |  |  | ┌─────┬─────┬───┐ |  |
|  | └─────┴──────┴───────┘ |  |  | id | bio | ... |  |  |
|  | (small, fast, cached) |  | └─────┴─────┴───┘ |  |
| └─────────────────────────┘ | (large, infrequent) |  |
  Benefits:
  - Hot data fits in cache/memory better
  - Smaller row size = more rows per page = faster scans
  - Independent scaling for hot vs cold
```

### Horizontal Partitioning (Table Partitioning)

```
  Horizontal Partitioning (Native DB)
  PostgreSQL declarative partitioning:
  CREATE TABLE events (
  id          BIGINT,
  created_at  TIMESTAMP,
  event_type  TEXT,
  payload     JSONB
  ) PARTITION BY RANGE (created_at);
  CREATE TABLE events_2024_01
  PARTITION OF events
  FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
  CREATE TABLE events_2024_02
  PARTITION OF events
  FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');
|  | events |  | events |  | events |  |
|  | _2024_01 |  | _2024_02 |  | _2024_03 |  |
|  | 50M rows |  | 48M rows |  | 52M rows |  |
|  | (archived) |  | (cold) |  | (hot) |  |
  Benefits:
  - Partition pruning: queries on date only scan 1 partition
  - Easy archival: DROP TABLE events_2023_01 (instant)
  - Parallel scans: each partition scanned concurrently
  - Independent VACUUM / maintenance per partition
  Partitioning Types:
|  | Type | Use Case |  |
|  | RANGE | Time-series, dates, numeric ranges |  |
|  | LIST | Categories, regions, status values |  |
|  | HASH | Even distribution of any key |  |
```

---

## Read Replicas

### Read Replica Architecture

```
  Read Replica Architecture
|  | Application |  |
|  | ┌────────────┐ |  |
|  |  | Write Path | ──┼──────────────────▶┌──────────────┐ |
|  | └────────────┘ |  | PRIMARY |  |
|  |  |  | (leader) |  |
|  | ┌────────────┐ | └──────┬───────┘ |
|  |  | Read Path | ──┼──┐ | replication |
|  | └────────────┘ |  | ┌──────┼──────┐ |
| └──────────────────┘ |  |  |  |  |
|  | ┌──────▼──┐ ┌─▼────┐ ┌▼────┐ |
| └────────▶ | Replica 1 |  | Rep 2 |  | Rep 3 |  |
| (round | (reads) |  |  |  |  |  |
  robin)  └─────────┘ └──────┘ └─────┘
  Replication Types:
|  | Type | Description |  |
|  | Async (default) | Primary doesn't wait for replica ack |  |
|  |  | Pros: low write latency |  |
|  |  | Cons: replica lag (stale reads) |  |
|  | Semi-sync | Wait for at least 1 replica ack |  |
|  |  | Pros: durability guarantee |  |
|  |  | Cons: slightly higher write latency |  |
|  | Sync | Wait for ALL replicas |  |
|  |  | Pros: strongest consistency |  |
|  |  | Cons: highest write latency |  |
  Handling Replication Lag:
|  | 1. Read-your-writes: route user to primary |  |
|  | after their write for N seconds |  |
|  | 2. Monotonic reads: stick user to same replica |  |
|  | 3. Causal consistency: track write version, |  |
|  | wait for replica to catch up |  |
|  | 4. Accept staleness: for non-critical reads |  |
```

---

## Async Processing

### Queue-Based Load Leveling

```
  Queue-Based Load Leveling
  WITHOUT QUEUE:
  Request rate:  ████████████████████████████  (peak: 10K/s)
  Server capacity: ██████████                  (max: 5K/s)
  Result: 503 errors during peak
  WITH QUEUE:
|  | Produce | ───▶ | Queue | ───▶ | Consumers | ───▶ | Database |  |
|  | 10K/s |  | (buffer) |  | (5K/s |  |  |  |
| └───────┘ |  |  | steady) | └─────────┘ |
|  | absorbs | └───────────┘ |
|  | burst |  |
  Queue absorbs the spike, consumers process at steady rate.
  No requests lost, no 503 errors.
  Queue depth over time:
| Depth | ╱╲ |
|  | ╱  ╲ |
|  | ╱    ╲ |
|  | ╱      ╲ |
|  | ─────╱────────╲────────── |
  └─────────────────────────▶ Time
  burst    drain   empty
```

### Background Job Patterns

```
  Background Job Architecture
  ┌────────────┐   enqueue   ┌───────────────┐
|  | Web API | ────────────▶ | Job Queue |  |
|  | (fast |  | (Redis/SQS) |  |
|  | response) | └───────┬───────┘ |
| └────────────┘ |  |
|  |  | dequeue |
|  | 202 Accepted |  |
|  | {job_id: "abc"}   ┌─────────▼──────────┐ |
| ▼ | Worker Pool |  |
|  | ┌──────┐ ┌──────┐ |  |
| Poll status: |  | W1 |  | W2 |  |  |
| GET /jobs/abc | └──────┘ └──────┘ |  |
| → {status: "processing"} | ┌──────┐ ┌──────┐ |  |
| → {status: "complete", |  | W3 |  | W4 |  |  |
| result: {...}} | └──────┘ └──────┘ |  |
  Job Types:
|  | Type | Example | Priority |  |
|  | Immediate | Send welcome email | High |  |
|  | Scheduled | Daily report | Medium |  |
|  | Recurring (cron) | Cleanup old data | Low |  |
|  | Delayed | Reminder in 24h | Medium |  |
|  | Batch | Bulk import | Low |  |
```

---

## Auto-Scaling

### Auto-Scaling Architecture

```
  Auto-Scaling Architecture
|  | Metrics Source |  |
|  | (CloudWatch / Prometheus / Custom) |  |
  ▼
|  | Scaling Policy Engine |  |
|  | Rule 1: CPU > 70% for 3min → scale up |  |
|  | Rule 2: CPU < 30% for 10min → scale down |  |
|  | Rule 3: Queue depth > 1000 → scale up |  |
|  | Rule 4: Request latency P99 > 500ms → up |  |
  ▼
|  | Scaling Action |  |
|  | Current: 3 instances |  |
|  | Target:  5 instances (+2) |  |
|  | Cooldown: 300s (prevent flapping) |  |
|  | Min: 2  Max: 20 |  |
  Scaling Types:
|  | Type | Mechanism |  |
|  | Reactive | Scale based on current metrics |  |
|  | Predictive | ML-based, scale before demand |  |
|  | Scheduled | Scale at known peak times |  |
|  | Manual | Operator sets target count |  |
  Scaling Metrics Priority:
  1. Custom business metrics (orders/sec, active users)
  2. Queue depth / backlog size
  3. Request latency (P95, P99)
  4. CPU utilization
  5. Memory utilization
  Custom > Queue > Latency > CPU > Memory
  (most meaningful to least meaningful)
```

---

## Capacity Planning

### Capacity Planning Worksheet

```
  CAPACITY PLANNING WORKSHEET
  STEP 1: TRAFFIC ESTIMATION
  Monthly Active Users (MAU):     ____________
  Daily Active Users (DAU):       ____________ (MAU * 0.2-0.5)
  Concurrent users (peak):        ____________ (DAU * 0.1)
  Actions per user per day:       ____________
  Read:Write ratio:               ____________ :1
  Read QPS:   DAU * reads_per_user / 86400 = ____________
  Write QPS:  DAU * writes_per_user / 86400 = ____________
  Peak QPS:   avg * 3 (or observed peak ratio) = _________
  STEP 2: STORAGE
  Average object size:    ____________ bytes
  New objects per day:    ____________
  Daily storage growth:   objects * size = ____________ GB
  Retention period:       ____________ years
  Total storage:          daily * 365 * years = ________ TB
  With replication (3x):  total * 3 = ____________ TB
  STEP 3: BANDWIDTH
  Ingress (writes):       write_QPS * size = _________ MB/s
  Egress (reads):         read_QPS * size = _________ MB/s
  Peak egress:            peak_QPS * size = _________ MB/s
  STEP 4: COMPUTE
  QPS per server:         ____________ (benchmark)
  Servers needed:         peak_QPS / QPS_per_server
  = ____________ servers
  With redundancy (1.5x): ____________ servers
  STEP 5: CACHE
  Cache hit ratio target: ____________ % (aim for 95%+)
  Working set size:       ____________ GB
  Cache nodes needed:     working_set / node_memory
  = ____________ nodes
  STEP 6: DATABASE
  Read replicas needed:   read_QPS / reads_per_replica
  = ____________ replicas
  Shards needed:          total_storage / max_per_shard
  = ____________ shards
  Connections needed:     app_servers * pool_size
  = ____________ connections
  STEP 7: GROWTH PLANNING
  Growth rate:            ____________ % per year
  Plan for:               ____________ years ahead
  Future capacity:        current * (1 + rate)^years
  = ____________
```

### Quick Reference Numbers

```
  Useful Numbers for Back-of-Envelope Calculations
  Time:
  1 day   = 86,400 seconds ≈ 100K seconds
  1 month = 2.5M seconds
  1 year  = 31.5M seconds ≈ 30M seconds
  Data sizes:
  1 char (UTF-8)       = 1-4 bytes
  UUID                 = 36 chars = 36 bytes (text)
  IPv4 address         = 4 bytes
  Timestamp            = 8 bytes
  Tweet-size text      = ~300 bytes
  Typical JSON object  = 1-10 KB
  Typical web page     = 2-5 MB
  High-res image       = 2-5 MB
  1-minute video (720p)= 50-100 MB
  Throughput:
  SSD random read      = 100K+ IOPS
  SSD sequential read  = 500 MB/s - 3 GB/s
  HDD random read      = 100-200 IOPS
  Network (1Gbps)      = 125 MB/s
  Network (10Gbps)     = 1.25 GB/s
  Database:
  PostgreSQL (single)  = 5K-50K QPS
  MySQL (single)       = 5K-50K QPS
  Redis                = 100K-500K ops/sec
  Cassandra (per node) = 10K-50K ops/sec
  Elasticsearch        = 5K-20K searches/sec/shard
  Web servers:
  Nginx               = 10K-100K concurrent connections
  Node.js (single)    = 1K-10K req/sec
  Go HTTP server      = 10K-100K req/sec
  Java Spring Boot    = 5K-30K req/sec
  Powers of 2:
  2^10 = 1,024        ≈ 1 Thousand
  2^20 = 1,048,576    ≈ 1 Million
  2^30 = 1,073,741,824 ≈ 1 Billion
  2^40 ≈ 1 Trillion
```
