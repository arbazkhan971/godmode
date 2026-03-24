---
name: micro
description: |
  Microservices design and management skill. Activates when user needs to decompose monoliths, design service boundaries, configure inter-service communication (REST, gRPC, events), set up service mesh (Istio, Linkerd), implement service discovery and load balancing, or manage distributed transactions with the Saga pattern. Triggers on: /godmode:micro, "design microservices", "decompose this service", "service mesh", "saga pattern", "service communication", or when the orchestrator detects microservice architecture work.
---

# Micro -- Microservices Design & Management

## When to Activate
- User invokes `/godmode:micro`
- User says "design microservices", "decompose this monolith", "split this service"
- User says "service mesh", "service discovery", "saga pattern"
- User says "inter-service communication", "gRPC between services", "event-driven services"
- Building a new distributed system or migrating from a monolith

## Workflow

### Step 1: System Context Assessment
```
SYSTEM CONTEXT:
Project: <name>  Current Architecture: Monolith | Modular Monolith | Microservices | Greenfield
Team Structure: <teams, ownership>  Scale: <request volume, data volume, growth>
Data Stores: <databases, caches, brokers>  Constraints: <SLAs, compliance, skill level>
Pain Points: <what drives the need for microservices>
```

### Step 2: Service Decomposition
Define bounded contexts with domain-driven decomposition:

```
BOUNDED CONTEXT MAP:
  Context: <Name>
  Business capability: <what it owns>
  Core entities, Commands, Queries, Events published/consumed
  Data ownership: <exclusively owned data>  Team: <owning team>
```

Decomposition criteria (HIGH weight): business domain boundary, independent deployment need, data ownership clarity, team alignment, transactional boundary. Rules: decompose by business capability (not technical layer), each service owns its data exclusively, if two services need strong consistency they belong together.

### Step 3: Inter-Service Communication

**REST** — Simple CRUD, immediate response needed, external-facing. Add circuit breaker (5 failures -> open), timeout (3s), retry (3x exponential), fallback.

**gRPC** — High-throughput internal (10k+ RPS), low-latency, streaming, polyglot. Use deadline propagation, client-side load balancing, health checking protocol.

**Event-Driven (Async)** — Eventual consistency, decoupling, fan-out, long-running processes. Standard event format: event_id, event_type, version, timestamp, source, correlation_id, data. Brokers: Kafka (high-throughput, ordered), RabbitMQ (flexible routing), SQS/SNS (AWS-native), NATS (ultra-low latency).

```
DECISION: Need immediate response -> Sync (REST/gRPC)
          Fire-and-forget/fan-out  -> Async (Events/Pub-Sub)
          High-throughput internal  -> gRPC
          External API              -> REST
```

### Step 4: Service Mesh
**Istio:** VirtualService (traffic routing/splitting), DestinationRule (circuit breaking, load balancing), PeerAuthentication (mTLS STRICT), AuthorizationPolicy (service-to-service ACL). Best for complex routing, multi-cluster, WASM.

**Linkerd:** ServiceProfile (retry/timeout per route), TrafficSplit (canary). Simpler, lighter (~64Mi vs ~128Mi), gentler learning curve.

### Step 5: Service Discovery & Load Balancing
K8s DNS: `<service>.<namespace>.svc.cluster.local`. Load balancing: Round Robin (homogeneous), Least Request (variable latency), Consistent Hash (sticky sessions).

### Step 6: Saga Pattern (Distributed Transactions)

**Choreography (2-4 services):** Each service publishes events, next service reacts. Loose coupling, hard to trace. Each step has a compensating action.

**Orchestration (5+ services):** Central coordinator manages steps, compensates in reverse on failure. Easy to trace, unit-testable.

Rules: every step MUST have a compensating action (idempotent), persist saga state, use correlation IDs, set timeouts, log every transition.

### Step 7: Service Topology
```
Clients -> API Gateway (rate limiting, auth, routing)
  -> [Order|Product|User Service] -> Event Bus -> [Payment|Inventory|Notification Svc]
  -> Database per Service
```

### Step 8: Resilience Patterns
Circuit Breaker (5 consecutive 5xx, 30s half-open), Timeout (3s default), Retry (3x exponential with jitter), Bulkhead (10 concurrent per svc), Rate Limit (per tier), Fallback (cached/degraded).

