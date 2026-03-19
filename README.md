<div align="center">

# GODMODE

### Turn on Godmode for Claude Code, Codex, Gemini CLI & OpenCode.

**126 skills. 7 subagents. Zero configuration.**

Your AI writes code. Godmode makes it write *great* code.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-126-ff6b6b.svg)](skills/)
[![Agents](https://img.shields.io/badge/subagents-7-ff9f43.svg)](agents/)

[Quick Start](#quick-start) · [How It Works](#how-it-works) · [All Skills](#skills-126) · [Platforms](#platforms)

</div>

---

## See it in action

```
$ /godmode:optimize
Goal: Reduce API response time
Iterations: 20

  ▸ BASELINE    847ms
  ▸ ROUND 1     554ms ✓ KEPT  (-34.5%)  — added index on category_id
  ▸ ROUND 2     382ms ✓ KEPT  (-31.0%)  — enabled gzip compression
  ▸ ROUND 3     276ms ✓ KEPT  (-27.7%)  — eager loading for posts
  ▸ ROUND 4     290ms ✗ REVERTED         — batch loader (guard failed)
  ▸ ROUND 5     226ms ✓ KEPT  (-18.2%)  — connection pool to 20
  ▸ ROUND 6     198ms ✓ KEPT  (-12.4%)  — Redis response cache

  === Optimize Complete (6/20 rounds) ===
  847ms → 198ms (76.6% improvement)
  Keeps: 5 | Discards: 1
```

Every improvement **measured**. Every bad change **reverted**. Every experiment **committed**.

---

## Quick Start

```bash
# Install
claude plugin install godmode

# Use
/godmode:optimize   # Autonomous performance iteration
/godmode:build      # Build with parallel agents
/godmode:secure     # STRIDE + OWASP security audit
/godmode:ship       # Pre-flight + deploy + verify
```

Or let godmode figure it out:

```bash
/godmode make this API faster       # → routes to optimize
/godmode fix the failing tests      # → routes to fix
/godmode build a rate limiter       # → routes to think → plan → build
```

---

## How It Works

### The Loop

Every iterative skill runs the same protocol:

```
WHILE goal not reached:
    1. REVIEW  — read state, results log, git log
    2. IDEATE  — pick next change
    3. MODIFY  — ONE atomic change
    4. COMMIT  — git commit BEFORE verify
    5. VERIFY  — run metric + guard command
    6. DECIDE  — improved → keep. worse → git reset --hard HEAD~1
    7. LOG     — append to .godmode/results.tsv
    8. REPEAT  — never stop, never ask
```

### The Phases

```
THINK → PLAN → BUILD → TEST → FIX → OPTIMIZE → SECURE → SHIP
```

Godmode auto-detects which phase you're in and routes to the right skill.

### Multi-Agent Execution

For complex tasks, godmode dispatches parallel agents in isolated git worktrees:

```
Round 1:  Agent 1 [worktree] ──┐
          Agent 2 [worktree] ───┼── merge + test
          Agent 3 [worktree] ──┘
Round 2:  Agent 4 [worktree] ──┐
          Agent 5 [worktree] ───┼── merge + test
```

Max 5 agents per round. Each agent: one task, one commit, scoped files. Merge sequentially, test after each merge.

---

## Subagents (7)

| Agent | Role |
|-------|------|
| **planner** | Decomposes goals into parallel tasks |
| **builder** | Implements tasks with TDD in worktrees |
| **reviewer** | Code review for correctness + security |
| **optimizer** | Autonomous measure → modify → verify loop |
| **explorer** | Read-only codebase reconnaissance |
| **security** | STRIDE + OWASP audit with 4 adversarial personas |
| **tester** | TDD test generation, RED-GREEN-REFACTOR |

---

## Skills (126)

### Core Workflow (15)

| Skill | What it does |
|-------|-------------|
| `godmode` | Orchestrator — detects phase, routes to skill |
| `think` | Brainstorm approaches, produce a spec |
| `predict` | 5 expert personas evaluate your design |
| `scenario` | Explore edge cases across 12 dimensions |
| `plan` | Decompose spec into atomic tasks with deps |
| `build` | Execute with TDD + parallel agents |
| `test` | Write tests, enforce RED-GREEN-REFACTOR |
| `review` | 4-agent code review (correctness, security, perf, style) |
| `optimize` | Autonomous iteration loop with mechanical verification |
| `debug` | Scientific bug investigation (7 techniques) |
| `fix` | Autonomous error remediation loop |
| `ship` | Checklist → dry-run → deploy → verify → monitor |
| `finish` | Branch finalization (merge/PR/keep/discard) |
| `setup` | Configure Godmode for your project |
| `verify` | Evidence gate — prove claims with commands |

### Architecture & Design (10)

| Skill | What it does |
|-------|-------------|
| `architect` | System architecture design |
| `rfc` | Technical proposal writing |
| `ddd` | Domain-Driven Design |
| `pattern` | Design pattern selection |
| `schema` | Database/API schema design |
| `concurrent` | Concurrency patterns |
| `distributed` | Distributed systems design |
| `scale` | Scalability engineering |
| `legacy` | Legacy code modernization |
| `migration` | System migration |

### API & Backend (14)

| Skill | What it does |
|-------|-------------|
| `api` | REST API design and implementation |
| `graphql` | GraphQL schema and resolvers |
| `grpc` | gRPC services |
| `orm` | ORM setup and query optimization |
| `query` | Database query optimization |
| `cache` | Caching strategy |
| `queue` | Message queues and job processing |
| `event` | Event-driven architecture |
| `realtime` | WebSocket / real-time |
| `edge` | Edge computing and CDN |
| `micro` | Microservices |
| `search` | Full-text search |
| `ratelimit` | Rate limiting |
| `webhook` | Webhook design and delivery |

### Frameworks (12)

| Skill | What it does |
|-------|-------------|
| `react` | React architecture |
| `nextjs` | Next.js |
| `vue` | Vue.js |
| `svelte` | SvelteKit |
| `angular` | Angular |
| `node` | Node.js backend |
| `fastapi` | FastAPI |
| `django` | Django |
| `rails` | Ruby on Rails |
| `laravel` | Laravel |
| `spring` | Spring Boot |
| `tailwind` | Tailwind CSS |

### Databases (3)

| Skill | What it does |
|-------|-------------|
| `postgres` | PostgreSQL |
| `redis` | Redis |
| `nosql` | NoSQL design |

### Security & Compliance (8)

| Skill | What it does |
|-------|-------------|
| `secure` | STRIDE + OWASP audit with red-team |
| `auth` | Authentication flows |
| `rbac` | Role-based access control |
| `secrets` | Secrets management |
| `crypto` | Cryptographic review |
| `pentest` | Penetration testing |
| `devsecops` | Security pipeline |
| `comply` | Compliance (GDPR, HIPAA, SOC 2) |

### Testing (7)

| Skill | What it does |
|-------|-------------|
| `e2e` | End-to-end testing |
| `integration` | Integration testing |
| `loadtest` | Load and stress testing |
| `lint` | Linter setup and custom rules |
| `type` | Type system design |
| `perf` | Performance profiling |
| `webperf` | Web vitals optimization |

### DevOps & Infrastructure (16)

| Skill | What it does |
|-------|-------------|
| `deploy` | Deployment strategies |
| `k8s` | Kubernetes |
| `infra` | Infrastructure as Code |
| `cicd` | CI/CD pipelines |
| `ghactions` | GitHub Actions |
| `pipeline` | Data/build pipelines |
| `docker` | Docker |
| `backup` | Backup and disaster recovery |
| `incident` | Incident response |
| `observe` | Observability (metrics, traces, logs) |
| `logging` | Structured logging |
| `network` | Network configuration |
| `resilience` | Circuit breakers, retries |
| `config` | Configuration management |
| `cost` | Cloud cost optimization |
| `cron` | Scheduled tasks |

### Frontend & UI (8)

| Skill | What it does |
|-------|-------------|
| `ui` | Component design |
| `a11y` | Accessibility audit |
| `seo` | SEO optimization |
| `mobile` | Mobile development |
| `chart` | Data visualization |
| `state` | State management |
| `designsystem` | Design system architecture |
| `forms` | Form architecture |
| `responsive` | Responsive design |

### AI & ML (5)

| Skill | What it does |
|-------|-------------|
| `ml` | ML pipeline design |
| `mlops` | Model deployment |
| `rag` | Retrieval-Augmented Generation |
| `prompt` | Prompt engineering |
| `eval` | LLM evaluation |

### Developer Experience (12)

| Skill | What it does |
|-------|-------------|
| `docs` | Documentation |
| `onboard` | Developer onboarding |
| `refactor` | Safe refactoring workflows |
| `git` | Git workflow automation |
| `pr` | Pull request management |
| `monorepo` | Monorepo management |
| `npm` | Package management |
| `changelog` | Changelog generation |
| `opensource` | Open source project management |
| `analytics` | Analytics instrumentation |
| `apidocs` | OpenAPI/Swagger docs |
| `reliability` | SRE practices |
| `slo` | SLO/SLI definition |

### Integrations (14)

| Skill | What it does |
|-------|-------------|
| `i18n` | Internationalization |
| `email` | Email templates and delivery |
| `pay` | Payment integration (Stripe) |
| `cli` | CLI tool development |
| `automate` | Task automation |
| `migrate` | Database migrations |
| `storage` | File storage (S3, blob) |
| `agent` | AI agent design |
| `feature` | Feature flags |
| `notify` | Push/SMS/in-app notifications |
| `experiment` | A/B testing |
| `seed` | Database seeding |
| `upload` | File uploads |
| `chaos` | Chaos engineering |

---

## Platforms

| Platform | Status | Agents |
|----------|--------|--------|
| **Claude Code** | Full support | Parallel via `Agent` tool + worktrees |
| **Codex** | Full support | Native `.codex/agents/*.toml` |
| **Gemini CLI** | Compatible | Sequential execution |
| **OpenCode** | Compatible | Sequential execution |

---

## Contributing

Every skill is a Markdown file. If you can write clear instructions, you can add a skill.

```bash
mkdir skills/your-skill
# Edit skills/your-skill/SKILL.md
# Submit a PR
```

---

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">

**Discipline before speed. Evidence before claims. Git is memory.**

**[Install](https://github.com/arbazkhan971/godmode)** · **[Docs](docs/)** · **[Discuss](https://github.com/arbazkhan971/godmode/discussions)**

</div>
