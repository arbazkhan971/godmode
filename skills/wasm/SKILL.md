---
name: wasm
description: |
  WebAssembly development skill. Activates when user needs to compile, integrate, optimize, or debug WebAssembly modules. Covers compilation from Rust, C++, and Go to WASM, WASI (WebAssembly System Interface) for portable system access, browser-side WASM integration with JavaScript, server-side WASM runtimes (Wasmtime, Wasmer), and performance profiling of WASM modules. Produces optimized WASM binaries, integration code, and test harnesses. Triggers on: /godmode:wasm, "compile to WebAssembly", "use WASM", "WASI module", "optimize WASM performance", or when the orchestrator detects WebAssembly-related work.
---

# WASM — WebAssembly Development

## When to Activate
- User invokes `/godmode:wasm`
- User says "compile to WebAssembly", "use WASM", "build WASM module"
- User says "WASI module", "portable WASM", "run WASM on the server"
- User says "optimize WASM performance", "profile WASM", "reduce WASM size"
- User says "integrate WASM with JavaScript", "call WASM from browser"
- When `/godmode:plan` identifies performance-critical code suitable for WASM
- When `/godmode:perf` recommends offloading computation to WASM

## Workflow

### Step 1: Discovery & Context
Understand the WebAssembly requirements:

```
WASM DISCOVERY:
Project: <name and purpose>
Source language: Rust | C/C++ | Go | AssemblyScript | Zig | Swift
Target environment: Browser | Server (Wasmtime/Wasmer) | Edge (Cloudflare Workers) | Embedded
Use case: <compute-intensive, codec, crypto, image processing, game engine, plugin system>
Integration: <JavaScript interop, standalone CLI, library, plugin>
Size budget: <KB target for browser delivery>
Performance target: <latency, throughput, compared to native>
WASI needs: <file system, network, clocks, random, none>
Existing codebase: <porting existing native code vs greenfield>
```

If the user hasn't specified, ask: "What language are you compiling from? Where will the WASM module run (browser or server)?"

### Step 2: Rust to WASM Compilation
Set up Rust-to-WASM compilation pipeline:

```
RUST TO WASM:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  Target: wasm32-unknown-unknown (browser, no WASI)           │
│          wasm32-wasi (server, WASI system interface)         │
│          wasm32-wasip1 (WASI preview 1)                      │
│          wasm32-wasip2 (WASI preview 2 — component model)    │
│                                                              │
│  Toolchain:                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐               │
│  │  Rust     │───│  wasm-   │───│  wasm-opt │               │
│  │  (cargo)  │   │  bindgen │   │  (Binaryen)│               │
│  └──────────┘    └──────────┘    └──────────┘               │
│       │                │               │                     │
│    .wasm            JS glue        optimized                 │
│    binary           + .wasm         .wasm                    │
│                                                              │
│  Alternative: wasm-pack (all-in-one)                         │
│  ┌──────────┐    ┌──────────┐                                │
│  │  Rust     │───│ wasm-pack│──> npm package                 │
│  │  (cargo)  │   │  build   │   (JS + .wasm + types)        │
│  └──────────┘    └──────────┘                                │
│                                                              │
└─────────────────────────────────────────────────────────────┘

PROJECT SETUP (Rust + wasm-pack):
  # Cargo.toml
  [lib]
  crate-type = ["cdylib", "rlib"]

  [dependencies]
  wasm-bindgen = "0.2"
  js-sys = "0.3"        # JavaScript standard library bindings
  web-sys = "0.3"       # Web API bindings (DOM, fetch, etc.)
  serde = { version = "1", features = ["derive"] }
  serde-wasm-bindgen = "0.6"

  [profile.release]
  opt-level = "z"        # Optimize for size (or "s" for balanced)
  lto = true             # Link-time optimization
  codegen-units = 1      # Single codegen unit for maximum optimization
  strip = true           # Strip debug symbols
  panic = "abort"        # Smaller panic handling

  # Build command
  wasm-pack build --target web --release
  # Targets: web (ES modules), bundler (webpack), nodejs, no-modules

RUST WASM PATTERNS:

  // Expose function to JavaScript
  #[wasm_bindgen]
  pub fn process_data(input: &[u8]) -> Vec<u8> {
      // Compute-intensive work in Rust
      // Returns result to JavaScript
  }

  // Accept and return complex types via serde
  #[wasm_bindgen]
  pub fn transform(input: JsValue) -> Result<JsValue, JsError> {
      let data: InputData = serde_wasm_bindgen::from_value(input)?;
      let result = process(data);
      Ok(serde_wasm_bindgen::to_value(&result)?)
  }

  // Access DOM APIs via web-sys
  #[wasm_bindgen]
  pub fn render_to_canvas(canvas_id: &str) -> Result<(), JsError> {
      let document = web_sys::window().unwrap().document().unwrap();
      let canvas = document.get_element_by_id(canvas_id).unwrap();
      // ...
  }
```

