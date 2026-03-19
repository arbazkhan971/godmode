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
- Read spec (if exists): `.godmode/spec.md` or user-provided
- Scan codebase: `git ls-files`, directory structure, existing patterns
- Detect stack (from orchestrator Step 1)

### 2. Decompose into Tasks

Each task must have:
```yaml
- id: 1
  title: "Create user schema"
  skill: schema          # which godmode skill to follow
  files: [src/db/user.ts, src/db/migrations/001_users.sql]
  depends_on: []         # task IDs this depends on
  agent: true            # can be dispatched to agent
  test: "npx jest src/db/user.test.ts"
  done_when: "Schema exists and migration runs"
```

### 3. Build Dependency Graph

```
Sort tasks topologically.
Tasks with no dependencies → Round 1 (parallel).
Tasks depending on Round 1 → Round 2.
Continue until all tasks are assigned rounds.
```

### 4. Validate Plan

```
FOR each task:
  - files[] must be real paths or new files in existing directories
  - depends_on[] must reference valid task IDs
  - No circular dependencies
  - Every file appears in at most 2 tasks (avoid merge conflicts)
```

### 5. Output

Write plan to `.godmode/plan.yaml`. Print summary:
```
Plan: {N} tasks in {M} rounds
Round 1: tasks 1,2,3 (parallel)
Round 2: tasks 4,5 (parallel, depends on round 1)
Round 3: task 6 (sequential, depends on 4+5)
```

## Rules

1. Every task has exact file paths. No "somewhere in src/".
2. Every task has a `done_when` criterion that's mechanically verifiable.
3. Max 5 tasks per round (matches build's agent cap).
4. No task modifies more than 5 files. Split larger tasks.
5. Plan must be valid YAML. Build skill parses it literally.
