---
name: scale
description: |
  Scalability engineering skill. Activates when user needs horizontal vs vertical scaling decisions, auto-scaling configuration, database read replicas and write splitting, connection pooling at scale, rate limiting and backpressure, or capacity planning methodology. Triggers on: /godmode:scale, "scaling", "auto-scale", "read replica", "connection pool", "rate limiting", "backpressure", "capacity planning", "horizontal scaling", "vertical scaling", or when the orchestrator detects scalability work.
---

# Scale -- Scalability Engineering

## When to Activate
- User invokes `/godmode:scale`
- User says "scaling", "auto-scale", "horizontal scaling", "vertical scaling"
- User says "read replica", "write splitting", "connection pooling"
- User says "rate limiting", "backpressure", "capacity planning"
- User says "too slow", "can't handle load", "need more throughput"
- When load testing reveals performance bottlenecks
- When `/godmode:loadtest` shows the system cannot handle target load
- When `/godmode:observe` alerts on resource saturation

## Workflow

### Step 1: Scalability Assessment
Understand the current system and scaling requirements:

```
SCALABILITY CONTEXT:
Project: <name and purpose>
Current Architecture: Monolith | Microservices | Serverless | Hybrid
Current Scale: <requests/sec, concurrent users, data volume>
Target Scale: <target requests/sec, users, data volume>
Growth Rate: <monthly/quarterly growth percentage>
Bottleneck: <CPU | Memory | I/O | Network | Database | External API>
Budget Constraint: <monthly infrastructure budget>
SLA: <latency p50, p99, availability target>
Database: <type, current size, read/write ratio>
Current Infrastructure: <cloud provider, instance types, region>
Peak vs Baseline: <peak traffic ratio to baseline>
```

If the user has not provided context, ask: "What is your current request volume, and what is the bottleneck -- is the system CPU-bound, memory-bound, I/O-bound, or database-bound? This determines the scaling strategy."

### Step 2: Horizontal vs Vertical Scaling Decision
Choose the right scaling direction:

```
SCALING DIRECTION ANALYSIS:
+--------------------------------------------------------------+
|  Factor              | Vertical (Scale Up) | Horizontal (Out)  |
+--------------------------------------------------------------+
|  Current utilization | CPU: <%>  Mem: <%>  | Instances: <N>    |
|  Cost per unit       | $<cost/larger inst> | $<cost/add inst>  |
|  Complexity          | Low (bigger box)    | Higher (distribute)|
|  Max ceiling         | <largest instance>  | Unlimited (theory) |
|  Downtime required   | Yes (resize)        | No (add nodes)    |
|  State management    | N/A (single node)   | Requires stateless |
|  Database fit        | Good for writes     | Good for reads    |
+--------------------------------------------------------------+

DECISION FRAMEWORK:
Scale UP when:
- Single-threaded workload (cannot parallelize)
- Database write bottleneck (single-writer constraint)
- Quick fix needed (resize takes minutes vs days of re-architecture)
- Not yet at instance type ceiling
- Cost of re-architecture exceeds cost of larger instance

Scale OUT when:
- Already at instance ceiling
- Stateless application tier
- Read-heavy workload (add read replicas)
- Need fault tolerance (multiple instances survive failures)
- Traffic has high peak-to-baseline ratio (auto-scale)
- Cost-effective at scale (many small > few large)

SCALING DIRECTION: <Vertical | Horizontal | Both> -- <justification>
```

### Step 3: Auto-Scaling Configuration
Design auto-scaling policies for dynamic load:

```
AUTO-SCALING DESIGN:
+--------------------------------------------------------------+
|  Tier               | Min | Max | Target Metric    | Target   |
+--------------------------------------------------------------+
|  Application        | <N> | <N> | CPU utilization   | 70%     |
|  Workers            | <N> | <N> | Queue depth       | <N>     |
|  Cache              | <N> | <N> | Memory usage      | 75%     |
|  Database replicas  | <N> | <N> | Connection count  | 80%     |
+--------------------------------------------------------------+

SCALING POLICIES:
+--------------------------------------------------------------+
|  Policy             | Trigger              | Action            |
+--------------------------------------------------------------+
|  Scale out          | CPU > 70% for 3 min  | +2 instances      |
|  Scale out (fast)   | CPU > 90% for 1 min  | +4 instances      |
|  Scale in           | CPU < 30% for 10 min | -1 instance       |
|  Scheduled scale    | Monday 8am           | Min = <N>         |
|  Scheduled scale    | Friday 6pm           | Min = <base>      |
+--------------------------------------------------------------+

SCALING TIMING:
  Scale-out speed: <time to launch + warm up new instance>
  Scale-in cooldown: <minimum time between scale-in events>
  Warm-up period: <time before new instance receives full traffic>
  Pre-warming: <scheduled scaling for known traffic patterns>
```

#### AWS Auto Scaling Group
```yaml
# Launch Template
Resources:
  LaunchTemplate:
    Type: AWS::EC2::LaunchTemplate
    Properties:
      LaunchTemplateData:
        InstanceType: !Ref InstanceType
        ImageId: !Ref AMI
        UserData:
          Fn::Base64: !Sub |
            #!/bin/bash
            # Bootstrap and warm-up script
            /opt/app/warm-cache.sh
            /opt/app/start-service.sh

  AutoScalingGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      MinSize: !Ref MinInstances
      MaxSize: !Ref MaxInstances
      DesiredCapacity: !Ref DesiredInstances
      LaunchTemplate:
        LaunchTemplateId: !Ref LaunchTemplate
        Version: !GetAtt LaunchTemplate.LatestVersionNumber
      HealthCheckType: ELB
      HealthCheckGracePeriod: 300
      TargetGroupARNs:
        - !Ref TargetGroup
      MetricsCollection:
        - Granularity: "1Minute"

  ScaleOutPolicy:
    Type: AWS::AutoScaling::ScalingPolicy
    Properties:
      AutoScalingGroupName: !Ref AutoScalingGroup
      PolicyType: TargetTrackingScaling
      TargetTrackingConfiguration:
        PredefinedMetricSpecification:
          PredefinedMetricType: ASGAverageCPUUtilization
        TargetValue: 70
        ScaleInCooldown: 300
        ScaleOutCooldown: 60
```

#### Kubernetes Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 3
  maxReplicas: 50
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Pods
          value: 4
          periodSeconds: 60
        - type: Percent
          value: 100
          periodSeconds: 60
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Pods
          value: 1
          periodSeconds: 120
      selectPolicy: Min
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: 1000
```

#### KEDA (Event-Driven Autoscaling)
```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: worker-scaler
spec:
  scaleTargetRef:
    name: worker-deployment
  minReplicaCount: 1
  maxReplicaCount: 100
  pollingInterval: 15
  cooldownPeriod: 300
  triggers:
    - type: rabbitmq
      metadata:
        queueName: tasks
        queueLength: "10"   # Scale when > 10 messages per worker
    - type: prometheus
      metadata:
        serverAddress: http://prometheus:9090
        metricName: http_requests_total
        threshold: "100"
        query: sum(rate(http_requests_total[2m]))
```

### Step 4: Database Read Replicas and Write Splitting
Scale the database tier:

```
DATABASE SCALING STRATEGY:
+--------------------------------------------------------------+
|  Technique          | Scales           | Complexity | When     |
+--------------------------------------------------------------+
|  Vertical scaling   | Everything       | Low        | First    |
|  Read replicas      | Read throughput  | Medium     | Read-heavy|
|  Connection pooling | Connection count | Low-Medium | Always   |
|  Write splitting    | Read + Write     | Medium     | Read-heavy|
|  Sharding           | Everything       | Very High  | Last resort|
|  Caching layer      | Read throughput  | Medium     | Hot data |
+--------------------------------------------------------------+

READ REPLICA ARCHITECTURE:
+-------------------+       +-------------------+
|  Primary (Writer) | ----> |  Replica 1 (Read) |
|                   | ----> |  Replica 2 (Read) |
|                   | ----> |  Replica 3 (Read) |
+-------------------+       +-------------------+
        |                           |
   All writes              All reads (eventual)
   Strong reads            + read-your-writes via
                            session routing

