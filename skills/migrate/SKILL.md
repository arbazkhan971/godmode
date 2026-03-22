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

IF ormconfig.ts OR data-source.ts with TypeORM imports:
  Tool = TypeORM
  Migration dir = src/migrations/

IF .sequelizerc OR config/config.json with Sequelize:
  Tool = Sequelize
  Migration dir = migrations/

IF manage.py AND <app>/models.py:
  Tool = Django
  Migration dir = <app>/migrations/

IF Gemfile with 'rails' AND db/migrate/:
  Tool = Rails
  Migration dir = db/migrate/

IF migrate.go OR golang-migrate config:
  Tool = Go-migrate
  Migration dir = migrations/ OR db/migrations/

IF alembic/ OR alembic.ini:
  Tool = Alembic
  Migration dir = alembic/versions/

IF flyway.conf OR sql/V*__*.sql:
  Tool = Flyway
  Migration dir = sql/

IF knexfile.ts OR knexfile.js:
  Tool = Knex
  Migration dir = migrations/

ELSE:
  Tool = Raw SQL
  Migration dir = <ask user or scan for .sql files>
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

# Rails
bin/rails db:migrate:status

# TypeORM
npx typeorm schema:log

# Alembic
alembic check
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
  - ADD INDEX on large table (may lock)
  - RENAME COLUMN (needs code deployment coordination)
  - CHANGE COLUMN TYPE (if implicit cast safe)

DANGEROUS (requires explicit plan):
  - DROP COLUMN (data loss — is anything still reading it?)
  - DROP TABLE (data loss — is anything still referencing it?)
  - CHANGE COLUMN TYPE (if data truncation possible)
  - RENAME TABLE (breaks all queries referencing old name)

BREAKING (must use expand-contract pattern):
  - Any change to a column that is actively read/written by running code
  - Any removal of a column still referenced in application queries
  - Any type change that could fail for existing data
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
  2. Stop writing to old column/table
  3. Remove old column/table
  4. Clean up dual-write code
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
    ]

    operations = [
        migrations.AddField(
            model_name='user',
            name='role',
            field=models.CharField(max_length=50, default='user'),
        ),
    ]
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
ALTER TABLE users DROP COLUMN IF EXISTS role;
```

#### Knex Example
```javascript
exports.up = function(knex) {
  return knex.schema.alterTable('users', (table) => {
    table.string('role', 50).notNullable().defaultTo('user');
    table.index('role', 'idx_users_role');
  });
};

exports.down = function(knex) {
  return knex.schema.alterTable('users', (table) => {
    table.dropIndex('role', 'idx_users_role');
    table.dropColumn('role');
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
        );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(
            `ALTER TABLE "users" DROP COLUMN "role"`
        );
    }
}
```

#### Alembic Example
```python
"""add user role

Revision ID: a1b2c3d4e5f6
Revises: 9z8y7x6w5v4u
Create Date: 2025-01-15 10:30:00.000000
"""
from alembic import op
import sqlalchemy as sa

revision = 'a1b2c3d4e5f6'
down_revision = '9z8y7x6w5v4u'

def upgrade() -> None:
    op.add_column('users', sa.Column('role', sa.String(50), nullable=False, server_default='user'))

def downgrade() -> None:
    op.drop_column('users', 'role')
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
python manage.py migrate --plan

# Rails
bin/rails db:migrate:status

# Alembic
alembic check
alembic heads  # Ensure single head (no branch conflicts)

# Flyway
flyway validate

# Generic SQL
# Parse SQL for syntax errors using database-specific tool
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
python manage.py migrate <app> <previous_migration_name>  # rollback
python manage.py migrate <app> <migration_name>           # re-apply

# Rails
bin/rails db:migrate
bin/rails db:rollback STEP=1
bin/rails db:migrate

# Alembic
alembic upgrade head
alembic downgrade -1
alembic upgrade head

# Knex
npx knex migrate:latest
npx knex migrate:rollback
npx knex migrate:latest
```

#### 5c: Data Preservation Check
For ALTER and DROP operations, verify no data loss:
```sql
-- Before migration: snapshot row count and sample data
SELECT COUNT(*) FROM <table>;
SELECT * FROM <table> LIMIT 5;

-- After migration UP: verify data preserved
SELECT COUNT(*) FROM <table>;  -- same count
SELECT * FROM <table> LIMIT 5; -- data intact, new column has default

-- After migration DOWN: verify data restored
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
FROM information_schema.tables
WHERE table_name = '<table>';
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

APPLY COMMAND:
<tool-specific command>

