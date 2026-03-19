# /godmode:slo

Service level objectives, SLIs, error budgets, and reliability targets. Defines measurable SLIs, sets SLO targets with rolling windows, calculates error budgets, configures multi-window multi-burn-rate alerts, establishes error budget policies, gates releases on budget health, builds SLO dashboards, and sets up review cadence.

## Usage

```
/godmode:slo                                   # Full SLO definition and implementation
/godmode:slo --sli                             # SLI selection and measurement guidance
/godmode:slo --target                          # SLO target setting guidance
/godmode:slo --budget                          # Error budget calculation and status
/godmode:slo --alerts                          # Multi-window burn rate alert configuration
/godmode:slo --policy                          # Error budget policy definition
/godmode:slo --gate                            # SLO-based release gating configuration
/godmode:slo --composite                       # Composite SLO for user journeys
/godmode:slo --dashboard                       # SLO dashboard setup (Grafana/Datadog)
/godmode:slo --review                          # SLO review template and cadence
/godmode:slo --validate                        # Validate SLO implementation
```

## What It Does

1. Assesses service context (type, criticality, traffic pattern, dependencies)
2. Clarifies SLA vs SLO vs SLI hierarchy and relationships
3. Selects appropriate SLIs by service type (API, pipeline, storage, streaming)
4. Defines SLO targets with rolling or calendar windows
5. Calculates error budgets (time-based and request-based)
6. Configures multi-window multi-burn-rate alerts (Google SRE Workbook pattern)
7. Establishes error budget policy (velocity decisions tied to budget health)
8. Sets up SLO-based release gating (block deploys when budget is low)
9. Defines composite SLOs for user journeys spanning multiple services
10. Creates SLO dashboards (Grafana, Datadog) with budget tracking
11. Establishes SLO review cadence (weekly, monthly, quarterly)

## Output
- SLO definitions at `docs/slo/<service>-slo.md`
- Error budget policy at `docs/slo/error-budget-policy.md`
- Burn rate alert rules at `infra/alerts/<service>-slo-burn-rate.yaml`
- Recording rules at `infra/prometheus/<service>-slo-recording-rules.yaml`
- Dashboard config at `infra/dashboards/<service>-slo-dashboard.json`
- Release gate config at `ci/<service>-slo-release-gate.yaml`
- Commit: `"slo: <service> -- <targets>, <error budget policy>, <verdict>"`
- Verdict: SLO READY / NEEDS WORK

## Next Step
If NEEDS WORK: Address gaps in SLI selection, alert config, or policy, then re-validate.
If SLO READY: `/godmode:observe` to implement SLI monitoring, or `/godmode:ship` to deploy with release gating.

## Examples

```
/godmode:slo                                   # Full SLO implementation for a service
/godmode:slo --sli                             # Choose SLIs for a data pipeline
/godmode:slo --budget                          # Check error budget status for checkout service
/godmode:slo --alerts                          # Configure burn rate alerts for API gateway
/godmode:slo --composite                       # Define composite SLO for purchase journey
/godmode:slo --dashboard                       # Set up Grafana SLO dashboard
/godmode:slo --gate                            # Add SLO-based release gating to CI/CD
/godmode:slo --review                          # Set up quarterly SLO review process
```
