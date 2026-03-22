---
name: concurrent
description: |
 Concurrency and parallelism skill. Activates when user needs thread safety analysis, race condition detection, async/await pattern guidance, lock-free data structures, actor model design, deadlock detection and prevention, or concurrent testing strategies. Triggers on: /godmode:concurrent, "thread safety", "race condition", "async await", "deadlock", "lock-free", "actor model", "concurrent", "parallelism", or when the orchestrator detects concurrency work.
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
Existing Primitives: <mutexes, channels, atomics, locks currently in use>
```

If the user has not provided context, ask: "What language/runtime are you using, and is the workload primarily CPU-bound or I/O-bound? This determines the right concurrency model."

### Step 2: Thread Safety Analysis
Identify shared mutable state and classify access patterns:

```
SHARED STATE INVENTORY:
| State | Access Pattern | Protection | Risk |
|---|---|---|---|
| <variable/resource> | Read-Write | <mutex/none> | HIGH |
| <variable/resource> | Read-Only | None needed | LOW |
| <variable/resource> | Write-Only | <channel> | MED |

CRITICAL SECTIONS:
1. <description of code region> -- <what shared state it touches>
2. <description of code region> -- <what shared state it touches>

THREAD SAFETY VERDICT: SAFE | UNSAFE | NEEDS REVIEW
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
|---|---|---|---|
| Check-then-act | Y/N | <file:line> | |
| Read-modify-write | Y/N | <file:line> | |
| Compound actions | Y/N | <file:line> | |
| Lazy initialization | Y/N | <file:line> | |
| Iterator invalidation | Y/N | <file:line> | |
| Double-checked locking | Y/N | <file:line> | |
| Publication escape | Y/N | <file:line> | |
| Time-of-check-time-of-use | Y/N | <file:line> | |

DETECTION TOOLS:
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

SAFE (lock):
 lock.acquire();
 try {
 if (map.has(key)) {
 return map.get(key);
 }
 } finally {
 lock.release();
 }
```

**Read-modify-write**
```
UNSAFE:
 counter = counter + 1; // Read, modify, write -- not atomic

SAFE (atomic):
 counter.incrementAndGet(); // Java AtomicInteger
 counter.fetch_add(1, Ordering::SeqCst); // Rust AtomicUsize
 atomic.AddInt64(&counter, 1); // Go sync/atomic

SAFE (lock):
 mu.Lock()
 counter++
 mu.Unlock()
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
 getProducts(),
 getConfig()
 ]);

3. Controlled concurrency -- p-limit, p-map (when too many concurrent ops)
 import pLimit from 'p-limit';
 const limit = pLimit(10); // Max 10 concurrent
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

2. Controlled concurrency -- asyncio.Semaphore
 sem = asyncio.Semaphore(10)
 async def limited_fetch(url):
 async with sem:
 return await fetch(url)

3. Task groups (Python 3.11+) -- structured concurrency
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
 for range jobs {
 result := <-results
 // handle result
 }

2. Worker pool
 jobs := make(chan Job, 100)
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
 let handle = tokio::spawn(async move {
 expensive_computation().await
 });
 let result = handle.await?;

3. Bounded concurrency -- tokio::sync::Semaphore
 let sem = Arc::new(Semaphore::new(10));
```

### Step 5: Lock-Free Data Structures
Design or select lock-free alternatives when locks are a bottleneck:

```
LOCK-FREE DATA STRUCTURES:
| Structure | Use Case | Implementation |
|---|---|---|
| Atomic counter | Counters, flags | AtomicI64, atomic|
| CAS loop | Compare-and-swap ops | compare_exchange |
| Lock-free queue | Producer-consumer | crossbeam, ConcurrentLinkedQueue |
| Lock-free stack | LIFO work stealing | Treiber stack |
| Lock-free hash map | Concurrent KV | dashmap (Rust), ConcurrentHashMap (Java) |
| Read-copy-update | Read-heavy workloads | RCU, arc-swap |
| Immutable data | Shared state | Persistent data structures |

WHEN TO USE LOCK-FREE:
- High contention on a specific data structure
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
|---|---|---|---|
| <ActorName> | <message types> | <fields> | <list> |

SUPERVISION STRATEGY:
```

#### Erlang/OTP Patterns
```
SUPERVISION TREES:
 [Application Supervisor]
 / | \
 [Worker Pool] [Event Manager] [State Server]
 / | \
 [W1] [W2] [W3]

RESTART STRATEGIES:
- one_for_one: Restart only the failed child
- one_for_all: Restart all children when one fails
- rest_for_one: Restart failed child and all started after it
- simple_one_for_one: Dynamic worker pool (all children same type)

