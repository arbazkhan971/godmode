---
name: laravel
description: |
  Laravel mastery skill. Activates when user needs to build, configure, optimize, or debug Laravel applications. Covers Eloquent ORM patterns, service container, facades, contracts, queue system, events, broadcasting, Sanctum/Passport authentication, and testing with PHPUnit and Pest. Provides opinionated guidance on production-grade Laravel patterns. Triggers on: /godmode:laravel, "laravel app", "eloquent", "artisan", "blade", or when the orchestrator detects PHP backend work using Laravel.
---

# Laravel — Laravel Mastery

## When to Activate
- User invokes `/godmode:laravel`
- User says "build a Laravel app", "create a Laravel API", "set up Laravel"
- User asks about Eloquent, Blade, Livewire, Artisan, or Laravel queues
- When `/godmode:plan` identifies Laravel implementation tasks
- When `/godmode:scaffold` detects a Laravel project
- When working with PHP backend services using Laravel framework

## Workflow

### Step 1: Project Assessment & Architecture Decision
Understand the project and choose the right Laravel setup:

```
LARAVEL ASSESSMENT:
Project: <name and purpose>
Laravel version: <latest stable, e.g., 11.x>
PHP version: <latest stable, e.g., 8.3.x>
Architecture: Full-stack (Blade/Livewire) | API-only | Hybrid (Inertia)
Database: MySQL | PostgreSQL | SQLite (dev) | MariaDB
Queue driver: Redis | Database | SQS | Beanstalkd
Real-time: Laravel Reverb | Pusher | Ably | None
Auth: Sanctum (SPA/token) | Passport (OAuth2) | Breeze | Jetstream
Frontend: Blade + Livewire | Inertia (Vue/React) | API-only
CSS: Tailwind (default) | Bootstrap
Cache: Redis | Memcached | File | Database
Deployment: Docker | Laravel Forge | Vapor (serverless) | Envoyer
```

```
LARAVEL SETUP DECISIONS:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Decision                            │  Choice & Justification          │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Full-stack vs API-only              │  Blade+Livewire: Server-rendered │
│                                      │  Inertia: SPA feel, Vue/React   │
│                                      │  API-only: Separate frontend    │
│  Auth starter kit                    │  Breeze: Simple, Blade/Inertia  │
│                                      │  Jetstream: Full-featured, teams│
│  API auth                            │  Sanctum: SPA + mobile tokens   │
│                                      │  Passport: Full OAuth2 server   │
│  Queue driver                        │  Redis: Fast, reliable, standard│
│                                      │  Database: No Redis dependency  │
│  Real-time                           │  Reverb: Laravel native WS      │
│  Testing                             │  Pest: Modern, expressive syntax│
│                                      │  PHPUnit: Standard, full control│
└──────────────────────────────────────┴──────────────────────────────────┘
```

Rules:
- ALWAYS use the latest PHP version (8.3+) for performance and type system improvements
- Laravel Sanctum for SPA + mobile token auth — Passport only when you need a full OAuth2 server
- Pest is the modern Laravel testing standard — prefer it over raw PHPUnit for new projects
- Use Laravel Reverb for WebSockets — it is the official, first-party solution

### Step 2: Eloquent ORM Patterns
Master Laravel's ActiveRecord-style ORM:

```php
// Model with relationships, scopes, and casts
class Order extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'customer_id', 'status', 'total_cents', 'notes',
    ];

    protected $casts = [
        'status' => OrderStatus::class,      // Enum casting
        'total_cents' => 'integer',
        'metadata' => 'array',               // JSON casting
        'confirmed_at' => 'datetime',
        'is_priority' => 'boolean',
    ];

    // Relationships
    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function items(): HasMany
    {
        return $this->hasMany(OrderItem::class);
    }

    public function products(): BelongsToMany
    {
        return $this->belongsToMany(Product::class, 'order_items')
            ->withPivot('quantity', 'unit_price')
            ->withTimestamps();
    }

    public function shippingAddress(): HasOne
    {
        return $this->hasOne(ShippingAddress::class);
    }

    // Scopes — composable query constraints
    public function scopeActive(Builder $query): void
    {
        $query->whereNot('status', OrderStatus::Cancelled);
    }

    public function scopeRecent(Builder $query): void
    {
        $query->orderByDesc('created_at');
    }

    public function scopeForCustomer(Builder $query, int $customerId): void
    {
        $query->where('customer_id', $customerId);
    }

    public function scopeCreatedBetween(Builder $query, Carbon $start, Carbon $end): void
    {
        $query->whereBetween('created_at', [$start, $end]);
    }

    // Accessors & Mutators (Laravel 11 attribute syntax)
    protected function totalDollars(): Attribute
    {
        return Attribute::make(
            get: fn () => $this->total_cents / 100,
            set: fn (float $value) => ['total_cents' => (int) ($value * 100)],
        );
    }

    // Business logic
    public function isCancelable(): bool
    {
        return in_array($this->status, [OrderStatus::Pending, OrderStatus::Confirmed]);
    }
}

// Enum for status (PHP 8.1+ backed enum)
enum OrderStatus: string
{
    case Pending = 'pending';
    case Confirmed = 'confirmed';
    case Shipped = 'shipped';
    case Delivered = 'delivered';
    case Cancelled = 'cancelled';
}
```

