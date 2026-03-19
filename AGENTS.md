# AGENTS.md — Godmode for AI Coding Agents

Godmode is a skill plugin with 165 specialized skills and 7 subagents that turn AI coding agents into disciplined engineers. Every change is measured, every bad change is reverted, and every experiment is committed.

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

**Usage pattern:**
1. Spawn `planner` to decompose a goal into rounds of parallel tasks
2. Spawn `explorer` to map the codebase before builders start
3. Spawn multiple `builder` agents in parallel (one per task, each following a skill)
4. Spawn `reviewer` to check each builder's work
5. Spawn `optimizer` to improve the merged result
6. Spawn `security` for a final audit before shipping

## Skill Catalog (165 Skills)

| Skill | Description |
|-------|-------------|
| `a11y` | Accessibility testing and auditing |
| `adr` | Architecture Decision Records |
| `agent` | AI agent development |
| `aiops` | AI Operations and safety |
| `analytics` | Analytics implementation |
| `angular` | Angular architecture |
| `animation` | Animation and motion design |
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
| `contract` | Contract testing |
| `cost` | Cloud cost optimization |
| `crypto` | Cryptography implementation |
| `ddd` | Domain-Driven Design |
| `debug` | Scientific debugging |
| `deploy` | Advanced deployment strategies |
| `designsystem` | Design system architecture |
| `desktop` | Desktop application development |
| `devsecops` | DevSecOps pipeline |
| `distributed` | Distributed systems design |
| `django` | Django and FastAPI development |
| `docker` | Docker mastery |
| `docs` | Documentation generation and maintenance |
| `dx` | Developer experience optimization |
| `e2e` | End-to-end testing |
| `edge` | Edge computing and serverless |
| `email` | Email and notification systems |
| `embeddings` | Embeddings and semantic search |
| `errorhandling` | Error handling architecture |
| `errortrack` | Error tracking and analysis |
| `estimate` | Effort estimation |
| `eval` | AI/LLM evaluation |
| `event` | Event-driven architecture |
| `extension` | Browser extension development |
| `fastapi` | FastAPI mastery |
| `finetune` | Model fine-tuning |
| `finish` | Branch finalization |
| `fix` | Autonomous error fixing |
| `forms` | Form architecture |
| `gamedev` | Game development |
| `gdpr` | GDPR deep compliance |
| `git` | Advanced Git workflows |
| `godmode` | Orchestrator (auto-routes to the right skill) |
| `graphql` | GraphQL API development |
| `grpc` | gRPC and Protocol Buffers |
| `hipaa` | HIPAA deep compliance |
| `i18n` | Internationalization and localization |
| `incident` | Incident response and post-mortem |
| `infra` | Infrastructure as Code |
| `integration` | Integration testing |
| `iot` | IoT and embedded systems |
| `k8s` | Kubernetes and container orchestration |
| `laravel` | Laravel mastery |
| `learn` | Learning and teaching |
| `legacy` | Legacy code modernization |
| `license` | License management |
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
| `multimodal` | Multimodal AI |
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
| `pair` | Pair programming assistance |
| `pattern` | Design pattern recommendation |
| `pay` | Payment and billing integration |
| `pentest` | Penetration testing |
| `perf` | Performance profiling and optimization |
| `pipeline` | Data pipeline and ETL |
| `plan` | Planning and task decomposition |
| `postgres` | PostgreSQL mastery |
| `pr` | Pull request excellence |
| `predict` | Multi-persona prediction and evaluation |
| `prioritize` | Task prioritization using structured frameworks |
| `prompt` | Prompt engineering |
| `pwa` | Progressive Web App |
| `quality` | Code quality and analysis |
| `query` | Query optimization and data analysis |
| `queue` | Message queue and job processing |
| `rag` | RAG (Retrieval-Augmented Generation) |
| `rails` | Ruby on Rails mastery |
| `rbac` | Permission and access control |
| `react` | React architecture |
| `realtime` | Real-time communication |
| `redis` | Redis architecture and design |
| `refactor` | Large-scale refactoring |
| `release` | Release management |
| `reliability` | Site reliability engineering |
| `report` | Report generation |
| `resilience` | System resilience |
| `responsive` | Responsive and adaptive design |
| `retro` | Retrospective and team health |
| `review` | Code review |
| `rfc` | RFC and technical proposal writing |
| `scaffold` | Code generation and scaffolding |
| `scale` | Scalability engineering |
| `scenario` | Edge case and scenario exploration |
| `schema` | Data modeling and schema design |
| `scope` | Scope management and MVP definition |
| `search` | Search implementation |
| `secrets` | Secrets management |
| `secure` | Security audit (STRIDE + OWASP + red-team) |
| `seo` | SEO optimization and auditing |
| `setup` | Configuration wizard |
| `ship` | Shipping workflow (preflight + deploy + verify) |
| `snapshot` | Snapshot and approval testing |
| `soc2` | SOC 2 deep compliance |
| `spring` | Spring Boot mastery |
| `standup` | Daily standup and progress tracking |
| `state` | State management design |
| `storage` | File storage and CDN |
| `svelte` | Svelte and SvelteKit mastery |
| `tailwind` | Tailwind CSS mastery |
| `terminal` | Terminal and shell productivity |
| `test` | TDD enforcement (red-green-refactor) |
| `think` | Brainstorming and design |
| `three` | 3D web development |
| `type` | Type system and schema validation |
| `ui` | UI component architecture |
| `unittest` | Unit testing mastery |
| `verify` | Evidence gate (prove it or revert it) |
| `visual` | Visual regression testing |
| `vscode` | IDE and editor configuration |
| `vue` | Vue.js mastery |
| `wasm` | WebAssembly development |
| `web3` | Blockchain and Web3 development |
| `webperf` | Web performance optimization |
