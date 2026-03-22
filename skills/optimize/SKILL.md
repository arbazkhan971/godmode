---
name: optimize
description: Autonomous optimization loop. 3 parallel agents per round, mechanical metrics only.
---

## Activate When
- `/godmode:optimize`, "make faster", "improve", "optimize"

## Setup (once)
Ask: Goal, Metric (`cmd` → single number), Direction (↑/↓), Scope (file globs). Auto-detect from stack.

### Baseline Measurement Protocol
```
Baseline: run metric_cmd 3 times, take median.
- If variance >5%: profile 10 runs, use statistical baseline (trim outliers, take median of middle 8).
- Commit baseline as iteration 0: "baseline: {metric} = {value}"
- Record in .godmode/optimize-results.tsv as round 0, status=baseline.
```

### Guard vs Metric Distinction
```
METRIC: shell cmd outputting a single number (optimization target, direction ↑ or ↓)
GUARD:  test_cmd && lint_cmd && build_cmd (must ALL pass, non-negotiable)
Change must BOTH improve metric AND pass guard.
Guard failure → DISCARD (terminal, no retry — rework counts against the 2-rework cap).
Metric regression + guard pass → DISCARD (not harmful, just useless).
```

## The Loop
```
WHILE current_round < max_rounds:
    current_round += 1
    # 1. REVIEW — in-scope files + results.tsv (last 10) + git log -10. Profile first: identify hotspot before changing.
    IF bounded AND remaining < 3: exploit only (refine best kept change, no new experiments)
    # 2. HYPOTHESIZE — 3 independent untested changes (algorithmic > caching > structural)
    IF >5 consecutive discards: STUCK RECOVERY (see below)
    # 3. DISPATCH 3 AGENTS (parallel, worktrees)
    Each agent: ONE change → commit → run guard → verify 3x → report median.
    Agent timeout: 5 min per agent per round. Exceeded → kill worktree, discard, move on.
    # 4. PICK WINNER — largest improvement
    improved + guard passed → cherry-pick to main branch, update baseline
    improved + guard failed → rework (max 2), else discard
    no improvement → discard all
    # 5. LOG to .godmode/optimize-results.tsv: round, agent, change, metric_before, metric_after, status(kept/discarded)
    # 6. STATUS every 5 rounds. DIMINISHING: last 3 keeps <1% → radical → compound → STOP
STOP: target | max rounds | diminishing returns | guard broken
```
Print: `{metric}: {baseline} → {final} ({delta}%). {keeps} kept, {discards} discarded across {total} rounds. Best change: round {N}`.

## Stuck Recovery Strategy
```
IF >5 consecutive discards:
  1. Re-read ALL in-scope files (not just recent diffs) — stale mental model is #1 cause of stuck loops.
  2. Try OPPOSITE approach:
     - If simplifying failed → add caching/precomputation
     - If inlining failed → extract functions
     - If algorithmic failed → try data structure change
     - If micro-optimizing failed → try architectural change
  3. If opposite fails → radical rewrite: replace component entirely (new algorithm, new library, new data layout).
  4. If radical fails → accept defeat, log stop_reason=stuck, print final summary.
```

## Simplicity Criterion (Concrete Thresholds)
```
Discard if: lines_added > 5 AND metric_improvement < 0.5%
Discard if: cognitive_complexity_increased AND metric_improvement < 1%
Keep if:    lines_removed with equal/better metric (simplification win)
Keep if:    same lines + metric_improvement >= 1% (clear optimization win)
Tie-break:  fewer lines wins. Equal lines → fewer branches/loops wins.
```

## Agent Timeout
```
5 min wall-clock per agent per round.
Exceeded → kill worktree, mark status=timeout in results.tsv, discard, move on.
Do NOT extend. Do NOT retry the same hypothesis. Next round picks new hypotheses.
```

## Keep/Discard Discipline
```
After EACH agent round:
  KEEP if: metric improved AND guard (test_cmd && lint_cmd && build_cmd) passed
  DISCARD if: metric worsened OR guard failed
  On discard: git reset --hard HEAD~1. Log discard reason in results.tsv.
  On guard failure: discard is terminal — rework counts against the 2-rework cap.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: metric meets or exceeds target
  - budget_exhausted: max_rounds reached
  - diminishing_returns: 3 consecutive keeps each < 1% improvement
  - stuck: >5 consecutive discards
```

## Output Format
Print: `Skill: {metric}: {baseline} → {final} ({delta}%). {keeps} kept, {discards} discarded. Status: {DONE|PARTIAL}.`

## Rules
1. Metric must be a shell command that outputs a single number. No subjective assessment.
2. One change per agent per round. Max 3 agents. Only winner kept.
3. Never modify test files. Never cache mutable data. Never trade readability for <1% gain. Profile before guessing.
4. +0.1% with added complexity → discard. Same metric + fewer lines → keep. Simpler code > marginal gains.
5. Diminishing returns: 3 consecutive <1% keeps → radical → compound → stop.

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- Run experiments **sequentially** instead of 3 parallel agents per round.
- For each experiment: create branch `godmode-opt-{round}-{n}`, make ONE change, commit, run guard + verify 3x.
- Compare all 3 results. Cherry-pick the winner to main: `git checkout main && git merge godmode-opt-{round}-{winner}`.
- Delete experiment branches: `git branch -D godmode-opt-{round}-{n}`.
- If no experiment improved: discard all, log, move to next round.
- Same termination logic: target reached, max rounds, diminishing returns.
- ~3x slower per round but identical results.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
