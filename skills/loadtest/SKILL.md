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
Target endpoints/operations:
  - <endpoint/operation> — <expected traffic pattern>
  - <endpoint/operation> — <expected traffic pattern>
  - <endpoint/operation> — <expected traffic pattern>

Current known metrics:
  Avg response time: <Xms | unknown>
  P95 response time: <Xms | unknown>
  P99 response time: <Xms | unknown>
  Error rate: <X% | unknown>
  Current RPS capacity: <N | unknown>
  Concurrent users: <N | unknown>

Target SLOs:
  Response time P95: <Xms>
  Response time P99: <Xms>
  Error rate: < <X>%
  Throughput: <N> requests/sec
  Availability: <X>%
```

### Step 2: Select Test Type
Choose the appropriate load test pattern:

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
      │      │  │
  400 │      │  │
      │      │  │
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
      │   │                                            │
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
const errorRate = new Rate('errors');
const responseTime = new Trend('response_time');

// Test configuration
export const options = {
  stages: [
    { duration: '2m', target: 50 },    // Ramp up
    { duration: '10m', target: 50 },   // Steady state
    { duration: '2m', target: 100 },   // Push higher
    { duration: '5m', target: 100 },   // Hold at peak
    { duration: '2m', target: 0 },     // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],  // P95 < 500ms, P99 < 1s
    errors: ['rate<0.01'],                             // Error rate < 1%
    http_req_failed: ['rate<0.01'],                    // HTTP failures < 1%
  },
};

// Test scenario
export default function () {
  // Endpoint 1: List (high traffic)
  const listRes = http.get('http://localhost:3000/api/items', {
    headers: { 'Authorization': `Bearer ${__ENV.API_TOKEN}` },
  });
  check(listRes, {
    'list status is 200': (r) => r.status === 200,
    'list response time < 500ms': (r) => r.timings.duration < 500,
  });
  errorRate.add(listRes.status !== 200);
  responseTime.add(listRes.timings.duration);

  sleep(1); // Think time between requests

  // Endpoint 2: Create (write operation)
  const createRes = http.post(
    'http://localhost:3000/api/items',
    JSON.stringify({ name: `item-${Date.now()}`, value: Math.random() }),
    { headers: { 'Content-Type': 'application/json' } }
  );
  check(createRes, {
    'create status is 201': (r) => r.status === 201,
    'create response time < 1000ms': (r) => r.timings.duration < 1000,
  });
  errorRate.add(createRes.status !== 201);

  sleep(Math.random() * 3 + 1); // Variable think time (1-4s)
}

// Summary output
export function handleSummary(data) {
  return {
    'loadtest/results/baseline-summary.json': JSON.stringify(data, null, 2),
  };
}
```

#### Artillery (YAML)
```yaml
# loadtest/baseline.artillery.yml
config:
  target: "http://localhost:3000"
  phases:
    - duration: 120      # 2 min ramp-up
      arrivalRate: 5
      rampTo: 50
      name: "Ramp up"
    - duration: 600      # 10 min steady
      arrivalRate: 50
      name: "Steady state"
    - duration: 120      # 2 min ramp-down
      arrivalRate: 50
      rampTo: 0
      name: "Ramp down"
  defaults:
    headers:
      Authorization: "Bearer {{ $processEnvironment.API_TOKEN }}"
  ensure:
    p95: 500
    p99: 1000
    maxErrorRate: 1

scenarios:
  - name: "Browse and create"
    weight: 70
    flow:
      - get:
          url: "/api/items"
          capture:
            - json: "$[0].id"
              as: "itemId"
      - think: 2
      - get:
          url: "/api/items/{{ itemId }}"
      - think: 1

  - name: "Create item"
    weight: 30
    flow:
      - post:
          url: "/api/items"
          json:
            name: "item-{{ $randomNumber(1000, 9999) }}"
            value: "{{ $randomNumber(1, 100) }}"
      - think: 3
```

