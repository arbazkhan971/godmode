# AGENTS.md — Godmode for AI Coding Agents

Godmode is a skill plugin with 126 specialized skills and 7 subagents that turn AI coding agents into disciplined engineers. Every change is measured, every bad change is reverted, and every experiment is committed.

## Core Workflow: The Godmode Loop

```
THINK  -->  BUILD  -->  OPTIMIZE  -->  SHIP
```

1. **THINK** — Design first. Explore options, write a spec, pick an approach.
2. **BUILD** — TDD: write tests first, implement second, review third.
3. **OPTIMIZE** — Autonomous iteration loop: measure, hypothesize, modify, verify. Keep what improves, revert what doesn't.
4. **SHIP** — Preflight checks (tests, lint, security, types), deploy, monitor, verify.

## Key Principles

- **Mechanical verification over vibes.** Every claim must be backed by evidence: test output, benchmark numbers, or tool results. Never say "looks good" — prove it.
- **Git-as-memory.** Every experiment gets its own commit. Successful changes are kept. Failed changes are reverted. The git log is the audit trail.
- **Atomic changes.** One logical change per commit. Small, reviewable, reversible.
- **Automatic rollback.** If a change makes things worse (tests fail, performance degrades, errors increase), revert it immediately. No exceptions.

## How to Use Skills

When a user invokes a skill (e.g., `/godmode:secure`, `/godmode:test`, `/godmode:deploy`), **read the full skill file** at:

```
./skills/<skill-name>/SKILL.md
```

Follow the workflow defined in that file exactly. The SKILL.md contains activation triggers, step-by-step workflow, output format, and quality gates.

Example: if the user says `/godmode:secure`, read `./skills/secure/SKILL.md` and execute the security audit workflow defined there.

If the user says `/godmode` without a specific skill, read `./skills/godmode/SKILL.md` — the orchestrator will detect the right phase and route to the appropriate skills.

## Subagents (7 Built-in)

Godmode ships with 7 specialized subagents. Spawn them for complex tasks that benefit from parallel execution.

| Agent | Role | Mode |
|-------|------|------|
| **planner** | Decomposes goals into parallel tasks, maps each to a skill, builds dependency graph | Read-only |
| **builder** | Executes implementation tasks following a skill's workflow exactly | Read-write |
| **reviewer** | Reviews code for correctness, security, and skill adherence | Read-only |
| **optimizer** | Runs the autonomous measure → modify → verify → keep/revert loop | Read-write |
| **explorer** | Maps codebase structure, traces code paths, gathers context | Read-only |
| **security** | STRIDE + OWASP security audit with code evidence | Read-only |
| **tester** | Writes unit/integration/e2e tests following TDD | Read-write |

**Agent definitions:** `agents/*.md` (Claude Code), `.codex/agents/*.toml` (Codex)

Additional specialized reviewers (`code-reviewer.md`, `spec-reviewer.md`) are available for focused review tasks dispatched by the review and think skills respectively.

## Agent Capability Matrix

Each agent has explicit tool access constraints. Violations are bugs — agents must not exceed their granted permissions.

| Agent | Read | Write | Edit | Bash | Grep | Glob | Agent() | Worktree | Git |
|-------|------|-------|------|------|------|------|---------|----------|-----|
| **planner** | Yes | `.godmode/` only | No | Read-only | Yes | Yes | No | No | `log` only |
| **builder** | Yes | Yes | Yes | Yes | Yes | Yes | No | Yes | Yes |
| **reviewer** | Yes | `.godmode/` only | No | Test only | Yes | Yes | No | No | `log` only |
| **optimizer** | Yes | Yes | Yes | Yes | Yes | Yes | No | Yes | Yes |
| **explorer** | Yes | No | No | Read-only | Yes | Yes | No | No | `log` only |
| **security** | Yes | `.godmode/` only | No | Read-only | Yes | Yes | No | No | `log` only |
| **tester** | Yes | Test files only | Test files only | Yes | Yes | Yes | No | Yes | Yes |

**Key constraints:**

