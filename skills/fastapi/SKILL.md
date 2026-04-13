---
name: fastapi
description: |
  FastAPI mastery skill. Covers Pydantic models, DI,
  async DB access, background tasks, WebSocket, testing.
  Triggers on: /godmode:fastapi, "fastapi", "pydantic",
  "async api", "python api".
---

# FastAPI — FastAPI Mastery

## Activate When
- User invokes `/godmode:fastapi`
- User says "build a FastAPI app", "async API"
- User asks about Pydantic, DI, async endpoints
- When working with Python async backend services

## Workflow

### Step 1: Project Assessment

```bash
# Detect FastAPI project
grep -l "fastapi" pyproject.toml requirements.txt \
  setup.py 2>/dev/null

# Check Python version
python3 --version

# Detect package manager
ls uv.lock poetry.lock Pipfile.lock 2>/dev/null
```

```
FASTAPI ASSESSMENT:
FastAPI version: <0.115.x>
Python: <3.12+ recommended>
ORM: SQLAlchemy 2.0 async | Tortoise | SQLModel
Auth: JWT | OAuth2 | API keys
Package manager: uv (preferred) | Poetry | pip

IF Python < 3.12: recommend upgrade for performance
IF using sync psycopg2: must migrate to asyncpg
IF no Alembic: add migration support immediately
```

```
PROJECT STRUCTURE:
app/
├── main.py           # FastAPI app factory
├── config.py         # pydantic-settings
├── dependencies.py   # Shared DI (DB, auth)
├── api/v1/
│   ├── router.py     # Aggregates all v1 routes
│   ├── orders.py     # Order endpoints
│   └── customers.py  # Customer endpoints
├── models/           # SQLAlchemy models
├── schemas/          # Pydantic schemas
├── services/         # Business logic
└── tests/
```

### Step 2: Pydantic Model Design

```
PYDANTIC PATTERNS:
| Pattern                  | Usage               |
|--------------------------|---------------------|
| Separate Create/Update/Resp | Per-operation    |
| field_validator          | Single-field custom |
| model_validator          | Cross-field logic   |
| Field(gt=0, max_length)  | Declarative limits |
| from_attributes=True     | ORM → Pydantic     |
| Generic PaginatedResp[T] | Reusable pagination|

THRESHOLDS:
  max_length for strings: always set (default 255)
  gt=0 for IDs and counts: always set
  le=1000 for pagination page_size: prevent abuse
  IF no Field() constraints: validation is incomplete
```

### Step 3: Dependency Injection

```
DI PATTERNS:
| Pattern             | Usage               |
|---------------------|---------------------|
| Annotated[T, Depends]| Type-safe DI       |
| yield dependencies  | Resource lifecycle  |
| Nested dependencies | Service → Repo → DB|
| Class-based deps    | Service classes     |
| Lifespan events     | App-scoped pools   |

RULES:
  Max DI chain depth: 3 levels
  IF deeper: refactor, something is over-abstracted
  IF using module globals for DB: refactor to Depends()
```

### Step 4: Async Database Access

```bash
# Install async driver
uv add asyncpg sqlalchemy[asyncio] alembic

# Initialize Alembic
alembic init -t async alembic
```

```
ASYNC DB RULES:
  Driver: asyncpg (never psycopg2 in async context)
  expire_on_commit: False (always)
  Loading: selectin (async-safe, not lazy)
  Query style: SQLAlchemy 2.0 (select(), Mapped[])
  Migrations: Alembic (never metadata.create_all())
  Pool: min 5, max 20 connections (tune per traffic)

IF N+1 detected: add with() eager loading
IF pool exhaustion: increase max, add connection timeout
```

### Step 5: Background Tasks & WebSocket

```
TASK STRATEGY:
| Approach        | When to Use            |
|-----------------|------------------------|
| BackgroundTasks | Simple fire-and-forget |
| Celery          | Complex, scheduling    |
| ARQ             | Async-native, light    |
| asyncio.create  | In-process async work  |

WEBSOCKET RULES:
  Authenticate in handshake (JWT in query params)
  Handle WebSocketDisconnect gracefully
  IF multi-worker: use Redis Pub/Sub (not in-memory)
  Connection limit: 1000 per server instance
```

### Step 6: Testing with pytest & HTTPX

```bash
# Run async tests
uv run pytest tests/ -v --tb=short

# Run with coverage
uv run pytest tests/ --cov=app --cov-report=term
```

```
TESTING STRATEGY:
| Layer       | Approach               |
|-------------|------------------------|
| Endpoints   | HTTPX AsyncClient      |
| Services    | pytest + async fixtures|
| Schemas     | Pydantic validation    |
| Repos       | Test DB session        |
| Dependencies| dependency_overrides   |

THRESHOLDS:
  Coverage target: >= 80% overall
  Endpoint coverage: 100% of routes
  Schema tests: every validation rule tested
  IF test uses real external service: mock it
```

### Step 7: Validation & Delivery

```
FASTAPI VALIDATION:
| Check                        | Status |
|------------------------------|--------|
| Async endpoints throughout   | ?      |
| Pydantic schemas for all I/O | ?      |
| DI via Depends() (no globals)| ?      |
| Async DB driver (asyncpg)    | ?      |
| N+1 prevention (selectin)    | ?      |
| Auth on protected endpoints  | ?      |
| Field() constraints on schemas| ?     |
| Alembic migrations present   | ?      |
```

Commit: `"fastapi: <service> — <N> async endpoints,
  Pydantic schemas, pytest"`

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Async everywhere.** One sync layer blocks all.
2. **Pydantic is your contract.**
3. **DI over imports.** Makes testing trivial.
4. **Separate schemas from models.** They diverge.
5. **Test with HTTPX, not requests.**
6. **Auto-generated docs are a feature.** Keep accurate.
7. **Background tasks for side effects.**

## HARD RULES

1. Always use async endpoints with async DB drivers.
2. Never return SQLAlchemy models from endpoints.
3. Never import DB sessions as module globals.
4. Always separate schemas: Create, Update, Response.
5. Always set expire_on_commit=False on async sessions.
6. Always use selectin loading for async relationships.
7. Never use metadata.create_all() in production.
8. Always use Field() constraints on Pydantic schemas.
9. Never block event loop with CPU-intensive work.
10. Always use pydantic-settings for configuration.

## Auto-Detection
```
1. FastAPI imports, Python version, package manager
2. ORM: SQLAlchemy/Tortoise/SQLModel, async driver
3. Auth: python-jose/authlib, Pydantic v1 vs v2
4. Tests: pytest/httpx, Alembic migrations
```

## Output Format
Print: `FastAPI: {action}, {endpoints} endpoints,
  {models} models. Tests: {status}. Verdict: {verdict}.`

## TSV Logging
```
timestamp	project	endpoints	models	migrations	tests	status
```

## Keep/Discard Discipline
```
KEEP if: tests pass AND quality improved
  AND no regressions
DISCARD if: tests fail OR performance regressed
```

## Stop Conditions
```
STOP when ANY of:
  - All tasks complete and validated
  - User requests stop
  - Max iterations reached
```

<!-- tier-3 -->

## Error Recovery
- mypy fails: fix models → schemas → services → routers.
- Tests fail: verify test DB configured.
- Alembic: multiple heads → `alembic merge heads`.
- Async issues: replace requests with httpx.AsyncClient.
- DI errors: verify Depends() function signatures.

