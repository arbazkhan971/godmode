---
name: godmode
description: |
  Orchestrator skill. Activates when user says /godmode without a subcommand, or when context suggests a phase transition. Auto-detects current project phase (THINK/BUILD/OPTIMIZE/SHIP) by examining git history, test status, and file state. Routes to the appropriate sub-skill. Also activates on ambiguous requests where the right skill is unclear. Supports continuous loop mode, multi-agent parallel execution, skill chaining, automatic error recovery, and session tracking.
---

# Godmode — The Orchestrator

## When to Activate
- User invokes `/godmode` without a subcommand
- User describes a goal but doesn't specify which phase to start with
- A sub-skill completes and the next phase needs to be determined
- User asks "what should I do next?" or similar orientation questions
- User gives a natural language request that maps to one or more skills

---

## Step 0: Project Detection

Before anything else, detect the project type. This determines every default command used downstream.

Scan the working directory root for these files, in order. First match wins primary stack; continue scanning for secondary stacks (monorepos often have multiple).

| Indicator File | Stack | Test Command | Lint Command | Build Command | Package Manager |
|---|---|---|---|---|---|
| `package.json` + `next.config.*` | Next.js / TS | `npm test` or `npx jest` | `npx eslint . --fix` | `npm run build` | npm / yarn / pnpm (check lockfile) |
| `package.json` + `tsconfig.json` | TypeScript / Node | `npx jest` or `npx vitest` | `npx eslint . --fix` | `npx tsc --noEmit` | npm / yarn / pnpm (check lockfile) |
| `package.json` | JavaScript / Node | `npm test` | `npx eslint . --fix` | `npm run build` | npm / yarn / pnpm (check lockfile) |
| `pyproject.toml` | Python (modern) | `pytest` | `ruff check --fix .` | n/a | uv / pip / poetry (check `[build-system]`) |
| `requirements.txt` | Python (legacy) | `pytest` | `ruff check --fix .` or `flake8` | n/a | pip |
| `Cargo.toml` | Rust | `cargo test` | `cargo clippy --fix` | `cargo build --release` | cargo |
| `go.mod` | Go | `go test ./...` | `golangci-lint run` | `go build ./...` | go modules |
| `Gemfile` | Ruby | `bundle exec rspec` | `bundle exec rubocop -A` | n/a | bundler |
| `pom.xml` | Java (Maven) | `mvn test` | `mvn checkstyle:check` | `mvn package -DskipTests` | maven |
| `build.gradle` or `build.gradle.kts` | Java/Kotlin (Gradle) | `./gradlew test` | `./gradlew ktlintCheck` | `./gradlew build -x test` | gradle |
| `mix.exs` | Elixir | `mix test` | `mix credo` | `mix compile` | mix |
| `Package.swift` | Swift | `swift test` | `swiftlint` | `swift build` | spm |
| `CMakeLists.txt` | C/C++ | `ctest` | `clang-tidy` | `cmake --build build` | cmake |
| `Makefile` (only) | Unknown / C | `make test` | `make lint` | `make` | make |
| `docker-compose.yml` | Containerized | detect inner stack | detect inner stack | `docker compose build` | docker |

