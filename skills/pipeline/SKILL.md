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
- User asks about data quality checks, scheduling, or orchestration
- User needs to debug a failing pipeline or design streaming/batch processing

## Workflow

### Step 1: Understand the Data Flow
Map the complete data flow before writing any code:

```
DATA FLOW SPECIFICATION:
Name: <pipeline name>  Type: <batch | streaming | micro-batch | CDC | hybrid>
Schedule: <cron | event-triggered | continuous>  SLA: <max latency>
Sources: <source>: <type> (<format>, <volume/day>, <access method>)
Transformations: 1. <step> (input -> output)
Destinations: <target>: <type> (<format>, <write method>)
Idempotency: <can re-run safely?>  Error handling: <skip | fail | dead-letter | retry>
```

### Step 2: Detect Pipeline Environment
```
IF dags/ OR airflow.cfg           -> Airflow
IF dbt_project.yml                -> dbt (compute from profiles.yml)
IF dagster.yaml OR Definitions()  -> Dagster
IF prefect imports                -> Prefect
IF kafka/confluent imports        -> Kafka
IF spark/pyspark imports          -> Spark
```

### Step 3: Choose Pipeline Pattern
```
BATCH:     Extract -> Stage -> Transform -> Validate -> Load (Airflow+dbt, Dagster, Prefect)
STREAMING: Source -> Stream Processor -> Sink (Kafka+Flink, Spark Streaming)
CDC:       Source DB -> CDC tool -> Stream/Batch -> Target (Debezium, AWS DMS)
ELT:       Extract -> Load raw -> Transform in warehouse (Fivetran/Airbyte + dbt)
```

Every pipeline boundary needs a schema contract: version, format, fields with types/constraints. Breaking changes require version bump and consumer notification.

### Step 4: Implement Pipeline Components

**Extraction:** Track watermarks, handle retries with backoff, log metrics. Patterns: API pagination with rate limiting, DB incremental by updated_at, file dedup via processed log.

**Transformation:** Pure functions only — no DB/API calls, no side effects. Composable via `.pipe()`. Example: `clean_emails -> deduplicate -> enrich_with_geo -> validate_schema`.

**Loading strategies:**
- UPSERT: Insert/update by key — most common for dimensions
- SWAP: Load staging, atomically rename — best for full refreshes
- APPEND: Insert only — best for fact/event tables
- SCD Type 2: Track historical changes with effective dates

### Step 5: Data Quality Checks
Every pipeline needs these checks — not optional:

- **Row-level:** not_null, unique, range, pattern, referential integrity, freshness
- **Dataset-level:** row count (min/max/change threshold), completeness (fill rate), distribution
- **Cross-pipeline:** source-target count reconciliation, aggregate sum reconciliation

### Step 6: Observability
Structured logging at every stage (rows extracted/transformed/loaded, duration). Essential metrics: pipeline_duration_seconds, rows_processed/rejected, last_success_timestamp, data_freshness, quality_score. Alert on: failure, 2x duration, quality < 95%, no data > 2 hours, count change > 50%.

### Step 7: Error Handling
- Dead Letter Queue: bad records to separate table for investigation
- Retry with exponential backoff for transient failures
- Checkpoint and resume for large batch jobs
- Circuit breaker if source fails N times consecutively

### Step 8: Orchestrator Configuration
Generate config for detected tool (Airflow DAG, dbt project, Dagster assets). Chain: extract >> validate_raw >> transform >> validate_clean >> load >> reconcile.

### Step 9: Test the Pipeline
- **Unit tests:** transformation function correctness
- **Integration tests:** end-to-end with fixtures, verify counts and sums
- **Backfill test:** run twice, verify identical results (idempotency)

### Step 10: Report
```
Commit: "pipeline: <name> -- <source> to <target>, <schedule>"
Components: extractor, transformer, loader, quality checks, orchestrator config, tests
```

## Key Behaviors
1. **Design before coding.** Map full data flow before writing code.
2. **Idempotency is non-negotiable.** Use upserts, watermarks, deduplication.
3. **Data quality is part of the pipeline.** Checks between every stage.
4. **Write transformations as pure functions.** No side effects.
5. **Schema contracts at every boundary.** Fail loudly on unexpected changes.
6. **Dead-letter queues save investigations.** Never silently drop records.
7. **Reconcile source-target counts after every load.**
8. **Design for backfill from day one.** Parameterize by date range.

## Flags & Options

| Flag | Description |
|--|--|
| `--design` | Design pipeline architecture without implementing |
| `--implement` | Implement from existing design |
| `--test` | Run unit + integration tests |
| `--debug` | Investigate a failing pipeline |
| `--validate` | Run data quality checks |
| `--dbt` | Focus on dbt model design |
| `--streaming` | Design streaming pipeline |

## HARD RULES
1. **NEVER build without a data flow diagram first.**
2. **NEVER skip data quality checks.** Validate at every boundary.
3. **NEVER make a pipeline non-idempotent.** Upserts, watermarks, deduplication.
4. **NEVER silently drop records.** Every reject goes to a DLQ with context.
5. **NEVER hardcode credentials.** Environment variables or secrets manager.
6. **NEVER put side effects in transformations.** Pure: DataFrame in, DataFrame out.
7. **ALWAYS reconcile source-target counts.**
8. **ALWAYS design for backfill from day one.**

## Auto-Detection
```
1. Detect sources: DB connections, API configs, file sources (S3/GCS)
2. Detect frameworks: Airflow, dbt, Prefect, Dagster, Luigi, Beam, Spark
3. Detect targets: BigQuery, Snowflake, Redshift, data lakes
4. Detect quality tools: Great Expectations, dbt tests, Soda
5. Set PIPELINE SCOPE from detected context
```

## Explicit Loop Protocol
```
stages = [data_flow_design, extraction, transformation, quality_checks, loading, reconciliation, observability, tests]
FOR EACH stage: IMPLEMENT -> TEST with sample data -> VERIFY quality -> REPORT status
Never advance if current stage silently drops records.
```

## Multi-Agent Dispatch
```
Agent 1 (pipeline-extract): Extractors, watermarking, retry logic
Agent 2 (pipeline-transform): Pure transforms, schema validation, quality checks
Agent 3 (pipeline-load): Loading strategies, reconciliation, DLQ
MERGE ORDER: extract -> transform -> load
```

## TSV Logging
Log to `.godmode/pipeline-results.tsv`: `iteration\tstage\tsource\ttarget\trecords_in\trecords_out\trecords_rejected\tduration_s\tquality_pct\tstatus`

## Success Criteria
- Data flow documented before implementation
- All transformations idempotent
- Quality checks at every boundary
- Rejected records in DLQ with context
- Source-target counts reconciled
- Pipeline runs within SLA

## Error Recovery
- **Schema changed:** Fail loudly, alert, update contract, re-run after verification.
- **Duplicates:** Use upsert instead of insert, add dedup step.
- **DLQ growing:** Investigate rejection reason, fix source or transformation.
- **Exceeds SLA:** Profile stages, parallelize, optimize queries, use incremental loads.
- **Connection timeout:** Retry with exponential backoff, check pool config.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-pipeline-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `Pipeline: {stages} stages, {sources} sources -> {targets} targets. Quality checks: {N}. SLA: {met|missed}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH pipeline change:
  KEEP if: pipeline runs end-to-end AND data quality checks pass AND SLA met
  DISCARD if: data quality fails OR pipeline errors OR SLA exceeded
  On discard: revert. Fix data quality issue before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - Pipeline runs end-to-end with zero errors
  - Data quality checks validate all stages
  - SLA target met (data available by deadline)
  - Backfill capability tested
```
