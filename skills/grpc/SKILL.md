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
- User says "gRPC load balancing", "service mesh with gRPC"
- When `/godmode:plan` identifies gRPC or inter-service communication tasks
- When `/godmode:micro` designs microservice-to-microservice communication

## Workflow

### Step 1: Discovery & Context
Understand the gRPC service requirements:

```
GRPC DISCOVERY:
Project: <name and purpose>
Language: Go | Rust | Java | C++ | Python | TypeScript | C#
Framework: tonic (Rust) | grpc-go | grpc-java | grpc-node | grpcio (Python)
Proto version: proto3 (default) | proto2
Consumers: <internal services, mobile, browser via gRPC-web, CLI tools>
Scale: <expected RPS, concurrent streams>
Communication patterns: unary | server-streaming | client-streaming | bidi-streaming
Service mesh: Istio | Linkerd | Consul Connect | none
Existing protos: <list any existing .proto files for consistency>
Auth: mTLS | JWT token in metadata | API key | none
```

If the user hasn't specified, ask: "What language for the server? What patterns do you need (unary, streaming)?"

### Step 2: Proto File Design
Design well-structured Protocol Buffer definitions:

```protobuf
// ============================================================
// Proto: <service_name>.proto
// Package: <company>.<domain>.<version>
// ============================================================

syntax = "proto3";

package <company>.<domain>.v1;

option go_package = "<module>/gen/<domain>/v1;<domain>v1";
option java_package = "com.<company>.<domain>.v1";
option java_multiple_files = true;

import "google/protobuf/timestamp.proto";
import "google/protobuf/field_mask.proto";
import "google/protobuf/empty.proto";
import "google/protobuf/wrappers.proto";
import "google/api/annotations.proto";   // for REST transcoding
import "validate/validate.proto";         // for field validation

// --- Service Definition ---
service <Entity>Service {
  // Unary RPCs
  rpc Get<Entity>(Get<Entity>Request) returns (<Entity>) {}
  rpc List<Entities>(List<Entities>Request) returns (List<Entities>Response) {}
  rpc Create<Entity>(Create<Entity>Request) returns (<Entity>) {}
  rpc Update<Entity>(Update<Entity>Request) returns (<Entity>) {}
  rpc Delete<Entity>(Delete<Entity>Request) returns (google.protobuf.Empty) {}

  // Streaming RPCs
  rpc Watch<Entities>(Watch<Entities>Request) returns (stream <Entity>Event) {}
  rpc BatchCreate<Entities>(stream Create<Entity>Request) returns (BatchCreate<Entities>Response) {}
  rpc <Entity>Chat(stream ChatMessage) returns (stream ChatMessage) {}
}

// --- Messages ---
message <Entity> {
  string id = 1;
  string name = 2 [(validate.rules).string = {min_len: 1, max_len: 255}];
  <EntityStatus> status = 3;
  google.protobuf.Timestamp created_at = 4;
  google.protobuf.Timestamp updated_at = 5;
  map<string, string> metadata = 6;
}

// --- Enums ---
enum <EntityStatus> {
  <ENTITY_STATUS>_UNSPECIFIED = 0;  // Always have UNSPECIFIED as 0
  <ENTITY_STATUS>_ACTIVE = 1;
  <ENTITY_STATUS>_INACTIVE = 2;
  <ENTITY_STATUS>_ARCHIVED = 3;
}

// --- Request/Response Messages ---
message Get<Entity>Request {
  string id = 1 [(validate.rules).string.uuid = true];
}

message List<Entities>Request {
  int32 page_size = 1 [(validate.rules).int32 = {gte: 1, lte: 100}];
  string page_token = 2;
  string filter = 3;      // CEL expression or simple filter
  string order_by = 4;    // e.g., "created_at desc"
}

message List<Entities>Response {
  repeated <Entity> <entities> = 1;
  string next_page_token = 2;
  int32 total_size = 3;
}

message Create<Entity>Request {
  <Entity> <entity> = 1 [(validate.rules).message.required = true];
  string request_id = 2;  // Idempotency key
}

message Update<Entity>Request {
  <Entity> <entity> = 1 [(validate.rules).message.required = true];
  google.protobuf.FieldMask update_mask = 2;  // Partial updates
}

message Delete<Entity>Request {
  string id = 1 [(validate.rules).string.uuid = true];
}
```

