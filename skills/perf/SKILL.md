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
Language/Runtime: <Node.js | Python | Go | Rust | Java/Kotlin | Swift | C/C++>

Profiling modules:
  [ ] CPU profiling — where is time being spent?
  [ ] Memory profiling — where is memory being allocated/leaked?
  [ ] Concurrency analysis — are there race conditions or deadlocks?
  [ ] Benchmarking — how fast is this compared to alternatives?

Profiling approach:
  - Sampling profiler (low overhead, statistical): <for production use>
  - Instrumentation profiler (exact, high overhead): <for development use>
  - Tracing (request-level): <for distributed systems>
```

### Step 2: CPU Profiling & Flame Graph Analysis
Identify where CPU time is spent:

#### Profiling Tools by Language
```
CPU PROFILING TOOLS:
Node.js:
  - Built-in: node --prof / --cpu-prof
  - Clinic.js: clinic flame -- node app.js
  - 0x: 0x app.js (generates flame graphs)

Python:
  - cProfile: python -m cProfile -o output.prof script.py
  - py-spy: py-spy record -o profile.svg -- python script.py (sampling, low overhead)
  - Scalene: scalene script.py (CPU + memory + GPU)

Go:
  - pprof: import _ "net/http/pprof" (built-in)
  - go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
  - go tool trace (execution tracer)

Rust:
  - perf: perf record --call-graph dwarf ./target/release/app
  - flamegraph: cargo flamegraph
  - criterion: benchmarking with statistical analysis

Java/Kotlin:
  - JFR: -XX:StartFlightRecording=duration=30s,filename=rec.jfr
  - async-profiler: ./profiler.sh -d 30 -f profile.html <pid>
  - VisualVM: GUI-based profiling

Swift/iOS:
  - Instruments: Time Profiler template
  - Xcode: Debug Navigator → CPU gauge
  - os_signpost: custom instrumentation

C/C++:
  - perf: perf record -g ./app && perf report
  - Valgrind (callgrind): valgrind --tool=callgrind ./app
  - Intel VTune: vtune -collect hotspots -- ./app
```

#### Flame Graph Interpretation
```
FLAME GRAPH ANALYSIS:

Reading a flame graph:
  - X-axis: sample population (NOT time — wider = more samples = more CPU time)
  - Y-axis: stack depth (bottom = entry point, top = leaf functions)
  - Color: arbitrary (used for visual distinction, not meaning)

What to look for:
  1. PLATEAUS: Wide flat tops indicate functions consuming significant CPU
     → These are your optimization targets

  2. TOWERS: Tall narrow stacks indicate deep call chains
     → May indicate excessive abstraction or recursion

  3. GAPS: Functions you expect to see but don't appear
     → May be inlined or below sampling threshold

Common bottleneck patterns:
  Pattern: JSON serialization/deserialization plateau
  Cause: Large objects being serialized on hot path
  Fix: Stream serialization, reduce object size, cache serialized form

  Pattern: Regex compilation in hot loop
  Cause: Regex compiled on every iteration instead of once
  Fix: Compile regex outside loop, use compiled/static regex

  Pattern: GC/memory allocation plateau
  Cause: Excessive allocations triggering garbage collection
  Fix: Object pooling, reduce allocations, pre-allocate buffers

  Pattern: Lock contention plateau (futex/mutex wait)
  Cause: Threads waiting on shared lock
  Fix: Reduce critical section size, use lock-free structures, partition data
```

For each CPU bottleneck found:
```
CPU FINDING <N>:
Function: <name>
Location: <file>:<line>
CPU share: <percentage of total samples>
Call path: <caller → ... → this function>

Evidence:
```<language>
<the hot code path>
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

#### Memory Profiling Tools
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
Object type: <what is being allocated/leaked>
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

#### Race Condition Detection
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
Target: <what is being benchmarked>
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
2. Save report: `docs/perf/<target>-perf-report.md`
3. Commit: `"perf: <target> — <N> findings (<top finding summary>)"`
4. If critical findings: "Performance issues found. Run `/godmode:fix` for quick fixes or `/godmode:optimize` for systematic improvement."
5. If benchmarks needed: "Profiling complete. Run benchmarks with `/godmode:perf --bench` to establish baselines."

## Key Behaviors

1. **Profile before optimizing.** Never guess where the bottleneck is. Profile first, then optimize the proven hotspot. Developers' intuition about performance is wrong more often than right.
2. **Statistical rigor in benchmarks.** A single run is not a benchmark. Report confidence intervals, check for significance, control for noise. Otherwise you're measuring randomness.
3. **Flame graphs are mandatory.** For CPU profiling, always generate a flame graph. It communicates more information in one image than pages of profiler output.
4. **Memory leaks need proof.** "Memory grows" is not proof of a leak. Show the retention chain — what is holding the reference that prevents collection?
5. **Concurrency bugs need reproduction scenarios.** Describe the exact interleaving that causes the bug. "It sometimes crashes under load" is not a finding. Show which threads, which operations, which ordering.
6. **Measure the fix.** Every performance remediation must include before/after measurements. Without measurement, you don't know if you helped or hurt.

## Example Usage

### Profiling a slow API endpoint
```
User: /godmode:perf The /api/reports endpoint takes 8 seconds

