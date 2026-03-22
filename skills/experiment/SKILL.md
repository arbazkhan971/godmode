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
┌──────────────────┬──────────────────────────────┬──────────────────────────────┐
│ Platform │ Best For │ Key Capabilities │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│ Statsig │ High-velocity teams, │ Warehouse-native, auto │
│ │ product-led growth, │ sample size, pulse checks, │
│ │ warehouse-native analytics │ Bayesian + frequentist, │
│ │ │ free tier generous │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│ Optimizely │ Enterprise, marketing & │ Visual editor, audiences, │
│ │ product experimentation, │ Stats Engine (sequential), │
│ │ content experiments │ multi-armed bandits, │
│ │ │ full-stack + web SDKs │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│ GrowthBook │ Open-source, data-warehouse │ Self-hosted option, │
│ │ first, Bayesian stats, │ Bayesian engine, SQL-based │
│ │ privacy-conscious teams │ metrics, feature flags, │
│ │ │ free self-hosted │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│ VWO │ CRO teams, landing page │ Visual editor, heatmaps, │
│ │ optimization, marketing- │ session recordings, │
│ │ led experimentation │ SmartStats (Bayesian), │
│ │ │ personalization │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│ LaunchDarkly │ Feature flag-first teams, │ Feature flags + experiments │
│ Experiments │ progressive delivery, │ unified, targeting rules, │
│ │ server-side experiments │ Bayesian analysis, │
│ │ │ enterprise-grade │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│ PostHog │ Self-hosted, all-in-one │ Experiments + analytics + │
│ │ product analytics + │ session replay + flags, │
│ │ experimentation │ Bayesian, open source │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│ Homegrown │ Custom requirements, │ Full control, no vendor │
│ │ regulatory constraints, │ lock-in, requires stats │
│ │ unique assignment logic │ expertise and infra work │
└──────────────────┴──────────────────────────────┴──────────────────────────────┘

SELECTED: <platform>
JUSTIFICATION: <why — based on team size, traffic, statistical rigor, budget, integration>
ARCHITECTURE:
 Assignment: <client-side | server-side | edge>
 Metrics pipeline: <platform-native | warehouse-connected | custom>
 Feature flag integration: <same platform | separate system | none>
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
┌──────────────────┬──────────────────────────────┬──────────────┬──────────────┐
│ Type │ Metric │ Baseline │ Target │
├──────────────────┼──────────────────────────────┼──────────────┼──────────────┤
│ Primary (OEC) │ <Overall Evaluation │ <current │ <target │
│ │ Criterion — the single │ value> │ value or │
│ │ metric that decides ship │ │ MDE> │
│ │ or no-ship> │ │ │
├──────────────────┼──────────────────────────────┼──────────────┼──────────────┤
│ Secondary │ <supporting metric 1> │ <value> │ <direction> │
│ │ <supporting metric 2> │ <value> │ <direction> │
├──────────────────┼──────────────────────────────┼──────────────┼──────────────┤
│ Guardrail │ <metric that must NOT │ <value> │ <must not │
│ │ degrade — e.g., latency, │ │ regress │
│ │ error rate, revenue/user, │ │ beyond X> │
│ │ bounce rate> │ │ │
└──────────────────┴──────────────────────────────┴──────────────┴──────────────┘

VARIANTS:
┌───────────┬──────────────────────────────────────┬──────────────┐
│ Variant │ Description │ Traffic % │
├───────────┼──────────────────────────────────────┼──────────────┤
│ Control │ Current experience (no change) │ 50% │
│ Test A │ <description of change> │ 50% │
│ (Test B) │ <optional additional variant> │ (adjust %) │
└───────────┴──────────────────────────────────────┴──────────────┘

TARGETING:
 Audience: <all users | segment — e.g., new users, US only, mobile only>
 Exclusions: <users in conflicting experiments | internal users | bots>
 Ramp plan: <5% -> 25% -> 50% per variant, with checks at each stage>
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

 Where:
 p1 = baseline rate = <value>
 p2 = expected rate = p1 * (1 + MDE) = <value>
 Z_alpha/2 = 1.96 (for alpha = 0.05, two-tailed)
 Z_beta = 0.84 (for power = 0.80)

 RESULT:
 Sample size per variant: <N>
 Total sample size: <N * number of variants>
 At current traffic (<N>/day): <estimated days to reach sample size>
 Estimated duration: <X weeks>

BAYESIAN PARAMETERS (if applicable):
 Prior: <uninformative | weakly informative | based on prior experiments>
 Credible interval: 95%
 Decision threshold: P(Treatment > Control) >= 0.95
 Expected runtime: <duration based on convergence simulations>

