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
Scale direction:   <Vertical | Horizontal>
Relationships:     <None | Simple | Complex | Graph-like>
Schema flexibility: <Fixed | Evolving | Schemaless>
Query complexity:  <Simple lookups | Aggregations | Graph traversals | Full-text>
Cloud preference:  <AWS | GCP | Azure | Self-managed>
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
|  Key-value lookups, known      | DynamoDB       | Ad-hoc       |
|  access patterns, serverless   |                | queries      |
+--------------------------------------------------------------+
|  High-write time-series,       | Cassandra      | Complex      |
|  IoT sensor data, wide rows    |                | joins        |
+--------------------------------------------------------------+
|  Relationships ARE the data,   | Neo4j          | Simple       |
|  traversals, recommendations   |                | CRUD         |
+--------------------------------------------------------------+
|  Metrics, events, monitoring   | InfluxDB /     | Relational   |
|  with time-based queries       | TimescaleDB    | queries      |
+--------------------------------------------------------------+
|  Simple cache, session store   | Redis          | Complex      |
|  counters, queues              |                | queries      |
+--------------------------------------------------------------+
|  Full-text search, logging     | Elasticsearch  | Transactional|
|  analytics, faceted search     |                | writes       |
+--------------------------------------------------------------+

DECISION TREE:
1. Is the primary access pattern key-value lookups?
   -> YES: DynamoDB (AWS) or Redis (if fits in memory)
   -> NO: continue

2. Are relationships between entities the core of the data model?
   -> YES: Neo4j or Amazon Neptune
   -> NO: continue

3. Is the data primarily time-series (metrics, events, IoT)?
   -> YES: TimescaleDB (SQL + time-series) or InfluxDB (purpose-built)
   -> NO: continue

4. Do you need flexible schemas with rich query capabilities?
   -> YES: MongoDB
   -> NO: continue

5. Is it massive write throughput with simple lookups?
   -> YES: Cassandra or ScyllaDB
   -> NO: continue

6. Is it search and analytics over unstructured text?
   -> YES: Elasticsearch / OpenSearch
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
}

// PATTERN 2: Referenced Document (1:many, read independently)
// Users with orders -- orders are queried independently
// users collection
{
  _id: ObjectId("user123"),
  name: "Alice Johnson",
  email: "alice@example.com",
  plan: "pro"
}
// orders collection
{
  _id: ObjectId("order456"),
  user_id: ObjectId("user123"),  // reference
  total: 109.97,
  status: "shipped"
}

// PATTERN 3: Bucket Pattern (time-series, IoT, metrics)
// Group related measurements into buckets
{
  _id: ObjectId("..."),
  sensor_id: "temp-sensor-42",
  bucket_start: ISODate("2025-01-15T10:00:00Z"),
  bucket_end: ISODate("2025-01-15T11:00:00Z"),
  measurements: [
    { ts: ISODate("2025-01-15T10:00:00Z"), value: 22.5 },
    { ts: ISODate("2025-01-15T10:01:00Z"), value: 22.6 },
    // ... up to 60 measurements per hour
  ],
  count: 60,
  sum: 1350.0,
  min: 22.1,
  max: 23.4,
  avg: 22.5
}
// Benefits: fewer documents, pre-computed aggregates, efficient time queries

// PATTERN 4: Computed Pattern (pre-aggregate for reads)
// Product with computed review stats
{
  _id: ObjectId("prod789"),
  name: "Wireless Headphones",
  price: 79.99,
  review_stats: {
    count: 342,
    avg_rating: 4.3,
    rating_distribution: { 1: 12, 2: 18, 3: 45, 4: 120, 5: 147 }
  }
}
// Update review_stats atomically on new review:
// db.products.updateOne({ _id: "prod789" }, {
//   $inc: { "review_stats.count": 1, "review_stats.rating_distribution.5": 1 },
//   $set: { "review_stats.avg_rating": <new_avg> }
// })

