# Recipe: Taming a Legacy Codebase

> From "nobody wants to touch this code" to "I can actually ship features confidently." Understanding, testing, and modernizing legacy code without a rewrite.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `onboard → quality → legacy → refactor → test → optimize → ship` |
| **Timeline** | Ongoing (incremental improvement, 2-4 weeks for first visible impact) |
| **Team size** | 1-4 developers |
| **Example project** | "BillingEngine" — a 150K-line Java monolith with no tests, high complexity, and tribal knowledge |

---

## Prerequisites

- Access to the legacy codebase and its runtime environment
- Ability to deploy changes (even if the process is manual)
- Permission to add tests and refactor (not just fix bugs)
- Godmode installed and configured

---

## The Scenario

You joined a team that owns a legacy system:
- 150K lines of Java, written over 8 years by 12 different developers
- 23% test coverage (mostly broken or flaky tests)
- Average cyclomatic complexity: 31 (the worst class has complexity 247)
- Deployment: once every 2 weeks, takes 4 hours, usually breaks something
- Documentation: JavaDoc from 2017, one architecture diagram that is wrong
- Tribal knowledge: two engineers who know how it works, one is leaving

Your mission: make this codebase maintainable enough that the team can ship features confidently, without a multi-year rewrite.

---

## Session Transcript

### Phase 1: Onboard — Understand What You Have

Do not change a single line of code until you understand the system.

```
> /godmode:onboard

Godmode: Scanning codebase...

CODEBASE ANALYSIS:

Language: Java 11 (87%), JavaScript (8%), SQL (5%)
Size: 152,340 lines across 1,843 files
Framework: Spring Boot 2.3 (outdated, current is 3.x)
Database: PostgreSQL 12 (4 schemas, 89 tables)
Build: Maven (7 modules)
Tests: 342 tests, 23% coverage, 41 tests failing

Module structure:
  billing-core/        — 42K lines, business logic + domain model
  billing-api/         — 18K lines, REST controllers
  billing-jobs/        — 12K lines, scheduled batch processing
  billing-integration/ — 22K lines, Stripe, Salesforce, QuickBooks
  billing-common/      — 8K lines, shared utilities
  billing-migration/   — 3K lines, database migrations
  billing-legacy/      — 47K lines, deprecated code still referenced

Key findings:
  - billing-legacy/ has 47K lines that should not exist but are still called
  - 14 circular dependencies between modules
  - 89 database tables, 23 with no foreign keys
  - 7 different date/time handling approaches
  - 3 separate logging frameworks in use
  - God class: InvoiceProcessor.java (4,200 lines, 67 public methods)
  - Database access: mixed JDBC, JPA, and raw SQL across modules

Entry points (most business-critical):
  1. InvoiceProcessor.java — generates monthly invoices for all customers
  2. PaymentService.java — processes Stripe payments and webhooks
  3. SubscriptionManager.java — handles plan changes, upgrades, downgrades
  4. ReconciliationJob.java — daily job matching payments to invoices
  5. UsageAggregator.java — hourly job computing usage-based billing

Architecture: Anemic domain model. Services contain all business logic.
Controllers call services, services call repositories, repositories use
mixed JPA and raw SQL. No clear domain boundaries.

Saved: docs/onboarding/billingengine-codebase-map.md
Saved: docs/onboarding/billingengine-code-tour.md

Commit: "docs: BillingEngine codebase map and code tour"
```

**Time: 30 minutes.** Worth every second. You now have a map instead of wandering blind.

### Phase 2: Quality — Measure the Damage

