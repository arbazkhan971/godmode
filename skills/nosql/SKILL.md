---
name: nosql
description: NoSQL database design (Mongo, DynamoDB, etc).
---

## Activate When
- `/godmode:nosql`, "mongodb schema", "dynamodb design"
- "cassandra model", "neo4j graph", "time-series"
- "which database?", "nosql vs sql?"

## Workflow

### 1. Requirements Assessment
```
Data model: Document|Key-Value|Wide-Column|Graph|TimeSeries
Access patterns: <list read/write patterns + frequency>
Scale: <expected documents, queries/sec>
Consistency: eventual|strong|tunable
```
```bash
# Check for NoSQL drivers
cat package.json 2>/dev/null | grep -iE "mongo|dynamo|neo4j"
pip list 2>/dev/null | grep -iE "pymongo|boto3|cassandra"
```

### 2. Database Selection
```
IF hierarchical/nested data + flexible schema: MongoDB
IF key-based access, extreme scale: DynamoDB
IF time-series writes, wide rows: Cassandra
IF relationship traversal: Neo4j
IF metrics/IoT at scale: InfluxDB/TimescaleDB
DEFAULT: Start with PostgreSQL, move to NoSQL when
  a specific technical requirement demands it.
```
IF access patterns unknown: do NOT choose NoSQL yet.
IF < 1M records and relational: PostgreSQL is better.

### 3. MongoDB Document Modeling
```
Embed when: read together, 1:1 or 1:few, bounded size
Reference when: independent, large, shared across docs
IF subdocument > 16MB: must reference (Mongo limit)
IF array grows unbounded: use bucketing pattern
```
```javascript
// Compound index (covers multiple query patterns)
db.orders.createIndex({ customer_id: 1, created_at: -1 })
// Partial index (smaller, faster)
db.orders.createIndex(
  { status: 1 }, { partialFilterExpression: { active: true } }
)
```

### 4. DynamoDB Single-Table Design
```
Design for access patterns FIRST, entity model second.
PK: high cardinality, even distribution
SK: enables range queries within partition
GSI: different PK+SK for alternate access patterns
```
IF partition > 10GB: add write sharding.
IF PK cardinality < 100 on high-volume: use composite.
IF hot partition > 30% traffic: redistribute.

### 5. Cassandra Partition Design
```
One table per query (no JOINs).
Target: < 100MB per partition, < 100K rows.
Use time-bucketed keys for time-series data.
```

### 6. Neo4j Graph Modeling
```
Nodes = entities (nouns), Relationships = verbs
IF "find connections" or "shortest path": graph DB
  runs 100-1000x faster than SQL JOINs.
```

### 7. Time-Series (InfluxDB/TimescaleDB)
```
IF already using PostgreSQL: TimescaleDB extension
IF high-cardinality pure metrics: InfluxDB
Tags = indexed metadata (strings), Fields = values
```

## Hard Rules
1. NEVER design schema before listing ALL access patterns.
2. ALWAYS set schema validation in MongoDB production.
3. NEVER allow unbounded document/partition growth.
4. ALWAYS add indexes matching query patterns.
5. Partition size: DynamoDB < 10GB, Cassandra < 100MB.

## TSV Logging
Append `.godmode/nosql-results.tsv`:
```
timestamp	database	action	collection	index_count	status
```

## Keep/Discard
```
KEEP if: tests pass AND quality improved AND no regression.
DISCARD if: tests fail OR performance regressed.
```

## Stop Conditions
```
STOP when FIRST of:
  - All access patterns covered without scans
  - Partition sizes within limits
  - User requests stop
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Query degrades with growth | Check explain(), add indexes |
| Data inconsistency | Check write concern, use majority |
| Connection exhaustion | Increase pool, check leaks |
