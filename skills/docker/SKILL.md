---
name: docker
description: |
  Docker mastery skill. Activates when user needs to create, optimize, or troubleshoot Docker configurations. Covers Dockerfile best practices (multi-stage builds, layer caching, minimal images), Docker Compose for local development, image size optimization, security scanning (Trivy, Snyk), networking, volumes, BuildKit features, and build arguments. Triggers on: /godmode:docker, "Dockerfile", "docker compose", "container image", "multi-stage build", "image size", "docker security", or when containerizing an application.
---

# Docker — Docker Mastery

## When to Activate
- User invokes `/godmode:docker`
- User says "Dockerfile", "docker compose", "container image", "multi-stage build"
- User says "image size", "docker security", "container optimization"
- User needs to containerize an application for the first time
- User wants to optimize an existing Docker setup
- User needs local development environment with Docker Compose
- Pre-ship check identifies Docker configuration issues
- Godmode orchestrator detects Dockerfile anti-patterns during `/godmode:review`

## Workflow

### Step 1: Assess Docker Context
Understand the project and its containerization needs:

```
DOCKER CONTEXT ASSESSMENT:
Project:
  Language/Runtime: <Node.js | Python | Go | Java | Rust | multi-language>
  Framework: <Express | Django | Spring | etc.>
  Build system: <npm | pip | gradle | cargo | make>
  Entry point: <main file or command>

Current Docker state:
  Dockerfile: <exists | missing | multiple>
  Docker Compose: <exists | missing>
  .dockerignore: <exists | missing | incomplete>
  Base image: <image:tag>
  Image size: <current size>
  Build time: <current build time>
  Layers: <number of layers>
  Security scan: <clean | N vulnerabilities>

Environment:
  Local dev: <Docker Compose | devcontainer | manual>
  CI/CD: <GitHub Actions | GitLab CI | Jenkins | none>
  Registry: <Docker Hub | ECR | GCR | ACR | GHCR>
  Orchestration: <Kubernetes | ECS | Compose | Swarm | none>

Target:
  Production readiness: <development | staging | production>
  Size target: << 100MB | < 500MB | minimize>
  Security requirements: <standard | strict (no CVEs) | compliance>
```

### Step 2: Dockerfile Best Practices
Create or optimize the Dockerfile using production-grade patterns:

#### Multi-Stage Build Pattern
```dockerfile
# ============================================================
# Stage 1: Dependencies (cached separately from source code)
# ============================================================
FROM node:20-alpine AS deps
WORKDIR /app

# Copy only dependency files first (layer caching)
COPY package.json package-lock.json ./
RUN npm ci --only=production

# ============================================================
# Stage 2: Build (compile/transpile source code)
# ============================================================
FROM node:20-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ============================================================
# Stage 3: Production (minimal runtime image)
# ============================================================
FROM node:20-alpine AS production
WORKDIR /app

# Security: run as non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Copy only production artifacts
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY package.json ./

# Security: drop all capabilities, run as non-root
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

#### Layer Caching Strategy
```
LAYER CACHING RULES:
┌─────────────────────────────────────────────────────────────┐
│ Rule                          │ Why                          │
├───────────────────────────────┼──────────────────────────────┤
│ COPY dependency files first   │ Dependencies change less     │
│                               │ often than source code       │
│ RUN install BEFORE COPY src   │ Bust cache only when deps    │
│                               │ actually change              │
│ Order instructions by change  │ Least-changing layers first, │
│ frequency                     │ most-changing layers last     │
│ Combine related RUN commands  │ Fewer layers, smaller image  │
│ Use .dockerignore             │ Exclude node_modules, .git,  │
│                               │ test files from build context│
└───────────────────────────────┴──────────────────────────────┘

CACHE INVALIDATION ORDER (top = rarely changes, bottom = changes often):
  1. Base image (FROM)
  2. System packages (RUN apt-get / apk add)
  3. Dependency files (COPY package.json)
  4. Dependency install (RUN npm ci)
  5. Source code (COPY . .)
  6. Build step (RUN npm run build)
  7. Runtime configuration (ENV, CMD)
