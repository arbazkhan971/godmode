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
find . -name "*integration*" -o -name "*e2e*" -o -path "*/it/*"

# Check for Docker/container configuration
find . -name "docker-compose*" -o -name "Dockerfile*" -o -name "testcontainers*"
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

#### Testcontainers — Go

```go
package repository_test

import (
    "context"
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/testcontainers/testcontainers-go"
    "github.com/testcontainers/testcontainers-go/modules/postgres"
)

func setupPostgres(t *testing.T) *sql.DB {
    ctx := context.Background()

    pgContainer, err := postgres.Run(ctx,
        "postgres:16-alpine",
        postgres.WithDatabase("testdb"),
        postgres.WithUsername("test"),
        postgres.WithPassword("test"),
        testcontainers.WithWaitStrategy(
            wait.ForLog("database system is ready to accept connections").
                WithOccurrence(2).
                WithStartupTimeout(30*time.Second),
        ),
    )
    assert.NoError(t, err)
    t.Cleanup(func() { pgContainer.Terminate(ctx) })

    connStr, err := pgContainer.ConnectionString(ctx, "sslmode=disable")
    assert.NoError(t, err)

    db, err := sql.Open("postgres", connStr)
    assert.NoError(t, err)

    runMigrations(db)
    return db
}

func TestUserRepository_SaveAndFind(t *testing.T) {
    db := setupPostgres(t)
    repo := NewUserRepository(db)

    err := repo.Save(context.Background(), &User{ID: "1", Name: "Alice"})
    assert.NoError(t, err)

    user, err := repo.FindByID(context.Background(), "1")
    assert.NoError(t, err)
    assert.Equal(t, "Alice", user.Name)
}
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

#### Other Containers

```typescript
// Redis
import { RedisContainer } from '@testcontainers/redis';
const redis = await new RedisContainer().start();
const url = redis.getConnectionUrl();

// MongoDB
import { MongoDBContainer } from '@testcontainers/mongodb';
const mongo = await new MongoDBContainer('mongo:7').start();
const uri = mongo.getConnectionString();

// Kafka
import { KafkaContainer } from '@testcontainers/kafka';
const kafka = await new KafkaContainer().withExposedPorts(9093).start();
const brokers = [`${kafka.getHost()}:${kafka.getMappedPort(9093)}`];

// Elasticsearch
import { ElasticsearchContainer } from '@testcontainers/elasticsearch';
const es = await new ElasticsearchContainer('elasticsearch:8.11.0').start();
const url = es.getHttpUrl();

// LocalStack (AWS services)
import { LocalstackContainer } from '@testcontainers/localstack';
const localstack = await new LocalstackContainer().start();
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

```python
# Python — Factory Boy
import factory
from myapp.models import User, Order

class UserFactory(factory.Factory):
    class Meta:
        model = User

    id = factory.LazyFunction(uuid4)
    name = factory.Faker("name")
    email = factory.LazyAttribute(lambda o: f"{o.name.lower().replace(' ', '.')}@example.com")
    role = "member"

class OrderFactory(factory.Factory):
    class Meta:
        model = Order

    id = factory.LazyFunction(uuid4)
    user = factory.SubFactory(UserFactory)
    status = "pending"
    total = factory.LazyFunction(lambda: round(random.uniform(10, 500), 2))
```

**3. SQL file seeding (for large reference datasets)**
```sql
-- seeds/reference-data.sql
INSERT INTO countries (code, name) VALUES
  ('US', 'United States'),
  ('GB', 'United Kingdom'),
  ('DE', 'Germany');

INSERT INTO currencies (code, symbol, decimal_places) VALUES
  ('USD', '$', 2),
  ('GBP', '£', 2),
  ('EUR', '€', 2);
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

**Strategy 4: Fresh container per test class (most isolated, slowest)**
```
Use when: Tests modify schema, or cleanup is too complex.
Cost: Each test class gets a new container (adds 2-5 seconds).
```

#### Cleanup Decision Matrix
```
CHOOSE YOUR CLEANUP STRATEGY:

Fast + isolated:     Transaction rollback (if framework supports it)
Fast + simple:       TRUNCATE between tests
No cleanup needed:   Unique data per test (best for parallel tests)
Maximum isolation:   Fresh container per test class (slow, use sparingly)
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

#### HTTP API Testing — Python (pytest + httpx)

```python
import pytest
import httpx
from myapp import create_app

@pytest.fixture(scope="module")
def app(postgres_container):
    """Create the app with a real database."""
    return create_app(database_url=postgres_container.get_connection_url())

@pytest.fixture
def client(app):
    """HTTP client for testing."""
    with httpx.Client(app=app, base_url="http://test") as client:
        yield client

def test_creates_user_and_returns_201(client):
    response = client.post("/api/users", json={"name": "Alice", "email": "alice@example.com"})
    assert response.status_code == 201

    user = response.json()
    assert user["name"] == "Alice"

    # Verify persistence
    get_response = client.get(f"/api/users/{user['id']}")
    assert get_response.status_code == 200
    assert get_response.json()["name"] == "Alice"

def test_returns_409_for_duplicate_email(client):
    client.post("/api/users", json={"name": "Alice", "email": "dup@example.com"})
    response = client.post("/api/users", json={"name": "Bob", "email": "dup@example.com"})
    assert response.status_code == 409
```

