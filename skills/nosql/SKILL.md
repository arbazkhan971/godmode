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
Data volume:       <current size, growth rate>
Read/write ratio:  <percentage split>
Consistency needs: <Strong | Eventual | Tunable>
Latency target:    <p50, p99 requirements>
    # ... (condensed)
Budget:            <Managed service OK | Self-hosted required>
```

### Step 2: Database Selection

#### When to Use Which Database

```
DATABASE SELECTION MATRIX:
+--------------------------------------------------------------+
|  If your data looks like...    | Use            | Not          |
+--------------------------------------------------------------+
|  Nested objects, flexible      | MongoDB        | Highly       |
|  schema, rich queries          |                | relational   |
+--------------------------------------------------------------+
    # ... (condensed)
   -> NO: PostgreSQL is probably the right choice
```

```
NOSQL vs SQL:
+--------------------------------------------------------------+
|  Choose SQL (PostgreSQL) when:  | Choose NoSQL when:          |
+--------------------------------------------------------------+
|  Complex joins across tables    | Flexible/evolving schema    |
|  ACID transactions required     | Horizontal scaling needed   |
|  Ad-hoc queries are common      | Access patterns are known   |
|  Relational integrity matters   | Denormalization is OK       |
|  Schema is stable and known     | High write throughput       |
|  Reporting and analytics        | Geographic distribution     |
|  Under 10TB of data             | Specific data model (graph, |
|  One region is sufficient       | time-series, key-value)     |
+--------------------------------------------------------------+

DEFAULT ADVICE:
Start with PostgreSQL. Move to NoSQL when PostgreSQL cannot meet
a specific requirement (scale, schema flexibility, data model fit).
Do not choose NoSQL because it is "trendy" or "webscale."
```

### Step 3: MongoDB Document Modeling

#### Document Design Principles

```
MONGODB MODELING RULES:
1. Model for your queries, not for your entities
2. Embed when: data is read together, 1:1 or 1:few relationship
3. Reference when: data is read independently, 1:many or many:many
4. Denormalize reads, normalize writes
5. Document size limit: 16MB (design for << 1MB typical)

