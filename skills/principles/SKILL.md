---
name: principles
description: >
  Authoring discipline prelude. Think -> Simplicity -> Surgical -> Goal-driven.
  Read before any Edit. Based on Karpathy's LLM-coding-mistakes observations.
  Complements the Universal Protocol with an authoring layer.
---

# Authoring Discipline — Prelude to the Universal Protocol

**Scope.** Governs what you *decide to write*. The Universal Protocol in
`SKILL.md` governs *how you verify and keep it*. On conflict, Protocol wins.

**Tradeoff.** Biases toward caution over speed. For trivial tasks (one-line
fixes, typos, renames, pure formatting), use judgment and skip the pre-flight.
The gates apply to tasks that change behavior.

**When.** Every agent, every skill, every round — before the first Edit.

## 1. Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs. Before the first Edit:

- State your assumptions in one line. If uncertain, ask.
- If two or more interpretations exist, present them — do NOT pick silently.
- If a simpler approach exists, say so.
- If something is unclear, stop and emit `NEEDS_CONTEXT`.

**Rule.** If you cannot write one sentence stating what the user wants,
ask before coding, not after.

## 2. Simplicity First

Minimum code that solves the problem. Nothing speculative.

**Pre-MODIFY checklist** — run before writing a single line:

1. List every function, class, constant, import, and file you plan to add.
2. For each, answer YES/NO:
   - Single-use? (used once after my change)
   - Impossible-case handler? (error path that cannot fire)
   - Unrequested configurability? (flag/option nobody asked for)
3. Strike any YES. Inline single-use helpers. Delete impossible-case
   handlers. Remove unrequested configuration.
4. If the list still has >5 items for a task that changes <20 lines,
   the approach is too complex. Rewrite it.

**Hard stops.** Never add features beyond the request, abstractions for
single-use code, configurability nobody asked for, error handling for
impossible scenarios, or refactors "while we're here."

Post-MODIFY complexity falls under the Protocol's line-vs-delta table.
This checklist catches complexity *before* it is written.

## 3. Surgical Changes

Touch only what you must. Clean up only your own mess.

**Line-trace rule.** Every semantically changed line must trace directly to
the user's request. If not, classify as `scope_drift` and remove from your
diff before committing.

*In scope:* lines implementing the requested behavior, tests covering it,
orphans YOUR changes created (imports/vars/helpers your edit made unused).

*Out of scope:* improving adjacent code, comments, or formatting; refactoring
things that aren't broken; renaming for consistency; deleting pre-existing
dead code (mention it in the report — do NOT delete); auto-formatter churn
on lines you didn't touch semantically.

Match existing style, even if you'd do it differently. `task.files` controls
which files you may touch; the line-trace rule controls which lines inside
those files you may touch.

## 4. Goal-Driven Execution

Define success. Loop until verified. The success criterion MUST be a shell
command that exits zero when the goal is met. Subjective criteria ("works
well," "looks good," "is faster") are vibes — reject before coding, replace
with a command.

- "Add validation" -> "Write tests for invalid inputs, then make them pass."
- "Fix the bug" -> "Write a test that reproduces it, then make it pass."
- "Refactor X" -> "Tests pass before and after; diff shows no behavior change."

Multi-step tasks state a brief plan, verify step per step:

```
1. [step] -> verify: [shell command that exits zero]
2. [step] -> verify: [shell command that exits zero]
```

Strong criteria let you loop independently. Weak criteria force clarification.

**Effectiveness signal.** Fewer unnecessary diff lines, fewer rewrites,
ambiguity surfaced as `NEEDS_CONTEXT` before implementation.
