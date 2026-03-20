# Godmode Quick Start

**126 skills. 7 subagents. 5 platforms. Zero configuration.**

---

## 1. Pick Your Platform

Install Godmode in your project directory:

| Platform | Install |
|----------|---------|
| **Claude Code** | `claude plugin install godmode` |
| **Cursor** | `bash /path/to/godmode/adapters/cursor/install.sh .` |
| **Gemini CLI** | `bash /path/to/godmode/adapters/gemini/install.sh .` |
| **Codex** | `bash /path/to/godmode/adapters/codex/install.sh .` |
| **OpenCode** | `bash /path/to/godmode/adapters/opencode/install.sh .` |

Replace `/path/to/godmode` with wherever you cloned the repo. For Codex and OpenCode you can also `cd godmode && bash adapters/<platform>/install.sh /path/to/your/project`.

---

## 2. Your First Skill

Every platform uses the same syntax:

```
/godmode:think brainstorm approaches for adding rate limiting to our API
```

Godmode reads your codebase, identifies the stack, and produces a structured spec with trade-offs, risks, and recommendations. The output is identical on all 5 platforms.

---

## 3. The Core Loop

```
THINK -> PLAN -> BUILD -> TEST -> REVIEW -> OPTIMIZE -> SECURE -> SHIP
```

| Phase | Skill | What happens |
|-------|-------|-------------|
| **THINK** | `/godmode:think` | Brainstorm approaches, produce a design spec |
| **PLAN** | `/godmode:plan` | Decompose the spec into atomic, parallelizable tasks |
| **BUILD** | `/godmode:build` | Implement with TDD -- tests first, then code |
| **TEST** | `/godmode:test` | Verify coverage, run RED-GREEN-REFACTOR |
| **REVIEW** | `/godmode:review` | 4-perspective code review (correctness, security, perf, style) |
| **OPTIMIZE** | `/godmode:optimize` | Autonomous measure-modify-verify loop |
| **SECURE** | `/godmode:secure` | STRIDE + OWASP audit with adversarial red-team |
| **SHIP** | `/godmode:ship` | Pre-flight checks, deploy, verify, monitor |

You can enter at any phase. Godmode auto-detects context from your repo state.

---

## 4. Five-Minute Tutorial: Add Rate Limiting to an API

### Step 1: Think

```
/godmode:think Add rate limiting to POST /api/messages -- 100 req/min per user
```

Output: a spec covering token bucket vs sliding window, Redis vs in-memory, middleware placement, and failure modes.

### Step 2: Plan

```
/godmode:plan implement the rate limiting spec from the think phase
```

Output: a task list with dependencies, file assignments, and execution rounds. Example:

```
Round 1: [1] Create rate limiter middleware  [2] Add Redis config
Round 2: [3] Wire middleware into routes (depends on 1, 2)
Round 3: [4] Add integration tests (depends on 3)
```

### Step 3: Build

```
/godmode:build execute the rate limiting plan
```

Godmode dispatches builders (parallel on Claude Code/Cursor, sequential on others). Each builder writes tests first, then implements, then verifies tests pass before committing.

### Step 4: Test

```
/godmode:test verify rate limiting coverage
```

Runs your test suite, identifies gaps, generates missing tests following RED-GREEN-REFACTOR. Every new test starts failing (RED), gets fixed (GREEN), then gets cleaned up (REFACTOR).

### Step 5: Review

```
/godmode:review review the rate limiting implementation
```

Four review passes: correctness, security, performance, and style. Each produces findings with severity and line-level references. On Claude Code and Cursor these run in parallel.

### Step 6: Ship

```
/godmode:ship deploy the rate limiting changes
```

Runs pre-flight checks (tests pass, no lint errors, no secrets in diff), executes dry-run deploy, then real deploy, then post-deploy verification.

---

## 5. What's Different Per Platform

All 126 skills work on every platform. The differences are in execution model:

| Capability | Claude Code | Cursor | Gemini CLI | Codex | OpenCode |
|-----------|-------------|--------|------------|-------|----------|
| **Agent execution** | Parallel (worktrees) | Parallel (background agents) | Sequential | Sequential | Sequential |
| **Isolation** | Git worktrees | Background agents | Active branch | Active branch | Active branch |
| **Skill syntax** | `/godmode:skill` | `/godmode:skill` or `@godmode skill` | `/godmode:skill` | `codex "Run /godmode:skill"` | `/godmode:skill` |
| **Interactive** | Yes | Yes | Yes | No (batch) | Yes |
| **Subagent config** | `agents/*.md` | `.cursorrules` | `GEMINI.md` | `.codex/agents/*.toml` | `AGENTS.md` |

**Parallel vs Sequential:** On Claude Code and Cursor, `build` dispatches up to 5 builders simultaneously. On Gemini CLI, Codex, and OpenCode, the same 5 tasks run one at a time. Same results, different throughput.

**Worktrees vs Branches:** Claude Code isolates each agent in a git worktree (true parallel writes). Cursor uses background agents. The other platforms work on the active branch with atomic commits and automatic rollback on failure.

---

## 6. Next Steps

- **[FAQ](FAQ.md)** -- Common questions and troubleshooting
- **[CONTRIBUTING](../CONTRIBUTING.md)** -- Add your own skills (every skill is just a Markdown file)
- **[Full Skill Catalog](COMPLETE-SKILL-LIST.md)** -- All 126 skills with descriptions
- **[Platform Details](../adapters/)** -- Deep-dive into each adapter
- **[Recipes](recipes/)** -- Pre-built skill chains for common workflows
- **[Philosophy](PHILOSOPHY.md)** -- Why Godmode works the way it does
