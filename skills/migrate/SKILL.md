---
name: migrate
description: |
  Database migration and schema management skill. Activates when a developer needs to create, validate, apply, or roll back database schema changes. Detects the project's ORM/migration tool (Prisma, Drizzle, TypeORM, Sequelize, Django, Rails, Go-migrate, Alembic, Flyway, Liquibase, Knex, or raw SQL) and generates idiomatic migrations with backward compatibility checks, data preservation guards, and rollback strategies. Triggers on: /godmode:migrate, "add a column", "change the schema", "create a migration", "database migration", "schema change", or when code changes imply model/entity modifications.
---

# Migrate -- Database Migration & Schema Management

## When to Activate
- User invokes `/godmode:migrate`
- User says "add a column," "change the schema," "create a migration," "rename table"
- User modifies a model/entity file and needs a corresponding migration
- User asks "is this migration safe?" or "will this break production?"
- Godmode orchestrator detects schema drift between code and database
- User needs to roll back a bad migration or recover from a failed deploy

## Workflow

### Step 1: Detect Migration Environment

Identify the project's ORM, migration tool, database engine, and current migration state:

```
MIGRATION ENVIRONMENT:
Tool:           <Prisma | Drizzle | TypeORM | Sequelize | Django | Rails | Go-migrate | Alembic | Flyway | Liquibase | Knex | Raw SQL>
Database:       <PostgreSQL | MySQL | SQLite | MongoDB | SQL Server | CockroachDB | PlanetScale>
Detection:      <how detected — prisma/schema.prisma, alembic/env.py, db/migrate/, etc.>
Migration dir:  <path to migration files>
Current head:   <latest applied migration name/version>
Pending:        <number of unapplied migrations, if any>
Schema file:    <path to schema definition, if declarative>
```
Detection rules:
```
IF prisma/schema.prisma OR schema.prisma exists:
  Tool = Prisma
  Migration dir = prisma/migrations/

IF drizzle.config.ts OR drizzle/ exists:
  Tool = Drizzle
  Migration dir = drizzle/ OR drizzle/migrations/

  ...
```

### Step 2: Analyze Schema Change Request

Determine what schema changes are needed:

```
SCHEMA CHANGE REQUEST:
Type:         <CREATE TABLE | ALTER TABLE | DROP TABLE | ADD COLUMN | DROP COLUMN |
               RENAME COLUMN | CHANGE TYPE | ADD INDEX | ADD CONSTRAINT |
               ADD RELATION | DATA MIGRATION | COMPOSITE>
Tables:       <affected tables/collections>
Columns:      <affected columns/fields>
Description:  <plain-language description of the change>
Source:        <user request | model diff | schema drift detection>
```
If the change originates from a model file modification, diff the model against the current schema:
```bash
# Prisma
npx prisma migrate diff --from-migrations prisma/migrations --to-schema-datamodel prisma/schema.prisma

# Django
python manage.py makemigrations --dry-run --verbosity 2

```

### Step 3: Backward Compatibility Assessment

Before generating any migration, assess risk. This is the most critical step.

#### Risk Classification

```
RISK ASSESSMENT:
Level:          <SAFE | CAUTION | DANGEROUS | BREAKING>
Reversible:     <YES | PARTIAL | NO>
Data loss risk: <NONE | POTENTIAL | CERTAIN>
Downtime:       <ZERO | BRIEF | EXTENDED>
Lock duration:  <NONE | ROW | TABLE — estimate in seconds>
```
Risk rules:
```
SAFE (apply freely):
  - ADD COLUMN with DEFAULT or NULLABLE
  - ADD INDEX CONCURRENTLY
  - ADD TABLE
  - ADD CONSTRAINT (not on huge tables)

CAUTION (review carefully):
  - ADD COLUMN NOT NULL without DEFAULT (needs backfill)
  ...
```

#### Expand-Contract Pattern (for DANGEROUS/BREAKING changes)

When a change is BREAKING, split it into phases:

```
PHASE 1 — EXPAND (deploy first):
  1. Add new column/table alongside old one
  2. Deploy code that writes to BOTH old and new
  3. Backfill new column/table from old data
  4. Verify new column has correct data

PHASE 2 — CONTRACT (deploy after Phase 1 is stable):
  1. Deploy code that reads from new column/table
  ...
```
### Step 4: Generate Migration

Generate an idiomatic migration for the detected tool. Every migration MUST include:

1. **Up migration** -- the forward change
2. **Down migration** -- the exact rollback
3. **Data preservation** -- handle existing data
4. **Idempotency guards** -- safe to run twice

#### Prisma Example
```prisma
// schema.prisma change:
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  role      String   @default("user")  // NEW COLUMN
}
```
```bash
npx prisma migrate dev --name add_user_role
```

#### Django Example
```python
# Generated migration
from django.db import migrations, models

class Migration(migrations.Migration):
    dependencies = [
        ('users', '0012_previous_migration'),
```

#### Rails Example
```ruby
class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :string, default: 'user', null: false
  end
end
```

#### Raw SQL Example
```sql
-- UP
ALTER TABLE users ADD COLUMN role VARCHAR(50) NOT NULL DEFAULT 'user';
CREATE INDEX idx_users_role ON users (role);

-- DOWN
DROP INDEX IF EXISTS idx_users_role;
```

#### Knex Example
```javascript
exports.up = function(knex) {
  return knex.schema.alterTable('users', (table) => {
    table.string('role', 50).notNullable().defaultTo('user');
    table.index('role', 'idx_users_role');
  });
};
```

#### Go-migrate Example
```sql
-- 000002_add_user_role.up.sql
ALTER TABLE users ADD COLUMN role VARCHAR(50) NOT NULL DEFAULT 'user';

-- 000002_add_user_role.down.sql
ALTER TABLE users DROP COLUMN role;
```

#### TypeORM Example
```typescript
import { MigrationInterface, QueryRunner } from "typeorm";

export class AddUserRole1700000000000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(
            `ALTER TABLE "users" ADD "role" varchar(50) NOT NULL DEFAULT 'user'`
```

#### Alembic Example
```python
"""add user role

Revision ID: a1b2c3d4e5f6
Revises: 9z8y7x6w5v4u
Create Date: 2025-01-15 10:30:00.000000
"""
```

### Step 5: Validate Migration Before Applying

Run a comprehensive validation suite:

#### 5a: Syntax and Schema Validation
```bash
# Prisma
npx prisma validate
npx prisma migrate diff --from-migrations prisma/migrations --to-schema-datamodel prisma/schema.prisma

# Django
python manage.py makemigrations --check
```

#### 5b: Rollback Test (Critical)
```
1. Apply migration UP      → verify schema matches expected state
2. Apply migration DOWN    → verify schema returns to previous state
3. Apply migration UP again → verify it still works (idempotency)
```

For each tool:
```bash
# Prisma
npx prisma migrate deploy
npx prisma migrate reset  # WARNING: destroys data, dev only

# Django
python manage.py migrate <app> <migration_name>
```

#### 5c: Data Preservation Check
For ALTER and DROP operations, verify no data loss:
```sql
-- Before migration: snapshot row count and sample data
SELECT COUNT(*) FROM <table>;
SELECT * FROM <table> LIMIT 5;

-- After migration UP: verify data preserved
SELECT COUNT(*) FROM <table>;  -- same count
```

#### 5d: Lock Duration Estimation
For large tables, estimate lock time:
```sql
-- PostgreSQL: check table size
SELECT pg_size_pretty(pg_total_relation_size('<table>'));
SELECT reltuples::bigint AS row_estimate FROM pg_class WHERE relname = '<table>';

-- MySQL: check table size
SELECT table_rows, data_length, index_length
```

