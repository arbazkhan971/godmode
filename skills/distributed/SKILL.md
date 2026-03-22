---
name: distributed
description: |
 Distributed systems design skill. Activates when user needs CAP theorem trade-off analysis, consensus protocol selection (Raft, Paxos), distributed locking (Redlock, ZooKeeper), sharding and partitioning strategies, eventual consistency patterns, leader election, or distributed architecture design. Triggers on: /godmode:distributed, "distributed system", "CAP theorem", "consensus", "Raft", "Paxos", "sharding", "partitioning", "eventual consistency", "leader election", or when the orchestrator detects distributed systems work.
---

# Distributed -- Distributed Systems Design

## When to Activate
- User invokes `/godmode:distributed`
- User says "distributed system", "CAP theorem", "consensus protocol"
- User says "Raft", "Paxos", "leader election", "distributed lock"
- User says "sharding", "partitioning", "eventual consistency"
- User says "split brain", "network partition", "quorum"
- When designing systems that span multiple nodes or data centers
- When `/godmode:plan` identifies distributed architecture work
- When `/godmode:review` flags consistency or partition tolerance issues

## Workflow

### Step 1: Distributed System Context
Understand the system before making distributed design decisions:

```
DISTRIBUTED SYSTEM CONTEXT:
Project: <name and purpose>
Topology: Single Region | Multi-Region | Edge | Hybrid
Number of Nodes: <expected cluster size>
Data Model: Relational | Document | Key-Value | Graph | Time-Series
Consistency Requirement: Strong | Eventual | Causal | Session
Availability Requirement: <target uptime, e.g., 99.99%>
Partition Tolerance: Must handle network partitions | Single data center only
Latency Budget: <p50, p99 targets>
Data Volume: <total data size, growth rate>
Write/Read Ratio: <approximate ratio, e.g., 1:100>
Existing Infrastructure: <databases, message brokers, cloud services>
```

If the user has not provided context, ask: "What is the consistency requirement -- do all reads need to see the latest write, or is stale data acceptable for a bounded time? This is the most important distributed systems decision."

### Step 2: CAP Theorem Trade-Off Analysis
Analyze the fundamental trade-offs for the system:

```
CAP THEOREM ANALYSIS:
+---------------------------------------------------------------+
| CONSISTENCY |
| /\ |
| / \ |
| / \ |
| / CP \ |
| / zone \ |
| / \ |
| / YOUR \ |
| / SYSTEM \ |
| / [here] \ |
| / \ |
| AVAILABILITY ---/-------- AP --------\--- PARTITION TOLERANCE |
| zone |
+---------------------------------------------------------------+

TRADE-OFF DECISION:
+--------------------------------------------------------------+
| Dimension | Choice | Justification |
+--------------------------------------------------------------+
| During partition | Consistency (CP)| <why or why not> |
| | OR Availability | |
| | (AP) | |
| Normal operation | Tunable per | <which operations |
| | operation | need strong vs eventual>|
| Read consistency | <level> | <justification> |
| Write consistency | <level> | <justification> |
+--------------------------------------------------------------+

CONSISTENCY LEVELS:
+--------------------------------------------------------------+
| Level | Guarantee | Latency Cost |
+--------------------------------------------------------------+
| Linearizable | Real-time ordering | Highest (quorum) |
| Sequential | Global total order | High |
| Causal | Respects causality | Medium |
| Session | Read-your-writes | Low-Medium |
| Eventual | Converges eventually | Lowest |
+--------------------------------------------------------------+

PACELC EXTENSION:
During Partition: <choose Availability or Consistency>
Else (normal): <choose Latency or Consistency>
PACELC Classification: <PA/EL | PA/EC | PC/EL | PC/EC>
```

Rules:
- CAP is a spectrum, not a binary choice -- tune consistency per operation
- Financial transactions need strong consistency; analytics can be eventual
- Understand PACELC -- during normal operation, you still choose between latency and consistency
- Document which operations require which consistency level

