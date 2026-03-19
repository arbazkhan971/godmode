# Concurrency Patterns Reference

> Language-specific concurrency patterns for Go, Rust, JavaScript/TypeScript, and Python. Covers common pitfalls and testing strategies for concurrent code.

---

## Go Concurrency Patterns

### Goroutines and Channels

Go's concurrency model is built on CSP (Communicating Sequential Processes): share memory by communicating, not communicate by sharing memory.

#### Fan-Out / Fan-In

Distribute work across multiple goroutines and collect results.

```go
// Fan-out: distribute work to N workers
func fanOut(input <-chan Job, numWorkers int) []<-chan Result {
    channels := make([]<-chan Result, numWorkers)
    for i := 0; i < numWorkers; i++ {
        channels[i] = worker(input)
    }
    return channels
}

// Worker: processes jobs from input channel
func worker(input <-chan Job) <-chan Result {
    out := make(chan Result)
    go func() {
        defer close(out)
        for job := range input {
            out <- process(job)
        }
    }()
    return out
}

// Fan-in: merge multiple result channels into one
func fanIn(channels ...<-chan Result) <-chan Result {
    var wg sync.WaitGroup
    merged := make(chan Result)

    for _, ch := range channels {
        wg.Add(1)
        go func(c <-chan Result) {
            defer wg.Done()
            for result := range c {
                merged <- result
            }
        }(ch)
    }

    go func() {
        wg.Wait()
        close(merged)
    }()
    return merged
}
```

#### Pipeline

Chain processing stages via channels.

```go
func generate(nums ...int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for _, n := range nums {
            out <- n
        }
    }()
    return out
}

func square(in <-chan int) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            out <- n * n
        }
    }()
    return out
}

func filter(in <-chan int, predicate func(int) bool) <-chan int {
    out := make(chan int)
    go func() {
        defer close(out)
        for n := range in {
            if predicate(n) {
                out <- n
            }
        }
    }()
    return out
}

// Usage: generate → square → filter → consume
results := filter(square(generate(1, 2, 3, 4, 5)), func(n int) bool {
    return n > 10
})
```

#### Context for Cancellation

```go
func fetchWithTimeout(ctx context.Context, url string) ([]byte, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, err
    }
    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, err  // Returns context.DeadlineExceeded on timeout
    }
    defer resp.Body.Close()
    return io.ReadAll(resp.Body)
}

// Parent context for graceful shutdown
func main() {
    ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
    defer stop()

    // All goroutines respect ctx.Done()
    go runServer(ctx)
    go runWorker(ctx)

    <-ctx.Done()
    // Graceful shutdown
}
```

#### errgroup for Parallel Tasks with Error Handling

```go
import "golang.org/x/sync/errgroup"

func fetchAll(ctx context.Context, urls []string) ([]Response, error) {
    g, ctx := errgroup.WithContext(ctx)
    results := make([]Response, len(urls))

    for i, url := range urls {
        i, url := i, url  // Capture loop variables
        g.Go(func() error {
            resp, err := fetch(ctx, url)
            if err != nil {
                return err  // Cancels all other goroutines via ctx
            }
            results[i] = resp
            return nil
        })
    }

    if err := g.Wait(); err != nil {
        return nil, err
    }
    return results, nil
}
```

#### Select for Multiplexing

```go
func processWithTimeout(work <-chan Job, done <-chan struct{}) {
    for {
        select {
        case job := <-work:
            process(job)
        case <-time.After(30 * time.Second):
            log.Println("No work received in 30s, idling")
        case <-done:
            log.Println("Shutting down")
            return
        }
    }
}
```

