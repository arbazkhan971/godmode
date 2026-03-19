# /godmode:ship

Structured 8-phase shipping workflow. Inventories changes, runs pre-ship checklist, prepares artifacts, performs dry-run, executes the ship (PR/deploy/release), verifies, logs, and monitors post-ship.

## Usage

```
/godmode:ship                           # Full 8-phase shipping workflow
/godmode:ship --pr                      # Create a pull request
/godmode:ship --deploy staging          # Deploy to staging
/godmode:ship --deploy production       # Deploy to production
/godmode:ship --release 1.2.0           # Create a tagged release
/godmode:ship --skip-checklist          # Skip pre-ship checklist (not recommended)
/godmode:ship --rollback                # Roll back last deployment
/godmode:ship --status                  # Show status of last shipment
```

## What It Does

1. **Inventory** — Catalog all changes (commits, files, features, deps)
2. **Checklist** — Run pre-ship checks (tests, lint, security, docs)
3. **Prepare** — Rebase, build, generate changelog
4. **Dry Run** — Simulate deployment/PR without executing
5. **Ship** — Create PR, deploy, or tag a release
6. **Verify** — Check CI status, smoke tests, health endpoint
7. **Log** — Record shipment in `.godmode/ship-log.tsv`
8. **Monitor** — 15-minute post-deploy monitoring (if applicable)

## Output
- PR, deployment, or release (depending on mode)
- Ship log entry
- Post-ship monitoring report

## Next Step
After ship: `/godmode:finish` to clean up the branch, or `/godmode` for next feature.

## Examples

```
/godmode:ship --pr                      # Create a pull request
/godmode:ship --deploy staging          # Deploy to staging first
/godmode:ship --release 2.0.0           # Tag and release
/godmode:ship --rollback                # Undo last deploy
```
