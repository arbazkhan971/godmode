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
│   └── asgi.py                 # ASGI entry point (async support)
│
├── apps/                       # Django applications
│   ├── users/
│   │   ├── __init__.py
│   │   ├── apps.py             # AppConfig
│   │   ├── models.py           # User model, Profile
│   │   ├── managers.py         # Custom managers (UserManager)
│   │   ├── admin.py            # Admin configuration
│   │   ├── serializers.py      # DRF serializers
│   │   ├── views.py            # Views or ViewSets
│   │   ├── urls.py             # App-level URL patterns
│   │   ├── permissions.py      # Custom DRF permissions
│   │   ├── signals.py          # Signal handlers (post_save, etc.)
│   │   ├── tasks.py            # Celery tasks
│   │   ├── services.py         # Business logic (not in views!)
│   │   ├── selectors.py        # Query logic (complex reads)
│   │   ├── tests/
│   │   │   ├── __init__.py
│   │   │   ├── test_models.py
│   │   │   ├── test_views.py
│   │   │   ├── test_services.py
│   │   │   └── factories.py   # Factory Boy factories
│   │   └── migrations/
│   │       └── 0001_initial.py
│   │
│   ├── products/
│   │   ├── ...                 # Same structure as users
│   │   └── migrations/
│   │
│   └── core/                   # Shared utilities
│       ├── models.py           # Abstract base models (TimeStamped, etc.)
│       ├── permissions.py      # Shared permission classes
│       ├── pagination.py       # Custom pagination classes
│       ├── exceptions.py       # Custom exception handler
│       └── middleware.py       # Custom middleware
│
├── templates/                  # Project-level templates (if full-stack)
│   ├── base.html
│   └── components/
├── static/                     # Static files (CSS, JS, images)
└── requirements/
    ├── base.txt
    ├── development.txt
    └── production.txt

APP DESIGN RULES:
- Each app handles ONE domain concept (users, products, orders)
- Apps should be loosely coupled — minimal cross-app imports
- Business logic goes in services.py, NOT in views or serializers
- Complex read queries go in selectors.py
- Use signals sparingly — prefer explicit service calls
- Abstract base models in core/ for shared fields (created_at, updated_at)
- Keep migrations clean — squash when they exceed 20 per app
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

  # Separate serializers for create vs read
  class UserCreateSerializer(serializers.ModelSerializer):
      password = serializers.CharField(write_only=True, min_length=8)

      class Meta:
          model = User
          fields = ['email', 'password', 'first_name', 'last_name']

      def create(self, validated_data):
          return User.objects.create_user(**validated_data)

  class UserDetailSerializer(serializers.ModelSerializer):
      posts_count = serializers.IntegerField(read_only=True)
      recent_activity = ActivitySerializer(many=True, read_only=True)

      class Meta:
          model = User
          fields = ['id', 'email', 'full_name', 'posts_count',
                    'recent_activity', 'created_at']

  # Nested serializer with write support
  class OrderSerializer(serializers.ModelSerializer):
      items = OrderItemSerializer(many=True)

      class Meta:
          model = Order
          fields = ['id', 'customer', 'items', 'total', 'status']

      def create(self, validated_data):
          items_data = validated_data.pop('items')
          order = Order.objects.create(**validated_data)
          OrderItem.objects.bulk_create([
              OrderItem(order=order, **item) for item in items_data
          ])
          return order

2. ViewSets — Standard CRUD with routing:

  class UserViewSet(viewsets.ModelViewSet):
      queryset = User.objects.all()
      permission_classes = [IsAuthenticated]
      filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
      filterset_fields = ['is_active', 'role']
      search_fields = ['email', 'first_name', 'last_name']
      ordering_fields = ['created_at', 'email']
      ordering = ['-created_at']

      def get_serializer_class(self):
          if self.action == 'create':
              return UserCreateSerializer
          if self.action in ['retrieve', 'me']:
              return UserDetailSerializer
          return UserSerializer

      def get_queryset(self):
          qs = super().get_queryset()
          if self.action == 'retrieve':
              qs = qs.annotate(posts_count=Count('posts'))
              qs = qs.prefetch_related('recent_activity')
          return qs

      @action(detail=False, methods=['get'])
      def me(self, request):
          serializer = self.get_serializer(request.user)
          return Response(serializer.data)

      @action(detail=True, methods=['post'])
      def deactivate(self, request, pk=None):
          user = self.get_object()
          user_service.deactivate(user, performed_by=request.user)
          return Response(status=status.HTTP_204_NO_CONTENT)

