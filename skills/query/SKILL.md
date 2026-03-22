---
name: query
description: |
  Query optimization and data analysis skill. Activates when a developer needs to analyze, optimize, or debug database queries. Interprets EXPLAIN plans, recommends indexes, rewrites queries for performance, detects N+1 problems, and profiles slow queries. Works across SQL databases (PostgreSQL, MySQL, SQLite, SQL Server), MongoDB, Redis, Elasticsearch, and ORM-generated queries (Prisma, Sequelize, TypeORM, Django ORM, ActiveRecord, SQLAlchemy, GORM). Triggers on: /godmode:query, "this query is slow", "optimize this query", "explain plan", "add an index", "N+1 problem", or when performance profiling reveals database bottlenecks.
---

# Query -- Query Optimization & Data Analysis

## When to Activate
- User invokes `/godmode:query`
- User says "this query is slow," "optimize this query," "why is this taking so long?"
- User shares an EXPLAIN plan and asks for interpretation
- User asks about indexing strategy
- Performance profiling reveals database queries as a bottleneck
- User encounters N+1 query problems
- User needs to write a complex query (aggregation, window functions, CTEs, subqueries)
- User asks "should I add an index?" or "which indexes do I need?"
- User needs to analyze data patterns or generate reports from the database

## Workflow

### Step 1: Identify Query Context

Determine the database engine, access pattern, and the query to optimize:

```
QUERY CONTEXT:
Database:       <PostgreSQL | MySQL | SQLite | SQL Server | MongoDB | Redis | Elasticsearch>
Access via:     <Raw SQL | Prisma | Sequelize | TypeORM | Django ORM | ActiveRecord | SQLAlchemy | GORM | Mongoose | Drizzle>
Query source:   <user-provided | ORM-generated | slow query log | application code>
Table(s):       <tables/collections involved>
Estimated rows: <approximate row counts for involved tables>
Current timing: <execution time if known>
Target timing:  <acceptable execution time>
```
If the query comes from an ORM, extract the generated SQL first:
```bash
# Prisma: enable query logging
# In prisma client initialization:
# new PrismaClient({ log: ['query'] })

# Django: use django.db.connection.queries or django-debug-toolbar
python -c "
```

### Step 2: Analyze Current Query Performance

#### 2a: Run EXPLAIN (SQL Databases)

Execute the appropriate EXPLAIN command for the database engine:

```sql
-- PostgreSQL (most informative)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) <query>;

-- PostgreSQL: without executing (safe for destructive queries)
EXPLAIN (COSTS, FORMAT JSON) <query>;

```
#### 2b: Interpret EXPLAIN Output

Read the EXPLAIN output and extract these signals:

```
QUERY ANALYSIS:
Scan type:        <Seq Scan | Index Scan | Index Only Scan | Bitmap Scan | Hash Join | Nested Loop | etc.>
Rows estimated:   <planner estimate>
Rows actual:      <actual rows, if ANALYZE used>
Estimate accuracy: <ratio of estimated to actual -- off by 10x+ is a red flag>
Cost:             <total cost from planner>
Actual time:      <execution time in ms>
Buffers:          <shared hit, shared read, shared written>
  ...
```
Key red flags:
```
RED FLAGS:
[ ] Sequential scan on large table (> 10K rows) -- needs index
[ ] Nested loop join on large tables -- switch to hash/merge join
[ ] Rows estimated vs actual off by > 10x -- stale statistics
[ ] Sort on disk (external merge) -- needs more work_mem or index
[ ] Filter removing > 90% of scanned rows -- index needed
[ ] Seq Scan inside a loop -- classic N+1 pattern
[ ] High shared read / low shared hit -- data not in cache
  ...
```

#### 2c: Analyze MongoDB Queries

```javascript
// Get query execution stats
db.collection.find(<query>).explain("executionStats")

// Key fields to check:
// executionStats.totalDocsExamined vs executionStats.nReturned
//   (if ratio > 10:1, you need a better index)
```
#### 2d: Analyze Redis Commands

```bash
# Check slow log
SLOWLOG GET 10

# Monitor commands in real-time (use briefly -- impacts performance)
MONITOR

```
### Step 3: Diagnose Performance Issues

Identify the root cause of poor performance:

#### Issue 1: Missing Index
```
DIAGNOSIS: Missing index
Evidence: Sequential scan on <table> filtering by <column>
         Scanned <N> rows, returned <M> rows (ratio: <N/M>:1)
Solution: CREATE INDEX idx_<table>_<column> ON <table> (<column>);
Impact:   Seq Scan -> Index Scan, estimated speedup: <X>x
```

#### Issue 2: N+1 Query Problem
```
DIAGNOSIS: N+1 query
Evidence: <N> identical queries executed in a loop, each fetching one related record
          Total queries: <N+1> (1 parent + N children)
          Total time: <sum of all query times>
Solution: Replace with a single JOIN or batch query
          ORM solution: Use eager loading (includes/select_related/with/include)
Impact:   <N+1> queries -> <1-2> queries, estimated speedup: <X>x
```