WRITE SPLITTING CONFIGURATION:
Application-level routing:
  Writes -> primary endpoint
  Strong reads -> primary endpoint
  Eventually-consistent reads -> replica endpoint (round-robin)
  Read-after-write -> primary for <N> seconds, then replica

Proxy-level routing (PgBouncer, ProxySQL, Amazon RDS Proxy):
  Route by query type:
    INSERT/UPDATE/DELETE -> primary
    SELECT -> replica (configurable)
  Route by transaction:
    In transaction -> primary
    Outside transaction -> replica

REPLICATION LAG MONITORING:
  Acceptable lag: <threshold, e.g., 100ms for config, 5s for analytics>
  Alert threshold: <when to alert, e.g., lag > 1s>
  Circuit breaker: <when to stop routing to lagging replica>
  Metrics:
    - seconds_behind_master (MySQL)
    - pg_stat_replication.replay_lag (PostgreSQL)
    - ReplicaLag (AWS CloudWatch)
```

#### PostgreSQL Read Replica Setup
```sql
-- Primary configuration (postgresql.conf)
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
synchronous_commit = on  -- or 'remote_apply' for sync replicas

-- Create replication slot (prevents WAL cleanup before replica catches up)
SELECT pg_create_physical_replication_slot('replica_1');

-- Replica configuration (postgresql.conf)
primary_conninfo = 'host=primary port=5432 user=replicator'
primary_slot_name = 'replica_1'
hot_standby = on
hot_standby_feedback = on  -- Prevents vacuum conflicts

-- Monitor replication lag
SELECT
  client_addr,
  state,
  sent_lsn,
  write_lsn,
  flush_lsn,
  replay_lsn,
  (extract(epoch from now()) - extract(epoch from replay_lag))::int as lag_seconds
FROM pg_stat_replication;
```

#### Application-Level Write Splitting (Node.js example)
```javascript
// Connection configuration
const primary = new Pool({
  host: 'primary.db.example.com',
  max: 20,
  idleTimeoutMillis: 30000,
});

const replicaPool = [
  new Pool({ host: 'replica-1.db.example.com', max: 50 }),
  new Pool({ host: 'replica-2.db.example.com', max: 50 }),
];

let replicaIndex = 0;

function getReadPool() {
  const pool = replicaPool[replicaIndex % replicaPool.length];
  replicaIndex++;
  return pool;
}

// Usage
async function getUser(id) {
  return getReadPool().query('SELECT * FROM users WHERE id = $1', [id]);
}

async function updateUser(id, data) {
  return primary.query('UPDATE users SET name = $1 WHERE id = $2', [data.name, id]);
}

// Read-after-write: route to primary for N seconds after write
const recentWrites = new Map(); // userId -> timestamp

async function getUserAfterWrite(userId) {
  const lastWrite = recentWrites.get(userId);
  if (lastWrite && Date.now() - lastWrite < 5000) {
    return primary.query('SELECT * FROM users WHERE id = $1', [userId]);
  }
  return getReadPool().query('SELECT * FROM users WHERE id = $1', [userId]);
}
```

### Step 5: Connection Pooling at Scale
Configure connection pools to maximize throughput:

```
CONNECTION POOLING DESIGN:
+--------------------------------------------------------------+
|  Layer              | Pool Size | Timeout  | Idle Timeout     |
+--------------------------------------------------------------+
|  Application -> DB  | <N>       | <ms>     | <ms>             |
|  Proxy -> DB        | <N>       | <ms>     | <ms>             |
|  App -> Cache       | <N>       | <ms>     | <ms>             |
|  App -> External API| <N>       | <ms>     | <ms>             |
+--------------------------------------------------------------+

POOL SIZE FORMULA:
  Optimal pool size = (core_count * 2) + effective_spindle_count
  (HikariCP recommendation for database connections)

  For async I/O-bound:
  Pool size = requests_per_second * avg_latency_seconds
  Example: 1000 RPS * 0.01s avg latency = 10 connections minimum

  RULE OF THUMB:
  - Start small (10-20 connections)
  - Monitor pool wait time
  - Increase only if wait time > acceptable threshold
  - Too large pools cause: lock contention, memory waste, connection overhead

