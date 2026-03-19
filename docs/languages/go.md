# Go Developer Guide

How to use Godmode's full workflow for Go projects — from design to production.

---

## Setup

```bash
/godmode:setup
# Godmode auto-detects Go via go.mod
# Test: go test ./...
# Lint: golangci-lint run
# Vet: go vet ./...
# Build: go build ./...
```

### Example `.godmode/config.yaml`
```yaml
language: go
framework: stdlib           # or gin, echo, fiber, chi, etc.
test_command: go test ./... -count=1
lint_command: golangci-lint run
vet_command: go vet ./...
build_command: go build -o bin/server ./cmd/server
verify_command: curl -s -o /dev/null -w '%{time_total}' http://localhost:8080/health
```

---

## How Each Skill Applies to Go

### THINK Phase

| Skill | Go Adaptation |
|-------|---------------|
| **think** | Design interfaces and structs first. A Go spec defines the contract (interfaces) and data shapes (structs). Emphasize small interfaces ("Accept interfaces, return structs"). |
| **predict** | Expert panel evaluates concurrency design, error handling strategy, and deployment model. Request panelists with Go depth (e.g., standard library contributor, distributed systems engineer). |
| **scenario** | Explore edge cases around goroutine leaks, channel deadlocks, race conditions, context cancellation, and nil pointer dereferences. |

### BUILD Phase

| Skill | Go Adaptation |
|-------|---------------|
| **plan** | Each task specifies packages and interfaces. File paths follow Go conventions (`internal/service/user.go`). Tasks note which interfaces they implement or consume. |
| **build** | TDD with `go test`. RED step writes a `_test.go` file with table-driven tests. GREEN step implements the function. REFACTOR step extracts interfaces, simplifies error handling. |
| **test** | Use table-driven tests, `testing.T`, and subtests (`t.Run`). Mock with interfaces (no framework required). Use `testify/assert` for readability or stay with stdlib. |
| **review** | Check for goroutine leaks, unchecked errors, context propagation, proper `defer` usage, and idiomatic Go patterns. |

### OPTIMIZE Phase

| Skill | Go Adaptation |
|-------|---------------|
| **optimize** | Target response time, memory allocations, or throughput. Guard rail: `go test ./... -race` must pass. Use `go tool pprof` for profiling-guided optimization. |
| **debug** | Use `dlv` (Delve) for debugging. Check for race conditions with `-race`. Analyze goroutine dumps with `SIGQUIT`. |
| **fix** | Autonomous fix loop handles test failures, vet errors, and lint violations. Guard rail: `go test ./... && go vet ./... && golangci-lint run` |
| **secure** | Audit dependencies with `govulncheck`. Check for SQL injection, command injection, path traversal, and insecure TLS configuration. |

### SHIP Phase

| Skill | Go Adaptation |
|-------|---------------|
| **ship** | Pre-flight: `go test ./... -race && go vet ./... && golangci-lint run && go build ./...`. Verify the binary runs and serves health checks. |
| **finish** | Ensure the binary is statically compiled for deployment. Verify Docker multi-stage build produces a minimal image. |

---

## Recommended Metrics

| Metric | Verify Command | Target |
|--------|---------------|--------|
| Test coverage | `go test ./... -coverprofile=cover.out && go tool cover -func=cover.out \| grep total \| awk '{print $3}'` | >= 80% |
| Vet errors | `go vet ./... 2>&1 \| grep -c 'vet:'` | 0 |
| Benchmark (ns/op) | `go test -bench=BenchmarkHandler -benchmem ./internal/handler \| grep 'ns/op' \| awk '{print $3}'` | Project-specific |
| Allocations (allocs/op) | `go test -bench=BenchmarkHandler -benchmem ./internal/handler \| grep 'allocs/op' \| awk '{print $7}'` | Decreasing |
| Binary size | `go build -o bin/server ./cmd/server && du -b bin/server \| cut -f1` | Project-specific |
| Lint violations | `golangci-lint run 2>&1 \| grep -c 'issues'` | 0 |
| Race conditions | `go test ./... -race 2>&1; echo $?` | exit code 0 |
| Build time | `/usr/bin/time go build ./... 2>&1 \| grep real` | Project-specific |

---

## Common Verify Commands

### Tests pass
```bash
go test ./... -count=1
```

### Tests pass with race detection
```bash
go test ./... -race -count=1
```

### Vet clean
```bash
go vet ./...
```

### Lint clean
```bash
golangci-lint run
```

### Build succeeds
```bash
go build ./...
```

### Benchmark
```bash
go test -bench=. -benchmem ./...
```

### Coverage report
```bash
go test ./... -coverprofile=cover.out && go tool cover -func=cover.out
```

### Vulnerability check
```bash
govulncheck ./...
```

---

## Tool Integration

