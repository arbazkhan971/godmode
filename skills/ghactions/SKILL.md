---
name: ghactions
description: GitHub Actions workflows, custom actions, CI/CD on GitHub, matrix builds. Use when user mentions GitHub Actions, workflow, .github/workflows, actions, CI pipeline on GitHub, matrix strategy.
---

# GHACTIONS — GitHub Actions Expert

## When to Activate
- User invokes `/godmode:ghactions`
- User says "create workflow", "add GitHub Actions", "set up Actions"
- User says "workflow is failing", "fix Actions", "Actions is slow"
- User says "matrix build", "reusable workflow", "composite action"
- User says "workflow_dispatch", "cron schedule", "on push"
- User mentions `.github/workflows/`, `action.yml`, or `workflow_call`
- Project needs CI/CD specifically on GitHub Actions
- User wants to create a custom JavaScript or Docker action

## Workflow

### Step 1: Discover Repository Context
Analyze the repository to determine what workflows are needed:

```
REPOSITORY CONTEXT:
┌──────────────────────────────────────────────────────────┐
│  Existing Workflows: <list .github/workflows/*.yml>      │
│  Language: <detected language/framework>                  │
│  Package Manager: <npm | pnpm | yarn | pip | go mod>     │
│  Test Framework: <jest | vitest | pytest | go test>       │
│  Linter: <eslint | ruff | golangci-lint | etc.>          │
│  Dockerfile: <present | absent>                           │
│  Monorepo: <yes/no — turbo | nx | lerna>                 │
│  Branch Protection: <rules detected>                      │
│  Environments: <staging | production | custom>            │
│  Secrets Configured: <list of secret names>               │
└──────────────────────────────────────────────────────────┘
```

If no workflows exist: "No `.github/workflows/` directory found. I'll create one with a production-ready workflow. What does this project need — CI, deployment, release automation, or all three?"

### Step 2: Workflow Syntax — Triggers
Select and configure the right event triggers:

```yaml
# Push and PR triggers with path filtering
on:
  push:
    branches: [main, develop]
    paths:
      - 'src/**'
      - 'package.json'
      - '.github/workflows/**'
    paths-ignore:
      - '**.md'
      - 'docs/**'
  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened]

  # Scheduled runs (e.g., nightly security scan)
  schedule:
    - cron: '0 2 * * 1'  # Every Monday at 2 AM UTC

  # Manual trigger with inputs
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - production
      dry-run:
        description: 'Dry run (no actual deploy)'
        required: false
        type: boolean
        default: false

  # Triggered by another workflow
  workflow_call:
    inputs:
      image-tag:
        required: true
        type: string
    secrets:
      DEPLOY_TOKEN:
        required: true
    outputs:
      deploy-url:
        description: 'Deployed URL'
        value: ${{ jobs.deploy.outputs.url }}
```

```
TRIGGER SELECTION GUIDE:
┌──────────────────────────────────────────────────────────┐
│  Trigger              │ Use Case                          │
│  ─────────────────────────────────────────────────────── │
│  push                 │ CI on merge, deploy on main       │
│  pull_request         │ PR checks, preview deploys        │
│  pull_request_target  │ Label PRs from forks safely       │
│  schedule             │ Nightly builds, security scans    │
│  workflow_dispatch    │ Manual deploys, ad-hoc tasks      │
│  workflow_call        │ Reusable workflow invocation       │
│  release              │ Publish packages on tag/release    │
│  workflow_run         │ Chain workflows after completion   │
│  repository_dispatch  │ External system triggers           │
│  merge_group          │ Merge queue validation             │
└──────────────────────────────────────────────────────────┘
```

### Step 3: Jobs, Steps, and Matrix Strategy
Structure jobs with dependencies, matrix builds, and services:

```yaml
jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run type-check

  test:
    name: Test (${{ matrix.os }} / Node ${{ matrix.node-version }})
    runs-on: ${{ matrix.os }}
    timeout-minutes: 20
    needs: lint
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
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - run: npm ci

      - name: Run tests
        run: npm test -- --coverage=${{ matrix.coverage || 'false' }}
        env:
          DATABASE_URL: postgres://postgres:test@localhost:5432/testdb

      - name: Upload coverage
        if: matrix.coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
          retention-days: 14
```

