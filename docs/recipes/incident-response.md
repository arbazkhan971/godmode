# Recipe: Handling a Production Incident

> From "things are broken" to "fixed and post-mortem written." A complete Godmode workflow for incident response.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `incident → debug → fix → verify → deploy → observe → incident --postmortem` |
| **Timeline** | Minutes to hours (depending on severity) |
| **Team size** | 1-3 engineers (incident commander + responders) |
| **Example incident** | "CheckoutService" — orders failing with 500 errors after a deployment |

---

## The Scenario

It is 2:47 PM on a Thursday. Your monitoring fires:

```
ALERT: Error rate > 5% on checkout-service for 3 minutes
ALERT: p99 latency > 10s on POST /api/orders
PagerDuty: SEV2 incident triggered
```

Customers cannot complete purchases. Revenue is being lost every minute.

---

## Phase 1: Classify and Stabilize (Minutes 0-5)

### Step 1: Incident — Classify Severity

```
> /godmode:incident --classify

Godmode: Gathering incident data...

INCIDENT CLASSIFICATION:

Signals:
  - Error rate: 12.4% (normally 0.2%)
  - POST /api/orders: 500 Internal Server Error
  - GET /api/orders: normal (reads unaffected)
  - Other endpoints: normal
  - Started: 14:44 UTC (3 minutes ago)
  - Last deploy: 14:42 UTC (checkout-service v2.8.3)

Correlation: Error spike started 2 minutes after deploy v2.8.3

CLASSIFICATION:
  Severity: SEV2 — Major feature broken, revenue impact
  Scope: Order creation only (reads, other services unaffected)
  Users affected: ~340 users attempted checkout in last 3 minutes
  Revenue impact: ~$12K/hour at current traffic

IMMEDIATE QUESTION:
The error spike correlates with deploy v2.8.3 (2 minutes before errors).
Do you want to:
  A) Rollback to v2.8.2 immediately (fastest mitigation)
  B) Investigate first (if rollback is risky or the change is critical)

> Rollback first, then investigate.

Godmode: Initiating rollback...

ROLLBACK:
  ✓ checkout-service rolled back to v2.8.2
  ✓ Health check: OK
  ✓ Error rate: 12.4% → 0.3% (recovering)
  ✓ T+2 min: Error rate 0.2% (nominal)

Incident mitigated. Users can checkout again.

Saved: docs/incidents/2026-03-19-checkout-failure.md
Timeline entry: 14:47 — Rollback to v2.8.2, service restored
```

---

## Phase 2: Investigate Root Cause (Minutes 10-30)

### Step 2: Debug — Find the Root Cause

Now that the bleeding has stopped, find out what went wrong in v2.8.3:

```
> /godmode:debug --incident

Godmode: Investigating checkout-service v2.8.3...

INVESTIGATION:

Technique 1: Diff Analysis
  git diff v2.8.2..v2.8.3

  Changes in v2.8.3:
    1. src/services/order.service.ts — refactored createOrder()
    2. src/models/order.model.ts — added new field: delivery_estimate
    3. migrations/042_add_delivery_estimate.sql — ALTER TABLE orders ADD COLUMN
    4. src/utils/pricing.ts — extracted pricing calculation

Technique 2: Error Log Analysis
  ERROR: Column 'delivery_estimate' cannot be null
  at INSERT INTO orders (customer_id, total, delivery_estimate, ...)

  The new delivery_estimate column was added as NOT NULL without a default
  value. The migration ran successfully, but the application code does not
  always populate delivery_estimate — specifically, it is only set for
  physical products, not digital products.

Technique 3: Reproduce
  curl -X POST /api/orders -d '{"items": [{"product_id": "digital-101", "qty": 1}]}'
  → 500: Column 'delivery_estimate' cannot be null

  curl -X POST /api/orders -d '{"items": [{"product_id": "physical-201", "qty": 1}]}'
  → 201: Order created successfully

  Confirmed: Digital product orders fail, physical product orders succeed.

ROOT CAUSE ANALYSIS:
  Bug: Migration 042 added delivery_estimate as NOT NULL without a default.
  Impact: Digital product orders (no delivery estimate) fail with SQL error.
  Introduced by: v2.8.3, commit a3f7c2d
  Why not caught:
    1. Test suite only tests physical product orders
    2. No test for digital product checkout flow
    3. Migration review did not flag NOT NULL without DEFAULT
  Contributing factor: No database migration linting in CI pipeline

Saved: docs/incidents/2026-03-19-checkout-failure.md (updated with RCA)
Timeline entry: 14:58 — Root cause identified: NOT NULL migration on delivery_estimate
```

---

## Phase 3: Fix the Issue (Minutes 30-60)

### Step 3: Fix — Apply the Correction