CONNECTION POOL ARCHITECTURE:
+-------------------+     +-------------------+     +-------------------+
|  App Instance 1   |     |  PgBouncer / RDS  |     |  Database         |
|  Pool: 20 conns   | --> |  Proxy             | --> |  max_connections: |
|  App Instance 2   |     |  Pool: 100 conns  |     |  200              |
|  Pool: 20 conns   | --> |                    |     |                   |
|  App Instance 3   |     |                    |     |                   |
|  Pool: 20 conns   | --> |                    |     |                   |
+-------------------+     +-------------------+     +-------------------+
  60 total app conns        100 backend conns        200 max connections

WHY USE A PROXY:
- 100 app instances * 20 pool = 2000 connections (exceeds DB max)
- Proxy multiplexes: 2000 app connections -> 100 DB connections
- Transaction-level pooling: connection returned between transactions
```

#### PgBouncer Configuration
```ini
; pgbouncer.ini
[databases]
mydb = host=primary.db.example.com port=5432 dbname=mydb

[pgbouncer]
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt

; Pool mode: transaction (best for web apps)
pool_mode = transaction

; Pool size
default_pool_size = 50
min_pool_size = 10
max_client_conn = 2000
max_db_connections = 100

; Timeouts
server_idle_timeout = 600
client_idle_timeout = 0
query_timeout = 30
query_wait_timeout = 120

; Monitoring
stats_period = 60
log_connections = 0
log_disconnections = 0
```

### Step 6: Rate Limiting and Backpressure
Protect the system from overload:

```
RATE LIMITING STRATEGY:
+--------------------------------------------------------------+
|  Layer              | Algorithm       | Limit           | Key  |
+--------------------------------------------------------------+
|  API Gateway        | Token bucket    | 1000 req/min    | API key|
|  Per-user           | Sliding window  | 100 req/min     | User ID|
|  Per-endpoint       | Fixed window    | 50 req/min      | IP+path|
|  Global             | Leaky bucket    | 10000 req/min   | Global |
+--------------------------------------------------------------+

RATE LIMITING ALGORITHMS:
+--------------------------------------------------------------+
|  Algorithm          | Burst Handling | Memory   | Accuracy    |
+--------------------------------------------------------------+
|  Fixed window       | Allows 2x at   | Low      | Low         |
|                     | window boundary|          |              |
|  Sliding window log | No burst       | High     | Exact        |
|  Sliding window     | Minimal burst  | Low      | Approximate  |
|  counter            |                |          |              |
|  Token bucket       | Controlled     | Low      | Good         |
|                     | burst (bucket  |          |              |
|                     | size = burst)  |          |              |
|  Leaky bucket       | No burst       | Low      | Good         |
|                     | (smooths out)  |          |              |
+--------------------------------------------------------------+

RECOMMENDED: Token bucket for most API rate limiting
  - Tokens refill at steady rate (sustained limit)
  - Bucket size allows controlled burst (burst limit)
  - Example: 100 tokens/sec refill, bucket size 200
    -> Sustained: 100 req/sec, Burst: 200 req immediate
```

#### Redis-based Token Bucket
```lua
-- Redis Lua script for atomic token bucket
-- KEYS[1] = rate limit key
-- ARGV[1] = bucket capacity
-- ARGV[2] = refill rate (tokens per second)
-- ARGV[3] = current timestamp (microseconds)
-- ARGV[4] = tokens requested

local key = KEYS[1]
local capacity = tonumber(ARGV[1])
local refill_rate = tonumber(ARGV[2])
local now = tonumber(ARGV[3])
local requested = tonumber(ARGV[4])

local bucket = redis.call('hmget', key, 'tokens', 'last_refill')
local tokens = tonumber(bucket[1]) or capacity
local last_refill = tonumber(bucket[2]) or now

-- Refill tokens based on elapsed time
local elapsed = (now - last_refill) / 1000000  -- Convert to seconds
local new_tokens = math.min(capacity, tokens + (elapsed * refill_rate))

if new_tokens >= requested then
  new_tokens = new_tokens - requested
  redis.call('hmset', key, 'tokens', new_tokens, 'last_refill', now)
  redis.call('expire', key, math.ceil(capacity / refill_rate) * 2)
  return 1  -- Allowed
