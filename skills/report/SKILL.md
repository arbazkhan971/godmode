---
name: report
description: |
  Report generation skill. Activates when users need to create automated development reports in PDF, HTML, or Markdown. Generates metric dashboards, sprint retrospective reports, code health reports, performance trend reports, and custom project reports. Produces structured, data-driven documents with charts, tables, and actionable summaries. Triggers on: /godmode:report, "generate a report", "create a summary", "sprint retro", "code health check", or when the orchestrator detects reporting needs.
---

# Report — Report Generation

## When to Activate
- User invokes `/godmode:report`
- User says "generate a report", "create a summary", "write a status update"
- User says "sprint retro", "retrospective", "code health", "performance report"
- When a sprint ends and retrospective data needs compiling
- When `/godmode:optimize` completes and results need summarizing
- When stakeholders need project status or metric dashboards

## Workflow

### Step 1: Report Discovery
Understand what report is needed, for whom, and from what data:

```
REPORT DISCOVERY:
Project: <name and purpose>
Report type: <sprint-retro | code-health | performance | metric-dashboard | release | custom>
Audience: <engineering team | management | stakeholders | external clients>
Format: <PDF | HTML | Markdown | all>
Time period: <sprint N | last 2 weeks | Q1 2025 | custom date range>
Data sources:
  - Git history: <commits, PRs, branches>
  - CI/CD: <build times, failure rates, deployment frequency>
  - Issue tracker: <tickets completed, velocity, burndown>
  - Code analysis: <coverage, complexity, lint errors, tech debt>
  - Performance: <response times, error rates, uptime>
  - Custom: <user-provided metrics or data files>
Frequency: <one-time | weekly | per-sprint | monthly | quarterly>
Distribution: <email | Slack | S3 | Confluence | static site>
```

If the user hasn't specified, ask: "What kind of report do you need? Who will read it?"

### Step 2: Data Collection
Gather data from all relevant sources:

```
DATA COLLECTION:
┌──────────────────────────────┬──────────────────────────────────────────┐
│  Source                      │  Data Points Collected                   │
├──────────────────────────────┼──────────────────────────────────────────┤
│  Git                         │  Commits: <N>                            │
│                              │  PRs merged: <N>                         │
│                              │  PRs open: <N>                           │
│                              │  Contributors: <N>                       │
│                              │  Files changed: <N>                      │
│                              │  Lines added/removed: +<N> / -<N>       │
├──────────────────────────────┼──────────────────────────────────────────┤
│  CI/CD                       │  Builds: <N> (pass: <N>, fail: <N>)     │
│                              │  Avg build time: <duration>              │
│                              │  Deployments: <N>                        │
│                              │  Rollbacks: <N>                          │
│                              │  MTTR: <duration>                        │
├──────────────────────────────┼──────────────────────────────────────────┤
│  Issue Tracker               │  Created: <N>                            │
│                              │  Completed: <N>                          │
│                              │  Velocity: <story points>                │
│                              │  Cycle time: <avg duration>              │
│                              │  Bugs: <N created> / <N fixed>          │
├──────────────────────────────┼──────────────────────────────────────────┤
│  Code Quality                │  Test coverage: <pct>                    │
│                              │  Lint errors: <N>                        │
│                              │  Cyclomatic complexity: <avg>            │
│                              │  Tech debt: <hours estimated>            │
│                              │  Duplicated lines: <pct>                 │
├──────────────────────────────┼──────────────────────────────────────────┤
│  Performance                 │  P50 latency: <ms>                       │
│                              │  P99 latency: <ms>                       │
│                              │  Error rate: <pct>                       │
│                              │  Uptime: <pct>                           │
│                              │  Apdex score: <value>                    │
└──────────────────────────────┴──────────────────────────────────────────┘

DATA COLLECTION STATUS: <COMPLETE | PARTIAL — missing sources listed>
```

#### Git Data Collection Commands
```bash
# Commits in date range
git log --after="<start>" --before="<end>" --oneline | wc -l

# Contributors
git log --after="<start>" --before="<end>" --format='%aN' | sort -u | wc -l

# Lines changed
git log --after="<start>" --before="<end>" --stat --format="" | tail -1

# Files most frequently changed (hotspots)
git log --after="<start>" --before="<end>" --name-only --format="" | sort | uniq -c | sort -rn | head -20

# PR merge frequency (GitHub)
gh pr list --state merged --search "merged:>=$START_DATE" --json number,title,mergedAt
```

