---
name: schema
description: |
  Data modeling and schema design skill. Activates when a developer needs to design, evaluate, or evolve data models and schemas. Covers relational schema design (normalization, denormalization trade-offs), NoSQL data modeling (document, key-value, graph, time-series), schema evolution and migrations, entity-relationship modeling, and data validation schemas (Zod, JSON Schema, Avro, Protobuf). Triggers on: /godmode:schema, "design the schema", "data model", "normalize", "denormalize", "entity relationship", "validation schema", or when data architecture decisions need structured guidance.
---

# Schema -- Data Modeling & Schema Design

## When to Activate
- User invokes `/godmode:schema`
- User says "design the schema," "data model," "what tables do I need?"
- User asks about normalization, denormalization, or schema trade-offs
- User needs to model entities and relationships for a new feature or system
- User asks about NoSQL data modeling (document, key-value, graph, time-series)
- User needs to design validation schemas (Zod, JSON Schema, Avro, Protobuf)
- User asks about schema evolution, versioning, or backward compatibility
- User encounters data integrity issues, redundancy, or anomalies
- Godmode orchestrator detects data modeling decisions that need guidance

## Workflow

### Step 1: Understand the Domain

Gather requirements before designing any schema:

```
DOMAIN ANALYSIS:
Application:    <what the system does>
Entities:       <core business objects identified>
Relationships:  <how entities relate to each other>
Access patterns: <primary read/write operations>
Scale:          <expected data volume per entity>
Consistency:    <strong | eventual | mixed>
Latency:        <real-time | near-real-time | batch>
Compliance:     <GDPR | HIPAA | PCI-DSS | SOX | none>
Database:       <PostgreSQL | MySQL | MongoDB | DynamoDB | Neo4j | Redis | not decided>
```

Key questions to answer before schema design:
```
1. What are the core entities? (nouns in the domain)
2. How do they relate? (one-to-one, one-to-many, many-to-many)
3. What queries will run most frequently? (read patterns drive schema)
4. What is the write-to-read ratio? (write-heavy vs read-heavy)
5. What is the expected data volume? (thousands vs billions of rows)
6. What consistency guarantees are required? (financial data vs analytics)
7. Will the schema need to evolve frequently? (startup vs regulated industry)
8. Are there multi-tenancy requirements? (shared schema vs schema per tenant)
```

### Step 2: Entity-Relationship Modeling

#### 2a: Identify Entities and Attributes

```
ENTITY CATALOG:
+-------------------+--------------------------------------------+------------------+
| Entity            | Key Attributes                             | Expected Volume  |
+-------------------+--------------------------------------------+------------------+
| User              | id, email, name, role, created_at          | 100K             |
| Organization      | id, name, plan, billing_email              | 10K              |
| Project           | id, name, description, org_id              | 500K             |
| Task              | id, title, status, assignee_id, project_id | 5M               |
| Comment           | id, body, author_id, task_id, created_at   | 20M              |
+-------------------+--------------------------------------------+------------------+
```

#### 2b: Define Relationships

```
RELATIONSHIP MAP:
+-------------------+----------------+-------------------+-------------------+
| From              | Relationship   | To                | Cardinality       |
+-------------------+----------------+-------------------+-------------------+
| Organization      | has many       | User              | 1:N               |
| Organization      | has many       | Project           | 1:N               |
| User              | belongs to     | Organization      | N:1               |
| Project           | has many       | Task              | 1:N               |
| Task              | has many       | Comment           | 1:N               |
| Task              | assigned to    | User              | N:1               |
| User              | has many       | Comment           | 1:N               |
| Task              | has many       | Tag (through)     | M:N               |
+-------------------+----------------+-------------------+-------------------+
```

#### 2c: ER Diagram (Text)

```
┌──────────────┐     1:N     ┌──────────────┐     1:N     ┌──────────────┐
│ Organization │────────────>│   Project     │────────────>│    Task      │
│              │             │              │             │              │
│ id (PK)      │             │ id (PK)      │             │ id (PK)      │
│ name         │             │ name         │             │ title        │
│ plan         │             │ description  │             │ status       │
│ billing_email│             │ org_id (FK)  │             │ priority     │
│ created_at   │             │ created_at   │             │ assignee_id  │
└──────────────┘             └──────────────┘             │ project_id   │
       │                                                   │ created_at   │
       │ 1:N                                               └──────────────┘
       ▼                                                          │
┌──────────────┐                                           1:N    │
│    User      │                                                  ▼
│              │                                           ┌──────────────┐
│ id (PK)      │                                           │   Comment    │
│ email        │◄──────────────────────────────────────────│              │
│ name         │         N:1 (author)                      │ id (PK)      │
│ role         │                                           │ body         │
│ org_id (FK)  │                                           │ author_id    │
│ created_at   │                                           │ task_id (FK) │
└──────────────┘                                           │ created_at   │
                                                           └──────────────┘
```

