---
name: schema
description: >
  Data modeling and schema design. Relational, NoSQL,
  migrations, ER modeling, validation schemas.
---

# Schema -- Data Modeling & Schema Design

## Activate When
- `/godmode:schema`, "data model", "design the schema"
- Normalization, denormalization, schema trade-offs
- NoSQL data modeling, validation schemas (Zod, Protobuf)
- Schema evolution, versioning, backward compatibility

## Workflow

### Step 1: Understand the Domain
```
DOMAIN ANALYSIS:
Application:    <purpose>
Entities:       <core business objects>
Access patterns: <primary read/write ops>
Scale:          <volume per entity>
Consistency:    <strong | eventual | mixed>
Database:       <PostgreSQL | MySQL | MongoDB | etc>
```
Key questions:
```
1. What are the core entities? (nouns)
2. How do they relate? (1:1, 1:N, M:N)
3. Most frequent queries? (reads drive schema)
4. Write-to-read ratio? (heavy writes vs reads)
5. Expected volume? (thousands vs billions)
6. Consistency guarantees? (financial vs analytics)
7. Will schema evolve frequently?
8. Multi-tenancy requirements?
```

### Step 2: Entity-Relationship Modeling
```
ENTITY CATALOG:
| Entity   | Key Attributes              | Volume |
|----------|----------------------------|--------|
| User     | id, email, name, role      | 100K   |
| Project  | id, name, org_id           | 500K   |
| Task     | id, title, status, user_id | 5M     |
| Comment  | id, body, author_id        | 20M    |

Organization 1:N -> Project 1:N -> Task 1:N -> Comment
Task N:1 -> User (assignee), Task M:N -> Tag
```

### Step 3: Relational Schema Design

#### Normalization
```
1NF: Atomic values, no repeating groups
2NF: No partial dependencies on composite key
3NF: No transitive dependencies
BCNF: Every determinant is a candidate key
```
Start at 3NF. Denormalize only when EXPLAIN proves
joins are the bottleneck.

#### When to Denormalize
```
IF read frequency >> write frequency: denormalize
IF join is bottleneck in EXPLAIN: materialized view
IF data is point-in-time: snapshot at creation
IF aggregation is expensive AND frequent:
  counter cache (e.g., comment_count on Task)
```

#### SQL Schema Generation
```sql
CREATE TABLE organizations (
  id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  plan VARCHAR(50) NOT NULL DEFAULT 'free'
       CHECK (plan IN ('free','pro','enterprise')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_org_plan ON organizations(plan);
```

### Step 4: NoSQL Data Modeling
```
EMBED vs REFERENCE:
IF data always read together (1:few): EMBED
IF child rarely changes independently: EMBED
IF data shared across many documents: REFERENCE
IF child changes frequently: REFERENCE
IF array could grow unbounded: REFERENCE (always)
```

### Step 5: Schema Evolution
```bash
# Create migration
npx prisma migrate dev --name add_user_role
# Or with Flyway
flyway migrate -url=jdbc:postgresql://localhost/mydb
```

Safe changes (no downtime): add nullable column,
add column with default, add table, add index
CONCURRENTLY, widen column type.

#### Expand-Contract for Breaking Changes
```
Phase 1 EXPAND: Add new column, dual-write, backfill
Phase 2 MIGRATE: Read/write only new column
Phase 3 CONTRACT: Drop old column
Timeline: days to weeks between phases
```

### Step 6: Validation Schemas (Zod)
```typescript
import { z } from 'zod';
export const userSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email().max(255),
  name: z.string().min(1).max(255),
  role: z.enum(['owner','admin','member','viewer']),
});
export type User = z.infer<typeof userSchema>;
```

### Step 7: Multi-Tenancy
```
IF many small tenants: shared schema + tenant_id
  (row-level security, low complexity)
IF moderate isolation: schema per tenant (SET search_path)
IF enterprise compliance: database per tenant
  (full isolation, high complexity)
```

### Step 8: Report
```
SCHEMA DESIGN: {description}
Database: {engine} | Model: {type}
Entities: {N} | Relationships: {N} | Indexes: {N}
Evolution: {expand-contract|versioned|additive}
```
Commit: `"schema: design <desc> data model"`

## Key Behaviors
1. **Access patterns drive schema.** Design for reads.
2. **Start normalized, denormalize with evidence.**
3. **Every table needs a primary key.** UUID or BIGSERIAL.
4. **Foreign keys are not optional.**
5. **Timestamps on everything.** Use TIMESTAMPTZ.
6. **Constraints in DB, validation in app.**
7. **Never ask to continue. Loop autonomously.**

## HARD RULES
1. NEVER design without knowing access patterns.
2. NEVER use FLOAT for money. Use DECIMAL or cents.
3. ALWAYS use TIMESTAMPTZ, never bare TIMESTAMP.
4. EVERY FK column must have an index.
5. NEVER use natural keys as primary keys.
6. EVERY migration must have a rollback script.
7. EVERY enum field needs CHECK or DB enum type.
8. NEVER embed unbounded arrays in documents.

## Auto-Detection
```bash
ls prisma/ migrations/ db/migrate/ alembic/ 2>/dev/null
grep -r "CREATE TABLE\|CREATE INDEX" \
  --include="*.sql" -l 2>/dev/null | head -5
grep -r "z.object\|Joi.object\|yup.object" \
  --include="*.ts" -l 2>/dev/null | head -5
```

## TSV Logging
Log to `.godmode/schema-results.tsv`:
`timestamp\tdatabase\tmodel_type\tentities\tindexes\tverdict`

## Keep/Discard Discipline
```
KEEP if: migration applies AND rollback works
  AND EXPLAIN shows index usage
DISCARD if: migration locks table >5s
  OR rollback fails OR seq scan on indexed column
```

## Stop Conditions
```
STOP when:
  - All entities have verified up+down migrations
  - All FK columns have indexes
  - Validation schema matches DB schema
  - User requests stop
```
