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
- **MITIGATE** — Reduce impact (circuit breakers, fallbacks, rate limits)
- **PROCESS** — Improve response process (runbooks, escalation paths)

Priority: P0 = 1 week (blocks features), P1 = 2 weeks, P2 = 1 month.

### Step 7: Metrics and Reporting
```
INCIDENT METRICS:
MTTD: <min from symptom to alert>  MTTA: <min from alert to response>
MTTR: <min from detection to resolution>  MTBF: <days since last>
Frequency (30d): SEV1=<N> SEV2=<N> SEV3=<N> SEV4=<N>
Action items: <completed>/<total> (<pct>). Repeats: <count>.
```
### Step 8: Commit and Transition
1. Save post-mortem as `docs/incidents/INC-<ID>-postmortem.md`
2. Save timeline as `docs/incidents/INC-<ID>-timeline.md`
3. Commit: `"incident: INC-<ID> — <severity> — <title> (<status>)"`
4. If RESOLVED: "Post-mortem complete. Action items tracked. Run `/godmode:plan` to schedule remediation work."
5. If ACTIVE: "Incident still active. Focus on mitigation. Re-run `/godmode:incident` when resolved to complete post-mortem."

## Key Behaviors
1. **Severity drives response.** SEV1 = drop everything. SEV4 = queue it.
2. **Timeline is sacred.** Timestamp every action. Memory fails under stress; logs don't.
3. **Blameless or useless.** Blame systems, not humans.
4. **Actionable items only.** "Add test for edge case X" not "be more careful."
5. **Follow up.** Track action item completion. Escalate overdue items.

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
```
1. Check for active alerts: error messages, stack traces, 5xx codes, PagerDuty/OpsGenie refs
2. Check for existing docs: docs/incidents/, postmortems/, INC-YYYY-MM-DD-NNN patterns
3. Check for monitoring: .github/, terraform/, docker-compose.yml, k8s manifests
4. Detect environment: deployment configs, production URLs, on-call rotation tools
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
```

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
- **Cannot identify root cause**: Widen investigation to 24h before incident. Check deploys, config changes, dependency updates. Declare "undetermined" if needed.
- **Timeline has gaps**: Cross-reference logs, metrics, deploy history, git log, Slack messages.
- **Post-mortem becomes blame-oriented**: Redirect to systems thinking. "The system allowed Y" not "Person X did Y."
- **Action items stale**: Escalate weekly. Block feature work if critical items overdue.
- **Severity disputed**: Use severity matrix. If in doubt, classify higher.
- **Recurring root cause**: Escalate to leadership. Require systemic fix.

## Keep/Discard Discipline
```
KEEP if: evidence confirms hypothesis AND mitigation reduces error rate
DISCARD if: evidence contradicts OR mitigation has no effect. Log all results.
Action items: KEEP if addresses root cause. DISCARD if vague or duplicate.
```

## Autonomy
Never ask to continue. Loop autonomously. On failure: git reset --hard HEAD~1.

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
