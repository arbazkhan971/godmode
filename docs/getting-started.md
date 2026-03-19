# Getting Started with Godmode

This guide walks you through your first Godmode session, from installation to shipping a feature.

## Installation

```bash
# Install the Godmode plugin
claude plugin install godmode
```

## First Run: Setup

When you first use Godmode in a project, it automatically detects your environment:

```bash
/godmode:setup
```

Godmode will detect:
- Your programming language and framework
- Your test command (e.g., `npm test`, `pytest`, `cargo test`)
- Your lint command (e.g., `npm run lint`, `ruff check .`)
- Your build command (if applicable)

It saves this to `.godmode/config.yaml`. You can edit this file directly or run `/godmode:setup` again.

## Your First Feature: End-to-End Walkthrough

Let's build a rate limiter for an API from scratch using the full Godmode workflow.

### Step 1: Think (Design)

```
/godmode:think I need to add rate limiting to our Express.js API
```

Godmode will:
1. Research your codebase for existing patterns
2. Ask one clarifying question (e.g., "Per-user or global rate limiting?")
3. Propose 2-3 approaches with tradeoffs
4. Help you choose
5. Write a spec to `docs/specs/rate-limiter.md`

**Time: 3-5 minutes**

### Step 2: Plan (Decompose)

```
/godmode:plan
```

Godmode will:
1. Read the spec you just created
2. Identify files to create and modify
3. Break the feature into 8-12 tasks, each 2-5 minutes
4. Each task has exact file paths, code sketches, and test requirements
5. Create a feature branch

**Output:** `docs/plans/rate-limiter-plan.md` on branch `feat/rate-limiter`

**Time: 2-3 minutes**

### Step 3: Build (Implement)

```
/godmode:build
```

Godmode will execute each task using TDD:
1. **RED** — Write a failing test
2. **GREEN** — Implement the minimum code to pass
3. **REFACTOR** — Clean up without changing behavior
4. Commit at every step
5. Run code review at phase boundaries

Independent tasks run in parallel via agent dispatch.

**Time: 15-30 minutes** (depending on feature complexity)

### Step 4: Optimize (Improve)

```
/godmode:optimize --goal "reduce rate limiter overhead" --verify "npm run bench" --target "< 1ms"
```

Godmode runs an autonomous loop:
1. Measures baseline performance
2. Hypothesizes an improvement
3. Makes one change
4. Verifies mechanically (runs the benchmark)
5. Keeps the change if better, reverts if not
6. Repeats until the target is met

**Time: 5-15 minutes** (autonomous)

### Step 5: Secure (Audit)

```
/godmode:secure
```

Godmode runs a full security audit:
- STRIDE threat analysis
- OWASP Top 10 checklist
- 4 red-team personas probe for vulnerabilities
- Every finding has code evidence and remediation

**Time: 3-5 minutes**

### Step 6: Ship (Deploy)

```
/godmode:ship --pr
```

Godmode runs the 8-phase shipping workflow:
1. Inventories all changes
2. Runs pre-ship checklist
3. Prepares the branch (rebase, build)
4. Dry-runs the PR
5. Creates the PR with full description
6. Verifies CI passes

**Output:** A pull request URL

**Time: 2-3 minutes**

## Quick Reference

### I want to...

| Goal | Command |
|------|---------|
| Start a new feature | `/godmode:think <description>` |
| Check what to do next | `/godmode` |
| Break a spec into tasks | `/godmode:plan` |
| Start building | `/godmode:build` |
| Fix failing tests | `/godmode:fix` |
| Investigate a bug | `/godmode:debug` |
| Improve performance | `/godmode:optimize --goal "<goal>"` |
| Check security | `/godmode:secure` |
| Create a PR | `/godmode:ship --pr` |
| Configure Godmode | `/godmode:setup` |

## Tips for Success

### 1. Trust the process
Godmode's workflow is: THINK, BUILD, OPTIMIZE, SHIP. Skipping phases (especially THINK) leads to rework. Take the 5 minutes to design first.

### 2. Let the loop run
The optimization loop will try things that don't work. That's expected and valuable. Don't interrupt it — let it finish its iterations.

### 3. Read the logs
Godmode produces detailed logs in `.godmode/`:
- `optimize-results.tsv` — Every optimization iteration
- `fix-log.tsv` — Every error fix
- `ship-log.tsv` — Every shipment

These logs are your project's memory.

### 4. Commit the .godmode directory
The `.godmode/` directory should be in version control. It contains your project's Godmode configuration and experiment history. Teammates benefit from the same setup.

### 5. Chain skills
Skills are designed to chain together:
```
think → predict → plan → build → optimize → secure → ship
```

You don't have to run every skill every time. Use what you need. But the full chain produces the best results.

## Troubleshooting

### "No spec found"
Run `/godmode:think` first to create a specification, then `/godmode:plan`.

### "Tests are failing before build"
Run `/godmode:fix` to fix existing failures before starting a new build.

### "Optimization loop not making progress"
If 3 consecutive iterations are reverted, Godmode stops automatically. This means the easy wins are gone. Consider a different approach (re-think the design) or accept the current performance.

### "Setup didn't detect my tools"
Run `/godmode:setup` and provide the commands manually when prompted. Then verify with `/godmode:setup --validate`.
