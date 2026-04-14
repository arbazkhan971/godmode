---
name: godmode
description: "Turn on Godmode. 126 skills, 7 subagents, zero configuration. Routes to the right skill automatically."
---

@./skills/godmode/SKILL.md

---

# Universal Coding Discipline — prelude to the Protocol

**Authoring discipline governs what you decide to write. The Universal
Protocol below governs how you verify and keep it.** Read the prelude before
every Edit. For trivial tasks (one-line fixes, typos, renames, pure
formatting), use judgment — the gates apply to behavior changes.

- **Think Before Coding.** State assumptions. If multiple interpretations
  exist, surface them — do NOT pick silently. Emit `NEEDS_CONTEXT` when
  requirements are ambiguous.
- **Simplicity First.** Pre-MODIFY checklist: no single-use helpers, no
  impossible-case handlers, no unrequested configurability. Catch complexity
  *before* it is written, not only at the post-MODIFY discard table below.
- **Surgical Changes.** Every semantically changed line must trace directly
  to the user's request. Adjacent-code "improvements," formatting churn, and
  deletions of pre-existing dead code are `scope_drift` — discard.
- **Goal-Driven Execution.** Success criterion is a shell command exiting
  zero, not a vibe. Reject "works well" / "looks good" / "is faster" before
  coding; replace with a command.

Full prelude, including the pre-MODIFY checklist and line-trace rule:

@./skills/principles/SKILL.md

---

# Universal Protocol — governs ALL 126 skills

## 1. The Loop

Every iterative skill follows one loop. No exceptions.

```
round = 0
baseline = measure(metric_cmd)

WHILE goal_not_met AND budget_not_exhausted:
    round += 1
    REVIEW   — read state: in-scope files, last 10 of results.tsv, git log -5
    IDEATE   — propose ONE change (or N parallel agents, each ONE change)
    MODIFY   — implement, then commit immediately
    VERIFY   — run guard (test_cmd && lint_cmd); run metric_cmd 3x, take median
    DECIDE   — keep or discard (rules below)
    LOG      — append to .godmode/<skill>-results.tsv

Do NOT pause to ask. Do NOT wait for confirmation. Loop until goal, budget, or stuck.
```

## 2. Keep / Discard Rules

```
KEEP    if  metric improved  AND  guard passed
DISCARD if  metric worse     OR   guard failed
DISCARD if  lines_added > 5  AND  metric_delta < 0.5%   # complexity tax
DISCARD if  complexity_cost > improvement_magnitude      # simplicity wins
KEEP    if  same metric + fewer lines                    # free simplification
```

On discard: `git reset --hard HEAD~1`. Never leave broken commits.
On keep: update baseline, continue.

**Cheapest-discard-first precedence.** Discards have a cost hierarchy:

- **Cost-0: pre-MODIFY strike.** The item is never written. See
  `skills/principles/SKILL.md §2` pre-MODIFY checklist.
- **Cost-1: pre-commit audit.** Written, but dropped via
  `git restore -p --staged` before the commit lands. See
  `docs/discard-audit.md` for the spec.
- **Cost-2: post-commit revert.** This section's rules. `git reset
  --hard HEAD~1` after the guard fails or the metric regresses.

A Cost-2 discard that could have been caught at Cost-0 or Cost-1 is
logged as `escaped_discard` in `.godmode/lessons.md` in addition to its
primary failure class. Escaped discards are feedback for the pre-MODIFY
checklist — 3+ escapes in a session means the checklist is drifting and
the agent should re-read `skills/principles/SKILL.md §2` before IDEATE.

## 3. Simplicity Criterion

Concrete thresholds — apply universally:

| Added lines | Required improvement |
|-------------|---------------------|
| 1-5         | any positive delta  |
| 6-20        | >= 1%               |
| 21-50       | >= 3%               |
| 51+         | >= 5%               |

Same metric + fewer lines = always keep. Readability > marginal gains.

## 4. Stopping Conditions

Stop when ANY is true:

- **target_reached** — metric hit goal
- **budget_exhausted** — max rounds/iterations consumed
- **diminishing_returns** — last 3 keeps each < 1% improvement
- **stuck** — 5+ consecutive discards (after recovery attempts)

Log `stop_reason` in session-log.tsv. Always print final summary.

## 5. Stuck Recovery (4-step escalation)

```
Step 0: DIAGNOSE — read last 3 commit diffs + test output.
        Write a 2-sentence diagnosis: what pattern the failures share,
        and what constraint they all violate.
        Example: "Last 3 attempts all added caching layers.
        The metric is I/O-bound, not CPU-bound. Switch to async I/O."
