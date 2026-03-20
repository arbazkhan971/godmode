---
name: build
description: Implementation engine. Parallel agents in worktrees from plan.
---

## Activate When
- `/godmode:build`, "build", "implement", "create"
- Plan exists with unimplemented tasks

## Input
Read `.godmode/plan.yaml`. No plan file → run `/godmode:plan` first. No plan needed for single-file changes.

## The Loop
```
tasks = load_plan()
WHILE tasks remain:
    round = pick_tasks_with_no_unmet_deps(tasks, completed)[:5]
    FOR each task: Agent("Implement: {task.title}\nFiles: {task.files}\nDone when: {task.done_when}\nStack: {stack}", isolation: "worktree")
    FOR each completed agent:
        merge worktree → conflict: discard, log, retry with narrower scope → test fail: `/godmode:fix` (max 2) or revert
    VERIFY: test_cmd && lint_cmd && build_cmd → fail: /godmode:fix (max 3)
    Log to .godmode/build-log.tsv: round, task_id, status(merged/reverted/conflict). Print "Round {N}: {done}/{total}"
```

## Rules
1. One task per agent. Commit message: `feat({module}): {task.title}`. One commit per task.
2. Agent may only modify files listed in task.files. Touching other files = discard.
3. Test after every merge. Broken builds don't proceed.
4. Max 5 agents per round. Dependency order always.
5. Build what the plan says. No unplanned refactoring, no TODO comments, no placeholder implementations.
6. No code without tests. Log everything to TSV.
