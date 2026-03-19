# /godmode:django

Build Python web applications with Django and FastAPI. Covers Django project structure, Django REST Framework serializers and viewsets, FastAPI dependency injection and Pydantic models, async Django with ASGI, admin customization, and database optimization.

## Usage

```
/godmode:django                            # Full Django/FastAPI workflow
/godmode:django --audit                    # Audit existing project
/godmode:django --django                   # Django-specific guidance
/godmode:django --fastapi                  # FastAPI-specific guidance
/godmode:django --drf                      # Django REST Framework patterns
/godmode:django --admin                    # Admin customization
/godmode:django --async                    # Async Django / ASGI configuration
/godmode:django --orm                      # Database optimization guide
/godmode:django --migrate                  # Database migration strategy
/godmode:django --deploy gunicorn          # Deploy with Gunicorn + Nginx
/godmode:django --deploy docker            # Deploy with Docker
```

## What It Does

1. Assesses project context (Django, FastAPI, or hybrid; monolith or microservice)
2. Designs Django project structure (settings split, app architecture, service layer)
3. Configures DRF with serializers, viewsets, permissions, pagination, and throttling
4. Designs FastAPI application with dependency injection, Pydantic models, and async routers
5. Configures async Django with ASGI, async ORM queries, and Channels for WebSocket
6. Customizes Django admin (list_display, filters, actions, inlines, fieldsets)
7. Optimizes Django ORM queries (select_related, prefetch_related, annotations, indexes)
8. Validates against Python web best practices (16-point audit)
9. Generates project structure and API endpoint inventory

## Output
- Django project structure with apps, services, and selectors
- DRF ViewSet and serializer patterns or FastAPI router and schema patterns
- Admin configuration with optimized queries
- Database optimization with indexes and query patterns
- Architecture audit with PASS/NEEDS REVISION verdict
- Commit: `"django: <project> — <framework>, <N> apps, <M> endpoints, <admin/async config>"`

## Next Step
After Django/FastAPI architecture: `/godmode:api` for API documentation, `/godmode:test` for model and view tests, or `/godmode:deploy` for production deployment.

## Examples

```
/godmode:django Build a REST API for a blog platform with Django + DRF
/godmode:django --fastapi Build a notification microservice with FastAPI
/godmode:django --admin Customize admin for our e-commerce product catalog
/godmode:django --orm Our list views are slow — optimize the ORM queries
/godmode:django --audit Check our Django project for architecture issues
```
