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
Connection method: <Direct | PgBouncer | Supavisor | pgcat | Odyssey>
Workload type:    <OLTP | OLAP | Mixed | Time-series>
Database size:    <total size including indexes>
Largest table:    <name, row count, size>
Extensions:       <currently installed>
Replication:      <none | streaming | logical | both>
Partitioning:     <none | range | list | hash>
Pain points:      <what is driving the need for PostgreSQL expertise>
```

Gather system configuration:
```sql
-- PostgreSQL version and key settings
SELECT version();
SHOW shared_buffers;
SHOW effective_cache_size;
SHOW work_mem;
SHOW maintenance_work_mem;
SHOW max_connections;
SHOW max_parallel_workers_per_gather;
SHOW wal_level;
SHOW max_wal_senders;

-- Database size overview
SELECT pg_database.datname,
       pg_size_pretty(pg_database_size(pg_database.datname)) AS size
FROM pg_database ORDER BY pg_database_size(pg_database.datname) DESC;

-- Largest tables
SELECT schemaname, relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
       pg_size_pretty(pg_relation_size(relid)) AS table_size,
       pg_size_pretty(pg_indexes_size(relid)) AS index_size,
       n_live_tup AS live_rows,
       n_dead_tup AS dead_rows
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 20;

-- Installed extensions
SELECT extname, extversion FROM pg_extension ORDER BY extname;
```

### Step 2: Advanced PostgreSQL Features

#### 2a: Common Table Expressions (CTEs)

```sql
-- Recursive CTE: Organizational hierarchy
WITH RECURSIVE org_tree AS (
    -- Base case: top-level employees (no manager)
    SELECT id, name, manager_id, 1 AS depth, ARRAY[id] AS path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: employees with managers already in the tree
    SELECT e.id, e.name, e.manager_id, ot.depth + 1, ot.path || e.id
    FROM employees e
    JOIN org_tree ot ON e.manager_id = ot.id
    WHERE NOT e.id = ANY(ot.path)  -- cycle prevention
)
SELECT * FROM org_tree ORDER BY path;

-- Materialized CTE (PostgreSQL 12+): Force CTE to materialize
-- By default, PG 12+ inlines CTEs. Use MATERIALIZED to prevent.
WITH expensive_calc AS MATERIALIZED (
    SELECT user_id, SUM(amount) AS total_spent
    FROM orders
    WHERE created_at >= NOW() - INTERVAL '1 year'
    GROUP BY user_id
)
SELECT u.name, ec.total_spent
FROM users u
JOIN expensive_calc ec ON u.id = ec.user_id
WHERE ec.total_spent > 1000;

-- NOT MATERIALIZED: Force inlining (optimization fence removed)
WITH filtered AS NOT MATERIALIZED (
    SELECT * FROM orders WHERE status = 'active'
)
SELECT * FROM filtered WHERE customer_id = 42;
-- Planner can push customer_id filter into the CTE scan
```

#### 2b: Window Functions

```sql
-- Running totals and rankings
SELECT
    order_id,
    customer_id,
    amount,
    order_date,
    -- Running total per customer
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    -- Rank within customer orders
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date DESC) AS recency_rank,
    -- Percentile across all orders
    PERCENT_RANK() OVER (ORDER BY amount) AS spend_percentile,
    -- Moving average (last 7 days)
    AVG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
        RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
    ) AS moving_avg_7d,
    -- Lead/lag for comparison
    LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_amount,
    amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY order_date) AS delta
FROM orders;

-- FILTER clause with window functions (PostgreSQL-specific)
SELECT
    date_trunc('month', created_at) AS month,
    COUNT(*) AS total_orders,
    COUNT(*) FILTER (WHERE status = 'completed') AS completed,
    COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled,
    SUM(amount) FILTER (WHERE status = 'completed') AS completed_revenue
FROM orders
GROUP BY 1
ORDER BY 1;

-- GROUPING SETS, CUBE, ROLLUP for multi-dimensional aggregation
SELECT
    COALESCE(region, 'ALL REGIONS') AS region,
    COALESCE(product_category, 'ALL CATEGORIES') AS category,
    SUM(revenue) AS total_revenue,
    COUNT(*) AS order_count
