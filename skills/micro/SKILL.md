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
- When building a new distributed system or migrating from a monolith
- When `/godmode:plan` identifies microservice decomposition tasks
- When `/godmode:review` flags tight coupling or service boundary issues

## Workflow

### Step 1: System Context & Current State Assessment
Understand the existing architecture before decomposing anything:

```
SYSTEM CONTEXT:
Project: <name and purpose>
Current Architecture: Monolith | Modular Monolith | Microservices (partial) | Greenfield
Team Structure: <number of teams, ownership model>
Scale Requirements: <expected request volume, data volume, growth projections>
Deployment Cadence: <how often teams need to deploy independently>
Data Stores: <databases, caches, message brokers currently in use>
Constraints: <latency SLAs, compliance requirements, team skill level>
Pain Points: <what is driving the need for microservices>
```

If the user has not provided context, ask: "What is the current architecture, and what problem are we solving with microservices? Not every system needs microservices."

### Step 2: Service Decomposition Strategy
Identify bounded contexts and define service boundaries:

#### Domain-Driven Decomposition
```
BOUNDED CONTEXT MAP:
+---------------------------------------------------------------+
|  Context: <Name>                                               |
|  Description: <what business capability it owns>               |
|  Core entities: <list of domain entities>                      |
|  Commands: <list of state-changing operations>                 |
|  Queries: <list of read operations>                            |
|  Events published: <list of domain events emitted>             |
|  Events consumed: <list of domain events subscribed to>        |
|  Data ownership: <what data this context exclusively owns>     |
|  Team: <owning team>                                           |
+---------------------------------------------------------------+

CONTEXT RELATIONSHIPS:
+---------------------+          +---------------------+
|  Order Context      | -------> |  Payment Context    |
|  (upstream)         | publishes|  (downstream)       |
|                     | OrderPlaced                     |
+---------------------+          +---------------------+
        |                                |
        | publishes                      | publishes
        | OrderShipped                   | PaymentCompleted
        v                                v
+---------------------+          +---------------------+
|  Shipping Context   |          |  Notification       |
|  (downstream)       |          |  Context            |
+---------------------+          +---------------------+
```

#### Decomposition Decision Framework
```
DECOMPOSITION CRITERIA:
+--------------------------------------------------------------+
|  Criterion                    | Weight | Score (1-5) | Notes  |
+--------------------------------------------------------------+
|  Business domain boundary     | HIGH   | <score>     |        |
|  Independent deployment need  | HIGH   | <score>     |        |
|  Different scaling needs      | MEDIUM | <score>     |        |
|  Different technology needs   | MEDIUM | <score>     |        |
|  Data ownership clarity       | HIGH   | <score>     |        |
|  Team ownership alignment     | HIGH   | <score>     |        |
|  Transactional boundary       | HIGH   | <score>     |        |
|  Change frequency difference  | MEDIUM | <score>     |        |
+--------------------------------------------------------------+

DECOMPOSITION VERDICT: <SPLIT | KEEP TOGETHER | DEFER>
Rationale: <why this boundary makes sense or does not>
```

Rules:
- Decompose along business capabilities, not technical layers
- Each service owns its data exclusively -- no shared databases
- If two services need strong transactional consistency, they probably belong together
- A microservice should be owned by a single team
- If you cannot name the bounded context, the boundary is wrong

### Step 3: Inter-Service Communication Design
Choose the right communication pattern for each service interaction:

#### Synchronous Communication (Request-Response)

**REST (HTTP/JSON)**
```
USE WHEN:
- Simple CRUD operations across services
- Client needs an immediate response
- Low-to-medium throughput requirements
- External-facing APIs

DESIGN:
+-------------------+     HTTP/JSON      +-------------------+
|  Order Service    | -----------------> |  Product Service  |
|                   | GET /products/:id  |                   |
|                   | <-- 200 + body     |                   |
+-------------------+                    +-------------------+

RESILIENCE:
- Circuit breaker: Open after 5 consecutive failures
- Timeout: 3s (never wait forever)
- Retry: 3 attempts with exponential backoff (100ms, 400ms, 1600ms)
- Fallback: Return cached data or degraded response
- Bulkhead: Isolate thread pools per downstream service
```

