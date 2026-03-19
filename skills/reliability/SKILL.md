---
name: reliability
description: |
  Site reliability engineering skill. Activates when user needs SLO/SLI/SLA definition and tracking, error budgets and burn rate alerts, toil identification and elimination, on-call rotation design, runbook automation, or incident management process design. Triggers on: /godmode:reliability, "SRE", "SLO", "SLI", "SLA", "error budget", "toil", "on-call", "runbook", "site reliability", or when the orchestrator detects reliability engineering work.
---

# Reliability -- Site Reliability Engineering

## When to Activate
- User invokes `/godmode:reliability`
- User says "SRE", "SLO", "SLI", "SLA", "error budget"
- User says "toil", "on-call", "runbook", "site reliability"
- User says "availability target", "burn rate", "reliability"
- User says "incident process", "production readiness", "operational maturity"
- When establishing production operations for a new service
- When `/godmode:observe` identifies missing SLOs or alerting gaps
- When `/godmode:incident` reveals systemic reliability issues

## Workflow

### Step 1: Service Reliability Context
Understand the service and its reliability requirements:

```
RELIABILITY CONTEXT:
Service: <name and purpose>
Users: <who uses this service, internal/external>
Business Criticality: Tier 1 (revenue) | Tier 2 (important) | Tier 3 (internal)
Current Reliability: <observed uptime, error rate, latency>
Current Monitoring: <what is monitored today>
Current Alerting: <what alerts exist, who receives them>
Current On-Call: <is there an on-call rotation, how does it work>
Current Runbooks: <do runbooks exist, are they up to date>
Pain Points: <what reliability problems exist today>
Dependencies: <critical upstream and downstream services>
```

If the user has not provided context, ask: "What is the business criticality of this service -- is downtime measured in lost revenue, user frustration, or internal inconvenience? This determines how much reliability investment is warranted."

### Step 2: SLO/SLI/SLA Definition
Define the service level objectives that drive reliability decisions:

```
SERVICE LEVEL HIERARCHY:
+---------------------------------------------------------------+
|  SLA (Agreement)     -- External promise to customers           |
|    |                                                             |
|    v                                                             |
|  SLO (Objective)     -- Internal target (stricter than SLA)     |
|    |                                                             |
|    v                                                             |
|  SLI (Indicator)     -- Measured metric that tracks the SLO     |
+---------------------------------------------------------------+

SLI DEFINITIONS:
+--------------------------------------------------------------+
|  Category    | SLI                    | Measurement            |
+--------------------------------------------------------------+
|  Availability| Successful requests /  | HTTP 5xx excluded,     |
|              | total requests         | measured at LB         |
|  Latency     | Requests faster than   | p50, p99 at server     |
|              | threshold / total      | side (not client)      |
|  Throughput  | Requests processed /   | Measured per second    |
|              | second                 | at application         |
|  Correctness | Correct responses /    | Validation checks      |
|              | total responses        | on output              |
|  Freshness   | Data updated within    | Lag measurement on     |
|              | threshold / total      | data pipeline          |
|  Durability  | Data retained /        | Measured over quarter  |
|              | data stored            |                        |
+--------------------------------------------------------------+

SLO TABLE:
+--------------------------------------------------------------+
|  SLI              | SLO Target | Window   | SLA (if external) |
+--------------------------------------------------------------+
|  Availability     | 99.9%      | 30 days  | 99.5%             |
|  Latency (p50)    | < 100ms    | 30 days  | < 500ms           |
|  Latency (p99)    | < 500ms    | 30 days  | < 2000ms          |
|  Error rate       | < 0.1%     | 30 days  | < 1%              |
|  Throughput       | > 1000 RPS | 30 days  | N/A               |
+--------------------------------------------------------------+

SLO WINDOW:
- Rolling 30-day window (most common, smooth)
- Calendar month (aligned with billing, spiky)
- Rolling 7-day window (faster feedback, more volatile)

ERROR BUDGET = 1 - SLO
  99.9% SLO -> 0.1% error budget -> 43.2 minutes/month
  99.95% SLO -> 0.05% error budget -> 21.6 minutes/month
  99.99% SLO -> 0.01% error budget -> 4.3 minutes/month
```

