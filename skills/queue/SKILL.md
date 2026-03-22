---
name: queue
description: |
  Message queue and job processing skill. Activates when teams need to design, build, or debug asynchronous processing systems. Covers queue architecture (Kafka, RabbitMQ, SQS, Bull/BullMQ, Celery, Sidekiq), job scheduling, priority queues, rate limiting, dead letter handling, retry strategies, delivery guarantees (exactly-once, at-least-once, at-most-once), worker pool design, backpressure handling, and event-driven architecture patterns. Triggers on: /godmode:queue, "add background jobs", "set up a queue", "process async", "retry failed jobs", "dead letter queue", or when the application needs asynchronous processing.
---

# Queue — Message Queue & Job Processing

## When to Activate
- User invokes `/godmode:queue`
- User says "add background jobs", "process this async", "set up a queue"
- User says "retry failed jobs", "dead letter queue", "job is stuck"
- User says "rate limit processing", "throttle workers", "backpressure"
- User needs scheduled/recurring tasks, delayed execution, or delivery guarantees
- Application has long-running tasks blocking request handlers

## Workflow

### Step 1: Requirements Assessment

```
QUEUE REQUIREMENTS:
Use case: <job processing|event streaming|task queue|pub/sub|workflow>
Volume: <msg/sec>, Size: <avg payload>, Ordering: <strict FIFO|partition|best-effort|none>
Delivery: <exactly-once|at-least-once|at-most-once>
Latency: <<100ms|<1s|<30s|minutes>, Processing time: <<1s|seconds|minutes|hours>
Existing infra: <Redis|PostgreSQL|AWS|none>

TECHNOLOGY SELECTION:
  SQS: AWS-native, simple queues, unlimited throughput, managed
  BullMQ: Node.js + Redis, 10-50K/sec, great dashboard, built-in retry/scheduling
  Celery: Python + Redis/RabbitMQ, 10-50K/sec, complex task workflows
  Kafka: Event streaming, millions/sec, partition-ordered, replay-able
  RabbitMQ: Complex routing, multiple consumers, 10-50K/sec
  Redis Streams: Lightweight streaming, 100K+/sec
  PostgreSQL SKIP LOCKED: Already using PG, <1K jobs/sec, no new infra

DECISION: AWS simple? → SQS. Node.js+Redis? → BullMQ. Python tasks? → Celery.
  Event streaming+replay? → Kafka. Complex routing? → RabbitMQ. Low volume+PG? → SKIP LOCKED.
```

### Step 2: Queue Architecture

```
TOPOLOGY:
  Producers → Broker → [high-priority] → Worker Pool A (concurrency 10)
                      → [default]       → Worker Pool B (concurrency 20)
                      → [bulk]          → Worker Pool C (concurrency 5)
                      → [dead-letter]   → DLQ Processor (manual review)

Flow: produce → route → queue → consume → ack/nack → retry/DLQ

BULLMQ: Configure queues with attempts, exponential backoff, removeOnComplete/Fail.
KAFKA: Partition by entity_id, replication 3 (min ISR 2), retention 7 days.
CELERY: task_acks_late=True, prefetch_multiplier=1, reject_on_worker_lost=True.
```

### Step 3: Retry Strategy & Dead Letters

```
RETRY SCHEDULE: 0s → 1s → 4s → 16s → 60s (capped) → DLQ
Formula: min(base_delay * 2^attempt + jitter, max_delay)

RETRYABLE: Network timeouts, 5xx, DB connection errors, rate limits (429)
NON-RETRYABLE (fail immediately): 4xx validation, auth failures, deserialization, business logic

DLQ CONFIG:
  Queue: <original>-dlq, Retention: 30 days, Alert: depth > 100
  Processing options: Replay | Replay with fix | Skip | Escalate
```

### Step 4: Delivery Guarantees & Idempotency

