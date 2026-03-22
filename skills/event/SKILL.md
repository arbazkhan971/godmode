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

If the user has not specified context, ask: "What is driving the move to events? Do you need event sourcing (full history rebuild) or async messaging (fire-and-forget notifications)?"

### Step 2: Event Sourcing Design
Store state as a sequence of immutable events rather than current-state snapshots:

#### Event Store Design
```
EVENT STORE SCHEMA:

+---------------------------------------------------------+
| Table: events |
+---------------------------------------------------------+
| event_id UUID PRIMARY KEY |
| aggregate_type VARCHAR(100) NOT NULL |
| aggregate_id UUID NOT NULL |
| event_type VARCHAR(200) NOT NULL |
| event_version INTEGER NOT NULL |
| data JSONB NOT NULL |
| metadata JSONB NOT NULL |
| created_at TIMESTAMP NOT NULL |
+---------------------------------------------------------+
| UNIQUE (aggregate_id, event_version) |
```

#### Event Sourcing Example
```
AGGREGATE: Order

Events in order:
 1. OrderCreated { order_id, customer_id, items, total }
 2. PaymentReceived { payment_id, amount, method }
 3. OrderConfirmed { confirmed_at }
 4. ItemShipped { shipment_id, tracking_number }
 5. OrderDelivered { delivered_at, signature }

State reconstruction:
 OrderCreated -> status: PENDING, items: [...], total: 99.99
 PaymentReceived -> status: PAID, payment: { id, amount }
 OrderConfirmed -> status: CONFIRMED, confirmed_at:...
 ItemShipped -> status: SHIPPED, tracking: ABC123
 OrderDelivered -> status: DELIVERED, delivered_at:...

Current state = fold(events, initialState)
```

### Step 3: CQRS Implementation
Separate the read model (query) from the write model (command):

```
CQRS ARCHITECTURE:

WRITE SIDE (Commands):
+-------------------+ +-------------------+ +-------------------+
| API / Client | --> | Command Handler | --> | Event Store |
| | | (validates, | | (append-only) |
| CreateOrder | | applies rules) | | |
| CancelOrder | +-------------------+ +-------------------+
| UpdateAddress | |
+-------------------+ | publish
 v
 +-------------------+
 | Event Bus |
 | (Kafka/RabbitMQ) |
 +-------------------+
```

#### Projection Design
```
PROJECTIONS:
+--------------------------------------------------------------+
| Projection | Source Events | Read Model |
+--------------------------------------------------------------+
| OrderSummary | OrderCreated, | orders_summary |
| | OrderConfirmed, | (denormalized) |
| | OrderDelivered | |
| CustomerDashboard | OrderCreated, | customer_orders |
| | PaymentReceived, | (per-customer) |
| | OrderDelivered | |
| InventoryView | StockReserved, | inventory_levels |
| | StockReleased, | (per-product) |
| | StockReceived | |
| RevenueReport | PaymentReceived, | revenue_daily |
| | RefundProcessed | (aggregated) |
```

### Step 4: Message Broker Design
Choose and configure the right message broker for the workload:

#### Kafka Configuration
```
KAFKA TOPOLOGY:

Cluster: <N> brokers, <replication factor>
Topics:
+--------------------------------------------------------------+
| Topic | Partitions | Retention | Key |
+--------------------------------------------------------------+
| order.events | 12 | 30 days | order_id |
| payment.events | 6 | 30 days | payment_id |
| inventory.events | 6 | 7 days | product_id |
| notification.commands | 3 | 1 day | user_id |
| dead-letter | 3 | 90 days | original_ |
| | | | topic |
+--------------------------------------------------------------+

```

#### RabbitMQ Configuration
```
RABBITMQ TOPOLOGY:

Exchanges:
+--------------------------------------------------------------+
| Exchange | Type | Durable | Routing |
+--------------------------------------------------------------+
| order.events | topic | yes | order.created |
| | | | order.confirmed |
| | | | order.shipped |
| payment.events | topic | yes | payment.completed |
| | | | payment.failed |
| notifications.direct | direct | yes | email, sms, push |
| dead-letter.exchange | fanout | yes | (all DLQ traffic) |
+--------------------------------------------------------------+

```

#### SQS/SNS Configuration
```
AWS EVENT ARCHITECTURE:

SNS Topics (Fan-out):
+--------------------------------------------------------------+
| Topic | Subscriptions | Filter |
+--------------------------------------------------------------+
| order-events | payment-queue | type=order |
| | inventory-queue | type=order |
| | analytics-firehose | (all) |
| payment-events | notification-queue | type=pay |
| | order-update-queue | type=pay |
+--------------------------------------------------------------+

SQS Queues:
+--------------------------------------------------------------+
```

#### Broker Comparison
```
MESSAGE BROKER SELECTION:
+--------------------------------------------------------------+
| Feature | Kafka | RabbitMQ | SQS/SNS | NATS |
+--------------------------------------------------------------+
| Throughput | Very High | High | High | V.High|
| Latency | ~5ms | ~1ms | ~50ms | ~0.1ms|
| Ordering | Per-part. | Per-queue | FIFO opt | Per-sub|
| Replay | Yes | No | No | Yes* |
| Persistence | Yes | Yes | Yes | Yes* |
| Exactly-once | Yes | No (ack) | No (ack) | Yes* |
| Ops complexity | High | Medium | None | Low |
| Best for | Streaming | Routing | AWS | Speed |
| | High vol. | Complex | Managed | Simple|
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
```

