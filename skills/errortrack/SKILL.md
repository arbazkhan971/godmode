---
name: errortrack
description: |
  Error tracking and analysis skill. Activates when teams need to aggregate, categorize, and analyze application errors at scale. Groups stack traces, correlates root causes, tracks error budgets, and identifies trends before they become incidents. Integrates with Sentry, Bugsnag, DataDog, and other error tracking platforms. Triggers on: /godmode:errortrack, "analyze errors", "error budget", "what's causing these exceptions", or when error rates spike.
---

# Errortrack — Error Tracking & Analysis

## When to Activate
- User invokes `/godmode:errortrack`
- User asks about error patterns, spikes, or recurring exceptions
- User says "what errors are we seeing?", "analyze our error rate", "error budget"
- Error rate thresholds are breached in monitoring
- User wants to triage and prioritize error backlog
- Pre-ship check to confirm error budget health

## Workflow

### Step 1: Error Aggregation

Collect and aggregate errors from all available sources:

```
ERROR AGGREGATION:
Source: <Sentry | Bugsnag | DataDog | CloudWatch | application logs | custom>
Time window: <last 1h | 24h | 7d | 30d | custom range>
Environment: <production | staging | all>
Total errors: <count>
Unique error groups: <count>
Error rate: <errors per minute/hour>
Error rate trend: <INCREASING | STABLE | DECREASING>
```

#### Source Integration Commands
```bash
# Sentry — fetch recent issues
sentry-cli issues list --project <project> --status unresolved

# DataDog — query error metrics
curl -s "https://api.datadoghq.com/api/v1/query?query=sum:errors.count{env:production}.as_count()" \
  -H "DD-API-KEY: ${DD_API_KEY}"

# Bugsnag — list error groups
curl -s "https://api.bugsnag.com/projects/<id>/errors?sort=events&direction=desc" \
  -H "Authorization: token ${BUGSNAG_TOKEN}"

# Application logs — aggregate by error type
grep -c "ERROR\|FATAL\|Exception" /var/log/app/*.log

# CloudWatch Logs Insights
aws logs start-query --log-group-name <group> \
  --query 'fields @timestamp, @message | filter @message like /ERROR/ | stats count() by bin(1h)'
```

### Step 2: Error Categorization

Group errors into actionable categories:

```
ERROR CATEGORIES:
┌─────────────────────┬───────┬───────────┬──────────┬──────────────────────┐
│ Category            │ Count │ % of Total│ Trend    │ Top Error            │
├─────────────────────┼───────┼───────────┼──────────┼──────────────────────┤
│ Unhandled Exception │ <N>   │ <N>%      │ <trend>  │ <most common>        │
│ Network/Timeout     │ <N>   │ <N>%      │ <trend>  │ <most common>        │
│ Validation Error    │ <N>   │ <N>%      │ <trend>  │ <most common>        │
│ Auth/Permission     │ <N>   │ <N>%      │ <trend>  │ <most common>        │
│ Database Error      │ <N>   │ <N>%      │ <trend>  │ <most common>        │
│ Third-party/API     │ <N>   │ <N>%      │ <trend>  │ <most common>        │
│ Resource Exhaustion │ <N>   │ <N>%      │ <trend>  │ <most common>        │
│ Business Logic      │ <N>   │ <N>%      │ <trend>  │ <most common>        │
└─────────────────────┴───────┴───────────┴──────────┴──────────────────────┘
```

### Step 3: Stack Trace Grouping

Intelligent grouping of errors by root cause, not just message text:

```
STACK TRACE GROUPS:
Group 1: <normalized error signature>
  Fingerprint: <hash of normalized stack frames>
  Occurrences: <count>
  First seen: <timestamp>
  Last seen: <timestamp>
  Affected versions: <list>
  Affected users: <count or percentage>
  Representative stack trace:
    at <function> (<file>:<line>)
    at <function> (<file>:<line>)
    at <function> (<file>:<line>)
  Variations: <count of distinct but related stack traces>
```

#### Grouping Strategy
```
GROUPING RULES:
1. Normalize stack frames:
   - Strip line numbers (code changes shift lines)
   - Remove generated/minified frames
   - Collapse framework internals to single frame
2. Group by:
   - Exception type + top 3 application frames
   - NOT by error message (messages contain variable data)
3. Merge groups when:
   - Same exception type AND same top application frame
   - Different messages but identical call path
4. Split groups when:
   - Same exception type but different call paths
   - Same message but different root causes
```

