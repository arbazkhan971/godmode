---
name: pipeline
description: |
  Data pipeline and ETL skill. Activates when a developer needs to design, build, test, or debug data flows -- from simple scripts to complex orchestrated pipelines. Covers extraction, transformation, loading, data quality validation, schema evolution, and pipeline observability. Works with any pipeline tool (Airflow, dbt, Spark, Dagster, Prefect, Luigi, custom scripts, cron jobs, Kafka, Flink, AWS Glue, Cloud Dataflow) and any data store (SQL databases, data warehouses, object storage, APIs, message queues). Triggers on: /godmode:pipeline, "build a data pipeline", "ETL", "data flow", "sync data", "transform data", "data quality", or when data movement between systems is needed.
---

# Pipeline -- Data Pipeline & ETL

## When to Activate
- User invokes `/godmode:pipeline`
- User says "build a data pipeline," "ETL," "data flow," "sync data between X and Y"
- User needs to move, transform, or load data between systems
- User asks about data quality checks or validation
- User needs to debug a failing pipeline or data inconsistency
- User asks about scheduling, orchestration, or dependency management for data jobs
- User needs to design a streaming or batch processing architecture

## Workflow

### Step 1: Understand the Data Flow

Map the complete data flow before writing any code:

```
DATA FLOW SPECIFICATION:
Name:           <pipeline name>
Type:           <batch | streaming | micro-batch | CDC | hybrid>
Schedule:       <cron expression | event-triggered | continuous | manual>
SLA:            <max acceptable latency from source event to target availability>

Sources:
  - <source 1>: <database/API/file/queue> (<format>, <volume/day>, <access method>)
  - <source 2>: <database/API/file/queue> (<format>, <volume/day>, <access method>)

Transformations:
  1. <step description> (input -> output)
  2. <step description> (input -> output)
  3. <step description> (input -> output)

Destinations:
  - <target 1>: <database/warehouse/lake/API> (<format>, <write method>)
  - <target 2>: <database/warehouse/lake/API> (<format>, <write method>)

Data volume:    <rows/day or GB/day>
Freshness:      <how recent must the data be?>
Idempotency:    <can the pipeline be re-run safely?>
Error handling: <skip | fail | dead-letter | retry>
```

### Step 2: Detect Pipeline Environment

Identify the orchestration tool and infrastructure:

```
PIPELINE ENVIRONMENT:
Orchestrator:   <Airflow | dbt | Dagster | Prefect | Luigi | Temporal | Step Functions |
                 Argo Workflows | cron | custom | none>
Detection:      <how detected -- dags/ folder, dbt_project.yml, dagster.yaml, etc.>
Compute:        <local | Spark | BigQuery | Redshift | Snowflake | Databricks | Lambda | ECS>
Storage:        <S3 | GCS | Azure Blob | HDFS | local filesystem>
Message queue:  <Kafka | RabbitMQ | SQS | Pub/Sub | Redis Streams | none>
Monitoring:     <CloudWatch | Datadog | Prometheus | built-in | none>
```

Detection rules:
```
IF dags/ directory OR airflow.cfg OR DAG imports:
  Orchestrator = Airflow

IF dbt_project.yml:
  Orchestrator = dbt
  Compute = <warehouse from profiles.yml>

IF dagster.yaml OR Definitions() in code:
  Orchestrator = Dagster

IF prefect imports OR prefect.yaml:
  Orchestrator = Prefect

IF luigi imports OR luigi.cfg:
  Orchestrator = Luigi

IF serverless.yml with step functions:
  Orchestrator = Step Functions

IF Makefile/scripts with data steps OR crontab:
  Orchestrator = cron/custom

IF kafka imports OR confluent imports:
  Message queue = Kafka

IF spark imports OR pyspark:
  Compute = Spark
```

### Step 3: Design the Pipeline Architecture

#### 3a: Choose Pipeline Pattern

Select the appropriate pattern based on requirements:

