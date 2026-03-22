---
name: fastapi
description: |
  FastAPI mastery skill. Activates when user needs to build, configure, optimize, or debug FastAPI applications. Covers Pydantic model design, dependency injection patterns, async database access (SQLAlchemy async, Tortoise ORM), background tasks, WebSocket support, and testing with pytest and HTTPX. Provides opinionated guidance on production-grade FastAPI patterns. Triggers on: /godmode:fastapi, "fastapi", "pydantic", "async api", "python api", or when the orchestrator detects Python async backend work using FastAPI.
---

# FastAPI — FastAPI Mastery

## When to Activate
- User invokes `/godmode:fastapi`
- User says "build a FastAPI app", "create an async API", "set up FastAPI"
- User asks about Pydantic models, dependency injection, async endpoints, or HTTPX testing
- When `/godmode:plan` identifies FastAPI implementation tasks
- When `/godmode:scaffold` detects a FastAPI project
- When working with Python async backend services

## Workflow

### Step 1: Project Assessment & Architecture Decision
Understand the project and choose the right FastAPI configuration:

```
FASTAPI ASSESSMENT:
Project: <name and purpose>
FastAPI version: <latest stable, e.g., 0.115.x>
Python version: <3.12+ recommended>
Architecture: Monolith | Modular monolith | Microservices
Database: PostgreSQL | MySQL | MongoDB | SQLite (dev)
ORM: SQLAlchemy 2.0 (async) | Tortoise ORM | SQLModel | Beanie (MongoDB)
Auth: JWT (python-jose) | OAuth2 | API keys | Session
Task queue: Celery | ARQ | Dramatiq | BackgroundTasks (simple)
Package manager: uv | Poetry | pip + venv
Deployment: Docker + uvicorn | Kubernetes | AWS Lambda (Mangum)
API docs: Swagger UI (default) | ReDoc | Both
```

```
FASTAPI PROJECT STRUCTURE:
app/
├── main.py                 # FastAPI application factory
├── config.py               # Settings with pydantic-settings
├── dependencies.py          # Shared dependencies (DB session, auth)
├── api/
│   ├── __init__.py
│   ├── v1/
│   │   ├── __init__.py
│   │   ├── router.py       # APIRouter aggregating all v1 routes
│   │   ├── orders.py       # Order endpoints
│   │   ├── customers.py    # Customer endpoints
│   │   └── auth.py         # Authentication endpoints
│   └── deps.py             # API-specific dependencies
├── models/
```

Rules:
- ALWAYS separate Pydantic schemas from SQLAlchemy models — they serve different purposes
- ALWAYS use async endpoints with async database drivers for I/O-bound work
- Use `pydantic-settings` for configuration management with environment variables
- Structure by feature (orders.py, customers.py) not by layer (routes.py, services.py)
- Use `uv` as package manager — it is 10-100x faster than pip

### Step 2: Pydantic Model Design
Design type-safe request/response schemas:

```python
from datetime import datetime
from decimal import Decimal
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, Field, EmailStr, field_validator, model_validator
# ... (condensed)
```

```
PYDANTIC PATTERNS:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  Usage                           │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Separate Create/Update/Response     │  Different fields per operation  │
│  field_validator                     │  Single-field custom validation  │
│  model_validator                     │  Cross-field validation          │
│  Field(..., gt=0, max_length=100)    │  Declarative constraints         │
│  ConfigDict(from_attributes=True)    │  ORM model -> Pydantic schema    │
│  Generic PaginatedResponse[T]        │  Reusable pagination wrapper     │
│  Summary schemas                     │  Lightweight nested objects      │
│  Computed fields                     │  Derived values in response      │
│  Discriminated unions                │  Polymorphic request bodies      │
│  Strict types                        │  StrictInt, StrictStr for safety │
└──────────────────────────────────────┴──────────────────────────────────┘
```

