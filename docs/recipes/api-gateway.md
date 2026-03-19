# Recipe: Building an API Gateway

> Rate limiting, authentication, caching, and resilience for your API. From design to load-tested deployment.

---

## Context

Your API is growing. Multiple clients (web app, mobile app, partner integrations) hit your services. You need a single entry point that handles cross-cutting concerns: authentication, rate limiting, caching, request routing, and circuit breaking. This recipe builds an API gateway from scratch or configures one using existing infrastructure.

## The Chain

```
architect → api → auth → cache → resilience → loadtest → deploy
```

## When to Use This Recipe

- You have multiple backend services that need a unified entry point
- You need rate limiting to protect against abuse
- You need API key management for external partners
- You need request-level caching to reduce backend load
- You need circuit breakers to handle downstream failures gracefully
- You are preparing for a public API launch

---

## Session Transcript

### Phase 1: Architect the Gateway

```
> /godmode:architect Design an API gateway for our platform. We have
  3 backend services (users, orders, products) and need to support
  our web app, mobile app, and 50 partner integrations. Expected
  load is 10K req/s peak.

Godmode: Analyzing architecture requirements...

ARCHITECTURE DECISION:

  Option A: Build custom gateway (Express/Fastify + plugins)
    + Full control, no vendor lock-in
    + Can embed business logic
    - Must build and maintain every feature
    - 2-4 weeks to production-ready

  Option B: Kong Gateway (open source)
    + Battle-tested at scale
    + Rich plugin ecosystem (auth, rate limit, caching, logging)
    + Declarative configuration
    - Learning curve, operational complexity
    - Lua for custom plugins

  Option C: AWS API Gateway + Lambda
    + Fully managed, zero ops
    + Native AWS integration
    - Vendor lock-in
    - Cold start latency
    - Cost at high volume ($3.50/million requests)

  Option D: Envoy + custom control plane
    + Industry standard for service mesh
    + Extremely high performance
    - Steep learning curve
    - Overkill unless you need service mesh

RECOMMENDATION: Kong Gateway (Option B)
  Why: 10K req/s needs proven infrastructure. Kong handles this easily.
  Plugins cover auth, rate limiting, caching, and logging out of the box.
  Custom business logic via Lua or external HTTP plugins.

  If you prefer no infrastructure: Option C (AWS API Gateway) for lower
  ops burden at the cost of vendor lock-in and per-request pricing.

  If you prefer full control: Option A (custom Fastify gateway) is viable
  with a strong team and 2-4 weeks investment.

Saved: docs/adrs/adr-api-gateway.md
Commit: "architect: API gateway — Kong selected for 10K req/s with 3 services"
```

### Phase 2: API Design

Define the gateway's route table, versioning, and contracts.

```
> /godmode:api --type gateway

Godmode: Designing gateway routes...

ROUTE TABLE:
  /api/v1/users/*       → users-service:8001
  /api/v1/orders/*      → orders-service:8002
  /api/v1/products/*    → products-service:8003

  Cross-cutting routes:
  POST  /api/v1/auth/token       — Issue JWT (gateway handles auth)
  POST  /api/v1/auth/refresh     — Refresh JWT
  POST  /api/v1/auth/revoke      — Revoke token
  GET   /api/v1/health           — Gateway health check
  GET   /api/v1/status           — Aggregate service health

VERSIONING STRATEGY:
  URL-based: /api/v1/, /api/v2/
  Deprecation: v1 gets 6-month sunset with Sunset header
  Breaking changes: new version only, old version read-only

REQUEST TRANSFORMATION:
  Incoming (external):
    Authorization: Bearer <JWT>
    X-API-Key: <partner key>

  Outgoing (to services):
    X-User-ID: <extracted from JWT>
    X-User-Role: <extracted from JWT>
    X-Request-ID: <generated UUID>
    X-Forwarded-For: <client IP>

RESPONSE TRANSFORMATION:
  Strip internal headers (X-Powered-By, Server)
  Add rate limit headers (X-RateLimit-Limit, X-RateLimit-Remaining)
  Add request ID header (X-Request-ID)
  Add CORS headers for web clients

Commit: "api: gateway route table — 3 services, versioned, transformed headers"
```