#### Schema Registry & Versioning
```
SCHEMA VERSIONING STRATEGY:

COMPATIBILITY MODES:
+--------------------------------------------------------------+
| Mode | Rule | Use When |
+--------------------------------------------------------------+
| Backward compatible | New schema reads old | Adding fields |
| | data | |
| Forward compatible | Old schema reads new | Deprecating |
| | data | fields |
| Full compatible | Both directions | Default |
| Breaking | Neither direction | Major version |
+--------------------------------------------------------------+

SAFE CHANGES (backward + forward compatible):
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
```

### Step 6: Dead Letter Queues & Retry Policies
Design failure handling for event processing:

```
RETRY AND DLQ STRATEGY:

RETRY POLICY:
+--------------------------------------------------------------+
| Attempt | Delay | Action |
+--------------------------------------------------------------+
| 1 | Immediate | Process message |
| 2 | 1 second | Retry (transient failure) |
| 3 | 5 seconds | Retry (backoff) |
| 4 | 30 seconds | Retry (extended backoff) |
| 5 | 5 minutes | Final retry |
| Failed | -- | Move to Dead Letter Queue |
+--------------------------------------------------------------+

DEAD LETTER QUEUE DESIGN:
```

### Step 7: Idempotency Patterns
Ensure safe message reprocessing when duplicates occur:

```
IDEMPOTENCY PATTERNS:
+--------------------------------------------------------------+
| Pattern | How it works | Best for |
+--------------------------------------------------------------+
| Idempotency key | Store processed keys | Commands |
| | in a set/table | |
| Natural idempotency | Operation is | Upserts, sets |
| | inherently safe | |
| Optimistic locking | Version check before | Updates |
| | write | |
| Deduplication table | Event ID lookup | Event consumers|
| | before processing | |
+--------------------------------------------------------------+

DEDUPLICATION TABLE:
```

### Step 8: Validation
Validate the event-driven architecture against best practices:

```
EVENT ARCHITECTURE VALIDATION:
+--------------------------------------------------------------+
| Check | Status |
+--------------------------------------------------------------+
| Event envelope follows standard format | PASS | FAIL |
| All events have correlation IDs | PASS | FAIL |
| Schema versioning strategy defined | PASS | FAIL |
| Schema registry configured | PASS | FAIL |
| Dead letter queues on all consumers | PASS | FAIL |
| Retry policy with exponential backoff | PASS | FAIL |
| Idempotent consumers | PASS | FAIL |
| Event ordering guaranteed where needed | PASS | FAIL |
| Consumer groups properly configured | PASS | FAIL |
| Broker replication and durability set | PASS | FAIL |
| Monitoring on consumer lag | PASS | FAIL |
```

### Step 9: Artifacts & Commit
Generate the deliverables:

```
EVENT ARCHITECTURE COMPLETE:

Artifacts:
- Event catalog: docs/events/<system>-event-catalog.md
- Schema definitions: schemas/<domain>/<event>.avsc (or.json,.proto)
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

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full event-driven architecture design |
| `--sourcing` | Design event sourcing with event store |
| `--cqrs` | Design CQRS with read/write model separation |

## Keep/Discard Discipline
Each event domain design either passes validation or gets revised.
- **KEEP**: Schema registered, DLQ configured, idempotent consumer verified, correlation IDs present.
- **DISCARD**: Schema breaks backward compatibility, consumer is not idempotent, or DLQ missing. Fix before proceeding.
- **CRASH**: Broker misconfiguration or schema registry rejection. Fix config, re-register schema.
- Log every domain result to `.godmode/event-results.tsv`.

## Stop Conditions
- All events have schema definitions with compatibility checks.
- DLQ configured for every consumer with exponential backoff retry policy.
- Every consumer handles duplicate delivery (idempotent processing verified).
- Correlation IDs propagated across all event handlers.
- Consumer lag monitoring and alerting configured.

## HARD RULES

1. **Never use events as remote procedure calls.** Events are notifications of something that happened (past tense: "OrderPlaced"), not requests for something to happen. If you need a response, use a command with a reply channel.
2. **Never mutate historical events.** Changing events after publication breaks every consumer that already processed them and destroys the audit trail. Publish corrective events instead.
3. **Never deploy consumers without idempotency.** At-least-once delivery means duplicates will happen. Every consumer must handle reprocessing safely using a deduplication table or natural idempotency.
4. **Never skip the dead letter queue.** Every consumer needs a DLQ for messages that cannot be processed after retries. Monitor DLQ depth and alert on non-zero.
5. **Never publish events without a schema registry check.** Without schema validation, a producer can publish malformed events that break every consumer downstream.

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
| Domain | Events | Topics | Consumers | DLQ | Schema |
+--------------------------------------------------------------+
| <domain> | N | N | N | yes | avro |
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
| Criterion | Required |
+--------------------------------------------------------------+
| All events have schema definitions | YES |
| Schema registry with compatibility checks | YES |
| Event envelope has required fields | YES |
| (event_id, correlation_id, timestamp, type, version) |
| DLQ configured for every consumer | YES |
| Idempotent consumers (deduplication) | YES |
| Correlation ID propagated across services | YES |
| Consumer lag monitoring configured | YES |
| No sensitive data in events without encrypt| YES |
| Domain-specific topics (no mega-topic) | YES |
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