Rules:
- ALWAYS separate schemas: `Create` (input), `Update` (partial input), `Response` (output)
- Use `Field(...)` with constraints (`gt`, `le`, `max_length`) — validation at the schema level, not the endpoint
- Use `from_attributes=True` (was `orm_mode`) to convert SQLAlchemy models to Pydantic schemas
- Use Python 3.12+ syntax: `str | None` instead of `Optional[str]`, `list[T]` instead of `List[T]`
- Use generic `PaginatedResponse[T]` for consistent pagination across all list endpoints

### Step 3: Dependency Injection Patterns
Leverage FastAPI's DI system:

```python
from collections.abc import AsyncGenerator
from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
# ... (condensed)
```

```
DEPENDENCY INJECTION PATTERNS:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  Usage                           │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Annotated[T, Depends(fn)]           │  Type-safe DI (Python 3.9+)     │
│  yield dependencies                  │  Resource lifecycle (DB, files)  │
│  Nested dependencies                 │  Service -> Repository -> DB     │
│  Parameterized dependencies          │  require_role("admin")           │
│  Class-based dependencies            │  Service classes with __init__   │
│  Cached dependencies                 │  use_cache=True on Depends       │
│  Request-scoped                      │  Default — one per request       │
│  App-scoped (lifespan)               │  DB pool, HTTP clients           │
└──────────────────────────────────────┴──────────────────────────────────┘
```

Rules:
- Use `Annotated` type aliases for commonly used dependencies — cleaner function signatures
- Use `yield` in dependencies for resource cleanup (database sessions, file handles)
- Keep dependency chains shallow (max 3 levels deep) — deep chains are hard to debug
- Use lifespan events for app-scoped resources (connection pools, HTTP client pools)
- Dependencies are request-scoped by default — safe for database sessions

### Step 4: Async Database Access
Configure async SQLAlchemy:

```python
from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
# ... (condensed)
```

```
ASYNC DATABASE PATTERNS:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  Usage                           │
├──────────────────────────────────────┼──────────────────────────────────┤
│  asyncpg driver                      │  PostgreSQL async driver         │
│  expire_on_commit=False              │  Access attributes after commit  │
│  selectin loading                    │  Async-safe eager loading        │
│  Repository pattern                  │  Encapsulate query logic         │
│  Alembic async migrations            │  Schema version control          │
│  select() + execute()                │  SQLAlchemy 2.0 query style      │
│  session.flush()                     │  Get ID before commit            │
│  Mapped[] annotations                │  Type-safe column definitions    │
│  TimestampMixin                      │  Reusable audit fields           │
│  Composite indexes                   │  Multi-column query optimization │
└──────────────────────────────────────┴──────────────────────────────────┘
```

Rules:
- ALWAYS use `asyncpg` driver for PostgreSQL (`postgresql+asyncpg://`)
- ALWAYS set `expire_on_commit=False` — avoids lazy loading errors in async context
- Use `selectin` loading strategy for relationships — it is async-safe unlike `lazy="joined"`
- Use SQLAlchemy 2.0 style (`select()`, `Mapped[]`) — not the legacy 1.x query API
- Use Alembic for migrations with async support — never auto-create tables in production
- Use repository pattern to keep query logic out of services and endpoints

### Step 5: Background Tasks & WebSocket Support
Handle async work and real-time communication:

```python
from fastapi import BackgroundTasks, WebSocket, WebSocketDisconnect

# Simple background tasks (no external queue needed)
@router.post("/orders", response_model=OrderResponse, status_code=201)
async def create_order(
    data: OrderCreate,
# ... (condensed)
```

