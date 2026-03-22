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

## Multi-Agent Dispatch

```
Agent 1 (gql-schema): types, inputs, shared types, performance plugins, snapshot tests
Agent 2 (gql-resolvers): resolvers, DataLoader factory, context factory, subscriptions
Agent 3 (gql-tests): integration tests, N+1 regression, breaking change detection, load tests
MERGE: schema -> resolvers -> tests. Run full test suite and verify schema snapshot.
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

- **Do NOT expose database columns directly as GraphQL fields.** Design for consumers, not the database.
- **Do NOT skip DataLoaders.** Every relation field gets a DataLoader. No exceptions.
- **Do NOT throw exceptions for user-facing errors.** Use mutation payload patterns with error arrays.
- **Do NOT allow arbitrary queries in production.** Use persisted queries or an allowlist.
- **Do NOT federate prematurely.** Start monolithic, extract when team boundaries demand it.
- **Do NOT use subscriptions for infrequently changing data.** Polling is simpler.
- **Do NOT design input types that mirror output types.** They have different shapes and validation rules.
- **Do NOT ignore schema evolution.** Use graphql-inspector or schema snapshot tests in CI.

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
+--------------------------------------------------------------+
|  Domain        | Types | Queries | Mutations | DataLoaders    |
+--------------------------------------------------------------+
|  <domain>      | N     | N       | N         | N              |
+--------------------------------------------------------------+
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
+--------------------------------------------------------------+
|  Criterion                                  | Required         |
+--------------------------------------------------------------+
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
+--------------------------------------------------------------+

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

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run GraphQL tasks sequentially: schema, then resolvers, then tests.
- Use branch isolation per task: `git checkout -b godmode-graphql-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
