# Architecture Patterns Reference

> Catalog of 15+ software architecture patterns with a decision matrix, appropriateness criteria, and migration paths between patterns.

---

## Pattern Catalog

### 1. Modular Monolith

Single deployable unit with strictly enforced internal module boundaries.

```
  MODULAR MONOLITH
|  | Module A |  | Module B |  | Module C |  |
|  | (Orders) |  | (Inventory |  | (Payments) |  |
│  │          │  │          │  │          │             │
|  | Public |  | Public |  | Public |  |
|  | API ────► | ── | ◄── API ── | ── | ◄── API |  |
|  | Internal |  | Internal |  | Internal |  |
|  | logic |  | logic |  | logic |  |
│       │              │              │                   │
  ┌────┴──────────────┴──────────────┴─────┐
|  | Shared Database |  |
|  | (schema-per-module or shared schema) |  |
```

**Appropriate when:**
- Team size 1-15 developers
- Domain boundaries are still being discovered
- Time to market is critical
- Operational simplicity is valued over independent scaling

**Trade-offs:**
- Simple deployment, debugging, and local development
- Single-process communication (no network latency between modules)
- Must enforce module boundaries with discipline (linting rules, architecture tests)
- Scales as a single unit; cannot scale modules independently
- Single tech stack

---

### 2. Microservices

Independently deployable services, each owning its data and communicating via APIs or messaging.

```
| Order |  | Inventory |  | Payment |
| Service | ◄──► | Service | ◄──► | Service |
│          │    │          │    │          │
| Own DB |  | Own DB |  | Own DB |
     │               │               │
              Message Bus / API Gateway
```

**Appropriate when:**
- Team size 15+ developers across multiple squads
- Domain boundaries are well-understood
- Independent deployment and scaling per service is needed
- Polyglot tech stack is beneficial

**Trade-offs:**
- Independent deployment, scaling, and technology choices
- Fault isolation — one service failure does not bring down the system
- Distributed system complexity (network, consistency, debugging)
- Operational overhead (monitoring, deployment, service discovery)
- Data consistency requires sagas or eventual consistency

---

### 3. Serverless / FaaS

Functions triggered by events, with fully managed infrastructure.

**Appropriate when:**
- Workload is bursty or unpredictable
- Cost optimization (pay-per-invocation) is a priority
- Team wants zero infrastructure management
- Event-driven workflows dominate

**Trade-offs:**
- Auto-scales to zero and to peak, pay only for usage
- Cold start latency (100ms-2s depending on runtime and provider)
- Vendor lock-in to cloud provider
- Execution duration limits (15 min on AWS Lambda)
- Difficult to test locally and debug in production

---

### 4. Event-Driven Architecture

Components communicate through asynchronous events via a message broker.

```
| Producer | ───► | Event Bus | ───► | Consumer |
|  |  | (Kafka / |  | A |
| Emits: |  | RabbitMQ / | ───► | Consumer |
| OrderPlaced | SNS+SQS) |  | B |
| OrderShipped |  | ───► | Consumer |
└──────────┘    └───────────────┘    │  C       │
```

**Appropriate when:**
- Loose coupling between components is essential
- Multiple consumers need to react to the same business events
- Audit trail or event sourcing is required
- Temporal decoupling (producer and consumer do not need to be online simultaneously)

**Trade-offs:**
- Extreme loose coupling; adding new consumers requires no producer changes
- Natural audit log if using event store
- Eventual consistency — not immediately consistent
- Event ordering and deduplication complexity
- Debugging event flows across services is challenging

---

### 5. CQRS (Command Query Responsibility Segregation)

Separate models for read and write operations.

```
┌───────────┐     Commands      ┌────────────────┐
| Client | ──────────────────► | Write Model |
|  |  | (Domain logic) |
|  |  | ┌────────────┐ |
|  |  |  | Event Store |  |
|  |  | └──────┬─────┘ |
│           │                   └─────────┼───────┘
│           │                             │ Events
│           │                             ▼
│           │                   ┌─────────────────┐
|  | Queries | Read Model |
|  | ◄────────────────── | (Projections) |
|  |  | Denormalized |
└───────────┘                   │  for fast reads │
```

**Appropriate when:**
- Read and write workloads differ drastically (100:1 read:write ratio)
- Complex queries need denormalized read models
- Event sourcing is used for the write side
- Read scalability must be independent of write scalability

