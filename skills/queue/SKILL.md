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

// Add jobs with priority
await emailQueue.add('send-welcome', { userId: '123', email: 'user@example.com' }, {
  priority: 1,   // 1 = highest priority
  delay: 0,      // Process immediately
});

await emailQueue.add('send-digest', { userId: '123' }, {
  priority: 10,  // Lower priority
  delay: 3600000, // Delay 1 hour
});

// Scheduled/recurring jobs
await emailQueue.add('daily-digest', {}, {
  repeat: { pattern: '0 9 * * *' }, // Every day at 9 AM
});
```

#### Kafka Architecture (Event Streaming)
```
KAFKA TOPOLOGY:
┌──────────────────────────────────────────────────────────┐
│  Topic: order-events                                      │
│  Partitions: 6 (keyed by order_id for ordering)           │
│  Replication: 3 (min ISR: 2)                              │
│  Retention: 7 days                                        │
│  Compaction: disabled (event log, not state)               │
│                                                           │
│  Producers:                                               │
│    Order Service → order.created, order.updated,           │
│                    order.cancelled, order.completed         │
│                                                           │
│  Consumer Groups:                                         │
│    payment-service (6 consumers, 1 per partition)          │
│    inventory-service (3 consumers, 2 partitions each)      │
│    analytics-service (1 consumer, all partitions)          │
│    notification-service (2 consumers, 3 partitions each)   │
└──────────────────────────────────────────────────────────┘
```

#### Celery Architecture (Python)
```python
from celery import Celery
from celery.schedules import crontab

app = Celery('tasks', broker='redis://localhost:6379/0', backend='redis://localhost:6379/1')

app.conf.update(
    task_serializer='json',
    accept_content=['json'],
    result_serializer='json',
    timezone='UTC',
    task_acks_late=True,                # Ack after completion (at-least-once)
    worker_prefetch_multiplier=1,       # One task at a time per worker
    task_reject_on_worker_lost=True,    # Requeue if worker crashes
    task_default_retry_delay=60,        # 60s default retry delay
    task_max_retries=5,
    task_routes={
        'tasks.send_email': {'queue': 'high-priority'},
        'tasks.generate_report': {'queue': 'bulk'},
        'tasks.process_image': {'queue': 'default'},
    },
)

# Scheduled tasks (celery beat)
app.conf.beat_schedule = {
    'cleanup-expired-sessions': {
        'task': 'tasks.cleanup_sessions',
        'schedule': crontab(minute=0, hour='*/6'),  # Every 6 hours
    },
    'daily-digest': {
        'task': 'tasks.send_daily_digest',
        'schedule': crontab(minute=0, hour=9),  # 9 AM daily
    },
}
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
DEAD LETTER QUEUE (DLQ):
┌──────────────────────────────────────────────────────────┐
│  DLQ Configuration                                        │
│  ─────────────────────────────────────────────────────── │
│  Queue name:     <original-queue>-dlq                     │
│  Retention:      30 days                                  │
│  Max size:       100,000 messages                         │
│  Alert:          When DLQ depth > 100                     │
│  Review cadence: Daily automated report                   │
│                                                           │
│  DLQ Message Format:                                      │
│  {                                                        │
│    "original_queue": "email",                             │
│    "job_id": "job-uuid-123",                              │
│    "job_name": "send-welcome",                            │
│    "payload": { ... },                                    │
│    "attempts": 5,                                         │
│    "first_failed_at": "2025-03-15T10:30:00Z",            │
│    "last_failed_at": "2025-03-15T10:35:16Z",             │
│    "errors": [                                            │
│      { "attempt": 1, "error": "ECONNREFUSED", "at": ..},│
│      { "attempt": 2, "error": "ECONNREFUSED", "at": ..},│
│      { "attempt": 3, "error": "ETIMEDOUT", "at": ..},   │
│      { "attempt": 4, "error": "ETIMEDOUT", "at": ..},   │
│      { "attempt": 5, "error": "ETIMEDOUT", "at": ..}    │
│    ]                                                      │
│  }                                                        │
│                                                           │
│  DLQ Processing Options:                                  │
│    1. Replay: Re-enqueue to original queue                │
│    2. Replay with fix: Modify payload, re-enqueue         │
│    3. Skip: Mark as acknowledged (will not process)       │
│    4. Escalate: Create incident ticket                    │
└──────────────────────────────────────────────────────────┘
```

#### Retry Implementation (BullMQ)
```typescript
// Worker with retry-aware error handling
const worker = new Worker('email', async (job) => {
  try {
    const result = await sendEmail(job.data);
    return result;
  } catch (error) {
    // Classify error as retryable or not
    if (isNonRetryable(error)) {
      // Move directly to DLQ — do not retry
      await deadLetterQueue.add('failed-email', {
        originalJob: job.data,
        jobId: job.id,
        error: error.message,
        attempts: job.attemptsMade,
      });
      return; // Do not throw — prevents retry
    }
    // Retryable error — throw to trigger BullMQ retry
    throw error;
  }
}, {
  connection,
  concurrency: 10,
  limiter: {
    max: 100,    // Max 100 jobs
    duration: 1000, // Per second (rate limit: 100/sec)
  },
});

