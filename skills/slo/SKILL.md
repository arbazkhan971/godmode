---
name: slo
description: >
  SLOs, SLIs, error budgets, burn rate alerts,
  reliability targets, service level management.
---

# SLO -- Service Level Objectives

## Activate When
- `/godmode:slo`, "SLO", "SLI", "SLA", "error budget"
- "reliability target", "uptime", "burn rate"
- Defining reliability contracts for services
- Incident reveals SLO violations went undetected

## Workflow

### Step 1: Service Context
```
Service: <name and purpose>
Type: User-facing API | Internal API | Pipeline | Batch
Criticality: Tier 1 (revenue) | Tier 2 | Tier 3
Current Reliability: <observed uptime, error rate>
Traffic: <steady | diurnal | spiky | seasonal>
Request Volume: <RPS or per day>
```

### Step 2: SLA vs SLO vs SLI
```
SLA: External contract. Breach = legal/financial.
  Example: "99.5% uptime/month or credit issued."
SLO: Internal target, stricter than SLA.
  Drives priorities via error budgets.
SLI: Measured indicator.
  Example: successful requests / total requests.
```

### Step 3: SLI Selection
```
USER-FACING API:
  Availability: success / total (exclude 5xx)
  Latency: requests below threshold / total
  Error rate: (5xx + timeouts) / total

PIPELINE / BATCH:
  Freshness: data age < threshold
  Completeness: records processed / expected
  Correctness: valid outputs / total outputs

ERROR CLASSIFICATION:
  5xx = YES | Timeout = YES | 4xx = NO
  429 rate-limited = DOCUMENT CHOICE
  Dependency failure = YES (user doesn't care why)
```
```bash
# Measure current SLIs
curl -sf localhost:9090/api/v1/query \
  --data-urlencode 'query=sum(rate(http_requests_total{code=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))' \
  | jq '.data.result[0].value[1]'
```

### Step 4: SLO Targets
```
| SLI          | SLO Target | Window | SLA     |
|-------------|-----------|--------|---------|
| Availability | 99.9%     | 30d    | 99.5%   |
| Latency p50 | < 100ms   | 30d    | < 200ms |
| Latency p99 | < 500ms   | 30d    | < 1000ms|
| Error rate  | < 0.1%    | 30d    | < 0.5%  |
```

### Step 5: Error Budget Calculation
```
Error budget = 1 - SLO target

EXAMPLE: 99.9% availability, 30 days
  Budget: 43,200 min * 0.001 = 43.2 min/month

REFERENCE TABLE:
| SLO   | Budget  | Min/month | Sec/day  |
|-------|---------|----------|----------|
| 99%   | 1%      | 432 min  | 864 sec  |
| 99.5% | 0.5%    | 216 min  | 432 sec  |
| 99.9% | 0.1%    | 43.2 min | 86.4 sec |
| 99.95%| 0.05%   | 21.6 min | 43.2 sec |
| 99.99%| 0.01%   | 4.3 min  | 8.6 sec  |
```

### Step 6: Burn Rate Alerts
```
Burn rate = observed error rate / max allowed rate
  1x = normal | 2x = exhausts in 15d
  10x = exhausts in 3d | 36x = in 20h

MULTI-WINDOW ALERTS (Google SRE Workbook):
| Severity | Burn | Long Win | Short Win |
|----------|------|----------|-----------|
| Critical | 14.4 | 1h       | 5min      |
| High     | 6    | 6h       | 30min     |
| Medium   | 3    | 1d       | 2h        |
| Low      | 1    | 3d       | 6h        |
```

### Step 7: Error Budget Policy
```
> 75% remaining: Full velocity. Ship freely.
50-75%: Normal velocity, review risky changes.
25-50%: Slow down. Extra review for critical paths.
10-25%: Freeze non-critical. Reliability only.
< 10%: Full freeze. All effort to reliability.
```

### Step 8: Release Gating
```
IF budget < 10%: block deployment
IF canary error rate > 2x baseline: auto-rollback
IF budget dropped > 5% in 1h: alert + investigate
IF progressive rollout: pause on budget spike
```

### Step 9: Composite SLOs
```
User journey "Complete Purchase":
  Product API 99.9% * Cart 99.9% * Checkout 99.95%
  * Payment 99.99% * Notification 99.5%
  = 99.24% composite availability
Optimize the weakest link, not the strongest.
```

### Step 10: Dashboard & Review
Panels: SLO summary, budget time series (30d with
threshold lines at 75%/50%/25%/10%), burn rate.

Review: Weekly (team), Monthly (team + mgmt),
Quarterly (leadership, targets + SLA alignment).

## Key Behaviors
1. **SLOs make reliability measurable.**
2. **Error budgets balance velocity and reliability.**
3. **Burn rate alerts replace threshold alerts.**
4. **Composite SLOs reflect user experience.**
5. **Start conservative, tighten incrementally.**
6. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER set SLO = 100%. Zero budget = zero deploys.
2. NEVER set SLO = SLA. Gap is your safety margin.
3. NEVER use averages as SLIs. Use proportional.
4. NEVER define SLOs without error budget policy.
5. ALWAYS require both long AND short alert windows.
6. ALWAYS measure SLIs closer to the user.
7. ALWAYS start with current measured reliability.

## Auto-Detection
```bash
grep -r "prometheus\|datadog\|grafana\|newrelic" \
  --include="*.yml" --include="*.yaml" -l 2>/dev/null
find . -name "*slo*" -o -name "*service-level*" \
  2>/dev/null | head -5
```

## TSV Logging
Log to `.godmode/slo-results.tsv`:
`timestamp\tservice\tslis\tslos\tbudget_pct\tstatus`

## Output Format
```
SLO: {service} | SLIs: {N} | SLOs: {N}
Budget: {N} min/month ({N}% remaining)
Alerts: {N} configured | Policy: {status}
Verdict: SLO READY | NEEDS WORK
```

## Keep/Discard Discipline
```
KEEP if: SLO < current reliability AND SLO > SLA
  AND error budget policy documented
DISCARD if: SLO = 100% OR SLO = SLA
  OR burn rate alerts fire on resolved problems
```

## Stop Conditions
```
STOP when:
  - SLIs defined, SLOs set, budgets calculated
  - Burn rate alerts configured, policy documented
  - Dashboard live AND release gating configured
  - User requests stop OR max 10 iterations
```