**Resolution rules:**
1. Check for lockfiles first: `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, `package-lock.json` → npm, `uv.lock` → uv, `poetry.lock` → poetry.
2. If `package.json` has a `"test"` script, use `npm test` (or equivalent) instead of guessing the runner.
3. If `package.json` has `"lint"` or `"lint:fix"`, prefer that over raw eslint.
4. If `pyproject.toml` has `[tool.pytest]`, confirm pytest is the runner.
5. For monorepos, detect the workspace root and note per-package stacks.

Store the detected config mentally (or in `.godmode/project.json` if `--loop` or `--resume` is active) so every downstream skill inherits the correct commands without re-detection.

---

## Step 1: Auto-Skill Matching

Map the user's natural language to the correct skill(s). This runs BEFORE phase detection when the user provides a freeform request.

### Natural Language → Skill Mapping Table

| User says (trigger phrase) | Skill | Rationale |
|---|---|---|
| "make it faster", "speed up", "too slow", "performance" | `optimize` | Performance optimization |
| "secure this", "check for vulnerabilities", "harden" | `secure` | Security audit |
| "write tests", "add tests", "cover this", "test coverage" | `test` | Test generation |
| "fix this", "it's broken", "doesn't work", "error" | `fix` | Bug fix |
| "debug", "why is this happening", "investigate" | `debug` | Root cause analysis |
| "refactor", "clean up", "simplify", "too messy" | `refactor` | Code refactoring |
| "deploy", "push to prod", "go live" | `deploy` | Deployment |
| "ship it", "release", "tag a version" | `ship` | Release / ship |
| "plan this", "break it down", "how should we build" | `plan` | Task planning |
| "think about", "design", "what's the best approach" | `think` | Design thinking |
| "build", "implement", "create", "code this" | `build` | Implementation |
| "review", "code review", "check my code" | `review` | Code review |
| "document", "add docs", "explain this code" | `docs` | Documentation |
| "lint", "format", "style issues" | `lint` | Lint / format |
| "migrate", "upgrade", "move to" | `migrate` | Migration |
| "set up CI", "add pipeline", "github actions" | `cicd` | CI/CD setup |
| "add auth", "login", "authentication" | `auth` | Auth implementation |
| "add API", "endpoint", "REST", "route" | `api` | API design |
| "database", "schema", "add table", "model" | `schema` | Schema design |
| "UI", "component", "page", "layout" | `ui` | UI implementation |
| "make it accessible", "a11y", "screen reader" | `a11y` | Accessibility |
| "search", "find", "index" | `search` | Search implementation |
| "cache", "caching", "memoize" | `cache` | Caching strategy |
| "real-time", "websocket", "live updates" | `realtime` | Real-time features |
| "email", "send notification", "alert" | `notify` | Notifications |
| "docker", "containerize", "Dockerfile" | `docker` | Containerization |
| "scale", "handle more traffic", "horizontal" | `scale` | Scaling strategy |
| "monitor", "observability", "metrics", "logging" | `observe` | Observability |
| "estimate", "how long", "effort", "story points" | `estimate` | Estimation |
| "what changed", "changelog", "release notes" | `changelog` | Changelog |
| "config", "environment", "env vars", "settings" | `config` | Configuration |
| "rate limit", "throttle", "too many requests" | `ratelimit` | Rate limiting |
| "internationalize", "translate", "i18n", "localize" | `i18n` | Internationalization |
| "SEO", "meta tags", "search engine" | `seo` | SEO |
| "GraphQL", "query language", "schema stitching" | `graphql` | GraphQL |
| "state management", "redux", "zustand", "store" | `state` | State management |
| "error handling", "try catch", "graceful errors" | `errorhandling` | Error handling |
| "load test", "stress test", "how many users" | `loadtest` | Load testing |
| "feature flag", "toggle", "experiment" | `experiment` | Feature flags |
| "secrets", "vault", "credentials" | `secrets` | Secrets management |
| "queue", "background job", "worker", "async task" | `queue` | Queue/workers |

**Matching rules:**
1. Case-insensitive substring matching on the user's message.
2. If multiple skills match, pick the most specific one (e.g., "make the API faster" → `optimize` not `api`).
3. If the request implies a chain (e.g., "build and test a payment system"), map to a skill chain (see Skill Chaining below).
4. If no match found, fall through to Step 2 (Phase Detection).
5. Compound requests ("secure and optimize") spawn parallel agents — one per skill.

---

## Step 2: Gather Context

Collect signals to determine the current project phase:

1. **Git state** — Are there uncommitted changes? What branch are we on? How many commits since branch creation?
2. **Test state** — Do tests exist? Do they pass? What's the coverage?
3. **Error state** — Are there lint errors, type errors, or failing tests?
4. **File state** — Is there a spec? A plan? Implementation code? Is it complete?
5. **User intent** — What did the user just say? What are they trying to accomplish?
6. **Project stack** — What was detected in Step 0? Set all default commands accordingly.
7. **Session history** — Check `.godmode/session-log.tsv` for what skills have already run this session.

---

## Step 3: Detect Phase

```
IF no spec exists AND no plan exists:
  → THINK phase (suggest /godmode:think)

IF spec exists BUT no plan OR incomplete plan:
  → BUILD phase, planning stage (suggest /godmode:plan)

IF plan exists AND tasks remain unimplemented:
  → BUILD phase, execution stage (suggest /godmode:build)

