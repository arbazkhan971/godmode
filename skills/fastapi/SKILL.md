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
│   ├── __init__.py
│   ├── order.py            # SQLAlchemy models
│   └── customer.py
├── schemas/
│   ├── __init__.py
│   ├── order.py            # Pydantic schemas (request/response)
│   └── customer.py
├── services/
│   ├── __init__.py
│   ├── order_service.py    # Business logic
│   └── payment_service.py
├── repositories/
│   ├── __init__.py
│   └── order_repo.py       # Data access layer
├── core/
│   ├── __init__.py
│   ├── security.py         # JWT, password hashing
│   ├── exceptions.py       # Custom exceptions + handlers
│   └── middleware.py        # Custom middleware
├── db/
│   ├── __init__.py
│   ├── session.py          # Async engine + session factory
│   └── migrations/         # Alembic migrations
└── tests/
    ├── conftest.py          # Fixtures (client, DB, factories)
    ├── test_orders.py
    └── test_auth.py
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

# Enum for type safety
class OrderStatus(str, Enum):
    PENDING = "pending"
    CONFIRMED = "confirmed"
    SHIPPED = "shipped"
    DELIVERED = "delivered"
    CANCELLED = "cancelled"

# Base schema with shared fields
class OrderBase(BaseModel):
    notes: str | None = Field(None, max_length=500, examples=["Handle with care"])

# Create schema (request body)
class OrderCreate(OrderBase):
    customer_id: UUID
    items: list["OrderItemCreate"] = Field(..., min_length=1, max_length=100)

    @field_validator("items")
    @classmethod
    def validate_unique_products(cls, v: list["OrderItemCreate"]) -> list["OrderItemCreate"]:
        product_ids = [item.product_id for item in v]
        if len(product_ids) != len(set(product_ids)):
            raise ValueError("Duplicate products in order")
        return v

# Update schema (partial updates)
class OrderUpdate(BaseModel):
    notes: str | None = None
    status: OrderStatus | None = None

    @model_validator(mode="before")
    @classmethod
    def check_at_least_one_field(cls, data: dict) -> dict:
        if not any(v is not None for v in data.values()):
            raise ValueError("At least one field must be provided")
        return data

# Response schema
class OrderResponse(OrderBase):
    id: UUID
    status: OrderStatus
    total: Decimal = Field(..., decimal_places=2)
    customer: "CustomerSummary"
    items: list["OrderItemResponse"]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

# Paginated response
class PaginatedResponse[T](BaseModel):
    data: list[T]
    total: int
    page: int
    per_page: int
    pages: int

    @property
    def has_next(self) -> bool:
        return self.page < self.pages

# Item schemas
class OrderItemCreate(BaseModel):
    product_id: UUID
    quantity: int = Field(..., gt=0, le=1000)

class OrderItemResponse(BaseModel):
    id: UUID
    product_id: UUID
    product_name: str
    quantity: int
    unit_price: Decimal
    subtotal: Decimal

    model_config = ConfigDict(from_attributes=True)

# Lightweight summary for nested responses
class CustomerSummary(BaseModel):
    id: UUID
    name: str
    email: EmailStr

    model_config = ConfigDict(from_attributes=True)
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
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.db.session import async_session_factory

# Database session dependency
async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise

# Type alias for cleaner signatures
DbSession = Annotated[AsyncSession, Depends(get_db)]

# Auth dependency
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: DbSession,
) -> User:
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    except JWTError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)

    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    return user

CurrentUser = Annotated[User, Depends(get_current_user)]

# Role-based access dependency
def require_role(*roles: str):
    async def check_role(user: CurrentUser) -> User:
        if user.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )
        return user
    return check_role

AdminUser = Annotated[User, Depends(require_role("admin"))]

# Service dependency with repository injection
class OrderService:
    def __init__(self, db: DbSession) -> None:
        self.db = db
        self.repo = OrderRepository(db)

    async def create_order(self, data: OrderCreate, user: User) -> Order:
        order = Order(**data.model_dump(), customer_id=user.customer_id)
        self.db.add(order)
        await self.db.flush()
        return order

    async def get_orders(self, user: User, page: int, per_page: int) -> PaginatedResponse[OrderResponse]:
        return await self.repo.list_paginated(
            filters={"customer_id": user.customer_id},
            page=page,
            per_page=per_page,
        )

# Dependency factory
async def get_order_service(db: DbSession) -> OrderService:
    return OrderService(db)

OrderServiceDep = Annotated[OrderService, Depends(get_order_service)]

