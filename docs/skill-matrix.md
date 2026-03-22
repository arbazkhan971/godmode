# Skill Matrix — Which Skill Do I Use?

The definitive reference for picking the right Godmode skill. 126 skills across 11 categories.

---

## 1. Quick Lookup: "I want to..." → Skill

| I want to... | Use this skill | Why not... |
|---|---|---|
| Make my app faster | `optimize` | Not `perf` — perf profiles and diagnoses, optimize iterates and commits improvements |
| Fix broken tests | `fix` | Not `debug` — debug investigates root cause, fix remediates in a loop |
| Find out why something is broken | `debug` | Not `fix` — fix applies changes, debug finds the root cause first |
| Add a new feature | `build` | Not `plan` — plan decomposes into tasks, build executes them with agents |
| Break down a large feature | `plan` | Not `think` — think explores approaches and writes a spec, plan produces tasks |
| Check for security holes | `secure` | Not `pentest` — pentest is active exploitation, secure is STRIDE+OWASP audit |
| Actively exploit vulnerabilities | `pentest` | Not `secure` — secure audits and reports, pentest attempts real exploitation |
| Deploy to production | `ship` | Not `deploy` — deploy designs strategies (blue-green, canary), ship executes the checklist |
| Design a deployment strategy | `deploy` | Not `ship` — ship runs a pre-flight checklist and pushes, deploy plans rollout mechanics |
| Brainstorm an approach | `think` | Not `predict` — think explores and writes a spec, predict evaluates an existing spec |
| Evaluate a design before building | `predict` | Not `scenario` — scenario finds edge cases, predict has 5 expert personas vote go/no-go |
| Explore edge cases and failure modes | `scenario` | Not `predict` — predict evaluates overall viability, scenario enumerates 12 failure dimensions |
| Write tests for my code | `test` | Not `e2e` — test does unit/integration via TDD, e2e is browser-level end-to-end |
| Write end-to-end browser tests | `e2e` | Not `test` — test is RED-GREEN-REFACTOR for unit tests, e2e tests full user flows |
| Get a code review | `review` | Not `lint` — lint checks style rules, review is 4-agent correctness+security+perf+style |
| Improve code structure | `refactor` | Not `optimize` — optimize improves measurable metrics, refactor restructures for clarity |
| Set up the project for Godmode | `setup` | Not `config` — config is for app configuration management, setup initializes .godmode/ |
| Finish a feature branch | `finish` | Not `ship` — ship deploys, finish validates and merges/PRs the branch |
| Prove a claim with evidence | `verify` | Not `test` — test writes test cases, verify runs a command and checks pass/fail |
| Design system architecture | `architect` | Not `pattern` — pattern selects design patterns, architect designs full system structure |
| Write an RFC/technical proposal | `rfc` | Not `think` — think produces a spec for immediate build, rfc writes a formal proposal for team review |
| Profile CPU or memory usage | `perf` | Not `optimize` — optimize makes iterative improvements, perf produces flame graphs and profiles |
| Optimize web page load time | `webperf` | Not `perf` — perf is backend profiling, webperf focuses on Core Web Vitals and browser metrics |
| Load test my API | `loadtest` | Not `perf` — perf profiles a single process, loadtest hammers the system with concurrent requests |
| Set up CI/CD | `cicd` | Not `ghactions` — ghactions is GitHub Actions specifically, cicd covers all CI/CD platforms |
| Create GitHub Actions workflows | `ghactions` | Not `cicd` — cicd is platform-agnostic, ghactions generates `.github/workflows/` files |
| Containerize my app | `docker` | Not `k8s` — k8s orchestrates containers, docker builds and configures them |
| Orchestrate containers in production | `k8s` | Not `docker` — docker builds images, k8s deploys and scales them |
| Add authentication | `auth` | Not `rbac` — rbac designs role/permission models, auth implements login/signup/session flows |
| Add role-based permissions | `rbac` | Not `auth` — auth handles identity (who you are), rbac handles authorization (what you can do) |
| Add caching | `cache` | Not `redis` — redis is a specific tool, cache designs the caching strategy (what, where, TTL) |
| Design a REST API | `api` | Not `graphql` — api is REST-specific, graphql is for GraphQL schemas |
| Add real-time features | `realtime` | Not `event` — event is backend event-driven architecture, realtime is WebSocket/SSE to clients |
| Add payment processing | `pay` | Not `api` — api is generic REST, pay specifically handles Stripe/payment integration |
| Manage database migrations | `migrate` | Not `migration` — migration is system-level migration, migrate is database schema migration |
| Migrate to a new system | `migration` | Not `migrate` — migrate handles DB schema changes, migration handles full system rewrites |
| Set up observability | `observe` | Not `logging` — logging is structured log output, observe covers metrics+traces+logs together |