### Go Concurrency Pitfalls

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PITFALL                        │  SYMPTOM              │  FIX              │
├─────────────────────────────────┼───────────────────────┼───────────────────┤
│  Goroutine leak                 │  Memory grows forever │  Always have a    │
│  (goroutine blocked on channel  │                       │  cancellation     │
│   that nobody reads/writes)     │                       │  path (ctx.Done)  │
│                                 │                       │                   │
│  Race condition                 │  Inconsistent data,   │  Use channels or  │
│  (shared variable without sync) │  crashes under load   │  sync.Mutex.      │
│                                 │                       │  Run: go test     │
│                                 │                       │  -race            │
│                                 │                       │                   │
│  Deadlock                       │  Program hangs        │  Avoid nested     │
│  (two goroutines waiting for    │  "fatal error: all    │  locks. Use       │
│   each other)                   │   goroutines asleep"  │  consistent lock  │
│                                 │                       │  ordering.        │
│                                 │                       │                   │
│  Closing a closed channel       │  Panic                │  Only close from  │
│                                 │                       │  sender side.     │
│                                 │                       │  Use sync.Once.   │
│                                 │                       │                   │
│  Loop variable capture          │  All goroutines see   │  Capture: i := i  │
│  in goroutine                   │  same (last) value    │  or pass as param │
│                                 │                       │                   │
│  Unbuffered channel as          │  Deadlock when        │  Use buffered     │
│  unread signal                  │  nobody is receiving  │  channel or       │
│                                 │                       │  select+default   │
└─────────────────────────────────┴───────────────────────┴───────────────────┘
```

---

## Rust Concurrency Patterns

Rust's ownership system prevents data races at compile time. If it compiles, there are no data races.

### Ownership-Based Thread Safety

```rust
use std::thread;

// Move ownership into thread — no shared mutable state
fn spawn_with_ownership() {
    let data = vec![1, 2, 3, 4, 5];

    let handle = thread::spawn(move || {
        // data is MOVED into this thread — original thread cannot access it
        let sum: i32 = data.iter().sum();
        sum
    });

    // data is no longer accessible here (compile error if used)
    let result = handle.join().unwrap();
    println!("Sum: {}", result);
}
```

### Arc + Mutex for Shared State

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn shared_counter() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];

    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
            // Lock is automatically released when `num` goes out of scope
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }

    println!("Final count: {}", *counter.lock().unwrap());
}
```

### Channels (mpsc)

```rust
use std::sync::mpsc;
use std::thread;

fn producer_consumer() {
    let (tx, rx) = mpsc::channel();

    // Multiple producers
    for i in 0..5 {
        let tx = tx.clone();
        thread::spawn(move || {
            tx.send(format!("Message from thread {}", i)).unwrap();
        });
    }
    drop(tx);  // Drop original sender so rx.iter() terminates

    // Single consumer
    for message in rx {
        println!("Received: {}", message);
    }
}
```

### Rayon for Data Parallelism

```rust
use rayon::prelude::*;

fn parallel_processing() {
    let data: Vec<i32> = (0..1_000_000).collect();

    // Automatically parallelized across CPU cores
    let sum: i32 = data.par_iter().map(|x| x * x).sum();

    // Parallel sort
    let mut items = vec![5, 3, 1, 4, 2];
    items.par_sort();
}
```

### Tokio Async Runtime

```rust
use tokio;

#[tokio::main]
async fn main() {
    // Spawn concurrent tasks
    let task1 = tokio::spawn(async {
        fetch_data("https://api.example.com/a").await
    });

    let task2 = tokio::spawn(async {
        fetch_data("https://api.example.com/b").await
    });

    // Await both concurrently
    let (result1, result2) = tokio::join!(task1, task2);

    // Select first to complete
    tokio::select! {
        val = fetch_data("fast-api") => println!("Fast: {:?}", val),
        _ = tokio::time::sleep(Duration::from_secs(5)) => println!("Timeout"),
    }
}
```

