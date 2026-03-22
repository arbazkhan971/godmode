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

## Troubleshooting

### "Skill not found" or empty response

1. Confirm `skills/` directory exists and is accessible from the project root:
   ```bash
   ls skills/godmode/SKILL.md
   ```
2. If using symlinks, verify they are not broken:
   ```bash
   file skills/godmode/SKILL.md   # should show "ASCII text", not "broken symbolic link"
   ```
3. Confirm `GEMINI.md` is in the project root:
   ```bash
   test -f GEMINI.md && echo "OK" || echo "MISSING"
   ```

### Tool name errors

Gemini CLI uses different tool names than Claude Code. If you see errors like "Read is not a function" or "Unknown tool: Edit", the skill is using Claude Code tool names. Translate manually:

| Skill says | You use |
|---|---|
| `Read(...)` | `read_file(...)` |
| `Write(...)` | `write_file(...)` |
| `Edit(...)` | `replace(...)` |
| `Bash(...)` | `run_shell_command(...)` |
| `Grep(...)` | `grep_search(...)` |
| `Glob(...)` | `glob(...)` |

### Agent dispatch errors

If a skill instructs `Agent(builder, ...)` or `SendMessage(...)`, these tools do not exist in Gemini CLI. Execute the agent's task directly in your current session. Read the agent definition file (e.g., `agents/builder.md`) and follow its workflow manually.

### Sequential mode producing different results

It should not. If you observe different outcomes between Gemini CLI and Claude Code, check:
1. Both are using the same `config.yaml` (same test_cmd, lint_cmd, build_cmd).
2. Both are running against the same git commit.
3. No environment differences (Node version, Python version, etc.).

## Verification

Run the verification script after installation to confirm everything is wired correctly:

```bash
bash adapters/gemini/verify.sh
```

The script checks:
- `GEMINI.md` exists in the project root
- `skills/` directory is accessible and contains SKILL.md files
- `agents/` directory is accessible and contains agent definitions
- `commands/` directory is accessible for slash command registration
- `.godmode/config.yaml` exists with valid test/lint/build commands

If any check fails, the script prints the specific issue and the command to fix it.

**Manual verification** (if the script is unavailable):

```bash
# 1. Config file exists
cat .godmode/config.yaml

# 2. Skills are readable
head -5 skills/godmode/SKILL.md

# 3. Agents are readable
head -5 agents/planner.md

# 4. Commands are registered
ls commands/godmode/*.md | head -5

# 5. Test a skill invocation
# In Gemini CLI: /godmode:verify claim="setup works" cmd="echo ok"
```

## Reference

- Tool mapping and full configuration: see [gemini-config.md](./gemini-config.md)
- Root GEMINI.md (loaded by Gemini CLI): [../../GEMINI.md](../../GEMINI.md)
- All skills: [../../skills/](../../skills/)
- All agents: [../../agents/](../../agents/)
- All commands: [../../commands/](../../commands/)
