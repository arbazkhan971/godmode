---
name: plan
description: Decompose spec into tasks with deps, files, agents. Output .godmode/plan.yaml.
---

## Activate When
- `/godmode:plan`, "break down", "plan this", "create tasks"
- Spec exists but no plan

## Workflow
### 1. Read Context
- Read spec: `.godmode/spec.md` or user-provided
- Scan codebase: `git ls-files`, directory structure, existing patterns
- Detect stack (from orchestrator Step 1)
### 2. Decompose into Tasks
Each task: `id`, `title`, `skill` (which godmode skill), `files` (exact paths), `depends_on` (task IDs), `agent: true/false`, `test` (verify command), `done_when` (exit 0 = done).
### 3. Build Dependency Graph
Sort tasks topologically. Group tasks with no unmet deps into rounds for parallel execution. Continue until all tasks assigned.
### 4. Validate Plan
- `files[]` must be real paths or new files in existing directories
- `depends_on[]` must reference valid task IDs, no circular deps
- Every file appears in at most 2 tasks (avoid merge conflicts)
### 5. Output
Write `.godmode/plan.yaml`. Print: `Plan: {N} tasks in {M} rounds`. For complex plans, suggest `/godmode:predict` before `/godmode:build`.

## Rules
1. Every task has exact file paths that exist (or will be created). No globs, no "somewhere in".
2. Every `done_when` is a shell command. If it exits 0, the task is done.
3. Max 5 tasks per round (matches build's agent cap).
4. Max 5 files per task. Larger → split into subtasks with shared interface.
5. Plan must be valid YAML. Build skill parses it literally.
