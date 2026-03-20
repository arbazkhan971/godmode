---
name: architect
description: |
  Software architecture skill. Activates when user needs to design system architecture, select architecture patterns, create C4 diagrams, or apply domain-driven design at the strategic level. Evaluates trade-offs across monolith, microservices, serverless, event-driven, CQRS, and hexagonal architectures. Produces architecture decision records, C4 diagrams, and bounded context maps. Triggers on: /godmode:architect, "design the architecture", "system design", "how should I structure this", or when the orchestrator detects architecture-level decisions.
---

# Architect — Software Architecture Design

## When to Activate
- User invokes `/godmode:architect`
- User says "design the architecture", "system design", "how should I structure this"
- User asks about monolith vs. microservices, serverless, or event-driven decisions
- When starting a greenfield project that needs structural decisions
- When `/godmode:think` identifies architecture as the primary concern
- When a system is hitting scaling, reliability, or maintainability walls

## Workflow

### Step 1: Context & Requirements Gathering
Understand the system before recommending architecture:

```
ARCHITECTURE CONTEXT:
System: <name and purpose>
Stage: <greenfield | evolving | rewrite | migration>
Team size: <how many developers will work on this>
Scale expectations:
  - Users: <expected concurrent/total users>
  - Data volume: <expected data growth>
  - Throughput: <requests/sec, messages/sec>
  - Latency requirements: <p50, p95, p99 targets>
Deployment: <cloud provider | on-prem | hybrid>
Existing constraints:
  - Tech stack: <languages, frameworks, databases already chosen>
  - Compliance: <regulatory requirements: HIPAA, SOC2, GDPR, PCI-DSS>
  - Budget: <infrastructure budget constraints>
  - Timeline: <delivery timeline pressure>
```

### Step 2: Architecture Pattern Evaluation
Evaluate candidate patterns against the requirements. Always evaluate at least 3 patterns:

#### Pattern 1: Monolith (Modular)
```
PATTERN: Modular Monolith
├── Structure: Single deployable unit with well-defined internal module boundaries
├── Best when:
│   ├── Team is small (1-8 developers)
│   ├── Domain boundaries are unclear or evolving
│   ├── Time to market is critical
│   └── Operational simplicity is valued
├── Trade-offs:
│   ├── ✓ Simple deployment and debugging
│   ├── ✓ No network latency between modules
│   ├── ✓ Single database transactions
│   ├── ✓ Easy refactoring across module boundaries
│   ├── ✗ Scales as a unit (vertical first, then horizontal)
│   ├── ✗ Single tech stack
│   ├── ✗ Risk of module boundary erosion over time
│   └── ✗ Deployment requires full redeploy
└── Scaling ceiling: ~50 developers, ~10K req/sec (with optimization)
```

#### Pattern 2: Microservices
```
PATTERN: Microservices
├── Structure: Independent services communicating via APIs/messaging
├── Best when:
│   ├── Team is large (15+ developers) or multiple teams
│   ├── Domain boundaries are well-understood
│   ├── Independent scaling of components is required
│   └── Polyglot tech stack is beneficial
├── Trade-offs:
│   ├── ✓ Independent deployment and scaling
│   ├── ✓ Technology diversity per service
│   ├── ✓ Fault isolation
│   ├── ✓ Team autonomy and ownership
│   ├── ✗ Distributed system complexity (network, consistency, debugging)
│   ├── ✗ Operational overhead (monitoring, deployment, service mesh)
│   ├── ✗ Data consistency requires sagas or eventual consistency
│   └── ✗ Integration testing is harder
└── Scaling ceiling: Virtually unlimited with proper infrastructure
```

