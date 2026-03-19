# /godmode:node

Build production-grade Node.js backends. Covers framework selection (Express, Fastify, Hono, NestJS), middleware design, stream processing, worker threads, cluster mode, memory management, and event loop optimization.

## Usage

```
/godmode:node                              # Full Node.js backend workflow
/godmode:node --audit                      # Audit existing Node.js project
/godmode:node --framework express          # Start with Express
/godmode:node --framework fastify          # Start with Fastify
/godmode:node --framework hono             # Start with Hono
/godmode:node --framework nestjs           # Start with NestJS
/godmode:node --middleware                  # Design middleware pipeline
/godmode:node --streams                    # Design stream processing pipeline
/godmode:node --workers                    # Configure worker threads or cluster
/godmode:node --perf                       # Performance audit (event loop, memory, GC)
/godmode:node --production                 # Production hardening checklist
/godmode:node --migrate express fastify    # Migrate between frameworks
```

## What It Does

1. Assesses project requirements (type, scale, framework, runtime, deployment)
2. Selects framework based on project needs (Express, Fastify, Hono, NestJS)
3. Designs application architecture (layered, modular, or microservice)
4. Designs middleware pipeline with proper ordering and composition
5. Configures stream processing for large data handling
6. Sets up worker threads for CPU-bound tasks and cluster mode for scaling
7. Optimizes memory management and event loop performance
8. Applies production hardening (graceful shutdown, health checks, monitoring)
9. Validates against Node.js best practices (16-point audit)
10. Generates application structure and configuration

## Output
- Framework selection with performance rationale
- Application directory structure with layered architecture
- Middleware pipeline with ordering and composition patterns
- Worker thread pool and/or cluster configuration
- Production readiness checklist with PASS/NEEDS REVISION verdict
- Commit: `"node: <project> — <framework>, <N> routes, <architecture pattern>"`

## Next Step
After Node.js backend: `/godmode:api` to document the API, `/godmode:test` for integration tests, or `/godmode:deploy` for Docker/Kubernetes deployment.

## Examples

```
/godmode:node Build a REST API for inventory management with barcode scanning
/godmode:node --framework fastify High-performance JSON API for real-time analytics
/godmode:node --streams Design a CSV import pipeline that handles 10GB files
/godmode:node --perf Our API response times spike every few minutes
/godmode:node --production Prepare our Express app for production deployment
```