```

#### Language-Specific Patterns

```
MULTI-STAGE BUILD BY LANGUAGE:
┌──────────┬─────────────────────┬─────────────────┬───────────┐
│ Language │ Build Image         │ Runtime Image    │ Size      │
├──────────┼─────────────────────┼─────────────────┼───────────┤
│ Node.js  │ node:20-alpine      │ node:20-alpine   │ ~120MB    │
│ Python   │ python:3.12-slim    │ python:3.12-slim │ ~150MB    │
│ Go       │ golang:1.22-alpine  │ scratch/distroless│ ~10MB    │
│ Rust     │ rust:1.77-alpine    │ scratch/distroless│ ~5MB     │
│ Java     │ eclipse-temurin:21  │ eclipse-temurin:  │ ~200MB   │
│          │                     │ 21-jre-alpine    │           │
│ .NET     │ mcr.microsoft.com/  │ mcr.microsoft.com│ ~100MB   │
│          │ dotnet/sdk:8.0      │ /dotnet/aspnet:  │           │
│          │                     │ 8.0-alpine       │           │
└──────────┴─────────────────────┴─────────────────┴───────────┘

DISTROLESS vs ALPINE vs SCRATCH:
  scratch:     Empty image. Only for statically compiled binaries (Go, Rust).
               No shell, no package manager, no debugging tools.
  distroless:  Google's minimal images. No shell, no package manager.
               Includes only runtime (libc, ca-certs, timezone data).
  alpine:      Minimal Linux with musl libc. ~5MB base. Has shell + apk.
               Good balance of size and debuggability.
  slim:        Debian-based, stripped down. ~80MB base. Has shell + apt.
               Use when alpine causes musl compatibility issues.
```

### Step 3: Docker Compose for Local Development
Set up a complete local development environment:

```yaml
# docker-compose.yml — Local development
version: "3.9"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: development          # Multi-stage: use dev stage
      args:
        NODE_ENV: development
    ports:
      - "3000:3000"
      - "9229:9229"               # Node.js debugger
    volumes:
      - .:/app                    # Bind mount for hot reload
      - /app/node_modules         # Anonymous volume: don't overwrite
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://user:pass@db:5432/appdb
      - REDIS_URL=redis://cache:6379
    depends_on:
      db:
        condition: service_healthy
      cache:
        condition: service_healthy
    command: npm run dev           # Override production CMD

  db:
    image: postgres:16-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: appdb
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d appdb"]
      interval: 5s
      timeout: 3s
      retries: 5

  cache:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redisdata:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5

volumes:
  pgdata:
  redisdata:
```

```
DOCKER COMPOSE PATTERNS:
┌─────────────────────────────────────────────────────────────┐
│ Pattern               │ Purpose                              │
├───────────────────────┼──────────────────────────────────────┤
│ depends_on + health   │ Start order with readiness check     │
│ target: development   │ Use dev stage of multi-stage build   │
│ bind mount + anon vol │ Hot reload without overwriting deps  │
│ named volumes         │ Persist data across restarts         │
│ init scripts          │ Seed database on first start         │
│ profiles              │ Optional services (monitoring, etc.) │
│ env_file              │ Keep secrets out of compose file     │
│ networks              │ Isolate service communication        │
└───────────────────────┴──────────────────────────────────────┘

COMPOSE PROFILES (optional services):
  docker compose --profile monitoring up    # Include Prometheus, Grafana
  docker compose --profile debug up         # Include debug tools
  docker compose up                         # Core services only