#### HTTP API Testing — Go

```go
func TestCreateUser(t *testing.T) {
    db := setupPostgres(t)
    handler := NewUserHandler(NewUserRepository(db))
    server := httptest.NewServer(handler)
    defer server.Close()

    // Create user
    body := `{"name": "Alice", "email": "alice@example.com"}`
    resp, err := http.Post(server.URL+"/api/users", "application/json", strings.NewReader(body))
    assert.NoError(t, err)
    assert.Equal(t, http.StatusCreated, resp.StatusCode)

    var user User
    json.NewDecoder(resp.Body).Decode(&user)
    assert.Equal(t, "Alice", user.Name)

    // Verify persistence
    resp, err = http.Get(server.URL + "/api/users/" + user.ID)
    assert.NoError(t, err)
    assert.Equal(t, http.StatusOK, resp.StatusCode)
}
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

#### Pattern 4: Cache Integration
Test that caching works correctly with real cache:

```typescript
describe('CachedUserRepository (integration)', () => {
  let redis: StartedRedisContainer;
  let db: StartedPostgreSqlContainer;
  let cachedRepo: CachedUserRepository;

  beforeAll(async () => {
    [redis, db] = await Promise.all([
      new RedisContainer().start(),
      new PostgreSqlContainer().start(),
    ]);

    const dbRepo = new UserRepository(await connectDb(db));
    const cache = new RedisCache(redis.getConnectionUrl());
    cachedRepo = new CachedUserRepository(dbRepo, cache);
  });

  it('serves from cache on second read', async () => {
    await cachedRepo.save({ id: '1', name: 'Alice' });

    // First read — cache miss, hits database
    const first = await cachedRepo.findById('1');
    expect(first.name).toBe('Alice');

    // Modify directly in DB (bypassing cache)
    await directDbUpdate('1', { name: 'Modified' });

    // Second read — should still return cached value
    const second = await cachedRepo.findById('1');
    expect(second.name).toBe('Alice'); // Cache hit, stale but correct behavior
  });

  it('invalidates cache on update', async () => {
    await cachedRepo.save({ id: '2', name: 'Bob' });
    await cachedRepo.findById('2'); // Populate cache

    await cachedRepo.update('2', { name: 'Robert' });

    const user = await cachedRepo.findById('2');
    expect(user.name).toBe('Robert'); // Cache was invalidated
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

#### CI Configuration
```yaml
# .github/workflows/test.yml
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_DB: testdb
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - run: npm run test:integration
        env:
          DATABASE_URL: postgres://test:test@localhost:5432/testdb
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

### Testing a repository with a real database
```
User: /godmode:integration Test the OrderRepository with a real PostgreSQL

Integration: Analyzing OrderRepository...

Found: src/repositories/order-repository.ts
Dependencies: PostgreSQL (orders, order_items tables)
Migrations: migrations/001-create-orders.sql

Setting up Testcontainers:
  - PostgreSQL 16 container
  - Running migrations
  - Factory fixtures for orders and users

Creating: tests/integration/repositories/order-repository.test.ts

describe('OrderRepository (integration)', () => {
  // Container setup with beforeAll/afterAll
  it('saves and retrieves order with items', ...);
  it('finds orders by user ID', ...);
  it('updates order status', ...);
  it('handles concurrent status updates', ...);
  it('cascades delete to order items', ...);
  it('returns empty array for user with no orders', ...);
});

Writing 6 integration tests with PostgreSQL container...
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

## Anti-Patterns

- **Do NOT mock the database in integration tests.** That defeats the purpose. Use Testcontainers or an in-memory alternative.
- **Do NOT share test databases across parallel test runs.** Parallel tests writing to the same database cause non-deterministic failures. Use per-run containers.
- **Do NOT seed all data globally.** Global seed data creates hidden coupling between tests. Each test owns its data.
- **Do NOT skip cleanup.** Leftover data from one test causes the next test to fail in mysterious ways. Always clean up.
- **Do NOT use production databases for testing.** Not even read-only queries. Use dedicated test containers.
- **Do NOT ignore slow tests.** An integration test taking 30 seconds usually means a missing index, unnecessary sleep, or wrong wait strategy. Investigate.
- **Do NOT test everything with integration tests.** Pure logic belongs in unit tests. Integration tests verify boundaries and interactions. Use the testing pyramid: many unit tests, fewer integration tests.
- **Do NOT hardcode ports.** Testcontainers assign random ports. Always use `container.getMappedPort()` to get the actual port.
