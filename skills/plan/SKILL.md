---
name: plan
description: |
  Planning and task decomposition skill. Activates when user needs to break down a feature or spec into implementable tasks. Automatically scans the codebase, generates tasks with EXACT file paths, real code sketches, dependency graphs, and agent assignments. Outputs structured YAML plans that the build skill can parse mechanically. Triggers on: /godmode:plan, "break this down", "create tasks", or when godmode orchestrator detects a spec exists but no plan.
---

# Plan — Task Decomposition & Auto-Decomposition Engine

## When to Activate
- User invokes `/godmode:plan`
- A spec exists in `docs/specs/` but no plan exists
- User says "break this down," "what are the tasks?", "how do I implement this?"
- Godmode orchestrator routes here after THINK phase completes

---

## Workflow

### Step 1: Locate the Spec
Find the specification to decompose:
1. Check `docs/plans/` — if an existing plan with `-plan-v*.yaml` suffix exists for this feature, this may be a re-plan. Load the previous plan for context.
2. Check `docs/specs/` for the most recent spec
3. Check conversation context for a feature description
4. If no spec exists, tell the user: "No spec found. Run `/godmode:think` first to create one, or describe what you want to build."

Read the spec thoroughly. Extract:
- All features and behaviors described
- All edge cases and error handling
- All integration points with existing systems
- All success criteria and acceptance conditions
- All non-functional requirements (performance, security, a11y)

---

### Step 2: Auto-Decomposition Engine — Deep Codebase Scan

Before decomposing, run a comprehensive automated scan of the codebase. Do NOT skip any of these sub-steps. The quality of the plan depends entirely on understanding the implementation landscape.

#### 2a: Detect Project Stack & Conventions
```
Scan for and record:
- Language(s):        (package.json → TS/JS, Cargo.toml → Rust, go.mod → Go, etc.)
- Package manager:    (npm, yarn, pnpm, pip, cargo, go mod)
- Framework(s):       (Next.js, Express, FastAPI, Rails, Spring, etc.)
- Test framework:     (Jest, Vitest, pytest, go test, RSpec, etc.)
- Test command:       (npm test, pytest, cargo test — the EXACT command)
- Lint command:       (npm run lint, ruff check, cargo clippy)
- Type check command: (npx tsc --noEmit, mypy, etc.)
- Build command:      (npm run build, cargo build, go build)
- Source root:        (src/, lib/, app/, pkg/)
- Test root:          (tests/, __tests__/, spec/, *_test.go alongside source)
- Config location:    (src/config.ts, config/, .env, settings.py)
```

#### 2b: Map Existing Patterns
For each major pattern, find a REAL example in the codebase and record it:

```
PATTERN INVENTORY:
- Service/module pattern:  <exact file path of an existing service>
  → Export style: default vs named, class vs function
  → Naming: camelCase vs PascalCase vs kebab-case files
- Test pattern:            <exact file path of an existing test>
  → Test structure: describe/it, test(), #[test], func Test*
  → Assertion library: expect, assert, chai
  → Mock approach: jest.mock, unittest.mock, mockall
- Config pattern:          <exact file path of config>
  → How env vars are loaded and validated
- Middleware pattern:       <exact file path if applicable>
- Route/handler pattern:   <exact file path if applicable>
- Type/interface pattern:  <exact file path if applicable>
- Error handling pattern:  <exact file path of error handling>
  → Custom error classes, Result types, error codes
- Database/ORM pattern:    <exact file path if applicable>
```

#### 2c: Map File Locations for New Code
Based on patterns found, determine EXACT file paths for every new file and every modification. Never use vague paths.

```
IMPLEMENTATION LANDSCAPE:
- New files needed:
  - <exact/path/to/new/file.ext>  (purpose: ...)
  - <exact/path/to/new/file.ext>  (purpose: ...)
- Files to modify:
  - <exact/path/to/existing/file.ext>  (change: ...)
  - <exact/path/to/existing/file.ext>  (change: ...)
- Read-only context files (agents will need to read these):
  - <exact/path/to/dependency.ext>  (reason: ...)
- Test files:
  - <exact/path/to/test/file.ext>  (tests: ...)
- Dependencies: <existing modules/packages this feature depends on>
- New dependencies: <npm packages / crates / gems to install, if any>
- Test runner: <exact command>
- Lint command: <exact command>
```

