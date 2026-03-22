---
name: experiment
description: A/B testing, experimentation platforms, statistical analysis, multivariate testing. Use when user mentions A/B test, experiment, split test, multivariate test, statistical significance, conversion optimization, Optimizely, Statsig, GrowthBook.
---

# Experiment — A/B Testing & Experimentation

## When to Activate
- User invokes `/godmode:experiment`
- User says "A/B test", "split test", "run an experiment", "multivariate test"
- User says "statistical significance", "conversion optimization", "test a variant"
- User says "set up Optimizely", "configure Statsig", "use GrowthBook", "VWO", "LaunchDarkly experiments"
- User says "sample size calculation", "power analysis", "p-value", "confidence interval"
- User says "feature flag experiment", "multi-armed bandit", "experiment results"
- When `/godmode:plan` identifies experimentation or conversion optimization tasks

## Workflow

### Step 1: Experiment Discovery
Understand the business context and what needs to be tested:

```
EXPERIMENT DISCOVERY:
Project: <name and purpose>
Business goal: <what outcome we want to improve>
Current state:
 - Baseline metric: <metric name> = <current value>
 - Traffic volume: <daily users / events hitting the surface>
 - Existing experiments: <none | list of active experiments>
Surface: <web page | mobile screen | API endpoint | email | pricing page>
Framework: <React | Next.js | Vue | React Native | iOS | Android | backend>
Experimentation platform: <none | Optimizely | Statsig | GrowthBook | VWO | LaunchDarkly | PostHog | homegrown>
Data warehouse: <BigQuery | Snowflake | Redshift | none>
Analytics platform: <Amplitude | Mixpanel | PostHog | Segment | none>
Risk tolerance: <low — revenue surface | medium — growth feature | high — minor UX change>
```

If the user hasn't specified, ask: "What metric are you trying to improve, and what change do you believe will move it?"

### Step 2: Experimentation Platform Selection
Choose the right platform for the team's needs:

```
PLATFORM SELECTION:
| Platform | Best For | Key Capabilities |
|---|---|---|
| Statsig | High-velocity teams, | Warehouse-native, auto |
|  | product-led growth, | sample size, pulse checks, |
|  | warehouse-native analytics | Bayesian + frequentist, |
|  |  | free tier generous |
| Optimizely | Enterprise, marketing & | Visual editor, audiences, |
|  | product experimentation, | Stats Engine (sequential), |
|  | content experiments | multi-armed bandits, |
|  |  | full-stack + web SDKs |
| GrowthBook | Open-source, data-warehouse | Self-hosted option, |
```

### Step 3: Experiment Design
Design a rigorous experiment with clear hypothesis and metrics:

```
EXPERIMENT DESIGN:
Name: <experiment-slug> (e.g., "checkout-single-page-v2")
Owner: <team or person>
Start date: <planned start>
Hypothesis: If we <change>, then <metric> will <improve/decrease> by <magnitude>
 because <reasoning based on data, user research, or prior experiments>.

METRICS:
| Type | Metric | Baseline | Target |
|---|---|---|---|
| Primary (OEC) | <Overall Evaluation | <current | <target |
|  | Criterion — the single | value> | value or |
|  | metric that decides ship |  | MDE> |
|  | or no-ship> |  |  |
```

### Step 4: Sample Size & Power Analysis
Calculate the required sample size before launching:

```
POWER ANALYSIS:
Statistical approach: <frequentist | Bayesian>

FREQUENTIST PARAMETERS:
 Significance level (alpha): 0.05 (5% false positive rate)
 Power (1 - beta): 0.80 (80% chance of detecting a true effect)
 Baseline conversion rate: <current rate — e.g., 3.2%>
 Minimum Detectable Effect (MDE): <smallest meaningful change — e.g., 10% relative>
 Test type: <two-tailed | one-tailed>
 Number of variants: <2 for A/B, N for multivariate>

SAMPLE SIZE CALCULATION:
 Formula (two-proportion z-test):
 n = (Z_alpha/2 + Z_beta)^2 * (p1*(1-p1) + p2*(1-p2)) / (p2 - p1)^2

```