### Step 3: Consensus Protocol Selection
Choose and configure the right consensus protocol:

#### Raft Consensus
```
RAFT OVERVIEW:
+--------------------------------------------------------------+
| Component | Role |
+--------------------------------------------------------------+
| Leader | Handles all client requests, replicates |
| | log entries to followers |
| Follower | Replicates leader's log, votes in |
| | elections, redirects clients to leader |
| Candidate | Requests votes to become leader |
+--------------------------------------------------------------+

RAFT STATE MACHINE:
 Follower --[election timeout]--> Candidate
 Candidate --[majority votes]--> Leader
 Candidate --[higher term seen]--> Follower
 Leader --[higher term seen]--> Follower

RAFT CONFIGURATION:
 Cluster size: <N> (odd number: 3, 5, 7)
 Quorum: <(N/2) + 1>
 Election timeout: 150-300ms (randomized)
 Heartbeat interval: 50ms (must be << election timeout)
 Log compaction: Snapshot every <N> entries

FAULT TOLERANCE:
 3 nodes: tolerates 1 failure
 5 nodes: tolerates 2 failures
 7 nodes: tolerates 3 failures
 Formula: tolerates (N-1)/2 failures

USE WHEN:
- Need strong consistency (linearizable reads/writes)
- Cluster size is small-to-medium (3-7 nodes)
- Leader-based coordination is acceptable
- Need understandable consensus (vs Paxos complexity)

IMPLEMENTATIONS:
- etcd: Kubernetes coordination, service discovery
- CockroachDB: Distributed SQL with Raft per range
- TiKV: Distributed key-value with Raft groups
- HashiCorp Consul: Service mesh, KV store
- Custom: hashicorp/raft (Go), openraft (Rust)
```

#### Paxos Consensus
```
PAXOS OVERVIEW:
+--------------------------------------------------------------+
| Role | Responsibility |
+--------------------------------------------------------------+
| Proposer | Proposes values (client requests) |
| Acceptor | Votes on proposals, stores accepted values|
| Learner | Learns the chosen value |
+--------------------------------------------------------------+

PAXOS PHASES:
 Phase 1a (Prepare): Proposer sends prepare(n) to acceptors
 Phase 1b (Promise): Acceptors promise not to accept proposals < n
 Phase 2a (Accept): Proposer sends accept(n, value) to acceptors
 Phase 2b (Accepted): Acceptors accept if no higher proposal seen

VARIANTS:
+--------------------------------------------------------------+
| Variant | Improvement | Use Case |
+--------------------------------------------------------------+
| Basic Paxos | Single value consensus | Rare in practice|
| Multi-Paxos | Pipelined log replication| Database replication|
| Fast Paxos | 2 round trips vs 3 | Low-latency |
| Flexible Paxos | Asymmetric quorums | Read-heavy |
| EPaxos | Leaderless, commutative | Multi-leader |
+--------------------------------------------------------------+

USE WHEN:
- Need proven theoretical foundation
- Multi-leader or leaderless operation required (EPaxos)
- Existing system uses Paxos-based protocols
- Academic or research context

PREFER RAFT WHEN:
- Building from scratch (simpler to implement correctly)
- Team does not have deep distributed systems expertise
- Debugging and operational simplicity matter
```

#### Consensus Decision Matrix
```
CONSENSUS DECISION:
+--------------------------------------------------------------+
| Factor | Raft | Paxos | None|
+--------------------------------------------------------------+
| Understandability | High | Low | N/A |
| Leader requirement | Yes (single) | Optional | N/A |
| Latency | 1 RTT (leader) | 2 RTT (basic) | 0 |
| Fault tolerance | (N-1)/2 | (N-1)/2 | 0 |
| Implementation ease | Medium | Hard | Easy|
| Best for | Most systems | Multi-leader | AP |
+--------------------------------------------------------------+

SELECTED: <Raft | Paxos | None (AP system)> -- <justification>
```

### Step 4: Distributed Locking
Design distributed locks for coordination across nodes:

#### Redlock (Redis-based)
```
REDLOCK ALGORITHM:
1. Get current time in milliseconds
2. Acquire lock on N/2+1 Redis instances sequentially
 - SET key value NX PX <ttl>
 - Use short timeout per instance (5-50ms)
3. Calculate elapsed time
4. Lock is valid if acquired on majority AND elapsed < TTL
5. If lock acquired: effective TTL = initial TTL - elapsed
6. If lock NOT acquired: release on ALL instances

CONFIGURATION:
 Redis instances: <N> (odd, typically 5, on independent machines)
 Lock TTL: <duration> (must be >> clock drift + operation time)
 Retry delay: <random 0-retry_max ms>
 Retry count: <3-5 attempts>
 Clock drift factor: 0.01 (1% of TTL)

REDLOCK IMPLEMENTATION:
 lock_key = "lock:<resource>"
 lock_value = "<unique-client-id>:<uuid>" // For safe unlock
 lock_ttl = 30000 // 30 seconds

 // Acquire
 acquired = 0
 start_time = now()
 for each redis_instance:
 if SET lock_key lock_value NX PX lock_ttl:
 acquired++
 elapsed = now() - start_time
 if acquired >= (N/2 + 1) AND elapsed < lock_ttl:
 // Lock acquired, valid for (lock_ttl - elapsed) ms
 else:
 // Release all, retry

 // Release (must use Lua script for atomicity)
 EVAL "if redis.call('get', KEYS[1]) == ARGV[1] then
 return redis.call('del', KEYS[1])
 else
 return 0
 end" 1 lock_key lock_value

LIMITATIONS:
- Controversial: Martin Kleppmann argues Redlock is unsafe
- Clock skew can cause split-lock scenarios
- No fencing tokens by default (add manually)
- Network partitions can cause lock to appear held
```

#### ZooKeeper-based Locks
```
ZOOKEEPER DISTRIBUTED LOCK:
1. Create ephemeral sequential node: /locks/<resource>/lock-<seq>
2. Get all children of /locks/<resource>/
3. If your node has the lowest sequence number: lock acquired
4. If not: set watch on the next-lowest node, wait
5. On watch trigger: repeat from step 2
6. Release: delete your ephemeral node (auto-deleted on disconnect)

ADVANTAGES OVER REDLOCK:
- Ephemeral nodes auto-release on client disconnect
- Sequential ordering prevents thundering herd
- Session-based: lock tied to client session, not wall clock
- Fencing tokens: use zxid (ZooKeeper transaction ID)

ZOOKEEPER LOCK PATTERN:
 /locks/
 /resource-a/
 lock-0000000001 (held by client-1, ephemeral)
 lock-0000000002 (waiting, watches 0001)
 lock-0000000003 (waiting, watches 0002)

CONFIGURATION:
 Session timeout: 30s (balance between quick failover and false expiry)
 Lock path: /locks/<namespace>/<resource>
 Fencing token: zxid of lock node creation
```

#### Distributed Lock Decision
```
DISTRIBUTED LOCK SELECTION:
+--------------------------------------------------------------+
| Factor | Redlock | ZooKeeper | etcd |
+--------------------------------------------------------------+
| Correctness | Debated | Strong | Strong |
| Latency | Low (~5ms) | Medium (~20ms)| Medium |
| Fault tolerance | Majority | Majority | Raft |
| Auto-release | TTL-based | Session-based | Lease |
| Fencing tokens | Manual | Built-in | Rev |
| Operational cost | Redis cluster | ZK ensemble | etcd |
| Best for | Efficiency lock| Correctness | K8s env|
+--------------------------------------------------------------+

IMPORTANT DISTINCTION:
- Efficiency lock: Prevents duplicate work, tolerates occasional failure
 -> Redlock is fine, simpler to operate
- Correctness lock: Prevents data corruption, must never fail
 -> ZooKeeper or etcd with fencing tokens

SELECTED: <Redlock | ZooKeeper | etcd> -- <justification>
FENCING: <Yes (required for correctness) | No (efficiency lock)>
```