```
ELOQUENT QUERY OPTIMIZATION:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  Usage                           │
├──────────────────────────────────────┼──────────────────────────────────┤
│  with('relation')                    │  Eager load (prevent N+1)        │
│  load('relation')                    │  Lazy eager load (post-query)    │
│  withCount('relation')               │  Count without loading           │
│  select('col1', 'col2')             │  Reduce memory footprint         │
│  pluck('column')                     │  Extract array of values         │
│  chunk(1000, fn)                     │  Process large datasets          │
│  chunkById(1000, fn)                 │  Safe chunking with mutations    │
│  lazy()                              │  Lazy collection (memory safe)   │
│  cursor()                            │  One-by-one streaming            │
│  whereHas('relation', fn)            │  Filter by relationship          │
│  withWhereHas('relation', fn)        │  Eager load + filter combined    │
│  upsert(data, unique, update)        │  Bulk insert/update              │
│  Model::query()->toSql()            │  Debug query output              │
└──────────────────────────────────────┴──────────────────────────────────┘
```

```php
// Controller with optimized queries
class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $orders = Order::query()
            ->with(['customer:id,name,email', 'items:id,order_id,product_id,quantity'])
            ->withCount('items')
            ->active()
            ->recent()
            ->when($request->status, fn ($q, $status) => $q->where('status', $status))
            ->when($request->customer_id, fn ($q, $id) => $q->forCustomer($id))
            ->paginate($request->integer('per_page', 25));

        return OrderResource::collection($orders)->response();
    }
}

// API Resource (never expose models directly)
class OrderResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'status' => $this->status->value,
            'total' => $this->total_dollars,
            'items_count' => $this->items_count,
            'customer' => new CustomerResource($this->whenLoaded('customer')),
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'created_at' => $this->created_at->toISOString(),
        ];
    }
}
```

Rules:
- ALWAYS use `with()` to eager load relationships displayed in responses
- ALWAYS use API Resources — never return Eloquent models directly from controllers
- Use `$preventLazyLoading` in `AppServiceProvider::boot()` to catch N+1 in development
- Use backed enums (PHP 8.1+) for status fields — they provide type safety and IDE support
- Use `chunk` or `cursor` for processing large datasets — never `Model::all()`
- Add database indexes on all foreign keys and columns used in where/orderBy

### Step 3: Service Container, Facades & Contracts
Leverage Laravel's IoC container:

```php
// Contract (Interface)
namespace App\Contracts;

interface PaymentGateway
{
    public function charge(int $amountCents, string $currency, array $metadata = []): PaymentResult;
    public function refund(string $transactionId, int $amountCents): RefundResult;
}

// Implementation
namespace App\Services;

class StripePaymentGateway implements PaymentGateway
{
    public function __construct(
        private readonly StripeClient $stripe,
        private readonly LoggerInterface $logger,
    ) {}

    public function charge(int $amountCents, string $currency, array $metadata = []): PaymentResult
    {
        try {
            $intent = $this->stripe->paymentIntents->create([
                'amount' => $amountCents,
                'currency' => $currency,
                'metadata' => $metadata,
            ]);
            return PaymentResult::success($intent->id);
        } catch (StripeException $e) {
            $this->logger->error('Payment failed', ['error' => $e->getMessage()]);
            return PaymentResult::failure($e->getMessage());
        }
    }
}

// Service Provider binding
namespace App\Providers;

class PaymentServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(PaymentGateway::class, function ($app) {
            return new StripePaymentGateway(
                stripe: new StripeClient(config('services.stripe.secret')),
                logger: $app->make(LoggerInterface::class),
            );
        });
    }
}

// Action class (single-responsibility service)
namespace App\Actions;

class CreateOrder
{
    public function __construct(
        private readonly PaymentGateway $payment,
        private readonly OrderRepository $orders,
    ) {}

    public function execute(CreateOrderDTO $dto): Order
    {
        return DB::transaction(function () use ($dto) {
            $order = $this->orders->create($dto);

            $payment = $this->payment->charge(
                amountCents: $order->total_cents,
                currency: 'usd',
                metadata: ['order_id' => $order->id],
            );

            if ($payment->failed()) {
                throw new PaymentFailedException($payment->error);
            }

            $order->markAsConfirmed($payment->transactionId);
            OrderConfirmed::dispatch($order);

            return $order;
        });
    }
}
```

