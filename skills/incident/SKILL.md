---
name: incident
description: |
  Incident response and post-mortem skill. Activates when production incidents occur and need structured management, or when teams need blameless post-mortems after resolution. Classifies incidents by severity (SEV1-4), constructs detailed timelines, coordinates response actions, and produces actionable post-mortem documents. Triggers on: /godmode:incident, "we have an outage", "production is down", "post-mortem", "incident report", or when monitoring alerts surface in conversation.
---

# Incident — Incident Response & Post-Mortem

## When to Activate
- User invokes `/godmode:incident`
- User reports a production outage, degradation, or alert
- User says "production is down", "we have an incident", "write a post-mortem"
- Monitoring alerts or PagerDuty/OpsGenie notifications are shared
- User needs to document a past incident for review

## Workflow

### Step 1: Incident Classification

Immediately classify the incident by severity to determine response urgency:

```
INCIDENT CLASSIFICATION:
ID: INC-<YYYY-MM-DD>-<NNN>
Title: <concise description of the impact>
Reported by: <who reported it>
Reported at: <timestamp UTC>
Severity: <SEV1 | SEV2 | SEV3 | SEV4>
Status: <INVESTIGATING | IDENTIFIED | MONITORING | RESOLVED>
```
#### Severity Definitions

| Level | Name | Impact | Response Time | Examples |
|--|--|--|--|--|
| **SEV1** | Critical | Complete service outage, data loss, security breach | Immediate (< 15 min) | Site down, database corruption, credentials leaked |
| **SEV2** | Major | Significant degradation, major feature broken | < 30 min | Payment processing failing, auth broken for subset |
| **SEV3** | Minor | Partial degradation, workaround available | < 2 hours | Slow responses, non-critical feature broken |
| **SEV4** | Low | Cosmetic issue, minimal user impact | Next business day | UI glitch, minor logging error, docs incorrect |

#### Escalation Rules
```
SEV1:
  - Page on-call immediately
  - Open war room (Slack channel / Zoom bridge)
  - Notify engineering leadership within 15 minutes
  - Status page updated within 20 minutes
  - Customer communication within 30 minutes

SEV2:
  - Page on-call
  - Dedicated incident channel
  - Notify team lead within 30 minutes
  - Status page updated within 1 hour

SEV3:
  - Notify on-call via non-urgent channel
  - Track in incident management system
  - Update status page if customer-facing

SEV4:
  - Create ticket in backlog
  - Address in next sprint/cycle
```

### Step 2: Incident Timeline Construction

Build a precise, timestamped record of events as they unfold:

```
INCIDENT TIMELINE — INC-<ID>:
| Timestamp (UTC) | Event |
|--|--|
| HH:MM:SS | First alert triggered: <alert name> |
| HH:MM:SS | On-call acknowledged |
| HH:MM:SS | Investigation started |
| HH:MM:SS | Root cause identified: <brief description> |
| HH:MM:SS | Mitigation applied: <action taken> |
| HH:MM:SS | Service restored |
| HH:MM:SS | Monitoring confirms stable |
| HH:MM:SS | Incident resolved |
```
#### Evidence Gathering
For each timeline entry, attach evidence:
```
EVIDENCE:
- Monitoring dashboards (screenshots or links)
- Log snippets with timestamps
- Deployment records (commit SHA, deploy timestamp)
- Configuration changes
- Customer reports / support tickets
- Alert history from PagerDuty/OpsGenie/CloudWatch
```

### Step 3: Impact Assessment

Quantify the blast radius:

```
IMPACT ASSESSMENT:
Duration: <start time> to <end time> (<total minutes>)
Users affected: <number or percentage>
Requests failed: <number or error rate percentage>
Revenue impact: <estimated $ or "not quantified">
SLA impact: <SLA budget consumed, remaining budget>
Data impact: <data lost, corrupted, or exposed — or NONE>
Downstream systems: <list of affected dependent services>
Customer communications sent: <YES/NO — details>
```
### Step 4: Root Cause Analysis

