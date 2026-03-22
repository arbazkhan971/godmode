---
name: pr
description: |
  Pull request excellence skill. Activates when user needs to create, optimize, or manage pull requests with best practices including description templates, size optimization, stacked PRs for large features, review request strategies, auto-labeling, auto-assignment, and PR metrics for cycle time optimization. Designs PRs that are easy to review, quick to merge, and well-documented. Triggers on: /godmode:pr, "create a PR", "stacked PRs", "PR template", "review request", "PR too large", or when preparing to merge code that needs structured review.
---

# PR — Pull Request Excellence

## When to Activate
- User invokes `/godmode:pr`
- User says "create a PR," "stacked PRs," "PR template," "PR too large"
- User needs to break a large change into reviewable pieces
- User wants to optimize PR review cycle time
- User needs a PR description template for the team
- Godmode orchestrator detects a large diff during `/godmode:ship`

## Workflow

### Step 1: Assess PR Context
Understand the change and determine the optimal PR strategy:

```
PR ASSESSMENT:
Change analysis:
  Branch: <branch name>
  Base: <target branch>
  Commits: <N>
  Files changed: <N>
  Lines added: <N>
  Lines removed: <N>
  Net change: <+/- N>

Size classification:
  XS:  1-10 lines    (trivial — auto-merge candidate)
  S:   11-50 lines   (ideal — single concept, quick review)
  M:   51-200 lines  (acceptable — focused feature or fix)
  L:   201-500 lines (too large — consider splitting)
  XL:  500+ lines    (must split — stacked PRs required)

Current size: <XS | S | M | L | XL>

Change categories:
  - [ ] New feature
  - [ ] Bug fix
  - [ ] Refactor (no behavior change)
  - [ ] Documentation
  - [ ] Test coverage
  - [ ] Configuration / infrastructure
  - [ ] Dependency update
  - [ ] Database migration

Risk level: <LOW | MEDIUM | HIGH>
Review urgency: <ASAP | normal | low priority>
Suggested reviewers: <based on file ownership / CODEOWNERS>
```

### Step 2: PR Size Optimization
If the PR is too large, split it into smaller, focused PRs:

```
PR SPLITTING STRATEGIES:
┌─────────────────────────────────────────────────────────────┐
│ Strategy          │ When to Use                             │
├───────────────────┼─────────────────────────────────────────┤
│ By layer          │ Data model → business logic → API →     │
│                   │ UI (each layer is one PR)               │
│ By feature slice  │ Each user-facing feature is one PR      │
│ By refactor+feat  │ Refactor first (PR 1), feature (PR 2)  │
│ By test+impl      │ Tests first (PR 1), implementation     │
│                   │ (PR 2)                                  │
│ By file type      │ Schema migration (PR 1), code (PR 2),  │
│                   │ config (PR 3)                           │
└───────────────────┴─────────────────────────────────────────┘

SPLITTING EXAMPLE:
  Original: 450-line PR "Add user permissions system"

  Split into:
  PR 1: Add permission model and migration (80 lines) — S
    - Database schema for permissions table
    - Model with validations
    - Unit tests for model

  PR 2: Add permission service layer (120 lines) — M
    - Business logic for checking permissions
    - Caching layer for permission lookups
    - Service tests

  PR 3: Add permission API endpoints (90 lines) — M
    - REST endpoints for CRUD operations
    - Request validation
    - Integration tests

  PR 4: Add permission UI components (100 lines) — M
    - Permission management page
    - Role assignment UI
    - Component tests

  Result: 4 focused PRs instead of 1 overwhelming PR
  Average review time: 15 min each vs 2+ hours for the original

WHY SMALL PRS MATTER:
┌─────────────────────────────────────────────────────────────┐
│ PR Size  │ Review Quality │ Time to Merge │ Bug Escape Rate│
├──────────┼────────────────┼───────────────┼────────────────┤
│ < 50 LOC │ Thorough       │ < 1 hour      │ Very low       │
│ 50-200   │ Good           │ < 4 hours     │ Low            │
│ 200-500  │ Declining      │ 1-3 days      │ Moderate       │
│ 500+     │ Rubber stamp   │ 3+ days       │ High           │
└──────────┴────────────────┴───────────────┴────────────────┘
```

### Step 3: PR Description Template
Generate a high-quality PR description:

```
PR DESCRIPTION TEMPLATE:
┌─────────────────────────────────────────────────────────────┐
│ ## Summary                                                  │
│ <1-3 sentences: what this PR does and why>                  │
│                                                             │
│ ## Problem                                                  │
│ <What issue or need does this address?>                     │
│ <Link to issue/ticket: Closes #NNN>                         │
│                                                             │
│ ## Solution                                                 │
│ <How does this PR solve the problem?>                       │
│ <Key design decisions and tradeoffs>                        │
│                                                             │
│ ## Changes                                                  │
│ - <Bulleted list of specific changes>                       │
│ - <One line per logical change>                             │
│                                                             │
│ ## Testing                                                  │
│ - <How was this tested?>                                    │
│ - <New tests added? Which scenarios?>                       │
│ - <Manual testing steps, if applicable>                     │
│                                                             │
│ ## Screenshots (if UI change)                               │
│ | Before | After |                                          │
│ |--------|-------|                                          │
│ | <img>  | <img> |                                          │
│                                                             │
│ ## Checklist                                                │
│ - [ ] Tests passing                                         │
│ - [ ] Lint clean                                            │
│ - [ ] Documentation updated                                 │
│ - [ ] No breaking changes (or documented)                   │
│ - [ ] Reviewed my own diff before requesting review         │
│                                                             │
│ ## Reviewer Notes                                           │
│ <Anything specific reviewers should focus on?>              │
│ <Areas of uncertainty where feedback is wanted?>            │
└─────────────────────────────────────────────────────────────┘

DESCRIPTION ANTI-PATTERNS:
  ✗ "Fixed the thing"               — What thing? Why?
  ✗ "See ticket for details"        — PR should be self-contained
  ✗ No description at all           — Forces reviewers to read every line blind
  ✗ 500-word essay                  — Keep it scannable
  ✓ "Fix race condition in checkout that caused duplicate charges
     when users double-clicked the pay button. Added debounce to the
     submit handler and idempotency key to the payment API call."
```

### Step 4: Stacked PRs for Large Features
Decompose large features into dependent, sequential PRs:

```
STACKED PR PATTERN:
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  main ──────────────────────────────────────────            │
│    │                                                        │
│    ├── PR 1: Data model (base: main)                        │
│    │     │                                                  │
│    │     ├── PR 2: Service layer (base: PR 1 branch)        │
│    │     │     │                                            │
│    │     │     ├── PR 3: API endpoints (base: PR 2 branch)  │
│    │     │     │     │                                      │
│    │     │     │     └── PR 4: UI (base: PR 3 branch)       │
│    │     │     │                                            │
│    │     │     └─────────────────────────────────            │
│    │     │                                                  │
│    │     └───────────────────────────────────────            │
│    │                                                        │
│    └─────────────────────────────────────────────            │
│                                                             │
│  Merge order: PR 1 → PR 2 → PR 3 → PR 4                   │
│  Each PR is small, focused, and independently reviewable    │
│                                                             │
└─────────────────────────────────────────────────────────────┘

STACKED PR WORKFLOW:

1. Plan the stack:
   Decompose the feature into ordered, dependent PRs
   Each PR should be reviewable in < 30 minutes
   Each PR should pass CI independently

2. Create the branches:
   git checkout main
   git checkout -b feat/permissions-model        # PR 1
   # ... make changes, commit ...
   git checkout -b feat/permissions-service       # PR 2 (branches from PR 1)
   # ... make changes, commit ...
   git checkout -b feat/permissions-api           # PR 3 (branches from PR 2)
   # ... make changes, commit ...

3. Create PRs with correct base branches:
   gh pr create --base main --head feat/permissions-model
   gh pr create --base feat/permissions-model --head feat/permissions-service
   gh pr create --base feat/permissions-service --head feat/permissions-api

4. Review and merge bottom-up:
   Merge PR 1 → main (re-target PR 2 to main)
   Merge PR 2 → main (re-target PR 3 to main)
   Merge PR 3 → main

RETARGETING AFTER MERGE:
  When PR 1 merges to main:
  gh pr edit <PR-2-number> --base main
  git checkout feat/permissions-service
  git rebase main
  git push --force-with-lease

STACKED PR DESCRIPTION:
  Add to each PR in the stack:
  "## Stack
   This is PR 2/4 in the permissions feature stack:
   1. [x] #101 — Data model (merged)
   2. [ ] #102 — Service layer (this PR)
   3. [ ] #103 — API endpoints (depends on this PR)
   4. [ ] #104 — UI (depends on #103)

   Review this PR independently. It builds on #101."

TOOLING:
  - ghstack (Meta): automated stacked diffs for GitHub
  - git-branchless: stacked branch management
  - Graphite: SaaS for stacked PRs with auto-rebase
  - spr: simple stacked PR tool
```

### Step 5: Review Request Strategies
Get the right reviewers and get reviewed quickly:

```
REVIEW REQUEST STRATEGIES:
┌─────────────────────────────────────────────────────────────┐
│ Strategy              │ Implementation                      │
├───────────────────────┼─────────────────────────────────────┤
│ CODEOWNERS            │ Auto-assign based on file paths     │
│ Round-robin           │ Rotate reviewers evenly             │
│ Domain expert         │ Tag the person who knows this area  │
│ Buddy system          │ Pair with a consistent review buddy │
│ Load-balanced         │ Assign to person with fewest open   │
│                       │ reviews                             │
└───────────────────────┴─────────────────────────────────────┘

CODEOWNERS FILE (.github/CODEOWNERS):
  # Default owner for everything
  * @team-lead

  # Frontend
  /src/components/  @frontend-team
  /src/pages/       @frontend-team
  *.css             @frontend-team
  *.tsx             @frontend-team

  # Backend
  /src/api/         @backend-team
  /src/services/    @backend-team
  /src/models/      @backend-team

  # Infrastructure
  /terraform/       @infra-team
  /docker/          @infra-team
  /.github/         @devops-lead

  # Security-sensitive
  /src/auth/        @security-team @team-lead
  /src/crypto/      @security-team

GETTING REVIEWED FASTER:
  1. Keep PRs small (< 200 lines)
  2. Write a clear description (reviewers skim first)
  3. Self-review before requesting (catch obvious issues)
  4. Add inline comments on tricky parts (guide the reviewer)
  5. Tag specific reviewers (don't rely on auto-assignment alone)
  6. Set urgency: 🔴 blocking / 🟡 normal / 🟢 low priority
  7. Review others' PRs promptly (reciprocity drives speed)
  8. Time your requests (morning in the reviewer's timezone)

REVIEW ETIQUETTE:
  As author:
  - Respond to all comments (even if just "Done" or "Won't fix because...")
  - Don't dismiss reviews without explanation
  - Push fixes as new commits (easier to re-review), squash before merge

  As reviewer:
  - Review within 4 hours (business hours) — or decline and suggest someone else
  - Distinguish blockers from suggestions (prefix: "nit:", "blocking:", "question:")
  - Approve with comments if only nits remain
  - Don't request changes on style preferences the linter allows
```

### Step 6: Auto-Labeling and Auto-Assignment
Automate PR metadata for faster triage:

```
AUTO-LABELING RULES:
┌─────────────────────────────────────────────────────────────┐
│ Condition                          │ Label                  │
├────────────────────────────────────┼────────────────────────┤
│ Files in /src/components/          │ frontend               │
│ Files in /src/api/                 │ backend                │
│ Files in /terraform/ or /docker/   │ infrastructure         │
│ Files match *.test.* or *.spec.*   │ tests                  │
│ Files match *.md                   │ documentation          │
│ Branch starts with fix/            │ bug-fix                │
│ Branch starts with feat/           │ feature                │
│ Branch starts with hotfix/         │ hotfix, urgent         │
│ Lines changed < 50                 │ size/S                 │
│ Lines changed 50-200               │ size/M                 │
│ Lines changed 200-500              │ size/L                 │
│ Lines changed > 500                │ size/XL, needs-split   │
│ PR description mentions "breaking" │ breaking-change        │
│ Files in /src/auth/ or /src/crypto/│ security-review        │
│ Files match *.sql or *migration*   │ database               │
└────────────────────────────────────┴────────────────────────┘

GITHUB ACTIONS LABELER (.github/labeler.yml):
  frontend:
    - changed-files:
      - any-glob-to-any-file: ['src/components/**', 'src/pages/**', '*.css', '*.tsx']

  backend:
    - changed-files:
      - any-glob-to-any-file: ['src/api/**', 'src/services/**', 'src/models/**']

  infrastructure:
    - changed-files:
      - any-glob-to-any-file: ['terraform/**', 'docker/**', '.github/**']

  tests:
    - changed-files:
      - any-glob-to-any-file: ['**/*.test.*', '**/*.spec.*']

  documentation:
    - changed-files:
      - any-glob-to-any-file: ['**/*.md', 'docs/**']

AUTO-ASSIGNMENT (.github/auto-assign.yml):
  addReviewers: true
  addAssignees: true
  reviewers:
    - reviewer1
    - reviewer2
    - reviewer3
  numberOfReviewers: 2
  assignees:
    - author         # Auto-assign PR author
  skipKeywords:
    - wip
    - draft

SIZE LABELS (GitHub Action):
  name: PR Size Label
  on: pull_request
  jobs:
    size:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/labeler@v5
        - name: Label PR size
          uses: codelytv/pr-size-labeler@v1
          with:
            xs_max_size: 10
            s_max_size: 50
            m_max_size: 200
            l_max_size: 500
            fail_if_xl: true
            message_if_xl: |
              This PR is too large (>500 lines). Please split into
              smaller PRs for better review quality.
```

