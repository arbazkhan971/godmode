---
name: reliability
description: Site reliability engineering -- SLO/SLI/SLA,
  error budgets, toil, on-call, runbooks, incidents.
---

## Activate When
- `/godmode:reliability`, "SRE", "SLO", "error budget"
- "toil", "on-call", "runbook", "incident management"
- Establishing production operations for a new service

## Workflow

### 1. Service Context
```bash
grep -r "healthcheck\|health-check\|/health" \
  --include="*.ts" --include="*.py" -l 2>/dev/null
grep -r "pagerduty\|opsgenie\|alertmanager" \
  --include="*.yaml" --include="*.yml" -l 2>/dev/null
```
```
Service: <name> | Criticality: Tier 1/2/3
Current state: monitoring, alerting, on-call, runbooks
Dependencies: <upstream and downstream>
```

### 2. SLO/SLI/SLA
Hierarchy: SLA (external) -> SLO (internal, stricter)
-> SLI (measured metric).

SLI categories: availability (success/total),
latency (requests < threshold / total), throughput,
correctness, freshness, durability.

Error budget = 1 - SLO.
- 99.9% = 43.2 min/month error budget
- 99.99% = 4.3 min/month error budget

Errors: HTTP 5xx, timeouts, circuit breaker rejections.
NOT 4xx or 429.

### 3. Error Budgets & Burn Rate Alerts
Policy:
- >50% remaining: normal operations
- 25-50%: slow risky deploys
- 10-25%: freeze non-critical
- <10%: all hands on reliability
- 0%: only reliability work

Multi-window burn rate alerts:
- Critical: 14.4x burn, 1h+5m -> Page
- High: 6x burn, 6h+30m -> Page
- Medium: 3x burn, 1d+2h -> Ticket
- Low: 1x burn, 3d+6h -> Log

Both windows must trigger (reduces false positives).

### 4. Toil Reduction
Toil = manual, repetitive, automatable, tactical,
no enduring value. Inventory with frequency + hours.
Target: <50% of team capacity. Automate top 3.

IF toil > 50%: stop feature work, automate.

### 5. On-Call
Minimum 5 engineers. Primary + secondary.
Escalation: L1(0m) -> L2(15m) -> L3(30m) -> L4(60m).
Health: <5 pages/shift, <1 during sleep, MTTA <5min,
MTTR <30min, false positive <20%.
Max 1 week in 5. Day off after off-hours SEV1.

### 6. Runbooks
Every pageable alert needs: what is happening, user
impact, diagnostic steps (commands), mitigation
options (commands), escalation, post-incident actions.
Levels: L0 Manual -> L1 Assisted -> L2 Semi-auto
-> L3 Full auto.

### 7. Incident Management
Lifecycle: Detection -> Triage -> Mitigation ->
Resolution -> Post-mortem -> Prevention.
Severity: SEV1 (<15min), SEV2 (<30min),
SEV3 (<2h), SEV4 (next day).
Roles: IC, Tech Lead, Comms, Scribe.

### 8. Production Readiness
SLOs, error budget alerts, dashboards, logging,
tracing, alerts, runbooks, on-call, circuit breakers,
timeouts, auto-scaling, canary deploy, rollback.

## Hard Rules
1. NEVER set SLO at 100%.
2. EVERY alert must have a runbook.
3. NEVER alert on raw metrics -- use burn rate.
4. SET SLO stricter than SLA.
5. SLIs from real user traffic only.
6. NEVER skip SEV1/SEV2 post-mortems.
7. Budget policy MUST define exhaustion response.
8. On-call minimum 5 people.
9. Toil measured monthly; >50% = stop features.

## TSV Logging
Append `.godmode/reliability-results.tsv`:
```
timestamp	service	slo_count	budget_remaining_pct	alerts	runbooks	status
```

## Keep/Discard
```
KEEP if: SLO measurement works AND alerts fire
  correctly AND runbook is actionable.
DISCARD if: false positives OR measurement broken
  OR runbook is vague.
```

## Stop Conditions
```
STOP when ALL of:
  - SLOs defined and measurable (tier-1 services)
  - Burn rate alerts configured and tested
  - On-call rotation active with escalation
  - Runbooks exist for all critical alerts
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| SLO always breached | Set at current p95, improve later |
| Alert fatigue | Increase threshold, multi-signal alerts |
| Runbook outdated | Add to deploy checklist, test quarterly |
| Budget depleted fast | Freeze deploys, fix top errors |