```
SERVICE ARCHITECTURE:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  When to Use                     │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Action classes (single method)      │  Complex operations (CreateOrder)│
│  Service classes (multiple methods)  │  Related operations (OrderService) │
│  Repository pattern                  │  Abstract data access layer      │
│  DTOs (Data Transfer Objects)        │  Typed input/output structures   │
│  Contracts (interfaces)              │  Swappable implementations       │
│  Service Providers                   │  Binding interfaces to concrete  │
│  Facades                             │  Static-like access to services  │
│  Pipeline pattern                    │  Sequential processing steps     │
└──────────────────────────────────────┴──────────────────────────────────┘
```

Rules:
- Bind interfaces (contracts) in service providers — swap implementations for testing
- Use Action classes for complex single operations — one public method: `execute()`
- Use DTOs instead of arrays for passing structured data between layers
- Constructor injection over facade usage in application code — facades are for convenience, DI is for testability
- Use `DB::transaction()` for operations that must be atomic

### Step 4: Queue System, Events & Broadcasting
Handle async work and real-time updates:

```php
// Job with retry, backoff, and middleware
class ProcessOrderPayment implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;
    use Batchable; // For batch processing

    public int $tries = 3;
    public array $backoff = [10, 60, 300]; // Exponential backoff

    public function __construct(
        public readonly Order $order,
    ) {}

    public function handle(PaymentGateway $payment): void
    {
        if ($this->batch()?->cancelled()) {
            return;
        }

        $result = $payment->charge($this->order->total_cents, 'usd');

        if ($result->failed()) {
            $this->fail(new PaymentFailedException($result->error));
            return;
        }

        $this->order->markAsConfirmed($result->transactionId);
        OrderConfirmed::dispatch($this->order);
    }

    public function failed(Throwable $exception): void
    {
        Log::error('Payment processing failed', [
            'order_id' => $this->order->id,
            'error' => $exception->getMessage(),
        ]);
        $this->order->markAsFailed();
        Notification::send($this->order->customer, new PaymentFailedNotification($this->order));
    }

    public function middleware(): array
    {
        return [
            new RateLimited('payments'),
            new WithoutOverlapping($this->order->id),
        ];
    }
}

// Event + Listener pattern
class OrderConfirmed
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public readonly Order $order,
    ) {}
}

// Listener
class SendOrderConfirmationEmail implements ShouldQueue
{
    public function handle(OrderConfirmed $event): void
    {
        Mail::to($event->order->customer)
            ->queue(new OrderConfirmationMail($event->order));
    }
}

// Broadcasting for real-time
class OrderStatusUpdated implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public function __construct(
        public readonly Order $order,
    ) {}

    public function broadcastOn(): array
    {
        return [
            new PrivateChannel("orders.{$this->order->customer_id}"),
        ];
    }

    public function broadcastWith(): array
    {
        return [
            'order_id' => $this->order->id,
            'status' => $this->order->status->value,
            'updated_at' => $this->order->updated_at->toISOString(),
        ];
    }
}
```

