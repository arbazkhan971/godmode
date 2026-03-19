# /godmode:event

Design event-driven architectures. Implements event sourcing, CQRS, message broker topologies (Kafka, RabbitMQ, SQS, NATS), event schema design with versioning, dead letter queues, retry policies, and idempotency patterns.

## Usage

```
/godmode:event                          # Full event-driven architecture design
/godmode:event --sourcing               # Design event sourcing with event store
/godmode:event --cqrs                   # Design CQRS with read/write separation
/godmode:event --broker kafka           # Design Kafka topic topology
/godmode:event --broker rabbitmq        # Design RabbitMQ exchange/queue topology
/godmode:event --broker sqs             # Design SQS/SNS topic and queue topology
/godmode:event --broker nats            # Design NATS subject and stream topology
/godmode:event --schema                 # Design event schemas with versioning
/godmode:event --dlq                    # Design dead letter queues and retry policies
/godmode:event --idempotency            # Design idempotency patterns for consumers
/godmode:event --catalog                # Generate event catalog documentation
/godmode:event --validate               # Validate existing event architecture
```

## What It Does

1. Assesses current architecture and event-driven requirements
2. Designs event sourcing with event store, snapshots, and aggregate reconstruction
3. Implements CQRS with separate read/write models and projections
4. Configures message broker topology (topics, partitions, exchanges, queues)
5. Designs event schema envelope with versioning and registry
6. Sets up dead letter queues with retry policies and exponential backoff
7. Implements idempotency patterns for safe message reprocessing
8. Validates architecture against 14 best-practice checks

## Output
- Event catalog at `docs/events/<system>-event-catalog.md`
- Schema definitions at `schemas/<domain>/<event>.avsc`
- Broker topology at `docs/events/<system>-broker-topology.md`
- CQRS design at `docs/events/<system>-cqrs.md`
- DLQ/Retry config at `infra/messaging/`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"event: <system> -- <N> event types, <broker>, <pattern>"`

## Next Step
After event design: `/godmode:micro` to design services, `/godmode:contract` to define event contracts, or `/godmode:build` to implement handlers.

## Examples

```
/godmode:event Design event sourcing for order management
/godmode:event --broker kafka              # Set up Kafka topics
/godmode:event --schema                    # Design event schemas
/godmode:event --dlq                       # Configure dead letter queues
/godmode:event --cqrs                      # Design CQRS architecture
```
