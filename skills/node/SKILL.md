---
name: node
description: |
  Node.js backend development skill. Activates when building, architecting, or optimizing Node.js server applications. Covers framework selection and architecture (Express, Fastify, Hono, NestJS), middleware design patterns, stream processing, worker threads and cluster mode for CPU-bound work, memory management, event loop optimization, and production hardening. Every recommendation includes concrete code and performance rationale. Triggers on: /godmode:node, "Node.js backend", "Express", "Fastify", "Hono", "NestJS", "middleware", "worker threads", "cluster", "event loop", "streams".
---

# Node.js — Node.js Backend Development

## When to Activate
- User invokes `/godmode:node`
- User says "Node.js backend", "build a server", "REST API with Node"
- User mentions "Express", "Fastify", "Hono", "NestJS", "Koa"
- User asks about "middleware", "request pipeline", "middleware chain"
- User mentions "streams", "worker threads", "cluster mode"
- User asks about "event loop", "memory leak", "Node.js performance"
- When `/godmode:plan` identifies a Node.js backend project
- When `/godmode:review` flags Node.js architecture issues

## Workflow

### Step 1: Project Assessment
Understand the backend requirements:

```
NODE.JS PROJECT ASSESSMENT:
Project: <name and purpose>
Type: <REST API | GraphQL | real-time | CLI | microservice | monolith>
Scale: <expected RPS, concurrent connections, data volume>
Framework preference: <Express | Fastify | Hono | NestJS | none>
Runtime: <Node.js | Bun | Deno>
Database: <PostgreSQL, MongoDB, Redis, etc.>
Auth: <JWT, session, OAuth2, API keys>
Deployment: <Docker, serverless, PM2, Kubernetes>
Constraints: <latency SLAs, memory limits, CPU-bound tasks>
```

If the user hasn't specified, ask: "What kind of backend are you building? What's your expected scale and deployment target?"

### Step 2: Framework Selection
Choose the right framework based on project needs:

```
FRAMEWORK SELECTION GUIDE:

┌────────────────────────────────────────────────────────────────────────────┐
│ Framework │ Best For                    │ Perf      │ Ecosystem  │ Opinion │
├───────────┼─────────────────────────────┼───────────┼────────────┼─────────┤
│ Express   │ Rapid prototyping, APIs     │ Moderate  │ Massive    │ Low     │
│           │ with many npm integrations  │ ~15K RPS  │ 80K+ pkgs  │         │
├───────────┼─────────────────────────────┼───────────┼────────────┼─────────┤
│ Fastify   │ High-performance APIs       │ High      │ Growing    │ Medium  │
│           │ JSON-heavy workloads        │ ~50K RPS  │ 300+ plugs │         │
│           │ Schema-based validation     │           │            │         │
├───────────┼─────────────────────────────┼───────────┼────────────┼─────────┤
│ Hono      │ Edge/serverless, ultra-light│ Very High │ Growing    │ Low     │
│           │ Multi-runtime (Node, Bun,   │ ~80K RPS  │ 100+ mid   │         │
│           │ Deno, Cloudflare Workers)   │           │            │         │
```

### Step 3: Application Architecture
Design the application structure:

```
APPLICATION ARCHITECTURE:

Express / Fastify / Hono — Layered Architecture:
src/
├── server.ts              # Server bootstrap, graceful shutdown
├── app.ts                 # Framework app instance, global middleware
├── config/
│   ├── index.ts           # Configuration loader (env vars, defaults)
│   ├── database.ts        # Database connection config
│   └── logger.ts          # Logger configuration (pino, winston)
├── middleware/
│   ├── auth.ts            # Authentication middleware
│   ├── validate.ts        # Request validation middleware
│   ├── rateLimit.ts       # Rate limiting middleware
│   ├── errorHandler.ts    # Global error handler
```

### Step 4: Middleware Design Patterns
Design the middleware pipeline:

```
MIDDLEWARE DESIGN PATTERNS:

Pattern 1 — Request Pipeline (Express/Fastify):
  // Middleware executes in order — design the pipeline carefully
  app.use(requestId())           // 1. Assign unique request ID
  app.use(logger())              // 2. Log incoming request
  app.use(cors(corsOptions))     // 3. CORS headers
  app.use(helmet())              // 4. Security headers
  app.use(rateLimit(limits))     // 5. Rate limiting
  app.use(auth())                // 6. Authentication (sets req.user)
  app.use(compress())            // 7. Response compression
  // --- Routes execute here ---
  app.use(notFoundHandler)       // 8. 404 handler
  app.use(errorHandler)          // 9. Global error handler (ALWAYS place last)

```

### Step 5: Stream Processing
Design stream-based data processing:

```
STREAM PROCESSING PATTERNS:

Pattern 1 — File upload with streams (no memory buffering):
  import { pipeline } from 'stream/promises'
  import { createWriteStream } from 'fs'
  import { createGzip } from 'zlib'

  app.post('/upload', async (req, res) => {
    const output = createWriteStream('/uploads/file.gz')
    await pipeline(
      req,                    // Readable: incoming request body
      createGzip(),           // Transform: compress on the fly
      output                  // Writable: save to disk
    )
    res.json({ status: 'uploaded' })
```

### Step 6: Worker Threads & Cluster Mode
Design CPU-bound task handling:

```
WORKER THREADS — CPU-Bound Tasks:

When to use:
- Image processing, video transcoding
- PDF generation
- Data compression/encryption
- Heavy computation (sorting, ML inference)
- JSON parsing of very large payloads

// worker-pool.ts — Reusable worker pool
import { Worker } from 'worker_threads'
import { cpus } from 'os'

class WorkerPool {
  private workers: Worker[] = []
```

### Step 7: Memory Management & Event Loop Optimization
Optimize Node.js runtime performance:

```
MEMORY MANAGEMENT:

1. Identify memory leaks:
  // Enable heap snapshots
  node --inspect server.js
  // Or programmatically:
  import v8 from 'v8'
  function takeHeapSnapshot() {
    const filename = `/tmp/heap-${Date.now()}.heapsnapshot`
    v8.writeHeapSnapshot(filename)
    return filename
  }

  // Monitor memory in production:
  setInterval(() => {
```

### Step 8: Production Hardening
Prepare the Node.js application for production:

```
PRODUCTION CHECKLIST:
┌──────────────────────────────────────────────────────────────────────┐
│  Check                                         │  Status             │
├────────────────────────────────────────────────┼─────────────────────┤
│  Graceful shutdown (SIGTERM handler)           │  PASS | FAIL        │
│  Health check endpoint (/health, /ready)       │  PASS | FAIL        │
│  Structured logging (pino, not console.log)    │  PASS | FAIL        │
│  Request ID propagation                        │  PASS | FAIL        │
│  Global error handler catches all errors       │  PASS | FAIL        │
│  Unhandled rejection/exception handlers        │  PASS | FAIL        │
│  Rate limiting configured                      │  PASS | FAIL        │
│  CORS configured properly                      │  PASS | FAIL        │
│  Helmet/security headers                       │  PASS | FAIL        │
│  Request body size limits                      │  PASS | FAIL        │
│  Connection pooling (database, HTTP clients)   │  PASS | FAIL        │
```

### Step 9: Deliverables
Generate the project artifacts:

```
NODE.JS BACKEND COMPLETE:

Artifacts:
- Framework: <Express | Fastify | Hono | NestJS>
- Architecture: <layered | modular | microservice>
- Routes: <N> endpoints across <M> resources
- Middleware: <N> middleware in pipeline
- Workers: <configured | not needed>
- Production: Graceful shutdown, health checks, monitoring
- Audit: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:api — Design and document the API specification
-> /godmode:test — Write integration and unit tests
-> /godmode:deploy — Deploy with Docker, PM2, or Kubernetes
-> /godmode:observe — Set up logging, metrics, and tracing
```