else
  redis.call('hmset', key, 'tokens', new_tokens, 'last_refill', now)
  redis.call('expire', key, math.ceil(capacity / refill_rate) * 2)
  return 0  -- Denied
end
```

#### Backpressure Patterns
```
BACKPRESSURE MECHANISMS:
+--------------------------------------------------------------+
|  Pattern            | How It Works         | Best For          |
+--------------------------------------------------------------+
|  Bounded queues     | Reject when full     | Async workers     |
|  Load shedding      | Drop excess requests | Overload protect  |
|  Circuit breaker    | Stop calling failed  | Downstream protect|
|                     | dependency            |                   |
|  Adaptive concurr.  | Adjust concurrent    | Self-tuning       |
|                     | limit dynamically     |                   |
|  TCP backpressure   | Let TCP flow control | Network layer     |
|  Reactive streams   | Subscriber controls  | Stream processing |
|                     | demand (back-          |                   |
|                     | pressure signal)       |                   |
+--------------------------------------------------------------+

LOAD SHEDDING PRIORITY:
1. Health checks -- NEVER shed (must always respond)
2. Authentication -- High priority (users cannot log in otherwise)
3. Critical API calls -- High priority (payments, data writes)
4. Standard API calls -- Medium priority (shed under extreme load)
5. Background jobs -- Low priority (shed first)
6. Analytics/telemetry -- Lowest priority (shed aggressively)

LOAD SHEDDING IMPLEMENTATION:
  if current_load > 90%:
    reject LOW priority requests (HTTP 503 + Retry-After header)
  if current_load > 95%:
    reject MEDIUM priority requests
  if current_load > 99%:
    reject all non-CRITICAL requests

RESPONSE HEADERS:
  HTTP/1.1 429 Too Many Requests
  Retry-After: 30
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 0
  X-RateLimit-Reset: 1705312800
```

### Step 7: Capacity Planning Methodology
Plan infrastructure capacity for growth:

```
CAPACITY PLANNING FRAMEWORK:
+--------------------------------------------------------------+
|  Step               | Action                                   |
+--------------------------------------------------------------+
|  1. Measure current | Baseline metrics under normal load       |
|  2. Project growth  | Forecast based on business projections   |
|  3. Identify limits | Find ceiling of each component           |
|  4. Calculate runway| Time until each component hits ceiling   |
|  5. Plan scaling    | Determine scaling action per component   |
|  6. Budget          | Estimate cost of scaling actions          |
|  7. Execute         | Implement scaling in priority order       |
+--------------------------------------------------------------+

CURRENT CAPACITY BASELINE:
+--------------------------------------------------------------+
|  Component      | Current | Peak  | Capacity | Utilization    |
+--------------------------------------------------------------+
|  Web servers    | <N>     | <N>   | <N> RPS  | <%>            |
|  API servers    | <N>     | <N>   | <N> RPS  | <%>            |
|  Database (CPU) | <N>     | <N>   | <N> QPS  | <%>            |
|  Database (conn)| <N>     | <N>   | <N>      | <%>            |
|  Database (disk)| <N> GB  | <N>GB | <N> GB   | <%>            |
|  Cache (memory) | <N> GB  | <N>GB | <N> GB   | <%>            |
|  Cache (conn)   | <N>     | <N>   | <N>      | <%>            |
|  Queue depth    | <N>     | <N>   | <N>      | <%>            |
+--------------------------------------------------------------+

GROWTH PROJECTION:
+--------------------------------------------------------------+
|  Metric          | Current  | +3 months | +6 months | +12 mo  |
+--------------------------------------------------------------+
|  Users           | <N>      | <N>       | <N>       | <N>     |
|  Requests/sec    | <N>      | <N>       | <N>       | <N>     |
|  Data volume     | <N> GB   | <N> GB    | <N> GB    | <N> GB  |
|  Peak multiplier | <X>x     | <X>x      | <X>x      | <X>x    |
+--------------------------------------------------------------+