### Step 3: Report Templates
Select and populate the appropriate report template:

#### Sprint Retrospective Report
```
SPRINT RETROSPECTIVE REPORT
Sprint: <sprint name/number>
Period: <start date> — <end date>
Team: <team name>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EXECUTIVE SUMMARY
<2-3 sentence summary of sprint outcomes>

VELOCITY & DELIVERY
  Planned: <N story points>
  Completed: <N story points> (<pct>% of planned)
  Carried over: <N story points>
  Velocity trend: <increasing | stable | decreasing> (3-sprint average: <N>)

  ┌─────────────────────────────────────────────────────────────┐
  │  Sprint velocity (last 6 sprints — bar chart)              │
  │  ████████████ 42                                            │
  │  ██████████████ 48                                          │
  │  ███████████ 38                                             │
  │  █████████████ 45                                           │
  │  ████████████████ 52                                        │
  │  ██████████████ 47  <- current                              │
  └─────────────────────────────────────────────────────────────┘

WHAT WE SHIPPED
  1. <feature/fix> — <brief description> (<ticket ID>)
  2. <feature/fix> — <brief description> (<ticket ID>)
  3. <feature/fix> — <brief description> (<ticket ID>)

WHAT WENT WELL
  - <positive observation with evidence>
  - <positive observation with evidence>
  - <positive observation with evidence>

WHAT NEEDS IMPROVEMENT
  - <issue with evidence and impact>
  - <issue with evidence and impact>
  - <issue with evidence and impact>

ACTION ITEMS
  1. <action> — Owner: <name> — Due: <date>
  2. <action> — Owner: <name> — Due: <date>
  3. <action> — Owner: <name> — Due: <date>

METRICS
  PRs merged: <N> (avg review time: <duration>)
  Build success rate: <pct>%
  Test coverage: <pct>% (delta: <+/- N>%)
  Bugs introduced: <N> | Bugs fixed: <N>
  Deployment count: <N>
```

#### Code Health Report
```
CODE HEALTH REPORT
Project: <project name>
Date: <report date>
Period: <date range>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

HEALTH SCORE: <N>/100 (<EXCELLENT | GOOD | FAIR | POOR | CRITICAL>)

BREAKDOWN:
  Test coverage:        <pct>% (<trend arrow> from <previous pct>%)     [<score>/25]
  Code complexity:      avg <N> (<trend arrow> from <previous>)          [<score>/25]
  Tech debt:            <N> hours (<trend arrow> from <previous>)        [<score>/25]
  Dependency health:    <N> outdated, <N> vulnerable                     [<score>/25]

TEST COVERAGE:
  Overall: <pct>%
  ┌──────────────────┬───────────┬───────────┬───────────┐
  │  Module          │  Coverage │  Trend    │  Status   │
  ├──────────────────┼───────────┼───────────┼───────────┤
  │  <module 1>      │  <pct>%   │  <arrow>  │  OK|WARN  │
  │  <module 2>      │  <pct>%   │  <arrow>  │  OK|WARN  │
  │  <module 3>      │  <pct>%   │  <arrow>  │  OK|WARN  │
  └──────────────────┴───────────┴───────────┴───────────┘
  Uncovered hotspots: <list of frequently-changed files with low coverage>

COMPLEXITY HOTSPOTS:
  ┌──────────────────────────────────┬─────────────┬──────────────┐
  │  File                            │  Complexity │  Suggestion  │
  ├──────────────────────────────────┼─────────────┼──────────────┤
  │  <file path>                     │  <N>        │  <refactor>  │
  │  <file path>                     │  <N>        │  <split>     │
  └──────────────────────────────────┴─────────────┴──────────────┘

DEPENDENCY AUDIT:
  Total dependencies: <N>
  Outdated: <N> (major: <N>, minor: <N>, patch: <N>)
  Vulnerable: <N> (critical: <N>, high: <N>, moderate: <N>)
  Unused: <N> (candidates for removal)

TECH DEBT INVENTORY:
  Total estimated: <N> hours
  Categories:
    - TODO/FIXME comments: <N> across <M> files
    - Deprecated API usage: <N> instances
    - Missing tests for critical paths: <N>
    - Outdated dependencies: <N> hours to update
  Priority items:
    1. <highest priority debt item with justification>
    2. <second priority debt item with justification>
    3. <third priority debt item with justification>

RECOMMENDATIONS:
  1. <actionable recommendation with expected impact>
  2. <actionable recommendation with expected impact>
  3. <actionable recommendation with expected impact>
```