```
> /godmode:fix --from-debug

Godmode: Applying fix based on root cause analysis...

FIX STRATEGY:
  Option A: Make delivery_estimate nullable (ALTER TABLE ... ALTER COLUMN)
  Option B: Add a default value ('N/A' for digital products)
  Option C: Set delivery_estimate in application code for all product types

Recommendation: Option A + C
  - Make the column nullable (safe migration, backward compatible)
  - Update application to set delivery_estimate = null for digital products
  - This matches the business reality: digital products have no delivery date

FIX ITERATION 1:
  File: migrations/043_fix_delivery_estimate_nullable.sql
  Change: ALTER TABLE orders ALTER COLUMN delivery_estimate DROP NOT NULL

  File: src/services/order.service.ts
  Change: Set delivery_estimate = null for digital products explicitly

  Regression tests added:
    "digital product order creates successfully" — PASSES ✓
    "physical product order includes delivery estimate" — PASSES ✓
    "mixed cart order handles both product types" — PASSES ✓

Verification:
  ✓ All 247 existing tests pass
  ✓ 3 new regression tests pass
  ✓ Manual test: digital product checkout succeeds
  ✓ Manual test: physical product checkout succeeds

Commit: "fix: make delivery_estimate nullable for digital products"
Commit: "test: regression tests for digital product checkout"
```

### Step 4: Prevent Future Occurrence

```
> /godmode:fix --preventive

Godmode: Adding preventive measures...

PREVENTIVE FIXES:

1. Database migration linting (CI check):
   File: .github/workflows/ci.yml
   Added: squawk (PostgreSQL migration linter) step
   Rule: NOT NULL columns MUST have a DEFAULT value or be explicitly reviewed

2. Checkout test coverage:
   File: tests/integration/checkout.test.ts
   Added: 8 tests covering all product type combinations
   - Digital only, physical only, mixed cart
   - Free product, discounted product
   - Guest checkout, logged-in checkout

3. Pre-deploy smoke test:
   File: scripts/smoke-test.sh
   Added: Tests both digital and physical product checkout on staging
   Runs automatically before production deploy promotion

Commit: "ci: add migration linting with squawk"
Commit: "test: comprehensive checkout flow coverage — 8 new tests"
Commit: "ci: add pre-deploy smoke test for checkout flows"
```

---

## Phase 4: Validate and Deploy (Minutes 60-90)

### Step 5: Verify — Confirm the Fix

```
> /godmode:verify

Godmode: Running full verification suite...

VERIFICATION:

Code verification:
  ✓ All 258 tests pass (247 existing + 11 new)
  ✓ Lint: clean
  ✓ Type check: clean
  ✓ Migration lint: clean (squawk passes)

Staging verification:
  ✓ Migration 043 applied to staging
  ✓ Digital product checkout: 201 Created
  ✓ Physical product checkout: 201 Created
  ✓ Mixed cart checkout: 201 Created
  ✓ Error rate on staging: 0%
  ✓ Smoke tests: 12/12 passing

Shadow replay:
  ✓ Replayed 340 failed requests from incident window
  ✓ All 340 would now succeed with the fix

VERDICT: Fix verified. Safe to deploy.
```

### Step 6: Deploy — Ship the Fix

```
> /godmode:deploy --strategy canary --percentage 10

Godmode: Deploying checkout-service v2.8.4...

DEPLOYMENT:
  Strategy: Canary (10% → 25% → 50% → 100%)

  T+0:  ✓ 10% traffic to v2.8.4
  T+5:  ✓ Error rate 0%, latency normal — promoting to 25%
  T+10: ✓ Error rate 0%, latency normal — promoting to 50%
  T+15: ✓ Error rate 0%, latency normal — promoting to 100%

  v2.8.4 fully deployed. Canary successful.

Timeline entry: 15:52 — v2.8.4 deployed to production (fix + preventive measures)
```

### Step 7: Observe — Monitor Recovery

```
> /godmode:observe --incident-watch 60

Godmode: Monitoring post-deploy metrics for 60 minutes...

POST-DEPLOY MONITORING:

T+0:   Error rate: 0.18% | p99: 245ms | Orders/min: 47
T+15:  Error rate: 0.15% | p99: 232ms | Orders/min: 52
T+30:  Error rate: 0.20% | p99: 241ms | Orders/min: 49
T+45:  Error rate: 0.17% | p99: 228ms | Orders/min: 51
T+60:  Error rate: 0.19% | p99: 235ms | Orders/min: 48

All metrics within normal bounds. No anomalies detected.

INCIDENT STATUS: RESOLVED
Duration: 14:44 — 15:52 (68 minutes total)
Mitigation time: 3 minutes (rollback)
Full resolution: 68 minutes (fix deployed)
```

---

## Phase 5: Post-Mortem (Within 24 Hours)

### Step 8: Incident Post-Mortem

