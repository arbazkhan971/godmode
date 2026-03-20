---
name: review
description: 4-agent code review. Correctness, security, performance, style. Auto-fixes NITs.
---

## Activate When
- `/godmode:review`, "review this", "check my code"

## Workflow
### 1. Gather Diff
Run `git diff main...HEAD` (full diff, never --stat). Read every changed file. >500 changed lines → split into per-directory reviews.
### 2. Multi-Agent Review (4 agents, parallel)
- **Correctness** — logic errors, off-by-ones, null/undefined, unhandled promise rejections, missing returns
- **Security** — injection (SQL/XSS/cmd), auth bypass, secrets in code, insecure defaults
- **Performance** — N+1 queries, O(n²) in hot paths, missing pagination, unbounded `.map()`/`.filter()` chains, memory leaks
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

## Output Format
Print: `Review: {verdict} ({score}/10). {must_fix} MUST-FIX, {should_fix} SHOULD-FIX, {nit} NIT. Auto-fixed: {auto_fixed_count}.`

## TSV Logging
Append `.godmode/review-log.tsv`: timestamp, scope, category, severity, file_line, description, status(open/auto-fixed/deferred).

## Rules
1. Every finding: file:line + suggested fix (code). No vague feedback like 'consider improving' or 'could be better'.
2. MUST-FIX blocks merge. NIT = auto-fixed if safe. Review against spec + tests, not personal style. No bikeshedding.
3. Auto-fix only safe changes. Never auto-fix logic, public APIs, or security-related code.

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks parallel agent dispatch:
- Run the 4 review passes **sequentially**: Correctness → Security → Performance → Style.
- Each pass: read the full diff, output findings in the same `SEVERITY | FILE:LINE | DESCRIPTION | SUGGESTED FIX` format.
- After all 4 passes: merge and deduplicate findings identically to the parallel version.
- Auto-fix NITs and produce verdict using the same scoring.
- ~4x slower but identical quality and output format.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
