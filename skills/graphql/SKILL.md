---
name: graphql
description: |
  GraphQL API development skill. Activates when user needs to design, build, optimize, or test GraphQL APIs. Covers schema design (SDL-first and code-first), resolver architecture, N+1 query detection with DataLoader patterns, subscription implementation, schema federation for microservices, and performance hardening (query complexity limits, depth limiting, persisted queries). Produces production-ready schemas, resolvers, and test suites. Triggers on: /godmode:graphql, "build a GraphQL API", "design GraphQL schema", "fix N+1 queries", "set up subscriptions", or when the orchestrator detects GraphQL-related work.
---

# GraphQL — API Development

## When to Activate
- User invokes `/godmode:graphql`
- User says "build a GraphQL API", "design GraphQL schema", "add a query/mutation"
- User says "fix N+1 queries", "add DataLoader", "optimize GraphQL performance"
- User says "set up GraphQL subscriptions", "add real-time updates"
- User says "federate my schema", "split schema across services"
- When `/godmode:plan` identifies GraphQL-related tasks
- When `/godmode:review` flags GraphQL performance or design issues

## Workflow

### Step 1: Discovery & Context
Understand the GraphQL API requirements before writing any schema:

```
GRAPHQL DISCOVERY:
Project: <name and purpose>
Approach: SDL-first | Code-first
Framework: Apollo Server | GraphQL Yoga | Mercurius | Pothos | Nexus | TypeGraphQL | Strawberry | Ariadne | gqlgen
Language: TypeScript | Python | Go | Rust | Java
Consumers: <web app, mobile, third-party, internal services>
Scale: <expected queries/sec, subscription connections>
Auth model: <JWT, session, API key, none>
Existing schema: <list any existing types for consistency>
Real-time needs: <subscriptions, live queries, none>
Federation: <monolith | gateway with subgraphs>
```

If the user hasn't specified, ask: "SDL-first or code-first? What framework are you using?"

### Step 2: Schema Design — SDL-First Approach
Design the schema using Schema Definition Language as the source of truth:

```graphql
# ============================================================
# SCHEMA: <ServiceName>
# Approach: SDL-first
# ============================================================

# --- Scalars ---
scalar DateTime
scalar JSON
scalar Upload

# --- Enums ---
enum <EntityStatus> {
  ACTIVE
  INACTIVE
  ARCHIVED
```

Rules:
- Every mutation returns a payload type with the entity and an errors array — never throw for user errors
- Use Relay-style connection pagination for all list fields
- Input types are always separate from output types
- Non-nullable fields use `!` — be intentional about nullability
- Enums for fixed sets of values, never strings

### Step 3: Schema Design — Code-First Approach
For code-first projects, generate type-safe schema builders:

```
CODE-FIRST SCHEMA DESIGN:
Framework: <Pothos | Nexus | TypeGraphQL | gqlgen | Strawberry>

Architecture:
  src/
    graphql/
      schema.ts            # Schema builder entry point
      types/
        <entity>.ts        # Type definitions per domain entity
        connections.ts      # Shared pagination types
        errors.ts           # Error types and interfaces
      resolvers/
        <entity>.resolver.ts  # Resolvers per domain entity
      inputs/
        <entity>.input.ts   # Input type definitions
```

### Step 4: Resolver Architecture
Design resolvers with clear separation of concerns:

```
RESOLVER ARCHITECTURE:
  Request
  ▼
|  | Middleware | Auth, logging, rate limiting, tracing |
  └──────┬───────┘
  ▼
|  | Resolver | Orchestration only — no business logic |
|  | (thin layer) | Calls services, returns results |
  └──────┬───────┘
  ▼
```

Resolver implementation pattern:
```typescript
// RESOLVER PATTERN (TypeScript + Apollo)
const resolvers = {
  Query: {
    // Delegate to service layer
    entity: (_, { id }, ctx) => ctx.services.entity.findById(id),
    entities: (_, { filter, pagination }, ctx) =>
# ... (condensed)
```

