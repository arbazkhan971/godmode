# /godmode:seed

Database seeding, test fixtures, factory patterns, and fake data generation. Covers factory libraries (FactoryBot, fishery, factory_boy, Bogus), Faker integration, idempotent seed scripts, environment-aware seeding, large dataset optimization, and production data anonymization.

## Usage

```
/godmode:seed                                    # Interactive seed setup workflow
/godmode:seed --factory                          # Set up factory pattern for the project
/godmode:seed --faker                            # Configure fake data generation
/godmode:seed --script                           # Create idempotent seed script
/godmode:seed --env                              # Environment-specific seeding (dev/staging/demo)
/godmode:seed --large                            # Optimize for large datasets (batch, COPY)
/godmode:seed --deterministic                    # Reproducible seeds with fixed faker seed
/godmode:seed --anonymize                        # Production data anonymization pipeline
/godmode:seed --cleanup                          # Seed data cleanup strategies
/godmode:seed --fixtures                         # Set up test fixtures
/godmode:seed --relationships                    # Handle complex association seeding
/godmode:seed --report                           # Generate seed infrastructure report
```

## What It Does

1. Detects the project's ORM, database, and existing seeding infrastructure
2. Sets up factory patterns with the right library for the language (fishery, factory_boy, FactoryBot, Bogus)
3. Configures fake data generation with deterministic seeds for reproducibility
4. Creates idempotent seed scripts that use upsert and skip duplicates
5. Implements environment-aware seeding with different data volumes per environment
6. Handles relationship seeding in dependency order (parents before children)
7. Optimizes large dataset seeding with batch inserts, streaming, and PostgreSQL COPY
8. Builds production data anonymization pipelines for safe development snapshots
9. Configures cleanup strategies (transaction rollback, truncate, delete-by-marker)

## Output
- Factory definitions for project entities
- Idempotent seed script with environment configs
- Anonymization queries for production snapshots
- Commit: `"seed: add <description> seeding infrastructure"`

## Next Step
After seeding setup: `/godmode:test` for test infrastructure, or `/godmode:orm` to optimize the data access layer.

## Examples

```
/godmode:seed Set up seeding for my Prisma + PostgreSQL project
/godmode:seed --factory                          # Add fishery factories for User, Post, Comment
/godmode:seed --large                            # I need 100K orders for performance testing
/godmode:seed --anonymize                        # Anonymize production DB for local dev
/godmode:seed --env                              # Different seed data for dev vs staging vs demo
```
