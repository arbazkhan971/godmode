# Recipe: Building a Data Pipeline

> From raw data to analytics dashboard. Extract, transform, load, validate, monitor.

---

## Context

You need to move data from one or more sources into a destination where it can be analyzed. Maybe it is syncing your production database to a data warehouse. Maybe it is aggregating events from Kafka into Elasticsearch. Maybe it is a simple daily CSV import. Regardless of complexity, the principles are the same: extract reliably, transform correctly, load safely, validate always, and monitor everything.

## The Chain

```
pipeline → schema → migrate → quality → observe → deploy
```

## When to Use This Recipe

- Syncing a production database to a data warehouse (PostgreSQL to BigQuery/Snowflake/Redshift)
- Building an ETL/ELT pipeline for analytics
- Aggregating event streams into a reporting database
- Building a data lake ingestion layer
- Migrating data between systems
- Creating a real-time or near-real-time analytics pipeline

---

## Session Transcript

### Phase 1: Pipeline Design

Map the complete data flow before writing code.

```
> /godmode:pipeline We need to sync our PostgreSQL production database
  (orders, customers, products) to BigQuery for our analytics team.
  They need data refreshed every 4 hours. We have about 2M orders,
  500K customers, and 50K products.

Godmode: Designing data flow...

DATA FLOW SPECIFICATION:
  Name:       prod_to_bigquery
  Type:       batch (incremental)
  Schedule:   every 4 hours (0 */4 * * *)
  SLA:        data available within 30 minutes of run start

  Sources:
    - production.orders:       PostgreSQL (2M rows, ~50K new/day)
    - production.customers:    PostgreSQL (500K rows, ~2K new/day)
    - production.products:     PostgreSQL (50K rows, ~100 new/day)
    - production.order_items:  PostgreSQL (8M rows, FK to orders)

  Transformations:
    1. Incremental extract (watermark: updated_at)
    2. Deduplicate by primary key (keep latest)
    3. Clean and normalize (trim strings, validate emails)
    4. Join orders + order_items for denormalized fact table
    5. Compute derived fields (order_total, item_count, customer_lifetime_value)
    6. Apply business rules (exclude test orders, handle refunds)

  Destinations:
    - analytics.raw_orders:      BigQuery (append, partitioned by date)
    - analytics.raw_customers:   BigQuery (upsert by customer_id)
    - analytics.raw_products:    BigQuery (upsert by product_id)
    - analytics.fact_orders:     BigQuery (denormalized, partitioned by order_date)
    - analytics.dim_customers:   BigQuery (SCD Type 2 for history)

  Data volume:
    Initial load: ~2M orders + 8M items + 500K customers
    Incremental: ~50K orders/day, ~2K customers/day

  Idempotency: YES (upsert + dedup ensures safe re-runs)
  Error handling: DLQ for bad records, retry with backoff for transient errors

Saved: docs/specs/prod-to-bigquery-pipeline.md
Commit: "pipeline: design — prod PostgreSQL to BigQuery, 4-hour batch"
```

### Phase 2: Schema Design

Define the target schema and contracts between pipeline stages.

```
> /godmode:schema --target bigquery

Godmode: Designing warehouse schema...

TARGET SCHEMA:

  analytics.raw_orders (staging layer):
    order_id        INT64 NOT NULL
    customer_id     INT64 NOT NULL
    status          STRING
    total           NUMERIC(10,2)
    currency        STRING
    created_at      TIMESTAMP
    updated_at      TIMESTAMP
    _loaded_at      TIMESTAMP    -- pipeline metadata
    _source_hash    STRING       -- dedup key
    _partition_date DATE         -- partition column

  analytics.fact_orders (mart layer):
    order_id        INT64 NOT NULL
    customer_id     INT64 NOT NULL
    customer_name   STRING
    customer_email  STRING
    item_count      INT64
    order_total     NUMERIC(10,2)
    currency        STRING
    status          STRING
    is_refunded     BOOL
    order_date      DATE
    created_at      TIMESTAMP
    _loaded_at      TIMESTAMP

  analytics.dim_customers (SCD Type 2):
    customer_key    INT64        -- surrogate key
    customer_id     INT64        -- natural key
    name            STRING
    email           STRING
    tier            STRING       -- bronze, silver, gold
    lifetime_value  NUMERIC(10,2)
    effective_from  TIMESTAMP
    effective_to    TIMESTAMP    -- NULL = current
    is_current      BOOL

SCHEMA CONTRACTS:
  Every stage boundary has a Pydantic/Pandera schema:
  - raw_extract_schema:   validates data coming from PostgreSQL
  - clean_schema:         validates data after cleaning
  - fact_schema:          validates denormalized fact table
  - dim_schema:           validates dimension table

Commit: "schema: BigQuery target schema — raw, fact, dimension tables"
```

### Phase 3: Migration and Initial Load