# Usage in endpoint
@router.get("/orders", response_model=PaginatedResponse[OrderResponse])
async def list_orders(
    service: OrderServiceDep,
    user: CurrentUser,
    page: int = Query(1, ge=1),
    per_page: int = Query(25, ge=1, le=100),
) -> PaginatedResponse[OrderResponse]:
    return await service.get_orders(user, page, per_page)
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
from sqlalchemy import ForeignKey, String, Numeric, Index
from datetime import datetime
from uuid import UUID, uuid4

# Engine setup
engine = create_async_engine(
    settings.database_url,  # postgresql+asyncpg://...
    pool_size=20,
    max_overflow=10,
    pool_timeout=30,
    pool_recycle=1800,
    echo=settings.debug,
)

async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

# Base model
class Base(DeclarativeBase):
    pass

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        default=datetime.utcnow, onupdate=datetime.utcnow
    )

# Model definition (SQLAlchemy 2.0 declarative style)
class Order(Base, TimestampMixin):
    __tablename__ = "orders"
    __table_args__ = (
        Index("idx_orders_customer_status", "customer_id", "status"),
    )

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    customer_id: Mapped[UUID] = mapped_column(ForeignKey("customers.id"), index=True)
    status: Mapped[str] = mapped_column(String(20), default="pending")
    total_cents: Mapped[int] = mapped_column(default=0)
    notes: Mapped[str | None] = mapped_column(String(500))

    # Relationships
    customer: Mapped["Customer"] = relationship(back_populates="orders", lazy="selectin")
    items: Mapped[list["OrderItem"]] = relationship(
        back_populates="order", cascade="all, delete-orphan", lazy="selectin"
    )

# Repository pattern for data access
class OrderRepository:
    def __init__(self, session: AsyncSession) -> None:
        self.session = session

    async def get_by_id(self, order_id: UUID) -> Order | None:
        return await self.session.get(Order, order_id)

    async def list_paginated(
        self,
        filters: dict,
        page: int = 1,
        per_page: int = 25,
    ) -> PaginatedResponse[OrderResponse]:
        query = select(Order)

        # Apply filters dynamically
        for key, value in filters.items():
            if value is not None:
                query = query.where(getattr(Order, key) == value)

        # Count total
        count_query = select(func.count()).select_from(query.subquery())
        total = (await self.session.execute(count_query)).scalar_one()

        # Paginate
        query = query.offset((page - 1) * per_page).limit(per_page)
        query = query.order_by(Order.created_at.desc())

        result = await self.session.execute(query)
        orders = result.scalars().all()

        return PaginatedResponse(
            data=[OrderResponse.model_validate(o) for o in orders],
            total=total,
            page=page,
            per_page=per_page,
            pages=(total + per_page - 1) // per_page,
        )

    async def create(self, data: OrderCreate) -> Order:
        order = Order(**data.model_dump(exclude={"items"}))
        order.items = [OrderItem(**item.model_dump()) for item in data.items]
        self.session.add(order)
        await self.session.flush()
        return order

    async def bulk_update_status(self, ids: list[UUID], status: str) -> int:
        result = await self.session.execute(
            update(Order).where(Order.id.in_(ids)).values(status=status)
        )
        return result.rowcount
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
    service: OrderServiceDep,
    user: CurrentUser,
    background_tasks: BackgroundTasks,
) -> OrderResponse:
    order = await service.create_order(data, user)

    # Fire-and-forget tasks
    background_tasks.add_task(send_confirmation_email, order.id)
    background_tasks.add_task(notify_warehouse, order.id)
    background_tasks.add_task(update_analytics, "order_created", order.id)

    return OrderResponse.model_validate(order)

# For heavy tasks, use Celery or ARQ
from arq import create_pool
from arq.connections import RedisSettings

# ARQ worker tasks
async def process_payment(ctx: dict, order_id: str) -> dict:
    """Process payment in background with retry."""
    db = ctx["db"]
    payment_service = ctx["payment_service"]

    order = await db.get(Order, order_id)
    result = await payment_service.charge(order.total_cents)

    if result.success:
        order.status = "confirmed"
        order.payment_id = result.transaction_id
        await db.commit()
        return {"status": "success", "transaction_id": result.transaction_id}

    raise Exception(f"Payment failed: {result.error}")

# ARQ worker settings
class WorkerSettings:
    functions = [process_payment]
    redis_settings = RedisSettings.from_dsn(settings.redis_url)
    max_tries = 3
    retry_delay = 10  # seconds