#### SLO Calculation
```
AVAILABILITY SLI CALCULATION:
  SLI = (total_requests - error_requests) / total_requests * 100

  What counts as an error:
  - HTTP 5xx responses (server errors)
  - Timeouts (request exceeded deadline)
  - Circuit breaker rejections (shed load)

  What does NOT count as an error:
  - HTTP 4xx responses (client errors)
  - Rate-limited requests (429) -- debatable, document your choice
  - Planned maintenance (if communicated and excluded by agreement)

LATENCY SLI CALCULATION:
  SLI = requests_below_threshold / total_requests * 100

  Threshold selection:
  - p50 threshold: median user experience
  - p99 threshold: tail latency (worst 1%)
  - Both should have separate SLOs

  Where to measure:
  - At the load balancer (includes network, most accurate for user)
  - At the application (excludes network, easier to action)
  - NOT at the client (too many variables)
```

### Step 3: Error Budgets and Burn Rate Alerts
Configure error budget tracking and alerting:

```
ERROR BUDGET CALCULATION:
  SLO: 99.9% availability over 30 days
  Total minutes in 30 days: 43,200
  Error budget: 43,200 * 0.001 = 43.2 minutes of downtime

  Budget consumed: (actual_errors / total_requests) / (1 - SLO) * 100
  Example: 0.05% error rate -> 0.05% / 0.1% = 50% budget consumed

ERROR BUDGET POLICY:
+--------------------------------------------------------------+
|  Budget Remaining | Action                                     |
+--------------------------------------------------------------+
|  > 50%            | Normal development velocity                |
|  25-50%           | Increase testing, slow risky deploys        |
|  10-25%           | Freeze non-critical changes, focus on       |
|                   | reliability improvements                    |
|  < 10%            | All hands on reliability, freeze deploys    |
|  0% (exhausted)   | Only reliability work until budget restores |
+--------------------------------------------------------------+
```

#### Multi-Window Burn Rate Alerts
```
BURN RATE ALERTING:
  Burn rate = (error rate observed / error rate allowed by SLO)

  If burn rate = 1: budget consumed exactly at SLO rate
  If burn rate = 10: budget consumed 10x faster (exhausts in 3 days)
  If burn rate = 100: budget consumed in ~7 hours

MULTI-WINDOW BURN RATE ALERT CONFIGURATION:
+--------------------------------------------------------------+
|  Severity  | Burn Rate | Long Window | Short Window | Action  |
+--------------------------------------------------------------+
|  Critical  | 14.4x     | 1 hour      | 5 minutes    | Page    |
|  High      | 6x        | 6 hours     | 30 minutes   | Page    |
|  Medium    | 3x        | 1 day       | 2 hours      | Ticket  |
|  Low       | 1x        | 3 days      | 6 hours      | Log     |
+--------------------------------------------------------------+

WHY MULTI-WINDOW:
- Long window: Catches sustained error rates (not just blips)
- Short window: Ensures the problem is current (not just historical)
- Both must trigger: Reduces false positives dramatically

PROMETHEUS ALERTING RULES:
groups:
  - name: slo-burn-rate
    rules:
      # Critical: 14.4x burn rate over 1h AND 5m
      - alert: SLOBurnRateCritical
        expr: |
          (
            sum(rate(http_requests_total{code=~"5.."}[1h]))
            /
            sum(rate(http_requests_total[1h]))
          ) > (14.4 * 0.001)
          AND
          (
            sum(rate(http_requests_total{code=~"5.."}[5m]))
            /
            sum(rate(http_requests_total[5m]))
          ) > (14.4 * 0.001)
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "SLO burn rate critical: {{ $value | humanizePercentage }}"
          runbook_url: "https://runbooks.example.com/slo-burn-rate"

      # High: 6x burn rate over 6h AND 30m
      - alert: SLOBurnRateHigh
        expr: |
          (
            sum(rate(http_requests_total{code=~"5.."}[6h]))
            /
            sum(rate(http_requests_total[6h]))
          ) > (6 * 0.001)
          AND
          (
            sum(rate(http_requests_total{code=~"5.."}[30m]))
            /
            sum(rate(http_requests_total[30m]))
          ) > (6 * 0.001)
        for: 5m
        labels:
          severity: high
        annotations:
          summary: "SLO burn rate high: {{ $value | humanizePercentage }}"
          runbook_url: "https://runbooks.example.com/slo-burn-rate"

      # Medium: 3x burn rate over 1d AND 2h
      - alert: SLOBurnRateMedium
        expr: |
          (
            sum(rate(http_requests_total{code=~"5.."}[1d]))
            /
            sum(rate(http_requests_total[1d]))
          ) > (3 * 0.001)
          AND
          (
            sum(rate(http_requests_total{code=~"5.."}[2h]))
            /
            sum(rate(http_requests_total[2h]))
          ) > (3 * 0.001)
        for: 15m
        labels:
          severity: medium
        annotations:
          summary: "SLO burn rate elevated: {{ $value | humanizePercentage }}"
```