#### Pattern 3: Serverless / FaaS
```
PATTERN: Serverless
├── Structure: Functions triggered by events, managed infrastructure
├── Best when:
│   ├── Workload is bursty or unpredictable
│   ├── Cost optimization (pay-per-invocation) is important
│   ├── Team wants zero infrastructure management
│   └── Event-driven workflows dominate
├── Trade-offs:
│   ├── ✓ Zero infrastructure management
│   ├── ✓ Auto-scaling to zero and to peak
│   ├── ✓ Pay only for actual usage
│   ├── ✓ Fast time to production for simple services
│   ├── ✗ Cold start latency
│   ├── ✗ Vendor lock-in
│   ├── ✗ Execution duration limits
│   └── ✗ Difficult to test locally and debug in production
└── Scaling ceiling: Provider limits (1000+ concurrent, varies by provider)
```

#### Pattern 4: Event-Driven
```
PATTERN: Event-Driven Architecture
├── Structure: Components communicate through events via message broker
├── Best when:
│   ├── Loose coupling between components is essential
│   ├── Audit trail / event sourcing is required
│   ├── Real-time data propagation is needed
│   └── Multiple consumers need to react to same business events
├── Trade-offs:
│   ├── ✓ Extreme loose coupling
│   ├── ✓ Natural audit log (event store)
│   ├── ✓ Easy to add new consumers without changing producers
│   ├── ✓ Resilient to consumer failures (replay from broker)
│   ├── ✗ Eventual consistency (not immediately consistent)
│   ├── ✗ Event ordering and deduplication complexity
│   ├── ✗ Debugging event flows across services is hard
│   └── ✗ Event schema evolution requires careful management
└── Scaling ceiling: Broker-dependent (Kafka: millions of events/sec)
```

#### Pattern 5: CQRS (Command Query Responsibility Segregation)
```
PATTERN: CQRS
├── Structure: Separate models for read and write operations
├── Best when:
│   ├── Read and write workloads differ significantly
│   ├── Complex queries require denormalized read models
│   ├── Event sourcing is used for the write side
│   └── Read scalability must be independent of write scalability
├── Trade-offs:
│   ├── ✓ Optimized read and write models independently
│   ├── ✓ Read side scales independently
│   ├── ✓ Supports multiple read projections from same events
│   ├── ✓ Natural fit with event sourcing
│   ├── ✗ Increased system complexity
│   ├── ✗ Eventual consistency between read and write
│   ├── ✗ More code to maintain (two models instead of one)
│   └── ✗ Overkill for simple CRUD applications
└── Scaling ceiling: Depends on implementation; read side can scale independently
```

#### Pattern 6: Hexagonal (Ports & Adapters)
```
PATTERN: Hexagonal Architecture
├── Structure: Business logic at center, external concerns at edges via ports/adapters
├── Best when:
│   ├── Business logic is complex and must be protected from infrastructure changes
│   ├── Multiple interfaces to the same domain (API, CLI, events, scheduled jobs)
│   ├── Testability is a top priority
│   └── Infrastructure may change (swap databases, message brokers, etc.)
├── Trade-offs:
│   ├── ✓ Business logic fully decoupled from infrastructure
│   ├── ✓ Highly testable (mock adapters, test domain in isolation)
│   ├── ✓ Easy to swap infrastructure (database, queue, API)
│   ├── ✓ Clear dependency direction (always inward)
│   ├── ✗ More interfaces and boilerplate
│   ├── ✗ Can feel over-engineered for simple CRUD
│   ├── ✗ Team needs to understand the pattern discipline
│   └── ✗ Risk of anemic domain if ports are too thin
└── Scaling ceiling: Pattern-agnostic; depends on how it's deployed
```

### Step 3: Architecture Comparison Matrix
Present a structured comparison:

```
┌────────────────────────────────────────────────────────────────────────────────┐
│  ARCHITECTURE COMPARISON — <system name>                                       │
├──────────────────┬──────────┬──────────┬──────────┬──────────┬────────────────┤
│  Criterion       │ Option A │ Option B │ Option C │ Weight   │ Notes          │
├──────────────────┼──────────┼──────────┼──────────┼──────────┼────────────────┤
│  Scalability     │  ★★★☆☆  │  ★★★★★  │  ★★★★☆  │  HIGH    │ <context>      │
│  Simplicity      │  ★★★★★  │  ★★☆☆☆  │  ★★★☆☆  │  HIGH    │ <context>      │
│  Team fit        │  ★★★★☆  │  ★★☆☆☆  │  ★★★★☆  │  MEDIUM  │ <context>      │
│  Time to market  │  ★★★★★  │  ★★☆☆☆  │  ★★★★☆  │  HIGH    │ <context>      │
│  Cost            │  ★★★★☆  │  ★★☆☆☆  │  ★★★★★  │  MEDIUM  │ <context>      │
│  Testability     │  ★★★☆☆  │  ★★★★☆  │  ★★★★★  │  MEDIUM  │ <context>      │
│  Reliability     │  ★★★☆☆  │  ★★★★★  │  ★★★★☆  │  HIGH    │ <context>      │
│  Maintainability │  ★★★★☆  │  ★★★☆☆  │  ★★★★★  │  HIGH    │ <context>      │
├──────────────────┼──────────┼──────────┼──────────┼──────────┼────────────────┤
│  WEIGHTED TOTAL  │  <score> │  <score> │  <score> │          │                │
└──────────────────┴──────────┴──────────┴──────────┴──────────┴────────────────┘

RECOMMENDATION: <pattern> because <1-2 sentence justification tied to requirements>
```

### Step 4: C4 Architecture Diagrams
Produce diagrams at all four C4 levels for the chosen architecture:

#### Level 1: System Context
Who uses the system and what external systems does it interact with?
```
C4 CONTEXT DIAGRAM:
┌─────────────────────────────────────────────────┐
│                   Users / Actors                │
│  [Web User]  [Mobile User]  [Admin]  [API Consumer] │
└──────────┬──────────┬──────────┬───────────────┘
           │          │          │
           ▼          ▼          ▼
┌─────────────────────────────────────────────────┐
│              <<System>>                         │
│              <System Name>                      │
│              <One-line description>              │
└──────────┬──────────┬──────────┬───────────────┘
           │          │          │
           ▼          ▼          ▼
┌──────────┐ ┌──────────┐ ┌──────────────────────┐
│ External │ │ External │ │ External             │
│ System A │ │ System B │ │ System C             │
│ <purpose>│ │ <purpose>│ │ <purpose>            │
└──────────┘ └──────────┘ └──────────────────────┘
```

#### Level 2: Container Diagram
What are the major deployable units?
```
C4 CONTAINER DIAGRAM:
┌──────────────────────────────────────────────────────┐
│  <<System>> <System Name>                            │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │
│  │ Web App  │  │ API      │  │ Worker Service   │   │
│  │ (React)  │──│ (Node.js)│──│ (Python)         │   │
│  │ :3000    │  │ :8080    │  │ Async processing │   │
│  └──────────┘  └────┬─────┘  └────────┬─────────┘   │
│                     │                 │              │
│              ┌──────┴──────┐  ┌──────┴──────┐       │
│              │ PostgreSQL  │  │ Redis       │       │
│              │ Primary DB  │  │ Cache/Queue │       │
│              └─────────────┘  └─────────────┘       │
└──────────────────────────────────────────────────────┘
```

#### Level 3: Component Diagram
What are the major components within each container?
```
C4 COMPONENT DIAGRAM — <Container Name>:
┌──────────────────────────────────────────────────────┐
│  <<Container>> API Service                           │
│                                                      │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │ Auth         │  │ Rate Limiter │                  │
│  │ Controller   │  │ Middleware   │                  │
│  └──────┬───────┘  └──────┬───────┘                  │
│         │                 │                          │
│  ┌──────┴─────────────────┴───────┐                  │
│  │       Domain Services          │                  │
│  │  ┌─────────┐  ┌────────────┐   │                  │
│  │  │ Order   │  │ Inventory  │   │                  │
│  │  │ Service │  │ Service    │   │                  │
│  │  └────┬────┘  └─────┬──────┘   │                  │
│  └───────┼─────────────┼──────────┘                  │
│          │             │                             │
│  ┌───────┴─────────────┴──────────┐                  │
│  │     Infrastructure Layer       │                  │
│  │  ┌───────────┐  ┌──────────┐   │                  │
│  │  │ Postgres  │  │ Redis    │   │                  │
│  │  │ Adapter   │  │ Adapter  │   │                  │
│  │  └───────────┘  └──────────┘   │                  │
│  └────────────────────────────────┘                  │
└──────────────────────────────────────────────────────┘
```

