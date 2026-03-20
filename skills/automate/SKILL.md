---
name: automate
description: |
  Task automation skill. Activates when a developer needs to automate repetitive workflows, create scheduled jobs, set up webhooks, design GitHub Actions workflows, write automation scripts, or build Makefiles/Taskfiles. Detects the project's existing automation tooling and generates idiomatic automation configurations with proper error handling, logging, retry logic, and monitoring. Triggers on: /godmode:automate, "automate this", "create a cron job", "set up webhook", "write a Makefile", "create GitHub Action", "automate deployment", or when repetitive manual processes are identified.
---

# Automate -- Task Automation & Workflow Orchestration

## When to Activate
- User invokes `/godmode:automate`
- User says "automate this", "create a cron job", "set up a webhook"
- User says "write a Makefile", "create a Taskfile", "automate deployment"
- User says "create GitHub Action", "schedule this task", "run this nightly"
- User identifies a repetitive manual process that should be scripted
- Godmode orchestrator detects repeated manual commands in history
- Project lacks automation for common tasks (lint, test, build, deploy)

## Workflow

### Step 1: Discover Automation Context
Identify the project's existing automation landscape and the task to automate:

```
AUTOMATION CONTEXT:
+---------------------------------------------------------+
|  Project type:      <language/framework>                 |
|  Package manager:   <npm | pip | go mod | maven | etc.>  |
|  Existing automation:                                    |
|    CI/CD:           <GitHub Actions | GitLab CI | none>  |
|    Task runner:     <Make | Task | Just | npm scripts |  |
|                      Gradle | Rake | none>               |
|    Cron/scheduler:  <crontab | systemd timer | k8s      |
|                      CronJob | CloudWatch | none>        |
|    Webhooks:        <present | none>                     |
|    Scripts:         <bash scripts | Python scripts |     |
|                      none detected>                      |
|  Task to automate:  <description of the repetitive task> |
|  Trigger type:      <schedule | event | manual | hook>   |
|  Frequency:         <one-time | on-demand | recurring>   |
+---------------------------------------------------------+
```

Detection rules:
```
IF Makefile exists:
  Task runner = Make

IF Taskfile.yml OR Taskfile.yaml exists:
  Task runner = Task (go-task)

IF justfile exists:
  Task runner = Just

IF package.json with "scripts":
  Task runner = npm scripts

IF .github/workflows/*.yml exists:
  CI/CD = GitHub Actions

IF .gitlab-ci.yml exists:
  CI/CD = GitLab CI

IF Rakefile exists:
  Task runner = Rake

IF build.gradle OR build.gradle.kts exists:
  Task runner = Gradle
```

If no automation exists: "No automation tooling detected. I recommend starting with [Make/Task/npm scripts] based on your project. Shall I set it up?"

### Step 2: Classify Automation Type
Determine the right automation approach for the task:

```
AUTOMATION CLASSIFICATION:
+---------------------------------------------------------+
|  Type            | Best For              | Tool           |
|  --------------------------------------------------------|
|  Cron/Schedule   | Nightly builds, DB    | crontab,       |
|                  | cleanup, reports,     | systemd timer, |
|                  | health checks         | k8s CronJob,   |
|                  |                       | GitHub Actions  |
|                  |                       | schedule        |
|  --------------------------------------------------------|
|  Event/Webhook   | Deploy on push, PR    | GitHub Actions  |
|                  | checks, Slack notify, | on:, webhooks,  |
|                  | issue triage          | Zapier, n8n     |
|  --------------------------------------------------------|
|  Task Runner     | Build, test, lint,    | Make, Task,     |
|                  | format, dev setup,    | Just, npm       |
|                  | one-command workflows | scripts         |
|  --------------------------------------------------------|
|  Script          | Data processing,      | Bash, Python,   |
|                  | migration, bulk ops,  | Node.js scripts |
|                  | environment setup     |                 |
|  --------------------------------------------------------|
|  CI/CD Workflow  | Test on PR, deploy    | GitHub Actions, |
|                  | on merge, release     | GitLab CI       |
|                  | automation            |                 |
+---------------------------------------------------------+
```

### Step 3: Design Cron Jobs

For scheduled automation, design with proper scheduling, error handling, and monitoring:

