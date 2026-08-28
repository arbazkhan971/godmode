# The Definitive Godmode Skill List

> **135 implemented skills**, each with a complete `SKILL.md`. Organized alphabetically and by category.
>
> Every skill is a Markdown file in `skills/<name>/SKILL.md`. Invoke any skill with `/godmode:<name>`.

---

## Quick Stats

| Metric | Count |
|--------|-------|
| **Implemented skills** (have SKILL.md) | 135 |
| **Planned skills** (directory reserved) | 0 |
| **Total skill directories** | 135 |
| **Categories** | 11 |

---

## Alphabetical List (All 135 Implemented Skills)

| # | Skill | Command | One-Line Description |
|---|-------|---------|---------------------|
| 1 | a11y | `/godmode:a11y` | Accessibility — WCAG 2.1 AA/AAA, a11y audit, color contrast, keyboard navigation |
| 2 | agent | `/godmode:agent` | AI agent development — ReAct/plan-and-execute/multi-agent architectures, tool design, memory systems |
| 3 | analytics | `/godmode:analytics` | Product analytics implementation — event tracking, funnel analysis, A/B testing |
| 4 | angular | `/godmode:angular` | Angular architecture — NgRx, Signals, RxJS, standalone components, lazy loading, dependency injection |
| 5 | api | `/godmode:api` | API design and specification — REST, GraphQL, gRPC, OpenAPI, design an API, create API |
| 6 | apidocs | `/godmode:apidocs` | API documentation — OpenAPI, Swagger, Redoc, contract-first development, spec-first, code-first |
| 7 | architect | `/godmode:architect` | Software architecture design — system architecture, monolith/microservices/serverless/event-driven |
| 8 | auth | `/godmode:auth` | Authentication and authorization — JWT, OAuth2, OIDC, SAML, API keys, mTLS, MFA, passwordless |
| 9 | automate | `/godmode:automate` | Task automation — cron jobs, webhooks, GitHub Actions, Makefile, Taskfile, scripts, CI/CD |
| 10 | backup | `/godmode:backup` | Backup and disaster recovery — backup strategy, disaster recovery, RPO/RTO, data integrity, durability |
| 11 | bench | `/godmode:bench` | Formal benchmark harness — Runs a metric command N times across 2-3 variants |
| 12 | build | `/godmode:build` | Implementation engine — Parallel agents in worktrees from plan. |
| 13 | cache | `/godmode:cache` | Cache — Redis, Memcached, Varnish, CDN, cache invalidation, TTL, write-through, cache |
| 14 | changelog | `/godmode:changelog` | Changelog and release notes management |
| 15 | chaos | `/godmode:chaos` | Chaos engineering — failure injection, circuit breakers, game day, disaster recovery, resilience |
| 16 | chart | `/godmode:chart` | Data visualization — chart, graph, dashboard, visualize data, plot, analytics, D3.js, Chart.js |
| 17 | cicd | `/godmode:cicd` | CI/CD pipeline design — GitHub Actions, GitLab CI, CircleCI, Jenkins, stage optimization, caching |
| 18 | cli | `/godmode:cli` | CLI tool development — Argument parsing (Commander, Clap, Cobra, Click), TUI frameworks |
| 19 | comply | `/godmode:comply` | Compliance and governance — GDPR, HIPAA, SOC2, PCI-DSS, audit trails, privacy controls, data retention |
| 20 | concurrent | `/godmode:concurrent` | Concurrency and parallelism — thread safety, race condition, deadlock, lock-free, async/await, actor |
| 21 | config | `/godmode:config` | Config — dev/staging/prod, feature flags, A/B test rollout, config validation, env |
| 22 | cost | `/godmode:cost` | Cloud cost optimization — AWS/GCP/Azure, right-sizing, waste detection, cost allocation, budget |
| 23 | cron | `/godmode:cron` | Scheduled tasks and cron jobs |
| 24 | crypto | `/godmode:crypto` | Crypto — encryption, hashing, Argon2, bcrypt, key management, JWT signing, TLS |
| 25 | ddd | `/godmode:ddd` | Domain-Driven Design — Bounded contexts, context mapping, ubiquitous language, aggregates, entities |
| 26 | debug | `/godmode:debug` | Scientific debugging — Reproduce → investigate → prove root cause. Finds all |
| 27 | deploy | `/godmode:deploy` | Advanced deployment strategies — Blue-green, canary releases, progressive rollouts, automated rollback |
| 28 | designsystem | `/godmode:designsystem` | Design system architecture — design tokens, theme systems, Figma to code, component API |
| 29 | devsecops | `/godmode:devsecops` | DevSecOps pipeline security — SAST/DAST/SCA scanning, secret scanning, container scanning |
| 30 | distributed | `/godmode:distributed` | Distributed systems design — CAP theorem, consensus (Raft/Paxos), sharding, partitioning, eventual |
| 31 | django | `/godmode:django` | Django + FastAPI development — Project structure, DRF serializers/viewsets, Pydantic, async Django with |
| 32 | docker | `/godmode:docker` | Docker containerization — Dockerfile, multi-stage builds, Docker Compose, image size optimization |
| 33 | docs | `/godmode:docs` | Docs — OpenAPI/Swagger, JSDoc, docstrings, README, runbook, API docs, stale docs |
| 34 | e2e | `/godmode:e2e` | End-to-end testing skill — Activates for browser-based E2E tests, cross-browser testing, flaky test |
| 35 | edge | `/godmode:edge` | Edge computing and serverless — Deno Deploy, distributed state, Cloudflare Workers, Vercel Edge, AWS |
| 36 | email | `/godmode:email` | Email and notifications — SendGrid, SES, Postmark, Resend, MJML, React Email, delivery tracking |
| 37 | eval | `/godmode:eval` | AI/LLM evaluation — Benchmark creation, regression testing, statistical significance, LLM-as-judge |
| 38 | event | `/godmode:event` | Event-driven architecture — SQS, NATS, schema versioning, DLQ, retry policies, idempotency. |
| 39 | experiment | `/godmode:experiment` | A/B testing, experimentation, statistical analysis |
| 40 | fastapi | `/godmode:fastapi` | FastAPI mastery skill — Covers Pydantic models, DI, async DB access, background tasks |
| 41 | feature | `/godmode:feature` | Feature flag design, gradual rollouts, A/B testing, kill switches |
| 42 | finish | `/godmode:finish` | Branch finalization — Validate, squash-merge, PR, keep, or discard. Clean state enforced. |
| 43 | fix | `/godmode:fix` | Fix loop — One fix per commit, auto-revert on regression, until zero |
| 44 | forms | `/godmode:forms` | Form architecture skill — Multi-step wizards, validation (client + server, async), file uploads |
| 45 | ghactions | `/godmode:ghactions` | GitHub Actions workflows, custom actions, CI/CD |
| 46 | git | `/godmode:git` | Advanced Git workflows skill — Branching models, merge vs rebase, interactive rebase, git bisect |
| 47 | goal-bridge | `/godmode:goal-bridge` | Machine-checkable completion contracts for agent goal modes |
| 48 | godmode | `/godmode` | Orchestrator — Routes to skills, detects stack/phase, dispatches multi-agent worktrees. Triggers |
| 49 | graphql | `/godmode:graphql` | GraphQL API development skill — Schema design, resolver architecture, N+1 detection with DataLoader |
| 50 | grpc | `/godmode:grpc` | gRPC and Protocol Buffers skill |
| 51 | i18n | `/godmode:i18n` | Internationalization & localization skill — String extraction, translation workflows, pluralization |
| 52 | incident | `/godmode:incident` | Incident response and post-mortem skill |
| 53 | infra | `/godmode:infra` | Infrastructure as Code skill — Terraform, CloudFormation, Pulumi, CDK. IaC testing, cost estimation |
| 54 | integration | `/godmode:integration` | Integration testing skill — Tests across real boundaries — databases, APIs, message queues. |
| 55 | k8s | `/godmode:k8s` | Kubernetes and container orchestration skill |
| 56 | laravel | `/godmode:laravel` | Laravel mastery skill — Eloquent ORM, service container, queues, events, Sanctum/Passport auth, Pest |
| 57 | legacy | `/godmode:legacy` | Legacy code modernization skill — Characterization tests, golden master, incremental modernization |
| 58 | lint | `/godmode:lint` | Linting and code standards skill |
| 59 | loadtest | `/godmode:loadtest` | Load testing and performance testing skill |
| 60 | logging | `/godmode:logging` | Structured logging skill — JSON logs, log levels, correlation IDs, PII redaction, log |
| 61 | micro | `/godmode:micro` | Microservices design and management |
| 62 | migrate | `/godmode:migrate` | Database migration and schema management |
| 63 | migration | `/godmode:migration` | System migration and technology transition |
| 64 | ml | `/godmode:ml` | ML development and experimentation |
| 65 | mlops | `/godmode:mlops` | MLOps and model deployment |
| 66 | mobile | `/godmode:mobile` | Mobile app development (iOS/Android/cross-platform) |
| 67 | monorepo | `/godmode:monorepo` | Monorepo architecture and management -- |
| 68 | network | `/godmode:network` | Network, DNS, SSL/TLS, CDN, load balancers |
| 69 | nextjs | `/godmode:nextjs` | Next.js mastery -- App Router, Server Components, |
| 70 | node | `/godmode:node` | Node.js backend development |
| 71 | nosql | `/godmode:nosql` | NoSQL database design (Mongo, DynamoDB, etc) |
| 72 | notify | `/godmode:notify` | Push notifications, SMS, in-app notifications, |
| 73 | npm | `/godmode:npm` | Package management (npm/yarn/pnpm/bun) |
| 74 | observe | `/godmode:observe` | Monitoring and observability (metrics/logs/traces) |
| 75 | onboard | `/godmode:onboard` | Codebase onboarding and architecture walkthrough |
| 76 | opensource | `/godmode:opensource` | Open source project management |
| 77 | optimize | `/godmode:optimize` | Autonomous optimization loop — 3 parallel agents |
| 78 | orm | `/godmode:orm` | ORM and data access optimization |
| 79 | pattern | `/godmode:pattern` | Design pattern recommendation and anti-pattern |
| 80 | pay | `/godmode:pay` | Payment and billing integration -- Stripe, |
| 81 | pentest | `/godmode:pentest` | Penetration testing (OWASP methodology) |
| 82 | perf | `/godmode:perf` | Performance profiling -- CPU, memory, concurrency, |
| 83 | pipeline | `/godmode:pipeline` | Data pipeline and ETL -- extraction, |
| 84 | plan | `/godmode:plan` | Task decomposition and dependency planning |
| 85 | postgres | `/godmode:postgres` | PostgreSQL mastery -- advanced features, |
| 86 | pr | `/godmode:pr` | Pull request excellence and review optimization |
| 87 | predict | `/godmode:predict` | 3-persona + meta-expert evaluation |
| 88 | principles | `/godmode:principles` | Authoring discipline prelude — Think -> Simplicity -> Surgical -> Goal-driven. Read before |
| 89 | prompt | `/godmode:prompt` | Prompt engineering -- design, test, version, |
| 90 | query | `/godmode:query` | Query optimization and EXPLAIN analysis |
| 91 | queue | `/godmode:queue` | Message queue and job processing -- Kafka, |
| 92 | rag | `/godmode:rag` | RAG (Retrieval-Augmented Generation) systems |
| 93 | rails | `/godmode:rails` | Ruby on Rails mastery |
| 94 | ratelimit | `/godmode:ratelimit` | Rate limiting algorithms, quota management, |
| 95 | rbac | `/godmode:rbac` | Permission and access control (RBAC/ABAC/ReBAC) |
| 96 | react | `/godmode:react` | React architecture -- components, state, |
| 97 | realtime | `/godmode:realtime` | Real-time communication -- WebSocket, SSE, |
| 98 | redis | `/godmode:redis` | Redis architecture and system design |
| 99 | refactor | `/godmode:refactor` | Large-scale code refactoring and transformation |
| 100 | reliability | `/godmode:reliability` | Site reliability engineering -- SLO/SLI/SLA, |
| 101 | research | `/godmode:research` | Prior art and context gathering |
| 102 | resilience | `/godmode:resilience` | System resilience -- circuit breakers, retries, |
| 103 | responsive | `/godmode:responsive` | Responsive and adaptive design with CSS Grid, |
| 104 | review | `/godmode:review` | 4-agent code review — Correctness, security |
| 105 | rfc | `/godmode:rfc` | RFC and technical proposal writing |
| 106 | scale | `/godmode:scale` | Scalability engineering — Horizontal/vertical decisions, auto-scaling, read replicas, connection |
| 107 | scenario | `/godmode:scenario` | Edge case exploration — 12 dimensions, scored by likelihood x impact. Runnable tests |
| 108 | schema | `/godmode:schema` | Data modeling and schema design |
| 109 | search | `/godmode:search` | Search implementation — Full-text search, relevance tuning, facets, autocomplete, fuzzy matching. |
| 110 | secrets | `/godmode:secrets` | Secrets management — Leak detection, rotation, vault setup, .env management, access auditing. |
| 111 | secure | `/godmode:secure` | Security audit — STRIDE + OWASP Top 10 + 4 red-team personas. |
| 112 | seed | `/godmode:seed` | Database seeding, test fixtures, factory patterns, fake data generation |
| 113 | seo | `/godmode:seo` | SEO optimization — Meta tags, structured data, Core Web Vitals, sitemap, robots.txt |
| 114 | setup | `/godmode:setup` | Configuration wizard — Auto-detects project stack, validates commands, saves .godmode/config.yaml. |
| 115 | ship | `/godmode:ship` | Ship workflow — Checklist, dry-run, ship, verify. PR, deploy, or release. |
| 116 | slo | `/godmode:slo` | SLOs, SLIs, error budgets, burn rate alerts, reliability targets, service level management |
| 117 | spring | `/godmode:spring` | Spring Boot mastery — Auto-configuration, security, Data JPA, Actuator, testing with TestContainers. |
| 118 | state | `/godmode:state` | State management design — Frontend state, server state, state machines, optimistic updates, caching. |
| 119 | stdio | `/godmode:stdio` | Stdio — Canonical terse command patterns, 13 terse equivalents, context-efficient bash |
| 120 | storage | `/godmode:storage` | File storage and CDN — Object storage, presigned URLs, image/video processing, lifecycle policies. |
| 121 | svelte | `/godmode:svelte` | Svelte/SvelteKit mastery — Runes reactivity, stores, routing, form actions, SSR, adapter configuration. |
| 122 | tailwind | `/godmode:tailwind` | Tailwind CSS mastery — Configuration, custom plugins, responsive design, dark mode, performance, CVA. |
| 123 | team | `/godmode:team` | Team bundles — Invoke named skill bundles, YAML coordination pattern, dispatch pipeline/parallel/swarm |
| 124 | terse | `/godmode:terse` | Output-compression mode for long autonomous loops |
| 125 | test | `/godmode:test` | TDD loop — RED-GREEN-REFACTOR until coverage target met. |
| 126 | think | `/godmode:think` | Design session — Explore problem, scan codebase, generate 2-3 approaches, recommend one |
| 127 | tokens | `/godmode:tokens` | Token-budget observability for godmode loops |
| 128 | tutorial | `/godmode:tutorial` | Day-0 onboarding walkthrough: first install to a first successful session |
| 129 | type | `/godmode:type` | Type system and schema validation |
| 130 | ui | `/godmode:ui` | UI component architecture — Design systems, Storybook, CSS architecture, design tokens, component |
| 131 | upload | `/godmode:upload` | File upload handling, image optimization, media processing, signed URLs, multipart, virus scanning |
| 132 | verify | `/godmode:verify` | Evidence gate — Run command, read full output, confirm or deny claim. |
| 133 | vue | `/godmode:vue` | Vue.js mastery — Composition API, Pinia, Vue Router, Nuxt SSR/SSG, Vite optimization |
| 134 | webhook | `/godmode:webhook` | Webhook design, delivery, retry, HMAC verification, event subscriptions, dead letter queues |
| 135 | webperf | `/godmode:webperf` | Web performance optimization — Lighthouse, bundle analysis, code splitting, image optimization, critical |

