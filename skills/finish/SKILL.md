---
name: finish
description: Branch finalization. Merge, PR, keep, or discard.
---

## Activate When
- `/godmode:finish`, "done with branch", "merge", "clean up"

## Workflow
### 1. Pre-Check
Verify: clean working tree, no uncommitted changes, tests pass, lint passes. If anything fails → fix first.
### 2. Choose Outcome
- **MERGE:** squash-merge to main, delete branch
- **PR:** `gh pr create` with body auto-generated from git log
- **KEEP:** branch stays for later
- **DISCARD:** delete branch (confirm first — destructive)
Decision: tests pass + reviewed → MERGE/PR. Tests pass + unreviewed → PR. WIP → KEEP. Abandoned → DISCARD.
### 3. Post-Finalization
Log to `.godmode/session-log.tsv`. Print: `"Branch {name}: {outcome}"`.

## Rules
1. Clean state before finalize. No uncommitted changes, tests must pass.
2. Squash-merge for clean history. One commit per feature on main.
3. Never force-delete without confirmation.
4. PR body from git log. Auto-generate from commit history.