CAPACITY RUNWAY:
+--------------------------------------------------------------+
|  Component      | Hits 70%  | Hits 90%  | Action Required     |
+--------------------------------------------------------------+
|  Web servers    | <date>    | <date>    | <scale action>      |
|  Database (CPU) | <date>    | <date>    | <scale action>      |
|  Database (disk)| <date>    | <date>    | <scale action>      |
|  Cache (memory) | <date>    | <date>    | <scale action>      |
+--------------------------------------------------------------+

SCALING ROADMAP:
+--------------------------------------------------------------+
|  Timeline  | Component     | Action          | Cost Impact    |
+--------------------------------------------------------------+
|  Now       | <component>   | <action>        | +$<N>/month    |
|  +3 months | <component>   | <action>        | +$<N>/month    |
|  +6 months | <component>   | <action>        | +$<N>/month    |
|  +12 months| <component>   | <action>        | +$<N>/month    |
+--------------------------------------------------------------+
```

### Step 8: Caching Strategy for Scale
Design caching to reduce load on backend systems:

```
CACHING LAYERS:
+--------------------------------------------------------------+
|  Layer              | Technology    | TTL    | Invalidation    |
+--------------------------------------------------------------+
|  CDN (static assets)| CloudFront   | 24h    | Deploy-time     |
|  CDN (API responses)| CloudFront   | 60s    | Cache-Control   |
|  Application cache  | Redis/Memcached| <TTL> | Write-through   |
|  Query cache        | In-process   | 30s    | Time-based      |
|  ORM/session cache  | In-process   | Request| Request scope   |
+--------------------------------------------------------------+

CACHE PATTERNS:
+--------------------------------------------------------------+
|  Pattern            | Write Path           | Read Path         |
+--------------------------------------------------------------+
|  Cache-aside        | App writes DB only   | Check cache, miss |
|  (lazy loading)     |                       | -> read DB, fill  |
|  Write-through      | App writes cache+DB  | Always read cache |
|  Write-behind       | App writes cache,    | Always read cache |
|  (write-back)       | async flush to DB    |                   |
|  Read-through       | Cache reads DB on    | Always read cache |
|                     | miss (transparent)    |                   |
+--------------------------------------------------------------+

CACHE SIZING:
  Working set size: <data that is accessed frequently>
  Hit rate target: > 95% (below this, caching may not help)
  Memory budget: <available cache memory>
  Eviction policy: LRU (default) | LFU (frequency-based) | TTL

CACHE STAMPEDE PREVENTION:
- Locking: Only one process refreshes expired key (others wait)
- Probabilistic early refresh: Refresh before TTL expires (random)
- Background refresh: Separate process keeps cache warm
- Stale-while-revalidate: Serve stale, refresh in background
```

### Step 9: Scaling Checklist
Validate the scaling design:

```
SCALING VALIDATION:
+--------------------------------------------------------------+
|  Check                                    | Status            |
+--------------------------------------------------------------+
|  Application tier is stateless            | PASS | FAIL       |
|  Session state externalized (Redis/DB)    | PASS | FAIL       |
|  Auto-scaling policies configured         | PASS | FAIL       |
|  Database read replicas for read scaling  | PASS | FAIL       |
|  Connection pooling at all layers         | PASS | FAIL       |
|  Rate limiting at API gateway             | PASS | FAIL       |
|  Backpressure on async processing         | PASS | FAIL       |
|  Caching layer for hot data               | PASS | FAIL       |
|  CDN for static assets                    | PASS | FAIL       |
|  Capacity planning with runway dates      | PASS | FAIL       |
|  Load tested at 2x projected peak         | PASS | FAIL       |
|  Graceful degradation under overload      | PASS | FAIL       |
+--------------------------------------------------------------+

VERDICT: <SCALES | NEEDS WORK>
```

### Step 10: Artifacts & Commit
Generate deliverables:

```
SCALING DESIGN COMPLETE:

Artifacts:
- Scaling architecture: docs/scale/<system>-scaling-plan.md
- Capacity plan: docs/scale/<system>-capacity-plan.md
- Auto-scaling config: infra/<system>-autoscaling.yaml
- Rate limiting config: infra/<system>-rate-limits.yaml
- Validation: <SCALES | NEEDS WORK>

