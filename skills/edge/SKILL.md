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
```

Edge function patterns:
```typescript
// PATTERN: Cloudflare Worker
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url);

    // Early rejection
# ... (condensed)
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

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full edge/serverless design workflow |
| `--cloudflare` | Target Cloudflare Workers |
| `--vercel` | Target Vercel Edge Functions |

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

## Output Format

```
EDGE/SERVERLESS DEPLOYMENT COMPLETE:
  Platform: <Cloudflare Workers | AWS Lambda | Vercel Edge | Deno Deploy | other>
  Functions: <N> edge functions deployed
  Cold start: <before>ms → <after>ms (<reduction>% improvement)
  Bundle size: <N> KB (limit: <M> KB)
  Runtime: <V8 isolate | Node.js | Deno | Bun>
  State: <Durable Objects | DynamoDB | KV | R2 | none>
  Caching: <Cache API | CDN | KV cache | none>
  Regions: <N> regions / <global | specific regions>
  Timeout: <N>ms (limit: <M>ms)

FUNCTION SUMMARY:
+--------------------------------------------------------------+
|  Function          | Route      | Cold Start | Bundle | State |
+--------------------------------------------------------------+
|  <function>        | /api/...   | <N>ms      | <K>KB  | KV    |
+--------------------------------------------------------------+
```

## TSV Logging

Log every invocation to `.godmode/` as TSV. Create on first run.

```
Fields: timestamp\tproject\tplatform\tfunctions_count\tcold_start_before_ms\tcold_start_after_ms\tbundle_size_kb\tregions\tcommit_sha
Example: 2025-01-15T10:30:00Z\tmy-api\tcloudflare-workers\t6\t450\t120\t85\tglobal\tabc1234
```

## Success Criteria

```
EDGE/SERVERLESS SUCCESS CRITERIA:
+--------------------------------------------------------------+
|  Criterion                                  | Required         |
+--------------------------------------------------------------+
|  Bundle size within platform limits         | YES              |
|  Cold start < 200ms (or platform target)    | YES              |
|  No Node.js-only APIs in edge runtime       | YES (edge)       |
|  Environment secrets not in code            | YES              |
|  Error handling with structured responses   | YES              |
|  Timeout configured below platform max      | YES              |
|  Caching strategy for repeated requests     | YES              |
|  Observability (logs, traces, metrics)      | YES              |
|  No long-running connections in serverless  | YES              |
|  Graceful degradation on dependency failure | YES              |
+--------------------------------------------------------------+

VERDICT: ALL required criteria must PASS. Any FAIL → fix before commit.
```

## Error Recovery

```
ERROR RECOVERY — EDGE:
1. Cold start exceeds target:
   → Reduce bundle size (tree-shake, remove unused deps). Use dynamic import for rarely-used code. Pre-warm with scheduled pings. Switch to edge runtime (V8 isolate) from Node.js.
2. Bundle size exceeds platform limit:
   → Audit dependencies (bundlephobia). Replace heavy libs with lightweight alternatives. Use platform-native APIs (fetch, crypto) instead of polyfills. Split into multiple functions.
3. Function timeout:
   → Profile execution. Move long operations to background queue (Queues API, SQS). Cache intermediate results. Reduce external API call count.
4. Edge function crashes with "X is not defined":
   → Check runtime compatibility. Edge runtimes lack Node.js globals (Buffer, process, fs). Use web-standard APIs. Add platform-specific polyfills if needed.
5. State inconsistency across regions:
   → Use eventually-consistent KV with conflict resolution. Or use Durable Objects / DynamoDB for strong consistency on specific operations. Document consistency model.
6. Deployment fails silently (old version still serving):

## Edge Computing Optimization Loop

```
EDGE OPTIMIZATION PASSES:

Pass 1 — Cold Start Optimization:
  1. Measure cold start per function (Cloudflare: wrangler tail, Lambda: CloudWatch REPORT)
  2. Reduce bundle size: tree-shake, replace Node.js polyfills with web-standard APIs
  3. Lazy initialization: defer DB/cache connections to first use
  4. Lambda: increase memory (CPU scales with it), use SnapStart, Provisioned Concurrency
  5. Target: <1MB bundle (<100KB for edge), <200ms cold start (Lambda), <5ms (V8 isolates)

Pass 2 — Payload Size:
  1. Trim JSON responses: remove null fields, use field selection, paginate lists
  2. Enable gzip/brotli compression on all responses
  3. Use streaming (ReadableStream) for responses >100KB
  4. Target: <50KB gzipped for list endpoints, <10KB for detail

Pass 3 — CDN & Caching:
  1. Audit Cache-Control headers on every endpoint
  2. Static assets: public, max-age=31536000, immutable (content-hashed URLs)
  3. Dynamic: s-maxage=60, stale-while-revalidate=300
  4. User-specific: private, no-cache. Auth endpoints: no-store
  5. Target: >80% CDN hit rate for static, >50% for dynamic

Pass 4 — Cost & Efficiency:
  1. Measure cost per function ($/1M requests)
  2. Reduce invocations via aggressive caching
  3. Right-size Lambda memory with Power Tuning tool
  4. Choose cheapest platform per workload type

OPTIMIZATION REPORT:
┌──────────────────────────────┬───────────┬───────────┬───────────┐
│  Metric                      │  Before   │  After    │  Δ        │
├──────────────────────────────┼───────────┼───────────┼───────────┤
│  Cold start p99 (ms)        │  <N>      │  <N>      │  -<N>%    │
│  Bundle size (KB)           │  <N>      │  <N>      │  -<N>%    │
│  CDN cache hit rate (%)     │  <N>%     │  <N>%     │  +<N>%    │
│  Cost per 1M requests ($)   │  $<N>     │  $<N>     │  -<N>%    │
└──────────────────────────────┴───────────┴───────────┴───────────┘
VERDICT: <OPTIMIZED | NEEDS FURTHER WORK>
```

## Keep/Discard Discipline
```
After EACH implementation or optimization change:
  1. MEASURE: Run tests / validate the change produces correct output.
  2. COMPARE: Is the result better than before? (faster, safer, more correct)
  3. DECIDE:
     - KEEP if: tests pass AND quality improved AND no regressions introduced
     - DISCARD if: tests fail OR performance regressed OR new errors introduced
  4. COMMIT kept changes with descriptive message. Revert discarded changes before proceeding.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All identified tasks are complete and validated
  - User explicitly requests stop
  - Max iterations reached — report partial results with remaining items listed

DO NOT STOP just because:
  - One item is complex (complete the simpler ones first)
  - A non-critical check is pending (handle that in a follow-up pass)
```

