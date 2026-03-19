# /godmode:cron

Design, build, and debug scheduled tasks and recurring job systems. Covers cron expression syntax, scheduler selection (node-cron, BullMQ, Celery Beat, Sidekiq-Cron, APScheduler, Hangfire, Quartz), idempotency, distributed locking, job monitoring, dead letter handling, priority queues, job chaining, rate-limited execution, and timezone handling.

## Usage

```
/godmode:cron                             # Full scheduled task design workflow
/godmode:cron --tech bullmq               # Target BullMQ repeatable jobs
/godmode:cron --tech celery               # Design Celery Beat schedules
/godmode:cron --tech quartz               # Design Quartz scheduler (Java)
/godmode:cron --diagnose                  # Diagnose missed or failing scheduled jobs
/godmode:cron --expression "0 9 * * *"    # Validate and explain a cron expression
/godmode:cron --chain                     # Design dependent job pipelines
/godmode:cron --monitor                   # Set up schedule monitoring and alerting
/godmode:cron --backfill                  # Backfill missed scheduled job runs
/godmode:cron --timezone                  # Design timezone-aware schedules
/godmode:cron --lock                      # Design distributed locking for multi-instance
```

## What It Does

1. Assesses scheduling requirements (frequency, duration, overlap, timezone)
2. Selects the appropriate scheduler technology based on stack and constraints
3. Provides cron expression syntax reference and validation
4. Designs schedule registry with idempotent job registration
5. Implements distributed locking for multi-instance deployments
6. Adds idempotency to ensure safe retries and duplicate handling
7. Configures overlap protection and missed-run detection
8. Designs job chaining for dependent scheduled pipelines
9. Implements rate-limited execution for downstream service protection
10. Establishes schedule monitoring, alerting, and dead letter handling

## Output
- Schedule registry at `config/schedules/registry.ts`
- Scheduler setup at `config/schedules/scheduler.ts`
- Idempotency helpers at `lib/scheduled-job-runner.ts`
- Monitoring at `lib/cron-monitor.ts`
- Commit: `"cron: <scheduler> — <N> jobs, <frequency range>, <lock strategy>"`

## Next Step
After schedule setup: `/godmode:observe` to add schedule monitoring, `/godmode:queue` for complex async processing, or `/godmode:ship` to deploy.

## Examples

```
/godmode:cron Set up daily report generation and hourly data sync
/godmode:cron --tech celery Configure Celery Beat for periodic cleanup tasks
/godmode:cron --diagnose Our daily digest stopped running 3 days ago
/godmode:cron --expression "*/15 9-17 * * 1-5" What does this cron expression do?
/godmode:cron --chain Design end-of-day processing pipeline with dependencies
/godmode:cron --timezone Schedule user-facing notifications in their local timezone
```