// PATTERN 5: Polymorphic Pattern (different shapes in same collection)
// Notifications of different types
{
  _id: ObjectId("..."),
  type: "email",
  recipient: "alice@example.com",
  subject: "Welcome!",
  body: "...",
  sent_at: ISODate("...")
}
{
  _id: ObjectId("..."),
  type: "sms",
  phone: "+1234567890",
  message: "Your code is 123456",
  sent_at: ISODate("...")
}
{
  _id: ObjectId("..."),
  type: "push",
  device_token: "abc123...",
  title: "New message",
  payload: { ... },
  sent_at: ISODate("...")
}
// Single collection, single index on { type: 1, sent_at: -1 }
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
      localField: "items.product_id",
      foreignField: "_id",
      as: "product"
  }},
  { $unwind: "$product" },

  // Stage 4: Group by region and category
  { $group: {
      _id: {
        region: "$shipping_address.region",
        category: "$product.category"
      },
      total_revenue: { $sum: { $multiply: ["$items.qty", "$items.price"] } },
      order_count: { $sum: 1 },
      avg_order_value: { $avg: { $multiply: ["$items.qty", "$items.price"] } },
      unique_customers: { $addToSet: "$customer_id" }
  }},

  // Stage 5: Add computed fields
  { $addFields: {
      unique_customer_count: { $size: "$unique_customers" }
  }},

  // Stage 6: Sort by revenue
  { $sort: { total_revenue: -1 } },

  // Stage 7: Project final shape
  { $project: {
      _id: 0,
      region: "$_id.region",
      category: "$_id.category",
      total_revenue: { $round: ["$total_revenue", 2] },
      order_count: 1,
      avg_order_value: { $round: ["$avg_order_value", 2] },
      unique_customers: "$unique_customer_count"
  }}
])

// Aggregation pipeline optimization tips:
// 1. $match early: filter before $lookup and $unwind
// 2. $project early: drop unneeded fields to reduce pipeline memory
// 3. Use indexes: first $match/$sort can use indexes
// 4. allowDiskUse: true for large aggregations (> 100MB pipeline memory)
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
// Indexes all fields within payload -- use cautiously (storage overhead)

// TTL index (auto-expire documents)
db.sessions.createIndex({ created_at: 1 }, { expireAfterSeconds: 86400 })

// Index intersection: MongoDB can combine 2 single-field indexes
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
|  CUSTOMER#cust-123   | ORDER#2025-01-15#ord1 | total, status,  |
|                      |                       | created_at      |
+--------------------------------------------------------------+
|  CUSTOMER#cust-123   | ORDER#2025-01-10#ord2 | total, status,  |
|                      |                       | created_at      |
+--------------------------------------------------------------+
|  ORDER#ord-001       | ORDER#ord-001         | customer_id,    |
|                      |                       | total, status   |
+--------------------------------------------------------------+
|  ORDER#ord-001       | ITEM#prod-abc#1       | product_name,   |
|                      |                       | qty, price      |
+--------------------------------------------------------------+
|  ORDER#ord-001       | ITEM#prod-xyz#2       | product_name,   |
|                      |                       | qty, price      |
+--------------------------------------------------------------+
|  PRODUCT#prod-abc    | PRODUCT#prod-abc      | name, price,    |
|                      |                       | category        |
+--------------------------------------------------------------+

QUERIES:
1. Get customer:     PK = "CUSTOMER#cust-123", SK = "CUSTOMER#cust-123"
2. Get order:        PK = "ORDER#ord-001",     SK = "ORDER#ord-001"
3. Customer orders:  PK = "CUSTOMER#cust-123", SK begins_with "ORDER#"
4. Order items:      PK = "ORDER#ord-001",     SK begins_with "ITEM#"
5. Get product:      PK = "PRODUCT#prod-abc",  SK = "PRODUCT#prod-abc"
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
  Query: All orders containing a specific product

GSI2 -- "Status Index" (order status queries)
  GSI2-PK: status
  GSI2-SK: created_at
  Query: All orders by status, sorted by date