#### Crontab Format Reference
```
CRON EXPRESSION:
+------- minute (0-59)
| +------- hour (0-23)
| | +------- day of month (1-31)
| | | +------- month (1-12)
| | | | +------- day of week (0-7, 0 and 7 = Sunday)
| | | | |
* * * * *  command

COMMON SCHEDULES:
  Every 5 min:     */5 * * * *
  Hourly:          0 * * * *
  Daily at 2am:    0 2 * * *
  Weekly Monday:   0 9 * * 1
  Monthly 1st:     0 0 1 * *
  Weekdays 9am:    0 9 * * 1-5
```

#### Cron Job Script Template
```bash
#!/usr/bin/env bash
set -euo pipefail

# <TASK_NAME> — Scheduled automation
# Schedule: <cron expression> (<human readable>)
# Purpose: <what this job does>

SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"
LOCK_FILE="/tmp/${SCRIPT_NAME%.sh}.lock"

# Logging
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" | tee -a "$LOG_FILE"; }
log_info() { log "INFO" "$1"; }
log_error() { log "ERROR" "$1"; }

# Prevent concurrent execution
if [ -f "$LOCK_FILE" ]; then
  PID=$(cat "$LOCK_FILE")
  if kill -0 "$PID" 2>/dev/null; then
    log_error "Already running (PID $PID). Exiting."
    exit 1
  fi
  log_info "Stale lock file found. Removing."
  rm -f "$LOCK_FILE"
fi
echo $$ > "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT

# Health check / notification on failure
notify_failure() {
  log_error "Job failed: $1"
  # curl -X POST "$SLACK_WEBHOOK_URL" -d "{\"text\":\"CRON FAILED: ${SCRIPT_NAME} — $1\"}"
}
trap 'notify_failure "Unexpected error on line $LINENO"' ERR

# ---- Main logic ----
log_info "Starting ${SCRIPT_NAME}"

# <TASK_LOGIC_HERE>

log_info "Completed ${SCRIPT_NAME}"
```

#### GitHub Actions Schedule
```yaml
name: Scheduled Task

on:
  schedule:
    - cron: '0 2 * * *'  # Daily at 2am UTC
  workflow_dispatch: {}   # Allow manual trigger

permissions:
  contents: read

jobs:
  scheduled-task:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    steps:
      - uses: actions/checkout@v4

      - name: Run scheduled task
        run: ./scripts/scheduled-task.sh
        env:
          TASK_ENV: production

      - name: Notify on failure
        if: failure()
        run: |
          echo "Scheduled task failed — check logs"
          # curl webhook for Slack/PagerDuty notification
```

#### Kubernetes CronJob
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: <task-name>
spec:
  schedule: "0 2 * * *"
  concurrencyPolicy: Forbid
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  startingDeadlineSeconds: 600
  jobTemplate:
    spec:
      backoffLimit: 2
      activeDeadlineSeconds: 1800
      template:
        spec:
          restartPolicy: OnFailure
          containers:
            - name: <task-name>
              image: <image>:<tag>
              command: ["./scripts/scheduled-task.sh"]
              resources:
                requests:
                  cpu: 100m
                  memory: 128Mi
                limits:
                  cpu: 500m
                  memory: 512Mi
```

### Step 4: Design Webhook Automation

For event-driven automation:

#### Webhook Handler Template (Node.js/Express)
```typescript
import express from 'express';
import crypto from 'crypto';

const app = express();
app.use(express.json());

// Verify webhook signature (GitHub example)
function verifySignature(req: express.Request): boolean {
  const signature = req.headers['x-hub-signature-256'] as string;
  if (!signature) return false;

  const hmac = crypto.createHmac('sha256', process.env.WEBHOOK_SECRET!);
  const digest = 'sha256=' + hmac.update(JSON.stringify(req.body)).digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(digest));
}

