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

# Check for Docker/container configuration
find. -name "docker-compose*" -o -name "Dockerfile*" -o -name "testcontainers*"
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
 let client: Client;

 beforeAll(async () => {
 // Start a real PostgreSQL container
 container = await new PostgreSqlContainer('postgres:16-alpine')
.withDatabase('testdb')
.withUsername('test')
.withPassword('test')
.start();

 // Connect using the container's dynamic port
 client = new Client({
 host: container.getHost(),
 port: container.getMappedPort(5432),
 database: container.getDatabase(),
 user: container.getUsername(),
 password: container.getPassword(),
 });
 await client.connect();

 // Run migrations
 await runMigrations(client);
 }, 60_000); // Container startup can take time

 afterAll(async () => {
 await client.end();
 await container.stop();
 });

 beforeEach(async () => {
 // Clean slate for each test
 await client.query('DELETE FROM users');
 });

 it('inserts and retrieves a user', async () => {
 const repo = new UserRepository(client);

 await repo.save({ id: '1', name: 'Alice', email: 'alice@example.com' });
 const user = await repo.findById('1');

 expect(user).toEqual({
 id: '1',
 name: 'Alice',
 email: 'alice@example.com',
 });
 });

 it('returns null for non-existent user', async () => {
 const repo = new UserRepository(client);
 const user = await repo.findById('nonexistent');
 expect(user).toBeNull();
 });
});
```

#### Testcontainers — Python

```python
import pytest
from testcontainers.postgres import PostgresContainer
import psycopg2

@pytest.fixture(scope="module")
def postgres():
 """Start a PostgreSQL container for the test module."""
 with PostgresContainer("postgres:16-alpine") as pg:
 conn = psycopg2.connect(pg.get_connection_url())
 run_migrations(conn)
 yield conn
 conn.close()

@pytest.fixture(autouse=True)
def clean_tables(postgres):
 """Clean all tables before each test."""
 cursor = postgres.cursor()
 cursor.execute("DELETE FROM users")
 postgres.commit()
 yield
 postgres.rollback()

def test_inserts_and_retrieves_user(postgres):
 repo = UserRepository(postgres)
 repo.save(User(id="1", name="Alice", email="alice@example.com"))

 user = repo.find_by_id("1")

 assert user.name == "Alice"
 assert user.email == "alice@example.com"

def test_returns_none_for_nonexistent_user(postgres):
 repo = UserRepository(postgres)
 assert repo.find_by_id("nonexistent") is None
```

#### Testcontainers — Java (JUnit 5)

```java
@Testcontainers
class UserRepositoryIntegrationTest {

 @Container
 static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16-alpine")
.withDatabaseName("testdb")
.withUsername("test")
.withPassword("test");

 private UserRepository repo;
 private JdbcTemplate jdbc;

 @BeforeEach
 void setUp() {
 var dataSource = new DriverManagerDataSource(
 postgres.getJdbcUrl(),
 postgres.getUsername(),
 postgres.getPassword()
 );
 jdbc = new JdbcTemplate(dataSource);
 runMigrations(jdbc);
 repo = new UserRepository(jdbc);
 }

 @AfterEach
 void tearDown() {
 jdbc.execute("DELETE FROM users");
 }

 @Test
 void insertsAndRetrievesUser() {
 repo.save(new User("1", "Alice", "alice@example.com"));

 var user = repo.findById("1");

 assertThat(user).isPresent();
 assertThat(user.get().getName()).isEqualTo("Alice");
 }
}
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

 // Step 3: Do NOT seed test-specific data here — do it in each test
}
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
 role: 'member',
 createdAt: new Date(),
...overrides,
 };
}

export function createOrder(user: User, overrides: Partial<Order> = {}): Order {
 return {
 id: randomUUID(),
 userId: user.id,
 items: [{ product: 'Widget', quantity: 1, price: 9.99 }],
 status: 'pending',
 total: 9.99,
...overrides,
 };
}

// In tests:
it('marks order as shipped', async () => {
 const user = createUser();
 await userRepo.save(user);
 const order = createOrder(user, { status: 'paid' });
 await orderRepo.save(order);

 await orderService.shipOrder(order.id);

 const updated = await orderRepo.findById(order.id);
 expect(updated.status).toBe('shipped');
});
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

