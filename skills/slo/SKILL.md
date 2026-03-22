---
name: slo
description: SLOs, SLIs, error budgets, reliability targets, service level management. Use when user mentions SLO, SLI, SLA, error budget, reliability target, uptime, availability target, nine nines.
---

# SLO -- Service Level Objectives & Error Budget Management

## When to Activate
- User invokes `/godmode:slo`
- User says "SLO", "SLI", "SLA", "error budget"
- User says "reliability target", "uptime", "availability target"
- User says "nine nines", "nines", "burn rate"
- User says "service level", "error budget policy", "budget exhaustion"
- User says "release gating", "SLO dashboard", "SLO review"
- When defining reliability contracts for a new or existing service
- When `/godmode:observe` identifies services without defined SLOs
- When `/godmode:incident` reveals that SLO violations went undetected

## Workflow

### Step 1: Service Context & Stakeholder Alignment
Understand what the service does and who cares about its reliability:

```
SERVICE CONTEXT:
Service: <name and purpose>
Type: User-facing API | Internal API | Data pipeline | Batch job | Streaming
Users: <who depends on this service, internal/external>
Business Criticality: Tier 1 (revenue) | Tier 2 (important) | Tier 3 (internal)
Current Reliability: <observed uptime, error rate, latency if known>
Current Monitoring: <what metrics are collected today>
Existing SLOs: <any existing targets, formal or informal>
Dependencies: <critical upstream and downstream services>
Traffic Pattern: <steady | diurnal | spiky | seasonal>
Request Volume: <approximate requests per second or per day>
```

If the user has not provided context, ask: "What does this service do and who are its users? The answers determine which SLIs matter and how aggressive the SLO targets should be."

### Step 2: SLA vs SLO vs SLI -- Establish the Hierarchy
Clarify the three levels before defining anything:

```
SERVICE LEVEL HIERARCHY:
+---------------------------------------------------------------+
|  SLA (Service Level Agreement)                                  |
|    External, contractual promise to customers.                  |
|    Breach has legal or financial consequences.                  |
|    Example: "99.5% uptime per calendar month or credit issued." |
|                                                                 |
|  SLO (Service Level Objective)                                  |
|    Internal target, stricter than the SLA.                      |
|    Drives engineering priorities via error budgets.              |
|    Example: "99.9% availability over a rolling 30-day window."  |
|                                                                 |
|  SLI (Service Level Indicator)                                  |
|    The measured metric that evaluates the SLO.                  |
|    Must be objective, measurable, and tied to user experience.  |
|    Example: "successful requests / total requests at the LB."   |
+---------------------------------------------------------------+

RELATIONSHIP:
  SLI (measurement) feeds -> SLO (target) which is stricter than -> SLA (contract)

CRITICAL RULE:
  SLO must always be stricter than SLA.
  If SLA = 99.5%, SLO should be >= 99.9%.
  The gap between SLO and SLA is your safety margin.
  If SLO = SLA, you will breach your contract before you notice.
```

### Step 3: SLI Selection
Choose the right indicators based on service type:

```
SLI SELECTION BY SERVICE TYPE:

USER-FACING API / WEB SERVICE:
+--------------------------------------------------------------+
|  SLI Category  | Definition                | Measurement       |
+--------------------------------------------------------------+
|  Availability  | Successful requests /     | HTTP 5xx excluded, |
|                | total requests            | measured at LB     |
|  Latency       | Requests below threshold  | p50, p99 at server |
|                | / total requests          | or LB (not client) |
|  Error rate    | Failed requests /         | 5xx + timeouts /   |
|                | total requests            | total requests     |
+--------------------------------------------------------------+

DATA PIPELINE / BATCH JOB:
+--------------------------------------------------------------+
|  SLI Category  | Definition                | Measurement       |
+--------------------------------------------------------------+
|  Freshness     | Data updated within       | Lag between event  |
|                | threshold / total         | time and processed |
|  Correctness   | Correct outputs /         | Validation checks  |
|                | total outputs             | on pipeline output |
|  Throughput    | Records processed /       | Measured per window|
|                | records expected          | (hour, day)        |
+--------------------------------------------------------------+

STORAGE SYSTEM:
+--------------------------------------------------------------+
|  SLI Category  | Definition                | Measurement       |
+--------------------------------------------------------------+
|  Durability    | Data retained /           | Measured over      |
|                | data stored               | quarter or year    |
|  Availability  | Successful read+write /   | Measured at client |
|                | total operations          | library level      |
|  Latency       | Operations below          | p50, p99, p999    |
|                | threshold / total         |                    |
+--------------------------------------------------------------+

STREAMING SYSTEM:
+--------------------------------------------------------------+
|  SLI Category  | Definition                | Measurement       |
+--------------------------------------------------------------+
|  Freshness     | End-to-end latency <      | Measured at        |
|                | threshold / total msgs    | consumer side      |
|  Availability  | Messages delivered /      | Produced vs        |
|                | messages produced         | consumed count     |
|  Throughput    | Messages processed /sec   | Consumer lag       |
|                | vs expected rate          | monitoring         |
+--------------------------------------------------------------+

SLI MEASUREMENT PRINCIPLES:
1. Measure closer to the user, not closer to the server
   - Load balancer > application > database
2. Count ALL requests, including shed load and circuit breaker rejections
3. Exclude client errors (4xx) from availability SLI -- they are not your fault
4. Rate-limited requests (429): document your choice and be consistent
5. Use proportional SLIs (good events / total events), not averages
```