### Rust Concurrency Pitfalls

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PITFALL                        │  SYMPTOM              │  FIX              │
├─────────────────────────────────┼───────────────────────┼───────────────────┤
│  Deadlock (Mutex)               │  Program hangs        │  Consistent lock  │
│  (compile-time safety does NOT  │                       │  ordering. Use    │
│   prevent deadlocks)            │                       │  try_lock() with  │
│                                 │                       │  timeout.         │
│                                 │                       │                   │
│  Mutex poisoning                │  PoisonError on       │  Handle with      │
│  (thread panicked while holding │  lock()               │  .lock()          │
│   lock)                         │                       │  .unwrap_or_else  │
│                                 │                       │  (|e| e.into_inner│
│                                 │                       │  ())              │
│                                 │                       │                   │
│  Blocking in async context      │  Executor thread      │  Use              │
│  (calling blocking I/O in async │  starved, other tasks │  spawn_blocking() │
│   task)                         │  delayed              │  for blocking ops │
│                                 │                       │                   │
│  Send / Sync bounds             │  Compile error: type  │  Wrap with Arc,   │
│  (type not safe to send across  │  cannot be sent       │  Mutex, or use    │
│   threads)                      │  between threads      │  Send-safe types  │
│                                 │                       │                   │
│  Async cancellation safety      │  Resource leak when   │  Implement Drop,  │
│  (task dropped mid-await)       │  task is cancelled    │  use cancel-safe  │
│                                 │                       │  patterns         │
└─────────────────────────────────┴───────────────────────┴───────────────────┘
```

---

## JavaScript / TypeScript Concurrency Patterns

JavaScript is single-threaded with an event loop. Concurrency is cooperative (not preemptive).

### Event Loop Model

```
┌───────────────────────────────────────────────────────────────┐
│                    JavaScript Event Loop                        │
│                                                                │
│  ┌──────────────┐                                              │
│  │  Call Stack   │ ← Synchronous code executes here            │
│  │  (single      │                                              │
│  │   thread)     │                                              │
│  └──────┬───────┘                                              │
│         │                                                      │
│         ▼                                                      │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐       │
│  │ Microtask    │ → │ Macrotask    │ → │ Render       │       │
│  │ Queue        │   │ Queue        │   │ (browsers)   │       │
│  │              │   │              │   │              │       │
│  │ - Promises   │   │ - setTimeout │   │ - Layout     │       │
│  │ - queueMicro │   │ - setInterval│   │ - Paint      │       │
│  │ - MutationObs│   │ - I/O        │   │ - Composite  │       │
│  └──────────────┘   │ - MessagePort│   └──────────────┘       │
│                     └──────────────┘                           │
│                                                                │
│  EXECUTION ORDER per tick:                                     │
│  1. Run all synchronous code on call stack                     │
│  2. Drain ALL microtasks (including newly added ones)          │
│  3. Run ONE macrotask                                          │
│  4. Render (if browser)                                        │
│  5. Repeat                                                     │
└───────────────────────────────────────────────────────────────┘
```

### Promise.all for Parallel Execution

```typescript
// PARALLEL: All requests start simultaneously
async function fetchAll(urls: string[]): Promise<Response[]> {
  const promises = urls.map(url => fetch(url));
  return Promise.all(promises);
  // Fails fast: if any promise rejects, entire result rejects
}

// PARALLEL with error tolerance: Promise.allSettled
async function fetchAllSafe(urls: string[]): Promise<PromiseSettledResult<Response>[]> {
  const promises = urls.map(url => fetch(url));
  return Promise.allSettled(promises);
  // Returns results for ALL, including failures:
  // [{ status: "fulfilled", value: ... }, { status: "rejected", reason: ... }]
}

// RACE: First to complete wins
async function fetchFastest(urls: string[]): Promise<Response> {
  return Promise.race(urls.map(url => fetch(url)));
}

// ANY: First to SUCCEED wins (ignores rejections until all fail)
async function fetchAny(urls: string[]): Promise<Response> {
  return Promise.any(urls.map(url => fetch(url)));
}
```

### Concurrency Limiter

```typescript
async function withConcurrencyLimit<T>(
  tasks: (() => Promise<T>)[],
  limit: number
): Promise<T[]> {
  const results: T[] = [];
  const executing = new Set<Promise<void>>();

  for (const [index, task] of tasks.entries()) {
    const promise = task().then(result => {
      results[index] = result;
    });

    const wrapped = promise.then(() => {
      executing.delete(wrapped);
    });
    executing.add(wrapped);

    if (executing.size >= limit) {
      await Promise.race(executing);
    }
  }

  await Promise.all(executing);
  return results;
}

