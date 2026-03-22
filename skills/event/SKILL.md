---
name: event
description: |
  Event-driven architecture skill. Activates when user needs to design event sourcing systems, implement CQRS, configure message brokers (Kafka, RabbitMQ, SQS, NATS), design event schemas with versioning, set up dead letter queues and retry policies, or implement idempotency patterns. Triggers on: /godmode:event, "event sourcing", "CQRS", "message broker", "Kafka setup", "event schema", "dead letter queue", "idempotency", or when the orchestrator detects event-driven architecture work.
---

# Event -- Event-Driven Architecture

## When to Activate
- User invokes `/godmode:event`
- User says "event sourcing", "CQRS", "event-driven architecture"
- User says "set up Kafka", "configure RabbitMQ", "message broker design"
- User says "event schema", "dead letter queue", "retry policy", "idempotency"
- When building systems that need loose coupling between components
- When `/godmode:micro` identifies async communication needs between services
- When `/godmode:plan` includes event-driven design tasks

## Workflow

### Step 1: Event Architecture Assessment
Understand the system requirements and choose the right event-driven pattern:

```
EVENT ARCHITECTURE CONTEXT:
Project: <name and purpose>
Current State: No events | Basic pub/sub | Partial event sourcing | Full CQRS/ES
Consistency Requirement: Strong | Eventual (seconds) | Eventual (minutes)
Throughput: <events per second — current and projected>
Consumer Count: <number of services consuming events>
Ordering Requirement: None | Per-entity | Global
Retention: <how long events must be stored>
Replay Requirement: Yes (audit/rebuild) | No
Compliance: <GDPR, HIPAA, SOX requirements affecting event data>
```

If the user has not specified context, ask: "What is driving the move to events? Do you need event sourcing (full history rebuild) or just async messaging (fire-and-forget notifications)?"

### Step 2: Event Sourcing Design
Store state as a sequence of immutable events rather than current-state snapshots:

#### Event Store Design
```
EVENT STORE SCHEMA:

+---------------------------------------------------------+
|  Table: events                                           |
+---------------------------------------------------------+
|  event_id        UUID PRIMARY KEY                        |
|  aggregate_type  VARCHAR(100) NOT NULL                   |
|  aggregate_id    UUID NOT NULL                           |
|  event_type      VARCHAR(200) NOT NULL                   |
|  event_version   INTEGER NOT NULL                        |
|  data            JSONB NOT NULL                          |
|  metadata        JSONB NOT NULL                          |
|  created_at      TIMESTAMP NOT NULL                      |
+---------------------------------------------------------+
|  UNIQUE (aggregate_id, event_version)                    |
|  INDEX ON (aggregate_type, aggregate_id)                 |
|  INDEX ON (event_type)                                   |
|  INDEX ON (created_at)                                   |
+---------------------------------------------------------+

AGGREGATE RECONSTRUCTION:
  1. Load all events for aggregate_id, ordered by event_version
  2. Apply each event to build current state
  3. Cache current state (snapshot) for performance

SNAPSHOT OPTIMIZATION:
+---------------------------------------------------------+
|  Table: snapshots                                        |
+---------------------------------------------------------+
|  aggregate_id    UUID PRIMARY KEY                        |
|  aggregate_type  VARCHAR(100) NOT NULL                   |
|  state           JSONB NOT NULL                          |
|  version         INTEGER NOT NULL                        |
|  created_at      TIMESTAMP NOT NULL                      |
+---------------------------------------------------------+

Snapshot strategy:
  - Take snapshot every N events (e.g., every 100)
  - Rebuild: Load snapshot + events after snapshot version
  - Reduces load time from O(all events) to O(events since snapshot)
```

#### Event Sourcing Example
```
AGGREGATE: Order

Events in order:
  1. OrderCreated      { order_id, customer_id, items, total }
  2. PaymentReceived   { payment_id, amount, method }
  3. OrderConfirmed    { confirmed_at }
  4. ItemShipped       { shipment_id, tracking_number }
  5. OrderDelivered    { delivered_at, signature }

State reconstruction:
  OrderCreated     -> status: PENDING, items: [...], total: 99.99
  PaymentReceived  -> status: PAID, payment: { id, amount }
  OrderConfirmed   -> status: CONFIRMED, confirmed_at: ...
  ItemShipped      -> status: SHIPPED, tracking: ABC123
  OrderDelivered   -> status: DELIVERED, delivered_at: ...

Current state = fold(events, initialState)
```

### Step 3: CQRS Implementation
Separate the read model (query) from the write model (command):

```
CQRS ARCHITECTURE:

WRITE SIDE (Commands):
+-------------------+     +-------------------+     +-------------------+
|  API / Client     | --> |  Command Handler  | --> |  Event Store      |
|                   |     |  (validates,      |     |  (append-only)    |
|  CreateOrder      |     |   applies rules)  |     |                   |
|  CancelOrder      |     +-------------------+     +-------------------+
|  UpdateAddress    |                                       |
+-------------------+                                       | publish
                                                            v
                                                   +-------------------+
                                                   |  Event Bus        |
                                                   |  (Kafka/RabbitMQ) |
                                                   +-------------------+
                                                            |
                                                            | project
                                                            v
READ SIDE (Queries):                               +-------------------+
+-------------------+     +-------------------+     |  Projection       |
|  API / Client     | --> |  Query Handler    | <-- |  (builds read     |
|                   |     |  (fast reads)     |     |   models)         |
|  GetOrder         |     +-------------------+     +-------------------+
|  ListOrders       |            |
|  SearchOrders     |            v
+-------------------+     +-------------------+
                          |  Read Database    |
                          |  (optimized for   |
                          |   queries)        |
                          +-------------------+

SEPARATION:
- Write model: Normalized, event-sourced, enforces business rules
- Read model: Denormalized, optimized for specific query patterns
- Projection: Asynchronous process that transforms events into read models
- Eventual consistency: Read model is milliseconds to seconds behind write model
```

