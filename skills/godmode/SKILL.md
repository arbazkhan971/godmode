---
name: godmode
description: |
  Orchestrator skill. Activates when user says /godmode without a subcommand, or when context suggests a phase transition. Auto-detects current project phase (THINK/BUILD/OPTIMIZE/SHIP) by examining git history, test status, and file state. Routes to the appropriate sub-skill. Also activates on ambiguous requests where the right skill is unclear.
---

# Godmode — The Orchestrator

## When to Activate
- User invokes `/godmode` without a subcommand
- User describes a goal but doesn't specify which phase to start with
- A sub-skill completes and the next phase needs to be determined
- User asks "what should I do next?" or similar orientation questions

## Workflow

### Step 1: Gather Context
Collect signals to determine the current project phase:

1. **Git state** — Are there uncommitted changes? What branch are we on? How many commits since branch creation?
2. **Test state** — Do tests exist? Do they pass? What's the coverage?
3. **Error state** — Are there lint errors, type errors, or failing tests?
4. **File state** — Is there a spec? A plan? Implementation code? Is it complete?
5. **User intent** — What did the user just say? What are they trying to accomplish?

### Step 2: Detect Phase

```
IF no spec exists AND no plan exists:
  → THINK phase (suggest /godmode:think)

IF spec exists BUT no plan OR incomplete plan:
  → BUILD phase, planning stage (suggest /godmode:plan)

IF plan exists AND tasks remain unimplemented:
  → BUILD phase, execution stage (suggest /godmode:build)

IF implementation exists AND tests fail:
  → OPTIMIZE phase, fix stage (suggest /godmode:fix)

IF implementation exists AND tests pass BUT performance/quality issues:
  → OPTIMIZE phase (suggest /godmode:optimize)

IF implementation exists AND tests pass AND quality is good:
  → SHIP phase (suggest /godmode:ship)

IF security review requested OR pre-ship:
  → OPTIMIZE phase, security stage (suggest /godmode:secure)

IF errors in logs or stack traces mentioned:
  → OPTIMIZE phase, debug stage (suggest /godmode:debug)
```

### Step 3: Present Recommendation

Output a brief status card:

```
┌─────────────────────────────────────────┐
│  GODMODE — Status Assessment            │
├─────────────────────────────────────────┤
│  Project: <detected project name>       │
│  Branch:  <current branch>              │
│  Phase:   <THINK|BUILD|OPTIMIZE|SHIP>   │
│  Health:  <tests passing/failing/none>  │
├─────────────────────────────────────────┤
│  Recommended next action:               │
│  → /godmode:<skill> — <reason>          │
│                                         │
│  Other options:                         │
│  → /godmode:<alt1> — <reason>           │
│  → /godmode:<alt2> — <reason>           │
└─────────────────────────────────────────┘
```

### Step 4: Multi-Agent Execution (Default)

When the goal involves multiple skills or substantial work, **default to multi-agent execution**:

1. **Decompose** — Use the planner agent's approach: break the goal into independent tasks, map each to a skill
2. **Dependency graph** — Identify which tasks depend on others. Group independent tasks into rounds.
3. **Dispatch in parallel** — For each round, spawn agents simultaneously:
   - Use `Agent` tool with `isolation: "worktree"` so each agent works on its own branch
   - Each agent receives: task description + skill name + files in scope
   - Tell each agent: "Read `skills/<name>/SKILL.md` and follow its workflow for this task: <description>"
4. **Collect & merge** — When all agents in a round complete, review their output and merge branches
5. **Next round** — Dispatch dependent tasks that were waiting. Repeat until done.
6. **Verify** — Run tests/build/lint across the merged result

**Example decomposition:**
```
User: /godmode Build a SaaS billing system with Stripe

GODMODE — Parallel Execution Plan
Round 1 (parallel — 3 agents):
  Agent 1: Design database schema    → skill: schema,  worktree: wt-schema
  Agent 2: Design API contracts       → skill: api,     worktree: wt-api
  Agent 3: Set up Stripe webhooks    → skill: webhook,  worktree: wt-webhook

Round 2 (parallel — 2 agents, depends on Round 1):
  Agent 4: Implement auth + RBAC     → skill: auth,    worktree: wt-auth
  Agent 5: Build payment endpoints   → skill: pay,     worktree: wt-pay

Round 3 (sequential, depends on Round 2):
  Agent 6: Write integration tests   → skill: integration
  Agent 7: Security audit            → skill: secure
```

**When to use single-agent instead:**
- Simple, focused tasks (one skill, one file)
- User explicitly says "don't parallelize" or "just do it"
- The task can't be meaningfully decomposed

### Step 5: Single-Agent Fallback

