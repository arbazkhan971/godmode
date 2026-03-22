# Recipe: From Docker to Kubernetes Production

> From a Dockerfile to production Kubernetes deployment. Containerization, orchestration, CI/CD, and production readiness.

---

## Overview

| Attribute | Value |
|-----------|-------|
| **Chain** | `docker → k8s → cicd → observe → deploy → ship` |
| **Timeline** | 3-5 days for full production setup |
| **Team size** | 1-3 developers (or 1 developer with platform experience) |
| **Example project** | "StreamAPI" — a multi-service API deployed to Kubernetes with CI/CD |

---

## Prerequisites

- Application code (any language)
- Container registry (Docker Hub, ECR, GCR, or GitHub Container Registry)
- Kubernetes cluster (EKS, GKE, AKS, or local with kind/minikube for dev)
- kubectl and Helm installed
- Godmode installed and configured

---

## The Journey

```
Local development → Dockerfile → Docker Compose → Kubernetes manifests → Helm charts → CI/CD → Production
```

Most teams jump straight to Kubernetes. This recipe builds up incrementally, validating at each step.

---

## Technology Recommendations

| Layer | Recommendation | Why |
|-------|---------------|-----|
| Container runtime | Docker (build) + containerd (K8s) | Industry standard, widest compatibility |
| Registry | GitHub Container Registry or ECR | Integrated with CI/CD |
| Orchestration | Kubernetes (EKS, GKE, or AKS) | Production-grade, managed control plane |
| Package manager | Helm 3 | Templated manifests, release management |
| CI/CD | GitHub Actions | Simple, integrated, free for public repos |
| Ingress | nginx-ingress or Traefik | TLS termination, routing, rate limiting |
| Secrets | External Secrets Operator + AWS Secrets Manager | No secrets in git, automatic sync |
| Monitoring | Prometheus + Grafana (see monitoring-setup recipe) | Native Kubernetes integration |

---

## Session Transcript

### Phase 1: Docker — Containerize the Application

```
> /godmode:docker We have a Node.js API (TypeScript) with a PostgreSQL
  database and Redis cache. I need production-ready Dockerfiles with
  multi-stage builds, security hardening, and a Docker Compose setup
  for local development.

Godmode: Analyzing application... Creating container configuration...

DOCKER CONFIGURATION:

Dockerfile (multi-stage, production-optimized):

  Stage 1: deps (install dependencies)
    FROM node:20-alpine AS deps
    - Copy package.json and lock file only
    - Install production dependencies
    - Separate layer for caching

  Stage 2: build (compile TypeScript)
    FROM node:20-alpine AS build
    - Copy source code
    - Install all dependencies (including devDependencies)
    - Run TypeScript compiler
    - Run tests during build (fail fast)

  Stage 3: production (minimal runtime image)
    FROM node:20-alpine AS production
    - Copy only production node_modules from deps stage
    - Copy only compiled JavaScript from build stage
    - Run as non-root user (node:node, UID 1000)
    - Healthcheck: curl http://localhost:3000/health
    - No shell, no package manager in final image

  Image properties:
    Base image: node:20-alpine (57MB vs 350MB for node:20)
    Final size: ~120MB (vs 800MB+ for naive Dockerfile)
    User: non-root (UID 1000)
    Read-only filesystem: supported
    No secrets baked in: environment variables only

Security hardening:
  ✓ Non-root user
  ✓ Read-only root filesystem
  ✓ No unnecessary packages
  ✓ .dockerignore excludes: .git, node_modules, .env, tests
  ✓ Pinned base image digest (not just tag)
  ✓ No COPY . . before dependency install (cache invalidation)
  ✓ hadolint: 0 warnings

Docker Compose (local development):
  services:
    api:
      build: .
      ports: 3000:3000
      volumes: ./src:/app/src (hot reload)
      depends_on: [postgres, redis]
      environment: from .env.local

    postgres:
      image: postgres:16-alpine
      volumes: postgres-data (persistent)
      ports: 5432:5432

    redis:
      image: redis:7-alpine
      ports: 6379:6379

    migrate:
      build: .
      command: npx prisma migrate deploy
      depends_on: [postgres]

Files created:
  Dockerfile                   — multi-stage production build
  Dockerfile.dev               — development build with hot reload
  docker-compose.yml           — full local development stack
  docker-compose.test.yml      — test environment with ephemeral DB
  .dockerignore                — excludes unnecessary files

Commit: "docker: multi-stage Dockerfile, Docker Compose for dev and test"
```

**Time: 30 minutes.**

### Phase 2: K8s — Create Kubernetes Manifests

