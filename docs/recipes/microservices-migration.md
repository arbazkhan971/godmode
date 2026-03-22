# Recipe: Monolith to Microservices

> From tangled monolith to well-bounded microservices. A complete Godmode workflow using Domain-Driven Design, event-driven communication, and incremental migration.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `architect → ddd → micro → event → api → contract → k8s → observe → deploy` |
| **Timeline** | 3-6 months (incremental delivery every 2 weeks) |
| **Team size** | 4-8 engineers organized by domain |
| **Example project** | "ShopHub" — an e-commerce monolith splitting into domain-aligned microservices |

---

## The Scenario

ShopHub is a successful e-commerce platform:
- Django monolith, 350K lines of Python, serving 50K daily active users
- Single PostgreSQL database with 127 tables
- Deployment: 1-hour deploy pipeline, 2-3 deploys per week
- Pain points:
  - Teams step on each other (8 engineers, 1 deployable unit)
  - Scaling: checkout slows down when search gets heavy traffic
  - Feature velocity: new features take 3x longer than they should
  - Testing: full test suite takes 45 minutes
- You need independent teams that can deploy independently

---

## Phase 1: Strategic Design (Week 1-2)

### Step 1: Architect — Evaluate the Migration

```
> /godmode:architect --context "monolith-to-microservices evaluation"

Godmode: Analyzing monolith for microservices readiness...

ARCHITECTURE ASSESSMENT:

Current state: Django monolith
  - 350K lines, 127 tables, 8 Django apps
  - Apps: users, catalog, inventory, orders, payments, shipping, reviews, analytics
  - Tight coupling: orders imports from 6 other apps directly
  - Shared models: Product model used by catalog, inventory, orders, reviews
  - Shared database: all 127 tables in one PostgreSQL instance

Readiness checklist:
  ✓ Team is large enough to justify (8 engineers, growing to 12)
  ✓ Clear business domains identifiable
  ✗ No API boundaries between current modules
  ✗ Heavy cross-module database joins
  ✗ No event infrastructure (Kafka, RabbitMQ)
  ✗ No container orchestration (running on EC2 directly)

MIGRATION APPROACH EVALUATION:

Approach A: Big Bang Rewrite
  Risk: EXTREME — 6-12 months of zero delivery
  Recommendation: NEVER do this

Approach B: Strangler Fig (Backend-for-Frontend first)
  Risk: LOW — incremental, reversible
  Strategy: Build new services behind the monolith, one domain at a time
  Recommendation: YES — this is the right approach

Approach C: Module-first (modular monolith, then extract)
  Risk: LOW — adds boundaries inside the monolith first
  Strategy: Enforce module boundaries in the monolith, then extract as services
  Recommendation: COMBINE with Approach B

RECOMMENDED: Approach B + C
  Step 1: Enforce module boundaries in the monolith (modular monolith)
  Step 2: Add event bus (Kafka) alongside the monolith
  Step 3: Extract services one domain at a time (strangler fig)
  Step 4: Decommission monolith domains as services are validated

Saved: docs/architecture/microservices-migration-strategy.md
Saved: docs/adr/001-incremental-strangler-fig.md
```

### Step 2: DDD — Domain Decomposition

