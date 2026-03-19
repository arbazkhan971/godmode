# /godmode:fastapi

Build, configure, and optimize FastAPI applications. Covers Pydantic model design, dependency injection patterns, async database access (SQLAlchemy async, Tortoise ORM), background tasks, WebSocket support, and testing with pytest and HTTPX.

## Usage

```
/godmode:fastapi                           # Full FastAPI setup workflow
/godmode:fastapi --schemas                 # Design Pydantic models with validation
/godmode:fastapi --auth jwt                # Configure JWT authentication
/godmode:fastapi --auth oauth2             # Configure OAuth2 with scopes
/godmode:fastapi --db sqlalchemy           # Set up async SQLAlchemy
/godmode:fastapi --db tortoise             # Set up Tortoise ORM
/godmode:fastapi --websocket               # Add WebSocket support
/godmode:fastapi --tasks celery            # Configure Celery task queue
/godmode:fastapi --tasks arq               # Configure ARQ (async-native)
/godmode:fastapi --test                    # Generate pytest + HTTPX test suite
/godmode:fastapi --optimize                # Profile and optimize async performance
/godmode:fastapi --audit                   # Audit existing app for anti-patterns
```

## What It Does

1. Assesses project requirements and sets up async-first project structure
2. Designs Pydantic schemas with create/update/response separation, validators, and generics
3. Configures dependency injection with Annotated types, nested dependencies, and role-based access
4. Sets up async SQLAlchemy 2.0 with asyncpg, repository pattern, and Alembic migrations
5. Implements background tasks (FastAPI BackgroundTasks, Celery, or ARQ) and WebSocket support
6. Configures JWT authentication with dependency-based access control
7. Generates comprehensive pytest + HTTPX async test suite with fixtures and dependency overrides
8. Validates against 15 production-readiness checks

## Output
- Configured FastAPI application with async-first architecture
- Pydantic schemas for all request/response models
- Async SQLAlchemy models with repository pattern
- Dependency injection chain (auth, DB sessions, services)
- Background task configuration
- pytest + HTTPX async test suite
- Alembic migration scripts
- Auto-generated OpenAPI docs at /docs and /redoc
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"fastapi: <service> — <N> async endpoints, Pydantic schemas, pytest"`

## Next Step
After FastAPI setup: `/godmode:test` for more coverage, `/godmode:secure` for security audit, or `/godmode:deploy` for Docker + uvicorn deployment.

## Examples

```
/godmode:fastapi Build an inventory management API
/godmode:fastapi --schemas Design schemas for a multi-tenant SaaS
/godmode:fastapi --auth jwt Set up JWT authentication
/godmode:fastapi --db sqlalchemy Configure async PostgreSQL
/godmode:fastapi --websocket Add real-time order tracking
/godmode:fastapi --optimize Profile our async endpoints
/godmode:fastapi --audit Check our FastAPI app for issues
```
