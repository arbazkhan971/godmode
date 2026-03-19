# /godmode:chaos

Chaos engineering and resilience testing. Designs controlled failure injection experiments, validates circuit breakers, plans game days, and generates resilience scorecards.

## Usage

```
/godmode:chaos                          # Full chaos assessment — map failures, design experiments
/godmode:chaos --experiment <name>      # Run a specific pre-designed experiment
/godmode:chaos --network                # Network failure experiments only
/godmode:chaos --process                # Process/compute failure experiments only
/godmode:chaos --storage                # Storage/database failure experiments only
/godmode:chaos --deps                   # External dependency failure experiments only
/godmode:chaos --circuit-breaker        # Circuit breaker validation only
/godmode:chaos --gameday                # Generate a game day plan
/godmode:chaos --scorecard              # Generate resilience scorecard from past experiments
/godmode:chaos --production             # Production experiments (extra safety checks)
```

## What It Does

1. Defines steady state metrics (success rate, latency, error rate, resource usage)
2. Maps failure domains (network, compute, storage, dependencies, data)
3. Designs chaos experiments with hypothesis, injection method, and rollback
4. Tests circuit breaker state transitions (CLOSED, OPEN, HALF-OPEN)
5. Plans game days with timeline, safety protocols, and escalation paths
6. Generates resilience scorecard grading each failure domain (A/B/C/F)

## Output
- Experiment definitions at `docs/chaos/<system>-experiments.md`
- Game day plan at `docs/chaos/<system>-gameday-plan.md`
- Resilience scorecard at `docs/chaos/<system>-resilience-report.md`
- Commit: `"chaos: <system> — <N> experiments, resilience: <grade>"`
- Overall grade: RESILIENT / ADEQUATE / FRAGILE

## Next Step
If FRAGILE: `/godmode:fix` to address resilience gaps, then re-test.
If RESILIENT: `/godmode:ship` to deploy with confidence.

## Examples

```
/godmode:chaos                          # Full resilience assessment
/godmode:chaos --network                # Test network failure handling
/godmode:chaos --circuit-breaker        # Validate circuit breaker behavior
/godmode:chaos --gameday                # Plan a team game day exercise
/godmode:chaos --deps                   # Test external dependency failures
```