```
BATCH PIPELINE (most common):
When: Data is processed on a schedule (hourly, daily)
Pattern: Extract -> Stage -> Transform -> Validate -> Load
Tools:  Airflow + dbt, Dagster, Prefect, cron + scripts

Example DAG:
  extract_orders -> stage_raw -> transform_orders -> validate -> load_warehouse
       |                              |
  extract_customers -----> join_data --+

STREAMING PIPELINE:
When: Data must be available within seconds/minutes
Pattern: Source -> Stream Processor -> Sink
Tools:  Kafka + Flink, Kafka Streams, Spark Streaming, AWS Kinesis

Example:
  kafka_topic -> flink_job -> enrichment -> output_topic -> sink_connector -> database

MICRO-BATCH:
When: Near-real-time (minutes), but true streaming is overkill
Pattern: Poll source -> Process batch -> Write -> Repeat
Tools:  Spark Structured Streaming, custom scripts with polling

CDC (Change Data Capture):
When: Replicate database changes to another system
Pattern: Source DB -> CDC tool -> Stream/Batch -> Target
Tools:  Debezium, AWS DMS, Fivetran, Airbyte

ELT (Extract-Load-Transform):
When: Warehouse has sufficient compute, transformation is SQL-based
Pattern: Extract -> Load raw -> Transform in warehouse
Tools:  Fivetran/Airbyte (EL) + dbt (T)
```

#### 3b: Define Schema Contracts

Every pipeline boundary needs a schema contract:

```
SCHEMA CONTRACT: <stage name>
Version:    <schema version>
Format:     <JSON | Avro | Parquet | CSV | Protobuf>

Fields:
  - name: <field name>
    type: <string | int | float | boolean | timestamp | array | object>
    nullable: <true | false>
    description: <what this field represents>
    constraints: <min/max, regex pattern, enum values, foreign key>

Example record:
  { "field1": "value1", "field2": 42, ... }

Breaking changes require:
  1. Schema version bump
  2. Backward-compatible transition period
  3. Consumer notification
```

### Step 4: Implement Pipeline Components

#### 4a: Extraction

Build resilient extractors for each source:

```python
# PATTERN: Idempotent extraction with watermarking
class Extractor:
    """
    Every extractor MUST:
    1. Track a watermark (last extracted timestamp/ID)
    2. Extract data >= watermark (overlap is OK, duplicates handled downstream)
    3. Handle source failures gracefully (retry with backoff)
    4. Log extraction metrics (rows extracted, time taken, errors)
    """

    def extract(self, watermark: datetime) -> DataFrame:
        # Fetch data from source since watermark
        # Return raw data with metadata columns (_extracted_at, _source)
        pass

    def get_watermark(self) -> datetime:
        # Read last successful watermark from state store
        pass

    def set_watermark(self, watermark: datetime):
        # Write watermark after successful extraction
        pass
```

Source-specific patterns:
```python
# API extraction with pagination and rate limiting
def extract_from_api(endpoint, watermark, page_size=100):
    page = 1
    all_records = []
    while True:
        response = requests.get(endpoint, params={
            'updated_since': watermark.isoformat(),
            'page': page,
            'per_page': page_size,
        })
        response.raise_for_status()
        records = response.json()['data']
        if not records:
            break
        all_records.extend(records)
        page += 1
        time.sleep(0.1)  # Rate limiting
    return all_records

# Database extraction with change tracking
def extract_from_db(connection, table, watermark):
    query = f"""
        SELECT *, NOW() as _extracted_at
        FROM {table}
        WHERE updated_at >= %s
        ORDER BY updated_at ASC
    """
    return pd.read_sql(query, connection, params=[watermark])

# File extraction with deduplication
def extract_from_files(bucket, prefix, processed_files_log):
    new_files = list_files(bucket, prefix) - read_processed_log(processed_files_log)
    for file in sorted(new_files):
        yield read_file(bucket, file)
        log_processed_file(processed_files_log, file)
```

#### 4b: Transformation

Build testable, composable transformation functions:

```python
# PATTERN: Pure transformation functions (no side effects)
# Every transformation function:
# 1. Takes a DataFrame/record as input
# 2. Returns a DataFrame/record as output
# 3. Has NO side effects (no DB calls, no file writes)
# 4. Is independently testable

def clean_emails(df: pd.DataFrame) -> pd.DataFrame:
    """Normalize and validate email addresses."""
    df = df.copy()
    df['email'] = df['email'].str.strip().str.lower()
    df['email_valid'] = df['email'].str.match(r'^[^@]+@[^@]+\.[^@]+$')
    return df

def deduplicate(df: pd.DataFrame, key_columns: list) -> pd.DataFrame:
    """Remove duplicate records, keeping the most recent."""
    return df.sort_values('updated_at', ascending=False).drop_duplicates(
        subset=key_columns, keep='first'
    )

def enrich_with_geo(df: pd.DataFrame, geo_lookup: dict) -> pd.DataFrame:
    """Add geographic data based on country code."""
    df = df.copy()
    df['region'] = df['country_code'].map(geo_lookup)
    return df

# Compose transformations into a pipeline
def transform_orders(raw_orders: pd.DataFrame) -> pd.DataFrame:
    return (
        raw_orders
        .pipe(clean_emails)
        .pipe(deduplicate, key_columns=['order_id'])
        .pipe(enrich_with_geo, geo_lookup=GEO_DATA)
        .pipe(validate_schema, schema=ORDER_SCHEMA)
    )
```

dbt transformation example:
```sql
-- models/staging/stg_orders.sql
WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
),

cleaned AS (
    SELECT
        order_id,
        LOWER(TRIM(customer_email)) AS customer_email,
        order_total::DECIMAL(10,2) AS order_total,
        COALESCE(status, 'unknown') AS status,
        created_at,
        updated_at,
        CURRENT_TIMESTAMP AS _loaded_at
    FROM source
    WHERE order_id IS NOT NULL
)

SELECT * FROM cleaned

-- models/staging/stg_orders.yml (schema test)
version: 2
models:
  - name: stg_orders
    columns:
      - name: order_id
        tests:
          - unique
          - not_null
      - name: customer_email
        tests:
          - not_null
      - name: order_total
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
```

#### 4c: Loading

Write data to the target with safety:

```python
# PATTERN: Idempotent loading strategies

# Strategy 1: UPSERT (merge) -- most common for dimension tables
def load_upsert(df, target_table, key_columns, connection):
    """Insert or update based on key columns."""
    temp_table = f"_staging_{target_table}"
    df.to_sql(temp_table, connection, if_exists='replace', index=False)
    merge_sql = f"""
        INSERT INTO {target_table} ({', '.join(df.columns)})
        SELECT {', '.join(df.columns)} FROM {temp_table}
        ON CONFLICT ({', '.join(key_columns)})
        DO UPDATE SET {', '.join(f'{c} = EXCLUDED.{c}' for c in df.columns if c not in key_columns)};
        DROP TABLE {temp_table};
    """
    connection.execute(merge_sql)

# Strategy 2: SWAP (partition swap) -- best for full refreshes
def load_swap(df, target_table, connection):
    """Load into staging table, then atomically swap."""
    staging = f"{target_table}_staging"
    df.to_sql(staging, connection, if_exists='replace', index=False)
    connection.execute(f"""
        BEGIN;
        ALTER TABLE {target_table} RENAME TO {target_table}_old;
        ALTER TABLE {staging} RENAME TO {target_table};
        DROP TABLE {target_table}_old;
        COMMIT;
    """)

# Strategy 3: APPEND (insert only) -- best for fact/event tables
def load_append(df, target_table, connection):
    """Append new records. Relies on upstream deduplication."""
    df.to_sql(target_table, connection, if_exists='append', index=False)

# Strategy 4: SCD Type 2 (slowly changing dimensions)
def load_scd2(df, target_table, key_columns, connection):
    """Track historical changes with effective dates."""
    # Close existing current records that have changes
    # Insert new versions with effective_from = now, effective_to = null
    pass  # Implementation depends on schema design
```