Identify the true root cause using the 5 Whys technique:

```
ROOT CAUSE ANALYSIS:
Proximate cause: <what directly triggered the incident>

5 Whys:
1. Why did <symptom> happen?
   → Because <immediate cause>
2. Why did <immediate cause> happen?
   → Because <deeper cause>
3. Why did <deeper cause> happen?
   → Because <process/system gap>
4. Why did <process/system gap> exist?
   → Because <organizational factor>
5. Why did <organizational factor> persist?
   → Because <root cause>

ROOT CAUSE: <single sentence stating the true root cause>

Contributing factors:
- <factor 1 — e.g., missing monitoring>
- <factor 2 — e.g., insufficient testing>
- <factor 3 — e.g., unclear runbook>
```
### Step 5: Blameless Post-Mortem Document

Generate the full post-mortem in blameless format:

```markdown
# Post-Mortem: INC-<ID> — <Title>

**Date:** <incident date>
**Severity:** <SEV level>
**Duration:** <total duration>
**Authors:** <post-mortem authors>
**Status:** <DRAFT | REVIEWED | FINAL>

## Summary
<2-3 sentence summary: what happened, what the impact was, how it was resolved>

## Timeline
<full timeline from Step 2>

## Impact
<impact assessment from Step 3>

## Root Cause
<root cause analysis from Step 4>

## What Went Well
- <things that worked — detection speed, team response, tooling>
- <effective processes that limited blast radius>
- <good decisions made under pressure>

## What Went Wrong
- <things that failed — slow detection, missing alerts, unclear ownership>
- <processes that broke down>
- <tooling gaps>

## Where We Got Lucky
- <things that could have made it worse but didn't>
- <near-misses to address>

## Action Items
<table from Step 6>

## Lessons Learned
- <key takeaway 1>
- <key takeaway 2>
- <key takeaway 3>
```
#### Blameless Principles
- **Name systems, not people.** "The deployment pipeline did not run integration tests" not "Alice forgot to run tests."
- **Focus on process gaps.** Every incident reveals a system weakness, not a human weakness.
- **Assume good intent.** Everyone involved was doing their best with the information they had.
- **Celebrate detection and response.** Fast detection and good response are as important as prevention.

### Step 6: Action Item Tracking

Every post-mortem must produce concrete, assigned, and deadline-bound action items:

```
ACTION ITEMS:
| # | Action | Type | Priority | Owner | Due Date |
|--|--|--|--|--|--|
| 1 | <action> | PREVENT | P0 | <team> | <date> |
| 2 | <action> | DETECT | P0 | <team> | <date> |
| 3 | <action> | MITIGATE | P1 | <team> | <date> |
| 4 | <action> | PROCESS | P2 | <team> | <date> |
```
#### Action Item Types
- **PREVENT** — Stop this class of incident from recurring
- **DETECT** — Catch it faster next time (alerts, monitoring, tests)
- **MITIGATE** — Reduce impact when it happens (circuit breakers, fallbacks, rate limits)
- **PROCESS** — Improve response process (runbooks, escalation paths, communication templates)

#### Priority Levels
- **P0** — Must complete within 1 week. Blocks shipping new features.
- **P1** — Must complete within 2 weeks. Tracked in sprint.
- **P2** — Must complete within 1 month. Scheduled for next cycle.

### Step 7: Metrics and Reporting

Track incident metrics over time:

```
INCIDENT METRICS:
MTTD (Mean Time to Detect):    <minutes from first symptom to first alert>
MTTA (Mean Time to Acknowledge): <minutes from alert to human response>
MTTR (Mean Time to Resolve):   <minutes from detection to resolution>
MTBF (Mean Time Between Failures): <days since last incident of this class>

Incident frequency (30 days):
  SEV1: <count>  SEV2: <count>  SEV3: <count>  SEV4: <count>

Action item completion rate: <completed>/<total> (<percentage>)
Repeat incidents: <count of incidents with same root cause as prior>
```
### Step 8: Commit and Transition
1. Save post-mortem as `docs/incidents/INC-<ID>-postmortem.md`
2. Save timeline as `docs/incidents/INC-<ID>-timeline.md`
3. Commit: `"incident: INC-<ID> — <severity> — <title> (<status>)"`
4. If RESOLVED: "Post-mortem complete. Action items tracked. Run `/godmode:plan` to schedule remediation work."
5. If ACTIVE: "Incident still active. Focus on mitigation. Re-run `/godmode:incident` when resolved to complete post-mortem."

