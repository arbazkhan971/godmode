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
}

# --- Input Types ---
input Create<Entity>Input {
  <field>: <Type>!
  <field>: <Type>
}

input Update<Entity>Input {
  <field>: <Type>
  <field>: <Type>
}

input <Entity>Filter {
  status: <EntityStatus>
  search: String
  createdAfter: DateTime
  createdBefore: DateTime
}

input PaginationInput {
  first: Int
  after: String
  last: Int
  before: String
}

# --- Object Types ---
type <Entity> {
  id: ID!
  <field>: <Type>!
  <field>: <Type>
  <relation>: <RelatedEntity>!
  <relations>: <RelatedEntityConnection>!
  createdAt: DateTime!
  updatedAt: DateTime!
}

# --- Connections (Relay-style pagination) ---
type <Entity>Connection {
  edges: [<Entity>Edge!]!
  pageInfo: PageInfo!
  totalCount: Int!
}

type <Entity>Edge {
  cursor: String!
  node: <Entity>!
}

type PageInfo {
  hasNextPage: Boolean!
  hasPreviousPage: Boolean!
  startCursor: String
  endCursor: String
}

# --- Queries ---
type Query {
  <entity>(id: ID!): <Entity>
  <entities>(
    filter: <Entity>Filter
    pagination: PaginationInput
    orderBy: <Entity>OrderBy
  ): <Entity>Connection!
}

# --- Mutations ---
type Mutation {
  create<Entity>(input: Create<Entity>Input!): Create<Entity>Payload!
  update<Entity>(id: ID!, input: Update<Entity>Input!): Update<Entity>Payload!
  delete<Entity>(id: ID!): Delete<Entity>Payload!
}

# --- Mutation Payloads ---
type Create<Entity>Payload {
  <entity>: <Entity>
  errors: [UserError!]!
}

type UserError {
  field: [String!]
  message: String!
  code: ErrorCode!
}

# --- Subscriptions ---
type Subscription {
  <entity>Created: <Entity>!
  <entity>Updated(id: ID): <Entity>!
  <entity>Deleted: ID!
}
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
      scalars/
        datetime.ts         # Custom scalar implementations
      context.ts            # Context type definition
      plugins/
        complexity.ts       # Query complexity plugin
        depth-limit.ts      # Depth limiting plugin
        auth.ts             # Auth directive/plugin

Design principles:
  - Types co-located with their resolvers
  - Shared types (PageInfo, UserError) in common module
  - Context carries auth, dataloaders, and DB connection
  - Plugins handle cross-cutting concerns
```

### Step 4: Resolver Architecture
Design resolvers with clear separation of concerns:

```
RESOLVER ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│  Request                                                     │
│    │                                                         │
│    ▼                                                         │
│  ┌──────────────┐                                            │
│  │  Middleware   │  Auth, logging, rate limiting, tracing     │
│  └──────┬───────┘                                            │
│         ▼                                                    │
│  ┌──────────────┐                                            │
│  │  Resolver     │  Orchestration only — no business logic   │
│  │  (thin layer) │  Calls services, returns results          │
│  └──────┬───────┘                                            │
│         ▼                                                    │
│  ┌──────────────┐                                            │
│  │  Service      │  Business logic, validation, rules        │
│  │  Layer        │  Framework-agnostic, testable in isolation│
│  └──────┬───────┘                                            │
│         ▼                                                    │
│  ┌──────────────┐                                            │
│  │  DataLoader   │  Batched, cached data fetching            │
│  │  Layer        │  One DataLoader per entity per request    │
│  └──────┬───────┘                                            │
│         ▼                                                    │
│  ┌──────────────┐                                            │
│  │  Data Source  │  Database, REST API, gRPC, cache          │
│  └──────────────┘                                            │
└─────────────────────────────────────────────────────────────┘