**Trade-offs:**
- Read and write sides optimized independently
- Multiple read projections from the same event stream
- Eventual consistency between read and write models
- Significantly more complex than simple CRUD
- Overkill for applications with balanced read/write workloads

---

### 6. Hexagonal (Ports & Adapters)

Business logic at the center, all external concerns at the edges via well-defined ports and adapters.

```
  ADAPTERS (outer)
|  | REST |  | gRPC |  | Event |  |
|  | API |  | API |  | Consumer |  |
              │     │         │           │          │
  ┌──┴─────────┴───────────┴───────┐
|  | PORTS (interfaces) |  |
              │                 │                     │
  ┌──────────────┴──────────────────┐
|  | DOMAIN (business logic) |  |
|  | Pure, no dependencies on |  |
|  | infrastructure |  |
              │                 │                     │
  ┌──────────────┴──────────────────┐
|  | PORTS (interfaces) |  |
  └──┬─────────┬───────────┬───────┘
              │     │         │           │          │
  ┌──┴───┐  ┌─┴──────┐  ┌─┴───────┐
|  | Postgr |  | Redis |  | Kafka |  |
|  | es |  | Cache |  | Producer |  |
```

**Appropriate when:**
- Business logic is complex and must be insulated from infrastructure changes
- Multiple interfaces serve the same domain (API, CLI, events, jobs)
- Testability is a top priority
- Infrastructure may change (swap databases, message brokers)

**Trade-offs:**
- Domain logic fully decoupled from infrastructure
- Highly testable (mock adapters, test domain in isolation)
- Easy to swap infrastructure components
- More interfaces and boilerplate code
- Can feel over-engineered for simple CRUD applications

---

### 7. Layered (N-Tier)

Traditional horizontal layering with strict dependency direction.

```
│  Presentation Layer      │  ← UI, API controllers
│  Application Layer       │  ← Use cases, orchestration
│  Domain/Business Layer   │  ← Business rules, entities
│  Data Access Layer       │  ← Repositories, ORM
│  Infrastructure Layer    │  ← Database, file system, external APIs

Rule: Each layer only depends on the layer directly below it.
```

**Appropriate when:**
- Team is familiar with traditional enterprise patterns
- Application has clear horizontal boundaries
- Strict separation of concerns is the primary goal

**Trade-offs:**
- Well-understood, abundant documentation and examples
- Clear dependency direction
- Can lead to "pass-through" layers that add no value
- Cross-cutting concerns (logging, auth) are awkward to handle
- Changes often ripple through all layers

---

### 8. Clean Architecture

Concentric circles with dependency rule: dependencies point inward, domain at center.

```
  FRAMEWORKS & DRIVERS (outermost)
  Web frameworks, DB drivers, UI, external APIs
|  | INTERFACE ADAPTERS |  |
|  | Controllers, Presenters, Gateways |  |
│  │                                                    │ │
|  | ┌──────────────────────────────────────────────┐ |  |
|  |  | APPLICATION BUSINESS RULES |  |  |
|  |  | Use Cases |  |  |
│  │  │                                                │ │ │
|  |  | ┌──────────────────────────────────────────┐ |  |  |
|  |  |  | ENTERPRISE BUSINESS RULES |  |  |  |
|  |  |  | Entities, Value Objects |  |  |  |
|  |  | └──────────────────────────────────────────┘ |  |  |
|  | └──────────────────────────────────────────────┘ |  |
DEPENDENCY RULE: Source code dependencies point INWARD only.
Nothing in an inner circle can know about anything in an outer circle.
```

**Appropriate when:**
- Domain logic is the most valuable part of the system
- Long-lived systems where infrastructure will change
- Teams value testability and independence from frameworks

**Trade-offs:**
- Domain is fully framework-agnostic and testable
- Clear boundaries make reasoning about code easier
- More boilerplate (interfaces at every boundary)
- Steep learning curve for teams new to the pattern

---

### 9. Service Mesh

Infrastructure layer for service-to-service communication with sidecar proxies.