```
> /godmode:incident --postmortem

Godmode: Generating post-mortem from incident timeline...

POST-MORTEM: Checkout Failure — 2026-03-19

SUMMARY:
  Incident: Digital product orders returning 500 errors
  Duration: 68 minutes (3-minute mitigation via rollback)
  Severity: SEV2
  Revenue impact: ~$620 (estimated 52 failed orders in 3-minute window)
  Customers affected: ~340 attempted, ~52 failed to complete checkout

TIMELINE:
  14:42  Deploy v2.8.3 to production
  14:44  First 500 errors appear on POST /api/orders
  14:45  Monitoring alert fires (error rate > 5%)
  14:47  Incident classified as SEV2, rollback initiated
  14:49  Rollback complete, error rate returning to normal
  14:58  Root cause identified (NOT NULL column without default)
  15:35  Fix implemented, tested, verified
  15:52  v2.8.4 deployed with fix + preventive measures
  15:52  Incident resolved

ROOT CAUSE:
  Migration 042 added delivery_estimate as NOT NULL without a default value.
  Digital products do not have a delivery estimate, causing INSERT to fail.

CONTRIBUTING FACTORS:
  1. No database migration linting in CI
  2. Test suite lacked digital product checkout coverage
  3. No pre-deploy smoke test for critical checkout paths
  4. Code review did not catch the NOT NULL constraint issue

WHAT WENT WELL:
  1. Monitoring detected the issue within 1 minute
  2. Rollback was fast (2 minutes to full recovery)
  3. Root cause was identified quickly via deploy correlation
  4. Fix included preventive measures, not just the immediate fix

WHAT WENT POORLY:
  1. The bug reached production — should have been caught in CI
  2. 52 customers had a failed checkout experience
  3. No automated canary analysis would have caught this
     (canary only checked health, not business transactions)

ACTION ITEMS:
  ✓ DONE — Add migration linting to CI (squawk)
  ✓ DONE — Add digital product checkout tests
  ✓ DONE — Add pre-deploy smoke test
  TODO — Add canary analysis for business metrics (orders/min)
  TODO — Customer communication: apologize to 52 affected customers
  TODO — Add checkout failure rate to SLO dashboard
  TODO — Review all NOT NULL columns added in last 6 months

Saved: docs/incidents/2026-03-19-checkout-failure.md (final)
Saved: docs/postmortems/2026-03-19-checkout-failure-postmortem.md
```

---

## Incident Response Cheat Sheet

### Severity Classification

| SEV | Criteria | Response Time | Example |
|-----|----------|---------------|---------|
| SEV1 | Complete outage, all users affected | Immediate (< 5 min) | Database down, all APIs 500 |
| SEV2 | Major feature broken, revenue impact | < 15 min | Checkout failing, auth broken |
| SEV3 | Minor feature degraded, workaround exists | < 1 hour | Search slow, export failing |
| SEV4 | Cosmetic issue, no functional impact | Next business day | Wrong icon, typo in email |

### Decision Tree: Rollback vs. Investigate

```
Is the system losing money/data RIGHT NOW?
├── YES → Rollback immediately, then investigate
  /godmode:incident --rollback
  /godmode:debug --incident
└── NO  → Investigate first
          ├── Can you reproduce it?
  ├── YES → /godmode:debug
  └── NO  → /godmode:observe --trace <request-id>
          └── /godmode:fix --from-debug
```

### Godmode Commands for Each Phase

```
# Phase 1: Classify and stabilize
/godmode:incident --classify          # severity, scope, impact
/godmode:incident --rollback          # if needed

# Phase 2: Investigate
/godmode:debug --incident             # root cause analysis
/godmode:debug --error "exact error"  # if you have the error message

# Phase 3: Fix
/godmode:fix --from-debug             # apply fix from RCA
/godmode:fix --preventive             # prevent recurrence

# Phase 4: Validate and deploy
/godmode:verify                       # confirm fix works
/godmode:deploy --strategy canary     # safe deployment

# Phase 5: Monitor and document
/godmode:observe --incident-watch 60  # post-deploy monitoring
/godmode:incident --postmortem        # generate post-mortem
```

---

## Custom Chain for Incident Response

```yaml
# .godmode/chains.yaml
chains:
  incident-response:
    description: "Full incident lifecycle"
    steps:
      - incident   # classify
      - debug      # investigate
      - fix        # remediate
      - verify     # confirm
      - deploy:
          strategy: canary
      - observe    # monitor
      - incident:
          args: "--postmortem"

  hotfix:
    description: "Fast path when root cause is obvious"
    steps:
      - fix
      - verify
      - deploy:
          strategy: canary
      - observe
```

---

## Key Principles

1. **Mitigate first, investigate second.** A rolled-back system serving customers is better than a broken system while you read logs.

2. **Every incident gets a post-mortem.** Not to assign blame, but to improve the system. If the same incident can happen twice, the post-mortem failed.

3. **Preventive fixes are non-negotiable.** The immediate fix stops the bleeding. The preventive fixes (CI checks, tests, monitoring) stop it from happening again.

4. **Measure the impact.** "Some users were affected" is not good enough. "52 customers failed to complete checkout, estimated $620 revenue impact" drives the right level of urgency.

5. **Action items have owners and deadlines.** "TODO: improve monitoring" will never happen. "TODO: Add checkout failure rate to SLO dashboard — @alice — by Friday" will.

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Bug Fix Example](../examples/bug-fix.md) — Simpler debug-fix-ship flow
- [Performance Optimization Recipe](performance-optimization.md) — When the incident is about performance
- [Security Hardening Recipe](security-hardening.md) — When the incident is a security breach
