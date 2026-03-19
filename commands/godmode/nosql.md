# /godmode:nosql

NoSQL database design. MongoDB document modeling and aggregation pipeline, DynamoDB single-table design with GSI/LSI strategies, Cassandra partition key design, Neo4j graph modeling and Cypher queries, time-series databases, and database selection guidance.

## Usage

```
/godmode:nosql                                   # Interactive NoSQL design workflow
/godmode:nosql --mongodb                         # MongoDB document modeling and aggregation
/godmode:nosql --dynamodb                        # DynamoDB single-table design with GSI/LSI
/godmode:nosql --cassandra                       # Cassandra partition key and wide-row design
/godmode:nosql --neo4j                           # Neo4j graph modeling and Cypher queries
/godmode:nosql --timeseries                      # Time-series database design (InfluxDB, TimescaleDB)
/godmode:nosql --compare                         # Compare NoSQL databases for a use case
/godmode:nosql --migrate                         # Plan migration from SQL to NoSQL or between NoSQL
/godmode:nosql --model                           # Design data model for specified access patterns
/godmode:nosql --index                           # Design indexing strategy for a NoSQL database
/godmode:nosql --aggregate                       # Build MongoDB aggregation pipeline
/godmode:nosql --graph-query                     # Write Cypher queries for Neo4j
```

## What It Does

1. Assesses requirements: data model, access patterns, volume, consistency, latency
2. Selects the right NoSQL database using decision matrix and trade-off analysis
3. Designs MongoDB schemas: embedding vs. referencing, bucket pattern, computed pattern, polymorphic pattern
4. Builds DynamoDB single-table designs: composite PK/SK, GSI overloading, sparse indexes
5. Models Cassandra tables: partition key selection, clustering columns, time bucketing, write-optimized multi-table design
6. Creates Neo4j graph models: node/relationship design, Cypher queries for traversals, recommendations, fraud detection
7. Configures time-series databases: InfluxDB (Flux queries, downsampling) and TimescaleDB (continuous aggregates)

## Output
- Database selection rationale with comparison matrix
- Data model design with access pattern mapping
- Index strategy with trade-off analysis
- Query examples for every access pattern
- Commit: `"nosql: <description> -- <database>, <key design decisions>"`

## Next Step
After NoSQL design: `/godmode:query` for query optimization, `/godmode:migrate` for data migration, or `/godmode:postgres` if PostgreSQL turns out to be the better fit.

## Examples

```
/godmode:nosql --compare                         # MongoDB vs DynamoDB for our use case
/godmode:nosql --dynamodb                        # Single-table design for multi-tenant SaaS
/godmode:nosql --mongodb --aggregate             # Build aggregation pipeline for analytics
/godmode:nosql --neo4j                           # Graph model for recommendation engine
/godmode:nosql --cassandra                       # IoT sensor data model with time bucketing
```
