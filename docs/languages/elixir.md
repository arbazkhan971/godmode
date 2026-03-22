# Elixir/Phoenix Developer Guide

How to use Godmode's full workflow for Elixir and Phoenix projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Elixir via mix.exs
# Test: mix test
# Lint: mix credo --strict / mix dialyzer
# Format: mix format --check-formatted
# Build: mix compile --warnings-as-errors
```

### Example `.godmode/config.yaml`
```yaml
language: elixir
framework: phoenix             # or nerves, plain otp, etc.
test_command: mix test --max-failures 1
lint_command: mix credo --strict && mix dialyzer
format_command: mix format --check-formatted
build_command: mix compile --warnings-as-errors
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:4000/api/health
```

---

## How Each Skill Applies to Elixir

### THINK Phase

| Skill | Elixir Adaptation |
|--|--|
| **think** | Design behaviours, structs, and supervision trees first. An Elixir spec should define `@callback` types, struct shapes with `@type` annotations, and the supervision hierarchy. Include `@spec` type annotations for all public functions. |
| **predict** | Expert panel evaluates OTP design, fault tolerance strategy, and message-passing architecture. Request panelists with Elixir depth (e.g., OTP architect, Phoenix core contributor, BEAM VM expert). |
| **scenario** | Explore edge cases around process crashes (let it crash philosophy), GenServer state recovery, distributed node partitions, message mailbox overflow, and LiveView socket disconnect/reconnect. |

### BUILD Phase

| Skill | Elixir Adaptation |
|--|--|
| **plan** | Each task specifies modules and supervision tree placement. File paths follow Elixir conventions (`lib/my_app/services/user_service.ex`). Tasks note which supervisors, contexts, and migrations are affected. |
| **build** | TDD with ExUnit. RED step writes a test module with `describe`/`test` blocks. GREEN step implements the module. REFACTOR step extracts behaviours, uses pattern matching, and applies OTP patterns. |
| **test** | Use ExUnit with `setup`/`setup_all`. Use Mox for behaviour-based mocking. Use `Ecto.Adapters.SQL.Sandbox` for database isolation. Use `Phoenix.ConnTest` for controller tests. |
| **review** | Check for missing `@spec` annotations, GenServer bottlenecks (single process handling too much), missing supervisor strategies, improper use of `Process.sleep` in production code, and Ecto N+1 queries. |

### OPTIMIZE Phase

| Skill | Elixir Adaptation |
|--|--|
| **optimize** | Target request latency, process count, or memory per process. Guard rail: `mix test` must pass on every iteration. Use `:observer` and `:recon` data to guide hypotheses. |
| **debug** | Use `:observer.start()`, `:recon`, and `IEx.pry`. Check for common Elixir pitfalls: GenServer bottlenecks, large process mailboxes, binary memory leaks, and ETS table contention. |
| **fix** | Autonomous fix loop handles compiler warnings, test failures, and Credo violations. Guard rail: `mix compile --warnings-as-errors && mix test && mix credo --strict`. |
| **secure** | Run `mix deps.audit` and `mix sobelow`. Check for atom exhaustion from user input, unsafe deserialization with `:erlang.binary_to_term`, SQL injection in raw Ecto queries, and missing CSRF protection. |

### SHIP Phase

| Skill | Elixir Adaptation |
|--|--|
| **ship** | Pre-flight: `mix test && mix credo --strict && mix dialyzer && mix format --check-formatted`. Verify release builds with `mix release`. |
| **finish** | Ensure version is bumped in `mix.exs`. Verify `config/runtime.exs` handles all environment variables. Confirm release configuration includes all required applications. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--|--|--|
| Tests pass | `mix test 2>&1 \| grep 'tests'` | 0 failures |
| Compiler warnings | `mix compile --warnings-as-errors 2>&1; echo $?` | exit code 0 |
| Credo violations | `mix credo --strict 2>&1 \| tail -1` | 0 issues |
| Dialyzer | `mix dialyzer 2>&1 \| tail -1` | 0 warnings |
| Format check | `mix format --check-formatted 2>&1; echo $?` | exit code 0 |
| Test coverage | `mix test --cover 2>&1 \| grep 'Total'` | >= 85% |
| Dependency vulnerabilities | `mix deps.audit 2>&1 \| tail -1` | 0 |
| Response time | `curl -s -o /dev/null -w '%{time_total}' http://localhost:4000/api/health` | < 0.01s |

---

## Common Verify Commands

### Tests pass
```bash
mix test --max-failures 1
```

### Compile clean (warnings as errors)
```bash
mix compile --warnings-as-errors
```

