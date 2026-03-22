---
name: integration
description: |
 Integration testing skill. Activates when user needs to test how components work together across real boundaries — databases, APIs, message queues, and external services. Covers Testcontainers for Docker-based dependencies, database seeding and cleanup strategies, API integration testing with real HTTP, service-level integration patterns, and transaction management in tests. Supports all major frameworks and languages. Triggers on: /godmode:integration, "integration test", "test with real database", "test API endpoint", "testcontainers", or when /godmode:test identifies integration-level gaps.
---

# Integration — Integration Testing

## When to Activate
- User invokes `/godmode:integration`
- User asks "test this with a real database" or "test the API endpoint"
- User asks about Testcontainers or Docker-based test dependencies
- User needs database seeding, migration, or cleanup in tests
- User wants to test service-to-service interactions
- `/godmode:test` identifies integration coverage gaps
- `/godmode:unittest` recommends integration tests for heavily-mocked code

## Workflow

### Step 1: Assess Integration Boundaries
Map the real external dependencies the code interacts with:

```bash
# Identify external dependencies
<trace database connections, API calls, message queue producers/consumers>

# Check for existing integration tests
find. -name "*integration*" -o -name "*e2e*" -o -path "*/it/*"

```

```
INTEGRATION BOUNDARY MAP:
Target: <module/service being tested>
Language: <language>
Framework: <test framework>

External dependencies:
 Databases:
 - <PostgreSQL | MySQL | MongoDB | Redis | etc.> — <what data>
 APIs:
 - <external service name> — <what endpoints>
 Message queues:
 - <Kafka | RabbitMQ | SQS | etc.> — <what topics/queues>
 File systems:
 - <S3 | local disk | etc.> — <what files>
 Other:
 - <SMTP, LDAP, Elasticsearch, etc.>

Existing integration tests: <N tests | NONE>
Container setup: <Testcontainers | docker-compose | manual | NONE>
Test database: <in-memory | container | shared dev instance | NONE>
```

### Step 2: Set Up Test Containers

Testcontainers provides disposable Docker containers for integration tests — each test run gets a fresh, isolated instance.

#### Testcontainers — Node.js / TypeScript

```typescript
// testcontainers setup — Jest/Vitest
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql';
import { Client } from 'pg';

describe('UserRepository (integration)', () => {
 let container: StartedPostgreSqlContainer;
```

#### Testcontainers — Python

```python
import pytest
from testcontainers.postgres import PostgresContainer
import psycopg2

@pytest.fixture(scope="module")
def postgres():
```

#### Testcontainers — Java (JUnit 5)

```java
@Testcontainers
class UserRepositoryIntegrationTest {

 @Container
 static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
.withDatabaseName("testdb")
```

### Step 3: Database Seeding and Cleanup

#### Seeding Strategies

**1. Migration-based seeding (recommended for schema)**
Run production migrations to create the schema, then seed test data:

```typescript
async function setupTestDatabase(client: Client) {
 // Step 1: Run the same migrations used in production
 await runMigrations(client);

 // Step 2: Seed reference data (enums, configs, lookup tables)
 await seedReferenceData(client);
```

**2. Fixture-based seeding (for test data)**
Create reusable fixture factories:

```typescript
// fixtures/user-fixtures.ts
export function createUser(overrides: Partial<User> = {}): User {
 return {
 id: randomUUID(),
 name: 'Test User',
 email: `test-${randomUUID()}@example.com`,
```

#### Cleanup Strategies

**Strategy 1: TRUNCATE between tests (fastest)**
```typescript
beforeEach(async () => {
 // TRUNCATE is faster than DELETE for clearing all rows
 await client.query(`
 TRUNCATE TABLE orders, users, payments CASCADE
 `);
});
```

**Strategy 2: Transaction rollback (zero cleanup needed)**
```typescript
// Wrap each test in a transaction that gets rolled back
let transaction: Transaction;

beforeEach(async () => {
 transaction = await db.beginTransaction();
});
```

```python
# pytest-django does this automatically with @pytest.mark.django_db(transaction=True)
@pytest.mark.django_db
def test_creates_user(client):
 response = client.post("/api/users/", {"name": "Alice"})
 assert response.status_code == 201
 # Database changes are automatically rolled back after this test
```

**Strategy 3: Unique data per test (no cleanup needed)**
```typescript
// Every test creates data with unique IDs — no conflicts, no cleanup
it('finds user by email', async () => {
 const unique = randomUUID();
 const user = createUser({ email: `${unique}@test.com` });
 await repo.save(user);

```

