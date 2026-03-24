---
name: backup
description: |
  Backup and disaster recovery skill. Activates when user needs to design backup strategies, define RPO/RTO targets, test recovery procedures, verify data integrity, or generate disaster recovery runbooks. Produces comprehensive backup plans with automated verification and tested recovery procedures. Triggers on: /godmode:backup, "backup strategy", "disaster recovery", "what's our RPO?", "can we recover from", or when designing critical data infrastructure.
---

# Backup — Backup & Disaster Recovery

## When to Activate
- User invokes `/godmode:backup`
- User says "backup strategy," "disaster recovery," "what happens if we lose the database?"
- User is designing data infrastructure that needs durability guarantees
- After `/godmode:infra` provisions stateful services (databases, storage, queues)
- Incident post-mortem reveals backup or recovery gaps
- Compliance requirements mandate backup and recovery documentation

## Workflow

### Step 1: Inventory Data Assets
Identify all data that needs protection:

```
DATA ASSET INVENTORY:
| Asset | Type | Size | Growth | Critical |
```

### Step 2: Define RPO/RTO Targets
Set recovery objectives for each data tier:

```
RECOVERY OBJECTIVES:
| Data Tier | RPO | RTO | Justification |
```

### Step 3: Backup Strategy Design
Design backup approach for each data tier:

#### Tier 1: Continuous Protection
```
TIER 1 BACKUP STRATEGY:

Primary database:
```

#### Tier 2: Periodic Snapshots
```
TIER 2 BACKUP STRATEGY:

File uploads (S3/GCS):
```

#### Tier 3: Daily Backups
```
TIER 3 BACKUP STRATEGY:

Application logs:
```

### Step 4: Backup Verification
Automated checks that backups are actually working:

```
BACKUP VERIFICATION SCHEDULE:
| Check | Frequency | Method | Alert |
```
```

### Step 5: Data Integrity Verification
Verify backed-up data is consistent and usable:
```
DATA INTEGRITY CHECKS:
| Check | Method | Frequency |
|--|--|--|
| Row count consistency | Compare source vs | After each |
|  | restored backup | restore test |
| Checksum verification | SHA-256 of backup | Every backup |
|  | file |  |
| Foreign key integrity | Run FK constraint | Weekly |
|  | check on restored DB | restore |
| Application smoke test | Run app against | Monthly |
|  | restored DB | restore |
| Point-in-time accuracy | Restore to specific | Quarterly |
|  | time, verify records |  |
| Cross-region consistency | Compare checksums | Weekly |
|  | across regions |  |

Integrity verification queries:
```sql
-- Row count comparison (run against source and restored)
SELECT table_name, n_live_tup
FROM pg_stat_user_tables
```
```

### Step 6: Recovery Procedures
Document step-by-step recovery for each failure scenario:
```
RECOVERY: Primary Database Failure
Severity: CRITICAL
RPO: < 1 minute (via streaming replication)
RTO: < 15 minutes (via automated failover)

AUTOMATED RESPONSE:
  1. Health check detects primary is unresponsive (30 seconds)
  2. Orchestrator promotes synchronous replica to primary (15 seconds)
  3. Application connection pool reconnects to new primary (30 seconds)
  4. DNS/service discovery updated (60 seconds)
  5. Alert sent to on-call engineer
  6. Total automated recovery: < 3 minutes

MANUAL RESPONSE (if automated failover fails):
  1. Verify primary is truly down (not a network partition)
     $ pg_isready -h <primary-host>
  2. Check replica lag
     $ psql -h <replica-host> -c "SELECT pg_last_wal_replay_lsn();"
  3. Promote replica manually
     $ pg_ctl promote -D /var/lib/postgresql/data
  4. Update connection string in application config
  5. Restart application instances
  6. Verify application is serving traffic

POST-RECOVERY:
  1. Provision new replica from promoted primary
  2. Verify replication is streaming
  3. Update monitoring and alerting
  4. Write incident report
