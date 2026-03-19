# Autonomous Loop Protocol — Full Specification

## Overview
The autonomous loop is the core differentiator of Godmode. It enables an AI agent to independently improve code through a disciplined experimental process. Every action is measured, logged, and reversible.

## Protocol Definition

### Pre-Loop: Configuration
Before the loop begins, these MUST be defined:

```yaml
goal: "<human-readable optimization target>"
metric: "<what is measured>"
verify_command: "<exact shell command that outputs a numeric value>"
target: "<comparison operator> <value>"  # e.g., "< 200" or "> 90"
guard_rails:
  - test_command: "<command>"
  - lint_command: "<command>"
max_iterations: 25
scope:
  include: ["src/", "lib/"]
  exclude: ["node_modules/", "dist/"]
```

### Verify Command Requirements
The verify command MUST:
1. Accept no interactive input
2. Complete within 60 seconds
3. Output a single numeric value (or output parseable to extract one)
4. Be deterministic within 10% variance across runs
5. Exit with code 0 on success

Examples of valid verify commands:
```bash
# HTTP response time (milliseconds)
curl -s -o /dev/null -w '%{time_total}' http://localhost:3000/api/endpoint | awk '{printf "%.0f", $1*1000}'

# Bundle size (bytes)
npm run build --silent && stat -f%z dist/bundle.js

# Test execution time (seconds)
{ time npm test --silent; } 2>&1 | grep real | awk '{print $2}' | sed 's/[ms]//g'

# Lines of code
find src -name "*.ts" | xargs wc -l | tail -1 | awk '{print $1}'

# Memory usage (KB)
node -e "const m = require('./dist'); setTimeout(() => console.log(Math.round(process.memoryUsage().heapUsed / 1024)), 1000)"

# Custom benchmark
npm run bench -- --json 2>/dev/null | jq '.results[0].ops_per_sec'
```

### Loop Iteration Protocol

Each iteration follows this exact sequence:

```
ITERATION N:
├── 1. ANALYZE
│   ├── Read code in scope
│   ├── Review previous iteration results
│   └── Form hypothesis (observation → theory → proposed change → expected impact)
│
├── 2. COMMIT CHECKPOINT
│   └── git stash (if uncommitted changes from previous work)
│
├── 3. MODIFY
│   ├── Make ONE logical change
│   ├── Stay within scope
│   └── Don't break public interfaces
│
├── 4. GUARD RAILS
│   ├── Run test command → must pass
│   ├── Run lint command → must pass
│   └── If any guard rail fails → REVERT immediately
│
├── 5. MEASURE
│   ├── Run verify command (run 1)
│   ├── Run verify command (run 2)
│   ├── Run verify command (run 3)
│   └── Calculate median
│
├── 6. COMPARE
│   ├── Calculate delta from PREVIOUS iteration (not just baseline)
│   ├── Calculate cumulative delta from BASELINE
│   └── Determine verdict: IMPROVED / NO CHANGE / REGRESSED
│
├── 7. DECIDE
│   ├── If IMPROVED: git commit with results
│   ├── If NO CHANGE: git revert HEAD (change didn't help)
│   └── If REGRESSED: git revert HEAD (change made things worse)
│
├── 8. LOG
│   └── Append row to .godmode/optimize-results.tsv
│
└── 9. CONTINUE?
    ├── Target reached? → STOP (success)
    ├── Max iterations? → STOP (limit reached)
    ├── 3 consecutive reverts? → STOP (diminishing returns)
    └── Otherwise → next iteration
```

### Measurement Protocol
To ensure reliable measurements:

```
MEASUREMENT:
1. Warm up: Run verify command once, discard result (primes caches, JIT, etc.)
2. Run 1: Execute verify command, record value
3. Run 2: Execute verify command, record value
4. Run 3: Execute verify command, record value
5. Median: Sort values, take middle value
6. Variance: If max-min > 20% of median, warn about instability
```