### Phase 3: Authentication

```
> /godmode:auth --gateway

Godmode: Configuring gateway authentication...

AUTHENTICATION LAYERS:

  Layer 1: API Key Authentication (partner integrations)
    - Partners receive an API key (32-char random string)
    - Key sent via X-API-Key header
    - Gateway validates key against key store (Redis)
    - Key maps to: partner_id, rate_limit_tier, allowed_routes
    - Key rotation: partners can generate new keys, old key valid for 24h

  Layer 2: JWT Authentication (web + mobile apps)
    - POST /api/v1/auth/token with credentials → JWT
    - JWT contains: user_id, role, permissions, exp
    - Gateway validates JWT signature (RS256, public key)
    - Token expiry: 15 minutes (access), 7 days (refresh)
    - Refresh: POST /api/v1/auth/refresh with refresh token

  Layer 3: OAuth2 (third-party integrations)
    - Authorization Code flow for user-authorized access
    - Client Credentials flow for service-to-service
    - Scopes: read:users, write:orders, read:products, admin:*
    - Token storage: Redis with TTL

  Route-level rules:
    /api/v1/auth/*        → No auth required (public)
    /api/v1/health        → No auth required (monitoring)
    /api/v1/products      → API key OR JWT (public catalog)
    /api/v1/orders        → JWT required (user-specific)
    /api/v1/users/me      → JWT required (user-specific)
    /api/v1/users         → JWT required + admin role

  Security:
    ✓ Passwords: Argon2id hashing
    ✓ Tokens: RS256 signed JWTs (asymmetric — services verify with public key)
    ✓ API keys: SHA-256 hashed in storage (never stored in plaintext)
    ✓ Brute force: 5 failed attempts → 15 minute lockout
    ✓ Token revocation: blacklist in Redis (checked on every request)

Commit: "auth: API key + JWT + OAuth2 — three auth layers for gateway"
```

### Phase 4: Caching

```
> /godmode:cache --gateway

Godmode: Configuring gateway-level caching...

CACHING STRATEGY:

  Cache store: Redis (dedicated instance, not shared with auth)

  Cache rules by endpoint:
    GET /api/v1/products          → 5 min TTL (catalog changes rarely)
    GET /api/v1/products/:id      → 5 min TTL (individual product)
    GET /api/v1/users/me          → NO CACHE (user-specific, changes on write)
    GET /api/v1/orders            → NO CACHE (user-specific, real-time)
    GET /api/v1/orders/:id        → 30 sec TTL (order status changes)

  Cache key format:
    cache:<method>:<path>:<sorted_query_params>:<user_id_or_api_key>

  Cache headers (RFC 7234 compliant):
    Cache-Control: public, max-age=300         (cacheable, 5 min)
    Cache-Control: private, no-cache           (not cacheable)
    ETag: "<hash of response body>"            (conditional requests)
    Vary: Authorization, Accept-Encoding       (cache varies by user/encoding)

  Cache invalidation:
    On write (POST/PUT/DELETE): invalidate related GET cache keys
    Pattern: write to /api/v1/products/:id → invalidate /api/v1/products/*
    TTL-based expiry as fallback safety net

  Conditional requests:
    Client sends: If-None-Match: "<etag>"
    Gateway responds: 304 Not Modified (saves bandwidth)

  Cache metrics:
    cache_hit_total, cache_miss_total, cache_eviction_total
    Target hit rate: > 60% for product endpoints

  Expected impact:
    Products endpoints: ~80% cache hit rate → 80% fewer requests to products-service
    Overall: ~40% reduction in backend load

Commit: "cache: Redis gateway cache — products 5min, conditional requests, invalidation"
```

### Phase 5: Resilience

