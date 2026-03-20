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
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Decision                            │  Choice & Justification          │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Full-stack vs API-only              │  Full-stack: Hotwire for interactivity │
│                                      │  API-only: --api flag, JSON responses  │
│  Database                            │  PostgreSQL for production ALWAYS │
│  Background processor                │  Solid Queue (Rails 8 default)   │
│                                      │  Sidekiq (Redis-backed, battle-tested) │
│  Real-time                           │  Turbo Streams for live updates  │
│  Authentication                      │  Rails 8: built-in auth generator│
│                                      │  Rails 7: Devise or custom       │
│  JavaScript                          │  Import Maps (simple, no build)  │
│                                      │  esbuild (if heavy JS needed)    │
│  CSS                                 │  Tailwind (Rails default)        │
│  Testing                             │  RSpec + FactoryBot + Capybara   │
└──────────────────────────────────────┴──────────────────────────────────┘
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
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Convention                          │  Rule                            │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Model naming                        │  Singular, CamelCase (Order)     │
│  Table naming                        │  Plural, snake_case (orders)     │
│  Controller naming                   │  Plural, CamelCase (OrdersController) │
│  File naming                         │  snake_case (order.rb)           │
│  Foreign keys                        │  <model>_id (customer_id)        │
│  Join tables                         │  Alphabetical (labels_orders)    │
│  Primary keys                        │  id (auto-increment or UUID)     │
│  Timestamps                          │  created_at, updated_at (auto)   │
│  Boolean columns                     │  Adjective (active, published)   │
│  Routes                              │  RESTful resources               │
│  Partials                            │  _prefix (e.g., _form.html.erb) │
│  Helpers                             │  Named after controller          │
│  Concerns                            │  Shared behavior modules         │
└──────────────────────────────────────┴──────────────────────────────────┘