### Step 3: C/C++ and Go to WASM
Support additional source languages:

```
C/C++ TO WASM (Emscripten):
┌─────────────────────────────────────────────────────────────┐
│  Toolchain: Emscripten (emcc/em++)                           │
│                                                              │
│  # Compile C/C++ to WASM                                     │
│  emcc src/main.c -o output.js \                              │
│    -s WASM=1 \                                               │
│    -s EXPORTED_FUNCTIONS='["_process","_malloc","_free"]' \   │
│    -s EXPORTED_RUNTIME_METHODS='["ccall","cwrap"]' \         │
│    -s MODULARIZE=1 \                                         │
│    -s EXPORT_NAME='createModule' \                           │
│    -O3                                                       │
│                                                              │
│  Output: output.js (glue code) + output.wasm (binary)        │
│                                                              │
│  Key flags:                                                  │
│    -O3: Maximum optimization                                 │
│    -Os: Optimize for size                                    │
│    -s WASM=1: Emit WASM (not asm.js fallback)               │
│    -s ALLOW_MEMORY_GROWTH=1: Dynamic memory (heap growth)    │
│    -s TOTAL_MEMORY=64MB: Fixed memory (faster, predictable)  │
│    -s PTHREAD_POOL_SIZE=4: Web Workers for threads            │
│    -s FILESYSTEM=0: Disable FS emulation (smaller binary)    │
│                                                              │
│  Use cases: Porting existing C/C++ libraries (SQLite, FFmpeg,│
│  image codecs, physics engines, crypto)                      │
└─────────────────────────────────────────────────────────────┘

GO TO WASM:
┌─────────────────────────────────────────────────────────────┐
│  Toolchain: Go compiler (built-in) or TinyGo                 │
│                                                              │
│  # Standard Go (large binary, full runtime):                 │
│  GOOS=js GOARCH=wasm go build -o main.wasm ./cmd/wasm       │
│  # Requires wasm_exec.js from Go distribution                │
│                                                              │
│  # TinyGo (RECOMMENDED — much smaller binaries):             │
│  tinygo build -o main.wasm -target wasm ./cmd/wasm           │
│  # Or with WASI:                                             │
│  tinygo build -o main.wasm -target wasi ./cmd/wasm           │
│                                                              │
│  Size comparison:                                            │
│    Standard Go: ~2-10 MB (includes Go runtime + GC)          │
│    TinyGo: ~50-500 KB (stripped runtime)                     │
│                                                              │
│  Limitations:                                                │
│    - Standard Go: large binary, includes full GC             │
│    - TinyGo: no goroutines in WASM, limited reflect, some    │
│      stdlib packages unsupported                             │
│    - Neither supports threads in WASM yet                    │
│                                                              │
│  Use cases: Porting Go logic to browser, WASI plugins,       │
│  when team already knows Go                                  │
└─────────────────────────────────────────────────────────────┘

LANGUAGE SELECTION GUIDE:
┌──────────────┬──────────────┬──────────────┬──────────────┐
│  Factor      │  Rust        │  C/C++       │  Go          │
├──────────────┼──────────────┼──────────────┼──────────────┤
│  Binary size │  10-100 KB   │  50-500 KB   │  2-10 MB     │
│              │  (smallest)  │  (small)     │  (large)     │
│  Performance │  Near-native │  Near-native │  Good (GC    │
│              │              │              │  overhead)   │
│  Safety      │  Memory-safe │  Manual      │  GC-managed  │
│              │              │  memory      │              │
│  JS interop  │  Excellent   │  Good        │  Basic       │
│              │  (wasm-bindgen)│ (Emscripten)│ (wasm_exec)  │
│  WASI support│  Excellent   │  Good        │  Good        │
│              │              │              │  (via TinyGo)│
│  Ecosystem   │  Growing fast│  Mature      │  Limited     │
│  Best for    │  New WASM    │  Porting     │  Quick       │
│              │  projects    │  legacy C/C++│  prototypes  │
└──────────────┴──────────────┴──────────────┴──────────────┘

RECOMMENDATION: Rust for new WASM projects. C/C++ for porting existing
native code. TinyGo for teams with Go expertise and simple use cases.
```