### Step 3: Proto File Best Practices
Enforce proto design rules:

```
PROTO DESIGN RULES:
┌──────────────────────────────────────────────────────────────┐
│  Rule                                  │  Rationale           │
├────────────────────────────────────────┼──────────────────────┤
│  1. Use proto3 syntax                  │  Simpler, forward-   │
│                                        │  compatible          │
│  2. Package = company.domain.version   │  Globally unique,    │
│                                        │  version-scoped      │
│  3. Enum zero value = UNSPECIFIED      │  Detect unset fields │
│                                        │  vs intentional zero │
│  4. Field numbers are forever          │  Never reuse a field │
│                                        │  number after removal│
│  5. Use FieldMask for partial updates  │  Client specifies    │
│                                        │  which fields change │
│  6. Request/Response per RPC           │  Never share message │
│                                        │  types across RPCs   │
│  7. Idempotency key on create/update   │  Safe retries across │
│                                        │  network failures    │
│  8. google.protobuf.Timestamp for time │  Language-agnostic   │
│                                        │  time representation │
│  9. Repeated fields, not singular for  │  Forward-compatible  │
│     collections                        │  with pagination     │
│  10. Reserve removed field numbers     │  Prevent accidental  │
│      and names                         │  reuse               │
│  11. Keep messages small (<100 fields) │  Readability and     │
│                                        │  maintainability     │
│  12. Use wrappers.proto for nullable   │  Distinguish "not    │
│      scalars                           │  set" from zero      │
└────────────────────────────────────────┴──────────────────────┘

PROTO FILE ORGANIZATION:
  protos/
    <company>/
      <domain>/
        v1/
          <service>.proto       # Service definition + request/response messages
          resources.proto       # Shared resource messages
          enums.proto           # Shared enums
          events.proto          # Event messages for streaming
        v2/
          <service>.proto       # New version (breaking changes)
    google/
      api/
        annotations.proto       # HTTP transcoding annotations
      protobuf/
        timestamp.proto         # Well-known types
    validate/
      validate.proto            # buf validate rules

BREAKING CHANGE DETECTION:
  Use buf to detect breaking changes before merge:
  $ buf breaking --against '.git#branch=main'

  Breaking changes include:
  - Removing a field or changing its number
  - Changing a field type
  - Renaming a service or RPC
  - Removing an enum value
  - Changing package name
```

### Step 4: Code Generation Pipeline
Set up automated code generation from proto files:

```
CODE GENERATION:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  .proto files                                                │
│       │                                                      │
│       ▼                                                      │
│  ┌──────────┐                                                │
│  │   buf     │  (or protoc with plugins)                     │
│  │  generate │                                                │
│  └──────┬───┘                                                │
│    ┌────┼────────┬────────┐                                  │
│    ▼    ▼        ▼        ▼                                  │
│  ┌────┐┌──────┐┌──────┐┌──────┐                              │
│  │ Go ││TS/JS ││ Rust ││Python│                              │
│  │stubs││stubs ││stubs ││stubs │                              │
│  └────┘└──────┘└──────┘└──────┘                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘

BUF CONFIGURATION (buf.yaml):
  version: v2
  modules:
    - path: protos
  lint:
    use:
      - STANDARD
    except:
      - FIELD_NOT_REQUIRED  # Allow required fields with validate
  breaking:
    use:
      - FILE

BUF GENERATION (buf.gen.yaml):
  version: v2
  plugins:
    # Go
    - local: protoc-gen-go
      out: gen/go
      opt: paths=source_relative
    - local: protoc-gen-go-grpc
      out: gen/go
      opt: paths=source_relative

    # TypeScript
    - local: protoc-gen-ts
      out: gen/ts
      opt: long_type_string=true

    # Validation
    - local: protoc-gen-validate
      out: gen/go
      opt: paths=source_relative,lang=go

    # gRPC-Gateway (REST transcoding)
    - local: protoc-gen-grpc-gateway
      out: gen/go
      opt: paths=source_relative

GENERATION RULES:
1. Generated code is NEVER committed to the repository — regenerate in CI
2. Pin plugin versions in buf.gen.yaml or Makefile
3. Run buf lint before generation — invalid protos produce invalid code
4. Run buf breaking before merge — catch breaking changes early
5. Generate for ALL consumer languages in one pass
6. Include validation code generation (protoc-gen-validate or buf validate)
```

