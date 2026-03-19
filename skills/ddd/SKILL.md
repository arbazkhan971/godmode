---
name: ddd
description: |
  Domain-Driven Design skill. Activates when user needs to model a complex domain, define bounded contexts, design aggregates, or facilitate event storming. Covers strategic design (bounded contexts, context mapping, ubiquitous language) and tactical design (aggregates, entities, value objects, domain events, repositories). Produces bounded context maps, aggregate boundary diagrams, domain event catalogs, and implementation scaffolds. Triggers on: /godmode:ddd, "model the domain", "bounded context", "aggregate design", "event storming", or when the orchestrator detects domain modeling needs.
---

# DDD — Domain-Driven Design

## When to Activate
- User invokes `/godmode:ddd`
- User says "model the domain", "define bounded contexts", "design aggregates"
- User says "event storming", "domain events", "ubiquitous language"
- When `/godmode:architect` identifies that domain boundaries need clarification
- When `/godmode:pattern` detects an anemic domain model anti-pattern
- When business logic complexity outgrows simple CRUD operations
- When multiple teams need clear ownership boundaries

## Workflow

### Step 1: Domain Discovery
Understand the business domain before modeling:

```
DOMAIN CONTEXT:
Business: <what does the business do?>
Core domain: <the thing that differentiates this business>
Supporting domains: <necessary but not differentiating>
Generic domains: <commodity — auth, billing, email>
Key stakeholders: <who are the domain experts?>
Known pain points: <where does the current model break down?>
```

**Identify the core domain.** This is where you invest the most modeling effort. Generic domains get off-the-shelf solutions. Supporting domains get simple implementations. Only the core domain gets full DDD treatment.

### Step 2: Ubiquitous Language
Establish the shared vocabulary between developers and domain experts:

```
UBIQUITOUS LANGUAGE — <Domain Name>:
┌──────────────────┬──────────────────────────────────────────────────────┐
│ Term             │ Definition                                          │
├──────────────────┼──────────────────────────────────────────────────────┤
│ <Term 1>         │ <Precise definition as understood by domain experts │
│                  │  AND developers. No ambiguity.>                     │
├──────────────────┼──────────────────────────────────────────────────────┤
│ <Term 2>         │ <Definition. Note: "Order" in the Sales context     │
│                  │  means something different than in Fulfillment.>    │
├──────────────────┼──────────────────────────────────────────────────────┤
│ <Term 3>         │ <Definition. Include what it is NOT if ambiguous.>  │
└──────────────────┴──────────────────────────────────────────────────────┘

LANGUAGE RULES:
- These terms are used in code (class names, method names, variable names)
- These terms are used in conversations with stakeholders
- If a term means different things in different contexts, it belongs in
  different bounded contexts with different definitions
- When a new term emerges, add it to this glossary immediately
```

### Step 3: Event Storming
Facilitate a structured event storming session to discover domain events, commands, aggregates, and boundaries:

#### Phase 1: Chaotic Exploration (Domain Events)
List every domain event — things that happened in the past tense:
```
DOMAIN EVENTS (unordered):
🟧 OrderPlaced
🟧 PaymentReceived
🟧 PaymentFailed
🟧 InventoryReserved
🟧 InventoryOutOfStock
🟧 OrderShipped
🟧 OrderDelivered
🟧 OrderCancelled
🟧 RefundIssued
🟧 CustomerRegistered
🟧 PriceChanged
🟧 PromotionApplied
```

#### Phase 2: Timeline (Temporal Ordering)
Arrange events in chronological order:
```
TIMELINE:
CustomerRegistered → OrderPlaced → InventoryReserved → PaymentReceived
  → OrderShipped → OrderDelivered

ALTERNATE FLOWS:
OrderPlaced → InventoryOutOfStock → OrderCancelled → RefundIssued
OrderPlaced → InventoryReserved → PaymentFailed → OrderCancelled
OrderShipped → OrderDelivered → RefundIssued (return)
```

#### Phase 3: Commands & Actors
Identify what triggers each event:
```
COMMANDS AND TRIGGERS:
┌────────────────────┬──────────────────┬────────────────────┐
│ Command            │ Actor            │ Produces Event     │
├────────────────────┼──────────────────┼────────────────────┤
│ PlaceOrder         │ Customer         │ OrderPlaced        │
│ ProcessPayment     │ Payment Gateway  │ PaymentReceived    │
│ ReserveInventory   │ System (auto)    │ InventoryReserved  │
│ ShipOrder          │ Warehouse Staff  │ OrderShipped       │
│ CancelOrder        │ Customer/System  │ OrderCancelled     │
│ IssueRefund        │ Support Agent    │ RefundIssued       │
└────────────────────┴──────────────────┴────────────────────┘
```