```
ASYNC TASK STRATEGY:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Approach                            │  When to Use                     │
├──────────────────────────────────────┼──────────────────────────────────┤
│  BackgroundTasks                     │  Simple fire-and-forget (email)  │
│  Celery                              │  Complex workflows, scheduling   │
│  ARQ                                 │  Async-native, lightweight       │
│  Dramatiq                            │  Actor-based, reliable           │
│  asyncio.create_task()               │  In-process async work           │
└──────────────────────────────────────┴──────────────────────────────────┘

WEBSOCKET PATTERNS:
- ConnectionManager: Track active connections per channel
- Authentication: Verify JWT in WebSocket handshake query params
- Heartbeat: Ping/pong every 30s to detect stale connections
- Reconnection: Client-side exponential backoff on disconnect
- Scaling: Use Redis Pub/Sub for multi-process broadcasting
```

Rules:
- Use `BackgroundTasks` for simple, quick tasks that don't need retry logic
- Use Celery or ARQ for tasks that need retries, scheduling, or monitoring
- Authenticate WebSocket connections — check JWT in the initial handshake
- Use Redis Pub/Sub when running multiple uvicorn workers — in-memory ConnectionManager is per-process
- Always handle `WebSocketDisconnect` gracefully — clients disconnect without warning

### Step 6: Testing with pytest & HTTPX
Comprehensive async testing strategy:

```python
# conftest.py — Shared fixtures
import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

from app.main import create_app
# ... (condensed)
```

```
TESTING STRATEGY:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Layer                               │  Approach                        │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Endpoints (HTTP)                    │  pytest + HTTPX AsyncClient      │
│  Services (business logic)           │  pytest + async fixtures         │
│  Schemas (validation)                │  pytest + Pydantic validation    │
│  Repositories (data access)          │  pytest + test DB session        │
│  Dependencies (DI)                   │  dependency_overrides            │
│  WebSockets                          │  HTTPX WebSocket client          │
│  Background tasks                    │  Mock or capture tasks           │
│  Auth (JWT/OAuth2)                   │  Auth header fixtures            │
└──────────────────────────────────────┴──────────────────────────────────┘

TEST TOOLING:
```

Rules:
- Use `HTTPX AsyncClient` with `ASGITransport` — no need to start a server for testing
- Use `dependency_overrides` to swap database sessions and external services in tests
- Roll back transactions in test fixtures — each test gets a clean database
- Test Pydantic schemas independently — validation logic deserves its own tests
- Use `pytest.mark.anyio` or `pytest.mark.asyncio` for all async tests
- Use factories for test data — avoid hardcoded values that break when schemas change

### Step 7: Validation & Delivery
Verify the FastAPI application:

```
FASTAPI VALIDATION:
┌──────────────────────────────────────┬──────────┬──────────────────────┐
│  Check                               │  Status  │  Notes               │
├──────────────────────────────────────┼──────────┼──────────────────────┤
│  Async endpoints throughout          │  PASS    │  No sync blocking    │
│  Pydantic schemas for all I/O        │  PASS    │  Create/Update/Resp  │
│  Dependency injection (no globals)   │  PASS    │  Depends() everywhere│
│  Async DB driver (asyncpg)           │  PASS    │  No sync psycopg2    │
│  N+1 prevention (selectin loading)   │  PASS    │  Relationships loaded│
│  Auth on all protected endpoints     │  PASS    │  JWT + role checks   │
│  Input validation with constraints   │  PASS    │  Field validators    │
│  Error handling centralized          │  PASS    │  Exception handlers  │
│  Alembic migrations present          │  PASS    │  Version-controlled  │
│  Tests pass with HTTPX               │  PASS    │  Async test suite    │
│  Config via pydantic-settings        │  PASS    │  Typed env vars      │
```

```
FASTAPI DELIVERY:

Artifacts:
- Application: <service-name> FastAPI <version>
- Endpoints: <N> async endpoints across <M> resources
- Schemas: <N> Pydantic models (create/update/response)
- Services: <N> service classes with DI
- Tests: <N> async tests passing (endpoints, services, schemas)
- Migrations: <N> Alembic migration scripts
- OpenAPI spec: Auto-generated at /docs and /redoc
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:test — Add more test coverage
-> /godmode:secure — Security hardening audit
-> /godmode:deploy — Deploy with Docker + uvicorn
-> /godmode:loadtest — Performance testing (async throughput)
-> /godmode:observe — Set up structured logging and metrics
```

