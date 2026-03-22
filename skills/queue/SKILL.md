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
- User needs to decouple services or handle eventual consistency
- User needs scheduled jobs, cron-like recurring tasks, or delayed execution
- Application has long-running tasks blocking request handlers
- User asks about delivery guarantees, idempotency, or message ordering
- Godmode orchestrator detects synchronous processing that should be async

## Workflow

### Step 1: Queue Requirements Assessment

Evaluate the processing needs, constraints, and appropriate architecture:

```
QUEUE REQUIREMENTS ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│  Dimension          │ Value                               │
│  ─────────────────────────────────────────────────────── │
│  Use case           │ <job processing | event streaming | │
│                     │  task queue | pub/sub | workflow>    │
│  Message volume     │ <messages per second>               │
│  Message size       │ <avg payload size>                  │
│  Ordering required  │ <strict FIFO | partition-ordered |  │
│                     │  best-effort | none>                │
│  Delivery guarantee │ <exactly-once | at-least-once |     │
│                     │  at-most-once>                      │
│  Latency target     │ << 100ms | < 1s | < 30s | minutes> │
│  Retention          │ <process once | replay-able |       │
│                     │  N days retention>                  │
│  Processing time    │ << 1s | seconds | minutes | hours>  │
│  Failure rate       │ <expected % of failures>            │
│  Existing infra     │ <Redis | PostgreSQL | AWS | none>   │
│  Team expertise     │ <none | basic | advanced>           │
├──────────────────────────────────────────────────────────┤
│  Recommendation: <technology selection with rationale>    │
└──────────────────────────────────────────────────────────┘
```

#### Technology Selection Matrix
```
QUEUE TECHNOLOGY SELECTION:
┌──────────────────┬────────────┬───────────┬──────────┬───────────┬────────────┐
│ Technology       │ Best for   │ Throughput│ Ordering │ Delivery  │ Ops cost   │
├──────────────────┼────────────┼───────────┼──────────┼───────────┼────────────┤
│ Kafka            │ Event      │ Millions/ │ Partition│ At-least  │ High       │
│                  │ streaming, │ sec       │ ordered  │ once      │            │
│                  │ log aggr.  │           │          │ (EOS opt) │            │
│                  │            │           │          │           │            │
│ RabbitMQ         │ Task       │ 10K-50K/  │ Per-queue│ At-least  │ Medium     │
│                  │ routing,   │ sec       │ FIFO     │ once      │            │
│                  │ complex    │           │          │           │            │
│                  │ topologies │           │          │           │            │
│                  │            │           │          │           │            │
│ SQS              │ AWS-native │ Unlimited │ FIFO     │ At-least  │ None       │
│                  │ simple     │ (standard)│ (FIFO    │ once      │ (managed)  │
│                  │ queues     │           │ queues)  │ (EO FIFO) │            │
│                  │            │           │          │           │            │
│ Bull/BullMQ      │ Node.js    │ 10K-50K/  │ Per-queue│ At-least  │ Low (Redis)│
│                  │ job queues │ sec       │ FIFO     │ once      │            │
│                  │            │           │          │           │            │
│ Celery           │ Python     │ 10K-50K/  │ Per-queue│ At-least  │ Low-Medium │
│                  │ task queues│ sec       │ FIFO     │ once      │            │
│                  │            │           │          │           │            │
│ Sidekiq          │ Ruby job   │ 10K-25K/  │ Per-queue│ At-least  │ Low (Redis)│
│                  │ processing │ sec       │ FIFO     │ once      │            │
│                  │            │           │          │           │            │
│ Redis Streams    │ Lightweight│ 100K+/    │ Per-     │ At-least  │ Low        │
│                  │ event      │ sec       │ stream   │ once      │            │
│                  │ streaming  │           │          │           │            │
│                  │            │           │          │           │            │
│ PostgreSQL       │ Already    │ 1K-5K/    │ Advisory │ At-least  │ None       │
│ (SKIP LOCKED)    │ using PG,  │ sec       │ locks    │ once      │ (no new)   │
│                  │ low volume │           │          │           │            │
└──────────────────┴────────────┴───────────┴──────────┴───────────┴────────────┘

Decision tree:
  Already on AWS + simple queue needs?           → SQS (+ SQS FIFO for ordering)
  Node.js + Redis available + job processing?    → BullMQ
  Python + complex task workflows?               → Celery (+ Redis or RabbitMQ broker)
  Event streaming + replay + high throughput?    → Kafka
  Complex routing + multiple consumers?          → RabbitMQ
  Already using PG + < 1K jobs/sec?              → PostgreSQL SKIP LOCKED
  Lightweight streaming + Redis available?       → Redis Streams
```