```
MATRIX EXECUTION MAP:
┌──────────────────────────────────────────────────────────┐
│  Combination              │ Status  │ Duration │ Tests   │
│  ─────────────────────────────────────────────────────── │
│  ubuntu / node-18         │ RUN     │ ~2m      │ 120     │
│  ubuntu / node-20 (+cov)  │ RUN     │ ~2m 30s  │ 120     │
│  ubuntu / node-22         │ RUN     │ ~2m      │ 120     │
│  macos / node-20          │ RUN     │ ~3m      │ 120     │
│  macos / node-22          │ RUN     │ ~3m      │ 120     │
│  macos / node-18          │ SKIP    │ —        │ excl.   │
├──────────────────────────────────────────────────────────┤
│  5 combinations run in parallel, fail-fast disabled       │
└──────────────────────────────────────────────────────────┘
```

### Step 4: Reusable Workflows
Create DRY, shareable workflows with `workflow_call`:

```yaml
# .github/workflows/reusable-ci.yml
name: Reusable CI

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'
      working-directory:
        required: false
        type: string
        default: '.'
      run-e2e:
        required: false
        type: boolean
        default: false
    secrets:
      NPM_TOKEN:
        required: false

permissions:
  contents: read
  checks: write

jobs:
  ci:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'
          cache-dependency-path: '${{ inputs.working-directory }}/package-lock.json'

      - run: npm ci
        env:
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}

      - run: npm run lint
      - run: npm run type-check
      - run: npm test

      - name: E2E tests
        if: inputs.run-e2e
        run: npm run test:e2e
```

```yaml
# .github/workflows/ci.yml — caller workflow
name: CI
on:
  pull_request:
    branches: [main]

jobs:
  ci:
    uses: ./.github/workflows/reusable-ci.yml
    with:
      node-version: '20'
      run-e2e: true
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}

  # Monorepo: call the same workflow for each package
  ci-api:
    uses: ./.github/workflows/reusable-ci.yml
    with:
      working-directory: 'packages/api'

  ci-web:
    uses: ./.github/workflows/reusable-ci.yml
    with:
      working-directory: 'packages/web'
      run-e2e: true
```

### Step 5: Composite Actions
Build custom actions that encapsulate multi-step logic:

```yaml
# .github/actions/setup-project/action.yml
name: 'Setup Project'
description: 'Install dependencies with caching and optional build'
inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '20'
  install-command:
    description: 'Install command'
    required: false
    default: 'npm ci'
  build:
    description: 'Run build after install'
    required: false
    default: 'false'
outputs:
  cache-hit:
    description: 'Whether cache was hit'
    value: ${{ steps.cache.outputs.cache-hit }}
runs:
  using: composite
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'

    - id: cache
      uses: actions/cache@v4
      with:
        path: node_modules
        key: deps-${{ runner.os }}-${{ hashFiles('package-lock.json') }}
        restore-keys: |
          deps-${{ runner.os }}-

    - name: Install dependencies
      if: steps.cache.outputs.cache-hit != 'true'
      run: ${{ inputs.install-command }}
      shell: bash

    - name: Build
      if: inputs.build == 'true'
      run: npm run build
      shell: bash
```

```yaml
# Usage in any workflow
steps:
  - uses: actions/checkout@v4
  - uses: ./.github/actions/setup-project
    with:
      build: 'true'
  - run: npm test
```

### Step 6: Caching Strategies
Maximize cache hits to minimize install and build times:

```
CACHING STRATEGY MAP:
┌──────────────────────────────────────────────────────────┐
│  What to Cache       │ Key Formula          │ Savings     │
│  ─────────────────────────────────────────────────────── │
│  npm/pnpm/yarn       │ lockfile hash         │ 30-90s     │
│  pip / venv          │ requirements hash     │ 20-60s     │
│  Go modules          │ go.sum hash           │ 15-45s     │
│  Rust target/        │ Cargo.lock hash       │ 60-300s    │
│  Docker layers       │ BuildKit GHA backend  │ 60-180s    │
│  Turborepo           │ turbo hash            │ 30-120s    │
│  Next.js .next/cache │ source hash           │ 30-90s     │
│  Gradle / Maven      │ build file hash       │ 30-120s    │
│  Playwright browsers │ version string        │ 60-90s     │
└──────────────────────────────────────────────────────────┘
```

