---
name: godmode
description: Orchestrator. Routes to skills, detects stack/phase, dispatches multi-agent worktrees.
---

## Activate When
- `/godmode` without subcommand
- `/godmode:<skill>` — read `skills/<skill>/SKILL.md`, follow it
- Natural language request → match to skill

## Step 1: Detect Stack (once, cache)
Check root for these files. First match wins. Cache as `stack`, `test_cmd`, `lint_cmd`, `build_cmd`.
```
package.json + next.config.*  → Next.js    | npm test      | eslint --fix  | npm run build
package.json + tsconfig.json  → TypeScript | npx vitest    | eslint --fix  | tsc --noEmit
package.json                  → JavaScript | npm test      | eslint --fix  | npm run build
pyproject.toml                → Python     | pytest        | ruff check .  | —
Cargo.toml                    → Rust       | cargo test    | cargo clippy  | cargo build
go.mod                        → Go         | go test ./... | golangci-lint | go build ./...
Gemfile                       → Ruby       | rspec         | rubocop -A    | —
pom.xml                       → Java       | mvn test      | checkstyle    | mvn package
```
Lockfiles: `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, `uv.lock` → uv.
No match → ask user for test/lint/build commands. Cache those.

## Step 2: Match Skill
| Trigger | Skill |
|--|--|
| "make faster", "optimize", "improve" | optimize |
| "fix", "broken", "error" | fix |
| "debug", "why is this" | debug |
| "test", "coverage" | test |
| "secure", "vulnerabilities" | secure |
| "review", "check my code" | review |
| "build", "implement", "create" | build |
| "plan", "break down" | plan |
| "think", "design" | think |
| "ship", "deploy" | ship |
| "what could go wrong", "edge cases" | scenario |
| "predict", "will this work", "evaluate" | predict |
| "done", "finish", "clean up" | finish |
| "prove it", "verify" | verify |

No match → phase detection (Step 3).

## Step 3: Detect Phase (State Machine)
```
no .godmode/spec.md, no plan       → THINK
spec exists, no .godmode/plan.yaml → PLAN
plan exists, tasks incomplete      → BUILD
code exists, tests failing         → FIX
tests passing, unreviewed          → REVIEW
reviewed, metrics unoptimized      → OPTIMIZE
all green                          → SHIP
```
Transitions are forward-only unless stuck recovery triggers a rollback (see Rules §6).

## Step 4: Execute
Read `skills/{skill}/SKILL.md`. Follow it literally. Pass: `stack`, `test_cmd`, `lint_cmd`, `build_cmd` as variables.

## Output Format
Print: `Godmode: stack={stack}, skill={skill}, phase={phase}. Dispatching.`
After skill completes, print: `Godmode: {skill} complete. Next: {next_skill_or_done}.`

## Hard Rules
1. Detect stack FIRST — cache result. Never guess test/lint/build commands.
2. One skill at a time — read its SKILL.md, follow it literally. No improvisation.
3. Commit BEFORE verify — revert on failure with `git reset --hard HEAD~1`.
4. Log every skill invocation to `.godmode/session-log.tsv` — append, never overwrite.
5. Stuck recovery: >5 consecutive discards triggers opposite approach, then re-plan, then stop.

## Rules
1. Detect stack FIRST. Cache result. One skill at a time — read its SKILL.md, follow it.
2. Iterative skills (build/test/fix/debug/optimize/secure) use `WHILE` loops. Initialize `current_iteration = 0`. Increment at loop top.
3. `Iterations: N` = run exactly N times then stop+summarize. No number = loop until interrupted. Never ask to continue.
4. Commit BEFORE verify. Revert on failure: `git reset --hard HEAD~1`. Never leave broken commits in history.
5. Log: `.godmode/<skill>-results.tsv` (append, never overwrite). Session: `.godmode/session-log.tsv`: timestamp, skill, iters, kept, discarded, stop_reason, outcome.
   `stop_reason` values:
   - `target_reached` — spec/goal fully achieved
   - `budget_exhausted` — max iterations hit
   - `diminishing_returns` — last 3 iters each < 1% improvement
   - `stuck` — >5 consecutive discards
   - `error_cascade` — >3 failed attempts on same task
   - `user_interrupt` — manual stop
6. KEEP/DISCARD: All iterative phases follow the meta-protocol in root SKILL.md. Decisions are atomic — commit before verify, revert if verify fails.
7. Stuck recovery (>5 consecutive discards):
   1. Try opposite approach within same phase. Re-read all in-scope files. Never repeat failed approach.
   2. If still stuck: escalate to previous phase (e.g., BUILD stuck → re-PLAN).
   3. If still stuck after re-plan: log `stuck_reason` in session-log.tsv, move to next task.
8. Multi-agent: ≤5 agents/round, `isolation: "worktree"`. Each agent sees only task.files. Merge sequentially. Test after each. Conflict → discard, re-queue.
9. Chain: `think → plan → [predict] → build → test → fix → review → optimize → secure → ship`. [predict] optional but recommended.

## Keep/Discard Discipline
```
All iterative skills follow this discipline:
  KEEP if: metric improved AND guard (build_cmd && lint_cmd && test_cmd) passed
  DISCARD if: metric worsened OR guard failed
  On discard: git reset --hard HEAD~1. Log discard in session-log.tsv.
  Decisions are atomic — commit before verify, revert if verify fails.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: spec/goal fully achieved
  - budget_exhausted: max iterations hit
  - diminishing_returns: last 3 iterations each < 1% improvement
  - stuck: >5 consecutive discards
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- **Rule 8 (multi-agent):** Execute tasks sequentially in the current session instead of dispatching parallel agents. One task at a time, commit after each.
- **Worktree isolation:** Use branch-based isolation: `git checkout -b godmode-{task}`, work, merge back. See `adapters/shared/sequential-dispatch.md`.
- **All other rules apply unchanged.** The loop, verification, rollback, and logging work identically.

## Error Recovery
| Failure | Action |
|--|--|
| Stack detection finds no match | Ask user for `test_cmd`, `lint_cmd`, `build_cmd`. Cache the answers. Do not guess. |
| Skill SKILL.md not found | List available skills with `ls skills/`. Suggest closest match. Never fabricate skill instructions. |
| Stuck in phase loop (>5 discards) | Escalate to previous phase (BUILD stuck -> re-PLAN). Log `stuck_reason` in session-log.tsv. |
| Agent merge conflict | Discard conflicting agent. Re-queue task with narrower scope in next round. |

## Success Criteria
1. Stack detected and cached with correct `test_cmd`, `lint_cmd`, `build_cmd`.
2. Skill matched and its SKILL.md followed to completion.
3. Session logged in `.godmode/session-log.tsv` with stop_reason.
4. No broken commits left in history (reverted on failure).

## TSV Logging
Append to `.godmode/session-log.tsv`:
```
timestamp	skill	iterations	kept	discarded	stop_reason	outcome
```
One row per skill invocation. Never overwrite previous rows.