### Step 5: Implement Data Quality Checks

Data quality is not optional. Every pipeline needs these checks:

#### 5a: Row-Level Validation

```python
QUALITY_CHECKS = {
    'not_null': {
        'columns': ['order_id', 'customer_id', 'total'],
        'action': 'reject',  # reject | warn | fill_default
    },
    'unique': {
        'columns': ['order_id'],
        'action': 'reject_duplicates',
    },
    'range': {
        'total': {'min': 0, 'max': 1_000_000},
        'quantity': {'min': 1, 'max': 10_000},
        'action': 'reject',
    },
    'pattern': {
        'email': r'^[^@]+@[^@]+\.[^@]+$',
        'phone': r'^\+?[0-9]{10,15}$',
        'action': 'warn',
    },
    'referential': {
        'customer_id': {'table': 'customers', 'column': 'id'},
        'action': 'reject',
    },
    'freshness': {
        'updated_at': {'max_age_hours': 24},
        'action': 'alert',
    },
}
```

#### 5b: Dataset-Level Validation

```python
DATASET_CHECKS = {
    'row_count': {
        'min': 1,           # Not empty
        'max': 10_000_000,  # Not suspiciously large
        'change_threshold': 0.5,  # Alert if count changes by > 50%
    },
    'completeness': {
        'min_fill_rate': 0.95,  # At least 95% non-null for key columns
        'columns': ['customer_id', 'total', 'status'],
    },
    'distribution': {
        'status': {
            'expected_values': ['active', 'completed', 'cancelled', 'refunded'],
            'max_unknown_rate': 0.01,  # Max 1% unknown values
        },
    },
    'timeliness': {
        'max_delay_minutes': 60,  # Data should arrive within 60 min
    },
}
```

#### 5c: Cross-Pipeline Validation

```python
CROSS_CHECKS = {
    'source_target_reconciliation': {
        'source_count_query': 'SELECT COUNT(*) FROM source_orders WHERE date = :date',
        'target_count_query': 'SELECT COUNT(*) FROM warehouse.orders WHERE date = :date',
        'tolerance': 0,  # Exact match required
    },
    'aggregate_reconciliation': {
        'source_sum_query': 'SELECT SUM(total) FROM source_orders WHERE date = :date',
        'target_sum_query': 'SELECT SUM(total) FROM warehouse.orders WHERE date = :date',
        'tolerance_pct': 0.01,  # Within 1%
    },
}
```

#### 5d: Data Quality Report

```
DATA QUALITY REPORT:
Pipeline:       <pipeline name>
Run:            <run ID or timestamp>
Duration:       <execution time>

+---------------------------------------------------------------+
|  Check                    | Status | Details                   |
+---------------------------------------------------------------+
|  Row count                | PASS   | 45,230 rows (expected     |
|                           |        | 40K-50K)                  |
|  Null check (order_id)    | PASS   | 0 nulls                   |
|  Null check (email)       | WARN   | 23 nulls (0.05%)          |
|  Uniqueness (order_id)    | PASS   | 0 duplicates              |
|  Range (total)            | FAIL   | 3 rows with negative      |
|                           |        | total (rejected)          |
|  Freshness                | PASS   | Latest record: 12 min ago |
|  Source-target recon      | PASS   | Exact match: 45,230       |
+---------------------------------------------------------------+
|  Records processed: 45,233                                    |
|  Records loaded:    45,230                                    |
|  Records rejected:  3 (sent to dead-letter queue)             |
|  Data quality score: 99.99%                                   |
+---------------------------------------------------------------+
```

### Step 6: Implement Observability

Every pipeline must be observable:

#### 6a: Logging

```python
# Structured logging for every pipeline stage
import structlog

log = structlog.get_logger()

log.info("extraction_complete",
    source="orders_api",
    rows_extracted=45230,
    watermark="2025-01-15T10:30:00Z",
    duration_seconds=12.4,
    api_calls=453,
)

log.info("transformation_complete",
    stage="clean_emails",
    rows_in=45230,
    rows_out=45207,
    rows_rejected=23,
    duration_seconds=2.1,
)

log.info("load_complete",
    target="warehouse.orders",
    strategy="upsert",
    rows_inserted=44890,
    rows_updated=317,
    duration_seconds=8.7,
)
```

