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

**Usage pattern (parallel platforms — Claude Code):**
1. Spawn `planner` to decompose a goal into rounds of parallel tasks
2. Spawn `explorer` to map the codebase before builders start
3. Spawn multiple `builder` agents in parallel (one per task, each following a skill)
4. Spawn `reviewer` to check each builder's work
5. Spawn `optimizer` to improve the merged result
6. Spawn `security` for a final audit before shipping

**Sequential platforms (Gemini CLI, OpenCode, Codex):**
Same workflow, but execute each agent role sequentially in the current session: plan → explore → build (one task at a time) → review (4 passes) → optimize (one experiment at a time). See `adapters/shared/sequential-dispatch.md` for the full protocol. Core skills include `## Platform Fallback` sections with specific instructions.

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