Commit: `"node: <project> — <framework>, <N> routes, <architecture pattern>"`

## Key Behaviors

1. **Framework fits the need.** Express for speed-to-market, Fastify for performance, Hono for edge, NestJS for enterprise. Never over-engineer framework choice.
2. **Layers enforce boundaries.** Controllers parse HTTP, services contain logic, repositories abstract data. Each layer is testable in isolation.
3. **Middleware pipeline is deliberate.** Order matters. Auth before rate limiting? Rate limiting before auth? Design the pipeline intentionally.
4. **Streams for large data.** Never buffer an entire file, CSV, or database export in memory. Use streams and pipeline() for predictable memory usage.
5. **Worker threads for CPU work only.** Node.js excels at I/O. CPU-bound tasks go to worker threads. Do not block the event loop.
6. **Monitor the event loop.** Event loop lag is the canary in the coal mine. If p99 exceeds 100ms, you have a blocking operation to find and fix.
7. **Graceful shutdown is mandatory.** Every production Node.js server must handle SIGTERM, drain connections, close database pools, and exit cleanly.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Node.js backend workflow |
| `--audit` | Audit existing Node.js project |
| `--framework <name>` | Start with specific framework (express, fastify, hono, nestjs) |

## Auto-Detection

```
IF package.json contains "express" OR "fastify" OR "hono" OR "@nestjs/core" OR "koa":
  framework = detect_framework()
  version = package.json.dependencies[framework]
  SUGGEST "Node.js backend ({framework} {version}) detected. Activate /godmode:node?"

IF package.json has "type": "module" AND main entry is server.ts/server.js/index.ts:
  SUGGEST "Node.js server application detected. Activate /godmode:node?"

IF tsconfig.json has "module": "commonjs" AND code imports http/https/net:
  SUGGEST "Node.js server detected. Activate /godmode:node?"

IF Dockerfile contains "FROM node:" AND EXPOSE directive:
  port = parse EXPOSE port
  SUGGEST "Containerized Node.js server (port {port}) detected. Activate /godmode:node?"

IF directory contains src/routes/ OR src/controllers/ OR src/middleware/:
  SUGGEST "Node.js backend architecture detected. Activate /godmode:node?"

ON performance issue (event loop lag > 100ms OR memory > 85% heap):
  SUGGEST "Node.js performance issue detected. Run /godmode:node --perf?"
```

## Iterative API Build Protocol

```
WHEN building a Node.js API with multiple resources:

current_resource = 0
total_resources = len(api_resources)  # e.g., ["users", "posts", "comments"]
built_resources = []
production_checks = []

WHILE current_resource < total_resources:
  resource = api_resources[current_resource]

  1. CREATE route file (routes/{resource}.ts)
  2. CREATE controller ({resource}Controller.ts)
  3. CREATE service ({resource}Service.ts)
  4. CREATE repository ({resource}Repository.ts)
  5. CREATE validation schemas (Zod/Joi for request validation)
```

## HARD RULES

```
1. NEVER block the event loop. No synchronous file I/O, no CPU-heavy
   computation on the main thread, no JSON.parse of multi-MB payloads
   without a worker thread.

2. NEVER use console.log in production. Use a structured logger (pino)
   with log levels, request IDs, and JSON output.

3. EVERY production Node.js server MUST handle SIGTERM gracefully:
   stop accepting connections, drain in-flight requests, close DB pools.

4. NEVER buffer large files in memory. Use streams and pipeline()
   for files > 10MB. A 1GB upload with req.body crashes the process.

5. EVERY Map used as a cache MUST have a max size and TTL.
   Unbounded caches grow linearly with traffic until OOM.
```

## Output Format

End every Node skill invocation with this summary block:

```
NODE RESULT:
Action: <scaffold | endpoint | middleware | service | optimize | test | audit | upgrade>
Files created/modified: <N>
Endpoints created/modified: <N>
Framework: <Express | Fastify | Hono | Koa | NestJS | none>
Tests passing: <yes | no | skipped>
Build status: <passing | failing | not-checked>
Issues fixed: <N>
Notes: <one-line summary>
```

