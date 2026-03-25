---
name: integration
description: |
  Integration testing skill. Tests across real
  boundaries — databases, APIs, message queues.
  Covers Testcontainers, DB seeding/cleanup, API
  integration. Triggers on: /godmode:integration,
  "test with real database", "testcontainers".
---

# Integration — Integration Testing

## When to Activate
- User invokes `/godmode:integration`
- User says "test with real database", "test API"
- User asks about Testcontainers or Docker-based deps
- `/godmode:test` identifies integration coverage gaps

## Workflow

### Step 1: Assess Integration Boundaries

```bash
# Identify external dependencies
grep -rn "createConnection\|createPool\|mongoose" \
  src/ --include="*.ts" | head -10

# Check for existing integration tests
find . -name "*integration*" -o -path "*/it/*" \
  | grep -v node_modules | head -10

# Check Docker availability
docker info > /dev/null 2>&1 && echo "Docker: OK" \
  || echo "Docker: NOT AVAILABLE"
```

```
INTEGRATION BOUNDARY MAP:
Target: <module/service>
Language: <language>, Framework: <test framework>

Dependencies:
  Databases: <PostgreSQL | MySQL | MongoDB | Redis>
  APIs: <external services>
  Queues: <Kafka | RabbitMQ | SQS>

IF no integration tests exist: start with DB boundary
IF heavily mocked code: replace mocks with containers
IF Docker unavailable: use test DB instance instead
```

### Step 2: Set Up Testcontainers

```typescript
// Node.js / TypeScript example
import { PostgreSqlContainer } from
  '@testcontainers/postgresql';

let container;
beforeAll(async () => {
  container = await new PostgreSqlContainer()
    .start();
  // container.getConnectionUri() for connection
}, 60_000); // 60s timeout for container startup
```

```python
# Python example
import pytest
from testcontainers.postgres import PostgresContainer

@pytest.fixture(scope="module")
def postgres():
    with PostgresContainer("postgres:16-alpine") as pg:
        yield pg
```

### Step 3: Database Seeding & Cleanup

```
CLEANUP STRATEGIES:
| Strategy           | Speed  | Isolation  |
|-------------------|--------|-----------|
| Transaction rollback| Fast  | High      |
| TRUNCATE between   | Fast   | High      |
| Unique data/test   | No cleanup| Parallel|
| Fresh container    | Slow   | Maximum   |

IF framework supports it: transaction rollback
IF parallel tests: unique data per test
IF schema tests: fresh container per class

THRESHOLDS:
  Container startup timeout: >= 60 seconds
  Avg test duration target: < 5 seconds
  IF test > 10s: check query optimization
  IF flaky: check cleanup, add retry for container
```

### Step 4: API Integration Testing

```bash
# Run integration tests with longer timeout
npx vitest run tests/integration/ --timeout=30000

# Python
pytest tests/integration/ -m integration -v
```

```
API TEST PATTERNS:
  POST → verify 201 + DB has record
  GET → verify response matches seeded data
  PUT → verify updated fields persist
  DELETE → verify record removed
  Auth: get real token, test protected endpoints
  Errors: test 400, 401, 403, 404, 409
```

### Step 5: Service-Level Integration

```
PATTERNS:
1. Service → Database: real DB, real repo, real service
2. Service → Service: real services, mock external APIs
3. Producer → Queue → Consumer: real broker container

IF testing queue: verify message delivery + processing
IF testing transactions: verify full commit or rollback
IF testing failure: simulate DB down, timeout, pool full
```

### Step 6: Test Configuration

```json
// package.json — separate from unit tests
{
  "scripts": {
    "test": "jest --testPathPattern='tests/unit'",
    "test:integration": "jest --testPathPattern=\
'tests/integration'",
    "test:all": "jest"
  }
}
```

```
SEPARATION RULES:
  Unit tests: fast, no containers, run on every save
  Integration: slower, needs Docker, run on PR
  IF mixed in same suite: tag and filter
  CI pipeline: unit first, then integration
```

### Step 7: Run, Verify, Report

```
INTEGRATION TEST REPORT:
Target: <module>
Tests: <N> (DB: <N>, API: <N>, Queue: <N>)
Containers: <list>
Seeding: <strategy>, Cleanup: <strategy>
All passing: YES/NO
Avg duration: <N>ms per test
```

Commit: `"test(integration): <module> — <N> tests
  with <containers>"`

## Key Behaviors

1. **Real dependencies, not mocks.**
2. **Isolate between tests.** Clean state each time.
3. **Testcontainers over shared instances.**
4. **Test transaction boundaries.**
5. **Separate from unit tests in CI.**
6. **Seed minimally.** Each test owns its data.
7. **Test failure modes.** DB down, timeout, pool full.

## HARD RULES

1. Never mock DB in integration tests.
2. Never share test DBs across parallel runs.
3. Never hardcode ports — use getMappedPort().
4. Never seed globally — each test owns its data.
5. Never use production databases for testing.
6. Never skip cleanup between tests.
7. Always separate integration from unit in CI.
8. Always test transaction boundaries.
9. Always include container startup timeout (>= 60s).
10. Always test failure modes.

## Auto-Detection
```
1. Test infra: docker-compose, testcontainers
2. Framework: jest/vitest, pytest, JUnit
3. Dependencies: pg/mysql2/prisma, kafkajs, ioredis
4. ORM: Prisma/Drizzle/Knex, Alembic
5. Seeding: seeds/, fixtures/, factories/
```

## Quality Targets
- Target: <30s per integration test execution
- Target: >90% integration test pass rate
- Target: 0 flaky tests (>1% failure rate quarantined)
- Test data cleanup: 100% of fixtures torn down after run

## Output Format
Print: `Integration: {tests} tests, {boundaries}
  boundaries. Containers: {list}.
  Pass rate: {rate}%. Avg: {ms}ms. Verdict: {verdict}.`

## TSV Logging
```
iteration	boundary	container	tests	passing	avg_ms	status
```

## Keep/Discard Discipline
```
KEEP if: all tests pass deterministically
  AND container setup reproducible AND cleanup verified
DISCARD if: flaky (passes sometimes, fails sometimes)
  Diagnose root cause before re-adding.
```

## Stop Conditions
```
STOP when ALL of:
  - All external boundaries covered
  - All tests pass with real containers
  - Data isolation verified, no leakage
  - Avg duration < 5s per test
```

## Error Recovery
- Container fails to start: check Docker, increase timeout.
- Port conflict: use getMappedPort(), never hardcode.
- Test data leaks: switch to transaction rollback.
- Flaky test: add retry for container, check cleanup.
