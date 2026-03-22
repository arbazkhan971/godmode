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
| Decision | Choice & Justification |
|---|---|
| Full-stack vs API-only | Blade+Livewire: Server-rendered |
|  | Inertia: SPA feel, Vue/React |
|  | API-only: Separate frontend |
| Auth starter kit | Breeze: Simple, Blade/Inertia |
|  | Jetstream: Full-featured, teams |
| API auth | Sanctum: SPA + mobile tokens |
|  | Passport: Full OAuth2 server |
| Queue driver | Redis: Fast, reliable, standard |
|  | Database: No Redis dependency |
| Real-time | Reverb: Laravel native WS |
| Testing | Pest: Modern, expressive syntax |
|  | PHPUnit: Standard, full control |
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
# ... (condensed)
```

```
ELOQUENT QUERY OPTIMIZATION:
| Pattern | Usage |
|---|---|
| with('relation') | Eager load (prevent N+1) |
| load('relation') | Lazy eager load (post-query) |
| withCount('relation') | Count without loading |
| select('col1', 'col2') | Reduce memory footprint |
| pluck('column') | Extract array of values |
| chunk(1000, fn) | Process large datasets |
| chunkById(1000, fn) | Safe chunking with mutations |
| lazy() | Lazy collection (memory safe) |
| cursor() | One-by-one streaming |
| whereHas('relation', fn) | Filter by relationship |
| withWhereHas('relation', fn) | Eager load + filter combined |
| upsert(data, unique, update) | Bulk insert/update |
| Model::query()->toSql() | Debug query output |
```

```php
// Controller with optimized queries
class OrderController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $orders = Order::query()
# ... (condensed)
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
# ... (condensed)
```

```
SERVICE ARCHITECTURE:
| Pattern | When to Use |
|---|---|
| Action classes (single method) | Complex operations (CreateOrder) |
| Service classes (multiple methods) | Related operations (OrderService) |
| Repository pattern | Abstract data access layer |
| DTOs (Data Transfer Objects) | Typed input/output structures |
| Contracts (interfaces) | Swappable implementations |
| Service Providers | Binding interfaces to concrete |
| Facades | Static-like access to services |
| Pipeline pattern | Sequential processing steps |
```

Rules:
- Bind interfaces (contracts) in service providers — swap implementations for testing
- Use Action classes for complex single operations — one public method: `execute()`
- Use DTOs instead of arrays for passing structured data between layers
- Constructor injection over facade usage in application code — facades are for convenience, DI is for testability
- Use `DB::transaction()` for operations requiring atomicity

### Step 4: Queue System, Events & Broadcasting
Handle async work and real-time updates:

```php
// Job with retry, backoff, and middleware
class ProcessOrderPayment implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;
    use Batchable; // For batch processing

# ... (condensed)
```

```
ASYNC ARCHITECTURE:
| Component | Purpose |
|---|---|
| Jobs (ShouldQueue) | Async task processing |
| Events + Listeners | Decoupled event handling |
| Notifications | Multi-channel alerts |
| Broadcasting (ShouldBroadcast) | Real-time via WebSocket |
| Mail (Mailable + queue) | Email sending |
| Job Batches | Group related jobs |
| Job Chains | Sequential job execution |
| Rate Limiting (middleware) | Throttle job execution |
| Unique Jobs (ShouldBeUnique) | Prevent duplicate processing |

```

Rules:
- Jobs MUST stay idempotent — safe to retry without side effects
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
# ... (condensed)
```

```
AUTH ARCHITECTURE:
| Auth Method | When to Use |
|---|---|
| Sanctum (SPA mode) | SPA with same-domain backend |
| Sanctum (token mode) | Mobile apps, third-party tokens |
| Passport | Full OAuth2 server needed |
| Breeze | Simple auth scaffolding |
| Jetstream | Auth + teams + 2FA + API tokens |
| Socialite | OAuth social login providers |

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
# ... (condensed)
```

```php
// Factory with states
class OrderFactory extends Factory
{
    protected $model = Order::class;

    public function definition(): array
# ... (condensed)
```

