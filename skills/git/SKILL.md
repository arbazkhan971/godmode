---
name: git
description: |
 Advanced Git workflows skill. Activates when user needs sophisticated version control strategies including branching models, merge vs rebase decisions, interactive rebase mastery, git bisect for regression hunting, cherry-picking, stashing, worktree management, and commit message conventions. Designs and validates Git workflows that scale from solo projects to large teams. Triggers on: /godmode:git, "branching strategy", "rebase vs merge", "git bisect", "interactive rebase", "cherry-pick", "git worktree", "conventional commits", or when the team needs a structured version control workflow.
---

# Git — Advanced Git Workflows

## When to Activate
- User invokes `/godmode:git`
- User says "branching strategy," "rebase vs merge," "git bisect," "interactive rebase"
- User needs to find a regression in the commit history
- User wants to set up commit conventions for a team
- User needs parallel development with worktrees
- User is restructuring commit history before a PR
- Godmode orchestrator detects messy Git history during `/godmode:review` or `/godmode:ship`

## Workflow

### Step 1: Assess Repository Context
Understand the project and team before recommending workflows:

```
GIT CONTEXT ASSESSMENT:
Repository:
 Name: <repo name>
 Size: <commits, contributors, branches>
 CI/CD: <GitHub Actions | GitLab CI | Jenkins | CircleCI | none>
 Hosting: <GitHub | GitLab | Bitbucket | self-hosted>

Team:
 Size: <solo | small (2-5) | medium (6-15) | large (15+)>
 Release cadence: <continuous | weekly | bi-weekly | monthly | ad-hoc>
 Environments: <dev | staging | production | multi-region>
 Code review: <required | optional | none>

Current state:
 Default branch: <main | master | develop>
 Active branches: <N>
 Stale branches (>30 days): <N>
 Merge strategy: <merge commits | squash | rebase | mixed>
 Commit conventions: <conventional | freeform | inconsistent>
 Protected branches: <list>

Recommended workflow: <GitFlow | Trunk-Based | GitHub Flow | Ship/Show/Ask>
Justification: <why this workflow fits>
```

### Step 2: Branching Strategy Selection
Choose the right branching model for the team:

#### GitFlow (Complex Release Cycles)
```
GITFLOW MODEL:
┌─────────────────────────────────────────────────────────────┐
│ │
│ main ────●─────────────●──────────────●──── (releases) │
│ │ │ │ │
│ hotfix │ ●──●─────┘ │ │
│ │ │ │
│ release │ ●──●──●────────────┘ │
│ │ │ │
│ develop ─┴────●────┴───●────●────●────●──── (integration) │
│ │ │ │
│ feature ●──●──●───────┘ │
│ │
└─────────────────────────────────────────────────────────────┘

Branch naming:
 feature/* — New features (branch from develop, merge to develop)
 release/* — Release preparation (branch from develop, merge to main + develop)
 hotfix/* — Production fixes (branch from main, merge to main + develop)
 develop — Integration branch (always deployable to staging)
 main — Production releases (tagged with semver)

Best for:
 - Scheduled release cycles (weekly, bi-weekly, monthly)
 - Multiple versions in production simultaneously
 - Teams with dedicated QA phase before release
 - Products with formal release approval process

Not for:
 - Continuous deployment teams
 - Solo developers or small teams
 - Microservices (too heavyweight per service)
```

#### Trunk-Based Development (Continuous Delivery)
```
TRUNK-BASED MODEL:
┌─────────────────────────────────────────────────────────────┐
│ │
│ main ──●──●──●──●──●──●──●──●──●──●──●──── (always │
│ │ │ │ │ deployable) │
│ short ●──●──┘ ●──●──┘ ●──●──┘ │
│ lived │
│ branches (< 2 days) │
│ │
│ releases: │
│ main ──────────●─────────────●──────────── (tagged) │
│ v1.2.0 v1.3.0 │
│ │
└─────────────────────────────────────────────────────────────┘

Rules:
 1. Branches live < 2 days (ideally < 1 day)
 2. Main is always deployable
 3. Feature flags gate incomplete work
 4. CI runs on every push to main
 5. Releases are tagged commits on main

Best for:
 - Continuous deployment (multiple deploys per day)
 - Teams with strong CI/CD and feature flags
 - Microservices architecture
 - Senior teams comfortable with small, frequent merges

Not for:
 - Teams without CI/CD
 - Teams that need long-running feature branches
 - Products with formal QA gates
```