### Step 4: WASI — WebAssembly System Interface
Design portable WASM modules with system access:

```
WASI ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  WHAT IS WASI?                                               │
│  WASI provides a standardized system interface for WASM,     │
│  enabling portable access to files, network, clocks, and     │
│  environment — without browser APIs.                         │
│                                                              │
│  ┌──────────┐                                                │
│  │   WASM    │  Pure computation (no system access)           │
│  │  Module   │                                                │
│  └────┬─────┘                                                │
│       │ imports WASI functions                                │
│  ┌────┴─────┐                                                │
│  │   WASI    │  Standardized system interface                 │
│  │ Interface │  (file I/O, env vars, clocks, random)         │
│  └────┬─────┘                                                │
│       │ host provides implementations                        │
│  ┌────┴─────┐                                                │
│  │   Host    │  Wasmtime, Wasmer, Node.js, browser polyfill  │
│  │  Runtime  │                                                │
│  └──────────┘                                                │
│                                                              │
└─────────────────────────────────────────────────────────────┘

WASI CAPABILITIES:
┌──────────────────────────────────────────────────────────────┐
│  Interface         │  Provides                │  Status       │
├────────────────────┼──────────────────────────┼───────────────┤
│  wasi:filesystem   │  File read/write, dirs   │  Stable       │
│  wasi:cli          │  Args, env, stdio        │  Stable       │
│  wasi:clocks       │  Wall clock, monotonic   │  Stable       │
│  wasi:random       │  Cryptographic random    │  Stable       │
│  wasi:sockets      │  TCP/UDP networking      │  Preview      │
│  wasi:http         │  HTTP client/server      │  Preview      │
│  wasi:io           │  Streams, polling        │  Stable       │
│  wasi:logging      │  Structured logging      │  Proposal     │
│  wasi:keyvalue     │  Key-value storage       │  Proposal     │
│  wasi:blobstore    │  Blob storage            │  Proposal     │
└────────────────────┴──────────────────────────┴───────────────┘

WASI COMPONENT MODEL (Preview 2):
  The component model enables WASM modules to:
  - Import and export rich interfaces (not just functions)
  - Compose multiple WASM components together
  - Use high-level types (strings, records, variants, lists)
  - Interoperate across languages (Rust component calls Go component)

  // WIT (WASM Interface Type) definition
  package my:plugin@1.0.0;

  interface processor {
    record input-data {
      content: list<u8>,
      format: string,
    }

    record output-data {
      result: list<u8>,
      metadata: list<tuple<string, string>>,
    }

    process: func(data: input-data) -> result<output-data, string>;
  }

  world my-plugin {
    import wasi:logging/logging;
    export processor;
  }

SECURITY MODEL:
  WASI uses capability-based security:
  - Modules have NO access by default (sandboxed)
  - Host explicitly grants capabilities:
    wasmtime run --dir=/data::readonly --env=APP_ENV=prod module.wasm
  - File access restricted to pre-opened directories
  - Network access requires explicit host grant
  - No ambient authority — every resource is explicitly passed
```