### Step 2: Queue Architecture Design

Design the queue topology, exchanges, and routing:

```
QUEUE ARCHITECTURE:
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  Producers              Broker                   Consumers           │
│  ─────────             ──────                   ──────────           │
│                                                                      │
│  API Server ──┐     ┌─ [high-priority] ──────── Worker Pool A (3)   │
│               │     │  TTL: none                  Concurrency: 10   │
│  Webhook   ───┼────>├─ [default]      ──────── Worker Pool B (5)   │
│  Handler      │     │  TTL: 24h                   Concurrency: 20   │
│               │     │                                                │
│  Scheduler ───┘     ├─ [bulk]         ──────── Worker Pool C (2)   │
│  (cron)             │  TTL: 72h                   Concurrency: 5    │
│                     │                                                │
│                     └─ [dead-letter]  ──────── DLQ Processor (1)   │
│                        TTL: 30 days               Manual review     │
│                                                                      │
│  Flow: produce → route → queue → consume → ack/nack → retry/DLQ    │
└──────────────────────────────────────────────────────────────────────┘
```

#### BullMQ Architecture (Node.js)
```typescript
import { Queue, Worker, QueueScheduler, QueueEvents } from 'bullmq';
import Redis from 'ioredis';

const connection = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  maxRetriesPerRequest: null, // Required by BullMQ
});

// Define queues by priority/purpose
const emailQueue = new Queue('email', {
  connection,
  defaultJobOptions: {
    attempts: 3,
    backoff: { type: 'exponential', delay: 1000 },
    removeOnComplete: { age: 86400, count: 1000 },
    removeOnFail: { age: 604800 },
  },
});

const bulkQueue = new Queue('bulk-processing', {
  connection,
  defaultJobOptions: {
    attempts: 5,
    backoff: { type: 'exponential', delay: 5000 },
    removeOnComplete: { age: 172800 },
    removeOnFail: false, // Keep all failed jobs for review
  },
});

// Jobs: add with priority (1=highest), delay (ms), repeat (cron pattern)
```

#### Kafka Configuration
```
KAFKA TOPIC DESIGN:
  Partitions: keyed by entity_id for ordering (6 typical)
  Replication: 3 (min ISR: 2 for durability)
  Retention: 7 days (event log), compaction for state topics
  Consumer groups: 1 consumer per partition for max parallelism
```

#### Celery Configuration (Python)
```
KEY CELERY SETTINGS:
  task_acks_late=True           # At-least-once delivery
  worker_prefetch_multiplier=1  # One task at a time per worker
  task_reject_on_worker_lost=True  # Requeue on worker crash
  task_max_retries=5            # Max retry attempts
  task_routes: route tasks to priority queues (high-priority, default, bulk)
  beat_schedule: crontab-based recurring tasks via celery beat
```

### Step 3: Retry Strategy & Dead Letter Handling

Design resilient failure handling:

```
RETRY STRATEGY:
┌──────────────────────────────────────────────────────────┐
│  Attempt │ Delay    │ Backoff   │ Action                  │
│  ─────────────────────────────────────────────────────── │
│  1       │ 0s       │ —         │ Immediate processing    │
│  2       │ 1s       │ —         │ First retry             │
│  3       │ 4s       │ 2^2       │ Exponential backoff     │
│  4       │ 16s      │ 2^4       │ Exponential backoff     │
│  5       │ 60s      │ capped    │ Final retry             │
│  FAIL    │ —        │ —         │ Move to DLQ             │
└──────────────────────────────────────────────────────────┘

Backoff formula: min(base_delay * 2^attempt + jitter, max_delay)
  base_delay: 1000ms
  max_delay: 60000ms (1 minute)
  jitter: random(0, 500ms) — prevents thundering herd

Retryable errors:
  - Network timeouts
  - 5xx from downstream services
  - Database connection errors
  - Rate limit (429) responses
  - Temporary file system errors

Non-retryable errors (fail immediately):
  - 4xx validation errors (bad input)
  - Authentication failures (401/403)
  - Deserialization errors (corrupt message)
  - Business logic violations
  - Missing required resources (404 on critical dependency)
```