```yaml
# Advanced caching — multiple paths, restore keys
- uses: actions/cache@v4
  id: deps-cache
  with:
    path: |
      node_modules
      ~/.npm
      .next/cache
    key: deps-${{ runner.os }}-${{ hashFiles('package-lock.json') }}-${{ hashFiles('src/**') }}
    restore-keys: |
      deps-${{ runner.os }}-${{ hashFiles('package-lock.json') }}-
      deps-${{ runner.os }}-

# Built-in caching via setup actions (preferred)
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'           # Automatically caches ~/.npm

- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'           # Automatically caches pip

- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
    cache: true            # Automatically caches Go modules

# Docker layer caching with BuildKit
- uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

### Step 7: Secrets and Environment Management
Handle secrets securely and configure deployment environments:

```yaml
# Environment-scoped secrets and protection rules
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - name: Deploy
        run: ./deploy.sh
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          DEPLOY_URL: ${{ vars.DEPLOY_URL }}  # Environment variables (non-secret)

  deploy-production:
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment:
      name: production
      url: https://app.example.com
    # Production environment configured in repo settings:
    #   - Required reviewers (1-6 approvers)
    #   - Wait timer (e.g., 15 minutes)
    #   - Deployment branch restriction (main only)
    steps:
      - name: Deploy
        run: ./deploy.sh --production
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

```
ENVIRONMENT PROTECTION RULES:
┌──────────────────────────────────────────────────────────┐
│  Environment  │ Reviewers │ Wait  │ Branch │ Secrets     │
│  ─────────────────────────────────────────────────────── │
│  development  │ 0         │ 0     │ any    │ DEV_*       │
│  staging      │ 0         │ 0     │ main   │ STG_*       │
│  production   │ 2         │ 15m   │ main   │ PROD_*      │
│  preview      │ 0         │ 0     │ PR     │ PREVIEW_*   │
└──────────────────────────────────────────────────────────┘
```

```yaml
# OIDC authentication — no long-lived secrets needed
permissions:
  id-token: write
  contents: read

steps:
  - name: Configure AWS credentials via OIDC
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-actions
      aws-region: us-east-1
      # No access key secrets needed — uses GitHub's OIDC token

  - name: Authenticate to Google Cloud via OIDC
    uses: google-github-actions/auth@v2
    with:
      workload_identity_provider: 'projects/123/locations/global/workloadIdentityPools/github/providers/repo'
      service_account: 'deploy@project.iam.gserviceaccount.com'
```

### Step 8: Artifact Upload and Download
Pass data between jobs and persist build outputs:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm run build

      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-output
          path: |
            dist/
            !dist/**/*.map
          retention-days: 7
          compression-level: 6
          if-no-files-found: error

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: |
            junit.xml
            coverage/lcov.info
          retention-days: 30

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-output
          path: dist/

      - name: Deploy
        run: |
          ls -la dist/
          # deploy dist/ to production

  # Merge artifacts from matrix jobs
  collect-coverage:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          pattern: coverage-*
          merge-multiple: true
          path: coverage/

      - name: Merge coverage
        run: npx nyc merge coverage/ merged.json
```

```
ARTIFACT LIFECYCLE:
┌──────────────────────────────────────────────────────────┐
│  Artifact Type    │ Retention │ Compression │ Max Size    │
│  ─────────────────────────────────────────────────────── │
│  Build output     │ 7 days    │ level 6     │ ~50 MB      │
│  Test results     │ 30 days   │ level 6     │ ~10 MB      │
│  Coverage reports │ 14 days   │ level 6     │ ~20 MB      │
│  Docker SBOM      │ 90 days   │ level 9     │ ~5 MB       │
│  Release binaries │ 90 days   │ level 9     │ ~500 MB     │
│  Debug logs       │ 3 days    │ level 1     │ ~100 MB     │
├──────────────────────────────────────────────────────────┤
│  GitHub limit: 500 MB per artifact, 10 GB per repo       │
└──────────────────────────────────────────────────────────┘
```

### Step 9: Conditional Execution
Control when jobs and steps run:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    # Job-level conditions
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      # Skip if commit message contains [skip ci]
      - name: Check skip
        if: "!contains(github.event.head_commit.message, '[skip ci]')"
        run: echo "Running CI"

      # Run only on specific file changes
      - uses: dorny/paths-filter@v3
        id: changes
        with:
          filters: |
            backend:
              - 'src/api/**'
              - 'src/lib/**'
            frontend:
              - 'src/app/**'
              - 'src/components/**'
            infra:
              - 'terraform/**'
              - 'Dockerfile'

      - name: Deploy backend
        if: steps.changes.outputs.backend == 'true'
        run: ./deploy-backend.sh

      - name: Deploy frontend
        if: steps.changes.outputs.frontend == 'true'
        run: ./deploy-frontend.sh

      # Always run cleanup, even on failure
      - name: Cleanup
        if: always()
        run: ./cleanup.sh

      # Run only on failure
      - name: Notify on failure
        if: failure()
        run: |
          curl -X POST "${{ secrets.SLACK_WEBHOOK }}" \
            -d '{"text":"Deploy failed: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"}'

      # Run on success only
      - name: Tag release
        if: success()
        run: |
          git tag "v${{ github.run_number }}"
          git push origin "v${{ github.run_number }}"
```

