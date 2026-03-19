---
name: optimize
description: |
  Autonomous iteration loop. Measure → modify → verify → keep/revert → repeat. Multi-agent parallel optimization with 3 agents per round in isolated worktrees. Git-as-memory. Mechanical metrics only.
---

# Optimize — Autonomous Iteration Loop

## Activate When
- `/godmode:optimize`
- "make faster", "improve", "optimize", "iterate"
- After build completes and quality improvement is desired

## Setup (do once)

**1. Auto-Detect Metrics** — Scan for test frameworks, benchmarks, build output. Suggest metric + verify command + guard.

**2. Collect Config** — Goal (one sentence), Metric (command outputting a NUMBER — reject if not numeric), Direction (higher|lower), Verify (dry-run before accepting), Guard (must-pass command, optional), Scope (file globs), Iterations (N or unlimited).

**3. Measure Baseline** — Run verify 3x, take median. Commit: `"optimize: baseline — {metric} = {value}"`

## The Loop

```
baseline = median(verify() x 3)

WHILE current_round < max_rounds:
    current_round += 1

    # 1. REVIEW — Read in-scope files, optimize-results.tsv (last 10), git log -10.
    IF bounded AND remaining < 3: exploit > explore.

    # 2. HYPOTHESIZE — pick 3 independent untested changes.
    IF >5 consecutive discards: try OPPOSITE of what failed.

    # 3. DISPATCH 3 AGENTS (parallel, in worktrees)
    Each: ONE change → commit → guard (must pass) → verify 3x median.
    Commit msg: "optimize: round {N} agent {M} — {description}"

    # 4. PICK WINNER — largest improvement
    improved + guard_passed → cherry-pick onto main, update baseline
    improved + guard_failed → rework (max 2 tries), else discard
    no improvement → discard all

    # 5. LOG — append to .godmode/optimize-results.tsv:
    round  agent  hypothesis  change  baseline  measured  delta%  verdict  commit

    # 6. STATUS (every 5 rounds)
    "Round {N}: {metric} at {val} (from {original}, {delta}%), {keeps}/{discards}"

    # 7. DIMINISHING RETURNS — last 3 keeps all <1%:
    Try radical → compound (combine top 3 keeps) → if still stalls: STOP.

STOP: target reached | max rounds | diminishing returns exhausted | guard broken
```

Print final summary: baseline → final (delta%), keeps/discards, best round, log path.

## Rules

1. **NEVER STOP. NEVER ASK.** Unbounded: loop forever. Bounded: loop N times.
2. **Commit BEFORE verify.** Rollback is `git reset --hard HEAD~1`.
3. **Mechanical metric only.** Must output a number. No subjective judgments.
4. **One change per agent per round.** No "while I'm here" fixes.
5. **Automatic revert.** Same/worse → revert. No debates.
6. **Guard is read-only.** Never modify tests to make optimization pass.
7. **Simplicity override.** +0.1% with ugly code → discard. Same metric + simpler → keep.
8. **TSV log every iteration.** No exceptions.
9. **When stuck (>5 discards):** re-read all files, try opposite, try radical, try compound.
10. **Max 3 agents per round.** All start from same baseline. Only winner kept.