### Credo (static analysis)
```bash
mix credo --strict
```

### Dialyzer (type checking)
```bash
mix dialyzer
```

### Format check
```bash
mix format --check-formatted
```

### Security audit
```bash
mix deps.audit
mix sobelow --config
```

### API responds
```bash
curl -s -o /dev/null -w '%{time_total}' http://localhost:4000/api/health
```

---

## Tool Integration

### ExUnit

Godmode's TDD cycle maps directly to ExUnit:

```bash
# RED step: run single test file, expect failure
mix test test/my_app/services/user_service_test.exs

# GREEN step: run single test, expect pass
mix test test/my_app/services/user_service_test.exs

# After GREEN: run full suite to catch regressions
mix test

# Coverage
mix test --cover

# Run only tagged tests
mix test --only integration
```

**Test patterns** for Godmode projects:
```elixir
# test/my_app/services/user_service_test.exs
defmodule MyApp.Services.UserServiceTest do
  use MyApp.DataCase, async: true

  alias MyApp.Services.UserService
  alias MyApp.Accounts.User

  import MyApp.AccountsFixtures

  describe "get_user/1" do
    test "returns user when found" do
      user = user_fixture(name: "Alice")

      assert {:ok, found} = UserService.get_user(user.id)
      assert found.name == "Alice"
    end

    test "returns error when not found" do
      assert {:error, :not_found} = UserService.get_user(Ecto.UUID.generate())
    end

    test "returns error for invalid id" do
      assert {:error, :invalid_id} = UserService.get_user("not-a-uuid")
    end
  end

  describe "create_user/1" do
    test "creates user with valid attrs" do
      attrs = %{name: "Bob", email: "bob@example.com"}

      assert {:ok, %User{} = user} = UserService.create_user(attrs)
      assert user.name == "Bob"
      assert user.email == "bob@example.com"
    end

    test "returns changeset error for invalid attrs" do
      assert {:error, %Ecto.Changeset{}} = UserService.create_user(%{name: ""})
    end
  end
end
```

**Mox-based testing** for external dependencies:
```elixir
# test/support/mocks.ex
Mox.defmock(MyApp.MockHTTPClient, for: MyApp.HTTPClient)
Mox.defmock(MyApp.MockPaymentGateway, for: MyApp.PaymentGateway)

# test/my_app/services/payment_service_test.exs
defmodule MyApp.Services.PaymentServiceTest do
  use MyApp.DataCase, async: true

  import Mox

  alias MyApp.Services.PaymentService

  setup :verify_on_exit!

  describe "charge/2" do
    test "processes payment through gateway" do
      expect(MyApp.MockPaymentGateway, :charge, fn amount, _opts ->
        assert amount == 2999
        {:ok, %{id: "ch_123", status: "succeeded"}}
      end)

      assert {:ok, charge} = PaymentService.charge(2999, currency: "usd")
      assert charge.status == "succeeded"
    end

    test "handles gateway failure" do
      expect(MyApp.MockPaymentGateway, :charge, fn _amount, _opts ->
        {:error, %{code: "card_declined", message: "Card was declined"}}
      end)

      assert {:error, reason} = PaymentService.charge(2999, currency: "usd")
      assert reason.code == "card_declined"
    end
  end
end
```

### Credo + Dialyzer

```yaml
# Guard rail for optimize loop
guard_rails:
  - command: mix test --max-failures 1
    expect: exit code 0
  - command: mix compile --warnings-as-errors
    expect: exit code 0
  - command: mix credo --strict
    expect: exit code 0
```

**Credo configuration** (`.credo.exs`):
```elixir
%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: %{
        enabled: [
          {Credo.Check.Readability.ModuleDoc, []},
          {Credo.Check.Readability.Specs, []},
          {Credo.Check.Design.TagTODO, [exit_status: 0]},
          {Credo.Check.Refactor.CyclomaticComplexity, [max_complexity: 8]},
          {Credo.Check.Warning.LazyLogging, []}
        ]
      }
    }
  ]
}
```

**Dialyzer** for type checking:
```bash
# Initial PLT build (one-time, slow)
mix dialyzer --plt

# Type check
mix dialyzer

# With detailed output
mix dialyzer --format dialyxir
```

---

## OTP Patterns

### GenServer

