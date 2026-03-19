---
name: review
description: 4-agent code review. Correctness, security, performance, style. Auto-fixes NITs.
---

# Review — Code Review

## Activate When
- `/godmode:review`, "review this", "check my code"

## Workflow
### 1. Gather Diff
Run `git diff main...HEAD --stat` and `git log main..HEAD --oneline`.
### 2. Multi-Agent Review (4 agents, parallel)
- **Correctness** — logic errors, edge cases, off-by-ones, null handling
- **Security** — injection, auth bypass, data exposure, OWASP
- **Performance** — N+1 queries, unnecessary re-renders, memory leaks
- **Style** — naming, dead code, inconsistent patterns, missing types
Each agent outputs: `SEVERITY | FILE:LINE | DESCRIPTION | SUGGESTED FIX`
Severities: MUST-FIX, SHOULD-FIX, NIT.
### 3. Merge & Deduplicate
Combine all findings. Remove duplicates. Sort by severity.
### 4. Auto-Fix NITs
For each NIT: if safe (unused imports, whitespace, reorder), apply and commit `"review: fix {description}"`. Else leave for human.
### 5. Verdict
- 0 MUST-FIX → APPROVE (score 8-10)
- Any MUST-FIX → REQUEST CHANGES (score 5-7)
- Critical security → REJECT (score < 5)

## Rules
1. Every finding has file:line and suggested fix. No vague feedback.
2. MUST-FIX blocks merge. SHOULD-FIX blocks next round. NIT = auto-fixed or ignored.
3. Review against spec/plan, not personal preference.
4. Auto-fix only safe changes. Never auto-fix logic or public APIs.
5. 4 agents, 4 perspectives. Don't skip any.
