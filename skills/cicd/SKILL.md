---
name: cicd
description: |
  CI/CD pipeline design skill. Activates when user needs to create, optimize, or troubleshoot continuous integration and delivery pipelines. Supports GitHub Actions, GitLab CI, CircleCI, and Jenkins. Handles stage optimization, caching strategies, artifact management, pipeline templating, and matrix builds. Triggers on: /godmode:cicd, "create pipeline", "optimize CI", "add GitHub Actions", "fix pipeline", or when shipping requires CI/CD configuration.
---

# CICD — CI/CD Pipeline Design

## When to Activate
- User invokes `/godmode:cicd`
- User says "create pipeline", "set up CI/CD", "add GitHub Actions"
- User says "optimize CI", "pipeline is slow", "fix failing pipeline"
- User says "add deployment stage", "set up matrix builds"
- Project has no CI/CD configuration
- Shipping workflow requires automated pipeline
- Pipeline performance needs improvement

## Workflow

### Step 1: Discover Pipeline Context
Identify the project's CI/CD requirements and existing configuration:

```
PIPELINE CONTEXT:
┌──────────────────────────────────────────────────────────┐
│  Platform: <GitHub Actions | GitLab CI | CircleCI |       │
│            Jenkins | None detected>                       │
│  Language: <detected language/framework>                  │
│  Package Manager: <npm | pip | go mod | maven | etc.>     │
│  Test Framework: <jest | pytest | go test | junit | etc.> │
│  Linter: <eslint | ruff | golangci-lint | etc.>          │
│  Container: <Dockerfile present? Y/N>                     │
│  Deploy Target: <K8s | ECS | Lambda | Vercel | etc.>     │
│  Existing Pipeline: <path to config or "none">            │
│  Branch Strategy: <trunk-based | gitflow | github flow>  │
└──────────────────────────────────────────────────────────┘
```

If no pipeline exists: "No CI/CD configuration found. Shall I create one? Specify your preferred platform (GitHub Actions, GitLab CI, CircleCI, Jenkins)."

### Step 2: Pipeline Architecture Design
Design the pipeline stages based on project needs:

```
PIPELINE ARCHITECTURE:
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Lint   │ -> │  Test   │ -> │  Build  │ -> │ Security│ -> │ Deploy  │
│         │    │         │    │         │    │         │    │         │
│ Format  │    │ Unit    │    │ Docker  │    │ SAST    │    │ Staging │
│ Lint    │    │ Integ.  │    │ Assets  │    │ Deps    │    │ Prod    │
│ Types   │    │ E2E     │    │ Publish │    │ Secrets │    │ Verify  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
     |              |              |              |              |
   ~30s          ~2-5m          ~1-3m          ~1-2m          ~2-5m
                                                         (manual gate
                                                          for prod)
```

### Step 3: Generate Pipeline Configuration

#### GitHub Actions
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

