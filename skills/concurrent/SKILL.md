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
+--------------------------------------------------------------+
| State | Access Pattern | Protection | Risk |
+--------------------------------------------------------------+
| <variable/resource> | Read-Write | <mutex/none> | HIGH |
| <variable/resource> | Read-Only | None needed | LOW |
| <variable/resource> | Write-Only | <channel> | MED |
+--------------------------------------------------------------+

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
+--------------------------------------------------------------+
| Pattern | Found | Location | Fix |
+--------------------------------------------------------------+
| Check-then-act | Y/N | <file:line> | |
| Read-modify-write | Y/N | <file:line> | |
| Compound actions | Y/N | <file:line> | |
| Lazy initialization | Y/N | <file:line> | |
| Iterator invalidation | Y/N | <file:line> | |
| Double-checked locking | Y/N | <file:line> | |
| Publication escape | Y/N | <file:line> | |
| Time-of-check-time-of-use | Y/N | <file:line> | |
+--------------------------------------------------------------+

DETECTION TOOLS:
- Go: go run -race./...
- Rust: cargo +nightly miri test (for unsafe code)
- Java: ThreadSanitizer, FindBugs/SpotBugs
- C/C++: ThreadSanitizer (TSan), Helgrind
- Python: threading module + careful review (GIL does not prevent logical races)
- Node.js: Async race conditions in event loop (not thread races)
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
 const results = await Promise.all(
 urls.map(url => limit(() => fetch(url)))
 );

4. Error handling -- Promise.allSettled (when partial failure is OK)
 const results = await Promise.allSettled(promises);
 const successes = results.filter(r => r.status === 'fulfilled');
 const failures = results.filter(r => r.status === 'rejected');

ANTI-PATTERNS:
- await in a loop (sequential when it could be concurrent)
- Unhandled promise rejections (always catch or use allSettled)
- Mixing callbacks and promises (pick one)
- Not propagating cancellation (use AbortController)
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
 async with asyncio.TaskGroup() as tg:
 task1 = tg.create_task(fetch_user(user_id))
 task2 = tg.create_task(fetch_orders(user_id))
 # Both tasks guaranteed complete or cancelled here

4. Async generators -- streaming results
 async for chunk in stream_response(url):
 process(chunk)

ANTI-PATTERNS:
- Using asyncio.sleep(0) as a yield point hack
- Blocking the event loop with sync I/O (use run_in_executor)
- Creating tasks without awaiting or storing references
- Ignoring CancelledError (always clean up on cancellation)
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
 results := make(chan Result, 100)
 for w := 0; w < numWorkers; w++ {
 go worker(jobs, results)
 }

3. Context cancellation
 ctx, cancel := context.WithTimeout(parentCtx, 5*time.Second)
 defer cancel()
 select {
 case result := <-doWork(ctx):
 return result, nil
 case <-ctx.Done():
 return nil, ctx.Err()
 }

4. errgroup (structured concurrency)
 g, ctx := errgroup.WithContext(parentCtx)
 g.Go(func() error { return fetchUser(ctx, id) })
 g.Go(func() error { return fetchOrders(ctx, id) })
 if err := g.Wait(); err != nil {
 return err
 }

ANTI-PATTERNS:
- Goroutine leak (always ensure goroutines can exit)
- Unbuffered channel deadlock (sender and receiver must be ready)
- Closing a channel from the receiver side
- Not using context for cancellation propagation
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
 for url in urls {
 let permit = sem.clone().acquire_owned().await?;
 tokio::spawn(async move {
 let _permit = permit;
 fetch(url).await
 });
 }

4. Channels -- tokio::sync::mpsc
 let (tx, mut rx) = mpsc::channel(100);
 tokio::spawn(async move {
 while let Some(msg) = rx.recv().await {
 process(msg).await;
 }
 });

