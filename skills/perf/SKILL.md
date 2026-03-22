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

#### Profiling Tools by Language
```
CPU PROFILING TOOLS:
Node.js:
  - Built-in: node --prof / --cpu-prof
```

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
Find memory leaks and excessive allocations:
```
MEMORY PROFILING TOOLS:
Node.js:
  - --inspect + Chrome DevTools Memory tab (heap snapshots)
  - node --heap-prof (V8 heap profiler)
  - clinic heapprofiler -- node app.js

Python:
  - tracemalloc: built-in memory tracking
  - memory_profiler: @profile decorator, line-by-line memory
  - objgraph: object reference graph visualization

Go:
  - pprof: go tool pprof http://localhost:6060/debug/pprof/heap
  - GODEBUG=gctrace=1 (GC activity tracing)
  - runtime.ReadMemStats() (programmatic monitoring)

Rust:
  - DHAT: valgrind --tool=dhat ./target/release/app
  - jemalloc + jeprof: allocation profiling
  - Memory is statically managed — leaks are rare but possible with Rc/Arc cycles

Java/Kotlin:
  - JFR + JMC: Flight Recorder memory events
  - Eclipse MAT: heap dump analysis
  - jmap -dump:format=b,file=heap.bin <pid>

Swift/iOS:
  - Instruments: Leaks + Allocations templates
  - Xcode Memory Graph Debugger (Debug → Debug Workflow → View Memory Graph)
  - MallocStackLogging for allocation tracking

C/C++:
  - Valgrind (memcheck): valgrind --leak-check=full ./app
  - AddressSanitizer: -fsanitize=address
  - Heaptrack: heaptrack ./app && heaptrack_gui heaptrack.*.zst
```

#### Leak Detection Methodology
```
MEMORY LEAK DETECTION:

Step 1: Establish baseline memory usage
  - Start application, let it stabilize (GC runs, caches warm)
  - Record: RSS, heap used, object count

Step 2: Apply load
  - Run representative workload for N iterations/minutes
  - Record memory at regular intervals

Step 3: Analyze growth pattern
  - Constant memory: no leak
  - Linear growth: leak proportional to activity (classic leak)
  - Stepped growth: leak per N operations (periodic leak)
  - Logarithmic growth: cache growing without eviction (bounded but wasteful)

Step 4: Identify leak source
  - Take heap snapshot BEFORE load
  - Take heap snapshot AFTER load
  - Diff snapshots: objects that grew in count/size = candidates
  - For each candidate: trace allocation site and reference chain

Step 5: Verify fix
  - Apply fix, repeat steps 1-3
  - Memory should stabilize after warmup
```

For each memory finding:
```
MEMORY FINDING <N>:
Type: LEAK | EXCESSIVE ALLOCATION | FRAGMENTATION | CACHE UNBOUNDED
Location: <file>:<line>
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
  Node.js: typically single-threaded, but worker_threads + SharedArrayBuffer can race

Common race condition patterns:
  1. Counter without atomic increment
  2. Lazy initialization without synchronization (double-checked locking done wrong)
  3. Collection modified while being iterated
  4. File handle shared between threads/goroutines
  5. Database read-modify-write without transaction
```

#### Deadlock Detection
```
DEADLOCK DETECTION:

Static analysis:
  - Lock ordering violations: Thread A locks [M1, M2], Thread B locks [M2, M1]
  - Channel/pipe operations that can block indefinitely
  - Unbounded waits without timeout

Dynamic detection:
  Go: goroutine dump (SIGQUIT / runtime.Stack)
  Java: jstack <pid> / Thread dump in JMC
  Python: faulthandler.dump_traceback()
  C/C++: gdb → thread apply all bt

Common deadlock patterns:
  1. Lock ordering inconsistency (A→B vs B→A)
  2. Lock held while calling external function that acquires same lock
  3. Channel send blocking because receiver already exited
  4. Database row-level locks in conflicting order
  5. Connection pool exhaustion (all connections held, new request waits)

Prevention strategies:
  - Always acquire locks in consistent global order
  - Use try-lock with timeout instead of blocking lock
  - Prefer lock-free data structures where possible
  - Use channels/message passing instead of shared memory
  - Set timeouts on all blocking operations
```

