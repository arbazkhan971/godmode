---
name: review
description: |
  Code review skill. Activates when code needs review before merging or after a build phase completes. Performs 2-stage review: automated checks then agent-based review against spec and plan. Dispatches code-reviewer agent. Triggers on: /godmode:review, after build phase boundaries, before shipping, or when user says "review this code."
---

# Review — Code Review with Technical Rigor

## When to Activate
- User invokes `/godmode:review`
- Build skill triggers review at phase boundaries
- Before shipping (`/godmode:ship` invokes this as a pre-flight check)
- User says "review this," "check this code," "is this ready to merge?"
- A pull request needs review

## Workflow

### Step 1: Determine Review Scope
Identify what code needs reviewing:

```bash
# If reviewing branch changes
git diff main...HEAD --stat

# If reviewing recent changes
git diff HEAD~<N>...HEAD --stat

# If reviewing specific files
git diff <files>
```

```
REVIEW SCOPE:
Branch: <branch name>
Base: <base branch>
Commits: <N> commits
Files changed: <N>
Lines added: <N>
Lines removed: <N>
Spec: <path to spec, if exists>
Plan: <path to plan, if exists>
```

### Step 2: Stage 1 — Automated Checks
Run all automated quality gates:

```
AUTOMATED CHECKS:
[ ] Tests pass: <test command>
[ ] Lint clean: <lint command>
[ ] Type check: <type check command>
[ ] Coverage ≥ target: <coverage command>
[ ] No secrets in diff: <check for API keys, passwords, tokens>
[ ] No large binaries: <check for files > 1MB>
[ ] No console.log/print debugging left behind
[ ] Dependencies lock file updated (if deps changed)
```

Report:
```
STAGE 1 RESULTS:
✓ Tests: 47/47 passing
✓ Lint: clean
✓ Types: no errors
✓ Coverage: 84% (target: 80%)
✓ No secrets detected
✓ No large files
✗ 2 console.log statements found — must remove
✓ Lock file up to date

STAGE 1: FAIL — 1 issue must be fixed
```

If Stage 1 fails, fix the issues before proceeding to Stage 2.

### Step 3: Stage 2 — Agent Review
Dispatch the code-reviewer agent with full context. The reviewer evaluates across 7 dimensions:

#### Dimension 1: Spec Compliance
Does the implementation match what was designed?
```
- Every requirement in the spec is implemented
- No features were added that aren't in the spec (scope creep)
- Edge cases identified in the spec are handled
- Success criteria from the spec can be verified
```

#### Dimension 2: Logic Correctness
Is the code actually correct?
```
- Algorithm logic is sound
- Loop invariants and termination conditions are correct
- State transitions are valid
- Mathematical operations handle overflow/underflow
- Boolean logic is correct (no De Morgan mistakes)
- Off-by-one errors checked
```

#### Dimension 3: Error Handling
What happens when things go wrong?
```
- All external calls have error handling
- Errors are logged with sufficient context
- Errors propagate correctly (not swallowed silently)
- User-facing errors are informative but not leaky
- Partial failures are handled (rollback or compensate)
```

#### Dimension 4: Security
Is the code safe?
```
- Input validation on all external inputs
- No SQL injection, XSS, or command injection vectors
- Authentication/authorization checks present
- Secrets not hardcoded
- HTTPS/TLS for external communication
- No sensitive data in logs
```

#### Dimension 5: Performance
Will this perform well?
```
- No N+1 query patterns
- Appropriate indexing for database queries
- No unnecessary memory allocations in hot paths
- Pagination for list endpoints
- Caching where appropriate
- No blocking operations in async contexts
```

#### Dimension 6: Maintainability
Can someone else understand and modify this?
```
- Clear naming (variables, functions, files)
- Appropriate abstraction level (not too abstract, not too concrete)
- Comments explain WHY, not WHAT
- No magic numbers or strings
- DRY without over-abstraction
- Follows existing project patterns
```

#### Dimension 7: Test Quality
Are the tests good?
```
- Tests cover the spec's success criteria
- Tests cover edge cases from the scenario matrix
- Test names describe behavior
- No flaky or intermittent tests
- Appropriate use of mocks (not over-mocked)
- Tests are readable and maintainable
```

### Step 4: Review Report