PROJECT STRUCTURE (standard Rails):
app/
├── controllers/          # Request handling
│   ├── concerns/         # Shared controller behavior
│   └── api/v1/           # API versioned controllers
├── models/               # Domain logic + persistence
│   └── concerns/         # Shared model behavior
├── views/                # Templates (ERB/Slim/Haml)
│   └── layouts/          # Application layouts
├── jobs/                 # Background jobs
├── mailers/              # Email sending
├── channels/             # Action Cable channels
├── services/             # Service objects (app/services/)
├── queries/              # Query objects (app/queries/)
├── policies/             # Authorization policies (Pundit)
├── serializers/          # API serializers (app/serializers/)
└── components/           # ViewComponents (optional)
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
  has_one :shipping_address, dependent: :destroy

  # Validations
  validates :status, presence: true, inclusion: { in: %w[pending confirmed shipped delivered cancelled] }
  validates :total_cents, numericality: { greater_than_or_equal_to: 0 }

  # Enums (Rails 7+ syntax)
  enum :status, {
    pending: "pending",
    confirmed: "confirmed",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  # Scopes — composable, reusable queries
  scope :recent, -> { order(created_at: :desc) }
  scope :active, -> { where.not(status: :cancelled) }
  scope :for_customer, ->(customer_id) { where(customer_id: customer_id) }
  scope :created_between, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # Callbacks (use sparingly)
  after_create_commit :send_confirmation_email
  after_update_commit :broadcast_status_change, if: :saved_change_to_status?

  # Custom methods
  def cancelable?
    pending? || confirmed?
  end
end

# QUERY OPTIMIZATION — Avoiding N+1 queries
class OrdersController < ApplicationController
  # BAD: N+1 — loads customer and items separately for each order
  # def index
  #   @orders = Order.all
  # end

  # GOOD: Eager loading with includes
  def index
    @orders = Order
      .includes(:customer, :order_items)     # Prevents N+1
      .where(customer: current_user)
      .recent
      .page(params[:page])
      .per(25)
  end

  # GOOD: Preload vs Includes vs Eager Load
  # includes  — smart: uses preload or eager_load depending on conditions
  # preload   — separate queries (2 queries: orders + customers)
  # eager_load — single LEFT OUTER JOIN (1 query, wider result set)

  # For counting without loading records
  def stats
    @total = Order.active.count
    @revenue = Order.active.sum(:total_cents)
    # Use pluck for single-column extraction
    @statuses = Order.distinct.pluck(:status)
  end
end

# Query object for complex searches
class OrderSearchQuery
  def initialize(scope = Order.all)
    @scope = scope
  end

  def call(params)
    @scope
      .then { |s| params[:status] ? s.where(status: params[:status]) : s }
      .then { |s| params[:customer_id] ? s.for_customer(params[:customer_id]) : s }
      .then { |s| params[:min_total] ? s.where("total_cents >= ?", params[:min_total]) : s }
      .then { |s| params[:since] ? s.where("created_at >= ?", params[:since]) : s }
      .includes(:customer)
      .recent
      .page(params[:page])
  end
end
```

```
ACTIVERECORD PERFORMANCE PATTERNS:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Pattern                             │  When to Use                     │
├──────────────────────────────────────┼──────────────────────────────────┤
│  includes(:assoc)                    │  Default N+1 prevention          │
│  preload(:assoc)                     │  Separate queries (large joins)  │
│  eager_load(:assoc)                  │  Need WHERE on association       │
│  select(:col1, :col2)               │  Reduce data transfer            │
│  pluck(:column)                      │  Extract array of values         │
│  find_each(batch_size: 1000)         │  Process large datasets          │
│  in_batches(of: 1000)               │  Batch updates/deletes           │
│  .count / .sum / .average            │  Database-level aggregation      │
│  counter_cache: true                 │  Avoid COUNT queries             │
│  strict_loading!                     │  Detect N+1 in development       │
│  explain                             │  Analyze query execution plan    │
│  add_index                           │  Every FK + frequent WHERE cols  │
│  database views                      │  Complex reporting queries       │
└──────────────────────────────────────┴──────────────────────────────────┘
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
┌─────────────────────────────────────────────────────────────────┐
│  Turbo Drive    — SPA-like navigation without JavaScript        │
│  Turbo Frames   — Update specific page sections independently   │
│  Turbo Streams  — Real-time updates via WebSocket or HTTP       │
│  Stimulus       — Sprinkle JavaScript behavior on HTML          │
└─────────────────────────────────────────────────────────────────┘
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
    format.turbo_stream  # renders update.turbo_stream.erb
    format.html { redirect_to @order }
  end
end

<!-- update.turbo_stream.erb -->
<%= turbo_stream.replace "order_#{@order.id}" do %>
  <%= render partial: "orders/order", locals: { order: @order } %>
<% end %>

<!-- Turbo Stream — Broadcast from model (real-time to all viewers) -->
<!-- order.rb -->
after_update_commit -> { broadcast_replace_to "orders",
  partial: "orders/order", locals: { order: self } }

<!-- Stimulus controller — Sprinkle JS behavior -->
<!-- app/javascript/controllers/search_controller.js -->
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      fetch(`${this.urlValue}?q=${this.inputTarget.value}`,
        { headers: { "Accept": "text/vnd.turbo-stream.html" } })
        .then(r => r.text())
        .then(html => Turbo.renderStreamMessage(html))
    }, 300)
  }
}
```

```
HOTWIRE DECISION GUIDE:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Need                                │  Use                             │
├──────────────────────────────────────┼──────────────────────────────────┤
│  SPA-like page transitions           │  Turbo Drive (automatic)         │
│  Update one section on click         │  Turbo Frames                    │
│  Real-time updates to all viewers    │  Turbo Streams (broadcast)       │
│  Update page after form submit       │  Turbo Streams (HTTP response)   │
│  Toggle visibility, dropdowns        │  Stimulus controller             │
│  Form validation, character count    │  Stimulus controller             │
│  Complex interactive widget          │  Stimulus + Turbo Frames         │
│  Full SPA (React/Vue needed)         │  Rails API-only + separate SPA   │
└──────────────────────────────────────┴──────────────────────────────────┘
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

  def perform(order)
    OrderConfirmationMailer.with(order: order).confirmation.deliver_now
    order.update!(confirmation_sent_at: Time.current)
  end
