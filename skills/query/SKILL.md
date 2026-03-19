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
from django.db import connection
# run query...
print(connection.queries[-1]['sql'])
"

# Rails: check log/development.log or use .to_sql
Model.where(conditions).to_sql

# SQLAlchemy: compile query
str(query.statement.compile(compile_kwargs={"literal_binds": True}))

# TypeORM: enable logging in data source config
# logging: true, or use .getQuery()

# Sequelize: use logging: console.log option
```

### Step 2: Analyze Current Query Performance

#### 2a: Run EXPLAIN (SQL Databases)

Execute the appropriate EXPLAIN command for the database engine:

```sql
-- PostgreSQL (most informative)
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) <query>;

-- PostgreSQL: without executing (safe for destructive queries)
EXPLAIN (COSTS, FORMAT JSON) <query>;

-- MySQL
EXPLAIN FORMAT=JSON <query>;
-- or for execution stats:
EXPLAIN ANALYZE <query>;  -- MySQL 8.0.18+

-- SQLite
EXPLAIN QUERY PLAN <query>;

-- SQL Server
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
<query>;
-- or for estimated plan:
SET SHOWPLAN_XML ON;
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
Sort method:      <quicksort in memory | external merge on disk>
Join strategy:    <nested loop | hash join | merge join>
```

Key red flags:
```
RED FLAGS:
[ ] Sequential scan on large table (> 10K rows) -- needs index
[ ] Nested loop join on large tables -- consider hash/merge join
[ ] Rows estimated vs actual off by > 10x -- stale statistics
[ ] Sort on disk (external merge) -- needs more work_mem or index
[ ] Filter removing > 90% of scanned rows -- index needed
[ ] Seq Scan inside a loop -- classic N+1 pattern
[ ] High shared read / low shared hit -- data not in cache
[ ] Hash join with huge hash table -- memory pressure
[ ] Bitmap heap scan with many recheck conditions -- partial index opportunity
```

#### 2c: Analyze MongoDB Queries

```javascript
// Get query execution stats
db.collection.find(<query>).explain("executionStats")

// Key fields to check:
// executionStats.totalDocsExamined vs executionStats.nReturned
//   (if ratio > 10:1, you need a better index)
// executionStats.executionTimeMillis
// queryPlanner.winningPlan.stage
//   COLLSCAN = full collection scan (bad)
//   IXSCAN = index scan (good)
//   FETCH + IXSCAN = index scan + document fetch (check if covered index possible)
```

#### 2d: Analyze Redis Commands

```bash
# Check slow log
SLOWLOG GET 10

# Monitor commands in real-time (use briefly -- impacts performance)
MONITOR

# Check key patterns and memory
MEMORY USAGE <key>
DEBUG OBJECT <key>  # encoding, refcount, serializedlength

# Check if O(N) commands are used on large datasets
# Dangerous: KEYS *, SMEMBERS on large sets, LRANGE 0 -1 on large lists
# Safe alternatives: SCAN, SSCAN, LRANGE with pagination
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
          Consider rewriting as a subquery or CTE if appropriate
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
          Consider materialized view for frequently-run aggregations
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
CREATE INDEX CONCURRENTLY idx_<table>_<columns>
ON <table> (<columns>)
WHERE <condition>;  -- partial index, if applicable

Estimated impact:
  Read:  <X>x faster for queries filtering on these columns
  Write: <Y>% slower for INSERT/UPDATE on this table
  Storage: ~<Z>MB additional
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

Time: <expected time>
Plan: <expected plan changes>

Changes:
1. <what changed and why>
2. <what changed and why>
```

Common rewrites:
```sql
-- ANTI-PATTERN: Correlated subquery
SELECT u.*, (SELECT COUNT(*) FROM orders WHERE user_id = u.id) AS order_count
FROM users u;

-- OPTIMIZED: JOIN with aggregation
SELECT u.*, COALESCE(o.order_count, 0) AS order_count
FROM users u
LEFT JOIN (SELECT user_id, COUNT(*) AS order_count FROM orders GROUP BY user_id) o
ON u.id = o.user_id;

