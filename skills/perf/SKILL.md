---
name: perf
description: |
  Performance profiling & optimization skill. Activates when code needs CPU profiling, memory leak detection, concurrency bug hunting, or benchmarking with statistical rigor. Covers flame graph analysis, allocation tracking, race condition and deadlock detection, and benchmarking methodology with confidence intervals. Every finding includes profiling evidence, root cause analysis, and measured remediation. Triggers on: /godmode:perf, "profile", "memory leak", "race condition", "deadlock", "benchmark", "flame graph", "slow", "bottleneck".
---

# Perf — Performance Profiling & Optimization

## When to Activate
- User invokes `/godmode:perf`
- User says "profile this", "find the bottleneck", "memory leak", "why is this slow"
- User mentions "flame graph", "CPU profiling", "race condition", "deadlock"
- User asks "benchmark this", "is this fast enough", "compare performance"
- When `/godmode:optimize` needs deeper analysis of a bottleneck
- When production monitoring shows performance degradation
- When concurrency bugs cause intermittent failures

## Workflow

### Step 1: Profiling Strategy
Determine what to profile and how:

```
PROFILING PLAN:
Target: <application/service/function>
Symptom: <what the user observed — slow response, high CPU, OOM, etc.>
```
### Step 2: CPU Profiling & Flame Graph Analysis
Identify where CPU time is spent:

#### Flame Graph Interpretation
```
FLAME GRAPH ANALYSIS:

Reading a flame graph:
```

For each CPU bottleneck found:
```
CPU FINDING <N>:
Function: <name>
Location: <file>:<line>
```

Root cause: <why this code is slow>
Impact: <N>% of total CPU time

Remediation:
```<language>
<the optimized code>
```

Expected improvement: <percentage reduction in CPU for this path>
```

### Step 3: Memory Leak Detection & Allocation Tracking
Find memory leaks and excessive allocations. Use language-native tools: Node.js (--heap-prof, Chrome DevTools), Python (tracemalloc), Go (pprof), Rust (DHAT), Java (JFR+JMC), C/C++ (Valgrind, ASan).

Leak detection: baseline memory -> apply load -> analyze growth pattern (constant=ok, linear=leak, stepped=periodic leak) -> diff heap snapshots -> trace allocation site -> fix -> verify stable.

For each memory finding:
```
MEMORY FINDING <N>:
Type: LEAK | EXCESSIVE ALLOCATION | FRAGMENTATION | CACHE UNBOUNDED
Source: <file>:<line>
Object type: <the allocated/leaked object type>
Growth rate: <MB per hour / per request / per iteration>

Evidence:
  Heap snapshot diff:
    <ObjectType>: +<N> instances (+<M> MB) over <duration>

  Allocation trace:
    <stack trace showing where objects are allocated>

  Retention chain (for leaks):
    <root → ... → leaked object>
    Why not collected: <reference preventing GC>

Remediation:
```<language>
<the fixed code — remove reference, add cleanup, bound cache, etc.>
```

Verification:
  Before: <N>MB after 1000 requests
  After: <N>MB after 1000 requests (stable)
```

### Step 4: Concurrency Bug Detection
Find race conditions, deadlocks, and data corruption:
```
RACE CONDITION DETECTION:

Static analysis patterns:
  - Shared mutable state without synchronization
  - Read-modify-write without atomic operations
  - Check-then-act without holding lock (TOCTOU)
  - Publishing mutable object to another thread without happens-before

Dynamic detection tools:
  Go: go test -race / go run -race (ThreadSanitizer)
  Rust: miri (experimental), cargo test with sanitizers
  C/C++: -fsanitize=thread (ThreadSanitizer)
  Java: -XX:+UseThreadSanitizer, FindBugs/SpotBugs concurrency checks
  Python: threading debug mode, sys.settrace for lock ordering
  Node.js: single-threaded by default, but worker_threads + SharedArrayBuffer can race

Common race condition patterns:
  1. Counter without atomic increment
  2. Lazy initialization without synchronization (double-checked locking done wrong)
  3. Collection modified while being iterated
  4. File handle shared between threads/goroutines
  5. Database read-modify-write without transaction
```

#### Deadlock Detection
Detect via: lock ordering violations, unbounded waits, channel deadlocks. Tools: Go (goroutine dump), Java (jstack), Python (faulthandler), C/C++ (gdb). Prevent with: consistent lock ordering, try-lock with timeout, channels over shared memory, timeouts on all blocking ops.

For each concurrency finding:
```
CONCURRENCY FINDING <N>:
Type: RACE CONDITION | DEADLOCK | LIVELOCK | STARVATION
Severity: CRITICAL | HIGH | MEDIUM
Code path: <file>:<line>

Scenario:
  Thread/goroutine 1: <sequence of operations>
  Thread/goroutine 2: <sequence of operations>
  Conflict: <what happens when they interleave>

Evidence:
```<language>
<the concurrent code with annotated race/deadlock points>
```

Impact:
  - <data corruption | crash | hang | incorrect result>
  - Reproducibility: <always | under load | intermittent | rare>

Remediation:
```<language>
<the fixed concurrent code>
```

