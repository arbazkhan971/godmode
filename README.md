<div align="center">

# Godmode — Autonomous AI Coding Agent for Claude Code, Cursor, Codex & Gemini

### Your AI writes code. Godmode makes it write *great* code — then proves it.

The open-source autonomous coding agent that turns AI assistants into engineering systems. 126 skills for building, testing, optimizing, securing, and shipping software — with iterative optimization, parallel multi-agent execution, automatic rollback, and failure memory. Plugin for Claude Code, Cursor, Codex, Gemini CLI, and OpenCode.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-126-ff6b6b.svg)](skills/)
[![Agents](https://img.shields.io/badge/subagents-7-ff9f43.svg)](agents/)
[![Claude Code](https://img.shields.io/badge/Claude_Code-supported-4A90D9.svg)](adapters/)
[![Codex](https://img.shields.io/badge/Codex-supported-10A37F.svg)](adapters/codex/)
[![Gemini CLI](https://img.shields.io/badge/Gemini_CLI-supported-4285F4.svg)](adapters/gemini/)
[![Cursor](https://img.shields.io/badge/Cursor-supported-000000.svg)](adapters/cursor/)
[![OpenCode](https://img.shields.io/badge/OpenCode-supported-7C3AED.svg)](adapters/opencode/)

</div>

> **TL;DR:** Install with `claude plugin install godmode`. Say `/godmode optimize my API` and walk away. It measures, iterates, keeps improvements, reverts failures, and stops when done.

---

## See It In Action

### Performance Optimization — 847ms to 198ms, fully autonomous

```
$ /godmode:optimize
Goal: Reduce API response time
Iterations: 20

  BASELINE    847ms
  ROUND 1     554ms  KEPT  (-34.5%)  -- added index on category_id
  ROUND 2     382ms  KEPT  (-31.0%)  -- enabled gzip compression
  ROUND 3     276ms  KEPT  (-27.7%)  -- eager loading for posts
  ROUND 4     290ms  REVERTED        -- batch loader (guard failed)
  ROUND 5     226ms  KEPT  (-18.2%)  -- connection pool to 20
  ROUND 6     198ms  KEPT  (-12.4%)  -- Redis response cache

  === 847ms --> 198ms (76.6% improvement) ===
  Keeps: 5 | Discards: 1
```

### Multi-Agent Build — 4 agents, isolated worktrees, clean merge

```
$ /godmode:build
Goal: Add user authentication system

  PLAN        Decomposed into 4 parallel tasks
  AGENT 1     [worktree] Auth middleware + JWT tokens        DONE
  AGENT 2     [worktree] User model + password hashing       DONE
  AGENT 3     [worktree] Login/register API endpoints         DONE
  AGENT 4     [worktree] Integration tests for auth flow      DONE
  MERGE       Sequential merge + test after each              ALL PASS
  REVIEW      4-agent code review (security, perf, style)     APPROVED

  === 4 tasks | 4 agents | 12 files | 47 tests passing ===
```

### Security Audit — STRIDE + OWASP + red team

```
$ /godmode:secure
Target: src/api/

  RECON       Mapped 23 endpoints, 4 auth flows, 2 data stores
  STRIDE      6 threat categories analyzed
  OWASP       Top 10 checklist applied
  RED TEAM    4 personas: script kiddie, insider, APT, researcher

  CRITICAL  1   SQL injection in /api/search (parameterize query)
  HIGH      2   Missing rate limit on /api/login, weak CORS policy
  MEDIUM    3   Verbose error messages, missing CSP header, session fixation
  LOW       1   Server version disclosed in headers

  7 findings with fix code + verification commands
```

Every finding comes with code evidence, severity, a concrete fix, and a command to verify the fix works.

---

## Quick Start

```bash
# Install (Claude Code)
claude plugin install godmode

# Or install for other platforms
bash adapters/cursor/install.sh
bash adapters/gemini/install.sh
bash adapters/opencode/install.sh
```

```bash
# Use specific skills
/godmode:optimize   # Autonomous performance iteration
/godmode:build      # Build with parallel agents
/godmode:secure     # Security audit
/godmode:ship       # Pre-flight + deploy + verify

# Or just describe what you want
/godmode make this API faster       # --> routes to optimize
/godmode fix the failing tests      # --> routes to fix
/godmode build a rate limiter       # --> routes to think --> plan --> build
```

Godmode auto-detects what you need and routes to the right skill.

---

## What Is Godmode?

Godmode is an open-source plugin that adds autonomous coding capabilities to AI assistants like Claude Code, Cursor, Codex, Gemini CLI, and OpenCode. Instead of generating code once and hoping it works, Godmode runs a disciplined engineering loop: **measure, modify, verify, keep or revert, repeat** — until the goal is met.

It ships with 126 expert skills (performance optimization, security auditing, TDD, deployment, database tuning, and more), 7 specialized subagents that work in parallel, and a failure memory system that learns from every discarded change.

## How Godmode Compares to Plain AI Coding

| Problem | Godmode's answer |
|---|---|
| AI generates code once and stops | Autonomous iteration loops that run until the goal is met |
| No way to know if a change helped | Every change is benchmarked against a mechanical metric |
| Bad changes stay in the codebase | Automatic git revert on any regression |
| Complex tasks bottleneck on one agent | Up to 5 parallel agents in isolated git worktrees |
| AI repeats the same mistakes | Failure memory classifies and logs every failed approach |
| Crashes lose all progress | Session state persists and auto-resumes |
| Improvements might be noise | Variance testing and generalization gates prevent overfitting |

---

## How It Works

Every iterative skill follows the same disciplined loop:

```
1. REVIEW   -- read state, logs, git history
2. IDEATE   -- pick the next change (informed by past failures)
3. MODIFY   -- make ONE atomic change, commit before verify
4. VERIFY   -- run guard (tests + lint + build must all pass)
5. DECIDE   -- improved --> KEEP. Worse --> DISCARD (git reset)
6. LOG      -- append to .godmode/<skill>-results.tsv
7. REPEAT   -- until goal met or iteration budget exhausted
```

No human approval needed between iterations. Every experiment is committed to git. Every discard is classified and remembered.

### The Full Pipeline

```
THINK --> PLAN --> BUILD --> TEST --> FIX --> OPTIMIZE --> SECURE --> SHIP
```

Godmode detects which phase you're in and routes to the right skill. Skills chain automatically — optimize finds an issue, triggers fix, re-optimizes, then ships.

### Failure Intelligence

Every discard is classified into one of 8 failure types and logged to `.godmode/<skill>-failures.tsv`. On 3+ consecutive failures, the agent writes a reflective diagnosis analyzing the pattern before trying again. Lessons persist in `.godmode/lessons.md` across sessions.

### Multi-Agent Execution

Complex tasks are decomposed and run in parallel:

```
Round 1:  Agent 1 [worktree] --\
          Agent 2 [worktree] ---+-- merge + test
          Agent 3 [worktree] --/
Round 2:  Agent 4 [worktree] --\
          Agent 5 [worktree] ---+-- merge + test
```

Max 5 agents per round. Each gets its own git worktree. Merge sequentially, test after each merge.

---

## Subagents (7)

| Agent | Role |
|-------|------|
| **planner** | Decomposes goals into parallel tasks |
| **builder** | Implements tasks with TDD in isolated worktrees |
| **reviewer** | Code review for correctness, security, performance, style |
| **optimizer** | Autonomous measure --> modify --> verify loop |
| **explorer** | Read-only codebase reconnaissance |
| **security** | STRIDE + OWASP audit with 4 adversarial personas |
| **tester** | TDD test generation, RED-GREEN-REFACTOR |

---

## Skills (126)

Godmode includes 126 skills across 12 domains. Each skill encodes a real engineering workflow — not just instructions, but a complete protocol with verification steps.

| Domain | Count | Highlights |
|--------|-------|------------|
| **Core Workflow** | 15 | `godmode` `think` `plan` `build` `test` `review` `optimize` `debug` `fix` `ship` `verify` |
| **Architecture & Design** | 10 | `architect` `rfc` `ddd` `pattern` `schema` `distributed` `scale` `migration` |
| **API & Backend** | 14 | `api` `graphql` `grpc` `orm` `cache` `queue` `event` `realtime` `webhook` |
| **Frameworks** | 12 | `react` `nextjs` `vue` `svelte` `node` `fastapi` `django` `rails` `spring` |
| **Security & Compliance** | 8 | `secure` `auth` `rbac` `pentest` `devsecops` `comply` |
| **Testing** | 7 | `e2e` `integration` `loadtest` `perf` `webperf` |
| **DevOps & Infra** | 16 | `k8s` `docker` `cicd` `ghactions` `infra` `observe` `resilience` |
| **Frontend & UI** | 9 | `ui` `a11y` `seo` `mobile` `designsystem` `responsive` |
| **Databases** | 3 | `postgres` `redis` `nosql` |
| **AI & ML** | 5 | `ml` `mlops` `rag` `prompt` `eval` |
| **Developer Experience** | 13 | `docs` `refactor` `git` `pr` `monorepo` `changelog` `slo` |
| **Integrations** | 14 | `i18n` `pay` `cli` `agent` `feature` `chaos` `experiment` |

Full skill reference: [skills/](skills/)

---

## Platforms

| Platform | Agents | Setup |
|----------|--------|-------|
| **Claude Code** | Parallel (worktrees) | `claude plugin install godmode` |
| **Codex** | Native agents | Clone + use `.codex/` config |
| **Cursor** | Background agents | `bash adapters/cursor/install.sh` |
| **Gemini CLI** | Sequential | `bash adapters/gemini/install.sh` |
| **OpenCode** | Sequential | `bash adapters/opencode/install.sh` |

All 126 skills work on every platform. Parallel agent skills automatically degrade to sequential on platforms without native agent dispatch.

Verify your installation: `bash adapters/<platform>/verify.sh`

---

## Philosophy

**Discipline before speed.** Every change is measured. Bad changes are reverted.

**Evidence before claims.** "Looks good" is rejected. Numeric proof is required.

**Git is memory.** Every experiment is committed. Every revert is in the log.

**Keep or discard.** Binary decisions only. No maybes.

**Learn from failure.** Every discard is classified and remembered.

**Simplicity first.** Complex changes that marginally improve metrics are discarded.

---

## Contributing

Every skill is a Markdown file. If you can write clear instructions, you can add a skill.

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for the complete guide:

- [Adding a New Skill](CONTRIBUTING.md#complete-skill-creation-guide)
- [Skill Quality Checklist](CONTRIBUTING.md#skill-quality-checklist)
- [Adding a New Platform Adapter](CONTRIBUTING.md#adding-a-new-platform-adapter)
- [Testing Your Changes](CONTRIBUTING.md#testing-your-skill)
- [Style Guide](CONTRIBUTING.md#skill-writing-style-guide)

---

## Frequently Asked Questions

<details>
<summary><strong>How does Godmode differ from Copilot, Cursor, or other AI coding tools?</strong></summary>

Godmode is not a replacement for these tools — it's a plugin that makes them better. Copilot and Cursor generate code in a single pass. Godmode adds autonomous iteration: it measures results, keeps improvements, reverts failures, and repeats until the goal is met. It works *inside* Cursor and Claude Code, not instead of them.
</details>

<details>
<summary><strong>Does Godmode work with any programming language?</strong></summary>

Yes. Godmode skills are language-agnostic — they define engineering workflows (test, measure, verify), not language-specific syntax. If your AI assistant supports a language, Godmode's skills work with it. Framework-specific skills (React, Django, Rails, etc.) provide additional specialized guidance.
</details>

<details>
<summary><strong>Can I use Godmode for free?</strong></summary>

Godmode itself is free and open source (MIT license). You need a working installation of one of the supported AI coding tools (Claude Code, Cursor, Codex, Gemini CLI, or OpenCode), which may have their own pricing.
</details>

<details>
<summary><strong>What does "autonomous" mean? Does it run without human input?</strong></summary>

Yes. Once you set a goal and a metric (e.g., "reduce API latency, measured by `curl -w '%{time_total}'`"), Godmode runs the optimization loop autonomously — modifying code, verifying results, keeping improvements, reverting failures — without asking for approval between iterations. You can set an iteration limit or let it run until interrupted.
</details>

<details>
<summary><strong>Is it safe? Can it break my code?</strong></summary>

Every change is committed to git *before* verification. If a change makes things worse, it's automatically reverted with `git reset`. Your codebase never stays in a broken state. Guard commands (tests, linting, build) must pass for any change to be kept.
</details>

<details>
<summary><strong>How do I add my own skills?</strong></summary>

Every skill is a Markdown file. Copy an existing skill, modify it, and drop it in the `skills/` directory. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full guide.
</details>

---

## License

MIT -- see [LICENSE](LICENSE).

---

<div align="center">

**Discipline before speed. Evidence before claims. Git is memory.**

**[Install](#quick-start)** | **[Docs](docs/)** | **[FAQ](docs/FAQ.md)** | **[Troubleshooting](docs/troubleshooting.md)** | **[Discuss](https://github.com/arbazkhan971/godmode/discussions)**

</div>