```
ASYNC ARCHITECTURE:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Component                           │  Purpose                         │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Jobs (ShouldQueue)                  │  Async task processing           │
│  Events + Listeners                  │  Decoupled event handling        │
│  Notifications                       │  Multi-channel alerts            │
│  Broadcasting (ShouldBroadcast)      │  Real-time via WebSocket         │
│  Mail (Mailable + queue)             │  Email sending                   │
│  Job Batches                         │  Group related jobs              │
│  Job Chains                          │  Sequential job execution        │
│  Rate Limiting (middleware)          │  Throttle job execution          │
│  Unique Jobs (ShouldBeUnique)        │  Prevent duplicate processing   │
└──────────────────────────────────────┴──────────────────────────────────┘

QUEUE CONFIGURATION:
┌──────────┬──────────────┬──────────────────────────────────┐
│  Queue   │  Priority    │  Examples                         │
├──────────┼──────────────┼──────────────────────────────────┤
│  high    │  Processed first │  Payments, critical alerts    │
│  default │  Standard    │  Emails, notifications            │
│  low     │  Background  │  Reports, exports, cleanup        │
└──────────┴──────────────┴──────────────────────────────────┘
```

Rules:
- Jobs MUST be idempotent — safe to retry without side effects
- Use `$backoff` array for exponential backoff on retries
- Use `WithoutOverlapping` middleware to prevent concurrent processing of the same entity
- Use events for side effects (email, notification, logging) — keep the main action clean
- Use `ShouldBeUnique` to prevent duplicate jobs in the queue
- Monitor queue with `php artisan queue:monitor` and Laravel Horizon (for Redis)

### Step 5: Authentication — Sanctum & Passport
Implement secure authentication:

```php
// Sanctum — SPA + Token Authentication
// config/sanctum.php
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'localhost,localhost:3000')),

// API routes with Sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', fn (Request $request) => $request->user());
    Route::apiResource('orders', OrderController::class);
});

// Token issuance
class AuthController extends Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        if (! Auth::attempt($request->validated())) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $user = Auth::user();
        $token = $user->createToken(
            name: $request->device_name ?? 'api-token',
            abilities: $this->getAbilitiesForUser($user),
            expiresAt: now()->addDays(30),
        );

        return response()->json([
            'token' => $token->plainTextToken,
            'expires_at' => $token->accessToken->expires_at,
        ]);
    }
}

// Authorization with Gates and Policies
class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        return $user->id === $order->customer_id
            || $user->hasRole('admin');
    }

    public function update(User $user, Order $order): bool
    {
        return $user->id === $order->customer_id
            && $order->isCancelable();
    }

    public function delete(User $user, Order $order): bool
    {
        return $user->hasRole('admin');
    }
}

// Controller using policy
class OrderController extends Controller
{
    public function update(UpdateOrderRequest $request, Order $order): JsonResponse
    {
        $this->authorize('update', $order);

        $order->update($request->validated());

        return new OrderResource($order);
    }
}
```

```
AUTH ARCHITECTURE:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Auth Method                         │  When to Use                     │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Sanctum (SPA mode)                  │  SPA with same-domain backend    │
│  Sanctum (token mode)                │  Mobile apps, third-party tokens │
│  Passport                            │  Full OAuth2 server needed       │
│  Breeze                              │  Simple auth scaffolding         │
│  Jetstream                           │  Auth + teams + 2FA + API tokens │
│  Socialite                           │  OAuth social login providers    │
└──────────────────────────────────────┴──────────────────────────────────┘

AUTHORIZATION LAYERS:
- Gates: Simple closures for non-model actions
- Policies: Model-specific authorization logic
- Middleware: Route-level access control
- Token abilities: Fine-grained API token permissions
```

### Step 6: Testing with PHPUnit & Pest
Comprehensive testing strategy:

```php
// Pest test — Model
describe('Order', function () {
    it('has a customer relationship', function () {
        $order = Order::factory()->create();
        expect($order->customer)->toBeInstanceOf(Customer::class);
    });

    it('scopes active orders exclude cancelled', function () {
        Order::factory()->create(['status' => OrderStatus::Confirmed]);
        Order::factory()->create(['status' => OrderStatus::Cancelled]);

        expect(Order::active()->count())->toBe(1);
    });

    it('is cancelable when pending or confirmed', function () {
        $pending = Order::factory()->make(['status' => OrderStatus::Pending]);
        $shipped = Order::factory()->make(['status' => OrderStatus::Shipped]);

        expect($pending->isCancelable())->toBeTrue()
            ->and($shipped->isCancelable())->toBeFalse();
    });
});

// Pest test — API endpoint
describe('Orders API', function () {
    beforeEach(function () {
        $this->user = User::factory()->create();
        Sanctum::actingAs($this->user, ['orders:read', 'orders:write']);
    });

    it('lists orders for the authenticated user', function () {
        Order::factory()->count(3)->create(['customer_id' => $this->user->customer_id]);
        Order::factory()->count(2)->create(); // Other user's orders

        $response = $this->getJson('/api/v1/orders');

        $response->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonStructure(['data' => [['id', 'status', 'total', 'created_at']]]);
    });

    it('creates an order and dispatches confirmation job', function () {
        Queue::fake();
        $product = Product::factory()->create();

        $response = $this->postJson('/api/v1/orders', [
            'items' => [['product_id' => $product->id, 'quantity' => 2]],
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.status', 'pending');

        Queue::assertPushed(ProcessOrderPayment::class);
    });

    it('returns 403 when updating another user\'s order', function () {
        $otherOrder = Order::factory()->create();

        $this->putJson("/api/v1/orders/{$otherOrder->id}", ['status' => 'confirmed'])
            ->assertForbidden();
    });
});

// Pest test — Job
describe('ProcessOrderPayment', function () {
    it('charges the payment gateway and confirms the order', function () {
        Event::fake();
        $order = Order::factory()->create(['status' => OrderStatus::Pending]);
        $gateway = Mockery::mock(PaymentGateway::class);
        $gateway->shouldReceive('charge')
            ->once()
            ->andReturn(PaymentResult::success('txn_123'));

        (new ProcessOrderPayment($order))->handle($gateway);

        expect($order->fresh()->status)->toBe(OrderStatus::Confirmed);
        Event::assertDispatched(OrderConfirmed::class);
    });

    it('marks order as failed when payment fails', function () {
        Notification::fake();
        $order = Order::factory()->create();
        $gateway = Mockery::mock(PaymentGateway::class);
        $gateway->shouldReceive('charge')
            ->andReturn(PaymentResult::failure('Card declined'));

        $job = new ProcessOrderPayment($order);
        expect(fn () => $job->handle($gateway))->toThrow(PaymentFailedException::class);
    });
});
```

```php
// Factory with states
class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
    {
        return [
            'customer_id' => Customer::factory(),
            'status' => OrderStatus::Pending,
            'total_cents' => fake()->numberBetween(1000, 100000),
            'notes' => fake()->optional()->sentence(),
        ];
    }

    public function confirmed(): static
    {
        return $this->state(fn () => [
            'status' => OrderStatus::Confirmed,
            'confirmed_at' => now(),
        ]);
    }

    public function withItems(int $count = 3): static
    {
        return $this->afterCreating(fn (Order $order) =>
            OrderItem::factory()->count($count)->create(['order_id' => $order->id])
        );
    }
}
```

```
TESTING STRATEGY:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Layer                               │  Approach                        │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Models                              │  Pest + Factories + Assertions   │
│  API endpoints                       │  Pest + Sanctum::actingAs        │
│  Jobs/Listeners                      │  Pest + Queue::fake + Event::fake│
│  Services/Actions                    │  Pest + Mockery for dependencies │
│  Policies                            │  Pest + authorize assertions     │
│  Validation                          │  Pest + assertUnprocessable      │
│  Browser/E2E                         │  Laravel Dusk (Selenium)         │
│  Mail                                │  Mail::fake + assertQueued       │
│  Notifications                       │  Notification::fake              │
└──────────────────────────────────────┴──────────────────────────────────┘

TEST HELPERS:
- Factories: Build test data with states and afterCreating hooks
- Fake facades: Queue::fake(), Event::fake(), Mail::fake(), Notification::fake()
- Sanctum::actingAs(): Authenticate as user with abilities
- assertDatabaseHas/assertDatabaseMissing: Verify database state
- Travel helpers: $this->travel(5)->minutes() for time-dependent tests
- RefreshDatabase trait: Clean database between tests (migration-based)
```

Rules:
- Use Pest for new Laravel projects — it is the modern standard with cleaner syntax
- Use `RefreshDatabase` trait — it wraps tests in transactions for speed
- Use `Queue::fake()`, `Event::fake()`, `Mail::fake()` to test side effects without executing them
- Use factory states for common variations (`:confirmed`, `:withItems`)
- Test authorization rules in every endpoint test — authorization bugs are security bugs
- Use `assertDatabaseHas` to verify persistence, not just response status codes

### Step 7: Validation & Delivery
Verify the Laravel application:

```
LARAVEL VALIDATION:
┌──────────────────────────────────────┬──────────┬──────────────────────┐
│  Check                               │  Status  │  Notes               │
├──────────────────────────────────────┼──────────┼──────────────────────┤
│  N+1 prevention (preventLazyLoading) │  PASS    │  Enabled in dev      │
│  Eager loading on all endpoints      │  PASS    │  with() used         │
│  API Resources (no raw models)       │  PASS    │  JsonResource used   │
│  Form Requests for validation        │  PASS    │  No inline rules     │
│  Policies for authorization          │  PASS    │  All endpoints gated │
│  Jobs idempotent with backoff        │  PASS    │  Retry-safe          │
│  Events for side effects             │  PASS    │  Decoupled listeners │
│  Config cached for production        │  PASS    │  config:cache        │
│  Routes cached for production        │  PASS    │  route:cache         │
│  Environment variables validated     │  PASS    │  No missing env vars │
│  Database indexes on FKs             │  PASS    │  All foreign keys    │
│  Migrations reversible               │  PASS    │  All have down()     │
│  Tests pass (Pest green)             │  PASS    │  Full suite passing  │
│  CSRF/CORS configured               │  PASS    │  Per environment     │
│  Queue monitoring configured         │  PASS    │  Horizon or pulse    │
└──────────────────────────────────────┴──────────┴──────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

```
LARAVEL DELIVERY:

Artifacts:
- Application: <app-name> Laravel <version>
- Models: <N> Eloquent models with relationships and scopes
- Controllers: <N> API controllers with resources
- Jobs: <N> queued jobs with retry policies
- Events: <N> events with listeners
- Tests: <N> Pest tests passing
- Migrations: <N> database migrations
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:test — Increase test coverage
-> /godmode:secure — Security hardening audit
-> /godmode:deploy — Deploy with Forge/Vapor
-> /godmode:optimize — Performance tuning (caching, query optimization)
-> /godmode:observe — Set up monitoring with Telescope/Pulse
```

Commit: `"laravel: <app> — <N> models, <M> endpoints, Eloquent, Pest"`

## Key Behaviors

1. **Laravel conventions first.** Follow the framework's patterns — Eloquent, Resources, Form Requests, Policies. Fighting Laravel's conventions creates maintenance debt.
2. **API Resources, always.** Never return raw Eloquent models from controllers. API Resources control the shape of your response and decouple your API from your database schema.
3. **Prevent lazy loading.** Enable `Model::preventLazyLoading()` in development to catch N+1 queries before they reach production.
4. **Events for side effects.** Email, notifications, analytics, logging — put them in event listeners. Keep your primary action clean and testable.
5. **Jobs must be idempotent.** Queued jobs will be retried on failure. Design them so that running twice produces the same result as running once.
6. **Pest for testing.** Pest's expressive syntax makes tests readable and maintainable. Use fake facades to isolate side effects.
7. **Cache everything in production.** Run `config:cache`, `route:cache`, `view:cache`, and `event:cache` in production. The performance difference is significant.

## Example Usage

### Building a Laravel API
```
User: /godmode:laravel Build an e-commerce API

Laravel: Assessing requirements...

LARAVEL ASSESSMENT:
Project: E-Commerce API
Laravel: 11.x
PHP: 8.3
Architecture: API-only
Auth: Sanctum (SPA + mobile tokens)
Queue: Redis + Horizon

Creating models: Product, Order, OrderItem, Customer, Category...
Setting up Sanctum authentication...
Creating API Resources and Form Requests...
Implementing queued jobs: ProcessPayment, SendConfirmation...
Writing Pest tests: 60 tests across models, API, jobs...

All 15 checks PASS.
```

### Optimizing Eloquent Queries
```
User: /godmode:laravel Our order listing page is slow

Laravel: Analyzing queries...

FINDINGS:
1. N+1 on Order -> Customer (eager loading missing)
2. N+1 on Order -> Items (loading items per order)
3. Missing index on orders.status column
4. Loading full Order model when only 3 fields needed