### Step 5: Sharding and Partitioning Strategies
Design data distribution across nodes:

```
PARTITIONING STRATEGIES:
+--------------------------------------------------------------+
| Strategy | How It Works | Best For |
+--------------------------------------------------------------+
| Hash partitioning | hash(key) % N | Even distribution |
| Range partitioning | Key ranges per shard | Range queries |
| Consistent hashing | Hash ring with vnodes | Dynamic scaling |
| Geographic | By region/location | Data locality |
| Directory-based | Lookup table | Flexible routing |
+--------------------------------------------------------------+

CONSISTENT HASHING:
 Hash Ring:
 0 ----[Node A]---- 90 ----[Node B]---- 180 ----[Node C]---- 270 ---- 360
 | | |
 keys 271-90 keys 91-180 keys 181-270

 Virtual Nodes (vnodes):
 - Each physical node gets 100-200 virtual nodes on the ring
 - Ensures even distribution despite heterogeneous hardware
 - Adding a node steals proportional keys from all existing nodes
 - Removing a node distributes keys proportionally

 REBALANCING:
 - Add node: Only 1/N of keys need to move (vs hash % N where all move)
 - Remove node: Only removed node's keys redistribute
 - Weight adjustment: Add/remove vnodes for the physical node

PARTITION KEY SELECTION:
+--------------------------------------------------------------+
| Criterion | Good Key | Bad Key |
+--------------------------------------------------------------+
| Cardinality | user_id (millions) | country (few) |
| Distribution | UUID (uniform) | timestamp (hot) |
| Query pattern | Matches WHERE clause | Requires scatter |
| Write distribution | Even across partitions| All to one shard |
+--------------------------------------------------------------+

HOT SPOT MITIGATION:
- Salting: Append random suffix to hot keys (trade-off: scatter reads)
- Split hot partitions: Sub-partition the hot shard
- Caching: Cache hot keys to avoid hitting the shard
- Write buffering: Batch writes to hot partitions

SHARD MAP:
+--------------------------------------------------------------+
| Shard | Key Range / Hash Range | Node | Replicas |
+--------------------------------------------------------------+
| shard-0 | <range> | node-1 | node-2, node-3|
| shard-1 | <range> | node-2 | node-3, node-1|
| shard-2 | <range> | node-3 | node-1, node-2|
+--------------------------------------------------------------+
```

### Step 6: Eventual Consistency Patterns
Design systems that converge to consistency over time:

```
EVENTUAL CONSISTENCY PATTERNS:
+--------------------------------------------------------------+
| Pattern | Mechanism | Use Case |
+--------------------------------------------------------------+
| Read repair | Fix stale reads on | Key-value stores|
| | detection | |
| Anti-entropy | Background Merkle | Replica sync |
| | tree comparison | |
| Gossip protocol | Random peer exchange | Membership, |
| | | failure detect |
| Vector clocks | Causal ordering | Conflict detect |
| CRDTs | Merge without coord | Collaborative |
| | | editing, counters|
| Last-writer-wins | Timestamp resolution | Simple cases |
| Application-level | Domain-specific | Business rules |
| resolution | merge logic | |
+--------------------------------------------------------------+
```

#### CRDTs (Conflict-free Replicated Data Types)
```
CRDT TYPES:
+--------------------------------------------------------------+
| CRDT | Operations | Merge Rule | Use |
+--------------------------------------------------------------+
| G-Counter | Increment | Max per node | Views |
| PN-Counter | Inc/Dec | Max per node | Votes |
| G-Set | Add | Union | Tags |
| OR-Set | Add/Remove | Add wins | Cart |
| LWW-Register | Set | Latest wins | Profile|
| MV-Register | Set | Keep all | Collab|
| RGA | Insert/Delete | Interleave | Text |
+--------------------------------------------------------------+

CRDT GUARANTEE:
- All replicas converge to the same state without coordination
- No conflict resolution needed -- merge function is automatic
- Trade-off: Limited operations, metadata overhead

WHEN TO USE CRDTs:
- Multi-master replication (each node accepts writes)
- Offline-first applications (sync when reconnected)
- Collaborative editing (multiple users editing simultaneously)
- Counters and sets across distributed nodes
```

