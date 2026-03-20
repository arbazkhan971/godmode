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
- Use cached `test_cmd`, `lint_cmd`, `build_cmd`. If any is `—` (not available), omit from task verify steps.
### 2. Decompose into Tasks
Each task: `id`, `title`, `skill` (godmode skill name), `files` (exact paths), `depends_on` (task IDs), `agent: true|false`, `test` (verify cmd), `done_when` (shell cmd, exit 0 = done).
### 3. Build Dependency Graph
Topological sort. Group independent tasks into rounds (max 5). Data-layer tasks before API before UI.
### 4. Validate Plan
- `files[]` must be real paths (`git ls-files`) or new files in existing dirs. Validate: `test -d $(dirname $path)`.
- `depends_on[]` must reference valid task IDs, no circular deps
- Max 2 tasks per file (avoid conflicts). If unavoidable, tasks touching same file must be sequential.
### 5. Output
Write `.godmode/plan.yaml`. Print: `Plan: {N} tasks, {M} rounds, {F} files`. If >10 tasks → suggest `/godmode:predict`.

## TSV Logging
Append `.godmode/plan-log.tsv`: timestamp, feature, total_tasks, total_rounds, total_files, plan_path.

## Rules
1. Every task lists exact file paths. Existing files: verify with `git ls-files`. New files: parent dir must exist.
2. Every `done_when` is a shell command. If it exits 0, the task is done.
3. Max 5 tasks per round (build's agent limit). Same-round tasks: zero file overlap. Validate: no path appears in two tasks.
4. Max 5 files per task. Larger → split into subtasks with shared interface.
5. Valid YAML required — build parses literally. Validate: `python3 -c 'import yaml; yaml.safe_load(open(".godmode/plan.yaml"))'`. Fix before proceeding.
