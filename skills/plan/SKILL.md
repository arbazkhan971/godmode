---
name: plan
description: |
  Task decomposition and dependency planning skill. Reads a spec (from /godmode:think) or user-provided requirements and decomposes them into an ordered set of implementation tasks with file assignments, dependency edges, and verification commands. Outputs .godmode/plan.yaml consumed by /godmode:build. Triggers on: /godmode:plan, "break down", "plan this", "create tasks", or when a spec exists but no plan does.
---

# Plan — Task Decomposition & Dependency Planning

## Activate When
- User invokes `/godmode:plan`
- User says "break down", "plan this", "create tasks", "what are the steps"
- `.godmode/spec.md` exists but `.godmode/plan.yaml` does not
- `/godmode:think` just completed and user wants to proceed
- User provides a feature description and asks "how should I build this"

## Auto-Detection
The godmode orchestrator routes here when:
- Phase detection finds `.godmode/spec.md` present but no `.godmode/plan.yaml`
- User language matches: "decompose", "break into tasks", "dependency graph", "task list", "what order"
- After `/godmode:think` completes, the chain suggests plan as next step

## Step-by-step Workflow

### Step 1: Read Context
Gather all inputs before decomposing:

```bash
# Read the spec
cat .godmode/spec.md

# Scan codebase structure
git ls-files | head -200

# Understand existing architecture
find . -maxdepth 3 -type f \( -name "*.ts" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.js" \) | head -80

# Check for existing config
cat .godmode/config.yaml 2>/dev/null
```

Use cached `test_cmd`, `lint_cmd`, `build_cmd` from stack detection. If any is `—` (not available), omit from task verify steps. If no spec exists, ask user for requirements or run `/godmode:think` first.

### Step 2: Identify Boundaries
Determine natural task boundaries from the spec:

```
BOUNDARY ANALYSIS:
- Data layer changes (models, schemas, migrations)
- API/service layer changes (routes, controllers, services)
- UI layer changes (components, pages, styles)
- Configuration changes (env, configs, infrastructure)
- Test additions (unit, integration, e2e)
```

Priority order: data-layer → API/service → UI → config → tests. Each boundary becomes one or more tasks. Never mix layers in a single task unless the change is trivial (fewer than 10 lines).

### Step 3: Decompose into Tasks
Create tasks with full metadata. Each task:

```yaml
- id: "task-01"
  title: "Add user preferences schema"
  skill: "build"            # which godmode skill executes this
  files:                     # exact paths, max 5 per task
    - src/models/preferences.ts
    - src/migrations/003_add_preferences.sql
  depends_on: []             # task IDs that must complete first
  agent: true                # can this run in a parallel agent?
  test: "npx vitest run src/models/__tests__/preferences.test.ts"
  done_when: "npx vitest run src/models/__tests__/preferences.test.ts --reporter=verbose 2>&1 | grep -q 'Tests.*passed'"
```

Rules for decomposition:
- One responsibility per task. If you need "and" to describe it, split it.
- `files[]` max 5. More than 5 = split into subtasks with a shared interface.
- `done_when` must be a shell command that exits 0 when complete. No subjective criteria.
- `skill` is the godmode skill that will execute: usually `build`, but can be `test`, `fix`, `secure`.

### Step 4: Build Dependency Graph
Arrange tasks into execution rounds:

```
DEPENDENCY GRAPH:
Round 1 (parallel): task-01, task-02        # no deps
Round 2 (parallel): task-03, task-04        # depend on round 1
Round 3 (sequential): task-05               # depends on task-03 AND task-04
Round 4 (parallel): task-06, task-07        # depend on round 3
```

Topological sort. Group independent tasks into rounds (max 5 tasks per round). Enforce:
- Data-layer tasks before API tasks before UI tasks
- Schema/type tasks before implementation tasks
- No circular dependencies (detect and error)
- Tasks touching the same file must be in different rounds (sequential)

### Step 5: Validate Plan Integrity
Run validation checks before writing:

```bash
# Verify existing files are real
for f in $(grep "files:" -A 5 .godmode/plan.yaml | grep "- " | sed 's/- //'); do
  git ls-files --error-unmatch "$f" 2>/dev/null || test -d "$(dirname "$f")"
done

# Verify no circular dependencies
python3 -c "
import yaml
plan = yaml.safe_load(open('.godmode/plan.yaml'))
# topological sort check
"

# Verify no file overlap within same round
# (checked programmatically during step 4)
```

Validation checklist:
- `files[]` — existing files verified via `git ls-files`; new files have existing parent dirs (`test -d $(dirname $path)`)
- `depends_on[]` — all referenced IDs exist, no cycles
- Same-round tasks — zero file overlap. If unavoidable, make sequential.
- Max 2 tasks per file across entire plan. If more, restructure to reduce conflicts.

### Step 6: Write Plan File
Write `.godmode/plan.yaml` with all tasks, then validate YAML:

```bash
# Validate YAML syntax
python3 -c 'import yaml; yaml.safe_load(open(".godmode/plan.yaml"))'

# Commit the plan
git add .godmode/plan.yaml && git commit -m "plan: decompose {feature} into {N} tasks"
```

### Step 7: Summarize and Suggest Next Step
Print summary. If more than 10 tasks, suggest `/godmode:predict` before building.

## Output Format
At each stage, print progress:

```
Plan: reading spec (.godmode/spec.md, 47 lines)...
Plan: identified 6 boundaries across 3 layers.
Plan: decomposed into 9 tasks.
Plan: arranged into 4 rounds (max parallelism: 3).
Plan: validation passed — 9 tasks, 14 files, 0 conflicts.
Plan: wrote .godmode/plan.yaml (9 tasks, 4 rounds, 14 files).
Plan: >10 tasks — consider /godmode:predict before /godmode:build.
```

Final output line:
```
Plan: {N} tasks, {M} rounds, {F} files. Next: /godmode:predict or /godmode:build.
```

## TSV Logging
Append to `.godmode/plan-log.tsv` (create if missing, never overwrite):

```
timestamp	feature	total_tasks	total_rounds	total_files	max_parallelism	plan_path	spec_path
2025-01-15T14:30:00Z	user-preferences	9	4	14	3	.godmode/plan.yaml	.godmode/spec.md
```

Columns: `timestamp`, `feature`, `total_tasks`, `total_rounds`, `total_files`, `max_parallelism`, `plan_path`, `spec_path`.

## Success Criteria
The plan is done when ALL of the following are true:
- [ ] `.godmode/plan.yaml` exists and parses as valid YAML
- [ ] Every task has `id`, `title`, `skill`, `files`, `depends_on`, `agent`, `test`, `done_when`
- [ ] Every `files[]` entry is a real path or a new file in an existing directory
- [ ] Every `depends_on[]` references a valid task ID with no cycles
- [ ] No two same-round tasks share a file
- [ ] Every `done_when` is a shell command (not prose)
- [ ] Plan is committed to git
- [ ] TSV log row appended

## Error Recovery
- **No spec exists:** Print `Plan: no spec found. Run /godmode:think first.` and exit. Do not guess.
- **YAML validation fails:** Fix syntax errors in-place. Re-run `python3 -c 'import yaml; yaml.safe_load(...)'`. Max 3 attempts, then print the parse error and stop.
- **Circular dependency detected:** Print the cycle (e.g., `task-03 → task-05 → task-03`). Break the cycle by merging the smaller task into the larger one or removing a dependency edge. Re-validate.
- **File overlap in same round:** Move one of the conflicting tasks to the next round. Re-number rounds. Log which tasks were moved and why.
- **Too many tasks (>20):** Split into phases. Write `.godmode/plan-phase-1.yaml` and `.godmode/plan-phase-2.yaml`. Each phase independently buildable.

## Anti-Patterns
1. **Vague done_when:** `"works correctly"`, `"looks good"`, `"is complete"` are never valid. Must be a shell command with exit code 0.
2. **Monolith tasks:** A task touching 8 files across 3 layers. Split it. Max 5 files, one layer per task.
3. **Over-sequencing:** Making every task depend on the previous one when they could run in parallel. Check: can task B start before task A finishes? If yes, no dependency edge.
4. **Missing test tasks:** Plan has 10 implementation tasks and 0 test tasks. Every new module needs a test task in the plan.
5. **Phantom files:** Listing files that do not exist and whose parent directories do not exist. Always verify paths.

## Examples

### Example 1: API Feature
```
User: "Plan the user preferences feature"
Plan: reading spec (.godmode/spec.md, 32 lines)...
Plan: decomposed into 5 tasks, 3 rounds, 8 files.

Round 1: task-01 (add preferences schema), task-02 (add preferences migration)
Round 2: task-03 (preferences API routes), task-04 (preferences service layer)
Round 3: task-05 (preferences API tests)

Plan: wrote .godmode/plan.yaml. Next: /godmode:build.
```

### Example 2: Large Feature (>10 tasks)
```
User: "Plan the multi-tenant billing system"
Plan: reading spec (.godmode/spec.md, 89 lines)...
Plan: decomposed into 14 tasks, 6 rounds, 23 files.
Plan: >10 tasks — recommend /godmode:predict before building.
Plan: wrote .godmode/plan.yaml. Next: /godmode:predict.
```

### Example 3: Minimal Change (no plan needed)
```
User: "Plan adding a health check endpoint"
Plan: spec describes 1 route + 1 test (2 files total). Skip plan — /godmode:build can handle ≤2 files directly.
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- Plan generation itself requires no parallel agents — runs identically on all platforms.
- When writing `agent: true|false` on tasks, set `agent: false` for all tasks if the platform cannot dispatch agents.
- The resulting plan will be consumed by `/godmode:build`, which handles sequential fallback independently.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
