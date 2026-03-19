# Ruby on Rails Developer Guide

How to use Godmode's full workflow for Ruby and Rails projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Ruby via Gemfile, Rakefile, or config.ru
# Test: bundle exec rspec / bundle exec rails test
# Lint: bundle exec rubocop
# Build: bundle install / rake assets:precompile
```

### Example `.godmode/config.yaml`
```yaml
language: ruby
framework: rails               # or sinatra, hanami, etc.
test_command: bundle exec rspec --fail-fast
lint_command: bundle exec rubocop --parallel
format_command: bundle exec rubocop -A
build_command: bundle install && rake assets:precompile
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/up
```

---

## How Each Skill Applies to Ruby

### THINK Phase

| Skill | Ruby Adaptation |
|-------|----------------|
| **think** | Design domain models and service objects first. A Ruby spec should define ActiveRecord associations, validations, and service object interfaces. Include input/output contracts with typed parameters where possible. |
| **predict** | Expert panel evaluates Rails conventions, query performance (N+1, eager loading), and scaling strategy. Request panelists with Ruby depth (e.g., Rails core contributor, Sidekiq maintainer). |
| **scenario** | Explore edge cases around nil handling (NoMethodError on nil), ActiveRecord callbacks ordering, race conditions in concurrent requests, background job failure modes, and timezone handling. |

### BUILD Phase

| Skill | Ruby Adaptation |
|-------|----------------|
| **plan** | Each task specifies models, controllers, and services. File paths follow Rails conventions (`app/services/user_service.rb`). Tasks note which migrations, routes, and test files are affected. |
| **build** | TDD with RSpec. RED step writes a spec file with `describe`/`context`/`it` blocks. GREEN step implements the class. REFACTOR step extracts service objects, uses value objects, and applies Ruby idioms. |
| **test** | Use RSpec with `let`/`before`/`subject`. Use FactoryBot for test data. Use `have_enqueued_job` matchers for background jobs. Separate request specs, model specs, and service specs. |
| **review** | Check for missing validations, N+1 queries, fat controllers, callbacks with side effects, missing database indexes, and improper use of `update_column` (bypasses validations). |

### OPTIMIZE Phase

| Skill | Ruby Adaptation |
|-------|----------------|
| **optimize** | Target response time, memory usage, or query count. Guard rail: `bundle exec rspec` must pass on every iteration. Use Rack Mini Profiler and Bullet gem data to guide hypotheses. |
| **debug** | Use `binding.pry` (Pry) or `debugger` (debug gem). Check for common Rails pitfalls: N+1 queries, excessive object allocation, memory bloat from large ActiveRecord result sets. |
| **fix** | Autonomous fix loop handles test failures, type errors, and style violations. Guard rail: `bundle exec rspec && bundle exec rubocop`. |
| **secure** | Run `bundle audit` and `brakeman`. Check for SQL injection in raw queries, mass assignment vulnerabilities, XSS in views, CSRF bypass, and insecure direct object references. |

### SHIP Phase

| Skill | Ruby Adaptation |
|-------|----------------|
| **ship** | Pre-flight: `bundle exec rspec && bundle exec rubocop && brakeman -q`. Verify migrations are reversible and seeds run cleanly. |
| **finish** | Ensure version is bumped. Verify `Gemfile.lock` is committed. Confirm database migrations are production-safe (no data loss, no long locks). |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| Tests pass | `bundle exec rspec 2>&1 \| grep 'examples'` | 0 failures |
| Style violations | `bundle exec rubocop --parallel 2>&1 \| tail -1` | 0 offenses |
| Security audit | `bundle audit check 2>&1 \| grep 'Vulnerabilities'` | 0 |
| Static security | `brakeman -q 2>&1 \| grep 'Warnings'` | 0 warnings |
| Test coverage | `open coverage/index.html` (SimpleCov) | >= 85% |
| Response time | `curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/up` | < 0.05s |
| Query count | Bullet gem / Rack Mini Profiler | No N+1s |
| Memory usage | `derailed bundle:mem` | Project-specific |

---

## Common Verify Commands

### Tests pass
```bash
bundle exec rspec --fail-fast
# or
bundle exec rails test
```

### Style check
```bash
bundle exec rubocop --parallel
```

### Security audit
```bash
bundle audit check --update
```

### Static security scan
```bash
brakeman -q --no-pager
```

### Database status
```bash
rails db:migrate:status
```

### Routes (sanity check)
```bash
rails routes --compact
```

### API responds
```bash
curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/up
```

---

## Tool Integration

### RSpec

Godmode's TDD cycle maps directly to RSpec:

```bash
# RED step: run single spec file, expect failure
bundle exec rspec spec/services/user_service_spec.rb

