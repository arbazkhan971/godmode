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
│  Platform        │  Best For                    │  Key Capabilities            │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│  Statsig         │  High-velocity teams,        │  Warehouse-native, auto      │
│                  │  product-led growth,         │  sample size, pulse checks,  │
│                  │  warehouse-native analytics  │  Bayesian + frequentist,     │
│                  │                              │  free tier generous           │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│  Optimizely      │  Enterprise, marketing &     │  Visual editor, audiences,   │
│                  │  product experimentation,    │  Stats Engine (sequential),  │
│                  │  content experiments         │  multi-armed bandits,        │
│                  │                              │  full-stack + web SDKs       │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│  GrowthBook      │  Open-source, data-warehouse │  Self-hosted option,         │
│                  │  first, Bayesian stats,      │  Bayesian engine, SQL-based  │
│                  │  privacy-conscious teams     │  metrics, feature flags,     │
│                  │                              │  free self-hosted            │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│  VWO             │  CRO teams, landing page     │  Visual editor, heatmaps,   │
│                  │  optimization, marketing-    │  session recordings,         │
│                  │  led experimentation         │  SmartStats (Bayesian),      │
│                  │                              │  personalization             │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│  LaunchDarkly    │  Feature flag-first teams,   │  Feature flags + experiments │
│  Experiments     │  progressive delivery,       │  unified, targeting rules,   │
│                  │  server-side experiments     │  Bayesian analysis,          │
│                  │                              │  enterprise-grade            │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│  PostHog         │  Self-hosted, all-in-one     │  Experiments + analytics +   │
│                  │  product analytics +         │  session replay + flags,     │
│                  │  experimentation             │  Bayesian, open source       │
├──────────────────┼──────────────────────────────┼──────────────────────────────┤
│  Homegrown       │  Custom requirements,        │  Full control, no vendor     │
│                  │  regulatory constraints,     │  lock-in, requires stats     │
│                  │  unique assignment logic     │  expertise and infra work    │
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
│  Type            │  Metric                      │  Baseline    │  Target      │
├──────────────────┼──────────────────────────────┼──────────────┼──────────────┤
│  Primary (OEC)   │  <Overall Evaluation         │  <current    │  <target     │
│                  │  Criterion — the single      │  value>      │  value or    │
│                  │  metric that decides ship     │              │  MDE>        │
│                  │  or no-ship>                  │              │              │
├──────────────────┼──────────────────────────────┼──────────────┼──────────────┤
│  Secondary       │  <supporting metric 1>       │  <value>     │  <direction> │
│                  │  <supporting metric 2>       │  <value>     │  <direction> │
├──────────────────┼──────────────────────────────┼──────────────┼──────────────┤
│  Guardrail       │  <metric that must NOT       │  <value>     │  <must not   │
│                  │  degrade — e.g., latency,    │              │  regress     │
│                  │  error rate, revenue/user,    │              │  beyond X>   │
│                  │  bounce rate>                │              │              │
└──────────────────┴──────────────────────────────┴──────────────┴──────────────┘

VARIANTS:
┌───────────┬──────────────────────────────────────┬──────────────┐
│  Variant  │  Description                         │  Traffic %   │
├───────────┼──────────────────────────────────────┼──────────────┤
│  Control  │  Current experience (no change)      │  50%         │
│  Test A   │  <description of change>             │  50%         │
│  (Test B) │  <optional additional variant>       │  (adjust %)  │
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
  │  Unit             │  Use When                                       │
  ├──────────────────┼──────────────────────────────────────────────────┤
  │  User ID          │  Default. Logged-in users. Consistent cross-    │
  │                   │  session, cross-device.                         │
  ├──────────────────┼──────────────────────────────────────────────────┤
  │  Device / Cookie  │  Pre-login experiments (signup page, pricing).  │
  │  ID               │  May split across devices.                      │
  ├──────────────────┼──────────────────────────────────────────────────┤
  │  Session ID       │  Session-scoped tests (UI variants that reset   │
  │                   │  each visit). Lower power, noisier.             │
  ├──────────────────┼──────────────────────────────────────────────────┤
  │  Company / Org    │  B2B — all users in a company see same variant. │
  │  ID               │  Fewer units, need more orgs for power.         │
  ├──────────────────┼──────────────────────────────────────────────────┤
  │  Page / Request   │  Stateless experiments (ML model variants,      │
  │                   │  ranking algorithms). Each request independent. │
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

