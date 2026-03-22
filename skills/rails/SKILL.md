---
name: rails
description: |
 Ruby on Rails mastery skill. Activates when user needs to build, configure, optimize, or debug Rails applications. Covers Rails conventions, ActiveRecord patterns, query optimization, Hotwire (Turbo and Stimulus), background jobs (Sidekiq, Solid Queue), and testing with RSpec and FactoryBot. Provides opinionated guidance following the Rails Way. Triggers on: /godmode:rails, "rails app", "ruby on rails", "activerecord", "hotwire", "turbo", or when the orchestrator detects Ruby/Rails backend work.
---

# Rails — Ruby on Rails Mastery

## When to Activate
- User invokes `/godmode:rails`
- User says "build a Rails app", "create a Rails API", "set up Rails"
- User asks about ActiveRecord, Hotwire, Turbo, Stimulus, or Sidekiq
- When `/godmode:plan` identifies Rails implementation tasks
- When `/godmode:scaffold` detects a Rails project
- When working with Ruby backend services using Rails framework

## Workflow

### Step 1: Project Assessment & Architecture Decision
Understand the project and choose the right Rails configuration:

```
RAILS ASSESSMENT:
Project: <name and purpose>
Rails version: <latest stable, e.g., 7.2.x or 8.0.x>
Ruby version: <latest stable, e.g., 3.3.x>
Architecture: Full-stack (Hotwire) | API-only | Hybrid
Database: PostgreSQL | MySQL | SQLite (dev only)
Background jobs: Sidekiq | Solid Queue | Good Job | Delayed Job
Real-time: Action Cable | Turbo Streams | None
Auth: Devise | has_secure_password | OmniAuth | Custom
Asset pipeline: Propshaft + Import Maps | esbuild | Vite
CSS: Tailwind | Bootstrap | Vanilla
Deployment: Docker | Kamal | Heroku | AWS/GCP
```

```
RAILS SETUP DECISIONS:
| Decision | Choice & Justification |
|---|---|
| Full-stack vs API-only | Full-stack: Hotwire for interactivity |
|  | API-only: --api flag, JSON responses |
| Database | PostgreSQL for production ALWAYS |
| Background processor | Solid Queue (Rails 8 default) |
|  | Sidekiq (Redis-backed, battle-tested) |
| Real-time | Turbo Streams for live updates |
| Authentication | Rails 8: built-in auth generator |
|  | Rails 7: Devise or custom |
| JavaScript | Import Maps (simple, no build) |
|  | esbuild (if heavy JS needed) |
| CSS | Tailwind (Rails default) |
| Testing | RSpec + FactoryBot + Capybara |
```

Rules:
- ALWAYS use PostgreSQL in production — SQLite is for development and testing only
- For Rails 8, prefer built-in generators for auth, sessions, and background jobs
- Import Maps is the Rails default — only use esbuild/Vite if you need heavy JavaScript frameworks
- Use Solid Queue (Rails 8) or Sidekiq (Rails 7) for background jobs — never process long tasks inline

### Step 2: Rails Conventions & Project Structure
Follow the Rails Way rigorously:

```
RAILS CONVENTIONS:
| Convention | Rule |
|---|---|
| Model naming | Singular, CamelCase (Order) |
| Table naming | Plural, snake_case (orders) |
| Controller naming | Plural, CamelCase (OrdersController) |
| File naming | snake_case (order.rb) |
| Foreign keys | <model>_id (customer_id) |
| Join tables | Alphabetical (labels_orders) |
| Primary keys | id (auto-increment or UUID) |
| Timestamps | created_at, updated_at (auto) |
| Boolean columns | Adjective (active, published) |
| Routes | RESTful resources |
| Partials | _prefix (e.g., _form.html.erb) |
```

Rules:
- Follow Rails conventions religiously — "convention over configuration" is the framework's superpower
- Fat models are an anti-pattern too — extract to service objects, query objects, and concerns
- Use `app/services/` for complex business logic that spans multiple models
- Use `app/queries/` for complex database queries that don't belong in models
- Use concerns sparingly — they should represent genuinely shared behavior, not a dumping ground

### Step 3: ActiveRecord Patterns & Query Optimization
Master the ORM layer:

```ruby
# Model with associations and validations
class Order < ApplicationRecord
 # Associations
 belongs_to :customer
 has_many :order_items, dependent: :destroy
 has_many :products, through: :order_items
```

```
ACTIVERECORD PERFORMANCE PATTERNS:
| Pattern | When to Use |
|---|---|
| includes(:assoc) | Default N+1 prevention |
| preload(:assoc) | Separate queries (large joins) |
| eager_load(:assoc) | Need WHERE on association |
| select(:col1, :col2) | Reduce data transfer |
| pluck(:column) | Extract array of values |
| find_each(batch_size: 1000) | Process large datasets |
| in_batches(of: 1000) | Batch updates/deletes |
| .count /.sum /.average | Database-level aggregation |
| counter_cache: true | Avoid COUNT queries |
| strict_loading! | Detect N+1 in development |
| explain | Analyze query execution plan |
| add_index | Every FK + frequent WHERE cols |
| database views | Complex reporting queries |
```

Rules:
- ALWAYS use `includes` to eager load associations displayed in views/serializers
- Enable `strict_loading` in development/test to catch N+1 queries early
- Use `find_each` or `in_batches` for processing large datasets — never `.all.each`
- Add database indexes on all foreign keys and columns used in WHERE/ORDER BY
- Use `counter_cache` for belongs_to associations where you display counts frequently
- Prefer scopes over class methods for query building — they are composable

### Step 4: Hotwire — Turbo & Stimulus
Build modern, interactive Rails UIs without heavy JavaScript:

```
HOTWIRE ARCHITECTURE:
  Turbo Drive — SPA-like navigation without JavaScript
  Turbo Frames — Update specific page sections independently
  Turbo Streams — Real-time updates via WebSocket or HTTP
  Stimulus — Sprinkle JavaScript behavior on HTML
```

```erb
<!-- Turbo Frame — Independent page section -->
<%= turbo_frame_tag "order_#{@order.id}" do %>
 <div class="order-card">
 <h3><%= @order.title %></h3>
 <p>Status: <%= @order.status %></p>
 <%= link_to "Edit", edit_order_path(@order) %>
 </div>
<% end %>

<!-- Turbo Stream — Real-time update from controller -->
<!-- orders_controller.rb -->
def update
 @order.update!(order_params)
 respond_to do |format|
 format.turbo_stream # renders update.turbo_stream.erb
```

```
HOTWIRE DECISION GUIDE:
| Need | Use |
|---|---|
| SPA-like page transitions | Turbo Drive (automatic) |
| Update one section on click | Turbo Frames |
| Real-time updates to all viewers | Turbo Streams (broadcast) |
| Update page after form submit | Turbo Streams (HTTP response) |
| Toggle visibility, dropdowns | Stimulus controller |
| Form validation, character count | Stimulus controller |
| Complex interactive widget | Stimulus + Turbo Frames |
| Full SPA (React/Vue needed) | Rails API-only + separate SPA |
```

Rules:
- Start with Turbo Drive (it is automatic) — it makes navigation instant with zero code
- Use Turbo Frames before reaching for Stimulus — frames handle most "update this section" needs
- Use Turbo Streams for real-time updates — combine HTTP responses and WebSocket broadcasts
- Keep Stimulus controllers small and focused — one behavior per controller
- If you need heavy client-side state management, Rails API-only + React/Vue is the right call

### Step 5: Background Jobs
Process long-running tasks asynchronously:

```ruby
# Job definition
class OrderConfirmationJob < ApplicationJob
 queue_as :default
 retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
 discard_on ActiveJob::DeserializationError

```

```
BACKGROUND JOB STRATEGY:
| Processor | When to Use |
|---|---|
| Solid Queue (Rails 8) | Default for Rails 8 — DB-backed |
|  | No Redis dependency, simple |
| Sidekiq | High throughput, Redis-backed |
|  | Battle-tested, rich ecosystem |
| Good Job | PostgreSQL-backed, multithreaded |
|  | Good for Heroku, no Redis |

JOB DESIGN RULES:
- Jobs MUST stay idempotent — safe to retry
- Jobs MUST accept simple arguments (IDs, not objects) for serialization
```