---

## 2. Core Skills Matrix

The 15 core workflow skills and their properties.

| Skill | Mode | Loop Type | Modifies Code? | Multi-Agent? | Needs Prior Skill? | Human Input | Typical Runtime |
|---|---|---|---|---|---|---|---|
| `godmode` | Router | One-shot | No | No | None | Natural language request | Seconds |
| `think` | Sequential | One-shot | Yes (spec) | No | None | Goal description | 2-5 min |
| `predict` | Parallel personas | Multi-agent | No | Yes (5 personas) | `think` (spec.md) | None | 1-3 min |
| `scenario` | Sequential | One-shot | Yes (test skeletons) | No | `think` (spec.md) | None | 3-5 min |
| `plan` | Sequential | One-shot | Yes (plan.yaml) | No | `think` (spec.md) | None | 1-3 min |
| `build` | Iterative loop | Autonomous | Yes | Yes (up to 5 agents) | `plan` (plan.yaml) | None | 5-30 min |
| `test` | Iterative loop | Autonomous | Yes (tests) | No | None | Coverage target | 3-15 min |
| `review` | Parallel agents | Multi-agent | Yes (NIT auto-fix) | Yes (4 agents) | None | None | 2-5 min |
| `optimize` | Iterative loop | Autonomous | Yes | Yes (3 agents/round) | Metric command | Metric + guard cmd | 5-60 min |
| `debug` | Iterative loop | Autonomous | Minimal (logs) | No | Failing test/error | None | 3-15 min |
| `fix` | Iterative loop | Autonomous | Yes | No | Error output | None | 2-20 min |
| `ship` | Sequential checklist | One-shot | No (triggers external) | No | Passing checks | Confirm dry-run | 2-5 min |
| `finish` | Sequential | One-shot | Yes (merge/squash) | No | Commits on branch | Mode selection | 1-2 min |
| `setup` | Sequential wizard | One-shot | Yes (config) | No | None | Stack confirmation | 1-3 min |
| `verify` | Single-shot | One-shot | No | No | A claim to verify | Claim + command | Seconds |

### Loop Type Legend

| Loop Type | Meaning | Skills |
|---|---|---|
| **Autonomous** | Runs in a WHILE loop with automatic keep/revert decisions. Terminates on target met, max iterations, or diminishing returns. No human input needed per iteration. | `build`, `test`, `optimize`, `debug`, `fix` |
| **Multi-agent** | Dispatches multiple agents (parallel on Claude Code/Cursor, sequential elsewhere). Each agent runs independently; results merge deterministically. | `predict` (5 personas), `review` (4 passes), `build` (5 agents/round), `optimize` (3 agents/round) |
| **One-shot** | Runs once from start to finish. No iteration loop. May have internal steps but does not repeat them. | `godmode`, `think`, `scenario`, `plan`, `ship`, `finish`, `setup`, `verify` |

Note: Some skills appear in multiple categories. `build` and `optimize` are both autonomous (iterative loop) and multi-agent (parallel dispatch within each iteration). On sequential platforms, the multi-agent aspect degrades to sequential dispatch but the autonomous loop still runs.

### Core Pipeline Flow