```
CONDITION REFERENCE:
┌──────────────────────────────────────────────────────────┐
│  Condition                     │ Evaluates True When      │
│  ─────────────────────────────────────────────────────── │
│  success()                     │ All previous steps pass  │
│  failure()                     │ Any previous step fails  │
│  always()                      │ Always (even cancelled)  │
│  cancelled()                   │ Workflow was cancelled    │
│  github.ref == 'refs/heads/m'  │ Push to main branch      │
│  github.event_name == 'PR'     │ Triggered by PR          │
│  contains(matrix.os, 'ubuntu') │ Matrix value matches     │
│  startsWith(github.ref, 'v')   │ Tag push (v1.0.0)        │
│  github.actor == 'dependabot'  │ Dependabot triggered     │
└──────────────────────────────────────────────────────────┘
```

### Step 10: Workflow Optimization
Maximize speed and minimize cost:

```yaml
# Concurrency — cancel redundant runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
  # PRs: cancel old runs. Main: let all complete.

# Path filters — skip irrelevant workflows
on:
  push:
    paths:
      - 'src/**'
      - 'tests/**'
      - 'package.json'
    paths-ignore:
      - '**.md'
      - '.vscode/**'
      - 'docs/**'

# Timeout every job
jobs:
  build:
    timeout-minutes: 15
    runs-on: ubuntu-latest
    steps:
      # Shallow clone for speed
      - uses: actions/checkout@v4
        with:
          fetch-depth: 1

      # Skip duplicate runs
      - uses: fkirc/skip-duplicate-actions@v5
        id: skip
        with:
          concurrent_skipping: same_content_newer

      - if: steps.skip.outputs.should_skip != 'true'
        run: npm test
```

```
OPTIMIZATION CHECKLIST:
┌──────────────────────────────────────────────────────────┐
│  Technique                │ Savings   │ Complexity         │
│  ─────────────────────────────────────────────────────── │
│  Concurrency groups       │ ~30-50%   │ Low — 3 lines      │
│  Path filters             │ ~20-40%   │ Low — 5 lines      │
│  Shallow clone            │ 5-15s     │ Low — 1 line        │
│  Dependency caching       │ 30-90s    │ Low — built-in      │
│  Test sharding            │ 50-70%    │ Medium — matrix     │
│  Docker layer caching     │ 60-180s   │ Medium — BuildKit   │
│  Skip duplicate runs      │ ~20%      │ Low — action        │
│  Composite actions (DRY)  │ maint.    │ Medium — refactor   │
│  Self-hosted runners      │ ~50%      │ High — infra        │
│  Larger runners           │ ~30-50%   │ Low — config        │
│  ARM runners (cheaper)    │ ~37% cost │ Low — label         │
└──────────────────────────────────────────────────────────┘

TOTAL POTENTIAL: 60-80% faster workflows
```

### Step 11: Custom JavaScript and Docker Actions
Create custom actions for unique automation needs:

```yaml
# JavaScript action — action.yml
name: 'PR Size Labeler'
description: 'Labels PRs based on diff size'
inputs:
  token:
    description: 'GitHub token'
    required: true
  xs-max:
    description: 'Max lines for XS label'
    default: '10'
  s-max:
    description: 'Max lines for S label'
    default: '50'
outputs:
  label:
    description: 'The label applied'
runs:
  using: node20
  main: dist/index.js
```

```javascript
// index.js — custom JavaScript action
const core = require('@actions/core');
const github = require('@actions/github');

async function run() {
  try {
    const token = core.getInput('token', { required: true });
    const octokit = github.getOctokit(token);
    const { context } = github;

    const { data: pr } = await octokit.rest.pulls.get({
      ...context.repo,
      pull_number: context.payload.pull_request.number,
    });

    const additions = pr.additions + pr.deletions;
    const xsMax = parseInt(core.getInput('xs-max'));
    const sMax = parseInt(core.getInput('s-max'));

    let label;
    if (additions <= xsMax) label = 'size/xs';
    else if (additions <= sMax) label = 'size/s';
    else if (additions <= 200) label = 'size/m';
    else if (additions <= 500) label = 'size/l';
    else label = 'size/xl';

    await octokit.rest.issues.addLabels({
      ...context.repo,
      issue_number: context.payload.pull_request.number,
      labels: [label],
    });

    core.setOutput('label', label);
    core.info(`Applied label: ${label} (${additions} lines changed)`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
```

