---
name: grpc
description: |
  gRPC and Protocol Buffers development skill. Activates when user needs to design, build, or optimize gRPC services. Covers proto file design and best practices, service definition and code generation, streaming patterns (unary, server, client, bidirectional), gRPC-web for browser clients, load balancing, and service mesh integration. Produces production-ready proto files, generated code, and deployment configurations. Triggers on: /godmode:grpc, "build a gRPC service", "design proto file", "add streaming RPC", "set up gRPC-web", or when the orchestrator detects gRPC-related work.
---

# gRPC — Protocol Buffers & Service Development

## When to Activate
- User invokes `/godmode:grpc`
- User says "build a gRPC service", "design proto file", "define gRPC API"
- User says "add streaming", "bidirectional stream", "server-side streaming"
- User says "set up gRPC-web", "gRPC in the browser"
- When `/godmode:plan` identifies gRPC or inter-service communication tasks

## Workflow

### Step 1: Discovery & Context
```
GRPC DISCOVERY:
Project: <name>, Language: <Go|Rust|Java|C++|Python|TypeScript|C#>
Framework: <tonic|grpc-go|grpc-java|grpc-node|grpcio>
Proto version: proto3 (default)
Consumers: <internal services, mobile, browser via gRPC-web>
Communication: unary | server-streaming | client-streaming | bidi-streaming
Service mesh: <Istio|Linkerd|Consul Connect|none>
Auth: <mTLS|JWT|API key|none>
```

If unspecified, ask: "What language for the server? What patterns (unary, streaming)?"

### Step 2: Proto File Design
Use proto3. Package: `<company>.<domain>.v1`. Set `go_package`, `java_package`.

Service structure:
```protobuf
service <Entity>Service {
  rpc Get<Entity>(Get<Entity>Request) returns (<Entity>) {}
  rpc List<Entities>(List<Entities>Request) returns (List<Entities>Response) {}
  rpc Create<Entity>(Create<Entity>Request) returns (<Entity>) {}
  rpc Update<Entity>(Update<Entity>Request) returns (<Entity>) {}
  rpc Delete<Entity>(Delete<Entity>Request) returns (google.protobuf.Empty) {}
  rpc Watch<Entities>(Watch<Entities>Request) returns (stream <Entity>Event) {}
}
```

Message patterns: Entity with id, name, status, timestamps, metadata. Request/Response per RPC (never shared). Use FieldMask for partial updates. Idempotency key on create/update. Validation rules via buf validate.

### Step 3: Proto Design Rules

```
1. proto3 syntax always              7. Idempotency key on create/update
2. Package = company.domain.version  8. google.protobuf.Timestamp for time
3. Enum zero = UNSPECIFIED           9. Repeated fields for collections
4. Field numbers are permanent       10. Reserve removed field numbers/names
5. FieldMask for partial updates     11. Keep messages < 100 fields
6. Request/Response per RPC          12. wrappers.proto for nullable scalars

FILE ORGANIZATION:
protos/<company>/<domain>/v1/<service>.proto, resources.proto, enums.proto, events.proto

BREAKING CHANGE DETECTION:
  $ buf breaking --against '.git#branch=main'
  Breaking: removing fields, changing types, renaming services/RPCs, removing enum values
```

### Step 4: Code Generation Pipeline
Use buf (not raw protoc) for linting, breaking change detection, generation.

```
buf.yaml: version v2, modules path protos, lint STANDARD, breaking FILE
buf.gen.yaml: plugins for Go, TypeScript, validation, gRPC-Gateway

RULES:
1. Generated code NEVER committed — regenerate in CI
2. Pin plugin versions
3. Run buf lint before generation
4. Run buf breaking before merge
5. Generate for ALL consumer languages in one pass
6. Include validation code generation
```

### Step 5: Streaming Patterns

```
1. UNARY: One request, one response. Use for CRUD.
2. SERVER STREAMING: One request, stream of responses. Use for feeds, watches, large datasets.
3. CLIENT STREAMING: Stream of requests, one response. Use for batch uploads, aggregation.
4. BIDIRECTIONAL: Independent streams both directions. Use for chat, collaboration, sync.

BEST PRACTICES:
- Set deadlines on all RPCs (prevent hung connections)
- Implement keepalive pings (detect dead connections)
- Handle stream errors as normal flow
- Use flow control / backpressure (prevent OOM)
- Send heartbeats on long-lived streams (keep proxies/LBs alive)
- Implement reconnection with resume token
```

### Step 6: gRPC-Web for Browsers

```
OPTIONS: Envoy Proxy (production, no code changes) | Buf Connect (no proxy, full streaming, recommended for new) | grpc-web npm (simple, limited streaming)
LIMITATIONS: No client or bidi streaming in browsers (HTTP/1.1). Server streaming via chunked transfer. CORS required.
```

### Step 7: Load Balancing & Service Mesh

```
CHALLENGE: gRPC uses HTTP/2 with long-lived connections. L4 LBs see one connection → all RPCs to one backend.
SOLUTION: L7 load balancing that distributes individual RPCs.

STRATEGIES:
1. Proxy-based L7 (recommended): Envoy/Nginx/Traefik
2. Client-side (look-aside): built into grpc-go, grpc-java
3. xDS-based (service mesh): Istio, Linkerd, Consul

SERVICE MESH: Enable HTTP/2 detection, per-RPC LB, retry policies, circuit breaking, distributed tracing, mTLS.
HEALTH CHECK: Implement grpc.health.v1.Health on every server.
```

### Step 8: Error Handling & Observability