### Step 3: Relational Schema Design

#### 3a: Normalization Levels

```
NORMALIZATION GUIDE:
+--------+----------------------------+----------------------------------------+
| Form   | Rule                       | What It Eliminates                     |
+--------+----------------------------+----------------------------------------+
| 1NF    | Atomic values, no          | Repeating groups, multi-valued         |
|        | repeating groups            | columns (tags as CSV string)           |
+--------+----------------------------+----------------------------------------+
| 2NF    | 1NF + no partial           | Columns dependent on part of a         |
|        | dependencies               | composite key                          |
+--------+----------------------------+----------------------------------------+
| 3NF    | 2NF + no transitive        | Columns dependent on non-key           |
|        | dependencies               | columns (city -> zip -> state)         |
+--------+----------------------------+----------------------------------------+
| BCNF   | Every determinant is a     | Anomalies in tables with overlapping   |
|        | candidate key              | candidate keys                         |
+--------+----------------------------+----------------------------------------+
```

**Practical rule:** Start at 3NF. Denormalize only when you can prove (with query profiling) that joins are a bottleneck.

#### 3b: When to Denormalize

```
DENORMALIZATION DECISION:
+----------------------------+-------------------------------------------+
| Denormalize WHEN           | Example                                   |
+----------------------------+-------------------------------------------+
| Read frequency >> write    | Product listing with category name        |
| frequency for the data     | (read 1000x/sec, category changes 1x/day)|
+----------------------------+-------------------------------------------+
| Join is consistently the   | Dashboard query joining 5 tables;         |
| bottleneck in EXPLAIN      | materialized view or cached columns       |
+----------------------------+-------------------------------------------+
| Data is historical/        | Order snapshot with product name/price    |
| point-in-time              | at time of purchase (must not change)     |
+----------------------------+-------------------------------------------+
| Aggregation is expensive   | Counter cache: comment_count on Task      |
| and frequently needed      | instead of COUNT(*) on every page load    |
+----------------------------+-------------------------------------------+
| Cross-service boundary     | Each microservice owns its data; can't    |
| prevents joins             | join across databases                     |
+----------------------------+-------------------------------------------+

Do NOT denormalize when:
[ ] You haven't measured the join performance
[ ] Write frequency is high (updates must propagate to all copies)
[ ] Data consistency is critical (financial, medical)
[ ] The denormalized data changes frequently
```

#### 3c: SQL Schema Generation

```sql
-- Fully normalized 3NF schema
CREATE TABLE organizations (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    plan        VARCHAR(50) NOT NULL DEFAULT 'free'
                CHECK (plan IN ('free', 'pro', 'enterprise')),
    billing_email VARCHAR(255),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       VARCHAR(255) NOT NULL UNIQUE,
    name        VARCHAR(255) NOT NULL,
    role        VARCHAR(50) NOT NULL DEFAULT 'member'
                CHECK (role IN ('owner', 'admin', 'member', 'viewer')),
    org_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_users_org ON users(org_id);
CREATE INDEX idx_users_email ON users(email);

CREATE TABLE projects (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    description TEXT,
    org_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(org_id, name)  -- No duplicate project names within an org
);
CREATE INDEX idx_projects_org ON projects(org_id);

CREATE TABLE tasks (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title       VARCHAR(500) NOT NULL,
    description TEXT,
    status      VARCHAR(50) NOT NULL DEFAULT 'todo'
                CHECK (status IN ('todo', 'in_progress', 'in_review', 'done', 'cancelled')),
    priority    SMALLINT NOT NULL DEFAULT 2 CHECK (priority BETWEEN 0 AND 4),
    assignee_id UUID REFERENCES users(id) ON DELETE SET NULL,
    project_id  UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    due_date    DATE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX idx_tasks_assignee ON tasks(assignee_id) WHERE assignee_id IS NOT NULL;

CREATE TABLE comments (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    body        TEXT NOT NULL CHECK (length(body) > 0),
    author_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_comments_task_created ON comments(task_id, created_at DESC);

-- Many-to-many: tasks <-> tags
CREATE TABLE tags (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL,
    color       VARCHAR(7),  -- hex color
    org_id      UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    UNIQUE(org_id, name)
);

CREATE TABLE task_tags (
    task_id     UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    tag_id      UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (task_id, tag_id)
);
CREATE INDEX idx_task_tags_tag ON task_tags(tag_id);

-- Automatic updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_organizations_updated BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_projects_updated BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_tasks_updated BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_comments_updated BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### Step 4: NoSQL Data Modeling

#### 4a: Document Store (MongoDB/DynamoDB)

```
DOCUMENT MODEL DESIGN PRINCIPLES:
1. Model for your access patterns, not for normalization
2. Embed data that is read together (one query, one document)
3. Reference data that changes independently or is shared across documents
4. Avoid unbounded arrays (a document cannot grow forever)

