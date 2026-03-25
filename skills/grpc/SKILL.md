---
name: grpc
description: |
  gRPC and Protocol Buffers skill. Proto design,
  code generation, streaming patterns, gRPC-web,
  load balancing, service mesh integration.
  Triggers on: /godmode:grpc, "gRPC service",
  "proto file", "streaming RPC", "gRPC-web".
---

# gRPC — Protocol Buffers & Service Development

## When to Activate
- User invokes `/godmode:grpc`
- User says "build a gRPC service", "design proto"
- User says "add streaming", "bidirectional stream"
- User says "set up gRPC-web"
- Plan identifies gRPC or inter-service communication

## Workflow

### Step 1: Discovery & Context

```bash
# Detect existing proto files and tools
find . -name "*.proto" -not -path "*/node_modules/*" \
  2>/dev/null | head -20

# Check for buf configuration
ls buf.yaml buf.gen.yaml 2>/dev/null

# Check gRPC dependencies
grep -r "grpc\|tonic\|grpc-go\|grpcio" \
  go.mod Cargo.toml package.json pyproject.toml \
  2>/dev/null
```

```
GRPC DISCOVERY:
  Language: <Go|Rust|Java|Python|TypeScript>
  Framework: <tonic|grpc-go|grpc-java|grpc-node>
  Proto version: proto3
  Consumers: <internal|mobile|browser via gRPC-web>
  Patterns: <unary|server-stream|client-stream|bidi>

IF no buf.yaml: create one (not raw protoc)
IF no protos: scaffold from API requirements
IF browser clients: add gRPC-web or Connect
```

### Step 2: Proto File Design

```protobuf
service <Entity>Service {
  rpc Get<Entity>(Get<Entity>Request)
    returns (<Entity>) {}
  rpc List<Entities>(List<Entities>Request)
    returns (List<Entities>Response) {}
  rpc Create<Entity>(Create<Entity>Request)
    returns (<Entity>) {}
  rpc Watch<Entities>(Watch<Entities>Request)
    returns (stream <Entity>Event) {}
}
```

```
PROTO RULES:
  1. proto3 syntax always
  2. Package = company.domain.v1
  3. Enum zero value = UNSPECIFIED
  4. Field numbers are permanent — never reuse
  5. FieldMask for partial updates
  6. Request/Response per RPC (never share)
  7. Idempotency key on create/update
  8. google.protobuf.Timestamp for time
  9. Reserve removed field numbers/names
  10. Keep messages < 100 fields

FILE LAYOUT:
  protos/<company>/<domain>/v1/
    <service>.proto, resources.proto,
    enums.proto, events.proto
```

### Step 3: Code Generation Pipeline

```bash
# Lint protos
buf lint

# Check for breaking changes
buf breaking --against '.git#branch=main'

# Generate code
buf generate
```

```
GENERATION RULES:
  Generated code NEVER committed — regen in CI
  Pin plugin versions in buf.gen.yaml
  Run buf lint before generation
  Run buf breaking before merge
  Generate for ALL consumer languages in one pass

THRESHOLDS:
  buf lint errors: must be 0
  buf breaking regressions: must be 0
  IF breaking change needed: add new field,
    reserve old — never modify existing
```

### Step 4: Streaming Patterns

```
| Pattern      | Use Case                     |
|--------------|------------------------------|
| Unary        | CRUD operations              |
| Server stream| Feeds, watches, large data   |
| Client stream| Batch uploads, aggregation   |
| Bidirectional| Chat, collaboration, sync    |

BEST PRACTICES:
  Set deadlines on all RPCs (prevent hung conns)
  Implement keepalive pings (detect dead conns)
  Use flow control / backpressure (prevent OOM)
  Send heartbeats on long-lived streams
  Implement reconnection with resume token

THRESHOLDS:
  Unary deadline: 5s default, 30s max
  Stream keepalive: every 30s
  Backpressure buffer: 1000 messages max
  IF stream idle > 60s without heartbeat: close
```

### Step 5: gRPC-Web for Browsers

```
OPTIONS:
  Envoy Proxy: production, no code changes
  Buf Connect: no proxy, full streaming, recommended
  grpc-web npm: simple, limited streaming

LIMITATIONS:
  No client or bidi streaming in browsers (HTTP/1.1)
  Server streaming via chunked transfer
  CORS required for cross-origin
```