### Step 7: PR Metrics and Cycle Time Optimization
Measure and improve the PR review process:

```
PR METRICS DASHBOARD:
┌─────────────────────────────────────────────────────────────┐
│  PR CYCLE TIME METRICS (last 30 days)                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Time to First Review:                                      │
│    P50: 2.5 hours    P90: 8 hours    Target: < 4 hours     │
│    ████████████░░░░░░░░  62% within target                  │
│                                                             │
│  Time to Merge (after approval):                            │
│    P50: 30 min       P90: 4 hours    Target: < 2 hours     │
│    ██████████████████░░  89% within target                  │
│                                                             │
│  Total Cycle Time (open → merge):                           │
│    P50: 6 hours      P90: 24 hours   Target: < 24 hours    │
│    ████████████████░░░░  78% within target                  │
│                                                             │
│  Review Rounds:                                             │
│    Average: 1.4       Target: ≤ 2                           │
│    1 round: 65%  2 rounds: 28%  3+ rounds: 7%              │
│                                                             │
│  PR Size Distribution:                                      │
│    XS: ██████  15%                                          │
│    S:  ████████████████████  48%                             │
│    M:  ██████████████  28%                                   │
│    L:  ████  7%                                             │
│    XL: █  2%                                                │
│                                                             │
│  Approval Rate (first review):                              │
│    Approved: 42%  Changes requested: 51%  Rejected: 7%     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

KEY METRICS TO TRACK:
┌──────────────────────────┬───────────────┬──────────────────┐
│ Metric                   │ Target        │ Why It Matters   │
├──────────────────────────┼───────────────┼──────────────────┤
│ Time to first review     │ < 4 hours     │ Unblocks author  │
│ Review rounds            │ ≤ 2           │ Less back-and-   │
│                          │               │ forth            │
│ Total cycle time         │ < 24 hours    │ Ship faster      │
│ PR size (median)         │ < 200 lines   │ Better reviews   │
│ Approval rate (1st rev.) │ > 50%         │ PR quality       │
│ Stale PR rate            │ < 5%          │ No abandoned PRs │
│ Reviewer load balance    │ < 2x variance │ Fair workload    │
└──────────────────────────┴───────────────┴──────────────────┘

OPTIMIZATION STRATEGIES:
  High time to first review?
    → Set up CODEOWNERS auto-assignment
    → Establish team SLA (review within 4 hours)
    → Reduce WIP limit (review before starting new work)

  Too many review rounds?
    → Authors self-review before requesting
    → Add inline comments on complex changes
    → Use PR description template consistently
    → Run linter/tests before opening PR

  Large PRs (> 200 lines)?
    → Enable size labeler with warnings
    → Train team on stacked PR pattern
    → Set CI check that fails on XL PRs
    → Celebrate small PRs in team retros

  Stale PRs (open > 3 days)?
    → Set up daily Slack notification for aging PRs
    → Auto-close PRs inactive for 14 days
    → Weekly PR triage in standup

  Unbalanced reviewer load?
    → Round-robin assignment
    → Track reviews per person per week
    → Redistribute CODEOWNERS if skewed
```

### Step 8: PR Report

```
┌────────────────────────────────────────────────────────────┐
│  PULL REQUEST PLAN                                         │
├────────────────────────────────────────────────────────────┤
│  Feature: <name>                                           │
│  Total change: <N> lines across <N> files                  │
│                                                            │
│  Strategy: <single PR | stacked PRs>                       │
│  Number of PRs: <N>                                        │
│                                                            │
│  PR 1: <title>                                             │
│    Size: <S/M>   Base: main   Reviewers: <names>           │
│  PR 2: <title>                                             │
│    Size: <S/M>   Base: PR 1   Reviewers: <names>           │
│  PR 3: <title>                                             │
│    Size: <S/M>   Base: PR 2   Reviewers: <names>           │
│                                                            │
│  Labels: <auto-assigned labels>                            │
│  Template: <standard | custom>                             │
│  Estimated review time: <N> minutes per PR                 │
│  Estimated total cycle: <N> hours                          │
│                                                            │
│  Ready for: /godmode:ship                                  │
└────────────────────────────────────────────────────────────┘
```

### Step 9: Commit and Transition
1. Create PR(s) with description template applied
2. Commit: `"chore: PR workflow — <strategy> with <N> PRs for <feature>"`
3. After PR creation: "PR(s) created. Use `/godmode:ship` to finalize or `/godmode:review` for pre-merge review."

## Explicit Loop Protocol

For stacked PR workflows involving iterative splitting and creation:

```
STACKED PR LOOP:
current_iteration = 0
remaining_diff = total_diff
pr_stack = []

WHILE remaining_diff > 200 lines AND current_iteration < 8:
  current_iteration += 1

  1. IDENTIFY next slice:
     - Find the next logical, independently-reviewable chunk
     - Prefer: schema first, then service, then API, then UI
     - Each slice MUST pass CI independently

  2. CREATE branch and PR:
     - Branch from previous stack branch (or main for first)
     - Create PR with base = previous branch
     - Apply description template with stack position

  3. VALIDATE:
     - PR size < 200 lines? YES -> continue
     - CI passes on this branch? YES -> continue
     - Independently reviewable? YES -> continue
     - IF any NO: re-split this slice further

  4. UPDATE remaining_diff:
     - remaining_diff -= lines_in_this_pr
     - pr_stack.append({ pr_number, branch, size, base })

  OUTPUT: pr_stack with merge order and retarget instructions
```

## Multi-Agent Dispatch

For large feature PRs that need splitting across domains:

```
PARALLEL AGENTS (when feature spans multiple domains):
Agent 1 — Backend PR (worktree: pr-backend)
  - Extract backend changes (models, services, migrations)
  - Create PR with tests passing independently

Agent 2 — API PR (worktree: pr-api)
  - Extract API layer changes (controllers, serializers, routes)
  - Base on Agent 1's branch

Agent 3 — Frontend PR (worktree: pr-frontend)
  - Extract frontend changes (components, pages, styles)
  - Base on Agent 2's branch

Agent 4 — Config/Infra PR (worktree: pr-infra)
  - Extract infrastructure changes (docker, CI, env vars)
  - Independent base (main), merge in parallel

Each agent writes its own PR description with stack context.
MERGE ORDER: Agent 4 (independent) + Agent 1 -> Agent 2 -> Agent 3
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. NEVER create a PR with more than 500 lines without splitting it.
2. NEVER leave a PR description empty — every PR gets the template.
3. NEVER request review before self-reviewing the diff.
4. NEVER force-push during active review — push new commits instead.
5. NEVER assign more than 3 reviewers — 1-2 is ideal.
6. NEVER stack more than 5 PRs deep — use parallel branches instead.
7. ALWAYS include the issue/ticket link in the PR description.
8. ALWAYS mark draft PRs as draft — do not request review on WIP.
9. ALWAYS squash commits before merging (not during review).
10. NEVER merge a PR with failing CI checks.
```

## Key Behaviors

1. **Small PRs are non-negotiable.** A 500-line PR will get rubber-stamped. Four 125-line PRs will get thoughtful reviews. Always split large changes.
2. **Description is for the reviewer.** Write the PR description as if the reviewer knows nothing about what you have been working on. Give them the context to review efficiently.
3. **Self-review first.** Read your own diff before clicking "Request review." You will catch 30% of issues yourself and save your reviewer time.
4. **Stacked PRs for large features.** If a feature takes more than 200 lines, plan the stack before writing code. Each PR should be independently reviewable and mergeable.
5. **Automate the boring parts.** Labels, assignment, size checks, and template enforcement should be automated. Humans focus on code quality, not metadata.
6. **Measure and improve.** Track cycle time, review rounds, and PR size. What gets measured gets improved.
7. **Review others promptly.** PR review is a team sport. If you want fast reviews, review others' PRs fast. The golden rule applies.

## Example Usage