// Webhook endpoint
app.post('/webhooks/github', (req, res) => {
  if (!verifySignature(req)) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  const event = req.headers['x-github-event'] as string;
  const payload = req.body;

  // Route by event type
  switch (event) {
    case 'push':
      handlePush(payload);
      break;
    case 'pull_request':
      handlePullRequest(payload);
      break;
    case 'issues':
      handleIssue(payload);
      break;
    default:
      console.log(`Unhandled event: ${event}`);
  }

  res.status(200).json({ received: true });
});
```

#### GitHub Actions Event Triggers
```yaml
on:
  push:
    branches: [main]
    paths:
      - 'src/**'
      - '!src/**/*.test.ts'
  pull_request:
    types: [opened, synchronize, reopened]
  issues:
    types: [opened, labeled]
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production
```

### Step 5: Design GitHub Actions Workflows

For CI/CD and automation workflows:

#### Release Automation
```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write
  packages: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate changelog
        id: changelog
        run: |
          PREVIOUS_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
          if [ -n "$PREVIOUS_TAG" ]; then
            CHANGELOG=$(git log ${PREVIOUS_TAG}..HEAD --pretty=format:"- %s (%h)" --no-merges)
          else
            CHANGELOG=$(git log --pretty=format:"- %s (%h)" --no-merges)
          fi
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          echo "$CHANGELOG" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create GitHub release
        uses: softprops/action-gh-release@v2
        with:
          body: ${{ steps.changelog.outputs.changelog }}
          generate_release_notes: true
```

#### PR Automation
```yaml
name: PR Automation

on:
  pull_request:
    types: [opened, edited, synchronize]

permissions:
  contents: read
  pull-requests: write

jobs:
  auto-label:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/labeler@v5
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}

  size-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check PR size
        run: |
          ADDITIONS=$(gh pr view ${{ github.event.pull_request.number }} --json additions -q '.additions')
          if [ "$ADDITIONS" -gt 500 ]; then
            gh pr comment ${{ github.event.pull_request.number }} --body "Warning: This PR has $ADDITIONS additions. Consider breaking it into smaller PRs."
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

#### Dependency Update Automation
```yaml
name: Dependency Update Check

on:
  schedule:
    - cron: '0 9 * * 1'  # Weekly Monday 9am UTC
  workflow_dispatch: {}

permissions:
  contents: write
  pull-requests: write

jobs:
  update-deps:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Check for updates
        run: npx npm-check-updates --format group

      - name: Update minor/patch
        run: |
          npx npm-check-updates -u --target minor
          npm install

      - name: Run tests
        run: npm test

      - name: Create PR if changes
        run: |
          if git diff --quiet; then
            echo "No updates available"
            exit 0
          fi
          BRANCH="deps/update-$(date +%Y%m%d)"
          git checkout -b "$BRANCH"
          git add .
          git commit -m "deps: update minor/patch dependencies ($(date +%Y-%m-%d))"
          git push origin "$BRANCH"
          gh pr create --title "deps: weekly dependency update" \
            --body "Automated minor/patch dependency updates. All tests pass." \
            --label "dependencies"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Step 6: Design Makefile/Taskfile

For local task running and developer workflows:

#### Makefile Template
```makefile
.PHONY: help setup dev test lint format build clean deploy

# Default target
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ---- Setup ----
setup: ## Install dependencies and configure dev environment
	npm ci
	cp -n .env.example .env 2>/dev/null || true
	npm run db:migrate
	@echo "Setup complete. Run 'make dev' to start."

# ---- Development ----
dev: ## Start development server with hot reload
	npm run dev

# ---- Quality ----
lint: ## Run linter
	npm run lint

format: ## Format code
	npm run format

typecheck: ## Run type checker
	npm run type-check

# ---- Testing ----
test: ## Run all tests
	npm test

test-unit: ## Run unit tests only
	npm test -- --testPathPattern='unit'

test-integration: ## Run integration tests only
	npm test -- --testPathPattern='integration'

test-watch: ## Run tests in watch mode
	npm test -- --watch

coverage: ## Run tests with coverage report
	npm test -- --coverage

# ---- Build ----
build: ## Build for production
	npm run build

docker-build: ## Build Docker image
	docker build -t $(IMAGE_NAME):$(VERSION) .

# ---- Database ----
db-migrate: ## Run database migrations
	npm run db:migrate

db-rollback: ## Rollback last migration
	npm run db:rollback

db-seed: ## Seed database with sample data
	npm run db:seed

db-reset: ## Reset database (migrate + seed)
	npm run db:reset

