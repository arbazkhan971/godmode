---
name: optimize
description: Autonomous optimization loop. 3 parallel agents per round, mechanical metrics only.
---

## Activate When
- `/godmode:optimize`, "make faster", "improve", "optimize"

## Setup (once)
Detect test/bench/build outputs → suggest metric + verify + guard. Collect: Goal, Metric (numeric), Direction, Verify (dry-run first), Guard, Scope, Iterations. Baseline: verify 3x, median, commit.

## The Loop
```
WHILE current_round < max_rounds:
    current_round += 1
    # 1. REVIEW — in-scope files + results.tsv (last 10) + git log -10. Identify bottleneck.
    IF bounded AND remaining < 3: exploit > explore
    # 2. HYPOTHESIZE — 3 independent untested changes (algorithmic > caching > structural)
    IF >5 consecutive discards: try OPPOSITE
    # 3. DISPATCH 3 AGENTS (parallel, worktrees)
    Each: ONE change → commit → guard → verify 3x median
    # 4. PICK WINNER — largest improvement
    improved + guard passed → cherry-pick, update baseline
    improved + guard failed → rework (max 2), else discard
    no improvement → discard all
    # 5. LOG to .godmode/optimize-results.tsv
    # 6. STATUS every 5 rounds
    # 7. DIMINISHING — last 3 keeps <1%: radical → compound → STOP
STOP: target | max rounds | diminishing returns | guard broken
```
Print: baseline → final (delta%), keeps/discards, best round.

## Rules
1. Mechanical metric only. Must output a number.
2. One change per agent per round. Max 3 agents. Only winner kept.
3. Never modify tests to pass optimization.
4. +0.1% with added complexity → discard. Same metric + fewer lines → keep.
5. Diminishing returns: 3 consecutive <1% keeps → radical → compound → stop.
