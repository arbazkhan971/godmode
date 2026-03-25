---
name: feature
description: |
  Feature flag design, gradual rollouts, A/B testing,
  kill switches. LaunchDarkly, Unleash, Flagsmith.
  Triggers on: /godmode:feature, "feature flag",
  "gradual rollout", "kill switch", "A/B test".
---

# Feature — Feature Flags & Progressive Delivery

## When to Activate
- User invokes `/godmode:feature`
- User says "feature flag", "gradual rollout"
- User says "kill switch", "A/B test"
- Deploying needs safer rollout or deploy/release decoupling

## Workflow

### Step 1: Flag Strategy Assessment

```bash
# Detect existing flag infrastructure
grep -r "launchdarkly\|unleash\|flagsmith\|split\|statsig" \
  package.json pyproject.toml 2>/dev/null

# Find existing flag usage
grep -rn "featureFlag\|isEnabled\|isFeatureEnabled" \
  src/ --include="*.ts" --include="*.py" 2>/dev/null | wc -l

# Check for stale flags (not evaluated in 30+ days)
grep -rn "featureFlag\|isEnabled" src/ \
  --include="*.ts" 2>/dev/null | head -20
```

```
FLAG STRATEGY:
  Current: None | Homegrown | LaunchDarkly | Unleash
  Flag needs: Release | Experiment | Ops | Permission
  Environments: Dev | Staging | Prod | Mobile

IF < 5 flags: Homegrown or Flagsmith OSS
IF 5-50 flags: Unleash or Flagsmith
IF 50+ flags with experiments: LaunchDarkly
IF strict data residency: self-hosted
```

### Step 2: Flag Types

```
| Type       | Lifecycle   | Default | Duration  |
|------------|-------------|---------|-----------|
| Release    | Short-lived | OFF     | < 2 weeks |
| Experiment | Short-lived | CONTROL | < 4 weeks |
| Ops/Kill   | Permanent   | ON      | Forever   |
| Permission | Permanent   | OFF     | Forever   |

RELEASE RAMP:
  CREATE → INTERNAL → CANARY 1% → 5% → 25%
    → 50% → 100% → CLEANUP (within 2 weeks)

EXPERIMENT RAMP:
  CREATE → CONFIGURE → RUN → SIGNIFICANCE
    → PICK WINNER → CLEANUP (within 1 week)
```

### Step 3: Targeting & Gradual Rollout

```
RULE PRIORITY (top to bottom):
  1. Individual overrides
  2. Employee targeting
  3. Beta segment
  4. Percentage rollout
  5. Default OFF

ROLLOUT STAGES:
  Internal (0.1%) 1d → Canary (1%) 1-2d
    → Early (5%) 2-3d → Expanding (25%) 3-5d
    → Majority (50%) 3-5d → Full (100%)

GATE CRITERIA (advance only if all pass):
  Error rate < baseline + 0.1%
  P95 latency < baseline + 10%
  Conversion > baseline - 2%
  Support tickets < baseline + 5%

STICKY BUCKETING:
  hash(flagKey:userId) % 10000 / 100
  Same user always sees same variant
  Increasing % adds users, never flips existing
```

### Step 4: Kill Switches

```
REQUIREMENTS:
  Effect in < 30 seconds, no deploy needed
  Dashboard/CLI accessible, audit trail
  Hierarchy: Global → Service → Feature → Region

AUTO-TRIGGERS:
  IF error rate > 5% for 2min: disable flag
  IF P99 > 3x baseline for 5min: disable flag

FALLBACK:
  Locally cached values (5min TTL)
  Then hardcoded defaults
  Never crash because flag service is down
```

### Step 5: Lifecycle Management

```
NAMING CONVENTION:
  enable_<feature> (release)
  exp_<name> (experiment)
  disable_<feature> (ops kill switch)

STALE FLAG DETECTION:
  Release at 100% for > 2 weeks: STALE
  Experiment concluded > 1 week: STALE
  Not evaluated in > 30 days: STALE
  > 90 days without cleanup date: STALE

THRESHOLDS:
  Max flags per service: 50 (audit if more)
  Evaluation latency: < 5ms (in-memory cache)
  Cache refresh interval: 30 seconds
  Cleanup deadline: 2 weeks after 100%
```

### Step 6: A/B Testing Integration

```
PROCESS:
  1. Define hypothesis + primary metric
  2. Set guardrail metrics (must not regress)
  3. Calculate sample size for power 0.80
  4. Configure sticky bucketing variants
  5. Wait for significance (p < 0.05)

THRESHOLDS:
  Minimum duration: 7 days (full business cycle)
  Alpha: 0.05, Power: 0.80
  Never peek before minimum sample reached
  Correct for multiple testing if > 2 variants
```

### Step 7: Validation
Check: types categorized, naming enforced,
  owner assigned, cleanup dates set, kill switches
  defined, sticky bucketing, fallback behavior,
  audit trail, evaluation < 5ms.

Commit: `"feature: <flag_name> — <type> at <pct>%"`

## Key Behaviors
1. **Flags are temporary by default.** Cleanup required.
2. **Decouple deploy from release.** Ship dark.
3. **Kill switches are not optional.**
4. **Clean up flags.** Max 2 weeks at 100%.
5. **Sticky bucketing is mandatory.**
6. **Test both paths.** On, off, and transition.
7. **Default to off, fail to off.**

## HARD RULES
1. Never leave release flags at 100% for > 2 weeks.
2. Never nest flag checks. Keep flags independent.
3. Never use flags as permanent config.
4. Always test both flag-on AND flag-off paths.
5. Never evaluate flags in hot loops. Once per request.
6. Never expose server-side targeting rules to clients.
7. Never call experiment winner without sample size.
8. Always maintain an audit trail for flag changes.

## Auto-Detection
```bash
grep -r "launchdarkly\|unleash\|flagsmith" package.json
grep -rl "featureFlag\|isEnabled" src/ --include="*.ts"
```

## Output Format
Print: `Feature: {flag} at {pct}% rollout.
  Error={err}%, latency_p99={lat}ms.
  Kill switch: {tested|untested}. Status: {status}.`

## TSV Logging
```
step	flag_name	flag_type	platform	status	details
```

## Keep/Discard Discipline
```
KEEP if: metrics within guardrails AND no error spike
  AND kill switch tested
DISCARD if: error > baseline+0.1% OR latency > +10%
  OR conversion drops > 2%
On discard: roll back to previous percentage.
```

## Stop Conditions
```
STOP when ALL of:
  - Flag at 100% with stable metrics for 7 days
  - Kill switch tested and verified
  - Cleanup scheduled (within 2 weeks)
```

## Error Recovery
- SDK init fails: check API key, implement fallbacks.
- Flag not evaluating: check context (user.id passed?).
- Rollout errors: set to 0%, check logs, resume at 1%.
- Stale flags: run audit, remove code, delete branches.
- Conflicting flags: map deps, encode as prerequisites.
