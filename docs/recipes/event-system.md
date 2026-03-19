# Recipe: Building an Event-Driven System

> From monolithic request-response to fully decoupled event-driven architecture. Kafka, event sourcing, CQRS, and production observability.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `architect → event → queue → build → test → observe → ship` |
| **Timeline** | 1-2 weeks for core event infrastructure |
| **Team size** | 2-5 developers |
| **Example project** | "OrderFlow" — an e-commerce order processing system with event sourcing and CQRS |

---

## Prerequisites

- Node.js, Go, or Java environment configured
- Kafka or RabbitMQ cluster provisioned (or Docker Compose for local dev)
- PostgreSQL for event store and read models
- Redis for projections cache
- Godmode installed and configured

---

## The Scenario

You are building an order processing system where:
- Orders go through multiple stages (placed, paid, shipped, delivered)
- Multiple services need to react to order events (inventory, notifications, analytics)
- You need a complete audit trail of every state change
- Read patterns differ significantly from write patterns
- The system must handle 10K orders/hour at peak

---

## Technology Recommendations

| Layer | Recommendation | Why |
|-------|---------------|-----|
| Message broker | Apache Kafka | Durable, ordered, replayable event log |
| Alternative broker | RabbitMQ | Simpler, better for routing patterns, lower throughput |
| Event store | PostgreSQL (append-only table) | ACID guarantees for event persistence |
| Read database | PostgreSQL + Redis | Materialized views for queries, Redis for hot data |
| Framework | Node.js (TypeScript) or Go | Event-driven patterns fit both well |
| Serialization | Avro with Schema Registry | Schema evolution with backward compatibility |
| Orchestration | Docker Compose (dev), Kubernetes (prod) | Multi-service local development |

**When to choose Kafka vs. RabbitMQ:**
- **Kafka:** Event sourcing, event replay, high throughput, ordered processing, log compaction
- **RabbitMQ:** Task queues, routing patterns, low latency, simpler operations, temporary messages

---

## Session Transcript

### Phase 1: Architect — Design the Event-Driven Architecture

```
> /godmode:architect I need to design an event-driven order processing
  system. Services: Order Service, Inventory Service, Payment Service,
  Notification Service, Analytics Service. Orders go through: placed →
  paid → shipped → delivered. Each transition triggers downstream actions.

Godmode: Analyzing requirements...

ARCHITECTURE CONTEXT:
System: OrderFlow — event-driven order processing
Pattern: Event Sourcing + CQRS
Scale: 10K orders/hour peak
Services: 5 bounded contexts

PATTERN EVALUATION:

Pattern A: Choreography (events only, no orchestrator)
  Pros: Fully decoupled, each service owns its reactions
  Cons: Hard to track order flow, distributed debugging
  Fit: ★★★☆☆

Pattern B: Orchestration (Saga pattern with central coordinator)
  Pros: Clear flow visibility, easier error handling
  Cons: Single point of coordination, tighter coupling
  Fit: ★★★★☆

Pattern C: Hybrid (Orchestration for order flow + Choreography for side effects)
  Pros: Order flow is clear, side effects are decoupled
  Cons: Two patterns to understand
  Fit: ★★★★★

RECOMMENDATION: Pattern C — Hybrid

Order lifecycle (orchestrated):
  OrderSaga coordinates: place → reserve inventory → charge payment → confirm

Side effects (choreographed):
  OrderPlaced → NotificationService sends confirmation email
  OrderPlaced → AnalyticsService records conversion
  OrderShipped → NotificationService sends tracking email
  PaymentFailed → NotificationService sends retry notice

EVENT FLOW:

  ┌─────────────┐     OrderPlaced      ┌──────────────┐
  │   Order      │ ──────────────────→  │  Inventory    │
  │   Service    │                      │  Service      │
  │  (commands)  │ ←────────────────── │  (reserves)   │
  └──────┬───────┘   InventoryReserved  └──────────────┘
         │
         │ PaymentRequested     ┌──────────────┐
         └────────────────────→ │  Payment      │
         ←──────────────────── │  Service      │
           PaymentCharged       └──────────────┘

  All events published to Kafka ──→ NotificationService
                                ──→ AnalyticsService
                                ──→ Event Store (audit log)

Saved: docs/architecture/orderflow-event-architecture.md
Saved: docs/adr/001-hybrid-event-architecture.md
Commit: "architect: OrderFlow event-driven architecture — hybrid orchestration + choreography"
```

