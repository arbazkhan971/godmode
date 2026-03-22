# Pytest Mastery Guide

Comprehensive reference for Python testing with pytest, covering fixtures, parametrization, mocking, async testing, and the plugin ecosystem.

---

## Table of Contents

1. [Configuration](#configuration)
2. [Fixtures](#fixtures)
3. [Parametrize](#parametrize)
4. [Markers](#markers)
5. [Mocking](#mocking)
6. [Async Testing](#async-testing)
7. [Database Fixtures](#database-fixtures)
8. [Plugin Ecosystem](#plugin-ecosystem)

---

## Configuration

### pyproject.toml Configuration

```toml
# pyproject.toml
[tool.pytest.ini_options]
# Test discovery
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]

# Output
addopts = [
    "-v",                       # Verbose output
    "--tb=short",               # Short tracebacks
    "--strict-markers",         # Error on unknown markers
    "--strict-config",          # Error on config warnings
    "-ra",                      # Show summary for all except passed
    "--color=yes",
]

# Markers
markers = [
    "slow: marks tests as slow (deselect with '-m \"not slow\"')",
    "integration: integration tests requiring external services",
    "e2e: end-to-end tests",
    "unit: unit tests",
]

# Logging
log_cli = true
log_cli_level = "INFO"
log_cli_format = "%(asctime)s [%(levelname)8s] %(message)s"

# Warnings
filterwarnings = [
    "error",                    # Treat all warnings as errors
    "ignore::DeprecationWarning:some_third_party.*",
]

# Minimum pytest version
minversion = "7.0"

# Async mode for pytest-asyncio
asyncio_mode = "auto"
```

### conftest.py Structure

```
project/
├── pyproject.toml
├── src/
  └── myapp/
  ├── __init__.py
  ├── models.py
  ├── services.py
  └── utils.py
├── tests/
  ├── conftest.py            # Root conftest: shared fixtures, plugins
  ├── unit/
│   │   ├── conftest.py        # Unit-specific fixtures
│   │   ├── test_models.py
│   │   └── test_utils.py
  ├── integration/
│   │   ├── conftest.py        # Integration fixtures (DB, API clients)
│   │   ├── test_services.py
│   │   └── test_api.py
  └── e2e/
  ├── conftest.py        # E2E fixtures (browser, full stack)
  └── test_workflows.py
```

### CLI Usage

```bash
# Run all tests
pytest

# Run specific file/directory
pytest tests/unit/test_models.py
pytest tests/unit/

# Run specific test
pytest tests/unit/test_models.py::test_create_user
pytest tests/unit/test_models.py::TestUser::test_create

# Run by marker
pytest -m slow
pytest -m "not slow"
pytest -m "integration and not e2e"

# Run by keyword expression
pytest -k "test_user and not delete"
pytest -k "TestUser or TestAdmin"

# Parallel execution (pytest-xdist)
pytest -n auto                  # Auto-detect CPU count
pytest -n 4                     # 4 parallel workers

# Stop on first failure
pytest -x                       # Stop after first failure
pytest --maxfail=3              # Stop after 3 failures

# Show local variables in tracebacks
pytest --showlocals

# Coverage
pytest --cov=myapp --cov-report=html --cov-report=term-missing

# Run last failed
pytest --lf                     # Only last failed
pytest --ff                     # Failed first, then rest

# Debugging
pytest --pdb                    # Drop into pdb on failure
pytest --pdbcls=IPython.terminal.debugger:TerminalPdb
pytest -s                       # Don't capture stdout (see print output)
```

---

## Fixtures

### Basic Fixtures

```python
import pytest


@pytest.fixture
def sample_user():
    """Create a sample user dict."""
    return {
        "id": 1,
        "name": "Alice",
        "email": "alice@example.com",
        "role": "admin",
    }


@pytest.fixture
def sample_users(sample_user):
    """Fixtures can depend on other fixtures."""
    return [
        sample_user,
        {"id": 2, "name": "Bob", "email": "bob@example.com", "role": "user"},
        {"id": 3, "name": "Carol", "email": "carol@example.com", "role": "user"},
    ]


def test_user_name(sample_user):
    assert sample_user["name"] == "Alice"


def test_user_count(sample_users):
    assert len(sample_users) == 3
```

### Fixture Scopes

```python
@pytest.fixture(scope="function")       # Default: new for each test function
def per_test_fixture():
    return create_resource()


@pytest.fixture(scope="class")          # Shared across all tests in a class
def per_class_fixture():
    return create_resource()


@pytest.fixture(scope="module")         # Shared across all tests in a module
def per_module_fixture():
    return create_resource()


@pytest.fixture(scope="package")        # Shared across all tests in a package
def per_package_fixture():
    return create_resource()


@pytest.fixture(scope="session")        # Shared across entire test session
def per_session_fixture():
    return create_resource()
```

### Setup and Teardown with yield

```python
@pytest.fixture
def db_connection():
    """Fixture with setup and teardown."""
    # Setup
    conn = database.connect("test_db")
    conn.begin_transaction()

    yield conn  # Provide the fixture value

    # Teardown (always runs, even if test fails)
    conn.rollback()
    conn.close()


@pytest.fixture
def temp_directory(tmp_path):
    """Use built-in tmp_path fixture."""
    test_dir = tmp_path / "test_data"
    test_dir.mkdir()
    (test_dir / "config.json").write_text('{"key": "value"}')
    yield test_dir
    # tmp_path cleanup is automatic


@pytest.fixture(autouse=True)
def reset_environment():
    """Auto-use fixture: runs for every test automatically."""
    original_env = os.environ.copy()
    yield
    os.environ.clear()
    os.environ.update(original_env)
```

### Factory Fixtures

```python
@pytest.fixture
def make_user():
    """Factory fixture for creating users with custom attributes."""
    created_users = []

    def _make_user(name="Test User", email=None, role="user"):
        email = email or f"{name.lower().replace(' ', '.')}@example.com"
        user = User(name=name, email=email, role=role)
        user.save()
        created_users.append(user)
        return user

    yield _make_user

    # Cleanup all created users
    for user in created_users:
        user.delete()


def test_admin_permissions(make_user):
    admin = make_user(name="Admin", role="admin")
    user = make_user(name="Regular")
    assert admin.can_manage(user)
    assert not user.can_manage(admin)
```

### Built-in Fixtures

```python
def test_builtin_fixtures(
    tmp_path,           # pathlib.Path to a unique temp directory
    tmp_path_factory,   # Factory for creating temp directories
    capsys,             # Capture stdout/stderr
    capfd,              # Capture file descriptors 1 and 2
    caplog,             # Capture log output
    monkeypatch,        # Modify objects, dicts, env vars
    request,            # Fixture request object (metadata)
    pytestconfig,       # Access to pytest configuration
    recwarn,            # Record warnings
    doctest_namespace,  # Dict for doctest imports
):
    pass


# capsys example
def test_output(capsys):
    print("hello")
    captured = capsys.readouterr()
    assert captured.out == "hello\n"
    assert captured.err == ""


# caplog example
def test_logging(caplog):
    import logging
    with caplog.at_level(logging.WARNING):
        logging.warning("watch out!")
    assert "watch out!" in caplog.text
    assert len(caplog.records) == 1
    assert caplog.records[0].levelname == "WARNING"


# monkeypatch examples
def test_monkeypatch(monkeypatch):
    # Set environment variable
    monkeypatch.setenv("API_KEY", "test-key")
    assert os.environ["API_KEY"] == "test-key"

    # Delete environment variable
    monkeypatch.delenv("HOME", raising=False)

    # Modify dict
    monkeypatch.setitem(config, "debug", True)

    # Replace attribute
    monkeypatch.setattr(requests, "get", mock_get)

    # Change directory
    monkeypatch.chdir(tmp_path)
```

### Request Fixture (Metadata)

```python
@pytest.fixture
def data_source(request):
    """Access test metadata from the fixture."""
    # Access marker data
    marker = request.node.get_closest_marker("data_source")
    source_type = marker.args[0] if marker else "memory"

    if source_type == "memory":
        return InMemoryDataSource()
    elif source_type == "sqlite":
        return SQLiteDataSource(":memory:")
    elif source_type == "postgres":
        return PostgresDataSource(os.environ["TEST_DB_URL"])


@pytest.mark.data_source("sqlite")
def test_with_sqlite(data_source):
    data_source.store("key", "value")
    assert data_source.get("key") == "value"
```

---

## Parametrize

### Basic Parametrize

```python
@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
    (0, 0),
    (-1, -2),
])
def test_double(input, expected):
    assert double(input) == expected


# With test IDs
@pytest.mark.parametrize("input,expected", [
    pytest.param(1, 2, id="positive"),
    pytest.param(0, 0, id="zero"),
    pytest.param(-1, -2, id="negative"),
])
def test_double_with_ids(input, expected):
    assert double(input) == expected
```

### Multiple Parametrize (Cartesian Product)

```python
@pytest.mark.parametrize("x", [0, 1, 2])
@pytest.mark.parametrize("y", [10, 20])
def test_addition(x, y):
    """Runs 6 tests: (0,10), (0,20), (1,10), (1,20), (2,10), (2,20)"""
    assert add(x, y) == x + y
```

### Parametrize with Marks

```python
@pytest.mark.parametrize("input,expected", [
    ("hello", "HELLO"),
    ("world", "WORLD"),
    pytest.param("", "", marks=pytest.mark.xfail(reason="empty string edge case")),
    pytest.param(None, None, marks=pytest.mark.skip(reason="not implemented")),
    pytest.param("a" * 10000, "A" * 10000, marks=pytest.mark.slow),
])
def test_uppercase(input, expected):
    assert to_upper(input) == expected
```

### Parametrize Classes

```python
@pytest.mark.parametrize("backend", ["sqlite", "postgres", "mysql"])
class TestDatabaseOperations:
    def test_insert(self, backend, db_factory):
        db = db_factory(backend)
        db.insert({"name": "test"})
        assert db.count() == 1

    def test_query(self, backend, db_factory):
        db = db_factory(backend)
        db.insert({"name": "test"})
        results = db.query({"name": "test"})
        assert len(results) == 1
```

### Indirect Parametrize (Through Fixtures)

```python
@pytest.fixture
def user(request):
    """Fixture that receives parametrized values."""
    role = request.param
    return create_user(role=role)


@pytest.mark.parametrize("user", ["admin", "editor", "viewer"], indirect=True)
def test_user_permissions(user):
    assert user.role in ["admin", "editor", "viewer"]
    assert user.has_read_access()
```

### Dynamic Parametrize

```python
def load_test_cases():
    """Load test cases from a JSON file."""
    import json
    with open("tests/data/test_cases.json") as f:
        return json.load(f)


@pytest.mark.parametrize(
    "input_data,expected",
    [(tc["input"], tc["expected"]) for tc in load_test_cases()],
    ids=[tc["name"] for tc in load_test_cases()],
)
def test_from_file(input_data, expected):
    assert process(input_data) == expected
```

---

## Markers

### Built-in Markers

```python
# Skip a test unconditionally
@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass


# Skip conditionally
@pytest.mark.skipif(
    sys.platform == "win32",
    reason="Unix-only feature"
)
def test_unix_permissions():
    pass


# Expected failure
@pytest.mark.xfail(reason="Known bug #123")
def test_known_bug():
    assert broken_function() == "expected"


# Expected failure with condition
@pytest.mark.xfail(
    sys.version_info < (3, 11),
    reason="Requires Python 3.11+ feature",
    strict=True,    # Fail if test unexpectedly passes
)
def test_new_feature():
    pass


# Parametrize (covered above)
@pytest.mark.parametrize("x", [1, 2, 3])
def test_param(x):
    pass


# Filter warnings
@pytest.mark.filterwarnings("ignore::DeprecationWarning")
def test_with_deprecated_api():
    pass


# Set timeout (pytest-timeout)
@pytest.mark.timeout(10)
def test_slow_operation():
    pass


# Run in a specific order (pytest-order)
@pytest.mark.order(1)
def test_setup_first():
    pass
```

### Custom Markers

```python
# conftest.py
import pytest


def pytest_configure(config):
    """Register custom markers."""
    config.addinivalue_line("markers", "slow: marks test as slow")
    config.addinivalue_line("markers", "integration: integration tests")
    config.addinivalue_line("markers", "gpu: requires GPU")


# Usage
@pytest.mark.slow
def test_large_dataset():
    pass


@pytest.mark.integration
def test_api_endpoint():
    pass


@pytest.mark.gpu
def test_model_training():
    pass
```

```bash
# Run by marker
pytest -m slow
pytest -m "not slow"
pytest -m "integration and not gpu"
pytest -m "slow or integration"
```

### Marker-Based Fixture Selection

```python
# conftest.py
@pytest.fixture(autouse=True)
def skip_by_platform(request):
    """Skip tests based on platform markers."""
    if request.node.get_closest_marker("linux_only"):
        if sys.platform != "linux":
            pytest.skip("Linux only")
    if request.node.get_closest_marker("mac_only"):
        if sys.platform != "darwin":
            pytest.skip("macOS only")
```

---

## Mocking

### unittest.mock Basics

```python
from unittest.mock import Mock, MagicMock, patch, AsyncMock


# Create a mock
mock = Mock()
mock.some_method.return_value = 42
assert mock.some_method("arg") == 42
mock.some_method.assert_called_once_with("arg")


# MagicMock supports magic methods
magic = MagicMock()
magic.__len__.return_value = 5
assert len(magic) == 5
magic.__getitem__.return_value = "item"
assert magic[0] == "item"


# Spec (restrict to real interface)
mock = Mock(spec=MyClass)
mock.real_method()      # OK
mock.fake_method()      # AttributeError
```

### Patch Decorators and Context Managers

```python
# Patch as decorator
@patch("myapp.services.requests.get")
def test_fetch_data(mock_get):
    mock_get.return_value.json.return_value = {"data": "test"}
    mock_get.return_value.status_code = 200

    result = fetch_data("http://api.example.com/data")

    assert result == {"data": "test"}
    mock_get.assert_called_once_with("http://api.example.com/data", timeout=30)


# Patch as context manager
def test_fetch_data_context():
    with patch("myapp.services.requests.get") as mock_get:
        mock_get.return_value.json.return_value = {"data": "test"}
        result = fetch_data("http://api.example.com/data")
        assert result == {"data": "test"}


# Multiple patches (applied bottom-up as decorator args)
@patch("myapp.services.cache.get")
@patch("myapp.services.db.query")
@patch("myapp.services.requests.get")
def test_with_multiple_mocks(mock_requests, mock_db, mock_cache):
    # Note: order is reversed from decorator order
    mock_cache.return_value = None
    mock_db.return_value = []
    mock_requests.return_value.json.return_value = {"data": "api"}
    # ...


# patch.object for specific instances
@patch.object(UserService, "send_email")
def test_registration(mock_send_email):
    service = UserService()
    service.register("test@example.com")
    mock_send_email.assert_called_once()


# patch.dict for dictionaries
@patch.dict(os.environ, {"API_KEY": "test-key", "DEBUG": "true"})
def test_with_env():
    assert os.environ["API_KEY"] == "test-key"
```

### Side Effects

```python
# Raise exception
mock = Mock()
mock.side_effect = ValueError("invalid input")
with pytest.raises(ValueError, match="invalid input"):
    mock()

# Return different values on successive calls
mock = Mock()
mock.side_effect = [1, 2, 3]
assert mock() == 1
assert mock() == 2
assert mock() == 3

# Custom function as side effect
def custom_side_effect(url, **kwargs):
    if "users" in url:
        return MockResponse({"users": []}, 200)
    elif "posts" in url:
        return MockResponse({"posts": []}, 200)
    raise ValueError(f"Unexpected URL: {url}")

mock = Mock(side_effect=custom_side_effect)
```

### pytest-mock (mocker Fixture)

```python
# pip install pytest-mock

def test_with_mocker(mocker):
    """pytest-mock provides a cleaner API."""
    # Patch (auto-cleanup, no need for decorators)
    mock_get = mocker.patch("myapp.services.requests.get")
    mock_get.return_value.json.return_value = {"data": "test"}

    # Spy (call through to real implementation)
    spy = mocker.spy(MyClass, "method")
    obj = MyClass()
    result = obj.method()       # Real method runs
    spy.assert_called_once()    # But we can assert on calls

    # Stub (replace with a new Mock)
    stub = mocker.stub(name="my_stub")
    stub.return_value = "stubbed"

    # patch.object
    mocker.patch.object(UserService, "send_email")

    # patch.dict
    mocker.patch.dict(os.environ, {"KEY": "value"})

    # Access mock call args
    mock_get.assert_called_once()
    args, kwargs = mock_get.call_args
    assert kwargs.get("timeout") == 30


def test_mock_property(mocker):
    """Mock a property."""
    mocker.patch.object(
        type(MyClass),
        "my_property",
        new_callable=mocker.PropertyMock,
        return_value="mocked_value",
    )
    obj = MyClass()
    assert obj.my_property == "mocked_value"
```

### Assertion Patterns

```python
from unittest.mock import call, ANY

mock = Mock()
mock(1, 2, key="value")
mock(3, 4)

# Assert specific calls
mock.assert_any_call(1, 2, key="value")
mock.assert_called_with(3, 4)           # Last call

# Assert call count
assert mock.call_count == 2

# Assert call order
mock.assert_has_calls([
    call(1, 2, key="value"),
    call(3, 4),
], any_order=False)

# Use ANY for flexible matching
mock.assert_called_with(ANY, 4)

# Reset mock
mock.reset_mock()
assert mock.call_count == 0

# Assert not called
mock.assert_not_called()
```

---

## Async Testing

### pytest-asyncio

```python
# pip install pytest-asyncio

import pytest
import asyncio


# With asyncio_mode = "auto" in config, no decorator needed
async def test_async_function():
    result = await async_fetch("http://api.example.com")
    assert result["status"] == "ok"


# Explicit marker (if not using auto mode)
@pytest.mark.asyncio
async def test_async_explicit():
    result = await async_fetch("http://api.example.com")
    assert result["status"] == "ok"


# Async fixtures
@pytest.fixture
async def async_client():
    client = AsyncHTTPClient()
    await client.connect()
    yield client
    await client.disconnect()


async def test_with_async_client(async_client):
    response = await async_client.get("/api/health")
    assert response.status == 200
```

### Async Fixture Scopes

```python
@pytest.fixture(scope="session")
async def db_pool():
    """Session-scoped async fixture."""
    pool = await asyncpg.create_pool(
        "postgresql://localhost/test_db",
        min_size=2,
        max_size=10,
    )
    yield pool
    await pool.close()


@pytest.fixture
async def db_connection(db_pool):
    """Per-test connection from the pool."""
    async with db_pool.acquire() as conn:
        tr = conn.transaction()
        await tr.start()
        yield conn
        await tr.rollback()
```

### Mocking Async Code

```python
from unittest.mock import AsyncMock, patch


async def test_mock_async_function():
    mock_fetch = AsyncMock(return_value={"data": "test"})

    with patch("myapp.client.fetch", mock_fetch):
        result = await myapp.client.fetch("/api/data")

    assert result == {"data": "test"}
    mock_fetch.assert_awaited_once_with("/api/data")


async def test_mock_async_context_manager(mocker):
    mock_session = AsyncMock()
    mock_session.__aenter__.return_value = mock_session
    mock_session.__aexit__.return_value = False
    mock_session.get.return_value.json = AsyncMock(
        return_value={"data": "test"}
    )

    mocker.patch("aiohttp.ClientSession", return_value=mock_session)

    result = await fetch_data("/api/data")
    assert result == {"data": "test"}


# AsyncMock assertions
mock = AsyncMock()
await mock("arg1", key="value")

mock.assert_awaited_once()
mock.assert_awaited_with("arg1", key="value")
mock.assert_awaited_once_with("arg1", key="value")
assert mock.await_count == 1
```

### Testing Async Generators and Iterators

```python
async def test_async_generator():
    results = []
    async for item in async_data_stream():
        results.append(item)
    assert len(results) == 10


async def test_async_timeout():
    with pytest.raises(asyncio.TimeoutError):
        await asyncio.wait_for(
            slow_async_function(),
            timeout=1.0,
        )


async def test_gather_concurrent():
    results = await asyncio.gather(
        fetch_users(),
        fetch_posts(),
        fetch_comments(),
    )
    users, posts, comments = results
    assert len(users) > 0
```

### anyio Backend Testing

```python
# pip install anyio pytest-anyio
import anyio
import pytest


@pytest.mark.anyio
async def test_with_anyio():
    """Runs with both asyncio and trio backends."""
    async with anyio.create_task_group() as tg:
        tg.start_soon(some_async_task)


# Parametrize backends
@pytest.fixture(params=["asyncio", "trio"])
def anyio_backend(request):
    return request.param
```

---

## Database Fixtures

### SQLAlchemy Fixtures

```python
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from myapp.models import Base


@pytest.fixture(scope="session")
def engine():
    """Create a test database engine."""
    engine = create_engine(
        "sqlite:///test.db",
        echo=False,
    )
    Base.metadata.create_all(engine)
    yield engine
    Base.metadata.drop_all(engine)
    engine.dispose()


@pytest.fixture(scope="session")
def session_factory(engine):
    return sessionmaker(bind=engine)


@pytest.fixture
def db_session(session_factory) -> Session:
    """Per-test database session with automatic rollback."""
    session = session_factory()
    session.begin_nested()      # SAVEPOINT

    yield session

    session.rollback()          # Rollback to SAVEPOINT
    session.close()


@pytest.fixture
def user_factory(db_session):
    """Factory for creating test users in the database."""
    def _create_user(name="Test User", email=None):
        from myapp.models import User
        email = email or f"{name.lower().replace(' ', '.')}@test.com"
        user = User(name=name, email=email)
        db_session.add(user)
        db_session.flush()      # Assign ID without committing
        return user
    return _create_user


def test_create_user(db_session, user_factory):
    user = user_factory(name="Alice")
    assert user.id is not None
    assert user.name == "Alice"

    found = db_session.query(User).filter_by(name="Alice").first()
    assert found is not None
```

### Async SQLAlchemy (2.0+)

```python
import pytest
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
    async_sessionmaker,
)
from myapp.models import Base


@pytest.fixture(scope="session")
async def async_engine():
    engine = create_async_engine("sqlite+aiosqlite:///test.db")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()


@pytest.fixture
async def async_session(async_engine) -> AsyncSession:
    async_session_factory = async_sessionmaker(
        async_engine, class_=AsyncSession, expire_on_commit=False,
    )
    async with async_session_factory() as session:
        async with session.begin():
            yield session
        await session.rollback()
```

### PostgreSQL with Docker (pytest-docker)

```python
# conftest.py
import pytest
import docker


@pytest.fixture(scope="session")
def postgres_container():
    """Start a PostgreSQL container for integration tests."""
    client = docker.from_env()
    container = client.containers.run(
        "postgres:16",
        detach=True,
        ports={"5432/tcp": 5433},
        environment={
            "POSTGRES_DB": "test_db",
            "POSTGRES_USER": "test_user",
            "POSTGRES_PASSWORD": "test_pass",
        },
        remove=True,
    )

    # Wait for PostgreSQL to be ready
    import time
    for _ in range(30):
        try:
            import psycopg2
            conn = psycopg2.connect(
                host="localhost", port=5433,
                dbname="test_db", user="test_user", password="test_pass",
            )
            conn.close()
            break
        except Exception:
            time.sleep(1)
    else:
        container.stop()
        pytest.fail("PostgreSQL did not start in time")

    yield "postgresql://test_user:test_pass@localhost:5433/test_db"

    container.stop()
```

### Factory Boy Integration

```python
# pip install factory-boy
import factory
from myapp.models import User, Post


class UserFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = User
        sqlalchemy_session_persistence = "flush"

    name = factory.Faker("name")
    email = factory.LazyAttribute(lambda o: f"{o.name.lower().replace(' ', '.')}@example.com")
    role = "user"
    is_active = True


class AdminFactory(UserFactory):
    role = "admin"


class PostFactory(factory.alchemy.SQLAlchemyModelFactory):
    class Meta:
        model = Post
        sqlalchemy_session_persistence = "flush"

    title = factory.Faker("sentence")
    body = factory.Faker("paragraph")
    author = factory.SubFactory(UserFactory)


@pytest.fixture(autouse=True)
def set_factory_session(db_session):
    """Bind factories to the test session."""
    UserFactory._meta.sqlalchemy_session = db_session
    PostFactory._meta.sqlalchemy_session = db_session


def test_user_posts(db_session):
    user = UserFactory()
    posts = PostFactory.create_batch(5, author=user)
    assert len(user.posts) == 5
```

---

## Plugin Ecosystem

### pytest-cov (Coverage)

```bash
pip install pytest-cov

# Basic coverage
pytest --cov=myapp

# With report formats
pytest --cov=myapp --cov-report=term-missing --cov-report=html --cov-report=xml

# Fail below threshold
pytest --cov=myapp --cov-fail-under=80

# Branch coverage
pytest --cov=myapp --cov-branch
```

```toml
# pyproject.toml
[tool.coverage.run]
source = ["myapp"]
branch = true
omit = [
    "*/tests/*",
    "*/migrations/*",
    "*/__main__.py",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if TYPE_CHECKING:",
    "raise NotImplementedError",
    "@abstractmethod",
]
fail_under = 80
show_missing = true

[tool.coverage.html]
directory = "htmlcov"
```

### pytest-xdist (Parallel Execution)

```bash
pip install pytest-xdist

# Auto-detect CPU count
pytest -n auto

# Fixed worker count
pytest -n 4

# Distribute by file (default)
pytest -n 4 --dist=loadfile

# Distribute by test
pytest -n 4 --dist=load

# Distribute by group
pytest -n 4 --dist=loadgroup

# Each worker gets unique ID via worker_id fixture
```

```python
@pytest.fixture
def unique_db_name(worker_id):
    """Create unique database per worker."""
    if worker_id == "master":
        return "test_db"
    return f"test_db_{worker_id}"


@pytest.fixture
def unique_port(worker_id):
    """Assign unique port per worker."""
    if worker_id == "master":
        return 8000
    worker_num = int(worker_id.replace("gw", ""))
    return 8000 + worker_num + 1
```

### pytest-timeout

```bash
pip install pytest-timeout
```

```python
# Per-test timeout
@pytest.mark.timeout(10)
def test_with_timeout():
    pass

# Global timeout in config
# [tool.pytest.ini_options]
# timeout = 30
```

### pytest-randomly (Randomize Test Order)

```bash
pip install pytest-randomly

# Run with random seed
pytest -p randomly

# Reproduce specific order
pytest -p randomly --randomly-seed=12345

# Disable randomization
pytest -p no:randomly
```

### pytest-benchmark

```bash
pip install pytest-benchmark
```

```python
def test_sort_performance(benchmark):
    data = list(range(10000, 0, -1))
    result = benchmark(sorted, data)
    assert result == list(range(1, 10001))


def test_complex_benchmark(benchmark):
    # Setup/teardown per round
    def setup():
        return (generate_large_dataset(),), {}

    benchmark.pedantic(
        process_data,
        setup=setup,
        rounds=100,
        warmup_rounds=10,
    )
```

### pytest-freezegun (Time Freezing)

```python
# pip install pytest-freezegun
from freezegun import freeze_time


@freeze_time("2025-01-15 12:00:00")
def test_time_dependent():
    from datetime import datetime
    assert datetime.now().year == 2025
    assert datetime.now().month == 1


# As fixture
@pytest.fixture
def frozen_time():
    with freeze_time("2025-06-15"):
        yield


def test_with_frozen_time(frozen_time):
    from datetime import date
    assert date.today() == date(2025, 6, 15)
```

### pytest-httpx (HTTPX Mocking)

```python
# pip install pytest-httpx
import httpx


async def test_mock_httpx(httpx_mock):
    httpx_mock.add_response(
        url="https://api.example.com/users",
        json={"users": [{"id": 1, "name": "Alice"}]},
    )

    async with httpx.AsyncClient() as client:
        response = await client.get("https://api.example.com/users")

    assert response.json()["users"][0]["name"] == "Alice"


async def test_mock_httpx_error(httpx_mock):
    httpx_mock.add_exception(httpx.ConnectTimeout("Connection timed out"))

    with pytest.raises(httpx.ConnectTimeout):
        async with httpx.AsyncClient() as client:
            await client.get("https://api.example.com/users")
```

### Writing Custom Plugins

```python
# conftest.py or as a package
import pytest
import time


def pytest_addoption(parser):
    """Add custom CLI options."""
    parser.addoption(
        "--runslow",
        action="store_true",
        default=False,
        help="Run slow tests",
    )


def pytest_collection_modifyitems(config, items):
    """Modify collected tests."""
    if not config.getoption("--runslow"):
        skip_slow = pytest.mark.skip(reason="need --runslow option to run")
        for item in items:
            if "slow" in item.keywords:
                item.add_marker(skip_slow)


@pytest.hookimpl(tryfirst=True, hookwrapper=True)
def pytest_runtest_makereport(item, call):
    """Add test duration to report."""
    outcome = yield
    rep = outcome.get_result()
    if rep.when == "call":
        rep.duration = call.duration


def pytest_terminal_summary(terminalreporter, exitstatus, config):
    """Add custom summary to terminal output."""
    reports = terminalreporter.stats.get("passed", [])
    if reports:
        slow_tests = sorted(reports, key=lambda r: r.duration, reverse=True)[:5]
        terminalreporter.write_sep("=", "Top 5 slowest tests")
        for report in slow_tests:
            terminalreporter.write_line(
                f"  {report.duration:.3f}s  {report.nodeid}"
            )
```

---

## Quick Reference Card

```
Command                          Description
pytest                           Run all tests
pytest -x                        Stop on first failure
pytest -k "pattern"              Filter by name pattern
pytest -m marker                 Filter by marker
pytest -n auto                   Parallel execution
pytest --lf                      Rerun last failed
pytest --ff                      Failed first
pytest -s                        Show print output
pytest --pdb                     Debug on failure
pytest --cov=pkg                 Coverage report
pytest --durations=10            Show 10 slowest tests
pytest -v                        Verbose output
pytest --co                      Collect only (dry run)
pytest --fixtures                Show available fixtures

Fixture Scopes: function < class < module < package < session
Marker Logic:   -m "a and b"  |  -m "a or b"  |  -m "not a"
```
