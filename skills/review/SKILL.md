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
- Same file:line from multiple agents → merge into single finding.
- Take highest severity. Take first agent's fix. Log all reporters.
- Different severity for same finding → escalate to highest.
### 4. Auto-Fix NITs
NITs: auto-fix if safe. Logic/API/security NITs → leave for human.
- SAFE to auto-fix: imports, formatting, whitespace, comment typos.
- UNSAFE (defer to human): logic changes, API changes, security patches, test modifications.
- Each auto-fix is a separate commit with message: `review-autofix: {description}`.
### 5. Verdict
Score: 0-10 (median of all agents' scores, not average).
- 10: 0 MUST-FIX, 0 SHOULD-FIX → APPROVE.
- 8-9: 0 MUST-FIX, 1-3 SHOULD-FIX → APPROVE.
- 5-7: 1+ MUST-FIX → APPROVE with conditions (REQUEST CHANGES).
- 0-4: 2+ MUST-FIX or critical security → REJECT.
### 6. Re-Review Protocol
- If score < 8: author must respond to every MUST-FIX and SHOULD-FIX.
- Re-review only modified parts (diff of fixes).
- Max re-reviews: 3 iterations. After 3: SHIP with known issues documented.

## Output Format
Print: `Review: {verdict} ({score}/10). {must_fix} MUST-FIX, {should_fix} SHOULD-FIX, {nit} NIT. Auto-fixed: {auto_fixed_count}.`

## TSV Logging
Append `.godmode/review-log.tsv`: timestamp, scope, category, severity, file_line, description, status(open/auto-fixed/deferred).

## Keep/Discard Discipline
```
After EACH review finding:
  KEEP if: finding has file:line + severity + concrete fix
  DISCARD if: finding is vague, lacks code evidence, or duplicates existing finding
  On discard: remove finding from report. Log reason in review-log.tsv.
  Never keep a finding without a concrete suggested fix.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: all 4 agents completed and findings merged
  - budget_exhausted: max 3 re-review iterations reached
  - diminishing_returns: re-review found 0 new issues
  - stuck: >5 vague findings discarded without actionable replacements
```

## Rules
1. Every finding: file:line + suggested fix (code). No vague feedback like 'improve' or 'could be better'.
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