end

# Enqueue
OrderConfirmationJob.perform_later(order)           # Async
OrderConfirmationJob.set(wait: 5.minutes).perform_later(order)  # Delayed
OrderConfirmationJob.set(queue: :high).perform_later(order)     # Priority
```

```
BACKGROUND JOB STRATEGY:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Processor                           │  When to Use                     │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Solid Queue (Rails 8)               │  Default for Rails 8 — DB-backed │
│                                      │  No Redis dependency, simple     │
│  Sidekiq                             │  High throughput, Redis-backed   │
│                                      │  Battle-tested, rich ecosystem   │
│  Good Job                            │  PostgreSQL-backed, multithreaded│
│                                      │  Good for Heroku, no Redis      │
└──────────────────────────────────────┴──────────────────────────────────┘

JOB DESIGN RULES:
- Jobs MUST be idempotent — safe to retry
- Jobs MUST accept simple arguments (IDs, not objects) for serialization
- Jobs SHOULD be small and focused — one responsibility per job
- Jobs MUST have error handling and retry policies
- Jobs SHOULD log their start, completion, and failure
- Monitor queue depth — growing queues indicate processing problems

QUEUE PRIORITY:
┌──────────┬──────────────┬──────────────────────────────────┐
│  Queue   │  Priority    │  Examples                         │
├──────────┼──────────────┼──────────────────────────────────┤
│  critical│  Highest     │  Payment processing, alerts       │
│  default │  Normal      │  Email sending, notifications     │
│  low     │  Lowest      │  Reports, data exports, cleanup   │
└──────────┴──────────────┴──────────────────────────────────┘
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

  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by :selenium_chrome_headless
  end
end

# spec/factories/orders.rb
FactoryBot.define do
  factory :order do
    association :customer
    status { :pending }
    total_cents { Faker::Number.between(from: 1000, to: 100_000) }

    trait :confirmed do
      status { :confirmed }
      confirmed_at { Time.current }
    end

    trait :with_items do
      transient do
        items_count { 3 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.items_count, order: order)
      end
    end
  end
end

# spec/models/order_spec.rb
RSpec.describe Order, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:order_items).dependent(:destroy) }
  end

  describe "#cancelable?" do
    it "returns true for pending orders" do
      order = build(:order, status: :pending)
      expect(order).to be_cancelable
    end

    it "returns false for shipped orders" do
      order = build(:order, status: :shipped)
      expect(order).not_to be_cancelable
    end
  end

  describe "scopes" do
    it ".active excludes cancelled orders" do
      active = create(:order, status: :confirmed)
      cancelled = create(:order, status: :cancelled)

      expect(Order.active).to include(active)
      expect(Order.active).not_to include(cancelled)
    end
  end
end

# spec/requests/orders_spec.rb
RSpec.describe "Orders", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /orders" do
    it "returns paginated orders" do
      create_list(:order, 30, customer: user.customer)
      get orders_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /orders" do
    let(:valid_params) { { order: { product_ids: [create(:product).id] } } }

    it "creates an order and enqueues confirmation" do
      expect {
        post orders_path, params: valid_params
      }.to change(Order, :count).by(1)
        .and have_enqueued_job(OrderConfirmationJob)

      expect(response).to redirect_to(Order.last)
    end
  end
end

# spec/system/orders_spec.rb (Capybara)
RSpec.describe "Order management", type: :system do
  let(:user) { create(:user) }
  before { sign_in user }

  it "creates an order with Turbo" do
    visit new_order_path
    fill_in "Product", with: "Widget"
    click_button "Create Order"

    expect(page).to have_content("Order created successfully")
    expect(page).to have_css("[data-turbo-frame='orders']")
  end