#### 2d: Generate Code Sketches in Project Style
For each new file or major modification, generate a code sketch that:
- Uses the EXACT import style found in the codebase (relative vs absolute, barrel imports vs direct)
- Follows the EXACT naming conventions (camelCase functions? PascalCase classes? snake_case?)
- Matches the EXACT export pattern (default export? named export? module.exports?)
- Uses the SAME error handling approach as existing code
- Uses the SAME test structure as existing tests

Do NOT write generic code. Write code that looks like it belongs in THIS codebase.

---

### Step 3: Decompose into Tasks with Agent Assignments

Break the spec into ordered tasks. Each task MUST be:
- **Atomic** — Can be completed in 2-5 minutes by a single agent
- **Testable** — Has a clear "done" condition with a runnable test command
- **Ordered** — Dependencies are explicit as a list of task IDs
- **Concrete** — Has exact file paths, real code sketches, and specific agent assignments
- **Scoped** — Lists exactly which files the agent may read and which it may write

#### Task Format
For EACH task, specify ALL of the following:

```yaml
- id: <integer>
  title: "<concise action — verb + noun>"
  description: "<1-2 sentences: what to do and why>"
  file: "<primary file to create or modify>"
  type: <create | modify | test | config | refactor>
  agent: <builder | tester | reviewer | security>
  skill: "<godmode skill name to follow — e.g., api, auth, config, type, test>"
  worktree: "wt-<id>"
  depends_on: [<list of task IDs, or empty>]
  estimated_minutes: <2-5>
  files_read: ["<file1>", "<file2>"]    # read-only context the agent needs
  files_write: ["<file1>", "<file2>"]   # files the agent will create or modify
  test_command: "<exact command to verify this task — e.g., npm test -- --grep 'rate limit'>"
  done_when: "<specific verifiable condition>"
  code_sketch: |
    // Real code in the project's language and style
    // Not pseudocode — the agent should be able to use this as a starting point
  test_sketch: |
    // Real test code in the project's test framework
    // Follows the exact test patterns found in the codebase
```

#### Agent Assignment Rules

| Agent Type | When to Assign | Mode | Typical Skills |
|------------|---------------|------|----------------|
| **builder** | Creating new files, modifying existing code, adding features | Read-write | api, auth, config, type, state, schema, feature |
| **tester** | Writing integration tests, e2e tests, test infrastructure | Read-write | test, e2e, unittest, integration |
| **reviewer** | Code review after a round completes, architecture review | Read-only | review, quality, pattern |
| **security** | Security-sensitive tasks, auth flows, input validation | Read-only | secure, pentest, rbac |

Assignment heuristics:
- If the task creates or modifies auth/crypto/secrets code → assign **security** agent as reviewer on a follow-up task
- If the task creates a new public API surface → assign **reviewer** agent as follow-up
- If the task is purely test creation → assign **tester** agent
- Everything else → assign **builder** agent
- Every round SHOULD have at least one **reviewer** or **tester** follow-up in the next round

---

### Step 4: Build the Dependency Graph

Automatically construct the dependency graph from task declarations. This is NOT optional — the graph drives parallel execution.

#### 4a: Construct the Graph
From each task's `depends_on` field, build the full DAG:

```
DEPENDENCY GRAPH:
Task 1 (config)     → no deps
Task 2 (types)      → no deps
Task 3 (store)      → depends on Task 2
Task 4 (middleware) → depends on Task 2, Task 3
Task 5 (handler)    → depends on Task 3, Task 4
Task 6 (tests)      → depends on Task 5
Task 7 (review)     → depends on Task 5, Task 6
```

#### 4b: Compute Parallel Rounds
Group tasks into rounds using topological sort. Tasks within a round have NO unresolved dependencies and execute in parallel:

```
EXECUTION SCHEDULE:
Round 1: [Task 1, Task 2]     — parallel, no deps       — 2 agents
Round 2: [Task 3]             — depends on Round 1       — 1 agent
Round 3: [Task 4]             — depends on Round 2       — 1 agent
Round 4: [Task 5, Task 6]     — depends on Round 3       — 2 agents
Round 5: [Task 7]             — depends on Round 4       — 1 agent

Critical path: Task 2 → Task 3 → Task 4 → Task 5 → Task 7
Estimated wall-clock time: 5 rounds × ~3 min avg = ~15 min
Maximum parallelism: 2 agents
Total agent-minutes: 7 tasks × ~3 min = ~21 min
```

