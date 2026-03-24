---
name: cron
description: Scheduled tasks, cron jobs, background job queues, recurring work. Use when user mentions cron, scheduler, background jobs, recurring tasks, Bull, BullMQ, Celery, Sidekiq, node-cron, APScheduler.
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

1. **Cron is not fire-and-forget.** Monitor every scheduled job for missed runs, failures, and duration anomalies. A job that silently stops running is worse than a job that loudly fails.
2. **Idempotency is mandatory.** Schedulers fire duplicate runs during restarts, leader failovers, and clock skew. Every handler must produce the same result when called twice for the same schedule window.
3. **Distributed locking is required in production.** If you run more than one instance of your application, you need a distributed lock to prevent duplicate job fires. No exceptions.
4. **Overlap protection is not optional.** A job that runs every 5 minutes but takes 7 minutes will overlap and compound. Use `max_instances: 1`, `coalesce: true`, or a lock that spans the execution.
## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full scheduled task design workflow |
| `--tech <name>` | Target specific scheduler (bullmq, celery, sidekiq, apscheduler, hangfire, quartz, node-cron) |
| `--diagnose` | Diagnose missed or failing scheduled jobs |

## HARD RULES

Never ask to continue. Loop autonomously until all jobs have locking, idempotency, and monitoring.

1. **NEVER use `setInterval` or `setTimeout` for production scheduling.** They do not survive restarts, have no distributed locking, no monitoring, and drift over time.
2. **NEVER schedule jobs in local timezones.** DST transitions skip the 2 AM job in March and double-fire the 1 AM job in November. Use UTC for all system schedules.
3. **NEVER assume single-instance execution.** If the app runs on 2+ instances, every cron job fires N times without distributed locking. Add locking from day one.
4. **ALWAYS make every scheduled handler idempotent.** Schedulers fire duplicates during restarts, failovers, and Redis reconnections.
5. **ALWAYS guard against overlap.** A job that runs every hour but takes 90 minutes will stack up and OOM the system. Use locks or `max_instances`.
6. **NEVER put heavy work in the scheduler tick.** The scheduler should enqueue a job, not execute it. Blocking the scheduler loop delays all other schedules.
7. **ALWAYS verify registered job count on startup.** If registration fails silently, jobs stop running with no alert.
8. **ALWAYS use IANA timezone names** (America/New_York), never fixed offsets (UTC-5). Fixed offsets are wrong for half the year.

## Auto-Detection

On activation, detect the scheduling context:

```bash
# Detect scheduler libraries
grep -r "bullmq\|bull\|agenda\|node-cron\|bree\|croner" package.json 2>/dev/null
grep -r "celery\|apscheduler\|django-cron\|huey" requirements.txt setup.py pyproject.toml 2>/dev/null
grep -r "sidekiq\|sidekiq-cron\|whenever\|clockwork" Gemfile 2>/dev/null

# Detect existing cron jobs
```
iteration	job_name	schedule	scheduler	locking	idempotent	overlap_guard	monitoring	status
## Success Criteria
- All jobs use a proper scheduler library (not `setInterval`/`setTimeout`).
- All schedules defined in UTC (no local timezone, no fixed offsets).
- Distributed locking configured for multi-instance deployments.
- All job handlers are idempotent (safe to re-run).
- Overlap protection configured (skip or queue, never stack).
- Job monitoring with success/failure alerting.
  ...
```
After EACH cron job configuration change:
  1. MEASURE: Run the job in test mode — does it complete without error?
## Stop Conditions
```
STOP when ANY of these are true:
  - All detected jobs have proper scheduling, locking, idempotency, and monitoring
  - User explicitly requests stop
  - Max iterations (15) reached — report partial results with unconfigured jobs listed

DO NOT STOP only because:
  - One job is complex (still configure the simpler ones)
  - Monitoring is not yet configured (handle that in a separate pass)

On failure: revert the last cron configuration change with `git reset --hard HEAD~1` and retry with a narrower scope.
```

## Error Recovery
| Failure | Action |
|--|--|
| Job runs twice (no lock) | Add file-based lock or advisory lock. Check if cron expression fires more frequently than job duration. |
| Job silently fails | Add exit code checking, stderr capture, and alerting. Log start/end with duration. |
| Timezone confusion | Always use UTC in cron expressions. Convert display times to UTC. Document timezone in comments. |
| Job overlaps with next scheduled run | Add `skip-if-running` guard. Set `concurrencyPolicy: Forbid` in K8s CronJobs. Increase interval or optimize job. |
  ...
```
