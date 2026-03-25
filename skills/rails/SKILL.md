---
name: rails
description: Ruby on Rails mastery.
---

## Activate When
- `/godmode:rails`, "rails app", "ruby on rails"
- "activerecord", "hotwire", "turbo", "sidekiq"
- Rails backend implementation tasks

## Workflow

### 1. Project Assessment
```
Rails version: <7.2.x or 8.0.x>
Ruby version: <3.3.x>
Architecture: Full-stack (Hotwire)|API-only|Hybrid
Database: PostgreSQL (ALWAYS for production)
Jobs: Sidekiq|Solid Queue|Good Job
Real-time: Action Cable|Turbo Streams|None
Auth: Devise|has_secure_password|Rails 8 built-in
Assets: Propshaft + Import Maps|esbuild|Vite
```
```bash
cat Gemfile | grep -E "rails|ruby"
cat config/database.yml | grep adapter
```
IF Rails 8: prefer built-in generators (auth, jobs).
IF < heavy JS: Import Maps (no build step).
IF heavy JS: esbuild or Vite.

### 2. Rails Conventions
```
| Convention | Rule |
| Model | Singular CamelCase (Order) |
| Table | Plural snake_case (orders) |
| Controller | Plural CamelCase (OrdersController) |
| File | snake_case (order.rb) |
| Foreign key | <model>_id (customer_id) |
| Join table | Alphabetical (labels_orders) |
| Timestamps | created_at, updated_at (auto) |
```
NEVER violate naming conventions (framework superpower).
Extract to services when model > 200 LOC.

### 3. ActiveRecord Patterns
```
| Pattern | When |
| includes(:assoc) | Default N+1 prevention |
| preload(:assoc) | Separate queries (large joins) |
| eager_load(:assoc) | Need WHERE on association |
| select(:col1,:col2) | Reduce data transfer |
| find_each(batch:1000) | Process large datasets |
| counter_cache: true | Avoid COUNT queries |
```
ALWAYS use includes for associations in views.
ALWAYS enable strict_loading in development.
NEVER .all.each for large datasets — use find_each.
IF foreign key exists: MUST have database index.

### 4. Hotwire (Turbo + Stimulus)
```
| Need | Use |
| SPA-like navigation | Turbo Drive (automatic) |
| Update one section | Turbo Frames |
| Real-time broadcast | Turbo Streams |
| Toggle/dropdown/count | Stimulus controller |
| Full SPA (React/Vue) | Rails API-only + SPA |
```
IF < 90% of interactivity: Hotwire handles it.
IF complex client state: Rails API + React/Vue.

### 5. Background Jobs
```
| Processor | When |
| Solid Queue (Rails 8) | Default, DB-backed, simple |
| Sidekiq | High throughput, Redis-backed |
| Good Job | PostgreSQL-backed, no Redis |
```
Jobs MUST be idempotent (safe to retry).
NEVER process > 200ms tasks inline.
ALWAYS set retry limits with exponential backoff.

### 6. Testing (RSpec + FactoryBot)
```
| Layer | Approach |
| Models | RSpec + FactoryBot + Shoulda |
| Requests | RSpec request specs (not controller) |
| System | Capybara (critical flows only) |
| Jobs | ActiveJob::TestHelper |
```
Use `build` over `create` when DB not needed.
Use traits for common variations.
IF coverage < 60%: write tests before refactoring.

### 7. Validation
```
[ ] Rails conventions followed
[ ] N+1 eliminated (strict_loading enabled)
[ ] Foreign keys indexed
[ ] Jobs idempotent
[ ] Tests pass (RSpec green)
[ ] Credentials managed (Rails credentials)
[ ] No default_scope, no logic in callbacks
```


```bash
# Rails development and testing
rspec --format progress
rails db:migrate:status
bundle audit check
```

## Hard Rules
1. ALWAYS PostgreSQL in production.
2. NEVER leave N+1 queries (includes + strict_loading).
3. NEVER default_scope (silently affects every query).
4. NEVER business logic in callbacks (use services).
5. NEVER update_attribute (skips validations).
6. NEVER raw SQL without parameterization.
7. ALWAYS index foreign keys + WHERE/ORDER columns.
8. ALWAYS make migrations reversible.
9. NEVER .all.each (use find_each/in_batches).

## TSV Logging
Append `.godmode/rails.tsv`:
```
timestamp	action	files	models	migrations	tests	status
```

## Keep/Discard
```
KEEP if: tests pass, no new N+1, migrations reversible.
DISCARD if: tests fail, Bullet detects N+1,
  migration irreversible.
```

## Stop Conditions
```
STOP when FIRST of:
  - bin/rails test passes with zero failures
  - No pending migrations, all FKs indexed
  - No default_scope, no callback logic
  - Bullet reports zero N+1 alerts
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Tests fail | db:test:prepare, check fixtures, --seed |
| Migration fails | Add down method, use strong_migrations |
| N+1 detected | Add includes at query site, Bullet verify |
| Bundle audit vuln | Update gem or document + pin version |
