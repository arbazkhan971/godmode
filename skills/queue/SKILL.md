---
name: queue
description: Message queue and job processing -- Kafka,
  RabbitMQ, SQS, BullMQ, Celery, Sidekiq.
---

## Activate When
- `/godmode:queue`, "add background jobs", "set up queue"
- "retry failed jobs", "dead letter queue", "job stuck"
- "rate limit processing", "backpressure"

## Workflow

### 1. Requirements
```bash
grep -r "bullmq\|celery\|sidekiq\|kafkajs\|sqs" \
  package.json requirements.txt 2>/dev/null
```
```
Use case: job processing | event streaming | pub/sub
Volume: <msg/sec>, Payload: <avg size>
Ordering: strict FIFO | partition | best-effort
Delivery: exactly-once | at-least-once | at-most-once
Latency: <100ms | <1s | <30s
Existing infra: Redis | PostgreSQL | AWS | none
```

### 2. Technology Selection
```
SQS: AWS-native, managed, unlimited throughput
BullMQ: Node.js+Redis, 10-50K/sec, great dashboard
Celery: Python+Redis/RabbitMQ, complex workflows
Kafka: millions/sec, partition-ordered, replayable
RabbitMQ: complex routing, 10-50K/sec
Redis Streams: lightweight, 100K+/sec
PG SKIP LOCKED: no new infra, <1K jobs/sec
```
IF AWS simple: SQS. IF Node.js+Redis: BullMQ.
IF event streaming: Kafka. IF low volume+PG: SKIP LOCKED.

### 3. Architecture
```
Producers -> Broker
  -> [high-priority] -> Worker Pool A (concurrency 10)
  -> [default]       -> Worker Pool B (concurrency 20)
  -> [bulk]          -> Worker Pool C (concurrency 5)
  -> [dead-letter]   -> DLQ Processor
```

### 4. Retry Strategy & Dead Letters
```
Retry: 0s -> 1s -> 4s -> 16s -> 60s (cap) -> DLQ
Formula: min(base * 2^attempt + jitter, max_delay)

Retryable: network timeout, 5xx, DB connection, 429
Non-retryable: 4xx, auth, deserialization, biz logic

DLQ: <original>-dlq, retention 30 days, alert >100
Options: replay | replay with fix | skip | escalate
```

### 5. Delivery Guarantees & Idempotency
- At-most-once: ack before process (metrics/logs)
- At-least-once: ack after process + DLQ (most tasks)
- Exactly-once: transactional + idempotency keys
  (payments, financial, orders)

Idempotency: check Redis key, acquire lock (NX+TTL),
process, store result (TTL 24h), release lock.

### 6. Priority & Rate Limiting
```
P0 critical: password reset, payment (SLA <10s)
P1 high: welcome email, order confirm (SLA <60s)
P2 normal: notifications, image proc (SLA <5m)
P3 low: reports, exports (SLA <1h)
P4 background: cleanup, analytics (SLA <24h)
```
Rate limit: token bucket or BullMQ limiter
`{ max: 100, duration: 60000 }`.

### 7. Worker Pool & Backpressure
```
Min workers: 2, Max: 20, Scale on depth > 100
Concurrency per worker: 10 (I/O-bound)

Backpressure:
  Depth > 1K -> WARN + alert
  Depth > 10K -> SCALE workers
  Depth > 100K -> SHED low-priority
  Worker memory > 80% -> PAUSE accepting
  Downstream 5xx > 10% -> CIRCUIT BREAK
```
Graceful shutdown: SIGTERM -> pause -> finish -> exit.

### 8. Scheduling
```
Daily digest: 0 9 * * * (default, 5m timeout)
Cleanup: 0 */6 * * * (bg, 30m timeout)
Weekly reports: 0 2 * * 1 (bulk, 2h timeout)
```
Distributed lock (one scheduler), all UTC,
alert if job misses window.

### 9. Monitoring
```
Queue depth waiting (<1K), active (<50), DLQ (<100)
Processing rate (>10/s), Success rate (>95%)
Avg time (<10s), P95 (<30s)
Worker count (>2), Retry rate (<10%)
```

## Hard Rules
1. NEVER >500ms tasks in request handlers.
2. NEVER retry without exponential backoff + jitter.
3. ALWAYS design idempotent handlers.
4. NEVER >1MB payloads in queue (use S3 reference).
5. NEVER share workers across priority levels.
6. NEVER skip graceful shutdown (SIGTERM).
7. ALWAYS configure DLQ for every production queue.
8. ALWAYS monitor DLQ depth and alert.
9. ALWAYS classify retryable vs non-retryable.
10. ALWAYS set job TTL/retention.

## TSV Logging
Append `.godmode/queue-results.tsv`:
```
timestamp	technology	queues	worker_pools	retry	dlq	idempotency	status
```

## Keep/Discard
```
KEEP if: depth stable AND error rate < 1%
  AND P95 < target AND DLQ not growing.
DISCARD if: depth growing OR error spike
  OR DLQ growing.
```

## Stop Conditions
```
STOP when ALL of:
  - All >500ms tasks queued
  - Retry + backoff configured
  - DLQ on all queues
  - Idempotent handlers
  - Graceful shutdown
  - Error rate < 1%
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Jobs stuck active | Check logs, verify timeout |
| DLQ growing | Inspect patterns, fix root cause |
| Memory exhaustion | Limit concurrency, check leaks |
| Duplicates | Verify idempotency key, add dedup |
| Backlog growing | Scale workers, add backpressure |