#### Phase 4: Aggregates
Group events around the entities that own them:
```
AGGREGATES:
┌─────────────────────────────────────────────────┐
│  <<Aggregate>> Order                            │
│  Commands: PlaceOrder, CancelOrder              │
│  Events: OrderPlaced, OrderCancelled,           │
│          OrderShipped, OrderDelivered            │
│  Invariants:                                    │
│  - Order total must be > 0                      │
│  - Cannot cancel a delivered order              │
│  - Cannot ship without payment                  │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  <<Aggregate>> Inventory                        │
│  Commands: ReserveInventory, ReleaseInventory   │
│  Events: InventoryReserved, InventoryOutOfStock │
│  Invariants:                                    │
│  - Stock count cannot go negative               │
│  - Reserved quantity cannot exceed available     │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  <<Aggregate>> Payment                          │
│  Commands: ProcessPayment, IssueRefund          │
│  Events: PaymentReceived, PaymentFailed,        │
│          RefundIssued                            │
│  Invariants:                                    │
│  - Refund cannot exceed original payment        │
│  - Payment must reference a valid order          │
└─────────────────────────────────────────────────┘
```

#### Phase 5: Bounded Context Discovery
Draw boundaries around aggregates that share a ubiquitous language:
```
BOUNDED CONTEXTS:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌─────────────────────────┐  ┌──────────────────────────────┐  │
│  │  ORDERING CONTEXT       │  │  FULFILLMENT CONTEXT         │  │
│  │                         │  │                              │  │
│  │  Aggregates:            │  │  Aggregates:                 │  │
│  │  - Order                │  │  - Shipment                  │  │
│  │  - Cart                 │  │  - Inventory                 │  │
│  │                         │  │                              │  │
│  │  "Order" = items a      │  │  "Order" = items to pick     │  │
│  │  customer wants to buy  │  │  and ship from warehouse     │  │
│  └─────────────────────────┘  └──────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────┐  ┌──────────────────────────────┐  │
│  │  BILLING CONTEXT        │  │  IDENTITY CONTEXT            │  │
│  │                         │  │                              │  │
│  │  Aggregates:            │  │  Aggregates:                 │  │
│  │  - Payment              │  │  - Customer                  │  │
│  │  - Invoice              │  │  - Account                   │  │
│  │                         │  │                              │  │
│  │  "Order" = a billable   │  │  "Customer" = account with   │  │
│  │  transaction            │  │  credentials and profile     │  │
│  └─────────────────────────┘  └──────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Step 4: Context Mapping
Define relationships between bounded contexts:

```
CONTEXT MAP:
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│   Ordering ──── Partnership ────► Fulfillment                          │
│      │                                │                                │
│   Customer/                      Customer/                             │
│   Supplier                       Supplier                              │
│      │                                │                                │
│      ▼                                ▼                                │
│   Billing ──── Conformist ────► Payment Gateway (External)             │
│                                                                         │
│   Identity ──── Open Host Service ────► All Contexts                   │
│                  (Published Language)                                    │
│                                                                         │
│   Reporting ──── ACL ────► Legacy ERP System                           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘

CONTEXT RELATIONSHIP TYPES:
┌──────────────────────┬──────────────────────────────────────────────────┐
│ Relationship         │ When to Use                                     │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Partnership          │ Two teams cooperate closely, evolve interface   │
│                      │ together. High trust, high coordination.        │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Customer/Supplier    │ Downstream needs influence upstream priorities. │
│                      │ Upstream accommodates but owns the interface.   │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Conformist           │ Downstream conforms to upstream's model.        │
│                      │ No influence on the upstream team.              │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Anti-Corruption      │ Downstream translates upstream's model to       │
│ Layer (ACL)          │ protect its own domain from pollution.          │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Open Host Service    │ Upstream exposes a well-defined protocol        │
│                      │ (API) that any downstream can consume.          │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Published Language   │ A shared language (schema, API spec) used       │
│                      │ between contexts. Often paired with OHS.        │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Shared Kernel        │ Two contexts share a small subset of the model. │
│                      │ Use sparingly — creates tight coupling.         │
├──────────────────────┼──────────────────────────────────────────────────┤
│ Separate Ways        │ No integration. Contexts are completely         │
│                      │ independent with duplicated concepts.           │
└──────────────────────┴──────────────────────────────────────────────────┘
```

### Step 5: Tactical Design — Aggregate Internals
For each aggregate in the core domain, design the internal structure:

```
AGGREGATE DESIGN — <Aggregate Name>:

Root Entity: <AggregateRootName>
  ID: <type and generation strategy>
  State: <key properties>
  Invariants:
    1. <business rule that must always be true>
    2. <business rule that must always be true>

Entities (within this aggregate):
  - <EntityName>: <purpose, ID type, key properties>
  - <EntityName>: <purpose, ID type, key properties>

Value Objects:
  - <ValueObjectName>: <immutable, defined by attributes not identity>
    Properties: <list>
    Validation: <what makes it valid>
    Equality: <compared by value, not reference>
  - <ValueObjectName>: ...

Domain Events (emitted by this aggregate):
  - <EventName>: <when emitted, what data it carries>
  - <EventName>: ...

Commands (accepted by this aggregate):
  - <CommandName>: <preconditions, what it does, events it produces>
  - <CommandName>: ...

Repository Interface:
  - save(aggregate): void
  - findById(id): Aggregate | null
  - <custom queries needed by the domain>
```

#### Aggregate Design Rules
```
AGGREGATE BOUNDARY RULES:
1. CONSISTENCY BOUNDARY: Everything inside an aggregate is immediately
   consistent. Cross-aggregate operations are eventually consistent.

2. TRANSACTION BOUNDARY: One aggregate = one transaction. Never modify
   two aggregates in the same transaction.

3. SIZE RULE: Keep aggregates small. If an aggregate has more than
   3-4 entities, consider splitting.

4. REFERENCE RULE: Aggregates reference each other by ID only, never
   by direct object reference.

5. CASCADE RULE: Only the aggregate root can be referenced from outside.
   Internal entities are accessed through the root.

6. INVARIANT RULE: An aggregate protects its invariants. All state
   changes go through the root, which validates business rules.

7. IDENTITY RULE: Entities have identity (ID). Value Objects do not.
   Prefer Value Objects over Entities when possible.
```

### Step 6: Domain Event Catalog
Document all domain events for cross-context communication:

```
DOMAIN EVENT CATALOG:
┌──────────────────────┬─────────────┬────────────────────────────────────┐
│ Event                │ Source      │ Payload                            │
│                      │ Context     │                                    │
├──────────────────────┼─────────────┼────────────────────────────────────┤
│ OrderPlaced          │ Ordering    │ orderId, customerId, items[],      │
│                      │             │ totalAmount, placedAt              │
├──────────────────────┼─────────────┼────────────────────────────────────┤
│ PaymentReceived      │ Billing     │ paymentId, orderId, amount,        │
│                      │             │ method, paidAt                     │
├──────────────────────┼─────────────┼────────────────────────────────────┤
│ InventoryReserved    │ Fulfillment │ reservationId, orderId, items[],   │
│                      │             │ warehouseId, reservedAt            │
├──────────────────────┼─────────────┼────────────────────────────────────┤
│ OrderShipped         │ Fulfillment │ shipmentId, orderId, trackingNo,   │
│                      │             │ carrier, shippedAt                 │
└──────────────────────┴─────────────┴────────────────────────────────────┘