#### Level 4: Code Diagram
What are the key classes/modules and their relationships?
```
C4 CODE DIAGRAM — <Component>:
Show key interfaces, classes, and their relationships.
Use the codebase's actual language idioms (classes for Java/C#,
modules for Python/Go, types for TypeScript).
```

### Step 5: Domain-Driven Design — Strategic View
Map bounded contexts and their relationships:

```
BOUNDED CONTEXT MAP:
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌──────────────┐    Partnership    ┌──────────────┐            │
│  │   Ordering   │◄────────────────►│  Inventory   │            │
│  │   Context    │                   │  Context     │            │
│  └──────┬───────┘                   └──────────────┘            │
│         │                                                       │
│   Customer/                                                     │
│   Supplier                                                      │
│         │                                                       │
│  ┌──────▼───────┐    Conformist     ┌──────────────┐            │
│  │   Billing    │──────────────────►│  Payment     │            │
│  │   Context    │                   │  Gateway     │            │
│  └──────────────┘                   │  (External)  │            │
│                                     └──────────────┘            │
│  ┌──────────────┐   ACL            ┌──────────────┐            │
│  │  Reporting   │◄─────────────────│  Legacy      │            │
│  │  Context     │  Anti-Corruption │  System      │            │
│  └──────────────┘  Layer           └──────────────┘            │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

RELATIONSHIP TYPES:
- Partnership: Two teams cooperate, both evolve the interface
- Customer/Supplier: Downstream depends on upstream, upstream considers downstream needs
- Conformist: Downstream conforms to upstream's model without influence
- Anti-Corruption Layer (ACL): Downstream translates upstream's model to protect its own
- Shared Kernel: Two contexts share a subset of the domain model
- Open Host Service: Upstream exposes a well-defined protocol for any consumer
```

### Step 6: Quality Attribute Analysis
For the recommended architecture, analyze non-functional requirements:

```
QUALITY ATTRIBUTES:
┌─────────────────────┬────────────────────────────────────────────┐
│ Attribute           │ How the architecture addresses it          │
├─────────────────────┼────────────────────────────────────────────┤
│ Scalability         │ <specific mechanism: horizontal scaling,   │
│                     │  sharding, read replicas, etc.>            │
├─────────────────────┼────────────────────────────────────────────┤
│ Reliability         │ <redundancy, failover, circuit breakers,   │
│                     │  retry policies, health checks>            │
├─────────────────────┼────────────────────────────────────────────┤
│ Maintainability     │ <module boundaries, dependency direction,  │
│                     │  testability, deployment independence>      │
├─────────────────────┼────────────────────────────────────────────┤
│ Security            │ <auth boundaries, network segmentation,    │
│                     │  encryption at rest/transit, secrets mgmt> │
├─────────────────────┼────────────────────────────────────────────┤
│ Observability       │ <logging, metrics, tracing, alerting>      │
├─────────────────────┼────────────────────────────────────────────┤
│ Performance         │ <caching, async processing, CDN,           │
│                     │  database optimization>                    │
└─────────────────────┴────────────────────────────────────────────┘
```

### Step 7: Architecture Decision Record
Document the decision formally:

```markdown
# ADR-<number>: <Architecture Decision Title>

## Status
Accepted

## Context
<What is the issue? What forces are at play?>

## Decision
<What is the architecture decision?>

## Consequences
### Positive
- <benefit 1>
- <benefit 2>

### Negative
- <trade-off 1>
- <trade-off 2>

### Risks
- <risk 1 and mitigation>
- <risk 2 and mitigation>
```