IF implementation exists AND tests fail:
  → OPTIMIZE phase, fix stage (suggest /godmode:fix)

IF implementation exists AND tests pass BUT performance/quality issues:
  → OPTIMIZE phase (suggest /godmode:optimize)

IF implementation exists AND tests pass AND quality is good:
  → SHIP phase (suggest /godmode:ship)

IF security review requested OR pre-ship:
  → OPTIMIZE phase, security stage (suggest /godmode:secure)

IF errors in logs or stack traces mentioned:
  → OPTIMIZE phase, debug stage (suggest /godmode:debug)
```

---

## Step 4: Present Recommendation

Output a brief status card:

```
┌─────────────────────────────────────────┐
│  GODMODE — Status Assessment            │
├─────────────────────────────────────────┤
│  Project: <detected project name>       │
│  Stack:   <detected stack from Step 0>  │
│  Branch:  <current branch>              │
│  Phase:   <THINK|BUILD|OPTIMIZE|SHIP>   │
│  Health:  <tests passing/failing/none>  │
├─────────────────────────────────────────┤
│  Recommended next action:               │
│  → /godmode:<skill> — <reason>          │
│                                         │
│  Other options:                         │
│  → /godmode:<alt1> — <reason>           │
│  → /godmode:<alt2> — <reason>           │
└─────────────────────────────────────────┘
```

---

## Step 5: Skill Chaining — Auto-Transition Protocol

When a skill completes, do NOT stop and ask. Transition to the next skill in the active chain automatically. The user opted into godmode — they want the full pipeline.

### Predefined Chains

**Full lifecycle (default for new features):**
```
think → plan → build → review → test → optimize → secure → ship
```

**Bug resolution:**
```
debug → fix → test → verify
```

**Design-to-UI pipeline:**
```
uxdesign → wireframe → ui → designconsistency → visual
```

**PM-driven feature:**
```
pm → think → plan → build → test → ship
```

**Hardening pipeline:**
```
test → optimize → secure → loadtest → ship
```

**Refactor pipeline:**
```
review → refactor → test → verify
```

**API development:**
```
schema → api → test → apidocs → deploy
```

### Chain Execution Rules

1. **Auto-detect the chain.** Based on the entry skill and user intent, select the matching chain. If ambiguous, use the full lifecycle chain.
2. **Skip completed phases.** If tests already exist and pass, skip `test` in the chain. If a spec exists, skip `think`.
3. **Never ask "should I continue?"** between chain steps. Just transition. Print a one-line transition notice:
   ```
   ── chain: build ✓ → advancing to review ──
   ```
4. **Chain can be interrupted.** If the user types anything during execution, pause the chain, handle their request, and offer to resume.
5. **On failure, branch to error recovery** (see Error Recovery below), then resume the chain from the failed step.
6. **Custom chains** via flag: `--chain "build,test,optimize,ship"` to override the default.

---

## Step 6: Multi-Agent Orchestration Protocol

When the goal involves multiple independent tasks, default to multi-agent parallel execution. This section defines the EXACT protocol.

### When to Parallelize
- The goal decomposes into 2+ independent tasks
- The tasks touch different files or directories
- The user hasn't said "don't parallelize" or "just do it sequentially"

### Maximum Agents
- **Cap: 5 agents per round.** Never spawn more than 5 concurrent agents. If there are more tasks, queue them into subsequent rounds.
- **Minimum for parallel: 2 agents.** Don't spawn a single agent in isolation — just run it inline.

### Agent Dispatch — Exact Syntax

For each agent, use this exact Agent tool call format:

```
Tool: Agent
prompt: |
  You are working on: <one-sentence task description>

  ## Your Skill
  Read the file `skills/<skill-name>/SKILL.md` and follow its workflow exactly.

  ## Scope
  Files you should focus on:
  <list of file paths>

  ## Context
  Project stack: <detected stack>
  Test command: <test command>
  Lint command: <lint command>
  Build command: <build command>

  ## Task
  <detailed task description, 2-5 sentences>

  ## Completion Criteria
  - <criterion 1>
  - <criterion 2>
  - All tests pass: `<test command>`
  - No lint errors: `<lint command>`

  ## IMPORTANT
  - Commit your work with clear commit messages
  - Do NOT modify files outside your scope
  - If you are blocked, document what's blocking you in a comment and move on
