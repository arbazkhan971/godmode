---
name: incident
description: |
  Incident response and post-mortem skill. Severity
  classification (SEV1-4), timeline construction,
  blameless post-mortems, action item tracking.
  Triggers on: /godmode:incident, "production is down",
  "post-mortem", "incident report".
---

# Incident — Incident Response & Post-Mortem

## When to Activate
- User invokes `/godmode:incident`
- User reports production outage or degradation
- User says "production is down", "write a post-mortem"
- Monitoring alerts or PagerDuty notifications shared

## Workflow

### Step 1: Incident Classification

```bash
# Check recent deployments (common root cause)
git log --oneline --since="2 hours ago" | head -10

# Check error rates if monitoring accessible
curl -s "http://localhost:9090/api/v1/query?\
query=rate(http_requests_total{code=~'5..'}[5m])" \
  2>/dev/null | head -5
```

```
INCIDENT CLASSIFICATION:
ID: INC-<YYYY-MM-DD>-<NNN>
Title: <concise impact description>
Severity: <SEV1 | SEV2 | SEV3 | SEV4>
Status: INVESTIGATING | IDENTIFIED | MONITORING | RESOLVED

SEVERITY MATRIX:
| Level | Impact           | Response Time |
|-------|-----------------|---------------|
| SEV1  | Complete outage | < 15 min      |
| SEV2  | Major degradation| < 30 min     |
| SEV3  | Partial degradation| < 2 hours  |
| SEV4  | Minimal impact  | Next business day|

IF error rate > 50%: SEV1
IF error rate 10-50% or major feature broken: SEV2
IF error rate 1-10% or workaround exists: SEV3
IF cosmetic or < 1% impact: SEV4
```

### Step 2: Timeline Construction

```
INCIDENT TIMELINE — INC-<ID>:
| Timestamp (UTC) | Event                    |
|-----------------|--------------------------|
| HH:MM:SS        | First alert triggered    |
| HH:MM:SS        | On-call acknowledged     |
| HH:MM:SS        | Root cause identified    |
| HH:MM:SS        | Mitigation applied       |
| HH:MM:SS        | Service restored         |
| HH:MM:SS        | Incident resolved        |

EVIDENCE per entry:
  - Monitoring dashboards (screenshots/links)
  - Log snippets with timestamps
  - Deploy records (commit SHA, timestamp)
  - Customer reports / support tickets
```

### Step 3: Impact Assessment

```
IMPACT:
Duration: <start> to <end> (<total minutes>)
Users affected: <number or percentage>
Requests failed: <number or error rate %>
Revenue impact: <estimated $ or unknown>
SLA consumed: <budget used, remaining>
Data impact: <lost, corrupted, exposed, or NONE>

THRESHOLDS:
  MTTD target: < 5 minutes (symptom to alert)
  MTTA target: < 15 minutes (alert to response)
  MTTR target: < 60 minutes (detection to resolution)
  IF MTTR > 120 min for SEV1: escalate process review
```

### Step 4: Root Cause Analysis (5 Whys)

```
1. Why did <symptom> happen?
   → Because <immediate cause>
2. Why did <immediate cause> happen?
   → Because <deeper cause>
3. Why did <deeper cause> happen?
   → Because <process gap>
4. Why did <process gap> exist?
   → Because <organizational factor>
5. Why did <organizational factor> persist?
   → Because <root cause>

ROOT CAUSE: <single sentence>
Contributing factors:
  - <missing monitoring>
  - <insufficient testing>
  - <unclear runbook>
```

### Step 5: Blameless Post-Mortem

```markdown
# Post-Mortem: INC-<ID> — <Title>
Severity: <SEV>, Duration: <total>

## Summary
<2-3 sentences: what, impact, resolution>

## Timeline
<from Step 2>

## Impact
<from Step 3>

## Root Cause
<from Step 4>

## What Went Well
- <detection speed, team response, tooling>

## What Went Wrong
- <slow detection, missing alerts, unclear ownership>

## Where We Got Lucky
- <things that could have been worse>

## Action Items
<from Step 6>
```

**Blameless principles:**
- Name systems, not people.
- Focus on process gaps.
- Assume good intent.

### Step 6: Action Item Tracking

```
| # | Action      | Type    | Priority | Owner | Due  |
|---|-------------|---------|----------|-------|------|
| 1 | <action>    | PREVENT | P0       | <team>| <date>|
| 2 | <action>    | DETECT  | P0       | <team>| <date>|
| 3 | <action>    | MITIGATE| P1       | <team>| <date>|

Types: PREVENT (stop recurrence), DETECT (faster),
  MITIGATE (reduce impact), PROCESS (improve response)
Priority: P0 = 1 week, P1 = 2 weeks, P2 = 1 month

IF action item > 30 days old: escalate weekly
IF no owner: action item is invalid — assign now
IF vague ("be more careful"): rewrite as specific action
```

### Step 7: Metrics

```
MTTD: <min>, MTTA: <min>, MTTR: <min>
Frequency (30d): SEV1=<N> SEV2=<N> SEV3=<N>
Action items: <completed>/<total>
Repeat incidents: <count>
```

Commit: `"incident: INC-<ID> — <severity> — <title>"`

## Key Behaviors

1. **Severity drives response.** SEV1 = drop everything.
2. **Timeline is sacred.** Timestamp every action.
3. **Blameless or useless.** Blame systems, not humans.
4. **Actionable items only.** Not "be more careful."
5. **Follow up.** Track completion weekly.

## HARD RULES

1. Never assign blame to individuals.
2. Never skip post-mortem for SEV1 or SEV2.
3. Never guess at timeline — use logs and git history.
4. Never inflate or deflate severity.
5. Never create action items without owner and due date.
6. Never let action items exceed 30 days without follow-up.
7. Always timestamp in UTC.
8. Always attach evidence to timeline entries.
9. Always include "Where We Got Lucky" section.
10. Always update status page within severity timeframe.

## Auto-Detection
```
1. Active alerts: error messages, 5xx codes
2. Existing docs: docs/incidents/, postmortems/
3. Monitoring: terraform, docker-compose, k8s
4. Environment: deployment configs, on-call tools
```

## Investigation Loop
```
WHILE status != "RESOLVED":
  1. GATHER: logs (15min window), error rates, deploys
  2. UPDATE timeline
  3. FORM hypothesis: "caused by X because Y"
  4. TEST: check logs/metrics that confirm or deny
  5. IF confirmed: apply mitigation, monitor 5-10 min
  6. IF denied: record, form new hypothesis
  7. IF monitoring stable 15+ min: status = RESOLVED
  8. IF > 10 iterations: escalate severity
```

## Output Format
Print: `Incident: SEV{N} — {title}. MTTR: {min}m.
  Action items: {count}. Status: {status}.`

## TSV Logging
```
timestamp	severity	title	mttr_min	action_items	status
```

## Keep/Discard Discipline
```
KEEP if: evidence confirms hypothesis AND mitigation
  reduces error rate
DISCARD if: evidence contradicts OR no effect
```

## Stop Conditions
```
STOP investigation when ANY of:
  - Root cause identified with evidence
  - Service stable 15+ min (shift to post-mortem)
  - User requests stop

STOP post-mortem when:
  - All sections complete
  - All action items have owners and deadlines
```

## Error Recovery
- Cannot find root cause: widen to 24h before incident.
- Timeline gaps: cross-reference logs, metrics, Slack.
- Post-mortem blame-oriented: redirect to systems.
- Recurring root cause: escalate to leadership.
