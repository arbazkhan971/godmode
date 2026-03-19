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
Run `git log main..HEAD --oneline` and `git diff main..HEAD --stat`.
### 2. Pre-Ship Checklist
Mechanically verify: tests pass, no lint errors, no type errors, security audit passed (no critical/high), coverage above threshold, changelog updated, no TODO/FIXME/HACK in diff.
Score = passing/total x 100. Must be 100% to proceed.
### 3. Dry-Run
Preview the ship action without executing. Show what would be created/deployed/tagged.
### 4. Ship
- **PR:** `gh pr create --title "{title}" --body "{body}"`
- **Deploy:** trigger CI/CD or apply manifests
- **Release:** `git tag v{version} && gh release create`
### 5. Verify
Post-ship health check (endpoint curl or smoke tests). If unhealthy, rollback immediately.
### 6. Log
Append to `.godmode/ship-log.tsv`: timestamp, type, commit, outcome, url.

## Rules
1. **100% checklist before shipping.** No exceptions.
2. **Dry-run before real ship.** Always preview first.
3. **Rollback plan defined before shipping.** Know how to undo.
4. **Verify after shipping.** Don't assume it worked.
5. **One ship per invocation.** Don't batch multiple releases.
6. **Log every ship.**