### Step 5: Streaming Patterns
Implement the four gRPC communication patterns:

```
STREAMING PATTERNS:

1. UNARY (Request-Response):
   ─────────────────────────
   Client sends one request, server sends one response.

   Client ──Request──> Server
   Client <──Response── Server

   Use for: CRUD operations, simple queries
   Example: GetUser, CreateOrder, DeleteItem

2. SERVER STREAMING:
   ──────────────────
   Client sends one request, server sends a stream of responses.

   Client ──Request──> Server
   Client <──Response── Server
   Client <──Response── Server
   Client <──Response── Server
   Client <────EOF───── Server

   Use for: Real-time feeds, large result sets, watch/subscribe
   Example: WatchOrders, StreamLogs, ListLargeDataset

   Implementation considerations:
   - Server controls flow — client receives as fast as server sends
   - Use for push-based patterns where server has new data over time
   - Client can cancel the stream at any time
   - Server should respect context cancellation

3. CLIENT STREAMING:
   ──────────────────
   Client sends a stream of requests, server sends one response.

   Client ──Request──> Server
   Client ──Request──> Server
   Client ──Request──> Server
   Client ────EOF────> Server
   Client <──Response── Server

   Use for: Batch uploads, aggregation, file upload
   Example: BatchCreateItems, UploadFile, ReportMetrics

   Implementation considerations:
   - Client controls flow — sends at its own pace
   - Server processes stream and returns summary/result
   - Use for accumulating data before processing
   - Server can return early (before client finishes) on error

4. BIDIRECTIONAL STREAMING:
   ─────────────────────────
   Both client and server send streams of messages independently.

   Client ──Request──> Server
   Client <──Response── Server
   Client ──Request──> Server
   Client ──Request──> Server
   Client <──Response── Server
   Client <──Response── Server

   Use for: Chat, real-time collaboration, game state sync
   Example: Chat, CollaborativeEdit, GameSync

   Implementation considerations:
   - Streams are independent — no request-response pairing
   - Either side can send at any time
   - Order is preserved within each direction
   - Complex error handling — either side can error or cancel
   - Use channels/goroutines (Go) or async streams (Rust) for concurrency

STREAMING BEST PRACTICES:
┌──────────────────────────────────────────────────────────────┐
│  Practice                                │  Reason            │
├──────────────────────────────────────────┼────────────────────┤
│  Set deadlines on all RPCs               │  Prevent hung      │
│                                          │  connections       │
│  Implement keepalive pings               │  Detect dead       │
│                                          │  connections       │
│  Handle stream errors as normal flow     │  Streams can break │
│                                          │  at any time       │
│  Use flow control (backpressure)         │  Prevent OOM from  │
│                                          │  fast producers    │
│  Send heartbeats on long-lived streams   │  Keep proxies and  │
│                                          │  LBs from closing  │
│  Implement reconnection with resume      │  Streams will drop │
│                                          │  — resume, don't   │
│                                          │  restart            │
│  Log stream lifecycle events             │  Debug connection   │
│                                          │  issues             │
└──────────────────────────────────────────┴────────────────────┘
```