```
| Service A |  | Service B |
| ┌────────────┐ |  | ┌────────────┐ |
|  | App Logic |  |  |  | App Logic |  |
| └─────┬──────┘ |  | └─────┬──────┘ |
│        │         │       │        │         │
| ┌─────┴──────┐ | mTLS | ┌─────┴──────┐ |
|  | Sidecar | ◄─┼───────┼─► | Sidecar |  |
|  | Proxy |  |  |  | Proxy |  |
|  | (Envoy) |  |  |  | (Envoy) |  |
| └────────────┘ |  | └────────────┘ |
              ┌─────┴──────┐
  Control
  Plane
  (Istio /
  Linkerd)

Provides: mTLS, load balancing, circuit breaking,
          retries, observability, traffic splitting
```

**Appropriate when:**
- Microservices architecture at scale (20+ services)
- Consistent security (mTLS) between all services is required
- Need traffic management (canary, A/B, rate limiting) without code changes
- Observability across service communication is critical

**Trade-offs:**
- Cross-cutting concerns handled at infrastructure level
- No application code changes for mTLS, retries, circuit breaking
- Significant operational complexity
- Resource overhead (sidecar per pod)
- Debugging through proxy layer adds complexity

---

### 10. Micro Frontends

Extend microservice principles to the frontend.

```
  Shell / Container App
|  | Team A |  | Team B |  | Team C |  |
|  | Product List |  | Shopping Cart |  | User |  |
|  | (React) |  | (Vue) |  | Profile |  |
|  |  |  |  |  | (Svelte) |  |
  Integration: Module Federation / Web Components /
  iframes / server-side composition
```

**Appropriate when:**
- Multiple teams own different parts of the UI
- Teams need independent deployment of frontend features
- Different parts of the UI have different technical requirements
- Large-scale frontend with 10+ developers

**Trade-offs:**
- Team autonomy and independent deployments
- Technology diversity per micro frontend
- Integration complexity (shared state, routing, styling conflicts)
- Bundle size can grow (duplicate dependencies)
- User experience consistency is harder to maintain

---

### 11. Space-Based Architecture

Distribute processing and data across multiple nodes to eliminate central database bottleneck.

**Appropriate when:**
- Extreme scalability requirements (millions of concurrent users)
- Variable and unpredictable load
- Low-latency requirements for both reads and writes
- Can tolerate eventual consistency

**Trade-offs:**
- Near-linear horizontal scaling
- In-memory data grids eliminate database bottleneck
- Complex data replication and consistency management
- Expensive infrastructure (in-memory stores)
- Debugging distributed state is challenging

---

### 12. Pipe and Filter

Process data through a chain of independent, composable processing steps.

```
Input → [Filter A] → [Filter B] → [Filter C] → Output
         (validate)   (transform)   (enrich)

Examples:
  - ETL pipelines
  - Image processing (resize → watermark → compress → upload)
  - Log processing (parse → filter → aggregate → alert)
  - CI/CD pipelines (lint → test → build → deploy)
```

**Appropriate when:**
- Data flows through a series of transformations
- Steps are independent and reusable
- Processing can be parallelized across steps
- Each step has a single responsibility

**Trade-offs:**
- Steps are composable and reusable
- Easy to add, remove, or reorder steps
- Overhead from data transfer between steps
- Error handling across the pipeline requires careful design
- Not suited for interactive or request-response patterns

---

### 13. Strangler Fig (Migration Pattern)

Incrementally replace a legacy system by routing traffic to new implementations.

```
PHASE 1:                    PHASE 2:                    PHASE 3:
| Proxy |  | Proxy |  | Proxy |
     │                          │                          │
  100% legacy              /orders → new             100% new
  /rest → legacy
     ▼                          │                          ▼
┌──────────┐          ┌────────┴────────┐          ┌──────────┐
| Legacy |  | Legacy | New |  | New |
| System |  | System | Service |  | System |
└──────────┘          └────────┴────────┘          └──────────┘
```

**Appropriate when:**
- Migrating from a legacy system that cannot be replaced all at once
- Need to keep the system running during migration
- Different parts of the system can be migrated independently

**Trade-offs:**
- Zero downtime migration
- Risk is contained — roll back individual routes if needed
- Both systems must run simultaneously (infrastructure cost)
- Data synchronization between old and new systems is complex
- Can stall mid-migration if discipline is lost ("permanent strangler")

---

### 14. Sidecar / Ambassador / Adapter

Decompose cross-cutting functionality into companion processes.