```

### Prompt Construction Rules
1. **Always include the skill reference.** The agent must read the SKILL.md.
2. **Always scope the files.** Unbounded agents cause merge conflicts.
3. **Always include test/lint/build commands** from Step 0 detection.
4. **Include inter-agent context** if this agent depends on another's output: "Agent 1 will create the schema at `src/db/schema.ts`. Assume it exists with these types: ..."
5. **Keep prompts under 500 words.** Agents work better with focused instructions.

### Branch & Worktree Management

Each agent works in an isolated worktree. The orchestrator manages branches:

```bash
# Before dispatching round N, create branches from current HEAD
git branch wt-agent1-<short-task-name> HEAD
git branch wt-agent2-<short-task-name> HEAD

# Agents work in worktrees automatically via isolation: "worktree"
# After all agents in round complete, merge sequentially:

git checkout <main-working-branch>
git merge wt-agent1-<short-task-name> --no-edit
git merge wt-agent2-<short-task-name> --no-edit
git merge wt-agent3-<short-task-name> --no-edit

# Clean up
git branch -d wt-agent1-<short-task-name>
git branch -d wt-agent2-<short-task-name>
git branch -d wt-agent3-<short-task-name>
```

### Conflict Resolution Protocol

When `git merge` fails with conflicts:

1. **Check conflict scope.** Run `git diff --name-only --diff-filter=U` to list conflicted files.
2. **If conflicts are in different functions/sections** — resolve automatically by keeping both changes (most common case with well-scoped agents).
3. **If conflicts are semantic** (two agents modified the same function differently):
   - Abort the merge: `git merge --abort`
   - Read both versions of the conflicted file
   - Synthesize a merged version that preserves both agents' intent
   - Apply the synthesized version, commit, continue merging remaining branches
4. **If conflicts are irreconcilable** — keep the agent whose task had higher priority (earlier in the dependency graph), discard the other, and re-run the discarded agent on the post-merge state.

### Failed Agent Protocol

When an agent fails (errors out, doesn't complete, produces broken code):

1. **Check the agent's output** for error messages or partial work.
2. **If partial work is usable** — merge what's there, add remaining work to next round.
3. **If work is broken** — discard the branch: `git branch -D wt-failed-agent`
4. **Retry once** with a refined prompt that includes the error context:
   ```
   Previous attempt failed with: <error summary>
   Avoid: <what went wrong>
   ```
5. **If retry fails** — log the failure, skip this task, continue with remaining agents. Report it in the final summary.
6. **Never retry more than once.** Two failures means the task needs human input or decomposition.

### Execution Flow Diagram

```
Decompose goal into tasks
        │
        ▼
Group into rounds by dependency
        │
        ▼
┌─── Round 1 ───────────────────┐
│ Agent 1 ─┐                    │
│ Agent 2 ──┼── parallel exec   │
│ Agent 3 ─┘                    │
└───────────┬───────────────────┘
            ▼
     Merge all branches
     Resolve conflicts
     Run tests on merged result
            │
        ┌───┴───┐
        │ Pass? │
        └───┬───┘
       yes  │  no → fix inline, then continue
            ▼
┌─── Round 2 ───────────────────┐
│ Agent 4 ─┐                    │
│ Agent 5 ──┼── parallel exec   │
└───────────┬───────────────────┘
            ▼
     Merge, test, continue...
            │
            ▼
     Final verification
     (test + lint + build)
            │
            ▼
     Summary report
```

### Example Decomposition

```
User: /godmode Build a SaaS billing system with Stripe

GODMODE — Parallel Execution Plan
Round 1 (parallel — 3 agents):
  Agent 1: Design database schema    → skill: schema,  worktree: wt-schema
  Agent 2: Design API contracts       → skill: api,     worktree: wt-api
  Agent 3: Set up Stripe webhooks    → skill: webhook,  worktree: wt-webhook

Round 2 (parallel — 2 agents, depends on Round 1):
  Agent 4: Implement auth + RBAC     → skill: auth,    worktree: wt-auth
  Agent 5: Build payment endpoints   → skill: pay,     worktree: wt-pay

Round 3 (sequential, depends on Round 2):
  Agent 6: Write integration tests   → skill: integration
  Agent 7: Security audit            → skill: secure
