---
name: backup
description: |
  Backup and disaster recovery skill. Activates when user needs to design backup strategies, define RPO/RTO targets, test recovery procedures, verify data integrity, or generate disaster recovery runbooks. Produces comprehensive backup plans with automated verification and tested recovery procedures. Triggers on: /godmode:backup, "backup strategy", "disaster recovery", "what's our RPO?", "can we recover from", or when critical data infrastructure is being designed.
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
┌──────────────────────────────────────────────────────────────────┐
│ Asset               │ Type       │ Size    │ Growth   │ Critical │
├──────────────────────────────────────────────────────────────────┤
│ Primary database    │ PostgreSQL │ 50 GB   │ 2 GB/mo  │ YES      │
│ User file uploads   │ S3/GCS     │ 200 GB  │ 10 GB/mo │ YES      │
│ Redis cache         │ Redis      │ 5 GB    │ stable   │ NO       │
│ Application logs    │ ELK/CW     │ 100 GB  │ 20 GB/mo │ PARTIAL  │
│ Configuration       │ Git/Vault  │ < 1 MB  │ minimal  │ YES      │
│ Secrets/keys        │ Vault/KMS  │ < 1 MB  │ minimal  │ CRITICAL │
│ Message queue       │ Kafka/SQS  │ 10 GB   │ varies   │ YES      │
│ Search index        │ ES/Algolia │ 15 GB   │ 1 GB/mo  │ NO       │
└──────────────────────────────────────────────────────────────────┘

Rebuild-from-source:
  Redis cache: Can be rebuilt from primary database (no backup needed)
  Search index: Can be reindexed from primary database (no backup needed)
  Application logs: Useful but not critical (reduced retention acceptable)
```

### Step 2: Define RPO/RTO Targets
Set recovery objectives for each data tier:

```
RECOVERY OBJECTIVES:
┌──────────────────────────────────────────────────────────────────┐
│ Data Tier      │ RPO            │ RTO            │ Justification │
├──────────────────────────────────────────────────────────────────┤
│ Tier 1:        │ < 1 minute     │ < 15 minutes   │ Business-     │
│ Critical       │ (near-zero     │ (automated      │ critical,     │
│ (primary DB,   │  data loss)    │  failover)      │ revenue       │
│  secrets)      │                │                 │ impact        │
├──────────────────────────────────────────────────────────────────┤
│ Tier 2:        │ < 1 hour       │ < 1 hour       │ Important     │
│ Important      │ (hourly        │ (restore from   │ but can       │
│ (file uploads, │  snapshots)    │  snapshot)      │ tolerate      │
│  queue data)   │                │                 │ brief loss    │
├──────────────────────────────────────────────────────────────────┤
│ Tier 3:        │ < 24 hours     │ < 4 hours      │ Rebuild-      │
│ Operational    │ (daily         │ (restore or     │ able,         │
│ (logs, cache,  │  backups)      │  rebuild)       │ non-critical  │
│  search index) │                │                 │               │
└──────────────────────────────────────────────────────────────────┘

RPO = Recovery Point Objective (maximum acceptable data loss)
RTO = Recovery Time Objective (maximum acceptable downtime)
```

### Step 3: Backup Strategy Design
Design backup approach for each data tier:

#### Tier 1: Continuous Protection
```
TIER 1 BACKUP STRATEGY:

Primary database:
  Method 1: Streaming replication (real-time)
    - Synchronous replica in same region (zero data loss)
    - Asynchronous replica in different region (< 1 second lag)
    - Automatic failover via orchestrator (< 15 second switchover)

  Method 2: Continuous WAL archiving (point-in-time recovery)
    - WAL segments shipped to object storage every 60 seconds
    - Enables recovery to any point in time within retention window
    - Retention: 30 days of WAL history

  Method 3: Daily base backups
    - Full backup: daily at 03:00 UTC (low-traffic window)
    - Stored in separate region on object storage
    - Encrypted at rest (AES-256, keys in KMS)
    - Retention: 30 days daily, 12 months weekly, 7 years monthly