# ---- Deploy ----
deploy-staging: build ## Deploy to staging
	./scripts/deploy.sh staging

deploy-production: build ## Deploy to production (requires confirmation)
	@echo "Deploying to PRODUCTION. Press Ctrl+C to cancel."
	@read -p "Type 'deploy' to confirm: " confirm && [ "$$confirm" = "deploy" ] || exit 1
	./scripts/deploy.sh production

# ---- Cleanup ----
clean: ## Remove build artifacts and caches
	rm -rf dist/ node_modules/.cache coverage/ .next/
	@echo "Cleaned build artifacts."

nuke: ## Remove everything (node_modules, dist, caches)
	rm -rf node_modules/ dist/ coverage/ .next/ .turbo/
	@echo "Nuked. Run 'make setup' to rebuild."

# ---- CI helpers ----
ci-lint: ## CI: lint + typecheck + format check
	npm run format:check
	npm run lint
	npm run type-check

ci-test: ## CI: run tests with coverage
	npm test -- --coverage --ci --reporters=default --reporters=jest-junit

ci-build: ## CI: production build
	NODE_ENV=production npm run build
```

#### Taskfile Template (go-task)
```yaml
version: '3'

vars:
  IMAGE_NAME: '{{.PROJECT_NAME | default "app"}}'
  VERSION:
    sh: git describe --tags --always --dirty 2>/dev/null || echo "dev"

tasks:
  default:
    desc: Show available tasks
    cmds:
      - task --list

  setup:
    desc: Install dependencies and configure dev environment
    cmds:
      - npm ci
      - cp -n .env.example .env 2>/dev/null || true
      - npm run db:migrate
    status:
      - test -d node_modules

  dev:
    desc: Start development server
    cmds:
      - npm run dev

  lint:
    desc: Run linter
    cmds:
      - npm run lint

  format:
    desc: Format code
    cmds:
      - npm run format

  test:
    desc: Run all tests
    cmds:
      - npm test

  test:watch:
    desc: Run tests in watch mode
    cmds:
      - npm test -- --watch

  build:
    desc: Build for production
    cmds:
      - npm run build
    sources:
      - src/**/*
      - package.json
    generates:
      - dist/**/*

  clean:
    desc: Remove build artifacts
    cmds:
      - rm -rf dist/ coverage/ .next/ node_modules/.cache

  deploy:staging:
    desc: Deploy to staging
    deps: [build]
    cmds:
      - ./scripts/deploy.sh staging

  deploy:production:
    desc: Deploy to production
    deps: [build]
    prompt: Deploy to PRODUCTION?
    cmds:
      - ./scripts/deploy.sh production
```

### Step 7: Script Automation for Repetitive Tasks

For one-off or recurring scripts:

#### Script Template (Bash)
```bash
#!/usr/bin/env bash
set -euo pipefail

# <SCRIPT_NAME> — <description>
# Usage: ./scripts/<name>.sh [options]

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging
info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
die()   { error "$1"; exit 1; }

# Argument parsing
VERBOSE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose) VERBOSE=true; shift ;;
    -n|--dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "Usage: $(basename "$0") [options]"
      echo "  -v, --verbose  Verbose output"
      echo "  -n, --dry-run  Show what would be done"
      echo "  -h, --help     Show this help"
      exit 0
      ;;
    *) die "Unknown option: $1" ;;
  esac
done

# Prerequisites check
command -v node >/dev/null 2>&1 || die "node is required but not installed"

# ---- Main logic ----
main() {
  info "Starting task..."

  if $DRY_RUN; then
    info "[DRY RUN] Would execute task"
    return 0
  fi

  # <TASK_LOGIC_HERE>

  info "Task completed successfully"
}

main "$@"
```

#### Script Template (Python)
```python
#!/usr/bin/env python3
"""<SCRIPT_NAME> — <description>

Usage:
    python scripts/<name>.py [options]
"""

import argparse
import logging
import sys
from pathlib import Path

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parent.parent


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="<description>")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")
    parser.add_argument("-n", "--dry-run", action="store_true", help="Show what would be done")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    logger.info("Starting task...")

    if args.dry_run:
        logger.info("[DRY RUN] Would execute task")
        return 0

    # <TASK_LOGIC_HERE>

    logger.info("Task completed successfully")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

