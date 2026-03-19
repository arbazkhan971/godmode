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
├───────────┼─────────────────────────────┼───────────┼────────────┼─────────┤
│ NestJS    │ Enterprise, large teams     │ Moderate  │ Large      │ High    │
│           │ Microservices, DDD          │ ~15K RPS* │ 500+ pkgs  │         │
│           │ Angular-style architecture  │ *Express  │            │         │
│           │                             │ or Fastify│            │         │
└───────────┴─────────────────────────────┴───────────┴────────────┴─────────┘
* NestJS performance depends on underlying adapter (Express or Fastify)

DECISION FLOW:
1. Need enterprise structure + DI + decorators? → NestJS
2. Need maximum performance + JSON validation? → Fastify
3. Need edge/serverless + multi-runtime? → Hono
4. Need rapid prototyping + huge ecosystem? → Express
5. Need microservice communication? → NestJS (built-in transport layers)
6. Need WebSocket + REST in one? → Fastify (with @fastify/websocket) or Hono
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
│   ├── requestId.ts       # Request ID injection
│   └── cors.ts            # CORS configuration
├── routes/
│   ├── index.ts           # Route registration
│   ├── users.ts           # /api/users routes
│   ├── posts.ts           # /api/posts routes
│   └── health.ts          # /health and /ready endpoints
├── controllers/
│   ├── userController.ts  # Request handling, response formatting
│   └── postController.ts  # Delegates to services
├── services/
│   ├── userService.ts     # Business logic, orchestration
│   └── postService.ts     # No HTTP awareness
├── repositories/
│   ├── userRepository.ts  # Database queries (Prisma, Drizzle, Knex)
│   └── postRepository.ts  # Data access abstraction
├── models/
│   ├── user.ts            # Type definitions, Zod schemas
│   └── post.ts            # Validation schemas
├── utils/
│   ├── errors.ts          # Custom error classes
│   ├── pagination.ts      # Pagination helpers
│   └── crypto.ts          # Hashing, encryption utilities
└── types/
    └── index.ts           # Shared TypeScript types

NestJS — Module Architecture:
src/
├── main.ts                # Bootstrap, global pipes, interceptors
├── app.module.ts          # Root module
├── common/
│   ├── decorators/        # Custom decorators (@CurrentUser, @Roles)
│   ├── filters/           # Exception filters
│   ├── guards/            # Auth guards, role guards
│   ├── interceptors/      # Logging, transform, cache interceptors
│   ├── pipes/             # Validation pipes
│   └── middleware/         # HTTP middleware
├── config/
│   └── config.module.ts   # @nestjs/config with Joi validation
├── auth/
│   ├── auth.module.ts
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── strategies/        # Passport strategies (JWT, local, OAuth)
│   └── guards/            # JwtAuthGuard, RolesGuard
├── users/
│   ├── users.module.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── users.repository.ts
│   ├── dto/               # CreateUserDto, UpdateUserDto
│   ├── entities/          # User entity (TypeORM/Prisma)
│   └── users.spec.ts      # Unit tests
├── posts/
│   ├── posts.module.ts
│   ├── posts.controller.ts
│   ├── posts.service.ts
│   └── dto/
└── database/
    ├── database.module.ts
    └── migrations/

LAYER RULES:
- Controllers handle HTTP (request parsing, response formatting)
- Services contain business logic (no HTTP awareness)
- Repositories abstract data access (swappable storage)
- Each layer only depends on the layer below it
- NEVER import controllers from services or repositories from controllers
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
  app.use(errorHandler)          // 9. Global error handler (MUST be last)

Pattern 2 — Composable Middleware (functional):
  // Higher-order middleware for reusability
  function requireRole(...roles: string[]) {
    return (req: Request, res: Response, next: NextFunction) => {
      if (!req.user) return res.status(401).json({ error: 'Unauthorized' })
      if (!roles.includes(req.user.role)) {
        return res.status(403).json({ error: 'Forbidden' })
      }
      next()
    }
  }

  // Compose multiple middleware
  function compose(...middlewares: Middleware[]) {
    return (req: Request, res: Response, next: NextFunction) => {
      const run = (i: number): void => {
        if (i >= middlewares.length) return next()
        middlewares[i](req, res, (err) => {
          if (err) return next(err)
          run(i + 1)
        })
      }
      run(0)
    }
  }

  // Usage:
  router.delete('/users/:id',
    compose(requireAuth, requireRole('admin'), validateParams(idSchema)),
    userController.delete
  )

