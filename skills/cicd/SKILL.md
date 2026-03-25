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
  Platform: <GitHub Actions | GitLab CI | CircleCI |
  Jenkins | None detected>
  Language: <detected language/framework>
  Package Manager: <npm | pip | go mod | maven | etc.>
  Test Framework: <jest | pytest | go test | junit | etc.>
  Linter: <eslint | ruff | golangci-lint | etc.>
  Container: <Dockerfile present? Y/N>
  Deploy Target: <K8s | ECS | Lambda | Vercel | etc.>
  Existing Pipeline: <path to config or "none">
  Branch Strategy: <trunk-based | gitflow | github flow>
```

If no pipeline exists: "No CI/CD configuration found. Shall I create one? Specify your preferred platform (GitHub Actions, GitLab CI, CircleCI, Jenkins)."

### Step 2: Pipeline Architecture Design
Design the pipeline stages based on project needs:

```
PIPELINE ARCHITECTURE:
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
| Lint | -> | Test | -> | Build | -> | Security | -> | Deploy |
│         │    │         │    │         │    │         │    │         │
| Format |  | Unit |  | Docker |  | SAST |  | Staging |
|--|--|--|--|--|--|--|--|--|
| Lint |  | Integ. |  | Assets |  | Deps |  | Prod |
| Types |  | E2E |  | Publish |  | Secrets |  | Verify |
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
```

#### GitLab CI
```yaml
stages:
  - lint
  - test
  - build
  - security
  - deploy
```
CACHING STRATEGY:
| Cache Type | Key | Savings |
|--|--|--|
| Dependencies | lockfile hash | 30-90s |
| (node_modules, | (package-lock.json |  |
| .venv, vendor) | Pipfile.lock) |  |
| Build cache | source hash | 60-180s |
|--|--|--|
| (Docker layers, | (Dockerfile + |  |
| compiled assets) | source files) |  |
| Test cache | test file hash | 10-30s |
|--|--|--|
| (jest cache, |  |  |
| pytest cache) |  |  |
| Tool cache | version string | 20-60s |
|--|--|--|
| (Go, Node, Python |  |  |
| runtime install) |  |  |

Total estimated savings: 2-6 minutes per pipeline run
```

#### Docker Layer Caching
Multi-stage Dockerfile: deps layer (cached on lockfile hash) -> build layer (cached on source hash). Copy lockfile first, `npm ci`, then copy source.

### Step 5: Pipeline Optimization
Analyze and improve pipeline performance:

```
PIPELINE PERFORMANCE ANALYSIS:
| Stage | Current | Optimized | Savings |
|--|--|--|--|
| Checkout | 15s | 8s | Shallow clone |
| Install deps | 90s | 5s | Cache hit |
| Lint | 30s | 30s | — |
| Type check | 45s | 45s | — |
| Unit tests | 180s | 65s | 3x sharding |
| Integration | 120s | 120s | Parallel with unit |
| Build image | 180s | 45s | Layer caching |
| Security scan | 60s | 60s | — |
| Deploy staging | 120s | 90s | Parallel verify |
| TOTAL | 14m 0s | 7m 48s | -44% |
| Serial path | 14m 0s | 5m 30s | With parallelism |
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
```

```
MATRIX EXECUTION:
| Combination | Status | Duration | Result |
|--|--|--|--|
| ubuntu / node-18 | PASS | 2m 15s | 42/42 |
| ubuntu / node-20 | PASS | 2m 08s | 42/42 |
| ubuntu / node-22 | PASS | 2m 22s | 42/42 |
| macos / node-20 | PASS | 3m 01s | 42/42 |
| macos / node-22 | PASS | 3m 12s | 42/42 |
  Total: 5/5 passing (all combinations green)
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
```

#### GitHub Actions — Reusable Workflow
```yaml
# .github/workflows/reusable-deploy.yml
name: Deploy
on:
  workflow_call:
    inputs:
      environment:
```

### Step 8: Artifact Management
Handle build outputs, test results, and deployment packages:

```
ARTIFACT STRATEGY:
| Artifact | Retention | Size Limit | Purpose |
|--|--|--|--|
| Test results (JUnit) | 30 days | 10 MB | PR checks |
| Coverage reports | 30 days | 50 MB | Tracking |
| Docker images | 90 days | — | Deployment |
| Build logs | 90 days | — | Debugging |
| SBOM | 365 days | 5 MB | Compliance |
| SARIF (security) | 365 days | 10 MB | Audit |
| Release binaries | Permanent | 500 MB | Distribution |
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

```bash
# Run CI pipeline locally for testing
act -j test --secret-file .env.ci
docker build --target test -t app:test .
npm run lint && npm run typecheck && npm test
```

1. **Fast feedback first.** Lint before tests. Fail fast.
2. **Cache aggressively.** Dependencies, Docker layers, artifacts.
3. **Parallelize where possible.** Lint + typecheck concurrently.
4. **Test sharding.** 6 min suite -> 2 min on 3 shards.
5. **Environments as gates.** Staging auto, prod manual approval.
6. **Concurrency control.** Cancel stale pipeline runs.
7. **Timeouts mandatory.** Every job has a timeout.
8. **Secrets injected, not stored.** Never echo in logs.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Analyze existing pipeline and suggest improvements |
| `--create` | Generate new pipeline from scratch |
| `--optimize` | Focus on performance optimization |

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
Pipeline under 10 minutes. Dependency cache hit rate >90%. Tests sharded when >3min. Security scanning included. Staging gate before production. All versions pinned (no `latest`). Secrets masked. Timeouts on every job. Zero flaky tests.

## Error Recovery
| Failure | Action |
|--|--|
| Pipeline times out | Add `timeout-minutes` to every job. Identify slow step, split into parallel jobs. |
| Cache miss every run | Verify cache key includes lockfile hash. Check cache path matches install location. |
| Secret not available | Check scope (repo/env/org). Secrets unavailable in fork PRs by default. |
| Deploy fails, tests pass | Check env-specific config, verify artifact matches tested build. |
| Flaky test blocks pipeline | Quarantine with skip annotation + linked issue. Fix root cause within 48h. |

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

## Stop Conditions
```
STOP when: pipeline < 10 minutes OR all stages optimized
  OR user requests stop OR max 15 iterations
DO NOT STOP because one stage is at limit or cache > 90%.
```