```yaml
# Docker action — action.yml
name: 'Database Migration'
description: 'Runs database migrations in a container'
inputs:
  database-url:
    description: 'Database connection string'
    required: true
  command:
    description: 'Migration command'
    default: 'migrate'
runs:
  using: docker
  image: Dockerfile
  args:
    - ${{ inputs.command }}
  env:
    DATABASE_URL: ${{ inputs.database-url }}
```

### Step 12: Security Hardening
Lock down workflows against supply-chain and injection attacks:

```yaml
# 1. Pin actions to full-length commit SHA (not tags)
steps:
  - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
  - uses: actions/setup-node@60edb5dd545a775178f52524783378180af0d1f8 # v4.0.2

# 2. Minimal permissions (never use permissions: write-all)
permissions:
  contents: read
  # Add only what you need:
  # packages: write      — push to GHCR
  # security-events: write — upload SARIF
  # id-token: write       — OIDC auth
  # pull-requests: write  — comment on PRs

# 3. Prevent script injection — never interpolate directly in run:
steps:
  # BAD — vulnerable to injection:
  # - run: echo "PR title: ${{ github.event.pull_request.title }}"

  # GOOD — use environment variable:
  - name: Safe title handling
    env:
      PR_TITLE: ${{ github.event.pull_request.title }}
    run: echo "PR title: $PR_TITLE"

# 4. Restrict fork access
  - name: Build
    if: github.event.pull_request.head.repo.full_name == github.repository
    run: npm run build
    env:
      SECRET_KEY: ${{ secrets.SECRET_KEY }}

# 5. OpenSSF Scorecard — automated security analysis
name: Scorecard
on:
  schedule:
    - cron: '0 6 * * 1'
  push:
    branches: [main]

permissions: read-all

jobs:
  scorecard:
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: ossf/scorecard-action@v2
        with:
          results_file: scorecard.sarif
          results_format: sarif
      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: scorecard.sarif
```

```
SECURITY CHECKLIST:
┌──────────────────────────────────────────────────────────┐
│  ✓  Pin actions to SHA digests (not mutable tags)         │
│  ✓  Use least-privilege permissions per workflow           │
│  ✓  Never interpolate user input directly in run:          │
│  ✓  Use OIDC instead of long-lived credential secrets      │
│  ✓  Restrict secret access from fork PRs                   │
│  ✓  Enable Dependabot for action version updates           │
│  ✓  Run OpenSSF Scorecard weekly                           │
│  ✓  Scan container images with Trivy/Grype                 │
│  ✓  Audit npm/pip dependencies in CI                       │
│  ✓  Use CODEOWNERS to protect .github/workflows/           │
│  ✓  Enable branch protection + required status checks      │
│  ✓  Use merge queues for serialized main branch merges     │
└──────────────────────────────────────────────────────────┘
```

### Step 13: Deployment Environments with Approvals
Configure gated deployments with manual approval and rollback:

```yaml
jobs:
  deploy-staging:
    runs-on: ubuntu-latest
    environment:
      name: staging
      url: ${{ steps.deploy.outputs.url }}
    outputs:
      url: ${{ steps.deploy.outputs.url }}
    steps:
      - uses: actions/checkout@v4

      - id: deploy
        name: Deploy to staging
        run: |
          URL=$(./deploy.sh --env staging)
          echo "url=$URL" >> "$GITHUB_OUTPUT"

      - name: Smoke tests
        run: |
          curl -sf "${{ steps.deploy.outputs.url }}/health" || exit 1
          npm run test:smoke -- --base-url="${{ steps.deploy.outputs.url }}"

  deploy-production:
    runs-on: ubuntu-latest
    needs: deploy-staging
    environment:
      name: production
      url: https://app.example.com
    # This job pauses until a required reviewer approves in the GitHub UI
    steps:
      - uses: actions/checkout@v4

      - name: Blue-green deploy
        run: |
          # Deploy to green slot
          ./deploy.sh --env production --slot green
          # Verify green slot
          curl -sf https://green.app.example.com/health || exit 1
          # Swap traffic
          ./deploy.sh --swap green

      - name: Post-deploy verification
        run: |
          npm run test:smoke -- --base-url=https://app.example.com
          # Verify error rate stays below threshold
          ./check-error-rate.sh --threshold 0.1

      - name: Rollback on failure
        if: failure()
        run: |
          ./deploy.sh --rollback
          echo "::warning::Production deploy failed. Rolled back."

      - name: Notify
        if: always()
        uses: slackapi/slack-github-action@v1
        with:
          payload: |
            {
              "text": "Production deploy ${{ job.status }}: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Step 14: Commit and Report
```
1. Save workflow files in `.github/workflows/`
2. Save composite actions in `.github/actions/<name>/action.yml`
3. Save reusable workflows in `.github/workflows/reusable-*.yml`
4. Commit: "ci: <description> — GitHub Actions (<N> jobs, <estimated time>)"
5. Provide summary of:
   - Workflows created/modified
   - Trigger configuration
   - Estimated run time (with caching)
   - Security measures applied
   - Next steps (enable environments, add secrets, configure branch protection)