#### 6b: Metrics

```
Essential pipeline metrics:
  - pipeline_duration_seconds       (histogram)
  - pipeline_rows_processed_total   (counter)
  - pipeline_rows_rejected_total    (counter)
  - pipeline_last_success_timestamp (gauge)
  - pipeline_data_freshness_seconds (gauge)
  - pipeline_quality_score          (gauge)
```

#### 6c: Alerting

```
ALERT RULES:
  - Pipeline failed:              Page on-call
  - Pipeline > 2x expected duration: Warn in Slack
  - Data quality score < 99%:     Warn in Slack
  - Data quality score < 95%:     Page on-call
  - No data received in > 2 hours: Page on-call
  - Row count change > 50%:       Warn in Slack (possible schema change at source)
  - Source-target reconciliation mismatch: Page on-call
```

### Step 7: Implement Error Handling and Recovery

```python
# Error handling strategies

# Strategy 1: Dead Letter Queue (DLQ)
# Bad records go to a separate table/queue for investigation
def process_with_dlq(records, transform_fn, dlq):
    good_records = []
    for record in records:
        try:
            good_records.append(transform_fn(record))
        except Exception as e:
            dlq.send({
                'record': record,
                'error': str(e),
                'pipeline': PIPELINE_NAME,
                'timestamp': datetime.utcnow().isoformat(),
            })
    return good_records

# Strategy 2: Retry with exponential backoff
@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=4, max=60),
    retry=retry_if_exception_type((ConnectionError, TimeoutError)),
)
def extract_from_api(endpoint):
    return requests.get(endpoint, timeout=30).json()

# Strategy 3: Checkpoint and resume
class CheckpointedPipeline:
    def run(self):
        checkpoint = self.load_checkpoint()
        for batch in self.get_batches(start_from=checkpoint):
            self.process_batch(batch)
            self.save_checkpoint(batch.last_id)
        self.clear_checkpoint()

# Strategy 4: Circuit breaker
# If source fails N times in a row, stop trying and alert
class CircuitBreaker:
    def __init__(self, failure_threshold=5, reset_timeout=300):
        self.failures = 0
        self.threshold = failure_threshold
        self.reset_timeout = reset_timeout
        self.last_failure = None
        self.state = 'closed'  # closed = normal, open = failing

    def call(self, fn, *args, **kwargs):
        if self.state == 'open':
            if time.time() - self.last_failure > self.reset_timeout:
                self.state = 'half-open'
            else:
                raise CircuitBreakerOpen("Source is down, skipping")

        try:
            result = fn(*args, **kwargs)
            self.failures = 0
            self.state = 'closed'
            return result
        except Exception as e:
            self.failures += 1
            self.last_failure = time.time()
            if self.failures >= self.threshold:
                self.state = 'open'
            raise
```

### Step 8: Generate Orchestrator Configuration

Create the orchestration configuration for the detected tool:

#### Airflow DAG
```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'email_on_failure': True,
    'email': ['data-alerts@company.com'],
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'orders_pipeline',
    default_args=default_args,
    description='Extract orders, transform, load to warehouse',
    schedule_interval='0 */4 * * *',  # Every 4 hours
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=['orders', 'warehouse'],
) as dag:

    extract = PythonOperator(
        task_id='extract_orders',
        python_callable=extract_orders,
    )

    validate_raw = PythonOperator(
        task_id='validate_raw_data',
        python_callable=validate_raw_data,
    )

    transform = PythonOperator(
        task_id='transform_orders',
        python_callable=transform_orders,
    )

    validate_clean = PythonOperator(
        task_id='validate_clean_data',
        python_callable=validate_clean_data,
    )

    load = PythonOperator(
        task_id='load_to_warehouse',
        python_callable=load_to_warehouse,
    )

    reconcile = PythonOperator(
        task_id='reconcile_counts',
        python_callable=reconcile_source_target,
    )

    extract >> validate_raw >> transform >> validate_clean >> load >> reconcile
```