```
> /godmode:migrate --initial-load

Godmode: Setting up target tables and running initial load...

MIGRATION:
  1. Created BigQuery dataset: analytics
  2. Created tables: raw_orders, raw_customers, raw_products,
     fact_orders, dim_customers
  3. Applied partitioning: raw_orders by _partition_date,
     fact_orders by order_date
  4. Applied clustering: fact_orders by customer_id, status

INITIAL LOAD:
  Extracting full history from PostgreSQL...
    orders:      2,034,567 rows extracted (4.2 GB)
    order_items: 8,112,340 rows extracted (12.1 GB)
    customers:   512,890 rows extracted (890 MB)
    products:    48,230 rows extracted (120 MB)

  Transforming...
    ✓ Deduplication: 0 duplicates found (clean source)
    ✓ Cleaning: 234 emails normalized, 12 invalid emails flagged
    ✓ Joins: orders + items joined successfully
    ✓ Derived fields: order_total, customer_lifetime_value computed

  Loading to BigQuery...
    ✓ raw_orders:    2,034,567 rows loaded
    ✓ raw_customers: 512,890 rows loaded
    ✓ raw_products:  48,230 rows loaded
    ✓ fact_orders:   2,034,567 rows loaded
    ✓ dim_customers: 512,890 rows loaded (all current)

  Reconciliation:
    ✓ orders:    source 2,034,567 = target 2,034,567
    ✓ customers: source 512,890 = target 512,890
    ✓ products:  source 48,230 = target 48,230

  Duration: 18 minutes

Commit: "migrate: initial load — 2M orders, 500K customers to BigQuery"
```

### Phase 4: Data Quality

```
> /godmode:quality --pipeline

Godmode: Configuring data quality checks...

QUALITY CHECKS CONFIGURED:

  Row-level checks:
    ✓ NOT NULL: order_id, customer_id, total (all tables)
    ✓ UNIQUE: order_id (fact_orders), customer_id+effective_from (dim_customers)
    ✓ RANGE: total >= 0, item_count >= 1
    ✓ PATTERN: email matches ^[^@]+@[^@]+\.[^@]+$
    ✓ REFERENTIAL: customer_id in fact_orders exists in dim_customers
    ✓ FRESHNESS: latest order < 5 hours old (aligns with 4-hour schedule)

  Dataset-level checks:
    ✓ ROW COUNT: alert if daily count changes by > 50%
    ✓ COMPLETENESS: email fill rate > 99%
    ✓ DISTRIBUTION: order status values within expected set
    ✓ TIMELINESS: data arrives within 30 minutes of schedule

  Cross-pipeline checks:
    ✓ SOURCE-TARGET RECONCILIATION: exact count match per batch
    ✓ AGGREGATE RECONCILIATION: SUM(total) match within 0.01%

  dbt tests generated:
    models/staging/stg_orders.yml     — 8 tests
    models/marts/fact_orders.yml      — 12 tests
    models/marts/dim_customers.yml    — 6 tests

Commit: "quality: 26 data quality checks across all pipeline stages"
```

### Phase 5: Observability

```
> /godmode:observe --pipeline

Godmode: Setting up pipeline monitoring...

OBSERVABILITY CONFIGURED:

  Metrics (Datadog):
    pipeline_duration_seconds{pipeline="prod_to_bigquery", stage="*"}
    pipeline_rows_processed_total{pipeline="prod_to_bigquery", table="*"}
    pipeline_rows_rejected_total{pipeline="prod_to_bigquery", table="*"}
    pipeline_data_freshness_seconds{pipeline="prod_to_bigquery"}
    pipeline_quality_score{pipeline="prod_to_bigquery"}

  Logging (structured, JSON):
    Every stage logs: start, record counts, duration, errors
    Dead-letter queue: rejected records with error context

  Alerts:
    CRITICAL: Pipeline failed (pages on-call)
    CRITICAL: Source-target count mismatch (pages on-call)
    WARNING:  Pipeline > 2x expected duration (Slack)
    WARNING:  Quality score < 99% (Slack)
    WARNING:  Row count change > 50% (Slack)
    INFO:     Pipeline succeeded (Slack daily digest)

  Dashboard:
    Created Datadog dashboard: "Data Pipeline — prod_to_bigquery"
    Panels:
      - Pipeline run history (success/fail)
      - Duration trend (with p95 line)
      - Rows processed per run
      - Data freshness gauge
      - Quality score trend
      - Error rate by type

Commit: "observe: pipeline monitoring — metrics, alerts, dashboard"
```

### Phase 6: Deploy

```
> /godmode:deploy --pipeline

Godmode: Deploying pipeline to production...

ORCHESTRATOR: Airflow (Cloud Composer)

DAG deployed: dags/prod_to_bigquery.py
  Schedule: 0 */4 * * * (every 4 hours)
  Tasks:
    extract_orders → extract_customers → extract_products
         ↓                    ↓                  ↓
    stage_raw ─────────────────────────────────────
         ↓
    transform_orders → transform_customers
         ↓                    ↓
    quality_checks ────────────
         ↓
    load_fact_orders → load_dim_customers
         ↓                    ↓
    reconcile ─────────────────
         ↓
    notify_success

  Error handling:
    retries: 2 per task
    retry_delay: 5 minutes
    email_on_failure: data-alerts@company.com

VERIFICATION:
  ✓ DAG parsed successfully
  ✓ Connections configured (PostgreSQL source, BigQuery target)
  ✓ First manual run: SUCCESS (18 min, 52K new orders loaded)
  ✓ Reconciliation: PASS (exact match)
  ✓ Quality checks: PASS (score 99.97%)
  ✓ Alerts: test alert received in Slack

Commit: "deploy: Airflow DAG — prod_to_bigquery, 4-hour schedule"
```

