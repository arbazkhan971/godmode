---
name: distributed
description: |
 Distributed systems design skill. Activates when user needs CAP theorem trade-off analysis, consensus
 protocol selection (Raft, Paxos), distributed locking (Redlock, ZooKeeper), sharding and partitioning
 strategies, eventual consistency patterns, leader election, or distributed architecture design. Triggers on:
 /godmode:distributed, "distributed system", "CAP theorem", "consensus", "Raft", "Paxos", "sharding",
 "partitioning", "eventual consistency", "leader election", or when the orchestrator detects distributed
 systems work.
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
  ...
```
If the user has not provided context, ask: "What is the consistency requirement -- do all reads need to see
the latest write, or is stale data acceptable for a bounded time? This is the most important distributed
systems decision."

### Step 2: CAP Theorem Trade-Off Analysis
Analyze the fundamental trade-offs for the system:

```
CAP THEOREM ANALYSIS:
| CONSISTENCY |
| /\ |
| / \ |
| / \ |
| / CP \ |
| / zone \ |
| / \ |
  ...
```
Rules:
- CAP is a spectrum, not a binary choice -- tune consistency per operation
- Financial transactions need strong consistency; analytics tolerate eventual consistency
- Understand PACELC -- during normal operation, you still choose between latency and consistency
- Document which operations require which consistency level

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
  ...
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

  ...
```

#### Distributed Lock Decision
```
DISTRIBUTED LOCK SELECTION:
| Factor | Redlock | ZooKeeper | etcd |
|--|--|--|--|
| Correctness | Debated | Strong | Strong |
| Latency | Low (~5ms) | Medium (~20ms)| Medium |
| Fault tolerance | Majority | Majority | Raft |
| Auto-release | TTL-based | Session-based | Lease |
| Fencing tokens | Manual | Built-in | Rev |
  ...
```

### Step 5: Sharding and Partitioning Strategies
Design data distribution across nodes:

```
PARTITIONING STRATEGIES:
| Strategy | How It Works | Best For |
|--|--|--|
| Hash partitioning | hash(key) % N | Even distribution |
| Range partitioning | Key ranges per shard | Range queries |
| Consistent hashing | Hash ring with vnodes | Dynamic scaling |
| Geographic | By region/location | Data locality |
| Directory-based | Lookup table | Flexible routing |
  ...
```
### Step 6: Eventual Consistency Patterns
Design systems that converge to consistency over time:

```
EVENTUAL CONSISTENCY PATTERNS:
| Pattern | Mechanism | Use Case |
|--|--|--|
| Read repair | Fix stale reads on | Key-value stores|
| | detection | |
| Anti-entropy | Background Merkle | Replica sync |
| | tree comparison | |
| Gossip protocol | Random peer exchange | Membership, |
  ...
```
#### CRDTs (Conflict-free Replicated Data Types)
```
CRDT TYPES:
| CRDT | Operations | Merge Rule | Use |
|--|--|--|--|
| G-Counter | Increment | Max per node | Views |
| PN-Counter | Inc/Dec | Max per node | Votes |
| G-Set | Add | Union | Tags |
| OR-Set | Add/Remove | Add wins | Cart |
| LWW-Register | Set | Latest wins | Profile|
  ...
```

#### Conflict Resolution Strategies
```
CONFLICT RESOLUTION DECISION:
| Strategy | Complexity | Data Loss Risk | Best For |
|--|--|--|--|
| Last-writer-wins | Low | High | Idempotent|
| Vector clocks | Medium | None (manual) | Custom |
| CRDTs | High | None (auto) | Counters |
| Application merge | High | None (custom) | Business |
| Operational trans. | Very High | None | Documents |
  ...
```

### Step 7: Leader Election
Design leader election for coordination:

```
LEADER ELECTION PATTERNS:
| Pattern | Mechanism | Implementation |
|--|--|--|
| Bully algorithm | Highest ID wins | Custom |
| Raft election | Random timeout + | etcd, Consul |
| | majority vote | |
| ZooKeeper | Ephemeral | ZooKeeper/Curator |
| ephemeral nodes | sequential nodes | |
  ...
```
### Step 8: Network Partition Handling
Design behavior during and after network partitions:

```
PARTITION HANDLING STRATEGY:
| Phase | Action |
|--|--|
| Detection | Failure detector (heartbeat timeout, |
| | phi accrual, or gossip-based) |
| During partition | <CP: reject writes on minority side> |
| | OR <AP: accept writes, resolve later> |
| Healing | Anti-entropy, read repair, reconciliation|
  ...
```
### Step 9: Distributed System Topology
Generate the system architecture:

```
DISTRIBUTED TOPOLOGY:
| Region: us-east-1 Region: eu-west-1 |
| +---------------------------+ +---------------------------+|
| | [Leader Node 1] | | [Follower Node 3] ||
| | [Follower Node 2] | | [Follower Node 4] ||
| | [Follower Node 5] | | ||
| +---------------------------+ +---------------------------+|
| | | |
  ...
```
### Step 10: Validation & Artifacts
Validate the distributed system design:

```
DISTRIBUTED SYSTEM VALIDATION:
| Check | Status |
|--|--|
| CAP trade-offs explicitly documented | PASS | FAIL |
| Consistency level defined per operation | PASS | FAIL |
| Consensus protocol selected and justified | PASS | FAIL |
| Partition handling strategy defined | PASS | FAIL |
| Conflict resolution mechanism chosen | PASS | FAIL |
  ...
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
  ...
```
Commit: `"distributed: <system> -- <consistency model>, <consensus>, <N> shards, <verdict>"`

## Key Behaviors

Never ask to continue. Loop autonomously until done.

```bash
# Test distributed system behavior
docker compose up -d && sleep 5
curl -s http://localhost:2379/health  # etcd health
redis-cli cluster info | grep cluster_state
```
IF quorum size < (N/2)+1: reconfigure for proper fault tolerance.
WHEN network partition detected: verify system behavior matches CAP choice.
IF replication lag > 100ms: investigate network or load issues.

1. **CAP is the first conversation.** CP or AP during partitions.
2. **Consistency per-operation.** Strong for payments, eventual for counters.
3. **Partitions are inevitable.** Design for them, not around them.
4. **Fencing tokens required.** Prevent stale leader writes.
## Flags & Options

| Flag | Description |
|--|--|
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
## Keep/Discard Discipline
Each design decision either passes validation or gets revised.
- **KEEP**: Validation checklist passes for the design aspect, failure modes documented.
- **DISCARD**: Validation fails (e.g., no fencing tokens on leader election, missing partition plan). Revise before proceeding.
- **CRASH**: Design reveals fundamental architectural conflict. Revisit CAP trade-off from scratch.
- Log every design session to `.godmode/distributed-results.tsv`.

```
DISTRIBUTED SYSTEM: {system_name}
Topology: {topology} | Nodes: {N}
CAP choice: {CP|AP} | PACELC: {classification}
Consistency: {level} (per-operation breakdown: {N} operations documented)
Consensus: {protocol} | Quorum: {quorum_size}
Sharding: {strategy} | Partition key: {key}
Conflict resolution: {strategy}
Leader election: {mechanism} | Fencing: {yes|no}
  ...
```

## TSV Logging
Log every distributed systems session to `.godmode/distributed-results.tsv`:
```
timestamp	system	topology	cap_choice	consistency_level
consensus	sharding_strategy	partition_key	conflict_resolution	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. CAP trade-off documented. Consistency per-operation.
2. Consensus protocol with fault tolerance: tolerates (N-1)/2 failures.
3. Partition handling defined. Fencing tokens on leader election.
4. Every failure mode documented. Chaos test plan exists.
```

## Stop Conditions
Stop when: target reached, budget exhausted, or >5 consecutive discards.

