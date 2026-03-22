# Rust Developer Guide

How to use Godmode's full workflow for Rust projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Rust via Cargo.toml
# Test: cargo test
# Lint: cargo clippy -- -D warnings
# Build: cargo build --release
# Format: cargo fmt --check
```

### Example `.godmode/config.yaml`
```yaml
language: rust
framework: none             # or actix-web, axum, rocket, etc.
test_command: cargo test
lint_command: cargo clippy -- -D warnings
format_command: cargo fmt --check
build_command: cargo build --release
verify_command: ./target/release/mytool --benchmark
```

---

## How Each Skill Applies to Rust

### THINK Phase

| Skill | Rust Adaptation |
|--|--|
| **think** | Design traits, structs, and enums first. A Rust spec should define the type system before any logic. Include ownership and lifetime considerations. Decide between `&str` and `String`, `Vec` and slices, `Box` and `Arc`. |
| **predict** | Expert panel evaluates ownership model, error handling strategy (`Result` vs. `anyhow` vs. `thiserror`), and async runtime choice (tokio vs. async-std). Request panelists with Rust depth (e.g., compiler contributor, embedded systems engineer). |
| **scenario** | Explore edge cases around lifetime elision failures, borrow checker conflicts, `Send`/`Sync` bounds, `unsafe` usage, and panic paths. |

### BUILD Phase

| Skill | Rust Adaptation |
|--|--|
| **plan** | Each task specifies crates, modules, and traits. File paths follow Rust conventions (`src/service/user.rs`). Tasks note which traits they implement or require. Tasks identify where `unsafe` blocks are needed and why. |
| **build** | TDD with `cargo test`. RED step writes `#[cfg(test)]` module or integration test. GREEN step implements the function. REFACTOR step reduces clones, introduces zero-copy patterns, tightens type constraints. |
| **test** | Use `#[test]` functions, `assert_eq!`/`assert!` macros, and `#[should_panic]` for error cases. Use `proptest` or `quickcheck` for property-based testing. Integration tests go in `tests/`. |
| **review** | Check for unnecessary `.clone()`, missing error propagation (`?`), `unwrap()` in non-test code, `unsafe` without safety comments, and unused `Result` values. |

### OPTIMIZE Phase

| Skill | Rust Adaptation |
|--|--|
| **optimize** | Target execution time, binary size, or memory usage. Guard rail: `cargo test` and `cargo clippy` must pass. Use `cargo bench` with Criterion for precise measurement. |
| **debug** | Use `rust-gdb` or `rust-lldb` for debugging. Check borrow checker errors carefully — they often reveal design issues, not just syntax issues. |
| **fix** | Autonomous fix loop handles test failures, clippy warnings, and compilation errors. Guard rail: `cargo test && cargo clippy -- -D warnings` |
| **secure** | Audit dependencies with `cargo audit`. Check for `unsafe` blocks, `transmute`, raw pointer dereference, and unchecked indexing. Review `tokio::spawn` for `Send` safety. |

### SHIP Phase

| Skill | Rust Adaptation |
|--|--|
| **ship** | Pre-flight: `cargo test && cargo clippy -- -D warnings && cargo fmt --check && cargo build --release`. Verify the release binary runs and produces expected output. |
| **finish** | Ensure `Cargo.toml` version is bumped. Verify `cargo doc` generates clean documentation. For libraries, verify `cargo publish --dry-run` succeeds. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--|--|--|
| Test pass rate | `cargo test 2>&1 \| grep 'test result' \| head -1` | 0 failures |
| Clippy warnings | `cargo clippy -- -D warnings 2>&1; echo $?` | exit code 0 |
| Compile time (debug) | `/usr/bin/time cargo build 2>&1 \| grep real` | Project-specific |
| Compile time (release) | `/usr/bin/time cargo build --release 2>&1 \| grep real` | Project-specific |
| Binary size | `cargo build --release && du -b target/release/mytool \| cut -f1` | Project-specific |
| Benchmark (ns/iter) | `cargo bench \| grep 'ns/iter' \| awk '{print $5}'` | Decreasing |
| Unsafe blocks | `grep -rn 'unsafe' src/ \| grep -v '// SAFETY:' \| wc -l` | 0 undocumented |
| Dependencies | `cargo tree --depth 1 \| wc -l` | Minimize |
| `unwrap()` count | `grep -rn '\.unwrap()' src/ --include='*.rs' \| grep -v '#\[cfg(test)\]' \| wc -l` | 0 in non-test code |

---

## Common Verify Commands

### Tests pass
```bash
cargo test
```

### Tests pass (specific module)
```bash
cargo test --lib service::user
```

### Clippy clean
```bash
cargo clippy -- -D warnings
```

### Format check
```bash
cargo fmt --check
```

### Build succeeds (release)
```bash
cargo build --release
```

### Benchmark
```bash
cargo bench
```

### Dependency audit
```bash
cargo audit
```

### Documentation builds
```bash
cargo doc --no-deps
```

---

## Tool Integration

### cargo test

Godmode's TDD cycle maps directly to `cargo test`:

```bash
# RED step: run single test, expect failure
cargo test test_create_user -- --nocapture

# GREEN step: run single test, expect pass
cargo test test_create_user -- --nocapture

# After GREEN: run full suite to catch regressions
cargo test

# Integration tests only
cargo test --test integration

# With output visible
cargo test -- --nocapture
```

**Rust test patterns** for Godmode TDD:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn create_user_with_valid_input() {
        let svc = UserService::new(MockRepo::new());
        let user = svc.create("Alice", "alice@example.com").unwrap();
        assert_eq!(user.name, "Alice");
        assert_eq!(user.email, "alice@example.com");
    }

    #[test]
    fn create_user_rejects_empty_name() {
        let svc = UserService::new(MockRepo::new());
        let result = svc.create("", "alice@example.com");
        assert!(result.is_err());
        assert!(matches!(result, Err(AppError::Validation(_))));
    }

    #[test]
    fn create_user_rejects_invalid_email() {
        let svc = UserService::new(MockRepo::new());
        let result = svc.create("Alice", "not-an-email");
        assert!(result.is_err());
    }
}
```

### cargo clippy

Clippy is the definitive Rust linter. Use as a guard rail with deny warnings:

```bash
# Full clippy check (guard rail) — treats warnings as errors
cargo clippy -- -D warnings

# With additional lint groups
cargo clippy -- -D warnings -W clippy::pedantic -A clippy::module_name_repetitions

# Fix auto-fixable issues during refactor step
cargo clippy --fix --allow-dirty
```

**Recommended `clippy.toml`** for Godmode projects:
```toml
# Enforce in CI/guard rails
msrv = "1.75.0"
cognitive-complexity-threshold = 25
too-many-arguments-threshold = 6
```

Add to `Cargo.toml` or `lib.rs` for project-wide lint configuration:
```rust
#![warn(clippy::pedantic)]
#![warn(clippy::nursery)]
#![deny(clippy::unwrap_used)]
#![deny(unsafe_code)]
```

### cargo bench (Criterion)

Rust benchmarking integrates naturally with the optimize loop:

```toml
# Cargo.toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "benchmarks"
harness = false
```

```rust
// benches/benchmarks.rs
use criterion::{criterion_group, criterion_main, Criterion};

fn bench_shorten_url(c: &mut Criterion) {
    let svc = UrlService::new();
    c.bench_function("shorten_url", |b| {
        b.iter(|| svc.shorten("https://example.com/very/long/path"))
    });
}

criterion_group!(benches, bench_shorten_url);
criterion_main!(benches);
```

```bash
# Use as verify command in optimize loop
cargo bench -- --output-format bencher | grep 'ns/iter' | awk '{print $5}'

# Generate HTML reports for detailed analysis
cargo bench
# Reports at target/criterion/*/report/index.html
```

### cargo audit

Dependency vulnerability scanning:

```bash
# Install (once)
cargo install cargo-audit

# Run as part of secure skill
cargo audit

# JSON output for parsing
cargo audit --json
```

---

## Example: Full Workflow for Building a Rust CLI Tool

### Scenario
Build a CLI tool that validates and formats JSON/YAML configuration files, with schema validation, pretty-printing, and conversion between formats.

### Step 1: Think (Design)
```
/godmode:think I need a CLI tool in Rust that validates and formats
configuration files. Supports JSON and YAML. Features: validate against
JSON Schema, pretty-print, convert between formats, check for common
misconfigurations. Use clap for CLI, serde for serialization.
```

Godmode produces a spec at `docs/specs/config-tool.md` containing:
- Trait definitions: `ConfigParser`, `ConfigValidator`, `ConfigFormatter`
- Enum definitions: `Format { Json, Yaml }`, `ValidationError`, `AppError`
- CLI design: `cfgtool validate <file>`, `cfgtool fmt <file>`, `cfgtool convert <file> --to <format>`
- Error handling: `thiserror` for domain errors, `anyhow` for CLI-level error propagation
- Zero-copy design: parse into borrowed `serde_json::Value` where possible

### Step 2: Plan (Decompose)
```
/godmode:plan
```

Produces `docs/plans/config-tool-plan.md` with tasks:
1. Define domain types and error enums (`src/types.rs`)
2. Implement JSON parser with serde (`src/parser/json.rs`)
3. Implement YAML parser with serde (`src/parser/yaml.rs`)
4. Implement JSON Schema validator (`src/validator/schema.rs`)
5. Implement format converter (`src/converter.rs`)
6. Implement pretty-printer with configurable indentation (`src/formatter.rs`)
7. Build CLI with clap derive macros (`src/cli.rs`, `src/main.rs`)
8. Add integration tests with fixture files (`tests/`)

### Step 3: Build (TDD)
```
/godmode:build
```

Each task follows RED-GREEN-REFACTOR:

**Task 2 — RED:**
```rust
// src/parser/json.rs
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_valid_json() {
        let input = r#"{"name": "test", "version": 1}"#;
        let result = JsonParser::parse(input);
        assert!(result.is_ok());
    }

    #[test]
    fn parse_invalid_json_returns_error() {
        let input = r#"{"name": "test",}"#; // trailing comma
        let result = JsonParser::parse(input);
        assert!(result.is_err());
        assert!(matches!(result, Err(ParseError::InvalidSyntax { .. })));
    }

    #[test]
    fn parse_preserves_structure() {
        let input = r#"{"nested": {"key": "value"}}"#;
        let config = JsonParser::parse(input).unwrap();
        assert_eq!(config.get("nested.key"), Some(&Value::String("value".into())));
    }
}
```
Commit: `test(red): JSON parser — failing parse and validation tests`

**Task 2 — GREEN:**
```rust
// src/parser/json.rs
use crate::types::{Config, ParseError};