---

## Pipeline Architecture Patterns

### Pattern 1: ELT with dbt (Most Common)

```
ARCHITECTURE:
  Extract + Load: Fivetran / Airbyte / custom scripts
  Transform: dbt (SQL in the warehouse)
  Orchestrate: Airflow / dbt Cloud / Dagster

  Flow:
    Source DB → [Fivetran] → Raw Layer → [dbt] → Staging → Marts → Dashboard

  Best for:
    - Analytics pipelines
    - When the warehouse has strong compute (BigQuery, Snowflake)
    - When transformations are mostly SQL

  dbt project structure:
    models/
      staging/       # 1:1 with source tables, light cleaning
      intermediate/  # Reusable logic, ephemeral models
      marts/         # Business-facing tables (facts + dimensions)
    tests/           # Data quality tests
    macros/          # Reusable SQL functions
    seeds/           # Static reference data (country codes, etc.)
```

### Pattern 2: ETL with Python (Custom Logic)

```
ARCHITECTURE:
  Extract: Python scripts with watermarking
  Transform: Pandas / Polars / PySpark
  Load: Direct to target via ORM or bulk insert
  Orchestrate: Airflow / Dagster / Prefect

  Flow:
    Source → [Python extract] → Raw files (S3) → [Python transform] → Target DB

  Best for:
    - Complex transformations that are hard in SQL
    - Multiple heterogeneous sources (APIs, files, databases)
    - When you need Python libraries (ML, NLP, geo)
```

### Pattern 3: Streaming (Real-Time)

```
ARCHITECTURE:
  Source: Kafka / Kinesis / Pub/Sub
  Process: Flink / Kafka Streams / Spark Streaming
  Sink: Database / Elasticsearch / S3
  Orchestrate: continuous (no scheduler)

  Flow:
    Event Source → Kafka → [Flink] → Sink → Dashboard

  Best for:
    - Real-time analytics (< 1 minute latency)
    - Event-driven architectures
    - Fraud detection, anomaly detection, alerting
```

---

## Building the Analytics Dashboard

Once data is in the warehouse, connect a BI tool.

```
DASHBOARD OPTIONS:
  Metabase     — Open source, self-hosted, good for small teams
  Looker       — Enterprise, strong semantic layer, Google-native
  Superset     — Open source, feature-rich, steeper learning curve
  Mode         — SQL-first, good for data teams
  Lightdash    — dbt-native, metrics layer from dbt models

RECOMMENDED FOR SPEED: Metabase
  - Self-host on Railway/Render in 5 minutes
  - Connect to BigQuery/Snowflake/PostgreSQL
  - Auto-generates dashboards from table structure
  - Non-technical users can build their own reports

DASHBOARD DESIGN:
  Executive dashboard:
    - Revenue this month (vs last month)
    - Orders per day (trend chart)
    - Top 10 products by revenue
    - Customer acquisition (new vs returning)
    - Order status distribution (pie chart)

  Operations dashboard:
    - Pipeline health (last run status, duration)
    - Data freshness indicator
    - Quality score trend
    - Failed records in DLQ
    - Row counts per table (trend)
```

---

## Common Gotchas

### 1. The initial backfill takes 10x longer than you expect
Your incremental pipeline processes 50K rows in 2 minutes. The initial backfill of 2M rows does not take 80 minutes — it takes 6 hours because of memory pressure, API rate limits, and transaction lock contention. Plan for it.

### 2. Schema changes at the source break everything
Production deploys a new column. Or renames one. Or changes a type from integer to string. Your pipeline silently loads wrong data or loudly crashes. Solution: schema contracts with version tracking at every boundary.

### 3. Time zones are a nightmare
Is `created_at` in UTC? Server local time? User local time? It depends on who wrote the code. Always extract timestamps in UTC. Always store in UTC. Convert to local time only at the dashboard layer.

### 4. Deleted records are invisible to incremental extraction
If your watermark is `WHERE updated_at > :last_run`, you never see hard deletes. Solutions: soft deletes (status column), CDC (Debezium), or periodic full reconciliation.

### 5. "The data looks wrong" is the hardest bug
Data issues hide. A wrong JOIN produces plausible-looking numbers that are 15% off. The only defense is reconciliation: compare source and target counts, sums, and distributions after every load.

---

## See Also

- [Master Skill Index](../skill-index.md) — `/godmode:pipeline` and `/godmode:quality` references
- [Skill Chains](../skill-chains.md) — ml-pipeline chain for ML workflows
- [Building an API Gateway](api-gateway.md) — If your pipeline sources are APIs