### Step 9: Validation
Check: single bounded context per service, no shared databases, single team ownership, async where possible, circuit breakers on sync calls, saga for distributed transactions, health checks, independent deployability.

### Step 10: Artifacts & Commit
```
Artifacts: topology diagram, service catalog, communication contracts, saga definitions, mesh config
Commit: "micro: <system> -- <N> services, <pattern>, <saga type>"
Next: /godmode:api, /godmode:event, /godmode:k8s, /godmode:observe
```

## Key Behaviors
1. **Decompose by business capability, not technical layer.**
2. **Each service owns its data.** No shared databases.
3. **Default to async communication.** Sync creates temporal coupling.
4. **Every sync call needs a circuit breaker.** Fail fast, degrade gracefully.
5. **Sagas replace distributed transactions.** No distributed ACID.
6. **Start with a modular monolith.** Extract when boundaries are proven.
7. **Service mesh is infrastructure.** mTLS, observability, resilience in the mesh.
8. **One team per service.**

## Flags & Options

| Flag | Description |
|--|--|
| `--decompose` | Propose service decomposition |
| `--communication` | Design inter-service communication |
| `--saga <name>` | Design a specific saga workflow |
| `--mesh istio\|linkerd` | Generate service mesh config |
| `--validate` | Validate existing architecture |
| `--resilience` | Design resilience patterns |

## HARD RULES
1. NEVER share a database between services.
2. NEVER decompose by technical layer ("database service" is wrong).
3. NEVER skip modular monolith for greenfield projects.
4. EVERY sync call MUST have circuit breaker, timeout (3s), retry with backoff.
5. EVERY service MUST have health check and be independently deployable.
6. NEVER use distributed transactions (2PC). Use sagas.
7. EVERY event MUST include: event_id, type, version, timestamp, source, correlation_id, data.

## Auto-Detection
```
IF docker-compose with >2 services OR k8s deployments >2 OR istio/linkerd config
OR proto files OR @grpc/@nestjs/microservices/moleculer in package.json
  -> Suggest /godmode:micro
```

## Multi-Agent Dispatch
```
Agent 1 (service-design): Bounded contexts, entity ownership
Agent 2 (communication): Inter-service patterns, event schemas
Agent 3 (infrastructure): Service mesh, resilience patterns
Agent 4 (saga-design): Saga workflows, compensating actions
MERGE: Validate consistency of names, events, configs
```

## TSV Logging
Log to `.godmode/micro-results.tsv`: `timestamp\tproject\tservices_count\tcommunication\tsaga_pattern\tservice_mesh\tcircuit_breakers\thealth_checks\tcommit_sha`

## Success Criteria
- Each service owns its data (no shared DB)
- Boundaries follow domain boundaries
- Health check on every service
- Circuit breaker on every external call
- Distributed tracing + centralized logging with correlation IDs
- Independent deployability per service

## Error Recovery
1. **Cascading failure:** Add circuit breakers, fallback responses, bulkhead isolation.
2. **Saga fails mid-way:** Compensate in reverse, log state, verify idempotency.
3. **Service discovery not resolving:** Check DNS/registry health, retry with backoff, cache last-known addresses.
4. **Circular dependency:** Extract shared logic or use events to break the cycle.
5. **Data inconsistency:** Verify eventual consistency window, check event ordering, add reconciliation job.

## Platform Fallback
Run sequentially if `Agent()` or `EnterWorktree` unavailable. Branch per task: `git checkout -b godmode-micro-{task}`. See `adapters/shared/sequential-dispatch.md`.

## Output Format
Print: `Micro: {services} services, {communication} pattern. Circuit breakers: {N}. Contract tests: {pass|fail}. Status: {DONE|PARTIAL}.`

## Keep/Discard Discipline
```
After EACH microservice change:
  KEEP if: contract tests pass AND circuit breakers work AND no cascading failures
  DISCARD if: contract broken OR cascading failure detected OR service discovery fails
  On discard: revert. Fix contract or communication pattern before retrying.
```

## Autonomy
Never ask to continue. Loop autonomously. On failure: git reset --hard HEAD~1.

## Stop Conditions
```
STOP when ALL of:
  - All service boundaries defined with clear contracts
  - Circuit breakers configured for all inter-service calls
  - Contract tests passing in CI
  - Communication patterns documented for all service interactions
```