- **Read-only Bash** means the agent can run commands that inspect state (`ls`, `cat`, `find`, `wc`, `git log`, `git diff`) but must not run commands that modify state (`rm`, `mv`, `npm install`, `git commit`).
- **Test-only Bash** means the agent can run test suites (`npm test`, `pytest`, `go test`) and linters, but must not run build, deploy, or destructive commands.
- **`.godmode/` only Write** means the agent can write structured reports and plan files to the `.godmode/` directory but must not create or modify source files.
- **Test files only Write/Edit** means the agent can create and modify files in test directories (e.g., `__tests__/`, `*_test.go`, `*.spec.ts`) but must not touch production source files.
- **No Agent()** — subagents cannot spawn further subagents. Only the orchestrator dispatches agents. This prevents runaway recursion.
- **Worktree** access means the agent can use `EnterWorktree`/`ExitWorktree` for isolated execution on platforms that support it.
- **Git `log` only** means the agent can read git history (`git log`, `git show`, `git diff`) but must not create commits, branches, or tags.

## Agent Communication Protocol

Agents do not communicate with each other directly. All coordination flows through the orchestrator.

### Dispatch Flow

```
Orchestrator
    |
    +--> planner (produces execution plan)
    |        |
    |        v
    +--> explorer (produces codebase report)
    |        |
    |        v
    +--> builder x N (each produces a builder report)
    |        |
    |        v
    +--> reviewer (produces review verdict per builder)
    |        |
    |        v
    +--> optimizer (produces optimization log)
    |        |
    |        v
    +--> security (produces security audit)
    |
    v
Orchestrator merges results, resolves conflicts, ships
```

### Status Codes

Every agent must end its report with exactly one of these status codes:

| Status | Meaning | Orchestrator Action |
|--------|---------|---------------------|
| `DONE` | Task completed successfully, all gates passed | Proceed to next stage |
| `DONE_WITH_CONCERNS` | Task completed but agent flagged non-blocking issues | Proceed, but queue issues for follow-up |
| `NEEDS_CONTEXT` | Agent cannot proceed without additional information | Orchestrator provides missing context and re-dispatches |
| `BLOCKED` | Agent hit an unresolvable issue after max retries | Orchestrator logs the blocker, skips or re-queues the task |
| `PARTIAL` | Some subtasks completed, others failed or were skipped | Orchestrator keeps completed work, re-queues failures |

### Agent Input/Output Contract

**Input** — every agent receives a structured dispatch message from the orchestrator:

```
Task ID:      <unique identifier>
Agent Role:   <planner|builder|reviewer|optimizer|explorer|security|tester>
Skill:        <skill name to follow>
Scope:        <list of files/directories this agent may touch>
Context:      <output from previous agents — plans, reports, explorer maps>
Constraints:  <any additional restrictions for this task>
```