afterEach(async () => {
 await transaction.rollback(); // All changes disappear
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

 const found = await repo.findByEmail(`${unique}@test.com`);
 expect(found.id).toBe(user.id);
});
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

 beforeAll(async () => {
 container = await new PostgreSqlContainer().start();
 app = createApp({
 databaseUrl: container.getConnectionString(),
 });
 });

 afterAll(async () => {
 await container.stop();
 });

 it('creates a user and returns 201', async () => {
 const response = await request(app)
.post('/api/users')
.send({ name: 'Alice', email: 'alice@example.com' })
.expect(201);

 expect(response.body).toMatchObject({
 id: expect.any(String),
 name: 'Alice',
 email: 'alice@example.com',
 });

 // Verify it was actually persisted
 const getResponse = await request(app)
.get(`/api/users/${response.body.id}`)
.expect(200);

 expect(getResponse.body.name).toBe('Alice');
 });

 it('returns 409 when email already exists', async () => {
 await request(app)
.post('/api/users')
.send({ name: 'Alice', email: 'duplicate@example.com' })
.expect(201);

 await request(app)
.post('/api/users')
.send({ name: 'Bob', email: 'duplicate@example.com' })
.expect(409);
 });

 it('returns 400 for invalid email format', async () => {
 const response = await request(app)
.post('/api/users')
.send({ name: 'Alice', email: 'not-an-email' })
.expect(400);

 expect(response.body.error).toContain('email');
 });
});
```

#### Testing Authenticated Endpoints

```typescript
describe('authenticated API routes', () => {
 let authToken: string;

 beforeAll(async () => {
 // Create a test user and get a real auth token
 await request(app)
.post('/api/auth/register')
.send({ email: 'test@example.com', password: 'Test1234!' });

 const loginResponse = await request(app)
.post('/api/auth/login')
.send({ email: 'test@example.com', password: 'Test1234!' });

 authToken = loginResponse.body.token;
 });

 it('returns user profile with valid token', async () => {
 const response = await request(app)
.get('/api/me')
.set('Authorization', `Bearer ${authToken}`)
.expect(200);

 expect(response.body.email).toBe('test@example.com');
 });

 it('returns 401 without token', async () => {
 await request(app)
.get('/api/me')
.expect(401);
 });

 it('returns 401 with expired token', async () => {
 const expiredToken = createExpiredToken({ userId: '1' });
 await request(app)
.get('/api/me')
.set('Authorization', `Bearer ${expiredToken}`)
.expect(401);
 });
});
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

 beforeAll(async () => {
 const db = await setupTestDatabase();
 orderRepo = new OrderRepository(db);
 inventoryRepo = new InventoryRepository(db);
 orderService = new OrderService(orderRepo, inventoryRepo);
 });

 it('creates order AND decrements inventory atomically', async () => {
 // Seed: 10 widgets in stock
 await inventoryRepo.setStock('widget', 10);

 // Act: place order for 3 widgets
 const order = await orderService.placeOrder({
 items: [{ product: 'widget', quantity: 3 }],
 });

 // Assert: order created
 expect(order.status).toBe('confirmed');

 // Assert: inventory decremented
 const stock = await inventoryRepo.getStock('widget');
 expect(stock).toBe(7);
 });

 it('rolls back order when inventory is insufficient', async () => {
 await inventoryRepo.setStock('widget', 2);

 await expect(
 orderService.placeOrder({
 items: [{ product: 'widget', quantity: 5 }],
 })
 ).rejects.toThrow(InsufficientStockError);

 // Inventory should be unchanged (transaction rolled back)
 const stock = await inventoryRepo.getStock('widget');
 expect(stock).toBe(2);
 });
});
```

#### Pattern 2: Service-to-Service Integration
Test that services communicate correctly through their real interfaces:

```typescript
describe('CheckoutFlow (integration)', () => {
 // Real services, but external payment gateway is a mock server
 let orderService: OrderService;
 let paymentService: PaymentService;
 let notificationService: NotificationService;

 beforeAll(async () => {
 const db = await setupTestDatabase();
 // Mock server for external payment API
 const paymentMock = await startWireMockServer({
 mappings: [
 {
 request: { method: 'POST', url: '/charge' },
 response: { status: 200, body: { transactionId: 'tx_123' } },
 },
 ],
 });

 paymentService = new PaymentService({ baseUrl: paymentMock.url });
 orderService = new OrderService(new OrderRepository(db));
 notificationService = new NotificationService(new InMemoryEmailSender());
 });

 it('completes checkout: creates order, charges payment, sends confirmation', async () => {
 const result = await checkoutFlow.execute({
 userId: 'user-1',
 items: [{ product: 'widget', quantity: 1, price: 9.99 }],
 paymentMethod: 'card_123',
 });

 expect(result.order.status).toBe('paid');
 expect(result.payment.transactionId).toBe('tx_123');
 expect(result.notificationSent).toBe(true);
 });
});
```

#### Pattern 3: Message Queue Integration
Test that producers and consumers work together through a real message broker:

```typescript
describe('Order Event Processing (integration)', () => {
 let kafkaContainer: StartedKafkaContainer;
 let producer: OrderEventProducer;
 let consumer: OrderEventConsumer;

 beforeAll(async () => {
 kafkaContainer = await new KafkaContainer().start();
 const brokers = [`${kafkaContainer.getHost()}:${kafkaContainer.getMappedPort(9093)}`];

 producer = new OrderEventProducer({ brokers });
 consumer = new OrderEventConsumer({ brokers, groupId: 'test-group' });
 await consumer.subscribe('order-events');
 });

 it('publishes order.created event and consumer processes it', async () => {
 const receivedEvents: OrderEvent[] = [];
 consumer.on('order.created', (event) => receivedEvents.push(event));
 await consumer.start();

 await producer.publish({
 type: 'order.created',
 orderId: 'order-123',
 userId: 'user-1',
 total: 49.99,
 });

 // Wait for consumer to process (with timeout)
 await waitFor(() => expect(receivedEvents).toHaveLength(1), { timeout: 5000 });

 expect(receivedEvents[0]).toMatchObject({
 type: 'order.created',
 orderId: 'order-123',
 });
 });
});
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
 }
}
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
 if testing.Short() {
 t.Skip("skipping integration test in short mode")
 }
...
}
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

## Example Usage


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
| `--seed` | Focus on creating seed data and fixtures |
| `--api` | Focus on API endpoint integration tests |
| `--service` | Focus on service-level integration patterns |
| `--ci` | Generate CI configuration for integration tests |
| `--cleanup <strategy>` | Specify cleanup strategy (truncate, rollback, unique) |



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
