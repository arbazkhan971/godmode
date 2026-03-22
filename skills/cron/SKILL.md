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
|---|---|---|---|---|---|
| node-cron        | Node.js     | In-proc  | No         | None      | Minimal  |
|                  | Simple cron | (memory) | (single)   | (restart  |          |
|                  | schedules   |          |            | loses)    |          |
|                  |             |          |            |           |          |
| BullMQ           | Node.js     | Redis    | Yes        | Redis     | Low      |
| (repeatable)     | Production  |          | (leader    | (survives |          |
|                  | recurring   |          | election)  | restart)  |          |
|                  |             |          |            |           |          |
  Cloud-native, no servers to manage?          -> EventBridge / Cloud Scheduler
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

#### Sidekiq-Cron (Ruby)
```ruby
# config/initializers/sidekiq_cron.rb
Sidekiq::Cron::Job.load_from_hash(
  'daily_digest' => {
    'cron'  => '0 9 * * *',
    'class' => 'DailyDigestWorker',
    'queue' => 'default',
```

#### Hangfire (.NET)
```csharp
// Startup.cs
services.AddHangfire(config => config
    .SetDataCompatibilityLevel(CompatibilityLevel.Version_180)
    .UseSimpleAssemblyNameTypeSerializer()
    .UseRecommendedSerializerSettings()
    .UseSqlServerStorage(connectionString, new SqlServerStorageOptions
    {
        CommandBatchMaxTimeout = TimeSpan.FromMinutes(5),
        SlidingInvisibilityTimeout = TimeSpan.FromMinutes(5),
        QueuePollInterval = TimeSpan.FromSeconds(15),
        UseRecommendedIsolationLevel = true,
    })
);
services.AddHangfireServer();

```

#### Quartz (Java)
```java
// QuartzConfig.java
@Configuration
public class QuartzConfig {

    @Bean
    public JobDetail dailyDigestJob() {
```

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
  - Schedule window (e.g., "2025-03-15T09:00Z") is stable
  - Use: `{job-name}:{schedule-window}` as the key
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
|  Method              | Backend  | Pros            | Cons  |
|  Redis SETNX + EX    | Redis    | Fast, simple    | Not   |
|                      |          | atomic acquire   | CP    |
|                      |          |                  |       |
|  Redlock             | Redis    | Multi-node       | Cont- |
|                      |          |                  |       |
|                      |          |                  |       |
  - Enterprise / Kafka ecosystem                         -> ZooKeeper
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
5. **UTC for system jobs, always.** Never schedule system jobs in a local timezone. DST transitions will skip or double-fire your jobs. Use UTC, convert for display.
6. **Monitor schedule adherence, not just job success.** A job that succeeds but runs 3 hours late is still a failure. Track last-run-at and alert on missed windows.
7. **Dead letter every exhausted retry.** Scheduled jobs that fail all retries must go to a DLQ with full context. Do not silently drop them — they represent missed business operations.
8. **Separate scheduler from executor.** The process that decides "it is time to run" should not be the process that does the work. Scheduler enqueues; workers execute. This allows independent scaling.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full scheduled task design workflow |
| `--tech <name>` | Target specific scheduler (bullmq, celery, sidekiq, apscheduler, hangfire, quartz, node-cron) |
| `--diagnose` | Diagnose missed or failing scheduled jobs |

## HARD RULES

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
1	daily_report	0 6 * * *	bullmq	redis_lock	yes	max_instances:1	yes	configured
2	hourly_sync	0 * * * *	bullmq	redis_lock	yes	skip_if_running	yes	configured
3	weekly_cleanup	0 3 * * 0	bullmq	redis_lock	yes	max_instances:1	yes	configured
```

## Success Criteria
- All jobs use a proper scheduler library (not `setInterval`/`setTimeout`).
- All schedules defined in UTC (no local timezone, no fixed offsets).
- Distributed locking configured for multi-instance deployments.
- All job handlers are idempotent (safe to re-run).
- Overlap protection configured (skip or queue, never stack).
- Job monitoring with success/failure alerting.
- Startup registry check verifies all jobs are registered.
- Schedule definitions auditable (logged on startup, versioned in code).

## Keep/Discard Discipline
```
After EACH cron job configuration change:
  1. MEASURE: Run the job in test mode — does it complete without error?
  2. COMPARE: Is the job safer than before? (locking added, idempotency verified, overlap guarded)
  3. DECIDE:
     - KEEP if: job runs successfully AND locking works AND no duplicate execution
     - DISCARD if: job fails OR locking does not prevent duplicates OR overlap guard breaks
  4. COMMIT kept changes. Revert discarded changes before configuring the next job.
```

## Stuck Recovery
```
IF >3 consecutive iterations fail to correctly configure a job:
  1. Re-read the job handler code — the issue may be in the handler, not the scheduler config.
  2. Simplify: remove all safeguards, verify the job runs at all, then add safeguards back one at a time.
  3. Check infrastructure: is Redis reachable? Is the database connection pool large enough for scheduled jobs?
  4. If still stuck → log stop_reason=stuck, skip this job, move to the next one. Return to it after all others are configured.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All detected jobs have proper scheduling, locking, idempotency, and monitoring
  - User explicitly requests stop
  - Max iterations (15) reached — report partial results with unconfigured jobs listed

DO NOT STOP just because:
  - One job is complex (still configure the simpler ones)
  - Monitoring is not yet configured (handle that in a separate pass)
```

## Simplicity Criterion
```
PREFER the simpler scheduling approach:
  - node-cron for single-instance, in-process jobs before BullMQ for distributed scheduling
  - Database advisory locks before Redis Redlock for distributed locking
  - skip-if-running before max_instances for overlap protection
  - Hardcoded schedule in code before dynamic schedule from database (unless user needs runtime changes)
  - Fewer jobs with broader scope over many narrow-scope jobs (e.g., one cleanup job vs five)
```


## Error Recovery
| Failure | Action |
|---------|--------|
| Job runs twice (no lock) | Add file-based lock or advisory lock. Check if cron expression fires more frequently than job duration. |
| Job silently fails | Add exit code checking, stderr capture, and alerting. Log start/end with duration. |
| Timezone confusion | Always use UTC in cron expressions. Convert display times to UTC. Document timezone in comments. |
| Job overlaps with next scheduled run | Add `skip-if-running` guard. Set `concurrencyPolicy: Forbid` in K8s CronJobs. Increase interval or optimize job. |

## Output Format
Print: `Cron: {N} jobs configured. Schedule: {expressions}. Lock: {present|missing}. Alert: {active|none}. Status: {DONE|PARTIAL}.`

## TSV Logging
Append to `.godmode/cron-results.tsv`:
```
timestamp	job_name	schedule	lock_type	alert_configured	timeout_s	status
```
One row per cron job configured. Never overwrite previous rows.