#### Dead Letter Queue Design
```
DLQ CONFIGURATION:
  Queue name: <original-queue>-dlq
  Retention: 30 days, max 100K messages
  Alert: DLQ depth > 100, review daily
  Message fields: original_queue, job_id, payload, attempts, errors[], timestamps
  Processing: Replay | Replay with fix | Skip | Escalate to incident
```

#### Retry Implementation Pattern
```
RETRY-AWARE WORKER:
1. In the worker handler, wrap processing in try/catch
2. On error: classify as retryable or non-retryable
   - Non-retryable (4xx, validation, auth): send to DLQ, return without throwing
   - Retryable (5xx, timeout, connection): throw to trigger BullMQ built-in retry
3. Configure worker with concurrency limit and rate limiter
```

### Step 4: Delivery Guarantees & Idempotency

Design for the correct delivery semantics:

```
DELIVERY GUARANTEES:
┌──────────────────────────────────────────────────────────┐
│  Guarantee       │ Mechanism          │ Trade-off         │
│  ─────────────────────────────────────────────────────── │
│  At-most-once    │ Ack before process │ May lose messages │
│                  │ No retries         │ Simplest, fastest │
│                  │ Fire-and-forget    │ Use for: metrics, │
│                  │                    │ analytics, logs   │
│                  │                    │                   │
│  At-least-once   │ Ack after process  │ May duplicate     │
│                  │ Retry on failure   │ Requires idempot. │
│                  │ DLQ for poisons    │ Use for: most     │
│                  │                    │ business tasks    │
│                  │                    │                   │
│  Exactly-once    │ Transactional      │ Highest latency   │
│                  │ processing         │ Complex to impl.  │
│                  │ Idempotency keys   │ Use for: payments,│
│                  │ Deduplication      │ financial, orders  │
└──────────────────────────────────────────────────────────┘
```

#### Idempotency Pattern
```
IDEMPOTENCY IMPLEMENTATION:
1. Check Redis for key `idempotent:{jobId}` — if exists, return cached result
2. Acquire distributed lock `lock:idempotent:{jobId}` with NX + TTL (300s)
3. If lock acquired: run handler, store result with TTL (24h), release lock
4. If lock not acquired: another worker is processing — throw and retry later
5. For payment jobs: pass job.id as Stripe/provider idempotency_key too
```

### Step 5: Priority Queues & Rate Limiting

Design job prioritization and throughput control:

```
PRIORITY QUEUE DESIGN:
┌──────────────────────────────────────────────────────────┐
│  Priority  │ Queue           │ Use case           │ SLA   │
│  ─────────────────────────────────────────────────────── │
│  P0 (crit) │ critical        │ Password reset,    │ < 10s │
│            │                 │ payment confirm    │       │
│  P1 (high) │ high-priority   │ Welcome email,     │ < 60s │
│            │                 │ order confirmation │       │
│  P2 (norm) │ default         │ Notifications,     │ < 5m  │
│            │                 │ image processing   │       │
│  P3 (low)  │ bulk            │ Reports, exports,  │ < 1h  │
│            │                 │ batch processing   │       │
│  P4 (bg)   │ background      │ Cleanup, analytics │ < 24h │
│            │                 │ aggregation        │       │
└──────────────────────────────────────────────────────────┘

Worker allocation:
  critical:     2 workers, concurrency 5  (always available)
  high-priority: 3 workers, concurrency 10
  default:      5 workers, concurrency 20
  bulk:         2 workers, concurrency 5
  background:   1 worker, concurrency 2
```

#### Rate Limiting Patterns
```
RATE LIMITING STRATEGIES:
┌──────────────────────────────────────────────────────────┐
│  Pattern            │ Use case              │ Impl.       │
│  ─────────────────────────────────────────────────────── │
│  Token bucket       │ API call limits       │ Redis +     │
│                     │ (e.g., 100 req/min    │ Lua script  │
│                     │ to external API)      │             │
│                     │                       │             │
│  Sliding window     │ Per-user rate limits  │ Redis       │
│                     │ (e.g., 10 emails/hr   │ sorted sets │
│                     │ per user)             │             │
│                     │                       │             │
│  Concurrency limit  │ Resource protection   │ Semaphore   │
│                     │ (e.g., max 5 PDF      │ (Redis or   │
│                     │ renders at once)      │ BullMQ)     │
│                     │                       │             │
│  Leaky bucket       │ Smoothing bursts      │ Queue with  │
│                     │ (steady output rate)  │ fixed drain │
└──────────────────────────────────────────────────────────┘
```