### Step 4: Toil Identification and Elimination
Find and eliminate repetitive operational work:

```
TOIL DEFINITION:
Toil is work that is:
- Manual: Requires a human to do it
- Repetitive: Done more than once
- Automatable: Could be done by a machine
- Tactical: Reactive, not strategic
- No enduring value: Does not improve the system permanently
- Scales with service growth: More users = more toil

TOIL INVENTORY:
+--------------------------------------------------------------+
|  Task                | Frequency | Time/Occ | Monthly Hours   |
+--------------------------------------------------------------+
|  <manual deploy>     | <N>/week  | <M> min  | <total hours>   |
|  <restart service>   | <N>/week  | <M> min  | <total hours>   |
|  <manual scaling>    | <N>/month | <M> min  | <total hours>   |
|  <cert rotation>     | <N>/qtr   | <M> min  | <total hours>   |
|  <log investigation> | <N>/week  | <M> min  | <total hours>   |
|  <data cleanup>      | <N>/month | <M> min  | <total hours>   |
+--------------------------------------------------------------+
TOTAL TOIL: <N> hours/month (<N>% of team capacity)

TOIL TARGET: < 50% of SRE team time (Google SRE book recommendation)
CURRENT: <N>% -> <ACCEPTABLE | EXCESSIVE>

TOIL ELIMINATION PRIORITY:
+--------------------------------------------------------------+
|  Priority | Task              | Automation Approach  | Effort  |
+--------------------------------------------------------------+
|  1        | <highest toil>    | <how to automate>    | <S/M/L> |
|  2        | <second highest>  | <how to automate>    | <S/M/L> |
|  3        | <third highest>   | <how to automate>    | <S/M/L> |
+--------------------------------------------------------------+

TOIL REDUCTION TARGETS:
  This quarter: Reduce toil from <N>% to <M>% (-<X> hours/month)
  Next quarter: Reduce to <M>% (-<X> hours/month)
  6 months: Reach <50% target
```

### Step 5: On-Call Rotation Design
Design sustainable on-call practices:

```
ON-CALL ROTATION:
+--------------------------------------------------------------+
|  Parameter          | Configuration                            |
+--------------------------------------------------------------+
|  Rotation type      | Weekly | Bi-weekly | Follow-the-sun     |
|  Team size          | <N> engineers (minimum 5 for weekly)     |
|  Primary on-call    | 1 engineer                               |
|  Secondary on-call  | 1 engineer (escalation backup)           |
|  Handoff time       | <day> <time> <timezone>                  |
|  Handoff process    | <sync meeting, async doc, both>          |
|  Compensation       | <time off, pay differential, both>       |
+--------------------------------------------------------------+

ON-CALL SCHEDULE:
+--------------------------------------------------------------+
|  Week    | Primary        | Secondary       | Notes            |
+--------------------------------------------------------------+
|  Week 1  | <engineer>     | <engineer>      |                  |
|  Week 2  | <engineer>     | <engineer>      |                  |
|  Week 3  | <engineer>     | <engineer>      |                  |
|  Week 4  | <engineer>     | <engineer>      |                  |
|  Week 5  | <engineer>     | <engineer>      |                  |
+--------------------------------------------------------------+

ESCALATION POLICY:
+--------------------------------------------------------------+
|  Level   | Who              | Timeout    | Method             |
+--------------------------------------------------------------+
|  L1      | Primary on-call  | 0 min      | PagerDuty/phone    |
|  L2      | Secondary on-call| 15 min     | PagerDuty/phone    |
|  L3      | Engineering lead | 30 min     | Phone call         |
|  L4      | VP Engineering   | 60 min     | Phone call         |
+--------------------------------------------------------------+

ON-CALL HEALTH METRICS:
+--------------------------------------------------------------+
|  Metric                    | Target    | Current              |
+--------------------------------------------------------------+
|  Pages per on-call shift   | < 5       | <N>                  |
|  Pages during sleep hours  | < 1       | <N>                  |
|  Mean time to acknowledge  | < 5 min   | <N> min              |
|  Mean time to resolve      | < 30 min  | <N> min              |
|  False positive rate       | < 20%     | <N>%                 |
|  On-call satisfaction      | > 7/10    | <N>/10               |
+--------------------------------------------------------------+

ON-CALL SUSTAINABILITY:
- Maximum 1 week in 5 (never more frequent)
- Maximum 2 pages per night (more = fix the system, not the person)
- Mandatory day off after high-severity incident during off-hours
- On-call engineer has reduced sprint commitments (50% capacity)
- Every page generates an action item (reduce future pages)
```