```

## Key Behaviors

1. **Least privilege permissions.** Every workflow declares only the permissions it needs. Never use `permissions: write-all`. Default to `contents: read`.
2. **Pin actions to SHA.** Tags are mutable. A compromised action can push a new tag. Pin to the full commit SHA and use Dependabot to update.
3. **Cancel redundant runs.** Use concurrency groups. When a new commit pushes on a PR, cancel the in-progress run for that PR. Do not waste minutes.
4. **Cache everything.** Dependencies via setup actions, Docker layers via BuildKit GHA backend, build outputs via actions/cache. Every cache miss costs 30-120 seconds.
5. **Fail fast on cheap checks.** Lint and format in under a minute. Type check next. Tests last. Do not wait 5 minutes for tests before discovering a lint error.
6. **Matrix builds for compatibility.** Test across OS and runtime versions. Use `fail-fast: false` so one failure does not cancel useful results from other combinations.
7. **Environments gate production.** Staging deploys automatically. Production requires manual approval. Configure required reviewers in repository settings.
8. **Secrets never leak.** Use OIDC for cloud providers. Scope secrets to environments. Never interpolate untrusted input in `run:` blocks.
9. **Timeouts on every job.** A hung workflow burns Actions minutes. Set `timeout-minutes` on every job. 15 minutes is a good default.
10. **DRY with reusable workflows.** If two workflows share the same CI steps, extract a reusable workflow. Monorepos call it once per package.

## Example Usage

### Creating a CI workflow
```
User: /godmode:ghactions Set up CI for our TypeScript monorepo

GHACTIONS: Analyzing repository...

REPOSITORY CONTEXT:
  Existing Workflows: none
  Language: TypeScript (monorepo — turbo)
  Packages: apps/web, apps/api, packages/shared
  Package Manager: pnpm
  Test Framework: vitest
  Linter: ESLint + Prettier

Creating workflows...

Created: .github/workflows/ci.yml
  Trigger: push to main, PRs to main
  Concurrency: cancel-in-progress on PRs
  Path filters: skip docs-only changes
  Jobs: lint -> test (matrix: 3 packages) -> build
  Caching: pnpm store + turbo remote cache
  Permissions: contents: read

Created: .github/actions/setup-project/action.yml
  Composite action: pnpm install + turbo cache

Estimated run time: ~4 minutes (with caching)
Security: pinned actions, minimal permissions

Push to trigger first run.
```

### Adding deployment with environments
```
User: /godmode:ghactions Add staging and production deploys with approval gates

GHACTIONS: Adding deployment workflow...

Created: .github/workflows/deploy.yml
  Trigger: push to main (after CI passes)
  Jobs:
    deploy-staging:
      Environment: staging (auto-deploy)
      Auth: AWS OIDC (no long-lived secrets)
      Smoke tests after deploy
    deploy-production:
      Environment: production (requires 2 reviewers)
      Blue-green deploy with rollback
      Post-deploy verification
      Slack notification on completion

ACTION REQUIRED:
  1. Create 'staging' and 'production' environments in repo settings
  2. Add required reviewers to 'production' environment
  3. Configure AWS OIDC trust policy for GitHub Actions
  4. Add SLACK_WEBHOOK_URL secret to repository
```

### Hardening an existing workflow
```
User: /godmode:ghactions Harden our workflows for security

GHACTIONS: Auditing workflow security...

FINDINGS:
  1. actions/checkout@v4 — mutable tag (pin to SHA)
  2. permissions not set — defaults to write-all
  3. Untrusted input in run: block (injection risk)
  4. Fork PRs have access to secrets
  5. No Scorecard or dependency audit

FIXES APPLIED:
  1. Pinned all actions to full commit SHA
  2. Added explicit permissions: contents: read
  3. Moved interpolations to env: variables
  4. Added fork-detection condition on secret steps
  5. Created .github/workflows/scorecard.yml

  Security score: 3/10 -> 9/10
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Analyze existing workflows and suggest improvements |
| `--create` | Generate new workflow from scratch |
| `--deploy` | Add deployment workflow with environments |
| `--matrix` | Set up matrix builds for multi-version testing |
| `--reusable` | Extract reusable workflows from existing config |
| `--composite` | Create composite action for shared steps |
| `--custom-action` | Scaffold a custom JavaScript or Docker action |
| `--harden` | Security audit and hardening of workflows |
| `--optimize` | Focus on speed and cost optimization |
| `--cron` | Add scheduled workflow (nightly build, cleanup, etc.) |
| `--fix` | Diagnose and fix failing workflow |
| `--dry-run` | Show workflow changes without writing files |