Pattern 3 — Fastify Hooks (lifecycle-based):
  // Fastify uses hooks instead of middleware
  fastify.addHook('onRequest', async (request, reply) => {
    request.startTime = performance.now()
  })

  fastify.addHook('preValidation', async (request, reply) => {
    await verifyAuth(request)      // Auth before validation
  })

  fastify.addHook('preHandler', async (request, reply) => {
    await checkRateLimit(request)  // Rate limit before handler
  })

  fastify.addHook('onSend', async (request, reply, payload) => {
    reply.header('X-Request-Id', request.id)
    return payload
  })

  fastify.addHook('onResponse', async (request, reply) => {
    const duration = performance.now() - request.startTime
    log.info({ duration, status: reply.statusCode, url: request.url })
  })

Pattern 4 — Hono Middleware (Web Standard):
  import { Hono } from 'hono'
  import { cors } from 'hono/cors'
  import { logger } from 'hono/logger'
  import { jwt } from 'hono/jwt'

  const app = new Hono()
  app.use('*', logger())
  app.use('*', cors())
  app.use('/api/*', jwt({ secret: process.env.JWT_SECRET }))

  // Custom middleware
  app.use('*', async (c, next) => {
    const start = Date.now()
    await next()
    const duration = Date.now() - start
    c.header('X-Response-Time', `${duration}ms`)
  })

Pattern 5 — NestJS Guards, Interceptors, Pipes:
  // Guard — controls access
  @Injectable()
  class RolesGuard implements CanActivate {
    canActivate(context: ExecutionContext): boolean {
      const roles = this.reflector.get<string[]>('roles', context.getHandler())
      const request = context.switchToHttp().getRequest()
      return roles.includes(request.user.role)
    }
  }

  // Interceptor — transforms request/response
  @Injectable()
  class LoggingInterceptor implements NestInterceptor {
    intercept(context: ExecutionContext, next: CallHandler) {
      const now = Date.now()
      return next.handle().pipe(
        tap(() => console.log(`${Date.now() - now}ms`))
      )
    }
  }

  // Pipe — validates/transforms input
  @Injectable()
  class ZodValidationPipe implements PipeTransform {
    constructor(private schema: ZodSchema) {}
    transform(value: unknown) {
      return this.schema.parse(value)
    }
  }

ERROR HANDLING MIDDLEWARE:
  // Global error handler — MUST be last middleware
  function errorHandler(err: Error, req: Request, res: Response, next: NextFunction) {
    // Known operational errors
    if (err instanceof AppError) {
      return res.status(err.statusCode).json({
        error: { code: err.code, message: err.message }
      })
    }

    // Validation errors (Zod, Joi)
    if (err instanceof ZodError) {
      return res.status(400).json({
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid request',
          details: err.issues
        }
      })
    }

    // Unknown errors — log and return generic message
    logger.error({ err, requestId: req.id }, 'Unhandled error')
    return res.status(500).json({
      error: { code: 'INTERNAL_ERROR', message: 'Internal server error' }
    })
  }
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
  })

Pattern 2 — CSV processing with Transform streams:
  import { Transform } from 'stream'

  class CSVParser extends Transform {
    private buffer = ''
    private headers: string[] = []

    _transform(chunk: Buffer, encoding: string, callback: Function) {
      this.buffer += chunk.toString()
      const lines = this.buffer.split('\n')
      this.buffer = lines.pop() || ''  // Keep incomplete line

      for (const line of lines) {
        const values = line.split(',')
        if (!this.headers.length) {
          this.headers = values
          continue
        }
        const obj = Object.fromEntries(
          this.headers.map((h, i) => [h, values[i]])
        )
        this.push(JSON.stringify(obj) + '\n')
      }
      callback()
    }

    _flush(callback: Function) {
      if (this.buffer) {
        // Process remaining data
      }
      callback()
    }
  }

