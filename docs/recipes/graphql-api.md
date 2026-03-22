# Recipe: Building a GraphQL API

> From schema design to production-ready GraphQL API. Type-safe, performant, and well-tested.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `think → graphql → schema → build → contract → test → ship` |
| **Timeline** | 3-5 days for a complete API |
| **Team size** | 1-3 developers |
| **Example project** | "TaskHub" — a project management GraphQL API with real-time subscriptions |

---

## Prerequisites

- Node.js or Go environment configured
- PostgreSQL or MongoDB provisioned
- Redis for subscriptions and caching
- Godmode installed and configured

---

## Technology Recommendations

| Layer | Recommendation | Why |
|-------|---------------|-----|
| Runtime | Node.js (TypeScript) or Go | Mature GraphQL ecosystem |
| Framework | Apollo Server or Mercurius (Fastify) | Production-proven, great DX |
| Schema approach | Code-first (TypeGraphQL / Nexus) or SDL-first | Type safety from the start |
| Database | PostgreSQL + Prisma | Type-safe ORM, excellent migration story |
| Subscriptions | Redis PubSub + WebSocket | Scalable real-time across instances |
| Auth | JWT with directive-based authorization | Declarative, schema-level security |
| Caching | DataLoader + Redis | Solve N+1 at the loader level, cache at Redis level |
| Testing | Jest + graphql-request | Fast integration tests against the schema |

**Alternative stacks:**
- **Python:** Strawberry + SQLAlchemy + Ariadne
- **Go:** gqlgen + GORM (compiled resolvers, excellent performance)
- **Ruby:** graphql-ruby + Rails (convention-driven)

---

## Session Transcript

### Phase 1: Think — Define the API Surface

Start with the domain, not the schema.

```
> /godmode:think I want to build a GraphQL API for TaskHub, a project
  management tool. Core entities: Users, Teams, Projects, Tasks, Comments.
  Key workflows: create projects with tasks, assign tasks to team members,
  track task status, and get real-time updates when tasks change.

Godmode: Researching problem space...

Two questions before designing:
1. Read-heavy or write-heavy? (dashboards vs. frequent task updates?)
2. Do you need offline support or is real-time the priority?

> Read-heavy — dashboards and task boards are the main view. Real-time
  updates for task status changes and new comments.

Godmode: Writing spec...

API SCOPE:
  Queries:
    - Nested resource fetching (project → tasks → assignees)
    - Filtered task lists with pagination (cursor-based)
    - Dashboard aggregations (tasks by status, overdue count)
    - Full-text search across tasks and comments

  Mutations:
    - CRUD for Projects, Tasks, Comments
    - Task assignment and status transitions
    - Batch operations (move multiple tasks)

  Subscriptions:
    - taskUpdated — real-time task status changes
    - commentAdded — new comments on watched tasks
    - projectActivity — activity feed for a project

  OUT OF SCOPE (post-v1):
    - File attachments
    - Time tracking
    - Gantt chart data
    - Webhooks for external integrations

Saved: docs/specs/taskhub-graphql-api.md
Commit: "spec: TaskHub GraphQL API — projects, tasks, real-time subscriptions"
```

**Time: 25 minutes.** Defining the query patterns upfront prevents schema redesigns later.

### Phase 2: GraphQL — Design the Schema

