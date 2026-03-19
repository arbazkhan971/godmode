# /godmode:reliability

Site reliability engineering practices. Defines SLOs/SLIs/SLAs with error budget tracking, configures multi-window burn rate alerts, identifies and eliminates toil, designs sustainable on-call rotations, creates automated runbooks, and establishes incident management processes.

## Usage

```
/godmode:reliability                       # Full SRE assessment and implementation
/godmode:reliability --slo                 # SLO/SLI/SLA definition only
/godmode:reliability --budget              # Error budget calculation and policy
/godmode:reliability --alerts              # Burn rate alert configuration
/godmode:reliability --toil                # Toil identification and elimination plan
/godmode:reliability --oncall              # On-call rotation design
/godmode:reliability --runbook             # Runbook creation for specific alert
/godmode:reliability --incident            # Incident management process design
/godmode:reliability --readiness           # Production readiness review
/godmode:reliability --maturity            # Operational maturity assessment
/godmode:reliability --validate            # Validate SRE practices against checklist
```

## What It Does

1. Assesses service reliability context (business criticality, current monitoring, pain points)
2. Defines SLOs with measurable SLIs (availability, latency, correctness, freshness)
3. Calculates error budgets and establishes budget policies (velocity freeze at thresholds)
4. Configures multi-window burn rate alerts (critical, high, medium, low)
5. Inventories toil and creates prioritized elimination plan (target: < 50% of team time)
6. Designs sustainable on-call rotations with escalation policies and health metrics
7. Creates actionable runbooks for every pageable alert with automation levels
8. Establishes incident management process (severity, roles, communication, post-mortems)
9. Runs production readiness review checklist
10. Assesses operational maturity (L1 Reactive -> L2 Proactive -> L3 Advanced)

## Output
- SLO definitions at `docs/sre/<service>-slos.md`
- Error budget policy at `docs/sre/error-budget-policy.md`
- Alert configuration at `infra/alerts/<service>-burn-rate.yaml`
- Runbooks at `docs/sre/runbooks/<alert-name>.md`
- Production readiness at `docs/sre/<service>-production-readiness.md`
- Commit: `"reliability: <service> -- <SLO targets>, <error budget policy>, <verdict>"`
- Verdict: RELIABLE / NEEDS WORK

## Next Step
If NEEDS WORK: Address gaps in SLOs, alerts, or runbooks, then re-validate.
If RELIABLE: `/godmode:ship` to deploy with confidence.

## Examples

```
/godmode:reliability                       # Full SRE assessment
/godmode:reliability --slo                 # Define SLOs for payment API
/godmode:reliability --budget              # Calculate error budget for main service
/godmode:reliability --toil                # Inventory and plan toil reduction
/godmode:reliability --oncall              # Design on-call rotation for team
/godmode:reliability --runbook             # Create runbook for high-error-rate alert
/godmode:reliability --readiness           # Run production readiness review
```