SPARSE INDEX PATTERN:
  Only items with the GSI PK attribute appear in the GSI
  Useful for: "Get all featured products" (only featured ones have the attribute)
  GSI-PK: featured_status   (only set on featured products)
  GSI-SK: created_at
  Result: Small, efficient index of only featured items

OVERLOADED GSI PATTERN:
  Same GSI serves multiple access patterns:
  GSI1-PK: "gsi1pk" (generic attribute name)
  GSI1-SK: "gsi1sk" (generic attribute name)

  For customer entity: gsi1pk = email,           gsi1sk = "CUSTOMER"
  For order entity:    gsi1pk = product_id,       gsi1sk = order_date
  For payment entity:  gsi1pk = payment_method,   gsi1sk = amount

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
  RCU (Read Capacity Unit)  = 1 strongly consistent read/sec for items up to 4KB
                             = 2 eventually consistent reads/sec for items up to 4KB

HOT PARTITION PREVENTION:
  BAD PK:  status (only 3-4 values, all traffic on few partitions)
  GOOD PK: customer_id (high cardinality, even distribution)
  WORKAROUND: Add random suffix for write-heavy keys
    PK = "COUNTER#page-views#" + random(0, 9)
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

-- Query: latest readings for sensor today
SELECT * FROM sensor_readings
WHERE sensor_id = 'temp-42' AND day = '2025-01-15'
ORDER BY reading_time DESC
LIMIT 100;

-- Query: readings in a time range
SELECT * FROM sensor_readings
WHERE sensor_id = 'temp-42' AND day = '2025-01-15'
  AND reading_time >= '2025-01-15T10:00:00Z'
  AND reading_time <= '2025-01-15T12:00:00Z';

-- Anti-pattern: unbounded partition (no day bucket)
-- BAD: PRIMARY KEY (sensor_id, reading_time)
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
    PRIMARY KEY (status, order_date, order_id)
) WITH CLUSTERING ORDER BY (order_date DESC, order_id ASC);

-- Table 3: Order details by ID
CREATE TABLE orders_by_id (
    order_id      UUID,
    user_id       UUID,
    order_date    TIMESTAMP,
    total         DECIMAL,
    status        TEXT,
    items         LIST<FROZEN<order_item>>,  -- UDT
    PRIMARY KEY (order_id)
);

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
|  1-hop relationship           | JOIN (fast)   | Traverse      |
|  2-hop relationship           | 2 JOINs       | 2 traversals  |
|  Variable depth (1-N hops)    | N JOINs or    | Single query  |
|                               | recursive CTE | (fast!)       |
|  Shortest path                | Very hard     | Built-in      |
|  Pattern matching             | Complex SQL   | Native        |
|  Aggregation over all data    | Fast (scan)   | Slower        |
+--------------------------------------------------------------+

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

// Variable-length paths (1-3 hops)
MATCH (alice:Person {name: 'Alice'})-[:FOLLOWS*1..3]->(connection)
RETURN DISTINCT connection.name, length(shortestPath((alice)-[:FOLLOWS*]->(connection))) AS distance

// Shortest path
MATCH path = shortestPath(
  (alice:Person {name: 'Alice'})-[:FOLLOWS*..10]-(bob:Person {name: 'Bob'})
)
RETURN path, length(path) AS distance

// Recommendation: People who follow the same people Alice follows
MATCH (alice:Person {name: 'Alice'})-[:FOLLOWS]->(common)<-[:FOLLOWS]-(recommendation)
WHERE recommendation <> alice
  AND NOT (alice)-[:FOLLOWS]->(recommendation)
RETURN recommendation.name, COUNT(common) AS shared_connections
ORDER BY shared_connections DESC
LIMIT 10

// Aggregation: Company with most employees
MATCH (p:Person)-[:WORKS_AT]->(c:Company)
RETURN c.name, COUNT(p) AS employee_count
ORDER BY employee_count DESC

