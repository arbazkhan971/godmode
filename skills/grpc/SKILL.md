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
Enable browser access to gRPC services:

```
GRPC-WEB ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────┐       │
│  │  Browser  │───│  Envoy Proxy │───│  gRPC Server  │       │
│  │ (gRPC-Web)│   │  (transcodes)│   │  (native gRPC)│       │
│  └──────────┘    └──────────────┘    └──────────────┘       │
│                                                              │
│  Alternative: gRPC-Web middleware in the server itself       │
│  ┌──────────┐    ┌──────────────────────────┐               │
│  │  Browser  │───│  gRPC Server + grpc-web  │               │
│  │ (gRPC-Web)│   │  middleware               │               │
│  └──────────┘    └──────────────────────────┘               │
│                                                              │
│  Alternative: Connect protocol (Buf Connect)                 │
│  ┌──────────┐    ┌──────────────────────────┐               │
│  │  Browser  │───│  Connect Server           │               │
│  │ (Connect) │   │  (gRPC + gRPC-Web + HTTP) │               │
│  └──────────┘    └──────────────────────────┘               │
│                                                              │
└─────────────────────────────────────────────────────────────┘

GRPC-WEB OPTIONS:

Option A — Envoy Proxy (RECOMMENDED for production):
  Envoy sits in front of gRPC services and transcodes
  gRPC-Web requests to native gRPC.

  Pros: No server code changes, production-proven, supports all features
  Cons: Extra infrastructure component

Option B — grpc-web npm package + middleware:
  Server includes gRPC-Web middleware that handles transcoding.

  Pros: No separate proxy, simpler deployment
  Cons: Limited streaming support, less mature

Option C — Buf Connect (RECOMMENDED for new projects):
  Connect is a protocol compatible with gRPC that works natively
  in browsers without a proxy. Supports gRPC, gRPC-Web, and
  Connect protocols simultaneously.

  Pros: No proxy needed, full streaming, idiomatic HTTP, browser-native
  Cons: Newer ecosystem, requires Connect-compatible server

GRPC-WEB LIMITATIONS:
- No client streaming (browser limitation — HTTP/1.1)
- No bidirectional streaming (use WebSocket fallback or Connect)
- Server streaming works but with chunked transfer encoding
- Binary proto encoding or base64 text encoding
- CORS must be configured on the proxy/server

CLIENT CODE GENERATION:
  # Using buf + connect-es (recommended)
  buf generate --template buf.gen.ts.yaml

  # Using grpc-web
  protoc --grpc-web_out=import_style=typescript,mode=grpcwebtext:gen/web
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

1. Proxy-based (L7 — RECOMMENDED for most deployments):
   ┌──────────┐    ┌──────────┐    ┌──────────┐
   │  Client   │───│  L7 Proxy │───│  Server 1 │
   │           │   │ (Envoy,   │───│  Server 2 │
   │           │   │  Nginx,   │───│  Server 3 │
   │           │   │  Traefik) │
   └──────────┘    └──────────┘

   - Proxy terminates HTTP/2 connection from client
   - Opens separate connections to each backend
   - Distributes individual RPCs (not connections)
   - Supports round-robin, least-connections, weighted

2. Client-side (look-aside):
   ┌──────────┐    ┌──────────┐
   │  Client   │───│  Server 1 │
   │  (built-in│───│  Server 2 │
   │   LB)     │───│  Server 3 │
   └──────┬───┘
          │
   ┌──────┴───────┐
   │  Service      │
   │  Discovery    │
   │  (DNS, etcd,  │
   │   Consul)     │
   └──────────────┘

   - Client discovers backends via service registry
   - Client maintains connections to multiple backends
   - Client distributes RPCs using configured policy
   - Built into grpc-go, grpc-java (pick_first, round_robin)

3. xDS-based (service mesh native):
   - Client uses xDS protocol to get routing config from control plane
   - Istio, Linkerd, and Consul inject xDS-compatible sidecars
   - Most sophisticated: supports traffic splitting, fault injection, retries

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

MESH CONFIGURATION FOR GRPC:
1. Enable HTTP/2 protocol detection (automatic in Istio/Linkerd)
2. Configure per-RPC load balancing (not per-connection)
3. Set retry policies per method:
   - Unary: retry on UNAVAILABLE, DEADLINE_EXCEEDED (max 3)
   - Streaming: retry on UNAVAILABLE only (streams are not idempotent)
4. Configure circuit breaking:
   - Max connections per host
   - Max pending requests
   - Max requests per connection
5. Enable distributed tracing propagation (gRPC metadata -> trace headers)
6. Configure mTLS between services (mesh handles certificate rotation)

HEALTH CHECKING:
  service Health {
    rpc Check(HealthCheckRequest) returns (HealthCheckResponse);
    rpc Watch(HealthCheckRequest) returns (stream HealthCheckResponse);
  }

  - Implement grpc.health.v1.Health service on every gRPC server
  - Used by load balancers, service mesh, and Kubernetes probes
  - Report per-service health (not just process health)
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
  Use google.rpc error details to attach structured metadata:
  - BadRequest.FieldViolation — per-field validation errors
  - RetryInfo — when and how to retry
  - DebugInfo — stack trace (development only, never production)
  - ErrorInfo — machine-readable error reason and domain
  - QuotaFailure — which quota was exceeded
  - PreconditionFailure — which precondition failed

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

## Anti-Patterns

- **Do NOT use L4 load balancing for gRPC.** HTTP/2 multiplexes all RPCs over one connection. L4 balancers see one connection and route everything to one backend.
- **Do NOT skip enum zero value.** Every enum must have `FOO_UNSPECIFIED = 0`. Without it, you cannot distinguish "not set" from the first enum value.
- **Do NOT reuse field numbers.** When you remove a field, reserve its number. Reusing a number causes silent data corruption with old clients.
- **Do NOT share request/response messages across RPCs.** Each RPC gets its own messages. Sharing creates coupling — changing one RPC breaks another.
- **Do NOT use INTERNAL for all errors.** gRPC has 16 status codes for a reason. INVALID_ARGUMENT, NOT_FOUND, and PERMISSION_DENIED give clients actionable information.
- **Do NOT ignore backpressure in streams.** A fast producer and slow consumer will cause OOM. Implement flow control on both sides.
- **Do NOT skip health checks.** Without grpc.health.v1.Health, load balancers and orchestrators cannot route traffic correctly.
- **Do NOT commit generated code.** Generate in CI from proto files. Committed generated code drifts from protos and causes merge conflicts.