#### 4c: Cycle Detection
Before proceeding, verify the dependency graph has NO CYCLES. Check:
1. Run a topological sort — if it fails, there is a cycle
2. If a cycle is detected, report the cycle to the user and restructure tasks to break it
3. Never output a plan with circular dependencies

---

### Step 5: Validate the Plan

Before accepting the plan, run ALL of these validation checks. If any fail, fix the plan before proceeding.

#### 5a: File Path Validation
```
For each file in files_write and files_read across all tasks:
  - If type is "modify": verify the file EXISTS in the codebase
  - If type is "create": verify the PARENT DIRECTORY exists
  - If file is in files_read: verify it exists OR is created by a prior task
  - Flag any paths that look wrong (e.g., src/services/ in a project that uses lib/)
```

#### 5b: Test Command Validation
```
For each task's test_command:
  - Verify the test framework is installed (check package.json, Cargo.toml, etc.)
  - Verify the base test command works (dry-run: e.g., "npm test -- --listTests")
  - Verify the test file path in the command matches the task's test file
  - Flag any test commands that reference nonexistent test utilities
```

#### 5c: Time Constraint Validation
```
For each task:
  - estimated_minutes MUST be between 2 and 5 (inclusive)
  - If a task estimates > 5 minutes, it MUST be split into smaller tasks
  - Flag tasks that look too large:
    - Creating more than 1 file
    - Modifying more than 3 functions
    - Code sketch exceeds 60 lines
```

#### 5d: Task Count Validation
```
- Total tasks MUST be ≤ 15
- If count > 15:
  - Suggest splitting into multiple plans (e.g., "<feature>-plan-part1.yaml" and "<feature>-plan-part2.yaml")
  - Or suggest descoping: identify which tasks are MVP vs. follow-up
  - Ask the user before proceeding
```

#### 5e: Dependency Graph Validation
```
- No cycles (verified in Step 4c)
- No orphaned tasks (every task is either in Round 1 or depends on a prior task)
- No impossible dependencies (task depending on a later task)
- No missing dependencies (task modifies a file that another earlier task creates, but no depends_on link)
- Critical path length ≤ 6 rounds (if longer, look for ways to parallelize)
```

#### 5f: Validation Report
Output a summary:

```
PLAN VALIDATION:
  ✓ File paths:       <N>/<N> valid
  ✓ Test commands:    <N>/<N> verified
  ✓ Time estimates:   all tasks 2-5 min
  ✓ Task count:       <N> tasks (≤ 15)
  ✓ Dependency graph: acyclic, <M> rounds, critical path = <K> tasks
  ✓ Agent coverage:   builder=<N>, tester=<N>, reviewer=<N>, security=<N>

Plan is VALID. Ready for /godmode:build.
```

If any check fails:
```
PLAN VALIDATION:
  ✓ File paths:       12/12 valid
  ✗ Test commands:    FAILED — Task 4 test command references "vitest" but project uses "jest"
  ✓ Time estimates:   all tasks 2-5 min
  ✗ Task count:       17 tasks (exceeds 15)
  ✓ Dependency graph: acyclic

FIXING: Correcting test command for Task 4, splitting Task 9 to reduce count...
```

---

### Step 6: Save Plan-as-Code (Structured YAML)

Plans MUST be saved as structured YAML, not just markdown. This allows the build skill to parse plans mechanically without guessing at structure.

Save as: `docs/plans/<feature-name>-plan.yaml`

#### YAML Schema