-- ANTI-PATTERN: DISTINCT to fix a bad join
SELECT DISTINCT u.* FROM users u JOIN orders o ON u.id = o.user_id;

-- OPTIMIZED: EXISTS instead of JOIN + DISTINCT
SELECT u.* FROM users u WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

-- ANTI-PATTERN: OR on different columns (prevents index use)
SELECT * FROM products WHERE name = 'Widget' OR category = 'Tools';

-- OPTIMIZED: UNION ALL with separate index scans
SELECT * FROM products WHERE name = 'Widget'
UNION ALL
SELECT * FROM products WHERE category = 'Tools' AND name != 'Widget';

-- ANTI-PATTERN: Function on indexed column (prevents index use)
SELECT * FROM events WHERE YEAR(created_at) = 2025;

-- OPTIMIZED: Range condition (uses index)
SELECT * FROM events WHERE created_at >= '2025-01-01' AND created_at < '2026-01-01';

-- ANTI-PATTERN: Large IN list
SELECT * FROM users WHERE id IN (1, 2, 3, ..., 10000);

-- OPTIMIZED: JOIN with VALUES or temp table
SELECT u.* FROM users u
JOIN (VALUES (1),(2),(3),...) AS v(id) ON u.id = v.id;

-- ANTI-PATTERN: OFFSET for pagination (scans and discards rows)
SELECT * FROM products ORDER BY id LIMIT 20 OFFSET 10000;

-- OPTIMIZED: Keyset pagination (seeks directly)
SELECT * FROM products WHERE id > <last_seen_id> ORDER BY id LIMIT 20;
```

#### 4c: ORM-Level Optimizations

```python
# Django: N+1 fix
# BEFORE (N+1):
for order in Order.objects.all():
    print(order.customer.name)  # Hits DB for each customer

# AFTER (eager loading):
for order in Order.objects.select_related('customer').all():
    print(order.customer.name)  # Single JOIN query

# Django: defer unused fields
User.objects.defer('bio', 'avatar_url').filter(active=True)

# Django: use values/values_list for read-only data
User.objects.values_list('id', 'email', flat=False).filter(active=True)
```

```typescript
// Prisma: N+1 fix
// BEFORE (N+1):
const users = await prisma.user.findMany();
for (const user of users) {
  const orders = await prisma.order.findMany({ where: { userId: user.id } });
}

// AFTER (eager loading):
const users = await prisma.user.findMany({
  include: { orders: true }
});

// Prisma: select only needed fields
const users = await prisma.user.findMany({
  select: { id: true, email: true }
});
```

```ruby
# Rails: N+1 fix
# BEFORE (N+1):
@orders = Order.all
@orders.each { |o| puts o.customer.name }

# AFTER (eager loading):
@orders = Order.includes(:customer).all
@orders.each { |o| puts o.customer.name }