**gRPC (HTTP/2 + Protobuf)**
```
USE WHEN:
- High-throughput internal communication (10k+ RPS)
- Low-latency requirements (sub-10ms)
- Streaming data (server-push, bidirectional)
- Polyglot services needing strong type contracts

DESIGN:
+-------------------+     gRPC/Protobuf  +-------------------+
|  API Gateway      | -----------------> |  User Service     |
|                   | GetUser(id)        |                   |
|                   | <-- UserResponse   |                   |
+-------------------+                    +-------------------+

PROTO DEFINITION:
syntax = "proto3";

service UserService {
  rpc GetUser(GetUserRequest) returns (UserResponse);
  rpc ListUsers(ListUsersRequest) returns (stream UserResponse);
  rpc CreateUser(CreateUserRequest) returns (UserResponse);
  rpc UpdateUser(UpdateUserRequest) returns (UserResponse);
  rpc DeleteUser(DeleteUserRequest) returns (google.protobuf.Empty);
}

message GetUserRequest {
  string id = 1;
}

message UserResponse {
  string id = 1;
  string email = 2;
  string name = 3;
  google.protobuf.Timestamp created_at = 4;
}

RESILIENCE:
- Deadline propagation: Set deadlines, not timeouts
- Retry policy: Retry on UNAVAILABLE with backoff
- Load balancing: Client-side round-robin or weighted
- Health checking: gRPC health checking protocol
```

#### Asynchronous Communication (Event-Driven)

**Event/Message-Based**
```
USE WHEN:
- Eventual consistency is acceptable
- Decoupling producers from consumers
- Fan-out to multiple consumers
- Long-running processes
- Cross-service data synchronization

DESIGN:
+-------------------+     Event Bus      +-------------------+
|  Order Service    | -- OrderPlaced --> |  Inventory Service|
|                   |                    |  Payment Service  |
|                   |                    |  Notification Svc |
+-------------------+                    +-------------------+

EVENT FORMAT:
{
  "event_id": "evt-uuid-here",
  "event_type": "order.placed",
  "version": "1.0",
  "timestamp": "2025-01-15T10:30:45.123Z",
  "source": "order-service",
  "correlation_id": "req-uuid-here",
  "data": {
    "order_id": "ord-123",
    "customer_id": "cust-456",
    "total_amount": 99.99,
    "items": [...]
  }
}

BROKER OPTIONS:
- Kafka: High-throughput, ordered, persistent, replay
- RabbitMQ: Flexible routing, low-latency, mature
- SQS/SNS: AWS-native, serverless, managed
- NATS: Ultra-low latency, lightweight, cloud-native
```

#### Communication Pattern Decision Matrix
```
COMMUNICATION DECISION:
+--------------------------------------------------------------+
|  Scenario                          | Pattern    | Protocol    |
+--------------------------------------------------------------+
|  Need immediate response           | Sync       | REST/gRPC   |
|  Fire-and-forget notification      | Async      | Events      |
|  Fan-out to multiple consumers     | Async      | Pub/Sub     |
|  Long-running workflow             | Async      | Saga/Events |
|  High-throughput internal calls    | Sync       | gRPC        |
|  External API exposure             | Sync       | REST        |
|  Data replication across services  | Async      | CDC/Events  |
|  Request with async processing     | Hybrid     | REST + Event|
+--------------------------------------------------------------+
```

### Step 4: Service Mesh Configuration
Configure the data plane and control plane for service-to-service communication:

#### Istio Configuration
```yaml
# VirtualService: Traffic routing and splitting
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: order-service
spec:
  hosts:
    - order-service
  http:
    - match:
        - headers:
            x-canary:
              exact: "true"
      route:
        - destination:
            host: order-service
            subset: canary
          weight: 100
    - route:
        - destination:
            host: order-service
            subset: stable
          weight: 95
        - destination:
            host: order-service
            subset: canary
          weight: 5

---
# DestinationRule: Load balancing and circuit breaking
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: order-service
spec:
  host: order-service
  trafficPolicy:
    connectionPool:
      tcp:
        maxConnections: 100
      http:
        h2UpgradePolicy: DEFAULT
        http1MaxPendingRequests: 100
        http2MaxRequests: 1000
    outlierDetection:
      consecutive5xxErrors: 5
      interval: 30s
      baseEjectionTime: 30s
      maxEjectionPercent: 50
    loadBalancer:
      simple: LEAST_REQUEST
  subsets:
    - name: stable
      labels:
        version: v1
    - name: canary
      labels:
        version: v2

---
# PeerAuthentication: Mutual TLS
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: <namespace>
spec:
  mtls:
    mode: STRICT

---
# AuthorizationPolicy: Service-to-service access control
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: order-service-policy
spec:
  selector:
    matchLabels:
      app: order-service
  rules:
    - from:
        - source:
            principals: ["cluster.local/ns/<ns>/sa/api-gateway"]
      to:
        - operation:
            methods: ["GET", "POST"]
            paths: ["/api/v1/orders*"]
```

