# Python Developer Guide

How to use Godmode's full workflow for Python projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Python via pyproject.toml, setup.py, or requirements.txt
# Test: pytest
# Lint: ruff check .
# Format: black --check . / ruff format --check .
# Type check: mypy .
```

### Example `.godmode/config.yaml`
```yaml
language: python
framework: fastapi          # or django, flask, etc.
test_command: pytest -x --tb=short
lint_command: ruff check .
format_command: black --check .
type_check_command: mypy . --ignore-missing-imports
build_command: python -m build
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/health
```

---

## How Each Skill Applies to Python

### THINK Phase

| Skill | Python Adaptation |
|-------|-------------------|
| **think** | Design data models and protocols first. A Python spec should define dataclasses, Pydantic models, or Protocol classes. Include type annotations in the spec. |
| **predict** | Expert panel evaluates Pythonic design, performance (GIL implications), and deployment strategy. Request panelists with Python depth (e.g., core contributor, Django maintainer). |
| **scenario** | Explore edge cases around `None` handling, exception hierarchies, async/sync boundaries, and import-time side effects. |

### BUILD Phase

| Skill | Python Adaptation |
|-------|-------------------|
| **plan** | Each task specifies modules and classes. File paths follow Python conventions (`src/app/services/user_service.py`). Tasks note which `__init__.py` exports need updating. |
| **build** | TDD with pytest. RED step writes a `test_*.py` file with fixtures. GREEN step implements the module. REFACTOR step adds type annotations, extracts helpers, uses comprehensions. |
| **test** | Use `pytest` fixtures, `parametrize`, and `monkeypatch`. Prefer `pytest-mock` for mocking. Structure tests in `tests/` mirroring `src/`. |
| **review** | Check for missing type annotations, bare `except` clauses, mutable default arguments, and proper use of `__all__` for public APIs. |

### OPTIMIZE Phase

| Skill | Python Adaptation |
|-------|-------------------|
| **optimize** | Target response time, memory usage, or startup time. Guard rail: `pytest -x` must pass on every iteration. Consider GIL-aware optimizations (multiprocessing, async I/O). |
| **debug** | Use `pdb`/`ipdb` for interactive debugging. Check for common Python pitfalls: mutable defaults, late binding closures, circular imports. |
| **fix** | Autonomous fix loop handles test failures, type errors, and lint violations. Guard rail: `pytest -x && mypy . && ruff check .` |
| **secure** | Audit dependencies with `pip-audit`. Check for SQL injection in raw queries, `eval()`/`exec()` usage, insecure deserialization (`pickle`), and path traversal. |

### SHIP Phase

| Skill | Python Adaptation |
|-------|-------------------|
| **ship** | Pre-flight: `pytest && mypy . && ruff check . && black --check .`. Verify Docker image builds or wheel packages correctly. |
| **finish** | Ensure `pyproject.toml` version is bumped. Verify `py.typed` marker exists if shipping a typed library. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| Test coverage | `pytest --cov=src --cov-report=term \| grep TOTAL \| awk '{print $4}'` | >= 85% |
| Type checking score | `mypy . --ignore-missing-imports 2>&1 \| tail -1` | 0 errors |
| Lint errors | `ruff check . 2>&1 \| tail -1` | 0 errors |
| Format check | `black --check . 2>&1; echo $?` | exit code 0 |
| Dependency vulnerabilities | `pip-audit 2>&1 \| grep 'found' \| awk '{print $2}'` | 0 |
| Response time | `curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/health` | < 0.05s |
| Import time | `python -X importtime -c "import app" 2>&1 \| head -1` | < 500ms |
| Memory usage | `python -c "import tracemalloc; tracemalloc.start(); from app import main; print(tracemalloc.get_traced_memory()[1])"` | Project-specific |

---

## Common Verify Commands

### Tests pass
```bash
pytest -x --tb=short
```

### Test coverage
```bash
pytest --cov=src --cov-report=term-missing
```

### Type check clean
```bash
mypy . --ignore-missing-imports --strict
```

### Lint clean
```bash
ruff check .
```

### Format check
```bash
black --check .
# or
ruff format --check .
```

### Security audit
```bash
pip-audit
```

### API responds
```bash
curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/health
```

---

## Tool Integration

### pytest

Godmode's TDD cycle maps directly to pytest:

```bash
# RED step: run single test file, expect failure
pytest tests/services/test_user_service.py -x

# GREEN step: run single test, expect pass
pytest tests/services/test_user_service.py -x

# After GREEN: run full suite to catch regressions
pytest

# Coverage check
pytest --cov=src --cov-report=html
```

**Fixtures** for Godmode projects:
```python
# conftest.py
import pytest
from app.database import get_test_db