```
SIDECAR:                 AMBASSADOR:              ADAPTER:
App + helper process     App + proxy to           App + format translator
                         external services

| ┌─────┐ ┌─────┐ |  | ┌─────┐ ┌─────┐ |  | ┌─────┐ ┌─────┐ |
|  | App |  | Log |  |  |  | App |  | Proxy |  |  |  | App |  | Adapt |  |
|  |  |  | Agent |  |  |  |  |  |  |  |  |  |  |  | er |  |
| └─────┘ └─────┘ |  | └─────┘ └──┬──┘ |  | └─────┘ └──┬──┘ |
| Pod |  | Pod |  |  | Pod |  |
└─────────────────┘     └────────────┼───┘     └────────────┼───┘
                                     ▼                      ▼
                              External APIs          Legacy System
                              (retry, auth,          (protocol
                               circuit break)         translation)
```

**Appropriate when:**
- Sidecar: logging, monitoring, configuration, networking concerns
- Ambassador: external service communication (retries, auth, circuit breaking)
- Adapter: integrating with legacy systems or different protocols

---

### 15. Cell-Based Architecture

Isolate groups of functionality into independent, self-contained cells for blast radius containment.

```
| Cell A |  | Cell B |  | Cell C |
| (US-East) |  | (US-West) |  | (EU) |
│                 │  │                 │  │                 │
| ┌───┐ ┌───┐ |  | ┌───┐ ┌───┐ |  | ┌───┐ ┌───┐ |
|  | API |  | DB |  |  |  | API |  | DB |  |  |  | API |  | DB |  |
| └───┘ └───┘ |  | └───┘ └───┘ |  | └───┘ └───┘ |
| ┌───┐ ┌───┐ |  | ┌───┐ ┌───┐ |  | ┌───┐ ┌───┐ |
|  | Q |  | $ |  |  |  | Q |  | $ |  |  |  | Q |  | $ |  |
| └───┘ └───┘ |  | └───┘ └───┘ |  | └───┘ └───┘ |
        │                    │                    │
                    Cell Router
           (routes users to their assigned cell)
```

**Appropriate when:**
- Blast radius containment is critical (outage should not affect all users)
- Multi-region or multi-tenant isolation requirements
- Regulatory requirements for data residency
- Scale beyond what a single deployment can handle

**Trade-offs:**
- Failure in one cell does not affect other cells
- Data residency compliance per cell
- Complex routing logic (user-to-cell mapping)
- Cross-cell operations are difficult (user migration, global queries)
- Infrastructure multiplication (each cell is a full stack)

---

### 16. Vertical Slice Architecture

Organize code by feature rather than by technical layer. Each slice contains all layers for a single feature.

```
TRADITIONAL LAYERED:              VERTICAL SLICE:
| Controllers |  | Feat. |  | Feat. |  | Feat. |
├──────────────────┤              │  A  │ │  B  │ │  C  │
| Services |  |  |  |  |  |  |
├──────────────────┤     →        │Ctrl │ │Ctrl │ │Ctrl │
| Repositories |  | Svc |  | Svc |  | Svc |
├──────────────────┤              │Repo │ │Repo │ │Repo │
| Entities |  | Model |  | Model |  | Model |
```

**Appropriate when:**
- Features are relatively independent of each other
- Team wants to minimize cross-feature coupling
- Easy to understand all code for a single feature in one place
- CQRS or Mediator pattern is in use

**Trade-offs:**
- Easy to reason about a single feature end-to-end
- Changes to one feature do not affect others
- Code duplication across slices if not managed
- Shared infrastructure must still be factored out

---

## Architecture Decision Matrix

Use this matrix to select an architecture based on your constraints.