#### Locust (Python)
```python
# loadtest/baseline_locust.py
from locust import HttpUser, task, between, events
import json
import time
import random

class APIUser(HttpUser):
    wait_time = between(1, 4)  # Think time between requests
    host = "http://localhost:3000"

    def on_start(self):
        """Called when a simulated user starts."""
        self.token = self.environment.parsed_options.api_token
        self.headers = {"Authorization": f"Bearer {self.token}"}

    @task(7)  # 70% of traffic
    def list_items(self):
        with self.client.get("/api/items", headers=self.headers,
                             catch_response=True) as response:
            if response.status_code != 200:
                response.failure(f"Got {response.status_code}")
            elif response.elapsed.total_seconds() > 0.5:
                response.failure(f"Too slow: {response.elapsed.total_seconds():.2f}s")

    @task(3)  # 30% of traffic
    def create_item(self):
        payload = {
            "name": f"item-{int(time.time())}",
            "value": random.randint(1, 100)
        }
        with self.client.post("/api/items", json=payload,
                              headers=self.headers,
                              catch_response=True) as response:
            if response.status_code != 201:
                response.failure(f"Got {response.status_code}")

    @task(1)  # 10% of traffic — heavy operation
    def search_items(self):
        query = random.choice(["widget", "gadget", "tool", "device"])
        self.client.get(f"/api/items/search?q={query}", headers=self.headers)
```

### Step 4: Establish Baseline
Run initial tests to establish performance baselines:

```
BASELINE RESULTS:
Date: <ISO date>
Environment: <dev | staging | prod-like>
System specs: <CPU, memory, disk, network>
Database: <type, size, connection pool>

┌─────────────────────┬──────────┬──────────┬──────────┬──────────┐
│ Metric              │ P50      │ P95      │ P99      │ Max      │
├─────────────────────┼──────────┼──────────┼──────────┼──────────┤
│ Response time (ms)  │ <val>    │ <val>    │ <val>    │ <val>    │
│ Throughput (rps)    │ <val>    │ —        │ —        │ <val>    │
│ Error rate (%)      │ <val>    │ —        │ —        │ <val>    │
│ CPU usage (%)       │ <val>    │ <val>    │ <val>    │ <val>    │
│ Memory usage (MB)   │ <val>    │ <val>    │ <val>    │ <val>    │
│ DB connections      │ <val>    │ <val>    │ <val>    │ <val>    │
│ Network I/O (MB/s)  │ <val>    │ <val>    │ <val>    │ <val>    │
└─────────────────────┴──────────┴──────────┴──────────┴──────────┘

Per-endpoint breakdown:
┌─────────────────────┬──────┬──────┬──────┬──────┬───────┐
│ Endpoint            │ RPS  │ P50  │ P95  │ P99  │ Errors│
├─────────────────────┼──────┼──────┼──────┼──────┼───────┤
│ GET /api/items      │ <N>  │ <ms> │ <ms> │ <ms> │ <N>%  │
│ POST /api/items     │ <N>  │ <ms> │ <ms> │ <ms> │ <N>%  │
│ GET /api/items/:id  │ <N>  │ <ms> │ <ms> │ <ms> │ <N>%  │
│ GET /api/search     │ <N>  │ <ms> │ <ms> │ <ms> │ <N>%  │
└─────────────────────┴──────┴──────┴──────┴──────┴───────┘
```

### Step 5: Bottleneck Analysis
Identify where performance breaks down:

```
BOTTLENECK ANALYSIS:
┌──────────────────────────────────────────────────────────────┐
│  Technique          │ Finding                                │
├──────────────────────────────────────────────────────────────┤
│  Response time      │ P99 spikes at <N> concurrent users     │
│  distribution       │ Bimodal distribution suggests caching  │
│                     │ miss vs hit pattern                    │
├──────────────────────────────────────────────────────────────┤
│  Resource           │ CPU saturates at <N>% under load       │
│  saturation         │ Memory grows linearly (possible leak)  │
│                     │ DB connections max out at <N>           │
├──────────────────────────────────────────────────────────────┤
│  Error analysis     │ Errors start at <N> RPS                │
│                     │ Error type: <timeout | 5xx | conn      │
│                     │ refused | OOM>                         │
├──────────────────────────────────────────────────────────────┤
│  Correlation        │ Response time correlates with <DB query│
│                     │ time | external API calls | GC pauses> │
├──────────────────────────────────────────────────────────────┤
│  Slowest            │ GET /api/search — full table scan      │
│  endpoints          │ POST /api/orders — N+1 query problem   │
│                     │ GET /api/reports — no pagination        │
└──────────────────────────────────────────────────────────────┘

ROOT CAUSES (ranked by impact):
1. <cause> — Affects <N>% of requests — Fix: <recommendation>
2. <cause> — Affects <N>% of requests — Fix: <recommendation>
3. <cause> — Affects <N>% of requests — Fix: <recommendation>
```

