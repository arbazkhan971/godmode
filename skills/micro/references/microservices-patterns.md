# Microservices Patterns Reference

Comprehensive guide to microservices architecture patterns covering decomposition, communication, data management, and observability.

---

## Table of Contents

1. [Service Decomposition Strategies](#service-decomposition-strategies)
2. [Communication Patterns](#communication-patterns)
3. [Data Management Patterns](#data-management-patterns)
4. [Observability Patterns](#observability-patterns)
5. [Deployment Patterns](#deployment-patterns)
6. [Security Patterns](#security-patterns)

---

## Service Decomposition Strategies

### Decomposition by Business Capability

Business capabilities represent what a business does to generate value. Each capability maps to a service.

```
  E-Commerce Platform
|  | Product |  | Order |  | Customer |  |
|  | Management |  | Management |  | Management |  |
|  | - catalog |  | - placement |  | - profile |  |
|  | - pricing |  | - tracking |  | - address |  |
|  | - inventory |  | - returns |  | - loyalty |  |
|  | Payment |  | Shipping |  | Marketing |  |
|  | Processing |  | & Delivery |  | & Promo |  |
|  | - charge |  | - routing |  | - campaigns |  |
|  | - refund |  | - tracking |  | - coupons |  |
|  | - ledger |  | - labels |  | - analytics |  |
```

**When to use**: Stable business domains with clear boundaries.

**Strengths**: Aligns with organizational structure (Conway's Law), stable boundaries, clear ownership.

**Weaknesses**: Business capabilities may overlap, cross-cutting concerns are hard to place.

### Decomposition by Subdomain (DDD)

Domain-Driven Design identifies bounded contexts through domain analysis.

```
  Domain Model Map
  CORE DOMAINS (competitive advantage):
|  | Pricing Engine |  | Recommendation |  |
|  | (complex rules, |  | Engine |  |
|  | dynamic pricing) |  | (ML-driven) |  |
  SUPPORTING DOMAINS (necessary but not differentiating):
|  | Inventory |  | Shipping |  |
|  | Management |  | Calculation |  |
  GENERIC DOMAINS (commodity — buy or use OSS):
|  | Authentication |  | Email / |  |
|  | (Auth0/Keycloak) |  | Notification |  |
```

**Context Mapping Relationships**:

```
| Order | Partnership | Inventory |
| Context | ◀══════════════════▶ | Context |
└───────┬───────┘                    └───────────────┘
  Customer/Supplier
┌───────▼───────┐     Anti-corruption    ┌───────────────┐
| Payment | Layer (ACL) | External |
| Context | ◀──────────────────────▶ | PSP API |
```

| Relationship | Description | Use When |
|-------------|-------------|----------|
| Partnership | Teams coordinate; shared success | Closely collaborating teams |
| Customer/Supplier | Upstream supplies, downstream consumes | Clear dependency direction |
| Conformist | Downstream conforms to upstream model | No leverage over upstream |
| Anti-Corruption Layer | Translation layer between contexts | Integrating with legacy/external |
| Shared Kernel | Shared subset of domain model | Tightly coupled subsystems |
| Open Host Service | Published API with protocol | Multiple consumers |

### Decomposition by Use Case / User Story

```
User Journey: "Place an Order"

Step 1: Browse    →  Product Service
Step 2: Add Cart  →  Cart Service
Step 3: Checkout  →  Order Service
Step 4: Pay       →  Payment Service
Step 5: Ship      →  Shipping Service
Step 6: Notify    →  Notification Service

Each step = potential service boundary
```

### Strangler Fig Pattern (Decomposing Monoliths)

```
Phase 1: Monolith handles everything
  MONOLITH
|  | Auth |  | Orders |  | Shipping |  |
Phase 2: New features as services; proxy routes
| API Gateway | ─────────────────────┐ |
| (Facade) |  |
└────────┬────────┘                     │
┌────────▼──────────────────┐   ┌───────▼──────┐
| MONOLITH |  | New Service |
| ┌────────┐ ┌────────┐ |  | (Shipping) |
|  | Auth |  | Orders |  |  |  |
| └────────┘ └────────┘ | └──────────────┘ |

Phase 3: Gradually extract more services
| API Gateway | ─────────────┬────────────┐ |
└────────┬────────┘             │            │
┌────────▼────────┐  ┌─────────▼──┐  ┌──────▼──────┐
| MONOLITH |  | Order |  | Shipping |
| ┌────────┐ |  | Service |  | Service |
|  | Auth |  | └────────────┘  └─────────────┘ |
Phase 4: Monolith fully replaced
| API Gateway | ──┬──────────┬────────────┐ |
└─────────────────┘  │          │            │
              ┌───────▼──┐ ┌────▼───────┐ ┌──▼──────────┐
| Auth |  | Order |  | Shipping |
| Service |  | Service |  | Service |
```

### Service Granularity Checklist

```
Too Coarse (merge candidate):
  [ ] Service has multiple reasons to change
  [ ] Service has multiple owners/teams
  [ ] Deployments frequently require coordination
  [ ] Service is a "god service" touching many tables

Too Fine (split too far):
  [ ] High inter-service chatter (>5 calls per request)
  [ ] Distributed transactions required for basic operations
  [ ] Team is managing >10 services per developer
  [ ] Latency unacceptable due to network hops

Right-Sized:
  [✓] Single team owns and operates the service
  [✓] Independent deploy cycle (weekly+)
  [✓] Minimal synchronous dependencies (<3)
  [✓] Clear domain boundary with stable API
  [✓] Data fits in a single database schema
```

---

## Communication Patterns

### Synchronous Communication

#### Request-Response (REST / gRPC)

```
┌──────────┐   HTTP/gRPC    ┌──────────┐   HTTP/gRPC    ┌──────────┐
| Service A | ──────────────▶ | Service B | ──────────────▶ | Service C |
|  | ◀────────────── |  | ◀────────────── |  |
└──────────┘   response     └──────────┘   response     └──────────┘

Timeline:
A ━━━━━━━━━┫ waiting ┣━━━━━━━━━━━━━┫ waiting ┣━━━━━━ response
           B ━━━━━━━━━┫ waiting ┣━━ response
                      C ━━━━━━━━ response

Total latency = latency(A→B) + latency(B→C) + processing
```

**REST vs gRPC Comparison**:

| Aspect | REST | gRPC |
|--------|------|------|
| Protocol | HTTP/1.1 or HTTP/2 | HTTP/2 |
| Payload | JSON (text) | Protobuf (binary) |
| Streaming | Limited (SSE, WebSocket) | Bidirectional streaming native |
| Code gen | OpenAPI (optional) | Protobuf (required) |
| Browser support | Native | Requires grpc-web proxy |
| Latency | Higher (~1-5ms overhead) | Lower (~0.5-1ms overhead) |
| Human readable | Yes | No (binary) |

#### API Composition Pattern

```
| Client | ───── GET ────────▶ | API Composer |
|  | ◀── combined ────── | (Aggregator) |
└──────────┘     response      └────────┬─────────┘
                  ┌──────▼──────┐ ┌─────▼─────┐ ┌─────▼─────┐
| User Svc |  | Order Svc |  | Review Svc |
| {name,email} |  | {orders} |  | {reviews} |
Combined Response:
{
  "user": { "name": "Alice", "email": "..." },
  "orders": [ ... ],
  "reviews": [ ... ]
}
```

### Asynchronous Communication

#### Message-Based (Point-to-Point)

```
┌──────────┐    message     ┌──────────┐    message     ┌──────────┐
| Service A | ──────────────▶ | Queue | ──────────────▶ | Service B |
| (sender) |  | (broker) |  | (receiver) |
Properties:
  - One producer, one consumer per message
  - Guaranteed delivery (with acks)
  - Load leveling (consumer processes at own pace)
  - Examples: SQS, RabbitMQ (direct exchange)
```

#### Event-Based (Publish-Subscribe)

```
| Service A |  | Service B |
| (publish) | ─── event ──▶┌──────────┐───────▶ | (subscribe) |
└──────────┘              │  Topic   │        └──────────┘
  (broker)
|  | ┌──────────┐ |
|  | ───────▶ | Service C |
                          └──────────┘        │(subscribe)│
Properties:
  - One producer, many consumers
  - Loose coupling (publisher unaware of subscribers)
  - Event replay possible (Kafka)
  - Examples: Kafka topics, SNS, Redis Pub/Sub
```

### Choreography vs Orchestration

#### Choreography (Decentralized)

```
Each service reacts to events independently:

┌──────────┐  OrderCreated  ┌──────────┐  PaymentDone  ┌──────────┐
| Order | ───────────────▶ | Payment | ───────────────▶ | Shipping |
| Service |  | Service |  | Service |
     ▲                                                       │
  ShippingDone

Pros:                           Cons:
+ No single point of failure    - Hard to track overall flow
+ Services are independent      - Difficult to debug
+ Easy to add new consumers     - Cycle detection is complex
+ Simple to implement           - No central error handling
```

#### Orchestration (Centralized)

```
Central orchestrator coordinates the workflow:

  Orchestrator
  (Order Saga)
       1.create       2.charge       3.ship
       ┌──────▼──────┐ ┌────▼───────┐ ┌───▼────────┐
| Order |  | Payment |  | Shipping |
| Service |  | Service |  | Service |
Pros:                           Cons:
+ Clear workflow visibility     - Single point of failure
+ Centralized error handling    - Orchestrator can become complex
+ Easy to reason about flow     - Tighter coupling to orchestrator
+ Compensation logic in one place - May bottleneck
```

### Communication Pattern Selection Guide

```
| Requirement | Pattern | Example |
| Need response now | Sync (REST/gRPC) | User login |
| Fire and forget | Async (queue) | Send email |
| Multiple consumers | Pub/Sub (topic) | Order placed event |
| Complex workflow | Orchestration | Order fulfillment |
| Loose coupling | Choreography | Notification routing |
| High throughput | Streaming | Click stream |
| Real-time updates | WebSocket/SSE | Live dashboard |
| Batch processing | Async + queue | Report generation |
```

### Service Mesh

```
  Service Mesh
|  | Service A |  | Service B |  |
|  | ┌─────────────┐ | mTLS | ┌─────────────┐ |  |
|  |  | Application |  |  |  | Application |  |  |
|  | └──────┬──────┘ |  | └──────▲──────┘ |  |
|  | ┌──────▼──────┐ |  | ┌──────┴──────┐ |  |
|  |  | Sidecar | ─┼──────────┼─ | Sidecar |  |  |
|  |  | Proxy |  |  |  | Proxy |  |  |
|  |  | (Envoy) |  |  |  | (Envoy) |  |  |
|  | └─────────────┘ |  | └─────────────┘ |  |
|  | Control Plane (Istio) |  |
|  | ┌────────┐  ┌────────┐  ┌────────────────┐ |  |
|  |  | Pilot |  | Citadel |  | Galley/Mixer |  |  |
|  |  | (routing |  | (certs) |  | (config/policy) |  |  |
|  | └────────┘  └────────┘  └────────────────┘ |  |
  Features:
  - Mutual TLS (mTLS) between services
  - Traffic management (canary, A/B, fault injection)
  - Observability (metrics, traces, logs)
  - Retry, timeout, circuit breaking
```

---

## Data Management Patterns

### Database Per Service

```
|  | User |  | Order |  | Product |  |
|  | Service |  | Service |  | Service |  |
  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐
|  | User DB |  | Order DB |  | Product DB |  |
|  | (Postgres) |  | (MySQL) |  | (MongoDB) |  |
  Rules:
  - Each service owns its data exclusively
  - No direct database access between services
  - Data shared only through APIs or events
  - Polyglot persistence (right DB for the job)
```

**Benefits**: Independent scaling, technology freedom, fault isolation.

**Challenges**: Cross-service queries, distributed transactions, data consistency.

### Saga Pattern

#### Choreography-Based Saga

```
┌─────────┐  OrderCreated  ┌─────────┐  PaymentOK  ┌─────────┐
| Order | ───────────────▶ | Payment | ────────────▶ | Inventory |
| Service |  | Service |  | Service |
| InventoryReserved |  |
  ◀─────────────────────────┼────────────────────────┘
  OrderConfirmed
     └─────────────────────────▶│

COMPENSATION (on failure):
  InventoryFailed
  ◀─────────────────────────┼────────────────────────┘
  RefundPayment
     └─────────────────────────▶│
  CancelOrder
     └─────────────────────────▶│
```

#### Orchestration-Based Saga

```
  Order Saga Orchestrator
  State Machine:
|  | PENDING | ──▶ | PAYMENT | ──▶ | INVENTORY |  |
|  |  |  | PENDING |  | PENDING |  |
  └─────────┘   └─────┬────┘   └─────┬─────┘
| fail | fail |  |
  ▼              ▼
|  | PAYMENT |  | INVENTORY |  |
|  | FAILED |  | FAILED |  |
|  | (cancel) |  | (refund + |  |
| └──────────┘ | cancel) |  |
  Success path:
  PENDING → PAYMENT_OK → INVENTORY_OK →
  SHIPPING_OK → CONFIRMED
  Each step: command → service → reply → next
```

### CQRS (Command Query Responsibility Segregation)

```
  CQRS Architecture
  WRITE SIDE                          READ SIDE
  ──────────                          ─────────
|  | Commands |  | Queries |  |
|  | (create, |  | (list, |  |
|  | update, |  | search, |  |
|  | delete) |  | report) |  |
  ┌────▼─────────┐                  ┌──────▼──────────┐
|  | Command |  | Query |  |
|  | Handler |  | Handler |  |
|  | (validation, |  | (direct read) |  |
|  | business | └──────┬──────────┘ |
|  | logic) |  |  |
  └────┬─────────┘                  ┌──────▼──────────┐
|  |  | Read Model |  |
| ┌────▼─────────┐ | (denormalized, |  |
|  | Write Model | ──events──▶ | materialized |  |
|  | (normalized, | projection | views) |  |
|  | source of |  |  |  |
|  | truth) |  | - Elasticsearch |  |
|  |  |  | - Redis |  |
|  | - PostgreSQL |  | - DynamoDB |  |
```

**When to use CQRS**:

| Signal | Description |
|--------|-------------|
| Read/Write asymmetry | Reads vastly outnumber writes (or vice versa) |
| Different models needed | Write model != read model |
| Performance | Read and write databases can scale independently |
| Complex queries | Read side can use specialized stores |
| Event sourcing | Natural fit with event-sourced write side |

**When NOT to use CQRS**:

| Signal | Description |
|--------|-------------|
| Simple CRUD | No difference between read/write models |
| Strong consistency required | Eventual consistency between models is unacceptable |
| Small scale | Complexity overhead not justified |
| Same team reads/writes | No organizational benefit |

### Shared Database Anti-Pattern and Alternatives

```
ANTI-PATTERN: Shared Database
| Service A |  | Service B |  | Service C |
              ┌──────▼──────┐
| Shared DB | ← coupling, schema lock-in, |
|  | no independent deploy |

ALTERNATIVE: API Data Access
┌──────────┐  API call  ┌──────────┐
| Service A | ───────────▶ | Service B |
|  | ◀─────────── | (data |
└───────────┘  response  │  owner)  │
                         ┌─────▼────┐
  B's DB

ALTERNATIVE: Event-Driven Data Replication
┌──────────┐  event    ┌──────────┐
| Service B | ─────────▶ | Service A |
| (source) | stream | (replica) |
┌─────▼─────┐          ┌─────▼─────┐
| B's DB |  | A's local |
| (source) |  | read copy |
```

### Data Consistency Patterns

#### Transactional Outbox

```
  Service A
  BEGIN TRANSACTION
|  | 1. INSERT INTO orders (...) |  |
|  | 2. INSERT INTO outbox ( |  |
|  | event_type, payload, status) |  |
  COMMIT
|  | Outbox Poller | ──── publish ──────────▶ | Message |
|  | (or CDC via | events | Broker |
|  | Debezium) |  |
  Outbox Table:
|  | id | evt_type | payload | status | ts |  |
|  | 1 | OrderNew | {json} | SENT | ... |  |
|  | 2 | OrderNew | {json} | PEND | ... |  |
```

#### Change Data Capture (CDC)

```
| Service |  | Database |  | CDC Tool |
| (writes) | ────▶ | (WAL/ | ────▶ | (Debezium) |
└──────────────┘     │   binlog)    │     └──────┬───────┘
                     └──────────────┘            │
                                          ┌──────▼───────┐
  Kafka
  (change
  events)
                             ┌──────▼──┐  ┌──────▼──┐  ┌─────▼───┐
| Search |  | Cache |  | Analyt. |
| Index |  | Update |  | Pipeline |
```

---

## Observability Patterns

### The Three Pillars

```
  Observability Stack
|  | LOGS |  | METRICS |  | TRACES |  |
|  | What |  | How much / |  | Where / |  |
|  | happened |  | How fast |  | How long |  |
|  | Structured |  | Counters |  | Distributed |  |
|  | events |  | Gauges |  | request |  |
|  |  |  | Histograms |  | flow |  |
|  | ELK/Loki |  | Prometheus |  | Jaeger/ |  |
|  |  |  | /Datadog |  | Zipkin |  |
  Correlation ID ties all three together across services
```

### Health Check API Pattern

```
GET /health

Response (healthy):
{
  "status": "UP",
  "version": "2.3.1",
  "uptime": "72h15m",
  "checks": {
    "database": {
      "status": "UP",
      "latency_ms": 3
    },
    "redis": {
      "status": "UP",
      "latency_ms": 1
    },
    "downstream_payment_svc": {
      "status": "UP",
      "latency_ms": 45
    }
  }
}

Response (degraded):
{
  "status": "DEGRADED",
  "checks": {
    "database": { "status": "UP" },
    "redis": { "status": "DOWN", "error": "Connection refused" },
    "downstream_payment_svc": { "status": "UP" }
  }
}

Health Check Types:
| Type | Purpose |
| Liveness | Is the process running? (restart) |
| Readiness | Can it handle traffic? (route) |
| Startup | Has it finished initializing? |
| Deep/Dependency | Are all dependencies healthy? |
```

### Distributed Tracing

```
Request Flow with Trace Context:

Client ──▶ API Gateway ──▶ Order Service ──▶ Payment Service
                                └──▶ Inventory Service

Trace: trace_id=abc123
  Span A: API Gateway [========]          50ms
  └─ Span B: Order Service   [==============] 120ms
  ├─ Span C: Payment Svc     [========]   80ms
  └─ Span D: Inventory Svc   [====]       40ms
  Total request time: 170ms
  Critical path: A → B → C

Span Context Propagation:
  Headers:
    traceparent: 00-abc123-span_b-01
    tracestate: vendor=value

  W3C Trace Context standard
```

### Log Aggregation

```
| Service A |  | Service B |  | Service C |
| (stdout) |  | (stdout) |  | (stdout) |
┌─────▼─────┐  ┌─────▼─────┐  ┌─────▼─────┐
| Log Agent |  | Log Agent |  | Log Agent |
| (Filebeat/ |  | (Filebeat/ |  | (Filebeat/ |
| Fluentd) |  | Fluentd) |  | Fluentd) |
            ┌────────▼────────┐
  Log Pipeline
  (Logstash /
  Kafka)
            ┌────────▼────────┐
  Log Storage
  (Elasticsearch
  / Loki)
            ┌────────▼────────┐
  Visualization
  (Kibana /
  Grafana)
```

### Structured Log Format

```json
{
  "timestamp": "2024-01-15T10:30:00.123Z",
  "level": "ERROR",
  "service": "order-service",
  "instance": "order-svc-7b4f9-abc12",
  "trace_id": "abc123def456",
  "span_id": "span_789",
  "correlation_id": "req-550e8400",
  "message": "Payment processing failed",
  "error": {
    "type": "PaymentDeclinedException",
    "message": "Insufficient funds",
    "stack": "..."
  },
  "context": {
    "user_id": "usr_12345",
    "order_id": "ord_67890",
    "amount": 99.99,
    "currency": "USD"
  },
  "duration_ms": 234
}
```

### Metrics Patterns

```
RED Method (Request-driven services):
  Rate:     requests per second
  Errors:   failed requests per second
  Duration: distribution of request latencies (p50, p95, p99)

USE Method (Resource-oriented):
  Utilization:  % of resource capacity used
  Saturation:   queue depth / backlog
  Errors:       resource error count

Four Golden Signals (Google SRE):
  Latency:    time to serve a request
  Traffic:    demand on the system
  Errors:     rate of failed requests
  Saturation: how "full" the system is

Dashboard Layout:
  Service: order-service
|  | Request Rate |  | Error Rate |  | P99 Latency |  |
|  | 523/sec |  | 0.3% |  | 245ms |  |
|  | ▁▂▃▅▇▅▃▂▁ |  | ▁▁▁▂▁▁▁▁▁ |  | ▁▂▂▃▂▂▁▂▁ |  |
|  | CPU Usage |  | Memory |  | Connections |  |
|  | 67% |  | 2.1 GB |  | 145/200 |  |
|  | ▃▃▅▅▇▇▅▅▃ |  | ▅▅▅▅▅▆▆▆▆ |  | ▃▃▃▃▅▅▆▅▃ |  |
```

### Alerting Strategy

```
Alert Severity Levels:

  P1 (Page immediately):
    - Service down (0 healthy instances)
    - Error rate > 10% for 5 minutes
    - P99 latency > 5s for 5 minutes
    - Data loss detected

  P2 (Page during business hours):
    - Error rate > 2% for 15 minutes
    - P99 latency > 2s for 15 minutes
    - Disk usage > 85%
    - Certificate expiring < 7 days

  P3 (Ticket):
    - Error rate > 0.5% for 1 hour
    - Memory usage trending up (leak)
    - Dependency degraded
    - Queue depth growing

  P4 (Dashboard/notification):
    - Performance regression detected
    - Non-critical dependency slow
    - Resource usage > 60%

Alert Routing:
  P1 → PagerDuty → On-call engineer → Escalation (15min)
  P2 → Slack #incidents → Team lead
  P3 → Jira ticket → Sprint backlog
  P4 → Slack #monitoring → FYI
```

---

## Deployment Patterns

### Blue-Green Deployment

```
  Load Balancer
       ┌──────▼──────┐         ┌──────▼──────┐
| BLUE |  | GREEN |
| (v1.0) |  | (v1.1) |
| ACTIVE ● |  | STANDBY ○ |
| ┌──┐┌──┐┌──┐ |  | ┌──┐┌──┐┌──┐ |
| └──┘└──┘└──┘ |  | └──┘└──┘└──┘ |
Switch: route 100% traffic from Blue to Green
Rollback: route back to Blue (instant)
```

### Canary Deployment

```
  Load Balancer
  (weighted)
| 95% | 5% |
       ┌──────▼──────┐         ┌──────▼──────┐
| STABLE |  | CANARY |
| (v1.0) |  | (v1.1) |
| ┌──┐┌──┐┌──┐ |  | ┌──┐ |
| └──┘└──┘└──┘ |  | └──┘ |
Progression: 5% → 25% → 50% → 100%
Metrics gate: error rate < 0.1%, p99 < 200ms
Auto-rollback: if metrics breach threshold
```

---

## Security Patterns

### Authentication / Authorization

```
┌──────────┐   JWT     ┌──────────────┐
| Client | ─────────▶ | API Gateway |
└──────────┘           │  (validate   │
  JWT)
  claims: {sub, roles, scopes}
       ┌──────▼──────┐ ┌─────▼─────┐ ┌───────▼─────┐
| Service A |  | Service B |  | Service C |
| (check |  | (check |  | (check |
| scope: |  | scope: |  | scope: |
| read:users) |  | write: |  | admin) |
       └─────────────┘ │  orders) │ └─────────────┘
```

### Secrets Management

```
  Secrets Management
|  | Service | ───▶ | Vault / AWS Secrets |  |
|  | (on start) | ◀─── | Manager |  |
|  | Env vars: |  | Secrets: |  |
|  | DB_URL=vault |  | db/password = **** |  |
|  | API_KEY=vault |  | api/key = **** |  |
| └──────────────┘ |  |  |
|  | Features: |  |
|  | - Auto-rotation |  |
|  | - Audit log |  |
|  | - Lease-based access |  |
|  | - Dynamic secrets |  |
```

---

## Pattern Selection Decision Tree

```
Start: "I need to build a microservices system"
├─ How to split the monolith?
  ├─ Clear business domains? → Decompose by Business Capability
  ├─ Complex domain model?   → Decompose by Subdomain (DDD)
  └─ Legacy system?          → Strangler Fig Pattern
├─ How should services communicate?
  ├─ Need immediate response?     → Sync (REST/gRPC)
  ├─ Can tolerate delay?          → Async (message queue)
  ├─ Multiple consumers needed?   → Pub/Sub (event topic)
  └─ Complex multi-step workflow? → Saga (orchestration)
├─ How to manage data?
  ├─ Service independence critical? → Database per service
  ├─ Cross-service transactions?    → Saga pattern
  ├─ Read/Write asymmetry?          → CQRS
  └─ Reliable event publishing?     → Transactional outbox
├─ How to observe the system?
  ├─ What happened?     → Structured logging + aggregation
  ├─ How is it doing?   → Metrics (RED/USE)
  └─ Where is it slow?  → Distributed tracing
└─ How to deploy safely?
   ├─ Instant rollback needed?    → Blue-Green
   ├─ Gradual rollout preferred?  → Canary
   └─ Feature toggling?           → Feature flags
```
