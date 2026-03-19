# Recipe: Modernizing a Legacy Monolith

> From "nobody wants to touch this code" to "actually maintainable." A complete Godmode workflow for legacy modernization using the strangler fig pattern.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `onboard → quality → refactor → migrate → test → deploy → observe` |
| **Timeline** | Weeks to months (incremental, never a big bang) |
| **Team size** | 2-6 developers |
| **Example project** | "OrderSystem" — a 200K-line PHP monolith migrated to Node.js/TypeScript |

---

## The Scenario

You inherited a legacy system:
- 200K lines of PHP 5.6, running since 2012
- No tests (0% coverage)
- 47 database tables with no foreign keys
- Business logic mixed into SQL queries inside controllers
- Single MySQL server handling everything
- Deployed via FTP to a bare-metal server
- Documentation: one outdated wiki page

Your mission: modernize it incrementally without a rewrite, keeping the system running the entire time.

---

## Phase 1: Understand What You Have (Week 1)

### Step 1: Onboard — Map the Existing System

```
> /godmode:onboard

Godmode: Scanning codebase...

CODEBASE ANALYSIS:

Language: PHP 5.6 (98%), JavaScript (2%)
Size: 203,847 lines across 1,247 files
Framework: Custom (no framework)
Database: MySQL 5.7, 47 tables
Structure:
  /controllers/    — 89 files, 42K lines (routes + business logic + SQL)
  /models/         — 31 files, 8K lines (thin wrappers around SQL)
  /views/          — 312 files, 67K lines (PHP templates)
  /lib/            — 28 files, 12K lines (utilities)
  /includes/       — 45 files, 19K lines (config, bootstrap, helpers)
  /public/         — static assets
  /sql/            — raw migration scripts (unversioned)

Key findings:
  - No dependency injection — globals everywhere
  - Database queries embedded in 73 of 89 controllers
  - No separation between read and write paths
  - Session-based auth with no CSRF protection
  - 14 cron jobs defined in crontab, not in code

Entry points:
  - /controllers/OrderController.php — the heart of the system (3,200 lines)
  - /controllers/UserController.php — authentication and user management
  - /controllers/ReportController.php — generates business reports

Architecture: God-class controllers calling MySQL directly.
No service layer, no repository pattern.

Saved: docs/onboarding/ordersystem-architecture.md
Saved: docs/onboarding/ordersystem-code-tour.md
```

### Step 2: Quality — Assess the Damage

```
> /godmode:quality

Godmode: Running code quality analysis...

QUALITY REPORT:

Complexity:
  Average cyclomatic complexity: 23.4 (target: < 10)
  Files with complexity > 50: 12 files
  Worst offender: OrderController.php (complexity: 147)

Duplication:
  Duplicated blocks: 234 (18.7% of codebase)
  Largest duplicate: 89 lines (order validation logic, copied 6 times)

Dependencies:
  External packages: 0 (everything hand-rolled)
  Circular dependencies: N/A (no module system)

Tech debt score: 847 / 1000 (CRITICAL)
  - No tests: +200 points
  - No type safety: +150 points
  - Massive duplication: +150 points
  - God classes: +100 points
  - Hardcoded configuration: +80 points
  - No error handling pattern: +70 points
  - SQL injection risk: +50 points
  - No dependency management: +47 points

TOP 10 HOTSPOTS (most-changed, highest-complexity files):
  1. OrderController.php — 3,200 lines, complexity 147, 312 git commits
  2. UserController.php — 1,800 lines, complexity 89, 198 commits
  3. ReportController.php — 2,100 lines, complexity 112, 156 commits
  4. PaymentController.php — 1,400 lines, complexity 67, 143 commits
  5. InventoryController.php — 1,100 lines, complexity 54, 121 commits
  [...]

Saved: docs/quality/ordersystem-quality-report.md
```

---

## Phase 2: Establish Safety Nets (Week 2-3)

### Step 3: Test — Add Characterization Tests

Before changing anything, capture current behavior:

```
> /godmode:test --strategy characterization

Godmode: Analyzing system behavior...

CHARACTERIZATION TEST STRATEGY:
You have zero tests. Before refactoring, we need to capture the current
behavior as a safety net. Writing tests that document WHAT the system does
today, not what it SHOULD do.

Approach:
  1. HTTP-level integration tests (black box)
  2. Database state assertions
  3. Capture actual responses as golden files

Writing characterization tests for top 5 hotspots...

Tests written:
  tests/characterization/orders.test.js        — 34 tests
  tests/characterization/users.test.js         — 22 tests
  tests/characterization/reports.test.js       — 18 tests
  tests/characterization/payments.test.js      — 15 tests
  tests/characterization/inventory.test.js     — 12 tests

Total: 101 characterization tests, all passing against current system
Coverage: ~35% of critical paths

These tests make HTTP requests to the running system and verify:
  - Response status codes
  - Response body structure (JSON schema)
  - Database state changes
  - Side effects (email sending mocked)

Commit: "test: characterization tests for top 5 modules — 101 tests"
```

### Step 4: Observe — Add Monitoring Before Changing Anything

```
> /godmode:observe --legacy

Godmode: Adding observability to legacy system...

OBSERVABILITY ADDITIONS (non-invasive):

1. Access log parsing (nginx → Prometheus):
   - Request rate by endpoint
   - Response time distribution
   - Error rate by status code

2. MySQL slow query log → dashboard:
   - Queries > 100ms
   - Table lock contention
   - Connection pool usage

3. Application-level metrics (PHP middleware):
   - Added lightweight timing middleware (12 lines of PHP)
   - Logs request duration to syslog
   - Zero dependency additions

4. Health check endpoint:
   - /health — returns 200 if DB is reachable
   - Added to load balancer monitoring

Baseline metrics captured:
  - Average response time: 890ms (p50), 3.2s (p99)
  - Error rate: 2.3% (mostly 500s from unhandled exceptions)
  - Slow queries: 47 queries > 1 second
  - Peak load: 120 requests/second

Saved: docs/observability/baseline-metrics.md
Commit: "observe: add baseline monitoring to legacy system"
```

---

## Phase 3: Strangler Fig — Build the New Alongside the Old (Week 3-12)

The strangler fig pattern: build new services that gradually replace legacy functionality. The old and new systems coexist, with a routing layer directing traffic.

### Step 5: Architect — Design the Migration Architecture

```
> /godmode:architect --strategy strangler-fig

Godmode: Designing migration architecture...

STRANGLER FIG ARCHITECTURE:

                    ┌─────────────┐
     requests ────→ │   Reverse   │
                    │   Proxy     │
                    │  (nginx)    │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │   Router    │
                    │  (by path)  │
                    └──┬───────┬──┘
                       │       │
              ┌────────┴──┐ ┌──┴────────┐
              │  Legacy   │ │   New     │
              │  PHP App  │ │  Node.js  │
              │           │ │  Services │
              └─────┬─────┘ └─────┬─────┘
                    │             │
              ┌─────┴─────────────┴─────┐
              │     Shared MySQL DB     │
              │  (both systems read/    │
              │   write same tables)    │
              └─────────────────────────┘

Migration order (by business value and risk):
  1. User auth (high risk, foundational)
  2. Order listing/search (high traffic, read-only — safe)
  3. Reporting (isolated, no writes)
  4. Payment processing (high value, needs careful testing)
  5. Order creation (the heart — last to migrate)
  6. Inventory management
  7. Admin panel

Saved: docs/architecture/strangler-fig-plan.md
Saved: docs/adr/002-strangler-fig-migration.md
```

### Step 6: Migrate — Service by Service

For each module, the process is:

#### Migration 1: Order Listing (Week 4-5)

```
> /godmode:think Migrate order listing from PHP to Node.js/TypeScript.
  Read-only endpoint. Must return identical JSON structure.
  Must handle all existing query parameters: status, date_from, date_to,
  customer_id, page, per_page, sort_by.

Saved: docs/specs/migrate-order-listing.md

> /godmode:plan

PLAN: 8 tasks
  Task 1: Set up Node.js project with TypeScript
  Task 2: Create database connection (read replica)
  Task 3: Implement Order repository (SQL → TypeScript)
  Task 4: Implement order listing service
  Task 5: Create GET /api/orders endpoint with validation
  Task 6: Add pagination matching legacy format exactly
  Task 7: Shadow testing — run both old and new, compare responses
  Task 8: Nginx routing rule to send /api/orders to new service

> /godmode:build

[builds all 8 tasks with TDD]
BUILD COMPLETE: 8 tasks, 31 tests, all passing.

> /godmode:verify

Godmode: Running shadow comparison...

SHADOW TEST RESULTS (1000 production-mirrored requests):
  Identical responses: 994 / 1000 (99.4%)
  Differences:
    - 4 responses: date format differs (ISO vs. MySQL datetime) — FIXED
    - 2 responses: null vs. empty string for optional fields — FIXED

After fixes: 1000 / 1000 identical ✓

> /godmode:deploy --strategy canary --percentage 5

Canary deployment:
  T+0:   5% traffic to new service
  T+30:  ✓ Error rate 0%, latency improved (890ms → 120ms)
  T+60:  Promoting to 25%
  T+120: Promoting to 100%
  ✓ Migration complete. Legacy order listing decommissioned.
```