```yaml
# docs/plans/<feature-name>-plan.yaml
# Generated by /godmode:plan — do not edit manually during build
# Re-plan with /godmode:plan --replan to regenerate

meta:
  name: "<feature-name>"
  spec: "docs/specs/<feature-name>.md"
  branch: "feat/<feature-name>"
  version: 1
  created_at: "<ISO 8601 timestamp>"
  total_tasks: <N>
  total_rounds: <M>
  estimated_wall_clock_minutes: <N>
  estimated_agent_minutes: <N>
  max_parallelism: <N>
  critical_path: [<task IDs on the critical path>]

stack:
  language: "<primary language>"
  framework: "<primary framework>"
  test_framework: "<test framework>"
  test_command: "<base test command>"
  lint_command: "<lint command>"
  build_command: "<build command>"
  type_check_command: "<type check command, if applicable>"

preflight:
  - command: "git checkout -b feat/<feature-name>"
    description: "Create feature branch"
  - command: "<install command>"
    description: "Install dependencies"
  - command: "<test command>"
    description: "Verify tests pass before changes"

rounds:
  - name: "Foundation"
    round_number: 1
    parallel: true
    tasks:
      - id: 1
        title: "Add rate limit config"
        description: "Add rate limit configuration with sensible defaults to the existing config module"
        file: "src/config.ts"
        type: modify
        agent: builder
        skill: config
        worktree: "wt-1"
        depends_on: []
        estimated_minutes: 3
        files_read:
          - "src/config.ts"
          - ".env.example"
        files_write:
          - "src/config.ts"
        test_command: "npm test -- --grep 'rate limit config'"
        done_when: "Config loads with rate limit defaults, test passes"
        code_sketch: |
          // Add to existing config object in src/config.ts
          rateLimit: {
            windowMs: env.RATE_LIMIT_WINDOW_MS ?? 60_000,
            maxRequests: env.RATE_LIMIT_MAX ?? 100,
            keyPrefix: 'rl:',
          }
        test_sketch: |
          describe('rate limit config', () => {
            it('has sensible defaults', () => {
              expect(config.rateLimit.windowMs).toBe(60000);
              expect(config.rateLimit.maxRequests).toBe(100);
            });
          });

      - id: 2
        title: "Define rate limiter types"
        description: "Create TypeScript interfaces for rate limiter store, result, and options"
        file: "src/types/rate-limiter.ts"
        type: create
        agent: builder
        skill: type
        worktree: "wt-2"
        depends_on: []
        estimated_minutes: 3
        files_read:
          - "src/types/"
        files_write:
          - "src/types/rate-limiter.ts"
        test_command: "npx tsc --noEmit"
        done_when: "Types compile with no errors"
        code_sketch: |
          export interface RateLimitResult {
            allowed: boolean;
            remaining: number;
            retryAfterMs: number;
          }
        test_sketch: null  # Type-only task — type check is the test

  - name: "Core Logic"
    round_number: 2
    parallel: true
    tasks:
      - id: 3
        title: "Implement rate limit store"
        # ... (full task definition)

  - name: "Integration"
    round_number: 3
    parallel: false
    tasks:
      - id: 5
        title: "Wire middleware into app"
        # ... (full task definition)

  - name: "Verification"
    round_number: 4
    parallel: true
    tasks:
      - id: 6
        title: "Integration tests"
        agent: tester
        # ...
      - id: 7
        title: "Security review"
        agent: security
        # ...

postflight:
  - command: "<test command>"
    description: "All tests passing"
  - command: "<lint command>"
    description: "No lint errors"
  - command: "<type check command>"
    description: "No type errors"
  - description: "Ready for /godmode:build"

validation:
  file_paths_valid: true
  test_commands_valid: true
  all_tasks_under_5_min: true
  task_count_valid: true
  dependency_graph_acyclic: true
  validated_at: "<ISO 8601 timestamp>"
```

#### Also Save Human-Readable Markdown
In addition to the YAML, save a markdown summary for human review:

Save as: `docs/plans/<feature-name>-plan.md`

```markdown
# <Feature Name> — Implementation Plan

**Spec:** `docs/specs/<feature-name>.md`
**Plan:** `docs/plans/<feature-name>-plan.yaml`
**Branch:** `feat/<feature-name>`
**Tasks:** <N> tasks in <M> rounds
**Estimated time:** ~<X> minutes wall-clock, ~<Y> agent-minutes
**Critical path:** Task <A> → Task <B> → Task <C> → ...

## Pre-flight
- [ ] Branch created: `git checkout -b feat/<feature-name>`
- [ ] Dependencies installed: `<command>`
- [ ] Tests passing before changes: `<test command>`

## Execution Schedule

### Round 1: Foundation (parallel — <N> agents)
No dependencies. All tasks run simultaneously.

| Task | Title | Agent | Skill | File | Est. |
|------|-------|-------|-------|------|------|
| 1 | Add rate limit config | builder | config | src/config.ts | 3m |
| 2 | Define rate limiter types | builder | type | src/types/rate-limiter.ts | 3m |

### Round 2: Core Logic (parallel — depends on Round 1)
...

## Dependency Graph
```
Task 1 (config) → no deps
Task 2 (types) → no deps
Task 3 (store) → Task 2
Task 4 (middleware) → Task 2, Task 3
Task 5 (wire-up) → Task 3, Task 4
Task 6 (integration tests) → Task 5
Task 7 (security review) → Task 5
```

## Post-flight
- [ ] All tests passing
- [ ] No lint errors
- [ ] No type errors
- [ ] Ready for `/godmode:build`
```