### Step 6: gRPC-Web for Browser Clients

```
GRPC-WEB OPTIONS:
┌──────────────┬────────────────────────────────────────────────────┐
│ Option       │ Description                                        │
├──────────────┼────────────────────────────────────────────────────┤
│ Envoy Proxy  │ Transcodes gRPC-Web to native gRPC. Production-   │
│ (production) │ proven. No server code changes. Extra component.   │
│ Buf Connect  │ No proxy needed. Full streaming. Browser-native.   │
│ (new projects│ Supports gRPC + gRPC-Web + Connect simultaneously.│
│ grpc-web npm │ Server-side middleware. Simpler but limited         │
│ (simple)     │ streaming support.                                 │
└──────────────┴────────────────────────────────────────────────────┘

LIMITATIONS: No client streaming, no bidi streaming (browser HTTP/1.1).
Server streaming works via chunked transfer encoding. CORS required.

CODE GENERATION:
  buf generate --template buf.gen.ts.yaml   # Buf Connect (recommended)
  protoc --grpc-web_out=...                 # grpc-web
```

### Step 7: Load Balancing & Service Mesh Integration
Design production-ready gRPC infrastructure:

```
GRPC LOAD BALANCING:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  CHALLENGE: gRPC uses HTTP/2, which multiplexes requests     │
│  over a single long-lived connection. Traditional L4 load    │
│  balancers only see one connection, so all requests go to    │
│  one backend.                                                │
│                                                              │
│  SOLUTION: Use L7 (application-layer) load balancing that    │
│  understands HTTP/2 frames and can distribute individual     │
│  RPCs across backends.                                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘

LOAD BALANCING STRATEGIES:
1. Proxy-based L7 (RECOMMENDED): Envoy/Nginx/Traefik terminates HTTP/2, distributes individual RPCs.
2. Client-side (look-aside): Client discovers backends via DNS/etcd/Consul, distributes RPCs directly.
   Built into grpc-go, grpc-java (pick_first, round_robin).
3. xDS-based (service mesh): Client gets routing config from control plane (Istio, Linkerd, Consul).

SERVICE MESH INTEGRATION:

┌──────────────────────────────────────────────────────────────┐
│  Mesh         │  gRPC Support  │  Notes                      │
├───────────────┼────────────────┼─────────────────────────────┤
│  Istio        │  Full (Envoy)  │  L7 LB, mTLS, tracing,     │
│               │                │  traffic management          │
│  Linkerd      │  Full          │  Automatic L7 LB for HTTP/2,│
│               │                │  mTLS, transparent           │
│  Consul       │  Full (Envoy)  │  Service discovery + Envoy  │
│  Connect      │                │  sidecar                     │
└───────────────┴────────────────┴─────────────────────────────┘

MESH CONFIGURATION: Enable HTTP/2 detection, per-RPC LB, retry policies
(unary: retry UNAVAILABLE+DEADLINE_EXCEEDED max 3, streaming: UNAVAILABLE only),
circuit breaking, distributed tracing propagation, mTLS.

HEALTH CHECKING: Implement grpc.health.v1.Health on every server.
Used by load balancers, service mesh, and Kubernetes probes.
```

### Step 8: Error Handling & Observability
Design robust error handling and observability:

```
GRPC ERROR HANDLING:

STATUS CODES (use correctly — not all errors are INTERNAL):
┌──────────────────┬───────────────────────────────────────────┐
│  Code            │  When to Use                              │
├──────────────────┼───────────────────────────────────────────┤
│  OK              │  Success                                  │
│  CANCELLED       │  Client cancelled the request             │
│  INVALID_ARGUMENT│  Client sent invalid input (validation)   │
│  NOT_FOUND       │  Requested resource does not exist        │
│  ALREADY_EXISTS  │  Duplicate resource (create conflict)     │
│  PERMISSION_DENIED│ Authenticated but not authorized         │
│  UNAUTHENTICATED │  Missing or invalid credentials           │
│  RESOURCE_EXHAUSTED│ Rate limit exceeded, quota exhausted    │
│  FAILED_PRECONDITION│ Operation rejected (wrong state)       │
│  ABORTED         │  Concurrency conflict (retry may succeed) │
│  OUT_OF_RANGE    │  Value outside valid range                │
│  UNIMPLEMENTED   │  RPC not implemented                     │
│  INTERNAL        │  Unexpected server error (bug)            │
│  UNAVAILABLE     │  Service temporarily unavailable (retry)  │
│  DEADLINE_EXCEEDED│ Operation took too long                  │
│  DATA_LOSS       │  Unrecoverable data loss or corruption    │
└──────────────────┴───────────────────────────────────────────┘

RICH ERROR DETAILS (google.rpc.Status):
  BadRequest.FieldViolation (validation), RetryInfo (retry guidance),
  ErrorInfo (machine-readable reason), PreconditionFailure (which precondition).

OBSERVABILITY:

Interceptors/Middleware:
  Every gRPC server should have these interceptors in order:
  1. Recovery (catch panics, return INTERNAL)
  2. Logging (structured log for every RPC)
  3. Metrics (Prometheus counters and histograms)
  4. Tracing (OpenTelemetry span per RPC)
  5. Auth (validate credentials from metadata)
  6. Validation (validate request messages)

Metrics to export:
  - grpc_server_handled_total{method, code} — RPC count by method and status
  - grpc_server_handling_seconds{method} — RPC latency histogram
  - grpc_server_msg_received_total{method} — Messages received (streaming)
  - grpc_server_msg_sent_total{method} — Messages sent (streaming)
  - grpc_server_started_total{method} — RPCs started (for in-flight tracking)

Distributed tracing:
  - Propagate trace context via gRPC metadata
  - Create span per RPC (automatic with interceptor)
  - Add attributes: rpc.method, rpc.service, rpc.status_code
  - Propagate across service boundaries in mesh
```

### Step 9: Testing gRPC Services
Comprehensive testing strategy:

```
GRPC TESTING STRATEGY:
┌─────────────────────────────────────────────────────────────┐
│  Layer              │  What to Test            │  Tool       │
├─────────────────────┼──────────────────────────┼─────────────┤
│  Proto validation   │  Proto files lint clean  │  buf lint   │
│  Breaking changes   │  No breaking changes     │  buf breaking│
│  Unit: handlers     │  RPC handler logic with  │  Go test /  │
│                     │  mocked dependencies     │  pytest     │
│  Integration        │  Full server with test   │  grpcurl /  │
│                     │  client and real DB      │  Evans      │
│  Streaming          │  All stream patterns     │  Custom test│
│                     │  with edge cases         │  client     │
│  Load               │  RPS, latency percentiles│  ghz        │
│  Contract           │  Proto backward compat   │  buf breaking│
│  E2E                │  Multi-service flows     │  Custom     │
└─────────────────────┴──────────────────────────┴─────────────┘

TESTING TOOLS:
  - buf lint: Validate proto file style and conventions
  - buf breaking: Detect breaking changes against a reference
  - grpcurl: Command-line gRPC client (like curl for gRPC)
  - Evans: Interactive gRPC client with REPL
  - ghz: gRPC load testing tool (like wrk for gRPC)
  - testify (Go), pytest (Python): Unit test frameworks

STREAMING TEST CASES:
  Server streaming:
  - Server sends 0 messages (empty stream)
  - Server sends 1 message
  - Server sends many messages (verify order)
  - Client cancels mid-stream
  - Server errors mid-stream
  - Connection drops mid-stream

  Client streaming:
  - Client sends 0 messages
  - Client sends 1 message
  - Client sends many messages
  - Server returns early (before client finishes)
  - Client errors mid-stream

  Bidirectional:
  - Both sides send and receive concurrently
  - One side finishes before the other
  - Either side errors mid-stream
  - Deadlock detection (both sides waiting for data)
```