### Step 5: Assignment Strategy
Design how users are assigned to variants:

```
ASSIGNMENT STRATEGY:

METHOD: <deterministic hashing | random with persistence | platform-managed>

DETERMINISTIC HASHING (recommended):
 Hash input: <user_id + experiment_id>
 Hash function: MurmurHash3 (fast, uniform distribution)
 Bucketing: hash % 10000 -> 0-4999 = Control, 5000-9999 = Treatment

 Properties:
 ✓ Deterministic — same user always gets same variant
 ✓ No storage required — variant computed from hash
 ✓ Works across client and server — same assignment everywhere
 ✓ No race conditions — no network call needed

```

#### Assignment Implementation
```typescript
// experiments/assignment.ts
import murmurhash3 from 'murmurhash3js';

interface ExperimentConfig {
 id: string;
 salt: string; // unique per experiment, prevents correlated assignments
# ... (condensed)
```

### Step 6: Statistical Methods
Choose and configure the right statistical approach:

```
STATISTICAL METHODS:

FREQUENTIST (default — well understood, industry standard):
 Test: <Z-test for proportions | t-test for means | Mann-Whitney for non-normal>
 Correction: <Bonferroni for multiple variants | Holm for multiple metrics>
 Sequential testing: <fixed-horizon (recommended) | group-sequential (mSPRT)>

 Decision rules:
 SHIP: p-value < 0.05 AND effect size >= MDE AND no guardrail regressions
 KILL: p-value < 0.05 AND effect is negative
 WAIT: p-value >= 0.05 AND sample size not yet reached
 INCONCLUSIVE: sample size reached AND p-value >= 0.05 -> no detectable effect

BAYESIAN (when you need probability of being better):
 Prior: Beta(alpha, beta) based on <historical data | uninformative Beta(1,1)>
```

### Step 7: Multi-Armed Bandits
For optimization-focused experiments where exploration-exploitation tradeoff matters:

```
MULTI-ARMED BANDITS:

WHEN TO USE BANDITS INSTEAD OF A/B TESTS:
 ✓ Optimizing for immediate reward (ad selection, recommendations, content ranking)
 ✓ Short-lived experiments with high opportunity cost (promotions, landing pages)
 ✓ Many variants (>4) where fixed-split A/B is too expensive
 ✗ NOT for learning causal effects (bandits optimize, not measure)
 ✗ NOT for permanent product changes (use A/B test for ship/no-ship decisions)

ALGORITHMS:
| Algorithm | Description & When to Use |
|---|---|
| Epsilon-Greedy | Explore randomly epsilon% of time. Simple. Good |
|  | baseline. Set epsilon = 0.1 (10% explore). |
```

### Step 8: Feature Flag Integration
Connect experiments to feature flags for safe rollout:

```
FEATURE FLAG INTEGRATION:

LIFECYCLE:
 1. Feature flag created (off by default)
 2. Flag enabled for internal team (dogfood)
 3. Experiment created targeting flag
 4. Experiment ramps traffic (5% -> 25% -> 50%)
 5. Experiment reaches conclusion
 6. Ship: flag turned ON for 100%, experiment archived
 7. Kill: flag turned OFF, experiment archived
 8. Clean up: flag removed from codebase, code for losing variant deleted

FLAG-EXPERIMENT MAPPING:
| Flag Key | Experiment |
```

### Step 9: Results Analysis & Decision Making
Analyze experiment results and make data-driven decisions:

```
EXPERIMENT RESULTS:
Experiment: <name>
Duration: <start_date> — <end_date>
Total participants: <N> (Control: <N>, Treatment: <N>)

SAMPLE RATIO MISMATCH CHECK:
 Expected ratio: 50/50
 Actual ratio: <actual>/<actual>
 Chi-squared p-value: <value>
 SRM detected: <NO — proceed | YES — investigate before trusting results>

PRIMARY METRIC (OEC):
| Variant | Users | Metric Value | vs Control | p-value |
```

