---
name: orm
description: |
  ORM and data access optimization skill. Activates when a developer needs to select, configure, or optimize an ORM or data access layer. Covers ORM selection (Prisma, Drizzle, TypeORM, SQLAlchemy, GORM, ActiveRecord), query builder patterns, N+1 query detection and resolution, connection pooling configuration, and transaction management patterns. Triggers on: /godmode:orm, "which ORM", "N+1 query", "connection pool", "transaction", "query builder", "data access layer", or when database access code needs architectural guidance or performance optimization.
---

# ORM -- ORM & Data Access Optimization

## When to Activate
- User invokes `/godmode:orm`
- User says "which ORM", "Prisma vs Drizzle", "N+1 query", "connection pool"
- User needs transaction management, query builder patterns, or raw SQL escape
- User wants to audit ORM usage for performance issues

## Workflow

### Step 1: Detect Data Access Environment
```
Language: <TS|Python|Go|Ruby|Java|Rust|PHP>
ORM: <Prisma|Drizzle|TypeORM|SQLAlchemy|Django ORM|GORM|ActiveRecord|None>
Database: <PostgreSQL|MySQL|SQLite|MongoDB>
Connection: <direct|pooler|serverless|edge>
```
Scan for: schema files, model definitions, query patterns, N+1 indicators (queries in loops), pool configuration.

### Step 2: ORM Selection

**TypeScript/JavaScript:**
- Prisma: Max type safety, great DX, schema-first. Heavy engine (~2MB).
- Drizzle: SQL-first, max performance, ~30KB, edge-ready.
- TypeORM: Decorator-based, NestJS integration. Heavy.

**Python:** SQLAlchemy 2.0 (FastAPI), Django ORM (Django), Tortoise (async-first).

**Other:** Go: GORM/Ent/sqlc. Ruby: ActiveRecord/Sequel. Java: Hibernate/jOOQ. Rust: Diesel/SeaORM.

### Step 3: N+1 Detection & Resolution
Enable query logging, load a list page, count queries. If count = 1 + N, you have N+1.

```typescript
// Prisma: BAD (N+1)
const posts = await prisma.post.findMany();
for (const post of posts) { await prisma.user.findUnique({ where: { id: post.authorId } }); }

// Prisma: GOOD (1 query with JOIN)
const posts = await prisma.post.findMany({ include: { author: true } });

// Drizzle: GOOD (JOIN)
const posts = await db.select().from(postsTable)
  .leftJoin(usersTable, eq(postsTable.authorId, usersTable.id));
```

Other ORMs: Django `select_related`/`prefetch_related`, SQLAlchemy `joinedload`/`selectinload`, Rails `includes`/`eager_load`, GORM `Preload`/`Joins`.

### Step 4: Connection Pooling
```
Formula: pool_size = (core_count * 2) + 1 (for SSDs)
Typical: 10-20 connections per instance

         | Development | Production
min      | 1           | 5
max      | 5           | 20
idle_timeout | 30s     | 300s
max_lifetime | 30min   | 1 hour
```

WARNING: PostgreSQL degrades above ~100 active connections. Use PgBouncer/RDS Proxy for multiplexing. Coordinate: `pool_size * instances < max_connections * 0.8`.

### Step 5: Transaction Patterns

**Basic:** Use interactive transactions (Prisma `$transaction`, SQLAlchemy `Session`). Include optimistic locking guards. Set isolation level for financial operations.

**Nested (Savepoints):** Inner transaction failure does not roll back outer. Use for non-critical side effects (notifications, email queue).

**Distributed (Saga):** For cross-service operations. Each step has execute + compensate. Compensate in reverse order on failure. Log compensation failures for manual intervention.

### Step 6: Query Builder Patterns
Build dynamic queries with composable conditions. Drizzle: `and(...conditions)`, SQLAlchemy: `and_(*conditions)`. Always cap pagination: `min(limit, 100)`.

**Raw SQL escape hatch:** Use when ORM generates bad SQL. Prisma `$queryRaw`, Drizzle `sql\`\``, SQLAlchemy `text()`. Always use parameterized queries.

### Step 7: Production Readiness
```
[ ] Connection pooling configured     [ ] Query logging in dev
[ ] N+1 queries fixed                 [ ] Slow query threshold (>1s)
[ ] Statement timeout configured      [ ] Retry for transient failures
[ ] Migration tested (up+down+up)     [ ] Health checks enabled
[ ] Schema matches database (no drift)
```

