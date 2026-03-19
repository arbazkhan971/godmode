---
name: standup
description: |
  Daily standup and progress tracking skill. Generates automated standup reports from git activity, identifies blockers and escalation paths, tracks sprint burndown, and calculates team velocity. Triggers on: /godmode:standup, "what did I do yesterday", "standup report", "daily update", "sprint progress", or when the godmode orchestrator detects a sprint is in progress.
---

# Standup — Daily Standup & Progress Tracking

## When to Activate
- User invokes `/godmode:standup`
- User says "what did I do yesterday", "daily standup", "sprint progress", "burndown"
- User asks for a progress update or status report
- Sprint is in progress and user needs a daily checkpoint
- Team lead needs velocity metrics or blocker summaries

## Workflow

### Step 1: Gather Git Activity

Analyze recent git history to understand what work has been done:

1. **Collect commits** — Parse `git log` for the last 24 hours (or since last standup)
2. **Collect PRs** — Check for opened, merged, and reviewed pull requests
3. **Collect branches** — Identify active feature branches and their status
4. **Map to work items** — Correlate commits/PRs to issue tracker references (JIRA, Linear, GitHub Issues)

```
GIT ACTIVITY REPORT:
Period: <start_date> to <end_date>
Author: <git user or --all for team>

Commits: <count>
PRs Opened: <count>
PRs Merged: <count>
PRs Reviewed: <count>
Files Changed: <count>
Lines Added/Removed: +<added> / -<removed>
```

### Step 2: Generate Standup Report

Produce a structured standup report following the classic three-question format:

```markdown
# Standup Report — <date>
## Author: <name>

### Yesterday (Completed)
- <completed item 1 — linked to commit/PR>
- <completed item 2 — linked to commit/PR>

### Today (Planned)
- <planned item 1 — linked to issue/branch>
- <planned item 2 — linked to issue/branch>

### Blockers
- <blocker 1 — severity, owner, escalation path>
- <blocker 2 — severity, owner, escalation path>
  (or "No blockers")

### Metrics
- Commits: <N>
- PRs merged: <N>
- Review turnaround: <avg hours>
- Sprint progress: <N>/<total> points (<percent>%)
```

Inference rules for the report:
- **Yesterday** comes from git activity (commits, merges, reviews)
- **Today** comes from assigned issues in current sprint, open branches, and PR review requests
- **Blockers** come from: stale PRs (>24h without review), failing CI, unresolved review comments, dependency issues, and explicit blocker labels

### Step 3: Identify and Escalate Blockers

Automatically detect blockers from signals in the development workflow:

```
BLOCKER DETECTION:
Source              | Signal                         | Severity
--------------------|-------------------------------|----------
PR Review           | PR open > 24h, no reviewer    | MEDIUM
PR Review           | PR open > 48h, no reviewer    | HIGH
CI/CD               | Build failing on main branch  | CRITICAL
CI/CD               | Flaky test blocking merge     | HIGH
Dependencies        | Upstream PR blocking work      | MEDIUM
Dependencies        | External API/service down      | HIGH
Code Review         | Unresolved comments > 48h     | MEDIUM
Sprint              | Task blocked, no assignee     | HIGH
Sprint              | Task in progress > 3 days     | MEDIUM
```

Escalation protocol:
1. **MEDIUM** — Flag in standup report, suggest action
2. **HIGH** — Flag in standup report with recommended owner, suggest Slack/email notification
3. **CRITICAL** — Flag prominently, recommend immediate team attention, link to `/godmode:incident` if production-related

### Step 4: Track Sprint Burndown

Calculate and visualize sprint progress:

```
SPRINT BURNDOWN:
Sprint: <sprint name/number>
Duration: <start_date> to <end_date>
Day: <current_day> of <total_days>

Total Points: <total>
Completed:    <completed> (<percent>%)
In Progress:  <in_progress>
Remaining:    <remaining>

Ideal Burndown:  <expected_remaining> points remaining by today
Actual Burndown: <actual_remaining> points remaining
Variance:        <ahead/behind> by <N> points

Burndown Trend:
Day 1:  ████████████████████ <total>
Day 2:  ██████████████████   <day2>
Day 3:  ████████████████     <day3>
...
Today:  ████████████         <current>
Target: ████████             <ideal>
```

Risk assessment:
- **On Track** — Actual burndown within 10% of ideal
- **At Risk** — Actual burndown 10-25% behind ideal; suggest scope adjustment
- **Off Track** — Actual burndown >25% behind ideal; recommend immediate scope conversation with `/godmode:scope`

### Step 5: Calculate Velocity

Track team velocity across sprints for planning accuracy:

```
VELOCITY REPORT:
Sprint History (last 6 sprints):
Sprint    | Committed | Completed | Velocity | Accuracy
----------|-----------|-----------|----------|----------
Sprint N  | <pts>     | <pts>     | <pts>    | <pct>%
Sprint N-1| <pts>     | <pts>     | <pts>    | <pct>%
...

Rolling Average (3-sprint): <avg> points/sprint
Rolling Average (6-sprint): <avg> points/sprint
Trend: <increasing | stable | decreasing>
Recommended Commitment (next sprint): <recommended> points

Confidence Range:
  Optimistic (P25): <high> points
  Expected (P50):   <mid> points
  Conservative (P75): <low> points
```

Velocity insights:
- Flag sprints with >20% variance from average
- Identify patterns (e.g., velocity drops after large refactors, holidays)
- Recommend sprint commitment based on 3-sprint rolling average
- Account for team capacity changes (PTO, new members)

### Step 6: Generate Team Summary (Optional)

When `--team` flag is used, aggregate individual standups:

```markdown
# Team Standup Summary — <date>

## Completed Yesterday
- [Alice] Merged rate limiter PR (#142), reviewed auth refactor (#138)
- [Bob] Completed database migration scripts, fixed flaky test
- [Carol] Shipped notification service to staging

## Planned Today
- [Alice] Start API versioning implementation
- [Bob] Begin integration tests for migration
- [Carol] Production deploy of notification service

## Team Blockers (2)
1. [HIGH] PR #138 needs second reviewer — blocking auth refactor (Alice, Bob)
2. [MEDIUM] Staging environment flaky — intermittent 503s (Carol)

## Sprint Health
- Day 6 of 10 | 58% complete | Slightly behind (-3 points)
- Velocity projection: 34 points (vs 38 committed)
- Recommendation: Consider descoping notification preferences (5 pts)
```

## Key Behaviors

1. **Evidence-based reporting.** Every item in "Yesterday" is backed by a commit, PR, or review. No self-reported fluff.
2. **Proactive blocker detection.** Don't wait for people to report blockers — detect them from stale PRs, failing CI, and stuck tasks.
3. **Quantified progress.** Use points, percentages, and trends. "Making good progress" is not a metric.
4. **Actionable recommendations.** When burndown is off track, recommend specific scope adjustments. When blockers exist, suggest specific owners and actions.
5. **Historical context.** Velocity is meaningless without history. Always show trends across sprints.
6. **Fast and automated.** The standup report should generate in seconds from git data. No manual input required for "Yesterday."

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Generate individual standup report from git activity |
| `--team` | Generate aggregated team standup summary |
| `--since <date>` | Override the lookback period (default: 24 hours) |
| `--sprint <name>` | Specify sprint for burndown tracking |
| `--velocity` | Show velocity report with historical trends |
| `--burndown` | Show sprint burndown chart |
| `--blockers` | Show only blockers and escalation recommendations |
| `--format <type>` | Output format: `markdown` (default), `slack`, `json` |
| `--author <name>` | Filter activity to a specific author |

## HARD RULES

1. **NEVER fabricate activity.** If git shows no commits, report that honestly. An empty "Yesterday" is a signal, not a failure.
2. **NEVER extrapolate burndown from fewer than 3 days of data.** Early trends are noise, not signal.
3. **NEVER count velocity from incomplete sprints.** Only completed sprints contribute to rolling averages.
4. **ALWAYS back every "Yesterday" item with evidence** -- a commit SHA, PR number, or review link.
5. **ALWAYS classify blockers by severity** (MEDIUM/HIGH/CRITICAL) and include an escalation path.
6. **NEVER treat all blockers equally.** A stale PR is not the same severity as a failing CI build on main.
7. **ALWAYS include the "Planned Today" section**, even if it requires inference from assigned issues and open branches.

## Auto-Detection

On activation, detect the project context for standup generation:

```bash
# Detect git user for filtering
git config user.name 2>/dev/null
git config user.email 2>/dev/null

# Detect recent activity window
git log --oneline --since="24 hours ago" --author="$(git config user.email)" 2>/dev/null | head -20

# Detect sprint/issue tracker references in commits
git log --oneline --since="7 days ago" | grep -oE "(JIRA|LINEAR|GH)-[0-9]+" | sort -u 2>/dev/null

# Detect open PRs
gh pr list --author="@me" --state=open 2>/dev/null || echo "gh CLI not available"

# Detect CI status
gh run list --limit=3 2>/dev/null || echo "gh CLI not available"
```

## Anti-Patterns

- **Do NOT fabricate activity.** If git shows no commits, report that honestly. An empty "Yesterday" is a signal, not a failure.
- **Do NOT ignore failing CI.** A red build on main is always a blocker, even if no one reported it.
- **Do NOT extrapolate burndown from day 1.** Wait until at least day 3 of a sprint before making trend projections.
- **Do NOT count velocity from incomplete sprints.** Only completed sprints contribute to the rolling average.
- **Do NOT treat all blockers equally.** A stale PR is not the same severity as a production outage. Classify and escalate appropriately.
- **Do NOT skip the "Planned Today" section.** Even if it requires inference from assigned issues, the plan section is critical for coordination.

## Chaining

- `/godmode:standup` -> `/godmode:scope` (when burndown shows scope issues)
- `/godmode:standup` -> `/godmode:prioritize` (when blockers need triage)
- `/godmode:standup` -> `/godmode:incident` (when critical blockers indicate production issues)
- `/godmode:standup --velocity` -> `/godmode:plan` (use velocity data for sprint planning)

## Example Usage

### Quick individual standup
```
User: /godmode:standup

Standup: Scanning git activity since 2026-03-18 09:00 UTC...

# Standup Report — 2026-03-19
## Author: arbaz

### Yesterday (Completed)
- Merged PR #87: Add rate limiting middleware (3 commits, +142/-12 lines)
- Reviewed PR #85: Fix user session timeout (2 comments, approved)
- Pushed 2 commits to feat/api-versioning branch

### Today (Planned)
- Continue API versioning (feat/api-versioning, 60% complete)
- Review PR #89: Database connection pooling
- Sprint planning prep (velocity review)

### Blockers
- No blockers

### Metrics
- Commits: 5
- PRs merged: 1
- Review turnaround: 3.2 hours
- Sprint progress: 24/38 points (63%)
```

### Team standup with burndown
```
User: /godmode:standup --team --burndown

Standup: Aggregating team activity and sprint metrics...

[Team summary with individual contributions, blockers, and burndown chart]
```

### Velocity report for sprint planning
```
User: /godmode:standup --velocity

Standup: Calculating velocity from last 6 sprints...

[Velocity table, rolling averages, confidence range, recommended commitment]
```