### Step 6: Runbook Design and Automation
Create actionable runbooks for common operational scenarios:

```
RUNBOOK TEMPLATE:
+---------------------------------------------------------------+
|  RUNBOOK: <Alert Name>                                          |
+---------------------------------------------------------------+
|  Alert:       <alert name and severity>                         |
|  Service:     <service name>                                    |
|  Owner:       <team/individual>                                 |
|  Last updated: <date>                                           |
|  Last used:    <date>                                           |
+---------------------------------------------------------------+
|                                                                 |
|  WHAT IS HAPPENING:                                             |
|  <1-2 sentence description of what this alert means>            |
|                                                                 |
|  USER IMPACT:                                                   |
|  <what users are experiencing right now>                        |
|                                                                 |
|  DIAGNOSTIC STEPS:                                              |
|  1. Check <dashboard-url> for <metric>                          |
|  2. Run: <diagnostic command>                                   |
|  3. Check <log query> for errors                                |
|  4. Verify <dependency> is healthy: <health check command>      |
|                                                                 |
|  MITIGATION STEPS:                                              |
|  Option A: <quick fix, e.g., restart service>                   |
|    Command: <exact command to run>                              |
|    Expected result: <what you should see>                       |
|    Time to effect: <how long until recovery>                    |
|                                                                 |
|  Option B: <rollback if Option A fails>                         |
|    Command: <exact rollback command>                            |
|    Expected result: <what you should see>                       |
|                                                                 |
|  ESCALATION:                                                    |
|  If not resolved in <N> minutes:                                |
|  - Escalate to <team/person>                                    |
|  - Include: <what information to provide>                       |
|                                                                 |
|  POST-INCIDENT:                                                 |
|  - Create incident ticket: <link to template>                   |
|  - Schedule post-mortem if SEV1/SEV2                            |
+---------------------------------------------------------------+

RUNBOOK INVENTORY:
+--------------------------------------------------------------+
|  Alert                 | Runbook Exists | Automated | Tested  |
+--------------------------------------------------------------+
|  High error rate       | YES / NO       | YES / NO  | <date>  |
|  High latency          | YES / NO       | YES / NO  | <date>  |
|  Database connection   | YES / NO       | YES / NO  | <date>  |
|  Disk space low        | YES / NO       | YES / NO  | <date>  |
|  Memory pressure       | YES / NO       | YES / NO  | <date>  |
|  Certificate expiring  | YES / NO       | YES / NO  | <date>  |
|  Dependency down       | YES / NO       | YES / NO  | <date>  |
+--------------------------------------------------------------+

RUNBOOK COVERAGE: <N>/<M> alerts have runbooks (<percentage>%)
TARGET: 100% of pageable alerts have runbooks
```

