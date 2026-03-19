# /godmode:loadtest

Load testing and performance testing. Generates test scenarios for k6, Artillery, Locust, and JMeter. Establishes baselines, finds bottlenecks, and validates capacity through stress, spike, and soak testing.

## Usage

```
/godmode:loadtest                       # Baseline load test with standard ramp pattern
/godmode:loadtest --stress              # Find the breaking point with increasing load
/godmode:loadtest --spike               # Test sudden traffic surge behavior
/godmode:loadtest --soak                # Long-duration endurance test (4+ hours)
/godmode:loadtest --tool <name>         # Generate scripts for specific tool (k6, artillery, locust, jmeter)
/godmode:loadtest --baseline            # Establish and save baseline metrics
/godmode:loadtest --compare <file>      # Compare results against a previous baseline
/godmode:loadtest --ci                  # Generate CI-friendly test with pass/fail thresholds
/godmode:loadtest --endpoints <list>    # Test specific endpoints only
```

## What It Does

1. Analyzes API endpoints and traffic patterns to design realistic test scenarios
2. Generates load test scripts for your preferred tool (k6, Artillery, Locust, JMeter)
3. Runs baseline tests to establish performance metrics (P50, P95, P99, throughput, error rate)
4. Finds breaking points through stress testing with increasing load
5. Identifies bottlenecks through correlation analysis (CPU, memory, DB, network)
6. Validates results with statistical significance checking (Welch's t-test, Cohen's d)

## Output
- Test scripts in `loadtest/` directory
- Results in `loadtest/results/`
- Performance report at `docs/performance/<target>-loadtest-report.md`
- Commit: `"loadtest: <target> — <verdict> (P95: <X>ms, <N>rps, <X>% errors)"`
- Verdict: MEETS SLOs / NEEDS OPTIMIZATION / CRITICAL

## Next Step
If NEEDS OPTIMIZATION: `/godmode:optimize` to address bottlenecks, then re-test.
If MEETS SLOs: `/godmode:ship` to deploy with confidence.

## Examples

```
/godmode:loadtest                       # Baseline performance test
/godmode:loadtest --stress              # Find the breaking point
/godmode:loadtest --spike               # Simulate Black Friday traffic surge
/godmode:loadtest --soak                # Run 8-hour endurance test
/godmode:loadtest --tool k6             # Generate k6 test scripts
/godmode:loadtest --compare baseline.json  # Compare against previous run
```