#### GitHub Flow (Simple and Effective)
```
GITHUB FLOW MODEL:
┌─────────────────────────────────────────────────────────────┐
│ │
│ main ──●────●────●────●────●────●──── (always deployable) │
│ │ │ │ │ │ │ │
│ PR ●─●──┘ │ │ │ │ │
│ branch ●──●──●──┘ │ │ │
│ ●──●──●──●──┘ │ │
│ ●──●──┘ │
│ │
└─────────────────────────────────────────────────────────────┘

Rules:
 1. Main is always deployable
 2. Create a descriptive branch for every change
 3. Push to branch, open a pull request
 4. Discuss and review in the PR
 5. Merge to main after approval
 6. Deploy immediately after merge

Best for:
 - Most teams (default recommendation)
 - Open source projects
 - Teams using GitHub/GitLab with PR workflows
 - Moderate release cadence (daily to weekly)

Not for:
 - Teams needing multiple release versions simultaneously
 - Very large monorepos with complex release trains
```

#### Ship/Show/Ask (Trust-Based)
```
SHIP/SHOW/ASK MODEL:
┌─────────────────────────────────────────────────────────────┐
│ │
│ SHIP — Merge directly to main. No PR. No review. │
│ Use for: typos, config, CI fixes, docs, trivial │
│ │
│ SHOW — Merge to main, THEN open a PR for visibility. │
│ Use for: small refactors, non-critical features, │
│ changes within your domain expertise │
│ │
│ ASK — Open a PR and wait for review BEFORE merging. │
│ Use for: architecture changes, security changes, │
│ cross-team code, unfamiliar areas │
│ │
└─────────────────────────────────────────────────────────────┘

Decision matrix:
┌───────────────────────────┬──────┬──────┬──────┐
│ Change Type │ SHIP │ SHOW │ ASK │
├───────────────────────────┼──────┼──────┼──────┤
│ Typo/docs fix │ ● │ │ │
│ Config change │ ● │ │ │
│ Bug fix (well-tested) │ │ ● │ │
│ Small refactor │ │ ● │ │
│ New feature (your domain) │ │ ● │ │
│ New feature (other domain)│ │ │ ● │
│ Architecture change │ │ │ ● │
│ Security-related change │ │ │ ● │
│ Database migration │ │ │ ● │
│ Public API change │ │ │ ● │
└───────────────────────────┴──────┴──────┴──────┘

Best for:
 - High-trust senior teams
 - Teams that want speed without bureaucracy
 - Organizations with strong testing culture

Not for:
 - Teams with junior developers who need review feedback
 - Compliance-heavy environments (SOC2, HIPAA)
 - Teams without comprehensive test suites
```

### Step 3: Merge vs Rebase Strategy
Choose the right integration strategy:

```
MERGE VS REBASE DECISION:
┌─────────────────────────────────────────────────────────────┐
│ Criteria │ Merge Commit │ Squash │ Rebase │
├───────────────────────┼──────────────┼────────────┼─────────┤
│ History readability │ Noisy │ Clean │ Clean │
│ Preserves context │ Full │ Summarized │ Full │
│ Bisect effectiveness │ Good │ Limited │ Best │
│ Conflict resolution │ Once │ Once │ Per-com │
│ Reversibility │ Easy revert │ Easy revert│ Hard │
│ Force push required │ No │ No │ Yes │
│ CI re-runs │ No │ No │ Yes │
│ Safe for shared branch│ Yes │ Yes │ NO │
└───────────────────────┴──────────────┴────────────┴─────────┘

RECOMMENDED STRATEGY BY CONTEXT:
 Solo developer: Rebase (clean linear history)
 Small team: Squash merge (clean + easy revert)
 Large team: Merge commits (preserves full context)
 Open source: Squash merge (clean mainline history)
 Monorepo: Merge commits (bisect across packages)

GOLDEN RULES:
 1. Never rebase public/shared branches
 2. Rebase YOUR branch onto main, never main onto your branch
 3. Squash merge for feature branches with messy WIP commits
 4. Merge commits when individual commits tell a meaningful story
 5. Be consistent — the whole team uses the same strategy
```

