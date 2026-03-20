---
name: edge
description: |
  Edge computing and serverless development skill. Activates when user needs to design, build, deploy, or optimize edge functions and serverless applications. Covers edge function design (Cloudflare Workers, Vercel Edge, Deno Deploy), serverless architecture (AWS Lambda, GCP Cloud Functions, Azure Functions), cold start optimization, edge caching strategies, and distributed state at the edge (Durable Objects, KV stores). Produces production-ready edge functions, serverless configurations, and deployment pipelines. Triggers on: /godmode:edge, "build edge function", "deploy to Cloudflare Workers", "optimize Lambda cold start", "serverless API", or when the orchestrator detects edge or serverless work.
---

# Edge — Edge Computing & Serverless

## When to Activate
- User invokes `/godmode:edge`
- User says "build edge function", "deploy to Cloudflare Workers", "Vercel Edge Function"
- User says "serverless API", "AWS Lambda", "Cloud Functions", "Azure Functions"
- User says "optimize cold start", "reduce Lambda latency"
- User says "edge caching", "Durable Objects", "KV store at edge"
- When `/godmode:deploy` targets a serverless or edge platform
- When `/godmode:perf` identifies latency that edge deployment could reduce

## Workflow

### Step 1: Discovery & Context
Understand the edge/serverless requirements:

```
EDGE DISCOVERY:
Project: <name and purpose>
Platform: Cloudflare Workers | Vercel Edge | Deno Deploy | AWS Lambda | GCP Cloud Functions | Azure Functions | Fastly Compute | Netlify Edge | Fly.io
Runtime: V8 isolates (edge) | Node.js (Lambda) | Deno | WASM | custom
Use case: <API gateway, SSR, image optimization, auth, geolocation routing, A/B testing>
Latency target: <ms — e.g., p99 < 50ms>
Traffic: <requests/sec, geographic distribution>
State needs: <stateless | KV | durable objects | database>
Data location: <where is the origin data — region, provider>
Budget: <cost ceiling per million requests>
Existing infra: <current deployment, migration or greenfield>
```

If the user hasn't specified, ask: "Which platform are you targeting? What latency requirements do you have?"

### Step 2: Edge Function Design
Design functions for edge runtime constraints:

```
EDGE FUNCTION ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌──────┐   ┌───────────────┐   ┌──────────────┐           │
│  │Client│──>│  Edge Location │──>│  Origin       │           │
│  │      │<──│  (CDN PoP)     │<──│  (if needed)  │           │
│  └──────┘   │               │   └──────────────┘           │
│             │  ┌───────────┐│                               │
│             │  │Edge Func  ││  Runs in ~300 locations       │
│             │  │(V8 isolate)││  Sub-ms cold start           │
│             │  └───────────┘│  Limited CPU time              │
│             │  ┌───────────┐│                               │
│             │  │ KV / Cache ││  Distributed state            │
│             │  └───────────┘│                               │
│             └───────────────┘                               │
│                                                              │
└─────────────────────────────────────────────────────────────┘

EDGE PLATFORM COMPARISON:
┌────────────────┬──────────────┬────────────────┬────────────┐
│  Platform      │  Runtime     │  CPU Limit     │  Cold Start│
├────────────────┼──────────────┼────────────────┼────────────┤
│  Cloudflare    │  V8 isolate  │  10-50ms CPU   │  <1ms      │
│  Workers       │              │  (adjustable)  │            │
│  Vercel Edge   │  V8 isolate  │  Varies by plan│  <5ms      │
│  Functions     │  (Edge       │                │            │
│                │   Runtime)   │                │            │
│  Deno Deploy   │  V8 isolate  │  50ms CPU      │  <5ms      │
│                │  (Deno)      │  (per request) │            │
│  Fastly        │  WASM        │  Configurable  │  <1ms      │
│  Compute       │  (Wasmtime)  │                │            │
│  Netlify Edge  │  Deno        │  50ms CPU      │  <10ms     │
│  Functions     │              │                │            │
└────────────────┴──────────────┴────────────────┴────────────┘

EDGE RUNTIME CONSTRAINTS:
  - No file system access (most platforms)
  - Limited CPU time per request (10-50ms typical)
  - No native modules (no Node.js C++ addons)
  - No long-running processes (request-response only)
  - Limited memory (128 MB typical per isolate)
  - No global mutable state between requests (in most runtimes)
  - Subset of Node.js APIs (no fs, child_process, net)
  - fetch() is the primary I/O primitive

DESIGN RULES FOR EDGE:
1. Keep functions small and focused — one function per route or concern
2. Avoid heavy computation — delegate to origin for CPU-intensive work
3. Use streaming responses for large payloads (ReadableStream)
4. Cache aggressively — edge is closest to the user
5. Fail open — if edge function errors, fall through to origin
6. Use early returns — reject invalid requests before doing work
```