```
think → predict → plan → build → test → review → fix → optimize → secure → ship → finish
  |        |                                  |       |
  |   (gate: <7 → rethink)              (fix loop)  (fix loop)
  |                                           |       |
  +-- scenario (edge cases, any time) --------+-------+
```

---

## 3. Category Deep-Dives

### Architecture and Design (10 skills)

| Skill | Focus | Output | Read-Only? |
|---|---|---|---|
| `architect` | Full system architecture, C4 diagrams | ADRs, diagrams | Yes |
| `rfc` | Technical proposals for team review | RFC document | Yes |
| `ddd` | Domain-Driven Design, bounded contexts | Context maps, aggregates | Yes |
| `pattern` | Design pattern selection | Pattern recommendation + code | Yes |
| `schema` | Database and API schema design | Schema definitions | Yes |
| `concurrent` | Thread safety, async patterns | Concurrency design | Yes |
| `distributed` | Distributed systems (consensus, partitioning) | System design | Yes |
| `scale` | Scalability engineering | Scaling plan | Yes |
| `legacy` | Legacy code modernization strategy | Migration plan | Yes |
| `migration` | Full system migration | Migration runbook | Yes |

**When to use each:** Start with `architect` for greenfield systems. Use `ddd` when domain complexity is high. Use `pattern` when you know you need a pattern but not which one. Use `schema` early for data-heavy apps. Use `scale` when you are hitting limits. Use `legacy` and `migration` for existing systems that need modernization.

**Common combos:** `architect` then `schema` then `plan` then `build`. For rewrites: `legacy` then `migration` then `architect`.

---

### API and Backend (14 skills)

| Skill | Focus | Modifies Code? |
|---|---|---|
| `api` | REST API design and implementation | Yes |
| `graphql` | GraphQL schema, resolvers, DataLoader | Yes |
| `grpc` | gRPC service definitions and stubs | Yes |
| `orm` | ORM setup, model definitions, query patterns | Yes |
| `query` | SQL/query optimization (EXPLAIN, indexes) | Yes |
| `cache` | Caching strategy (what, where, TTL, invalidation) | Yes |
| `queue` | Message queues, job processing (BullMQ, Celery) | Yes |
| `event` | Event-driven architecture, pub/sub | Yes |
| `realtime` | WebSocket, SSE, real-time sync | Yes |
| `edge` | Edge computing, CDN, edge functions | Yes |
| `micro` | Microservices decomposition, service mesh | Yes |
| `search` | Full-text search (Elasticsearch, Typesense) | Yes |
| `ratelimit` | Rate limiting strategies and implementation | Yes |
| `webhook` | Webhook design, delivery, retry logic | Yes |

**How they differ:** `api` vs `graphql` vs `grpc` is protocol choice. `orm` vs `query` — orm sets up models, query optimizes existing queries. `cache` vs `redis` — cache designs strategy, redis implements it in Redis specifically. `queue` vs `event` — queue is task/job processing, event is pub/sub domain events. `realtime` vs `webhook` — realtime is persistent connections to clients, webhook is server-to-server HTTP callbacks.

**Common combos:** `api` + `cache` + `ratelimit` for a typical REST service. `graphql` + `query` + `cache` for data-heavy APIs. `queue` + `event` for async processing pipelines.

---

### Frameworks (12 skills)

| Skill | Framework | Language | Pairs Well With |
|---|---|---|---|
| `react` | React | JavaScript/TypeScript | `nextjs`, `state`, `tailwind` |
| `nextjs` | Next.js | TypeScript | `react`, `tailwind`, `api` |
| `vue` | Vue.js | JavaScript/TypeScript | `tailwind`, `state` |
| `svelte` | SvelteKit | JavaScript/TypeScript | `tailwind` |
| `angular` | Angular | TypeScript | `state`, `forms` |
| `node` | Node.js | JavaScript/TypeScript | `api`, `queue`, `docker` |
| `fastapi` | FastAPI | Python | `api`, `postgres`, `docker` |
| `django` | Django | Python | `postgres`, `auth`, `api` |
| `rails` | Ruby on Rails | Ruby | `postgres`, `redis`, `deploy` |
| `laravel` | Laravel | PHP | `postgres`, `queue`, `auth` |
| `spring` | Spring Boot | Java/Kotlin | `postgres`, `k8s`, `grpc` |
| `tailwind` | Tailwind CSS | CSS | Any frontend framework skill |