```
> /godmode:ddd

Godmode: Running Domain-Driven Design analysis...

══════════════════════════════════════════════
DOMAIN ANALYSIS
══════════════════════════════════════════════

Step 1: Event Storming (automated)

Analyzing codebase for domain events, commands, and aggregates...

DOMAIN EVENTS DISCOVERED:
  Users:     UserRegistered, UserVerified, UserDeactivated
  Catalog:   ProductCreated, ProductUpdated, PriceChanged, CategoryChanged
  Inventory: StockReceived, StockReserved, StockDepleted, StockReleased
  Orders:    OrderPlaced, OrderConfirmed, OrderShipped, OrderDelivered,
             OrderCancelled, OrderRefunded
  Payments:  PaymentInitiated, PaymentCompleted, PaymentFailed, RefundIssued
  Shipping:  ShipmentCreated, ShipmentDispatched, ShipmentDelivered,
             TrackingUpdated
  Reviews:   ReviewSubmitted, ReviewApproved, ReviewFlagged
  Analytics: PageViewed, SearchPerformed, CartUpdated, CheckoutStarted

Step 2: Bounded Context Mapping

| Identity |  | Catalog |  | Inventory |
| Context |  | Context |  | Context |
│              │    │              │    │              │
| - User |  | - Product |  | - StockItem |
| - Profile |  | - Category |  | - Warehouse |
| - Auth |  | - Price |  | - Reservation |
| - Permission |  | - Image |  |  |
  ┌──────┴───────┐
       └────────────┤    Order     ├───────────┘
  Context
  - Order
  - OrderLine
  - Cart
              ┌────────────┼────────────┐
       ┌──────┴──────┐ ┌──┴──────┐ ┌──┴──────────┐
| Payment |  | Shipping |  | Review |
| Context |  | Context |  | Context |
       │             │ │         │ │              │
| - Payment |  | - Shipment |  | - Review |
| - Refund |  | - Carrier |  | - Rating |
| - Invoice |  | - Tracking |  | - Moderation |
Step 3: Context Relationships

RELATIONSHIPS:
  Identity ←→ Order: Customer/Supplier (Identity provides user data)
  Catalog ←→ Order: Shared Kernel (Product reference in both)
  Inventory ←→ Order: Customer/Supplier (Order reserves stock)
  Order ←→ Payment: Customer/Supplier (Order triggers payment)
  Order ←→ Shipping: Customer/Supplier (Order triggers shipment)
  Order ←→ Review: Separate (Review references order loosely)
  Catalog ←→ Inventory: Conformist (Inventory tracks catalog products)

Step 4: Service Boundaries

PROPOSED MICROSERVICES:
  1. identity-service      — User management, auth, permissions
  2. catalog-service       — Products, categories, pricing, search
  3. inventory-service     — Stock management, reservations, warehouses
  4. order-service         — Cart, checkout, order lifecycle
  5. payment-service       — Payment processing, refunds, invoicing
  6. shipping-service      — Shipment management, carrier integration, tracking
  7. review-service        — Product reviews, ratings, moderation
  8. analytics-service     — Event collection, reporting, dashboards

DATA OWNERSHIP:
  Each service owns its data. No shared database.
  Cross-service data: communicated via events or API calls.

  Identity:  users, profiles, permissions, sessions
  Catalog:   products, categories, prices, images
  Inventory: stock_items, warehouses, reservations
  Order:     orders, order_lines, carts
  Payment:   payments, refunds, invoices
  Shipping:  shipments, tracking_events, carriers
  Review:    reviews, ratings, moderation_queue
  Analytics: events (append-only event store)

Saved: docs/architecture/bounded-contexts.md
Saved: docs/architecture/context-map.md
```

### Step 3: Event — Design Event-Driven Communication

```
> /godmode:event

Godmode: Designing event-driven architecture...

EVENT ARCHITECTURE:

Infrastructure: Apache Kafka
  Reasoning: High throughput, replay capability, multiple consumers

TOPIC DESIGN:

  Topic                        Partitions  Retention  Key
  identity.user.events         6           7 days     user_id
  catalog.product.events       12          7 days     product_id
  inventory.stock.events       6           7 days     product_id
  order.events                 12          30 days    order_id
  payment.events               6           30 days    payment_id
  shipping.events              6           30 days    shipment_id
  review.events                3           7 days     product_id
  analytics.page.events        24          3 days     session_id

EVENT SCHEMAS (Avro with Schema Registry):

  OrderPlaced:
    order_id:      string (UUID)
    customer_id:   string (UUID)
    items:         array of {product_id, quantity, unit_price}
    total_amount:  int (cents)
    currency:      string
    placed_at:     timestamp
    metadata:      map<string, string>

  PaymentCompleted:
    payment_id:    string (UUID)
    order_id:      string (UUID)
    amount:        int (cents)
    currency:      string
    method:        string (card, bank_transfer, wallet)
    completed_at:  timestamp

  [... schemas for all event types ...]

EVENT CHOREOGRAPHY (who produces, who consumes):

  OrderPlaced →
    consumed by: inventory-service (reserve stock)
    consumed by: payment-service (initiate payment)
    consumed by: analytics-service (track conversion)

  PaymentCompleted →
    consumed by: order-service (confirm order)
    consumed by: shipping-service (create shipment)
    consumed by: analytics-service (track revenue)

  ShipmentDispatched →
    consumed by: order-service (update order status)
    consumed by: notification-service (email customer)

SAGA: Order Placement (orchestrated)
  1. Order-service creates order (PENDING)
  2. → Inventory-service reserves stock
     ← StockReserved / StockInsufficient
  3. → Payment-service initiates payment
     ← PaymentCompleted / PaymentFailed
  4. If PaymentFailed → Inventory-service releases stock (compensate)
  5. If PaymentCompleted → Order confirmed, shipping notified

Saved: docs/architecture/event-driven-design.md
Saved: proto/events/ (all event schemas)
```