Step 1: try OPPOSITE of last approach (informed by diagnosis)
Step 2: try RADICAL rewrite of hotspot (informed by diagnosis)
Step 3: accept defeat — stop, log "stuck", report best result
```

The diagnosis turns blind retries into informed pivots.
Never skip Step 0. The 2-sentence diagnosis must reference specific code or test output.
Never repeat a failed approach. Never loop without changing strategy.

## 6. Logging

All skills log to `.godmode/`:

**Per-skill:** `.godmode/<skill>-results.tsv`
```
round	change	metric_before	metric_after	delta%	status	lines_changed
```

**Session:** `.godmode/session-log.tsv`
```
timestamp	skill	rounds	kept	discarded	final_metric	stop_reason
```

Append only. Never overwrite. Create on first write.

## 7. Execution Rules

1. Detect stack FIRST (see orchestrator). Cache `stack`, `test_cmd`, `lint_cmd`, `build_cmd`.
2. Read `skills/<skill>/SKILL.md` — follow it literally. This protocol overrides on conflict.
3. Commit BEFORE verify. Revert on failure. Zero broken commits in history.
4. Multi-agent: <=5 agents/round, worktree isolation. Merge sequentially, test after each.
   For skills that support it, parallel hypothesis mode dispatches N agents
   on different approaches to the same problem. Best wins, rest discarded.
   This is different from multi-agent task dispatch (different parts of code).
5. No worktrees? Sequential branches: `godmode-{skill}-{round}`, merge winner, delete rest.
6. Metric = shell command outputting a single number. No subjective judgment. Ever.
7. `Iterations: N` = exactly N rounds. No number = loop until stopped. Never ask to continue.
8. Chain: think -> plan -> [predict] -> build -> test -> fix -> review -> optimize -> secure -> ship.

## 8. Failure Classification

Every DISCARD must be classified. Append to `.godmode/<skill>-failures.tsv`:

```
round	change	delta%	failure_class	reason	files_touched
```

**Failure classes (use exactly one per discard):**

| Class | When to use |
|--|--|
| measurement_error | Metric command flaky or non-deterministic (stdev > delta) |
| noise | Delta within variance threshold (<0.5%) |
| regression | Change broke something unrelated |
| file_scope_drift | Change touched files outside `task.files` (wrong file). Recovery: revert whole commit, re-dispatch with narrower `task.files`. |
| line_scope_drift | Change touched right file but added unrelated lines (formatting churn, adjacent "improvements," renames for consistency, deleted pre-existing dead code, auto-formatter reflows). Recovery: surgically drop drift hunks via `git restore -p --staged`, keep in-scope hunks, re-run guard. See `docs/discard-audit.md`. |
| complexity_tax | Improvement too small for lines added |
| infrastructure | Docker/env/dependency/tooling issue |
| already_tried | Similar approach discarded in last 10 rounds |
| overfitting | Improvement specific to one case, not generalizable |

**Before each IDEATE step, read the last 10 rows of failures.tsv:**
- If >3 failures in the same class: stop trying that approach category.
- If last 2 discards share a class: switch strategy before next attempt.
- Discarded runs still provide learning signal. Never delete failures.tsv.

## 9. Overfitting Prevention

Before every KEEP decision, apply these tests:

1. **Variance test:** Run metric_cmd 3 times. If stdev > |delta|, classify as `noise` and DISCARD.
2. **Generalization test:** "If this exact file/test disappeared, would this change still improve the project?" If NO → DISCARD as `overfitting`.
3. **No task-specific hacks:** Never add hardcoded logic for one specific test case, input, or benchmark. Fix the class of problems, not one instance.
4. **Simplification wins:** Equal metric + fewer lines = always KEEP. This is never overfitting.

## 10. Learning from Discards

Discarded runs still provide learning signal. Never waste a failure.

After every DISCARD:
1. Classify the failure (see Failure Classification above).
2. Append to `.godmode/<skill>-failures.tsv` with reason.
3. Check: has this failure class occurred 3+ times? If yes, that approach category is exhausted — switch strategy entirely.

Before every IDEATE:
1. Read last 10 rows of `<skill>-failures.tsv`.
2. Count failures per class.
3. Avoid the most common failure class. Try the LEAST common instead.
4. If all 8 classes have 2+ failures: escalate to stuck recovery.

The failures log is append-only. It persists across sessions. It is the memory of what NOT to try.

## 11. Environment Isolation

For reproducible metrics, optionally wrap metric_cmd in Docker:

```
metric_cmd_docker: "docker run --rm -v $(pwd):/app -w /app node:20 npm run benchmark"
```

When Docker is available AND metric variance > 5%:
- Build image once, cache dependencies.
- Run each metric measurement in a fresh container.
- Eliminates: cache drift, background process noise, dependency skew.

When Docker is NOT available (default):
- Run metric_cmd 3x, take median.
- Flag warning if variance > 5% between runs.
- Log variance in results.tsv as additional column.

Docker is recommended but never required. The loop works identically either way.

## 12. Session Resume

After every iteration, atomically save state to `.godmode/session-state.json`:

```json
{
  "skill": "optimize",
  "round": 7,
  "baseline": 847,
  "current_best": 198,
  "last_kept_commit": "abc1234",
  "consecutive_discards": 0,
  "approach_history": ["index", "gzip", "eager_load", "pool", "cache"],
  "failure_classes": {"noise": 2, "regression": 1},
  "stop_reason": null,
  "timestamp": "2026-04-04T12:30:00Z"
}
```

On session start:
1. Check `.godmode/session-state.json`. If exists and `stop_reason` is null:
   - Print: "Resuming from round {round}. Best so far: {current_best}."
   - Verify `last_kept_commit` matches HEAD. If not, warn and ask.
   - Continue the loop from round N+1.
2. If `stop_reason` is set: previous session completed. Start fresh.
3. If file doesn't exist: first run. Start fresh.

On session end (normal or interrupted):
- If loop completed: set `stop_reason` in state file.
- If interrupted: state file has `stop_reason: null` → next session resumes.

## 13. Lessons

Persistent learning across sessions. File: `.godmode/lessons.md`

**After each session**, append 1-3 lessons learned:
```
### Round N — {skill} — {date}
- Lesson: {concrete, reusable insight}
- Context: {what happened that taught this}
```

**Before each session**, read lessons.md:
- Apply relevant lessons to the current task.
- Never repeat a mistake that has a lesson entry.

**Format rules:**
- One lesson per bullet. Concrete and actionable.
- Bad: "Be careful with caching."
- Good: "Redis TTL must match DB write frequency. 60s TTL with 5min writes = stale reads."
- Lessons are append-only. Never delete. Mark obsolete lessons with `[OBSOLETE]`.

## 14. Default Activations

Every `/godmode:*` invocation — and every natural-language `/godmode` request
that routes to a pipeline skill (think, plan, build, test, fix, optimize,
secure, ship) — fires the full default stack below. No explicit flags
required. This section is the single source of truth for what runs by default.

### Authoring discipline (Karpathy family)

1. **Principles prelude** — `skills/principles/SKILL.md` is imported via
   `@./skills/principles/SKILL.md` from `SKILL.md`, `GEMINI.md`, `OPENCODE.md`.
   Every agent reads it before the first Edit. Governs: Think Before Coding,
   Simplicity First (pre-MODIFY strike), Surgical Changes (line-trace rule),
   Goal-Driven Execution.
2. **Pre-commit discard audit** — `agents/builder.md § Protocol 10a`,
   `agents/tester.md § Protocol 12a`, `agents/optimizer.md § Protocol 11a`.
   Before every `git commit`, drops `line_scope_drift` hunks via
   `git restore -p --staged`. Spec: `docs/discard-audit.md`.
3. **DispatchContext schema validation** — `AGENTS.md § DispatchContext
   Schema`. All 7 subagents validate input at dispatch time; missing required
   field → `BLOCKED: invalid_dispatch`.
4. **Discard cost hierarchy** — Cost-0 (pre-MODIFY strike), Cost-1 (pre-commit
   audit), Cost-2 (post-commit revert). Cost-2 discards that should have been
   caught earlier are logged as `escaped_discard` in `lessons.md`.
5. **Scope-drift taxonomy** — `file_scope_drift` (wrong file → revert whole
   commit) vs `line_scope_drift` (right file, wrong lines → drop hunks
   surgically). See `SKILL.md §8 Failure Classification`.

### Token optimization (caveman / rtk / Harness family)

6. **Progressive Disclosure routing** — `skills/godmode/SKILL.md § Step 2`
   reads ONLY Tier 1 (~20 lines) of each skill at route time via a POSIX awk
   extractor. ~90% routing-time context reduction across 134 skills.
7. **Stdio input-side compression** — `skills/stdio/SKILL.md`. Canonical
   command patterns (git log → git log --oneline -20, cat → wc -l, etc.)
   that every agent prefers. Referenced from `AGENTS.md § Context Refresh`.
8. **Terse output-side compression** — `skills/terse/SKILL.md`. Auto-activates
   from round 2 onward (lowered from 5 in Phase E) unless
   `terse_user_opted_out=true`. Compresses round summaries, status lines,
   agent reports. TSVs, code, errors, commit messages, final summary stay
   verbose.
9. **Token observability** — `skills/tokens/SKILL.md`. Logs per-round
   input/output token counts to `.godmode/token-log.tsv`. Default ON per
   session; opt out via `GODMODE_TOKENS=0`.
10. **Lessons compression** — `skills/godmode/SKILL.md § Step 0b` compresses
    `lessons.md` if it exceeds 100 lines before loading.

### Coordination and observability (Harness + best-practice family)

11. **Named coordination patterns** — `docs/coordination-patterns.md`.
    Every plan declares its outermost pattern (Pipeline, Fan-out/Fan-in,
    Expert Pool, Producer-Reviewer, Supervisor, Hierarchical Delegation)
    in its first line. Enforced in `skills/plan/SKILL.md`.
12. **Research auto-dispatch** — `skills/godmode/SKILL.md § Step 3` routes
    to `skills/research/SKILL.md` before `skills/think/` when the task
    mentions an external library/framework, spans >5 files, or has no prior
    `.godmode/research.md`.

### How the 8 pipeline skills inherit

Each of `think`, `plan`, `build`, `test`, `fix`, `optimize`, `secure`, `ship`
has a rule in its `## Hard Rules` section:

> **0. Inherits Default Activations per `SKILL.md §14`.** Principles prelude,
> pre-commit audit, terse, stdio, tokens, DispatchContext validation,
> Progressive Disclosure routing, discard cost hierarchy, and coordination
> patterns all fire by default. Do NOT require explicit flags; do NOT skip
> any of them unless the user opts out via documented env vars or slash
> commands.

Non-pipeline skills (like `bench`, `tutorial`, `team`) inherit §14 indirectly
through `skills/godmode/SKILL.md` — the orchestrator applies Step 0a, 0b,
and Step 3b checks regardless of which skill is dispatched.

### Opt-outs (the only way to disable a default)

| Default | Opt-out |
|---|---|
| Terse auto-activation | `/godmode:terse off` (sticky for session) or `GODMODE_TERSE=0` |
| Token logging | `GODMODE_TOKENS=0` env var |
| Pre-commit audit | Cannot opt out — it's a mechanical gate |
| Principles prelude | Cannot opt out — imported as `@./` prelude |
| DispatchContext validation | Cannot opt out — it's a hard gate |
| Progressive Disclosure | Cannot opt out — Tier 2/3 always loadable on demand |
| Research auto-dispatch | Pass `--no-research` flag OR run `/godmode:think` directly |

Everything else runs on every normal command.