permissions:
  contents: read
  packages: write
  security-events: write

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}
  NODE_VERSION: '20'

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci

      - name: Check formatting
        run: npm run format:check

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run type-check

  test:
    name: Test
    runs-on: ubuntu-latest
    timeout-minutes: 15
    needs: lint
    strategy:
      fail-fast: false
      matrix:
        shard: [1, 2, 3]
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - run: npm ci

      - name: Run tests (shard ${{ matrix.shard }}/3)
        run: npm test -- --shard=${{ matrix.shard }}/3
        env:
          DATABASE_URL: postgres://postgres:test@localhost:5432/test
          REDIS_URL: redis://localhost:6379

      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-${{ matrix.shard }}
          path: coverage/

  coverage:
    name: Coverage Report
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/download-artifact@v4
        with:
          pattern: coverage-*
          merge-multiple: true

      - name: Merge and report coverage
        run: |
          npx nyc merge coverage/ merged-coverage.json
          npx nyc report --reporter=text --reporter=lcov

      - name: Check coverage threshold
        run: npx nyc check-coverage --lines 80 --branches 75 --functions 80

  build:
    name: Build & Push Image
    runs-on: ubuntu-latest
    needs: [test]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=
            type=ref,event=branch

      - id: build
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ needs.build.outputs.image-tag }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

      - name: Upload scan results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Dependency audit
        run: npm audit --audit-level=high

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: [build, security]
    environment: staging
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to staging
        run: |
          echo "Deploying ${{ needs.build.outputs.image-tag }} to staging"
          # helm upgrade or kubectl apply or aws ecs update-service

      - name: Verify deployment
        run: |
          # Health check, smoke tests
          curl -sf https://staging.example.com/health || exit 1

      - name: Run smoke tests
        run: npm run test:smoke -- --base-url=https://staging.example.com

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment: production
    steps:
      - uses: actions/checkout@v4

      - name: Deploy to production
        run: |
          echo "Deploying ${{ needs.build.outputs.image-tag }} to production"
          # Production deployment with canary or blue-green

      - name: Verify deployment
        run: |
          curl -sf https://api.example.com/health || exit 1

      - name: Post-deploy notification
        if: always()
        run: |
          # Notify Slack, PagerDuty, etc.
          echo "Deployment ${{ job.status }}"
```

#### GitLab CI
```yaml
stages:
  - lint
  - test
  - build
  - security
  - deploy

variables:
  NODE_VERSION: "20"
  DOCKER_TLS_CERTDIR: "/certs"

default:
  cache:
    key:
      files:
        - package-lock.json
    paths:
      - node_modules/
    policy: pull

.node-setup:
  image: node:${NODE_VERSION}
  before_script:
    - npm ci --cache .npm --prefer-offline

### Step 4: Caching Strategies
Optimize pipeline speed with intelligent caching:

```
CACHING STRATEGY:
┌──────────────────────────────────────────────────────────┐
│  Cache Type        │ Key                │ Savings         │
│  ─────────────────────────────────────────────────────── │
│  Dependencies      │ lockfile hash      │ 30-90s          │
│  (node_modules,    │ (package-lock.json │                 │
│   .venv, vendor)   │  Pipfile.lock)     │                 │
│                    │                    │                 │
│  Build cache       │ source hash        │ 60-180s         │
│  (Docker layers,   │ (Dockerfile +      │                 │
│   compiled assets) │  source files)     │                 │
│                    │                    │                 │
│  Test cache        │ test file hash     │ 10-30s          │
│  (jest cache,      │                    │                 │
│   pytest cache)    │                    │                 │
│                    │                    │                 │
│  Tool cache        │ version string     │ 20-60s          │
│  (Go, Node, Python │                    │                 │
│   runtime install) │                    │                 │
└──────────────────────────────────────────────────────────┘

Total estimated savings: 2-6 minutes per pipeline run
```

#### Docker Layer Caching
```dockerfile
# Optimized Dockerfile for CI caching
FROM node:20-slim AS base

# Dependencies layer (cached unless lockfile changes)
FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production=false

# Build layer (cached unless source changes)
FROM deps AS build
COPY . .
RUN npm run build

# Production layer (minimal image)
FROM base AS production
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --production
COPY --from=build /app/dist ./dist
USER node
CMD ["node", "dist/index.js"]
```

### Step 5: Pipeline Optimization
Analyze and improve pipeline performance:

```
PIPELINE PERFORMANCE ANALYSIS:
┌──────────────────────────────────────────────────────────┐
│  Stage          │ Current │ Optimized │ Savings           │
│  ─────────────────────────────────────────────────────── │
│  Checkout       │ 15s     │ 8s        │ Shallow clone     │
│  Install deps   │ 90s     │ 5s        │ Cache hit         │
│  Lint           │ 30s     │ 30s       │ —                 │
│  Type check     │ 45s     │ 45s       │ —                 │
│  Unit tests     │ 180s    │ 65s       │ 3x sharding       │
│  Integration    │ 120s    │ 120s      │ Parallel with unit│
│  Build image    │ 180s    │ 45s       │ Layer caching     │
│  Security scan  │ 60s     │ 60s       │ —                 │
│  Deploy staging │ 120s    │ 90s       │ Parallel verify   │
├──────────────────────────────────────────────────────────┤
│  TOTAL          │ 14m 0s  │ 7m 48s    │ -44%              │
│  Serial path    │ 14m 0s  │ 5m 30s    │ With parallelism  │
└──────────────────────────────────────────────────────────┘
```

#### Optimization Techniques
```
OPTIMIZATION CHECKLIST:
- [ ] Shallow clone (--depth 1) for CI builds
- [ ] Dependency caching with lockfile hash key
- [ ] Docker layer caching (BuildKit, GitHub cache)
- [ ] Test sharding (split tests across parallel workers)
- [ ] Parallel stages (lint + type check concurrently)
- [ ] Conditional stages (skip deploy on PRs)
- [ ] Incremental builds (only rebuild changed packages)
- [ ] Concurrency limits (cancel redundant runs)
- [ ] Timeout enforcement (prevent hung builds)
- [ ] Artifact size limits (don't upload unnecessary files)
- [ ] Matrix builds for multi-version testing
- [ ] Self-hosted runners for heavy workloads
```

### Step 6: Matrix Builds
Configure multi-version and multi-platform testing:

```yaml
# GitHub Actions matrix example
strategy:
  fail-fast: false
  matrix:
    os: [ubuntu-latest, macos-latest]
    node-version: [18, 20, 22]
    exclude:
      - os: macos-latest
        node-version: 18
    include:
      - os: ubuntu-latest
        node-version: 20
        coverage: true
```

```
MATRIX EXECUTION:
┌──────────────────────────────────────────────────────────┐
│  Combination              │ Status  │ Duration │ Result  │
│  ─────────────────────────────────────────────────────── │
│  ubuntu / node-18         │ PASS    │ 2m 15s   │ 42/42   │
│  ubuntu / node-20         │ PASS    │ 2m 08s   │ 42/42   │
│  ubuntu / node-22         │ PASS    │ 2m 22s   │ 42/42   │
│  macos / node-20          │ PASS    │ 3m 01s   │ 42/42   │
│  macos / node-22          │ PASS    │ 3m 12s   │ 42/42   │
├──────────────────────────────────────────────────────────┤
│  Total: 5/5 passing (all combinations green)              │
└──────────────────────────────────────────────────────────┘
```

### Step 7: Pipeline Templating
Create reusable pipeline components:

#### GitHub Actions — Composite Action
```yaml
# .github/actions/setup/action.yml
name: 'Project Setup'
description: 'Install dependencies with caching'
inputs:
  node-version:
    description: 'Node.js version'
    default: '20'
runs:
  using: composite
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'
    - run: npm ci
      shell: bash
```

#### GitHub Actions — Reusable Workflow
```yaml
# .github/workflows/reusable-deploy.yml
name: Deploy
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
      image-tag:
        required: true
        type: string
    secrets:
      DEPLOY_TOKEN:
        required: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    steps:
      - name: Deploy
        run: |
          echo "Deploying ${{ inputs.image-tag }} to ${{ inputs.environment }}"
```

### Step 8: Artifact Management
Handle build outputs, test results, and deployment packages:

```
ARTIFACT STRATEGY:
┌──────────────────────────────────────────────────────────┐
│  Artifact           │ Retention │ Size Limit │ Purpose    │
│  ─────────────────────────────────────────────────────── │
│  Test results (JUnit)│ 30 days  │ 10 MB      │ PR checks  │
│  Coverage reports   │ 30 days   │ 50 MB      │ Tracking   │
│  Docker images      │ 90 days   │ —          │ Deployment │
│  Build logs         │ 90 days   │ —          │ Debugging  │
│  SBOM               │ 365 days  │ 5 MB       │ Compliance │
│  SARIF (security)   │ 365 days  │ 10 MB      │ Audit      │
│  Release binaries   │ Permanent │ 500 MB     │ Distribution│
└──────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Report
```
1. Save pipeline configuration in `.github/workflows/`, `.gitlab-ci.yml`, or equivalent
2. Save reusable components in `.github/actions/` or equivalent
3. Commit: "cicd: <description> — <platform> pipeline (<N> stages, <estimated time>)"
4. If pipeline exists: Show optimization recommendations with estimated savings
5. If new pipeline: "Pipeline created. Push to trigger first run."
6. If fixing pipeline: Show root cause and fix applied
```

## Key Behaviors

1. **Fast feedback first.** Lint and type check run before tests. Fail fast on the cheapest checks.
2. **Cache aggressively.** Dependencies, Docker layers, build artifacts. Every second saved multiplies across every developer and every push.
3. **Parallelize where possible.** Lint, type check, and security scan have no dependencies on each other. Run them concurrently.
4. **Test sharding for speed.** Split test suites across parallel workers. A 6-minute test suite becomes 2 minutes on 3 shards.
5. **Environments as gates.** Staging deploys automatically. Production requires manual approval. No exceptions.
6. **Concurrency control.** Cancel redundant pipeline runs when new commits push. Do not waste compute on stale commits.
7. **Timeouts are mandatory.** Every job must have a timeout. A hung pipeline that runs for 6 hours costs money and blocks deployments.
8. **Secrets are injected, not stored.** Use platform-native secret management (GitHub Secrets, GitLab CI variables). Never echo secrets in logs.

## Example Usage

### Creating a new pipeline
```
User: /godmode:cicd Set up GitHub Actions for our Node.js API

CICD: Analyzing project...

PIPELINE CONTEXT:
  Platform: GitHub Actions (new)
  Language: TypeScript / Node.js 20
  Package Manager: npm
  Test Framework: Jest (42 tests)
  Linter: ESLint + Prettier
  Container: Dockerfile present
  Deploy Target: AWS ECS

Generating pipeline...

Created: .github/workflows/ci.yml
  Stages: lint -> test -> build -> security -> deploy
  Caching: npm dependencies (lockfile hash)
  Sharding: 3-way test parallelism
  Docker: BuildKit with GHA cache
  Environments: staging (auto), production (manual)

Estimated run time: ~5 minutes (with caching)

Created: .github/actions/setup/action.yml
  Reusable setup composite action

Pipeline ready. Push to main to trigger first run.
```

### Optimizing a slow pipeline
```
User: /godmode:cicd Our CI takes 18 minutes, make it faster

CICD: Analyzing pipeline performance...

BOTTLENECKS FOUND:
  1. npm install: 95s (no caching)
  2. Tests: 8m serial (no sharding)
  3. Docker build: 4m (no layer caching)
  4. Sequential stages that could parallelize

OPTIMIZATIONS APPLIED:
  1. Added dependency caching — saves 85s
  2. Added 3-way test sharding — saves 5m 20s
  3. Added Docker BuildKit + GHA cache — saves 3m
  4. Parallelized lint + type-check — saves 45s

RESULT:
  Before: 18m 0s
  After:  5m 30s
  Savings: -69%
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Analyze existing pipeline and suggest improvements |
| `--create` | Generate new pipeline from scratch |
| `--optimize` | Focus on performance optimization |
| `--platform <name>` | Target platform (github, gitlab, circleci, jenkins) |
| `--add-stage <name>` | Add a specific stage (security, deploy, e2e, etc.) |
| `--matrix` | Set up matrix builds for multi-version testing |
| `--template` | Create reusable pipeline components |
| `--fix` | Diagnose and fix failing pipeline |
| `--dry-run` | Show pipeline changes without writing files |