#### What Counts as an Error
```
ERROR CLASSIFICATION:
+--------------------------------------------------------------+
|  Response           | Counts as Error? | Rationale             |
+--------------------------------------------------------------+
|  HTTP 5xx           | YES              | Server failure         |
|  Timeout            | YES              | Server too slow        |
|  Circuit breaker    | YES              | Shed load = user hurt  |
|  HTTP 4xx           | NO               | Client mistake         |
|  HTTP 429 (rate     | DOCUMENT CHOICE  | Debatable: user is     |
|    limited)         |                  | blocked either way     |
|  Planned downtime   | DOCUMENT CHOICE  | Excluded if SLA says so|
|  Dependency failure  | YES             | User does not care why |
+--------------------------------------------------------------+
```

### Step 4: SLO Definition -- Target + Window
Set concrete SLO targets for each SLI:

```
SLO DEFINITION TABLE:
+--------------------------------------------------------------+
|  SLI              | SLO Target | Window      | SLA (if any)   |
+--------------------------------------------------------------+
|  Availability     | <target>%  | <window>    | <target>%      |
|  Latency (p50)    | < <N>ms    | <window>    | < <N>ms        |
|  Latency (p99)    | < <N>ms    | <window>    | < <N>ms        |
|  Error rate       | < <N>%     | <window>    | < <N>%         |
|  Freshness        | < <N>s     | <window>    | < <N>s         |
|  Throughput       | > <N> RPS  | <window>    | > <N> RPS      |
+--------------------------------------------------------------+

SLO WINDOW OPTIONS:
+--------------------------------------------------------------+
|  Window Type       | When to Use              | Trade-offs     |
+--------------------------------------------------------------+
|  Rolling 30 days   | Default. Smooth. Best    | Slower to reset|
|                    | for most services.       | after incidents |
|  Rolling 7 days    | Fast feedback. Good for  | More volatile,  |
|                    | rapid iteration.         | small sample    |
|  Calendar month    | Aligned with billing and | Spiky: budget   |
|                    | business reporting.      | resets on 1st   |
|  Rolling 90 days   | Strategic services with  | Very slow to    |
|                    | low traffic.             | recover budget  |
+--------------------------------------------------------------+

CHOOSING THE RIGHT TARGET:
+--------------------------------------------------------------+
|  Availability | Downtime/month | Use Case                      |
+--------------------------------------------------------------+
|  99%          | 7.3 hours      | Internal tools, dev envs      |
|  99.5%        | 3.6 hours      | Non-critical internal services|
|  99.9%        | 43.2 minutes   | Most production services      |
|  99.95%       | 21.6 minutes   | Important user-facing services|
|  99.99%       | 4.3 minutes    | Revenue-critical, payments    |
|  99.999%      | 26 seconds     | Infrastructure (DNS, auth)    |
+--------------------------------------------------------------+

RULES FOR SETTING TARGETS:
1. Start with current measured reliability minus a small margin
   - If currently at 99.95%, set SLO to 99.9% (achievable)
2. Never set SLO = 100% -- it is impossible and means zero budget
3. Set SLO stricter than SLA -- the gap is your safety margin
4. Different SLIs can have different windows
5. Start conservative, tighten later as you learn
```