```
┌──────────────────────────────────────────────────────┐
│  CODE REVIEW — <branch name>                         │
├──────────────────────────────────────────────────────┤
│  Verdict: <APPROVE | REQUEST CHANGES | REJECT>       │
├──────────────────────────────────────────────────────┤
│  Scores:                                             │
│  Spec Compliance:  ████████░░  8/10                  │
│  Logic Correctness: █████████░  9/10                 │
│  Error Handling:    ██████░░░░  6/10                  │
│  Security:          █████████░  9/10                 │
│  Performance:       ███████░░░  7/10                  │
│  Maintainability:   ████████░░  8/10                 │
│  Test Quality:      ██████████  10/10                │
│                                                      │
│  Overall:           ████████░░  8.1/10               │
├──────────────────────────────────────────────────────┤
│  MUST FIX (blocks merge):                            │
│  1. <file:line> — <issue description>                │
│  2. <file:line> — <issue description>                │
│                                                      │
│  SHOULD FIX (recommended):                           │
│  3. <file:line> — <issue description>                │
│  4. <file:line> — <issue description>                │
│                                                      │
│  NICE TO HAVE (optional):                            │
│  5. <file:line> — <suggestion>                       │
└──────────────────────────────────────────────────────┘
```

### Step 5: Address Findings
For each MUST FIX item:
1. Show the problematic code
2. Explain why it's a problem
3. Show the suggested fix
4. Apply the fix (with user confirmation)
5. Re-run affected tests

After all MUST FIX items are addressed, re-run Stage 1 automated checks.

### Step 6: Final Verdict
```
REVIEW COMPLETE:
- MUST FIX: <N> found, <N> resolved
- SHOULD FIX: <N> found, <N> resolved
- NICE TO HAVE: <N> noted

Final verdict: APPROVED ✓
Ready for /godmode:ship or /godmode:optimize
```

Commit: `"review: <branch> — approved (<score>/10)"`

## Key Behaviors

1. **Every finding has a file and line.** "Error handling could be better" is not a review finding. "`src/services/user.ts:47` — `createUser` doesn't catch the duplicate key error from PostgreSQL" is a finding.
2. **MUST FIX means MUST FIX.** Don't approve code with unresolved MUST FIX items. Ever.
3. **Check against the spec.** The review's primary job is confirming the code matches the spec. If there's no spec, note it.
4. **Don't nitpick.** Style preferences that the linter doesn't catch are NICE TO HAVE at best. Focus on correctness and security.
5. **Be constructive.** Every problem identified should include a suggested fix.
6. **Score honestly.** A 10/10 score should be rare. Most good code is 7-8/10.

## Example Usage

### Reviewing a feature branch
```
User: /godmode:review

Review: Analyzing branch feat/rate-limiter against main...

REVIEW SCOPE:
Branch: feat/rate-limiter
Base: main
Commits: 14 commits
Files changed: 8
Lines added: 342
Lines removed: 12
Spec: docs/specs/rate-limiter.md
Plan: docs/plans/rate-limiter-plan.md

Running Stage 1 — Automated Checks...
✓ All 51 tests passing
✓ Lint clean
✓ Types clean
✓ Coverage 87%
✗ Found `console.log` in src/middleware/rate-limiter.ts:23

Stage 1: FAIL — Remove debug logging

[After fix]

Running Stage 2 — Agent Review...
[Detailed 7-dimension review]
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full 2-stage review |
| `--quick` | Stage 1 only (automated checks) |
| `--security` | Focus review on security dimension |
| `--diff <base>` | Review against a specific base branch or commit |
| `--files <paths>` | Review specific files only |
| `--strict` | Treat SHOULD FIX as MUST FIX |

## Anti-Patterns

- **Do NOT approve with unresolved MUST FIX items.** That defeats the purpose of code review.
- **Do NOT review without context.** Always read the spec and plan before reviewing. A review without context is just style checking.
- **Do NOT be vague.** "This could be better" is not helpful. Be specific: what, where, why, and how to fix it.
- **Do NOT block on style preferences.** If the linter doesn't flag it, it's probably fine. Save your energy for correctness and security.
- **Do NOT review your own code in isolation.** The review should compare against the spec and plan, not just check if the code "looks good."
- **Do NOT skip the automated stage.** Manual review catches design issues; automated review catches syntax issues. You need both.