#### Linkerd Configuration
```yaml
# ServiceProfile: Retry and timeout policies
apiVersion: linkerd.io/v1alpha2
kind: ServiceProfile
metadata:
  name: order-service.<namespace>.svc.cluster.local
  namespace: <namespace>
spec:
  routes:
    - name: GET /api/v1/orders
      condition:
        method: GET
        pathRegex: /api/v1/orders
      isRetryable: true
      timeout: 3s
    - name: POST /api/v1/orders
      condition:
        method: POST
        pathRegex: /api/v1/orders
      isRetryable: false
      timeout: 5s

---
# TrafficSplit: Canary deployment
apiVersion: split.smi-spec.io/v1alpha1
kind: TrafficSplit
metadata:
  name: order-service
  namespace: <namespace>
spec:
  service: order-service
  backends:
    - service: order-service-stable
      weight: 950
    - service: order-service-canary
      weight: 50
```

#### Service Mesh Comparison
```
SERVICE MESH SELECTION:
+--------------------------------------------------------------+
|  Feature              | Istio          | Linkerd              |
+--------------------------------------------------------------+
|  Complexity           | High           | Low                  |
|  Resource overhead    | Higher (~128Mi)| Lower (~64Mi)        |
|  mTLS                 | Built-in       | Built-in             |
|  Traffic splitting    | VirtualService | TrafficSplit (SMI)   |
|  Observability        | Kiali, Jaeger  | Dashboard, tap       |
|  Multi-cluster        | Yes            | Yes                  |
|  Learning curve       | Steep          | Gentle               |
|  Extensibility        | WASM, EnvoyFil.| Limited              |
|  Best for             | Complex routing| Simple, lightweight  |
+--------------------------------------------------------------+

RECOMMENDATION:
- Start with Linkerd if: simple mTLS + observability needed
- Choose Istio if: advanced traffic management, multi-cluster, WASM
```

### Step 5: Service Discovery & Load Balancing
Configure how services find and communicate with each other:

```
SERVICE DISCOVERY PATTERNS:
+--------------------------------------------------------------+
|  Pattern              | Implementation        | Best For       |
+--------------------------------------------------------------+
|  DNS-based (K8s)      | CoreDNS + Services    | K8s-native     |
|  Client-side          | Eureka, Consul SDK    | JVM, polyglot  |
|  Server-side          | K8s Service, ALB      | Cloud-native   |
|  Service mesh         | Istio/Linkerd sidecar | Zero-code      |
+--------------------------------------------------------------+

KUBERNETES SERVICE DISCOVERY:
Service DNS:  <service-name>.<namespace>.svc.cluster.local
Short form:   <service-name>.<namespace>
Same namespace: <service-name>

Example:
  Order Service -> http://product-service.catalog.svc.cluster.local:8080/api/v1/products
  Same namespace: http://product-service:8080/api/v1/products
```

#### Load Balancing Strategies
```
LOAD BALANCING:
+--------------------------------------------------------------+
|  Strategy        | How it works             | Best for         |
+--------------------------------------------------------------+
|  Round Robin     | Sequential distribution  | Homogeneous pods |
|  Least Request   | Route to least-busy pod  | Variable latency |
|  Random          | Random selection         | Large clusters   |
|  Consistent Hash | Same client -> same pod  | Sticky sessions  |
|  Weighted        | Distribute by weight     | Canary/migration |
+--------------------------------------------------------------+

IMPLEMENTATION (Istio):
trafficPolicy:
  loadBalancer:
    simple: LEAST_REQUEST    # or ROUND_ROBIN, RANDOM, PASSTHROUGH

IMPLEMENTATION (K8s native):
# K8s Services default to round-robin via kube-proxy/iptables
# For session affinity:
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

### Step 6: Distributed Transaction Management (Saga Pattern)
Manage data consistency across service boundaries without distributed locks:

#### Choreography-Based Saga (Event-Driven)
```
SAGA: Order Processing (Choreography)

