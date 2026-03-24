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
If the user has not provided context, ask: "What does this service do and who are its users? The answers determine which SLIs matter and how aggressively to set SLO targets."

### Step 2: SLA vs SLO vs SLI -- Establish the Hierarchy
Clarify the three levels before defining anything:

```
SERVICE LEVEL HIERARCHY:
|  SLA (Service Level Agreement)                                  |
|    External, contractual promise to customers.                  |
|    Breach has legal or financial consequences.                  |
|    Example: "99.5% uptime per calendar month or credit issued." |
|  SLO (Service Level Objective)                                  |
|    Internal target, stricter than the SLA.                      |
|    Drives engineering priorities via error budgets.              |
```
### Step 3: SLI Selection
Choose the right indicators based on service type:

```
SLI SELECTION BY SERVICE TYPE:

USER-FACING API / WEB SERVICE:
|  SLI Category  | Definition                | Measurement       |
|--|--|--|
|  Availability  | Successful requests /     | HTTP 5xx excluded, |
|                | total requests            | measured at LB     |
|  Latency       | Requests below threshold  | p50, p99 at server |
|                | / total requests          | or LB (not client) |
|  Error rate    | Failed requests /         | 5xx + timeouts /   |
|                | total requests            | total requests     |

DATA PIPELINE / BATCH JOB:
```
#### What Counts as an Error
```
ERROR CLASSIFICATION:
|  Response           | Counts as Error? | Rationale             |
|--|--|--|
|  HTTP 5xx           | YES              | Server failure         |
|  Timeout            | YES              | Server too slow        |
|  Circuit breaker    | YES              | Shed load = user hurt  |
|  HTTP 4xx           | NO               | Client mistake         |
|  HTTP 429 (rate     | DOCUMENT CHOICE  | Debatable: user is     |
|    limited)         |                  | blocked either way     |
|  Planned downtime   | DOCUMENT CHOICE  | Excluded if SLA says so|
|  Dependency failure  | YES             | User does not care why |
```

### Step 4: SLO Definition -- Target + Window
Set concrete SLO targets for each SLI:

```
SLO DEFINITION TABLE:
|  SLI              | SLO Target | Window      | SLA (if any)   |
|--|--|--|--|
|  Availability     | <target>%  | <window>    | <target>%      |
|  Latency (p50)    | < <N>ms    | <window>    | < <N>ms        |
|  Latency (p99)    | < <N>ms    | <window>    | < <N>ms        |
|  Error rate       | < <N>%     | <window>    | < <N>%         |
|  Freshness        | < <N>s     | <window>    | < <N>s         |
|  Throughput       | > <N> RPS  | <window>    | > <N> RPS      |

SLO WINDOW OPTIONS:
|  Window Type       | When to Use              | Trade-offs     |
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
|  SLO      | Error Budget | Minutes/month | Seconds/day       |
|--|--|--|--|
|  99%      | 1%           | 432 min       | 864 sec (14.4 min)|
|  99.5%    | 0.5%         | 216 min       | 432 sec (7.2 min) |
|  99.9%    | 0.1%         | 43.2 min      | 86.4 sec          |
```
### Step 6: Burn Rate Alerts -- Multi-Window, Multi-Burn-Rate
Configure alerting based on how fast errors consume the budget:

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
|  Severity  | Burn Rate | Long Window | Short Window | Action  |
```
### Step 7: Error Budget Policy
Define what happens at each level of budget consumption:

```
ERROR BUDGET POLICY:
|  Budget Remaining | Development Policy                         |
|--|--|
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
```
### Step 8: SLO-Based Release Gating
Use error budgets to gate deployments:

```
RELEASE GATE POLICY:
|  Gate                        | Threshold   | Block Action      |
|--|--|--|
|  Pre-deploy budget check     | Budget < 10%| Block deployment   |
|  Canary error rate check     | > 2x baseline| Auto-rollback     |
|  Post-deploy budget check    | Budget dropped| Alert + investigate|
|                              | > 5% in 1h  |                    |
|  Progressive rollout         | Each stage   | Pause on budget    |
|                              | checks budget| consumption spike  |

CI/CD INTEGRATION EXAMPLE:
  # In deployment pipeline
  check_error_budget:
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
```
### Step 10: SLO Dashboards & Review
Dashboard panels: SLO summary (SLI/target/current/budget/status), error budget time series (30-day with threshold lines at 75%/50%/25%/10%), burn rate graph, top SLO violators.

Review cadence: Weekly (team, budget status), Monthly (team + eng/product mgr, trends + adjustments), Quarterly (leadership, targets + investment + SLA alignment).
### Step 11: Artifacts & Completion
Artifacts: `docs/slo/<service>-slo.md`, `infra/alerts/<service>-slo-burn-rate.yaml`, `infra/dashboards/<service>-slo-dashboard.json`, `ci/<service>-slo-release-gate.yaml`.
Commit: `"slo: <service> -- <targets>, <error budget policy>, <verdict>"`

## Key Behaviors

1. **SLOs are the contract between the service and its users.** Without SLOs, reliability is a feeling, not a fact. Define them explicitly, measure them continuously, and use them to make decisions.
2. **Error budgets turn reliability into an engineering tool.** When budget is healthy, ship fast. When budget is depleted, stop and fix. This creates a self-regulating system where velocity and reliability are in dynamic equilibrium.
3. **Burn rate alerts replace threshold alerts.** Do not alert on "error rate > 1%". Alert on "errors consuming the budget N times faster than sustainable". This connects the alert to business impact.
4. **Composite SLOs reflect user experience.** A user journey that spans five services has an SLO that is the product of all five. Optimize the weakest link, not the strongest.
5. **SLO review cadence prevents drift.** Weekly checks catch acute issues. Monthly reviews adjust tactics. Quarterly reviews adjust strategy and targets.
6. **Release gating with error budgets prevents preventable outages.** If the budget is already low, a risky deployment could breach the SLA. Gate the deploy until budget recovers.
7. **SLO dashboards make reliability visible to everyone.** Engineers, product managers, and leadership all see the same number. This creates shared ownership of reliability.
8. **Start conservative, tighten incrementally.** A too-strict SLO that is always violated is worse than a moderate SLO that is consistently met. Build trust first, then raise the bar.
9. **On failure: git reset --hard HEAD~1.**
10. **Never ask to continue. Loop autonomously until SLO targets defined or budget exhausted.**

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full SLO definition, error budget, alerts, dashboard, policy |
| `--sli` | SLI selection and measurement guidance only |
| `--target` | SLO target setting guidance only |

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
| Service | <name> |
|--|--|
| SLIs defined | <N> indicators |
| SLOs defined | <N> objectives |
| Window | <rolling 7d | 30d | 90d> |
| Error budget | <N> min/month (remaining: <N>%) |
| Burn rate alerts | Critical: <x>  High: <x>  Medium: <x>  Low: <x> |
| Budget policy | DOCUMENTED / MISSING |
| Release gating | CONFIGURED / NOT CONFIGURED |
| Dashboard | CREATED / MISSING |
| Composite SLOs | <N> user journeys |
| Review cadence | Weekly / Monthly / Quarterly |
| Verdict | SLO READY | NEEDS WORK |
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
  4. Review the policy in a team meeting to verify buy-in

IF burn rate alerts are noisy (too many false positives):
  1. Verify both long AND short windows are configured (not one alone)
  2. Check that the SLI calculation excludes client errors (4xx)
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