#### Server-Side Assignment
```typescript
// experiments/server.ts
import { createHash } from 'crypto';

function serverAssign(experimentId: string, userId: string, variants: string[]): string {
  const hash = createHash('sha256')
    .update(`${experimentId}:${userId}`)
    .digest();
  const bucket = hash.readUInt32BE(0) % 10000;
  const segmentSize = 10000 / variants.length;
  const index = Math.floor(bucket / segmentSize);
  return variants[Math.min(index, variants.length - 1)];
}

// Feature flag integration (LaunchDarkly / Statsig / GrowthBook pattern)
function getExperimentVariant(flagKey: string, userId: string, defaults: string = 'control'): string {
  try {
    // Platform-specific: replace with your SDK
    return experimentClient.getVariant(flagKey, { userId });
  } catch (error) {
    console.error(`[Experiment] Failed to get variant for ${flagKey}:`, error);
    return defaults; // Always fall back to control
  }
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
    SHIP:   p-value < 0.05 AND effect size >= MDE AND no guardrail regressions
    KILL:   p-value < 0.05 AND effect is negative
    WAIT:   p-value >= 0.05 AND sample size not yet reached
    INCONCLUSIVE: sample size reached AND p-value >= 0.05 -> no detectable effect

BAYESIAN (when you need probability of being better):
  Prior: Beta(alpha, beta) based on <historical data | uninformative Beta(1,1)>
  Posterior: Updated after each observation batch
  Decision rules:
    SHIP:   P(Treatment > Control) >= 0.95 AND expected loss < <threshold>
    KILL:   P(Treatment > Control) < 0.05
    WAIT:   0.05 <= P(Treatment > Control) < 0.95

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
  │  Pitfall                         │  Prevention                              │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  Peeking at results early        │  Use sequential testing or commit to     │
  │                                  │  fixed horizon. Never stop early on      │
  │                                  │  standard tests.                         │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  P-hacking (testing many         │  Pre-register primary metric. Apply      │
  │  metrics until one is p < 0.05)  │  Bonferroni correction for multiple      │
  │                                  │  comparisons.                            │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  Multiple comparisons (many      │  Use Bonferroni or Holm-Bonferroni.      │
  │  variants inflate false          │  With 5 variants, alpha = 0.05/5 = 0.01 │
  │  positive rate)                  │  per comparison.                         │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  Simpson's paradox (segment      │  Always check overall effect before      │
  │  results contradict overall)     │  segment breakdowns. Do not cherry-pick  │
  │                                  │  favorable segments.                     │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  Novelty / primacy effects       │  Run for at least 2-3 weeks. Segment    │
  │                                  │  by new vs returning users.              │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  Sample Ratio Mismatch (SRM)     │  Check actual split matches expected     │
  │                                  │  (chi-squared test). SRM invalidates     │
  │                                  │  results.                                │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  Day-of-week effects             │  Always run experiments for full weeks   │
  │                                  │  (7, 14, 21 days) to avoid bias.        │
  ├──────────────────────────────────┼──────────────────────────────────────────┤
  │  Interference / network effects  │  Use cluster-based randomization for     │
  │                                  │  social features. Standard A/B fails     │
  │                                  │  when users influence each other.        │
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
│  Algorithm           │  Description & When to Use                           │
├──────────────────────┼───────────────────────────────────────────────────────┤
│  Epsilon-Greedy      │  Explore randomly epsilon% of time. Simple. Good     │
│                      │  baseline. Set epsilon = 0.1 (10% explore).          │
├──────────────────────┼───────────────────────────────────────────────────────┤
│  Thompson Sampling   │  Sample from posterior, pick arm with highest sample.│
│  (recommended)       │  Bayesian, adapts quickly, strong theoretical        │
│                      │  guarantees. Best general-purpose bandit.            │
├──────────────────────┼───────────────────────────────────────────────────────┤
│  UCB1 (Upper         │  Pick arm with highest upper confidence bound.       │
│  Confidence Bound)   │  Deterministic, no random exploration. Good when     │
│                      │  reproducibility matters.                            │
├──────────────────────┼───────────────────────────────────────────────────────┤
│  Contextual Bandits  │  Use user context (device, country, plan) to         │
│                      │  personalize arm selection. LinUCB or neural         │
│                      │  bandits. Higher complexity, higher reward.          │
└──────────────────────┴───────────────────────────────────────────────────────┘

IMPLEMENTATION:
  Reward signal: <conversion | click | revenue | engagement score>
  Update frequency: <real-time | batch every N minutes | daily>
  Minimum exploration: <each arm gets at least N impressions before optimization>
  Convergence threshold: <stop when best arm has >95% allocation>
```

