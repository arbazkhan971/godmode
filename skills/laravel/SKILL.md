---
name: laravel
description: |
  Laravel mastery skill. Eloquent ORM, service container,
  queues, events, Sanctum/Passport auth, Pest testing.
  Triggers on: /godmode:laravel, "laravel app",
  "eloquent", "artisan", "blade".
---

# Laravel — Laravel Mastery

## Activate When
- User invokes `/godmode:laravel`
- User says "build a Laravel app", "Laravel API"
- User asks about Eloquent, Blade, Livewire, queues
- When working with PHP backend using Laravel

## Workflow

### Step 1: Project Assessment

```bash
# Detect Laravel version
php artisan --version 2>/dev/null
php -v | head -1

# Check for common issues
php artisan route:list --json | wc -l
php artisan config:show app.debug 2>/dev/null
```

```
LARAVEL ASSESSMENT:
Laravel: <11.x>, PHP: <8.3.x>
Architecture: Full-stack (Blade) | API-only | Inertia
Database: MySQL | PostgreSQL | SQLite
Queue: Redis | Database | SQS
Auth: Sanctum | Passport | Breeze | Jetstream

IF PHP < 8.2: recommend upgrade (performance + types)
IF using $guarded = []: switch to explicit $fillable
IF no preventLazyLoading: enable in AppServiceProvider
```

### Step 2: Eloquent ORM Patterns

```
QUERY OPTIMIZATION:
| Pattern                | Usage              |
|------------------------|--------------------|
| with('relation')       | Eager load (N+1)   |
| withCount('relation')  | Count without load  |
| select('col1','col2')  | Reduce memory       |
| chunk(1000, fn)        | Large datasets      |
| cursor()               | One-by-one stream   |

THRESHOLDS:
  N+1 tolerance: 0 (use preventLazyLoading)
  chunk size: 1000 records per batch
  Model::all() in production: NEVER
  IF query count > 10 per request: audit with Debugbar
```

```
RULES:
  Always with() for displayed relationships
  Always use API Resources (never raw models)
  Always backed enums for status fields (PHP 8.1+)
  Always index foreign keys and WHERE columns
  IF processing > 100 records: use chunk/cursor
```

### Step 3: Service Container & Architecture

```
SERVICE ARCHITECTURE:
| Pattern             | When to Use          |
|---------------------|---------------------|
| Action classes      | Complex single ops   |
| Service classes     | Related operations   |
| Repository pattern  | Abstract data access |
| DTOs                | Typed input/output   |
| Contracts           | Swappable impls      |
| Pipelines           | Sequential steps     |

RULES:
  Bind interfaces in service providers
  Action classes: one public method (execute)
  Constructor injection over facades
  DB::transaction() for atomicity
  IF business logic in controller: extract to service
```

### Step 4: Queue System & Events

```php
// Job with retry configuration
class ProcessPayment implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue,
        Queueable, SerializesModels;

    public $tries = 3;
    public $backoff = [10, 60, 300]; // seconds
    public $timeout = 120;
}
```

```
ASYNC RULES:
  Jobs MUST be idempotent (safe to retry)
  Use $backoff array for exponential backoff
  Use WithoutOverlapping for same-entity ops
  Use ShouldBeUnique to prevent duplicates
  Events for side effects (email, notification)
  IF job runs > 30s: consider breaking into chain

THRESHOLDS:
  Job timeout: 120s default, 300s max
  Retry attempts: 3 (with backoff)
  Queue monitoring: Horizon for Redis
  IF queue depth > 1000: scale workers
```

### Step 5: Authentication

```
AUTH SELECTION:
| Method       | When to Use              |
|-------------|--------------------------|
| Sanctum SPA | Same-domain SPA          |
| Sanctum token| Mobile, third-party     |
| Passport     | Full OAuth2 server       |
| Breeze       | Simple auth scaffold     |
| Jetstream    | Auth + teams + 2FA       |

RULES:
  Every endpoint must check Policy or Gate
  Authorization bugs are security bugs
  IF API + SPA: Sanctum stateful cookies
  IF API + mobile: Sanctum token-based
```

### Step 6: Testing with Pest

```bash
# Run tests
php artisan test --parallel

# Run with coverage
php artisan test --coverage --min=80
```

```
TESTING STRATEGY:
| Layer        | Approach                 |
|-------------|--------------------------|
| Models       | Pest + Factories         |
| API          | Pest + actingAs          |
| Jobs         | Queue::fake + assertions |
| Events       | Event::fake              |
| Policies     | authorize assertions     |
| Validation   | assertUnprocessable      |

RULES:
  Use RefreshDatabase (wraps in transactions)
  Use factory states for variations
  Test authorization in every endpoint test
  assertDatabaseHas for persistence verification
  IF coverage < 80%: add tests for uncovered routes

THRESHOLDS:
  Coverage target: >= 80% overall
  Endpoint coverage: 100% of routes
  IF test suite > 60s: enable --parallel
```

### Step 7: Validation & Delivery

```
LARAVEL VALIDATION:
| Check                         | Status |
|-------------------------------|--------|
| preventLazyLoading enabled    | ?      |
| Eager loading on endpoints    | ?      |
| API Resources (no raw models) | ?      |
| Form Requests for validation  | ?      |
| Policies on all endpoints     | ?      |
| Jobs idempotent with backoff  | ?      |
| Config cached for production  | ?      |
| Routes cached for production  | ?      |
```

Commit: `"laravel: <app> — <N> models,
  <M> endpoints, Pest"`


```bash
# Laravel development and testing
php artisan test --parallel
php artisan route:list --compact
composer audit
```

```bash
# Laravel testing and auditing
php artisan test --parallel
composer audit
curl -s http://localhost:8000/health
```

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Laravel conventions first.**
2. **API Resources always.** Never return raw models.
3. **Prevent lazy loading** in development.
4. **Events for side effects.**
5. **Keep jobs idempotent.**
6. **Pest for testing.**
7. **Cache everything in production:**
   config:cache, route:cache, view:cache.

## HARD RULES

1. Never return raw Eloquent models from controllers.
2. Never use $guarded = [] — explicit $fillable only.
3. Never put business logic in controllers.
4. Never use inline validation — Form Request classes.
5. Never process heavy work synchronously — queue it.
6. Never reference env() outside config files.
7. Never skip authorization on any endpoint.
8. Always enable preventLazyLoading in development.
9. Always use DB::transaction() for atomicity.
10. Always use backed enums for status fields.

## Auto-Detection
```
1. Laravel: artisan file, composer.json laravel/framework
2. PHP: composer.json require.php version
3. Architecture: routes/web.php, routes/api.php
```

## Output Format
Print: `Laravel: {action}, {models} models,
  {endpoints} endpoints. Tests: {status}.
  Verdict: {verdict}.`

## TSV Logging
```
timestamp	project	models	controllers	migrations	tests	status
```

## Keep/Discard Discipline
```
KEEP if: tests pass AND quality improved
DISCARD if: tests fail OR performance regressed
```

## Stop Conditions
```
STOP when ANY of:
  - All tasks complete and validated
  - User requests stop
  - Max iterations reached
```

<!-- tier-3 -->

## Error Recovery
- Test fails: check phpunit.xml test DB config.
- Migration fails: check column type conflicts.
- N+1: add with() eager loading.
- Queue job fails: check serializability.
- Auth errors: verify Policy registration.

