# /godmode:errortrack

Error tracking and analysis across your application. Aggregates errors from Sentry, Bugsnag, DataDog, and application logs. Groups stack traces by root cause, correlates with deploys, tracks error budgets against SLOs, and prioritizes errors for fixing.

## Usage

```
/godmode:errortrack                        # Full error analysis for production
/godmode:errortrack --budget               # Error budget status only
/godmode:errortrack --trends               # Trend analysis over last 30 days
/godmode:errortrack --triage               # Prioritized triage list only
/godmode:errortrack --group <fingerprint>  # Deep dive into a specific error group
/godmode:errortrack --since 4h             # Analyze errors since duration
/godmode:errortrack --env staging          # Target specific environment
/godmode:errortrack --source sentry        # Limit to specific platform
/godmode:errortrack --export               # Export analysis as JSON
```

## What It Does

1. Aggregates errors from all configured sources (Sentry, Bugsnag, DataDog, CloudWatch, logs)
2. Categorizes errors (unhandled exceptions, network, validation, auth, database, third-party, resource, business logic)
3. Groups stack traces by root cause using normalized frame fingerprinting
4. Correlates error spikes with deploys, config changes, and upstream events
5. Analyzes trends (new errors, resolved, regressions, fastest growing)
6. Tracks error budgets against SLO targets with burn-rate alerts
7. Prioritizes errors using impact-based scoring (users affected, frequency, severity)

## Output
- Error analysis at `docs/errors/<date>-error-analysis.md`
- Commit: `"errortrack: <date> — <N> groups, <budget status> budget (<action>)"`

## Error Budget Policy

| Budget Remaining | Status | Action |
|-----------------|--------|--------|
| > 50% | Green | Ship freely |
| 20-50% | Yellow | Ship with caution |
| 5-20% | Orange | Feature freeze, reliability only |
| < 5% | Red | Deploy freeze |
| 0% | Exhausted | Full stop until budget replenishes |

## Next Step
If P0 errors: `/godmode:debug` to investigate root cause.
If active outage: `/godmode:incident` to manage the incident.
If budget healthy: `/godmode:ship` to deliver.

## Examples

```
/godmode:errortrack                        # Full production error analysis
/godmode:errortrack --budget               # Check SLO budget health
/godmode:errortrack --since 2h             # Errors in the last 2 hours
/godmode:errortrack --trends               # 30-day error trend report
```
