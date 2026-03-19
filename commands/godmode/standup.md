# /godmode:standup

Generate automated standup reports from git activity. Tracks sprint burndown, calculates velocity, and identifies blockers with escalation recommendations.

## Usage

```
/godmode:standup                              # Individual standup from git activity
/godmode:standup --team                       # Aggregated team standup summary
/godmode:standup --since 2026-03-17           # Override lookback period
/godmode:standup --sprint "Sprint 14"         # Specify sprint for burndown
/godmode:standup --velocity                   # Velocity report with trends
/godmode:standup --burndown                   # Sprint burndown chart
/godmode:standup --blockers                   # Show only blockers and escalations
/godmode:standup --format slack               # Output in Slack-friendly format
/godmode:standup --author alice               # Filter to specific author
```

## What It Does

1. **Gather** — Scans git log, PRs, branches, and issue references for the lookback period
2. **Report** — Generates structured standup (Yesterday / Today / Blockers / Metrics)
3. **Detect Blockers** — Identifies stale PRs, failing CI, stuck tasks, and dependency issues
4. **Burndown** — Tracks sprint progress against ideal burndown with risk assessment
5. **Velocity** — Calculates rolling averages across sprints with confidence ranges

## Output
- Standup report in markdown (or Slack/JSON format)
- Blocker list with severity and escalation recommendations
- Sprint burndown chart with on-track/at-risk/off-track assessment
- Velocity trends with recommended sprint commitment

## Next Step
After standup: `/godmode:prioritize` to triage blockers, or `/godmode:scope` to adjust sprint scope.

## Examples

```
/godmode:standup                              # Quick daily standup
/godmode:standup --team --burndown            # Team summary with burndown
/godmode:standup --velocity                   # Sprint planning velocity data
/godmode:standup --blockers --format slack    # Post blockers to Slack
```