---

## Phase 2: API and Contract Design (Week 3-4)

### Step 4: API — Design Service APIs

```
> /godmode:api --type grpc --services all

Godmode: Designing gRPC APIs for all services...

API DESIGN:

Service: catalog-service (gRPC)
  rpc GetProduct(GetProductRequest) returns (Product)
  rpc SearchProducts(SearchRequest) returns (SearchResponse)
  rpc ListCategories(ListCategoriesRequest) returns (CategoryList)
  rpc UpdatePrice(UpdatePriceRequest) returns (Product)

Service: order-service (gRPC + REST)
  gRPC (internal):
    rpc CreateOrder(CreateOrderRequest) returns (Order)
    rpc GetOrder(GetOrderRequest) returns (Order)
    rpc CancelOrder(CancelOrderRequest) returns (Order)
  REST (external via gateway):
    POST /api/v1/orders
    GET /api/v1/orders/:id
    POST /api/v1/orders/:id/cancel
    GET /api/v1/orders (list with filters)

  [... APIs for all 8 services ...]

API GATEWAY ROUTING:
  /api/v1/users/*     → identity-service
  /api/v1/products/*  → catalog-service
  /api/v1/inventory/* → inventory-service (internal only)
  /api/v1/orders/*    → order-service
  /api/v1/payments/*  → payment-service
  /api/v1/shipments/* → shipping-service
  /api/v1/reviews/*   → review-service

Saved: proto/ (all service definitions)
Saved: docs/api/service-apis.md
```

### Step 5: Contract — Define Consumer Contracts

```
> /godmode:contract --framework pact

Godmode: Setting up consumer-driven contract testing...

CONTRACT TESTING:

Consumer-Provider pairs:
  order-service → catalog-service (product lookup)
  order-service → inventory-service (stock check + reservation)
  order-service → payment-service (payment initiation)
  shipping-service → order-service (order details)
  review-service → catalog-service (product details)
  review-service → order-service (purchase verification)

Pact contracts generated:
  contracts/order-catalog.pact.json
  contracts/order-inventory.pact.json
  contracts/order-payment.pact.json
  contracts/shipping-order.pact.json
  contracts/review-catalog.pact.json
  contracts/review-order.pact.json

CI integration:
  - Consumer tests generate pact files
  - Provider tests verify pact files
  - "Can I deploy?" check before any service deployment
  - Pact Broker for contract storage and versioning

File: .github/workflows/contract-test.yml
  - Runs on every PR
  - Blocks deploy if contracts are broken
  - Tags successful verifications for deployment

Commit: "contract: consumer-driven contracts for all service pairs"
```

---

## Phase 3: Extract Services (Week 5-20)

### Migration Order

Extract services in dependency order — start with services that have fewer dependents:

```
Migration order:
  1. review-service      (week 5-6)   — fewest dependencies, lowest risk
  2. analytics-service   (week 7-8)   — read-only, no writes to shared DB
  3. shipping-service    (week 8-9)   — mostly independent
  4. payment-service     (week 10-12) — critical path, needs careful testing
  5. identity-service    (week 12-14) — foundational, many dependents
  6. inventory-service   (week 14-16) — tightly coupled with orders
  7. catalog-service     (week 16-18) — shared by many services
  8. order-service       (week 18-20) — the core, extracted last
```

### Step 6: Micro — Extract a Service (repeat per service)

Example: extracting payment-service (the most instructive extraction).

