---
name: nosql
description: |
  NoSQL database design skill. Activates when a developer needs to model data for document, key-value, wide-column, graph, or time-series databases. Covers MongoDB document modeling and aggregation pipeline, DynamoDB single-table design with GSI/LSI strategies, Cassandra partition key design, Neo4j graph modeling and Cypher queries, time-series databases (InfluxDB, TimescaleDB), and guidance on when to use which NoSQL database. Triggers on: /godmode:nosql, "mongodb schema", "dynamodb design", "cassandra data model", "neo4j graph", "which database should I use", "nosql vs sql", or when the orchestrator detects NoSQL database design work.
---

# NoSQL -- NoSQL Database Design

## When to Activate
- User invokes `/godmode:nosql`
- User says "mongodb schema", "document model", "aggregation pipeline"
- User says "dynamodb design", "single-table design", "GSI", "LSI"
- User says "cassandra model", "partition key", "wide-column"
- User says "neo4j", "graph database", "cypher query"
- User says "time-series database", "InfluxDB", "metrics storage"
- User asks "which database should I use?", "nosql vs sql?"
- When `/godmode:schema` identifies NoSQL as the right data layer
- When `/godmode:architect` needs to select a database technology

## Workflow

### Step 1: Requirements Assessment

Determine the data model requirements before selecting a database:

```
NOSQL REQUIREMENTS:
Data model:        <Document | Key-Value | Wide-Column | Graph | Time-Series>
Access patterns:   <list of read/write patterns with frequency>
```

### Step 2: Database Selection

#### When to Use Which Database

```
DATABASE SELECTION MATRIX:
|  If your data looks like...    | Use            | Not          |
```

```
NOSQL vs SQL:
|  Choose SQL (PostgreSQL) when:  | Choose NoSQL when:          |
```

### Step 3: MongoDB Document Modeling

#### Document Design Principles

```
MONGODB MODELING RULES:
1. Model for your queries, not for your entities
2. Embed when: data is read together, 1:1 or 1:few relationship
```

#### Document Modeling Patterns

```javascript
// PATTERN 1: Embedded Document (1:few, read-together)
// Orders with line items -- always read together
{
```

#### MongoDB Aggregation Pipeline

```javascript
// Multi-stage aggregation: Sales report by region and category
db.orders.aggregate([
  // Stage 1: Filter to completed orders in date range
```

#### MongoDB Indexing

```javascript
// Compound index (most important -- covers multiple query patterns)
db.orders.createIndex({ customer_id: 1, created_at: -1 })
// Serves: find by customer, find by customer sorted by date, sort by date within customer
```

### Step 4: DynamoDB Single-Table Design

#### Core Concepts

```
DYNAMODB FUNDAMENTALS:
- Table = collection of items (rows)
- Item = collection of attributes (columns)
```

#### Single-Table Design Example

```
E-COMMERCE -- Single Table Design

ACCESS PATTERNS:
```

#### GSI and LSI Strategies

```
GSI (Global Secondary Index):
- Different PK + SK than base table
- Eventually consistent (or strongly consistent with extra cost)
```

#### DynamoDB Best Practices

```
DYNAMODB RULES:
1. Design for access patterns FIRST, entity model second
2. One table for all entity types (single-table design)
```

### Step 5: Cassandra Partition Key Design

#### Data Modeling

```
CASSANDRA MODELING RULES:
1. One table per query (query-driven design)
2. Partition key determines data distribution AND locality
```

```sql
-- Cassandra table design for IoT sensor data
-- Query: Get readings for a sensor in a time range

```

```
CASSANDRA PARTITION SIZING:
Target: < 100MB per partition, < 100K rows per partition

```

```sql
-- Multi-table design for different queries on same data

-- Table 1: User's orders by date
```

### Step 6: Neo4j Graph Modeling

#### Graph Design

```
GRAPH MODELING RULES:
1. Nodes are entities (nouns): Person, Product, Company
2. Relationships are connections (verbs): BOUGHT, WORKS_AT, FOLLOWS
```

#### Cypher Queries

```cypher
// CREATE nodes and relationships
CREATE (alice:Person {name: 'Alice', age: 32})
CREATE (bob:Person {name: 'Bob', age: 28})
```

#### Graph Modeling Patterns

```
PATTERN 1: Social Network
  (:Person)-[:FOLLOWS]->(:Person)
  (:Person)-[:POSTED]->(:Post)
```

### Step 7: Time-Series Databases

#### InfluxDB

```
INFLUXDB CONCEPTS:
- Measurement: like a table (e.g., "cpu_usage")
- Tags: indexed metadata (e.g., host, region) -- strings only
```

```sql
-- InfluxDB (Flux query language)
-- Write data
// Line protocol: measurement,tag=value field=value timestamp
```

#### TimescaleDB (already covered in postgres skill -- brief summary)

```
TIMESCALEDB vs INFLUXDB:
|  Feature              | TimescaleDB        | InfluxDB          |
```

### Step 8: Report and Transition