1. Order Service        -> publishes OrderCreated
2. Payment Service      -> consumes OrderCreated
                        -> processes payment
                        -> publishes PaymentCompleted | PaymentFailed
3. Inventory Service    -> consumes PaymentCompleted
                        -> reserves stock
                        -> publishes StockReserved | StockInsufficient
4. Shipping Service     -> consumes StockReserved
                        -> schedules shipment
                        -> publishes ShipmentScheduled

COMPENSATION (on failure):
PaymentFailed       -> Order Service cancels order
StockInsufficient   -> Payment Service refunds payment
                    -> Order Service cancels order
ShipmentFailed      -> Inventory Service releases stock
                    -> Payment Service refunds payment
                    -> Order Service cancels order

SAGA FLOW:
OrderCreated -> PaymentCompleted -> StockReserved -> ShipmentScheduled
     |                |                  |                  |
     v                v                  v                  v
OrderCancelled  PaymentRefunded   StockReleased    ShipmentCancelled
  (compensate)    (compensate)     (compensate)      (compensate)
```

#### Orchestration-Based Saga (Central Coordinator)
```
SAGA: Order Processing (Orchestration)

Saga Orchestrator (Order Saga):
  Step 1: CreateOrder       -> Order Service
  Step 2: ProcessPayment    -> Payment Service
  Step 3: ReserveStock      -> Inventory Service
  Step 4: ScheduleShipment  -> Shipping Service

  On failure at Step N:
    Compensate Step N-1, N-2, ..., Step 1 (reverse order)

ORCHESTRATOR STATE MACHINE:
+----------+     +----------+     +----------+     +----------+
|  ORDER   | --> | PAYMENT  | --> |  STOCK   | --> | SHIPPING |
|  PENDING |     | PENDING  |     | PENDING  |     | PENDING  |
+----------+     +----------+     +----------+     +----------+
     |                |                |                |
     v                v                v                v
+----------+     +----------+     +----------+     +----------+
|  ORDER   |     | PAYMENT  |     |  STOCK   |     | SHIPPING |
|  CREATED |     | COMPLETED|     | RESERVED |     | SCHEDULED|
+----------+     +----------+     +----------+     +----------+
                      |                |                |
                      v                v                v
                +----------+     +----------+     +----------+
                | PAYMENT  |     |  STOCK   |     | SHIPPING |
                | REFUNDED |     | RELEASED |     | CANCELLED|
                +----------+     +----------+     +----------+
                (compensate)     (compensate)     (compensate)
```

#### Saga Pattern Selection
```
SAGA SELECTION:
+--------------------------------------------------------------+
|  Factor              | Choreography       | Orchestration      |
+--------------------------------------------------------------+
|  Complexity          | Low (few services) | High (many steps)  |
|  Coupling            | Loose              | Central coordinator|
|  Visibility          | Hard to trace      | Easy to trace      |
|  Single point failure| No                 | Orchestrator       |
|  Best for            | 2-4 services       | 5+ services        |
|  Error handling      | Each service       | Centralized        |
|  Testing             | Integration-heavy  | Unit-testable      |
+--------------------------------------------------------------+

SELECTED: <Choreography | Orchestration> -- <justification>
```

#### Saga Implementation Guidelines
```
SAGA RULES:
1. Every step MUST have a compensating action
2. Compensating actions MUST be idempotent
3. Saga state MUST be persisted (survive restarts)
4. Use correlation IDs to track saga instances
5. Set timeouts on each step (detect hung sagas)
6. Log every state transition for debugging
7. Dead letter failed sagas for manual review

SAGA STATE TABLE:
CREATE TABLE saga_instances (
  saga_id         UUID PRIMARY KEY,
  saga_type       VARCHAR(100) NOT NULL,
  correlation_id  UUID NOT NULL,
  current_step    VARCHAR(100) NOT NULL,
  status          VARCHAR(20) NOT NULL,  -- RUNNING, COMPLETED, COMPENSATING, FAILED
  payload         JSONB NOT NULL,
  created_at      TIMESTAMP NOT NULL,
  updated_at      TIMESTAMP NOT NULL,
  completed_at    TIMESTAMP,
  error           TEXT
);