// Usage: process 100 URLs, max 5 concurrent
const results = await withConcurrencyLimit(
  urls.map(url => () => fetch(url).then(r => r.json())),
  5
);
```

### Web Workers (True Parallelism in Browser)

```typescript
// main.ts
const worker = new Worker('worker.js');

worker.postMessage({ data: largeDataset, operation: 'sort' });

worker.onmessage = (event) => {
  console.log('Sorted result:', event.data);
};

worker.onerror = (error) => {
  console.error('Worker error:', error);
};

// worker.js
self.onmessage = (event) => {
  const { data, operation } = event.data;
  if (operation === 'sort') {
    const sorted = data.sort((a, b) => a - b);
    self.postMessage(sorted);
  }
};
```

### Node.js Worker Threads

```typescript
import { Worker, isMainThread, parentPort, workerData } from 'worker_threads';

if (isMainThread) {
  // Main thread: spawn worker
  const worker = new Worker(__filename, {
    workerData: { input: [1, 2, 3, 4, 5] }
  });

  worker.on('message', (result) => {
    console.log('Result from worker:', result);
  });

  worker.on('error', (err) => {
    console.error('Worker error:', err);
  });
} else {
  // Worker thread: CPU-intensive work
  const { input } = workerData;
  const result = input.map(n => fibonacci(n));
  parentPort!.postMessage(result);
}
```

### JavaScript Concurrency Pitfalls

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PITFALL                        │  SYMPTOM              │  FIX              │
├─────────────────────────────────┼───────────────────────┼───────────────────┤
│  Unhandled promise rejection    │  Silent failures,     │  Always .catch()  │
│                                 │  process exit (Node)  │  or try/catch in  │
│                                 │                       │  async functions   │
│                                 │                       │                   │
│  Sequential await in loop       │  10 requests take     │  Use Promise.all  │
│  for (const url of urls) {      │  10x time instead     │  for parallel     │
│    await fetch(url);            │  of 1x                │  execution         │
│  }                              │                       │                   │
│                                 │                       │                   │
│  Blocking the event loop        │  UI freezes (browser) │  Offload to Web   │
│  (CPU-heavy sync code)          │  Requests stall (Node)│  Worker or Worker │
│                                 │                       │  Thread            │
│                                 │                       │                   │
│  Race condition in shared       │  Inconsistent state   │  Use atomic       │
│  state (multiple async ops      │  after concurrent     │  operations, or   │
│  modify same object)            │  modifications        │  serialize access  │
│                                 │                       │                   │
│  Memory leak in event           │  Memory grows         │  Always           │
│  listeners                      │  unbounded            │  removeEventListen│
│                                 │                       │  er, use AbortCtrl│
│                                 │                       │                   │
│  Microtask starvation           │  Macrotasks never     │  Avoid infinite   │
│  (recursive promise chains)     │  execute              │  microtask loops  │
│                                 │                       │  Yield with       │
│                                 │                       │  setTimeout(0)    │
└─────────────────────────────────┴───────────────────────┴───────────────────┘
```

---

## Python Concurrency Patterns

Python has multiple concurrency models: threading (I/O-bound), multiprocessing (CPU-bound), and asyncio (cooperative I/O-bound).

