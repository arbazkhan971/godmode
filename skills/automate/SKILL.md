---
name: automate
description: |
  Task automation skill. Activates when a developer needs to automate repetitive workflows, create scheduled jobs, set up webhooks, design GitHub Actions workflows, write automation scripts, or build Makefiles/Taskfiles. Triggers on: /godmode:automate, "automate this", "create a cron job", "set up webhook", "write a Makefile", "create GitHub Action", or when repetitive manual processes are identified.
---

# Automate -- Task Automation & Workflow Orchestration

## When to Activate
- User invokes `/godmode:automate`
- User says "automate this", "create a cron job", "set up a webhook"
- User says "write a Makefile", "create GitHub Action", "schedule this task"
- Project lacks automation for common tasks (lint, test, build, deploy)

## Workflow

### Step 1: Discover Context
Detect existing: task runner (Make, Task, Justfile, npm scripts), CI/CD (GitHub Actions, GitLab CI), scheduler (crontab, k8s CronJob), scripts.

### Step 2: Classify Type

| Type | Best For | Tool |
|--|--|--|
| Cron/Schedule | Nightly builds, cleanup, reports | crontab, k8s CronJob, GH Actions schedule |
| Event/Webhook | Deploy on push, notifications | GitHub Actions on:, webhooks |
| Task Runner | Build, test, lint, dev setup | Make, Task, Justfile, npm scripts |
| Script | Data processing, migration | Bash, Python, Node.js |
| CI/CD | Test on PR, deploy on merge | GitHub Actions, GitLab CI |

### Step 3: Cron Jobs
Format: `minute hour day-of-month month day-of-week`. Every cron script: `set -euo pipefail`, lock file, logging, failure notification, cleanup trap. GitHub Actions: schedule + workflow_dispatch. K8s: CronJob with concurrencyPolicy: Forbid.

### Step 4: Webhooks
Verify signature (HMAC-SHA256). Route by event type. Return 200 within 5 seconds.

### Step 5: GitHub Actions
Pin action versions (@v4). Set permissions. Set timeout. Release automation, PR automation, scheduled tasks.

### Step 6: Makefile/Taskfile
Targets: help, setup, dev, lint, format, typecheck, test, build, deploy-staging, deploy-production (with confirmation), clean, ci-lint, ci-test, ci-build.

### Step 7: Script Template
Every script: `set -euo pipefail`, logging, `--help`, `--dry-run`, `--verbose`, prerequisites check, main function.

### Step 8: Report
```
AUTOMATION REPORT:
Task: <description> | Type: <cron | webhook | workflow | script>
Trigger: <schedule | event | manual> | Error handling: <present>
```

## Key Behaviors

1. **Detect before generating.** Add to existing Makefile, don't create competing files.
2. **Error handling is mandatory.** Log, notify, exit non-zero.
3. **Lock files prevent overlap.** No concurrent duplicate execution.
4. **Idempotency required.** Safe to run twice.
5. **Dry-run for destructive ops.** `--dry-run` is non-negotiable.
6. **Secrets injected, never hardcoded.**
7. **Logging required.** Start, actions, completion.
8. **Timeouts prevent runaway jobs.**

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive workflow |
| `--cron <expr>` | Scheduled job |
| `--webhook <event>` | Webhook handler |
| `--workflow <name>` | GitHub Actions workflow |
| `--script <name>` | Standalone script |
| `--makefile` | Generate/update Makefile |
| `--hook <git-hook>` | Git hook |
| `--audit` | Audit existing automation |

## HARD RULES

1. NEVER automate without error handling.
2. NEVER hardcode secrets.
3. EVERY scheduled job MUST have a lock file.
4. EVERY script MUST support --dry-run.
5. EVERY task MUST log start/actions/completion.
6. EVERY CI workflow MUST have a timeout.
7. EVERY scheduled GH Actions MUST have workflow_dispatch.
8. NEVER duplicate existing automation.
9. NEVER schedule at midnight UTC.

## Output Format

```
AUTOMATION RESULT:
Type: <cron | webhook | workflow | script> | Trigger: <schedule | event | manual>
Error handling: present | Dry-run: supported | Timeout: set
```

## Auto-Detection
```
1. ls Makefile Taskfile.yml justfile Rakefile build.gradle
2. ls .github/workflows/*.yml .gitlab-ci.yml
3. ls package.json pyproject.toml go.mod
4. ls scripts/ bin/ tools/
```

## Platform Fallback
Run sequentially: scripts, then CI workflows, then scheduler configuration.

## TSV Logging
Append to `.godmode/automate-results.tsv`:
```
timestamp	task	type	trigger	frequency	file	error_handling	timeout	status
```
One row per automation artifact. Never overwrite previous rows.

## Error Recovery
| Failure | Action |
|--|--|
| Task runner not detected | Check for ALL known runners before creating new. If none exist, ask user preference: Make, Task, or npm scripts. |
| Cron syntax invalid | Validate with crontab.guru. Common mistake: `*/5` means every 5 minutes, not the 5th minute. |
| GitHub Actions workflow fails | Check runner OS, secrets exist in repo settings, actions versions pinned (`@v4` not `@latest`), timeout set. |
| Script fails in CI but works locally | Check PATH, working directory, missing deps in lockfile, env vars not set in CI. Add `env` dump in debug mode. |

## Success Criteria
1. Automation script runs with `--dry-run` without side effects.
2. Error handling present: `set -euo pipefail` (bash) or try/catch with meaningful messages.
3. Logging captures start time, actions taken, completion status.
4. Concurrency guard exists for scheduled jobs (lock file or flock).

## Keep/Discard Discipline
```
After EACH automation artifact:
  KEEP if: dry-run passes AND error handling present AND logging captures start/actions/completion
  DISCARD if: no error handling OR secrets hardcoded OR no dry-run support for destructive ops
  On discard: revert. Fix error handling before retrying.
```

## Stop Conditions
```
STOP when ALL of:
  - Script runs with --dry-run without side effects
  - Error handling present with meaningful messages
  - Logging captures start, actions, and completion
  - Concurrency guard exists for scheduled jobs
```
