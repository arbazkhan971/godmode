---
name: build
description: Implementation engine. Parallel agents in worktrees from plan.
---

## Activate When
- `/godmode:build`, "build", "implement", "create"
- Plan exists with unimplemented tasks

## Input
Read `.godmode/plan.yaml`. Missing → `/godmode:plan` first. Skip plan only for changes touching ≤2 files.

## The Loop
```
tasks = load_plan()
WHILE tasks remain:
    round = pick_tasks_with_no_unmet_deps(tasks, completed)[:5]
    FOR each task: Agent("Implement: {task.title}\nFiles: {task.files}\nDone when: {task.done_when}\nStack: {stack}", isolation: "worktree")
    FOR each completed agent:
        merge worktree → conflict: `git merge --abort`, discard, retry narrower scope → test fail: `/godmode:fix` (max 2) or `git revert HEAD`
    VERIFY: build_cmd && lint_cmd && test_cmd → fail: /godmode:fix (max 3). All 3 must pass.
    Append `.godmode/build-log.tsv`: round, task_id, agent_time_ms, status(merged/reverted/conflict). Print `Round {N}: {done}/{total}`
```

## Output Format
Print: `Build: {completed}/{total} tasks in {rounds} rounds. Merged: {merged}. Reverted: {reverted}. Conflicts: {conflicts}.`

## Rules
1. One task per agent. Commit message: `feat({module}): {task.title}`. One commit per task.
2. Agent may only modify files listed in task.files. Touching other files = discard.
3. After every merge: `build_cmd && lint_cmd && test_cmd`. Any non-zero exit = stop round, fix before next merge.
4. Max 5 agents per round. Dependency order always.
5. Build exactly what the plan says. No unplanned refactoring, no TODOs, no stubs, no `// placeholder`.
6. Every new function gets a test. Every merge gets a TSV row. No exceptions.
7. Each agent receives: task.title, task.files, task.done_when, stack info. Nothing else.

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- Execute ONE task at a time instead of up to 5 parallel agents.
- Use branch isolation: `git checkout -b godmode-build-{task_id}`, implement, commit, then `git checkout main && git merge godmode-build-{task_id}`.
- After each merge: run `build_cmd && lint_cmd && test_cmd`. Fail → `git merge --abort` or `git reset --hard HEAD~1`.
- Clean up branches: `git branch -d godmode-build-{task_id}`.
- Task ordering, dependency logic, conflict handling, and TSV logging remain identical.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