### Step 8: Report
```
ORM: <selected>  Database: <engine>  Connection: <direct|pooled|serverless>
N+1: <N> found, <M> fixed  Pool: <min>-<max> connections
Queries: <before> -> <after>  Latency: <before>ms -> <after>ms
Commit: "orm: optimize <description> data access layer"
```

## Autonomous Operation
- Loop until target or budget. Never pause.
- Measure before/after. Guard: test_cmd && lint_cmd.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Key Behaviors
1. **ORM for 90%, raw SQL for 10%.** Know your escape hatch.
2. **Enable query logging in development.** Cannot fix what you cannot see.
3. **Eager load at query site, not globally.** Load at point of use.
4. **Pools are bounded.** More connections != more throughput.
5. **Transactions as short as possible.** Compute outside, write inside.
6. **Optimistic locking for concurrent updates.**
7. **Monitor pool metrics.** Alert at 80% utilization.
8. **Migrations and schema must stay in sync.**

## Flags & Options

| Flag | Description |
|--|--|
| `--select` | ORM selection guide |
| `--n-plus-one` | Scan for N+1 patterns |
| `--pool` | Configure connection pooling |
| `--transactions` | Transaction management patterns |
| `--audit` | Full data access audit |
| `--raw-sql` | Raw SQL for complex queries |

## HARD RULES
1. **NEVER mix ORMs in the same project.**
2. **NEVER set pool size >= max_connections.** Coordinate across instances.
3. **NEVER lazy-load in a loop.** That is an N+1. Fix before committing.
4. **NEVER hold a transaction open during I/O.** No HTTP/email/uploads inside transactions.
5. **NEVER use SELECT * in production.** Select only needed columns.
6. **ALWAYS enable query logging in development.**
7. **ALWAYS test migrations with up+down+up cycle.**
8. **NEVER retry on constraint violations.** Only retry transient failures.

## Auto-Detection
```
1. Check dependencies for ORM: prisma, drizzle-orm, typeorm, sqlalchemy, django.db, gorm
2. Scan for schema/model files, migrations, pool config
3. Detect N+1 indicators: lazy loading, no include/joinedload in queries
4. Check database type from connection strings
```

## Explicit Loop Protocol
```
SCAN for N+1, missing indexes, pool misconfig, unoptimized queries
FOR EACH issue: DIAGNOSE -> FIX -> VERIFY (query count reduced) -> MEASURE (before/after)
```

## Multi-Agent Dispatch
```
Agent 1 (orm-n-plus-one): Scan and fix N+1 queries
Agent 2 (orm-pool-config): Audit and configure pool settings
Agent 3 (orm-transactions): Audit transaction patterns, add optimistic locking
MERGE ORDER: n-plus-one -> pool-config -> transactions
```

## TSV Logging
Log to `.godmode/orm-results.tsv`: `timestamp\tproject\torm\tmodels_audited\tn1_found\tn1_fixed\tpool_configured\tquery_reduction_pct\tcommit_sha`

## Success Criteria
- Zero N+1 queries in audited operations
- Connection pool sized for workload
- All transactions use explicit boundaries
- Migrations are reversible
- No raw SQL without parameterized queries
- Query logging enabled in dev/staging

## Error Recovery
1. **N+1 persists:** Verify include/joinedload on correct relation. Add query count assertion test.
2. **Pool exhausted:** Check for leaked connections, increase with caution, add proxy.
3. **Migration fails:** Check data-dependent failures, add backfill before schema change.
4. **Deadlock:** Verify consistent lock ordering, reduce transaction scope, retry with backoff.
5. **Query timeout:** Run EXPLAIN ANALYZE, add index, paginate.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-orm-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `ORM: {models} models, {queries} queries optimized. N+1: {fixed|none}. Latency p50: {N}ms, p99: {N}ms. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH ORM change:
  KEEP if: all queries under target latency AND no N+1 detected AND tests pass
  DISCARD if: query regression OR N+1 introduced OR connection pool issues
  On discard: revert. Profile query before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - All endpoints under target latency (p50 <50ms, p99 <200ms)
  - No N+1 queries detected
  - Connection pool sized correctly
  - All models have corresponding tests
```
