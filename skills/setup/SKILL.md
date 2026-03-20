---
name: setup
description: |
  Configuration wizard. Auto-detects project stack, validates commands, saves .godmode/config.yaml. Triggers on: /godmode:setup, first-time use (no .godmode/), or when a skill needs config that doesn't exist.
---

# Setup — Configuration Wizard

## Activate When
- `/godmode:setup` or first time using Godmode (no `.godmode/` directory)
- A skill needs a verify/test command but none is configured
- User wants to change optimization targets or settings

## Workflow

1. **DETECT** — Scan root for `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc. Detect language, framework, test runner, lint tool, CI, package manager. Auto-detect everything possible before asking.
2. **VALIDATE COMMANDS** — For each detected command (test, lint, typecheck, build): run it. If it fails, ask user for alternative. Never accept a command without running it.
3. **CONFIGURE OPTIMIZATION** (if needed) — Ask what to optimize. Set verify command, metric, target. Run verify command 3 times to confirm stable baseline.
4. **DEFINE SCOPE** — Source dirs, test dirs, out-of-scope dirs (node_modules, dist, .git, etc).
5. **SAVE CONFIG** — Write `.godmode/config.yaml`:
   ```yaml
   project: { name, language, framework }
   commands: { test, lint, typecheck, build }
   optimization: { goal, metric, verify, target, max_iterations: 25 }
   scope: { include: [...], exclude: [...] }
   guard_rails: [{ command, name, must_pass: true }, ...]
   ```
6. **FINAL VALIDATION** — Run all configured commands once. Print results. Commit config.

## Key Behaviors
- Auto-detect first, ask second. One question at a time.
- Validate every command by running it. A wrong test command wastes hours.
- Provide sensible defaults. User should be able to accept defaults and go.
- Dry-run verify command 3 times to confirm stability.
- Save everything to `.godmode/` for version control.

## Platform Detection

Between DETECT and VALIDATE COMMANDS, detect the host platform:

1. **Check indicators** (first match wins):
   - **Claude Code** — `Agent()` tool and `EnterWorktree` tool available
   - **Gemini CLI** — `read_file`, `write_file`, `run_shell_command` tools available
   - **OpenCode** — slash command support present, no `Agent()` tool
   - **Codex** — batch mode active or `.codex/` directory exists in project root
   - **Cursor** — `.cursorrules` file present or background agents available
   - **Unknown** — none of the above; default to sequential, manual worktrees

2. **Report capabilities** — Print exactly:
   `Detected platform: {platform}. Parallel agents: {yes/no}. Worktrees: {native/manual/branch-based}.`

   | Platform    | Parallel agents | Worktrees    |
   |-------------|-----------------|--------------|
   | Claude Code | yes             | native       |
   | Gemini CLI  | no              | manual       |
   | OpenCode    | no              | manual       |
   | Codex       | no              | branch-based |
   | Cursor      | no              | manual       |

3. **Sequential fallback** — For non-Claude-Code platforms, note that skills using parallel dispatch will run sequentially. Reference `adapters/shared/sequential-dispatch.md` for details.

4. **Save to config** — Add `platform: { name, parallel_agents, worktree_mode }` to `.godmode/config.yaml`.

## HARD RULES

1. NEVER accept a test/lint/verify command without running it first.
2. NEVER store secrets in `.godmode/config.yaml`. Use env vars or secrets manager.
3. NEVER skip validation of the verify command. Run 3 times minimum.
4. NEVER overwrite existing `.godmode/config.yaml` without confirmation.
5. NEVER require setup for skills that don't need it (think, debug work without config).
6. ALWAYS commit `.godmode/` to version control.
7. ALWAYS auto-detect before asking the user.