```elixir
# lib/my_app/cache/product_cache.ex
defmodule MyApp.Cache.ProductCache do
  use GenServer

  @moduledoc """
  In-memory product cache with TTL-based expiration.
  """

  # Client API

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @spec get(atom(), String.t()) :: {:ok, term()} | :miss
  def get(server \\ __MODULE__, key) do
    GenServer.call(server, {:get, key})
  end

  @spec put(atom(), String.t(), term(), pos_integer()) :: :ok
  def put(server \\ __MODULE__, key, value, ttl_ms \\ 300_000) do
    GenServer.cast(server, {:put, key, value, ttl_ms})
  end

  # Server callbacks

  @impl true
  def init(_opts) do
    table = :ets.new(:product_cache, [:set, :protected])
    {:ok, %{table: table}}
  end

  @impl true
  def handle_call({:get, key}, _from, %{table: table} = state) do
    case :ets.lookup(table, key) do
      [{^key, value, expiry}] ->
        if System.monotonic_time(:millisecond) < expiry do
          {:reply, {:ok, value}, state}
        else
          :ets.delete(table, key)
          {:reply, :miss, state}
        end

      [] ->
        {:reply, :miss, state}
    end
  end

  @impl true
  def handle_cast({:put, key, value, ttl_ms}, %{table: table} = state) do
    expiry = System.monotonic_time(:millisecond) + ttl_ms
    :ets.insert(table, {key, value, expiry})
    {:noreply, state}
  end
end
```

### Supervision Trees

```elixir
# lib/my_app/application.ex
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Database
      MyApp.Repo,

      # PubSub for Phoenix channels and LiveView
      {Phoenix.PubSub, name: MyApp.PubSub},

      # Application-level caches
      {MyApp.Cache.ProductCache, name: MyApp.Cache.ProductCache},

      # Background job processing
      {MyApp.Workers.Supervisor, []},

      # Rate limiter
      {MyApp.RateLimiter, []},

      # Web endpoint (must be last)
      MyAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: MyApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

```elixir
# lib/my_app/workers/supervisor.ex
defmodule MyApp.Workers.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    children = [
      {MyApp.Workers.EmailWorker, []},
      {MyApp.Workers.ReportWorker, []},
      {Task.Supervisor, name: MyApp.TaskSupervisor}
    ]

    # rest_for_one: if email worker crashes, restart report worker too
    Supervisor.init(children, strategy: :rest_for_one)
  end
end
```

### Task.Supervisor for concurrent operations

```elixir
# Parallel API calls with supervision
defmodule MyApp.Services.AggregationService do
  @spec fetch_dashboard(String.t()) :: {:ok, map()} | {:error, term()}
  def fetch_dashboard(user_id) do
    tasks = [
      Task.Supervisor.async(MyApp.TaskSupervisor, fn -> fetch_stats(user_id) end),
      Task.Supervisor.async(MyApp.TaskSupervisor, fn -> fetch_notifications(user_id) end),
      Task.Supervisor.async(MyApp.TaskSupervisor, fn -> fetch_recent_activity(user_id) end)
    ]

    results = Task.await_many(tasks, 5_000)

    {:ok, %{
      stats: Enum.at(results, 0),
      notifications: Enum.at(results, 1),
      activity: Enum.at(results, 2)
    }}
  rescue
    e -> {:error, e}
  end
