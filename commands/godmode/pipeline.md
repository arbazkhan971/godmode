# /godmode:pipeline

Data pipeline and ETL design, implementation, testing, and debugging. Covers extraction, transformation, loading, data quality validation, schema contracts, observability, and error handling. Works with any orchestrator (Airflow, dbt, Dagster, Prefect, Luigi, custom scripts) and any data store.

## Usage

```
/godmode:pipeline                             # Interactive pipeline design workflow
/godmode:pipeline --design                    # Design architecture without implementing
/godmode:pipeline --implement                 # Implement from existing design
/godmode:pipeline --test                      # Run pipeline tests (unit + integration)
/godmode:pipeline --backfill 2025-01-01:2025-01-31   # Run for historical date range
/godmode:pipeline --validate                  # Run data quality checks on last output
/godmode:pipeline --debug                     # Investigate a failing pipeline
/godmode:pipeline --status                    # Show run history and health
/godmode:pipeline --dry-run                   # Show what pipeline would do without executing
/godmode:pipeline --profile                   # Profile performance (time per stage)
/godmode:pipeline --schema                    # Show schema contracts for all boundaries
/godmode:pipeline --reconcile                 # Run source-target reconciliation
/godmode:pipeline --dbt                       # Focus on dbt model design and testing
/godmode:pipeline --streaming                 # Design a streaming pipeline
/godmode:pipeline --monitor                   # Set up monitoring and alerting
```

## What It Does

1. Maps the complete data flow (sources, transformations, targets, schedule, SLA)
2. Detects the orchestration tool (Airflow, dbt, Dagster, Prefect, etc.)
3. Designs pipeline architecture (batch, streaming, CDC, ELT)
4. Implements: extractors with watermarking, pure transformation functions, idempotent loaders
5. Adds data quality checks at every boundary (row-level, dataset-level, cross-pipeline)
6. Configures error handling (dead-letter queues, retries, circuit breakers, checkpoints)
7. Sets up observability (structured logging, metrics, alerting)
8. Tests: unit tests for transforms, integration tests end-to-end, backfill/idempotency tests

## Output
- Pipeline implementation files (extractor, transformer, loader, quality checks)
- Orchestrator configuration (DAG, dbt project, Dagster definitions)
- Test suite with unit and integration tests
- Data quality report after each run
- Commit: `"pipeline: <name> -- <source> to <target>, <schedule>"`

## Next Step
After pipeline: `/godmode:query` to optimize pipeline queries, `/godmode:migrate` if schema changes needed, or `/godmode:ship` to deploy.

## Examples

```
/godmode:pipeline Sync orders from Postgres to BigQuery, daily at 2 AM
/godmode:pipeline --debug Our nightly ETL has been failing for 3 days
/godmode:pipeline --dbt Build staging and mart models for the orders domain
/godmode:pipeline --streaming Clickstream from Kafka to Elasticsearch
/godmode:pipeline --backfill 2024-01-01:2024-12-31   # Load historical data
/godmode:pipeline --reconcile                         # Verify source matches target
```