RESOLVER RULES:
1. Resolvers are THIN — they map GraphQL to service calls, nothing else
2. Business logic lives in the service layer, never in resolvers
3. Data fetching goes through DataLoaders, never direct DB calls from resolvers
4. Context is created per-request and carries auth, loaders, and services
5. Field resolvers are lazy — only called when the field is requested
6. Error handling uses union types or payload patterns, not exceptions
```

Resolver implementation pattern:
```typescript
// RESOLVER PATTERN (TypeScript + Apollo)
const resolvers = {
  Query: {
    // Delegate to service layer
    entity: (_, { id }, ctx) => ctx.services.entity.findById(id),
    entities: (_, { filter, pagination }, ctx) =>
      ctx.services.entity.findMany(filter, pagination),
  },
  Mutation: {
    createEntity: async (_, { input }, ctx) => {
      // Auth check via context
      ctx.auth.requirePermission('entity:create');
      // Delegate to service — returns { entity, errors }
      return ctx.services.entity.create(input);
    },
  },
  // Field resolvers use DataLoaders
  Entity: {
    relatedItems: (parent, _, ctx) =>
      ctx.loaders.relatedItem.loadMany(parent.relatedItemIds),
    author: (parent, _, ctx) =>
      ctx.loaders.user.load(parent.authorId),
  },
};
```

### Step 5: N+1 Detection and DataLoader Patterns
Identify and eliminate N+1 query problems:

```
N+1 DETECTION CHECKLIST:
┌──────────────────────────────────────────────────────────────┐
│  Pattern                           │  Status                 │
├────────────────────────────────────┼─────────────────────────┤
│  List query with nested relations  │  CHECK for N+1          │
│  Field resolver with DB call       │  MUST use DataLoader    │
│  Nested connection within list     │  CHECK batch strategy   │
│  Polymorphic relations (unions)    │  CHECK loader per type  │
│  Deeply nested queries (3+ levels) │  CHECK cumulative load  │
└────────────────────────────────────┴─────────────────────────┘

DATALOADER IMPLEMENTATION:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  WITHOUT DataLoader (N+1):                                   │
│  ────────────────────────                                    │
│  Query: posts { author { name } }                            │
│                                                              │
│  SELECT * FROM posts;           -- 1 query                   │
│  SELECT * FROM users WHERE id = 1;  -- N queries             │
│  SELECT * FROM users WHERE id = 2;  --   (one per post)     │
│  SELECT * FROM users WHERE id = 3;                           │
│  ...                                                         │
│                                                              │
│  WITH DataLoader (batched):                                  │
│  ──────────────────────────                                  │
│  SELECT * FROM posts;           -- 1 query                   │
│  SELECT * FROM users WHERE id IN (1, 2, 3, ...);  -- 1 query│
│                                                              │
│  Total: 2 queries instead of N+1                             │
│                                                              │
└─────────────────────────────────────────────────────────────┘

DATALOADER RULES:
1. One DataLoader instance per entity per request (never shared across requests)
2. DataLoaders are created in context factory, passed via context
3. Keys must be returned in the SAME ORDER as requested
4. Handle missing records: return null (not error) for optional relations
5. Batch function signature: (keys: K[]) => Promise<(V | Error)[]>
6. Cache is request-scoped — no cross-request pollution
7. For has-many relations, use a grouping loader:
   - Keys: parent IDs
   - Returns: arrays of children, grouped by parent ID
```

DataLoader factory pattern:
```typescript
// DATALOADER FACTORY
function createLoaders(db: Database) {
  return {
    user: new DataLoader<string, User>(async (ids) => {
      const users = await db.user.findMany({ where: { id: { in: [...ids] } } });
      const userMap = new Map(users.map(u => [u.id, u]));
      return ids.map(id => userMap.get(id) ?? new Error(`User ${id} not found`));
    }),

    // Grouped loader for has-many relations
    postsByAuthor: new DataLoader<string, Post[]>(async (authorIds) => {
      const posts = await db.post.findMany({
        where: { authorId: { in: [...authorIds] } },
      });
      const grouped = groupBy(posts, 'authorId');
      return authorIds.map(id => grouped[id] ?? []);
    }),
  };
}
```

### Step 6: Subscription Implementation
Design real-time GraphQL subscriptions:

```
SUBSCRIPTION ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  Transport: WebSocket (graphql-ws) | SSE (for HTTP/2)        │
│  Protocol: graphql-ws (preferred) | subscriptions-transport-ws (legacy)│
│  Pub/Sub backend: In-memory | Redis | Kafka | NATS           │
│                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐               │
│  │  Client   │◄──│  Gateway  │◄──│  Pub/Sub  │               │
│  │(WebSocket)│   │  Server   │   │  Backend  │               │
│  └──────────┘    └──────────┘    └──────────┘               │
│                                       ▲                      │
│                                       │                      │
│                               ┌───────┴───────┐             │
│                               │   Mutation     │             │
│                               │   Resolver     │             │
│                               │  (publishes)   │             │
│                               └───────────────┘             │
│                                                              │
└─────────────────────────────────────────────────────────────┘