## HARD RULES

1. **NEVER STOP** until the pipeline is green or all failures are documented with root causes.
2. **git commit BEFORE verify** — commit pipeline config, then trigger a run to verify.
3. **Automatic revert on regression** — if a pipeline change increases total runtime by >20%, revert and reassess.
4. **TSV logging** — log every pipeline optimization:
   ```
   timestamp	stage	before_duration	after_duration	savings_pct	technique	status
   ```
5. **NEVER deploy to production without a staging gate.** No exceptions.
6. **NEVER use `latest` for action/image versions.** Pin to SHA or specific version.
7. **NEVER echo secrets in pipeline logs.** Use masking.
8. **ALWAYS set timeouts on every job.**
9. **ALWAYS cache dependencies with lockfile hash key.**

## Explicit Loop Protocol

When optimizing an existing pipeline:

```
current_iteration = 0
stages = list_all_pipeline_stages()
optimizations_applied = []

WHILE stages has unoptimized items:
    current_iteration += 1
    stage = stages.pop(0)

    # Measure current
    baseline_duration = measure(stage)

    # Identify optimizations
    opportunities = analyze(stage)  # caching, sharding, parallel, etc.

    FOR each opportunity in opportunities:
        apply(opportunity)
        new_duration = measure(stage)
        IF new_duration > baseline_duration:
            revert(opportunity)
        ELSE:
            optimizations_applied.append({stage, opportunity, savings})
            baseline_duration = new_duration

    git commit pipeline config

    IF current_iteration % 5 == 0:
        print(f"Progress: {current_iteration} stages optimized")
        print(f"Total savings so far: {sum(o.savings for o in optimizations_applied)}")

    IF all stages optimized:
        generate_report(optimizations_applied)
        BREAK
```

## Auto-Detection

On activation, automatically detect project context without asking:

```
AUTO-DETECT:
1. CI platform:
   ls .github/workflows/*.yml 2>/dev/null && echo "github-actions"
   ls .gitlab-ci.yml 2>/dev/null && echo "gitlab-ci"
   ls .circleci/config.yml 2>/dev/null && echo "circleci"
   ls Jenkinsfile 2>/dev/null && echo "jenkins"

2. Language and package manager:
   ls package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null  # Node.js
   ls Pipfile.lock requirements.txt pyproject.toml 2>/dev/null  # Python
   ls go.sum 2>/dev/null  # Go
   ls Cargo.lock 2>/dev/null  # Rust

3. Test framework:
   grep -r "jest\|vitest\|mocha\|pytest\|go test\|cargo test" package.json Makefile 2>/dev/null

4. Container:
   ls Dockerfile docker-compose.yml 2>/dev/null

5. Deploy target:
   grep -ri "ecs\|kubernetes\|k8s\|vercel\|netlify\|lambda" .github/ .gitlab-ci* 2>/dev/null

-> Auto-configure pipeline stages based on detected stack.
-> Auto-select caching strategy based on package manager.
-> Only ask user about deploy target if not detectable.
```

## Output Format
Print on completion: `CI/CD: {stage_count} stages, {job_count} jobs. Build: {build_time}. Test: {test_time}. Deploy: {deploy_target}. Cache: {cache_status}. Verdict: {verdict}.`

## TSV Logging
Log every pipeline optimization to `.godmode/cicd-results.tsv`:
```
iteration	stage	job_count	duration_before	duration_after	cache_hit_rate	status
1	build	3	240s	90s	95%	optimized
2	test	4	480s	180s	90%	sharded
3	security	2	120s	60s	80%	added
4	deploy	2	300s	300s	n/a	configured
```
Columns: iteration, stage, job_count, duration_before, duration_after, cache_hit_rate, status(optimized/sharded/added/configured/failed).