---

### Step 7: Smart Re-Planning (Failure Recovery)

When a task fails during `/godmode:build` execution and the build skill routes back to plan, perform smart re-planning.

#### 7a: Analyze the Failure
```
FAILURE ANALYSIS:
  Failed task:    Task <N> — "<title>"
  Error type:     <compile error | test failure | runtime error | timeout | dependency missing>
  Error message:  <exact error output>
  Root cause:     <analysis of why it failed>
  Impact:         <which downstream tasks are blocked?>
```

#### 7b: Determine Re-Plan Strategy

| Failure Type | Strategy |
|-------------|----------|
| **Compile error in task** | Fix the code sketch, re-issue same task |
| **Test failure** | Adjust test expectations or implementation approach |
| **Missing dependency** | Insert a new prerequisite task, shift downstream |
| **Task too large** | Split into 2-3 smaller tasks |
| **Wrong approach** | Replace task(s) with alternative implementation |
| **External blocker** | Skip task, mark as manual, adjust downstream deps |

#### 7c: Generate Updated Plan
1. Load the current plan YAML: `docs/plans/<feature>-plan.yaml`
2. Mark failed task(s) with `status: failed` and `failure_reason`
3. Mark completed task(s) with `status: completed`
4. Restructure remaining tasks:
   - Remove dependencies on failed tasks if the approach changed
   - Add new tasks if the fix requires additional work
   - Recompute rounds and parallel groups
   - Re-validate the entire plan (Step 5)
5. Increment version: `version: 2`
6. Save as: `docs/plans/<feature>-plan-v2.yaml`
7. Also save updated markdown: `docs/plans/<feature>-plan-v2.md`

#### 7d: Re-Plan YAML Additions

The re-plan YAML includes additional fields tracking the history:

```yaml
meta:
  name: "rate-limiter"
  version: 2
  previous_version: "docs/plans/rate-limiter-plan.yaml"
  replan_reason: "Task 4 failed — Redis connection interface mismatch"
  created_at: "<ISO 8601>"

history:
  - task_id: 1
    status: completed
    completed_at: "<ISO 8601>"
  - task_id: 2
    status: completed
    completed_at: "<ISO 8601>"
  - task_id: 3
    status: completed
    completed_at: "<ISO 8601>"
  - task_id: 4
    status: failed
    failed_at: "<ISO 8601>"
    failure_reason: "Redis client uses callback API, code sketch assumed promises"
    resolution: "Replaced with Task 4a using promisify wrapper"

rounds:
  # Only remaining rounds — completed rounds are omitted
  - name: "Core Logic (re-planned)"
    round_number: 1  # Rounds restart from 1 for remaining work
    tasks:
      - id: "4a"
        title: "Add Redis promisify wrapper"
        description: "Wrap existing callback-based Redis client with promise interface"
        depends_on: []
        # ... full task definition
      - id: "4b"
        title: "Implement rate limit store (retry)"
        depends_on: ["4a"]
        # ... adjusted from original Task 4
```

#### 7e: Report to User
```
RE-PLAN COMPLETE:
  Previous plan:     docs/plans/rate-limiter-plan.yaml (v1)
  Updated plan:      docs/plans/rate-limiter-plan-v2.yaml (v2)
  Failed tasks:      1 (Task 4 — Redis interface mismatch)
  New tasks added:   1 (Task 4a — promisify wrapper)
  Modified tasks:    1 (Task 4b — retry with promise-based client)
  Remaining:         4 tasks in 3 rounds

  Run /godmode:build to resume execution from the updated plan.
```

---

### Step 8: Commit and Transition