```
> /godmode:quality

Godmode: Running comprehensive quality analysis...

QUALITY REPORT:

Complexity:
  Average cyclomatic complexity: 31.4 (target: < 10)
  Files with complexity > 50: 23 files
  Top offenders:
    InvoiceProcessor.java      — complexity 247, 4,200 lines
    PaymentService.java        — complexity 134, 2,800 lines
    SubscriptionManager.java   — complexity 98, 1,900 lines
    ReconciliationJob.java     — complexity 87, 1,600 lines
    UsageAggregator.java       — complexity 76, 1,400 lines

Duplication:
  Duplicated blocks: 412 (22.1% of codebase)
  Largest duplicates:
    - Invoice validation logic: copied 8 times across 5 files
    - Date range calculation: copied 11 times
    - Stripe API retry logic: copied 4 times with subtle differences

Test health:
  Total tests: 342
  Passing: 301 (88%)
  Failing: 41 (12%) — most broken by code changes that ignored tests
  Flaky: 17 (5%) — timing-dependent or depend on test execution order
  Coverage: 23% overall
    billing-core: 31%
    billing-api: 18%
    billing-jobs: 8%
    billing-integration: 12%
    billing-common: 67%
    billing-legacy: 0%

Dependencies:
  47 direct dependencies, 18 with known vulnerabilities
  Spring Boot 2.3: end of life (security patches stopped)
  3 dependencies with critical CVEs

Tech debt score: 891 / 1000 (CRITICAL)

TOP 10 HOTSPOTS (most-changed + highest-complexity):
  1. InvoiceProcessor.java — 4,200 lines, complexity 247, 489 git commits
  2. PaymentService.java — 2,800 lines, complexity 134, 342 commits
  3. SubscriptionManager.java — 1,900 lines, complexity 98, 267 commits
  4. ReconciliationJob.java — 1,600 lines, complexity 87, 198 commits
  5. UsageAggregator.java — 1,400 lines, complexity 76, 156 commits
  [...]

Hotspots are where high complexity meets frequent changes — the highest
return on investment for refactoring.

Saved: docs/quality/billingengine-quality-report.md
Saved: docs/quality/billingengine-hotspot-map.md

Commit: "quality: BillingEngine analysis — complexity 31.4 avg, 22% duplication, 23% coverage"
```

**Time: 15 minutes.**

### Phase 3: Legacy — Create a Modernization Strategy

```
> /godmode:legacy

Godmode: Reading codebase map and quality report... Creating modernization strategy...

LEGACY MODERNIZATION STRATEGY:

Priority order (by ROI: business impact / effort):

  Priority 1: Fix the test suite (Week 1)
    Why: You cannot refactor safely without tests.
    Actions:
      - Fix 41 failing tests (or delete if testing dead code)
      - Fix 17 flaky tests (remove timing dependencies)
      - Add characterization tests for top 5 hotspots
    Expected outcome: Green test suite as a foundation

  Priority 2: Tame InvoiceProcessor (Week 2-3)
    Why: Highest complexity (247), most changed file (489 commits),
         every bug fix is a risk.
    Actions:
      - Add characterization tests around current behavior
      - Extract method: break 67 public methods into cohesive groups
      - Extract class: InvoicePriceCalculator, InvoiceValidator,
        InvoiceFormatter, InvoicePersistence
      - Result: 4 focused classes instead of 1 god class
    Expected outcome: Complexity per class < 30

  Priority 3: Eliminate duplication (Week 3-4)
    Why: 22% duplication means bugs are fixed in one copy but not others.
    Actions:
      - Extract shared invoice validation to InvoiceValidationService
      - Extract DateRangeCalculator utility
      - Extract StripeRetryPolicy (one implementation, not 4 subtly different ones)
    Expected outcome: Duplication < 5%

  Priority 4: Upgrade Spring Boot (Week 4-5)
    Why: End-of-life framework with known CVEs.
    Actions:
      - Upgrade 2.3 → 2.7 → 3.0 → 3.2 (incremental, not big bang)
      - Fix breaking changes at each step
      - Run full test suite after each upgrade
    Expected outcome: Supported framework, CVEs resolved

  Priority 5: Decommission billing-legacy (Week 5-6)
    Why: 47K lines of "deprecated" code still being called.
    Actions:
      - Map all references to billing-legacy classes
      - Migrate callers to billing-core equivalents
      - Delete billing-legacy module
    Expected outcome: 47K fewer lines of code

WHAT NOT TO DO:
  - Do NOT rewrite from scratch (the legacy system works, a rewrite will take
    longer than estimated and introduce new bugs)
  - Do NOT refactor without tests (you will break things you do not understand)
  - Do NOT try to fix everything at once (focus on hotspots)
  - Do NOT chase 100% test coverage (cover the hotspots and critical paths)

Saved: docs/legacy/billingengine-modernization-strategy.md

Commit: "legacy: BillingEngine modernization strategy — 5 priorities over 6 weeks"
```

**Time: 20 minutes.**

### Phase 4: Refactor — Execute Priority 2 (Tame the God Class)

