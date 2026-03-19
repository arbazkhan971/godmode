---
name: optimize
description: Autonomous optimization loop. 3 parallel agents per round, mechanical metrics only.
---

# Optimize — Autonomous Iteration Loop

## Activate When
- `/godmode:optimize`, "make faster", "improve", "optimize"

## Setup (once)
1. **Detect** — Scan for test/bench/build outputs. Suggest metric + verify + guard.
2. **Config** — Goal, Metric (numeric output only), Direction (higher|lower), Verify (dry-run first), Guard (must-pass, optional), Scope, Iterations.
3. **Baseline** — Run verify 3x, median. Commit: `"optimize: baseline — {metric} = {value}"`

## The Loop
```
WHILE current_round < max_rounds:
    current_round += 1
    # 1. REVIEW — in-scope files, results.tsv (last 10), git log -10
    IF bounded AND remaining < 3: exploit > explore
    # 2. HYPOTHESIZE — 3 independent untested changes
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
1. Never stop, never ask. Bounded: N times. Unbounded: forever.
2. Commit BEFORE verify. Rollback: `git reset --hard HEAD~1`.
3. Mechanical metric only. Must output a number.
4. One change per agent per round.
5. Same/worse → revert. No debates.
6. Never modify tests to pass optimization.
7. +0.1% with ugly code → discard. Same metric + simpler → keep.
8. TSV log every iteration.
9. Stuck >5 discards: opposite, radical, compound.
10. Max 3 agents per round. Only winner kept.
