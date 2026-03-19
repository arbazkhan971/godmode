# /godmode:report

Automated report generation for development teams. Creates sprint retrospectives, code health reports, performance trend reports, and metric dashboards in PDF, HTML, or Markdown. Collects data from Git, CI/CD, issue trackers, and code analysis tools.

## Usage

```
/godmode:report                                    # Interactive report type selection
/godmode:report --type sprint-retro                # Sprint retrospective report
/godmode:report --type code-health                 # Code health and tech debt report
/godmode:report --type performance                 # Performance trend report
/godmode:report --type metrics                     # Metric dashboard report
/godmode:report --type release                     # Release notes report
/godmode:report --format pdf                       # Output as PDF (default: md)
/godmode:report --format html,pdf                  # Multiple output formats
/godmode:report --period last-sprint               # Report for last sprint
/godmode:report --period 2025-03-01..2025-03-14    # Custom date range
/godmode:report --compare last-quarter             # Compare against previous period
/godmode:report --distribute slack                 # Send report to Slack
/godmode:report --automate                         # Set up automated CI/CD workflow
/godmode:report --template custom-template         # Use a custom report template
/godmode:report --data-only                        # Collect raw data without generating report
/godmode:report --ci                               # CI-friendly output with exit codes
```

## What It Does

1. Identifies report type, audience, time period, and data sources
2. Collects data from Git history, CI/CD pipelines, issue trackers, code quality tools, and performance monitors
3. Transforms and aggregates metrics with period-over-period comparison
4. Populates structured report templates (sprint retro, code health, performance, metrics)
5. Generates reports in Markdown, HTML, or PDF format
6. Configures automated report generation via CI/CD workflows
7. Distributes reports via Slack, email, S3, or Confluence

## Output
- Report at `docs/reports/<report-name>-<date>.<format>`
- Report template at `docs/reports/templates/<template-name>.<ext>`
- Data snapshot at `docs/reports/data/<report-name>-<date>.json`
- CI/CD workflow at `.github/workflows/report-<type>.yml` (if automated)
- Commit: `"report: <type> report — <period>, <N> metrics, <format> output"`

## Key Principles

1. **Data-driven** — every claim is backed by collected data, no opinions or guesses
2. **Actionable** — every report includes specific next steps and recommendations
3. **Trend over snapshot** — show how metrics change over time, not just current values
4. **Automate collection** — humans analyze and recommend, machines collect and format
5. **Right audience, right depth** — executive reports: KPIs; engineering reports: detailed metrics

## Next Step
After report: `/godmode:chart` for custom visualizations, `/godmode:optimize` to act on recommendations, or `/godmode:plan` to convert action items into tasks.

## Examples

```
/godmode:report --type sprint-retro                # Sprint retrospective
/godmode:report --type code-health --format pdf    # Code health as PDF
/godmode:report --type performance --period last-month  # Monthly performance
/godmode:report --automate --type metrics          # Set up automated metrics report
```
