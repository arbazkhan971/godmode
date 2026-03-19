# /godmode:laravel

Build, configure, and optimize Laravel applications. Covers Eloquent ORM patterns, service container, facades, contracts, queue system, events, broadcasting, Sanctum/Passport authentication, and testing with PHPUnit and Pest.

## Usage

```
/godmode:laravel                           # Full Laravel setup workflow
/godmode:laravel --api                     # API-only Laravel application
/godmode:laravel --auth sanctum            # Configure Sanctum auth (SPA + tokens)
/godmode:laravel --auth passport           # Configure Passport OAuth2 server
/godmode:laravel --queue redis             # Configure Redis queue with Horizon
/godmode:laravel --model Order             # Generate model with best practices
/godmode:laravel --events                  # Set up event-driven architecture
/godmode:laravel --broadcast               # Configure real-time broadcasting
/godmode:laravel --test                    # Generate Pest test suite
/godmode:laravel --optimize                # Find and fix N+1 and slow queries
/godmode:laravel --upgrade 11              # Upgrade Laravel version
/godmode:laravel --audit                   # Audit existing app for anti-patterns
```

## What It Does

1. Assesses project requirements and selects architecture (Blade+Livewire, Inertia, API-only)
2. Configures Eloquent models with relationships, scopes, casts, and PHP 8.1+ backed enums
3. Designs service layer with contracts (interfaces), Action classes, DTOs, and service providers
4. Sets up queue system with Redis/database driver, job middleware, retry policies, and monitoring
5. Implements event-driven architecture with events, listeners, and real-time broadcasting
6. Configures Sanctum or Passport authentication with Policies for authorization
7. Generates comprehensive Pest test suite with factories, fake facades, and assertion helpers
8. Validates against 15 Laravel best-practice checks

## Output
- Configured Laravel application with selected components
- Eloquent models with relationships, scopes, and casts
- API controllers with Resources and Form Requests
- Service layer with contracts, Actions, and DTOs
- Queued jobs with retry policies and monitoring
- Events and listeners for side effects
- Pest test suite with factories
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"laravel: <app> — <N> models, <M> endpoints, Eloquent, Pest"`

## Next Step
After Laravel setup: `/godmode:test` for more coverage, `/godmode:secure` for security audit, or `/godmode:deploy` for Forge/Vapor deployment.

## Examples

```
/godmode:laravel Build an e-commerce API
/godmode:laravel --auth sanctum Set up SPA + mobile token auth
/godmode:laravel --queue redis Configure background job processing
/godmode:laravel --events Set up event-driven order processing
/godmode:laravel --optimize Our order listing page is slow
/godmode:laravel --audit Check our Laravel app for anti-patterns
```
