---
name: loadtest
description: |
  Load testing and performance testing skill. Activates when user needs to stress-test systems, establish performance baselines, identify bottlenecks, or validate capacity. Generates test scenarios for k6, Artillery, Locust, and JMeter. Covers stress testing, spike testing, soak testing, and statistical significance checking. Triggers on: /godmode:loadtest, "load test", "stress test", "performance test", "benchmark", or when ship skill needs capacity validation.
---

# Loadtest — Load Testing & Performance Testing

## When to Activate
- User invokes `/godmode:loadtest`
- User says "load test", "stress test", "benchmark", "capacity planning"
- User asks "can it handle the load?" or "what's the breaking point?"
- Ship skill needs performance validation before deployment
- After optimize skill improves performance and needs verification
- User wants to establish performance baselines

## Workflow

### Step 1: Define Test Scope
Understand what to test and what success looks like:

```
LOAD TEST SCOPE:
Target system: <API | web app | database | message queue | full stack>
Target endpoints/operations (list each):
  - e.g., GET /api/users — 500 req/s steady state
  - e.g., POST /api/orders — 50 req/s with burst to 200

Current known metrics:
  Avg response time: <Xms | unknown>
  P95 response time: <Xms | unknown>
  P99 response time: <Xms | unknown>
  Error rate: <X% | unknown>
  Current RPS capacity: <N | unknown>
  Concurrent users: <N | unknown>

```
### Step 2: Select Test Type
Choose the correct load test pattern:

#### Load Test (Baseline)
```
PURPOSE: Establish normal operating performance
PATTERN: Ramp up to expected load, hold steady, ramp down

      Users
  100 │          ┌──────────────┐
      │         /│              │\
   50 │        / │              │ \
      │       /  │              │  \
    0 │──────/   │              │   \──────
      └──────┬───┬──────────────┬───┬──────
             2m   5m            15m  17m

Ramp-up: 2 minutes (gradual increase to target)
Steady: 10 minutes (sustained target load)
Ramp-down: 2 minutes (graceful decrease)
Target: Expected production traffic level
```

#### Stress Test (Breaking Point)
```
PURPOSE: Find the system's breaking point
PATTERN: Continuously increase load until failure

      Users
  500 │                              X ← Breaking point
      │                           /
  300 │                        /
      │                     /
  100 │                  /
      │               /
   50 │            /
      │         /
   10 │──────/
      └──────┬──┬──┬──┬──┬──┬──┬──┬──
             2m 4m 6m 8m 10 12 14 16

Step: Add 50 users every 2 minutes
Hold: 1 minute at each level
Stop: When error rate >10% or response time >10s
Record: Last stable level = max capacity
```

#### Spike Test (Sudden Surge)
```
PURPOSE: Test behavior under sudden traffic surges
PATTERN: Normal load, sudden spike, return to normal

      Users
  500 │      ┌──┐
  400 │      │  │
  100 │──────┘  └──────────
      │
   50 │
      │
    0 │
      └──────┬──┬──┬───────
             5m 7m 9m

Baseline: 5 minutes at normal load
Spike: Instant jump to 5x normal (2 minutes)
Recovery: Return to normal, observe recovery time
Measure: How long until metrics return to baseline
```

#### Soak Test (Endurance)
```
PURPOSE: Find memory leaks, connection exhaustion, gradual degradation
PATTERN: Moderate load sustained for hours

      Users
  100 │   ┌────────────────────────────────────────────┐
   50 │   │                                            │
      │  /│                                            │\
    0 │─/ │                                            │ \─
      └───┬────────────────────────────────────────────┬──
          5m                   4-8 hours               end

Duration: 4-8 hours minimum
Load: 70-80% of known capacity
Monitor: Memory, CPU, disk, connection count over time
Alert: Any metric that trends upward continuously = leak
```

### Step 3: Generate Test Scripts
Generate test scripts for the user's preferred tool:

#### k6 (JavaScript)
```javascript
// loadtest/baseline.k6.js
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
```

#### Artillery (YAML)
```yaml
# loadtest/baseline.artillery.yml
config:
  target: "http://localhost:3000"
  phases:
    - duration: 120      # 2 min ramp-up
      arrivalRate: 5
```