// Subgraph pattern matching: Find triangles (mutual follows)
MATCH (a:Person)-[:FOLLOWS]->(b:Person)-[:FOLLOWS]->(c:Person)-[:FOLLOWS]->(a)
RETURN a.name, b.name, c.name

// Update: Add property to relationship
MATCH (alice:Person {name: 'Alice'})-[r:FOLLOWS]->(bob:Person {name: 'Bob'})
SET r.since = 2023

// Delete: Remove relationship
MATCH (alice:Person {name: 'Alice'})-[r:FOLLOWS]->(bob:Person {name: 'Bob'})
DELETE r

// Indexes for performance
CREATE INDEX person_name FOR (p:Person) ON (p.name)
CREATE INDEX company_name FOR (c:Company) ON (c.name)
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
  RETURN rec, COUNT(c) AS score
  ORDER BY score DESC LIMIT 10

PATTERN 3: Knowledge Graph
  (:Entity)-[:RELATES_TO {type: '...'}]->(:Entity)
  (:Entity)-[:HAS_PROPERTY]->(:Property)
  (:Entity)-[:INSTANCE_OF]->(:Class)
  (:Class)-[:SUBCLASS_OF]->(:Class)

PATTERN 4: Fraud Detection
  (:Account)-[:TRANSFERRED {amount, timestamp}]->(:Account)
  (:Person)-[:OWNS]->(:Account)
  (:Person)-[:SHARES_ADDRESS_WITH]->(:Person)
  (:Person)-[:SHARES_DEVICE_WITH]->(:Person)

  Fraud query: Find accounts connected through suspicious patterns
  MATCH (a:Account)-[:TRANSFERRED*2..5]->(b:Account)
  WHERE a <> b AND ALL(r IN relationships(path) WHERE r.amount > 10000)
  RETURN a, b, length(path)

PATTERN 5: Dependency Graph
  (:Package)-[:DEPENDS_ON]->(:Package)
  (:Service)-[:CALLS]->(:Service)
  (:Task)-[:BLOCKS]->(:Task)

  Circular dependency detection:
  MATCH path = (p:Package)-[:DEPENDS_ON*]->(p)
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
  |> aggregateWindow(every: 1m, fn: mean)
  |> movingAverage(n: 10)
  |> map(fn: (r) => ({r with _value: r._value * 1.0}))

// Downsampling task (continuous query equivalent)
option task = {name: "downsample_cpu", every: 1h}
from(bucket: "metrics")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "cpu_usage")
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
  - Text index: title + body for full-text search

  Indexes:
  1. { slug: 1 } -- unique
  2. { "categories.slug": 1, published_at: -1 } -- category listing
  3. { author_id: 1, published_at: -1 } -- author's articles
  4. text: { title: "text", body: "text" } -- full-text search
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

  GSI1-PK: email,      GSI1-SK: TENANT#<id>       (user by email)

  5 access patterns served with 1 table + 1 GSI
```

### Choosing between databases
```
User: /godmode:nosql Should we use MongoDB or DynamoDB for our app?

NoSQL: Comparing for your use case...

YOUR REQUIREMENTS:
  - Flexible schema (evolving rapidly)
  - Complex queries with aggregation
  - Full-text search
  - 50K reads/sec, 5K writes/sec
  - AWS infrastructure

VERDICT: MongoDB Atlas (on AWS)
REASONS:
  1. Aggregation pipeline covers your complex query needs
  2. Built-in full-text search (Atlas Search)
  3. Flexible schema with validation
  4. DynamoDB's query limitations would require too many GSIs

  DynamoDB would be better if:
  - Access patterns were simpler (key-value lookups)
  - You needed serverless scaling
  - Latency < 5ms was critical
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

IF code imports "neo4j-driver" OR "neo4j":
  DETECT database = "Neo4j"
  SUGGEST "Neo4j graph database detected. Activate /godmode:nosql?"

IF code imports "influxdb" OR "influxdb-client":
  DETECT database = "InfluxDB"
  SUGGEST "InfluxDB time-series database detected. Activate /godmode:nosql?"

