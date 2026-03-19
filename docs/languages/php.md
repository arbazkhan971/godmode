# PHP/Laravel Developer Guide

How to use Godmode's full workflow for PHP and Laravel projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects PHP via composer.json, artisan, or index.php
# Test: php artisan test / ./vendor/bin/phpunit
# Lint: ./vendor/bin/pint --test / ./vendor/bin/phpstan analyse
# Build: composer install --no-dev --optimize-autoloader
```

### Example `.godmode/config.yaml`
```yaml
language: php
framework: laravel             # or symfony, slim, etc.
test_command: php artisan test --parallel
lint_command: ./vendor/bin/pint --test && ./vendor/bin/phpstan analyse --level=max
format_command: ./vendor/bin/pint
build_command: composer install --no-dev --optimize-autoloader
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/api/health
```

---

## How Each Skill Applies to PHP

### THINK Phase

| Skill | PHP Adaptation |
|-------|---------------|
| **think** | Design interfaces, DTOs, and enums first. A PHP spec should define the contract layer with `interface` types, readonly DTOs (PHP 8.2+), and backed enums. Include strict types declaration and return type annotations. |
| **predict** | Expert panel evaluates Laravel architecture, query performance (Eloquent N+1), and caching strategy. Request panelists with PHP depth (e.g., Laravel core contributor, Symfony maintainer). |
| **scenario** | Explore edge cases around null coalescing, exception hierarchies, queue failure modes, database transaction boundaries, and file upload validation. |

### BUILD Phase

| Skill | PHP Adaptation |
|-------|---------------|
| **plan** | Each task specifies classes and namespaces. File paths follow Laravel conventions (`app/Services/UserService.php`). Tasks note which service providers, routes, and migrations are affected. |
| **build** | TDD with PHPUnit. RED step writes a test class with `@test` annotation or `test_` prefix. GREEN step implements the class. REFACTOR step extracts value objects, applies strict types, and uses PHP 8.2+ features. |
| **test** | Use PHPUnit with feature and unit test separation. Use `RefreshDatabase` trait for database tests. Mock external services with `Http::fake()` and `Queue::fake()`. |
| **review** | Check for missing `declare(strict_types=1)`, N+1 queries, mass assignment vulnerabilities, missing validation rules, and improper error handling with bare `catch`. |

### OPTIMIZE Phase

| Skill | PHP Adaptation |
|-------|---------------|
| **optimize** | Target response time, memory usage, or queue throughput. Guard rail: `php artisan test` must pass on every iteration. Use Laravel Telescope or Debugbar data to guide hypotheses. |
| **debug** | Use Xdebug, Laravel Telescope, or Debugbar. Check for common PHP/Laravel pitfalls: N+1 queries, eager loading misuse, missing indexes, serialization bottlenecks. |
| **fix** | Autonomous fix loop handles test failures, static analysis errors, and format violations. Guard rail: `php artisan test && ./vendor/bin/phpstan analyse && ./vendor/bin/pint --test`. |
| **secure** | Audit with `composer audit`. Check for SQL injection in raw queries, mass assignment vulnerabilities, XSS in Blade templates (unescaped `{!! !!}`), CSRF token misuse, and insecure file uploads. |

### SHIP Phase

| Skill | PHP Adaptation |
|-------|---------------|
| **ship** | Pre-flight: `php artisan test && ./vendor/bin/phpstan analyse && ./vendor/bin/pint --test`. Verify migrations run cleanly and config cache builds. |
| **finish** | Ensure version is updated. Verify `.env.example` is current. Confirm `composer.lock` is committed. Run `php artisan config:cache && php artisan route:cache` for production. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| Tests pass | `php artisan test 2>&1 \| grep 'Tests:'` | All passed |
| Static analysis | `./vendor/bin/phpstan analyse --level=max 2>&1 \| tail -1` | 0 errors |
| Code style | `./vendor/bin/pint --test 2>&1; echo $?` | exit code 0 |
| Test coverage | `php artisan test --coverage --min=80 2>&1 \| grep 'Total'` | >= 80% |
| Dependency vulnerabilities | `composer audit 2>&1 \| grep 'Found'` | 0 |
| Response time | `curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/api/health` | < 0.05s |
| Query count per request | Laravel Debugbar or Telescope | Project-specific |
| Memory usage | `php -d memory_limit=-1 -r "echo memory_get_peak_usage(true);"` | Project-specific |

---

## Common Verify Commands

### Tests pass
```bash
php artisan test --parallel
# or
./vendor/bin/phpunit
```

### Static analysis clean
```bash
./vendor/bin/phpstan analyse --level=max
```

### Code style check
```bash
./vendor/bin/pint --test
```

### Security audit
```bash
composer audit
```

### Route list (sanity check)
```bash
php artisan route:list --compact
```

### Migration status
```bash
php artisan migrate:status
```

### API responds
```bash
curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/api/health
```

---

## Tool Integration

### PHPUnit

Godmode's TDD cycle maps directly to PHPUnit:

```bash
# RED step: run single test class, expect failure
php artisan test --filter=UserServiceTest