end
```

```
TESTING STRATEGY:
┌──────────────────────────────────────┬──────────────────────────────────┐
│  Layer                               │  Approach                        │
├──────────────────────────────────────┼──────────────────────────────────┤
│  Models                              │  RSpec + FactoryBot + Shoulda    │
│  Controllers/Requests                │  RSpec request specs             │
│  System/Integration                  │  Capybara + Selenium             │
│  Services                            │  RSpec unit specs                │
│  Jobs                                │  ActiveJob::TestHelper           │
│  Mailers                             │  ActionMailer::TestHelper        │
│  API                                 │  Request specs + JSON assertions │
│  Turbo Streams                       │  assert_turbo_stream in requests │
└──────────────────────────────────────┴──────────────────────────────────┘

TEST HELPERS:
- FactoryBot: Build test data with traits and transients
- Faker: Generate realistic fake data
- Shoulda Matchers: One-liner validations/associations
- DatabaseCleaner: Transaction-based cleanup (if needed)
- VCR / WebMock: HTTP stubbing for external APIs
- SimpleCov: Code coverage reporting
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
┌──────────────────────────────────────┬──────────┬──────────────────────┐
│  Check                               │  Status  │  Notes               │
├──────────────────────────────────────┼──────────┼──────────────────────┤
│  Follows Rails conventions           │  PASS    │  Naming, structure   │
│  N+1 queries eliminated              │  PASS    │  includes/preload    │
│  strict_loading in dev               │  PASS    │  Catches lazy loads  │
│  Database indexes on FKs             │  PASS    │  All foreign keys    │
│  Background jobs idempotent          │  PASS    │  Safe to retry       │
│  Hotwire used appropriately          │  PASS    │  Frames + Streams    │
│  Tests pass (RSpec green)            │  PASS    │  Models + requests   │
│  FactoryBot factories valid          │  PASS    │  No orphan factories │
│  Credentials managed properly        │  PASS    │  Rails credentials   │
│  Database migrations reversible      │  PASS    │  All have down()     │
│  Strong parameters enforced          │  PASS    │  No mass assignment  │
│  CSRF protection enabled             │  PASS    │  Turbo compatible    │
│  Content Security Policy set         │  PASS    │  CSP headers         │
│  Production config hardened          │  PASS    │  Force SSL, log tags │
│  Ruby/Rails versions current         │  PASS    │  No EOL versions     │
└──────────────────────────────────────┴──────────┴──────────────────────┘

VERDICT: <PASS | NEEDS REVISION>
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
   - .ruby-version file
   - Gemfile: ruby "3.3.x"
3. Detect database:
   - config/database.yml: adapter field (postgresql, mysql2, sqlite3)
   - DATABASE_URL environment variable
4. Detect architecture choices:
   - config/application.rb: config.api_only? -> API mode
   - app/views/ presence -> full-stack
   - app/javascript/controllers/ -> Stimulus installed
   - Gemfile: turbo-rails, stimulus-rails -> Hotwire
5. Detect background job processor:
   - Gemfile: sidekiq, good_job, solid_queue, delayed_job
   - config/sidekiq.yml, config/queue.yml presence
6. Detect testing framework:
   - Gemfile: rspec-rails -> RSpec
   - test/ directory -> Minitest (default)
   - spec/ directory -> RSpec
   - Gemfile: factory_bot_rails, shoulda-matchers, capybara
7. Detect auth strategy:
   - Gemfile: devise, rodauth-rails, or custom auth
   - app/models/user.rb: has_secure_password
   - Rails 8 generated auth: app/controllers/sessions_controller.rb
8. Detect deployment:
   - config/deploy.yml -> Kamal
   - Procfile -> Heroku
   - Dockerfile -> Docker-based
   - .platform/ -> AWS Elastic Beanstalk
```

## Multi-Agent Dispatch

For large Rails feature development:

```
PARALLEL AGENTS:
Agent 1 — Models & Migrations (worktree: rails-models)
  - Generate models with associations and validations
  - Create database migrations with proper indexes
  - Add scopes, enums, and callbacks
  - Write model specs with FactoryBot

Agent 2 — Controllers & Routes (worktree: rails-controllers)
  - Generate RESTful controllers with strong params
  - Configure routes with proper nesting
  - Add authorization checks
  - Write request specs

