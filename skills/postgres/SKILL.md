---
name: postgres
description: PostgreSQL mastery -- advanced features,
  replication, partitioning, tuning, connection pooling.
---

## Activate When
- `/godmode:postgres`, "postgres performance"
- "tune postgres", "replication", "partition table"
- "pgbouncer", "pgvector", "full-text search"
- "VACUUM", "ANALYZE", "bloat", "pg_stat"

## Workflow

### 1. Environment Assessment
```sql
SELECT version();
SHOW shared_buffers;
SHOW work_mem;
SHOW max_connections;
```
```
Version: PostgreSQL 14|15|16|17
Hosting: self-managed|RDS|Aurora|Supabase|Neon
Workload: OLTP|OLAP|mixed
Size: <total GB>, Tables: <N>, Largest: <N rows>
```

### 2. Advanced Features
**CTEs**: recursive for hierarchies, materialized
for repeated subqueries (PG 12+ auto-optimizes).

**Window Functions**: ROW_NUMBER, RANK, LAG/LEAD,
running totals with SUM() OVER().

**JSONB**: GIN index for containment (@>), use
jsonb_path_query for complex extraction. Keep
structured data in columns, metadata in JSONB.

**Full-Text Search**: tsvector + GIN index.
`to_tsvector('english', col)` with `@@` operator.
IF FTS sufficient: skip Elasticsearch.

### 3. Extensions
- **pgvector**: vector similarity (RAG, embeddings).
  Use ivfflat (fast, approximate) or hnsw (accurate).
  IF <1M vectors: pgvector over Pinecone.
- **PostGIS**: geospatial. ST_DWithin for proximity.
- **TimescaleDB**: time-series. Hypertables with
  automatic partitioning by time.
- **pg_stat_statements**: ALWAYS install. Non-negotiable
  for understanding query performance.

### 4. Replication
**Streaming (physical)**: byte-for-byte copy. Use for
HA failover + read replicas. `wal_level=replica`.

**Logical**: table-level, selective. Use for cross-
version upgrades, specific table replication, CDC.
Requires `wal_level=logical`.

IF HA failover needed: streaming replication.
IF selective table sync: logical replication.

### 5. Partitioning
```sql
CREATE TABLE events (
  id bigserial, created_at timestamptz, data jsonb
) PARTITION BY RANGE (created_at);
CREATE TABLE events_2024_q1 PARTITION OF events
  FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');
```
- Range: time-series, logs (partition by month/quarter)
- List: known categories (partition by region/status)
- Hash: uniform distribution (partition by user_id)

IF table >10M rows: consider partitioning.
IF queries always filter by time: range partition.
ALWAYS include partition key in WHERE clause.

### 6. VACUUM & Autovacuum
```sql
SELECT relname, n_dead_tup,
  last_autovacuum, last_autoanalyze
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000 ORDER BY n_dead_tup DESC;
```
VACUUM: reclaims dead tuples. VACUUM FULL: rewrites
table (EXCLUSIVE LOCK -- maintenance window only).
ANALYZE: updates statistics for query planner.

IF dead_tuple_ratio > 10%: tune autovacuum.
IF bloat > 50%: consider pg_repack (no lock).

### 7. Connection Pooling
PgBouncer: transaction mode for web apps.
Pool: `(cores * 2) + 1` per instance.
PG degrades above ~100 active connections.

IF multi-tenant SaaS on Supabase: use Supavisor.
IF web app: PgBouncer in transaction mode.

Coordinate: `pool_size * instances < max_conn * 0.8`.

### 8. Performance Tuning
```
shared_buffers: 25% of RAM (start point)
work_mem: RAM / (max_connections * 2)
effective_cache_size: 75% of RAM
random_page_cost: 1.1 (SSD) or 4.0 (HDD)
```
```sql
-- Cache hit ratio (target >99%)
SELECT sum(heap_blks_hit) /
  nullif(sum(heap_blks_hit + heap_blks_read), 0)
FROM pg_statio_user_tables;

-- Index hit ratio (target >95%)
SELECT sum(idx_blks_hit) /
  nullif(sum(idx_blks_hit + idx_blks_read), 0)
FROM pg_statio_user_indexes;
```

### 9. EXPLAIN ANALYZE
```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) <query>;
```
Red flags: Seq Scan on >10K rows, Nested Loop on
large tables, estimates off >10x (run ANALYZE).
ALWAYS use CONCURRENTLY for production index creation.


```bash
# PostgreSQL diagnostics
psql -c "SELECT * FROM pg_stat_activity WHERE state = 'active'"
psql -c "EXPLAIN ANALYZE SELECT 1"
pg_dump --schema-only > schema.sql
```

```bash
# PostgreSQL diagnostics
psql -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active'"
pg_dump --schema-only > schema.sql
```

```bash
# PostgreSQL diagnostics
curl -s http://localhost:8080/health/db
grep -r "CREATE INDEX" migrations/ | wc -l
```

## Hard Rules
1. NEVER VACUUM FULL without maintenance window.
2. NEVER disable autovacuum.
3. ALWAYS CREATE INDEX CONCURRENTLY in production.
4. ALWAYS install pg_stat_statements.
5. NEVER exceed ~100 direct connections (use pooler).
6. ALWAYS include partition key in WHERE clauses.
7. ALWAYS EXPLAIN ANALYZE before claiming optimized.
8. NEVER tune without measuring baseline first.

## TSV Logging
Append `.godmode/postgres-ops.tsv`:
```
timestamp	operation	table	metric_before	metric_after	improvement_pct	verdict
```

## Keep/Discard
```
KEEP if: execution time improved AND plan uses
  new index/config AND tests pass.
DISCARD if: no improvement OR regression OR
  correctness changed.
```

## Stop Conditions
```
STOP when FIRST of:
  - Cache hit ratio > 99%
  - Dead tuple ratio < 10% all tables
  - Top-5 queries under target latency
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Seq scan on large table | Add index, ANALYZE table |
| Lock contention | SKIP LOCKED, reduce txn duration |
| Pool exhaustion | Increase pool, add PgBouncer |
| Migration locks table | CREATE INDEX CONCURRENTLY |