Edge function patterns:
```typescript
// PATTERN: Cloudflare Worker
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // Early rejection
    if (!isValidRequest(request)) {
      return new Response('Bad Request', { status: 400 });
    }

    // Check cache first
    const cacheKey = new Request(url.toString(), request);
    const cache = caches.default;
    let response = await cache.match(cacheKey);
    if (response) return response;

    // Process at edge
    response = await handleRequest(request, env);

    // Cache the response
    ctx.waitUntil(cache.put(cacheKey, response.clone()));

    return response;
  },
};

// PATTERN: Vercel Edge Function
export const config = { runtime: 'edge' };

export default async function handler(request: Request) {
  const { searchParams } = new URL(request.url);
  const country = request.headers.get('x-vercel-ip-country') ?? 'US';

  // Geo-routing at edge
  const data = await fetch(`${getOriginForCountry(country)}/api/data`);
  return new Response(data.body, {
    headers: { 'Cache-Control': 's-maxage=60, stale-while-revalidate=300' },
  });
}

// PATTERN: Deno Deploy
Deno.serve(async (request: Request) => {
  const url = new URL(request.url);

  // Edge-side rendering
  const html = renderPage(url.pathname);
  return new Response(html, {
    headers: { 'Content-Type': 'text/html', 'Cache-Control': 'public, max-age=300' },
  });
});
```

### Step 3: Serverless Architecture
Design serverless applications on traditional FaaS platforms:

```
SERVERLESS ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌──────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐    │
│  │Client│──>│API Gateway│──>│  Lambda   │──>│ Database  │    │
│  │      │<──│(route,auth│<──│ Function  │<──│ / Service │    │
│  └──────┘   │ throttle) │   └──────────┘   └──────────┘    │
│             └──────────┘                                    │
│                                                              │
│  EVENT-DRIVEN:                                               │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐               │
│  │  Event    │──>│  Lambda   │──>│  Output   │               │
│  │  Source   │   │ Function  │   │  Target   │               │
│  │(S3, SQS, │   └──────────┘   │(DB, S3,   │               │
│  │ DynamoDB, │                  │ SNS, SQS) │               │
│  │ EventBridge)│                └──────────┘               │
│  └──────────┘                                               │
│                                                              │
└─────────────────────────────────────────────────────────────┘

SERVERLESS PLATFORM COMPARISON:
┌────────────────┬──────────────┬────────────────┬────────────┐
│  Platform      │  Max Runtime │  Memory        │  Cold Start│
├────────────────┼──────────────┼────────────────┼────────────┤
│  AWS Lambda    │  15 min      │  128MB-10GB    │  100ms-5s  │
│  GCP Cloud     │  9 min (HTTP)│  128MB-32GB    │  100ms-3s  │
│  Functions     │  60 min (evt)│                │            │
│  Azure Funcs   │  5-10 min    │  1.5GB (cons.) │  100ms-5s  │
│                │              │  14GB (prem.)  │            │
│  AWS Lambda@   │  5-30s       │  128MB-3GB     │  <100ms    │
│  Edge          │              │                │            │
└────────────────┴──────────────┴────────────────┴────────────┘

SERVERLESS FUNCTION STRUCTURE:

// AWS Lambda (Node.js)
export const handler = async (event, context) => {
  // 1. Parse and validate input
  const body = JSON.parse(event.body);
  const errors = validate(body);
  if (errors.length) return { statusCode: 400, body: JSON.stringify({ errors }) };

  // 2. Business logic (keep thin — delegate to services)
  const result = await processOrder(body);

  // 3. Return response
  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(result),
  };
};

// GCP Cloud Function
import { HttpFunction } from '@google-cloud/functions-framework';

export const handler: HttpFunction = async (req, res) => {
  const data = req.body;
  const result = await process(data);
  res.json(result);
};

SERVERLESS DESIGN PRINCIPLES:
1. Functions are stateless — all state in external stores
2. Functions are idempotent — safe to retry on failure
3. Functions are single-purpose — one function, one job
4. Functions time out — set appropriate timeouts, handle gracefully
5. Functions scale to zero — no cost when idle
6. Events are the glue — SQS, EventBridge, pub/sub connect functions
```

### Step 4: Cold Start Optimization
Minimize function startup latency:

```
COLD START ANALYSIS:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  WHAT IS A COLD START?                                       │
│  When a function instance does not exist, the platform must: │
│  1. Allocate resources (container or isolate)                │
│  2. Download and extract code                                │
│  3. Initialize runtime (Node.js, Python, Java, etc.)         │
│  4. Run module initialization (imports, DB connections)       │
│  5. Execute handler                                          │
│                                                              │
│  Steps 1-4 are the "cold start." Step 5 is normal execution.│
│                                                              │
│  COLD START DURATIONS:                                       │
│  ┌──────────────┬──────────┬───────────────────────┐        │
│  │  Runtime      │  Typical │  Worst Case           │        │
│  ├──────────────┼──────────┼───────────────────────┤        │
│  │  V8 isolate  │  <5ms    │  <10ms                │        │
│  │  (Edge)      │          │                       │        │
│  │  Node.js     │  100-300ms│ 1-3s (large bundles) │        │
│  │  Python      │  100-500ms│ 1-5s (heavy imports) │        │
│  │  Go          │  <100ms  │  <500ms               │        │
│  │  Java        │  500ms-3s│  5-15s (JVM + Spring) │        │
│  │  .NET        │  200ms-1s│  3-10s (full framework)│        │
│  └──────────────┴──────────┴───────────────────────┘        │
│                                                              │
└─────────────────────────────────────────────────────────────┘

COLD START OPTIMIZATION STRATEGIES:

1. MINIMIZE BUNDLE SIZE:
   ─────────────────────
   Smaller code = faster download and initialization
   - Tree-shake unused imports (esbuild, webpack)
   - Use lightweight alternatives (date-fns vs moment, got vs axios)
   - Remove unused SDK modules (import only needed AWS service clients)
   - Target specific runtime (no browser polyfills in Lambda)

   Before: import AWS from 'aws-sdk';  // 70MB
   After:  import { S3Client } from '@aws-sdk/client-s3';  // 3MB

2. LAZY INITIALIZATION:
   ─────────────────────
   Defer expensive setup until first use:

   // BAD: Initialized on every cold start
   const dbPool = createPool(config);  // 200ms

   // GOOD: Initialized on first request that needs it
   let dbPool: Pool | null = null;
   function getPool() {
     if (!dbPool) dbPool = createPool(config);
     return dbPool;
   }

3. PROVISIONED CONCURRENCY (AWS Lambda):
   ──────────────────────────────────────
   Pre-warm N instances that are always ready:
   - Eliminates cold starts for provisioned instances
   - Costs money for idle instances
   - Use for latency-sensitive endpoints only

   # serverless.yml
   functions:
     api:
       handler: handler.main
       provisionedConcurrency: 5  # 5 always-warm instances

4. RUNTIME SELECTION:
   ──────────────────
   Choose runtime based on cold start sensitivity:
   - Latency-critical: Go, Rust, or edge (V8 isolate)
   - Standard APIs: Node.js (good balance)
   - ML/data: Python (accept longer cold starts)
   - Avoid: Java/Spring for user-facing APIs (unless GraalVM native image)

5. KEEP-ALIVE / WARMING:
   ─────────────────────
   Periodic invocations to prevent instance recycling:
   - CloudWatch scheduled event every 5 min
   - NOT a substitute for provisioned concurrency
   - Keeps ONE instance warm (not scaled instances)
   - Use as supplement, not primary strategy

6. SNAPSTART (AWS Lambda Java):
   ────────────────────────────
   Takes a snapshot of initialized JVM state:
   - Eliminates JVM + framework startup time
   - Cold start drops from 3-5s to <200ms
   - Requires idempotent initialization code

7. EDGE RUNTIMES (near-zero cold start):
   ──────────────────────────────────────
   V8 isolates start in <5ms — effectively no cold start.
   Trade-off: limited API surface, shorter execution time.
   Use edge for latency-critical paths, Lambda for everything else.

COLD START OPTIMIZATION CHECKLIST:
┌──────────────────────────────────────────────────────────────┐
│  Optimization                          │  Impact   │ Status  │
├────────────────────────────────────────┼───────────┼─────────┤
│  Bundle size < 5 MB                    │  HIGH     │ CHECK   │
│  Tree-shaken imports                   │  HIGH     │ CHECK   │
│  Lazy DB/cache initialization          │  MEDIUM   │ CHECK   │
│  Modular SDK imports                   │  HIGH     │ CHECK   │
│  Provisioned concurrency (if needed)   │  HIGH     │ CHECK   │
│  Appropriate runtime selected          │  HIGH     │ CHECK   │
│  No unnecessary middleware/frameworks  │  MEDIUM   │ CHECK   │
│  Connection reuse across invocations   │  MEDIUM   │ CHECK   │
│  SnapStart enabled (Java only)         │  HIGH     │ CHECK   │
└────────────────────────────────────────┴───────────┴─────────┘
```

### Step 5: Edge Caching Strategies
Design caching for edge and serverless:

```
EDGE CACHING ARCHITECTURE:
┌─────────────────────────────────────────────────────────────┐
│                                                              │
│  ┌──────┐   ┌──────────────────────────────┐   ┌──────────┐│
│  │Client│──>│        Edge Location          │──>│  Origin  ││
│  │      │   │  ┌───────┐    ┌───────────┐  │   │  Server  ││
│  │      │<──│  │ CDN   │    │Edge Func   │  │<──│          ││
│  └──────┘   │  │ Cache │<──>│(compute +  │  │   └──────────┘│
│             │  └───────┘    │ cache API) │  │              │
│             │               └───────────┘  │              │
│             └──────────────────────────────┘              │
│                                                              │
└─────────────────────────────────────────────────────────────┘

CACHING STRATEGIES:

1. CACHE-FIRST (stale-while-revalidate):
   ──────────────────────────────────────
   Serve stale content immediately, revalidate in background.

   Cache-Control: public, s-maxage=60, stale-while-revalidate=300

   User experience: Always fast (cached response).
   Freshness: Up to 5 minutes stale during revalidation.
   Use for: Marketing pages, product listings, blog posts.

2. NETWORK-FIRST (cache as fallback):
   ────────────────────────────────────
   Try origin, fall back to cache if origin is down.

   async function handler(request) {
     try {
       const response = await fetch(origin);
       cache.put(request, response.clone());
       return response;
     } catch {
       return cache.match(request) ?? new Response('Service Unavailable', { status: 503 });
     }
   }

   Use for: API responses that must be fresh but should degrade gracefully.

3. CACHE-ONLY (pre-populated):
   ────────────────────────────
   Serve only from edge cache. Populate via push or background job.

   Use for: Static assets, pre-rendered pages, feature flags.

4. TIERED CACHING:
   ────────────────
   Multiple cache layers with different TTLs:

   Layer 1: Browser cache (private, short TTL)
     Cache-Control: private, max-age=60

   Layer 2: Edge/CDN cache (shared, medium TTL)
     Cache-Control: public, s-maxage=300
     Surrogate-Control: max-age=3600  (CDN-specific, longer TTL)

   Layer 3: Origin cache (Redis/Memcached, long TTL)
     Internal cache for expensive computations or DB queries

5. CACHE INVALIDATION:
   ────────────────────
   Strategy A: TTL-based (simple, eventual consistency)
     Set appropriate max-age. Accept staleness within TTL.

   Strategy B: Purge-on-write (immediate consistency)
     On data mutation, purge relevant cache keys.
     Cloudflare: await cache.delete(key)
     Fastly: instant purge via surrogate keys
     Vercel: revalidateTag() / revalidatePath()

   Strategy C: Versioned URLs (immutable caching)
     /assets/app.a1b2c3.js → Cache-Control: immutable, max-age=31536000
     Content hash in URL means URL changes when content changes.
     Never cache-bust. Always deploy new URL.

CACHE KEY DESIGN:
  Include in cache key:
  - URL path and query parameters (always)
  - Accept-Language header (for i18n)
  - User-Agent class (mobile vs desktop, if different responses)
  - Country/region (for geo-specific content)

  Exclude from cache key:
  - Authentication headers (do not cache per-user responses in shared cache)
  - Tracking parameters (utm_source, fbclid)
  - Request ID headers

  // Cloudflare Worker: custom cache key
  const cacheKey = new URL(request.url);
  cacheKey.searchParams.delete('utm_source');
  cacheKey.searchParams.delete('fbclid');
  const cached = await caches.default.match(new Request(cacheKey.toString()));
```

### Step 6: Distributed State at the Edge
Manage state in a globally distributed environment:

```
EDGE STATE SOLUTIONS:
┌──────────────┬──────────────┬──────────────┬───────────────┐
│  Solution    │  Consistency │  Latency     │  Use Case     │
├──────────────┼──────────────┼──────────────┼───────────────┤
│  KV Store    │  Eventually  │  <10ms read  │  Config, flags│
│  (CF KV,     │  consistent  │  ~500ms write│  sessions,    │
│  Vercel KV)  │              │              │  feature gates│
│  Durable     │  Strongly    │  Varies (co- │  Counters,    │
│  Objects     │  consistent  │  located)    │  rate limiting│
│  (CF DO)     │              │              │  coordination │
│  D1/Turso    │  Strongly    │  <10ms read  │  Relational   │
│  (edge SQL)  │  consistent  │  (replicas)  │  data at edge │
│  R2/S3       │  Eventually  │  Varies      │  Large objects│
│  (edge blob) │  consistent  │              │  media, files │
│  DynamoDB    │  Tunable     │  <10ms (DAX) │  High-scale   │
│  Global Tbl  │  (eventual   │  ~50ms       │  global data  │
│              │  or strong)  │  (cross-reg) │              │
└──────────────┴──────────────┴──────────────┴───────────────┘

KV STORE PATTERNS:

  // Cloudflare KV — eventually consistent key-value
  export default {
    async fetch(request, env) {
      // Read (fast — served from nearest edge)
      const config = await env.CONFIG_KV.get('feature-flags', { type: 'json' });

      // Write (propagates globally in ~60 seconds)
      await env.CONFIG_KV.put('user:123:session', JSON.stringify(session), {
        expirationTtl: 3600,  // Auto-expire in 1 hour
      });

      // List keys with prefix
      const keys = await env.CONFIG_KV.list({ prefix: 'user:123:' });
    },
  };

  Characteristics:
  - Reads: <10ms at edge (cached at PoP)
  - Writes: ~500ms (propagated to all locations in ~60s)
  - Consistency: Eventually consistent (stale reads possible)
  - Best for: Read-heavy, write-rarely data (config, flags, sessions)

DURABLE OBJECTS PATTERNS:

  // Cloudflare Durable Object — strongly consistent, single-threaded
  export class RateLimiter implements DurableObject {
    private requests: number = 0;
    private windowStart: number = 0;

    async fetch(request: Request): Promise<Response> {
      const now = Date.now();
      if (now - this.windowStart > 60_000) {
        this.requests = 0;
        this.windowStart = now;
      }

      this.requests++;
      if (this.requests > 100) {
        return new Response('Rate limited', { status: 429 });
      }
      return new Response('OK');
    }
  }

  // Worker routes to the correct Durable Object instance
  export default {
    async fetch(request, env) {
      const userId = getUserId(request);
      const id = env.RATE_LIMITER.idFromName(userId);
      const limiter = env.RATE_LIMITER.get(id);
      return limiter.fetch(request);
    },
  };

  Characteristics:
  - Single-threaded: one instance handles all requests for a given ID
  - Strongly consistent: no stale reads, transactional within object
  - Automatically migrated to edge location nearest to users
  - Best for: Counters, rate limiting, coordination, WebSocket state

EDGE STATE DECISION TREE:
  Is the data read-heavy, write-rarely?
    YES -> KV Store (eventually consistent, fast reads)
    NO  -> Continue

  Does the data need strong consistency?
    YES -> Durable Objects or edge SQL (D1/Turso)
    NO  -> KV Store with TTL

  Is it relational data with complex queries?
    YES -> Edge SQL (D1, Turso, PlanetScale)
    NO  -> Continue

  Is it large binary data (images, files)?
    YES -> R2 / S3 with CDN caching
    NO  -> KV or Durable Objects based on consistency needs
```

### Step 7: Serverless Infrastructure as Code
Define serverless infrastructure with IaC:

```
SERVERLESS IAC:

AWS SAM (Serverless Application Model):
  # template.yaml
  AWSTemplateFormatVersion: '2010-09-09'
  Transform: AWS::Serverless-2016-10-31

  Globals:
    Function:
      Timeout: 30
      MemorySize: 256
      Runtime: nodejs20.x
      Architectures: [arm64]  # Graviton — 20% cheaper, faster cold start
      Tracing: Active
      Environment:
        Variables:
          TABLE_NAME: !Ref DataTable

  Resources:
    ApiFunction:
      Type: AWS::Serverless::Function
      Properties:
        Handler: dist/handler.main
        Events:
          Api:
            Type: HttpApi
            Properties:
              Path: /api/{proxy+}
              Method: ANY
        Policies:
          - DynamoDBCrudPolicy:
              TableName: !Ref DataTable
        ProvisionedConcurrencyConfig:
          ProvisionedConcurrentExecutions: 5

    DataTable:
      Type: AWS::DynamoDB::Table
      Properties:
        BillingMode: PAY_PER_REQUEST
        AttributeDefinitions:
          - { AttributeName: pk, AttributeType: S }
          - { AttributeName: sk, AttributeType: S }
        KeySchema:
          - { AttributeName: pk, KeyType: HASH }
          - { AttributeName: sk, KeyType: RANGE }

Serverless Framework:
  # serverless.yml
  service: my-api
  provider:
    name: aws
    runtime: nodejs20.x
    architecture: arm64
    memorySize: 256
    timeout: 30
  functions:
    api:
      handler: dist/handler.main
      events:
        - httpApi:
            path: /api/{proxy+}
            method: ANY

Cloudflare Workers (wrangler.toml):
  name = "my-worker"
  main = "src/index.ts"
  compatibility_date = "2024-01-01"

  [[kv_namespaces]]
  binding = "CONFIG_KV"
  id = "abc123"

  [[durable_objects.bindings]]
  name = "RATE_LIMITER"
  class_name = "RateLimiter"

  [vars]
  ENVIRONMENT = "production"

DEPLOYMENT CHECKLIST:
┌──────────────────────────────────────────────────────────────┐
│  Check                                │  Status               │
├───────────────────────────────────────┼───────────────────────┤
│  Bundle size optimized                │  PASS | FAIL          │
│  Environment variables configured     │  PASS | FAIL          │
│  Secrets in secret manager (not env)  │  PASS | FAIL          │
│  IAM permissions least-privilege      │  PASS | FAIL          │
│  Timeout set appropriately            │  PASS | FAIL          │
│  Memory sized for workload            │  PASS | FAIL          │
│  Cold start within latency budget     │  PASS | FAIL          │
│  Error handling and retries           │  PASS | FAIL          │
│  Monitoring and alerting configured   │  PASS | FAIL          │
│  Cost estimate reviewed               │  PASS | FAIL          │
└───────────────────────────────────────┴───────────────────────┘
```

