# /godmode:git

Advanced Git workflow mastery. Recommends branching strategies, merge/rebase decisions, interactive rebase guidance, git bisect for regression hunting, cherry-picking, stashing, worktree management, and commit message conventions.

## Usage

```
/godmode:git                           # Full workflow assessment and recommendation
/godmode:git --strategy                # Recommend branching strategy only
/godmode:git --merge                   # Recommend merge strategy (merge vs rebase vs squash)
/godmode:git --rebase                  # Interactive rebase guidance for current branch
/godmode:git --bisect                  # Start guided bisect to find a regression
/godmode:git --bisect-auto <script>    # Automated bisect with test script
/godmode:git --cherry-pick <SHA>       # Guided cherry-pick with conflict resolution
/godmode:git --stash                   # Stash management (list, apply, clean up)
/godmode:git --worktree                # Worktree setup for parallel development
/godmode:git --conventions             # Set up commit message conventions and tooling
/godmode:git --cleanup                 # Clean up stale branches, prune worktrees
/godmode:git --audit                   # Audit current Git practices and suggest improvements
```

## What It Does

1. **Assess** — Evaluate repository context, team size, release cadence
2. **Recommend** — Select branching model (GitFlow, Trunk-Based, GitHub Flow, Ship/Show/Ask)
3. **Configure** — Set up merge strategy, commit conventions, branch naming
4. **Tooling** — Install commitlint, husky, branch protection rules
5. **Guide** — Interactive rebase, bisect, cherry-pick, worktree operations

## Output
- Git workflow recommendation tailored to team context
- Branch naming conventions and protection rules
- Commit message convention configuration
- Guided operations (rebase, bisect, cherry-pick, worktree)

## Next Step
After git workflow setup: `/godmode:pr` for pull request excellence or `/godmode:ship` to ship.

## Examples

```
/godmode:git                           # Get a full workflow recommendation
/godmode:git --bisect                  # Find which commit introduced a bug
/godmode:git --rebase                  # Clean up branch history before PR
/godmode:git --conventions             # Set up Conventional Commits for the team
/godmode:git --worktree                # Set up parallel development worktrees
```
