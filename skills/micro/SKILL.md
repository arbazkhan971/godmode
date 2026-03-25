---
name: micro
description: Microservices design and management.
---

## Activate When
- `/godmode:micro`, "design microservices"
- "decompose this monolith", "service mesh"
- "saga pattern", "inter-service communication"

## Workflow

### 1. System Context
```bash
find . -name "docker-compose*" -o -name "*.proto" \
  | head -10
grep -r "microservices\|grpc\|moleculer" \
  package.json 2>/dev/null
```
```
Architecture: Monolith | Modular Monolith | Microservices
Team Structure: <teams, ownership>
Scale: <request volume, data volume>
Data Stores: <databases, caches, brokers>
```

### 2. Service Decomposition
Domain-driven bounded contexts. Each service owns
its data exclusively. Decompose by business capability
(not technical layer).

IF two services need strong consistency: they belong
together. IF greenfield: start with modular monolith.

### 3. Inter-Service Communication
- **REST**: CRUD, immediate response, external-facing.
  Circuit breaker (5 failures -> open), timeout 3s,
  retry 3x exponential, fallback.
- **gRPC**: high-throughput internal (10K+ RPS),
  low-latency, streaming, polyglot.
- **Event-Driven**: eventual consistency, decoupling,
  fan-out. Kafka (ordered), RabbitMQ (routing),
  SQS/SNS (AWS), NATS (ultra-low latency).

DECISION: Need immediate response -> sync (REST/gRPC).
Fire-and-forget/fan-out -> async (events).

### 4. Service Mesh
- **Istio**: complex routing, multi-cluster, WASM.
  ~128Mi memory per sidecar.
- **Linkerd**: simpler, lighter (~64Mi), gentler
  learning curve.

### 5. Service Discovery
K8s DNS: `<svc>.<ns>.svc.cluster.local`.
LB: Round Robin (homogeneous), Least Request
(variable latency), Consistent Hash (sticky).

### 6. Saga Pattern
- **Choreography (2-4 services)**: each publishes
  events, next reacts. Loose coupling, hard to trace.
- **Orchestration (5+ services)**: central coordinator,
  compensates in reverse on failure. Easy to trace.

Every step MUST have compensating action (idempotent).
Persist saga state. Use correlation IDs. Set timeouts.

### 7. Resilience Patterns
Circuit Breaker (5 consecutive 5xx, 30s half-open),
Timeout (3s default), Retry (3x exponential+jitter),
Bulkhead (10 concurrent per svc), Rate Limit, Fallback.

### 8. Validation
Single bounded context per service, no shared DBs,
single team ownership, async where possible, circuit
breakers on sync calls, saga for distributed txns.

## Quality Targets
- Target: <100ms inter-service call latency p95
- Target: >99.9% service availability
- Max service payload: <1MB per request
- Circuit breaker threshold: >50% error rate triggers open

## Hard Rules
1. NEVER share a database between services.
2. NEVER decompose by technical layer.
3. NEVER skip modular monolith for greenfield.
4. EVERY sync call: circuit breaker + timeout 3s + retry.
5. EVERY service: health check + independent deploy.
6. NEVER use distributed transactions (2PC). Use sagas.
7. EVERY event: event_id, type, version, timestamp,
   source, correlation_id, data.

## TSV Logging
Append `.godmode/micro-results.tsv`:
```
timestamp	services_count	communication	saga_pattern	mesh	status
```

## Keep/Discard
```
KEEP if: contract tests pass AND circuit breakers work
  AND no cascading failures.
DISCARD if: contract broken OR cascading failure
  OR service discovery fails.
```

## Stop Conditions
```
STOP when ALL of:
  - All boundaries defined with clear contracts
  - Circuit breakers on all inter-service calls
  - Contract tests passing in CI
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Cascading failure | Add circuit breakers, bulkhead |
| Saga fails mid-way | Compensate reverse, verify idempotency |
| Discovery not resolving | Check DNS, retry with backoff |
| Circular dependency | Extract shared or use events |