#### Bandit Implementation
```typescript
// experiments/bandit.ts

interface BanditArm {
  id: string;
  successes: number;
  failures: number;
}

// Thompson Sampling for binary outcomes (clicks, conversions)
function thompsonSampling(arms: BanditArm[]): string {
  let bestArm = arms[0].id;
  let bestSample = -1;

  for (const arm of arms) {
    // Sample from Beta distribution
    const sample = betaSample(arm.successes + 1, arm.failures + 1);
    if (sample > bestSample) {
      bestSample = sample;
      bestArm = arm.id;
    }
  }

  return bestArm;
}

// Epsilon-greedy: simple but effective
function epsilonGreedy(arms: BanditArm[], epsilon: number = 0.1): string {
  if (Math.random() < epsilon) {
    // Explore: random arm
    return arms[Math.floor(Math.random() * arms.length)].id;
  }
  // Exploit: best-performing arm
  return arms.reduce((best, arm) => {
    const rate = arm.successes / (arm.successes + arm.failures || 1);
    const bestRate = best.successes / (best.successes + best.failures || 1);
    return rate > bestRate ? arm : best;
  }).id;
}

// Update after observing reward
function updateArm(arm: BanditArm, reward: boolean) {
  if (reward) arm.successes++;
  else arm.failures++;
}
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
│  Flag Key               │  Experiment                                  │
├─────────────────────────┼──────────────────────────────────────────────┤
│  <flag_key>             │  <experiment_name>                           │
│                         │  Variants: control = false, test = true      │
│                         │  Status: <active | concluded | archived>     │
└─────────────────────────┴──────────────────────────────────────────────┘

PROGRESSIVE DELIVERY:
  Day 0: 0% (flag off)
  Day 1: 1% (canary — check error rates, latency)
  Day 3: 5% (early signal — check guardrails)
  Day 5: 25% (significant signal — first stats check for sequential tests)
  Day 7: 50% (full experiment — run to required sample size)
  Decision day: Ship 100% or kill
```

