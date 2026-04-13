---
name: pipeline
description: Data pipeline and ETL -- extraction,
  transformation, loading, data quality, orchestration.
---

## Activate When
- `/godmode:pipeline`, "build a data pipeline", "ETL"
- "data flow", "sync data", "data quality"
- Move, transform, or load data between systems

## Workflow

### 1. Data Flow Specification
```bash
ls dags/ dbt_project.yml dagster.yaml 2>/dev/null
grep -r "airflow\|dagster\|prefect\|kafka" \
  requirements.txt package.json 2>/dev/null
```
```
Name: <pipeline>
Type: batch | streaming | micro-batch | CDC
Schedule: cron | event-triggered | continuous
SLA: <max latency>
Sources: <name>: <type> (<format>, <volume/day>)
Transforms: 1. <step> (input -> output)
Destinations: <target>: <type> (<write method>)
Idempotent: yes/no
Error handling: skip | fail | dead-letter | retry
```

### 2. Pipeline Pattern
- Batch: Extract -> Stage -> Transform -> Validate
  -> Load (Airflow+dbt, Dagster, Prefect)
- Streaming: Source -> Processor -> Sink
  (Kafka+Flink, Spark Streaming)
- CDC: Source DB -> CDC tool -> Target
  (Debezium, AWS DMS)
- ELT: Extract -> Load raw -> Transform in warehouse
  (Fivetran/Airbyte + dbt)

IF data changes hourly: batch with cron.
IF sub-second latency needed: streaming (Kafka).
IF already using PostgreSQL: CDC with Debezium.

### 3. Implement Components

**Extraction**: track watermarks, retry with backoff,
log metrics. Patterns: API pagination with rate limit,
DB incremental by updated_at, file dedup.

**Transformation**: pure functions only -- no DB calls,
no side effects. Composable via `.pipe()`.

**Loading strategies**:
- UPSERT: insert/update by key (dimensions)
- SWAP: staging + atomic rename (full refresh)
- APPEND: insert only (fact/event tables)
- SCD Type 2: historical tracking with dates

### 4. Data Quality Checks
Every pipeline needs these (not optional):
- Row: not_null, unique, range, pattern, referential
- Dataset: row count (min/max/threshold), completeness
- Cross-pipeline: source-target count reconciliation

IF quality < 95%: alert and investigate.
IF count change > 50%: block load and alert.

### 5. Observability
Structured logging at every stage. Metrics:
duration_seconds, rows_processed/rejected,
last_success, data_freshness, quality_score.
Alert: failure, 2x duration, quality < 95%,
no data > 2 hours.

### 6. Error Handling
DLQ for bad records. Retry with exponential backoff.
Checkpoint and resume for large batches. Circuit
breaker if source fails N times.

### 7. Testing
- Unit: transformation correctness
- Integration: end-to-end with fixtures
- Backfill: run twice, verify identical (idempotency)

## Hard Rules
1. NEVER build without data flow diagram first.
2. NEVER skip data quality checks.
3. NEVER make pipeline non-idempotent.
4. NEVER silently drop records (use DLQ).
5. NEVER hardcode credentials.
6. NEVER put side effects in transformations.
7. ALWAYS reconcile source-target counts.
8. ALWAYS design for backfill from day one.

## TSV Logging
Append `.godmode/pipeline-results.tsv`:
```
timestamp	stage	source	target	records_in	records_out	rejected	quality_pct	status
```

## Keep/Discard
```
KEEP if: pipeline runs end-to-end AND quality checks
  pass AND SLA met.
DISCARD if: quality fails OR errors OR SLA exceeded.
```

## Stop Conditions
```
STOP when ALL of:
  - Pipeline runs end-to-end with zero errors
  - Quality checks validate all stages
  - SLA met
  - Backfill tested
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Schema changed | Fail loudly, update contract |
| Duplicates | Use upsert, add dedup step |
| DLQ growing | Investigate rejection reason |
| Exceeds SLA | Profile stages, parallelize |
| Connection timeout | Retry with backoff, check pool |
