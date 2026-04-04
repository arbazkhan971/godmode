---
name: optimize
description: Autonomous optimization loop. 3 parallel agents
  per round, mechanical metrics only.
---

## Activate When
- `/godmode:optimize`, "make faster", "improve", "optimize"

## Setup (once)
Ask: Goal, Metric (`cmd` -> single number),
Direction (up/down), Scope (file globs).

### Baseline
```bash
# Run metric_cmd 3 times, take median
metric_cmd; metric_cmd; metric_cmd
```
IF variance >5%: 10 runs, trim outliers, median of 8.
If metric variance > 5% across 3 runs: consider Docker isolation for deterministic measurement.
Log variance alongside metric in results.tsv.
Commit baseline as iteration 0.

### Guard vs Metric
```
METRIC: shell cmd -> single number (target)
GUARD:  test_cmd && lint_cmd && build_cmd (must pass)
Change must BOTH improve metric AND pass guard.
Guard failure -> DISCARD (terminal, counts against
  2-rework cap).
```

## Session Resume
On start: check `.godmode/session-state.json`. If resuming (`stop_reason` is null), restore baseline/round/approach_history and skip to saved round.
After each iteration: atomically save state (round, baseline, current_best, last_kept_commit, consecutive_discards, approach_history, failure_classes) to `.godmode/session-state.json`.
On completion: set `stop_reason` in the state file.

## Lessons Integration
Before IDEATE: read `.godmode/lessons.md` for optimization-specific insights.
After session: append lessons (e.g., "Metric X is I/O-bound, not CPU-bound" or "Table Y too small for index benefit").

## The Loop
```
WHILE current_round < max_rounds:
  1. REVIEW: in-scope files + results.tsv + git log
     Read last 10 rows of optimize-failures.tsv before proposing next change. Avoid repeating the most common failure class.
     Profile first: identify hotspot before changing.
     IF bounded AND remaining < 3: exploit only.
  2. HYPOTHESIZE: 3 independent untested changes
     (algorithmic > caching > structural)
     IF >5 consecutive discards: STUCK RECOVERY
  3. DISPATCH 3 AGENTS (parallel, worktrees)
     Each: ONE change -> commit -> guard -> 3x verify
     Timeout: 5 min per agent. Exceeded -> kill+discard.
  4. PICK WINNER: largest improvement
     improved + guard pass -> cherry-pick, update baseline
     improved + guard fail -> rework (max 2), else discard
     no improvement -> discard all
  5. LOG to .godmode/optimize-results.tsv
  6. STATUS every 5 rounds.
     Last 3 keeps <1% -> radical -> compound -> STOP
STOP: target | max rounds | diminishing | guard broken
```

## Parallel Hypothesis Mode

When stuck or when the search space is wide, test multiple approaches simultaneously:

1. IDEATE 3 different optimization strategies (not 3 variations — 3 fundamentally different approaches).
2. Dispatch 3 agents, each in a separate worktree, each implementing one strategy.
3. All 3 run the same metric_cmd.
4. KEEP only the best result. DISCARD the other 2.
5. If all 3 are worse than baseline: discard all, log "parallel_exhausted".

Trigger: after 2 consecutive single-agent discards, switch to parallel mode.
Return to single-agent mode after a successful parallel keep.

Log to results.tsv: `round | agent_1_change | agent_1_delta | agent_2_change | agent_2_delta | agent_3_change | agent_3_delta | winner | status`

## Stuck Recovery
```
IF >5 consecutive discards:
  0. DIAGNOSE: Re-read ALL in-scope files (stale model)
     On 3+ consecutive discards: PAUSE. Read the last 3 diffs and test outputs.
     Write a 2-sentence diagnosis explaining the shared failure pattern.
     Use the diagnosis to pick a fundamentally different approach.
     Log the diagnosis to optimize-failures.tsv in the reason column.
  1. Try OPPOSITE approach (informed by diagnosis)
  2. If opposite fails -> radical rewrite (informed by diagnosis)
  3. If radical fails -> accept defeat, log, stop
```

## Simplicity Criterion
```
Discard if: +5 lines AND improvement < 0.5%
Discard if: complexity up AND improvement < 1%
Keep if: lines removed with equal/better metric
Tie-break: fewer lines wins
```

## Hard Rules
1. Metric = shell command outputting single number.
2. One change per agent per round. Max 3 agents.
3. Never modify test files. Never trade readability
   for <1% gain. Profile before guessing.
4. Guard must pass for every kept change.
5. Diminishing: 3 consecutive <1% -> radical -> stop.

## TSV Logging
Append `.godmode/optimize-results.tsv`:
```
round	agent	change	metric_before	metric_after	delta_pct	status	failure_class
```
On DISCARD: also append to `.godmode/optimize-failures.tsv` with `failure_class` and `reason`.

## Keep/Discard
```
KEEP if: metric improved AND guard passed.
DISCARD if: metric worsened OR guard failed.
On discard: git reset --hard HEAD~1.
```

## Learning from Discards

After DISCARD: read `optimize-failures.tsv`. Count by `failure_class`.
If >3 in same class: announce "Approach category exhausted: {class}. Switching strategy."
Before next IDEATE: skip any change similar to the top failure class.

### Overfitting Prevention
Before KEEP: run metric_cmd 3x. If stdev > |improvement|: DISCARD as noise.
"Would this optimization help if the specific bottleneck moved?" If NO → DISCARD.

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: metric meets target
  - budget_exhausted: max_rounds reached
  - diminishing: 3 consecutive keeps each < 1%
  - stuck: >5 consecutive discards after recovery
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Metric non-numeric | Pipe through tail -1 or awk |
| Noisy metric (>5%) | 10 runs, trim outliers, median 8 |
| All 3 agents regress | Stuck recovery, opposite approach |
| Agent timeout (>5m) | Kill worktree, discard, next round |

```bash
# Profile and benchmark
npm run build -- --profile
npx lighthouse http://localhost:3000 --output=json
pytest --benchmark-only
```