Commit: `"fastapi: <service> — <N> async endpoints, Pydantic schemas, pytest"`

## Key Behaviors

1. **Async everywhere.** If one layer is sync, the entire request blocks. Use async drivers, async ORM, async HTTP clients — all the way down.
2. **Pydantic is your contract.** Request schemas validate input. Response schemas shape output. They are your API documentation, your type safety, and your validation layer in one.
3. **Dependency injection over imports.** Never import a database session directly. Use `Depends()` for everything — it makes testing trivial with `dependency_overrides`.
4. **Separate schemas from models.** Pydantic schemas define API shape. SQLAlchemy models define database shape. They will diverge, and that is correct.
5. **Test with HTTPX, not requests.** HTTPX's `AsyncClient` with `ASGITransport` tests your app without starting a server — fast, reliable, and production-realistic.
6. **Auto-generated docs are a feature.** FastAPI generates OpenAPI docs from your type annotations and Pydantic schemas. Keep them accurate — they are your API documentation.
7. **Background tasks for side effects.** Email, analytics, notifications — anything that does not affect the response body goes in a background task or job queue.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full FastAPI setup workflow |
| `--schemas` | Design Pydantic models with validation |
| `--auth jwt` | Configure JWT authentication |

## Auto-Detection

On activation, automatically detect FastAPI project context:

```
AUTO-DETECT SEQUENCE:
1. Scan for FastAPI imports (from fastapi import FastAPI) in Python files
2. Detect Python version from pyproject.toml / setup.py / .python-version
3. Check package manager: uv (uv.lock), poetry (poetry.lock), pip (requirements.txt)
4. Detect ORM: SQLAlchemy (sqlalchemy in deps), Tortoise (tortoise-orm), SQLModel, Beanie
5. Check for async DB driver: asyncpg, aiomysql, motor — flag if sync driver used (psycopg2)
6. Detect auth pattern: python-jose (JWT), authlib (OAuth2), fastapi.security imports
7. Scan for Pydantic version (v1 vs v2) — flag deprecated v1 patterns (orm_mode, Optional vs | None)
8. Check for Alembic migrations directory (alembic/ or migrations/)
9. Detect test framework: pytest, httpx, pytest-asyncio, anyio
10. Check for existing project structure (monolith vs modular, feature-based vs layer-based)
```

## Explicit Loop Protocol

When building multiple API resources iteratively:

```
FASTAPI RESOURCE BUILD LOOP:
current_iteration = 0
resources = [resource_1, resource_2, ...]  // from project assessment

WHILE current_iteration < len(resources) AND NOT user_says_stop:
  1. SELECT next resource from priority list
  2. CREATE Pydantic schemas: <Resource>Create, <Resource>Update, <Resource>Response
  3. CREATE SQLAlchemy model with Mapped[] annotations and relationships
  4. CREATE repository with async queries (list_paginated, get_by_id, create, update)
  5. CREATE service class with business logic and DI
  6. CREATE router with async endpoints and dependency injection
  7. CREATE Alembic migration for new model
  8. WRITE tests: endpoint tests (HTTPX), service tests, schema validation tests
  9. RUN tests — if failures, fix before proceeding
  10. current_iteration += 1
  11. REPORT: "Resource <N>/<total> complete: <name> — <X> endpoints, <Y> tests passing"

ON COMPLETION:
  RUN full validation checklist (Step 7)
  REPORT: "<N> resources, <M> endpoints, <K> tests, all async, validation PASS/FAIL"
```

## Hard Rules

