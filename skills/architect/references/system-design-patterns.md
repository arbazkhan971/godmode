# System Design Patterns Reference

Comprehensive catalog of system design patterns with architecture diagrams, trade-off analysis, and capacity estimation templates.

---

## Table of Contents

1. [URL Shortener](#1-url-shortener)
2. [Rate Limiter](#2-rate-limiter)
3. [Notification System](#3-notification-system)
4. [Chat System](#4-chat-system)
5. [Load Balancer](#5-load-balancer)
6. [API Gateway](#6-api-gateway)
7. [Service Registry](#7-service-registry)
8. [Message Queue](#8-message-queue)
9. [Distributed Cache](#9-distributed-cache)
10. [Search System](#10-search-system)
11. [News Feed / Timeline](#11-news-feed--timeline)
12. [File Storage System](#12-file-storage-system)
13. [Video Streaming](#13-video-streaming)
14. [Web Crawler](#14-web-crawler)
15. [Unique ID Generator](#15-unique-id-generator)
16. [Key-Value Store](#16-key-value-store)
17. [Consistent Hashing](#17-consistent-hashing)
18. [Proximity Service](#18-proximity-service)
19. [Autocomplete / Typeahead](#19-autocomplete--typeahead)
20. [Metrics Collection](#20-metrics-collection)
21. [Payment System](#21-payment-system)
22. [Reservation System](#22-reservation-system)
23. [Content Delivery Network](#23-content-delivery-network)
24. [Distributed Lock](#24-distributed-lock)
25. [Leader Election](#25-leader-election)
26. [Event-Driven Ingestion Pipeline](#26-event-driven-ingestion-pipeline)
27. [Multi-Region Active-Active](#27-multi-region-active-active)

---

## 1. URL Shortener

### Architecture

```
┌──────────┐     ┌───────────────┐     ┌───────────────┐
│  Client   │────▶│  API Gateway  │────▶│  Shortener    │
│           │◀────│  (rate limit) │◀────│  Service      │
└──────────┘     └───────────────┘     └───────┬───────┘
                                               │
                                    ┌──────────┴──────────┐
                                    │                     │
                              ┌─────▼─────┐       ┌──────▼──────┐
                              │   Cache    │       │  Database   │
                              │  (Redis)   │       │  (MySQL /   │
                              │            │       │   NoSQL)    │
                              └───────────┘       └─────────────┘
                                                         │
                                                  ┌──────▼──────┐
                                                  │  Analytics  │
                                                  │  (Kafka →   │
                                                  │   Spark)    │
                                                  └─────────────┘
```

### Key Decisions

| Aspect | Choice | Rationale |
|--------|--------|-----------|
| ID generation | Base62 encoding of auto-increment or Snowflake ID | Short, URL-safe characters |
| Storage | NoSQL (DynamoDB) or relational (MySQL) | Simple key-value access pattern |
| Cache | Redis with TTL | Hot URLs receive >80% of traffic |
| Collision handling | Check-and-retry or pre-generated key pool | Pre-generated pool avoids contention |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Eventual consistency acceptable; same short URL always resolves to same long URL |
| Availability | High | Reads from cache; multi-region replication |
| Partition Tolerance | High | Stateless service; partitioned DB behind the scenes |

### Capacity Estimation Template

```
Write ratio:         100M URLs/month
Read ratio:          10:1 (1B reads/month)
URL size:            ~500 bytes average
Storage/year:        100M * 12 * 500B = 600 GB/year
QPS (write):         100M / (30 * 86400) ≈ 40 QPS
QPS (read):          400 QPS average, 2000 QPS peak
Cache size (20%):    1B * 0.2 * 500B = 100 GB
Bandwidth (read):    2000 * 500B = 1 MB/s peak
```

---

## 2. Rate Limiter

### Architecture

```
┌──────────┐     ┌──────────────────────────────────┐
│  Client   │────▶│           API Gateway             │
│           │◀────│                                    │
└──────────┘     │  ┌────────────────────────────┐   │
                  │  │    Rate Limiter Middleware   │   │
                  │  │                              │   │
                  │  │  ┌────────┐  ┌───────────┐  │   │
                  │  │  │ Rules  │  │  Counter   │  │   │
                  │  │  │ Engine │  │  Store     │  │   │
                  │  │  └────────┘  │  (Redis)   │  │   │
                  │  │              └───────────┘  │   │
                  │  └────────────────────────────┘   │
                  └──────────┬───────────────────────┘
                             │
                       ┌─────▼─────┐
                       │  Backend  │
                       │  Service  │
                       └───────────┘
```

### Algorithms

```
Token Bucket
─────────────────────────────────────
Bucket: [●●●●●○○○○○]  capacity=10
         ▲               refill_rate=2/sec
         │
    tokens consumed
    per request

Sliding Window Log
─────────────────────────────────────
Timeline: |--req--req----req--req--|--req--|
          |<---- window (60s) ---->|
          Count requests in window: 4

Fixed Window Counter
─────────────────────────────────────
Window 1 [00:00-01:00]: count=47 / limit=50
Window 2 [01:00-02:00]: count=12 / limit=50
                         ▲
                    boundary spike risk

Sliding Window Counter
─────────────────────────────────────
Current window weight:  70% of current + 30% of previous
Effective count:        current*0.7 + previous*0.3
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Distributed counters may have slight drift |
| Availability | High | Fail-open policy when Redis is down |
| Partition Tolerance | High | Local fallback; sync on reconnect |

### Capacity Estimation Template

```
Users:               10M DAU
Requests/user/min:   ~10
Total QPS:           10M * 10 / 60 ≈ 1.7M QPS
Rules per user:      ~5 (per endpoint)
Redis entries:        10M * 5 = 50M keys
Memory per entry:    ~100 bytes
Total Redis memory:  50M * 100B = 5 GB
```

---

## 3. Notification System

### Architecture

```
┌──────────────┐     ┌──────────────┐     ┌────────────────┐
│  Trigger      │────▶│  Notification │────▶│  Priority      │
│  Sources      │     │  Service      │     │  Queue         │
│  (API/Event)  │     │               │     │  (Kafka)       │
└──────────────┘     └──────────────┘     └───────┬────────┘
                                                   │
                          ┌────────────────────────┼─────────────────────┐
                          │                        │                     │
                   ┌──────▼──────┐   ┌─────────────▼──┐   ┌─────────────▼──┐
                   │  Push       │   │  Email          │   │  SMS           │
                   │  Worker     │   │  Worker         │   │  Worker        │
                   │             │   │                 │   │                │
                   │  ┌───────┐  │   │  ┌───────────┐ │   │  ┌──────────┐ │
                   │  │ APNs/ │  │   │  │ SendGrid/ │ │   │  │ Twilio/  │ │
                   │  │ FCM   │  │   │  │ SES       │ │   │  │ SNS      │ │
                   │  └───────┘  │   │  └───────────┘ │   │  └──────────┘ │
                   └─────────────┘   └────────────────┘   └──────────────┘
                          │                   │                    │
                          └───────────┬───────┘────────────────────┘
                                      │
                               ┌──────▼──────┐
                               │  Delivery   │
                               │  Tracker    │
                               │  (DB + Log) │
                               └─────────────┘
```

### Key Components

| Component | Responsibility |
|-----------|---------------|
| Template Engine | Renders notification content per channel |
| Preference Store | User opt-in/out and channel preferences |
| Rate Controller | Per-user notification frequency caps |
| Dedup Service | Prevents duplicate sends within a window |
| Delivery Tracker | Tracks sent, delivered, opened, failed |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | At-least-once delivery; idempotent handlers |
| Availability | High | Queue absorbs spikes; workers scale horizontally |
| Partition Tolerance | High | Kafka partitions; retry with DLQ |

### Capacity Estimation Template

```
Notifications/day:   500M
Channels:            3 (push, email, SMS)
Avg payload:         1 KB
Throughput:          500M / 86400 ≈ 5800/sec
Peak (3x):           ~17,400/sec
Storage (30 days):   500M * 30 * 1KB = 15 TB
Kafka partitions:    ~50 per topic (target 500 msg/sec/partition)
```

---

## 4. Chat System

### Architecture

```
┌──────────┐    WebSocket     ┌────────────────┐
│ Client A  │◀──────────────▶│  WebSocket      │
└──────────┘                  │  Gateway        │
                              │  (sticky conn)  │
┌──────────┐    WebSocket     │                 │
│ Client B  │◀──────────────▶│                 │
└──────────┘                  └───────┬────────┘
                                      │
                          ┌───────────┴───────────┐
                          │                       │
                   ┌──────▼──────┐     ┌──────────▼─────┐
                   │  Chat       │     │  Presence       │
                   │  Service    │     │  Service        │
                   │             │     │  (heartbeat)    │
                   └──────┬──────┘     └────────────────┘
                          │
               ┌──────────┼──────────┐
               │          │          │
        ┌──────▼──┐ ┌─────▼────┐ ┌──▼───────────┐
        │ Message │ │  Group   │ │  Media       │
        │ Store   │ │  Service │ │  Service     │
        │ (Cass.) │ │          │ │  (S3 + CDN)  │
        └─────────┘ └──────────┘ └──────────────┘
```

### Message Flow

```
Sender                Gateway              Chat Service         Receiver
  │                      │                      │                   │
  │──── send(msg) ──────▶│                      │                   │
  │                      │──── route(msg) ─────▶│                   │
  │                      │                      │── store(msg) ──▶DB│
  │                      │                      │                   │
  │                      │                      │── if online ─────▶│
  │                      │                      │   push via WS     │
  │                      │                      │                   │
  │                      │                      │── if offline ────▶│
  │                      │                      │   queue + push    │
  │◀── ack ─────────────│◀── ack ─────────────│                   │
  │                      │                      │                   │
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Ordered within a conversation; eventual across devices |
| Availability | High | Message queue buffers offline; multi-DC |
| Partition Tolerance | High | Cassandra partitioned by conversation_id |

### Capacity Estimation Template

```
DAU:                 50M
Messages/user/day:   40
Total messages/day:  2B
Avg message size:    200 bytes
Storage/day:         2B * 200B = 400 GB
Storage/year:        ~146 TB
QPS (write):         2B / 86400 ≈ 23,000
QPS (read):          5x write ≈ 115,000
WebSocket conns:     50M concurrent (peak)
Servers (50K/srv):   ~1000 WebSocket servers
```

---

## 5. Load Balancer

### Architecture

```
                    ┌─────────────────────────────────┐
                    │        DNS (Round Robin)         │
                    └──────────────┬──────────────────┘
                                   │
                    ┌──────────────▼──────────────────┐
                    │       L4 Load Balancer           │
                    │    (TCP/UDP - hardware/DPDK)     │
                    └──────────────┬──────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
    ┌─────────▼────────┐ ┌────────▼─────────┐ ┌───────▼──────────┐
    │  L7 LB (nginx)   │ │  L7 LB (nginx)   │ │  L7 LB (nginx)   │
    │  SSL termination │ │  SSL termination │ │  SSL termination │
    │  path routing    │ │  path routing    │ │  path routing    │
    └────────┬─────────┘ └────────┬─────────┘ └────────┬─────────┘
             │                    │                     │
      ┌──────┴──────┐     ┌──────┴──────┐       ┌──────┴──────┐
      │ App Pool A  │     │ App Pool B  │       │ App Pool C  │
      │ ┌──┐┌──┐┌──┐│     │ ┌──┐┌──┐┌──┐│       │ ┌──┐┌──┐┌──┐│
      │ │S1││S2││S3││     │ │S1││S2││S3││       │ │S1││S2││S3││
      │ └──┘└──┘└──┘│     │ └──┘└──┘└──┘│       │ └──┘└──┘└──┘│
      └─────────────┘     └─────────────┘       └─────────────┘
```

### Algorithms

| Algorithm | Use Case | Complexity |
|-----------|----------|-----------|
| Round Robin | Equal-capacity servers | O(1) |
| Weighted Round Robin | Mixed-capacity servers | O(1) |
| Least Connections | Variable request duration | O(log n) |
| Least Response Time | Latency-sensitive | O(log n) |
| IP Hash | Session affinity | O(1) |
| Consistent Hash | Cache clusters | O(log n) |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | N/A | Routing layer; consistency depends on backend |
| Availability | High | Active-passive or active-active HA pair |
| Partition Tolerance | Medium | Split-brain risk with active-active |

---

## 6. API Gateway

### Architecture

```
┌──────────┐     ┌──────────────────────────────────────────┐
│  Clients  │────▶│              API Gateway                  │
│           │◀────│                                            │
└──────────┘     │  ┌──────────┐ ┌──────────┐ ┌───────────┐ │
                  │  │  Auth    │ │  Rate    │ │  Request  │ │
                  │  │  Filter  │ │  Limiter │ │  Router   │ │
                  │  └──────────┘ └──────────┘ └───────────┘ │
                  │  ┌──────────┐ ┌──────────┐ ┌───────────┐ │
                  │  │  Circuit │ │  Request │ │  Response  │ │
                  │  │  Breaker │ │  Logger  │ │  Cache     │ │
                  │  └──────────┘ └──────────┘ └───────────┘ │
                  └──────────┬──────────┬──────────┬─────────┘
                             │          │          │
                      ┌──────▼──┐ ┌─────▼───┐ ┌───▼────────┐
                      │  User   │ │  Order  │ │  Payment   │
                      │  Svc    │ │  Svc    │ │  Svc       │
                      └─────────┘ └─────────┘ └────────────┘
```

### Responsibilities

- **Authentication/Authorization**: JWT validation, OAuth token introspection
- **Rate Limiting**: Per-client, per-endpoint throttling
- **Request Routing**: Path-based, header-based, version-based
- **Protocol Translation**: REST to gRPC, WebSocket upgrade
- **Response Aggregation**: Combine multiple backend responses
- **Circuit Breaking**: Protect downstream from cascading failure

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | High | Single entry point for policy enforcement |
| Availability | High | Horizontally scaled; health-checked |
| Partition Tolerance | Medium | Single point of failure if not redundant |

---

## 7. Service Registry

### Architecture

```
┌────────────────────────────────────────────────┐
│              Service Registry (Consul/Eureka)    │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │  Registry Table                           │   │
│  │  ┌───────────┬──────────┬──────────────┐ │   │
│  │  │ Service   │ Instance │ Health       │ │   │
│  │  ├───────────┼──────────┼──────────────┤ │   │
│  │  │ user-svc  │ 10.0.1.1 │ HEALTHY     │ │   │
│  │  │ user-svc  │ 10.0.1.2 │ HEALTHY     │ │   │
│  │  │ order-svc │ 10.0.2.1 │ HEALTHY     │ │   │
│  │  │ order-svc │ 10.0.2.2 │ UNHEALTHY   │ │   │
│  │  └───────────┴──────────┴──────────────┘ │   │
│  └──────────────────────────────────────────┘   │
└───────────┬──────────────────────┬──────────────┘
            │                      │
     ┌──────▼──────┐        ┌──────▼──────┐
     │  Register   │        │  Discover   │
     │  (on boot)  │        │  (on call)  │
     │  + heartbeat│        │  + cache    │
     └─────────────┘        └─────────────┘
```

### Patterns

| Pattern | Mechanism | Example |
|---------|-----------|---------|
| Self-registration | Service registers itself | Eureka client |
| Third-party registration | Sidecar/orchestrator registers | Kubernetes, Consul agent |
| Client-side discovery | Client queries registry + LB | Netflix Ribbon |
| Server-side discovery | Router/LB queries registry | AWS ALB, Kubernetes Service |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Stale entries possible; TTL + health checks mitigate |
| Availability | High | Replicated registry (Raft/Gossip) |
| Partition Tolerance | High | Gossip protocol handles network partitions |

---

## 8. Message Queue

### Architecture

```
┌───────────┐     ┌───────────────────────────────────┐     ┌───────────┐
│ Producers  │────▶│           Message Broker            │────▶│ Consumers  │
│            │     │                                     │     │            │
│ ┌───────┐  │     │  ┌─────────────────────────────┐   │     │  ┌───────┐ │
│ │ Svc A │  │     │  │  Topic: orders               │   │     │  │ Svc X │ │
│ └───────┘  │     │  │  ┌────┬────┬────┬────┬────┐ │   │     │  └───────┘ │
│ ┌───────┐  │     │  │  │ P0 │ P1 │ P2 │ P3 │ P4 │ │   │     │  ┌───────┐ │
│ │ Svc B │  │     │  │  └────┴────┴────┴────┴────┘ │   │     │  │ Svc Y │ │
│ └───────┘  │     │  └─────────────────────────────┘   │     │  └───────┘ │
└───────────┘     │  ┌─────────────────────────────┐   │     └───────────┘
                   │  │  Topic: payments             │   │
                   │  │  ┌────┬────┬────┐            │   │
                   │  │  │ P0 │ P1 │ P2 │            │   │
                   │  │  └────┴────┴────┘            │   │
                   │  └─────────────────────────────┘   │
                   └───────────────────────────────────┘
```

### Delivery Guarantees

| Guarantee | Mechanism | Use Case |
|-----------|-----------|----------|
| At-most-once | Fire and forget, no ack | Metrics, logs |
| At-least-once | Ack after processing; retry on failure | Orders, payments |
| Exactly-once | Idempotent consumer + transactional outbox | Financial ledger |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Ordering within partition; no global order |
| Availability | High | Replicated partitions; ISR in Kafka |
| Partition Tolerance | High | Designed for distributed operation |

---

## 9. Distributed Cache

### Architecture

```
┌──────────┐     ┌──────────────┐     ┌───────────────────────┐
│  Client   │────▶│  App Server   │────▶│   Cache Cluster        │
│           │◀────│               │◀────│                         │
└──────────┘     └──────────────┘     │  ┌─────┐ ┌─────┐       │
                                       │  │ N1  │ │ N2  │       │
                        ┌──────┐       │  │slt  │ │slt  │       │
                        │  DB  │◀──────│  │0-5K │ │5K-  │       │
                        │      │       │  └─────┘ │10K  │       │
                        └──────┘       │          └─────┘       │
                                       │  ┌─────┐              │
                                       │  │ N3  │              │
                                       │  │slt  │              │
                                       │  │10K- │              │
                                       │  │16K  │              │
                                       │  └─────┘              │
                                       └───────────────────────┘
```

### Caching Strategies

```
Cache-Aside (Lazy Loading)
──────────────────────────
App ──▶ Cache hit?  ──YES──▶ return cached
              │
              NO
              │
        App ──▶ DB ──▶ write to cache ──▶ return

Read-Through
──────────────────────────
App ──▶ Cache ──miss──▶ Cache fetches from DB ──▶ return

Write-Through
──────────────────────────
App ──▶ Cache ──▶ Cache writes to DB (sync) ──▶ ack

Write-Behind (Write-Back)
──────────────────────────
App ──▶ Cache ──▶ ack immediately
              │
        (async batch flush to DB)
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Stale reads possible; TTL + invalidation mitigate |
| Availability | High | Replicated nodes; hash ring redistribution |
| Partition Tolerance | High | Consistent hashing handles node loss |

### Capacity Estimation Template

```
Cacheable objects:   50M
Avg object size:     2 KB
Total cache size:    50M * 2KB = 100 GB
Hit ratio target:    95%
Nodes (32 GB each):  4 nodes (with replication: 8)
Eviction:            LRU with TTL
QPS per node:        100K ops/sec (Redis benchmark)
```

---

## 10. Search System

### Architecture

```
┌──────────┐     ┌──────────────┐     ┌───────────────────────┐
│  Client   │────▶│  Search API   │────▶│  Search Cluster        │
│           │◀────│  (parse,rank) │◀────│  (Elasticsearch)       │
└──────────┘     └──────────────┘     │                         │
                                       │  ┌───────┐ ┌───────┐  │
                                       │  │ Shard │ │ Shard │  │
                                       │  │  0    │ │  1    │  │
                                       │  └───────┘ └───────┘  │
                                       │  ┌───────┐ ┌───────┐  │
                                       │  │ Shard │ │ Shard │  │
                                       │  │  2    │ │  3    │  │
                                       │  └───────┘ └───────┘  │
                                       └───────────────────────┘
                                                │
                                       ┌────────▼────────┐
                                       │  Indexing        │
                                       │  Pipeline        │
                                       │  (Kafka → ETL → │
                                       │   Bulk Index)    │
                                       └─────────────────┘
```

### Key Components

| Component | Function |
|-----------|----------|
| Query Parser | Tokenize, stem, spell-correct, expand synonyms |
| Inverted Index | Term → document_id mapping for fast lookup |
| Ranking Engine | TF-IDF, BM25, learning-to-rank models |
| Indexer | Batch and real-time document ingestion |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Near real-time indexing (~1s delay) |
| Availability | High | Replica shards serve reads during failures |
| Partition Tolerance | High | Distributed shard allocation |

---

## 11. News Feed / Timeline

### Architecture

```
┌──────────┐                            ┌──────────────┐
│  User A   │──── post ────────────────▶│  Feed Service │
│ (author)  │                            │               │
└──────────┘                            └───────┬───────┘
                                                │
                              ┌─────────────────┼──────────────────┐
                              │                 │                  │
                       ┌──────▼──────┐  ┌───────▼───────┐  ┌──────▼──────┐
                       │  Fan-out    │  │  Post Store   │  │  Social    │
                       │  Service    │  │  (write)      │  │  Graph     │
                       └──────┬──────┘  └───────────────┘  └────────────┘
                              │
                     ┌────────┼────────┐
                     │        │        │
              ┌──────▼──┐ ┌──▼─────┐ ┌▼──────────┐
              │ Feed    │ │ Feed   │ │ Feed      │
              │ Cache B │ │ Cch C  │ │ Cache D   │
              │ (Redis) │ │(Redis) │ │ (Redis)   │
              └─────────┘ └────────┘ └───────────┘
                   │           │           │
              ┌────▼──┐  ┌────▼──┐  ┌─────▼──┐
              │User B │  │User C │  │User D  │
              │(reader)│  │(reader)│ │(reader)│
              └───────┘  └───────┘  └────────┘
```

### Fan-out Strategies

| Strategy | Mechanism | Best For |
|----------|-----------|----------|
| Fan-out on write (push) | Pre-compute feeds on post creation | Users with <10K followers |
| Fan-out on read (pull) | Assemble feed at read time | Celebrity users (>10K followers) |
| Hybrid | Push for normal, pull for celebrities | Large-scale social networks |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Feed can be slightly stale; eventual |
| Availability | High | Pre-computed feeds in cache |
| Partition Tolerance | High | Feed cache sharded per user |

---

## 12. File Storage System

### Architecture

```
┌──────────┐     ┌──────────────┐     ┌────────────────────────┐
│  Client   │────▶│  Upload API   │────▶│  Object Store           │
│           │     │  (presigned   │     │  (S3/GCS/MinIO)         │
│           │     │   URL flow)   │     │                          │
└──────────┘     └──────┬───────┘     │  ┌────────┐ ┌────────┐  │
                        │              │  │Bucket A│ │Bucket B│  │
                  ┌─────▼─────┐       │  └────────┘ └────────┘  │
                  │ Metadata  │       └────────────────────────┘
                  │ Service   │                │
                  │ (DB)      │       ┌────────▼────────┐
                  └───────────┘       │  CDN Edge Cache  │
                                      └─────────────────┘
```

### Upload Flow

```
Client                API              Object Store
  │                    │                    │
  │── request upload ─▶│                    │
  │                    │── generate ────────▶│
  │                    │   presigned URL     │
  │◀── presigned URL ──│                    │
  │                    │                    │
  │── PUT directly ────────────────────────▶│
  │◀── 200 OK ─────────────────────────────│
  │                    │                    │
  │── confirm upload ─▶│                    │
  │                    │── save metadata    │
  │◀── file URL ───────│                    │
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | High | Metadata in RDBMS; object store is strongly consistent (S3) |
| Availability | High | Multi-AZ replication; CDN for reads |
| Partition Tolerance | High | Object store handles internally |

---

## 13. Video Streaming

### Architecture

```
┌──────────┐     ┌──────────────────────────────────────────┐
│  Creator  │────▶│  Upload + Transcode Pipeline              │
└──────────┘     │                                            │
                  │  Upload ──▶ Queue ──▶ Transcode Workers   │
                  │                       │                    │
                  │              ┌────────┼────────┐          │
                  │              │        │        │          │
                  │           1080p    720p     480p          │
                  │              │        │        │          │
                  │              └────────┼────────┘          │
                  │                       ▼                    │
                  │              Object Storage (segments)     │
                  └──────────────────────┬───────────────────┘
                                         │
                  ┌──────────────────────▼───────────────────┐
                  │                    CDN                     │
                  │  ┌──────┐  ┌──────┐  ┌──────┐           │
                  │  │Edge 1│  │Edge 2│  │Edge 3│           │
                  │  └──────┘  └──────┘  └──────┘           │
                  └──────────────────────────────────────────┘
                         │           │           │
                  ┌──────▼──┐ ┌──────▼──┐ ┌──────▼──┐
                  │ Viewer  │ │ Viewer  │ │ Viewer  │
                  │ (ABR)   │ │ (ABR)   │ │ (ABR)   │
                  └─────────┘ └─────────┘ └─────────┘
```

### Adaptive Bitrate Streaming

```
Bandwidth Detection:
  High BW  ──▶ 1080p segments
  Med BW   ──▶ 720p segments
  Low BW   ──▶ 480p segments

Manifest (HLS):
  #EXTM3U
  #EXT-X-STREAM-INF:BANDWIDTH=5000000
  1080p/playlist.m3u8
  #EXT-X-STREAM-INF:BANDWIDTH=2500000
  720p/playlist.m3u8
  #EXT-X-STREAM-INF:BANDWIDTH=1000000
  480p/playlist.m3u8
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Eventual; transcode can take minutes |
| Availability | High | CDN edge caching; origin fallback |
| Partition Tolerance | High | CDN + multi-region origin |

---

## 14. Web Crawler

### Architecture

```
┌──────────────────────────────────────────────────┐
│                   Crawler System                   │
│                                                    │
│  ┌──────────┐     ┌──────────┐     ┌───────────┐ │
│  │  Seed    │────▶│  URL     │────▶│  Fetcher  │ │
│  │  URLs    │     │  Frontier │     │  Workers  │ │
│  └──────────┘     │  (Queue)  │     │  (N pool) │ │
│                   └──────────┘     └─────┬─────┘ │
│                        ▲                  │       │
│                        │                  ▼       │
│                   ┌────┴──────┐    ┌────────────┐ │
│                   │  URL      │    │  Parser    │ │
│                   │  Filter   │◀───│  (extract  │ │
│                   │  (dedup,  │    │   links)   │ │
│                   │   robots) │    └────────────┘ │
│                   └───────────┘          │        │
│                                          ▼        │
│                                   ┌────────────┐  │
│                                   │  Storage   │  │
│                                   │  (S3/HDFS) │  │
│                                   └────────────┘  │
└──────────────────────────────────────────────────┘
```

### Politeness Policies

| Policy | Implementation |
|--------|---------------|
| robots.txt | Parse and cache per domain |
| Crawl delay | Per-domain rate limiter (1-5 req/sec) |
| Deduplication | Bloom filter or SimHash for content dedup |
| Priority | PageRank-based URL scoring |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Snapshot; web changes faster than crawl cycle |
| Availability | Medium | Single orchestrator risk; HA scheduler needed |
| Partition Tolerance | High | Workers are independent; queue-based |

---

## 15. Unique ID Generator

### Architecture

```
┌─────────────────────────────────────────────────┐
│              Snowflake ID Structure               │
│                                                   │
│  ┌─────────┬───────────┬─────────┬─────────────┐ │
│  │ Sign(1) │ Timestamp │ Machine │ Sequence    │ │
│  │  bit    │  (41 bit) │ (10bit) │  (12 bit)   │ │
│  └─────────┴───────────┴─────────┴─────────────┘ │
│                                                   │
│  Timestamp: milliseconds since custom epoch       │
│  Machine:   datacenter (5) + worker (5)          │
│  Sequence:  counter per millisecond (4096/ms)    │
│                                                   │
│  Total:     64-bit signed integer                 │
│  Lifespan:  ~69 years from epoch                  │
│  Capacity:  4096 IDs/ms/worker * 1024 workers    │
│           = ~4.2M IDs/ms                         │
└─────────────────────────────────────────────────┘
```

### Alternative Approaches

| Approach | Pros | Cons |
|----------|------|------|
| UUID v4 | No coordination | 128-bit; not sortable |
| Snowflake | Sortable; compact 64-bit | Clock sync dependency |
| Database auto-increment | Simple | Single point of failure; not distributed |
| DB with step (Flickr) | Simple; multi-master | Requires coordination for new nodes |
| ULID | Sortable; 128-bit; lexicographic | Slightly larger than Snowflake |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | High | Monotonically increasing within a worker |
| Availability | High | No network call for generation |
| Partition Tolerance | High | Each worker generates independently |

---

## 16. Key-Value Store

### Architecture

```
┌──────────┐     ┌─────────────────────────────────────┐
│  Client   │────▶│         Key-Value Cluster             │
│           │◀────│                                       │
└──────────┘     │  ┌─────────────────────────────────┐ │
                  │  │  Coordinator Node               │ │
                  │  │  (consistent hash → partition)  │ │
                  │  └──────────────┬──────────────────┘ │
                  │                 │                     │
                  │    ┌────────────┼────────────┐       │
                  │    │            │            │       │
                  │  ┌─▼──┐     ┌──▼─┐      ┌──▼─┐    │
                  │  │ N1 │     │ N2 │      │ N3 │    │
                  │  │R:a │     │R:b │      │R:c │    │
                  │  │R:b │     │R:c │      │R:a │    │
                  │  └────┘     └────┘      └────┘    │
                  │                                     │
                  │  Replication factor: 3               │
                  │  W=2, R=2 (quorum)                  │
                  └─────────────────────────────────────┘
```

### Consistency Levels

```
ONE:     ┌──W──▶N1──ack──┐
         │               ▼
Client──▶Coord           respond
         │
         └──W──▶N2 (async)
         └──W──▶N3 (async)

QUORUM:  ┌──W──▶N1──ack──┐
         │               │
Client──▶Coord           ├──▶ respond (2 of 3)
         │               │
         └──W──▶N2──ack──┘
         └──W──▶N3 (async)

ALL:     ┌──W──▶N1──ack──┐
         │               │
Client──▶Coord           ├──▶ respond (3 of 3)
         │               │
         └──W──▶N2──ack──┤
         └──W──▶N3──ack──┘
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Tunable | W+R > N for strong consistency |
| Availability | High | Hinted handoff; read repair |
| Partition Tolerance | High | Consistent hashing; vector clocks |

---

## 17. Consistent Hashing

### Architecture

```
                    Hash Ring (0 to 2^32)
                         0
                        ╱│╲
                      ╱  │  ╲
                   N1    │    N4
                  ╱      │      ╲
                ╱        │        ╲
              ╱          │          ╲
            N1v          │          N4v     ← virtual nodes
           ╱             │             ╲
         ╱               │               ╲
       ╱                 │                 ╲
     N2 ────────────── ──┼── ────────────── N3
       ╲                 │                 ╱
         ╲               │               ╱
           N2v           │           N3v
              ╲          │          ╱
                ╲        │        ╱
                  ╲      │      ╱
                   N3v2  │  N1v2
                      ╲  │  ╱
                        ╲│╱

    Key K → hash(K) → walk clockwise → first node
    Virtual nodes ensure even distribution
```

### Node Addition/Removal

```
Before (3 nodes):    After adding N4:
  Key range per node:   Key range redistribution:
  N1: 0-120             N1: 0-90
  N2: 121-240           N4: 91-120 (took from N1)
  N3: 241-360           N2: 121-240
                        N3: 241-360

  Only K/N keys move (where K = total keys, N = nodes)
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Minimal redistribution; temporary inconsistency on rebalance |
| Availability | High | Node loss redistributes to neighbors |
| Partition Tolerance | High | No central coordinator needed |

---

## 18. Proximity Service

### Architecture

```
┌──────────┐     ┌──────────────┐     ┌─────────────────────┐
│  Mobile   │────▶│  Location    │────▶│  Geospatial Index    │
│  Client   │◀────│  Service     │◀────│                       │
│  (lat,lng)│     └──────────────┘     │  ┌───────────────┐   │
└──────────┘                           │  │  Geohash /    │   │
                                       │  │  Quadtree     │   │
                                       │  │               │   │
                                       │  │  gh:9q8yy →   │   │
                                       │  │  [poi1,poi2]  │   │
                                       │  └───────────────┘   │
                                       └─────────────────────┘
```

### Geohash Grid

```
Precision:
  ┌──────┬──────────────┬─────────────────┐
  │ Len  │ Cell Size    │ Use Case        │
  ├──────┼──────────────┼─────────────────┤
  │  4   │ ~39km x 20km │ Regional search │
  │  5   │ ~5km x 5km   │ City search     │
  │  6   │ ~1.2km x 0.6km│ Neighborhood   │
  │  7   │ ~150m x 150m │ Block level     │
  │  8   │ ~38m x 19m   │ Building level  │
  └──────┴──────────────┴─────────────────┘

Neighbor lookup: query geohash + 8 adjacent cells
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Location updates are eventually consistent |
| Availability | High | Read-heavy; cached geohash results |
| Partition Tolerance | High | Sharded by geohash prefix |

---

## 19. Autocomplete / Typeahead

### Architecture

```
┌──────────┐     ┌──────────────┐     ┌──────────────────────┐
│  Client   │────▶│  Typeahead   │────▶│  Trie Service         │
│  (debounce│◀────│  API         │◀────│                        │
│   200ms)  │     └──────────────┘     │  ┌──────────────────┐ │
└──────────┘                           │  │     (root)       │ │
                                       │  │     / | \        │ │
                                       │  │    c  d  f       │ │
                                       │  │   / \   |        │ │
                                       │  │  a   o  o        │ │
                                       │  │  |   |  |        │ │
                                       │  │  r   g  o        │ │
                                       │  │ (car)(dog)(foo)  │ │
                                       │  │  [5]  [8]  [3]  │ │
                                       │  └──────────────────┘ │
                                       └──────────────────────┘
```

### Ranking

```
Score(suggestion) = frequency_weight * recency_decay * personalization_boost

Frequency:       raw query count (normalized)
Recency:         exponential decay (half-life = 7 days)
Personalization: user history affinity score
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Trie rebuilt periodically; stale suggestions OK |
| Availability | High | In-memory trie; replicated across nodes |
| Partition Tolerance | High | Each replica is self-sufficient |

---

## 20. Metrics Collection

### Architecture

```
┌──────────┐   ┌──────────┐   ┌──────────┐
│  App 1   │   │  App 2   │   │  App 3   │
│  Agent   │   │  Agent   │   │  Agent   │
└────┬─────┘   └────┬─────┘   └────┬─────┘
     │              │              │
     └──────────────┼──────────────┘
                    │
           ┌────────▼────────┐
           │  Collection     │
           │  Service        │
           │  (pull/push)    │
           └────────┬────────┘
                    │
           ┌────────▼────────┐
           │  Time Series    │
           │  Database       │
           │  (InfluxDB /    │
           │   Prometheus)   │
           └────────┬────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
  ┌─────▼─────┐ ┌──▼────────┐ ┌▼──────────┐
  │ Dashboard │ │  Alerting  │ │  Query    │
  │ (Grafana) │ │  Engine    │ │  API      │
  └───────────┘ └───────────┘ └───────────┘
```

### Data Model

```
Metric: cpu.usage
  Tags:    {host: web-01, region: us-east, env: prod}
  Fields:  {value: 72.5}
  Time:    2024-01-15T10:30:00Z

Storage Layout (columnar):
  ┌────────────┬───────┬─────────┬──────┐
  │ timestamp  │ host  │ region  │ value│
  ├────────────┼───────┼─────────┼──────┤
  │ 10:30:00   │ web-01│ us-east │ 72.5 │
  │ 10:30:00   │ web-02│ us-east │ 68.1 │
  │ 10:30:00   │ web-03│ us-west │ 55.3 │
  └────────────┴───────┴─────────┴──────┘

Downsampling:
  Raw:     1-second granularity    → 7 days
  5-min:   averaged                → 30 days
  1-hour:  averaged                → 1 year
  1-day:   averaged                → forever
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Slight delay acceptable; write-optimized |
| Availability | High | Agents buffer locally on collection failure |
| Partition Tolerance | High | Sharded by metric + time range |

---

## 21. Payment System

### Architecture

```
┌──────────┐     ┌──────────────┐     ┌────────────────────┐
│  Client   │────▶│  Payment     │────▶│  Payment Service    │
│           │◀────│  API         │◀────│                      │
└──────────┘     └──────────────┘     │  ┌──────────────┐   │
                                       │  │ Idempotency  │   │
                                       │  │ Store (Redis)│   │
                                       │  └──────────────┘   │
                                       └────────┬───────────┘
                                                │
                         ┌──────────────────────┼───────────────────┐
                         │                      │                   │
                  ┌──────▼──────┐     ┌─────────▼────────┐ ┌───────▼──────┐
                  │  Ledger     │     │  PSP Adapter     │ │  Reconciler  │
                  │  Service    │     │  (Stripe/Adyen)  │ │  (batch)     │
                  │  (double    │     └──────────────────┘ └──────────────┘
                  │   entry)    │
                  └─────────────┘
```

### Double-Entry Ledger

```
Transaction: User pays $100 for Order #5678

  ┌─────────────┬────────┬────────┬─────────┐
  │ Account     │ Debit  │ Credit │ Balance │
  ├─────────────┼────────┼────────┼─────────┤
  │ User Wallet │ $100   │        │ -$100   │
  │ Revenue     │        │ $100   │ +$100   │
  └─────────────┴────────┴────────┴─────────┘

  Invariant: sum(debits) == sum(credits) ALWAYS
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Critical | ACID transactions; double-entry ledger |
| Availability | High | Idempotency keys; retry-safe |
| Partition Tolerance | Medium | Synchronous replication for ledger |

---

## 22. Reservation System

### Architecture

```
┌──────────┐     ┌──────────────┐     ┌─────────────────────┐
│  Client   │────▶│  Booking     │────▶│  Inventory Service   │
│           │◀────│  API         │◀────│                       │
└──────────┘     └──────────────┘     │  ┌───────────────┐   │
                                       │  │ Availability  │   │
                                       │  │ Cache (Redis) │   │
                                       │  └───────┬───────┘   │
                                       │          │           │
                                       │  ┌───────▼───────┐   │
                                       │  │ Reservation   │   │
                                       │  │ DB (Postgres) │   │
                                       │  │ SELECT...FOR  │   │
                                       │  │ UPDATE / OCC  │   │
                                       │  └───────────────┘   │
                                       └─────────────────────┘
```

### Concurrency Control

```
Optimistic Concurrency (OCC):
  1. Read:    version=5, available=10
  2. Reserve: UPDATE SET available=9, version=6
              WHERE id=X AND version=5
  3. If rows_affected == 0 → retry (conflict)

Pessimistic Locking:
  1. SELECT ... FOR UPDATE (row lock)
  2. Check availability
  3. UPDATE available count
  4. COMMIT (release lock)

Distributed Lock (Redis):
  1. SETNX lock:item:123 owner=txn_abc EX 30
  2. Process reservation
  3. Release lock (Lua script for atomicity)
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | High | No double-booking; serialized writes |
| Availability | Medium | Lock contention reduces throughput |
| Partition Tolerance | Medium | Single-leader DB for strong consistency |

---

## 23. Content Delivery Network

### Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     CDN Architecture                      │
│                                                          │
│  ┌─────────┐          ┌─────────────┐                   │
│  │ Origin  │◀─────────│  Mid-Tier   │                   │
│  │ Server  │          │  Cache      │                   │
│  └─────────┘          └──────┬──────┘                   │
│                              │                           │
│              ┌───────────────┼───────────────┐          │
│              │               │               │          │
│       ┌──────▼──────┐ ┌─────▼───────┐ ┌─────▼──────┐  │
│       │ Edge PoP    │ │ Edge PoP    │ │ Edge PoP   │  │
│       │ (US-East)   │ │ (EU-West)   │ │ (APAC)     │  │
│       │ ┌────────┐  │ │ ┌────────┐  │ │ ┌────────┐ │  │
│       │ │ Cache  │  │ │ │ Cache  │  │ │ │ Cache  │ │  │
│       │ │ + TLS  │  │ │ │ + TLS  │  │ │ │ + TLS  │ │  │
│       │ └────────┘  │ │ └────────┘  │ │ └────────┘ │  │
│       └─────────────┘ └─────────────┘ └────────────┘  │
│              │               │               │          │
│         ┌────▼──┐       ┌────▼──┐       ┌────▼──┐      │
│         │Users │       │Users │       │Users │      │
│         └──────┘       └──────┘       └──────┘      │
└──────────────────────────────────────────────────────────┘
```

### Cache Invalidation Strategies

| Strategy | Mechanism | Latency |
|----------|-----------|---------|
| TTL-based | Automatic expiry | Seconds to hours |
| Purge API | Explicit invalidation | Seconds |
| Versioned URLs | `/v2/style.css` or `?v=hash` | Instant (new URL) |
| Stale-while-revalidate | Serve stale, refresh async | Near-zero |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Cached content may be stale |
| Availability | Very High | Globally distributed; origin failover |
| Partition Tolerance | High | Each PoP operates independently |

---

## 24. Distributed Lock

### Architecture

```
┌──────────────────────────────────────────────┐
│           Redlock Algorithm (Redis)            │
│                                                │
│  Client tries to acquire lock on N/2+1 nodes: │
│                                                │
│  ┌────────┐  ┌────────┐  ┌────────┐          │
│  │ Redis  │  │ Redis  │  │ Redis  │          │
│  │ Node 1 │  │ Node 2 │  │ Node 3 │          │
│  │  [OK]  │  │  [OK]  │  │ [FAIL] │          │
│  └────────┘  └────────┘  └────────┘          │
│                                                │
│  ┌────────┐  ┌────────┐                       │
│  │ Redis  │  │ Redis  │  Result: 4/5 = OK    │
│  │ Node 4 │  │ Node 5 │  Lock acquired        │
│  │  [OK]  │  │  [OK]  │                       │
│  └────────┘  └────────┘                       │
│                                                │
│  Lock validity = TTL - acquisition_time       │
│  Fencing token: monotonic counter             │
└──────────────────────────────────────────────┘
```

### Lock Patterns

| Pattern | Description | Use Case |
|---------|-------------|----------|
| Mutex | Exclusive access | Critical section |
| Read-Write Lock | Multiple readers, single writer | Shared config |
| Lease | Time-bounded lock with auto-release | Leader election |
| Fencing | Lock + monotonic token for safety | Distributed writes |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | High | Quorum-based; fencing tokens prevent stale ops |
| Availability | Medium | Requires majority of nodes; lock contention |
| Partition Tolerance | Medium | Minority partition cannot acquire locks |

---

## 25. Leader Election

### Architecture

```
┌───────────────────────────────────────────────┐
│         Leader Election (Raft/ZooKeeper)        │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Node A   │  │ Node B   │  │ Node C   │     │
│  │ LEADER   │  │ FOLLOWER │  │ FOLLOWER │     │
│  │ ████████ │  │          │  │          │     │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘     │
│       │              │              │           │
│       │──heartbeat──▶│              │           │
│       │──heartbeat──────────────────▶           │
│       │              │              │           │
│  If leader fails:                               │
│       │    ╳         │              │           │
│       │              │──request────▶│           │
│       │              │    vote      │           │
│       │              │◀──grant──────│           │
│       │              │              │           │
│       │         ┌────┴─────┐        │           │
│       │         │ Node B   │        │           │
│       │         │ NEW      │        │           │
│       │         │ LEADER   │        │           │
│       │         └──────────┘        │           │
└───────────────────────────────────────────────┘
```

### Algorithms

| Algorithm | Mechanism | Used By |
|-----------|-----------|---------|
| Raft | Log replication + term-based voting | etcd, Consul |
| ZAB | Atomic broadcast | ZooKeeper |
| Paxos | Proposal + accept phases | Chubby, Spanner |
| Bully | Highest ID wins | Simple systems |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | High | Single leader ensures serial ordering |
| Availability | Medium | Election period = brief unavailability |
| Partition Tolerance | Medium | Minority partition has no leader |

---

## 26. Event-Driven Ingestion Pipeline

### Architecture

```
┌──────────┐  ┌──────────┐  ┌──────────┐
│ Source 1  │  │ Source 2  │  │ Source 3  │
│ (API)     │  │ (CDC)     │  │ (IoT)     │
└─────┬─────┘  └─────┬─────┘  └─────┬─────┘
      │              │              │
      └──────────────┼──────────────┘
                     │
            ┌────────▼────────┐
            │  Ingestion      │
            │  Gateway        │
            │  (schema valid) │
            └────────┬────────┘
                     │
            ┌────────▼────────┐
            │  Stream         │
            │  (Kafka)        │
            └────────┬────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
   ┌─────▼─────┐ ┌──▼────────┐ ┌▼──────────┐
   │ Real-time │ │  Batch    │ │  Archive  │
   │ Consumer  │ │  ETL      │ │  (S3/GCS) │
   │ (Flink)   │ │  (Spark)  │ │           │
   └─────┬─────┘ └─────┬─────┘ └───────────┘
         │              │
   ┌─────▼─────┐ ┌─────▼─────┐
   │ Real-time │ │  Data     │
   │ Dashboard │ │  Warehouse│
   └───────────┘ └───────────┘
```

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Medium | Eventual; late-arriving events handled with watermarks |
| Availability | High | Kafka replication; consumer replay |
| Partition Tolerance | High | Horizontally partitioned stream |

---

## 27. Multi-Region Active-Active

### Architecture

```
                    ┌─────────────────┐
                    │  Global DNS     │
                    │  (GeoDNS /      │
                    │   Anycast)      │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼──────┐ ┌────▼────────┐ ┌──▼──────────┐
     │ Region: US    │ │ Region: EU  │ │ Region: AP  │
     │               │ │             │ │             │
     │ ┌───────────┐ │ │ ┌─────────┐ │ │ ┌─────────┐ │
     │ │ App + DB  │ │ │ │ App+DB  │ │ │ │ App+DB  │ │
     │ │ (primary) │ │ │ │(primary)│ │ │ │(primary)│ │
     │ └─────┬─────┘ │ │ └────┬────┘ │ │ └────┬────┘ │
     └───────┼───────┘ └──────┼──────┘ └──────┼──────┘
              │               │               │
              └───────────────┼───────────────┘
                              │
                   ┌──────────▼──────────┐
                   │  Conflict Resolution │
                   │  (CRDTs / LWW /     │
                   │   app-level merge)  │
                   └─────────────────────┘
```

### Conflict Resolution Strategies

| Strategy | Mechanism | Data Loss Risk |
|----------|-----------|---------------|
| Last Writer Wins (LWW) | Timestamp-based | Concurrent writes lost |
| CRDTs | Commutative/convergent types | None (merge-friendly types) |
| Application-level | Domain-specific merge logic | Depends on logic |
| Region affinity | Route user to "home" region | Low (single writer) |

### Trade-offs

| Property | Rating | Notes |
|----------|--------|-------|
| Consistency | Low | Eventual; conflict resolution needed |
| Availability | Very High | Any region can serve any request |
| Partition Tolerance | Very High | Regions operate independently |

---

## General Capacity Estimation Template

```
┌─────────────────────────────────────────────────────────┐
│              CAPACITY ESTIMATION WORKSHEET                │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  TRAFFIC                                                 │
│  ─────────                                               │
│  DAU:              _______ users                         │
│  Read:Write ratio: _______:1                             │
│  Avg reads/user:   _______ /day                          │
│  Avg writes/user:  _______ /day                          │
│  Read QPS:         DAU * reads / 86400 = _______         │
│  Write QPS:        DAU * writes / 86400 = _______        │
│  Peak multiplier:  3x → Read peak: _______ QPS          │
│                                                          │
│  STORAGE                                                 │
│  ─────────                                               │
│  Avg object size:  _______ bytes                         │
│  New objects/day:  _______                               │
│  Daily growth:     objects * size = _______ GB           │
│  Retention:        _______ years                         │
│  Total storage:    daily * 365 * years = _______ TB     │
│                                                          │
│  BANDWIDTH                                               │
│  ──────────                                              │
│  Incoming:         write_QPS * obj_size = _______ MB/s  │
│  Outgoing:         read_QPS * obj_size = _______ MB/s   │
│                                                          │
│  MEMORY (CACHE)                                          │
│  ──────────────                                          │
│  Cache ratio:      20% of daily reads                    │
│  Cache size:       read_QPS * 86400 * 0.2 * size        │
│                    = _______ GB                          │
│  Servers (32GB):   cache_size / 32 = _______ nodes      │
│                                                          │
│  SERVERS                                                 │
│  ────────                                                │
│  QPS per server:   ~1000 (typical web server)            │
│  App servers:      peak_QPS / 1000 = _______            │
│  With redundancy:  servers * 1.3 = _______              │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## CAP Theorem Quick Reference

```
         Consistency
            ╱╲
           ╱  ╲
          ╱ CP ╲
         ╱      ╲
        ╱________╲
       ╱          ╲
      ╱     CA     ╲
     ╱   (single    ╲
    ╱    machine)    ╲
   ╱__________________╲
  Availability ──── Partition Tolerance

  CP Systems: HBase, MongoDB, Redis Cluster, ZooKeeper
  AP Systems: Cassandra, DynamoDB, CouchDB, Riak
  CA Systems: Traditional RDBMS (single node — no partition tolerance)

  In distributed systems, P is mandatory → choose C or A.
```

## PACELC Extension

```
  If Partition:        choose Availability or Consistency (PAC)
  Else (normal ops):   choose Latency or Consistency (ELC)

  ┌──────────────┬──────┬──────┐
  │ System       │ PA/PC│ EL/EC│
  ├──────────────┼──────┼──────┤
  │ DynamoDB     │ PA   │ EL   │
  │ Cassandra    │ PA   │ EL   │
  │ MongoDB      │ PC   │ EC   │
  │ HBase        │ PC   │ EC   │
  │ MySQL (InnoDB)│ PC  │ EC   │
  │ Cosmos DB    │ PA*  │ EL*  │  *tunable
  └──────────────┴──────┴──────┘
```
