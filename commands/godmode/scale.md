# /godmode:scale

Scalability engineering and capacity planning. Analyzes horizontal vs vertical scaling decisions, configures auto-scaling, designs database read replicas and write splitting, optimizes connection pooling, implements rate limiting and backpressure, and plans capacity for growth.

## Usage

```
/godmode:scale                             # Full scalability assessment and design
/godmode:scale --assess                    # Current capacity assessment only
/godmode:scale --horizontal                # Horizontal scaling design
/godmode:scale --vertical                  # Vertical scaling recommendations
/godmode:scale --autoscale                 # Auto-scaling configuration
/godmode:scale --database                  # Database scaling (replicas, pooling, splitting)
/godmode:scale --cache                     # Caching strategy design
/godmode:scale --ratelimit                 # Rate limiting and backpressure design
/godmode:scale --capacity                  # Capacity planning with growth projections
/godmode:scale --cost                      # Cost analysis for scaling options
```

## What It Does

1. Assesses current scalability context (bottleneck, utilization, growth rate, SLAs)
2. Analyzes horizontal vs vertical scaling trade-offs for each component
3. Configures auto-scaling policies (AWS ASG, Kubernetes HPA, KEDA)
4. Designs database read replicas with write splitting and replication lag monitoring
5. Optimizes connection pooling at all layers (PgBouncer, RDS Proxy, application pools)
6. Implements rate limiting (token bucket, sliding window) and backpressure patterns
7. Creates capacity planning projections with runway dates and scaling roadmap
8. Designs caching layers (CDN, application cache, query cache) with invalidation strategies

## Output
- Scaling architecture at `docs/scale/<system>-scaling-plan.md`
- Capacity plan at `docs/scale/<system>-capacity-plan.md`
- Auto-scaling config at `infra/<system>-autoscaling.yaml`
- Commit: `"scale: <system> -- <strategy>, <target capacity>, <verdict>"`
- Verdict: SCALES / NEEDS WORK

## Next Step
If NEEDS WORK: Address bottlenecks, then re-assess.
If SCALES: `/godmode:loadtest` to verify scaling under simulated load.

## Examples

```
/godmode:scale                             # Full scalability assessment
/godmode:scale --assess                    # Assess current capacity bottlenecks
/godmode:scale --database                  # Scale database with read replicas
/godmode:scale --ratelimit                 # Design API rate limiting
/godmode:scale --capacity                  # Plan capacity for next 12 months
/godmode:scale --autoscale                 # Configure Kubernetes auto-scaling
```