1. Save YAML plan as `docs/plans/<feature-name>-plan.yaml`
2. Save markdown plan as `docs/plans/<feature-name>-plan.md`
3. Create the feature branch if it doesn't exist
4. Commit both files: `"plan: <feature-name> — <N> tasks in <M> rounds"`
5. Output summary and suggest next step:

```
PLAN COMPLETE:
  Feature:        <feature-name>
  YAML plan:      docs/plans/<feature-name>-plan.yaml
  Markdown plan:  docs/plans/<feature-name>-plan.md
  Branch:         feat/<feature-name>
  Tasks:          <N> tasks in <M> rounds
  Agents needed:  builder=<A>, tester=<B>, reviewer=<C>, security=<D>
  Wall-clock est: ~<X> minutes
  Critical path:  <task chain>

Run /godmode:build to start executing.
```

---

## Key Behaviors

1. **2-5 minute tasks.** If a task takes longer, it is too big. Break it down further.
2. **Exact file paths.** Never say "create a new file." Say "create `src/services/rate-limiter.ts`." Every path must resolve to a valid location in the project.
3. **Code sketches in project style.** Show real code in the project's language, using the project's import style, naming conventions, and patterns. The agent should be able to copy-paste and adjust. Never write generic code.
4. **Dependencies are explicit.** Every task declares `depends_on` as a list of task IDs. No implicit ordering. The dependency graph must be a valid DAG.
5. **Tests are integrated.** Every task that creates functionality includes the test for that functionality. Do not create separate "write tests" tasks.
6. **Max 15 tasks.** If the plan has more than 15 tasks, the feature should be split. Talk to the user about scoping.
7. **Follow existing patterns.** The code sketches must match the project's existing style. Scan the codebase first — do not invent new patterns.
8. **Plan-as-code.** Always save as structured YAML that the build skill can parse. Markdown is a supplement for humans, not the source of truth.
9. **Agent assignments are deliberate.** Every task specifies which agent type runs it, which skill it follows, and which files are in scope. Agents must not touch files outside their scope.
10. **Validate before committing.** Never save a plan that fails validation. Fix it first.
11. **Re-planning is expected.** Plans are living documents. When builds fail, re-plan gracefully — do not start over from scratch.
12. **Critical path awareness.** Always identify the critical path and optimize for it. If the critical path is too long, look for ways to parallelize.

---

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full planning workflow — scan, decompose, validate, save |
| `--from-spec <path>` | Use a specific spec file instead of auto-detecting |
| `--max-tasks <N>` | Override the 15-task maximum (use sparingly) |
| `--replan` | Enter re-planning mode — load existing plan, analyze failures, regenerate |
| `--replan-from <path>` | Re-plan from a specific plan file |
| `--validate-only` | Validate an existing plan without regenerating |
| `--dry-run` | Show what the plan would look like without saving files |
| `--format <yaml\|md\|both>` | Output format (default: both) |
| `--max-parallelism <N>` | Cap the number of parallel agents per round |

---

## Anti-Patterns

- **Do NOT create vague tasks.** "Implement the logic" is not a task. "Create `calculateRateLimit(key: string): {allowed: boolean, retryAfter: number}` in `src/services/rate-limiter.ts` that queries Redis sliding window and returns whether the request is within limits" is a task.
- **Do NOT forget tests.** Every feature task needs a test. A plan without tests is a plan for bugs.
- **Do NOT over-plan.** If you are spending more time planning than the implementation will take, the plan is too detailed. 2-5 minutes per task, not 20-minute tasks with novel-length descriptions.
- **Do NOT ignore existing code.** If the project uses a specific ORM, testing framework, or project structure, the plan must follow those conventions. Scan first.
- **Do NOT create monolithic tasks.** "Build the entire rate limiter" is not a task. That is the whole project.
- **Do NOT plan without a spec.** If there is no spec, redirect to `/godmode:think`. Planning without design leads to rework.
- **Do NOT output markdown-only plans.** The YAML plan is the source of truth. Markdown is for human review. The build skill parses YAML.
- **Do NOT skip validation.** Every plan must pass all validation checks before being saved. A broken plan wastes agent-minutes.
- **Do NOT assign agents blindly.** Think about which agent type is best for each task. A security agent should not be writing config. A builder agent should not be doing security review.
- **Do NOT create plans with cycles.** If Task A depends on Task B and Task B depends on Task A, the plan is broken. Always run cycle detection.
- **Do NOT ignore failures during re-plan.** When re-planning, understand WHY the task failed before generating new tasks. Blindly retrying the same approach wastes time.