```

### When to Use Single-Agent Instead
- Simple, focused tasks (one skill, one file)
- User explicitly says "don't parallelize" or "just do it"
- The task can't be meaningfully decomposed
- Only one skill in the active chain step

---

## Step 7: Single-Agent Fallback

For simple tasks that don't warrant decomposition:
- If the user confirms the recommendation, immediately invoke that skill
- If the user picks an alternative, invoke that instead
- If the user provides new context, re-evaluate from Step 1

---

## Autonomous Iteration — The Core Engine

Every Godmode skill that involves iterative work (optimize, fix, debug, build) runs the same autonomous loop engine inherited from autoresearch:

```
LOOP (FOREVER or N iterations):
  1. Review: Read current state + git history + results log
  2. Ideate: Pick next change based on goal and past results
  3. Modify: Make ONE focused change
  4. Commit: git commit BEFORE verification
  5. Verify: Run mechanical metric (tests, benchmark, etc.)
  6. Guard: Run guard command if set (tests must pass)
  7. Decide:
     - IMPROVED + guard passed → KEEP
     - IMPROVED + guard failed → Revert, rework (max 2 attempts)
     - SAME/WORSE → git reset --hard HEAD~1, DISCARD
     - CRASHED → Fix (max 3 attempts), else DISCARD
  8. Log: Append to .godmode/<skill>-results.tsv
  9. Track: Append to .godmode/session-log.tsv (see Results Tracking)
  10. Repeat: NEVER STOP. NEVER ASK "should I continue?"
```

**This is not a suggestion. This is the execution protocol.** Skills that skip the loop, skip commits, skip verification, or ask permission to continue are NOT running godmode — they're just generating text.

### Bounded Iterations

Add `Iterations: N` to any skill invocation to run exactly N iterations:
```
/godmode:optimize
Iterations: 20
```

After N iterations, print a final summary with baseline → current, keeps/discards/crashes.

---

## Continuous Loop Mode — `--loop`

When `--loop` is active, godmode becomes fully autonomous. It never stops. It never asks. It executes the full lifecycle until the project is done or the user interrupts.

### Loop Protocol

```
WHILE true:
  1. Run Step 0: Project Detection (once, cache result)
  2. Run Step 1: Auto-Skill Matching (if user gave a request)
  3. Run Step 2: Gather Context
  4. Run Step 3: Detect Phase
  5. Select skill chain based on phase (see Skill Chaining)
  6. Execute the entire chain:
     FOR each skill in chain:
       a. Print transition: ── loop: executing <skill> ──
       b. Run the skill (with autonomous iteration if applicable)
       c. Log result to .godmode/session-log.tsv
       d. IF skill fails → Error Recovery protocol
       e. IF skill succeeds → continue to next in chain
  7. After chain completes:
     a. Re-gather context (Step 2)
     b. Re-detect phase (Step 3)
     c. IF phase is SHIP and all checks pass → print DONE summary, exit loop
     d. IF new issues detected → select new chain, continue loop
     e. IF no new issues and not at SHIP → advance to next logical phase
  8. NEVER ask "should I continue?"
  9. NEVER pause between chain steps
  10. ONLY stop if:
      - All phases complete and project passes all checks
      - User interrupts
      - 3 consecutive chain failures (likely needs human input)
      - --loop=N was specified and N cycles have completed
```

### Loop Lifecycle

```
Start: User says "/godmode --loop Build a REST API for user management"

Cycle 1: THINK phase
  ── loop: executing think ──
  Produces spec in .godmode/spec.md
  ── loop: think ✓ → advancing to plan ──

Cycle 1: PLAN phase
  ── loop: executing plan ──
  Produces plan in .godmode/plan.md with 8 tasks
  ── loop: plan ✓ → advancing to build ──

Cycle 1: BUILD phase
  ── loop: executing build ──
  Implements all 8 tasks, commits each
  ── loop: build ✓ → advancing to review ──

Cycle 1: REVIEW phase
  ── loop: executing review ──
  Finds 3 issues, auto-files them
  ── loop: review ✓ → advancing to test ──

Cycle 1: TEST phase
  ── loop: executing test ──
  Generates tests, 2 fail
  ── loop: test ✓ (2 failures) → advancing to fix ──