Secrets/keys:
  - Vault auto-snapshots every 15 minutes
  - Encrypted backup to separate storage
  - Unsealing keys stored in separate security domain
  - Recovery procedure tested quarterly
```

#### Tier 2: Periodic Snapshots
```
TIER 2 BACKUP STRATEGY:

File uploads (S3/GCS):
  - Cross-region replication enabled (automatic)
  - Versioning enabled (protects against accidental deletion)
  - Lifecycle: current → 30 days → Infrequent Access → 90 days → Glacier
  - Deletion protection: MFA required for bucket deletion

Message queue:
  - Consumer offsets checkpointed every 5 minutes
  - Dead letter queue for failed messages (14-day retention)
  - Queue configuration backed up to Git (IaC)
```

#### Tier 3: Daily Backups
```
TIER 3 BACKUP STRATEGY:

Application logs:
  - Shipped to centralized logging service (retained 30 days hot, 1 year cold)
  - Daily export to object storage (compressed, encrypted)
  - No point-in-time recovery needed

Cache (Redis):
  - RDB snapshots every 6 hours (kept for rebuild reference only)
  - Primary recovery method: rebuild from database
  - Cache warming script: <script location>

Search index:
  - Daily index snapshot to object storage
  - Primary recovery method: full reindex from database
  - Reindex script: <script location>
  - Estimated reindex time: <duration>
```

### Step 4: Backup Verification
Automated checks that backups are actually working:

```
BACKUP VERIFICATION SCHEDULE:
┌──────────────────────────────────────────────────────────────────┐
│ Check                    │ Frequency  │ Method              │ Alert│
├──────────────────────────────────────────────────────────────────┤
│ Backup job completed     │ Per run    │ Job exit code       │ Page │
│ Backup size reasonable   │ Per run    │ Compare to previous │ Warn │
│ Backup file readable     │ Daily      │ Read header/checksum│ Page │
│ Restore test (sample)    │ Weekly     │ Restore to test env │ Warn │
│ Full restore test        │ Monthly    │ Restore full DB     │ Page │
│ Cross-region accessible  │ Weekly     │ Read from DR region │ Page │
│ Encryption verified      │ Weekly     │ Verify encryption   │ Page │
│ Retention policy applied │ Weekly     │ Count old backups   │ Warn │
└──────────────────────────────────────────────────────────────────┘

Verification script:
```bash
#!/bin/bash
# backup-verify.sh — Run daily via cron or CI

# 1. Check latest backup exists and is recent
LATEST=$(aws s3 ls s3://backups/db/ --recursive | sort | tail -1)
AGE_HOURS=$(( ($(date +%s) - $(date -d "$LATEST_DATE" +%s)) / 3600 ))
if [ $AGE_HOURS -gt 25 ]; then
  alert "CRITICAL: Latest backup is ${AGE_HOURS}h old (expected < 25h)"
fi

# 2. Check backup size is reasonable (not empty, not suspiciously small)
SIZE=$(echo $LATEST | awk '{print $3}')
if [ $SIZE -lt $MIN_EXPECTED_SIZE ]; then
  alert "WARNING: Backup size ${SIZE} is below minimum ${MIN_EXPECTED_SIZE}"
fi

# 3. Verify backup integrity (checksum)
aws s3 cp "s3://backups/db/${LATEST_FILE}" - | sha256sum | verify_checksum

# 4. Test restore (weekly)
if [ $(date +%u) -eq 1 ]; then  # Monday
  restore_to_test_env "$LATEST_FILE"
  run_integrity_checks
fi
```
```

### Step 5: Data Integrity Verification
Ensure backed-up data is consistent and usable:

```
DATA INTEGRITY CHECKS:
┌──────────────────────────────────────────────────────────────────┐
│ Check                     │ Method                │ Frequency    │
├──────────────────────────────────────────────────────────────────┤
│ Row count consistency     │ Compare source vs     │ After each   │
│                           │ restored backup       │ restore test │
│ Checksum verification     │ SHA-256 of backup     │ Every backup │
│                           │ file                  │              │
│ Foreign key integrity     │ Run FK constraint      │ Weekly       │
│                           │ check on restored DB  │ restore      │
│ Application smoke test    │ Run app against       │ Monthly      │
│                           │ restored DB           │ restore      │
│ Point-in-time accuracy    │ Restore to specific   │ Quarterly    │
│                           │ time, verify records  │              │
│ Cross-region consistency  │ Compare checksums     │ Weekly       │
│                           │ across regions        │              │
└──────────────────────────────────────────────────────────────────┘