#### dbt Project
```yaml
# dbt_project.yml
name: 'analytics'
version: '1.0.0'
profile: 'warehouse'

models:
  analytics:
    staging:
      +materialized: view
      +schema: staging
    intermediate:
      +materialized: ephemeral
    marts:
      +materialized: table
      +schema: analytics

tests:
  +severity: warn

seeds:
  +schema: seeds
```

#### Dagster
```python
from dagster import asset, Definitions, ScheduleDefinition

@asset(group_name="orders")
def raw_orders():
    """Extract orders from source API."""
    return extract_orders()

@asset(group_name="orders")
def cleaned_orders(raw_orders):
    """Clean and validate order data."""
    return transform_orders(raw_orders)

@asset(group_name="orders")
def warehouse_orders(cleaned_orders):
    """Load cleaned orders to warehouse."""
    return load_to_warehouse(cleaned_orders)

orders_schedule = ScheduleDefinition(
    name="orders_every_4_hours",
    cron_schedule="0 */4 * * *",
    target=["raw_orders", "cleaned_orders", "warehouse_orders"],
)

defs = Definitions(
    assets=[raw_orders, cleaned_orders, warehouse_orders],
    schedules=[orders_schedule],
)
```

### Step 9: Test the Pipeline

#### 9a: Unit Tests (transformation functions)
```python
def test_clean_emails():
    df = pd.DataFrame({'email': ['  User@EXAMPLE.com  ', 'bad-email', None]})
    result = clean_emails(df)
    assert result['email'][0] == 'user@example.com'
    assert result['email_valid'][0] == True
    assert result['email_valid'][1] == False

def test_deduplicate():
    df = pd.DataFrame({
        'order_id': [1, 1, 2],
        'total': [100, 150, 200],
        'updated_at': ['2025-01-01', '2025-01-02', '2025-01-01'],
    })
    result = deduplicate(df, key_columns=['order_id'])
    assert len(result) == 2
    assert result[result['order_id'] == 1]['total'].values[0] == 150  # Kept latest
```

#### 9b: Integration Tests (end-to-end with test data)
```python
def test_full_pipeline():
    # Setup: load test data into source
    source_data = load_fixture('test_orders.json')
    load_to_source(source_data)

    # Run pipeline
    run_pipeline('orders_pipeline')

    # Verify: check target has expected data
    target_data = read_from_target('warehouse.orders')
    assert len(target_data) == len(source_data)
    assert target_data['total'].sum() == source_data['total'].sum()

    # Verify: quality checks passed
    quality_report = get_quality_report('orders_pipeline')
    assert quality_report['score'] >= 0.99
```

#### 9c: Backfill Test
```python
def test_idempotent_backfill():
    """Running the pipeline twice should produce the same result."""
    run_pipeline('orders_pipeline', date='2025-01-15')
    result_1 = read_from_target('warehouse.orders', date='2025-01-15')

    run_pipeline('orders_pipeline', date='2025-01-15')  # Re-run same date
    result_2 = read_from_target('warehouse.orders', date='2025-01-15')

    assert_frame_equal(result_1, result_2)  # Identical results
```

### Step 10: Report and Transition

```
+------------------------------------------------------------+
|  PIPELINE -- <pipeline name>                                |
+------------------------------------------------------------+
|  Type:          <batch | streaming | micro-batch>           |
|  Orchestrator:  <tool>                                      |
|  Schedule:      <cron expression or trigger>                |
|  Sources:       <list of sources>                           |
|  Targets:       <list of targets>                           |
+------------------------------------------------------------+
|  Components created:                                        |
|  - <extractor file>                                         |
|  - <transformer file>                                       |
|  - <loader file>                                            |
|  - <quality checks file>                                    |
|  - <orchestrator config file>                               |
|  - <test file>                                              |
+------------------------------------------------------------+
|  Quality checks:  <N> checks configured                     |
|  Error handling:  <DLQ | retry | checkpoint | circuit breaker>|
|  Observability:   <logging | metrics | alerts>              |
+------------------------------------------------------------+
|  Test results:                                              |
|  Unit tests:        <N> passing                             |
|  Integration tests: <N> passing                             |
|  Backfill test:     PASS (idempotent)                       |
+------------------------------------------------------------+
```