### Step 8: Artifacts & Transition
1. Save architecture document: `docs/architecture/<system>-architecture.md`
2. Save ADR: `docs/adr/<number>-<decision>.md`
3. Save diagrams inline in the architecture document
4. Commit: `"architect: <system> — <pattern> architecture with C4 diagrams and ADR"`
5. Suggest next steps:
   - "Architecture designed. Run `/godmode:ddd` to define domain boundaries and aggregates."
   - "Architecture designed. Run `/godmode:plan` to decompose into implementation tasks."
   - "Architecture designed. Run `/godmode:api` to design the API layer."

## Key Behaviors

1. **Requirements before patterns.** Never recommend an architecture without understanding scale expectations, team size, and constraints. A microservice architecture for a 2-person team is malpractice.
2. **Always compare at least 3 options.** Even if the answer seems obvious, the comparison matrix forces rigorous thinking and documents why alternatives were rejected.
3. **C4 diagrams are mandatory.** At minimum produce Level 1 (Context) and Level 2 (Container) diagrams. Level 3 and 4 are produced when the user asks for detail.
4. **Trade-offs are honest.** Every pattern has real downsides. Never present an architecture as having no weaknesses.
5. **ADRs capture the "why."** The Architecture Decision Record explains the reasoning, not just the decision. Future developers will thank you.
6. **Bounded contexts before microservices.** If recommending microservices, the bounded context map must come first. Services without clear domain boundaries become a distributed monolith.
7. **Validate against the team.** The best architecture is one the team can actually build and operate. Factor in team experience and operational maturity.

## Example Usage

### Designing a new e-commerce platform
```
User: /godmode:architect Design the architecture for a new e-commerce platform.
      We expect 10K concurrent users, team of 6 developers.

Architect: Gathering requirements...

ARCHITECTURE CONTEXT:
System: E-commerce Platform
Stage: Greenfield
Team size: 6 developers
Scale: 10K concurrent users, 500 req/sec peak
Deployment: AWS

Evaluating patterns...

┌────────────────────────────────────────────────────────────────────┐
│  ARCHITECTURE COMPARISON — E-Commerce Platform                     │
├──────────────────┬──────────┬──────────┬──────────┬───────────────┤
│  Criterion       │ Modular  │ Micro-   │ Server-  │ Weight        │
│                  │ Monolith │ services │ less     │               │
├──────────────────┼──────────┼──────────┼──────────┼───────────────┤
│  Scalability     │  ★★★☆☆  │  ★★★★★  │  ★★★★☆  │  HIGH         │
│  Simplicity      │  ★★★★★  │  ★★☆☆☆  │  ★★★☆☆  │  HIGH         │
│  Team fit (6)    │  ★★★★★  │  ★★☆☆☆  │  ★★★☆☆  │  HIGH         │
│  Time to market  │  ★★★★★  │  ★★☆☆☆  │  ★★★★☆  │  HIGH         │
│  Cost            │  ★★★★☆  │  ★★☆☆☆  │  ★★★★★  │  MEDIUM       │
│  Maintainability │  ★★★★☆  │  ★★★★★  │  ★★★☆☆  │  HIGH         │
├──────────────────┼──────────┼──────────┼──────────┼───────────────┤
│  WEIGHTED TOTAL  │  32      │  24      │  27      │               │
└──────────────────┴──────────┴──────────┴──────────┴───────────────┘

RECOMMENDATION: Modular Monolith with hexagonal architecture internally.
Team of 6 is too small for microservices overhead. Modular boundaries
enable future extraction if needed.

Shall I produce C4 diagrams and an ADR for this architecture?
```

