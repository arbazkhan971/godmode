---
name: django
description: |
  Django and FastAPI development skill. Activates when building, architecting, or optimizing Python web applications.
    Covers Django project structure and app architecture, Django REST Framework with serializers and viewsets, FastAPI
    dependency injection and Pydantic models, async Django with ASGI configuration, admin customization, database
    optimization with the Django ORM, and production deployment. Every recommendation includes concrete code and
    architectural rationale. Triggers on: /godmode:django, "Django", "FastAPI", "DRF", "Django REST Framework",
    "Pydantic", "ASGI", "Django admin", "Python web", "viewsets", "serializers".
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

If the user hasn't specified, ask: "Are you building with Django, FastAPI, or both? Is this an API-only
service or full-stack with templates?"

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

### Step 5: Async Django & ASGI
```
ASGI setup: config/asgi.py with get_asgi_application().
For WebSockets: channels ProtocolTypeRouter + AuthMiddlewareStack.
Use httpx.AsyncClient (not requests) in async views.
```

### Step 6: Django Admin
```
Admin patterns: @admin.register(Model) + ModelAdmin.
Required: list_display, list_filter, search_fields, list_select_related.
Optional: list_editable, inlines, actions, readonly_fields.
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
| Check | Status |
|--|--|
| Business logic in services (not views) | PASS | FAIL |
| Serializers validate all input | PASS | FAIL |
| No N+1 queries (select/prefetch_related) | PASS | FAIL |
| Database indexes on filtered/ordered fields | PASS | FAIL |
| Custom user model (AbstractUser) | PASS | FAIL |
| Settings split by environment | PASS | FAIL |
| Secrets from environment variables | PASS | FAIL |
| Admin performance (list_select_related) | PASS | FAIL |
| Pagination on all list endpoints | PASS | FAIL |
| Authentication and permissions configured | PASS | FAIL |
| Tests use factories (Factory Boy) | PASS | FAIL |
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


```bash
# Django development and testing
python manage.py check --deploy
pytest --tb=short
python manage.py migrate --check
```

## Key Behaviors

```bash
# Django diagnostics
python manage.py check --deploy
python manage.py test --parallel --verbosity=2
python manage.py makemigrations --check --dry-run
python manage.py showmigrations | grep '\[ \]'
```

IF query count per list view > 5: add select_related/prefetch_related.
WHEN test coverage < 80%: add tests before shipping.
IF response time P95 > 200ms: profile with django-debug-toolbar.

1. **Services own business logic.** Views dispatch, serializers validate, services contain logic.
2. **Fat models, thin views — but not too fat.** Cross-model rules belong in services.
3. **DRF serializers are contracts.** Never `fields = '__all__'`. Separate create vs read serializers.
4. **Eliminate N+1 queries.** select_related for FK, prefetch_related for M2M. Use django-debug-toolbar.
5. **FastAPI dependencies compose.** Auth, pagination, DB sessions as composable deps.
6. **Pydantic is source of truth.** Validation, serialization, documentation in one place.
7. **Admin is a power tool.** Customize list_display, search, filters. Admin N+1 is the top perf issue.

## Flags & Options

| Flag | Description |
|--|--|
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

## Auto-Detection
```
1. Scan for manage.py, settings.py → Django; main.py with FastAPI → FastAPI; both → hybrid
2. Check REST_FRAMEWORK config, AUTH_USER_MODEL, DATABASES engine
3. Scan for services.py/selectors.py (layering), factories.py (testing), Celery (tasks)
4. Maturity: scaffold | structured | optimized | production-ready
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
1. `python manage.py check --deploy` passes with 0 critical warnings
2. `python manage.py test` passes; coverage >= 80%
3. No business logic in views/serializers — services only
4. No `fields = '__all__'` — explicit field lists
5. All querysets use select_related/prefetch_related; list views <= 5 queries, detail <= 3
6. Filterable/sortable fields have DB indexes
7. Custom user model (not default auth.User)
8. Migrations consistent (`makemigrations --check`)

## Error Recovery
| Failure | Action |
|--|--|
| manage.py check fails | Fix CRITICAL first (middleware, ALLOWED_HOSTS) |
| Tests fail | Check test DB permissions, fixtures |
| Migration conflict | `makemigrations --merge` |
| N+1 detected | Add select_related/prefetch_related |

## Keep/Discard Discipline
```
KEEP if: tests pass AND quality improved AND no regressions
DISCARD if: tests fail OR performance regressed. Revert before proceeding.
```

## Stop Conditions
```
STOP when: all tasks validated OR max iterations reached.
Guard: python manage.py test && python manage.py check --deploy.
On failure: git reset --hard HEAD~1.
```

