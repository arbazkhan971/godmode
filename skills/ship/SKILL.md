---
name: ship
description: Ship workflow. Checklist → dry-run → ship → verify. PR, deploy, or release.
---

## Activate When
- `/godmode:ship`, "ship it", "deploy", "release", "merge"

## Workflow
### 1. Inventory Changes
Run `git log main..HEAD --oneline` and `git diff main..HEAD --stat`.
### 2. Pre-Ship Checklist
Run each, record pass/fail: `test_cmd`, `lint_cmd`, `build_cmd`, `grep -rn 'API_KEY\|SECRET\|PASSWORD' $(git diff main..HEAD --name-only)`, `grep -n 'TODO\|FIXME' $(git diff main..HEAD --name-only)`.
Score = passing/total x 100. Must be 100% to proceed.
### 3. Dry-Run
Preview: show exact commands that will run, files/branches/tags that will be created. User must confirm.
### 4. Ship
- **PR:** `gh pr create --title "{title}" --body "## Summary\n{changes}\n## Test Plan\n{how_verified}"`
- **Deploy:** trigger CI/CD or apply manifests
- **Release:** `git tag v{version} && gh release create`
### 5. Verify
Post-ship: `curl -sf {endpoint}` or run smoke test. Non-zero exit = rollback (`git revert HEAD && push`).
### 6. Log
Append to `.godmode/ship-log.tsv`: timestamp, type, commit, outcome, url.

## Rules
1. 100% checklist before shipping. No exceptions.
2. Dry-run before real ship. State rollback command before executing.
3. Verify after shipping. One ship per invocation. Failed verify = immediate rollback.