POST-APPLY VERIFICATION:
[ ] Migration shows as applied in migration history
[ ] Schema matches expected state
[ ] Application starts and responds correctly
[ ] Key queries still work (smoke test)
[ ] No unexpected lock contention or performance degradation
```

### Step 7: Report and Transition

```
+------------------------------------------------------------+
|  MIGRATION -- <table>.<change>                              |
+------------------------------------------------------------+
|  Tool:          <detected tool>                             |
|  Database:      <database engine>                           |
|  Change:        <description>                               |
|  Risk:          <SAFE | CAUTION | DANGEROUS | BREAKING>     |
|  Files created: <list of migration files>                   |
+------------------------------------------------------------+
|  Validation:                                                |
|  Schema valid:     YES/NO                                   |
|  Rollback tested:  YES/NO                                   |
|  Data preserved:   YES/NO                                   |
|  Lock estimate:    <duration>                               |
+------------------------------------------------------------+
|  Status: <APPLIED | READY TO APPLY | NEEDS REVIEW>         |
+------------------------------------------------------------+
```

Commit: `"migrate: <table>.<change> -- <risk level>"`

## Key Behaviors

1. **Detect, don't assume.** Always scan the project to find the migration tool. Never assume Prisma just because it's a Node project.
2. **Backward compatibility is non-negotiable.** Every migration must be checked for backward compatibility. A migration that breaks running code is a production outage.
3. **Rollbacks are mandatory.** Every UP must have a matching DOWN. If a migration cannot be rolled back (e.g., DROP COLUMN with data loss), document this explicitly and require confirmation.
4. **Data preservation is sacred.** Existing data must survive the migration. If data transformation is needed, include a data migration step with verification.
5. **Lock awareness saves production.** Estimate lock duration for every DDL operation on tables with significant data. Suggest CONCURRENTLY or online DDL when needed.
6. **One concern per migration.** Don't combine unrelated schema changes in a single migration. Each migration should be independently reversible.
7. **Idempotency prevents failures.** Use IF NOT EXISTS, IF EXISTS, and conditional guards. A migration that crashes halfway through and can't be re-run is a nightmare.
8. **Test in dev, verify in staging, apply in prod.** Never apply an untested migration to production.
9. **Name migrations descriptively.** `add_role_to_users` not `migration_042`. Future developers need to understand the change from the filename.
10. **Handle seeds and fixtures.** When schema changes affect seed data or test fixtures, update them in the same migration.

## Example Usage

### Adding a column
```
User: /godmode:migrate Add a "role" column to the users table with default "member"

Migrate: Detecting environment...

MIGRATION ENVIRONMENT:
Tool:           Prisma
Database:       PostgreSQL
Migration dir:  prisma/migrations/
Current head:   20250101_add_user_avatar
Pending:        0

SCHEMA CHANGE REQUEST:
Type:         ADD COLUMN
Tables:       users
Columns:      role (String, default: "member")

RISK ASSESSMENT:
Level:          SAFE
Reversible:     YES
Data loss risk: NONE
Downtime:       ZERO
Lock duration:  < 1 second (users table: 12,400 rows)

Generating migration...
- Updated prisma/schema.prisma: added `role String @default("member")`
- Generated: prisma/migrations/20250115_add_user_role/migration.sql

Validating...
  Schema valid:     YES
  Rollback tested:  YES (prisma migrate reset in dev)
  Data preserved:   YES (12,400 rows retained, role = "member" for all)

Apply now? [Y/n]
```

### Dangerous rename with expand-contract
```
User: /godmode:migrate Rename the "email" column to "email_address" in users

Migrate: Detecting environment...

RISK ASSESSMENT:
Level:          BREAKING
Reversible:     PARTIAL
Data loss risk: NONE (but breaks all queries referencing "email")
Downtime:       POSSIBLE if deployed without code coordination

This is a BREAKING change. I recommend the expand-contract pattern:

PHASE 1 — EXPAND (this migration):
  1. Add column "email_address" (nullable)
  2. Backfill: UPDATE users SET email_address = email
  3. Add NOT NULL constraint after backfill
  4. Add unique index on email_address

Deploy code that writes to BOTH "email" and "email_address".

PHASE 2 — CONTRACT (separate migration, after Phase 1 is stable):
  1. Switch reads to "email_address"
  2. Stop writing to "email"
  3. Drop "email" column

Generate Phase 1 migration? [Y/n]
```

### Rolling back a failed migration
```
User: /godmode:migrate --rollback The last migration broke the app

Migrate: Checking migration history...

Last applied: 20250115_add_payment_status
Status:       APPLIED but application errors detected

Rolling back...
  bin/rails db:rollback STEP=1
  Removed: add_payment_status migration changes
  Schema restored to: 20250114_add_invoice_table

Verification:
  Schema matches pre-migration state: YES
  Application starts: YES
  Tests pass: YES

Rollback successful. The migration file is still present at
db/migrate/20250115_add_payment_status.rb for debugging.