# GREEN step: run single test, expect pass
php artisan test --filter=UserServiceTest

# After GREEN: run full suite to catch regressions
php artisan test --parallel

# Coverage
php artisan test --coverage --min=80
```

**Test patterns** for Godmode projects:
```php
// tests/Unit/Services/UserServiceTest.php
<?php

declare(strict_types=1);

namespace Tests\Unit\Services;

use App\Models\User;
use App\Repositories\UserRepositoryInterface;
use App\Services\UserService;
use App\Exceptions\UserNotFoundException;
use Mockery;
use Tests\TestCase;

class UserServiceTest extends TestCase
{
    private UserRepositoryInterface $mockRepository;
    private UserService $sut;

    protected function setUp(): void
    {
        parent::setUp();
        $this->mockRepository = Mockery::mock(UserRepositoryInterface::class);
        $this->sut = new UserService($this->mockRepository);
    }

    public function test_get_user_returns_user_when_found(): void
    {
        $user = new User(['id' => '123', 'name' => 'Alice']);
        $this->mockRepository
            ->shouldReceive('findById')
            ->once()
            ->with('123')
            ->andReturn($user);

        $result = $this->sut->getUser('123');

        $this->assertEquals('Alice', $result->name);
    }

    public function test_get_user_throws_when_not_found(): void
    {
        $this->mockRepository
            ->shouldReceive('findById')
            ->once()
            ->with('missing')
            ->andReturnNull();

        $this->expectException(UserNotFoundException::class);

        $this->sut->getUser('missing');
    }
}
```

**Feature test** with database:
```php
// tests/Feature/Api/UserEndpointTest.php
<?php

declare(strict_types=1);

namespace Tests\Feature\Api;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class UserEndpointTest extends TestCase
{
    use RefreshDatabase;

    public function test_list_users_returns_paginated_response(): void
    {
        User::factory()->count(25)->create();

        $response = $this->getJson('/api/users');

        $response->assertOk()
            ->assertJsonStructure([
                'data' => [['id', 'name', 'email']],
                'meta' => ['current_page', 'total'],
            ])
            ->assertJsonCount(15, 'data'); // default pagination
    }

    public function test_create_user_validates_required_fields(): void
    {
        $response = $this->postJson('/api/users', []);

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['name', 'email']);
    }
}
```

### PHPStan

Guard rail configuration for Godmode projects:

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: php artisan test --parallel
    expect: exit code 0
  - command: ./vendor/bin/phpstan analyse --level=max
    expect: exit code 0
  - command: ./vendor/bin/pint --test
    expect: exit code 0
```

**PHPStan configuration** (`phpstan.neon`):
```neon
parameters:
    level: max
    paths:
        - app
        - tests
    ignoreErrors: []
    checkMissingIterableValueType: true
    checkGenericClassInNonGenericObjectType: true
includes:
    - vendor/larastan/larastan/extension.neon
```

### Laravel Pint