MULTIPLE COMPARISONS CORRECTION:
 Method: <Bonferroni | Holm-Bonferroni | Benjamini-Hochberg | none (A/B only)>
 Adjusted alpha: <if applicable>

WARNINGS:
 - If MDE < 1%, you likely need millions of samples — consider a more targeted metric
 - If duration > 4 weeks, consider increasing MDE or targeting a higher-traffic surface
 - For revenue metrics, use larger sample sizes (higher variance)
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

ASSIGNMENT UNIT:
 ┌──────────────────┬──────────────────────────────────────────────────┐
 │ Unit │ Use When │
 ├──────────────────┼──────────────────────────────────────────────────┤
 │ User ID │ Default. Logged-in users. Consistent cross- │
 │ │ session, cross-device. │
 ├──────────────────┼──────────────────────────────────────────────────┤
 │ Device / Cookie │ Pre-login experiments (signup page, pricing). │
 │ ID │ May split across devices. │
 ├──────────────────┼──────────────────────────────────────────────────┤
 │ Session ID │ Session-scoped tests (UI variants that reset │
 │ │ each visit). Lower power, noisier. │
 ├──────────────────┼──────────────────────────────────────────────────┤
 │ Company / Org │ B2B — all users in a company see same variant. │
 │ ID │ Fewer units, need more orgs for power. │
 ├──────────────────┼──────────────────────────────────────────────────┤
 │ Page / Request │ Stateless experiments (ML model variants, │
 │ │ ranking algorithms). Each request independent. │
 └──────────────────┴──────────────────────────────────────────────────┘

 Selected unit: <unit>
 Justification: <why>

MUTUAL EXCLUSION:
 Conflicting experiments: <list experiments on the same surface>
 Isolation: <mutual exclusion layers | traffic splitting | no overlap needed>
 Strategy: <each user in at most one experiment on this surface>
```

#### Assignment Implementation
```typescript
// experiments/assignment.ts
import murmurhash3 from 'murmurhash3js';

interface ExperimentConfig {
 id: string;
 salt: string; // unique per experiment, prevents correlated assignments
 variants: { id: string; weight: number }[];
 targeting?: (context: UserContext) => boolean;
 mutualExclusionGroup?: string;
}

interface UserContext {
 userId: string;
 deviceId?: string;
 country?: string;
 platform?: string;
 userProperties?: Record<string, unknown>;
}

function assignVariant(config: ExperimentConfig, context: UserContext): string | null {
 // Check targeting rules
 if (config.targeting && !config.targeting(context)) {
 return null; // User not eligible
 }

 // Deterministic hash-based assignment
 const hashInput = `${config.salt}.${context.userId}`;
 const hash = murmurhash3.x86.hash32(hashInput);
 const bucket = (hash >>> 0) % 10000; // 0-9999

 let cumulative = 0;
 for (const variant of config.variants) {
 cumulative += variant.weight * 10000;
 if (bucket < cumulative) {
 return variant.id;
 }
 }
 return config.variants[0].id; // fallback to control
}

// Exposure logging — only log when user actually sees the variant
function logExposure(
 experimentId: string,
 variantId: string,
 userId: string,
 deduplicationKey?: string
) {
 // Deduplicate: only log first exposure per user per experiment per session
 const key = deduplicationKey || `${experimentId}:${userId}`;
 if (exposureCache.has(key)) return;
 exposureCache.add(key);

 analytics.track('Experiment Exposure', {
 experiment_id: experimentId,
 variant_id: variantId,
 timestamp: new Date().toISOString(),
 });
}
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
 Posterior: Updated after each observation batch
 Decision rules:
 SHIP: P(Treatment > Control) >= 0.95 AND expected loss < <threshold>
 KILL: P(Treatment > Control) < 0.05
 WAIT: 0.05 <= P(Treatment > Control) < 0.95

 Advantages over frequentist:
 ✓ Direct probability statement ("95% chance Treatment is better")
 ✓ Natural handling of early stopping (no peeking problem)
 ✓ Expected loss quantifies downside risk
 ✗ Requires prior specification (can be controversial)
 ✗ Computationally heavier for complex metrics

