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

1. **Backups that are not tested are not backups.** A backup you have never restored is a hope, not a plan. Test restores regularly.
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

## Anti-Patterns

- **Do NOT assume backups work without testing.** "We have automated backups configured" means nothing until you have successfully restored from one. Test regularly.
- **Do NOT store backups in the same failure domain.** Same-region, same-account backups do not protect against region failures or account compromise. Use separate regions and accounts.
- **Do NOT skip encryption.** Backup files contain your entire database — every user's data, every secret. Encrypt them. Manage keys separately.
- **Do NOT define RPO/RTO without business input.** Engineering cannot decide acceptable data loss alone. These are business decisions with engineering implementation.
- **Do NOT write runbooks that only one person can execute.** Recovery procedures must be usable by anyone on the on-call rotation. Test with different team members.
- **Do NOT neglect backup monitoring.** A silently failing backup job is worse than no backup — it creates false confidence. Alert on every failure, verify every success.
- **Do NOT treat DR as a one-time project.** Systems change. New data stores are added. Backup strategies must evolve with the system. Review quarterly.