Concurrency mechanism used: <mutex | atomic | channel | transaction | lock-free>
```

### Step 5: Benchmarking Methodology
Measure performance with statistical rigor:
```
BENCHMARKING PROTOCOL:
1. Environment: dedicated hardware, disable frequency scaling, warm up JIT/caches
2. Measurement: warm-up iterations + measurement iterations, discard outliers
3. Statistics: report mean, median, p95, p99, stddev, 95% CI. CV > 10% = unstable.
4. Comparison (A vs B): interleaved runs, Welch's t-test, p < 0.05 = significant
```

For each benchmark:
```
BENCHMARK: <name> | Target: <function> | Env: <hardware, runtime>
Mean: <value> +/- <std dev> | Median: <value> | P95/P99: <value>/<value>
95% CI: [<lower>, <upper>] | Throughput: <ops/sec>
```

### Step 6: Profiling Report

```
  PERFORMANCE PROFILE — <target>
  CPU Profiling:
  Top hotspots:
  1. <function> — <N>% CPU
  2. <function> — <N>% CPU
  3. <function> — <N>% CPU
  Flame graph: <path to generated flame graph>
  Memory:
  Leaks found: <N>
  Growth rate: <N>MB/hour (target: stable)
  Peak RSS: <N>MB
  Top allocators:
  1. <site> — <N>MB allocated
  2. <site> — <N>MB allocated
  Concurrency:
  Race conditions: <N>
  Deadlock risks: <N>
  Lock contention hotspots: <N>
  Benchmarks:
  <benchmark 1>: <value> (target: <target>)
  <benchmark 2>: <value> (target: <target>)
  Findings: <total>
  CRITICAL: <N>  HIGH: <N>  MEDIUM: <N>  LOW: <N>
  Priority fixes:
  1. <highest impact finding>
  2. <second highest impact finding>
  3. <third highest impact finding>
  Next: /godmode:optimize — Autonomous optimization loop
  /godmode:fix — Fix critical findings
```

### Step 7: Commit and Transition
1. Save flame graphs and profiles: `docs/perf/<target>-profile/`
2. Auto-detect runtime from manifest files, existing profiling tools, build config, and benchmarks.

## Autonomous Operation
- Loop until all hotspots addressed or budget exhausted. Never pause.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## HARD RULES

1. **NEVER optimize without profiling first.** Developers' intuition about performance is wrong more often than right. Profile, then optimize.
2. **NEVER report benchmark results without confidence intervals.** "150ms" is meaningless. "150ms mean (95% CI: [142, 158], n=50)" is meaningful.
3. **NEVER benchmark on noisy/shared systems for final results.** CI runners with other jobs produce unreliable data. Control the environment.
4. **NEVER skip warm-up iterations.** JIT-compiled languages (Java, Node.js, .NET) perform dramatically differently after warm-up. Discard initial runs.
5. **NEVER profile debug/development builds.** Always profile release/production builds. Debug builds have different performance characteristics.
  ...
```
After EACH performance fix:
  1. MEASURE: Re-run the profiler or benchmark (minimum 5 runs for statistical confidence).
  2. COMPARE: Did the target metric improve? Is the change statistically significant (p < 0.05)?
  3. DECIDE:
     - KEEP if: improvement is significant AND no regression in other metrics AND tests pass
     - DISCARD if: no significant improvement OR regression in another metric OR tests fail
  4. COMMIT kept changes with before/after numbers. Revert discarded changes before the next fix.

Never keep an optimization without measured before/after evidence.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All hotspots consuming > 10% CPU are identified and addressed
  - Memory is stable under sustained load (no leaks)
  - Zero race conditions detected by sanitizer tools
  - User explicitly requests stop
  - Optimization plateau: 3 consecutive fixes produce < 5% improvement

DO NOT STOP only because:
  - Minor hotspots (< 5% CPU) remain (diminishing returns)
  - Benchmarks show unstable variance (fix the environment, not the code)
```

## Output Format
Print on completion: `Perf: {finding_count} findings ({critical} critical, {high} high). CPU hotspot: {top_hotspot} ({cpu_pct}%). Memory: {leak_status}. Concurrency: {race_count} races, {deadlock_count} deadlocks. Top fix: {top_fix} ({improvement}% improvement).`
```
iteration	module	finding_type	location	severity	metric_before	metric_after	status
1	cpu	hotspot	formatCurrency:45	critical	8247ms	423ms	fixed
2	memory	leak	EventCache:120	high	+50MB/hr	stable	fixed
3	concurrency	race	Counter:33	critical	data_corruption	safe	fixed
```
Columns: iteration, module(cpu/memory/concurrency/benchmark), finding_type, location, severity, metric_before, metric_after, status(fixed/open/wontfix).

## Error Recovery
| Failure | Action |
|--|--|
| Profiler shows no clear hotspot | Check sampling rate is sufficient. Profile under realistic load, not idle. Try a different profiler (CPU vs memory vs I/O). |
| Optimization regresses another metric | Measure all key metrics before and after. Use A/B testing for production changes. Revert if tradeoff is unacceptable. |
| Benchmark results are noisy | Increase iterations. Pin CPU frequency. Disable turbo boost. Run on dedicated hardware. Warm up JIT before measuring. |