SEQUENTIAL TESTING (for valid early stopping):
 Method: <always-valid p-values (mSPRT) | group sequential (O'Brien-Fleming)>
 Looks: <scheduled analysis points — e.g., every 1000 users>
 Alpha spending: <O'Brien-Fleming | Pocock | custom spending function>
 Minimum runtime: <at least 1 full business cycle — typically 7 days>

VARIANCE REDUCTION (increase sensitivity):
 CUPED: Use pre-experiment data as covariate to reduce variance by 30-50%
 Stratified sampling: Stratify by high-variance segments (country, device, plan)
 Triggered analysis: Only include users who actually encountered the change

COMMON PITFALLS:
 ┌──────────────────────────────────┬──────────────────────────────────────────┐
 │ Pitfall │ Prevention │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ Peeking at results early │ Use sequential testing or commit to │
 │ │ fixed horizon. Never stop early on │
 │ │ standard tests. │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ P-hacking (testing many │ Pre-register primary metric. Apply │
 │ metrics until one is p < 0.05) │ Bonferroni correction for multiple │
 │ │ comparisons. │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ Multiple comparisons (many │ Use Bonferroni or Holm-Bonferroni. │
 │ variants inflate false │ With 5 variants, alpha = 0.05/5 = 0.01 │
 │ positive rate) │ per comparison. │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ Simpson's paradox (segment │ Always check overall effect before │
 │ results contradict overall) │ segment breakdowns. Do not cherry-pick │
 │ │ favorable segments. │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ Novelty / primacy effects │ Run for at least 2-3 weeks. Segment │
 │ │ by new vs returning users. │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ Sample Ratio Mismatch (SRM) │ Check actual split matches expected │
 │ │ (chi-squared test). SRM invalidates │
 │ │ results. │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ Day-of-week effects │ Always run experiments for full weeks │
 │ │ (7, 14, 21 days) to avoid bias. │
 ├──────────────────────────────────┼──────────────────────────────────────────┤
 │ Interference / network effects │ Use cluster-based randomization for │
 │ │ social features. Standard A/B fails │
 │ │ when users influence each other. │
 └──────────────────────────────────┴──────────────────────────────────────────┘
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
┌──────────────────────┬───────────────────────────────────────────────────────┐
│ Algorithm │ Description & When to Use │
├──────────────────────┼───────────────────────────────────────────────────────┤
│ Epsilon-Greedy │ Explore randomly epsilon% of time. Simple. Good │
│ │ baseline. Set epsilon = 0.1 (10% explore). │
├──────────────────────┼───────────────────────────────────────────────────────┤
│ Thompson Sampling │ Sample from posterior, pick arm with highest sample.│
│ (recommended) │ Bayesian, adapts quickly, strong theoretical │
│ │ guarantees. Best general-purpose bandit. │
├──────────────────────┼───────────────────────────────────────────────────────┤
│ UCB1 (Upper │ Pick arm with highest upper confidence bound. │
│ Confidence Bound) │ Deterministic, no random exploration. Good when │
│ │ reproducibility matters. │
├──────────────────────┼───────────────────────────────────────────────────────┤
│ Contextual Bandits │ Use user context (device, country, plan) to │
│ │ personalize arm selection. LinUCB or neural │
│ │ bandits. Higher complexity, higher reward. │
└──────────────────────┴───────────────────────────────────────────────────────┘

IMPLEMENTATION:
 Reward signal: <conversion | click | revenue | engagement score>
 Update frequency: <real-time | batch every N minutes | daily>
 Minimum exploration: <each arm gets at least N impressions before optimization>
 Convergence threshold: <stop when best arm has >95% allocation>
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
┌─────────────────────────┬──────────────────────────────────────────────┐
│ Flag Key │ Experiment │
├─────────────────────────┼──────────────────────────────────────────────┤
│ <flag_key> │ <experiment_name> │
│ │ Variants: control = false, test = true │
│ │ Status: <active | concluded | archived> │
└─────────────────────────┴──────────────────────────────────────────────┘

PROGRESSIVE DELIVERY:
 Day 0: 0% (flag off)
 Day 1: 1% (canary — check error rates, latency)
 Day 3: 5% (early signal — check guardrails)
 Day 5: 25% (significant signal — first stats check for sequential tests)
 Day 7: 50% (full experiment — run to required sample size)
 Decision day: Ship 100% or kill
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
┌───────────┬──────────────┬──────────────┬──────────────┬──────────────┐
│ Variant │ Users │ Metric Value│ vs Control │ p-value │
├───────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│ Control │ <N> │ <value> │ — │ — │
│ Treatment│ <N> │ <value> │ <+/- X%> │ <value> │
└───────────┴──────────────┴──────────────┴──────────────┴──────────────┘

 Confidence interval (95%): [<lower>, <upper>]
 Significant at alpha = 0.05: <YES | NO>
 Practical significance: <YES — exceeds MDE | NO — below MDE>
 Power achieved: <value>

