---
name: event
description: |
  Event-driven architecture skill. Covers event sourcing,
  CQRS, message brokers (Kafka, RabbitMQ, SQS, NATS),
  schema versioning, DLQ, retry policies, idempotency.
  Triggers on: /godmode:event, "event sourcing", "CQRS",
  "Kafka", "dead letter queue", "idempotency".
---

# Event -- Event-Driven Architecture

## When to Activate
- User invokes `/godmode:event`
- User says "event sourcing", "CQRS", "message broker"
- User says "Kafka", "RabbitMQ", "dead letter queue"
- When building loosely coupled async systems

## Workflow

### Step 1: Event Architecture Assessment

```bash
# Detect message broker infrastructure
ls kafka/ docker-compose*.yml 2>/dev/null \
  | head -5
grep -rl "kafkajs\|amqplib\|@aws-sdk/client-sqs" \
  package.json pyproject.toml 2>/dev/null

# Check for event schemas
find . -name "*.avsc" -o -name "*.proto" \
  -o -path "*/events/*" | head -10
```

```
EVENT ARCHITECTURE CONTEXT:
Current State: No events | Basic pub/sub | Full CQRS/ES
Throughput: <events per second>
Ordering: None | Per-entity | Global
Retention: <how long to store events>

IF throughput > 10K/s: recommend Kafka
IF ordering per-entity only: Kafka partitions by key
IF need replay: Kafka or NATS JetStream (not RabbitMQ)
IF simple fan-out: SNS/SQS or RabbitMQ
```

### Step 2: Broker Selection

```
MESSAGE BROKER SELECTION:
| Feature    | Kafka  | RabbitMQ | SQS/SNS | NATS  |
|-----------|--------|----------|---------|-------|
| Throughput| V.High | High     | High    | V.High|
| Latency   | ~5ms   | ~1ms     | ~50ms   | ~0.1ms|
| Ordering  | Per-pt | Per-q    | FIFO opt| Per-sb|
| Replay    | Yes    | No       | No      | Yes*  |

THRESHOLDS:
  Kafka: use when > 10K events/sec or need replay
  RabbitMQ: use when < 10K/sec and need routing
  SQS/SNS: use when AWS-native and < 50K/sec
  NATS: use when need sub-ms latency
```

### Step 3: Event Schema Design

```
EVENT ENVELOPE (required fields):
  event_id: UUID
  event_type: "order.placed" (past tense)
  event_version: "1.2"
  source: "order-service"
  timestamp: ISO 8601
  correlation_id: UUID (propagated across services)
  data: { ... payload ... }

VERSIONING:
  Backward compatible: new schema reads old data
  Forward compatible: old schema reads new data
  RULE: never modify existing fields, only add
  RULE: new fields must have defaults
  RULE: reserve removed field numbers (protobuf)
```

### Step 4: DLQ & Retry Policies

```
RETRY POLICY:
| Attempt | Delay      | Action                  |
|---------|-----------|-------------------------|
| 1       | Immediate | Process message         |
| 2       | 1 second  | Retry (transient)       |
| 3       | 5 seconds | Retry (backoff)         |
| 4       | 30 seconds| Retry (extended backoff)|
| 5       | → DLQ     | Move to dead letter     |

DLQ RULES:
  IF DLQ depth > 0: alert team within 5 minutes
  IF DLQ depth > 100: page on-call
  IF message age in DLQ > 24h: escalate to P1
  Every consumer MUST have a DLQ configured
```

### Step 5: Idempotency Patterns

```
| Pattern           | How It Works         |
|-------------------|---------------------|
| Idempotency key   | Store processed IDs |
| Natural idempotent| Upserts, SET ops    |
| Optimistic locking| Version check       |
| Dedup table       | event_id in DB      |

RULE: Every consumer must be idempotent.
At-least-once delivery means duplicates WILL occur.
```

### Step 6: Event Sourcing (if needed)

Store state as immutable event sequence.
Rebuild aggregate state by replaying events.
Use snapshots every 100 events for performance.

### Step 7: CQRS (if needed)

Separate write model (commands → event store)
from read model (projections → query-optimized DB).
Projection lag target: < 500ms for user-facing reads.

### Step 8: Validation

```
EVENT ARCHITECTURE VALIDATION:
| Check                              | Status |
|------------------------------------|--------|
| Event envelope follows standard    | ?      |
| All events have correlation IDs    | ?      |
| Schema versioning strategy defined | ?      |
| DLQ on all consumers               | ?      |
| Idempotent consumer verified       | ?      |
| Retry with exponential backoff     | ?      |
```

Commit: `"event: <system> -- <N> event types,
  <broker>, <pattern>"`

## Key Behaviors

1. **Events are facts, not commands.** Past tense:
   "OrderPlaced", not "PlaceOrder".
2. **Events are immutable.** Publish corrective events.
3. **Schema evolution is mandatory.** Backward and
   forward compatibility from day one.
4. **Every consumer is idempotent.**

## HARD RULES

1. Never use events as remote procedure calls.
2. Never mutate historical events.
3. Never deploy consumers without idempotency.
4. Never skip the dead letter queue.
5. Never publish without schema registry check.

## Auto-Detection
```
1. Broker: kafka, rabbitmq, SQS/SNS, NATS configs
2. Schemas: *.avsc, *.proto, events/ directory
3. DLQ: dead-letter config, maxReceiveCount
4. Event sourcing: event_store table, Axon framework
```

## Loop Protocol
```
FOR each event domain:
  1. Design schema with envelope standard
  2. Register in schema registry
  3. Implement producer + consumer
  4. Configure DLQ + retry policy
  5. Verify idempotency with duplicate test
  6. IF schema breaks compat: add field, don't modify
  7. IF DLQ growing: check handler, fix root cause
```

## Output Format
Print: `Event: {pattern}, {broker}, {N} event types,
  DLQ: {configured}. Verdict: {verdict}.`

## TSV Logging
```
timestamp	broker	event_types	dlq_configured	idempotency	status
```

## Keep/Discard Discipline
```
KEEP if: schema registered AND DLQ configured
  AND idempotent consumer verified
DISCARD if: schema breaks compat OR no DLQ
  OR consumer not idempotent
```

## Stop Conditions
```
STOP when ANY of:
  - All events have schemas with compat checks
  - DLQ on every consumer with backoff retry
  - Idempotency verified for all consumers
  - User requests stop
```

## Error Recovery
- Schema compat fails: add fields with defaults only.
- Consumer lag growing: scale instances, add partitions.
- DLQ growing: check handler, fix deserialization.
- Ordering broken: verify partition key strategy.