Pattern 3 — Database streaming for large exports:
  app.get('/export/users', async (req, res) => {
    res.setHeader('Content-Type', 'application/x-ndjson')
    res.setHeader('Transfer-Encoding', 'chunked')

    const cursor = db.user.findMany({
      cursor: true,    // Prisma cursor-based pagination
      take: 1000,
    })

    for await (const batch of cursor) {
      for (const user of batch) {
        res.write(JSON.stringify(user) + '\n')
      }
    }
    res.end()
  })

Pattern 4 — Async iterables (modern Node.js):
  import { Readable } from 'stream'

  // Convert async generator to readable stream
  async function* generateReport(params) {
    const header = 'id,name,email\n'
    yield header

    let cursor = null
    do {
      const batch = await db.user.findMany({
        take: 100,
        cursor: cursor ? { id: cursor } : undefined,
      })
      for (const user of batch) {
        yield `${user.id},${user.name},${user.email}\n`
      }
      cursor = batch.at(-1)?.id
    } while (cursor)
  }

  app.get('/report', (req, res) => {
    res.setHeader('Content-Type', 'text/csv')
    Readable.from(generateReport(req.query)).pipe(res)
  })

STREAM RULES:
- ALWAYS use streams for files > 10MB — never buffer entirely in memory
- Use pipeline() over .pipe() — handles errors and cleanup automatically
- Set highWaterMark to control memory usage (default 16KB for streams)
- Use stream/promises for async/await compatibility
- Backpressure is handled automatically by pipeline() — respect it
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
  private queue: Array<{ data: any; resolve: Function; reject: Function }> = []
  private available: Worker[] = []

  constructor(private workerPath: string, size = cpus().length - 1) {
    for (let i = 0; i < size; i++) {
      const worker = new Worker(workerPath)
      worker.on('message', (result) => {
        const task = worker.__currentTask
        task.resolve(result)
        this.available.push(worker)
        this.processQueue()
      })
      worker.on('error', (err) => {
        const task = worker.__currentTask
        task.reject(err)
        // Replace dead worker
        const replacement = new Worker(workerPath)
        this.workers[this.workers.indexOf(worker)] = replacement
        this.available.push(replacement)
      })
      this.workers.push(worker)
      this.available.push(worker)
    }
  }

  async execute<T>(data: any): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push({ data, resolve, reject })
      this.processQueue()
    })
  }

  private processQueue() {
    while (this.queue.length > 0 && this.available.length > 0) {
      const worker = this.available.pop()!
      const task = this.queue.shift()!
      worker.__currentTask = task
      worker.postMessage(task.data)
    }
  }

  async shutdown() {
    await Promise.all(this.workers.map(w => w.terminate()))
  }
}

// image-worker.ts — Worker script
import { parentPort } from 'worker_threads'
import sharp from 'sharp'

parentPort?.on('message', async ({ buffer, width, height, format }) => {
  const result = await sharp(buffer)
    .resize(width, height)
    .toFormat(format)
    .toBuffer()
  parentPort?.postMessage(result)
})

// Usage in route handler:
const imagePool = new WorkerPool('./image-worker.js', 4)

app.post('/resize', async (req, res) => {
  const result = await imagePool.execute({
    buffer: req.body,
    width: 800,
    height: 600,
    format: 'webp'
  })
  res.type('image/webp').send(result)
})


CLUSTER MODE — Multi-Process Scaling:

// cluster.ts — Production process management
import cluster from 'cluster'
import { cpus } from 'os'

if (cluster.isPrimary) {
  const numWorkers = parseInt(process.env.WEB_CONCURRENCY || '') || cpus().length

  console.log(`Primary ${process.pid} starting ${numWorkers} workers`)

  for (let i = 0; i < numWorkers; i++) {
    cluster.fork()
  }

  cluster.on('exit', (worker, code, signal) => {
    console.error(`Worker ${worker.process.pid} died (${signal || code})`)
    if (code !== 0) {
      console.log('Starting replacement worker...')
      cluster.fork()   // Auto-restart crashed workers
    }
  })

  // Graceful shutdown
  process.on('SIGTERM', () => {
    for (const worker of Object.values(cluster.workers!)) {
      worker?.send('shutdown')
    }
  })
} else {
  // Worker process — run the actual server
  import('./server.js')
}