#### Rate Limiter Implementation
```typescript
// BullMQ rate-limited worker
const rateLimitedWorker = new Worker('external-api-calls', async (job) => {
  return callExternalAPI(job.data);
}, {
  connection,
  concurrency: 5,
  limiter: {
    max: 100,       // Max 100 jobs
    duration: 60000, // Per minute (100 req/min to external API)
  },
});

// Per-key rate limiting (e.g., per user)
class PerKeyRateLimiter {
  constructor(private redis: Redis) {}

  async checkLimit(key: string, maxRequests: number, windowSec: number): Promise<boolean> {
    const now = Date.now();
    const windowStart = now - (windowSec * 1000);
    const redisKey = `ratelimit:${key}`;

    const pipeline = this.redis.pipeline();
    pipeline.zremrangebyscore(redisKey, 0, windowStart); // Remove old entries
    pipeline.zadd(redisKey, now, `${now}`);              // Add current
    pipeline.zcard(redisKey);                             // Count in window
    pipeline.expire(redisKey, windowSec);                 // Auto-cleanup

    const results = await pipeline.exec();
    const count = results![2][1] as number;
    return count <= maxRequests;
  }
}
```

### Step 6: Worker Pool Design & Backpressure

Design worker scaling and backpressure handling:

```
WORKER POOL DESIGN:
┌──────────────────────────────────────────────────────────┐
│  Parameter           │ Value     │ Rationale              │
│  ─────────────────────────────────────────────────────── │
│  Min workers         │ 2         │ Always-on for latency  │
│  Max workers         │ 20        │ Resource cap           │
│  Scale-up trigger    │ Queue     │ Add worker when queue  │
│                      │ depth > 100│ depth exceeds threshold│
│  Scale-down trigger  │ Queue     │ Remove worker when idle│
│                      │ depth = 0 │ for 5 minutes          │
│                      │ for 5m    │                        │
│  Concurrency/worker  │ 10        │ I/O-bound tasks allow  │
│                      │           │ concurrent processing  │
│  Max memory/worker   │ 512MB     │ OOM protection         │
│  Health check        │ 30s       │ Restart stuck workers  │
│  Graceful shutdown   │ 30s       │ Finish current job     │
│                      │ timeout   │ before exit            │
└──────────────────────────────────────────────────────────┘

BACKPRESSURE HANDLING:
┌──────────────────────────────────────────────────────────┐
│  Trigger                │ Action                          │
│  ─────────────────────────────────────────────────────── │
│  Queue depth > 1,000    │ WARN: Alert team, log metric   │
│  Queue depth > 10,000   │ SCALE: Auto-scale workers up   │
│  Queue depth > 100,000  │ SHED: Reject low-priority jobs │
│  Worker memory > 80%    │ PAUSE: Stop accepting new jobs │
│  Downstream 5xx > 10%   │ CIRCUIT BREAK: Pause queue,    │
│                         │ wait for recovery              │
│  DLQ depth > 100        │ ALERT: Investigate failures    │
│  Job age > SLA          │ ESCALATE: Page on-call          │
└──────────────────────────────────────────────────────────┘
```

#### Graceful Shutdown Pattern
```
SIGTERM HANDLER:
1. On SIGTERM: call worker.pause() — stop accepting new jobs
2. Set shutdown timeout (30s) — force exit if current job does not complete
3. Call worker.close() — wait for current job to finish
4. Clear timeout, exit 0
```

#### Circuit Breaker Pattern
```
CIRCUIT BREAKER (for downstream dependencies):
States: CLOSED → OPEN → HALF-OPEN → CLOSED
- CLOSED: forward all requests. On failure: increment counter.
- OPEN (threshold reached): reject all requests. After resetTimeout: move to HALF-OPEN.
- HALF-OPEN: allow one request. On success: CLOSED. On failure: OPEN.
Config: threshold=5 failures, resetTimeout=30s.
```

### Step 7: Job Scheduling & Recurring Tasks

Design scheduled and recurring job execution:

```
SCHEDULE DESIGN:
┌──────────────────────────────────────────────────────────┐
│  Job                │ Schedule       │ Queue    │ Timeout │
│  ─────────────────────────────────────────────────────── │
│  Daily digest email │ 0 9 * * *     │ default  │ 5m      │
│  Cleanup expired    │ 0 */6 * * *   │ bg       │ 30m     │
│  sessions           │               │          │         │
│  Generate reports   │ 0 2 * * 1     │ bulk     │ 2h      │
│  (weekly)           │               │          │         │
│  Sync inventory     │ */15 * * * *  │ high     │ 2m      │
│  Health check       │ */5 * * * *   │ critical │ 30s     │
│  Invoice generation │ 0 0 1 * *     │ bulk     │ 4h      │
│  (monthly)          │               │          │         │
└──────────────────────────────────────────────────────────┘

Schedule safety:
  - Distributed lock: Only one scheduler instance creates jobs
  - Overlap protection: Skip if previous run still executing
  - Idempotency: Safe to create duplicate scheduled jobs (deduplicated)
  - Timezone: All schedules in UTC (convert for display only)
  - Monitoring: Alert if scheduled job does not run within expected window
```

#### Scheduled Jobs Implementation
```typescript
// BullMQ repeatable jobs with safety
async function setupScheduledJobs(queue: Queue) {
  // Remove old schedules to prevent duplicates on restart
  const existingRepeatableJobs = await queue.getRepeatableJobs();
  for (const job of existingRepeatableJobs) {
    await queue.removeRepeatableByKey(job.key);
  }

  // Daily digest at 9 AM UTC
  await queue.add('daily-digest', {}, {
    repeat: { pattern: '0 9 * * *' },
    jobId: 'daily-digest', // Prevent duplicates
  });

  // Cleanup every 6 hours
  await queue.add('cleanup-sessions', {}, {
    repeat: { pattern: '0 */6 * * *' },
    jobId: 'cleanup-sessions',
  });

  // Inventory sync every 15 minutes
  await queue.add('sync-inventory', {}, {
    repeat: { pattern: '*/15 * * * *' },
    jobId: 'sync-inventory',
  });
}
```

### Step 8: Monitoring & Observability

Track queue health and job processing metrics:

```
QUEUE MONITORING:
┌──────────────────────────────────────────────────────────┐
│  Metric                    │ Current  │ Alert     │ Status│
│  ─────────────────────────────────────────────────────── │
│  Queue depth (waiting)     │ 42       │ > 1,000   │ OK    │
│  Queue depth (active)      │ 10       │ > 50      │ OK    │
│  Queue depth (delayed)     │ 156      │ > 5,000   │ OK    │
│  DLQ depth                 │ 3        │ > 100     │ OK    │
│  Processing rate (jobs/s)  │ 45       │ < 10      │ OK    │
│  Success rate              │ 99.2%    │ < 95%     │ OK    │
│  Avg processing time       │ 1.2s     │ > 10s     │ OK    │
│  P95 processing time       │ 4.8s     │ > 30s     │ OK    │
│  Oldest job age            │ 12s      │ > 5m      │ OK    │
│  Worker count              │ 5        │ < 2       │ OK    │
│  Worker memory avg         │ 256MB    │ > 450MB   │ OK    │
│  Retry rate                │ 2.1%     │ > 10%     │ OK    │
└──────────────────────────────────────────────────────────┘

Dashboard panels:
  1. Queue depth over time (line chart, by queue)
  2. Processing rate over time (line chart)
  3. Success vs failure rate (stacked area)
  4. Processing time distribution (histogram)
  5. DLQ depth trend (line chart with alert threshold)
  6. Worker utilization (gauge per worker)
  7. Top failing jobs (table with error details)
  8. Job latency (time from enqueue to completion)
```

### Step 9: Commit and Transition

```
1. Save queue configuration as `config/queues/<queue-name>.ts`
2. Save worker definitions as `workers/<queue-name>-worker.ts`
3. Save retry/DLQ config as `config/queues/retry-policy.ts`
4. Save scheduled jobs as `config/queues/schedules.ts`
5. Commit: "queue: <queue-name> — <technology>, <N> queues, <N> workers, <delivery guarantee>"
6. If new queue: "Queue infrastructure configured. <N> queues, <N> workers. Deploy and monitor."
7. If fixing failures: "Retry strategy improved. DLQ processing added. Monitor DLQ depth."
8. If scaling: "Worker pool scaled to <N>. Backpressure handling added at <threshold>."
```

