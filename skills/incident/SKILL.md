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
|-------|------|--------|---------------|----------|
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
┌──────────────────┬────────────────────────────────────────────┐
│ Timestamp (UTC)  │ Event                                      │
├──────────────────┼────────────────────────────────────────────┤
│ HH:MM:SS         │ First alert triggered: <alert name>        │
│ HH:MM:SS         │ On-call acknowledged                       │
│ HH:MM:SS         │ Investigation started                      │
│ HH:MM:SS         │ Root cause identified: <brief description> │
│ HH:MM:SS         │ Mitigation applied: <action taken>         │
│ HH:MM:SS         │ Service restored                           │
│ HH:MM:SS         │ Monitoring confirms stable                 │
│ HH:MM:SS         │ Incident resolved                          │
└──────────────────┴────────────────────────────────────────────┘
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
- <near-misses that should be addressed>

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
┌────┬──────────────┬──────────┬──────────┬───────────┬──────────┐
│ #  │ Action       │ Type     │ Priority │ Owner     │ Due Date │
├────┼──────────────┼──────────┼──────────┼───────────┼──────────┤
│ 1  │ <action>     │ PREVENT  │ P0       │ <team>    │ <date>   │
│ 2  │ <action>     │ DETECT   │ P0       │ <team>    │ <date>   │
│ 3  │ <action>     │ MITIGATE │ P1       │ <team>    │ <date>   │
│ 4  │ <action>     │ PROCESS  │ P2       │ <team>    │ <date>   │
└────┴──────────────┴──────────┴──────────┴───────────┴──────────┘
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
4. **Action items must be actionable.** "Be more careful" is not an action item. "Add integration test for payment edge case X" is.
5. **Every incident is a gift.** It reveals a weakness you didn't know about. The post-mortem is how you extract that value.
6. **Follow up.** A post-mortem without completed action items is theater. Track completion and hold teams accountable to deadlines.

## Example Usage

### Responding to a Production Outage
```
User: /godmode:incident Production API is returning 500 errors

Incident: Classifying...

INCIDENT CLASSIFICATION:
ID: INC-2025-03-15-001
Title: Production API returning 500 errors on /api/v2/orders
Severity: SEV2 — Major (order processing degraded, users can't checkout)
Status: INVESTIGATING

Building timeline...

TIMELINE:
14:23 UTC — CloudWatch alarm triggered: 5xx rate > 5%
14:25 UTC — On-call acknowledged via PagerDuty
14:28 UTC — Investigation started, checking recent deploys
14:32 UTC — Identified: deploy at 14:15 UTC introduced null pointer in order validation
14:35 UTC — Rollback initiated to previous version
14:38 UTC — Rollback complete, error rate dropping
14:42 UTC — Error rate back to baseline (< 0.1%)
14:45 UTC — Status: RESOLVED

Generating post-mortem...

ROOT CAUSE: Missing null check in order validation after refactoring
            the address normalization module (commit abc123f).

ACTION ITEMS:
1. [PREVENT] Add null-safety lint rule for order module — P0 — Platform team — Mar 22
2. [DETECT] Add canary deployment with 5-min bake time — P1 — DevOps — Mar 29
3. [PROCESS] Update deploy runbook with rollback criteria — P2 — DevOps — Apr 5
```

### Writing a Retrospective Post-Mortem
```
User: /godmode:incident Write a post-mortem for last Tuesday's database incident

Incident: Gathering information for retrospective post-mortem...
What was the incident? When did it occur?
What was the impact? How was it resolved?

<interactive Q&A to build the full post-mortem>
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive incident management |
| `--classify` | Classify severity only |
| `--timeline` | Build/update timeline only |
| `--postmortem` | Generate post-mortem from existing timeline |
| `--retro` | Retrospective mode — build post-mortem from past incident |
| `--actions` | List and track action items from past post-mortems |
| `--metrics` | Show incident metrics dashboard |
| `--template` | Output blank post-mortem template |

## Anti-Patterns

- **Do NOT skip the post-mortem.** Every SEV1 and SEV2 gets a post-mortem. No exceptions. SEV3 gets a lightweight review.
- **Do NOT assign blame.** "John deployed bad code" is never acceptable. "The deployment pipeline lacked integration test gating" is.
- **Do NOT let action items rot.** Track them. Follow up weekly. Escalate if overdue.
- **Do NOT inflate severity.** A cosmetic bug is not SEV1. Over-classification breeds alert fatigue and erodes trust in the system.
- **Do NOT guess at the timeline.** Use logs, monitoring data, and git history. Human memory under stress is unreliable.
- **Do NOT skip "Where We Got Lucky."** Near-misses are free lessons. Capture them before they become real incidents.
