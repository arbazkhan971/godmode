---
name: postgres
description: |
  PostgreSQL mastery skill. Activates when a developer needs advanced PostgreSQL features, extension management, replication setup, partitioning strategies, performance tuning, or connection pooling configuration. Covers CTEs, window functions, JSONB, full-text search, PostGIS, pgvector, TimescaleDB, streaming and logical replication, declarative partitioning, VACUUM/ANALYZE tuning, pg_stat diagnostics, PgBouncer, and Supavisor. Triggers on: /godmode:postgres, "postgres performance", "set up replication", "partition this table", "configure pgbouncer", "pgvector", "full-text search in postgres", or when the orchestrator detects PostgreSQL-specific work.
---

# Postgres -- PostgreSQL Mastery

## When to Activate
- User invokes `/godmode:postgres`
- User says "postgres performance", "tune postgres", "postgres is slow"
- User asks about CTEs, window functions, JSONB queries, or full-text search in PostgreSQL
- User needs to set up replication (streaming or logical)
- User asks about partitioning a large table
- User needs to configure PgBouncer or Supavisor
- User asks about PostgreSQL extensions (PostGIS, pgvector, TimescaleDB)
- User says "VACUUM", "ANALYZE", "bloat", "pg_stat", "dead tuples"
- When `/godmode:query` identifies PostgreSQL-specific optimization opportunities
- When `/godmode:migrate` encounters PostgreSQL-specific DDL requirements

## Workflow

### Step 1: PostgreSQL Environment Assessment

Determine the PostgreSQL version, configuration, and workload profile:

```
POSTGRES CONTEXT:
Version:          <PostgreSQL 14 | 15 | 16 | 17>
Hosting:          <Self-managed | RDS | Aurora | Supabase | Neon | Crunchy | AlloyDB | CloudSQL>
```

Gather system configuration:
```sql
-- PostgreSQL version and key settings
SELECT version();
SHOW shared_buffers;
```

### Step 2: Advanced PostgreSQL Features

#### 2a: Common Table Expressions (CTEs)

```sql
-- Recursive CTE: Organizational hierarchy
WITH RECURSIVE org_tree AS (
    -- Base case: top-level employees (no manager)
```

#### 2b: Window Functions

```sql
-- Running totals and rankings
SELECT
    order_id,
```

#### 2c: JSONB Operations

```sql
-- JSONB storage and querying
CREATE TABLE events (
    id          BIGSERIAL PRIMARY KEY,
```

#### 2d: Full-Text Search

```sql
-- tsvector column with GIN index
ALTER TABLE articles ADD COLUMN search_vector tsvector;

```

### Step 3: Extension Management

#### 3a: pgvector -- Vector Similarity Search

```sql
-- Install pgvector
CREATE EXTENSION IF NOT EXISTS vector;

```

#### 3b: PostGIS -- Geospatial Data

```sql
-- Install PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

```

#### 3c: TimescaleDB -- Time-Series Data

```sql
-- Install TimescaleDB
CREATE EXTENSION IF NOT EXISTS timescaledb;

```

#### Extension Selection Guide
```
EXTENSION SELECTION:
+--------------------------------------------------------------+
|  Need                        | Extension        | Notes       |
```

### Step 4: Replication Setup

#### 4a: Streaming Replication (Physical)

```
STREAMING REPLICATION:
Purpose:  Byte-for-byte copy of the primary for HA and read scaling
Use when: You need identical replicas, failover, read replicas
```

#### 4b: Logical Replication

```
LOGICAL REPLICATION:
Purpose:  Table-level, selective replication with transformation
Use when: Replicating specific tables, cross-version upgrades, data integration
```

### Step 5: Partitioning Strategies

```sql
-- Declarative Partitioning (PostgreSQL 10+)

-- RANGE PARTITIONING: Time-series data, logs, events
```

```
PARTITIONING DECISION:
+--------------------------------------------------------------+
|  Strategy   | Use When                    | Partition Key      |
```

### Step 6: VACUUM, ANALYZE, and pg_stat Tuning

#### 6a: VACUUM and Autovacuum

```sql
-- Check autovacuum status and dead tuple buildup
SELECT schemaname, relname,
       n_live_tup, n_dead_tup,
```

```
VACUUM TYPES:
+--------------------------------------------------------------+
|  Command              | What It Does          | When to Use    |
```

#### 6b: pg_stat_statements and Diagnostics

```sql
-- Enable pg_stat_statements (essential for production)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

```

```
DIAGNOSTIC CHECKLIST:
+--------------------------------------------------------------+
|  Metric                    | Target         | Query            |
```

### Step 7: Connection Pooling

#### 7a: PgBouncer

```
PGBOUNCER CONFIGURATION:

pgbouncer.ini:
```

#### 7b: Supavisor (Elixir-based, Supabase)