#### Conflict Resolution Strategies
```
CONFLICT RESOLUTION DECISION:
+--------------------------------------------------------------+
| Strategy | Complexity | Data Loss Risk | Best For |
+--------------------------------------------------------------+
| Last-writer-wins | Low | High | Idempotent|
| Vector clocks | Medium | None (manual) | Custom |
| CRDTs | High | None (auto) | Counters |
| Application merge | High | None (custom) | Business |
| Operational trans. | Very High | None | Documents |
+--------------------------------------------------------------+

SELECTED: <strategy> -- <justification>
```

### Step 7: Leader Election
Design leader election for coordination:

```
LEADER ELECTION PATTERNS:
+--------------------------------------------------------------+
| Pattern | Mechanism | Implementation |
+--------------------------------------------------------------+
| Bully algorithm | Highest ID wins | Custom |
| Raft election | Random timeout + | etcd, Consul |
| | majority vote | |
| ZooKeeper | Ephemeral | ZooKeeper/Curator |
| ephemeral nodes | sequential nodes | |
| Database advisory | SELECT FOR UPDATE | PostgreSQL |
| locks | or advisory lock | |
| Cloud-native | Managed service | K8s Lease, DynamoDB|
+--------------------------------------------------------------+

LEADER ELECTION REQUIREMENTS:
1. Safety: At most one leader at any time
2. Liveness: Election eventually completes
3. Stability: Leader remains until failure or voluntary step-down

KUBERNETES LEASE-BASED ELECTION:
apiVersion: coordination.k8s.io/v1
kind: Lease
metadata:
 name: my-service-leader
 namespace: default
spec:
 holderIdentity: pod-name-xyz
 leaseDurationSeconds: 15
 acquireTime: "2025-01-15T10:00:00Z"
 renewTime: "2025-01-15T10:00:10Z"
 leaseTransitions: 3

LEADER RESPONSIBILITIES:
+--------------------------------------------------------------+
| Responsibility | How |
+--------------------------------------------------------------+
| Heartbeat/renewal | Renew lease every <interval> |
| Graceful handoff | Release lease on shutdown signal |
| Work distribution | Assign partitions to followers |
| Follower health check | Reassign work from failed followers |
| Split-brain prevention | Fencing token on every operation |
+--------------------------------------------------------------+

FENCING TOKENS:
- Every time a new leader is elected, increment a monotonic token
- Include the token in every write operation
- Storage layer rejects writes with stale tokens
- Prevents split-brain: old leader's writes are rejected

LEADER ELECTION DECISION:
+--------------------------------------------------------------+
| Environment | Recommendation |
+--------------------------------------------------------------+
| Kubernetes | K8s Lease API (simplest) |
| etcd available | etcd election (battle-tested) |
| ZooKeeper available| ZK ephemeral nodes (strong guarantees) |
| Database only | Advisory locks (pragmatic) |
| Custom cluster | Raft-based (build with hashicorp/raft) |
+--------------------------------------------------------------+

SELECTED: <approach> -- <justification>
```

### Step 8: Network Partition Handling
Design behavior during and after network partitions:

```
PARTITION HANDLING STRATEGY:
+--------------------------------------------------------------+
| Phase | Action |
+--------------------------------------------------------------+
| Detection | Failure detector (heartbeat timeout, |
| | phi accrual, or gossip-based) |
| During partition | <CP: reject writes on minority side> |
| | OR <AP: accept writes, resolve later> |
| Healing | Anti-entropy, read repair, reconciliation|
| Post-partition | Conflict resolution, data merge |
+--------------------------------------------------------------+

FAILURE DETECTION:
- Heartbeat timeout: Simple, configurable, prone to false positives
- Phi accrual: Adaptive, based on heartbeat history, fewer false positives
- Gossip-based: Scalable, uses multiple opinions before declaring failure
- Timeout = <base_timeout> * <suspicion_multiplier> * log(cluster_size)

SPLIT-BRAIN PREVENTION:
1. Quorum requirement: Only majority partition can serve writes
2. Fencing: Old leader's operations rejected by fencing token
3. STONITH: Shoot The Other Node In The Head (forcibly stop minority)
4. Witness: Third-party arbiter breaks ties in even-sized clusters
```

### Step 9: Distributed System Topology
Generate the system architecture:

```
DISTRIBUTED TOPOLOGY:
+---------------------------------------------------------------+
| Region: us-east-1 Region: eu-west-1 |
| +---------------------------+ +---------------------------+|
| | [Leader Node 1] | | [Follower Node 3] ||
| | [Follower Node 2] | | [Follower Node 4] ||
| | [Follower Node 5] | | ||
| +---------------------------+ +---------------------------+|
| | | |
| +---------- WAN Link -----------+ |
| (async replication) |
+---------------------------------------------------------------+

DATA FLOW:
 Writes -> Leader (us-east-1) -> Sync replicate to Node 2, 5
 -> Async replicate to Node 3, 4

 Reads (strong) -> Leader only
 Reads (eventual) -> Any node (local region preferred)
 Reads (bounded staleness) -> Any node with max lag check
```

### Step 10: Validation & Artifacts
Validate the distributed system design:

```
DISTRIBUTED SYSTEM VALIDATION:
+--------------------------------------------------------------+
| Check | Status |
+--------------------------------------------------------------+
| CAP trade-offs explicitly documented | PASS | FAIL |
| Consistency level defined per operation | PASS | FAIL |
| Consensus protocol selected and justified | PASS | FAIL |
| Partition handling strategy defined | PASS | FAIL |
| Conflict resolution mechanism chosen | PASS | FAIL |
| Leader election with fencing tokens | PASS | FAIL |
| Replication topology documented | PASS | FAIL |
| Sharding strategy with partition key | PASS | FAIL |
| Failure detector configured | PASS | FAIL |
| Split-brain prevention in place | PASS | FAIL |
| Network partition test plan exists | PASS | FAIL |
| Data reconciliation after partition | PASS | FAIL |
+--------------------------------------------------------------+

VERDICT: <SOUND | NEEDS REVISION>
```

Generate deliverables:

```
DISTRIBUTED SYSTEM DESIGN COMPLETE:

Artifacts:
- Architecture document: docs/distributed/<system>-architecture.md
- CAP analysis: docs/distributed/<system>-cap-analysis.md
- Partition handling plan: docs/distributed/<system>-partition-plan.md
- Sharding design: docs/distributed/<system>-sharding.md
- Validation: <SOUND | NEEDS REVISION>

Next steps:
-> /godmode:concurrent -- Design concurrent components within each node
-> /godmode:chaos -- Test partition tolerance with chaos experiments
-> /godmode:observe -- Monitor replication lag, consensus health, partition events
-> /godmode:loadtest -- Verify behavior under distributed load
-> /godmode:scale -- Plan capacity for the distributed cluster
```

Commit: `"distributed: <system> -- <consistency model>, <consensus>, <N> shards, <verdict>"`

## Key Behaviors

1. **CAP is the first conversation.** Before any design work, establish whether the system prioritizes consistency or availability during partitions. This decision cascades through everything.
2. **Consistency is per-operation, not per-system.** The same system can use strong consistency for payments and eventual consistency for read counters. Document the level for each operation.
3. **Network partitions are inevitable.** Design for partitions, not around them. Every distributed system will experience network issues -- the question is how it behaves.
4. **Fencing tokens prevent split-brain corruption.** A leader that does not know it has been replaced will issue stale writes. Fencing tokens are the only reliable protection.
5. **Prefer Raft over Paxos for new systems.** Raft is provably equivalent to Paxos but dramatically easier to understand, implement, and debug. Use Paxos only when leaderless operation is required.
6. **Sharding decisions are hard to change.** Choose partition keys carefully. Resharding a live system is one of the hardest distributed operations.
7. **Test with real partitions.** Use chaos engineering to inject network partitions, clock skew, and node failures. Paper designs are insufficient.
8. **Document the failure modes.** For every component, document what happens when it fails. If you cannot answer "what happens when X is down?", the design is incomplete.