EMBED vs REFERENCE DECISION:
+---------------------------+---------------------------+
| EMBED when                | REFERENCE when            |
+---------------------------+---------------------------+
| Data is always read       | Data is shared across     |
| together (1:few)          | many documents            |
+---------------------------+---------------------------+
| Child rarely changes      | Child changes frequently  |
| independently             | and independently         |
+---------------------------+---------------------------+
| Array is bounded          | Array can grow unbounded  |
| (max ~100 items)          | (comments, logs, events)  |
+---------------------------+---------------------------+
| Data belongs to parent    | Data has its own lifecycle |
| (address of a user)       | (user of an order)        |
+---------------------------+---------------------------+
```

```javascript
// MongoDB document model: e-commerce order
// GOOD: Embed items (bounded, always read with order, point-in-time snapshot)
{
  _id: ObjectId("..."),
  orderNumber: "ORD-2025-001",
  customer: {
    _id: ObjectId("..."),    // Reference to customer collection
    name: "Jane Doe",        // Denormalized snapshot (point-in-time)
    email: "jane@example.com"
  },
  items: [                   // Embedded (bounded, max ~50 items per order)
    {
      productId: ObjectId("..."),
      name: "Widget Pro",    // Snapshot at time of purchase
      price: 29.99,          // Snapshot at time of purchase
      quantity: 2
    }
  ],
  shipping: {                // Embedded (1:1, always read with order)
    address: "123 Main St",
    city: "Springfield",
    state: "IL",
    zip: "62704",
    method: "express",
    trackingNumber: "1Z999AA10123456784"
  },
  totals: {
    subtotal: 59.98,
    tax: 4.80,
    shipping: 9.99,
    total: 74.77
  },
  status: "shipped",
  statusHistory: [           // Embedded (bounded lifecycle, always read together)
    { status: "placed", at: ISODate("2025-03-01T10:00:00Z") },
    { status: "paid", at: ISODate("2025-03-01T10:01:00Z") },
    { status: "shipped", at: ISODate("2025-03-02T14:30:00Z") }
  ],
  createdAt: ISODate("2025-03-01T10:00:00Z"),
  updatedAt: ISODate("2025-03-02T14:30:00Z")
}

// BAD: Embedding unbounded comments in a document
// Comments can grow to thousands -- use a separate collection with a reference
```

#### 4b: Key-Value Store (Redis/DynamoDB)

```
KEY-VALUE DESIGN PATTERNS:
+----------------------+-----------------------------+------------------------------+

### Step 5: Schema Evolution and Migrations

#### 5a: Backward-Compatible Changes (Safe)

```
SAFE SCHEMA CHANGES (no downtime, no coordination):
+----------------------------+----------------------------------------------+
| Change                     | Why It's Safe                                |
+----------------------------+----------------------------------------------+
| Add nullable column        | Existing rows get NULL, old code ignores it  |
| Add column with default    | Existing rows get default, old code ignores  |
| Add new table              | No existing code references it               |
| Add new index              | CONCURRENTLY avoids locks (PostgreSQL)       |
| Widen a column type        | INT -> BIGINT, VARCHAR(50) -> VARCHAR(255)   |
| Add CHECK constraint       | If all existing data satisfies it             |
+----------------------------+----------------------------------------------+
```

