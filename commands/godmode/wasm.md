# /godmode:wasm

Compile, integrate, optimize, and test WebAssembly modules. Covers Rust/C++/Go to WASM compilation, WASI for portable system access, browser and server-side integration, plugin systems, and performance profiling.

## Usage

```
/godmode:wasm                           # Full WASM development workflow
/godmode:wasm --rust                    # Rust-to-WASM compilation setup
/godmode:wasm --cpp                     # C/C++-to-WASM via Emscripten
/godmode:wasm --go                      # Go-to-WASM via TinyGo
/godmode:wasm --wasi                    # Build WASI-compatible module
/godmode:wasm --browser                 # Browser integration setup
/godmode:wasm --server                  # Server-side runtime integration
/godmode:wasm --plugin                  # Design WASM plugin system
/godmode:wasm --optimize                # Optimize binary size and performance
/godmode:wasm --profile                 # Profile WASM execution and memory
/godmode:wasm --test                    # Generate WASM test suite
/godmode:wasm --size                    # Binary size analysis and optimization
```

## What It Does

1. Discovers project context, source language, target environment, and size budget
2. Sets up compilation pipeline (wasm-pack for Rust, Emscripten for C/C++, TinyGo for Go)
3. Configures build optimization (LTO, size optimization, symbol stripping, wasm-opt)
4. Integrates with browser via wasm-bindgen, streaming compilation, and Web Workers
5. Configures WASI for portable server-side modules with capability-based security
6. Sets up server-side runtimes (Wasmtime, Wasmer, wazero) for plugin systems
7. Profiles binary size (twiggy) and execution performance (Chrome DevTools, benchmarks)
8. Generates tests at native and WASM layers with size regression CI gates

## Output
- WASM binary: `pkg/<name>_bg.wasm` (optimized)
- JS glue: `pkg/<name>.js` + `pkg/<name>.d.ts`
- Build config: `Cargo.toml` / `Makefile` / build script
- Integration: `src/wasm-loader.ts` (browser integration code)
- Tests: `tests/wasm-*.test.ts` + native unit tests
- Commit: `"wasm: <module> — <N> KB gzipped, <language>-to-WASM, <target> integration"`

## Next Step
After WASM build: `/godmode:perf` to profile hot paths, or `/godmode:edge` to deploy WASM to edge runtimes.

## Examples

```
/godmode:wasm --rust Compile our image processing library to WASM for the browser
/godmode:wasm --plugin Create a WASM plugin system for our Go application
/godmode:wasm --optimize Our WASM binary is 2MB, we need it under 200KB
/godmode:wasm --wasi Build a WASI module for our server-side computation
/godmode:wasm --size Analyze what is bloating our WASM binary
```
