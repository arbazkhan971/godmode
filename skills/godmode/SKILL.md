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
| "refactor", "simplify" | refactor |
| "document", "docs" | docs |

No match → phase detection (Step 3).

## Step 3: Detect Phase
```
no spec, no plan           → THINK
spec exists, no plan       → PLAN
plan exists, tasks remain  → BUILD
code exists, tests failing → FIX
code exists, tests passing → OPTIMIZE or SHIP
```

## Step 4: Execute
Read `skills/{skill}/SKILL.md`. Follow it exactly. Pass cached stack vars.

## Rules
1. Detect stack FIRST. Cache result.
2. One skill at a time. Read its SKILL.md. Follow it.
3. Iterative skills (build/test/fix/debug/optimize/secure) use `WHILE` loops. Track `current_iteration`. No counter = not looping.
4. `Iterations: N` = bounded. No number = loop forever. Never ask "should I continue?"
5. Commit BEFORE verify. Revert on failure: `git reset --hard HEAD~1`.
6. Log iterations to `.godmode/<skill>-results.tsv`, skills to `.godmode/session-log.tsv`.
7. Stuck (>5 discards): re-read all, try opposite, try radical.
8. Multi-agent: up to 5 agents per round, `isolation: "worktree"`, scoped files. Merge sequentially. Test after each. Conflict → discard, retry.
9. Chain auto-transitions: `think → plan → build → test → fix → optimize → secure → ship`. Skip completed.