```

### Step 4: Image Size Optimization
Reduce image size systematically:

```
IMAGE SIZE OPTIMIZATION CHECKLIST:
┌─────────────────────────────────────────────────────────────┐
│ Technique                        │ Typical Savings          │
├──────────────────────────────────┼──────────────────────────┤
│ Multi-stage build                │ 50-90% reduction         │
│ Alpine/distroless base           │ 60-80% vs debian/ubuntu  │
│ .dockerignore (exclude .git,     │ 10-50% build context     │
│   node_modules, tests, docs)     │ reduction                │
│ Combine RUN commands             │ 5-20% fewer layers       │
│ Remove package manager cache     │ 10-50MB savings          │
│   (rm -rf /var/cache/apk/*)     │                          │
│ --no-install-recommends (apt)    │ 10-30% package reduction │
│ npm ci --only=production         │ 30-70% node_modules      │
│ Strip debug symbols (Go/Rust)    │ 20-40% binary size       │
│ UPX compression (Go/Rust)        │ 50-70% binary size       │
│ Remove unnecessary files after   │ Varies widely            │
│   build (docs, tests, examples)  │                          │
└──────────────────────────────────┴──────────────────────────┘

ANALYSIS COMMANDS:
  docker images <image>                     # Check final image size
  docker history <image>                    # See layer sizes
  dive <image>                              # Interactive layer explorer
  docker scout quickview <image>            # Docker Scout analysis

.dockerignore (MUST HAVE):
  .git
  .gitignore
  node_modules
  npm-debug.log
  Dockerfile*
  docker-compose*
  .dockerignore
  .env*
  *.md
  tests/
  coverage/
  .vscode/
  .idea/
```

### Step 5: Security Scanning and Hardening
Scan images for vulnerabilities and apply security best practices:

```
SECURITY SCANNING TOOLS:
┌─────────────────────────────────────────────────────────────┐
│ Tool              │ Command                                  │
├───────────────────┼──────────────────────────────────────────┤
│ Trivy             │ trivy image <image:tag>                  │
│ Snyk              │ snyk container test <image:tag>          │
│ Docker Scout      │ docker scout cves <image:tag>            │
│ Grype             │ grype <image:tag>                        │
│ Dockle            │ dockle <image:tag>                       │
└───────────────────┴──────────────────────────────────────────┘

TRIVY SCANNING (recommended):
  # Scan for vulnerabilities
  trivy image --severity HIGH,CRITICAL <image:tag>

  # Scan Dockerfile for misconfigurations
  trivy config Dockerfile

  # Scan in CI (fail on HIGH/CRITICAL)
  trivy image --exit-code 1 --severity HIGH,CRITICAL <image:tag>

  # Generate SBOM (Software Bill of Materials)
  trivy image --format spdx-json -o sbom.json <image:tag>

DOCKERFILE SECURITY CHECKLIST:
┌─────────────────────────────────────────────────────────────┐
│ Practice                              │ Priority            │
├───────────────────────────────────────┼─────────────────────┤
│ Run as non-root user (USER)           │ CRITICAL            │
│ Pin base image digests (sha256)       │ HIGH                │
│ No secrets in ENV or COPY             │ CRITICAL            │
│ Use COPY not ADD (unless tar/URL)     │ MEDIUM              │
│ Set read-only filesystem where able   │ HIGH                │
│ Drop all capabilities, add needed     │ HIGH                │
│ Use --no-cache for package installs   │ MEDIUM              │
│ Scan in CI pipeline                   │ HIGH                │
│ Sign images (Docker Content Trust)    │ HIGH (production)   │
│ Use .dockerignore (no .env, .git)     │ HIGH                │
│ Set HEALTHCHECK in Dockerfile         │ MEDIUM              │
│ Limit container resources at runtime  │ MEDIUM              │
└───────────────────────────────────────┴─────────────────────┘

RUNTIME SECURITY:
  docker run \
    --read-only \                         # Read-only filesystem
    --tmpfs /tmp \                        # Writable /tmp only
    --cap-drop ALL \                      # Drop all Linux capabilities
    --cap-add NET_BIND_SERVICE \          # Add only what's needed
    --security-opt no-new-privileges \    # Prevent privilege escalation
    --memory 512m \                       # Memory limit
    --cpus 1.0 \                          # CPU limit
    --pids-limit 100 \                    # Process limit
    <image:tag>
```

### Step 6: Docker Networking and Volumes
Configure networking and persistent storage:

```
DOCKER NETWORKING:
┌─────────────────────────────────────────────────────────────┐
│ Network Type    │ Use Case                                   │
├─────────────────┼─────────────────────────────────────────────┤
│ bridge (default)│ Containers on same host communicate         │
│ host            │ Container shares host network (no isolation)│
│ overlay         │ Multi-host communication (Swarm/K8s)        │
│ macvlan         │ Container gets its own MAC address          │
│ none            │ No networking (isolated workloads)           │
└─────────────────┴─────────────────────────────────────────────┘

COMPOSE NETWORKING PATTERNS:
  # Isolated networks for microservices
  networks:
    frontend:          # Public-facing services
    backend:           # Internal services only
    monitoring:        # Observability stack

  services:
    api:
      networks: [frontend, backend]      # Can talk to both
    db:
      networks: [backend]                # Only internal access
    nginx:
      networks: [frontend]              # Only public-facing

VOLUME PATTERNS:
┌─────────────────────────────────────────────────────────────┐
│ Type              │ Use Case                                 │
├───────────────────┼──────────────────────────────────────────┤
│ Named volume      │ Database data, persistent storage        │
│ Bind mount        │ Source code (hot reload in development)  │
│ Anonymous volume  │ Temp data that shouldn't overwrite host  │
│ tmpfs mount       │ Secrets, temp files (RAM-only, no disk)  │
└───────────────────┴──────────────────────────────────────────┘

VOLUME BEST PRACTICES:
  1. Named volumes for databases (survives container recreation)
  2. Bind mounts for development only (never in production)
  3. tmpfs for sensitive data (never written to disk)
  4. Backup strategy for named volumes:
     docker run --rm -v myvolume:/data -v $(pwd):/backup \
       alpine tar czf /backup/volume-backup.tar.gz -C /data .
```

### Step 7: BuildKit Features and Build Arguments
Leverage advanced build capabilities:

```
BUILDKIT FEATURES:
┌─────────────────────────────────────────────────────────────┐
│ Feature                 │ Syntax / Usage                     │
├─────────────────────────┼────────────────────────────────────┤
│ Enable BuildKit         │ DOCKER_BUILDKIT=1 docker build .   │
│ Cache mounts            │ RUN --mount=type=cache,target=/root│
│                         │ /.cache/pip pip install -r req.txt │
│ Secret mounts           │ RUN --mount=type=secret,id=mysecret│
│                         │ cat /run/secrets/mysecret           │
│ SSH mounts              │ RUN --mount=type=ssh git clone ...  │
│ Heredocs                │ RUN <<EOF                           │
│                         │   apt-get update                    │
│                         │   apt-get install -y curl           │
│                         │ EOF                                 │
│ Multi-platform builds   │ docker buildx build --platform      │
│                         │ linux/amd64,linux/arm64 .           │
└─────────────────────────┴────────────────────────────────────┘

CACHE MOUNT PATTERNS (massive speed improvement):
  # Node.js — cache npm
  RUN --mount=type=cache,target=/root/.npm \
      npm ci

  # Python — cache pip
  RUN --mount=type=cache,target=/root/.cache/pip \
      pip install -r requirements.txt

  # Go — cache modules and build
  RUN --mount=type=cache,target=/go/pkg/mod \
      --mount=type=cache,target=/root/.cache/go-build \
      go build -o /app/server .

  # Rust — cache cargo
  RUN --mount=type=cache,target=/usr/local/cargo/registry \
      --mount=type=cache,target=/app/target \
      cargo build --release

SECRET HANDLING (never bake secrets into layers):
  # Build with secret:
  docker build --secret id=npm_token,src=.npmrc .

  # In Dockerfile:
  RUN --mount=type=secret,id=npm_token,target=/root/.npmrc \
      npm ci

BUILD ARGUMENTS:
  ARG NODE_VERSION=20
  ARG BUILD_DATE
  ARG GIT_SHA

  FROM node:${NODE_VERSION}-alpine
  LABEL org.opencontainers.image.created=${BUILD_DATE}
  LABEL org.opencontainers.image.revision=${GIT_SHA}

  # Build:
  docker build \
    --build-arg BUILD_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --build-arg GIT_SHA=$(git rev-parse HEAD) .

MULTI-PLATFORM BUILDS:
  # Create a builder
  docker buildx create --name multiarch --use

  # Build for multiple platforms
  docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --tag myapp:latest \
    --push .
```

### Step 8: Docker Report

```
┌────────────────────────────────────────────────────────────┐
│  DOCKER CONFIGURATION REPORT                               │
├────────────────────────────────────────────────────────────┤
│  Dockerfile: <created | optimized | validated>             │
│  Build type: <single-stage | multi-stage>                  │
│  Base image: <image:tag>                                   │
│  Final image size: <size>                                  │
│  Layers: <N>                                               │
│                                                            │
│  Docker Compose: <created | updated | N/A>                 │
│  Services: <list>                                          │
│  Volumes: <list>                                           │
│  Networks: <list>                                          │
│                                                            │
│  Security:                                                 │
│    Non-root user: <yes | no>                               │
│    .dockerignore: <complete | incomplete | missing>        │
│    Vulnerability scan: <clean | N issues>                  │
│    Secrets in image: <none | WARNING: found>               │
│                                                            │
│  Optimization:                                             │
│    Layer caching: <optimal | N improvements>               │
│    Size reduction: <N% from baseline>                      │
│    Build time: <N seconds>                                 │
│                                                            │
│  Ready for: /godmode:k8s or /godmode:deploy                │
└────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Commit Dockerfile: `"build(docker): Dockerfile — multi-stage <language> with <base image>"`
2. Commit Compose: `"build(docker): docker-compose — <N services> for local dev"`
3. After Docker setup: "Docker configured. Use `/godmode:k8s` for Kubernetes deployment or `/godmode:deploy` to ship."

## Key Behaviors

1. **Multi-stage builds are non-negotiable.** Every production Dockerfile uses multi-stage builds. No exceptions. The build stage should never appear in the final image.
2. **Layer caching is the first optimization.** Before anything else, ensure dependency installation is cached separately from source code changes. This alone saves minutes per build.
3. **Security is not optional.** Every image runs as non-root, has a .dockerignore, and passes vulnerability scanning. Secrets never appear in build layers.
4. **Compose is for development.** Docker Compose is the standard for local development environments. Production uses Kubernetes or managed container services.
5. **Size matters.** Smaller images deploy faster, start faster, and have fewer vulnerabilities. Target the smallest base image that works for your runtime.
6. **BuildKit is the default.** Always use BuildKit features (cache mounts, secret mounts, heredocs). They exist to solve real problems.
7. **.dockerignore before Dockerfile.** Create the .dockerignore first. A missing .dockerignore is the most common cause of bloated images and leaked secrets.

## Example Usage

### Containerizing a Node.js application
```
User: /godmode:docker I have a Next.js app, need to containerize it for production.

Docker: Assessing project context...

DOCKER CONTEXT ASSESSMENT:
Language: Node.js (Next.js)
Build: npm run build (outputs .next/)
Current state: No Dockerfile, no Docker Compose

Creating multi-stage Dockerfile...
  Stage 1: deps — install production dependencies
  Stage 2: build — compile Next.js
  Stage 3: production — minimal runtime with standalone output

Image size: 120MB (vs 1.2GB naive approach)
Security: non-root user, .dockerignore, no secrets in layers

Creating Docker Compose for local dev...
  app: Next.js with hot reload
  db: PostgreSQL 16
  cache: Redis 7

Files created:
  Dockerfile (multi-stage, 3 stages)
  docker-compose.yml (3 services)
  .dockerignore (comprehensive)

Next: /godmode:k8s to deploy to Kubernetes
```

### Optimizing an existing Dockerfile
```
User: /godmode:docker --optimize Our Docker image is 2.3GB and takes 8 minutes to build.

Docker: Analyzing current Dockerfile...

ISSUES FOUND:
  1. Single-stage build (all build tools in final image)
  2. Using ubuntu:latest (not pinned, large base)
  3. COPY . . before npm install (cache busted every build)
  4. No .dockerignore (copying .git, node_modules, tests)
  5. Running as root
  6. No health check

OPTIMIZATION APPLIED:
  - Multi-stage build: 2.3GB -> 185MB (92% reduction)
  - Alpine base: 185MB -> 120MB (35% further reduction)
  - Layer reordering: 8min -> 45sec rebuild (94% faster)
  - .dockerignore: build context 1.8GB -> 12MB
  - Non-root user + health check added
  - Trivy scan: 0 HIGH/CRITICAL vulnerabilities
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full Docker assessment and optimization |
| `--init` | Create Dockerfile and Compose from scratch |
| `--optimize` | Optimize existing Docker configuration |
| `--compose` | Docker Compose setup for local development |
| `--security` | Security scan and hardening |
| `--scan` | Run vulnerability scan (Trivy/Snyk) |
| `--slim` | Aggressive image size reduction |
| `--buildkit` | Enable and configure BuildKit features |
| `--multi-platform` | Set up multi-architecture builds |
| `--ci` | Generate CI/CD Docker build pipeline |
| `--audit` | Audit existing Docker setup for issues |

## Anti-Patterns

- **Do NOT use `latest` tag for base images.** Pin to a specific version (e.g., `node:20.11-alpine`). `latest` is unpredictable and breaks reproducibility.
- **Do NOT copy everything with `COPY . .` as the first instruction.** Copy dependency files first, install, then copy source. Otherwise every source change invalidates the dependency cache.
- **Do NOT run as root in production.** Always add a non-root user with USER instruction. Root in containers is root on the host if the container escapes.
- **Do NOT store secrets in ENV or COPY them into the image.** Use BuildKit secret mounts or runtime environment variables. Secrets in layers are visible in `docker history`.
- **Do NOT use ADD when COPY suffices.** ADD has URL fetch and tar extraction side effects. Use COPY for simple file copying.
- **Do NOT skip .dockerignore.** Without it, your entire project directory (including .git, node_modules, .env) is sent as build context.
- **Do NOT use docker-compose in production.** Docker Compose is a development tool. Use Kubernetes, ECS, or a managed container platform for production.
- **Do NOT ignore vulnerability scan results.** A "ship anyway" attitude toward CRITICAL CVEs is a security incident waiting to happen.
