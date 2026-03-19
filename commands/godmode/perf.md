# /godmode:perf

Performance profiling & optimization — CPU profiling with flame graph analysis, memory leak detection, concurrency bug detection (race conditions, deadlocks), and benchmarking with statistical significance. Every finding includes profiling evidence and measured remediation.

## Usage

```
/godmode:perf                          # Full profiling (CPU + memory + concurrency)
/godmode:perf --cpu                    # CPU profiling and flame graph
/godmode:perf --memory                 # Memory profiling and leak detection
/godmode:perf --concurrency            # Race condition and deadlock detection
/godmode:perf --bench                  # Benchmarks with statistical analysis
/godmode:perf --compare                # A/B benchmark comparison
/godmode:perf --duration 60            # Profile for 60 seconds
/godmode:perf --flamegraph             # Generate flame graph from profile data
/godmode:perf --leak-check             # Extended memory leak detection
```

## What It Does

1. Profiles CPU usage and generates flame graphs for visual bottleneck identification
2. Detects memory leaks through heap snapshot diffing and retention chain analysis
3. Tracks memory allocations to find excessive allocation hotspots
4. Scans for race conditions (shared mutable state, TOCTOU, read-modify-write)
5. Detects deadlock risks (lock ordering violations, unbounded waits)
6. Runs benchmarks with statistical rigor:
   - Warm-up iterations discarded
   - Multiple measurement runs with median/mean/percentiles
   - 95% confidence intervals
   - Welch's t-test for A/B comparisons
   - Coefficient of variation for stability assessment
7. Provides language-specific tooling recommendations (Node.js, Python, Go, Rust, Java, Swift, C/C++)

## Output
- Flame graphs at `docs/perf/<target>-profile/`
- Performance report at `docs/perf/<target>-perf-report.md`
- Commit: `"perf: <target> — <N> findings (<top finding>)"`
- Before/after measurements for every remediation

## Next Step
If critical findings: `/godmode:fix` for quick fixes.
For systematic improvement: `/godmode:optimize` for autonomous optimization loop.
If benchmarks pass: `/godmode:ship` to deploy.

## Examples

```
/godmode:perf                          # Full performance profile
/godmode:perf --cpu                    # Just CPU + flame graph
/godmode:perf --bench                  # Run benchmarks
/godmode:perf --compare                # Compare two implementations
```