DECISION: Worker Threads vs Cluster vs External:
┌────────────────────────────────────────────────────────────────────┐
│ Need                          │ Solution                           │
├───────────────────────────────┼────────────────────────────────────┤
│ CPU-bound task in request     │ Worker thread pool                 │
│ Multi-core HTTP scaling       │ Cluster mode (or PM2)              │
│ Background job processing     │ BullMQ + Redis (separate process)  │
│ Long-running computation      │ Separate service / serverless fn   │
│ Real-time + computation       │ Worker threads for compute,        │
│                               │ main thread for I/O                │
└───────────────────────────────┴────────────────────────────────────┘

RULE: Node.js is single-threaded for I/O — that is its strength.
      Use worker threads ONLY for CPU-bound work.
      Use cluster mode OR a process manager (PM2) for horizontal scaling.
      Use BullMQ for background jobs that should survive restarts.
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
    const { heapUsed, heapTotal, rss, external } = process.memoryUsage()
    metrics.gauge('node.heap.used', heapUsed)
    metrics.gauge('node.heap.total', heapTotal)
    metrics.gauge('node.rss', rss)
    metrics.gauge('node.external', external)

    // Alert on growth
    if (heapUsed / heapTotal > 0.85) {
      logger.warn('Heap usage above 85%', { heapUsed, heapTotal })
    }
  }, 30_000)

2. Common memory leak sources and fixes:
  // LEAK: Unbounded caches
  const cache = new Map()  // Grows forever!
  // FIX: Use LRU cache with max size
  import { LRUCache } from 'lru-cache'
  const cache = new LRUCache({ max: 1000, ttl: 1000 * 60 * 5 })

  // LEAK: Event listeners not removed
  socket.on('data', handler)  // Added on every connection, never removed
  // FIX: Remove on disconnect
  socket.on('close', () => socket.removeListener('data', handler))

  // LEAK: Closures holding references
  function createHandler(hugeData) {
    return (req, res) => {
      // hugeData is retained even if only a small part is used
      res.json({ count: hugeData.length })
    }
  }
  // FIX: Extract only what you need
  function createHandler(hugeData) {
    const count = hugeData.length  // Extract the value
    return (req, res) => res.json({ count })
  }

  // LEAK: Global error handlers accumulating references
  // LEAK: Unfinished promises / abandoned async operations
  // LEAK: Large buffers kept in scope

3. Garbage collection tuning:
  // Increase old space for large heaps
  node --max-old-space-size=4096 server.js

  // Monitor GC pauses
  const { PerformanceObserver } = require('perf_hooks')
  const obs = new PerformanceObserver((list) => {
    for (const entry of list.getEntries()) {
      if (entry.duration > 100) {
        logger.warn(`Long GC pause: ${entry.duration}ms`, {
          kind: entry.detail?.kind
        })
      }
    }
  })
  obs.observe({ entryTypes: ['gc'] })

EVENT LOOP OPTIMIZATION:

1. Never block the event loop:
  // BAD: Synchronous file read in request handler
  app.get('/config', (req, res) => {
    const data = fs.readFileSync('/etc/config.json')  // BLOCKS
    res.json(JSON.parse(data))
  })
  // GOOD: Async read
  app.get('/config', async (req, res) => {
    const data = await fs.promises.readFile('/etc/config.json')
    res.json(JSON.parse(data))
  })

  // BAD: JSON.parse of huge payload on main thread
  // GOOD: Use worker thread for large JSON parsing

2. Monitor event loop lag:
  import { monitorEventLoopDelay } from 'perf_hooks'

  const histogram = monitorEventLoopDelay({ resolution: 20 })
  histogram.enable()

  setInterval(() => {
    metrics.gauge('node.eventloop.p50', histogram.percentile(50) / 1e6)
    metrics.gauge('node.eventloop.p99', histogram.percentile(99) / 1e6)
    metrics.gauge('node.eventloop.max', histogram.max / 1e6)
    histogram.reset()

    // Alert if event loop is consistently slow
    if (histogram.percentile(99) / 1e6 > 100) {
      logger.warn('Event loop lag >100ms at p99')
    }
  }, 10_000)

