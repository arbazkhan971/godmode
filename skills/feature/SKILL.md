---
name: feature
description: Feature flag design, gradual rollouts, A/B testing integration, kill switches. Use when user mentions feature flags, toggles, gradual rollout, canary release, LaunchDarkly, Unleash, Flagsmith, or progressive delivery.
---

# Feature -- Feature Flags & Progressive Delivery

## When to Activate
- User invokes `/godmode:feature`
- User says "feature flag", "gradual rollout", "kill switch", "A/B test"
- User says "LaunchDarkly", "Unleash", "Flagsmith", "flag cleanup"
- When deploying needs safer rollout or decoupling deploy from release

## Workflow

### Step 1: Flag Strategy Assessment
```
FLAG STRATEGY:
Current System: None | Homegrown | LaunchDarkly | Unleash | Flagsmith | Split.io
Flag Needs: Release flags | Experiment flags | Ops/kill switches | Permission flags
Environments: Dev (local overrides) | Staging (server-side) | Prod (server-side) | Mobile (client-side)
Team size: <small|medium|large>  Experimentation: <none|basic|advanced>
```

### Step 2: Flag Types

**Release (short-lived):** Decouple deploy from release. Default OFF. Lifecycle: CREATE -> INTERNAL -> CANARY 1% -> RAMP 5/25/50/100% -> CLEANUP.

**Experiment (short-lived):** A/B testing with sticky bucketing. Default CONTROL. Lifecycle: CREATE -> CONFIGURE VARIANTS -> RUN -> REACH SIGNIFICANCE -> PICK WINNER -> CLEANUP.

**Ops/Kill Switch (permanent):** Emergency disable. Default ON (feature active). Lifecycle: ALWAYS AVAILABLE -> TRIGGERED DURING INCIDENT -> RESTORED. Examples: disable_recommendations, disable_search, force_maintenance_mode.

**Permission (permanent):** Plan-based access, beta programs. Default OFF. Target by user attributes, plan, org.

### Step 3: Platform Selection
```
< 5 flags, simple              -> Homegrown or Flagsmith OSS
5-50 flags, team of 5-20       -> Unleash or Flagsmith
50+ flags, experimentation      -> LaunchDarkly or Split.io
Strict data residency           -> Self-hosted Unleash/Flagsmith
```

Server-side evaluation (recommended): sub-ms, full context, rules not exposed. Client-side: works offline, no round-trip, but rules visible.

### Step 4: Targeting & Gradual Rollout
Rule priority (top to bottom): individual overrides -> employee targeting -> beta segment -> percentage rollout -> default OFF.

```
ROLLOUT STAGES:
  Internal (0.1%) 1 day -> Canary (1%) 1-2 days -> Early (5%) 2-3 days
  -> Expanding (25%) 3-5 days -> Majority (50%) 3-5 days -> Full (100%)

GATE CRITERIA: Error rate < baseline+0.1%, P95 < baseline+10%,
  Conversion > baseline-2%, Support tickets < baseline+5%
```

Sticky bucketing via murmur3 hash: `hash(flagKey:userId) % 10000 / 100`. Same user always sees same variant. Increasing percentage adds new users without flipping existing ones.

### Step 5: Kill Switches
Requirements: effect in <30s, no deploy needed, dashboard/CLI accessible, audit trail. Hierarchy: Global -> Service -> Feature -> Region -> Client. Automatic triggers: error rate >5% for 2min -> disable flag. Fallback: use locally cached values (5min TTL), then hardcoded defaults. Never crash because flag service is down.

### Step 6: Flag Lifecycle Management
Naming: `enable_<feature>` (release), `exp_<name>` (experiment), `disable_<feature>` (ops), `ops_<name>` (ops).

Stale flag detection: release at 100% for >2 weeks, experiment concluded >1 week, not evaluated in >30 days, >90 days without cleanup date. Automate weekly stale flag reminders with cleanup tickets.

### Step 7: A/B Testing
1. Define hypothesis and primary metric. 2. Set guardrail metrics (must not regress). 3. Calculate sample size. 4. Configure sticky bucketing variants. 5. Track exposure and conversion events. 6. Wait for significance (p<0.05). Pitfalls: no peeking, adjust for multiple testing, deterministic hashing not random, run full business cycle (7 days).

### Step 8: Homegrown Schema
Tables: feature_flags, flag_rules, flag_rollouts, flag_variants, flag_audit_log, flag_environments. Evaluation: cache (refresh 30s) -> env override -> global enable -> rules (priority) -> percentage (murmur3) -> default disabled.