### Step 8: Observability for Edge and Serverless
Monitor distributed edge functions:

```
EDGE OBSERVABILITY:

LOGGING:
  Edge functions often lack traditional logging. Use structured
  logs shipped to a centralized service.

  // Structured logging at edge
  function log(level: string, message: string, data: Record<string, unknown>) {
    console.log(JSON.stringify({
      level,
      message,
      timestamp: new Date().toISOString(),
      requestId: crypto.randomUUID(),
      ...data,
    }));
  }

  // Cloudflare Workers: Logpush or Tail Workers
  // Vercel: Built-in log drain to Datadog, Axiom, etc.
  // AWS Lambda: CloudWatch Logs (automatic)

METRICS:
  Key metrics for edge/serverless:
  ┌──────────────────────────────────────────────────────────┐
  │  Metric                   │  Alert Threshold             │
  ├───────────────────────────┼──────────────────────────────┤
  │  Invocation count         │  Spike >2x baseline          │
  │  Error rate (4xx, 5xx)    │  >1% of requests             │
  │  Duration (p50, p95, p99) │  p99 > latency budget        │
  │  Cold start rate          │  >5% of invocations          │
  │  Cold start duration      │  p99 > 1s                    │
  │  Throttle count           │  Any (indicates scaling issue)│
  │  Concurrent executions    │  >80% of limit               │
  │  Cache hit rate           │  <80% (investigate misses)   │
  │  Cost per invocation      │  >budget / expected volume   │
  └───────────────────────────┴──────────────────────────────┘

DISTRIBUTED TRACING:
  Edge functions run in hundreds of locations. Tracing is essential
  to debug request flows across edge -> origin -> database.

  // Propagate trace ID through the request chain
  const traceId = request.headers.get('x-trace-id') ?? crypto.randomUUID();
  const originResponse = await fetch(originUrl, {
    headers: { 'x-trace-id': traceId },
  });

  Tools: Datadog, Honeycomb, Axiom, Grafana Tempo
  Protocol: W3C Trace Context (traceparent header)
```

### Step 9: Testing Edge and Serverless
Comprehensive testing strategy:

```
EDGE/SERVERLESS TESTING:
┌─────────────────────────────────────────────────────────────┐
│  Layer              │  What to Test            │  Tool       │
├─────────────────────┼──────────────────────────┼─────────────┤
│  Unit               │  Handler logic with      │  Vitest /   │
│                     │  mocked env/context      │  Jest       │
│  Integration        │  Full request/response   │  Miniflare /│
│                     │  with local runtime      │  SAM local  │
│  Edge simulation    │  Edge-specific APIs (KV, │  Miniflare /│
│                     │  Durable Objects, cache) │  wrangler   │
│  E2E                │  Deployed function with  │  Playwright │
│                     │  real infrastructure     │             │
│  Performance        │  Cold start, latency,    │  k6 / wrk   │
│                     │  throughput              │             │
│  Chaos              │  Origin failure, KV      │  Custom     │
│                     │  unavailability, timeout │             │
│  Cost               │  Estimate cost at scale  │  Calculator │
└─────────────────────┴──────────────────────────┴─────────────┘

LOCAL DEVELOPMENT:
  Cloudflare: wrangler dev (local Miniflare simulation)
  Vercel: vercel dev (local edge runtime simulation)
  AWS Lambda: sam local invoke / sam local start-api
  Deno Deploy: deno serve (native local execution)

TESTING PATTERNS:

  // Unit test (handler in isolation)
  describe('handler', () => {
    it('returns cached response', async () => {
      const env = createMockEnv({ KV: mockKV({ key: 'value' }) });
      const request = new Request('https://example.com/api/key');
      const response = await handler(request, env);
      expect(response.status).toBe(200);
      expect(await response.text()).toBe('value');
    });

    it('falls back to origin on cache miss', async () => {
      const env = createMockEnv({ KV: mockKV({}) });
      const request = new Request('https://example.com/api/missing');
      const response = await handler(request, env);
      expect(response.status).toBe(200);
      // Verify origin was called
    });
  });
```

### Step 10: Artifacts & Completion
Generate the deliverables:

```
EDGE/SERVERLESS DESIGN COMPLETE:

Artifacts:
- Functions: src/functions/<name>.ts
- Configuration: wrangler.toml / serverless.yml / template.yaml
- Infrastructure: IaC definitions for all edge/serverless resources
- Tests: tests/<name>.test.ts (unit + integration)
- CI/CD: .github/workflows/deploy-edge.yml
- Monitoring: Dashboards and alert definitions

Metrics:
- Functions: <N> edge functions, <M> serverless functions
- Latency: p50 <X>ms, p99 <Y>ms (cold start: <Z>ms)
- Cache hit rate: <N>%
- Cost estimate: $<X>/million requests

Next steps:
-> /godmode:observe — Set up monitoring and alerting
-> /godmode:perf — Load test and optimize cold starts
-> /godmode:deploy — Deploy to production with gradual rollout
-> /godmode:cache — Optimize caching strategy
```

