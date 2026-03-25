---
name: perf
description: Performance profiling -- CPU, memory, concurrency,
  benchmarking with statistical rigor.
---

## Activate When
- `/godmode:perf`, "profile this", "find bottleneck"
- "memory leak", "race condition", "deadlock"
- "benchmark", "flame graph", "why is this slow"

## Workflow

### 1. Profiling Strategy
```bash
# Node.js CPU profile
node --cpu-prof --cpu-prof-dir=./profiles app.js
# Go CPU profile
go tool pprof http://localhost:6060/debug/pprof/profile
# Python memory
python -c "import tracemalloc; tracemalloc.start()"
```
```
Target: <application/function>
Symptom: <slow response, high CPU, OOM, hang>
Language: <Node.js|Python|Go|Rust|Java>
```

### 2. CPU Profiling & Flame Graphs
For each hotspot found:
```
Function: <name> at <file>:<line>
CPU share: <N>% of total
Root cause: <why slow>
Remediation: <optimized code>
Expected improvement: <N>% reduction
```
IF hotspot >10% CPU: must address.
IF hotspot <5% CPU: diminishing returns.

### 3. Memory Leak Detection
Tools: Node.js (--heap-prof), Python (tracemalloc),
Go (pprof), Rust (DHAT), Java (JFR+JMC).

Pattern: baseline -> load -> analyze growth.
- Constant: OK
- Linear: leak
- Stepped: periodic leak

For each finding:
```
Type: LEAK | EXCESSIVE ALLOCATION | UNBOUNDED CACHE
Source: <file>:<line>
Growth rate: <MB per hour/request>
Retention chain: <root -> ... -> leaked object>
```
IF growth is linear under load: confirmed leak.
IF cache grows without bound: add max size + eviction.

### 4. Concurrency Bug Detection
```bash
# Go race detector
go test -race ./...
# C/C++ thread sanitizer
gcc -fsanitize=thread -o app app.c && ./app
```
Common patterns: counter without atomic, lazy init
without sync, collection modified during iteration,
read-modify-write without transaction.

For each finding:
```
Type: RACE | DEADLOCK | LIVELOCK | STARVATION
Severity: CRITICAL | HIGH | MEDIUM
Code path: <file>:<line>
Reproducibility: always | under load | intermittent
```

Deadlock prevention: consistent lock ordering,
try-lock with timeout, channels over shared memory.

### 5. Benchmarking
```
Protocol:
1. Dedicated hardware, disable frequency scaling
2. Warm-up iterations + measurement iterations
3. Report: mean, median, p95, p99, stddev, 95% CI
4. CV > 10% = unstable environment
5. Comparison: interleaved runs, Welch's t-test,
   p < 0.05 = statistically significant
```
IF benchmark variance >10%: fix environment first.
NEVER benchmark on shared CI runners for final results.
NEVER skip warm-up for JIT languages (Node, Java).

### 6. Report
```
CPU: top 3 hotspots with % and file:line
Memory: leaks found, growth rate, peak RSS
Concurrency: races, deadlock risks, contention
Benchmarks: values with 95% CI
Priority fixes: ordered by impact
```

## Hard Rules
1. NEVER optimize without profiling first.
2. NEVER benchmark without confidence intervals.
3. NEVER benchmark on noisy/shared systems.
4. NEVER skip warm-up iterations (JIT languages).
5. NEVER profile debug builds (use release/prod).
6. ALWAYS measure before and after optimization.
7. ALWAYS report p95/p99, not just mean.

## TSV Logging
Append `.godmode/perf-results.tsv`:
```
timestamp	module	finding_type	location	severity	metric_before	metric_after	status
```

## Keep/Discard
```
KEEP if: improvement is statistically significant
  AND no regression AND tests pass.
DISCARD if: no significant improvement OR regression.
Never keep optimization without measured evidence.
```

## Stop Conditions
```
STOP when FIRST of:
  - All hotspots >10% CPU addressed
  - Memory stable under sustained load
  - Zero races detected by sanitizer
  - 3 consecutive fixes < 5% improvement
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| No clear hotspot | Check sampling rate, profile under load |
| Optimization regresses | Measure all metrics, revert if needed |
| Noisy benchmarks | Pin CPU, disable turbo, dedicated HW |