```
> /godmode:resilience --gateway

Godmode: Configuring resilience patterns...

RATE LIMITING:

  Tiers:
    Free API key:     100 req/min,   5,000 req/day
    Standard API key: 1,000 req/min, 100,000 req/day
    Premium API key:  10,000 req/min, 1,000,000 req/day
    Internal (JWT):   5,000 req/min  (no daily limit)

  Algorithm: Sliding window counter (Redis)
    More accurate than fixed window, less memory than sliding log.

  Rate limit headers (draft-ietf-httpapi-ratelimit-headers):
    RateLimit-Limit: 1000
    RateLimit-Remaining: 742
    RateLimit-Reset: 1710847200

  Response on limit exceeded:
    HTTP 429 Too Many Requests
    Retry-After: 45
    Body: { "error": "rate_limit_exceeded", "retry_after_seconds": 45 }

CIRCUIT BREAKERS:

  Per-service circuit breakers:
    users-service:    threshold 50% failures in 60s, open for 30s
    orders-service:   threshold 50% failures in 60s, open for 30s
    products-service: threshold 50% failures in 60s, open for 30s

  States:
    CLOSED  → normal operation, requests pass through
    OPEN    → service is down, return 503 immediately (no request sent)
    HALF-OPEN → after timeout, allow 1 probe request to test recovery

  Fallbacks when circuit is open:
    GET /products    → return cached response (stale cache)
    GET /orders      → return 503 with "Service temporarily unavailable"
    POST /orders     → return 503 (cannot accept writes when orders-service is down)

TIMEOUTS:

  Gateway → service timeout: 5 seconds
  Client → gateway timeout: 10 seconds
  Keep-alive connections: 60 seconds

  Timeout response:
    HTTP 504 Gateway Timeout
    Body: { "error": "upstream_timeout", "service": "orders-service" }

RETRIES:

  Retry policy:
    Retryable: 502, 503, 504, connection errors
    Not retryable: 4xx (client errors), POST/PUT/DELETE (not idempotent)
    Max retries: 2
    Backoff: 100ms, 500ms (exponential)

  Idempotency key:
    Clients send: Idempotency-Key: <uuid>
    Gateway deduplicates: same key within 24h returns cached response
    Enables safe retries for POST requests

HEALTH CHECKS:

  GET /api/v1/health → gateway health
  GET /api/v1/status → aggregate service health

  Service health probes:
    Every 10 seconds: HTTP GET to each service's /health endpoint
    Healthy: 3 consecutive successes
    Unhealthy: 2 consecutive failures

Commit: "resilience: rate limiting, circuit breakers, timeouts, retries, health checks"
```

### Phase 6: Load Testing

```
> /godmode:loadtest --target gateway

Godmode: Running load tests against gateway...

LOAD TEST CONFIGURATION:
  Tool: k6
  Target: https://gateway.staging.internal
  Duration: 10 minutes
  Ramp-up: 0 → 10K req/s over 2 minutes

SCENARIO 1: Normal traffic (10K req/s mixed)
  60% GET /products (cached)
  20% GET /orders (authenticated)
  10% POST /orders (write)
  10% other endpoints

  Results:
    Throughput: 10,200 req/s sustained ✓
    p50 latency: 12ms ✓
    p95 latency: 45ms ✓
    p99 latency: 120ms ✓
    Error rate: 0.02% ✓
    Cache hit rate: 78% ✓

SCENARIO 2: Spike traffic (2x normal)
  Sudden ramp to 20K req/s

  Results:
    Throughput: 18,500 req/s (rate limiting kicked in) ✓
    p50 latency: 18ms ✓
    p95 latency: 85ms ✓
    p99 latency: 340ms (acceptable under spike) ✓
    Rate limited: 1,500 req/s returned 429 (correct behavior) ✓
    Error rate: 0.05% ✓

SCENARIO 3: Downstream failure
  Simulated orders-service outage during load

  Results:
    Circuit breaker: OPENED after 12 failures in 3 seconds ✓
    Products/users: unaffected ✓
    Orders endpoints: 503 returned in < 5ms (no timeout wait) ✓
    Recovery: orders-service restored → half-open → closed in 45s ✓

LOAD TEST VERDICT: PASS
  All targets met. Gateway handles 10K req/s with room for 2x spikes.

Commit: "loadtest: gateway handles 10K req/s, graceful degradation at 20K"
```

### Phase 7: Deploy

