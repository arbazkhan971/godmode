---
name: seed
description: Database seeding, test fixtures, factory patterns, fake data generation. Use when user mentions seed data, fixtures, factories, test data, Faker, FactoryBot, database population.
---

# Seed -- Database Seeding & Test Data Generation

## When to Activate
- User invokes `/godmode:seed`
- User says "seed the database", "generate test data", "create fixtures"
- User asks about factory patterns (FactoryBot, fishery, factory_boy, Bogus)
- User needs fake data generation (Faker.js, Faker Python, go-faker)
- User needs idempotent seed scripts or environment-aware seeding
- User needs data anonymization for production snapshots

## Workflow

### Step 1: Detect Seeding Environment

```
SEEDING ENVIRONMENT:
Language: <TS | Python | Go | Ruby | Java | C# | PHP>
ORM/DAL: <Prisma | Drizzle | TypeORM | SQLAlchemy | Django ORM | GORM | ActiveRecord | Eloquent>
Database: <PostgreSQL | MySQL | SQLite | MongoDB>
Existing seeds: <path or "none detected">
Factory lib: <fishery | factory_boy | FactoryBot | Bogus | none>
Faker lib: <@faker-js/faker | Faker (Python) | go-faker | none>
Environments: <dev | staging | demo>
```

Scan codebase: look for `prisma/seed.ts`, `db/seeds.rb`, `scripts/seed*`, factory definitions, fixture files, existing `createMany`/`bulk_create` usage.

### Step 2: Factory Pattern Implementation

**Library selection**: TypeScript: fishery. Python: factory_boy. Ruby: FactoryBot. Go: table-driven builders with gofakeit. C#: Bogus. Java: Instancio. PHP: Eloquent factories.

**Key patterns across all languages**:
- Base factory with faker-generated defaults and sequence IDs
- Traits/variants for common modifications (admin, inactive, published)
- Associations via SubFactory/associations parameter
- `build()` for in-memory, `create()` for persisted, `buildList(N)` for batches
- Override any field at call site

### Step 3: Seed Script Architecture

**Idempotent seed script rules**:
1. ALWAYS use upsert (insert or update) instead of plain insert
2. Use stable identifiers (slug, email) — NOT auto-increment IDs
3. Run in dependency order (users before posts, categories before products)
4. Wrap each group in a transaction
5. Log created vs skipped vs updated
6. Re-runnable: running twice = same result as once

**Seed structure**: Set `faker.seed(42)` for determinism → Phase 1: reference data (roles, categories via upsert) → Phase 2: core entities (fixed seed users + random users via createMany/skipDuplicates) → Phase 3: dependent entities (posts, comments). Check existing count vs target, only create delta.

### Step 4: Relationship Handling

Seed in topological order: reference data → independent entities → first-level deps → second-level deps → many-to-many joins → derived data.

Collect parent IDs after creation, pass to child seeders. Use Pareto distribution for realistic associations (20% of parents get 80% of children).

### Step 5: Large Dataset Seeding

- NEVER insert one row at a time — use `createMany` / `bulk_create` / `insert_all`
- Batch size: 500-5000 rows per INSERT
- For 100K+ rows: streaming or raw `COPY` (PostgreSQL)
- Disable indexes/constraints during bulk load, rebuild after
- Show progress for long-running seeds
- PostgreSQL optimization: `SET session_replication_role = 'replica'` (disable FK checks), seed, re-enable, `REINDEX`, `ANALYZE`

### Step 6: Deterministic Seeds

- `faker.seed(42)` = same data every run = reproducible bugs/screenshots
- Use sequences instead of random IDs
- Different seeds for different environments
- Per-test: reset seed before each test suite

### Step 7: Data Anonymization

For production snapshots: replace emails (user_N@example.com), names (faker), phones (faker), addresses, free text (lorem). Remove entirely: credit cards, API keys, tokens, passwords (replace with known hash). Add noise to financial amounts (±10%). Shift dates by random offset.

Rules: NEVER copy production without anonymization. Anonymize in separate DB. Keep referential integrity. Deterministic mapping (hash-based). Verify before granting access.

### Step 8: Cleanup Strategies

- **Truncate cascade**: Full reset — `TRUNCATE table CASCADE`
- **Delete by marker**: Selective — `DELETE WHERE source = 'seed'`
- **Transaction rollback**: Per-test — BEGIN → seed → test → ROLLBACK (fastest)
- **Database drop/create**: CI pipelines
- **Snapshot restore**: `pg_restore` from dump

**Environment-aware seeding**: Dev (50 users, deterministic, minimal), Staging (5K users, randomized, weekly reset), Demo (200 curated users, deterministic). Fixed test users always present (admin@example.com, etc). All emails use @example.com.

### Step 9: Report and Commit
```
Commit: "seed: add <description> seeding infrastructure"
Files: seed script, factories/, environment configs, package.json seed command
```

## Key Behaviors

