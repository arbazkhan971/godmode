---
name: godmode
description: |
  Orchestrator. Routes to skills, detects stack/phase,
  dispatches multi-agent worktrees.
  Triggers on: /godmode, /godmode:<skill>.
---

## Activate When
- `/godmode` without subcommand
- `/godmode:<skill>` — read `skills/<skill>/SKILL.md`
- Natural language request → match to skill

## Step 0a: Check Terse Mode
IF `$GODMODE_TERSE` is set OR `/godmode:terse on` was invoked this session:
compress all emitted output per `skills/terse/SKILL.md`. TSV rows, code blocks,
error messages, commit messages, and the final user-facing summary stay
verbose. Terse is an emit contract only — loops, decisions, commits, and
TSV writes are identical in both modes. See `skills/terse/SKILL.md` for the
full contract and the before/after examples.

Also check `.godmode/session-state.json` for auto-activation. If the file
exists and `consecutive_rounds_without_human >= 5` AND
`terse_user_opted_out != true`: auto-enable terse for this round and emit
the activation message defined in `skills/terse/SKILL.md § Auto-Activation`.
This check runs at the START of every round, before the loop body. The
counter is incremented at the END of each round (immediately after DECIDE
and LOG) and reset to 0 at the START of any round that was triggered by a
new user prompt. A user-issued `/godmode:terse off` sets `terse_user_opted_out`
to true for the remainder of the session and disables auto-activation.

## Step 0: Check for Resumable Session
Read `.godmode/session-state.json` if it exists.
IF `stop_reason` is null: resume the interrupted skill at the saved round.
IF `stop_reason` is set OR file missing: proceed with fresh detection.
Print resume status at start of every session.

## Step 0b: Load Lessons
Read `.godmode/lessons.md` if it exists.
Surface relevant lessons for the detected skill.
After session: append 1-3 new lessons.

IF `lessons.md` exceeds 100 lines: compress before loading. Keep entries from
the last 30 days AND entries referenced (cited) more than twice. Mark stale
entries `[OBSOLETE]` rather than deleting — the file is append-only history.
After compression, re-read and continue. Target post-compression length: ≤60
lines. This keeps the lesson-loading context lean on long-running sessions
where the file would otherwise grow unbounded.

## Step 1: Detect Stack (once, cache)

```bash
# Detect project stack from root files
ls package.json pyproject.toml Cargo.toml go.mod \
  Gemfile pom.xml 2>/dev/null

# Detect lockfile for package manager
ls yarn.lock pnpm-lock.yaml uv.lock \
  package-lock.json 2>/dev/null

# Verify commands work
$test_cmd --version 2>/dev/null
$lint_cmd --version 2>/dev/null
```

```
STACK DETECTION:
| Files                         | Stack      | test_cmd      | lint_cmd      | build_cmd      |
|-------------------------------|------------|---------------|---------------|----------------|
| package.json + next.config.*  | Next.js    | npm test      | eslint --fix  | npm run build  |
| package.json + tsconfig.json  | TypeScript | npx vitest    | eslint --fix  | tsc --noEmit   |
| pyproject.toml                | Python     | pytest        | ruff check .  | —              |
| Cargo.toml                    | Rust       | cargo test    | cargo clippy  | cargo build    |
| go.mod                        | Go         | go test ./... | golangci-lint | go build ./... |

IF no match: ask user for test/lint/build commands
IF lockfile found: use matching package manager
```

## Step 2: Match Skill (Tier 1 routing)

Read ONLY Tier 1 of each skill file to match the user's request. Tier 1 =
frontmatter + the `## Activate When` block. The Tier 1 boundary is the
first `## ` header that follows `## Activate When`. Everything after that
boundary is Tier 2 (loaded only once a skill is matched) or Tier 3 (loaded
only on edge cases, marked by a literal `tier-3` HTML comment).

```bash
# Tier 1 extractor — POSIX awk, reads only the Activate When block
for f in skills/*/SKILL.md; do
  awk '/^## Activate When/{found=1} found && /^## /{if(seen++)exit} {print}' "$f"
done
```

Tier 1 never exceeds ~25 lines per skill. Total routing cost across 134
skills is ~2,700 lines — ~90% less than reading every skill in full (~27k
lines). Stacks with `skills/terse/` (output-side compression), `skills/stdio/`
(input-side canonical commands), and rtk (if installed) for compound
context savings.

Match process:
1. Scan all Tier 1 blocks for keyword hits in frontmatter `description:`
   plus `## Activate When` bullets.
2. Pick the skill with the most trigger hits. Tie-break: shorter
   `## Activate When` list wins (more specific trigger).
3. Once matched, read the FULL matched skill file up to the
   `tier-3` HTML comment marker if present (Tier 2 auto-included).
4. If the skill has a Tier 3 section AND the loop hits a failure class
   from `SKILL.md §8` (error recovery, quality target verification,
   platform fallback), read past the marker.

Canonical trigger shortcuts (fastest path — if a request matches one of
these exactly, skip the Tier 1 scan):