### The GIL (Global Interpreter Lock)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PYTHON GIL:                                                                │
│                                                                             │
│  The CPython GIL allows only ONE thread to execute Python bytecode          │
│  at a time. This means:                                                     │
│                                                                             │
│  ┌──────────────────┬──────────────────┬────────────────────────────────┐   │
│  │  Workload         │  Use              │  Why                           │   │
│  ├──────────────────┼──────────────────┼────────────────────────────────┤   │
│  │  CPU-bound        │  multiprocessing  │  Threads cannot parallelize    │   │
│  │  (math, parsing)  │  or ProcessPool   │  CPU work due to GIL           │   │
│  │                   │                   │                                │   │
│  │  I/O-bound        │  asyncio or       │  GIL is released during I/O   │   │
│  │  (HTTP, DB, file) │  threading        │  waits, enabling concurrency   │   │
│  │                   │                   │                                │   │
│  │  Mixed            │  asyncio +        │  Async for I/O, process pool   │   │
│  │                   │  ProcessPool      │  for CPU-heavy parts           │   │
│  └──────────────────┴──────────────────┴────────────────────────────────┘   │
│                                                                             │
│  NOTE: Python 3.13+ introduces an experimental free-threaded mode           │
│  (--disable-gil) that removes the GIL. Watch for production readiness.      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### asyncio Patterns

```python
import asyncio
import aiohttp

# Gather: run coroutines concurrently
async def fetch_all(urls: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch(session, url) for url in urls]
        return await asyncio.gather(*tasks, return_exceptions=True)

async def fetch(session: aiohttp.ClientSession, url: str) -> dict:
    async with session.get(url) as response:
        return await response.json()

# Semaphore: limit concurrency
async def fetch_with_limit(urls: list[str], limit: int = 10) -> list[dict]:
    semaphore = asyncio.Semaphore(limit)

    async def limited_fetch(session, url):
        async with semaphore:
            return await fetch(session, url)

    async with aiohttp.ClientSession() as session:
        tasks = [limited_fetch(session, url) for url in urls]
        return await asyncio.gather(*tasks)

# TaskGroup (Python 3.11+): structured concurrency
async def process_items(items: list[Item]) -> list[Result]:
    results = []
    async with asyncio.TaskGroup() as tg:
        for item in items:
            tg.create_task(process(item))
    # All tasks complete or all are cancelled if one raises
    return results

# Timeout
async def with_timeout():
    try:
        async with asyncio.timeout(5.0):
            result = await slow_operation()
    except TimeoutError:
        print("Operation timed out")
```

### Producer-Consumer with asyncio.Queue

```python
import asyncio

async def producer(queue: asyncio.Queue, items: list):
    for item in items:
        await queue.put(item)
    await queue.put(None)  # Sentinel to signal completion

async def consumer(queue: asyncio.Queue, worker_id: int):
    while True:
        item = await queue.get()
        if item is None:
            queue.task_done()
            await queue.put(None)  # Pass sentinel to next consumer
            break
        await process(item)
        queue.task_done()

async def main():
    queue = asyncio.Queue(maxsize=100)
    items = list(range(1000))

    producers = [asyncio.create_task(producer(queue, items))]
    consumers = [asyncio.create_task(consumer(queue, i)) for i in range(5)]

    await asyncio.gather(*producers)
    await queue.join()
    for c in consumers:
        c.cancel()
```

### multiprocessing for CPU-Bound Work

```python
from concurrent.futures import ProcessPoolExecutor
import multiprocessing

def cpu_intensive(n: int) -> int:
    """This runs in a separate process, bypassing the GIL."""
    return sum(i * i for i in range(n))

# ProcessPoolExecutor
def parallel_compute(inputs: list[int]) -> list[int]:
    with ProcessPoolExecutor(max_workers=multiprocessing.cpu_count()) as executor:
        results = list(executor.map(cpu_intensive, inputs))
    return results

# Mixing async + multiprocessing
async def async_cpu_work(inputs: list[int]) -> list[int]:
    loop = asyncio.get_event_loop()
    with ProcessPoolExecutor() as pool:
        tasks = [loop.run_in_executor(pool, cpu_intensive, n) for n in inputs]
        return await asyncio.gather(*tasks)
```

