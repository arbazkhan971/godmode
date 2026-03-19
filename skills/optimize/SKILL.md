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

### 1. Auto-Detect Metrics

Scan project before asking the user anything:

```bash
# Test frameworks → coverage metric
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
# Benchmarks → timing metric
find . -name "*.bench.*" -o -name "*benchmark*" 2>/dev/null
# Build output → size metric
ls dist/ build/ out/ target/ 2>/dev/null
```

Suggest: "Detected pytest + benchmark suite. Recommend metric: test execution time (lower is better). Verify: `pytest --tb=short 2>&1 | tail -1`. Guard: `pytest --tb=short`."

### 2. Collect Config

```
Goal:      What to improve (one sentence)
Metric:    Command that outputs a NUMBER (not subjective)
Direction: higher | lower
Verify:    Shell command that produces the metric
Guard:     Command that must always pass (tests, typecheck) — optional
Scope:     File globs to modify
Iterations: N (or unlimited)
```

**Dry-run verify command before accepting.** If it doesn't output a number, reject it.

### 3. Measure Baseline

Run verify 3 times. Take median. Commit: `"optimize: baseline — {metric} = {value}"`

---

## The Loop

```
current_round = 0
max_rounds = N  # from "Iterations: N", or Infinity
baseline = median(verify() x 3)

WHILE current_round < max_rounds:
    current_round += 1

    # 1. REVIEW (30 sec)
    Read in-scope files. Read .godmode/optimize-results.tsv (last 10).
    Read git log --oneline -10.
    IF bounded AND remaining < 3: exploit > explore.

    # 2. HYPOTHESIZE — pick 3 independent changes
    Select 3 untested hypotheses from codebase analysis.
    IF >5 consecutive discards: try OPPOSITE of what failed.

    # 3. DISPATCH 3 AGENTS (parallel, in worktrees)
    Each agent:
      a. Makes ONE change
      b. Commits: "optimize: round {N} agent {M} — {description}"
      c. Runs guard (must pass)
      d. Runs verify 3x, takes median

    # 4. PICK WINNER
    best = agent with largest improvement
    IF best.improved AND best.guard_passed:
        Cherry-pick onto main. baseline = best.metric. STATUS = keep
    ELIF best.improved AND best.guard_failed:
        Rework (max 2 tries). IF fails: discard.
    ELSE:
        All agents failed. STATUS = discard.

    # 5. LOG — every agent gets a row
    Append to .godmode/optimize-results.tsv:
    round  agent  hypothesis  change  baseline  measured  delta%  verdict  commit

    # 6. STATUS (every 5 rounds)
    IF current_round % 5 == 0:
        "Round {N}: {metric} at {val} (from {original}, {delta}%), {keeps}/{discards}"

    # 7. DIMINISHING RETURNS
    IF last 3 keeps all < 1% improvement:
        Try radical change (different algorithm, architecture)
        IF radical also < 1%: try compound (combine top 3 keeps)
        IF compound also stalls: print summary, STOP.

STOP CONDITIONS: target reached | max rounds | diminishing returns exhausted | guard broken
```

**Print final summary:**
```
=== Optimize Complete ({N}/{max} rounds, {N*3} experiments) ===
Baseline: {start} → Final: {end} ({delta}%)
Keeps: X | Discards: Y
Best: round #{n} — {description} ({delta}%)
Log: .godmode/optimize-results.tsv
```

---

## Single-Agent Mode

When multi-agent is overkill (simple projects, one file), run the same loop but with 1 agent per round. Same protocol: commit → verify → keep/revert.

---

## Rules

1. **NEVER STOP. NEVER ASK.** Unbounded: loop forever. Bounded: loop N times.
2. **Commit BEFORE verify.** Rollback is `git reset --hard HEAD~1`.
3. **Mechanical metric only.** No "looks good." Must output a number.
4. **One change per agent per round.** No "while I'm here" fixes.
5. **Automatic revert.** Same/worse → revert. No debates.
6. **Guard is read-only.** Never modify tests to make optimization pass.
7. **Simplicity override.** +0.1% improvement with ugly code → discard. Same metric + simpler → keep.
8. **TSV log every iteration.** No exceptions.
9. **When stuck (>5 discards):** re-read all files, try opposite, try radical, try compound.
10. **Max 3 agents per round.** All start from same baseline. Only winner kept.
