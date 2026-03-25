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
Commit baseline as iteration 0.

### Guard vs Metric
```
METRIC: shell cmd -> single number (target)
GUARD:  test_cmd && lint_cmd && build_cmd (must pass)
Change must BOTH improve metric AND pass guard.
Guard failure -> DISCARD (terminal, counts against
  2-rework cap).
```

## The Loop
```
WHILE current_round < max_rounds:
  1. REVIEW: in-scope files + results.tsv + git log
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

## Stuck Recovery
```
IF >5 consecutive discards:
  1. Re-read ALL in-scope files (stale model)
  2. Try OPPOSITE approach
  3. If opposite fails -> radical rewrite
  4. If radical fails -> accept defeat, log, stop
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
round	agent	change	metric_before	metric_after	delta_pct	status
```

## Keep/Discard
```
KEEP if: metric improved AND guard passed.
DISCARD if: metric worsened OR guard failed.
On discard: git reset --hard HEAD~1.
```

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