```
| Trigger                            | Skill    |
|------------------------------------|----------|
| "make faster", "optimize"          | optimize |
| "fix", "broken", "error"           | fix      |
| "debug", "why is this"             | debug    |
| "test", "coverage"                 | test     |
| "secure", "vulnerabilities"        | secure   |
| "review", "check my code"          | review   |
| "research", "prior art"            | research |
| "build", "implement", "create"     | build    |
| "plan", "break down"               | plan     |
| "ship", "deploy"                   | ship     |
| "done", "finish", "clean up"       | finish   |
| "terse", "compress output"         | terse    |
| "tokens", "token budget"           | tokens   |
| "stdio", "command patterns"        | stdio    |
| "team", "bundle"                   | team     |
| "tutorial", "onboarding"           | tutorial |
| "bench", "benchmark"               | bench    |

IF no match: fall through to phase detection (Step 3).
```

Skills whose Tier 1 block fails to parse (missing `## Activate When`,
malformed frontmatter) are routing-invisible. The only skill without
`## Activate When` is `skills/principles/SKILL.md`, which is imported
directly as a prelude via `@./skills/principles/SKILL.md` and not
routable — this is intentional.

## Step 3: Detect Phase (State Machine)

```
PHASE DETECTION:
  no spec, no plan                → THINK
  spec exists, no plan            → PLAN
  plan exists, tasks incomplete   → BUILD
  code exists, tests failing      → FIX
  tests passing, unreviewed       → REVIEW
  reviewed, metrics unoptimized   → OPTIMIZE
  all green                       → SHIP

THRESHOLDS:
  Stuck recovery: > 5 consecutive discards
    → try opposite approach
    → if still stuck: escalate to previous phase
    → if still stuck: log reason, move to next task
```

## Step 3b: Failure-Aware Routing

Before routing to any skill, check `.godmode/<skill>-failures.tsv` if it exists.
If the target skill has >10 consecutive failures: suggest an alternative skill or approach.
Surface failure patterns in the session summary: "optimize had 5 noise failures — metric may be non-deterministic."

## Step 4: Execute
Read `skills/{skill}/SKILL.md`. Follow it literally.
Pass: `stack`, `test_cmd`, `lint_cmd`, `build_cmd`.

## Output Format
Print: `Godmode: stack={stack}, skill={skill},
  phase={phase}. Dispatching.`
After: `Godmode: {skill} complete. Next: {next}.`

## Quality Targets
- Skill routing: <2s to match and dispatch
- Stack detection: <5s for full project analysis
- Target: >95% correct skill match on natural language input

## Hard Rules
Never ask to continue. Loop autonomously until done.

1. Detect stack FIRST — cache result. Never guess.
2. One skill at a time — read SKILL.md, follow it.
3. Commit BEFORE verify — revert on failure.
4. Log every invocation to `.godmode/session-log.tsv`.
5. Stuck recovery: > 5 discards triggers escalation.

## Rules
1. Iterative skills use WHILE loops with counter.
2. `Iterations: N` = run exactly N times then stop.
3. Commit before verify. Revert: `git reset --hard HEAD~1`.
4. Log: `.godmode/<skill>-results.tsv` (append only).
5. Session: `.godmode/session-log.tsv` with stop_reason:
   target_reached | budget_exhausted |
   diminishing_returns | stuck | user_interrupt
6. KEEP/DISCARD: atomic — commit before verify,
   revert if verify fails.
7. Multi-agent: <= 5 agents/round, worktree isolation.
8. Chain: think → plan → [predict] → build → test
   → fix → review → optimize → secure → ship.

## Keep/Discard Discipline
```
KEEP if: metric improved AND guard passed
  (build_cmd && lint_cmd && test_cmd)
DISCARD if: metric worsened OR guard failed
On discard: git reset --hard HEAD~1. Log reason.
```

## Meta-Loop (Outer Loop)

After each skill completes, analyze results and decide the next skill:

```
WHILE project_goal_not_met:
  result = run_current_skill()
  IF result.status == "DONE" AND result.findings > 0:
    next_skill = route_findings(result)  # e.g., optimize found security issue → secure
  ELIF result.status == "DONE" AND result.findings == 0:
    next_skill = advance_phase()          # move to next phase in chain
  ELIF result.status == "STUCK":
    next_skill = escalate_or_skip()       # try alternative skill
  LOG to session-log.tsv
```

The meta-loop enables: optimize → review finds issue → fix → re-optimize → secure → ship.
Without it, each skill runs in isolation. With it, skills chain automatically.

## Persistence

If session ends mid-loop, .godmode/session-state.json preserves state.
The stop hook notifies the user to run /godmode to resume.
For fully autonomous overnight runs: use Ralph Loop or /loop with godmode.

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: spec/goal fully achieved
  - budget_exhausted: max iterations hit
  - diminishing_returns: last 3 iters each < 1%
  - stuck: > 5 consecutive discards
```

## TSV Logging
```
timestamp	skill	iterations	kept	discarded	stop_reason	outcome
```

## Error Recovery
| Failure | Action |
|---------|--------|
| No stack match | Ask user for commands. Cache. |
| SKILL.md missing | List available, suggest closest. |
| Stuck in loop | Escalate to previous phase. |
| Merge conflict | Discard agent, re-queue narrower. |

```bash
# Detect project stack from root files
ls package.json pyproject.toml Cargo.toml go.mod 2>/dev/null
git log --oneline -5
```