## Auto-Detection

Before prompting the user, automatically detect queue infrastructure:

```
AUTO-DETECT SEQUENCE:
1. Detect existing queue technology:
   - package.json: bullmq, bull, bee-queue, amqplib, kafkajs, sqs-consumer
   - requirements.txt: celery, dramatiq, rq, kombu
   - Gemfile: sidekiq, good_job, delayed_job, solid_queue
   - go.mod: asynq, machinery, watermill
2. Detect broker infrastructure:
   - docker-compose.yml: redis, rabbitmq, kafka, zookeeper images
   - Environment vars: REDIS_URL, RABBITMQ_URL, KAFKA_BROKERS, SQS_QUEUE_URL
   - AWS config: SQS queue ARNs, SNS topic ARNs
3. Detect existing job definitions:
   - app/jobs/ (Rails), tasks/ (Celery), workers/ (BullMQ)
   - Scan for perform, process, handle method patterns
4. Detect scheduling:
   - cron patterns in code or config
   - sidekiq-scheduler, celery beat config, BullMQ repeat patterns
5. Detect monitoring:
   - Bull Board, Flower, Sidekiq Web UI routes
   - Prometheus metrics endpoints for queue depth
6. Detect pain points:
   - Error logs with retry/DLQ patterns
   - Memory usage spikes in worker processes
   - Growing queue depth in monitoring
```

## Explicit Loop Protocol

For iterative queue health diagnosis and tuning:

```
QUEUE TUNING LOOP:
current_iteration = 0
max_iterations = 4
baseline = capture_queue_metrics()  # depth, processing_rate, error_rate, p95_latency

WHILE current_iteration < max_iterations AND SLA_not_met:
  current_iteration += 1

  1. DIAGNOSE top issue:
     - Queue depth growing? -> insufficient workers or slow processing
     - High error rate? -> fix error handling, add retries
     - High p95 latency? -> worker concurrency, downstream bottleneck
     - DLQ growing? -> investigate failure patterns

  2. APPLY single fix:
     - Scale workers / adjust concurrency / fix error handler / add rate limit
     - ONE change per iteration

  3. MEASURE:
     - Wait for metrics to stabilize (minimum 5 minutes under load)
     - Record: { iteration, change, depth, rate, error_rate, p95 }

  4. EVALUATE:
     - IF all SLAs met (depth < threshold, latency < target): STOP
     - IF improvement < 10%: try different approach
     - ELSE: continue to next issue

  OUTPUT:
  Iteration | Change | Queue Depth | Rate | Error % | P95
  0         | baseline| 12,847     | 0/s  | 100%    | N/A
  1         | reconnect| 12,847    | 200/s| 2.1%    | 4.8s
  ...
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. NEVER process tasks > 500ms in request handlers — use background jobs.
2. NEVER retry without exponential backoff and jitter.
3. NEVER assume jobs run exactly once — ALWAYS design handlers to be idempotent.
4. NEVER store large payloads (> 1MB) in the queue — store in S3, reference in job.
5. NEVER share worker pools across priority levels — separate queues, separate workers.
6. NEVER skip graceful shutdown — handle SIGTERM, finish current job, then exit.
7. ALWAYS configure a dead letter queue for every production queue.
8. ALWAYS monitor DLQ depth and alert when it grows.
9. ALWAYS classify errors as retryable vs non-retryable before retrying.
10. ALWAYS set job TTL / retention limits — queues are not permanent storage.
11. NEVER use polling intervals shorter than processing time.
12. ALWAYS use idempotency keys for financial/payment jobs.
```

## Key Behaviors