3. Router configuration:

  # urls.py
  from rest_framework.routers import DefaultRouter

  router = DefaultRouter()
  router.register('users', UserViewSet, basename='user')
  router.register('products', ProductViewSet, basename='product')
  router.register('orders', OrderViewSet, basename='order')

  urlpatterns = [
      path('api/v1/', include(router.urls)),
      path('api/v1/auth/', include('apps.auth.urls')),
  ]

4. Custom permissions:

  class IsOwnerOrAdmin(permissions.BasePermission):
      def has_object_permission(self, request, view, obj):
          if request.user.is_staff:
              return True
          return obj.owner == request.user

  class IsReadOnly(permissions.BasePermission):
      def has_permission(self, request, view):
          return request.method in permissions.SAFE_METHODS

5. Pagination:

  # config/settings/base.py
  REST_FRAMEWORK = {
      'DEFAULT_PAGINATION_CLASS': 'apps.core.pagination.CursorPagination',
      'PAGE_SIZE': 20,
      'DEFAULT_AUTHENTICATION_CLASSES': [
          'rest_framework_simplejwt.authentication.JWTAuthentication',
      ],
      'DEFAULT_PERMISSION_CLASSES': [
          'rest_framework.permissions.IsAuthenticated',
      ],
      'DEFAULT_THROTTLE_CLASSES': [
          'rest_framework.throttling.AnonRateThrottle',
          'rest_framework.throttling.UserRateThrottle',
      ],
      'DEFAULT_THROTTLE_RATES': {
          'anon': '100/hour',
          'user': '1000/hour',
      },
      'EXCEPTION_HANDLER': 'apps.core.exceptions.custom_exception_handler',
  }

SERIALIZER RULES:
- NEVER put business logic in serializers — use services
- Use separate serializers for create/update vs read
- Always specify fields explicitly — never use fields = '__all__'
- Use select_related/prefetch_related in get_queryset to avoid N+1
- Validate at the serializer level, not in views
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
│   └── dependencies.py     # Feature-specific dependencies
│
├── products/
│   ├── router.py
│   ├── schemas.py
│   ├── models.py
│   ├── service.py
│   └── repository.py
│
└── core/
    ├── security.py         # JWT, password hashing
    ├── exceptions.py       # Custom exception handlers
    └── middleware.py        # CORS, logging, timing middleware

PYDANTIC MODELS (schemas.py):

  from pydantic import BaseModel, EmailStr, Field
  from datetime import datetime

  # Base schema — shared fields
  class UserBase(BaseModel):
      email: EmailStr
      first_name: str = Field(min_length=1, max_length=50)
      last_name: str = Field(min_length=1, max_length=50)

  # Create schema — input validation
  class UserCreate(UserBase):
      password: str = Field(min_length=8, max_length=128)

  # Update schema — all fields optional
  class UserUpdate(BaseModel):
      email: EmailStr | None = None
      first_name: str | None = Field(None, min_length=1, max_length=50)
      last_name: str | None = Field(None, min_length=1, max_length=50)

  # Response schema — what the API returns
  class UserResponse(UserBase):
      id: int
      is_active: bool
      created_at: datetime

      model_config = ConfigDict(from_attributes=True)

  # List response with pagination
  class PaginatedResponse[T](BaseModel):
      items: list[T]
      total: int
      page: int
      page_size: int
      has_next: bool

