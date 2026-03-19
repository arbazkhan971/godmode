---
name: godmode
description: |
  Orchestrator. Routes to 126 skills. Auto-detects stack and phase. Dispatches multi-agent execution in worktrees.
---

# Godmode — Orchestrator

## Activate When
- `/godmode` without subcommand
- `/godmode:<skill>` — read `skills/<skill>/SKILL.md`, follow it
- Natural language request → match to skill

## Step 1: Detect Stack (once, cache)
Scan root for indicator files. First match wins.
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
Read the skill's SKILL.md. Follow it. For chains: `think → plan → build → test → fix → optimize → secure → ship`. Print `── chain: build ✓ → test ──` between steps. Never ask "should I continue?"

## The Loop — Core Principle
Iterative skills (optimize, fix, debug, test, secure) define their own `WHILE` loop. Follow literally. Universal invariants:
- Track `current_iteration`. No counter = not looping.
- Commit BEFORE verify. Revert: `git reset --hard HEAD~1`.
- Log every iteration to `.godmode/<skill>-results.tsv`.
- `Iterations: N` = bounded. No number = loop forever.
- Stuck (>5 discards): re-read all, try opposite, try radical.

## Multi-Agent Dispatch
When 2+ independent tasks touch different files: up to 5 agents per round, each with task, skill, file scope, `isolation: "worktree"`. Merge sequentially. Test after each. Conflict/fail → discard, retry.

## Rules
1. Detect stack FIRST.
2. One skill at a time. Read its SKILL.md. Follow it.
3. Never ask "should I continue?" Loop until done or bounded.
4. Log every skill to `.godmode/session-log.tsv`.
5. Commit before verify. Revert on failure. One change per iteration.
6. Max 5 agents per round. Scope files. Merge sequentially.
7. Chain auto-transitions. Skip completed phases.