### Step 4: Root Cause Correlation

Correlate error groups with system events:

```
ROOT CAUSE CORRELATION:
Error group: <fingerprint>
Correlated events:
  - Deploy: <commit SHA deployed at timestamp — correlation score>
  - Config change: <change description at timestamp — correlation score>
  - Dependency: <upstream service event at timestamp — correlation score>
  - Traffic: <traffic pattern change at timestamp — correlation score>
  - Infrastructure: <infra event at timestamp — correlation score>

Correlation method:
  - Temporal: errors started within <N> minutes of event
  - Causal: deploy touched files in the error stack trace
  - Statistical: error rate change is <N> sigma from baseline
```

#### Correlation Techniques
```
TEMPORAL CORRELATION:
  For each error group, find events within [-30min, +5min] of first occurrence.
  Score = 1.0 if event is within 5 minutes, decaying to 0.0 at 30 minutes.

CODE CORRELATION:
  For each error group, extract file paths from stack trace.
  Cross-reference with recent git commits touching those files.
  Score = files_in_common / files_in_stack_trace.

STATISTICAL CORRELATION:
  Compute baseline error rate (30-day rolling average).
  Flag as anomaly if current rate > baseline + 3 * stddev.
  Correlate anomaly start with nearest system event.
```

### Step 5: Trend Analysis

Analyze error patterns over time to predict issues:

```
TREND ANALYSIS:
Period: <time range analyzed>

Error rate trend:
  Current:  <errors/min>
  1h ago:   <errors/min> (<change%>)
  24h ago:  <errors/min> (<change%>)
  7d ago:   <errors/min> (<change%>)
  30d ago:  <errors/min> (<change%>)

New errors (first seen in period):
  <count> new error groups
  - <error 1>: <first seen timestamp>
  - <error 2>: <first seen timestamp>

Resolved errors (not seen in period):
  <count> error groups resolved
  - <error 1>: <last seen timestamp>

Regression errors (previously resolved, now recurring):
  <count> regressions
  - <error 1>: resolved <date>, recurred <date>

Top growing errors (fastest increasing rate):
  1. <error>: <growth rate>
  2. <error>: <growth rate>
  3. <error>: <growth rate>
```

### Step 6: Error Budgets

Track error budgets against SLO targets:

```
ERROR BUDGET STATUS:
┌────────────────────┬──────────┬──────────┬──────────┬──────────┐
│ SLO                │ Target   │ Current  │ Budget   │ Status   │
├────────────────────┼──────────┼──────────┼──────────┼──────────┤
│ Availability       │ 99.95%   │ <actual> │ <remaining>│ <status>│
│ Latency (p99)      │ < 500ms  │ <actual> │ <remaining>│ <status>│
│ Error rate         │ < 0.1%   │ <actual> │ <remaining>│ <status>│
│ Saturation         │ < 80%    │ <actual> │ <remaining>│ <status>│
└────────────────────┴──────────┴──────────┴──────────┴──────────┘

Budget burn rate:
  Current: <X>x normal burn rate
  At this rate, budget exhausted in: <N days/hours>
  Recommendation: <CONTINUE | SLOW DOWN | FREEZE DEPLOYS>
```

#### Budget Policy
```
ERROR BUDGET POLICY:
Green  (> 50% remaining): Ship freely. Innovate.
Yellow (20-50% remaining): Ship with caution. Extra review on risky changes.
Orange (5-20% remaining): Feature freeze. Bug fixes and reliability only.
Red    (< 5% remaining):  Deploy freeze. All hands on reliability.
Exhausted (0% remaining): Full stop. No deploys until budget replenishes.
```

### Step 7: Triage and Prioritization

Prioritize errors for fixing using a severity matrix:

```
ERROR TRIAGE:
┌────┬─────────────────────────┬──────┬────────────┬──────────┬──────────┐
│ #  │ Error Group             │ Users│ Frequency  │ Severity │ Priority │
├────┼─────────────────────────┼──────┼────────────┼──────────┼──────────┤
│ 1  │ <error description>     │ <N>  │ <per hour> │ HIGH     │ P0       │
│ 2  │ <error description>     │ <N>  │ <per hour> │ HIGH     │ P0       │
│ 3  │ <error description>     │ <N>  │ <per hour> │ MEDIUM   │ P1       │
│ 4  │ <error description>     │ <N>  │ <per hour> │ LOW      │ P2       │
└────┴─────────────────────────┴──────┴────────────┴──────────┴──────────┘

Priority formula:
  Score = (users_affected * 3) + (frequency * 2) + (severity_weight * 1)
  P0: score >= 80  (fix immediately)
  P1: score >= 40  (fix this sprint)
  P2: score >= 10  (schedule for next cycle)
  P3: score < 10   (backlog)
```

### Step 8: Report and Transition
1. Save error analysis as `docs/errors/<date>-error-analysis.md`
2. Commit: `"errortrack: <date> — <unique errors> groups, <budget status> budget (<action>)"`
3. If P0 errors found: "Critical errors detected. Run `/godmode:debug` to investigate, or `/godmode:incident` if this is an active outage."
4. If budget at risk: "Error budget at <status>. Recommend <action>. Run `/godmode:optimize` to improve reliability."
5. If healthy: "Error rates nominal. Budget healthy. Ready to ship."

## Key Behaviors

1. **Group by root cause, not message.** "Connection refused to db-replica-3:5432" and "Connection refused to db-replica-7:5432" are the same error. Group them.
2. **Trend matters more than count.** 1,000 errors/day that has been stable for months is less urgent than 10 errors/day that started 2 hours ago.
3. **Correlate with deploys.** The most common root cause of new errors is new code. Always check what was deployed.
4. **Error budgets drive decisions.** When budget is green, ship fast. When budget is red, stop and fix. No judgment calls needed.
5. **Distinguish signal from noise.** Expected errors (404 on invalid URLs, 401 on expired tokens) are noise. Filter them out before analysis.
6. **Track regressions ruthlessly.** A bug that comes back is a process failure, not just a code failure.

## Example Usage

### Analyzing Error Patterns
```
User: /godmode:errortrack What errors are we seeing in production?

Errortrack: Aggregating errors from the last 24 hours...

ERROR AGGREGATION:
Source: Sentry + application logs
Time window: last 24 hours
Environment: production
Total errors: 12,847
Unique error groups: 23
Error rate: 8.9/min (STABLE)

Top 3 error groups:
1. NullPointerException in OrderService.validate() — 6,200 occurrences (48%)
   First seen: 2 hours ago | Correlated with deploy abc123f
2. TimeoutException in PaymentGateway.charge() — 3,100 occurrences (24%)
   First seen: 14 days ago | Upstream Stripe latency
3. ValidationError in UserController.update() — 1,800 occurrences (14%)
   First seen: 45 days ago | Known issue, low priority

Error budget: 72% remaining (GREEN — ship freely)

Recommendation: Fix #1 immediately (regression from today's deploy).
Monitor #2 (upstream dependency). #3 is stable, schedule for backlog.
```

### Checking Error Budget
```
User: /godmode:errortrack --budget

Errortrack: Calculating error budget status...

ERROR BUDGET STATUS:
Availability SLO (99.95%): Currently 99.97% — 58% budget remaining (GREEN)
Error rate SLO (< 0.1%): Currently 0.04% — 80% budget remaining (GREEN)
Latency p99 SLO (< 500ms): Currently 420ms — 35% budget remaining (YELLOW)

Recommendation: Latency budget trending toward orange.
Investigate slow endpoints with /godmode:optimize --goal "reduce p99 latency".
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full error analysis for production |
| `--budget` | Error budget status only |
| `--trends` | Trend analysis over last 30 days |
| `--triage` | Prioritized triage list only |
| `--group <fingerprint>` | Deep dive into a specific error group |
| `--since <duration>` | Analyze errors since duration (e.g., `--since 4h`) |
| `--env <environment>` | Target specific environment (default: production) |
| `--source <platform>` | Limit to specific platform (sentry, datadog, bugsnag) |
| `--export` | Export analysis as JSON for integration |

## HARD RULES

1. **Never treat all errors equally.** A NullPointerException affecting 10,000 users is not the same as a debug log warning. Always prioritize by user impact and frequency.
2. **Never group errors by message text alone.** Messages contain variable data (IDs, timestamps, hostnames). Group by normalized stack trace structure (top 3 application frames + exception type).
3. **Never ignore the error budget policy.** If budget is red and someone wants to ship a feature, the answer is no. Policy exists to protect users, not to be overridden by urgency.
4. **Never analyze errors without a time window.** "All errors ever" is meaningless. Always specify a time range relevant to the question being asked.
5. **Never skip deploy correlation.** The most common root cause of new errors is new code. Always cross-reference error onset with the most recent deploy.

## Loop Protocol

```
error_group_queue = fetch_unresolved_error_groups(since="24h")
current_iteration = 0