For each concurrency finding:
```
CONCURRENCY FINDING <N>:
Type: RACE CONDITION | DEADLOCK | LIVELOCK | STARVATION
Severity: CRITICAL | HIGH | MEDIUM
Location: <file>:<line>

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

1. Environment preparation:
   - Disable CPU frequency scaling (governor = performance)
   - Close non-essential processes
   - Pin process to specific CPU core(s) if possible
   - Warm up JIT/caches before measuring
   - Use dedicated hardware (not shared CI/CD runner for final benchmarks)

2. Measurement methodology:
   - Minimum iterations: enough to achieve target confidence
   - Warm-up iterations: discard first N runs (JIT compilation, cache warming)
   - Measurement iterations: collect M data points after warm-up
   - Cool-down: optional pause between iterations to prevent thermal throttling

3. Statistical analysis:
   - Report: mean, median, standard deviation, min, max
   - Compute 95% confidence interval for the mean
   - Minimum sample size for 95% CI with 5% margin:
     n = (Z * s / E)^2 where Z=1.96, s=sample std dev, E=margin
   - Check for outliers: values > 3 standard deviations from mean
   - Report coefficient of variation (CV = stddev/mean) — if CV > 10%, results are unstable

4. Comparison protocol (A vs B):
   - Run A and B interleaved (not sequentially) to control for drift
   - Use paired measurements where possible
   - Apply Welch's t-test (or Mann-Whitney U for non-normal distributions)
   - Report p-value: p < 0.05 = statistically significant
   - Report effect size: "B is X% faster (95% CI: [lower, upper])"
   - If p >= 0.05: "No statistically significant difference detected"
```

#### Benchmarking Tools
```
BENCHMARKING TOOLS BY LANGUAGE:

Node.js:
  - Benchmark.js: robust statistical benchmarks
  - autocannon: HTTP load testing with latency percentiles
  - hyperfine: command-line benchmarking with warmup and statistical analysis

Python:
  - timeit: built-in micro-benchmarking (handles warmup)
  - pytest-benchmark: integration with pytest, comparison, histograms
  - locust: load testing with user simulation

Go:
  - testing.B: built-in benchmarks (go test -bench=.)
  - benchstat: statistical comparison of benchmark results
  - pprof integration: profile during benchmark

Rust:
  - criterion: statistical benchmarking with confidence intervals
  - divan: fast iteration benchmarks
  - cargo bench: built-in benchmark support

Java/Kotlin:
  - JMH: Java Microbenchmark Harness (the gold standard)
  - Manages JIT warmup, dead code elimination, loop unrolling
  - Reports mean, error, confidence intervals

General:
  - hyperfine: language-agnostic CLI benchmark tool
  - wrk / wrk2: HTTP benchmarking with latency correction
  - k6: modern load testing with scripting
```

For each benchmark result:
```
BENCHMARK: <name>
Target: <the benchmarked function/operation>
Environment: <hardware, OS, runtime version>

Results:
  Iterations: <N> (after <M> warm-up)
  Mean: <value> +/- <std dev>
  Median: <value>
  P95: <value>
  P99: <value>
  Min: <value>
  Max: <value>
  CV: <value>% (<STABLE if <5% | MODERATE if 5-10% | UNSTABLE if >10%>)

95% confidence interval: [<lower>, <upper>]
Throughput: <ops/sec or requests/sec>
```

For comparison benchmarks:
```
BENCHMARK COMPARISON: <A> vs <B>
Hypothesis: <B> is faster than <A>

         |    Mean    |  Median  |   P95    |   P99
---------|------------|----------|----------|----------
  A      | <value>    | <value>  | <value>  | <value>
  B      | <value>    | <value>  | <value>  | <value>
  Delta   | <value>    | <value>  | <value>  | <value>
  Change  | <+/-N%>    | <+/-N%>  | <+/-N%>  | <+/-N%>

Statistical test: Welch's t-test
  t-statistic: <value>
  p-value: <value>
  Significant: <YES (p < 0.05) | NO (p >= 0.05)>
  Effect size: <value>% (95% CI: [<lower>%, <upper>%])

Verdict: <B is X% faster (statistically significant) |
          No significant difference detected |
          A is X% faster (B is a regression)>
```

### Step 6: Profiling Report

