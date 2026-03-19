---
name: review
description: 4-agent code review. Correctness, security, performance, style. Auto-fixes NITs.
---

## Activate When
- `/godmode:review`, "review this", "check my code"

## Workflow
### 1. Gather Diff
Run `git diff main...HEAD` (full diff, not just stat) and `git log main..HEAD --oneline`. Read every changed file.
### 2. Multi-Agent Review (4 agents, parallel)
- **Correctness** — logic errors, off-by-ones, null/undefined, unhandled promise rejections, missing returns
- **Security** — injection (SQL/XSS/cmd), auth bypass, secrets in code, insecure defaults
- **Performance** — N+1 queries, O(n²) loops, unnecessary re-renders, unbounded growth, memory leaks
- **Style** — naming conventions, dead/unreachable code, inconsistent patterns, missing types/returns
Each agent outputs: `SEVERITY | FILE:LINE | DESCRIPTION | SUGGESTED FIX (code snippet)`
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
1. Every finding: file:line + suggested fix. No vague feedback.
2. MUST-FIX blocks merge. NIT = auto-fixed. Review against spec, not preference.
3. Auto-fix only safe changes. Never auto-fix logic or public APIs.