---

## Skills by Category

### Core Workflow (22 skills)

The skills that form the THINK-BUILD-OPTIMIZE-SHIP loop, plus the discipline, compression, and observability skills every skill inherits by default.

| Skill | Phase | Description |
|-------|--|--|
| `godmode` | Meta | Orchestrator — Routes to skills, detects stack/phase, dispatches |
| `setup` | Meta | Configuration wizard — Auto-detects project stack, validates |
| `verify` | Meta | Evidence gate — Run command, read full output, confirm or deny claim. |
| `think` | THINK | Design session — Explore problem, scan codebase, generate 2-3 |
| `predict` | THINK | 3-persona + meta-expert evaluation |
| `scenario` | THINK | Edge case exploration — 12 dimensions, scored by likelihood x impact. |
| `plan` | BUILD | Task decomposition and dependency planning |
| `build` | BUILD | Implementation engine — Parallel agents in worktrees from plan. |
| `test` | BUILD | TDD loop — RED-GREEN-REFACTOR until coverage target met. |
| `review` | BUILD | 4-agent code review — Correctness, security |
| `optimize` | OPTIMIZE | Autonomous optimization loop — 3 parallel agents |
| `debug` | OPTIMIZE | Scientific debugging — Reproduce → investigate → prove root cause. |
| `fix` | OPTIMIZE | Fix loop — One fix per commit, auto-revert on regression, until zero |
| `ship` | SHIP | Ship workflow — Checklist, dry-run, ship, verify. PR, deploy, or |
| `finish` | SHIP | Branch finalization — Validate, squash-merge, PR, keep, or discard. |
| `principles` | Meta | Authoring discipline prelude — Think -> Simplicity -> Surgical -> |
| `stdio` | Meta | Stdio — Canonical terse command patterns, 13 terse equivalents |
| `terse` | Meta | Output-compression mode for long autonomous loops |
| `tokens` | Meta | Token-budget observability for godmode loops |
| `research` | THINK | Prior art and context gathering |
| `team` | Meta | Team bundles — Invoke named skill bundles, YAML coordination pattern |
| `goal-bridge` | Meta | Machine-checkable completion contracts for agent goal modes |