### Step 6: Load Balancing

```
CHALLENGE: HTTP/2 long-lived connections mean L4 LBs
  route all RPCs to one backend.
SOLUTION: L7 load balancing per individual RPC.

STRATEGIES:
  1. Proxy L7 (recommended): Envoy/Nginx/Traefik
  2. Client-side: built into grpc-go, grpc-java
  3. xDS / service mesh: Istio, Linkerd, Consul

HEALTH CHECK:
  Implement grpc.health.v1.Health on every server
  IF no health check: load balancer can't route
```

### Step 7: Error Handling & Observability

```
STATUS CODES (use correctly):
  OK, CANCELLED, INVALID_ARGUMENT, NOT_FOUND,
  ALREADY_EXISTS, PERMISSION_DENIED,
  UNAUTHENTICATED, RESOURCE_EXHAUSTED,
  UNAVAILABLE, DEADLINE_EXCEEDED, INTERNAL

INTERCEPTOR CHAIN (in order):
  Recovery → Logging → Metrics → Tracing → Auth

METRICS:
  grpc_server_handled_total{method,code}
  grpc_server_handling_seconds{method}
```

### Step 8: Testing

```
TEST LAYERS:
  Proto: buf lint + buf breaking
  Unit: mocked dependencies
  Integration: grpcurl / Evans against real server
  Streaming: 0 msgs, 1 msg, many, cancel, error
  Load: ghz benchmark tool
  Contract: buf breaking before merge

STREAMING EDGE CASES:
  Cancel mid-stream, error mid-stream,
  connection drop, concurrent send/receive,
  deadlock detection for bidi streams
```

### Step 9: Completion
```
GRPC COMPLETE:
  Services: <N>, RPCs: <N> unary / <M> streaming
  buf lint: PASS, buf breaking: PASS
  Health check: implemented
  TLS: <mTLS|server-only|plaintext>
```

Commit: `"grpc: <service> — <N> RPCs, streaming
  + health checks configured"`

## Key Behaviors
Never ask to continue. Loop autonomously until done.

1. **Proto files are the contract.** Design first.
2. **Use buf, not raw protoc.**
3. **Every enum starts with UNSPECIFIED = 0.**
4. **Field numbers are permanent.** Never reuse.
5. **Request/Response per RPC.** Never share.
6. **L7 load balancing is mandatory.**
7. **Health checks on every server.**

## HARD RULES
1. Always use proto3 syntax for new services.
2. Every enum MUST start with UNSPECIFIED = 0.
3. Never reuse field numbers. Reserve removed ones.
4. Never share request/response across RPCs.
5. Always use buf (not raw protoc).
6. Never commit generated code. Generate in CI.
7. Always use L7 load balancing for gRPC.
8. Always implement grpc.health.v1.Health.
9. Always set deadlines on all RPCs.
10. Always use correct status codes.

## Auto-Detection
```
1. Proto files: find . -name "*.proto"
2. Language: go.mod, Cargo.toml, package.json
3. Buf config: buf.yaml, buf.gen.yaml
4. Health check: grep grpc.health in source
5. Streaming: grep stream in .proto files
```

## Quality Targets
- Target: <50ms p95 unary RPC latency
- Max message size: <4MB default
- Target: >99.9% RPC success rate
- Connection pool: >=2 channels per backend

## Output Format
```
gRPC: {N} services, {M} RPCs (unary/streaming).
  buf lint: {status}. Health: {status}.
  LB: {strategy}. TLS: {type}.
```

## TSV Logging
```
timestamp	project	services	rpcs	streaming_rpcs	buf_lint	breaking	commit_sha
```

## Keep/Discard Discipline
```
KEEP if: buf lint PASS AND buf breaking PASS
  AND health check present
DISCARD if: lint error OR breaking change
  OR missing health check
```

## Stop Conditions
```
STOP when: buf lint 0 errors AND breaking 0
  AND health check implemented AND all RPCs
  have deadlines and per-RPC messages
  OR user requests stop OR max 10 iterations
```

## Error Recovery
- Proto compile fails: fix syntax, imports, types.
- buf lint errors: fix naming, structure per rules.
- Breaking change: add new fields, reserve old.
- Streaming hangs: check deadlines, keepalive config.
- UNAVAILABLE: verify address, TLS, health check.
- Stale stubs: re-run buf generate.

