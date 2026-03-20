# Gemini CLI Configuration Guide for Godmode

## Tool Mapping

Godmode skills reference tools by their Claude Code names. Map them to Gemini CLI equivalents:

| Skill Reference | Gemini CLI Tool | Notes |
|---|---|---|
| `Read` | `read_file` | Read file contents |
| `Write` | `write_file` | Create or overwrite a file |
| `Edit` | `replace` | Replace a string in a file |
| `Bash` | `run_shell_command` | Execute shell commands |
| `Grep` | `grep_search` | Search file contents with regex |
| `Glob` | `glob` | Find files by pattern |
| `TodoWrite` | `write_todos` | Write structured task lists |
| `Skill` | `activate_skill` | Invoke a godmode skill |

When a skill instruction says "use Read to examine the file," use `read_file`. When it says "use Bash to run tests," use `run_shell_command`. Apply this mapping to every tool reference in every skill.

## Loading Skills

To load and execute a skill, read its SKILL.md file:

```
read_file("./skills/<skill-name>/SKILL.md")
```

Examples:

```
read_file("./skills/optimize/SKILL.md")   # autonomous performance loop
read_file("./skills/secure/SKILL.md")     # security audit
read_file("./skills/test/SKILL.md")       # TDD enforcement
read_file("./skills/build/SKILL.md")      # implementation with agents
```

After reading, follow the skill's workflow step by step.

## Sequential Execution

Gemini CLI runs in a single session without parallel agent support. When skill instructions reference parallelism, convert to sequential execution:

**"Dispatch 3 agents in parallel"** becomes:
1. Execute agent 1's task to completion.
2. Execute agent 2's task to completion.
3. Execute agent 3's task to completion.

**"Run builder agents in parallel worktrees"** becomes:
1. Complete builder 1's task, commit.
2. Complete builder 2's task, commit.
3. Complete builder 3's task, commit.

**"Launch 5 agents per round, max 3 rounds"** becomes:
1. Execute all 5 tasks sequentially in round 1.
2. Execute all tasks sequentially in round 2.
3. Continue until done.

The output is identical. Only throughput differs.

## Worktree Fallback

Some skills use `EnterWorktree` and `ExitWorktree` to isolate work in separate git worktrees. Gemini CLI does not have these tools natively. Use `run_shell_command` instead:

**Creating a worktree:**

```
run_shell_command("git worktree add /tmp/godmode-wt-taskname -b godmode/taskname")
```

**Working in the worktree:**

```
# Read/write files using the worktree path
read_file("/tmp/godmode-wt-taskname/src/example.ts")
run_shell_command("cd /tmp/godmode-wt-taskname && npm test")
```

**Merging and cleaning up:**

```
run_shell_command("git merge godmode/taskname")
run_shell_command("git worktree remove /tmp/godmode-wt-taskname")
run_shell_command("git branch -d godmode/taskname")
```

If worktree isolation is not critical for the task (e.g., small changes, single-file edits), skip worktrees entirely and work directly on the current branch.

## Agent Fallback

Skills may reference `Agent(role, task)` to dispatch a subagent. In Gemini CLI, execute the agent's task directly in the current session:

**"Agent(explorer, 'map the auth module')"** becomes:

```
read_file("./agents/explorer.md")
# Then follow the explorer workflow: read files, trace dependencies, summarize
```

**"Agent(reviewer, 'review the PR changes')"** becomes:

```
read_file("./agents/reviewer.md")
# Then follow the reviewer workflow: check correctness, security, performance
```

**"Agent(tester, 'write tests for user service')"** becomes:

```
read_file("./agents/tester.md")
# Then follow the tester workflow: RED-GREEN-REFACTOR cycle
```

For multi-agent workflows (e.g., planner dispatches 3 builders), read the planner agent file, decompose the tasks, then execute each builder task sequentially:

```
read_file("./agents/planner.md")
# Decompose into tasks: task1, task2, task3

read_file("./agents/builder.md")
# Execute task1 to completion, commit

# Execute task2 to completion, commit

# Execute task3 to completion, commit
```

## Recommended Workflow Order

When running the full godmode cycle, execute phases sequentially:

```
THINK → PLAN → BUILD → TEST → REVIEW → OPTIMIZE → SECURE → SHIP
```

At each phase, load the corresponding skill and follow its workflow before moving to the next.
