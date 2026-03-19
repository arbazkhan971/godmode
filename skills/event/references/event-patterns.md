# Event-Driven Patterns Reference

Comprehensive guide to event sourcing, CQRS, saga patterns, reliable publishing, and event schema evolution for distributed systems.

---

## Table of Contents

1. [Event Sourcing](#event-sourcing)
2. [CQRS](#cqrs)
3. [Saga Patterns](#saga-patterns)
4. [Outbox Pattern](#outbox-pattern)
5. [Event Schema Evolution](#event-schema-evolution)
6. [Event Choreography](#event-choreography)
7. [Event Store Design](#event-store-design)
8. [Idempotent Consumers](#idempotent-consumers)
9. [Dead Letter Queues](#dead-letter-queues)
10. [Pattern Combinations](#pattern-combinations)

---

## Event Sourcing

### Core Concept

```
┌──────────────────────────────────────────────────────────────┐
│                   Event Sourcing vs CRUD                      │
│                                                               │
│  CRUD (state-based):                                         │
│  ┌──────────────────────────────────────────┐                │
│  │  Account: #12345                         │                │
│  │  Balance: $750.00                        │                │
│  │  Last updated: 2024-01-15                │                │
│  └──────────────────────────────────────────┘                │
│  → Only current state. History lost.                         │
│                                                               │
│  Event Sourcing (event-based):                               │
│  ┌──────────────────────────────────────────┐                │
│  │  Event Stream: account-12345              │                │
│  │                                           │                │
│  │  [1] AccountOpened   {amount: $0}         │                │
│  │  [2] MoneyDeposited  {amount: $1000}      │                │
│  │  [3] MoneyWithdrawn  {amount: $200}       │                │
│  │  [4] MoneyWithdrawn  {amount: $50}        │                │
│  │                                           │                │
│  │  Current state = replay events:           │                │
│  │  $0 + $1000 - $200 - $50 = $750          │                │
│  └──────────────────────────────────────────┘                │
│  → Full history preserved. State is derived.                 │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Event Store Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    Event Store                                │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐    │
│  │  Events Table                                        │    │
│  │  ┌─────┬──────────┬──────────┬────────┬───────────┐  │    │
│  │  │ seq │ stream   │ version  │ type   │ data      │  │    │
│  │  ├─────┼──────────┼──────────┼────────┼───────────┤  │    │
│  │  │  1  │ acc-123  │    1     │ Opened │ {amt:0}   │  │    │
│  │  │  2  │ acc-123  │    2     │ Deposit│ {amt:1000}│  │    │
│  │  │  3  │ acc-456  │    1     │ Opened │ {amt:500} │  │    │
│  │  │  4  │ acc-123  │    3     │ Wdraw  │ {amt:200} │  │    │
│  │  │  5  │ acc-456  │    2     │ Deposit│ {amt:100} │  │    │
│  │  └─────┴──────────┴──────────┴────────┴───────────┘  │    │
│  │                                                       │    │
│  │  Unique constraint: (stream_id, version)              │    │
│  │  → Optimistic concurrency control                     │    │
│  │                                                       │    │
│  │  Append-only: events are NEVER updated or deleted     │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                               │
│  Read patterns:                                               │
│    - Load stream: SELECT * WHERE stream='acc-123'            │
│                   ORDER BY version ASC                        │
│    - Subscribe: poll WHERE seq > last_seen_seq               │
│    - All events: SELECT * ORDER BY seq ASC                   │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Aggregate Reconstruction

```
Command: WithdrawMoney($100)
│
▼
┌──────────────────────────────────────────────────┐
│  1. Load events for aggregate                     │
│     SELECT * FROM events                          │
│     WHERE stream_id = 'account-123'               │
│     ORDER BY version ASC                          │
│                                                   │
│  2. Replay events to build current state          │
│     state = initial_state                         │
│     for event in events:                          │
│       state = apply(state, event)                 │
│                                                   │
│     Event [1] AccountOpened  → balance = $0       │
│     Event [2] MoneyDeposited → balance = $1000    │
│     Event [3] MoneyWithdrawn → balance = $800     │
│                                                   │
│  3. Validate command against current state        │
│     Can withdraw $100? balance($800) >= $100 ✓    │
│                                                   │
│  4. Produce new event                             │
│     MoneyWithdrawn {amount: $100}                 │
│                                                   │
│  5. Append to event store                         │
│     INSERT INTO events (stream, version, type, data) │
│     VALUES ('account-123', 4, 'MoneyWithdrawn',   │
│             '{"amount": 100}')                    │
│     WHERE NOT EXISTS (version = 4)  ← OCC check  │
│                                                   │
│  6. Publish event to subscribers                  │
│     → projections, read models, other services    │
│                                                   │
└──────────────────────────────────────────────────┘
```

### Snapshots

```
┌──────────────────────────────────────────────────────────┐
│                    Snapshots                               │
│                                                          │
│  Problem: Replaying 10,000 events is slow                │
│  Solution: Periodic snapshots of aggregate state         │
│                                                          │
│  Event Stream:                                           │
│  [1]─[2]─[3]─...─[1000]─[SNAP]─[1001]─[1002]─...─[1500]│
│                            ▲                              │
│                       snapshot at                         │
│                       version 1000                        │
│                                                          │
│  Reconstruction with snapshot:                           │
│    1. Load latest snapshot (version 1000)                │
│       state = snapshot.state                             │
│    2. Load events AFTER snapshot                         │
│       SELECT * WHERE stream='acc-123' AND version > 1000 │
│    3. Replay only 500 events instead of 1500            │
│                                                          │
│  Snapshot Table:                                         │
│  ┌──────────┬─────────┬───────────────────────────┐      │
│  │ stream   │ version │ state                     │      │
│  ├──────────┼─────────┼───────────────────────────┤      │
│  │ acc-123  │ 1000    │ {balance:5430, status:...}│      │
│  │ acc-456  │  500    │ {balance:890, status:...} │      │
│  └──────────┴─────────┴───────────────────────────┘      │
│                                                          │
│  Snapshot Strategy:                                      │
│    - Every N events (e.g., every 100)                    │
│    - On time interval (e.g., daily)                      │
│    - On demand (when load time exceeds threshold)        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### Projections

```
┌──────────────────────────────────────────────────────────────┐
│                       Projections                             │
│                                                               │
│  Event Store ────────────────▶ Projection ────▶ Read Model   │
│  (source of truth)             (transformer)    (query-opt.) │
│                                                               │
│  Example: Account Balance Projection                         │
│                                                               │
│  Events:                      Read Model (materialized view):│
│  ┌────────────────────┐       ┌─────────────────────────┐    │
│  │ AccountOpened       │       │  account_balances       │    │
│  │ MoneyDeposited      │  ────▶│  ┌────────┬─────────┐  │    │
│  │ MoneyWithdrawn      │       │  │ acc_id │ balance │  │    │
│  │ AccountClosed       │       │  ├────────┼─────────┤  │    │
│  └────────────────────┘       │  │ 123    │ $750    │  │    │
│                                │  │ 456    │ $600    │  │    │
│                                │  └────────┴─────────┘  │    │
│                                └─────────────────────────┘    │
│                                                               │
│  Multiple projections from same events:                      │
│                                                               │
│  Events ──┬──▶ Balance projection ──▶ account_balances       │
│           │                                                   │
│           ├──▶ Transaction history ──▶ transaction_log       │
│           │                                                   │
│           ├──▶ Monthly report ──▶ monthly_summaries          │
│           │                                                   │
│           └──▶ Fraud detection ──▶ suspicious_patterns       │
│                                                               │
│  Projection Tracking:                                        │
│  ┌──────────────────┬──────────────┬────────────────┐        │
│  │ projection_name  │ last_seq     │ status         │        │
│  ├──────────────────┼──────────────┼────────────────┤        │
│  │ balance          │ 15,234       │ RUNNING        │        │
│  │ txn_history      │ 15,234       │ RUNNING        │        │
│  │ monthly_report   │ 14,800       │ REBUILDING     │        │
│  └──────────────────┴──────────────┴────────────────┘        │
│                                                               │
│  Rebuild: replay ALL events to recreate a projection         │
│  from scratch (fixing bugs, new requirements)                │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## CQRS

### Architecture with Event Sourcing

```
┌──────────────────────────────────────────────────────────────┐
│              CQRS + Event Sourcing                            │
│                                                               │
│  COMMAND SIDE                                                 │
│  ────────────                                                 │
│  ┌──────────┐    ┌───────────────┐    ┌──────────────┐       │
│  │ Command  │───▶│   Command     │───▶│  Event Store │       │
│  │ (write)  │    │   Handler     │    │  (append     │       │
│  └──────────┘    │               │    │   only)      │       │
│                  │ 1. Load agg   │    └──────┬───────┘       │
│                  │ 2. Validate   │           │               │
│                  │ 3. New events │           │ publish       │
│                  │ 4. Append     │           │               │
│                  └───────────────┘           │               │
│                                              │               │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ─ │
│                                              │               │
│  QUERY SIDE                                  │               │
│  ──────────                                  │               │
│                                    ┌─────────▼──────────┐    │
│  ┌──────────┐    ┌────────────┐   │   Event Processor   │    │
│  │  Query   │───▶│  Query     │   │   (projection)      │    │
│  │  (read)  │    │  Handler   │   └─────────┬──────────┘    │
│  └──────────┘    └─────┬──────┘             │               │
│                        │              ┌─────▼──────┐         │
│                        └──────────────▶  Read DB   │         │
│                                       │  (Elastic, │         │
│                                       │   Redis,   │         │
│                                       │   Postgres)│         │
│                                       └────────────┘         │
│                                                               │
│  Consistency: EVENTUAL (write → event → projection → read)   │
│  Typical lag: 10ms - 1s                                      │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Read/Write Model Separation

```
┌──────────────────────────────────────────────────────────────┐
│            Read vs Write Model Design                         │
│                                                               │
│  WRITE MODEL (normalized, optimized for consistency)         │
│  ┌────────────────────────────────────────────────┐          │
│  │  orders                                        │          │
│  │  ┌─────┬─────────┬────────┬────────┬────────┐ │          │
│  │  │ id  │ user_id │ status │ total  │ created│ │          │
│  │  └─────┴─────────┴────────┴────────┴────────┘ │          │
│  │                                                │          │
│  │  order_items                                   │          │
│  │  ┌─────┬──────────┬────────┬─────┬──────────┐ │          │
│  │  │ id  │ order_id │ prod_id│ qty │ price    │ │          │
│  │  └─────┴──────────┴────────┴─────┴──────────┘ │          │
│  │                                                │          │
│  │  payments                                      │          │
│  │  ┌─────┬──────────┬────────┬────────┐         │          │
│  │  │ id  │ order_id │ amount │ status │         │          │
│  │  └─────┴──────────┴────────┴────────┘         │          │
│  └────────────────────────────────────────────────┘          │
│                                                               │
│  READ MODEL (denormalized, optimized for queries)            │
│  ┌────────────────────────────────────────────────┐          │
│  │  order_summary_view                            │          │
│  │  ┌─────┬──────┬────────┬───────┬─────────────┐│          │
│  │  │ id  │ user │ items  │ total │ payment_    ││          │
│  │  │     │_name │ [{name,│       │ status      ││          │
│  │  │     │      │  qty,  │       │             ││          │
│  │  │     │      │  price}│       │             ││          │
│  │  │     │      │  ...]  │       │             ││          │
│  │  └─────┴──────┴────────┴───────┴─────────────┘│          │
│  │                                                │          │
│  │  → Single query returns everything the UI needs│          │
│  │  → No JOINs needed                            │          │
│  │  → Optimized for the specific read pattern    │          │
│  └────────────────────────────────────────────────┘          │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Multiple Read Models

```
Same event stream → multiple optimized read models:

Event: OrderPlaced
       │
       ├──▶ Read Model 1: Order List (PostgreSQL)
       │    For: customer order history page
       │    Schema: {order_id, date, total, status, item_count}
       │
       ├──▶ Read Model 2: Order Search (Elasticsearch)
       │    For: admin order search
       │    Schema: {full text + all fields + facets}
       │
       ├──▶ Read Model 3: Dashboard Metrics (TimescaleDB)
       │    For: real-time business dashboard
       │    Schema: {orders_per_hour, revenue, avg_order_value}
       │
       └──▶ Read Model 4: Recommendation Input (Redis)
            For: "customers also bought" feature
            Schema: {user_id → [product_ids]}
```

### Handling Eventual Consistency in UI

```
┌──────────────────────────────────────────────────────────┐
│         UI Strategies for Eventual Consistency             │
│                                                          │
│  Strategy 1: Optimistic UI                               │
│  ─────────────────────────                               │
│  User clicks "Place Order"                               │
│    → UI immediately shows "Order Placed"                 │
│    → Command sent in background                          │
│    → If command fails: show error + rollback UI          │
│                                                          │
│  Strategy 2: Read-Your-Writes                            │
│  ──────────────────────────                              │
│  After write: read from WRITE model for this user        │
│  After propagation: switch back to READ model            │
│  Implementation:                                         │
│    Cookie/header: X-Read-After-Write: {timestamp}        │
│    If read_model.updated_at < timestamp:                 │
│      query write model instead                           │
│                                                          │
│  Strategy 3: Polling / Subscription                      │
│  ──────────────────────────────                          │
│  After write: poll read model until consistent           │
│    or: subscribe via WebSocket for update event          │
│                                                          │
│  Strategy 4: Causal Consistency Token                    │
│  ─────────────────────────────────                       │
│  Write returns: {result: "ok", version: 42}              │
│  Subsequent reads include: If-Version: 42                │
│  Read handler: wait until projection >= version 42       │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Saga Patterns

### Choreography Saga (Detailed)

```
┌──────────────────────────────────────────────────────────────┐
│              Choreography Saga: Order Fulfillment             │
│                                                               │
│  Happy Path:                                                  │
│  ═══════════                                                  │
│                                                               │
│  Order Svc          Payment Svc        Inventory Svc          │
│  ─────────          ───────────        ─────────────          │
│  │                  │                  │                       │
│  │ OrderCreated ───▶│                  │                       │
│  │                  │ PaymentCharged──▶│                       │
│  │                  │                  │ StockReserved ──▶     │
│  │◀─────────────────┼──────────────────┤                       │
│  │ OrderConfirmed   │                  │                       │
│  │                  │                  │                       │
│                                                               │
│  Shipping Svc       Notification Svc                          │
│  ────────────       ────────────────                          │
│  │                  │                                         │
│  │◀─ StockReserved  │                                         │
│  │ ShipmentCreated─▶│                                         │
│  │                  │ NotifySent                               │
│                                                               │
│  Compensation Path (payment fails):                           │
│  ══════════════════════════════════                            │
│                                                               │
│  Order Svc          Payment Svc        Inventory Svc          │
│  ─────────          ───────────        ─────────────          │
│  │                  │                  │                       │
│  │ OrderCreated ───▶│                  │                       │
│  │                  │ PaymentFailed ──▶│                       │
│  │◀─────────────────┤                  │                       │
│  │ OrderCancelled   │                  │                       │
│  │                  │                  │                       │
│                                                               │
│  Compensation Path (stock reservation fails):                │
│  ════════════════════════════════════════                      │
│                                                               │
│  Order Svc          Payment Svc        Inventory Svc          │
│  ─────────          ───────────        ─────────────          │
│  │                  │                  │                       │
│  │ OrderCreated ───▶│                  │                       │
│  │                  │ PaymentCharged──▶│                       │
│  │                  │                  │ StockInsufficient     │
│  │                  │◀─────────────────┤                       │
│  │                  │ PaymentRefunded  │                       │
│  │◀─────────────────┤                  │                       │
│  │ OrderCancelled   │                  │                       │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Orchestration Saga (Detailed)

```
┌──────────────────────────────────────────────────────────────┐
│            Orchestration Saga: Order Fulfillment              │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐    │
│  │              Saga Orchestrator                        │    │
│  │                                                       │    │
│  │  State Machine:                                       │    │
│  │                                                       │    │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────┐            │    │
│  │  │ STARTED │─▶│ PAYMENT  │─▶│ RESERVED │            │    │
│  │  │         │  │ PENDING  │  │ PENDING  │            │    │
│  │  └─────────┘  └────┬─────┘  └────┬─────┘            │    │
│  │                     │             │                   │    │
│  │                     │ fail        │ fail              │    │
│  │                     ▼             ▼                   │    │
│  │              ┌──────────┐  ┌──────────────┐          │    │
│  │              │ PAYMENT  │  │ COMPENSATING │          │    │
│  │              │ FAILED   │  │ (refund)     │          │    │
│  │              └────┬─────┘  └──────┬───────┘          │    │
│  │                   │               │                   │    │
│  │                   ▼               ▼                   │    │
│  │              ┌────────────────────────┐               │    │
│  │              │      CANCELLED        │               │    │
│  │              └────────────────────────┘               │    │
│  │                                                       │    │
│  │  Success: STARTED → PAYMENT_OK → RESERVED_OK →       │    │
│  │           SHIPPED → CONFIRMED                        │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                               │
│  Saga Log (for recovery):                                    │
│  ┌──────┬──────────────┬──────────┬─────────────────────┐    │
│  │ saga │ step         │ status   │ data                │    │
│  ├──────┼──────────────┼──────────┼─────────────────────┤    │
│  │ s001 │ create_order │ DONE     │ {order_id: 123}     │    │
│  │ s001 │ charge_pay   │ DONE     │ {payment_id: 456}   │    │
│  │ s001 │ reserve_stock│ FAILED   │ {error: "no stock"} │    │
│  │ s001 │ refund_pay   │ DONE     │ {refund_id: 789}    │    │
│  │ s001 │ cancel_order │ DONE     │ {cancelled: true}   │    │
│  └──────┴──────────────┴──────────┴─────────────────────┘    │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Choreography vs Orchestration Decision Guide

```
┌───────────────────────┬──────────────────┬─────────────────────┐
│ Criterion             │ Choreography     │ Orchestration       │
├───────────────────────┼──────────────────┼─────────────────────┤
│ Number of steps       │ 2-4 (simple)     │ 4+ (complex)        │
│ Visibility            │ Hard to trace    │ Central dashboard   │
│ Coupling              │ Loose            │ Tighter to orch.    │
│ Single point failure  │ None             │ Orchestrator        │
│ Error handling        │ Distributed      │ Centralized         │
│ Compensation logic    │ Per-service      │ In orchestrator     │
│ Adding new steps      │ Add subscriber   │ Modify orchestrator │
│ Testing               │ Integration heavy│ Unit-testable       │
│ Debugging             │ Correlation IDs  │ Saga log            │
│ Team autonomy         │ High             │ Medium              │
│ Cyclic dependencies   │ Risk             │ Avoided             │
└───────────────────────┴──────────────────┴─────────────────────┘

Rule of thumb:
  - 2-3 services, simple flow → Choreography
  - 4+ services, complex compensation → Orchestration
  - Mix: choreography between bounded contexts,
         orchestration within a bounded context
```

### Saga Compensation Design

```
┌──────────────────────────────────────────────────────────┐
│           Compensation Transaction Design                 │
│                                                          │
│  Forward Action          Compensation                    │
│  ──────────────          ────────────                    │
│  Create order       →   Cancel order                     │
│  Reserve inventory  →   Release inventory                │
│  Charge payment     →   Refund payment                   │
│  Create shipment    →   Cancel shipment                  │
│  Send notification  →   Send cancellation notice         │
│  Create account     →   Deactivate account               │
│                                                          │
│  Compensation Rules:                                     │
│  1. Compensations execute in REVERSE order               │
│  2. Compensations must be IDEMPOTENT                     │
│  3. Compensations must ALWAYS succeed (retried forever)  │
│  4. Compensations are SEMANTIC inverses                  │
│     (not undo — you cannot un-send an email)             │
│                                                          │
│  Steps: T1 → T2 → T3 → T4 (fail)                       │
│  Compensate: C3 → C2 → C1                               │
│                                                          │
│  Non-compensatable steps:                                │
│    - Sending email → send correction/apology email       │
│    - External API call → log for manual reconciliation   │
│    - Physical shipment → initiate return                 │
│                                                          │
│  Pivot Transaction:                                      │
│    The step after which the saga MUST go forward.        │
│    Before pivot: can compensate                          │
│    After pivot: can only retry (forward recovery)        │
│                                                          │
│    T1 → T2 → [PIVOT: T3] → T4 → T5                     │
│    If T4 fails: retry T4 (don't compensate T3)          │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Outbox Pattern

### Transactional Outbox

```
┌──────────────────────────────────────────────────────────────┐
│                 Transactional Outbox Pattern                   │
│                                                               │
│  Problem: Dual-write inconsistency                           │
│                                                               │
│  BAD (non-atomic):                                           │
│    1. Write to DB         ✓ (succeeds)                       │
│    2. Publish to Kafka    ✗ (fails — crash/network)          │
│    → DB updated but event lost                               │
│                                                               │
│  SOLUTION: Outbox table in same DB transaction               │
│                                                               │
│  ┌───────────────────────────────────────────────────┐       │
│  │  BEGIN TRANSACTION                                │       │
│  │                                                    │       │
│  │  INSERT INTO orders (id, user_id, total, status)  │       │
│  │  VALUES ('ord-123', 'usr-456', 99.99, 'CREATED');│       │
│  │                                                    │       │
│  │  INSERT INTO outbox (id, aggregate_type,           │       │
│  │    aggregate_id, event_type, payload)              │       │
│  │  VALUES (uuid(), 'Order', 'ord-123',              │       │
│  │    'OrderCreated',                                 │       │
│  │    '{"order_id":"ord-123","total":99.99}');        │       │
│  │                                                    │       │
│  │  COMMIT                                            │       │
│  └───────────────────────────────────────────────────┘       │
│                                                               │
│  Either BOTH succeed or NEITHER does (atomic).               │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Outbox Relay Mechanisms

```
┌──────────────────────────────────────────────────────────────┐
│                Outbox Relay Options                            │
│                                                               │
│  Option 1: Polling Publisher                                  │
│  ────────────────────────────                                 │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐           │
│  │  Outbox   │─poll─│  Relay   │─pub──│  Kafka   │           │
│  │  Table    │      │  Process │      │          │           │
│  └──────────┘      └──────────┘      └──────────┘           │
│                                                               │
│  SELECT * FROM outbox                                        │
│  WHERE published = false                                     │
│  ORDER BY created_at ASC                                     │
│  LIMIT 100;                                                  │
│                                                               │
│  -- After successful publish:                                │
│  UPDATE outbox SET published = true WHERE id IN (...);       │
│  -- Or: DELETE FROM outbox WHERE id IN (...);                │
│                                                               │
│  Polling interval: 100ms-1s                                  │
│  Pros: Simple                                                │
│  Cons: Polling overhead, slight delay                        │
│                                                               │
│  ─────────────────────────────────────────────────           │
│                                                               │
│  Option 2: Change Data Capture (CDC)                         │
│  ────────────────────────────────────                         │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐           │
│  │  Outbox   │─WAL──│ Debezium │─pub──│  Kafka   │           │
│  │  Table    │      │  (CDC)   │      │          │           │
│  └──────────┘      └──────────┘      └──────────┘           │
│                                                               │
│  Reads database WAL/binlog directly.                         │
│  No polling needed. Near real-time.                          │
│                                                               │
│  Pros: Lower latency, no polling overhead                    │
│  Cons: More infrastructure (Debezium + Kafka Connect)        │
│                                                               │
│  ─────────────────────────────────────────────────           │
│                                                               │
│  Option 3: Listen/Notify (PostgreSQL)                        │
│  ─────────────────────────────────────                        │
│  Trigger on outbox INSERT → NOTIFY channel                   │
│  Relay process: LISTEN channel → publish to Kafka            │
│                                                               │
│  Pros: Real-time, built-in                                   │
│  Cons: PostgreSQL-specific, lost on connection drop          │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Outbox Table Schema

```
┌──────────────────────────────────────────────────────────┐
│                Outbox Table Design                         │
│                                                          │
│  CREATE TABLE outbox (                                   │
│    id              UUID PRIMARY KEY,                     │
│    aggregate_type  VARCHAR(255) NOT NULL,                │
│    aggregate_id    VARCHAR(255) NOT NULL,                │
│    event_type      VARCHAR(255) NOT NULL,                │
│    payload         JSONB NOT NULL,                       │
│    metadata        JSONB,           -- trace_id, etc.    │
│    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),     │
│    published_at    TIMESTAMP,                            │
│    retry_count     INT DEFAULT 0,                        │
│    status          VARCHAR(20) DEFAULT 'PENDING'         │
│    -- PENDING, PUBLISHED, FAILED                         │
│  );                                                      │
│                                                          │
│  CREATE INDEX idx_outbox_pending                         │
│    ON outbox (created_at)                                │
│    WHERE status = 'PENDING';                             │
│                                                          │
│  Cleanup: DELETE WHERE status='PUBLISHED'                │
│           AND published_at < NOW() - INTERVAL '7 days'; │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Event Schema Evolution

### Schema Compatibility Types

```
┌──────────────────────────────────────────────────────────────┐
│              Schema Compatibility Matrix                       │
│                                                               │
│  BACKWARD COMPATIBLE (new reader, old event):                │
│  ─────────────────────────────────────────────               │
│  Old event: {order_id, total}                                │
│  New schema: {order_id, total, currency: "USD"}              │
│  → New reader can read old events (uses default for currency)│
│  Rule: only ADD optional fields with defaults                │
│                                                               │
│  FORWARD COMPATIBLE (old reader, new event):                 │
│  ───────────────────────────────────────────                  │
│  New event: {order_id, total, currency: "EUR"}               │
│  Old schema: {order_id, total}                               │
│  → Old reader ignores unknown field "currency"               │
│  Rule: readers must ignore unknown fields                    │
│                                                               │
│  FULL COMPATIBLE (both directions):                          │
│  ─────────────────────────────────                            │
│  Both backward and forward compatible.                       │
│  Strictest, safest.                                          │
│                                                               │
│  BREAKING CHANGE (incompatible):                             │
│  ───────────────────────────────                              │
│  Old: {total: 99.99}      (number)                           │
│  New: {total: "99.99"}    (string)                           │
│  → Type change breaks old readers                            │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Schema Evolution Strategies

```
┌──────────────────────────────────────────────────────────────┐
│            Schema Evolution Strategies                         │
│                                                               │
│  Strategy 1: Schema Registry (Confluent)                     │
│  ────────────────────────────────────────                     │
│  Producer ──▶ Schema Registry ──▶ Validate compatibility     │
│                    │                                          │
│               ┌────▼────┐                                    │
│               │ Schema  │  v1: {order_id, total}             │
│               │ Store   │  v2: {order_id, total, currency}   │
│               │         │  v3: {order_id, total, currency,   │
│               │         │       discount}                    │
│               └─────────┘                                    │
│                                                               │
│  Event payload includes schema_id in header:                 │
│  [schema_id=2][binary payload]                               │
│  Consumer looks up schema_id → deserialize correctly         │
│                                                               │
│  ─────────────────────────────────────────                    │
│                                                               │
│  Strategy 2: Event Versioning                                │
│  ────────────────────────────                                 │
│                                                               │
│  Approach A: Versioned event types                           │
│    OrderCreatedV1 {order_id, total}                          │
│    OrderCreatedV2 {order_id, total, currency}                │
│                                                               │
│  Approach B: Version field in payload                        │
│    {version: 2, order_id: "123", total: 99, currency: "USD"}│
│                                                               │
│  Approach C: Content-type versioning                         │
│    Header: content-type: application/vnd.order.v2+json       │
│                                                               │
│  ─────────────────────────────────────────                    │
│                                                               │
│  Strategy 3: Upcasting                                       │
│  ────────────────────                                         │
│  Convert old events to new schema on read:                   │
│                                                               │
│  Event Store: {order_id: "123", total: 99}  (v1)            │
│  Upcaster:    add currency = "USD" (default)                 │
│  Consumer:    {order_id: "123", total: 99, currency: "USD"} │
│                                                               │
│  Chain: v1 → upcast_v1_to_v2 → upcast_v2_to_v3 → latest   │
│                                                               │
│  ─────────────────────────────────────────                    │
│                                                               │
│  Strategy 4: Weak/Strong Schema with Envelope               │
│  ─────────────────────────────────────────────                │
│  {                                                            │
│    "event_id": "evt-789",                                    │
│    "event_type": "OrderCreated",                             │
│    "schema_version": 2,                                      │
│    "timestamp": "2024-01-15T10:30:00Z",                     │
│    "metadata": {"trace_id": "abc", "source": "order-svc"},  │
│    "data": {                                                  │
│      "order_id": "ord-123",                                  │
│      "total": 99.99,                                         │
│      "currency": "USD"                                       │
│    }                                                          │
│  }                                                            │
│  Envelope fields: never change                               │
│  Data fields: evolve per schema_version                      │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Safe Schema Changes

```
┌──────────────────────────┬──────────┬──────────────────────┐
│ Change                   │ Safe?    │ Notes                │
├──────────────────────────┼──────────┼──────────────────────┤
│ Add optional field       │ YES      │ With sensible default│
│ Remove optional field    │ YES*     │ *If consumers ignore │
│ Add required field       │ NO       │ Breaks old producers │
│ Remove required field    │ NO       │ Breaks old consumers │
│ Rename field             │ NO       │ Treated as remove+add│
│ Change field type        │ NO       │ Deserialization break│
│ Change field semantics   │ NO       │ Silent corruption    │
│ Add enum value           │ DEPENDS  │ Forward compat issue │
│ Remove enum value        │ NO       │ Breaks old events    │
│ Widen numeric type       │ YES      │ int32 → int64        │
│ Narrow numeric type      │ NO       │ int64 → int32 risk   │
└──────────────────────────┴──────────┴──────────────────────┘

Golden Rule: make additive, optional changes only.
For breaking changes: create a new event type.
```

---

## Event Choreography

### Event Flow Mapping

```
┌──────────────────────────────────────────────────────────────┐
│              Event Flow Map                                    │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐     │
│  │                                                     │     │
│  │  OrderCreated ──┬──▶ PaymentService.handleOrder()  │     │
│  │                 ├──▶ InventoryService.reserve()     │     │
│  │                 └──▶ AnalyticsService.track()       │     │
│  │                                                     │     │
│  │  PaymentCharged ──┬──▶ OrderService.confirmOrder() │     │
│  │                   └──▶ NotifService.sendReceipt()  │     │
│  │                                                     │     │
│  │  PaymentFailed ───┬──▶ OrderService.cancelOrder()  │     │
│  │                   └──▶ NotifService.sendFailure()  │     │
│  │                                                     │     │
│  │  StockReserved ───────▶ ShipService.createShip()   │     │
│  │                                                     │     │
│  │  StockInsufficient ──┬▶ PayService.refund()        │     │
│  │                      └▶ OrderService.cancel()      │     │
│  │                                                     │     │
│  │  ShipmentCreated ────▶ NotifService.sendTracking() │     │
│  │                                                     │     │
│  └─────────────────────────────────────────────────────┘     │
│                                                               │
│  This map should be maintained as living documentation.      │
│  Tools: AsyncAPI spec, event catalog, event storming.        │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Idempotent Consumers

### Idempotency Strategies

```
┌──────────────────────────────────────────────────────────────┐
│                Idempotent Consumer Patterns                    │
│                                                               │
│  Problem: at-least-once delivery means duplicates            │
│                                                               │
│  Strategy 1: Event ID Deduplication                          │
│  ──────────────────────────────────                           │
│  ┌──────────────────────────────────────────┐                │
│  │  processed_events table                  │                │
│  │  ┌──────────────┬───────────────────┐    │                │
│  │  │ event_id     │ processed_at      │    │                │
│  │  ├──────────────┼───────────────────┤    │                │
│  │  │ evt-001      │ 2024-01-15 10:30  │    │                │
│  │  │ evt-002      │ 2024-01-15 10:31  │    │                │
│  │  └──────────────┴───────────────────┘    │                │
│  │                                           │                │
│  │  On receive event:                        │                │
│  │    INSERT INTO processed_events (event_id)│                │
│  │    ON CONFLICT DO NOTHING;                │                │
│  │    if rows_affected == 1:                 │                │
│  │      process event (first time)           │                │
│  │    else:                                  │                │
│  │      skip (duplicate)                     │                │
│  └──────────────────────────────────────────┘                │
│                                                               │
│  Strategy 2: Idempotent Operations                           │
│  ─────────────────────────────────                            │
│  Design operations to be naturally idempotent:               │
│    SET balance = $750  (idempotent)                           │
│    vs                                                         │
│    ADD $100 to balance (NOT idempotent)                      │
│                                                               │
│  Strategy 3: Conditional Write                               │
│  ─────────────────────────────                                │
│  UPDATE orders SET status = 'CONFIRMED'                      │
│  WHERE id = 'ord-123' AND status = 'PENDING';               │
│  → Second execution: 0 rows affected (no-op)                │
│                                                               │
│  Strategy 4: Version Check                                   │
│  ─────────────────────────                                    │
│  UPDATE accounts SET balance = 750, version = 5              │
│  WHERE id = 'acc-123' AND version = 4;                       │
│  → Duplicate replay: version mismatch, no-op                │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Dead Letter Queues

### DLQ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                Dead Letter Queue (DLQ)                         │
│                                                               │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐             │
│  │ Producer  │────▶│  Main    │────▶│ Consumer │             │
│  └──────────┘     │  Queue   │     │          │             │
│                   └──────────┘     └────┬─────┘             │
│                                         │                    │
│                                    Processing                │
│                                    fails N times             │
│                                         │                    │
│                                         ▼                    │
│                                  ┌──────────────┐            │
│                                  │  Retry Queue │            │
│                                  │  (delay: 30s)│            │
│                                  └──────┬───────┘            │
│                                         │                    │
│                                    Still failing             │
│                                    after M retries           │
│                                         │                    │
│                                         ▼                    │
│                                  ┌──────────────┐            │
│                                  │  Dead Letter │            │
│                                  │  Queue       │            │
│                                  │              │            │
│                                  │ Manual review│            │
│                                  │ + alerting   │            │
│                                  └──────────────┘            │
│                                                               │
│  DLQ Processing:                                             │
│    1. Alert on new DLQ messages                              │
│    2. Investigate root cause                                 │
│    3. Fix consumer bug (if any)                              │
│    4. Replay DLQ messages back to main queue                 │
│    5. Archive or discard after resolution                    │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Pattern Combinations

### Event Sourcing + CQRS + Saga

```
┌──────────────────────────────────────────────────────────────┐
│        Complete Event-Driven Architecture                     │
│                                                               │
│  ┌─────────┐  command  ┌────────────────────────────┐        │
│  │ Client  │──────────▶│   Write Side               │        │
│  └────┬────┘           │                            │        │
│       │                │  Aggregate ──▶ Event Store │        │
│       │                │  (validate)    (append)    │        │
│       │                └──────────┬─────────────────┘        │
│       │                           │                           │
│       │                    ┌──────▼──────┐                   │
│       │                    │ Event Bus   │                   │
│       │                    │ (Kafka)     │                   │
│       │                    └──┬──┬──┬────┘                   │
│       │                       │  │  │                        │
│       │           ┌───────────┘  │  └───────────┐           │
│       │           │              │              │           │
│       │    ┌──────▼──────┐ ┌────▼─────┐ ┌──────▼──────┐    │
│       │    │ Projection  │ │  Saga    │ │ Notification│    │
│       │    │ (read model)│ │ Orch.    │ │ Handler     │    │
│       │    └──────┬──────┘ └──────────┘ └─────────────┘    │
│       │           │                                          │
│       │    ┌──────▼──────┐                                  │
│       │    │  Read DB    │                                  │
│       │    │  (Elastic)  │                                  │
│       │    └──────▲──────┘                                  │
│       │           │                                          │
│       │  query    │                                          │
│       └───────────┘                                          │
│                                                               │
│  Flow: command → aggregate → event → bus →                   │
│        projection + saga + notification                      │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### When to Use What

```
┌───────────────────────────┬────────────────────────────────┐
│ Requirement               │ Pattern                        │
├───────────────────────────┼────────────────────────────────┤
│ Full audit trail          │ Event Sourcing                 │
│ Read/write optimization   │ CQRS                           │
│ Cross-service transaction │ Saga                           │
│ Reliable event publishing │ Outbox Pattern                 │
│ Schema changes over time  │ Schema Registry + Versioning   │
│ At-least-once handling    │ Idempotent Consumers           │
│ Poison message handling   │ Dead Letter Queue              │
│ Temporal queries          │ Event Sourcing + Projections   │
│ Real-time materialization │ CQRS + Change Data Capture     │
│ Multi-service workflows   │ Saga + Event Choreography      │
└───────────────────────────┴────────────────────────────────┘
```