DEPENDENCY INJECTION:

  from fastapi import Depends, HTTPException, status
  from fastapi.security import OAuth2PasswordBearer

  oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/token")

  # Database session dependency
  async def get_db() -> AsyncGenerator[AsyncSession, None]:
      async with async_session() as session:
          try:
              yield session
              await session.commit()
          except Exception:
              await session.rollback()
              raise

  # Current user dependency (composable)
  async def get_current_user(
      token: str = Depends(oauth2_scheme),
      db: AsyncSession = Depends(get_db),
  ) -> User:
      payload = decode_jwt(token)
      user = await db.get(User, payload["sub"])
      if not user or not user.is_active:
          raise HTTPException(status_code=401, detail="Invalid credentials")
      return user

  # Role-based dependency (factory pattern)
  def require_role(*roles: str):
      async def dependency(user: User = Depends(get_current_user)):
          if user.role not in roles:
              raise HTTPException(status_code=403, detail="Insufficient permissions")
          return user
      return dependency

  # Pagination dependency
  async def get_pagination(
      page: int = Query(1, ge=1),
      page_size: int = Query(20, ge=1, le=100),
  ) -> dict:
      return {"offset": (page - 1) * page_size, "limit": page_size, "page": page}

ROUTER (router.py):

  from fastapi import APIRouter, Depends, Query, Path, status
  from fastapi.responses import StreamingResponse

  router = APIRouter(prefix="/users", tags=["users"])

  @router.get("/", response_model=PaginatedResponse[UserResponse])
  async def list_users(
      pagination: dict = Depends(get_pagination),
      search: str | None = Query(None, min_length=1),
      is_active: bool | None = None,
      db: AsyncSession = Depends(get_db),
      current_user: User = Depends(get_current_user),
  ):
      return await user_service.list_users(
          db, pagination=pagination, search=search, is_active=is_active
      )

  @router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
  async def create_user(
      data: UserCreate,
      db: AsyncSession = Depends(get_db),
      current_user: User = Depends(require_role("admin")),
  ):
      return await user_service.create_user(db, data)

  @router.get("/{user_id}", response_model=UserResponse)
  async def get_user(
      user_id: int = Path(ge=1),
      db: AsyncSession = Depends(get_db),
      current_user: User = Depends(get_current_user),
  ):
      user = await user_service.get_user(db, user_id)
      if not user:
          raise HTTPException(status_code=404, detail="User not found")
      return user

  @router.patch("/{user_id}", response_model=UserResponse)
  async def update_user(
      user_id: int,
      data: UserUpdate,
      db: AsyncSession = Depends(get_db),
      current_user: User = Depends(require_role("admin")),
  ):
      return await user_service.update_user(db, user_id, data)

  # Mount router in main.py:
  app.include_router(users.router, prefix="/api/v1")

FASTAPI RULES:
- Pydantic models for ALL input validation — never trust raw request data
- Dependencies compose — build complex auth/permissions from simple deps
- Use async everywhere — async def for endpoints, async SQLAlchemy, async httpx
- response_model strips extra fields — prevents data leakage
- Use Path/Query/Body validators for all parameters
- Background tasks for non-critical work (email, logging)
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
      "websocket": AuthMiddlewareStack(
          URLRouter(websocket_urlpatterns)
      ),
  })

2. Async views:
  # Async function-based view
  from django.http import JsonResponse
  from asgiref.sync import sync_to_async

  async def dashboard_view(request):
      # Async ORM queries (Django 4.1+)
      user_count = await User.objects.acount()
      recent_orders = [
          order async for order in
          Order.objects.filter(status='pending').order_by('-created_at')[:10]
      ]

      # Call sync code from async context
      report = await sync_to_async(generate_report)()

      return JsonResponse({
          'user_count': user_count,
          'recent_orders': [serialize(o) for o in recent_orders],
      })

  # Async DRF view (with adrf)
  from adrf.viewsets import ModelViewSet as AsyncModelViewSet

  class OrderViewSet(AsyncModelViewSet):
      queryset = Order.objects.all()
      serializer_class = OrderSerializer

      async def perform_create(self, serializer):
          order = await sync_to_async(serializer.save)(user=self.request.user)
          await send_order_notification(order)  # Async notification