#### Projection Design
```
PROJECTIONS:
+--------------------------------------------------------------+
|  Projection          | Source Events       | Read Model        |
+--------------------------------------------------------------+
|  OrderSummary        | OrderCreated,       | orders_summary    |
|                      | OrderConfirmed,     | (denormalized)    |
|                      | OrderDelivered      |                   |
|  CustomerDashboard   | OrderCreated,       | customer_orders   |
|                      | PaymentReceived,    | (per-customer)    |
|                      | OrderDelivered      |                   |
|  InventoryView       | StockReserved,      | inventory_levels  |
|                      | StockReleased,      | (per-product)     |
|                      | StockReceived       |                   |
|  RevenueReport       | PaymentReceived,    | revenue_daily     |
|                      | RefundProcessed     | (aggregated)      |
+--------------------------------------------------------------+

PROJECTION RULES:
1. Projections are disposable -- delete and rebuild from events
2. Each projection handles events idempotently (reprocessing is safe)
3. Track last processed event position per projection
4. Multiple projections can consume the same events
5. New projections can be added and backfilled from event history
```

### Step 4: Message Broker Design
Choose and configure the right message broker for the workload:

#### Kafka Configuration
```
KAFKA TOPOLOGY:

Cluster: <N> brokers, <replication factor>
Topics:
+--------------------------------------------------------------+
|  Topic                  | Partitions | Retention | Key        |
+--------------------------------------------------------------+
|  order.events           | 12         | 30 days   | order_id   |
|  payment.events         | 6          | 30 days   | payment_id |
|  inventory.events       | 6          | 7 days    | product_id |
|  notification.commands  | 3          | 1 day     | user_id    |
|  dead-letter            | 3          | 90 days   | original_  |
|                         |            |           | topic      |
+--------------------------------------------------------------+

PRODUCER CONFIG:
acks: all                          # Wait for all replicas
retries: 3                         # Retry transient failures
enable.idempotence: true           # Exactly-once semantics
max.in.flight.requests: 5          # With idempotence enabled
compression.type: lz4              # Compress for throughput
linger.ms: 5                       # Batch for 5ms
batch.size: 16384                  # 16KB batch size

CONSUMER CONFIG:
group.id: <service-name>           # Consumer group per service
auto.offset.reset: earliest        # Start from beginning on new group
enable.auto.commit: false          # Manual commit after processing
max.poll.records: 500              # Process 500 records per poll
session.timeout.ms: 30000          # 30s heartbeat timeout
max.poll.interval.ms: 300000       # 5m max processing time

PARTITIONING STRATEGY:
- Key-based: Same entity always goes to same partition (ordering)
- Round-robin: Even distribution when ordering is not needed
- Custom: Hash on composite key (tenant_id + entity_id)

PARTITION COUNT FORMULA:
  partitions = max(
    ceil(target_throughput / partition_throughput),
    number_of_consumers_in_largest_group
  )
```

#### RabbitMQ Configuration
```
RABBITMQ TOPOLOGY:

Exchanges:
+--------------------------------------------------------------+
|  Exchange             | Type    | Durable | Routing           |
+--------------------------------------------------------------+
|  order.events         | topic   | yes     | order.created     |
|                       |         |         | order.confirmed   |
|                       |         |         | order.shipped     |
|  payment.events       | topic   | yes     | payment.completed |
|                       |         |         | payment.failed    |
|  notifications.direct | direct  | yes     | email, sms, push  |
|  dead-letter.exchange | fanout  | yes     | (all DLQ traffic) |
+--------------------------------------------------------------+

Queues:
+--------------------------------------------------------------+
|  Queue                    | Durable | TTL    | DLX             |
+--------------------------------------------------------------+
|  payment.process-orders   | yes     | 30s    | dead-letter.exc |
|  inventory.reserve-stock  | yes     | 30s    | dead-letter.exc |
|  notification.send-email  | yes     | 60s    | dead-letter.exc |
|  dead-letter.queue        | yes     | 90d    | none            |
+--------------------------------------------------------------+

Bindings:
  order.events [order.created] -> payment.process-orders
  order.events [order.created] -> inventory.reserve-stock
  payment.events [payment.completed] -> notification.send-email

RABBITMQ BEST PRACTICES:
- Publisher confirms: Enable for guaranteed delivery
- Consumer prefetch: Set to 10-50 (not unlimited)
- Message TTL: Set per-queue, not per-message
- Lazy queues: For queues with large backlogs
- Quorum queues: For high-availability (replaces mirrored queues)
```

#### SQS/SNS Configuration
```
AWS EVENT ARCHITECTURE:

SNS Topics (Fan-out):
+--------------------------------------------------------------+
|  Topic                  | Subscriptions          | Filter     |
+--------------------------------------------------------------+
|  order-events           | payment-queue          | type=order |
|                         | inventory-queue        | type=order |
|                         | analytics-firehose     | (all)      |
|  payment-events         | notification-queue     | type=pay   |
|                         | order-update-queue     | type=pay   |
+--------------------------------------------------------------+

SQS Queues:
+--------------------------------------------------------------+
|  Queue                  | Visibility | Retention | DLQ        |
+--------------------------------------------------------------+
|  payment-processing     | 30s        | 14 days   | payment-dlq|
|  inventory-reservations | 30s        | 14 days   | inv-dlq    |
|  notification-sending   | 60s        | 4 days    | notif-dlq  |
|  payment-dlq            | 30s        | 14 days   | none       |
+--------------------------------------------------------------+

SQS CONFIGURATION:
  VisibilityTimeout: 6x average processing time
  ReceiveWaitTimeSeconds: 20 (long polling)
  MaxReceiveCount: 3 (before DLQ)
  MessageRetentionPeriod: 1209600 (14 days)
```

