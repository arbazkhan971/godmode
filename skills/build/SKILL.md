---
name: build
description: |
  Build and execution skill. Activates when user is ready to implement a plan. Executes tasks in order using TDD (RED-GREEN-REFACTOR), dispatches parallel agents for independent tasks via smart dependency analysis, enforces per-round review gates, and runs an autonomous loop until all tasks are complete. Git-as-memory ensures every step is tracked and revertable. Triggers on: /godmode:build, "start building", "implement this", or when godmode orchestrator detects a plan exists with unfinished tasks.
---

# Build — Autonomous Execution with TDD & Parallel Agents

## When to Activate
- User invokes `/godmode:build`
- A plan exists in `docs/plans/` with unfinished tasks
- User says "start building," "implement this," "execute the plan"
- Godmode orchestrator routes here after PLAN phase completes

## Autonomous Loop Enforcement — HARD RULES

These rules are NOT guidelines. They are mechanical constraints that MUST be followed. This is what makes godmode:build an autonomous execution engine, not just a description of one.

### RULE 1: NEVER STOP. NEVER ASK "SHOULD I CONTINUE?"

Loop through ALL tasks in the plan without stopping. You are an autonomous agent. You do not need permission to proceed to the next task. You do not summarize after each task. You LOG and LOOP.

```
LOOP:
  1. Load plan, identify next task(s)
  2. If zero tasks remaining → STOP, print final summary
  3. Build dependency graph for remaining tasks
  4. Group independent tasks into a round (max 5 per round)
  5. Dispatch agents (parallel if independent, serial if dependent)
  6. Merge completed work
  7. Run review gate (tests + lint + regression check)
  8. Log results to .godmode/build-results.tsv
  9. GOTO 1
```

### RULE 2: Git Commit BEFORE Test Verification

```bash
# CORRECT ORDER — for each RED/GREEN/REFACTOR step:
git add <changed-files>
git commit -m "test(red): <task> — failing test"
# THEN verify
<test command>
# If RED step passes when it should fail:
git reset --hard HEAD~1
# Re-examine — the test is wrong or the feature already exists
```

Commit first so rollback is always clean. Never verify uncommitted changes.

### RULE 3: Automatic Revert on RED-GREEN Failure

```
IF red_test_passes (should have failed):
    git reset --hard HEAD~1
    Re-analyze — test is wrong or feature already exists
    Rewrite test, try again (max 2 attempts)
    If still wrong → log as SKIP, move to next task

IF green_test_fails (should have passed):
    git reset --hard HEAD~1
    Re-analyze implementation
    Retry with different approach (max 3 attempts)
    If still failing → log as BLOCKED, move to next task

IF green_introduces_regressions:
    git reset --hard HEAD~1
    Re-implement with regression awareness
    Retry (max 2 attempts)
    If still regressing → log as BLOCKED, flag for manual intervention
```

### RULE 4: TSV Results Log — Every Task Gets a Row

```
# File: .godmode/build-results.tsv
task_num	round	timestamp	title	status	red_commit	green_commit	refactor_commit	tests_added	tests_total	agent_id
1	1	2024-01-15T10:23:00Z	"Rate limit config"	DONE	abc1234	def5678	ghi9012	3	45	main
2	1	2024-01-15T10:23:00Z	"Redis store"	DONE	jkl3456	mno7890	-	4	49	agent-1
3	1	2024-01-15T10:23:00Z	"In-memory store"	DONE	pqr1234	stu5678	vwx9012	3	52	agent-2
4	2	2024-01-15T10:35:00Z	"Middleware"	BLOCKED	yza1234	-	-	1	52	agent-1
```

### RULE 5: NEVER Ask for Permission Mid-Build

Wrong:
```
Task 3 complete. Should I continue to Task 4?
```

Right:
```
[Task 3 DONE] → [Task 4 starting...]
```

The only valid stop conditions are:
- All tasks complete
- User sends Ctrl+C / interrupt
- 3 consecutive tasks BLOCKED (systemic issue — print diagnostic and stop)

### RULE 6: Status Print Every 3 Tasks

Do NOT summarize after every task. Do NOT ask for feedback. Just loop.

Every 3 tasks, print ONE status block:

```
BUILD PROGRESS: ████████░░ 8/10 tasks
Round 1: ✓✓✓ (3/3 complete)
Round 2: ✓✓░ (2/3 in progress)
Round 3: ░░ (waiting)
Tests: 34/34 passing | Coverage: 82%
```

### RULE 7: Per-Round Review Gate Is Mandatory

After EVERY round of agents completes (not just at the end):
1. Run full test suite
2. Run linter
3. Run type checker
4. Compare test count — must be >= previous round
5. If regressions found → identify which merge caused them → revert THAT specific merge
6. Only proceed to next round after gate passes

### RULE 8: Guard Commands Are Read-Only

NEVER modify test files, lint configs, or guard commands to make a build task pass. Always adapt the implementation to pass the guards, not the other way around. Exception: tasks whose explicit purpose is to ADD new tests.

## Workflow

### Step 1: Load the Plan
Find and validate the implementation plan:
1. Check `docs/plans/` for the active plan
2. Verify pre-flight checklist is complete
3. Identify which tasks are already done (check git log for commits matching task descriptions)
4. Determine the next task(s) to execute

```
BUILD STATUS:
Plan: docs/plans/<feature>-plan.md
Branch: feat/<feature>
Tasks: <completed>/<total> complete
Next: Task <N> — <title>
```

If no plan exists: "No plan found. Run `/godmode:plan` first."

### Step 2: Pre-Build Verification
Before writing any code, confirm the codebase is healthy:

```bash
# Run existing tests
<test command>

# Check for lint errors
<lint command>

# Verify clean git state
git status
```

Record baseline metrics:
```
PRE-BUILD BASELINE:
Tests: <N> passing, 0 failing
Lint: clean
Coverage: <X>%
Git: clean working tree on branch feat/<feature>
```

If tests are failing before you start: "Existing tests are failing. Run `/godmode:fix` first, then come back to build."

### Step 3: Build the Dependency Graph

Before dispatching ANY agents, analyze the plan to build a dependency graph automatically. Do NOT rely on the plan explicitly stating dependencies — derive them yourself.

#### 3a: File-Touch Analysis
For each task in the plan, determine which files it will create or modify:

```
DEPENDENCY ANALYSIS:
Task 1: src/config/rate-limit.ts, tests/config/rate-limit.test.ts
Task 2: src/store/interface.ts, tests/store/interface.test.ts
Task 3: src/store/redis.ts, tests/store/redis.test.ts → IMPORTS store/interface.ts
Task 4: src/middleware/rate-limit.ts → IMPORTS config + store/interface
Task 5: src/utils/headers.ts, tests/utils/headers.test.ts
Task 6: src/store/memory.ts → IMPORTS store/interface.ts
```

#### 3b: Dependency Rules
Apply these rules to determine execution order:

```
RULE: If Task B imports/requires a file that Task A creates → B depends on A
RULE: If Task B modifies a file that Task A also modifies → serialize B after A
RULE: If Tasks X and Y touch completely different files → parallelize them
RULE: If a task creates an interface that others implement → that task goes first
RULE: If unsure about dependency → serialize (safe default)
```

#### 3c: Generate Execution Rounds
Group tasks into rounds based on the dependency graph:

```
EXECUTION PLAN:
Round 1 (parallel): Task 1, Task 2, Task 5 — no shared files
Round 2 (parallel): Task 3, Task 6 — both depend on Task 2 (interface), independent of each other
Round 3 (serial):   Task 4 — depends on Tasks 1, 2, 3
```

Constraints:
- **Maximum 5 agents per round** — more causes diminishing returns and merge complexity
- If a round has >5 independent tasks, split into sub-rounds of 5
- Tasks within a round MUST NOT touch the same files
- Every round must pass the review gate before the next round starts

### Step 4: Execute Tasks (TDD Loop)
For each task, follow the RED-GREEN-REFACTOR cycle:

#### RED: Write the Failing Test
```
1. Read the task's test specification from the plan
2. Write the test file (or add to existing test file)
3. git add + git commit: "test(red): <task title> — failing test"
4. Run the test — it MUST fail
5. If it passes → git reset --hard HEAD~1, re-examine (see RULE 3)
```