For simple tasks that don't warrant decomposition:
- If the user confirms the recommendation, immediately invoke that skill
- If the user picks an alternative, invoke that instead
- If the user provides new context, re-evaluate from Step 1

## Autonomous Iteration — The Core Engine

Every Godmode skill that involves iterative work (optimize, fix, debug, build) runs the same autonomous loop engine inherited from autoresearch:

```
LOOP (FOREVER or N iterations):
  1. Review: Read current state + git history + results log
  2. Ideate: Pick next change based on goal and past results
  3. Modify: Make ONE focused change
  4. Commit: git commit BEFORE verification
  5. Verify: Run mechanical metric (tests, benchmark, etc.)
  6. Guard: Run guard command if set (tests must pass)
  7. Decide:
     - IMPROVED + guard passed → KEEP
     - IMPROVED + guard failed → Revert, rework (max 2 attempts)
     - SAME/WORSE → git reset --hard HEAD~1, DISCARD
     - CRASHED → Fix (max 3 attempts), else DISCARD
  8. Log: Append to .godmode/<skill>-results.tsv
  9. Repeat: NEVER STOP. NEVER ASK "should I continue?"
```

**This is not a suggestion. This is the execution protocol.** Skills that skip the loop, skip commits, skip verification, or ask permission to continue are NOT running godmode — they're just generating text.

### Bounded Iterations

Add `Iterations: N` to any skill invocation to run exactly N iterations:
```
/godmode:optimize
Iterations: 20
```

After N iterations, print a final summary with baseline → current, keeps/discards/crashes.

## Key Behaviors

1. **Never guess — investigate.** Always run `git status`, `git log --oneline -10`, and check for test files before recommending.
2. **Bias toward action.** Don't just recommend — ask "Should I start X now?" and proceed on confirmation.
3. **Remember the full loop.** The ideal flow is THINK → BUILD → OPTIMIZE → SHIP. Nudge users toward completing the full cycle.
4. **Respect explicit requests.** If a user says "optimize this," don't redirect to THINK even if no spec exists. Honor their intent, but note what was skipped.
5. **Track phase transitions.** When transitioning between phases, summarize what was accomplished in the previous phase.
6. **Iterate autonomously.** When executing optimize/fix/debug, LOOP. Do not stop after one change. Do not ask for permission. Commit, verify, keep/revert, repeat.

## Example Usage

### Starting a new project
```
User: /godmode I want to build a rate limiter for our API

Godmode: Analyzing project state...
- No existing spec or plan found
- This is a new feature request

┌─────────────────────────────────────────┐
│  GODMODE — Status Assessment            │
├─────────────────────────────────────────┤
│  Project: api-rate-limiter              │
│  Branch:  main                          │
│  Phase:   THINK                         │
│  Health:  No tests yet                  │
├─────────────────────────────────────────┤
│  Recommended next action:               │
│  → /godmode:think — Design the rate     │
│    limiter before building it           │
│                                         │
│  Other options:                         │
│  → /godmode:plan — Skip to planning     │
│    if you already know the design       │
│  → /godmode:build — Jump straight to    │
│    code (not recommended)               │
└─────────────────────────────────────────┘

Shall I start the design session with /godmode:think?
```

### Mid-project check-in
```
User: /godmode

Godmode: Analyzing project state...
- Branch: feat/rate-limiter (12 commits)
- Tests: 8 passing, 3 failing
- Lint: clean
- Coverage: 64%

┌─────────────────────────────────────────┐
│  GODMODE — Status Assessment            │
├─────────────────────────────────────────┤
│  Project: api-rate-limiter              │
│  Branch:  feat/rate-limiter             │
│  Phase:   OPTIMIZE (fix)                │
│  Health:  3 tests failing               │
├─────────────────────────────────────────┤
│  Recommended next action:               │
│  → /godmode:fix — Fix 3 failing tests   │
│    before optimizing further            │
│                                         │
│  Other options:                         │
│  → /godmode:debug — Investigate root    │
│    cause of failures first              │
│  → /godmode:optimize — Ignore failures  │
│    and optimize passing code            │
└─────────────────────────────────────────┘
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Auto-detect phase and recommend |
| `--status` | Show status card without recommending action |
| `--force <phase>` | Skip auto-detection, go directly to a phase |
| `--loop` | Enter continuous mode: execute recommended skill, then re-evaluate, repeat |

## Anti-Patterns

- **Do NOT skip context gathering.** Never recommend a skill without checking git state and test state first.
- **Do NOT cycle between skills endlessly.** If you've recommended the same skill 3 times and the user hasn't made progress, ask what's blocking them.
- **Do NOT override explicit user intent.** If they say "ship it," don't insist on more optimization unless there are critical failures.
- **Do NOT present the status card for subcommands.** If the user says `/godmode:build`, go straight to the build skill — don't show the orchestrator card.
