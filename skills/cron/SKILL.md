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
- Godmode orchestrator detects hardcoded `setInterval` or `setTimeout` loops that should be proper scheduled jobs

## Workflow

### Step 1: Scheduling Requirements Assessment

Evaluate what needs to run, how often, and under what constraints:

```
SCHEDULING REQUIREMENTS ASSESSMENT:
+---------------------------------------------------------+
|  Dimension            | Value                             |
|  ------------------------------------------------------- |
|  Task type            | <cleanup | report | sync | alert |
|                       |  billing | digest | health check> |
|  Frequency            | <seconds | minutes | hourly |     |
|                       |  daily | weekly | monthly | cron> |
|  Cron expression      | <* * * * * | custom>              |
|  Duration per run     | << 1s | seconds | minutes | hours>|
|  Overlap allowed?     | <yes | no | skip-if-running>      |
|  Idempotent?          | <yes | must make idempotent>      |
|  Timezone             | <UTC | user-local | configurable> |
    # ... (condensed)
+---------------------------------------------------------+
```

#### Cron Expression Quick Reference
```
CRON EXPRESSION SYNTAX:
+---------------------------------------------------------+
|  Field        | Values          | Special chars           |
|  ------------------------------------------------------- |
|  Minute       | 0-59            | * , - /                 |
|  Hour         | 0-23            | * , - /                 |
|  Day of month | 1-31            | * , - / ? L W           |
|  Month        | 1-12 or JAN-DEC | * , - /                |
|  Day of week  | 0-7 or SUN-SAT | * , - / ? L #           |
|  (Second)     | 0-59 (optional) | * , - /                 |
+---------------------------------------------------------+

Common patterns:
    # ... (condensed)
    and 7 = Sunday) — check your library
```

#### Scheduler Technology Selection Matrix
```
SCHEDULER TECHNOLOGY SELECTION:
+------------------+-------------+----------+------------+-----------+----------+
| Technology       | Language    | Backend  | Distributed| Persistence| Ops cost |
+------------------+-------------+----------+------------+-----------+----------+
| node-cron        | Node.js     | In-proc  | No         | None      | Minimal  |
|                  | Simple cron | (memory) | (single)   | (restart  |          |
|                  | schedules   |          |            | loses)    |          |
|                  |             |          |            |           |          |
| BullMQ           | Node.js     | Redis    | Yes        | Redis     | Low      |
| (repeatable)     | Production  |          | (leader    | (survives |          |
|                  | recurring   |          | election)  | restart)  |          |
|                  |             |          |            |           |          |
| Agenda           | Node.js     | MongoDB  | Yes        | MongoDB   | Low      |
    # ... (condensed)
  Cloud-native, no servers to manage?          -> EventBridge / Cloud Scheduler
```

### Step 2: Schedule Architecture Design

Design the scheduling topology, job registry, and execution flow:

```
SCHEDULE ARCHITECTURE:
+----------------------------------------------------------------------+
|                                                                        |
|  Scheduler              Job Registry               Executors           |
|  ---------              ------------               ---------           |
|                                                                        |
|                     +-- daily-digest -------------- Worker Pool A (2)  |
|  Cron Engine ------+-- cleanup-expired ----------- Worker Pool B (3)  |
|  (single leader)   +-- sync-inventory ------------ Worker Pool A (2)  |
|                     +-- generate-reports ---------- Worker Pool C (1)  |
|                     +-- health-check -------------- Inline (fast)     |
|                     +-- billing-cycle ------------- Worker Pool C (1)  |
|                                                                        |
    # ... (condensed)
+----------------------------------------------------------------------+
```

#### BullMQ Repeatable Jobs (Node.js — Production)
```typescript
import { Queue, Worker, QueueEvents } from 'bullmq';
import Redis from 'ioredis';

const connection = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT || '6379'),
  maxRetriesPerRequest: null,
});

// Dedicated queue for scheduled/recurring work
const schedulerQueue = new Queue('scheduled-jobs', {
  connection,
  defaultJobOptions: {
    # ... (condensed)
});
```