EVENT SCHEMA RULES:
1. Events are past tense (OrderPlaced, not PlaceOrder)
2. Events are immutable — never modify a published event
3. Events carry enough data for consumers to act without callbacks
4. Events have a version field for schema evolution
5. Events are the contract between bounded contexts
```

### Step 7: Implementation Scaffold
Generate the directory structure and skeleton code:

```
DIRECTORY STRUCTURE:
src/
├── <context-name>/
│   ├── domain/
│   │   ├── model/
│   │   │   ├── <AggregateRoot>.ts        # Aggregate root entity
│   │   │   ├── <Entity>.ts               # Child entities
│   │   │   └── <ValueObject>.ts          # Value objects
│   │   ├── events/
│   │   │   └── <DomainEvent>.ts          # Domain events
│   │   ├── commands/
│   │   │   └── <Command>.ts              # Commands
│   │   ├── repositories/
│   │   │   └── <Repository>.ts           # Repository interface (port)
│   │   └── services/
│   │       └── <DomainService>.ts        # Domain services (stateless logic)
│   ├── application/
│   │   ├── handlers/
│   │   │   └── <CommandHandler>.ts       # Command handlers (use cases)
│   │   └── queries/
│   │       └── <QueryHandler>.ts         # Query handlers (read side)
│   └── infrastructure/
│       ├── persistence/
│       │   └── <RepositoryImpl>.ts       # Repository implementation (adapter)
│       └── messaging/
│           └── <EventPublisher>.ts       # Event publishing adapter
```

### Step 8: Artifacts & Transition
1. Save domain model: `docs/domain/<context>-domain-model.md`
2. Save event catalog: `docs/domain/event-catalog.md`
3. Save context map: `docs/domain/context-map.md`
4. Save ubiquitous language: `docs/domain/ubiquitous-language.md`
5. Commit: `"ddd: <context> — bounded contexts, aggregates, and event catalog"`
6. Suggest next steps:
   - "Domain modeled. Run `/godmode:architect` to select the architecture for this domain."
   - "Domain modeled. Run `/godmode:plan` to decompose aggregate implementation into tasks."
   - "Domain modeled. Run `/godmode:pattern` to select implementation patterns for each aggregate."

## Key Behaviors

1. **Start with events, not entities.** Events reveal the real behavior of the domain. Entities emerge from grouping events. Starting with entities leads to CRUD thinking.
2. **Ubiquitous language is non-negotiable.** If developers use different terms than domain experts, the model is wrong. Code must speak the domain language.
3. **Bounded contexts are social, not technical.** Context boundaries follow team boundaries and linguistic boundaries, not technology or deployment boundaries.
4. **Aggregates are small.** If an aggregate contains more than 3-4 entities, it is probably too large. Small aggregates enable better concurrency and simpler code.
5. **Reference by ID across aggregates.** Never hold direct object references to entities in other aggregates. Use IDs and resolve them when needed.
6. **Eventual consistency between contexts.** Do not try to make cross-context operations immediately consistent. Use domain events and accept eventual consistency.
7. **Not everything needs DDD.** CRUD operations, reports, and generic domains do not benefit from tactical DDD patterns. Reserve the investment for the core domain.
8. **Event storming is collaborative.** Even in a solo coding session, walk through the event storming phases. The structured thinking process catches model errors early.

## Example Usage

### Modeling an e-commerce domain
```
User: /godmode:ddd Model the domain for our e-commerce platform

DDD: Starting domain discovery...

DOMAIN CONTEXT:
Business: Online retail marketplace
Core domain: Ordering & Checkout (competitive differentiator)
Supporting: Inventory management, Customer profiles
Generic: Authentication, Email notifications, Payment processing

Beginning event storming...

Phase 1 — Domain Events discovered: 24 events
Phase 2 — Timeline with 4 alternate flows mapped
Phase 3 — 18 commands identified with actors
Phase 4 — 6 aggregates identified
Phase 5 — 4 bounded contexts defined

BOUNDED CONTEXTS:
1. Ordering (core) — Order, Cart, Promotion
2. Fulfillment (supporting) — Shipment, Inventory
3. Billing (supporting) — Payment, Invoice
4. Identity (generic) — Customer, Account

CONTEXT MAP:
Ordering ←Partnership→ Fulfillment
Ordering ←Customer/Supplier→ Billing
Billing ←Conformist→ Stripe (External)
Identity ←Open Host Service→ All

Shall I proceed to tactical design for the Ordering context?
```

### Designing aggregate boundaries
```
User: /godmode:ddd --aggregate Design the Order aggregate boundaries

DDD: Analyzing the Order aggregate...

AGGREGATE DESIGN — Order:
Root Entity: Order
  ID: OrderId (UUID)
  State: status, customerId, items[], totalAmount, placedAt
  Invariants:
    1. Order must have at least one item
    2. Total must equal sum of item prices
    3. Cannot transition from Delivered to Cancelled

Entities:
  - OrderItem: quantity, productId, unitPrice, subtotal

Value Objects:
  - Money: amount (decimal), currency (enum)
  - Address: street, city, state, zip, country
  - OrderStatus: Draft | Placed | Paid | Shipped | Delivered | Cancelled

Domain Events:
  - OrderPlaced: orderId, customerId, items[], totalAmount
  - OrderCancelled: orderId, reason, cancelledAt

Commands:
  - PlaceOrder: precondition (cart not empty), produces OrderPlaced
  - CancelOrder: precondition (status < Shipped), produces OrderCancelled

NOTE: Payment is NOT inside the Order aggregate. Payment is in the
Billing context. They communicate via events (OrderPlaced → ProcessPayment).
```

### Facilitating event storming
```
User: /godmode:ddd --event-storm We're building a ride-sharing app

DDD: Starting event storming session...

Let me explore the domain. What happens from a rider's perspective?

