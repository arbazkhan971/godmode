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
  ...
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
  ...
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
Target: <module/service>. Tests: <N> (DB: <N>, API: <N>, Queue: <N>).
Containers: <list>. Seeding: <strategy>. Cleanup: <strategy>. All passing: YES/NO.
```
### Step 8: Commit and Transition
Commit: `"test(integration): <module> — <N> tests with <containers>"`

## Key Behaviors
1. **Real dependencies, not mocks.** Mocking the DB = unit test with extra steps.
2. **Isolate between tests.** Clean state per test (truncate/rollback), real services.
3. **Testcontainers over shared instances.** Fresh, disposable per run.
4. **Test transaction boundaries.** Multi-step operations succeed or fully roll back.
5. **Separate from unit tests in CI.** Integration tests are slower.
6. **Seed minimally.** Each test owns its data. No global seeds.
7. **Test failure modes.** DB down, timeout, pool exhaustion.

## Keep/Discard Discipline
Each integration test boundary either passes or gets reverted. No flaky tests remain.
- **KEEP**: All tests pass deterministically, container setup is reproducible, cleanup verified.
- **DISCARD**: Flaky test (passes sometimes, fails sometimes). Diagnose root cause before re-adding.
- **CRASH**: Container startup failure or port conflict. Fix infrastructure, then retry once.
- Log every boundary result to `.godmode/integration-results.tsv`.

## Autonomy
Never ask to continue. Loop autonomously. Loop until target or budget. Never pause. Measure before/after. Guard: test_cmd && lint_cmd. On failure: git reset --hard HEAD~1.

## Stop Conditions
- All external boundaries have integration test coverage (database, API, cache, queue).
- All integration tests pass with real containers, no mocks for external dependencies.
- Test data isolation verified with no leakage between tests.
- Average test duration under 5 seconds per test (excluding container startup).

## HARD RULES
1. NEVER mock DB in integration tests — use Testcontainers or real instances.
2. NEVER share test DBs across parallel runs — each gets its own container.
3. NEVER hardcode ports — use `container.getMappedPort()`.
4. NEVER seed globally — each test owns its data.
5. NEVER use production databases for testing.
6. NEVER skip cleanup between tests.
7. ALWAYS separate integration from unit tests in CI.
8. ALWAYS test transaction boundaries (full success or full rollback).
9. ALWAYS include container startup timeout (>= 60s).
10. ALWAYS test failure modes (DB down, timeout, pool exhaustion).
AUTO-DETECT:
1. Test infra: docker-compose*.yml, testcontainers*, tests/integration/
2. Framework: jest/vitest/mocha, pytest, JUnit/Testcontainers
3. Dependencies: pg/mysql2/prisma/mongoose, kafkajs/amqplib, ioredis
4. ORM: Prisma/Drizzle/Knex/TypeORM, Alembic, golang-migrate
5. Seeding: seeds/, fixtures/, factories/, factory-boy/fishery/faker
```

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Assess boundaries and write integration tests |
| `--for <file>` | Write integration tests for a specific module |
| `--container <type>` | Specify container type (postgres, mysql, redis, kafka, mongo) |

## Output Format
Print on completion: `Integration: {total_tests} tests across {boundary_count} boundaries. Containers: {containers}. Pass rate: {pass_rate}%. Avg duration: {avg_ms}ms. Verdict: {verdict}.`

## TSV Logging
```
iteration	boundary	container	tests_written	tests_passing	avg_duration_ms	status
```

## Success Criteria
- All external boundaries covered (database, API, cache, queue) with real containers.
- Test data isolation verified, transaction boundaries tested, failure modes covered.
- Average test duration under 5s per test. CI runs integration tests on every PR.

## Error Recovery
  ...
