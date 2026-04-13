---
name: query
description: Query optimization and EXPLAIN analysis.
---

## Activate When
- `/godmode:query`, "this query is slow", "optimize"
- EXPLAIN plan interpretation, indexing strategy
- N+1 problem, complex aggregation, slow query log

## Workflow

### 1. Query Context
```
Database: PostgreSQL|MySQL|SQLite|MongoDB|Redis
Access via: Raw SQL|Prisma|Django ORM|ActiveRecord|GORM
Table(s): <involved tables>
Estimated rows: <approximate counts>
Current time: <ms>  Target: <ms>
```
```bash
# Extract ORM-generated SQL
# Prisma: new PrismaClient({ log: ['query'] })
# Django: django.db.connection.queries
# Rails: ActiveRecord::Base.logger = Logger.new(STDOUT)
```

### 2. EXPLAIN Analysis
```sql
-- PostgreSQL (most informative)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) <query>;
-- Safe mode (no execution)
EXPLAIN (COSTS, FORMAT JSON) <query>;
```
```
Red flags:
[ ] Seq Scan on > 10K rows — needs index
[ ] Nested Loop on large tables — use hash join
[ ] Estimated vs actual off > 10x — stale stats
[ ] Sort on disk — needs work_mem or index
[ ] Filter removes > 90% scanned — index needed
[ ] Seq Scan inside loop — N+1 pattern
```
IF MongoDB: `db.collection.find().explain("executionStats")`
  Check totalDocsExamined vs nReturned ratio.
IF Redis: `SLOWLOG GET 10` for slow commands.

### 3. Diagnose Issues
```
Missing Index:
  Evidence: Seq Scan on <table> filtering by <col>
  Fix: CREATE INDEX idx_<table>_<col> ON <table>(<col>)
N+1 Query:
  Evidence: <N> identical queries in loop
  Fix: JOIN or eager loading (includes/select_related)
  ORM: Django select_related, Prisma include,
    Rails includes, SQLAlchemy joinedload
Inefficient Join:
  Evidence: Nested Loop on <N>x<M> rows
  Fix: Ensure join columns indexed both sides
Over-fetching:
  Evidence: SELECT * returning <N> unused columns
  Fix: SELECT only needed columns
Stale Statistics:
  Evidence: Estimated <N> vs actual <M> (off by >10x)
  Fix: ANALYZE <table>
```
IF improvement < 10% after optimization: diminishing returns.
IF query still > 1s after indexes: consider materialized view.

### 4. Index Recommendations
```
B-tree (default): equality, range, sort, LIKE 'prefix%'
GIN: full-text search, JSONB, arrays
BRIN: very large tables with natural ordering
Partial: WHERE active=true (smaller, faster)
Covering (INCLUDE): enables index-only scan
```
```sql
-- ALWAYS use CONCURRENTLY in production PostgreSQL
CREATE INDEX CONCURRENTLY idx_name ON table(col);
```
Trade-off: every index speeds reads, slows writes.
IF write-heavy table (> 1000 writes/sec): limit to 3-5 indexes.

### 5. Verify
```bash
# Run EXPLAIN ANALYZE on optimized query
# Run 3 times, take median
# Run full test suite — verify correctness
# Check write performance — new indexes slow writes
```


```bash
# Analyze query performance
psql -c "EXPLAIN (ANALYZE, BUFFERS) SELECT 1"
npx prisma studio
```

## Hard Rules
1. NEVER claim optimized without EXPLAIN before/after.
2. ALWAYS CREATE INDEX CONCURRENTLY in production PG.
3. NEVER add index without stating write trade-off.
4. NEVER SELECT * in production queries.
5. NEVER OFFSET for deep pagination — use keyset.
6. NEVER apply functions to indexed columns in WHERE.
7. ALWAYS fix N+1 at ORM level, not just SQL.

## TSV Logging
Append `.godmode/query-results.tsv`:
```
timestamp	database	queries_optimized	indexes_added	latency_pct	status
```

## Keep/Discard
```
KEEP if: time improved AND tests pass AND
  write overhead acceptable.
DISCARD if: correctness changed OR no improvement.
```

## Stop Conditions
```
STOP when FIRST of:
  - Query meets target (default < 50ms)
  - No seq scans on > 10K row tables
  - All N+1 eliminated
  - Improvement < 10% last iteration
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Wrong results | Check JOINs, WHERE, NULL handling |
| Still slow > 1s | Check missing indexes, full scans |
| ORM inefficiency | Use raw SQL for complex queries |