EMBEDDING vs REFERENCING:
+--------------------------------------------------------------+
|  Embed when:                   | Reference when:              |
+--------------------------------------------------------------+
|  Data is always read together  | Data is read independently   |
|  1:1 or 1:few relationship     | 1:many (unbounded) relation  |
|  Data doesn't change often     | Data changes frequently      |
|  Sub-document < 1KB            | Sub-document is large        |
|  No duplication needed         | Same data shared by many     |
+--------------------------------------------------------------+
```

#### Document Modeling Patterns

```javascript
// PATTERN 1: Embedded Document (1:few, read-together)
// Orders with line items -- always read together
{
  _id: ObjectId("..."),
  order_number: "ORD-2025-001",
  customer: {
    id: ObjectId("..."),
    name: "Alice Johnson",
    email: "alice@example.com"
  },
  items: [
    { product_id: ObjectId("..."), name: "Widget", qty: 2, price: 29.99 },
    { product_id: ObjectId("..."), name: "Gadget", qty: 1, price: 49.99 }
  ],
  total: 109.97,
  status: "shipped",
  created_at: ISODate("2025-01-15T10:30:00Z")
    # ... (condensed)
// Discriminator: "type" field determines document shape
```

#### MongoDB Aggregation Pipeline

```javascript
// Multi-stage aggregation: Sales report by region and category
db.orders.aggregate([
  // Stage 1: Filter to completed orders in date range
  { $match: {
      status: "completed",
      created_at: {
        $gte: ISODate("2025-01-01"),
        $lt: ISODate("2025-02-01")
      }
  }},

  // Stage 2: Unwind line items (one doc per item)
  { $unwind: "$items" },

  // Stage 3: Lookup product details
  { $lookup: {
      from: "products",
    # ... (condensed)
// 5. $merge/$out: write results to a collection for materialized views
```

#### MongoDB Indexing

```javascript
// Compound index (most important -- covers multiple query patterns)
db.orders.createIndex({ customer_id: 1, created_at: -1 })
// Serves: find by customer, find by customer sorted by date, sort by date within customer

// Partial index (only index documents matching a filter)
db.orders.createIndex(
  { status: 1, created_at: -1 },
  { partialFilterExpression: { status: { $in: ["pending", "processing"] } } }
)
// Smaller index, only covers active orders

// Text index (full-text search)
db.articles.createIndex({ title: "text", body: "text" }, { weights: { title: 10, body: 1 } })
db.articles.find({ $text: { $search: "mongodb performance" } })

// Wildcard index (flexible schema)
db.events.createIndex({ "payload.$**": 1 })
    # ... (condensed)
// But compound indexes are almost always better than relying on intersection
```

### Step 4: DynamoDB Single-Table Design

#### Core Concepts

```
DYNAMODB FUNDAMENTALS:
- Table = collection of items (rows)
- Item = collection of attributes (columns)
- Partition Key (PK): determines data distribution
- Sort Key (SK): enables range queries within a partition
- Item size limit: 400KB
- Provisioned or On-Demand capacity

ACCESS PATTERN FIRST DESIGN:
1. List ALL access patterns before designing the table
2. Design PK + SK to serve the most critical patterns
3. Use GSIs for remaining patterns
4. Denormalize aggressively -- no JOINs in DynamoDB

SINGLE-TABLE DESIGN:
All entity types in ONE table with composite PK/SK
PK pattern:   <ENTITY>#<ID>
SK pattern:   <ENTITY>#<ID> or <RELATIONSHIP>#<SORT_VALUE>
```

#### Single-Table Design Example

```
E-COMMERCE -- Single Table Design

ACCESS PATTERNS:
1. Get customer by ID
2. Get order by ID
3. Get all orders for a customer (sorted by date)
4. Get all items in an order
5. Get product by ID
6. Get all orders for a product (across customers)

TABLE DESIGN:
+--------------------------------------------------------------+
|  PK                  | SK                    | Data            |
+--------------------------------------------------------------+
|  CUSTOMER#cust-123   | CUSTOMER#cust-123     | name, email,    |
|                      |                       | plan, created   |
+--------------------------------------------------------------+
    # ... (condensed)
6. Product orders:   GSI1 (see below)
```

#### GSI and LSI Strategies

```
GSI (Global Secondary Index):
- Different PK + SK than base table
- Eventually consistent (or strongly consistent with extra cost)
- Has its own provisioned throughput
- Maximum 20 GSIs per table

LSI (Local Secondary Index):
- Same PK as base table, different SK
- Strongly consistent reads available
- Must be created at table creation time
- Maximum 5 LSIs per table
- Shares base table's throughput

GSI DESIGN for E-Commerce:
GSI1 -- "Inverted Index" (product -> orders)
  GSI1-PK: product_id  (attribute projected from items)
  GSI1-SK: order_date
    # ... (condensed)
  One GSI, three access patterns
```

#### DynamoDB Best Practices

```
DYNAMODB RULES:
1. Design for access patterns FIRST, entity model second
2. One table for all entity types (single-table design)
3. No JOINs -- denormalize everything
4. PK should have high cardinality (distribute evenly)
5. Use SK for sorting, filtering, and one-to-many relationships
6. GSIs are expensive -- use overloaded GSIs
7. Use transactions sparingly (2x write cost)
8. BatchGetItem/BatchWriteItem for bulk operations
9. Item size < 400KB -- split large items
10. Use DynamoDB Streams for change data capture

CAPACITY PLANNING:
  On-Demand:  Best for unpredictable workloads, development, spiky traffic
  Provisioned: Best for steady workloads, cheaper at scale, with auto-scaling

  WCU (Write Capacity Unit) = 1 write/sec for items up to 1KB
    # ... (condensed)
    Sum all 10 shards for total count
```

### Step 5: Cassandra Partition Key Design

#### Data Modeling

```
CASSANDRA MODELING RULES:
1. One table per query (query-driven design)
2. Partition key determines data distribution AND locality
3. Clustering columns determine sort order within a partition
4. No JOINs, no subqueries, no aggregations across partitions
5. Denormalize heavily -- duplicate data across tables

PARTITION KEY DESIGN:
  partition_key -> hash -> token -> node
  All rows with the same partition key are on the same node

  GOOD partition key:
  - High cardinality (many distinct values)
  - Even distribution (no hot partitions)
  - Used in every query's WHERE clause

  BAD partition key:
  - Low cardinality (e.g., status, country)
  - Time-based without bucketing (all today's data on one partition)
  - User-based if one user has 100x more data than average
```

```sql
-- Cassandra table design for IoT sensor data
-- Query: Get readings for a sensor in a time range

CREATE TABLE sensor_readings (
    sensor_id    TEXT,
    day          DATE,           -- bucket by day to bound partition size
    reading_time TIMESTAMP,
    temperature  DOUBLE,
    humidity     DOUBLE,
    pressure     DOUBLE,
    PRIMARY KEY ((sensor_id, day), reading_time)
    -- Partition key: (sensor_id, day) -- composite
    -- Clustering key: reading_time -- sorted within partition
) WITH CLUSTERING ORDER BY (reading_time DESC)
  AND compaction = {'class': 'TimeWindowCompactionStrategy',
                    'compaction_window_size': 1,
                    'compaction_window_unit': 'DAYS'}
  AND default_time_to_live = 7776000;  -- 90 days TTL

    # ...
-- A sensor sending 1 reading/sec = 86,400 rows/day = 31M rows/year
-- Partition too large! Bucket by day or hour.
```

```
CASSANDRA PARTITION SIZING:
Target: < 100MB per partition, < 100K rows per partition

BUCKET STRATEGIES:
+--------------------------------------------------------------+
|  Data Rate             | Bucket By    | Partition Size         |
+--------------------------------------------------------------+
|  1 event/min           | month        | ~43K rows/partition    |
|  1 event/sec           | day          | ~86K rows/partition    |
|  100 events/sec        | hour         | ~360K rows/partition   |
|  1000 events/sec       | minute       | ~60K rows/partition    |
+--------------------------------------------------------------+

WIDE-ROW PATTERN:
  Partition key: entity + time bucket
  Clustering key: timestamp + unique ID
  Each partition = one time window of data for one entity
  Enables efficient range scans within the window
```

```sql
-- Multi-table design for different queries on same data

-- Table 1: User's orders by date
CREATE TABLE orders_by_user (
    user_id       UUID,
    order_date    TIMESTAMP,
    order_id      UUID,
    total         DECIMAL,
    status        TEXT,
    PRIMARY KEY (user_id, order_date, order_id)
) WITH CLUSTERING ORDER BY (order_date DESC, order_id ASC);

-- Table 2: Orders by status (for admin dashboard)
CREATE TABLE orders_by_status (
    status        TEXT,
    order_date    TIMESTAMP,
    order_id      UUID,
    user_id       UUID,
    total         DECIMAL,
    # ...
-- ALL THREE TABLES are written to on every order create/update
-- This is normal in Cassandra -- trade write amplification for read performance
```

### Step 6: Neo4j Graph Modeling

#### Graph Design

```
GRAPH MODELING RULES:
1. Nodes are entities (nouns): Person, Product, Company
2. Relationships are connections (verbs): BOUGHT, WORKS_AT, FOLLOWS
3. Properties are attributes on nodes/relationships
4. Model relationships explicitly -- they are first-class citizens
5. Relationships always have a direction (but can be traversed either way)

WHEN TO USE A GRAPH DATABASE:
- Relationships between entities are the primary concern
- Queries involve traversing connections (friends-of-friends, shortest path)
- Data is naturally a network (social, organizational, dependency)
- Relational JOINs become 5+ tables deep
- Recommendation engines, fraud detection, knowledge graphs

GRAPH vs RELATIONAL:
+--------------------------------------------------------------+
|  Query                        | Relational    | Graph         |
+--------------------------------------------------------------+
|  Direct lookup by ID          | Fast          | Fast          |
    # ...
KEY INSIGHT: Graphs excel at relationship-centric queries.
Relational databases excel at set-based operations and aggregations.
```

#### Cypher Queries

```cypher
// CREATE nodes and relationships
CREATE (alice:Person {name: 'Alice', age: 32})
CREATE (bob:Person {name: 'Bob', age: 28})
CREATE (acme:Company {name: 'Acme Corp', industry: 'Tech'})

CREATE (alice)-[:WORKS_AT {since: 2020, role: 'Engineer'}]->(acme)
CREATE (bob)-[:WORKS_AT {since: 2022, role: 'Designer'}]->(acme)
CREATE (alice)-[:FOLLOWS]->(bob)

// MATCH: Find all people Alice follows
MATCH (alice:Person {name: 'Alice'})-[:FOLLOWS]->(followed)
RETURN followed.name

// Friends of friends (2 hops)
MATCH (alice:Person {name: 'Alice'})-[:FOLLOWS]->()-[:FOLLOWS]->(fof)
WHERE fof <> alice  // Exclude Alice herself
RETURN DISTINCT fof.name
    # ... (condensed)
CREATE CONSTRAINT person_email_unique FOR (p:Person) REQUIRE p.email IS UNIQUE
```

#### Graph Modeling Patterns

```
PATTERN 1: Social Network
  (:Person)-[:FOLLOWS]->(:Person)
  (:Person)-[:POSTED]->(:Post)
  (:Person)-[:LIKES]->(:Post)
  (:Post)-[:TAGGED_WITH]->(:Topic)

PATTERN 2: E-Commerce Recommendations
  (:Customer)-[:PURCHASED]->(:Product)
  (:Product)-[:IN_CATEGORY]->(:Category)
  (:Product)-[:SIMILAR_TO]->(:Product)
  (:Customer)-[:VIEWED]->(:Product)

  Recommendation query:
  "Customers who bought X also bought Y"
  MATCH (c:Customer)-[:PURCHASED]->(:Product {id: 'X'}),
        (c)-[:PURCHASED]->(rec:Product)
  WHERE rec.id <> 'X'
    # ... (condensed)
  RETURN path
```

### Step 7: Time-Series Databases

#### InfluxDB

```
INFLUXDB CONCEPTS:
- Measurement: like a table (e.g., "cpu_usage")
- Tags: indexed metadata (e.g., host, region) -- strings only
- Fields: actual values (e.g., value, count) -- not indexed
- Timestamp: every point has a time
- Bucket: container for data with a retention policy
- Organization: top-level namespace

TAG vs FIELD:
- Tags: low cardinality, used in WHERE/GROUP BY, indexed
- Fields: high cardinality, actual measurements, not indexed
  BAD TAG:  user_id (millions of values -> high cardinality -> OOM)
  GOOD TAG: region, host, status_code, environment
```

```sql
-- InfluxDB (Flux query language)
-- Write data
// Line protocol: measurement,tag=value field=value timestamp
cpu_usage,host=server01,region=us-east value=72.5 1705334400000000000
cpu_usage,host=server02,region=us-west value=45.2 1705334400000000000

// Flux query: Average CPU by host over 5-minute windows
from(bucket: "metrics")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "cpu_usage")
  |> filter(fn: (r) => r.region == "us-east")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> group(columns: ["host"])
  |> yield(name: "mean_cpu")

// Flux query: Detect anomalies (values > 2 standard deviations)
from(bucket: "metrics")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu_usage")
    # ...
  |> aggregateWindow(every: 5m, fn: mean)
  |> to(bucket: "metrics_downsampled", org: "myorg")
```

#### TimescaleDB (already covered in postgres skill -- brief summary)

```
TIMESCALEDB vs INFLUXDB:
+--------------------------------------------------------------+
|  Feature              | TimescaleDB        | InfluxDB          |
+--------------------------------------------------------------+
|  Query language       | SQL (full)         | Flux (custom)     |
|  JOINs                | Yes                | Limited           |
|  Ecosystem            | PostgreSQL (huge)  | InfluxDB-specific |
|  Extensions           | All PG extensions  | N/A               |
|  Compression          | 90%+ native        | Good              |
|  Continuous aggs      | Yes (materialized) | Tasks             |
|  Retention policies   | Yes                | Yes               |
|  Learning curve       | Low (SQL)          | Medium (Flux)     |
|  Best for             | Mixed workloads,   | Pure metrics,     |
|                       | SQL + time-series  | IoT, monitoring   |
+--------------------------------------------------------------+

RECOMMENDATION:
- Use TimescaleDB if: you already use PostgreSQL, need JOINs with time data,
  want SQL compatibility, or have a mixed workload
- Use InfluxDB if: pure metrics/monitoring, very high cardinality time-series,
  or you need the InfluxDB ecosystem (Telegraf, Kapacitor, Grafana integration)
```

### Step 8: Report and Transition

```
+------------------------------------------------------------+
|  NOSQL DESIGN -- <description>                              |
+------------------------------------------------------------+
|  Database selected: <database>                              |
|  Rationale:         <why this database>                     |
+------------------------------------------------------------+
|  Data model:                                                |
|  - Collections/Tables: <count>                              |
|  - Key patterns: <description>                              |
|  - Indexes: <count and types>                               |
|                                                             |
|  Access patterns served:                                    |
|  1. <pattern>: <how served (PK/SK/GSI/query)>              |
|  2. <pattern>: <how served>                                 |
|                                                             |
|  Denormalization:                                           |
|  - <what is duplicated and why>                             |
|                                                             |
|  Consistency model: <strong | eventual | tunable>           |
+------------------------------------------------------------+
```

Commit: `"nosql: <description> -- <database>, <key design decisions>"`

## Key Behaviors

1. **Access patterns first.** In NoSQL, you design the data model around your queries, not around your entities. List every access pattern before drawing a single schema.
2. **Denormalize deliberately.** NoSQL databases trade storage and write amplification for read performance. Duplication is a feature, not a bug. But document every denormalization decision.
3. **Know your partition key.** In DynamoDB and Cassandra, the partition key determines everything: data distribution, query capability, and hot partition risk. Get it right on day one.
4. **Embed vs. reference in MongoDB.** Embed when data is read together and the subdocument is small and bounded. Reference when data is independent, large, or shared across documents.
5. **One table per query in Cassandra.** Cassandra has no JOINs. Each query needs its own table optimized for that exact read pattern, even if it means writing the same data 3-4 times.
6. **Graph databases for relationships.** If your queries are "find connections", "shortest path", or "people who also X", a graph database will be 100-1000x faster than JOINs.
7. **Time-series databases for metrics.** PostgreSQL with TimescaleDB handles most time-series workloads. Use InfluxDB for high-cardinality pure metrics at massive scale.
8. **Start with PostgreSQL.** The default database should be PostgreSQL. Move to NoSQL only when PostgreSQL cannot meet a specific technical requirement.
9. **Bound your partitions.** In DynamoDB, Cassandra, and MongoDB, unbounded collections (growing forever in one partition/document) cause performance degradation. Use time buckets, size limits, or pagination.
10. **Schema validation in MongoDB.** MongoDB is schemaless, not schema-free. Use JSON Schema validation to enforce document structure in production.

## Example Usage

### Designing a MongoDB schema
```
User: /godmode:nosql Design a MongoDB schema for our content management system

NoSQL: Analyzing access patterns...

ACCESS PATTERNS:
1. Get article by slug (read)
2. List articles by category, sorted by date (read)
3. Get article with author details (read)
4. Full-text search across articles (read)
5. Add/update article (write)

DOCUMENT DESIGN:
  articles collection:
  - Embed: author summary (name, avatar) -- read together
  - Embed: categories (small bounded list) -- read together
  - Reference: author full profile -- read independently
```

### DynamoDB single-table design
```
User: /godmode:nosql Design a DynamoDB table for our SaaS multi-tenant app

NoSQL: Mapping access patterns...

ACCESS PATTERNS:
1. Get tenant by ID
2. Get user by ID within tenant
3. List all users for a tenant
4. Get user by email (cross-tenant)
5. List tenant's invoices by date

SINGLE TABLE:
  PK: TENANT#<id>,     SK: TENANT#<id>           (tenant details)
  PK: TENANT#<id>,     SK: USER#<email>           (user in tenant)
  PK: TENANT#<id>,     SK: INVOICE#<date>#<id>    (invoice)

```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive NoSQL design workflow |
| `--mongodb` | MongoDB document modeling and aggregation |
| `--dynamodb` | DynamoDB single-table design with GSI/LSI |
| `--cassandra` | Cassandra partition key and wide-row design |
| `--neo4j` | Neo4j graph modeling and Cypher queries |
| `--timeseries` | Time-series database design (InfluxDB, TimescaleDB) |
| `--compare` | Compare NoSQL databases for a use case |
| `--migrate` | Plan migration from SQL to NoSQL or between NoSQL databases |
| `--model` | Design data model for specified access patterns |
| `--index` | Design indexing strategy for a NoSQL database |
| `--aggregate` | Build MongoDB aggregation pipeline |
| `--graph-query` | Write Cypher queries for Neo4j |

## Auto-Detection

```
IF package.json OR requirements.txt contains "mongoose" OR "mongodb" OR "pymongo":
  DETECT database = "MongoDB"
  SUGGEST "MongoDB driver detected. Activate /godmode:nosql?"

IF package.json OR requirements.txt contains "@aws-sdk/client-dynamodb" OR "boto3":
  IF code references DynamoDB tables:
    DETECT database = "DynamoDB"
    SUGGEST "DynamoDB usage detected. Activate /godmode:nosql?"

IF code imports "cassandra-driver" OR "datastax":
  DETECT database = "Cassandra"
  SUGGEST "Cassandra driver detected. Activate /godmode:nosql?"


## Iterative Data Modeling Protocol

```
WHEN designing a NoSQL data model:

current_pattern = 0
access_patterns = list_all_access_patterns()  # MUST be defined first
total_patterns = len(access_patterns)
served_patterns = []
unserved_patterns = []

WHILE current_pattern < total_patterns:
  pattern = access_patterns[current_pattern]

  1. DETERMINE how to serve this pattern:
     - MongoDB: which collection, index, or aggregation?
     - DynamoDB: which PK/SK combo or GSI?
     - Cassandra: which table (one table per query)?
     - Neo4j: which traversal pattern?

  2. DESIGN key structure / document shape / graph model
  3. VALIDATE:
    # ...
  FOR each unserved pattern: propose solution (GSI, denormalization, separate table)
  GENERATE complete schema with all indexes and access pattern mapping
```

## Multi-Agent Dispatch

```
WHEN designing a complex NoSQL system with multiple database types:

DISPATCH parallel agents in worktrees:

  Agent 1 (primary-data-model):
    - Design primary data store (MongoDB/DynamoDB/Cassandra)
    - Map all CRUD access patterns to key design
    - Design indexes (compound, partial, TTL)
    - Output: data model documentation + index definitions

## HARD RULES

```
1. NEVER design a NoSQL schema before listing ALL access patterns.
   In NoSQL, you model for queries, not for entities.

2. NEVER use a relational (normalized) design in DynamoDB or Cassandra.
   Denormalize for reads. Duplication is a feature, not a bug.

3. NEVER use low-cardinality partition keys (e.g., "status" with 3 values).
   This creates hot partitions that throttle your entire table.

4. NEVER create unbounded partitions. Cassandra partitions > 100MB
   and DynamoDB items collections > 10GB cause performance degradation.
   Use time bucketing or size limits.

5. MongoDB documents MUST have schema validation in production.
   "Schemaless" does not mean "no schema."

6. In Cassandra, ONE TABLE PER QUERY. No JOINs, no subqueries.
    # ... (condensed)
   (schema flexibility, data model fit, horizontal scale).
```

## Output Format

After every NoSQL operation (database selection, schema design, query optimization, migration), emit a structured result box:

```
┌─ NOSQL RESULT ──────────────────────────────────────┐
│ Database : DynamoDB                                  │
│ Operation : single-table design for e-commerce       │
│ Entities : User, Order, Product, Review              │
│ Partition Key : PK (composite: ENTITY#ID)            │
│ Sort Key : SK (composite: ENTITY#TIMESTAMP)          │
│ GSIs : GSI1 (inverted), GSI2 (by-status)             │
│ Access Patterns : 12 identified, 12 covered          │
│ Hot Partition Risk : LOW (high-cardinality PK)       │

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
timestamp	database	operation	entity_count	access_patterns_covered	access_patterns_total	partition_strategy	hot_partition_risk	verdict
2026-03-20T14:30:00Z	DynamoDB	single-table-design	4	12	12	composite-PK	LOW	READY
2026-03-20T14:35:00Z	MongoDB	schema-validation	3	8	8	sharded-by-tenant	LOW	READY
2026-03-20T14:40:00Z	Cassandra	table-per-query	6	15	18	time-bucketed	MEDIUM	NEEDS_TUNING
```

## Success Criteria

**READY** (all must be true):
- Database selection justified against PostgreSQL baseline (specific technical reason documented)
- Every access pattern has a corresponding table/index/GSI design
- Zero hot partition risk for the expected data distribution
- Schema validation enabled (MongoDB: JSON Schema validator; DynamoDB: attribute constraints in application layer)
- Partition sizes within limits (Cassandra < 100MB, DynamoDB item collections < 10GB)
- Denormalization strategy documented for every duplicated field (source of truth + sync mechanism)
- Connection pooling configured with bounded min/max
- Read/write consistency level explicitly chosen and documented (not using defaults blindly)

**NEEDS_TUNING** (any one true):
- 1-2 access patterns not covered by existing indexes/GSIs (requires scan or filter)

## Error Recovery

1. **Hot partition detected (single partition > 30% of throughput)**
2. **Access pattern not covered (full table scan required)**
3. **Data inconsistency from denormalization (stale duplicated data)**
4. **Migration between NoSQL databases (or from SQL to NoSQL)**

## NoSQL Schema Design Audit Loop

```
NOSQL AUDIT LOOP:
max_iterations = 15

WHILE NOT all_patterns_covered AND iteration < max_iterations:
  Phase 1 — Access Pattern Coverage:
    FOR each access pattern: verify it can be served without scan
    MongoDB: check index covers query. DynamoDB: PK/SK or GSI. Cassandra: table exists.
    Fix uncovered patterns: add GSI, index, or denormalized table.

  Phase 2 — Partition Key Optimization (DynamoDB/Cassandra):
    Check for hot partitions (>30% of traffic on one partition) → add write sharding
    Check partition sizes (DynamoDB <10GB, Cassandra <100MB) → add time bucketing
    Check PK cardinality (<100 on high-volume tables) → use composite key

  Phase 3 — Document Validation (MongoDB):
    Add JSON Schema validators to collections without them
    Extract unbounded arrays to separate collections
    Split documents >1MB into references

    # ...
│ Simple lookup latency p99            │ < 10ms       │ 10-50ms      │ > 50ms       │
└──────────────────────────────────────┴──────────────┴──────────────┴──────────────┘
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

DO NOT STOP just because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (that can be a follow-up pass)
```


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run NoSQL tasks sequentially: primary data model, then secondary data model, then graph model (if needed).
- Use branch isolation per task: `git checkout -b godmode-nosql-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
```
