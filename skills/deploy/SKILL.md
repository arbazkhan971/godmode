---
name: deploy
description: |
  Advanced deployment strategies skill. Activates when user needs sophisticated deployment orchestration including blue-green deployments, canary releases, progressive rollouts, automated rollback, feature flag coordination, and zero-downtime migrations. Designs and validates deployment plans with risk mitigation at every stage. Triggers on: /godmode:deploy, "deploy with zero downtime", "canary release", "blue-green deployment", "rollback strategy", or when shipping critical changes that require controlled rollout.
---

# Deploy — Advanced Deployment Strategies

## When to Activate
- User invokes `/godmode:deploy`
- User says "deploy with zero downtime," "canary release," "blue-green deployment"
- User needs rollback strategy for a risky change
- Feature flags need orchestration for a complex rollout
- Database migrations or infrastructure changes require zero-downtime approach
- Godmode orchestrator detects high-risk changes during `/godmode:ship`

## Workflow

### Step 1: Assess Deployment Context
Characterize the change and determine the appropriate deployment strategy:

```
DEPLOYMENT ASSESSMENT:
Change type: <application code | database migration | infrastructure | config | all>
Risk level: <LOW | MEDIUM | HIGH | CRITICAL>
Rollback complexity: <INSTANT | MINUTES | HOURS | DIFFICULT>

Change characteristics:
  - [ ] Backward compatible (old code works with new data)
  - [ ] Forward compatible (new code works with old data)
  - [ ] Database schema changes involved
  - [ ] API contract changes (breaking/non-breaking)
  - [ ] Infrastructure changes (new services, topology)
  - [ ] Feature flags available
  - [ ] Stateful components affected (sessions, caches)

Current environment:
  Production instances: <N>
  Load balancer: <type>
  Database: <type, replication setup>
  Traffic: <requests/sec, peak hours>
  SLA: <uptime requirement>

Recommended strategy: <Blue-Green | Canary | Progressive | Rolling | Recreate>
Justification: <why this strategy fits>
```

### Step 2: Blue-Green Deployment
Two identical environments, instant switchover:

```
BLUE-GREEN DEPLOYMENT PLAN:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   LOAD BALANCER                                             │
│        │                                                    │
│   ┌────┴────┐                                               │
│   │         │                                               │
│   ▼         ▼                                               │
│ ┌──────┐  ┌──────┐                                          │
│ │ BLUE │  │GREEN │                                          │
│ │(live)│  │(idle)│                                          │
│ │ v1.0 │  │ v1.1 │                                          │
│ └──┬───┘  └──┬───┘                                          │
│    │         │                                               │
│    └────┬────┘                                               │
│         ▼                                                    │
│    ┌─────────┐                                               │
│    │   DB    │  (shared, migrations must be compatible)      │
│    └─────────┘                                               │
└─────────────────────────────────────────────────────────────┘

Phase 1: PREPARE GREEN
  1. Deploy new version to GREEN environment
  2. Run smoke tests against GREEN (not receiving live traffic)
  3. Verify health checks pass on all GREEN instances
  4. Warm up caches and connection pools on GREEN

Phase 2: SWITCH TRAFFIC
  5. Update load balancer to route 100% traffic to GREEN
  6. Monitor error rates, latency, and business metrics for 5 minutes
  7. Verify no 5xx errors above baseline

Phase 3: VALIDATE
  8. Run integration tests against production (via GREEN)
  9. Monitor for 15 minutes
  10. If stable: GREEN becomes the new BLUE (live)
  11. Keep old BLUE running for 1 hour as rollback target

ROLLBACK: Switch load balancer back to BLUE (< 30 seconds)
```

### Step 3: Canary Release
Route a small percentage of traffic to the new version:

```
CANARY RELEASE PLAN:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   LOAD BALANCER (traffic splitting)                         │
│        │                                                    │
│   ┌────┴──────────────┐                                     │
│   │ 95%               │ 5%                                  │
│   ▼                   ▼                                     │
│ ┌──────────┐  ┌──────────┐                                  │
│ │ STABLE   │  │ CANARY   │                                  │
│ │ (N inst) │  │ (1 inst) │                                  │
│ │  v1.0    │  │  v1.1    │                                  │
│ └──────────┘  └──────────┘                                  │
└─────────────────────────────────────────────────────────────┘

Canary stages:
  Stage 1: 1% traffic → canary (10 min observation)
  Stage 2: 5% traffic → canary (15 min observation)
  Stage 3: 25% traffic → canary (30 min observation)
  Stage 4: 50% traffic → canary (30 min observation)
  Stage 5: 100% traffic → full rollout

Success criteria (must ALL pass at each stage):
  - Error rate: <= baseline + 0.1%
  - P99 latency: <= baseline + 10%
  - Business metrics: no regression (conversion, revenue, etc.)
  - No new error signatures in logs
  - CPU/memory within normal bounds

Automatic rollback triggers:
  - Error rate exceeds baseline + 1%
  - P99 latency exceeds baseline + 50%
  - Any 5xx error rate > 0.5%
  - Health check failures on canary instances
  - Manual trigger by on-call engineer
```

### Step 4: Progressive Rollout
Percentage-based traffic shifting with automated gates:

```
PROGRESSIVE ROLLOUT PLAN:
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│ Stage    │ Traffic  │ Duration │ Gate     │ Rollback │
├──────────┼──────────┼──────────┼──────────┼──────────┤
│ 1. Smoke │ 0% (int) │ 5 min    │ Auto     │ Auto     │
│ 2. Seed  │ 1%       │ 10 min   │ Auto     │ Auto     │
│ 3. Low   │ 5%       │ 15 min   │ Auto     │ Auto     │
│ 4. Med   │ 25%      │ 30 min   │ Manual   │ Auto     │
│ 5. High  │ 50%      │ 30 min   │ Manual   │ Auto     │
│ 6. Full  │ 100%     │ Monitor  │ Manual   │ Manual   │
└──────────┴──────────┴──────────┴──────────┴──────────┘

Gate criteria:
  Auto gate: pass if all success metrics within threshold for full duration
  Manual gate: auto gate + human approval required to proceed

Traffic routing method:
  - [ ] Load balancer weighted routing
  - [ ] Service mesh (Istio/Linkerd) traffic splitting
  - [ ] Feature flag percentage rollout
  - [ ] DNS-based routing
  - [ ] Header-based routing (internal testing)
```

### Step 5: Automated Rollback
Define rollback criteria and execution plan:

```
ROLLBACK PLAN:
┌─────────────────────────────────────────────────────────────┐
│ AUTOMATIC ROLLBACK TRIGGERS                                 │
├─────────────────────────────────────────────────────────────┤
│ Trigger                        │ Threshold    │ Window     │
├────────────────────────────────┼──────────────┼────────────┤
│ HTTP 5xx rate                  │ > 1%         │ 2 min      │
│ P99 latency                   │ > 2x baseline│ 5 min      │
│ Error log rate                 │ > 3x baseline│ 5 min      │
│ Health check failures          │ > 2 consec.  │ immediate  │
│ Business metric drop           │ > 10%        │ 15 min     │
│ Memory usage                   │ > 90%        │ 5 min      │
│ CPU usage                      │ > 95%        │ 5 min      │
└────────────────────────────────┴──────────────┴────────────┘

ROLLBACK EXECUTION:
  1. DETECT: Monitoring triggers rollback alert
  2. DECIDE: Auto-rollback if within auto-rollback stages, page on-call otherwise
  3. EXECUTE:
     a. Shift 100% traffic to stable version (< 30 seconds)
     b. Scale down new version instances
     c. Verify stable version is healthy
     d. Send rollback notification to team
  4. INVESTIGATE:
     a. Preserve logs and metrics from failed deployment
     b. Capture state for post-mortem
     c. Create incident ticket
  5. COMMUNICATE:
     a. Notify stakeholders of rollback
     b. Provide estimated timeline for fix and re-deploy

DATABASE ROLLBACK:
  Forward-only migrations: No rollback needed (additive changes)
  Breaking migrations: Requires reverse migration script
  Data migrations: Point-in-time recovery (RPO defined)
```

### Step 6: Feature Flag Orchestration
Coordinate feature flags with deployment stages:

```
FEATURE FLAG ROLLOUT PLAN:
┌──────────────────────────────────────────────────────────────┐
│ Flag               │ Stage 1   │ Stage 2  │ Stage 3 │ Full  │
├──────────────────────────────────────────────────────────────┤
│ new-checkout-ui    │ internal  │ 5% users │ 50%     │ 100%  │
│ payment-v2-api     │ internal  │ internal │ 5%      │ 100%  │
│ new-recommendation │ OFF       │ OFF      │ 25%     │ 100%  │
└──────────────────────────────────────────────────────────────┘

Flag dependencies:
  payment-v2-api REQUIRES new-checkout-ui (cannot enable v2 without new UI)
  new-recommendation INDEPENDENT (can be toggled separately)

Kill switches:
  Each flag has a kill switch that disables it within 30 seconds
  Kill switch does NOT require a new deployment
  Kill switch reverts to previous behavior, not an error state

Flag lifecycle:
  1. Create flag (default: OFF)
  2. Enable for internal users / staging
  3. Progressive rollout to production users
  4. Monitor and validate at each stage
  5. When 100%: remove flag from code (cleanup PR)
  6. Delete flag from flag service

Stale flag detection:
  - Alert if flag has been at 100% for > 30 days without cleanup
  - Alert if flag has been at 0% for > 14 days (abandoned experiment)
```

### Step 7: Zero-Downtime Migration Strategies
For database and infrastructure changes that cannot tolerate downtime:

#### Database Schema Migration (Expand-Contract Pattern)
```
ZERO-DOWNTIME SCHEMA MIGRATION:

Phase 1: EXPAND (deploy with old + new schema)
  Migration: Add new column/table (nullable, with defaults)
  Code: Write to BOTH old and new locations
  Duration: Deploy and verify writes are dual-writing

Phase 2: MIGRATE (backfill existing data)
  Script: Batch-copy data from old to new location
  Verification: Row counts match, data integrity checks pass
  Duration: Depends on data volume (estimate: <time>)

Phase 3: CONTRACT (switch reads to new, stop writing old)
  Code: Read from new location, write only to new location
  Verification: Old location receives no new writes
  Duration: Deploy and verify

Phase 4: CLEANUP (remove old schema)
  Migration: Drop old column/table
  Code: Remove dual-write logic
  Duration: Deploy cleanup code

Total migration timeline: <estimate>
Rollback at each phase: YES (revert code, schema remains compatible)
```

#### Service Migration
```
ZERO-DOWNTIME SERVICE MIGRATION:

Phase 1: STRANGLER FIG
  1. Deploy new service alongside old service
  2. Route specific endpoints to new service (start with low-traffic)
  3. Monitor error rates and latency for new service
  4. Gradually migrate more endpoints

Phase 2: DATA SYNC
  1. Set up bidirectional sync between old and new data stores
  2. Verify data consistency with checksums
  3. Run shadow traffic (duplicate requests to new service, compare responses)

Phase 3: CUTOVER
  1. Route 100% traffic to new service
  2. Keep old service running (read-only) for rollback
  3. Monitor for 24-48 hours
  4. Decommission old service
```

### Step 8: Deployment Report