# Rails: select only needed columns
User.select(:id, :email).where(active: true)
```

### Step 5: Verify Optimization

After applying changes, measure the improvement:

```
OPTIMIZATION RESULTS:
+---------------------------------------------------------------+
|  Before                    |  After                            |
+---------------------------------------------------------------+
|  Execution time: <X>ms     |  Execution time: <Y>ms           |
|  Rows scanned:   <N>       |  Rows scanned:   <M>             |
|  Scan type:      Seq Scan  |  Scan type:      Index Scan      |
|  Buffers read:   <A>       |  Buffers read:   <B>             |
|  Queries:        <P>       |  Queries:        <Q>             |
+---------------------------------------------------------------+
|  Improvement: <X/Y>x faster, <N/M>x fewer rows scanned       |
+---------------------------------------------------------------+
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
+------------------------------------------------------------+
|  QUERY OPTIMIZATION -- <description>                        |
+------------------------------------------------------------+
|  Database:        <engine>                                  |
|  Tables:          <affected tables>                         |
|  Original time:   <X>ms                                     |
|  Optimized time:  <Y>ms                                     |
|  Speedup:         <X/Y>x                                    |
+------------------------------------------------------------+
|  Changes made:                                              |
|  1. <change description>                                    |
|  2. <change description>                                    |
|                                                             |
|  Indexes added:                                             |
|  - idx_<name> ON <table> (<columns>)                        |
|                                                             |
|  Queries rewritten:    <N>                                  |
|  N+1 problems fixed:  <N>                                   |
+------------------------------------------------------------+
|  Write overhead:  <estimated impact on INSERT/UPDATE>       |
|  Storage added:   <estimated index size>                    |
+------------------------------------------------------------+
```

Commit: `"query: optimize <description> -- <speedup>x improvement"`

## Key Behaviors

1. **Measure before and after.** Never claim an optimization without numbers. Run EXPLAIN ANALYZE before the change, apply the fix, run EXPLAIN ANALYZE after.
2. **Read the EXPLAIN output line by line.** Don't just check if there's a Seq Scan. Understand the full plan -- join order, filter conditions, sort methods, buffer usage.
3. **Prefer index-only solutions.** Adding an index is cheaper and safer than rewriting application code. Start with indexes, escalate to query rewrites only if needed.
4. **Consider write trade-offs.** Every index speeds up reads but slows down writes. Always state the trade-off explicitly.
5. **Fix N+1 at the ORM level.** Don't just optimize the SQL -- fix the application code that generates the N+1 pattern. Use eager loading, batching, or data loaders.
6. **CONCURRENTLY for production indexes.** In PostgreSQL, always use CREATE INDEX CONCURRENTLY in production to avoid locking the table. In MySQL, use ALTER TABLE ... ADD INDEX (online DDL) or pt-online-schema-change.
7. **Statistics matter.** Before blaming the query, check if table statistics are current. Stale statistics cause bad plans.
8. **Pagination done right.** OFFSET-based pagination is O(N) for deep pages. Keyset (cursor) pagination is O(1). Always recommend keyset pagination for large datasets.
9. **Don't over-index.** More indexes means slower writes and more storage. Aim for the minimum set of indexes that covers the actual query workload.
10. **Understand the data.** Cardinality, distribution, and skew affect index effectiveness. An index on a boolean column with 99% TRUE is nearly useless for filtering TRUE but excellent for filtering FALSE.

## Example Usage

### Optimizing a slow query
```
User: /godmode:query This query takes 3 seconds:
      SELECT * FROM orders WHERE customer_id = 42 ORDER BY created_at DESC LIMIT 20;

Query: Analyzing...

QUERY CONTEXT:
Database:       PostgreSQL 15
Table:          orders (2.4M rows)
Current timing: 3,200ms

Running EXPLAIN ANALYZE...

QUERY ANALYSIS:
Scan type:     Seq Scan on orders
Filter:        customer_id = 42
Rows scanned:  2,400,000
Rows returned: 847
Sort:          external merge (on disk)

RED FLAGS:
[x] Sequential scan on 2.4M row table
[x] Scanning 2.4M rows to find 847 (2,831:1 ratio)
[x] Sort on disk -- data doesn't fit in work_mem

DIAGNOSIS: Missing index on (customer_id, created_at)

INDEX RECOMMENDATION:
CREATE INDEX CONCURRENTLY idx_orders_customer_created
ON orders (customer_id, created_at DESC);

Rationale:
- Composite index covers both the WHERE and ORDER BY
- DESC on created_at matches the query's ORDER BY DESC
- Eliminates both the Seq Scan AND the Sort step

After adding index:
  Scan type: Index Scan Backward using idx_orders_customer_created
  Rows scanned: 20 (LIMIT satisfied directly from index)
  Sort: none (index provides order)
  Time: 0.4ms

Speedup: 8,000x (3,200ms -> 0.4ms)
```

### Fixing an N+1 problem
```
User: /godmode:query My API endpoint is making 500 database queries per request

Query: Let me trace the query pattern...