### Architecture and Design (6 skills)

Structural decisions that shape the system before code is written.

| Skill | Desc |
|--|--|
| `architect` | Software architecture design — system architecture |
| `rfc` | RFC and technical proposal writing |
| `ddd` | Domain-Driven Design — Bounded contexts, context mapping, ubiquitous |
| `pattern` | Design pattern recommendation and anti-pattern |
| `schema` | Data modeling and schema design |
| `distributed` | Distributed systems design — CAP theorem, consensus (Raft/Paxos) |

### API and Backend (31 skills)

Building robust server-side systems.

| Skill | Desc |
|--|--|
| `api` | API design and specification — REST, GraphQL, gRPC, OpenAPI, design |
| `apidocs` | API documentation — OpenAPI, Swagger, Redoc, contract-first |
| `graphql` | GraphQL API development skill — Schema design, resolver architecture |
| `grpc` | gRPC and Protocol Buffers skill |
| `query` | Query optimization and EXPLAIN analysis |
| `cache` | Cache — Redis, Memcached, Varnish, CDN, cache invalidation, TTL |
| `redis` | Redis architecture and system design |
| `queue` | Message queue and job processing -- Kafka, |
| `event` | Event-driven architecture — SQS, NATS, schema versioning, DLQ, retry |
| `micro` | Microservices design and management |
| `search` | Search implementation — Full-text search, relevance tuning, facets |
| `concurrent` | Concurrency and parallelism — thread safety, race condition |
| `state` | State management design — Frontend state, server state, state |
| `pipeline` | Data pipeline and ETL -- extraction, |
| `django` | Django + FastAPI development — Project structure, DRF |
| `fastapi` | FastAPI mastery skill — Covers Pydantic models, DI, async DB access |
| `laravel` | Laravel mastery skill — Eloquent ORM, service container, queues |
| `rails` | Ruby on Rails mastery |
| `spring` | Spring Boot mastery — Auto-configuration, security, Data JPA |
| `node` | Node.js backend development |
| `nosql` | NoSQL database design (Mongo, DynamoDB, etc) |
| `postgres` | PostgreSQL mastery -- advanced features, |
| `orm` | ORM and data access optimization |
| `ratelimit` | Rate limiting algorithms, quota management, |
| `realtime` | Real-time communication -- WebSocket, SSE, |
| `webhook` | Webhook design, delivery, retry, HMAC verification, event |
| `email` | Email and notifications — SendGrid, SES, Postmark, Resend, MJML |
| `notify` | Push notifications, SMS, in-app notifications, |
| `pay` | Payment and billing integration -- Stripe, |
| `seed` | Database seeding, test fixtures, factory patterns, fake data |
| `analytics` | Product analytics implementation — event tracking, funnel analysis |