Investigate the failure with /godmode:debug, then fix and re-apply.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive migration workflow: detect, generate, validate |
| `--generate` | Generate migration file without applying |
| `--validate` | Validate pending migrations without applying |
| `--apply` | Apply all pending migrations |
| `--rollback` | Roll back the last applied migration |
| `--rollback <N>` | Roll back the last N migrations |
| `--status` | Show migration status (applied, pending, failed) |
| `--diff` | Show schema diff between code and database |
| `--dry-run` | Show what migration would do without generating files |
| `--sql` | Output raw SQL regardless of ORM (useful for review) |
| `--seed` | Run seed files after migration |
| `--force` | Skip confirmation prompts (use with caution) |
| `--expand-contract` | Force expand-contract pattern for the change |
| `--check-compat` | Run backward compatibility check only |
| `--lock-estimate` | Estimate lock duration for pending migrations |

## Auto-Detection

```
ON file_change in models/ OR entities/ OR schema:
  detected_tool = detect_migration_tool()  # See Step 1 detection rules
  IF detected_tool != null:
    diff = compute_schema_diff(detected_tool)
    IF diff.has_changes:
      SUGGEST "Schema change detected in {changed_file}. Run /godmode:migrate to generate migration."

ON startup:
  IF prisma/schema.prisma exists:
    pending = run("npx prisma migrate status")
    IF pending.has_unapplied:
      WARN "Prisma has {N} unapplied migrations. Run /godmode:migrate --apply."

  IF alembic/ exists:
    heads = run("alembic heads")
    IF heads.count > 1:
      WARN "Alembic has multiple heads (branch conflict). Run /godmode:migrate --status."

  IF db/migrate/ exists AND Gemfile has 'rails':
    pending = run("bin/rails db:migrate:status")
    IF pending.has_down:
      WARN "Rails has pending migrations. Run /godmode:migrate --apply."
```

## Iterative Migration Protocol

```
WHEN applying a batch of migrations OR multi-phase schema change:

current_migration = 0
total_migrations = len(pending_migrations)
applied = []
failed = []

WHILE current_migration < total_migrations:
  migration = pending_migrations[current_migration]

  1. VALIDATE migration syntax (tool-specific validation)
  2. ASSESS risk level (SAFE/CAUTION/DANGEROUS/BREAKING)
  3. ESTIMATE lock duration for affected tables
  4. IF risk >= DANGEROUS:
       REQUIRE explicit user confirmation
       IF expand-contract needed: split into phases

  5. APPLY migration UP
  6. VERIFY:
     - Schema matches expected state
     - Row counts preserved
     - Application can start

  IF verification_fails:
    ROLLBACK migration DOWN
    failed.append(migration)
    HALT "Migration {migration.name} failed verification. Rolled back."
    BREAK
  ELSE:
    applied.append(migration)
    current_migration += 1

  REPORT "{current_migration}/{total_migrations} migrations applied"

FINAL: Report all applied migrations and any failures
```

## Multi-Agent Dispatch

```
WHEN performing a large-scale schema migration (multiple tables, expand-contract):

DISPATCH parallel agents in worktrees:

  Agent 1 (migration-generator):
    - Generate migration files for all schema changes
    - Ensure proper ordering (tables before foreign keys)
    - Include UP and DOWN for every migration
    - Output: migration files in tool-specific format

  Agent 2 (validation):
    - Test each migration: UP -> verify -> DOWN -> verify -> UP
    - Check data preservation (row counts, sample data)
    - Estimate lock duration for each DDL operation
    - Output: validation report per migration

  Agent 3 (application-code):
    - Update model/entity files to match new schema
    - Update queries and repositories for schema changes
    - Handle dual-read/dual-write for expand-contract phases
    - Output: updated application code

  Agent 4 (seed-and-fixture):
    - Update seed data for new schema
    - Update test fixtures for new columns/tables
    - Verify test suite passes with migrated schema
    - Output: updated seeds + fixtures + test results

MERGE:
  - Verify migration files match application code changes
  - Verify seeds and fixtures work with migrated schema
  - Verify all validation checks passed
  - Run full test suite
```

## HARD RULES

```
1. NEVER generate a migration without first detecting the project's migration tool.
   Wrong tool = wrong syntax = broken migration.

2. EVERY migration MUST have a matching DOWN/rollback. If a migration cannot
   be rolled back, document this explicitly and require user confirmation.

3. NEVER combine unrelated schema changes in one migration file.
   One concern per migration. Independent rollbacks require independent files.

4. NEVER apply a migration to production without testing rollback in dev/staging.
   UP then DOWN then UP must succeed cleanly.

5. ALWAYS check lock duration before applying DDL on tables > 100K rows.
   Use CONCURRENTLY or online DDL tools for large tables.

6. NEVER add a NOT NULL column without a DEFAULT to a table with existing rows.
   This will fail on every database engine.

7. NEVER rename or drop a column without the expand-contract pattern
   if the application is actively reading/writing that column.

8. ALWAYS preserve existing data. A migration that loses data without
   explicit user confirmation is a production incident.
```