#### Feature Flag + Experiment Implementation
```typescript
// experiments/feature-experiment.ts

interface FeatureExperiment {
  flagKey: string;
  experimentId: string;
  variants: {
    control: { flagValue: boolean | string; weight: number };
    treatment: { flagValue: boolean | string; weight: number };
  };
  targetingRules?: TargetingRule[];
}

// React hook for feature experiments
function useExperiment(flagKey: string): {
  variant: string;
  isEnabled: boolean;
  isLoading: boolean;
} {
  const { userId } = useAuth();
  const [variant, setVariant] = useState<string>('control');
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const assignment = experimentClient.getVariant(flagKey, { userId });
    setVariant(assignment);
    setIsLoading(false);

    // Log exposure only when component renders (user sees variant)
    experimentClient.logExposure(flagKey, assignment, userId);
  }, [flagKey, userId]);

  return {
    variant,
    isEnabled: variant !== 'control',
    isLoading,
  };
}

// Usage in component
function CheckoutPage() {
  const { variant, isEnabled, isLoading } = useExperiment('checkout-single-page');

  if (isLoading) return <CheckoutSkeleton />;

  return isEnabled ? <SinglePageCheckout /> : <MultiStepCheckout />;
}
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
│  Variant  │  Users       │  Metric Value│  vs Control  │  p-value     │
├───────────┼──────────────┼──────────────┼──────────────┼──────────────┤
│  Control  │  <N>         │  <value>     │  —           │  —           │
│  Treatment│  <N>         │  <value>     │  <+/- X%>    │  <value>     │
└───────────┴──────────────┴──────────────┴──────────────┴──────────────┘

  Confidence interval (95%): [<lower>, <upper>]
  Significant at alpha = 0.05: <YES | NO>
  Practical significance: <YES — exceeds MDE | NO — below MDE>
  Power achieved: <value>

SECONDARY METRICS:
┌──────────────────────────────┬──────────────┬──────────────┬──────────┐
│  Metric                      │  Control     │  Treatment   │  p-value │
├──────────────────────────────┼──────────────┼──────────────┼──────────┤
│  <metric 1>                  │  <value>     │  <value>     │  <value> │
│  <metric 2>                  │  <value>     │  <value>     │  <value> │
└──────────────────────────────┴──────────────┴──────────────┴──────────┘

GUARDRAIL METRICS:
┌──────────────────────────────┬──────────────┬──────────────┬──────────┐
│  Guardrail                   │  Control     │  Treatment   │  Status  │
├──────────────────────────────┼──────────────┼──────────────┼──────────┤
│  <latency p99>               │  <value>     │  <value>     │  OK | ALERT│
│  <error rate>                │  <value>     │  <value>     │  OK | ALERT│
│  <revenue per user>          │  <value>     │  <value>     │  OK | ALERT│
│  <bounce rate>               │  <value>     │  <value>     │  OK | ALERT│
└──────────────────────────────┴──────────────┴──────────────┴──────────┘

SEGMENT ANALYSIS (check for heterogeneous treatment effects):
┌──────────────────┬──────────────┬──────────────┬──────────────────────┐
│  Segment         │  Control     │  Treatment   │  Lift                │
├──────────────────┼──────────────┼──────────────┼──────────────────────┤
│  New users       │  <value>     │  <value>     │  <+/- X%>            │
│  Returning users │  <value>     │  <value>     │  <+/- X%>            │
│  Mobile          │  <value>     │  <value>     │  <+/- X%>            │
│  Desktop         │  <value>     │  <value>     │  <+/- X%>            │
│  Free plan       │  <value>     │  <value>     │  <+/- X%>            │
│  Paid plan       │  <value>     │  <value>     │  <+/- X%>            │
└──────────────────┴──────────────┴──────────────┴──────────────────────┘

  NOTE: Segment analysis is exploratory. Do NOT use segment results to
  override the overall decision unless pre-registered. Segment findings
  should generate hypotheses for follow-up experiments.

DECISION FRAMEWORK:
┌─────────────────────────────────────────────────────────────────────────┐
│  Stat sig + Positive + Guardrails OK           →  SHIP IT              │
│  Stat sig + Positive + Guardrail ALERT         →  INVESTIGATE guardrail│
│  Stat sig + Negative                           →  KILL IT              │
│  Not sig + Reached sample size                 →  INCONCLUSIVE — kill  │
│  Not sig + Under sample size                   →  KEEP RUNNING         │
│  Stat sig + Below MDE                          →  Likely not worth it  │
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
│  #  │  Experiment          │  Status  │  Surface │  Expected Impact  │
├─────┼──────────────────────┼──────────┼──────────┼───────────────────┤
│  1  │  <name>              │  LIVE    │  <page>  │  +<X%> <metric>   │
│  2  │  <name>              │  QUEUED  │  <page>  │  +<X%> <metric>   │
│  3  │  <name>              │  DESIGN  │  <page>  │  +<X%> <metric>   │
│  4  │  <name>              │  DONE    │  <page>  │  Shipped +<X%>    │
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

### Step 11: Platform-Specific Implementation

#### Statsig Implementation
```typescript
// experiments/statsig.ts
import Statsig from 'statsig-node';

await Statsig.initialize(process.env.STATSIG_SECRET_KEY!);

// Get experiment variant
function getExperiment(userId: string, experimentName: string) {
  const user = { userID: userId };
  const experiment = Statsig.getExperiment(user, experimentName);
  return {
    variant: experiment.getGroupName(),
    params: experiment.getValue(),
  };
}

// Log exposure is automatic with Statsig — it fires when getExperiment is called
// Log custom metric event
function logMetric(userId: string, eventName: string, value?: number, metadata?: Record<string, string>) {
  Statsig.logEvent({ userID: userId }, eventName, value, metadata);
}
```

#### GrowthBook Implementation
```typescript
// experiments/growthbook.ts
import { GrowthBook } from '@growthbook/growthbook-react';

const gb = new GrowthBook({
  apiHost: process.env.GROWTHBOOK_API_HOST,
  clientKey: process.env.GROWTHBOOK_CLIENT_KEY,
  enableDevMode: process.env.NODE_ENV === 'development',
  trackingCallback: (experiment, result) => {
    // Send exposure event to your analytics
    analytics.track('Experiment Exposure', {
      experiment_id: experiment.key,
      variant_id: result.key,
    });
  },
});