### Step 8: Commit and Report

```
AUTOMATION REPORT:
+---------------------------------------------------------+
|  Task:             <description of what was automated>   |
|  Type:             <cron | webhook | workflow | script   |
|                     | taskfile>                          |
|  Trigger:          <schedule | event | manual | hook>    |
|  Files created:    <list of files>                       |
+---------------------------------------------------------+
|  Schedule:         <cron expression, if applicable>      |
|  Error handling:   <retry | notify | log | fail-fast>    |
|  Monitoring:       <logs | alerts | dashboard>           |
|  Rollback:         <how to disable or revert>            |
+---------------------------------------------------------+
|  Next steps:                                             |
|  - <manual steps needed, if any>                         |
|  - <secrets to configure>                                |
|  - <monitoring to set up>                                |
+---------------------------------------------------------+
```

Commit: `"automate: <type> for <task> -- <trigger> (<frequency>)"`

## Key Behaviors

1. **Detect before generating.** Always check existing automation tooling. If the project uses Make, add targets to the existing Makefile. Do not create a competing Taskfile.
2. **Error handling is mandatory.** Every automated task must handle errors gracefully: log the failure, send a notification, and exit with a non-zero code. Silent failures are worse than no automation.
3. **Lock files prevent overlap.** Scheduled tasks must use lock files or concurrency guards to prevent duplicate execution. Two cleanup scripts running simultaneously cause data corruption.
4. **Idempotency is required.** Every script must be safe to run twice. If the task already completed, the second run should be a no-op, not a duplicate action.
5. **Dry-run before real run.** Every script must support `--dry-run` to show what it would do without doing it. This is non-negotiable for destructive operations.
6. **Secrets are injected, never hardcoded.** API keys, tokens, and passwords come from environment variables or secret managers. Never commit secrets in automation scripts.
7. **Logging is required.** Every automated task must log its start time, actions taken, and completion status. When a cron job fails at 3am, logs are the only evidence.
8. **Timeouts prevent runaway jobs.** Every scheduled task and CI workflow must have a timeout. A script that hangs indefinitely blocks the next scheduled run and wastes resources.

## Example Usage

### Automating a repetitive workflow
```
User: /godmode:automate I manually run lint, test, and build every time before pushing

Automate: Analyzing workflow...

AUTOMATION CONTEXT:
  Project type: TypeScript / Node.js
  Task runner: npm scripts (package.json)
  CI/CD: GitHub Actions (existing)
  Task to automate: Pre-push quality checks

RECOMMENDATION: Makefile + git pre-push hook

Created: Makefile
  Targets: lint, test, build, check (runs all three)

Created: .githooks/pre-push
  Runs: make check before every push
  Bypass: git push --no-verify (for emergencies only)

Run 'make check' to execute manually, or just 'git push' to trigger automatically.
```

### Creating a scheduled cleanup job
```
User: /godmode:automate Clear expired sessions from the database every night

Automate: Designing scheduled job...

AUTOMATION CONTEXT:
  CI/CD: GitHub Actions
  Database: PostgreSQL
  Schedule: Daily at 2am UTC

Created: .github/workflows/cleanup-sessions.yml
  Schedule: 0 2 * * * (daily at 2am UTC)
  Action: DELETE FROM sessions WHERE expires_at < NOW()
  Monitoring: Logs row count deleted, notifies Slack on failure
  Manual trigger: workflow_dispatch enabled

Created: scripts/cleanup-sessions.sh
  Lock file: prevents concurrent execution
  Dry run: --dry-run flag to preview without deleting
  Logging: /var/log/cleanup-sessions.log
```