1. **Seeds must be idempotent.** Use upsert, skipDuplicates, update_or_create. Never blindly insert.
2. **Use factories for tests, seed scripts for environments.** Different problems, use both.
3. **Seed in dependency order.** Parents before children. Violating = FK errors.
4. **Use deterministic seeds for development.** `faker.seed(42)` = reproducible data.
5. **Batch insert for performance.** `createMany` is 100x faster than create-in-loop.
6. **Tag seeded data.** `source: 'seed'` or `@example.com` emails for cleanup.
7. **Environment-specific volumes.** Dev=50, Staging=5000, Demo=curated, Production=zero fake.
8. **Never seed production with fake data.** Only reference data (roles, permissions).
9. **Anonymize before snapshotting.** Replace all PII before copying production data.
10. **Clean up after tests.** Transaction rollback (fastest), truncate, or delete-by-marker.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive seed setup |
| `--factory` | Set up factory pattern |
| `--script` | Create idempotent seed script |
| `--env` | Configure environment-specific seeding |
| `--large` | Optimize for large datasets (batch, COPY) |
| `--deterministic` | Set up reproducible seeds |
| `--anonymize` | Production data anonymization pipeline |
| `--cleanup` | Seed data cleanup strategies |

## HARD RULES

1. NEVER seed production databases with development data. Environment guard at top of every seed script.
2. ALWAYS use fixed faker seed (`faker.seed(42)`) for deterministic output.
3. NEVER use auto-increment IDs as stable references. Use slugs/emails for upsert matching.
4. ALWAYS use batch inserts. Single-row loops turn 2s seed into 5min seed.
5. NEVER include real user data in seed files. Seed files are in version control.
6. ALWAYS make seeds idempotent with upsert logic.
7. NEVER seed without a transaction. Partial seed is worse than no seed.
8. ALWAYS provide a `--reset` flag for clean-slate option.

## Auto-Detection
```bash
grep -r "prisma\|typeorm\|sequelize\|django\|sqlalchemy\|activerecord" package.json pyproject.toml Gemfile 2>/dev/null
ls prisma/seed.ts db/seeds.rb scripts/seed* 2>/dev/null
grep -r "@faker-js\|faker\|factory_bot\|factoryboy\|Bogus" package.json pyproject.toml Gemfile 2>/dev/null
```

## TSV Logging
```
STEP	ENTITY	ORM	METHOD	STATUS	DETAILS
1	users	prisma	createMany	seeded	50 users with faker seed 42
2	posts	prisma	createMany	seeded	200 posts across 50 users
3	idempotency	-	upsert	verified	re-run produced 0 duplicates
4	reset	-	truncate	verified	--reset clears all tables in correct order
```
Print: `Seeds: {N} entities, {rows} rows. ORM: {tool}. Faker seed: {seed}. Idempotent: {yes/no}. Environments: {list}. Reset: {supported/not}.`

## Success Criteria
1. Seed runs without errors on clean database.
2. Idempotent (running twice = no duplicates, no constraint violations).
3. Dependency order correct (parents before children).
4. Batch inserts used for all entities.
5. Faker seed fixed for deterministic output.
6. Environment guard prevents production seeding.
7. `--reset` truncates in reverse dependency order.
8. Test factories share data patterns with seeds.

## Error Recovery
- **FK constraint violation**: Wrong seed order. Map dependencies, seed topologically.
- **Unique constraint on re-run**: Not idempotent. Switch to upsert. Match on stable identifier.
- **Seed too slow**: Switch to batch inserts. Disable indexes during bulk, re-enable after.
- **Faker data unrealistic**: Use domain-specific generators. Curate demo data by hand.
- **Production guard missing**: Add `if (env === 'production') throw` at top of every seed entry point.
- **Reset wrong order**: Reverse seed dependency order for truncation. Use `TRUNCATE CASCADE`.

## Iteration Protocol
```
WHILE incomplete: REVIEW → IMPLEMENT next entity → TEST (idempotent, no dupes) → VERIFY (counts, FK integrity)
IF pass: commit | IF fail: fix (max 3 attempts)
STOP: all entities seeded, idempotent verified, env guards active, --reset works
```

## Keep/Discard Discipline
```
KEEP if: idempotent (re-run safe), batch-inserted, dependency order correct
DISCARD if: unique constraint on re-run OR FK errors OR single-row loops
```

## Stop Conditions
```
STOP when: all entities seeded idempotently, env guard active, --reset works, or user stops
DO NOT STOP just because: demo curation incomplete or anonymization pipeline not built
```

## Anti-Patterns
- Do NOT put seed logic in migrations — migrations change schema, seeds populate data.
- Do NOT use random data for demo environments — curated data tells a story.
- Do NOT skip cleanup in tests — leftover data pollutes next test.
- Do NOT seed same data in every environment — use environment-specific configs.

## Multi-Agent Dispatch
```
Agent 1 (seed-core): Entry point, env guards, CLI flags, dependency mapping, reference data
Agent 2 (seed-entities): Entity seeds with faker + batch inserts, factory functions
Agent 3 (seed-validation): Validation (counts, FK), --reset flag, env-specific configs
MERGE: core → entities → validation
```

## Platform Fallback
Run sequentially: core setup → entity seeds → validation/reset. Branch per task.

## Output Format
Print: `Seed: {entities} entities, {rows} rows. Idempotent: {yes|no}. Env guard: {active|missing}. Re-run safe: {yes|no}. Status: {DONE|PARTIAL}.`