# WebSocket endpoint
class ConnectionManager:
    def __init__(self) -> None:
        self.active_connections: dict[str, list[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, channel: str) -> None:
        await websocket.accept()
        self.active_connections.setdefault(channel, []).append(websocket)

    async def disconnect(self, websocket: WebSocket, channel: str) -> None:
        self.active_connections.get(channel, []).remove(websocket)

    async def broadcast(self, channel: str, message: dict) -> None:
        for connection in self.active_connections.get(channel, []):
            try:
                await connection.send_json(message)
            except Exception:
                await self.disconnect(connection, channel)

manager = ConnectionManager()

@router.websocket("/ws/orders/{customer_id}")
async def order_updates(websocket: WebSocket, customer_id: str):
    await manager.connect(websocket, f"orders:{customer_id}")
    try:
        while True:
            data = await websocket.receive_text()
            # Handle incoming messages (ping, subscribe to specific orders)
    except WebSocketDisconnect:
        await manager.disconnect(websocket, f"orders:{customer_id}")

# Broadcast from service layer
async def notify_order_update(order: Order) -> None:
    await manager.broadcast(f"orders:{order.customer_id}", {
        "type": "order_updated",
        "order_id": str(order.id),
        "status": order.status,
        "updated_at": order.updated_at.isoformat(),
    })
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
- WebSocket connections must be authenticated — check JWT in the initial handshake
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
from app.db.session import Base, get_db
from app.core.security import create_access_token

# Test database
TEST_DATABASE_URL = "postgresql+asyncpg://test:test@localhost:5432/test_db"

@pytest.fixture(scope="session")
def anyio_backend():
    return "asyncio"

@pytest.fixture(scope="session")
async def engine():
    engine = create_async_engine(TEST_DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield engine
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

@pytest.fixture
async def db_session(engine) -> AsyncGenerator[AsyncSession, None]:
    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        yield session
        await session.rollback()

@pytest.fixture
async def client(db_session: AsyncSession) -> AsyncGenerator[AsyncClient, None]:
    app = create_app()

    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test",
    ) as ac:
        yield ac

@pytest.fixture
def auth_headers(user: User) -> dict[str, str]:
    token = create_access_token(data={"sub": str(user.id)})
    return {"Authorization": f"Bearer {token}"}

@pytest.fixture
async def user(db_session: AsyncSession) -> User:
    user = User(email="test@example.com", name="Test User", role="user")
    db_session.add(user)
    await db_session.flush()
    return user

@pytest.fixture
async def order(db_session: AsyncSession, user: User) -> Order:
    order = Order(customer_id=user.customer_id, status="pending", total_cents=5000)
    db_session.add(order)
    await db_session.flush()
    return order

# test_orders.py — Endpoint tests
import pytest
from httpx import AsyncClient

pytestmark = pytest.mark.anyio

async def test_list_orders_returns_paginated_results(
    client: AsyncClient,
    auth_headers: dict,
    order: Order,
):
    response = await client.get("/api/v1/orders", headers=auth_headers)

    assert response.status_code == 200
    data = response.json()
    assert data["total"] >= 1
    assert data["page"] == 1
    assert len(data["data"]) >= 1
    assert data["data"][0]["id"] == str(order.id)

async def test_create_order_returns_201(
    client: AsyncClient,
    auth_headers: dict,
    product: Product,
):
    payload = {
        "items": [{"product_id": str(product.id), "quantity": 2}],
        "notes": "Test order",
    }

    response = await client.post("/api/v1/orders", json=payload, headers=auth_headers)

    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "pending"
    assert data["notes"] == "Test order"

async def test_create_order_validates_empty_items(
    client: AsyncClient,
    auth_headers: dict,
):
    response = await client.post(
        "/api/v1/orders",
        json={"items": []},
        headers=auth_headers,
    )

    assert response.status_code == 422  # Validation error

async def test_get_order_returns_404_for_nonexistent(
    client: AsyncClient,
    auth_headers: dict,
):
    response = await client.get(
        "/api/v1/orders/00000000-0000-0000-0000-000000000000",
        headers=auth_headers,
    )

    assert response.status_code == 404

async def test_unauthenticated_request_returns_401(client: AsyncClient):
    response = await client.get("/api/v1/orders")
    assert response.status_code == 401

# test_services.py — Unit tests
async def test_order_service_creates_order(db_session: AsyncSession, user: User):
    service = OrderService(db_session)
    data = OrderCreate(
        customer_id=user.customer_id,
        items=[OrderItemCreate(product_id=product_id, quantity=2)],
    )

    order = await service.create_order(data, user)

    assert order.id is not None
    assert order.status == "pending"
    assert len(order.items) == 1

# test_schemas.py — Pydantic validation tests
def test_order_create_rejects_duplicate_products():
    with pytest.raises(ValueError, match="Duplicate products"):
        OrderCreate(
            customer_id=uuid4(),
            items=[
                OrderItemCreate(product_id=product_id, quantity=1),
                OrderItemCreate(product_id=product_id, quantity=2),  # Same product
            ],
        )

def test_order_update_requires_at_least_one_field():
    with pytest.raises(ValueError, match="At least one field"):
        OrderUpdate()
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
- pytest-asyncio / anyio: Async test execution
- HTTPX AsyncClient: HTTP testing without running server
- factory-boy: Test data factories (FactoryBoy with async support)
- Faker: Realistic test data generation
- respx: Mock external HTTP requests
- pytest-cov: Code coverage
- TestContainers: Real PostgreSQL in tests (CI)
- dependency_overrides: Swap dependencies for testing
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
│  CORS configured                     │  PASS    │  Per environment     │
│  OpenAPI docs generated              │  PASS    │  Auto from schemas   │
│  Background tasks for heavy work     │  PASS    │  No sync blocking    │
│  Structured logging configured       │  PASS    │  JSON in production  │
└──────────────────────────────────────┴──────────┴──────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
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

## Example Usage

### Building a FastAPI Service
```
User: /godmode:fastapi Build an inventory management API

FastAPI: Assessing requirements...

FASTAPI ASSESSMENT:
Project: Inventory Management API
FastAPI: 0.115.x
Python: 3.12
Database: PostgreSQL (asyncpg)
ORM: SQLAlchemy 2.0 async
Auth: JWT bearer tokens

Creating Pydantic schemas: Product, Warehouse, StockLevel...
Setting up async SQLAlchemy with repository pattern...
Configuring JWT authentication dependencies...
Creating async endpoints with DI...
Writing pytest + HTTPX test suite...

All 15 checks PASS.
```

### Designing Pydantic Models
```
User: /godmode:fastapi Design schemas for a multi-tenant SaaS API

FastAPI: Designing Pydantic schemas...

SCHEMAS:
- TenantCreate / TenantResponse (with settings JSON field)
- UserCreate / UserUpdate / UserResponse (with role enum)
- Paginated[T] generic wrapper for all list endpoints
- Custom validators: email uniqueness per tenant, role transitions
- Discriminated union for notification preferences
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full FastAPI setup workflow |
| `--schemas` | Design Pydantic models with validation |
| `--auth jwt` | Configure JWT authentication |
| `--auth oauth2` | Configure OAuth2 with scopes |
| `--db sqlalchemy` | Set up async SQLAlchemy |
| `--db tortoise` | Set up Tortoise ORM |
| `--websocket` | Add WebSocket support |
| `--tasks celery` | Configure Celery task queue |
| `--tasks arq` | Configure ARQ (async-native) |
| `--test` | Generate pytest + HTTPX test suite |
| `--optimize` | Profile and optimize async performance |
| `--audit` | Audit existing FastAPI app for anti-patterns |

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

## Multi-Agent Dispatch

For large FastAPI services, dispatch parallel agents per resource domain:

```
PARALLEL FASTAPI AGENTS:
When building multiple resource domains simultaneously:

Agent 1 (worktree: api-core):
  - Set up FastAPI app factory, config (pydantic-settings), DB session
  - Implement auth dependencies (JWT, role-based access)
  - Create shared schemas (PaginatedResponse, error types)
  - Set up Alembic and base model with TimestampMixin

Agent 2 (worktree: api-domain-a):
  - Build resource domain A (schemas, models, repos, services, routes)
  - Write tests for domain A endpoints and services
  - Create Alembic migrations for domain A models

Agent 3 (worktree: api-domain-b):
  - Build resource domain B (schemas, models, repos, services, routes)
  - Write tests for domain B endpoints and services
  - Create Alembic migrations for domain B models

MERGE STRATEGY: Core merges first. Domain agents rebase onto core, then merge sequentially.
  Alembic migration conflicts resolved by regenerating heads after merge.
  Final: run full test suite, verify OpenAPI docs render correctly.
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

## Anti-Patterns

- **Do NOT use sync database drivers.** `psycopg2` blocks the event loop. Use `asyncpg` with `postgresql+asyncpg://` connection strings.
- **Do NOT return SQLAlchemy models directly.** Use Pydantic response schemas. Models carry ORM state that will break serialization and leak internals.
- **Do NOT import database sessions as module globals.** Use `Depends(get_db)` for request-scoped sessions. Global sessions cause concurrency bugs.
- **Do NOT skip input validation.** Pydantic schemas with `Field()` constraints catch bad data before it reaches your service layer.
- **Do NOT block the event loop.** CPU-intensive work (image processing, ML inference) must run in a thread pool (`run_in_executor`) or separate worker process.
- **Do NOT use `lazy` loading on async relationships.** Use `selectin` or `joined` loading strategy. Lazy loading triggers synchronous queries in an async context.
- **Do NOT hardcode configuration.** Use `pydantic-settings` with `.env` files. Every configurable value must come from environment variables.
- **Do NOT skip Alembic migrations.** FastAPI + SQLAlchemy needs explicit schema management. Never use `metadata.create_all()` in production.