### Step 5: N+1 Detection and DataLoader Patterns
Identify and eliminate N+1 query problems:

```
N+1 DETECTION CHECKLIST:
| Pattern | Status |
|---|---|
| List query with nested relations | CHECK for N+1 |
| Field resolver with DB call | MUST use DataLoader |
| Nested connection within list | CHECK batch strategy |
| Polymorphic relations (unions) | CHECK loader per type |
| Deeply nested queries (3+ levels) | CHECK cumulative load |

DATALOADER IMPLEMENTATION:
  WITHOUT DataLoader (N+1):
```

DataLoader factory pattern:
```typescript
// DATALOADER FACTORY
function createLoaders(db: Database) {
  return {
    user: new DataLoader<string, User>(async (ids) => {
      const users = await db.user.findMany({ where: { id: { in: [...ids] } } });
      const userMap = new Map(users.map(u => [u.id, u]));
# ... (condensed)
```

### Step 6: Subscription Implementation
Design real-time GraphQL subscriptions:

```
SUBSCRIPTION ARCHITECTURE:
  Transport: WebSocket (graphql-ws) | SSE (for HTTP/2)
  Protocol: graphql-ws (preferred) | subscriptions-transport-ws (legacy)
  Pub/Sub backend: In-memory | Redis | Kafka | NATS
  ┌──────────┐    ┌──────────┐    ┌──────────┐
|  | Client | ◄── | Gateway | ◄── | Pub/Sub |  |
|  | (WebSocket) |  | Server |  | Backend |  |
  └──────────┘    └──────────┘    └──────────┘
  ▲
  ┌───────┴───────┐
|  | Mutation |  |
```

### Step 7: Schema Federation for Microservices

```
FEDERATION: Client -> Gateway (Router) -> Subgraphs (each owns domain types)
Version: Apollo Federation v2 | GraphQL Mesh | Cosmo | Grafbase

SUBGRAPH RULES:
  1. Each subgraph owns its entities — single source of truth
  2. @key directive for entity lookup: type User @key(fields: "id") { ... }
  3. Extend types across subgraphs with reference resolvers
  4. @shareable for types used across subgraphs
  5. Gateway handles query planning — subgraphs never call each other

COMPOSITION CHECKS: @key fields have __resolveReference, no ownership conflicts,
  shared types @shareable, no circular deps, composition succeeds
```

### Step 8: Performance Hardening
Protect the GraphQL API from abuse and ensure performance:

```
PERFORMANCE DEFENSES:

1. QUERY COMPLEXITY ANALYSIS:
   ─────────────────────────
   Assign cost to each field and reject queries exceeding threshold:

   type Query {
     users(first: Int): UserConnection  # cost: first * 2 (list multiplier)
   }
   type User {
     name: String    # cost: 1
     posts: [Post]   # cost: 10 (nested list)
   }

   Max complexity: 1000 per query
```

### Step 9: Testing GraphQL APIs

```
TESTING LAYERS:
  Schema validation: buildSchema — verify valid SDL
  Resolver unit tests: mock context, test in isolation (Jest/Vitest)
  Integration tests: full query execution against test server (supertest)
  N+1 regression: instrument DB, assert query count per operation — fail CI on regression
  Contract: graphql-inspector diff — block merge on breaking changes without version bump
  Schema snapshot: snapshot printed schema, diff catches unintended changes
```

### Step 10: Artifacts & Completion
Generate the deliverables:

```
GRAPHQL DESIGN COMPLETE:

Artifacts:
- Schema: src/graphql/schema.graphql (or generated from code-first)
- Resolvers: src/graphql/resolvers/<entity>.resolver.ts
- DataLoaders: src/graphql/loaders/<entity>.loader.ts
- Subscriptions: src/graphql/subscriptions/<entity>.subscription.ts
- Tests: tests/graphql/<entity>.test.ts
- Performance config: src/graphql/plugins/{complexity,depth-limit}.ts

Metrics:
- Types: <N> object types, <M> input types, <K> enums
- Operations: <N> queries, <M> mutations, <K> subscriptions
- N+1 protection: DataLoaders for all relation fields
- Performance: complexity limit <X>, depth limit <Y>
```

Commit: `"graphql: <service> — <N> types, <M> operations, DataLoaders, subscriptions configured"`

## Key Behaviors

1. **Schema is the contract.** Whether SDL-first or code-first, the schema is the source of truth. Design it before implementing resolvers.
2. **DataLoaders are mandatory.** Every field resolver that fetches data must use a DataLoader. No exceptions. N+1 queries are bugs.
3. **Mutations return payloads, not raw types.** Every mutation returns a payload with the entity and an errors array. Never throw for user-facing errors.
4. **Performance defenses are not optional.** Every production GraphQL API must have depth limiting, complexity analysis, and either persisted queries or an allowlist.
5. **Federation is an architecture decision.** Do not federate prematurely. Start monolithic and extract subgraphs when team boundaries or scaling demands require it.
6. **Test the schema, not just the resolvers.** Schema snapshot tests catch accidental breaking changes. Query count tests catch N+1 regressions. Both run in CI.
7. **Subscriptions need infrastructure.** In-memory pub/sub works for development. Production requires Redis, Kafka, or NATS — and connection limits.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full GraphQL design workflow |
| `--sdl` | SDL-first schema design |
| `--code-first` | Code-first schema design (Pothos, Nexus, TypeGraphQL) |

## Auto-Detection

```
1. Framework: apollo-server, graphql-yoga, mercurius, pothos, nexus, type-graphql, strawberry, gqlgen
2. Approach: *.graphql files = SDL-first, schema builder imports = code-first
3. DataLoader: scan for dataloader imports — flag if missing with relation resolvers
4. Subscriptions: graphql-ws, Redis pub/sub config
5. Federation: @apollo/subgraph, @apollo/gateway, federation directives
6. Performance: query-complexity, depth-limit, persisted queries config
7. N+1: field resolvers with direct DB calls (no DataLoader)
```

## Explicit Loop Protocol

```
FOR each entity (dependency order, leaf entities first):
  1. DESIGN types, connections, inputs, mutation payloads
  2. IMPLEMENT resolvers (queries + mutations)
  3. CREATE DataLoaders for all relation fields
  4. WRITE tests (unit + integration + N+1 query count assertions)
  5. REPORT: "Entity <N>/<total>: <name> — <X> queries, <Y> mutations"
ON COMPLETION: Add complexity/depth limits, run schema validation
```

## Hard Rules

```
HARD RULES — GRAPHQL:
1. EVERY field resolver that fetches data MUST use a DataLoader. No exceptions. N+1 queries are bugs.
2. EVERY mutation MUST return a payload type with the entity and an errors array. Never throw for user-facing errors.
3. EVERY list field MUST use Relay-style connection pagination (edges, pageInfo, totalCount).
4. NEVER expose database column names directly as GraphQL fields. Design the schema for consumers, not the database.
5. ALWAYS use separate input types for create vs update. They have different required fields and validation rules.
6. ALWAYS add depth limiting and complexity analysis to production APIs. Without them, one query can bring down the server.
7. ALWAYS use persisted queries or an allowlist in production. Arbitrary query strings are an attack surface.
8. NEVER share message/input types across multiple operations. Each query/mutation gets its own input and output types.
9. ALWAYS run schema snapshot tests and breaking change detection in CI. Accidental breaking changes break clients.
10. NEVER federate prematurely. Start monolithic. Extract subgraphs only when team boundaries or scaling demands it.
```

## Output Format

