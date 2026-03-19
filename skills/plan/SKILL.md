---
name: plan
description: |
  Decomposes a spec or goal into ordered tasks with file paths, dependencies, and agent assignments. Outputs YAML that build skill can parse.
---

# Plan — Task Decomposition

## Activate When
- `/godmode:plan`, "break down", "plan this", "create tasks"
- Spec exists but no plan

## Workflow
### 1. Read Context
- Read spec: `.godmode/spec.md` or user-provided
- Scan codebase: `git ls-files`, directory structure, existing patterns
- Detect stack (from orchestrator Step 1)
### 2. Decompose into Tasks
Each task is a YAML entry with fields: `id`, `title`, `skill` (godmode skill to follow), `files` (exact paths), `depends_on` (task IDs), `agent: true/false`, `test` (command), `done_when` (verifiable criterion).
### 3. Build Dependency Graph
Sort tasks topologically. Group tasks with no unmet deps into rounds for parallel execution. Continue until all tasks assigned.
### 4. Validate Plan
- `files[]` must be real paths or new files in existing directories
- `depends_on[]` must reference valid task IDs, no circular deps
- Every file appears in at most 2 tasks (avoid merge conflicts)
### 5. Output
Write to `.godmode/plan.yaml`. Print summary: `Plan: {N} tasks in {M} rounds` with per-round breakdown.

## Rules
1. Every task has exact file paths. No "somewhere in src/".
2. Every task has a `done_when` that's mechanically verifiable.
3. Max 5 tasks per round (matches build's agent cap).
4. No task modifies more than 5 files. Split larger tasks.
5. Plan must be valid YAML. Build skill parses it literally.
