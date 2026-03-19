# /godmode:backup

Backup strategy design and disaster recovery planning. Inventories data assets, defines RPO/RTO targets, designs tiered backup strategies, automates verification, tests recovery procedures, and generates comprehensive DR runbooks.

## Usage

```
/godmode:backup                                  # Full backup and DR strategy
/godmode:backup --inventory                      # Data asset inventory
/godmode:backup --rpo-rto                        # Define recovery objectives
/godmode:backup --strategy                       # Backup strategy design
/godmode:backup --verify                         # Backup verification setup
/godmode:backup --runbook                        # Generate DR runbook
/godmode:backup --test                           # Execute restore test
/godmode:backup --status                         # Current backup health
/godmode:backup --audit                          # Audit existing backup config
/godmode:backup --scenario db-failure            # Recovery plan for specific scenario
```

## What It Does

1. Inventories all data assets (databases, file storage, caches, configs, secrets)
2. Defines RPO/RTO targets per data tier based on business criticality
3. Designs tiered backup strategies:
   - **Tier 1 (Critical)**: Continuous replication, WAL archiving, daily full backups
   - **Tier 2 (Important)**: Periodic snapshots, cross-region replication
   - **Tier 3 (Operational)**: Daily backups, rebuild-from-source procedures
4. Sets up automated backup verification (integrity checks, test restores)
5. Documents recovery procedures for each failure scenario
6. Generates a disaster recovery runbook usable by any on-call engineer

## Output
- Backup strategy at `docs/dr/<date>-backup-strategy.md`
- DR runbook at `docs/dr/<date>-disaster-recovery-runbook.md`
- Commit: `"backup: <scope> — <verdict> (RPO: <target>, RTO: <target>, <N> scenarios)"`
- Verdict: PROTECTED / PARTIAL / AT RISK

## Next Step
After backup design: `/godmode:comply` to verify backup meets regulatory requirements.
Schedule quarterly DR tests to keep runbooks current.

## Examples

```
/godmode:backup                                  # Full strategy design
/godmode:backup --inventory                      # "What data do we have?"
/godmode:backup --runbook                        # Generate DR runbook
/godmode:backup --test                           # "Test our restore procedure"
/godmode:backup --scenario region-down           # "What if us-east-1 goes down?"
```
