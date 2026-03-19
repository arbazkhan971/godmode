# /godmode:automate

Automate repetitive workflows. Designs cron jobs, webhook handlers, GitHub Actions workflows, automation scripts, and Makefiles/Taskfiles. Detects existing automation tooling and generates idiomatic configurations with error handling, logging, retry logic, and monitoring.

## Usage

```
/godmode:automate                            # Interactive automation workflow
/godmode:automate --cron "0 2 * * *"        # Create a scheduled cron job
/godmode:automate --webhook <event>          # Create a webhook handler
/godmode:automate --workflow <name>          # Create a GitHub Actions workflow
/godmode:automate --script <name>            # Create an automation script
/godmode:automate --makefile                 # Generate or update Makefile
/godmode:automate --taskfile                 # Generate or update Taskfile
/godmode:automate --hook <git-hook>          # Create a git hook
/godmode:automate --list                     # List all existing automation
/godmode:automate --audit                    # Audit existing automation for issues
/godmode:automate --dry-run                  # Show plan without creating files
```

## What It Does

1. Detects project language, framework, and existing automation tooling
2. Classifies the automation type (schedule, event, task runner, script, CI/CD)
3. Generates automation with error handling, logging, lock files, and timeouts
4. Supports dry-run mode for all destructive automation
5. Injects secrets via environment variables, never hardcoded
6. Reports what was created and what requires manual configuration

## Output
- Automation files (workflows, scripts, Makefiles, Taskfiles, hooks)
- Commit: `"automate: <type> for <task> -- <trigger> (<frequency>)"`
- Summary of files created with TODOs for manual setup (secrets, monitoring)

## Automation Types

| Type | Tool | Trigger |
|------|------|---------|
| **Cron/Schedule** | crontab, systemd timer, k8s CronJob, GitHub Actions schedule | Time-based |
| **Event/Webhook** | GitHub Actions on:, webhook handlers | Push, PR, issue, release |
| **Task Runner** | Make, Task, Just, npm scripts | Manual command |
| **Script** | Bash, Python, Node.js | Manual or scheduled |
| **CI/CD Workflow** | GitHub Actions, GitLab CI | Push, PR, tag, schedule |

## Next Step
After automation is created: test with `--dry-run`, configure secrets, then `/godmode:ship` to deploy.

## Examples

```
/godmode:automate I manually run lint, test, build before every push
/godmode:automate --cron "0 2 * * *" Clean expired sessions nightly
/godmode:automate --webhook pr-merged Send Slack notification on PR merge
/godmode:automate --workflow release Automate releases on version tags
/godmode:automate --makefile Add dev setup and quality check targets
/godmode:automate --hook pre-push Run tests before every push
/godmode:automate --audit Check all automation for missing error handling
```