Agent 3 — Views & Hotwire (worktree: rails-views)
  - Build views with Turbo Frames for interactivity
  - Add Turbo Streams for real-time updates
  - Create Stimulus controllers for JS behavior
  - Write system specs for critical flows

Agent 4 — Jobs & Services (worktree: rails-services)
  - Extract service objects for complex business logic
  - Create background jobs with retry policies
  - Build mailers and notification logic
  - Write unit specs for services and jobs

MERGE ORDER: Agent 1 first (models/schema), then Agent 2 + 4 in parallel, then Agent 3.
```

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
10. NEVER use .all.each for large datasets — use find_each or in_batches.
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
7. **Migrations are forever.** Every migration must be reversible. Never edit a migration that has been committed — write a new one.

## Example Usage

### Building a Rails Application
```
User: /godmode:rails Build a project management app

Rails: Assessing requirements...

RAILS ASSESSMENT:
Project: Project Management App
Rails: 8.0.x
Ruby: 3.3.x
Architecture: Full-stack (Hotwire)
Database: PostgreSQL
Jobs: Solid Queue
Auth: Rails 8 built-in auth generator

Creating models: Project, Task, User, Comment...
Configuring Hotwire: Turbo Frames for inline editing, Streams for real-time...
Setting up background jobs: NotificationJob, ReportGenerationJob...
Writing specs: 45 model specs, 30 request specs, 8 system specs...

All 15 checks PASS.
```

### Optimizing ActiveRecord Queries
```
User: /godmode:rails Optimize our slow order listing page

Rails: Analyzing queries...

FINDINGS:
1. N+1 on Order -> Customer (loading customer name per order)
2. N+1 on Order -> OrderItems (counting items per order)
3. Missing index on orders.status column
4. Full table scan on orders.created_at ordering

FIXES:
1. Added .includes(:customer) to query
2. Added counter_cache :order_items_count to OrderItem
3. Added index on [:status, :created_at]
4. Query time: 850ms -> 12ms
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Rails setup workflow |
| `--api` | API-only Rails application |
| `--hotwire` | Configure Hotwire (Turbo + Stimulus) |
| `--auth` | Set up authentication (Devise or built-in) |
| `--jobs sidekiq` | Configure Sidekiq for background jobs |
| `--jobs solid_queue` | Configure Solid Queue (Rails 8) |
| `--model <name>` | Generate model with best practices |
| `--optimize` | Find and fix N+1 queries and slow queries |
| `--test` | Generate RSpec + FactoryBot test suite |
| `--upgrade <version>` | Upgrade Rails version with migration guide |
| `--audit` | Audit existing Rails app for anti-patterns |
| `--deploy kamal` | Configure Kamal deployment |

## Anti-Patterns

- **Do NOT skip database indexes.** Every `belongs_to` foreign key needs an index. Every column used in WHERE or ORDER BY needs an index.
- **Do NOT use `default_scope`.** It silently affects every query and is nearly impossible to override cleanly. Use named scopes instead.
- **Do NOT put business logic in callbacks.** Callbacks create hidden dependencies and make testing painful. Use service objects for complex logic.
- **Do NOT use `update_attribute`.** It skips validations. Use `update!` or `update` with explicit error handling.
- **Do NOT write raw SQL without parameterization.** `where("name = '#{params[:name]}'")` is SQL injection. Use `where(name: params[:name])` or `where("name = ?", params[:name])`.
- **Do NOT test implementation details.** Do not test that a method calls another method. Test the observable behavior and output.
- **Do NOT use `create` in factories when `build` suffices.** Hitting the database slows down tests. Only `create` when you need persistence.
- **Do NOT leave N+1 queries in production.** Use Bullet gem and `strict_loading` to catch them in development. Every N+1 is a performance bug.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run Rails tasks sequentially: models/migrations, then controllers/routes, then views/Hotwire, then jobs/services.
- Use branch isolation per task: `git checkout -b godmode-rails-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