SECONDARY METRICS:
┌──────────────────────────────┬──────────────┬──────────────┬──────────┐
│ Metric │ Control │ Treatment │ p-value │
├──────────────────────────────┼──────────────┼──────────────┼──────────┤
│ <metric 1> │ <value> │ <value> │ <value> │
│ <metric 2> │ <value> │ <value> │ <value> │
└──────────────────────────────┴──────────────┴──────────────┴──────────┘

GUARDRAIL METRICS:
┌──────────────────────────────┬──────────────┬──────────────┬──────────┐
│ Guardrail │ Control │ Treatment │ Status │
├──────────────────────────────┼──────────────┼──────────────┼──────────┤
│ <latency p99> │ <value> │ <value> │ OK | ALERT│
│ <error rate> │ <value> │ <value> │ OK | ALERT│
│ <revenue per user> │ <value> │ <value> │ OK | ALERT│
│ <bounce rate> │ <value> │ <value> │ OK | ALERT│
└──────────────────────────────┴──────────────┴──────────────┴──────────┘

SEGMENT ANALYSIS (check for heterogeneous treatment effects):
┌──────────────────┬──────────────┬──────────────┬──────────────────────┐
│ Segment │ Control │ Treatment │ Lift │
├──────────────────┼──────────────┼──────────────┼──────────────────────┤
│ New users │ <value> │ <value> │ <+/- X%> │
│ Returning users │ <value> │ <value> │ <+/- X%> │
│ Mobile │ <value> │ <value> │ <+/- X%> │
│ Desktop │ <value> │ <value> │ <+/- X%> │
│ Free plan │ <value> │ <value> │ <+/- X%> │
│ Paid plan │ <value> │ <value> │ <+/- X%> │
└──────────────────┴──────────────┴──────────────┴──────────────────────┘

 NOTE: Segment analysis is exploratory. Do NOT use segment results to
 override the overall decision unless pre-registered. Segment findings
 should generate hypotheses for follow-up experiments.

DECISION FRAMEWORK:
┌─────────────────────────────────────────────────────────────────────────┐
│ Stat sig + Positive + Guardrails OK → SHIP IT │
│ Stat sig + Positive + Guardrail ALERT → INVESTIGATE guardrail│
│ Stat sig + Negative → KILL IT │
│ Not sig + Reached sample size → INCONCLUSIVE — kill │
│ Not sig + Under sample size → KEEP RUNNING │
│ Stat sig + Below MDE → Likely not worth it │
└─────────────────────────────────────────────────────────────────────────┘

RECOMMENDATION: <SHIP IT | ITERATE | KILL IT | KEEP RUNNING | INCONCLUSIVE>
 Rationale: <evidence-based reasoning citing metrics above>
 Follow-up: <next experiment or action based on learnings>
```

### Step 10: Experiment Lifecycle Management
Track experiments from ideation to conclusion:

```
EXPERIMENT LIFECYCLE:

EXPERIMENT BACKLOG:
┌─────┬──────────────────────┬──────────┬──────────┬───────────────────┐
│ # │ Experiment │ Status │ Surface │ Expected Impact │
├─────┼──────────────────────┼──────────┼──────────┼───────────────────┤
│ 1 │ <name> │ LIVE │ <page> │ +<X%> <metric> │
│ 2 │ <name> │ QUEUED │ <page> │ +<X%> <metric> │
│ 3 │ <name> │ DESIGN │ <page> │ +<X%> <metric> │
│ 4 │ <name> │ DONE │ <page> │ Shipped +<X%> │
└─────┴──────────────────────┴──────────┴──────────┴───────────────────┘

LIFECYCLE STATES:
 IDEA → DESIGN → REVIEW → QUEUED → RAMPING → LIVE → ANALYZING → DECIDED → CLEANUP

 IDEA: Hypothesis documented, no design yet
 DESIGN: Experiment designed, metrics defined, sample size calculated
 REVIEW: Peer review of experiment design (avoid bias, check metrics)
 QUEUED: Implementation done, waiting for traffic slot / mutual exclusion
 RAMPING: Gradually increasing traffic (canary phase)
 LIVE: Full traffic, collecting data
 ANALYZING: Reached sample size, analyzing results
 DECIDED: Ship / kill decision made
 CLEANUP: Losing variant code removed, flag cleaned up

EXPERIMENT VELOCITY:
 Experiments launched this month: <N>
 Experiments concluded this month: <N>
 Win rate: <N>% (experiments shipped / experiments concluded)
 Average duration: <N> days
 Current active: <N> experiments
 Backlog depth: <N> experiments queued