## Key Behaviors

1. **Severity drives response.** SEV1 means drop everything. SEV4 means queue it up. Never over- or under-classify.
2. **Timeline is sacred.** Every action, discovery, and decision gets a timestamp. Memory fails under stress; logs don't.
3. **Blameless or useless.** The moment blame enters, people stop sharing information. Blame systems, not humans.
4. **Keep action items actionable.** "Be more careful" is not an action item. "Add integration test for payment edge case X" is.
5. **Every incident is a gift.** It reveals a weakness you didn't know about. The post-mortem is how you extract that value.
6. **Follow up.** A post-mortem without completed action items is theater. Track completion and hold teams accountable to deadlines.

## HARD RULES
1. NEVER assign blame to individuals — name systems, processes, and tools. "The deployment pipeline lacked X" not "Alice forgot X."
2. NEVER skip the post-mortem for SEV1 or SEV2 incidents. No exceptions.
3. NEVER guess at the timeline — use logs, monitoring data, and git history. Human memory under stress is unreliable.
4. NEVER inflate or deflate severity — classify honestly. Over-classification breeds alert fatigue; under-classification delays response.
5. NEVER create action items without an owner and a due date. "Be more careful" is not an action item.
6. NEVER let action items exceed 30 days without follow-up — track weekly, escalate if overdue.
7. ALWAYS timestamp every event in UTC — local times cause confusion during multi-timezone incidents.
8. ALWAYS attach evidence to timeline entries (logs, dashboards, deploy records).
9. ALWAYS include "Where We Got Lucky" in post-mortems — near-misses are free lessons.
10. ALWAYS update the status page within the timeframe defined by the severity level.

## Auto-Detection
On activation, detect incident context automatically:
```
AUTO-DETECT:
1. Check for active alerts:
   - Scan conversation for error messages, stack traces, HTTP 5xx codes
   - Look for PagerDuty/OpsGenie/CloudWatch alert references
   - Detect severity keywords: "down", "outage", "degraded", "breach"
2. Check for existing incident docs:
   - docs/incidents/, postmortems/, incident-reports/
   - Previous incident IDs (INC-YYYY-MM-DD-NNN pattern)
3. Check for monitoring integration:
   - .github/, terraform/ (for infrastructure context)
   - docker-compose.yml, k8s manifests (for service topology)
4. Detect environment:
   - Parse deployment configs for production URLs, service names
   - Identify on-call rotation tools (PagerDuty, OpsGenie configs)
5. Auto-generate incident ID from current date + sequence
```

## Incident Investigation Loop
Active incident investigation is iterative — gather evidence, form hypotheses, test them:
```
current_iteration = 0
status = "INVESTIGATING"

WHILE status != "RESOLVED":
  1. GATHER latest evidence:
     - Fresh logs from affected services (last 15 min window)
     - Current error rates and latency metrics
     - Recent deployments or config changes
  2. UPDATE timeline with new findings
  3. FORM hypothesis: "The issue is caused by X because Y"
  4. TEST hypothesis:
     - Check logs/metrics that would confirm or deny
     - If confirmed → apply mitigation
     - If denied → record as eliminated cause, form new hypothesis
  5. IF mitigation applied:
     - Monitor for 5-10 minutes
     - IF metrics recovering → status = "MONITORING"
     - IF no improvement → revert mitigation, continue investigating
  6. IF status == "MONITORING" for 15+ minutes with stable metrics:
     - status = "RESOLVED"
  7. current_iteration += 1
  8. IF current_iteration > 10 AND status == "INVESTIGATING":
     - ESCALATE to next severity level
     - Broaden investigation scope

EXIT when status == "RESOLVED"
POST-EXIT: Generate post-mortem document
```

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive incident management |
| `--classify` | Classify severity only |
| `--timeline` | Build/update timeline only |
| `--postmortem` | Generate post-mortem from existing timeline |
| `--retro` | Retrospective mode — build post-mortem from past incident |
| `--actions` | List and track action items from past post-mortems |
| `--metrics` | Show incident metrics dashboard |
| `--template` | Output blank post-mortem template |