## Example Usage

### Designing a distributed key-value store
```
User: /godmode:distributed Design a distributed KV store for our configuration service

Distributed: Analyzing requirements...

DISTRIBUTED SYSTEM CONTEXT:
 Purpose: Configuration service for 50 microservices
 Consistency: Strong (config changes must be visible immediately)
 Availability: 99.99% target
 Data volume: Small (< 1GB total), read-heavy (1000:1 read:write)

CAP ANALYSIS:
 Choice: CP -- config must be consistent, brief unavailability OK
 PACELC: PC/EC -- consistency always, even at latency cost

CONSENSUS: Raft (3-node cluster)
 Quorum reads for strong consistency
 Follower reads with linearizable lease for reduced leader load

SHARDING: Not needed (data fits on single Raft group)
REPLICATION: 3 replicas, synchronous within Raft

Verdict: SOUND -- 12/12 checks pass
```


## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full distributed system design |
| `--cap` | CAP theorem trade-off analysis only |
| `--consensus` | Consensus protocol selection and configuration |
| `--lock` | Distributed locking design |
| `--shard` | Sharding and partitioning strategy |
| `--consistency` | Eventual consistency pattern design |
| `--leader` | Leader election design |
| `--partition` | Network partition handling strategy |
| `--topology` | Generate distributed system topology diagram |
| `--validate` | Validate existing distributed architecture |

## Auto-Detection

Before prompting the user, automatically detect distributed system context:

```
AUTO-DETECT SEQUENCE:
1. Detect multi-service topology:
 - docker-compose.yml with multiple services → distributed system
 - kubernetes manifests with multiple Deployments → distributed system
 - Multiple repos or monorepo with service directories → microservices

2. Detect consensus/coordination:
 - grep for: etcd, consul, zookeeper in configs or dependencies
 - Check for: Raft, Paxos references in code or docs
 - Check for: leader election, distributed lock usage

3. Detect message brokers:
 - Kafka, RabbitMQ, SQS, NATS, Redis Streams in configs
 - Event-driven patterns: event bus, event store, pub/sub

4. Detect data distribution:
 - Multiple database connection strings → data partitioned across stores
 - Sharding configuration in database config (MongoDB shardKey, Vitess, Citus)
 - Read replica configuration (primary/replica endpoints)

5. Detect consistency patterns:
 - grep for: eventual consistency, saga, compensation, outbox pattern
 - Check for: dual-write code, CDC (change data capture) configs
 - Check for: idempotency keys, correlation IDs, fencing tokens

6. Detect replication topology:
 - Multi-region deployment configs (AWS regions, GCP regions)
 - Replication lag monitoring (pg_stat_replication, ReplicaLag metrics)
 - Async vs sync replication configuration

7. Auto-classify:
 - Single service + single DB → not distributed (suggest /godmode:architect)
 - Multiple services + message broker → event-driven distributed
 - Multiple services + shared DB → distributed monolith (anti-pattern)
 - Multi-region deployment → geo-distributed system

-> Auto-populate DISTRIBUTED SYSTEM CONTEXT from detected signals.
-> Only ask about consistency requirements if not inferrable from code.
```

## Keep/Discard Discipline
Each design decision either passes validation or gets revised.
- **KEEP**: Validation checklist passes for the design aspect, failure modes documented.
- **DISCARD**: Validation fails (e.g., no fencing tokens on leader election, missing partition plan). Revise before proceeding.
- **CRASH**: Design reveals fundamental architectural conflict. Revisit CAP trade-off from scratch.
- Log every design session to `.godmode/distributed-results.tsv`.