CREATE TABLE saga_step_log (
  id              UUID PRIMARY KEY,
  saga_id         UUID REFERENCES saga_instances(saga_id),
  step_name       VARCHAR(100) NOT NULL,
  action          VARCHAR(20) NOT NULL,  -- EXECUTE, COMPENSATE
  status          VARCHAR(20) NOT NULL,  -- PENDING, SUCCESS, FAILED
  request         JSONB,
  response        JSONB,
  executed_at     TIMESTAMP NOT NULL,
  duration_ms     INTEGER
);
```

### Step 7: Service Topology & Architecture Diagram
Generate the microservice topology:

```
SERVICE TOPOLOGY:
+---------------------------------------------------------------+
|  External Clients (Web, Mobile, Third-Party)                   |
+---------------------------------------------------------------+
                          |
                    [API Gateway]
                    (rate limiting, auth, routing)
                          |
          +---------------+---------------+
          |               |               |
    [Order Service] [Product Service] [User Service]
          |               |               |
          +-------+-------+               |
                  |                        |
            [Event Bus / Message Broker]   |
            (Kafka / RabbitMQ / NATS)     |
                  |                        |
    +-------------+-------------+          |
    |             |             |          |
[Payment Svc] [Inventory Svc] [Notification Svc]
    |             |
    +------+------+
           |
    [Database per Service]
    Order DB | Product DB | User DB | Payment DB | Inventory DB
+---------------------------------------------------------------+

SERVICE REGISTRY:
+--------------------------------------------------------------+
|  Service            | Port  | Protocol | Owner    | SLA       |
+--------------------------------------------------------------+
|  api-gateway        | 8080  | REST     | Platform | 99.99%    |
|  order-service      | 8081  | gRPC     | Orders   | 99.9%     |
|  product-service    | 8082  | gRPC     | Catalog  | 99.9%     |
|  user-service       | 8083  | gRPC     | Identity | 99.95%    |
|  payment-service    | 8084  | gRPC     | Payments | 99.99%    |
|  inventory-service  | 8085  | gRPC     | Supply   | 99.9%     |
|  notification-svc   | 8086  | Async    | Comms    | 99.5%     |
+--------------------------------------------------------------+
```

### Step 8: Resilience Patterns
Configure fault tolerance across the service mesh:

```
RESILIENCE CONFIGURATION:
+--------------------------------------------------------------+
|  Pattern           | Config                | Service           |
+--------------------------------------------------------------+
|  Circuit Breaker   | 5 consecutive 5xx     | All downstream    |
|                    | 30s half-open         | calls             |
|  Timeout           | 3s default            | Sync calls        |
|                    | 30s for batch ops     |                   |
|  Retry             | 3 attempts            | Idempotent ops    |
|                    | Exponential backoff   | GET, PUT, DELETE  |
|                    | Jitter: 0-500ms       |                   |
|  Bulkhead          | 10 concurrent per svc | All services      |
|  Rate Limit        | Per service tier      | API Gateway       |
|  Fallback          | Cached/degraded       | Non-critical data |
+--------------------------------------------------------------+
```

### Step 9: Validation
Validate the microservice architecture against best practices:

```
ARCHITECTURE VALIDATION:
+--------------------------------------------------------------+
|  Check                                    | Status             |
+--------------------------------------------------------------+
|  Each service has a single bounded context| PASS | FAIL        |
|  No shared databases between services     | PASS | FAIL        |
|  Service ownership mapped to teams        | PASS | FAIL        |
|  Async communication where possible       | PASS | FAIL        |
|  Circuit breakers on all sync calls       | PASS | FAIL        |
|  Timeouts on all external calls           | PASS | FAIL        |
|  Saga pattern for distributed transactions| PASS | FAIL        |
|  Service mesh or equivalent configured    | PASS | FAIL        |
|  Health checks on every service           | PASS | FAIL        |
|  Independent deployability verified       | PASS | FAIL        |
|  Data ownership clearly defined           | PASS | FAIL        |
|  API contracts defined between services   | PASS | FAIL        |
|  Observability on all services            | PASS | FAIL        |
|  Resilience patterns applied              | PASS | FAIL        |
+--------------------------------------------------------------+

VERDICT: <PASS | NEEDS REVISION>
```

### Step 10: Artifacts & Commit
Generate the deliverables:

```
MICROSERVICE DESIGN COMPLETE:

Artifacts:
- Architecture diagram: docs/architecture/<system>-topology.md
- Service catalog: docs/architecture/<system>-services.md
- Communication contracts: docs/architecture/<system>-communication.md
- Saga definitions: docs/architecture/<system>-sagas.md
- Service mesh config: k8s/mesh/ or infra/mesh/
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:api -- Design the API for each service
-> /godmode:event -- Design the event-driven communication layer
-> /godmode:contract -- Define inter-service contracts
-> /godmode:k8s -- Deploy services to Kubernetes
-> /godmode:observe -- Instrument observability across services
```

Commit: `"micro: <system> -- <N> services, <communication pattern>, <saga type>"`

## Key Behaviors

1. **Decompose by business capability, not by technical layer.** A "database service" or "validation service" is not a microservice. An "order service" or "payment service" is.
2. **Each service owns its data.** No shared databases. Period. If two services need the same data, one owns it and the other gets it via API or events.
3. **Default to asynchronous communication.** Synchronous calls create temporal coupling. Use events unless the caller genuinely needs an immediate response.
4. **Every sync call needs a circuit breaker.** One slow downstream service should not take down the entire system. Fail fast, degrade gracefully.
5. **Sagas replace distributed transactions.** There is no distributed ACID across microservices. Use sagas with compensating actions.
6. **Start with a modular monolith.** If you are building from scratch, build a well-structured monolith first. Extract services when you have clear boundaries and team scaling needs.
7. **Service mesh is infrastructure, not optional.** mTLS, observability, traffic management, and resilience patterns belong in the mesh, not in application code.
8. **One team per service.** If a service requires coordination across multiple teams to deploy, the boundary is wrong.

## Example Usage

### Decomposing a monolith into microservices
```
User: /godmode:micro Decompose our e-commerce monolith

Micro: Analyzing current architecture...

SYSTEM CONTEXT:
  Architecture: Monolith (Rails, 180k LOC)
  Teams: 4 (Orders, Catalog, Payments, Platform)
  Pain points: Deploy conflicts, scaling bottlenecks on checkout

BOUNDED CONTEXTS IDENTIFIED:
  1. Order Management -- orders, line items, order status
  2. Product Catalog -- products, categories, search
  3. User Identity -- users, auth, profiles
  4. Payment Processing -- payments, refunds, invoices
  5. Inventory -- stock levels, reservations, warehouses
  6. Notifications -- email, SMS, push

COMMUNICATION DESIGN:
  Sync (gRPC): API Gateway -> All services
  Async (Kafka): Order -> Payment, Inventory, Notifications
  Saga: Order processing (choreography, 4 steps)

SERVICE MESH: Istio (mTLS, traffic splitting, circuit breaking)

Validation: 14/14 checks PASS
```

### Designing a saga for distributed transactions
```
User: /godmode:micro Design a saga for our booking workflow

Micro: Designing orchestration-based saga...

SAGA: Booking Workflow
  Step 1: CreateBooking     -> Booking Service
  Step 2: ChargePayment     -> Payment Service
  Step 3: ReserveRoom       -> Inventory Service
  Step 4: SendConfirmation  -> Notification Service

  Compensations:
  Step 4 fail: Cancel notification (no-op)
  Step 3 fail: Refund payment, cancel booking
  Step 2 fail: Cancel booking

  State machine: 4 steps, 3 compensations
  Persistence: saga_instances table
  Timeout: 30s per step, 120s total
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full microservice design workflow |
| `--decompose` | Analyze and propose service decomposition |
| `--communication` | Design inter-service communication only |
| `--saga <name>` | Design a specific saga workflow |
| `--mesh istio` | Generate Istio service mesh configuration |
| `--mesh linkerd` | Generate Linkerd service mesh configuration |
| `--topology` | Generate service topology diagram |
| `--validate` | Validate existing microservice architecture |
| `--resilience` | Design resilience patterns (circuit breaker, retry, bulkhead) |
| `--migrate` | Plan monolith-to-microservices migration |

## Auto-Detection