### Step 6: Statistical Significance
Validate that performance changes are real, not noise:

```
STATISTICAL ANALYSIS:
Comparison: <baseline vs optimized | version A vs version B>
Test runs: <N> (minimum 5 per variant for reliable results)
Confidence level: 95% (p < 0.05)

┌─────────────────────┬──────────┬──────────┬──────────┬────────┐
│ Metric              │ Before   │ After    │ Change   │ Sig?   │
├─────────────────────┼──────────┼──────────┼──────────┼────────┤
│ P50 response (ms)   │ <val>±<σ>│ <val>±<σ>│ <-X%>    │ YES/NO │
│ P95 response (ms)   │ <val>±<σ>│ <val>±<σ>│ <-X%>    │ YES/NO │
│ P99 response (ms)   │ <val>±<σ>│ <val>±<σ>│ <-X%>    │ YES/NO │
│ Throughput (rps)     │ <val>±<σ>│ <val>±<σ>│ <+X%>    │ YES/NO │
│ Error rate (%)       │ <val>±<σ>│ <val>±<σ>│ <-X%>    │ YES/NO │
│ CPU usage (%)        │ <val>±<σ>│ <val>±<σ>│ <-X%>    │ YES/NO │
│ Memory usage (MB)    │ <val>±<σ>│ <val>±<σ>│ <-X%>    │ YES/NO │
└─────────────────────┴──────────┴──────────┴──────────┴────────┘

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
┌──────────────────────────────────────────────────────────────┐
│  LOAD TEST REPORT — <target>                                 │
├──────────────────────────────────────────────────────────────┤
│  Test type: <load | stress | spike | soak>                   │
│  Duration: <X> minutes                                       │
│  Max users: <N>                                              │
│  Total requests: <N>                                         │
│                                                              │
│  PERFORMANCE:                                                │
│  P50: <X>ms  P95: <X>ms  P99: <X>ms                         │
│  Throughput: <N> rps (peak: <N> rps)                         │
│  Error rate: <X>%                                            │
│                                                              │
│  CAPACITY:                                                   │
│  Max stable load: <N> concurrent users / <N> rps             │
│  Breaking point: <N> concurrent users / <N> rps              │
│  Headroom: <X>% above current production traffic             │
│                                                              │
│  BOTTLENECKS:                                                │
│  1. <bottleneck> — <impact>                                  │
│  2. <bottleneck> — <impact>                                  │
│  3. <bottleneck> — <impact>                                  │
│                                                              │
│  SLO COMPLIANCE:                                             │
│  P95 < 500ms: <PASS/FAIL> (actual: <X>ms)                   │
│  P99 < 1000ms: <PASS/FAIL> (actual: <X>ms)                  │
│  Error rate < 1%: <PASS/FAIL> (actual: <X>%)                 │
│  Throughput > 100rps: <PASS/FAIL> (actual: <N>rps)           │
│                                                              │
│  Verdict: <MEETS SLOs | NEEDS OPTIMIZATION | CRITICAL>      │
└──────────────────────────────────────────────────────────────┘
```

### Step 8: Commit and Transition
1. Save test scripts to `loadtest/` directory
2. Save results to `loadtest/results/`
3. Save report as `docs/performance/<target>-loadtest-report.md`
4. Commit: `"loadtest: <target> — <verdict> (P95: <X>ms, <N>rps, <X>% errors)"`
5. If NEEDS OPTIMIZATION: "Bottlenecks identified. Run `/godmode:optimize` to address them, then re-test."
6. If MEETS SLOs: "Performance validated. Ready for `/godmode:ship`."

