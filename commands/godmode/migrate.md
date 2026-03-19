# /godmode:migrate

Database migration and schema management. Auto-detects your ORM/migration tool, generates idiomatic migrations with backward compatibility checks, validates rollback safety, and estimates lock duration on large tables.

## Usage

```
/godmode:migrate                              # Interactive: detect tool, generate, validate, apply
/godmode:migrate --generate                   # Generate migration file without applying
/godmode:migrate --validate                   # Validate pending migrations without applying
/godmode:migrate --apply                      # Apply all pending migrations
/godmode:migrate --rollback                   # Roll back the last migration
/godmode:migrate --rollback 3                 # Roll back the last 3 migrations
/godmode:migrate --status                     # Show migration status (applied, pending, failed)
/godmode:migrate --diff                       # Show schema diff between code and database
/godmode:migrate --dry-run                    # Show what migration would do without generating files
/godmode:migrate --sql                        # Output raw SQL regardless of ORM
/godmode:migrate --seed                       # Run seed files after migration
/godmode:migrate --expand-contract            # Force expand-contract pattern for breaking changes
/godmode:migrate --check-compat               # Run backward compatibility check only
/godmode:migrate --lock-estimate              # Estimate lock duration for pending migrations
```

## What It Does

1. Detects the migration tool (Prisma, Drizzle, TypeORM, Sequelize, Django, Rails, Go-migrate, Alembic, Flyway, Liquibase, Knex, or raw SQL)
2. Analyzes the schema change request (from user description or model file diff)
3. Assesses backward compatibility and risk level (SAFE, CAUTION, DANGEROUS, BREAKING)
4. Generates idiomatic migration with UP and DOWN
5. Validates: schema check, rollback test, data preservation, lock estimation
6. Applies with pre/post verification

For BREAKING changes, automatically recommends the expand-contract pattern (add new alongside old, migrate data, remove old).

## Output
- Migration file(s) in the project's migration directory
- Risk assessment with lock duration estimate
- Rollback verification results
- Commit: `"migrate: <table>.<change> -- <risk level>"`

## Next Step
After migrate: `/godmode:query` to optimize queries for the new schema, or `/godmode:build` to continue implementation.

## Examples

```
/godmode:migrate Add a "role" column to users with default "member"
/godmode:migrate Rename email to email_address on the customers table
/godmode:migrate --status                     # See what's applied and pending
/godmode:migrate --rollback                   # Undo the last migration
/godmode:migrate --validate                   # Check pending migrations are safe
/godmode:migrate --lock-estimate              # How long will the ALTER TABLE lock?
```