#### Migration 2: Authentication (Week 5-6)

```
> /godmode:think Migrate session-based PHP auth to JWT-based Node.js auth.
  Must support both old session cookies (for legacy pages not yet migrated)
  and new JWT tokens (for migrated API endpoints).

> /godmode:auth --migration-mode

Godmode: Implementing dual-mode authentication...

DUAL AUTH STRATEGY:
  - New endpoints: JWT Bearer tokens
  - Legacy endpoints: PHP session cookies (unchanged)
  - Bridge: Auth service issues both JWT and sets PHP session
  - Login flow: New Node.js login → issues JWT + creates PHP session
  - Gradual migration: As each endpoint migrates, it switches to JWT

Files created:
  src/services/auth.service.ts
  src/middleware/dual-auth.ts       — accepts JWT OR session cookie
  src/utils/php-session-bridge.ts   — creates PHP session for legacy pages

Commit: "feat: dual-mode auth — JWT for new services, session bridge for legacy"
```

#### Migration 3-7: Repeat Pattern

Each subsequent module follows the same pattern:

```
think → plan → build → verify (shadow test) → deploy (canary) → decommission legacy
```

### Step 7: Refactor — Clean Up As You Go

After each migration, clean up the new code:

```
> /godmode:refactor --target src/services/order.service.ts

Godmode: Analyzing refactoring opportunities...

REFACTORING PLAN:
  1. Extract query builder from order service (single responsibility)
  2. Introduce repository pattern (decouple from SQL)
  3. Extract pagination logic to shared utility
  4. Add proper error types (replace generic Error)

Impact analysis:
  Files affected: 4
  Tests affected: 12 (will need updates)
  Risk: LOW (well-tested code)

[executes refactoring with test updates]

Commit: "refactor: extract OrderRepository, shared pagination, typed errors"
```

---

## Phase 4: Database Migration (Week 8-12)

### Step 8: Schema Migration — Fix the Database

```
> /godmode:migrate --analyze

Godmode: Analyzing database schema...

SCHEMA ANALYSIS:

Problems found:
  1. No foreign keys — 23 relationships have no constraints
  2. No indexes — 18 queries doing full table scans
  3. Mixed data types — created_at is VARCHAR in 6 tables, DATETIME in 12
  4. No soft delete — records hard-deleted, breaking audit trail
  5. Denormalized data — customer address stored in 4 different tables
  6. No enum constraints — status fields accept any string

MIGRATION PLAN (non-breaking, additive):

Phase A: Add missing indexes (zero downtime):
  migration_001: Add 18 indexes identified by slow query log

Phase B: Add foreign keys (zero downtime):
  migration_002: Add foreign keys with ON DELETE SET NULL

Phase C: Normalize data types (zero downtime):
  migration_003: Add proper DATETIME columns alongside VARCHAR dates
  migration_004: Backfill DATETIME columns from VARCHAR
  migration_005: Update application to read from new columns
  migration_006: Drop old VARCHAR date columns

Phase D: Add constraints (requires app coordination):
  migration_007: Add CHECK constraints for status enums
  migration_008: Add NOT NULL constraints where appropriate

CRITICAL: Each migration is independently deployable and reversible.
Never combine schema changes with data changes.

Saved: docs/migrations/ordersystem-migration-plan.md
```

```
> /godmode:migrate --execute phase-a

Godmode: Executing Phase A — adding indexes...

Migrations executed:
  migration_001_add_orders_status_index.sql ✓
  migration_001_add_orders_customer_index.sql ✓
  migration_001_add_orders_created_at_index.sql ✓
  [... 15 more indexes ...]

Impact:
  Slow queries: 47 → 8 (83% reduction)
  Average query time: 340ms → 45ms

Commit: "migrate: add 18 missing database indexes — 83% slow query reduction"
```