end
```

---

## Framework Integration

### Phoenix LiveView

```yaml
# .godmode/config.yaml
framework: phoenix-liveview
test_command: mix test --max-failures 1
lint_command: mix credo --strict && mix dialyzer
build_command: mix compile --warnings-as-errors && mix assets.deploy
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:4000
```

LiveView-specific THINK considerations:
- LiveView lifecycle: `mount` -> `handle_params` -> `render`
- Event handling with `handle_event` and `handle_info`
- Real-time form validation with `validate` and `save` events
- PubSub for multi-user real-time updates
- LiveComponent extraction for reusable stateful components
- Temporary assigns for memory optimization on large lists

LiveView-specific patterns:
```elixir
# lib/my_app_web/live/task_list_live.ex
defmodule MyAppWeb.TaskListLive do
  use MyAppWeb, :live_view

  alias MyApp.Tasks

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "tasks")
    end

    tasks = Tasks.list_tasks()

    {:ok,
     socket
     |> assign(:page_title, "Tasks")
     |> stream(:tasks, tasks)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    task = Tasks.get_task!(id)
    {:ok, _} = Tasks.delete_task(task)
    {:noreply, stream_delete(socket, :tasks, task)}
  end

  @impl true
  def handle_info({:task_created, task}, socket) do
    {:noreply, stream_insert(socket, :tasks, task, at: 0)}
  end

  @impl true
  def handle_info({:task_updated, task}, socket) do
    {:noreply, stream_insert(socket, :tasks, task)}
  end
end
```

LiveView testing:
```elixir
# test/my_app_web/live/task_list_live_test.exs
defmodule MyAppWeb.TaskListLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "task list" do
    test "displays tasks", %{conn: conn} do
      task = insert(:task, title: "Fix bug")

      {:ok, view, html} = live(conn, ~p"/tasks")

      assert html =~ "Fix bug"
      assert has_element?(view, "#tasks-#{task.id}")
    end

    test "deletes task on click", %{conn: conn} do
      task = insert(:task, title: "Fix bug")

      {:ok, view, _html} = live(conn, ~p"/tasks")

      view
      |> element("#tasks-#{task.id} button[phx-click=delete]")
      |> render_click()

      refute has_element?(view, "#tasks-#{task.id}")
    end

    test "receives real-time updates", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/tasks")

      task = insert(:task, title: "New task")
      Phoenix.PubSub.broadcast(MyApp.PubSub, "tasks", {:task_created, task})

      assert has_element?(view, "#tasks-#{task.id}")
    end
  end
end
```

### Phoenix API (JSON)

```yaml
# .godmode/config.yaml
framework: phoenix-api
test_command: mix test --max-failures 1
lint_command: mix credo --strict && mix dialyzer
build_command: mix compile --warnings-as-errors
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:4000/api/health
```

Phoenix API-specific THINK considerations:
- Context modules for domain boundaries
- Changeset validation and error formatting
- Token-based authentication (Guardian, Joken)
- API versioning strategy
- Rate limiting with Hammer

---

## Deployment with Fly.io

### Release configuration

```elixir
# mix.exs
def project do
  [
    app: :my_app,
    version: "0.1.0",
    elixir: "~> 1.17",
    releases: [
      my_app: [
        include_executables_for: [:unix],
        applications: [runtime_tools: :permanent]
      ]
    ]
  ]
end
```

```elixir
# config/runtime.exs
import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL not set"

  config :my_app, MyApp.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE not set"

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :my_app, MyAppWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [ip: {0, 0, 0, 0, 0, 0, 0, 0}, port: port],
    secret_key_base: secret_key_base
end
```

### Fly.io deployment

```toml
# fly.toml
app = "my-app"
primary_region = "iad"

[build]

[env]
  PHX_HOST = "my-app.fly.dev"
  PORT = "8080"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = "stop"
  auto_start_machines = true
  min_machines_running = 1

  [http_service.concurrency]
    type = "connections"
    hard_limit = 1000
    soft_limit = 750

[[vm]]
  memory = "1gb"
  cpu_kind = "shared"
  cpus = 1
```

```dockerfile
# Dockerfile
ARG ELIXIR_VERSION=1.17.0
ARG OTP_VERSION=27.0
ARG DEBIAN_VERSION=bookworm-20240701-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder
RUN apt-get update -y && apt-get install -y build-essential git
WORKDIR /app

ENV MIX_ENV="prod"
RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV && mix deps.compile

COPY config/config.exs config/${MIX_ENV}.exs config/
COPY lib lib
COPY priv priv
COPY assets assets

RUN mix assets.deploy && mix compile && mix release

FROM ${RUNNER_IMAGE}
RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses5 locales ca-certificates
WORKDIR /app
COPY --from=builder /app/_build/prod/rel/my_app ./

ENV LANG en_US.UTF-8
CMD ["/app/bin/server"]
```

```bash
# Deploy to Fly.io
fly deploy

# Run migrations
fly ssh console -C "/app/bin/migrate"

# Open remote IEx
fly ssh console -C "/app/bin/my_app remote"

# Scale
fly scale count 2

# View logs
fly logs
```

Godmode ship integration with Fly.io:
```bash
/godmode:ship --pre-flight "mix test && mix credo --strict && mix dialyzer" \
  --deploy "fly deploy"
```

### Hot code upgrades (advanced)

```bash
# Build an upgrade release
MIX_ENV=prod mix release --overwrite

# Elixir releases support hot upgrades via appup/relup files
# For most deployments, rolling restarts via Fly.io are simpler and safer
```

---

## Example: Full Workflow for Building an Elixir Service

### Scenario
Build a real-time notification service using Phoenix with LiveView dashboard, GenServer-based rate limiting, PubSub for fan-out delivery, and PostgreSQL persistence.

### Step 1: Think (Design)
```
/godmode:think I need a notification service with Phoenix — multi-channel
delivery (email, push, in-app), rate limiting per user with GenServer,
LiveView admin dashboard showing delivery stats in real-time, PubSub for
broadcasting notifications to connected clients, Oban for reliable
background job processing.
```

Godmode produces a spec at `docs/specs/notification-service.md` containing:
- Typespecs: `Notification.t()`, `Channel.t()`, `DeliveryStatus.t()`
- Context module: `Notifications` with public API functions
- GenServer: `RateLimiter` with per-user token bucket algorithm
- Oban workers: `EmailWorker`, `PushWorker`, `InAppWorker`
- LiveView: `DashboardLive` with real-time delivery metrics
- Supervision tree: `Application` -> `RateLimiter` + `Oban` + `Endpoint`

### Step 2: Build (TDD)
```
/godmode:build
```

**Task 1 — RED:**
```elixir
# test/my_app/notifications_test.exs
defmodule MyApp.NotificationsTest do
  use MyApp.DataCase, async: true

  alias MyApp.Notifications

  describe "send_notification/1" do
    test "creates notification and enqueues delivery job" do
      attrs = %{
        recipient_id: Ecto.UUID.generate(),
        channel: :email,
        subject: "Welcome",
        body: "Hello, welcome!"
      }

      assert {:ok, notification} = Notifications.send_notification(attrs)
      assert notification.status == :pending
      assert_enqueued(worker: MyApp.Workers.EmailWorker, args: %{id: notification.id})
    end

    test "rejects when rate limited" do
      recipient_id = Ecto.UUID.generate()
      # Exhaust rate limit
      for _ <- 1..10, do: Notifications.send_notification(%{recipient_id: recipient_id, channel: :email, subject: "X", body: "X"})

      assert {:error, :rate_limited} = Notifications.send_notification(%{recipient_id: recipient_id, channel: :email, subject: "X", body: "X"})
    end
  end
end
```
Commit: `test(red): Notification context — failing delivery and rate limiting tests`

**Task 1 — GREEN:**
Implement `Notifications` context with Oban job enqueuing and rate limiter integration.
Commit: `feat: Notification context — multi-channel delivery with rate limiting`

### Step 3: Optimize
```
/godmode:optimize --goal "reduce notification delivery latency" \
  --verify "curl -s -o /dev/null -w '%{time_total}' -X POST http://localhost:4000/api/notifications -H 'Content-Type: application/json' -d '{\"recipient_id\":\"user-1\",\"channel\":\"email\",\"subject\":\"test\",\"body\":\"test\"}'" \
  --target "< 0.01"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|--|--|--|--|--|--|
| 1 | Synchronous rate limiter call | Use ETS for O(1) lookups instead of GenServer call | 15ms | 6ms | KEEP |
| 2 | Ecto insert overhead | Use `Repo.insert` with `returning: false` | 6ms | 4ms | KEEP |
| 3 | JSON encoding in controller | Use Jason encoder with iodata | 4ms | 3ms | KEEP |

### Step 4: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
mix test                      ✓ 35/35 passing
mix compile --warnings-as-errors ✓ 0 warnings
mix credo --strict            ✓ 0 issues
mix dialyzer                  ✓ 0 warnings
mix format --check-formatted  ✓ All formatted
```

---

## Elixir-Specific Tips

### 1. Behaviours are your spec
In the THINK phase, define behaviours (`@callback`) before implementations. Behaviours serve as contracts that enable Mox-based testing and make the system pluggable:
```elixir
defmodule MyApp.PaymentGateway do
  @callback charge(pos_integer(), keyword()) :: {:ok, map()} | {:error, map()}
end
```

### 2. Let it crash — but with supervision
Design for failure from the start. Every stateful process should be under a supervisor. Godmode's think skill generates supervision trees that match your domain:
```
/godmode:think --include "supervision tree design, restart strategies, graceful degradation"
```

### 3. Use contexts for domain boundaries
Phoenix contexts (`lib/my_app/accounts.ex`, `lib/my_app/orders.ex`) define clear domain boundaries. Each context owns its schema, queries, and business logic. Cross-context communication goes through the public API.

### 4. Pattern matching over conditionals
Elixir excels at multi-clause pattern matching. Prefer multiple function heads over `if`/`case` chains:
```elixir
# Prefer this
def process(%{status: :pending} = order), do: charge_payment(order)
def process(%{status: :paid} = order), do: fulfill(order)
def process(%{status: :shipped} = order), do: {:ok, order}

# Over nested conditionals
```

### 5. Dialyzer catches bugs types miss
Run `mix dialyzer` as a guard rail even though Elixir is dynamically typed. Dialyzer catches impossible pattern matches, unreachable code, and spec violations that tests might miss:
```
/godmode:optimize --goal "eliminate dialyzer warnings" --verify "mix dialyzer 2>&1 | grep -c 'warning'" --target "0"
```