Perf: Setting up profiling...

PROFILING PLAN:
Target: GET /api/reports
Symptom: 8 second response time
Language: Node.js (Express)

CPU Profile (30 seconds under load):
  1. generateReport() — 62% CPU
     └── formatCurrency() — 41% CPU (called 50,000 times per request)
         └── new Intl.NumberFormat() — 38% CPU (constructed inside loop)
  2. JSON.stringify(report) — 18% CPU (large response object)
  3. Database query — 12% CPU

Top finding:
  Intl.NumberFormat constructed 50,000 times per request.
  Constructor is expensive (~0.15ms each = 7.5 seconds total).

  Fix: Cache the formatter instance.

  Before: 8,247ms mean (n=10, CI: [7,891, 8,603])
  After:    423ms mean (n=10, CI: [398, 448])

  Improvement: 94.9% (p < 0.001, statistically significant)

Next: /godmode:optimize for further improvements
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full profiling (CPU + memory + concurrency scan) |
| `--cpu` | CPU profiling and flame graph only |
| `--memory` | Memory profiling and leak detection only |
| `--concurrency` | Race condition and deadlock detection only |
| `--bench` | Run benchmarks with statistical analysis |
| `--compare` | Compare two implementations (A/B benchmark) |
| `--duration <N>` | Profiling duration in seconds (default: 30) |
| `--flamegraph` | Generate flame graph from existing profile data |
| `--leak-check` | Extended memory leak detection (longer observation) |

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

## Auto-Detection

Before profiling, detect the runtime environment and existing instrumentation:

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

## Explicit Loop Protocol

Performance optimization is iterative -- profile, fix, measure, repeat:

```
current_iteration = 0
modules = [cpu_profiling, memory_profiling, concurrency_analysis, benchmarking]
findings = []

WHILE modules is not empty AND current_iteration < 12:
    current_iteration += 1
    module = modules.pop(0)

    1. PROFILE: run the appropriate profiler for this module
    2. ANALYZE: interpret flame graph / heap snapshot / thread dump
    3. FOR each hotspot/leak/race found:
       a. DIAGNOSE root cause with evidence
       b. IMPLEMENT fix
       c. RE-PROFILE to measure improvement
       d. RECORD: before/after metrics with confidence intervals
    4. IF fix introduces regression in another area:
        modules.append(regressed_module)
    5. IF improvement < 5% AND more hotspots exist:
        CONTINUE to next hotspot
    6. REPORT: "Module {module}: {N} findings, {total_improvement}% improvement -- iteration {current_iteration}"

OUTPUT: Performance profile report with all findings and measured remediations.
```

## Multi-Agent Dispatch

For comprehensive performance analysis, dispatch parallel agents:

```
MULTI-AGENT PERFORMANCE ANALYSIS:
Dispatch 3-4 agents in parallel worktrees.

Agent 1 (worktree: perf-cpu):
  - Run CPU profiler under representative load
  - Generate flame graph
  - Identify top 5 hotspots with evidence
  - Implement and measure fixes for each

Agent 2 (worktree: perf-memory):
  - Take heap snapshots before/after load
  - Identify memory leaks via snapshot diffing
  - Trace retention chains for leaked objects
  - Fix leaks and verify memory stabilizes

Agent 3 (worktree: perf-concurrency):
  - Run with race detector enabled (Go -race, TSan, etc.)
  - Identify data races and deadlock risks
  - Verify lock ordering consistency
  - Fix races and verify under concurrent load

Agent 4 (worktree: perf-benchmarks):
  - Establish baseline benchmarks with statistical rigor
  - Run comparison benchmarks for proposed optimizations
  - Report with confidence intervals and p-values
  - Create regression benchmark suite for CI

MERGE ORDER: cpu -> memory -> concurrency -> benchmarks
CONFLICT ZONES: Hot path code changes, lock/synchronization changes
```

## Anti-Patterns

- **Do NOT optimize without profiling.** "This loop looks slow" is not evidence. Profile it. The bottleneck is almost never where you think it is.
- **Do NOT report benchmark results without confidence intervals.** "It runs in 150ms" is meaningless. "150ms mean (95% CI: [142, 158], n=50)" is meaningful.
- **Do NOT benchmark on noisy systems.** A shared CI runner with other jobs running produces unreliable results. Control the environment or report high variance.
- **Do NOT ignore warm-up.** JIT-compiled languages (Java, Node.js, .NET) perform dramatically differently after warm-up. Discard initial iterations.
- **Do NOT use wall-clock time for micro-benchmarks.** Use high-resolution timers (performance.now(), time.monotonic_ns(), std::time::Instant). Wall-clock time includes OS scheduling noise.
- **Do NOT claim "no memory leak" from a 30-second test.** Some leaks only manifest over hours or days. Match the test duration to the expected runtime.
- **Do NOT dismiss intermittent concurrency bugs.** "It only happens sometimes" means there IS a bug. Race conditions are deterministic in their cause, even if timing-dependent in their manifestation.
- **Do NOT profile debug builds.** Debug builds have extra instrumentation, assertions, and disabled optimizations that completely change the performance profile. Always profile release/production builds.