#### NATS Configuration
```
NATS TOPOLOGY:

Subjects:
  order.>              # Wildcard for all order events
  order.created        # Specific event
  order.confirmed
  payment.>            # All payment events

JetStream Streams:
+--------------------------------------------------------------+
|  Stream          | Subjects       | Retention   | Replicas    |
+--------------------------------------------------------------+
|  ORDERS          | order.>        | Limits      | 3           |
|                  |                | MaxAge: 30d |             |
|  PAYMENTS        | payment.>      | Limits      | 3           |
|                  |                | MaxAge: 30d |             |
+--------------------------------------------------------------+

Consumers:
+--------------------------------------------------------------+
|  Consumer            | Stream   | Deliver  | Ack Policy       |
+--------------------------------------------------------------+
|  payment-processor   | ORDERS   | Push     | Explicit         |
|  inventory-reserver  | ORDERS   | Pull     | Explicit         |
|  analytics-reader    | ORDERS   | Pull     | None             |
+--------------------------------------------------------------+

NATS ADVANTAGES:
- Sub-millisecond latency
- No external dependencies (embedded or standalone)
- JetStream for persistence and exactly-once
- Built-in request-reply pattern
- Lightweight (single binary, ~15MB)
```

#### Broker Comparison
```
MESSAGE BROKER SELECTION:
+--------------------------------------------------------------+
|  Feature          | Kafka      | RabbitMQ  | SQS/SNS  | NATS  |
+--------------------------------------------------------------+
|  Throughput       | Very High  | High      | High     | V.High|
|  Latency          | ~5ms       | ~1ms      | ~50ms    | ~0.1ms|
|  Ordering         | Per-part.  | Per-queue | FIFO opt | Per-sub|
|  Replay           | Yes        | No        | No       | Yes*  |
|  Persistence      | Yes        | Yes       | Yes      | Yes*  |
|  Exactly-once     | Yes        | No (ack)  | No (ack) | Yes*  |
|  Ops complexity   | High       | Medium    | None     | Low   |
|  Best for         | Streaming  | Routing   | AWS      | Speed |
|                   | High vol.  | Complex   | Managed  | Simple|
+--------------------------------------------------------------+
* With JetStream enabled
```

### Step 5: Event Schema Design & Versioning
Design event schemas that evolve without breaking consumers:

#### Event Envelope Standard
```
EVENT ENVELOPE:
{
  "event_id": "evt-550e8400-e29b-41d4-a716-446655440000",
  "event_type": "order.placed",
  "event_version": "1.2",
  "source": "order-service",
  "timestamp": "2025-01-15T10:30:45.123Z",
  "correlation_id": "req-660e8400-e29b-41d4-a716-446655440000",
  "causation_id": "evt-440e8400-e29b-41d4-a716-446655440000",
  "metadata": {
    "user_id": "usr-123",
    "tenant_id": "tenant-456",
    "trace_id": "abc123def456",
    "schema_registry_url": "https://schema.example.com/order.placed/v1.2"
  },
  "data": {
    // Event-specific payload
  }
}

ENVELOPE RULES:
- event_id: Globally unique, used for deduplication
- event_type: Dot-separated namespace (domain.event_name)
- event_version: Semantic version of the event schema
- source: Service that produced the event
- correlation_id: Links all events in a business flow
- causation_id: The event that caused this event
- metadata: Operational data (not business data)
- data: Business payload (the actual event content)
```

#### Schema Registry & Versioning
```
SCHEMA VERSIONING STRATEGY:

COMPATIBILITY MODES:
+--------------------------------------------------------------+
|  Mode                | Rule                    | Use When      |
+--------------------------------------------------------------+
|  Backward compatible | New schema reads old    | Adding fields |
|                      | data                    |               |
|  Forward compatible  | Old schema reads new    | Deprecating   |
|                      | data                    | fields        |
|  Full compatible     | Both directions         | Default       |
|  Breaking            | Neither direction       | Major version |
+--------------------------------------------------------------+

SAFE CHANGES (backward + forward compatible):
  + Add optional field with default value
  + Add new event type
  + Deprecate field (keep in schema, stop populating)

UNSAFE CHANGES (breaking -- requires new version):
  - Remove required field
  - Rename field
  - Change field type
  - Change field semantics

VERSIONING APPROACH:
  v1.0 -> v1.1: Add optional field (backward compatible)
  v1.1 -> v1.2: Deprecate field (forward compatible)
  v1.2 -> v2.0: Remove deprecated field (breaking change)

SCHEMA REGISTRY:
  Tool: Confluent Schema Registry | AWS Glue | Apicurio
  Format: Avro (recommended) | JSON Schema | Protobuf
  Validation: Producer validates schema before publishing
  Evolution: Registry rejects incompatible schema changes
```

#### Schema Examples
```
AVRO SCHEMA (order.placed v1):
{
  "type": "record",
  "name": "OrderPlaced",
  "namespace": "com.example.order.events",
  "fields": [
    {"name": "order_id", "type": "string"},
    {"name": "customer_id", "type": "string"},
    {"name": "total_amount", "type": "double"},
    {"name": "currency", "type": "string", "default": "USD"},
    {"name": "items", "type": {"type": "array", "items": {
      "type": "record",
      "name": "OrderItem",
      "fields": [
        {"name": "product_id", "type": "string"},
        {"name": "quantity", "type": "int"},
        {"name": "unit_price", "type": "double"}
      ]
    }}},
    {"name": "placed_at", "type": "string"}
  ]
}

EVOLUTION (v1 -> v1.1): Add optional discount field
{
  ...
  "fields": [
    ... existing fields ...,
    {"name": "discount_amount", "type": ["null", "double"], "default": null}
  ]
}
```