SUBSCRIPTION PATTERNS:

Pattern 1: Event-driven (simple)
  subscription { orderCreated { id status total } }
  - Mutation publishes event after write
  - Subscription filters by topic
  - Good for: notifications, activity feeds

Pattern 2: Live query (filtered)
  subscription { orderUpdated(orderId: "123") { id status } }
  - Client subscribes with filter arguments
  - Server publishes only matching events
  - Good for: detail views, dashboards

Pattern 3: Presence / typing indicators
  subscription { userTyping(channelId: "abc") { userId timestamp } }
  - High-frequency, ephemeral events
  - Use TTL-based expiration, not DB persistence
  - Good for: chat, collaboration

SUBSCRIPTION RULES:
1. Always authenticate subscriptions on connection_init
2. Authorize each subscription topic — users only see their data
3. Use Redis/Kafka pub/sub in production — in-memory does not scale horizontally
4. Set connection limits per user to prevent resource exhaustion
5. Implement heartbeat/keepalive to detect stale connections
6. Filter events server-side, not client-side — minimize data sent over wire
7. Handle reconnection gracefully — client should re-subscribe and catch up
```

### Step 7: Schema Federation for Microservices
Design a federated GraphQL architecture:

```
FEDERATION ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌──────────────┐                                            │
│  │   Client      │                                            │
│  └──────┬───────┘                                            │
│         ▼                                                    │
│  ┌──────────────┐   Composes subgraph schemas                │
│  │   Gateway     │   Routes queries to subgraphs             │
│  │  (Router)     │   Handles query planning                  │
│  └──────┬───────┘                                            │
│    ┌────┼────────────┐                                       │
│    ▼    ▼            ▼                                       │
│  ┌────┐ ┌────────┐ ┌────────┐                                │
│  │User│ │Product │ │ Order  │   Each subgraph owns its       │
│  │Svc │ │  Svc   │ │  Svc   │   domain types and resolvers   │
│  └────┘ └────────┘ └────────┘                                │
│                                                              │
└─────────────────────────────────────────────────────────────┘

FEDERATION VERSION: Apollo Federation v2 | GraphQL Mesh | Cosmo | Grafbase

SUBGRAPH DESIGN RULES:
1. Each subgraph owns its domain entities — single source of truth
2. Use @key directive to define entity lookup:
   type User @key(fields: "id") { id: ID! name: String! }
3. Extend types across subgraphs with reference resolvers:
   type User @key(fields: "id") { id: ID! }  # stub in Order subgraph
   extend type User { orders: [Order!]! }      # Order subgraph adds field
4. Use @shareable for types used across subgraphs
5. Use @external + @requires for computed fields needing cross-subgraph data
6. Use @provides to declare which fields a subgraph can resolve
7. Gateway handles query planning — subgraphs never call each other directly

COMPOSITION CHECKLIST:
┌──────────────────────────────────────────────────────────────┐
│  Check                                │  Status               │
├───────────────────────────────────────┼───────────────────────┤
│  All @key fields have __resolveReference │  PASS | FAIL       │
│  No type ownership conflicts          │  PASS | FAIL          │
│  Shared types marked @shareable       │  PASS | FAIL          │
│  No circular subgraph dependencies    │  PASS | FAIL          │
│  Schema composition succeeds          │  PASS | FAIL          │
│  Gateway query plan is efficient      │  PASS | FAIL          │
│  Subgraph health checks configured    │  PASS | FAIL          │
└───────────────────────────────────────┴───────────────────────┘
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
   Reject with: { "errors": [{ "message": "Query complexity 1247 exceeds maximum 1000" }] }

   Implementation:
   - graphql-query-complexity (Node.js)
   - graphql-ruby complexity (Ruby)
   - Custom visitor on the AST