### Step 10: Artifacts & Completion
Generate the deliverables:

```
GRPC DESIGN COMPLETE:

Artifacts:
- Proto files: protos/<company>/<domain>/v1/<service>.proto
- Generated code: gen/<language>/<domain>/v1/
- Buf config: buf.yaml, buf.gen.yaml, buf.lock
- Server: src/server/<service>_server.<ext>
- Interceptors: src/interceptors/{logging,metrics,auth,validation}.<ext>
- Health check: src/health/health_server.<ext>
- Tests: tests/<service>_test.<ext>

Metrics:
- Services: <N> service definitions
- RPCs: <N> unary, <M> server-streaming, <K> client-streaming, <J> bidi
- Messages: <N> message types, <M> enums
- Validation: buf lint PASS, buf breaking PASS

Next steps:
-> /godmode:test — Write comprehensive tests for RPC handlers
-> /godmode:deploy — Deploy with load balancing and health checks
-> /godmode:observe — Set up metrics, tracing, and alerting
-> /godmode:micro — Integrate with microservice architecture
```

Commit: `"grpc: <service> — <N> RPCs, <M> message types, streaming + health checks configured"`

## Key Behaviors

1. **Proto files are the contract.** Design the proto file first. The proto file IS the API specification, the documentation, and the source of code generation.
2. **Use buf, not raw protoc.** buf provides linting, breaking change detection, and a better generation pipeline. Raw protoc is error-prone and hard to maintain.
3. **Every enum starts with UNSPECIFIED = 0.** This is how you detect unset fields. Skipping this causes subtle bugs when zero-value enums look intentional.
4. **Field numbers are permanent.** Never reuse a field number. Reserve numbers and names when removing fields.
5. **Request and response messages are per-RPC.** Never share a message type across multiple RPCs. Each RPC gets its own request and response — even if they look similar today.
6. **Streaming is an architecture choice.** Do not use streaming just because you can. Unary RPCs are simpler to debug, test, retry, and load balance. Use streaming when the data model demands it.
7. **L7 load balancing is mandatory for gRPC.** L4 load balancers see one HTTP/2 connection and send all RPCs to one backend. Always use L7 or client-side load balancing.
8. **Health checks are not optional.** Every gRPC server implements grpc.health.v1.Health. Load balancers, meshes, and orchestrators depend on it.

## Example Usage

### Designing a gRPC Service
```
User: /godmode:grpc Design a gRPC service for an order management system

gRPC: Starting discovery...

GRPC DISCOVERY:
Project: Order Management Service
Language: Go (tonic for Rust alternative)
Framework: grpc-go
Consumers: Internal services (inventory, payment, shipping)
Communication: Unary for CRUD, server-streaming for order status updates

Proto designed:
- Service: OrderService with 7 RPCs
- Messages: 12 message types, 3 enums
- Streaming: WatchOrderStatus (server-streaming)
- Validation: buf validate rules on all fields
- Health check: grpc.health.v1.Health implemented

buf lint: PASS (0 warnings)
buf breaking: PASS (no previous version)
```

### Adding Streaming
```
User: /godmode:grpc Add bidirectional streaming for real-time chat

gRPC: Designing bidi streaming RPC...

RPC: ChatStream(stream ChatMessage) returns (stream ChatMessage)

Implementation:
- Server maintains connection map (userId -> stream)
- Messages routed server-side to target recipients
- Heartbeat every 30s to detect stale connections
- Reconnection with message sequence number for resume
- Flow control: backpressure when client is slow

Test cases:
- Concurrent send/receive
- Client disconnect and reconnect
- Server graceful shutdown with drain
- 1000 concurrent streams load test
```