This is the most impactful refactoring. Let us walk through it in detail.

```
> /godmode:refactor --target InvoiceProcessor.java

Godmode: Analyzing InvoiceProcessor.java...

REFACTORING PLAN: InvoiceProcessor.java (4,200 lines → 4 focused classes)

Current state:
  InvoiceProcessor has 67 public methods handling:
    - Price calculation (12 methods)
    - Invoice validation (9 methods)
    - Invoice formatting and PDF generation (8 methods)
    - Database persistence (11 methods)
    - Stripe integration (7 methods)
    - Email delivery (5 methods)
    - Logging and auditing (8 methods)
    - Orchestration (7 methods)

Target state:
  InvoiceProcessor          — orchestration only (7 methods, ~200 lines)
  InvoicePriceCalculator    — pure calculation logic (12 methods, ~600 lines)
  InvoiceValidator          — validation rules (9 methods, ~400 lines)
  InvoiceFormatter          — PDF and email formatting (13 methods, ~700 lines)
  InvoicePersistence        — database operations (11 methods, ~500 lines)
  StripeInvoiceService      — Stripe-specific logic (7 methods, ~400 lines)

Refactoring steps (each step is a separate commit, tests pass after each):

  Step 1: Add characterization tests for InvoiceProcessor
    Tests capture current behavior: 34 tests covering critical paths
    These tests will catch any behavior change during refactoring.

  Step 2: Extract InvoicePriceCalculator
    Move: calculateSubtotal, applyDiscount, applyTax, calculateTotal,
          computeProration, calculateUsageFees, ...
    Technique: Extract Class (move methods + fields they depend on)
    Tests: move related tests, add new unit tests for extracted class

  Step 3: Extract InvoiceValidator
    Move: validateLineItems, validateCustomer, validateDates,
          checkDuplicateInvoice, ...
    Technique: Extract Class
    Tests: pure validation logic — easy to unit test

  Step 4: Extract InvoiceFormatter
    Move: generatePdf, formatLineItems, renderTemplate,
          prepareEmailBody, formatCurrency, ...
    Technique: Extract Class
    Tests: formatter tests with expected output comparisons

  Step 5: Extract InvoicePersistence
    Move: saveInvoice, updateStatus, findByCustomer, findOverdue, ...
    Technique: Extract Class (introduce Repository pattern)
    Tests: integration tests with test database

  Step 6: Extract StripeInvoiceService
    Move: createStripeInvoice, syncPaymentStatus, handleWebhook, ...
    Technique: Extract Class
    Tests: mock Stripe API, test retry logic

  Step 7: Clean up InvoiceProcessor
    InvoiceProcessor now delegates to extracted classes.
    Verify all 34 characterization tests still pass.

Impact analysis:
  Files that call InvoiceProcessor: 23 files
  Strategy: InvoiceProcessor keeps its public API initially.
  Internal implementation delegates to new classes.
  Callers are migrated to new classes incrementally (later).

Risk assessment: LOW
  - Characterization tests protect against behavior changes
  - Each step is a separate commit (easy to revert)
  - InvoiceProcessor public API does not change (callers unaffected)

Executing...

  Step 1: ✓ 34 characterization tests written and passing
  Step 2: ✓ InvoicePriceCalculator extracted, 12 methods, tests pass
  Step 3: ✓ InvoiceValidator extracted, 9 methods, tests pass
  Step 4: ✓ InvoiceFormatter extracted, 13 methods, tests pass
  Step 5: ✓ InvoicePersistence extracted, 11 methods, tests pass
  Step 6: ✓ StripeInvoiceService extracted, 7 methods, tests pass
  Step 7: ✓ InvoiceProcessor cleaned up, 7 methods, all 34 characterization tests pass

Results:
  Before: 1 class, 4,200 lines, complexity 247
  After:  6 classes, avg 450 lines each, max complexity 28

Commit: "test: characterization tests for InvoiceProcessor — 34 tests"
Commit: "refactor: extract InvoicePriceCalculator from InvoiceProcessor"
Commit: "refactor: extract InvoiceValidator from InvoiceProcessor"
Commit: "refactor: extract InvoiceFormatter from InvoiceProcessor"
Commit: "refactor: extract InvoicePersistence from InvoiceProcessor"
Commit: "refactor: extract StripeInvoiceService from InvoiceProcessor"
Commit: "refactor: InvoiceProcessor delegates to extracted classes"
```

