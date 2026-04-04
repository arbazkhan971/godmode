---
name: review
description: 4-agent code review. Correctness, security,
  performance, style. Auto-fixes NITs.
---

## Activate When
- `/godmode:review`, "review this", "check my code"

## Workflow

### 1. Gather Diff
```bash
git diff main...HEAD
```
Read every changed file. >500 lines -> split into
per-directory reviews.

### 2. Multi-Agent Review (4 agents, parallel)
- **Correctness**: logic errors, off-by-ones, null,
  unhandled promise rejections, missing returns
- **Security**: injection (SQL/XSS/cmd), auth bypass,
  secrets in code, insecure defaults
- **Performance**: N+1 queries, O(n^2) in hot paths,
  missing pagination, memory leaks
- **Style**: naming, dead code, inconsistent patterns,
  missing types/returns

Each agent outputs:
`SEVERITY | FILE:LINE | DESCRIPTION | SUGGESTED FIX`
Severities: MUST-FIX, SHOULD-FIX, NIT.
IF no findings: state `{category}: No issues found.`

### 3. Merge & Deduplicate
Combine findings. Same file:line = merge, keep highest
severity, first agent's fix. Sort: MUST-FIX first.

### 4. Auto-Fix NITs
SAFE: imports, formatting, whitespace, comment typos.
UNSAFE (human): logic, API, security, test changes.
Each auto-fix = separate commit:
`"review-autofix: {description}"`.

### 5. Verdict
Score: 0-10 (median of all agents).
- 10: 0 MUST, 0 SHOULD -> APPROVE
- 8-9: 0 MUST, 1-3 SHOULD -> APPROVE
- 5-7: 1+ MUST -> REQUEST CHANGES
- 0-4: 2+ MUST or critical security -> REJECT

IF score < 8: author responds to every MUST + SHOULD.
Re-review only modified parts. Max 3 iterations.

## Quality Targets
- Target: <30min average review turnaround
- Target: 0 critical issues missed per review
- Max PR size: <400 lines changed for effective review
- Target: 0 MUST-FIX findings remaining at merge time
- Target: >8/10 verdict score before approval
- Target: <3 re-review iterations to reach approval
- Target: <500 line diffs per review (split if larger)
- False positive rate: <10% of all findings
- Auto-fix success rate: >95% of NIT fixes pass tests

## Hard Rules
1. Every finding: file:line + suggested fix (code).
2. MUST-FIX blocks merge. NIT = auto-fix if safe.
3. Review against spec + tests, not personal style.
4. Score = median of 4 agents.
5. Deduplicate same file:line across agents.

## TSV Logging
Append `.godmode/review-log.tsv`:
```
timestamp	scope	category	severity	file_line	description	status
```

## Keep/Discard
```
KEEP if: finding has file:line + severity + fix.
DISCARD if: vague, lacks evidence, or duplicate.
```

## Failure Classification
On finding DISCARD: classify and append to `.godmode/review-failures.tsv`.
False positive classes: `stale_context`, `framework_idiom`, `test_only_code`, `intentional_pattern`, `duplicate_finding`.

## Cross-Model Review (Optional)

For higher-confidence reviews, dispatch agents with different models:
- Agent 1 (primary model): Correctness + Performance review
- Agent 2 (secondary model): Security + Style review

Findings caught by only one model are flagged as "cross-model finding" —
these are the blind spots that self-play misses.

Enable with: `--cross-model` flag or when reviewing security-critical code.

## Stop Conditions
```
STOP when FIRST of:
  - All 4 agents completed and findings merged
  - Max 3 re-review iterations
  - Re-review found 0 new issues
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Diff too large (>500) | Split per-directory reviews |
| Vague findings | Discard, re-run with explicit instruction |
| Auto-fix breaks tests | Revert, reclassify as SHOULD-FIX |
| Conflicting findings | Escalate to highest severity |
