# /godmode:redis

Redis architecture and system design. Data structure selection, caching strategies, queues, pub/sub, session stores, rate limiters, Redis Cluster and Sentinel, memory optimization, eviction policies, Lua scripting, and Redis Functions.

## Usage

```
/godmode:redis                                   # Interactive Redis architecture workflow
/godmode:redis --cache                           # Design a caching strategy with invalidation
/godmode:redis --queue                           # Design a reliable queue with Lists or Streams
/godmode:redis --pubsub                          # Configure pub/sub or Streams for messaging
/godmode:redis --session                         # Design a session store with Redis Hashes
/godmode:redis --rate-limit                      # Implement rate limiting with sliding window
/godmode:redis --leaderboard                     # Design a leaderboard with Sorted Sets
/godmode:redis --cluster                         # Set up Redis Cluster for horizontal scaling
/godmode:redis --sentinel                        # Configure Redis Sentinel for high availability
/godmode:redis --memory                          # Analyze and optimize memory usage
/godmode:redis --lua                             # Write Lua scripts or Redis Functions
/godmode:redis --lock                            # Implement distributed locking
/godmode:redis --streams                         # Design event streaming with Redis Streams
/godmode:redis --diagnose                        # Run full Redis diagnostic (memory, slowlog)
/godmode:redis --persistence                     # Configure RDB/AOF persistence
```

## What It Does

1. Assesses Redis environment (version, hosting, deployment, workload)
2. Selects optimal data structures for each use case (strings, hashes, lists, sets, sorted sets, streams)
3. Designs caching strategies with invalidation, stampede prevention, and TTL policies
4. Configures queues (Lists, Streams), pub/sub, and session stores
5. Implements patterns: rate limiting, distributed locks, leaderboards
6. Sets up Cluster (horizontal scaling) or Sentinel (high availability)
7. Optimizes memory: encoding thresholds, eviction policies, key naming, compression
8. Writes Lua scripts and Redis Functions for atomic multi-step operations

## Output
- Data structure selection with key patterns and memory estimates
- Caching design with invalidation strategy and stampede prevention
- Cluster/Sentinel topology with configuration
- Memory analysis with optimization recommendations
- Commit: `"redis: <description> -- <key outcome>"`

## Next Step
After Redis architecture: `/godmode:cache` for application-level caching, `/godmode:scale` for broader scaling work, or `/godmode:queue` for advanced queue design.

## Examples

```
/godmode:redis --cache                           # Design API response caching layer
/godmode:redis --rate-limit                      # Build 100 req/min per user limiter
/godmode:redis --cluster                         # Scale beyond single-node memory
/godmode:redis --streams                         # Event sourcing with consumer groups
/godmode:redis --memory                          # Diagnose high memory usage
```