**Time: 30 minutes.**

### Phase 2: Event — Define the Event Catalog

```
> /godmode:event

Godmode: Reading architecture... Designing event catalog...

EVENT CATALOG:

Domain Events (things that happened):
  OrderPlaced        — { orderId, customerId, items[], total, placedAt }
  InventoryReserved  — { orderId, reservations[{sku, quantity, warehouseId}] }
  InventoryFailed    — { orderId, failedItems[{sku, requested, available}] }
  PaymentRequested   — { orderId, amount, currency, paymentMethod }
  PaymentCharged     — { orderId, paymentId, chargedAmount, chargedAt }
  PaymentFailed      — { orderId, reason, retryable }
  OrderConfirmed     — { orderId, confirmedAt, estimatedDelivery }
  OrderShipped       — { orderId, trackingNumber, carrier, shippedAt }
  OrderDelivered     — { orderId, deliveredAt, signature }
  OrderCancelled     — { orderId, reason, cancelledBy, cancelledAt }

Commands (requests to do something):
  PlaceOrder         — { customerId, items[], shippingAddress }
  ReserveInventory   — { orderId, items[] }
  ChargePayment      — { orderId, amount, paymentMethod }
  ShipOrder          — { orderId, warehouseId }
  CancelOrder        — { orderId, reason }

Event schema versioning:
  Version 1: Initial schema
  Evolution strategy: backward-compatible additions only
  Breaking changes: new event type + consumer migration

Kafka topics:
  order.events        — all order domain events (partitioned by orderId)
  inventory.events    — inventory domain events (partitioned by sku)
  payment.events      — payment domain events (partitioned by orderId)
  notification.commands — notification requests (partitioned by customerId)

Partitioning strategy:
  - By orderId for order events → guarantees ordering per order
  - By sku for inventory → ordering per product
  - Consumer groups per service → parallel processing

Saved: docs/events/orderflow-event-catalog.md
Saved: schemas/avro/order-placed-v1.avsc
Saved: schemas/avro/payment-charged-v1.avsc
[... all event schemas ...]

Commit: "event: OrderFlow event catalog — 10 domain events, 5 commands, Avro schemas"
```

**Time: 25 minutes.**

### Phase 3: Queue — Configure Message Infrastructure

```
> /godmode:queue --broker kafka

Godmode: Configuring Kafka infrastructure...

KAFKA CONFIGURATION:

Topics:
  order.events
    Partitions: 12 (matches expected consumer parallelism)
    Replication: 3 (fault tolerance)
    Retention: 30 days (replayable)
    Cleanup: delete (not compact — need full history)

  inventory.events
    Partitions: 6
    Replication: 3
    Retention: 7 days

  payment.events
    Partitions: 6
    Replication: 3
    Retention: 30 days

  notification.commands
    Partitions: 4
    Replication: 3
    Retention: 3 days

  dead-letter.events
    Partitions: 1
    Replication: 3
    Retention: 90 days (investigate failures)

Consumer groups:
  order-saga-consumer        — OrderService (processes inventory + payment events)
  inventory-consumer         — InventoryService (processes order commands)
  payment-consumer           — PaymentService (processes payment commands)
  notification-consumer      — NotificationService (processes all events)
  analytics-consumer         — AnalyticsService (processes all events)
  event-store-consumer       — EventStore (persists all events to PostgreSQL)

Consumer configuration:
  Auto-commit: disabled (manual commit after processing)
  Max poll records: 100
  Session timeout: 30s
  Max retries: 3 with exponential backoff (1s, 5s, 30s)
  Dead letter: after 3 failures, publish to dead-letter.events

Idempotency:
  - Producer: enable.idempotence=true (exactly-once within partition)
  - Consumer: deduplicate by eventId in processing layer

Files generated:
  infra/kafka/docker-compose.kafka.yml    — local Kafka + Zookeeper + Schema Registry
  infra/kafka/topics.sh                   — topic creation script
  src/lib/kafka-producer.ts               — idempotent producer with schema validation
  src/lib/kafka-consumer.ts               — consumer with retry, DLQ, and manual commit
  src/lib/event-store.ts                  — append-only PostgreSQL event store

Commit: "infra: Kafka configuration — topics, consumers, DLQ, idempotent producer"
```