FROM sales
GROUP BY GROUPING SETS (
    (region, product_category),  -- per region + category
    (region),                     -- per region total
    (product_category),           -- per category total
    ()                            -- grand total
)
ORDER BY region, category;
```

#### 2c: JSONB Operations

```sql
-- JSONB storage and querying
CREATE TABLE events (
    id          BIGSERIAL PRIMARY KEY,
    event_type  TEXT NOT NULL,
    payload     JSONB NOT NULL,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- GIN index for containment queries
CREATE INDEX idx_events_payload ON events USING GIN (payload);

-- GIN index on specific path (more selective, smaller)
CREATE INDEX idx_events_payload_user ON events USING GIN ((payload -> 'user'));

-- Containment operator @> (uses GIN index)
SELECT * FROM events
WHERE payload @> '{"user": {"role": "admin"}, "action": "delete"}';

-- Path existence operator ? (uses GIN index)
SELECT * FROM events WHERE payload ? 'error_code';

-- jsonb_path_query (SQL/JSON path -- PostgreSQL 12+)
SELECT id, jsonb_path_query(payload, '$.items[*] ? (@.price > 100)') AS expensive_items
FROM events
WHERE event_type = 'purchase';

-- jsonb_path_exists for filtering
SELECT * FROM events
WHERE jsonb_path_exists(payload, '$.items[*] ? (@.quantity > 10)');

-- Aggregation into JSONB
SELECT customer_id,
       jsonb_agg(jsonb_build_object(
           'order_id', order_id,
           'amount', amount,
           'date', created_at
       ) ORDER BY created_at DESC) AS order_history
FROM orders
GROUP BY customer_id;

-- JSONB update operations
UPDATE events
SET payload = jsonb_set(payload, '{status}', '"processed"')
WHERE id = 123;

-- Remove a key
UPDATE events
SET payload = payload - 'temporary_field'
WHERE event_type = 'import';

-- Deep merge
UPDATE events
SET payload = payload || '{"metadata": {"processed_at": "2025-01-15T10:00:00Z"}}'
WHERE id = 123;

-- JSONB vs JSON decision:
-- Use JSONB (99% of cases): binary storage, indexable, operators, no duplicate keys
-- Use JSON only if: exact formatting/key order must be preserved, write-heavy with no reads
```

#### 2d: Full-Text Search

```sql
-- tsvector column with GIN index
ALTER TABLE articles ADD COLUMN search_vector tsvector;

-- Populate with weighted fields
UPDATE articles SET search_vector =
    setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(subtitle, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(body, '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(tags_text, '')), 'B');

-- GIN index on the tsvector column
CREATE INDEX idx_articles_search ON articles USING GIN (search_vector);

-- Auto-update trigger
CREATE FUNCTION articles_search_trigger() RETURNS trigger AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.subtitle, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.body, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.tags_text, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_articles_search
    BEFORE INSERT OR UPDATE ON articles
    FOR EACH ROW EXECUTE FUNCTION articles_search_trigger();

-- Search with ranking
SELECT id, title,
       ts_rank_cd(search_vector, query) AS rank,
       ts_headline('english', body, query,
           'StartSel=<mark>, StopSel=</mark>, MaxWords=35, MinWords=15'
       ) AS snippet
FROM articles,
     to_tsquery('english', 'postgresql & (performance | optimization)') AS query
WHERE search_vector @@ query
ORDER BY rank DESC
LIMIT 20;

-- Prefix matching (autocomplete)
SELECT title FROM articles
WHERE search_vector @@ to_tsquery('english', 'postg:*');

-- Phrase search (PostgreSQL 9.6+)
SELECT title FROM articles
WHERE search_vector @@ phraseto_tsquery('english', 'connection pooling');

-- Full-text search vs. alternatives:
-- pg_trgm: fuzzy matching, similarity, typo tolerance (use with GIN/GiST)
-- pg_search (FTS): structured queries, ranking, stemming, stop words
-- Elasticsearch: if you need faceting, aggregations, complex analyzers at scale
-- For most apps: PostgreSQL FTS + pg_trgm covers 90% of search needs
```

### Step 3: Extension Management

#### 3a: pgvector -- Vector Similarity Search

```sql
-- Install pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- Create table with vector column
CREATE TABLE documents (
    id          BIGSERIAL PRIMARY KEY,
    content     TEXT NOT NULL,
    embedding   vector(1536),  -- OpenAI ada-002 dimension
    metadata    JSONB DEFAULT '{}'
);

-- HNSW index (recommended for most cases -- faster queries)
CREATE INDEX idx_documents_embedding ON documents
    USING hnsw (embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 200);

-- IVFFlat index (faster to build, good for large datasets)
-- CREATE INDEX idx_documents_embedding ON documents
--     USING ivfflat (embedding vector_cosine_ops)
--     WITH (lists = 100);  -- sqrt(row_count) is a good starting point

-- Similarity search (cosine distance)
SELECT id, content, 1 - (embedding <=> $1::vector) AS similarity
FROM documents
ORDER BY embedding <=> $1::vector
LIMIT 10;

-- Filtered similarity search
SELECT id, content, 1 - (embedding <=> $1::vector) AS similarity
FROM documents
WHERE metadata @> '{"category": "technical"}'
ORDER BY embedding <=> $1::vector
LIMIT 10;

-- Distance operators:
-- <=>  Cosine distance (most common for text embeddings)
-- <->  L2 (Euclidean) distance
-- <#>  Inner product (negative, for max inner product search)

-- Tuning HNSW search quality
SET hnsw.ef_search = 100;  -- Higher = more accurate, slower (default 40)

-- pgvector vs dedicated vector DB:
-- pgvector: Good for < 10M vectors, simpler ops, data co-located with app data
-- Pinecone/Weaviate/Qdrant: Better for > 10M vectors, advanced filtering, managed scaling
```

#### 3b: PostGIS -- Geospatial Data

```sql
-- Install PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create table with geometry column
CREATE TABLE locations (
    id          BIGSERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    geom        GEOMETRY(Point, 4326),  -- WGS84 coordinate system
    address     TEXT
);

-- Spatial index
CREATE INDEX idx_locations_geom ON locations USING GIST (geom);

-- Insert a point (longitude, latitude)
INSERT INTO locations (name, geom, address)
VALUES ('Office', ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326), '350 5th Ave, NYC');

-- Find locations within 5km radius
SELECT name, address,
       ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)::geography) AS distance_meters
FROM locations
WHERE ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326)::geography, 5000)
ORDER BY distance_meters;

-- Bounding box query (fastest for rectangular areas)
SELECT * FROM locations
WHERE geom && ST_MakeEnvelope(-74.05, 40.68, -73.90, 40.82, 4326);

-- GeoJSON output (for API responses)
SELECT jsonb_build_object(
    'type', 'FeatureCollection',
    'features', jsonb_agg(
        jsonb_build_object(
            'type', 'Feature',
            'geometry', ST_AsGeoJSON(geom)::jsonb,
            'properties', jsonb_build_object('name', name, 'address', address)
        )
    )
) FROM locations WHERE ST_DWithin(...);
```

#### 3c: TimescaleDB -- Time-Series Data

```sql
-- Install TimescaleDB
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Create regular table first
CREATE TABLE metrics (
    time        TIMESTAMPTZ NOT NULL,
    device_id   TEXT NOT NULL,
    metric_name TEXT NOT NULL,
    value       DOUBLE PRECISION,
    tags        JSONB DEFAULT '{}'
);

-- Convert to hypertable (partitions by time automatically)
SELECT create_hypertable('metrics', 'time',
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists => TRUE
);

-- Add compression policy (compress chunks older than 7 days)
ALTER TABLE metrics SET (
    timescaledb.compress,
    timescaledb.compress_segmentby = 'device_id,metric_name',
    timescaledb.compress_orderby = 'time DESC'
);
SELECT add_compression_policy('metrics', INTERVAL '7 days');

-- Add retention policy (drop data older than 90 days)
SELECT add_retention_policy('metrics', INTERVAL '90 days');

-- Continuous aggregates (materialized rollups)
CREATE MATERIALIZED VIEW metrics_hourly
WITH (timescaledb.continuous) AS
SELECT
    time_bucket('1 hour', time) AS bucket,
    device_id,
    metric_name,
    AVG(value) AS avg_value,
    MIN(value) AS min_value,
    MAX(value) AS max_value,
    COUNT(*) AS sample_count
FROM metrics
GROUP BY 1, 2, 3
WITH NO DATA;

-- Refresh policy for continuous aggregate
SELECT add_continuous_aggregate_policy('metrics_hourly',
    start_offset => INTERVAL '3 hours',
    end_offset => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour'
);

-- Query with time_bucket
SELECT time_bucket('15 minutes', time) AS bucket,
       device_id,
       AVG(value) AS avg_value,
       percentile_cont(0.95) WITHIN GROUP (ORDER BY value) AS p95
FROM metrics
WHERE time > NOW() - INTERVAL '24 hours'
  AND metric_name = 'cpu_usage'
