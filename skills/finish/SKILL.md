---
name: finish
description: |
  Branch finalization skill. Activates when work on a branch is done and needs to be wrapped up. Handles four outcomes: merge to main, create PR for review, keep branch for later, or discard branch. Ensures clean state before any finalization action. Triggers on: /godmode:finish, "done with this branch", "merge this", "clean up", or after ship phase completes.
---

# Finish — Branch Finalization

## When to Activate
- User invokes `/godmode:finish`
- User says "done with this branch," "wrap up," "merge this"
- After `/godmode:ship` completes and the PR is merged
- User wants to clean up after a feature is complete
- User wants to discard an abandoned branch

## Workflow

### Step 1: Assess Branch State
Check the current branch's state:

```bash
# Current branch
git branch --show-current

# Uncommitted changes
git status

# Relationship to main
git log main..HEAD --oneline
git diff main..HEAD --stat

# Any stashed changes
git stash list
```

```
BRANCH STATE:
Branch: <name>
Base: <main/master>
Commits ahead: <N>
Files changed: <N>
Uncommitted changes: <YES/NO>
Stashed changes: <N>
Tests: <passing/failing>
PR: <#N if exists, else "none">
```

### Step 2: Clean Up
Before finalizing, ensure everything is clean:

1. **Uncommitted changes:**
   - If meaningful: commit them
   - If temporary/debug: discard them (with user confirmation)

2. **Stashed changes:**
   - If related to this branch: apply and commit
   - If unrelated: leave stashed, note for user

3. **Tests:**
   - Must pass before merge/PR
   - Can be failing if discarding

4. **Lint/Types:**
   - Must be clean before merge/PR

```
CLEANUP:
✓ All changes committed
✓ No stashed changes for this branch
✓ Tests passing (47/47)
✓ Lint clean
✓ Types clean
```

### Step 3: Choose Finalization Action
Present options to the user:

```
Branch feat/rate-limiter is ready to finalize.

Options:
1. MERGE  — Merge directly into main (for small, reviewed changes)
2. PR     — Create a pull request for review (recommended)
3. KEEP   — Keep the branch for later work
4. DISCARD — Delete the branch and all changes
```

### Action: MERGE
```bash
# Switch to main
git checkout main
git pull origin main

# Merge the feature branch
git merge feat/<feature> --no-ff -m "Merge feat/<feature>: <description>"

# Delete the feature branch
git branch -d feat/<feature>

# Push
git push origin main
git push origin --delete feat/<feature>  # delete remote branch
```

Pre-merge checks:
- [ ] Tests pass on the branch
- [ ] Branch is rebased on latest main
- [ ] No merge conflicts
- [ ] Code review completed (or not required)

### Action: PR
```bash
# Push the branch
git push -u origin feat/<feature>

# Create PR
gh pr create \
  --title "<feature>: <brief description>" \
  --body "<generated PR description>"
```

Then transition to `/godmode:ship --pr` for the full PR workflow.

### Action: KEEP
```bash
# Push to remote so it's backed up
git push -u origin feat/<feature>

# Switch back to main
git checkout main
```

```
Branch feat/<feature> saved to remote.
To resume later: git checkout feat/<feature>
```

### Action: DISCARD
```bash
# Confirm with user — this is destructive
echo "This will permanently delete branch feat/<feature> and all <N> commits."
echo "Are you sure? (yes/no)"

# If confirmed:
git checkout main
git branch -D feat/<feature>
git push origin --delete feat/<feature> 2>/dev/null  # if remote exists
```

### Step 4: Post-Finalization
After the action completes:

```
FINALIZATION COMPLETE:
Action: <MERGE | PR | KEEP | DISCARD>
Branch: feat/<feature>
Current branch: main

Summary:
- <What happened>
- <Any artifacts created (PR URL, etc.)>
- <Any cleanup performed>

Next:
→ Start a new feature: /godmode:think
→ Check project status: /godmode
```

## Key Behaviors

1. **Always clean up first.** No uncommitted changes, no failing tests (unless discarding).
2. **Confirm destructive actions.** Discarding a branch is permanent. Always confirm.
3. **Recommend PR over direct merge.** PRs leave an audit trail and allow review.
4. **Push before keeping.** If keeping a branch for later, push it to the remote so it's not just local.
5. **Delete merged branches.** After a successful merge, clean up the local and remote branch.
6. **Report what happened.** The user should know exactly what state things are in after finalization.

## Example Usage

### Finishing a feature
```
User: /godmode:finish

Finish: Assessing branch state...

BRANCH STATE:
Branch: feat/rate-limiter
Commits ahead: 14
Tests: 51/51 passing
PR: none

Options:
1. MERGE — Merge into main
2. PR — Create pull request (recommended)
3. KEEP — Save for later
4. DISCARD — Delete branch

User: 2

Finish: Creating pull request...
Pushing branch to remote...
Creating PR #124: "Rate limiter: sliding window with Redis store"
PR URL: https://github.com/org/repo/pull/124

Run /godmode:ship for the full shipping workflow.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive — present options |
| `--merge` | Direct merge to main |
| `--pr` | Create pull request |
| `--keep` | Keep branch for later |
| `--discard` | Delete branch (requires confirmation) |
| `--force-discard` | Delete without confirmation (use carefully) |

## Anti-Patterns

- **Do NOT merge with failing tests.** Fix them first with `/godmode:fix`.
- **Do NOT discard without confirmation.** Even with `--force-discard`, warn about what will be lost.
- **Do NOT leave branches lingering.** If a branch is done, finish it. Stale branches are confusing.
- **Do NOT merge without rebasing.** Always rebase on latest main before merging to avoid unnecessary merge conflicts.
- **Do NOT forget to push before keeping.** A local-only branch is one `rm -rf` away from gone.