### Security and Compliance (8 skills)

Protecting systems and meeting regulatory requirements.

| Skill | Desc |
|--|--|
| `secure` | Security audit — STRIDE + OWASP Top 10 + 4 red-team personas. |
| `auth` | Authentication and authorization — JWT, OAuth2, OIDC, SAML, API keys |
| `rbac` | Permission and access control (RBAC/ABAC/ReBAC) |
| `secrets` | Secrets management — Leak detection, rotation, vault setup, .env |
| `pentest` | Penetration testing (OWASP methodology) |
| `devsecops` | DevSecOps pipeline security — SAST/DAST/SCA scanning, secret |
| `comply` | Compliance and governance — GDPR, HIPAA, SOC2, PCI-DSS, audit trails |
| `crypto` | Crypto — encryption, hashing, Argon2, bcrypt, key management, JWT |

### Testing and Quality (9 skills)

Ensuring code correctness, reliability, and maintainability.

| Skill | Desc |
|--|--|
| `test` | TDD loop — RED-GREEN-REFACTOR until coverage target met. |
| `e2e` | End-to-end testing skill — Activates for browser-based E2E tests |
| `integration` | Integration testing skill — Tests across real boundaries — databases |
| `loadtest` | Load testing and performance testing skill |
| `chaos` | Chaos engineering — failure injection, circuit breakers, game day |
| `lint` | Linting and code standards skill |
| `perf` | Performance profiling -- CPU, memory, concurrency, |
| `bench` | Formal benchmark harness — Runs a metric command N times across 2-3 |
| `experiment` | A/B testing, experimentation, statistical analysis |

