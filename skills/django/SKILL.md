---
name: django
description: |
  Django and FastAPI development skill. Activates when building, architecting, or optimizing Python web applications. Covers Django project structure and app architecture, Django REST Framework with serializers and viewsets, FastAPI dependency injection and Pydantic models, async Django with ASGI configuration, admin customization, database optimization with the Django ORM, and production deployment. Every recommendation includes concrete code and architectural rationale. Triggers on: /godmode:django, "Django", "FastAPI", "DRF", "Django REST Framework", "Pydantic", "ASGI", "Django admin", "Python web", "viewsets", "serializers".
---

# Django — Django & FastAPI Development

## When to Activate
- User invokes `/godmode:django`
- User says "Django", "Django project", "Django app"
- User mentions "FastAPI", "Pydantic", "dependency injection"
- User asks about "DRF", "Django REST Framework", "serializers", "viewsets"
- User mentions "Django admin", "admin customization"
- User asks about "ASGI", "async Django", "Uvicorn", "Daphne"
- When `/godmode:plan` identifies a Python web project
- When `/godmode:review` flags Django or FastAPI architecture issues

## Workflow

### Step 1: Project Assessment
Understand the Python web application context:

```
PYTHON WEB PROJECT ASSESSMENT:
Project: <name and purpose>
Framework: <Django | FastAPI | both (Django + FastAPI hybrid)>
Type: <monolith | microservice | API-only | full-stack with templates>
Scale: <expected RPS, team size, data volume>
Database: <PostgreSQL, MySQL, SQLite, MongoDB>
Auth: <Django auth, OAuth2, JWT, API keys>
Async needs: <WebSocket, background tasks, streaming, long-polling>
Deployment: <Gunicorn+Nginx, Docker, serverless, PaaS>
Existing code: <greenfield | existing Django project | migration>
```

If the user hasn't specified, ask: "Are you building with Django, FastAPI, or both? Is this an API-only service or full-stack with templates?"

### Step 2: Django Project Structure
Design the Django project layout following best practices:

```
DJANGO PROJECT STRUCTURE:

project/
├── manage.py
├── pyproject.toml              # Dependencies, tools config (ruff, mypy)
├── config/                     # Project-level configuration
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py             # Shared settings
│   │   ├── development.py      # Dev overrides (DEBUG=True, etc.)
│   │   ├── production.py       # Production settings (security, caching)
│   │   └── test.py             # Test settings (fast password hasher, in-memory)
│   ├── urls.py                 # Root URL configuration
│   ├── wsgi.py                 # WSGI entry point
```

### Step 3: Django REST Framework Patterns
Design the API layer with DRF:

```
DRF ARCHITECTURE PATTERNS:

1. Serializers — Data validation and transformation:

  # Base serializer pattern
  class UserSerializer(serializers.ModelSerializer):
      full_name = serializers.SerializerMethodField()

      class Meta:
          model = User
          fields = ['id', 'email', 'full_name', 'created_at']
          read_only_fields = ['id', 'created_at']

      def get_full_name(self, obj):
          return f"{obj.first_name} {obj.last_name}"
```

### Step 4: FastAPI Architecture
Design FastAPI applications with dependency injection:

```
FASTAPI APPLICATION ARCHITECTURE:

app/
├── main.py                 # FastAPI app instance, lifespan events
├── config.py               # Pydantic Settings for configuration
├── dependencies.py         # Shared dependencies (get_db, get_current_user)
├── database.py             # SQLAlchemy/databases async engine setup
│
├── users/
│   ├── __init__.py
│   ├── router.py           # APIRouter with endpoints
│   ├── schemas.py          # Pydantic models (request/response)
│   ├── models.py           # SQLAlchemy/SQLModel ORM models
│   ├── service.py          # Business logic
│   ├── repository.py       # Database queries
```

### Step 5: Async Django & ASGI Configuration
Configure Django for async operation:

```
ASYNC DJANGO CONFIGURATION:

1. ASGI setup (config/asgi.py):
  import os
  from django.core.asgi import get_asgi_application

  os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.production')
  application = get_asgi_application()

  # With channels for WebSocket support:
  from channels.routing import ProtocolTypeRouter, URLRouter
  from channels.auth import AuthMiddlewareStack

  application = ProtocolTypeRouter({
      "http": get_asgi_application(),
```

### Step 6: Django Admin Customization
Design a powerful admin interface:

```
ADMIN CUSTOMIZATION PATTERNS:

1. Model Admin — display, filtering, actions:

  @admin.register(Product)
  class ProductAdmin(admin.ModelAdmin):
      # Display
      list_display = ['name', 'sku', 'price_display', 'stock_status',
                       'category', 'is_active', 'created_at']
      list_display_links = ['name']
      list_editable = ['is_active']

      # Filtering and search
      list_filter = ['category', 'is_active', 'created_at',
                      ('price', admin.EmptyFieldListFilter)]
```

### Step 7: Database Optimization
Optimize Django ORM queries:

```
DJANGO ORM OPTIMIZATION:

1. N+1 query prevention:
  # BAD: N+1 queries (1 query for orders + N queries for customers)
  orders = Order.objects.all()
  for order in orders:
      print(order.customer.name)  # Each access triggers a query!

  # GOOD: select_related for ForeignKey/OneToOne (SQL JOIN)
  orders = Order.objects.select_related('customer').all()

  # GOOD: prefetch_related for ManyToMany/reverse FK (separate query)
  orders = Order.objects.prefetch_related('items', 'items__product').all()

  # GOOD: Prefetch with custom queryset
```

### Step 8: Validation
Validate the Python web project:

```
PYTHON WEB PROJECT AUDIT:
┌──────────────────────────────────────────────────────────────────────┐
│  Check                                         │  Status             │
├────────────────────────────────────────────────┼─────────────────────┤
│  Business logic in services (not views)        │  PASS | FAIL        │
│  Serializers validate all input                │  PASS | FAIL        │
│  No N+1 queries (select/prefetch_related)      │  PASS | FAIL        │
│  Database indexes on filtered/ordered fields   │  PASS | FAIL        │
│  Custom user model (AbstractUser)              │  PASS | FAIL        │
│  Settings split by environment                 │  PASS | FAIL        │
│  Secrets from environment variables            │  PASS | FAIL        │
│  Admin performance (list_select_related)       │  PASS | FAIL        │
│  Pagination on all list endpoints              │  PASS | FAIL        │
│  Authentication and permissions configured     │  PASS | FAIL        │
│  Tests use factories (Factory Boy)             │  PASS | FAIL        │
```

### Step 9: Deliverables
Generate the project artifacts:

```
PYTHON WEB PROJECT COMPLETE:

Artifacts:
- Framework: <Django | FastAPI | hybrid>
- Apps/modules: <N> apps, <M> models
- API: <DRF ViewSets | FastAPI routers> with <N> endpoints
- Admin: <N> ModelAdmin configs customized
- Database: <PostgreSQL> with <N> indexes, optimized queries
- Async: <ASGI configured | WSGI only>
- Audit: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:api — Document the API with OpenAPI spec
-> /godmode:test — Write model, view, and integration tests
-> /godmode:deploy — Deploy with Gunicorn+Nginx or Docker
-> /godmode:migrate — Handle database schema migrations
```

Commit: `"django: <project> — <framework>, <N> apps, <M> endpoints, <admin/async config>"`

## Key Behaviors

1. **Services own business logic.** Views parse requests, serializers validate data, services contain the actual logic. This separation makes testing straightforward and logic reusable.
2. **Fat models, thin views — but not too fat.** Models define fields and relationships. Business rules spanning multiple models belong in services, not in model methods.
3. **DRF serializers are contracts.** Never use `fields = '__all__'`. Explicitly list every field. Use separate serializers for create vs read to control what goes in and what comes out.
4. **Eliminate N+1 queries aggressively.** Use `select_related` for ForeignKey, `prefetch_related` for ManyToMany. Use `django-debug-toolbar` in development to catch them.
5. **FastAPI dependencies compose.** Build authentication, authorization, pagination, and database sessions as composable dependencies. Complex endpoints assemble simple deps.
6. **Pydantic models are the source of truth.** In FastAPI, Pydantic schemas define validation, serialization, and documentation in one place. Never validate manually.
7. **Admin is a power tool, not an afterthought.** Customize list_display, search, filters, and actions. Admin N+1 queries are the most common Django performance issue.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Django/FastAPI workflow |
| `--audit` | Audit existing Django or FastAPI project |
| `--django` | Django-specific guidance only |

## HARD RULES