Found in src/controllers/orders.ts:
  const orders = await prisma.order.findMany({ where: { status: 'active' } });
  for (const order of orders) {
    const customer = await prisma.customer.findUnique({ where: { id: order.customerId } });
    const items = await prisma.orderItem.findMany({ where: { orderId: order.id } });
  }

DIAGNOSIS: N+1 query (actually N+1+N -- two nested queries)
  1 query for orders (returns 250 orders)
  250 queries for customers (one per order)
  250 queries for order items (one per order)
  Total: 501 queries

FIX:
  const orders = await prisma.order.findMany({
    where: { status: 'active' },
    include: {
      customer: true,
      items: true,
    },
  });

  Total queries after fix: 1 (with JOINs)
  Speedup: ~100x (501 queries -> 1 query)
```

### Analyzing a MongoDB query
```
User: /godmode:query This MongoDB aggregation pipeline is crawling

Query: Running explain...

db.events.aggregate([
  { $match: { type: "click", timestamp: { $gte: ISODate("2025-01-01") } } },
  { $group: { _id: "$userId", clickCount: { $sum: 1 } } },
  { $sort: { clickCount: -1 } },
  { $limit: 100 }
]).explain("executionStats")

ANALYSIS:
Stage:               COLLSCAN (full collection scan)
Documents examined:  45,000,000
Documents matched:   1,200,000
Execution time:      28,400ms

FIX: Create compound index
db.events.createIndex({ type: 1, timestamp: 1, userId: 1 })

After index:
Stage:               IXSCAN
Documents examined:  1,200,000 (only matching docs)
Execution time:      1,200ms

Speedup: 23x (28.4s -> 1.2s)

For further improvement, consider a pre-aggregated collection
(materialized view pattern) if this runs frequently.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive query optimization workflow |
| `--explain` | Run EXPLAIN on a query and interpret the output |
| `--indexes` | Analyze and recommend indexes for the database |
| `--n-plus-one` | Scan application code for N+1 query patterns |
| `--slow-log` | Analyze the database slow query log |
| `--rewrite` | Rewrite a query for better performance |
| `--profile` | Profile all queries from a specific endpoint or operation |
| `--compare` | Compare performance of two query variants |
| `--orm` | Focus on ORM-level optimizations |
| `--redis` | Analyze Redis command patterns |
| `--mongo` | Analyze MongoDB queries and indexes |
| `--unused-indexes` | Find indexes that are never used (waste of write overhead) |
| `--missing-indexes` | Detect queries that would benefit from indexes |
| `--report` | Generate a full database performance report |

## Anti-Patterns

- **Do NOT optimize without measuring.** "This query should be faster with an index" is a hypothesis. Run EXPLAIN ANALYZE before and after to prove it.
- **Do NOT add indexes blindly.** Every index has a write cost. Check if the query runs frequently enough to justify the overhead.
- **Do NOT ignore the ORM layer.** The prettiest SQL in the world doesn't help if the ORM generates N+1 queries around it.
- **Do NOT use SELECT * in production queries.** Fetch only the columns you need. This enables index-only scans and reduces I/O.
- **Do NOT use OFFSET for deep pagination.** OFFSET 100000 scans and discards 100,000 rows. Use keyset/cursor pagination.
- **Do NOT apply functions to indexed columns in WHERE clauses.** `WHERE YEAR(created_at) = 2025` cannot use an index on `created_at`. Use range conditions instead.
- **Do NOT create single-column indexes for every column.** Think about query patterns and create composite indexes that serve multiple queries.
- **Do NOT forget to update statistics after bulk data changes.** Stale statistics lead to bad query plans.
- **Do NOT assume an index helps without checking selectivity.** An index on a boolean column with 50/50 distribution won't help much.
- **Do NOT optimize queries in isolation.** Consider the full workload. An optimization that helps one query but hurts ten others is a net negative.
- **Do NOT skip the write-side impact.** Report the INSERT/UPDATE/DELETE overhead of every new index.
