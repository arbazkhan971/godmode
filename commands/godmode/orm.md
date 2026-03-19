# /godmode:orm

ORM and data access optimization. Covers ORM selection (Prisma, Drizzle, TypeORM, SQLAlchemy, GORM, ActiveRecord), N+1 query detection, connection pooling, transaction management, and query builder patterns.

## Usage

```
/godmode:orm                                  # Interactive ORM selection and configuration
/godmode:orm --select                         # ORM comparison matrix and recommendation
/godmode:orm --n-plus-one                     # Scan codebase for N+1 query patterns
/godmode:orm --pool                           # Configure connection pooling for production
/godmode:orm --transactions                   # Design transaction management patterns
/godmode:orm --query-builder                  # Implement dynamic query building
/godmode:orm --raw-sql                        # Add raw SQL for complex queries
/godmode:orm --audit                          # Full ORM usage and performance audit
/godmode:orm --migrate                        # Migrate between ORMs
/godmode:orm --replica                        # Set up read replica routing
/godmode:orm --logging                        # Configure query logging and slow detection
/godmode:orm --report                         # Full data access layer report
```

## What It Does

1. Detects current ORM, database, and data access patterns in the project
2. Selects the right ORM with framework-specific comparison matrices (TypeScript, Python, Go, Ruby, Java, Rust)
3. Detects N+1 query patterns and provides ORM-idiomatic eager loading fixes
4. Configures connection pooling (pool size, timeouts, recycling, health checks)
5. Implements transaction patterns (basic, nested/savepoints, distributed/saga)
6. Builds composable query builders for dynamic filtering, sorting, and pagination
7. Adds raw SQL escape hatches for queries the ORM handles poorly
8. Verifies production readiness (logging, timeouts, retries, monitoring)

## Output
- ORM selection recommendation with rationale
- N+1 query detection report with fixes
- Connection pool configuration
- Transaction management code
- Commit: `"orm: optimize <description> data access layer"`

## Next Step
After ORM configuration: `/godmode:query` for query-level optimization, or `/godmode:schema` to revisit the data model.

## Examples

```
/godmode:orm Prisma or Drizzle for my edge-deployed API?
/godmode:orm --n-plus-one                     # Find all N+1 queries in the codebase
/godmode:orm --pool                           # My connections keep timing out
/godmode:orm --transactions                   # How to handle checkout with inventory
/godmode:orm --audit                          # Full data access layer health check
```
