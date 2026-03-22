# Godmode's Seven Core Principles

These principles govern every action taken by the autonomous optimization loop. They are non-negotiable. Violating any of them invalidates the iteration.

---

## Principle 1: Mechanical Verification Only

**Statement:** Never claim something is true without running a command and reading the output.

**In practice:**
- "I think it's faster" → INVALID. Run the benchmark.
- "The tests should pass" → INVALID. Run the tests.
- "This looks more efficient" → INVALID. Measure it.

**The rule:** If you can't point to a command output that proves your claim, the claim is false until proven.

**Why it matters:** Human intuition about performance is wrong more often than it's right. Compilers optimize differently than we expect. Caches behave differently under load. The only truth is the measurement.

**Violation examples:**
```
BAD: "Refactored the database query, performance should improve."
     (No measurement taken)

BAD: "Response time: 198ms (estimated based on code analysis)"
     (Not measured, estimated)

GOOD: "Response time: 198ms (median of 3 runs: 198, 203, 195)"
      (Measured, with raw data)
```

---

## Principle 2: One Change Per Iteration

**Statement:** Make exactly one logical change per iteration. Never combine multiple modifications.

**In practice:**
- Change one function, one query, one configuration value
- If you're tempted to fix "one more thing," that's the next iteration
- Multi-file changes are OK if they constitute ONE logical change (e.g., updating a function signature and all its callers)

**Why it matters:** If you change A and B simultaneously and the metric improves by 30%, you don't know if A contributed 25% and B contributed 5%, or if A contributed 35% and B actually regressed by 5%. One change at a time produces clean experimental data.

**Violation examples:**
```
BAD: "Added index on user_id AND refactored the query to use a JOIN"
     (Two changes — which one helped?)

BAD: "Fixed the N+1 query and also cleaned up the response serialization"
     (Two changes — if metric regressed, which one caused it?)

GOOD: "Added index on posts.user_id column"
      (One change — if metric improves, we know why)
```

---

## Principle 3: Git Is Memory

**Statement:** Every experiment is committed. Every revert is committed. The git history IS the experiment log.

**In practice:**
- Commit before measuring (so the code state is captured)
- Commit reverts explicitly (so we know what was tried and rejected)
- Use descriptive commit messages with the iteration number
- Never amend commits in the optimization loop — the history must be linear and honest

**Why it matters:** Three weeks from now, someone will ask "why didn't you try X?" The git log should answer that question: "We did try X, in iteration 7, and it regressed performance by 12%."

**Commit message format:**
```
optimize: iteration <N> — <brief description of change>
optimize: iteration <N> — REVERT: <reason for reverting>
optimize: baseline — <metric> = <value>
optimize: complete — <metric> <baseline> → <final> (<improvement>%)
```

---

## Principle 4: Evidence Before Claims

**Statement:** Write the result AFTER measuring, not before. Never predict the outcome in the commit message or log.

**In practice:**
- Commit the code change FIRST
- Run the verify command SECOND
- Log the result THIRD
- The log entry is descriptive (what happened), not predictive (what we think will happen)

**Why it matters:** Prediction creates confirmation bias. If you write "this should improve by 20%" and then measure 18%, you will be satisfied. But if you measure first and see 18%, you evaluate that number on its own merits — 18% is likely not worth the added complexity.

**Violation examples:**
```
BAD: Commit: "optimize: add eager loading — expect ~50% improvement"
     (Predicted before measuring)

GOOD: Commit: "optimize: iteration 3 — add eager loading for posts relation"
      Log: "Measured: 847ms → 612ms (-27.7%) — KEEP"
      (Measured then logged)
```

---

## Principle 5: Guard Rails Are Sacred

**Statement:** Tests must pass. Lint must pass. If an optimization breaks something, it's not an optimization — it's a regression with a silver lining.

**In practice:**
- Run ALL guard rail commands BEFORE measuring the metric
- If any guard rail fails, REVERT immediately — do not measure the metric
- Never disable a guard rail to make an optimization work
- If a guard rail is flaky, fix the guard rail first

**Why it matters:** A 50% performance improvement that breaks 3 tests means you've introduced bugs. Those bugs will cost more to find and fix than the performance is worth. Guard rails exist to prevent optimization-induced regressions.

**The order matters:**
```
1. Make the change
2. Run guard rails (tests, lint, types)
3. If guard rails fail → REVERT, log as "GUARD RAIL FAILURE"
4. If guard rails pass → measure the metric
5. If metric improved → KEEP
6. If metric regressed → REVERT
```

---

## Principle 6: Reverts Are Data

**Statement:** A reverted experiment is not a failure. It is valuable knowledge about what does NOT work for this specific problem.

**In practice:**
- Log reverted iterations with the same detail as kept iterations
- Include what you learned in the log entry
- Don't feel bad about reverts — they're expected and normal
- A 60% keep rate (12 of 20 iterations kept) is excellent

**Why it matters:** Thomas Edison didn't fail 1,000 times — he found 1,000 ways that don't work. A reverted optimization tells you something concrete: "this approach does not improve this metric in this codebase." That's valuable information that prevents wasted effort in the future.

**Expected ratios:**
```
Excellent: 60-70% keep rate
Good:      40-60% keep rate
Normal:    30-40% keep rate
Concerning: < 30% keep rate (re-evaluate strategy)
```

**What to learn from reverts:**
```
REVERT LOG:
Iteration 3: Streaming JSON — no measurable improvement
  Learning: Serialization is not the bottleneck. I/O time dominates.

Iteration 7: Increased worker pool to 32 — REGRESSED by 8%
  Learning: At this data volume, thread contention outweighs parallelism.

Iteration 11: Aggressive caching — tests failed (stale data)
  Learning: Cache invalidation is required before caching can work here.
```

---

## Principle 7: Know When to Stop

**Statement:** Diminishing returns are real. Recognize them and stop.

**In practice:**
- Target reached → stop celebrating, stop optimizing
- 3 consecutive reverts → the easy wins are gone
- Max iterations reached → accept what you have
- Marginal improvement (< 2% for last 3 kept iterations) → stop

**Why it matters:** The first 3 iterations typically yield 60% improvement. The next 10 yield another 15%. The last 20 yield 3%. At some point, the agent's effort is better spent elsewhere. Recognize that point and stop.

**Stopping decision matrix:**
```
| Condition                        | Action              |
|----------------------------------|----------------------|
| Target achieved                  | STOP — success       |
| Max iterations reached           | STOP — assess        |
| 3 consecutive reverts            | STOP — diminishing   |
| Last 3 kept iterations < 2% each | STOP — plateau      |
| Guard rails can't be maintained  | STOP — incompatible  |
| New approach needed              | STOP — re-think      |
```

**After stopping:**
1. Write the summary report
2. Commit the final state
3. Recommend next action (ship, or think about a different approach)