### Migrating from monolith to microservices
```
User: /godmode:architect Our monolith is hitting scaling limits at 50K req/sec.
      Team is 35 developers across 5 squads.

Architect: Analyzing constraints...
- 35 developers / 5 squads → strong case for service boundaries per squad
- 50K req/sec → identify hotspots first

RECOMMENDATION: Strangler Fig migration to event-driven microservices.
Extract highest-traffic bounded contexts first.

Migration strategy:
1. Identify bounded contexts (→ /godmode:ddd)
2. Extract hotspot service behind API gateway
3. Introduce event bus for cross-context communication
4. Migrate contexts one at a time over 6-12 months
5. Decommission monolith modules as services go live
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full architecture analysis with comparison matrix and C4 diagrams |
| `--quick` | Skip comparison matrix, recommend based on constraints |
| `--compare <p1> <p2> <p3>` | Compare specific patterns only |
| `--c4` | Focus on C4 diagram generation for an existing architecture |
| `--adr` | Generate an Architecture Decision Record only |
| `--context-map` | Generate bounded context map only |
| `--migrate` | Architecture migration analysis (current → target with strategy) |
| `--validate` | Validate existing architecture against stated requirements |

## Auto-Detection

Before prompting the user, automatically detect architecture context:

```
AUTO-DETECT SEQUENCE:
1. Detect project structure:
   - Monorepo? Check for nx.json, turbo.json, pnpm-workspace.yaml, lerna.json
   - Multi-service? Check for docker-compose.yml with multiple services
   - Single app? Standard project layout
2. Detect current architecture pattern:
   - Count service directories or Dockerfiles → monolith vs microservices
   - Check for message broker configs (kafka, rabbitmq, sqs) → event-driven
   - Check for API gateway configs (kong, nginx, traefik) → gateway pattern
3. Detect tech stack:
   - Languages: scan file extensions (.ts, .py, .go, .java, .rs)
   - Databases: grep for connection strings, ORM configs (prisma, typeorm, sqlalchemy)
   - Infrastructure: check for terraform, pulumi, cdk, cloudformation files
4. Detect team signals:
   - Count git contributors in last 6 months → team size proxy
   - Check CODEOWNERS file → team boundaries
5. Detect existing architecture docs:
   - Find docs/architecture/, docs/adr/, C4 diagrams, architecture.md
6. Detect scale indicators:
   - Check Dockerfile/k8s configs for replica counts
   - Check for auto-scaling configs, load balancer configs
7. Auto-configure:
   - Small team + single repo → likely modular monolith candidate
   - Multiple repos + multiple databases → likely already microservices
   - Event broker present → event-driven components exist
```

## Multi-Agent Dispatch

For comprehensive architecture analysis of large systems:

```
PARALLEL ARCHITECTURE ANALYSIS:
IF system has multiple services OR team_size > 10:
  Agent 1 (worktree: arch-patterns):
    - Evaluate architecture patterns against requirements
    - Build comparison matrix with weighted scoring
    - Produce recommendation with justification

  Agent 2 (worktree: arch-diagrams):
    - Generate C4 Level 1 (System Context) diagram
    - Generate C4 Level 2 (Container) diagram
    - Generate C4 Level 3 (Component) for key containers
    - Generate bounded context map

  Agent 3 (worktree: arch-quality):
    - Analyze quality attributes (scalability, reliability, security)
    - Identify architectural risks and mitigations
    - Evaluate operational complexity
    - Assess team fit for recommended architecture

  COORDINATOR merges into unified architecture document + ADR
```

## Anti-Patterns

- **Do NOT recommend microservices by default.** Microservices are a solution to organizational scaling, not a default. Most systems should start as a modular monolith.
- **Do NOT skip the requirements gathering.** "What architecture should I use?" without knowing team size, scale, and constraints is unanswerable. Ask.
- **Do NOT produce diagrams without explanation.** Every diagram must have accompanying text explaining the key decisions and trade-offs it represents.
- **Do NOT present one option.** Even for seemingly obvious choices, the comparison matrix documents why alternatives were rejected. This prevents revisiting the decision later.
- **Do NOT conflate architecture patterns with implementation patterns.** Microservices is an architecture pattern. Repository is an implementation pattern. They operate at different levels.
- **Do NOT ignore the team.** A technically perfect architecture that the team cannot build or operate is a failed architecture. Always factor in team experience.
- **Do NOT design for theoretical scale.** Design for 10x your current needs, not 1000x. You can re-architect when you have 1000x problems (and 1000x revenue to fund it).


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run architecture tasks sequentially: patterns, then diagrams, then quality attributes.
- Use branch isolation per task: `git checkout -b godmode-architect-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