FIXES:
1. Added ->with('customer:id,name')
2. Added ->withCount('items')
3. Added index migration for status
4. Used select() to limit columns
Query time: 1200ms -> 8ms
```

## HARD RULES
1. NEVER return raw Eloquent models from controllers — always use API Resources (JsonResource).
2. NEVER use `$guarded = []` — explicitly define `$fillable` on every model. Mass assignment vulnerabilities are real.
3. NEVER put business logic in controllers — controllers receive requests and return responses. Logic belongs in Action/Service classes.
4. NEVER use inline validation in controllers — use Form Request classes. They are reusable, testable, and self-documenting.
5. NEVER process heavy work synchronously — email, PDF, payments, and external API calls MUST be queued.
6. NEVER reference `env()` outside config files — use `config()` helper in application code.
7. NEVER skip authorization — every endpoint must check Policies or Gates. No exceptions.
8. ALWAYS enable `Model::preventLazyLoading()` in development — catch N+1 queries before production.
9. ALWAYS use `DB::transaction()` for operations that must be atomic.
10. ALWAYS use backed enums (PHP 8.1+) for status fields and `$casts` for type safety.

## Auto-Detection
On activation, detect Laravel project context automatically:
```
AUTO-DETECT:
1. Confirm Laravel project:
   - artisan file in project root
   - composer.json with laravel/framework dependency
   - Parse Laravel version from composer.lock
2. Detect PHP version:
   - composer.json → require.php version constraint
   - php -v output
3. Detect architecture:
   - routes/web.php present → full-stack (Blade/Livewire/Inertia)
   - routes/api.php present → API routes exist
   - resources/views/ → Blade templates
   - resources/js/ with Vue/React → Inertia
4. Detect auth:
   - config/sanctum.php → Sanctum
   - config/passport.php → Passport
   - laravel/breeze or laravel/jetstream in composer.json
5. Detect queue/cache:
   - config/queue.php → connection driver (redis, database, sqs)
   - config/cache.php → cache driver
   - config/horizon.php → Laravel Horizon
6. Detect testing:
   - tests/Feature/, tests/Unit/
   - pestphp/pest in composer.json → Pest
   - phpunit.xml → PHPUnit
7. Detect deployment:
   - forge.yml → Laravel Forge
   - serverless.yml → Laravel Vapor
   - docker-compose.yml → Docker/Sail
```

## Iterative Build Protocol
Laravel features are built iteratively through the stack:
```
current_layer = 0
layers = ["migration", "model", "policy", "formrequest", "controller", "resource", "routes", "tests"]

WHILE current_layer < len(layers):
  layer = layers[current_layer]
  1. IMPLEMENT layer:
     - migration: Create schema with proper indexes and foreign keys
     - model: Relationships, scopes, casts, fillable, accessors
     - policy: Authorization rules for every action
     - formrequest: Validation rules with custom messages
     - controller: Thin controller using Action/Service classes
     - resource: API Resource with conditional relationships
     - routes: Route registration with middleware
     - tests: Pest tests for this layer
  2. VALIDATE layer:
     - Run: php artisan test --filter={layer}
     - Check: No N+1 (preventLazyLoading catches these)
     - Check: No mass assignment vulnerabilities
  3. IF validation fails → fix before proceeding to next layer
  4. COMMIT: "laravel: {feature} — {layer} layer"
  5. current_layer += 1

EXIT when all layers complete and tests pass
```

## Multi-Agent Dispatch
For large Laravel features spanning multiple domains:
```
DISPATCH parallel agents (one per domain):

Agent 1 (worktree: laravel-models):
  - Models, migrations, factories, seeders
  - Scope: app/Models/, database/
  - Output: Eloquent models with relationships and factories

Agent 2 (worktree: laravel-api):
  - Controllers, Form Requests, API Resources, Routes
  - Scope: app/Http/, routes/
  - Output: Complete API layer

Agent 3 (worktree: laravel-services):
  - Action classes, Service classes, Events, Jobs, Listeners
  - Scope: app/Actions/, app/Services/, app/Events/, app/Jobs/
  - Output: Business logic with async processing

Agent 4 (worktree: laravel-tests):
  - Pest test suite covering all layers
  - Scope: tests/
  - Output: Feature + Unit tests with factories

MERGE ORDER: models → services → api → tests
CONFLICT RESOLUTION: models branch owns migrations and model definitions
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Laravel setup workflow |
| `--api` | API-only Laravel application |
| `--auth sanctum` | Configure Sanctum auth |
| `--auth passport` | Configure Passport OAuth2 |
| `--queue redis` | Configure Redis queue with Horizon |
| `--model <name>` | Generate model with best practices |
| `--events` | Set up event-driven architecture |
| `--broadcast` | Configure real-time broadcasting |
| `--test` | Generate Pest test suite |
| `--optimize` | Find and fix N+1 and slow queries |
| `--upgrade <version>` | Upgrade Laravel version with guide |
| `--audit` | Audit existing Laravel app for anti-patterns |

