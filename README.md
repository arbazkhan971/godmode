<div align="center">

# GODMODE

### Turn on Godmode for Claude Code, Codex, Gemini CLI & OpenCode.

**171 skills. 7 subagents. Zero configuration. One command.**

Your AI writes code. Godmode makes it write *great* code.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg)](package.json)
[![Skills](https://img.shields.io/badge/skills-171-ff6b6b.svg)](skills/)
[![Agents](https://img.shields.io/badge/subagents-7-ff9f43.svg)](agents/)
[![Commands](https://img.shields.io/badge/commands-158-orange.svg)](commands/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-blueviolet.svg)](https://claude.ai)
[![Codex](https://img.shields.io/badge/Codex-Compatible-green.svg)](.codex/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

[Quick Start](#quick-start) · [Subagents](#subagents-7-built-in) · [All 170 Skills](#the-skill-map-170-skills) · [Examples](#real-world-examples) · [Contributing](#contributing)

</div>

---

## See it in action

```
$ /godmode I need to optimize our API response time

  GODMODE ─── Detecting phase...
  ┌──────────────────────────────────────────────────────┐
  │  Phase: OPTIMIZE                                     │
  │  Goal:  Reduce API response time                     │
  │  Plan:  measure → hypothesize → modify → verify      │
  └──────────────────────────────────────────────────────┘

  ▸ BASELINE    847ms (median of 3 runs)
  ▸ ITERATION 1 Added index on category_id      → 554ms ✓ KEPT  (-34.5%)
  ▸ ITERATION 2 Enabled gzip compression        → 382ms ✓ KEPT  (-31.0%)
  ▸ ITERATION 3 Switched to eager loading        → 276ms ✓ KEPT  (-27.7%)
  ▸ ITERATION 4 Reduced N+1 with batch loader   → 290ms ✗ REVERTED
  ▸ ITERATION 5 Increased connection pool to 20  → 226ms ✓ KEPT  (-18.2%)
  ▸ ITERATION 6 Added Redis response cache       → 198ms ✓ KEPT  (-12.4%)

  ────────────────────────────────────────────────────────
  RESULT  847ms → 198ms  (76.6% improvement)
  COMMITS 9 iterations · 5 kept · 3 reverted · 1 guard rail
  ────────────────────────────────────────────────────────
```

Every improvement is **measured**. Every bad change is **reverted**. Every experiment is **committed**. No vibes. Just evidence.

---

## Why Godmode?

| The Problem | The Godmode Fix |
|---|---|
| Your AI generates code, then you spend hours fixing it | Godmode enforces TDD — tests first, implementation second, zero rework |
| "Make it faster" produces guesswork, not results | The autonomous loop measures, experiments, and proves every change |
| You need 10 different tools for design, build, test, deploy | 171 skills + 7 subagents, one plugin — from brainstorm to production |
| AI changes break things and you don't notice until prod | Git-as-memory: every experiment committed, bad changes auto-reverted |
| Security review means "looks fine to me" | STRIDE + OWASP + red-team audit finds what humans miss |
| Design and product work lives in Figma/Notion, disconnected from code | UX design, wireframing, PRDs, and user research skills — design to code in one loop |

---

## The Godmode Loop

```
    ┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
    │          │     │          │     │          │     │          │
    │  THINK   │────▸│  BUILD   │────▸│ OPTIMIZE │────▸│   SHIP   │
    │          │     │          │     │          │     │          │
    └──────────┘     └──────────┘     └──────────┘     └──────────┘
         │                │                │                │
    ┌────┴────┐     ┌────┴────┐     ┌────┴────┐     ┌────┴────┐
    │ Design  │     │ TDD +   │     │ Measure │     │Preflight│
    │ first.  │     │parallel │     │ + auto  │     │+ deploy │
    │ Explore │     │ agents. │     │ iterate │     │+ monitor│
    │ options.│     │ Review. │     │ + prove.│     │+ verify.│
    └─────────┘     └─────────┘     └─────────┘     └─────────┘
```

**THINK** — Brainstorm approaches. Get expert predictions. Explore edge cases. Write a spec before a single line of code.

**BUILD** — Break the spec into atomic tasks. Execute with TDD (RED-GREEN-REFACTOR). Run parallel agents. Code review at every boundary.

**OPTIMIZE** — The autonomous loop: measure baseline, hypothesize, modify one thing, verify mechanically, keep if better or revert if worse. Repeat.

**SHIP** — Pre-flight checklist. Dry run. Deploy. Smoke test. Monitor. Rollback plan ready. Every time.

### How Agents Drive Each Phase

Every phase uses the same agentic pattern: **decompose → dispatch → merge → verify**.

```
    USER GOAL: "Build a rate limiter"
         │
         ▼
    ┌──────────┐
    │ GODMODE  │ ← Orchestrator detects phase, routes to skill
    │  detect  │
    └────┬─────┘
         │
    ┌────▼─────┐     ┌──────────┐
    │ PLANNER  │────▸│ EXPLORER │  ← Recon agent reads codebase
    │ agent    │     │ agent    │    before planning
    └────┬─────┘     └──────────┘
         │
         ▼  Generates rounds of parallel tasks
    ╔══════════════════════════════════════╗
    ║  Round 1: Foundation                 ║
    ║  ┌─────────┐ ┌─────────┐ ┌────────┐ ║
    ║  │BUILDER 1│ │BUILDER 2│ │BUILDER 3│ ║ ← Each in isolated
    ║  │  wt-1   │ │  wt-2   │ │  wt-3  │ ║   git worktree
    ║  └────┬────┘ └────┬────┘ └───┬────┘ ║
    ║       └───────────┼──────────┘      ║
    ║              MERGE + TEST           ║
    ╠══════════════════════════════════════╣
    ║  Round 2: Core Logic                 ║
    ║  ┌─────────┐ ┌─────────┐            ║
    ║  │BUILDER 4│ │BUILDER 5│            ║ ← Depends on Round 1
    ║  │  wt-4   │ │  wt-5   │            ║
    ║  └────┬────┘ └────┬────┘            ║
    ║       └───────────┘                 ║
    ║         MERGE + TEST                ║
    ╠══════════════════════════════════════╣
    ║  Round 3: Verification               ║
    ║  ┌──────────┐  ┌──────────┐         ║
    ║  │ REVIEWER │  │ SECURITY │         ║ ← Final gates
    ║  │  agent   │  │  agent   │         ║
    ║  └──────────┘  └──────────┘         ║
    ╚══════════════════════════════════════╝
         │
         ▼
    ┌──────────┐
    │ OPTIMIZE │ ← Optimizer agent runs autonomous loop
    │  agent   │   measure → modify → verify → keep/revert
    └────┬─────┘
         │
         ▼
    ┌──────────┐
    │   SHIP   │ ← Pre-flight, deploy, smoke test, monitor
    └──────────┘
```

**Key principles:**
- **Isolation**: Every builder agent works in its own git worktree — no conflicts during parallel work
- **Rounds**: Tasks with dependencies wait; independent tasks run simultaneously
- **Verification**: Full test suite runs after every merge, not just at the end
- **Auto-revert**: If a merge introduces failures, the offending branch is reverted and flagged for retry

---

## Quick Start

```bash
# 1. Install
claude plugin install godmode

# 2. Run
/godmode I want to build a rate limiter for our API

# 3. That's it. Godmode handles the rest.
```

Or go directly to any skill:

```bash
/godmode:think     # Design before you code
/godmode:build     # Build with TDD + parallel agents
/godmode:optimize  # Autonomous performance iteration
/godmode:ship      # Ship with pre-flight checks
```

---

## Subagents (7 Built-in)

Godmode ships with **7 specialized subagents** that work in parallel via isolated git worktrees. The orchestrator decomposes your goal, dispatches agents across rounds, merges results, and verifies — all automatically.

| Agent | Role | Mode |
|-------|------|------|
| **planner** | Decomposes goals into parallel tasks mapped to skills | Read-only |
| **builder** | Implements tasks following skill workflows with TDD | Read-write |
| **reviewer** | Reviews code for correctness, security, and spec adherence | Read-only |
| **optimizer** | Autonomous measure → modify → verify iteration loop | Read-write |
| **explorer** | Read-only codebase reconnaissance and research | Read-only |
| **security** | STRIDE + OWASP audit with 4 adversarial personas | Read-only |
| **tester** | TDD test generation and RED-GREEN-REFACTOR enforcement | Read-write |

### Multi-Agent Execution Flow

This is the **default execution mode**. Every plan, build, and optimization runs through this pipeline:

```
                         ┌─────────────┐
                         │   PLANNER   │
                         │  Decompose  │
                         │  goal into  │
                         │   rounds    │
                         └──────┬──────┘
                                │
                    ┌───────────┼───────────┐
                    ▼           ▼           ▼
              ┌──────────┐┌──────────┐┌──────────┐
  Round 1     │ BUILDER  ││ BUILDER  ││ BUILDER  │   ← Parallel agents
  (parallel)  │ worktree ││ worktree ││ worktree │     in isolated
              │  wt-1    ││  wt-2    ││  wt-3    │     git worktrees
              └────┬─────┘└────┬─────┘└────┬─────┘
                   │           │           │
                   └───────────┼───────────┘
                               ▼
                      ┌────────────────┐
                      │  MERGE + TEST  │   ← Integrate all branches
                      │  Full suite    │     Run full test suite
                      └───────┬────────┘
                              │
                   ┌──────────┼──────────┐
                   ▼          ▼          ▼
             ┌──────────┐┌──────────┐┌──────────┐
  Round 2    │ BUILDER  ││ BUILDER  ││ TESTER   │   ← Next round of
  (parallel) │ worktree ││ worktree ││ worktree │     parallel agents
             │  wt-4    ││  wt-5    ││  wt-6    │
             └────┬─────┘└────┬─────┘└────┬─────┘
                  │           │           │
                  └───────────┼───────────┘
                              ▼
                     ┌────────────────┐
                     │  MERGE + TEST  │
                     └───────┬────────┘
                             │
                   ┌─────────┴─────────┐
                   ▼                   ▼
            ┌────────────┐      ┌────────────┐
            │  REVIEWER  │      │  SECURITY  │   ← Final verification
            │  Code review│      │  STRIDE +  │     before completion
            │  vs spec   │      │  OWASP     │
            └────────────┘      └────────────┘
```

**How it works across CLIs:**

| CLI | Agent Dispatch Method |
|-----|----------------------|
| **Claude Code** | `Agent` tool with `isolation: "worktree"` per task |
| **Codex** | Native subagents via `.codex/agents/*.toml` definitions |
| **Gemini CLI** | Sequential execution (no native parallel support) |
| **OpenCode** | Sequential execution with agent role instructions |

### Example: Multi-Agent Build

```
$ /godmode Build a SaaS billing system with Stripe

  GODMODE ─── Decomposing into parallel rounds...

  Round 1 — Dispatching 3 agents in parallel:
    Agent 1 [wt-schema]  → Design database schema     (skill: schema)
    Agent 2 [wt-api]     → Design API contracts        (skill: api)
    Agent 3 [wt-webhook] → Set up Stripe webhooks      (skill: webhook)

  [Agent 1] ✓ Schema complete — 4 migrations, 6 tests
  [Agent 3] ✓ Webhooks complete — 3 endpoints, 5 tests
  [Agent 2] ✓ API contracts complete — 8 endpoints, 12 tests

  Merging Round 1... ✓ All 23 tests passing

  Round 2 — Dispatching 2 agents in parallel:
    Agent 4 [wt-auth] → Implement auth + RBAC    (skill: auth)
    Agent 5 [wt-pay]  → Build payment endpoints   (skill: pay)

  [Agent 4] ✓ Auth complete — JWT + roles, 8 tests
  [Agent 5] ✓ Payments complete — checkout flow, 11 tests

  Merging Round 2... ✓ All 42 tests passing

  Round 3 — Final verification:
    Reviewer  → Code review against spec         ✓ APPROVED
    Security  → STRIDE + OWASP audit             ✓ 0 critical, 1 low

  BUILD COMPLETE ✓  5 agents · 2 rounds · 42 tests · 0 failures
```

---

## The Skill Map (170 Skills)

### Core Workflow
| Skill | Description |
|-------|-------------|
| `godmode` | Auto-detect phase, orchestrate the full loop |
| `think` | Brainstorm 2-3 approaches, produce a spec |
| `predict` | 5 expert personas evaluate your design |
| `scenario` | Explore edge cases across 12 dimensions |
| `plan` | Decompose spec into 2-5 min atomic tasks |
| `build` | Execute with TDD + parallel agents |
| `test` | Write tests, enforce RED-GREEN-REFACTOR |
| `review` | 2-stage code review (automated + agent) |
| `optimize` | Autonomous iteration loop with mechanical verification |
| `debug` | Scientific bug investigation (7 techniques) |
| `fix` | Autonomous error remediation loop |
| `ship` | 8-phase shipping workflow |
| `finish` | Branch finalization (merge/PR/keep/discard) |
| `setup` | Configure Godmode for your project |
| `verify` | Evidence gate — prove claims with commands |

### Architecture & Design
| Skill | Description |
|-------|-------------|
| `architect` | System architecture design and review |
| `rfc` | Write and review RFCs |
| `adr` | Architecture Decision Records |
| `ddd` | Domain-Driven Design patterns |
| `pattern` | Design pattern selection and implementation |
| `schema` | Database/API schema design |
| `contract` | API contract testing and validation |
| `concurrent` | Concurrency and parallelism patterns |
| `distributed` | Distributed systems design |
| `scale` | Scalability engineering |
| `legacy` | Legacy code modernization |
| `migration` | System migration and technology transition |

### API & Backend
| Skill | Description |
|-------|-------------|
| `api` | REST API design, implementation, and testing |
| `graphql` | GraphQL schema, resolvers, and optimization |
| `grpc` | gRPC service definition and implementation |
| `orm` | ORM setup, migrations, and query optimization |
| `query` | Database query optimization and analysis |
| `cache` | Caching strategy design and implementation |
| `queue` | Message queue setup and management |
| `event` | Event-driven architecture patterns |
| `realtime` | WebSocket / real-time communication |
| `edge` | Edge computing and CDN optimization |
| `micro` | Microservices architecture and patterns |
| `search` | Full-text search implementation |
| `ratelimit` | Rate limiting algorithms and middleware |
| `webhook` | Webhook design, delivery, and retry logic |
| `apidocs` | OpenAPI/Swagger documentation generation |
| `upload` | File uploads and media processing |

### Frameworks
| Skill | Description |
|-------|-------------|
| `angular` | Angular architecture |
| `django` | Django development |
| `fastapi` | FastAPI mastery |
| `laravel` | Laravel mastery |
| `nextjs` | Next.js mastery |
| `node` | Node.js backend development |
| `rails` | Ruby on Rails mastery |
| `react` | React architecture |
| `spring` | Spring Boot mastery |
| `svelte` | Svelte/SvelteKit mastery |
| `tailwind` | Tailwind CSS mastery |
| `vue` | Vue.js mastery |

### Databases
| Skill | Description |
|-------|-------------|
| `postgres` | PostgreSQL mastery |
| `redis` | Redis architecture and system design |
| `nosql` | NoSQL database design |

### Security & Compliance
| Skill | Description |
|-------|-------------|
| `secure` | STRIDE + OWASP security audit with red-team |
| `auth` | Authentication flow design and implementation |
| `rbac` | Role-based access control |
| `secrets` | Secrets management and rotation |
| `crypto` | Cryptographic implementation review |
| `pentest` | Penetration testing workflows |
| `devsecops` | Security pipeline integration |
| `comply` | Compliance framework implementation |
| `gdpr` | Deep GDPR compliance |
| `hipaa` | Deep HIPAA compliance |
| `soc2` | Deep SOC 2 compliance |

### Testing & Quality
| Skill | Description |
|-------|-------------|
| `unittest` | Unit test generation and coverage |
| `e2e` | End-to-end test orchestration |
| `integration` | Integration testing |
| `loadtest` | Load and stress testing |
| `quality` | Code quality metrics and enforcement |
| `lint` | Linter configuration and custom rules |
| `type` | Type system design and migration |
| `perf` | Performance profiling and benchmarking |
| `webperf` | Web vitals and frontend performance |
| `eval` | LLM evaluation and benchmarking |
| `snapshot` | Snapshot testing workflows |
| `chaos` | Chaos engineering experiments |
| `reliability` | Site reliability engineering |
| `slo` | SLO/SLI definition and error budget tracking |

### DevOps & Infrastructure
| Skill | Description |
|-------|-------------|
| `deploy` | Deployment automation and strategies |
| `k8s` | Kubernetes manifests and operations |
| `infra` | Infrastructure as Code (Terraform, Pulumi) |
| `cicd` | CI/CD pipeline design and optimization |
| `pipeline` | Data and build pipeline orchestration |
| `release` | Release management and versioning |
| `backup` | Backup strategy and disaster recovery |
| `incident` | Incident response runbooks |
| `observe` | Observability stack setup (metrics, traces, logs) |
| `logging` | Structured logging implementation |
| `errortrack` | Error tracking and alerting |
| `errorhandling` | Error handling patterns and strategies |
| `network` | Network configuration and troubleshooting |
| `resilience` | Circuit breakers, retries, fallbacks |
| `config` | Configuration management |
| `cost` | Cloud cost optimization |
| `cron` | Scheduled tasks and job queue management |
| `ghactions` | GitHub Actions workflow design and optimization |

### Frontend & UI
| Skill | Description |
|-------|-------------|
| `ui` | Component design and implementation |
| `visual` | Visual regression testing |
| `a11y` | Accessibility audit and remediation |
| `seo` | SEO optimization and metadata |
| `pwa` | Progressive Web App setup |
| `mobile` | Mobile development patterns |
| `desktop` | Desktop app development (Electron, Tauri) |
| `chart` | Data visualization and charting |
| `state` | State management architecture |
| `wasm` | WebAssembly integration |
| `animation` | Animation and motion design |
| `designsystem` | Design system architecture |
| `forms` | Form architecture |
| `responsive` | Responsive and adaptive design |
| `three` | 3D web development |
| `gamedev` | Game development architecture |

### UI/UX & Product
| Skill | Description |
|-------|-------------|
| `uxdesign` | UI/UX design — personas, heuristics, user flows, design handoff |
| `wireframe` | Wireframing, prototyping, and component layout planning |
| `research` | User research — interviews, surveys, journey mapping, JTBD |
| `pm` | Product management — PRDs, user stories, prioritization, launch |
| `strategy` | Product strategy — roadmaps, growth models, market analysis |
| `designconsistency` | Design contract enforcement — no more AI-generated drift |

### AI & ML
| Skill | Description |
|-------|-------------|
| `ml` | Machine learning pipeline design |
| `mlops` | ML model deployment and monitoring |
| `rag` | Retrieval-Augmented Generation setup |
| `prompt` | Prompt engineering and optimization |
| `analytics` | Analytics instrumentation and dashboards |
| `aiops` | AI operations and safety |
| `embeddings` | Embeddings and semantic search |
| `finetune` | Model fine-tuning |
| `multimodal` | Multimodal AI |

### Developer Experience
| Skill | Description |
|-------|-------------|
| `docs` | Documentation generation and maintenance |
| `onboard` | Developer onboarding automation |
| `learn` | Interactive learning and codebase exploration |
| `dx` | Developer experience improvements |
| `scaffold` | Project scaffolding and boilerplate |
| `refactor` | Safe, incremental refactoring workflows |
| `pair` | AI pair programming sessions |
| `standup` | Automated standup report generation |
| `report` | Project status and metrics reports |
| `git` | Git workflow automation |
| `pr` | Pull request creation and review |
| `monorepo` | Monorepo tooling and management |
| `docker` | Docker mastery |
| `npm` | Package management |
| `terminal` | Terminal and shell productivity |
| `vscode` | IDE and editor configuration |
| `changelog` | Changelog and release notes |
| `estimate` | Effort estimation and complexity analysis |
| `prioritize` | Task prioritization |
| `scope` | Scope management |
| `retro` | Retrospective and team health |
| `opensource` | Open source project management |
| `license` | License management |

### Integrations & Specialized
| Skill | Description |
|-------|-------------|
| `i18n` | Internationalization and localization |
| `email` | Email template design and delivery |
| `pay` | Payment integration (Stripe, etc.) |
| `web3` | Web3 / blockchain development |
| `iot` | IoT device communication patterns |
| `cli` | CLI tool development |
| `extension` | Browser/IDE extension development |
| `automate` | Task automation and scripting |
| `migrate` | Database and system migrations |
| `storage` | Storage strategy (S3, blob, local) |
| `agent` | AI agent design and orchestration |
| `feature` | Feature flags and gradual rollouts |
| `notify` | Push, SMS, and in-app notifications |
| `experiment` | A/B testing and statistical analysis |
| `seed` | Database seeding and factory patterns |
| `dependencies` | Dependency management and supply chain security |

---

## Feature Highlights

| # | Feature | What It Does |
|---|---------|-------------|
| 1 | **Autonomous Optimization Loop** | Measures, experiments, proves — no guesswork, just data |
| 2 | **TDD Enforcement** | RED-GREEN-REFACTOR on every build, every time |
| 3 | **7 Subagents, Multi-Agent Default** | Planner decomposes, builders execute in parallel worktrees, reviewers verify |
| 4 | **Git-as-Memory** | Every experiment committed, every revert tracked |
| 5 | **Mechanical Verification** | Real commands, real output — never "it should work" |
| 6 | **STRIDE + OWASP Security** | Structured security audit, not a vibes check |
| 7 | **5 Expert Personas** | Your design reviewed by simulated domain experts |
| 8 | **170 Skills, Zero Config** | Install once, use everything — no setup required |
| 9 | **8-Phase Ship Workflow** | Pre-flight, dry run, deploy, smoke test, monitor, rollback |
| 10 | **Language Agnostic** | JS/TS, Python, Rust, Go, Ruby, Java — auto-detected |

---

## Godmode vs. The Rest

| Capability | Godmode | Cursor | GitHub Copilot | Autoresearch | Superpowers |
|---|:---:|:---:|:---:|:---:|:---:|
| Code generation | Yes | Yes | Yes | Yes | Yes |
| Full workflow (idea to production) | **Yes** | No | No | No | No |
| Autonomous optimization loop | **Yes** | No | No | No | No |
| Mechanical verification | **Yes** | No | No | No | No |
| 170 specialized skills | **Yes** | No | No | No | No |
| TDD enforcement | **Yes** | No | No | No | No |
| Security audit framework | **Yes** | No | No | No | No |
| Git-as-memory (auto-revert) | **Yes** | No | No | No | No |
| Parallel agent dispatch | **Yes** | No | No | No | No |
| 7 specialized subagents | **Yes** | No | No | No | No |
| Multi-CLI support (5 platforms) | **Yes** | No | No | No | No |
| Evidence-based claims | **Yes** | No | No | No | No |
| Works inside your existing editor | **Yes** | Built-in | Built-in | Yes | Yes |

---

## Real-World Examples

```bash
# Design a feature from scratch
/godmode:think I need WebSocket support for real-time notifications

# Optimize a slow endpoint — hands-free
/godmode:optimize --goal "reduce /api/products response time" --target "< 200ms"

# Security audit before launch
/godmode:secure Run a full STRIDE + OWASP audit on the auth module

# Debug a production issue scientifically
/godmode:debug Users report intermittent 502 errors on the checkout endpoint

# Ship with confidence
/godmode:ship --pr

# Multi-agent build — 3 agents in parallel
/godmode:build  # Auto-dispatches parallel agents per round
```

---

## Supported Platforms

Godmode works across all major AI coding CLIs — with native subagent support where available.

| Platform | Status | Subagents |
|----------|--------|-----------|
| **Claude Code** | Full support | `Agent` tool with worktree isolation |
| **Codex** | Full support | Native `.codex/agents/*.toml` subagents |
| **Cursor** | Compatible | Sequential execution |
| **OpenCode** | Compatible | Sequential with agent roles |
| **Gemini CLI** | Compatible | Sequential execution |

---

## Documentation

| Document | Description |
|----------|-------------|
| [Getting Started](docs/getting-started.md) | First-time walkthrough |
| [Architecture](docs/architecture.md) | System design overview |
| [Skill Chaining](docs/chaining.md) | How to chain skills together |
| [Domain Guide](docs/domain-guide.md) | Backend, frontend, ML, DevOps |
| [CI/CD Integration](docs/ci-cd.md) | GitHub Actions, GitLab CI |
| [Design Document](docs/godmode-design.md) | Full design specification |

---

## Contributing

We welcome contributions. Every skill is a Markdown file — if you can write clear instructions, you can add a skill.

```bash
# Fork, clone, create a skill
cp -r skills/_template skills/your-skill
# Edit skills/your-skill/SKILL.md
# Submit a PR
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide.

---

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

**Discipline before speed. Evidence before claims. Git is memory.**

**[Install Godmode](https://github.com/arbazkhan971/godmode)** · **[Read the Docs](docs/getting-started.md)** · **[Join the Discussion](https://github.com/arbazkhan971/godmode/discussions)**

</div>