---

## Phase 5: Decommission Legacy (Week 12+)

### Step 9: Quality — Final Assessment

```
> /godmode:quality --compare-baseline

Godmode: Comparing current state to initial baseline...

MODERNIZATION PROGRESS:

                        Before          After           Change
Lines of code:         203,847         52,340          -74.3%
Languages:             PHP 5.6         TypeScript      Modern
Test coverage:         0%              89%             +89%
Cyclomatic complexity: 23.4 avg        6.2 avg         -73.5%
Duplication:           18.7%           2.1%            -88.8%
Tech debt score:       847/1000        124/1000        -85.4%
Response time (p50):   890ms           85ms            -90.4%
Response time (p99):   3,200ms         340ms           -89.4%
Error rate:            2.3%            0.12%           -94.8%
Deploy frequency:      Monthly (FTP)   Daily (CI/CD)   30x improvement
Deploy time:           45 min manual   4 min automated 91% faster

Modules migrated:      7/7             100%
Legacy code remaining: 0 lines         Fully decommissioned

Saved: docs/quality/modernization-final-report.md
```

### Step 10: Ship — Final Cutover

```
> /godmode:ship --milestone "legacy-decommission"

Godmode: Shipping final legacy decommission...

DECOMMISSION CHECKLIST:
  ✓ All endpoints migrated to Node.js/TypeScript
  ✓ All tests passing (342 tests)
  ✓ PHP session bridge no longer needed (all endpoints on JWT)
  ✓ Legacy PHP application stopped
  ✓ DNS updated to point directly to new service
  ✓ Old server scheduled for decommission in 30 days
  ✓ Monitoring confirms zero traffic to legacy

Legacy system decommissioned. Migration complete.
```

---

## The Strangler Fig Pattern with Godmode

```
Week 1-2:  [████████████████████████████████████████] Legacy 100%
Week 3:    [████████████████████████████████████ ····] Legacy 90% | New 10%
Week 5:    [████████████████████████████ ············] Legacy 70% | New 30%
Week 8:    [████████████████ ························] Legacy 40% | New 60%
Week 10:   [████████ ································] Legacy 20% | New 80%
Week 12:   [·········································] Legacy 0%  | New 100%
```

Key principle: at every point in this timeline, the system is fully functional in production. There is never a "big bang" cutover.

---

## Godmode Skills Used at Each Phase

| Phase | Skills | Purpose |
|-------|--------|---------|
| Understand | onboard, quality | Map the codebase, quantify the debt |
| Safety nets | test, observe | Characterization tests, baseline metrics |
| Architecture | architect, adr | Design strangler fig, document decisions |
| Migrate (per module) | think, plan, build, verify, deploy | Incremental migration |
| Refactor | refactor, quality | Clean up new code as you go |
| Database | migrate, query | Schema fixes, index optimization |
| Decommission | quality, ship | Final assessment, legacy shutdown |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Godmode Alternative |
|-------------|-------------|-------------------|
| Big-bang rewrite | 12+ months, no value until done, high risk | Strangler fig with incremental delivery |
| Migrate without tests | Break things you do not understand | Characterization tests first (`/godmode:test --strategy characterization`) |
| Migrate everything at once | Too many variables, impossible to debug | One module at a time with shadow testing |
| Skip monitoring | Cannot prove new system is better | Baseline metrics before, continuous comparison after |
| Perfectionism | "Let's also redesign the data model" | Migrate first, refactor second — working beats perfect |

---

## Custom Chain for Legacy Modernization

```yaml
# .godmode/chains.yaml
chains:
  migrate-module:
    description: "Migrate one legacy module to the new system"
    steps:
      - think
      - plan
      - build
      - test
      - verify   # shadow testing against legacy
      - deploy:
          strategy: canary
          start: 5
      - observe   # compare metrics old vs. new

  legacy-assess:
    description: "Initial legacy system assessment"
    steps:
      - onboard
      - quality
      - observe
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Microservices Migration Recipe](microservices-migration.md) — If you are going from monolith to microservices
- [Performance Optimization Recipe](performance-optimization.md) — Optimizing the newly migrated services
- [Incident Response Recipe](incident-response.md) — When the migration causes production issues