### Step 10: Experiment Lifecycle Management
Track experiments from ideation to conclusion:

```
EXPERIMENT LIFECYCLE:

EXPERIMENT BACKLOG:
| # | Experiment | Status | Surface | Expected Impact |
|---|---|---|---|---|
| 1 | <name> | LIVE | <page> | +<X%> <metric> |
| 2 | <name> | QUEUED | <page> | +<X%> <metric> |
| 3 | <name> | DESIGN | <page> | +<X%> <metric> |
| 4 | <name> | DONE | <page> | Shipped +<X%> |

LIFECYCLE STATES:
 IDEA → DESIGN → REVIEW → QUEUED → RAMPING → LIVE → ANALYZING → DECIDED → CLEANUP

```

### Step 12: Validation & Delivery
Validate the experiment setup before launching:

```
EXPERIMENT VALIDATION:
| Check | Status |
|---|---|
| Hypothesis is specific and falsifiable | PASS | FAIL |
| Primary metric (OEC) is defined | PASS | FAIL |
| Guardrail metrics are defined | PASS | FAIL |
| Sample size calculated and achievable | PASS | FAIL |
| Power >= 0.80 for target MDE | PASS | FAIL |
| Assignment is deterministic and sticky | PASS | FAIL |
| Exposure logging fires on variant render | PASS | FAIL |
| Exposure is deduplicated (one per user per session) | PASS | FAIL |
| Control experience is unchanged | PASS | FAIL |
| Treatment renders correctly on all devices | PASS | FAIL |
| Mutual exclusion configured for conflicting tests | PASS | FAIL |
```

```
EXPERIMENT IMPLEMENTATION COMPLETE:

Artifacts:
- Experiment config: src/experiments/<experiment-name>.ts
- Assignment logic: src/experiments/assignment.ts
- Exposure logging: src/experiments/exposure.ts
- Feature flag: <flag_key> in <platform>
- Metrics definition: docs/experiments/<experiment-name>.md

Platform: <platform>
Experiment: <name>
Variants: <N> (<list>)
Primary metric: <metric>
Guardrails: <list>
Sample size: <N per variant> (<estimated duration>)
```

Commit: `"experiment: <name> — <N> variants, <primary metric>, <statistical method>"`

## Key Behaviors