Cycle 1: FIX phase
  ── loop: executing fix ──
  Fixes 2 failures via autonomous iteration
  ── loop: fix ✓ → advancing to optimize ──

Cycle 1: OPTIMIZE phase
  ── loop: executing optimize ──
  10 iterations, 6 kept, 4 discarded
  ── loop: optimize ✓ → advancing to secure ──

Cycle 1: SECURE phase
  ── loop: executing secure ──
  Finds 1 issue, auto-fixes
  ── loop: secure ✓ → advancing to ship ──

Cycle 1: SHIP phase
  ── loop: executing ship ──
  All checks pass. PR created.
  ── loop: COMPLETE ──

Session Summary: 8 skills executed, 22 commits, 1 PR created
```

---

## Results Tracking — `.godmode/session-log.tsv`

Every skill invocation is logged. This is mandatory — no exceptions.

### Log Format

File: `.godmode/session-log.tsv`

```tsv
timestamp	skill	duration_sec	outcome	detail
2025-01-15T14:30:00Z	think	45	success	spec created: .godmode/spec.md
2025-01-15T14:31:12Z	plan	72	success	8 tasks planned
2025-01-15T14:33:00Z	build	340	success	8 tasks implemented, 8 commits
2025-01-15T14:39:00Z	test	120	partial	14 tests generated, 2 failing
2025-01-15T14:41:00Z	fix	90	success	2 failures fixed in 3 iterations
2025-01-15T14:43:00Z	optimize	200	success	10 iterations: 6 kept, 4 discarded
2025-01-15T14:47:00Z	secure	60	success	1 vulnerability fixed
2025-01-15T14:48:00Z	ship	30	success	PR #42 created
```

### Logging Protocol

At the START of every skill execution:
```bash
echo -n "$(date -u +%Y-%m-%dT%H:%M:%SZ)\t<skill>\t" >> .godmode/session-log.tsv
```

At the END of every skill execution, append:
```bash
# Calculate duration from start timestamp
echo "<duration>\t<outcome>\t<detail>" >> .godmode/session-log.tsv
```

Outcomes: `success`, `partial`, `failed`, `skipped`

### `--status` Flag

When `--status` is invoked, read `.godmode/session-log.tsv` and present:

```
┌─────────────────────────────────────────────────┐
│  GODMODE — Session Status                       │
├─────────────────────────────────────────────────┤
│  Session started: 2025-01-15T14:30:00Z          │
│  Duration:        18 min                        │
│  Skills run:      8                             │
│  Commits made:    22                            │
│                                                 │
│  Skill Breakdown:                               │
│  ✓ think     (45s)   — spec created            │
│  ✓ plan      (72s)   — 8 tasks                 │
│  ✓ build     (340s)  — 8 commits               │
│  ✓ test      (120s)  — 14 tests, 2 failing     │
│  ✓ fix       (90s)   — 3 iterations            │
│  ✓ optimize  (200s)  — 6/10 kept               │
│  ✓ secure    (60s)   — 1 vuln fixed            │
│  ✓ ship      (30s)   — PR #42                  │
│                                                 │
│  Current phase: SHIPPED                         │
│  Next action:   none — project complete         │
└─────────────────────────────────────────────────┘
```

---

## Error Recovery Protocol

When a skill fails mid-execution, godmode does NOT crash. It recovers.

### Checkpoint Save

At the start of each skill execution, save a checkpoint:

File: `.godmode/checkpoint.json`
```json
{
  "skill": "build",
  "chain": ["think", "plan", "build", "review", "test", "optimize", "secure", "ship"],
  "chain_index": 2,
  "started_at": "2025-01-15T14:33:00Z",
  "branch": "feat/user-api",
  "last_commit": "a1b2c3d",
  "project_stack": "typescript",
  "test_cmd": "npx jest",
  "lint_cmd": "npx eslint . --fix",
  "build_cmd": "npx tsc --noEmit",
  "iteration": 5,
  "total_iterations": null,
  "context": {
    "plan_file": ".godmode/plan.md",
    "tasks_completed": [1, 2, 3, 4],
    "tasks_remaining": [5, 6, 7, 8]
  }
}
```

### `--resume` Flag

When user invokes `/godmode --resume`:

1. Read `.godmode/checkpoint.json`
2. Verify the branch and last commit still exist: `git log --oneline <last_commit> -1`
3. Restore context from the checkpoint
4. Resume the chain from `chain_index`, starting the failed skill from its last known state
5. Print:
   ```
   ── resuming from checkpoint: build (iteration 5) on feat/user-api ──
   ```

### `--rollback` Flag

When user invokes `/godmode --rollback`:

1. Read `.godmode/checkpoint.json`
2. Reset to the commit before the failed skill started:
   ```bash
   git reset --hard <last_commit>
   ```
3. Remove the checkpoint file
4. Print:
   ```
   ── rolled back to <last_commit> (before <skill> started) ──
   ```
5. Re-run phase detection and present the status card

### Automatic Recovery During `--loop`

When a skill fails during continuous loop mode:

1. Save checkpoint (automatic)
2. Attempt to fix the failure:
   - If tests fail → run `fix` skill for up to 3 iterations
   - If build fails → read error, make targeted fix, retry build
   - If lint fails → run lint with `--fix`, commit, retry
3. If fix succeeds → continue the chain
4. If fix fails after 3 attempts → log failure, skip to next skill in chain
5. If 3 consecutive skills fail → halt the loop, present status, ask for human input

---

## Key Behaviors

1. **Never guess — investigate.** Always run `git status`, `git log --oneline -10`, and check for test files before recommending.
2. **Bias toward action.** Don't just recommend — ask "Should I start X now?" and proceed on confirmation. In `--loop` mode, don't ask at all.
3. **Remember the full loop.** The ideal flow is THINK → PLAN → BUILD → REVIEW → TEST → OPTIMIZE → SECURE → SHIP. Nudge users toward completing the full cycle.
4. **Respect explicit requests.** If a user says "optimize this," don't redirect to THINK even if no spec exists. Honor their intent, but note what was skipped.
5. **Track phase transitions.** When transitioning between phases, summarize what was accomplished in the previous phase.
6. **Iterate autonomously.** When executing optimize/fix/debug, LOOP. Do not stop after one change. Do not ask for permission. Commit, verify, keep/revert, repeat.
7. **Log everything.** Every skill invocation hits `.godmode/session-log.tsv`. No exceptions.
8. **Detect the stack.** Never assume npm, pytest, or cargo. Detect from project files. Use the detected commands everywhere.
9. **Recover from failure.** Save checkpoints. Resume on `--resume`. Roll back on `--rollback`. Never lose work.
10. **Chain skills.** After one skill completes, auto-transition to the next. The user chose godmode — they want the full pipeline, not hand-holding.

---

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Auto-detect phase and recommend |
| `--status` | Show session status card with cumulative stats from `.godmode/session-log.tsv` |
| `--force <phase>` | Skip auto-detection, go directly to a phase |
| `--loop` | Enter continuous mode: execute full skill chains autonomously, never stop, never ask |
| `--loop=N` | Run continuous mode for N cycles, then stop and summarize |
| `--resume` | Resume from last checkpoint (`.godmode/checkpoint.json`) |
| `--rollback` | Roll back to the commit before the last failed skill |
| `--chain "<s1>,<s2>,..."` | Override the default skill chain with a custom sequence |
| `--parallel` | Force multi-agent parallel execution even for simple tasks |
| `--sequential` | Force single-agent sequential execution, no parallelism |
| `--stack <name>` | Override auto-detected project stack (e.g., `--stack rust`) |
| `--dry-run` | Show what godmode would do without executing anything |

---

## Example Usage

### Starting a new project
```
User: /godmode I want to build a rate limiter for our API