```


### Step 12: Validation & Delivery
Validate the experiment setup before launching:

```
EXPERIMENT VALIDATION:
┌──────────────────────────────────────────────────────┬──────────────┐
│ Check │ Status │
├──────────────────────────────────────────────────────┼──────────────┤
│ Hypothesis is specific and falsifiable │ PASS | FAIL │
│ Primary metric (OEC) is defined │ PASS | FAIL │
│ Guardrail metrics are defined │ PASS | FAIL │
│ Sample size calculated and achievable │ PASS | FAIL │
│ Power >= 0.80 for target MDE │ PASS | FAIL │
│ Assignment is deterministic and sticky │ PASS | FAIL │
│ Exposure logging fires on variant render │ PASS | FAIL │
│ Exposure is deduplicated (one per user per session) │ PASS | FAIL │
│ Control experience is unchanged │ PASS | FAIL │
│ Treatment renders correctly on all devices │ PASS | FAIL │
│ Mutual exclusion configured for conflicting tests │ PASS | FAIL │
│ Ramp plan defined (canary -> full traffic) │ PASS | FAIL │
│ Metric events fire correctly for all variants │ PASS | FAIL │
│ SRM check will run on Day 1 │ PASS | FAIL │
│ No peeking plan — analysis only at sample size │ PASS | FAIL │
│ Rollback plan if guardrail alert fires │ PASS | FAIL │
│ Feature flag kills treatment if needed │ PASS | FAIL │
│ Duration accounts for full-week cycles │ PASS | FAIL │
└──────────────────────────────────────────────────────┴──────────────┘

LAUNCH CHECKLIST:
 [ ] Experiment design peer-reviewed
 [ ] Implementation code reviewed
 [ ] QA verified both variants render correctly
 [ ] Analytics events verified in staging
 [ ] SRM monitoring configured
 [ ] Guardrail alerts configured
 [ ] Rollback procedure documented
 [ ] Stakeholders notified of experiment launch
 [ ] Calendar reminder set for analysis date

VERDICT: <READY TO LAUNCH | NEEDS REVISION>
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
Statistical method: <frequentist | Bayesian | sequential>

Next steps:
-> /godmode:analytics — Verify metric events are tracking correctly
-> /godmode:observe — Monitor guardrail metrics during experiment
-> /godmode:report — Generate experiment results report
-> /godmode:chart — Visualize experiment results
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

## Example Usage

### Designing a New A/B Test
```
User: /godmode:experiment I want to test a new checkout flow

Experiment: Starting experiment design...

EXPERIMENT DESIGN:
Name: checkout-single-page-v2
Hypothesis: If we consolidate the 4-step checkout into a single page,
 then checkout completion rate will increase by 8% because users
 currently abandon between steps 2 and 3 (address -> payment).

Primary metric (OEC): Checkout completion rate
 Baseline: 62.4%
 MDE: 8% relative (62.4% -> 67.4%)

Guardrails: p99 latency, payment error rate, average order value

Power analysis:
 Sample size: 4,800 per variant (9,600 total)
 At 800 checkouts/day: ~12 days
 Planned duration: 14 days (2 full weeks)

Assignment: Deterministic hash of user_id, 50/50 split
Platform: Statsig

Ready to implement. Proceed?
```


## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full experiment design workflow |
| `--platform <name>` | Force platform: `statsig`, `optimizely`, `growthbook`, `vwo`, `launchdarkly`, `posthog`, `custom` |
| `--design` | Design experiment only (hypothesis, metrics, sample size) — no implementation |
| `--analyze <name>` | Analyze results for a running or completed experiment |
| `--power` | Run power analysis and sample size calculation only |
| `--audit` | Audit running experiments for SRM, peeking, missing guardrails |
| `--bandit` | Use multi-armed bandit instead of fixed A/B test |
| `--sequential` | Use sequential testing for valid early stopping |
| `--bayesian` | Use Bayesian analysis (probability of being better, expected loss) |
| `--backlog` | View and prioritize the experiment backlog |
| `--cleanup <name>` | Remove losing variant code and archive experiment |
| `--multivariate` | Design a multivariate test (3+ variants) |
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
All of these must be true before marking the task complete:
1. Feature flag creates clean separation between control and treatment (no code leakage between variants).
2. Assignment is deterministic per user (same user always gets same variant across sessions).
3. Exposure event fires exactly once per user per experiment per session (deduplication verified).
4. SRM check runs on Day 1 and validates split ratio within tolerance (chi-squared p > 0.01).
5. Sample size calculation is documented with MDE, alpha, power, and baseline conversion rate.
6. Guardrail metrics are defined and monitored (minimum: latency, error rate, revenue).
7. Analysis query correctly joins exposures to outcomes and excludes contaminated users.
8. Cleanup plan exists: flag removal scheduled within 2 weeks of experiment conclusion.