```
STATUS CODES (use correctly):
  OK, CANCELLED, INVALID_ARGUMENT, NOT_FOUND, ALREADY_EXISTS,
  PERMISSION_DENIED, UNAUTHENTICATED, RESOURCE_EXHAUSTED,
  FAILED_PRECONDITION, ABORTED, UNIMPLEMENTED, INTERNAL,
  UNAVAILABLE, DEADLINE_EXCEEDED, DATA_LOSS

INTERCEPTOR CHAIN (in order):
  Recovery → Logging → Metrics → Tracing → Auth → Validation

METRICS: grpc_server_handled_total{method,code}, grpc_server_handling_seconds{method}, msg_received/sent_total
TRACING: Propagate context via metadata, span per RPC, attributes: rpc.method/service/status_code
```

### Step 9: Testing

```
LAYERS: Proto validation (buf lint/breaking), Unit (mocked deps), Integration (grpcurl/Evans),
  Streaming edge cases, Load (ghz), Contract (buf breaking), E2E

STREAMING TESTS: 0 messages, 1 message, many (verify order), cancel mid-stream,
  error mid-stream, connection drop. Bidi: concurrent send/receive, deadlock detection.
```

### Step 10: Artifacts & Completion
```
GRPC COMPLETE:
Services: <N>, RPCs: <N> unary/<M> streaming, Messages: <N> types/<M> enums
Proto validation: buf lint PASS, buf breaking PASS
Health check: implemented, TLS: <mTLS|server-only|plaintext>
```
Commit: `"grpc: <service> — <N> RPCs, streaming + health checks configured"`

## Key Behaviors

1. **Proto files are the contract.** Design proto first — it IS the API spec, docs, and codegen source.
2. **Use buf, not raw protoc.** Linting, breaking change detection, better generation pipeline.
3. **Every enum starts with UNSPECIFIED = 0.** Detects unset fields.
4. **Field numbers are permanent.** Never reuse. Reserve removed numbers/names.
5. **Request/Response per RPC.** Never share across RPCs.
6. **Streaming is an architecture choice.** Unary is simpler to debug, test, retry, load balance.
7. **L7 load balancing is mandatory.** L4 sees one HTTP/2 connection.
8. **Health checks are not optional.** Every server implements grpc.health.v1.Health.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full gRPC design workflow |
| `--proto` | Proto files only |
| `--generate` | Code generation from existing protos |
| `--streaming` | Streaming pattern design |
| `--web` | gRPC-Web or Connect setup |
| `--mesh` | Service mesh integration |
| `--validate` | Lint and validate protos |
| `--breaking` | Check breaking changes |
| `--test` | Generate test suite |

## Auto-Detection
```
Scan: .proto files, language (go.mod/Cargo.toml/package.json for grpc deps), buf config,
protoc in Makefile, gen/ directory, streaming in service definitions, health check impl,
load balancing config, observability interceptors, gRPC-Web/Connect.
```

## HARD RULES

1. ALWAYS use proto3 syntax for new services.
2. EVERY enum MUST start with UNSPECIFIED = 0.
3. NEVER reuse field numbers. Reserve removed numbers and names.
4. NEVER share request/response messages across RPCs.
5. ALWAYS use buf (not raw protoc).
6. NEVER commit generated code. Generate in CI.
7. ALWAYS use L7 load balancing for gRPC.
8. ALWAYS implement grpc.health.v1.Health on every server.
9. ALWAYS set deadlines on all RPCs.
10. ALWAYS use correct status codes (NOT_FOUND, INVALID_ARGUMENT give actionable info; INTERNAL does not).

## Loop Protocol
```
FOR EACH service (dependency order):
  1. Design proto, 2. buf lint + breaking, 3. Generate + implement handlers,
  4. Add interceptors + health check, 5. Write tests
POST-LOOP: buf lint + breaking on full tree, verify all health checks.
```

## Multi-Agent Dispatch
```
Agent 1 — grpc-protos: proto design, buf config, shared types, lint+breaking
Agent 2 — grpc-server: handlers, interceptors, health check, L7 LB
Agent 3 — grpc-client: client stubs, interceptors, gRPC-Web/Connect, integration tests
MERGE: Proto first, then server+client. Final: integration tests.
```

## Output Format
```
GRPC SERVICE COMPLETE:
Services: <N>, RPCs: <M> total (unary/server-stream/client-stream/bidi)
Proto: buf lint PASS, Health: implemented, LB: <strategy>, TLS: <type>
```

## TSV Logging
Append to `.godmode/grpc-results.tsv`: `timestamp\tproject\tservices_count\trpcs_count\tstreaming_rpcs\tbuf_lint_status\tbreaking_changes\tcommit_sha`

## Success Criteria
Proto compiles, buf lint 0 errors, buf breaking 0 regressions, health check implemented,
reflection enabled (dev/staging), deadlines on all RPCs, correct status codes,
interceptors for logging+metrics, TLS for production.

## Error Recovery
```
Proto compile fails → fix syntax, imports, types. buf lint → fix naming, structure.
Breaking change → add new fields, reserve old. Streaming hangs → check deadlines, keepalive.
UNAVAILABLE → verify address, TLS, health check. Stale stubs → re-run buf generate.
```

## Keep/Discard Discipline
```
KEEP if buf lint PASS AND buf breaking PASS AND health check present.
DISCARD if any lint error, breaking change, or missing health check.
Never keep wire-incompatible breaks. Never skip buf breaking before merge.
```

## Stop Conditions
```
Loop until target or budget. Never ask to continue — loop autonomously.
Measure before/after. Guard: test_cmd && lint_cmd.
On failure: git reset --hard HEAD~1.

STOP when: buf lint 0 errors AND buf breaking 0 regressions AND health check implemented
  AND all RPCs have deadlines, per-RPC messages, and validation
  OR user requests stop OR max 10 iterations
```

## Platform Fallback
Run sequentially if `Agent()` unavailable. Branch per task. See `adapters/shared/sequential-dispatch.md`.
