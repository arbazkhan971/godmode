---
name: ship
description: Ship workflow. Checklist → dry-run → ship → verify. PR, deploy, or release.
---

## Activate When
- `/godmode:ship`, "ship it", "deploy", "release", "merge"

## Workflow
### 1. Inventory Changes
Run `git log main..HEAD --oneline` and `git diff main..HEAD --stat`. If no commits → nothing to ship, stop.
### 2. Pre-Ship Checklist
Run each, PASS/FAIL: `build_cmd`, `lint_cmd`, `test_cmd`, `grep -rn 'API_KEY\|SECRET\|PASSWORD\|PRIVATE' $(git diff main..HEAD --name-only)`, `grep -n 'TODO\|FIXME\|HACK' $(git diff main..HEAD --name-only)`.
Print: `Checklist: {passing}/{total}`. Any FAIL = stop. Fix failures with `/godmode:fix`, then re-run checklist.
### 3. Dry-Run
Preview: print exact commands, target branch/tag, and rollback command. User must type 'yes' to proceed.
### 4. Ship
- **PR:** `gh pr create --title "{title}" --body "## Summary\n{changes}\n## Test Plan\n{how_verified}"`
- **Deploy:** trigger CI/CD or apply manifests
- **Release:** `git tag v{version} && gh release create v{version} --generate-notes`
### 5. Verify
Post-ship: `curl -sf {endpoint}/health` or `test_cmd`. Non-zero = rollback: `git revert HEAD && git push`.
### 6. Log
Append `.godmode/ship-log.tsv`: ISO-8601 timestamp, type, commit_sha, outcome(shipped/rolled-back/failed), url.

## Rules
1. 100% checklist before shipping. No exceptions. Never ship with failing checks — fix first, then re-run.
2. Dry-run first. Print rollback command (`git revert HEAD && git push`) before executing ship action.
3. Verify after shipping. One ship per invocation. Failed verify = immediate rollback.