Lock duration guidelines:
```
< 100K rows:    Locks are negligible
100K - 1M rows: ADD COLUMN ~seconds, ADD INDEX ~seconds to minutes
1M - 10M rows:  ADD COLUMN ~seconds, ADD INDEX ~minutes (use CONCURRENTLY)
10M - 100M rows: Use online DDL tools (pt-online-schema-change, gh-ost)
> 100M rows:    Requires DBA review and maintenance window planning
```

### Step 6: Apply Migration

Apply with safety nets:

```
PRE-APPLY CHECKLIST:
[ ] Migration validated (Step 5)
[ ] Rollback tested (Step 5b)
[ ] Data preservation verified (Step 5c)
[ ] Lock duration acceptable (Step 5d)
[ ] Application code compatible with BOTH old and new schema
[ ] Backup taken (or point-in-time recovery available)

  ...
```
### Step 7: Report and Transition
Print: `MIGRATION: {table}.{change}. Tool: {tool}. Risk: {level}. Rollback: {tested|untested}.`
Commit: `"migrate: <table>.<change> -- <risk level>"`

## Key Behaviors
1. **Detect, don't assume.** Scan for the migration tool. Never assume.
2. **Backward compatibility non-negotiable.** Breaking running code = outage.
3. **Rollbacks mandatory.** Every UP needs matching DOWN.
4. **Data preservation sacred.** Existing data must survive.
## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive migration workflow: detect, generate, validate |
| `--generate` | Generate migration file without applying |
| `--validate` | Validate pending migrations without applying |

## Auto-Detection
```
ON file_change in models/entities/schema: detect tool, compute diff, suggest if changes found.
ON startup: check for pending migrations, suggest if any.
```
## HARD RULES

```
1. NEVER generate a migration without first detecting the project's migration tool.
   Wrong tool = wrong syntax = broken migration.

2. EVERY migration MUST have a matching DOWN/rollback. If a migration cannot
   be rolled back, document this explicitly and require user confirmation.

3. NEVER combine unrelated schema changes in one migration file.
   One concern per migration. Independent rollbacks require independent files.
  ...
```
## TSV Logging
Append to `.godmode/migrate-results.tsv`:
```
STEP\tMIGRATION\tORM\tDIRECTION\tSTATUS\tDETAILS
```
Print final summary: `Migration: {name}, ORM: {tool}, direction: {up}. Tables affected: {N}. Backward compatible: {yes/no}. Rollback tested: {yes/no}. App code updated: {yes/no}.`

## Success Criteria
1. ORM-generated migration (not hand-written SQL unless no ORM). UP applies on existing data.
2. DOWN fully reverses UP (schema diff = zero). App compiles and tests pass.
3. No backward-incompatible changes without expand-contract. Lock estimated for >1M row tables.
4. Seeds/fixtures updated. Commit name: `{timestamp}_{action}_{target}`.

## Error Recovery
- **Fails on existing data**: Check NOT NULL without DEFAULT, type casts, constraints. Add DEFAULT or backfill separately.
- **DOWN fails**: Fix before proceeding. Test on copy of UP-migrated database.
- **ORM not detected**: Ask user. Check package.json, requirements.txt, Gemfile, go.mod.

## Keep/Discard Discipline
```
KEEP if: UP applies cleanly, DOWN reverses fully, row counts preserved, tests pass.
DISCARD if: DOWN fails, data loss, NOT NULL without DEFAULT, lock > 5s without approval.
Test full cycle (UP -> DOWN -> UP) before committing.
```

## Autonomy
Never ask to continue. Loop autonomously. Loop until target or budget. Never pause. Measure before/after. Guard: test_cmd && lint_cmd. On failure: git reset --hard HEAD~1.

## Stop Conditions
1. UP applies cleanly, DOWN reverses (schema diff = zero). Tests pass.
2. Data preserved. Seeds/fixtures updated. Lock estimated for >1M row tables.

## Output Format
Print: `Migrate: {table}.{change} — risk: {SAFE|CAUTION|DANGEROUS|BREAKING}. Rollback: {tested|untested}. Data preserved: {yes|no}. Status: {DONE|PARTIAL}.`
