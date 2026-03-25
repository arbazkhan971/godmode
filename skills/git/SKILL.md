---
name: git
description: |
  Advanced Git workflows skill. Branching models,
  merge vs rebase, interactive rebase, git bisect,
  cherry-pick, worktrees, commit conventions.
  Triggers on: /godmode:git, "branching strategy",
  "rebase vs merge", "git bisect", "cherry-pick".
---

# Git — Advanced Git Workflows

## When to Activate
- User invokes `/godmode:git`
- User says "branching strategy", "rebase vs merge"
- User says "git bisect", "interactive rebase"
- User needs parallel development with worktrees
- Messy history detected during review or ship

## Workflow

### Step 1: Assess Repository Context

```bash
# Repository stats
git log --oneline | wc -l         # Total commits
git branch -a | wc -l             # Total branches
git shortlog -sn | wc -l          # Contributors
git branch --merged main | wc -l  # Stale branches

# Detect commit conventions
git log --oneline -20 | head -10

# Check for tooling
ls .commitlintrc* .husky/ .git/hooks/commit-msg \
  2>/dev/null
```

```
GIT CONTEXT:
Team: solo | small (2-5) | medium (6-15) | large (15+)
Release cadence: continuous | weekly | monthly
Default branch: <main | master>
Commit convention: <conventional | custom | none>
Stale branches: <N branches merged but not deleted>
Stash count: <N>

IF team == solo: GitHub Flow or trunk-based
IF team == small: GitHub Flow or Ship/Show/Ask
IF team == large: trunk-based with feature flags
IF stale branches > 10: clean up immediately
IF stash count > 3: convert to branches or drop
```

### Step 2: Branching Strategy

```
STRATEGY SELECTION:
| Team Size  | Cadence    | Recommended        |
|-----------|------------|-------------------|
| Solo      | Continuous | Trunk-based       |
| 2-5       | Weekly     | GitHub Flow       |
| 6-15      | Bi-weekly  | Trunk-based + flags|
| 15+       | Varied     | Trunk-based + flags|
| Any       | Infrequent | GitFlow           |
```

### Step 3: Merge vs Rebase

```
| Criteria         | Merge  | Squash | Rebase |
|-----------------|--------|--------|--------|
| History         | Noisy  | Clean  | Clean  |
| Bisect          | Good   | Limited| Best   |
| Conflict pain   | Once   | Once   | Per-com|
| Safe for shared | Yes    | Yes    | NO     |

DECISION:
  15 WIP commits → squash merge
  3 clean commits → rebase + merge (preserve narrative)
  Release branch → merge commit (--no-ff)
  Hotfix to 2 branches → cherry-pick
  Long feature (>1 week) → rebase onto main weekly

THRESHOLDS:
  Branch age limit: 2 days (trunk-based), 7 days max
  IF branch > 7 days: rebase onto main immediately
  IF conflicts > 5 files: merge main INTO feature
```

### Step 4: Interactive Rebase

```
OPERATIONS:
| Command | Use Case                    |
|---------|----------------------------|
| pick    | Keep commit as-is          |
| reword  | Change message only        |
| squash  | Combine with previous      |
| fixup   | Combine, discard message   |
| drop    | Remove commit              |

SAFETY: Always create backup branch first:
  git branch backup-<name>
```

### Step 5: Git Bisect

```
git bisect start
git bisect bad                 # HEAD is broken
git bisect good v1.2.0         # This tag was good
# Git checks out middle commit — test it
git bisect good                # or git bisect bad
# Repeat until culprit found

AUTOMATED BISECT (recommended for > 10 commits):
  git bisect start HEAD v1.2.0
  git bisect run npm test
  # Finds the breaking commit automatically

THRESHOLDS:
  100 commits → bisect finds it in 7 steps
  1000 commits → 10 steps
  IF > 10 commits to search: always use automated
```

### Step 6: Cherry-Pick & Stash

```
CHERRY-PICK RULES:
  Single: git cherry-pick <SHA>
  Range: git cherry-pick A..B
  IF conflict: git cherry-pick --continue
  IF abort: git cherry-pick --abort

STASH RULES:
  IF stash survives > 1 day: convert to branch
  IF stash count > 3: clean up immediately
  Never use stash as long-term storage
```

### Step 7: Worktree Management

```bash
# Work on hotfix without switching branches
git worktree add ../project-hotfix hotfix/fix-123
# Work in ../project-hotfix independently
# Clean up when done
git worktree remove ../project-hotfix
```

### Step 8: Commit Conventions

```
CONVENTIONAL COMMITS:
  <type>[scope]: <description>

| Type     | SemVer | Usage              |
|----------|--------|--------------------|
| feat     | MINOR  | New feature        |
| fix      | PATCH  | Bug fix            |
| docs     | —      | Documentation      |
| refactor | —      | Code restructuring |
| test     | —      | Adding tests       |
| chore    | —      | Maintenance        |

RULES:
  Subject line: < 72 characters
  Body: wrap at 72 characters
  Footer: BREAKING CHANGE: description
```

Commit: `"docs: git workflow — <model> with <strategy>"`

## Key Behaviors

1. **Match workflow to team.** Solo != 50-person team.
2. **Consistency beats perfection.**
3. **History should tell a story.**
4. **Never rebase public branches.**
5. **Bisect is underused.** Use before reading 100 commits.
6. **Stashes are temporary.** Convert after 1 day.
7. **Worktrees eliminate context switching.**

## HARD RULES

1. Never rebase public/shared branches.
2. Never force-push shared branches. Use --force-with-lease.
3. Never mix merge strategies on a team.
4. Always use descriptive commit messages.
5. Always backup before interactive rebase.
6. Never accumulate > 3 stashes.
7. Always rebase before opening a PR.
8. Delete merged branches within 7 days.
9. Use automated bisect for > 10 commits.
10. Remove worktrees when done.

## Auto-Detection
```
1. Hosting: git remote -v
2. Conventions: git log patterns
3. Stale branches: git branch --merged
4. Tooling: .commitlintrc, .husky
```

## Quality Targets
- Target: <50MB max file size in repository
- Target: <10s for common git operations (status, diff, log)
- Branch age limit: <30 days before stale cleanup

## Output Format
Print: `Git: {operation} on {branch}. Commits: {N}.
  Conflicts: {N}. Stale: {N}. Verdict: {verdict}.`

## TSV Logging
```
timestamp	operation	branch	commits	conflicts	status
```

## Keep/Discard Discipline
```
KEEP if: rebase clean AND tests pass AND no artifacts
DISCARD if: rebase introduces artifacts OR tests fail
  Abort with git rebase --abort, use backup branch
```

## Stop Conditions
```
STOP when ALL of:
  - Branch strategy documented and agreed
  - All commits follow convention
  - Stale branches < 30 days cleaned
  - Stash count < 3
  - All operations result in passing tests
```

## Error Recovery
- Merge conflict too complex: backup, abort, break
  into smaller commits.
- Rebase wrong: git reflog, reset to pre-rebase state.
- Bisect wrong result: verify test script determinism.