### Step 6: Dead Letter Queues & Retry Policies
Design failure handling for event processing:

```
RETRY AND DLQ STRATEGY:

RETRY POLICY:
+--------------------------------------------------------------+
|  Attempt | Delay      | Action                                |
+--------------------------------------------------------------+
|  1       | Immediate  | Process message                       |
|  2       | 1 second   | Retry (transient failure)             |
|  3       | 5 seconds  | Retry (backoff)                       |
|  4       | 30 seconds | Retry (extended backoff)              |
|  5       | 5 minutes  | Final retry                           |
|  Failed  | --         | Move to Dead Letter Queue             |
+--------------------------------------------------------------+

DEAD LETTER QUEUE DESIGN:
+--------------------------------------------------------------+
|  DLQ: <service>-dead-letter                                   |
|  Retention: 90 days                                           |
|  Alert: On new message arrival                                |
|  Monitoring: Queue depth dashboard                            |
+--------------------------------------------------------------+
|                                                               |
|  DLQ Message Format:                                          |
|  {                                                            |
|    "original_message": { ... },                               |
|    "original_topic": "order.events",                          |
|    "original_partition": 3,                                   |
|    "original_offset": 12345,                                  |
|    "failure_reason": "PaymentGatewayTimeout",                 |
|    "failure_count": 5,                                        |
|    "first_failure_at": "2025-01-15T10:30:45Z",               |
|    "last_failure_at": "2025-01-15T10:35:12Z",                |
|    "stack_trace": "...",                                      |
|    "consumer_group": "payment-processor",                     |
|    "consumer_instance": "payment-svc-7d4f8b-x9k2m"           |
|  }                                                            |
+--------------------------------------------------------------+

DLQ PROCESSING:
1. Alert on-call when DLQ depth > 0
2. Investigate root cause (not just reprocess blindly)
3. Fix the issue in the consumer
4. Replay DLQ messages back to the original topic
5. Monitor for re-failures

DLQ REPLAY TOOL:
  # Replay all DLQ messages back to original topic
  kafka-console-consumer --topic dead-letter --from-beginning |
    kafka-console-producer --topic order.events

  # Or use a dedicated replay service with filtering
  dlq-replay --source dead-letter \
             --target order.events \
             --filter "failure_reason=PaymentGatewayTimeout" \
             --rate-limit 100/s
```

### Step 7: Idempotency Patterns
Ensure safe message reprocessing when duplicates occur:

```
IDEMPOTENCY PATTERNS:
+--------------------------------------------------------------+
|  Pattern              | How it works          | Best for       |
+--------------------------------------------------------------+
|  Idempotency key      | Store processed keys  | Commands       |
|                       | in a set/table        |                |
|  Natural idempotency  | Operation is          | Upserts, sets  |
|                       | inherently safe       |                |
|  Optimistic locking   | Version check before  | Updates        |
|                       | write                 |                |
|  Deduplication table  | Event ID lookup       | Event consumers|
|                       | before processing     |                |
+--------------------------------------------------------------+

DEDUPLICATION TABLE:
CREATE TABLE processed_events (
  event_id        UUID PRIMARY KEY,
  event_type      VARCHAR(200) NOT NULL,
  consumer_group  VARCHAR(100) NOT NULL,
  processed_at    TIMESTAMP NOT NULL,
  result          JSONB
);

-- Index for cleanup (remove entries older than retention)
CREATE INDEX idx_processed_events_time ON processed_events(processed_at);

-- Cleanup: DELETE FROM processed_events WHERE processed_at < NOW() - INTERVAL '7 days';

CONSUMER PSEUDOCODE:
function handleEvent(event):
  // 1. Check if already processed
  if (await isProcessed(event.event_id, consumerGroup)):
    log.info("Duplicate event, skipping", { event_id: event.event_id })
    return ACK

  // 2. Process within a transaction
  try:
    await db.transaction(async (tx) => {
      // Process the business logic
      await processBusinessLogic(tx, event.data)

      // Mark as processed (same transaction)
      await markProcessed(tx, event.event_id, consumerGroup)
    })

    return ACK
  catch (error):
    if (isTransient(error)):
      return NACK  // Retry
    else:
      return DEAD_LETTER  // Unrecoverable
```

### Step 8: Validation
Validate the event-driven architecture against best practices:

```
EVENT ARCHITECTURE VALIDATION:
+--------------------------------------------------------------+
|  Check                                    | Status             |
+--------------------------------------------------------------+
|  Event envelope follows standard format   | PASS | FAIL        |
|  All events have correlation IDs          | PASS | FAIL        |
|  Schema versioning strategy defined       | PASS | FAIL        |
|  Schema registry configured               | PASS | FAIL        |
|  Dead letter queues on all consumers      | PASS | FAIL        |
|  Retry policy with exponential backoff    | PASS | FAIL        |
|  Idempotent consumers                     | PASS | FAIL        |
|  Event ordering guaranteed where needed   | PASS | FAIL        |
|  Consumer groups properly configured      | PASS | FAIL        |
|  Broker replication and durability set    | PASS | FAIL        |
|  Monitoring on consumer lag               | PASS | FAIL        |
|  DLQ alerting configured                  | PASS | FAIL        |
|  Events do not contain sensitive PII      | PASS | FAIL        |
|  Projections are rebuildable from events  | PASS | FAIL        |
+--------------------------------------------------------------+

VERDICT: <PASS | NEEDS REVISION>
```

### Step 9: Artifacts & Commit
Generate the deliverables:

```
EVENT ARCHITECTURE COMPLETE:

Artifacts:
- Event catalog: docs/events/<system>-event-catalog.md
- Schema definitions: schemas/<domain>/<event>.avsc (or .json, .proto)
- Broker topology: docs/events/<system>-broker-topology.md
- CQRS design: docs/events/<system>-cqrs.md
- DLQ/Retry config: infra/messaging/ or k8s/messaging/
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:micro -- Design the services that produce/consume events
-> /godmode:contract -- Define event contracts between producers and consumers
-> /godmode:observe -- Monitor consumer lag, DLQ depth, event throughput
-> /godmode:build -- Implement event handlers and projections
```

Commit: `"event: <system> -- <N> event types, <broker>, <pattern (ES/CQRS/pub-sub)>"`

## Key Behaviors

1. **Events are facts, not commands.** An event says "OrderPlaced" (past tense, something happened). A command says "PlaceOrder" (imperative, do something). Do not conflate them.
2. **Events are immutable.** Once published, an event cannot be changed. If the data was wrong, publish a corrective event (e.g., OrderAmountCorrected). Never mutate event history.
3. **Schema evolution is mandatory.** Events will change. Design for backward and forward compatibility from day one. Use a schema registry to enforce compatibility.
4. **Every consumer must be idempotent.** Messages will be delivered more than once. Processing the same event twice must produce the same result.
5. **Dead letter queues are not optional.** Every consumer needs a DLQ for messages that cannot be processed. Monitor DLQ depth and alert on non-zero.
6. **Correlation IDs trace the full flow.** Every event in a business flow shares the same correlation_id. Without it, debugging distributed event chains is impossible.
7. **Consumer lag is the most important metric.** If consumers fall behind, the system is degrading. Alert on growing lag before it becomes a crisis.
8. **Projections are disposable.** Read models can be deleted and rebuilt from the event store. Design projections with this in mind.

## Example Usage

### Designing an event-driven order system
```
User: /godmode:event Design event sourcing for our order management system

Event: Assessing architecture requirements...

EVENT ARCHITECTURE CONTEXT:
  Current: PostgreSQL CRUD, no events
  Throughput: ~500 orders/min peak
  Consumers: 4 services (payment, inventory, shipping, notifications)
  Ordering: Per-order (same order events in sequence)
  Retention: 2 years (audit requirement)

DESIGN:
  Pattern: Event Sourcing + CQRS
  Broker: Kafka (3 brokers, replication factor 3)
  Schema: Avro with Confluent Schema Registry

EVENT CATALOG:
  order.created (v1.0)
  order.payment_received (v1.0)
  order.confirmed (v1.0)
  order.item_shipped (v1.0)
  order.delivered (v1.0)
  order.cancelled (v1.0)
  order.refunded (v1.0)

PROJECTIONS:
  OrderSummary -> orders_summary (customer dashboard)
  OrderAnalytics -> orders_daily_stats (reporting)
  InventoryView -> inventory_levels (stock management)

DLQ: payment-dlq, inventory-dlq, shipping-dlq, notification-dlq
Retry: 5 attempts, exponential backoff (1s -> 5m)
Idempotency: Deduplication table per consumer

Validation: 14/14 checks PASS
```

### Setting up a Kafka topic structure
```
User: /godmode:event Set up Kafka topics for our microservices

Event: Designing Kafka topology...

TOPICS:
  order.events        12 partitions, 30d retention, key: order_id
  payment.events      6 partitions, 30d retention, key: payment_id
  inventory.events    6 partitions, 7d retention, key: product_id
  notification.cmd    3 partitions, 1d retention, key: user_id
  dead-letter         3 partitions, 90d retention, key: original_topic

CONSUMER GROUPS:
  payment-processor   -> order.events (order.created)
  inventory-reserver  -> order.events (order.created)
  notification-sender -> payment.events (payment.completed)

Config generated: infra/kafka/topics.yaml
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full event-driven architecture design |
| `--sourcing` | Design event sourcing with event store |
| `--cqrs` | Design CQRS with read/write model separation |
| `--broker kafka` | Design Kafka topic topology |
| `--broker rabbitmq` | Design RabbitMQ exchange/queue topology |
| `--broker sqs` | Design SQS/SNS topic and queue topology |
| `--broker nats` | Design NATS subject and stream topology |
| `--schema` | Design event schemas with versioning |
| `--dlq` | Design dead letter queues and retry policies |
| `--idempotency` | Design idempotency patterns for consumers |
| `--catalog` | Generate event catalog documentation |
| `--validate` | Validate existing event architecture |

## HARD RULES

1. **Never use events as remote procedure calls.** Events are notifications of something that happened (past tense: "OrderPlaced"), not requests for something to happen. If you need a response, use a command with a reply channel.
2. **Never mutate historical events.** Changing events after publication breaks every consumer that already processed them and destroys the audit trail. Publish corrective events instead.
3. **Never deploy consumers without idempotency.** At-least-once delivery means duplicates will happen. Every consumer must handle reprocessing safely using a deduplication table or natural idempotency.
4. **Never skip the dead letter queue.** Every consumer needs a DLQ for messages that cannot be processed after retries. Monitor DLQ depth and alert on non-zero.
5. **Never publish events without a schema registry check.** Without schema validation, a producer can publish malformed events that break every consumer downstream.

## Loop Protocol

```
event_design_queue = detect_event_domains()  // e.g., [orders, payments, inventory, notifications]
current_iteration = 0