3. Batch operations to reduce event loop pressure:
  // BAD: Individual database calls in a loop
  for (const id of ids) {
    await db.user.update({ where: { id }, data: { active: false } })
  }
  // GOOD: Batch operation
  await db.user.updateMany({
    where: { id: { in: ids } },
    data: { active: false }
  })

  // BAD: setImmediate/setTimeout for each item
  // GOOD: Process in batches, yield control periodically
  async function processBatch(items, batchSize = 100) {
    for (let i = 0; i < items.length; i += batchSize) {
      const batch = items.slice(i, i + batchSize)
      await Promise.all(batch.map(processItem))
      // Yield to event loop between batches
      await new Promise(resolve => setImmediate(resolve))
    }
  }
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
│  Timeout on all external calls                 │  PASS | FAIL        │
│  Memory leak monitoring                        │  PASS | FAIL        │
│  Event loop lag monitoring                     │  PASS | FAIL        │
│  Process manager configured (PM2, cluster)     │  PASS | FAIL        │
│  Secrets from env vars, not config files       │  PASS | FAIL        │
└────────────────────────────────────────────────┴─────────────────────┘

GRACEFUL SHUTDOWN TEMPLATE:
  const server = app.listen(port)
  const connections = new Set<Socket>()

  server.on('connection', (conn) => {
    connections.add(conn)
    conn.on('close', () => connections.delete(conn))
  })

  async function shutdown(signal: string) {
    logger.info(`${signal} received, starting graceful shutdown`)

    // Stop accepting new connections
    server.close()

    // Close existing connections after a grace period
    setTimeout(() => {
      connections.forEach(conn => conn.destroy())
    }, 10_000)

    // Close database connections
    await db.$disconnect()
    await redis.quit()

    logger.info('Shutdown complete')
    process.exit(0)
  }

  process.on('SIGTERM', () => shutdown('SIGTERM'))
  process.on('SIGINT', () => shutdown('SIGINT'))

  // Catch unhandled errors (log, don't crash silently)
  process.on('unhandledRejection', (reason) => {
    logger.fatal({ reason }, 'Unhandled rejection')
    shutdown('unhandledRejection')
  })

  process.on('uncaughtException', (error) => {
    logger.fatal({ error }, 'Uncaught exception')
    shutdown('uncaughtException')
  })
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

## Example Usage

### Building a new API
```
User: /godmode:node Build a REST API for an inventory management system

NODE: Starting project assessment...

ASSESSMENT:
Project: Inventory management API
Framework: Fastify (JSON-heavy, needs performance for barcode scanning)
Database: PostgreSQL with Prisma ORM
Auth: JWT with API key support for warehouse scanners
Scale: ~5000 RPS peak during receiving

ARCHITECTURE:
src/
├── server.ts          # Fastify bootstrap with graceful shutdown
├── routes/
│   ├── products.ts    # CRUD + search + barcode lookup
│   ├── inventory.ts   # Stock levels, adjustments, transfers
│   ├── warehouses.ts  # Warehouse management
│   └── reports.ts     # Inventory reports (streaming CSV export)
├── services/
│   ├── inventoryService.ts   # Stock calculation, low-stock alerts
│   └── barcodeService.ts     # Barcode generation/lookup
...

Middleware pipeline:
1. requestId → 2. logger → 3. cors → 4. rateLimit → 5. auth → 6. validate
```