#### 5b: Breaking Changes (Expand-Contract Pattern)

```
EXPAND-CONTRACT FOR BREAKING CHANGES:
Example: Rename column "name" to "full_name"

Phase 1 - EXPAND (backward compatible):
  - Add "full_name" column
  - Backfill: UPDATE users SET full_name = name WHERE full_name IS NULL
  - Add trigger: writes to "name" also write to "full_name" (dual-write)
  - Deploy code that reads from "full_name" but writes to both

Phase 2 - MIGRATE (transition):
  - Deploy code that reads/writes only "full_name"
  - Verify no code references "name"

Phase 3 - CONTRACT (cleanup):
  - Drop trigger
  - Drop "name" column
  - Done

Timeline: Days to weeks between phases (never same deployment)
```

#### 5c: Schema Versioning

```
SCHEMA VERSIONING STRATEGIES:
+-------------------+-------------------------------------------+---------------------+
| Strategy          | How It Works                              | Best For            |
+-------------------+-------------------------------------------+---------------------+
| Sequential        | 001_create_users.sql, 002_add_email.sql   | Relational DBs      |
| migrations        | Applied in order, tracked in table         | (most common)       |
+-------------------+-------------------------------------------+---------------------+
| Schema registry   | Central registry stores schema versions   | Event streaming     |
| (Avro/Protobuf)   | Checks forward/backward compatibility     | (Kafka, Pulsar)     |
+-------------------+-------------------------------------------+---------------------+
| Document          | Each document carries a "version" field   | Document stores     |
| versioning        | Application handles multiple versions     | (MongoDB)           |
+-------------------+-------------------------------------------+---------------------+
| API versioning    | /v1/users, /v2/users with different       | APIs with external  |
|                   | schemas behind the same DB                | consumers           |
+-------------------+-------------------------------------------+---------------------+
```

### Step 6: Data Validation Schemas

#### 6a: Zod (TypeScript Runtime Validation)

```typescript
// schemas/user.schema.ts
import { z } from 'zod';

export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email().max(255),
  name: z.string().min(1).max(255),
  role: z.enum(['owner', 'admin', 'member', 'viewer']),
  orgId: z.string().uuid(),
  bio: z.string().max(1000).optional(),
  avatar: z.string().url().optional(),
  preferences: z.object({
    theme: z.enum(['light', 'dark', 'system']).default('system'),
    locale: z.string().regex(/^[a-z]{2}(-[A-Z]{2})?$/).default('en'),
    notifications: z.object({
      email: z.boolean().default(true),
      push: z.boolean().default(false),
      digest: z.enum(['daily', 'weekly', 'never']).default('daily'),
    }).default({}),
  }).default({}),
  createdAt: z.coerce.date(),
  updatedAt: z.coerce.date(),
});

// Derived types
export type User = z.infer<typeof userSchema>;

// Partial schemas for different operations
export const createUserSchema = userSchema.omit({
  id: true,
  createdAt: true,
  updatedAt: true,
});

export const updateUserSchema = userSchema
  .omit({ id: true, createdAt: true, updatedAt: true })
  .partial();

export const userFilterSchema = z.object({
  role: z.enum(['owner', 'admin', 'member', 'viewer']).optional(),
  orgId: z.string().uuid().optional(),
  search: z.string().max(100).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  sortBy: z.enum(['name', 'email', 'createdAt']).default('createdAt'),
  sortOrder: z.enum(['asc', 'desc']).default('desc'),
});

export type CreateUser = z.infer<typeof createUserSchema>;
export type UpdateUser = z.infer<typeof updateUserSchema>;
export type UserFilter = z.infer<typeof userFilterSchema>;
```

#### 6b: JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/schemas/user.json",
  "type": "object",
  "required": ["email", "name", "role", "orgId"],
  "properties": {
    "id": {
      "type": "string",
      "format": "uuid"
    },
    "email": {
      "type": "string",
      "format": "email",
      "maxLength": 255
    },
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 255
    },

### Step 7: Multi-Tenancy Patterns

