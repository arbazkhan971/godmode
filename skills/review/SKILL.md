---
name: review
description: 4-agent code review. Correctness, security, performance, style. Auto-fixes NITs.
---

## Activate When
- `/godmode:review`, "review this", "check my code"

## Workflow
### 1. Gather Diff
Run `git diff main...HEAD` and `git log main..HEAD --oneline`. Read every changed file. If >500 lines changed, split review by module.
### 2. Multi-Agent Review (4 agents, parallel)
- **Correctness** — logic errors, off-by-ones, null/undefined, unhandled promise rejections, missing returns
- **Security** — injection (SQL/XSS/cmd), auth bypass, secrets in code, insecure defaults
- **Performance** — N+1 queries, O(n²) in loops, unnecessary re-renders/re-computations, unbounded collections, memory leaks
- **Style** — naming conventions, dead/unreachable code, inconsistent patterns, missing types/returns
Each agent outputs: `SEVERITY | FILE:LINE | DESCRIPTION | SUGGESTED FIX (code snippet)`
Severities: MUST-FIX, SHOULD-FIX, NIT.
If no findings in a category, agent must state: `{category}: No issues found.`
### 3. Merge & Deduplicate
Combine findings. Deduplicate (same file:line = merge). Sort: MUST-FIX → SHOULD-FIX → NIT.
### 4. Auto-Fix NITs
For each NIT: if safe (unused imports, whitespace, reorder, formatting), auto-fix and commit `"review: fix {description}"`. If touches logic → leave for human.
### 5. Verdict
- 0 MUST-FIX → APPROVE (score 8-10)
- Any MUST-FIX → REQUEST CHANGES (score 5-7)
- Critical security → REJECT (score < 5)

## Rules
1. Every finding: file:line + suggested fix (code). No vague feedback like 'consider improving' or 'could be better'.
2. MUST-FIX blocks merge. NIT = auto-fixed. Review against spec and tests, not personal style preference.
3. Auto-fix only safe changes. Never auto-fix logic, public APIs, or security-related code.