// Set user attributes for targeting
gb.setAttributes({
  id: userId,
  country: userCountry,
  plan: userPlan,
  deviceType: isMobile ? 'mobile' : 'desktop',
});

// Get variant (React)
function useFeatureValue(key: string, fallback: string): string {
  return gb.getFeatureValue(key, fallback);
}

// In component
function PricingPage() {
  const layout = gb.getFeatureValue('pricing-layout', 'grid');
  return layout === 'comparison' ? <ComparisonTable /> : <PricingGrid />;
}
```

#### Optimizely Implementation
```typescript
// experiments/optimizely.ts
import { createInstance } from '@optimizely/optimizely-sdk';

const optimizely = createInstance({
  sdkKey: process.env.OPTIMIZELY_SDK_KEY!,
});

await optimizely.onReady();

function getVariation(userId: string, experimentKey: string): string | null {
  const user = optimizely.createUserContext(userId);
  const decision = user.decide(experimentKey);

  return decision.variationKey;
}

// Track conversion event
function trackConversion(userId: string, eventKey: string, tags?: Record<string, unknown>) {
  const user = optimizely.createUserContext(userId);
  user.trackEvent(eventKey, tags);
}
```

### Step 12: Validation & Delivery
Validate the experiment setup before launching:

```
EXPERIMENT VALIDATION:
┌──────────────────────────────────────────────────────┬──────────────┐
│  Check                                               │  Status      │
├──────────────────────────────────────────────────────┼──────────────┤
│  Hypothesis is specific and falsifiable              │  PASS | FAIL │
│  Primary metric (OEC) is defined                     │  PASS | FAIL │
│  Guardrail metrics are defined                       │  PASS | FAIL │
│  Sample size calculated and achievable               │  PASS | FAIL │
│  Power >= 0.80 for target MDE                        │  PASS | FAIL │
│  Assignment is deterministic and sticky              │  PASS | FAIL │
│  Exposure logging fires on variant render            │  PASS | FAIL │
│  Exposure is deduplicated (one per user per session) │  PASS | FAIL │
│  Control experience is unchanged                     │  PASS | FAIL │
│  Treatment renders correctly on all devices          │  PASS | FAIL │
│  Mutual exclusion configured for conflicting tests   │  PASS | FAIL │
│  Ramp plan defined (canary -> full traffic)          │  PASS | FAIL │
│  Metric events fire correctly for all variants       │  PASS | FAIL │
│  SRM check will run on Day 1                         │  PASS | FAIL │
│  No peeking plan — analysis only at sample size      │  PASS | FAIL │
│  Rollback plan if guardrail alert fires              │  PASS | FAIL │
│  Feature flag kills treatment if needed              │  PASS | FAIL │
│  Duration accounts for full-week cycles              │  PASS | FAIL │
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

### Running a Multivariate Test
```
User: /godmode:experiment Test 3 different pricing page layouts

Experiment: Multivariate test design...

EXPERIMENT: pricing-layout-mvt
Variants:
  Control (33%): Current grid layout
  Test A (33%): Comparison table with feature checkmarks
  Test B (33%): Single recommended plan with upgrade path

Correction: Bonferroni — alpha adjusted to 0.05/3 = 0.017 per comparison
Sample size: 6,200 per variant (18,600 total)
Duration: 21 days (3 weeks for day-of-week coverage)

WARNING: 3 variants means 3x sample size. Consider testing the
strongest hypothesis first as a simple A/B test.
```

