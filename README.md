<div align="center">

# GODMODE

### Turn on Godmode for Claude Code, Codex, Gemini CLI, Cursor & OpenCode.

**126 skills. 7 subagents. Zero configuration.**

Your AI writes code. Godmode makes it write *great* code.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-126-ff6b6b.svg)](skills/)
[![Agents](https://img.shields.io/badge/subagents-7-ff9f43.svg)](agents/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-supported-4A90D9.svg)](adapters/)
[![Codex](https://img.shields.io/badge/Codex-supported-10A37F.svg)](adapters/codex/)
[![Gemini CLI](https://img.shields.io/badge/Gemini_CLI-supported-4285F4.svg)](adapters/gemini/)
[![Cursor](https://img.shields.io/badge/Cursor-supported-000000.svg)](adapters/cursor/)
[![OpenCode](https://img.shields.io/badge/OpenCode-supported-7C3AED.svg)](adapters/opencode/)

</div>

---

### Quick Links

[Why Godmode?](#why-godmode) · [Philosophy](#philosophy) · [How It's Different](#how-its-different) · [See It In Action](#see-it-in-action) · [Quick Start](#quick-start) · [How It Works](#how-it-works) · [All Skills](#skills-126) · [Platforms](#platforms) · [Contributing](CONTRIBUTING.md) · [FAQ](docs/FAQ.md) · [Troubleshooting](docs/troubleshooting.md)

---

## Why Godmode?

AI coding assistants can write code. But writing code is the easy part.

The hard part is everything that happens *after* the first draft: verifying it works, measuring its performance, catching regressions, iterating until it's actually good, and knowing when to throw a change away. That is engineering discipline, and no AI coding tool does it on its own.

**Without Godmode**, AI assistants:
- Generate code and hope it works
- Have no way to measure if a change improved anything
- Cannot roll back a bad change automatically
- Do not iterate -- they produce one draft and stop
- Skip verification, testing, and security review
- Have no memory of what they tried before

**With Godmode**, every AI assistant gains:
- **Autonomous iteration loops** -- measure, modify, verify, keep or revert, repeat
- **Git as memory** -- every experiment is committed *before* verification, so bad changes can be rolled back with `git reset --hard HEAD~1`
- **Mechanical verification** -- claims are proven with commands, not asserted in prose
- **Multi-agent dispatch** -- complex tasks are decomposed and executed in parallel by specialized agents in isolated worktrees
- **126 expert skills** -- from architecture to deployment, security to performance, each encoding real engineering workflows
- **Cross-platform support** -- the same skills work on Claude Code, Codex, Gemini CLI, Cursor, and OpenCode

Godmode turns your AI assistant from a code generator into an engineering system.

---

## Philosophy

Inspired by [Karpathy's autoresearch](https://github.com/karpathy/autoresearch):

**Discipline before speed.** Every change is measured. Bad changes are reverted.
**Evidence before claims.** "Looks good" is rejected. Numeric proof is required.
**Git is memory.** Commit history is the audit trail. Every experiment is logged.
**Simplicity first.** Complex changes that marginally improve metrics are discarded.
**Never stop.** Loops run autonomously until goal met or budget exhausted.
**Keep or discard.** Every iteration produces a binary decision. No maybes.

Godmode turns iterative improvement from art (hoping changes work)
into engineering (knowing changes work by measurement).

---

## How It's Different

| | Plain AI Coding | With Godmode |
|---|---|---|
| **Approach** | Generate code in one shot | Iterate: measure, modify, verify, keep or revert |
| **Verification** | "I believe this works" | Runs tests, benchmarks, linters -- proves it works |
| **Bad changes** | Left in place, hope for the best | Automatically reverted via git |
| **Performance** | No measurement | Baseline measured, every change benchmarked |
| **Security** | Maybe a mention of best practices | STRIDE + OWASP audit with 4 red-team personas |
| **Memory** | Forgets what it tried | Git log + results.tsv tracks every experiment |
| **Complex tasks** | One agent, sequential | Up to 5 parallel agents in isolated worktrees |
| **Engineering rigor** | Varies wildly | Enforced by the skill protocol every time |

---

## See It In Action

### Autonomous Performance Optimization

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

### Multi-Agent Build

```
$ /godmode:build
Goal: Add user authentication system

  ▸ PLAN        Decomposed into 4 parallel tasks
  ▸ AGENT 1     [worktree] Auth middleware + JWT tokens       ✓ DONE
  ▸ AGENT 2     [worktree] User model + password hashing      ✓ DONE
  ▸ AGENT 3     [worktree] Login/register API endpoints        ✓ DONE
  ▸ AGENT 4     [worktree] Integration tests for auth flow     ✓ DONE
  ▸ MERGE       Sequential merge + test after each             ✓ ALL PASS
  ▸ REVIEW      4-agent code review (security, perf, style)    ✓ APPROVED

  === Build Complete ===
  4 tasks | 4 agents | 12 files | 47 tests passing
```

Parallel execution in isolated worktrees. Merge conflicts caught immediately. Tests run after every merge.

### Security Audit

```
$ /godmode:secure
Target: src/api/

  ▸ RECON       Mapped 23 endpoints, 4 auth flows, 2 data stores
  ▸ STRIDE      6 threat categories analyzed
  ▸ OWASP       Top 10 checklist applied
  ▸ RED TEAM    4 personas: script kiddie, insider, APT, researcher

  === Findings ===
  CRITICAL  1   SQL injection in /api/search (parameterize query)
  HIGH      2   Missing rate limit on /api/login, weak CORS policy
  MEDIUM    3   Verbose error messages, missing CSP header, session fixation
  LOW       1   Server version disclosed in headers

  Report: docs/security/api-audit.md
  Remediation: 7 findings with fix code + verification commands
```

Every finding has code evidence, severity, and a concrete fix. Not just warnings -- actionable remediations.

### Autonomous Bug Fix

```
$ /godmode:fix
Error: Tests failing in CI — TypeError: Cannot read property 'id' of undefined

  ▸ INVESTIGATE  Reproduced locally, traced to UserService.getProfile()
  ▸ ROOT CAUSE   Null user returned when session expires mid-request
  ▸ FIX          Added null guard + early return with 401
  ▸ VERIFY       All 84 tests passing, error no longer reproducible
  ▸ REGRESSION   Added test for expired-session edge case

  === Fix Complete ===
  1 root cause | 1 fix | 1 regression test | 84/84 tests passing
```

Scientific debugging: reproduce, hypothesize, fix, verify, add regression test. No guessing.

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

Every iterative skill follows the same loop:

1. **REVIEW** -- read state, logs, git history
2. **IDEATE** -- pick the next change
3. **MODIFY** -- make the change, commit before verify
4. **VERIFY** -- run guard (tests + lint + build must all pass)
5. **DECIDE** -- improved --> KEEP. Worse --> DISCARD (git reset)
6. **LOG** -- append to `.godmode/<skill>-results.tsv`

This loop runs autonomously. No human approval needed between iterations.

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

| Skill | Purpose |
|--|--|
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

| Skill | Purpose |
|--|--|
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

| Skill | Purpose |
|--|--|
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

| Skill | Purpose |
|--|--|
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

| Skill | Purpose |
|--|--|
| `postgres` | PostgreSQL |
| `redis` | Redis |
| `nosql` | NoSQL design |

### Security & Compliance (8)

| Skill | Purpose |
|--|--|
| `secure` | STRIDE + OWASP audit with red-team |
| `auth` | Authentication flows |
| `rbac` | Role-based access control |
| `secrets` | Secrets management |
| `crypto` | Cryptographic review |
| `pentest` | Penetration testing |
| `devsecops` | Security pipeline |
| `comply` | Compliance (GDPR, HIPAA, SOC 2) |

### Testing (7)

| Skill | Purpose |
|--|--|
| `e2e` | End-to-end testing |
| `integration` | Integration testing |
| `loadtest` | Load and stress testing |
| `lint` | Linter setup and custom rules |
| `type` | Type system design |
| `perf` | Performance profiling |
| `webperf` | Web vitals optimization |

### DevOps & Infrastructure (16)

| Skill | Purpose |
|--|--|
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

### Frontend & UI (9)

| Skill | Purpose |
|--|--|
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

| Skill | Purpose |
|--|--|
| `ml` | ML pipeline design |
| `mlops` | Model deployment |
| `rag` | Retrieval-Augmented Generation |
| `prompt` | Prompt engineering |
| `eval` | LLM evaluation |

### Developer Experience (13)

| Skill | Purpose |
|--|--|
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

| Skill | Purpose |
|--|--|
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

| Platform | Status | Agents | Setup |
|----------|--------|--------|-------|
| **Claude Code** | Full support | Parallel via `Agent` tool + worktrees | `claude plugin install godmode` |
| **Codex** | Full support | Native `.codex/agents/*.toml` | Clone + use `.codex/` config |
| **Cursor** | Full support | Background agents | `bash adapters/cursor/install.sh` |
| **Gemini CLI** | Full support | Sequential execution | `bash adapters/gemini/install.sh` |
| **OpenCode** | Full support | Sequential execution | `bash adapters/opencode/install.sh` |

All 126 skills work on every platform. Skills that use parallel agents (build, optimize, review) automatically degrade to sequential execution on platforms without native agent dispatch.

Each platform adapter includes a verification script to confirm correct installation:

```bash
bash adapters/gemini/verify.sh      # Verify Gemini CLI setup
bash adapters/opencode/verify.sh    # Verify OpenCode setup
bash adapters/cursor/verify.sh      # Verify Cursor setup
bash adapters/codex/verify.sh       # Verify Codex setup
```

See [adapters/](adapters/) for platform-specific setup and [docs/platform-comparison.md](docs/platform-comparison.md) for a detailed comparison.

---

## What Users Say

> *"I pointed godmode:optimize at a slow endpoint and walked away. Came back to a 76% improvement with every change individually committed and verified."*
> -- **Example quote** (placeholder)

> *"The security audit found a SQL injection I missed in code review. It didn't just flag it -- it gave me the fix and a command to verify the fix worked."*
> -- **User testimonial** (placeholder)

> *"We used godmode:build to add a full auth system. Four agents worked in parallel, and the merge was clean. That would have been a full day of work."*
> -- **Success story** (placeholder)

*These are example quotes illustrating typical use cases. If you have a real testimonial, [open a discussion](https://github.com/arbazkhan971/godmode/discussions) and we will feature it here.*

---

## Contributing

Every skill is a Markdown file. If you can write clear instructions, you can add a skill.

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for the complete guide, including:

- [Adding a New Skill](CONTRIBUTING.md#complete-skill-creation-guide) -- step-by-step from directory creation to PR
- [Skill Quality Checklist](CONTRIBUTING.md#skill-quality-checklist) -- every required section and standard
- [Adding a New Platform Adapter](CONTRIBUTING.md#adding-a-new-platform-adapter) -- how to support a new AI coding tool
- [Testing Your Changes](CONTRIBUTING.md#testing-your-skill) -- 6 test levels from readability to live execution
- [Style Guide](CONTRIBUTING.md#skill-writing-style-guide) -- how to write skills that AI agents execute reliably

---

## License

MIT -- see [LICENSE](LICENSE).

---

<div align="center">

**Discipline before speed. Evidence before claims. Git is memory.**

**[Install](https://github.com/arbazkhan971/godmode)** · **[Docs](docs/)** · **[Discuss](https://github.com/arbazkhan971/godmode/discussions)**

</div>