WHILE error_group_queue is not empty:
  batch = error_group_queue.take(5)
  current_iteration += 1

  FOR each error_group in batch:
    1. Normalize stack traces → compute fingerprint
    2. Count: occurrences, affected users, first/last seen
    3. Correlate: find deploys/config changes within [-30min, +5min] of first occurrence
    4. Classify: unhandled exception | network | validation | auth | DB | third-party
    5. Score priority: (users * 3) + (frequency * 2) + (severity * 1)
    6. IF P0 → flag for immediate investigation

  Log: "Iteration {current_iteration}: triaged {batch.length} error groups, {P0_count} P0, {error_group_queue.remaining} remaining"

  IF error_group_queue is empty:
    Compute error budget status
    Generate triage report
    BREAK
```

## Multi-Agent Dispatch

```
PARALLEL AGENTS (3 worktrees):

Agent 1 — "aggregation":
  EnterWorktree("aggregation")
  Fetch errors from all sources (Sentry, DataDog, Bugsnag, CloudWatch, logs)
  Normalize and group by stack trace fingerprint
  Compute per-group metrics: count, affected users, trend
  ExitWorktree()

Agent 2 — "correlation":
  EnterWorktree("correlation")
  Fetch recent deploys (git log, CI/CD history)
  Fetch config changes and infrastructure events
  Compute temporal and code correlation scores for each error group
  Identify regressions (previously resolved, now recurring)
  ExitWorktree()

Agent 3 — "budget-and-triage":
  EnterWorktree("budget-and-triage")
  Calculate error budget status against SLOs (availability, error rate, latency)
  Compute burn rate and time-to-exhaustion
  Generate prioritized triage list with P0/P1/P2/P3 rankings
  Produce trend analysis (new errors, resolved, growing)
  ExitWorktree()

MERGE: Combine aggregation, correlation, and triage into unified error report.
```

## Auto-Detection

```
AUTO-DETECT error tracking context:
  1. Check for error tracking SDK: @sentry/node, @sentry/react, bugsnag-js, dd-trace
  2. Check for log aggregation: elasticsearch, loki, cloudwatch-logs, datadog-log
  3. Scan for SLO definitions: slo.yaml, error-budget config, service-level-objectives
  4. Check CI/CD for deploy tracking: GitHub releases, deploy tags, deployment history API
  5. Detect monitoring: Grafana dashboards, DataDog monitors, PagerDuty integrations
  6. Grep application logs for error rate patterns: ERROR, FATAL, Exception counts

  USE detected context to:
    - Query the correct error tracking platform
    - Correlate with the correct deployment pipeline
    - Reference existing SLO targets for budget calculation
    - Use existing alert channels for P0 notifications
```

## Anti-Patterns

- **Do NOT treat all errors equally.** A NullPointerException affecting 10,000 users is not the same as a debug log warning. Prioritize by impact.
- **Do NOT ignore error budget policy.** If budget is red and someone wants to ship a feature, the answer is no. Policy exists for a reason.
- **Do NOT group by error message alone.** Messages contain variable data (IDs, timestamps, hostnames). Group by stack trace structure.
- **Do NOT forget to filter expected errors.** 404s from bots, 401s from expired tokens, and rate-limit 429s are expected. Filter before analysis.
- **Do NOT analyze without a time window.** "All errors ever" is meaningless. Always specify a time range relevant to the question.
- **Do NOT skip correlation.** An error spike without a correlated event is a mystery. A mystery is harder to fix than a known regression.