### Step 5: Browser-Side WASM Integration
Integrate WASM modules into web applications:

```
BROWSER INTEGRATION:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  LOADING PATTERNS:                                           │
│                                                              │
│  Pattern 1: Streaming compilation (RECOMMENDED)              │
│  ─────────────────────────────────────────────               │
│  const { instance } = await WebAssembly.instantiateStreaming( │
│    fetch('/module.wasm'),                                    │
│    importObject                                              │
│  );                                                          │
│  // Compiles while downloading — fastest for large modules   │
│                                                              │
│  Pattern 2: wasm-bindgen / wasm-pack generated               │
│  ────────────────────────────────────────────                │
│  import init, { processData } from './pkg/my_module.js';     │
│  await init();  // Loads and instantiates WASM               │
│  const result = processData(input);  // Call like normal JS  │
│                                                              │
│  Pattern 3: Web Worker isolation                             │
│  ───────────────────────────────                             │
│  // main.js                                                  │
│  const worker = new Worker('wasm-worker.js');                │
│  worker.postMessage({ type: 'process', data: input });       │
│  worker.onmessage = (e) => handleResult(e.data);            │
│                                                              │
│  // wasm-worker.js                                           │
│  const wasm = await WebAssembly.instantiateStreaming(         │
│    fetch('/module.wasm')                                     │
│  );                                                          │
│  self.onmessage = (e) => {                                   │
│    const result = wasm.instance.exports.process(e.data);     │
│    self.postMessage(result);                                 │
│  };                                                          │
│  // Runs on separate thread — no main thread blocking        │
│                                                              │
└─────────────────────────────────────────────────────────────┘

MEMORY MANAGEMENT:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  WASM uses linear memory — a contiguous byte array shared    │
│  between JS and WASM.                                        │
│                                                              │
│  Passing data JS -> WASM:                                    │
│  1. Allocate memory in WASM (call exported alloc function)   │
│  2. Copy data from JS into WASM memory                       │
│  3. Pass pointer and length to WASM function                 │
│  4. Free memory when done (call exported dealloc function)   │
│                                                              │
│  // Manual memory management                                 │
│  const ptr = wasm.exports.alloc(data.length);                │
│  new Uint8Array(wasm.exports.memory.buffer, ptr, data.length)│
│    .set(data);                                               │
│  const resultPtr = wasm.exports.process(ptr, data.length);   │
│  wasm.exports.dealloc(ptr, data.length);                     │
│                                                              │
│  // With wasm-bindgen (automatic — RECOMMENDED)              │
│  const result = processData(new Uint8Array(data));           │
│  // wasm-bindgen handles alloc/copy/dealloc automatically    │
│                                                              │
│  RULES:                                                      │
│  - Never hold references to memory.buffer across WASM calls  │
│    (buffer may be detached if memory grows)                  │
│  - Use TypedArrays for bulk data transfer                    │
│  - Prefer wasm-bindgen for complex data (strings, objects)   │
│  - For large data, use SharedArrayBuffer (requires COOP/COEP)│
│                                                              │
└─────────────────────────────────────────────────────────────┘

BUNDLER INTEGRATION:
  Webpack: experiments.asyncWebAssembly = true (Webpack 5+)
  Vite: built-in WASM support via ?init import
  Rollup: @rollup/plugin-wasm
  Next.js: experimental.serverComponentsExternalPackages or webpack config

  // Vite example
  import init from './pkg/my_module.wasm?init';
  const instance = await init();

  // Webpack example (async WASM)
  import { processData } from './pkg/my_module';
  const result = await processData(input);
```

### Step 6: Server-Side WASM Runtimes
Run WASM outside the browser:

```
SERVER-SIDE WASM RUNTIMES:
┌──────────────┬──────────────┬──────────────┬───────────────┐
│  Runtime     │  Language    │  Strengths   │  Best For     │
├──────────────┼──────────────┼──────────────┼───────────────┤
│  Wasmtime    │  Rust        │  Standards-  │  Production   │
│              │              │  compliant,  │  workloads,   │
│              │              │  Cranelift   │  WASI P2       │
│              │              │  JIT/AOT     │               │
│  Wasmer      │  Rust        │  Multiple    │  Plugin       │
│              │              │  backends,   │  systems,     │
│              │              │  package mgr │  edge deploy  │
│  WasmEdge    │  C++         │  Lightweight,│  Edge/IoT,    │
│              │              │  AI/ML ext,  │  Kubernetes   │
│              │              │  Kubernetes  │               │
│  wazero      │  Go          │  Pure Go,    │  Go apps      │
│              │              │  zero deps,  │  needing WASM │
│              │              │  embeddable  │  plugins      │
│  Node.js     │  C++         │  Built-in    │  Node.js apps │
│  (V8)        │              │  V8 engine   │  with WASM    │
└──────────────┴──────────────┴──────────────┴───────────────┘

USE CASES FOR SERVER-SIDE WASM:

1. Plugin/Extension Systems:
   ─────────────────────────
   Host application loads WASM plugins at runtime.
   Plugins run sandboxed — cannot access host memory or FS
   unless explicitly granted.

   Benefits:
   - Language-agnostic plugins (Rust, Go, C, Python compiled to WASM)
   - Security sandboxing (plugins cannot crash host)
   - Hot-reload (load new plugin without restart)
   - Deterministic execution (same input = same output)

2. Serverless/Edge Functions:
   ──────────────────────────
   WASM modules as serverless function handlers.
   Sub-millisecond cold starts (vs seconds for containers).

   Platforms: Cloudflare Workers, Fermyon Spin, wasmCloud, Fastly Compute

3. Embedded Computation:
   ─────────────────────
   Embed WASM runtime in existing application for safe
   user-defined computation (formulas, filters, transformations).

   Benefits:
   - Sandboxed execution with resource limits
   - Deterministic and reproducible
   - Portable across host environments

EMBEDDING PATTERN (Rust + Wasmtime):
  // Load and instantiate a WASM module
  let engine = Engine::default();
  let module = Module::from_file(&engine, "plugin.wasm")?;
  let mut store = Store::new(&engine, host_state);

  // Link WASI capabilities
  let wasi = WasiCtxBuilder::new()
      .inherit_stdio()
      .preopened_dir("/data", "data", DirPerms::READ, FilePerms::READ)?
      .build();

  let mut linker = Linker::new(&engine);
  wasmtime_wasi::add_to_linker(&mut linker, |s| &mut s.wasi)?;

  let instance = linker.instantiate(&mut store, &module)?;
  let process = instance.get_typed_func::<(i32, i32), i32>(&mut store, "process")?;
  let result = process.call(&mut store, (ptr, len))?;

EMBEDDING PATTERN (Go + wazero):
  ctx := context.Background()
  r := wazero.NewRuntime(ctx)
  defer r.Close(ctx)

  wasi_snapshot_preview1.MustInstantiate(ctx, r)

  code, _ := os.ReadFile("plugin.wasm")
  mod, _ := r.InstantiateWithConfig(ctx,
      code,
      wazero.NewModuleConfig().
          WithStdout(os.Stdout).
          WithFS(dataFS),
  )

  process := mod.ExportedFunction("process")
  result, _ := process.Call(ctx, ptr, length)
```

### Step 7: Performance Profiling WASM Modules
Optimize WASM binary size and execution performance:

```
PERFORMANCE PROFILING:

1. BINARY SIZE OPTIMIZATION:
   ─────────────────────────
   Size budget for browser delivery:
   - Target: <100 KB gzipped for most use cases
   - Acceptable: <500 KB gzipped for heavy computation
   - Large: >1 MB gzipped (consider code splitting or lazy loading)

   Optimization techniques:
   ┌──────────────────────────────────────────────────────────┐
   │  Technique                    │  Size Reduction          │
   ├───────────────────────────────┼──────────────────────────┤
   │  opt-level = "z" (Rust)      │  10-30% smaller          │
   │  LTO (link-time optimization)│  10-20% smaller          │
   │  Strip debug symbols         │  50-80% smaller          │
   │  wasm-opt -Oz (Binaryen)     │  5-15% smaller           │
   │  panic = "abort" (Rust)      │  5-10% smaller           │
   │  Remove unused features      │  Varies                  │
   │  twiggy (dead code analysis) │  Identifies bloat        │
   │  wasm-snip (remove functions)│  Surgical removal        │
   │  gzip/brotli compression     │  60-80% transfer savings │
   └───────────────────────────────┴──────────────────────────┘

   Measurement tools:
   - twiggy top module.wasm — shows largest functions/data
   - twiggy dominators module.wasm — shows what keeps code alive
   - wasm-opt --metrics module.wasm — binary section sizes
   - Bloaty McBloatface — binary size profiling

2. EXECUTION PERFORMANCE:
   ───────────────────────
   Profiling tools:
   - Chrome DevTools: Performance tab with WASM support
   - Firefox Profiler: Native WASM profiling with source maps
   - perf (Linux): Profile WASM running in Wasmtime/Wasmer
   - Instruments (macOS): Profile server-side WASM runtimes
   - wasm-opt --metrics: Instruction count analysis

   Benchmark patterns:
   ┌──────────────────────────────────────────────────────────┐
   │  BENCHMARK METHODOLOGY:                                  │
   │                                                          │
   │  1. Baseline: Measure pure JavaScript implementation     │
   │  2. WASM: Measure WASM implementation                    │
   │  3. Compare: Ops/sec, latency percentiles, memory usage  │
   │  4. Include: Data transfer overhead (JS <-> WASM)        │
   │                                                          │
   │  Common results:                                         │
   │  - CPU-bound computation: WASM 2-10x faster than JS      │
   │  - Small operations: JS faster (WASM call overhead)      │
   │  - Large data transfer: Overhead can negate gains         │
   │  - DOM manipulation: JS always faster (no WASM DOM API)  │
   │                                                          │
   │  Rule: WASM wins when computation dominates.             │
   │  WASM loses when data transfer or interop dominates.     │
   └──────────────────────────────────────────────────────────┘

3. MEMORY PROFILING:
   ──────────────────
   WASM linear memory is a contiguous buffer that can only grow.

   Monitor:
   - memory.buffer.byteLength — current memory allocation
   - Peak memory usage during computation
   - Memory growth events (expensive — triggers buffer detachment)
   - Fragmentation in allocator (wee_alloc, dlmalloc, etc.)

   Tips:
   - Pre-allocate memory if workload size is known
   - Reuse buffers across calls instead of alloc/dealloc per call
   - Use wee_alloc (Rust) for smaller allocator code
   - Monitor with: new WebAssembly.Memory({ initial: 256, maximum: 1024 })

4. WASM-SPECIFIC OPTIMIZATIONS:
   ─────────────────────────────
   - Minimize JS-WASM boundary crossings (batch operations)
   - Use SharedArrayBuffer for zero-copy data sharing with Workers
   - Enable WASM SIMD for vector operations (128-bit)
   - Enable WASM threads for parallel computation
   - Use streaming compilation for faster startup
   - Cache compiled modules with WebAssembly.compileStreaming + Cache API
```

### Step 8: Testing WASM Modules
Comprehensive testing strategy:

```
WASM TESTING STRATEGY:
┌─────────────────────────────────────────────────────────────┐
│  Layer              │  What to Test            │  Tool       │
├─────────────────────┼──────────────────────────┼─────────────┤
│  Unit (native)      │  Core logic in source    │  cargo test │
│                     │  language without WASM   │  / go test  │
│  Unit (WASM)        │  Compiled WASM module    │  wasm-bindgen│
│                     │  in headless browser     │  -test      │
│  Integration        │  JS + WASM interaction   │  Playwright │
│                     │  in real browser         │  / Vitest   │
│  Size regression    │  Binary size within      │  Custom CI  │
│                     │  budget after changes    │  check      │
│  Performance        │  Ops/sec and latency     │  Benchmark  │
│                     │  regression detection    │  harness    │
│  Compatibility      │  Works across browsers   │  BrowserStack│
│                     │  and runtimes            │  / Sauce    │
│  WASI conformance   │  Correct system calls    │  Wasmtime   │
│                     │  on server runtimes      │  / Wasmer   │
└─────────────────────┴──────────────────────────┴─────────────┘

TEST PATTERNS:

1. Native unit tests (test logic without WASM overhead):
   # Rust
   cargo test  # Tests run natively, not in WASM
   # Go
   go test ./...  # Tests run natively

2. WASM unit tests (test compiled WASM in browser):
   # Rust + wasm-bindgen-test
   wasm-pack test --headless --chrome
   # Runs tests inside headless Chrome/Firefox

3. Integration test pattern:
   // test/wasm-integration.test.ts
   describe('WASM module', () => {
     let module;
     beforeAll(async () => { module = await init(); });

     it('processes data correctly', () => {
       const input = new Uint8Array([1, 2, 3]);
       const result = module.process(input);
       expect(result).toEqual(expected);
     });

     it('handles large inputs without OOM', () => {
       const large = new Uint8Array(10_000_000);
       expect(() => module.process(large)).not.toThrow();
     });

     it('cleans up memory after processing', () => {
       const before = module.memory.buffer.byteLength;
       for (let i = 0; i < 100; i++) module.process(smallInput);
       const after = module.memory.buffer.byteLength;
       expect(after - before).toBeLessThan(1_000_000);
     });
   });

4. Size regression (CI gate):
   # .github/workflows/wasm-size.yml
   # Build WASM, check gzipped size against threshold
   # Fail if binary exceeds budget
```

### Step 9: Artifacts & Completion
Generate the deliverables:

```
WASM BUILD COMPLETE:

Artifacts:
- Source: src/lib.rs (or src/main.c, cmd/wasm/main.go)
- WASM binary: pkg/<name>_bg.wasm (optimized)
- JS glue: pkg/<name>.js + pkg/<name>.d.ts
- Build config: Cargo.toml / Makefile / build script
- Integration: src/wasm-loader.ts (browser integration code)
- Tests: tests/wasm-*.test.ts + native unit tests
- CI: .github/workflows/wasm-build.yml

Metrics:
- Binary size: <N> KB raw, <M> KB gzipped
- Size budget: WITHIN | OVER budget
- Performance: <N>x faster than JavaScript baseline
- Memory peak: <N> MB during processing
- Browser compatibility: Chrome <V>+, Firefox <V>+, Safari <V>+

Next steps:
-> /godmode:perf — Profile and optimize hot paths
-> /godmode:test — Expand test coverage
-> /godmode:deploy — Deploy with proper MIME types and caching
-> /godmode:edge — Deploy WASM to edge runtime
```

Commit: `"wasm: <module> — <N> KB gzipped, <language>-to-WASM, <target> integration"`

## Key Behaviors

1. **Choose Rust for new WASM projects.** Rust produces the smallest binaries, has the best WASM tooling (wasm-bindgen, wasm-pack), and guarantees memory safety without a garbage collector.
2. **Measure before optimizing.** Profile the JavaScript implementation first. WASM only wins for CPU-bound computation. If the bottleneck is I/O or DOM, WASM will not help.
3. **Binary size is a feature.** Every kilobyte matters for browser delivery. Set a size budget, measure after every change, and gate CI on it.
4. **Minimize boundary crossings.** Each JS-to-WASM call has overhead. Batch operations: pass an array and process it in WASM, instead of calling WASM per element.
5. **Use Web Workers for heavy computation.** WASM on the main thread blocks rendering. Run computation-heavy WASM in a Web Worker and communicate via postMessage.
6. **WASI is for portability.** If the WASM module needs file system, network, or environment access, use WASI. If it is pure computation, target wasm32-unknown-unknown (smaller binary).
7. **Test at both layers.** Unit test the core logic in the native language (fast feedback). Integration test the compiled WASM with real browser/runtime (correctness guarantee).
8. **Cache compiled modules.** WebAssembly.compileStreaming is expensive. Cache the compiled module in IndexedDB or Cache API for instant subsequent loads.