### Step 9: Validation
Check: types categorized, naming enforced, owner assigned, cleanup dates set, kill switches defined, gradual rollout documented, sticky bucketing, fallback behavior, audit trail, stale detection, evaluation <5ms.

## Key Behaviors
1. **Flags are temporary by default.** Cleanup date required for release/experiment flags.
2. **Decouple deploy from release.** Ship dark, enable gradually.
3. **Kill switches are not optional.** Every critical feature needs emergency off.
4. **Clean up flags.** Max 2 weeks at 100% before removal.
5. **Sticky bucketing is mandatory.** Same user, same variant, every request.
6. **Test both paths.** On, off, and transition.
7. **Default to off, fail to off.** Safe defaults when flag service unreachable.
8. **Keep flag evaluation fast.** In-memory with periodic sync.

## Flags & Options

| Flag | Description |
|--|--|
| `--rollout` | Design gradual rollout plan |
| `--experiment` | Set up A/B test |
| `--killswitch` | Design kill switches |
| `--audit` | Audit for stale/orphaned flags |
| `--cleanup` | Generate cleanup plan |
| `--schema` | DB schema for homegrown flags |

## HARD RULES
1. **NEVER leave release flags at 100% for >2 weeks.** Clean up.
2. **NEVER nest flag checks.** Keep flags independent.
3. **NEVER use flags as permanent config.** Use config files for that.
4. **ALWAYS test both flag-on AND flag-off paths.**
5. **NEVER evaluate flags in hot loops.** Once per request.
6. **NEVER expose server-side targeting rules to clients.**
7. **NEVER call an experiment winner without sufficient sample size.**
8. **ALWAYS maintain an audit trail** for every flag change.

## Auto-Detection
```bash
grep -r "launchdarkly\|unleash\|flagsmith\|split\|statsig" package.json
grep -rl "featureFlag\|isEnabled\|isFeatureEnabled" src/ --include="*.ts" --include="*.py"
```

## Iteration Protocol
```
FOR EACH rollout stage (1%, 5%, 25%, 50%, 100%):
  Set percentage -> Monitor metrics for observation window
  IF degraded: ROLLBACK to previous stage
  IF stable: advance
AFTER 100%: Schedule cleanup (max 2 weeks)
```

## Multi-Agent Dispatch
```
Agent 1 (feature-sdk): SDK, evaluation wrapper, defaults
Agent 2 (feature-code): Flag-gated code, targeting, kill switch
Agent 3 (feature-ops): Rollout monitoring, lifecycle, cleanup automation
MERGE ORDER: sdk -> code -> ops
```

## TSV Logging
Log to `.godmode/feature-results.tsv`: `STEP\tFLAG_NAME\tFLAG_TYPE\tPLATFORM\tSTATUS\tDETAILS`

## Success Criteria
1. Flag evaluates correctly in both on/off states.
2. Default value is safe (off = old behavior).
3. SDK handles failure gracefully (default value, no crash).
4. Targeting rules work for specific users/segments.
5. Kill switch tested — reverts within seconds.
6. Cleanup plan with scheduled date.
7. No flag evaluation in hot loops.
8. Audit trail exists.

## Error Recovery
| Failure | Action |
|--|--|
| SDK init fails | Check API/SDK key, verify network, implement fallback defaults. |
| Flag not evaluating | Check evaluation context (user.id passed?), use provider debugger. |
| Rollout causing errors | Set to 0% immediately, check error logs for flag=on cohort, fix, resume from 1%. |
| Stale flags accumulating | Run audit, remove flag code, delete dead branches, automate weekly CI check. |
| Conflicting flags | Map dependencies, encode as prerequisites, never nest if-checks. |

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-feature-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `Feature: {flag_name} at {pct}% rollout. Metrics: error={err}%, latency_p99={lat}ms. Kill switch: {tested|untested}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH flag rollout stage:
  KEEP if: metrics within guardrails AND no error spike AND kill switch tested
  DISCARD if: error rate > baseline+0.1% OR latency > baseline+10% OR conversion drops >2%
  On discard: roll back to previous percentage. Investigate before advancing.
```

## Stop Conditions
```
STOP when ALL of:
  - Flag at 100% with stable metrics for 7 days
  - Kill switch tested and verified
  - Cleanup commit scheduled (remove flag code within 2 weeks)
```