```
|  NOSQL DESIGN -- <description>                              |
```

Commit: `"nosql: <description> -- <database>, <key design decisions>"`

## Key Behaviors

1. **Access patterns first.** In NoSQL, you design the data model around your queries, not around your entities. List every access pattern before drawing a single schema.
2. **Denormalize deliberately.** NoSQL databases trade storage and write amplification for read performance. Duplication is a feature, not a bug. But document every denormalization decision.
3. **Know your partition key.** In DynamoDB and Cassandra, the partition key determines everything: data distribution, query capability, and hot partition risk. Get it right on day one.
4. **Embed vs. reference in MongoDB.** Embed when data is read together and the subdocument is small and bounded. Reference when data is independent, large, or shared across documents.
5. **One table per query in Cassandra.** Cassandra has no JOINs. Each query needs its own table optimized for that exact read pattern, even if it means writing the same data 3-4 times.
6. **Graph databases for relationships.** If your queries are "find connections", "shortest path", or "people who also X", a graph database runs 100-1000x faster than JOINs.
7. **Time-series databases for metrics.** PostgreSQL with TimescaleDB handles most time-series workloads. Use InfluxDB for high-cardinality pure metrics at massive scale.
8. **Start with PostgreSQL.** Default to PostgreSQL. Move to NoSQL only when PostgreSQL cannot meet a specific technical requirement.
9. **Bound your partitions.** In DynamoDB, Cassandra, and MongoDB, unbounded collections (growing forever in one partition/document) cause performance degradation. Use time buckets, size limits, or pagination.
10. **Schema validation in MongoDB.** MongoDB is schemaless, not schema-free. Use JSON Schema validation to enforce document structure in production.

## Iterative Data Modeling Protocol

```
WHEN designing a NoSQL data model:

current_pattern = 0
```

## HARD RULES

```
1. NEVER design a NoSQL schema before listing ALL access patterns.
   In NoSQL, you model for queries, not for entities.

```

## Output Format

After every NoSQL operation (database selection, schema design, query optimization, migration), emit a structured result box:

```
┌─ NOSQL RESULT ──────────────────────────────────────┐
  Database : DynamoDB
  Operation : single-table design for e-commerce
```
timestamp	database	operation	entity_count	access_patterns_covered	access_patterns_total	partition_strategy	hot_partition_risk	verdict
2026-03-20T14:30:00Z	DynamoDB	single-table-design	4	12	12	composite-PK	LOW	READY
2026-03-20T14:35:00Z	MongoDB	schema-validation	3	8	8	sharded-by-tenant	LOW	READY
2026-03-20T14:40:00Z	Cassandra	table-per-query	6	15	18	time-bucketed	MEDIUM	NEEDS_TUNING
```

## Success Criteria

```
NOSQL AUDIT LOOP:
max_iterations = 15

WHILE NOT all_patterns_covered AND iteration < max_iterations:
  Phase 1 — Access Pattern Coverage:
    FOR each access pattern: verify it serves without scan
    MongoDB: check index covers query. DynamoDB: PK/SK or GSI. Cassandra: table exists.
    Fix uncovered patterns: add GSI, index, or denormalized table.

  Phase 2 — Partition Key Optimization (DynamoDB/Cassandra):
    Check for hot partitions (>30% of traffic on one partition) → add write sharding
    Check partition sizes (DynamoDB <10GB, Cassandra <100MB) → add time bucketing
    Check PK cardinality (<100 on high-volume tables) → use composite key

  Phase 3 — Document Validation (MongoDB):
```

## Keep/Discard Discipline
```
After EACH implementation or optimization change:
  1. MEASURE: Run tests / validate the change produces correct output.
  2. COMPARE: Is the result better than before? (faster, safer, more correct)
  3. DECIDE:
     - KEEP if: tests pass AND quality improved AND no regressions introduced
     - DISCARD if: tests fail OR performance regressed OR new errors introduced
  4. COMMIT kept changes with descriptive message. Revert discarded changes before proceeding.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All identified tasks are complete and validated
  - User explicitly requests stop
  - Max iterations reached — report partial results with remaining items listed

DO NOT STOP only because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (handle that in a follow-up pass)
```


## Error Recovery
| Failure | Action |
|--|--|
| Query performance degrades with data growth | Check index usage with `explain()`. Add compound indexes matching query patterns. Use sharding for horizontal scale. |
| Data inconsistency across replicas | Check write concern settings. Use `majority` write concern for critical data. Add application-level reconciliation. |
| Schema migration breaks existing documents | Add default values for new fields at application layer. Use lazy migration: update documents on read. Never drop fields without checking all consumers. |
| Connection pool exhaustion | Increase pool size. Check for connection leaks (unclosed cursors, long-running transactions). Add connection timeout. |

## TSV Logging
Append to `.godmode/nosql-results.tsv`:
```
timestamp	database	action	collection	index_count	query_ms_p95	status
```
One row per optimization or schema change. Never overwrite previous rows.