**When to use:** Use the framework skill for framework-specific architecture decisions, project structure, and idiomatic patterns. These are not "install framework" skills — they guide how to structure and build within the framework.

---

### Databases (3 skills)

| Skill | Database | When to Use |
|---|---|---|
| `postgres` | PostgreSQL | Relational data, ACID, JSON support, full-text search |
| `redis` | Redis | Caching, sessions, pub/sub, rate limiting, queues |
| `nosql` | MongoDB, DynamoDB, etc. | Document stores, wide-column, key-value at scale |

**How they differ:** `postgres` for structured relational data. `redis` for ephemeral/fast-access data. `nosql` when schema flexibility or horizontal scaling is the priority. Use `schema` first if unsure about your data model.

---

### Security and Compliance (8 skills)

| Skill | Scope | Destructive? | Needs Auth? |
|---|---|---|---|
| `secure` | STRIDE + OWASP audit (16 categories x 4 personas) | Optional (--fix) | No |
| `auth` | Authentication flows (JWT, OAuth, sessions) | Yes | No |
| `rbac` | Role-based access control, permissions | Yes | No |
| `secrets` | Secrets management (vaults, env vars, rotation) | Yes | No |
| `crypto` | Cryptographic review (hashing, encryption, TLS) | Read-only | No |
| `pentest` | Active penetration testing with real payloads | Read-only (reports) | Yes (authorization required) |
| `devsecops` | Security pipeline integration (SAST, DAST, SCA) | Yes (CI config) | No |
| `comply` | Compliance frameworks (GDPR, HIPAA, SOC 2) | Read-only (gap analysis) | No |

**Progression:** `secure` (find issues) then `pentest` (validate exploitability) then `fix` (remediate) then `devsecops` (prevent recurrence). Use `auth` and `rbac` during build. Use `comply` before launch.

---

### Testing (7 skills)

| Skill | Type | Iterative? | Output |
|---|---|---|---|
| `e2e` | End-to-end browser tests | No | Test files (Playwright/Cypress) |
| `integration` | Integration tests (DB, API) | No | Test files |
| `loadtest` | Load/stress testing | No | Load test scripts + reports |
| `lint` | Linter setup, custom rules | No | Config files + custom rules |
| `type` | Type system design (TypeScript, mypy) | No | Type definitions |
| `perf` | Performance profiling (CPU, memory, concurrency) | No | Profile reports + fixes |
| `webperf` | Web Vitals (LCP, FID, CLS) | No | Performance audit + fixes |

**How they differ from core `test`:** The core `test` skill runs a TDD loop targeting coverage. These 7 skills are specialized. `e2e` tests user flows in a browser. `integration` tests service boundaries. `loadtest` tests under concurrency. `perf` profiles runtime behavior. `webperf` measures browser metrics.

**Common combos:** `test` (unit) + `integration` + `e2e` for full test pyramid. `perf` then `optimize` for performance work. `webperf` + `optimize` for frontend speed.

---

### DevOps and Infrastructure (16 skills)

| Skill | Focus | Modifies Code? |
|---|---|---|
| `deploy` | Deployment strategies (blue-green, canary, rollback) | Yes (manifests) |
| `k8s` | Kubernetes manifests, Helm, operators | Yes |
| `infra` | Infrastructure as Code (Terraform, Pulumi, CDK) | Yes |
| `cicd` | CI/CD pipeline design (platform-agnostic) | Yes |
| `ghactions` | GitHub Actions workflows specifically | Yes |
| `pipeline` | Data or build pipelines | Yes |
| `docker` | Dockerfiles, compose, multi-stage builds | Yes |
| `backup` | Backup strategy, disaster recovery | Yes (scripts/config) |
| `incident` | Incident response runbooks | Read-only (runbooks) |
| `observe` | Observability stack (metrics, traces, logs) | Yes |
| `logging` | Structured logging implementation | Yes |
| `network` | Network configuration, DNS, load balancers | Yes (config) |
| `resilience` | Circuit breakers, retries, bulkheads | Yes |
| `config` | Configuration management (env vars, feature config) | Yes |
| `cost` | Cloud cost optimization | Read-only (recommendations) |
| `cron` | Scheduled tasks, cron jobs | Yes |