```
> /godmode:k8s

Godmode: Reading Docker configuration... Generating Kubernetes manifests...

KUBERNETES ARCHITECTURE:

Namespace: streamapi
  ├── Deployment: api (3 replicas)
  ├── Service: api (ClusterIP)
  ├── Ingress: api (TLS, rate limiting)
  ├── HorizontalPodAutoscaler: api (CPU/memory based)
  ├── PodDisruptionBudget: api (minAvailable: 2)
  ├── ConfigMap: api-config (non-sensitive config)
  ├── ExternalSecret: api-secrets (from AWS Secrets Manager)
  ├── ServiceAccount: api (least-privilege RBAC)
  ├── NetworkPolicy: api (restrict ingress/egress)
  └── ServiceMonitor: api (Prometheus scraping)

Deployment configuration:
  Replicas: 3 (minimum for HA)
  Strategy: RollingUpdate (maxSurge: 1, maxUnavailable: 0)

  Container:
    Resources:
      requests: 256Mi memory, 250m CPU
      limits: 512Mi memory, 500m CPU
    Probes:
      liveness: GET /health every 15s (fail after 3)
      readiness: GET /ready every 5s (fail after 3)
      startup: GET /health every 5s (fail after 30 — allows slow starts)
    Security context:
      runAsNonRoot: true
      runAsUser: 1000
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities: drop ALL

  Pod topology:
    podAntiAffinity: prefer spreading across nodes
    topologySpreadConstraints: max skew 1 across zones

Ingress:
  Host: api.streamapi.com
  TLS: cert-manager with Let's Encrypt
  Annotations:
    rate-limit: 100 req/s per IP
    proxy-body-size: 10m
    ssl-redirect: true

HPA:
  Min replicas: 3
  Max replicas: 10
  Scale on: CPU > 70% OR memory > 80%
  Scale down stabilization: 300s (prevent flapping)

Helm chart structure:
  charts/streamapi/
    Chart.yaml
    values.yaml          — default values
    values-staging.yaml  — staging overrides
    values-prod.yaml     — production overrides
    templates/
      deployment.yaml
      service.yaml
      ingress.yaml
      hpa.yaml
      pdb.yaml
      configmap.yaml
      external-secret.yaml
      serviceaccount.yaml
      networkpolicy.yaml
      servicemonitor.yaml
      _helpers.tpl

Commit: "k8s: Helm chart — deployment, ingress, HPA, PDB, network policies, security context"
```

**Time: 45 minutes.**

### Phase 3: CI/CD — Automate Build and Deploy

```
> /godmode:cicd

Godmode: Designing CI/CD pipeline...

CI/CD PIPELINE:

Trigger: Push to main or pull request

Pipeline stages:

  Stage 1: Test (parallel jobs, ~3 min)
    ├── Lint: eslint + prettier check
    ├── Type check: tsc --noEmit
    ├── Unit tests: jest --coverage
    └── Security scan: trivy (dependencies)

  Stage 2: Build (~2 min)
    ├── Docker build (multi-stage)
    ├── Tag: git SHA + branch name
    ├── Push to container registry
    └── Container scan: trivy (image vulnerabilities)

  Stage 3: Deploy to Staging (auto, ~3 min)
    ├── Helm upgrade --install (staging namespace)
    ├── Wait for rollout complete
    ├── Run smoke tests against staging
    └── Run E2E tests against staging

  Stage 4: Deploy to Production (manual approval, ~3 min)
    ├── Require approval from team lead
    ├── Helm upgrade --install (production namespace)
    ├── Wait for rollout complete
    ├── Run smoke tests against production
    └── Notify Slack #deploys

  Rollback:
    Automatic: if smoke tests fail, helm rollback
    Manual: /rollback command in Slack

Pipeline optimizations:
  - Docker layer caching (GitHub Actions cache)
  - Parallel test jobs
  - Skip build if only docs changed
  - Reuse staging image for production (same SHA)

Branch strategy:
  main        → auto-deploy to staging → manual promote to production
  feature/*   → run tests only (no deploy)
  hotfix/*    → fast-track: test → staging → production (expedited approval)

Files created:
  .github/workflows/ci.yml              — test + build pipeline
  .github/workflows/deploy-staging.yml   — auto-deploy to staging
  .github/workflows/deploy-prod.yml      — manual deploy to production
  .github/workflows/rollback.yml         — emergency rollback
  scripts/smoke-test.sh                  — health check + basic API tests
  scripts/e2e-staging.sh                 — end-to-end tests for staging

Commit: "cicd: GitHub Actions — test, build, deploy staging/production, rollback"
```

**Time: ~30 min.**

### Phase 4: Observe — Kubernetes-Native Monitoring