2. DEPTH LIMITING:
   ──────────────
   Reject deeply nested queries that could cause exponential work:

   # REJECTED (depth 7):
   { users { posts { comments { author { posts { comments { text } } } } } } }

   Max depth: 5 (configurable per operation type)
   Implementation: graphql-depth-limit middleware

3. PERSISTED QUERIES:
   ──────────────────
   Replace arbitrary query strings with pre-registered hashes:

   # Client sends hash instead of full query:
   POST /graphql
   { "extensions": { "persistedQuery": { "sha256Hash": "abc123..." } } }

   Benefits:
   - Eliminates arbitrary query injection
   - Reduces bandwidth (no query string in request)
   - Enables CDN caching of GET requests
   - Whitelist mode: only registered queries allowed in production

   Modes:
   - Automatic Persisted Queries (APQ): client sends hash, server caches
   - Build-time extraction: queries extracted at compile time, deployed as allowlist
   - RECOMMENDED: Build-time extraction for production, APQ for development

4. RATE LIMITING:
   ──────────────
   Rate limit by operation type, complexity, and user tier:

   ┌──────────────┬──────────┬──────────────┬─────────────┐
   │  Tier        │  Queries │  Mutations   │  Subscriptions│
   ├──────────────┼──────────┼──────────────┼─────────────┤
   │  Free        │  100/min │  20/min      │  2 active    │
   │  Standard    │  1000/min│  200/min     │  10 active   │
   │  Premium     │  10000/min│ 2000/min    │  100 active  │
   └──────────────┴──────────┴──────────────┴─────────────┘

5. RESPONSE CACHING:
   ─────────────────
   Cache at multiple layers:
   - CDN: GET requests with persisted queries (cache by query hash)
   - Application: @cacheControl directive per field
   - DataLoader: request-scoped deduplication (built-in)

   type Product @cacheControl(maxAge: 300) {
     id: ID!
     name: String!
     price: Float! @cacheControl(maxAge: 60)
     inventory: Int! @cacheControl(maxAge: 0)
   }

6. QUERY ALLOWLISTING (production hardening):
   ──────────────────────────────────────────
   In production, reject any query not in the allowlist:
   - Extract all queries from client code at build time
   - Register them with SHA256 hashes
   - Server rejects unregistered queries with 400
   - Eliminates entire classes of injection attacks
```

### Step 9: Testing GraphQL APIs
Comprehensive testing strategy:

```
GRAPHQL TESTING STRATEGY:
┌─────────────────────────────────────────────────────────────┐
│  Layer              │  What to Test            │  Tool       │
├─────────────────────┼──────────────────────────┼─────────────┤
│  Schema validation  │  Schema is valid SDL     │  buildSchema│
│  Unit: resolvers    │  Resolver logic in       │  Jest/Vitest│
│                     │  isolation with mocks    │             │
│  Unit: services     │  Business logic without  │  Jest/Vitest│
│                     │  GraphQL layer           │             │
│  Integration        │  Full query execution    │  supertest  │
│                     │  against test server     │  + graphql  │
│  N+1 detection      │  Query count assertions  │  Custom     │
│                     │  per operation           │  middleware │
│  Performance        │  Response time, query    │  k6, Artillery│
│                     │  complexity distribution │             │
│  Security           │  Auth, depth, complexity │  Custom     │
│                     │  injection attempts      │  test suite │
│  Contract           │  Schema backward compat  │  graphql-   │
│                     │                          │  inspector  │
└─────────────────────┴──────────────────────────┴─────────────┘

TESTING PATTERNS:

1. Schema snapshot testing:
   - Snapshot the printed schema after every change
   - Diff catches unintended breaking changes
   - Run: graphql-inspector diff old-schema.graphql new-schema.graphql