Godmode: Analyzing project state...
- Detected stack: TypeScript / Node (package.json + tsconfig.json)
- Test: npx jest | Lint: npx eslint . --fix | Build: npx tsc --noEmit
- No existing spec or plan found
- This is a new feature request

┌─────────────────────────────────────────┐
│  GODMODE — Status Assessment            │
├─────────────────────────────────────────┤
│  Project: api-rate-limiter              │
│  Stack:   TypeScript / Node             │
│  Branch:  main                          │
│  Phase:   THINK                         │
│  Health:  No tests yet                  │
├─────────────────────────────────────────┤
│  Recommended next action:               │
│  → /godmode:think — Design the rate     │
│    limiter before building it           │
│                                         │
│  Other options:                         │
│  → /godmode:plan — Skip to planning     │
│    if you already know the design       │
│  → /godmode:build — Jump straight to    │
│    code (not recommended)               │
└─────────────────────────────────────────┘

Shall I start the design session with /godmode:think?
```

### Natural language routing
```
User: /godmode make it faster

Godmode: Matched "make it faster" → optimize
- Detected stack: Rust (Cargo.toml)
- Test: cargo test | Build: cargo build --release
- Running optimization loop...

── executing optimize (autonomous iteration) ──
```

### Continuous loop mode
```
User: /godmode --loop Build a REST API for user management