GROUP BY 1, 2
ORDER BY 1 DESC;
```

#### Extension Selection Guide
```
EXTENSION SELECTION:
+--------------------------------------------------------------+
|  Need                        | Extension        | Notes       |
+--------------------------------------------------------------+
|  Vector similarity search    | pgvector         | < 10M vecs  |
|  Geospatial queries          | PostGIS          | Industry std |
|  Time-series data            | TimescaleDB      | Compression  |
|  Fuzzy text matching         | pg_trgm          | Built-in     |
|  Full-text search            | built-in FTS     | No extension |
|  UUID generation             | pgcrypto / uuid  | gen_random() |
|  Cron-like scheduling        | pg_cron          | Managed DBs  |
|  Columnar storage            | citus_columnar   | Analytics    |
|  Foreign data wrappers       | postgres_fdw     | Cross-DB     |
|  Partitioning helpers        | pg_partman       | Auto-manage  |
|  Statistics/monitoring       | pg_stat_statements| Essential   |
|  Connection info             | pg_stat_kcache   | I/O tracking |
+--------------------------------------------------------------+
```

### Step 4: Replication Setup

#### 4a: Streaming Replication (Physical)

```
STREAMING REPLICATION:
Purpose:  Byte-for-byte copy of the primary for HA and read scaling
Use when: You need identical replicas, failover, read replicas
Limitation: Entire cluster is replicated (cannot select tables)

PRIMARY CONFIGURATION (postgresql.conf):
wal_level = replica              # Required for streaming replication
max_wal_senders = 10             # Max number of replication connections
wal_keep_size = 1GB              # WAL retention (or use replication slots)
synchronous_commit = on          # or 'remote_apply' for sync replication
hot_standby = on                 # Allow reads on replicas

REPLICA SETUP:
# 1. Base backup from primary
pg_basebackup -h <primary-host> -D /var/lib/postgresql/data \
    -U replicator -P -R --wal-method=stream

# -R creates standby.signal and sets primary_conninfo in postgresql.auto.conf

# 2. Verify replica is streaming
SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn,
       pg_wal_lsn_diff(sent_lsn, replay_lsn) AS replay_lag_bytes
FROM pg_stat_replication;

# 3. Check replication lag
SELECT CASE WHEN pg_is_in_recovery() THEN
    pg_last_wal_replay_lsn() || ' (lag: ' ||
    COALESCE(EXTRACT(EPOCH FROM (NOW() - pg_last_xact_replay_timestamp()))::text, 'N/A') || 's)'
ELSE 'primary' END AS replication_status;
```

#### 4b: Logical Replication

```
LOGICAL REPLICATION:
Purpose:  Table-level, selective replication with transformation
Use when: Replicating specific tables, cross-version upgrades, data integration
Limitation: DDL not replicated, sequences not synced, large objects excluded

PRIMARY (publisher):
-- 1. Set wal_level
ALTER SYSTEM SET wal_level = logical;
-- Restart required

-- 2. Create publication
CREATE PUBLICATION my_pub FOR TABLE orders, customers, products;
-- or: CREATE PUBLICATION my_pub FOR ALL TABLES;

-- 3. Create replication user
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '<strong-password>';
GRANT SELECT ON orders, customers, products TO replicator;

REPLICA (subscriber):
-- 1. Create matching table structures (DDL is not replicated)
-- Copy schema from primary:
-- pg_dump -h <primary> -s -t orders -t customers -t products | psql

-- 2. Create subscription
CREATE SUBSCRIPTION my_sub
    CONNECTION 'host=<primary> dbname=mydb user=replicator password=<pw>'
    PUBLICATION my_pub
    WITH (copy_data = true, create_slot = true);

-- 3. Monitor subscription status
SELECT subname, received_lsn, latest_end_lsn,
       latest_end_time, last_msg_receipt_time
FROM pg_stat_subscription;

LOGICAL vs STREAMING:
+--------------------------------------------------------------+
|  Feature              | Streaming        | Logical            |
+--------------------------------------------------------------+
|  Granularity          | Entire cluster   | Per-table          |
|  Cross-version        | No               | Yes                |
|  DDL replication      | Yes (byte copy)  | No (manual)        |
|  Writes on replica    | No               | Yes                |
|  Use for HA failover  | Yes              | Not recommended    |
|  Use for data sync    | Overkill         | Yes                |
|  Use for read scaling | Yes              | Yes                |
|  Sequence sync        | Yes              | No (manual)        |
+--------------------------------------------------------------+
```

### Step 5: Partitioning Strategies

```sql
-- Declarative Partitioning (PostgreSQL 10+)

-- RANGE PARTITIONING: Time-series data, logs, events
CREATE TABLE events (
    id          BIGSERIAL,
    event_type  TEXT NOT NULL,
    payload     JSONB,
    created_at  TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id, created_at)  -- partition key must be in PK
) PARTITION BY RANGE (created_at);

-- Create partitions (monthly)
CREATE TABLE events_2025_01 PARTITION OF events
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE events_2025_02 PARTITION OF events
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
-- ... repeat or automate with pg_partman

-- Default partition (catches rows that match no partition)
CREATE TABLE events_default PARTITION OF events DEFAULT;

-- Automate with pg_partman
CREATE EXTENSION IF NOT EXISTS pg_partman;
SELECT partman.create_parent(
    p_parent_table := 'public.events',
    p_control := 'created_at',
    p_type := 'native',
    p_interval := 'monthly',
    p_premake := 3  -- create 3 future partitions
);

-- LIST PARTITIONING: Multi-tenant, regional, categorical
CREATE TABLE orders (
    id          BIGSERIAL,
    tenant_id   TEXT NOT NULL,
    amount      NUMERIC(12,2),
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (id, tenant_id)
) PARTITION BY LIST (tenant_id);

CREATE TABLE orders_tenant_a PARTITION OF orders FOR VALUES IN ('tenant_a');
CREATE TABLE orders_tenant_b PARTITION OF orders FOR VALUES IN ('tenant_b');
CREATE TABLE orders_default PARTITION OF orders DEFAULT;

-- HASH PARTITIONING: Even distribution when no natural range/list
CREATE TABLE sessions (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     BIGINT NOT NULL,
    data        JSONB,
    expires_at  TIMESTAMPTZ
) PARTITION BY HASH (id);

CREATE TABLE sessions_p0 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE sessions_p1 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE sessions_p2 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE sessions_p3 PARTITION OF sessions FOR VALUES WITH (MODULUS 4, REMAINDER 3);

