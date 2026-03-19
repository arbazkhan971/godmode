---
name: review
description: |
  Code review skill. Activates when code needs review before merging or after a build phase completes. Performs 2-stage review: automated checks then multi-agent review (correctness, security, performance, style) against spec and plan. Each finding has structured severity (MUST-FIX, SHOULD-FIX, NIT), file:line, and suggested fix. Auto-fixes NITs. Produces APPROVE/REQUEST_CHANGES/REJECT verdict. Triggers on: /godmode:review, after build phase boundaries, before shipping, or when user says "review this code."
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

### Step 3: Stage 2 — Multi-Agent Review

Dispatch FOUR parallel reviewer agents, each with a specialized focus. This replaces a single monolithic review with targeted expert perspectives.

```
DISPATCH PARALLEL REVIEW AGENTS:

Agent 1: CORRECTNESS REVIEW
  Focus: Does the code do what the spec says?
  Checks: Spec compliance, logic correctness, algorithm soundness,
          edge case handling, state transitions, off-by-one errors
  Output: List of findings with severity + file:line

Agent 2: SECURITY REVIEW
  Focus: Any vulnerabilities?
  Checks: Runs secure skill checklist (STRIDE + OWASP Top 10 lite),
          input validation, auth/authz, injection vectors, secrets
  Output: List of findings with severity + file:line

Agent 3: PERFORMANCE REVIEW
  Focus: Any obvious perf issues?
  Checks: N+1 queries, missing DB indexes, unbounded loops,
          unnecessary allocations, blocking in async, missing caching,
          large payload sizes, missing pagination
  Output: List of findings with severity + file:line

Agent 4: STYLE REVIEW
  Focus: Follows project conventions?
  Checks: Naming conventions, file/folder structure, design patterns,
          code organization, comment quality, DRY violations,
          appropriate abstraction level, consistency with existing code
  Output: List of findings with severity + file:line

MERGE RESULTS:
- Deduplicate findings across agents (same file:line = merge)
- Resolve severity conflicts (take the higher severity)
- Combine into single structured review output
```

Each agent evaluates the code across its focus area, producing findings in the structured format defined below. The merged results feed into the 7-dimension scoring.

### Structured Review Output Format

Every finding from every agent MUST follow this format:

```
FINDING: <title>
Severity: MUST-FIX | SHOULD-FIX | NIT
Agent: Correctness | Security | Performance | Style
Location: <file>:<line>
Description: <what the issue is and why it matters>
Suggested fix:
  <concrete code change or action to take>
```

Severity definitions:
- **MUST-FIX**: Blocks merge. Bugs, security vulnerabilities, data loss risks, spec violations.
- **SHOULD-FIX**: Strongly recommended. Performance issues, missing error handling, test gaps.
- **NIT**: Minor. Style inconsistencies, naming, formatting, minor readability improvements.

The reviewer evaluates across 7 dimensions:

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

### Step 5: Auto-Fix NITs

Automatically apply all NIT-level findings without user confirmation. These are low-risk formatting, naming, and style fixes that don't change behavior.

```
AUTO-FIX NIT LOOP:

For each finding with severity NIT:
  1. Read the code at file:line
  2. Apply the suggested fix (formatting, naming, import ordering, etc.)
  3. Run linter to confirm fix is valid
  4. If linter passes: stage the change
  5. If linter fails: revert and skip (log as SKIPPED)

After all NITs processed:
  git commit: "review: auto-fix <N> NITs (formatting, naming, style)"

SAFE NIT FIXES (auto-apply):
  - Variable/function renaming to match project conventions
  - Import reordering/grouping
  - Removing unused imports or variables
  - Adding missing semicolons or trailing commas (per project config)
  - Fixing whitespace/indentation inconsistencies
  - Adding missing JSDoc/docstring stubs
  - Replacing magic numbers with named constants

UNSAFE CHANGES (never auto-apply, even if NIT):
  - Changing logic or control flow
  - Modifying function signatures
  - Altering error messages (might break tests)
  - Renaming exported/public APIs (might break consumers)
```

### Step 6: Address MUST-FIX and SHOULD-FIX Findings

For each MUST-FIX item:
1. Show the problematic code with full context
2. Explain why it's a problem (reference spec, security rule, or perf issue)
3. Show the suggested fix with concrete code
4. Apply the fix (with user confirmation for MUST-FIX)
5. Re-run affected tests to confirm no regression

For each SHOULD-FIX item:
1. Present the finding with suggested fix
2. Apply if user approves, or note as "deferred" if declined
3. Log deferred items to `.godmode/review-deferred.tsv`

