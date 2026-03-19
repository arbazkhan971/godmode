# /godmode:concurrent

Concurrency and parallelism engineering. Performs thread safety analysis, detects race conditions, designs async/await patterns, implements lock-free data structures, applies actor model patterns, prevents deadlocks, and creates concurrent testing strategies.

## Usage

```
/godmode:concurrent                        # Full concurrency analysis and design
/godmode:concurrent --analyze              # Thread safety analysis of existing code
/godmode:concurrent --race                 # Race condition detection and fixes
/godmode:concurrent --async                # Async/await pattern design
/godmode:concurrent --lockfree             # Lock-free data structure design
/godmode:concurrent --actor                # Actor model system design
/godmode:concurrent --deadlock             # Deadlock detection and prevention
/godmode:concurrent --test                 # Concurrent testing strategy
/godmode:concurrent --model                # Concurrency model selection guide
```

## What It Does

1. Assesses concurrency context (language, runtime, workload type, existing primitives)
2. Inventories all shared mutable state and classifies access patterns
3. Detects race conditions (check-then-act, read-modify-write, TOCTOU)
4. Designs async/await patterns for the target runtime (Node.js, Python, Go, Rust)
5. Recommends lock-free alternatives when locks are measured as bottlenecks
6. Designs actor systems with supervision trees and message protocols
7. Prevents deadlocks through lock ordering, timeouts, and resource hierarchies
8. Creates concurrent testing strategies (race detectors, stress tests, property tests)

## Output
- Thread safety analysis at `docs/concurrency/<feature>-thread-safety.md`
- Race condition report at `docs/concurrency/<feature>-race-analysis.md`
- Concurrent tests at `tests/concurrent/<feature>-concurrent.test.<ext>`
- Commit: `"concurrent: <feature> -- <model>, <N> shared states protected, <verdict>"`
- Verdict: SAFE / NEEDS WORK

## Next Step
If NEEDS WORK: Fix identified race conditions, then re-analyze.
If SAFE: `/godmode:loadtest` to verify behavior under concurrent load.

## Examples

```
/godmode:concurrent                        # Full analysis of concurrent code
/godmode:concurrent --race                 # Detect race conditions in shared cache
/godmode:concurrent --async                # Design async pipeline in Go
/godmode:concurrent --actor                # Design actor system for message processing
/godmode:concurrent --deadlock             # Analyze and prevent deadlocks
/godmode:concurrent --test                 # Create concurrent test suite
```
