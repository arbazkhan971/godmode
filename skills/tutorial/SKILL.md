---
name: tutorial
description: >
  Day-0 onboarding walkthrough. Gets a first-time user from
  a fresh install to a successful /godmode:think or
  /godmode:optimize session in under 5 minutes, with a
  concrete starter task and a reading of the results TSV.
---

## Activate When
- `/godmode:tutorial`, "how do I start", "first run"
- User has just installed godmode and has not yet produced a `.godmode/` directory
- User asks "what should I try first"

## Before You Begin
Terminal, git repo, one supported agent (Claude Code, Codex, Gemini
CLI, Cursor, or OpenCode). Don't use a branch you care about:
`git checkout -b godmode-tutorial`.

## Walkthrough

### Step 1: Detect your platform (30s)
```bash
command -v claude    && echo "-> Claude Code"
command -v codex     && echo "-> Codex"
command -v gemini    && echo "-> Gemini CLI"
command -v cursor    && echo "-> Cursor"
command -v opencode  && echo "-> OpenCode"
```
Expected: at least one line prints. Pitfall: if two print, pick the
one you actually intend to drive this session — skills are invoked
identically on all five, but Step 2's verify script is per-platform.

### Step 2: Verify godmode is installed (30s)
```bash
bash adapters/<plat>/verify.sh .   # e.g. adapters/codex/verify.sh .
```
Expected: a `Verification: N/N checks passed` summary with a non-zero
skill count. Quick sanity alternative:
```bash
ls skills/godmode/SKILL.md skills/optimize/SKILL.md skills/think/SKILL.md
```
All three must resolve. Pitfall: running verify from the wrong cwd.
It resolves `GODMODE_ROOT` relative to itself, but the target dir
defaults to `.` — pass an explicit path when verifying a project.

### Step 3: Pick a trivial starter task (30s)
Resist your hardest problem. Pick something a one-line shell command
can measure. A good day-0 task:

> "Reduce the word count of the first paragraph of `README.md` by
>  20% without changing its meaning."

Metric:
```bash
head -20 README.md | wc -w
```
Expected: one integer. That's your baseline. Pitfall: "make it
clearer" is not a metric — godmode will either refuse or invent a
bad one. If you can't write a shell command that returns a number,
you are not ready for `/godmode:optimize`.

### Step 4: Run /godmode:think and read the spec (90s)
```
/godmode:think Reduce first paragraph of README.md by 20% words.
Success: head -20 README.md | wc -w returns <= 0.8x baseline.
```
Expected: the session writes `.godmode/spec.md` and prints
`Think: wrote .godmode/spec.md (N lines)`. Open it:
```bash
cat .godmode/spec.md
```
You should see **Problem**, **Approach**, **Success Criteria**,
**Files to Modify**, **Risks**. Pitfall: if think asks a clarifying
question, answer in one sentence — do not turn the first run into a
20-message design debate.

### Step 5: Run /godmode:optimize with a 3-round budget (90s)
```
/godmode:optimize
Goal: shrink README.md intro
Metric: head -20 README.md | wc -w
Direction: down
Iterations: 3
```
Expected: a baseline line then up to three rounds, each tagged `KEPT`
or `DISCARDED`. The loop commits every attempt and
`git reset --hard HEAD~1`s on discards, so your tree stays clean.
Pitfall: forgetting `Iterations: 3`. Unbounded `/godmode:optimize` is
fine for real work, wrong for a tutorial.

### Step 6: Interpret .godmode/optimize-results.tsv (60s)
```bash
column -t -s $'\t' .godmode/optimize-results.tsv
```
Columns: `round`, `agent`, `change`, `metric_before`, `metric_after`,
`delta_pct`, `status`, `failure_class`.

- `status=KEPT` rows moved the baseline — they live in git.
- `status=DISCARDED` rows were reverted — no git presence, but the
  row stays as audit.
- Final delta = `(first_metric_before - last_kept_metric_after) /
  first_metric_before`. Kept 2 of 3 from 120 to 94 words = -21.7%.
- `failure_class` tells you *why* a change was thrown out. Repeated
  classes mean switch strategy, not retry — see
  `skills/optimize/SKILL.md` "Learning from Discards".

Pitfall: treating `DISCARDED` rows as bugs. They are the point. An
empty `optimize-failures.tsv` is suspicious, not reassuring.

### Step 7: Next skills to try (30s)
You now have the keep/discard loop model. It powers every iterative
skill. Natural next commands:

- `/godmode:build` — TDD-style feature build against a spec
- `/godmode:secure` — STRIDE + OWASP audit over a target path
- `/godmode:ship` — preflight checks before deploy

The full 126-skill catalog lives in `AGENTS.md` and
`docs/COMPLETE-SKILL-LIST.md`. Godmode's orchestrator also routes
natural language: `/godmode "make this faster"` dispatches `optimize`.

## Common Pitfalls
- **Running on main/master.** Use a scratch branch. Discards run
  `git reset --hard HEAD~1` — you want that on a throwaway branch.
- **No mechanical metric.** "Better code" is not a metric. If your
  goal can't be reduced to `cmd -> one number`, run `/godmode:think`
  first, not `/godmode:optimize`.
- **Unbounded first run.** Always pass `Iterations: 3` (or similar)
  on your first tutorial pass. You are learning the loop, not
  squeezing the last 0.5% out of a hot path.
- **Dirty working tree.** Godmode expects a clean tree at session
  start. Commit or stash before invoking any skill that writes code.
- **Confusing stop reasons.** `diminishing_returns` and
  `budget_exhausted` are normal completions, not failures. Only
  `stuck` and `guard_broken` mean something went wrong.
- **Ignoring `.godmode/session-state.json`.** If a session is
  interrupted, the next `/godmode` call resumes at the saved round
  unless `stop_reason` is already set. Delete the file to force a
  fresh start.

## What To Read Next
- `README.md` — the 30-second pitch and the worked examples at the
  top are the shortest path to "why godmode exists."
- `SKILL.md` (repo root) — the Universal Protocol that governs all
  126 skills. Short, dense, worth one full read.
- `skills/godmode/SKILL.md` — the orchestrator. Read this before you
  write any custom skill; every skill file inherits its conventions.
- `skills/optimize/SKILL.md` — the canonical iterative loop. Step 5
  above is a 3-iteration subset of what's described here.
- `docs/PHILOSOPHY.md` — the design principles behind keep/discard,
  git-as-memory, and mechanical verification.
- `docs/getting-started.md` and `docs/quick-start.md` — longer-form
  onboarding if 5 minutes wasn't enough.

## Output Format
```
Tutorial: platform={plat}. Verified {N}/{N} checks.
Tutorial: starter task -- {one line}. Baseline = {N}.
Tutorial: think wrote .godmode/spec.md ({N} lines).
Tutorial: optimize ran {R} rounds. Kept={K} Discarded={D}.
Tutorial: final delta {pct}. Next: /godmode:build.
```

## Hard Rules
1. Never run the tutorial on a branch you care about.
2. Always bound the first `/godmode:optimize` with `Iterations: 3`.
3. Metric must be a shell command returning one number. No prose.
4. If `/godmode:think` asks a clarifying question, answer in one
   sentence and move on.
5. Do not delete `.godmode/` mid-session — it holds the resume state.

## Stop Conditions
```
STOP when FIRST of:
  - all 7 steps completed and optimize-results.tsv has >= 1 KEPT row
  - user gives up (session aborted)
  - > 5 minutes elapsed on any single step (you hit a real problem,
    switch to docs/troubleshooting.md)
```