```
| Criterion | Mod. | Micro- | Server- | Event- | CQRS | Hexag. | Clean |
|  | Monolith | services | less | Driven |  |  | Arch. |
| Team size <10 | ★★★★★ | ★★☆☆☆ | ★★★★☆ | ★★★☆☆ | ★★☆☆☆ | ★★★★☆ | ★★★★☆ |
| Team size 10-30 | ★★★☆☆ | ★★★★☆ | ★★★☆☆ | ★★★★☆ | ★★★★☆ | ★★★★☆ | ★★★★☆ |
| Team size 30+ | ★★☆☆☆ | ★★★★★ | ★★★☆☆ | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★☆☆ |
| Time to market | ★★★★★ | ★★☆☆☆ | ★★★★☆ | ★★☆☆☆ | ★★☆☆☆ | ★★★☆☆ | ★★★☆☆ |
| Scalability | ★★★☆☆ | ★★★★★ | ★★★★★ | ★★★★★ | ★★★★★ | ★★★☆☆ | ★★★☆☆ |
| Operational cost | ★★★★★ | ★★☆☆☆ | ★★★★☆ | ★★☆☆☆ | ★★☆☆☆ | ★★★★☆ | ★★★★☆ |
| Testability | ★★★☆☆ | ★★★★☆ | ★★☆☆☆ | ★★★☆☆ | ★★★★☆ | ★★★★★ | ★★★★★ |
| Domain complexity | ★★★☆☆ | ★★★★☆ | ★★☆☆☆ | ★★★★☆ | ★★★★★ | ★★★★★ | ★★★★★ |
| Data consistency | ★★★★★ | ★★☆☆☆ | ★★★☆☆ | ★★☆☆☆ | ★★☆☆☆ | ★★★★★ | ★★★★★ |
| Fault isolation | ★★☆☆☆ | ★★★★★ | ★★★★★ | ★★★★☆ | ★★★★☆ | ★★☆☆☆ | ★★☆☆☆ |
| Learning curve | ★★★★★ | ★★☆☆☆ | ★★★☆☆ | ★★☆☆☆ | ★★☆☆☆ | ★★★☆☆ | ★★★☆☆ |

READING GUIDE:
  ★★★★★ = Excellent fit for this criterion
  ★☆☆☆☆ = Poor fit for this criterion
```

### Quick Decision Guide

```
START HERE:

  Team size?
  ├── 1-8 developers
  └── Domain complexity?
  ├── Simple CRUD → Modular Monolith
  ├── Complex domain → Modular Monolith + Hexagonal
  └── Bursty workload → Serverless
  ├── 8-20 developers
  └── Domain boundaries clear?
  ├── Yes → Start extracting key services (2-5 services)
  ├── No → Modular Monolith (discover boundaries first)
  └── Read-heavy → CQRS within monolith
  └── 20+ developers (multiple squads)
      └── Microservices, with:
          ├── Event-driven for async communication
          ├── CQRS for read-heavy services
          ├── Service mesh for cross-cutting concerns
          └── Cell-based for blast radius at scale
```

---

## Migration Paths Between Patterns

### Modular Monolith → Microservices (Strangler Fig)

```
MIGRATION STRATEGY:
Phase 1: Enforce module boundaries in the monolith
  - Each module has a public API (interface/facade)
  - No direct database access across modules
  - Modules communicate through internal APIs or events
  Duration: 1-3 months

Phase 2: Extract the first service
  - Choose the module with clearest boundary and highest independence
  - Deploy it as a separate service behind the API gateway
  - Route traffic to new service via strangler proxy
  - Keep monolith module as fallback
  Duration: 1-2 months per service

Phase 3: Extract remaining services incrementally
  - One module at a time, ordered by business value / independence
  - Introduce event bus for cross-service communication
  - Migrate data ownership (hardest part)
  Duration: 2-6 months per service

Phase 4: Decommission the monolith
  - All modules extracted
  - Remove proxy routes to monolith
  - Shut down monolith
  Duration: 1 month

TOTAL: 6-24 months depending on system size

RISKS:
- Data migration between shared database and per-service databases
- Distributed transactions (convert to sagas)
- Performance regression (network calls replace in-process calls)
- Stalling mid-migration (keep momentum, set deadlines per module)
```

### Monolith → Serverless

```
MIGRATION STRATEGY:
Phase 1: Identify stateless, event-driven operations
  - Background jobs, scheduled tasks, webhooks
  - Extract to Lambda/Cloud Functions first (low risk)

Phase 2: Extract API endpoints
  - Move individual endpoints to functions behind API Gateway
  - Use strangler pattern to route gradually

Phase 3: Decompose state
  - Move from relational DB to managed services (DynamoDB, S3)
  - Convert synchronous workflows to event-driven (Step Functions, EventBridge)

RISKS:
- Cold start latency for latency-sensitive paths
- Vendor lock-in increases with each AWS/GCP-specific service
- Cost can exceed monolith at sustained high traffic
```

### Layered → Hexagonal