Commit: `"pipeline: <pipeline name> -- <source> to <target>, <schedule>"`

## Key Behaviors

1. **Design before coding.** Map the full data flow (sources, transformations, targets) before writing any extraction or loading code. A pipeline without a clear design accumulates tech debt faster than any other system.
2. **Idempotency is non-negotiable.** Every pipeline must be safe to re-run. Use upserts, watermarks, and deduplication to ensure that running a pipeline twice produces the same result as running it once.
3. **Data quality is part of the pipeline, not an afterthought.** Quality checks run between every stage. Bad data caught early is a log entry. Bad data caught in production is a customer incident.
4. **Transformations must be pure functions.** No database calls, no API calls, no side effects inside transformation functions. This makes them testable, composable, and debuggable.
5. **Schema contracts at every boundary.** Every handoff between pipeline stages has an explicit schema. When the source schema changes, the pipeline should fail loudly, not silently corrupt data.
6. **Dead-letter queues save investigations.** Never silently drop bad records. Route them to a DLQ with the original record, the error message, and the pipeline context. Future-you will be grateful.
7. **Reconciliation proves correctness.** After every load, reconcile source and target counts. If they don't match, the pipeline has a bug. No exceptions.
8. **Backfill is not an edge case.** Every pipeline will need to be backfilled at some point. Design for it from day one -- parameterize by date range, support idempotent re-runs.
9. **Monitor freshness, not just success.** A pipeline that runs successfully but processes zero rows is not healthy. Track data freshness (time since last new record) alongside pipeline status.
10. **One pipeline, one concern.** Don't mix unrelated data flows in a single pipeline. If orders and inventory come from different sources and serve different consumers, they are different pipelines.

## Example Usage

### Building a batch pipeline
```
User: /godmode:pipeline Sync orders from our Postgres DB to BigQuery warehouse, daily

Pipeline: Designing data flow...

DATA FLOW SPECIFICATION:
Name:           orders_to_warehouse
Type:           batch
Schedule:       0 2 * * * (daily at 2 AM UTC)
SLA:            Data available in warehouse by 3 AM UTC

Sources:
  - production.orders: PostgreSQL (1M rows/day, incremental by updated_at)
  - production.order_items: PostgreSQL (3M rows/day, FK to orders)

Transformations:
  1. Extract incremental (watermark: updated_at)
  2. Clean and normalize (trim strings, validate emails)
  3. Join orders + order_items
  4. Compute aggregates (order_total, item_count)
  5. Deduplicate by order_id

Destinations:
  - analytics.orders: BigQuery (upsert by order_id)

Quality checks:
  - Not null: order_id, customer_id, total
  - Unique: order_id
  - Range: total >= 0
  - Freshness: latest order < 24h old
  - Reconciliation: source count == target count

Files created:
  - dags/orders_pipeline.py (Airflow DAG)
  - pipelines/orders/extract.py
  - pipelines/orders/transform.py
  - pipelines/orders/load.py
  - pipelines/orders/quality.py
  - tests/test_orders_pipeline.py
```

### Debugging a failing pipeline
```
User: /godmode:pipeline Our nightly users sync has been failing for 3 days

Pipeline: Investigating...

Checking Airflow logs...
  Last 3 runs: FAILED at task "load_users"
  Error: "Column 'phone' cannot be null" (IntegrityError)

Root cause: Source system started sending null phone numbers on Jan 12.
  - Source records with null phone: 342 (since Jan 12)
  - Target schema: phone VARCHAR(20) NOT NULL

Options:
  1. ALTER TABLE users ALTER COLUMN phone DROP NOT NULL (allow nulls)
  2. Add COALESCE(phone, '') in transformation (fill with empty string)
  3. Add dead-letter queue for records with null phone (skip them)

Recommendation: Option 3 (DLQ) + alert. Null phones likely indicate
a data quality issue at the source that should be investigated.

Fix applied:
  - Added null check in transform step: reject rows with null phone to DLQ
  - Added alert: "Users with null phone detected, {count} sent to DLQ"
  - Backfilled Jan 12-15 (342 records sent to DLQ)
  - Pipeline now passing
```

