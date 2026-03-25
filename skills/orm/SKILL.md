---
name: orm
description: ORM and data access optimization.
---

## Activate When
- `/godmode:orm`, "which ORM", "Prisma vs Drizzle"
- "N+1 query", "connection pool", "transaction"
- ORM usage audit for performance issues

## Workflow

### 1. Detect Environment
```bash
grep -r "prisma\|drizzle-orm\|typeorm\|sqlalchemy" \
  package.json requirements.txt go.mod 2>/dev/null
grep -r "include:\|select_related\|joinedload" \
  --include="*.ts" --include="*.py" -l 2>/dev/null
```
```
Language: <TS|Python|Go|Ruby|Java>
ORM: <Prisma|Drizzle|TypeORM|SQLAlchemy|Django|GORM>
Database: <PostgreSQL|MySQL|SQLite>
Connection: <direct|pooler|serverless>
```

### 2. ORM Selection
**TypeScript/JavaScript:**
- Prisma: max type safety, great DX, schema-first.
  Heavy engine (~2MB). Best for most projects.
- Drizzle: SQL-first, ~30KB, edge-ready. Best for
  performance-critical or serverless.
- TypeORM: decorator-based, NestJS integration.

**Python:** SQLAlchemy 2.0 (FastAPI), Django ORM.
**Go:** GORM, Ent, sqlc. **Ruby:** ActiveRecord.

IF edge/serverless: Drizzle (smallest bundle).
IF max type safety: Prisma.

### 3. N+1 Detection & Resolution
Enable query logging, load list page, count queries.
If count = 1 + N, you have N+1.

```typescript
// BAD (N+1): queries in loop
const posts = await prisma.post.findMany();
for (const p of posts) {
  await prisma.user.findUnique({
    where: { id: p.authorId }
  });
}

// GOOD (1 query with JOIN)
const posts = await prisma.post.findMany({
  include: { author: true }
});
```
ORM equivalents: Django `select_related`/`prefetch`,
SQLAlchemy `joinedload`/`selectinload`,
Rails `includes`/`eager_load`, GORM `Preload`/`Joins`.

### 4. Connection Pooling
```
Formula: pool_size = (core_count * 2) + 1
Typical: 10-20 connections per instance
         | Dev  | Prod
min      | 1    | 5
max      | 5    | 20
idle_timeout | 30s | 300s
```
WARNING: PostgreSQL degrades above ~100 connections.
Use PgBouncer/RDS Proxy for multiplexing.
Coordinate: `pool * instances < max_conn * 0.8`.

IF pool utilization > 80%: alert and investigate.

### 5. Transaction Patterns
Interactive transactions (Prisma `$transaction`,
SQLAlchemy `Session`). Optimistic locking for
concurrent updates. Set isolation level for financial.

Nested (savepoints): inner failure does not roll back
outer. For non-critical side effects.

Distributed (saga): cross-service ops. Each step has
execute + compensate. Compensate in reverse on failure.

### 6. Query Builder & Raw SQL
Composable conditions: `and(...conditions)`.
Cap pagination: `min(limit, 100)`.
Raw SQL escape hatch: Prisma `$queryRaw`,
Drizzle `sql`, SQLAlchemy `text()`.
ALWAYS use parameterized queries.

### 7. Production Readiness
```
[ ] Pool configured     [ ] Query logging in dev
[ ] N+1 fixed           [ ] Slow query threshold (>1s)
[ ] Statement timeout   [ ] Retry transient failures
[ ] Migration up+down+up [ ] Schema matches DB
```

## Hard Rules
1. NEVER mix ORMs in same project.
2. NEVER set pool_size >= max_connections.
3. NEVER lazy-load in a loop (N+1).
4. NEVER hold transaction open during I/O.
5. NEVER use SELECT * in production.
6. ALWAYS enable query logging in development.
7. ALWAYS test migrations up+down+up.
8. NEVER retry constraint violations.

## TSV Logging
Append `.godmode/orm-results.tsv`:
```
timestamp	orm	models_audited	n1_found	n1_fixed	pool_configured	query_reduction_pct	status
```

## Keep/Discard
```
KEEP if: queries under target latency AND no N+1
  AND tests pass.
DISCARD if: query regression OR N+1 introduced
  OR pool issues.
```

## Stop Conditions
```
STOP when ALL of:
  - p50 < 50ms, p99 < 200ms
  - No N+1 queries detected
  - Pool sized correctly
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| N+1 persists | Verify include on correct relation |
| Pool exhausted | Check leaks, increase with caution |
| Migration fails | Check data deps, add backfill |
| Deadlock | Consistent lock ordering, reduce scope |
| Query timeout | EXPLAIN ANALYZE, add index, paginate |