**Output** — every agent produces a structured report (format defined in each agent's `.md` file). The orchestrator parses these reports to decide next steps.

### Chaining Pattern

Agent outputs feed into subsequent agent inputs:

1. **planner output** (execution plan with rounds, tasks, file scopes) becomes **builder input** (each builder receives one task from the plan)
2. **explorer output** (codebase map, patterns, utilities) becomes **builder context** (builders use the map to find existing code to reuse)
3. **builder output** (changed files, commits, test results) becomes **reviewer input** (reviewer checks each builder's diff)
4. **reviewer output** (APPROVE / REQUEST_CHANGES / REJECT) triggers orchestrator decisions: approved work proceeds, rejected work is re-queued or discarded
5. **All agent outputs** feed into **optimizer input** (optimizer sees the merged result and runs improvement iterations)
6. **optimizer output** (final optimized state) becomes **security input** (security audits the final code)

## Multi-Agent Coordination Rules

### Concurrency Limits

- **Max 5 agents per round.** The orchestrator dispatches at most 5 parallel agents in a single round. This prevents resource exhaustion and keeps merge complexity manageable.
- **Max 3 rounds before checkpoint.** After 3 rounds of agent dispatches, the orchestrator must pause, review cumulative results, and decide whether to continue, adjust the plan, or ship.

### File Scoping

Each agent receives an explicit file scope in its dispatch message. Scoping rules:

- **No overlap**: two agents in the same round must not be assigned overlapping file scopes. The planner is responsible for partitioning work to avoid conflicts.
- **Scope enforcement**: if an agent discovers it needs to modify a file outside its scope, it must report `NEEDS_CONTEXT` to the orchestrator instead of making the change.
- **Shared read access**: all agents can read any file regardless of scope. Write scope is what gets restricted.

### Merge Order

When multiple agents complete work in the same round:

1. **Sequential merge** — agents' work is merged one at a time, in the order they were dispatched (not the order they finished).
2. **Test after each merge** — after merging each agent's work, run the full test suite. If tests fail, that agent's work is the cause.
3. **Fast-fail on conflict** — if merging agent B's work causes test failures, discard agent B's changes (revert the merge), log the conflict, and continue merging remaining agents.
4. **Re-queue discarded work** — discarded agent tasks are added to the next round with a note about why they failed, so the agent can try a different approach.

### Conflict Resolution

| Conflict Type | Resolution |
|---------------|------------|
| Two agents modified the same file | Discard the later agent's changes, re-queue its task |
| Agent's changes break existing tests | Revert the agent's commit, re-queue with failure context |
| Agent exceeds its file scope | Discard all out-of-scope changes, keep in-scope changes if they pass tests independently |
| Agent reports BLOCKED | Log the blocker, remove the task from the current cycle, surface to orchestrator for replanning |

## Platform-Specific Agent Behavior

### Claude Code (Parallel Execution)

Claude Code has native `Agent()` and `EnterWorktree`/`ExitWorktree` tools. Full parallel execution is supported.

**Dispatch pattern:**
1. Spawn `planner` agent to decompose a goal into rounds of parallel tasks
2. Spawn `explorer` agent to map the codebase before builders start
3. Spawn multiple `builder` agents in parallel (one per task, each in its own worktree, each following a skill)
4. Spawn `reviewer` agent to check each builder's work
5. Spawn `optimizer` agent to improve the merged result (uses worktree for each experiment)
6. Spawn `security` agent for a final audit before shipping

**Worktree usage:** builder and optimizer agents each get their own worktree via `EnterWorktree(task-name)`. This provides true filesystem isolation — agents cannot accidentally interfere with each other's work. After completion, worktrees are merged back to the base branch and cleaned up via `ExitWorktree`.

**Parallelism ceiling:** up to 5 agents in parallel per round. The orchestrator waits for all agents in a round to complete before starting the next round.

### Gemini CLI / OpenCode / Codex (Sequential Execution)

These platforms lack native `Agent()` and worktree tools. Execute the same workflow sequentially in a single session.

**Dispatch pattern:**
1. Run the planner role: decompose the goal into tasks
2. Run the explorer role: map the codebase
3. Run each builder task one at a time: implement, test, commit, then move to the next
4. Run the reviewer role: 4 review passes (Correctness, Security, Performance, Style) executed sequentially
5. Run the optimizer role: one experiment at a time (try, measure, keep or revert)
6. Run the security role: final audit

**Worktree replacement:** use branch-based isolation instead. Create a `godmode-{task-name}` branch for each task, do the work, merge back to the base branch. See `adapters/shared/sequential-dispatch.md` for the full protocol.

**Performance impact:** sequential execution is slower (roughly proportional to the number of parallel agents replaced) but produces identical results. Verification logic, rollback behavior, output format, and decision criteria are unchanged.

### Cursor (Background Agents with File Scoping)

Cursor supports background agents with its own dispatch model. Godmode adapts as follows:

**Dispatch pattern:**
1. Use Cursor's background agent capability to run builder tasks concurrently
2. Each background agent receives strict file scoping — Cursor enforces that agents only modify their assigned files
3. The orchestrator polls for completion and merges results in dispatch order
4. Review and security passes run in the foreground after all builders complete

**Limitations:** Cursor background agents do not support worktree isolation. File scoping is the primary isolation mechanism. The orchestrator must be extra careful about file scope partitioning to prevent conflicts.

## Skill Catalog (126 Skills)

| Skill | Description |
|-------|-------------|
| `a11y` | Accessibility testing and auditing |
| `agent` | AI agent development |
| `analytics` | Analytics implementation |
| `angular` | Angular architecture |
| `api` | API design and specification |
| `architect` | Software architecture |
| `auth` | Authentication and authorization |
| `automate` | Task automation |
| `backup` | Backup and disaster recovery |
| `build` | Build and execution (TDD enforcement) |
| `cache` | Caching strategy |
| `changelog` | Changelog and release notes management |
| `chaos` | Chaos engineering |
| `chart` | Data visualization |
| `cicd` | CI/CD pipeline design |
| `cli` | CLI tool development |
| `comply` | Compliance and governance |
| `concurrent` | Concurrency and parallelism |
| `config` | Environment and configuration management |
| `cost` | Cloud cost optimization |
| `crypto` | Cryptography implementation |
| `ddd` | Domain-Driven Design |
| `debug` | Scientific debugging |
| `deploy` | Advanced deployment strategies |
| `designsystem` | Design system architecture |
| `devsecops` | DevSecOps pipeline |
| `distributed` | Distributed systems design |
| `django` | Django and FastAPI development |
| `docker` | Docker mastery |
| `docs` | Documentation generation and maintenance |
| `e2e` | End-to-end testing |
| `edge` | Edge computing and serverless |
| `email` | Email and notification systems |
| `eval` | AI/LLM evaluation |
| `event` | Event-driven architecture |
| `fastapi` | FastAPI mastery |
| `finish` | Branch finalization |
| `fix` | Autonomous error fixing |
| `forms` | Form architecture |
| `git` | Advanced Git workflows |
| `godmode` | Orchestrator (auto-routes to the right skill) |
| `graphql` | GraphQL API development |
| `grpc` | gRPC and Protocol Buffers |
| `i18n` | Internationalization and localization |
| `incident` | Incident response and post-mortem |
| `infra` | Infrastructure as Code |
| `integration` | Integration testing |
| `k8s` | Kubernetes and container orchestration |
| `laravel` | Laravel mastery |
| `legacy` | Legacy code modernization |
| `lint` | Linting and code standards |
| `loadtest` | Load testing and performance testing |
| `logging` | Logging and structured logging |
| `micro` | Microservices design and management |
| `migrate` | Database migration and schema management |
| `migration` | System migration |
| `ml` | ML development and experimentation |
| `mlops` | MLOps and model deployment |
| `mobile` | Mobile app development |
| `monorepo` | Monorepo management |
| `network` | Network and DNS |
| `nextjs` | Next.js mastery |
| `node` | Node.js backend development |
| `nosql` | NoSQL database design |
| `npm` | Package management |
| `observe` | Monitoring and observability |
| `onboard` | Codebase onboarding |
| `opensource` | Open source project management |
| `optimize` | Autonomous iteration loop (the heart of Godmode) |
| `orm` | ORM and data access optimization |
| `pattern` | Design pattern recommendation |
| `pay` | Payment and billing integration |
| `pentest` | Penetration testing |
| `perf` | Performance profiling and optimization |
| `pipeline` | Data pipeline and ETL |
| `plan` | Planning and task decomposition |
| `postgres` | PostgreSQL mastery |
| `pr` | Pull request excellence |
| `predict` | Multi-persona prediction and evaluation |
| `prompt` | Prompt engineering |
| `query` | Query optimization and data analysis |
| `queue` | Message queue and job processing |
| `rag` | RAG (Retrieval-Augmented Generation) |
| `rails` | Ruby on Rails mastery |
| `rbac` | Permission and access control |
| `react` | React architecture |
| `realtime` | Real-time communication |
| `redis` | Redis architecture and design |
| `refactor` | Large-scale refactoring |
| `reliability` | Site reliability engineering |
| `resilience` | System resilience |
| `responsive` | Responsive and adaptive design |
| `review` | Code review |
| `rfc` | RFC and technical proposal writing |
| `scale` | Scalability engineering |
| `scenario` | Edge case and scenario exploration |
| `schema` | Data modeling and schema design |
| `search` | Search implementation |
| `secrets` | Secrets management |
| `secure` | Security audit (STRIDE + OWASP + red-team) |
| `seo` | SEO optimization and auditing |
| `setup` | Configuration wizard |
| `ship` | Shipping workflow (preflight + deploy + verify) |
| `spring` | Spring Boot mastery |
| `state` | State management design |
| `storage` | File storage and CDN |
| `svelte` | Svelte and SvelteKit mastery |
| `tailwind` | Tailwind CSS mastery |
| `test` | TDD enforcement (red-green-refactor) |
| `think` | Brainstorming and design |
| `type` | Type system and schema validation |
| `ui` | UI component architecture |
| `verify` | Evidence gate (prove it or revert it) |
| `vue` | Vue.js mastery |
| `webperf` | Web performance optimization |
| `apidocs` | OpenAPI/Swagger documentation generation |
| `cron` | Scheduled tasks and job queue management |
| `experiment` | A/B testing and statistical analysis |
| `feature` | Feature flags and gradual rollouts |
| `ghactions` | GitHub Actions workflow design and optimization |
| `notify` | Push, SMS, and in-app notifications |
| `ratelimit` | Rate limiting algorithms and middleware |
| `seed` | Database seeding and factory patterns |
| `slo` | SLO/SLI definition and error budget tracking |
| `upload` | File uploads and media processing |
| `webhook` | Webhook design, delivery, and retry logic |
