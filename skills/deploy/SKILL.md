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

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full deployment planning and strategy recommendation |
| `--strategy <type>` | Use specific strategy: blue-green, canary, progressive, rolling |
| `--canary` | Canary release with automated gates |

## HARD RULES

1. **NEVER deploy without a tested rollback plan.** "Fix forward" is not a rollback strategy.
2. **NEVER skip canary stages** — going from 1% to 100% without intermediate stages defeats canary.
3. **NEVER run breaking database migrations during deploy** — use expand-contract pattern.
4. **NEVER deploy during peak traffic** unless urgently needed.
5. **NEVER deploy without monitoring dashboards open and ready.**
6. **NEVER couple multiple risky changes** — deploy one risky change at a time.
7. **ALWAYS clean up feature flags within 30 days** of full rollout.
8. **git commit BEFORE verify** — commit deployment plan, then execute.
9. **Automatic revert on regression** — if any rollback trigger fires, revert immediately.
10. **TSV logging** — log every deployment:
    ```
    timestamp	feature	strategy	stages	duration	rollback_triggered	status
    ```

## Explicit Loop Protocol

When executing a progressive rollout:

```
current_iteration = 0
stages = [
    {pct: 0, type: "smoke", duration: "5m", gate: "auto"},
    {pct: 1, type: "seed",  duration: "10m", gate: "auto"},
    {pct: 5, type: "low",   duration: "15m", gate: "auto"},
    {pct: 25, type: "med",  duration: "30m", gate: "manual"},
    {pct: 50, type: "high", duration: "30m", gate: "manual"},
    {pct: 100, type: "full", duration: "monitor", gate: "manual"},
]

WHILE stages is not empty:
    current_iteration += 1
    stage = stages.pop(0)

    # Deploy to percentage
```

## Keep/Discard Discipline
```
After EACH canary/progressive stage:
  1. MEASURE: Collect error rate, P99 latency, and business metrics for the observation window.
  2. COMPARE: Are all metrics within threshold compared to baseline?
  3. DECIDE:
     - KEEP (promote to next stage) if: ALL success criteria pass for the full observation duration
     - DISCARD (rollback) if: ANY rollback trigger fires OR manual approval denied
  4. Log the stage result with metrics in .godmode/deploy-results.tsv.

Never promote a canary stage if metrics are "probably fine" — require them to be clearly within threshold for the full duration.
```

## Stuck Recovery
```
IF deployment is stuck (canary metrics are ambiguous — neither clearly healthy nor clearly failing):
  1. EXTEND the observation window — ambiguous metrics often need more data points.
  2. CHECK for confounding variables: is there a traffic pattern change, another deployment in progress, or a dependency issue?
  3. HOLD at current percentage — do not promote or rollback while uncertain.
  4. If metrics remain ambiguous after 2x the normal observation window → ROLLBACK to be safe, investigate offline.
  5. Log stop_reason=ambiguous_metrics for post-deployment review.
```

## Stop Conditions
```
STOP the deployment (rollback) when ANY of these are true:
  - Error rate exceeds baseline + 1% for 2+ minutes
  - P99 latency exceeds 2x baseline for 5+ minutes
  - Health check failures on canary instances
  - Business metric drops >10% for 15+ minutes
  - Manual rollback triggered by on-call engineer

COMPLETE the deployment when:
  - 100% traffic on new version AND metrics stable for 15+ minutes
  - Feature flags configured for any gated functionality
  - Old version kept available for 1-hour rollback window
```

## Simplicity Criterion
```
PREFER the simpler deployment approach:
  - Rolling update before canary (for low-risk changes)
  - Canary before blue-green (canary uses fewer resources)
  - Feature flags before deployment-level traffic splitting (decouples deploy from release)
  - Expand-contract migrations before offline schema migrations (zero downtime)
  - Fewer deployment stages with longer observation over many rapid micro-stages
  - Automated rollback triggers over manual monitoring (humans are slow at 3 AM)
```

## Auto-Detection

On activation, automatically detect deployment context:

```
AUTO-DETECT:
1. Infrastructure:
   kubectl cluster-info 2>/dev/null && echo "kubernetes"
   aws ecs list-clusters 2>/dev/null && echo "ecs"
   ls vercel.json netlify.toml 2>/dev/null && echo "jamstack"

2. Load balancer:
   kubectl get ingress -A 2>/dev/null
   aws elbv2 describe-load-balancers 2>/dev/null

3. Existing deployment strategy:
   grep -ri "strategy\|canary\|blue.green\|rolling" k8s/ helm/ .github/workflows/ 2>/dev/null

4. Feature flag provider:
   grep -ri "launchdarkly\|unleash\|flagsmith" src/ package.json 2>/dev/null
```

## Output Format
Print on completion: `Deploy: {strategy} to {environment}. Canary: {canary_pct}% → {final_pct}%. Health: {health_status}. Rollback: {rollback_status}. Duration: {duration}. Verdict: {verdict}.`

## TSV Logging
Log every deployment step to `.godmode/deploy-results.tsv`:
```
step	environment	strategy	canary_pct	error_rate	latency_p99	rollback_triggered	status
1	staging	canary	5	0.1	120ms	no	healthy
2	production	canary	5	0.1	125ms	no	healthy
3	production	canary	25	0.3	130ms	no	healthy
4	production	canary	100	0.2	128ms	no	complete
```
Columns: step, environment, strategy, canary_pct, error_rate, latency_p99, rollback_triggered, status(healthy/degraded/rolled_back/complete).

## Success Criteria
- Deployment strategy selected based on risk assessment (canary for high-risk, rolling for low-risk).
- Rollback plan documented and tested before deploying.
- Health checks pass at every canary stage before promotion.
- Error rate stays below threshold at each stage (typically < 1%).
- Latency P99 stays within baseline + 10% at each stage.
- Database migrations are backward-compatible (expand-contract pattern).
- Feature flags configured for risky changes.
- Monitoring dashboard active during deployment with alerting.

## Error Recovery
- **Canary health check fails**: Automatically rollback canary traffic to zero. Investigate logs for the canary pods/instances. Check for configuration drift between canary and stable versions.
- **Database migration fails mid-deploy**: Do not retry the migration blindly. Check for partial schema changes. Use idempotent migrations that can be re-run safely. If the migration is not reversible, restore from the pre-deploy backup.
- **Rollback fails**: If automated rollback fails, manually set the deployment to the previous known-good image/version. Check that the rollback target is still available in the container registry. Verify database compatibility with the older version.
- **Traffic spike during deployment**: Pause the canary promotion. Wait for traffic to stabilize. Resume only when error rate and latency return to baseline.
- **Feature flag service is down**: Deploy without feature flags by keeping new code paths disabled by default. Never deploy with flags enabled if the flag service is unreachable.
- **Monitoring shows anomalies but no clear failure**: Hold at current canary percentage. Extend the observation window. Only promote when metrics are clearly within threshold for the full observation period.