### Step 5: Error Budget Calculation & Tracking
Calculate the error budget and establish tracking:

```
ERROR BUDGET FORMULA:
  Error budget = 1 - SLO target

  EXAMPLE:
  SLO: 99.9% availability over 30 days
  Total minutes in 30 days: 43,200
  Error budget: 43,200 * (1 - 0.999) = 43,200 * 0.001 = 43.2 minutes

ERROR BUDGET REFERENCE TABLE:
+--------------------------------------------------------------+
|  SLO      | Error Budget | Minutes/month | Seconds/day       |
+--------------------------------------------------------------+
|  99%      | 1%           | 432 min       | 864 sec (14.4 min)|
|  99.5%    | 0.5%         | 216 min       | 432 sec (7.2 min) |
|  99.9%    | 0.1%         | 43.2 min      | 86.4 sec          |
|  99.95%   | 0.05%        | 21.6 min      | 43.2 sec          |
|  99.99%   | 0.01%        | 4.3 min       | 8.6 sec           |
|  99.999%  | 0.001%       | 0.43 min      | 0.86 sec          |
+--------------------------------------------------------------+

BUDGET CONSUMPTION TRACKING:
  Budget consumed (%) = (actual_bad_events / total_events) / (1 - SLO) * 100

  Example:
  SLO: 99.9% (budget = 0.1%)
  Observed error rate: 0.03%
  Budget consumed: 0.03% / 0.1% = 30%
  Budget remaining: 70%

REQUEST-BASED BUDGET (alternative to time-based):
  Total requests in window: 10,000,000
  Error budget (requests): 10,000,000 * 0.001 = 10,000 bad requests allowed
  Bad requests so far: 3,000
  Budget consumed: 30%

PROMETHEUS RECORDING RULES FOR BUDGET TRACKING:
groups:
  - name: slo-error-budget
    interval: 1m
    rules:
      # Error ratio over 30 days
      - record: slo:error_ratio:30d
        expr: |
          1 - (
            sum(increase(http_requests_total{code!~"5.."}[30d]))
            /
            sum(increase(http_requests_total[30d]))
          )

      # Budget remaining (1 = full, 0 = exhausted, negative = over budget)
      - record: slo:error_budget_remaining:ratio
        expr: |
          1 - (slo:error_ratio:30d / (1 - 0.999))

      # Budget consumption rate (per hour)
      - record: slo:error_budget_consumption_rate:1h
        expr: |
          (
            sum(rate(http_requests_total{code=~"5.."}[1h]))
            /
            sum(rate(http_requests_total[1h]))
          ) / (1 - 0.999)
```

### Step 6: Burn Rate Alerts -- Multi-Window, Multi-Burn-Rate
Configure alerting based on how fast the error budget is being consumed:

```
BURN RATE CONCEPT:
  Burn rate = (observed error rate) / (maximum error rate allowed by SLO)

  If burn rate = 1:   Budget consumed at exactly SLO rate (normal)
  If burn rate = 2:   Budget consumed 2x faster (exhausts in 15 days)
  If burn rate = 10:  Budget consumed 10x faster (exhausts in 3 days)
  If burn rate = 14.4: Budget consumed in ~2 days
  If burn rate = 36:  Budget consumed in ~20 hours
  If burn rate = 720: Budget consumed in 1 hour

MULTI-WINDOW MULTI-BURN-RATE ALERT TABLE:
(Google SRE Workbook recommended configuration)
+--------------------------------------------------------------+
|  Severity  | Burn Rate | Long Window | Short Window | Action  |
+--------------------------------------------------------------+
|  Critical  | 14.4x     | 1 hour      | 5 minutes    | Page    |
|  High      | 6x        | 6 hours     | 30 minutes   | Page    |
|  Medium    | 3x        | 1 day       | 2 hours      | Ticket  |
|  Low       | 1x        | 3 days      | 6 hours      | Log     |
+--------------------------------------------------------------+

WHY TWO WINDOWS:
- Long window alone: Fires on historical problems that already resolved
- Short window alone: Fires on brief spikes that self-correct
- Both together: Problem is sustained AND currently happening
  -> Dramatically fewer false positives

BUDGET CONSUMPTION PER ALERT:
  Critical (14.4x for 1h): consumes 2% of 30-day budget
  High (6x for 6h):        consumes 5% of 30-day budget
  Medium (3x for 1d):       consumes 10% of 30-day budget
  Low (1x for 3d):          consumes 10% of 30-day budget

PROMETHEUS ALERT PATTERN (per severity):
  alert: SLOBurnRate<Severity>
  expr: |
    (error_rate_over_long_window) > (burn_rate * error_budget_fraction)
    AND
    (error_rate_over_short_window) > (burn_rate * error_budget_fraction)
  for: <stabilization period>
  labels: severity, slo
  annotations: summary, runbook_url

  Availability SLI: sum(rate(http_requests_total{code=~"5.."}[window])) / sum(rate(http_requests_total[window]))
  Latency SLI: 1 - (sum(rate(bucket{le="threshold"}[window])) / sum(rate(count[window])))
```