### Creating a well-structured PR
```
User: /godmode:pr I've finished the rate limiter feature and need to
       create a PR.

PR: Assessing PR context...

PR ASSESSMENT:
Branch: feat/rate-limiter
Base: main
Commits: 14
Files changed: 8
Lines: +342 / -12
Size: L (354 lines — consider splitting)

Recommendation: Split into 2 stacked PRs

PR 1: "feat(middleware): add rate limiter core with Redis store"
  Files: rate-limiter.ts, redis-store.ts, config.ts, tests
  Size: M (180 lines)
  Base: main

PR 2: "feat(api): apply rate limiting to public endpoints"
  Files: routes.ts, middleware-chain.ts, integration tests
  Size: M (174 lines)
  Base: PR 1

Creating PR 1...

## Summary
Add rate limiting middleware with configurable limits per endpoint
and a Redis-backed sliding window counter.

## Problem
Public API endpoints have no rate limiting, allowing abuse and
potential DoS. Closes #456.

## Solution
Sliding window rate limiter using Redis sorted sets for O(1)
check-and-increment. Configurable per-route limits with sensible
defaults (100 req/min for authenticated, 20 req/min for anonymous).

## Changes
- Add `RateLimiter` middleware with sliding window algorithm
- Add `RedisStore` for distributed rate limit state
- Add configuration schema for per-route limits
- Add unit tests for limiter logic and Redis store

## Testing
- 12 unit tests covering normal flow, limit exceeded, Redis failure
- Manual testing with `ab` (Apache Bench) at 200 req/sec

PR #123 created: https://github.com/org/repo/pull/123
Reviewers assigned: @backend-team (via CODEOWNERS)
Labels: backend, feature, size/M
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full PR assessment, sizing, and creation |
| `--template` | Generate PR description template only |
| `--split` | Analyze and recommend PR splitting strategy |
| `--stack` | Create stacked PRs for current feature |
| `--metrics` | Show PR cycle time metrics for the team |
| `--labels` | Set up auto-labeling configuration |
| `--codeowners` | Generate CODEOWNERS file from git history |
| `--size-check` | Check if current diff is too large |
| `--self-review` | Run self-review checklist before requesting |
| `--retarget` | Retarget stacked PRs after a merge |

## Output Format

After each PR skill invocation, emit a structured report:

```
PR REPORT:
┌──────────────────────────────────────────────────────┐
│  PR action           │  <create | split | stack | review> │
│  Branch              │  <branch name>                 │
│  Diff size           │  +<N> / -<N> lines             │
│  Files changed       │  <N>                           │
│  PR size category    │  <XS | S | M | L | XL>         │
│  Split recommended   │  YES (<N> PRs) / NO            │
│  Self-review         │  DONE / SKIPPED                │
│  CI status           │  PASSING / FAILING             │
│  Reviewers assigned  │  <N> (<names>)                 │
│  Verdict             │  READY FOR REVIEW | NEEDS WORK │
└──────────────────────────────────────────────────────┘
```

## TSV Logging

Log every PR operation for tracking:

```
timestamp	skill	action	branch	diff_lines	files_changed	size_category	status
2026-03-20T14:00:00Z	pr	create	feature/auth	+180/-30	8	M	ready
2026-03-20T14:10:00Z	pr	split	feature/big-refactor	+800/-200	24	XL	split_into_3
```

## Success Criteria

The PR skill is complete when ALL of the following are true:
1. PR is within size limits (< 400 lines changed, or split if larger)
2. PR description includes summary, related issues, and test plan
3. Self-review checklist is completed before requesting review
4. CI passes (tests, lint, type check)
5. Appropriate reviewers are assigned (1-2 specific people, not the whole team)
6. PR targets the correct base branch
7. Stacked PRs (if any) have correct dependency chain and are < 5 deep

## Error Recovery

```
IF PR is too large (> 400 lines):
  1. Analyze the diff by concern: refactoring, feature, tests, config
  2. Split into separate PRs by concern (each independently mergeable)
  3. Use stacked PRs if changes have dependencies
  4. If splitting is not possible, add a detailed self-review walkthrough in the description

IF CI fails on the PR:
  1. Check the specific failing step (test, lint, type check, build)
  2. Fix locally, push the fix as a new commit (not amend during review)
  3. If the failure is flaky/unrelated, document it and re-run CI
  4. Never merge with failing CI

IF reviewers are not responding within 24 hours:
  1. Send a direct message with a brief summary of the PR
  2. If still no response, re-assign to a different available reviewer
  3. Consider the PR may be too large — offer to walk through it
  4. Set a team SLA for PR review turnaround (recommendation: < 24 hours)