### Step 6: Testing with RSpec & FactoryBot
Comprehensive testing strategy:

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
 config.use_transactional_fixtures = true
 config.include FactoryBot::Syntax::Methods
 config.include Devise::Test::IntegrationHelpers, type: :request
 config.include ActiveJob::TestHelper
```

```
TESTING STRATEGY:
| Layer | Approach |
|---|---|
| Models | RSpec + FactoryBot + Shoulda |
| Controllers/Requests | RSpec request specs |
| System/Integration | Capybara + Selenium |
| Services | RSpec unit specs |
| Jobs | ActiveJob::TestHelper |
| Mailers | ActionMailer::TestHelper |
| API | Request specs + JSON assertions |
| Turbo Streams | assert_turbo_stream in requests |

TEST HELPERS:
```

Rules:
- Use `build` over `create` when you don't need database persistence — faster tests
- Use traits in factories for common variations (`:confirmed`, `:with_items`)
- Request specs over controller specs — Rails team recommends request specs
- System specs for critical user flows only — they are slow, keep the suite small
- Use `have_enqueued_job` to test job scheduling without running the job
- Test Turbo Stream responses with `assert_turbo_stream` in request specs

### Step 7: Validation & Delivery
Verify the Rails application:

```
RAILS VALIDATION:
| Check | Status | Notes |
|---|---|---|
| Follows Rails conventions | PASS | Naming, structure |
| N+1 queries eliminated | PASS | includes/preload |
| strict_loading in dev | PASS | Catches lazy loads |
| Database indexes on FKs | PASS | All foreign keys |
| Background jobs idempotent | PASS | Safe to retry |
| Hotwire used appropriately | PASS | Frames + Streams |
| Tests pass (RSpec green) | PASS | Models + requests |
| FactoryBot factories valid | PASS | No orphan factories |
| Credentials managed properly | PASS | Rails credentials |
| Database migrations reversible | PASS | All have down() |
| Strong parameters enforced | PASS | No mass assignment |
```

```
RAILS DELIVERY:

Artifacts:
- Application: <app-name> Rails <version>
- Models: <N> models with associations and validations
- Controllers: <N> RESTful controllers
- Views: <N> views with Hotwire (Turbo Frames + Streams)
- Jobs: <N> background jobs
- Tests: <N> specs passing (models, requests, system)
- Migrations: <N> database migrations
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:test — Increase test coverage
-> /godmode:secure — Security hardening audit
-> /godmode:deploy — Deploy with Kamal or Docker
-> /godmode:optimize — Performance tuning
-> /godmode:observe — Set up monitoring
```

Commit: `"rails: <app> — <N> models, <M> controllers, Hotwire, RSpec"`

## Auto-Detection

Before prompting the user, automatically detect Rails project context:

```
AUTO-DETECT SEQUENCE:
1. Detect Rails version:
 - Gemfile: gem "rails", "~> 8.0" or specific version
 - Gemfile.lock: rails version
 - config/application.rb: Rails version constant
2. Detect Ruby version:
 -.ruby-version file
 - Gemfile: ruby "3.3.x"
3. Detect database:
 - config/database.yml: adapter field (postgresql, mysql2, sqlite3)
 - DATABASE_URL environment variable
4. Detect architecture choices:
 - config/application.rb: config.api_only? -> API mode
 - app/views/ presence -> full-stack
 - app/javascript/controllers/ -> Stimulus installed