IF docker-compose.yml contains "mongo:" OR "dynamodb-local" OR "cassandra:" OR "neo4j:":
  db_name = detect_nosql_from_compose()
  SUGGEST "{db_name} detected in Docker Compose. Activate /godmode:nosql?"

IF directory contains *.cql files (Cassandra) OR *.cypher files (Neo4j):
  SUGGEST "NoSQL query files detected. Activate /godmode:nosql?"
```

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
     - Partition size bounded (DynamoDB < 10GB, Cassandra < 100MB)
     - No unbounded arrays in documents (MongoDB)
     - High-cardinality partition keys
     - No shared data that requires distributed transactions

  IF pattern cannot be served efficiently:
    unserved_patterns.append(pattern)
    SUGGEST "Pattern '{pattern}' may need a GSI, materialized view, or separate table"
  ELSE:
    served_patterns.append(pattern)

  current_pattern += 1
  REPORT "{current_pattern}/{total_patterns} access patterns addressed"

FINAL:
  REPORT "Served: {len(served_patterns)}, Unserved: {len(unserved_patterns)}"
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

  Agent 2 (secondary-data-model):
    - Design secondary store if needed (Redis cache, Elasticsearch search)
    - Design cache invalidation strategy
    - Design search index mapping
    - Output: cache strategy + search index config

  Agent 3 (graph-model):
    - Design graph model if relationships are core (Neo4j)
    - Write Cypher queries for traversal patterns
    - Design graph indexes
    - Output: graph schema + query library

  Agent 4 (migration-and-testing):
    - Design data migration scripts (seed data, backfill)
    - Write data validation queries
    - Design capacity planning estimates
    - Output: migration scripts + validation suite

MERGE:
  - Verify all access patterns are served by at least one data store
  - Verify denormalization is consistent across stores
  - Verify sync strategy between primary and secondary stores
  - Run validation queries against test data
```

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
   Write amplification is the accepted tradeoff.

7. NEVER choose NoSQL because "it scales." PostgreSQL handles
   terabytes and millions of rows. Choose NoSQL for data model fit.

8. ALWAYS start with PostgreSQL as the default. Move to NoSQL only
   when PostgreSQL cannot meet a specific technical requirement
   (schema flexibility, data model fit, horizontal scale).
```

## Anti-Patterns

- **Do NOT choose NoSQL because "it scales."** PostgreSQL scales to terabytes and millions of rows. Choose NoSQL for data model fit, not scale marketing.
- **Do NOT design NoSQL schemas like relational schemas.** Normalized tables with references and JOINs is an anti-pattern in DynamoDB and Cassandra. Denormalize for reads.
- **Do NOT use MongoDB as a "schemaless" dumping ground.** Enforce schema validation. "Schemaless" does not mean "no schema" -- it means the schema lives in your application code, which is worse.
- **Do NOT create DynamoDB tables per entity type.** Single-table design puts all entities in one table with composite keys. Multiple tables means you cannot query across entity types.
- **Do NOT use low-cardinality partition keys.** A DynamoDB partition key with 3 values (e.g., "active", "pending", "closed") creates hot partitions. Use high-cardinality keys.
- **Do NOT create unbounded partitions in Cassandra.** A partition that grows forever (sensor data without time bucketing) will eventually exceed node memory and cause read timeouts.
- **Do NOT use Neo4j for simple CRUD.** If your queries are "get user by ID" and "list users by name", a relational database is simpler and faster. Use graphs when relationships drive the queries.
- **Do NOT use high-cardinality tags in InfluxDB.** Tags like user_id with millions of values create enormous index memory usage. Use fields for high-cardinality values.
- **Do NOT ignore consistency trade-offs.** MongoDB is eventually consistent by default. DynamoDB GSIs are eventually consistent. Cassandra consistency is tunable. Understand what "eventually" means for your application.
- **Do NOT skip the "which database" question.** The most expensive NoSQL mistake is choosing the wrong database. Spend time on selection (Step 2) before spending weeks on modeling.
