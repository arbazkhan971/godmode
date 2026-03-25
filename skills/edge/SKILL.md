---
name: edge
description: |
  Edge computing and serverless skill. Covers Cloudflare
  Workers, Vercel Edge, Deno Deploy, AWS Lambda, cold
  start optimization, edge caching, distributed state.
  Triggers on: /godmode:edge, "edge function",
  "serverless API", "optimize Lambda cold start".
---

# Edge — Edge Computing & Serverless

## When to Activate
- User invokes `/godmode:edge`
- User says "edge function", "Cloudflare Workers",
  "Vercel Edge", "serverless API", "AWS Lambda"
- User says "optimize cold start", "reduce latency"
- User says "edge caching", "Durable Objects", "KV store"

## Workflow

### Step 1: Discovery & Context

```bash
# Detect platform config
ls wrangler.toml vercel.json serverless.yml \
  template.yaml deno.json 2>/dev/null

# Check bundle size (warn if > 1MB)
du -sh dist/ build/ .output/ 2>/dev/null

# Check for platform CLIs
which wrangler vercel serverless sam 2>/dev/null
```

```
EDGE DISCOVERY:
Platform: Cloudflare | Vercel | Deno Deploy |
  AWS Lambda | GCP Cloud Functions | Azure Functions
Runtime: V8 isolates (edge) | Node.js | Deno | WASM
Latency target: <ms — e.g., p99 < 50ms>
State needs: stateless | KV | durable objects | DB
Budget: <cost ceiling per million requests>

IF platform not specified: ask user
IF bundle > 1MB: flag cold start risk
IF latency target < 50ms: recommend edge runtime
```

### Step 2: Edge Function Design

```
ARCHITECTURE:
  Client → Edge PoP (~300 locations) → Origin

Edge function constraints:
  CPU time limit: 10-50ms (platform dependent)
  Bundle size limit: 1MB (CF Workers), 4MB (Vercel)
  No Node.js globals in edge (Buffer, fs, process)

WHEN to use edge vs serverless:
  Edge: latency-critical, geolocation, auth, A/B test
  Serverless: CPU-heavy, long-running, DB-intensive
```

### Step 3: Cold Start Optimization

```
COLD START BENCHMARKS:
| Runtime      | Typical Cold Start |
|--------------|-------------------|
| V8 isolate   | < 5ms             |
| Node.js 20   | 100-300ms         |
| Python 3.12  | 150-400ms         |
| Java 21      | 500-3000ms        |
| .NET 8       | 200-500ms         |

OPTIMIZATION CHECKLIST:
- Bundle size < 1MB (tree-shake, remove unused deps)
- Lazy-initialize DB connections and heavy modules
- Use ESM imports (faster parse than CJS)
- Provisioned concurrency for p99 < 100ms targets
- IF cold start > 200ms: profile with --cpu-prof
- IF bundle > 5MB: audit deps with bundlephobia

THRESHOLDS:
  Target cold start: < 200ms
  Target bundle: < 1MB (edge), < 5MB (Lambda)
  Target p99 latency: < 100ms (edge), < 500ms (Lambda)
```

### Step 4: Edge Caching Strategies

```
CACHING STRATEGIES:
| Strategy              | TTL       | Use Case       |
|-----------------------|-----------|----------------|
| Cache-Control         | 60-3600s  | Static assets  |
| stale-while-revalidate| 60s+300s  | Dynamic lists  |
| KV cache              | 30-300s   | API responses  |
| Cache API (CF)        | Custom    | Computed output|

RULES:
- IF response is per-user: Cache-Control: private
- IF response is public: s-maxage + revalidate
- IF hit rate < 80%: audit cache keys
- Target CDN hit rate: > 80%
```

### Step 5: Distributed State at the Edge

