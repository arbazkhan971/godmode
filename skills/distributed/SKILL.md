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
```

Rules:
- CAP is a spectrum, not a binary choice -- tune consistency per operation
- Financial transactions need strong consistency; analytics tolerate eventual consistency
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
 Lock TTL: <duration> (set >> clock drift + operation time)
 Retry delay: <random 0-retry_max ms>
 Retry count: <3-5 attempts>
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
4. **Fencing tokens prevent split-brain corruption.** A leader that does not know a new leader replaced it will issue stale writes. Fencing tokens are the only reliable protection.
5. **Prefer Raft over Paxos for new systems.** Raft is provably equivalent to Paxos but dramatically easier to understand, implement, and debug. Use Paxos only when leaderless operation is required.
6. **Sharding decisions are hard to change.** Choose partition keys carefully. Resharding a live system is one of the hardest distributed operations.
7. **Test with real partitions.** Use chaos engineering to inject network partitions, clock skew, and node failures. Paper designs are insufficient.
8. **Document the failure modes.** For every component, document what happens when it fails. If you cannot answer "what happens when X is down?", the design is incomplete.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full distributed system design |
| `--cap` | CAP theorem trade-off analysis only |
| `--consensus` | Consensus protocol selection and configuration |

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
- DOCUMENT ALL consistency levels per operation, not per system
- DOCUMENT ALL failure modes for every component ("what happens when X is down?")
- TEST ALL distributed systems with real network partitions via chaos engineering before production

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
| Failure | Action |
|---------|--------|
| Split-brain during network partition | Use consensus protocol (Raft/Paxos). Configure quorum-based writes. Prefer CP over AP for financial data. |
| Message ordering violated | Use partition keys for ordering guarantees. Add sequence numbers. Implement idempotent consumers for at-least-once delivery. |
| Service discovery fails | Add health check retries. Use DNS-based discovery with TTL. Fall back to static configuration as last resort. |
| Clock skew causes event ordering issues | Use logical clocks (Lamport/vector clocks). Never rely on wall clock for causal ordering across nodes. |