IF stacked PR chain breaks after a merge:
  1. Retarget child PRs to the new base (the merged PR's target branch)
  2. Rebase each child PR onto the new base
  3. Resolve any conflicts introduced by the merge
  4. Update PR descriptions to reflect the new dependency chain
```

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Detect branch strategy: check for main/master, develop, release/* branches
2. Detect PR template: ls .github/PULL_REQUEST_TEMPLATE.md
3. Detect CI status: check for .github/workflows/, .circleci/, .gitlab-ci.yml
4. Detect labeling: ls .github/labeler.yml, .github/labels.yml
5. Detect CODEOWNERS: ls .github/CODEOWNERS
6. Detect merge strategy: check repo settings or recent merge commits for squash/rebase/merge
7. Auto-configure: use detected conventions for PR creation
```

## Anti-Patterns

- **Do NOT open PRs with 500+ lines.** They will not get a thorough review. Split them. No exceptions.
- **Do NOT leave the PR description empty.** "See ticket" is not a description. The PR should stand on its own.
- **Do NOT request review before self-reviewing.** Read your own diff first. Catch the obvious issues yourself.
- **Do NOT keep PRs open for more than 3 days.** If a PR is aging, it means it's too large, the reviewer is overloaded, or the feature is not well-scoped.
- **Do NOT stack more than 5 PRs deep.** Beyond 5, the rebase chain becomes fragile. Break into independent parallel PRs if possible.
- **Do NOT force push during review.** Push new commits so reviewers can see incremental changes. Squash before merge.
- **Do NOT request review from the entire team.** Tag 1-2 specific reviewers. Diffusion of responsibility means nobody reviews.


## PR Quality Loop

Iterative protocol for ensuring every PR meets quality standards before requesting review:

```
PR QUALITY LOOP:
current_iteration = 0
max_iterations = 5
quality_gates = [size_check, self_review, description_check, checklist_verify, merge_criteria]

WHILE current_iteration < max_iterations:
  gate = quality_gates[current_iteration]
  current_iteration += 1

  IF gate == "size_check":
    1. MEASURE:
       lines_changed = git diff --stat {base}..HEAD | tail -1 | parse
       files_changed = git diff --name-only {base}..HEAD | wc -l
    2. ENFORCE SIZE LIMITS:
       XS:  1-10 lines     → auto-merge candidate, skip most gates
       S:   11-50 lines    → ideal, full review in <15 min
       M:   51-200 lines   → acceptable, review in <30 min
       L:   201-400 lines  → WARNING: consider splitting
       XL:  401+ lines     → BLOCKED: must split before review
    3. IF XL:
       - Analyze diff by concern: refactor, feature, tests, config, docs
       - Propose split plan: N smaller PRs with dependency chain
       - HALT until split is complete or user overrides with justification
    4. IF L:
       - WARN but allow with justification
       - Require extra reviewer (2 instead of 1)
       - Add "needs-split" label as reminder for future

  IF gate == "self_review":
    1. GENERATE self-review checklist from diff:
       FOR each file in changed_files:
         - [ ] Read the full diff for {file} — no skimming
         - [ ] Check for debug statements (console.log, print, debugger)
         - [ ] Check for commented-out code (should be deleted, not commented)
         - [ ] Check for hardcoded values (magic numbers, URLs, credentials)
         - [ ] Check for TODO/FIXME/HACK that should be resolved before merge
         - [ ] Check for adequate error handling (no bare catch, no swallowed errors)
    2. RUN automated self-review:
       grep -rn 'console\.log\|debugger\|print(' $(git diff --name-only {base}..HEAD) 2>/dev/null
       grep -rn 'TODO\|FIXME\|HACK\|XXX' $(git diff --name-only {base}..HEAD) 2>/dev/null
       grep -rn '\/\/.*[A-Z].*=.*["\x27]' $(git diff --name-only {base}..HEAD) 2>/dev/null
    3. REPORT findings:
       - Debug statements: <N> (target: 0)
       - Commented-out code blocks: <N> (target: 0)
       - Unresolved TODOs: <N> (target: 0 or explicitly documented)
       - Hardcoded values: <N> (target: 0)
    4. IF findings > 0: FIX before proceeding

  IF gate == "description_check":
    1. VALIDATE PR description against template:
       REQUIRED SECTIONS:
       [ ] Summary (1-3 sentences, not empty)
       [ ] Problem/context (links to issue or explains why)
       [ ] Solution (what approach was taken and key tradeoffs)
       [ ] Changes (bulleted list of specific changes)
       [ ] Testing (how it was tested, new tests added)
       [ ] Checklist (standard items checked off)
    2. SCORE description quality:
       - All sections present: +1 per section (max 6)
       - Issue/ticket linked: +1
       - Screenshots for UI changes: +1
       - Reviewer guidance notes: +1
       - Total: <N>/9
    3. IF score < 6: REWRITE missing sections before proceeding

  IF gate == "checklist_verify":
    1. RUN verification commands:
       [ ] Tests pass: {test_cmd} → exit code 0
       [ ] Lint clean: {lint_cmd} → exit code 0
       [ ] Type check: {typecheck_cmd} → exit code 0 (if applicable)
       [ ] Build succeeds: {build_cmd} → exit code 0
       [ ] No secrets in diff: grep for API_KEY, SECRET, PASSWORD, TOKEN
       [ ] No conflict markers: grep for <<<<<<<, =======, >>>>>>>
       [ ] Branch is up to date with base: git fetch origin {base} && git merge-base --is-ancestor origin/{base} HEAD
    2. ALL must pass. ANY failure blocks PR creation.
    3. IF tests/lint/build fail: delegate to /godmode:fix, then re-run this gate

  IF gate == "merge_criteria":
    1. DEFINE merge readiness criteria:
       REQUIRED (all must be true):
       [ ] CI passes (all status checks green)
       [ ] At least 1 approval from a qualified reviewer
       [ ] No unresolved review comments (all threads resolved)
       [ ] Branch is up to date with base (no merge conflicts)
       [ ] PR size is within limits (< 400 lines or justified)
       RECOMMENDED:
       [ ] No "changes requested" reviews outstanding
       [ ] Author has responded to all reviewer comments
       [ ] Documentation updated if public API changed
       [ ] CHANGELOG updated if user-facing change
    2. SCORE: required_met / total_required
    3. IF all required met: READY TO MERGE
       IF any required missing: BLOCKED — list blockers

  REPORT: "Gate {current_iteration}/{max_iterations}: {gate} — {PASS | FAIL | BLOCKED}"

FINAL PR QUALITY SCORE:
┌──────────────────────────────────────────────────────────┐
│  PR QUALITY ASSESSMENT                                    │
├──────────────────────┬────────┬───────────────────────────┤
│  Gate                │ Status │ Details                    │
├──────────────────────┼────────┼───────────────────────────┤
│  Size check          │ PASS   │ M (142 lines)             │
│  Self-review         │ PASS   │ 0 issues found            │
│  Description         │ PASS   │ 8/9 quality score         │
│  Checklist verify    │ PASS   │ 7/7 checks passed         │
│  Merge criteria      │ READY  │ Awaiting 1 approval       │
├──────────────────────┼────────┼───────────────────────────┤
│  Overall             │ READY  │ Ready for review           │
└──────────────────────┴────────┴───────────────────────────┘
```

### Review Checklist Protocol

Standardized checklist for reviewers to ensure thorough, consistent reviews:

```
REVIEWER CHECKLIST (apply to every PR review):

CORRECTNESS:
[ ] Does the code do what the PR description says?
[ ] Are edge cases handled (null, empty, boundary values)?
[ ] Are error paths handled correctly (not swallowed, proper error types)?
[ ] Is the logic correct for all input combinations?
[ ] Are there race conditions or concurrency issues?

DESIGN:
[ ] Is this the right level of abstraction?
[ ] Does this follow existing patterns in the codebase?
[ ] Are there unnecessary dependencies introduced?
[ ] Is the code in the right location (correct module/layer)?
[ ] Could this be simpler without losing functionality?

TESTING:
[ ] Are new tests added for new functionality?
[ ] Do tests cover both happy path and error cases?
[ ] Are test names descriptive (document expected behavior)?
[ ] Are tests independent (no shared mutable state)?
[ ] Is test coverage adequate for the risk level of the change?

SECURITY:
[ ] No secrets, credentials, or PII in the diff?
[ ] Input validation present for user-supplied data?
[ ] SQL injection, XSS, CSRF protections maintained?
[ ] Authentication/authorization checks not bypassed?
[ ] No new attack surface exposed without documentation?

PERFORMANCE:
[ ] No N+1 queries introduced?
[ ] No unbounded loops or data fetches?
[ ] Pagination for list endpoints?
[ ] Appropriate caching if accessing expensive resources?
[ ] No unnecessary re-renders (frontend)?

REVIEW COMMENT CONVENTIONS:
  Prefix every comment with its weight:
  "blocking: <comment>"     — Must fix before merge
  "suggestion: <comment>"   — Improvement, not required
  "nit: <comment>"          — Style/preference, not required
  "question: <comment>"     — Seeking understanding, not blocking
  "praise: <comment>"       — Acknowledging good work (important for morale)

REVIEW RESPONSE TIMES:
  Target: first review within 4 business hours
  SLA: all PRs reviewed within 24 business hours
  If you cannot review within SLA: decline and suggest alternate reviewer
```

### Merge Criteria Enforcement

```
MERGE CRITERIA (enforced before every merge):

HARD REQUIREMENTS (automated — cannot be bypassed):
  1. CI green: all status checks pass
  2. No merge conflicts: branch is rebased on latest base
  3. Approvals met: >= {required_approvals} (default: 1)
  4. No dismissed reviews: all "changes requested" resolved

SOFT REQUIREMENTS (team-enforced — documented exceptions allowed):
  1. All review threads resolved
  2. PR description complete (all template sections filled)
  3. Documentation updated for API/behavior changes
  4. CHANGELOG entry for user-facing changes
  5. Migration tested (if database changes present)
  6. Feature flag configured (if partial feature)

MERGE METHOD:
  Default: squash merge (clean history, one commit per PR)
  Exception: merge commit for release branches or when commit history matters
  Never: rebase merge on shared branches without team agreement

POST-MERGE CLEANUP:
  1. Delete source branch (automated via GitHub settings)
  2. Retarget dependent PRs (if stacked)
  3. Verify CI on main after merge (catch integration issues)
  4. Close related issues (via "Closes #NNN" in description)
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run PR tasks sequentially: backend PR, then API PR, then frontend PR, then config/infra PR.
- Use branch isolation per task: `git checkout -b godmode-pr-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
