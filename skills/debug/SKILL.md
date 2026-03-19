---
name: debug
description: |
  Scientific debugging skill. Activates when user encounters bugs, unexpected behavior, or test failures that need investigation. Uses 7 systematic techniques to isolate root causes. Runs autonomously until the bug is found and a fix is proposed. Triggers on: /godmode:debug, "why is this happening?", "this doesn't work", stack traces, or error messages in conversation.
---

# Debug — Scientific Bug Investigation

## When to Activate
- User invokes `/godmode:debug`
- User shares a stack trace or error message
- User says "this doesn't work," "why is X happening?", "help me debug"
- Tests are failing with unclear reasons
- Godmode orchestrator detects failing tests during build

## Workflow

### Step 1: Reproduce the Bug
Before investigating, confirm the bug exists and is reproducible:

```
BUG REPORT:
Symptom: <what's going wrong — exact error or unexpected behavior>
Expected: <what should happen>
Actual: <what actually happens>
Reproducible: <YES/NO/INTERMITTENT>
Reproduce command: <exact command to trigger the bug>
Environment: <relevant env details>
```

If the bug is not reproducible: "I can't reproduce this. Can you provide the exact steps, environment, and inputs that trigger it?"

**Run the reproduce command and capture the output.** Do not rely on the user's description alone — observe it yourself.

### Step 2: Gather Initial Evidence
Before forming hypotheses, collect data:

```bash
# Recent changes that might be related
git log --oneline -20

# Check if tests were passing before
git stash && <test command> && git stash pop

# Related error logs
<log command or file>

# Current state of the failing code
<read relevant files>
```

### Step 2b: Bug Severity Classification

Classify each bug before investigation to prioritize correctly:

```
BUG SEVERITY CLASSIFICATION:

P0 — CRASH / OUTAGE
  App crashes, server down, data unavailable, complete feature broken.
  Response: Drop everything. Fix immediately. Wake people up if needed.
  Examples: unhandled exception in main loop, database connection leak, OOM

P1 — DATA LOSS / CORRUPTION
  Data is lost, corrupted, or silently wrong. Users may not notice immediately.
  Response: Fix within hours. May need rollback + data repair.
  Examples: write to wrong table, silent truncation, race condition on save

P2 — INCORRECT BEHAVIOR
  Feature works but produces wrong results. No data loss.
  Response: Fix within days. Workaround may exist.
  Examples: wrong calculation, incorrect filter, off-by-one, wrong status code

P3 — COSMETIC / MINOR
  Visual glitch, typo, minor UX issue. No functional impact.
  Response: Fix when convenient. Batch with other work.
  Examples: misaligned button, wrong color, grammatical error in message
```

```
BUG TRIAGE:
#  Bug                                         Severity  Investigate
1  "Server crashes on /api/users POST"          P0        ← NOW
2  "Order totals silently wrong with discount"  P1        ← NEXT
3  "Search returns 0 results for valid query"   P2        ← AFTER
4  "Footer links are blue instead of gray"      P3        ← LAST
```

### Step 2c: Multi-Agent Debugging

When multiple bugs exist in **independent modules**, dispatch parallel debug agents:

```
MULTI-AGENT DEBUG DISPATCH:

Condition: 3+ bugs in different modules with no shared code paths.

Agent 1: Debug test failures in auth module     (worktree: wt-debug-1)
Agent 2: Debug test failures in payment module  (worktree: wt-debug-2)
Agent 3: Debug type errors across codebase      (worktree: wt-debug-3)
```

Each agent:
1. Creates a worktree from the current branch
2. Investigates only bugs in its assigned scope
3. Produces root cause analysis for each bug
4. Reports findings back to the main thread

```
MULTI-AGENT DEBUG RESULTS:
Agent 1 (auth):    Found 2 root causes — req.user moved to req.auth.user (diff analysis)
Agent 2 (payment): Found 1 root cause — currency conversion uses wrong decimal scale (state inspection)
Agent 3 (types):   Found 3 root causes — User type renamed email→emailAddress (trace analysis)
Total: 6 root causes identified in parallel
```

