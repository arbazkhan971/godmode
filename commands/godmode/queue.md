# /godmode:queue

Design, build, and debug message queue and job processing systems. Covers queue architecture (Kafka, RabbitMQ, SQS, BullMQ, Celery), retry strategies, dead letter handling, delivery guarantees, priority queues, worker pool design, and backpressure handling.

## Usage

```
/godmode:queue                             # Full queue architecture design workflow
/godmode:queue --tech bullmq               # Target BullMQ specifically
/godmode:queue --tech kafka                # Design Kafka event streaming
/godmode:queue --tech sqs                  # Design AWS SQS queue
/godmode:queue --diagnose                  # Diagnose queue health issues
/godmode:queue --dlq                       # Review and process dead letter queue
/godmode:queue --schedule                  # Design scheduled/recurring jobs
/godmode:queue --retry                     # Design retry strategy
/godmode:queue --scale                     # Design worker scaling and backpressure
/godmode:queue --monitor                   # Set up queue monitoring
/godmode:queue --benchmark                 # Run queue throughput benchmarks
```

## What It Does

1. Assesses queue requirements (volume, ordering, delivery guarantees, latency)
2. Selects the appropriate queue technology based on constraints
3. Designs queue topology (exchanges, routing, priority levels)
4. Implements retry strategy with exponential backoff and jitter
5. Configures dead letter queue with structured error capture
6. Designs delivery guarantee implementation (idempotency keys, deduplication)
7. Sets up priority queues with separate worker pools
8. Implements rate limiting for external service calls
9. Designs worker pool scaling with backpressure handling
10. Establishes queue monitoring and alerting

## Output
- Queue configuration at `config/queues/<queue-name>.ts`
- Worker definitions at `workers/<queue-name>-worker.ts`
- Retry policy at `config/queues/retry-policy.ts`
- Scheduled jobs at `config/queues/schedules.ts`
- Commit: `"queue: <queue-name> — <technology>, <N> queues, <N> workers, <delivery guarantee>"`

## Next Step
After queue setup: `/godmode:observe` to add queue monitoring, or `/godmode:ship` to deploy workers.

## Examples

```
/godmode:queue Set up async email processing for our API
/godmode:queue --tech kafka Design event streaming for order processing
/godmode:queue --diagnose Jobs are piling up and not processing
/godmode:queue --dlq Review and replay failed jobs
/godmode:queue --schedule Set up daily report generation
```