### Step 4: Interactive Rebase Mastery
Restructure commit history before merging:

```
INTERACTIVE REBASE OPERATIONS:
┌──────────┬─────────────────────────────────────────────────────┐
│ Command │ Use Case │
├──────────┼─────────────────────────────────────────────────────┤
│ pick │ Keep commit as-is │
│ reword │ Change commit message (keep changes) │
│ edit │ Stop at commit to amend (split, modify) │
│ squash │ Combine with previous commit (keep both messages) │
│ fixup │ Combine with previous commit (discard this message) │
│ drop │ Remove commit entirely │
│ reorder │ Move commit lines to change order │
└──────────┴─────────────────────────────────────────────────────┘

COMMON REBASE RECIPES:

Recipe 1: Clean up before PR
 git rebase -i main
 - Squash WIP commits into logical units
 - Reword messages to follow conventions
 - Drop debug/experiment commits
 - Result: each commit is a logical, reviewable unit

Recipe 2: Split a commit that's too large
 git rebase -i HEAD~3
 # Mark the commit as 'edit'
 git reset HEAD~1 # Unstage the commit
 git add <file1> # Stage first logical change
 git commit -m "feat: add user model"
 git add <file2> # Stage second logical change
 git commit -m "feat: add user API endpoint"
 git rebase --continue

Recipe 3: Reorder commits for better narrative
 git rebase -i HEAD~5
 # Rearrange pick lines so the story flows:
 # 1. Add data model
 # 2. Add business logic
 # 3. Add API endpoint
 # 4. Add tests
 # 5. Add documentation

Recipe 4: Fixup a previous commit
 # Make your fix, then:
 git commit --fixup=<SHA of commit to fix>
 # Later, autosquash:
 git rebase -i --autosquash main

SAFETY NET:
 Before any rebase: git branch backup-<branch-name>
 If rebase goes wrong: git rebase --abort
 If already completed: git reflog → git reset --hard <pre-rebase-SHA>
```

### Step 5: Git Bisect for Finding Regressions
Binary search through history to find the commit that introduced a bug:

```
GIT BISECT WORKFLOW:
┌─────────────────────────────────────────────────────────────┐
│ │
│ ●──●──●──●──●──●──●──●──●──●──●──●──●──● (100 commits) │
│ ▲ ▲ │
│ GOOD BAD │
│ (v1.2.0) (HEAD) │
│ │
│ Bisect finds the bad commit in log2(100) = 7 steps │
│ │
└─────────────────────────────────────────────────────────────┘

MANUAL BISECT:
 git bisect start
 git bisect bad # Current commit is broken
 git bisect good v1.2.0 # This tag was working
 # Git checks out the middle commit
 # Test manually, then:
 git bisect good # or: git bisect bad
 # Repeat until the bad commit is found
 git bisect reset # Return to original branch

AUTOMATED BISECT (recommended):
 git bisect start
 git bisect bad HEAD
 git bisect good v1.2.0
 git bisect run <test-script>
 # Script must exit 0 for good, 1 for bad, 125 to skip
 git bisect reset

Example test script (bisect-test.sh):
 #!/bin/bash
 npm test -- --grep "user login" 2>/dev/null
 # Exit code 0 = test passes (good commit)
 # Exit code 1 = test fails (bad commit)

BISECT WITH COMPLEX CRITERIA:
 #!/bin/bash
 # Build the project (skip if build fails on old commits)
 make build || exit 125
 # Run the specific failing test
 make test-login || exit 1
 exit 0

AFTER FINDING THE BAD COMMIT:
 1. Read the commit: git show <bad-SHA>
 2. Understand what changed and why it broke
 3. Fix the bug (do NOT revert blindly)
 4. Write a regression test that catches this specific failure
 5. Commit: "fix: <description> — regression from <bad-SHA>"
```

### Step 6: Cherry-Picking and Stashing Strategies
Selective commit application and work-in-progress management:

```
CHERRY-PICK PATTERNS:
┌─────────────────────────────────────────────────────────────┐
│ Pattern │ Command │
├──────────────────────────┼──────────────────────────────────┤
│ Single commit │ git cherry-pick <SHA> │
│ Range of commits │ git cherry-pick A..B │
│ Multiple specific │ git cherry-pick A B C │
│ Without committing │ git cherry-pick -n <SHA> │
│ Resolve conflicts │ git cherry-pick --continue │
│ Abort cherry-pick │ git cherry-pick --abort │
└──────────────────────────┴──────────────────────────────────┘

When to cherry-pick:
 ✓ Hotfix from develop to main (or vice versa)
 ✓ Backporting a fix to a release branch
 ✓ Extracting one commit from a branch you don't want to merge
 ✗ Do NOT cherry-pick entire branches (use merge/rebase instead)
 ✗ Do NOT cherry-pick into branches that will later merge (creates duplicates)

STASH STRATEGIES:
┌─────────────────────────────────────────────────────────────┐
│ Operation │ Command │
├──────────────────────────┼──────────────────────────────────┤
│ Stash with message │ git stash push -m "WIP: login" │
│ Stash specific files │ git stash push -m "msg" -- file │
│ Stash including untracked│ git stash push -u -m "msg" │
│ List stashes │ git stash list │
│ Apply (keep in stash) │ git stash apply stash@{0} │
│ Pop (remove from stash) │ git stash pop stash@{0} │
│ Show stash contents │ git stash show -p stash@{0} │
│ Create branch from stash │ git stash branch <name> │
│ Drop specific stash │ git stash drop stash@{0} │
│ Clear all stashes │ git stash clear │
└──────────────────────────┴──────────────────────────────────┘

Stash best practices:
 1. Always use -m with descriptive messages
 2. Don't accumulate stashes — apply or drop within a day
 3. Use 'git stash branch' for stashes that grow complex
 4. Prefer WIP commits over stashes for longer pauses:
 git commit -am "WIP: description" (rewrite later with rebase)
```

### Step 7: Worktree Management for Parallel Development
Work on multiple branches simultaneously without switching:

```
GIT WORKTREE PATTERNS:
┌─────────────────────────────────────────────────────────────┐
│ │
│ /project/ (main worktree — main branch) │
│ /project-hotfix/ (linked worktree — hotfix/*) │
│ /project-feature/ (linked worktree — feature/*) │
│ /project-review/ (linked worktree — PR review) │
│ │
└─────────────────────────────────────────────────────────────┘

WORKTREE COMMANDS:
┌──────────────────────────────┬──────────────────────────────┐
│ Operation │ Command │
├──────────────────────────────┼──────────────────────────────┤
│ Add worktree (existing br.) │ git worktree add../proj-fix │
│ │ hotfix/urgent-fix │
│ Add worktree (new branch) │ git worktree add -b feat/new │
│ │../proj-feat main │
│ List worktrees │ git worktree list │
│ Remove worktree │ git worktree remove │
│ │../proj-fix │
│ Prune stale worktrees │ git worktree prune │
└──────────────────────────────┴──────────────────────────────┘

USE CASES:
 1. Hotfix while feature work is in progress
 - Main worktree: continue feature development
 - Linked worktree: fix production bug immediately
 - No stashing, no context switching, no lost state

 2. PR review without disrupting current work
 - Main worktree: keep coding
 - Linked worktree: check out PR branch, run tests, review

 3. Compare behavior across branches
 - Run both versions simultaneously
 - A/B test behavior in parallel

 4. Long-running build/test in one worktree
 - Start CI-like test run in worktree A
 - Continue development in worktree B

WORKTREE BEST PRACTICES:
 1. Use a consistent naming convention:../project-<purpose>/
 2. Remove worktrees when done (they take disk space)
 3. Each worktree has its own working directory but shares.git
 4. Install dependencies separately in each worktree
 5. Don't check out the same branch in multiple worktrees
```

### Step 8: Commit Message Conventions
Standardize commit messages for automation and readability:

```
CONVENTIONAL COMMITS FORMAT:
┌─────────────────────────────────────────────────────────────┐
│ │
│ <type>[optional scope]: <description> │
│ │
│ [optional body] │
│ │
│ [optional footer(s)] │
│ │
└─────────────────────────────────────────────────────────────┘

TYPES:
┌──────────┬──────────────────────────────────┬───────────────┐
│ Type │ Description │ SemVer Impact │
├──────────┼──────────────────────────────────┼───────────────┤
│ feat │ New feature │ MINOR │
│ fix │ Bug fix │ PATCH │
│ docs │ Documentation only │ none │
│ style │ Formatting, whitespace │ none │
│ refactor │ Code change, no feature/fix │ none │
│ perf │ Performance improvement │ PATCH │
│ test │ Adding or correcting tests │ none │
│ build │ Build system or dependencies │ none │
│ ci │ CI configuration │ none │
│ chore │ Maintenance tasks │ none │
│ revert │ Revert a previous commit │ varies │
└──────────┴──────────────────────────────────┴───────────────┘

BREAKING CHANGES:
 Append ! after type/scope: feat!: remove deprecated login endpoint
 Or add footer: BREAKING CHANGE: login endpoint removed

EXAMPLES:
 feat(auth): add OAuth2 login with Google provider
 fix(api): handle null response from payment gateway
 docs(readme): add deployment instructions for AWS
 refactor(db): extract query builder from repository layer
 perf(search): add index on users.email for faster lookup
 test(auth): add edge cases for expired JWT tokens
 ci: add Node 20 to test matrix
 feat!: drop support for Node 16

 feat(cart): add quantity limits per product

 Products can now have a maximum quantity per cart.
 Default limit is 99. Configurable per product in admin panel.

 Closes #1234

ENFORCEMENT:
 - commitlint: lint commit messages in CI
 - husky: pre-commit hook to validate format
 - commitizen: interactive commit message builder (cz-cli)

 #.commitlintrc.json
 {
 "extends": ["@commitlint/config-conventional"],
 "rules": {
 "type-enum": [2, "always", [
 "feat", "fix", "docs", "style", "refactor",
 "perf", "test", "build", "ci", "chore", "revert"
 ]],
 "subject-max-length": [2, "always", 72],
 "body-max-line-length": [2, "always", 100]
 }
 }
```

### Step 9: Git Workflow Report

```
┌────────────────────────────────────────────────────────────┐
│ GIT WORKFLOW RECOMMENDATION │
├────────────────────────────────────────────────────────────┤
│ Team size: <N> │
│ Release cadence: <cadence> │
│ │
│ Branching model: <GitFlow | Trunk-Based | GitHub Flow | │
│ Ship/Show/Ask> │
│ Merge strategy: <merge commits | squash | rebase> │
│ Commit convention: <Conventional Commits | custom> │
│ │
│ Branch naming: │
│ feature/<ticket>-<slug> │
│ fix/<ticket>-<slug> │
│ hotfix/<slug> │
│ release/<version> │
│ │
│ Protected branches: <list> │
│ Required reviews: <N> │
│ CI requirements: <list> │
│ │
│ Tooling: │
│ - commitlint + husky for commit message validation │
│ - Branch protection rules configured │
│ - PR template created │
│ -.gitignore reviewed │
│ │
│ Ready for: /godmode:pr or /godmode:ship │
└────────────────────────────────────────────────────────────┘
```

### Step 10: Commit and Transition
1. Save workflow configuration as `.github/CONTRIBUTING.md` or `docs/git-workflow.md`
2. Commit: `"docs: git workflow — <branching model> with <merge strategy>"`
3. After workflow setup: "Git workflow configured. Use `/godmode:pr` for pull request excellence or `/godmode:ship` to ship."

## Key Behaviors

1. **Match workflow to team.** A solo developer does not need GitFlow. A 50-person team should not use Ship/Show/Ask without safeguards. Always assess context first.
2. **Consistency beats perfection.** A mediocre strategy applied consistently is better than a perfect strategy applied inconsistently. Get team buy-in.
3. **History should tell a story.** Each commit on main should represent a logical, reviewable unit of work. Use interactive rebase to achieve this before merging.
4. **Never rebase public branches.** Rebase your own feature branch onto main. Never rebase main onto anything. Never force-push shared branches.
5. **Bisect is underused.** When a regression appears, reach for `git bisect` before reading through 100 commits manually. Automated bisect is even better.
6. **Stashes are temporary.** If a stash survives more than a day, it should be a WIP commit or a branch. Stash lists longer than 3 entries are a smell.
7. **Worktrees eliminate context switching.** Instead of stashing, switching branches, and restoring state, open another worktree. Each worktree is isolated.

## Example Usage