Next steps:
-> /godmode:loadtest -- Verify scaling under simulated load
-> /godmode:observe -- Monitor scaling metrics and alerts
-> /godmode:cost -- Analyze cost impact of scaling decisions
-> /godmode:distributed -- Design distributed components
-> /godmode:perf -- Optimize bottleneck components
```

Commit: `"scale: <system> -- <strategy>, <target capacity>, <verdict>"`

## Key Behaviors

1. **Measure before scaling.** Never scale based on guesses. Profile the system, identify the bottleneck, and scale the bottleneck. Scaling the wrong component wastes money.
2. **Scale the bottleneck, not everything.** If the database is the bottleneck, adding more application servers is useless. Find the constraint and address it directly.
3. **Stateless is a prerequisite.** Horizontal scaling requires stateless application instances. Externalize all state (sessions, uploads, caches) before adding instances.
4. **Auto-scaling needs tuning.** Default auto-scaling policies are rarely optimal. Tune scale-out speed, scale-in cooldown, and warm-up period based on traffic patterns.
5. **Connection pools are often the hidden bottleneck.** 100 application instances with 20 connections each = 2000 database connections. Use connection proxies (PgBouncer, RDS Proxy) to multiplex.
6. **Rate limiting is protection, not punishment.** Rate limits prevent cascade failures, protect expensive operations, and ensure fair resource distribution.
7. **Capacity planning is continuous.** Run capacity analysis quarterly. Traffic patterns change, features change, and growth accelerates. Stale capacity plans are dangerous.
8. **Cache with purpose, not hope.** Caching data with low hit rates wastes memory and adds complexity. Measure hit rates and cache only the working set.

## Example Usage

### Scaling a web application for 10x growth
```
User: /godmode:scale Our app does 500 RPS now, need to handle 5000 RPS

Scale: Assessing current bottlenecks...

CURRENT CAPACITY:
  Web servers: 4 instances, 70% CPU at 500 RPS -> ceiling ~700 RPS
  Database: 1 primary, 85% CPU, 200 connections (max 300)
  Cache: Redis, 2GB used of 8GB, 99.2% hit rate

BOTTLENECK: Database (hits ceiling at ~600 RPS)

SCALING PLAN:
  Phase 1 (immediate): Add 2 read replicas, write-split reads
    -> Database read capacity: 3x (handles 1500 RPS)
  Phase 2 (week 1): Add PgBouncer, increase app to 10 instances
    -> App capacity: 1750 RPS
  Phase 3 (week 2): Add auto-scaling (min 10, max 30)
    -> App capacity: 5250 RPS
  Phase 4 (week 3): Add CDN + API caching for top 10 endpoints
    -> Effective capacity: 7000+ RPS (70% cache hit)

COST IMPACT: +$2,400/month (current $1,800 -> $4,200)
```

### Designing rate limiting for an API
```
User: /godmode:scale Design rate limiting for our public API

Scale: Designing rate limiting...

RATE LIMITING TIERS:
  Free tier:    60 req/min,  1000 req/day
  Pro tier:     600 req/min, 50000 req/day
  Enterprise:   6000 req/min, unlimited daily

  Algorithm: Token bucket (allows controlled burst)
  Storage: Redis (shared across all API instances)
  Key: API key (per-user) + endpoint (per-resource)
  Response: 429 + Retry-After header + rate limit headers

  Special limits:
  POST /search:  10 req/min (expensive query)
  POST /export:  5 req/hour (heavy operation)
  GET /status:   No limit (health check)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full scalability assessment and design |
| `--assess` | Current capacity assessment only |
| `--horizontal` | Horizontal scaling design |
| `--vertical` | Vertical scaling recommendations |
| `--autoscale` | Auto-scaling configuration |
| `--database` | Database scaling (replicas, pooling, splitting) |
| `--cache` | Caching strategy design |
| `--ratelimit` | Rate limiting and backpressure design |
| `--capacity` | Capacity planning with growth projections |
| `--cost` | Cost analysis for scaling options |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check infrastructure: docker-compose.yml, k8s manifests, terraform files, serverless.yml
2. Detect database: PostgreSQL, MySQL, MongoDB, DynamoDB configs and connection strings
3. Check for caching: Redis, Memcached, CDN configs (CloudFront, Fastly, Cloudflare)
4. Detect load balancer: nginx.conf, ALB/NLB configs, HAProxy
5. Check for auto-scaling: HPA (k8s), ASG (AWS), Cloud Run scaling configs
6. Detect message queues: RabbitMQ, SQS, Kafka, Redis Streams configs
7. Check for connection pooling: pgbouncer, ProxySQL, client-side pool configs
8. Scan for bottleneck indicators: N+1 queries, missing indexes, synchronous I/O in hot paths
```

## Iterative Scaling Implementation Loop

```
current_iteration = 0
max_iterations = 10
scaling_tasks = [list of bottlenecks/components to scale]

