---
name: pr
description: Pull request excellence and review optimization.
---

## Activate When
- `/godmode:pr`, "create a PR", "stacked PRs"
- "PR template", "PR too large", "review request"
- Large diff detected during `/godmode:ship`

## Workflow

### 1. Assess PR Context
```bash
git diff --stat main...HEAD
git log --oneline main...HEAD
```
```
Branch: <name> | Base: <target> | Commits: <N>
Files: <N> | +<N>/-<N> lines
Size: XS(<50) | S(50-200) | M(200-400) | L(400-500) | XL(>500)
```
IF >500 lines: MUST split before review.
IF >200 lines: recommend splitting.

### 2. PR Size Optimization
Splitting strategies:
- By layer: data model -> logic -> API -> UI
- By feature slice: each user-facing feature = 1 PR
- By refactor+feat: refactor first, feature second
- By test+impl: tests first, implementation second

### 3. PR Description Template
```
## Summary
<1-3 sentences: what and why>
## Problem
<Issue link: Closes #NNN>
## Solution
<How this PR solves the problem>
## Test Plan
<How to verify: automated + manual steps>
## Screenshots (if UI)
```

### 4. Stacked PRs for Large Features
```
main
  PR 1: data model (base: main)
    PR 2: service layer (base: PR 1)
      PR 3: API endpoints (base: PR 2)
        PR 4: UI (base: PR 3)
```
IF >5 PRs deep: use parallel branches instead.
Max stack depth: 5.

### 5. Review Request Strategies
CODEOWNERS auto-assignment, round-robin rotation,
domain expert tagging, buddy system.
Assign 1-2 reviewers (never >3).

### 6. PR Metrics
```
Time to first review: target < 4 hours
Review rounds: target <= 2
Total cycle time: target < 24 hours
PR size (median): target < 200 lines
Approval rate (1st): target > 50%
Stale PR rate: target < 5%
```
IF high first-review time: set up CODEOWNERS + SLA.
IF many rounds: self-review before requesting.

### 7. Commit
Create PR(s) with description template applied.
`"chore: PR workflow -- <strategy> for <feature>"`

## Hard Rules
1. NEVER create PR >500 lines without splitting.
2. NEVER leave PR description empty.
3. NEVER request review before self-reviewing diff.
4. NEVER force-push during active review.
5. NEVER assign >3 reviewers (1-2 ideal).
6. NEVER stack >5 PRs deep.
7. ALWAYS include issue/ticket link.
8. ALWAYS mark draft PRs as draft.
9. ALWAYS squash before merge (not during review).
10. NEVER merge with failing CI.

## TSV Logging
Append `.godmode/pr-results.tsv`:
```
timestamp	action	branch	diff_lines	files	size	status
```

## Keep/Discard
```
KEEP if: CI passes AND size < 400 lines
  AND description complete.
DISCARD if: CI fails OR XL without justification
  OR description empty.
```

## Stop Conditions
```
STOP when FIRST of:
  - All PRs within size limits
  - Description template applied
  - CI passes and reviewers assigned
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| PR too large (>500) | Split by concern, use stacked PRs |
| CI fails | Read output, fix locally, push |
| Merge conflicts | Rebase onto target, resolve locally |
| Contradicting feedback | Check codebase conventions first |
