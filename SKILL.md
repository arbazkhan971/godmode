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

## 8. Failure Classification

Every DISCARD must be classified. Append to `.godmode/<skill>-failures.tsv`:

```
round	change	delta%	failure_class	reason	files_touched
```

**Failure classes (use exactly one per discard):**

| Class | When to use |
|--|--|
| measurement_error | Metric command flaky or non-deterministic (stdev > delta) |
| noise | Delta within variance threshold (<0.5%) |
| regression | Change broke something unrelated |
| scope_drift | Change touched files outside assigned scope |
| complexity_tax | Improvement too small for lines added |
| infrastructure | Docker/env/dependency/tooling issue |
| already_tried | Similar approach discarded in last 10 rounds |
| overfitting | Improvement specific to one case, not generalizable |

**Before each IDEATE step, read the last 10 rows of failures.tsv:**
- If >3 failures in the same class: stop trying that approach category.
- If last 2 discards share a class: switch strategy before next attempt.
- Discarded runs still provide learning signal. Never delete failures.tsv.

## 9. Overfitting Prevention

Before every KEEP decision, apply these tests:

1. **Variance test:** Run metric_cmd 3 times. If stdev > |delta|, classify as `noise` and DISCARD.
2. **Generalization test:** "If this exact file/test disappeared, would this change still improve the project?" If NO → DISCARD as `overfitting`.
3. **No task-specific hacks:** Never add hardcoded logic for one specific test case, input, or benchmark. Fix the class of problems, not one instance.
4. **Simplification wins:** Equal metric + fewer lines = always KEEP. This is never overfitting.

## 10. Learning from Discards

Discarded runs still provide learning signal. Never waste a failure.

After every DISCARD:
1. Classify the failure (see Failure Classification above).
2. Append to `.godmode/<skill>-failures.tsv` with reason.
3. Check: has this failure class occurred 3+ times? If yes, that approach category is exhausted — switch strategy entirely.

Before every IDEATE:
1. Read last 10 rows of `<skill>-failures.tsv`.
2. Count failures per class.
3. Avoid the most common failure class. Try the LEAST common instead.
4. If all 8 classes have 2+ failures: escalate to stuck recovery.

The failures log is append-only. It persists across sessions. It is the memory of what NOT to try.

## 11. Environment Isolation

For reproducible metrics, optionally wrap metric_cmd in Docker:

```
metric_cmd_docker: "docker run --rm -v $(pwd):/app -w /app node:20 npm run benchmark"
```

When Docker is available AND metric variance > 5%:
- Build image once, cache dependencies.
- Run each metric measurement in a fresh container.
- Eliminates: cache drift, background process noise, dependency skew.

When Docker is NOT available (default):
- Run metric_cmd 3x, take median.
- Flag warning if variance > 5% between runs.
- Log variance in results.tsv as additional column.

Docker is recommended but never required. The loop works identically either way.