WHILE scaling_tasks is not empty AND current_iteration < max_iterations:
    task = scaling_tasks.pop(0)
    1. Measure current performance: identify the bottleneck (CPU, memory, I/O, network, DB)
    2. Choose scaling strategy: horizontal (add instances) vs vertical (bigger instance) vs optimize
    3. Implement the change (add replicas, configure auto-scaling, add caching, optimize query)
    4. Load test: simulate 2x current peak traffic
    5. Measure improvement: compare latency p50/p95/p99, throughput, error rate
    6. Verify cost impact: calculate $/request or $/user at new scale
    7. IF improvement < 20% → wrong bottleneck, re-measure and try different approach
    8. IF improvement >= 20% → commit: "scale: <component> — <strategy> (<improvement>)"
    9. current_iteration += 1

POST-LOOP: Capacity plan for 6-month and 12-month projected growth
```

## Multi-Agent Dispatch

```
PARALLEL AGENT DISPATCH (3 worktrees):
  Agent 1 — "scale-app": application-level scaling (stateless services, connection pools, caching)
  Agent 2 — "scale-data": database scaling (read replicas, sharding, indexes, query optimization)
  Agent 3 — "scale-infra": infrastructure scaling (auto-scaling, load balancers, CDN, queue workers)

MERGE ORDER: data → app → infra (data changes may affect app config, infra wraps both)
CONFLICT ZONES: connection strings, environment configs (define shared config first)
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. NEVER scale without measuring the bottleneck first. Profile before provisioning.
2. NEVER store state in application instances. Sessions, uploads, caches = externalize all.
3. EVERY auto-scaling policy must have a cooldown period. No flapping.
4. NEVER set connection pool size to maximum. Calculate: pool_size * instances <= DB max_connections.
5. ALWAYS load test at 2x projected peak before relying on a scaling plan.
6. EVERY scaling change must include a cost estimate. 10x instances = 10x cost.
7. NEVER scale a service that has an unoptimized hot path. Optimize first, scale second.
8. Rate limits MUST include clear headers (X-RateLimit-*, Retry-After) and documentation.
9. EVERY database read replica must handle stale reads correctly. No reading your own writes from replica.
10. Horizontal scaling MUST be tested with rolling deployments. No big-bang instance replacement.
```

## Anti-Patterns

- **Do NOT scale without measuring.** "We need more servers" without knowing the bottleneck leads to wasted money. Profile first: CPU, memory, I/O, network, database.
- **Do NOT keep state in application instances.** In-memory sessions, local file uploads, and instance-specific caches prevent horizontal scaling. Externalize everything.
- **Do NOT set pool sizes to maximum.** A 500-connection pool per instance with 20 instances = 10,000 connections. Databases cannot handle this. Use proxies and right-size pools.
- **Do NOT auto-scale without cooldown.** Without cooldown periods, auto-scaling flaps: scale up, load drops, scale down, load spikes, repeat. Set appropriate stabilization windows.
- **Do NOT cache everything.** Caching data with 5% hit rate wastes memory and adds invalidation complexity. Cache the working set (hot data) only.
- **Do NOT skip load testing.** A scaling plan that has not been load-tested is a guess. Test at 2x projected peak before relying on it.
- **Do NOT ignore cost.** Scaling from 4 to 40 instances is a 10x cost increase. Always calculate the cost impact and compare with alternative approaches (caching, optimization).
- **Do NOT rate-limit without communication.** Users need clear rate limit headers, meaningful error messages, and documentation. A bare 429 with no context is hostile.