Use when: Tests modify schema, or cleanup is too complex.
Cost: Each test class gets a new container (adds 2-5 seconds).
```

#### Cleanup Decision Matrix
```
CHOOSE YOUR CLEANUP STRATEGY:

Fast + isolated: Transaction rollback (if framework supports it)
Fast + simple: TRUNCATE between tests
No cleanup needed: Unique data per test (best for parallel tests)
Maximum isolation: Fresh container per test class (slow, use sparingly)
```

### Step 4: API Integration Testing

Test real HTTP endpoints with actual request/response cycles:

#### HTTP API Testing — Node.js

```typescript
import request from 'supertest';
import { createApp } from '../src/app';

describe('POST /api/users (integration)', () => {
 let app: Express;
 let container: StartedPostgreSqlContainer;

```

#### Testing Authenticated Endpoints

```typescript
describe('authenticated API routes', () => {
 let authToken: string;

 beforeAll(async () => {
 // Create a test user and get a real auth token
 await request(app)
```

### Step 5: Service-Level Integration Patterns

#### Pattern 1: Service-to-Database Integration
Test that your service layer correctly interacts with a real database:

```typescript
describe('OrderService (integration)', () => {
 // Real database, real repository, real service
 let orderService: OrderService;
 let orderRepo: OrderRepository;
 let inventoryRepo: InventoryRepository;

```

#### Pattern 2: Service-to-Service Integration
Test that services communicate correctly through their real interfaces:

```typescript
describe('CheckoutFlow (integration)', () => {
 // Real services, but external payment gateway is a mock server
 let orderService: OrderService;
 let paymentService: PaymentService;
 let notificationService: NotificationService;

```

#### Pattern 3: Message Queue Integration
Test that producers and consumers work together through a real message broker:

```typescript
describe('Order Event Processing (integration)', () => {
 let kafkaContainer: StartedKafkaContainer;
 let producer: OrderEventProducer;
 let consumer: OrderEventConsumer;

 beforeAll(async () => {
```

### Step 6: Integration Test Configuration

#### Test Tagging and Separation
Keep integration tests separate from unit tests so they can run independently:

```json
// package.json
{
 "scripts": {
 "test": "jest --testPathPattern='tests/unit'",
 "test:integration": "jest --testPathPattern='tests/integration'",
 "test:all": "jest"
```

```toml
# pyproject.toml
[tool.pytest.ini_options]
markers = [
 "integration: marks tests as integration tests (deselect with '-m \"not integration\"')",
]
```

```python
# pytest — mark integration tests
@pytest.mark.integration
def test_with_real_database():
...
```

```go
// Go — build tags for integration tests
//go:build integration

package repository_test

func TestWithRealDatabase(t *testing.T) {
```

### Step 7: Run, Verify, and Report

```bash
# Run integration tests (with longer timeout)
<framework command> --testPathPattern='integration' --timeout=30000

# Run with verbose output (integration failures need detail)
<framework command> --verbose
```

```
INTEGRATION TEST REPORT:
Target: <module/service>
Tests written: <N>
 - Database integration: <N>
 - API integration: <N>
 - Service integration: <N>
 - Message queue integration: <N>
Containers used:
 - <PostgreSQL 16, Redis 7, Kafka 3.6, etc.>
Seeding strategy: <fixtures | factories | SQL files>
Cleanup strategy: <truncate | transaction rollback | unique data>
All passing: <YES/NO>
Average test duration: <Xms>
Slowest test: <name> (<Xms>)
```

### Step 8: Commit and Transition
1. Commit tests: `"test(integration): <module> — <N> tests with <containers>"`
2. If database tests: confirm migrations run cleanly in test containers
3. If slow tests found: recommend container reuse or parallel execution
4. If external services involved: recommend `/godmode:contract` for contract testing

## Key Behaviors

1. **Use real dependencies, not mocks.** The entire point of integration tests is to verify real interactions. If you mock the database, you have a unit test with extra steps.
2. **Isolate between tests, not from dependencies.** Each test gets clean state (via truncate/rollback), but uses real databases, real caches, real queues.
3. **Testcontainers over shared instances.** Shared test databases cause flaky tests. Testcontainers give every test run a fresh, disposable instance.
4. **Test the transaction boundary.** The most valuable integration test verifies that multi-step operations either fully succeed or fully roll back.
5. **Separate integration from unit tests.** Integration tests are slower (seconds, not milliseconds). Run them separately in CI so unit tests stay fast.
6. **Seed minimally.** Each test seeds only the data it needs. Global seeding creates hidden dependencies between tests.
7. **Test failure modes.** Database down, network timeout, connection pool exhausted — integration tests should verify graceful degradation.

## Keep/Discard Discipline
Each integration test boundary either passes or gets reverted. No flaky tests remain.
- **KEEP**: All tests pass deterministically, container setup is reproducible, cleanup verified.
- **DISCARD**: Flaky test (passes sometimes, fails sometimes). Diagnose root cause before re-adding.
- **CRASH**: Container startup failure or port conflict. Fix infrastructure, then retry once.
- Log every boundary result to `.godmode/integration-results.tsv`.

## Stop Conditions
- All external boundaries have integration test coverage (database, API, cache, queue).
- All integration tests pass with real containers, no mocks for external dependencies.
- Test data isolation verified with no leakage between tests.
- Average test duration under 5 seconds per test (excluding container startup).

## HARD RULES
1. NEVER mock the database in integration tests — use Testcontainers or real instances. Mocking defeats the purpose.
2. NEVER share test databases across parallel test runs — each run gets its own container.
3. NEVER hardcode ports — always use `container.getMappedPort()` for dynamic port assignment.
4. NEVER seed all data globally — each test owns its data. Global seeds create hidden coupling.
5. NEVER use production databases for testing — not even read-only queries.
6. NEVER skip cleanup between tests — leftover data causes mysterious failures.
7. ALWAYS separate integration tests from unit tests in CI — integration tests are slower and run independently.
8. ALWAYS test the transaction boundary — verify multi-step operations fully succeed or fully roll back.
9. ALWAYS include a timeout for container startup (`beforeAll` timeout >= 60s).
10. ALWAYS test failure modes (database down, network timeout, pool exhaustion) — not just happy paths.
AUTO-DETECT:
1. Scan for existing test infrastructure:
 - docker-compose*.yml, Dockerfile*, testcontainers* references
 - tests/integration/, tests/e2e/, **/it/
2. Detect test framework:
 - package.json → jest, vitest, mocha
 - pyproject.toml → pytest, pytest markers
 - go.mod → testing package, testify
 - pom.xml/build.gradle → JUnit, Testcontainers
3. Detect external dependencies:
 - Database connections: pg, mysql2, mongoose, prisma, sqlalchemy, gorm
 - Message queues: kafkajs, amqplib, bullmq
 - Cache: ioredis, redis, node-cache
 - External APIs: axios, fetch, http client calls
4. Detect ORM/migration tooling:
 - Prisma, Drizzle, Knex, TypeORM, Sequelize
 - Alembic, Django migrations, Flask-Migrate
 - golang-migrate, goose
5. Check for existing seeding:
 - seeds/, fixtures/, factories/, test-data/
 - Factory libraries (factory-boy, fishery, faker)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Assess boundaries and write integration tests |
| `--for <file>` | Write integration tests for a specific module |
| `--container <type>` | Specify container type (postgres, mysql, redis, kafka, mongo) |

## Output Format
Print on completion: `Integration: {total_tests} tests across {boundary_count} boundaries. Containers: {containers}. Pass rate: {pass_rate}%. Avg duration: {avg_ms}ms. Verdict: {verdict}.`

## TSV Logging
Log every boundary result to `.godmode/integration-results.tsv`:
```
iteration	boundary	container	tests_written	tests_passing	avg_duration_ms	status
1	database	postgres:16	6	6	245	passing
2	api	postgres:16	8	7	312	failing
3	queue	kafka:3.6	4	4	890	passing
```
Columns: iteration, boundary, container, tests_written, tests_passing, avg_duration_ms, status(passing/failing/flaky).

## Success Criteria
- All external boundaries have integration test coverage (database, API, cache, queue).
- All integration tests pass with real containers (no mocks for external dependencies).
- Test data isolation verified (no leakage between tests).
- Transaction boundaries tested (multi-step operations succeed or fully roll back).
- Failure modes tested (connection failure, timeout, constraint violation).
- Average test duration under 5 seconds per test (excluding container startup).
- CI pipeline runs integration tests on every PR with container support.

## Error Recovery
| Failure | Action |
|---------|--------|
| Container fails to start | Check Docker daemon is running. Verify image tag exists. Increase startup timeout. Fall back to `docker-compose` if Testcontainers unavailable. |
| Port conflict on container | Use random port mapping (Testcontainers default). Never hardcode ports. Check for zombie containers: `docker ps -a`. |
| Test data leaks between tests | Verify cleanup strategy: transaction rollback, TRUNCATE, or unique prefixes. Run tests in isolation to confirm. |
| Flaky integration test (passes sometimes) | Check for race conditions, shared state, or insufficient wait times. Add explicit readiness checks before assertions. |