```
GRAPHQL DESIGN COMPLETE:
  Schema: <path to schema file(s)>
  Types: <N> object types, <M> input types, <K> enums
  Queries: <N> root queries
  Mutations: <M> root mutations
  Subscriptions: <S> subscription fields
  DataLoaders: <D> loaders (batch + grouped)
  Pagination: Relay connections on all list fields
  Auth: <mechanism> applied to <N> resolvers
  Performance: depth limit <N>, complexity limit <N>, persisted queries <on|off>
  Validation: schema snapshot <PASS|FAIL>, breaking changes <NONE|N found>

SCHEMA SUMMARY:
|  Domain        | Types | Queries | Mutations | DataLoaders    |
|---|---|---|---|---|
|  <domain>      | N     | N       | N         | N              |
```

## TSV Logging

Log every GraphQL design session to `.godmode/graphql-results.tsv`:

```
Fields: timestamp\tproject\ttypes_count\tqueries_count\tmutations_count\tdataloaders_count\tn1_issues_found\tn1_issues_fixed\tvalidation_status\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-api\t24\t8\t12\t15\t3\t3\tPASS\tabc1234
```

Append after every completed design or extension pass. One row per session. If the file does not exist, create it with a header row.

## Success Criteria

```
GRAPHQL SUCCESS CRITERIA:
|  Criterion                                  | Required         |
|---|---|
|  Schema compiles without errors             | YES              |
|  All list fields use Relay connections       | YES              |
|  All relation fields have DataLoaders       | YES              |
|  All mutations return payload types          | YES              |
|  Depth limit configured                     | YES              |
|  Complexity limit configured                | YES              |
|  N+1 regression tests pass (query counts)   | YES              |
|  Schema snapshot test passes                | YES              |
|  No breaking changes vs previous schema     | YES (if exists)  |
|  Persisted queries or allowlist in prod     | YES (production)  |

VERDICT: ALL required criteria must PASS. Any FAIL → fix before commit.
```

## Error Recovery

```
ERROR RECOVERY — GRAPHQL:
1. Schema compilation fails:
   → Read SDL error output. Fix syntax (missing types, circular refs, duplicate names). Re-compile. Repeat until clean.
2. N+1 query detected (query count exceeds expected):
   → Identify the resolver making direct DB calls. Create a DataLoader (batch or grouped). Replace direct call with loader. Re-test query count.
3. Breaking change detected vs previous schema:
   → Run graphql-inspector diff. Revert removals/type changes. Add new fields instead of modifying existing ones. Use @deprecated for removals.
4. Mutation returns raw error instead of payload type:
   → Wrap mutation return in a payload type: { entity: T, errors: [UserError] }. Move error handling from throw to errors array.
5. Subscription not receiving events:
   → Verify pub/sub backend is connected. Check topic name matches between publish and subscribe. Verify auth context is passed to subscription resolver.
6. Complexity/depth limit blocks legitimate queries:
   → Analyze the blocked query. If legitimate, increase limit or add cost overrides for specific fields. If malicious, keep the limit.
```

## Keep/Discard Discipline

After each GraphQL implementation pass, evaluate:
- **KEEP** if: schema compiles without errors, all relation fields use DataLoaders (zero N+1), all mutations return payload types, depth/complexity limits configured, no breaking changes vs previous schema.
- **DISCARD** if: N+1 query detected (resolver with direct DB call), mutation throws instead of returning error payload, list field lacks Relay connection pagination, or breaking change detected without version bump.
- Run schema snapshot test and N+1 regression test before every commit.
- Revert schema changes that remove types/fields — use @deprecated instead.

## Stop Conditions

Stop the graphql skill when:
1. Schema compiles without errors and snapshot test passes.
2. All relation fields have DataLoaders (zero N+1 queries verified by query count assertions).
3. All mutations return payload types with entity and errors array.
4. Depth limit and complexity limit are configured for production.
5. No breaking changes detected vs previous schema version.