```
SUPAVISOR:
Purpose:  Cloud-native connection pooler built for multi-tenant PostgreSQL
Use when: Running Supabase, multi-tenant SaaS, need per-tenant pool isolation
```

### Step 8: Performance Tuning Playbook

```
POSTGRESQL TUNING -- Quick Reference:

MEMORY:
```

### Step 9: Report and Transition

```
+------------------------------------------------------------+
|  POSTGRESQL MASTERY -- <description>                        |
+------------------------------------------------------------+
```

Commit: `"postgres: <description> -- <key outcome>"`

## Explicit Loop Protocol

For iterative performance tuning workflows:

```
TUNING LOOP:
current_iteration = 0
max_iterations = 5
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. NEVER run VACUUM FULL on a production table without explicit user confirmation
   and a maintenance window. It takes an EXCLUSIVE LOCK.
```

## Key Behaviors

1. **Always check the version.** PostgreSQL features vary significantly across versions. CTEs are optimized differently in 12+, partitioning improved dramatically in 11-14, and JSONB path queries require 12+.
2. **Measure before tuning.** Run pg_stat_statements, check cache hit ratios, and identify the actual bottleneck before changing postgresql.conf. Random tuning is worse than defaults.
3. **Use CONCURRENTLY for production DDL.** CREATE INDEX CONCURRENTLY, REINDEX CONCURRENTLY, and pg_repack avoid exclusive locks that block reads and writes.
4. **Partition key in every query.** Partitioning only helps if the query planner can prune partitions. Always include the partition key in WHERE clauses.
5. **Connection pooling is mandatory.** PostgreSQL forks a process per connection (~10MB each). Use PgBouncer in transaction mode for web applications.
6. **Autovacuum is not optional.** Never disable autovacuum. Instead, tune its aggressiveness per table based on update/delete frequency.
7. **Logical replication for selective sync.** When you need to replicate specific tables or across PostgreSQL versions, use logical replication. Use streaming for HA failover.
8. **Extensions over external tools.** Before adding Elasticsearch, try pg_trgm + FTS. Before Pinecone, try pgvector. PostgreSQL extensions keep your data in one place.
9. **EXPLAIN ANALYZE everything.** Never assume a query is optimized. Run EXPLAIN (ANALYZE, BUFFERS) and read every line of the plan.
10. **pg_stat_statements is non-negotiable.** Install it on every PostgreSQL instance. It is the single most important tool for understanding query performance in production.

## Keep/Discard Discipline
```
After EACH PostgreSQL optimization:
  1. MEASURE: Run EXPLAIN (ANALYZE, BUFFERS) on the target query before and after.
  2. COMPARE: Is execution time lower? Is the plan using the new index/config?
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Cache hit ratio > 99% and dead tuple ratio < 10% on all tables
  - All top-5 queries by total_exec_time are under target latency
```

## Output Format

Every postgres invocation must produce a structured report:

```
+------------------------------------------------------------+
|  POSTGRES RESULT                                            |
+------------------------------------------------------------+
```

## TSV Logging

Log every PostgreSQL operation to `.godmode/postgres-ops.tsv`:

```
timestamp	operation	target_table	metric_before	metric_after	improvement_pct	verdict
```

Append one row per operation. Never overwrite previous rows.

## Success Criteria

```
HEALTHY if ALL of the following:
  - Cache hit ratio > 99%
  - Index hit ratio > 95%
```

## EXPLAIN ANALYZE Optimization Loop

Autonomous loop that identifies the slowest queries, runs EXPLAIN ANALYZE, applies fixes, and verifies improvement. One change per iteration to isolate impact. Never stops until targets are met or diminishing returns detected.

```
EXPLAIN ANALYZE OPTIMIZATION LOOP:
current_iteration = 0
max_iterations = 20
```

### Index Tuning Reference

```
INDEX TUNING DECISION TABLE:
┌──────────────────────────────────────┬────────────────────────┬─────────────────────────────┐
│ EXPLAIN ANALYZE Signal               │ Index Type             │ Action                      │
```


## Error Recovery
| Failure | Action |
|---------|--------|
| Query plan shows sequential scan on large table | Add appropriate index. Use `EXPLAIN (ANALYZE, BUFFERS)` to verify index is used. Check if statistics are stale (`ANALYZE table`). |
| Lock contention on hot table | Use `SKIP LOCKED` for queue patterns. Reduce transaction duration. Partition the table. Check for long-running transactions with `pg_stat_activity`. |
| Connection pool exhaustion | Increase pool size or use PgBouncer. Check for leaked connections. Set `idle_in_transaction_session_timeout`. Monitor with `pg_stat_activity`. |
| Migration locks table for too long | Use `CREATE INDEX CONCURRENTLY`. Add columns with `DEFAULT` (Postgres 11+ is instant). Split large data migrations into batches. |
