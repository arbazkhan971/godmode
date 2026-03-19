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
Expects a plan from `/godmode:plan` with numbered tasks, dependencies, and file scope.
If no plan exists: suggest `/godmode:plan` first, or build inline for simple requests.

## The Loop
```
tasks = load_plan()
completed = []

WHILE tasks remain:
    round = pick_tasks_with_no_unmet_deps(tasks, completed)[:5]

    FOR each task in round:
        Agent("Implement: {task}, Files: {scope}, Test: {cmd}", isolation: "worktree")

    FOR each completed agent:
        merge branch → on conflict: resolve or discard, retry next round
        on test fail → fix inline or revert

    VERIFY: test_cmd && lint_cmd && build_cmd
    IF fail → /godmode:fix (max 3 iterations)

    Log to .godmode/build-log.tsv
    Print "Round {N}: {done}/{total} tasks"
    Mark round completed.
```

## Rules
1. One task per agent. One commit per task.
2. Scope files strictly. Agents don't touch files outside scope.
3. Test after every merge. Broken builds don't proceed.
4. Max 5 agents per round. Dependency order always.
5. No refactoring during build. Build what the plan says.
6. Log everything to TSV.
