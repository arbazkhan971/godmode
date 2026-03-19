# /godmode:experiment

A/B testing and experimentation for product teams. Designs rigorous experiments with hypothesis-driven methodology, calculates sample sizes with power analysis, implements assignment via Optimizely, Statsig, GrowthBook, VWO, LaunchDarkly, or custom solutions, applies correct statistical methods (frequentist, Bayesian, sequential), and enforces guardrail metrics. Covers the full experiment lifecycle from ideation to cleanup.

## Usage

```
/godmode:experiment                                # Full experiment design and implementation
/godmode:experiment --platform statsig             # Force a specific experimentation platform
/godmode:experiment --design                       # Design experiment only (no implementation)
/godmode:experiment --analyze checkout-v2          # Analyze results for a running experiment
/godmode:experiment --power                        # Run power analysis and sample size calculation
/godmode:experiment --audit                        # Audit running experiments for SRM, peeking, missing guardrails
/godmode:experiment --bandit                       # Use multi-armed bandit instead of fixed A/B test
/godmode:experiment --sequential                   # Use sequential testing for valid early stopping
/godmode:experiment --bayesian                     # Use Bayesian analysis
/godmode:experiment --backlog                      # View and prioritize the experiment backlog
/godmode:experiment --cleanup checkout-v2          # Remove losing variant code and archive experiment
/godmode:experiment --multivariate                 # Design a multivariate test (3+ variants)
```

## What It Does

1. Discovers the business goal, baseline metric, and surface to test
2. Designs a rigorous experiment with falsifiable hypothesis, primary metric (OEC), and guardrails
3. Calculates sample size via power analysis (frequentist or Bayesian)
4. Selects experimentation platform (Statsig, Optimizely, GrowthBook, VWO, LaunchDarkly, PostHog, or homegrown)
5. Implements deterministic assignment (user-level hashing, session-level, or org-level)
6. Configures exposure logging with deduplication
7. Integrates with feature flags for safe ramp and rollback
8. Applies correct statistical methods (frequentist, Bayesian, sequential, CUPED variance reduction)
9. Enforces pitfall prevention (no peeking, SRM checks, multiple comparison corrections)
10. Analyzes results with segment breakdowns and guardrail monitoring
11. Manages experiment lifecycle from ideation through code cleanup

## Output
- Experiment config at `src/experiments/<experiment-name>.ts`
- Assignment logic at `src/experiments/assignment.ts`
- Exposure logging at `src/experiments/exposure.ts`
- Feature flag in experimentation platform
- Metrics definition at `docs/experiments/<experiment-name>.md`
- Commit: `"experiment: <name> — <N> variants, <primary metric>, <statistical method>"`

## Key Principles

1. **Hypothesis first** — every experiment starts with a falsifiable hypothesis before any code
2. **Sample size before launch** — calculate required sample size and duration upfront
3. **Never peek** — standard tests are only valid at the committed sample size; use sequential testing if you need early stopping
4. **One primary metric** — pick a single OEC; multiple primaries inflate false positive rates
5. **Guardrails are non-negotiable** — always monitor latency, error rate, and revenue alongside conversion
6. **SRM on Day 1** — check sample ratio mismatch immediately; broken randomization invalidates everything
7. **Ship or kill** — no compromises; inconclusive means kill, not "let's ship to 20%"
8. **Clean up after** — remove losing variant code, delete feature flags, archive the experiment

## Next Step
After experiment: `/godmode:analytics` to verify metric events, `/godmode:observe` to monitor guardrails, `/godmode:report` for results reports, or `/godmode:chart` to visualize results.

## Examples

```
/godmode:experiment                                # Full experiment workflow
/godmode:experiment --platform growthbook --design # Design-only with GrowthBook
/godmode:experiment --analyze pricing-test         # Analyze running experiment
/godmode:experiment --power                        # Sample size calculator
/godmode:experiment --bandit                       # Multi-armed bandit optimization
/godmode:experiment --audit                        # Audit all running experiments
```
