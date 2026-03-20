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
|  Distributed?         | <single instance | multi-node>    |
|  Failure handling     | <retry | alert | skip | DLQ>      |
|  Persistence          | <in-memory | Redis | database>    |
|  Existing infra       | <Redis | PostgreSQL | AWS | none> |
|  Language / runtime   | <Node.js | Python | Ruby | Java | |
|                       |  .NET | Go>                       |
+---------------------------------------------------------+
|  Recommendation: <scheduler selection with rationale>    |
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
  * * * * *           Every minute
  */5 * * * *         Every 5 minutes
  0 * * * *           Every hour (top of hour)
  0 */6 * * *         Every 6 hours
  0 9 * * *           Daily at 9:00 AM
  0 9 * * 1-5         Weekdays at 9:00 AM
  0 0 * * 0           Weekly on Sunday at midnight
  0 0 1 * *           Monthly on the 1st at midnight
  0 0 1 1 *           Yearly on January 1st at midnight
  0 9 * * 1           Every Monday at 9:00 AM
  0 0 L * *           Last day of every month at midnight
  0 9 * * 1#1         First Monday of every month at 9:00 AM
  0 */15 9-17 * * 1-5 Every 15 min during business hours (M-F)

6-field (with seconds):
  */30 * * * * *      Every 30 seconds
  0 */5 * * * *       Every 5 minutes (at :00 seconds)

Gotchas:
  - Day-of-month and day-of-week interact oddly in standard cron
    (most libraries treat them as OR; some treat as AND)
  - February 30 or 31 silently skips — never fires
  - "0 0 */2 * *" means every 2nd day-of-month (1, 3, 5...),
    NOT "every other day" — use application logic for true intervals
  - Some libraries use 0-6 for day-of-week, others 0-7 (both 0
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
|                  | DB-backed   |          | (locking)  | (durable) |          |
|                  | scheduling  |          |            |           |          |
|                  |             |          |            |           |          |
| Celery Beat      | Python      | Redis /  | Partial    | Depends   | Medium   |
|                  | Periodic    | RabbitMQ | (single    | on broker |          |
|                  | tasks       |          | beat inst) |           |          |
|                  |             |          |            |           |          |
| APScheduler      | Python      | Memory / | Yes (with  | Optional  | Low      |
|                  | Flexible    | DB /     | job store) | DB store  |          |
|                  | scheduling  | Redis    |            |           |          |
|                  |             |          |            |           |          |
| Sidekiq-Cron     | Ruby        | Redis    | Yes        | Redis     | Low      |
| / sidekiq-       | Recurring   |          | (leader)   | (durable) |          |
| scheduler        | jobs        |          |            |           |          |
|                  |             |          |            |           |          |
| Hangfire         | .NET        | SQL      | Yes        | SQL DB    | Low-Med  |
|                  | Background  | Server   | (locking)  | (durable) |          |
|                  | jobs / cron |          |            |           |          |
|                  |             |          |            |           |          |
| Quartz           | Java / .NET | Memory / | Yes (JDBC  | DB        | Medium   |
|                  | Enterprise  | JDBC /   | job store) | (durable) |          |
|                  | scheduling  | RAM      |            |           |          |
|                  |             |          |            |           |          |
| pg_cron          | PostgreSQL  | PG       | Single DB  | PG        | Minimal  |
|                  | In-database | native   | instance   | (durable) |          |
|                  | scheduling  |          |            |           |          |
|                  |             |          |            |           |          |
| AWS EventBridge  | Any (cloud) | AWS      | Managed    | Managed   | None     |
| Scheduler        |             | managed  | (global)   | (fully)   | (pay/use)|
|                  |             |          |            |           |          |
| Cloud Scheduler  | Any (cloud) | GCP      | Managed    | Managed   | None     |
| (GCP)            |             | managed  | (global)   | (fully)   | (pay/use)|
+------------------+-------------+----------+------------+-----------+----------+

Decision tree:
  Node.js + simple + single process?           -> node-cron
  Node.js + Redis available + production?      -> BullMQ repeatable jobs
  Node.js + MongoDB + flexible scheduling?     -> Agenda
  Python + Celery already in stack?            -> Celery Beat
  Python + standalone scheduler?               -> APScheduler
  Ruby + Sidekiq already in stack?             -> sidekiq-cron
  .NET + SQL Server available?                 -> Hangfire
  Java + enterprise / clustered?               -> Quartz (JDBC store)
  PostgreSQL-only, no extra infra?             -> pg_cron
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
|  Flow: tick -> match schedule -> acquire lock -> enqueue -> execute    |
|        -> record result -> release lock -> schedule next run           |
|                                                                        |
|  Safety:                                                               |
|    - Distributed lock: only one instance fires each job                |
|    - Overlap guard: skip if previous run is still active               |
|    - Idempotency: safe to fire duplicate (deduplication at worker)     |
|    - Missed run: detect and optionally backfill on startup             |
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
    attempts: 3,
    backoff: { type: 'exponential', delay: 5000 },
    removeOnComplete: { age: 86400, count: 1000 },
    removeOnFail: { age: 604800 },
  },
});