WHILE event_design_queue is not empty:
  domain = event_design_queue.pop()
  current_iteration += 1

  1. Identify all events in the domain (aggregate commands → events)
  2. Design event schemas with envelope standard (event_id, correlation_id, etc.)
  3. Register schemas in schema registry with compatibility check
  4. Configure topic/exchange/queue (partitioning, retention, DLQ)
  5. Implement consumer with idempotency and retry policy
  6. Validate: schema registered, DLQ configured, idempotent, correlation IDs present

  Log: "Iteration {current_iteration}: designed {domain} domain, {N} event types, {event_design_queue.remaining} domains remaining"

  IF event_design_queue is empty:
    Run architecture validation checklist (14 checks)
    BREAK
```

## Multi-Agent Dispatch

```
PARALLEL AGENTS (3 worktrees):

Agent 1 — "event-store-and-schemas":
  EnterWorktree("event-store-and-schemas")
  Design event store schema (events table, snapshots table)
  Define event envelope standard with all required fields
  Create Avro/JSON Schema/Protobuf definitions for each event type
  Register schemas in schema registry with compatibility validation
  ExitWorktree()

Agent 2 — "broker-topology":
  EnterWorktree("broker-topology")
  Configure message broker (Kafka topics / RabbitMQ exchanges / SQS queues / NATS streams)
  Set partitioning strategy, retention, replication
  Configure DLQ for each consumer with retry policy (exponential backoff)
  Implement DLQ replay tooling
  ExitWorktree()

Agent 3 — "consumers-and-projections":
  EnterWorktree("consumers-and-projections")
  Implement idempotent consumers with deduplication table
  Build CQRS projections (read models from event stream)
  Add correlation ID propagation through all event handlers
  Configure consumer lag monitoring and alerting
  ExitWorktree()