## Stop Conditions
- CAP trade-off documented before any implementation begins.
- Consistency level specified per operation, not per system.
- Consensus protocol selected with fault tolerance calculated.
- Partition handling strategy defined for during-partition and post-partition phases.
- Every failure mode documented: "What happens when X is down?"

## HARD RULES

- NEVER skip the CAP theorem conversation before any distributed design work — this decision cascades through everything
- NEVER use wall clocks for event ordering — use logical clocks (Lamport, vector) or hybrid logical clocks
- NEVER deploy a leader election without fencing tokens — a stale leader WILL corrupt data
- NEVER use 2-phase commit at scale — use sagas or compensation-based approaches instead
- NEVER shard prematurely — start with single node, then replicas, then shard only when data volume or write throughput demands it
- ALL consistency levels MUST be documented per operation, not per system
- ALL failure modes MUST be documented for every component ("what happens when X is down?")
- ALL distributed systems MUST be tested with real network partitions via chaos engineering before production

## Output Format
Print on completion:
```
DISTRIBUTED SYSTEM: {system_name}
Topology: {topology} | Nodes: {N}
CAP choice: {CP|AP} | PACELC: {classification}
Consistency: {level} (per-operation breakdown: {N} operations documented)
Consensus: {protocol} | Quorum: {quorum_size}
Sharding: {strategy} | Partition key: {key}
Conflict resolution: {strategy}
Leader election: {mechanism} | Fencing: {yes|no}
Verdict: {SOUND|NEEDS REVISION}
Artifacts: {list of files created}
```

## TSV Logging
Log every distributed systems session to `.godmode/distributed-results.tsv`:
```
timestamp	system	topology	cap_choice	consistency_level	consensus	sharding_strategy	partition_key	conflict_resolution	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. CAP trade-off explicitly documented before any design work.
2. Consistency level specified per operation, not per system.
3. Consensus protocol selected with fault tolerance calculated (tolerates (N-1)/2 failures).
4. Partition handling strategy defined for during-partition and post-partition phases.
5. Fencing tokens implemented on leader election — no leader election without fencing.
6. Sharding strategy documented with partition key selection rationale.
7. Every failure mode documented: "What happens when X is down?"
8. Network partition test plan exists with specific chaos experiments defined.
9. Replication topology diagrammed with sync/async paths labeled.

## Error Recovery
```
IF user skips CAP discussion and jumps to implementation:
 → Block: "CAP trade-off must be documented before design. Is your system CP or AP during partitions?"
 → Do NOT proceed until consistency requirements are explicitly stated

IF consensus cluster has even number of nodes:
 → Warn: "Even node count ({N}) risks split-brain with no majority"
 → Recommend: add a witness/arbiter node or use odd count (N+1)

IF Redlock chosen for a correctness-critical lock:
 → Warn: "Redlock is debated for correctness locks (Kleppmann critique). Consider ZooKeeper or etcd with fencing tokens."
 → If user accepts risk: document in design: "Redlock used as efficiency lock; data corruption risk accepted"

IF sharding key produces hot spots (one shard receives >50% of writes):
 → Identify the hot key pattern (timestamp-based? popular entity?)
 → Apply mitigation: salting, split hot partition, or write buffering
 → Re-measure write distribution after fix

IF network partition test reveals data loss:
 → Identify: was the partition CP or AP? Was fencing token enforced?
 → If AP without conflict resolution: add CRDT, vector clocks, or application-level merge
 → If CP with data loss: check quorum configuration and fencing token implementation
 → Re-run partition test — must show zero data loss

IF replication lag exceeds acceptable threshold:
 → Measure: what is the current lag (pg_stat_replication.replay_lag)?
 → Check: is the replica under-resourced? Is WAL generation rate too high?
 → Mitigate: increase replica resources, or implement bounded-staleness reads that check lag before serving
```