```
HARD RULES — FASTAPI:
1. ALWAYS use async endpoints with async DB drivers. One sync call blocks the entire event loop.
2. NEVER return SQLAlchemy models directly from endpoints. Use Pydantic response schemas.
3. NEVER import DB sessions as module globals. Use Depends(get_db) for request-scoped sessions.
4. ALWAYS separate Pydantic schemas: Create (input), Update (partial), Response (output). They WILL diverge.
5. ALWAYS set expire_on_commit=False on async sessions. Without it, accessing attributes after commit triggers sync IO.
6. ALWAYS use selectin loading for async relationships. lazy loading triggers synchronous queries in async context.
7. NEVER use metadata.create_all() in production. Use Alembic migrations for schema management.
8. ALWAYS use Field() with constraints (gt, le, max_length) on Pydantic schemas. Validate at the schema level.
9. NEVER block the event loop with CPU-intensive work. Use run_in_executor or a separate worker process.
10. ALWAYS use pydantic-settings for configuration. Hardcoded config values are deployment bugs waiting to happen.
```

## Output Format

End every FastAPI skill invocation with this summary block:

```
FASTAPI RESULT:
Action: <scaffold | endpoint | model | schema | service | optimize | test | audit | upgrade>
Files created/modified: <N>
Endpoints created/modified: <N>
Models created/modified: <N>
Alembic migrations: <N created>
Tests passing: <yes | no | skipped>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
timestamp	project	action	files_count	endpoints_count	models_count	migrations_count	tests_status	notes
```

## Success Criteria

Every FastAPI skill invocation must pass ALL of these checks before reporting success:

1. `mypy .` or `pyright .` passes with zero errors
2. `pytest` passes if test suite exists
3. No sync database drivers (no `psycopg2` without async wrapper)
4. All endpoints use Pydantic response models (no raw dict returns)
5. All database sessions use `Depends(get_db)` (no module-global sessions)
6. All Pydantic schemas use `Field()` with constraints where applicable
7. No `metadata.create_all()` in production code (use Alembic)
8. No blocking calls in async endpoints (no `requests`, no sync file I/O)
9. All configuration uses `pydantic-settings` (no hardcoded values)
10. Alembic migration chain is linear (no multiple heads)

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Error Recovery

IF mypy/pyright fails:
  1. Fix type errors in order: models → schemas → services → routers
IF tests fail:
  1. Verify test database is configured and accessible
IF Alembic migration errors:
  1. Multiple heads → run `alembic merge heads` to create merge migration
IF async/blocking issues:
  1. Replace `requests` with `httpx.AsyncClient`
IF dependency injection errors:
  1. Verify all Depends() functions have correct signatures

## FastAPI Optimization Loop

```
FASTAPI OPTIMIZATION PASSES:

Pass 1 — Async Audit:
  1. Scan for blocking calls in async endpoints: requests→httpx, open→aiofiles,
     time.sleep→asyncio.sleep, psycopg2→asyncpg, pymongo→motor, redis-py→redis.asyncio
  2. Convert sync endpoints doing only I/O to async def with async libraries
  3. Offload CPU-intensive work to run_in_executor or ProcessPoolExecutor
  4. Monitor event loop lag (alert if >50ms)

Pass 2 — Dependency Injection Audit:
  1. Catalog all Depends() — verify scope (request vs app), caching, cleanup
  2. Fix: pool connections instead of creating per-request, cache I/O results
  3. Flatten deeply nested Depends() chains
  4. Add try/finally cleanup to all yield dependencies

```

## Keep/Discard Discipline
```
After EACH implementation or optimization change:
  1. MEASURE: Run tests / validate the change produces correct output.
  2. COMPARE: Is the result better than before? (faster, safer, more correct)
  3. DECIDE:
     - KEEP if: tests pass AND quality improved AND no regressions introduced
     - DISCARD if: tests fail OR performance regressed OR new errors introduced
  4. COMMIT kept changes with descriptive message. Revert discarded changes before proceeding.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All identified tasks are complete and validated
  - User explicitly requests stop
  - Max iterations reached — report partial results with remaining items listed

DO NOT STOP just because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (handle that in a follow-up pass)
```