**How they differ:** `deploy` designs the rollout strategy. `ship` executes it. `cicd` designs the pipeline. `ghactions` writes the YAML for GitHub specifically. `docker` builds the container. `k8s` orchestrates it. `observe` sets up the dashboards. `logging` instruments the code.

**Common combos:** `docker` + `k8s` + `deploy` for containerized production. `cicd` + `ghactions` + `docker` for CI. `observe` + `logging` + `resilience` for production reliability.

---

### Frontend and UI (9 skills)

| Skill | Focus | Output |
|---|---|---|
| `ui` | Component design, composition patterns | Components |
| `a11y` | Accessibility audit (WCAG 2.1) | Audit report + fixes |
| `seo` | SEO optimization (meta, structured data, performance) | SEO improvements |
| `mobile` | Mobile development (React Native, Flutter) | Mobile code |
| `chart` | Data visualization (D3, Chart.js, Recharts) | Chart components |
| `state` | State management (Redux, Zustand, Pinia, signals) | State architecture |
| `designsystem` | Design system (tokens, component library) | Design system code |
| `forms` | Form architecture (validation, multi-step, submission) | Form components |
| `responsive` | Responsive design (breakpoints, fluid layouts) | Responsive CSS/code |

**Common combos:** `ui` + `designsystem` + `a11y` for component libraries. `forms` + `state` for data-heavy UIs. `chart` + `responsive` for dashboards.

---

### AI and ML (5 skills)

| Skill | Focus | Output |
|---|---|---|
| `ml` | ML pipeline design (training, evaluation, serving) | Pipeline code |
| `mlops` | Model deployment, monitoring, A/B testing | Infrastructure config |
| `rag` | Retrieval-Augmented Generation (embeddings, vector DB) | RAG pipeline |
| `prompt` | Prompt engineering (few-shot, chain-of-thought) | Prompt templates |
| `eval` | LLM evaluation (benchmarks, regression testing) | Eval harness |

**Progression:** `prompt` (design prompts) then `eval` (measure quality) then `rag` (add retrieval) then `ml` (train custom models) then `mlops` (deploy and monitor).

---

### Developer Experience (13 skills)

| Skill | Focus | Modifies Code? |
|---|---|---|
| `docs` | Documentation (guides, API docs, READMEs) | Yes |
| `onboard` | Developer onboarding guides | Yes (docs) |
| `refactor` | Safe large-scale code restructuring | Yes |
| `git` | Git workflow automation (branching, hooks) | Yes (config) |
| `pr` | Pull request management and templates | Yes |
| `monorepo` | Monorepo setup (Turborepo, Nx, workspaces) | Yes |
| `npm` | Package management, publishing, versioning | Yes |
| `changelog` | Changelog generation from commits | Yes |
| `opensource` | Open source project setup (LICENSE, CONTRIBUTING) | Yes |
| `analytics` | Analytics instrumentation (events, funnels) | Yes |
| `apidocs` | OpenAPI/Swagger documentation | Yes |
| `reliability` | SRE practices (error budgets, toil reduction) | Yes |
| `slo` | SLO/SLI definition and monitoring | Yes |

---

### Integrations (14 skills)

