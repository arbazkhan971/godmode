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
```

### Step 2: Dockerfile Best Practices
Create or optimize the Dockerfile using production-grade patterns:

#### Multi-Stage Build Pattern
```dockerfile
# --- Stage 1: Dependencies (cached separately from source code)
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

# --- Stage 2: Build (compile/transpile source code)
FROM node:20-alpine AS build
WORKDIR /app
```

#### Layer Caching Strategy
```
LAYER CACHING RULES:
| Rule | Why |
|--|--|
| COPY dependency files first | Dependencies change less |
|  | often than source code |
| RUN install BEFORE COPY src | Bust cache only when deps |
|  | actually change |
| Order instructions by change | Least-changing layers first, |
| frequency | most-changing layers last |
| Combine related RUN commands | Fewer layers, smaller image |
| Use .dockerignore | Exclude node_modules, .git, |
|  | test files from build context |

```

#### Language-Specific Patterns

```
MULTI-STAGE BUILD BY LANGUAGE:
| Language | Build Image | Runtime Image | Size |
|--|--|--|--|
| Node.js | node:20-alpine | node:20-alpine | ~120MB |
| Python | python:3.12-slim | python:3.12-slim | ~150MB |
| Go | golang:1.22-alpine | scratch/distroless | ~10MB |
| Rust | rust:1.77-alpine | scratch/distroless | ~5MB |
| Java | eclipse-temurin:21 | eclipse-temurin: | ~200MB |
|  |  | 21-jre-alpine |  |
| .NET | mcr.microsoft.com/ | mcr.microsoft.com | ~100MB |
|  | dotnet/sdk:8.0 | /dotnet/aspnet: |  |
|  |  | 8.0-alpine |  |

```

### Step 3: Docker Compose for Local Development
Set up a complete local development environment:

```yaml
# docker-compose.yml — Local development
version: "3.9"

services:
  app:
    build:
```

```
DOCKER COMPOSE PATTERNS:
| Pattern | Purpose |
|--|--|
| depends_on + health | Start order with readiness check |
| target: development | Use dev stage of multi-stage build |
| bind mount + anon vol | Hot reload without overwriting deps |
| named volumes | Persist data across restarts |
| init scripts | Seed database on first start |
| profiles | Optional services (monitoring, etc.) |
| env_file | Keep secrets out of compose file |
| networks | Isolate service communication |

COMPOSE PROFILES (optional services):
  docker compose --profile monitoring up    # Include Prometheus, Grafana
  docker compose --profile debug up         # Include debug tools
  docker compose up                         # Core services only
