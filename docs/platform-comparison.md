# Platform Comparison

Godmode runs on 5 platforms. All 126 skills work everywhere. This document covers what differs: agent dispatch, tool names, installation, and performance.

---

## Feature Matrix

| Feature | Claude Code | Codex | Gemini CLI | OpenCode | Cursor |
|---------|:-----------:|:-----:|:----------:|:--------:|:------:|
| **Skills available** | 126 | 126 | 126 | 126 | 126 |
| **Subagents** | 7 | 7 | 7 | 7 | 7 |
| **Skill discovery** | Native `SKILL.md` | System prompt (`AGENTS.md`) | System prompt (`GEMINI.md`) | Plugin system (`plugin.json`) | Rules file (`.cursorrules`) |
| **Slash commands** | `/godmode:skill` | Batch prompt prefix | Chat commands | `/godmode:skill` (native) | `@godmode skill` or `/godmode:skill` |
| **Parallel agent dispatch** | Native (`Agent` tool) | No -- sequential | No -- sequential | No -- sequential | Background agents |
| **Git worktree isolation** | Native (`EnterWorktree`) | Branch-based fallback | Manual `git worktree` via shell | Not available | Manual / background agent scoped |
| **Tool names** | Native (Read, Write, Edit, Bash, Grep, Glob) | Mapped (generic file/shell ops) | Mapped (read_file, write_file, replace, run_shell_command, grep_search, glob) | Native (Read, Write, Edit, Bash, Grep, Glob) | Native (Read, Write, Edit, Bash, Grep, Glob) |
| **Session hooks** | Yes (session-start) | No | No | Yes (session_start in plugin.json) | No |
| **Interactive setup** | `/godmode:setup` wizard | No -- batch mode only | `/godmode:setup` in chat | `/godmode:setup` in chat | `@godmode setup` in chat |
| **Loop behavior** | Parallel (multi-agent per round) | Sequential (one agent per round) | Sequential (one agent per round) | Sequential (one agent per round) | Parallel (background agents) |
| **Background execution** | Agent tool runs in parallel | Entire session is batch | No | No | Background agents |
| **Config file format** | `.godmode/config.yaml` | `.godmode/config.yaml` + `.codex/config.toml` + `.codex/agents/*.toml` | `.godmode/config.yaml` | `.godmode/config.yaml` + `.opencode/plugins/godmode/plugin.json` | `.godmode/config.yaml` + `.cursorrules` |
| **Install method** | `claude plugin install godmode` | `bash adapters/codex/install.sh` | `bash adapters/gemini/install.sh` | `bash adapters/opencode/install.sh` | `bash adapters/cursor/install.sh` |
| **Agent definitions** | `agents/*.md` | `.codex/agents/*.toml` | `agents/*.md` (read manually) | `agents/*.md` (read manually) | `agents/*.md` (read manually) |

---

## Performance Comparison

Sequential execution produces identical results. Only wall-clock time differs.

| Skill | Parallel Tasks | Claude Code | Codex | Gemini CLI | OpenCode | Cursor |
|-------|---------------|:-----------:|:-----:|:----------:|:--------:|:------:|
| **Single-threaded skills** | 1 | 1x | 1x | 1x | 1x | 1x |
| **Build** (per round) | 5 agents | 1x | ~5x | ~5x | ~5x | ~1x |
| **Optimize** (per round) | 3 agents | 1x | ~3x | ~3x | ~3x | ~1x |
| **Review** (total) | 4 passes | 1x | ~4x | ~4x | ~4x | ~1x |

**Key takeaways:**

- **Claude Code** and **Cursor** run multi-agent skills in parallel -- same wall-clock time as a single agent.
- **Codex**, **Gemini CLI**, and **OpenCode** run the same tasks sequentially -- correct results, longer runtime.
- Single-threaded skills (think, plan, debug, fix, secure, ship, and all 111 domain skills) run at identical speed on every platform.
- The slowdown is purely wall-clock. Verification logic, rollback behavior, output format, and decision quality are the same everywhere.

---

## Migration Guide

Switching between platforms is straightforward because Godmode's state layer is platform-agnostic.

### Shared state: `.godmode/` directory

The `.godmode/` directory is shared across all platforms. It contains:

```
.godmode/
  config.yaml              # Project configuration (language, test/lint commands, scope)
  optimize-results.tsv     # Optimization history
  fix-log.tsv              # Fix attempt history
  ship-log.tsv             # Deployment history
  state.json               # Current skill state (if active)
```

Switch platforms without losing state. Start an optimize run on Claude Code, continue it on Cursor -- the TSV logs and config carry over.

### TSV logs are platform-agnostic

Every platform writes the same tab-separated log format. Columns, keep/revert decisions, and metric values are identical regardless of which platform produced them. You can analyze results across platforms with the same scripts.

### Skills are identical -- only invocation syntax differs

| Action | Claude Code | Codex | Gemini CLI | OpenCode | Cursor |
|--------|-------------|-------|------------|----------|--------|
| Run optimize | `/godmode:optimize` | `codex "Run /godmode:optimize ..."` | `/godmode:optimize` | `/godmode:optimize` | `@godmode optimize` |
| Run secure | `/godmode:secure` | `codex "Run /godmode:secure ..."` | `/godmode:secure` | `/godmode:secure` | `@godmode secure` |
| Auto-route | `/godmode make it faster` | `codex "Run /godmode -- make it faster"` | `/godmode make it faster` | `/godmode make it faster` | `@godmode make it faster` |

The underlying SKILL.md files are the same. Only the invocation surface changes.

### Switching platforms: checklist