#### Locust (Python)
```python
# loadtest/baseline_locust.py
from locust import HttpUser, task, between, events
import json
import time
import random

```

### Step 4: Establish Baseline
Run initial tests to establish performance baselines:

```
BASELINE RESULTS:
Date: <ISO date>
Environment: <dev | staging | prod-like>
System specs: <CPU, memory, disk, network>
Database: <type, size, connection pool>

| Metric | P50 | P95 | P99 | Max |
|--|--|--|--|--|
| Response time (ms) | <val> | <val> | <val> | <val> |
| Throughput (rps) | <val> | — | — | <val> |
| Error rate (%) | <val> | — | — | <val> |
| CPU usage (%) | <val> | <val> | <val> | <val> |
| Memory usage (MB) | <val> | <val> | <val> | <val> |
| DB connections | <val> | <val> | <val> | <val> |
```
### Step 5: Bottleneck Analysis
Identify where performance breaks down:

```
BOTTLENECK ANALYSIS:
| Technique | Finding |
|--|--|
| Response time | P99 spikes at <N> concurrent users |
| distribution | Bimodal distribution suggests caching |
|  | miss vs hit pattern |
| Resource | CPU saturates at <N>% under load |
| saturation | Memory grows linearly (possible leak) |
|  | DB connections max out at <N> |
| Error analysis | Errors start at <N> RPS |
|  | Error type: <timeout | 5xx | conn |
|  | refused | OOM> |
```
### Step 6: Statistical Significance
Validate that performance changes are real, not noise:

```
STATISTICAL ANALYSIS:
Comparison: <baseline vs optimized | version A vs version B>
Test runs: <N> (minimum 5 per variant for reliable results)
Confidence level: 95% (p < 0.05)

| Metric | Before | After | Change | Sig? |
|--|--|--|--|--|
| P50 response (ms) | <val>±<σ> | <val>±<σ> | <-X%> | YES/NO |
| P95 response (ms) | <val>±<σ> | <val>±<σ> | <-X%> | YES/NO |
| P99 response (ms) | <val>±<σ> | <val>±<σ> | <-X%> | YES/NO |
| Throughput (rps) | <val>±<σ> | <val>±<σ> | <+X%> | YES/NO |
| Error rate (%) | <val>±<σ> | <val>±<σ> | <-X%> | YES/NO |
| CPU usage (%) | <val>±<σ> | <val>±<σ> | <-X%> | YES/NO |
| Memory usage (MB) | <val>±<σ> | <val>±<σ> | <-X%> | YES/NO |

Statistical method: Welch's t-test (unequal variance assumed)
Effect size: Cohen's d = <value> (<small | medium | large>)
Verdict: <IMPROVEMENT CONFIRMED | NO SIGNIFICANT CHANGE | REGRESSION DETECTED>
```
#### Significance Rules
```
RULES FOR VALID COMPARISON:
1. Same environment — Same hardware, same database size, same network
2. Warm cache — Run a warm-up phase before measuring
3. Multiple runs — Minimum 5 runs per variant (10+ preferred)
4. Controlled variables — Only ONE change between variants
5. Report variance — Mean without standard deviation is meaningless
6. Use percentiles — Averages hide tail latency problems
7. Check distribution — If bimodal, split analysis by mode
```

### Step 7: Generate Performance Report

```
  LOAD TEST REPORT — <target>
  Test type: <load | stress | spike | soak>
  Duration: <X> minutes
  Max users: <N>
  Total requests: <N>
  PERFORMANCE:
  P50: <X>ms  P95: <X>ms  P99: <X>ms
  Throughput: <N> rps (peak: <N> rps)
  Error rate: <X>%
  CAPACITY:
  Max stable load: <N> concurrent users / <N> rps
```
### Step 8: Commit and Transition
1. Save test scripts to `loadtest/` directory
2. Save results to `loadtest/results/`
3. Save report as `docs/performance/<target>-loadtest-report.md`
4. Commit: `"loadtest: <target> — <verdict> (P95: <X>ms, <N>rps, <X>% errors)"`
5. If NEEDS OPTIMIZATION: "Bottlenecks identified. Run `/godmode:optimize` to address them, then re-test."
6. If MEETS SLOs: "Performance validated. Ready for `/godmode:ship`."

