---
name: review
description: |
  Code review. Multi-layer: correctness, security, performance, style. Structured findings with severity. Auto-fixes NITs.
---

# Review — Code Review

## Activate When
- `/godmode:review`, "review this", "check my code"
- After build phase completes
- Before shipping

## Workflow

### 1. Gather Diff
```bash
git diff main...HEAD --stat  # what changed
git log main..HEAD --oneline  # commit history
```

### 2. Multi-Agent Review (4 agents, parallel)

```
Agent 1 — Correctness: logic errors, edge cases, off-by-ones, null handling
Agent 2 — Security: injection, auth bypass, data exposure, OWASP issues
Agent 3 — Performance: N+1 queries, unnecessary re-renders, memory leaks
Agent 4 — Style: naming, dead code, inconsistent patterns, missing types
```

Each agent outputs findings in this format:
```
SEVERITY | FILE:LINE | DESCRIPTION | SUGGESTED FIX
MUST-FIX | src/api.ts:45 | SQL injection via string concat | Use parameterized query
SHOULD-FIX | src/auth.ts:12 | JWT not verified on /admin | Add auth middleware
NIT | src/utils.ts:3 | Unused import | Remove it
```

### 3. Merge & Deduplicate

Combine findings from all 4 agents. Remove duplicates. Sort by severity.

### 4. Auto-Fix NITs

```
FOR each NIT finding:
    IF safe (remove unused import, fix whitespace, reorder):
        Apply fix, commit: "review: fix {description}"
    ELSE: leave for human
```

### 5. Verdict

```
IF 0 MUST-FIX → APPROVE (score 8-10)
IF any MUST-FIX → REQUEST CHANGES (score 5-7)
IF critical security issue → REJECT (score < 5)
```

## Rules

1. **Every finding has file:line and suggested fix.** No vague feedback.
2. **MUST-FIX = blocks merge.** SHOULD-FIX = blocks next round. NIT = auto-fixed or ignored.
3. **Review against the spec/plan**, not personal preference.
4. **Auto-fix only safe changes.** Never auto-fix logic or public APIs.
5. **4 agents, 4 perspectives.** Don't skip security or performance.