```
TESTING STRATEGY:
| Layer | Approach |
|---|---|
| Models | Pest + Factories + Assertions |
| API endpoints | Pest + Sanctum::actingAs |
| Jobs/Listeners | Pest + Queue::fake + Event::fake |
| Services/Actions | Pest + Mockery for dependencies |
| Policies | Pest + authorize assertions |
| Validation | Pest + assertUnprocessable |
| Browser/E2E | Laravel Dusk (Selenium) |
| Mail | Mail::fake + assertQueued |
| Notifications | Notification::fake |

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
| Check | Status | Notes |
|---|---|---|
| N+1 prevention (preventLazyLoading) | PASS | Enabled in dev |
| Eager loading on all endpoints | PASS | with() used |
| API Resources (no raw models) | PASS | JsonResource used |
| Form Requests for validation | PASS | No inline rules |
| Policies for authorization | PASS | All endpoints gated |
| Jobs idempotent with backoff | PASS | Retry-safe |
| Events for side effects | PASS | Decoupled listeners |
| Config cached for production | PASS | config:cache |
| Routes cached for production | PASS | route:cache |
| Environment variables validated | PASS | No missing env vars |
| Database indexes on FKs | PASS | All foreign keys |
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
5. **Keep jobs idempotent.** The queue retries failed jobs. Design them so that running twice produces the same result as running once.
6. **Pest for testing.** Pest's expressive syntax makes tests readable and maintainable. Use fake facades to isolate side effects.
7. **Cache everything in production.** Run `config:cache`, `route:cache`, `view:cache`, and `event:cache` in production. The performance difference is significant.

## HARD RULES
1. NEVER return raw Eloquent models from controllers — always use API Resources (JsonResource).
2. NEVER use `$guarded = []` — explicitly define `$fillable` on every model. Mass assignment vulnerabilities are real.
3. NEVER put business logic in controllers — controllers receive requests and return responses. Logic belongs in Action/Service classes.
4. NEVER use inline validation in controllers — use Form Request classes. They are reusable, testable, and self-documenting.
5. NEVER process heavy work synchronously — queue email, PDF, payments, and external API calls.
6. NEVER reference `env()` outside config files — use `config()` helper in application code.
7. NEVER skip authorization — every endpoint must check Policies or Gates. No exceptions.
8. ALWAYS enable `Model::preventLazyLoading()` in development — catch N+1 queries before production.
9. ALWAYS use `DB::transaction()` for operations requiring atomicity.
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
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Laravel setup workflow |
| `--api` | API-only Laravel application |
| `--auth sanctum` | Configure Sanctum auth |

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

Log every invocation to `.godmode/` as TSV. Create on first run.

```
timestamp	project	action	files_count	models_count	controllers_count	migrations_count	tests_status	notes
```

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

IF php artisan test fails:
  1. Check that test database is configured in phpunit.xml
IF migration fails:
  1. Check for column type conflicts with existing data
IF N+1 query detected (preventLazyLoading):
  1. Add with() eager loading to the query
IF queue job fails:
  1. Check that job class is serializable (no closures, no unserializable properties)
IF authorization errors:
  1. Verify Policy is registered in AuthServiceProvider

## Laravel Optimization Loop

Run this systematic audit when optimizing an existing Laravel application:

```
LARAVEL OPTIMIZATION PASSES:

Pass 1 — Eloquent Query Optimization:
  1. Enable Model::preventLazyLoading() in AppServiceProvider::boot()
  2. Baseline query count per endpoint with Debugbar
  3. Fix N+1: add with(), withCount(), withWhereHas() for eager loading
  4. Replace create() loops with insert()/upsert() for bulk operations
  5. Use chunk()/chunkById() for large dataset processing

Pass 2 — Queue Processing:
  1. Catalog all queued jobs with queue, avg time, retries
  2. Set explicit $tries, $timeout, $backoff on every job
  3. Add uniqueId() to prevent duplicate jobs, failed() for error notification
  4. Enable after_commit on queue connection
  5. Scale workers per queue priority with Horizon
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