### Step 7: Error Budget Policy
Define what happens at each level of budget consumption:

```
ERROR BUDGET POLICY:
+--------------------------------------------------------------+
|  Budget Remaining | Development Policy                         |
+--------------------------------------------------------------+
|  > 75%            | Full velocity. Ship features, experiment.  |
|                   | Error budget is healthy.                   |
|  50-75%           | Normal velocity with caution. Review risky |
|                   | changes more carefully.                    |
|  25-50%           | Slow down. Increase test coverage. Require |
|                   | extra review for changes touching critical |
|                   | paths.                                     |
|  10-25%           | Freeze non-critical changes. Focus on      |
|                   | reliability improvements. Only ship fixes   |
|                   | that improve reliability.                   |
|  < 10%            | Full freeze. All engineering effort goes to |
|                   | reliability. No feature work until budget   |
|                   | recovers above 25%.                         |
|  0% (exhausted)   | Emergency. Only reliability work.           |
|                   | Rollback recent changes if they contributed.|
|                   | Daily SLO review until budget > 25%.        |
+--------------------------------------------------------------+

POLICY ENFORCEMENT:
  Who decides: SLO owner (typically service team lead)
  Who is notified: Engineering manager, product manager
  Where tracked: SLO dashboard, weekly SLO review meeting
  Override process: VP-level approval to ship features during freeze

BUDGET RESET:
  Rolling window: Budget recovers as old bad events age out
  Calendar window: Budget resets on first of month (perverse incentive
    to break things at end of month -- avoid calendar windows for this reason)

ERROR BUDGET ATTRIBUTION:
  When budget is consumed, attribute the cause:
  +--------------------------------------------------------------+
  |  Source              | Budget Consumed | Action               |
  +--------------------------------------------------------------+
  |  Deployments         | <N>%            | Improve canary, tests|
  |  Infrastructure      | <N>%            | Improve redundancy   |
  |  Dependencies        | <N>%            | Add circuit breakers |
  |  Organic errors      | <N>%            | Fix bugs             |
  |  Planned maintenance | <N>%            | Reduce window        |
  +--------------------------------------------------------------+
```

### Step 8: SLO-Based Release Gating
Use error budgets to gate deployments:

```
RELEASE GATE POLICY:
+--------------------------------------------------------------+
|  Gate                        | Threshold   | Block Action      |
+--------------------------------------------------------------+
|  Pre-deploy budget check     | Budget < 10%| Block deployment   |
|  Canary error rate check     | > 2x baseline| Auto-rollback     |
|  Post-deploy budget check    | Budget dropped| Alert + investigate|
|                              | > 5% in 1h  |                    |
|  Progressive rollout         | Each stage   | Pause on budget    |
|                              | checks budget| consumption spike  |
+--------------------------------------------------------------+

CI/CD INTEGRATION EXAMPLE:
  # In deployment pipeline
  check_error_budget:
    - query: slo:error_budget_remaining:ratio{service="my-service"}
    - if budget_remaining < 0.10:
        action: BLOCK
        message: "Error budget below 10%. Deployment blocked. Fix reliability first."
    - if budget_remaining < 0.25:
        action: WARN
        message: "Error budget below 25%. Proceeding with extra caution."
        require: manual_approval
    - else:
        action: PROCEED

  canary_check:
    - deploy to 5% of traffic
    - wait 10 minutes
    - compare canary error rate to baseline:
        if canary_error_rate > 2 * baseline_error_rate:
          action: ROLLBACK
          message: "Canary error rate 2x baseline. Rolling back."
    - if passed: proceed to 25%, 50%, 100%

PROGRESSIVE ROLLOUT WITH SLO GATES:
  Stage 1 (5%):   Wait 10m, check SLO -> proceed or rollback
  Stage 2 (25%):  Wait 15m, check SLO -> proceed or rollback
  Stage 3 (50%):  Wait 30m, check SLO -> proceed or rollback
  Stage 4 (100%): Monitor for 1h, check SLO -> confirm or rollback
```