**Time: 20 minutes.**

### Phase 4: Build — Implement the Services

```
> /godmode:build

Godmode: Reading architecture and event catalog... Starting implementation...

SERVICE IMPLEMENTATION:

Service 1: Order Service (Saga Orchestrator)
  Task 1: Event sourcing aggregate — Order with apply/fold pattern ✓
  Task 2: OrderSaga — orchestrates place → reserve → charge → confirm ✓
  Task 3: Saga compensation — rollback on inventory or payment failure ✓
  Task 4: Command handlers — PlaceOrder, CancelOrder ✓
  Task 5: Read model projection — order list, order detail ✓
  Task 6: REST/GraphQL API for order queries and commands ✓

Service 2: Inventory Service
  Task 7: Inventory aggregate — stock levels with reservations ✓
  Task 8: ReserveInventory handler — check stock, reserve, publish result ✓
  Task 9: ReleaseInventory handler — saga compensation ✓
  Task 10: Read model — current stock levels per warehouse ✓

Service 3: Payment Service
  Task 11: Payment aggregate — charge lifecycle ✓
  Task 12: ChargePayment handler — Stripe integration ✓
  Task 13: Refund handler — saga compensation ✓
  Task 14: Webhook handler — async payment confirmations ✓

Service 4: Notification Service
  Task 15: Event listener — subscribe to all relevant events ✓
  Task 16: Email templates — order confirmation, shipping, delivery ✓
  Task 17: Notification preferences — respect user opt-outs ✓

Service 5: Analytics Service
  Task 18: Event consumer — aggregate metrics from all events ✓
  Task 19: Time-series projections — orders/hour, revenue/day ✓
  Task 20: Real-time dashboard API ✓

Shared Infrastructure:
  Task 21: Event store — append-only PostgreSQL with event replay ✓
  Task 22: Saga state machine — persistent saga state with recovery ✓
  Task 23: Idempotency middleware — deduplicate by eventId ✓
  Task 24: Correlation ID propagation — trace events across services ✓

BUILD COMPLETE: 24 tasks, 89 tests, all green.

Commit: "feat: OrderFlow services — Order, Inventory, Payment, Notification, Analytics"
```

**Time: 6-8 hours.** Event sourcing aggregates and the saga orchestrator are the most complex pieces.

### Phase 5: Test — Event-Driven Testing Strategies

```
> /godmode:test --coverage-target 95

Godmode: Analyzing coverage and designing event-driven test strategy...

TEST STRATEGY:

Layer 1: Unit tests (aggregate logic)
  - Order aggregate: apply events, compute state
  - Saga state machine: transitions, compensation paths
  - Inventory: reservation math, concurrent reservations

Layer 2: Integration tests (service + Kafka)
  - Publish event → verify consumer processes it
  - Saga happy path: PlaceOrder → OrderConfirmed
  - Saga failure: PaymentFailed → inventory released
  - Dead letter queue: malformed event → DLQ after retries

Layer 3: Contract tests (event schemas)
  - Producer publishes events matching Avro schema
  - Consumer can deserialize all event versions
  - Schema evolution: v1 consumer reads v2 event (backward compatible)

Layer 4: End-to-end tests (full flow)
  - Place order → payment charged → order confirmed → email sent
  - Place order → inventory unavailable → order cancelled → refund issued

Tests written:
  Unit: 89 existing + 22 new = 111
  Integration: 34 new (with Testcontainers for Kafka)
  Contract: 18 new (Avro schema compatibility)
  E2E: 8 new (full order lifecycle)

Coverage: 78% → 95.8% ✓ TARGET MET

Key test patterns:
  - Testcontainers: spin up real Kafka and PostgreSQL for integration tests
  - Event replay: rebuild read model from event store, verify consistency
  - Chaos: inject consumer failures, verify DLQ and retry behavior
  - Time travel: test saga timeout handling with mocked clock

Commit: "test: event-driven test suite — unit, integration, contract, E2E — 171 tests"
```