**Time: 3-4 hours.** The most valuable work in this entire recipe.

### Phase 5: Test — Build a Real Test Suite

```
> /godmode:test --coverage-target 70

Godmode: Analyzing test suite and designing strategy...

TEST STRATEGY FOR LEGACY CODE:

Rule: Do not aim for 100% coverage on legacy code. Cover the hotspots
and the code you are changing. 70% on hotspots is worth more than
30% everywhere.

Step 1: Fix the existing test suite
  Failing tests: 41
    - 28 tests: broken by code changes (updated to match current behavior)
    - 9 tests: testing deleted code (deleted)
    - 4 tests: testing billing-legacy (moved to legacy test suite)

  Flaky tests: 17
    - 11 tests: timing-dependent (replaced Thread.sleep with CountDownLatch)
    - 4 tests: database order-dependent (added explicit ordering)
    - 2 tests: random port conflicts (use dynamic port allocation)

  Result: 315 tests, all passing, zero flaky ✓

Step 2: Add tests for refactored code
  InvoicePriceCalculator: 22 unit tests (pure logic, easy to test)
  InvoiceValidator: 18 unit tests (validation rules)
  InvoiceFormatter: 12 unit tests (output formatting)
  InvoicePersistence: 15 integration tests
  StripeInvoiceService: 10 unit tests (mocked Stripe)

Step 3: Add tests for remaining hotspots
  PaymentService: 28 characterization tests + 14 unit tests
  SubscriptionManager: 22 characterization tests + 10 unit tests
  ReconciliationJob: 16 integration tests
  UsageAggregator: 12 integration tests

Test summary:
  Before: 342 tests (41 failing, 17 flaky), 23% coverage
  After: 504 tests (0 failing, 0 flaky), 71% coverage on hotspots

  Hotspot coverage:
    InvoiceProcessor (refactored): 89%
    PaymentService: 72%
    SubscriptionManager: 68%
    ReconciliationJob: 74%
    UsageAggregator: 71%

Commit: "test: fix 41 failing and 17 flaky tests — 315 tests, all green"
Commit: "test: add tests for refactored invoice classes — 77 new tests"
Commit: "test: characterization tests for payment, subscription, reconciliation, usage"
```

**Time: 2-3 days.** Tests are the foundation. Everything else depends on them.

### Phase 6: Optimize — Performance and Build Improvements

```
> /godmode:optimize --goal "reduce build time and deploy risk"

Godmode: Analyzing build and deployment...

OPTIMIZATION PLAN:

Build time:
  Before: 12 minutes (full Maven build with tests)
  Actions:
    - Enable Maven parallel build (-T 1C)
    - Add build cache (Maven Build Cache Extension)
    - Split slow integration tests into separate profile
    - Run unit tests in CI (fast), integration tests on merge to main
  After: 4 minutes (unit tests), 8 minutes (full with integration)

Deployment improvements:
  Before: Manual, 4 hours, error-prone
  Actions:
    - Dockerize the application (multi-stage build)
    - Add health check endpoint (/actuator/health)
    - Create deployment pipeline (build → test → staging → production)
    - Add smoke tests that run after deployment
    - Document rollback procedure (tested monthly)
  After: Automated, 15 minutes, with rollback

Database query optimization:
  Found via slow query log:
    - Invoice listing: full table scan (added composite index)
    - Monthly billing job: N+1 queries (batched to single query)
    - Reconciliation: joining 5 tables without index (added covering index)
  After: slowest query reduced from 12s to 180ms

Commit: "optimize: build time 12min → 4min, deployment pipeline, query optimization"
```

**Time: 1 day.**

### Phase 7: Ship — Deploy the Improvements

```
> /godmode:ship

Godmode: Starting shipping workflow...

SHIP SUMMARY:

Changes being shipped:
  1. Refactored InvoiceProcessor (6 focused classes)
  2. Fixed test suite (504 tests, 0 failures, 0 flaky)
  3. Performance improvements (build time, queries)
  4. Deployment pipeline (automated, with rollback)

Risk assessment:
  - All characterization tests passing (behavior unchanged)
  - Code review completed
  - Deployed to staging for 3 days with production traffic mirror
  - No differences in billing calculations detected

DEPLOY:
  ✓ Staging verification: all tests pass, no calculation differences
  ✓ Production deployment via new pipeline (15 minutes)
  ✓ Smoke tests passing
  ✓ Billing calculations verified for 100 sample customers
  ✓ Monitoring: no errors, latency improved

RESULTS:
  - InvoiceProcessor: 4,200 lines → 6 classes, avg 450 lines each
  - Test coverage on hotspots: 23% → 71%
  - Build time: 12 min → 4 min
  - Deploy time: 4 hours → 15 minutes
  - Confidence level: significantly improved
```