function isNonRetryable(error: Error): boolean {
  const nonRetryableCodes = ['VALIDATION_ERROR', 'AUTH_FAILED', 'NOT_FOUND'];
  return nonRetryableCodes.includes((error as any).code)
    || (error as any).statusCode >= 400 && (error as any).statusCode < 500;
}
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

#### Idempotency Implementation
```typescript
// Idempotency key pattern for exactly-once semantics
class IdempotentJobProcessor {
  constructor(private redis: Redis, private ttl: number = 86400) {}

  async process(jobId: string, handler: () => Promise<any>): Promise<any> {
    const idempotencyKey = `idempotent:${jobId}`;

    // Check if already processed
    const existing = await this.redis.get(idempotencyKey);
    if (existing) {
      return JSON.parse(existing); // Return cached result
    }

    // Acquire lock to prevent concurrent processing
    const lock = await this.redis.set(
      `lock:${idempotencyKey}`, '1', 'EX', 300, 'NX'
    );
    if (!lock) {
      throw new Error('Job is being processed by another worker');
    }

    try {
      const result = await handler();

      // Store result with TTL for deduplication window
      await this.redis.set(idempotencyKey, JSON.stringify(result), 'EX', this.ttl);

      return result;
    } finally {
      await this.redis.del(`lock:${idempotencyKey}`);
    }
  }
}

// Usage in worker
const idempotent = new IdempotentJobProcessor(redis);

const worker = new Worker('payments', async (job) => {
  return idempotent.process(job.id!, async () => {
    // This handler runs at most once per job ID
    const charge = await stripe.charges.create({
      amount: job.data.amount,
      currency: job.data.currency,
      customer: job.data.customerId,
      idempotency_key: job.id, // Stripe-level idempotency too
    });
    await db.orders.update(job.data.orderId, { paymentId: charge.id, status: 'paid' });
    return { chargeId: charge.id };
  });
}, { connection });
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
```typescript
// Graceful shutdown for workers
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully...');

  // Stop accepting new jobs
  await worker.pause();

  // Wait for current jobs to complete (with timeout)
  const shutdownTimeout = setTimeout(() => {
    console.error('Graceful shutdown timed out, forcing exit');
    process.exit(1);
  }, 30000);

  await worker.close();
  clearTimeout(shutdownTimeout);

  console.log('Worker shut down gracefully');
  process.exit(0);
});
```

#### Circuit Breaker for Downstream Dependencies
```typescript
class CircuitBreaker {
  private failures = 0;
  private lastFailureTime = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';

  constructor(
    private threshold: number = 5,
    private resetTimeout: number = 30000,
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailureTime > this.resetTimeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open — downstream unavailable');
      }
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  private onSuccess() {
    this.failures = 0;
    this.state = 'closed';
  }

  private onFailure() {
    this.failures++;
    this.lastFailureTime = Date.now();
    if (this.failures >= this.threshold) {
      this.state = 'open';
    }
  }
}
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

## Anti-Patterns

- **Do NOT process long tasks in request handlers.** Anything over 500ms belongs in a background job. Users should not stare at a loading spinner while you generate a PDF.
- **Do NOT retry without backoff.** Immediate retries hammer a failing dependency. Use exponential backoff with jitter. Always.
- **Do NOT ignore the dead letter queue.** An empty DLQ is healthy. A growing DLQ is an incident. Monitor it, alert on it, process it.
- **Do NOT assume jobs run exactly once.** At-least-once is the common guarantee. Your handler WILL be called twice for the same job during failures. Make it idempotent.
- **Do NOT share worker pools across priorities.** A 10,000-job bulk export should not block password reset emails. Use separate queues and separate workers for different priorities.
- **Do NOT store large payloads in the queue.** Queues are for metadata and references, not 50MB files. Store the file in S3/storage, put the URL in the job payload.
- **Do NOT skip graceful shutdown.** Killing a worker mid-job corrupts state and causes double-processing. Handle SIGTERM, finish current work, then exit.
- **Do NOT use polling intervals shorter than your processing time.** If jobs take 5 seconds to process, polling every 100ms wastes CPU. Match polling to workload characteristics.
