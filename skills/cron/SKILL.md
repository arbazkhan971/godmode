---
name: cron
description: Scheduled tasks, cron jobs, background job queues, recurring work. Use when user mentions cron,
  scheduler, background jobs, recurring tasks, Bull, BullMQ, Celery, Sidekiq, node-cron, APScheduler.
---

# Cron — Scheduled Tasks & Recurring Job Orchestration

## When to Activate
- User invokes `/godmode:cron`
- User says "schedule a job", "cron job", "recurring task", "run every hour"
- User says "background scheduler", "periodic task", "timed execution"
- User says "node-cron", "BullMQ repeat", "Celery beat", "Sidekiq-cron", "APScheduler", "Hangfire", "Quartz"
- User needs a task to fire on a schedule (daily reports, cleanup, syncs, heartbeats)
- User asks about cron syntax, timezone handling, or overlap protection
- User needs distributed scheduling across multiple instances
- User needs rate-limited or priority-aware recurring execution
- Godmode orchestrator detects hardcoded `setInterval` or `setTimeout` loops that need conversion to proper scheduled jobs

## Workflow

### Step 1: Scheduling Requirements Assessment

Evaluate what needs to run, how often, and under what constraints:

```
SCHEDULING REQUIREMENTS ASSESSMENT:
|  Dimension            | Value                             |
|  Task type            | <cleanup | report | sync | alert |
|                       |  billing | digest | health check> |
|  Frequency            | <seconds | minutes | hourly |     |
```
#### Cron Expression Quick Reference
```
CRON EXPRESSION SYNTAX:
|  Field        | Values          | Special chars           |
|  Minute       | 0-59            | * , - /                 |
|  Hour         | 0-23            | * , - /                 |
|  Day of month | 1-31            | * , - / ? L W           |

Common patterns:
    and 7 = Sunday) — check your library
```

#### Scheduler Technology Selection Matrix
```
SCHEDULER TECHNOLOGY SELECTION:
| Technology       | Language    | Backend  | Distributed| Persistence| Ops cost |
|--|--|--|--|--|--|
| node-cron        | Node.js     | In-proc  | No         | None      | Minimal  |
|                  | Simple cron | (memory) | (single)   | (restart  |          |
|                  | schedules   |          |            | loses)    |          |
|                  |             |          |            |           |          |
| BullMQ           | Node.js     | Redis    | Yes        | Redis     | Low      |
  ...
```

### Step 2: Schedule Architecture Design

Design the scheduling topology, job registry, and execution flow:

```
SCHEDULE ARCHITECTURE:
|  Scheduler              Job Registry               Executors           |
|  ---------              ------------               ---------           |
|                     +-- daily-digest -------------- Worker Pool A (2)  |
|  Cron Engine ------+-- cleanup-expired ----------- Worker Pool B (3)  |
```
#### BullMQ Repeatable Jobs (Node.js — Production)
```typescript
import { Queue, Worker, QueueEvents } from 'bullmq';
import Redis from 'ioredis';

const connection = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
```

#### Celery Beat (Python — Production)
```python
from celery import Celery
from celery.schedules import crontab, solar
from datetime import timedelta

app = Celery('scheduler', broker='redis://localhost:6379/0', backend='redis://localhost:6379/1')

```

#### APScheduler (Python — Standalone)
```python
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.jobstores.redis import RedisJobStore
from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
from apscheduler.triggers.cron import CronTrigger
import pytz

```

**Sidekiq-Cron (Ruby):** `Sidekiq::Cron::Job.load_from_hash` with cron expression, class, and queue.
**Hangfire (.NET):** `RecurringJob.AddOrUpdate` with cron expression, SQL Server or Redis storage.
**Quartz (Java):** `@Configuration` with `JobDetail` bean and `CronTrigger` schedule.

### Step 3: Idempotency for Retries

Every scheduled job MUST safely run more than once for the same logical execution window:

```
IDEMPOTENCY STRATEGIES FOR SCHEDULED JOBS:
|  Strategy             | Use case                          |
|  Date-based key       | "digest:2025-03-15" — one per day |
|  Window-based key     | "sync:2025-03-15T10:00Z" — one   |
|                       | per 15-min window                 |

Principle: derive the idempotency key from the SCHEDULE, not the job ID.
  - The system re-creates the job on restart with a new ID
  ...
```
#### Idempotent Scheduled Job Implementation
```typescript
// Idempotent wrapper for scheduled jobs
class ScheduledJobRunner {
  constructor(private redis: Redis) {}

  async runOnce(
    jobName: string,
```

### Step 4: Distributed Job Locking

Prevent multiple scheduler instances from firing the same job simultaneously:

```
DISTRIBUTED LOCKING STRATEGIES:
| Method            | Backend | Pros                | Cons             |
| Redis SETNX + EX  | Redis   | Fast, atomic acquire | Not CP-safe      |
| Redlock           | Redis   | Multi-node consensus | Controversial    |
| DB advisory lock  | Postgres| No extra infra       | DB-coupled       |
| ZooKeeper/etcd    | ZK/etcd | CP-safe, reliable    | Ops overhead     |
```
#### Redis Distributed Lock
```typescript
class DistributedSchedulerLock {
  constructor(private redis: Redis) {}

  async acquireLeader(schedulerId: string, ttl: number = 30): Promise<boolean> {
    // Only one scheduler instance becomes leader
    const acquired = await this.redis.set(
```

