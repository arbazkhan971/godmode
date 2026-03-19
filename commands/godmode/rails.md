# /godmode:rails

Build, configure, and optimize Ruby on Rails applications. Covers Rails conventions, ActiveRecord patterns, query optimization, Hotwire (Turbo and Stimulus), background jobs (Sidekiq, Solid Queue), and testing with RSpec and FactoryBot.

## Usage

```
/godmode:rails                             # Full Rails setup workflow
/godmode:rails --api                       # API-only Rails application
/godmode:rails --hotwire                   # Configure Hotwire (Turbo + Stimulus)
/godmode:rails --auth                      # Set up authentication (Devise or built-in)
/godmode:rails --jobs sidekiq              # Configure Sidekiq for background jobs
/godmode:rails --jobs solid_queue          # Configure Solid Queue (Rails 8)
/godmode:rails --model Order               # Generate model with best practices
/godmode:rails --optimize                  # Find and fix N+1 queries
/godmode:rails --test                      # Generate RSpec + FactoryBot test suite
/godmode:rails --upgrade 8.0               # Upgrade Rails version
/godmode:rails --audit                     # Audit existing app for anti-patterns
/godmode:rails --deploy kamal              # Configure Kamal deployment
```

## What It Does

1. Assesses project requirements and selects architecture (full-stack Hotwire, API-only, hybrid)
2. Enforces Rails conventions rigorously (naming, structure, RESTful routes)
3. Configures ActiveRecord with optimized queries, eager loading, and strict_loading
4. Sets up Hotwire with Turbo Frames for partial updates and Turbo Streams for real-time
5. Configures background jobs with Sidekiq or Solid Queue, including queues, retries, and monitoring
6. Generates comprehensive test suite (RSpec model specs, request specs, system specs with Capybara)
7. Sets up FactoryBot factories with traits and transient attributes
8. Validates against 15 Rails best-practice checks

## Output
- Configured Rails application with selected components
- Models with associations, validations, scopes, and concerns
- RESTful controllers with strong parameters
- Views with Hotwire (Turbo Frames + Streams) or API serializers
- Background jobs with retry policies
- RSpec test suite with FactoryBot factories
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"rails: <app> — <N> models, <M> controllers, Hotwire, RSpec"`

## Next Step
After Rails setup: `/godmode:test` for more coverage, `/godmode:optimize` for performance tuning, or `/godmode:deploy` for Kamal/Docker deployment.

## Examples

```
/godmode:rails Build a project management app
/godmode:rails --api Build a JSON API for a mobile app
/godmode:rails --hotwire Add real-time updates to our task board
/godmode:rails --optimize Our order listing page is slow
/godmode:rails --audit Check our Rails app for anti-patterns
/godmode:rails --upgrade 8.0 Migrate from Rails 7.1 to 8.0
```