#### Issue 3: Inefficient Join
```
DIAGNOSIS: Inefficient join strategy
Evidence: Nested Loop join between <table_a> (<N> rows) and <table_b> (<M> rows)
          Resulting in <N*M> comparisons
Solution: Ensure join columns are indexed on both sides
          Rewrite as a subquery or CTE if the join produces excessive rows
Impact:   Nested Loop -> Hash Join, estimated speedup: <X>x
```

#### Issue 4: Over-fetching
```
DIAGNOSIS: Over-fetching data
Evidence: SELECT * returning <N> columns when only <M> are used
          Transferring <X>MB when <Y>MB would suffice
Solution: SELECT only needed columns
          Use covering index for index-only scan
Impact:   Reduced I/O and network transfer, estimated speedup: <X>x
```

#### Issue 5: Stale Statistics
```
DIAGNOSIS: Stale table statistics
Evidence: Planner estimated <N> rows, actual was <M> rows (off by <ratio>x)
          Bad estimate leads to wrong join strategy and scan type
Solution: ANALYZE <table>;  -- PostgreSQL
          ANALYZE TABLE <table>;  -- MySQL
Impact:   Planner makes better decisions with accurate statistics
```

#### Issue 6: Missing Composite Index
```
DIAGNOSIS: Multiple single-column indexes instead of composite
Evidence: Bitmap AND/OR combining <N> indexes on <table>
          Each index scan returns too many rows individually
Solution: CREATE INDEX idx_<table>_<col1>_<col2> ON <table> (<col1>, <col2>);
          Column order: most selective first, then range/sort columns
Impact:   Bitmap scan -> single Index Scan, estimated speedup: <X>x
```

#### Issue 7: Unoptimized Aggregation
```
DIAGNOSIS: Full table scan for aggregation
Evidence: Seq Scan + Sort + GroupAggregate on <table> (<N> rows)
Solution: Add index matching GROUP BY columns
          Use a materialized view for frequently-run aggregations
          Use approximate counts (HyperLogLog) for cardinality estimation
Impact:   Seq Scan -> Index Scan/Index Only Scan, estimated speedup: <X>x
```

### Step 4: Recommend and Implement Optimizations

For each diagnosed issue, provide a concrete fix:

#### 4a: Index Recommendations

```
INDEX RECOMMENDATION:
Table:      <table>
Columns:    <column(s)>
Type:       <btree | hash | gin | gist | brin | partial | covering>
Rationale:  <why this index helps>
Trade-off:  <write overhead, storage cost>

SQL:
  ...
```
Index type selection guide:
```
B-tree (default):     Equality, range, sorting, LIKE 'prefix%'
Hash:                 Equality only, slightly faster than B-tree for exact match
GIN:                  Full-text search, JSONB containment, array operations
GiST:                Geometric data, range types, full-text search
BRIN:                 Very large tables with natural ordering (timestamps, sequential IDs)
Partial:              Queries that always filter on a condition (WHERE active = true)
Covering (INCLUDE):   Enables index-only scan by including non-key columns
```

#### 4b: Query Rewriting

Present the original and optimized query side by side:

```
ORIGINAL QUERY:
<original SQL>

Time: <original time>
Plan: <key plan details>

OPTIMIZED QUERY:
<rewritten SQL>
  ...
```
Common rewrites:
```sql
-- ANTI-PATTERN: Correlated subquery
SELECT u.*, (SELECT COUNT(*) FROM orders WHERE user_id = u.id) AS order_count
FROM users u;

-- OPTIMIZED: JOIN with aggregation
SELECT u.*, COALESCE(o.order_count, 0) AS order_count
```

#### 4c: ORM-Level Optimizations

```python
# Django: N+1 fix
# BEFORE (N+1):
for order in Order.objects.all():
    print(order.customer.name)  # Hits DB for each customer

# AFTER (eager loading):
```
```typescript
// Prisma: N+1 fix
// BEFORE (N+1):
const users = await prisma.user.findMany();
for (const user of users) {
  const orders = await prisma.order.findMany({ where: { userId: user.id } });
}
```
```ruby
# Rails: N+1 fix
# BEFORE (N+1):
@orders = Order.all
@orders.each { |o| puts o.customer.name }

# AFTER (eager loading):
```
### Step 5: Verify Optimization

After applying changes, measure the improvement:

```
OPTIMIZATION RESULTS:
|  Before                    |  After                            |
|--|--|
|  Execution time: <X>ms     |  Execution time: <Y>ms           |
|  Rows scanned:   <N>       |  Rows scanned:   <M>             |
|  Scan type:      Seq Scan  |  Scan type:      Index Scan      |
|  Buffers read:   <A>       |  Buffers read:   <B>             |
|  Queries:        <P>       |  Queries:        <Q>             |
  ...
```
Verification steps:
```
1. Run EXPLAIN ANALYZE on optimized query -- confirm plan changed
2. Run query 3 times -- take median execution time
3. Compare before vs after with same data
4. Run full test suite -- ensure correctness preserved
5. Check write performance -- new indexes slow down writes
6. Monitor for 24h in staging -- check for edge cases under load
```

### Step 6: Report and Transition

```
|  QUERY OPTIMIZATION -- <description>                        |
|  Database:        <engine>                                  |
|  Tables:          <affected tables>                         |
|  Original time:   <X>ms                                     |
|  Optimized time:  <Y>ms                                     |
|  Speedup:         <X/Y>x                                    |
|  Changes made:                                              |
|  1. <change description>                                    |
  ...
```
Commit: `"query: optimize <description> -- <speedup>x improvement"`

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. NEVER claim a query is optimized without EXPLAIN ANALYZE before and after.
2. ALWAYS use CREATE INDEX CONCURRENTLY in PostgreSQL production environments.
3. NEVER add an index without stating the write overhead trade-off.
4. NEVER use SELECT * in production queries — select only needed columns.
5. NEVER use OFFSET for deep pagination — use keyset/cursor pagination.
6. NEVER apply functions to indexed columns in WHERE clauses.
7. ALWAYS fix N+1 at the ORM/application level, not just the SQL level.
  ...
```
## Key Behaviors

1. **Measure before and after.** Never claim an optimization without numbers. Run EXPLAIN ANALYZE before the change, apply the fix, run EXPLAIN ANALYZE after.
2. **Read the EXPLAIN output line by line.** Don't only check if there's a Seq Scan. Understand the full plan -- join order, filter conditions, sort methods, buffer usage.
3. **Prefer index-only solutions.** Adding an index is cheaper and safer than rewriting application code. Start with indexes, escalate to query rewrites only if needed.
4. **State write trade-offs.** Every index speeds up reads but slows down writes. Always state the trade-off explicitly.
## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive query optimization workflow |
| `--explain` | Run EXPLAIN on a query and interpret the output |
| `--indexes` | Analyze and recommend indexes for the database |

## Keep/Discard Discipline
```
After EACH query optimization:
  1. MEASURE: Run EXPLAIN ANALYZE on the optimized query. Record execution time and rows scanned.
  2. COMPARE: Did execution time improve? Did rows scanned decrease?
  3. DECIDE:
     - KEEP if: execution time improved AND test suite passes AND write overhead is acceptable
     - DISCARD if: query correctness changed OR write overhead exceeds read benefit OR no measurable improvement
  4. COMMIT kept changes. Revert discarded changes before the next optimization.

  ...
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Query time meets target latency (default: < 50ms)
  - No sequential scans on tables > 10K rows
  - All N+1 patterns eliminated
  - Improvement < 10% in last iteration (diminishing returns)
  - User explicitly requests stop

DO NOT STOP just because:
  ...
```

## Output Format

```
QUERY OPTIMIZATION COMPLETE:
  Database: <PostgreSQL | MySQL | MongoDB | Redis | other>
  Queries analyzed: <N>
  Queries optimized: <M>
  Indexes added: <K> (write overhead: <estimate>)
  Indexes removed: <J> (unused)
  Total latency reduction: <X>% (avg across optimized queries)

  ...
```
## TSV Logging

Log every query optimization session to `.godmode/query-results.tsv`:

```
Fields: timestamp\tproject\tdatabase\tqueries_analyzed\tqueries_optimized\tindexes_added\tindexes_removed\tavg_latency_reduction_pct\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-app\tpostgresql\t8\t5\t3\t1\t87\tabc1234
```
Append after every completed optimization pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
QUERY OPTIMIZATION SUCCESS CRITERIA:
|  Criterion                                  | Required         |
|--|--|
|  EXPLAIN ANALYZE run before AND after       | YES              |
|  Every optimization measured with numbers   | YES              |
|  No sequential scan on tables > 10K rows    | YES              |
|  N+1 queries eliminated                     | YES              |
|  No SELECT * in optimized queries           | YES              |
## Error Recovery
| Failure | Action |
|--|--|
| Query returns wrong results | Check JOIN conditions and WHERE clauses. Verify NULL handling. Test with known data set. Compare against manual calculation. |
| Query too slow (>1s) | Run EXPLAIN ANALYZE. Check for missing indexes, full table scans, or unnecessary JOINs. Use materialized views for complex aggregations. |
| Query works in dev but fails in production | Check for data volume differences. Verify index existence in production. Check for parameter sniffing issues. Test with production-like data. |
| ORM-generated query is inefficient | Use raw SQL for complex queries. Check for N+1 patterns. Use query builder for dynamic conditions. Profile ORM query output. |