## Output Format

End every Laravel skill invocation with this summary block:

```
LARAVEL RESULT:
Action: <scaffold | model | controller | service | policy | optimize | test | audit | upgrade>
Files created/modified: <N>
Models created/modified: <N>
Controllers created/modified: <N>
Migrations created: <N>
Tests passing: <yes | no | skipped>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Append one TSV row to `.godmode/laravel.tsv` after each invocation:

```
timestamp	project	action	files_count	models_count	controllers_count	migrations_count	tests_status	notes
```

Field definitions:
- `timestamp`: ISO-8601 UTC
- `project`: directory name from `basename $(pwd)`
- `action`: scaffold | model | controller | service | policy | optimize | test | audit | upgrade
- `files_count`: number of files created or modified
- `models_count`: number of Eloquent models created or modified
- `controllers_count`: number of controllers created or modified
- `migrations_count`: number of migrations generated
- `tests_status`: passing | failing | skipped | none
- `notes`: free-text, max 120 chars, no tabs

If `.godmode/` does not exist, create it and add `.godmode/` to `.gitignore` if not already present.

## Success Criteria

Every Laravel skill invocation must pass ALL of these checks before reporting success:

1. `php artisan test` passes if test suite exists
2. No Eloquent models returned directly from controllers (use API Resources)
3. No business logic in controllers (use Action or Service classes)
4. All models use explicit `$fillable` (no `$guarded = []`)
5. All form validation uses Form Request classes (no inline validation)
6. Heavy work dispatched to queues (email, PDF, payment, external APIs)
7. `preventLazyLoading` enabled in AppServiceProvider (development)
8. No `env()` calls outside config files (use `config()` helper)
9. All endpoints have authorization (Policies or Gates)
10. All migrations are consistent (`php artisan migrate:status`)

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Error Recovery

When errors occur, follow these remediation steps:

```
IF php artisan test fails:
  1. Check that test database is configured in phpunit.xml
  2. Verify RefreshDatabase or DatabaseTransactions trait is used
  3. Check that factories produce valid model instances
  4. Verify that environment-specific config is mocked in tests

IF migration fails:
  1. Check for column type conflicts with existing data
  2. Verify foreign key references exist before adding constraints
  3. For large tables, use batched operations to avoid lock timeouts
  4. Never edit deployed migrations — create new corrective migrations

IF N+1 query detected (preventLazyLoading):
  1. Add with() eager loading to the query
  2. Use withCount() for count-only relationships
  3. Use load() for conditional post-query loading
  4. Verify with Laravel Debugbar that query count decreased

IF queue job fails:
  1. Check that job class is serializable (no closures, no unserializable properties)
  2. Verify queue connection is configured and running
  3. Add retry logic with backoff: $backoff = [60, 300, 900]
  4. Implement failed() method for error notification

IF authorization errors:
  1. Verify Policy is registered in AuthServiceProvider
  2. Check that Gate definitions match the method signatures
  3. Verify middleware is applied to route groups
  4. Test with actingAs() in feature tests
```

## Anti-Patterns

- **Do NOT return Eloquent models from controllers.** Use API Resources. Models carry hidden state, relationships, and database details that should never leak to the API.
- **Do NOT put business logic in controllers.** Controllers receive a request and return a response. Business logic belongs in Action classes or Service classes.
- **Do NOT use `$guarded = []`.** Explicitly define `$fillable` on every model. Mass assignment vulnerabilities are real.
- **Do NOT skip Form Requests.** Inline validation in controllers is unmaintainable. Form Requests are reusable, testable, and self-documenting.
- **Do NOT process heavy work synchronously.** Email, PDF generation, payment processing, and external API calls must be queued.
- **Do NOT ignore `preventLazyLoading`.** Enable it in development. Every N+1 query is a production performance bug waiting to happen.
- **Do NOT hardcode configuration.** Use `.env` variables and `config()` helper. Never reference `env()` outside of config files.
- **Do NOT skip authorization.** Every endpoint must check Policies or Gates. An unauthorized endpoint is a security vulnerability, not a missing feature.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run Laravel tasks sequentially: models, then API, then services, then tests.
- Use branch isolation per task: `git checkout -b godmode-laravel-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