**Time: 2-3 hours.**

### Phase 6: Observe — Event-Driven Observability

```
> /godmode:observe

Godmode: Setting up observability for event-driven system...

OBSERVABILITY SETUP:

Metrics (Prometheus + Grafana):
  Event metrics:
    - events_published_total (by topic, event_type)
    - events_consumed_total (by consumer_group, topic, event_type)
    - event_processing_duration_seconds (histogram)
    - consumer_lag (by consumer_group, topic, partition)
    - dead_letter_events_total (by topic, error_reason)
    - saga_duration_seconds (histogram, by outcome)
    - saga_compensation_total (by reason)

  Business metrics:
    - orders_placed_total
    - orders_confirmed_total
    - orders_cancelled_total (by reason)
    - payment_charge_duration_seconds
    - inventory_reservation_failures_total

Logging (Structured JSON):
  - Every event published: { eventId, type, topic, correlationId, timestamp }
  - Every event consumed: { eventId, type, consumerGroup, processingTime }
  - Saga transitions: { sagaId, from, to, trigger, correlationId }
  - Dead letter: { eventId, type, error, retryCount, originalTopic }

Tracing (OpenTelemetry):
  - Distributed trace from API request through Kafka to all consumers
  - Correlation ID propagated in Kafka headers
  - Span per: API handler → event publish → consumer process → side effect

Dashboards:
  1. Event Flow Dashboard
     - Events/second by type (real-time)
     - Consumer lag per group (should be near zero)
     - Processing time percentiles
     - Dead letter queue depth

  2. Saga Dashboard
     - Active sagas count
     - Saga completion rate and duration
     - Compensation (rollback) frequency
     - Timeout rate

  3. Business Dashboard
     - Orders funnel: placed → confirmed → shipped → delivered
     - Drop-off rate at each stage
     - Average order processing time

Alerting:
  - Consumer lag > 1000 for 5 minutes → PagerDuty
  - Dead letter queue depth increasing → Slack
  - Saga timeout rate > 1% → PagerDuty
  - Event publishing failures → PagerDuty
  - Consumer error rate > 0.5% → Slack

Commit: "observe: event-driven observability — metrics, tracing, dashboards, alerts"
```

**Time: 45 minutes.**

### Phase 7: Ship — Deploy to Production

```
> /godmode:ship --deploy production

Godmode: Starting 8-phase shipping workflow...

Phase 1: INVENTORY
  38 commits, 72 files changed across 5 services
  Features: event sourcing, saga, CQRS, notifications, analytics

Phase 2: CHECKLIST
  ✓ Tests: 171/171 passing
  ✓ Avro schema compatibility: all schemas backward compatible
  ✓ Consumer lag: 0 on staging
  ✓ Dead letter queue: empty
  ✓ Saga timeout: configured (30s for payment, 60s for full flow)
  ✓ Idempotency: verified with duplicate event injection
  ✓ Kafka replication factor: 3
  ✓ All services have health checks

Phase 3: PREPARE
  ✓ Docker images built for all 5 services
  ✓ Kafka topics created in production
  ✓ Database migrations applied
  ✓ Schema Registry updated with all Avro schemas

Phase 4: DRY RUN
  ✓ Staging deployment verified
  ✓ End-to-end order flow: PlaceOrder → OrderConfirmed (1.2s)
  ✓ Load test: 10K orders/hour sustained for 30 minutes
  ✓ Saga compensation tested: payment failure → inventory released

Phase 5: DEPLOY
  ✓ All services deployed (rolling update)
  ✓ Kafka consumers rebalanced
  ✓ Health checks: all green

Phase 6: VERIFY
  ✓ Production smoke: order placed and confirmed
  ✓ Consumer lag: 0
  ✓ Event flow dashboard: events flowing
  ✓ No dead letter events

Phase 7: LOG
  Ship log: .godmode/ship-log.tsv
  Version: v1.0.0

Phase 8: MONITOR
  T+0:  ✓ Deployed
  T+5:  ✓ Consumer lag 0, processing time p99 85ms
  T+15: ✓ 42 orders processed, 0 failures
  T+30: ✓ All clear. Production launch confirmed stable.

OrderFlow v1.0.0 is LIVE.
```