```
> /godmode:graphql

Godmode: Reading spec... Designing GraphQL schema...

SCHEMA DESIGN:

Types:
  type User {
    id: ID!
    email: String!
    name: String!
    avatar: String
    teams: [Team!]!
    assignedTasks(status: TaskStatus): [Task!]!
  }

  type Team {
    id: ID!
    name: String!
    members: [User!]!
    projects: [Project!]!
  }

  type Project {
    id: ID!
    name: String!
    description: String
    team: Team!
    tasks(filter: TaskFilter, pagination: CursorInput): TaskConnection!
    stats: ProjectStats!
    createdAt: DateTime!
  }

  type Task {
    id: ID!
    title: String!
    description: String
    status: TaskStatus!
    priority: Priority!
    assignee: User
    project: Project!
    comments: [Comment!]!
    createdAt: DateTime!
    updatedAt: DateTime!
  }

  type Comment {
    id: ID!
    body: String!
    author: User!
    task: Task!
    createdAt: DateTime!
  }

Enums:
  enum TaskStatus { TODO, IN_PROGRESS, IN_REVIEW, DONE, ARCHIVED }
  enum Priority { LOW, MEDIUM, HIGH, URGENT }

Connections (cursor-based pagination):
  type TaskConnection {
    edges: [TaskEdge!]!
    pageInfo: PageInfo!
    totalCount: Int!
  }

Queries:
  type Query {
    me: User!
    project(id: ID!): Project
    task(id: ID!): Task
    searchTasks(query: String!, first: Int): [Task!]!
    dashboard: DashboardStats!
  }

Mutations:
  type Mutation {
    createProject(input: CreateProjectInput!): Project!
    createTask(input: CreateTaskInput!): Task!
    updateTask(id: ID!, input: UpdateTaskInput!): Task!
    moveTask(id: ID!, status: TaskStatus!): Task!
    assignTask(id: ID!, userId: ID!): Task!
    addComment(taskId: ID!, body: String!): Comment!
    batchMoveTasks(ids: [ID!]!, status: TaskStatus!): [Task!]!
  }

Subscriptions:
  type Subscription {
    taskUpdated(projectId: ID!): Task!
    commentAdded(taskId: ID!): Comment!
    projectActivity(projectId: ID!): Activity!
  }

Directives:
  @auth — requires authenticated user
  @hasRole(role: Role!) — requires specific role
  @rateLimit(max: Int!, window: Int!) — per-field rate limiting
  @cacheControl(maxAge: Int!) — CDN and client cache hints

Design decisions:
  1. Cursor-based pagination (not offset) — stable under concurrent writes
  2. Input types for all mutations — easier validation, better DX
  3. Connection pattern for lists — standard Relay-compatible pagination
  4. Custom directives for cross-cutting concerns — keeps resolvers clean
  5. Nullable by default for optional fields — explicit non-null with !

Saved: schema/taskhub.graphql
Commit: "graphql: TaskHub schema — types, queries, mutations, subscriptions"
```

**Time: 20 minutes.**

### Phase 3: Schema — Design the Database

```
> /godmode:schema

Godmode: Reading GraphQL schema... Designing database...

SCHEMA DESIGN:

Tables:
  users           — id, email, name, avatar_url, created_at
  teams           — id, name, created_at
  team_members    — team_id, user_id, role, joined_at (composite PK)
  projects        — id, team_id, name, description, created_at
  tasks           — id, project_id, assignee_id, title, description,
                    status, priority, position, created_at, updated_at
  comments        — id, task_id, author_id, body, created_at
  task_activity   — id, task_id, user_id, action, old_value, new_value,
                    created_at (append-only audit log)

Indexes:
  tasks(project_id, status)        — task board queries
  tasks(assignee_id, status)       — "my tasks" queries
  tasks(project_id, position)      — ordered task lists
  comments(task_id, created_at)    — comment threads
  task_activity(task_id)           — activity feed

Key patterns:
  - position column (float) for drag-and-drop reordering without rewriting
  - task_activity as append-only log for subscriptions and audit
  - soft delete via ARCHIVED status, not deleted_at column

Migration created and applied.

Commit: "schema: TaskHub database — 7 tables with indexes for GraphQL query patterns"
```

**Time: 15 minutes.**

### Phase 4: Build — Implement Resolvers

```
> /godmode:build

Godmode: Reading schema and GraphQL spec... Starting implementation...

RESOLVER ARCHITECTURE:

Layer 1: DataLoaders (solve N+1)
  userLoader      — batch load users by ID
  taskLoader      — batch load tasks by ID
  commentLoader   — batch load comments by task ID
  projectLoader   — batch load projects by ID

Layer 2: Services (business logic)
  TaskService     — status transitions, assignment, validation
  ProjectService  — CRUD, stats aggregation
  CommentService  — creation, notification triggers
  SearchService   — full-text search via PostgreSQL ts_vector

Layer 3: Resolvers (thin, delegate to services)
  Query resolvers      — fetch via DataLoaders
  Mutation resolvers   — validate input, call service, return result
  Field resolvers      — lazy-load nested relations via DataLoaders
  Subscription resolvers — Redis PubSub listeners

Implementation:

Phase 1: DataLoaders and base resolvers
  Task 1: DataLoader factory with per-request batching ✓
  Task 2: User resolvers (me, nested teams) ✓
  Task 3: Project resolvers (CRUD, nested tasks with pagination) ✓
  Task 4: Task resolvers (CRUD, status transitions, assignment) ✓
  Task 5: Comment resolvers (create, nested on task) ✓

Phase 2: Advanced features
  Task 6: Cursor-based pagination utility ✓
  Task 7: Full-text search with PostgreSQL ✓
  Task 8: Dashboard aggregation queries ✓
  Task 9: Batch task operations ✓

Phase 3: Real-time
  Task 10: Redis PubSub setup ✓
  Task 11: taskUpdated subscription ✓
  Task 12: commentAdded subscription ✓
  Task 13: projectActivity subscription ✓

Phase 4: Cross-cutting
  Task 14: @auth directive implementation ✓
  Task 15: @hasRole directive implementation ✓
  Task 16: @rateLimit directive (Redis sliding window) ✓
  Task 17: @cacheControl directive ✓
  Task 18: Error handling (custom GraphQL errors with codes) ✓
  Task 19: Query depth limiting (prevent abuse) ✓
  Task 20: Query complexity analysis ✓

BUILD COMPLETE: 20 tasks, 64 tests, all green.

Commit: "feat: GraphQL resolvers — DataLoaders, services, subscriptions, directives"
```