```
IF directory contains docker-compose.yml OR docker-compose.yaml:
  services_count = count services in compose file
  IF services_count > 2:
    SUGGEST "Detected multi-service Docker Compose with {services_count} services. Activate /godmode:micro?"

IF directory contains k8s/ OR kubernetes/ OR helm/:
  deployment_count = count Deployment manifests
  IF deployment_count > 2:
    SUGGEST "Detected {deployment_count} Kubernetes deployments. Activate /godmode:micro?"

IF directory contains istio/ OR linkerd/ OR service-mesh/:
  SUGGEST "Detected service mesh configuration. Activate /godmode:micro?"

IF directory contains proto/ OR *.proto files:
  SUGGEST "Detected gRPC proto definitions. Activate /godmode:micro?"

IF package.json contains "@grpc" OR "@nestjs/microservices" OR "moleculer" OR "seneca":
  SUGGEST "Detected microservice framework. Activate /godmode:micro?"
```

## Iterative Decomposition Protocol

```
WHEN decomposing a monolith OR designing multi-service architecture:

current_service = 0
total_services = len(identified_bounded_contexts)
failed_validations = []

WHILE current_service < total_services:
  service = bounded_contexts[current_service]

  1. DEFINE service boundary (entities, commands, events)
  2. DESIGN communication pattern (sync/async)
  3. DEFINE data ownership (which tables/collections)
  4. VALIDATE boundary:
     - No shared database with other services
     - Single team ownership
     - Independent deployability
     - Clear API contract

  IF validation_fails:
    failed_validations.append(service)
    LOG "Service {service.name} boundary invalid: {reason}"
    MERGE with adjacent context OR re-split
  ELSE:
    current_service += 1

  IF current_service % 3 == 0:
    REPORT progress: "{current_service}/{total_services} services designed"

FINAL: Generate topology diagram with all validated services
IF len(failed_validations) > 0:
  REPORT "Revisit: {failed_validations}"
```

## Multi-Agent Dispatch

```
WHEN designing a large microservice system (5+ services):

DISPATCH parallel agents in worktrees:

  Agent 1 (service-design):
    - Design bounded contexts and service boundaries
    - Define entity ownership per service
    - Output: service-catalog.md

  Agent 2 (communication-design):
    - Design inter-service communication patterns
    - Define event schemas and API contracts
    - Output: communication-contracts.md

  Agent 3 (infrastructure):
    - Configure service mesh (Istio/Linkerd)
    - Design resilience patterns (circuit breakers, retries)
    - Output: k8s/mesh/ configs

  Agent 4 (saga-design):
    - Design saga workflows for distributed transactions
    - Define compensating actions
    - Output: saga-definitions.md

MERGE: Validate all agents' outputs are consistent
  - Service names match across all documents
  - Event names in communication match saga definitions
  - Mesh configs reference correct service names
```

## HARD RULES

```
1. NEVER design a microservice that shares a database with another service.
   One service = one data store. No exceptions.

2. NEVER decompose by technical layer (e.g., "database service", "auth library service").
   Decompose by business domain ONLY.

3. NEVER skip the modular monolith step for greenfield projects.
   Build modular first. Extract when boundaries are proven.

4. EVERY synchronous call between services MUST have a circuit breaker,
   timeout (max 3s default), and retry with exponential backoff.

5. EVERY service MUST have a health check endpoint and be independently deployable.

6. NEVER use distributed transactions (2PC) across services.
   Use sagas with compensating actions.

7. EVERY event MUST include: event_id, event_type, version, timestamp,
   source, correlation_id, and data payload.

8. NEVER create a service with fewer than 2 bounded context entities.
   That is a nano-service, not a microservice.
```

## Anti-Patterns

- **Do NOT decompose by technical layer.** A "database service", "logging service", or "auth library as a service" creates distributed coupling without business value. Decompose by business domain.
- **Do NOT share databases between services.** A shared database is a distributed monolith. Every read from another service's tables is a hidden dependency.
- **Do NOT use synchronous calls for everything.** Chains of synchronous HTTP calls create cascading failure paths. One slow service takes down the entire chain.
- **Do NOT skip the modular monolith step.** Extracting services from a messy monolith gives you a distributed mess. Modularize first, then extract.
- **Do NOT create nano-services.** A service that does one trivial thing (e.g., "email validation service") adds network overhead, operational burden, and no business value.
- **Do NOT use distributed transactions (2PC).** Two-phase commit does not scale and creates tight coupling. Use sagas with compensating actions.
- **Do NOT ignore data ownership.** If you cannot clearly state which service owns which data, your service boundaries are wrong.
- **Do NOT deploy without a service mesh.** Manual circuit breakers, retries, and mTLS in every service is unsustainable. Use infrastructure-level solutions.
