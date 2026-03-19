# /godmode:resilience

System resilience engineering with circuit breakers, retry strategies, bulkheads, rate limiting, graceful degradation, and health checks. Designs fault-tolerant systems that handle failures gracefully and recover automatically.

## Usage

```
/godmode:resilience                        # Full resilience assessment and design
/godmode:resilience --circuit-breaker      # Circuit breaker pattern implementation
/godmode:resilience --retry                # Retry strategy with backoff and jitter
/godmode:resilience --bulkhead             # Bulkhead isolation pattern
/godmode:resilience --rate-limit           # Rate limiting strategy and implementation
/godmode:resilience --degrade              # Graceful degradation design
/godmode:resilience --health               # Health check implementation (liveness, readiness, startup)
/godmode:resilience --timeout              # Timeout hierarchy and budget management
/godmode:resilience --audit                # Audit existing resilience patterns
```

## What It Does

1. Assesses current resilience posture across all patterns (circuit breakers, retries, timeouts, bulkheads, rate limiting, health checks, degradation, fallbacks)
2. Maps dependency graph and identifies critical vs degradable paths
3. Implements circuit breaker pattern with state machine (closed/open/half-open), fallbacks, and monitoring
4. Designs retry strategies with exponential backoff, jitter (full/equal/decorrelated), and Retry-After header respect
5. Implements bulkhead pattern with semaphore-based concurrency isolation per dependency
6. Designs rate limiting with token bucket, sliding window, or concurrency-based algorithms
7. Creates graceful degradation matrix mapping each dependency to its fallback behavior
8. Implements health checks: liveness (process alive), readiness (can serve traffic), startup (initialization complete)
9. Designs timeout hierarchy ensuring each layer's timeout is less than its parent

## Output
- Resilience design at `docs/resilience/<service>-resilience.md`
- Implementation files in service source directory
- Commit: `"resilience: <service> — <patterns applied> (<coverage>)"`

## Resilience Patterns

| Pattern | Purpose | Failure Mode Addressed |
|---------|---------|----------------------|
| Circuit Breaker | Fast failure when dependency is down | Cascading failures |
| Retry + Backoff | Recover from transient failures | Temporary network issues |
| Bulkhead | Isolate failure domains | Resource exhaustion |
| Rate Limiting | Prevent overload | Traffic spikes |
| Graceful Degradation | Maintain partial functionality | Dependency outage |
| Health Checks | Enable orchestrator decisions | Container lifecycle |
| Timeout Budget | Prevent unbounded waits | Slow dependencies |

## Next Step
After resilience design: `/godmode:chaos` to validate with failure injection.
After implementation: `/godmode:observe` to monitor circuit breaker states and retry counts.
Under load: `/godmode:loadtest` to verify resilience under stress.

## Examples

```
/godmode:resilience                        # Full resilience assessment
/godmode:resilience --circuit-breaker      # Add circuit breakers to payment API
/godmode:resilience --health               # Implement K8s health probes
/godmode:resilience --timeout              # Design timeout hierarchy for microservices
```