// Register all scheduled jobs on startup
async function registerScheduledJobs() {
  // Idempotent: remove old schedules, then re-register
  const existing = await schedulerQueue.getRepeatableJobs();
  for (const job of existing) {
    await schedulerQueue.removeRepeatableByKey(job.key);
  }

  // Daily digest at 9 AM UTC
  await schedulerQueue.add('daily-digest', { type: 'digest' }, {
    repeat: { pattern: '0 9 * * *', tz: 'UTC' },
    jobId: 'daily-digest',
  });

  // Cleanup expired sessions every 6 hours
  await schedulerQueue.add('cleanup-sessions', { type: 'cleanup' }, {
    repeat: { pattern: '0 */6 * * *', tz: 'UTC' },
    jobId: 'cleanup-sessions',
  });

  // Sync inventory every 15 minutes
  await schedulerQueue.add('sync-inventory', { type: 'sync' }, {
    repeat: { pattern: '*/15 * * * *', tz: 'UTC' },
    jobId: 'sync-inventory',
  });

  // Weekly report generation — Mondays at 2 AM UTC
  await schedulerQueue.add('weekly-report', { type: 'report' }, {
    repeat: { pattern: '0 2 * * 1', tz: 'UTC' },
    jobId: 'weekly-report',
  });

  // Monthly billing — 1st of month at midnight UTC
  await schedulerQueue.add('billing-cycle', { type: 'billing' }, {
    repeat: { pattern: '0 0 1 * *', tz: 'UTC' },
    jobId: 'billing-cycle',
  });

  console.log('Scheduled jobs registered');
}