### Setting up a Git workflow for a team
```
User: /godmode:git We're a team of 8 engineers, deploying to production
 twice a week. What branching strategy should we use?

Git: Assessing repository context...

GIT CONTEXT ASSESSMENT:
Team size: medium (8 engineers)
Release cadence: bi-weekly
Environments: staging + production

Recommended workflow: GitHub Flow

Justification:
- Team size is manageable for PR-based workflow
- Bi-weekly releases don't need GitFlow complexity
- GitHub Flow gives you code review without ceremony

Branching model:
 main — always deployable, protected
 feature/<ticket>-<slug> — feature branches from main
 fix/<ticket>-<slug> — bug fix branches from main
 hotfix/<slug> — urgent production fixes

Merge strategy: Squash merge
 - Clean mainline history (one commit per feature)
 - Easy to revert entire features
 - PR title becomes the commit message

Commit convention: Conventional Commits
 - Enables automated changelog generation
 - Clear intent in every commit message
 - Enforced via commitlint + husky

Setting up tooling...
✓ commitlint configured
✓ husky pre-commit hook installed
✓ PR template created
✓ Branch protection rules documented
```


## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full workflow assessment and recommendation |
| `--strategy` | Recommend branching strategy only |
| `--merge` | Recommend merge strategy (merge vs rebase vs squash) |
| `--rebase` | Interactive rebase guidance for current branch |
| `--bisect` | Start guided bisect to find a regression |
| `--bisect-auto <script>` | Automated bisect with test script |
| `--cherry-pick <SHA>` | Guided cherry-pick with conflict resolution |
| `--stash` | Stash management (list, apply, clean up) |
| `--worktree` | Worktree setup for parallel development |
| `--conventions` | Set up commit message conventions and tooling |
| `--cleanup` | Clean up stale branches, prune worktrees |
| `--audit` | Audit current Git practices and suggest improvements |

## Auto-Detection

On activation, automatically detect Git repository context:

```
AUTO-DETECT SEQUENCE:
1. Run: git remote -v — detect hosting (GitHub, GitLab, Bitbucket, self-hosted)
2. Run: git log --oneline -20 — detect commit message conventions (conventional, freeform, mixed)
3. Run: git branch -a — count active branches, identify default branch (main/master/develop)
4. Run: git branch --merged main — count stale merged branches
5. Check for branch protection:.github/settings.yml, CODEOWNERS, branch protection API
6. Detect CI/CD:.github/workflows/,.gitlab-ci.yml, Jenkinsfile,.circleci/config.yml
7. Check for commit tooling:.commitlintrc*,.husky/,.czrc, commitizen config in package.json
8. Detect merge strategy: scan recent merge commits for --squash, --no-ff, or rebase patterns
9. Check for PR templates:.github/pull_request_template.md,.gitlab/merge_request_templates/
10. Count contributors (git shortlog -sn) — determine team size for workflow recommendation
```

## Keep/Discard Discipline
Each Git operation either improves the branch state or gets reverted.
- **KEEP**: Rebase produces clean history, tests pass after merge, no conflicts remain.
- **DISCARD**: Rebase introduces merge artifacts, tests fail, or history becomes less clear. Revert to backup branch.
- **CRASH**: Rebase conflict too complex to resolve cleanly. Abort (`git rebase --abort`), reassess approach.
- Always create a backup branch before interactive rebase: `git branch backup-<name>`.

## Stop Conditions
- Branch strategy documented and team-agreed (one of: trunk-based, GitHub Flow, GitFlow, Ship/Show/Ask).
- All commits on the branch follow the team's commit convention.
- No stale branches older than 30 days remain. Merged branches deleted within 7 days.
- All merge/rebase operations result in passing tests.
- Stash count is under 3.

## Hard Rules

```
HARD RULES — GIT:
1. NEVER rebase public/shared branches. Rebase only YOUR branches onto main.
2. NEVER use git push --force on shared branches. Use --force-with-lease on your own branches only.
3. NEVER mix merge strategies on a team. Pick one (merge, squash, or rebase) and enforce consistently.
4. ALWAYS use descriptive commit messages following the team's convention. "fix stuff" is never acceptable on main.
5. ALWAYS create a backup branch before interactive rebase: git branch backup-<name>.
6. NEVER accumulate more than 3 stashes. Convert stale stashes to branches or drop them.
7. ALWAYS run interactive rebase before opening a PR. Clean, logical commits — not WIP sausage-making.
8. NEVER leave stale branches. Delete merged branches within 7 days. Review inactive branches at 30 days.
9. ALWAYS use automated bisect (git bisect run) when hunting regressions across >10 commits.
10. ALWAYS remove worktrees when done. They share.git but consume disk space and create confusion.
```

