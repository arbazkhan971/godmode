---
name: experiment
description: |
  A/B testing, experimentation, statistical analysis.
  Triggers on: /godmode:experiment, "A/B test",
  "split test", "statistical significance",
  "Optimizely", "Statsig", "GrowthBook".
---

# Experiment — A/B Testing & Experimentation

## Activate When
- User invokes `/godmode:experiment`
- User says "A/B test", "split test", "experiment"
- User says "statistical significance", "sample size"
- User says "Statsig", "Optimizely", "GrowthBook"

## Workflow

### Step 1: Experiment Discovery

```bash
# Detect experimentation SDK
grep -l "statsig\|optimizely\|growthbook\|launchdarkly" \
  package.json pyproject.toml 2>/dev/null

# Check for existing experiment configs
find . -name "*experiment*" -o -name "*ab_test*" \
  | grep -v node_modules | head -10
```

```
EXPERIMENT DISCOVERY:
Baseline metric: <name> = <current value>
Traffic: <daily users hitting the surface>
Platform: none | Statsig | Optimizely | GrowthBook
Risk: low (revenue) | medium (growth) | high (minor UX)

IF no platform: recommend Statsig (best free tier)
IF baseline unknown: measure for 7 days first
IF traffic < 1000/day: experiment may take months
```

### Step 2: Experiment Design

```
EXPERIMENT DESIGN:
Name: <experiment-slug>
Hypothesis: If we <change>, then <metric> will
  <improve> by <magnitude> because <reasoning>.

METRICS:
| Type       | Metric      | Baseline | Target |
|-----------|-------------|----------|--------|
| Primary   | <OEC>       | <val>    | +<X>%  |
| Guardrail | latency p95 | <val>    | < +10% |
| Guardrail | error rate  | <val>    | < +0.1%|
| Guardrail | revenue     | <val>    | > -2%  |
| Secondary | <metric>    | <val>    | +<X>%  |
```

### Step 3: Sample Size & Power Analysis

```
POWER ANALYSIS:
  Alpha: 0.05 (5% false positive rate)
  Power: 0.80 (80% detection probability)
  Baseline rate: <current conversion — e.g., 3.2%>
  MDE: <smallest meaningful change — e.g., 10% rel>
  Variants: <2 for A/B, N for multivariate>

THRESHOLDS:
  Minimum power: 0.80
  Maximum alpha: 0.05
  Minimum MDE: what matters to the business
  Minimum duration: 7 days (avoid day-of-week bias)
  IF sample size > 30 days of traffic: increase MDE
    or increase traffic allocation
```

### Step 4: Assignment Strategy

```
DETERMINISTIC HASHING (recommended):
  hash(user_id + experiment_id) % 10000
  0-4999 = Control, 5000-9999 = Treatment

RULES:
  Same user always gets same variant
  No storage required — computed from hash
  Works across client and server
  Increasing % adds users, never flips existing ones
```

### Step 5: Statistical Methods

```
DECISION RULES (frequentist):
  SHIP: p < 0.05 AND effect >= MDE
    AND no guardrail regressions
  KILL: p < 0.05 AND effect negative
  WAIT: p >= 0.05 AND sample not reached
  INCONCLUSIVE: sample reached AND p >= 0.05

WHEN to use Bayesian:
  Need probability of being better (not just p-value)
  Want continuous monitoring without peeking penalty
  Business prefers "95% chance B is better" language
```

### Step 6: Results Analysis

```
EXPERIMENT RESULTS:
Duration: <start> — <end>
Participants: <N> (Control: <N>, Treatment: <N>)

SRM CHECK:
  Expected: 50/50, Actual: <actual>/<actual>
  Chi-squared p: <value>
  IF p < 0.01: SRM detected — STOP, do not interpret

PRIMARY METRIC:
| Variant   | Value | vs Control | p-value | Sig? |
|-----------|-------|-----------|---------|------|
| Control   | <val> | —         | —       | —    |
| Treatment | <val> | +<X>%    | <p>     | Y/N  |

GUARDRAILS:
  latency p95: <PASS|FAIL> (< +10% threshold)
  error rate: <PASS|FAIL> (< +0.1% threshold)
  revenue: <PASS|FAIL> (> -2% threshold)
```

### Step 7: Lifecycle Management

```
LIFECYCLE:
  IDEA → DESIGN → REVIEW → QUEUED → RAMPING →
  LIVE → ANALYZING → DECIDED → CLEANUP

RAMP SCHEDULE:
  5% → 25% → 50% → 100% (hold 7+ days each)

CLEANUP (within 2 weeks of decision):
  Remove losing variant code
  Delete feature flag
  Archive experiment config
```

### Step 8: Validation & Delivery

```
PRE-LAUNCH CHECKLIST:
| Check                             | Status |
|-----------------------------------|--------|
| Hypothesis specific & falsifiable | ?      |
| Primary metric (OEC) defined      | ?      |
| Guardrails defined                | ?      |
| Sample size achievable            | ?      |
| Power >= 0.80                     | ?      |
| Assignment deterministic & sticky | ?      |
| Exposure logged once per user     | ?      |
| Control unchanged                 | ?      |
| Mutual exclusion for conflicts    | ?      |
```

Commit: `"experiment: <name> — <N> variants,
  <metric>, <statistical method>"`

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Hypothesis before code.**
2. **Calculate sample size first.**
3. **Never peek** at frequentist results early.
4. **One primary metric** (OEC). Rest are guardrails.
5. **Check SRM on Day 1.** Broken randomization
   invalidates all results.
6. **Ship or kill.** Never "ship to 20% and see."
7. **Clean up** losing variant code within 2 weeks.

## HARD RULES

1. Never skip sample size calculation.
2. Never launch without written hypothesis.
3. Never use more than ONE primary metric.
4. Never peek at frequentist results before sample.
5. Always define guardrails before launch.
6. Always check SRM on Day 1.
7. Always run full-week multiples (7, 14, 21 days).
8. Never ship inconclusive at partial traffic.
9. Always clean up flags after conclusion.
10. Always deduplicate exposure logging.

## Auto-Detection
```
1. SDK: statsig, optimizely, growthbook, launchdarkly
2. Analytics: Amplitude, Mixpanel, Segment
3. Existing: experiment configs, assignment logic
```

## Output Format
Print: `Experiment: {name} — {status}.
  Split: {control}%/{treatment}%.
  p-value: {p}. Lift: {lift}%. Verdict: {verdict}.`

## TSV Logging
```
timestamp	experiment	metric	p_value	lift	status
```

## Keep/Discard Discipline
```
KEEP if: validated, implemented, metrics confirmed
DISCARD if: failed validation OR tests broke
  OR guardrails tripped
```

## Stop Conditions
```
STOP when ALL of:
  - All 9 pre-launch checks pass
  - Exposure logging fires once per user
  - Sample size documented with MDE, alpha, power
  - Guardrails defined and monitored
  - Cleanup plan scheduled
```

<!-- tier-3 -->

## Error Recovery
- SRM detected: halt, check assignment + bot filtering.
- Flag leaking: verify deterministic eval, check cache.
- Sample not reached: extend or use sequential testing.
- Guardrail breached: kill treatment immediately.