## TSV Logging

Append one TSV row to `.godmode/node.tsv` after each invocation:

```
timestamp	project	action	files_count	endpoints_count	framework	tests_status	build_status	notes
```

Field definitions:
- `timestamp`: ISO-8601 UTC
- `project`: directory name from `basename $(pwd)`
- `action`: scaffold | endpoint | middleware | service | optimize | test | audit | upgrade
- `files_count`: number of files created or modified
- `endpoints_count`: number of API endpoints created or modified
- `framework`: express | fastify | hono | koa | nestjs | none
- `tests_status`: passing | failing | skipped | none
- `build_status`: passing | failing | not-checked
- `notes`: free-text, max 120 chars, no tabs

If `.godmode/` does not exist, create it and add `.godmode/` to `.gitignore` if not already present.

## Success Criteria

Every Node skill invocation must pass ALL of these checks before reporting success:

1. `tsc --noEmit` passes (TypeScript projects) or linter passes (JavaScript projects)
2. `npm test` passes if test suite exists
3. No synchronous file I/O in request handlers (`readFileSync`, `writeFileSync`)
4. No `console.log` in production code (use structured logger: pino, winston)
5. Graceful shutdown handler exists (SIGTERM, SIGINT)
6. No unbounded in-memory caches (all Maps/objects used as cache have max size + TTL)
7. No unhandled promise rejections (global handler registered)
8. All streams use `pipeline()` instead of `.pipe()` for error handling
9. No blocking operations on the main thread (use worker_threads for CPU work)
10. Environment variables loaded via validated config (dotenv + joi/zod, not raw `process.env`)

If any check fails, fix it before reporting success. If a fix is not possible, document the reason in the Notes field.

## Keep/Discard Discipline
```
After EACH Node.js change (route, middleware, optimization):
  1. MEASURE: Run `tsc --noEmit` + `npm test` — does everything pass?
  2. COMPARE: Is event loop lag p99 stable or improved? Memory usage trending flat?
  3. DECIDE:
     - KEEP if: tests pass AND no sync I/O in request path AND no unbounded caches introduced
     - DISCARD if: tests fail OR event loop lag regresses OR memory leak detected
  4. COMMIT kept changes. Run `git reset --hard` on discarded changes before the next task.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All routes have validation, auth middleware, and error handling
  - Graceful shutdown handles SIGTERM with connection draining
  - Event loop lag p99 < 50ms under expected load
  - User explicitly requests stop

DO NOT STOP just because:
  - Worker thread optimization is not complete (only needed for CPU-bound tasks)
  - Dependency audit has unresolved low-severity advisories
```

## Node.js Optimization Loop

When optimizing an existing Node.js application, run this systematic audit loop. Each pass targets a specific performance dimension with measurable before/after metrics.

### Pass 1: Event Loop Lag Audit

```
EVENT LOOP LAG AUDIT:
  Step 1: Measure with monitorEventLoopDelay (node:perf_hooks).
    Log p50, p99, max every 10s. Alert if p99 > 100ms.

  Step 2: Identify blockers
    JSON.parse (large)     → streaming JSON parser
    JSON.stringify (large) → fast-json-stringify
    Regex on long strings  → re2 or bounded input
    Crypto (bcrypt)        → worker_threads
    Image/PDF processing   → worker_threads or queue
    Synchronous file I/O   → fs/promises
    DNS (first call)       → warm up on startup
    require() at runtime   → import at module top
    Large array sort       → stream-process or paginate

```

### Pass 2: Memory Leak Detection

