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
| Term | Definition |
|--|--|
| <Term 1> | <Precise definition as understood by domain experts |
|  | AND developers. No ambiguity.> |
| <Term 2> | <Definition. Note: "Order" in the Sales context |
|  | means something different than in Fulfillment.> |
| <Term 3> | <Definition. Include what it is NOT if ambiguous.> |

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
| Command | Actor | Produces Event |
|--|--|--|
| PlaceOrder | Customer | OrderPlaced |
| ProcessPayment | Payment Gateway | PaymentReceived |
| ReserveInventory | System (auto) | InventoryReserved |
| ShipOrder | Warehouse Staff | OrderShipped |
| CancelOrder | Customer/System | OrderCancelled |
| IssueRefund | Support Agent | RefundIssued |
```

#### Phase 4: Aggregates
Group events around the entities that own them:
```
AGGREGATES:
  <<Aggregate>> Order
  Commands: PlaceOrder, CancelOrder
  Events: OrderPlaced, OrderCancelled,
  OrderShipped, OrderDelivered
  Invariants:
  - Order total stays > 0
  - Cannot cancel a delivered order
  - Cannot ship without payment

  <<Aggregate>> Inventory
  Commands: ReserveInventory, ReleaseInventory
```

#### Phase 5: Bounded Context Discovery
Draw boundaries around aggregates that share a ubiquitous language:
```
BOUNDED CONTEXTS (list each with its aggregates and ubiquitous language):
  [ORDERING CONTEXT]
    Aggregates: Order, Cart
    "Order" here means: items a customer wants to buy
  [FULFILLMENT CONTEXT]
    Aggregates: Shipment, Inventory
    "Order" here means: items to pick and ship from warehouse
```

### Step 4: Context Mapping
Define relationships between bounded contexts:

```
CONTEXT MAP:
  Ordering ──── Partnership ────► Fulfillment
│      │                                │                                │
  Customer/                      Customer/
  Supplier                       Supplier
│      │                                │                                │
  ▼                                ▼
  Billing ──── Conformist ────► Payment Gateway (External)
  Identity ──── Open Host Service ────► All Contexts
  (Published Language)
  Reporting ──── ACL ────► Legacy ERP System
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
```

#### Aggregate Design Rules
```
AGGREGATE BOUNDARY RULES:
1. CONSISTENCY BOUNDARY: Everything inside an aggregate is immediately
   consistent. Cross-aggregate operations are eventually consistent.

2. TRANSACTION BOUNDARY: One aggregate = one transaction. Never modify
   two aggregates in the same transaction.

3. SIZE RULE: Keep aggregates small. If an aggregate has more than
   3-4 entities, split it.

4. REFERENCE RULE: Aggregates reference each other by ID only, never
   by direct object reference.

5. CASCADE RULE: External code references only the aggregate root.
   Internal entities are accessed through the root.
```

### Step 6: Domain Event Catalog
Document all domain events for cross-context communication:

```
DOMAIN EVENT CATALOG:
| Event | Source | Payload |
|  | Context |  |
| OrderPlaced | Ordering | orderId, customerId, items[], |
|  |  | totalAmount, placedAt |
| PaymentReceived | Billing | paymentId, orderId, amount, |
|  |  | method, paidAt |
| InventoryReserved | Fulfillment | reservationId, orderId, items[], |
|  |  | warehouseId, reservedAt |
| OrderShipped | Fulfillment | shipmentId, orderId, trackingNo, |
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
4. **Aggregates are small.** If an aggregate contains more than 3-4 entities, it is too large. Small aggregates enable better concurrency and simpler code.
5. **Reference by ID across aggregates.** Never hold direct object references to entities in other aggregates. Use IDs and resolve them when needed.
6. **Eventual consistency between contexts.** Never force immediate consistency across contexts. Use domain events and accept eventual consistency.
7. **Not everything needs DDD.** CRUD operations, reports, and generic domains do not benefit from tactical DDD patterns. Reserve the investment for the core domain.
8. **Event storming is collaborative.** Even in a solo coding session, walk through the event storming phases. The structured thinking process catches model errors early.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full DDD session: discovery, event storming, contexts, tactical design |
| `--strategic` | Strategic design only (bounded contexts, context map, ubiquitous language) |
| `--tactical` | Tactical design only (aggregates, entities, value objects, events) |

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
```

## Output Format
Print on completion:
```
DDD SESSION: {domain_name}
Core domain: {core_domain_name}
Bounded contexts: {N} identified ({list})
Aggregates: {N} designed
Domain events: {N} cataloged
Value objects: {N} defined
Context map relationships: {N} mapped
Artifacts: {list of files created}
```

## TSV Logging
Log every DDD session to `.godmode/ddd-results.tsv`:
```
timestamp	domain	bounded_contexts	aggregates	events	value_objects	context_relationships	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. Core domain identified and distinguished from supporting and generic domains.
2. Ubiquitous language glossary created with at least 5 terms defined unambiguously.
3. Event storming completed through at least Phase 4 (aggregates identified).
4. Every aggregate has documented invariants, commands, and events.
5. Context map shows relationship types between all bounded contexts.
6. No aggregate contains more than 4 entities.
7. Cross-aggregate references use IDs only, never direct object references.
8. Domain event catalog includes source context, payload fields, and schema version.

## Error Recovery
```
IF user asks to start with database schema:
  → Redirect: "Model the domain first. Schema is derived from the domain model."
  → Begin with Step 1 (Domain Discovery) instead of Step 7 (Implementation Scaffold)
  → After domain model is complete, suggest: "/godmode:schema to generate the persistence layer"

IF aggregate grows beyond 4 entities:
  → Flag: "Aggregate {name} has {N} entities — exceeds recommended maximum of 4"
  → Analyze which entities to extract into separate aggregates
  → Verify: extracted entities communicate via domain events, not direct references

IF same term means different things in different contexts:
  → This is correct DDD behavior — create separate entries in each context's glossary
  → Document: "'Order' in Ordering = items customer wants to buy. 'Order' in Fulfillment = items to pick and ship."
  → Add anti-corruption layer or published language at the boundary

```

## Keep/Discard Discipline
```
After EACH aggregate design or context boundary decision:
  1. MEASURE: Does the aggregate protect its invariants? Are cross-aggregate references by ID only?
  2. COMPARE: Is the aggregate small (3-4 entities max)? Does the bounded context have a consistent language?
  3. DECIDE:
     - KEEP if: invariants are enforceable AND aggregate is small AND context language is consistent
     - DISCARD if: aggregate exceeds 4 entities OR same term means different things within one context
  4. Split oversized aggregates. Redraw context boundaries where language diverges.

Never keep an aggregate that requires modifying two aggregates in the same transaction.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Core domain has bounded contexts, aggregates, and event catalog defined
  - Ubiquitous language glossary has 5+ terms with unambiguous definitions
  - Context map shows relationships between all bounded contexts
  - User explicitly requests stop

DO NOT STOP just because:
  - Supporting/generic domains are not fully modeled (core domain is the priority)
  - Implementation scaffold is not yet generated (model correctness comes first)
```