### Step 9: Composite SLOs
Define SLOs that span multiple services:

```
COMPOSITE SLO:
  When a user journey spans multiple services, define a composite SLO.

USER JOURNEY EXAMPLE: "Complete a purchase"
  1. Load product page    -> Product API (99.9% avail)
  2. Add to cart          -> Cart API (99.9% avail)
  3. Checkout             -> Checkout API (99.95% avail)
  4. Process payment      -> Payment API (99.99% avail)
  5. Send confirmation    -> Notification API (99.5% avail)

COMPOSITE AVAILABILITY (sequential):
  Composite SLO = Product AND Cart AND Checkout AND Payment AND Notification
  Worst case (independent failures):
    = 0.999 * 0.999 * 0.9995 * 0.9999 * 0.995
    = 0.9924 (99.24%)

  This means the JOURNEY availability is lower than ANY individual service.
  To achieve 99.9% journey SLO, each service must be well above 99.9%.

COMPOSITE AVAILABILITY (with redundancy):
  If a step has a fallback (e.g., cached product data):
    Effective availability = 1 - ((1 - primary) * (1 - fallback))
    = 1 - (0.001 * 0.01) = 0.99999 (99.999%)

COMPOSITE SLO TABLE:
+--------------------------------------------------------------+
|  User Journey      | Services Involved | Journey SLO | Status |
+--------------------------------------------------------------+
|  <journey name>    | <service list>     | <target>%  | <met?> |
|  <journey name>    | <service list>     | <target>%  | <met?> |
+--------------------------------------------------------------+

RECOMMENDATIONS:
1. Define SLOs for user journeys, not just individual services
2. The weakest link determines the journey SLO
3. Invest in the service that drags the composite SLO down most
4. Add redundancy (caching, fallbacks) to raise effective availability
5. Alert on the composite SLO, not just individual service SLOs
```

### Step 10: SLO Dashboards
Configure dashboards for SLO visibility:

```
SLO DASHBOARD LAYOUT:

PANEL 1: SLO Summary (top of dashboard)
+--------------------------------------------------------------+
|  SLI              | Target | Current | Budget Used | Status   |
+--------------------------------------------------------------+
|  Availability     | 99.9%  | 99.95%  | 30%         | HEALTHY  |
|  Latency (p50)    | <100ms | 45ms    | 15%         | HEALTHY  |
|  Latency (p99)    | <500ms | 380ms   | 60%         | WARNING  |
|  Error rate       | <0.1%  | 0.03%   | 30%         | HEALTHY  |
+--------------------------------------------------------------+

PANEL 2: Error Budget Remaining (time series, 30-day window)
  - Line chart showing budget remaining over time
  - Horizontal lines at 75%, 50%, 25%, 10% thresholds
  - Color: green > 50%, yellow 25-50%, orange 10-25%, red < 10%

PANEL 3: Burn Rate (time series, last 24h)
  - Line chart showing current burn rate
  - Horizontal lines at 1x, 3x, 6x, 14.4x thresholds
  - Spikes correlate with incidents

PANEL 4: Error Budget Attribution (pie chart)
  - Deployments: N%
  - Infrastructure: N%
  - Dependencies: N%
  - Organic errors: N%

PANEL 5: SLO Compliance History (bar chart, last 12 months)
  - Monthly SLO met/missed
  - Shows trends over time

KEY QUERIES:
  Error budget remaining:
    slo:error_budget_remaining:ratio{service='my-service'}
  Burn rate (1h):
    (sum(rate(http_requests_total{code=~'5..'}[1h])) / sum(rate(http_requests_total[1h]))) / (1 - 0.999)
  Budget thresholds: red < 10%, orange 10-25%, yellow 25-50%, green > 50%
  Burn rate thresholds: green < 3x, yellow 3-6x, orange 6-14.4x, red > 14.4x
```

