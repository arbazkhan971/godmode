# /godmode:distributed

Distributed systems design and analysis. Performs CAP theorem trade-off analysis, selects consensus protocols (Raft, Paxos), designs distributed locking (Redlock, ZooKeeper), plans sharding and partitioning strategies, implements eventual consistency patterns, and configures leader election.

## Usage

```
/godmode:distributed                       # Full distributed system design
/godmode:distributed --cap                 # CAP theorem trade-off analysis only
/godmode:distributed --consensus           # Consensus protocol selection and configuration
/godmode:distributed --lock                # Distributed locking design
/godmode:distributed --shard               # Sharding and partitioning strategy
/godmode:distributed --consistency         # Eventual consistency pattern design
/godmode:distributed --leader              # Leader election design
/godmode:distributed --partition            # Network partition handling strategy
/godmode:distributed --topology            # Generate distributed system topology diagram
/godmode:distributed --validate            # Validate existing distributed architecture
```

## What It Does

1. Assesses distributed system context (topology, consistency needs, data model, scale)
2. Analyzes CAP theorem trade-offs and PACELC classification for the system
3. Selects and configures consensus protocols (Raft, Paxos, or none for AP systems)
4. Designs distributed locking with Redlock, ZooKeeper, or etcd (with fencing tokens)
5. Plans sharding using consistent hashing, range partitioning, or geographic partitioning
6. Implements eventual consistency patterns (CRDTs, vector clocks, read repair, anti-entropy)
7. Configures leader election with split-brain prevention and fencing tokens
8. Designs network partition handling and post-partition reconciliation

## Output
- Architecture document at `docs/distributed/<system>-architecture.md`
- CAP analysis at `docs/distributed/<system>-cap-analysis.md`
- Partition handling plan at `docs/distributed/<system>-partition-plan.md`
- Commit: `"distributed: <system> -- <consistency model>, <consensus>, <N> shards, <verdict>"`
- Verdict: SOUND / NEEDS REVISION

## Next Step
If NEEDS REVISION: Address identified gaps, then re-validate.
If SOUND: `/godmode:chaos` to test partition tolerance with failure injection.

## Examples

```
/godmode:distributed                       # Full distributed system design
/godmode:distributed --cap                 # Analyze CAP trade-offs for config service
/godmode:distributed --consensus           # Select consensus protocol for KV store
/godmode:distributed --lock                # Design distributed locks for payment processing
/godmode:distributed --shard               # Plan sharding for user data
/godmode:distributed --partition            # Design partition handling for payment system
```
