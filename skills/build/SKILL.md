---
name: build
description: |
  Implementation engine. Takes a plan, dispatches parallel agents in worktrees, merges, verifies.
---

# Build — Implementation Engine

## Activate When
- `/godmode:build`, "build", "implement", "create"
- Plan exists with unimplemented tasks

## Input
Plan from `/godmode:plan` with tasks, deps, file scope. No plan → suggest plan first or build inline.

## The Loop
```
tasks = load_plan()
WHILE tasks remain:
    round = pick_tasks_with_no_unmet_deps(tasks, completed)[:5]
    FOR each task: Agent("Implement: {task}", files: {scope}, isolation: "worktree")
    FOR each completed agent:
        merge → conflict: resolve or discard → test fail: fix or revert
    VERIFY: test_cmd && lint_cmd && build_cmd → fail: /godmode:fix (max 3)
    Log to .godmode/build-log.tsv. Print "Round {N}: {done}/{total}"
```

## Rules
1. One task per agent. One commit per task.
2. Scope files strictly. No touching outside scope.
3. Test after every merge. Broken builds don't proceed.
4. Max 5 agents per round. Dependency order always.
5. Build what the plan says. No refactoring.
6. Log everything to TSV.