1. Install the target platform's adapter (see install methods in the feature matrix).
2. Verify `skills/` and `agents/` are accessible (symlinked or copied).
3. Confirm `.godmode/config.yaml` exists with correct test/lint commands.
4. Run `/godmode:verify` (or equivalent) to confirm the setup works.
5. Continue where you left off -- all TSV logs and git history are intact.

---

## Platform-Specific Tips

### Claude Code

- **Maximize parallel agents.** Claude Code is the only platform with native `Agent` tool dispatch. Use `build` (5 agents/round), `optimize` (3 agents/round), and `review` (4 passes) to their full potential.
- **Use worktree isolation.** The `EnterWorktree`/`ExitWorktree` tools give each agent a clean working directory. This prevents merge conflicts during parallel builds.
- **Skill discovery is automatic.** Claude Code reads `SKILL.md` files natively -- no system prompt injection or config files needed.
- **Reference loading via `@references/`.** Skills can pull in context files automatically, which is not available on other platforms.
- **Visual companion.** Claude Code supports opening browser-based dashboards for real-time monitoring during optimize/ship runs.

### Codex

- **Batch mode optimization.** Codex has no interactive session. Provide all context upfront in the task description: goal, constraints, file scope, and success criteria.
- **Agent TOML configuration.** Subagents are defined in `.codex/agents/*.toml` with fields for model, reasoning effort, and sandbox mode. Tune `model_reasoning_effort` (`low`/`medium`/`high`/`xhigh`) per agent role.
- **Set runtime limits.** Long-running skills (optimize with 25 iterations, large builds) need adequate `job_max_runtime_seconds` in `.codex/config.toml`. Default is 1800s (30 min).
- **No mid-execution prompts.** Codex cannot ask clarifying questions. Make sure `/godmode:setup` has been run (or `config.yaml` is complete) before invoking skills.
- **Branch-based isolation.** Without worktrees, Codex uses `git checkout -b godmode-{task}` for isolation. Tasks merge back to the base branch sequentially.

### Gemini CLI

- **Tool mapping gotchas.** Every skill references Claude Code tool names. You must mentally (or mechanically) translate: `Read` becomes `read_file`, `Edit` becomes `replace`, `Bash` becomes `run_shell_command`, `Grep` becomes `grep_search`. The full mapping is in `adapters/gemini/gemini-config.md`.
- **System prompt via GEMINI.md.** Gemini CLI reads `GEMINI.md` from the project root. The installer symlinks this from the Godmode repo.
- **Manual worktree commands.** Use `run_shell_command("git worktree add ...")` when a skill calls for worktree isolation. For simple single-file changes, skip worktrees entirely and work on the current branch.
- **Agent fallback.** When a skill says `Agent(explorer, ...)`, read `agents/explorer.md` and execute the workflow directly in your session. There is no dispatch mechanism.
- **Sequential is fine.** The optimize loop, build rounds, and review passes all produce identical output in sequential mode. Do not try to work around the lack of parallelism.

### OpenCode

- **Native slash commands.** OpenCode supports `/godmode:skill` natively -- no workarounds or chat prefix hacks needed. This is the cleanest invocation surface outside Claude Code.
- **Plugin system.** OpenCode uses `plugin.json` for skill registration. The manifest at `.opencode/plugins/godmode/plugin.json` declares all 126 skills, 7 agents, and the session hook.
- **Session hooks.** OpenCode supports `session_start` hooks for auto-loading project state. This runs automatically when you open a session.
- **Tool names match.** OpenCode uses the same tool names as Claude Code (Read, Write, Edit, Bash, Grep, Glob). No translation needed.
- **Sequential dispatch only.** Like Gemini CLI and Codex, multi-agent skills run one task at a time. The planner still decomposes work into rounds -- builders just execute sequentially within each round.

### Cursor

- **Background agent patterns.** Cursor's background agents enable parallel execution similar to Claude Code. The `build`, `optimize`, and `review` skills all dispatch background agents concurrently.
- **`.cursorrules` optimization.** The entire Godmode instruction set is condensed into `.cursorrules`. Keep this file up to date when upgrading Godmode -- it is the single source of agent behavior in Cursor.
- **Dual invocation syntax.** Both `@godmode skill` and `/godmode:skill` work. Use whichever fits your workflow.
- **Tool names match.** Cursor uses Read, Write, Edit, Bash, Grep, Glob -- no mapping required.
- **Auto-detection works.** Describe what you want in natural language and Cursor routes to the right skill, just like Claude Code. Example: "make this API faster" routes to optimize.
- **Symlinked skills and agents.** The installer symlinks `skills/` and `agents/` from the Godmode repo. If you move the Godmode clone, re-run the installer to fix broken symlinks.

---

## Quick Reference: Which Platform When?

| Scenario | Best platform | Why |
|----------|--------------|-----|
| Maximum throughput (large builds) | Claude Code or Cursor | Native parallel agent dispatch |
| CI/CD integration | Codex | Batch mode, no interactive prompts |
| Quick single-skill runs | Any | All platforms handle single-threaded skills identically |
| Existing Cursor workflow | Cursor | Background agents + familiar UX |
| Gemini ecosystem | Gemini CLI | System prompt integration via GEMINI.md |
| OpenCode ecosystem | OpenCode | Native slash commands + plugin system |

---

## See Also

- `adapters/shared/sequential-dispatch.md` -- full sequential execution protocol
- `adapters/*/README.md` -- platform-specific setup instructions
- `adapters/gemini/gemini-config.md` -- Gemini CLI tool mapping reference
- `adapters/codex/codex-config.md` -- Codex TOML agent configuration
- `docs/godmode-design.md` section 30 -- platform support architecture