#### Runbook Automation
```
AUTOMATION LEVELS:
+--------------------------------------------------------------+
|  Level            | Description              | Example         |
+--------------------------------------------------------------+
|  L0: Manual       | Human follows runbook    | SSH, run cmds   |
|  L1: Assisted     | Script gathers info      | Diagnostic script|
|  L2: Semi-auto    | Script fixes, human      | Auto-restart    |
|                   | confirms                  | with approval   |
|  L3: Full auto    | System self-heals        | Auto-scale,     |
|                   |                           | auto-restart    |
+--------------------------------------------------------------+

AUTOMATION PRIORITY:
  Automate first:
  1. Alerts that fire most frequently (reduce toil)
  2. Alerts with well-known, safe remediation (low risk)
  3. Alerts that fire during sleep hours (improve quality of life)

  Automate last:
  1. Rare alerts (low ROI)
  2. Alerts requiring judgment (high risk of wrong action)
  3. Alerts with data loss potential (needs human confirmation)

SELF-HEALING EXAMPLE:
  Alert: Pod OOMKilled
  Auto-remediation:
    1. Capture heap dump (for analysis)
    2. Restart pod (Kubernetes does this automatically)
    3. If > 3 OOMKills in 1 hour:
       a. Increase memory limit by 25%
       b. Alert on-call (something is leaking)
    4. If increased limit > threshold:
       a. Roll back to previous version
       b. Page on-call as SEV2
```

### Step 7: Incident Management Process
Define the incident lifecycle:

```
INCIDENT LIFECYCLE:
  Detection -> Triage -> Mitigation -> Resolution -> Post-mortem -> Prevention

INCIDENT SEVERITY DEFINITIONS:
+--------------------------------------------------------------+
|  Severity | Definition                 | Response | Comms      |
+--------------------------------------------------------------+
|  SEV1     | Total outage, data loss,   | < 15 min | Exec + all|
|           | security breach             |          | customers |
|  SEV2     | Major degradation, critical| < 30 min | Eng lead + |
|           | feature broken              |          | affected   |
|  SEV3     | Partial degradation,       | < 2 hrs  | Team only  |
|           | workaround available        |          |            |
|  SEV4     | Cosmetic, minimal impact   | Next day | Ticket     |
+--------------------------------------------------------------+

INCIDENT ROLES:
+--------------------------------------------------------------+
|  Role                | Responsibility                          |
+--------------------------------------------------------------+
|  Incident Commander  | Coordinates response, makes decisions   |
|  (IC)                | Delegates tasks, manages communication  |
|  Tech Lead           | Drives technical investigation and fix  |
|  Communications Lead | Updates stakeholders, status page        |
|  Scribe              | Documents timeline, decisions, actions   |
+--------------------------------------------------------------+

INCIDENT COMMUNICATION TEMPLATE:
  Subject: [SEV<N>] <Service> - <Brief Description>
  Status: Investigating | Identified | Monitoring | Resolved
  Impact: <what users are experiencing>
  Current action: <what we are doing right now>
  Next update: <time of next update>

INCIDENT TIMELINE:
  T+0:   Alert fires, on-call acknowledges
  T+5:   Initial triage, severity assigned
  T+10:  Incident channel created, roles assigned
  T+15:  First status update to stakeholders
  T+30:  Status update (every 30 min for SEV1, 1h for SEV2)
  T+??:  Root cause identified, mitigation applied
  T+??:  Resolved, monitoring for recurrence
  T+48h: Post-mortem document drafted
  T+7d:  Post-mortem meeting, action items assigned
```

### Step 8: Production Readiness Review
Assess whether a service is ready for production:

```
PRODUCTION READINESS CHECKLIST:
+--------------------------------------------------------------+
|  Category        | Check                         | Status     |
+--------------------------------------------------------------+
|  SLOs            | SLOs defined and measured     | PASS | FAIL|
|                  | Error budget alerts configured| PASS | FAIL|
|  Monitoring      | Dashboards for golden signals | PASS | FAIL|
|                  | Structured logging enabled    | PASS | FAIL|
|                  | Distributed tracing enabled   | PASS | FAIL|
|  Alerting        | Alerts for all failure modes  | PASS | FAIL|
|                  | Runbooks for all alerts       | PASS | FAIL|
|                  | On-call rotation configured   | PASS | FAIL|
|  Resilience      | Circuit breakers on deps      | PASS | FAIL|
|                  | Timeouts on all external calls| PASS | FAIL|
|                  | Graceful degradation defined  | PASS | FAIL|
|                  | Chaos tested                  | PASS | FAIL|
|  Scalability     | Auto-scaling configured       | PASS | FAIL|
|                  | Load tested at 2x peak        | PASS | FAIL|
|                  | Rate limiting enabled         | PASS | FAIL|
|  Deployment      | Canary or blue-green deploy   | PASS | FAIL|
|                  | Rollback tested               | PASS | FAIL|
|                  | Feature flags for new code    | PASS | FAIL|
|  Security        | Security audit passed         | PASS | FAIL|
|                  | Secrets management configured | PASS | FAIL|
|  Documentation   | Architecture documented       | PASS | FAIL|
|                  | API contracts defined         | PASS | FAIL|
|                  | Operational runbook complete  | PASS | FAIL|
+--------------------------------------------------------------+

VERDICT: <PRODUCTION READY | NOT READY (<N> items to fix)>
```

