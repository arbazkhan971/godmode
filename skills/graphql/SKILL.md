---
name: graphql
description: |
  GraphQL API development skill. Schema design,
  resolver architecture, N+1 detection with DataLoader,
  subscriptions, federation, performance hardening.
  Triggers on: /godmode:graphql, "GraphQL schema",
  "fix N+1 queries", "set up subscriptions".
---

# GraphQL — API Development

## When to Activate
- User invokes `/godmode:graphql`
- User says "build a GraphQL API", "design schema"
- User says "fix N+1 queries", "add DataLoader"
- User says "set up subscriptions", "federate schema"

## Workflow

### Step 1: Discovery & Context

```bash
# Detect GraphQL framework
grep -l "apollo-server\|graphql-yoga\|mercurius\|\
pothos\|nexus\|type-graphql\|strawberry\|gqlgen" \
  package.json pyproject.toml go.mod 2>/dev/null

# Check for DataLoader usage
grep -rl "dataloader\|DataLoader" src/ 2>/dev/null

# Find schema files
find . -name "*.graphql" -o -name "*.gql" \
  | head -10
```

```
GRAPHQL DISCOVERY:
Approach: SDL-first | Code-first
Framework: Apollo | Yoga | Mercurius | Pothos | gqlgen
Consumers: web app | mobile | third-party
Auth: JWT | session | API key
Federation: monolith | gateway + subgraphs

IF no DataLoader and has relations: N+1 is likely
IF no depth limit: production API is vulnerable
IF no complexity limit: one query can DoS the server
```

### Step 2: Schema Design

```graphql
# SDL-first example
type Query {
  user(id: ID!): User
  users(first: Int!, after: String): UserConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): CreateUserPayload!
}

# Every mutation returns payload with errors array
type CreateUserPayload {
  user: User
  errors: [UserError!]!
}
```

```
SCHEMA RULES:
  Mutations return payload types (never throw)
  All lists use Relay connections (edges, pageInfo)
  Input types separate from output types
  Non-nullable uses ! intentionally
  Enums for fixed sets, never strings

THRESHOLDS:
  Max query depth: 10 levels
  Max query complexity: 1000 points
  Connection max first/last: 100 items
  IF depth > 10: reject query
  IF complexity > 1000: reject query
```

### Step 3: Resolver Architecture

Resolvers are thin orchestration — no business logic.
Business logic lives in service layer.

### Step 4: N+1 Detection and DataLoader

```
N+1 DETECTION:
| Pattern                     | Action          |
|-----------------------------|-----------------|
| List with nested relations  | Add DataLoader  |
| Field resolver with DB call | Must use loader |
| 3+ levels deep query        | Audit batch plan|

DATALOADER RULES:
  Every relation field MUST use DataLoader.
  Create loaders per-request (not global).
  Batch by ID, return in same order as input.

IF query count > N+1 for list of N: DataLoader missing
IF no DataLoader imports: flag all relation resolvers
```

### Step 5: Subscriptions

```
SUBSCRIPTION ARCHITECTURE:
  Transport: WebSocket (graphql-ws preferred)
  Pub/Sub: Redis (production) | in-memory (dev)

THRESHOLDS:
  Max subscription connections: 10K per server
  Heartbeat interval: 30 seconds
  IF > 1 server instance: must use Redis pub/sub
  IF using in-memory pub/sub in prod: fix immediately
```

### Step 6: Federation (if needed)

Each subgraph owns its entities. Gateway handles
query planning. Subgraphs never call each other.
Run composition checks before every merge.

### Step 7: Performance Hardening

```
REQUIRED DEFENSES:
  Depth limit: 10 (configurable per operation)
  Complexity limit: 1000 per query
  Persisted queries or allowlist in production
  Rate limiting: per-client, per-operation

FIELD COSTS:
  Scalar field: 1 point
  Object field: 2 points
  List field: first * child_cost
  Connection: first * (edge_cost + node_cost)
```

### Step 8: Testing

```bash
# Run schema validation
npx graphql-inspector validate schema.graphql

# Run N+1 regression tests
npx vitest run tests/graphql/ --reporter=verbose
```

```
TESTING LAYERS:
  Schema validation: buildSchema succeeds
  Resolver unit: mock context, test isolation
  Integration: full query execution
  N+1 regression: assert query count per operation
  Contract: graphql-inspector diff (breaking changes)
```

### Step 9: Artifacts & Completion

```
GRAPHQL COMPLETE:
Types: <N> objects, <M> inputs, <K> enums
Operations: <N> queries, <M> mutations, <K> subs
DataLoaders: <N> (all relation fields covered)
Performance: depth <N>, complexity <N>
```

Commit: `"graphql: <service> — <N> types,
  <M> operations, DataLoaders configured"`

## Key Behaviors

Never ask to continue. Loop autonomously until done.

1. **Schema is the contract.** Design before resolvers.
2. **DataLoaders are mandatory.** N+1 queries are bugs.
3. **Mutations return payloads.** Never throw for
   user-facing errors.
4. **Performance defenses not optional.** Depth +
   complexity limits on every production API.
5. **Do not federate prematurely.**
6. **Test the schema, not only resolvers.**

## Quality Targets
- Query response: <200ms p95
- Max depth: <10 levels
- Max complexity: <1000 points

## HARD RULES

1. Every relation resolver must use DataLoader.
2. Every mutation returns payload + errors array.
3. Every list uses Relay-style connections.
4. Never expose DB column names as GraphQL fields.
5. Separate input types for create vs update.
6. Always add depth and complexity limits.
7. Always use persisted queries in production.
8. Never share input types across operations.
9. Always run schema snapshot tests in CI.
10. Never federate prematurely.

## Auto-Detection
```
1. Framework: apollo, yoga, mercurius, pothos, gqlgen
2. Approach: *.graphql = SDL, builder imports = code
3. DataLoader: scan for imports, flag if missing
4. Performance: depth-limit, complexity config
```

## Loop Protocol
```
FOR each entity (leaf first):
  1. Design types, connections, inputs, payloads
  2. Implement resolvers (queries + mutations)
  3. Create DataLoaders for all relation fields
  4. Write tests (unit + integration + N+1 count)
  5. IF N+1 detected: add DataLoader, re-test
  6. IF breaking change: add new field, deprecate old
POST: Add complexity/depth limits, validate schema
```

## Quality Targets
- Target: <200ms p95 query response time
- Max query depth: <=10 levels
- Max query complexity: <=1000 points
- Target: 0 N+1 query patterns detected

## Output Format
Print: `GraphQL: {types} types, {queries} queries,
  {mutations} mutations, {dataloaders} DataLoaders.
  N+1: {status}. Depth: {N}. Verdict: {verdict}.`

## TSV Logging
```
timestamp	types	queries	mutations	dataloaders	n1_fixed	status
```

## Keep/Discard Discipline
```
KEEP if: schema compiles AND zero N+1
  AND mutations return payloads AND limits configured
DISCARD if: N+1 detected OR mutation throws
  OR breaking change without version bump
```

## Stop Conditions
```
STOP when ALL of:
  - Schema compiles, snapshot test passes
  - All relation fields have DataLoaders
  - All mutations return payload types
  - Depth + complexity limits configured
  - No breaking changes vs previous schema
```

## Error Recovery
- Schema fails: fix syntax, missing types, circular refs.
- N+1 detected: add DataLoader, re-test query count.
- Breaking change: revert removal, add new field,
  use @deprecated.
- Subscription silent: verify pub/sub connection.