After all MUST-FIX items are addressed, re-run Stage 1 automated checks.

### Step 7: Review Verdict

The review produces one of three verdicts based on clear, deterministic criteria:

```
VERDICT CRITERIA:

APPROVE:
  - All MUST-FIX findings are resolved
  - Overall score >= 7/10
  - No dimension scores below 5/10
  - All automated checks pass (Stage 1)
  - NITs have been auto-fixed

REQUEST_CHANGES:
  - Any unresolved MUST-FIX findings remain, OR
  - Overall score is between 5-7/10, OR
  - Any dimension score is below 5/10
  - Code needs specific improvements before it can be approved

REJECT:
  - Overall score < 5/10, OR
  - Multiple MUST-FIX findings indicate fundamental design problems, OR
  - Code doesn't match the spec in significant ways, OR
  - Security review found Critical vulnerabilities
  - Code needs significant rework — not just fixes
```

```
REVIEW COMPLETE:
┌──────────────────────────────────────────────────────┐
│  VERDICT: <APPROVE | REQUEST_CHANGES | REJECT>       │
├──────────────────────────────────────────────────────┤
│  Findings summary:                                   │
│  MUST-FIX:    <N> found, <N> resolved                │
│  SHOULD-FIX:  <N> found, <N> resolved, <N> deferred │
│  NIT:         <N> found, <N> auto-fixed              │
│                                                      │
│  Multi-agent breakdown:                              │
│  Correctness: <N> findings (<N> MUST-FIX)            │
│  Security:    <N> findings (<N> MUST-FIX)            │
│  Performance: <N> findings (<N> MUST-FIX)            │
│  Style:       <N> findings (<N> NITs auto-fixed)     │
├──────────────────────────────────────────────────────┤
│  If APPROVE:                                         │
│  Ready for /godmode:ship or /godmode:optimize        │
│                                                      │
│  If REQUEST_CHANGES:                                 │
│  Fix the <N> remaining MUST-FIX items, then re-run   │
│  /godmode:review                                     │
│                                                      │
│  If REJECT:                                          │
│  Fundamental issues detected. Revisit design with    │
│  /godmode:spec or /godmode:plan before continuing    │
└──────────────────────────────────────────────────────┘
```

Commit: `"review: <branch> — <verdict> (<score>/10, <N> findings)"`

## Key Behaviors

1. **Every finding has a file and line.** "Error handling could be better" is not a review finding. "`src/services/user.ts:47` — `createUser` doesn't catch the duplicate key error from PostgreSQL" is a finding.
2. **MUST-FIX means MUST-FIX.** Don't approve code with unresolved MUST-FIX items. Ever. The verdict system enforces this.
3. **Check against the spec.** The review's primary job is confirming the code matches the spec. If there's no spec, note it.
4. **NITs get auto-fixed, not debated.** Style preferences are auto-fixed silently. Human attention goes to correctness and security.
5. **Be constructive.** Every problem identified must include a concrete suggested fix with code.
6. **Score honestly.** A 10/10 score should be rare. Most good code is 7-8/10.
7. **Use all four agents.** Each agent catches different classes of issues. A correctness-only review misses perf and security problems.
8. **Structured output is mandatory.** Every finding follows the severity/location/description/fix format. No freeform prose findings.

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
| (none) | Full multi-agent review (automated + 4 parallel agents) |
| `--quick` | Stage 1 only (automated checks) |
| `--security` | Focus review on security dimension |
| `--perf` | Focus review on performance dimension |
| `--correctness` | Focus review on correctness dimension |
| `--diff <base>` | Review against a specific base branch or commit |
| `--files <paths>` | Review specific files only |
| `--strict` | Treat SHOULD-FIX as MUST-FIX |
| `--no-autofix` | Skip auto-fix of NITs (report only) |
| `--agent <N>` | Run only a specific review agent (1-4) |

## Anti-Patterns

- **Do NOT approve with unresolved MUST FIX items.** That defeats the purpose of code review.
- **Do NOT review without context.** Always read the spec and plan before reviewing. A review without context is just style checking.
- **Do NOT be vague.** "This could be better" is not helpful. Be specific: what, where, why, and how to fix it.
- **Do NOT block on style preferences.** If the linter doesn't flag it, it's probably fine. Save your energy for correctness and security.
- **Do NOT review your own code in isolation.** The review should compare against the spec and plan, not just check if the code "looks good."
- **Do NOT skip the automated stage.** Manual review catches design issues; automated review catches syntax issues. You need both.