```
MEMORY LEAK DETECTION:
  Step 1: Monitor process.memoryUsage() every 30s (rss, heapUsed, heapTotal, external).

  Step 2: Common leak patterns and fixes
    Growing Map/Set (unbounded)   → maxSize + LRU eviction
    Event listener accumulation    → removeListener in cleanup
    Closure over request objects   → nullify refs after use
    Global cache without TTL       → TTL + size limit
    Unresolved promises           → timeout on all promises
    Stream not consumed/destroyed → always pipeline() streams
    setInterval never cleared     → clearInterval on shutdown
    Database connection leak       → pool with max + idle timeout

  Step 3: Heap snapshot — trigger with SIGUSR2, load in Chrome DevTools Memory tab.
    Compare 2 snapshots taken 5min apart to find growing objects.

  Step 4: Cap memory with --max-old-space-size=512. Alert at 80% of limit.

  TARGETS: heap stable over 24h | no unbounded caches | all listeners cleaned up
```

### Pass 3: Cluster Mode & Process Tuning

```
CLUSTER/PROCESS TUNING:
  Scaling strategy:
    Kubernetes/ECS: single process per container, scale via replicas
    PM2 on VM: cluster mode (instances: 'max', max_memory_restart: '500M')
    Serverless: platform manages scaling

  V8 flags:
    --max-old-space-size=512    (cap heap; set to container limit - 128MB)
    --max-semi-space-size=64    (young gen; helps GC pauses)

  Connection pools:
    PostgreSQL: max=20, idleTimeout=30s, connectionTimeout=5s
    Redis: maxRetriesPerRequest=3, connectTimeout=5s, lazyConnect=true

  CHECKLIST:
  [ ] --max-old-space-size matches container memory limit
  [ ] Connection pools sized for worker count * max connections
  [ ] Graceful shutdown drains connections before exit
  [ ] /ready returns 503 during shutdown drain
  [ ] Process restarts automatically on OOM
```

### Pass 4: Dependency & Bundle Audit

```
DEPENDENCY AUDIT:
  Step 1: npx cost-of-modules (install size + load time per dependency)

  Step 2: Replace heavy packages
    moment.js (300KB)     → date-fns / dayjs (2-10KB)
    lodash (full, 70KB)   → lodash-es (tree-shakable)
    axios (30KB)          → undici / built-in fetch
    uuid (10KB)           → crypto.randomUUID() (0KB)
    validator.js (50KB)   → zod (12KB)
    winston (100KB)       → pino (15KB, 5x faster)
    body-parser           → built into Express 4.16+
    dotenv + manual parse → @t3-oss/env or zod schema

  Step 3: npm audit --production (zero high/critical in prod deps)

  Step 4: Startup time
    Measure: node --eval "const t=Date.now(); require('./dist/server'); console.log(Date.now()-t+'ms')"
    Lazy-import heavy modules. Precompile TS — never run ts-node in production.
```

### Optimization Loop Summary

```
NODE.JS OPTIMIZATION REPORT:
  Metric                       │  Before  │  After   │  Target
  Event loop lag p99 (ms)     │  <N>     │  <N>     │  < 50ms
  Heap usage trend (24h)      │  growing │  stable  │  Stable
  Unbounded caches             │  <N>     │  0       │  Zero
  Sync I/O in request path    │  <N>     │  0       │  Zero
  CPU work on main thread      │  <N>     │  0       │  Offloaded
  p95 response time (ms)      │  <N>     │  <N>     │  Improved
  npm audit vulnerabilities    │  <N>     │  0       │  Zero

VERDICT: <OPTIMIZED | NEEDS FURTHER WORK>
```


## Error Recovery
| Failure | Action |
|---------|--------|
| Memory leak in production | Use `--inspect` and Chrome DevTools heap snapshots. Check for uncleared event listeners, growing caches, and closures holding references. |
| Event loop blocked (high latency) | Profile with `clinic doctor`. Move CPU-intensive work to worker threads. Add async boundaries in hot loops. |
| Unhandled promise rejection crashes process | Add global `process.on('unhandledRejection')` handler. Find and fix the unhandled promise. Always `await` or `.catch()` promises. |
| Module resolution fails after upgrade | Clear `node_modules` and lockfile. Reinstall. Check for ESM/CJS compatibility. Verify `"type": "module"` in package.json matches import style. |