2. Resolver unit testing:
   - Mock context (auth, loaders, services)
   - Test each resolver function in isolation
   - Assert return shape matches GraphQL type

3. Integration testing:
   - Spin up test server with test database
   - Execute real GraphQL operations
   - Assert response data, errors, and status codes

4. N+1 regression testing:
   - Instrument DB layer to count queries per operation
   - Assert: list of 20 items with relations = exactly N queries (not 20*N)
   - Fail CI if query count regresses

5. Breaking change detection:
   - Compare schema against last released version
   - Flag: removed types/fields, changed nullability, renamed arguments
   - Gate: block merge if breaking changes detected without version bump
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

Next steps:
-> /godmode:test — Write comprehensive tests for resolvers and queries
-> /godmode:perf — Load test the GraphQL API
-> /godmode:deploy — Deploy with subscription support
-> /godmode:api — Generate companion REST endpoints if needed
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

## Example Usage

### Designing a GraphQL API
```
User: /godmode:graphql Design a GraphQL API for a blog platform

GraphQL: Starting discovery...

GRAPHQL DISCOVERY:
Project: Blog Platform API
Approach: SDL-first
Framework: Apollo Server 4
Language: TypeScript
Consumers: Next.js frontend, React Native mobile app
Auth: JWT bearer tokens
Real-time: Subscriptions for new comments

Schema designed:
- 6 types: User, Post, Comment, Tag, PostConnection, CommentConnection
- 8 queries: post, posts, user, users, tags, postsByTag, commentsByPost, me
- 5 mutations: createPost, updatePost, deletePost, createComment, deleteComment
- 2 subscriptions: commentAdded, postPublished

DataLoaders configured for: User, Post, Comment, Tag (4 loaders)
Performance: complexity limit 500, depth limit 6, APQ enabled
```

### Fixing N+1 Queries
```
User: /godmode:graphql My posts query is making hundreds of DB calls

GraphQL: Analyzing query patterns...

N+1 DETECTED:
Query: { posts(first: 50) { edges { node { author { name } comments { totalCount } } } } }

Current behavior:
  1 query for posts
  50 queries for authors (one per post)
  50 queries for comment counts (one per post)
  Total: 101 queries

Fix applied:
  1 query for posts
  1 batched query for authors (DataLoader)
  1 batched query for comment counts (DataLoader)
  Total: 3 queries

Performance improvement: 97% fewer database queries
```

### Setting Up Federation
```
User: /godmode:graphql Federate our monolith into user, product, and order subgraphs

GraphQL: Analyzing current schema for federation boundaries...

FEDERATION PLAN:
Gateway: Apollo Router
Subgraphs:
  - User Service: User, Profile, Auth types (12 fields)
  - Product Service: Product, Category, Inventory types (18 fields)
  - Order Service: Order, OrderItem, Payment types (15 fields)

Entity references:
  - Order.user -> User @key(fields: "id")
  - OrderItem.product -> Product @key(fields: "id")

Composition: VALID — no conflicts detected
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full GraphQL design workflow |
| `--sdl` | SDL-first schema design |
| `--code-first` | Code-first schema design (Pothos, Nexus, TypeGraphQL) |
| `--federation` | Design federated schema with subgraphs |
| `--subscriptions` | Add subscription support |
| `--n+1` | Detect and fix N+1 query problems |
| `--perf` | Add performance defenses (complexity, depth, persisted queries) |
| `--test` | Generate test suite for schema and resolvers |
| `--validate` | Validate existing schema for best practices |
| `--diff <old> <new>` | Detect breaking changes between schema versions |
| `--allowlist` | Extract and register persisted queries |

## Auto-Detection

On activation, automatically detect GraphQL project context:

```
AUTO-DETECT SEQUENCE:
1. Scan for GraphQL framework: apollo-server, graphql-yoga, mercurius, @pothos-graphql, nexus, type-graphql, strawberry, ariadne, gqlgen
2. Detect approach: *.graphql files = SDL-first, schema builder imports = code-first
3. Check for existing schema: schema.graphql, typeDefs definitions, generated schema files
4. Detect DataLoader usage: scan for dataloader imports — flag if missing with relation resolvers present
5. Check for subscription infrastructure: graphql-ws, subscriptions-transport-ws, Redis pub/sub config
6. Detect federation: @apollo/subgraph, @apollo/gateway, federation directives in schema
7. Scan for performance defenses: query-complexity, depth-limit, persisted queries config
8. Check for testing: schema snapshot tests, resolver unit tests, integration tests with graphql queries
9. Detect N+1 patterns: field resolvers with direct DB calls (no DataLoader)
10. Check for code generation: graphql-codegen config, relay compiler, generated types directory
```

## Explicit Loop Protocol

When building or extending a GraphQL schema with multiple entity types:

```
GRAPHQL ENTITY BUILD LOOP:
current_iteration = 0
entities = [entity_1, entity_2, ...]  // from schema design