```
MULTI-TENANCY STRATEGIES:
+-------------------+-------------------+-------------------+-------------------+
| Strategy          | Isolation          | Complexity        | Best For          |
+-------------------+-------------------+-------------------+-------------------+
| Shared schema     | Row-level (WHERE   | Low               | SaaS with many    |
| (tenant_id col)   | tenant_id = ?)    |                   | small tenants     |
+-------------------+-------------------+-------------------+-------------------+
| Schema per tenant | Schema-level       | Medium            | Medium tenants    |
| (PostgreSQL       | (SET search_path) |                   | needing some      |
|  schemas)         |                   |                   | isolation         |
+-------------------+-------------------+-------------------+-------------------+
| Database per      | Full database      | High              | Enterprise with   |
| tenant            | isolation          |                   | compliance needs  |
+-------------------+-------------------+-------------------+-------------------+

SHARED SCHEMA WITH ROW-LEVEL SECURITY:
-- PostgreSQL RLS example
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
### Step 8: Report and Transition

```
+--------------------------------------------------------------+
|  SCHEMA DESIGN -- <description>                               |
+--------------------------------------------------------------+
|  Database:          <engine>                                  |
|  Model type:        <relational | document | graph | mixed>   |
|  Normalization:     <1NF | 2NF | 3NF | BCNF | denormalized> |
+--------------------------------------------------------------+
|  Entities:          <N entities defined>                      |
|  Relationships:     <N relationships defined>                 |
|  Indexes:           <N indexes recommended>                   |
|  Constraints:       <N constraints added>                     |
+--------------------------------------------------------------+
|  Schema artifacts:                                            |
|  - <SQL migration or schema file>                             |
|  - <Validation schema (Zod/JSON Schema/Protobuf)>            |
|  - <ER diagram>                                               |
+--------------------------------------------------------------+
|  Evolution strategy: <expand-contract | versioned | additive> |
|  Multi-tenancy:      <shared | schema-per | db-per | none>   |
+--------------------------------------------------------------+
```

Commit: `"schema: design <description> data model"`

## Key Behaviors

1. **Access patterns drive schema design.** The most common queries determine the schema, not normalization theory. Design for how data is read, then verify writes are acceptable.
2. **Start normalized, denormalize with evidence.** Begin at 3NF. Only denormalize when EXPLAIN ANALYZE proves joins are the bottleneck. Premature denormalization creates update anomalies.
3. **Every table needs a primary key.** Use UUID for distributed systems, BIGSERIAL for single-database systems. Never use natural keys (email, SSN) as primary keys -- they change.
4. **Foreign keys are not optional.** They enforce referential integrity at the database level. Application-level checks are not a substitute. Include ON DELETE behavior (CASCADE, SET NULL, RESTRICT).
5. **Timestamps on everything.** Every table gets `created_at` and `updated_at`. Use TIMESTAMPTZ, not TIMESTAMP. Time zones matter.
6. **Constraints in the database, validation in the application.** The database is the last line of defense. CHECK constraints, NOT NULL, UNIQUE, and foreign keys prevent invalid data even when application code has bugs.
7. **Schema evolution must be backward compatible.** Every migration must be deployable without downtime. Use the expand-contract pattern for breaking changes.
8. **Document models are designed around queries.** In NoSQL, embed data that is read together, reference data that is shared. There is no "correct" document structure -- only structures that serve your access patterns.
9. **Validation schemas are the single source of truth.** Define the schema once (Zod, Protobuf, Avro), derive types, API docs, and database constraints from it. Never maintain parallel definitions.
10. **Test schema changes against production-scale data.** A migration that runs in 100ms on dev (1000 rows) may lock the table for 30 minutes in production (10M rows).

## Example Usage

### Designing a schema from scratch
```
User: /godmode:schema I'm building a project management tool with orgs, users,
      projects, tasks, and comments. PostgreSQL.

Schema: Analyzing domain...

DOMAIN: Project management (multi-tenant SaaS)
Entities: Organization, User, Project, Task, Comment, Tag
Database: PostgreSQL

Designing 3NF schema with:
- UUID primary keys (distributed-ready)
- Row-level security for multi-tenancy
- Proper indexes for common access patterns (tasks by project+status, comments by task+date)
- Constraints: CHECK on enums, NOT NULL on required fields, FK with ON DELETE behavior