```
> /godmode:micro --extract payment

Godmode: Extracting payment bounded context from monolith...

EXTRACTION PLAN: payment-service

Step 1: Identify all payment code in the monolith
  Django app: payments/
  Models: Payment, Refund, Invoice, PaymentMethod
  Views: 14 API endpoints
  Tasks: 3 Celery tasks (process_payment, send_invoice, reconcile)
  Database tables: payments, refunds, invoices, payment_methods
  External calls: Stripe API
  Cross-references:
    - orders app imports Payment model (9 locations)
    - users app imports PaymentMethod model (3 locations)
    - analytics app reads payments table (5 queries)

Step 2: Create the new service
  Language: Python (FastAPI) — team familiar, consistent with monolith
  Database: New PostgreSQL instance (payment-service-db)
  Files generated:
    payment-service/
    ├── src/
  ├── api/           — FastAPI endpoints (matching current URLs)
  ├── services/      — Business logic extracted from Django views
  ├── models/        — SQLAlchemy models (from Django models)
  ├── events/        — Kafka producers and consumers
  └── stripe/        — Stripe integration (extracted from monolith)
    ├── tests/             — Tests migrated from monolith
    ├── migrations/        — Alembic migrations
    └── Dockerfile

Step 3: Data migration strategy
  Phase A: Dual-write (monolith writes to both old and new DB)
  Phase B: Sync verification (compare old and new DB continuously)
  Phase C: Switch reads to new service
  Phase D: Stop writes to old DB
  Phase E: Drop old payment tables from monolith DB

Step 4: Traffic migration
  - API gateway routes /api/payments/* to new service
  - Monolith code replaced with API calls to new service
  - Feature flag controls traffic split (0% → 10% → 50% → 100%)

> /godmode:build

[builds the extracted payment service]

> /godmode:verify

Shadow traffic comparison:
  1000 requests mirrored to both old and new:
  Identical responses: 998/1000 (99.8%)
  Differences: 2 timestamp format mismatches — FIXED

> /godmode:deploy --strategy canary --percentage 5

Canary deployment:
  T+0:   5% traffic to new payment-service
  T+30:  ✓ Error rate 0%, latency improved (240ms → 45ms)
  T+60:  Promoting to 25%
  T+120: Promoting to 100%
  ✓ payment-service fully extracted and deployed.
```

---

## Phase 4: Infrastructure (Week 4-6, parallel with extraction)

### Step 7: K8s — Kubernetes Setup

```
> /godmode:k8s

Godmode: Setting up Kubernetes infrastructure...

KUBERNETES ARCHITECTURE:

Cluster: AWS EKS (managed Kubernetes)
Namespace strategy: one namespace per environment (dev, staging, production)

Service deployments:
  identity-service:    2 replicas, 256Mi memory, 200m CPU
  catalog-service:     3 replicas, 512Mi memory, 500m CPU (handles search)
  inventory-service:   2 replicas, 256Mi memory, 200m CPU
  order-service:       3 replicas, 512Mi memory, 500m CPU (core service)
  payment-service:     2 replicas, 256Mi memory, 200m CPU
  shipping-service:    2 replicas, 256Mi memory, 200m CPU
  review-service:      1 replica, 128Mi memory, 100m CPU
  analytics-service:   2 replicas, 1Gi memory, 500m CPU (data processing)

Infrastructure:
  Kafka:              Confluent Cloud (managed)
  PostgreSQL:         RDS per service (8 instances)
  Redis:              ElastiCache (shared, namespace-isolated)
  API Gateway:        Kong Ingress Controller
  Service Mesh:       Istio (mTLS, traffic management, observability)
  CI/CD:              GitHub Actions → ArgoCD (GitOps)

Files generated:
  deploy/k8s/base/           — base Kubernetes manifests
  deploy/k8s/overlays/dev/   — development overrides
  deploy/k8s/overlays/prod/  — production overrides
  deploy/helm/               — Helm charts per service
  deploy/argocd/             — ArgoCD application definitions

Auto-scaling:
  HPA: Scale on CPU (70%) and custom metrics (requests/sec)
  Order-service: min 3, max 10 replicas
  Catalog-service: min 3, max 15 replicas (handles search spikes)

Commit: "infra: Kubernetes manifests, Helm charts, ArgoCD for all services"
```

### Step 8: Observe — Distributed Observability

```
> /godmode:observe --distributed

Godmode: Setting up distributed observability...

OBSERVABILITY STACK:

Distributed tracing (Jaeger via OpenTelemetry):
  - Automatic trace propagation across gRPC calls
  - Kafka message trace correlation
  - Trace sampling: 10% in production, 100% in staging

Metrics (Prometheus + Grafana):
  Per-service dashboards:
    - Request rate, latency, error rate (RED metrics)
    - Resource utilization (CPU, memory, network)
    - Database connection pool usage
  Cross-service dashboards:
    - End-to-end order flow latency (across all services)
    - Kafka consumer lag per topic
    - Service dependency map (auto-generated from traces)

Logging (EFK stack: Elasticsearch + Fluentd + Kibana):
  - Structured JSON logging (standard format across all services)
  - Correlation ID propagated across all service calls
  - Log aggregation with service, pod, and trace context

Alerting:
  - Per-service SLOs (99.9% availability, p99 < 500ms)
  - Cross-service alerts (order flow p99 > 5s)
  - Kafka consumer lag > 10,000 messages
  - Circuit breaker state changes

Saved: docs/observability/distributed-monitoring.md
Commit: "observe: distributed tracing, metrics, logging for microservices"
```