## TSV Logging
After each workflow step, append a row to `.godmode/migrate-results.tsv`:
```
STEP\tMIGRATION\tORM\tDIRECTION\tSTATUS\tDETAILS
1\t20240115_add_user_roles\tprisma\tup\tgenerated\tADD COLUMN role enum('admin','user') DEFAULT 'user'
2\t20240115_add_user_roles\tprisma\tdown\ttested\trollback verified, column dropped cleanly
3\t20240115_add_user_roles\tprisma\tup\tapplied\tdev database migrated in 0.3s
4\tapplication-code\t-\t-\tupdated\tUser model + API routes updated for role field
```
Print final summary: `Migration: {name}, ORM: {tool}, direction: {up}. Tables affected: {N}. Backward compatible: {yes/no}. Rollback tested: {yes/no}. App code updated: {yes/no}.`

## Success Criteria
All of these must be true before marking the task complete:
1. Migration generated by the detected ORM tool (not hand-written SQL unless ORM is absent).
2. UP migration applies cleanly on a database with existing data (not just empty schema).
3. DOWN migration fully reverses the UP (verified by: apply UP, apply DOWN, diff schema = zero changes).
4. Application code compiles and passes tests with the new schema.
5. No backward-incompatible changes without expand-contract pattern (renames, drops, type changes).
6. Lock duration estimated for large tables (>1M rows) and documented if >5 seconds.
7. Seed files and test fixtures updated to include new columns/tables.
8. Migration committed with descriptive name matching convention: `{timestamp}_{action}_{target}`.

## Error Recovery
| Failure | Action |
|---------|--------|
| Migration fails on existing data | Check for NOT NULL without DEFAULT, type cast errors, or constraint violations. Add DEFAULT or backfill in a separate data migration. |
| DOWN migration fails | Fix the DOWN before proceeding. A migration without working rollback is not shippable. Test DOWN on a copy of the UP-migrated database. |
| ORM not detected | Ask user which ORM/migration tool. Never guess. Check `package.json`, `requirements.txt`, `Gemfile`, `go.mod` for ORM dependencies. |
| Lock timeout on large table | Use online DDL: `pt-online-schema-change` (MySQL), `CREATE INDEX CONCURRENTLY` (Postgres), or expand-contract pattern. |
| Conflicting migration versions | Run `prisma migrate status` / `alembic heads` / `rails db:migrate:status` to detect. Merge migration files or create a merge migration. |
| Tests fail after migration | Check fixture files for missing new columns. Update factories/fixtures. Run `prisma generate` or equivalent to regenerate client. |

## Anti-Patterns

- **Do NOT generate migrations without detecting the tool first.** Prisma migration in a Django project is worse than nothing.
- **Do NOT apply migrations without rollback testing.** No escape hatch in production.
- **Do NOT combine unrelated changes.** Independent rollback requires independent files.
- **Do NOT skip backward compatibility checks.** Even ADD COLUMN can break on MySQL table rewrites.
- **Do NOT rename or drop columns without expand-contract.** Direct renames break running instances.
- **Do NOT ignore lock duration on large tables.** 10-minute table lock = 10-minute outage.
- **Do NOT put business logic in migrations.** Use separate data migrations for complex transformations.
- **Do NOT forget to update seeds and fixtures.** NOT NULL columns break fixtures missing the new column.
- **Do NOT assume the database is empty.** Always account for existing data.

## Keep/Discard Discipline

After each migration pass, evaluate:
- **KEEP** if: UP applies cleanly on a database with existing data, DOWN fully reverses the UP (zero schema diff), row counts preserved, application starts and passes tests, lock duration within acceptable range.
- **DISCARD** if: DOWN migration fails, data loss detected, NOT NULL without DEFAULT on populated table, backward-incompatible change without expand-contract pattern, or lock duration exceeds 5 seconds on large table without user confirmation.
- Test the full cycle (UP -> verify -> DOWN -> verify -> UP) before committing.
- Revert immediately if rollback test fails — a migration without working rollback is not shippable.

## Stop Conditions

Stop the migrate skill when:
1. UP migration applies cleanly and DOWN migration fully reverses it (verified by schema diff = zero).
2. Application code compiles and all tests pass with the new schema.
3. Row counts and sample data preserved after migration (no data loss).
4. Seed files and test fixtures updated for new columns/tables.
5. Lock duration estimated and documented for tables > 1M rows.

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run migration tasks sequentially: migration generation, then validation, then application code updates.
- Use branch isolation per task: `git checkout -b godmode-migrate-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