## Output Format

After each git skill invocation, emit a structured report:

```
GIT OPERATION REPORT:
┌──────────────────────────────────────────────────────┐
│ Operation │ <branch | merge | rebase | bisect | worktree> │
│ Branch │ <branch name> │
│ Commits │ <N> created / <N> cleaned up │
│ Conflicts resolved │ <N> │
│ Stale branches │ <N> cleaned / <N> remaining │
│ Worktrees │ <N> active │
│ Stashes │ <N> current (target: < 3) │
│ Tests after │ PASSING / FAILING │
│ Verdict │ CLEAN | NEEDS ATTENTION │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every git operation for tracking:

```
timestamp	skill	operation	branch	commits	conflicts	tests_pass	status
2026-03-20T14:00:00Z	git	rebase	feature/auth	5	0	yes	clean
2026-03-20T14:10:00Z	git	merge	release/v2.0	12	3	yes	resolved
```

## Success Criteria

The git skill is complete when ALL of the following are true:
1. Branch strategy is established and documented (trunk-based, gitflow, or GitHub flow)
2. All commits follow the team's commit message convention
3. No stale branches older than 30 days (merged branches deleted within 7 days)
4. Stash count is < 3 (stale stashes converted to branches or dropped)
5. All merge/rebase operations result in passing tests
6. Worktrees are cleaned up after use
7. Interactive rebase is performed before PR (clean, logical commits)

## Error Recovery

```
IF merge conflict is too complex to resolve:
 1. Create a backup branch: git branch backup-<name>
 2. Try rebase --abort or merge --abort to return to clean state
 3. Break the conflicting changes into smaller, non-overlapping commits
 4. Re-attempt the merge/rebase with the smaller changes

IF interactive rebase goes wrong:
 1. NEVER panic — git reflog shows everything
 2. Find the pre-rebase commit: git reflog | head -20
 3. Reset to the pre-rebase state: git reset --hard <pre-rebase-hash>
 4. Re-attempt with a more careful edit plan

IF bisect identifies the wrong commit:
 1. Verify the test script is deterministic (run it twice on the same commit)
 2. Check for flaky tests that may give false good/bad results
 3. Narrow the range manually and re-run bisect
 4. Use git bisect log to review and replay the bisect session

IF force push was accidentally done to shared branch:
 1. Alert the team immediately
 2. Find the pre-force-push ref: git reflog on the remote or another developer's local
 3. Restore with: git push --force-with-lease origin <correct-hash>:<branch>
 4. Have all team members pull the corrected branch
```


ADVANCED MERGE/REBASE SCENARIOS:

Scenario: Feature branch with 15 WIP commits, target is main
 → Squash merge. WIP history is noise. PR title becomes commit message.

Scenario: Feature branch with 3 clean, logical commits, target is main
 → Rebase + merge (or merge --no-ff). Preserve the meaningful commit narrative.

Scenario: Release branch merging back to main
 → Merge commit (--no-ff). The merge commit documents the release integration point.

Scenario: Hotfix applying to both main and develop
 → Cherry-pick to the second branch. Do NOT merge between main and develop.

Scenario: Long-running feature branch (>1 week) falling behind main
 → Rebase onto main weekly. Resolve conflicts incrementally, not all at once.
 → IF conflicts are too frequent: merge main INTO feature branch (pragmatic, preserves history).

Scenario: Contributor's PR to open-source project
 → Squash merge. External contributor's commit style may not match project conventions.

CONFLICT RESOLUTION STRATEGY:
 1. ALWAYS rebase/merge from main BEFORE opening a PR (author's responsibility)
 2. IF conflicts arise during PR review: author resolves, not reviewer
 3. IF conflicts arise during merge: resolve in a separate commit (not hidden in the merge)
 4. DOCUMENT non-obvious conflict resolutions in the PR comment thread
 5. AFTER resolving: run full test suite to verify resolution correctness
```