**Time: 3-4 hours.** The bulk of the work. DataLoaders are the most critical piece.

### Phase 5: Contract — Consumer-Driven Contract Tests

```
> /godmode:contract

Godmode: Analyzing GraphQL schema for contract testing...

CONTRACT TESTING STRATEGY:

For GraphQL APIs, contract testing verifies that:
  1. The schema matches what consumers expect
  2. Resolver responses match the schema types
  3. Breaking changes are caught before deployment

Approach: Schema-based contracts + operation-based contracts

Schema contracts:
  - Export schema as SDL artifact on every build
  - Diff against previous version to detect breaking changes
  - Breaking: removing fields, changing types, removing enum values
  - Non-breaking: adding fields, adding enum values, adding types

Operation contracts (per consumer):
  Consumer: "TaskHub Web App"
    operations/web-dashboard.graphql     — dashboard query
    operations/web-task-board.graphql    — project tasks query
    operations/web-create-task.graphql   — create task mutation
    operations/web-subscribe-tasks.graphql — task updates subscription

  Consumer: "TaskHub Mobile App"
    operations/mobile-my-tasks.graphql   — assigned tasks query
    operations/mobile-move-task.graphql  — move task mutation

Contract tests written:
  tests/contracts/schema-diff.test.ts       — 8 tests
  tests/contracts/web-consumer.test.ts      — 12 tests
  tests/contracts/mobile-consumer.test.ts   — 6 tests

Breaking change detection:
  ✓ Field removal detected
  ✓ Type change detected
  ✓ Required argument addition detected
  ✓ Enum value removal detected
  ✓ Non-null to nullable change detected

Commit: "test: GraphQL contract tests — schema diffing + consumer operation contracts"
```

**Time: 30 minutes.**

### Phase 6: Test — Fill Coverage Gaps

```
> /godmode:test --coverage-target 95

Godmode: Analyzing coverage report...

COVERAGE ANALYSIS:
Current: 82% (lines)
Target: 95%
Gap: 13% (47 uncovered lines)

Uncovered areas:
  1. Subscription error handling — client disconnect during publish
  2. DataLoader cache invalidation after mutations
  3. Cursor pagination edge cases — empty result set, single item
  4. Rate limiter — window expiry and Redis connection failure
  5. Query complexity — deeply nested query rejection
  6. Batch mutation — partial failure handling
  7. Search — special characters and empty query

Writing tests...

Tests added: 28 new tests
  - Subscription lifecycle (connect, receive, disconnect, reconnect)
  - DataLoader cache coherence after mutation
  - Pagination: empty, single, boundary, invalid cursor
  - Rate limiting: burst, window reset, Redis fallback
  - Query depth: exactly at limit, one over limit
  - Batch: all succeed, partial fail, all fail
  - Search: empty string, SQL injection attempt, unicode

Coverage: 82% → 96.1% ✓ TARGET MET

Commit: "test: fill GraphQL coverage gaps — subscriptions, pagination, rate limiting"
```

**Time: 45 minutes.**

### Phase 7: Ship — Deploy to Production

