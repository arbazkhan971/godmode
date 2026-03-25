---
name: concurrent
description: |
 Concurrency and parallelism skill. Activates when user needs thread safety analysis, race condition
 detection, async/await pattern guidance, lock-free data structures, actor model design, deadlock detection
 and prevention, or concurrent testing strategies. Triggers on: /godmode:concurrent, "thread safety", "race
 condition", "async await", "deadlock", "lock-free", "actor model", "concurrent", "parallelism", or when the
 orchestrator detects concurrency work.
---

# Concurrent -- Concurrency & Parallelism

## When to Activate
- User invokes `/godmode:concurrent`
- User says "thread safety", "race condition", "deadlock", "lock-free"
- User says "async/await", "actor model", "parallelism", "concurrent"
- User says "mutex", "semaphore", "channel", "goroutine", "tokio"
- When building multi-threaded or async systems
- When `/godmode:review` flags potential race conditions or deadlocks
- When `/godmode:test` reveals non-deterministic test failures

## Workflow

### Step 1: Concurrency Context Assessment
Understand the concurrency requirements before designing solutions:

```
CONCURRENCY CONTEXT:
Project: <name and purpose>
Language/Runtime: <Go | Rust | Node.js | Python | Java | Erlang/Elixir>
Concurrency Model: Threads | Green Threads | Event Loop | Actor Model | CSP
Current Issues: <race conditions, deadlocks, performance bottlenecks, none>
Shared State: <what mutable state is shared across concurrent units>
I/O Profile: CPU-bound | I/O-bound | Mixed
Scale: <concurrent connections/operations expected>
  ...
```
If the user has not provided context, ask: "What language/runtime are you using, and is the workload primarily
CPU-bound or I/O-bound? This determines the right concurrency model."

### Step 2: Thread Safety Analysis
Identify shared mutable state and classify access patterns:

```
SHARED STATE INVENTORY:
| State | Access Pattern | Protection | Risk |
|--|--|--|--|
| <variable/resource> | Read-Write | <mutex/none> | HIGH |
| <variable/resource> | Read-Only | None needed | LOW |
| <variable/resource> | Write-Only | <channel> | MED |

CRITICAL SECTIONS:
  ...
```
Rules:
- Identify every piece of shared mutable state before writing any concurrent code
- Prefer immutable data and message passing over shared mutable state
- If shared mutable state is unavoidable, protect it with the narrowest possible lock scope
- Document every critical section and its invariants

### Step 3: Race Condition Detection
Systematically check for race conditions:

```
RACE CONDITION ANALYSIS:
| Pattern | Found | Location | Fix |
|--|--|--|--|
| Check-then-act | Y/N | <file:line> | |
| Read-modify-write | Y/N | <file:line> | |
| Compound actions | Y/N | <file:line> | |
| Lazy initialization | Y/N | <file:line> | |
| Iterator invalidation | Y/N | <file:line> | |
  ...
```
#### Common Race Condition Patterns and Fixes

**Check-then-act (TOCTOU)**
```
UNSAFE:
 if (map.has(key)) { // Check
 return map.get(key); // Act -- another thread may have removed key
 }

SAFE (atomic operation):
 return map.getOrDefault(key, fallback); // Single atomic operation

  ...
```

**Read-modify-write**
```
UNSAFE:
 counter = counter + 1; // Read, modify, write -- not atomic

SAFE (atomic):
 counter.incrementAndGet(); // Java AtomicInteger
 counter.fetch_add(1, Ordering::SeqCst); // Rust AtomicUsize
 atomic.AddInt64(&counter, 1); // Go sync/atomic

  ...
```

### Step 4: Async/Await Patterns
Design correct async code for the target runtime:

#### Node.js (Event Loop)
```
PATTERNS:
1. Sequential async -- await one at a time (when order matters)
 const user = await getUser(id);
 const orders = await getOrders(user.id);

2. Concurrent async -- Promise.all (when independent)
 const [user, products, config] = await Promise.all([
 getUser(id),
  ...
```

#### Python (asyncio)
```
PATTERNS:
1. Concurrent tasks -- asyncio.gather
 results = await asyncio.gather(
 fetch_user(user_id),
 fetch_orders(user_id),
 fetch_preferences(user_id)
 )

  ...
```

#### Go (Goroutines + Channels)
```
PATTERNS:
1. Fan-out/fan-in
 results := make(chan Result, len(jobs))
 for _, job := range jobs {
 go func(j Job) {
 results <- process(j)
 }(job)
 }
  ...
```

#### Rust (Tokio / async-std)
```
PATTERNS:
1. Concurrent futures -- tokio::join!
 let (user, orders) = tokio::join!(
 get_user(id),
 get_orders(id)
 );

2. Spawned tasks with handles
  ...
```

### Step 5: Lock-Free Data Structures
Design or select lock-free alternatives when locks are a bottleneck:

```
LOCK-FREE DATA STRUCTURES:
| Structure | Use Case | Implementation |
|--|--|--|
| Atomic counter | Counters, flags | AtomicI64, atomic|
| CAS loop | Compare-and-swap ops | compare_exchange |
| Lock-free queue | Producer-consumer | crossbeam, ConcurrentLinkedQueue |
| Lock-free stack | LIFO work stealing | Treiber stack |
| Lock-free hash map | Concurrent KV | dashmap (Rust), ConcurrentHashMap (Java) |
  ...
```
### Step 6: Actor Model Design
Design actor-based systems for message-driven concurrency:

```
ACTOR MODEL PRINCIPLES:
1. Each actor has private state -- no shared mutable state
2. Actors communicate only through asynchronous messages
3. Each actor processes one message at a time -- sequential within actor
4. Actors can create child actors, send messages, change behavior

ACTOR SYSTEM DESIGN:
| Actor | Messages Received | State | Children|
  ...
```
### Step 7: Deadlock Detection and Prevention
Systematically prevent and detect deadlocks:

```
DEADLOCK CONDITIONS (all four must hold):
1. Mutual exclusion -- resource held exclusively
2. Hold and wait -- holding one resource, waiting for another
3. No preemption -- resources cannot be forcibly taken
4. Circular wait -- A waits for B, B waits for A

PREVENTION STRATEGIES:
| Strategy | Breaks Condition | How |
  ...
```
### Step 8: Concurrent Testing Strategies
Verify correctness of concurrent code:

```
CONCURRENT TESTING APPROACH:
| Technique | What It Catches | Tools |
|--|--|--|
| Race detector | Data races | go -race, TSan |
| Stress testing | Intermittent bugs | Run N times |
| Loom (Rust) | All interleavings | loom crate |
| Property testing | Invariant violations | QuickCheck, Hypothesis |
| Linearizability | Correctness of | Jepsen, elle |
  ...
```
### Step 9: Concurrency Model Selection
Choose the right concurrency model for the workload:

```
CONCURRENCY MODEL DECISION:
| Workload | Recommended Model | Language/Runtime |
|--|--|--|
| High I/O, many | Event loop / async | Node.js, Python |
| connections | | asyncio |
| CPU-bound parallel | Thread pool / rayon | Rust, Go, Java |
| Message-driven | Actor model | Erlang, Akka |
| distributed | | |
  ...
```
### Step 10: Validation & Artifacts
Validate the concurrency design:

```
CONCURRENCY VALIDATION:
| Check | Status |
|--|--|
| All shared mutable state identified | PASS | FAIL |
| Protection strategy for each shared state| PASS | FAIL |
| Race condition analysis complete | PASS | FAIL |
| Deadlock prevention strategy in place | PASS | FAIL |
| Cancellation/shutdown paths verified | PASS | FAIL |
  ...
```
Generate deliverables:

```
CONCURRENCY DESIGN COMPLETE:

Artifacts:
- Thread safety analysis: docs/concurrency/<feature>-thread-safety.md
- Race condition report: docs/concurrency/<feature>-race-analysis.md
- Concurrency tests: tests/concurrent/<feature>-concurrent.test.<ext>
- Validation: <SAFE | NEEDS WORK>

  ...
```
Commit: `"concurrent: <feature> -- <model>, <N> shared states protected, <verdict>"`

## Quality Targets
- Lock contention: <10ms per critical section
- CPU utilization: >80% under load
- Data race count: <1 detected by race detector

## Key Behaviors

Never ask to continue. Loop autonomously until done.

```bash
# Run concurrency checks
go test -race ./...
cargo test -- --test-threads=1
python -m pytest tests/ -x --timeout=30
```
IF race detector reports > 0 races: fix before merging.
WHEN stress test (1000 iterations) shows any failure: investigate.
IF mutex hold time > 100ms: refactor to reduce critical section.

1. **Identify shared mutable state first.** Enumerate before coding.
2. **Prefer message passing.** Channels > mutexes.
3. **Always use race detector.** Run on every test. No exceptions.
4. **Lock ordering prevents deadlocks.** Document global order.
## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full concurrency analysis and design |
| `--analyze` | Thread safety analysis of existing code |
| `--race` | Race condition detection and fixes |

## Auto-Detection
```
Detect language and concurrency model:
Go: goroutines+channels. Rust: tokio/async-std. Node: event loop.
Python: asyncio/threading. Java: threads/virtual threads.
## Keep/Discard Discipline
Each concurrency fix either passes the race detector or gets reverted.
- **KEEP**: Race detector clean, stress test (1000 iterations) passes, no new deadlock risk introduced.
- **DISCARD**: Fix introduces a new race, deadlock, or performance regression. Revert immediately.
- **CRASH**: Stress test reveals intermittent failure. Increase iterations to 10,000 to reproduce reliably, then fix.
- Log every analysis to `.godmode/concurrent-results.tsv`.

## Stop Conditions
```

