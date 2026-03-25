---
name: migrate
description: Database migration and schema management.
---

## Activate When
- `/godmode:migrate`, "add a column", "schema change"
- Model/entity file modified needing migration
- "is this migration safe?", "will this break production?"

## Workflow

### 1. Detect Migration Environment
```bash
# Auto-detect ORM/tool
ls prisma/schema.prisma drizzle.config.ts \
  alembic/env.py db/migrate/ 2>/dev/null
```
```
IF prisma/schema.prisma exists: Tool=Prisma, dir=prisma/migrations/
IF drizzle.config.ts exists: Tool=Drizzle, dir=drizzle/
IF alembic/env.py exists: Tool=Alembic
IF db/migrate/ exists: Tool=Rails
IF knexfile exists: Tool=Knex
```

### 2. Analyze Schema Change
```
SCHEMA CHANGE REQUEST:
Type:    CREATE|ALTER|DROP TABLE, ADD|DROP COLUMN,
         RENAME, CHANGE TYPE, ADD INDEX/CONSTRAINT
Tables:  <affected tables>
Source:  <user request | model diff | drift detection>
```
```bash
# Prisma diff
npx prisma migrate diff \
  --from-migrations prisma/migrations \
  --to-schema-datamodel prisma/schema.prisma
# Django dry-run
python manage.py makemigrations --dry-run --verbosity 2
```

### 3. Risk Assessment
```
Risk: SAFE | CAUTION | DANGEROUS | BREAKING
Reversible: YES | PARTIAL | NO
Data loss: NONE | POTENTIAL | GUARANTEED
Lock duration: NONE | ROW | TABLE (estimate seconds)

SAFE: ADD COLUMN with DEFAULT/NULLABLE, ADD INDEX
  CONCURRENTLY, ADD TABLE
CAUTION: ADD COLUMN NOT NULL without DEFAULT,
  RENAME COLUMN, ADD INDEX on >1M rows
DANGEROUS: DROP COLUMN, CHANGE TYPE with data loss
BREAKING: DROP TABLE, RENAME TABLE with live traffic
```

IF risk >= DANGEROUS: use expand-contract pattern.
IF table > 10M rows: use online DDL tools.
IF lock estimate > 5 seconds: require DBA approval.

### 4. Expand-Contract (BREAKING changes)
```
PHASE 1 — EXPAND: Add new alongside old, write BOTH,
  backfill, verify.
PHASE 2 — CONTRACT: Read from new, stop writing old,
  drop old after 2-week stability.
```

### 5. Generate Migration
Every migration MUST include:
1. Up migration (forward change)
2. Down migration (exact rollback)
3. Data preservation guards
4. Idempotency guards

```bash
# Prisma
npx prisma migrate dev --name add_user_role
# Django
python manage.py makemigrations
# Rails
bin/rails generate migration AddRoleToUsers
```

### 6. Validate Before Applying
```bash
# Syntax check
npx prisma validate  # or python manage.py check
# Rollback test: UP -> DOWN -> UP (idempotency)
# Data preservation: row count before == after
# Lock estimation for large tables:
```
```sql
SELECT pg_size_pretty(pg_total_relation_size('table'));
SELECT reltuples::bigint FROM pg_class
  WHERE relname = 'table';
```
```
< 100K rows: locks negligible
100K-1M: ADD COLUMN ~seconds, INDEX ~minutes
1M-10M: use CONCURRENTLY
10M-100M: use pt-online-schema-change / gh-ost
> 100M: DBA review + maintenance window
```

### 7. Apply and Report
```
PRE-APPLY: validated, rollback tested, data verified,
  lock acceptable, app code compatible, backup exists.
```
Print: `Migrate: {table}.{change} — risk: {level}.
  Rollback: {tested|untested}. Data: {preserved}.`

## Quality Targets
- Target: <5s per migration execution
- Target: 0 data loss during migration rollback
- Lock timeout: <5s for DDL operations

## Hard Rules
1. NEVER generate migration without detecting the tool.
2. EVERY migration MUST have matching DOWN/rollback.
3. NEVER combine unrelated changes in one migration.
4. NEVER ALTER large tables without lock estimation.
5. ALWAYS test full cycle: UP -> DOWN -> UP.

## TSV Logging
Append `.godmode/migrate-results.tsv`:
```
timestamp	migration	orm	direction	status	details
```

## Keep/Discard
```
KEEP if: UP clean, DOWN reverses, rows preserved,
  tests pass, lock < 5s or approved.
DISCARD if: DOWN fails, data loss, NOT NULL without
  DEFAULT, lock > 5s without approval.
```

## Stop Conditions
```
STOP when FIRST of:
  - UP clean + DOWN reverses + tests pass
  - Data preserved + seeds updated
  - Lock estimated for >1M row tables
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Fails on data | Check NOT NULL, type casts, add DEFAULT |
| DOWN fails | Fix before proceeding, test on copy |
| ORM not detected | Check package.json, requirements.txt |
