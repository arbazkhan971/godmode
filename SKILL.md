---
name: godmode
description: "Turn on Godmode. 126 skills, 7 subagents, zero configuration. Routes to the right skill automatically."
---

@./skills/godmode/SKILL.md

---

# Universal Protocol — governs ALL 126 skills

## 1. The Loop

Every iterative skill follows one loop. No exceptions.

```
round = 0
baseline = measure(metric_cmd)

WHILE goal_not_met AND budget_not_exhausted:
    round += 1
    REVIEW   — read state: in-scope files, last 10 of results.tsv, git log -5
    IDEATE   — propose ONE change (or N parallel agents, each ONE change)
    MODIFY   — implement, then commit immediately
    VERIFY   — run guard (test_cmd && lint_cmd); run metric_cmd 3x, take median
    DECIDE   — keep or discard (rules below)
    LOG      — append to .godmode/<skill>-results.tsv

Do NOT pause to ask. Do NOT wait for confirmation. Loop until goal, budget, or stuck.
```

## 2. Keep / Discard Rules

```
KEEP    if  metric improved  AND  guard passed
DISCARD if  metric worse     OR   guard failed
DISCARD if  lines_added > 5  AND  metric_delta < 0.5%   # complexity tax
DISCARD if  complexity_cost > improvement_magnitude      # simplicity wins
KEEP    if  same metric + fewer lines                    # free simplification
```

On discard: `git reset --hard HEAD~1`. Never leave broken commits.
On keep: update baseline, continue.

## 3. Simplicity Criterion

Concrete thresholds — apply universally:

| Added lines | Required improvement |
|-------------|---------------------|
| 1-5         | any positive delta  |
| 6-20        | >= 1%               |
| 21-50       | >= 3%               |
| 51+         | >= 5%               |

Same metric + fewer lines = always keep. Readability > marginal gains.

## 4. Stopping Conditions

Stop when ANY is true:

- **target_reached** — metric hit goal
- **budget_exhausted** — max rounds/iterations consumed
- **diminishing_returns** — last 3 keeps each < 1% improvement
- **stuck** — 5+ consecutive discards (after recovery attempts)

Log `stop_reason` in session-log.tsv. Always print final summary.

## 5. Stuck Recovery (3-step escalation)

```
Step 1: try OPPOSITE of last approach
Step 2: try RADICAL rewrite of hotspot
Step 3: accept defeat — stop, log "stuck", report best result
```

Never repeat a failed approach. Never loop without changing strategy.

## 6. Logging

All skills log to `.godmode/`:

**Per-skill:** `.godmode/<skill>-results.tsv`
```
round	change	metric_before	metric_after	delta%	status	lines_changed
```

**Session:** `.godmode/session-log.tsv`
```
timestamp	skill	rounds	kept	discarded	final_metric	stop_reason
```

Append only. Never overwrite. Create on first write.

## 7. Execution Rules

1. Detect stack FIRST (see orchestrator). Cache `stack`, `test_cmd`, `lint_cmd`, `build_cmd`.
2. Read `skills/<skill>/SKILL.md` — follow it literally. This protocol overrides on conflict.
3. Commit BEFORE verify. Revert on failure. Zero broken commits in history.
4. Multi-agent: <=5 agents/round, worktree isolation. Merge sequentially, test after each.
5. No worktrees? Sequential branches: `godmode-{skill}-{round}`, merge winner, delete rest.
6. Metric = shell command outputting a single number. No subjective judgment. Ever.
7. `Iterations: N` = exactly N rounds. No number = loop until stopped. Never ask to continue.
8. Chain: think -> plan -> [predict] -> build -> test -> fix -> review -> optimize -> secure -> ship.