```
> /godmode:observe --platform kubernetes

Godmode: Setting up Kubernetes-native observability...

KUBERNETES OBSERVABILITY:

Application monitoring (from monitoring-setup recipe):
  ✓ Prometheus ServiceMonitor scraping /metrics
  ✓ Grafana dashboards provisioned
  ✓ Alertmanager rules deployed

Kubernetes-specific monitoring:

  Cluster metrics (kube-state-metrics):
    - Pod status, restarts, OOMKills
    - Deployment replica count vs desired
    - Node resource utilization
    - PV usage and capacity

  Resource metrics (metrics-server):
    - CPU and memory per pod (for HPA)
    - Node-level resource usage

  Container metrics (cAdvisor):
    - Container CPU, memory, disk, network
    - Container restart count
    - Image pull duration

  Kubernetes events:
    - Pod scheduling failures
    - Image pull errors
    - OOMKilled events
    - Node not ready events

Dashboards added:
  1. Cluster Overview   — node health, pod status, resource usage
  2. Namespace Detail   — pods, deployments, services per namespace
  3. Pod Detail         — container metrics, logs, restarts
  4. Deployment Detail  — rollout status, replica history, HPA events

Alerts added:
  - Pod CrashLoopBackOff for > 5 minutes → PagerDuty
  - Pod OOMKilled → Slack (investigate memory limits)
  - Node NotReady for > 3 minutes → PagerDuty
  - PV usage > 85% → Slack
  - HPA at max replicas for > 30 minutes → Slack (scale limits)
  - Deployment rollout stuck for > 10 minutes → PagerDuty
  - Certificate expiring within 7 days → Slack

Commit: "observe: Kubernetes monitoring — cluster, node, pod, deployment dashboards and alerts"
```

**Time: ~30 min.**

### Phase 5: Deploy — Production Deployment

```
> /godmode:deploy --target production --provider eks

Godmode: Deploying to production Kubernetes cluster...

PRODUCTION DEPLOYMENT:

Infrastructure (Terraform):
  VPC:
    - 3 availability zones
    - Public subnets (load balancer)
    - Private subnets (pods)
    - NAT gateway for outbound

  EKS Cluster:
    - Kubernetes 1.29
    - Managed node group: 3x t3.large (2 vCPU, 8GB)
    - Autoscaling: 3-10 nodes
    - Private API endpoint

  Supporting services:
    - RDS PostgreSQL (Multi-AZ, encrypted)
    - ElastiCache Redis (cluster mode)
    - ECR for container images
    - S3 for Loki/Tempo storage
    - ACM for TLS certificates
    - Route 53 for DNS

  Security:
    - Pod security standards: restricted
    - Network policies: deny all by default
    - IAM roles for service accounts (IRSA)
    - Secrets in AWS Secrets Manager
    - Encryption at rest for EBS and RDS

Deployment sequence:
  1. ✓ Terraform apply (infrastructure)
  2. ✓ Install cert-manager (TLS)
  3. ✓ Install nginx-ingress (routing)
  4. ✓ Install external-secrets-operator (secrets)
  5. ✓ Install Prometheus stack (monitoring)
  6. ✓ Deploy application via Helm
  7. ✓ Configure DNS (Route 53 → ALB)
  8. ✓ Verify TLS certificate issued

Files created:
  infra/terraform/vpc.tf              — VPC and networking
  infra/terraform/eks.tf              — EKS cluster and node groups
  infra/terraform/rds.tf              — PostgreSQL database
  infra/terraform/elasticache.tf      — Redis cluster
  infra/terraform/ecr.tf              — Container registry
  infra/terraform/route53.tf          — DNS configuration
  infra/terraform/variables.tf        — configurable parameters
  infra/terraform/outputs.tf          — cluster endpoint, DB hostname

Commit: "deploy: production EKS infrastructure — VPC, cluster, RDS, Redis, monitoring"
```

**Time: 2-3 hours** (infrastructure provisioning takes time).

### Phase 6: Ship — Go Live