```
> /godmode:deploy --target production

Godmode: Deploying API gateway...

DEPLOYMENT:
  Strategy: Blue-green
  Infrastructure: Kubernetes (3 gateway pods, 2 Redis pods)

  Steps:
    1. Deploy green (new version) alongside blue (current)
    2. Health check green: ✓ all services reachable
    3. Smoke test green: ✓ auth, routing, caching, rate limiting
    4. Switch traffic: blue → green (via Kubernetes service)
    5. Monitor for 10 minutes: ✓ error rate 0.01%, latency normal
    6. Retire blue pods

  DNS:
    api.yourcompany.com → gateway load balancer

  TLS:
    ✓ Let's Encrypt certificate (auto-renewal)
    ✓ TLS 1.3 only
    ✓ HSTS enabled

  Documentation:
    ✓ API docs published at docs.yourcompany.com
    ✓ Partner onboarding guide updated
    ✓ Rate limit tiers documented

Commit: "deploy: API gateway live — blue-green deployment to production"
```

---

## Gateway Configuration Reference

### Kong (Declarative Configuration)

```yaml
# kong.yml
_format_version: "3.0"

services:
  - name: users-service
    url: http://users-service:8001
    routes:
      - name: users-route
        paths: ["/api/v1/users"]
        strip_path: false

  - name: orders-service
    url: http://orders-service:8002
    routes:
      - name: orders-route
        paths: ["/api/v1/orders"]
        strip_path: false

  - name: products-service
    url: http://products-service:8003
    routes:
      - name: products-route
        paths: ["/api/v1/products"]
        strip_path: false

plugins:
  - name: rate-limiting
    config:
      minute: 1000
      policy: redis
      redis_host: redis
      redis_port: 6379

  - name: jwt
    config:
      key_claim_name: kid
      claims_to_verify: [exp]

  - name: proxy-cache
    config:
      response_code: [200]
      request_method: [GET]
      content_type: [application/json]
      cache_ttl: 300
      strategy: redis

  - name: correlation-id
    config:
      header_name: X-Request-ID
      generator: uuid
```

### Custom Gateway (Fastify)

```typescript
// For teams that prefer full control over the gateway
// Fastify with plugins for each concern

import Fastify from 'fastify';
import proxy from '@fastify/http-proxy';
import rateLimit from '@fastify/rate-limit';

const gateway = Fastify({ logger: true });

// Rate limiting
await gateway.register(rateLimit, {
  max: 1000,
  timeWindow: '1 minute',
  redis: redisClient,
});

// Service routing
await gateway.register(proxy, {
  upstream: 'http://users-service:8001',
  prefix: '/api/v1/users',
});

await gateway.register(proxy, {
  upstream: 'http://orders-service:8002',
  prefix: '/api/v1/orders',
  preHandler: [authMiddleware], // Auth required
});

await gateway.register(proxy, {
  upstream: 'http://products-service:8003',
  prefix: '/api/v1/products',
});
```

---

## Partner API Key Management

```
PARTNER ONBOARDING WORKFLOW:
  1. Partner signs up → admin approves
  2. Admin assigns tier (free, standard, premium)
  3. System generates API key pair (public key for header, secret for webhooks)
  4. Partner receives key via secure channel (not email)
  5. Key is hashed (SHA-256) and stored in database
  6. Partner tests in sandbox environment
  7. Admin activates production access

KEY ROTATION:
  1. Partner requests new key
  2. System generates new key, marks old key as "rotating"
  3. Both keys work for 24-hour grace period
  4. After 24 hours, old key is revoked
  5. Partner confirms new key is in use

KEY REVOCATION:
  Immediate: old key stops working instantly
  Used for: security incidents, partner offboarding
  All in-flight requests with revoked key receive 401
```

---

## See Also

- [Master Skill Index](../skill-index.md) — `/godmode:api`, `/godmode:auth`, `/godmode:loadtest`
- [Skill Chains](../skill-chains.md) — new-api chain
- [Building a Real-Time Chat App](realtime-chat.md) — WebSocket through gateway
- [Building a Data Pipeline](data-pipeline.md) — If your gateway serves pipeline sources
