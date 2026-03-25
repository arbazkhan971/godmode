---
name: plan
description: Task decomposition and dependency planning.
  Reads spec and outputs ordered implementation tasks.
---

## Activate When
- `/godmode:plan`, "break down", "plan this"
- "create tasks", "what are the steps"
- `.godmode/spec.md` exists but no `.godmode/plan.yaml`

## Workflow

### 1. Read Context
```bash
cat .godmode/spec.md
git ls-files | head -200
find . -maxdepth 3 -type f \
  \( -name "*.ts" -o -name "*.py" -o -name "*.go" \) \
  | head -80
```
IF no spec: ask user or run `/godmode:think` first.

### 2. Identify Boundaries
- Data layer (models, schemas, migrations)
- API/service layer (routes, controllers, services)
- UI layer (components, pages, styles)
- Configuration (env, configs, infrastructure)
- Tests (unit, integration, e2e)

Priority: data -> API/service -> UI -> config -> tests.
NEVER mix layers in a single task unless < 10 lines.

### 3. Decompose into Tasks
```yaml
- id: "task-01"
  title: "Add user preferences schema"
  skill: "build"
  files:
    - src/models/preferences.ts
    - src/migrations/003_add_preferences.sql
  depends_on: []
  agent: true
  test: "npx vitest run src/models/..."
  done_when: "npx vitest run ... | grep 'passed'"
```
Rules:
- One responsibility per task
- `files[]` max 5 (more = split into subtasks)
- `done_when` = shell command exiting 0 (never prose)
- Max 2 tasks per file across entire plan

### 4. Build Dependency Graph
```
Round 1 (parallel): task-01, task-02 (no deps)
Round 2 (parallel): task-03, task-04 (depend on R1)
Round 3 (sequential): task-05 (depends on 03+04)
```
Topological sort. Max 5 tasks per round. Enforce:
- Data before API before UI
- Schema/type before implementation
- No circular dependencies
- Same-file tasks in different rounds

### 5. Validate Plan
```bash
python3 -c "import yaml; yaml.safe_load(
  open('.godmode/plan.yaml'))"
```
Checks: files exist or parent dir exists,
depends_on IDs valid (no cycles), no file overlap
within same round, max 2 tasks per file.

IF >20 tasks: split into phases.

### 6. Write Plan
```bash
git add .godmode/plan.yaml
git commit -m "plan: decompose {feature} into {N} tasks"
```

## Hard Rules
1. EVERY task: `done_when` is shell command exiting 0.
2. Max 5 files per task.
3. No circular dependencies.
4. Same-round tasks: zero file overlap.
5. Commit plan to git, validate YAML before proceeding.

## TSV Logging
Append `.godmode/plan-log.tsv`:
```
timestamp	feature	total_tasks	total_rounds	total_files	max_parallelism
```

## Keep/Discard
```
KEEP if: YAML parses AND no circular deps
  AND no file overlaps AND all paths valid.
DISCARD if: validation fails on any check.
```

## Stop Conditions
```
STOP when FIRST of:
  - plan.yaml written, validated, committed
  - >20 tasks (split into phases)
  - Decomposition produces no new independent tasks
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| No spec exists | Run /godmode:think first |
| YAML validation fails | Fix syntax, max 3 attempts |
| Circular dependency | Merge tasks or remove edge |
| File overlap in round | Move task to next round |
| >20 tasks | Split into phase-1 and phase-2 |