pub struct JsonParser;

impl JsonParser {
    pub fn parse(input: &str) -> Result<Config, ParseError> {
        let value: serde_json::Value = serde_json::from_str(input)
            .map_err(|e| ParseError::InvalidSyntax {
                format: "json",
                line: e.line(),
                column: e.column(),
                message: e.to_string(),
            })?;
        Ok(Config::from_json_value(value))
    }
}
```
Commit: `feat: JSON parser — serde-based parsing with typed errors`

**Task 2 — REFACTOR:** Add `#[inline]` hints, use `Cow<str>` for zero-copy where possible.
Commit: `refactor: JSON parser — zero-copy string handling with Cow`

Parallel agents handle tasks 2, 3, and 4 concurrently (independent parsers implementing the same trait).

### Step 4: Optimize
```
/godmode:optimize --goal "reduce parse time" \
  --verify "cargo bench -- bench_parse_large_json --output-format bencher 2>&1 | grep 'ns/iter' | awk '{print \$5}'" \
  --target "< 50000"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|--|--|--|--|--|--|
| 1 | String allocation during parse | Use `serde_json::from_str` with borrowed data | 185000 ns | 92000 ns | KEEP |
| 2 | Unnecessary cloning in nested access | Use references with lifetime annotations | 92000 ns | 71000 ns | KEEP |
| 3 | Default allocator is slow for many small allocs | Switch to `mimalloc` global allocator | 71000 ns | 58000 ns | KEEP |
| 4 | serde_json slower than simd-json for large files | Use `simd-json` crate | 58000 ns | 41000 ns | KEEP |
| 5 | Validator re-compiles schema each call | Cache compiled schema with `OnceCell` | 41000 ns | 39000 ns | KEEP |

Final: 185000 ns/iter to 39000 ns/iter (78.9% improvement). Target met.

### Step 5: Secure
```
/godmode:secure
```

Findings:
- MEDIUM: `simd-json` uses `unsafe` internally — verify it is well-audited (it is, widely used)
- MEDIUM: File path argument not sanitized — could read arbitrary files (add path validation)
- LOW: No maximum file size limit — could cause OOM with huge files (add `--max-size` flag)
- INFO: Consider adding `#![deny(unsafe_code)]` to prevent accidental unsafe usage in application code

### Step 6: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
cargo test                    ✓ 31/31 passing
cargo clippy -- -D warnings   ✓ 0 warnings
cargo fmt --check             ✓ formatted
cargo build --release         ✓ binary: 2.1MB
cargo audit                   ✓ 0 vulnerabilities
cargo doc --no-deps           ✓ docs generated
```

PR created with full description, benchmark results (ns/iter and allocs/op), and security audit summary.

---

## Rust-Specific Tips

### 1. Traits are your spec
In the THINK phase, define traits before structs. Traits are Rust's primary abstraction mechanism. A well-designed trait makes testing trivial (implement the trait for a mock struct) and enables the optimize loop to swap implementations.

### 2. Let the borrow checker guide your design
Borrow checker errors during the BUILD phase are not obstacles — they are design feedback. If the borrow checker rejects your code, reconsider ownership. Often the correct fix is a better data structure, not more `clone()` calls.

### 3. Use `cargo clippy` as a guard rail, not a suggestion
Run `cargo clippy -- -D warnings` (deny warnings) on every optimization iteration. Clippy catches performance anti-patterns (unnecessary allocations, redundant clones) that the optimize loop would otherwise have to discover manually.

### 4. Benchmark with Criterion, not ad-hoc timing
Criterion provides statistical analysis (confidence intervals, regression detection) that makes the optimize loop's measurements reliable. A single `std::time::Instant` measurement is noisy. Criterion runs hundreds of iterations and gives you the median with error bounds.

### 5. Track `unsafe` as a metric
Every `unsafe` block should have a `// SAFETY:` comment explaining why it is sound. Track undocumented `unsafe` blocks as a metric to reduce:
```
/godmode:optimize --goal "document all unsafe blocks" --verify "grep -rn 'unsafe' src/ | grep -v 'SAFETY:' | wc -l" --target "0"
```

### 6. Compile time is a metric
Rust's compile times are a real cost. Track them and use the optimize loop to reduce them when they become painful:
```
/godmode:optimize --goal "reduce compile time" --verify "/usr/bin/time cargo build --release 2>&1 | grep real | awk '{print \$2}'" --target "< 30"
```
Consider strategies like reducing monomorphization, splitting crates, and using `cargo check` for development.