@pytest.fixture
def db():
    """Provide a clean test database for each test."""
    database = get_test_db()
    yield database
    database.rollback()

@pytest.fixture
def client(db):
    """Provide a test client with database access."""
    from app.main import create_app
    app = create_app(database=db)
    with app.test_client() as client:
        yield client
```

### mypy

Use mypy as a guard rail in every optimization and build step:

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: mypy . --ignore-missing-imports
    expect: exit code 0
  - command: pytest -x
    expect: exit code 0
```

**Strict config** in `pyproject.toml`:
```toml
[tool.mypy]
strict = true
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
check_untyped_defs = true
```

### ruff

Ruff replaces flake8, isort, pyupgrade, and more — fast enough to use as a guard rail:

```bash
# Check for issues (guard rail)
ruff check .

# Auto-fix safe issues during refactor step
ruff check . --fix

# Format check
ruff format --check .

# Auto-format during refactor step
ruff format .
```

### black

If using black instead of ruff for formatting:

```bash
# Check formatting (guard rail)
black --check .

# Auto-format during refactor step
black .
```

---

## Framework Integration

### Django

```yaml
# .godmode/config.yaml
framework: django
test_command: python manage.py test --verbosity 2
lint_command: ruff check .
type_check_command: mypy . --settings-module=myproject.settings
build_command: python manage.py collectstatic --noinput
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/api/health/
```