Files to create:
- migrations/001_initial_schema.sql   (full DDL)
- schemas/entities.ts                  (Zod validation schemas)
- docs/er-diagram.md                   (entity-relationship diagram)
```

### Choosing between SQL and NoSQL
## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive schema design workflow |
| `--er` | Generate entity-relationship diagram |
| `--normalize` | Analyze and normalize an existing schema |
| `--denormalize` | Evaluate denormalization opportunities with measurements |
| `--nosql` | Design NoSQL document/key-value/graph model |
| `--validate` | Generate validation schemas (Zod, JSON Schema, Protobuf, Avro) |
| `--evolve` | Plan a backward-compatible schema evolution |
| `--multi-tenant` | Design multi-tenancy schema with isolation strategy |
| `--audit` | Audit existing schema for issues (missing indexes, constraints, types) |
| `--compare` | Compare two schema versions and identify breaking changes |
| `--seed` | Generate seed data for development and testing |
| `--report` | Generate full schema design report |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Detect ORM/query builder: prisma, drizzle, typeorm, sequelize, sqlalchemy, gorm
2. Check for existing schema files: prisma/schema.prisma, migrations/, models/, entities/
3. Detect database type: PostgreSQL, MySQL, MongoDB, SQLite from connection strings/configs
4. Check for migration tool: prisma migrate, knex, flyway, alembic, goose, dbmate
5. Detect validation library: zod, joi, yup, class-validator, pydantic, JSON Schema files
6. Check for existing ERD or schema docs: docs/schema*, docs/erd*, dbdiagram references
7. Scan for schema issues: grep for VARCHAR(255) overuse, missing indexes on FK columns
8. Check for seed data: prisma/seed.ts, seeds/, fixtures/, factories/
```

## Iterative Schema Design Loop

```
current_iteration = 0
max_iterations = 10
entities_remaining = [list of entities/tables to design or evolve]

WHILE entities_remaining is not empty AND current_iteration < max_iterations:
    entity = entities_remaining.pop(0)
    1. Define access patterns: list all queries this entity participates in
    2. Design columns/fields with correct types (no VARCHAR(255) by default)
    3. Add constraints: NOT NULL, UNIQUE, CHECK, foreign keys
    4. Add indexes for query patterns identified in step 1
    5. Generate migration file (up + down)
    6. Run migration against dev database
    7. Validate: run the expected queries, check EXPLAIN for index usage
## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "schema-tables": table definitions, constraints, indexes, migrations
  Agent 2 — "schema-validation": Zod/validation schemas derived from DB schema
  Agent 3 — "schema-seed": seed data, factories, fixtures for dev/test

MERGE ORDER: tables → validation → seed (validation mirrors tables, seed uses both)
CONFLICT ZONES: migration order numbers, shared type definitions (assign migration sequence first)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER design a schema without knowing the access patterns first.
2. NEVER use FLOAT/DOUBLE for money. Use DECIMAL/NUMERIC or integer cents.
3. ALWAYS use TIMESTAMPTZ (timestamp with time zone). Never bare TIMESTAMP.
4. EVERY foreign key column must have an index. No exceptions.
5. NEVER use natural keys as primary keys. Use surrogate keys (UUID or auto-increment).
6. EVERY migration must have a rollback (down migration). No forward-only migrations.
7. NEVER add a column with a default value in a way that locks the table (check your DB version).
8. Schema definitions must have ONE source of truth. Derive all others (Zod, JSON Schema) from it.
9. EVERY enum-like field must have a CHECK constraint or DB enum type. No unconstrained strings.
10. NEVER embed unbounded arrays in documents (NoSQL). Use references for unbounded collections.
```

## Output Format
Print on completion:
```
SCHEMA DESIGN: {description}
Database: {engine} | Model: {relational|document|graph|mixed}
Normalization: {level}
Entities: {N} | Relationships: {N} | Indexes: {N} | Constraints: {N}
Validation schema: {type (Zod/JSON Schema/Protobuf/Avro)}
Evolution strategy: {expand-contract|versioned|additive}
Multi-tenancy: {shared|schema-per|db-per|none}
Artifacts: {list of files created}
```

## TSV Logging
Log every schema session to `.godmode/schema-results.tsv`:
```
timestamp	description	database	model_type	normalization	entities	relationships	indexes	constraints	evolution_strategy	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. Access patterns identified before schema design begins.
2. Entity-Relationship diagram produced with cardinalities.
3. Every foreign key column has an index.
4. Every enum-like field has a CHECK constraint or DB enum type.
5. Timestamps use TIMESTAMPTZ, never bare TIMESTAMP.
6. Money fields use DECIMAL/NUMERIC or integer cents, never FLOAT/DOUBLE.
7. Every migration has both up and down scripts.
8. Validation schema (Zod/JSON Schema/Protobuf) derives from a single source of truth.
9. Primary keys are surrogate (UUID or auto-increment), never natural keys.

## Error Recovery
```
IF user provides no access patterns:
  → Ask: "What are the 5 most frequent queries? Read-heavy or write-heavy?"
  → Do NOT design schema until at least 3 access patterns are known