### DevOps and Infrastructure (21 skills)

Deploying, running, and monitoring production systems.

| Skill | Desc |
|--|--|
| `deploy` | Advanced deployment strategies — Blue-green, canary releases |
| `k8s` | Kubernetes and container orchestration skill |
| `infra` | Infrastructure as Code skill — Terraform, CloudFormation, Pulumi |
| `cicd` | CI/CD pipeline design — GitHub Actions, GitLab CI, CircleCI, Jenkins |
| `changelog` | Changelog and release notes management |
| `backup` | Backup and disaster recovery — backup strategy, disaster recovery |
| `incident` | Incident response and post-mortem skill |
| `observe` | Monitoring and observability (metrics/logs/traces) |
| `logging` | Structured logging skill — JSON logs, log levels, correlation IDs |
| `network` | Network, DNS, SSL/TLS, CDN, load balancers |
| `resilience` | System resilience -- circuit breakers, retries, |
| `config` | Config — dev/staging/prod, feature flags, A/B test rollout, config |
| `feature` | Feature flag design, gradual rollouts, A/B testing, kill switches |
| `cost` | Cloud cost optimization — AWS/GCP/Azure, right-sizing, waste |
| `docker` | Docker containerization — Dockerfile, multi-stage builds, Docker |
| `ghactions` | GitHub Actions workflows, custom actions, CI/CD |
| `cron` | Scheduled tasks and cron jobs |
| `slo` | SLOs, SLIs, error budgets, burn rate alerts, reliability targets |
| `reliability` | Site reliability engineering -- SLO/SLI/SLA, |
| `scale` | Scalability engineering — Horizontal/vertical decisions |
| `edge` | Edge computing and serverless — Deno Deploy, distributed state |