```

#### Scenario 2: Data Corruption
```
RECOVERY: Data Corruption — Severity: HIGH, RTO: 15min-2h
1. STOP: Identify scope, disable source (bad migration, broken code)
2. RECOVER: Point-in-time restore (recent) | Snapshot restore (widespread) | Selective table restore (targeted)
3. VERIFY: Row counts, smoke tests, no orphaned records
4. POST-MORTEM: Root cause, prevention, detection/recovery speed
```

#### Scenario 3: Complete Region Failure
```
RECOVERY: Region Failure — Severity: CRITICAL, RPO: <1min, RTO: <30min
1. Detect failure (monitoring + cloud status page)
2. Activate DR: promote cross-region replica, verify storage, scale instances, update DNS (TTL 60s)
3. Verify DR serving traffic, communicate to stakeholders
RETURN TO PRIMARY: Wait 24h+, reverse replication, verify consistency, canary traffic shift
```

### Step 7: Disaster Recovery Runbook
Generate a comprehensive runbook document:
```
  DISASTER RECOVERY RUNBOOK
  Last tested: <date>
  Next test scheduled: <date>
  Owner: <team/person>
  On-call escalation: <contact chain>
  Recovery objectives:
| Tier 1 RPO: < 1 min | RTO: < 15 min |
|--|--|
| Tier 2 RPO: < 1 hour | RTO: < 1 hour |
| Tier 3 RPO: < 24 hour | RTO: < 4 hours |
  Scenarios covered:
  1. Primary database failure      → Page 3
  2. Data corruption               → Page 5
  3. Complete region failure        → Page 8
  4. Ransomware / security breach   → Page 11
  5. Accidental data deletion       → Page 13
  6. Cloud provider outage          → Page 15
  Backup status:
  Database: <HEALTHY | DEGRADED | FAILED>
  File storage: <HEALTHY | DEGRADED | FAILED>
  Configuration: <HEALTHY | DEGRADED | FAILED>
  Secrets: <HEALTHY | DEGRADED | FAILED>
  Last successful restore test: <date> (<result>)
  Last DR failover test: <date> (<result>)
```

### Step 8: Backup & DR Report

```
  BACKUP & DISASTER RECOVERY REPORT
  Data assets inventoried: <N>
  Backup strategies defined: <N>
  Recovery procedures documented: <N> scenarios
  Coverage:
  Tier 1 (critical):    <PROTECTED | GAPS | UNPROTECTED>
  Tier 2 (important):   <PROTECTED | GAPS | UNPROTECTED>
  Tier 3 (operational): <PROTECTED | GAPS | UNPROTECTED>
  Verification:
  Automated checks: <CONFIGURED | PARTIAL | MISSING>
  Last restore test: <date | NEVER>
  Last DR test: <date | NEVER>
  Gaps identified: <N>
  1. <gap description and remediation>
  2. <gap description and remediation>
  Verdict: <PROTECTED | PARTIAL | AT RISK>
```

### Step 9: Commit and Transition
1. Save runbook as `docs/dr/<date>-disaster-recovery-runbook.md`
```
AUTO-DETECT SEQUENCE:
1. Detect data stores:
   - grep for database connection strings (postgres, mysql, mongodb, redis)
   - Check docker-compose.yml for database services
   - Check terraform/k8s configs for managed databases (RDS, Cloud SQL, etc.)
2. Detect object storage:
   - grep for S3, GCS, Azure Blob connection configs
   - Check for file upload handling code
3. Detect existing backup tooling:
   - Check for pg_dump scripts, mysqldump scripts
   - Check crontab for backup jobs
   - Check for backup-related GitHub Actions or CI jobs
   - Check for WAL archiving configuration (pg_basebackup, wal-g, pgbackrest)
4. Detect secrets management:
   - Check for Vault, AWS KMS, GCP KMS configs
   - Check for .env files with database credentials
5. Detect infrastructure-as-code:
   - terraform, pulumi, cdk → check for backup configurations
   - Check for RDS automated backups, snapshot configs
6. Estimate data size:
   - Check database migration count as proxy for schema complexity
   - Check disk usage in docker volumes or persistent volume claims
7. Auto-configure:
   - No backups detected → flag as CRITICAL gap
   - Backups exist but no verification → flag as HIGH gap
   - No cross-region backup → flag for Tier 1 data
```

## Explicit Loop Protocol

```
BACKUP VERIFICATION LOOP:
current_iteration = 0
max_iterations = 10
gaps_remaining = total_gaps_found

WHILE gaps_remaining > 0 AND current_iteration < max_iterations:
    current_iteration += 1

    1. SELECT highest-severity backup gap
    2. IMPLEMENT fix:
       - Missing backup → create backup job/config
       - No verification → add automated integrity check
       - No cross-region → configure replication
       - No restore test → create and run restore test
    3. git commit: "backup: fix <gap> (iter {current_iteration})"
    4. VERIFY the fix:
       - Backup job runs successfully
       - Backup file is valid (checksum, header check)
       - Restore test passes (if applicable)
    5. IF verification fails:
       - Debug configuration
       - Retry with adjusted parameters
    6. UPDATE gaps_remaining

    IF current_iteration % 3 == 0:
        PRINT STATUS:
        "Iteration {current_iteration}/{max_iterations}"
        "Gaps fixed: {total_gaps - gaps_remaining}/{total_gaps}"
        "Tier 1 coverage: {tier1_status}"
        "Tier 2 coverage: {tier2_status}"
        "Last restore test: {last_restore_result}"
