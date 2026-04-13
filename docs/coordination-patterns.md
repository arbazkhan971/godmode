# Coordination Patterns

Six named patterns for organizing multi-agent work in godmode.

Adopted from `revfactory/harness`. Today godmode's `planner` agent produces
ad-hoc plans — each one is a one-off shape. Named patterns give the planner
a shared vocabulary so its output is consistent, debuggable, and teachable.
The `planner.md` agent and `skills/plan/SKILL.md` both pick from this list.

Every plan must declare which pattern it uses in its first line:

```
PLAN
Pattern: Producer-Reviewer
Goal:    Add rate limiting to /api/login
...
```

On conflict, the Universal Protocol in `SKILL.md` wins. These patterns
govern *plan shape*, not keep/discard rules or loop structure.

## 1. Pipeline

Sequential dependent tasks where each step consumes the previous step's output.

**When to use.** Task has irreducible ordering. Each step produces an artifact
the next step reads.

**Godmode example.** `think → plan → build → test → review → optimize → ship`.
This is godmode's default pipeline, already hard-wired into the orchestrator.

**Failure mode to watch.** One slow step blocks the whole chain. Mitigation:
split the slow step into sub-steps or move it off the critical path.

## 2. Fan-out / Fan-in

Parallel independent tasks dispatched simultaneously, results merged at the end.

**When to use.** N tasks with no shared state or data dependencies. Each can
run in its own worktree without knowing about the others.

**Godmode example.** `skills/build/SKILL.md` dispatching 5 builder agents in
parallel worktrees, each with a disjoint `task.files` scope, merged in
dispatch order. Multi-variant `skills/bench/` runs (one variant per agent)
also follow this pattern.

**Failure mode.** Merge conflicts when scopes overlap. Mitigation: planner
enforces no-overlap file partitioning before dispatch (see `AGENTS.md §
Multi-Agent Coordination Rules`).

## 3. Expert Pool

Central router selects a specialist agent based on context, dispatches only
one per request.

**When to use.** Multiple specialists handle different contexts but only one
is needed at a time. The selection itself is cheap; the specialist is
expensive.

**Godmode example.** `skills/godmode/SKILL.md` Step 2 trigger matching —
"make faster" routes to `optimize`, "secure" routes to `secure`, "research"
routes to `research`. The orchestrator is an Expert Pool. `skills/think`
generating 2-3 approaches then picking one is a miniature Expert Pool
inside a single skill.

**Failure mode.** Router picks wrong specialist. Mitigation: failure-aware
routing (`skills/godmode/SKILL.md` Step 3b) consults failure history before
routing.

## 4. Producer-Reviewer

Generation agent produces output, reviewer agent gates it, orchestrator
accepts or rejects.

**When to use.** Output quality matters more than speed. A single-pass
generator will silently ship bad work; a reviewer catches regressions.

**Godmode example.** `skills/build/SKILL.md` (builder produces) → `agents/reviewer.md`
(reviewer gates) → orchestrator KEEPs or DISCARDs the commit. `skills/secure`
running after `skills/build` is a Producer-Reviewer where the "review" is a
security audit.

**Failure mode.** Reviewer becomes a rubber stamp. Mitigation: reviewer
must emit `REQUEST_CHANGES` or `REJECT` at least sometimes, and reviewer
output is logged to `.godmode/review-log.tsv`.

## 5. Supervisor

One central agent owns the plan and dispatches subordinates dynamically as
the situation evolves.

**When to use.** The task shape isn't known upfront. Early results change
what needs to happen next. A fixed plan would be wrong.

**Godmode example.** `skills/godmode/SKILL.md` (the orchestrator itself)
is a Supervisor. Meta-loop skills that chain `optimize → review →
fix → secure → ship` based on what each stage finds are supervised flows.

**Failure mode.** Supervisor becomes a bottleneck. Mitigation: subordinates
run in parallel worktrees when possible; supervisor only coordinates at
phase boundaries.

## 6. Hierarchical Delegation

Top-down recursive task splitting. A parent agent decomposes a task into
subtasks, each subtask may decompose further.

**When to use.** Task is clearly decomposable into independent sub-tasks
that are themselves non-trivial. Recursion stops when a subtask fits in
one builder's scope.

**Godmode example.** `skills/plan/SKILL.md` produces a plan with rounds;
each round has N tasks; each task goes to one builder. If a task is too
large, the planner splits it into sub-tasks for the next round. Rarely
deeper than 2 levels in practice — `AGENTS.md § Deadlock Prevention`
caps dependency depth at 2.

**Failure mode.** Recursive decomposition loops forever. Mitigation: max
depth of 2 enforced by the planner + acyclic dependency check.

## Pattern Selection Cheat Sheet

| Condition | Pattern |
|---|---|
| Sequential steps with handoffs | Pipeline |
| N independent tasks, disjoint scopes | Fan-out/Fan-in |
| One task, route to right specialist | Expert Pool |
| Generation + quality gate | Producer-Reviewer |
| Plan unknown upfront, evolves with state | Supervisor |
| Recursive subtask decomposition | Hierarchical Delegation |

**First question to ask when planning:** are the subtasks independent or
dependent? Independent → Fan-out. Dependent → Pipeline. Both → Hierarchical.

**Second question:** does the result need quality gating? Yes → wrap in
Producer-Reviewer. No → just the chosen shape.

## Composition

Patterns compose. A real godmode session often uses several at once:

```
Supervisor (orchestrator)
  └─ Pipeline (THINK → PLAN → BUILD → ...)
       └─ Fan-out/Fan-in (5 builders in parallel worktrees)
            └─ Producer-Reviewer (each builder wrapped with reviewer gate)
```

Declare the outermost pattern in the plan header. Nested patterns are
implicit.

## Hard Rules

1. Every plan declares a pattern in its first line.
2. Unknown pattern name → `BLOCKED: invalid_plan`. Picks must come from this
   list, not be invented.
3. Nested patterns are allowed; the declared pattern is the outermost one.
4. Pattern choice is advisory for the planner and binding for the executor.
   A builder cannot promote its task from Fan-out to Supervisor mid-round.
5. When the failure-aware router (Step 3b) detects a failing pattern, it
   tries a different pattern before retrying the same skill.

## See Also

- `AGENTS.md § Multi-Agent Coordination Rules` — file scoping, merge order
- `AGENTS.md § Deadlock Prevention` — max dependency depth
- `skills/plan/SKILL.md` — planner output format
- `skills/build/SKILL.md` — Fan-out/Fan-in execution
- `revfactory/harness` — original source of the 6-pattern taxonomy