#### Performance Trend Report
```
PERFORMANCE TREND REPORT
Service: <service name>
Period: <date range>
Environment: <production | staging>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUMMARY
  Overall health: <HEALTHY | DEGRADED | CRITICAL>
  SLA compliance: <pct>% (target: <pct>%)

LATENCY TRENDS:
  ┌──────────────────────────────────────────────────────────┐
  │  P50: <current ms> (trend: <arrow> <pct>% from last period)  │
  │  P95: <current ms> (trend: <arrow> <pct>% from last period)  │
  │  P99: <current ms> (trend: <arrow> <pct>% from last period)  │
  └──────────────────────────────────────────────────────────┘

  Slowest endpoints:
  ┌──────────────────────────────────┬──────────┬──────────┬──────────┐
  │  Endpoint                        │  P50     │  P99     │  RPS     │
  ├──────────────────────────────────┼──────────┼──────────┼──────────┤
  │  <endpoint 1>                    │  <ms>    │  <ms>    │  <N>     │
  │  <endpoint 2>                    │  <ms>    │  <ms>    │  <N>     │
  │  <endpoint 3>                    │  <ms>    │  <ms>    │  <N>     │
  └──────────────────────────────────┴──────────┴──────────┴──────────┘

ERROR RATES:
  Current: <pct>% (target: < <threshold>%)
  Trend: <arrow> <pct>% from last period
  Top errors:
    1. <error type>: <count> (<pct>% of total errors)
    2. <error type>: <count> (<pct>% of total errors)
    3. <error type>: <count> (<pct>% of total errors)

THROUGHPUT:
  Avg RPS: <N> (peak: <N>)
  Total requests: <N>
  Success rate: <pct>%

INFRASTRUCTURE:
  CPU utilization: avg <pct>%, peak <pct>%
  Memory utilization: avg <pct>%, peak <pct>%
  Disk I/O: <read/write rates>
  Network: <in/out bandwidth>

INCIDENTS:
  Total: <N> (P1: <N>, P2: <N>, P3: <N>)
  MTTR: <duration>
  MTTD: <duration>
  Notable:
    - <incident summary with duration and impact>

RECOMMENDATIONS:
  1. <performance optimization recommendation with expected impact>
  2. <capacity planning recommendation>
  3. <reliability improvement recommendation>
```

#### Metric Dashboard Report
```
METRIC DASHBOARD
Project: <project name>
Generated: <timestamp>
Period: <date range>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

KEY METRICS:
┌──────────────────┬──────────────┬──────────────┬──────────────┐
│  Metric          │  Current     │  Previous    │  Change      │
├──────────────────┼──────────────┼──────────────┼──────────────┤
│  <metric 1>      │  <value>     │  <value>     │  <delta>     │
│  <metric 2>      │  <value>     │  <value>     │  <delta>     │
│  <metric 3>      │  <value>     │  <value>     │  <delta>     │
│  <metric 4>      │  <value>     │  <value>     │  <delta>     │
└──────────────────┴──────────────┴──────────────┴──────────────┘

DORA METRICS (if applicable):
  Deployment frequency: <daily | weekly | monthly>
  Lead time for changes: <duration>
  Change failure rate: <pct>%
  Mean time to restore: <duration>
  DORA level: <Elite | High | Medium | Low>

CUSTOM METRICS:
  <project-specific metrics as defined by the team>
```

### Step 4: Report Generation
Generate the report in the requested format(s):