After all agents report, consolidate findings and hand off to `/godmode:fix` with the full root cause map.

**When NOT to parallelize:**
- Bugs may share a root cause (investigate together to find the common source)
- Bugs are in the same file or call chain (one investigation covers both)
- Only 1-2 bugs exist (parallelism overhead not worth it)

### Step 3: Apply Investigation Techniques
Use one or more of the 7 techniques to isolate the root cause.

**Auto-selection: Based on the bug type, pick the best technique automatically:**

| Bug Signal | Best Technique | Why |
|------------|---------------|-----|
| Stack trace available | Trace Analysis (#3) | Stack trace tells you the exact code path |
| "It used to work" | Git Bisect (#1) or Diff Analysis (#6) | Find the breaking commit |
| Intermittent / flaky | State Inspection (#4) + Logging (#3) | Capture state at failure time |
| Performance regression | Profiling (external tool) | Measure, don't guess |
| Data corruption / wrong results | Input Validation Audit (#4) | Trace data through the pipeline |
| Race condition / deadlock | Concurrency Analysis (#4 + #5) | Inspect shared state and timing |
| Unknown / no clues | Binary Search (#1) | Systematic elimination |

Apply this auto-selection before investigating. If the first technique doesn't yield a root cause within 10 minutes, switch to the next best technique.

#### Technique 1: Binary Search (git bisect)
When: You know it worked before but don't know which commit broke it.
```bash
git bisect start
git bisect bad HEAD
git bisect good <last-known-good-commit>
# Test each commit git bisect selects
git bisect run <test command that exits 0 on pass, 1 on fail>
```
Result: The exact commit that introduced the bug.

#### Technique 2: Minimal Reproduction
When: The bug happens in a complex context and you need to simplify.
```
1. Start with the full failing scenario
2. Remove components one at a time
3. After each removal, check if the bug persists
4. Continue until you have the smallest code that reproduces the bug
5. The last thing you removed (that made the bug disappear) is the culprit
```

#### Technique 3: Trace Analysis
When: You can see the error but don't know the code path.
```
1. Read the stack trace from bottom to top
2. Identify the entry point (your code) vs library code
3. Add strategic logging at key decision points:
   - Function entry/exit with parameters
   - Branch conditions (which path was taken)
   - Loop iterations (values at each step)
4. Run again and read the trace
5. The unexpected value or branch reveals the bug
```

#### Technique 4: State Inspection
When: The code looks correct but produces wrong results.
```
1. Identify the expected state at each step
2. Add checkpoints to dump actual state
3. Compare expected vs actual at each checkpoint
4. The first divergence point is where the bug lives
```

#### Technique 5: Dependency Isolation
When: The bug might be in a dependency or integration point.
```
1. Mock/stub external dependencies one at a time
2. Replace each with a known-good value
3. If the bug disappears when you mock X, the bug is in the interaction with X
4. Deep dive into that specific integration
```

#### Technique 6: Diff Analysis
When: "It used to work" — the bug was introduced by a recent change.
```
1. git diff <working-commit>..HEAD
2. Review each changed file
3. For each change, ask: "Could this cause the symptom?"
4. Focus on: changed conditionals, modified data types, altered order of operations
```

#### Technique 7: Rubber Duck Analysis
When: The code is complex and nothing obvious stands out.
```
1. Read the code aloud, line by line
2. For each line, state: what it does, what state it expects, what state it produces
3. When you can't explain a line clearly, that's suspicious
4. When your explanation contradicts the code, that's the bug
```

### Step 4: Form and Test Hypotheses
After investigation, form a specific hypothesis:

```
HYPOTHESIS:
Root cause: <specific description of the bug>
Location: <exact file:line>
Evidence: <what investigation revealed>
Why it fails: <detailed explanation of the failure mechanism>
Confidence: <HIGH/MEDIUM/LOW>
```

Test the hypothesis:
```
1. Predict what the fix should be (before applying it)
2. Apply the fix temporarily
3. Run the reproduce command — does the bug disappear?
4. Run full test suite — does anything else break?
5. If both pass: hypothesis confirmed
6. If bug persists: hypothesis rejected, try next technique
```

### Step 5: Document the Root Cause
Once confirmed, document the **full root cause chain** — not just where the bug is, but how the symptom connects to the root cause:

```
ROOT CAUSE CHAIN:
Symptom:         "TypeError: Cannot read property 'id' of undefined" in user controller
Proximate cause: req.user is undefined at src/controllers/user.ts:23
                 ↑ because
Intermediate:    Auth middleware no longer sets req.user (sets req.auth.user instead)
                 ↑ because
Root cause:      Auth middleware refactor (commit a1b2c3d) moved user from req.user
                 to req.auth.user, but dependents were not updated
Fix location:    src/controllers/user.ts:23 — change req.user to req.auth.user
                 (plus 4 other files that read req.user)
```

Full root cause analysis:

```
ROOT CAUSE ANALYSIS:
Bug: <symptom>
Severity: <P0 | P1 | P2 | P3>
Root cause chain:
  Symptom → <what the user sees>
  Proximate cause → <the immediate technical failure>
  Root cause → <the underlying reason it fails>
  Fix location → <exact file:line where the change goes>
Location: <file:line>
Mechanism: <step-by-step explanation of how the bug manifests>
Introduced by: <commit SHA, if known>
Why it wasn't caught: <missing test, edge case, etc.>

Fix:
- <exact change needed>

Regression test:
- <test that will catch this if it comes back>
```

The root cause chain is critical — it ensures you fix the actual root cause, not just the symptom. A fix at the proximate cause level will mask the bug; a fix at the root cause level prevents it from recurring anywhere.

### Step 6: Transition to Fix
Do NOT apply the fix during debug. Debug FINDS the bug. Fix APPLIES the fix.

```
Root cause identified. Run `/godmode:fix` to apply the fix,
add a regression test, and verify the solution.
```

If the user wants to fix immediately, invoke `/godmode:fix` with the root cause analysis.

## Autonomous Loop Enforcement — HARD RULES

Debug is an iteration loop. It does NOT find one bug and stop. It finds ALL bugs.

### RULE 1: LOOP UNTIL NO MORE BUGS

```
current_iteration = 0
failing_count = run_test_suite()  # count of failing tests / bugs

WHILE failing_count > 0:
    current_iteration += 1

    # 1. Pick next failing test / bug symptom (highest severity first: P0 > P1 > P2 > P3)
    bug = pick_highest_severity(failures)

    # 2. Select best debugging technique (auto-select from table in Step 3)
    technique = auto_select_technique(bug.signal)

    # 3. Apply technique — isolate root cause with EVIDENCE
    root_cause = investigate(bug, technique)
    # root_cause MUST have: file:line, data evidence, reproduce command

    # 4. Log finding
    Append to .godmode/debug-findings.tsv:
    iteration  bug  file  line  root_cause  technique_used  fix_applied  commit

    # 5. Hand off to fix skill OR fix inline if trivial
    IF trivial (one-line fix):
        Apply fix, commit, verify.
    ELSE:
        Invoke /godmode:fix with root_cause.

    # 6. Re-count failures
    failing_count = run_test_suite()

    # 7. Status print every 3 bugs
    IF current_iteration % 3 == 0:
        Print: "Debug iteration {current_iteration}: {found} bugs found, {failing_count} remaining"

    # 8. REPEAT — go to top of WHILE
    # DO NOT ask "should I continue?"
    # DO NOT stop after finding one bug

Print summary. STOP.
```

### RULE 2: NEVER GUESS — PROVE

Every root cause must have:
- **File and line number** where the bug lives
- **Data evidence** (actual vs expected values, captured at runtime)
- **Reproduce command** that triggers it

"I think it's in auth.ts" → NOT ACCEPTABLE
"auth.ts:47 — req.user is undefined because JWT middleware skipped (evidence: added console.log at line 46, output shows middleware chain is [cors, rateLimit] missing auth)" → ACCEPTABLE

### RULE 3: Track Findings in TSV

```
# .godmode/debug-findings.tsv
iteration	bug	file	line	root_cause	technique_used	fix_applied	commit
1	"Cannot read 'id' of undefined"	auth.ts	47	"JWT middleware not in chain"	diff-analysis	"Added auth middleware"	abc123
2	"Expected 200, got 500"	api.ts	112	"Missing null check on user.org"	state-inspection	"Added optional chaining"	def456
```

### RULE 4: Status Print Every 3 Bugs Found

```
Debug iteration 6: 4 bugs found and fixed, 2 remaining failures
```

## Key Behaviors

1. **Reproduce first.** Never investigate a bug you haven't seen yourself. Reproduce it.
2. **One technique at a time.** Don't scatter-shot. Pick the most appropriate technique and follow it through.
3. **Evidence, not intuition.** "I think the bug is in the auth middleware" is a guess. "The stack trace shows null at auth.ts:47, and req.user is undefined because the JWT middleware didn't run" is evidence.
4. **Binary search is powerful.** When you know it used to work, `git bisect` is faster than reading code.
5. **Don't fix during debug.** The debug skill FINDS the problem. The fix skill FIXES it. Separation of concerns.
6. **Document everything.** The root cause analysis is a permanent record. Future developers will thank you.
7. **Minimal reproduction is gold.** A 5-line reproduction is worth more than a 500-line investigation.

## Example Usage

### Debugging a failing test
```
User: /godmode:debug The user creation test started failing after the auth refactor

Debug: Let me investigate.

BUG REPORT:
Symptom: test "creates user with valid email" fails with "TypeError: Cannot read property 'id' of undefined"
Reproduce: npm test -- --grep "creates user"

Reproducing... confirmed failure.

Applying Technique 6: Diff Analysis
Checking recent commits related to auth...

git diff HEAD~5..HEAD -- src/middleware/auth*
Found: auth middleware was refactored in commit a1b2c3d
Key change: req.user was moved to req.auth.user

Applying Technique 4: State Inspection
Added checkpoint at src/controllers/user.ts:23
Expected: req.user = { id: 1, email: "..." }
Actual: req.user = undefined
But: req.auth.user = { id: 1, email: "..." }

HYPOTHESIS:
Root cause: Auth refactor moved user from req.user to req.auth.user,
but user controller still reads from req.user
Location: src/controllers/user.ts:23
Evidence: req.auth.user has the expected value, req.user is undefined
Confidence: HIGH

Testing hypothesis... [applies temporary fix, runs test]
✓ Test passes with fix. Hypothesis confirmed.

ROOT CAUSE ANALYSIS:
Bug: User creation fails with "Cannot read property 'id' of undefined"
Root cause: Auth middleware refactor (commit a1b2c3d) moved user object
from req.user to req.auth.user. The user controller was not updated.
Location: src/controllers/user.ts:23
Mechanism: createUser() reads req.user.id, but since the auth refactor,
the user object lives at req.auth.user. req.user is now undefined.

Run /godmode:fix to apply the fix and add a regression test.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full investigation workflow |
| `--bisect` | Jump straight to git bisect |
| `--trace` | Add trace logging and re-run |
| `--error "<message>"` | Investigate a specific error message |
| `--test "<name>"` | Investigate a specific failing test |
| `--quick` | Skip full investigation, go straight to hypothesis based on error message |

## Anti-Patterns

- **Do NOT guess.** "Let me try changing this and see if it fixes it" is not debugging. It's random mutation.
- **Do NOT fix during debug.** Debug finds. Fix fixes. If you fix during debug, you skip the regression test and root cause documentation.
- **Do NOT ignore the stack trace.** The stack trace tells you exactly where the error occurs. Read it before doing anything else.
- **Do NOT blame the framework/library without evidence.** 99% of bugs are in your code. Check your code first.
- **Do NOT investigate multiple bugs at once.** One bug at a time. If you find a second bug during investigation, note it and continue with the first.
- **Do NOT skip reproduction.** "The user says it's broken" is not reproduction. Run it yourself.
