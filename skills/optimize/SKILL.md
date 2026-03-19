---
name: optimize
description: |
  Core autonomous iteration loop — the heart of Godmode. Activates when user wants to improve code quality, performance, or any measurable metric through autonomous experimentation. Runs a disciplined loop: measure baseline, hypothesize, modify, verify mechanically, keep if better or revert if worse, repeat. Git-as-memory ensures every experiment is tracked. Triggers on: /godmode:optimize, "make this faster", "improve this", "optimize", or when godmode orchestrator detects OPTIMIZE phase.
---

# Optimize — Autonomous Iteration Loop

## When to Activate
- User invokes `/godmode:optimize`
- User says "make this faster," "improve performance," "optimize," "iterate on this"
- Godmode orchestrator routes here (implementation exists, tests pass, quality improvement desired)
- After build phase completes and user wants to push quality further
- When a specific metric needs improvement (response time, bundle size, memory usage, etc.)

## The Core Loop

This is the most important skill in Godmode. Everything else exists to support this loop.

```
┌─────────────────────────────────────────────────────────────┐
│                  THE AUTONOMOUS LOOP                        │
│                                                             │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐          │
│   │ MEASURE  │────▶│ HYPOTHE- │────▶│  MODIFY  │          │
│   │ BASELINE │     │   SIZE   │     │   CODE   │          │
│   └──────────┘     └──────────┘     └──────────┘          │
│        ▲                                  │                 │
│        │                                  ▼                 │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐          │
│   │  REPEAT  │◀────│KEEP/REVERT│◀────│  VERIFY  │          │
│   │ (or STOP)│     │          │     │MECHANICLY│          │
│   └──────────┘     └──────────┘     └──────────┘          │
│                                                             │
│   Every iteration: git commit. Every decision: evidence.    │
└─────────────────────────────────────────────────────────────┘
```

## Workflow

### Step 0: Setup (Run Once)
Before the loop starts, establish the optimization target.

If `/godmode:setup` has not been run, collect these interactively:

```
OPTIMIZATION CONFIG:
Goal: <what are we optimizing? e.g., "reduce API response time">
Metric: <measurable quantity, e.g., "p95 response time in ms">
Baseline: <current value, measured not estimated>
Target: <desired value, e.g., "< 200ms">
Verify command: <exact command that outputs the metric>
Guard rails:
  - Tests must pass: <test command>
  - Lint must pass: <lint command>
  - No regressions: <other commands>
Max iterations: <default 25>
Scope: <files/directories in scope for modifications>
```

**Critical: The verify command must be MECHANICAL.** It must:
- Run without human intervention
- Produce a parseable numeric result
- Be deterministic (same code = same result, within tolerance)
- Complete in under 60 seconds

Example verify commands:
```bash
# Response time
curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/health

# Bundle size
du -b dist/bundle.js | cut -f1

# Test execution time
/usr/bin/time -f '%e' npm test 2>&1 | tail -1

# Memory usage
node --max-old-space-size=512 -e "require('./dist'); console.log(process.memoryUsage().heapUsed)"

# Custom benchmark
npm run benchmark -- --json | jq '.results[0].mean'
```

### Step 1: Measure Baseline
Run the verify command and record the baseline:

```bash
# Run verify command 3 times, take median for stability
RESULT_1=$(verify_command)
RESULT_2=$(verify_command)
RESULT_3=$(verify_command)
BASELINE=median($RESULT_1, $RESULT_2, $RESULT_3)
```

```
BASELINE MEASUREMENT:
Metric: p95 response time
Value: 847ms
Target: < 200ms
Gap: 647ms (76% improvement needed)
```

Commit: `"optimize: baseline — <metric> = <value>"`

### Step 2: Analyze and Hypothesize
Before modifying anything, analyze the code to form a hypothesis:

```
HYPOTHESIS FOR ITERATION <N>:
Observation: <what I see in the code that could be improved>
Theory: <why this change should improve the metric>
Proposed change: <specific modification>
Expected impact: <estimated improvement>
Risk: <what could go wrong>
Files to modify: <exact file paths>
```