3. Async ORM operations (Django 4.1+):
  # Async querysets
  users = await User.objects.filter(is_active=True).acount()
  user = await User.objects.aget(pk=1)
  exists = await User.objects.filter(email=email).aexists()

  # Async iteration
  async for order in Order.objects.filter(status='pending'):
      await process_order(order)

  # Async create/update/delete
  user = await User.objects.acreate(email='new@example.com')
  await User.objects.filter(pk=1).aupdate(is_active=False)
  await User.objects.filter(is_active=False).adelete()

4. ASGI server configuration:
  # Production: Uvicorn with Gunicorn
  gunicorn config.asgi:application \
    --worker-class uvicorn.workers.UvicornWorker \
    --workers 4 \
    --bind 0.0.0.0:8000 \
    --timeout 120 \
    --keep-alive 5

  # Development:
  uvicorn config.asgi:application --reload --host 0.0.0.0 --port 8000

ASYNC RULES:
- Use async views ONLY when you have actual async I/O (external APIs, WebSocket)
- Django ORM is partially async (4.1+) — complex queries may still need sync_to_async
- NEVER use sync_to_async in a hot path — it creates a thread per call
- Use httpx (async) instead of requests for external HTTP calls
- Use Channels for WebSocket support — ASGI required
- Test async views with pytest-asyncio
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
      search_fields = ['name', 'sku', 'description']
      date_hierarchy = 'created_at'

      # Performance
      list_select_related = ['category']
      list_per_page = 50

      # Form layout
      fieldsets = [
          (None, {
              'fields': ['name', 'sku', 'description']
          }),
          ('Pricing', {
              'fields': ['price', 'compare_at_price', 'cost_per_item'],
              'classes': ['collapse'],
          }),
          ('Inventory', {
              'fields': ['stock_quantity', 'low_stock_threshold',
                          'track_inventory'],
          }),
          ('SEO', {
              'fields': ['slug', 'meta_title', 'meta_description'],
              'classes': ['collapse'],
          }),
      ]
      prepopulated_fields = {'slug': ('name',)}
      readonly_fields = ['created_at', 'updated_at']

      # Inline related models
      inlines = [ProductImageInline, ProductVariantInline]

      # Custom display methods
      @admin.display(description='Price', ordering='price')
      def price_display(self, obj):
          return f"${obj.price:.2f}"

      @admin.display(description='Stock', boolean=True)
      def stock_status(self, obj):
          return obj.stock_quantity > obj.low_stock_threshold

      # Custom actions
      @admin.action(description='Mark selected as active')
      def make_active(self, request, queryset):
          updated = queryset.update(is_active=True)
          self.message_user(request, f'{updated} products activated.')

      @admin.action(description='Export selected to CSV')
      def export_csv(self, request, queryset):
          response = HttpResponse(content_type='text/csv')
          response['Content-Disposition'] = 'attachment; filename="products.csv"'
          writer = csv.writer(response)
          writer.writerow(['Name', 'SKU', 'Price', 'Stock'])
          for product in queryset:
              writer.writerow([product.name, product.sku,
                                product.price, product.stock_quantity])
          return response

      actions = [make_active, export_csv]

      # Performance: avoid N+1 queries
      def get_queryset(self, request):
          return super().get_queryset(request).select_related(
              'category'
          ).prefetch_related('images', 'variants')

2. Inline models:

  class ProductImageInline(admin.TabularInline):
      model = ProductImage
      extra = 1
      max_num = 10
      fields = ['image', 'alt_text', 'is_primary', 'sort_order']

  class ProductVariantInline(admin.StackedInline):
      model = ProductVariant
      extra = 0
      fields = ['name', 'sku', 'price_modifier', 'stock_quantity']

3. Custom admin site:

  class CustomAdminSite(admin.AdminSite):
      site_header = 'Project Admin'
      site_title = 'Project Admin Portal'
      index_title = 'Dashboard'

      def get_app_list(self, request, app_label=None):
          # Custom ordering of apps in sidebar
          app_list = super().get_app_list(request, app_label)
          app_order = ['users', 'products', 'orders', 'analytics']
          return sorted(app_list,
                         key=lambda x: app_order.index(x['app_label'])
                         if x['app_label'] in app_order else 999)

  admin_site = CustomAdminSite(name='custom_admin')

