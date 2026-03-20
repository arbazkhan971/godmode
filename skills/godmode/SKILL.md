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

## Step 2: Match Skill
| Trigger | Skill |
|---------|-------|
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

## Step 3: Detect Phase
```
no .godmode/spec.md, no plan  → THINK
.godmode/spec.md exists, no .godmode/plan.yaml → PLAN
.godmode/plan.yaml exists, incomplete tasks  → BUILD
code exists, tests failing → FIX
code exists, tests passing → OPTIMIZE or SHIP
```

## Step 4: Execute
Read `skills/{skill}/SKILL.md`. Follow it exactly. Pass: stack, test_cmd, lint_cmd, build_cmd.

## Rules
1. Detect stack FIRST. Cache result. One skill at a time — read its SKILL.md, follow it.
2. Iterative skills (build/test/fix/debug/optimize/secure) use `WHILE` loops. Track `current_iteration`. No counter = not looping.
3. `Iterations: N` = bounded. No number = loop forever. Never ask "should I continue?"
4. Commit BEFORE verify. Revert on failure: `git reset --hard HEAD~1`.
5. Log iterations to `.godmode/<skill>-results.tsv` (columns defined per skill), sessions to `.godmode/session-log.tsv`: timestamp, skill, iterations, outcome.
6. Stuck (>5 discards): re-read all, try opposite, try radical.
7. Multi-agent: up to 5 agents per round, `isolation: "worktree"`, scoped files. Merge sequentially. Test after each. Conflict → discard, retry.
8. Chain: `think → plan → build → test → fix → review → optimize → secure → ship`. Auto-advance when current skill completes.