```
REPORT GENERATION:
┌──────────────┬──────────────────────────────────────────────────────────┐
│  Format      │  Implementation                                         │
├──────────────┼──────────────────────────────────────────────────────────┤
│  Markdown    │  Direct template rendering to .md file                  │
│              │  Charts: embedded as Mermaid diagrams or ASCII art       │
│              │  Tables: GitHub-flavored Markdown tables                 │
│              │  Output: docs/reports/<report-name>-<date>.md           │
├──────────────┼──────────────────────────────────────────────────────────┤
│  HTML        │  Template engine (Handlebars, EJS, or Nunjucks)         │
│              │  Charts: embedded Chart.js or inline SVG                 │
│              │  Styling: inline CSS for email compatibility             │
│              │  Output: docs/reports/<report-name>-<date>.html         │
├──────────────┼──────────────────────────────────────────────────────────┤
│  PDF         │  Puppeteer/Playwright rendering from HTML template      │
│              │  Charts: rendered as static images or inline SVG         │
│              │  Layout: print-optimized CSS (@media print)             │
│              │  Output: docs/reports/<report-name>-<date>.pdf          │
└──────────────┴──────────────────────────────────────────────────────────┘
```

#### Report Generation Scripts
```typescript
// Markdown report generator
function generateMarkdownReport(data: ReportData, template: string): string {
  // Render template with data
  // Generate ASCII chart representations
  // Format tables with proper alignment
  // Write to docs/reports/
}

// HTML report generator
function generateHTMLReport(data: ReportData, template: string): string {
  // Render HTML template with data
  // Embed Chart.js charts with inline data
  // Apply inline CSS for email compatibility
  // Write to docs/reports/
}

// PDF report generator (via Puppeteer)
async function generatePDFReport(htmlPath: string, outputPath: string): Promise<void> {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto(`file://${htmlPath}`);
  await page.pdf({
    path: outputPath,
    format: 'A4',
    printBackground: true,
    margin: { top: '1cm', right: '1cm', bottom: '1cm', left: '1cm' }
  });
  await browser.close();
}
```

### Step 5: Automation Setup
Configure automated report generation:

```
AUTOMATION:
Schedule: <cron expression — e.g., "0 9 * * 1" for Monday 9 AM>
Trigger: <schedule | sprint-end | release | manual>

Pipeline:
  1. Collect data from all configured sources
  2. Transform and aggregate metrics
  3. Generate report in configured format(s)
  4. Distribute via configured channel(s)

Distribution:
  - Slack: POST to <channel> with report summary + link to full report
  - Email: Send via <provider> to <distribution list>
  - S3/GCS: Upload to <bucket>/<path>
  - Confluence: Create/update page via API
  - GitHub Pages: Commit to gh-pages branch

CI/CD Integration:
  # GitHub Actions example
  name: Weekly Report
  on:
    schedule:
      - cron: '0 9 * * 1'  # Monday 9 AM UTC
    workflow_dispatch: {}     # Manual trigger

  jobs:
    generate-report:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - run: npm ci
        - run: npm run report:generate -- --type sprint-retro --format html,pdf
        - run: npm run report:distribute -- --channel slack,email
```

### Step 6: Validation & Delivery
Validate the report and deliver:

```
REPORT VALIDATION:
┌──────────────────────────────────────────────────────┬──────────────┐
│  Check                                               │  Status      │
├──────────────────────────────────────────────────────┼──────────────┤
│  All data sources responded successfully             │  PASS | FAIL │
│  Date range is correct and consistent                │  PASS | FAIL │
│  Metrics match source data (spot-check 3 values)     │  PASS | FAIL │
│  Charts render correctly in target format            │  PASS | FAIL │
│  Tables are formatted and aligned                    │  PASS | FAIL │
│  No placeholder text remaining (<template tags>)     │  PASS | FAIL │
│  Report file size is reasonable (< 10MB for PDF)     │  PASS | FAIL │
│  Distribution channels are configured and reachable  │  PASS | FAIL │
│  Previous report available for comparison            │  PASS | FAIL │
└──────────────────────────────────────────────────────┴──────────────┘

VERDICT: <PASS | NEEDS REVISION>
```

```
REPORT COMPLETE:

Artifacts:
- Report: docs/reports/<report-name>-<date>.<format>
- Template: docs/reports/templates/<template-name>.<ext>
- Data snapshot: docs/reports/data/<report-name>-<date>.json
- Automation: .github/workflows/report-<type>.yml (if automated)

Report type: <type>
Format: <format(s)>
Period: <date range>
Data sources: <N> sources, <N> metrics collected
Distribution: <channel(s)>

