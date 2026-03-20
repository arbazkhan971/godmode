# Codex Configuration Guide for Godmode

## System Prompt Loading

Codex loads its system prompt from `AGENTS.md` in the repository root. This file contains the full Godmode workflow, skill catalog, subagent definitions, and usage instructions. Codex reads it automatically when it starts a session.

No additional prompt configuration is needed. The `AGENTS.md` file is the single source of truth for agent behavior.

## Invoking Skills in Codex

Codex runs in batch mode. Provide the skill invocation in your task description:

```bash
# Direct skill invocation
codex "Run /godmode:optimize to reduce API latency"
codex "Run /godmode:secure to audit the authentication module"
codex "Run /godmode:test to add coverage for src/services/"
codex "Run /godmode:build to implement the webhook handler"
codex "Run /godmode:review to review the last 3 commits"

# Orchestrator auto-routing (detects the right skill)
codex "Run /godmode -- make the search endpoint faster"
codex "Run /godmode -- fix the CI failures"
codex "Run /godmode -- build a rate limiter for the API"
```

When invoked, the agent reads `./skills/<skill-name>/SKILL.md` and follows the workflow defined there step by step.

## Agent TOML Format

Codex defines agents using TOML files in `.codex/agents/`. Each file configures one subagent with a name, model, sandbox mode, and developer instructions.

### Reference

The existing agent definitions live at `.codex/agents/` in the Godmode repo root:

| File | Agent | Sandbox Mode |
|------|-------|-------------|
| `planner.toml` | Decomposes goals into parallel tasks | `read-only` |
| `builder.toml` | Executes implementation tasks | `workspace-write` |
| `reviewer.toml` | Reviews code for correctness and security | `read-only` |
| `optimizer.toml` | Runs the autonomous optimization loop | `workspace-write` |
| `explorer.toml` | Maps codebase structure | `read-only` |
| `security.toml` | STRIDE + OWASP security audit | `read-only` |
| `tester.toml` | Writes tests following TDD | `workspace-write` |

### TOML Structure

Each agent TOML file follows this structure:

```toml
name = "godmode_<role>"
description = "What this agent does. When to use it."
model = "gpt-5.4"
model_reasoning_effort = "high"        # low | medium | high | xhigh
sandbox_mode = "read-only"             # read-only | workspace-write
nickname_candidates = ["Name1", "Name2", "Name3"]

developer_instructions = """
Multi-line instructions for the agent.
These define the agent's behavior, workflow, and output format.
"""
```

**Key fields:**

- `model` -- the OpenAI model to use for the agent. Higher-capability models for complex tasks (builder, optimizer, security), lighter models for reconnaissance (explorer).
- `model_reasoning_effort` -- controls how much reasoning the model applies. Use `high` or `xhigh` for tasks requiring deep analysis.
- `sandbox_mode` -- `read-only` for agents that should never modify files (planner, reviewer, explorer, security). `workspace-write` for agents that create or edit files (builder, optimizer, tester).
- `developer_instructions` -- the system prompt for the agent. Should reference the relevant `skills/<name>/SKILL.md` file and define the output format.

### Global Configuration

The `.codex/config.toml` file controls agent-level settings:

```toml
[agents]
max_threads = 10              # Maximum concurrent agent threads
max_depth = 1                 # Maximum nesting depth for agent calls
job_max_runtime_seconds = 1800  # 30-minute timeout per agent job
```

In practice, Codex processes agent tasks single-threaded despite the `max_threads` setting. The `job_max_runtime_seconds` value is important for long-running skills like `optimize` (which may run 25+ iterations) and `build` (which may execute multi-round dependency graphs).

## Sequential Execution

Codex does not support parallel agent dispatch. When a skill instructs you to "dispatch N agents in parallel," execute each task sequentially instead.

### How It Works

1. The planner decomposes work into rounds of tasks, exactly as it would for parallel execution.
2. Each task in a round is executed one at a time, not concurrently.
3. Each task must pass all guard rails (tests, lint, build) and be committed before the next task starts.
4. If a task fails guard rails after two fix attempts, revert it and move to the next.

### Translation Examples

**"Dispatch 3 builders in parallel"** becomes:
1. Execute builder 1's task to completion, commit.
2. Execute builder 2's task to completion, commit.
3. Execute builder 3's task to completion, commit.

**"Run 4 review passes in parallel"** becomes:
1. Run Correctness review. Collect findings.
2. Run Security review. Collect findings.
3. Run Performance review. Collect findings.
4. Run Style review. Collect findings.
5. Merge and deduplicate all findings.

**"Try 3 optimization approaches in parallel worktrees"** becomes:
1. Try approach A. Measure. If improved, keep.
2. Try approach B. Measure. If better than A, keep B and revert A.
3. Try approach C. Measure. If better than current best, keep C and revert previous.
4. Only the single best result survives each round.

For the complete sequential execution protocol, including worktree fallback, merge conflict handling, and skill-specific instructions, see [`adapters/shared/sequential-dispatch.md`](../shared/sequential-dispatch.md).

## Worktree Fallback

Codex does not have native worktree tools. When a skill references `EnterWorktree` or `ExitWorktree`, use branch-based isolation instead:

```bash
# Create an isolated branch
git checkout -b godmode-{task-name}

# Do the work, test, commit
# ...

# Merge back
git checkout main && git merge godmode-{task-name}

# Clean up
git branch -d godmode-{task-name}
```

If the merge fails or tests fail after merging, abort and log the task as `DISCARDED`. See `adapters/shared/sequential-dispatch.md` for full merge failure handling.

## Tool Mapping

Godmode skills reference tools by their Claude Code names. Codex uses standard shell tools and file operations. Apply this mapping:

| Skill Reference | Codex Equivalent | Notes |
|---|---|---|
| `Read` | Read file contents | Use file reading capability |
| `Write` | Write file contents | Create or overwrite a file |
| `Edit` | Apply edits to a file | Replace strings in a file |
| `Bash` | Run shell commands | Execute shell commands |
| `Grep` | Search file contents | Regex search across files |
| `Glob` | Find files by pattern | File pattern matching |

When a skill instruction says "use Read to examine the file," read the file. When it says "use Bash to run tests," run the shell command. Apply this mapping to every tool reference in every skill.

## Recommended Workflow Order

When running the full Godmode cycle in Codex, execute phases sequentially:

```
THINK -> PLAN -> BUILD -> TEST -> REVIEW -> OPTIMIZE -> SECURE -> SHIP
```

At each phase, load the corresponding skill and follow its workflow before moving to the next.
