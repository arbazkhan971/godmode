# /godmode:schema

Data modeling and schema design. Covers relational schemas (normalization, denormalization), NoSQL modeling (document, key-value, graph, time-series), schema evolution, entity-relationship modeling, and validation schemas (Zod, JSON Schema, Avro, Protobuf).

## Usage

```
/godmode:schema                               # Interactive schema design workflow
/godmode:schema --er                          # Generate entity-relationship diagram
/godmode:schema --normalize                   # Analyze and normalize an existing schema
/godmode:schema --denormalize                 # Evaluate denormalization with measurements
/godmode:schema --nosql                       # Design NoSQL data model
/godmode:schema --validate                    # Generate validation schemas (Zod, JSON Schema)
/godmode:schema --evolve                      # Plan backward-compatible schema evolution
/godmode:schema --multi-tenant                # Design multi-tenancy schema
/godmode:schema --audit                       # Audit schema for issues
/godmode:schema --compare                     # Compare schema versions for breaking changes
/godmode:schema --seed                        # Generate seed data for dev/testing
/godmode:schema --report                      # Full schema design report
```

## What It Does

1. Analyzes the domain — entities, relationships, access patterns, scale, consistency needs
2. Models entities and relationships with cardinality (1:1, 1:N, M:N)
3. Designs relational schema at appropriate normalization level (1NF through BCNF)
4. Evaluates denormalization trade-offs with evidence from query profiling
5. Designs NoSQL models (document embedding vs referencing, key-value patterns, graph traversals, time-series hypertables)
6. Plans schema evolution with backward-compatible migration strategies (expand-contract)
7. Generates validation schemas (Zod, JSON Schema, Protobuf, Avro) as the single source of truth
8. Designs multi-tenancy isolation (shared schema with RLS, schema-per-tenant, database-per-tenant)

## Output
- Entity-relationship diagram (text-based)
- SQL schema with indexes, constraints, and triggers
- Validation schemas (Zod/JSON Schema/Protobuf/Avro)
- Schema evolution plan
- Commit: `"schema: design <description> data model"`

## Next Step
After schema design: `/godmode:migrate` to generate database migrations, or `/godmode:orm` to configure the data access layer.

## Examples

```
/godmode:schema Design a schema for a project management tool with orgs, users, projects, tasks
/godmode:schema --er                          # Visualize entity relationships
/godmode:schema --nosql                       # Should I use MongoDB or PostgreSQL?
/godmode:schema --validate                    # Generate Zod schemas from my database
/godmode:schema --evolve                      # Rename a column safely in production
/godmode:schema --multi-tenant                # Add multi-tenancy to my SaaS
```
