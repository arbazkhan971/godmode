---
name: build
description: |
  Build and execution skill. Activates when user is ready to implement a plan. Executes tasks in order using TDD (RED-GREEN-REFACTOR), dispatches parallel agents for independent tasks, and enforces 2-stage code review. Triggers on: /godmode:build, "start building", "implement this", or when godmode orchestrator detects a plan exists with unfinished tasks.
---

# Build — Execute with TDD & Parallel Agents

## When to Activate
- User invokes `/godmode:build`
- A plan exists in `docs/plans/` with unfinished tasks
- User says "start building," "implement this," "execute the plan"
- Godmode orchestrator routes here after PLAN phase completes

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
Parallel candidates: Tasks <X, Y> (no dependencies on each other)
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

If tests are failing before you start: "Existing tests are failing. Run `/godmode:fix` first, then come back to build."

### Step 3: Execute Tasks (TDD Loop)
For each task, follow the RED-GREEN-REFACTOR cycle:

#### RED: Write the Failing Test
```
1. Read the task's test specification from the plan
2. Write the test file (or add to existing test file)
3. Run the test — it MUST fail
4. If it passes, the test is wrong or the feature already exists
5. Commit: "test(red): <task title> — failing test"
```

#### GREEN: Make It Pass
```
1. Read the task's code sketch from the plan
2. Implement the minimum code to make the test pass
3. Run the test — it MUST pass now
4. Run ALL tests — nothing else should break
5. Commit: "feat: <task title> — implementation"
```

#### REFACTOR: Clean Up
```
1. Look for duplication, unclear naming, or unnecessary complexity
2. Refactor without changing behavior
3. Run ALL tests — everything must still pass
4. If improvements were made, commit: "refactor: <task title> — <what changed>"
5. If no refactoring needed, skip this step
```

### Step 4: Parallel Agent Dispatch
When multiple tasks have no dependency on each other, dispatch them in parallel:

```
PARALLEL EXECUTION:
Dispatching 3 agents for independent tasks:

Agent 1 → Task 4: Create user service
Agent 2 → Task 5: Create email service
Agent 3 → Task 6: Create notification service

Each agent follows the same RED-GREEN-REFACTOR cycle.
Waiting for all agents to complete...
```

Rules for parallel dispatch:
- Only tasks with no shared file dependencies can run in parallel
- Each agent gets its own context with the task details
- After all agents complete, run the FULL test suite to catch integration issues
- If any agent's tests fail in combination with others, resolve conflicts sequentially

### Step 5: Code Review Gate
After every 3-5 tasks (or at the end of a phase), trigger a review:

#### Stage 1: Automated Review
```
1. Run full test suite
2. Run linter
3. Run type checker (if applicable)
4. Check test coverage
5. Run any project-specific quality checks

AUTOMATED REVIEW:
✓ Tests: 24/24 passing
✓ Lint: clean
✓ Types: no errors
✓ Coverage: 87% (target: 80%)
```

#### Stage 2: Agent Review
Dispatch the code-reviewer agent to review the diff:

```
1. Generate diff: git diff <branch-base>...HEAD
2. Send to code-reviewer agent with context:
   - The spec (what should be built)
   - The plan (how it should be built)
   - The diff (what was actually built)
3. Review checks:
   - Does the implementation match the spec?
   - Are there logic errors?
   - Are edge cases handled?
   - Is error handling complete?
   - Are there security concerns?
   - Is the code following project conventions?
4. Address any MUST-FIX findings before proceeding
```

### Step 6: Phase Transitions
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

### Step 7: Build Complete
When all tasks are done:

```
BUILD COMPLETE ✓
All <N> tasks implemented and tested.

Results:
- Tests: <total> passing, 0 failing
- Coverage: <X>%
- New files: <count>
- Modified files: <count>
- Commits: <count>

Next steps:
→ /godmode:optimize — Improve performance and quality autonomously
→ /godmode:secure — Run a security audit
→ /godmode:ship — Ship if you're satisfied
```

Commit: `"build: <feature> — all <N> tasks complete"`

## Key Behaviors

1. **TDD is non-negotiable.** Every feature task starts with a failing test. No exceptions. No "I'll add tests later."
2. **Small commits.** One commit per RED, one per GREEN, one per REFACTOR. This creates a clean, reversible history.
3. **Run all tests frequently.** After every GREEN step, run the FULL test suite, not just the new test.
4. **Parallel when possible.** Don't serialize independent tasks. Use agents.
5. **Review at phase boundaries.** Don't wait until the end to review. Catch issues early.
6. **Never skip the failing test.** If the test passes immediately, investigate. Either the feature already exists, or the test doesn't test what you think it tests.
7. **Follow the plan.** Don't improvise. If the plan needs changes, update it first, then continue building.

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

Starting Task 1: Add rate limit configuration

RED: Writing failing test...
```

### Parallel execution
```
Build: Phase 1 complete. Starting Phase 2.

Tasks 4, 5, and 6 have no dependencies on each other.
Dispatching parallel agents:

Agent 1 → Task 4: Sliding window counter logic
Agent 2 → Task 5: Rate limit middleware
Agent 3 → Task 6: Rate limit response headers

All agents using RED-GREEN-REFACTOR cycle...

[Agent 1] ✓ Task 4 complete — 3 tests passing
[Agent 3] ✓ Task 6 complete — 2 tests passing
[Agent 2] ✓ Task 5 complete — 4 tests passing

Integration check: Running full suite...
✓ All 51 tests passing. No conflicts.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Execute all remaining tasks in the plan |
| `--task <N>` | Execute only a specific task |
| `--phase <N>` | Execute only a specific phase |
| `--no-parallel` | Disable parallel agent dispatch, execute sequentially |
| `--no-review` | Skip the code review gate (not recommended) |
| `--continue` | Resume from where the last build session stopped |
| `--dry-run` | Show what would be executed without making changes |

## Anti-Patterns

- **Do NOT skip tests.** "This is too simple to test" is how bugs happen. Test it.
- **Do NOT write implementation before the test.** The test comes first. Always. The RED step confirms you're testing the right thing.
- **Do NOT make large commits.** A commit with 500 lines changed is too big. Each RED/GREEN/REFACTOR step is one commit.
- **Do NOT ignore failing tests.** If a test fails after a change, fix it immediately. Don't move to the next task.
- **Do NOT deviate from the plan.** If you discover something the plan missed, update the plan first (`/godmode:plan --amend`), then continue.
- **Do NOT parallelize tasks with shared file dependencies.** Two agents writing to the same file will conflict. Serialize those tasks.
- **Do NOT skip the code review gate.** Even if you're confident, the review catches things you missed.
