# /godmode:observe

Set up full observability: metrics, structured logging, distributed tracing, alert rules, SLO/SLI definitions, and dashboards.

## Usage

```
/godmode:observe                        # Full observability assessment and setup
/godmode:observe --metrics              # Set up metrics instrumentation only
/godmode:observe --logging              # Set up structured logging only
/godmode:observe --tracing              # Set up distributed tracing only
/godmode:observe --alerts               # Design alert rules only
/godmode:observe --slos                 # Define SLO/SLI framework only
/godmode:observe --dashboard            # Design monitoring dashboards only
/godmode:observe --audit                # Assess current observability coverage
/godmode:observe --tool prometheus      # Target specific tool
```

## What It Does

1. Assesses current observability across three pillars (metrics, logs, traces)
2. Designs metrics using RED method (requests) and USE method (resources)
3. Configures structured JSON logging with correlation IDs
4. Instruments distributed tracing with OpenTelemetry
5. Defines SLOs with error budget tracking and burn rate alerts
6. Creates actionable alert rules with runbook links
7. Designs dashboards following the Four Golden Signals

## Output
- Observability configuration in `monitoring/` directory
- Alert rules as `monitoring/alerts.yaml`
- Dashboard definitions in `monitoring/dashboards/`
- SLO definitions as `monitoring/slos.yaml`
- Commit: `"observe: <description> — <pillars covered> (<N> metrics, <N> alerts)"`

## Next Step
After observability is configured: `/godmode:ship` to deploy with confidence, or `/godmode:secure` for security audit.

## Examples

```
/godmode:observe                        # Full observability stack
/godmode:observe --metrics --tool datadog  # DataDog metrics setup
/godmode:observe --slos                 # Define SLOs for the service
/godmode:observe --alerts               # Create alert rules
```