```
At-most-once: Ack before process, no retries. Use for metrics/analytics/logs.
At-least-once: Ack after process, retry on failure, DLQ for poison. Most business tasks.
Exactly-once: Transactional + idempotency keys + deduplication. Payments/financial/orders.

IDEMPOTENCY PATTERN:
  1. Check Redis for key idempotent:{jobId}
  2. Acquire distributed lock (NX + TTL 300s)
  3. Process, store result (TTL 24h), release lock
  4. For payments: pass jobId as provider idempotency_key
```

### Step 5: Priority Queues & Rate Limiting

```
PRIORITY LEVELS:
  P0 critical: password reset, payment confirm — SLA < 10s
  P1 high: welcome email, order confirm — SLA < 60s
  P2 normal: notifications, image processing — SLA < 5m
  P3 low: reports, exports — SLA < 1h
  P4 background: cleanup, analytics — SLA < 24h

RATE LIMITING:
  Token bucket: API call limits (Redis + Lua)
  Sliding window: per-user limits (Redis sorted sets)
  Concurrency limit: resource protection (semaphore)
  Leaky bucket: smoothing bursts (fixed drain rate)

BullMQ limiter: { max: 100, duration: 60000 } // 100 req/min
```

### Step 6: Worker Pool & Backpressure

```
POOL DESIGN:
  Min workers: 2, Max: 20, Scale on queue depth > 100
  Concurrency/worker: 10 (I/O-bound), Max memory: 512MB
  Health check: 30s, Graceful shutdown timeout: 30s

BACKPRESSURE:
  Depth > 1K → WARN + alert
  Depth > 10K → SCALE workers up
  Depth > 100K → SHED low-priority jobs
  Worker memory > 80% → PAUSE accepting
  Downstream 5xx > 10% → CIRCUIT BREAK
  DLQ depth > 100 → ALERT + investigate

GRACEFUL SHUTDOWN: SIGTERM → pause (stop accepting) → close (finish current) → exit
CIRCUIT BREAKER: CLOSED → OPEN (threshold=5 failures) → HALF-OPEN (after 30s) → test one → CLOSED/OPEN
```

### Step 7: Job Scheduling

```
SCHEDULE DESIGN:
  Daily digest: 0 9 * * * (default queue, 5m timeout)
  Cleanup: 0 */6 * * * (bg queue, 30m timeout)
  Weekly reports: 0 2 * * 1 (bulk queue, 2h timeout)
  Inventory sync: */15 * * * * (high queue, 2m timeout)

SAFETY: Distributed lock (one scheduler), overlap protection, idempotent creation,
  all UTC, alert if job doesn't run within window. Remove old repeatable jobs on restart.
```

### Step 8: Monitoring

```
METRICS (with alert thresholds):
  Queue depth waiting (<1K), active (<50), delayed (<5K), DLQ (<100)
  Processing rate (>10/s), Success rate (>95%), Avg time (<10s), P95 (<30s)
  Oldest job age (<5m), Worker count (>2), Retry rate (<10%)

DASHBOARD: Queue depth over time, processing rate, success vs failure,
  processing time histogram, DLQ trend, worker utilization, top failing jobs
```

### Step 9: Commit
Save queue config, workers, retry/DLQ policy, schedules. Commit: `"queue: <name> — <tech>, <N> queues, <N> workers, <delivery guarantee>"`

## Key Behaviors

1. **Async anything over 500ms.** Never make users wait for background work.
2. **Idempotency is mandatory.** Design every at-least-once handler to run safely multiple times.
3. **Dead letters are not trash.** Every DLQ message is a failed user action. Monitor daily.
4. **Retry with backoff, not forever.** Exponential + jitter, cap at 3-5, then DLQ.
5. **Separate priority queues need separate workers.** Bulk backlogs must not starve critical.
6. **Graceful shutdown required.** Finish current job on SIGTERM.
7. **Monitor queue depth, not only throughput.** Growing depth is the leading indicator.
8. **Rate limit external API calls.** Respect third-party limits or get banned.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full queue architecture |
| `--tech <name>` | Target technology |
| `--diagnose` | Diagnose health issues |
| `--dlq` | Review/process dead letters |
| `--schedule` | Scheduled/recurring jobs |
| `--retry` | Retry strategy design |
| `--scale` | Worker scaling + backpressure |
| `--monitor` | Queue monitoring + alerting |

