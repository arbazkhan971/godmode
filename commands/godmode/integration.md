# /godmode:integration

Integration testing with real dependencies using Testcontainers, proper database seeding/cleanup, API endpoint testing, and service-level integration patterns.

## Usage

```
/godmode:integration                           # Assess boundaries and write integration tests
/godmode:integration --for <file>              # Write integration tests for a specific module
/godmode:integration --container postgres      # Specify container type
/godmode:integration --seed                    # Focus on creating seed data and fixtures
/godmode:integration --api                     # Focus on API endpoint integration tests
/godmode:integration --service                 # Focus on service-level integration patterns
/godmode:integration --ci                      # Generate CI configuration for integration tests
/godmode:integration --cleanup truncate        # Specify cleanup strategy
```

## What It Does

1. Maps all external dependency boundaries (databases, APIs, queues, caches)
2. Sets up Testcontainers for disposable, isolated test infrastructure
3. Creates fixture factories and seed data strategies
4. Implements cleanup strategies (truncate, transaction rollback, unique data)
5. Writes integration tests that verify real interactions:
   - Database CRUD with real SQL
   - API endpoints with real HTTP requests
   - Service-to-service communication
   - Message queue producer/consumer flows
   - Cache hit/miss/invalidation behavior
6. Configures test separation (unit vs integration) for CI pipelines

## Output
- Integration test files in `tests/integration/`
- Fixture factories in `tests/fixtures/`
- Container configuration for Testcontainers
- CI pipeline configuration (if `--ci` flag used)
- Commit: `"test(integration): <module> — <N> tests with <containers>"`

## Next Step
After integration tests: `/godmode:contract` for API contract testing.
If external services involved: `/godmode:contract` for consumer-driven contracts.

## Examples

```
/godmode:integration --for src/repos/order-repo.ts    # Test repository with real DB
/godmode:integration --container redis                  # Redis integration tests
/godmode:integration --api                              # Test API endpoints
/godmode:integration --ci                               # Generate CI config
/godmode:integration --seed                             # Create test fixtures
```
