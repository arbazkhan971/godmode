# /godmode:postgres

PostgreSQL mastery. Advanced features (CTEs, window functions, JSONB, full-text search), extension management (pgvector, PostGIS, TimescaleDB), replication setup, partitioning strategies, VACUUM/ANALYZE tuning, and connection pooling configuration.

## Usage

```
/godmode:postgres                                # Interactive PostgreSQL mastery workflow
/godmode:postgres --extensions                   # List, install, configure extensions
/godmode:postgres --replication                  # Set up streaming or logical replication
/godmode:postgres --partition                    # Design and implement table partitioning
/godmode:postgres --vacuum                       # Diagnose and fix VACUUM/autovacuum issues
/godmode:postgres --tune                         # Performance tuning for postgresql.conf
/godmode:postgres --pooling                      # Configure PgBouncer, Supavisor, or pgcat
/godmode:postgres --fts                          # Set up full-text search with ranking
/godmode:postgres --jsonb                        # JSONB schema design and query optimization
/godmode:postgres --pgvector                     # Set up pgvector for vector similarity search
/godmode:postgres --postgis                      # Configure PostGIS for geospatial queries
/godmode:postgres --timescale                    # Set up TimescaleDB for time-series data
/godmode:postgres --diagnose                     # Run full diagnostic (pg_stat, cache hits, bloat)
/godmode:postgres --audit                        # Complete PostgreSQL health audit
```

## What It Does

1. Assesses PostgreSQL environment (version, hosting, extensions, workload)
2. Implements advanced features: CTEs (recursive, materialized), window functions, JSONB operations, full-text search with ranking
3. Configures extensions: pgvector for AI search, PostGIS for geospatial, TimescaleDB for time-series
4. Sets up replication: streaming (physical) for HA, logical for selective sync
5. Designs partitioning: range (time-series), list (multi-tenant), hash (even distribution)
6. Tunes VACUUM/autovacuum and diagnoses bloat with pg_stat views
7. Configures connection pooling (PgBouncer, Supavisor, pgcat)
8. Tunes postgresql.conf for memory, WAL, planner, and parallelism

## Output
- PostgreSQL environment assessment with diagnostics
- Extension configuration with working examples
- Replication setup with monitoring queries
- Partitioning design with automated management
- Performance tuning recommendations with before/after measurements
- Commit: `"postgres: <description> -- <key outcome>"`

## Next Step
After PostgreSQL work: `/godmode:query` for query optimization, `/godmode:migrate` for schema changes, or `/godmode:cache` for caching layer design.

## Examples

```
/godmode:postgres --pgvector                     # Set up AI vector search
/godmode:postgres --vacuum                       # Fix 40% dead tuple bloat
/godmode:postgres --replication                  # Set up read replicas
/godmode:postgres --tune                         # Optimize for OLTP workload
/godmode:postgres --fts                          # Replace Elasticsearch with native FTS
```