### Diagnosing performance issues
```
User: /godmode:node Our API response times spike to 2s every few minutes

NODE: Analyzing potential causes...

INVESTIGATION:
1. Event loop lag monitoring shows p99 spikes to 1800ms
2. GC pauses show major GC events of 500ms every 3 minutes
3. Heap usage graph shows sawtooth pattern (classic memory pressure)

ROOT CAUSE: Unbounded in-memory cache growing to 500MB, triggering
full garbage collection pauses.

FIX:
1. Replace Map cache with LRU cache (max 10,000 entries, 5min TTL)
2. Move hot data to Redis for shared caching across cluster
3. Add event loop lag metric to dashboards
4. Set --max-old-space-size=2048 to fail fast instead of GC-thrashing
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Node.js backend workflow |
| `--audit` | Audit existing Node.js project |
| `--framework <name>` | Start with specific framework (express, fastify, hono, nestjs) |
| `--middleware` | Design middleware pipeline only |
| `--streams` | Design stream processing pipeline |
| `--workers` | Configure worker threads or cluster mode |
| `--perf` | Performance audit (event loop, memory, GC) |
| `--production` | Production hardening checklist |
| `--migrate <from> <to>` | Migrate between frameworks (e.g., express to fastify) |

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
  6. WIRE middleware chain:
     auth -> validate -> rateLimit -> controller
  7. VERIFY layer boundaries:
     - Controller has NO database queries
     - Service has NO HTTP awareness (no req/res)
     - Repository has NO business logic

  IF boundary_violation_found:
    FIX violation before proceeding
    CONTINUE

  built_resources.append(resource)
  current_resource += 1

  IF current_resource % 3 == 0:
    REPORT "{current_resource}/{total_resources} resources built"
    RUN integration tests for built resources

FINAL:
  RUN production hardening checklist
  VERIFY: graceful shutdown, health checks, structured logging,
          error handling, rate limiting, security headers
  REPORT endpoint count and production readiness status
```

## Multi-Agent Dispatch

```
WHEN building a full Node.js backend with multiple concerns:

DISPATCH parallel agents in worktrees:

  Agent 1 (api-routes):
    - Implement route handlers for all resources
    - Configure request validation (Zod schemas)
    - Wire middleware chain
    - Output: src/routes/ + src/controllers/

  Agent 2 (business-logic):
    - Implement service layer with business rules
    - Implement repository layer with database queries
    - Output: src/services/ + src/repositories/

  Agent 3 (middleware-infra):
    - Implement auth middleware (JWT/session)
    - Implement rate limiting, CORS, security headers
    - Implement global error handler
    - Implement graceful shutdown
    - Output: src/middleware/ + src/server.ts

  Agent 4 (performance):
    - Configure worker threads for CPU-bound tasks
    - Implement stream processing for large data
    - Set up memory and event loop monitoring
    - Output: src/workers/ + src/utils/monitoring.ts

MERGE:
  - Verify routes use middleware from Agent 3
  - Verify controllers call services from Agent 2
  - Verify CPU-bound operations use workers from Agent 4
  - Run full integration test suite
  - Run production hardening checklist
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

6. Controllers handle HTTP. Services contain logic. Repositories abstract data.
   NEVER mix these concerns. No database queries in controllers.
   No req/res objects in services.

7. EVERY external HTTP call MUST have a timeout.
   Default: 5s for APIs, 30s for file downloads. Never wait forever.

8. NEVER use cluster.fork() inside containers.
   Let the orchestrator (Kubernetes, ECS) handle scaling.
   One process per container.
```

## Anti-Patterns

- **Do NOT block the event loop.** No synchronous file I/O, no CPU-heavy computation on the main thread, no `JSON.parse` of multi-MB payloads without a worker. The event loop is sacred.
- **Do NOT use `console.log` in production.** Use a structured logger (pino, winston) with log levels, request IDs, and JSON output for log aggregation.
- **Do NOT skip graceful shutdown.** Without it, in-flight requests are killed during deploys, database connections leak, and data can be corrupted.
- **Do NOT buffer large files in memory.** A 1GB upload with `req.body` will crash the process. Use streams and pipeline().
- **Do NOT create unbounded caches.** Every `Map` used as a cache must have a max size and TTL. Memory grows linearly with traffic without bounds.
- **Do NOT ignore unhandled rejections.** Unhandled promise rejections are ticking time bombs. Log them, then shut down gracefully.
- **Do NOT use `cluster.fork()` in containers.** Containers should run one process — let the orchestrator (Kubernetes, ECS) handle scaling. Use cluster mode only for bare-metal or VM deployments.
- **Do NOT mix business logic into controllers.** Controllers parse HTTP. Services contain logic. Mixing them makes testing impossible and creates coupling.