OWNERSHIP RULES:
- Arc<Mutex<T>> for shared mutable state across tasks
- Arc<RwLock<T>> when reads dominate writes
- Channels (mpsc, broadcast, watch) for message passing
- Send + Sync bounds required for cross-task sharing
```

### Step 5: Lock-Free Data Structures
Design or select lock-free alternatives when locks are a bottleneck:

```
LOCK-FREE DATA STRUCTURES:
+--------------------------------------------------------------+
| Structure | Use Case | Implementation |
+--------------------------------------------------------------+
| Atomic counter | Counters, flags | AtomicI64, atomic|
| CAS loop | Compare-and-swap ops | compare_exchange |
| Lock-free queue | Producer-consumer | crossbeam, ConcurrentLinkedQueue |
| Lock-free stack | LIFO work stealing | Treiber stack |
| Lock-free hash map | Concurrent KV | dashmap (Rust), ConcurrentHashMap (Java) |
| Read-copy-update | Read-heavy workloads | RCU, arc-swap |
| Immutable data | Shared state | Persistent data structures |
+--------------------------------------------------------------+

WHEN TO USE LOCK-FREE:
- High contention on a specific data structure
- Locks measured as a bottleneck via profiling
- Real-time or low-latency requirements
- Reader-heavy workloads with rare writes

WHEN TO AVOID LOCK-FREE:
- Simple cases where a mutex works fine
- Complex invariants spanning multiple fields
- When correctness is hard to verify
- Premature optimization without profiling evidence

MEMORY ORDERING (Rust/C++):
+--------------------------------------------------------------+
| Ordering | Guarantees | Use Case |
+--------------------------------------------------------------+
| Relaxed | Atomicity only | Counters |
| Acquire/Release | Happens-before on pair | Lock-like sync |
| SeqCst | Total global order | Default safe |
+--------------------------------------------------------------+

Rule: Start with SeqCst. Only relax ordering after proving correctness and measuring the performance difference.
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
+--------------------------------------------------------------+
| Actor | Messages Received | State | Children|
+--------------------------------------------------------------+
| <ActorName> | <message types> | <fields> | <list> |
+--------------------------------------------------------------+

SUPERVISION STRATEGY:
+--------------------------------------------------------------+
| Error Type | Strategy |
+--------------------------------------------------------------+
| Transient error | Restart child actor |
| Permanent error | Stop child actor, escalate to parent |
| Timeout | Restart with backoff |
| Unknown | Stop all children, escalate |
+--------------------------------------------------------------+
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
- gen_statem: Finite state machine
- gen_event: Event handling with multiple handlers
- supervisor: Supervises child processes

LET IT CRASH:
- Do NOT write defensive code inside actors
- Let unexpected errors crash the actor
- Supervisor restarts with clean state
- Separate error handling from business logic
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
 actor ! ProcessOrder(orderId)

3. Pipe pattern (async result to actor)
 futureResult.pipeTo(sender())

4. Stash pattern (defer messages during state transitions)
 def receive = {
 case Initialize => stash(); context.become(initializing)
 }
 def initializing = {
 case Initialized => unstashAll(); context.become(ready)
 }

SUPERVISION:
 override val supervisorStrategy = OneForOneStrategy(
 maxNrOfRetries = 10,
 withinTimeRange = 1.minute
 ) {
 case _: ArithmeticException => Resume
 case _: NullPointerException => Restart
 case _: IllegalArgumentException => Stop
 case _: Exception => Escalate
 }
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
+--------------------------------------------------------------+
| Strategy | Breaks Condition | How |
+--------------------------------------------------------------+
| Lock ordering | Circular wait | Always acquire in |
| | | consistent global order|
| Lock timeout | Hold and wait | Give up after timeout |
| Try-lock | Hold and wait | Non-blocking attempt |
| Single lock | Hold and wait | One coarse lock |
| Lock-free design | Mutual exclusion | Atomics, channels |
| Resource hierarchy | Circular wait | Number resources, |
| | | acquire in order |
+--------------------------------------------------------------+