## Key Behaviors

1. **Baseline before optimizing.** You cannot improve what you haven't measured. Always establish a baseline first.
2. **Test in production-like environments.** Load tests against localhost with SQLite don't predict production behavior. Match hardware, data volume, and network topology.
3. **Think in percentiles, not averages.** Average response time of 100ms means nothing if P99 is 5 seconds. Always report P50, P95, P99.
4. **Statistical rigor required.** A single run proves nothing. Multiple runs with variance analysis are the minimum for valid conclusions.
5. **Correlate, don't guess.** When response time increases, check CPU, memory, database query time, and network I/O simultaneously. The bottleneck is where saturation occurs.
6. **Realistic scenarios.** Load tests should simulate real user behavior — mixed read/write operations, think time between requests, varied payloads.
7. **Automate for regression.** Performance tests should run in CI to catch regressions before they reach production.

## Example Usage

### Baseline load test
```
User: /godmode:loadtest Establish a performance baseline for our API

Loadtest: Analyzing your API endpoints...

Found 12 endpoints in src/routes/
Selecting top 5 by traffic weight:
  GET  /api/users        (40% of traffic)
  GET  /api/users/:id    (25% of traffic)
  POST /api/orders       (15% of traffic)
  GET  /api/products     (12% of traffic)
  GET  /api/search       (8% of traffic)

Generating k6 test script...
Saved: loadtest/baseline.k6.js

Running baseline (50 users, 10 minutes)...

BASELINE RESULTS:
P50: 45ms  P95: 180ms  P99: 420ms
Throughput: 340 rps
Error rate: 0.02%
Breaking point: ~500 concurrent users

Verdict: MEETS SLOs — healthy headroom above production traffic
```

### Stress test before launch
```
User: /godmode:loadtest Stress test — we're expecting 10x traffic for Black Friday

Loadtest: Configuring stress test for 10x surge...

Current baseline: 50 rps normal, target: 500 rps sustained
Test: Ramp from 50 to 600 rps over 30 minutes

STRESS TEST RESULTS:
Breaking point: 420 rps (16% below target)
Bottleneck: Database connection pool (max 20, needs 80+)
Secondary: Redis memory at 90% at 400 rps

CRITICAL: System cannot handle 10x traffic.
Recommendations:
1. Increase DB connection pool to 100
2. Scale Redis to 4GB
3. Add read replicas for GET-heavy endpoints

Run /godmode:optimize to address bottlenecks, then re-test.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Baseline load test with standard ramp pattern |
| `--stress` | Find the breaking point with increasing load |
| `--spike` | Test sudden traffic surge behavior |
| `--soak` | Long-duration endurance test (4+ hours) |
| `--tool <name>` | Generate scripts for specific tool (k6, artillery, locust, jmeter) |
| `--baseline` | Establish and save baseline metrics |
| `--compare <file>` | Compare results against a previous baseline |
| `--ci` | Generate CI-friendly test with pass/fail thresholds |
| `--endpoints <list>` | Test specific endpoints only |

## Anti-Patterns

- **Do NOT load test production without coordination.** Unannounced load tests against production are indistinguishable from DDoS attacks. Coordinate with the team.
- **Do NOT test without think time.** Real users pause between requests. Tests without think time simulate unrealistic scenarios and overestimate capacity.
- **Do NOT ignore tail latency.** If P50 is 50ms but P99 is 5s, 1 in 100 users has a terrible experience. Optimize the tail.
- **Do NOT compare single runs.** One run with P95=200ms and another with P95=180ms is noise, not improvement. Run multiple times and use statistics.
- **Do NOT test with empty databases.** Performance on 100 rows is meaningless. Test with production-scale data volumes.
- **Do NOT skip warm-up.** Cold starts, empty caches, and JIT compilation make the first minutes of a test unrepresentative. Include a warm-up phase and exclude it from metrics.
