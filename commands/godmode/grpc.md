# /godmode:grpc

Design, build, and optimize gRPC services with Protocol Buffers. Covers proto file design, code generation with buf, streaming patterns, gRPC-web for browsers, load balancing, and service mesh integration.

## Usage

```
/godmode:grpc                           # Full gRPC design workflow
/godmode:grpc --proto                   # Design proto files only
/godmode:grpc --generate                # Run code generation from existing protos
/godmode:grpc --streaming               # Focus on streaming pattern design
/godmode:grpc --web                     # Set up gRPC-Web or Connect for browser clients
/godmode:grpc --mesh                    # Configure service mesh integration
/godmode:grpc --lb                      # Design load balancing strategy
/godmode:grpc --validate                # Lint and validate existing proto files
/godmode:grpc --breaking                # Check for breaking changes against main branch
/godmode:grpc --test                    # Generate test suite for gRPC handlers
/godmode:grpc --bench                   # Run gRPC load tests with ghz
```

## What It Does

1. Discovers project context, language, framework, and communication patterns
2. Designs proto files with proper package naming, field numbering, and validation rules
3. Sets up code generation pipeline with buf (lint, breaking change detection, multi-language generation)
4. Implements streaming patterns (unary, server-streaming, client-streaming, bidirectional)
5. Configures gRPC-Web or Buf Connect for browser client access
6. Designs L7 load balancing for proper HTTP/2 request distribution
7. Integrates with service mesh (Istio, Linkerd, Consul Connect) for mTLS, tracing, and traffic management
8. Configures error handling with proper status codes and rich error details
9. Sets up observability interceptors (logging, metrics, tracing, auth)

## Output
- Proto files: `protos/<company>/<domain>/v1/<service>.proto`
- Generated code: `gen/<language>/<domain>/v1/`
- Buf config: `buf.yaml`, `buf.gen.yaml`, `buf.lock`
- Server: `src/server/<service>_server.<ext>`
- Tests: `tests/<service>_test.<ext>`
- Commit: `"grpc: <service> — <N> RPCs, <M> message types, streaming + health checks configured"`

## Next Step
After gRPC design: `/godmode:test` to write handler tests, or `/godmode:micro` to integrate with microservice architecture.

## Examples

```
/godmode:grpc Design a gRPC service for order management
/godmode:grpc --streaming Add bidirectional streaming for real-time chat
/godmode:grpc --web Enable browser access to our gRPC services
/godmode:grpc --breaking Check if our proto changes break existing clients
/godmode:grpc --bench Load test our gRPC service with ghz
```