### Python Concurrency Pitfalls

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  PITFALL                        │  SYMPTOM              │  FIX              │
├─────────────────────────────────┼───────────────────────┼───────────────────┤
│  Using threads for CPU work     │  No speedup, GIL      │  Use              │
│                                 │  contention overhead  │  multiprocessing  │
│                                 │                       │  or ProcessPool   │
│                                 │                       │                   │
│  Forgetting await               │  Coroutine never      │  Enable           │
│  result = async_func()          │  executes, silent     │  RuntimeWarning   │
│  (missing await)                │  bug                  │  for unawaited    │
│                                 │                       │  coroutines       │
│                                 │                       │                   │
│  Blocking call in async         │  Event loop blocked,  │  Use              │
│  (calling requests.get() in     │  all tasks stall      │  aiohttp instead  │
│   async function)               │                       │  of requests. Or  │
│                                 │                       │  run_in_executor  │
│                                 │                       │                   │
│  Shared mutable state           │  Race conditions      │  Use asyncio.Lock │
│  across async tasks             │  with non-atomic ops  │  or redesign to   │
│                                 │                       │  avoid sharing    │
│                                 │                       │                   │
│  fire-and-forget tasks          │  Exceptions silently  │  Store task refs, │
│  asyncio.create_task(coro)      │  swallowed, task GC'd │  add done callback│
│  (no reference kept)            │                       │  or use TaskGroup │
│                                 │                       │                   │
│  Pickle limitations in          │  Cannot pass lambdas  │  Use top-level    │
│  multiprocessing                │  or closures across   │  functions only.  │
│                                 │  process boundaries   │  Serialize data   │
│                                 │                       │  explicitly.      │
└─────────────────────────────────┴───────────────────────┴───────────────────┘
```

---

## Testing Concurrent Code

### General Strategies

```
TESTING CONCURRENCY:
┌──────────────────────────────────────────────────────────────────────────┐
│  Strategy              │  What It Tests           │  Tools              │
├────────────────────────┼──────────────────────────┼─────────────────────┤
│  Race detector         │  Data races              │  go test -race      │
│                        │                          │  ThreadSanitizer    │
│                        │                          │                     │
│  Stress testing        │  Behavior under high     │  Run tests 1000x   │
│                        │  concurrency             │  with many threads  │
│                        │                          │                     │
│  Deterministic testing │  Specific interleavings  │  Control scheduling │
│                        │                          │  with barriers,     │
│                        │                          │  latches            │
│                        │                          │                     │
│  Property-based        │  Invariants hold under   │  Hypothesis (Python)│
│                        │  random interleavings    │  proptest (Rust)    │
│                        │                          │  rapid (Go)         │
│                        │                          │                     │
│  Model checking        │  All possible states     │  TLA+ (design),     │
│                        │  explored formally       │  Loom (Rust)        │
│                        │                          │                     │
│  Chaos / fault inject  │  Resilience to failures  │  Toxiproxy,        │
│                        │  during concurrent ops   │  Chaos Monkey       │
└────────────────────────┴──────────────────────────┴─────────────────────┘
```

### Go: Testing with Race Detector

```go
// Always run tests with -race flag
// go test -race ./...

func TestConcurrentCounter(t *testing.T) {
    counter := NewAtomicCounter()
    var wg sync.WaitGroup

    for i := 0; i < 1000; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            counter.Increment()
        }()
    }

    wg.Wait()

    if counter.Value() != 1000 {
        t.Errorf("Expected 1000, got %d", counter.Value())
    }
}
```

### Rust: Loom for Exhaustive Testing

```rust
#[cfg(test)]
mod tests {
    use loom::sync::Arc;
    use loom::sync::atomic::{AtomicUsize, Ordering};
    use loom::thread;