OTP BEHAVIORS:
- gen_server: Request-response server (most common)
```

#### Akka/Pekko Patterns
```
ACTOR HIERARCHY:
 /user (guardian)
 /order-manager
 /order-1
 /order-2
 /payment-processor
 /payment-worker-1
 /payment-worker-2

PATTERNS:
1. Ask pattern (request-response with timeout)
 implicit val timeout: Timeout = 3.seconds
 val future: Future[Response] = actor ? Request(data)

2. Tell pattern (fire-and-forget)
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
|---|---|---|
| Lock ordering | Circular wait | Always acquire in |
| | | consistent global order|
| Lock timeout | Hold and wait | Give up after timeout |
| Try-lock | Hold and wait | Non-blocking attempt |
| Single lock | Hold and wait | One coarse lock |
```

### Step 8: Concurrent Testing Strategies
Verify correctness of concurrent code:

```
CONCURRENT TESTING APPROACH:
| Technique | What It Catches | Tools |
|---|---|---|
| Race detector | Data races | go -race, TSan |
| Stress testing | Intermittent bugs | Run N times |
| Loom (Rust) | All interleavings | loom crate |
| Property testing | Invariant violations | QuickCheck, Hypothesis |
| Linearizability | Correctness of | Jepsen, elle |
| testing | concurrent operations | |
| Chaos injection | Timing dependencies | tokio-test, manual|
| Deterministic sim | Full replay | Hermit, FoundationDB |

TESTING CHECKLIST:
```

### Step 9: Concurrency Model Selection
Choose the right concurrency model for the workload:

```
CONCURRENCY MODEL DECISION:
| Workload | Recommended Model | Language/Runtime |
|---|---|---|
| High I/O, many | Event loop / async | Node.js, Python |
| connections | | asyncio |
| CPU-bound parallel | Thread pool / rayon | Rust, Go, Java |
| Message-driven | Actor model | Erlang, Akka |
| distributed | | |
| Mixed I/O + CPU | Async + spawn_blocking| Rust tokio, Go |
| Real-time, low-lat | Lock-free + busy wait | C/C++, Rust |
| Simple shared state| Mutex/RwLock | Any language |
| Pipeline processing| Channels / CSP | Go, Rust, Elixir |

SELECTED MODEL: <model> -- <justification>
```

### Step 10: Validation & Artifacts
Validate the concurrency design:

```
CONCURRENCY VALIDATION:
| Check | Status |
|---|---|
| All shared mutable state identified | PASS | FAIL |
| Protection strategy for each shared state| PASS | FAIL |
| Race condition analysis complete | PASS | FAIL |
| Deadlock prevention strategy in place | PASS | FAIL |
| Cancellation/shutdown paths verified | PASS | FAIL |
| Concurrent tests written | PASS | FAIL |
| Race detector passes cleanly | PASS | FAIL |
| Performance under concurrency measured | PASS | FAIL |

VERDICT: <SAFE | NEEDS WORK>
```

Generate deliverables:

```
CONCURRENCY DESIGN COMPLETE:

Artifacts:
- Thread safety analysis: docs/concurrency/<feature>-thread-safety.md
- Race condition report: docs/concurrency/<feature>-race-analysis.md
- Concurrency tests: tests/concurrent/<feature>-concurrent.test.<ext>
- Validation: <SAFE | NEEDS WORK>

Next steps:
-> /godmode:test -- Run concurrent test suite
-> /godmode:perf -- Profile under concurrent load
-> /godmode:review -- Review concurrent code for correctness
-> /godmode:loadtest -- Verify behavior at scale
```

Commit: `"concurrent: <feature> -- <model>, <N> shared states protected, <verdict>"`

## Key Behaviors

1. **Identify shared mutable state first.** Every concurrency bug starts with shared mutable state. Enumerate it before writing any concurrent code.
2. **Prefer message passing over shared state.** Channels, actors, and events are safer than mutexes. Use shared mutable state only when message passing adds unacceptable overhead.
3. **Always use the race detector.** If your language has a race detector, run it on every test. No exceptions. A clean race detector run is a minimum, not a guarantee.
4. **Lock ordering prevents deadlocks.** If you must use multiple locks, define and enforce a global acquisition order. Document it.
5. **Test concurrency with stress and chaos.** Running a test once proves nothing about concurrent correctness. Run it 1000 times. Inject delays. Simulate failures.
6. **Cancellation is not optional.** Every concurrent operation must support cancellation. Leaked goroutines, orphaned tasks, and zombie threads are resource leaks.
7. **Start with the simplest correct solution.** A mutex that works is better than a lock-free structure that could fail subtly. Optimize only with profiling evidence.
8. **Document the concurrency model.** Future developers need to understand why a particular approach was chosen and what invariants to maintain.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full concurrency analysis and design |
| `--analyze` | Thread safety analysis of existing code |
| `--race` | Race condition detection and fixes |

## Auto-Detection

Before prompting the user, automatically detect concurrency context:

```
AUTO-DETECT SEQUENCE:
1. Detect language and concurrency model:
 - Go: goroutines + channels (CSP). Check: go.mod, *.go files
 - Rust: tokio/async-std. Check: Cargo.toml for tokio, async-std deps
 - Node.js: event loop + async/await. Check: package.json
 - Python: asyncio, threading, multiprocessing. Check: imports in *.py
 - Java/Kotlin: threads, virtual threads, coroutines. Check: pom.xml, build.gradle
 - Erlang/Elixir: actor model (OTP). Check: mix.exs, rebar.config