## Success Criteria
- Full pipeline runs in under 10 minutes (lint + test + build + deploy).
- Dependency caching enabled with lockfile hash key (cache hit rate > 90%).
- Tests parallelized across shards when suite exceeds 3 minutes.
- Security scanning included (dependency audit + container scan).
- Staging gate before production deployment.
- All action/image versions pinned (no `latest` tags).
- Secrets never echoed in logs (masked with `::add-mask::`).
- Timeout configured on every job to prevent hung pipelines.
- Flaky tests quarantined or fixed (zero intermittent failures).

## Error Recovery
- **Pipeline times out**: Check for hung tests or builds. Add `timeout-minutes` to every job. Identify the slow step with timing annotations. Split long steps into parallel jobs.
- **Cache miss on every run**: Verify the cache key includes the lockfile hash. Check that the cache path matches where dependencies are installed. Ensure the cache is not being evicted due to size limits.
- **Secret not available in workflow**: Check that the secret is defined at the correct scope (repo, environment, org). Verify the workflow has permission to access the environment. Secrets are not available in fork PRs by default.
- **Deployment fails but tests passed**: Check for environment-specific configuration differences. Verify the build artifact matches what was tested. Check deployment credentials and permissions.
- **Test sharding produces uneven splits**: Rebalance shards based on test duration, not test count. Use `--shard` with timing data. Ensure the slowest shard is under the target time.
- **Flaky test blocks the pipeline**: Do not add retries as a permanent fix. Quarantine the test with a skip annotation and a linked issue. Fix the root cause within 48 hours.

## Keep/Discard Discipline
```
After EACH pipeline optimization:
  1. MEASURE: Run the pipeline — compare total duration and cache hit rate to baseline.
  2. DECIDE:
     - KEEP if: duration decreased OR cache hit rate improved AND all tests still pass
     - DISCARD if: duration increased >5% OR cache hit rate dropped OR any test fails
  3. COMMIT kept changes. Revert discarded changes before trying the next optimization.

Never keep an optimization that makes the pipeline faster but breaks test reliability.
```

## Stuck Recovery
```
IF >5 consecutive optimizations produce no duration improvement:
  1. Re-measure the baseline — previous measurements may be noisy.
  2. Profile the pipeline step by step — the bottleneck may not be where you think.
  3. Look for architectural changes: test sharding, parallel stages, self-hosted runners.
  4. If still stuck → log stop_reason=optimization_plateau, report current pipeline performance.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - Pipeline runs in under 10 minutes (or user-defined target)
  - All stages optimized and no further improvements identified
  - User explicitly requests stop
  - Max iterations (15) reached

DO NOT STOP just because:
  - One stage cannot be optimized further (other stages might have room)
  - Cache hit rate is already >90% (there may be non-cache optimizations)
```

## Simplicity Criterion
```
PREFER the simpler pipeline design:
  - Single workflow file before splitting into reusable workflows (until duplication is real)
  - Built-in caching (actions/cache, Docker layer cache) before custom cache solutions
  - Sequential stages before parallel stages (parallelize only when serial is too slow)
  - Platform-native features before third-party actions (fewer dependencies = fewer breakages)
  - Fewer pipeline files with clear names over many small workflow fragments
```

## Multi-Agent Dispatch
For comprehensive CI/CD pipeline setup:
```
DISPATCH parallel agents (one per pipeline concern):

Agent 1 (worktree: cicd-build):
  - Build stage optimization (caching, parallel steps)
  - Container image build and push
  - Scope: .github/workflows/, Dockerfile, build scripts
  - Output: Optimized build pipeline

Agent 2 (worktree: cicd-test):
  - Test stage setup (unit, integration, E2E)
  - Test sharding and parallelization
  - Scope: .github/workflows/, test config files
  - Output: Parallelized test pipeline

## Platform Fallback
Run tasks sequentially with branch isolation if `Agent()` or `EnterWorktree` unavailable. See `adapters/shared/sequential-dispatch.md`.