### Frontend and UI (18 skills)

Building user interfaces that are fast, accessible, and maintainable.

| Skill | Desc |
|--|--|
| `ui` | UI component architecture — Design systems, Storybook, CSS |
| `designsystem` | Design system architecture — design tokens, theme systems, Figma to |
| `a11y` | Accessibility — WCAG 2.1 AA/AAA, a11y audit, color contrast, keyboard |
| `seo` | SEO optimization — Meta tags, structured data, Core Web Vitals |
| `mobile` | Mobile app development (iOS/Android/cross-platform) |
| `chart` | Data visualization — chart, graph, dashboard, visualize data, plot |
| `webperf` | Web performance optimization — Lighthouse, bundle analysis, code |
| `i18n` | Internationalization & localization skill — String extraction |
| `storage` | File storage and CDN — Object storage, presigned URLs, image/video |
| `upload` | File upload handling, image optimization, media processing, signed |
| `angular` | Angular architecture — NgRx, Signals, RxJS, standalone components |
| `react` | React architecture -- components, state, |
| `vue` | Vue.js mastery — Composition API, Pinia, Vue Router, Nuxt SSR/SSG |
| `svelte` | Svelte/SvelteKit mastery — Runes reactivity, stores, routing, form |
| `nextjs` | Next.js mastery -- App Router, Server Components, |
| `tailwind` | Tailwind CSS mastery — Configuration, custom plugins, responsive |
| `forms` | Form architecture skill — Multi-step wizards, validation |
| `responsive` | Responsive and adaptive design with CSS Grid, |