```
> /godmode:ship --deploy production

Godmode: Starting 8-phase shipping workflow...

Phase 1: INVENTORY
  26 commits, 58 files changed
  Docker, Kubernetes, CI/CD, monitoring, infrastructure

Phase 2: CHECKLIST
  ✓ Tests: all passing in CI
  ✓ Docker image: scanned, no critical vulnerabilities
  ✓ Kubernetes manifests: validated with kubeval
  ✓ Helm chart: linted with helm lint
  ✓ TLS configured: A+ on SSL Labs
  ✓ Network policies: deny-all default
  ✓ Pod security: restricted mode
  ✓ Secrets: not in git, managed via External Secrets
  ✓ HPA: configured and tested
  ✓ PDB: minAvailable 2 (survives node drain)
  ✓ Monitoring: dashboards and alerts active

Phase 3: PREPARE
  ✓ Production image pushed to ECR
  ✓ Database migrated
  ✓ Secrets synced from AWS Secrets Manager

Phase 4: DRY RUN
  ✓ Staging deployment verified
  ✓ Smoke tests passing
  ✓ Load test: handles 1000 req/s with 3 replicas
  ✓ HPA scales to 6 replicas under load
  ✓ Rolling update: zero downtime verified

Phase 5: DEPLOY
  ✓ Helm upgrade to production
  ✓ Rollout complete (3/3 replicas ready)
  ✓ Ingress routing traffic

Phase 6: VERIFY
  ✓ Production smoke tests: 12/12
  ✓ TLS working (HTTPS redirect)
  ✓ API responding: p99 latency 32ms
  ✓ Monitoring: metrics flowing

Phase 7: LOG
  Ship log: .godmode/ship-log.tsv
  Version: v1.0.0

Phase 8: MONITOR
  T+0:  ✓ Deployed
  T+5:  ✓ Error rate 0%, latency p99 32ms
  T+15: ✓ HPA stable at 3 replicas
  T+30: ✓ All clear. Production launch confirmed stable.

StreamAPI v1.0.0 is LIVE on Kubernetes.
```

---

## Docker Best Practices

### Multi-Stage Build Pattern

```
Stage 1: deps       — install dependencies (cached layer)
Stage 2: build      — compile code (invalidated on source change)
Stage 3: production — minimal runtime (no build tools, no devDependencies)
```

### Image Size Optimization

| Technique | Savings |
|-----------|---------|
| Alpine base image | 300MB+ (vs Debian) |
| Multi-stage build | 500MB+ (no build tools in production) |
| .dockerignore | 50-200MB (no .git, node_modules, tests) |
| Production deps only | 100-300MB (no devDependencies) |

### Security Checklist

- Non-root user in all containers
- Read-only root filesystem
- No capabilities (drop ALL)
- Pinned base image versions
- Scanned with Trivy in CI
- No secrets baked into image

---

## Kubernetes Production Checklist

| Category | Item | Why |
|----------|------|-----|
| Availability | 3+ replicas | Survive pod/node failures |
| Availability | PodDisruptionBudget | Survive node drains |
| Availability | Pod anti-affinity | Spread across nodes |
| Availability | Topology spread | Spread across zones |
| Resources | CPU/memory requests | Scheduler accuracy |
| Resources | CPU/memory limits | Prevent noisy neighbor |
| Health | Liveness probe | Restart stuck processes |
| Health | Readiness probe | Remove unhealthy from LB |
| Health | Startup probe | Handle slow starts |
| Scaling | HPA configured | Auto-scale on demand |
| Scaling | Scale-down stabilization | Prevent flapping |
| Security | Non-root container | Least privilege |
| Security | Read-only filesystem | Prevent runtime modification |
| Security | Network policies | Restrict traffic |
| Security | Service account | RBAC per workload |
| Secrets | External Secrets | No secrets in manifests |
| Observability | ServiceMonitor | Prometheus scraping |
| Observability | Structured logging | Log aggregation |

---

## Common Pitfalls

| Pitfall | Why It Happens | Godmode Prevention |
|---------|---------------|-------------------|
| Fat Docker images (1GB+) | No multi-stage build | `/godmode:docker` generates multi-stage by default |
| No health checks | "The app starts, it is fine" | `/godmode:k8s` adds liveness + readiness + startup probes |
| Running as root | Default in most base images | Security context enforced in Helm templates |
| Secrets in ConfigMaps | "It is just the database URL" | External Secrets Operator for all secrets |
| No resource limits | Works in dev, OOMs in prod | `/godmode:k8s` sets requests and limits |
| Manual deployments | "I will just kubectl apply" | `/godmode:cicd` automates the full pipeline |
| No rollback plan | "It will work" | Helm rollback + automated smoke test gate |

---

## Custom Chain for Kubernetes Projects

```yaml
# .godmode/chains.yaml
chains:
  k8s-service:
    description: "Containerize and deploy a new service to Kubernetes"
    steps:
      - docker         # create Dockerfile and Compose
      - k8s            # generate Helm chart
      - cicd           # create CI/CD pipeline
      - observe        # add monitoring
      - deploy         # deploy to staging
      - ship           # promote to production

  k8s-scale:
    description: "Scale and optimize a Kubernetes workload"
    steps:
      - observe        # analyze current resource usage
      - optimize       # right-size resources
      - loadtest       # verify under load
      - deploy         # apply changes
      - observe        # verify improvements
```

---

## See Also

- [Skill Index](../skill-index.md) — All 48 skills
- [Chaining Guide](../chaining.md) — How skills communicate
- [Full Observability Setup](monitoring-setup.md) — Deep dive into monitoring on K8s
- [Building a SaaS](greenfield-saas.md) — Full SaaS deployment workflow
- [Building an Event System](event-system.md) — Deploying multi-service event architectures