Godmode: Entering continuous loop mode.
- Detected stack: Python (pyproject.toml + FastAPI)
- Test: pytest | Lint: ruff check --fix . | Build: n/a
- Chain: think → plan → build → review → test → optimize → secure → ship

── loop: executing think ──
...
── loop: think ✓ → advancing to plan ──
...
── loop: plan ✓ → advancing to build ──
[continues autonomously until complete]
```

### Mid-project check-in
```
User: /godmode

Godmode: Analyzing project state...
- Branch: feat/rate-limiter (12 commits)
- Tests: 8 passing, 3 failing
- Lint: clean
- Coverage: 64%

┌─────────────────────────────────────────┐
│  GODMODE — Status Assessment            │
├─────────────────────────────────────────┤
│  Project: api-rate-limiter              │
│  Stack:   TypeScript / Node             │
│  Branch:  feat/rate-limiter             │
│  Phase:   OPTIMIZE (fix)                │
│  Health:  3 tests failing               │
├─────────────────────────────────────────┤
│  Recommended next action:               │
│  → /godmode:fix — Fix 3 failing tests   │
│    before optimizing further            │
│                                         │
│  Other options:                         │
│  → /godmode:debug — Investigate root    │
│    cause of failures first              │
│  → /godmode:optimize — Ignore failures  │
│    and optimize passing code            │
└─────────────────────────────────────────┘
```

### Resuming after failure
```
User: /godmode --resume

Godmode: Loading checkpoint...
- Checkpoint found: build (iteration 5/8) on feat/user-api
- Last commit: a1b2c3d "implement task 4: validation middleware"
- Tasks remaining: 5, 6, 7, 8

── resuming from checkpoint: build (iteration 5) on feat/user-api ──
[continues building from task 5]
```

### Session status
```
User: /godmode --status

┌─────────────────────────────────────────────────┐
│  GODMODE — Session Status                       │
├─────────────────────────────────────────────────┤
│  Session started: 2025-01-15T14:30:00Z          │
│  Duration:        12 min                        │
│  Skills run:      5                             │
│  Commits made:    15                            │
│                                                 │
│  Skill Breakdown:                               │
│  ✓ think     (45s)   — spec created            │
│  ✓ plan      (72s)   — 8 tasks                 │
│  ✓ build     (340s)  — 8 commits               │
│  ◑ test      (120s)  — 14 tests, 2 failing     │
│  ✓ fix       (90s)   — 3 iterations            │
│                                                 │
│  Current phase: OPTIMIZE                        │
│  Next action:   /godmode:optimize               │
└─────────────────────────────────────────────────┘
```

---

## Anti-Patterns

- **Do NOT skip context gathering.** Never recommend a skill without checking git state and test state first.
- **Do NOT cycle between skills endlessly.** If you've recommended the same skill 3 times and the user hasn't made progress, ask what's blocking them.
- **Do NOT override explicit user intent.** If they say "ship it," don't insist on more optimization unless there are critical failures.
- **Do NOT present the status card for subcommands.** If the user says `/godmode:build`, go straight to the build skill — don't show the orchestrator card.
- **Do NOT skip project detection.** Always run Step 0. Never hardcode `npm test` when the project uses `cargo test`.
- **Do NOT spawn more than 5 agents.** Queue excess tasks into subsequent rounds.
- **Do NOT ignore the session log.** Every skill invocation must be logged. If the log doesn't exist, create it.
- **Do NOT leave broken state.** If a skill fails, save a checkpoint. If `--loop` is active, attempt auto-recovery before giving up.
- **Do NOT ask "should I continue?" in loop mode.** The user opted into autonomous execution. Respect that.
