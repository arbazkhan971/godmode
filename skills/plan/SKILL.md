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
Plan: >10 tasks — run /godmode:predict before /godmode:build.
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

## Planning Rigor Protocol

Extended protocol for task dependency graphing, effort estimation, and risk assessment:

```
PLANNING RIGOR PROTOCOL:
current_iteration = 0
max_iterations = 5
rigor_phases = [dependency_graph, effort_estimation, risk_assessment, critical_path, plan_validation]

WHILE current_iteration < max_iterations:
  phase = rigor_phases[current_iteration]
  current_iteration += 1

  IF phase == "dependency_graph":
    PURPOSE: Build and validate a complete task dependency graph with no cycles or missing edges.

    1. FOR each task in plan:
       IDENTIFY dependencies by analyzing:
       a. File dependencies:
          - Task B modifies files that import from files modified by Task A → B depends on A
          - Task B extends types/interfaces defined by Task A → B depends on A
          - Task B writes tests for code created by Task A → B depends on A
       b. Schema dependencies:
          - Task B adds API routes that use models from Task A → B depends on A
          - Task B writes migration that references table from Task A → B depends on A
       c. Build dependencies:
          - Task B requires output artifacts from Task A → B depends on A
          - Task B uses generated code from Task A → B depends on A

    2. VALIDATE graph integrity:
       a. Cycle detection (topological sort):
          - IF cycle found: report exact cycle path (A → B → C → A)
          - BREAK cycle by merging smallest task into dependent or removing edge
       b. Missing edges:
          - FOR each task pair (A, B) where A.files and B.files share imports:
            IF no dependency edge exists: WARN — "Possible missing dependency: {A} → {B}"
       c. Redundant edges:
          - IF A → B and A → C and B → C: the A → C edge is redundant (transitive)
          - Remove redundant edges to simplify the graph

    3. COMPUTE execution rounds (topological layers):
       round_1 = tasks with no dependencies (roots)
       round_2 = tasks whose dependencies are all in round_1
       round_N = tasks whose dependencies are all in rounds < N
       max_parallelism = max(len(round) for round in rounds)

    4. VISUALIZE:
       DEPENDENCY GRAPH:
       Round 1 (parallel, max {N}):
         ├── task-01: {title}
         ├── task-02: {title}
         └── task-03: {title}
       Round 2 (parallel, max {N}):
         ├── task-04: {title}  ← depends on task-01
         └── task-05: {title}  ← depends on task-02, task-03
       Round 3 (sequential):
         └── task-06: {title}  ← depends on task-04, task-05
       Round 4 (parallel, max {N}):
         ├── task-07: {title}  ← depends on task-06
         └── task-08: {title}  ← depends on task-06

       Total: {N} tasks, {M} rounds, max parallelism: {K}
       Critical path length: {P} tasks

  IF phase == "effort_estimation":
    PURPOSE: Estimate effort for each task using code complexity signals.

    1. FOR each task, estimate effort based on:
       a. File count: number of files to create/modify
          1 file: XS (< 30 min)
          2-3 files: S (30-60 min)
          4-5 files: M (1-2 hours)
          >5 files: L (2-4 hours) — split

       b. Lines of code (estimated):
          < 50 lines: XS
          50-150 lines: S
          150-300 lines: M
          300-500 lines: L
          >500 lines: XL — must split

       c. Complexity signals:
          - New file creation: +0.5 (scaffolding overhead)
          - Database migration: +1.0 (risk + validation time)
          - External API integration: +1.0 (unknown behavior)
          - Auth/security changes: +1.0 (extra review needed)
          - UI components: +0.5 (visual verification needed)
          - Test writing: +0.5 per test file

       d. Uncertainty multiplier:
          Well-understood domain: 1.0x
          Somewhat familiar: 1.3x
          New/unknown: 1.5x
          External dependency: 2.0x

    2. PRODUCE effort estimate per task:
       EFFORT ESTIMATES:
       ┌──────────┬─────────────────────────┬───────┬──────────┬─────────────┐
       │  Task    │  Title                  │  Size │  Effort  │  Confidence │
       ├──────────┼─────────────────────────┼───────┼──────────┼─────────────┤
       │  task-01 │  Add user schema        │  S    │  45 min  │  HIGH       │
       │  task-02 │  Add migration          │  S    │  60 min  │  HIGH       │
       │  task-03 │  Add API routes         │  M    │  90 min  │  MEDIUM     │
       │  task-04 │  Add external API call  │  M    │  180 min │  LOW        │
       │  task-05 │  Add tests              │  M    │  120 min │  MEDIUM     │
       ├──────────┼─────────────────────────┼───────┼──────────┼─────────────┤
       │  TOTAL   │                         │       │  ~8.3 hrs│             │
       └──────────┴─────────────────────────┴───────┴──────────┴─────────────┘

    3. COMPUTE total effort:
       sequential_effort = sum(all task efforts)
       parallel_effort = sum(critical path task efforts)
       speedup = sequential_effort / parallel_effort

  IF phase == "risk_assessment":
    PURPOSE: Identify and mitigate risks before they become blockers during execution.

    1. ASSESS risk for each task:
       RISK DIMENSIONS:
       a. Technical risk:
          - Using unfamiliar library/API? → HIGH
          - Complex algorithm or data structure? → MEDIUM
          - Standard CRUD operation? → LOW

       b. Integration risk:
          - Touching shared interfaces/contracts? → HIGH
          - Modifying database schema? → HIGH
          - Isolated module change? → LOW

       c. Dependency risk:
          - External API with unclear documentation? → HIGH
          - External API with SLA/uptime concerns? → MEDIUM
          - No external dependencies? → LOW

       d. Scope risk:
          - Requirements ambiguous or incomplete? → HIGH
          - Clear requirements but complex implementation? → MEDIUM
          - Well-defined, straightforward? → LOW

    2. FOR each HIGH risk task:
       DEFINE mitigation strategy:
       - Spike/prototype first (time-boxed exploration)
       - Fallback approach if primary approach fails
       - Expert consultation needed (who to ask)
       - Additional testing requirements
       - Rollback plan if integration fails

    3. PRODUCE risk matrix:
       RISK ASSESSMENT:
       ┌──────────┬──────────────┬──────────────┬────────────┬──────────────┐
       │  Task    │  Technical   │  Integration │  Dependency│  Scope       │
       ├──────────┼──────────────┼──────────────┼────────────┼──────────────┤
       │  task-01 │  LOW         │  LOW         │  LOW       │  LOW         │
       │  task-03 │  MEDIUM      │  HIGH        │  LOW       │  LOW         │
       │  task-04 │  HIGH        │  MEDIUM      │  HIGH      │  MEDIUM      │
       ├──────────┼──────────────┼──────────────┼────────────┼──────────────┤
       │  Overall │  MEDIUM      │  HIGH        │  MEDIUM    │  LOW         │
       └──────────┴──────────────┴──────────────┴────────────┴──────────────┘

       HIGH RISK TASKS WITH MITIGATIONS:
       task-04: "Add external API call"
         Risk: External API has unclear rate limits and inconsistent response schema
         Mitigation: Build adapter with circuit breaker; add response validation layer
         Fallback: Use mock API for development; defer real integration to Phase 2
         Spike: 1 hour to verify API behavior before committing to implementation

  IF phase == "critical_path":
    PURPOSE: Identify the longest chain of dependent tasks that determines minimum delivery time.

    1. COMPUTE critical path:
       FOR each path from root to leaf in the dependency graph:
         path_duration = sum(task.effort for task in path)
       critical_path = path with maximum duration
       critical_path_duration = max path_duration

    2. IDENTIFY slack (non-critical tasks):
       FOR each task NOT on the critical path:
         slack = latest_start - earliest_start
         IF slack > 2 hours: task can be deferred without affecting delivery

    3. REPORT:
       CRITICAL PATH:
       task-01 (45m) → task-03 (90m) → task-05 (120m) → task-06 (60m)
       Critical path duration: 5.25 hours
       Total plan duration (parallel): 5.25 hours
       Total plan duration (sequential): 8.3 hours
       Parallelism speedup: 1.6x

       Non-critical tasks (can be reordered):
       - task-02 (60m) — slack: 2.5 hours
       - task-04 (180m) — slack: 0 hours (also on critical path)

  IF phase == "plan_validation":
    PURPOSE: Final validation of the complete plan before execution.

    1. COMPLETENESS checks:
       [ ] Every spec requirement maps to at least one task
       [ ] Every task has a done_when criterion (shell command, not prose)
       [ ] Every task has files[] with real paths (or new files in existing dirs)
       [ ] Every task has effort estimate
       [ ] Every task has risk assessment

    2. FEASIBILITY checks:
       [ ] Total effort is reasonable (< 40 hours for one developer)
       [ ] No single task > 4 hours (split if so)
       [ ] Critical path < 2x any individual task (no serial bottleneck)
       [ ] HIGH risk tasks have mitigations documented
       [ ] External dependencies have fallback plans

    3. QUALITY checks:
       [ ] Test tasks exist for all implementation tasks
       [ ] Documentation tasks exist for public API changes
       [ ] Migration tasks have rollback plans

    4. IF validation fails:
       Identify specific failures
       Recommend fixes (split tasks, add missing tasks, add mitigations)
       Re-validate after fixes

  REPORT: "Phase {current_iteration}/{max_iterations}: {phase} — {PASS | NEEDS REVISION}"

FINAL PLAN RIGOR ASSESSMENT:
┌──────────────────────────────────────────────────────────┐
│  PLAN RIGOR SUMMARY                                       │
├──────────────────────┬────────┬───────────────────────────┤
│  Phase               │ Status │ Key Metric                 │
├──────────────────────┼────────┼───────────────────────────┤
│  Dependency graph    │ VALID  │ {N} tasks, {M} rounds      │
│  Effort estimation   │ DONE   │ ~{N} hours total           │
│  Risk assessment     │ DONE   │ {N} HIGH risks mitigated   │
│  Critical path       │ FOUND  │ {N} hours min delivery     │
│  Plan validation     │ PASS   │ All checks pass            │
├──────────────────────┼────────┼───────────────────────────┤
│  Overall             │ READY  │ Proceed to /godmode:build  │
└──────────────────────┴────────┴───────────────────────────┘
```

## Keep/Discard Discipline
```
After EACH plan validation:
  KEEP if: YAML parses AND no circular deps AND no file overlaps AND all paths valid
  DISCARD if: validation fails on any check
  On discard: fix the failing validation item. Re-validate. Max 3 attempts per issue.
  Never keep a plan with circular dependencies or invalid file paths.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: plan.yaml written, validated, and committed
  - budget_exhausted: >20 tasks (split into phases instead)
  - diminishing_returns: decomposition produces no new independent tasks
  - stuck: >5 validation failures with no resolution
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or worktree isolation:
- Plan generation itself requires no parallel agents — runs identically on all platforms.
- When writing `agent: true|false` on tasks, set `agent: false` for all tasks if the platform cannot dispatch agents.
- The resulting plan will be consumed by `/godmode:build`, which handles sequential fallback independently.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