-- PARTITION PRUNING verification
SET enable_partition_pruning = on;  -- default
EXPLAIN (ANALYZE) SELECT * FROM events WHERE created_at >= '2025-03-01' AND created_at < '2025-04-01';
-- Should show: "Partitions removed: N" or only scan the relevant partition
```

```
PARTITIONING DECISION:
+--------------------------------------------------------------+
|  Strategy   | Use When                    | Partition Key      |
+--------------------------------------------------------------+
|  Range      | Time-series, logs, events   | timestamp, date    |
|  List       | Multi-tenant, regions       | tenant_id, region  |
|  Hash       | Even spread, no natural key | id, user_id        |
+--------------------------------------------------------------+

PARTITIONING RULES:
1. Partition key MUST be in the PRIMARY KEY (or no PK)
2. Queries MUST include partition key in WHERE for pruning
3. Foreign keys referencing partitioned tables: PG 12+
4. Unique indexes must include partition key columns
5. Start partitioning when table exceeds ~50M rows or 10GB
6. Use pg_partman for automated partition creation and retention
7. Monitor partition pruning with EXPLAIN -- if all partitions are scanned, the key is missing from the query
```

### Step 6: VACUUM, ANALYZE, and pg_stat Tuning

#### 6a: VACUUM and Autovacuum

```sql
-- Check autovacuum status and dead tuple buildup
SELECT schemaname, relname,
       n_live_tup, n_dead_tup,
       ROUND(n_dead_tup::numeric / GREATEST(n_live_tup, 1) * 100, 2) AS dead_pct,
       last_vacuum, last_autovacuum,
       last_analyze, last_autoanalyze,
       autovacuum_count, autoanalyze_count
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC
LIMIT 20;

-- Check for tables that need vacuuming
SELECT schemaname || '.' || relname AS table_name,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size,
       n_dead_tup,
       ROUND(n_dead_tup::numeric / GREATEST(n_live_tup + n_dead_tup, 1) * 100, 2) AS bloat_pct
FROM pg_stat_user_tables
WHERE n_dead_tup > 10000
ORDER BY n_dead_tup DESC;

-- Table-level autovacuum tuning for high-churn tables
ALTER TABLE hot_table SET (
    autovacuum_vacuum_threshold = 1000,         -- default 50
    autovacuum_vacuum_scale_factor = 0.01,      -- default 0.2 (20%)
    autovacuum_analyze_threshold = 500,          -- default 50
    autovacuum_analyze_scale_factor = 0.005,     -- default 0.1 (10%)
    autovacuum_vacuum_cost_delay = 2,            -- default 2ms (reduce for faster vacuum)
    autovacuum_vacuum_cost_limit = 1000          -- default 200 (increase for faster vacuum)
);

-- Trigger formula: vacuum when dead_tuples > threshold + scale_factor * n_live_tup
-- Default: vacuum when dead > 50 + 0.2 * live_rows
-- For a 10M row table: vacuum when dead > 2,000,050 (too late!)
-- With tuning: vacuum when dead > 1000 + 0.01 * 10M = 101,000 (much better)
```

```
VACUUM TYPES:
+--------------------------------------------------------------+
|  Command              | What It Does          | When to Use    |
+--------------------------------------------------------------+
|  VACUUM               | Reclaims dead tuples  | Routine maint. |
|                       | Does NOT shrink table  |                |
|  VACUUM FULL          | Rewrites entire table | Severe bloat   |
|                       | EXCLUSIVE LOCK!        | Downtime only  |
|  VACUUM ANALYZE       | Vacuum + update stats  | After bulk ops |
|  VACUUM (PARALLEL N)  | Parallel index vacuum  | Large tables   |
|  pg_repack            | Online VACUUM FULL     | No downtime    |
+--------------------------------------------------------------+

BLOAT REMEDIATION:
1. Mild bloat (< 30%): Let autovacuum handle it, tune thresholds
2. Moderate bloat (30-60%): VACUUM VERBOSE, check autovacuum is running
3. Severe bloat (> 60%): pg_repack (online) or VACUUM FULL (downtime)
4. Index bloat: REINDEX CONCURRENTLY idx_name;
```

#### 6b: pg_stat_statements and Diagnostics

```sql
-- Enable pg_stat_statements (essential for production)
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Top queries by total time
SELECT
    calls,
    ROUND(total_exec_time::numeric, 2) AS total_ms,
    ROUND(mean_exec_time::numeric, 2) AS mean_ms,
    ROUND((100 * total_exec_time / SUM(total_exec_time) OVER ())::numeric, 2) AS pct_total,
    rows,
    query
FROM pg_stat_statements
ORDER BY total_exec_time DESC
LIMIT 20;

-- Top queries by mean time (slowest individual queries)
SELECT calls, ROUND(mean_exec_time::numeric, 2) AS mean_ms,
       ROUND(stddev_exec_time::numeric, 2) AS stddev_ms,
       rows, query
FROM pg_stat_statements
WHERE calls > 10
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Cache hit ratio (should be > 99%)
SELECT
    SUM(heap_blks_hit) AS heap_hit,
    SUM(heap_blks_read) AS heap_read,
    ROUND(SUM(heap_blks_hit)::numeric / GREATEST(SUM(heap_blks_hit) + SUM(heap_blks_read), 1) * 100, 2) AS cache_hit_pct
FROM pg_statio_user_tables;

-- Index usage statistics
SELECT schemaname, relname, indexrelname,
       idx_scan, idx_tup_read, idx_tup_fetch,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;  -- Low scan count = potentially unused index

-- Unused indexes (candidates for removal)
SELECT schemaname || '.' || relname AS table_name,
       indexrelname AS index_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
       idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey'
  AND indexrelname NOT LIKE '%_unique%'
ORDER BY pg_relation_size(indexrelid) DESC;

-- Lock monitoring
SELECT pid, usename, pg_blocking_pids(pid) AS blocked_by,
       query, state, wait_event_type, wait_event,
       NOW() - query_start AS query_duration
FROM pg_stat_activity
WHERE state != 'idle'
ORDER BY query_start;

-- Connection statistics
SELECT state, COUNT(*) FROM pg_stat_activity GROUP BY state;
SELECT usename, COUNT(*) FROM pg_stat_activity GROUP BY usename;
```

```
DIAGNOSTIC CHECKLIST:
+--------------------------------------------------------------+
|  Metric                    | Target         | Query            |
+--------------------------------------------------------------+
|  Cache hit ratio           | > 99%          | pg_statio_*      |
|  Index hit ratio           | > 95%          | pg_statio_*      |
|  Dead tuple ratio          | < 10%          | pg_stat_user_tbl |
|  Unused indexes            | 0              | pg_stat_user_idx |
|  Long-running queries      | < 60s          | pg_stat_activity |
|  Blocked queries           | 0              | pg_blocking_pids |
|  Connections near limit    | < 80%          | pg_stat_activity |
|  Replication lag           | < 1s           | pg_stat_repl     |
|  Transaction wraparound    | < 50% of limit | pg_stat_user_tbl |
+--------------------------------------------------------------+
```

### Step 7: Connection Pooling

#### 7a: PgBouncer

```
PGBOUNCER CONFIGURATION:

pgbouncer.ini:
[databases]
mydb = host=localhost port=5432 dbname=mydb

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = scram-sha-256
auth_file = /etc/pgbouncer/userlist.txt

# Pool mode (critical choice)
pool_mode = transaction    # Most common for web apps

# Pool sizing
default_pool_size = 20     # Connections per user/db pair
min_pool_size = 5          # Keep-alive connections
max_client_conn = 1000     # Max client connections
max_db_connections = 50    # Hard limit on actual PG connections
reserve_pool_size = 5      # Extra connections for burst
reserve_pool_timeout = 3   # Seconds before using reserve

# Timeouts
server_lifetime = 3600     # Reconnect backend after 1h
server_idle_timeout = 600  # Close idle backend after 10m
client_idle_timeout = 0    # 0 = no timeout (set > 0 in production)
query_timeout = 30         # Kill queries running > 30s
query_wait_timeout = 120   # Max time to wait for a connection

# Logging
log_connections = 1
log_disconnections = 1
log_pooler_errors = 1
stats_period = 60

POOL MODE SELECTION:
+--------------------------------------------------------------+
|  Mode          | How It Works           | Use When             |
+--------------------------------------------------------------+
|  session       | 1:1 client:server      | LISTEN/NOTIFY, temp  |
|                | for entire session     | tables, SET commands |
|  transaction   | shared after each tx   | Most web apps (90%)  |
|                | BEST for connection    |                      |
|                | multiplexing           |                      |
|  statement     | shared after each stmt | Simple read replicas |
|                | No multi-stmt tx       | Single-query pattern |
+--------------------------------------------------------------+

MONITORING:
SHOW pools;    -- Active, waiting, server connections
SHOW stats;    -- Query counts, bytes, timing
SHOW servers;  -- Backend connection state
SHOW clients;  -- Client connection state
SHOW config;   -- Running configuration
```

#### 7b: Supavisor (Elixir-based, Supabase)

```
SUPAVISOR:
Purpose:  Cloud-native connection pooler built for multi-tenant PostgreSQL
Use when: Running Supabase, multi-tenant SaaS, need per-tenant pool isolation

Key features:
- Per-tenant connection pooling with isolation
- Native support for prepared statements in transaction mode
- Built-in Prometheus metrics
- Hot config reload without dropping connections
- Named prepared statement support (unlike PgBouncer in tx mode)

Configuration:
{
  "tenants": [{
    "id": "tenant_abc",
    "db_host": "db.example.com",
    "db_port": 5432,
    "db_name": "mydb",
    "pool_size": 10,
    "pool_mode": "transaction",
    "max_client_connections": 200
  }]
}

POOLER COMPARISON:
+--------------------------------------------------------------+
|  Feature            | PgBouncer    | Supavisor   | pgcat      |
+--------------------------------------------------------------+
|  Language            | C            | Elixir      | Rust       |
|  Multi-tenant        | Limited      | Native      | Yes        |
|  Prepared statements | Session only | Transaction | Transaction|
|  Sharding            | No           | No          | Yes        |
|  Load balancing      | No           | Yes         | Yes        |
|  Protocol support    | Extensive    | Growing     | Growing    |
|  Maturity            | Very mature  | Newer       | Newer      |
|  Best for            | General use  | Supabase    | Sharding   |
+--------------------------------------------------------------+
```

### Step 8: Performance Tuning Playbook

```
POSTGRESQL TUNING -- Quick Reference:

MEMORY:
shared_buffers        = 25% of RAM (max ~8GB, diminishing returns after)
effective_cache_size  = 75% of RAM (hint to planner, not allocation)
work_mem              = RAM / (max_connections * 4) -- per sort/hash operation
                        Start at 4MB, increase for complex queries
maintenance_work_mem  = 512MB - 2GB (for VACUUM, CREATE INDEX, ALTER TABLE)

WAL:
wal_buffers           = 64MB (or -1 for auto-tune)
checkpoint_timeout    = 15min (up from default 5min)
checkpoint_completion_target = 0.9
max_wal_size          = 4GB - 16GB
min_wal_size          = 1GB

PLANNER:
random_page_cost      = 1.1 (SSD) or 4.0 (HDD) -- default 4.0
effective_io_concurrency = 200 (SSD) or 2 (HDD)
seq_page_cost         = 1.0 (keep as baseline)

PARALLELISM:
max_parallel_workers_per_gather = 4
max_parallel_workers            = 8
max_parallel_maintenance_workers = 4
parallel_tuple_cost             = 0.01
parallel_setup_cost             = 100

CONNECTIONS:
max_connections       = 100-200 (use pooler for more clients)
                        Each connection uses ~10MB RAM
                        200 connections = 2GB overhead