```
┌────────────────────────────────────────────────────────────────┐
│  PERFORMANCE PROFILE — <target>                                │
├────────────────────────────────────────────────────────────────┤
│  CPU Profiling:                                                │
│    Top hotspots:                                               │
│    1. <function> — <N>% CPU                                    │
│    2. <function> — <N>% CPU                                    │
│    3. <function> — <N>% CPU                                    │
│    Flame graph: <path to generated flame graph>                │
│                                                                │
│  Memory:                                                       │
│    Leaks found: <N>                                            │
│    Growth rate: <N>MB/hour (target: stable)                    │
│    Peak RSS: <N>MB                                             │
│    Top allocators:                                              │
│    1. <site> — <N>MB allocated                                 │
│    2. <site> — <N>MB allocated                                 │
│                                                                │
│  Concurrency:                                                  │
│    Race conditions: <N>                                        │
│    Deadlock risks: <N>                                         │
│    Lock contention hotspots: <N>                               │
│                                                                │
│  Benchmarks:                                                   │
│    <benchmark 1>: <value> (target: <target>)                   │
│    <benchmark 2>: <value> (target: <target>)                   │
│                                                                │
│  Findings: <total>                                             │
│    CRITICAL: <N>  HIGH: <N>  MEDIUM: <N>  LOW: <N>            │
├────────────────────────────────────────────────────────────────┤
│  Priority fixes:                                               │
│  1. <highest impact finding>                                   │
│  2. <second highest impact finding>                            │
│  3. <third highest impact finding>                             │
│                                                                │
│  Next: /godmode:optimize — Autonomous optimization loop        │
│        /godmode:fix — Fix critical findings                    │
└────────────────────────────────────────────────────────────────┘
```

### Step 7: Commit and Transition
1. Save flame graphs and profiles: `docs/perf/<target>-profile/`
```
AUTO-DETECT SEQUENCE:
1. Runtime detection:
   - ls package.json → Node.js (check for "type": "module")
   - ls go.mod → Go
   - ls Cargo.toml → Rust
   - ls pyproject.toml / setup.py → Python
   - ls pom.xml / build.gradle → Java/Kotlin
   - ls *.xcodeproj / Package.swift → Swift

2. Profiling tools already available:
   - grep for "clinic\|0x\|pprof\|flamegraph\|criterion\|jmh" in dependencies
   - Check for existing profiles: ls *.cpuprofile *.heapprofile *.prof *.jfr

3. Build configuration:
   - Detect release/debug mode from build scripts
   - Check for optimization flags (-O2, --release, NODE_ENV=production)

4. Existing benchmarks:
   - ls **/*bench* **/*benchmark* tests/perf/
   - Detect benchmark framework from imports

5. Output: PROFILING PLAN auto-populated with detected tools and targets.
```

## HARD RULES

1. **NEVER optimize without profiling first.** Developers' intuition about performance is wrong more often than right. Profile, then optimize.
2. **NEVER report benchmark results without confidence intervals.** "150ms" is meaningless. "150ms mean (95% CI: [142, 158], n=50)" is meaningful.
3. **NEVER benchmark on noisy/shared systems for final results.** CI runners with other jobs produce unreliable data. Control the environment.
4. **NEVER skip warm-up iterations.** JIT-compiled languages (Java, Node.js, .NET) perform dramatically differently after warm-up. Discard initial runs.
5. **NEVER profile debug/development builds.** Always profile release/production builds. Debug builds have different performance characteristics.
6. **NEVER claim "no memory leak" from a test shorter than the expected runtime.** Some leaks only manifest over hours or days.
7. **NEVER dismiss intermittent concurrency bugs.** "It only happens sometimes" means there IS a bug. Race conditions are deterministic in cause.
8. **ALWAYS generate a flame graph for CPU profiling.** No exceptions. It communicates more than pages of profiler output.
9. **ALWAYS measure the fix.** Every remediation must include before/after measurements. Without measurement, you do not know if you helped or hurt.

## Keep/Discard Discipline
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

DO NOT STOP just because:
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
|---------|--------|
| Profiler shows no clear hotspot | Check sampling rate is sufficient. Profile under realistic load, not idle. Try a different profiler (CPU vs memory vs I/O). |
| Optimization regresses another metric | Measure all key metrics before and after. Use A/B testing for production changes. Revert if tradeoff is unacceptable. |
| Benchmark results are noisy | Increase iterations. Pin CPU frequency. Disable turbo boost. Run on dedicated hardware. Warm up JIT before measuring. |
| Memory optimization increases latency | Profile both metrics together. Check if GC pressure shifted rather than reduced. Use memory pooling or arena allocation. |

## Success Criteria
1. Target metric improved with statistical confidence (median of 3+ runs, <5% variance).
2. No regression in other key metrics (latency, throughput, memory).
3. All guard checks pass (build, lint, test).
4. Profiling evidence documents the optimization (before/after flamegraphs or metrics).

## TSV Logging
Append to `.godmode/perf-results.tsv`:
```
iteration	module	finding_type	location	severity	metric_before	metric_after	status
```
One row per finding or optimization. Status: fixed, open, wontfix.