### go test

Godmode's TDD cycle maps directly to `go test`:

```bash
# RED step: run single test file, expect failure
go test -run TestCreateUser ./internal/service -v

# GREEN step: run single test, expect pass
go test -run TestCreateUser ./internal/service -v

# After GREEN: run full suite to catch regressions
go test ./... -count=1

# With race detector (always use in CI)
go test ./... -race -count=1

# Benchmarks
go test -bench=BenchmarkCreateUser -benchmem ./internal/service
```

**Table-driven tests** — the Go standard for Godmode TDD:
```go
func TestCreateUser(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserRequest
        wantErr bool
    }{
        {
            name:    "valid user",
            input:   CreateUserRequest{Name: "Alice", Email: "alice@example.com"},
            wantErr: false,
        },
        {
            name:    "missing email",
            input:   CreateUserRequest{Name: "Alice"},
            wantErr: true,
        },
        {
            name:    "empty name",
            input:   CreateUserRequest{Email: "alice@example.com"},
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            svc := NewUserService(mockRepo{})
            _, err := svc.Create(context.Background(), tt.input)
            if (err != nil) != tt.wantErr {
                t.Errorf("Create() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

### golangci-lint

The standard Go linter aggregator. Use as a guard rail:

```bash
# Full lint check (guard rail)
golangci-lint run

# With specific linters enabled
golangci-lint run --enable gocritic,gosec,prealloc,bodyclose
```

Recommended `.golangci.yml` for Godmode projects:
```yaml
linters:
  enable:
    - govet
    - errcheck
    - staticcheck
    - gosimple
    - unused
    - gocritic
    - gosec
    - prealloc
    - bodyclose
    - contextcheck
    - nilerr

linters-settings:
  errcheck:
    check-type-assertions: true
  gocritic:
    enabled-tags:
      - diagnostic
      - performance
```

### go vet

Built-in static analysis. Always include as a guard rail:

```yaml
guard_rails:
  - command: go vet ./...
    expect: exit code 0
  - command: go test ./... -race -count=1
    expect: exit code 0
  - command: golangci-lint run
    expect: exit code 0
```

### Benchmarks and pprof

Go's built-in benchmarking integrates naturally with the optimize loop:

```bash
# Run benchmarks as the verify command
go test -bench=BenchmarkHandler -benchmem -count=3 ./internal/handler | grep 'ns/op' | awk '{print $3}'

# Profile CPU during optimization
go test -bench=BenchmarkHandler -cpuprofile=cpu.prof ./internal/handler
go tool pprof -http=:8081 cpu.prof

# Profile memory allocations
go test -bench=BenchmarkHandler -memprofile=mem.prof ./internal/handler
go tool pprof -http=:8081 mem.prof
```

---

## Example: Full Workflow for Building a Go Microservice

### Scenario
Build a URL shortener microservice with Go standard library HTTP server, Redis for storage, and Prometheus metrics.

### Step 1: Think (Design)
```
/godmode:think I need a URL shortener microservice in Go.
Requirements: shorten URLs, redirect on access, track click counts,
expose Prometheus metrics. Use stdlib net/http, Redis for storage.
```

Godmode produces a spec at `docs/specs/url-shortener.md` containing:
- Interface definitions: `URLStore`, `IDGenerator`, `MetricsCollector`
- Struct definitions: `URL`, `ShortenRequest`, `ShortenResponse`, `URLStats`
- Endpoint design: `POST /shorten`, `GET /{id}` (redirect), `GET /{id}/stats`, `GET /metrics`
- Error handling: sentinel errors (`ErrNotFound`, `ErrInvalidURL`) with proper HTTP status mapping
- Concurrency design: stateless handlers, Redis for shared state, no in-process cache initially

### Step 2: Plan (Decompose)
```
/godmode:plan
```

Produces `docs/plans/url-shortener-plan.md` with tasks:
1. Define domain types and interfaces (`internal/domain/url.go`)
2. Implement ID generator with base62 encoding (`internal/shortid/generator.go`)
3. Implement Redis URL store (`internal/store/redis.go`)
4. Implement shorten handler (`internal/handler/shorten.go`)
5. Implement redirect handler (`internal/handler/redirect.go`)
6. Implement stats handler (`internal/handler/stats.go`)
7. Add Prometheus metrics middleware (`internal/middleware/metrics.go`)
8. Wire HTTP server and routes (`cmd/server/main.go`)
9. Integration tests with testcontainers-go

### Step 3: Build (TDD)
```
/godmode:build
```

Each task follows RED-GREEN-REFACTOR:

**Task 2 — RED:**
```go
// internal/shortid/generator_test.go
package shortid

import "testing"

