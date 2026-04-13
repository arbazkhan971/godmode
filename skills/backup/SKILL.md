---
name: backup
description: |
  Backup and disaster recovery skill. Activates when user needs to design backup strategies, define RPO/RTO targets,
    test recovery procedures, verify data integrity, or generate disaster recovery runbooks. Produces comprehensive
    backup plans with automated verification and tested recovery procedures. Triggers on: /godmode:backup, "backup
    strategy", "disaster recovery", "what's our RPO?", "can we recover from", or when designing critical data
    infrastructure.
---

# Backup — Backup & Disaster Recovery

## Activate When
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

IF backup age >24h: trigger immediate backup.
IF restore test fails: alert and re-run.

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
Save runbook as `docs/dr/<date>-disaster-recovery-runbook.md`

```bash
# Test backup and restore procedures
pg_dump -Fc mydb > backup_test.dump
pg_restore -d mydb_test backup_test.dump
psql mydb_test -c "SELECT count(*) FROM users;"
```


```bash
# Verify backup and test restore
pg_dump --format=custom -f backup.dump $DATABASE_URL
pg_restore --list backup.dump
curl -s http://localhost:8080/health
```

## Auto-Detection
```
1. Data stores: grep for postgres, mysql, mongodb, redis connection strings
2. Object storage: grep for S3, GCS, Azure Blob configs
3. Existing backups: check crontab, CI jobs, WAL archiving configs
4. No backups → CRITICAL gap. No verification → HIGH gap.
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

<!-- tier-3 -->

## Quality Targets
- RPO Tier 1: <1h data loss window
- RTO Tier 1: <15min recovery time
- Restore success: >99% verified

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
Print on completion: `Backup: {asset_count} assets covered. RPO: {rpo}. RTO: {rto}. Last restore test:
{last_test_date}. Encryption: {encryption_status}. Cross-region: {cross_region}. Verdict: {verdict}.`
```
timestamp	asset	operation	size	duration_s	status	checksum
2024-01-15T03:00:00Z	postgres-prod	backup	12GB	180	success	sha256:abc123
2024-01-15T03:05:00Z	redis-prod	backup	2GB	30	success	sha256:def456
2024-01-15T04:00:00Z	postgres-prod	restore-test	12GB	300	success	verified
```
Columns: timestamp, asset, operation(backup/restore-test/dr-drill), size, duration_s,
status(success/failed/partial), checksum.

## Success Criteria
```


## Keep/Discard
KEEP if: improvement verified. DISCARD if: regression or no change. Revert discards immediately.

## Stop Conditions
Stop when: target reached, budget exhausted, or >5 consecutive discards.