TOOL: Use PGTune (https://pgtune.leopard.in.ua/) for initial settings
      then adjust based on pg_stat_statements and workload profiling.
```

### Step 9: Report and Transition

```
+------------------------------------------------------------+
|  POSTGRESQL MASTERY -- <description>                        |
+------------------------------------------------------------+
|  Version:         <version>                                 |
|  Hosting:         <platform>                                |
|  Database size:   <size>                                    |
+------------------------------------------------------------+
|  Work completed:                                            |
|  1. <description of work>                                   |
|  2. <description of work>                                   |
|                                                             |
|  Extensions configured:                                     |
|  - <extension>: <purpose>                                   |
|                                                             |
|  Replication:     <type and status>                         |
|  Partitioning:    <strategy applied>                        |
|  Pooling:         <PgBouncer | Supavisor | pgcat>          |
+------------------------------------------------------------+
|  Performance metrics:                                       |
|  Cache hit ratio:   <pct>                                   |
|  Dead tuple ratio:  <pct>                                   |
|  Unused indexes:    <count>                                 |
|  Replication lag:   <seconds>                               |
+------------------------------------------------------------+
```

Commit: `"postgres: <description> -- <key outcome>"`

## Auto-Detection

Before prompting the user, automatically detect PostgreSQL context:

```
AUTO-DETECT SEQUENCE:
1. Scan for database config files:
   - database.yml, .env, docker-compose.yml, prisma/schema.prisma
   - Look for DATABASE_URL, POSTGRES_*, PG_* environment variables
2. Detect PostgreSQL version from:
   - docker-compose.yml image tags (postgres:16, timescale/timescaledb:latest)
   - Gemfile/package.json (pg gem version constraints)
   - Running instance: SELECT version();
3. Detect hosting platform from:
   - Supabase: SUPABASE_URL, supabase/ directory
   - Neon: neon.tech in DATABASE_URL
   - RDS/Aurora: rds.amazonaws.com in connection string
   - AlloyDB/CloudSQL: .cloudsql. or alloydb. in connection string
4. Detect ORM/driver:
   - Prisma: prisma/schema.prisma with provider = "postgresql"
   - ActiveRecord: database.yml with adapter: postgresql
   - SQLAlchemy: engine URL starting with postgresql://
   - TypeORM: ormconfig with type: "postgres"
5. Detect installed extensions:
   - SELECT extname FROM pg_extension;
6. Detect table sizes and pain points:
   - Largest tables, dead tuple ratios, unused indexes
```

## Explicit Loop Protocol

For iterative performance tuning workflows:

```
TUNING LOOP:
current_iteration = 0
max_iterations = 5
baseline_metrics = capture_pg_stat_snapshot()

WHILE current_iteration < max_iterations AND improvement_found:
  current_iteration += 1

  1. IDENTIFY bottleneck:
     - Run pg_stat_statements top-5 by total_time
     - Check cache hit ratio, dead tuple ratio, replication lag
     - Identify single worst offender

  2. APPLY fix:
     - Add index / rewrite query / tune autovacuum / adjust config
     - One change per iteration (isolate impact)

  3. MEASURE:
     - Re-run EXPLAIN ANALYZE on target query
     - Compare before/after metrics
     - Record: { iteration, change, metric_before, metric_after, improvement_pct }

  4. EVALUATE:
     - IF improvement < 5%: STOP (diminishing returns)
     - IF target met (e.g., cache hit > 99%, query < 50ms): STOP
     - ELSE: continue to next bottleneck

  OUTPUT after loop:
  Iteration | Change | Before | After | Improvement
  1         | ...    | ...    | ...   | ...
```

## Multi-Agent Dispatch

For large-scale PostgreSQL work, dispatch parallel agents:

```
PARALLEL AGENTS (when scope warrants):
Agent 1 — Schema & Extensions (worktree: pg-schema)
  - Analyze table structures, install/configure extensions
  - pgvector setup, PostGIS config, TimescaleDB hypertables

Agent 2 — Query Optimization (worktree: pg-queries)
  - Run pg_stat_statements analysis
  - Add indexes, rewrite slow queries
  - Fix N+1 patterns in ORM layer

Agent 3 — Replication & Partitioning (worktree: pg-infra)
  - Set up streaming/logical replication
  - Design and implement partitioning strategy
  - Configure pg_partman for automated partition management

Agent 4 — Connection Pooling & Tuning (worktree: pg-tuning)
  - Configure PgBouncer/Supavisor
  - Tune postgresql.conf memory/WAL/planner settings
  - Set up monitoring dashboards

MERGE ORDER: Agent 1 first (schema), then 2+3 in parallel, then 4.
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. NEVER run VACUUM FULL on a production table without explicit user confirmation
   and a maintenance window. It takes an EXCLUSIVE LOCK.
2. NEVER disable autovacuum. Tune it — never disable it.
3. NEVER increase max_connections above 200 without a connection pooler.
4. ALWAYS use CREATE INDEX CONCURRENTLY in production.
5. ALWAYS use REINDEX CONCURRENTLY, never plain REINDEX on live tables.
6. NEVER store passwords, tokens, or secrets in plain text columns.
7. ALWAYS include the partition key in WHERE clauses for partitioned tables.
8. NEVER use JSON type — use JSONB in 99.9% of cases.
9. ALWAYS run EXPLAIN (ANALYZE, BUFFERS) before claiming a query is optimized.
10. NEVER modify postgresql.conf without documenting the change and prior value.
11. ALWAYS test replication changes on a staging replica first.
12. NEVER run pg_basebackup or pg_dump during peak traffic without throttling.
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

## Example Usage

### Setting up pgvector for AI search
```
User: /godmode:postgres Set up pgvector for our document search

Postgres: Analyzing environment...

POSTGRES CONTEXT:
  Version: PostgreSQL 16
  Hosting: Supabase
  Extensions: pgvector already available

Setting up vector search:
1. Created embedding column (vector(1536) for OpenAI ada-002)
2. Built HNSW index with cosine distance
3. Created similarity search function with metadata filtering
4. Set hnsw.ef_search = 100 for high recall

Query: Find 10 most similar documents
  Time: 12ms (1.2M vectors, HNSW index)
  Recall@10: ~98% (verified against brute-force)
```

### Tuning autovacuum for a high-write table
```
User: /godmode:postgres Our orders table has 40% dead tuples

Postgres: Diagnosing...

TABLE STATUS:
  orders: 8.2M live rows, 3.3M dead tuples (40% bloat)
  Last autovacuum: 18 hours ago
  Autovacuum trigger: 50 + 0.2 * 8.2M = 1,640,050 dead tuples
  Current dead: 3,300,000 (above threshold but autovacuum is slow)

ROOT CAUSE: Default autovacuum_vacuum_cost_limit (200) is too conservative
  for this table's write rate (~50K updates/hour)

FIX:
  ALTER TABLE orders SET (
      autovacuum_vacuum_scale_factor = 0.02,
      autovacuum_vacuum_cost_delay = 2,
      autovacuum_vacuum_cost_limit = 1000
  );

  -- Immediate: run manual vacuum
  VACUUM (VERBOSE, PARALLEL 4) orders;

RESULT:
  Dead tuples: 3.3M -> 12K
  Table bloat: 40% -> 2%
  Autovacuum now triggers at: 1000 + 0.02 * 8.2M = 165,000 dead tuples
```

### Configuring streaming replication
```
User: /godmode:postgres Set up a read replica for our primary

Postgres: Setting up streaming replication...

PRIMARY (postgresql.conf):
  wal_level = replica
  max_wal_senders = 10
  wal_keep_size = 2GB

REPLICA:
  pg_basebackup completed (45GB, 12 minutes)
  Streaming replication established
  Replication lag: 0.3s

MONITORING:
  pg_stat_replication shows STREAMING state
  Lag alert configured at > 5s
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive PostgreSQL mastery workflow |
| `--extensions` | List, install, and configure PostgreSQL extensions |
| `--replication` | Set up streaming or logical replication |
| `--partition` | Design and implement table partitioning |
| `--vacuum` | Diagnose and fix VACUUM/autovacuum issues |
| `--tune` | Performance tuning for postgresql.conf |
| `--pooling` | Configure PgBouncer, Supavisor, or pgcat |
| `--fts` | Set up full-text search with ranking |
| `--jsonb` | JSONB schema design and query optimization |
| `--pgvector` | Set up pgvector for vector similarity search |
| `--postgis` | Configure PostGIS for geospatial queries |
| `--timescale` | Set up TimescaleDB for time-series data |
| `--diagnose` | Run full diagnostic (pg_stat, cache hits, bloat, locks) |
| `--audit` | Complete PostgreSQL health audit |

## Keep/Discard Discipline
```
After EACH PostgreSQL optimization:
  1. MEASURE: Run EXPLAIN (ANALYZE, BUFFERS) on the target query before and after.
  2. COMPARE: Is execution time lower? Is the plan using the new index/config?
  3. DECIDE:
     - KEEP if: query is faster AND no regression on other queries AND cache hit ratio stable or improved
     - DISCARD if: query regresses OR new index is unused OR config change degrades other workloads
  4. COMMIT kept changes. DROP INDEX / revert config on discarded changes before the next optimization.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Cache hit ratio > 99% and dead tuple ratio < 10% on all tables
  - All top-5 queries by total_exec_time are under target latency
  - Improvement per iteration < 5% (diminishing returns)
  - User explicitly requests stop

DO NOT STOP just because:
  - Non-critical tables still have unused indexes (address after critical path)
  - Replication lag monitoring is not yet dashboarded (pg_stat_replication queries suffice)
```

## Anti-Patterns

- **Do NOT store large BLOBs in PostgreSQL.** Store files in object storage (S3, GCS) and keep references in the database. Large objects bloat WAL and backups.
- **Do NOT partition small tables.** Partitioning adds query planning overhead. Only partition tables exceeding ~50M rows or 10GB.
- **Do NOT use synchronous replication without understanding the latency impact.** Synchronous commit waits for the replica to confirm, adding network round-trip to every write. Use asynchronous unless you need zero-data-loss guarantees.
- **Do NOT tune postgresql.conf randomly.** Use PGTune for initial settings, then profile with pg_stat_statements. Random tuning often makes things worse.

## Output Format

Every postgres invocation must produce a structured report:

```
+------------------------------------------------------------+
|  POSTGRES RESULT                                            |
+------------------------------------------------------------+
|  Version:        <version>                                  |
|  Hosting:        <platform>                                 |
|  Work performed: <description>                              |
|  Cache hit ratio: <pct>%                                    |
|  Dead tuple ratio: <pct>%                                   |
|  Unused indexes:  <count>                                   |
|  Replication lag: <seconds>s                                |
|  Verdict: <HEALTHY | NEEDS TUNING | DEGRADED>               |
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
  - Dead tuple ratio < 10% on all tables
  - Zero unused non-unique, non-primary-key indexes over 10MB
  - No queries > 60s in pg_stat_activity
  - No blocked queries (pg_blocking_pids returns empty)
  - Connections < 80% of max_connections
  - Replication lag < 1s (if replication is configured)
  - Transaction wraparound < 50% of limit
  - pg_stat_statements is installed

NEEDS TUNING if ANY of the following:
  - Cache hit ratio between 95-99%
  - Dead tuple ratio between 10-30% on any table
  - Unused indexes exist over 10MB
  - Queries > 30s in pg_stat_activity
  - Connections between 60-80% of max_connections

DEGRADED if ANY of the following:
  - Cache hit ratio < 95%
  - Dead tuple ratio > 30% on any table
  - Blocked queries exist for > 30s
  - Replication lag > 10s
  - Connections > 80% of max_connections without a pooler
  - Transaction wraparound > 75% of limit
```

## Error Recovery

```
IF a migration or DDL change locks a table in production:
  1. Check pg_stat_activity for blocking PIDs: SELECT pg_blocking_pids(pid) FROM pg_stat_activity WHERE wait_event_type = 'Lock'
  2. If the DDL is CREATE INDEX: cancel and use CREATE INDEX CONCURRENTLY instead
  3. If the DDL is ALTER TABLE: check if the operation requires a full table rewrite (adding NOT NULL, changing type) and schedule for maintenance window
  4. If queries are blocked: cancel the DDL (pg_cancel_backend), not the blocked queries
  5. For future DDL: always use lock_timeout = '3s' to fail fast rather than block

IF autovacuum is not keeping up with dead tuples:
  1. Check current autovacuum settings for the table: SELECT reloptions FROM pg_class WHERE relname = '<table>'
  2. Tune per-table: lower autovacuum_vacuum_scale_factor (0.01-0.05), increase autovacuum_vacuum_cost_limit (500-1000)
  3. Run manual VACUUM (VERBOSE, PARALLEL 4) <table> for immediate relief
  4. If bloat exceeds 50%: use pg_repack for online compaction (not VACUUM FULL)
  5. Monitor after tuning — check pg_stat_user_tables.n_dead_tup is trending down

IF replication lag spikes:
  1. Check pg_stat_replication on the primary for write_lag, flush_lag, replay_lag
  2. Check the replica for long-running queries that block replay (hot_standby_feedback)
  3. If network-related: check wal_keep_size is large enough to prevent WAL gap
  4. If CPU-related on replica: check max_parallel_workers on the replica
  5. If persistent: increase wal_sender_timeout and add more replicas for read distribution

IF connection pool exhaustion occurs:
  1. Check pg_stat_activity for idle-in-transaction connections: SELECT * FROM pg_stat_activity WHERE state = 'idle in transaction'
  2. Kill long-idle connections: SELECT pg_terminate_backend(pid) for connections idle > 5 minutes
  3. If no pooler exists: install PgBouncer in transaction mode immediately
  4. Tune pool sizes: default_pool_size = 20, max_db_connections = min(max_connections * 0.8, 100)
  5. Application-side: ensure every database connection is released after use (try/finally pattern)
```

## EXPLAIN ANALYZE Optimization Loop

Autonomous loop that identifies the slowest queries, runs EXPLAIN ANALYZE, applies fixes, and verifies improvement. One change per iteration to isolate impact. Never stops until targets are met or diminishing returns detected.

```
EXPLAIN ANALYZE OPTIMIZATION LOOP:
current_iteration = 0
max_iterations = 20
improvement_threshold = 5  // stop if improvement < 5%

// Phase 0: Capture Baseline from pg_stat_statements
baseline_queries = SELECT query, calls, mean_exec_time, total_exec_time, rows
  FROM pg_stat_statements
  ORDER BY total_exec_time DESC
  LIMIT 20;

baseline_health = {
  cache_hit_ratio: query_cache_hit_pct(),       // target: > 99%
  dead_tuple_ratio: max_dead_tuple_pct(),        // target: < 10%
  unused_indexes: count_unused_indexes(),         // target: 0
  long_queries: count_queries_over(threshold=30s) // target: 0
}

LOG: "BASELINE: cache_hit={baseline_health.cache_hit_ratio}%, dead_tuples={baseline_health.dead_tuple_ratio}%, unused_idx={baseline_health.unused_indexes}, long_queries={baseline_health.long_queries}"

WHILE current_iteration < max_iterations:
  current_iteration += 1

  // Phase 1: Identify Worst Offender
  target_query = select_worst_query(baseline_queries)
  // Priority: highest total_exec_time first (impact = calls * mean_time)

  plan_before = EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) target_query
  cost_before = plan_before.total_cost
  time_before = plan_before.execution_time_ms

  // Phase 2: Diagnose Plan
  diagnosis = analyze_plan(plan_before)
  // Detect: Seq Scan on large table, Nested Loop with high rows,
  // Sort without index, Hash Join spilling to disk, Bitmap Heap with
  // high recheck rate, parallel workers not used

  // Phase 3: Apply Single Fix (one per iteration)
  IF diagnosis.issue == "SEQ_SCAN_LARGE_TABLE":
    columns = extract_where_columns(target_query)
    CREATE INDEX CONCURRENTLY idx_{table}_{columns} ON {table} ({columns});
    ANALYZE {table};

  ELSE IF diagnosis.issue == "SORT_WITHOUT_INDEX":
    sort_cols = extract_order_by_columns(target_query)
    CREATE INDEX CONCURRENTLY idx_{table}_{sort_cols} ON {table} ({sort_cols});

  ELSE IF diagnosis.issue == "NESTED_LOOP_HIGH_ROWS":
    // Fix: add index on join column, or increase work_mem for hash join
    IF missing_index_on_join_column:
      CREATE INDEX CONCURRENTLY idx_{table}_{join_col} ON {table} ({join_col});
    ELSE:
      SET work_mem = '64MB' for this session and re-test

  ELSE IF diagnosis.issue == "BLOATED_TABLE":
    IF dead_tuple_pct > 30:
      VACUUM (VERBOSE, PARALLEL 4) {table};
    IF dead_tuple_pct > 60:
      -- Schedule pg_repack for online compaction

  ELSE IF diagnosis.issue == "MISSING_STATISTICS":
    ANALYZE {table};

  ELSE IF diagnosis.issue == "SUBOPTIMAL_CONFIG":
    // One config change per iteration
    IF random_page_cost == 4.0 AND storage == "SSD":
      SET random_page_cost = 1.1;
    ELSE IF effective_cache_size too low:
      SET effective_cache_size = '75% of RAM';

  // Phase 4: Verify Improvement
  plan_after = EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) target_query
  time_after = plan_after.execution_time_ms
  improvement_pct = ((time_before - time_after) / time_before) * 100

  // Phase 5: Keep/Discard
  IF time_after < time_before:
    KEEP the change
    LOG: "KEEP: {target_query.template} — {time_before}ms → {time_after}ms ({improvement_pct}% better)"
    UPDATE baseline_queries with new metrics
  ELSE:
    DISCARD the change (DROP INDEX, revert config)
    LOG: "DISCARD: {target_query.template} — regression detected ({time_before}ms → {time_after}ms), reverted"

  // Phase 6: Check Stopping Conditions
  IF improvement_pct < improvement_threshold AND improvement_pct >= 0:
    LOG: "Diminishing returns ({improvement_pct}% < {improvement_threshold}%). Stopping."
    BREAK

  REPORT: "Iteration {current_iteration}: {target_query.template} — {time_before}ms → {time_after}ms, fix: {diagnosis.issue}"

