# /godmode:ghactions

GitHub Actions expert — create, optimize, secure, and debug workflows. Handles triggers, jobs, matrix builds, reusable workflows, composite actions, caching, environments, secrets, OIDC, and security hardening.

## Usage

```
/godmode:ghactions                          # Analyze existing workflows, suggest improvements
/godmode:ghactions --create                 # Generate new workflow from scratch
/godmode:ghactions --deploy                 # Add deployment workflow with environments
/godmode:ghactions --matrix                 # Set up matrix builds for multi-version testing
/godmode:ghactions --reusable               # Extract reusable workflows from existing config
/godmode:ghactions --composite              # Create composite action for shared steps
/godmode:ghactions --custom-action          # Scaffold a custom JavaScript or Docker action
/godmode:ghactions --harden                 # Security audit and hardening of workflows
/godmode:ghactions --optimize               # Focus on speed and cost optimization
/godmode:ghactions --cron                   # Add scheduled workflow (nightly, cleanup)
/godmode:ghactions --fix                    # Diagnose and fix failing workflow
/godmode:ghactions --dry-run                # Show changes without writing files
```

## What It Does

1. Discovers repository context (language, tests, existing workflows, secrets)
2. Configures event triggers (push, PR, schedule, dispatch, workflow_call)
3. Structures jobs with dependencies, matrix strategy, and services
4. Creates reusable workflows and composite actions for DRY configuration
5. Implements caching (dependencies, Docker layers, build outputs)
6. Sets up deployment environments with approval gates and OIDC auth
7. Manages artifacts (upload, download, merge from matrix jobs)
8. Applies security hardening (pinned SHAs, minimal permissions, injection prevention)
9. Optimizes workflows (concurrency, path filters, sharding, timeouts)
10. Scaffolds custom JavaScript and Docker actions

## Output
- Workflow files in `.github/workflows/`
- Composite actions in `.github/actions/<name>/action.yml`
- Reusable workflows in `.github/workflows/reusable-*.yml`
- Custom actions with `action.yml` + implementation
- Security audit with before/after scoring
- Commit: `"ci: <description> — GitHub Actions (<N> jobs, <estimated time>)"`

## Next Step
After workflows are set up: `/godmode:deploy` to configure deployment targets, or `/godmode:secure` to harden further.

## Examples

```
/godmode:ghactions --create                     # New CI workflow for the project
/godmode:ghactions --deploy                     # Add staging + production with approvals
/godmode:ghactions --matrix                     # Test across Node 18/20/22 + OS
/godmode:ghactions --harden                     # Pin actions, fix permissions, prevent injection
/godmode:ghactions --optimize                   # Speed up slow workflows
/godmode:ghactions --custom-action              # Build a custom JS or Docker action
/godmode:ghactions --reusable                   # Extract shared logic into reusable workflow
```