ADMIN RULES:
- ALWAYS use list_select_related and prefetch_related — admin N+1 queries are common
- Use readonly_fields for computed or sensitive fields
- Use fieldsets to organize complex forms
- Custom actions for bulk operations (export, status change)
- Never expose sensitive data (passwords, tokens) in admin
- Use list_per_page to limit query size (default 100 is often too high)
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
  orders = Order.objects.prefetch_related(
      Prefetch('items',
               queryset=OrderItem.objects.select_related('product')
                        .filter(quantity__gt=0))
  ).all()

2. Use annotations over Python computation:
  # BAD: Calculate in Python
  for user in User.objects.all():
      user.order_total = sum(o.total for o in user.orders.all())

  # GOOD: Calculate in database
  users = User.objects.annotate(
      order_total=Sum('orders__total'),
      order_count=Count('orders'),
      avg_order_value=Avg('orders__total'),
  ).filter(order_count__gt=0)

3. Use .only() and .defer() for large models:
  # Only fetch needed fields
  products = Product.objects.only('name', 'price', 'stock_quantity')

  # Defer expensive fields (large text, JSON)
  products = Product.objects.defer('description', 'metadata')

4. Bulk operations:
  # BAD: Individual creates in a loop
  for item in items:
      Product.objects.create(**item)  # N queries

  # GOOD: Bulk create
  Product.objects.bulk_create([
      Product(**item) for item in items
  ], batch_size=1000)

  # GOOD: Bulk update
  Product.objects.bulk_update(products, ['price', 'stock_quantity'],
                               batch_size=1000)

5. Database indexes:
  class Product(models.Model):
      sku = models.CharField(max_length=50, unique=True, db_index=True)
      name = models.CharField(max_length=200)
      category = models.ForeignKey(Category, on_delete=models.CASCADE)
      price = models.DecimalField(max_digits=10, decimal_places=2)
      is_active = models.BooleanField(default=True)
      created_at = models.DateTimeField(auto_now_add=True)

      class Meta:
          indexes = [
              models.Index(fields=['category', 'is_active']),
              models.Index(fields=['-created_at']),
              models.Index(
                  fields=['price'],
                  condition=Q(is_active=True),
                  name='active_product_price_idx'  # Partial index
              ),
          ]
          ordering = ['-created_at']

6. Raw SQL for complex queries:
  # Use as last resort when ORM cannot express the query
  from django.db import connection

  with connection.cursor() as cursor:
      cursor.execute("""
          SELECT category_id, COUNT(*) as cnt, AVG(price) as avg_price
          FROM products_product
          WHERE is_active = true
          GROUP BY category_id
          HAVING COUNT(*) > 10
          ORDER BY avg_price DESC
      """)
      results = cursor.fetchall()
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
│  Migrations are clean (no conflicts)           │  PASS | FAIL        │
│  ASGI configured for async endpoints           │  PASS | FAIL | N/A  │
│  Celery for background tasks                   │  PASS | FAIL | N/A  │
│  CORS configured properly                      │  PASS | FAIL        │
│  Rate limiting on public endpoints             │  PASS | FAIL        │
└────────────────────────────────────────────────┴─────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
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

## Example Usage

### Building a Django REST API
```
User: /godmode:django Build a REST API for a blog platform

DJANGO: Starting project assessment...

ASSESSMENT:
Project: Blog platform API
Framework: Django + DRF
Type: API-only (React frontend)
Database: PostgreSQL
Auth: JWT (djangorestframework-simplejwt)

APPS:
├── apps/users/       # Custom user, profiles, following
├── apps/posts/       # Posts, drafts, publishing workflow
├── apps/comments/    # Threaded comments
├── apps/tags/        # Tag system with auto-suggest
└── apps/core/        # Base models, permissions, pagination

API ENDPOINTS:
- 6 ViewSets, 24 endpoints
- Cursor-based pagination on all lists
- Full-text search on posts (PostgreSQL)
- Nested comment serializers with depth control
...
```

