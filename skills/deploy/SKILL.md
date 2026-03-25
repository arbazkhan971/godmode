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
Characterize the change and determine the correct deployment strategy:

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
  LOAD BALANCER → routes 100% to active environment
    [BLUE env: v1.0 (live)] ←── current traffic
    [GREEN env: v1.1 (idle)] ←── deploy here, then switch
```

### Step 3: Canary Release
Route a small percentage of traffic to the new version:

```
CANARY RELEASE PLAN:
  LOAD BALANCER (traffic splitting)
    95% → [STABLE: v1.0, N instances]
     5% → [CANARY: v1.1, 1 instance]
  Gradually shift: 5% → 25% → 50% → 100% based on metrics

```

### Step 4: Progressive Rollout
Percentage-based traffic shifting with automated gates:

```
PROGRESSIVE ROLLOUT PLAN:
| Stage | Traffic | Duration | Gate | Rollback |
|--|--|--|--|--|
| 1. Smoke | 0% (int) | 5 min | Auto | Auto |
| 2. Seed | 1% | 10 min | Auto | Auto |
| 3. Low | 5% | 15 min | Auto | Auto |
| 4. Med | 25% | 30 min | Manual | Auto |
| 5. High | 50% | 30 min | Manual | Auto |
| 6. Full | 100% | Monitor | Manual | Manual |

Gate criteria:
  Auto gate: pass if all success metrics within threshold for full duration
  Manual gate: auto gate + human approval required to proceed
```

### Step 5: Automated Rollback
Define rollback criteria and execution plan:

```
ROLLBACK PLAN:
  AUTOMATIC ROLLBACK TRIGGERS
| Trigger | Threshold | Window |
|--|--|--|
| HTTP 5xx rate | > 1% | 2 min |
| P99 latency | > 2x baseline | 5 min |
| Error log rate | > 3x baseline | 5 min |
| Health check failures | > 2 consec. | immediate |
| Business metric drop | > 10% | 15 min |
| Memory usage | > 90% | 5 min |
| CPU usage | > 95% | 5 min |

```

### Step 6: Feature Flag Orchestration
Coordinate feature flags with deployment stages:

```
FEATURE FLAG ROLLOUT PLAN:
| Flag | Stage 1 | Stage 2 | Stage 3 | Full |
|--|--|--|--|--|
| new-checkout-ui | internal | 5% users | 50% | 100% |
| payment-v2-api | internal | internal | 5% | 100% |
| new-recommendation | OFF | OFF | 25% | 100% |

Flag dependencies:
  payment-v2-api REQUIRES new-checkout-ui (cannot enable v2 without new UI)
  new-recommendation INDEPENDENT (toggle separately)

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
  DEPLOYMENT PLAN
  Strategy: <Blue-Green | Canary | Progressive | Rolling>
  Risk level: <LOW | MEDIUM | HIGH | CRITICAL>
  Estimated duration: <time>
  Rollback time: <time>
  Pre-deployment checklist:
  [x] All tests passing
  [x] Security audit passed
  [x] Database migration tested in staging
  [x] Rollback procedure tested
  [x] Monitoring dashboards ready
  [x] On-call engineer confirmed
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
|--|--|
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

## Keep/Discard Discipline
```
KEEP (promote) if: ALL metrics within threshold for full observation
DISCARD (rollback) if: ANY trigger fires OR approval denied
```

## Stop Conditions
```
ROLLBACK when: error rate > baseline+1% for 2+min OR P99 > 2x baseline
  OR health check fails OR business metric drops > 10%
COMPLETE when: 100% traffic, metrics stable 15+ min
```

```bash
# Deploy and monitor
kubectl rollout status deployment/app --timeout=300s
kubectl get pods -l app=myapp --field-selector=status.phase!=Running
curl -s http://localhost/healthz | jq .status
```

## Auto-Detection
```
kubectl cluster-info 2>/dev/null && echo "kubernetes"
aws ecs list-clusters 2>/dev/null && echo "ecs"
grep -ri "canary\|blue.green\|rolling" k8s/ helm/ 2>/dev/null
```

## TSV Logging
Log to `.godmode/deploy-results.tsv`:
`step\tenvironment\tstrategy\tcanary_pct\terror_rate\tlatency_p99\tstatus`

## Success Criteria
- Error rate < 1% at each stage. P99 within baseline + 10%.
- Rollback tested. Health checks pass. Migrations backward-compatible.

## Error Recovery
| Failure | Action |
|--|--|
| Canary health fails | Rollback to 0%. Check config drift. |
| Migration fails | Don't retry blindly. Check partial changes. Restore backup. |
| Rollback fails | Manually set previous image. Verify registry + DB compat. |
| Traffic spike | Pause canary. Resume when baseline restored. |

