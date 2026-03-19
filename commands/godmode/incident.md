# /godmode:incident

Incident response and blameless post-mortem management. Classifies incidents by severity (SEV1-4), constructs precise timelines, performs root cause analysis, and produces actionable post-mortem documents with tracked action items.

## Usage

```
/godmode:incident                          # Interactive incident management
/godmode:incident --classify               # Classify severity only
/godmode:incident --timeline               # Build/update incident timeline
/godmode:incident --postmortem             # Generate post-mortem from timeline
/godmode:incident --retro                  # Retrospective post-mortem for past incident
/godmode:incident --actions                # List and track action items
/godmode:incident --metrics                # Incident metrics dashboard
/godmode:incident --template               # Output blank post-mortem template
```

## What It Does

1. Classifies incidents by severity (SEV1-4) with defined response times and escalation rules
2. Builds timestamped timelines with evidence (logs, dashboards, deploy records)
3. Quantifies impact (users affected, duration, revenue, SLA consumption)
4. Performs root cause analysis using 5 Whys technique
5. Generates blameless post-mortem documents (What Went Well, What Went Wrong, Where We Got Lucky)
6. Creates prioritized, assigned action items (PREVENT, DETECT, MITIGATE, PROCESS)
7. Tracks incident metrics (MTTD, MTTA, MTTR, MTBF)

## Output
- Post-mortem at `docs/incidents/INC-<ID>-postmortem.md`
- Timeline at `docs/incidents/INC-<ID>-timeline.md`
- Commit: `"incident: INC-<ID> — <severity> — <title> (<status>)"`

## Severity Levels

| Level | Impact | Response Time |
|-------|--------|---------------|
| **SEV1** | Complete outage, data loss, security breach | Immediate (< 15 min) |
| **SEV2** | Major degradation, critical feature broken | < 30 min |
| **SEV3** | Partial degradation, workaround available | < 2 hours |
| **SEV4** | Cosmetic issue, minimal user impact | Next business day |

## Next Step
If resolved: `/godmode:plan` to schedule remediation work.
If active: Focus on mitigation, re-run when resolved.

## Examples

```
/godmode:incident Production API returning 500 errors
/godmode:incident --retro Write post-mortem for Tuesday's database outage
/godmode:incident --actions Show outstanding action items from all post-mortems
/godmode:incident --metrics Show incident frequency and MTTR trends
```
