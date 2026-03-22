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
| Entity            | Key Attributes                             | Expected Volume  |
|--|--|--|
| User              | id, email, name, role, created_at          | 100K             |
| Organization      | id, name, plan, billing_email              | 10K              |
| Project           | id, name, description, org_id              | 500K             |
| Task              | id, title, status, assignee_id, project_id | 5M               |
| Comment           | id, body, author_id, task_id, created_at   | 20M              |
```
#### 2b: Define Relationships

```
RELATIONSHIP MAP:
| From              | Relationship   | To                | Cardinality       |
|--|--|--|--|
| Organization      | has many       | User              | 1:N               |
| Organization      | has many       | Project           | 1:N               |
| User              | belongs to     | Organization      | N:1               |
| Project           | has many       | Task              | 1:N               |
| Task              | has many       | Comment           | 1:N               |
| Task              | assigned to    | User              | N:1               |
| User              | has many       | Comment           | 1:N               |
| Task              | has many       | Tag (through)     | M:N               |
```
#### 2c: ER Diagram (Text)

```
┌──────────────┐     1:N     ┌──────────────┐     1:N     ┌──────────────┐
| Organization | ────────────> | Project | ────────────> | Task |
│              │             │              │             │              │
| id (PK) |  | id (PK) |  | id (PK) |
|--|--|--|--|--|
| name |  | name |  | title |
| plan |  | description |  | status |
| billing_email |  | org_id (FK) |  | priority |
| created_at |  | created_at |  | assignee_id |
└──────────────┘             └──────────────┘             │ project_id   │
|  | created_at |
       │ 1:N                                               └──────────────┘
       ▼                                                          │
