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

```bash
# Detect domain model patterns in codebase
grep -rn "class.*Aggregate\|class.*Entity\|class.*ValueObject" src/ --include="*.ts" --include="*.py"
grep -rn "Event\|EventHandler\|DomainEvent" src/ --include="*.ts" --include="*.py" | head -20
```

IF aggregate has > 4 entities: split into smaller aggregates.
WHEN same term means different things in 2 contexts: correct — separate glossary entries.
IF domain events > 50: group by context, verify no cross-context coupling.

1. **Start with events, not entities.** Events reveal behavior.
2. **Ubiquitous language non-negotiable.** Code = domain language.
3. **Bounded contexts are social.** Follow team/language boundaries.
4. **Aggregates are small.** Max 3-4 entities per aggregate.
5. **Reference by ID across aggregates.** Never direct object refs.
6. **Eventual consistency between contexts.** Use domain events.
7. **Not everything needs DDD.** CRUD and reports don't benefit.
8. **Event storming is collaborative.** Structured thinking catches errors.

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
```
AUTO-DETECT:
1. Scan for domain dirs: find src/ -type d -name "domain" -o -name "aggregates" -o -name "events"
2. Scan for domain objects: grep -r "class.*Entity\|class.*Aggregate\|class.*ValueObject" src/ -l
3. Scan for domain events: grep -r "Event\|EventHandler\|EventBus" src/ -l
4. Anemic model detection: models with only getters/setters, no behavior methods
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
1. Core domain identified. >= 5 ubiquitous language terms defined.
2. Event storming through Phase 4 (aggregates identified).
3. All aggregates have invariants, commands, events.
4. No aggregate > 4 entities. Cross-refs by ID only.

## Error Recovery
| Failure | Action |
|--|--|
| User starts with DB schema | Redirect: model domain first. Schema is derived. |
| Aggregate > 4 entities | Split. Use domain events between parts. |
| Term collision across contexts | Correct DDD — separate glossary entries per context. |

## Keep/Discard Discipline
```
KEEP if: invariants enforceable AND aggregate <= 4 entities
DISCARD if: oversized OR inconsistent language within context
```

## Stop Conditions
```
STOP when: contexts + aggregates + events defined
  AND glossary >= 5 terms AND context map complete
  OR user requests stop
```