WHILE current_iteration < len(entities) AND NOT user_says_stop:
  1. SELECT next entity by dependency order (entities with no relations first)
  2. DESIGN types: <Entity>, <EntityConnection>, Create/Update inputs, mutation payloads
  3. IMPLEMENT resolvers: Query (get, list), Mutation (create, update, delete)
  4. CREATE DataLoaders for all relation fields (batch + grouped loaders)
  5. ADD field resolvers that use DataLoaders (NEVER direct DB calls)
  6. WRITE tests: resolver unit tests, integration tests with real queries
  7. CHECK N+1: instrument DB layer, assert query count for list operations
  8. current_iteration += 1
  9. REPORT: "Entity <N>/<total>: <name> — <X> queries, <Y> mutations, DataLoaders: <Z>"

ON COMPLETION:
  ADD performance defenses: complexity limit, depth limit, persisted queries
  RUN schema validation and breaking change detection
  REPORT: "<N> types, <M> operations, <K> DataLoaders, complexity limit: <X>"
```

## Multi-Agent Dispatch

For large GraphQL APIs or federated schemas, dispatch parallel agents:

```
PARALLEL GRAPHQL AGENTS:
When building a GraphQL API with multiple domains:

Agent 1 (worktree: gql-schema):
  - Design complete schema (types, inputs, enums, connections, payloads)
  - Implement shared types (PageInfo, UserError, scalars)
  - Set up performance plugins (complexity, depth limit, APQ)
  - Create schema snapshot tests

Agent 2 (worktree: gql-resolvers):
  - Implement all resolvers with service layer delegation
  - Create DataLoader factory with batch and grouped loaders
  - Build context factory (auth, loaders, services per request)
  - Implement subscription resolvers with pub/sub

Agent 3 (worktree: gql-tests):
  - Write integration tests for all queries and mutations
  - Add N+1 regression tests (query count assertions)
  - Create breaking change detection in CI (graphql-inspector)
  - Write load tests for critical query paths

MERGE STRATEGY: Schema merges first. Resolvers rebase onto schema.
  Tests rebase onto resolvers. Final: run full test suite, verify schema snapshot.
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

## Anti-Patterns

- **Do NOT expose database columns directly as GraphQL fields.** Design the schema for the consumer's use case, not the database structure.
- **Do NOT skip DataLoaders.** "It's just one relation" is how you get 500ms list queries. Every relation field gets a DataLoader.
- **Do NOT throw exceptions for user-facing errors.** Use mutation payload patterns with error arrays. Exceptions are for unexpected server failures.
- **Do NOT allow arbitrary queries in production.** Use persisted queries or an allowlist. Arbitrary query strings are an attack surface.
- **Do NOT federate prematurely.** Federation adds operational complexity. Start with a monolith and extract when you have clear team boundaries.
- **Do NOT use subscriptions for everything.** Subscriptions are for real-time use cases. Polling or cache invalidation is simpler for data that changes infrequently.
- **Do NOT design input types that mirror output types.** Input types are what the client sends. Output types are what the server returns. They have different shapes and validation rules.
- **Do NOT ignore schema evolution.** Every schema change must be checked for backward compatibility. Use graphql-inspector or schema snapshot tests in CI.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run GraphQL tasks sequentially: schema, then resolvers, then tests.
- Use branch isolation per task: `git checkout -b godmode-graphql-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