DEADLOCK DETECTION CHECKLIST:
+--------------------------------------------------------------+
| Check | Status |
+--------------------------------------------------------------+
| All locks acquired in consistent order | PASS | FAIL |
| No nested lock acquisition | PASS | FAIL | N/A |
| Timeouts on all lock acquisitions | PASS | FAIL |
| No lock held during I/O operations | PASS | FAIL |
| Channel operations have timeouts/select | PASS | FAIL | N/A |
| Database transactions are short-lived | PASS | FAIL | N/A |
| No callback invoked while holding lock | PASS | FAIL |
+--------------------------------------------------------------+

DETECTION TOOLS:
- Go: goroutine dump (SIGQUIT or runtime.Stack)
- Java: jstack, ThreadMXBean.findDeadlockedThreads()
- Rust: parking_lot deadlock detection (debug builds)
- Database: pg_stat_activity, SHOW ENGINE INNODB STATUS
- General: Runtime deadlock detectors, watchdog timers
```

### Step 8: Concurrent Testing Strategies
Verify correctness of concurrent code:

```
CONCURRENT TESTING APPROACH:
+--------------------------------------------------------------+
| Technique | What It Catches | Tools |
+--------------------------------------------------------------+
| Race detector | Data races | go -race, TSan |
| Stress testing | Intermittent bugs | Run N times |
| Loom (Rust) | All interleavings | loom crate |
| Property testing | Invariant violations | QuickCheck, Hypothesis |
| Linearizability | Correctness of | Jepsen, elle |
| testing | concurrent operations | |
| Chaos injection | Timing dependencies | tokio-test, manual|
| Deterministic sim | Full replay | Hermit, FoundationDB |
+--------------------------------------------------------------+

TESTING CHECKLIST:
1. [ ] Run race detector on all concurrent code paths
2. [ ] Stress test with 100x normal concurrency
3. [ ] Test with artificially slow I/O (delays, timeouts)
4. [ ] Verify invariants hold under concurrent access
5. [ ] Test cancellation paths (what happens mid-operation?)
6. [ ] Test error paths under concurrency (error + concurrent access)
7. [ ] Verify graceful shutdown (all goroutines/tasks complete)
8. [ ] Test with single-threaded runtime (catches parallelism assumptions)

STRESS TEST TEMPLATE:
 Run test 1000 times with max parallelism:
 - Go: go test -race -count=1000 -parallel=<GOMAXPROCS>./...
 - Rust: cargo test -- --test-threads=<N> (repeat with script)
 - Java: Run under Thread Sanitizer or jcstress
 - Node: Run concurrent promise batches, check for missing/duplicate results

INVARIANT TESTING:
 For every concurrent data structure, define invariants:
 - Size invariant: insertions - deletions = current size
 - Ordering invariant: elements always sorted (if applicable)
 - Uniqueness invariant: no duplicate entries (if applicable)
 - Completeness invariant: no lost updates
 Run property tests that concurrently mutate and verify invariants hold.
```

### Step 9: Concurrency Model Selection
Choose the right concurrency model for the workload:

```
CONCURRENCY MODEL DECISION:
+--------------------------------------------------------------+
| Workload | Recommended Model | Language/Runtime |
+--------------------------------------------------------------+
| High I/O, many | Event loop / async | Node.js, Python |
| connections | | asyncio |
| CPU-bound parallel | Thread pool / rayon | Rust, Go, Java |
| Message-driven | Actor model | Erlang, Akka |
| distributed | | |
| Mixed I/O + CPU | Async + spawn_blocking| Rust tokio, Go |
| Real-time, low-lat | Lock-free + busy wait | C/C++, Rust |
| Simple shared state| Mutex/RwLock | Any language |
| Pipeline processing| Channels / CSP | Go, Rust, Elixir |
+--------------------------------------------------------------+

