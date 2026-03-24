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
  ...
```
### Step 2: PR Size Optimization
If the PR is too large, split it into smaller, focused PRs:

```
PR SPLITTING STRATEGIES:
| Strategy | When to Use |
|--|--|
| By layer | Data model → business logic → API → |
|  | UI (each layer is one PR) |
| By feature slice | Each user-facing feature is one PR |
| By refactor+feat | Refactor first (PR 1), feature (PR 2) |
| By test+impl | Tests first (PR 1), implementation |
  ...
```
### Step 3: PR Description Template
Generate a high-quality PR description:

```
PR DESCRIPTION TEMPLATE:
  ## Summary
  <1-3 sentences: what this PR does and why>
  ## Problem
  <What issue or need does this address?>
  <Link to issue/ticket: Closes #NNN>
  ## Solution
  <How does this PR solve the problem?>
  ...
```
### Step 4: Stacked PRs for Large Features
Decompose large features into dependent, sequential PRs:

```
STACKED PR PATTERN:
  main ──────────────────────────────────────────
  ├── PR 1: Data model (base: main)
│    │     │                                                  │
|  | ├── PR 2: Service layer (base: PR 1 branch) |
│    │     │     │                                            │
|  |  | ├── PR 3: API endpoints (base: PR 2 branch) |
│    │     │     │     │                                      │
  ...
```
### Step 5: Review Request Strategies
Get the right reviewers and get reviewed quickly:

```
REVIEW REQUEST STRATEGIES:
| Strategy | Implementation |
|--|--|
| CODEOWNERS | Auto-assign based on file paths |
| Round-robin | Rotate reviewers evenly |
| Domain expert | Tag the person who knows this area |
| Buddy system | Pair with a consistent review buddy |
| Load-balanced | Assign to person with fewest open |
  ...
```
### Step 6: Auto-Labeling and Auto-Assignment
Automate PR metadata for faster triage:

```
AUTO-LABELING RULES:
| Condition | Label |
|--|--|
| Files in /src/components/ | frontend |
| Files in /src/api/ | backend |
| Files in /terraform/ or /docker/ | infrastructure |
| Files match *.test.* or *.spec.* | tests |
| Files match *.md | documentation |
  ...
```
PR METRICS DASHBOARD:
  PR CYCLE TIME METRICS (last 30 days)
  Time to First Review:
  P50: 2.5 hours    P90: 8 hours    Target: < 4 hours
  ████████████░░░░░░░░  62% within target
  Time to Merge (after approval):
  P50: 30 min       P90: 4 hours    Target: < 2 hours
  ██████████████████░░  89% within target
  Total Cycle Time (open → merge):
  P50: 6 hours      P90: 24 hours   Target: < 24 hours
  ████████████████░░░░  78% within target
  Review Rounds:
  Average: 1.4       Target: ≤ 2
  1 round: 65%  2 rounds: 28%  3+ rounds: 7%
  PR Size Distribution:
  XS: ██████  15%
  S:  ████████████████████  48%
  M:  ██████████████  28%
  L:  ████  7%
  XL: █  2%
  Approval Rate (first review):
  Approved: 42%  Changes requested: 51%  Rejected: 7%

KEY METRICS TO TRACK:
| Metric | Target | Why It Matters |
|--|--|--|
| Time to first review | < 4 hours | Unblocks author |
| Review rounds | ≤ 2 | Less back-and- |
|  |  | forth |
| Total cycle time | < 24 hours | Ship faster |
| PR size (median) | < 200 lines | Better reviews |
| Approval rate (1st rev.) | > 50% | PR quality |
| Stale PR rate | < 5% | No abandoned PRs |
| Reviewer load balance | < 2x variance | Fair workload |

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
  PULL REQUEST PLAN
  Feature: <name>
  Total change: <N> lines across <N> files
  Strategy: <single PR | stacked PRs>
  Number of PRs: <N>
  PR 1: <title>
  Size: <S/M>   Base: main   Reviewers: <names>
  PR 2: <title>
  Size: <S/M>   Base: PR 1   Reviewers: <names>
  PR 3: <title>
  Size: <S/M>   Base: PR 2   Reviewers: <names>
  Labels: <auto-assigned labels>
  Template: <standard | custom>
  Estimated review time: <N> minutes per PR
  Estimated total cycle: <N> hours
  Ready for: /godmode:ship
```

### Step 9: Commit and Transition
1. Create PR(s) with description template applied
2. Commit: `"chore: PR workflow — <strategy> with <N> PRs for <feature>"`
3. After PR creation: "PR(s) created. Use `/godmode:ship` to finalize or `/godmode:review` for pre-merge review."

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
## Autonomous Operation
- Loop until target or budget. Never pause.
- Measure before/after. Guard: test_cmd && lint_cmd.
- On failure: git reset --hard HEAD~1.
- Never ask to continue. Loop autonomously.

## Key Behaviors

1. **Small PRs are non-negotiable.** A 500-line PR will get rubber-stamped. Four 125-line PRs will get thoughtful reviews. Split large changes.
2. **Description is for the reviewer.** Write the PR description as if the reviewer knows nothing about your recent work. Give them the context to review efficiently.
3. **Self-review first.** Read your own diff before clicking "Request review." You will catch 30% of issues yourself and save your reviewer time.
4. **Stacked PRs for large features.** If a feature takes more than 200 lines, plan the stack before writing code. Make each PR independently reviewable and mergeable.
## Summary
  ...
```

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full PR assessment, sizing, and creation |
| `--template` | Generate PR description template only |
| `--split` | Analyze and recommend PR splitting strategy |

## Output Format

After each PR skill invocation, emit a structured report:
  ...
```
PR REPORT:
| PR action | <create | split | stack | review> |
|--|--|--|--|--|
| Branch | <branch name> |
| Diff size | +<N> / -<N> lines |
| Files changed | <N> |
| PR size category | <XS | S | M | L | XL> |
| Split recommended | YES (<N> PRs) / NO |
  ...
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
5. Correct reviewers are assigned (1-2 specific people, not the whole team)
6. PR targets the correct base branch
7. Stacked PRs (if any) have correct dependency chain and are < 5 deep

## Keep/Discard Discipline
```
After EACH PR quality gate:
  1. MEASURE: Run CI checks — do tests, lint, and type checks pass?
  2. VERIFY: Is the PR within size limits and description complete?
  3. DECIDE:
     - KEEP if: CI passes AND size < 400 lines AND description has all required sections
     - DISCARD if: CI fails OR PR is XL without justification OR description is empty
  4. Fix discarded items before requesting review.

  ...
```

## Stop Conditions
```
STOP when ANY of these are true:
  - All PRs are within size limits (< 400 lines or split)
  - PR description template applied with all required sections
  - CI passes and reviewers assigned
  - User explicitly requests stop

DO NOT STOP only because:
  - One PR is borderline on size (split it or justify)
  ...
```
## Error Recovery
| Failure | Action |
|--|--|
| PR too large (>500 lines) | Split by concern: refactoring in one PR, feature in another. Use stacked PRs if changes are sequential. |
| CI fails on PR | Read failure output. Fix locally, push. Do not merge with failing CI. Check if failure is flaky (re-run once). |
| Merge conflicts | Rebase onto target branch. Resolve conflicts locally. Never resolve conflicts in the GitHub UI for complex changes. |
| Review feedback contradicts existing patterns | Check codebase conventions. If reviewer is correct, fix. If existing pattern is intentional, explain with code reference. |