---

## Phase 5: Validate and Ship (Ongoing)

### Step 9: Deploy — Progressive Rollout

```
> /godmode:deploy --strategy progressive

Godmode: Configuring progressive deployment...

DEPLOYMENT STRATEGY:

Per-service deployment (independent):
  1. PR merged → CI builds Docker image
  2. ArgoCD detects new image tag
  3. Canary deployment: 10% traffic for 15 minutes
  4. Automated analysis: error rate, latency, contract tests
  5. If metrics are healthy: progressive rollout (25% → 50% → 100%)
  6. If metrics degrade: automatic rollback

Cross-service deployment (coordinated):
  For breaking changes that span services:
  1. Deploy provider service first (backward-compatible)
  2. Run contract tests against new provider
  3. Deploy consumer services
  4. Remove backward-compatibility shim in next provider release

Feature flags (LaunchDarkly):
  - New service extraction: flag controls traffic routing
  - New features: flag controls feature availability
  - Gradual rollout: percentage-based feature rollout

DEPLOYMENT CADENCE:
  Before: 2-3 deploys per week (monolith, 1-hour pipeline)
  After: 5-10 deploys per day (per-service, 8-minute pipeline)

Saved: docs/deployment/progressive-rollout.md
```

---

## Migration Progress Tracker

```
MIGRATION STATUS (Week 14 of 20):

Service              Status          Traffic    Tests    Deploy
review-service       ✓ COMPLETE      100%       47       Independent
analytics-service    ✓ COMPLETE      100%       62       Independent
shipping-service     ✓ COMPLETE      100%       54       Independent
payment-service      ✓ COMPLETE      100%       89       Independent
identity-service     ✓ COMPLETE      100%       78       Independent
inventory-service    ◐ IN PROGRESS   50%        71       Canary
catalog-service      ○ NOT STARTED   0%         —        Monolith
order-service        ○ NOT STARTED   0%         —        Monolith

Monolith reduction: 350K lines → 145K lines (58% extracted)
Deploy frequency: 2-3/week → 8-10/day (services already extracted)
Test suite time: 45 min → 8 min per service (parallel)
Team structure: 2 teams of 4 (Ordering team, Platform team)
```

---

## Key Architecture Decisions

| Decision | Choice | ADR |
|----------|--------|-----|
| Migration strategy | Strangler Fig + Modular Monolith | ADR-001 |
| Communication | Event-driven (Kafka) + gRPC (sync) | ADR-002 |
| Database | Database-per-service (PostgreSQL) | ADR-003 |
| Service mesh | Istio | ADR-004 |
| Deployment | ArgoCD (GitOps) + Canary | ADR-005 |
| Contract testing | Pact | ADR-006 |
| Extraction order | Dependency-based (least dependent first) | ADR-007 |
| Data migration | Dual-write → switch reads → stop old writes | ADR-008 |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Alternative |
|-------------|---------|-------------|
| Distributed monolith | Services call each other synchronously for everything | Event-driven communication, accept eventual consistency |
| Shared database | Two services reading/writing same table | Database-per-service, data replicated via events |
| Big bang extraction | Extract all services simultaneously | One service at a time, validate each extraction |
| No contracts | Breaking changes discovered in production | Consumer-driven contract tests, "can I deploy?" gate |
| Nano-services | One function per service | Align services to bounded contexts, not CRUD entities |
| Missing observability | Cannot trace requests across services | Distributed tracing from day 1, correlation IDs everywhere |

---

## Custom Chain for Microservices Migration

```yaml
# .godmode/chains.yaml
chains:
  extract-service:
    description: "Extract one service from the monolith"
    steps:
      - ddd:
          args: "--context <bounded-context>"
      - micro:
          args: "--extract <service>"
      - api
      - contract
      - build
      - test
      - verify   # shadow traffic comparison
      - deploy:
          strategy: canary

  microservices-setup:
    description: "Initial microservices infrastructure"
    steps:
      - architect
      - ddd
      - event
      - k8s
      - observe
      - deploy
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Legacy Modernization Recipe](legacy-modernization.md) — If you are modernizing without going to microservices
- [Greenfield SaaS Recipe](greenfield-saas.md) — Starting with microservices from scratch
- [Incident Response Recipe](incident-response.md) — Handling incidents in distributed systems