#### Celery Beat (Python — Production)
```python
from celery import Celery
from celery.schedules import crontab, solar
from datetime import timedelta

app = Celery('scheduler', broker='redis://localhost:6379/0', backend='redis://localhost:6379/1')

app.conf.update(
    timezone='UTC',
    beat_schedule_filename='/var/lib/celery/beat-schedule',  # Persist schedule state
    beat_max_loop_interval=60,  # Check schedule every 60s max
    task_acks_late=True,
    worker_prefetch_multiplier=1,
    task_reject_on_worker_lost=True,
    # ... (condensed)
        raise self.retry(exc=exc)
```

#### APScheduler (Python — Standalone)
```python
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.jobstores.redis import RedisJobStore
from apscheduler.executors.pool import ThreadPoolExecutor, ProcessPoolExecutor
from apscheduler.triggers.cron import CronTrigger
import pytz

jobstores = {
    'default': RedisJobStore(host='localhost', port=6379, db=2),
}
executors = {
    'default': ThreadPoolExecutor(20),
    'cpu_bound': ProcessPoolExecutor(4),
}
    # ... (condensed)
scheduler.start()
```

#### Sidekiq-Cron (Ruby)
```ruby
# config/initializers/sidekiq_cron.rb
Sidekiq::Cron::Job.load_from_hash(
  'daily_digest' => {
    'cron'  => '0 9 * * *',
    'class' => 'DailyDigestWorker',
    'queue' => 'default',
    'description' => 'Send daily digest emails at 9 AM UTC',
  },
  'cleanup_sessions' => {
    'cron'  => '0 */6 * * *',
    'class' => 'CleanupSessionsWorker',
    'queue' => 'maintenance',
    'description' => 'Clean up expired sessions every 6 hours',
  },
  'sync_inventory' => {
    'cron'  => '*/15 * * * *',
    'class' => 'InventorySyncWorker',
    # ... (condensed)
end
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

// Register recurring jobs
RecurringJob.AddOrUpdate<IDailyDigestService>(
    "daily-digest",
    service => service.SendDigestAsync(),
    # ...
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc }
);
```

#### Quartz (Java)
```java
// QuartzConfig.java
@Configuration
public class QuartzConfig {

    @Bean
    public JobDetail dailyDigestJob() {
        return JobBuilder.newJob(DailyDigestJob.class)
            .withIdentity("daily-digest", "scheduled")
            .storeDurably()
            .requestRecovery(true)  // Re-execute on scheduler crash recovery
            .build();
    }

    @Bean
    public Trigger dailyDigestTrigger() {
        return TriggerBuilder.newTrigger()
            .forJob(dailyDigestJob())
    # ... (condensed)
// spring.quartz.properties.org.quartz.scheduler.instanceId=AUTO
```

### Step 3: Idempotency for Retries

Every scheduled job MUST be safe to run more than once for the same logical execution window:

```
IDEMPOTENCY STRATEGIES FOR SCHEDULED JOBS:
+---------------------------------------------------------+
|  Strategy             | Use case                          |
|  ------------------------------------------------------- |
|  Date-based key       | "digest:2025-03-15" — one per day |
|  Window-based key     | "sync:2025-03-15T10:00Z" — one   |
|                       | per 15-min window                 |
|  Database upsert      | INSERT ... ON CONFLICT DO NOTHING |
|  Redis SETNX          | Acquire lock with expiry          |
|  Idempotency token    | Unique key per logical run        |
|  State check          | Query current state before acting |
+---------------------------------------------------------+

Principle: derive the idempotency key from the SCHEDULE, not the job ID.
  - Job will be re-created on restart with a new ID
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
    scheduleWindow: string,
    handler: () => Promise<any>,
    ttl: number = 86400,
  ): Promise<{ status: 'executed' | 'skipped'; result?: any }> {
    const idempotencyKey = `scheduled:${jobName}:${scheduleWindow}`;

    // Check if this window was already processed
    const alreadyRan = await this.redis.get(idempotencyKey);
    if (alreadyRan) {
      return { status: 'skipped' };
    }
    # ... (condensed)
}, { connection });
```

### Step 4: Distributed Job Locking

Prevent multiple scheduler instances from firing the same job simultaneously:

```
DISTRIBUTED LOCKING STRATEGIES:
+---------------------------------------------------------+
|  Method              | Backend  | Pros            | Cons  |
|  ------------------------------------------------------- |
|  Redis SETNX + EX    | Redis    | Fast, simple    | Not   |
|                      |          | atomic acquire   | CP    |
|                      |          |                  |       |
|  Redlock             | Redis    | Multi-node       | Cont- |
|                      | (3+ nodes| consensus        | rover-|
|                      |          |                  | sial  |
|                      |          |                  |       |
|  PostgreSQL          | PG       | Strong           | Slower|
|  advisory locks      |          | consistency,     | than  |
|                      |          | no extra infra   | Redis |
|                      |          |                  |       |
|  ZooKeeper /         | ZK/etcd  | CP guarantee,    | Heavy |
|  etcd lease          |          | proven in prod   | infra |
    # ... (condensed)
  - Enterprise / Kafka ecosystem                         -> ZooKeeper
```

#### Redis Distributed Lock
```typescript
class DistributedSchedulerLock {
  constructor(private redis: Redis) {}

  async acquireLeader(schedulerId: string, ttl: number = 30): Promise<boolean> {
    // Only one scheduler instance becomes leader
    const acquired = await this.redis.set(
      'scheduler:leader',
      schedulerId,
      'EX', ttl,
      'NX'
    );
    return acquired === 'OK';
  }

  async renewLeadership(schedulerId: string, ttl: number = 30): Promise<boolean> {
    // Renew only if we are still the leader (atomic check-and-set)
    const script = `
    # ... (condensed)
}
```

#### PostgreSQL Advisory Lock
```python
import hashlib

def pg_advisory_lock_for_job(conn, job_name: str) -> bool:
    """Acquire a PostgreSQL advisory lock for a scheduled job.
    Returns True if lock acquired, False if another process holds it."""
    # Convert job name to a stable int64 for PG advisory lock
    lock_id = int(hashlib.sha256(job_name.encode()).hexdigest()[:15], 16)

    cursor = conn.cursor()
    cursor.execute("SELECT pg_try_advisory_lock(%s)", (lock_id,))
    acquired = cursor.fetchone()[0]
    return acquired

def pg_advisory_unlock(conn, job_name: str):
    lock_id = int(hashlib.sha256(job_name.encode()).hexdigest()[:15], 16)
    cursor = conn.cursor()
    cursor.execute("SELECT pg_advisory_unlock(%s)", (lock_id,))
```

### Step 5: Job Monitoring & Alerting

Track schedule health and detect missed or failing runs:

```
CRON JOB MONITORING:
+---------------------------------------------------------+
|  Metric                    | Current | Alert    | Status |
|  ------------------------------------------------------- |
|  Jobs scheduled            | 8       | —        | OK     |
|  Last run: daily-digest    | 09:00   | miss > 1h| OK     |
|  Last run: cleanup         | 06:00   | miss > 7h| OK     |
|  Last run: sync-inventory  | 10:45   | miss >20m| OK     |
|  Active runs               | 1       | > 5      | OK     |
|  Failed in last 24h        | 2       | > 10     | OK     |
|  Avg run duration          | 4.2s    | > 60s    | OK     |
|  Longest running now       | 3.1s    | > 300s   | OK     |
|  Overlap incidents (24h)   | 0       | > 0      | OK     |
|  Missed schedules (24h)    | 0       | > 0      | OK     |
+---------------------------------------------------------+

Alerting rules:
  CRITICAL: Job missed its schedule window + grace period
  CRITICAL: Job running longer than 5x its average duration
  WARNING:  Job failure rate > 10% in last hour
  WARNING:  DLQ depth for scheduled jobs > 0
  INFO:     Job completed but took 2x longer than average
```

#### Monitoring Implementation
```typescript
// Scheduled job health monitor
class CronJobMonitor {
  constructor(private redis: Redis, private alerter: Alerter) {}

