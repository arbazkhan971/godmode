# Sequential Dispatch Reference

When a Godmode skill instructs you to dispatch parallel agents or use worktree isolation, and your platform does not support these features natively, follow this document to translate parallel instructions into sequential execution.

The quality of results is identical. Only throughput is affected.

---

## When This Applies

This reference applies when ALL of the following are true:

- The platform does **not** have a native `Agent()` tool or `SendMessage` for parallel subagent dispatch
- The platform does **not** have native `EnterWorktree` / `ExitWorktree` tools
- The platform cannot run multiple independent tasks simultaneously in separate contexts

**Platforms covered:** Gemini CLI, OpenCode, Codex

**Platforms NOT covered:** Claude Code (has native `Agent` + worktree tools), Cursor (has background agents with its own dispatch model)

---

## Parallel Agent to Sequential Execution

When a skill says "dispatch N agents in parallel":

1. Execute each agent's task **sequentially** in the current session
2. For each task: complete it fully (implement, test, commit) before starting the next
3. Follow dependency order if specified; otherwise, execute left-to-right as listed in the skill

### Example Translation

```
# Skill instruction:
"Dispatch 3 agents: Agent A (add index), Agent B (add caching), Agent C (fix N+1)"

# Sequential execution:
1. Add index   -> test -> commit
2. Add caching -> test -> commit
3. Fix N+1     -> test -> commit
```

Each task must pass all guard rails (tests, lint, build) before its commit. If a task fails guard rails after two fix attempts, revert it and move to the next.

---

## Worktree Isolation to Branch-Based Isolation

When a skill says `EnterWorktree(name)` or specifies `isolation: worktree`:

```bash
# 1. Create an isolated branch
git checkout -b godmode-{task-name}

# 2. Do the work on that branch
#    (implement, test, commit)

# 3. Merge back to the base branch
git checkout main && git merge godmode-{task-name}

# 4. Clean up
git branch -d godmode-{task-name}
```

### Handling Merge Failures

If the merge produces conflicts or tests fail after the merge:

```bash
# Abort the merge (if conflicts prevented completion)
git merge --abort

# Or reset if the merge completed but tests fail
git reset --hard HEAD~1
```

Then:
1. Log the task as `DISCARDED` in the results TSV with the reason
2. Move to the next task
3. Do not retry — the parallel version would also discard a failing merge

---

## Skill-Specific Instructions

### Optimize Skill

The optimize skill dispatches 3 agents per round, each trying a different approach in a separate worktree. The best result wins.

**Sequential translation:**

1. Try approach A. Measure. If improved over baseline, record the result and keep the commit.
2. Try approach B. Measure. If improved over baseline AND better than A, keep B and revert A. If not, revert B.
3. Try approach C. Measure. If improved over baseline AND better than the current best, keep C and revert the previous best. If not, revert C.
4. Only the single best result survives each round.

This matches the parallel behavior exactly: three approaches are tried, the best one wins, the other two are discarded.

### Build Skill

The build skill dispatches up to 5 agents per round, each handling one task from the dependency graph.

**Sequential translation:**

1. Identify all tasks with no unmet dependencies (same dependency-graph logic as parallel)
2. Execute **one** task at a time, not five
3. After each task completes, run the full verification suite: `test_cmd`, `lint_cmd`, `build_cmd`
4. If verification fails: attempt `/godmode:fix` (max 2 retries), then revert if still failing
5. After completing a task, re-evaluate the dependency graph — newly unblocked tasks may now be eligible
6. Repeat until all tasks are complete or all remaining tasks are blocked

### Review Skill

The review skill dispatches 4 agents in parallel, each performing one review pass: Correctness, Security, Performance, Style.

**Sequential translation:**

1. Run the Correctness review pass. Collect all findings.
2. Run the Security review pass. Collect all findings.
3. Run the Performance review pass. Collect all findings.
4. Run the Style review pass. Collect all findings.
5. Merge all findings and deduplicate (same as the parallel version's merge step).

Each pass should analyze the code independently, as if the other passes have not yet run. Do not let findings from one pass influence another — the parallel version runs them simultaneously and they share no state.

---

## Performance Impact

Sequential execution is slower but produces identical results:

| Skill      | Parallel Tasks | Slowdown Factor | Reason                           |
|------------|----------------|-----------------|----------------------------------|
| Optimize   | 3 per round    | ~3x per round   | 3 approaches tried sequentially  |
| Build      | 5 per round    | ~5x per round   | 5 tasks executed one at a time   |
| Review     | 4 passes       | ~4x total       | 4 review passes run sequentially |

**What stays the same:**
- Verification logic (same guard rails, same thresholds)
- Rollback behavior (same revert conditions, same discard rules)
- Output format (same TSV logs, same summary reports)
- Decision logic (same keep/revert criteria)
- Final result quality (same code changes survive)

The only difference is wall-clock time.