    #[test]
    fn test_concurrent_increment() {
        loom::model(|| {
            let counter = Arc::new(AtomicUsize::new(0));

            let threads: Vec<_> = (0..2).map(|_| {
                let counter = Arc::clone(&counter);
                thread::spawn(move || {
                    counter.fetch_add(1, Ordering::SeqCst);
                })
            }).collect();

            for t in threads {
                t.join().unwrap();
            }

            assert_eq!(counter.load(Ordering::SeqCst), 2);
        });
    }
}
```

### Python: Testing Async Code

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_concurrent_fetch():
    results = await fetch_all(["http://example.com/1", "http://example.com/2"])
    assert len(results) == 2
    assert all(r.status == 200 for r in results)

@pytest.mark.asyncio
async def test_semaphore_limits_concurrency():
    active = 0
    max_active = 0
    lock = asyncio.Lock()

    async def tracked_task():
        nonlocal active, max_active
        async with lock:
            active += 1
            max_active = max(max_active, active)
        await asyncio.sleep(0.1)
        async with lock:
            active -= 1

    semaphore = asyncio.Semaphore(5)
    tasks = []
    for _ in range(20):
        async def limited():
            async with semaphore:
                await tracked_task()
        tasks.append(asyncio.create_task(limited()))

    await asyncio.gather(*tasks)
    assert max_active <= 5
```

### JavaScript: Testing Async Patterns

```typescript
describe('ConcurrencyLimiter', () => {
  it('should limit concurrent executions', async () => {
    let active = 0;
    let maxActive = 0;

    const task = async () => {
      active++;
      maxActive = Math.max(maxActive, active);
      await new Promise(resolve => setTimeout(resolve, 50));
      active--;
    };

    const tasks = Array.from({ length: 20 }, () => task);
    await withConcurrencyLimit(tasks, 5);

    expect(maxActive).toBeLessThanOrEqual(5);
  });

  it('should handle rejections without losing results', async () => {
    const tasks = [
      () => Promise.resolve('ok'),
      () => Promise.reject(new Error('fail')),
      () => Promise.resolve('also ok'),
    ];

    const results = await Promise.allSettled(tasks.map(t => t()));
    expect(results[0]).toEqual({ status: 'fulfilled', value: 'ok' });
    expect(results[1].status).toBe('rejected');
    expect(results[2]).toEqual({ status: 'fulfilled', value: 'also ok' });
  });
});
```

---

## Cross-Language Comparison

```
┌─────────────────────┬───────────────┬───────────────┬───────────────┬───────────────┐
│  Feature            │  Go            │  Rust          │  JavaScript   │  Python        │
├─────────────────────┼───────────────┼───────────────┼───────────────┼───────────────┤
│  Concurrency model  │  Goroutines   │  Ownership +  │  Event loop   │  GIL + asyncio│
│                     │  + channels   │  async/await  │  (single      │  or multi-    │
│                     │  (CSP)        │               │   thread)     │  processing   │
│                     │               │               │               │               │
│  True parallelism   │  Yes (runtime │  Yes (threads │  Web Workers/ │  Only via     │
│                     │  schedules on │  or async     │  Worker       │  multiprocess │
│                     │  OS threads)  │  tasks)       │  Threads      │  (GIL blocks) │
│                     │               │               │               │               │
│  Data race safety   │  Runtime      │  Compile-time │  N/A (single  │  N/A (GIL) +  │
│                     │  (race        │  (ownership   │  threaded)    │  asyncio.Lock │
│                     │  detector)    │  prevents)    │               │  for async    │
│                     │               │               │               │               │
│  Cancellation       │  context.Ctx  │  Drop / abort │  AbortCtrl    │  Task.cancel()│
│                     │               │               │               │  / TaskGroup  │
│                     │               │               │               │               │
│  Error handling     │  errgroup     │  Result<T,E>  │  Promise.all  │  TaskGroup or │
│                     │               │  + join       │  Settled      │  gather(       │
│                     │               │               │               │  return_exc)  │
│                     │               │               │               │               │
│  Typical use case   │  Network      │  Systems,     │  Web servers, │  Data science,│
│                     │  services,    │  performance- │  UI, I/O-     │  web servers, │
│                     │  CLI tools    │  critical     │  heavy apps   │  scripting    │
└─────────────────────┴───────────────┴───────────────┴───────────────┴───────────────┘
```