ON COMPLETION:
  // Final health check
  final_health = {
    cache_hit_ratio: query_cache_hit_pct(),
    dead_tuple_ratio: max_dead_tuple_pct(),
    unused_indexes: count_unused_indexes(),
    long_queries: count_queries_over(threshold=30s)
  }

  LOG to .godmode/postgres-explain-audit.tsv:
    timestamp\tquery_template\ttime_before_ms\ttime_after_ms\tfix_type\timprovement_pct\tverdict
  REPORT: "EXPLAIN ANALYZE loop complete: {current_iteration} iterations, cache_hit: {baseline_health.cache_hit_ratio}% → {final_health.cache_hit_ratio}%, top query: {best_improvement}% faster"
```

### Index Tuning Reference

```
INDEX TUNING DECISION TABLE:
┌──────────────────────────────────────┬────────────────────────┬─────────────────────────────┐
│ EXPLAIN ANALYZE Signal               │ Index Type             │ Action                      │
├──────────────────────────────────────┼────────────────────────┼─────────────────────────────┤
│ Seq Scan on WHERE col = ?            │ B-tree                 │ CREATE INDEX ON t(col)       │
│ Seq Scan on WHERE col LIKE '%x%'     │ GIN pg_trgm            │ CREATE INDEX USING GIN       │
│ Seq Scan on WHERE col @> '{}'        │ GIN                    │ CREATE INDEX USING GIN       │
│ Seq Scan on WHERE ST_DWithin(...)    │ GiST                   │ CREATE INDEX USING GIST      │
│ Sort without index                   │ B-tree (ORDER BY cols) │ CREATE INDEX ON t(sort_cols)  │
│ Filter removes > 90% of rows        │ Partial index          │ CREATE INDEX WHERE condition  │
│ Multiple columns in WHERE + ORDER    │ Composite B-tree       │ CREATE INDEX ON t(c1,c2,c3)  │
│ JSONB query (->>, @>)               │ GIN on jsonb_path_ops  │ CREATE INDEX USING GIN       │
│ Full-text search (tsvector)          │ GIN on tsvector column │ CREATE INDEX USING GIN       │
│ Vector similarity (pgvector)         │ HNSW or IVFFlat        │ CREATE INDEX USING hnsw      │
└──────────────────────────────────────┴────────────────────────┴─────────────────────────────┘

THRESHOLDS:
- Cache hit ratio: > 99% (HEALTHY), 95-99% (NEEDS TUNING), < 95% (DEGRADED)
- Dead tuple ratio: < 10% (HEALTHY), 10-30% (NEEDS TUNING), > 30% (DEGRADED)
- Query execution time: < 50ms (good), 50-500ms (review), > 500ms (must optimize)
- Improvement per iteration: stop if < 5% (diminishing returns)
- Unused indexes > 10MB: must be dropped (waste of write I/O and disk)
- Sequential scans on tables > 100K rows: must add index
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run Postgres tasks sequentially: schema/extensions, then query optimization, then replication/partitioning, then connection pooling/tuning.
- Use branch isolation per task: `git checkout -b godmode-postgres-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
