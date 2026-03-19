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

## Anti-Patterns

- **Do NOT use events as remote procedure calls.** Events are notifications of something that happened, not requests for something to happen. If you need a response, use a command with a reply channel.
- **Do NOT mutate events.** Changing historical events breaks every consumer that already processed them and destroys the audit trail. Publish corrective events instead.
- **Do NOT skip the schema registry.** Without schema validation, a producer can publish malformed events that break every consumer. Validate before publish.
- **Do NOT ignore consumer lag.** A consumer falling behind is the first sign of a production incident. Monitor lag and alert before it becomes critical.
- **Do NOT process DLQ messages blindly.** Replaying DLQ messages without fixing the root cause will just send them back to the DLQ. Investigate first, fix, then replay.
- **Do NOT put sensitive data in events without encryption.** Events are stored and replicated. PII in events requires encryption at rest and in transit, plus GDPR deletion strategy.
- **Do NOT design without idempotency.** At-least-once delivery means duplicates will happen. Every consumer must handle them gracefully.
- **Do NOT use a single topic for all events.** One mega-topic makes filtering, scaling, and retention management impossible. Use domain-specific topics.