## Auto-Detection
```
Detect: queue SDK (bullmq, celery, sidekiq, kafkajs, sqs-consumer), broker in docker-compose,
env vars (REDIS_URL, RABBITMQ_URL, KAFKA_BROKERS, SQS_QUEUE_URL), job directories,
scheduling config, monitoring UIs, error logs with retry/DLQ patterns.
```

## HARD RULES

1. NEVER process >500ms tasks in request handlers — use background jobs.
2. NEVER retry without exponential backoff and jitter.
3. NEVER assume exactly-once — ALWAYS design idempotent handlers.
4. NEVER store >1MB payloads in queue — reference S3/storage.
5. NEVER share worker pools across priority levels.
6. NEVER skip graceful shutdown (SIGTERM handling).
7. ALWAYS configure DLQ for every production queue.
8. ALWAYS monitor DLQ depth and alert on growth.
9. ALWAYS classify errors as retryable vs non-retryable.
10. ALWAYS set job TTL/retention — queues are not permanent storage.

## Loop Protocol
```
WHILE SLA not met AND iterations < 4:
  1. DIAGNOSE top issue (depth growing, high errors, high latency, DLQ growing)
  2. APPLY single fix (scale, fix handler, add rate limit)
  3. MEASURE (5 min stabilization), EVALUATE
```

## Multi-Agent Dispatch
```
Agent 1 (queue-core): Infrastructure, producers, queue config, retry strategy
Agent 2 (queue-workers): Idempotent handlers, graceful shutdown, concurrency, circuit breaker
Agent 3 (queue-monitoring): DLQ + replay, metrics, dashboard, alerts, integration tests
MERGE: Core → Workers → Monitoring. Final: end-to-end job lifecycle test.
```

## Output Format
```
QUEUE SYSTEM COMPLETE:
Technology: <name>, Queues: <N>, Workers: <N> pools/<M> concurrency
Retry: exponential backoff max <N>, DLQ: <yes|no>
Idempotency: <yes|no>, Delivery: <guarantee>, Graceful shutdown: <yes|no>
Monitoring: <configured|not>
```

## TSV Logging
Append to `.godmode/queue-results.tsv`: `timestamp\tproject\ttechnology\tqueues_count\tworker_pools\tretry_strategy\tdlq_configured\tidempotency\tcommit_sha`

## Success Criteria
All >500ms tasks in queues, retry with backoff, DLQ configured, idempotent handlers, graceful shutdown, separate priority queues, no large payloads (<10KB), monitoring active.

## Error Recovery
```
Jobs stuck active → check logs, verify stalledInterval/timeout, check downstream.
DLQ growing → inspect patterns, fix root cause, replay after fix.
Memory exhaustion → check leaks, limit concurrency, add monitoring.
Duplicates → verify idempotency key, check job ID uniqueness, add dedup cache.
Backlog growing → scale workers, check processing time, add backpressure.
Connection lost → auto-reconnect with backoff, health check endpoint, alert.
```

## Keep/Discard Discipline
```
KEEP if depth stable AND error rate < 1% AND P95 < target AND DLQ not growing.
DISCARD if depth growing OR error spike OR DLQ growing.
Observe metrics 5 min minimum before keeping concurrency changes.
```

## Stop Conditions
```
STOP when: All >500ms tasks queued AND retry+backoff AND DLQ configured AND idempotent
  AND graceful shutdown AND monitoring active AND depth stable AND error rate < 1%
  OR user requests stop OR max 4 iterations
```

## Platform Fallback
Run sequentially if `Agent()` unavailable. Branch per task. See `adapters/shared/sequential-dispatch.md`.
