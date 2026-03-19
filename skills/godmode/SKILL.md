---
name: godmode
description: |
  Orchestrator. Routes to 126 skills. Auto-detects project stack and phase. Runs autonomous iteration loops. Dispatches multi-agent parallel execution in worktrees. Never stops. Never asks.
---

# Godmode — Orchestrator

## Activate When
- `/godmode` without subcommand
- `/godmode:<skill>` — read `skills/<skill>/SKILL.md`, follow it
- Natural language request → match to skill (see table below)

## Step 1: Detect Stack (once, cache result)
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
Check lockfiles for package manager: `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, `uv.lock` → uv.
If `package.json` has `"test"` script → use `npm test`. If it has `"lint"` → use that.

## Step 2: Match Skill
| Trigger | Skill |
|---------|-------|
| "make faster", "optimize", "improve" | optimize |
| "fix", "broken", "error", "doesn't work" | fix |
| "debug", "why is this happening" | debug |
| "test", "coverage", "write tests" | test |
| "secure", "vulnerabilities", "harden" | secure |
| "review", "check my code" | review |
| "build", "implement", "create" | build |
| "plan", "break down", "decompose" | plan |
| "think", "design", "approach" | think |
| "ship", "release", "deploy" | ship |
| "refactor", "clean up", "simplify" | refactor |
| "document", "add docs" | docs |
If no match → fall through to phase detection (Step 3).

## Step 3: Detect Phase
```
IF no spec AND no plan           → THINK  (invoke think)
IF spec exists BUT no plan       → PLAN   (invoke plan)
IF plan exists, tasks remaining  → BUILD  (invoke build)
IF code exists, tests failing    → FIX    (invoke fix)
IF code exists, tests passing    → OPTIMIZE or SHIP
```

## Step 4: Execute
Read the matched skill's SKILL.md. Follow its workflow.
For chain execution: `think → plan → build → test → fix → optimize → secure → ship`
Between steps, print: `── chain: build ✓ → test ──`
Never ask "should I continue?" between chain steps.

---

## The Loop — Core Principle
Every iterative skill (optimize, fix, debug, test, secure) defines its own `WHILE` loop. Follow it literally. The universal invariants:
- Track `current_iteration`. If you're not counting, you're not looping.
- Commit BEFORE verify. Revert on failure: `git reset --hard HEAD~1`.
- Log every iteration to `.godmode/<skill>-results.tsv`.
- `Iterations: N` = bounded. No number = loop forever. Never ask "should I continue?"
- Stuck (>5 discards): re-read all files, try opposite, try radical.

---

## Multi-Agent Dispatch
When 2+ independent tasks touch different files: dispatch up to 5 agents per round, each with task description, skill reference, file scope, and `isolation: "worktree"`. Merge sequentially. Test after each merge. Conflict or test fail → resolve or discard, retry.
When NOT to parallelize: single file, single skill, user says "sequential".

---

## Rules
1. Detect stack FIRST. Never hardcode `npm test` on a Rust project.
2. One skill at a time. Read its SKILL.md. Follow it.
3. Never ask "should I continue?" in loop mode.
4. Log every skill to `.godmode/session-log.tsv`: timestamp, skill, duration, outcome.
5. Commit before verify. Revert on failure. One change per iteration.
6. Multi-agent: max 5 per round. Scope files. Merge sequentially.
7. Chain auto-transitions. Skip completed phases.
