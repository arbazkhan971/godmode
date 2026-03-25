---
name: loadtest
description: |
  Load testing and performance testing skill. k6,
  Artillery, Locust, JMeter. Stress, spike, soak
  testing. Statistical significance checking.
  Triggers on: /godmode:loadtest, "load test",
  "stress test", "performance test", "benchmark".
---

# Loadtest — Load Testing & Performance

## When to Activate
- User invokes `/godmode:loadtest`
- User says "load test", "stress test", "benchmark"
- User asks "can it handle the load?"
- Ship skill needs performance validation

## Workflow

### Step 1: Define Test Scope

```bash
# Detect existing test infrastructure
ls loadtest/ performance/ *.k6.js \
  *.artillery.yml *_locust.py 2>/dev/null

# Parse route files for endpoints
grep -rn "app\.\(get\|post\|put\|delete\)" \
  src/ routes/ --include="*.ts" 2>/dev/null | wc -l

# Check tool availability
k6 version 2>/dev/null || echo "k6: NOT INSTALLED"
artillery version 2>/dev/null
```

```
LOAD TEST SCOPE:
  Target: <API | web app | database | full stack>
  Endpoints: <list with expected RPS each>
  Current metrics: <P50, P95, P99 or unknown>
  Tool: <k6 | Artillery | Locust | JMeter>

IF no baseline exists: run baseline first
IF no tool installed: recommend k6 (lightweight)
IF testing production: coordinate with ops team
```

### Step 2: Select Test Type

```
| Type    | Purpose              | Pattern             |
|---------|----------------------|---------------------|
| Load    | Normal performance   | Ramp→steady→down    |
| Stress  | Breaking point       | Continuous increase  |
| Spike   | Sudden surge         | Normal→5x→normal    |
| Soak    | Memory leaks         | Moderate for hours   |

LOAD: ramp 2min, steady 10min, ramp-down 2min
STRESS: +50 users every 2min until failure
SPIKE: 5min baseline, instant 5x for 2min, recover
SOAK: 70-80% capacity for 4-8 hours minimum

THRESHOLDS:
  Stress stop: error rate > 10% OR P99 > 10s
  Spike recovery: metrics return to baseline
  Soak alert: any metric trending upward = leak
```

### Step 3: Generate Test Scripts

k6 (JavaScript), Artillery (YAML), or Locust (Python).
Include: custom metrics, thresholds, think time,
realistic payloads, auth tokens, ramp patterns.

```bash
# Run baseline test
k6 run --out json=results.json loadtest/baseline.k6.js

# Run with specific VUs and duration
k6 run --vus 100 --duration 10m loadtest/baseline.k6.js

# Artillery
artillery run loadtest/baseline.artillery.yml
```

### Step 4: Establish Baseline

```
BASELINE RESULTS:
  Date: <ISO>, Environment: <dev|staging|prod-like>
  System: <CPU, memory, DB type, pool size>

| Metric           | P50  | P95  | P99  | Max  |
|------------------|------|------|------|------|
| Response (ms)    | <val>| <val>| <val>| <val>|
| Throughput (rps)  | <val>| —    | —    | <val>|
| Error rate (%)    | <val>| —    | —    | <val>|
| CPU usage (%)     | <val>| <val>| <val>| <val>|
| Memory (MB)       | <val>| <val>| <val>| <val>|

THRESHOLDS:
  P95 target: < 500ms
  P99 target: < 1000ms
  Error rate: < 1%
  CV (coefficient of variation): < 10%
  IF CV > 15%: eliminate noise, increase duration
```

### Step 5: Bottleneck Analysis

```
ANALYSIS:
  Response distribution: bimodal = cache hit/miss
  CPU saturation: at <N>% under <N> users
  Memory trend: linear growth = possible leak
  DB connections: max out at <N>
  Error onset: starts at <N> RPS

IF CPU saturates first: optimize hot paths
IF memory grows linearly: check for leaks
IF DB connections max: increase pool or optimize
IF errors at low RPS: check application logic
```

### Step 6: Statistical Significance

```
COMPARISON RULES:
  Same environment, warm cache, 5+ runs minimum
  One change between variants, report variance
  Use percentiles (averages hide tail latency)

  Method: Welch's t-test (unequal variance)
  Confidence: 95% (p < 0.05)
  Effect size: Cohen's d (small/medium/large)
  Verdict: IMPROVEMENT | NO CHANGE | REGRESSION

THRESHOLDS:
  Minimum runs per variant: 5 (10+ preferred)
  IF bimodal distribution: split analysis by mode
  IF p >= 0.05: NO SIGNIFICANT CHANGE
```

### Step 7: Report

```
LOAD TEST REPORT:
  Type: <load|stress|spike|soak>
  Duration: <X>min, Max users: <N>
  P50: <X>ms  P95: <X>ms  P99: <X>ms
  Throughput: <N> rps (peak: <N>)
  Error rate: <X>%
  Max stable: <N> users / <N> rps
  Breaking point: <N> users
  Headroom: <X>x above production traffic
```

Commit: `"loadtest: <target> — P95: <X>ms,
  <N>rps, <X>% errors"`

## Key Behaviors
Never ask to continue. Loop autonomously until done.

1. **Baseline first.** Measure before optimizing.
2. **Production-like environments.** Match hardware.
3. **Percentiles, not averages.** P50, P95, P99.
4. **Statistical rigor.** Multiple runs with variance.
5. **Realistic scenarios.** Think time, mixed workloads.
6. **Automate for regression.** Run in CI.

## HARD RULES
1. Never load test production without coordination.
2. Never test without think time between requests.
3. Never compare single runs — 5+ minimum.
4. Never test with empty databases.
5. Never skip warm-up phase.
6. Never report averages without percentiles.
7. Always baseline before optimizing.
8. Always use production-scale data volumes.

## Auto-Detection
```
1. Endpoints: parse route files for paths/methods
2. Tests: loadtest/, *.k6.js, *.artillery.yml
3. Baselines: loadtest/results/
4. Infra: docker-compose, k8s manifests
```

## Output Format
Print: `Loadtest: {type} — P95: {p95}ms,
  P99: {p99}ms, {rps} rps, {err}% errors.
  Breaking: {N} users. Verdict: {verdict}.`

## TSV Logging
```
iteration	test_type	target_rps	actual_rps	p50_ms	p95_ms	p99_ms	error_rate	max_users	status
```

## Keep/Discard Discipline
```
KEEP if: statistically significant (p < 0.05,
  min 5 runs) AND no new error types
DISCARD if: no significant improvement
  OR regression in another metric
```

## Stop Conditions
```
STOP when ANY of:
  - All SLOs met with 2x headroom
  - Breaking point identified and documented
  - User requests stop
  - 5 consecutive no-improvement rounds
```

## Error Recovery
- Tool fails: verify installed, check target URL.
- All errors: check server running, auth tokens.
- Unrealistic numbers: verify think time.
- High variance (CV > 15%): increase duration.
- Crashes at high concurrency: `ulimit -n 65535`.