## Example Usage

### Compiling Rust to WASM
```
User: /godmode:wasm Compile our image processing library from Rust to WASM for the browser

WASM: Starting discovery...

WASM DISCOVERY:
Project: Image Processing Library (resize, crop, filter)
Source: Rust (existing crate)
Target: Browser (wasm32-unknown-unknown)
Integration: React app via wasm-pack
Size budget: 200 KB gzipped

Build configured:
- wasm-pack with --target web
- opt-level = "z", LTO enabled, panic = "abort"
- wasm-opt -Oz post-processing
- Web Worker integration for non-blocking processing

Results:
- Binary: 147 KB gzipped (within 200 KB budget)
- Performance: 4.2x faster than JavaScript canvas manipulation
- Memory: 32 MB peak for 4K image processing
```

### Building a Plugin System
```
User: /godmode:wasm Create a WASM plugin system for our Go application

WASM: Designing plugin architecture...

WASM PLUGIN SYSTEM:
Runtime: wazero (pure Go, zero CGO dependencies)
Interface: WASI Preview 1 + custom host functions
Plugin format: .wasm files loaded at runtime

Architecture:
- Host defines interface via WIT (4 exported functions required)
- Plugins compiled from Rust, Go, or C to WASM
- Sandboxed: plugins get read-only /data access, no network
- Hot-reload: new plugins loaded without restart
- Resource limits: 64 MB memory, 5 second timeout per call

Generated:
- Plugin SDK (Rust template + Go template)
- Host runtime integration
- Example plugin with tests
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full WASM development workflow |
| `--rust` | Rust-to-WASM compilation setup |
| `--cpp` | C/C++-to-WASM via Emscripten |
| `--go` | Go-to-WASM via TinyGo |
| `--wasi` | Build WASI-compatible module |
| `--browser` | Browser integration setup |
| `--server` | Server-side runtime integration |
| `--plugin` | Design WASM plugin system |
| `--optimize` | Optimize binary size and performance |
| `--profile` | Profile WASM execution and memory |
| `--test` | Generate WASM test suite |
| `--size` | Binary size analysis and optimization |

## Anti-Patterns

- **Do NOT use WASM for DOM manipulation.** WASM cannot access the DOM directly. Every DOM call goes through JS interop, which is slower than native JS. Use WASM for computation, JS for DOM.
- **Do NOT ignore binary size.** A 5 MB WASM binary defeats the purpose. Set a size budget, measure, and optimize. Use twiggy to find bloat.
- **Do NOT call WASM per-element in a loop.** Each JS-WASM boundary crossing has overhead. Pass the entire array to WASM and process it in one call.
- **Do NOT block the main thread.** Heavy WASM computation on the main thread freezes the UI. Use Web Workers for any operation that takes more than 16ms.
- **Do NOT hold references across memory growth.** When WASM memory grows, all TypedArray views are invalidated. Re-create views after any call that might trigger growth.
- **Do NOT skip native tests.** Testing only in WASM is slow. Test core logic natively (cargo test, go test), then verify WASM integration separately.
- **Do NOT use standard Go compiler for browser WASM.** Standard Go produces 2-10 MB binaries. Use TinyGo for dramatically smaller output.
- **Do NOT assume WASM is always faster.** WASM wins for CPU-bound computation. For small operations or I/O-bound work, JavaScript is often faster due to lower interop overhead.
