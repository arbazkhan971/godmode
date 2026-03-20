---
name: review
description: 4-agent code review. Correctness, security, performance, style. Auto-fixes NITs.
---

## Activate When
- `/godmode:review`, "review this", "check my code"

## Workflow
### 1. Gather Diff
Run `git diff main...HEAD` (full, not --stat). Read every changed file in full. >500 lines → split by directory/module.
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
NITs: auto-fix if safe (imports, whitespace, formatting). Commit each: `review: fix {description}`. Logic/API/security NITs → leave for human.
### 5. Verdict
- 0 MUST-FIX + 0 SHOULD-FIX → APPROVE (9-10). 0 MUST-FIX + some SHOULD-FIX → APPROVE (8).
- Any MUST-FIX → REQUEST CHANGES (score 5-7)
- Critical security → REJECT (score < 5)

## Rules
1. Every finding: file:line + suggested fix (code). No vague feedback like 'consider improving' or 'could be better'.
2. MUST-FIX blocks merge. NIT = auto-fixed. Review against spec and tests, not personal style preference.
3. Auto-fix only safe changes. Never auto-fix logic, public APIs, or security-related code.
