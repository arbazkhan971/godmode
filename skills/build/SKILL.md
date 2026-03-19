---
name: build
description: |
  Implementation engine. Takes a plan, dispatches parallel agents in worktrees, merges results, verifies. One task per agent, one commit per task.
---

# Build — Implementation Engine

## Activate When
- `/godmode:build`, "build", "implement", "create", "code this"
- Plan exists with unimplemented tasks

## Input

Expects a plan (from `/godmode:plan`) with numbered tasks, dependencies, and file scope.
If no plan exists: suggest `/godmode:plan` first, or build inline for simple requests.

## The Loop

```
tasks = load_plan()  # ordered by dependency
completed = []

WHILE tasks remain:
    # 1. SELECT ROUND — group independent tasks (max 5 agents)
    round = pick_tasks_with_no_unmet_deps(tasks, completed)[:5]

    # 2. DISPATCH AGENTS (parallel, in worktrees)
    FOR each task in round:
        Agent(prompt: "Implement: {task}\nFiles: {scope}\nTest: {cmd}", isolation: "worktree")

    # 3. MERGE (one at a time)
    FOR each completed agent:
        git merge {branch} --no-edit
        IF conflict → resolve or discard, retry next round
        IF tests fail → fix inline or revert

    # 4. VERIFY: test_cmd && lint_cmd && build_cmd
    IF fail → /godmode:fix (max 3 iterations)

    # 5. LOG to .godmode/build-log.tsv
    # 6. STATUS: "Round {N}: {done}/{total} tasks"

    Mark round as completed.
```

## Rules

1. One task per agent. One commit per task.
2. Scope files strictly. Agents don't touch files outside scope.
3. Test after every merge. Broken builds don't proceed.
4. Max 5 agents per round. Dependency order always.
5. No refactoring during build. Build what the plan says.
6. Log everything to TSV.