Integrity verification queries:
```sql
-- Row count comparison (run against source and restored)
SELECT table_name, n_live_tup
FROM pg_stat_user_tables
ORDER BY table_name;

-- Foreign key integrity
SELECT conname, conrelid::regclass
FROM pg_constraint
WHERE contype = 'f'
AND NOT convalidated;

-- Data freshness (verify latest records are present)
SELECT MAX(created_at) AS latest_record
FROM <critical_table>;
```
```

### Step 6: Recovery Procedures
Document step-by-step recovery for each failure scenario:

#### Scenario 1: Primary Database Failure
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
RECOVERY: Data Corruption (accidental deletion, bad migration, etc.)
Severity: HIGH
RPO: Depends on detection time
RTO: 15 minutes to 2 hours

PROCEDURE:
  1. STOP THE BLEEDING
     - Identify the scope of corruption (which tables, which rows)
     - If ongoing: disable the source (bad migration, broken code, etc.)
     - If accidental deletion: check if soft-delete is available

  2. ASSESS RECOVERY OPTIONS
     Option A: Point-in-time recovery (best for recent corruption)
       - Determine the timestamp just before corruption
       - Restore WAL to that point-in-time
       - Extract corrected data
       - Apply to production

     Option B: Snapshot restore (best for widespread corruption)
       - Identify the most recent clean snapshot
       - Restore to a separate instance
       - Diff against production to identify affected data
       - Selectively restore corrupted data

     Option C: Selective restore (best for targeted corruption)
       - Restore backup to temporary instance
       - Export only affected tables/rows
       - Import into production

  3. VERIFY RECOVERY
     - Row counts match expected values
     - Application smoke tests pass
     - No orphaned records or broken references
     - Users can access their data

  4. POST-MORTEM
     - How did corruption occur?
     - How to prevent recurrence?
     - Was detection fast enough?
     - Was recovery fast enough?
```

#### Scenario 3: Complete Region Failure
```
RECOVERY: Region Failure (disaster recovery)
Severity: CRITICAL
RPO: < 1 minute (cross-region replication)
RTO: < 30 minutes (DNS failover + warm standby)

PROCEDURE:
  1. Detect region failure (monitoring + cloud provider status page)
  2. Activate DR region:
     a. Promote cross-region database replica
     b. Verify file storage is accessible in DR region
     c. Scale up application instances in DR region
     d. Update DNS to point to DR region (TTL should be low: 60s)
  3. Verify DR environment is serving traffic
  4. Communicate to stakeholders: estimated recovery, data loss assessment
  5. Monitor DR environment stability

RETURN TO PRIMARY (when original region recovers):
  1. Verify primary region is stable (wait 24+ hours)
  2. Set up reverse replication (DR → primary)
  3. Verify data consistency between regions
  4. Gradual traffic shift back to primary (canary approach)
  5. Demote DR back to standby mode
```

### Step 7: Disaster Recovery Runbook
Generate a comprehensive runbook document:

```
┌────────────────────────────────────────────────────────────┐
│  DISASTER RECOVERY RUNBOOK                                 │
├────────────────────────────────────────────────────────────┤
│  Last tested: <date>                                       │
│  Next test scheduled: <date>                               │
│  Owner: <team/person>                                      │
│  On-call escalation: <contact chain>                       │
│                                                            │
│  Recovery objectives:                                      │
│    Tier 1 RPO: < 1 min   │  RTO: < 15 min                 │
│    Tier 2 RPO: < 1 hour  │  RTO: < 1 hour                 │
│    Tier 3 RPO: < 24 hour │  RTO: < 4 hours                │
│                                                            │
│  Scenarios covered:                                        │
│    1. Primary database failure      → Page 3               │
│    2. Data corruption               → Page 5               │
│    3. Complete region failure        → Page 8               │
│    4. Ransomware / security breach   → Page 11              │
│    5. Accidental data deletion       → Page 13              │
│    6. Cloud provider outage          → Page 15              │
│                                                            │
│  Backup status:                                            │
│    Database: <HEALTHY | DEGRADED | FAILED>                 │
│    File storage: <HEALTHY | DEGRADED | FAILED>             │
│    Configuration: <HEALTHY | DEGRADED | FAILED>            │
│    Secrets: <HEALTHY | DEGRADED | FAILED>                  │
│                                                            │
│  Last successful restore test: <date> (<result>)           │
│  Last DR failover test: <date> (<result>)                  │
└────────────────────────────────────────────────────────────┘
```

### Step 8: Backup & DR Report

```
┌────────────────────────────────────────────────────────────┐
│  BACKUP & DISASTER RECOVERY REPORT                         │
├────────────────────────────────────────────────────────────┤
│  Data assets inventoried: <N>                              │
│  Backup strategies defined: <N>                            │
│  Recovery procedures documented: <N> scenarios             │
│                                                            │
│  Coverage:                                                 │
│    Tier 1 (critical):    <PROTECTED | GAPS | UNPROTECTED>  │
│    Tier 2 (important):   <PROTECTED | GAPS | UNPROTECTED>  │
│    Tier 3 (operational): <PROTECTED | GAPS | UNPROTECTED>  │
│                                                            │
│  Verification:                                             │
│    Automated checks: <CONFIGURED | PARTIAL | MISSING>      │
│    Last restore test: <date | NEVER>                       │
│    Last DR test: <date | NEVER>                            │
│                                                            │
│  Gaps identified: <N>                                      │
│    1. <gap description and remediation>                    │
│    2. <gap description and remediation>                    │
│                                                            │
│  Verdict: <PROTECTED | PARTIAL | AT RISK>                  │
└────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Save runbook as `docs/dr/<date>-disaster-recovery-runbook.md`
2. Save backup config as `docs/dr/<date>-backup-strategy.md`
3. Commit: `"backup: <scope> — <verdict> (RPO: <target>, RTO: <target>, <N> scenarios)"`
4. If AT RISK: "Critical backup gaps found. Prioritize remediation before the next incident."
5. If PROTECTED: "Backup and DR plan is solid. Schedule quarterly DR tests."

## Key Behaviors

1. **Untested backups are not backups.** A backup you have never restored is a hope, not a plan. Test restores regularly.
2. **RPO and RTO drive everything.** Do not design backup strategy without first defining acceptable data loss and downtime. These numbers come from the business, not from engineering preferences.
3. **Separate backup storage from production.** Backups in the same region, same account, or same failure domain as production are not disaster recovery. Use separate regions and accounts.
4. **Encrypt all backups.** Backups contain your most sensitive data. Encrypt at rest and in transit. Manage keys separately from backup storage.
5. **Automate verification.** Manual backup checks get skipped. Automated verification with alerting catches problems before they become disasters.
6. **Document recovery step by step.** During an incident is not the time to figure out recovery procedures. Runbooks should be usable by anyone on the team, not just the person who designed the system.
7. **Test the full chain.** Backup job runs? Good. Backup file is valid? Better. Full restore works? Best. Application passes smoke tests against restored data? That is a tested backup.

## Example Usage

### Designing backup strategy for a new service
```
User: /godmode:backup We're launching a new payment service with PostgreSQL
      and S3 file storage. Design the backup and DR strategy.