1. **Async by default for anything over 500ms.** If a request handler does work that takes more than 500ms, it should be a background job. Do not make users wait.
2. **Idempotency is mandatory for at-least-once delivery.** Every job handler must be safe to run multiple times with the same input. Use idempotency keys, database upserts, or deduplication.
3. **Dead letters are not trash.** Every message in the DLQ represents a user action that failed. Monitor it, alert on it, review it daily.
4. **Retry with backoff, not retry forever.** Exponential backoff with jitter prevents thundering herds. Cap retries at a reasonable number (3-5), then DLQ.
5. **Priority queues need separate workers.** If high-priority and low-priority jobs share a worker pool, a bulk job backlog will starve critical jobs. Separate them.
6. **Graceful shutdown is required.** Workers must finish their current job before exiting. SIGTERM means "stop accepting new work," not "die immediately."
7. **Monitor queue depth, not just throughput.** High throughput means nothing if the queue is growing faster than you can process. Queue depth is the leading indicator.
8. **Rate limit calls to external services.** External APIs have rate limits. Your job queue must respect them or you get banned. Use token bucket or BullMQ limiter.

## Example Usage

### Setting up background job processing
```
User: /godmode:queue Set up async email processing for our Node.js API

Queue: Assessing queue requirements...

QUEUE REQUIREMENTS:
  Use case: Job processing (send emails)
  Volume: ~500 emails/hour peak
  Ordering: Not required
  Delivery: At-least-once (emails are idempotent via provider)
  Latency: < 60s for transactional, < 5m for bulk
  Existing infra: Redis available

Recommendation: BullMQ
  Rationale: Node.js native, Redis already available, excellent
  dashboard (Bull Board), built-in retry and scheduling.

Setting up queues...
  email-transactional: priority 1, concurrency 10, 3 retries
  email-bulk: priority 10, concurrency 5, 5 retries, rate limited 100/min
  email-dlq: manual review, 30-day retention

Workers configured:
  2 workers for transactional (always-on)
  1 worker for bulk (scales to 3)
  DLQ processor with Slack alerts

Monitoring:
  Queue depth, processing rate, DLQ depth metrics exposed
  Alerts: DLQ > 10, queue depth > 500, processing time > 30s

Queue ready. Test with: await emailQueue.add('send-welcome', { userId: '123' })
```

### Debugging stuck jobs
```
User: /godmode:queue --diagnose Jobs are piling up and not processing

Queue: Diagnosing queue health...

QUEUE HEALTH CHECK:
  Queue depth: 12,847 — CRITICAL (growing at 200/min)
  Active jobs: 0 — NO WORKERS PROCESSING
  Workers: 3 running but 0 active connections
  Last processed: 45 minutes ago
  DLQ: 0

Root cause: Redis connection lost
  Workers lost connection at 10:15 UTC
  No automatic reconnection configured
  Jobs continued to enqueue but no consumers

Fix applied:
  1. Added Redis reconnection strategy (exponential backoff)
  2. Added health check endpoint for workers
  3. Added worker heartbeat monitoring
  4. Restarted workers — processing resumed

Recovery status:
  Backlog: 12,847 jobs processing at 200/sec
  ETA to clear: ~65 seconds
  No data loss (at-least-once delivery preserved)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full queue architecture design workflow |
| `--tech <name>` | Target specific technology (kafka, rabbitmq, sqs, bullmq, celery) |
| `--diagnose` | Diagnose queue health issues (stuck jobs, growing depth) |
| `--dlq` | Review and process dead letter queue |
| `--schedule` | Design scheduled/recurring jobs only |
| `--retry` | Design retry strategy and error handling |
| `--scale` | Design worker scaling and backpressure |
| `--monitor` | Set up queue monitoring and alerting |
| `--migrate` | Migrate from one queue technology to another |
| `--benchmark` | Run queue throughput benchmarks |

## Multi-Agent Dispatch

```
PARALLEL QUEUE AGENTS:
When building a complete queue system with multiple queue types:

Agent 1 (worktree: queue-core):
  - Set up queue infrastructure (Redis/RabbitMQ/SQS connection)
  - Implement job producers with structured payloads
  - Configure queues by priority (critical, default, bulk)
  - Add retry strategy with exponential backoff + jitter

Agent 2 (worktree: queue-workers):
  - Implement idempotent job handlers for each job type
  - Add graceful shutdown (SIGTERM handling)
  - Configure worker concurrency per queue
  - Add circuit breaker for downstream dependencies

Agent 3 (worktree: queue-monitoring):
  - Configure DLQ with replay tooling
  - Add queue metrics (depth, processing time, failure rate)
  - Create monitoring dashboard and alerts
  - Write integration tests (job lifecycle, retry, DLQ)

MERGE: Core merges first. Workers rebase onto core.
  Monitoring rebases onto workers. Final: end-to-end job lifecycle test.