1. **Hypothesis before code.** Every experiment starts with a written, falsifiable hypothesis. If you cannot state what you expect to happen and why, you are not ready to test.
2. **Calculate sample size first.** Know how long the experiment needs to run before you start. Underpowered experiments waste time and produce noise.
3. **Never peek at results.** Standard frequentist tests are only valid at the pre-committed sample size. Peeking inflates false positives. Use sequential testing if you need valid early stopping.
4. **One primary metric.** Multiple primary metrics inflate false positive rates. Pick one Overall Evaluation Criterion. Everything else is secondary or guardrail.
5. **Guardrails are non-negotiable.** Always monitor latency, error rate, and revenue. A conversion win that tanks performance is not a win.
6. **Check for SRM on Day 1.** Sample Ratio Mismatch means your randomization is broken. Any results from an SRM experiment are invalid.
7. **Ship or kill — do not compromise.** Inconclusive results mean kill. "Let's ship to 20% and see" is not a valid conclusion. Run a follow-up experiment with a better hypothesis.
8. **Clean up after every experiment.** Remove losing variant code and delete the feature flag. Experiment debt is real.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full experiment design workflow |
| `--platform <name>` | Force platform: `statsig`, `optimizely`, `growthbook`, `vwo`, `launchdarkly`, `posthog`, `custom` |
| `--design` | Design experiment only (hypothesis, metrics, sample size) — no implementation |
AUTO-DETECT SEQUENCE:
1. Scan for experimentation SDK imports (statsig, optimizely, growthbook, launchdarkly, posthog, vwo)
2. Detect analytics platform (Amplitude, Mixpanel, Segment, PostHog) from package.json / requirements.txt
3. Check for existing feature flag configuration files
4. Identify data warehouse connection (BigQuery, Snowflake, Redshift) from env vars or config
5. Scan for existing experiment configs or assignment logic
6. Detect framework (React, Next.js, Vue, etc.) for client-side assignment patterns
7. Check for existing A/B test infrastructure (hash-based assignment, exposure logging)
```

### Keep/Discard Discipline
Each experiment either advances the branch or gets reverted. No half-implemented experiments remain in the tree.
- **KEEP**: Validated, implemented, metrics confirmed. Commit it.
- **DISCARD**: Failed validation, broke existing tests, or guardrails tripped. `git revert` to last good state.
- **CRASH**: Implementation error. If fixable (typo/import), fix and retry once. If fundamental, discard and move on.

### Results TSV Logging
After each experiment iteration, append to `.godmode/experiment-results.tsv`:
```
COMMIT	METRIC	MEMORY	STATUS	DESCRIPTION
a1b2c3d	conversion_rate	512MB	keep	checkout-single-page — 50/50 split, Statsig, MDE=8%
(none)	bounce_rate	—	discard	hero-banner-test — SRM detected in validation, reverted
(none)	latency_p99	—	crash	edge-assignment — SDK incompatible with runtime, skipped
```

## Stop Conditions
- All success criteria (8 checks) pass for the current experiment.
- Feature flag cleanly separates control and treatment with no code leakage.
- Exposure logging fires exactly once per user per experiment per session.
- Sample size calculation documented with MDE, alpha, power, and baseline rate.
- Guardrail metrics defined and monitored (latency, error rate, revenue minimum).

## Hard Rules

```
HARD RULES — EXPERIMENT:
1. NEVER skip sample size calculation. Underpowered experiments waste traffic and produce noise.
2. NEVER launch without a written, falsifiable hypothesis.
3. NEVER use more than ONE primary metric (OEC). Multiple primaries inflate false positive rates.
4. NEVER peek at frequentist test results before reaching sample size. Use sequential testing if early stopping is needed.
5. ALWAYS define guardrail metrics (latency, error rate, revenue) before launch.
6. ALWAYS check for SRM on Day 1. If SRM detected, results are INVALID — do not interpret them.
7. ALWAYS run experiments for full-week multiples (7, 14, 21 days) to avoid day-of-week bias.
8. NEVER ship inconclusive results at partial traffic. Kill it or redesign.
9. ALWAYS clean up losing variant code and delete feature flags after experiment concludes.
10. NEVER skip the exposure deduplication — log ONE exposure per user per experiment per session.
```

## Success Criteria
Verify all of these before marking the task complete:
1. Feature flag creates clean separation between control and treatment (no code leakage between variants).
2. Assignment is deterministic per user (same user always gets same variant across sessions).
3. Exposure event fires exactly once per user per experiment per session (deduplication verified).
4. SRM check runs on Day 1 and validates split ratio within tolerance (chi-squared p > 0.01).
5. Sample size calculation is documented with MDE, alpha, power, and baseline conversion rate.
6. Guardrail metrics are defined and monitored (minimum: latency, error rate, revenue).
7. Analysis query correctly joins exposures to outcomes and excludes contaminated users.
8. Cleanup plan exists: flag removal scheduled within 2 weeks of experiment conclusion.

## Output Format
Print: `Experiment: {name} — {status}. Split: {control}%/{treatment}%. Sample: {current}/{required}. p-value: {p}. Lift: {lift}%. Status: {DONE|PARTIAL}.`

## Error Recovery
| Failure | Action |
|---------|--------|
| SRM detected (uneven split) | Halt analysis immediately. Check assignment logic, bot filtering, and exposure logging. Do not interpret results until SRM resolved. |
| Feature flag leaking between variants | Verify flag evaluation is deterministic per user ID. Check for caching issues. Re-instrument and restart experiment. |
| Sample size not reached after planned duration | Extend duration or increase traffic allocation. Never peek at frequentist results early — use sequential testing if early stopping needed. |
| Guardrail metric breached | Kill treatment immediately. Roll back to control. Investigate root cause before re-launching. |
