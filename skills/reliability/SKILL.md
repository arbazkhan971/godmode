---
name: reliability
description: |
  Site reliability engineering skill. Activates when user needs SLO/SLI/SLA definition, error budgets and burn rate alerts, toil identification, on-call rotation, runbook automation, or incident management. Triggers on: /godmode:reliability, "SRE", "SLO", "error budget", "toil", "on-call", "runbook", or when the orchestrator detects reliability work.
---

# Reliability -- Site Reliability Engineering

## When to Activate
- User invokes `/godmode:reliability`
- User says "SRE", "SLO", "SLI", "SLA", "error budget", "toil", "on-call", "runbook"
- When establishing production operations for a new service

## Workflow

### Step 1: Service Context
```
Service: <name> | Criticality: Tier 1/2/3
Current: reliability, monitoring, alerting, on-call, runbooks
Dependencies: <upstream and downstream>
```

### Step 2: SLO/SLI/SLA
Hierarchy: SLA (external) -> SLO (internal, stricter) -> SLI (measured metric).

SLI categories: Availability (success/total), Latency (requests < threshold / total), Throughput, Correctness, Freshness, Durability.

Error budget = 1 - SLO. 99.9% = 43.2 min/month. 99.99% = 4.3 min/month.

Errors: HTTP 5xx, timeouts, circuit breaker rejections. NOT 4xx or 429.

### Step 3: Error Budgets & Burn Rate Alerts
**Policy:** >50% = normal. 25-50% = slow risky deploys. 10-25% = freeze non-critical. <10% = all hands. 0% = only reliability work.

**Multi-window burn rate alerts:**
- Critical: 14.4x, 1h+5m -> Page
- High: 6x, 6h+30m -> Page
- Medium: 3x, 1d+2h -> Ticket
- Low: 1x, 3d+6h -> Log

Both windows must trigger (reduces false positives).

### Step 4: Toil
Toil = manual, repetitive, automatable, tactical, no enduring value.
Inventory tasks with frequency and monthly hours. Target <50% of team capacity. Automate top 3.

### Step 5: On-Call
Min 5 engineers. Primary + secondary. Escalation: L1(0m) -> L2(15m) -> L3(30m) -> L4(60m).
Health: <5 pages/shift, <1 during sleep, MTTA <5min, MTTR <30min, false positive <20%.
Sustainability: max 1 week in 5, day off after off-hours SEV1.

### Step 6: Runbooks
Every pageable alert: what is happening, user impact, diagnostic steps (commands), mitigation options (commands), escalation, post-incident actions.
Levels: L0 Manual -> L1 Assisted -> L2 Semi-auto -> L3 Full auto.

### Step 7: Incident Management
Lifecycle: Detection -> Triage -> Mitigation -> Resolution -> Post-mortem -> Prevention.
Severity: SEV1 (<15min), SEV2 (<30min), SEV3 (<2h), SEV4 (next day).
Roles: IC, Tech Lead, Comms, Scribe.

### Step 8: Production Readiness
SLOs, error budget alerts, dashboards, logging, tracing, alerts, runbooks, on-call, circuit breakers, timeouts, auto-scaling, canary deploy, rollback, security, docs.

### Step 9: Validation
```
- SLOs defined: PASS | FAIL
- Error budgets tracked: PASS | FAIL
- Burn rate alerts: PASS | FAIL
- On-call sustainable: PASS | FAIL
- Runbooks for all alerts: PASS | FAIL
- Toil reduction plan: PASS | FAIL
- Incident process defined: PASS | FAIL
VERDICT: <RELIABLE | NEEDS WORK>
```

## Key Behaviors

1. **SLOs drive decisions.** Define first.
2. **Error budgets balance velocity and reliability.**
3. **Toil is the enemy.** Track monthly, never exceed 50%.
4. **On-call must be sustainable.**
5. **Every alert needs a runbook.**
6. **Incidents are learning.** Blameless post-mortems.
7. **Production readiness is a gate.**

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full SRE assessment |
| `--slo` | SLO/SLI/SLA definition |
| `--budget` | Error budget policy |
| `--alerts` | Burn rate alerts |
| `--toil` | Toil elimination |
| `--oncall` | On-call rotation |
| `--runbook` | Runbook creation |
| `--readiness` | Production readiness review |

## HARD RULES

1. NEVER set SLO at 100%.
2. EVERY alert must have a runbook.
3. NEVER alert on raw metrics — use burn rate.
4. SLO MUST be stricter than SLA.
5. SLIs from real user traffic.
6. NEVER skip SEV1/SEV2 post-mortems.
7. Budget policy MUST define exhaustion response.
8. On-call minimum 5 people.
9. Toil measured monthly; >50% = stop features.

## Output Format

```
RELIABILITY REPORT:
Service: <name> | Tier: <1|2|3>
SLOs: <N> | Error budget: <N> min/month
Alerts: <N> | Runbooks: <N>/<M>
On-call: <N> engineers | Toil: <N> hrs/month
Verdict: RELIABLE | NEEDS WORK
```

## Platform Fallback
Run sequentially: SLOs, then alerts, then runbooks.

## Error Recovery
| Failure | Action |
|---------|--------|
| SLO too aggressive (always breached) | Review historical data. Set SLO at current p95 performance. Improve gradually. An SLO nobody can meet erodes trust. |
| Alert fires too often (alert fatigue) | Increase threshold or `for:` duration. Use multi-signal alerts. Route low-severity to tickets, not pages. |
| Runbook outdated (does not match current system) | Add runbook review to deploy checklist. Auto-link runbooks to alerts. Test runbooks in game days. |
| Error budget depleted too fast | Freeze non-critical deployments. Focus on reliability fixes. Investigate top error sources. Add canary deployments. |

## Success Criteria
1. SLOs defined for all tier-1 services with measurable SLIs.
2. Error budget calculated and tracked with burn rate alerts.
3. On-call rotation configured with escalation paths.
4. Runbooks exist for all critical alerts and are tested quarterly.

## TSV Logging
Append to `.godmode/reliability-results.tsv`:
```
timestamp	service	slo_count	error_budget_remaining_pct	alerts_configured	runbooks_count	status
```
One row per service assessed. Never overwrite previous rows.

## Keep/Discard Discipline
```
After EACH reliability change:
  KEEP if: SLO measurement works AND alerts fire correctly AND runbook is actionable
  DISCARD if: alert produces false positives OR SLO measurement broken OR runbook is vague
  On discard: revert. Fix measurement or threshold before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - SLOs defined and measurable for all tier-1 services
  - Burn rate alerts configured and tested
  - On-call rotation active with escalation
  - Runbooks exist for all critical alerts
```