## Key Behaviors
1. **Baseline first.** Measure before optimizing.
2. **Production-like environments.** Match hardware, data volume, network.
3. **Percentiles, not averages.** Report P50, P95, P99.
4. **Statistical rigor.** Multiple runs with variance analysis.
5. **Correlate, don't guess.** Check CPU, memory, DB, network simultaneously.
6. **Realistic scenarios.** Mixed read/write, think time, varied payloads.
7. **Automate for regression.** Run in CI to catch regressions.

## HARD RULES
1. NEVER load test production without coordination — looks like DDoS.
2. NEVER test without think time — overestimates capacity.
3. NEVER compare single runs — run 5+ times minimum.
4. NEVER test with empty databases — use production-scale data.
5. NEVER skip warm-up — cold starts make first minutes unrepresentative.
6. NEVER report averages without percentiles — always P50, P95, P99.
7. ALWAYS baseline before optimizing. Production-like environments. Mixed workloads.

## Auto-Detection
```
1. Endpoints: parse route files (routes/*.ts, app.py, main.go), extract paths/methods
2. Existing tests: loadtest/, performance/, *.k6.js, *.artillery.yml, *_locust.py
3. Baselines: loadtest/results/, performance/baselines/
4. Infra: docker-compose.yml, k8s manifests, terraform
```

## Iterative Load Test Protocol
Load testing follows an iterative cycle — baseline, stress, identify, optimize, re-test:
```
current_phase = "baseline"
iteration = 0

WHILE current_phase != "complete":
  IF current_phase == "baseline":
    1. RUN baseline load test (expected traffic, 10 min steady)
    2. RECORD metrics: P50, P95, P99, throughput, error rate
    3. SAVE baseline: loadtest/results/baseline-{date}.json
    4. current_phase = "stress"

  IF current_phase == "stress":
    1. RUN stress test (ramp to 2x, 5x, 10x baseline)
    2. IDENTIFY breaking point (error rate > 10% or P99 > 10s)
    3. RECORD: max stable load, breaking point, bottleneck
    4. current_phase = "analyze"
```

## Keep/Discard Discipline
```
KEEP if: statistically significant improvement (p < 0.05, min 5 runs) AND no new error types
DISCARD if: no significant improvement OR regression in another metric
Never declare improvement from a single run — variance matters.
```

## Autonomy
Never ask to continue. Loop autonomously. On failure: git reset --hard HEAD~1.

## Stop Conditions
```
STOP when ANY of these are true:
  - All SLOs met with 2x headroom above current production traffic
  - Breaking point identified and documented
  - User explicitly requests stop
  - Optimization plateau reached (5 consecutive no-improvement rounds)

DO NOT STOP because:
  - One endpoint has a slow P99 (report it but continue testing others)
  - The load test tool reports warnings (investigate but do not abandon the test)
```

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Baseline load test with standard ramp pattern |
| `--stress` | Find the breaking point with increasing load |
| `--spike` | Test sudden traffic surge behavior |

## Output Format
Print on completion: `Loadtest: {test_type} — P95: {p95}ms, P99: {p99}ms, throughput: {rps} rps, errors: {error_rate}%. Breaking point: {breaking_point} users. Verdict: {verdict}.`

## TSV Logging
Log every load test run to `.godmode/loadtest-results.tsv`:
```
iteration	test_type	target_rps	actual_rps	p50_ms	p95_ms	p99_ms	error_rate	max_users	status
```

## Success Criteria
- Baseline: 5+ runs, CV < 10%. P95 < 500ms, P99 < 1000ms, errors < 1%.
- Breaking point identified. 2x headroom above production traffic.
- Bottlenecks ranked by impact. Results saved to `loadtest/results/` with timestamps.

## Error Recovery
- **Tool fails to start**: Verify installed (`k6 version`). Check target URL reachable.
- **All requests error**: Check server running, auth tokens valid, firewall rules.
- **Unrealistic numbers**: Verify think time. Check load generator not bottleneck.
- **High variance (CV > 15%)**: Eliminate noise, increase duration, increase warm-up.
- **Crashes at high concurrency**: `ulimit -n 65535`. Check connection pools.
- **Cannot reproduce prod**: Match data volume, hardware, network latency.