| Skill | Focus | Modifies Code? |
|---|---|---|
| `i18n` | Internationalization (locales, plurals, RTL) | Yes |
| `email` | Email templates and delivery (MJML, SendGrid) | Yes |
| `pay` | Payment integration (Stripe, webhooks, invoicing) | Yes |
| `cli` | CLI tool development (args, help, output) | Yes |
| `automate` | Task automation (scripts, workflows) | Yes |
| `migrate` | Database migrations (schema changes, data transforms) | Yes |
| `storage` | File storage (S3, blob, signed URLs) | Yes |
| `agent` | AI agent design (tool use, memory, planning) | Yes |
| `feature` | Feature flags (LaunchDarkly, Unleash, custom) | Yes |
| `notify` | Push/SMS/in-app notifications | Yes |
| `experiment` | A/B testing and experimentation | Yes |
| `seed` | Database seeding (dev data, fixtures) | Yes |
| `upload` | File uploads (multipart, validation, processing) | Yes |
| `chaos` | Chaos engineering (failure injection, game days) | Yes |

---

## 4. Skill Properties Legend

| Property | Meaning |
|---|---|
| **Iterative** | Runs in a WHILE loop: review, modify, verify, decide, repeat. Auto-terminates on target/diminishing returns. Skills: `optimize`, `fix`, `debug`, `test`, `build`. |
| **Sequential** | Runs steps in order, one pass. No loop. Skills: `think`, `plan`, `ship`, `setup`, `finish`, `verify`. |
| **Multi-Agent** | Dispatches parallel agents in isolated git worktrees. Falls back to sequential on platforms without Agent support. Skills: `build` (5 agents), `optimize` (3 agents), `review` (4 agents), `predict` (5 personas). |
| **Modifies Code** | Creates or edits source files and commits. Most skills do this. Notable exceptions: `verify` (read-only), `godmode` (router), `predict` (evaluates only), `cost` (recommends), `comply` (audits). |
| **Read-Only** | Analyzes code/system without changing anything. Output is a report, not a commit. Skills: `verify`, `predict`, `cost`, `comply`, `crypto`, `incident`, `pentest` (reports only). |
| **Destructive** | May revert commits (`git reset --hard HEAD~1`). This is intentional — bad changes get rolled back automatically. Skills: `optimize`, `fix`, `debug`, `build`. Always safe: every revert undoes a commit made seconds earlier. |
| **Needs Prior Skill** | Requires output from another skill. `plan` needs `think` (spec.md). `build` needs `plan` (plan.yaml). `predict` needs `think` (spec.md). Other skills can run standalone. |
| **Human Input** | What the user must provide. Ranges from "nothing" (auto-detected) to "confirm dry-run" (`ship`) to "metric command" (`optimize`). |
| **Platform** | All 126 skills work on all platforms. Multi-agent skills auto-degrade to sequential on platforms without agent dispatch (Gemini CLI, OpenCode). |

---

## 5. Framework/Stack Routing

Use this table to find the right starting skills for your technology stack.

| Your Stack | Start With | Then Add | Key Workflow Skills | DB Skills |
|---|---|---|---|---|
| Next.js + Tailwind | `nextjs` | `react`, `tailwind`, `state` | `test`, `optimize`, `ship` | `postgres` |
| React SPA | `react` | `tailwind`, `state`, `ui` | `test`, `e2e`, `webperf` | N/A (API backend) |
| Vue.js + Nuxt | `vue` | `tailwind`, `state`, `ui` | `test`, `e2e`, `webperf` | `postgres` |
| SvelteKit | `svelte` | `tailwind`, `ui` | `test`, `e2e`, `ship` | `postgres` |
| Angular | `angular` | `tailwind`, `state`, `forms` | `test`, `e2e`, `lint` | N/A (API backend) |
| FastAPI + PostgreSQL | `fastapi` | `api`, `postgres`, `auth` | `test`, `secure`, `docker` | `postgres`, `redis` |
| Django | `django` | `postgres`, `auth`, `api` | `test`, `secure`, `deploy` | `postgres`, `redis` |
| Rails | `rails` | `postgres`, `redis`, `auth` | `test`, `deploy`, `migrate` | `postgres`, `redis` |
| Laravel | `laravel` | `postgres`, `queue`, `auth` | `test`, `deploy`, `docker` | `postgres`, `redis` |
| Spring Boot | `spring` | `postgres`, `grpc`, `k8s` | `test`, `secure`, `deploy` | `postgres`, `redis` |
| Node.js API | `node` | `api`, `auth`, `queue` | `test`, `secure`, `docker` | `postgres`, `redis` |
| Go microservices | N/A (use `micro`) | `api`, `grpc`, `docker` | `test`, `secure`, `k8s` | `postgres`, `redis` |
| Rust backend | N/A (use `api`) | `docker`, `grpc` | `test`, `optimize`, `deploy` | `postgres` |
| Mobile (React Native) | `mobile` | `react`, `state`, `api` | `test`, `e2e`, `ship` | N/A (API backend) |
| Full-stack monorepo | `monorepo` | Framework + `api` + `docker` | `test`, `cicd`, `ship` | `postgres`, `redis` |
| AI/LLM application | `agent` | `rag`, `prompt`, `eval` | `test`, `optimize`, `ship` | `postgres`, `redis` |