Commit: `"edge: <service> — <N> functions, <platform>, p99 <X>ms, caching configured"`

## Key Behaviors

1. **Edge is for latency, serverless is for scale.** Edge functions run close to users for minimal latency. Serverless functions scale to zero for cost efficiency. Use both where appropriate.
2. **Cold starts are not a bug, they are an architecture constraint.** Design for them: minimize bundle size, lazy-initialize, use provisioned concurrency for latency-critical paths, or choose edge runtimes.
3. **Cache aggressively at the edge.** The fastest request is one that never reaches the origin. Use stale-while-revalidate, cache keys, and purge strategies.
4. **State at the edge is hard.** Understand the consistency model of your state store. KV is eventually consistent. Durable Objects are strongly consistent but single-homed. Choose based on requirements, not convenience.
5. **Test locally with platform emulators.** Miniflare for Cloudflare, sam local for AWS, vercel dev for Vercel. Never develop by deploying to production.
6. **Monitor cost as a first-class metric.** Serverless costs scale with traffic. A misconfigured function can generate surprising bills. Set budget alerts and estimate cost before deploying.
7. **Keep functions small and focused.** One function per concern. Edge functions have CPU limits. Serverless functions have cold start penalties proportional to code size.
8. **Fail gracefully.** Edge and serverless are distributed systems. Origin may be down, KV may be slow, function may time out. Design fallbacks at every step.

## Example Usage

### Building an Edge API
```
User: /godmode:edge Build an API gateway on Cloudflare Workers with KV caching

Edge: Starting discovery...

EDGE DISCOVERY:
Project: API Gateway
Platform: Cloudflare Workers
Runtime: V8 isolate
Use case: API routing, caching, rate limiting, auth
Latency target: p99 < 50ms

Designed:
- Router: Path-based routing to origin services
- Cache: stale-while-revalidate with KV fallback
- Rate limiting: Durable Objects per-user counter
- Auth: JWT validation at edge (no origin round-trip)

Latency: p50 3ms, p99 28ms (cache hit), p99 120ms (cache miss)
Cold start: <1ms (V8 isolate)
```

### Optimizing Lambda Cold Starts
```
User: /godmode:edge Our Lambda functions have 3-second cold starts

Edge: Analyzing cold start contributors...

COLD START ANALYSIS:
Current: 3,200ms cold start
  - Runtime init (Node.js): 200ms
  - Bundle download: 800ms (bundle: 45MB)
  - Module initialization: 1,400ms (heavy imports)
  - DB connection: 800ms (cold connection pool)

Optimizations applied:
  1. Tree-shook AWS SDK imports: 45MB -> 4MB (-91%)
  2. Lazy DB initialization: moved to first request
  3. Switched to ARM64 (Graviton): 20% faster init
  4. Added provisioned concurrency: 5 instances for critical path

After: 180ms cold start (94% improvement)
Provisioned paths: 0ms cold start
```

### Setting Up Durable Objects
```
User: /godmode:edge Implement distributed rate limiting with Durable Objects

Edge: Designing rate limiter...

Architecture:
- One Durable Object per user (strongly consistent counter)
- Sliding window algorithm: 100 requests per 60 seconds
- Worker routes to user-specific DO instance
- Alarm-based cleanup for stale state

Performance:
- Rate check latency: 2ms (co-located with user traffic)
- Zero false positives (strong consistency)
- Scales to millions of users (one DO per user)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full edge/serverless design workflow |
| `--cloudflare` | Target Cloudflare Workers |
| `--vercel` | Target Vercel Edge Functions |
| `--lambda` | Target AWS Lambda |
| `--gcp` | Target GCP Cloud Functions |
| `--deno` | Target Deno Deploy |
| `--cold-start` | Analyze and optimize cold starts |
| `--cache` | Design edge caching strategy |
| `--state` | Design distributed state (KV, Durable Objects) |
| `--cost` | Estimate and optimize costs |
| `--migrate` | Migrate from server to edge/serverless |
| `--test` | Generate test suite with local emulators |

## HARD RULES

1. **Never put heavy computation in edge functions.** Edge runtimes have CPU time limits (10-50ms). Delegate CPU-intensive work to origin or a Lambda with higher limits.
2. **Never cache authenticated responses in shared edge cache.** Private data in shared cache is a security vulnerability. Always use `Cache-Control: private` for per-user responses.
3. **Never deploy edge functions without local testing.** Use Miniflare (Cloudflare), `sam local` (AWS), or `vercel dev` (Vercel). Untested edge functions affect all global traffic instantly.
4. **Never store secrets in edge function source or environment variables in plain text.** Use platform secret managers (Wrangler secrets, AWS Secrets Manager, Vercel encrypted env vars).
5. **Never use `latest` tag or unbounded dependencies in serverless deployments.** Pin all dependency versions. Reproducible builds prevent surprise cold start regressions.

## Loop Protocol

```
function_queue = detect_edge_functions()  // list of functions/routes to build or optimize
current_iteration = 0