### Designing a streaming pipeline
```
User: /godmode:pipeline Real-time clickstream from Kafka to Elasticsearch for analytics

Pipeline: Designing streaming flow...

DATA FLOW SPECIFICATION:
Name:           clickstream_to_elastic
Type:           streaming
Schedule:       continuous
SLA:            < 30 second latency

Sources:
  - clicks_topic: Kafka (JSON, ~50K events/min)

Transformations:
  1. Deserialize JSON
  2. Enrich with session data (lookup from Redis)
  3. Geo-resolve IP addresses (MaxMind lookup)
  4. Window aggregate: clicks per user per minute

Destinations:
  - clickstream index: Elasticsearch (append, daily index rotation)

Components:
  - Flink job: src/flink/clickstream_job.py
  - Kafka schema: schemas/click_event.avsc
  - ES index template: config/clickstream_template.json
  - Quality: late event threshold (> 5 min = warn), missing fields = DLQ
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive pipeline design workflow |
| `--design` | Design pipeline architecture without implementing |
| `--implement` | Implement pipeline from existing design |
| `--test` | Run pipeline tests (unit + integration) |
| `--backfill <date-range>` | Run pipeline for a historical date range |
| `--validate` | Run data quality checks on last pipeline output |
| `--debug` | Investigate a failing pipeline |
| `--status` | Show pipeline run history and health |
| `--dry-run` | Show what the pipeline would do without executing |
| `--profile` | Profile pipeline performance (time per stage) |
| `--schema` | Show schema contracts for all pipeline boundaries |
| `--reconcile` | Run source-target reconciliation |
| `--dbt` | Focus on dbt model design and testing |
| `--streaming` | Design a streaming pipeline (Kafka, Flink, etc.) |
| `--monitor` | Set up monitoring and alerting for the pipeline |

## Anti-Patterns

- **Do NOT build a pipeline without a data flow diagram.** "Just read from A and write to B" leads to data quality nightmares. Map the full flow first.
- **Do NOT skip data quality checks.** "The source data is clean" is never true. Validate at every boundary.
- **Do NOT make transformations non-idempotent.** If running the pipeline twice doubles the data, you will have a very bad day during your first backfill.
- **Do NOT put business logic in SQL transformations without tests.** dbt models and SQL transforms need tests just like application code. Use schema tests, data tests, and freshness checks.
- **Do NOT silently drop records.** Every rejected record must go to a dead-letter queue with context. Silent data loss is the hardest bug to find.
- **Do NOT ignore schema evolution.** Sources change schemas without warning. Your pipeline should detect schema changes and fail loudly rather than loading corrupted data.
- **Do NOT skip reconciliation.** "The pipeline succeeded" means the code ran without errors. It does not mean the data is correct. Reconcile source and target counts.
- **Do NOT over-engineer simple flows.** A cron job running a Python script is a valid pipeline. Not everything needs Airflow, Spark, and a data lake.
- **Do NOT under-engineer complex flows.** A 500-line bash script with nested cron jobs is not a pipeline. It's a liability. Use proper orchestration.
- **Do NOT forget about backfill from the start.** The first thing that happens after launching a pipeline is "can you load the last 2 years of data?" Design for backfill from day one.
- **Do NOT mix batch and streaming without understanding the trade-offs.** Streaming adds complexity. If your SLA is "data available by next morning," batch is simpler and cheaper.
- **Do NOT hardcode connection strings.** Use environment variables or a secrets manager. A pipeline with hardcoded credentials will eventually be committed to version control.