# GREEN step: run single spec, expect pass
bundle exec rspec spec/services/user_service_spec.rb

# After GREEN: run full suite to catch regressions
bundle exec rspec

# Coverage
COVERAGE=true bundle exec rspec
```

**Test patterns** for Godmode projects:
```ruby
# spec/services/user_service_spec.rb
require 'rails_helper'

RSpec.describe UserService do
  subject(:service) { described_class.new(repository: repository) }

  let(:repository) { instance_double(UserRepository) }

  describe '#find_user' do
    context 'when user exists' do
      let(:user) { build(:user, id: '123', name: 'Alice') }

      before do
        allow(repository).to receive(:find_by_id).with('123').and_return(user)
      end

      it 'returns the user' do
        result = service.find_user('123')
        expect(result.name).to eq('Alice')
      end

      it 'queries the repository once' do
        service.find_user('123')
        expect(repository).to have_received(:find_by_id).once
      end
    end

    context 'when user does not exist' do
      before do
        allow(repository).to receive(:find_by_id).with('missing').and_return(nil)
      end

      it 'raises UserNotFoundError' do
        expect { service.find_user('missing') }
          .to raise_error(UserService::UserNotFoundError)
      end
    end
  end
end
```

**Request spec** for API testing:
```ruby
# spec/requests/api/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  describe 'GET /api/users' do
    before { create_list(:user, 25) }

    it 'returns paginated users' do
      get '/api/users', params: { page: 1, per_page: 10 }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json['data'].length).to eq(10)
      expect(json['meta']['total']).to eq(25)
    end
  end

  describe 'POST /api/users' do
    context 'with valid params' do
      let(:valid_params) { { user: { name: 'Alice', email: 'alice@example.com' } } }

      it 'creates a user and returns 201' do
        expect { post '/api/users', params: valid_params }
          .to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns 422 with validation errors' do
        post '/api/users', params: { user: { name: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body['errors']).to include('name')
      end
    end
  end
end
```

### Minitest (Alternative)

```ruby
# test/services/user_service_test.rb
require 'test_helper'

class UserServiceTest < ActiveSupport::TestCase
  setup do
    @repository = Minitest::Mock.new
    @service = UserService.new(repository: @repository)
  end

  test 'find_user returns user when found' do
    user = users(:alice)
    @repository.expect(:find_by_id, user, ['123'])

    result = @service.find_user('123')

    assert_equal 'Alice', result.name
    @repository.verify
  end

  test 'find_user raises when not found' do
    @repository.expect(:find_by_id, nil, ['missing'])

    assert_raises(UserService::UserNotFoundError) do
      @service.find_user('missing')
    end
  end
end
```

### RuboCop

Guard rail configuration for Godmode projects:

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: bundle exec rspec --fail-fast
    expect: exit code 0
  - command: bundle exec rubocop --parallel
    expect: exit code 0
```

**.rubocop.yml** for Godmode projects:
```yaml
require:
  - rubocop-rails
  - rubocop-rspec
  - rubocop-performance

AllCops:
  NewCops: enable
  TargetRubyVersion: 3.3
  Exclude:
    - 'db/schema.rb'
    - 'bin/**/*'
    - 'vendor/**/*'

Metrics/MethodLength:
  Max: 20

Style/Documentation:
  Enabled: false

RSpec/ExampleLength:
  Max: 15

RSpec/MultipleExpectations:
  Max: 3

Rails/HasManyOrHasOneDependent:
  Enabled: true
```

### Gem Management

```bash
# Install dependencies
bundle install

# Add a gem
bundle add sidekiq

# Add a dev gem
bundle add rubocop --group development

# Update gems
bundle update

# Check for outdated gems
bundle outdated --only-explicit

# Security audit
bundle audit check --update

# List gem sizes (for optimization)
bundle exec derailed bundle:mem
```

**Gemfile** best practices for Godmode projects:
```ruby
# Gemfile
source 'https://rubygems.org'
ruby '3.3.0'

gem 'rails', '~> 7.2'
gem 'pg', '~> 1.5'
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 7.2'

group :development, :test do
  gem 'rspec-rails', '~> 6.1'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'rubocop', '~> 1.60', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-performance', require: false
end

group :development do
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'rack-mini-profiler'
end

group :test do
  gem 'simplecov', require: false
  gem 'shoulda-matchers', '~> 6.1'
  gem 'webmock', '~> 3.23'
end
```

---

## Framework Integration

### Rails Conventions

```yaml
# .godmode/config.yaml
framework: rails
test_command: bundle exec rspec --fail-fast
lint_command: bundle exec rubocop --parallel
build_command: bundle install && rake assets:precompile
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/up
```

Rails-specific THINK considerations:
- Model design with associations, validations, and scopes
- Controller structure (RESTful actions, strong parameters)
- Service object pattern for complex business logic
- Active Job with Sidekiq for background processing
- Turbo/Hotwire for real-time features (if applicable)
- Database migration strategy (zero-downtime, backfills)

Rails-specific patterns:
```ruby
# app/services/order_service.rb
class OrderService
  class OrderCreationError < StandardError; end

  def initialize(payment_gateway: StripeGateway.new, notifier: OrderNotifier.new)
    @payment_gateway = payment_gateway
    @notifier = notifier
  end

  def create_order(user:, items:, payment_method_id:)
    ActiveRecord::Base.transaction do
      order = Order.create!(
        user: user,
        items: build_order_items(items),
        total: calculate_total(items)
      )

      charge = @payment_gateway.charge(
        amount: order.total,
        payment_method_id: payment_method_id,
        metadata: { order_id: order.id }
      )

      order.update!(payment_intent_id: charge.id, status: :paid)

      # Side effects via background jobs
      OrderConfirmationJob.perform_later(order)
      InventoryUpdateJob.perform_later(order)

      order
    end
  rescue Stripe::CardError => e
    raise OrderCreationError, "Payment failed: #{e.message}"
  end

  private

  def build_order_items(items)
    items.map do |item|
      OrderItem.new(
        product_id: item[:product_id],
        quantity: item[:quantity],
        unit_price: Product.find(item[:product_id]).price
      )
    end
  end

  def calculate_total(items)
    items.sum { |item| Product.find(item[:product_id]).price * item[:quantity] }
  end
end
```

### Rails optimize targets

```bash
# Query count for an endpoint
RAILS_LOG_LEVEL=debug curl http://localhost:3000/api/products 2>&1 | grep 'SELECT' | wc -l

# Memory profiling
bundle exec derailed bundle:mem

# Request profiling with rack-mini-profiler
# Visit /rack-mini-profiler/requests in development

# Migration safety check
bundle exec strong_migrations check
```

---

## Deployment

### Heroku

```bash
# Deploy to Heroku
git push heroku main

# Run migrations
heroku run rails db:migrate

# Check logs
heroku logs --tail

# Scale dynos
heroku ps:scale web=2 worker=1
```

**Procfile** for Heroku:
```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:migrate
```

Godmode ship integration with Heroku:
```bash
/godmode:ship --pre-flight "bundle exec rspec && bundle exec rubocop && brakeman -q" \
  --deploy "git push heroku main"
```

### Docker

```dockerfile
# Dockerfile
FROM ruby:3.3-slim AS base
RUN apt-get update -qq && apt-get install -y libpq-dev
WORKDIR /app

FROM base AS build
RUN apt-get install -y build-essential
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && bundle install
COPY . .
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

FROM base AS production
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

**docker-compose.yml** for development:
```yaml
services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
      - redis
    environment:
      DATABASE_URL: postgres://postgres:password@db:5432/myapp_development
      REDIS_URL: redis://redis:6379/0
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
  redis:
    image: redis:7-alpine
  worker:
    build: .
    command: bundle exec sidekiq -C config/sidekiq.yml
    depends_on:
      - db
      - redis
```

### Kamal (Docker-based deployment)

```yaml
# config/deploy.yml
service: myapp
image: myregistry/myapp
servers:
  web:
    - 192.168.1.1
    - 192.168.1.2
  job:
    hosts:
      - 192.168.1.3
    cmd: bundle exec sidekiq -C config/sidekiq.yml
registry:
  server: ghcr.io
  username: myuser
  password:
    - KAMAL_REGISTRY_PASSWORD
env:
  clear:
    RAILS_LOG_TO_STDOUT: 1
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
```

```bash
# Deploy with Kamal
kamal deploy

# Rollback
kamal rollback
```

---

## Example: Full Workflow for Building a Rails API

### Scenario
Build a project management API using Rails with Sidekiq background jobs, Action Cable for real-time updates, and Docker deployment.

### Step 1: Think (Design)
```
/godmode:think I need a project management API with Rails — projects with
tasks, team member assignment, real-time updates via Action Cable when tasks
change status, Sidekiq for email notifications and report generation,
PostgreSQL with full-text search.
```

Godmode produces a spec at `docs/specs/project-management.md` containing:
- Models: `Project`, `Task`, `TeamMember`, `Assignment` with associations
- Service objects: `TaskService`, `ProjectService`, `SearchService`
- Background jobs: `NotificationJob`, `ReportGenerationJob`
- Channel: `ProjectChannel` for real-time task updates
- Search: `pg_search` for full-text search across tasks and projects

### Step 2: Build (TDD)
```
/godmode:build
```

**Task 1 — RED:**
```ruby
# spec/services/task_service_spec.rb
RSpec.describe TaskService do
  subject(:service) { described_class.new }

  describe '#create_task' do
    let(:project) { create(:project) }
    let(:params) { { title: 'Fix bug', project_id: project.id, priority: :high } }

    it 'creates a task and broadcasts to channel' do
      expect { service.create_task(params) }
        .to change(Task, :count).by(1)
        .and have_broadcasted_to("project_#{project.id}")
    end
  end
end
```
Commit: `test(red): Task service — failing creation and broadcast tests`

**Task 1 — GREEN:**
Implement `TaskService` with Action Cable broadcasting.
Commit: `feat: Task service — creation with real-time broadcasting`

### Step 3: Optimize
```
/godmode:optimize --goal "reduce task list query time" \
  --verify "curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/projects/1/tasks" \
  --target "< 0.03"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | N+1 on assignments | Add `includes(:assignees)` | 95ms | 38ms | KEEP |
| 2 | No database index on project_id | Add composite index `(project_id, status)` | 38ms | 22ms | KEEP |
| 3 | Full model serialization | Use `jbuilder` with select fields | 22ms | 18ms | KEEP |

### Step 4: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
bundle exec rspec         ✓ 58/58 passing
bundle exec rubocop       ✓ 0 offenses
brakeman -q               ✓ 0 warnings
bundle audit              ✓ 0 vulnerabilities
```

---

## Ruby-Specific Tips

### 1. Service objects are your spec
In the THINK phase, design service objects for business logic before touching controllers or models. Service objects are testable, composable, and prevent fat models/controllers.

### 2. Use FactoryBot wisely
Prefer `build` (in-memory) over `create` (database) in unit specs. Reserve `create` for integration and request specs. Godmode's test skill generates efficient factory usage:
```ruby
# Fast unit test (no database)
let(:user) { build(:user) }

# Integration test (needs database)
let(:user) { create(:user) }
```

### 3. Enable Bullet in development
The Bullet gem detects N+1 queries and unused eager loading. Enable it from day one to catch query issues during the BUILD phase:
```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.rails_logger = true
  Bullet.raise = true # Fail tests on N+1
end
```

### 4. Use strong_migrations for safety
Prevent dangerous migrations that lock tables or cause downtime:
```
/godmode:review --check "strong_migrations" --verify "bundle exec strong_migrations check"
```

### 5. Background jobs for everything async
Move all side effects (emails, notifications, external API calls) to Sidekiq jobs. This keeps request/response cycles fast and makes the system resilient to external failures.