Django-specific THINK considerations:
- Model design with migrations strategy
- URL routing and view structure (function-based vs. class-based views)
- Serializer design (DRF serializers match Godmode's types-first approach)
- Query optimization with `select_related()` / `prefetch_related()`
- Middleware ordering and custom middleware design

Django-specific optimize targets:
```bash
# Query count for a view
python manage.py shell -c "
from django.test.utils import override_settings
from django.test import RequestFactory
from django.db import connection
factory = RequestFactory()
request = factory.get('/api/products/')
view(request)
print(len(connection.queries))
"

# Migration safety check
python manage.py makemigrations --check --dry-run
```

### FastAPI

```yaml
# .godmode/config.yaml
framework: fastapi
test_command: pytest -x --tb=short
lint_command: ruff check .
type_check_command: mypy . --ignore-missing-imports
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/health
```

FastAPI-specific THINK considerations:
- Pydantic model design (request/response schemas)
- Dependency injection architecture
- Async vs. sync endpoint decisions (I/O-bound vs. CPU-bound)
- Background task design
- WebSocket handler patterns

FastAPI-specific optimize targets:
```bash
# Concurrent request throughput
wrk -t4 -c100 -d10s http://localhost:8000/api/products | grep 'Requests/sec'

# Startup time
/usr/bin/time python -c "from app.main import app" 2>&1 | tail -1

# OpenAPI schema generation time
python -c "import time; start=time.time(); from app.main import app; app.openapi(); print(f'{(time.time()-start)*1000:.0f}ms')"
```

### Flask

```yaml
# .godmode/config.yaml
framework: flask
test_command: pytest -x --tb=short
lint_command: ruff check .
type_check_command: mypy . --ignore-missing-imports
build_command: flask --app app db upgrade
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:5000/health
```

Flask-specific THINK considerations:
- Blueprint structure for modular organization
- Application factory pattern
- Extension selection (SQLAlchemy, Marshmallow, Flask-Login)
- Request context and application context handling
- Error handler registration

---

## Example: Full Workflow for Building a Python Service

### Scenario
Build a notification service using FastAPI with async PostgreSQL access, background task processing, and WebSocket support.

### Step 1: Think (Design)
```
/godmode:think I need a notification service with FastAPI — supports
email, SMS, and push notifications. Async PostgreSQL with SQLAlchemy,
background task processing with Celery, real-time delivery via WebSocket.
```

Godmode produces a spec at `docs/specs/notification-service.md` containing:
- Pydantic models: `Notification`, `NotificationCreate`, `NotificationStatus`, `Channel`
- Endpoint design: `POST /notifications`, `GET /notifications/{id}`, `GET /notifications/stream` (WebSocket)
- Async architecture: FastAPI endpoints -> Celery tasks -> channel-specific senders
- Database schema: `notifications` table with status tracking and retry count

### Step 2: Plan (Decompose)
```
/godmode:plan
```

Produces `docs/plans/notification-service-plan.md` with tasks:
1. Define Pydantic models and enums (`app/models/notification.py`)
2. Create SQLAlchemy models and Alembic migration (`app/db/models.py`)
3. Implement notification repository with async queries (`app/repositories/notification_repo.py`)
4. Implement notification service with business logic (`app/services/notification_service.py`)
5. Create channel senders: email, SMS, push (`app/senders/`)
6. Implement Celery tasks for async delivery (`app/tasks/send_notification.py`)
7. Build FastAPI endpoints with dependency injection (`app/api/notifications.py`)
8. Add WebSocket endpoint for real-time updates (`app/api/ws.py`)
9. Integration tests with test containers

### Step 3: Build (TDD)
```
/godmode:build
```

Each task follows RED-GREEN-REFACTOR:

**Task 1 — RED:**
```python
# tests/models/test_notification.py
import pytest
from pydantic import ValidationError
from app.models.notification import NotificationCreate, Channel

def test_valid_notification_create():
    notif = NotificationCreate(
        recipient_id="user-123",
        channel=Channel.EMAIL,
        subject="Welcome",
        body="Hello, welcome to the platform.",
    )
    assert notif.recipient_id == "user-123"
    assert notif.channel == Channel.EMAIL

def test_invalid_channel_rejected():
    with pytest.raises(ValidationError):
        NotificationCreate(
            recipient_id="user-123",
            channel="pigeon",
            subject="Hello",
            body="This should fail.",
        )
```
Commit: `test(red): Notification models — failing Pydantic validation tests`

**Task 1 — GREEN:**
```python
# app/models/notification.py
from enum import Enum
from pydantic import BaseModel, Field

class Channel(str, Enum):
    EMAIL = "email"
    SMS = "sms"
    PUSH = "push"

class NotificationCreate(BaseModel):
    recipient_id: str = Field(..., min_length=1)
    channel: Channel
    subject: str = Field(..., min_length=1, max_length=255)
    body: str = Field(..., min_length=1)
    metadata: dict[str, str] | None = None
```
Commit: `feat: Notification models — Pydantic schemas with Channel enum`

Parallel agents handle tasks 3, 4, and 5 concurrently (no shared file dependencies).

### Step 4: Optimize
```
/godmode:optimize --goal "reduce notification creation latency" \
  --verify "curl -s -o /dev/null -w '%{time_total}' -X POST http://localhost:8000/notifications -H 'Content-Type: application/json' -d '{\"recipient_id\":\"user-1\",\"channel\":\"email\",\"subject\":\"test\",\"body\":\"test\"}'" \
  --target "< 0.02"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | Synchronous DB insert blocks response | Use `asyncpg` with async session | 85ms | 34ms | KEEP |
| 2 | Celery task dispatch is synchronous | Use `apply_async` with `ignore_result=True` | 34ms | 22ms | KEEP |
| 3 | Pydantic validation overhead | Use `model_validate` with strict mode | 22ms | 21ms | REVERT |
| 4 | Connection pool too small | Increase pool size from 5 to 20 | 22ms | 18ms | KEEP |

Final: 85ms to 18ms (78.8% improvement). Target met.

### Step 5: Secure
```
/godmode:secure
```

Findings:
- HIGH: No authentication on notification endpoints — add JWT middleware
- MEDIUM: Celery broker URL contains credentials in plain text — use environment variable
- MEDIUM: No input sanitization on notification body (potential XSS in email rendering)
- LOW: WebSocket endpoint has no connection rate limiting

### Step 6: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
pytest -x                 ✓ 42/42 passing
mypy . --strict           ✓ 0 errors
ruff check .              ✓ 0 issues
black --check .           ✓ 0 reformats
pip-audit                 ✓ 0 vulnerabilities
coverage                  ✓ 89% (target: 85%)
```

PR created with full description, optimization log, and security audit summary.

---

## Python-Specific Tips

### 1. Pydantic models are your spec
In the THINK phase, define Pydantic models before anything else. They serve as both validation logic and documentation. FastAPI and Django REST Framework both integrate directly with model schemas.

### 2. Use strict typing from day one
Enable `mypy --strict` in your project configuration. Godmode's fix loop can incrementally add type annotations to untyped code:
```
/godmode:optimize --goal "increase type coverage" --verify "mypy . --strict 2>&1 | grep -c 'error'" --target "0"
```

### 3. Use ruff for speed
Ruff is orders of magnitude faster than flake8 + isort + pyupgrade combined. It runs in milliseconds, making it an ideal guard rail that does not slow down the optimization loop.

### 4. Async-first for I/O-bound services
When building web services, prefer `async def` for endpoints that perform I/O (database queries, HTTP calls). Use `def` (sync) only for CPU-bound work. Godmode's predict panel can help evaluate async vs. sync tradeoffs.

### 5. Test fixtures are your factory
Invest in `conftest.py` fixtures during the BUILD phase. Good fixtures make every subsequent test faster to write. Godmode's test skill will generate fixtures when it detects shared setup patterns.