```
> /godmode:ship --deploy production

Godmode: Starting 8-phase shipping workflow...

Phase 1: INVENTORY
  22 commits, 48 files changed
  Features: schema, resolvers, subscriptions, directives, contracts

Phase 2: CHECKLIST
  ✓ Tests: 92/92 passing
  ✓ Schema validation: no breaking changes from last version
  ✓ Contract tests: all consumers passing
  ✓ Coverage: 96.1%
  ✓ Query depth limit: 10 levels max
  ✓ Query complexity limit: 1000 points max
  ✓ Rate limiting: configured per operation
  ✓ No N+1 queries (DataLoader on all relations)
  ✓ Introspection disabled in production

Phase 3: PREPARE
  ✓ Docker image built
  ✓ Database migration ready
  ✓ Redis cluster reachable

Phase 4: DRY RUN
  ✓ Staging deployment verified
  ✓ Smoke tests: 18/18 passing
  ✓ Subscription WebSocket connection: OK
  ✓ Load test: handles 2000 queries/second

Phase 5: DEPLOY
  ✓ Blue-green deployment initiated
  ✓ Health check: OK
  ✓ Traffic switched

Phase 6: VERIFY
  ✓ Production smoke tests: 18/18
  ✓ WebSocket subscriptions: connected
  ✓ Query latency p99: 45ms

Phase 7: LOG
  Ship log: .godmode/ship-log.tsv
  Version: v1.0.0

Phase 8: MONITOR
  T+0:  ✓ Deployed
  T+5:  ✓ Error rate 0.00%, query latency p99 45ms
  T+15: ✓ 127 queries served, 3 active subscriptions
  T+30: ✓ All clear. Production launch confirmed stable.

TaskHub GraphQL API v1.0.0 is LIVE.
```

---

## GraphQL-Specific Patterns

### N+1 Prevention with DataLoaders

The most common GraphQL performance problem. Every relationship resolver must use a DataLoader:

```
# WITHOUT DataLoader (N+1):
# Query: { projects { tasks { assignee { name } } } }
# Result: 1 query for projects + N queries for tasks + M queries for assignees

# WITH DataLoader:
# Result: 1 query for projects + 1 batch query for tasks + 1 batch query for assignees
```

Godmode creates DataLoaders for every relation automatically during `/godmode:build`.

### Subscription Architecture

```
  Client A ──ws──→  │              │
  Client B ──ws──→  │  GraphQL     │ ←── publish ── Mutation Resolver
  Client C ──ws──→  │  Server      │
                    ┌──────┴───────┐
  Redis PubSub
  (fan-out)
```

Each server instance subscribes to Redis channels. When a mutation fires, it publishes to Redis, which fans out to all server instances. Each instance delivers to its connected WebSocket clients.

### Query Complexity Budget

Assign costs to fields to prevent abusive queries:

```
type Query {
  projects: [Project!]! @complexity(value: 10)
}

type Project {
  tasks: [Task!]! @complexity(value: 5, multiplier: "first")
}

type Task {
  comments: [Comment!]! @complexity(value: 3, multiplier: "first")
}

# Budget: 1000 points per query
# { projects { tasks(first: 50) { comments(first: 20) } } }
# Cost: 10 + (50 * 5) + (50 * 20 * 3) = 10 + 250 + 3000 = 3260 → REJECTED
```

---

## Common Pitfalls

| Pitfall | Why It Happens | Godmode Prevention |
|---------|---------------|-------------------|
| N+1 queries | Field resolvers query DB individually | DataLoaders created for every relation |
| Schema bloat | Adding fields "just in case" | `/godmode:think` enforces minimal API surface |
| No pagination | Returning unbounded lists | Cursor-based connections enforced by `/godmode:graphql` |
| Overfetching server-side | Resolving fields the client did not request | Field-level resolution with DataLoader batching |
| Breaking changes | Removing or renaming fields | `/godmode:contract` catches breaking changes in CI |
| Subscription memory leaks | Not cleaning up on disconnect | Lifecycle management tested in `/godmode:test` |

---

## Custom Chain for GraphQL Projects

```yaml
# .godmode/chains.yaml
chains:
  graphql-feature:
    description: "Add a new feature to the GraphQL API"
    steps:
      - think
      - graphql        # schema changes
      - schema         # database changes
      - build          # resolvers + DataLoaders
      - contract       # verify no breaking changes
      - test
      - ship

  graphql-breaking:
    description: "Make a breaking schema change with migration"
    steps:
      - think
      - graphql        # new schema version
      - contract       # identify affected consumers
      - build          # deprecation + new fields
      - test
      - ship           # with consumer coordination
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [Building a SaaS](greenfield-saas.md) — Full SaaS development workflow
- [API Gateway Recipe](api-gateway.md) — If your GraphQL API sits behind a gateway