---

## Event Sourcing Patterns

### The Event Store

```
Events table (append-only):
  id          — UUID, unique event identifier
  stream_id   — aggregate ID (e.g., orderId)
  version     — sequential per stream (optimistic concurrency)
  type        — event type (e.g., "OrderPlaced")
  data        — JSON event payload
  metadata    — { correlationId, causationId, userId, timestamp }
  created_at  — wall clock time

Key properties:
  - Append-only: events are never updated or deleted
  - Ordered: version column ensures ordering within a stream
  - Replayable: rebuild any aggregate by replaying its events
  - Auditable: complete history of every state change
```

### CQRS Read Model Projection

```
Write side:                              Read side:
  PlaceOrder command                      GET /orders?status=confirmed
       │                                       │
       ▼                                       ▼
  Order Aggregate                         Read Model (PostgreSQL)
       │                                       ▲
       ▼                                       │
  OrderPlaced event ──→ Kafka ──→ Projector ───┘
                                  (builds materialized view)
```

The write side validates commands and emits events. The read side consumes events and builds optimized query models. They can use different databases, different schemas, and scale independently.

### Saga Compensation

When a step fails, the saga must undo all previous steps:

```
Happy path:  PlaceOrder → ReserveInventory → ChargePayment → ConfirmOrder
                   ✓              ✓                ✓              ✓

Failure at payment:
             PlaceOrder → ReserveInventory → ChargePayment → [FAIL]
                   ✓              ✓                ✗
                                  │
             Compensate: ←── ReleaseInventory ←── (no refund needed)
             CancelOrder
```

---

## Common Pitfalls

| Pitfall | Why It Happens | Godmode Prevention |
|---------|---------------|-------------------|
| Lost events | Producer does not wait for ack | Idempotent producer with acks=all |
| Duplicate processing | Consumer crashes after processing, before commit | Idempotency middleware deduplicates by eventId |
| Out-of-order events | Multiple partitions for same aggregate | Partition by aggregate ID |
| Schema breakage | Event schema changed without migration | Avro Schema Registry with compatibility checks |
| Unbounded consumer lag | Slow consumer cannot keep up | `/godmode:observe` alerts on lag > threshold |
| Saga stuck | Service down, no timeout | Saga timeout with compensation after deadline |
| Event store bloat | No snapshot strategy | Periodic snapshots for long-lived aggregates |

---

## Custom Chain for Event-Driven Projects

```yaml
# .godmode/chains.yaml
chains:
  new-event-flow:
    description: "Add a new event-driven workflow"
    steps:
      - architect     # design the event flow
      - event         # define new events and schemas
      - queue         # configure topics and consumers
      - build         # implement handlers and projections
      - test          # unit + integration + contract
      - observe       # dashboards and alerts
      - ship

  event-replay:
    description: "Rebuild read models from event store"
    steps:
      - observe       # check current state
      - build         # updated projection logic
      - test          # verify projection correctness
      - deploy        # deploy new projector
      - observe       # monitor rebuild progress
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [Building a GraphQL API](graphql-api.md) — If your event system serves a GraphQL API
- [From Docker to Kubernetes](docker-k8s.md) — Deploying multi-service event systems
- [Full Observability Setup](monitoring-setup.md) — Deep dive into monitoring event flows