Phase 1 — Events:
🟧 RideRequested
🟧 DriverMatched
🟧 DriverEnRoute
🟧 RiderPickedUp
🟧 RideInProgress
🟧 RideCompleted
🟧 PaymentCharged
🟧 RiderRated
🟧 DriverRated
🟧 RideCancelled
🟧 SurgeActivated
🟧 DriverLocationUpdated
...

This is a rich domain. I see at least 3 bounded contexts emerging:
1. Ride Management (core)
2. Matching & Dispatch (core)
3. Pricing & Billing (supporting)

Shall I continue to Phase 2 (timeline ordering)?
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full DDD session: discovery, event storming, contexts, tactical design |
| `--strategic` | Strategic design only (bounded contexts, context map, ubiquitous language) |
| `--tactical` | Tactical design only (aggregates, entities, value objects, events) |
| `--event-storm` | Facilitated event storming session |
| `--aggregate <name>` | Design a specific aggregate's internal structure |
| `--context-map` | Generate or update the bounded context map only |
| `--language` | Build or update the ubiquitous language glossary |
| `--scaffold` | Generate directory structure and skeleton code from the domain model |
| `--validate` | Validate existing domain model against DDD principles |

## HARD RULES

1. **NEVER start with the database schema.** Model the domain first. Persistence is derived.
2. **NEVER create a God Aggregate** — if an aggregate has more than 3-4 entities, split it.
3. **NEVER share domain objects across bounded contexts.** Each context owns its model.
4. **NEVER hold direct object references across aggregate boundaries.** Use IDs only.
5. **NEVER force immediate consistency across aggregates** — use domain events and eventual consistency.
6. **ALWAYS define ubiquitous language before writing code** — code speaks the domain language.
7. **ALWAYS start with events, not entities** — events reveal real behavior, entities emerge from grouping events.
8. **git commit BEFORE verify** — commit domain model artifacts, then validate against DDD principles.
9. **TSV logging** — log every DDD session:
   ```
   timestamp	domain	bounded_contexts	aggregates	events	value_objects	verdict
   ```

## Auto-Detection

On activation, automatically detect domain context:

```
AUTO-DETECT:
1. Existing domain structure:
   find src/ -type d -name "domain" -o -name "models" -o -name "entities" \
     -o -name "aggregates" -o -name "events" 2>/dev/null

2. Existing domain objects:
   grep -r "class.*Entity\|class.*Aggregate\|class.*ValueObject\|interface.*Repository" \
     src/ --include="*.ts" --include="*.java" --include="*.cs" -l 2>/dev/null

3. Domain events:
   grep -r "Event\|EventHandler\|EventBus\|publish.*event\|emit.*event" \
     src/ --include="*.ts" --include="*.java" -l 2>/dev/null

4. Anemic domain model detection:
   # Look for models that are just data bags (getters/setters only, no behavior)
   # Flag if entity classes have no methods beyond get/set

5. Service layer:
   find src/ -type f -name "*Service*" -o -name "*UseCase*" -o -name "*Handler*" 2>/dev/null
   # Detect if business logic lives in services (anemic) vs domain objects (rich)

6. Module/context boundaries:
   ls -d src/*/ 2>/dev/null
   # Detect existing module structure that may map to bounded contexts

-> Auto-identify if project uses DDD patterns already or is CRUD-based.
-> Auto-detect existing bounded context candidates from module structure.
-> Auto-flag anemic domain models for enrichment.
-> Only ask user about core vs supporting domain classification.
```

## Anti-Patterns

- **Do NOT start with the database schema.** DDD models the domain, not the database. The persistence model is derived from the domain model, not the other way around.
- **Do NOT create one big aggregate.** If your aggregate contains every entity in the system, you have a God Aggregate. Split it. One aggregate per transactional boundary.
- **Do NOT share domain objects across bounded contexts.** Each context has its own model. An "Order" in Ordering is different from an "Order" in Fulfillment. Translate at the boundary.
- **Do NOT use DDD for CRUD.** If the domain logic is "save this, read that, delete the other," DDD adds complexity without value. Use DDD where business rules are complex.
- **Do NOT skip the ubiquitous language.** Code that uses technical terms instead of domain terms (e.g., `processRecord` instead of `placeOrder`) creates a translation layer in every developer's head.
- **Do NOT hold references across aggregate boundaries.** Use IDs. Direct references create hidden coupling and make it impossible to enforce transactional boundaries.
- **Do NOT force immediate consistency across aggregates.** If two aggregates must be consistent, they should probably be one aggregate. Otherwise, use domain events and eventual consistency.
- **Do NOT model the entire domain at once.** Start with the core domain. Model supporting domains simply. Use off-the-shelf for generic domains. Expand DDD coverage only when complexity justifies it.