2. Detect existing concurrency primitives:
 - grep for: sync.Mutex, sync.RWMutex, sync.WaitGroup (Go)
 - grep for: Arc<Mutex>, Arc<RwLock>, tokio::spawn (Rust)
 - grep for: Promise.all, Promise.allSettled, Worker (Node.js)
 - grep for: asyncio.gather, threading.Lock, multiprocessing (Python)
 - grep for: synchronized, ReentrantLock, ExecutorService (Java)
```

## Keep/Discard Discipline
Each concurrency fix either passes the race detector or gets reverted.
- **KEEP**: Race detector clean, stress test (1000 iterations) passes, no new deadlock risk introduced.
- **DISCARD**: Fix introduces a new race, deadlock, or performance regression. Revert immediately.
- **CRASH**: Stress test reveals intermittent failure. Increase iterations to 10,000 to reproduce reliably, then fix.
- Log every analysis to `.godmode/concurrent-results.tsv`.

## Stop Conditions
- Every piece of shared mutable state identified and protected.
- Race detector (go -race, TSan, etc.) reports zero races.
- Deadlock detection checklist shows all items PASS.
- At least one stress test written: 1000 iterations with maximum parallelism, all passing.
- Every mutex has a comment documenting what shared state it protects.

## HARD RULES

1. **NEVER STOP** until all shared mutable state is identified and protected.
2. **NEVER add locks without documenting what they protect** — every mutex gets a comment.
3. **NEVER hold locks during I/O** — fetch data first, then acquire lock to update.
4. **ALWAYS run the race detector** on every test (go -race, TSan, etc.).
5. **ALWAYS verify cancellation paths** — every concurrent operation must support cancellation.
6. **git commit BEFORE verify** — commit concurrency fixes, then run stress tests.
7. **Automatic revert on regression** — if a fix introduces deadlocks or new races, revert immediately.
8. **TSV logging** — log every concurrency analysis:
 ```
 timestamp	component	shared_states	races_found	races_fixed	deadlock_risk	verdict
 ```

## Output Format
Print on completion:
```
CONCURRENCY ANALYSIS: {feature_or_component}
Language/Runtime: {language} | Model: {concurrency_model}
Shared mutable states: {N} identified, {N} protected
Race conditions: {N} found, {N} fixed
Deadlock risk: {HIGH|MEDIUM|LOW|NONE}
Concurrent tests: {N} written
Verdict: {SAFE|NEEDS WORK}
Artifacts: {list of files created}
```

## TSV Logging
Log every concurrency session to `.godmode/concurrent-results.tsv`:
```
timestamp	component	language	model	shared_states	races_found	races_fixed	deadlock_risk	tests_written	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. Every piece of shared mutable state identified and listed in the inventory.
2. Every shared mutable state has a documented protection mechanism (mutex, atomic, channel, immutable).
3. Race condition analysis completed using the 8-pattern checklist.
4. Race detector run (go -race, TSan, etc.) on all concurrent code paths.
5. Deadlock detection checklist completed with all items PASS.
6. Cancellation paths verified — every concurrent operation supports cancellation.
7. At least one stress test written: run 1000 iterations with maximum parallelism.
8. Every mutex has a comment documenting what shared state it protects.


## Error Recovery
| Failure | Action |
|---------|--------|
| Deadlock detected | Use consistent lock ordering. Add lock timeout. Use `NOWAIT` or `SKIP LOCKED` in SQL. Log lock acquisition order for debugging. |
| Race condition in tests (flaky) | Run stress test 1000x to reproduce reliably. Add explicit synchronization or use deterministic scheduling in test harness. |
| Thread pool exhaustion | Check for blocking calls in async code. Add backpressure. Monitor active thread count. Switch to a work-stealing scheduler. |
| Data corruption under load | Add mutex/lock around shared state. Use atomic operations for counters. Verify all shared state is documented with protecting lock. |