┌──────────────┐                                           1:N    │
│    User      │                                                  ▼
│              │                                           ┌──────────────┐
```
### Step 3: Relational Schema Design

#### 3a: Normalization Levels

```
NORMALIZATION GUIDE:
| Form   | Rule                       | What It Eliminates                     |
|--|--|--|
| 1NF    | Atomic values, no          | Repeating groups, multi-valued         |
|        | repeating groups            | columns (tags as CSV string)           |
| 2NF    | 1NF + no partial           | Columns dependent on part of a         |
|        | dependencies               | composite key                          |
| 3NF    | 2NF + no transitive        | Columns dependent on non-key           |
|        | dependencies               | columns (city -> zip -> state)         |
| BCNF   | Every determinant is a     | Anomalies in tables with overlapping   |
|        | candidate key              | candidate keys                         |
```
**Practical rule:** Start at 3NF. Denormalize only when you can prove (with query profiling) that joins are a bottleneck.

#### 3b: When to Denormalize

```
DENORMALIZATION DECISION:
| Denormalize WHEN           | Example                                   |
|--|--|
| Read frequency >> write    | Product listing with category name        |
| frequency for the data     | (read 1000x/sec, category changes 1x/day)|
| Join is consistently the   | Dashboard query joining 5 tables;         |
| bottleneck in EXPLAIN      | materialized view or cached columns       |
| Data is historical/        | Order snapshot with product name/price    |
| point-in-time              | at time of purchase (must not change)     |
| Aggregation is expensive   | Counter cache: comment_count on Task      |
| and frequently needed      | instead of COUNT(*) on every page load    |
```
#### 3c: SQL Schema Generation

```sql
-- Fully normalized 3NF schema
CREATE TABLE organizations (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(255) NOT NULL,
    plan        VARCHAR(50) NOT NULL DEFAULT 'free'
                CHECK (plan IN ('free', 'pro', 'enterprise')),
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
| EMBED when                | REFERENCE when            |
|--|--|
| Data is always read       | Data is shared across     |
| together (1:few)          | many documents            |
| Child rarely changes      | Child changes frequently  |
| independently             | and independently         |
```
```javascript
// MongoDB document model: e-commerce order
// GOOD: Embed items (bounded, always read with order, point-in-time snapshot)
{
  _id: ObjectId("..."),
  orderNumber: "ORD-2025-001",
  customer: {
```
#### 4b: Key-Value Store (Redis/DynamoDB)

```
KEY-VALUE DESIGN PATTERNS:

### Step 5: Schema Evolution and Migrations

#### 5a: Backward-Compatible Changes (Safe)

```
SAFE SCHEMA CHANGES (no downtime, no coordination):
| Change                     | Why It's Safe                                |
|--|--|
| Add nullable column        | Existing rows get NULL, old code ignores it  |
| Add column with default    | Existing rows get default, old code ignores  |
| Add new table              | No existing code references it               |
| Add new index              | CONCURRENTLY avoids locks (PostgreSQL)       |
| Widen a column type        | INT -> BIGINT, VARCHAR(50) -> VARCHAR(255)   |
| Add CHECK constraint       | If all existing data satisfies it             |
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
| Strategy          | How It Works                              | Best For            |
|--|--|--|
| Sequential        | 001_create_users.sql, 002_add_email.sql   | Relational DBs      |
| migrations        | Applied in order, tracked in table         | (most common)       |
| Schema registry   | Central registry stores schema versions   | Event streaming     |
| (Avro/Protobuf)   | Checks forward/backward compatibility     | (Kafka, Pulsar)     |
| Document          | Each document carries a "version" field   | Document stores     |
| versioning        | Application handles multiple versions     | (MongoDB)           |
| API versioning    | /v1/users, /v2/users with different       | APIs with external  |
|                   | schemas behind the same DB                | consumers           |
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
```

#### 6b: JSON Schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://example.com/schemas/user.json",
  "type": "object",
  "required": ["email", "name", "role", "orgId"],
  "properties": {
```
MULTI-TENANCY STRATEGIES:
| Strategy          | Isolation          | Complexity        | Best For          |
|--|--|--|--|
| Shared schema     | Row-level (WHERE   | Low               | SaaS with many    |
| (tenant_id col)   | tenant_id = ?)    |                   | small tenants     |
| Schema per tenant | Schema-level       | Medium            | Medium tenants    |
| (PostgreSQL       | (SET search_path) |                   | needing some      |
|  schemas)         |                   |                   | isolation         |
| Database per      | Full database      | High              | Enterprise with   |
| tenant            | isolation          |                   | compliance needs  |

SHARED SCHEMA WITH ROW-LEVEL SECURITY:
-- PostgreSQL RLS example
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
### Step 8: Report and Transition

```
|  SCHEMA DESIGN -- <description>                               |
|  Database:          <engine>                                  |
|  Model type:        <relational | document | graph | mixed>   |
|  Normalization:     <1NF | 2NF | 3NF | BCNF | denormalized> |
|  Entities:          <N entities defined>                      |
|  Relationships:     <N relationships defined>                 |
|  Indexes:           <N indexes recommended>                   |
|  Constraints:       <N constraints added>                     |
|  Schema artifacts:                                            |
|  - <SQL migration or schema file>                             |
|  - <Validation schema (Zod/JSON Schema/Protobuf)>            |
|  - <ER diagram>                                               |
|  Evolution strategy: <expand-contract | versioned | additive> |
|  Multi-tenancy:      <shared | schema-per | db-per | none>   |
```

Commit: `"schema: design <description> data model"`

## Key Behaviors

1. **Access patterns drive schema design.** The most common queries determine the schema, not normalization theory. Design for how data is read, then verify writes are acceptable.
2. **Start normalized, denormalize with evidence.** Begin at 3NF. Only denormalize when EXPLAIN ANALYZE proves joins are the bottleneck. Premature denormalization creates update anomalies.
3. **Every table needs a primary key.** Use UUID for distributed systems, BIGSERIAL for single-database systems. Never use natural keys (email, SSN) as primary keys -- they change.
4. **Foreign keys are not optional.** They enforce referential integrity at the database level. Application-level checks are not a substitute. Include ON DELETE behavior (CASCADE, SET NULL, RESTRICT).
5. **Timestamps on everything.** Every table gets `created_at` and `updated_at`. Use TIMESTAMPTZ, not TIMESTAMP. Time zones matter.
6. **Constraints in the database, validation in the application.** The database is the last line of defense. CHECK constraints, NOT NULL, UNIQUE, and foreign keys prevent invalid data even when application code has bugs.
7. **Keep schema evolution backward compatible.** Deploy every migration without downtime. Use the expand-contract pattern for breaking changes.
8. **Document models are designed around queries.** In NoSQL, embed data that is read together, reference data that is shared. There is no "correct" document structure -- only structures that serve your access patterns.
9. **Validation schemas are the single source of truth.** Define the schema once (Zod, Protobuf, Avro), derive types, API docs, and database constraints from it. Never maintain parallel definitions.
10. **Test schema changes against production-scale data.** A migration that runs in 100ms on dev (1000 rows) may lock the table for 30 minutes in production (10M rows).

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive schema design workflow |
| `--er` | Generate entity-relationship diagram |
| `--normalize` | Analyze and normalize an existing schema |

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

DO NOT STOP only because:
  - One entity has a complex migration (finish it)
  - Query performance is "good enough" without checking EXPLAIN
```
## Error Recovery
| Failure | Action |
|--|--|
| Schema validation rejects valid data | Check for overly strict constraints. Verify nullable fields. Test with real-world data samples, not only idealized test data. |
| Schema migration breaks consumers | Use additive-only changes (new fields with defaults). Never remove or rename fields without deprecation period. Version the schema. |
| Circular references in schema | Break cycle with lazy references or ID-based relationships. Document the relationship direction. |
| Generated types drift from schema | Automate type generation in CI. Run codegen on every schema change. Never edit generated types manually. |