---

## Appendix: Confusion Pairs

Skills that are commonly confused. Use this to disambiguate.

| Pair | Skill A does... | Skill B does... |
|---|---|---|
| `optimize` vs `perf` | Iterative loop: measure, change, verify, keep/revert. Commits improvements. | One-shot profiling: flame graphs, memory snapshots, race detection. Reports findings. |
| `fix` vs `debug` | Autonomous remediation loop. Picks error, fixes, commits, verifies. Reverts regressions. | Scientific investigation. Reproduces, bisects, proves root cause. Hands off to `fix`. |
| `ship` vs `deploy` | Pre-flight checklist, dry-run, execute (PR/tag/release), post-ship verify. | Designs deployment strategy: blue-green, canary, progressive rollout, rollback plans. |
| `ship` vs `finish` | Ships to production (deploy, release, PR creation + merge). | Finalizes a branch (squash-merge, PR creation, discard). Branch hygiene, not deployment. |
| `test` vs `e2e` | TDD loop for unit/integration tests. RED-GREEN-REFACTOR until coverage target. | End-to-end browser tests. Full user flow simulation with Playwright/Cypress. |
| `secure` vs `pentest` | STRIDE + OWASP audit with 4 personas. Reports vulnerabilities with code evidence. | Active exploitation. Attempts real attacks with real payloads. Requires authorization. |
| `think` vs `plan` | Explores approaches, writes `.godmode/spec.md` (the what and why). | Decomposes spec into tasks with deps, writes `.godmode/plan.yaml` (the how and order). |
| `refactor` vs `optimize` | Restructures code for clarity, maintainability, testability. No metric required. | Improves a measurable metric (latency, throughput, size). Needs a benchmark command. |
| `migrate` vs `migration` | Database schema migration (add columns, create tables, transform data). | Full system migration (rewrite, platform change, monolith-to-microservices). |
| `cache` vs `redis` | Designs caching strategy: what to cache, TTL, invalidation, where (CDN, app, DB). | Implements with Redis specifically: data structures, Lua scripts, cluster config. |
| `cicd` vs `ghactions` | Platform-agnostic CI/CD design: stages, gates, environments, rollback. | GitHub Actions YAML: workflow files, matrix builds, reusable actions. |
| `observe` vs `logging` | Full observability: metrics + traces + logs + dashboards + alerting. | Structured logging only: log levels, correlation IDs, log aggregation. |
| `api` vs `apidocs` | Designs and implements REST endpoints, auth middleware, error handling. | Generates OpenAPI/Swagger specs and interactive documentation from existing code. |
| `auth` vs `rbac` | Identity: login, signup, sessions, JWT, OAuth, password reset. | Authorization: roles, permissions, policies, row-level security. |
| `query` vs `orm` | Optimizes existing queries: EXPLAIN, indexes, rewriting N+1. | Sets up ORM models, relationships, migration generation. |