#### GREEN: Make It Pass
```
1. Read the task's code sketch from the plan
2. Implement the minimum code to make the test pass
3. git add + git commit: "feat: <task title> — implementation"
4. Run the test — it MUST pass now
5. Run ALL tests — nothing else should break
6. If fails → git reset --hard HEAD~1, re-implement (see RULE 3)
```

#### REFACTOR: Clean Up
```
1. Look for duplication, unclear naming, or unnecessary complexity
2. Refactor without changing behavior
3. git add + git commit: "refactor: <task title> — <what changed>"
4. Run ALL tests — everything must still pass
5. If tests break → git reset --hard HEAD~1, skip refactor
6. If no refactoring needed, skip this step
```

### Step 5: Smart Agent Dispatch (Default Mode)

**This is the default execution mode.** When the dependency graph reveals independent tasks, dispatch them as parallel agents automatically.

#### 5a: Agent Invocation
For each task in a parallel round, dispatch an agent with EXACT syntax:

```
Agent(
  prompt: "Read skills/<relevant-skill>/SKILL.md. Implement task: <full task description from plan>. Follow RED-GREEN-REFACTOR. Files in scope: <list of files this task touches>. Do NOT modify files outside scope. Commit messages: 'test(red): <title>', 'feat: <title>', 'refactor: <title>'. Run full test suite after GREEN step.",
  isolation: "worktree",
  mode: "bypassPermissions"
)
```

#### 5b: Dispatch Log
Print the dispatch for visibility:

```
ROUND 2 — Dispatching 3 agents in parallel:

Agent 1 [worktree: wt-task3] → Task 3: Redis store implementation
  Scope: src/store/redis.ts, tests/store/redis.test.ts
  Depends on: Task 2 (interface) ✓ complete
  Instruction: "Read skills/api/SKILL.md. Implement: Redis-backed rate limit store..."

Agent 2 [worktree: wt-task6] → Task 6: In-memory store implementation
  Scope: src/store/memory.ts, tests/store/memory.test.ts
  Depends on: Task 2 (interface) ✓ complete
  Instruction: "Read skills/api/SKILL.md. Implement: In-memory rate limit store..."

Agent 3 [worktree: wt-task5] → Task 5: Response header utility
  Scope: src/utils/headers.ts, tests/utils/headers.test.ts
  Depends on: nothing
  Instruction: "Read skills/api/SKILL.md. Implement: Rate limit response headers..."

Waiting for all agents to complete...
```

#### 5c: Agent Completion Handling
As each agent completes:
```
[Agent 1] ✓ Task 3 complete — 4 tests added, all passing (commit: abc1234)
[Agent 3] ✓ Task 5 complete — 2 tests added, all passing (commit: def5678)
[Agent 2] ✗ Task 6 FAILED — tests written but implementation has errors

→ Proceeding to merge successful agents. Task 6 enters failure recovery.
```

#### 5d: When to Fall Back to Single-Agent
- Only 1 task in the round
- User says "don't parallelize" or passes `--no-parallel`
- All remaining tasks touch overlapping files
- Previous round had merge conflicts from parallel work

### Step 6: Merge Protocol

After agents in a round complete, merge their work into the main feature branch ONE AT A TIME, in task order:

```bash
# For each completed agent worktree, in task-number order:
git merge <worktree-branch> --no-ff -m "merge: task <N> — <title>"

# Immediately verify after EACH merge:
<test command>

# If merge conflict:
git merge --abort
# Re-dispatch agent with conflict context (see Failure Recovery)

# If tests fail after merge (regression):
git revert -m 1 HEAD --no-edit
# Log the regression, re-dispatch agent with regression context
```