```bash
# Check formatting (guard rail)
./vendor/bin/pint --test

# Auto-fix formatting during refactor step
./vendor/bin/pint

# With preset
./vendor/bin/pint --preset laravel
```

**Pint configuration** (`pint.json`):
```json
{
    "preset": "laravel",
    "rules": {
        "declare_strict_types": true,
        "final_class": true,
        "void_return": true,
        "strict_comparison": true
    }
}
```

---

## Framework Integration

### Laravel Architecture

```yaml
# .godmode/config.yaml
framework: laravel
test_command: php artisan test --parallel
lint_command: ./vendor/bin/pint --test && ./vendor/bin/phpstan analyse --level=max
build_command: composer install --no-dev --optimize-autoloader
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/api/health
```

Laravel-specific THINK considerations:
- Service layer architecture (Controllers -> Services -> Repositories)
- Eloquent model design with relationships, scopes, and casts
- Form Request validation with custom rules
- Event/Listener decoupling for side effects
- Queue job design with retries and failure handling
- API Resource transformers for response shaping

Laravel-specific patterns:
```php
// app/Services/OrderService.php
<?php

declare(strict_types=1);

namespace App\Services;

use App\DTOs\CreateOrderDTO;
use App\Events\OrderCreated;
use App\Models\Order;
use App\Repositories\OrderRepositoryInterface;
use Illuminate\Support\Facades\DB;

final class OrderService
{
    public function __construct(
        private readonly OrderRepositoryInterface $repository,
    ) {}

    public function createOrder(CreateOrderDTO $dto): Order
    {
        return DB::transaction(function () use ($dto): Order {
            $order = $this->repository->create($dto);

            // Side effects handled via events
            event(new OrderCreated($order));

            return $order;
        });
    }
}
```

```php
// app/DTOs/CreateOrderDTO.php
<?php

declare(strict_types=1);

namespace App\DTOs;

final readonly class CreateOrderDTO
{
    public function __construct(
        public string $userId,
        public array $items,
        public string $shippingAddress,
        public ?string $couponCode = null,
    ) {}

    public static function fromRequest(array $validated): self
    {
        return new self(
            userId: $validated['user_id'],
            items: $validated['items'],
            shippingAddress: $validated['shipping_address'],
            couponCode: $validated['coupon_code'] ?? null,
        );
    }
}
```

### Composer Dependency Management

```bash
# Install dependencies
composer install

# Add a package
composer require laravel/sanctum

# Add a dev package
composer require --dev phpstan/phpstan

# Update dependencies
composer update

# Check for outdated packages
composer outdated --direct

# Security audit
composer audit

# Optimize autoloader for production
composer install --no-dev --optimize-autoloader
```

### Queue and Job Patterns

```php
// app/Jobs/ProcessOrderJob.php
<?php

declare(strict_types=1);

namespace App\Jobs;

use App\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

final class ProcessOrderJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 60;
    public int $timeout = 120;

    public function __construct(
        private readonly Order $order,
    ) {}

    public function handle(): void
    {
        // Process the order
    }

    public function failed(\Throwable $exception): void
    {
        // Notify admin of failure
    }
}
```

---

## Deployment with Forge/Vapor

### Laravel Forge

```bash
# Deployment script (configured in Forge)
cd /home/forge/myapp.com
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan queue:restart
```

Godmode ship integration with Forge:
```bash
/godmode:ship --pre-flight "php artisan test && ./vendor/bin/phpstan analyse --level=max" \
  --deploy "forge deploy myapp.com"
```

### Laravel Vapor

```yaml
# vapor.yml
id: 12345
name: my-app
environments:
  production:
    memory: 1024
    cli-memory: 512
    runtime: php-8.3:al2
    build:
      - composer install --no-dev --optimize-autoloader
      - php artisan config:cache
      - php artisan route:cache
    deploy:
      - php artisan migrate --force
    database: my-app-db
    cache: my-app-cache
    queues:
      - default
```

```bash
# Deploy to production
vapor deploy production

# Rollback
vapor rollback production
```

### Docker deployment