Backup: Let me assess your data assets and design a comprehensive strategy.

DATA ASSET INVENTORY:
  Payment database (PostgreSQL): 20 GB, growing 5 GB/month — CRITICAL
  Payment receipts (S3): 50 GB, growing 3 GB/month — IMPORTANT
  Payment service config: Git-managed — CRITICAL
  Payment encryption keys: Vault — CRITICAL

RECOVERY OBJECTIVES:
  Database: RPO < 1 min, RTO < 15 min (revenue-critical, regulated)
  Receipts: RPO < 1 hour, RTO < 1 hour (required for compliance)
  Config/keys: RPO < 5 min, RTO < 30 min (required for service restart)

BACKUP STRATEGY:
  Database:
    - Synchronous streaming replication to same-region standby
    - Asynchronous replication to DR region
    - Continuous WAL archiving to S3 (60-second segments)
    - Daily full backup to DR region S3 (encrypted, AES-256)
    - Retention: 30 days daily, 7 years monthly (PCI-DSS requirement)

  Receipts:
    - S3 cross-region replication (automatic)
    - S3 versioning enabled (accidental deletion protection)
    - Retention: 7 years (PCI-DSS requirement)

  Config/keys:
    - Git history provides versioned backup for config
    - Vault auto-snapshot every 15 minutes to DR region
    - Unsealing keys in separate AWS account

VERIFICATION:
  Daily: Automated backup file integrity check
  Weekly: Restore sample to test environment
  Monthly: Full restore + application smoke test
  Quarterly: Full DR failover test

Estimated monthly backup cost: $45 (storage + transfer)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full backup and DR strategy design |
| `--inventory` | Data asset inventory only |
| `--rpo-rto` | Define RPO/RTO targets only |
| `--strategy` | Backup strategy design only |
| `--verify` | Backup verification setup only |
| `--runbook` | Generate disaster recovery runbook |
| `--test` | Execute a restore test and report results |
| `--status` | Current backup health status |
| `--audit` | Audit existing backup configuration for gaps |
| `--scenario <type>` | Design recovery for specific scenario (db-failure, corruption, region-down) |

## Auto-Detection

Before prompting the user, automatically detect backup context:

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

For iterative backup verification and gap remediation:

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

```
MECHANICAL CONSTRAINTS — NON-NEGOTIABLE:
1. NEVER consider a backup valid until a restore test has succeeded.
2. NEVER store backups in the same failure domain as production (same region, same account).
3. EVERY backup MUST be encrypted at rest — no exceptions for any data tier.
4. EVERY backup job MUST alert on failure — silent backup failures are the worst kind.
5. EVERY backup MUST have a TTL/retention policy — no infinite storage growth.
6. RPO and RTO MUST be defined BEFORE designing backup strategy — business drives engineering.
7. git commit backup configurations BEFORE testing — baseline for debugging.
8. Automatic revert on regression: if backup config change causes production issues, revert immediately.
9. NEVER skip quarterly DR tests — schedule them and treat them as P1 obligations.
10. Log all backup operations in TSV:
    TIMESTAMP\tASSET\tOPERATION\tSIZE\tDURATION\tSTATUS\tCHECKSUM
```

## Anti-Patterns

- **Do NOT assume backups work without testing.** "We have automated backups" means nothing until you have restored from one.
- **Do NOT store backups in the same failure domain.** Same-region, same-account backups do not protect against region failures.
- **Do NOT skip encryption.** Backup files contain your entire database. Encrypt them. Manage keys separately.
- **Do NOT define RPO/RTO without business input.** These are business decisions with engineering implementation.
- **Do NOT write runbooks only one person can execute.** Recovery must be usable by anyone on-call.
- **Do NOT neglect backup monitoring.** Silent backup failures create false confidence. Alert on every failure.
- **Do NOT treat DR as a one-time project.** Systems change. Review backup strategies quarterly.