### Analyzing Experiment Results
```
User: /godmode:experiment --analyze checkout-single-page-v2

Experiment: Analyzing results...

RESULTS: checkout-single-page-v2
Duration: 14 days | Participants: 10,247 (Control: 5,131, Treatment: 5,116)
SRM check: PASS (p = 0.87)

Primary metric — Checkout completion rate:
  Control: 62.1% | Treatment: 66.8% | Lift: +7.6%
  p-value: 0.003 | 95% CI: [+2.4%, +12.8%] | Significant: YES

Guardrails: All OK (latency flat, errors flat, AOV +1.2%)

RECOMMENDATION: SHIP IT
  Lift is statistically significant and within MDE range.
  No guardrail degradation. Segment analysis shows consistent
  lift across mobile (+8.1%) and desktop (+7.2%).

Ship to 100% and schedule code cleanup for losing variant.
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

## Auto-Detection

On activation, automatically detect the experimentation context:

```
AUTO-DETECT SEQUENCE:
1. Scan for experimentation SDK imports (statsig, optimizely, growthbook, launchdarkly, posthog, vwo)
2. Detect analytics platform (Amplitude, Mixpanel, Segment, PostHog) from package.json / requirements.txt
3. Check for existing feature flag configuration files
4. Identify data warehouse connection (BigQuery, Snowflake, Redshift) from env vars or config
5. Scan for existing experiment configs or assignment logic
6. Detect framework (React, Next.js, Vue, etc.) for client-side assignment patterns
7. Check for existing A/B test infrastructure (hash-based assignment, exposure logging)
```

## Explicit Loop Protocol

When running multiple experiments or iterating on experiment design:

```
EXPERIMENT ITERATION LOOP:
current_iteration = 0
max_iterations = N  // number of experiments in backlog or design rounds

WHILE current_iteration < max_iterations AND NOT user_says_stop:
  1. SELECT next experiment from backlog (highest expected impact first)
  2. DESIGN experiment (hypothesis, metrics, sample size, assignment)
  3. VALIDATE design against checklist (Step 12)
  4. IF validation fails:
       FIX issues, re-validate (do NOT skip to next experiment)
  5. IMPLEMENT assignment + exposure logging + metrics
  6. RUN validation tests (SRM check template, metric event verification)
  7. REPORT design summary to user
  8. current_iteration += 1
  9. IF current_iteration < max_iterations:
       PROMPT user: "Proceed to next experiment or stop?"

ON COMPLETION:
  REPORT: "<N> experiments designed, <M> ready to launch, <K> need revision"
```

## Multi-Agent Dispatch

For teams running multiple experiments across surfaces, dispatch parallel agents:

```
PARALLEL EXPERIMENT AGENTS:
When designing experiments for multiple surfaces or platforms simultaneously:

Agent 1 (worktree: exp-frontend):
  - Design client-side experiments (UI changes, copy tests, layout tests)
  - Implement React/Vue hooks for variant assignment
  - Add exposure logging to components

Agent 2 (worktree: exp-backend):
  - Design server-side experiments (pricing, algorithms, ranking)
  - Implement server assignment logic and feature flags
  - Add metric event tracking to API endpoints

Agent 3 (worktree: exp-analysis):
  - Build sample size calculators and power analysis scripts
  - Create experiment results dashboards and SQL queries
  - Set up SRM detection and guardrail monitoring

MERGE STRATEGY: Each agent produces independent experiment configs.
  Merge sequentially — no conflicts expected (separate surfaces).
  Final validation: check mutual exclusion groups across all experiments.
```

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

## Anti-Patterns

- **Do NOT run experiments without a hypothesis.** "Let's just see what happens" is not an experiment. It is random change without learning.
- **Do NOT peek at results before reaching sample size.** Every peek inflates false positive rates. If you check daily on a 14-day test, your actual alpha is closer to 0.30 than 0.05.
- **Do NOT p-hack by testing many metrics.** Pre-register one primary metric. Apply corrections for secondary metrics. Do not go fishing for significance.
- **Do NOT ship inconclusive results.** If the experiment did not reach significance at the required sample size, the result is inconclusive. Kill it or redesign.
- **Do NOT ignore guardrail regressions.** A conversion lift that degrades performance, increases errors, or drops revenue per user is a net negative. Always check guardrails.
- **Do NOT run underpowered experiments.** If you need 10,000 users and you have 500/week, either find a higher-traffic surface, increase MDE, or do not run the experiment.
- **Do NOT use client-side assignment for server-rendered pages.** Users will see a flash of the wrong variant. Use server-side or edge assignment.
- **Do NOT skip the SRM check.** Sample Ratio Mismatch is the first thing to check. If your 50/50 split is actually 48/52, your randomization is broken and all results are invalid.
- **Do NOT let experiments run forever.** Set a hard deadline. If the experiment has not reached significance by the deadline, make a call and move on.
- **Do NOT accumulate experiment debt.** Every shipped experiment needs its losing variant code removed and feature flag deleted. Stale flags and dead code slow the team down.