func TestGenerate(t *testing.T) {
    gen := NewGenerator()

    t.Run("returns non-empty string", func(t *testing.T) {
        id := gen.Generate()
        if id == "" {
            t.Error("expected non-empty ID")
        }
    })

    t.Run("returns unique IDs", func(t *testing.T) {
        seen := make(map[string]bool)
        for i := 0; i < 10000; i++ {
            id := gen.Generate()
            if seen[id] {
                t.Errorf("duplicate ID generated: %s", id)
            }
            seen[id] = true
        }
    })

    t.Run("uses only base62 characters", func(t *testing.T) {
        id := gen.Generate()
        for _, c := range id {
            if !isBase62(c) {
                t.Errorf("non-base62 character in ID: %c", c)
            }
        }
    })
}
```
Commit: `test(red): ID generator — failing base62 generation tests`

**Task 2 — GREEN:**
```go
// internal/shortid/generator.go
package shortid

import (
    "crypto/rand"
    "math/big"
)

const alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

type Generator struct{}

func NewGenerator() *Generator {
    return &Generator{}
}

func (g *Generator) Generate() string {
    b := make([]byte, 7)
    for i := range b {
        n, _ := rand.Int(rand.Reader, big.NewInt(int64(len(alphabet))))
        b[i] = alphabet[n.Int64()]
    }
    return string(b)
}
```
Commit: `feat: ID generator — base62 random short ID generation`

Parallel agents handle tasks 4, 5, and 6 concurrently (independent handlers implementing the same interface).

### Step 4: Optimize
```
/godmode:optimize --goal "maximize requests per second" \
  --verify "go test -bench=BenchmarkShortenHandler -benchmem ./internal/handler | grep 'ns/op' | awk '{print \$3}'" \
  --target "< 5000"
```

Iteration log:
| # | Hypothesis | Change | Baseline | Measured | Verdict |
|---|-----------|--------|----------|----------|---------|
| 1 | JSON encoding creates allocations | Use `json.NewEncoder` with pooled buffers | 12400 ns/op | 7800 ns/op | KEEP |
| 2 | ID generation uses `crypto/rand` per character | Batch random bytes | 7800 ns/op | 5200 ns/op | KEEP |
| 3 | Redis round-trip per request | Add in-memory LRU cache | 5200 ns/op | 3100 ns/op | KEEP |
| 4 | HTTP handler allocates per request | Use `sync.Pool` for request/response structs | 3100 ns/op | 2800 ns/op | KEEP |
| 5 | String concatenation in URL builder | Use `strings.Builder` | 2800 ns/op | 2750 ns/op | REVERT |

Final: 12400 ns/op to 2800 ns/op (77.4% improvement). Target met.

### Step 5: Secure
```
/godmode:secure
```

Findings:
- HIGH: No rate limiting on `POST /shorten` — add token bucket middleware
- MEDIUM: Redis connection has no TLS — enable TLS for production
- MEDIUM: No URL validation (allows `javascript:` and `data:` schemes) — whitelist `http`/`https`
- LOW: Prometheus endpoint exposed without authentication

### Step 6: Ship
```
/godmode:ship --pr
```

Pre-flight passes:
```
go test ./... -race       ✓ 28/28 passing
go vet ./...              ✓ clean
golangci-lint run         ✓ 0 issues
govulncheck ./...         ✓ 0 vulnerabilities
go build ./cmd/server     ✓ binary: 8.2MB
coverage                  ✓ 84.3% (target: 80%)
```

PR created with full description, optimization log (with ns/op and allocs/op), and security audit summary.

---

## Go-Specific Tips

### 1. Interfaces are your spec
In the THINK phase, define small interfaces before anything else. Go interfaces are implicit — the consumer defines them. A well-designed interface makes testing trivial (mock by implementing the interface).

### 2. Table-driven tests are your TDD format
Every RED step should produce a table-driven test. This pattern naturally covers multiple cases and is idiomatic Go. Godmode's test skill generates table-driven tests by default for Go projects.

### 3. Always test with `-race`
Include `-race` in your guard rails. Race conditions are the most insidious bugs in Go. The race detector catches them at test time before they cause production incidents.

### 4. Benchmark before optimizing
Go's built-in benchmarking (`go test -bench`) is the ideal verify command for the optimize loop. Always include `-benchmem` to track allocations alongside time.

### 5. Use `go vet` and `golangci-lint` as guard rails
Both are fast enough to run on every iteration. `go vet` catches subtle bugs (printf format mismatches, unreachable code). `golangci-lint` aggregates dozens of linters into a single fast command.

### 6. Keep binaries small
Track binary size as a metric if deploying to containers. Use `-ldflags="-s -w"` to strip debug info. The optimize loop can target binary size reduction:
```
/godmode:optimize --goal "reduce binary size" --verify "go build -o bin/server ./cmd/server && du -b bin/server | cut -f1" --target "< 5000000"
```