### Step 11: SLO Review Cadence
Establish regular SLO reviews:

```
SLO REVIEW CADENCE:
+--------------------------------------------------------------+
|  Review Type  | Frequency | Attendees        | Focus           |
+--------------------------------------------------------------+
|  Weekly SLO   | Weekly    | Service team     | Budget status,  |
|  check        |           |                  | burn rate, any  |
|               |           |                  | incidents        |
|  Monthly SLO  | Monthly   | Team + eng mgr   | Budget trend,   |
|  review       |           | + product mgr    | policy enforce, |
|               |           |                  | SLO adjustments |
|  Quarterly    | Quarterly | Leadership +     | SLO targets,    |
|  SLO review   |           | all stakeholders | reliability     |
|               |           |                  | investment, SLA |
|               |           |                  | alignment       |
+--------------------------------------------------------------+

WEEKLY CHECK: SLO status, budget remaining, burn rate trend, incidents, action items.
QUARTERLY REVIEW: compliance rate, budget avg, SLO adjustment decisions, reliability investment.

WHEN TO ADJUST SLOs:
  TIGHTEN: consistently > 80% budget remaining, or users report uncaught issues.
  LOOSEN: consistently missing despite investment, or cost exceeds business value.
  LEAVE UNCHANGED: budget consumption 30-70% (well-calibrated).
```

### Step 12: Artifacts & Completion

```
SLO IMPLEMENTATION ARTIFACTS:
- docs/slo/<service>-slo.md (SLO definitions)
- docs/slo/error-budget-policy.md (budget policy)
- infra/alerts/<service>-slo-burn-rate.yaml (alert rules)
- infra/prometheus/<service>-slo-recording-rules.yaml (recording rules)
- infra/dashboards/<service>-slo-dashboard.json (dashboard)
- ci/<service>-slo-release-gate.yaml (release gate)
```

Commit: `"slo: <service> -- <targets>, <error budget policy>, <verdict>"`

## Key Behaviors

1. **SLOs are the contract between the service and its users.** Without SLOs, reliability is a feeling, not a fact. Define them explicitly, measure them continuously, and use them to make decisions.
2. **Error budgets turn reliability into an engineering tool.** When budget is healthy, ship fast. When budget is depleted, stop and fix. This creates a self-regulating system where velocity and reliability are in dynamic equilibrium.
3. **Burn rate alerts replace threshold alerts.** Do not alert on "error rate > 1%". Alert on "error budget is being consumed N times faster than sustainable". This connects the alert to business impact.
4. **Composite SLOs reflect user experience.** A user journey that spans five services has an SLO that is the product of all five. Optimize the weakest link, not the strongest.
5. **SLO review cadence prevents drift.** Weekly checks catch acute issues. Monthly reviews adjust tactics. Quarterly reviews adjust strategy and targets.
6. **Release gating with error budgets prevents preventable outages.** If the budget is already low, a risky deployment could breach the SLA. Gate the deploy until budget recovers.
7. **SLO dashboards make reliability visible to everyone.** Engineers, product managers, and leadership all see the same number. This creates shared ownership of reliability.
8. **Start conservative, tighten incrementally.** A too-strict SLO that is always violated is worse than a moderate SLO that is consistently met. Build trust first, then raise the bar.

## Example Usage

### Defining SLOs for a payment service
```
User: /godmode:slo Define SLOs for our payment processing API

SLO: Assessing service context...

SERVICE: Payment API (Tier 1 -- revenue-critical, user-facing)

SLI SELECTION:
  Availability: successful_requests / total_requests (exclude 4xx)
  Latency (p50): requests < 200ms / total_requests
  Latency (p99): requests < 1000ms / total_requests
  Correctness: verified_charges / total_charges

SLO TARGETS (rolling 30 days):
  Availability: 99.99% (4.3 min budget/month)
  Latency (p50): 99% of requests < 200ms
  Latency (p99): 99.9% of requests < 1000ms
  Correctness: 100% (no incorrect charges -- alerting, not budgeted)

ERROR BUDGET: 4.3 minutes/month (request-based: ~4,300 bad requests of 43M)
BURN RATE ALERTS: Critical (14.4x/1h), High (6x/6h), Medium (3x/1d)
POLICY: Freeze deploys when budget < 25%. All-hands reliability when < 10%.
RELEASE GATE: Block deployment if budget < 10%, require approval if < 25%.
```