```

### Step 4: Image Size Optimization
Reduce image size systematically:

```
IMAGE SIZE OPTIMIZATION CHECKLIST:
| Technique | Typical Savings |
|--|--|
| Multi-stage build | 50-90% reduction |
| Alpine/distroless base | 60-80% vs debian/ubuntu |
| .dockerignore (exclude .git, | 10-50% build context |
| node_modules, tests, docs) | reduction |
| Combine RUN commands | 5-20% fewer layers |
| Remove package manager cache | 10-50MB savings |
| (rm -rf /var/cache/apk/*) |  |
| --no-install-recommends (apt) | 10-30% package reduction |
| npm ci --only=production | 30-70% node_modules |
| Strip debug symbols (Go/Rust) | 20-40% binary size |
| UPX compression (Go/Rust) | 50-70% binary size |
```

### Step 5: Security Scanning and Hardening
Scan images for vulnerabilities and apply security best practices:

```
SECURITY SCANNING TOOLS:
| Tool | Command |
|--|--|
| Trivy | trivy image <image:tag> |
| Snyk | snyk container test <image:tag> |
| Docker Scout | docker scout cves <image:tag> |
| Grype | grype <image:tag> |
| Dockle | dockle <image:tag> |

TRIVY SCANNING (recommended):
  # Scan for vulnerabilities
  trivy image --severity HIGH,CRITICAL <image:tag>

```

### Step 6: Docker Networking and Volumes
Configure networking and persistent storage:

```
DOCKER NETWORKING:
| Network Type | Use Case |
|--|--|
| bridge (default) | Containers on same host communicate |
| host | Container shares host network (no isolation) |
| overlay | Multi-host communication (Swarm/K8s) |
| macvlan | Container gets its own MAC address |
| none | No networking (isolated workloads) |

COMPOSE NETWORKING PATTERNS:
  # Isolated networks for microservices
  networks:
    frontend:          # Public-facing services
```

### Step 7: BuildKit Features and Build Arguments
Use advanced build capabilities:

```
BUILDKIT FEATURES:
| Feature | Syntax / Usage |
|--|--|
| Enable BuildKit | DOCKER_BUILDKIT=1 docker build . |
| Cache mounts | RUN --mount=type=cache,target=/root |
|  | /.cache/pip pip install -r req.txt |
| Secret mounts | RUN --mount=type=secret,id=mysecret |
|  | cat /run/secrets/mysecret |
| SSH mounts | RUN --mount=type=ssh git clone ... |
| Heredocs | RUN <<EOF |
|  | apt-get update |
|  | apt-get install -y curl |
|  | EOF |
| Multi-platform builds | docker buildx build --platform |
```

### Step 8: Docker Report

```
  DOCKER CONFIGURATION REPORT
  Dockerfile: <created | optimized | validated>
  Build type: <single-stage | multi-stage>
  Base image: <image:tag>
  Final image size: <size>
  Layers: <N>
  Docker Compose: <created | updated | N/A>
  Services: <list>
  Volumes: <list>
  Networks: <list>
  Security:
```

### Step 9: Commit and Transition
1. Commit Dockerfile: `"build(docker): Dockerfile — multi-stage <language> with <base image>"`
2. Commit Compose: `"build(docker): docker-compose — <N services> for local dev"`
3. After Docker setup: "Docker configured. Use `/godmode:k8s` for Kubernetes deployment or `/godmode:deploy` to ship."

## Key Behaviors

1. **Multi-stage builds are non-negotiable.** Every production Dockerfile uses multi-stage builds. No exceptions. The build stage should never appear in the final image.
2. **Layer caching is the first optimization.** Before anything else, verify dependency installation is cached separately from source code changes. This alone saves minutes per build.
3. **Security is not optional.** Every image runs as non-root, has a .dockerignore, and passes vulnerability scanning. Secrets never appear in build layers.
4. **Compose is for development.** Docker Compose is the standard for local development environments. Production uses Kubernetes or managed container services.
5. **Smaller images are faster and safer.** They deploy faster, start faster, and have fewer vulnerabilities. Target the smallest base image that works for your runtime.
6. **BuildKit is the default.** Always use BuildKit features (cache mounts, secret mounts, heredocs). They exist to solve real problems.
7. **.dockerignore before Dockerfile.** Create the .dockerignore first. A missing .dockerignore is the most common cause of bloated images and leaked secrets.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full Docker assessment and optimization |
| `--init` | Create Dockerfile and Compose from scratch |
| `--optimize` | Optimize existing Docker configuration |

## HARD RULES

- NEVER use `latest` tag for base images — pin to specific version (e.g., `node:20.11-alpine`)
- NEVER run containers as root in production — always add a non-root USER directive
- NEVER store secrets in ENV, ARG, or COPY in Dockerfile layers — use BuildKit secret mounts or runtime env
- NEVER use ADD when COPY suffices — ADD has URL fetch and tar extraction side effects
- NEVER skip .dockerignore — without it, .git, node_modules, .env are sent as build context
- ALL production Dockerfiles MUST use multi-stage builds — build tools never appear in the final image
- ALL container images MUST pass vulnerability scanning (Trivy/Snyk) with zero CRITICAL findings before deployment
- ALL images MUST include a HEALTHCHECK directive

## Iterative Optimization Loop Protocol

When optimizing or auditing Docker configurations:

```
current_iteration = 0
optimization_queue = [all_dockerfiles_and_compose_files]
WHILE optimization_queue is not empty:
    current_iteration += 1
    file = optimization_queue.pop(next)
    analyze: base image size, layer count, caching order, security issues
    apply: multi-stage build, layer reordering, .dockerignore, non-root user, healthcheck
    measure: image size, build time, vulnerability count
    run: trivy image scan + trivy config scan
    IF scan reveals CRITICAL/HIGH vulnerabilities:
        fix and re-add to queue
    report: "Iteration {current_iteration}: {file} — size={N}MB, layers={N}, vulns={N}, build_time={N}s"
```

## Keep/Discard Discipline
```
After EACH Docker optimization:
  1. MEASURE: Build the image — check final size, layer count, build time, vulnerability count.
  2. COMPARE: Is the image smaller/faster/more secure than before?
  3. DECIDE:
     - KEEP if: image size decreased AND vulnerability count did not increase AND container starts successfully
     - DISCARD if: image size increased OR new critical vulnerability OR container fails to start
  4. COMMIT kept changes. Revert discarded changes before the next optimization.

Never keep a size optimization that introduces a critical CVE.
```

## Stuck Recovery
```
IF >3 consecutive optimizations fail to reduce image size or fix vulnerabilities:
  1. Re-examine the base image — switching from slim to alpine (or distroless) may unlock larger savings.
  2. Use `dive` to inspect layer-by-layer — the bloat may be in an unexpected layer.
  3. Check for musl vs glibc compatibility if alpine builds fail.
  4. If still stuck → log stop_reason=stuck, document current image size and known issues.
```

## Stop Conditions
```
Loop until target or budget. Never ask to continue — loop autonomously.
On failure: git reset --hard HEAD~1.

STOP when ANY of these are true:
  - All images use multi-stage builds with non-root user and health checks
  - Zero critical CVEs in vulnerability scan
  - Image size is within target (varies by language: Go <50MB, Node <200MB, Python <200MB)
  - User explicitly requests stop
  - Max iterations (10) reached

DO NOT STOP when:
  - HIGH (non-critical) CVEs exist in the base image with no fix available
  - Image size is slightly above target but all other criteria pass
```

## Simplicity Criterion
```
PREFER the simpler Docker configuration:
  - Alpine base before distroless (unless you genuinely need zero shell access)
  - Single Dockerfile with multi-stage before multiple Dockerfiles
  - Docker Compose for local dev before Kubernetes for local dev
  - COPY before ADD (unless you need tar extraction or URL fetch)
  - Fewer layers over many small RUN commands (combine related operations)
```

## Auto-Detection
```
1. Scan for Dockerfile*, docker-compose*, .dockerignore
2. Detect language: package.json→Node, pyproject.toml→Python, go.mod→Go, Cargo.toml→Rust, pom.xml→Java
3. Check image quality: FROM tag, USER directive, HEALTHCHECK, multi-stage patterns
4. State: missing | exists-unoptimized | optimized | production-ready
```

## Output Format
Print on completion: `Docker: {image_count} images optimized. Size: {before_size} → {after_size} (-{savings}%). Layers: {layer_count}. Security: {vuln_count} vulnerabilities ({critical} critical). Build: {build_time}. Verdict: {verdict}.`

## TSV Logging
Log to `.godmode/docker-results.tsv`:
```
iteration	image	size_before	size_after	layers	vulns_critical	vulns_high	build_time_s	status
```

## Success Criteria
- Multi-stage builds, Alpine/distroless base, pinned tags, non-root user, HEALTHCHECK.
- .dockerignore excludes .git, node_modules, .env. No secrets in layers.
- Zero critical CVEs. Build cache optimized (deps before source).

## Error Recovery
- **Build fails at install**: Verify lockfile copied before install. Check base image system deps and network.
- **Image too large**: Run `docker history --no-trunc`. Verify multi-stage copies only final artifact. Check `.dockerignore`.
- **Container crashes**: Check `docker logs`. Verify CMD/ENTRYPOINT. Check non-root user permissions.
- **Health check fails**: Verify endpoint exists. Check `--start-period`. Confirm health check tool in image.
- **Critical CVEs**: Update base image tag or dep. If no fix, document accepted risk.
- **Cache miss**: Verify COPY order (lockfile first). Check BuildKit enabled. Confirm CI preserves cache.