```
MIGRATION STRATEGY (in-place refactoring):
Phase 1: Define ports (interfaces)
  - Create interfaces for all external dependencies
  - Repository interfaces, message broker interfaces, external API interfaces

Phase 2: Invert dependencies
  - Domain layer defines interfaces
  - Infrastructure layer implements them
  - Wire via dependency injection

Phase 3: Reorganize directory structure
  - FROM: controllers/ services/ repositories/ models/
  - TO:   domain/ application/ infrastructure/ adapters/

Phase 4: Remove framework dependencies from domain
  - No ORM annotations in domain entities
  - No HTTP framework imports in domain logic
  - Pure domain objects with business rules

DURATION: 2-8 weeks for a medium codebase
RISK: Low (refactoring, no infrastructure changes)
```

### Microservices → Cell-Based

```
MIGRATION STRATEGY:
Phase 1: Identify cell boundaries
  - Group services by user affinity (geography, tenant, account)
  - Define what constitutes a "complete cell" (all services + data stores)

Phase 2: Create cell template
  - Infrastructure-as-code for a complete cell deployment
  - Each cell is a self-contained copy of the full stack

Phase 3: Implement cell routing
  - Build cell router that maps users to cells
  - Hash-based or configuration-based assignment

Phase 4: Deploy additional cells
  - Start with 2 cells (canary)
  - Gradually migrate users to cell-based routing
  - Add cells when traffic or isolation requirements demand it

RISKS:
- Cross-cell queries (global reports, admin views)
- User migration between cells
- Keeping cell deployments in sync (version drift)
```

### CQRS Addition to Existing Architecture

```
MIGRATION STRATEGY (additive, any base architecture):
Phase 1: Identify read-heavy endpoints
  - Dashboard queries, search, reporting
  - Endpoints hitting the database with complex JOINs

Phase 2: Create read models
  - Denormalized tables/views optimized for specific queries
  - Populate via database triggers, CDC, or application events

Phase 3: Route reads to read models
  - Query endpoints read from denormalized store
  - Write endpoints continue using the existing model

Phase 4: (Optional) Add event sourcing to write side
  - Store events instead of current state
  - Build read models as projections of events

RISKS:
- Consistency lag between write and read models
- Maintaining synchronization logic
- Monitoring for read model staleness
```

---

## Pattern Compatibility Matrix

Which patterns combine well together?

```
| Combines with | Micro- | Event- | CQRS | Hexag. | Service |
|  | services | Driven |  |  | Mesh |
| Microservices | — | ★★★★★ | ★★★★☆ | ★★★★★ | ★★★★★ |
| Event-Driven | ★★★★★ | — | ★★★★★ | ★★★★☆ | ★★★☆☆ |
| CQRS | ★★★★☆ | ★★★★★ | — | ★★★★☆ | ★★☆☆☆ |
| Hexagonal | ★★★★★ | ★★★★☆ | ★★★★☆ | — | ★★★☆☆ |
| Service Mesh | ★★★★★ | ★★★☆☆ | ★★☆☆☆ | ★★★☆☆ | — |
| Serverless | ★★★☆☆ | ★★★★★ | ★★★☆☆ | ★★☆☆☆ | ☆☆☆☆☆ |
| Mod. Monolith | ☆☆☆☆☆ | ★★★☆☆ | ★★★★☆ | ★★★★★ | ☆☆☆☆☆ |
| Strangler Fig | ★★★★★ | ★★★★☆ | ★★★☆☆ | ★★★☆☆ | ★★★★☆ |
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Better Approach |
|---|---|---|
| Distributed monolith | Microservices that must be deployed together | Enforce service independence, async communication |
| Big bang rewrite | Replacing entire system at once | Strangler fig migration, incremental extraction |
| Resume-driven architecture | Choosing tech for career advancement | Choose based on team skills and requirements |
| Golden hammer | Using one pattern for everything | Match pattern to problem; different parts of the system may need different patterns |
| Premature optimization | Microservices for a 3-person team | Start with modular monolith, extract when needed |
| Shared database | Multiple services sharing one database | Each service owns its data, communicate via APIs/events |
| Ignoring Conway's Law | Architecture does not match team structure | Align service boundaries with team boundaries |
| Architecture astronaut | Over-engineering with patterns that add no value | Start simple, add complexity only when justified by real problems |