## Output Format
Print on completion: `Backup: {asset_count} assets covered. RPO: {rpo}. RTO: {rto}. Last restore test: {last_test_date}. Encryption: {encryption_status}. Cross-region: {cross_region}. Verdict: {verdict}.`

## TSV Logging
Log every backup operation to `.godmode/backup-results.tsv`:
```
timestamp	asset	operation	size	duration_s	status	checksum
2024-01-15T03:00:00Z	postgres-prod	backup	12GB	180	success	sha256:abc123
2024-01-15T03:05:00Z	redis-prod	backup	2GB	30	success	sha256:def456
2024-01-15T04:00:00Z	postgres-prod	restore-test	12GB	300	success	verified
```
Columns: timestamp, asset, operation(backup/restore-test/dr-drill), size, duration_s, status(success/failed/partial), checksum.

## Success Criteria
- RPO and RTO defined with business stakeholder sign-off.
- All critical data assets have automated backup schedules.
- Backups encrypted at rest with managed keys (not hardcoded).
- Backups stored in a separate failure domain (different region, different account).
- Restore test completed successfully within the defined RTO.
- Backup failure alerts configured and verified.
- Retention policy defined and enforced (no infinite storage growth).
- Recovery runbook written and tested by at least two team members.
- Quarterly DR drill scheduled and completed.

## Error Recovery
- **Backup job fails silently**: Configure alerting for every backup job (PagerDuty, Slack, email). Verify alerts are working by intentionally failing a backup. Check monitoring dashboards daily.
- **Restore test fails**: Do not assume the backup is corrupt. Check the restore procedure first. Verify the target environment has sufficient resources. Check for schema version mismatches between backup and restore target.
- **Backup storage costs growing unbounded**: Review retention policy. Delete backups older than the retention period. Use tiered storage (hot → warm → cold) for older backups. Enable lifecycle rules on the storage bucket.
- **Encryption key lost or rotated**: Maintain key escrow or backup of encryption keys in a separate secure location. Document key rotation procedure. Test decryption with the new key before rotating.
- **RPO violated (backup older than allowed)**: Investigate why the scheduled backup did not run. Check for resource contention, network issues, or credential expiration. Run an immediate backup and fix the root cause.
- **DR drill reveals gaps**: Document all gaps found. Create remediation tasks with deadlines. Re-run the drill after fixes are applied. Update the runbook with lessons learned.

## Keep/Discard Discipline
```
After EACH backup configuration or gap remediation:
  1. MEASURE: Run the backup job — does it complete? Is the backup file valid (checksum, header)?
  2. COMPARE: Is coverage better than before? (new asset backed up, verification added, cross-region enabled)
  3. DECIDE:
     - KEEP if: backup completes AND file is valid AND restore test passes (if applicable)
     - DISCARD if: backup fails OR file is corrupt OR restore test fails
  4. COMMIT kept changes. Revert discarded changes before addressing the next gap.
```

## Stuck Recovery
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

DO NOT STOP just because:
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

## Multi-Agent Dispatch
For comprehensive backup and DR setup:
```
DISPATCH parallel agents (one per concern):

Agent 1 (worktree: backup-config):
  - Configure backup jobs for all data assets
  - Set up schedules, retention policies, encryption
  - Scope: backup scripts, cron jobs, cloud backup config
  - Output: Automated backup configuration

Agent 2 (worktree: backup-restore):
  - Write and test restore procedures
  - Create recovery runbooks
  - Scope: restore scripts, runbook documentation
  - Output: Tested restore procedures

Agent 3 (worktree: backup-monitoring):
  - Set up backup monitoring and alerting
  - Configure dashboards for backup status
  - Scope: monitoring config, alert rules
  - Output: Backup monitoring and alerting

MERGE ORDER: config → restore → monitoring
CONFLICT RESOLUTION: config branch owns backup schedules; restore branch owns runbooks
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run backup tasks sequentially: backup configuration, then restore testing, then monitoring setup.
- Use branch isolation per task: `git checkout -b godmode-backup-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