### Setting up webhook automation
```
User: /godmode:automate Send a Slack notification when a PR is merged

Automate: Designing webhook...

Created: .github/workflows/pr-merged-notify.yml
  Trigger: pull_request (closed + merged)
  Action: Post to Slack via webhook
  Message: PR title, author, merge commit, link

Requires: Add SLACK_WEBHOOK_URL to repository secrets.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive automation workflow: detect, design, generate |
| `--cron <expression>` | Create a cron/scheduled job |
| `--webhook <event>` | Create a webhook handler for an event |
| `--workflow <name>` | Create a GitHub Actions workflow |
| `--script <name>` | Create a standalone automation script |
| `--makefile` | Generate or update a Makefile |
| `--taskfile` | Generate or update a Taskfile |
| `--hook <git-hook>` | Create a git hook (pre-commit, pre-push, etc.) |
| `--dry-run` | Show automation plan without creating files |
| `--list` | List all existing automation in the project |
| `--audit` | Audit existing automation for issues (missing error handling, no timeouts) |

## Explicit Loop Protocol

When automating multiple tasks or iterating on automation reliability:

```
AUTOMATION BUILD LOOP:
current_iteration = 0
max_iterations = 15
tasks_remaining = total_tasks_to_automate

WHILE tasks_remaining > 0 AND current_iteration < max_iterations:
    current_iteration += 1

    1. SELECT next task to automate (highest impact first)
    2. DETECT existing automation context for this task
    3. GENERATE automation artifact (script, workflow, Makefile target)
    4. TEST the automation:
       - Dry-run mode (--dry-run) passes
       - Real execution succeeds
       - Error handling works (simulate failure)
       - Idempotency verified (run twice, same result)
    5. git commit: "automate: <type> for <task> (iter {current_iteration})"
    6. IF test fails:
       - Debug and fix
       - Re-test
       - If still failing after 3 attempts, log as manual and move on
    7. UPDATE tasks_remaining

    IF current_iteration % 5 == 0:
        PRINT STATUS:
        "Iteration {current_iteration}/{max_iterations}"
        "Tasks automated: {total_tasks - tasks_remaining}/{total_tasks}"
        "Automation types: {cron_count} cron, {workflow_count} workflows, {script_count} scripts"
        "Remaining: {tasks_remaining} tasks"

IF tasks_remaining > 0:
    PRINT "Remaining tasks need manual automation design: {tasks_remaining}"
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NON-NEGOTIABLE:
1. NEVER create automation without error handling — set -euo pipefail in bash, try/catch in scripts.
2. NEVER hardcode secrets — environment variables or secret managers only.
3. EVERY scheduled job MUST have a lock file or concurrency guard — no parallel execution.
4. EVERY script MUST support --dry-run — destructive operations need preview mode.
5. EVERY automated task MUST log: start time, actions taken, completion status.
6. EVERY CI workflow MUST have a timeout — no runaway jobs.
7. EVERY GitHub Actions scheduled workflow MUST also have workflow_dispatch.
8. NEVER duplicate existing automation — add to existing Makefile/Taskfile, do not create competing files.
9. NEVER schedule cron jobs at midnight UTC — offset by random minutes to avoid thundering herd.
10. git commit automation files BEFORE testing — if test fails, you have a baseline to debug from.
11. Automatic revert: if automation causes a failure in CI, revert the automation commit.
12. Log all automation artifacts in TSV:
    TYPE\tTRIGGER\tFREQUENCY\tFILE\tERROR_HANDLING\tTIMEOUT