WHILE function_queue is not empty:
  batch = function_queue.take(3)
  current_iteration += 1

  FOR each function in batch:
    1. Analyze function: bundle size, cold start, CPU time, cache strategy
    2. Implement or optimize the function (tree-shake, lazy init, cache headers)
    3. Test locally with platform emulator (miniflare, sam local, vercel dev)
    4. Measure: cold start ms, p99 latency, bundle size KB
    5. IF cold start > budget → apply optimization (reduce bundle, lazy init, provisioned concurrency)

  Log: "Iteration {current_iteration}: processed {batch.length} functions, {function_queue.remaining} remaining, avg cold start: {ms}ms"

  IF function_queue is empty:
    Run deployment checklist (secrets, IAM, monitoring)
    BREAK
```

## Multi-Agent Dispatch

```
PARALLEL AGENTS (3 worktrees):

Agent 1 — "edge-functions":
  EnterWorktree("edge-functions")
  Implement edge function handlers (routing, caching, auth)
  Configure wrangler.toml / vercel.json / serverless.yml
  Set up KV bindings, Durable Objects, or environment variables
  ExitWorktree()

Agent 2 — "cold-start-optimization":
  EnterWorktree("cold-start-optimization")
  Analyze bundle sizes with esbuild/webpack bundle analyzer
  Tree-shake imports (modular SDK imports, remove unused deps)
  Implement lazy initialization for DB/cache connections
  Configure provisioned concurrency where needed
  ExitWorktree()

Agent 3 — "caching-and-observability":
  EnterWorktree("caching-and-observability")
  Design cache key strategy (include geo, exclude tracking params)
  Set Cache-Control / Surrogate-Control headers per route
  Add structured logging with trace IDs
  Configure dashboards for latency, error rate, cache hit rate
  ExitWorktree()

MERGE: Combine all branches, run full deployment checklist, measure end-to-end latency.
```

## Auto-Detection

```
AUTO-DETECT edge/serverless context:
  1. Check for platform config: wrangler.toml (Cloudflare), vercel.json (Vercel),
     serverless.yml (Serverless Framework), template.yaml (SAM), deno.json (Deno Deploy)
  2. Detect runtime: V8 isolate (edge), Node.js (Lambda), Deno, WASM
  3. Scan for existing edge functions: src/functions/, api/, workers/
  4. Check package.json for platform CLIs: wrangler, vercel, serverless, aws-cdk
  5. Detect state stores: KV bindings, Durable Objects, DynamoDB tables, R2 buckets
  6. Check for cold start issues: measure bundle size (warn if > 5MB)
  7. Detect CI/CD: .github/workflows/deploy*, Makefile deploy targets

  USE detected context to:
    - Target the correct platform and runtime
    - Reuse existing infrastructure bindings
    - Prioritize cold start optimization if bundle > 5MB
    - Match existing deployment patterns
```

## Anti-Patterns

- **Do NOT put heavy computation in edge functions.** Edge runtimes have CPU time limits (10-50ms). Heavy work should go to origin or a Lambda with higher limits.
- **Do NOT treat serverless like a server.** No long-running processes, no global mutable state, no file system writes. Functions are ephemeral and stateless.
- **Do NOT ignore cold starts for user-facing APIs.** A 3-second cold start is a 3-second user wait. Optimize bundle size, use provisioned concurrency, or choose edge runtimes.
- **Do NOT cache authenticated responses in shared edge cache.** Private data in shared cache is a security vulnerability. Use `Cache-Control: private` for per-user responses.
- **Do NOT assume KV reads are strongly consistent.** KV stores at the edge are eventually consistent. A write may not be visible at all edge locations for 60 seconds. Design for this.
- **Do NOT deploy to production without local testing.** Use Miniflare, sam local, or vercel dev. Deploying untested edge functions can affect all global traffic instantly.
- **Do NOT use serverless for everything.** Long-running processes, WebSocket servers, and high-throughput streams are better served by containers or VMs. Serverless is for request-response workloads.
- **Do NOT ignore cost at scale.** $0.20 per million requests sounds cheap until you're serving a billion requests. Model costs before committing to an architecture.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run edge tasks sequentially: edge functions, then cold-start optimization, then caching/observability.
- Use branch isolation per task: `git checkout -b godmode-edge-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