### Checking error budget status
```
User: /godmode:slo --budget How is our error budget looking for the checkout service?

SLO: Querying error budget status...

CHECKOUT SERVICE - ERROR BUDGET STATUS:
  SLO: 99.9% availability (rolling 30 days)
  Current availability: 99.87%
  Error budget total: 43.2 minutes
  Error budget consumed: 56% (24.2 minutes used)
  Error budget remaining: 44% (19.0 minutes left)
  Burn rate (last 1h): 2.1x (slightly elevated)

  ATTRIBUTION:
    Deploy on Mar 12: 15 minutes (35% of budget)
    Redis failover Mar 15: 8 minutes (18% of budget)
    Organic errors: 1.2 minutes (3% of budget)

  POLICY STATUS: Normal velocity with caution (budget 25-50%)
  RECOMMENDATION: Address the deployment issue. Last deploy consumed
    35% of the budget. Improve canary analysis before next deploy.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full SLO definition, error budget, alerts, dashboard, policy |
| `--sli` | SLI selection and measurement guidance only |
| `--target` | SLO target setting guidance only |
| `--budget` | Error budget calculation and status check |
| `--alerts` | Multi-window burn rate alert configuration |
| `--policy` | Error budget policy definition |
| `--gate` | SLO-based release gating configuration |
| `--composite` | Composite SLO definition for user journeys |
| `--dashboard` | SLO dashboard setup (Grafana or Datadog) |
| `--review` | SLO review template and cadence setup |
| `--validate` | Validate SLO implementation against checklist |

## HARD RULES

1. **NEVER set SLO = 100%.** A 100% SLO means zero error budget, which means zero deployments. It is mathematically incompatible with shipping software.
2. **NEVER set SLO = SLA.** The SLO must always be stricter than the SLA. The gap is your safety margin. If SLO equals SLA, you breach the contract before detecting the problem.
3. **NEVER use averages as SLIs.** Use proportional SLIs (`99% of requests < 200ms`), not averages (`avg latency < 200ms`). Averages hide tail latency.
4. **NEVER define SLOs without an error budget policy.** An SLO without a policy is a number on a dashboard that changes nothing.
5. **NEVER alert on raw error rates without burn rate context.** Use multi-window, multi-burn-rate alerts. A 1% error rate for 5 seconds is noise; for 6 hours it is a crisis.
6. **ALWAYS require both long AND short windows for burn rate alerts.** Long window alone fires on resolved problems. Short window alone fires on transient spikes.
7. **ALWAYS measure SLIs closer to the user.** Load balancer metrics over application metrics over database metrics.
8. **ALWAYS start with current measured reliability** and set the SLO target slightly below it. Over-ambitious targets that are constantly violated erode trust.

## Output Format

After each SLO skill invocation, emit a structured report:

```
SLO REPORT:
┌──────────────────────────────────────────────────────┐
│  Service             │  <name>                        │
│  SLIs defined        │  <N> indicators                │
│  SLOs defined        │  <N> objectives                │
│  Window              │  <rolling 7d | 30d | 90d>      │
│  Error budget        │  <N> min/month (remaining: <N>%)│
│  Burn rate alerts    │  Critical: <x>  High: <x>  Medium: <x>  Low: <x> │
│  Budget policy       │  DOCUMENTED / MISSING          │
│  Release gating      │  CONFIGURED / NOT CONFIGURED   │
│  Dashboard           │  CREATED / MISSING             │
│  Composite SLOs      │  <N> user journeys             │
│  Review cadence      │  Weekly / Monthly / Quarterly  │
│  Verdict             │  SLO READY | NEEDS WORK        │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every SLO action for tracking:

```
timestamp	skill	service	action	slis	slos	budget_remaining_pct	status
2026-03-20T14:00:00Z	slo	payment-api	define	4	4	100	ready
2026-03-20T14:30:00Z	slo	checkout	budget_check	3	3	44	warning
```

## Success Criteria

