---
name: ship
description: |
  Shipping workflow. Checklist → dry-run → ship → verify → monitor. Supports PR, deploy, release.
---

# Ship — Shipping Workflow

## Activate When
- `/godmode:ship`, "ship it", "deploy", "release", "merge"
- After optimize/secure phases complete

## Workflow

### 1. Inventory Changes
```bash
git log main..HEAD --oneline  # what's being shipped
git diff main..HEAD --stat    # files changed
```

### 2. Pre-Ship Checklist
```
[ ] All tests pass
[ ] No lint errors
[ ] No type errors
[ ] Security audit passed (no critical/high)
[ ] Coverage above threshold
[ ] Changelog updated
[ ] No TODO/FIXME/HACK in diff
```

Run each check mechanically. Score = passing/total × 100. Must be 100% to proceed.

### 3. Dry-Run
Simulate the ship action without executing:
- PR: `gh pr create --dry-run` (or just preview title + body)
- Deploy: show what would deploy, don't trigger
- Release: show tag + notes, don't create

### 4. Ship
```
PR:      gh pr create --title "{title}" --body "{body}"
Deploy:  trigger CI/CD or kubectl apply
Release: git tag v{version} && gh release create
```

### 5. Verify
```bash
# Post-ship health check
curl -s health_endpoint  # or run smoke tests
# If unhealthy → rollback immediately
```

### 6. Log
Append to `.godmode/ship-log.tsv`: timestamp, type, commit, outcome, url

## Rules

1. **100% checklist before shipping.** No exceptions.
2. **Dry-run before real ship.** Always preview first.
3. **Rollback plan defined before shipping.** Know how to undo.
4. **Verify after shipping.** Don't assume it worked.
5. **One ship per invocation.** Don't batch multiple releases.
6. **Log every ship.** Traceability is non-negotiable.
