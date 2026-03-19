# /godmode:query

Query optimization and data analysis. Interprets EXPLAIN plans, recommends indexes, rewrites queries for performance, detects N+1 problems, and profiles slow queries across SQL databases, MongoDB, Redis, and any ORM.

## Usage

```
/godmode:query                                # Interactive query optimization
/godmode:query --explain                      # Run EXPLAIN on a query and interpret
/godmode:query --indexes                      # Analyze and recommend indexes
/godmode:query --n-plus-one                   # Scan code for N+1 query patterns
/godmode:query --slow-log                     # Analyze the database slow query log
/godmode:query --rewrite                      # Rewrite a query for better performance
/godmode:query --profile                      # Profile queries from a specific endpoint
/godmode:query --compare                      # Compare performance of two query variants
/godmode:query --orm                          # Focus on ORM-level optimizations
/godmode:query --redis                        # Analyze Redis command patterns
/godmode:query --mongo                        # Analyze MongoDB queries and indexes
/godmode:query --unused-indexes               # Find indexes that are never used
/godmode:query --missing-indexes              # Detect queries that need indexes
/godmode:query --report                       # Generate full database performance report
```

## What It Does

1. Identifies the database engine and access layer (raw SQL, ORM, driver)
2. Runs EXPLAIN ANALYZE and interprets the query plan line by line
3. Detects red flags: sequential scans, N+1 patterns, stale statistics, over-fetching, bad joins
4. Recommends concrete fixes: indexes (with type selection), query rewrites, ORM eager loading
5. Verifies improvement with before/after EXPLAIN comparison
6. Reports speedup with exact measurements

## Output
- EXPLAIN plan interpretation with red flags highlighted
- Index recommendations with SQL and trade-off analysis
- Rewritten queries with before/after performance comparison
- Commit: `"query: optimize <description> -- <speedup>x improvement"`

## Next Step
After query optimization: `/godmode:optimize` for broader performance work, or `/godmode:migrate` if schema changes are needed for new indexes.

## Examples

```
/godmode:query This query takes 3 seconds: SELECT * FROM orders WHERE customer_id = 42
/godmode:query --n-plus-one                   # Find all N+1 patterns in the codebase
/godmode:query --indexes                      # Full index audit
/godmode:query --slow-log                     # What's slow in production?
/godmode:query --compare                      # Is my rewrite actually faster?
```