MERGE: Combine all branches, run architecture validation checklist.
```

## Auto-Detection

```
AUTO-DETECT event-driven architecture context:
  1. Check for message broker: kafka (server.properties, docker-compose kafka),
     rabbitmq (rabbitmq.conf), SQS/SNS (AWS CDK/SAM), NATS (nats-server.conf)
  2. Scan for event schemas: schemas/, events/, *.avsc, *.proto files
  3. Check for schema registry: schema-registry config, Confluent, AWS Glue
  4. Detect event sourcing: event_store table, EventStore library, axon framework
  5. Detect CQRS: separate read/write models, projection services
  6. Check for DLQ config: dead-letter-queue, DLX (RabbitMQ), maxReceiveCount (SQS)
  7. Grep for consumer groups: group.id (Kafka), queue bindings (RabbitMQ)
  8. Check for idempotency: processed_events table, deduplication logic

  USE detected context to:
    - Target the correct broker (don't suggest Kafka if already on RabbitMQ)
    - Extend existing event schemas rather than redesigning
    - Identify gaps: missing DLQ, missing idempotency, no schema registry
    - Match existing event naming conventions
```

## Anti-Patterns

- **Do NOT use events as remote procedure calls.** Events are notifications of something that happened, not requests for something to happen. If you need a response, use a command with a reply channel.
- **Do NOT mutate events.** Changing historical events breaks every consumer that already processed them and destroys the audit trail. Publish corrective events instead.
- **Do NOT skip the schema registry.** Without schema validation, a producer can publish malformed events that break every consumer. Validate before publish.
- **Do NOT ignore consumer lag.** A consumer falling behind is the first sign of a production incident. Monitor lag and alert before it becomes critical.
- **Do NOT process DLQ messages blindly.** Replaying DLQ messages without fixing the root cause will just send them back to the DLQ. Investigate first, fix, then replay.
- **Do NOT put sensitive data in events without encryption.** Events are stored and replicated. PII in events requires encryption at rest and in transit, plus GDPR deletion strategy.
- **Do NOT design without idempotency.** At-least-once delivery means duplicates will happen. Every consumer must handle them gracefully.
- **Do NOT use a single topic for all events.** One mega-topic makes filtering, scaling, and retention management impossible. Use domain-specific topics.


## Output Format

```
EVENT ARCHITECTURE COMPLETE:
  Pattern: <Event Sourcing | CQRS | Pub/Sub | Hybrid>
  Broker: <Kafka | RabbitMQ | SQS/SNS | NATS | other>
  Event types: <N> events across <M> domains
  Schema registry: <Confluent | AWS Glue | custom | none>
  Schema format: <Avro | Protobuf | JSON Schema>
  Topics/Exchanges: <N> configured
  DLQ: <configured per consumer | not configured>
  Idempotency: <deduplication table | idempotency key | not implemented>
  Projections: <N> read models (CQRS)

DOMAIN EVENT SUMMARY:
+--------------------------------------------------------------+
|  Domain        | Events | Topics | Consumers | DLQ | Schema   |
+--------------------------------------------------------------+
|  <domain>      | N      | N      | N         | yes | avro     |
+--------------------------------------------------------------+
```

## TSV Logging

Log every event architecture session to `.godmode/event-results.tsv`:

```
Fields: timestamp\tproject\tbroker\tevent_types\tdomains\tschema_format\tdlq_configured\tidempotency\tprojections_count\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-app\tkafka\t18\t4\tavro\tyes\tyes\t6\tabc1234
```

Append after every completed event design pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
EVENT ARCHITECTURE SUCCESS CRITERIA:
+--------------------------------------------------------------+
|  Criterion                                  | Required         |
+--------------------------------------------------------------+
|  All events have schema definitions         | YES              |
|  Schema registry with compatibility checks  | YES              |
|  Event envelope has required fields          | YES              |
|  (event_id, correlation_id, timestamp, type, version)         |
|  DLQ configured for every consumer          | YES              |
|  Idempotent consumers (deduplication)       | YES              |
|  Correlation ID propagated across services  | YES              |
|  Consumer lag monitoring configured         | YES              |
|  No sensitive data in events without encrypt| YES              |
|  Domain-specific topics (no mega-topic)     | YES              |
+--------------------------------------------------------------+

VERDICT: ALL required criteria must PASS. Any FAIL → fix before commit.
```

## Error Recovery

```
ERROR RECOVERY — EVENT:
1. Schema compatibility check fails:
   → Do not modify existing fields. Add new fields with defaults. Use schema evolution rules (BACKWARD compatible). Register as new version, not replacement.
2. Consumer lag growing (falling behind):
   → Check consumer processing time. Scale consumer instances (add partitions if Kafka). Check for blocking I/O in handler. Add consumer lag alerting.
3. DLQ growing (events failing after retries):
   → Inspect DLQ messages for common error pattern. Fix root cause (schema mismatch, missing handler, dependency down). Replay DLQ after fix with idempotency check.
4. Duplicate events processed:
   → Verify idempotency check runs BEFORE processing. Check deduplication table TTL (must exceed max retry window). Add event_id to deduplication key.
5. Missing correlation IDs in downstream events:
   → Trace event flow. Ensure correlation_id from incoming event is copied to all outgoing events in the handler. Add middleware/interceptor to propagate automatically.
6. Event store growing unboundedly:
   → Implement snapshot strategy (snapshot every N events). Archive old events to cold storage. Set retention policy on topics/tables.
```

## Event-Driven Architecture Audit

Structured audit loop for event schema validation, ordering guarantee verification, and event flow health:

```
EVENT ARCHITECTURE AUDIT LOOP:

current_iteration = 0
max_iterations = 15
audit_queue = [
    "event_schema_validation",
    "ordering_guarantee_verification",
    "idempotency_coverage",
    "dlq_health",
    "consumer_lag_analysis",
    "correlation_id_propagation",
    "schema_compatibility_check",
    "event_flow_traceability"
]
findings = []

WHILE audit_queue is not empty AND current_iteration < max_iterations:
    current_iteration += 1
    audit_aspect = audit_queue.pop(0)

    1. SCAN all event producers and consumers for {audit_aspect}
    2. VALIDATE against event-driven best practices
    3. CLASSIFY: PASS | WARN | FAIL
    4. IF FAIL: generate fix with specific code/config changes
    5. IF new concerns surface: audit_queue.append(concern)
    6. REPORT "Audit iteration {current_iteration}: {audit_aspect} — {status}"

FINAL: Event architecture health report with prioritized fixes
```

### Event Schema Validation

```
EVENT SCHEMA VALIDATION:
┌──────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Details     │
├─────────────────────────────────────┼──────────┼─────────────┤
│  All events have schema definitions │ PASS|FAIL│ <N>/<total> │
│  (Avro, Protobuf, JSON Schema)      │          │ have schemas│
├─────────────────────────────────────┼──────────┼─────────────┤
│  Schema registry configured and     │ PASS|FAIL│ <registry>  │
│  enforcing compatibility            │          │             │
├─────────────────────────────────────┼──────────┼─────────────┤
│  Event envelope has ALL required     │ PASS|FAIL│ Missing:    │
│  fields: event_id, event_type,      │          │ <list>      │
│  version, timestamp, source,         │          │             │
│  correlation_id, data               │          │             │
├─────────────────────────────────────┼──────────┼─────────────┤
│  Event naming follows convention     │ PASS|FAIL│ Convention: │
│  (domain.entity.action, past tense) │          │ <violations>│
├─────────────────────────────────────┼──────────┼─────────────┤
│  Schema evolution is backward        │ PASS|FAIL│ <breaking   │
│  compatible (no breaking changes     │          │ changes     │
│  without version bump)              │          │ detected>   │
├─────────────────────────────────────┼──────────┼─────────────┤
│  No sensitive PII in event payloads │ PASS|FAIL│ <fields     │
│  without encryption                  │          │ flagged>    │
├─────────────────────────────────────┼──────────┼─────────────┤
│  Causation chain traceable           │ PASS|FAIL│ <events     │
│  (causation_id links to parent      │          │ missing     │
│  event that triggered this event)   │          │ causation>  │
├─────────────────────────────────────┼──────────┼─────────────┤
│  Event payload size within limits    │ PASS|WARN│ <events     │
│  (< 1MB recommended, < 256KB ideal)│          │ exceeding>  │
└─────────────────────────────────────┴──────────┴─────────────┘

SCHEMA VALIDATION COMMANDS:
  # JSON Schema validation
  npx ajv validate -s schemas/order-placed.json -d sample-events/order-placed.json

  # Avro compatibility check (Confluent Schema Registry)
  curl -X POST "http://schema-registry:8081/compatibility/subjects/<topic>-value/versions/latest" \
    -H "Content-Type: application/vnd.schemaregistry.v1+json" \
    -d '{"schema": "<new-schema-json>"}'

  # Protobuf breaking change detection
  buf breaking --against .git#branch=main proto/

  # Scan for PII in event schemas
  grep -rn "email\|phone\|ssn\|address\|credit_card\|password" schemas/

SCHEMA HEALTH REPORT:
┌──────────────────────────────────────────────────────────────┐
│  Event Type           │ Schema │ Version │ Compat.  │ Status  │
├───────────────────────┼────────┼─────────┼──────────┼─────────┤
│  order.placed         │ Avro   │ 1.2     │ BACKWARD │ VALID   │
│  order.cancelled      │ Avro   │ 1.0     │ BACKWARD │ VALID   │
│  payment.completed    │ JSON   │ 2.0     │ BREAKING │ WARN    │
│  user.registered      │ (none) │ —       │ —        │ FAIL    │
│  inventory.reserved   │ Proto  │ 1.0     │ FULL     │ VALID   │
├───────────────────────┴────────┴─────────┴──────────┴─────────┤
│  Total events: <N> │ With schema: <N> │ Without: <N>          │
│  Compatible: <N> │ Breaking changes detected: <N>             │
│  PII exposure risk: <N> events                                │
└──────────────────────────────────────────────────────────────┘
```

### Ordering Guarantee Verification

```
ORDERING GUARANTEE AUDIT:
┌──────────────────────────────────────────────────────────────┐
│  Requirement                        │ Mechanism   │ Status   │
├─────────────────────────────────────┼─────────────┼──────────┤
│  Per-entity ordering                │             │          │
│  (all events for same entity are    │ Partition   │ PASS|FAIL│
│  processed in order)                │ key = entity│          │
│                                     │ _id         │          │
├─────────────────────────────────────┼─────────────┼──────────┤
│  Causal ordering                    │             │          │
│  (if event A causes event B,        │ Same        │ PASS|FAIL│
│  consumers always see A before B)   │ partition + │          │
│                                     │ causation_id│          │
├─────────────────────────────────────┼─────────────┼──────────┤
│  Global ordering                    │             │          │
│  (all events across all entities    │ Single      │ PASS|FAIL│
│  are processed in total order)      │ partition   │          │
│                                     │ (limits     │          │
│                                     │ throughput) │          │
├─────────────────────────────────────┼─────────────┼──────────┤
│  No ordering required               │             │          │
│  (events can be processed in any    │ Any         │ PASS     │
│  order, consumer handles reordering)│ partitioning│          │
└─────────────────────────────────────┴─────────────┴──────────┘

ORDERING VERIFICATION TESTS:
  Test 1: Per-entity ordering
    - Publish events E1, E2, E3 for entity X to same topic
    - Verify consumer receives E1, E2, E3 in exact order
    - Verify: partition key is set to entity ID
    - Edge case: what happens if partition count changes? (key rehashing)

  Test 2: Cross-partition ordering (should NOT be assumed)
    - Publish events to different partitions
    - Verify: consumer does NOT depend on cross-partition order
    - IF cross-partition order is needed: document the limitation

  Test 3: Consumer restart ordering
    - Consumer processes events E1, E2, commits offset
    - Consumer crashes, restarts
    - Verify: consumer resumes from E3 (not reprocessing E1, E2)
    - Verify: idempotency handles the edge case of E2 reprocessing

  Test 4: Concurrent consumer ordering
    - Multiple consumer instances in same group
    - Verify: events for same entity always go to same consumer instance
    - Verify: partition assignment strategy does not split entity events

ORDERING RISK MATRIX:
┌──────────────────────────────────────────────────────────────┐
│  Event Flow               │ Required Order │ Guaranteed? │ Risk│
├───────────────────────────┼────────────────┼─────────────┼─────┤
│  <producer> → <consumer>  │ Per-entity     │ YES|NO      │ L|M|H│
│  <producer> → <consumer>  │ Causal         │ YES|NO      │ L|M|H│
│  <producer> → <consumer>  │ None           │ N/A         │ LOW  │
└───────────────────────────┴────────────────┴─────────────┴─────┘

FOR EACH HIGH-RISK ORDERING GAP:
  Flow: <producer → topic → consumer>
  Required: <per-entity | causal | global>
  Current: <not guaranteed | partially guaranteed>
  Fix:
    - Set partition key to <entity_id> for per-entity ordering
    - Use single partition for global ordering (note throughput limit)
    - Add sequence numbers to events for consumer-side reordering
    - Add causation_id and consumer-side causal ordering buffer
  Effort: <S|M|L>
```

### Event Architecture Health Scorecard

```
EVENT ARCHITECTURE HEALTH SCORECARD:
┌──────────────────────────────────────────────────────────────┐
│  Dimension                    │ Score (1-10) │ Weight│ Total  │
├───────────────────────────────┼──────────────┼───────┼────────┤
│  Schema coverage & quality    │ <score>      │ 0.20  │ <N>    │
│  (all events have validated   │              │       │        │
│  schemas with compatibility)  │              │       │        │
│  Ordering guarantees          │ <score>      │ 0.15  │ <N>    │
│  (correct partition keys,     │              │       │        │
│  ordering verified per flow)  │              │       │        │
│  Idempotency coverage         │ <score>      │ 0.15  │ <N>    │
│  (all consumers handle        │              │       │        │
│  duplicate delivery safely)   │              │       │        │
│  DLQ and retry configuration  │ <score>      │ 0.15  │ <N>    │
│  (every consumer has DLQ,     │              │       │        │
│  exponential backoff retries) │              │       │        │
│  Consumer lag health          │ <score>      │ 0.10  │ <N>    │
│  (all consumers keeping up,   │              │       │        │
│  lag monitoring and alerting) │              │       │        │
│  Correlation/traceability     │ <score>      │ 0.10  │ <N>    │
│  (correlation_id + causation  │              │       │        │
│  _id propagated across all    │              │       │        │
│  event handlers)              │              │       │        │
│  Schema evolution safety      │ <score>      │ 0.10  │ <N>    │
│  (backward compatible changes │              │       │        │
│  only, registry enforcing)    │              │       │        │
│  Operational maturity         │ <score>      │ 0.05  │ <N>    │
│  (DLQ replay tooling,         │              │       │        │
│  consumer lag dashboards)     │              │       │        │
├───────────────────────────────┼──────────────┼───────┼────────┤
│  OVERALL HEALTH               │              │       │ <total>│
│  Rating: EXCELLENT (8+) | GOOD (6-8) | NEEDS WORK (4-6) |   │
│           CRITICAL (<4)                                       │
└──────────────────────────────────────────────────────────────┘
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run event tasks sequentially: event store/schemas, then broker topology, then consumers/projections.
- Use branch isolation per task: `git checkout -b godmode-event-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
