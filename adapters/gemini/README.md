# Godmode Adapter for Gemini CLI

Use all 126 Godmode skills and 7 subagents from Gemini CLI.

## Installation

**Option A: Installer script**

```bash
cd your-project
bash /path/to/godmode/adapters/gemini/install.sh .
```

**Option B: Manual**

Copy or symlink the root `GEMINI.md` into your project:

```bash
cp /path/to/godmode/GEMINI.md ./GEMINI.md
cp -r /path/to/godmode/skills ./skills
cp -r /path/to/godmode/agents ./agents
cp -r /path/to/godmode/commands ./commands
```

Gemini CLI automatically reads `GEMINI.md` from the project root on startup.

## Usage

Invoke skills with natural language or slash syntax:

```
/godmode:optimize   — autonomous performance iteration
/godmode:secure     — STRIDE + OWASP security audit
/godmode:build      — build with TDD enforcement
/godmode            — auto-detect phase and route
```

Natural language also works:

```
"make this API faster"     → routes to optimize
"fix the failing tests"    → routes to fix
"review my auth module"    → routes to review
```

## Platform Limitations

Gemini CLI does not support parallel agent dispatch or git worktrees natively. All Godmode features still work, but with these constraints:

- **No parallel agents.** When a skill says "dispatch 3 agents in parallel," execute them sequentially in the current session, one at a time.
- **No worktrees.** When a skill says "EnterWorktree," use `run_shell_command` to run `git worktree add` / `git worktree remove` manually instead.
- **No Agent() dispatch.** When a skill says "Agent(...)", execute the task directly in the current session.

These constraints affect throughput, not capability. Every skill works correctly in sequential mode.

## Reference

- Tool mapping and full configuration: see [gemini-config.md](./gemini-config.md)
- Root GEMINI.md (loaded by Gemini CLI): [../../GEMINI.md](../../GEMINI.md)
- All skills: [../../skills/](../../skills/)
- All agents: [../../agents/](../../agents/)
- All commands: [../../commands/](../../commands/)
