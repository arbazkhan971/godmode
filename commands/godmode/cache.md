# /godmode:cache

Design and implement caching strategies. Configures multi-layer caches (CDN, application, database), cache invalidation (TTL, event-based, write-through, write-behind), Redis/Memcached/Varnish, and cache stampede prevention.

## Usage

```
/godmode:cache                          # Full caching strategy design
/godmode:cache --assess                 # Assess current caching and opportunities
/godmode:cache --redis                  # Design and configure Redis caching
/godmode:cache --memcached              # Design and configure Memcached caching
/godmode:cache --cdn                    # Design CDN / edge caching strategy
/godmode:cache --varnish                # Configure Varnish HTTP accelerator
/godmode:cache --invalidation           # Design cache invalidation strategy
/godmode:cache --stampede               # Implement cache stampede prevention
/godmode:cache --monitor                # Set up cache monitoring and alerting
/godmode:cache --warmup                 # Design cache warming strategy
/godmode:cache --validate               # Validate existing cache configuration
/godmode:cache --benchmark              # Benchmark cache performance
```

## What It Does

1. Assesses hot paths and identifies cache opportunities
2. Designs multi-layer cache architecture (CDN, app cache, DB cache)
3. Implements cache-aside, write-through, or write-behind patterns
4. Configures cache invalidation strategy (TTL, event-based, or hybrid)
5. Sets up Redis cluster or Memcached with proper memory and eviction policies
6. Configures CDN cache headers and Varnish VCL rules
7. Implements cache stampede prevention (mutex, PER, stale-while-revalidate)
8. Sets up cache monitoring (hit rate, latency, evictions, memory)
9. Validates configuration against 14 best-practice checks

## Output
- Cache design doc at `docs/caching/<system>-cache-strategy.md`
- Redis/Memcached config at `infra/cache/`
- Cache utility module at `src/lib/cache.ts`
- CDN/Varnish config at `infra/cdn/` or `infra/varnish/`
- Monitoring dashboard at `monitoring/dashboards/cache.json`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"cache: <system> -- <layers>, <invalidation strategy>, <hit rate target>"`

## Next Step
After cache design: `/godmode:perf` to benchmark improvement, `/godmode:observe` to monitor hit rates, or `/godmode:loadtest` to test under concurrency.

## Examples

```
/godmode:cache Design caching for our product catalog API
/godmode:cache --redis                     # Configure Redis cluster
/godmode:cache --invalidation              # Design invalidation strategy
/godmode:cache --stampede                  # Prevent thundering herd
/godmode:cache --assess                    # Audit existing cache setup
```