### FastAPI microservice
```
User: /godmode:django Build a FastAPI notification service

DJANGO: Starting project assessment...

ASSESSMENT:
Project: Notification microservice
Framework: FastAPI (not Django — microservice scope)
Type: Async microservice
Database: PostgreSQL + Redis (for real-time)

ARCHITECTURE:
app/
├── notifications/
│   ├── router.py       # Send, list, mark-read endpoints
│   ├── schemas.py      # NotificationCreate, NotificationResponse
│   ├── service.py      # Notification logic, deduplication
│   ├── repository.py   # Async SQLAlchemy queries
│   └── websocket.py    # Real-time WebSocket delivery
├── templates/           # Email/SMS templates (Jinja2)
├── channels/            # Email, SMS, push, in-app, Slack
└── dependencies.py      # Auth, rate limiting, channel selection
...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Django/FastAPI workflow |
| `--audit` | Audit existing Django or FastAPI project |
| `--django` | Django-specific guidance only |
| `--fastapi` | FastAPI-specific guidance only |
| `--drf` | Django REST Framework patterns |
| `--admin` | Admin customization |
| `--async` | Async Django / ASGI configuration |
| `--orm` | Database optimization guide |
| `--migrate` | Database migration strategy |
| `--deploy <target>` | Deployment configuration (gunicorn, docker, serverless) |

## HARD RULES

- NEVER put business logic in views or serializers — business rules belong in service functions
- NEVER use `fields = '__all__'` in DRF serializers — explicitly list every field to prevent data leakage
- NEVER use the default User model — always create a custom user model with AbstractUser at project start
- NEVER use synchronous HTTP calls (requests) in async views — use httpx.AsyncClient instead
- NEVER skip database indexes on fields used in filter(), order_by(), or WHERE clauses
- ALL N+1 queries MUST be eliminated with select_related (ForeignKey) and prefetch_related (ManyToMany)
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

## Multi-Agent Dispatch

```
DISPATCH 4 agents in separate worktrees:
  Agent 1 (models+DB):     Audit/build models, managers, indexes, migrations, custom User model
  Agent 2 (API layer):     Audit/build serializers, viewsets, routers, permissions, pagination, throttling
  Agent 3 (services):      Extract business logic into services.py + selectors.py, write service-level tests
  Agent 4 (admin+async):   Customize admin (list_display, filters, actions, inlines), configure ASGI if needed
SYNC point: All agents complete
  Merge worktrees
  Run full test suite + python manage.py check --deploy
  Generate project audit report with per-app status
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

## Anti-Patterns

- **Do NOT put business logic in views or serializers.** Views handle HTTP, serializers handle validation. Business rules belong in service functions that can be tested independently.
- **Do NOT use `fields = '__all__'` in serializers.** You will accidentally expose sensitive fields (passwords, tokens, internal IDs). Explicitly list every field.
- **Do NOT ignore N+1 queries.** Django ORM is lazy — every attribute access on a related object triggers a query. Use `select_related` and `prefetch_related` everywhere.
- **Do NOT skip database indexes.** Add indexes on every field used in `filter()`, `order_by()`, or `WHERE` clauses. Partial indexes for common query patterns.
- **Do NOT use the default User model.** Always create a custom user model with `AbstractUser` at project start. Changing later requires a database migration nightmare.
- **Do NOT handle auth in every view.** Use DRF permission classes or FastAPI dependencies. Auth logic scattered across views is unmaintainable and insecure.
- **Do NOT use synchronous HTTP calls in async views.** Use `httpx.AsyncClient` instead of `requests`. Synchronous calls block the event loop in ASGI.
- **Do NOT skip admin customization.** Default admin with just `admin.site.register(Model)` is useless at scale. Invest in list_display, search, filters, and actions — your operations team will thank you.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run Django tasks sequentially: models+DB, then API layer, then services, then admin+async.
- Use branch isolation per task: `git checkout -b godmode-django-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