## Output Format
Print on completion: `Incident: SEV{severity} — {title}. Duration: {start} to {resolved} ({total_time}). Root cause: {root_cause}. Action items: {action_count} ({completed}/{total} done). MTTR: {mttr}.`

## TSV Logging
Log every incident to `.godmode/incident-results.tsv`:
```
timestamp	severity	title	detection_time	resolution_time	mttr_min	root_cause	action_items	status
2024-01-15T14:30:00Z	SEV1	API outage	2min	45min	47	DB connection pool	5	resolved
2024-02-03T09:15:00Z	SEV2	Payment timeout	8min	30min	38	3rd party API	3	resolved
```
Columns: timestamp, severity, title, detection_time, resolution_time, mttr_min, root_cause, action_items, status(active/mitigated/resolved/postmortem_done).

## Success Criteria
- Incident classified within 5 minutes of detection (severity assigned).
- Timeline reconstructed from logs and monitoring data (not memory).
- Root cause identified with evidence (not guesses).
- Post-mortem completed within 48 hours of resolution (SEV1/SEV2).
- All action items tracked with owners and deadlines.
- Blameless language used throughout (systems, not individuals).
- "Where We Got Lucky" section included in post-mortem.
- MTTR trending downward quarter over quarter.

## Error Recovery
- **Cannot identify root cause**: Widen the investigation window. Check logs, metrics, and traces for the 24 hours before the incident. Look for correlated changes (deploys, config changes, dependency updates). If still unclear, declare "root cause undetermined" and add investigation action items.
- **Timeline has gaps**: Cross-reference multiple sources (application logs, infrastructure metrics, deployment history, git log, Slack messages). Use `git log --after` and `git log --before` to find changes in the incident window.
- **Post-mortem becomes blame-oriented**: Redirect to systems thinking. Replace "Person X did Y" with "The system allowed Y to happen without safeguards." Focus on what process or tooling change would prevent recurrence.
- **Action items not being completed**: Escalate overdue items weekly. Assign each item to a specific person with a specific deadline. Block feature work if critical remediation items are stale.
- **Severity disputed**: Use the severity matrix (customer impact, data loss, revenue impact). If in doubt, classify higher and downgrade after investigation.
- **Recurring incidents with same root cause**: Escalate to engineering leadership. Previous action items were insufficient. Require a systemic fix, not another band-aid.

## Keep/Discard Discipline
```
After EACH investigation hypothesis is tested:
  1. MEASURE: Does the evidence confirm or deny the hypothesis?
  2. DECIDE:
     - KEEP if: evidence confirms the hypothesis AND mitigation reduces error rate
     - DISCARD if: evidence contradicts the hypothesis OR mitigation has no effect
  3. Log the result: hypothesis, evidence, outcome (confirmed/denied), time spent.

For action items in post-mortems:
  - KEEP action items that address root cause or contributing factors
  - DISCARD action items that are vague ("be more careful") or duplicate existing controls
```

## Stop Conditions
```
STOP investigation when ANY of these are true:
  - Root cause identified with supporting evidence
  - Service restored and stable for 15+ minutes (then shift to post-mortem mode)
  - Incident downgraded below investigation threshold (SEV4)
  - User explicitly requests stop

STOP post-mortem when:
  - All sections complete (timeline, impact, root cause, action items)
  - All action items have owners and deadlines
  - Document reviewed by at least one other team member
```