```dockerfile
# Dockerfile
FROM php:8.3-fpm AS base
RUN apt-get update && apt-get install -y libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql opcache

FROM base AS build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts
COPY . .
RUN php artisan config:cache && php artisan route:cache

FROM base AS production
WORKDIR /app
COPY --from=build /app .
EXPOSE 9000
CMD ["php-fpm"]
```

---

## Example: Full Workflow for Building a Laravel API

### Scenario
Build an e-commerce API using Laravel with Stripe payments, queue-based order processing, Redis caching, and Forge deployment.

### Step 1: Think (Design)
```
/godmode:think I need an e-commerce API with Laravel — product catalog,
shopping cart, Stripe payment processing, order management with queue-based
fulfillment, Redis caching for product listings, webhook handling for
payment events.
```

Godmode produces a spec at `docs/specs/ecommerce-api.md` containing:
- DTOs: `CreateOrderDTO`, `PaymentIntentDTO`, `ProductFilterDTO`
- Model design: `Product`, `Order`, `OrderItem`, `Payment` with relationships
- Service layer: `OrderService`, `PaymentService`, `CartService`
- Event/Listener pairs: `OrderCreated` -> `ProcessPayment`, `PaymentReceived` -> `FulfillOrder`
- Queue jobs: `ProcessOrderJob`, `SendOrderConfirmationJob`

### Step 2: Build (TDD)
```
/godmode:build
```

**Task 1 — RED:**
```php
// tests/Unit/Services/CartServiceTest.php
public function test_add_item_increases_cart_total(): void
{
    $cart = CartService::create();
    $product = Product::factory()->make(['price' => 2999]);

    $cart->addItem($product, quantity: 2);

    $this->assertEquals(5998, $cart->total());
    $this->assertCount(1, $cart->items());
}
```
Commit: `test(red): Cart service — failing cart calculation tests`

**Task 1 — GREEN:**
Implement `CartService` with item management and total calculation.
Commit: `feat: Cart service — item management with price calculations`

### Step 3: Optimize
```
/godmode:optimize --goal "reduce product listing response time" \
  --verify "curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/api/products" \
  --target "< 0.03"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | N+1 query on categories | Add `with('category')` eager loading | 110ms | 45ms | KEEP |
| 2 | No query caching | Add `Cache::remember()` with 5min TTL | 45ms | 12ms | KEEP |
| 3 | Full model serialization | Use API Resource with sparse fieldsets | 12ms | 10ms | KEEP |

### Step 4: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
php artisan test --parallel   ✓ 67/67 passing
phpstan analyse --level=max   ✓ 0 errors
pint --test                   ✓ 0 changes needed
composer audit                ✓ 0 vulnerabilities
```

---

## PHP-Specific Tips

### 1. Strict types on every file
Add `declare(strict_types=1);` to every PHP file. Godmode's review skill flags files missing this declaration. Strict types prevent silent type coercion bugs.

### 2. Use readonly DTOs over arrays
Replace associative arrays with readonly DTO classes (PHP 8.2+). They provide type safety, IDE autocompletion, and serve as living documentation:
```php
// Instead of passing arrays around
final readonly class CreateUserDTO
{
    public function __construct(
        public string $name,
        public string $email,
        public ?string $phone = null,
    ) {}
}
```

### 3. Prevent N+1 queries from day one
Use `Model::preventLazyLoading()` in development. Godmode's review skill checks for missing eager loading:
```php
// AppServiceProvider.php
public function boot(): void
{
    Model::preventLazyLoading(! $this->app->isProduction());
    Model::preventSilentlyDiscardingAttributes();
    Model::preventAccessingMissingAttributes();
}
```

### 4. Use PHPStan at max level
Start with PHPStan level max and Larastan. Godmode's fix loop can resolve static analysis errors incrementally:
```
/godmode:optimize --goal "increase PHPStan level" --verify "./vendor/bin/phpstan analyse --level=max 2>&1 | tail -1" --target "0 errors"
```

### 5. Separate read and write operations
Use Laravel's query scopes for reads and service methods for writes. This makes caching, testing, and scaling straightforward. Godmode's think skill naturally produces this separation.