Next steps:
-> /godmode:chart — Create custom visualizations for the report
-> /godmode:optimize — Act on report recommendations
-> /godmode:plan — Convert action items into sprint tasks
```

Commit: `"report: <type> report — <period>, <N> metrics, <format> output"`

## Key Behaviors

1. **Data-driven, not opinion-driven.** Every claim in a report must be backed by collected data. No guessing, no vibes-based assessments.
2. **Actionable recommendations.** Every report includes specific, actionable next steps. A report without action items is just a status update.
3. **Consistent formatting.** Reports of the same type always follow the same template. Stakeholders should know where to find information.
4. **Trend over snapshot.** Show how metrics are changing, not just current values. Context from previous periods is essential.
5. **Automate the boring parts.** Data collection and formatting should be automated. Human effort goes into analysis and recommendations.
6. **Right audience, right depth.** Executive reports: KPIs and actions. Engineering reports: detailed metrics and code-level findings.

## Example Usage

### Sprint Retrospective
```
User: /godmode:report Generate a sprint retrospective for Sprint 47

Report: Collecting data for Sprint 47 (Mar 3 - Mar 14, 2025)...

DATA COLLECTION:
  Git: 127 commits, 23 PRs merged, 5 contributors
  Jira: 18 tickets completed (42 story points), 3 carried over
  CI: 89 builds (94% success rate), avg build time 4m 12s
  Coverage: 78.3% (+1.2% from Sprint 46)

Generating sprint retrospective report...

SPRINT RETROSPECTIVE REPORT
Sprint 47 | Mar 3 - Mar 14, 2025

Velocity: 42 points (planned: 45, 93% completion)
Trend: stable (3-sprint avg: 41.3)

What we shipped:
  1. User notification preferences (PROJ-234)
  2. API rate limiting middleware (PROJ-256)
  3. Dashboard performance optimization (PROJ-261)

Report generated: docs/reports/sprint-47-retro-2025-03-14.md
```

### Code Health Report
```
User: /godmode:report Create a code health report

Report: Analyzing codebase health...

CODE HEALTH SCORE: 72/100 (GOOD)

  Test coverage: 78.3%     [19/25]
  Complexity: avg 8.2      [20/25]
  Tech debt: 45 hours      [16/25]
  Dependencies: 3 vulnerable [17/25]

Top recommendations:
  1. Increase coverage in src/payments/ (currently 52%)
  2. Refactor src/api/handlers/orders.ts (complexity: 34)
  3. Update 3 vulnerable dependencies (2 high, 1 moderate)

Report: docs/reports/code-health-2025-03-14.md
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive report type selection and generation |
| `--type <report>` | Report type: `sprint-retro`, `code-health`, `performance`, `metrics`, `release`, `custom` |
| `--format <format>` | Output format: `md`, `html`, `pdf`, `all` (default: `md`) |
| `--period <range>` | Date range: `last-sprint`, `last-week`, `last-month`, `last-quarter`, `<start>..<end>` |
| `--compare <period>` | Compare against a previous period |
| `--distribute <channel>` | Send report: `slack`, `email`, `s3`, `confluence` |
| `--automate` | Set up automated report generation (CI/CD workflow) |
| `--template <name>` | Use a custom report template |
| `--data-only` | Collect and output raw data without generating report |
| `--ci` | CI-friendly output (exit code, machine-readable summary) |

## Anti-Patterns

- **Do NOT generate reports without verifying data accuracy.** Spot-check at least 3 metrics against source data. Wrong numbers destroy trust.
- **Do NOT include metrics without context.** "Test coverage: 78%" means nothing without trend, target, and comparison.
- **Do NOT create reports that nobody reads.** If a report has no audience or action items, it should not exist.
- **Do NOT hardcode date ranges.** Reports must be parameterized by time period. Hardcoded dates break automation.
- **Do NOT skip the executive summary.** The first section must answer: "What happened? Is it good or bad? What should we do?"
- **Do NOT include raw data dumps.** Reports summarize and interpret. Link to raw data for those who want details.
- **Do NOT generate reports without templates.** Consistency across reports builds trust. Ad-hoc formatting creates confusion.
- **Do NOT rely on a single data source.** Cross-reference metrics from multiple sources. Discrepancies indicate data quality issues.