IF EXPLAIN ANALYZE shows sequential scan on an indexed column:
  → Check: is the index type correct for the query (B-tree vs GIN vs GiST)?
  → Check: is the planner choosing a different plan due to low row count?
  → Fix the index or add a hint, re-run EXPLAIN

IF migration fails on production-scale data:
  → Check: does the migration lock the table? (ALTER TABLE ADD COLUMN with default on old PG)
  → Split into safe steps: add nullable column → backfill in batches → add NOT NULL constraint
  → Use CONCURRENTLY for index creation on PostgreSQL

IF schema has circular foreign keys:
  → Break the cycle: one FK must be nullable or deferred
  → Document: "Circular FK between {A} and {B} — {A}.{col} is nullable to break cycle"

IF NoSQL document exceeds size limit (16MB MongoDB):
  → Identify unbounded array causing growth
  → Extract to separate collection with reference
  → Add index on the reference field

IF parallel validation/seed agents produce conflicting migration numbers:
  → Assign migration number sequence before dispatching agents
  → Convention: Agent 1 gets 001-010, Agent 2 gets 011-020, Agent 3 gets 021-030
```

## Schema Migration Safety Loop

Autonomous loop that validates migrations, applies them, verifies correctness, and tests rollback. Every migration is proven safe before committing.

```
SCHEMA MIGRATION SAFETY LOOP:
current_iteration = 0
max_iterations = 10
migrations = detect_pending_migrations()  // from migration tool output

FOR each migration in migrations:
  current_iteration += 1
  IF current_iteration > max_iterations: BREAK

  // Phase 1: Static Validation
  static_checks = {
    has_up_and_down:        migration_has_both_up_and_down_script(),
    no_table_lock_risk:     no_alter_column_type_or_not_null_on_large_table(),
    // Large = > 1M rows. These lock the table on older PG versions.
    concurrent_indexes:     all_create_index_use_concurrently(),
    no_drop_column:         no_drop_column_without_expand_contract(),
    // Drop only allowed in CONTRACT phase after EXPAND+MIGRATE
    fk_has_index:           every_new_foreign_key_column_has_index(),
    timestamptz_not_ts:     all_new_timestamp_columns_use_timestamptz(),
    no_float_for_money:     no_float_or_double_for_monetary_fields(),
    enum_has_constraint:    all_new_enum_fields_have_check_or_db_enum(),
    default_safe:           add_column_default_is_safe_for_pg_version()
    // PG 11+ can add column with default without table lock
  }

  FOR each check in static_checks:
    IF check.status == FAIL:
      FIX the migration
      LOG: "STATIC fix: {check.name} in migration {migration.name}"

  // Phase 2: Apply to Test Database
  apply_result = run_migration_up(migration, target="test_db")
  IF apply_result.failed:
    DIAGNOSE error (constraint violation, syntax, lock timeout)
    FIX the migration
    RETRY up to 3 times

## Platform Fallback
Run tasks sequentially with branch isolation if `Agent()` or `EnterWorktree` unavailable. See `adapters/shared/sequential-dispatch.md`.
## Keep/Discard Discipline
```
After EACH schema entity or migration:
  1. MEASURE: Run migration up+down — does it apply and rollback cleanly?
  2. VERIFY: EXPLAIN ANALYZE key queries — do indexes get used?
  3. DECIDE:
     - KEEP if: migration applies cleanly AND rollback works AND query plans use indexes
     - DISCARD if: migration locks table >5s OR rollback fails OR query plan shows seq scan on indexed column
  4. COMMIT kept changes. Revert discarded changes before the next entity.

Never keep a schema change that breaks an existing query plan or locks a production table.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All entities have migrations with verified up+down scripts
  - All FK columns have indexes and EXPLAIN shows index usage
  - Validation schema matches database schema (single source of truth)
  - User explicitly requests stop

DO NOT STOP just because:
  - One entity has a complex migration (finish it)
  - Query performance is "good enough" without checking EXPLAIN
```