```

## Auto-Detection
```bash
AUTO-DETECT automation context:
  1. Task runner: ls Makefile Taskfile.yml Taskfile.yaml justfile Rakefile build.gradle 2>/dev/null
  2. CI/CD: ls .github/workflows/*.yml .gitlab-ci.yml .circleci/config.yml Jenkinsfile 2>/dev/null
  3. Scheduler: crontab -l 2>/dev/null; ls /etc/systemd/system/*.timer 2>/dev/null; kubectl get cronjobs 2>/dev/null
  4. Package manager: ls package.json pyproject.toml Gemfile go.mod Cargo.toml pom.xml 2>/dev/null
  5. Existing scripts: ls scripts/ bin/ tools/ 2>/dev/null
  6. Webhooks: grep -rl "webhook\|/api/hooks" src/ --include="*.ts" --include="*.py" 2>/dev/null | head -5

  USE detected context to:
    - Add targets to existing task runner (don't create Makefile if Taskfile exists)
    - Match existing CI/CD platform (don't create GitHub Actions if project uses GitLab CI)
    - Reuse existing script patterns (language, error handling style, logging format)
    - Identify automation gaps (no CI? no scheduled cleanup? no deploy automation?)
```

## Success Criteria
All of these must be true before marking the task complete:
1. Automation script runs successfully with `--dry-run` (no destructive side effects on first run).
2. Error handling is present: `set -euo pipefail` (bash) or try/catch (Python/Node) with meaningful error messages.
3. Logging captures: start time, actions taken, completion status, duration.
4. Concurrency guard exists for scheduled jobs (lock file, flock, or advisory lock).
5. CI workflow (if created) passes on a clean checkout with no manual setup required.
6. Secrets are in environment variables, not hardcoded in scripts or workflow files.
7. Timeout is configured for every scheduled/CI job (no runaway processes).
8. `workflow_dispatch` is present on every GitHub Actions scheduled workflow (manual trigger for debugging).

## Error Recovery
| Failure | Action |
|---------|--------|
| Task runner not detected | Check for ALL known runners before creating new. If truly none exist, ask user preference: Make (universal), Task (modern), or npm scripts (Node projects). |
| Cron syntax invalid | Validate with `crontab -l` or use a cron expression validator. Common mistake: `*/5` means every 5 minutes, not every 5th minute of the hour. Use crontab.guru for verification. |
| GitHub Actions workflow fails | Check: runner OS matches expected (`ubuntu-latest`), all secrets exist in repo settings, actions versions are pinned (`@v4` not `@latest`), timeout is set. |
| Script fails in CI but works locally | Check: working directory, PATH differences, missing dependencies not in lock file, env vars not set in CI. Add `env` dump in debug mode. |
| Lock file prevents execution | Check if previous run is actually still running (`ps aux | grep`). If stale lock: remove lock file and add PID-based locking to prevent stale locks. |
| Webhook delivery fails | Check: endpoint URL is reachable from sender, signature verification matches, request timeout is sufficient, response returns 2xx within 5 seconds. |

## Multi-Agent Dispatch
```
Agent 1 (worktree: automate-scripts):
  - Create automation scripts with error handling and dry-run
  - Add logging, lock files, and timeout mechanisms
  - Write unit tests for script logic

Agent 2 (worktree: automate-ci):
  - Create/update CI workflows (GitHub Actions, GitLab CI)
  - Configure scheduled triggers with workflow_dispatch
  - Set up webhook endpoints if needed

Agent 3 (worktree: automate-infra):
  - Configure cron jobs / systemd timers / K8s CronJobs
  - Set up monitoring and alerting for automation failures
  - Create Makefile/Taskfile targets for local execution

MERGE ORDER: scripts -> ci -> infra
CONFLICT ZONES: task runner targets, CI workflow definitions, environment variable declarations
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run automation tasks sequentially: scripts first, then CI workflows, then scheduler configuration.
- Use branch isolation per task: `git checkout -b godmode-automate-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.

## Anti-Patterns

- **Do NOT automate without error handling.** A script without `set -euo pipefail` or try/catch will fail silently. Silent failures are worse than manual processes because nobody notices.
- **Do NOT hardcode secrets in scripts.** Cron jobs and webhooks that contain API keys in plaintext are security incidents waiting to happen. Use environment variables or secret managers.
- **Do NOT skip lock files for scheduled jobs.** Two instances of the same cleanup script running simultaneously will corrupt data, double-send notifications, or race-condition your database.
- **Do NOT create automation without logging.** When a nightly job fails, the first question is "what happened?" Without logs, the answer is "nobody knows."
- **Do NOT set cron jobs without timeouts.** A data export script that hangs will block the next run, then the next, compounding failures until someone notices.
- **Do NOT duplicate existing automation.** If the project has a Makefile, add targets to it. Creating a separate Taskfile alongside an existing Makefile creates confusion about which is canonical.
- **Do NOT schedule jobs at midnight UTC.** Every scheduler defaults to midnight, creating thundering herd problems. Offset jobs by random minutes (e.g., 0 2 * * * instead of 0 0 * * *).
- **Do NOT automate destructive operations without dry-run.** A cleanup script that deletes data must support `--dry-run`. One mistyped query in production, and the data is gone.
- **Do NOT forget workflow_dispatch.** Every GitHub Actions scheduled workflow should also have `workflow_dispatch` for manual triggering. Waiting 24 hours to test a cron fix is unacceptable.