- NEVER put business logic in views or serializers — business rules belong in service functions
- NEVER use `fields = '__all__'` in DRF serializers — explicitly list every field to prevent data leakage
- NEVER use the default User model — always create a custom user model with AbstractUser at project start
- NEVER use synchronous HTTP calls (requests) in async views — use httpx.AsyncClient instead
- NEVER skip database indexes on fields used in filter(), order_by(), or WHERE clauses
- ELIMINATE ALL N+1 queries with select_related (ForeignKey) and prefetch_related (ManyToMany)
- ALL admin ModelAdmin classes MUST use list_select_related to prevent N+1 in the admin interface
- ALL API list endpoints MUST have pagination configured — unbounded queries are not acceptable

## Iterative Audit Loop Protocol

When auditing or building a Django/FastAPI project:

```
current_iteration = 0
audit_queue = [all_apps_and_modules]
WHILE audit_queue is not empty:
    current_iteration += 1
    batch = audit_queue.pop(next 3 apps)
    FOR each app in batch:
        check: business logic in services.py (not views/serializers)
        check: serializers have explicit fields (no __all__)
        check: select_related/prefetch_related on all querysets
        check: database indexes on filtered/ordered fields
        check: admin has list_select_related and list_per_page
        check: pagination on all list endpoints
        log violations found and fixes applied
    run tests + migration check (python manage.py check --deploy)
    IF new issues discovered in dependent apps:
        add to audit_queue
    report: "Iteration {current_iteration}: {N} apps audited, {M} violations fixed, {remaining} apps remaining"
```

## Auto-Detection

```
1. Check for Django or FastAPI:
   - Scan for manage.py, settings.py, wsgi.py, asgi.py → Django detected
   - Scan for main.py with FastAPI/APIRouter imports → FastAPI detected
   - Scan for both → hybrid project
2. Check Django configuration:
   - Scan settings for REST_FRAMEWORK config → DRF detected
   - Scan for INSTALLED_APPS to count apps
   - Check AUTH_USER_MODEL → custom user or default
   - Check for DATABASES config → detect database engine
3. Check project structure:
   - Scan for services.py, selectors.py → proper layering
   - Scan for factories.py in tests/ → Factory Boy usage
   - Scan for Celery config → background task setup
4. Determine maturity: scaffold | structured | optimized | production-ready
5. Set assessment fields and proceed to Step 1
```

## Output Format

End every Django skill invocation with this summary block:

```
DJANGO RESULT:
Action: <scaffold | model | view | serializer | service | optimize | test | audit | upgrade>
Files created/modified: <N>
Models created/modified: <N>
Views created/modified: <N>
Migrations created: <N>
Tests passing: <yes | no | skipped>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
timestamp	project	action	files_count	models_count	views_count	migrations_count	tests_status	notes
```

## Success Criteria

Every Django skill invocation must pass ALL of these checks before reporting success:

1. `python manage.py check --deploy` passes with no critical warnings
2. `python manage.py test` passes if test suite exists
3. No business logic in views or serializers (use service functions)
4. No `fields = '__all__'` in serializers (explicit field lists only)
5. All querysets use `select_related`/`prefetch_related` for related objects
6. All filterable/sortable fields have database indexes
7. Custom user model in place (not default `auth.User`)
8. All migrations are consistent (`python manage.py makemigrations --check`)
9. No synchronous HTTP calls in async views (use `httpx.AsyncClient`)
10. Admin classes have `list_display`, `search_fields`, and `list_filter` configured

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Error Recovery

IF manage.py check fails:
  1. Fix CRITICAL issues first (security middleware, ALLOWED_HOSTS)
IF tests fail:
  1. Check that the system creates the test database successfully (permissions)
IF migration errors:
  1. Conflicting migrations → run makemigrations --merge
IF N+1 query detected:
  1. Add select_related() for ForeignKey/OneToOne traversals
IF serializer/validation errors:
  1. Check that all required fields have defaults or are provided

## Django Optimization Loop

```
DJANGO OPTIMIZATION PASSES:

Pass 1 — Query Count & N+1 Audit:
  1. Instrument with django-debug-toolbar or DB logging
  2. Baseline query count per endpoint
  3. Fix N+1: select_related() for FK, prefetch_related() for M2M/reverse FK
  4. Use Prefetch() objects for filtered prefetches, annotate() for counts
  5. Target: list endpoints <=3-5 queries, detail <=2-3 queries

Pass 2 — Query Efficiency:
  1. Add indexes on every field in filter()/order_by()
  2. Add partial indexes for common query patterns (condition=Q(...))
  3. Use .values()/.only()/.defer() to reduce data loading
  4. Replace .save() loops with bulk_create()/bulk_update()
  5. Use .exists() instead of .count() > 0
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