```
EDGE STATE SOLUTIONS:
| Solution     | Consistency    | Latency   |
|-------------|----------------|-----------|
| KV Store    | Eventually     | <10ms read|
| Durable Obj | Strongly       | Varies    |
| D1/Turso    | Strongly       | <10ms read|
| R2/S3       | Eventually     | Varies    |

IF need strong consistency: use Durable Objects
IF need global reads: use KV with write-behind
IF need SQL at edge: use D1 or Turso replicas
```

### Step 6: Infrastructure as Code

```yaml
# wrangler.toml (Cloudflare Workers)
name = "my-worker"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
ENVIRONMENT = "production"
```

### Step 7: Observability

Structured JSON logs shipped to centralized service.
Metrics: cold start duration, p99 latency, error rate.

### Step 8: Testing

```bash
# Local testing with platform emulator
npx wrangler dev               # Cloudflare
npx vercel dev                  # Vercel
sam local start-api             # AWS SAM

# Run tests against local emulator
npx vitest run tests/edge/
```

```
TESTING MATRIX:
| Layer       | Tool                    |
|-------------|-------------------------|
| Unit        | Vitest / Jest (mocked)  |
| Integration | Miniflare / SAM local   |
| E2E         | Playwright (deployed)   |
| Performance | k6 / wrk               |
```

### Step 9: Artifacts & Completion

```
EDGE/SERVERLESS COMPLETE:
Platform: <platform>
Functions: <N>, Cold start: <X>ms, Bundle: <N>KB
Caching: <strategy>, Regions: <global | specific>
```

Commit: `"edge: <service> — <N> functions, p99 <X>ms"`

## Key Behaviors

1. **Edge for latency, serverless for scale.**
2. **Cold starts are architecture constraints.**
   Design for them: minimize bundles, lazy init.
3. **Cache aggressively.** Fastest request never
   reaches origin.
4. **State at edge is hard.** Know your consistency
   model before choosing.
5. **Test locally.** Miniflare, sam local, vercel dev.
6. **Monitor cost.** Set budget alerts before deploying.
7. **Keep functions small.** One function per concern.
8. **Fail gracefully.** Fallbacks at every step.

## HARD RULES

1. Never put heavy computation in edge functions
   (CPU limit: 10-50ms).
2. Never cache authenticated responses in shared cache.
3. Never deploy without local testing first.
4. Never store secrets in source or plain-text env vars.
5. Never use `latest` tag or unbounded dependencies.

## Auto-Detection
```
1. Platform: wrangler.toml, vercel.json, serverless.yml
2. Runtime: V8 isolate, Node.js, Deno, WASM
3. Functions: src/functions/, api/, workers/
4. Bundle size: warn if > 5MB
```

## Loop Protocol
```
FOR each function in queue:
  1. Analyze: bundle size, cold start, CPU, cache
  2. Implement or optimize
  3. Test locally with emulator
  4. MEASURE: cold start ms, p99, bundle KB
  5. IF cold start > 200ms: tree-shake, lazy init
  6. IF bundle > 1MB: audit deps, split function
```

## Output Format
Print: `Edge: {platform}, {N} functions, p99 {X}ms,
  bundle {N}KB, cache hit {X}%. Verdict: {verdict}.`

## TSV Logging
Log to `.godmode/edge-results.tsv`:
```
timestamp	platform	functions	cold_start_ms	bundle_kb	status
```

## Keep/Discard Discipline
```
KEEP if: tests pass AND cold start < 200ms
  AND bundle within limit
DISCARD if: tests fail OR cold start regressed
  OR new errors
```

## Stop Conditions
```
STOP when ANY of:
  - All functions deployed and validated
  - Cold start < 200ms for all functions
  - User requests stop
  - Max iterations reached
```

## Error Recovery
- Cold start too high: tree-shake, lazy init,
  increase Lambda memory, switch to edge runtime.
- Bundle too large: audit deps, use platform-native
  APIs, split into multiple functions.
- Function timeout: profile, move work to queue.
- "X is not defined": check runtime compatibility,
  edge runtimes lack Node.js globals.