// Worker that dispatches based on job name
const worker = new Worker('scheduled-jobs', async (job) => {
  switch (job.name) {
    case 'daily-digest':
      return await runDailyDigest(job.data);
    case 'cleanup-sessions':
      return await runCleanupSessions(job.data);
    case 'sync-inventory':
      return await runInventorySync(job.data);
    case 'weekly-report':
      return await runWeeklyReport(job.data);
    case 'billing-cycle':
      return await runBillingCycle(job.data);
    default:
      throw new Error(`Unknown scheduled job: ${job.name}`);
  }
}, {
  connection,
  concurrency: 5,
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
)

# --- Celery Beat Schedule Registry ---
app.conf.beat_schedule = {
    'daily-digest': {
        'task': 'tasks.send_daily_digest',
        'schedule': crontab(minute=0, hour=9),           # 9 AM UTC daily
        'options': {'queue': 'default', 'expires': 3600},
    },
    'cleanup-expired-sessions': {
        'task': 'tasks.cleanup_sessions',
        'schedule': crontab(minute=0, hour='*/6'),       # Every 6 hours
        'options': {'queue': 'maintenance'},
    },
    'sync-inventory': {
        'task': 'tasks.sync_inventory',
        'schedule': crontab(minute='*/15'),               # Every 15 minutes
        'options': {'queue': 'high-priority', 'expires': 840},
    },
    'weekly-report': {
        'task': 'tasks.generate_weekly_report',
        'schedule': crontab(minute=0, hour=2, day_of_week=1),  # Mon 2 AM
        'options': {'queue': 'bulk', 'expires': 86400},
    },
    'monthly-billing': {
        'task': 'tasks.run_billing_cycle',
        'schedule': crontab(minute=0, hour=0, day_of_month=1), # 1st of month
        'options': {'queue': 'billing', 'expires': 86400},
    },
}

# --- Task definitions with idempotency ---
@app.task(bind=True, max_retries=3, default_retry_delay=60)
def send_daily_digest(self):
    """Send daily digest emails. Idempotent: checks last_digest_sent_at."""
    from datetime import date
    today = date.today().isoformat()
    lock_key = f'digest:{today}'

    if not acquire_distributed_lock(lock_key, ttl=3600):
        return {'status': 'skipped', 'reason': 'already running or completed'}

    try:
        users = get_users_needing_digest(today)
        for user in users:
            send_digest_email.delay(user.id, today)
        return {'status': 'ok', 'users_queued': len(users)}
    except Exception as exc:
        release_distributed_lock(lock_key)
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
job_defaults = {
    'coalesce': True,             # Combine missed runs into a single run
    'max_instances': 1,           # Prevent overlap — only 1 instance at a time
    'misfire_grace_time': 300,    # Allow 5 min late before considering misfired
}

scheduler = BackgroundScheduler(
    jobstores=jobstores,
    executors=executors,
    job_defaults=job_defaults,
    timezone=pytz.utc,
)

# Register jobs
scheduler.add_job(
    run_daily_digest,
    CronTrigger(hour=9, minute=0, timezone='UTC'),
    id='daily-digest',
    name='Daily Digest Emails',
    replace_existing=True,        # Idempotent registration
)

scheduler.add_job(
    run_cleanup,
    CronTrigger(hour='*/6', minute=0, timezone='UTC'),
    id='cleanup-sessions',
    name='Cleanup Expired Sessions',
    replace_existing=True,
)

scheduler.add_job(
    run_inventory_sync,
    CronTrigger(minute='*/15', timezone='UTC'),
    id='sync-inventory',
    name='Sync Inventory',
    replace_existing=True,
)

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
    'queue' => 'high',
    'description' => 'Sync inventory every 15 minutes',
  },
  'weekly_report' => {
    'cron'  => '0 2 * * 1',
    'class' => 'WeeklyReportWorker',
    'queue' => 'bulk',
    'description' => 'Generate weekly reports on Monday at 2 AM UTC',
  },
)

# app/workers/daily_digest_worker.rb
class DailyDigestWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3, lock: :until_executed

  def perform
    today = Date.today.iso8601
    return if digest_already_sent?(today)

    users = User.needs_digest(today)
    users.find_each do |user|
      DigestEmailWorker.perform_async(user.id, today)
    end
  end
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
    "0 9 * * *",
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc }
);

RecurringJob.AddOrUpdate<ICleanupService>(
    "cleanup-sessions",
    service => service.CleanupExpiredSessionsAsync(),
    "0 */6 * * *",
    new RecurringJobOptions { TimeZone = TimeZoneInfo.Utc }
);

RecurringJob.AddOrUpdate<IInventoryService>(
    "sync-inventory",
    service => service.SyncAsync(),
    "*/15 * * * *",
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
            .withIdentity("daily-digest-trigger", "scheduled")
            .withSchedule(CronScheduleBuilder
                .cronSchedule("0 0 9 * * ?")  // 9 AM daily
                .inTimeZone(TimeZone.getTimeZone("UTC"))
                .withMisfireHandlingInstructionFireAndProceed())
            .build();
    }

    @Bean
    public JobDetail inventorySyncJob() {
        return JobBuilder.newJob(InventorySyncJob.class)
            .withIdentity("sync-inventory", "scheduled")
            .storeDurably()
            .requestRecovery(true)
            .build();
    }

    @Bean
    public Trigger inventorySyncTrigger() {
        return TriggerBuilder.newTrigger()
            .forJob(inventorySyncJob())
            .withIdentity("sync-inventory-trigger", "scheduled")
            .withSchedule(CronScheduleBuilder
                .cronSchedule("0 */15 * * * ?")  // Every 15 minutes
                .inTimeZone(TimeZone.getTimeZone("UTC"))
                .withMisfireHandlingInstructionDoNothing())
            .build();
    }
}