```

## Keep/Discard Discipline
Each change either advances the branch or gets reverted.
- **KEEP**: `bin/rails test` (or `rspec`) passes, no new N+1 queries, migrations reversible.
- **DISCARD**: Tests fail, Bullet detects new N+1, or migration is irreversible. Revert immediately.
- **CRASH**: Migration fails mid-run. Write a corrective migration; never edit existing ones.
- Log every action to `.godmode/rails.tsv` with status.

## Stop Conditions
- `bin/rails test` or `bundle exec rspec` passes with zero failures.
- `bin/rails db:migrate:status` shows no pending migrations.
- All `belongs_to` foreign keys have database indexes.
- No `default_scope` on any model. No business logic in callbacks.
- Bullet gem reports zero N+1 alerts.

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. ALWAYS use PostgreSQL in production — SQLite is for dev/test only.
2. NEVER leave N+1 queries — use includes/preload and strict_loading.
3. NEVER use default_scope — it silently affects every query.
4. NEVER put complex business logic in callbacks — use service objects.
5. NEVER use update_attribute — it skips validations. Use update! instead.
6. NEVER write raw SQL without parameterization — SQL injection is real.
7. ALWAYS add database indexes on all foreign keys and WHERE/ORDER columns.
8. ALWAYS make migrations reversible — never edit committed migrations.
9. ALWAYS use strong parameters — no mass assignment vulnerabilities.
10. NEVER use.all.each for large datasets — use find_each or in_batches.
11. ALWAYS use build over create in factories when DB persistence is not needed.
12. ALWAYS use request specs over controller specs (Rails recommendation).
```

## Key Behaviors

1. **Convention over configuration.** Follow the Rails Way. If you are fighting the framework, you are doing it wrong.
2. **Fat models, skinny controllers — but not too fat.** Extract complex logic to service objects. Models handle persistence and simple business rules.
3. **N+1 is the enemy.** Use `includes`, `strict_loading`, and Bullet gem to detect and eliminate N+1 queries before they hit production.
4. **Hotwire first, React later.** Most Rails apps do not need a JavaScript SPA. Turbo Frames and Streams handle 90% of interactive UI needs.
5. **Background everything slow.** Email sending, PDF generation, external API calls, and anything over 200ms belongs in a background job.
6. **Test behavior, not implementation.** RSpec request specs test the HTTP interface. Model specs test business rules. System specs test critical user flows.
7. **Migrations are forever.** Keep every migration reversible. Never edit a committed migration — write a new one.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Rails setup workflow |
| `--api` | API-only Rails application |
| `--hotwire` | Configure Hotwire (Turbo + Stimulus) |

## Output Format

End every Rails skill invocation with this summary block:

```
RAILS RESULT:
Action: <scaffold | model | controller | service | optimize | test | audit | upgrade | deploy>
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

Append one TSV row to `.godmode/rails.tsv` after each invocation:

```
timestamp	project	action	files_count	models_count	controllers_count	migrations_count	tests_status	notes
```

Field definitions:
- `timestamp`: ISO-8601 UTC
- `project`: directory name from `basename $(pwd)`
- `action`: scaffold | model | controller | service | optimize | test | audit | upgrade | deploy
- `files_count`: number of files created or modified
- `models_count`: number of models created or modified
- `controllers_count`: number of controllers created or modified
- `migrations_count`: number of migrations generated
- `tests_status`: passing | failing | skipped | none
- `notes`: free-text, max 120 chars, no tabs

If `.godmode/` does not exist, create it and add `.godmode/` to `.gitignore` if not already present.

## Success Criteria

Every Rails skill invocation must pass ALL of these checks before reporting success:

1. `bin/rails test` (or `bundle exec rspec`) passes if test suite exists
2. `bin/rails db:migrate:status` shows no pending migrations
3. All `belongs_to` foreign keys have database indexes
4. No `default_scope` on any model
5. No business logic in callbacks (use service objects)
6. All queries with WHERE/ORDER BY clauses have appropriate indexes
7. No raw SQL without parameterized queries
8. N+1 queries detected by Bullet gem are resolved
9. `bundle audit` shows no known vulnerabilities (if gem installed)
10. `bin/rails routes` has no duplicate or orphaned routes

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Error Recovery

When errors occur, follow these remediation steps:

```
IF tests fail:
 1. Check test database exists and is migrated (bin/rails db:test:prepare)
 2. Verify fixtures/factories have valid data and associations
 3. Check for order-dependent tests (run with --seed to verify)
 4. Verify that database cleaner strategy is correct (transaction vs truncation)

IF migration fails:
 1. Check for irreversible migration (add explicit down method)
 2. Verify column types are compatible with existing data
 3. Check for lock timeout on large tables (use strong_migrations gem)
 4. For failed production migration → write a corrective migration, never edit existing ones

IF N+1 queries detected:
 1. Add includes() or eager_load() to the query
 2. Use strict_loading! on associations to catch new N+1s
```