Rules for hypotheses:
- **One change per iteration.** Never modify multiple things at once.
- **Highest impact first.** Attack the biggest bottleneck first.
- **Evidence-based.** The hypothesis must be based on code analysis, not guessing.
- **Reversible.** The change must be committable and revertable.

### Step 3: Modify
Make the change. Follow these rules:

1. **One logical change only.** If you're tempted to fix "one more thing," resist. That's the next iteration.
2. **Modify, don't rewrite.** Targeted changes are safer than rewrites.
3. **Stay in scope.** Only modify files within the defined scope.
4. **Don't break the interface.** Internal changes only. Public APIs stay stable.

Commit: `"optimize: iteration <N> — <brief description of change>"`

### Step 4: Verify Mechanically
Run ALL verification checks in order:

```
VERIFICATION:
1. Guard rails:
   [ ] Tests pass: <result>
   [ ] Lint clean: <result>
   [ ] No regressions: <result>

2. Metric measurement (3 runs, median):
   Run 1: <value>
   Run 2: <value>
   Run 3: <value>
   Median: <value>

3. Comparison:
   Baseline: <baseline value>
   Current:  <current value>
   Delta:    <change> (<percentage>)
   Verdict:  IMPROVED / NO CHANGE / REGRESSED
```

**CRITICAL RULES FOR VERIFICATION:**
- **NEVER claim improvement without running the verify command.** No "this should be faster." Run it. Measure it. Prove it.
- **NEVER skip the guard rails.** An optimization that breaks tests is not an optimization.
- **Run 3 times minimum.** Single measurements are unreliable. Use the median.
- **Evidence before claims.** The log entry is written AFTER measurement, not before.

### Step 5: Keep or Revert

**If IMPROVED and guard rails pass:**
```
KEEP — Iteration <N>
Change: <description>
Metric: <baseline> → <new value> (<improvement>)
Cumulative: <original baseline> → <new value> (<total improvement>)
```

**If NO CHANGE or REGRESSED or guard rails fail:**
```bash
git revert HEAD --no-edit
```
```
REVERT — Iteration <N>
Change: <description>
Reason: <REGRESSED by X% | NO MEASURABLE CHANGE | TESTS FAILED | LINT FAILED>
Learning: <what this tells us about the problem>
```

The revert is NOT a failure. It's valuable information. We now know this approach doesn't work.

### Step 6: Log Results
Append to the results log (TSV format):

```
# File: .godmode/optimize-results.tsv
iteration	timestamp	hypothesis	change_description	baseline	measured	delta_pct	verdict	commit_sha
1	2024-01-15T10:23:00Z	"N+1 query in getUserPosts"	"Add eager loading for posts relation"	847	612	-27.7	KEEP	abc1234
2	2024-01-15T10:31:00Z	"Unindexed WHERE clause"	"Add index on posts.user_id"	612	401	-34.5	KEEP	def5678
3	2024-01-15T10:38:00Z	"JSON serialization overhead"	"Switch to streaming JSON"	401	415	+3.5	REVERT	ghi9012
```

### Step 7: Decide — Continue or Stop

**Continue if:**
- Target not yet reached
- Iterations remaining (under max)
- Still have untested hypotheses
- Last 3 iterations weren't all REVERT (diminishing returns signal)

**Stop if:**
- Target reached
- Max iterations reached
- Last 3 iterations all REVERT (no more low-hanging fruit)
- Guard rails can't be maintained

### Step 8: Summary Report
When the loop ends:

```
┌─────────────────────────────────────────────────────────────┐
│  OPTIMIZATION COMPLETE                                      │
├─────────────────────────────────────────────────────────────┤
│  Goal: Reduce API response time                             │
│  Metric: p95 response time (ms)                             │
│                                                             │
│  Baseline:  847ms                                           │
│  Final:     198ms                                           │
│  Target:    200ms  ✓ ACHIEVED                               │
│  Improvement: 76.6%                                         │
│                                                             │
│  Iterations: 12 total                                       │
│  Kept: 8 improvements                                       │
│  Reverted: 4 experiments                                    │
│                                                             │
│  Top improvements:                                          │
│  1. Add eager loading (+27.7%)                              │
│  2. Add database index (+34.5%)                             │
│  3. Connection pooling (+18.2%)                             │
│                                                             │
│  Full log: .godmode/optimize-results.tsv                    │
├─────────────────────────────────────────────────────────────┤
│  Next: /godmode:secure — Security audit before shipping     │
│        /godmode:ship — Ship if satisfied                    │
└─────────────────────────────────────────────────────────────┘
```