#### PostgreSQL Advisory Lock
```python
import hashlib

def pg_advisory_lock_for_job(conn, job_name: str) -> bool:
    """Acquire a PostgreSQL advisory lock for a scheduled job.
    Returns True if lock acquired, False if another process holds it."""
    # Convert job name to a stable int64 for PG advisory lock
```

### Step 5: Job Monitoring & Alerting

Track schedule health and detect missed or failing runs:

```
CRON JOB MONITORING:
|  Metric                    | Current | Alert    | Status |
|  Jobs scheduled            | 8       | —        | OK     |
|  Last run: daily-digest    | 09:00   | miss > 1h| OK     |
|  Last run: cleanup         | 06:00   | miss > 7h| OK     |
```
#### Monitoring Implementation
```typescript
// Scheduled job health monitor
class CronJobMonitor {
  constructor(private redis: Redis, private alerter: Alerter) {}

  async recordRun(jobName: string, result: {
    status: 'success' | 'failure';
```

### Step 6: Dead Letter Handling for Scheduled Jobs

Handle scheduled jobs that exhaust retries:

```
SCHEDULED JOB DLQ DESIGN:
|  DLQ for Scheduled Jobs                                   |
|  Queue:       scheduled-jobs-dlq                          |
|  Retention:   30 days                                     |
|  Alert:       Any entry (scheduled jobs should not fail)  |
```
### Step 7: Priority Queues & Job Chaining

Design priority-aware scheduling and dependent job pipelines:

```
SCHEDULED JOB PRIORITIES:
|  Priority | Schedule         | Job               | SLA    |
|  P0       | */5 * * * *      | Health check       | < 30s  |
|  P1       | */15 * * * *     | Inventory sync     | < 2m   |
|  P1       | 0 9 * * *        | Daily digest       | < 5m   |

JOB CHAINING (dependent execution):
|  Pipeline: "end-of-day"                                   |
```
#### Job Chaining Implementation
```typescript
// BullMQ Flow (parent-child dependencies)
import { FlowProducer } from 'bullmq';

const flowProducer = new FlowProducer({ connection });

// End-of-day pipeline — child jobs run first, parent last
```

### Step 8: Rate-Limited Execution

Prevent scheduled jobs from overwhelming downstream services:

```
RATE-LIMITED SCHEDULING:
|  Scenario                | Strategy                       |
|  API with 100 req/min    | Token bucket limiter on worker |
|  Email provider 500/hr   | BullMQ limiter: 500 per 3600s |
|  DB batch writes         | Chunk + delay between batches  |
```
#### Rate-Limited Scheduled Job
```typescript
// Scheduled job that processes in rate-limited batches
async function runDailyDigest() {
  const users = await db.users.findMany({
    where: { digestEnabled: true, lastDigestBefore: today() },
  });

```

### Step 9: Timezone Handling

Handle timezone-aware scheduling correctly:

```
TIMEZONE HANDLING:
|  Rule                                                     |
|  1. Store all schedules in UTC internally                 |
|  2. Convert to user timezone for display only             |
|  3. Use IANA timezone names (America/New_York), never     |
```
### Step 10: Database-Backed vs Redis-Backed Schedulers

Choose the right persistence layer:

```
SCHEDULER PERSISTENCE COMPARISON:
|  Aspect              | Redis-backed      | DB-backed      |
|  Speed               | Sub-ms operations | 1-10ms queries |
|  Durability          | RDB/AOF (config)  | Full ACID      |
|  Crash recovery      | May lose last      | No data loss   |

Use Redis-backed (BullMQ, Sidekiq-Cron) when:
  - Need complex queries on job history
```
### Step 11: Commit and Transition

```
1. Save schedule configuration as `config/schedules/registry.ts`
2. Save scheduler setup as `config/schedules/scheduler.ts`
3. Save idempotency helpers as `lib/scheduled-job-runner.ts`
4. Save monitoring as `lib/cron-monitor.ts`
5. Commit: "cron: <scheduler> — <N> jobs, <frequency range>, <lock strategy>"
6. If new scheduler: "Scheduled jobs configured. <N> jobs registered. Deploy and monitor."
7. If fixing failures: "Idempotency and locking added. Missed-schedule alerting enabled."
8. If migrating: "Migrated from <old> to <new>. All schedules verified."
```
## Key Behaviors

Never ask to continue. Loop autonomously until done.

```bash
# Validate cron expressions and test jobs
npx cron-validate "0 9 * * 1-5"
npm run test:cron -- --timeout 30000
redis-cli KEYS "bull:*:repeat:*" | head -10
```
IF job duration > 80% of interval: increase interval or optimize job.
WHEN missed runs > 0 in 24h: alert and investigate.
IF retry count > 3: move to dead letter queue.
1. **Monitor every scheduled job.** Missed runs, failures, duration.
2. **Idempotency mandatory.** Same result if called twice.
3. **Distributed locking in production.** No duplicate fires.
4. **Overlap protection.** Use max_instances: 1 or coalesce.
On failure: revert with git reset --hard HEAD~1.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full scheduled task design workflow |
| `--tech <name>` | Target specific scheduler (bullmq, celery, sidekiq, apscheduler, hangfire, quartz, node-cron) |
| `--diagnose` | Diagnose missed or failing scheduled jobs |

## Quality Targets
- Job success rate: >99% over 30 days
- Runtime per job: <80% of schedule interval
- Alert after: >3 consecutive failures


## Keep/Discard
KEEP if: improvement verified. DISCARD if: regression or no change. Revert discards immediately.

## Stop Conditions
Stop when: target reached, budget exhausted, or >5 consecutive discards.