## HARD RULES

1. **NEVER use `permissions: write-all`.** Declare minimum permissions per job. Broad permissions are an exploit surface.
2. **NEVER pin actions to mutable tags.** `actions/checkout@v4` can change. Pin to full commit SHA. Use Dependabot for updates.
3. **NEVER interpolate untrusted input in `run:` blocks.** `${{ github.event.pull_request.title }}` is a script injection vector. Use `env:` variables.
4. **NEVER share secrets with fork PRs.** Gate secret access with `github.event.pull_request.head.repo.full_name == github.repository`.
5. **ALWAYS set `timeout-minutes` on every job.** Without it, workflows can run up to 6 hours. Set explicit timeouts.
6. **ALWAYS use concurrency groups to cancel redundant runs.** Five quick commits without concurrency means five redundant workflow runs.
7. **ALWAYS set `retention-days` on artifact uploads.** Default 90-day retention balloons storage costs.
8. **NEVER use `continue-on-error: true` to fix flaky steps.** It masks real failures. Fix the flakiness or quarantine the test.

## Auto-Detection

On activation, detect the GitHub Actions context:

```bash
# Detect existing workflows
ls .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null

# Detect actions used
grep -rh "uses:" .github/workflows/ 2>/dev/null | sort -u

# Detect security issues (unpinned actions)
grep -rn "uses:.*@v[0-9]" .github/workflows/ 2>/dev/null | head -10

# Detect missing permissions
grep -L "permissions:" .github/workflows/*.yml 2>/dev/null

# Detect missing timeouts
grep -L "timeout-minutes:" .github/workflows/*.yml 2>/dev/null
```

## Anti-Patterns

- **Do NOT use `permissions: write-all`.** Declare the minimum permissions each workflow needs. Broad permissions are an exploit surface.
- **Do NOT pin actions to mutable tags.** `uses: actions/checkout@v4` can change under you. Pin to the full commit SHA. Use Dependabot for updates.
- **Do NOT interpolate untrusted input in `run:` blocks.** `${{ github.event.pull_request.title }}` in a `run:` step is a script injection vector. Use `env:` variables instead.
- **Do NOT share secrets with fork PRs.** `pull_request_target` runs with repo secrets. Forks can exploit this. Gate secret access with `github.event.pull_request.head.repo.full_name == github.repository`.
- **Do NOT skip concurrency groups.** Without them, every push queues a new run. Five quick commits means five redundant runs burning Actions minutes.
- **Do NOT omit timeouts.** A workflow without `timeout-minutes` can run for up to 6 hours by default. Set explicit timeouts on every job.
- **Do NOT duplicate steps across workflows.** Extract shared logic into composite actions or reusable workflows. Duplication means divergence.
- **Do NOT upload artifacts without retention limits.** Default retention is 90 days. Set `retention-days` to avoid ballooning storage costs.
- **Do NOT ignore the Actions usage report.** Monitor minutes consumption in repository settings. Self-hosted runners or larger runners may be more cost-effective at scale.
- **Do NOT use `continue-on-error: true` as a fix for flaky steps.** It masks real failures. Fix the flakiness or quarantine the test.

## Output Format
Print on completion: `GH Actions: {workflow_count} workflows, {job_count} jobs. Duration: {total_time}. Cache: {cache_hit_rate}%. Security: {security_issues} issues. Minutes/run: {minutes}. Verdict: {verdict}.`

## TSV Logging
Log every workflow optimization to `.godmode/ghactions-results.tsv`:
```
iteration	workflow	jobs	duration_before	duration_after	cache_hit_rate	security_fixes	status
1	ci.yml	4	12m	5m	92%	3	optimized
2	deploy.yml	3	8m	6m	85%	2	hardened
3	release.yml	2	15m	10m	90%	1	optimized
```
Columns: iteration, workflow, jobs, duration_before, duration_after, cache_hit_rate, security_fixes, status(created/optimized/hardened/failed).

## Success Criteria
- All workflows have explicit `permissions:` (no write-all).
- All third-party actions pinned to full commit SHA (not mutable tag).
- All jobs have `timeout-minutes` configured.
- Concurrency groups configured to cancel redundant runs.
- Dependency caching enabled with lockfile hash key.
- No untrusted input interpolated in `run:` blocks.
- Secrets never echoed in logs.
- Artifact retention configured with explicit `retention-days`.
- Total pipeline duration under 10 minutes for PR checks.