```

## HARD RULES

Never ask to continue. Loop autonomously until all backup gaps are resolved or budget exhausted.

```
MECHANICAL CONSTRAINTS — NON-NEGOTIABLE:
1. NEVER treat a backup as valid until a restore test has succeeded.
2. NEVER store backups in the same failure domain as production (same region, same account).
3. ENCRYPT EVERY backup at rest — no exceptions for any data tier.
4. EVERY backup job MUST alert on failure — silent backup failures are the worst kind.
5. EVERY backup MUST have a TTL/retention policy — no infinite storage growth.
6. DEFINE RPO and RTO BEFORE designing backup strategy — business drives engineering.
7. git commit backup configurations BEFORE testing — baseline for debugging.
8. Automatic revert on regression: if backup config change causes production issues, revert immediately.
9. NEVER skip quarterly DR tests — schedule them and treat them as P1 obligations.
10. Log all backup operations in TSV:
    TIMESTAMP\tASSET\tOPERATION\tSIZE\tDURATION\tSTATUS\tCHECKSUM
```

## Output Format
Print on completion: `Backup: {asset_count} assets covered. RPO: {rpo}. RTO: {rto}. Last restore test: {last_test_date}. Encryption: {encryption_status}. Cross-region: {cross_region}. Verdict: {verdict}.`
```
timestamp	asset	operation	size	duration_s	status	checksum
2024-01-15T03:00:00Z	postgres-prod	backup	12GB	180	success	sha256:abc123
2024-01-15T03:05:00Z	redis-prod	backup	2GB	30	success	sha256:def456
2024-01-15T04:00:00Z	postgres-prod	restore-test	12GB	300	success	verified
```
Columns: timestamp, asset, operation(backup/restore-test/dr-drill), size, duration_s, status(success/failed/partial), checksum.

## Success Criteria
```
IF >3 consecutive iterations fail to fix a backup gap:
  1. Re-read the backup tool documentation — misconfigured parameters are the #1 cause.
  2. Simplify: try a manual pg_dump/mongodump before automating with a complex backup tool.
  3. Check infrastructure: permissions, storage bucket access, network between source and backup target.
  4. If still stuck → log stop_reason=stuck, mark the gap as UNRESOLVED with details, move to next gap.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All critical data assets (Tier 1) have automated, verified backups
  - All backup gaps from the initial audit are resolved or documented
  - User explicitly requests stop
  - Max iterations (10) reached — report remaining gaps

DO NOT STOP only because:
  - Tier 3 assets lack backup (address Tier 1 first)
  - A restore test takes time to run (schedule it, do not skip it)
```

## Simplicity Criterion
```
PREFER the simpler backup approach:
  - Cloud-native automated backups (RDS snapshots, S3 versioning) before custom backup scripts
  - pg_dump with cron before pgBackRest for small databases
  - Cross-region replication before custom backup-and-copy scripts
  - Built-in encryption (AES-256 at rest) before custom encryption wrappers
  - If rebuild-from-source is faster than restore → document the rebuild procedure instead of backing up
```


## Error Recovery
| Failure | Action |
|--|--|
| Backup job fails silently | Add alerting on backup completion. Check disk space, permissions, and network connectivity. Verify backup tool exit code is checked. |
| Restore test fails | Compare backup format with current schema version. Check for schema drift since backup was taken. Test restore on a fresh instance. |
| Backup takes too long | Switch to incremental backups. Check if WAL archiving (Postgres) or binlog (MySQL) is available. Compress during transfer. |
| Backup storage fills up | Implement retention policy: keep daily for 7d, weekly for 4w, monthly for 12m. Automate cleanup of expired backups. |

## TSV Logging
Append to `.godmode/backup-results.tsv`:
```
timestamp	database	backup_type	size_mb	duration_s	restore_tested	status
```
One row per backup operation. Never overwrite previous rows.

## Keep/Discard Discipline
```
After EACH backup configuration change:
  KEEP if: backup completes AND restore test succeeds AND alerting fires on failure
  DISCARD if: backup fails OR restore produces data mismatch OR no alerting configured
  On discard: revert. A backup you cannot restore is not a backup.
```