## The Seven Principles

These are the non-negotiable rules of the optimization loop:

### 1. Mechanical Verification Only
No "I think it's faster." No "this looks better." Run the command. Read the number. That's the truth.

### 2. One Change Per Iteration
Multiple changes at once make it impossible to know what helped. One change. One measurement. One decision.

### 3. Git Is Memory
Every experiment is committed. Every revert is committed. The git log IS the experiment log. You can always go back.

### 4. Evidence Before Claims
Write the result AFTER measuring, not before. Never predict the outcome in the commit message.

### 5. Guard Rails Are Sacred
Tests must pass. Lint must pass. If an optimization breaks something, it's not an optimization — it's a regression.

### 6. Reverts Are Data
A reverted experiment is not a failure. It's knowledge: "this approach doesn't work for this problem." That's valuable.

### 7. Know When to Stop
Diminishing returns are real. If 3 consecutive iterations are reverted, the easy wins are gone. Stop or change strategy.

## Example Usage

### Optimizing database query performance
```
User: /godmode:optimize The /api/products endpoint is too slow

Optimize: Let me set up the optimization loop.

Goal: Reduce /api/products response time
Metric: Response time (ms)
Verify: curl -s -o /dev/null -w '%{time_total}\n' http://localhost:3000/api/products | awk '{print $1*1000}'

Measuring baseline (3 runs)...
Run 1: 1247ms
Run 2: 1189ms
Run 3: 1223ms
Baseline: 1223ms (median)

Target: < 300ms
Gap: 923ms

ITERATION 1:
Hypothesis: The products query joins 4 tables with no eager loading,
causing N+1 queries (one per product for each relation).
Change: Add eager loading for category, brand, and images relations.
Expected impact: ~50% reduction

[modifies code, commits, measures]

Verification:
✓ Tests: 47/47 passing
✓ Lint: clean
Run 1: 589ms | Run 2: 612ms | Run 3: 601ms
Median: 601ms (from 1223ms, -50.9%)
Verdict: KEEP ✓

ITERATION 2:
Hypothesis: No index on products.category_id used in WHERE clause.
...
```

### Optimizing bundle size
```
User: /godmode:optimize Our frontend bundle is too large (2.3MB)

Optimize: Setting up optimization loop.

Goal: Reduce frontend bundle size
Metric: Bundle size (bytes)
Verify: npm run build 2>/dev/null && du -b dist/assets/index-*.js | cut -f1

Baseline: 2,415,623 bytes (2.30MB)
Target: < 500,000 bytes (< 500KB)
...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive setup then autonomous loop |
| `--goal "<goal>"` | Set optimization goal directly |
| `--metric "<metric>"` | Set metric name |
| `--verify "<cmd>"` | Set verify command |
| `--target <value>` | Set target value |
| `--max <N>` | Maximum iterations (default 25) |
| `--resume` | Resume a previously paused optimization |
| `--report` | Show results from the last optimization run |
| `--dry-run` | Show what would happen without making changes |

## Anti-Patterns

- **Do NOT claim improvement without measurement.** This is the cardinal sin. "I refactored the code, it should be faster" is meaningless. Measure it.
- **Do NOT change multiple things per iteration.** If you add an index AND refactor a query, you don't know which one helped.
- **Do NOT skip guard rails.** A 50% speedup that breaks 3 tests is a regression, not an optimization.
- **Do NOT optimize without a target.** "Make it faster" is not a target. "Reduce p95 to under 200ms" is a target.
- **Do NOT continue after 3 consecutive reverts.** Diminishing returns. Either change strategy or stop.
- **Do NOT rewrite instead of optimizing.** The loop makes targeted changes. If you need a rewrite, that's a new THINK→BUILD cycle.
- **Do NOT forget to log.** The results TSV is the permanent record. Every iteration gets a row.
- **Do NOT optimize prematurely.** If the code doesn't work yet, go back to `/godmode:build` or `/godmode:fix`.