## Error Recovery
- **Workflow syntax error**: Run `actionlint` locally before pushing. Check YAML indentation. Validate with `act` for local testing.
- **Action fails with permission denied**: Add the required permission to the `permissions:` block. Common: `contents: read`, `pull-requests: write`, `packages: write`.
- **Cache miss every run**: Verify the cache key matches the actual lockfile path. Check that `actions/cache` is using `hashFiles('**/package-lock.json')`. Ensure the cache path matches the install directory.
- **Secret not available in fork PR**: Secrets are not passed to fork PRs by default. Use `pull_request_target` with caution, or require forks to set their own secrets.
- **Workflow runs too long**: Add `timeout-minutes` to the job. Check for hung processes. Split long jobs into parallel steps. Enable test sharding.
- **Concurrency group cancels needed runs**: Use `cancel-in-progress: false` for deploy workflows. Use `cancel-in-progress: true` only for PR checks where the latest commit is all that matters.

## Iterative Loop Protocol
```
current_workflow = 0
workflows = detect_github_workflows()

WHILE current_workflow < len(workflows):
  workflow = workflows[current_workflow]
  1. AUDIT: Check permissions, pinned versions, timeouts, caching, secrets handling
  2. FIX security issues: pin actions to SHA, restrict permissions, mask secrets
  3. OPTIMIZE performance: add caching, enable concurrency groups, parallelize jobs
  4. VALIDATE: run actionlint, verify with dry-run
  5. LOG to .godmode/ghactions-results.tsv
  6. current_workflow += 1
  7. REPORT: "Workflow {current_workflow}/{total}: {workflow} — {security_fixes} security fixes, {duration_before} → {duration_after}"

EXIT when all workflows optimized OR user requests stop
```

## Keep/Discard Discipline
```
After EACH workflow optimization or security fix:
  1. MEASURE: Run actionlint and trigger a test run — does the workflow pass?
  2. COMPARE: Is the workflow faster/more secure than before?
  3. DECIDE:
     - KEEP if: workflow passes AND duration improved (or security issue fixed) AND no regressions
     - DISCARD if: workflow fails OR duration increased >10% OR new security issue introduced
  4. COMMIT kept changes. Revert discarded changes before the next optimization.
```

## Stuck Recovery
```
IF >3 consecutive workflow changes fail to improve duration or fix an issue:
  1. Re-read the workflow YAML carefully — indentation and expression syntax errors are common.
  2. Run locally with `act` to reproduce the issue without burning Actions minutes.
  3. Simplify: remove the problematic step, verify the rest works, then re-add with corrections.
  4. If still stuck → log stop_reason=stuck, document the issue for manual resolution.
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All workflows pass actionlint and security audit
  - All workflows run under 10 minutes
  - User explicitly requests stop
  - Max iterations (12) reached

DO NOT STOP just because:
  - One workflow is inherently slow (deploy workflows can be longer)
  - Self-hosted runners would help (recommend them but do not block on setup)
```

## Simplicity Criterion
```
PREFER the simpler workflow design:
  - Inline steps before composite actions (until reuse across 3+ workflows is needed)
  - Single workflow file before workflow_call chains (unless workflows share no logic)
  - GitHub-hosted runners before self-hosted (until cost or performance demands it)
  - Built-in secrets before external secret managers
  - Fewer explicit permissions over broad write-all (but always declare them)
```

## Multi-Agent Dispatch
For repositories with multiple workflows:
```
DISPATCH parallel agents (one per workflow concern):

Agent 1 (worktree: ghactions-security):
  - Pin all actions to SHA, restrict permissions, fix secret handling
  - Scope: all .github/workflows/*.yml
  - Output: Hardened workflows

Agent 2 (worktree: ghactions-perf):
  - Add caching, concurrency groups, parallel jobs
  - Scope: all .github/workflows/*.yml
  - Output: Optimized workflows

Agent 3 (worktree: ghactions-reusable):
  - Extract shared logic into composite actions and reusable workflows
  - Scope: .github/actions/, .github/workflows/
  - Output: DRY workflow architecture

MERGE ORDER: security → perf → reusable
CONFLICT RESOLUTION: security branch takes priority on permission/action version conflicts
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run GitHub Actions tasks sequentially: security hardening, then performance optimization, then reusable workflow extraction.
- Use branch isolation per task: `git checkout -b godmode-ghactions-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