If variance is too high:
```
WARNING: Measurement instability detected.
Values: 150, 340, 180 (variance: 126%)
Possible causes:
- Server not fully warmed up
- Background processes interfering
- Network latency variation
- Non-deterministic code paths

Recommendation: Run 5 measurements instead of 3, or isolate the environment.
```

### Revert Protocol
When reverting:

```bash
# Revert the change
git revert HEAD --no-edit

# Verify the revert worked (metric should return to pre-change value)
<verify_command>  # Should match the value before this iteration's change
```

If the revert doesn't restore the previous value:
```
WARNING: Revert did not restore previous metric value.
Before change: 401ms
After change: 450ms
After revert: 415ms (expected ~401ms)

This suggests the change had side effects not captured by the revert.
Recommendation: Manual inspection of the revert diff.
```

### Stopping Conditions

| Condition | Action |
|-----------|--------|
| Target reached | Stop, report SUCCESS |
| Max iterations reached | Stop, report LIMIT REACHED |
| 3 consecutive reverts | Stop, report DIMINISHING RETURNS |
| Guard rail cannot be restored | Stop, report GUARD RAIL FAILURE |
| Verify command fails | Stop, report MEASUREMENT FAILURE |
| User interrupts | Stop, report INTERRUPTED (save state for --resume) |

### Results Log Format
Tab-separated values (TSV) for easy analysis:

```
# .godmode/optimize-results.tsv
# Fields: iteration, timestamp, hypothesis, change_description, file_changed, baseline_value, measured_value, delta_pct, cumulative_delta_pct, verdict, commit_sha
1	2024-01-15T10:23:00Z	"N+1 query"	"Add eager loading"	src/services/product.ts	847	612	-27.7	-27.7	KEEP	abc1234
2	2024-01-15T10:31:00Z	"Missing index"	"Add idx on user_id"	migrations/add-index.sql	612	401	-34.5	-52.7	KEEP	def5678
3	2024-01-15T10:38:00Z	"JSON overhead"	"Stream JSON response"	src/controllers/product.ts	401	415	+3.5	-51.0	REVERT	ghi9012
4	2024-01-15T10:45:00Z	"Connection pool"	"Increase pool to 20"	src/config/database.ts	401	328	-18.2	-61.3	KEEP	jkl3456
```

### Resume Protocol
When resuming a paused optimization:

```
1. Read .godmode/optimize-results.tsv
2. Identify the last iteration number and commit SHA
3. Verify current git HEAD matches the expected state
4. Re-measure current value (may differ if time has passed)
5. Update baseline to the current measured value
6. Continue from iteration N+1
```

## Hypothesis Generation Strategies

When forming hypotheses, use this priority order:

### Priority 1: Profile-Guided
If profiling data is available, attack the hottest code path.
```
Profile shows 60% of time spent in serializeProducts().
Hypothesis: Optimize the serialization function.
```

### Priority 2: Algorithmic
Look for inefficient algorithms (O(n^2) where O(n) is possible).
```
Found nested loop iterating products × categories.
Hypothesis: Pre-index categories by ID for O(1) lookup.
```

### Priority 3: I/O-Bound
Look for unnecessary I/O (database queries, file reads, network calls).
```
Found 47 individual SQL queries per request (N+1 pattern).
Hypothesis: Batch into a single query with JOIN or IN clause.
```

### Priority 4: Caching
Look for repeated computations with the same inputs.
```
calculateTax() called with same parameters on every item.
Hypothesis: Memoize tax calculation per (rate, region) tuple.
```

### Priority 5: Configuration
Look for suboptimal configuration (pool sizes, timeouts, batch sizes).
```
Database connection pool set to 5, but 20 concurrent requests expected.
Hypothesis: Increase pool size to match expected concurrency.
```

### Priority 6: Structural
Look for unnecessary work (unused imports, dead code, redundant computation).
```
Response includes 40 fields but client uses only 8.
Hypothesis: Add field selection to return only requested fields.
```
