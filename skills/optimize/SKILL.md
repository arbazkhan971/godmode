---
name: optimize
description: Autonomous optimization loop. 3 parallel agents per round, mechanical metrics only.
---

## Activate When
- `/godmode:optimize`, "make faster", "improve", "optimize"

## Setup (once)
Ask user: Goal, Metric (shell cmd → number), Direction (higher/lower), Scope (file globs). Auto-detect: Verify cmd, Guard (test_cmd). Baseline: run verify 3x, take median, commit.

## The Loop
```
WHILE current_round < max_rounds:
    current_round += 1
    # 1. REVIEW — in-scope files + results.tsv (last 10) + git log -10. Profile first: identify hotspot before changing.
    IF bounded AND remaining < 3: exploit (refine best) > explore (try new)
    # 2. HYPOTHESIZE — 3 independent untested changes (algorithmic > caching > structural)
    IF >5 consecutive discards: try OPPOSITE
    # 3. DISPATCH 3 AGENTS (parallel, worktrees)
    Each agent: ONE change → commit → run guard (test_cmd, must pass) → verify 3x → report median. Timeout: 5min per agent.
    # 4. PICK WINNER — largest improvement
    improved + guard passed → cherry-pick, update baseline
    improved + guard failed → rework (max 2), else discard
    no improvement → discard all
    # 5. LOG to .godmode/optimize-results.tsv: round, agent, change, metric_before, metric_after, status(kept/discarded)
    # 6. STATUS every 5 rounds. DIMINISHING: last 3 keeps <1% → radical → compound → STOP
STOP: target | max rounds | diminishing returns | guard broken
```
Print: `{metric}: {baseline} → {final} ({delta}%). Rounds: {total}, Keeps: {keeps}, Discards: {discards}, Best: round {N}`.

## Rules
1. Metric must be a shell command that outputs a single number. No subjective assessment.
2. One change per agent per round. Max 3 agents. Only winner kept.
3. Never modify tests. Never add caching that breaks correctness. Never trade readability for <1% gain.
4. +0.1% with added complexity → discard. Same metric + fewer lines → keep. Simpler code > marginal gains.
5. Diminishing returns: 3 consecutive <1% keeps → radical → compound → stop.
