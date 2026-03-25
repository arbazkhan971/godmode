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

## Step 2: Match Skill

```
| Trigger                            | Skill    |
|------------------------------------|----------|
| "make faster", "optimize"          | optimize |
| "fix", "broken", "error"          | fix      |
| "debug", "why is this"            | debug    |
| "test", "coverage"                | test     |
| "secure", "vulnerabilities"       | secure   |
| "review", "check my code"         | review   |
| "build", "implement", "create"    | build    |
| "plan", "break down"              | plan     |
| "ship", "deploy"                  | ship     |
| "done", "finish", "clean up"      | finish   |

IF no match: fall through to phase detection
```

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