The SLO skill is complete when ALL of the following are true:
1. SLIs are chosen based on service type (not one-size-fits-all)
2. SLIs measure user experience (not infrastructure metrics)
3. SLO targets are achievable (not 100%) and stricter than SLA
4. Error budgets are calculated correctly for each SLO
5. Multi-window burn rate alerts are configured (4 severity levels)
6. Error budget policy defines actions at each consumption level
7. SLO dashboard is created and accessible to all stakeholders
8. Release gating uses error budget to block/warn on deploys
9. SLO review cadence is established (weekly, monthly, quarterly)

## Error Recovery

```
IF SLO target is too aggressive (constantly violated):
  1. Measure current actual reliability over the last 30 days
  2. Set the SLO target slightly below the measured reliability
  3. Communicate the adjusted target to stakeholders
  4. Improve reliability incrementally and tighten the SLO over time

IF error budget policy is ignored (team ships during freeze):
  1. Integrate budget checks into CI/CD pipeline (automated gating)
  2. Make budget status visible on team dashboard and standup
  3. Require VP-level override approval for deploys during freeze
  4. Review the policy in a team meeting to ensure buy-in

IF burn rate alerts are noisy (too many false positives):
  1. Verify both long AND short windows are configured (not just one)
  2. Check that the SLI calculation excludes client errors (4xx)
  3. Increase the for duration to filter out transient spikes
  4. Check if the SLO target is too aggressive for the service's actual reliability

IF composite SLO shows degradation but individual services are green:
  1. Check inter-service latency (network issues between services)
  2. Check for cascading timeout chains
  3. Verify that each service's SLO is strict enough for the composite target
  4. Add circuit breakers or fallbacks to the weakest link in the journey
```

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Detect monitoring stack: grep for prometheus, datadog, grafana, newrelic in configs
2. Detect existing SLOs: find . -name "*slo*" -o -name "*service-level*" in docs/
3. Detect service type: check for HTTP handlers (API), queue consumers (pipeline), cron (batch)
4. Detect traffic patterns: check for load balancer configs, auto-scaling policies
5. Detect alerting: check for PagerDuty, OpsGenie, Slack webhook configs
6. Auto-configure: match SLI selection to detected service type
```

## Iterative SLO Implementation Loop

```
current_iteration = 0
max_iterations = 10
slo_tasks = [sli_selection, slo_targets, error_budgets, burn_rate_alerts, budget_policy, dashboard, release_gating, review_cadence]

WHILE slo_tasks is not empty AND current_iteration < max_iterations:
    task = slo_tasks.pop(0)
    1. Assess current state for this task
    2. Implement (SLI query, SLO target, alert rule, dashboard panel, policy doc)
    3. Validate: SLI is measurable, alert fires correctly, dashboard renders
    4. IF validation fails → revise thresholds or implementation
    5. IF passing → commit: "slo: <task> for <service>"
    6. current_iteration += 1

POST-LOOP: Run full validation checklist and simulate a budget consumption scenario
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "slo-definition": SLI selection, SLO targets, error budget calculation, policy document
  Agent 2 — "slo-alerts": Prometheus/Datadog recording rules, multi-window burn rate alerts
  Agent 3 — "slo-dashboard": Grafana/Datadog dashboard, release gating config, review templates

MERGE ORDER: definition → alerts → dashboard (alerts reference SLO targets, dashboard references alert rules)
CONFLICT ZONES: SLO target values and service names (agree on these before dispatch)
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run SLO tasks sequentially: SLI/SLO definitions, then burn rate alerts, then dashboard/gating.
- Use branch isolation per task: `git checkout -b godmode-slo-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.

## Keep/Discard Discipline
```
After EACH SLO configuration change:
  1. MEASURE: Query current SLI values over the last 24 hours.
  2. COMPARE: Does the SLO target match achievable reliability (current minus margin)?
  3. DECIDE:
     - KEEP if SLO target < current reliability AND SLO > SLA AND error budget policy documented.
     - DISCARD if SLO = 100% OR SLO = SLA OR burn rate alerts fire on resolved problems.
  4. COMMIT kept changes. Revert discarded thresholds before the next adjustment.

Never keep an SLO target that is constantly violated — it erodes trust.
Never keep a burn rate alert without both long AND short windows.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - SLIs defined, SLO targets set, error budgets calculated, burn rate alerts configured, budget policy documented
  - SLO dashboard live AND release gating configured AND review cadence established
  - User explicitly requests stop
  - Max iterations (10) reached
```