// Quartz properties for clustering (distributed)
// application.properties
// spring.quartz.job-store-type=jdbc
// spring.quartz.jdbc.initialize-schema=always
// spring.quartz.properties.org.quartz.jobStore.isClustered=true
// spring.quartz.properties.org.quartz.jobStore.clusterCheckinInterval=15000
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
  - Job might be re-created on restart with a new ID
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

    // Acquire exclusive lock for this window
    const lockKey = `lock:${idempotencyKey}`;
    const acquired = await this.redis.set(lockKey, '1', 'EX', 600, 'NX');
    if (!acquired) {
      return { status: 'skipped' }; // Another instance is handling it
    }

    try {
      const result = await handler();

      // Mark as completed — prevents re-execution for this window
      await this.redis.set(idempotencyKey, JSON.stringify({
        completedAt: new Date().toISOString(),
        result: typeof result === 'object' ? result : { value: result },
      }), 'EX', ttl);

      return { status: 'executed', result };
    } catch (error) {
      // Release lock on failure — allows retry
      await this.redis.del(lockKey);
      throw error;
    }
  }
}

// Usage in BullMQ worker
const runner = new ScheduledJobRunner(redis);

const worker = new Worker('scheduled-jobs', async (job) => {
  // Derive window from the repeatable job's timestamp
  const window = new Date(job.timestamp).toISOString().slice(0, 16); // "2025-03-15T09:00"

  return runner.runOnce(job.name, window, async () => {
    switch (job.name) {
      case 'daily-digest': return runDailyDigest();
      case 'cleanup-sessions': return runCleanupSessions();
      default: throw new Error(`Unknown job: ${job.name}`);
    }
  });
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
|                      |          |                  |       |
|  DB row locking      | Any RDBMS| Simple, works    | Lock  |
|  (SELECT FOR UPDATE) |          | with existing DB | cont. |
+---------------------------------------------------------+

Rule of thumb:
  - Single Redis instance + acceptable rare duplication -> SETNX
  - Need strong consistency + already have PG           -> Advisory locks
  - Distributed Redis + critical no-duplication          -> Redlock
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
      if redis.call("get", KEYS[1]) == ARGV[1] then
        return redis.call("pexpire", KEYS[1], ARGV[2])
      else
        return 0
      end
    `;
    const result = await this.redis.eval(script, 1, 'scheduler:leader', schedulerId, ttl * 1000);
    return result === 1;
  }

  async acquireJobLock(jobName: string, windowKey: string, ttl: number = 300): Promise<boolean> {
    const lockKey = `cron:lock:${jobName}:${windowKey}`;
    const acquired = await this.redis.set(lockKey, '1', 'EX', ttl, 'NX');
    return acquired === 'OK';
  }
}

// Leader election loop
async function runSchedulerWithLeaderElection(schedulerId: string) {
  const lock = new DistributedSchedulerLock(redis);

  setInterval(async () => {
    const isLeader = await lock.acquireLeader(schedulerId, 30);
    if (isLeader) {
      // This instance is the leader — it fires scheduled jobs
      await checkAndFireScheduledJobs();
    }
    // Not the leader — standby, will try again next interval
  }, 10_000); // Check every 10 seconds

  // Heartbeat to keep leadership
  setInterval(async () => {
    await lock.renewLeadership(schedulerId, 30);
  }, 10_000);
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
      .lpush(`cron:history:${jobName}`, JSON.stringify({
        at: now, ...result,
      }))
      .ltrim(`cron:history:${jobName}`, 0, 99) // Keep last 100 runs
      .exec();

    // Check for anomalies
    await this.checkAlerts(jobName, result);
  }

  async checkMissedSchedules(jobs: Array<{
    name: string;
    intervalMs: number;
    graceMs: number;
  }>) {
    for (const job of jobs) {
      const key = `cron:monitor:${job.name}`;
      const lastRun = await this.redis.hget(key, 'last_run_at');

      if (!lastRun) {
        this.alerter.warn(`Cron job "${job.name}" has never run`);
        continue;
      }

      const elapsed = Date.now() - parseInt(lastRun);
      if (elapsed > job.intervalMs + job.graceMs) {
        this.alerter.critical(
          `Cron job "${job.name}" missed schedule. ` +
          `Last run: ${Math.round(elapsed / 60000)} min ago. ` +
          `Expected interval: ${Math.round(job.intervalMs / 60000)} min.`
        );
      }
    }
  }

  private async checkAlerts(jobName: string, result: any) {
    if (result.status === 'failure') {
      // Check failure rate in last hour
      const history = await this.redis.lrange(`cron:history:${jobName}`, 0, -1);
      const recentRuns = history
        .map(h => JSON.parse(h))
        .filter(h => h.at > Date.now() - 3600000);

      const failRate = recentRuns.filter(r => r.status === 'failure').length / recentRuns.length;
      if (failRate > 0.1) {
        this.alerter.warn(
          `Cron job "${jobName}" failure rate: ${(failRate * 100).toFixed(1)}% in last hour`
        );
      }
    }
  }
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
|      { "attempt": 2, "error": "ECONNREFUSED ...", ... }, |
|      { "attempt": 3, "error": "ETIMEDOUT ...", ... }    |
|    ],                                                     |
|    "impact": "12,000 users did not receive digest"        |
|  }                                                        |
|                                                           |
|  Recovery options:                                        |
|    1. Fix root cause, manually trigger the job            |
|    2. Replay from DLQ to original queue                   |
|    3. Skip window (e.g., digest was for yesterday)        |
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
|      v                                                    |
|  Step 2: generate-daily-report                            |
|      |   (10 min, depends on step 1)                      |
|      v                                                    |
|  Step 3: send-report-email                                |
|      |   (1 min, depends on step 2)                       |
|      v                                                    |
|  Step 4: archive-raw-data                                 |
|          (30 min, depends on step 1, can run with 2/3)    |
|                                                           |
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
          data: { type: 'aggregation', period: 'daily' },
        },
      ],
    },
    {
      name: 'archive-raw-data',
      queueName: 'scheduled-jobs',
      data: { type: 'archive', period: 'daily' },
      children: [
        {
          name: 'aggregate-daily-stats',
          queueName: 'scheduled-jobs',
          data: { type: 'aggregation', period: 'daily' },
          opts: { jobId: 'agg-daily-shared' }, // Shared dependency (deduplicated)
        },
      ],
    },
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

// Worker with rate limit to respect email provider limits
const emailWorker = new Worker('email', async (job) => {
  return sendEmail(job.data);
}, {
  connection,
  concurrency: 5,
  limiter: {
    max: 500,        // Max 500 emails
    duration: 3600000, // Per hour (respect provider limit)
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

Celery timezone support:
  app.conf.timezone = 'UTC'
  crontab(hour=9, minute=0)  # Always UTC unless overridden

APScheduler timezone support:
  CronTrigger(hour=9, minute=0, timezone='US/Eastern')

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
  - Job frequency is sub-minute or high volume
  - Redis is already in the stack
  - Speed matters more than audit trail
  - You have Redis persistence configured (AOF recommended)

Use DB-backed (Hangfire, Quartz JDBC, Agenda, pg_cron) when:
  - Need full audit trail / compliance
  - Jobs are infrequent (hourly/daily)
  - Cannot lose schedule state under any circumstances
  - No Redis in stack and do not want to add it
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
  daily-report: 0 2 * * * (2 AM UTC), queue: bulk, timeout: 30m
  hourly-sync:  0 * * * * (top of hour), queue: high, timeout: 5m

Safety:
  Distributed lock via Redis SETNX (leader election)
  Idempotency key: {job}:{YYYY-MM-DDTHH:00}
  Overlap guard: skip if previous run still active
  Missed-run alert: fire if > 1.5x interval since last run

Monitoring:
  Schedule adherence, run duration, failure rate metrics
  Alerts: missed schedule, failure rate > 10%, duration > 5x avg

Cron ready. View schedules: await schedulerQueue.getRepeatableJobs()
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

Fix applied:
  1. Fixed registerScheduledJobs() to retry on Redis connection failure
  2. Re-registered all scheduled jobs
  3. Added startup health check: verify all expected jobs exist
  4. Added alert: "scheduled job count < expected" fires within 5 min
  5. Manually triggered daily-digest for missed days (backfill)

Recovery:
  3 missed digests backfilled and sent
  Schedule verified: next run at 2025-03-16T09:00Z
  Monitoring: startup verification + missed-schedule alerts active
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

# Detect existing scheduled workflows
ls .github/workflows/*.yml 2>/dev/null | xargs grep -l "schedule:" 2>/dev/null
```

## Anti-Patterns

- **Do NOT use `setInterval` or `setTimeout` for production scheduling.** They do not survive restarts, have no distributed locking, no monitoring, and drift over time. Use a proper scheduler.
- **Do NOT schedule jobs in local timezones.** DST transitions will skip your 2 AM job in March and run your 1 AM job twice in November. Use UTC for all system schedules.
- **Do NOT assume single-instance execution.** If your app runs on 2+ instances, every cron job will fire N times without distributed locking. Add locking from day one.
- **Do NOT skip idempotency because "cron only fires once."** Schedulers fire duplicates during restarts, failovers, clock drift, and Redis reconnections. Make every handler idempotent.
- **Do NOT ignore overlap.** A report that runs every hour but takes 90 minutes will stack up and eventually OOM your system. Guard against overlap with locks or `max_instances`.
- **Do NOT put heavy work in the scheduler tick.** The scheduler should enqueue a job, not execute it. Blocking the scheduler loop delays all other schedules.
- **Do NOT store schedule definitions only in code without a startup registry check.** If registration fails silently, jobs stop running with no alert. Verify registered job count on startup.
- **Do NOT use fixed-offset timezones (UTC-5).** Use IANA names (America/New_York). Fixed offsets do not handle daylight saving time and will be wrong for half the year.

## Output Format
Print on completion: `Cron: {job_count} jobs configured. Scheduler: {scheduler_type}. Locking: {lock_status}. Monitoring: {monitor_status}. Idempotent: {idempotent_count}/{job_count}. Overlap guard: {overlap_status}. Verdict: {verdict}.`

## TSV Logging
Log every cron job configuration to `.godmode/cron-results.tsv`:
```
iteration	job_name	schedule	scheduler	locking	idempotent	overlap_guard	monitoring	status
1	daily_report	0 6 * * *	bullmq	redis_lock	yes	max_instances:1	yes	configured
2	hourly_sync	0 * * * *	bullmq	redis_lock	yes	skip_if_running	yes	configured
3	weekly_cleanup	0 3 * * 0	bullmq	redis_lock	yes	max_instances:1	yes	configured
```
Columns: iteration, job_name, schedule, scheduler, locking, idempotent, overlap_guard, monitoring, status(configured/tested/failed).

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
  4. MONITOR: Configure alerting for success/failure/duration
  5. LOG to .godmode/cron-results.tsv
  6. current_job += 1
  7. REPORT: "Job {current_job}/{total}: {job_name} — schedule: {schedule}, locking: {lock_status}, idempotent: {idempotent}"

EXIT when all jobs configured OR user requests stop
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
  - Implement distributed locking for all jobs
  - Configure lock TTLs and failure handling
  - Scope: locking middleware, Redis/DB config
  - Output: Distributed locking for all jobs

Agent 3 (worktree: cron-monitoring):
  - Set up job monitoring and alerting
  - Configure success/failure/duration metrics
  - Scope: monitoring config, alert rules, dashboards
  - Output: Job monitoring with alerting

MERGE ORDER: scheduler → locking → monitoring
CONFLICT RESOLUTION: scheduler branch owns job definitions; locking branch owns middleware
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run cron tasks sequentially: scheduler setup, then distributed locking, then monitoring.
- Use branch isolation per task: `git checkout -b godmode-cron-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