---

## The Legacy Refactoring Playbook

### Rule 1: Test Before You Touch

Never refactor without tests. If you cannot write unit tests (too tangled), write characterization tests (HTTP-level tests that capture current behavior).

### Rule 2: Hotspots First

Refactor the files that are both high-complexity AND frequently changed. A 5,000-line file that nobody touches is not a priority. A 2,000-line file that gets 10 PRs per month is.

### Rule 3: Small Steps, Always Green

Every commit should leave the tests passing. If a refactoring is too big for one commit, break it into smaller steps. Extract one method, commit. Extract one class, commit.

### Rule 4: Preserve Behavior

The goal of refactoring is to change the structure without changing the behavior. Characterization tests are your proof that behavior is preserved.

### Rule 5: Strangle, Do Not Rewrite

The old code works (sort of). A rewrite introduces new bugs. Use the strangler fig pattern: build the new alongside the old, migrate incrementally.

---

## Refactoring Techniques for Legacy Code

| Technique | When to Use | Risk |
|-----------|------------|------|
| Extract Method | Long methods with identifiable blocks | LOW |
| Extract Class | God classes with multiple responsibilities | LOW |
| Introduce Parameter Object | Methods with 5+ parameters | LOW |
| Replace Conditional with Polymorphism | Long switch/if-else chains | MEDIUM |
| Introduce Interface | Tight coupling between modules | MEDIUM |
| Strangler Fig | Replacing entire modules | MEDIUM |
| Branch by Abstraction | Replacing implementations gradually | MEDIUM |

---

## Measuring Progress

Track these metrics weekly to prove the refactoring is working:

| Metric | Measures | Target Direction |
|--------|---------|-----------------|
| Cyclomatic complexity (avg) | Code understandability | Down |
| Duplication percentage | Copy-paste debt | Down |
| Test coverage (hotspots) | Safety net coverage | Up |
| Failing/flaky test count | Test suite health | Down to zero |
| Build time | Developer feedback loop | Down |
| Deploy frequency | Delivery confidence | Up |
| Change failure rate | Quality of changes | Down |
| Time to fix a bug (avg) | Codebase navigability | Down |

---

## Common Pitfalls

| Pitfall | Why It Happens | Godmode Prevention |
|---------|---------------|-------------------|
| Big-bang rewrite | "Let us just rewrite it in Rust" | `/godmode:legacy` recommends incremental strategy |
| Refactoring without tests | "Tests slow us down" | `/godmode:test --strategy characterization` first |
| Boiling the ocean | Trying to fix everything at once | `/godmode:quality` identifies hotspots for focused effort |
| Gold plating | "While we are here, let us also add..." | `/godmode:refactor` scopes each refactoring precisely |
| Ignoring the test suite | Broken tests become normal | `/godmode:test` fixes flaky/failing tests as step 1 |
| No metrics | "It feels better" is not evidence | `/godmode:quality --compare-baseline` tracks progress |

---

## Custom Chain for Legacy Projects

```yaml
# .godmode/chains.yaml
chains:
  legacy-improve:
    description: "Incremental legacy improvement cycle"
    steps:
      - quality        # measure current state
      - legacy         # identify next improvement target
      - test           # add tests around target
      - refactor       # improve the code
      - test           # verify no behavior change
      - ship           # deploy safely

  legacy-assess:
    description: "Initial legacy codebase assessment"
    steps:
      - onboard        # map the codebase
      - quality        # measure complexity, duplication, coverage
      - legacy         # create modernization strategy
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [Legacy Modernization Recipe](legacy-modernization.md) — Full strangler fig migration
- [Building a SaaS](greenfield-saas.md) — If you decide to build the replacement
- [Full Observability Setup](monitoring-setup.md) — Add monitoring to understand legacy behavior
