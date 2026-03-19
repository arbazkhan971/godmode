---
name: plan
description: |
  Planning and task decomposition skill. Activates when user needs to break down a feature or spec into implementable tasks. Each task is 2-5 minutes, has exact file paths, code samples, dependencies, and test requirements. Triggers on: /godmode:plan, "break this down", "create tasks", or when godmode orchestrator detects a spec exists but no plan.
---

# Plan — Task Decomposition

## When to Activate
- User invokes `/godmode:plan`
- A spec exists in `docs/specs/` but no plan exists
- User says "break this down," "what are the tasks?", "how do I implement this?"
- Godmode orchestrator routes here after THINK phase completes

## Workflow

### Step 1: Locate the Spec
Find the specification to decompose:
1. Check `docs/specs/` for the most recent spec
2. Check conversation context for a feature description
3. If no spec exists, tell the user: "No spec found. Run `/godmode:think` first to create one, or describe what you want to build."

Read the spec thoroughly. Identify:
- All features and behaviors described
- All edge cases and error handling
- All integration points
- All success criteria

### Step 2: Research the Codebase
Before decomposing, understand the implementation landscape:

1. **Identify existing patterns** — How are similar features built?
2. **Map file locations** — Where will new code live?
3. **Find dependencies** — What existing code will this depend on?
4. **Check test patterns** — How are similar features tested?

```
IMPLEMENTATION LANDSCAPE:
- New files needed: <list with exact paths>
- Files to modify: <list with exact paths>
- Dependencies: <existing modules/packages needed>
- Test files: <where tests will live>
- Test runner: <command to run tests>
```

### Step 3: Decompose into Tasks
Break the spec into ordered tasks. Each task MUST be:
- **Atomic** — Can be completed in 2-5 minutes
- **Testable** — Has a clear "done" condition
- **Ordered** — Dependencies are explicit
- **Concrete** — Has exact file paths and code samples

Task format:
```markdown
### Task N: <Title>
**File:** `<exact file path to create or modify>`
**Depends on:** Task <M> (or "none")
**Type:** <create | modify | test | config>

**What to do:**
<Precise description of the change>

**Code sketch:**
```<language>
// Approximate code — not final, but shows intent and structure
<code sample showing key logic>
```

**Test:**
```<language>
// Test that proves this task is done
<test code>
```

**Done when:** <Specific, verifiable condition>
```

### Step 4: Order and Group Tasks
Organize tasks into implementation phases:

```markdown
## Phase 1: Foundation (Tasks 1-3)
Set up data structures, interfaces, and configuration.
No business logic yet — just the skeleton.

### Task 1: ...
### Task 2: ...
### Task 3: ...

## Phase 2: Core Logic (Tasks 4-7)
Implement the main functionality with tests.
RED-GREEN-REFACTOR for each task.

### Task 4: ...
### Task 5: ...

## Phase 3: Integration (Tasks 8-10)
Connect to existing systems, add API endpoints, wire up UI.

### Task 8: ...

## Phase 4: Polish (Tasks 11-13)
Error handling, edge cases, logging, documentation.

### Task 11: ...
```

Rules:
- **Maximum 15 tasks.** If you have more, the feature is too big — split it into multiple plans.
- **Tests come with features.** Every feature task must include its test. Don't have separate "write tests" tasks.
- **Foundation first.** Data types, interfaces, and config come before logic.
- **Integration last.** Don't wire up the API until the core logic works.

### Step 5: Create the Plan File
Save the plan:

```markdown
# <Feature Name> — Implementation Plan

**Spec:** `docs/specs/<feature-name>.md`
**Branch:** `feat/<feature-name>`
**Estimated tasks:** <N>
**Estimated time:** <N * 3 min average>

## Pre-flight
- [ ] Branch created: `git checkout -b feat/<feature-name>`
- [ ] Dependencies installed: `<command>`
- [ ] Tests passing before changes: `<test command>`

## Tasks
<All phases and tasks>

## Post-flight
- [ ] All tests passing
- [ ] No lint errors
- [ ] Coverage ≥ <target>%
- [ ] Ready for `/godmode:build`
```

### Step 6: Commit and Transition
1. Save as `docs/plans/<feature-name>-plan.md`
2. Create the feature branch if it doesn't exist
3. Commit: `"plan: <feature-name> — <N> tasks in <M> phases"`
4. Suggest: "Plan ready with <N> tasks. Run `/godmode:build` to start executing."

## Key Behaviors

1. **2-5 minute tasks.** If a task takes longer, it's too big. Break it down further.
2. **Exact file paths.** Never say "create a new file." Say "create `src/services/rate-limiter.ts`."
3. **Code sketches, not pseudocode.** Show real code in the project's language and style. The implementer should be able to copy-paste and adjust.
4. **Dependencies are explicit.** Every task states which tasks must be done first. No implicit ordering.
5. **Tests are integrated.** Every task that creates functionality includes the test for that functionality.
6. **Max 15 tasks.** If the plan has more than 15 tasks, the feature should be split. Talk to the user about scoping.
7. **Follow existing patterns.** The code sketches should match the project's existing style, not introduce new patterns.

## Example Usage

### Planning an API endpoint
```
User: /godmode:plan Implement the rate limiter spec

Plan: Reading spec at docs/specs/rate-limiter.md...

IMPLEMENTATION LANDSCAPE:
- New files:
  - src/middleware/rate-limiter.ts
  - src/services/rate-limit-store.ts
  - tests/middleware/rate-limiter.test.ts
  - tests/services/rate-limit-store.test.ts
- Files to modify:
  - src/app.ts (add middleware)
  - src/config.ts (add rate limit config)
- Dependencies: existing Redis client at src/lib/redis.ts
- Test runner: npm test

## Phase 1: Foundation (Tasks 1-3)

### Task 1: Add rate limit configuration
**File:** `src/config.ts`
**Depends on:** none
**Type:** modify

**What to do:**
Add rate limit configuration with defaults.

**Code sketch:**
```typescript
// Add to existing config object
rateLimit: {
  windowMs: env.RATE_LIMIT_WINDOW_MS ?? 60_000,
  maxRequests: env.RATE_LIMIT_MAX ?? 100,
  keyPrefix: 'rl:',
}
```

**Test:**
```typescript
test('rate limit config has defaults', () => {
  expect(config.rateLimit.windowMs).toBe(60000);
  expect(config.rateLimit.maxRequests).toBe(100);
});
```

**Done when:** Config loads with defaults, test passes.

### Task 2: Create rate limit store interface and Redis implementation
...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full planning workflow |
| `--from-spec <path>` | Use a specific spec file |
| `--max-tasks <N>` | Override the 15-task maximum (use sparingly) |
| `--parallel` | Mark which tasks can be done in parallel by separate agents |
| `--estimate` | Add time estimates to each task |

## Anti-Patterns

- **Do NOT create vague tasks.** "Implement the logic" is not a task. "Create `calculateRateLimit(key: string): {allowed: boolean, retryAfter: number}` that queries Redis and returns whether the request is within limits" is a task.
- **Do NOT forget tests.** Every feature task needs a test. A plan without tests is a plan for bugs.
- **Do NOT over-plan.** If you're spending more time planning than the implementation will take, the plan is too detailed. 2-5 minutes per task, not 20-minute tasks with novel-length descriptions.
- **Do NOT ignore existing code.** If the project uses a specific ORM, testing framework, or project structure, the plan must follow those conventions.
- **Do NOT create monolithic tasks.** "Build the entire rate limiter" is not a task. That's the whole project.
- **Do NOT plan without a spec.** If there's no spec, redirect to `/godmode:think`. Planning without design leads to rework.