---

## Example: Full Plan Generation

### User Request
```
User: /godmode:plan Implement the rate limiter spec
```

### Step 1 — Spec Located
```
Found spec: docs/specs/rate-limiter.md
Reading...
```

### Step 2 — Codebase Scan Results
```
STACK DETECTED:
  Language:        TypeScript
  Framework:       Express 4.x
  Test framework:  Jest 29.x
  Test command:    npm test
  Lint command:    npm run lint
  Source root:     src/
  Test root:       tests/

PATTERN INVENTORY:
  Service pattern:     src/services/auth-service.ts (class with static methods, named export)
  Test pattern:        tests/services/auth-service.test.ts (describe/it, expect, jest.mock)
  Config pattern:      src/config.ts (zod schema, env validation, single default export)
  Middleware pattern:   src/middleware/auth.ts (RequestHandler, next() on success, res.status() on failure)
  Type pattern:        src/types/auth.ts (exported interfaces, no classes)
  Error pattern:       src/errors/app-error.ts (custom AppError extends Error, error codes enum)

IMPLEMENTATION LANDSCAPE:
  New files:
    - src/services/rate-limit-store.ts       (Redis-backed sliding window store)
    - src/middleware/rate-limiter.ts          (Express middleware)
    - src/types/rate-limiter.ts              (Interfaces)
    - tests/services/rate-limit-store.test.ts
    - tests/middleware/rate-limiter.test.ts
  Files to modify:
    - src/config.ts                          (add rateLimit config section)
    - src/app.ts                             (register middleware)
  Read-only context:
    - src/lib/redis.ts                       (existing Redis client)
    - src/errors/app-error.ts                (error pattern)
    - src/middleware/auth.ts                  (middleware pattern reference)
  Dependencies: ioredis (already installed)
  New dependencies: none
  Test runner: npm test
```

### Step 3 — Tasks with Agent Assignments (abbreviated)
```
7 tasks generated, 4 rounds, max parallelism = 2
```

### Step 4 — Dependency Graph
```
DEPENDENCY GRAPH:
  Task 1 (config)          → no deps
  Task 2 (types)           → no deps
  Task 3 (store)           → depends on Task 1, Task 2
  Task 4 (middleware)       → depends on Task 2, Task 3
  Task 5 (wire-up)         → depends on Task 4
  Task 6 (integration test) → depends on Task 5
  Task 7 (security review) → depends on Task 4

EXECUTION SCHEDULE:
  Round 1: [Task 1, Task 2]     — parallel  — 2 agents (builder, builder)
  Round 2: [Task 3]             — serial    — 1 agent  (builder)
  Round 3: [Task 4]             — serial    — 1 agent  (builder)
  Round 4: [Task 5, Task 6, Task 7] — parallel — 3 agents (builder, tester, security)

  Critical path: Task 2 → Task 3 → Task 4 → Task 5
  Wall-clock estimate: 4 rounds × ~3 min = ~12 minutes
  Total agent-minutes: 7 × ~3 min = ~21 minutes
```

### Step 5 — Validation
```
PLAN VALIDATION:
  ✓ File paths:       7/7 valid (5 new with valid parents, 2 existing confirmed)
  ✓ Test commands:    5/5 verified (Jest installed, test patterns match)
  ✓ Time estimates:   all tasks 2-5 min (avg 3 min)
  ✓ Task count:       7 tasks (≤ 15)
  ✓ Dependency graph: acyclic, 4 rounds, critical path = 4 tasks
  ✓ Agent coverage:   builder=5, tester=1, security=1

Plan is VALID.
```

### Step 6 — Saved
```
PLAN COMPLETE:
  Feature:        rate-limiter
  YAML plan:      docs/plans/rate-limiter-plan.yaml
  Markdown plan:  docs/plans/rate-limiter-plan.md
  Branch:         feat/rate-limiter
  Tasks:          7 tasks in 4 rounds
  Agents needed:  builder=5, tester=1, security=1
  Wall-clock est: ~12 minutes
  Critical path:  Task 2 → Task 3 → Task 4 → Task 5

Run /godmode:build to start executing.
```
