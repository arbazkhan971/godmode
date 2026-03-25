---
name: node
description: Node.js backend development.
---

## Activate When
- `/godmode:node`, "Node.js backend", "REST API"
- "Express", "Fastify", "Hono", "NestJS"
- "middleware", "streams", "worker threads", "event loop"

## Workflow

### 1. Project Assessment
```
Type: REST API|GraphQL|real-time|microservice|CLI
Scale: <expected RPS, concurrent connections>
Framework: Express|Fastify|Hono|NestJS|none
Runtime: Node.js|Bun|Deno
Database: <PostgreSQL, MongoDB, Redis, etc.>
Deployment: Docker|serverless|PM2|Kubernetes
```

### 2. Framework Selection
```
| Framework | Best For | Perf | Ecosystem |
| Express | Rapid prototyping | ~15K RPS | Massive |
| Fastify | High-perf JSON APIs | ~50K RPS | Growing |
| Hono | Edge/serverless | ~80K RPS | Growing |
| NestJS | Enterprise, DI | ~15K RPS | Large |
```
```bash
# Detect existing framework
cat package.json | grep -E "express|fastify|hono|nestjs"
```
IF < 1K RPS expected: Express is fine.
IF > 10K RPS needed: prefer Fastify or Hono.
IF enterprise with DI: NestJS.

### 3. Application Architecture
```
src/
├── server.ts        # Bootstrap, graceful shutdown
├── app.ts           # App instance, global middleware
├── config/          # Env vars, DB config, logger
├── middleware/       # Auth, validate, rateLimit, errors
├── routes/          # Route definitions
├── controllers/     # Request parsing, response
├── services/        # Business logic
├── repositories/    # Data access
└── utils/           # Shared helpers
```

### 4. Middleware Pipeline
```
Order matters — design deliberately:
1. requestId()     # Unique request ID
2. logger()        # Log incoming request
3. cors()          # CORS headers
4. helmet()        # Security headers
5. rateLimit()     # Rate limiting
6. auth()          # Authentication
7. compress()      # Response compression
--- Routes execute here ---
8. notFoundHandler # 404
9. errorHandler    # Global errors (ALWAYS last)
```

### 5. Streams and Workers
```
Streams: use pipeline() for files > 10MB.
  Never buffer entire file in memory.
Workers: use for CPU-bound tasks only
  (image processing, PDF, heavy computation).
  Pool size: max(1, cpus() - 1).
```
IF file upload > 10MB: stream to disk, never buffer.
IF CPU task > 100ms: offload to worker thread.

### 6. Production Hardening
```
[ ] Graceful shutdown (SIGTERM handler)
[ ] Health check (/health, /ready)
[ ] Structured logging (pino, not console.log)
[ ] Request ID propagation
[ ] Global error handler
[ ] Unhandled rejection handlers
[ ] Rate limiting
[ ] CORS configured
[ ] Helmet security headers
[ ] Request body size limits (1MB default)
[ ] Connection pooling (DB, HTTP clients)
[ ] Env vars via validated config (zod/joi)
```

## Hard Rules
1. NEVER block the event loop. No sync I/O,
   no CPU-heavy on main thread.
2. NEVER console.log in production. Use pino.
3. EVERY server MUST handle SIGTERM gracefully.
4. NEVER buffer large files. Use pipeline().
5. EVERY Map cache MUST have max size + TTL.

## TSV Logging
Append `.godmode/node.tsv`:
```
timestamp	action	files	endpoints	framework	tests	status
```

## Keep/Discard
```
KEEP if: tests pass AND no sync I/O in request path
  AND no unbounded caches.
DISCARD if: tests fail OR event loop lag regresses
  OR memory leak detected.
```

## Stop Conditions
```
STOP when FIRST of:
  - All routes have validation + auth + error handling
  - Graceful shutdown with connection draining
  - Event loop p99 < 50ms under load
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Memory leak | --inspect + heap snapshots, check listeners |
| Event loop blocked | clinic doctor, move CPU to workers |
| Unhandled rejection | Add global handler, find the promise |
| Module resolution | Clear node_modules, check ESM/CJS |