```
┌────────────────────────────────────────────────────────────┐
│  DEPLOYMENT PLAN                                           │
├────────────────────────────────────────────────────────────┤
│  Strategy: <Blue-Green | Canary | Progressive | Rolling>   │
│  Risk level: <LOW | MEDIUM | HIGH | CRITICAL>              │
│  Estimated duration: <time>                                │
│  Rollback time: <time>                                     │
│                                                            │
│  Pre-deployment checklist:                                 │
│  [x] All tests passing                                     │
│  [x] Security audit passed                                 │
│  [x] Database migration tested in staging                  │
│  [x] Rollback procedure tested                             │
│  [x] Monitoring dashboards ready                           │
│  [x] On-call engineer confirmed                            │
│  [x] Communication plan sent                               │
│                                                            │
│  Deployment stages: <N>                                    │
│  Feature flags: <N>                                        │
│  Automatic rollback: <ENABLED | DISABLED>                  │
│                                                            │
│  Go/No-Go: <GO | NO-GO>                                   │
│  Reason: <justification>                                   │
└────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Save deployment plan as `docs/deploy/<date>-<feature>-deployment.md`
2. Commit: `"deploy: <feature> — <strategy> with <N> stages"`
3. After successful deployment: "Deployment complete. Monitor for 24 hours, then clean up feature flags."
4. After rollback: "Rolled back to stable version. See incident report for root cause."

## Key Behaviors

1. **Strategy matches risk.** Low-risk changes can use rolling deploys. High-risk changes need canary with automated rollback. Never under-engineer deployment for risky changes.
2. **Rollback is always planned.** Every deployment plan includes a rollback procedure. If you cannot define rollback, the deployment is not ready.
3. **Database migrations are special.** Schema changes require the expand-contract pattern for zero downtime. Never run a breaking migration during deployment.
4. **Feature flags decouple deploy from release.** Deploy code anytime. Release features when ready. These are separate concerns.
5. **Monitoring is prerequisite.** Do not deploy without monitoring in place. You cannot canary without metrics to compare.
6. **Automation over heroics.** Automated rollback at 2 AM is better than paging an engineer. Define thresholds and let the system react.
7. **Communication is part of deployment.** Stakeholders, on-call, and dependent teams must know about high-risk deployments before they happen.

## Example Usage

### Deploying a payment system update
```
User: /godmode:deploy We need to deploy the new payment processor integration
       with zero downtime. It includes database changes.

Deploy: Assessing deployment context...

DEPLOYMENT ASSESSMENT:
Change type: Application code + database migration
Risk level: HIGH (payment system, database changes)
Rollback complexity: MINUTES (with expand-contract migration)

Recommended strategy: Canary Release with Expand-Contract Migration

Phase 1: Database EXPAND
  - Add new columns: payments.processor_v2, payments.processor_response_v2
  - Both nullable with defaults — no breaking change
  - Deploy migration to production (< 1 minute, online DDL)

Phase 2: Dual-Write Code Deploy (Canary)
  - Deploy code that writes to BOTH old and new columns
  - Canary at 1% → 5% → 25% → 50% → 100%
  - Monitor: payment success rate, latency, error rate
  - Auto-rollback if payment success rate drops > 0.5%

Phase 3: Backfill Historical Data
  - Batch script to populate new columns for existing records
  - Run during low-traffic window, throttled to avoid DB load

Phase 4: Switch Reads (Canary)
  - Deploy code that reads from new columns
  - Canary at 5% → 25% → 100%
  - Monitor: response accuracy, latency

Phase 5: Cleanup
  - Remove dual-write code
  - Drop old columns (after 7-day bake period)
  - Remove feature flags

Rollback at any phase: revert code, schema remains compatible.
Total timeline: 3-5 days (conservative, for payment system).
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full deployment planning and strategy recommendation |
| `--strategy <type>` | Use specific strategy: blue-green, canary, progressive, rolling |
| `--canary` | Canary release with automated gates |
| `--blue-green` | Blue-green deployment plan |
| `--progressive` | Progressive rollout with percentage stages |
| `--rollback` | Design rollback plan only |
| `--flags` | Feature flag orchestration plan only |
| `--migration` | Zero-downtime database migration plan only |
| `--dry-run` | Generate plan without executing |
| `--quick` | Simplified plan for low-risk changes |
| `--checklist` | Pre-deployment checklist only |

## Anti-Patterns

- **Do NOT deploy without a rollback plan.** "We'll fix forward" is not a rollback strategy. Have a tested rollback procedure for every deployment.
- **Do NOT skip canary stages.** Going from 1% to 100% without intermediate stages defeats the purpose of canary releases. Be patient.
- **Do NOT run breaking database migrations during deploy.** Use expand-contract pattern. Breaking migrations cause downtime.
- **Do NOT leave feature flags forever.** Flags that stay at 100% for months become technical debt. Clean them up within 30 days of full rollout.
- **Do NOT deploy during peak traffic.** Unless the deployment is urgently needed, deploy during low-traffic windows to minimize blast radius.
- **Do NOT deploy without monitoring.** Deploying blind means you cannot detect problems until users report them. Set up dashboards before deploying.
- **Do NOT couple multiple risky changes.** Deploy one risky change at a time. If two things break simultaneously, you cannot isolate the cause.