### Step 9: Operational Maturity Assessment
Assess overall operational maturity:

```
OPERATIONAL MATURITY MODEL:
+--------------------------------------------------------------+
|  Dimension         | L1 Reactive | L2 Proactive | L3 Advanced |
+--------------------------------------------------------------+
|  SLOs              | None        | Defined      | Error budget|
|                    |             |               | driven      |
|  Monitoring        | Basic uptime| Golden signals| Full        |
|                    |             |               | observability|
|  Alerting          | Noisy, many | Actionable   | Burn rate   |
|                    | false pos   |               | multi-window|
|  Incident mgmt    | Ad hoc      | Defined roles | Automated   |
|                    |             | and process   | + blameless |
|  On-call           | Hero culture| Rotation with | Sustainable |
|                    |             | escalation    | + metrics   |
|  Toil              | > 80%       | 50-80%       | < 50%       |
|  Runbooks          | None        | Some alerts   | 100% + auto |
|  Capacity plan     | None        | Quarterly     | Continuous  |
|  Chaos testing     | None        | Ad hoc       | Regular     |
|  Post-mortems      | None        | After SEV1   | All SEVs,   |
|                    |             |               | action track|
+--------------------------------------------------------------+

CURRENT MATURITY: <L1 | L2 | L3> per dimension
TARGET MATURITY: <L2 | L3> per dimension
GAP ANALYSIS: <list of improvements needed>
```

### Step 10: Validation & Artifacts
Validate the SRE implementation:

```
SRE VALIDATION:
+--------------------------------------------------------------+
|  Check                                    | Status            |
+--------------------------------------------------------------+
|  SLOs defined for all critical services   | PASS | FAIL       |
|  Error budgets calculated and tracked     | PASS | FAIL       |
|  Burn rate alerts configured              | PASS | FAIL       |
|  On-call rotation is sustainable          | PASS | FAIL       |
|  Runbooks exist for all pageable alerts   | PASS | FAIL       |
|  Toil identified and reduction plan exists| PASS | FAIL       |
|  Incident management process defined      | PASS | FAIL       |
|  Production readiness review complete     | PASS | FAIL       |
|  Operational maturity assessed            | PASS | FAIL       |
|  Post-mortem process established          | PASS | FAIL       |
+--------------------------------------------------------------+

VERDICT: <RELIABLE | NEEDS WORK>
```

Generate deliverables:

```
SRE IMPLEMENTATION COMPLETE:

Artifacts:
- SLO definitions: docs/sre/<service>-slos.md
- Error budget policy: docs/sre/error-budget-policy.md
- On-call rotation: docs/sre/<team>-oncall-rotation.md
- Runbooks: docs/sre/runbooks/<alert-name>.md
- Alert configuration: infra/alerts/<service>-burn-rate.yaml
- Production readiness: docs/sre/<service>-production-readiness.md
- Toil inventory: docs/sre/<team>-toil-inventory.md
- Validation: <RELIABLE | NEEDS WORK>

Next steps:
-> /godmode:observe -- Implement monitoring for SLIs
-> /godmode:incident -- Set up incident management process
-> /godmode:chaos -- Validate resilience with chaos experiments
-> /godmode:automate -- Automate runbook procedures
```

Commit: `"reliability: <service> -- <SLO targets>, <error budget policy>, <verdict>"`

## Key Behaviors

