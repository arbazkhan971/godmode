---
name: seed
description: >
  Database seeding, test fixtures, factory patterns,
  fake data generation. Idempotent seed scripts.
---

# Seed -- Database Seeding & Test Data

## Activate When
- `/godmode:seed`, "seed the database", "generate test data"
- "create fixtures", factory patterns (FactoryBot, fishery)
- Fake data generation (Faker.js, Faker Python)
- Data anonymization for production snapshots

## Workflow

### Step 1: Detect Environment
```bash
# Detect ORM and factory libraries
grep -r "prisma\|typeorm\|sequelize\|django\|sqlalchemy" \
  package.json pyproject.toml Gemfile 2>/dev/null
ls prisma/seed.ts db/seeds.rb scripts/seed* 2>/dev/null
grep -r "@faker-js\|faker\|factory_bot\|Bogus" \
  package.json pyproject.toml 2>/dev/null
```
```
SEEDING ENVIRONMENT:
Language: <TS | Python | Go | Ruby | Java>
ORM: <Prisma | Drizzle | SQLAlchemy | ActiveRecord>
Database: <PostgreSQL | MySQL | SQLite | MongoDB>
Existing seeds: <path or "none detected">
Factory lib: <fishery | factory_boy | none>
Faker lib: <@faker-js/faker | Faker Python | none>
```

### Step 2: Factory Pattern
```
Library selection:
  TypeScript: fishery
  Python: factory_boy
  Ruby: FactoryBot
  Go: table-driven builders + gofakeit
  C#: Bogus
  Java: Instancio

Key patterns:
  Base factory with faker defaults + sequence IDs
  Traits for variants (admin, inactive, published)
  build() for in-memory, create() for persisted
  buildList(N) for batches
  Override any field at call site
```

### Step 3: Seed Script Architecture
```
IDEMPOTENT SEED RULES:
1. ALWAYS upsert (insert or update), never plain insert
2. Stable identifiers (slug, email) not auto-increment
3. Dependency order (users before posts)
4. Wrap each group in transaction
5. Log: created vs skipped vs updated
6. Re-runnable: running twice = same result

SEED STRUCTURE:
  faker.seed(42) for determinism
  Phase 1: reference data (roles, categories via upsert)
  Phase 2: core entities (fixed + random users)
  Phase 3: dependent entities (posts, comments)
  Check count vs target, only create delta
```

### Step 4: Relationship Handling
Seed in topological order:
reference -> independent -> first-level deps ->
second-level deps -> M:N joins -> derived data.

Use Pareto distribution: 20% of parents get 80%
of children for realistic associations.

### Step 5: Large Dataset Seeding
```
NEVER insert one row at a time.
Batch size: 500-5000 rows per INSERT.
IF 100K+ rows: streaming or raw COPY (PostgreSQL)
IF bulk loading:
  SET session_replication_role = 'replica'
  (disable FK checks during load)
  After: REINDEX, ANALYZE

Performance thresholds:
  50 rows: <1s (dev seed)
  5K rows: <10s (staging seed)
  100K rows: <60s (demo seed via COPY)
```

### Step 6: Deterministic Seeds
- `faker.seed(42)` = same data every run
- Use sequences instead of random IDs
- Different seeds per environment
- Per-test: reset seed before each suite

### Step 7: Data Anonymization
```
IF production snapshot needed:
  Replace emails: user_N@example.com
  Replace names, phones, addresses: faker
  Remove: credit cards, API keys, tokens, passwords
  Add noise to financial amounts (+-10%)
  Shift dates by random offset
  NEVER copy production without anonymization
```

### Step 8: Cleanup Strategies
```
Truncate cascade: full reset
Delete by marker: DELETE WHERE source = 'seed'
Transaction rollback: BEGIN->seed->test->ROLLBACK
Database drop/create: CI pipelines
Snapshot restore: pg_restore from dump

ENVIRONMENT-AWARE:
  Dev: 50 users, deterministic, minimal
  Staging: 5K users, randomized, weekly reset
  Demo: 200 curated, deterministic
  Production: NEVER seed fake data
```

### Step 9: Commit
Commit: `"seed: add <desc> seeding infrastructure"`

## Key Behaviors
1. **Keep seeds idempotent.** Upsert, never blind insert.
2. **Factories for tests, scripts for environments.**
3. **Seed in dependency order.** Parents first.
4. **Deterministic for development.** faker.seed(42).
5. **Batch insert always.** 100x faster than loops.
6. **Tag seeded data.** @example.com for cleanup.
7. **Never seed production with fake data.**
8. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER seed production with development data.
2. ALWAYS use fixed faker seed for determinism.
3. NEVER use auto-increment IDs as stable refs.
4. ALWAYS use batch inserts. No single-row loops.
5. NEVER include real user data in seed files.
6. ALWAYS make seeds idempotent with upsert.
7. NEVER seed without a transaction.
8. ALWAYS provide --reset for clean-slate option.

## Auto-Detection
```bash
grep -r "prisma\|typeorm\|sequelize\|django" \
  package.json pyproject.toml Gemfile 2>/dev/null
ls prisma/seed.ts db/seeds.rb scripts/seed* 2>/dev/null
```

## TSV Logging
Log to `.godmode/seed-results.tsv`:
`step\tentity\torm\tmethod\tstatus\tdetails`

## Output Format
Print: `Seed: {N} entities, {rows} rows. Idempotent: {yes|no}. Env guard: {active}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
KEEP if: idempotent (re-run safe) AND batch-inserted
  AND dependency order correct
DISCARD if: unique constraint on re-run
  OR FK errors OR single-row loops
```

## Stop Conditions
```
STOP when:
  - All entities seeded idempotently
  - Env guard active, --reset works
  - User requests stop
```