  async recordRun(jobName: string, result: {
    status: 'success' | 'failure';
    duration: number;
    error?: string;
  }) {
    const key = `cron:monitor:${jobName}`;
    const now = Date.now();

    await this.redis.pipeline()
      .hset(key, 'last_run_at', now)
      .hset(key, 'last_status', result.status)
      .hset(key, 'last_duration_ms', result.duration)
      .hincrby(key, `count_${result.status}`, 1)
    # ... (condensed)
}
```

### Step 6: Dead Letter Handling for Scheduled Jobs

Handle scheduled jobs that exhaust retries:

```
SCHEDULED JOB DLQ DESIGN:
+---------------------------------------------------------+
|  DLQ for Scheduled Jobs                                   |
|  ------------------------------------------------------- |
|  Queue:       scheduled-jobs-dlq                          |
|  Retention:   30 days                                     |
|  Alert:       Any entry (scheduled jobs should not fail)  |
|  Review:      Immediate (every DLQ entry = investigation) |
|                                                           |
|  Entry format:                                            |
|  {                                                        |
|    "job_name": "daily-digest",                            |
|    "schedule": "0 9 * * *",                               |
|    "scheduled_window": "2025-03-15T09:00Z",               |
|    "attempts": 3,                                         |
|    "first_failed_at": "2025-03-15T09:00:05Z",            |
|    "last_failed_at": "2025-03-15T09:01:42Z",             |
|    "errors": [                                            |
|      { "attempt": 1, "error": "ECONNREFUSED ...", ... }, |
    # ...
|    4. Escalate to incident if SLA breached                |
+---------------------------------------------------------+
```

### Step 7: Priority Queues & Job Chaining

Design priority-aware scheduling and dependent job pipelines:

```
SCHEDULED JOB PRIORITIES:
+---------------------------------------------------------+
|  Priority | Schedule         | Job               | SLA    |
|  ------------------------------------------------------- |
|  P0       | */5 * * * *      | Health check       | < 30s  |
|  P1       | */15 * * * *     | Inventory sync     | < 2m   |
|  P1       | 0 9 * * *        | Daily digest       | < 5m   |
|  P2       | 0 */6 * * *      | Session cleanup    | < 30m  |
|  P3       | 0 2 * * 1        | Weekly report      | < 2h   |
|  P3       | 0 0 1 * *        | Monthly billing    | < 4h   |
+---------------------------------------------------------+

JOB CHAINING (dependent execution):
+---------------------------------------------------------+
|  Pipeline: "end-of-day"                                   |
|  Trigger: 0 23 * * * (11 PM UTC daily)                    |
|                                                           |
|  Step 1: aggregate-daily-stats                            |
|      |   (5 min)                                          |
    # ...
|  On failure at any step: alert, stop chain, DLQ           |
+---------------------------------------------------------+
```

#### Job Chaining Implementation
```typescript
// BullMQ Flow (parent-child dependencies)
import { FlowProducer } from 'bullmq';

const flowProducer = new FlowProducer({ connection });

// End-of-day pipeline — child jobs run first, parent last
await flowProducer.add({
  name: 'send-report-email',
  queueName: 'scheduled-jobs',
  data: { type: 'email', report: 'daily' },
  children: [
    {
      name: 'generate-daily-report',
      queueName: 'scheduled-jobs',
      data: { type: 'report', period: 'daily' },
      children: [
        {
          name: 'aggregate-daily-stats',
          queueName: 'scheduled-jobs',
    # ...
  ],
});
```

### Step 8: Rate-Limited Execution

Prevent scheduled jobs from overwhelming downstream services:

```
RATE-LIMITED SCHEDULING:
+---------------------------------------------------------+
|  Scenario                | Strategy                       |
|  ------------------------------------------------------- |
|  API with 100 req/min    | Token bucket limiter on worker |
|  Email provider 500/hr   | BullMQ limiter: 500 per 3600s |
|  DB batch writes         | Chunk + delay between batches  |
|  External webhook        | Concurrency 1 + delay between  |
|  Multiple tenants        | Per-tenant rate limit keys     |
+---------------------------------------------------------+
```

#### Rate-Limited Scheduled Job
```typescript
// Scheduled job that processes in rate-limited batches
async function runDailyDigest() {
  const users = await db.users.findMany({
    where: { digestEnabled: true, lastDigestBefore: today() },
  });

  // Enqueue individual emails with rate limiting
  for (const user of users) {
    await emailQueue.add('send-digest-email', {
      userId: user.id,
      date: today(),
    }, {
      priority: 5,
      // BullMQ handles rate limiting at the worker level
    });
  }

  return { queued: users.length };
}
    # ...
  },
});
```

### Step 9: Timezone Handling

Handle timezone-aware scheduling correctly:

```
TIMEZONE HANDLING:
+---------------------------------------------------------+
|  Rule                                                     |
|  ------------------------------------------------------- |
|  1. Store all schedules in UTC internally                 |
|  2. Convert to user timezone for display only             |
|  3. Use IANA timezone names (America/New_York), never     |
|     fixed offsets (UTC-5) — offsets break with DST        |
|  4. Test with DST transitions:                            |
|     - "Spring forward": 2 AM -> 3 AM (1 AM runs, 2 AM   |
|       does not exist)                                     |
|     - "Fall back": 2 AM -> 1 AM (1 AM runs twice!)       |
|  5. For user-facing schedules, convert at fire time:      |
|     "9 AM user-local" = different UTC per user per day    |
|  6. For system jobs, always use UTC — no DST surprises    |
+---------------------------------------------------------+

BullMQ timezone support:
  repeat: { pattern: '0 9 * * *', tz: 'America/New_York' }
    # ...
Quartz timezone support:
  .inTimeZone(TimeZone.getTimeZone("America/New_York"))
```

### Step 10: Database-Backed vs Redis-Backed Schedulers

Choose the right persistence layer:

```
SCHEDULER PERSISTENCE COMPARISON:
+---------------------------------------------------------+
|  Aspect              | Redis-backed      | DB-backed      |
|  ------------------------------------------------------- |
|  Speed               | Sub-ms operations | 1-10ms queries |
|  Durability          | RDB/AOF (config)  | Full ACID      |
|  Crash recovery      | May lose last      | No data loss   |
|                      | few seconds        |                |
|  Schedule history    | Manual (lists)     | Native (rows)  |
|  Query flexibility   | Limited            | Full SQL       |
|  Clustering          | Redis Cluster      | DB replication |
|  Ops complexity      | Moderate (Redis)   | Low (existing) |
|  Best for            | High-frequency     | Audit trail,   |
|                      | jobs, low latency  | compliance     |
+---------------------------------------------------------+

Use Redis-backed (BullMQ, Sidekiq-Cron) when:
    # ... (condensed)
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

1. **Cron is not fire-and-forget.** Every scheduled job must be monitored for missed runs, failures, and duration anomalies. A job that silently stops running is worse than a job that loudly fails.
2. **Idempotency is mandatory.** Schedulers fire duplicate runs during restarts, leader failovers, and clock skew. Every handler must produce the same result when called twice for the same schedule window.
3. **Distributed locking is required in production.** If you run more than one instance of your application, you need a distributed lock to prevent duplicate job fires. No exceptions.
4. **Overlap protection is not optional.** A job that runs every 5 minutes but takes 7 minutes will overlap and compound. Use `max_instances: 1`, `coalesce: true`, or a lock that spans the execution.
5. **UTC for system jobs, always.** Never schedule system jobs in a local timezone. DST transitions will skip or double-fire your jobs. Use UTC, convert for display.
6. **Monitor schedule adherence, not just job success.** A job that succeeds but runs 3 hours late is still a failure. Track last-run-at and alert on missed windows.
7. **Dead letter every exhausted retry.** Scheduled jobs that fail all retries must go to a DLQ with full context. Do not silently drop them — they represent missed business operations.
8. **Separate scheduler from executor.** The process that decides "it is time to run" should not be the process that does the work. Scheduler enqueues; workers execute. This allows independent scaling.

## Example Usage

### Setting up scheduled tasks
```
User: /godmode:cron Set up daily report generation and hourly data sync for our Node.js app

Cron: Assessing scheduling requirements...

SCHEDULING REQUIREMENTS:
  Tasks: 2 (report generation, data sync)
  Frequencies: daily (report), hourly (sync)
  Duration: report ~10min, sync ~30s
  Infra: Redis available
  Constraint: 3 app instances — need distributed locking

Recommendation: BullMQ repeatable jobs
  Rationale: Node.js native, Redis already available, built-in
  distributed locking, dashboard via Bull Board.

Scheduled jobs registered:
```

### Debugging missed scheduled jobs
```
User: /godmode:cron --diagnose Our daily digest stopped running 3 days ago

Cron: Diagnosing scheduled job health...

SCHEDULE HEALTH CHECK:
  Job: daily-digest
  Schedule: 0 9 * * * (9 AM UTC daily)
  Last successful run: 3 days ago (2025-03-12T09:00:05Z)
  Last attempted run: 2 days ago (2025-03-13T09:00:02Z) — FAILED
  Runs since failure: 0 (scheduler stopped attempting)

Root cause: BullMQ repeatable job was removed during deployment
  - Deployment at 2025-03-13T08:45Z cleared all repeatable jobs
  - registerScheduledJobs() threw an error on line 42 (Redis timeout)
  - Error was caught but not alerted
  - No jobs were re-registered after deployment
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full scheduled task design workflow |
| `--tech <name>` | Target specific scheduler (bullmq, celery, sidekiq, apscheduler, hangfire, quartz, node-cron) |
| `--diagnose` | Diagnose missed or failing scheduled jobs |
| `--expression <cron>` | Validate and explain a cron expression |
| `--chain` | Design dependent job pipelines |
| `--migrate` | Migrate from one scheduler to another |
| `--monitor` | Set up schedule monitoring and alerting |
| `--backfill` | Backfill missed scheduled job runs |
| `--timezone` | Design timezone-aware user-facing schedules |
| `--lock` | Design distributed locking for multi-instance |

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
grep -rl "cron\|schedule\|repeatable\|every\|interval" src/ --include="*.ts" --include="*.js" --include="*.py" --include="*.rb" 2>/dev/null | head -10

# Detect queue infrastructure
grep -r "redis\|rabbitmq\|sqs\|pubsub" package.json docker-compose.* 2>/dev/null


## Output Format
Print on completion: `Cron: {job_count} jobs configured. Scheduler: {scheduler_type}. Locking: {lock_status}. Monitoring: {monitor_status}. Idempotent: {idempotent_count}/{job_count}. Overlap guard: {overlap_status}. Verdict: {verdict}.`

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

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

## Error Recovery

- **Job fires multiple times across instances**: Enable distributed locking immediately. Use Redis-based locking (Redlock) or database advisory locks. Verify the lock TTL is longer than the job execution time.
- **Job silently stops running**: Check the scheduler process is alive. Verify the job is still registered (startup registry check). Check Redis connection if using Redis-backed scheduler. Add monitoring that alerts when a job does not run within its expected window.
- **Job execution overlaps with next scheduled run**: Enable overlap protection (`max_instances: 1` or `skipIfRunning`). If the job consistently exceeds its interval, increase the interval or optimize the job.
- **DST transition causes missed/duplicate job**: Verify all schedules use UTC. If user-facing schedules must be in local time, use IANA timezone names (not fixed offsets). Test across DST boundaries.
- **Job fails but retries indefinitely**: Set a maximum retry count. Use exponential backoff. After max retries, alert and move to dead-letter queue. Do not retry non-retriable errors (validation failures, auth errors).
- **Scheduler restart loses in-flight jobs**: Use a persistent queue (Redis, PostgreSQL, SQS) to store job state. On restart, the scheduler should resume in-flight jobs, not lose them.

## Iterative Loop Protocol
```
current_job = 0
jobs = detect_scheduled_jobs()  // from cron config, code analysis, scheduler library

WHILE current_job < len(jobs):
  job = jobs[current_job]
  1. AUDIT: Check schedule, locking, idempotency, overlap handling, monitoring
  2. FIX: Add missing safeguards (locking, idempotency, overlap guard)
  3. TEST: Verify job runs correctly in isolation

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
  - Monitoring is not yet configured (that can be a separate pass)
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

## Multi-Agent Dispatch
For comprehensive cron/scheduling setup:
```
DISPATCH parallel agents (one per concern):

Agent 1 (worktree: cron-scheduler):
  - Set up scheduler library and job registration
  - Configure schedules and overlap protection
  - Scope: scheduler config, job definitions
  - Output: Scheduler infrastructure with job registry

Agent 2 (worktree: cron-locking):

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run cron tasks sequentially: scheduler setup, then distributed locking, then monitoring.
- Use branch isolation per task: `git checkout -b godmode-cron-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
```