1. **SLOs drive every reliability decision.** Without SLOs, reliability work is arbitrary. Define SLOs first, then derive monitoring, alerting, error budgets, and operational investment from them.
2. **Error budgets balance velocity and reliability.** When the budget is healthy, ship fast. When the budget is exhausted, stop and fix reliability. This is not a suggestion -- it is a policy.
3. **Toil is the enemy of engineering.** Every hour spent on repetitive manual work is an hour not spent improving the system. Track toil, eliminate it systematically, and never let it exceed 50% of team capacity.
4. **On-call must be sustainable.** Engineers who are burned out from on-call write worse code and miss more bugs. Measure on-call health, fix noisy alerts, and compensate fairly.
5. **Runbooks are mandatory for every pageable alert.** An alert without a runbook means the on-call engineer is debugging from scratch at 3am. Every alert links to a runbook.
6. **Incidents are learning opportunities.** Blameless post-mortems with tracked action items prevent recurrence. Blame-filled post-mortems prevent people from reporting problems.
7. **Production readiness is a gate, not a suggestion.** Services that skip production readiness reviews cause incidents. Make the review mandatory before launch.
8. **Measure operational maturity and improve iteratively.** Reliability is not a destination. Assess maturity quarterly, set targets, and invest in the biggest gaps.

## Example Usage

### Defining SLOs for a new service
```
User: /godmode:reliability Define SLOs for our payment API

Reliability: Assessing service context...

SERVICE: Payment API (Tier 1 -- revenue-critical)

SLO DEFINITIONS:
  Availability: 99.99% (4.3 min downtime/month)
    SLI: successful_requests / total_requests (exclude 4xx)
  Latency (p50): < 200ms (99% of requests)
    SLI: requests < 200ms / total_requests
  Latency (p99): < 1000ms (99.9% of requests)
    SLI: requests < 1000ms / total_requests
  Correctness: 100% (no incorrect charges)
    SLI: verified_transactions / total_transactions

ERROR BUDGET: 4.3 minutes/month
BURN RATE ALERTS: Critical (14.4x/1h), High (6x/6h), Medium (3x/1d)

POLICY: Freeze non-critical deploys when budget < 25%
```

### Reducing operational toil
```
User: /godmode:reliability Our team spends too much time on manual ops

Reliability: Let me inventory the toil...

TOIL INVENTORY:
  1. Manual certificate rotation: 4h/month
  2. Database cleanup scripts: 6h/month
  3. Log investigation for customer issues: 8h/month
  4. Manual scaling during peak hours: 3h/month
  5. Restarting flaky services: 5h/month
  TOTAL: 26h/month (32% of team capacity)

ELIMINATION PLAN:
  Priority 1: Auto-cert rotation (cert-manager) -> saves 4h
  Priority 2: Auto-scaling policies -> saves 3h
  Priority 3: Self-healing restart with watchdog -> saves 5h
  Priority 4: Automated DB cleanup cron -> saves 6h
  Priority 5: Better logging + search -> saves 4h

  After automation: 4h/month (5% of capacity) -- customer log investigation remains
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full SRE assessment and implementation |
| `--slo` | SLO/SLI/SLA definition only |
| `--budget` | Error budget calculation and policy |
| `--alerts` | Burn rate alert configuration |
| `--toil` | Toil identification and elimination plan |
| `--oncall` | On-call rotation design |
| `--runbook` | Runbook creation for specific alert |
| `--incident` | Incident management process design |
| `--readiness` | Production readiness review |
| `--maturity` | Operational maturity assessment |
| `--validate` | Validate SRE practices against checklist |

## Anti-Patterns

- **Do NOT set SLOs at 100%.** A 100% availability target is impossible and means zero error budget. This stops all deployments. Set realistic targets (99.9% is generous for most services).
- **Do NOT alert on SLOs without error budgets.** An SLO alert without an error budget policy is just noise. The error budget tells you what to do about it.
- **Do NOT let toil grow unchecked.** "We'll automate it later" is how toil reaches 80% of team capacity. Track it monthly and allocate time for elimination.
- **Do NOT design on-call for heroes.** If one person handles all incidents, you have a single point of failure. Rotate, cross-train, and ensure at least 5 people can respond.
- **Do NOT write runbooks after incidents.** Write runbooks when you create alerts. An alert without a runbook is an alert that will be ignored at 3am.
- **Do NOT skip post-mortems.** Every SEV1/SEV2 gets a post-mortem. No exceptions. Post-mortems without tracked action items are useless -- track completion.
- **Do NOT confuse SLAs with SLOs.** SLAs are external promises with contractual consequences. SLOs are internal targets that should be stricter than SLAs. Never set SLO = SLA.
- **Do NOT alert on everything.** More alerts does not mean more reliability. It means more noise, more fatigue, and more ignored alerts. Alert on SLO burn rate, not individual metrics.