### Setting Up gRPC-Web
```
User: /godmode:grpc Enable browser access to our gRPC services

gRPC: Evaluating gRPC-Web options...

RECOMMENDED: Buf Connect
- No proxy required
- Full streaming support in browsers
- Compatible with existing gRPC servers
- TypeScript client generation with type safety

Setup:
1. Added connect-go adapter to existing gRPC server
2. Generated TypeScript client with buf generate
3. Configured CORS for browser access
4. Server now accepts gRPC, gRPC-Web, and Connect protocols simultaneously
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full gRPC design workflow |
| `--proto` | Design proto files only |
| `--generate` | Run code generation from existing protos |
| `--streaming` | Focus on streaming pattern design |
| `--web` | Set up gRPC-Web or Connect for browser clients |
| `--mesh` | Configure service mesh integration |
| `--lb` | Design load balancing strategy |
| `--validate` | Lint and validate existing proto files |
| `--breaking` | Check for breaking changes against main branch |
| `--test` | Generate test suite for gRPC handlers |
| `--bench` | Run gRPC load tests with ghz |

## Auto-Detection

On activation, automatically detect gRPC project context:

```
AUTO-DETECT SEQUENCE:
1. Scan for .proto files — determine package structure, proto version (proto2 vs proto3)
2. Detect language: Go (go.mod with google.golang.org/grpc), Rust (Cargo.toml with tonic), Java (grpc-java deps), Python (grpcio), TypeScript (grpc-node/@grpc)
3. Check for buf: buf.yaml, buf.gen.yaml, buf.lock — detect lint and generation config
4. If no buf, check for protoc: Makefile with protoc commands, generate scripts
5. Detect code generation targets: gen/ directory, generated stubs in source tree
6. Scan for streaming patterns: stream keyword in .proto service definitions
7. Check for health check implementation: grpc.health.v1 import or Health service definition
8. Detect load balancing: Envoy config, Istio VirtualService, client-side LB config
9. Check for observability: interceptor/middleware for logging, metrics (Prometheus), tracing (OpenTelemetry)
10. Detect gRPC-Web or Connect: envoy grpc-web filter, connect-go imports, grpc-web npm package
```

## Explicit Loop Protocol

```
FOR EACH service (in dependency order):
  1. DESIGN proto: service definition, messages, enums, validation rules
  2. RUN buf lint + buf breaking — fix before proceeding
  3. GENERATE code, IMPLEMENT handlers (unary first, then streaming)
  4. ADD interceptors (recovery, logging, metrics, auth), health check
  5. WRITE tests, REPORT progress

POST-LOOP: buf lint + buf breaking on full proto tree, verify all health checks.
```

## Multi-Agent Dispatch

```
PARALLEL AGENTS (3 worktrees):
  Agent 1 — grpc-protos: proto design, buf config, shared types, lint + breaking checks
  Agent 2 — grpc-server: handlers, interceptor chain, health check, L7 load balancing
  Agent 3 — grpc-client: client stubs, client interceptors, gRPC-Web/Connect, integration tests

MERGE: Proto first (server+client depend on generated code). Final: integration test suite.
```

## Hard Rules

```
HARD RULES — GRPC:
1. ALWAYS use proto3 syntax. Proto2 is legacy and should not be used for new services.
2. EVERY enum MUST start with UNSPECIFIED = 0. This is how you detect unset fields.
3. NEVER reuse a field number after removing a field. Reserve removed numbers and names.
4. NEVER share request/response messages across RPCs. Each RPC gets its own messages.
5. ALWAYS use buf (not raw protoc) for linting, breaking change detection, and code generation.
6. NEVER commit generated code. Generate in CI from proto files. Committed stubs drift and cause conflicts.
7. ALWAYS use L7 load balancing for gRPC. L4 balancers see one HTTP/2 connection and route everything to one backend.
8. ALWAYS implement grpc.health.v1.Health on every gRPC server. Load balancers and orchestrators depend on it.
9. ALWAYS set deadlines on all RPCs. RPCs without deadlines can hang forever and leak resources.
10. ALWAYS use correct status codes. NOT_FOUND, INVALID_ARGUMENT, PERMISSION_DENIED give clients actionable information — INTERNAL does not.
```

## Output Format

```
GRPC SERVICE COMPLETE:
  Proto files: <paths to .proto files>
  Services: <N> services, <M> total RPCs
  Streaming: <N> server-stream, <M> client-stream, <K> bidi-stream, <J> unary
  Proto validation: buf lint <PASS|FAIL>
  Code generation: <languages> generated from proto
  Reflection: <enabled|disabled>
  Health check: <grpc.health.v1 implemented|not implemented>
  Load balancing: <strategy> (round-robin | pick-first | xDS)
  TLS: <mTLS | server-only | plaintext>