SELECTED MODEL: <model> -- <justification>
```

### Step 10: Validation & Artifacts
Validate the concurrency design:

```
CONCURRENCY VALIDATION:
+--------------------------------------------------------------+
| Check | Status |
+--------------------------------------------------------------+
| All shared mutable state identified | PASS | FAIL |
| Protection strategy for each shared state| PASS | FAIL |
| Race condition analysis complete | PASS | FAIL |
| Deadlock prevention strategy in place | PASS | FAIL |
| Cancellation/shutdown paths verified | PASS | FAIL |
| Concurrent tests written | PASS | FAIL |
| Race detector passes cleanly | PASS | FAIL |
| Performance under concurrency measured | PASS | FAIL |
+--------------------------------------------------------------+

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
7. **Start with the simplest correct solution.** A mutex that works is better than a lock-free structure that might work. Optimize only with profiling evidence.
8. **Document the concurrency model.** Future developers need to understand why a particular approach was chosen and what invariants must be maintained.

## Example Usage

### Analyzing thread safety of a shared cache
```
User: /godmode:concurrent Analyze thread safety of our in-memory cache

Concurrent: Analyzing shared state...

SHARED STATE INVENTORY:
 cache map[string]CacheEntry -- Read-Write, protected by sync.RWMutex -- OK
 hitCount int64 -- Read-Write, NO PROTECTION -- UNSAFE
 lastEviction time.Time -- Write from evictor goroutine, read from handler -- UNSAFE

RACE CONDITIONS FOUND: 2
 1. hitCount increment in Get() -- read-modify-write without lock
 Fix: Use atomic.AddInt64(&c.hitCount, 1)
 2. lastEviction written by evictor, read by stats handler -- data race
 Fix: Use atomic.Value or protect with existing RWMutex

VERDICT: UNSAFE -- 2 race conditions, fixes provided
```


## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full concurrency analysis and design |
| `--analyze` | Thread safety analysis of existing code |
| `--race` | Race condition detection and fixes |
| `--async` | Async/await pattern design |
| `--lockfree` | Lock-free data structure design |
| `--actor` | Actor model system design |
| `--deadlock` | Deadlock detection and prevention |
| `--test` | Concurrent testing strategy |
| `--model` | Concurrency model selection guide |

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

3. Detect shared mutable state:
 - Global variables modified from multiple goroutines/threads
 - Package-level maps, slices, counters without synchronization
 - Singleton instances accessed concurrently

4. Detect existing race condition signals:
 - Check for: go test -race results in CI config
 - Check for: ThreadSanitizer flags in build config
 - Check test output for: DATA RACE, deadlock, timeout

5. Auto-classify workload:
 - I/O-bound: many HTTP calls, database queries, file operations
 - CPU-bound: computation, data processing, encoding
 - Mixed: both I/O and CPU in the same service

-> Auto-populate CONCURRENCY CONTEXT from detected signals.
-> Only ask user about specific shared state and I/O profile if not detectable.
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
```
IF race detector reports a data race:
 → Locate the shared mutable state from the race report
 → Classify: check-then-act, read-modify-write, or compound action?
 → Apply the narrowest fix: atomic > channel > mutex
 → Re-run race detector — must report zero races before proceeding

IF deadlock detected (goroutine/thread dump shows all blocked):
 → Identify the circular wait from the stack traces
 → Check lock acquisition order — are locks acquired in inconsistent order?
 → Fix: enforce global lock ordering, or use try-lock with timeout
 → Add a regression test that reproduces the deadlock scenario

IF stress test reveals intermittent failure:
 → Increase iteration count to 10,000 to make failure reproducible
 → Add artificial delays (sleep 1ms) at suspected race points to widen the window
 → Once reproduced reliably, apply fix, then remove artificial delays
 → Run stress test 10,000 times — must pass all iterations

IF goroutine/task leak detected (count grows over time):
 → Find the goroutine/task that never exits: runtime.NumGoroutine() or equivalent
 → Check: does it have a termination condition? Is context cancellation propagated?
 → Fix: add context.WithCancel, defer cancel(), and select on ctx.Done()
 → Verify: goroutine count stabilizes after fix

IF lock contention causes performance degradation (profiler shows lock wait time):
 → Measure: what percentage of time is spent waiting for locks?
 → Reduce critical section scope: move I/O and computation outside the lock
 → Consider: RWMutex if reads dominate, or lock-free structure if profiling justifies it
 → Do NOT switch to lock-free without profiling evidence
```