### AI and ML (7 skills)

Machine learning, LLMs, and intelligent systems.

| Skill | Desc |
|--|--|
| `ml` | ML development and experimentation |
| `mlops` | MLOps and model deployment |
| `rag` | RAG (Retrieval-Augmented Generation) systems |
| `prompt` | Prompt engineering -- design, test, version, |
| `agent` | AI agent development — ReAct/plan-and-execute/multi-agent |
| `predict` | 3-persona + meta-expert evaluation |
| `eval` | AI/LLM evaluation — Benchmark creation, regression testing |

### Developer Experience (10 skills)

Making developers more productive and codebases more approachable.

| Skill | Desc |
|--|--|
| `docs` | Docs — OpenAPI/Swagger, JSDoc, docstrings, README, runbook, API docs |
| `onboard` | Codebase onboarding and architecture walkthrough |
| `tutorial` | Day-0 onboarding walkthrough — Gets a first-time user from a fresh |
| `cli` | CLI tool development — Argument parsing |
| `npm` | Package management (npm/yarn/pnpm/bun) |
| `opensource` | Open source project management |
| `refactor` | Large-scale code refactoring and transformation |
| `git` | Advanced Git workflows skill — Branching models, merge vs rebase |
| `pr` | Pull request excellence and review optimization |
| `monorepo` | Monorepo architecture and management -- |

### Migration and Evolution (3 skills)

Moving systems forward without breaking them.

| Skill | Desc |
|--|--|
| `migrate` | Database migration and schema management |
| `migration` | System migration and technology transition |
| `legacy` | Legacy code modernization skill — Characterization tests, golden |

### Specialized Domains (2 skills)

Skills tailored to specific technology domains.

| Skill | Desc |
|--|--|
| `automate` | Task automation — cron jobs, webhooks, GitHub Actions, Makefile |
| `type` | Type system and schema validation |

---

## How to Use This List

**Run any skill directly:**
```bash
/godmode:think     # Start a design session
/godmode:build     # Build with TDD
/godmode:optimize  # Start the autonomous loop
```

**Chain skills together:**
```bash
think -> plan -> build -> review -> optimize -> secure -> ship -> finish
```

**Let the orchestrator decide:**
```bash
/godmode            # Auto-detects phase and routes to the right skill
```

See [Skill Chaining Guide](chaining.md) for advanced workflows.