SERVICE SUMMARY:
+--------------------------------------------------------------+
|  Service          | RPCs | Streaming | Proto pkg              |
+--------------------------------------------------------------+
|  <ServiceName>    | N    | N/M bidi  | <package.name>         |
+--------------------------------------------------------------+
```

## TSV Logging

Log every gRPC design session to `.godmode/grpc-results.tsv`:

```
Fields: timestamp\tproject\tservices_count\trpcs_count\tstreaming_rpcs\tbuf_lint_status\tbreaking_changes\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-service\t4\t18\t6\tPASS\t0\tabc1234
```

Append after every completed design or implementation pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
GRPC SUCCESS CRITERIA:
+--------------------------------------------------------------+
|  Criterion                                  | Required         |
+--------------------------------------------------------------+
|  Proto files compile without errors         | YES              |
|  buf lint passes with zero violations       | YES              |
|  buf breaking detects no regressions        | YES (if exists)  |
|  Health check service implemented           | YES              |
|  Reflection enabled for dev/staging         | YES              |
|  Deadline/timeout set on all RPCs           | YES              |
|  Error codes use canonical gRPC codes       | YES              |
|  Interceptors for logging + metrics         | YES              |
|  TLS configured for production              | YES (production)  |
|  Generated code committed or CI-generated   | YES              |
+--------------------------------------------------------------+

VERDICT: ALL required criteria must PASS. Any FAIL → fix before commit.
```

## Error Recovery

```
ERROR RECOVERY — GRPC:
1. Proto compilation fails:
   → Read protoc/buf error output. Fix syntax (missing imports, type mismatches, reserved field conflicts). Re-compile. Repeat until clean.
2. buf lint violations:
   → Run buf lint --error-format=json. Fix each violation (naming conventions, package structure, field numbering). Re-lint until 0 errors.
3. Breaking change detected (buf breaking):
   → Do not rename/remove fields. Add new fields with new numbers. Use reserved to retire old fields. Mark deprecated with field option.
4. Streaming RPC hangs or drops messages:
   → Check deadline/timeout configuration. Verify flow control (recv/send balance). Add keepalive pings for long-lived streams.
5. Client connection fails (UNAVAILABLE):
   → Verify server address and port. Check TLS cert chain. Confirm health check passes. Test with grpcurl for raw connectivity.
6. Code generation produces stale stubs:
   → Re-run buf generate or protoc with current proto files. Delete old generated files first. Verify import paths match proto package.
```

## Keep/Discard Discipline
```
After EACH proto file change:
  1. MEASURE: Run buf lint + buf breaking against main branch.
  2. COMPARE: Are lint errors = 0 AND breaking changes = 0?
  3. DECIDE:
     - KEEP if buf lint PASS AND buf breaking PASS AND health check present.
     - DISCARD if any lint error, any breaking change, or missing health check.
  4. COMMIT kept changes. Revert discarded changes before the next iteration.

Never keep a change that introduces a wire-incompatible break.
Never skip buf breaking check before merge.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - buf lint: 0 errors AND buf breaking: 0 regressions AND health check implemented
  - All RPCs have deadlines, per-RPC request/response messages, and validation rules
  - User explicitly requests stop
  - Max iterations (10) reached
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run gRPC tasks sequentially: proto definitions, then server implementation, then client stubs.
- Use branch isolation per task: `git checkout -b godmode-grpc-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