```

## Output Format

```
QUEUE SYSTEM COMPLETE:
  Technology: <BullMQ | Kafka | RabbitMQ | SQS | Celery | other>
  Queues: <N> queues configured
  Workers: <N> worker pools, <M> total concurrency
  Retry strategy: exponential backoff, max <N> attempts, jitter: <on|off>
  DLQ: <configured | not configured> — max retries before DLQ: <N>
  Idempotency: <implemented | not implemented>
  Delivery guarantee: <at-least-once | exactly-once | at-most-once>
  Graceful shutdown: <implemented | not implemented>
  Monitoring: <configured | not configured>

QUEUE SUMMARY:
+--------------------------------------------------------------+
|  Queue Name      | Priority | Concurrency | Retry | DLQ      |
+--------------------------------------------------------------+
|  <queue>         | high     | 5           | 3x    | yes      |
+--------------------------------------------------------------+
```

## TSV Logging

Log every queue design session to `.godmode/queue-results.tsv`:

```
Fields: timestamp\tproject\ttechnology\tqueues_count\tworker_pools\tretry_strategy\tdlq_configured\tidempotency\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-app\tbullmq\t4\t3\texponential\tyes\tyes\tabc1234
```

Append after every completed queue design or implementation pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
QUEUE SUCCESS CRITERIA:
+--------------------------------------------------------------+
|  Criterion                                  | Required         |
+--------------------------------------------------------------+
|  All long tasks (>500ms) moved to queue     | YES              |
|  Retry strategy with exponential backoff    | YES              |
|  Dead letter queue configured               | YES              |
|  Idempotent job handlers                    | YES              |
|  Graceful shutdown (SIGTERM handling)        | YES              |
|  Separate queues by priority                | YES              |
|  No large payloads in job data (<10KB)      | YES              |
|  Monitoring (queue depth, processing time)  | YES              |
|  Circuit breaker on downstream dependencies | RECOMMENDED      |
|  Job scheduling for recurring tasks         | IF APPLICABLE    |
+--------------------------------------------------------------+

VERDICT: ALL required criteria must PASS. Any FAIL → fix before commit.
```

## Error Recovery

```
ERROR RECOVERY — QUEUE:
1. Jobs stuck in active state (not completing):
   → Check worker logs for unhandled errors. Verify job timeout is set (stalledInterval). Implement stalled job recovery. Check if downstream dependency is down.
2. DLQ growing (jobs failing after max retries):
   → Inspect DLQ messages for common error patterns. Fix root cause (schema change, dependency down, permissions). Replay DLQ after fix. Do not replay without fixing.
3. Memory exhaustion in worker:
   → Check for memory leaks in job handler (unclosed connections, growing arrays). Limit concurrency. Add memory monitoring. Restart workers periodically if leak cannot be fixed.
4. Duplicate job processing:
   → Verify idempotency key is set and checked before processing. Check if job ID is unique. Add deduplication table/cache with TTL matching job retention.
5. Queue backlog growing (consumers falling behind):
   → Scale worker concurrency or add worker instances. Check if job processing time has increased (dependency slowdown). Add backpressure to producers if needed.
6. Connection to broker lost:
   → Implement automatic reconnection with backoff. Use connection pooling. Add health check endpoint that verifies broker connectivity. Alert on connection failures.
```

## Keep/Discard Discipline
```
After EACH queue configuration change:
  1. MEASURE: Check queue depth trend, processing rate, error rate, P95 latency.
  2. COMPARE: Is queue depth stable or decreasing? Is error rate below threshold?
  3. DECIDE:
     - KEEP if queue depth stable AND error rate < 1% AND P95 latency < target AND DLQ not growing.
     - DISCARD if queue depth growing OR error rate spiked OR DLQ growing after change.
  4. COMMIT kept changes. Revert discarded changes before the next tuning pass.

Never keep a concurrency change without observing metrics for at least 5 minutes under load.
Never keep a retry strategy without exponential backoff and jitter.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All long tasks (>500ms) in queues AND retry with backoff AND DLQ configured AND idempotent handlers
  - Queue depth stable AND error rate < 1% AND graceful shutdown implemented AND monitoring active
  - User explicitly requests stop
  - Max iterations (4) reached
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run queue tasks sequentially: queue design, then worker implementation, then monitoring.
- Use branch isolation per task: `git checkout -b godmode-queue-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