Merge rules:
- **One merge at a time.** Never batch-merge. Each merge gets its own verification.
- **Task-number order.** Lower-numbered tasks merge first (they're foundational).
- **Verify after each merge.** Run the full test suite. If it fails, that merge caused the regression.
- **Conflict = re-dispatch.** Never manually resolve conflicts. The agent that created the code should resolve its own conflicts.

### Step 7: Auto-Review Gate (Per-Round)

After every round completes and all merges succeed, run the full review gate:

```bash
# 1. Full test suite
<test command>

# 2. Lint check
<lint command>

# 3. Type check (if applicable)
<type check command>

# 4. Coverage check
<coverage command>
```

```
ROUND <N> REVIEW GATE:
Tests: 52/52 passing (was 42 before round) ✓
Lint: clean ✓
Types: no errors ✓
Coverage: 84% (was 80% before round) ✓
New tests this round: 10
Regressions: 0

GATE: PASSED — proceeding to Round <N+1>
```

If the gate fails:

```
ROUND <N> REVIEW GATE:
Tests: 50/52 passing ✗ — 2 REGRESSIONS
Lint: 1 error ✗
Types: clean ✓
Coverage: 79% (was 80%) ✗ — dropped below previous

GATE: FAILED — identifying regression source...

Regression analysis:
- test "user auth flow" failed after merge of Task 6 (commit ghi9012)
- lint error in src/store/memory.ts (from Task 6)
- coverage drop caused by untested branch in Task 6

Action: Reverting merge of Task 6...
git revert -m 1 ghi9012 --no-edit

Re-dispatching Task 6 agent with regression context...
```

### Step 8: Failure Recovery

When an agent fails, follow this protocol. NEVER block the entire build on one failed task.

#### 8a: Classify the Failure
```
FAILURE TYPES:
- RED_FAIL: Test couldn't be written (unclear spec) → flag for manual intervention
- GREEN_FAIL: Implementation doesn't pass tests → retry with more context
- MERGE_FAIL: Conflicts during merge → re-dispatch with conflict info
- REGRESSION_FAIL: Merge broke existing tests → revert merge, re-dispatch
- CRASH: Agent crashed/timed out → retry once, then skip
```

#### 8b: Retry Protocol
```
Attempt 1: Re-dispatch agent with original prompt
Attempt 2: Re-dispatch with:
  - Error output from previous attempt
  - Diff of what was tried
  - Explicit instructions on what went wrong
Attempt 3: Re-dispatch with:
  - Full context of all related files
  - Working implementations from sibling tasks for reference
  - Step-by-step implementation hints

After 3 failed attempts:
  - Save partial work to a branch: wt-task<N>-partial
  - Log as BLOCKED in build-results.tsv
  - Print: "Task <N> blocked after 3 attempts. Partial work on branch wt-task<N>-partial."
  - Continue with remaining tasks
```

#### 8c: Conflict Re-dispatch
When a merge conflict occurs:
```
Agent(
  prompt: "Your previous implementation of Task <N> has merge conflicts with the main branch. The conflicts are in: <conflicting files>. The main branch now contains: <description of merged changes since your worktree was created>. Re-implement Task <N> on top of the current main branch. Files in scope: <list>. Follow RED-GREEN-REFACTOR.",
  isolation: "worktree",
  mode: "bypassPermissions"
)
```

#### 8d: Regression Re-dispatch
When a merge introduces test failures:
```
Agent(
  prompt: "Your implementation of Task <N> caused regressions when merged. Failing tests: <test names and error messages>. Your changes: <diff summary>. The regression is likely caused by: <analysis>. Re-implement Task <N> ensuring these tests continue to pass: <list of regressed tests>. Follow RED-GREEN-REFACTOR.",
  isolation: "worktree",
  mode: "bypassPermissions"
)
```

### Step 9: Progress Tracking

Maintain a real-time build dashboard. Update it after every task completion and every round completion.

#### Live Dashboard (printed after each round):
```
┌─────────────────────────────────────────────────────────────┐
│  BUILD PROGRESS: ████████░░ 8/10 tasks                      │
├─────────────────────────────────────────────────────────────┤
│  Round 1: ✓✓✓ (3/3 complete)                               │
│  Round 2: ✓✓✗ (2/3 complete, 1 retrying)                   │
│  Round 3: ◉◉░ (2/2 in progress)                            │
│  Round 4: ░░ (waiting)                                      │
│                                                             │
│  Tests: 34/34 passing | Coverage: 82% | Lint: clean         │
│  Agents active: 2 | Failed: 1 (retrying) | Blocked: 0      │
│  Time elapsed: 12m 34s                                      │
└─────────────────────────────────────────────────────────────┘
```

#### Per-Task Status Indicators:
```
✓ = complete and merged
✗ = failed, being retried
◉ = in progress (agent running)
░ = waiting (not yet started)
⊘ = blocked (manual intervention needed)
```

### Step 10: Phase Transitions
When a build phase completes:

```
PHASE 1 COMPLETE: Foundation
✓ Task 1: Rate limit configuration
✓ Task 2: Rate limit store interface
✓ Task 3: Redis store implementation

Tests: 8/8 passing
Coverage: 72%

Proceeding to Phase 2: Core Logic
```

### Step 11: Build Complete
When all tasks are done:

```
┌─────────────────────────────────────────────────────────────┐
│  BUILD COMPLETE ✓                                           │
│  All <N> tasks implemented and tested.                      │
├─────────────────────────────────────────────────────────────┤
│  Results:                                                   │
│  - Tests: <total> passing, 0 failing                        │
│  - Coverage: <X>%                                           │
│  - New files: <count>                                       │
│  - Modified files: <count>                                  │
│  - Commits: <count>                                         │
│  - Rounds: <count>                                          │
│  - Agent dispatches: <count> (parallel: <N>, retries: <N>)  │
│  - Blocked tasks: <count> (see build-results.tsv)           │
│                                                             │
│  Build log: .godmode/build-results.tsv                      │
├─────────────────────────────────────────────────────────────┤
│  Next:                                                      │
│  → /godmode:optimize — Improve performance and quality      │
│  → /godmode:secure — Run a security audit                   │
│  → /godmode:ship — Ship if satisfied                        │
└─────────────────────────────────────────────────────────────┘
```

Final commit: `"build: <feature> — all <N> tasks complete"`

## Key Behaviors

1. **TDD is non-negotiable.** Every feature task starts with a failing test. No exceptions. No "I'll add tests later."
2. **Small commits.** One commit per RED, one per GREEN, one per REFACTOR. This creates a clean, reversible history.
3. **Run all tests frequently.** After every GREEN step, run the FULL test suite, not just the new test.
4. **Parallel when possible.** Don't serialize independent tasks. Use agents. But respect the dependency graph.
5. **Review at round boundaries.** Don't wait until the end to review. The per-round gate catches regressions before they compound.
6. **Never skip the failing test.** If the test passes immediately, investigate. Either the feature already exists, or the test doesn't test what you think it tests.
7. **Follow the plan.** Don't improvise. If the plan needs changes, update it first, then continue building.
8. **Never block on failure.** A failed task gets retried, then skipped. The build continues.
9. **Dependency graph is derived, not assumed.** Analyze file touches yourself. Don't trust the plan's dependency claims blindly.
10. **Merge one at a time.** Each merge gets its own verification. Batch-merging hides which merge broke things.

## Example Usage

### Starting a build
```
User: /godmode:build

Build: Loading plan from docs/plans/rate-limiter-plan.md...

BUILD STATUS:
Plan: rate-limiter-plan.md
Branch: feat/rate-limiter
Tasks: 0/10 complete
Next: Task 1 — Add rate limit configuration

Pre-build check:
✓ Tests: 42/42 passing
✓ Lint: clean
✓ Branch: feat/rate-limiter (clean)

Building dependency graph...

DEPENDENCY ANALYSIS:
Task 1: src/config/rate-limit.ts — no dependencies
Task 2: src/store/interface.ts — no dependencies
Task 3: src/store/redis.ts — depends on Task 2 (imports interface)
Task 4: src/middleware/rate-limit.ts — depends on Tasks 1, 2
Task 5: src/utils/headers.ts — no dependencies
Task 6: src/store/memory.ts — depends on Task 2 (imports interface)
Task 7: src/middleware/integration.ts — depends on Tasks 3, 4, 6
Task 8: tests/integration/rate-limit.e2e.ts — depends on Task 7
Task 9: src/admin/dashboard.ts — depends on Task 3
Task 10: docs/rate-limit.ts — depends on all tasks

EXECUTION PLAN:
Round 1 (3 agents): Tasks 1, 2, 5
Round 2 (2 agents): Tasks 3, 6
Round 3 (1 agent):  Task 4
Round 4 (3 agents): Tasks 7, 8, 9
Round 5 (1 agent):  Task 10

Starting Round 1...

ROUND 1 — Dispatching 3 agents in parallel:

Agent 1 [worktree: wt-task1] → Task 1: Rate limit configuration
Agent 2 [worktree: wt-task2] → Task 2: Store interface
Agent 3 [worktree: wt-task5] → Task 5: Response headers

Waiting for agents...

[Agent 2] ✓ Task 2 complete — 3 tests added
[Agent 3] ✓ Task 5 complete — 2 tests added
[Agent 1] ✓ Task 1 complete — 3 tests added

Merging Round 1...
git merge wt-task1 --no-ff → ✓ tests pass
git merge wt-task2 --no-ff → ✓ tests pass
git merge wt-task5 --no-ff → ✓ tests pass

ROUND 1 REVIEW GATE:
Tests: 50/50 passing ✓
Lint: clean ✓
Coverage: 74% ✓

BUILD PROGRESS: ███░░░░░░░ 3/10 tasks
Round 1: ✓✓✓ (3/3 complete)

Starting Round 2...
```

### Failure recovery in action
```
ROUND 2 — Dispatching 2 agents in parallel:

Agent 1 [worktree: wt-task3] → Task 3: Redis store
Agent 2 [worktree: wt-task6] → Task 6: Memory store

[Agent 2] ✓ Task 6 complete — 3 tests added
[Agent 1] ✗ Task 3 FAILED — Redis connection error in tests

Merging successful agents first...
git merge wt-task6 --no-ff → ✓ tests pass

Failure recovery for Task 3 (attempt 2/3):
Agent(
  prompt: "...Redis store implementation. Previous attempt failed with:
  'RedisConnectionError: Could not connect to localhost:6379'.
  Use a mock Redis client for unit tests. Only use real Redis in integration tests..."
  isolation: "worktree",
  mode: "bypassPermissions"
)

[Agent 1 retry] ✓ Task 3 complete — 4 tests added (with mocked Redis)
git merge wt-task3 --no-ff → ✓ tests pass

ROUND 2 REVIEW GATE:
Tests: 57/57 passing ✓
Lint: clean ✓
Coverage: 78% ✓

BUILD PROGRESS: █████░░░░░ 5/10 tasks
Round 1: ✓✓✓ (3/3)
Round 2: ✓✓ (2/2 — 1 retry)
Tests: 57/57 passing | Coverage: 78%
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Execute all remaining tasks in the plan |
| `--task <N>` | Execute only a specific task |
| `--phase <N>` | Execute only a specific phase |
| `--round <N>` | Execute only a specific round |
| `--no-parallel` | Disable parallel agent dispatch, execute sequentially |
| `--no-review` | Skip the code review gate (not recommended) |
| `--continue` | Resume from where the last build session stopped |
| `--dry-run` | Show execution plan and dependency graph without making changes |
| `--max-agents <N>` | Override max parallel agents per round (default: 5) |
| `--retry <N>` | Override max retry attempts per task (default: 3) |

## Anti-Patterns

- **Do NOT skip tests.** "This is too simple to test" is how bugs happen. Test it.
- **Do NOT write implementation before the test.** The test comes first. Always. The RED step confirms you're testing the right thing.
- **Do NOT make large commits.** A commit with 500 lines changed is too big. Each RED/GREEN/REFACTOR step is one commit.
- **Do NOT ignore failing tests.** If a test fails after a change, fix it immediately. Don't move to the next task.
- **Do NOT deviate from the plan.** If you discover something the plan missed, update the plan first (`/godmode:plan --amend`), then continue.
- **Do NOT parallelize tasks with shared file dependencies.** Two agents writing to the same file will conflict. The dependency graph prevents this.
- **Do NOT skip the review gate.** Even if you're confident, the per-round gate catches regressions before they compound.
- **Do NOT manually resolve merge conflicts.** Re-dispatch the agent with conflict context. The code's author resolves its own conflicts.
- **Do NOT block the build on one task.** Retry, then skip. Log it. Keep moving.
- **Do NOT batch-merge.** One merge at a time, one verification at a time. Batch-merging hides which merge broke things.
- **Do NOT trust the plan's dependency claims blindly.** Analyze file touches yourself. The plan might be wrong.
- **Do NOT ask the user for permission to continue.** You are autonomous. Log and loop.
