# Godmode — Complete Design Document

## 1. Vision & Philosophy

**Tagline:** "Turn on Godmode for Claude Code."

**What is Godmode?**
Godmode is a Claude Code skill plugin that gives your AI agent a complete, disciplined development workflow — from idea to optimized, shipped product. It combines:
- **Structured creation** (brainstorm → plan → TDD → build) from superpowers
- **Autonomous optimization** (modify → verify → keep/discard → repeat) from autoresearch
- **A seamless handoff** between building and optimizing

**Core Philosophy — The Godmode Loop:**
```
THINK → BUILD → OPTIMIZE → SHIP → REPEAT
```

Most AI coding tools do one thing well. Godmode does the full cycle:
1. **THINK** — Brainstorm, explore alternatives, design with the user
2. **BUILD** — Plan, test-first, implement with parallel agents and code review
3. **OPTIMIZE** — Autonomous iteration loops with mechanical verification
4. **SHIP** — Structured shipping with pre-flight checks and post-ship monitoring

**Three Principles:**
1. **Discipline before speed** — Design before code, tests before implementation, evidence before claims
2. **Autonomy within constraints** — The agent works independently, but within guardrails (metrics, guards, gates)
3. **Git is memory** — Every experiment is committed, every decision is traceable, every failure is a lesson

---

## 2. Skill Architecture — The Complete Skill Map

Godmode organizes skills into **4 phases** matching the core loop: THINK → BUILD → OPTIMIZE → SHIP.

### Phase 1: THINK (Design & Discovery)

| Skill | Command | Origin | Description |
|-------|---------|--------|-------------|
| **Brainstorm** | `/godmode:think` | Superpowers | Collaborative design sessions — one question at a time, visual companion, 2-3 approach proposals, spec writing |
| **Predict** | `/godmode:predict` | Autoresearch | Multi-persona expert consensus — 5 expert perspectives evaluate a design/decision before committing |
| **Scenario** | `/godmode:scenario` | Autoresearch | Edge case exploration — 12 dimensions (happy paths, errors, abuse, scale, concurrency, etc.) |

### Phase 2: BUILD (Plan & Implement)

| Skill | Command | Origin | Description |
|-------|---------|--------|-------------|
| **Plan** | `/godmode:plan` | Superpowers + Autoresearch | Decompose spec into 2-5 min tasks with exact file paths, code samples, and dependencies |
| **Build** | `/godmode:build` | Superpowers | Execute plan with TDD (RED-GREEN-REFACTOR), parallel agent dispatch, 2-stage code review |
| **Test** | `/godmode:test` | Superpowers | Test-driven development enforcement — write failing test first, then implement |
| **Review** | `/godmode:review` | Superpowers | Dispatch code-reviewer agent, handle feedback with technical rigor |

### Phase 3: OPTIMIZE (Autonomous Iteration)

| Skill | Command | Origin | Description |
|-------|---------|--------|-------------|
| **Optimize** | `/godmode:optimize` | Autoresearch | The core autonomous loop — modify → verify → keep/discard → repeat. Git-as-memory. Mechanical metrics only |
| **Debug** | `/godmode:debug` | Autoresearch | Scientific bug hunting — 7 investigation techniques, autonomous until codebase is clean |
| **Fix** | `/godmode:fix` | Autoresearch | Autonomous error remediation — one fix per iteration until zero errors remain |
| **Secure** | `/godmode:secure` | Autoresearch | STRIDE + OWASP + 4 red-team personas. Structured security audit with code evidence |

### Phase 4: SHIP (Deliver & Monitor)

| Skill | Command | Origin | Description |
|-------|---------|--------|-------------|
| **Ship** | `/godmode:ship` | Autoresearch + Superpowers | 8-phase shipping workflow — inventory, checklist, prepare, dry-run, ship, verify, log |
| **Finish** | `/godmode:finish` | Superpowers | Branch finalization — merge, PR, keep, or discard with full verification |

### Meta Skills (Always Active)

| Skill | Command | Origin | Description |
|-------|---------|--------|-------------|
| **Godmode** | `/godmode` | NEW | The orchestrator — auto-detects what phase you're in and suggests the right skill |
| **Setup** | `/godmode:setup` | Autoresearch | Interactive wizard — configure goal, scope, metric, verify command with dry-run validation |
| **Verify** | `/godmode:verify` | Superpowers | Evidence-before-claims gate — run command → read output → confirm → then claim success |

**Total: 16 skills** (3 THINK + 4 BUILD + 4 OPTIMIZE + 2 SHIP + 3 META)

---

## 3. Plugin File Structure

Godmode ships as a single Claude Code skill plugin directory. Every file has a purpose; no config sprawl.

```
godmode/
├── SKILL.md                          # Orchestrator skill (the /godmode command)
├── settings.json                     # Plugin-level defaults (iterations, model, etc.)
├── hooks/
│   ├── session-start.md              # Hook: runs on session start
│   └── lifecycle.md                  # Hook: phase transition events
├── skills/
│   ├── think/
│   │   ├── SKILL.md                  # /godmode:think (brainstorm)
│   │   ├── references/
│   │   │   ├── brainstorm-protocol.md
│   │   │   └── visual-companion.md
│   │   └── templates/
│   │       └── spec-template.md
│   ├── predict/
│   │   ├── SKILL.md                  # /godmode:predict
│   │   └── references/
│   │       └── persona-definitions.md
│   ├── scenario/
│   │   ├── SKILL.md                  # /godmode:scenario
│   │   └── references/
│   │       └── 12-dimensions.md
│   ├── plan/
│   │   ├── SKILL.md                  # /godmode:plan
│   │   └── references/
│   │       └── task-decomposition.md
│   ├── build/
│   │   ├── SKILL.md                  # /godmode:build
│   │   └── references/
│   │       ├── parallel-dispatch.md
│   │       └── review-protocol.md
│   ├── test/
│   │   ├── SKILL.md                  # /godmode:test
│   │   └── references/
│   │       └── tdd-cycle.md
│   ├── review/
│   │   ├── SKILL.md                  # /godmode:review
│   │   └── references/
│   │       └── severity-levels.md
│   ├── optimize/
│   │   ├── SKILL.md                  # /godmode:optimize
│   │   └── references/
│   │       ├── loop-protocol.md
│   │       ├── metrics-database.md
│   │       └── guard-system.md
│   ├── debug/
│   │   ├── SKILL.md                  # /godmode:debug
│   │   └── references/
│   │       └── investigation-techniques.md
│   ├── fix/
│   │   ├── SKILL.md                  # /godmode:fix
│   │   └── references/
│   │       └── fix-protocol.md
│   ├── secure/
│   │   ├── SKILL.md                  # /godmode:secure
│   │   └── references/
│   │       ├── stride-owasp.md
│   │       └── red-team-personas.md
│   ├── ship/
│   │   ├── SKILL.md                  # /godmode:ship
│   │   └── references/
│   │       └── shipping-workflow.md
│   ├── finish/
│   │   ├── SKILL.md                  # /godmode:finish
│   │   └── references/
│   │       └── completion-options.md
│   ├── setup/
│   │   ├── SKILL.md                  # /godmode:setup
│   │   └── references/
│   │       └── wizard-steps.md
│   └── verify/
│       ├── SKILL.md                  # /godmode:verify
│       └── references/
│           └── evidence-protocol.md
├── shared/
│   ├── git-memory.md                 # Git-as-memory conventions (shared across skills)
│   ├── results-format.md            # TSV logging format
│   ├── handoff-protocol.md          # Phase transition protocol
│   └── crash-recovery.md            # Error handling & recovery
└── .claude-plugin/
    ├── manifest.json                 # Plugin manifest for Claude Code marketplace
    └── marketplace.json              # Marketplace metadata (icon, description, tags)
```

### Key design decisions

| Decision | Rationale |
|----------|-----------|
| One `SKILL.md` per skill | Claude Code discovers skills by finding `SKILL.md` files — one file = one command |
| `references/` directories | Heavy content lives here — keeps SKILL.md focused on workflow, references hold deep knowledge |
| `shared/` directory | Cross-cutting concerns (git conventions, logging, handoff) stay DRY |
| `templates/` where needed | Skills that produce artifacts (specs, plans, reports) include output templates |
| `hooks/` at root level | Session and lifecycle hooks run automatically, not invoked as skills |
| `settings.json` at root | Single config file, overridable per-project via `.godmode/settings.json` in project root |

### File count

- **16 SKILL.md files** (one per skill, plus the root orchestrator)
- **~20 reference files** (deep knowledge, protocols, databases)
- **~4 shared files** (cross-cutting concerns)
- **~50 total files** — small enough to ship, large enough to be comprehensive

---

## 4. Skill File Format

Every skill is a single `SKILL.md` file. Claude Code reads this file when the skill is invoked, so it must be self-contained (or reference files it can load).

### SKILL.md Structure

```markdown
---
name: skill-name
description: One-line description (shown in skill discovery)
triggers:
  - /godmode:skillname
  - natural language trigger phrases
phase: THINK | BUILD | OPTIMIZE | SHIP | META
requires: [list, of, prerequisite, skills]  # optional
flags:
  --flag-name: "description of flag"        # optional
  --iterations: "max iteration count"       # optional
---

# Skill Name

## When to Use
[Trigger conditions — when does this skill activate?]

## Workflow
[Step-by-step instructions for the agent to follow]

### Step 1: [Name]
[Detailed instructions]

### Step 2: [Name]
[Detailed instructions]

## Key Behaviors
[Critical rules the agent must follow]

## References
[Links to files in the references/ directory]
- @references/protocol-name.md

## Example Usage
[Concrete examples of invoking and using the skill]
```

### Frontmatter Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Kebab-case skill identifier |
| `description` | string | Yes | One-line description, max 120 chars |
| `triggers` | string[] | Yes | Slash commands and natural language phrases |
| `phase` | enum | Yes | Which phase this skill belongs to |
| `requires` | string[] | No | Skills that must run before this one |
| `flags` | map | No | CLI flags the skill accepts |

### References Directory Pattern

References are loaded on demand using the `@references/filename.md` directive. The agent reads these files only when the workflow step requires them.

```markdown
## Workflow

### Step 3: Evaluate Security
Load the threat model reference:
@references/stride-owasp.md

Apply each category from the reference to the current codebase.
```

**Why this pattern?**
- Keeps SKILL.md small and scannable (~100-200 lines)
- References can be shared across skills via symlinks or `@shared/filename.md`
- Heavy knowledge (persona definitions, metric databases, protocol details) doesn't bloat the skill file
- References are versioned with the plugin — no external dependencies

### Templates Directory Pattern

Skills that produce artifacts include templates:

```markdown
## Workflow

### Step 5: Write the Spec
Use the spec template:
@templates/spec-template.md

Fill in each section based on the brainstorming session.
```

### Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Skill directory | lowercase, singular | `think/`, `build/`, `secure/` |
| SKILL.md | Always uppercase | `SKILL.md` |
| References | kebab-case | `brainstorm-protocol.md` |
| Templates | kebab-case with `-template` suffix | `spec-template.md` |
| Shared files | kebab-case | `git-memory.md` |

---

## 5. The Orchestrator — `/godmode`

The `/godmode` command is the entry point. It detects where you are in the development cycle and routes you to the right skill.

### Auto-Detection Algorithm

When the user types `/godmode` without a sub-command, the orchestrator inspects project state:

```
1. Check for .godmode/state.json          → Resume in-progress workflow
2. Check git log for recent commits        → Detect current phase
3. Check for failing tests                 → Route to /godmode:fix or /godmode:debug
4. Check for uncommitted changes           → Route to /godmode:review or /godmode:ship
5. Check for TODO/FIXME in codebase        → Route to /godmode:plan
6. Check if spec exists but no code        → Route to /godmode:build
7. Check if code exists but no tests       → Route to /godmode:test
8. Check if code exists but no spec        → Route to /godmode:think
9. Default                                 → Start fresh with /godmode:think
```

### State File (`.godmode/state.json`)

```json
{
  "phase": "BUILD",
  "active_skill": "build",
  "iteration": 3,
  "plan_file": ".godmode/plan.md",
  "current_task": "task-003",
  "metrics": {
    "tests_passing": 42,
    "test_coverage": 0.78,
    "lint_errors": 0
  },
  "history": [
    { "skill": "think", "completed": "2025-01-15T10:00:00Z" },
    { "skill": "plan", "completed": "2025-01-15T10:15:00Z" },
    { "skill": "build", "started": "2025-01-15T10:20:00Z" }
  ]
}
```

### Smart Routing Table

| Detected State | Routed To | Reason |
|---------------|-----------|--------|
| No project context | `/godmode:setup` | Need to configure first |
| Fresh start, no spec | `/godmode:think` | Start with design |
| Spec exists, no plan | `/godmode:plan` | Decompose the spec |
| Plan exists, tasks remain | `/godmode:build` | Execute next task |
| All tasks done, tests pass | `/godmode:optimize` | Improve what exists |
| Optimization plateau | `/godmode:ship` | Time to deliver |
| Failing tests | `/godmode:fix` | Fix before continuing |
| Security review pending | `/godmode:secure` | Audit before shipping |
| Ready to merge | `/godmode:finish` | Finalize the branch |

### User Override

The user can always bypass auto-detection:

```
/godmode:think           # Force brainstorming
/godmode:optimize        # Jump straight to optimization
/godmode --phase BUILD   # Force a specific phase
/godmode --reset         # Clear state, start fresh
```

### Orchestrator Output

When invoked, the orchestrator prints:

```
🔍 Godmode — Analyzing project state...

Phase:     BUILD (task 3 of 7)
Last skill: /godmode:build (15 min ago)
Tests:     42 passing, 0 failing
Coverage:  78%

→ Recommended: /godmode:build (continue task 4: "Add auth middleware")
→ Alternatives: /godmode:test, /godmode:review

Proceed with recommendation? [Y/n/choose]
```

---

## 6. `/godmode:think` — Brainstorm Skill Spec

**Origin:** Superpowers (structured brainstorming protocol)
**Phase:** THINK
**Purpose:** Collaborative design sessions that produce a written spec through disciplined, one-question-at-a-time exploration.

### Trigger Conditions

- User says "let's brainstorm", "I have an idea", "help me design", "let's think about"
- Orchestrator detects no spec exists for current work
- Explicitly invoked with `/godmode:think`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--visual` | false | Launch visual companion in browser |
| `--approaches` | 3 | Number of approaches to propose (2-5) |
| `--spec` | true | Write a spec at the end |
| `--review` | true | Run review loop on the spec |

### Workflow

**Step 1: Understand the Problem**
- Ask ONE question at a time (never batch questions)
- Listen to the answer completely before asking the next
- Build understanding incrementally
- Stop asking when you have enough to propose approaches (usually 3-7 questions)

**Step 2: Propose Approaches**
- Present 2-3 distinct approaches (not variations of the same idea)
- Each approach gets: name, one-paragraph description, pros, cons, complexity estimate
- Format as a comparison table
- Ask the user to pick one (or combine elements)

**Step 3: Deep Dive on Chosen Approach**
- Explore the chosen approach in detail
- Ask clarifying questions specific to this approach
- Identify technical decisions that need to be made
- Map out the components/modules involved

**Step 4: Write the Spec**
- Produce a structured spec document using `@templates/spec-template.md`
- Spec includes: problem statement, chosen approach, components, API surface, data model, edge cases, open questions
- Save to `.godmode/specs/SPEC-NAME.md`

**Step 5: Review Loop**
- Read the spec back to the user section by section
- Ask "Does this capture what you want?" for each section
- Iterate until the user approves
- Final spec is committed: `git commit -m "spec: SPEC-NAME"`

### Key Behaviors

1. **One question at a time** — Never ask "What's the goal and who are the users and what's the tech stack?" Ask one, wait, ask the next.
2. **No premature solutions** — Spend time understanding before proposing
3. **Concrete over abstract** — "Show me what the API call looks like" not "describe the interface"
4. **User drives decisions** — Present options, never decide for the user
5. **Spec is the output** — The brainstorm isn't done until there's a written, reviewed spec

### Example Usage

```
User: /godmode:think
Agent: What are you building? (one question to start)

User: A rate limiter for our API
Agent: What's the current setup — is this a new API or adding rate limiting to an existing one?

User: Existing Express.js API, about 40 endpoints
Agent: Are there different rate limit needs for different endpoints, or one global limit?

[... 3-5 more questions ...]

Agent: Here are 3 approaches:

| Approach | Description | Pros | Cons | Complexity |
|----------|-------------|------|------|------------|
| Token Bucket | Classic token bucket with Redis backend | Battle-tested, flexible | Requires Redis | Medium |
| Sliding Window | In-memory sliding window per IP | No external deps | Doesn't scale past one process | Low |
| API Gateway | Move rate limiting to nginx/Kong | Offloads from app | Infrastructure change | High |

Which approach works best for your situation?
```

### Visual Companion Integration

When `--visual` is active:
- Launch browser-based brainstorming canvas
- Display questions, answers, and approaches in real-time
- Allow user to rearrange, annotate, and connect ideas
- Export canvas state as part of the spec
- See Section 27 for full Visual Companion spec

---

## 7. `/godmode:predict` — Multi-Persona Prediction Skill Spec

**Origin:** Autoresearch (multi-persona expert panel)
**Phase:** THINK
**Purpose:** Evaluate a design decision or approach through 5 expert personas, reaching consensus before committing to implementation.

### Trigger Conditions

- User says "will this work?", "what could go wrong?", "evaluate this approach"
- Before a major architectural decision
- After `/godmode:think` produces a spec that needs validation
- Explicitly invoked with `/godmode:predict`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--personas` | 5 | Number of expert personas (3-7) |
| `--domain` | auto | Domain for persona selection (web, ml, systems, mobile, etc.) |
| `--decision` | — | Specific decision to evaluate (overrides auto-detect) |
| `--format` | table | Output format: `table`, `prose`, `json` |

### The 5 Expert Personas

| Persona | Perspective | Evaluates |
|---------|-------------|-----------|
| **The Architect** | System design, scalability, maintainability | Does the architecture hold up at 10x scale? |
| **The Skeptic** | Risk, failure modes, hidden complexity | What will break? What's being overlooked? |
| **The User** | UX, developer experience, usability | Is this actually pleasant to use? |
| **The Operator** | Deployment, monitoring, debugging in prod | Can I run this at 3am when it breaks? |
| **The Newcomer** | Onboarding, documentation, learning curve | Can someone new understand this in 30 min? |

Personas rotate based on `--domain`:
- **ML domain:** Adds "The Data Scientist" (data quality, model drift, reproducibility)
- **Security domain:** Adds "The Attacker" (exploit paths, abuse scenarios)
- **Frontend domain:** Adds "The Accessibility Expert" (a11y, screen readers, keyboard nav)

### Workflow

**Step 1: Frame the Decision**
- Identify the specific decision being evaluated
- Summarize the context (what exists, what's proposed, what alternatives were considered)
- State the decision clearly: "We're deciding whether to X or Y"

**Step 2: Persona Evaluation**
- Each persona evaluates independently
- Each persona produces:
  - **Verdict:** APPROVE / CONCERN / REJECT
  - **Confidence:** 1-5
  - **Key insight:** One sentence
  - **Evidence:** Specific technical reasoning

**Step 3: Consensus Matrix**

```
┌─────────────┬─────────┬────────────┬──────────────────────────────┐
│ Persona     │ Verdict │ Confidence │ Key Insight                  │
├─────────────┼─────────┼────────────┼──────────────────────────────┤
│ Architect   │ APPROVE │ 4/5        │ Clean separation of concerns │
│ Skeptic     │ CONCERN │ 3/5        │ Redis SPOF needs failover    │
│ User        │ APPROVE │ 5/5        │ Simple API, good defaults    │
│ Operator    │ CONCERN │ 4/5        │ Need metrics dashboard       │
│ Newcomer    │ APPROVE │ 4/5        │ Good docs, clear examples    │
├─────────────┼─────────┼────────────┼──────────────────────────────┤
│ CONSENSUS   │ PROCEED │ 4.0 avg    │ Proceed with 2 mitigations   │
└─────────────┴─────────┴────────────┴──────────────────────────────┘
```

**Step 4: Synthesis**
- Aggregate verdicts into a final recommendation
- Consensus rules:
  - All APPROVE → **PROCEED**
  - Any CONCERN → **PROCEED WITH MITIGATIONS** (list them)
  - Any REJECT → **RECONSIDER** (list blocking issues)
  - Majority REJECT → **STOP** (fundamental problems)

**Step 5: Action Items**
- List specific mitigations to address concerns
- Each mitigation becomes a task in the plan (if `/godmode:plan` runs next)
- Commit the prediction report: `git commit -m "predict: DECISION-NAME consensus"`

### Key Behaviors

1. **Personas argue independently** — Don't let one persona's view contaminate another
2. **Evidence-based** — Each verdict must cite specific technical reasoning, not vibes
3. **Concerns are gifts** — A CONCERN verdict is more valuable than a rubber-stamp APPROVE
4. **Actionable output** — Every concern must have a corresponding mitigation
5. **Not a gate** — The user decides whether to proceed; the prediction informs, not blocks

### Example Usage

```
User: /godmode:predict --decision "Use Redis for rate limiting vs in-memory"

Agent:
┌─────────────┬─────────┬────────────┬─────────────────────────────────┐
│ Persona     │ Verdict │ Confidence │ Key Insight                     │
├─────────────┼─────────┼────────────┼─────────────────────────────────┤
│ Architect   │ APPROVE │ 5/5        │ Redis enables horizontal scale  │
│ Skeptic     │ CONCERN │ 4/5        │ Redis connection pool can leak  │
│ User        │ APPROVE │ 4/5        │ Transparent to API consumers    │
│ Operator    │ CONCERN │ 3/5        │ Another service to monitor      │
│ Newcomer    │ APPROVE │ 3/5        │ Redis is well-documented        │
├─────────────┼─────────┼────────────┼─────────────────────────────────┤
│ CONSENSUS   │ PROCEED │ 3.8 avg    │ Proceed with 2 mitigations      │
└─────────────┴─────────┴────────────┴─────────────────────────────────┘

Mitigations:
1. Add connection pool health check and auto-reconnect
2. Add Redis metrics to monitoring dashboard
```

---

## 8. `/godmode:scenario` — Edge Case Explorer Skill Spec

**Origin:** Autoresearch (scenario exploration)
**Phase:** THINK
**Purpose:** Systematically explore edge cases across 12 dimensions before writing code, so edge cases are designed for — not discovered in production.

### Trigger Conditions

- After a spec is written and before planning
- User says "what could go wrong?", "edge cases", "what am I missing?"
- Explicitly invoked with `/godmode:scenario`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--dimensions` | all | Which dimensions to explore (comma-separated, or "all") |
| `--depth` | medium | Exploration depth: `shallow` (1 per dimension), `medium` (3), `deep` (5+) |
| `--target` | auto | Target component/feature to explore |
| `--output` | table | Output format: `table`, `checklist`, `test-cases` |

### The 12 Exploration Dimensions

| # | Dimension | Question | Examples |
|---|-----------|----------|----------|
| 1 | **Happy Path** | Does the normal case actually work? | Standard input, expected user, typical load |
| 2 | **Empty/Null** | What happens with nothing? | Empty string, null, undefined, zero, empty array |
| 3 | **Boundary** | What happens at the edges? | Max int, min int, exactly at limit, one over limit |
| 4 | **Invalid Input** | What happens with garbage? | Wrong type, malformed JSON, SQL injection, XSS |
| 5 | **Concurrency** | What happens when multiple things happen at once? | Race conditions, deadlocks, double-submit |
| 6 | **Scale** | What happens at 10x/100x/1000x? | 1M rows, 10K concurrent users, 1GB payload |
| 7 | **Failure** | What happens when dependencies fail? | DB down, API timeout, disk full, OOM |
| 8 | **State** | What happens with unexpected state? | Stale cache, partial migration, corrupted data |
| 9 | **Time** | What happens with time? | Timezone changes, DST, leap seconds, clock skew |
| 10 | **Permission** | What happens with wrong access? | Unauthorized, expired token, role escalation |
| 11 | **Abuse** | How could this be deliberately misused? | DDoS, scraping, data exfiltration, account takeover |
| 12 | **Recovery** | Can the system recover? | Restart mid-operation, restore from backup, rollback |

### Workflow

**Step 1: Identify Target**
- Read the spec or codebase to identify the component under exploration
- List the key operations/endpoints/functions to explore

**Step 2: Dimension Sweep**
- For each dimension, generate concrete scenarios
- Each scenario includes:
  - **Scenario:** One-sentence description
  - **Input:** What triggers this scenario
  - **Expected:** What should happen
  - **Risk:** LOW / MEDIUM / HIGH / CRITICAL
  - **Handled?:** YES / NO / PARTIAL

**Step 3: Produce Scenario Matrix**

```
Dimension: CONCURRENCY
┌───┬────────────────────────────┬──────────┬──────────┐
│ # │ Scenario                   │ Risk     │ Handled? │
├───┼────────────────────────────┼──────────┼──────────┤
│ 1 │ Two users claim same item  │ HIGH     │ NO       │
│ 2 │ Rate limit counter race    │ MEDIUM   │ PARTIAL  │
│ 3 │ Cache invalidation during  │ LOW      │ YES      │
│   │ concurrent writes          │          │          │
└───┴────────────────────────────┴──────────┴──────────┘
```

**Step 4: Risk Summary**
- Count unhandled scenarios by risk level
- Produce a risk heatmap across dimensions
- Highlight the top 5 most dangerous unhandled scenarios

**Step 5: Generate Artifacts**
- If `--output test-cases`: Generate test stubs for each unhandled scenario
- If `--output checklist`: Generate a TODO checklist for the plan
- Commit scenario report: `git commit -m "scenario: TARGET-NAME edge case exploration"`

### Key Behaviors

1. **Concrete, not abstract** — "User submits form twice in 200ms" not "concurrency issues"
2. **Every dimension gets attention** — Don't skip dimensions that seem irrelevant; that's where surprises hide
3. **Risk-ranked** — Not all edge cases are equal; focus attention on HIGH/CRITICAL
4. **Feeds into planning** — Unhandled scenarios become tasks in `/godmode:plan`
5. **Test-case ready** — Each scenario should be specific enough to write a test for

### Example Usage

```
User: /godmode:scenario --target "rate limiter" --depth deep --output test-cases

Agent: Exploring 12 dimensions for "rate limiter"...

TOP 5 UNHANDLED RISKS:
1. [CRITICAL] Clock skew between servers causes inconsistent rate limits
2. [HIGH] Redis connection dies mid-increment, counter stuck
3. [HIGH] Distributed race: two servers both allow request #100 of 100
4. [MEDIUM] User rotates API key to reset rate limit
5. [MEDIUM] Burst of 10K requests in 1ms overwhelms token bucket refill

Generated 23 test stubs → saved to tests/rate-limiter.scenario.test.ts
```

---

## 9. `/godmode:plan` — Planning Skill Spec

**Origin:** Superpowers + Autoresearch (task decomposition)
**Phase:** BUILD
**Purpose:** Decompose a spec into small (2-5 minute), actionable tasks with exact file paths, code samples, dependencies, and test criteria.

### Trigger Conditions

- A spec exists but no plan has been created
- User says "plan this", "break this down", "create tasks"
- Orchestrator routes here after THINK phase completes
- Explicitly invoked with `/godmode:plan`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--spec` | auto | Path to spec file (auto-detects from `.godmode/specs/`) |
| `--max-tasks` | 20 | Maximum number of tasks to generate |
| `--task-size` | 5min | Target task duration: `2min`, `5min`, `10min` |
| `--review` | true | Present plan to user for review before saving |
| `--parallel` | true | Identify which tasks can run in parallel |

### Workflow

**Step 1: Read the Spec**
- Load the spec from `.godmode/specs/` or the path provided
- Also load scenario results if they exist (unhandled edge cases become tasks)
- Also load prediction mitigations if they exist (concerns become tasks)

**Step 2: Identify Components**
- Map the spec to concrete code components:
  - Files to create
  - Files to modify
  - Dependencies to install
  - Configuration to add

**Step 3: Decompose into Tasks**
- Each task is 2-5 minutes of agent work
- Each task has:

```markdown
### Task 003: Add rate limit middleware

**Files:** `src/middleware/rate-limiter.ts` (CREATE), `src/app.ts` (MODIFY)
**Dependencies:** `ioredis` (INSTALL)
**Depends on:** Task 001 (Redis connection), Task 002 (config schema)
**Parallel group:** B (can run alongside Task 004)
**Test:** `tests/rate-limiter.test.ts` — "should return 429 after 100 requests"
**Acceptance:** Rate limiter middleware exists, passes 3 test cases
**Estimated time:** 4 min

**Implementation notes:**
- Use token bucket algorithm from spec section 3.2
- Default: 100 requests per 60-second window
- Key format: `ratelimit:{ip}:{endpoint}`
```

**Step 4: Build Dependency Graph**
- Map task dependencies into execution order
- Identify parallel groups (tasks with no interdependencies)
- Produce a visual execution plan:

```
Phase A (sequential):
  Task 001: Redis connection module
  Task 002: Config schema

Phase B (parallel):          Phase C (parallel):
  Task 003: Rate limiter       Task 004: Logging
  Task 005: Error handler      Task 006: Health check

Phase D (sequential):
  Task 007: Integration tests
  Task 008: Documentation
```

**Step 5: Plan Review**
- Present the complete plan to the user
- Show: task count, estimated total time, dependency graph, parallel opportunities
- User can: approve, reorder, split tasks, merge tasks, remove tasks, add tasks
- Iterate until approved

**Step 6: Save Plan**
- Save to `.godmode/plan.md`
- Update `.godmode/state.json` with plan reference
- Commit: `git commit -m "plan: FEATURE-NAME — N tasks, estimated Xmin"`

### Task Schema

| Field | Required | Description |
|-------|----------|-------------|
| `id` | Yes | Task identifier (e.g., `task-003`) |
| `title` | Yes | Short description |
| `files` | Yes | Files to create/modify with action (CREATE/MODIFY/DELETE) |
| `dependencies` | No | Package dependencies to install |
| `depends_on` | No | Task IDs that must complete first |
| `parallel_group` | No | Letter indicating parallel execution group |
| `test` | Yes | Test file and description of what to test |
| `acceptance` | Yes | Clear criteria for task completion |
| `estimated_time` | Yes | Estimated agent time in minutes |
| `notes` | No | Implementation hints, code samples, gotchas |

### Key Behaviors

1. **2-5 minute tasks** — If a task takes longer, it should be split
2. **Every task has a test** — No task is complete without a passing test
3. **File paths are exact** — Not "add a middleware" but "create `src/middleware/rate-limiter.ts`"
4. **Dependencies are explicit** — No hidden coupling between tasks
5. **User approves the plan** — The plan is a contract; don't start building without approval

---

## 10. `/godmode:build` — Execute Plan Skill Spec

**Origin:** Superpowers (parallel agent dispatch, TDD enforcement, code review)
**Phase:** BUILD
**Purpose:** Execute the plan task-by-task with TDD enforcement, parallel agent dispatch for independent tasks, and 2-stage code review.

### Trigger Conditions

- A plan exists with remaining tasks
- User says "build it", "start building", "execute the plan"
- Orchestrator routes here when plan exists and tasks remain
- Explicitly invoked with `/godmode:build`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--task` | next | Specific task ID to execute, or "next" for auto-selection |
| `--parallel` | true | Dispatch parallel tasks to separate agents |
| `--tdd` | true | Enforce TDD (write test first, then implement) |
| `--review` | true | Run 2-stage code review after each task |
| `--continue` | false | Auto-continue to next task after completion |
| `--model` | auto | Model for parallel agents (auto-selects based on task complexity) |

### Workflow

**Step 1: Select Task**
- Read the plan from `.godmode/plan.md`
- If `--task next`: select the next task whose dependencies are all complete
- If parallel group has multiple ready tasks and `--parallel` is on: dispatch all of them

**Step 2: Create Branch**
- Create a git branch for the task: `godmode/task-003-rate-limiter`
- This isolates each task's changes for clean review

**Step 3: TDD Cycle (per task)**

```
RED:    Write the test first → run it → confirm it FAILS
GREEN:  Write minimum code to pass the test → run it → confirm it PASSES
REFACTOR: Clean up the code → run tests → confirm still PASSES
```

- The agent MUST write the test file before writing any implementation
- The agent MUST run the test and see it fail before implementing
- The agent MUST run the test and see it pass after implementing
- If TDD is skipped (`--tdd false`), the agent still writes tests but doesn't enforce the RED step

**Step 4: 2-Stage Code Review**

*Stage 1: Self-Review*
- The building agent reviews its own changes
- Checks: code quality, test coverage, edge cases, naming, documentation
- Fixes any issues found

*Stage 2: Reviewer Agent*
- Dispatch a separate agent (or the same agent in reviewer mode) to review
- Reviewer gets: the task description, the diff, the test results
- Reviewer produces feedback with severity levels:
  - **BLOCK:** Must fix before merging (bugs, security issues)
  - **WARN:** Should fix, but not blocking (style, minor improvements)
  - **NOTE:** Optional improvement (nice-to-have)
- BLOCK issues loop back to the building agent for fixes
- After all BLOCKs resolved: merge task branch into working branch

**Step 5: Update State**
- Mark task as complete in `.godmode/state.json`
- Update progress: "Task 3/7 complete"
- Commit: `git commit -m "build: task-003 rate limiter middleware (RED-GREEN-REFACTOR)"`
- If `--continue`: proceed to Step 1 for next task

### Parallel Agent Dispatch

When multiple tasks in the same parallel group are ready:

```
Main Agent (coordinator):
  ├── Agent A → Task 003 (rate limiter)      [worktree: .godmode/worktrees/task-003]
  ├── Agent B → Task 004 (logging)           [worktree: .godmode/worktrees/task-004]
  └── Agent C → Task 005 (error handler)     [worktree: .godmode/worktrees/task-005]

  Wait for all → Merge all → Resolve conflicts → Run full test suite
```

- Each parallel agent works in its own git worktree
- Coordinator waits for all agents to complete
- Coordinator merges results and resolves any conflicts
- Full test suite runs after merge to catch integration issues

### Model Selection Strategy

| Task Complexity | Recommended Model | Reasoning |
|----------------|-------------------|-----------|
| Simple (create test, add config) | Haiku/Flash | Fast, cheap, sufficient |
| Medium (implement feature, add endpoint) | Sonnet | Good balance |
| Complex (architecture change, algorithm) | Opus | Needs deep reasoning |
| Review tasks | Sonnet | Reviewing needs less creativity, more rigor |

### Key Behaviors

1. **Tests come first** — No implementation without a failing test
2. **One task at a time** — Focus on one task, complete it, review it, then move on
3. **Branch per task** — Isolation enables clean review and easy rollback
4. **Review is not optional** — Every task gets reviewed, even if the user trusts the agent
5. **Progress is visible** — Status updates after each task completion

### Example Usage

```
User: /godmode:build --continue

Agent: Starting Task 003: Add rate limit middleware
Branch: godmode/task-003-rate-limiter

[RED] Writing test: tests/rate-limiter.test.ts
  ✗ "should return 429 after 100 requests" — FAIL (expected, no impl yet)

[GREEN] Writing implementation: src/middleware/rate-limiter.ts
  ✓ "should return 429 after 100 requests" — PASS
  ✓ "should reset after window expires" — PASS
  ✓ "should track per-IP limits" — PASS

[REFACTOR] Cleaning up...
  ✓ All 3 tests still passing

[REVIEW Stage 1] Self-review: 0 issues found
[REVIEW Stage 2] Reviewer: 1 WARN (add JSDoc to exported function), 0 BLOCK
  → Applied WARN fix

✅ Task 003 complete (3/7). Proceeding to Task 004...
```

---

## 11. `/godmode:test` — TDD Skill Spec

**Origin:** Superpowers (test-driven development enforcement)
**Phase:** BUILD
**Purpose:** Enforce the RED-GREEN-REFACTOR cycle as a standalone skill, usable outside of `/godmode:build` for adding tests to existing code or writing test suites from scratch.

### Trigger Conditions

- User says "write tests", "add test coverage", "TDD"
- Code exists without tests
- User wants to add tests for a specific function/module
- Explicitly invoked with `/godmode:test`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--target` | auto | File or function to test (auto-detects untested code) |
| `--framework` | auto | Test framework: `jest`, `pytest`, `go test`, `vitest`, etc. |
| `--coverage` | false | Run coverage report after tests pass |
| `--style` | unit | Test style: `unit`, `integration`, `e2e`, `snapshot` |
| `--cases` | auto | Number of test cases to write (auto based on complexity) |

### Workflow

**Step 1: Analyze Target**
- Read the target file/function
- Identify: inputs, outputs, side effects, error paths, edge cases
- List all behaviors that need testing

**Step 2: RED — Write Failing Tests**
- Write test file with descriptive test names
- Test naming convention: `should [expected behavior] when [condition]`
- Include tests for:
  - Happy path (normal operation)
  - Edge cases (empty, null, boundary)
  - Error cases (invalid input, failures)
  - Side effects (database writes, API calls)
- Run the tests — they MUST fail
- If any test passes, it's testing nothing useful (remove or rewrite)

**Step 3: GREEN — Implement (if target doesn't exist yet)**
- If testing new code: write minimum implementation to pass
- If testing existing code: skip this step (tests should pass against existing code)
- Run tests — they MUST all pass
- If tests fail against existing code: either the code has a bug (good, you found it) or the test is wrong (fix the test)

**Step 4: REFACTOR**
- Clean up both tests and implementation
- Remove duplication in tests (but keep tests readable — some duplication is OK)
- Extract test helpers/fixtures if patterns repeat
- Run tests — they MUST still pass

**Step 5: Coverage Report (if `--coverage`)**
- Run coverage tool for the test framework
- Report uncovered lines/branches
- Suggest additional tests for uncovered paths

### Test File Template

```typescript
// tests/rate-limiter.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { RateLimiter } from '../src/middleware/rate-limiter';

describe('RateLimiter', () => {
  let limiter: RateLimiter;

  beforeEach(() => {
    limiter = new RateLimiter({ limit: 100, window: 60 });
  });

  describe('allow()', () => {
    it('should allow requests under the limit', () => { /* ... */ });
    it('should reject requests over the limit', () => { /* ... */ });
    it('should reset after the window expires', () => { /* ... */ });
    it('should track limits per IP address', () => { /* ... */ });
  });

  describe('edge cases', () => {
    it('should handle empty IP address', () => { /* ... */ });
    it('should handle concurrent requests', () => { /* ... */ });
    it('should handle Redis connection failure gracefully', () => { /* ... */ });
  });
});
```

### Key Behaviors

1. **Test names are documentation** — Someone should understand the feature just from reading test names
2. **RED is mandatory** — If the test doesn't fail first, it proves nothing
3. **One assertion per test** (preferred) — Multiple assertions make failures ambiguous
4. **No mocking unless necessary** — Prefer real dependencies; mock only external services
5. **Tests must be deterministic** — No random data, no time-dependent assertions, no network calls

### Example Usage

```
User: /godmode:test --target src/middleware/rate-limiter.ts --coverage

Agent: Analyzing rate-limiter.ts...
  Found: 3 exported functions, 2 error paths, 4 edge cases

[RED] Writing 9 test cases in tests/rate-limiter.test.ts
  ✗ 9/9 tests FAIL (no implementation stub)

[GREEN] Implementation exists — running against existing code
  ✓ 7/9 tests PASS
  ✗ 2/9 tests FAIL:
    - "should handle Redis connection failure gracefully" — throws unhandled error
    - "should handle concurrent requests" — race condition detected

  ⚠ Found 2 bugs! These tests reveal real issues in the implementation.

[COVERAGE] 84% line coverage, 71% branch coverage
  Uncovered: error handling in reconnect(), edge case in slidingWindow()
```

---

## 12. `/godmode:review` — Code Review Skill Spec

**Origin:** Superpowers (dispatch reviewer agent, handle feedback)
**Phase:** BUILD
**Purpose:** Dispatch a dedicated code reviewer agent that reviews changes with technical rigor, categorized severity, and actionable feedback.

### Trigger Conditions

- After a task is built (automatically triggered by `/godmode:build`)
- User says "review this", "review my changes", "code review"
- Before merging any branch
- Explicitly invoked with `/godmode:review`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--scope` | staged | What to review: `staged`, `branch`, `file:path`, `commit:hash` |
| `--focus` | all | Review focus: `all`, `security`, `performance`, `style`, `correctness` |
| `--severity` | all | Minimum severity to report: `block`, `warn`, `note` |
| `--auto-fix` | false | Automatically apply WARN and NOTE fixes |
| `--model` | sonnet | Model for reviewer agent |

### Severity Levels

| Level | Symbol | Meaning | Action Required |
|-------|--------|---------|-----------------|
| **BLOCK** | :stop: | Must fix — bugs, security issues, data loss risks | Cannot merge until resolved |
| **WARN** | :warning: | Should fix — code quality, maintainability, minor issues | Fix recommended, not blocking |
| **NOTE** | :memo: | Optional — style preferences, nice-to-haves, suggestions | Author decides |

### Workflow

**Step 1: Gather Context**
- Read the diff (staged changes, branch diff, or specific files)
- Read relevant test files
- Read the task description (if invoked from `/godmode:build`)
- Understand what the change is trying to accomplish

**Step 2: Review Checklist**

The reviewer evaluates against this checklist:

| Category | Checks |
|----------|--------|
| **Correctness** | Does the code do what it claims? Are edge cases handled? |
| **Tests** | Are tests present? Do they test the right things? Coverage gaps? |
| **Security** | Input validation? Auth checks? Injection vulnerabilities? Secrets exposed? |
| **Performance** | N+1 queries? Unbounded loops? Missing indexes? Memory leaks? |
| **Error Handling** | Are errors caught? Meaningful error messages? Recovery paths? |
| **Naming** | Clear variable/function names? Consistent conventions? |
| **Documentation** | Comments for complex logic? Updated README? API docs? |
| **Style** | Consistent formatting? Follows project conventions? |

**Step 3: Produce Review**

```markdown
## Code Review: Task 003 — Rate Limiter Middleware

### Summary
Clean implementation of token bucket rate limiting. 1 blocking issue,
2 warnings, 1 note.

### Findings

#### 🛑 BLOCK: Unhandled Redis disconnection
**File:** `src/middleware/rate-limiter.ts:45`
**Issue:** If Redis disconnects, `increment()` throws an unhandled exception
that crashes the Express process.
**Fix:** Wrap in try/catch, fall back to allowing the request (fail-open)
or returning 503 (fail-closed).

#### ⚠️ WARN: Missing rate limit headers
**File:** `src/middleware/rate-limiter.ts:62`
**Issue:** Response doesn't include `X-RateLimit-Remaining` or
`X-RateLimit-Reset` headers.
**Fix:** Add standard rate limit headers per RFC 6585.

#### ⚠️ WARN: Test missing for window expiry
**File:** `tests/rate-limiter.test.ts`
**Issue:** No test for the case where the time window expires and the
counter resets.
**Fix:** Add a test that advances time past the window.

#### 📝 NOTE: Consider named export
**File:** `src/middleware/rate-limiter.ts:1`
**Suggestion:** Use named export instead of default export for
better tree-shaking and IDE support.
```

**Step 4: Handle Feedback Loop**
- BLOCK issues: Agent fixes them immediately, then re-reviews
- WARN issues: Agent fixes if `--auto-fix` is on, otherwise lists them
- NOTE issues: Listed for the user to decide
- Loop continues until zero BLOCKs remain

**Step 5: Approve or Request Changes**
- Zero BLOCKs → **APPROVED** — ready to merge
- BLOCKs remain after 3 fix attempts → **ESCALATE** — ask the user
- Commit review results: `git commit -m "review: task-003 approved (1 block fixed, 2 warns)"`

### Key Behaviors

1. **The reviewer is adversarial** — Its job is to find problems, not approve
2. **Every finding has a fix** — Don't just complain; show how to fix it
3. **Severity is strict** — BLOCK means BLOCK; don't inflate or deflate
4. **Context matters** — A quick prototype doesn't need the same rigor as production code
5. **Review the tests too** — Bad tests are worse than no tests (false confidence)

---

## 13. `/godmode:optimize` — Autonomous Optimization Loop Skill Spec

**Origin:** Autoresearch (the core 8-phase autonomous loop)
**Phase:** OPTIMIZE
**Purpose:** The heart of Godmode — an autonomous iteration loop that modifies code, measures results mechanically, and keeps only improvements. Git is memory. Metrics are truth.

### Trigger Conditions

- Code is built and tests pass, but performance/quality can be improved
- User says "optimize this", "make it faster", "improve this", "iterate on this"
- Orchestrator routes here after BUILD phase completes
- Explicitly invoked with `/godmode:optimize`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--metric` | — | The mechanical metric to optimize (required or prompted) |
| `--verify` | — | Command to measure the metric (required or prompted) |
| `--iterations` | 25 | Maximum iterations before stopping |
| `--target` | — | Target metric value (stop when reached) |
| `--guard` | — | Guard metric that must not regress (e.g., "tests passing") |
| `--scope` | auto | Files/directories in scope for modification |
| `--strategy` | auto | Optimization strategy: `hill-climb`, `explore`, `surgical` |

### The 8-Phase Loop

Each iteration follows this exact sequence:

```
┌─→ Phase 1: READ HISTORY
│   Phase 2: ANALYZE
│   Phase 3: PLAN CHANGE
│   Phase 4: IMPLEMENT
│   Phase 5: VERIFY (mechanical)
│   Phase 6: GUARD CHECK
│   Phase 7: KEEP or REVERT
│   Phase 8: LOG RESULTS
└────────────────────────┘ (repeat until target met or max iterations)
```

**Phase 1: READ HISTORY (Git-as-Memory)**
- Read the last N commit messages from optimization branch
- Read `.godmode/results.tsv` for metric history
- Understand: what was tried, what worked, what failed, what's the trend
- Never repeat a failed approach unless conditions changed

**Phase 2: ANALYZE**
- Read the current codebase (scoped files)
- Identify the biggest opportunity for improvement
- Consider: algorithmic changes, data structure changes, caching, batching, parallelism, reducing I/O

**Phase 3: PLAN CHANGE**
- Describe the change in one sentence
- Predict: expected metric improvement, risk of regression, confidence level
- The plan must be a single, atomic change (not a bundle of changes)

**Phase 4: IMPLEMENT**
- Make the code change
- Keep it small and focused (one idea per iteration)
- Don't touch files outside the scope

**Phase 5: VERIFY (Mechanical Measurement)**
- Run the verify command
- Parse the metric value from the output
- Compare to baseline and previous iteration
- The metric MUST be mechanically measurable — no vibes, no "I think it's better"

**Phase 6: GUARD CHECK**
- Run guard commands (e.g., test suite)
- If any guard fails: the change broke something
- Guard failure = mandatory revert, no exceptions

**Phase 7: KEEP or REVERT**

| Condition | Action |
|-----------|--------|
| Metric improved AND guards pass | **KEEP** — commit the change |
| Metric unchanged AND guards pass | **REVERT** — not worth the complexity |
| Metric regressed AND guards pass | **REVERT** — made it worse |
| Guards failed (any metric value) | **REVERT** — broke something |

- KEEP: `git commit -m "optimize: iteration N — [description] (+X% improvement)"`
- REVERT: `git checkout -- .` then `git commit -m "optimize: iteration N — [description] (reverted, [reason])"`

**Phase 8: LOG RESULTS**
- Append to `.godmode/results.tsv`:
  ```
  iteration	timestamp	description	metric_before	metric_after	delta	kept	guard_status
  7	2025-01-15T10:30:00Z	add response caching	340ms	285ms	-16.2%	true	pass
  ```
- Print progress summary:
  ```
  Iteration 7/25 | Metric: 285ms (target: 200ms) | Kept: 5 | Reverted: 2 | Trend: ↓ improving
  ```

### Stopping Conditions

| Condition | Behavior |
|-----------|----------|
| Target metric reached | Stop, report success |
| Max iterations reached | Stop, report best result |
| 5 consecutive reverts | Stop, report plateau (likely local optimum) |
| Guard fails 3 times in a row | Stop, report instability |
| User interrupts | Stop, preserve current best |

### Key Behaviors

1. **Mechanical metrics only** — If you can't measure it with a command, it's not a valid metric
2. **One change per iteration** — Atomic changes make it clear what helped and what didn't
3. **Git is memory** — Every iteration is committed (kept or reverted), creating a learning record
4. **Guards are sacred** — Never keep a change that breaks a guard, no matter how much the metric improved
5. **Revert is not failure** — A reverted iteration is a learned lesson; it prevents repeating mistakes
6. **No human in the loop** — The loop runs autonomously; the user watches and can interrupt

### Example Usage

```
User: /godmode:optimize --metric "p95 response time" \
  --verify "wrk -t4 -c100 -d10s http://localhost:3000/api | grep 'Latency.*99%'" \
  --target "200ms" \
  --guard "npm test" \
  --iterations 25

Agent: Starting optimization loop...
  Baseline: p95 = 340ms | Target: 200ms | Max iterations: 25

  Iteration 1: Add Redis caching for user lookups
    340ms → 285ms (-16.2%) ✓ KEPT

  Iteration 2: Batch database queries in list endpoint
    285ms → 241ms (-15.4%) ✓ KEPT

  Iteration 3: Add connection pooling
    241ms → 238ms (-1.2%) ✗ REVERTED (not worth added complexity)

  Iteration 4: Switch JSON serializer to fast-json-stringify
    241ms → 198ms (-17.8%) ✓ KEPT

  🎯 Target reached! p95 = 198ms (target: 200ms)
  Iterations: 4/25 | Kept: 3 | Reverted: 1
  Total improvement: 340ms → 198ms (-41.8%)
```

---

## 14. `/godmode:debug` — Bug Hunter Skill Spec

**Origin:** Autoresearch (scientific debugging method)
**Phase:** OPTIMIZE
**Purpose:** Systematically hunt bugs using the scientific method — hypothesize, test, narrow, repeat — with 7 investigation techniques.

### Trigger Conditions

- Tests are failing
- User reports a bug: "there's a bug", "this doesn't work", "something's wrong"
- Orchestrator detects failing tests
- Explicitly invoked with `/godmode:debug`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--bug` | — | Description of the bug (or auto-detect from failing tests) |
| `--technique` | auto | Investigation technique (1-7, or "auto" to try in order) |
| `--max-iterations` | 10 | Max investigation cycles |
| `--fix` | false | Auto-fix the bug after finding it (chains to `/godmode:fix`) |
| `--verbose` | false | Show detailed investigation reasoning |

### The 7 Investigation Techniques

| # | Technique | When to Use | Method |
|---|-----------|-------------|--------|
| 1 | **Stack Trace Analysis** | Error with stack trace | Read the trace bottom-up, identify the faulting line, trace data flow to it |
| 2 | **Binary Search (git bisect)** | "It used to work" | Use git bisect to find the exact commit that introduced the bug |
| 3 | **Minimal Reproduction** | Complex bug, unclear trigger | Reduce the reproduction case to the absolute minimum input |
| 4 | **State Inspection** | Wrong output, no error | Add logging/assertions at key points to inspect intermediate state |
| 5 | **Dependency Audit** | "It works locally" | Check dependency versions, environment variables, config differences |
| 6 | **Concurrency Analysis** | Intermittent failures | Look for race conditions, shared mutable state, missing locks |
| 7 | **Boundary Analysis** | Edge-case failures | Test at boundaries: 0, 1, max, empty, null, negative |

### Workflow

**Step 1: Reproduce**
- Run the failing test or reproduce the reported bug
- If the bug can't be reproduced: gather more information, check environment
- Record the exact error message, stack trace, and input that triggers it
- STOP if reproduction fails after 3 attempts — ask the user for more info

**Step 2: Hypothesize**
- Based on the error and codebase knowledge, form 1-3 hypotheses
- Each hypothesis has:
  - **Statement:** "The bug is caused by X"
  - **Evidence for:** Why this seems likely
  - **Evidence against:** Why this might be wrong
  - **Test:** How to confirm or deny this hypothesis

**Step 3: Investigate**
- Apply the appropriate technique (auto-selected or specified)
- For each hypothesis, run the test to confirm or deny
- Narrow down: eliminate hypotheses, form new ones based on findings
- Track the investigation in a structured log:

```
Investigation Log:
  H1: "Redis timeout causes null return" — DENIED (Redis responds in 2ms)
  H2: "Race condition in counter increment" — CONFIRMED
    Evidence: Adding 100ms delay between requests makes bug disappear
    Root cause: increment() reads then writes without atomic lock
```

**Step 4: Identify Root Cause**
- State the root cause clearly and specifically
- Show the exact line(s) of code responsible
- Explain the mechanism: what happens step-by-step that leads to the bug
- Differentiate root cause from symptoms

**Step 5: Recommend Fix**
- Propose 1-2 fix strategies
- For each: description, code change, risk assessment, test to verify
- If `--fix` is on: chain to `/godmode:fix` with the identified root cause
- Commit investigation: `git commit -m "debug: identified root cause of [BUG]"`

### Key Behaviors

1. **Reproduce first** — Never hypothesize about a bug you can't reproduce
2. **Scientific method** — Hypothesize, test, narrow. Don't guess and patch.
3. **One variable at a time** — Change one thing per investigation step
4. **Root cause, not symptoms** — Fixing the symptom creates a new bug later
5. **Investigation log** — Every step is documented for future reference
6. **Know when to stop** — If 10 iterations haven't found it, escalate to the user

### Example Usage

```
User: /godmode:debug --bug "Rate limiter allows 101 requests when limit is 100"

Agent: Reproducing...
  ✓ Reproduced: 101st request returns 200 instead of 429

Hypotheses:
  H1: Off-by-one in comparison (>= vs >) — Confidence: HIGH
  H2: Race condition in counter increment — Confidence: MEDIUM
  H3: Counter reset timing issue — Confidence: LOW

Investigating H1 (Stack Trace Analysis):
  src/middleware/rate-limiter.ts:34: `if (count > limit)`
  Should be: `if (count >= limit)`

  ✓ H1 CONFIRMED — off-by-one error

Root cause: Line 34 uses `>` instead of `>=`, allowing exactly limit+1 requests.

Fix: Change `count > limit` to `count >= limit`
Test: Verify 100th request succeeds and 101st request returns 429.

Chain to /godmode:fix? [Y/n]
```

---

## 15. `/godmode:fix` — Error Fixer Skill Spec

**Origin:** Autoresearch (autonomous error remediation)
**Phase:** OPTIMIZE
**Purpose:** Autonomous error fixing — one fix per iteration, auto-revert on failure, repeat until zero errors remain.

### Trigger Conditions

- Tests are failing and root cause is known (from `/godmode:debug` or obvious)
- Lint errors, type errors, build errors
- User says "fix this", "fix the errors", "make it pass"
- Explicitly invoked with `/godmode:fix`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--errors` | auto | Error source: `test`, `lint`, `typecheck`, `build`, `runtime`, `all` |
| `--verify` | auto | Verification command (auto-detects from project) |
| `--max-iterations` | 15 | Maximum fix attempts |
| `--one-at-a-time` | true | Fix one error per iteration (safer, more traceable) |
| `--auto-revert` | true | Automatically revert if fix introduces new errors |

### Workflow

**Step 1: Enumerate Errors**
- Run the verification command (test suite, linter, type checker, build)
- Parse the output to extract individual errors
- Create an error inventory:

```
Error Inventory (5 errors):
  E1: [TEST]  rate-limiter.test.ts:34 — "should reject at limit" — AssertionError
  E2: [TEST]  rate-limiter.test.ts:56 — "should reset window" — Timeout
  E3: [LINT]  rate-limiter.ts:12 — no-unused-vars: 'oldLimit'
  E4: [TYPE]  rate-limiter.ts:45 — Type 'string' not assignable to 'number'
  E5: [LINT]  rate-limiter.ts:78 — prefer-const: 'config' is never reassigned
```

**Step 2: Prioritize**
- Fix order: BUILD errors → TYPE errors → TEST errors → LINT errors
- Within a category: fix root causes first (a type error might cause a test failure)
- Identify cascading errors (fixing E4 might auto-fix E1)

**Step 3: Fix One Error**
- Select the highest-priority error
- Make the minimal code change to fix it
- One fix, one error, one iteration — no bundling

**Step 4: Verify**
- Run the full verification command
- Count remaining errors
- Check: did the fix introduce any NEW errors?

**Step 5: Keep or Revert**

| Result | Action |
|--------|--------|
| Error fixed, no new errors | **KEEP** — commit: `fix: resolve E1 — off-by-one in limit check` |
| Error fixed, but new error introduced | **REVERT** — the fix is wrong, try different approach |
| Error not fixed | **REVERT** — try different approach |
| Error fixed, but different error now fails | **KEEP** — net progress (fewer total errors) |

**Step 6: Repeat**
- Loop back to Step 1 with updated error inventory
- Continue until: zero errors, max iterations reached, or stuck (same error fails 3 fixes)

### Progress Tracking

```
Fix Progress:
  Iteration 1: Fix E4 (type error) → 5 errors → 4 errors ✓
  Iteration 2: Fix E1 (test, caused by E4) → 4 errors → 3 errors ✓ (cascade)
  Iteration 3: Fix E2 (test timeout) → 3 errors → 3 errors ✗ (reverted)
  Iteration 4: Fix E2 (different approach) → 3 errors → 2 errors ✓
  Iteration 5: Fix E3 (lint) → 2 errors → 1 error ✓
  Iteration 6: Fix E5 (lint) → 1 error → 0 errors ✓

  ✅ All errors resolved in 6 iterations (1 revert)
```

### Key Behaviors

1. **One fix per iteration** — Atomic fixes are traceable and revertable
2. **Auto-revert is default** — If a fix makes things worse, undo it immediately
3. **Root causes first** — Don't fix symptoms; cascade fixes save iterations
4. **Minimal changes** — The smallest change that fixes the error, nothing more
5. **Know when to stop** — If the same error resists 3 fix attempts, escalate to user

### Example Usage

```
User: /godmode:fix --errors all

Agent: Scanning for errors...
  Found: 2 test failures, 1 type error, 2 lint warnings (5 total)

  Iteration 1/15: Fixing TYPE error in rate-limiter.ts:45
    Change: parseInt(config.limit) → config.limit (already a number from schema)
    Verify: 5 → 3 errors (type error fixed, 1 test cascade-fixed) ✓ KEPT

  Iteration 2/15: Fixing TEST "should reset window" timeout
    Change: Increase test timeout 1000ms → 5000ms? No — fix the actual issue.
    Change: Use fake timers in test instead of real setTimeout
    Verify: 3 → 2 errors ✓ KEPT

  Iteration 3/15: Fixing LINT no-unused-vars
    Change: Remove unused variable 'oldLimit'
    Verify: 2 → 1 error ✓ KEPT

  Iteration 4/15: Fixing LINT prefer-const
    Change: let config → const config
    Verify: 1 → 0 errors ✓ KEPT

  ✅ All errors resolved in 4 iterations (0 reverts)
```

---

## 16. `/godmode:secure` — Security Audit Skill Spec

**Origin:** Autoresearch (STRIDE + OWASP + red-team personas)
**Phase:** OPTIMIZE
**Purpose:** Comprehensive security audit combining STRIDE threat modeling, OWASP Top 10 checks, and 4 red-team personas, producing a structured report with code evidence.

### Trigger Conditions

- Before shipping any user-facing feature
- User says "security review", "audit this", "is this secure?"
- Orchestrator recommends before `/godmode:ship`
- Explicitly invoked with `/godmode:secure`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--scope` | auto | Files/directories to audit (auto-detects from recent changes) |
| `--framework` | all | Which framework: `stride`, `owasp`, `redteam`, `all` |
| `--severity` | all | Minimum severity to report: `critical`, `high`, `medium`, `low` |
| `--fix` | false | Auto-fix findings (chains to `/godmode:fix`) |
| `--report` | markdown | Report format: `markdown`, `json`, `sarif` |

### STRIDE Threat Model

| Category | Question | Example Findings |
|----------|----------|-----------------|
| **S**poofing | Can someone pretend to be someone else? | Missing auth, weak session tokens |
| **T**ampering | Can someone modify data they shouldn't? | No input validation, unsigned payloads |
| **R**epudiation | Can someone deny their actions? | Missing audit logs, no timestamps |
| **I**nformation Disclosure | Can someone see data they shouldn't? | Verbose errors, exposed stack traces |
| **D**enial of Service | Can someone break availability? | No rate limiting, unbounded queries |
| **E**levation of Privilege | Can someone gain unauthorized access? | Missing role checks, IDOR vulnerabilities |

### OWASP Top 10 Checks

| # | Category | Automated Check |
|---|----------|----------------|
| A01 | Broken Access Control | Grep for missing auth middleware, IDOR patterns |
| A02 | Cryptographic Failures | Check for hardcoded secrets, weak hashing, HTTP links |
| A03 | Injection | SQL string concatenation, unsanitized user input, eval() |
| A04 | Insecure Design | Missing rate limits, no account lockout, no CSRF |
| A05 | Security Misconfiguration | Default credentials, verbose errors, open CORS |
| A06 | Vulnerable Components | Check dependency versions against known CVEs |
| A07 | Auth Failures | Weak password rules, missing MFA, session fixation |
| A08 | Data Integrity Failures | Unsigned updates, unverified deserialization |
| A09 | Logging Failures | Missing security event logging, log injection |
| A10 | SSRF | Unvalidated URL parameters, internal network access |

### 4 Red-Team Personas

| Persona | Motivation | Attack Style |
|---------|------------|-------------|
| **Script Kiddie** | Chaos, bragging | Automated tools, known exploits, brute force |
| **Insider Threat** | Revenge, profit | Valid credentials, knows the system, subtle |
| **APT (Nation-State)** | Espionage, disruption | Patient, sophisticated, multi-stage |
| **Automated Bot** | Scraping, DDoS, spam | High volume, no creativity, persistent |

Each persona "attacks" the system and reports what they could achieve.

### Workflow

**Step 1: Scope the Audit**
- Identify files in scope (modified files, or full codebase)
- Map the attack surface: endpoints, inputs, auth boundaries, data flows

**Step 2: STRIDE Analysis**
- For each STRIDE category, analyze the scoped code
- Produce findings with code evidence (file path, line number, code snippet)

**Step 3: OWASP Scan**
- Run each OWASP check against the codebase
- Cross-reference with STRIDE findings (avoid duplicates)

**Step 4: Red-Team Simulation**
- Each persona attempts to compromise the system
- Report: attack path, success/failure, impact, difficulty

**Step 5: Produce Report**

```markdown
## Security Audit Report

### Summary
- **Critical:** 1 | **High:** 2 | **Medium:** 3 | **Low:** 5
- **Attack surface:** 12 endpoints, 4 auth boundaries
- **Most vulnerable:** `/api/admin/users` (broken access control)

### Critical Findings

#### SEC-001: SQL Injection in user search [CRITICAL]
**Category:** STRIDE-Tampering, OWASP-A03
**File:** `src/routes/users.ts:45`
**Code:** `db.query(\`SELECT * FROM users WHERE name = '\${req.query.name}'\`)`
**Impact:** Full database read/write access
**Fix:** Use parameterized queries: `db.query('SELECT * FROM users WHERE name = $1', [req.query.name])`
**Red-team:** Script Kiddie could exploit this in <5 minutes with sqlmap

### High Findings
[...]

### Red-Team Results
| Persona | Goal | Result | Path |
|---------|------|--------|------|
| Script Kiddie | Data exfiltration | SUCCESS | SQLi → dump users table |
| Insider | Privilege escalation | SUCCESS | IDOR → access admin panel |
| APT | Persistent access | BLOCKED | No RCE vector found |
| Bot | DDoS | PARTIAL | Rate limiting exists but bypassable via IP rotation |
```

**Step 6: Action Items**
- Each finding becomes a fix task, prioritized by severity
- If `--fix` is on: chain to `/godmode:fix` for each finding
- Commit report: `git commit -m "secure: audit report — 1 critical, 2 high, 3 medium"`

### Key Behaviors

1. **Code evidence required** — Every finding must cite the exact file and line
2. **Fix included** — Every finding must include a concrete fix, not just "fix this"
3. **No false positives** — Only report issues with clear evidence; uncertain findings get a confidence level
4. **Severity is calibrated** — CRITICAL = actively exploitable, HIGH = exploitable with effort, MEDIUM = defense-in-depth, LOW = best practice
5. **Red team adds realism** — Persona attacks show impact in human terms, not just technical terms

---

## 17. `/godmode:ship` — Shipping Skill Spec

**Origin:** Autoresearch + Superpowers (structured shipping workflow)
**Phase:** SHIP
**Purpose:** 8-phase shipping workflow that handles 9 different shipment types, from npm packages to Docker images to GitHub releases.

### Trigger Conditions

- All tasks complete, tests pass, review approved
- User says "ship it", "deploy", "release", "publish"
- Orchestrator routes here after OPTIMIZE phase completes
- Explicitly invoked with `/godmode:ship`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--type` | auto | Shipment type (see 9 types below) |
| `--dry-run` | false | Run entire workflow without actually shipping |
| `--version` | auto | Version number (auto-bumps based on changes) |
| `--skip-security` | false | Skip security audit (not recommended) |
| `--changelog` | true | Auto-generate changelog from commits |

### 9 Shipment Types

| Type | Command | What it Does |
|------|---------|-------------|
| `npm` | `npm publish` | Publish to npm registry |
| `pypi` | `python -m twine upload` | Publish to PyPI |
| `docker` | `docker build && docker push` | Build and push Docker image |
| `github-release` | `gh release create` | Create GitHub release with assets |
| `github-pages` | `gh-pages -d dist` | Deploy to GitHub Pages |
| `vercel` | `vercel --prod` | Deploy to Vercel |
| `cloudflare` | `wrangler deploy` | Deploy to Cloudflare Workers |
| `binary` | `goreleaser` / custom | Build and distribute binaries |
| `custom` | user-defined | Run a custom deploy script |

### The 8-Phase Shipping Workflow

**Phase 1: Inventory**
- List all changes since last ship (commits, files changed, new dependencies)
- Categorize: features, fixes, breaking changes, chores
- Determine version bump: MAJOR (breaking), MINOR (feature), PATCH (fix)

**Phase 2: Pre-Flight Checklist**

```
Pre-Flight Checklist:
  ✓ All tests pass
  ✓ No lint errors
  ✓ No type errors
  ✓ Security audit passed (or --skip-security)
  ✓ No uncommitted changes
  ✓ On correct branch (main/release)
  ✓ Dependencies up to date
  ✓ Version bumped in package.json / pyproject.toml / etc.
  ✗ CHANGELOG.md updated → Auto-generating...
```

All items must pass. Failures block shipping with clear instructions to fix.

**Phase 3: Changelog**
- Auto-generate from git history since last tag
- Group by: Features, Fixes, Breaking Changes, Other
- Use conventional commit messages for categorization
- Present to user for review/edit

**Phase 4: Version Bump**
- Bump version in all relevant files (package.json, Cargo.toml, setup.py, etc.)
- Create version commit: `git commit -m "release: vX.Y.Z"`
- Create git tag: `git tag vX.Y.Z`

**Phase 5: Build**
- Run the project's build command
- Verify build artifacts exist and are correct size
- Run smoke tests against built artifacts (not source)

**Phase 6: Dry Run**
- Execute the shipment command with dry-run flag
- Show what WOULD be published/deployed
- User confirms before proceeding
- If `--dry-run` flag: stop here

**Phase 7: Ship**
- Execute the actual shipment command
- Capture output for logging
- Verify the shipment succeeded (check registry, check deployment URL)

**Phase 8: Post-Ship**
- Push git tags: `git push --tags`
- Create GitHub release (if applicable)
- Post-ship verification: hit the deployed endpoint, check the published package
- Update `.godmode/state.json` with ship record
- Log results: `git commit -m "ship: vX.Y.Z shipped to [target]"`

### Post-Ship Verification

| Shipment Type | Verification |
|--------------|-------------|
| npm | `npm view package@version` returns correct metadata |
| Docker | `docker pull image:tag` succeeds |
| GitHub Release | `gh release view vX.Y.Z` shows correct assets |
| Vercel/CF | HTTP GET to deployment URL returns 200 |
| Custom | Run user-defined verification command |

### Key Behaviors

1. **Pre-flight blocks shipping** — Every check must pass; no shortcuts
2. **Dry run first** — Always show what will happen before doing it
3. **User confirms** — The agent never ships without explicit user approval
4. **Post-ship verification** — Don't assume it worked; verify mechanically
5. **Rollback plan** — If post-ship verification fails, provide rollback instructions

### Example Usage

```
User: /godmode:ship --type npm

Agent: Phase 1: Inventory
  12 commits since v1.2.0
  Features: 2 | Fixes: 3 | Breaking: 0 → Version: 1.3.0

Phase 2: Pre-Flight
  ✓ 47 tests pass | ✓ 0 lint errors | ✓ Security audit clean

Phase 3: Changelog (auto-generated)
  ## 1.3.0
  ### Features
  - Add rate limiting middleware (#45)
  - Add Redis connection pooling (#47)
  ### Fixes
  - Fix off-by-one in rate limit counter (#48)
  - Fix Redis reconnection handling (#49)
  - Fix type error in config parser (#50)

Phase 4: Version → 1.3.0

Phase 5: Build → dist/ (42KB, 3 files)

Phase 6: Dry Run → npm publish --dry-run ✓

Ship v1.3.0 to npm? [Y/n]

Phase 7: Ship → npm publish ✓
Phase 8: Verify → npm view rate-limiter@1.3.0 ✓

✅ v1.3.0 shipped to npm successfully
```

---

## 18. `/godmode:finish` — Branch Finalization Skill Spec

**Origin:** Superpowers (branch finalization with verification)
**Phase:** SHIP
**Purpose:** Finalize a feature branch with 4 completion options, each gated by a verification step.

### Trigger Conditions

- Feature is complete and shipped (or ready to ship)
- User says "finish this", "wrap up", "merge", "close this branch"
- Explicitly invoked with `/godmode:finish`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--action` | prompt | Completion action: `merge`, `pr`, `keep`, `discard` |
| `--base` | main | Base branch for merge/PR |
| `--verify` | true | Run verification gate before finalizing |
| `--cleanup` | true | Delete branch after merge, clean up worktrees |

### 4 Completion Options

| Option | Command | What Happens |
|--------|---------|-------------|
| **Merge** | `--action merge` | Squash-merge into base branch, delete feature branch |
| **PR** | `--action pr` | Create pull request with auto-generated description |
| **Keep** | `--action keep` | Leave the branch as-is (for later) |
| **Discard** | `--action discard` | Delete the branch and all its changes |

### Workflow

**Step 1: Verification Gate**
- Run all tests
- Check for uncommitted changes
- Check for unresolved merge conflicts
- Check for TODO/FIXME items added during this branch
- Verify the feature works (run user-defined verification command if set)

```
Verification Gate:
  ✓ All tests pass (47/47)
  ✓ No uncommitted changes
  ✓ No merge conflicts
  ⚠ 2 TODO items found (non-blocking)
  ✓ Feature verification: /api/rate-limit returns 429 correctly
```

**Step 2: Generate Summary**
- Summarize what was done on this branch:
  - Commits: count and key changes
  - Files: created, modified, deleted
  - Tests: added, coverage change
  - Time: first commit to now

```
Branch Summary: godmode/rate-limiter
  Commits: 12 (7 tasks, 3 optimizations, 2 fixes)
  Files: 8 created, 3 modified, 0 deleted
  Tests: 15 added (coverage: 62% → 84%)
  Duration: 2h 15m
```

**Step 3: Execute Action**

*Merge:*
```bash
git checkout main
git merge --squash godmode/rate-limiter
git commit -m "feat: add rate limiting middleware (#45)\n\n[auto-generated summary]"
git branch -d godmode/rate-limiter
```

*PR:*
```bash
git push -u origin godmode/rate-limiter
gh pr create --title "feat: add rate limiting middleware" \
  --body "[auto-generated description with summary, test results, and review notes]"
```

*Keep:*
- No action, just report the current state

*Discard:*
- Confirm with user (destructive action)
- `git checkout main && git branch -D godmode/rate-limiter`

**Step 4: Cleanup**
- Delete worktrees if any exist
- Remove `.godmode/state.json` (reset state)
- Archive results to `.godmode/archive/`
- Final commit on main: `git commit -m "finish: rate-limiter branch finalized (merged)"`

### Key Behaviors

1. **Verification is mandatory** — Cannot finalize without passing the gate (unless `--verify false`)
2. **Discard requires confirmation** — Destructive action, must confirm twice
3. **Summary is always generated** — Even for discard, so there's a record of what was tried
4. **Cleanup is thorough** — No dangling branches, worktrees, or state files
5. **PR descriptions are rich** — Include summary, test results, review notes, and screenshots if applicable

---

## 19. `/godmode:setup` — Configuration Wizard Skill Spec

**Origin:** Autoresearch (interactive configuration with dry-run validation)
**Phase:** META
**Purpose:** 7-step interactive wizard that configures Godmode for the current project, with dry-run validation at each step.

### Trigger Conditions

- First time using Godmode in a project (no `.godmode/` directory)
- User says "set up godmode", "configure", "initialize"
- Orchestrator detects no project configuration
- Explicitly invoked with `/godmode:setup`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--quick` | false | Skip optional steps, use smart defaults |
| `--reset` | false | Re-run setup even if config exists |
| `--template` | — | Use a preset template: `node`, `python`, `go`, `rust`, `fullstack` |

### The 7 Setup Steps

**Step 1: Project Detection**
- Auto-detect project type from files:
  - `package.json` → Node.js
  - `pyproject.toml` / `setup.py` → Python
  - `go.mod` → Go
  - `Cargo.toml` → Rust
  - `Makefile` → generic
- Auto-detect test framework, linter, build tool
- Present findings: "I detected a Node.js project using Vitest and ESLint. Correct?"

**Step 2: Goal Definition**
- Ask: "What are you building or improving?"
- The answer becomes the `goal` in state — used by the orchestrator for context
- Example: "Add rate limiting to the Express API"

**Step 3: Scope Definition**
- Ask: "Which files/directories are in scope?"
- Auto-suggest based on project structure
- User can narrow or expand
- Saves to `scope` in settings — limits what the agent modifies

**Step 4: Primary Metric**
- Ask: "What does success look like, mechanically?"
- Must be a command that outputs a measurable number
- Examples:
  - `npm test 2>&1 | grep 'passing' | awk '{print $1}'` → test count
  - `wrk -t4 -c100 -d10s http://localhost:3000 | grep Latency` → response time
  - `wc -l src/**/*.ts | tail -1 | awk '{print $1}'` → lines of code
- **Dry-run validation:** Run the command, confirm it produces a number

**Step 5: Verification Command**
- Ask: "What command verifies everything still works?"
- Usually the test suite: `npm test`, `pytest`, `go test ./...`
- **Dry-run validation:** Run the command, confirm it exits 0

**Step 6: Guard Metrics (optional)**
- Ask: "Any metrics that must NOT regress?"
- Examples: test count, coverage percentage, bundle size, response time
- Each guard = a command + a threshold + a direction (must not go below/above)
- **Dry-run validation:** Run each guard command, confirm baseline values

**Step 7: Review & Save**
- Display the complete configuration
- User confirms or edits
- Save to `.godmode/settings.json`
- Create `.godmode/state.json` with initial state
- Commit: `git commit -m "setup: godmode configured for [GOAL]"`

### Generated Configuration

```json
// .godmode/settings.json
{
  "project": {
    "type": "node",
    "test_command": "npm test",
    "lint_command": "npx eslint src/",
    "build_command": "npm run build"
  },
  "goal": "Add rate limiting to the Express API",
  "scope": ["src/middleware/", "src/routes/", "tests/"],
  "metric": {
    "name": "p95 response time",
    "command": "wrk -t4 -c100 -d10s http://localhost:3000/api | grep '99%'",
    "baseline": "340ms",
    "target": "200ms",
    "direction": "lower_is_better"
  },
  "verify": "npm test",
  "guards": [
    {
      "name": "tests passing",
      "command": "npm test 2>&1 | grep -c 'passing'",
      "baseline": 42,
      "direction": "must_not_decrease"
    }
  ],
  "iterations": {
    "optimize_max": 25,
    "fix_max": 15,
    "debug_max": 10
  }
}
```

### Key Behaviors

1. **Dry-run everything** — Never save a config with commands that don't work
2. **Smart defaults** — Detect as much as possible, ask only what's needed
3. **Quick mode** — For experienced users who don't want 7 questions
4. **Templates** — Pre-built configs for common project types
5. **Re-runnable** — `--reset` lets you reconfigure without losing history

---

## 20. `/godmode:verify` — Evidence Gate Skill Spec

**Origin:** Superpowers (evidence-before-claims protocol)
**Phase:** META
**Purpose:** 5-step verification protocol that prevents the agent from claiming success without mechanical evidence. Run command, read output, confirm result, then claim.

### Trigger Conditions

- Called automatically by other skills before claiming success
- User says "verify this", "prove it works", "show me evidence"
- Before any state transition (THINK→BUILD, BUILD→OPTIMIZE, etc.)
- Explicitly invoked with `/godmode:verify`

### Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--command` | auto | Command to run for verification |
| `--expect` | pass | Expected result: `pass`, `fail`, `contains:STRING`, `value:RANGE` |
| `--retries` | 1 | Number of retry attempts |
| `--timeout` | 60s | Max time for command execution |

### The 5-Step Verification Protocol

**Step 1: Declare What You're Verifying**
- State the claim: "I'm verifying that all 47 tests pass"
- State the command: `npm test`
- State the expected result: "Exit code 0, output contains '47 passing'"

**Step 2: Run the Command**
- Execute the verification command
- Capture: stdout, stderr, exit code, execution time
- Do NOT summarize the output — capture it raw

**Step 3: Read the Output**
- Parse the full output
- Extract the relevant metric/result
- Compare against expected result

**Step 4: Confirm or Deny**

| Result | Action |
|--------|--------|
| Expected result matches | **VERIFIED** — proceed with claim |
| Expected result doesn't match | **FAILED** — do NOT claim success |
| Command times out | **INCONCLUSIVE** — retry or escalate |
| Command crashes | **ERROR** — investigate |

**Step 5: Report**
```
VERIFICATION RESULT: ✓ VERIFIED
  Claim: "All 47 tests pass"
  Command: npm test
  Exit code: 0
  Key output: "47 passing (3.2s)"
  Duration: 3.2s
```

Or on failure:
```
VERIFICATION RESULT: ✗ FAILED
  Claim: "All 47 tests pass"
  Command: npm test
  Exit code: 1
  Key output: "45 passing, 2 failing"
  Failed tests:
    - "should handle Redis timeout" — AssertionError
    - "should reset window" — Timeout
  Action: DO NOT claim success. Fix failing tests first.
```

### Integration with Other Skills

The verify protocol is embedded in other skills:

| Skill | Verification Point |
|-------|-------------------|
| `/godmode:build` | After each TDD cycle — verify tests pass |
| `/godmode:optimize` | Phase 5 — verify metric after each change |
| `/godmode:fix` | After each fix — verify error count decreased |
| `/godmode:ship` | Pre-flight and post-ship — verify everything works |
| `/godmode:finish` | Verification gate — verify before finalizing |

### Anti-Pattern: Claiming Without Evidence

The verify skill exists to prevent this anti-pattern:

```
BAD:  "I've fixed the bug and all tests should pass now."
      (No evidence. "Should pass" is not "passes.")

GOOD: "I've fixed the bug. Running verification..."
      VERIFICATION: ✓ npm test → 47 passing (0 failing)
      "All 47 tests pass. The bug is fixed."
```

### Key Behaviors

1. **Never claim without running** — "It should work" is not acceptable
2. **Raw output, not summaries** — Show the actual output, not your interpretation
3. **Mechanical only** — Verification must be a command, not a judgment call
4. **Retry before failing** — Flaky tests get one retry before reporting failure
5. **Failure is information** — A failed verification is more valuable than a false positive

---

## 21. The Handoff Protocol

**Purpose:** Define how skills transition between phases (THINK → BUILD → OPTIMIZE → SHIP) so the workflow feels seamless, not disjointed.

### The Problem

Without a handoff protocol, phase transitions are jarring:
- The brainstorm produces a spec, but the planner doesn't know it exists
- The builder finishes, but the optimizer doesn't know what to measure
- The optimizer hits a plateau, but the shipper doesn't know what's ready

### Handoff Contract

Every skill that completes a phase must produce a **handoff artifact** — a structured file that the next phase can consume.

| Transition | Handoff Artifact | Location | Key Contents |
|-----------|-----------------|----------|-------------|
| THINK → BUILD | Spec document | `.godmode/specs/*.md` | Problem, approach, components, API surface |
| THINK → BUILD | Prediction report | `.godmode/predictions/*.md` | Consensus, mitigations |
| THINK → BUILD | Scenario report | `.godmode/scenarios/*.md` | Edge cases, unhandled risks |
| BUILD → OPTIMIZE | Completed plan | `.godmode/plan.md` (all tasks ✓) | What was built, test results |
| BUILD → OPTIMIZE | Metric definition | `.godmode/settings.json` | What to measure, baseline, target |
| OPTIMIZE → SHIP | Optimization log | `.godmode/results.tsv` | All iterations, final metric |
| OPTIMIZE → SHIP | Security report | `.godmode/security/*.md` | Findings, fixes applied |
| SHIP → (next cycle) | Ship record | `.godmode/archive/*.json` | What was shipped, when, where |

### Handoff Sequence

```
THINK Phase Completion:
  1. Spec written and reviewed              → .godmode/specs/rate-limiter.md
  2. Predictions evaluated (optional)       → .godmode/predictions/rate-limiter.md
  3. Scenarios explored (optional)          → .godmode/scenarios/rate-limiter.md
  4. State updated: phase = "BUILD"
  5. Handoff message: "THINK complete. Ready for /godmode:plan"

BUILD Phase Completion:
  1. All plan tasks complete
  2. All tests pass
  3. Code reviewed
  4. State updated: phase = "OPTIMIZE"
  5. Handoff message: "BUILD complete. 7/7 tasks done, 47 tests passing. Ready for /godmode:optimize"

OPTIMIZE Phase Completion:
  1. Target metric reached (or plateau)
  2. Security audit passed
  3. State updated: phase = "SHIP"
  4. Handoff message: "OPTIMIZE complete. p95: 198ms (target: 200ms). Ready for /godmode:ship"

SHIP Phase Completion:
  1. Shipped and verified
  2. Branch finalized
  3. State archived
  4. Handoff message: "SHIP complete. v1.3.0 published to npm. Cycle complete."
```

### Automatic vs Manual Transitions

| Mode | Behavior |
|------|----------|
| **Auto** (`/godmode --auto`) | Skills chain automatically; orchestrator routes to next skill after each handoff |
| **Guided** (default) | Orchestrator suggests next skill; user confirms |
| **Manual** | User invokes each skill explicitly; no automatic transitions |

### Handoff Verification

Before transitioning, the orchestrator verifies:

1. **Artifact exists** — The handoff artifact was produced
2. **Artifact is valid** — It contains the required fields (not empty/placeholder)
3. **State is clean** — No uncommitted changes, no failing tests
4. **User approves** — In guided/manual mode, user confirms the transition

If any check fails, the transition is blocked with a clear message:

```
⚠ Cannot transition THINK → BUILD:
  ✓ Spec exists: .godmode/specs/rate-limiter.md
  ✗ Spec review not completed (Step 5 of /godmode:think)
  → Run /godmode:think to complete the review loop
```

### Key Behaviors

1. **Artifacts are the contract** — Skills communicate through files, not implicit state
2. **Verification at every gate** — Don't assume the previous phase completed properly
3. **Nothing is lost** — Every artifact is committed to git, creating a complete record
4. **Graceful degradation** — If an optional artifact is missing (e.g., no prediction), the transition still works

---

## 22. Git-as-Memory System

**Purpose:** Use git commits as the agent's persistent memory — every experiment, every decision, every revert is traceable and learnable.

### Why Git is Memory

AI agents have no persistent memory between sessions. But git does. Every commit message is a note-to-future-self. Every diff shows what was tried. Every revert shows what failed. The git log becomes the agent's learning journal.

### Commit Message Conventions

All Godmode commits follow a strict prefix convention:

| Prefix | Phase | Meaning | Example |
|--------|-------|---------|---------|
| `setup:` | META | Configuration change | `setup: godmode configured for rate-limiter` |
| `spec:` | THINK | Spec created/updated | `spec: rate-limiter initial spec` |
| `predict:` | THINK | Prediction report | `predict: rate-limiter approach consensus` |
| `scenario:` | THINK | Scenario exploration | `scenario: rate-limiter edge case report` |
| `plan:` | BUILD | Plan created/updated | `plan: rate-limiter — 7 tasks, estimated 25min` |
| `build:` | BUILD | Task implementation | `build: task-003 rate limiter middleware (RED-GREEN-REFACTOR)` |
| `review:` | BUILD | Code review result | `review: task-003 approved (1 block fixed)` |
| `test:` | BUILD | Test addition | `test: add rate limiter edge case tests` |
| `optimize:` | OPTIMIZE | Optimization iteration | `optimize: iteration 4 — fast-json-stringify (+17.8%)` |
| `debug:` | OPTIMIZE | Debug investigation | `debug: identified root cause of off-by-one` |
| `fix:` | OPTIMIZE | Error fix | `fix: resolve off-by-one in limit check` |
| `secure:` | OPTIMIZE | Security audit | `secure: audit report — 1 critical, 2 high` |
| `ship:` | SHIP | Shipment | `ship: v1.3.0 shipped to npm` |
| `finish:` | SHIP | Branch finalization | `finish: rate-limiter merged to main` |
| `revert:` | any | Reverted change | `revert: optimize iteration 3 — connection pooling (no improvement)` |

### Reading History (Pattern Learning)

Before each iteration, the agent reads git history to learn from past attempts:

```bash
# Read last 20 optimization commits to learn what worked
git log --oneline --grep="optimize:" -20

# Read reverts to avoid repeating mistakes
git log --oneline --grep="revert:" -10

# Read the full diff of a successful optimization
git show <commit-hash>

# Compare metric progression
git log --oneline --grep="optimize:" --format="%s" | grep -oP '\([^)]+\)'
```

### What the Agent Learns from History

| Pattern | What it Tells the Agent |
|---------|------------------------|
| `optimize: iteration 3 — caching (+16%)` | Caching worked well for this codebase |
| `revert: optimize iteration 5 — connection pooling (no improvement)` | Connection pooling didn't help here |
| `revert: revert: revert:` | Three reverts in a row = plateau, try a different strategy |
| `fix: fix: fix:` then `build:` | Multiple fixes after build = initial implementation was rushed |
| `optimize: ... (+0.5%)` | Diminishing returns = close to local optimum |

### History-Informed Decisions

The optimize loop uses history to make smarter decisions:

1. **Never repeat a reverted approach** — If "connection pooling" was reverted, don't try it again
2. **Double down on what works** — If "caching" improved things, look for more caching opportunities
3. **Detect plateaus** — 3+ consecutive reverts means try a fundamentally different strategy
4. **Track cumulative improvement** — Know the total improvement across all kept iterations
5. **Resume across sessions** — A new session can read history and pick up where the last left off

### Branch Strategy

```
main
  └── godmode/rate-limiter          # Feature branch
        ├── spec: ...                # THINK commits
        ├── plan: ...                # BUILD commits
        ├── build: task-001 ...
        ├── build: task-002 ...
        ├── optimize: iteration 1 ...
        ├── optimize: iteration 2 ...
        ├── revert: iteration 3 ...  # Reverted changes stay in history
        ├── optimize: iteration 4 ...
        ├── secure: audit ...
        └── ship: v1.3.0 ...
```

The full story of the feature — from idea to optimization to shipping — lives in one branch, readable as a narrative.

### Key Behaviors

1. **Every action is committed** — Even reverts get committed (as revert commits)
2. **Commit messages are structured** — Prefix convention makes history parseable
3. **History is read before acting** — The agent always checks what's been tried before
4. **Reverts are lessons, not failures** — They prevent the agent from repeating mistakes
5. **Cross-session continuity** — Git history persists between agent sessions

---

## 23. Mechanical Verification Framework

**Purpose:** Define how metrics work across Godmode — what counts as a valid metric, how to measure it, how to validate it, and a database of suggested metrics for common scenarios.

### Core Principle: No Vibes

The agent is never allowed to say:
- "The code looks cleaner now" (not measurable)
- "Performance should be better" (not verified)
- "I think this is more maintainable" (not mechanical)

Every claim must be backed by a command that produces a number.

### What Makes a Valid Metric

| Requirement | Explanation | Example |
|------------|-------------|---------|
| **Mechanical** | Produced by a command, not a judgment | `npm test \| grep passing` |
| **Deterministic** | Same input → same output (within tolerance) | Not a random benchmark |
| **Numeric** | Outputs a number (or parseable to a number) | `47`, `340ms`, `84.2%` |
| **Directional** | Clear which direction is better | Lower response time = better |
| **Fast** | Runs in <60 seconds (for iteration loops) | Not a 10-minute integration suite |

### Metric Definition Schema

```json
{
  "name": "p95 response time",
  "command": "wrk -t4 -c100 -d5s http://localhost:3000/api | grep '99%' | awk '{print $2}'",
  "parse": "duration_ms",
  "direction": "lower_is_better",
  "unit": "ms",
  "tolerance": 5,
  "baseline": null,
  "target": 200
}
```

| Field | Description |
|-------|-------------|
| `name` | Human-readable metric name |
| `command` | Shell command to measure the metric |
| `parse` | How to parse the output: `integer`, `float`, `duration_ms`, `percentage`, `last_number` |
| `direction` | `lower_is_better` or `higher_is_better` |
| `unit` | Display unit (ms, %, count, bytes, etc.) |
| `tolerance` | Acceptable variance between runs (noise floor) |
| `baseline` | Initial measurement (set by setup) |
| `target` | Goal value (optional, for optimization) |

### Metric Suggestion Database

When the user can't think of a metric, suggest from this database:

| Domain | Metric | Command Template |
|--------|--------|-----------------|
| **Testing** | Tests passing | `<test-cmd> 2>&1 \| grep -c 'pass'` |
| **Testing** | Test coverage | `<coverage-cmd> \| grep 'All files' \| awk '{print $NF}'` |
| **Performance** | Response time (p95) | `wrk -t4 -c100 -d5s <url> \| grep '99%'` |
| **Performance** | Requests/sec | `wrk -t4 -c100 -d5s <url> \| grep 'Requests/sec'` |
| **Performance** | Build time | `time <build-cmd> 2>&1 \| grep real \| awk '{print $2}'` |
| **Size** | Bundle size | `du -sb dist/ \| awk '{print $1}'` |
| **Size** | Lines of code | `find src -name '*.ts' \| xargs wc -l \| tail -1` |
| **Size** | Docker image size | `docker images <name> --format '{{.Size}}'` |
| **Quality** | Lint errors | `<lint-cmd> 2>&1 \| grep -c 'error'` |
| **Quality** | Type errors | `<typecheck-cmd> 2>&1 \| grep -c 'error'` |
| **Quality** | Cyclomatic complexity | `npx complexity-report src/ \| grep 'average'` |
| **Security** | Known vulnerabilities | `npm audit 2>&1 \| grep -c 'vulnerability'` |
| **Reliability** | Error rate | `<test-cmd> 2>&1 \| grep -c 'fail'` |

### Validation Rules

Before accepting a metric, validate:

1. **Command runs** — Execute the command, confirm it exits without error
2. **Output is parseable** — The output contains a number matching the parse rule
3. **Result is stable** — Run twice, results are within tolerance
4. **Direction is clear** — Confirm with user which direction is "better"
5. **Fast enough** — Command completes in under 60 seconds

### Metric Comparison

When comparing metric values between iterations:

```
Metric: p95 response time (lower is better)
  Before: 340ms
  After:  285ms
  Delta:  -55ms (-16.2%)
  Tolerance: ±5ms
  Verdict: IMPROVED (delta exceeds tolerance)
```

| Comparison | Verdict |
|-----------|---------|
| Delta exceeds tolerance in good direction | **IMPROVED** |
| Delta within tolerance | **UNCHANGED** (noise) |
| Delta exceeds tolerance in bad direction | **REGRESSED** |

### Key Behaviors

1. **Metrics are validated at setup** — Don't accept a metric that doesn't work
2. **Tolerance prevents noise** — Small fluctuations are not "improvements"
3. **Same conditions** — Metrics must be measured under the same conditions each time
4. **Parse, don't guess** — Use structured parsing, not regex on prose output
5. **Fail loudly** — If the metric command fails, stop the loop — don't continue with stale data

---

## 24. Guard System

**Purpose:** Prevent regressions during optimization. Guards are metrics that must NOT get worse, even while the primary metric is being improved.

### The Problem

Optimizing one metric often regresses another:
- Faster response time, but tests now fail
- Smaller bundle, but features are missing
- Better coverage, but tests are flaky

Guards prevent this by defining boundaries that must never be crossed.

### Guard Definition

```json
{
  "name": "tests passing",
  "command": "npm test 2>&1 | grep -oP '\\d+ passing' | grep -oP '\\d+'",
  "baseline": 47,
  "direction": "must_not_decrease",
  "tolerance": 0,
  "severity": "hard"
}
```

| Field | Description |
|-------|-------------|
| `name` | Human-readable guard name |
| `command` | Shell command to measure the guard metric |
| `baseline` | Value at the start (or minimum acceptable) |
| `direction` | `must_not_decrease` or `must_not_increase` |
| `tolerance` | Acceptable variance (0 = strict) |
| `severity` | `hard` (mandatory revert) or `soft` (warning, user decides) |

### Guard + Metric Interaction

```
Primary Metric: p95 response time (optimize: lower is better)
Guard 1: tests passing (must not decrease from 47)
Guard 2: test coverage (must not decrease from 84%)
Guard 3: bundle size (must not increase above 150KB)

Iteration 4:
  Primary metric: 241ms → 198ms ✓ IMPROVED
  Guard 1: 47 → 47 ✓ PASS
  Guard 2: 84% → 83% ✗ FAIL (hard guard)
  Guard 3: 142KB → 145KB ✓ PASS

  Verdict: REVERT (guard 2 failed, even though primary metric improved)
```

### Guard Severity

| Severity | On Failure | Use Case |
|----------|-----------|----------|
| **Hard** | Mandatory revert, no exceptions | Tests passing, no security vulnerabilities |
| **Soft** | Warning shown, user decides keep/revert | Coverage %, bundle size, complexity score |

### Common Guard Patterns

| Guard | Command | Direction | Typical Severity |
|-------|---------|-----------|-----------------|
| Tests passing | `npm test` (exit code) | must not fail | Hard |
| Test count | `npm test \| grep passing \| awk '{print $1}'` | must_not_decrease | Hard |
| Test coverage | `npx vitest --coverage \| grep 'All files'` | must_not_decrease | Soft |
| Lint clean | `npx eslint src/` (exit code) | must not fail | Hard |
| Type check | `npx tsc --noEmit` (exit code) | must not fail | Hard |
| Bundle size | `du -sb dist/ \| awk '{print $1}'` | must_not_increase | Soft |
| Build succeeds | `npm run build` (exit code) | must not fail | Hard |

### Max Retry Logic

When a guard fails:

```
Guard "tests passing" FAILED after optimization change.

Retry 1: Revert change, try different approach
  → New approach also fails guard?

Retry 2: Revert, try a more conservative approach
  → Still fails?

Retry 3: Revert, try minimal change
  → Still fails?

STOP: Guard has failed 3 consecutive times.
  This area may be fundamentally constrained.
  Report to user: "Cannot improve [metric] without regressing [guard]."
  Suggestion: Relax the guard threshold, or change the optimization strategy.
```

### Guard Auto-Discovery

During setup, Godmode can auto-suggest guards:

1. Detect test suite → suggest "tests passing" guard
2. Detect linter → suggest "lint clean" guard
3. Detect type checker → suggest "type check" guard
4. Detect build command → suggest "build succeeds" guard
5. Detect coverage tool → suggest "coverage" guard (soft)

### Key Behaviors

1. **Hard guards are non-negotiable** — If tests fail, revert. Period.
2. **Soft guards inform, don't block** — Show the warning, let the user decide
3. **Guards run after every iteration** — Not just at the end
4. **Guards are separate from the primary metric** — They measure different things
5. **Guard failure is a signal** — It means the optimization is approaching a constraint boundary

---

## 25. Results Logging

**Purpose:** Track every iteration's results in a structured, machine-readable format that enables progress summaries, trend analysis, and final reports.

### TSV Format

Results are logged in `.godmode/results.tsv` — tab-separated values for easy parsing.

```tsv
iteration	timestamp	skill	description	metric_name	metric_before	metric_after	delta	delta_pct	kept	guard_status	duration_s
1	2025-01-15T10:30:00Z	optimize	add Redis caching for user lookups	p95_response_time	340	285	-55	-16.2%	true	pass	45
2	2025-01-15T10:32:00Z	optimize	batch database queries	p95_response_time	285	241	-44	-15.4%	true	pass	62
3	2025-01-15T10:34:00Z	optimize	add connection pooling	p95_response_time	241	238	-3	-1.2%	false	pass	38
4	2025-01-15T10:36:00Z	optimize	fast-json-stringify	p95_response_time	241	198	-43	-17.8%	true	pass	51
5	2025-01-15T10:38:00Z	fix	resolve type error in config	errors	5	3	-2	-40.0%	true	pass	12
6	2025-01-15T10:39:00Z	fix	fix test timeout with fake timers	errors	3	2	-1	-33.3%	true	pass	18
```

### Column Definitions

| Column | Type | Description |
|--------|------|-------------|
| `iteration` | int | Sequential iteration number |
| `timestamp` | ISO 8601 | When the iteration completed |
| `skill` | string | Which skill produced this result |
| `description` | string | One-line description of the change |
| `metric_name` | string | Name of the metric being tracked |
| `metric_before` | number | Metric value before the change |
| `metric_after` | number | Metric value after the change |
| `delta` | number | Absolute change (after - before) |
| `delta_pct` | string | Percentage change |
| `kept` | boolean | Whether the change was kept (true) or reverted (false) |
| `guard_status` | string | Guard check result: `pass`, `fail:guard_name`, `skip` |
| `duration_s` | int | How long the iteration took in seconds |

### Progress Summaries

After each iteration, print a compact progress summary:

```
── Optimization Progress ──────────────────────────────────────
  Iteration:  4 / 25
  Metric:     p95 response time
  Current:    198ms (target: 200ms)
  Baseline:   340ms
  Total Δ:    -142ms (-41.8%)
  Kept:       3 / 4
  Trend:      ↓↓↓ (improving rapidly)
  ETA:        Target reached! ✓
────────────────────────────────────────────────────────────────
```

### Trend Indicators

| Symbol | Meaning |
|--------|---------|
| `↓↓↓` or `↑↑↑` | Rapidly improving (>10% per iteration) |
| `↓↓` or `↑↑` | Steadily improving (3-10% per iteration) |
| `↓` or `↑` | Slowly improving (<3% per iteration) |
| `→` | Flat (within tolerance) |
| `↑` or `↓` (wrong direction) | Regressing |
| `~` | Oscillating (inconsistent) |

### Final Report

When a loop completes (optimize, fix, debug), generate a final report:

```markdown
## Optimization Report: Rate Limiter Performance

### Summary
- **Goal:** Reduce p95 response time to under 200ms
- **Result:** 198ms (target: 200ms) ✓ ACHIEVED
- **Baseline:** 340ms → 198ms (-41.8% improvement)
- **Iterations:** 4 used / 25 budgeted
- **Duration:** 3 minutes 16 seconds
- **Efficiency:** 75% kept (3/4 iterations)

### What Worked
1. Redis caching for user lookups (-16.2%)
2. Batch database queries (-15.4%)
3. Fast-json-stringify for serialization (-17.8%)

### What Didn't Work
1. Connection pooling (-1.2%, reverted — not worth complexity)

### Guards
- Tests passing: 47/47 ✓ (no regressions)
- Coverage: 84% → 84% ✓ (maintained)

### Metric Progression
  340ms ████████████████████████████████████ baseline
  285ms █████████████████████████████       iteration 1
  241ms ████████████████████████            iteration 2
  241ms ████████████████████████            iteration 3 (reverted)
  198ms ████████████████████                iteration 4 ✓ target
  200ms ─────────────────────               target line
```

### Archival

When a cycle completes, results are archived:
- Copy `results.tsv` to `.godmode/archive/YYYY-MM-DD-feature-name.tsv`
- Generate final report to `.godmode/archive/YYYY-MM-DD-feature-name-report.md`
- Clear `results.tsv` for the next cycle

### Key Behaviors

1. **Log every iteration** — Including reverts (they're data too)
2. **TSV for machines, summaries for humans** — Both formats serve different needs
3. **Trend detection** — Don't just show the number; show the trajectory
4. **Visual progress** — Bar charts and progress summaries make it easy to scan
5. **Archive, don't delete** — Historical data might be useful for future optimization

---

## 26. Parallel Agent Dispatch

**Purpose:** Split work across multiple agents for independent tasks, using git worktrees for isolation and model matching for cost optimization.

### When to Use Parallel Dispatch

| Scenario | Parallel? | Reason |
|----------|-----------|--------|
| Tasks in same parallel group | Yes | No dependencies between them |
| Multiple test suites | Yes | Tests are independent |
| Code review + next task | Yes | Review doesn't block next task's RED phase |
| Sequential tasks | No | Task B depends on Task A's output |
| Optimization iterations | No | Each iteration depends on the previous |

### Architecture

```
Main Agent (Coordinator)
  │
  ├── Creates worktrees for each parallel task
  ├── Dispatches sub-agents with task context
  ├── Monitors progress and handles failures
  └── Merges results and resolves conflicts

Sub-Agent A                    Sub-Agent B
  ├── Works in worktree A       ├── Works in worktree B
  ├── Follows TDD cycle         ├── Follows TDD cycle
  ├── Commits to task branch    ├── Commits to task branch
  └── Reports completion        └── Reports completion
```

### Git Worktree Strategy

Each parallel agent gets its own worktree to avoid file conflicts:

```bash
# Coordinator creates worktrees
git worktree add .godmode/worktrees/task-003 -b godmode/task-003
git worktree add .godmode/worktrees/task-004 -b godmode/task-004
git worktree add .godmode/worktrees/task-005 -b godmode/task-005

# After completion, coordinator merges
git checkout godmode/feature-branch
git merge godmode/task-003
git merge godmode/task-004
git merge godmode/task-005

# Cleanup
git worktree remove .godmode/worktrees/task-003
git worktree remove .godmode/worktrees/task-004
git worktree remove .godmode/worktrees/task-005
```

### Model Matching Strategy

Not all tasks need the most powerful model. Match task complexity to model capability:

| Task Type | Complexity Signal | Recommended Model | Cost Factor |
|-----------|------------------|-------------------|-------------|
| Write test stub | Low: template-based work | Haiku/Flash | 1x |
| Add config/boilerplate | Low: repetitive patterns | Haiku/Flash | 1x |
| Implement feature | Medium: requires understanding | Sonnet | 5x |
| Fix complex bug | High: requires reasoning | Opus | 25x |
| Architecture change | High: cross-cutting concern | Opus | 25x |
| Code review | Medium: analysis, not creation | Sonnet | 5x |
| Write documentation | Low-Medium: summarization | Sonnet | 5x |

### Dispatch Protocol

**Step 1: Identify Parallel Tasks**
- Read the plan's dependency graph
- Find tasks with no incomplete dependencies (ready to execute)
- Group by parallel group letter

**Step 2: Prepare Context**
- For each task, prepare a context package:
  - Task description from the plan
  - Relevant file contents (read from worktree)
  - Test expectations
  - Coding conventions from the project
  - Reference to the spec (for understanding the big picture)

**Step 3: Dispatch**
- Create worktree per task
- Launch sub-agent with task context and model selection
- Each sub-agent follows the same TDD workflow as `/godmode:build`

**Step 4: Monitor**
- Track completion status of each sub-agent
- Handle timeouts (kill after 2x expected time)
- Handle failures (mark task as failed, move on)

**Step 5: Merge**
- Wait for all parallel tasks to complete
- Merge each task branch into the feature branch
- If merge conflicts arise:
  1. Auto-resolve if trivial (different files, different sections)
  2. If non-trivial: merge one at a time, running tests after each

**Step 6: Integration Verification**
- Run the full test suite on the merged result
- If tests fail: identify which merge caused the failure
- Fix integration issues before proceeding

### Conflict Resolution Strategy

| Conflict Type | Resolution |
|--------------|-----------|
| Different files modified | Auto-merge (no conflict) |
| Same file, different sections | Auto-merge (git handles this) |
| Same file, same section | Manual resolution by coordinator |
| Package dependency conflicts | Merge package files, run install, test |
| Test file conflicts | Keep both test sets, run all |

### Key Behaviors

1. **Worktrees, not branches** — Each agent gets an isolated working directory
2. **Model matching saves cost** — Don't use Opus for boilerplate tasks
3. **Integration test after merge** — Parallel work can create integration issues
4. **Graceful failure** — If one agent fails, the others continue
5. **Coordinator is responsible** — The main agent owns the merge and conflict resolution

---

## 27. Visual Companion

**Purpose:** Browser-based brainstorming and progress visualization tool that runs alongside the CLI, providing a spatial canvas for ideas and a dashboard for optimization progress.

### Design Philosophy: Zero Dependencies

The visual companion is a single HTML file with inline CSS and JavaScript. No build step, no npm install, no React. Just open it in a browser.

```
godmode/visual/companion.html   # Single file, everything inline
```

### How It Connects

```
CLI (Agent)  ←→  WebSocket  ←→  Browser (Visual Companion)
     │                                │
     └── Sends events ──────────────→ Displays in real-time
     └── Receives user actions ←──── Canvas interactions
```

**Launch:**
```bash
# Agent opens the companion
open http://localhost:9876/companion.html
# Or serves it:
python3 -m http.server 9876 --directory .godmode/visual/ &
```

### WebSocket Protocol

Messages are JSON objects with a `type` field:

```json
// Agent → Browser: Add a brainstorming question
{ "type": "question", "id": "q1", "text": "What are you building?" }

// Agent → Browser: Add user's answer
{ "type": "answer", "id": "q1", "text": "A rate limiter for our API" }

// Agent → Browser: Show approach proposals
{ "type": "approaches", "items": [
  { "id": "a1", "name": "Token Bucket", "pros": [...], "cons": [...] },
  { "id": "a2", "name": "Sliding Window", "pros": [...], "cons": [...] }
]}

// Agent → Browser: Optimization progress update
{ "type": "progress", "iteration": 4, "metric": 198, "target": 200, "kept": true }

// Agent → Browser: Phase transition
{ "type": "phase", "from": "BUILD", "to": "OPTIMIZE" }

// Browser → Agent: User selected an approach
{ "type": "select", "id": "a1" }

// Browser → Agent: User annotated something
{ "type": "annotate", "target": "a1", "text": "Let's use this but with Redis Cluster" }
```

### Visual Modes

**Mode 1: Brainstorm Canvas**
- Questions and answers appear as connected cards
- Approaches appear as comparison columns
- User can drag, connect, and annotate cards
- Spatial layout helps organize thinking

```
┌─────────────────────────────────────────────────┐
│  BRAINSTORM: Rate Limiter                       │
│                                                 │
│  ┌──────────┐     ┌──────────────┐              │
│  │ Q: What   │────→│ A: Existing  │              │
│  │ setup?    │     │ Express API  │              │
│  └──────────┘     └──────────────┘              │
│       │                                          │
│  ┌──────────┐     ┌──────────────┐              │
│  │ Q: Scale? │────→│ A: 10K RPM   │              │
│  └──────────┘     └──────────────┘              │
│                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌────────────┐│
│  │ Token Bucket │ │ Sliding Win │ │ API Gateway ││
│  │ ✓ Selected  │ │             │ │             ││
│  └─────────────┘ └─────────────┘ └────────────┘│
└─────────────────────────────────────────────────┘
```

**Mode 2: Progress Dashboard**
- Real-time metric chart (line graph showing improvement over iterations)
- Guard status indicators (green/red lights)
- Task completion progress bar
- Current phase indicator

```
┌─────────────────────────────────────────────────┐
│  OPTIMIZE: p95 Response Time                    │
│                                                 │
│  340ms ┤█                                       │
│  285ms ┤ █                                      │
│  241ms ┤  █                                     │
│  198ms ┤   █ ← current                         │
│  200ms ┤─ ─ ─ ─ target ─ ─ ─                   │
│        └────────────────────                    │
│         1   2   3   4                           │
│                                                 │
│  Guards: [✓ tests] [✓ coverage] [✓ lint]        │
│  Progress: ████████░░ 4/25 iterations           │
└─────────────────────────────────────────────────┘
```

**Mode 3: Plan View**
- Task list with dependencies visualized as a DAG
- Color coding: green (done), blue (in progress), gray (pending)
- Parallel groups highlighted

### Implementation Notes

- **No framework** — Vanilla JS, CSS Grid, SVG for charts
- **No build step** — Single HTML file, works when opened directly
- **WebSocket fallback** — If WebSocket fails, poll a JSON file every 2 seconds
- **Responsive** — Works on half-screen (side-by-side with terminal)
- **Dark mode** — Matches typical terminal aesthetics

### Key Behaviors

1. **Optional** — Godmode works perfectly without the visual companion
2. **Read-only by default** — The companion displays; the CLI drives
3. **Zero install** — Open an HTML file, that's it
4. **Real-time** — Updates as the agent works, no manual refresh
5. **Exportable** — Canvas state can be saved as PNG or JSON

---

## 28. Crash Recovery & Error Handling

**Purpose:** Define failure modes, recovery strategies, and max retry limits so the agent can recover gracefully from any failure.

### Failure Taxonomy

| Failure Mode | Severity | Detection | Recovery |
|-------------|----------|-----------|----------|
| **Agent crash** (context lost) | High | Session ends unexpectedly | Resume from git history + state file |
| **Command timeout** | Medium | Command exceeds timeout | Retry once, then skip/escalate |
| **Metric command fails** | High | Non-zero exit, no parseable output | Retry once, then halt loop |
| **Guard command fails** | High | Non-zero exit code | Treat as guard failure (revert) |
| **Git conflict** | Medium | Merge fails | Auto-resolve or escalate |
| **Disk full** | Critical | Write fails | Alert user, stop all work |
| **Network failure** | Medium | Fetch/push fails | Retry 3x, then work offline |
| **Test flakiness** | Low | Intermittent test failures | Retry test 2x before treating as real failure |
| **Infinite loop** | High | Iteration count exceeds max | Hard stop at max iterations |
| **Worktree corruption** | Medium | Git worktree commands fail | Remove and recreate worktree |

### Recovery Strategy: Session Resume

When the agent starts a new session in a project with existing `.godmode/` state:

```
1. Read .godmode/state.json
   → Determine: what phase, what skill, what iteration

2. Read .godmode/results.tsv
   → Determine: what was tried, what worked, what failed

3. Read git log (last 50 commits)
   → Determine: last action, uncommitted changes

4. Check for uncommitted changes
   → If dirty: stash or commit as "recovery: uncommitted changes from crashed session"

5. Resume from last known good state
   → Print: "Recovered from crashed session. Resuming at [phase], iteration [N]"
```

### Recovery Strategy: Stuck Loops

When the optimization loop appears stuck:

| Condition | Detection | Action |
|-----------|-----------|--------|
| 5 consecutive reverts | results.tsv shows 5 `kept=false` in a row | Switch strategy (explore → surgical, etc.) |
| Same error 3 fix attempts | Fix log shows same error ID 3 times | Escalate to user |
| Metric oscillating | Up-down-up-down pattern in results.tsv | Increase tolerance or change approach |
| Guard always failing | Guard fails on every attempt | Ask user to relax guard or change scope |
| No improvement after 10 iterations | All deltas within tolerance | Declare plateau, suggest different metric |

### Max Retry Limits

| Operation | Max Retries | On Exceed |
|-----------|------------|-----------|
| Command execution | 2 | Report failure, skip operation |
| Test run (flaky) | 2 | Treat as real failure |
| Git merge conflict | 1 | Escalate to coordinator/user |
| Network operation | 3 | Work offline mode |
| Optimization iteration | configurable (default 25) | Stop, report best result |
| Fix iteration | configurable (default 15) | Stop, report remaining errors |
| Debug iteration | configurable (default 10) | Stop, escalate to user |
| Guard failure in a row | 3 | Stop loop, ask user |

### State Checkpointing

To enable recovery, state is checkpointed frequently:

```
Checkpoint triggers:
  - After every successful iteration (results.tsv + state.json updated)
  - After every git commit (git is inherently checkpointed)
  - After every phase transition (state.json phase field updated)
  - Before any destructive operation (git stash or branch backup)
```

### Dirty State Handling

| State | Detection | Action |
|-------|-----------|--------|
| Uncommitted changes | `git status --porcelain` non-empty | Stash or commit as recovery |
| Partial merge | `.git/MERGE_HEAD` exists | Abort merge, retry |
| Detached HEAD | `git symbolic-ref HEAD` fails | Checkout the feature branch |
| Missing worktree | Worktree directory doesn't exist | Recreate from branch |
| Corrupted state.json | JSON parse fails | Rebuild from git history |

### Error Reporting

When an unrecoverable error occurs:

```
⚠ GODMODE ERROR — Unrecoverable

  Phase: OPTIMIZE (iteration 7)
  Error: Metric command timeout after 120s
  Command: wrk -t4 -c100 -d10s http://localhost:3000/api

  Attempted recovery:
    1. Retry command → timed out again
    2. Check if server is running → port 3000 not listening

  Root cause: The development server crashed during optimization.

  To resume:
    1. Start the dev server: npm run dev
    2. Run: /godmode:optimize --resume
```

### Key Behaviors

1. **Always recoverable** — No failure should require starting over
2. **State is on disk** — Not in memory; crashes don't lose progress
3. **Git is the ultimate backup** — Even if state files corrupt, git history tells the story
4. **Retry before failing** — One retry is cheap; immediate failure is frustrating
5. **Clear error messages** — Tell the user what happened, why, and how to fix it

---

## 29. Integration Points

**Purpose:** Define how skills chain together, pipeline definitions, and cross-skill communication patterns.

### Skill Communication Model

Skills communicate through three channels:

1. **Files** — Artifacts on disk (specs, plans, reports, results)
2. **State** — The `.godmode/state.json` file (current phase, active skill, progress)
3. **Git** — Commit history (what was done, what worked, what failed)

There is no direct function-call interface between skills. This is intentional: any skill can run independently, and the "integration" is the shared filesystem.

### Skill Chaining

Skills can chain to other skills at completion:

```
/godmode:think → completes → suggests /godmode:plan
/godmode:plan  → completes → suggests /godmode:build
/godmode:build → completes → suggests /godmode:optimize
/godmode:debug → finds bug → chains to /godmode:fix
/godmode:fix   → all fixed → suggests /godmode:optimize
/godmode:secure → finds issues → chains to /godmode:fix
```

### Pipeline Definitions

Common pipelines (sequences of skills) can be invoked as a single command:

| Pipeline | Skills | Use Case |
|----------|--------|----------|
| `--pipeline full` | think → plan → build → optimize → ship | Complete feature from scratch |
| `--pipeline build` | plan → build → review | Build from existing spec |
| `--pipeline harden` | test → secure → fix → optimize | Harden existing code |
| `--pipeline fix-all` | debug → fix → verify | Find and fix all bugs |
| `--pipeline ship` | review → secure → ship → finish | Ship existing feature |

Usage:
```
/godmode --pipeline full    # Run complete THINK→BUILD→OPTIMIZE→SHIP cycle
/godmode --pipeline harden  # Test, audit, fix, optimize existing code
```

### Cross-Skill Data Flow

```
┌─────────┐     spec.md      ┌──────────┐     plan.md      ┌─────────┐
│  think   │ ──────────────→  │   plan   │ ──────────────→  │  build  │
└─────────┘                   └──────────┘                   └─────────┘
     │                              ↑                             │
     │  prediction.md          scenario.md                        │
     ↓                              │                             │
┌─────────┐                   ┌──────────┐                   ┌─────────┐
│ predict  │                   │ scenario │                   │ review  │
└─────────┘                   └──────────┘                   └─────────┘
                                                                  │
                                                            state.json
                                                                  ↓
┌─────────┐   results.tsv    ┌──────────┐    findings.md    ┌─────────┐
│ optimize │ ←──────────────  │   fix    │ ←──────────────  │ secure  │
└─────────┘                   └──────────┘                   └─────────┘
     │
     │  results.tsv + state.json
     ↓
┌─────────┐   ship-record    ┌──────────┐
│  ship   │ ──────────────→  │  finish  │
└─────────┘                   └──────────┘
```

### Shared State Fields

Skills read and write specific fields in `.godmode/state.json`:

| Field | Written By | Read By |
|-------|-----------|---------|
| `phase` | Orchestrator, each skill on completion | Orchestrator, all skills |
| `active_skill` | Each skill on start | Orchestrator |
| `iteration` | optimize, fix, debug | All loop-based skills |
| `plan_file` | plan | build |
| `current_task` | build | review |
| `metrics.baseline` | setup, optimize (first iteration) | optimize |
| `metrics.current` | optimize, fix (each iteration) | All skills |
| `history[]` | Each skill on completion | Orchestrator |

### Event System

Skills emit events that other skills (or the visual companion) can observe:

| Event | Emitted By | Consumed By |
|-------|-----------|-------------|
| `phase.transition` | Orchestrator | Visual companion, hooks |
| `skill.start` | Each skill | Visual companion, logging |
| `skill.complete` | Each skill | Orchestrator, next skill in chain |
| `iteration.complete` | Loop skills | Visual companion, logging |
| `metric.measured` | Verify, optimize | Visual companion, results log |
| `guard.pass` / `guard.fail` | Guard system | Optimize, visual companion |
| `task.complete` | Build | Plan tracker, visual companion |

Events are written to `.godmode/events.jsonl` (JSON Lines format):
```json
{"time":"2025-01-15T10:30:00Z","event":"iteration.complete","data":{"iteration":4,"metric":198,"kept":true}}
```

### Key Behaviors

1. **File-based communication** — Skills don't call each other; they read/write files
2. **Pipelines are syntactic sugar** — They just invoke skills in sequence
3. **State.json is the coordination point** — Every skill reads and writes it
4. **Events are fire-and-forget** — No skill blocks on event delivery
5. **Any skill can run standalone** — Integration is optional, not required

---

## 30. Platform Support

**Purpose:** Godmode is designed for Claude Code first, but the architecture supports other AI coding tools. This section defines the compatibility layer.

### Primary Platform: Claude Code

Godmode is a native Claude Code skill plugin. It uses:
- `SKILL.md` file format (Claude Code's skill discovery)
- `@references/` directive (Claude Code's reference loading)
- Slash commands (`/godmode:*`)
- Agent dispatch (via `SendMessage` / `TaskCreate` tools)
- Git worktrees (via `EnterWorktree` / `ExitWorktree` tools)

### Compatibility Matrix

| Platform | Skill Discovery | Slash Commands | Agent Dispatch | Worktrees | Visual Companion |
|----------|----------------|----------------|----------------|-----------|-----------------|
| **Claude Code** | Native SKILL.md | Native | Native (SendMessage) | Native (EnterWorktree) | Via browser open |
| **Cursor** | Rules file import | Chat commands | Background agents | Manual git worktree | Via browser open |
| **Codex (OpenAI)** | System prompt injection | Chat prefix | Not supported | Manual git worktree | Not supported |
| **OpenCode** | Plugin system | Slash commands | Not supported | Manual git worktree | Via browser open |
| **Gemini CLI** | System prompt injection | Chat commands | Not supported | Manual git worktree | Not supported |

### Adaptation Strategy

For non-Claude Code platforms, provide adapter files:

```
godmode/
├── adapters/
│   ├── cursor/
│   │   ├── .cursorrules          # Cursor rules file that loads Godmode skills
│   │   └── install.sh            # Copies rules to project
│   ├── codex/
│   │   ├── system-prompt.md      # System prompt that includes Godmode workflows
│   │   └── install.sh
│   ├── opencode/
│   │   ├── plugin.json           # OpenCode plugin manifest
│   │   └── install.sh
│   └── gemini/
│       ├── system-prompt.md
│       └── install.sh
```

### Platform-Specific Limitations

**Cursor:**
- No native SKILL.md support — workflows are injected via `.cursorrules`
- Agent dispatch uses Cursor's background agent feature (different API)
- Slash commands become `@godmode think` style invocations
- All skill content must be condensed into rules format

**Codex (OpenAI):**
- No skill system — entire workflow is a system prompt
- No agent dispatch — all work is single-threaded
- No interactive features — Codex runs in batch mode
- Parallel tasks degrade to sequential execution

**OpenCode:**
- Plugin system is compatible but uses different manifest format
- No agent dispatch — single-threaded
- Slash commands work natively

**Gemini CLI:**
- No skill system — system prompt injection only
- No agent dispatch — single-threaded
- Limited tool use compared to Claude Code

### Core vs Platform-Specific Features

| Feature | Core (all platforms) | Claude Code only |
|---------|---------------------|-----------------|
| Brainstorming workflow | Yes | Visual companion |
| TDD cycle | Yes | — |
| Optimization loop | Yes | — |
| Git-as-memory | Yes | — |
| Mechanical verification | Yes | — |
| Guard system | Yes | — |
| Parallel agent dispatch | — | Yes (native) |
| Worktree isolation | Manual command | Automatic (tool) |
| Skill discovery | Varies | Native |
| Real-time visual dashboard | — | Yes |

### Key Behaviors

1. **Claude Code is the reference** — Design for Claude Code first, adapt for others
2. **Core workflows are portable** — The 8-phase optimize loop works anywhere
3. **Advanced features gracefully degrade** — No parallel dispatch? Run sequentially.
4. **Adapters are thin** — They translate, not re-implement
5. **Test on Claude Code first** — Other platforms are community-contributed

---

## 31. Installation & Setup

**Purpose:** Three installation paths — marketplace (one click), manual (git clone), and first-run wizard.

### Path 1: Claude Code Marketplace (Recommended)

```bash
# Install from the Claude Code skill marketplace
claude install godmode

# Or install a specific version
claude install godmode@1.3.0
```

This places the plugin in `~/.claude/skills/godmode/` and makes all `/godmode:*` commands available globally.

### Path 2: Manual Installation

```bash
# Clone into the Claude Code skills directory
git clone https://github.com/godmode-ai/godmode.git ~/.claude/skills/godmode

# Or for project-local installation
git clone https://github.com/godmode-ai/godmode.git .claude/skills/godmode
```

**Global vs. Local installation:**

| Location | Scope | Use Case |
|----------|-------|----------|
| `~/.claude/skills/godmode/` | All projects | Default, recommended |
| `.claude/skills/godmode/` | This project only | Custom per-project config |
| `.claude/skills/godmode/` (in repo) | Shared with team | Team standardization |

### Path 3: Quick Start (One Command)

```bash
# Install and configure in one step
claude install godmode && claude /godmode:setup --quick
```

### First-Run Wizard

On first use of `/godmode` in a project, the agent automatically runs setup:

```
Welcome to Godmode! Let's configure for this project.

Detected: Node.js project (package.json found)
  Test command: npm test (47 tests passing ✓)
  Lint command: npx eslint src/ (clean ✓)
  Build command: npm run build (succeeds ✓)

What are you building? > Add rate limiting to the API

Created .godmode/settings.json
Created .godmode/state.json

Ready! Try:
  /godmode:think    — Start brainstorming
  /godmode:plan     — Jump to planning (if you have a spec)
  /godmode:optimize — Start optimizing (if code exists)
  /godmode           — Let me figure out what's next
```

### Updating

```bash
# Update to latest version
claude update godmode

# Update to specific version
claude update godmode@1.4.0

# Check for updates
claude outdated
```

### Uninstalling

```bash
# Remove the plugin
claude uninstall godmode

# Remove project-local config (optional)
rm -rf .godmode/
```

### Verifying Installation

```bash
# Check that Godmode is installed and working
claude /godmode --version

# Output:
# Godmode v1.3.0
# Skills: 16 loaded
# Platform: Claude Code
# Config: ~/.claude/skills/godmode/settings.json
```

### Directory Structure After Installation

```
~/.claude/skills/godmode/      # Plugin files (skills, references, shared)
.godmode/                       # Project-local state (created on first use)
  ├── settings.json             # Project configuration
  ├── state.json                # Current state (phase, iteration, etc.)
  ├── results.tsv               # Optimization results log
  ├── events.jsonl              # Event log
  ├── specs/                    # Generated specs
  ├── predictions/              # Prediction reports
  ├── scenarios/                # Scenario reports
  ├── security/                 # Security audit reports
  ├── archive/                  # Completed cycle archives
  └── worktrees/                # Git worktrees for parallel tasks
```

### Key Behaviors

1. **One command install** — No manual file copying or configuration
2. **Auto-detect project** — First-run wizard figures out the project type
3. **Global by default** — Install once, use everywhere
4. **Project state is separate** — Plugin files and project state live in different places
5. **Gitignore-friendly** — `.godmode/` should be added to `.gitignore` (it's local state)

---

## 32. Hook System

**Purpose:** Hooks let Godmode inject behavior at session start and lifecycle events, with user-configurable hooks for custom automation.

### Built-in Hooks

**Session Start Hook (`hooks/session-start.md`)**

Runs when a new Claude Code session starts in a project with Godmode installed:

```markdown
# Session Start Hook

## Check for existing Godmode state
If .godmode/state.json exists:
  1. Read the state file
  2. Summarize where the user left off:
     "Godmode: You're in the [PHASE] phase, working on [GOAL].
      Last action: [LAST_SKILL] at [TIME].
      Progress: [SUMMARY]."
  3. Suggest next action

If .godmode/state.json does not exist:
  1. Mention Godmode is available: "Godmode is installed. Use /godmode to start."
```

**Lifecycle Hook (`hooks/lifecycle.md`)**

Runs on phase transitions and key events:

```markdown
# Lifecycle Hook

## On Phase Transition
When phase changes (e.g., THINK → BUILD):
  1. Verify handoff artifacts exist
  2. Update state.json
  3. Emit phase.transition event
  4. Print transition message

## On Skill Completion
When any skill completes:
  1. Update state.json history
  2. Emit skill.complete event
  3. Suggest next action (unless in auto mode)

## On Error
When an unrecoverable error occurs:
  1. Save crash state to .godmode/crash-dump.json
  2. Emit error event
  3. Print recovery instructions
```

### User-Configurable Hooks

Users can add custom hooks in `.godmode/hooks/`:

```
.godmode/hooks/
  ├── pre-build.md       # Runs before /godmode:build starts
  ├── post-build.md      # Runs after /godmode:build completes
  ├── pre-ship.md        # Runs before /godmode:ship starts
  ├── post-optimize.md   # Runs after each optimization iteration
  └── on-error.md        # Runs when any error occurs
```

### Hook Naming Convention

| Pattern | When it Runs |
|---------|-------------|
| `pre-{skill}.md` | Before the named skill starts |
| `post-{skill}.md` | After the named skill completes |
| `on-{event}.md` | When the named event occurs |

### Hook File Format

```markdown
---
hook: pre-build
description: Run linting before starting build
timeout: 30s
required: true  # If true, hook failure blocks the skill
---

# Pre-Build Hook

## Steps
1. Run the linter: `npx eslint src/`
2. If lint errors exist:
   - Print: "Fix lint errors before building"
   - Block the build
3. If lint is clean:
   - Print: "Lint clean ✓"
   - Proceed
```

### Hook Execution

```
User: /godmode:build

[Hook] Running pre-build hook...
  → npx eslint src/ ✓ clean

[Skill] Starting /godmode:build...
  ... (build happens) ...

[Hook] Running post-build hook...
  → Sending Slack notification (custom hook) ✓

[Skill] /godmode:build complete
```

### Hook Configuration in settings.json

```json
{
  "hooks": {
    "enabled": true,
    "timeout": "30s",
    "custom_dir": ".godmode/hooks/",
    "disabled_hooks": ["post-optimize"]  // Skip specific hooks
  }
}
```

### Built-in vs Custom Hooks

| Aspect | Built-in Hooks | Custom Hooks |
|--------|---------------|-------------|
| Location | `godmode/hooks/` (plugin dir) | `.godmode/hooks/` (project dir) |
| Modifiable | No (plugin code) | Yes (user owns them) |
| Required | Always run | Configurable |
| Examples | Session start, lifecycle | Slack notifications, custom checks |

### Key Behaviors

1. **Hooks are markdown** — Same format as skills, readable and editable
2. **Pre-hooks can block** — `required: true` means the skill won't start if the hook fails
3. **Post-hooks are informational** — They run after the skill, but don't affect its result
4. **Timeouts prevent hangs** — Hooks that run too long are killed
5. **Disabled by default for performance** — Custom hooks must be explicitly enabled

---

## 33. Configuration Schema

**Purpose:** Define the complete `settings.json` structure, per-project overrides, and global defaults.

### Configuration Hierarchy

Settings are resolved in order (later overrides earlier):

```
1. Plugin defaults (godmode/settings.json)           — shipped with plugin
2. Global user config (~/.godmode/settings.json)      — user preferences
3. Project config (.godmode/settings.json)             — project-specific
4. Command-line flags                                  — per-invocation override
```

### Complete Schema

```json
{
  "$schema": "https://godmode.dev/schema/settings.v1.json",

  // Project detection (usually auto-detected)
  "project": {
    "type": "node",                        // node, python, go, rust, java, generic
    "test_command": "npm test",
    "lint_command": "npx eslint src/",
    "build_command": "npm run build",
    "typecheck_command": "npx tsc --noEmit",
    "coverage_command": "npx vitest --coverage"
  },

  // Current goal (set by /godmode:setup)
  "goal": "Add rate limiting to the Express API",

  // File scope (what the agent can modify)
  "scope": {
    "include": ["src/", "tests/", "config/"],
    "exclude": ["node_modules/", "dist/", ".env"]
  },

  // Primary optimization metric
  "metric": {
    "name": "p95 response time",
    "command": "wrk -t4 -c100 -d5s http://localhost:3000/api | grep '99%' | awk '{print $2}'",
    "parse": "duration_ms",
    "direction": "lower_is_better",
    "unit": "ms",
    "tolerance": 5,
    "baseline": null,
    "target": 200
  },

  // Verification command
  "verify": "npm test",

  // Guard metrics
  "guards": [
    {
      "name": "tests passing",
      "command": "npm test 2>&1 | grep -oP '\\d+ passing' | grep -oP '\\d+'",
      "baseline": 47,
      "direction": "must_not_decrease",
      "tolerance": 0,
      "severity": "hard"
    },
    {
      "name": "test coverage",
      "command": "npx vitest --coverage 2>&1 | grep 'All files' | awk '{print $NF}'",
      "baseline": 84,
      "direction": "must_not_decrease",
      "tolerance": 2,
      "severity": "soft"
    }
  ],

  // Iteration limits
  "iterations": {
    "optimize_max": 25,
    "fix_max": 15,
    "debug_max": 10,
    "plateau_threshold": 5
  },

  // Agent configuration
  "agents": {
    "default_model": "sonnet",
    "complex_model": "opus",
    "simple_model": "haiku",
    "review_model": "sonnet",
    "max_parallel": 3
  },

  // Hook configuration
  "hooks": {
    "enabled": true,
    "timeout": "30s",
    "custom_dir": ".godmode/hooks/",
    "disabled_hooks": []
  },

  // Behavior preferences
  "behavior": {
    "auto_mode": false,             // Auto-transition between phases
    "tdd_enforced": true,           // Require TDD in build phase
    "review_required": true,        // Require code review after each task
    "security_before_ship": true,   // Require security audit before shipping
    "visual_companion": false,      // Launch visual companion by default
    "verbose": false,               // Detailed output
    "commit_style": "conventional"  // conventional, descriptive, or minimal
  },

  // Shipping preferences
  "shipping": {
    "type": "npm",
    "registry": "https://registry.npmjs.org/",
    "dry_run_first": true,
    "auto_changelog": true
  }
}
```

### Field Reference

| Section | Field | Type | Default | Description |
|---------|-------|------|---------|-------------|
| `project.type` | string | auto | Project language/framework |
| `project.test_command` | string | auto | How to run tests |
| `scope.include` | string[] | `["src/"]` | Directories the agent can modify |
| `scope.exclude` | string[] | `["node_modules/"]` | Directories to never touch |
| `metric.direction` | enum | — | `lower_is_better` or `higher_is_better` |
| `metric.tolerance` | number | 0 | Noise floor for metric comparison |
| `iterations.optimize_max` | int | 25 | Max optimization iterations |
| `iterations.plateau_threshold` | int | 5 | Consecutive reverts before stopping |
| `agents.max_parallel` | int | 3 | Max parallel sub-agents |
| `behavior.auto_mode` | bool | false | Automatically chain skills |
| `behavior.tdd_enforced` | bool | true | Require test-first development |

### Per-Project Override Example

A Python ML project might override:
```json
{
  "project": {
    "type": "python",
    "test_command": "pytest -v",
    "lint_command": "ruff check ."
  },
  "metric": {
    "name": "model accuracy",
    "command": "python evaluate.py | grep accuracy | awk '{print $2}'",
    "direction": "higher_is_better",
    "unit": "%"
  },
  "agents": {
    "default_model": "opus"
  }
}
```

### Key Behaviors

1. **Sensible defaults** — Works out of the box for common project types
2. **Progressive disclosure** — Basic usage needs no config; advanced users customize everything
3. **Validation on save** — Config is validated; invalid values are rejected with explanations
4. **Environment variable support** — Sensitive values can reference env vars: `"$REGISTRY_TOKEN"`
5. **Schema versioned** — `$schema` field allows config format evolution without breaking

---

## 34. README.md Draft

The GitHub README that sells Godmode. Designed for developers scanning quickly.

```markdown
# Godmode

**Turn on Godmode for Claude Code.**

Godmode is a skill plugin that gives your AI agent a complete development
workflow — from idea to optimized, shipped product.

[demo.gif placeholder — showing /godmode:think → plan → build → optimize → ship]

## The Godmode Loop

    THINK → BUILD → OPTIMIZE → SHIP → REPEAT

Most AI tools do one thing. Godmode does the full cycle.

| Phase | What happens | Skills |
|-------|-------------|--------|
| THINK | Brainstorm, predict outcomes, explore edge cases | think, predict, scenario |
| BUILD | Plan tasks, TDD, parallel build, code review | plan, build, test, review |
| OPTIMIZE | Autonomous iteration with mechanical metrics | optimize, debug, fix, secure |
| SHIP | Pre-flight checks, deploy, verify, finalize | ship, finish |

## Quick Start

    claude install godmode
    /godmode

That's it. Godmode detects your project and suggests what to do next.

## Feature Highlights

**Structured Brainstorming**
One question at a time. 2-3 approach proposals. Written spec output.
Optional visual companion in your browser.

**TDD Enforcement**
Write the test first. See it fail. Then implement. Every task.

**Autonomous Optimization**
Tell it what to measure. It modifies code, measures results, keeps
improvements, reverts failures. Git is memory. Metrics are truth.

**Guard System**
Optimize response time without breaking tests. Guards prevent regressions.

**Parallel Agent Dispatch**
Independent tasks run in parallel across agents and git worktrees.
Model matching: Haiku for boilerplate, Sonnet for features, Opus for
architecture.

**Security Audit**
STRIDE + OWASP + 4 red-team personas. Every finding includes the fix.

**Git-as-Memory**
Every experiment is committed. Reverts are lessons. The agent reads its
own history to avoid repeating mistakes.

**8-Phase Shipping**
Inventory → checklist → changelog → version → build → dry-run → ship → verify.
Supports npm, PyPI, Docker, GitHub Releases, Vercel, Cloudflare, and custom.

## Commands

| Command | Description |
|---------|-------------|
| `/godmode` | Auto-detect phase and suggest next skill |
| `/godmode:think` | Brainstorm and write a spec |
| `/godmode:predict` | Multi-persona expert evaluation |
| `/godmode:scenario` | Edge case exploration (12 dimensions) |
| `/godmode:plan` | Decompose spec into 2-5 min tasks |
| `/godmode:build` | Execute plan with TDD and parallel agents |
| `/godmode:test` | Write tests (RED-GREEN-REFACTOR) |
| `/godmode:review` | Code review with severity levels |
| `/godmode:optimize` | Autonomous optimization loop |
| `/godmode:debug` | Scientific bug hunting (7 techniques) |
| `/godmode:fix` | One fix per iteration until zero errors |
| `/godmode:secure` | Security audit (STRIDE + OWASP) |
| `/godmode:ship` | 8-phase shipping workflow |
| `/godmode:finish` | Branch finalization (merge/PR/keep/discard) |
| `/godmode:setup` | Configuration wizard |
| `/godmode:verify` | Evidence-before-claims gate |

## Pipelines

    /godmode --pipeline full      # THINK → BUILD → OPTIMIZE → SHIP
    /godmode --pipeline harden    # test → secure → fix → optimize
    /godmode --pipeline ship      # review → secure → ship → finish

## Philosophy

1. **Discipline before speed** — Design before code, tests before implementation
2. **Autonomy within constraints** — Agent works independently within guardrails
3. **Git is memory** — Every experiment committed, every decision traceable

## Built On

Godmode combines the best ideas from:
- [autoresearch](https://github.com/uditgoenka/autoresearch) — Autonomous iteration loops
- [superpowers](https://github.com/obra/superpowers) — Structured development workflows

## License

MIT
```

---

## 35. CHANGELOG Template

**Purpose:** Standardize version history format and semantic versioning strategy for Godmode releases.

### Versioning Strategy

Godmode follows [Semantic Versioning](https://semver.org/):

| Version Part | When to Bump | Example |
|-------------|-------------|---------|
| **MAJOR** (X.0.0) | Breaking changes to skill format, config schema, or command interface | Skill frontmatter schema change |
| **MINOR** (1.X.0) | New skills, new features in existing skills, new flags | Add `/godmode:refactor` skill |
| **PATCH** (1.0.X) | Bug fixes, documentation updates, metric database additions | Fix guard tolerance calculation |

### CHANGELOG Format

```markdown
# Changelog

All notable changes to Godmode are documented in this file.
Format based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Added
- New metric suggestions for Rust projects

## [1.3.0] - 2025-02-15

### Added
- `/godmode:scenario` skill — explore edge cases across 12 dimensions
- `--chain` flag for linking skills (e.g., `/godmode:debug --chain fix`)
- Metric suggestion database with 15 common metrics
- Support for Cloudflare Workers in `/godmode:ship`

### Changed
- `/godmode:optimize` now auto-selects strategy based on metric history
- Guard system supports soft guards (warnings instead of mandatory reverts)
- Parallel dispatch now uses model matching for cost optimization

### Fixed
- Fix: guard tolerance calculation was ignoring negative deltas
- Fix: visual companion WebSocket reconnection loop
- Fix: session start hook not detecting existing state on Windows paths

### Deprecated
- `--simple` flag on `/godmode:review` (use `--severity note` instead)

## [1.2.0] - 2025-01-20

### Added
- `/godmode:predict` skill — multi-persona expert evaluation
- Visual companion brainstorm canvas mode
- Pipeline support: `--pipeline full`, `--pipeline harden`

### Changed
- `/godmode:build` now enforces TDD by default (use `--tdd false` to disable)
- Results TSV format adds `duration_s` column

### Fixed
- Fix: optimize loop not reading revert history correctly
- Fix: plan dependency graph cycle detection

## [1.1.0] - 2025-01-10

### Added
- `/godmode:secure` skill — STRIDE + OWASP security audit
- Git-as-memory commit convention documentation
- Configuration hierarchy (global → project → CLI flags)

### Fixed
- Fix: worktree cleanup leaving dangling branches

## [1.0.0] - 2025-01-01

### Added
- Initial release with 16 skills
- Core loop: THINK → BUILD → OPTIMIZE → SHIP
- Orchestrator with auto-detection
- Git-as-memory system
- Mechanical verification framework
- Guard system
- Results logging (TSV)
- Visual companion (brainstorm + dashboard modes)
- Configuration wizard (/godmode:setup)
- Platform adapters for Cursor, Codex, OpenCode
```

### Categories Used

| Category | Meaning |
|----------|---------|
| **Added** | New features, skills, flags, integrations |
| **Changed** | Behavior changes to existing features |
| **Fixed** | Bug fixes |
| **Deprecated** | Features that will be removed in a future version |
| **Removed** | Features removed in this version |
| **Security** | Security-related changes |

### Auto-Generation

The `/godmode:ship` skill auto-generates changelog entries from git commits:
- Commits with `feat:` prefix → **Added**
- Commits with `fix:` prefix → **Fixed**
- Commits with `BREAKING:` in body → **Changed** (with breaking change note)
- Commits with `deprecate:` prefix → **Deprecated**
- Commits with `secure:` prefix → **Security**

---

## 36. Contributing Guide

**Purpose:** How to add new skills, testing requirements, and PR template for contributors.

### Adding a New Skill

**Step 1: Create the skill directory**
```
skills/
  └── your-skill/
      ├── SKILL.md
      └── references/
          └── your-protocol.md
```

**Step 2: Write the SKILL.md**

Follow the format from Section 4. Required sections:
- Frontmatter (name, description, triggers, phase, flags)
- When to Use
- Workflow (numbered steps)
- Key Behaviors
- Example Usage

**Step 3: Register with the orchestrator**

Add your skill to the routing table in the root `SKILL.md`:
```markdown
| your-skill | `/godmode:yourskill` | PHASE | Description |
```

**Step 4: Add to settings.json defaults**

If your skill has configurable settings, add defaults to `settings.json`.

**Step 5: Write tests**

Every skill must have a test scenario (see Testing Requirements below).

### Testing Requirements

Since skills are markdown instructions (not executable code), testing means **session replay testing**:

1. **Create a test scenario** in `tests/scenarios/`:
```markdown
# Test: /godmode:yourskill basic workflow

## Setup
- Project: Node.js with 3 test files
- State: BUILD phase, 2 tasks remaining

## Input
User: /godmode:yourskill --flag value

## Expected Behavior
1. Agent reads [specific files]
2. Agent produces [specific output format]
3. Agent commits with prefix "yourskill:"
4. State.json updated with [specific fields]

## Verification
- File .godmode/output.md exists
- Git log shows commit with "yourskill:" prefix
- State.json phase field is [expected value]
```

2. **Manual smoke test**: Run the skill in a real project and verify it follows the documented workflow.

3. **Integration test**: Verify the skill chains correctly with upstream and downstream skills.

### PR Template

```markdown
## New Skill / Skill Improvement

### What
[One sentence: what does this add/change?]

### Skill
- Name: `/godmode:yourskill`
- Phase: [THINK/BUILD/OPTIMIZE/SHIP/META]
- Origin: [new / autoresearch / superpowers]

### Checklist
- [ ] SKILL.md follows the standard format (Section 4)
- [ ] Frontmatter has all required fields
- [ ] Workflow has numbered steps
- [ ] Key Behaviors section included
- [ ] Example Usage section included
- [ ] References directory created (if needed)
- [ ] Orchestrator routing table updated
- [ ] Test scenario created in tests/scenarios/
- [ ] Smoke tested in a real project
- [ ] Integration tested with upstream/downstream skills
- [ ] CHANGELOG entry added

### Testing
[Describe how you tested this]

### Screenshots (if visual)
[Screenshots of the skill in action]
```

### Code Style for Skills

| Rule | Rationale |
|------|-----------|
| Workflows have numbered steps | Makes it easy to reference ("at Step 3...") |
| Tables for structured data | Scannable, not buried in prose |
| Code blocks for commands/output | Clear distinction between instructions and examples |
| One behavior per Key Behaviors item | Atomic rules are easier to follow |
| Example Usage shows a realistic scenario | Not toy examples; real-world complexity |

### Contribution Areas

| Area | Difficulty | Impact |
|------|-----------|--------|
| New skill | High | High |
| Metric database additions | Low | Medium |
| Platform adapter | Medium | Medium |
| Bug fix in existing skill | Low | High |
| Reference file expansion | Low | Medium |
| Test scenario | Medium | High |
| Documentation improvement | Low | Low |

---

## 37. Skill Discovery & Invocation System

**Purpose:** How Claude Code discovers Godmode skills, injects their descriptions, and matches user intent to the right skill.

### Discovery Mechanism

Claude Code scans for `SKILL.md` files in registered skill directories. When Godmode is installed:

```
Scan: ~/.claude/skills/godmode/
  Found: SKILL.md (orchestrator)
  Found: skills/think/SKILL.md
  Found: skills/predict/SKILL.md
  Found: skills/scenario/SKILL.md
  ... (16 total)
```

Each discovered skill is registered with:
- **Name:** From frontmatter `name` field
- **Triggers:** From frontmatter `triggers` field
- **Description:** From frontmatter `description` field

### Description Injection

Claude Code injects skill descriptions into the agent's context at session start:

```
Available skills:
  /godmode - Auto-detect phase and route to the right skill
  /godmode:think - Collaborative brainstorming with spec writing
  /godmode:predict - Multi-persona expert evaluation
  /godmode:scenario - Edge case exploration across 12 dimensions
  /godmode:plan - Decompose spec into 2-5 min tasks
  /godmode:build - Execute plan with TDD and parallel agents
  /godmode:test - Write tests with RED-GREEN-REFACTOR
  /godmode:review - Code review with severity levels
  /godmode:optimize - Autonomous optimization with mechanical metrics
  /godmode:debug - Scientific bug hunting
  /godmode:fix - One fix per iteration until zero errors
  /godmode:secure - STRIDE + OWASP security audit
  /godmode:ship - 8-phase shipping workflow
  /godmode:finish - Branch finalization
  /godmode:setup - Configuration wizard
  /godmode:verify - Evidence-before-claims gate
```

### Trigger Matching

When the user types a message, Claude Code matches it against skill triggers:

**Exact match (slash command):**
```
User: /godmode:think
Match: skills/think/SKILL.md (exact trigger match)
Action: Load SKILL.md, follow workflow
```

**Natural language match:**
```
User: "Let's brainstorm the authentication system"
Match: skills/think/SKILL.md (trigger phrase: "let's brainstorm")
Action: Suggest /godmode:think, or auto-invoke if confidence is high
```

**Orchestrator routing:**
```
User: /godmode
Match: Root SKILL.md (orchestrator)
Action: Run auto-detection algorithm, route to appropriate skill
```

### Trigger Confidence Levels

| Confidence | Action |
|-----------|--------|
| **High** (>0.9) | Auto-invoke the skill (exact match, explicit trigger phrase) |
| **Medium** (0.6-0.9) | Suggest the skill: "Would you like to use /godmode:think for brainstorming?" |
| **Low** (<0.6) | Don't suggest; let the user invoke explicitly |

### Skill Loading Process

When a skill is invoked:

```
1. Load SKILL.md content
2. Parse frontmatter (flags, requirements, phase)
3. Check prerequisites (does `requires` list have all skills completed?)
4. Load shared references (@shared/*.md) if referenced
5. Load skill-specific references (@references/*.md) as needed
6. Execute workflow step by step
```

### Namespace Convention

All Godmode skills use the `godmode:` namespace prefix:

```
/godmode           → Orchestrator (root SKILL.md)
/godmode:think     → skills/think/SKILL.md
/godmode:build     → skills/build/SKILL.md
```

This prevents collisions with other plugins:
```
/godmode:test      → Godmode's TDD skill
/other-plugin:test → Different plugin's test skill
```

### Skill Aliasing

Common abbreviations are registered as aliases:

| Alias | Full Command |
|-------|-------------|
| `/gm` | `/godmode` |
| `/gm:t` | `/godmode:think` |
| `/gm:b` | `/godmode:build` |
| `/gm:o` | `/godmode:optimize` |
| `/gm:s` | `/godmode:ship` |

### Key Behaviors

1. **Namespace isolation** — `godmode:` prefix prevents collisions
2. **Lazy loading** — SKILL.md content is loaded only when invoked, not at discovery
3. **Natural language is optional** — Users can always use explicit slash commands
4. **References load on demand** — Heavy files load only when the workflow step needs them
5. **Graceful missing skills** — If a skill file is missing, show a helpful error, not a crash

---

## 38. Domain Adaptation Guide

**Purpose:** How to use Godmode effectively for different domains — the core loop is universal, but metrics, guards, and workflows adapt per domain.

### Backend API Development

```json
{
  "project": { "type": "node" },
  "metric": {
    "name": "p95 response time",
    "command": "wrk -t4 -c100 -d5s http://localhost:3000/api | grep '99%'",
    "direction": "lower_is_better"
  },
  "guards": [
    { "name": "tests", "command": "npm test", "severity": "hard" },
    { "name": "no lint errors", "command": "npx eslint src/", "severity": "hard" }
  ]
}
```

**Key adaptations:**
- `/godmode:scenario` focuses on: concurrency, failure, scale, abuse
- `/godmode:secure` runs full STRIDE + OWASP
- `/godmode:optimize` measures: response time, throughput, memory usage
- `/godmode:ship` type: `npm`, `docker`, or `custom`

### Frontend Web Development

```json
{
  "project": { "type": "node" },
  "metric": {
    "name": "Lighthouse performance score",
    "command": "npx lighthouse http://localhost:3000 --output json --quiet | jq '.categories.performance.score'",
    "direction": "higher_is_better"
  },
  "guards": [
    { "name": "bundle size", "command": "du -sb dist/ | awk '{print $1}'", "direction": "must_not_increase", "severity": "soft" },
    { "name": "tests", "command": "npx vitest run", "severity": "hard" }
  ]
}
```

**Key adaptations:**
- `/godmode:predict` adds "The Accessibility Expert" persona
- `/godmode:scenario` focuses on: empty/null, permission, browser compatibility
- `/godmode:optimize` measures: bundle size, Lighthouse score, First Contentful Paint
- `/godmode:test` includes snapshot tests and visual regression tests

### Machine Learning

```json
{
  "project": { "type": "python" },
  "metric": {
    "name": "model accuracy",
    "command": "python evaluate.py --metric accuracy",
    "direction": "higher_is_better"
  },
  "guards": [
    { "name": "training time", "command": "python train.py --time-only", "direction": "must_not_increase", "tolerance": 60, "severity": "soft" },
    { "name": "data validation", "command": "python validate_data.py", "severity": "hard" }
  ]
}
```

**Key adaptations:**
- `/godmode:think` explores: model architecture, feature engineering, data pipeline
- `/godmode:predict` adds "The Data Scientist" persona (data quality, drift, reproducibility)
- `/godmode:optimize` measures: accuracy, F1, training time, inference latency
- `/godmode:scenario` focuses on: data quality, class imbalance, adversarial inputs, distribution shift
- `/godmode:test` focuses on data validation, model consistency tests

### DevOps / Infrastructure

```json
{
  "project": { "type": "generic" },
  "metric": {
    "name": "deployment time",
    "command": "time terraform apply -auto-approve 2>&1 | grep real | awk '{print $2}'",
    "direction": "lower_is_better"
  },
  "guards": [
    { "name": "terraform validate", "command": "terraform validate", "severity": "hard" },
    { "name": "cost estimate", "command": "infracost diff --format json | jq '.totalMonthlyCost'", "direction": "must_not_increase", "severity": "soft" }
  ]
}
```

**Key adaptations:**
- `/godmode:secure` focuses on: IAM misconfigurations, network exposure, secrets in code
- `/godmode:scenario` focuses on: failure modes, blast radius, recovery time
- `/godmode:ship` type: `custom` with `terraform apply` or `kubectl apply`

### Content / Documentation

```json
{
  "project": { "type": "generic" },
  "metric": {
    "name": "word count",
    "command": "wc -w docs/**/*.md | tail -1 | awk '{print $1}'",
    "direction": "higher_is_better"
  },
  "guards": [
    { "name": "links valid", "command": "npx markdown-link-check docs/", "severity": "hard" },
    { "name": "spell check", "command": "npx cspell docs/**/*.md | wc -l", "direction": "must_not_increase", "severity": "soft" }
  ]
}
```

**Key adaptations:**
- `/godmode:think` focuses on: outline, audience, tone, structure
- `/godmode:optimize` measures: readability score, completeness, broken links
- `/godmode:review` focuses on: clarity, accuracy, consistency

### Domain Selection Prompt

During `/godmode:setup`, if project type is ambiguous:

```
What kind of project is this?
  1. Backend API (Node, Python, Go, Rust)
  2. Frontend Web (React, Vue, Svelte)
  3. Full-Stack (Backend + Frontend)
  4. Machine Learning (Python, Jupyter)
  5. DevOps / Infrastructure (Terraform, K8s)
  6. CLI Tool (Go, Rust, Python)
  7. Library / Package (any language)
  8. Content / Documentation
  9. Other (I'll configure manually)
```

### Key Behaviors

1. **Same loop, different metrics** — The THINK→BUILD→OPTIMIZE→SHIP cycle works for every domain
2. **Metrics are domain-specific** — What you measure changes; how you measure doesn't
3. **Guards adapt** — A backend guard is "tests pass"; an ML guard is "data validates"
4. **Personas rotate** — Different domains need different expert perspectives
5. **Templates matter** — Domain-specific setup templates reduce configuration time

---

## 39. Anti-Patterns

**Purpose:** What NOT to do when using or implementing Godmode. Learn from the mistakes so you don't repeat them.

### Anti-Pattern 1: Vibes-Based Optimization

```
BAD:  "The code looks cleaner now, so I'll keep this change."
WHY:  "Looks cleaner" is not a metric. Run the verification command.
GOOD: "Running metric... p95 went from 241ms to 198ms. Keeping the change."
```

**Rule:** If you can't measure it with a command, it's not an improvement.

### Anti-Pattern 2: Big Bang Changes

```
BAD:  Make 5 changes in one optimization iteration.
WHY:  When the metric improves, you don't know which change helped.
      When it regresses, you don't know which change broke it.
GOOD: One change per iteration. Know exactly what worked.
```

**Rule:** Atomic changes make learning possible.

### Anti-Pattern 3: Skipping the RED Step

```
BAD:  Write the test and implementation at the same time.
WHY:  If the test never fails, it might not be testing anything.
GOOD: Write test → see it fail → then implement → see it pass.
```

**Rule:** A test that never failed never proved anything.

### Anti-Pattern 4: Ignoring Reverts

```
BAD:  "The last 5 iterations were reverted, but I'll keep trying the same approach."
WHY:  5 consecutive reverts = plateau. The current approach is exhausted.
GOOD: After 3 reverts, switch strategy. After 5, stop and reconsider.
```

**Rule:** Reverts are data. Use them.

### Anti-Pattern 5: Over-Guarding

```
BAD:  15 hard guards that make it impossible to change anything.
WHY:  Every change triggers a guard failure because the guards are too strict.
GOOD: 2-3 hard guards (tests pass, build succeeds) + a few soft guards.
```

**Rule:** Guards should protect, not paralyze.

### Anti-Pattern 6: Premature Optimization

```
BAD:  /godmode:optimize before /godmode:build is done.
WHY:  You're optimizing code that will change during build. Wasted iterations.
GOOD: Build it right first. Then make it fast.
```

**Rule:** Follow the phases. THINK → BUILD → OPTIMIZE → SHIP.

### Anti-Pattern 7: Claiming Without Evidence

```
BAD:  "I've fixed the bug and all tests pass now." (without running them)
WHY:  The agent might be wrong. It often is.
GOOD: Run the tests, show the output, then claim.
```

**Rule:** Use `/godmode:verify` before every claim.

### Anti-Pattern 8: Bundling Multiple Questions

```
BAD:  "What's the goal, who are the users, what's the tech stack, and what's the timeline?"
WHY:  The user gets overwhelmed. Answers are rushed. Details are missed.
GOOD: "What are you building?" ... wait ... "Who are the primary users?" ... wait ...
```

**Rule:** One question at a time. Listen before asking the next.

### Anti-Pattern 9: Infinite Loops

```
BAD:  No max iteration limit. Optimize forever.
WHY:  Diminishing returns. Costs money. Wastes time.
GOOD: Set max iterations. Detect plateaus. Stop when target is met.
```

**Rule:** Always have a stopping condition.

### Anti-Pattern 10: Cargo Culting from Git History

```
BAD:  "Caching worked in iteration 3, so I'll add caching to everything."
WHY:  Context matters. Caching helped one function; it might hurt another.
GOOD: Read history for inspiration, but validate each change independently.
```

**Rule:** History informs; it doesn't decide.

### Anti-Pattern 11: Ignoring Soft Guard Warnings

```
BAD:  "Coverage dropped 15% but it's a soft guard so who cares."
WHY:  Soft guards exist because the metric matters, just not at the hard-stop level.
GOOD: Investigate soft guard warnings. Fix them if reasonable.
```

**Rule:** Soft guards are warnings, not permissions to regress.

### Anti-Pattern 12: Shipping Without Security Audit

```
BAD:  "Tests pass, let's ship!" (skipping /godmode:secure)
WHY:  Tests verify functionality, not security. SQL injection passes all tests.
GOOD: Always run /godmode:secure before /godmode:ship.
```

**Rule:** Functional correctness is not security.

### Summary Table

| # | Anti-Pattern | One-Line Fix |
|---|-------------|-------------|
| 1 | Vibes-based optimization | Use mechanical metrics |
| 2 | Big bang changes | One change per iteration |
| 3 | Skipping RED step | See the test fail first |
| 4 | Ignoring reverts | Reverts are data; learn from them |
| 5 | Over-guarding | 2-3 hard guards, rest soft |
| 6 | Premature optimization | Build first, optimize second |
| 7 | Claiming without evidence | Run verify before claiming |
| 8 | Bundling questions | One question at a time |
| 9 | Infinite loops | Always set max iterations |
| 10 | Cargo culting history | Validate each change independently |
| 11 | Ignoring soft guards | Investigate warnings |
| 12 | Shipping without audit | Security audit before shipping |

---

## 40. Iteration Budget System

**Purpose:** How to allocate iterations across plan tasks and optimize loops, with auto-budgeting based on complexity.

### Why Budget Iterations?

Without budgeting:
- Simple tasks consume the same iteration count as complex tasks
- Optimization runs forever on diminishing returns
- The user has no sense of "how long will this take?"

With budgeting:
- Each task gets an iteration allowance proportional to complexity
- Optimization stops when the budget runs out (or the target is met)
- The user sees: "Estimated: 45 iterations across 7 tasks"

### Budget Allocation Algorithm

```
Total budget = user-configured max (default: 25 for optimize, 15 for fix)

For optimization:
  Budget = min(user_max, complexity_estimate)

For plan execution:
  Per-task budget = task_estimated_time / 2  (2 min = 1 iteration, 5 min = 2-3)
  Parallel group budget = max(task budgets in group)
  Total budget = sum(group budgets)
```

### Complexity Estimation

The planner estimates task complexity based on:

| Signal | Low (1) | Medium (2-3) | High (4-5) |
|--------|---------|-------------|-----------|
| Files to modify | 1 file | 2-3 files | 4+ files |
| Lines of code | <50 | 50-200 | >200 |
| New dependencies | 0 | 1 | 2+ |
| Has tests | Simple assertions | Multiple scenarios | Mocking, integration |
| Cross-module | Within one module | 2 modules | 3+ modules |

**Budget formula:** `iterations = complexity_score * 2`

### Budget Tracking

During execution, budget is tracked in real-time:

```
Task Budget Tracker:
  Task 001: Redis connection    [████░░] 2/3 iterations (1 remaining)
  Task 002: Config schema       [██████] 1/1 iterations (complete ✓)
  Task 003: Rate limiter        [██░░░░] 2/5 iterations (3 remaining)
  Task 004: Logging             [░░░░░░] 0/2 iterations (not started)
  ─────────────────────────────────────────────────
  Total:                        5/11 iterations used (6 remaining)
```

For optimization:

```
Optimization Budget:
  Used:      4 / 25 iterations
  Kept:      3 (75%)
  Remaining: 21
  Target:    200ms (current: 198ms) — TARGET MET ✓
  Estimated remaining: 0 (target already achieved)
```

### Auto-Budget Based on Complexity

When no explicit iteration limit is set, auto-budget estimates:

```
Auto-Budget Calculation:
  Project size: medium (150 files, 8K LOC)
  Task count: 7
  Average complexity: 2.5
  Optimization scope: 3 files

  Plan execution budget: 14 iterations (7 tasks × 2 avg)
  Optimization budget: 15 iterations (medium scope, reasonable target)
  Fix budget: 10 iterations (based on current error count × 2)

  Total estimated: 39 iterations
  Estimated time: ~20 minutes (at 30s per iteration)
```

### Budget Overruns

When a task or loop exceeds its budget:

| Situation | Action |
|-----------|--------|
| Task exceeds budget by 1 | Allow (soft limit) |
| Task exceeds budget by 2+ | Pause, ask user: "Task 003 has used 7/5 iterations. Continue?" |
| Optimization exceeds budget | Hard stop, report best result |
| Fix loop exceeds budget | Hard stop, report remaining errors |
| Total plan exceeds estimate by 50% | Pause, re-estimate, ask user |

### Budget Display in Plan

The plan includes budget information:

```markdown
### Task 003: Add rate limit middleware

**Budget:** 5 iterations (complexity: high)
**Files:** 3 files (CREATE: 2, MODIFY: 1)
**Estimated time:** 4-6 minutes
```

### Key Behaviors

1. **Budget is a guide, not a prison** — Soft limits allow flexibility; hard limits prevent waste
2. **Complexity drives budget** — Simple tasks get fewer iterations; complex ones get more
3. **Track and display** — Users should always see how much budget remains
4. **Auto-budget is conservative** — Better to underestimate and extend than overestimate and waste
5. **Budget includes reverts** — A reverted iteration still counts against the budget

---

## 41. Metric Discovery Phase

**Purpose:** Integrate metric discovery into the brainstorming phase so that "what does success look like mechanically?" is answered before any code is written.

### The Question

During `/godmode:think`, after understanding the problem and before writing the spec, the agent asks:

> "What does success look like, mechanically? What number would prove this feature works well?"

This is not an optional question. It's the bridge between THINK and OPTIMIZE.

### Metric Discovery Workflow

**Step 1: Ask the User**
- "If this feature is successful, what would we measure to prove it?"
- Listen for: performance goals, quality targets, capacity requirements, user experience metrics

**Step 2: Suggest from Database**
Based on the feature description, suggest relevant metrics from the metric database (Section 23):

```
Your feature "rate limiter" suggests these metrics:
  1. Requests correctly rate-limited (accuracy)
  2. Latency overhead added by the limiter (performance)
  3. Memory usage under load (efficiency)
  4. False positive rate (quality)

Which matters most? Or suggest your own.
```

**Step 3: Validate the Metric**
- Is it mechanical? (command-based, not vibes-based)
- Is it measurable right now? (or after a specific build task)
- Is it fast? (<60 seconds to measure)
- Does the user agree on direction? (higher/lower is better)

**Step 4: Define Guards**
- "What must NOT get worse while we optimize this metric?"
- Suggest default guards based on project type (tests passing, lint clean)
- Validate each guard command

**Step 5: Include in Spec**

The spec template gets a "Metrics" section:

```markdown
## Metrics

### Primary Metric
- **Name:** Requests correctly rate-limited
- **Command:** `npm test -- --grep "rate-limit" | grep passing | awk '{print $1}'`
- **Target:** 100% accuracy (all test cases pass)
- **Direction:** higher_is_better

### Guards
- Tests passing: `npm test` (hard, must not fail)
- Latency overhead: `wrk ... | grep p99` (soft, must not exceed 50ms added)

### When to Measure
- After build: verify accuracy against test cases
- During optimize: measure latency overhead, minimize it
```

### Integration Points

| Phase | How Metrics Are Used |
|-------|---------------------|
| **THINK** | Discover the metric, include in spec |
| **BUILD** | Verify metric baseline after implementation |
| **OPTIMIZE** | Primary metric drives the loop, guards protect |
| **SHIP** | Final metric value included in ship report |

### Metric Evolution

Metrics can change as understanding deepens:

```
Think phase:  "Requests correctly limited" (accuracy)
Build phase:  Baseline measured → 95% accuracy (some edge cases fail)
Optimize phase: Primary metric shifts to "latency overhead" after accuracy reaches 100%
Ship phase:   Both metrics reported in release notes
```

The agent can suggest metric changes:
```
"Accuracy is now 100% and stable. Should we switch the primary
 metric to latency overhead for the optimization phase?"
```

### Common Metric Discovery Conversations

**Backend feature:**
```
Agent: What does success look like mechanically?
User:  It should handle 10K requests per second.
Agent: Got it. We'll measure requests/sec with wrk. What's the baseline?
User:  Currently 8K without rate limiting.
Agent: So the guard is: throughput must not decrease below 8K. And we'll
       add a metric for rate limiting accuracy. Sound right?
```

**Frontend feature:**
```
Agent: What does success look like mechanically?
User:  The page should load fast.
Agent: "Fast" means different things. Which matters most?
       1. First Contentful Paint (perceived speed)
       2. Lighthouse score (overall performance)
       3. Bundle size (payload efficiency)
User:  Lighthouse score above 90.
Agent: Done. Primary metric: Lighthouse performance score. Target: 90.
```

### Key Behaviors

1. **Metrics are discovered, not imposed** — Ask the user; don't assume
2. **Discovered early** — During brainstorming, not after building
3. **Validated immediately** — Run the metric command during discovery
4. **Included in the spec** — The spec is incomplete without a metrics section
5. **Evolve over time** — Metrics can change as the project progresses

---

## 42. Chain System

**Purpose:** Chain skills together with the `--chain` flag so one skill's output feeds directly into the next skill.

### Syntax

```
/godmode:debug --chain fix          # Debug, then auto-fix what was found
/godmode:secure --chain fix         # Audit, then auto-fix findings
/godmode:test --chain fix           # Write tests, then fix failures they reveal
/godmode:build --chain review       # Build task, then review it
/godmode:fix --chain optimize       # Fix all errors, then optimize
/godmode:review --chain secure      # Review, then security audit
```

### How Chains Work

```
/godmode:secure --chain fix

Step 1: Run /godmode:secure
  → Produces security audit report with findings
  → Each finding has severity and recommended fix

Step 2: Automatically invoke /godmode:fix
  → Reads the security report
  → Converts findings into an error list
  → Fixes them one at a time (CRITICAL first, then HIGH, etc.)
  → Verifies each fix doesn't break guards
```

### Chain Compatibility Matrix

Not all skills can chain to all other skills. Valid chains:

| From | Can Chain To | What Passes |
|------|-------------|-------------|
| `debug` | `fix` | Root cause and recommended fix |
| `secure` | `fix` | Security findings as error list |
| `test` | `fix` | Failing test results |
| `fix` | `optimize` | Clean codebase (zero errors) |
| `fix` | `verify` | Fix results for verification |
| `build` | `review` | Task diff for review |
| `build` | `test` | Implementation for test writing |
| `review` | `secure` | Reviewed code for security audit |
| `review` | `fix` | Review findings (BLOCK items) |
| `think` | `plan` | Spec document |
| `plan` | `build` | Plan with tasks |
| `optimize` | `ship` | Optimized code |

Invalid chains are rejected with explanation:
```
/godmode:ship --chain think
Error: Cannot chain ship → think. Shipping is the end of the cycle.
Suggestion: Use /godmode --pipeline full to start a new cycle.
```

### Multi-Chains

Chain multiple skills in sequence:

```
/godmode:secure --chain fix --chain optimize
```

This runs: secure → fix (findings) → optimize (clean code)

### Chain Context Passing

When skills chain, context is passed through `.godmode/chain-context.json`:

```json
{
  "chain_id": "chain-20250115-001",
  "source_skill": "secure",
  "target_skill": "fix",
  "context": {
    "findings": [
      {
        "id": "SEC-001",
        "severity": "CRITICAL",
        "file": "src/routes/users.ts",
        "line": 45,
        "description": "SQL injection in user search",
        "fix": "Use parameterized queries"
      }
    ],
    "total_findings": 6,
    "critical_count": 1,
    "high_count": 2
  }
}
```

The target skill reads this context to understand what to do:
- `fix` reads findings and converts them to its error format
- `optimize` reads the clean state and sets up its baseline
- `review` reads the task diff and starts reviewing

### Chain vs Pipeline

| Feature | Chain (`--chain`) | Pipeline (`--pipeline`) |
|---------|-------------------|------------------------|
| Scope | 2-3 skills | Full phase or custom |
| Context | Passed explicitly | Through handoff artifacts |
| Use case | Quick ad-hoc linking | Standard workflows |
| Example | `debug --chain fix` | `--pipeline harden` |

### Key Behaviors

1. **Chains are optional** — Every skill works standalone
2. **Context is explicit** — The chain-context.json file makes data flow visible
3. **Invalid chains are caught** — Not every combination makes sense
4. **Multi-chain is linear** — A → B → C, not branching
5. **Chains respect budgets** — Each skill in the chain uses its own iteration budget

---

## 43. CI/CD Integration

**Purpose:** How to use Godmode in CI/CD pipelines for automated optimization, security audits, and quality gates.

### Non-Interactive Mode

In CI, there's no human to answer questions. Godmode supports non-interactive mode:

```bash
# All flags provided, no prompts
claude /godmode:secure --scope src/ --severity high --report sarif --non-interactive

# Optimize with all parameters specified
claude /godmode:optimize \
  --metric "npm test 2>&1 | grep passing | awk '{print \$1}'" \
  --guard "npm test" \
  --iterations 10 \
  --target 50 \
  --non-interactive
```

The `--non-interactive` flag:
- Skips all user prompts (uses defaults or provided flags)
- Never asks for confirmation
- Outputs structured results (JSON/SARIF) instead of pretty-printed summaries
- Exits with meaningful exit codes

### Exit Codes

| Code | Meaning | CI Action |
|------|---------|-----------|
| 0 | Success (all checks pass, target met) | Pipeline continues |
| 1 | Failure (checks failed, target not met) | Pipeline fails |
| 2 | Partial (some checks pass, some fail) | Pipeline warns |
| 3 | Error (Godmode itself crashed) | Pipeline errors |
| 4 | Timeout (max iterations reached without target) | Pipeline warns |

### `--fail-on` Flag

Control when the CI step should fail:

```bash
# Fail if any critical security finding
claude /godmode:secure --fail-on critical

# Fail if any BLOCK-level review finding
claude /godmode:review --fail-on block

# Fail if optimization doesn't reach target
claude /godmode:optimize --fail-on target-not-met

# Fail if any test fails
claude /godmode:fix --fail-on errors-remaining
```

### GitHub Actions Example

```yaml
name: Godmode Quality Gate
on: [pull_request]

jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropic/claude-code@v1
      - run: |
          claude /godmode:secure \
            --scope src/ \
            --report sarif \
            --fail-on critical \
            --non-interactive
      - uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: .godmode/security/report.sarif

  code-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: anthropic/claude-code@v1
      - run: |
          claude /godmode:review \
            --scope branch \
            --severity warn \
            --fail-on block \
            --non-interactive

  optimize:
    runs-on: ubuntu-latest
    if: github.event.pull_request.labels.*.name == 'needs-optimization'
    steps:
      - uses: actions/checkout@v4
      - uses: anthropic/claude-code@v1
      - run: |
          claude /godmode:optimize \
            --metric "npm test 2>&1 | grep passing" \
            --guard "npm test" \
            --iterations 10 \
            --non-interactive
```

### GitLab CI Example

```yaml
godmode-secure:
  stage: test
  script:
    - claude /godmode:secure --fail-on high --report json --non-interactive
  artifacts:
    paths:
      - .godmode/security/
```

### Output Formats for CI

| Format | Flag | Use Case |
|--------|------|----------|
| `--report json` | Machine-readable results | Custom CI integrations |
| `--report sarif` | SARIF format | GitHub Code Scanning, VS Code |
| `--report markdown` | Human-readable summary | PR comments |
| `--report junit` | JUnit XML | CI test result displays |

### PR Comment Integration

Godmode can post results as PR comments:

```bash
claude /godmode:secure --report markdown --non-interactive > report.md
gh pr comment $PR_NUMBER --body-file report.md
```

Or with the built-in flag:
```bash
claude /godmode:secure --pr-comment --non-interactive
```

### Resource Limits in CI

| Resource | Default | CI Override |
|----------|---------|------------|
| Max iterations | 25 | `--iterations 10` (lower for CI speed) |
| Timeout per command | 60s | `--timeout 30s` |
| Max parallel agents | 3 | `--parallel 1` (CI runners have limited resources) |
| Model | sonnet | `--model haiku` (cheaper for CI) |

### Key Behaviors

1. **Non-interactive is explicit** — Don't guess; require `--non-interactive` flag
2. **Exit codes matter** — CI pipelines read exit codes, not prose
3. **SARIF for security** — Standard format that integrates with GitHub/GitLab
4. **Lower budgets for CI** — CI runs should be fast; reduce iterations and use cheaper models
5. **Results as artifacts** — Always save reports to `.godmode/` for archival

---

## 44. Testing Strategy for Godmode Itself

**Purpose:** How to test skills, integration flows, and ensure Godmode works correctly — despite being markdown instructions, not executable code.

### The Challenge

Godmode skills are markdown files that instruct an AI agent. You can't unit test a markdown file the way you'd test a function. Testing requires:
1. **Session replay** — Record a session, verify it follows the workflow
2. **Scenario testing** — Set up a project state, invoke a skill, verify outputs
3. **Integration testing** — Run multiple skills in sequence, verify handoffs work

### Test Levels

| Level | What It Tests | How |
|-------|--------------|-----|
| **Schema** | SKILL.md frontmatter is valid | Parse YAML, validate against schema |
| **Structure** | SKILL.md has required sections | Check for "When to Use", "Workflow", "Key Behaviors" |
| **Scenario** | Skill produces correct output in a given context | Session replay in test project |
| **Integration** | Skills chain/handoff correctly | Run pipeline in test project |
| **Regression** | Changes don't break existing behavior | Re-run scenarios after changes |

### Schema Tests

Automated checks that every SKILL.md is well-formed:

```bash
# Test script: tests/validate-schemas.sh
for skill in skills/*/SKILL.md; do
  echo "Validating $skill..."

  # Check frontmatter exists
  grep -q "^---" "$skill" || echo "FAIL: No frontmatter in $skill"

  # Check required frontmatter fields
  for field in name description triggers phase; do
    grep -q "^$field:" "$skill" || echo "FAIL: Missing $field in $skill"
  done

  # Check required sections
  for section in "When to Use" "Workflow" "Key Behaviors"; do
    grep -q "## $section" "$skill" || echo "FAIL: Missing '$section' in $skill"
  done
done
```

### Scenario Tests

Each scenario tests a skill in a controlled environment:

```
tests/
  scenarios/
    think-basic.md          # Basic brainstorming flow
    think-with-visual.md    # Brainstorming with visual companion
    plan-from-spec.md       # Planning from an existing spec
    build-tdd.md            # Build task with TDD enforcement
    optimize-basic.md       # Basic optimization loop
    optimize-plateau.md     # Optimization hitting a plateau
    fix-cascading.md        # Fix with cascading errors
    secure-critical.md      # Security audit finding critical issues
    ship-npm.md             # Ship to npm
    chain-debug-fix.md      # Debug → fix chain
    pipeline-full.md        # Full THINK→BUILD→OPTIMIZE→SHIP
```

### Scenario File Format

```markdown
# Scenario: optimize-basic

## Test Project
Repository: tests/fixtures/express-api/
State: .godmode/state.json has phase=OPTIMIZE, 47 tests passing

## Setup Commands
npm install
npm test  # Verify baseline: 47 passing

## Invocation
/godmode:optimize --metric "npm test 2>&1 | grep passing | awk '{print $1}'" \
  --guard "npm test" --iterations 5 --non-interactive

## Expected Outcomes
1. At least 1 iteration completes
2. results.tsv has entries for each iteration
3. Each entry has: iteration number, timestamp, description, metric values
4. No guard failures (all kept or cleanly reverted)
5. Final metric >= baseline (47)
6. Git log shows "optimize: iteration N" commits

## Verification Commands
test -f .godmode/results.tsv                    # Results file exists
wc -l < .godmode/results.tsv                    # Has at least 2 lines (header + 1)
git log --oneline --grep="optimize:" | wc -l    # At least 1 optimize commit
npm test                                         # Tests still pass
```

### Session Replay Testing

Record a real session, then replay it to verify behavior:

**Recording:**
```bash
# Record all tool calls and responses during a session
claude --record .godmode/test-recordings/think-basic.json /godmode:think
```

**Replay Verification:**
```bash
# Replay and verify key behaviors
python tests/verify-recording.py .godmode/test-recordings/think-basic.json \
  --expect-questions 5 \          # At least 5 questions asked
  --expect-one-at-a-time \        # Only one question per turn
  --expect-approaches 3 \         # 3 approaches proposed
  --expect-spec-written \         # Spec file created
  --expect-commit "spec:"         # Commit with spec: prefix
```

### Integration Tests

Test that skills chain together correctly:

```markdown
# Integration Test: THINK → PLAN → BUILD

## Steps
1. /godmode:think (provide canned answers for non-interactive testing)
   → Verify: spec exists in .godmode/specs/
2. /godmode:plan --spec .godmode/specs/test-spec.md
   → Verify: plan exists in .godmode/plan.md, tasks have required fields
3. /godmode:build --task task-001
   → Verify: test file created before implementation, review run
```

### Test Fixtures

Pre-built project fixtures for testing:

```
tests/fixtures/
  express-api/          # Node.js Express API with tests
  python-ml/            # Python ML project with pytest
  go-cli/               # Go CLI tool with go test
  empty-project/        # Empty project (for setup testing)
  failing-tests/        # Project with known test failures (for fix testing)
  insecure-code/        # Project with known vulnerabilities (for secure testing)
```

### Key Behaviors

1. **Schema tests are automated** — Run on every PR, catch formatting issues early
2. **Scenario tests are the primary test** — They verify the skill actually works
3. **Integration tests catch handoff bugs** — The most common failure mode
4. **Fixtures are maintained** — Broken fixtures break all tests
5. **Session replay is gold** — A real recorded session is the best test of a skill

---

## 45. Marketplace Metadata

**Purpose:** Define the `.claude-plugin/marketplace.json` schema that enables Godmode to be listed in the Claude Code skill marketplace.

### Plugin Manifest (`.claude-plugin/manifest.json`)

```json
{
  "schema_version": "1.0",
  "name": "godmode",
  "display_name": "Godmode",
  "version": "1.3.0",
  "description": "Turn on Godmode for Claude Code. Complete development workflow from idea to shipped product.",
  "author": {
    "name": "Godmode AI",
    "url": "https://github.com/godmode-ai/godmode",
    "email": "hello@godmode.dev"
  },
  "license": "MIT",
  "repository": "https://github.com/godmode-ai/godmode",
  "homepage": "https://godmode.dev",
  "skills": [
    {
      "path": "SKILL.md",
      "command": "/godmode",
      "description": "Auto-detect phase and route to the right skill"
    },
    {
      "path": "skills/think/SKILL.md",
      "command": "/godmode:think",
      "description": "Collaborative brainstorming with spec writing"
    }
    // ... (all 16 skills listed)
  ],
  "hooks": [
    {
      "path": "hooks/session-start.md",
      "event": "session_start"
    },
    {
      "path": "hooks/lifecycle.md",
      "event": "lifecycle"
    }
  ],
  "compatibility": {
    "claude_code": ">=1.0.0",
    "platforms": ["macos", "linux", "windows"]
  },
  "dependencies": [],
  "keywords": ["development", "workflow", "optimization", "tdd", "security", "shipping"]
}
```

### Marketplace Metadata (`.claude-plugin/marketplace.json`)

```json
{
  "listing": {
    "title": "Godmode",
    "tagline": "Turn on Godmode for Claude Code",
    "short_description": "Complete development workflow — brainstorm, plan, build with TDD, optimize autonomously, and ship with confidence.",
    "long_description": "Godmode gives your AI agent a disciplined development workflow from idea to shipped product. It combines structured brainstorming from superpowers with autonomous optimization loops from autoresearch. 16 skills across 4 phases: THINK, BUILD, OPTIMIZE, SHIP.",
    "icon": "assets/icon.png",
    "banner": "assets/banner.png",
    "screenshots": [
      {
        "path": "assets/screenshots/brainstorm.png",
        "caption": "Structured brainstorming with approach comparison"
      },
      {
        "path": "assets/screenshots/optimize.png",
        "caption": "Autonomous optimization with metric tracking"
      },
      {
        "path": "assets/screenshots/security.png",
        "caption": "Security audit with STRIDE + OWASP"
      }
    ],
    "demo_gif": "assets/demo.gif"
  },
  "categories": ["Development Workflow", "Testing", "Security", "DevOps"],
  "tags": ["tdd", "optimization", "security", "shipping", "brainstorming", "planning"],
  "stats": {
    "skill_count": 16,
    "file_count": 50,
    "phases": ["THINK", "BUILD", "OPTIMIZE", "SHIP"]
  },
  "pricing": "free",
  "featured": false,
  "maturity": "stable",
  "support": {
    "issues": "https://github.com/godmode-ai/godmode/issues",
    "discussions": "https://github.com/godmode-ai/godmode/discussions",
    "docs": "https://godmode.dev/docs"
  }
}
```

### Icon Spec

- **Size:** 256x256px
- **Format:** PNG with transparency
- **Design:** Clean, recognizable at 32x32 (marketplace thumbnail)
- **Theme:** Lightning bolt or power-up aesthetic (Godmode = power mode)

### Banner Spec

- **Size:** 1280x640px
- **Format:** PNG
- **Content:** Plugin name, tagline, and visual representation of the THINK→BUILD→OPTIMIZE→SHIP loop

### Validation

The marketplace validates:
1. `manifest.json` has all required fields
2. All skill paths exist
3. Version follows semver
4. Icon and banner files exist and meet size requirements
5. Description is under 500 characters (short) / 2000 characters (long)
6. No broken links in support URLs

### Key Behaviors

1. **Marketplace-first distribution** — The primary way users find Godmode
2. **Rich listing** — Screenshots, demo GIF, and detailed description
3. **Version pinning** — Users can install specific versions
4. **Update notifications** — Marketplace notifies users of new versions
5. **Free and open source** — MIT license, no paid tiers

---

## 46. Example Workflows

**Purpose:** 5 complete end-to-end examples showing the full THINK → BUILD → OPTIMIZE → SHIP cycle in different contexts.

### Example 1: Add Rate Limiting to an Express API

```
SESSION START
─────────────
Godmode: You're in a Node.js Express project. No existing state.

User: /godmode

Godmode: No spec or plan found. Recommending /godmode:think.
         What are you building?

User: I need to add rate limiting to our API

─── THINK PHASE ──────────────────────────────────────────
/godmode:think

Q1: Is this for all endpoints or specific ones?
A: All endpoints, but different limits for auth vs public

Q2: What load are you expecting?
A: ~10K requests per minute in production

Q3: Do you already have Redis or another shared store?
A: Yes, Redis is already in the stack

Approaches:
  1. Token Bucket with Redis (recommended for your setup)
  2. Sliding Window Log
  3. Express middleware library (express-rate-limit)

User picks: #1 with elements of #3

What does success look like mechanically?
→ Primary metric: All rate limit tests pass (accuracy)
→ Optimization metric: p95 latency overhead < 5ms
→ Guard: Existing 47 tests still pass

Spec written → .godmode/specs/rate-limiter.md
Commit: spec: rate-limiter initial design

─── BUILD PHASE ──────────────────────────────────────────
/godmode:plan --spec .godmode/specs/rate-limiter.md

Plan: 6 tasks, ~20 minutes estimated
  Task 001: Redis rate limit key schema (2 min)
  Task 002: Token bucket implementation (5 min)
  Task 003: Express middleware wrapper (3 min)
  Task 004: Per-endpoint config (3 min)
  Task 005: Rate limit headers (2 min)
  Task 006: Integration tests (5 min)

User approves plan.
Commit: plan: rate-limiter — 6 tasks, estimated 20min

/godmode:build --continue

Task 001: [RED] Write test → FAIL → [GREEN] Implement → PASS → [REVIEW] Clean ✓
Task 002: [RED] Write test → FAIL → [GREEN] Implement → PASS → [REVIEW] 1 WARN fixed ✓
Task 003: [RED] Write test → FAIL → [GREEN] Implement → PASS → [REVIEW] Clean ✓
  (Tasks 004+005 in parallel)
Task 004: ✓  |  Task 005: ✓
Task 006: Integration tests → 15 tests, all passing ✓

Commit: build: all 6 tasks complete (62 tests passing)

─── OPTIMIZE PHASE ───────────────────────────────────────
/godmode:optimize --metric "wrk latency p95" --guard "npm test" --target "5ms overhead"

Iteration 1: Add connection pooling → 12ms → 8ms (-33%) ✓ KEPT
Iteration 2: Pipeline Redis commands → 8ms → 4ms (-50%) ✓ KEPT
Target met! (4ms < 5ms)

/godmode:secure --scope src/middleware/

Findings: 0 critical, 1 medium (rate limit bypass via IP spoofing)
Fix: Validate X-Forwarded-For header chain
Commit: secure: audit clean (1 medium fixed)

─── SHIP PHASE ───────────────────────────────────────────
/godmode:ship --type npm

Pre-flight: ✓ 62 tests | ✓ lint clean | ✓ security clean
Version: 2.1.0 (MINOR — new feature)
Changelog: auto-generated
Dry run: ✓
Ship: npm publish ✓
Verify: npm view api-server@2.1.0 ✓

/godmode:finish --action pr

PR created: "feat: add rate limiting middleware (#45)"
```

### Example 2: Optimize a Slow Python ML Pipeline

```
User: /godmode:optimize --metric "python train.py --time-only" \
  --guard "pytest" --target "120s" --iterations 15

Baseline: Training takes 340s

Iteration 1: Vectorize feature computation → 340s → 245s (-28%) ✓
Iteration 2: Add data caching → 245s → 198s (-19%) ✓
Iteration 3: Switch to float32 from float64 → 198s → 185s (-7%) ✓
Iteration 4: Parallel data loading → 185s → 142s (-23%) ✓
Iteration 5: Batch normalization optimization → 142s → 139s (-2%) ✗ REVERTED
Iteration 6: Reduce model complexity → 142s → 115s (-19%) ✓

Target met! 115s < 120s
Total: 340s → 115s (-66% improvement) in 6 iterations
```

### Example 3: Debug and Fix Flaky Tests

```
User: /godmode:debug --bug "test suite has 3 intermittent failures" --chain fix

Investigation:
  H1: Race condition in async tests → CONFIRMED (2 tests)
  H2: Time-dependent assertion → CONFIRMED (1 test)

Root causes:
  1. Shared database state between test files (no cleanup)
  2. setTimeout-based test relies on wall clock

Chaining to /godmode:fix...

Fix 1: Add beforeEach cleanup → 3 failing → 1 failing ✓
Fix 2: Replace setTimeout with fake timers → 1 failing → 0 failing ✓

All tests stable across 5 consecutive runs.
Commit: fix: resolve 3 flaky tests (shared state + time dependency)
```

### Example 4: Security Hardening Sprint

```
User: /godmode --pipeline harden

/godmode:test --target src/ --coverage
  Added 23 tests, coverage: 62% → 81%

/godmode:secure --scope src/
  Found: 1 critical (SQLi), 2 high (XSS, IDOR), 4 medium

/godmode:fix (chained from secure)
  Fixed: 7/7 findings in 7 iterations (0 reverts)

/godmode:optimize --metric "security findings count" --target 0
  Already at 0! Verifying with re-audit...
  Re-audit: 0 critical, 0 high, 0 medium ✓

Sprint complete: 23 tests added, 7 security issues fixed, 0 remaining.
```

### Example 5: Full Cycle for a New Feature (Frontend)

```
User: /godmode --pipeline full

THINK: Brainstorm dark mode toggle
  Spec: CSS custom properties approach, localStorage persistence
  Metric: Lighthouse accessibility score > 95

PLAN: 5 tasks
  1. CSS custom properties theme system
  2. Toggle component
  3. localStorage persistence
  4. System preference detection
  5. Transition animations

BUILD: All 5 tasks complete (TDD, 18 tests)
  Review: 1 WARN (missing prefers-reduced-motion check) → fixed

OPTIMIZE: Lighthouse score
  Baseline: 88
  Iteration 1: Add prefers-color-scheme media query → 88 → 91 ✓
  Iteration 2: Reduce CSS specificity → 91 → 94 ✓
  Iteration 3: Add aria labels to toggle → 94 → 97 ✓
  Target exceeded! (97 > 95)

SHIP: vercel deploy
  Pre-flight: ✓ | Ship: ✓ | Verify: site loads with dark mode ✓

Cycle complete! Dark mode feature shipped.
Total: 45 minutes, 12 iterations, 18 tests added.
```

---

## 47. Comparison Matrix

**Purpose:** Feature-by-feature comparison showing what Godmode takes from Autoresearch, what it takes from Superpowers, and what's new.

### Feature Comparison

| Feature | Autoresearch | Superpowers | Godmode |
|---------|:----------:|:-----------:|:-------:|
| **THINK Phase** | | | |
| Structured brainstorming | - | Yes | Yes |
| One question at a time | - | Yes | Yes |
| Visual companion | - | Yes | Yes |
| Multi-persona prediction | Yes | - | Yes |
| Edge case exploration | Yes | - | Yes |
| Spec writing | - | Yes | Yes |
| Metric discovery during thinking | - | - | **NEW** |
| **BUILD Phase** | | | |
| Task decomposition (2-5 min) | - | Yes | Yes |
| Dependency graph | - | Yes | Yes |
| TDD enforcement | - | Yes | Yes |
| Parallel agent dispatch | - | Yes | Yes |
| Git worktrees | - | Yes | Yes |
| 2-stage code review | - | Yes | Yes |
| Model matching for agents | - | - | **NEW** |
| **OPTIMIZE Phase** | | | |
| Autonomous iteration loop | Yes | - | Yes |
| Git-as-memory | Yes | - | Yes |
| Mechanical metrics only | Yes | - | Yes |
| Guard system | Yes | - | Yes (enhanced) |
| Auto-revert on failure | Yes | - | Yes |
| Results logging (TSV) | Yes | - | Yes |
| Scientific debugging | Yes | - | Yes |
| One fix per iteration | Yes | - | Yes |
| STRIDE threat modeling | Yes | - | Yes |
| OWASP Top 10 checks | Yes | - | Yes |
| Red-team personas | Yes | - | Yes |
| Soft guards | - | - | **NEW** |
| Plateau detection | - | - | **NEW** |
| Strategy switching | - | - | **NEW** |
| **SHIP Phase** | | | |
| 8-phase shipping | Yes | - | Yes |
| 9 shipment types | Yes | - | Yes |
| Branch finalization | - | Yes | Yes |
| 4 completion options | - | Yes | Yes |
| Post-ship verification | Yes | - | Yes |
| Auto-changelog | - | - | **NEW** |
| **META** | | | |
| Orchestrator / auto-detection | - | - | **NEW** |
| Configuration wizard | Yes | - | Yes (enhanced) |
| Evidence-before-claims | - | Yes | Yes |
| Hook system | - | - | **NEW** |
| Chain system | - | - | **NEW** |
| Pipeline definitions | - | - | **NEW** |
| CI/CD integration | - | - | **NEW** |
| Iteration budgets | - | - | **NEW** |
| **CROSS-CUTTING** | | | |
| Platform support | Claude Code | Claude Code | Multi-platform |
| Handoff protocol | - | - | **NEW** |
| Crash recovery | Partial | - | **NEW** |
| Skill discovery | - | - | **NEW** |
| Visual dashboard | - | Partial | Enhanced |
| Domain adaptation | - | - | **NEW** |

### What Godmode Adds Beyond Both

| New Feature | Why It Matters |
|-------------|---------------|
| **Orchestrator** | Users don't have to know which skill to use; Godmode figures it out |
| **Handoff protocol** | Seamless transitions between phases; no context lost |
| **Chain system** | Ad-hoc skill linking without full pipelines |
| **Metric discovery** | Success criteria defined before code is written |
| **Soft guards** | Flexible protection without over-constraining |
| **Iteration budgets** | Predictable time and cost |
| **CI/CD mode** | Use Godmode in pipelines, not just interactive |
| **Platform adapters** | Works beyond Claude Code |
| **Crash recovery** | Agent can resume after failures |
| **Hook system** | Customizable automation at lifecycle events |

### Philosophy Comparison

| Aspect | Autoresearch | Superpowers | Godmode |
|--------|-------------|-------------|---------|
| **Focus** | Optimization | Creation | Full cycle |
| **Autonomy** | High (autonomous loops) | Guided (user drives) | Adaptive (auto or guided) |
| **Memory** | Git commits | Session context | Git + state files |
| **Verification** | Mechanical metrics | Evidence gate | Both |
| **Organization** | Single skill file | Multiple skill files | Plugin with 16 skills |
| **Iteration** | Endless until target | Task-based | Budgeted with stopping conditions |

---

## 48. Roadmap

**Purpose:** Feature plans for v1.0, v1.1, and v2.0 releases.

### v1.0 — Foundation (Initial Release)

**Goal:** Ship the core THINK → BUILD → OPTIMIZE → SHIP cycle with all 16 skills.

| Feature | Status | Priority |
|---------|--------|----------|
| Orchestrator (`/godmode`) | Planned | P0 |
| Think skill (brainstorm + spec) | Planned | P0 |
| Plan skill (task decomposition) | Planned | P0 |
| Build skill (TDD + review) | Planned | P0 |
| Optimize skill (autonomous loop) | Planned | P0 |
| Ship skill (8-phase workflow) | Planned | P0 |
| Fix skill (error remediation) | Planned | P0 |
| Verify skill (evidence gate) | Planned | P0 |
| Setup skill (config wizard) | Planned | P0 |
| Debug skill (bug hunting) | Planned | P1 |
| Test skill (standalone TDD) | Planned | P1 |
| Review skill (standalone review) | Planned | P1 |
| Secure skill (security audit) | Planned | P1 |
| Predict skill (multi-persona) | Planned | P1 |
| Scenario skill (edge cases) | Planned | P1 |
| Finish skill (branch finalization) | Planned | P1 |
| Git-as-memory system | Planned | P0 |
| Guard system (hard guards only) | Planned | P0 |
| Results logging (TSV) | Planned | P0 |
| Handoff protocol | Planned | P0 |
| Configuration schema | Planned | P0 |
| Session start hook | Planned | P1 |
| Schema validation tests | Planned | P1 |

**Target:** 8-10 weeks of development

### v1.1 — Enhancement

**Goal:** Add advanced features requested from early adopters.

| Feature | Description |
|---------|-------------|
| Soft guards | Warning-level guards that don't auto-revert |
| Chain system (`--chain`) | Link skills together |
| Pipeline definitions | Pre-built skill sequences |
| Visual companion | Browser-based brainstorm canvas + progress dashboard |
| Parallel agent dispatch | Multi-agent execution with worktrees |
| Model matching | Auto-select model based on task complexity |
| Metric suggestion database | Pre-built metrics for common scenarios |
| Iteration budgets | Auto-budget based on complexity |
| Crash recovery | Resume from failed sessions |
| Cursor adapter | `.cursorrules` file for Cursor compatibility |

**Target:** 4-6 weeks after v1.0

### v1.2 — CI/CD & Platform

**Goal:** Make Godmode usable in CI pipelines and on more platforms.

| Feature | Description |
|---------|-------------|
| Non-interactive mode | `--non-interactive` flag for CI |
| `--fail-on` flags | Control CI exit codes |
| SARIF output | Security findings in GitHub Code Scanning format |
| JUnit output | Test results in CI-compatible format |
| GitHub Actions example | Ready-to-use workflow file |
| Codex adapter | System prompt for OpenAI Codex |
| OpenCode adapter | Plugin for OpenCode |
| Gemini CLI adapter | System prompt for Gemini |

**Target:** 3-4 weeks after v1.1

### v2.0 — Intelligence

**Goal:** Make Godmode smarter with cross-project learning and advanced optimization strategies.

| Feature | Description |
|---------|-------------|
| Cross-project metric database | Learn which optimizations work for which project types |
| Strategy library | Named optimization strategies (hill-climb, simulated annealing, explore) |
| Automatic strategy selection | Choose strategy based on metric behavior |
| Skill marketplace | Users can share custom skills |
| Custom persona system | User-defined prediction personas |
| Multi-metric optimization | Optimize multiple metrics simultaneously with Pareto frontier |
| Time-series analysis | Detect metric trends, predict plateau timing |
| Cost tracking | Track API costs per skill, per iteration |
| Team collaboration | Shared `.godmode/` state across team members |
| Web dashboard | Full web UI (not just companion) |

**Target:** 8-12 weeks after v1.2

### Release Timeline

```
v1.0  ──────→  v1.1  ────→  v1.2  ───→  v2.0
Foundation    Enhancement    CI/CD      Intelligence
(8-10 wk)    (+4-6 wk)     (+3-4 wk)  (+8-12 wk)
```

### Key Behaviors

1. **v1.0 is complete** — Every core skill works end-to-end; no stubs
2. **v1.1 is about polish** — Advanced features that make the experience smoother
3. **v1.2 is about reach** — CI/CD and platform support expand the user base
4. **v2.0 is about intelligence** — Learning across projects and sessions
5. **Community drives priorities** — Post-v1.0, roadmap is shaped by user feedback

---

## 49. License & Legal

### License: MIT

Godmode is released under the MIT License — the most permissive common open-source license.

```
MIT License

Copyright (c) 2025 Godmode AI Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### Attribution

Godmode stands on the shoulders of two excellent projects:

**Autoresearch** by Udit Goenka
- Repository: https://github.com/uditgoenka/autoresearch
- License: MIT
- Contributions: Autonomous iteration loops, git-as-memory, mechanical verification, guard system, security audit (STRIDE+OWASP), debug/fix workflows, shipping workflow, configuration wizard
- Attribution: "Optimization loop and verification framework inspired by autoresearch"

**Superpowers** by Jesse Vincent (obra)
- Repository: https://github.com/obra/superpowers
- License: MIT
- Contributions: Structured brainstorming, TDD enforcement, planning with small tasks, parallel agent dispatch, code review protocol, evidence-before-claims, branch finalization, visual companion
- Attribution: "Structured development workflow inspired by superpowers"

### How to Attribute

In any derivative work, include:

```
This project uses Godmode (https://github.com/godmode-ai/godmode),
which combines ideas from autoresearch by Udit Goenka and
superpowers by Jesse Vincent.
```

### What Users Can Do

Under MIT, users can:
- Use Godmode commercially (no restrictions)
- Modify and customize skills
- Create derivative works
- Redistribute (with attribution)
- Sell services built on Godmode

### What Users Must Do

- Include the MIT license in distributions
- Include the copyright notice

### What We Don't Cover

- **User's code:** Godmode doesn't claim any rights to code generated by the AI agent using Godmode skills. The user owns their code.
- **AI output:** Output generated during brainstorming, planning, and reviewing belongs to the user.
- **Configuration:** User settings and project state (`.godmode/`) are the user's data.

### Contributor License

Contributors to Godmode agree that their contributions are released under the same MIT license. No CLA required.

---

## 50. Design Summary & Architecture Diagram

### The Complete Picture

Godmode is a 16-skill Claude Code plugin organized into 4 phases. Every skill is a markdown file. Skills communicate through files on disk. Git is memory. Metrics are truth.

### Architecture Diagram (ASCII)

```
┌──────────────────────────────────────────────────────────────────────┐
│                        GODMODE ORCHESTRATOR                         │
│                          /godmode command                            │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
│  │ Auto-Detect   │ │ Smart Route  │ │ State Manager│ │ Hook System│ │
│  │ Project state │ │ Phase→Skill  │ │ .godmode/    │ │ Pre/Post   │ │
│  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘ │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          ▼                    ▼                    ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   THINK PHASE   │ │   BUILD PHASE   │ │ OPTIMIZE PHASE  │
│                 │ │                 │ │                 │
│ ┌─────────────┐ │ │ ┌─────────────┐ │ │ ┌─────────────┐ │
│ │   think     │ │ │ │    plan     │ │ │ │  optimize   │ │
│ │ (brainstorm)│ │ │ │ (decompose) │ │ │ │ (8-phase    │ │
│ └─────────────┘ │ │ └─────────────┘ │ │ │  loop)      │ │
│ ┌─────────────┐ │ │ ┌─────────────┐ │ │ └─────────────┘ │
│ │  predict    │ │ │ │   build     │ │ │ ┌─────────────┐ │
│ │ (5 personas)│ │ │ │ (TDD+review)│ │ │ │   debug     │ │
│ └─────────────┘ │ │ └─────────────┘ │ │ │ (7 methods) │ │
│ ┌─────────────┐ │ │ ┌─────────────┐ │ │ └─────────────┘ │
│ │  scenario   │ │ │ │    test     │ │ │ ┌─────────────┐ │
│ │ (12 dims)   │ │ │ │ (RED-GREEN) │ │ │ │    fix      │ │
│ └─────────────┘ │ │ └─────────────┘ │ │ │ (1 per iter)│ │
│                 │ │ ┌─────────────┐ │ │ └─────────────┘ │
│                 │ │ │   review    │ │ │ ┌─────────────┐ │
│                 │ │ │ (severity)  │ │ │ │   secure    │ │
│                 │ │ └─────────────┘ │ │ │ (STRIDE+    │ │
│                 │ │                 │ │ │  OWASP)     │ │
│                 │ │                 │ │ └─────────────┘ │
└────────┬────────┘ └────────┬────────┘ └────────┬────────┘
         │                   │                    │
         │    Handoff        │    Handoff         │    Handoff
         │    Protocol       │    Protocol        │    Protocol
         ▼                   ▼                    ▼
                    ┌─────────────────┐
                    │   SHIP PHASE    │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │    ship     │ │
                    │ │ (8 phases)  │ │
                    │ └─────────────┘ │
                    │ ┌─────────────┐ │
                    │ │   finish    │ │
                    │ │ (4 options) │ │
                    │ └─────────────┘ │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  META SKILLS    │
                    │ (always active) │
                    │                 │
                    │ • setup         │
                    │ • verify        │
                    │ • hooks         │
                    └─────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                     CROSS-CUTTING SYSTEMS                           │
│                                                                      │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
│  │ Git-as-Memory│ │  Mechanical  │ │ Guard System │ │  Results   │ │
│  │              │ │ Verification │ │              │ │  Logging   │ │
│  │ • Commits as │ │              │ │ • Hard guards│ │            │ │
│  │   memory     │ │ • Metrics    │ │ • Soft guards│ │ • TSV log  │ │
│  │ • History    │ │ • Validation │ │ • Max retry  │ │ • Progress │ │
│  │   learning   │ │ • Tolerance  │ │ • Auto-revert│ │ • Reports  │ │
│  │ • Reverts as │ │ • Database   │ │              │ │ • Archive  │ │
│  │   lessons    │ │              │ │              │ │            │ │
│  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘ │
│                                                                      │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
│  │   Parallel   │ │   Visual     │ │    Crash     │ │ Iteration  │ │
│  │   Dispatch   │ │  Companion   │ │   Recovery   │ │  Budgets   │ │
│  │              │ │              │ │              │ │            │ │
│  │ • Worktrees  │ │ • Canvas     │ │ • Resume     │ │ • Auto-est │ │
│  │ • Model match│ │ • Dashboard  │ │ • Checkpoint │ │ • Track    │ │
│  │ • Merge      │ │ • WebSocket  │ │ • Dirty state│ │ • Overrun  │ │
│  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

### Data Flow Summary

```
User Input
    │
    ▼
Orchestrator (auto-detect phase, route to skill)
    │
    ▼
Skill Execution (follows SKILL.md workflow)
    │
    ├── Reads: state.json, git history, references
    ├── Produces: artifacts (specs, plans, reports, code)
    ├── Verifies: mechanical metrics, guards
    └── Commits: everything to git
    │
    ▼
Handoff (artifacts + state → next skill)
    │
    ▼
Next Phase
```

### Design Principles Recap

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Discipline before speed | TDD, review gates, security audits before shipping |
| 2 | Autonomy within constraints | Agent works alone, bounded by guards, budgets, and max iterations |
| 3 | Git is memory | Every action committed, reverts are lessons, history informs decisions |
| 4 | Mechanical metrics only | No vibes; every claim backed by a command that outputs a number |
| 5 | One change per iteration | Atomic changes enable learning and safe rollback |
| 6 | Evidence before claims | Run the command, read the output, then claim success |
| 7 | Skills communicate through files | No hidden state; everything is on disk and in git |
| 8 | Graceful degradation | Missing features fall back safely; no hard crashes |

### By the Numbers

| Metric | Value |
|--------|-------|
| Total skills | 16 |
| Phases | 4 (THINK, BUILD, OPTIMIZE, SHIP) + META |
| Reference files | ~20 |
| Shared files | ~4 |
| Total plugin files | ~50 |
| Configuration fields | ~30 |
| Exploration dimensions | 12 (scenario) |
| Expert personas | 5 (predict) |
| Investigation techniques | 7 (debug) |
| Shipping phases | 8 (ship) |
| Shipment types | 9 (ship) |
| Anti-patterns documented | 12 |
| Example workflows | 5 |
| Design sections | 50 |

---

## 61. Internationalization Skills

### `/godmode:i18n` — Internationalization & Localization

**Purpose:** Prepare codebases for multi-language, multi-locale, multi-region support with production-grade i18n infrastructure.

**Core capabilities:**
- **String extraction:** Scan for hardcoded UI strings, extract to resource files (JSON, YAML, .strings, .xml, ARB) with translator context and key naming conventions
- **Framework selection:** Recommend and configure i18n libraries per stack (react-intl, vue-i18n, @angular/localize, NSLocalizedString, Android Resources, i18next, flutter_localizations)
- **Pluralization:** CLDR-compliant plural rules (not binary if/else) using ICU MessageFormat — handles English (2 forms), Arabic (6 forms), Polish (4 forms), Japanese (1 form)
- **Date/number/currency formatting:** Replace locale-unaware formatting with Intl API — DateTimeFormat, NumberFormat, currency with correct symbol position and decimal conventions
- **RTL support:** Convert directional CSS to logical properties (margin-inline-start, padding-inline-end, text-align: start), configure HTML dir attribute, mirror directional icons
- **Character set validation:** UTF-8 enforcement (utf8mb4 for MySQL), grapheme cluster awareness, Unicode normalization (NFC vs NFD), Intl.Collator for locale-aware sorting
- **Translation workflow:** Extract → translate (professional, TMS, machine+review, community) → import → validate (completeness, placeholders, HTML balance, length)
- **i18n testing:** Pseudo-localization (accent characters, 30-40% padding), RTL layout verification, locale-specific formatting, edge cases (CJK, emoji, mixed scripts)

**Invocation:** `/godmode:i18n`, "internationalize", "translate", "add language support", "localization", "RTL support"

**Key principle:** Extract and configure, don't translate. The skill builds the i18n infrastructure; actual translation is a human/service task. ICU MessageFormat is preferred over simpler formats because it handles plurals, gender, and select constructs that simpler systems cannot.

---

## 62. Code Quality & Analysis Skills

### `/godmode:quality` — Code Quality & Analysis

**Purpose:** Measure, catalog, and prioritize code quality issues across duplication, complexity, technical debt, dependency structure, and license compliance.

**Core capabilities:**
- **Code duplication detection:** AST-based structural comparison finding Type 1 (exact), Type 2 (parameterized), and Type 3 (structural) clones with extraction recommendations and duplication ratio scoring (< 3% excellent, > 20% critical)
- **Cyclomatic complexity:** Count linearly independent paths (if/else, loops, switch cases, boolean operators, ternary) with threshold of 10 per function
- **Cognitive complexity:** Measure human comprehension difficulty with nesting penalties, threshold of 15 per function, remediation via extract method, guard clauses, pipeline replacement
- **Technical debt identification:** Five categories — code smells (Long Method, God Class, Feature Envy), architecture debt (layering violations, missing abstractions), test debt (untested paths, brittle tests), documentation debt (undocumented APIs, stale docs), dependency debt (outdated, vulnerable, unused)
- **Debt prioritization:** Impact x Likelihood / Effort matrix producing ranked action list with estimated hours per item
- **Dependency analysis:** Fan-in/fan-out mapping, instability index (I = fan-out / (fan-in + fan-out)), Stable Abstract Principle violation detection
- **Circular dependency detection:** Identify dependency cycles with three breaking strategies — dependency inversion, extract shared module, event-based decoupling
- **License compliance:** Inventory all dependency licenses, flag GPL/AGPL/UNLICENSED/UNKNOWN conflicts, provide replacement recommendations for incompatible packages

**Invocation:** `/godmode:quality`, "code quality", "technical debt", "code smell", "complexity analysis", "dependency check", "license audit"

**Key principle:** Measure, don't guess. Every complexity score is calculated, every duplication located, every dependency mapped. Prioritize ruthlessly — not all debt is worth fixing. Use the Impact x Likelihood / Effort matrix to focus effort where it matters most.

---

## 63. Mobile Development Skills

### `/godmode:mobile` — Mobile App Development

**Purpose:** Build, configure, sign, optimize, and ship iOS and Android applications with platform-aware guidance for native and cross-platform approaches.

**Core capabilities:**
- **Platform assessment:** Evaluate native vs cross-platform tradeoffs, recommend approach (Swift, Kotlin, React Native, Flutter, Kotlin Multiplatform) based on project requirements, team skills, and performance needs
- **Architecture patterns:**
  - MVVM (Model-View-ViewModel): reactive UI with observable state, ViewModel as presentation logic layer, repository abstraction for data access
  - MVI (Model-View-Intent): unidirectional data flow with immutable state, sealed intent classes, separated side effects, time-travel debugging
  - Clean Architecture: three-layer separation (Presentation, Domain, Data) with dependency rule pointing inward, domain layer has zero external dependencies
- **Project setup:** Platform-specific configuration — Xcode project settings (bundle ID, ATS, privacy descriptions, schemes), Gradle configuration (variants, ProGuard, signing configs), React Native (TypeScript, navigation, state management, Hermes), Flutter (flavors, code generation, localization)
- **App signing:** iOS certificates and provisioning profiles (development, ad hoc, App Store, enterprise), Android keystores with Google Play App Signing, CI/CD keychain setup, security best practices (never commit keys)
- **App store submission:** Complete checklists for App Store (privacy labels, screenshots, metadata, archive/upload) and Play Store (data safety, store listing, AAB build, release tracks), review timeline expectations
- **Mobile performance:** Battery optimization (significant-change location, BGTaskScheduler/WorkManager, batch networking), memory management (image resize/cache, view recycling, retain cycle prevention, LeakCanary), network optimization (offline-first, compression, certificate pinning, exponential backoff), startup performance (< 1s cold start target, deferred init, binary size reduction)

**Invocation:** `/godmode:mobile`, "mobile app", "iOS", "Android", "React Native", "Flutter", "app store", "mobile performance"

**Key principle:** Platform-aware recommendations always. iOS and Android have different conventions, APIs, and review guidelines. Performance budgets (startup, memory, app size) are set at project start and measured at every milestone. Signing keystores are irreplaceable — treat them like production database credentials.

---

## 64. Performance Profiling Skills

### `/godmode:perf` — Performance Profiling & Optimization

**Purpose:** Identify performance bottlenecks through CPU profiling, memory leak detection, concurrency bug hunting, and statistically rigorous benchmarking.

**Core capabilities:**
- **CPU profiling & flame graphs:** Language-specific profiling tools (node --cpu-prof, py-spy, go tool pprof, cargo flamegraph, JFR/async-profiler, Instruments Time Profiler, perf/valgrind) with flame graph generation and interpretation — plateau analysis (wide tops = CPU hotspots), tower analysis (deep stacks = excessive abstraction), common patterns (JSON serialization, regex compilation in loops, GC pressure, lock contention)
- **Memory leak detection:** Heap snapshot diffing methodology — baseline → load → snapshot comparison. Tools per language (Chrome DevTools, tracemalloc, pprof heap, DHAT, Eclipse MAT, Instruments Leaks, Valgrind memcheck). Retention chain analysis proving why objects cannot be collected. Growth pattern classification (linear = classic leak, stepped = periodic, logarithmic = unbounded cache)
- **Allocation tracking:** Identify excessive allocation hotspots, object pooling recommendations, pre-allocation strategies, GC tuning guidance
- **Concurrency bug detection:**
  - Race conditions: shared mutable state without synchronization, TOCTOU patterns, read-modify-write without atomics. Tools: go test -race, ThreadSanitizer, miri
  - Deadlocks: lock ordering violations (A→B vs B→A), unbounded waits, channel deadlocks, connection pool exhaustion. Prevention: consistent lock ordering, try-lock with timeout, channels over shared memory
  - Detection tools per language with reproduction scenario documentation
- **Benchmarking methodology:** Statistical rigor required — warm-up iterations discarded, multiple measurement runs, report mean/median/stddev/percentiles, 95% confidence intervals, coefficient of variation for stability assessment. Comparison protocol: interleaved A/B runs, Welch's t-test for significance (p < 0.05), effect size with confidence intervals. Tools: Benchmark.js, pytest-benchmark, testing.B+benchstat, criterion, JMH, hyperfine

**Invocation:** `/godmode:perf`, "profile", "memory leak", "race condition", "deadlock", "benchmark", "flame graph", "slow", "bottleneck"

**Key principle:** Profile before optimizing — developers' intuition about bottlenecks is wrong more often than right. Statistical rigor is mandatory for benchmarks: a single measurement is noise, not data. Every remediation includes before/after measurements with confidence intervals. Concurrency bugs need exact interleaving scenarios, not "it sometimes crashes."

---

## Status: COMPLETE — Design + Implementation

## Document Complete

This design document covers all 50 sections of the Godmode Claude Code skill plugin.
It is intended to be a complete implementation guide — someone should be able to build
Godmode from this document alone.

## Implementation Complete (Iterations 51-100)

The following artifacts have been created as production-ready implementations:

### Skills (16 SKILL.md files)
- `skills/godmode/SKILL.md` — Orchestrator
- `skills/think/SKILL.md` — Brainstorming
- `skills/predict/SKILL.md` — Multi-persona evaluation
- `skills/scenario/SKILL.md` — Edge case exploration
- `skills/plan/SKILL.md` — Task decomposition
- `skills/build/SKILL.md` — TDD execution
- `skills/test/SKILL.md` — TDD enforcement
- `skills/review/SKILL.md` — Code review
- `skills/optimize/SKILL.md` — Autonomous loop
- `skills/debug/SKILL.md` — Scientific debugging
- `skills/fix/SKILL.md` — Error remediation
- `skills/secure/SKILL.md` — Security audit
- `skills/ship/SKILL.md` — Shipping workflow
- `skills/finish/SKILL.md` — Branch finalization
- `skills/setup/SKILL.md` — Configuration wizard
- `skills/verify/SKILL.md` — Evidence gate

### Commands (9 command files)
### Agents (2 agent definitions)
### Reference documents (7 detailed references)
### Infrastructure (hooks, config, marketplace metadata)
### Documentation (getting started, examples, domain guide, chaining, CI/CD, architecture)

**Total files created: 52**
**Total iterations: 100 (50 design + 50 implementation)**

**Godmode: Turn on Godmode for Claude Code.**

---

## 51. Database & Data Management Skills

Three new skills extend Godmode into the database and data engineering domain, ensuring developers never need a separate tool for schema management, query optimization, or data pipeline work.

### 51.1 Migrate — Database Migration & Schema Management (`skills/migrate/SKILL.md`)

**Purpose:** Generate, validate, and apply database migrations with production-grade safety.

**Key capabilities:**
- **Auto-detection:** Scans the project to identify the ORM/migration tool (Prisma, Drizzle, TypeORM, Sequelize, Django, Rails, Go-migrate, Alembic, Flyway, Liquibase, Knex, or raw SQL) and database engine.
- **Risk classification:** Every schema change is classified as SAFE, CAUTION, DANGEROUS, or BREAKING before any migration is generated.
- **Backward compatibility:** BREAKING changes (column renames, drops, type changes) trigger the expand-contract pattern — add new alongside old, backfill, then remove old — preventing production outages.
- **Rollback testing:** Every UP migration is validated by running UP, DOWN, UP to confirm reversibility and idempotency.
- **Lock estimation:** For large tables, estimates DDL lock duration and recommends CONCURRENTLY or online DDL tools when needed.
- **Data preservation:** Verifies row counts and sample data before/after migration to ensure no data loss.

**Workflow:** Detect environment -> Analyze change -> Assess risk -> Generate migration (UP + DOWN) -> Validate (syntax, rollback, data preservation, lock estimate) -> Apply with verification -> Report.

**Command:** `/godmode:migrate` (`commands/godmode/migrate.md`)

### 51.2 Query — Query Optimization & Data Analysis (`skills/query/SKILL.md`)

**Purpose:** Analyze, optimize, and debug database queries with measured before/after improvement.

**Key capabilities:**
- **EXPLAIN interpretation:** Reads EXPLAIN ANALYZE output line by line across PostgreSQL, MySQL, SQLite, SQL Server, and MongoDB, extracting scan types, join strategies, buffer usage, and row estimate accuracy.
- **Red flag detection:** Identifies sequential scans on large tables, N+1 patterns, stale statistics, over-fetching (SELECT *), inefficient joins, OFFSET pagination, and functions on indexed columns.
- **Index recommendations:** Recommends specific index types (B-tree, GIN, GiST, BRIN, partial, covering) with column order rationale, write-overhead trade-offs, and storage estimates.
- **Query rewriting:** Transforms correlated subqueries to JOINs, replaces DISTINCT-after-JOIN with EXISTS, converts OFFSET pagination to keyset, and eliminates function-on-column anti-patterns.
- **ORM-level fixes:** Detects N+1 patterns in Prisma, Django, Rails, SQLAlchemy, and Sequelize code and provides the idiomatic eager-loading fix for each.
- **Multi-engine support:** SQL databases, MongoDB (explain with executionStats), Redis (SLOWLOG, O(N) command detection), and Elasticsearch.

**Workflow:** Identify context -> Run EXPLAIN -> Interpret plan -> Diagnose issues -> Recommend and implement fixes -> Verify with before/after measurement -> Report.

**Command:** `/godmode:query` (`commands/godmode/query.md`)

### 51.3 Pipeline — Data Pipeline & ETL (`skills/pipeline/SKILL.md`)

**Purpose:** Design, build, test, and debug data pipelines from simple cron scripts to orchestrated multi-stage flows.

**Key capabilities:**
- **Pipeline architecture:** Selects the right pattern (batch, streaming, micro-batch, CDC, ELT) based on SLA, volume, and freshness requirements.
- **Tool detection:** Identifies Airflow, dbt, Dagster, Prefect, Luigi, Kafka, Spark, and custom setups from project files.
- **Extraction patterns:** Watermark-based incremental extraction, API pagination with rate limiting, file-based deduplication, and database change tracking.
- **Transformation design:** Pure transformation functions (no side effects) that are independently testable and composable via pipe chains.
- **Loading strategies:** Upsert, swap (atomic table rename), append, and SCD Type 2 — each idempotent so backfills are safe.
- **Data quality:** Row-level validation (nulls, uniqueness, ranges, patterns, referential integrity), dataset-level checks (row count anomalies, completeness, distribution drift, timeliness), and cross-pipeline reconciliation (source-target count and aggregate matching).
- **Error handling:** Dead-letter queues, retry with exponential backoff, checkpointed resume, and circuit breakers for flaky sources.
- **Observability:** Structured logging per stage, pipeline metrics (duration, rows processed, rejection rate, freshness), and alerting rules.
- **Testing:** Unit tests for transformations, integration tests end-to-end, and idempotent backfill verification.
- **Orchestrator output:** Generates Airflow DAGs, dbt projects, Dagster asset definitions, or Prefect flows matching the detected environment.

**Workflow:** Map data flow -> Detect environment -> Design architecture -> Implement components (extract, transform, load) -> Add quality checks -> Configure error handling -> Set up observability -> Generate orchestrator config -> Test (unit, integration, backfill) -> Report.

**Command:** `/godmode:pipeline` (`commands/godmode/pipeline.md`)

### Summary of Additions

| Artifact | Path | Iteration |
|----------|------|-----------|
| Migrate skill | `skills/migrate/SKILL.md` | 101 |
| Query skill | `skills/query/SKILL.md` | 102 |
| Pipeline skill | `skills/pipeline/SKILL.md` | 103 |
| Migrate command | `commands/godmode/migrate.md` | 104 |
| Query command | `commands/godmode/query.md` | 105 |
| Pipeline command | `commands/godmode/pipeline.md` | 106 |
| Design doc update | `docs/godmode-design.md` | 106 |

**Total new files: 6 (3 skills + 3 commands)**
**Iterations 101-106**

---

## 59. Incident & Error Handling Skills

Two new skills extend Godmode into production operations — managing incidents when things go wrong and tracking errors before they become incidents.

### Incident Response & Post-Mortem (`/godmode:incident`)

**Purpose:** Structured incident management from detection through post-mortem.

**Workflow:**
1. **Classify** — Severity levels SEV1-4 with defined response times and escalation rules
2. **Timeline** — Precise, timestamped record of events with attached evidence (logs, dashboards, deploy records)
3. **Impact** — Quantified blast radius: users affected, duration, revenue impact, SLA budget consumed
4. **Root Cause** — 5 Whys technique to identify true root cause and contributing factors
5. **Post-Mortem** — Blameless document covering What Went Well, What Went Wrong, and Where We Got Lucky
6. **Action Items** — Concrete, assigned, deadline-bound items categorized as PREVENT, DETECT, MITIGATE, or PROCESS
7. **Metrics** — MTTD, MTTA, MTTR, MTBF tracking over time

**Severity Levels:**
| Level | Impact | Response |
|-------|--------|----------|
| SEV1 | Complete outage, data loss, security breach | Immediate (< 15 min) |
| SEV2 | Major degradation, critical feature broken | < 30 min |
| SEV3 | Partial degradation, workaround exists | < 2 hours |
| SEV4 | Cosmetic, minimal user impact | Next business day |

**Key Principle:** Blameless or useless. Name systems, not people. Focus on process gaps, not human error.

**Chaining:** `/godmode:incident` → `/godmode:plan` (schedule remediation) → `/godmode:build` (implement fixes)

### Error Tracking & Analysis (`/godmode:errortrack`)

**Purpose:** Aggregate, categorize, and analyze application errors at scale before they become incidents.

**Workflow:**
1. **Aggregate** — Collect errors from Sentry, Bugsnag, DataDog, CloudWatch, and application logs
2. **Categorize** — Group into: unhandled exceptions, network/timeout, validation, auth, database, third-party, resource exhaustion, business logic
3. **Stack Trace Grouping** — Normalize frames, group by exception type + top application frames (not by message text)
4. **Root Cause Correlation** — Temporal, code, and statistical correlation with deploys, config changes, and upstream events
5. **Trend Analysis** — New errors, resolved, regressions, fastest-growing error groups
6. **Error Budgets** — Track against SLO targets with burn-rate alerts and policy (green/yellow/orange/red/exhausted)
7. **Triage** — Prioritize by impact score: users affected, frequency, severity weight

**Error Budget Policy:** When budget is green, ship freely. When red, deploy freeze. No judgment calls — the policy decides.

**Chaining:** `/godmode:errortrack` → `/godmode:debug` (investigate P0 errors) → `/godmode:incident` (if active outage)

---

## 60. ML & Data Science Skills

Two new skills bring structured machine learning workflows into Godmode — from experiment tracking through production model serving.

### ML Development & Experimentation (`/godmode:ml`)

**Purpose:** Manage the full ML experiment lifecycle with reproducibility, rigor, and bias awareness.

**Workflow:**
1. **Experiment Definition** — Hypothesis, objective, baseline, task type, dataset, framework, compute requirements
2. **Hyperparameter Management** — Structured YAML configs with search strategies (grid, random, Bayesian, Hyperband, population-based)
3. **Dataset Validation** — Schema checks, quality metrics, class distribution, data leakage detection, drift checks
4. **Bias Detection** — Per-attribute performance analysis with fairness metrics (demographic parity, equalized odds, predictive parity)
5. **Training Tracking** — Live metrics, checkpoint management, early stopping, GPU utilization
6. **Model Evaluation** — Per-class metrics, calibration analysis, confidence analysis, error pattern categorization
7. **Experiment Comparison** — Side-by-side metrics with statistical significance testing (paired bootstrap)

**Key Principle:** Reproducibility is non-negotiable. Every experiment records: code version (git SHA), data version, hyperparameters, random seeds, and environment.

**Bias Policy:** A model that performs well on average but poorly for a protected group is not ready to deploy. Bias is a deployment blocker, not a nice-to-have.

**Chaining:** `/godmode:ml` → `/godmode:mlops` (deploy best model) → `/godmode:ml` (retrain when drift detected)

### MLOps & Model Deployment (`/godmode:mlops`)

**Purpose:** Move models from experimentation to reliable production serving with monitoring and automation.

**Workflow:**
1. **Readiness Assessment** — Functional (metrics, latency, size), operational (health check, validation, fallback), compliance (model card, data provenance, privacy)
2. **Serving Infrastructure** — TensorFlow Serving, NVIDIA Triton, AWS SageMaker, or custom (FastAPI/Ray Serve)
3. **Inference Optimization** — FP16/INT8 quantization, ONNX conversion, TensorRT, pruning, distillation with accuracy/latency tradeoff benchmarks
4. **Batching Strategies** — Static, dynamic, and adaptive batching with benchmark-driven configuration
5. **Model Versioning** — Lifecycle management: STAGED → CANARY → CHAMPION → SHADOW → ARCHIVED → RETIRED
6. **A/B Testing** — Controlled experiments with traffic splitting, guardrail metrics, and statistical significance gates
7. **Drift Detection** — Feature drift (KS test, PSI, chi-squared), concept drift (performance degradation), severity classification
8. **Retraining Automation** — Scheduled, drift-based, or performance-based triggers with validation gates before promotion

**Deployment Flow:**
```
Train → Readiness Check → Deploy Canary (5%) → A/B Test → Promote Champion
                                                    ↓
                                          Monitor → Drift → Retrain
```

**Key Principle:** Automate retraining, but gate deployment. The retraining pipeline can run automatically. The promotion to champion must pass validation (A/B test or human review).

**Chaining:** `/godmode:mlops` → `/godmode:ml` (retrain) → `/godmode:mlops --promote` (promote new champion)

---

## 53. Frontend & UI Skills

Three new skills extend Godmode's capabilities into frontend quality, visual consistency, and UI architecture.

### 53.1 Accessibility Testing & Auditing (`/godmode:a11y`)

**Purpose:** Ensure WCAG 2.1 AA/AAA compliance through automated scanning and manual audit.

**Workflow:**
1. Define audit scope (pages, components, interactive flows)
2. Run automated scanners (Axe-core, Pa11y, Lighthouse accessibility)
3. Execute WCAG 2.1 manual checklist across all four principles:
   - **Perceivable** — text alternatives, color contrast (4.5:1 AA, 7:1 AAA), adaptable content
   - **Operable** — keyboard navigation, no traps, skip links, focus visibility, touch targets
   - **Understandable** — lang attributes, predictable behavior, input assistance, error messages
   - **Robust** — valid HTML, correct ARIA roles/states/properties, assistive technology compatibility
4. Deep-dive color contrast analysis (every foreground/background pair)
5. Keyboard navigation audit (tab order, keyboard patterns per component type)
6. Screen reader testing (landmarks, headings, form labels, live regions, dynamic content)
7. Auto-fix common issues (missing alt, orphaned labels, heading gaps, lang attribute)
8. Produce findings with severity, WCAG criterion, code evidence, and remediation

**Severity model:** CRITICAL (complete blocker for AT users), HIGH (significant barrier), MEDIUM (degraded experience), LOW (minor inconvenience).

**Verdict:** PASS (no CRITICAL/HIGH, Lighthouse >= 90), CONDITIONAL PASS (no CRITICAL, HIGH with mitigation plan), FAIL (any CRITICAL or Lighthouse < 70).

**Integration points:**
- Pre-ship gate in `/godmode:ship`
- Post-build check after UI changes
- Storybook addon validation via `/godmode:ui`

**Flags:** `--aaa`, `--component <name>`, `--page <url>`, `--contrast-only`, `--keyboard-only`, `--screen-reader`, `--fix`, `--ci`

### 53.2 Visual Regression Testing (`/godmode:visual`)

**Purpose:** Detect unintended visual changes through screenshot comparison, cross-browser testing, and design compliance validation.

**Workflow:**
1. Assess visual testing infrastructure (Playwright, BackstopJS, Chromatic, Percy)
2. Identify components under test with variant/state/breakpoint matrix
3. Capture baseline screenshots or load existing baselines
4. Run pixel-level visual diff against baselines with configurable threshold (default 1%)
5. Cross-browser comparison (Chromium, Firefox, WebKit) — flag unexpected rendering differences
6. Responsive breakpoint testing (320px through 1920px) — catch layout breaks
7. Design compliance validation (token usage vs hardcoded values, spacing, colors, typography)
8. Produce diff report with before/after screenshots and root cause analysis

**Threshold model:** 0-1% diff = PASS, 1-5% diff = REVIEW, >5% diff = FAIL. Dimension mismatches always fail.

**Verdict:** PASS (all within threshold), REVIEW NEEDED (minor changes require human confirmation), FAIL (significant unexpected regressions).

**Integration points:**
- Pre-ship gate for UI-heavy projects
- Post-CSS-refactor validation
- Design system update verification
- CI pipeline with exit code on failure

**Flags:** `--changed-only`, `--component <name>`, `--browser <name>`, `--breakpoint <width>`, `--update-baselines`, `--design-check`, `--threshold <N>`, `--ci`

### 53.3 UI Component Architecture (`/godmode:ui`)

**Purpose:** Analyze and improve component library design, design system consistency, Storybook integration, and CSS architecture.

**Workflow:**
1. Analyze current UI architecture (framework, styling, component count, Storybook status)
2. Audit component composition using Atomic Design hierarchy (atoms, molecules, organisms, templates, pages)
3. Evaluate CSS architecture fit (CSS Modules vs Tailwind vs CSS-in-JS vs SCSS) with decision matrix
4. Audit design token coverage — detect hardcoded colors, spacing, z-index, shadows
5. Assess Storybook coverage (stories, docs, controls, a11y addon per component)
6. Validate component quality (typing, ref forwarding, display names, loading/error/empty states)
7. Enforce naming conventions and API consistency (variant, size, children, on<Event>)
8. Auto-fix common violations (token replacement, ref forwarding, display names)
9. Generate component scaffolding with all standard files

**Design token audit:** Scans for hardcoded values that should use tokens. Reports violations by category (colors, typography, spacing, border-radius, shadows, z-index, transitions).

**CSS architecture recommendation:** Based on project context (framework, SSR requirements, team size, theming needs), recommends the optimal CSS approach with justification.

**Storybook audit:** Measures coverage across stories, autodocs, controls, and a11y addon. Components without stories are flagged.

**Integration points:**
- Feeds into `/godmode:a11y` for accessibility validation
- Feeds into `/godmode:visual` for visual regression baselines
- Component generation via `--generate <name>`
- Design system initialization via `--init`

**Flags:** `--component <name>`, `--tokens`, `--storybook`, `--css-decision`, `--structure`, `--patterns`, `--fix`, `--init`, `--generate <name>`

### 53.4 Skill Interactions

The three Frontend & UI skills form a quality pipeline:

```
/godmode:ui ──→ /godmode:a11y ──→ /godmode:visual ──→ /godmode:ship
(architecture)   (accessibility)    (visual fidelity)   (deployment)
```

- **UI** establishes the component structure and design system
- **A11y** ensures every component is accessible
- **Visual** ensures every component renders correctly across browsers
- **Ship** uses all three as pre-flight quality gates

Each skill can run independently or as part of the pipeline. The orchestrator (`/godmode`) routes to the appropriate skill based on context.

---

## 52. API Design & Integration Skills

### Overview

Two new skills extend Godmode into the API design and integration testing domain. These skills address the full API lifecycle: from initial design and specification through consumer contract verification and breaking change detection.

### Skill: `/godmode:api` — API Design & Specification

**Purpose:** Design, document, and validate APIs with production-quality specifications.

**Capabilities:**
- **Multi-protocol design:** REST, GraphQL, and gRPC API design with protocol-specific conventions and idioms
- **OpenAPI/Swagger generation:** Produces complete OpenAPI 3.1 specifications with schemas, security definitions, parameters, and example request/response pairs
- **Versioning strategies:** Supports URL path versioning, header versioning, query parameter versioning, and content negotiation — with deprecation policy and sunset headers
- **Rate limiting design:** Tiered rate limiting with token bucket/sliding window algorithms, response headers (X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset), and 429 error responses
- **Pagination patterns:** Offset/limit, cursor-based, and keyset pagination with configurable defaults and maximums
- **Error response standardization:** Consistent error schema with machine-readable codes, field-level validation details, request IDs, and documentation URLs
- **Design validation:** 15-point checklist covering naming conventions, HTTP method usage, status codes, auth, idempotency, and more

**Workflow:** Discovery -> Resource Modeling -> Endpoint Design -> Versioning -> Pagination -> Error Responses -> Rate Limiting -> OpenAPI Generation -> Validation -> Artifacts

**Artifacts produced:**
- `docs/api/<service>-openapi.yaml` — Complete OpenAPI 3.1 specification
- `docs/api/<service>-api-design.md` — Human-readable API design document

**Flags:** `--type rest|graphql|grpc`, `--validate`, `--spec`, `--versioning <strategy>`, `--pagination <strategy>`, `--diff <v1> <v2>`, `--mock`

### Skill: `/godmode:contract` — Contract Testing

**Purpose:** Verify API compatibility between producers and consumers using consumer-driven contract testing.

**Capabilities:**
- **Consumer-driven contracts:** Define what each consumer expects from the producer using Pact, Spring Cloud Contract, or custom frameworks
- **Mock server generation:** Generate mock servers from contracts so consumers can test against realistic stubs without a running provider
- **Provider verification:** Verify that the producer satisfies all consumer contracts with provider state handlers for precondition setup
- **Breaking change detection:** Compare API versions (OpenAPI diff, buf breaking for gRPC, graphql-inspector for GraphQL) and identify removed endpoints, renamed fields, changed types
- **Compatibility matrix:** Cross-consumer/cross-version matrix showing which consumers are compatible with which provider versions
- **CI/CD integration:** Pipeline configuration for automated contract testing with Pact Broker can-i-deploy checks before every deployment
- **Deployment safety:** Block deployments that would break existing consumers

**Workflow:** Discovery -> Consumer Contract Definition -> Mock Server Generation -> Provider Verification -> Breaking Change Detection -> Compatibility Matrix -> Report -> CI/CD Integration

**Artifacts produced:**
- `tests/contracts/<consumer>-<provider>.pact.spec.ts` — Consumer contract test files
- `tests/mocks/<provider>-stubs/` — Mock server configuration
- `docs/api/compatibility-matrix.md` — Cross-consumer compatibility matrix
- `docs/api/<provider>-contract-report.md` — Verification report

**Flags:** `--consumer <name>`, `--provider <name>`, `--breaking`, `--mock`, `--matrix`, `--publish`, `--can-i-deploy`, `--framework pact|spring`, `--ci`

### Integration with Existing Skills

The API skills integrate into the Godmode workflow at these points:

```
/godmode:think  ->  /godmode:api  ->  /godmode:contract  ->  /godmode:plan  ->  /godmode:build
     |                   |                    |                     |                  |
  Brainstorm        Design the          Define consumer       Decompose into     Implement
  the API idea      API spec            contracts & mocks     tasks with TDD     the endpoints
```

- **From `/godmode:think`:** After brainstorming an API approach, invoke `/godmode:api` to formalize the design
- **From `/godmode:api` to `/godmode:contract`:** After designing the API, define consumer contracts and generate mocks
- **From `/godmode:contract` to `/godmode:plan`:** After contracts are defined, plan the implementation tasks
- **From `/godmode:secure`:** The security audit validates auth, rate limiting, and input validation designed by `/godmode:api`
- **From `/godmode:ship`:** The ship workflow checks contract compatibility (can-i-deploy) before deployment
- **From `/godmode:review`:** Code review flags API inconsistencies and refers to `/godmode:api --validate`

### Design Principles for API Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Spec before code | Never implement an API without a validated specification |
| 2 | Consumer-driven contracts | Consumers define expectations; providers prove compliance |
| 3 | Consistency across endpoints | One error format, one naming convention, one auth pattern |
| 4 | Version from day one | Every API is versioned from the first endpoint |
| 5 | Contracts are tests, not docs | Contracts run in CI, fail builds, and block deployments |
| 6 | Matchers over exact values | Contracts use type/regex matchers, never hardcoded values |
| 7 | Breaking changes are visible | Every PR that touches API routes gets a breaking change check |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/api/SKILL.md` | Skill | API design and specification workflow |
| `skills/contract/SKILL.md` | Skill | Contract testing workflow |
| `commands/godmode/api.md` | Command | Usage reference for `/godmode:api` |
| `commands/godmode/contract.md` | Command | Usage reference for `/godmode:contract` |

**Iterations 107-110 (4 files, 2 skills, 2 commands)**

---

## 54. Infrastructure & DevOps Skills

Infrastructure and DevOps skills bring production-grade operational capabilities to Godmode. These five skills cover the full lifecycle of deploying, running, and maintaining software in production environments.

### Skills Overview

| Skill | Command | Purpose |
|-------|---------|---------|
| Infra | `/godmode:infra` | Infrastructure as Code — Terraform, CloudFormation, Pulumi, CDK |
| K8s | `/godmode:k8s` | Kubernetes & Container Orchestration — Helm, deployments, scaling |
| Observe | `/godmode:observe` | Monitoring & Observability — Metrics, logging, tracing, alerts, SLOs |
| Secrets | `/godmode:secrets` | Secrets Management — Vault, rotation, leak detection, auditing |
| CICD | `/godmode:cicd` | CI/CD Pipeline Design — GitHub Actions, GitLab CI, optimization |

### Infra — Infrastructure as Code

The `infra` skill manages cloud infrastructure through code. It supports four IaC toolchains (Terraform, CloudFormation, Pulumi, CDK) and enforces policy-as-code with OPA and Sentinel.

**Core workflow:**
1. Discover infrastructure context (tool, provider, state backend)
2. Validate IaC definitions (syntax, schema, configuration)
3. Enforce security policies (no public buckets, encryption required, least-privilege IAM)
4. Estimate monthly cost with delta from current spend
5. Detect drift between IaC definitions and deployed resources
6. Run IaC tests (unit with Terratest, integration, compliance with InSpec)
7. Generate safe deployment plan with resource counts
8. Apply with post-deployment verification

**Key principles:**
- Never apply without reviewing the plan
- Policy enforcement is mandatory, not optional
- Every change includes cost estimation
- Drift is a bug — detect and reconcile immediately
- Secrets never appear in IaC definitions

### K8s — Kubernetes & Container Orchestration

The `k8s` skill handles container deployment, scaling, and troubleshooting on Kubernetes clusters.

**Core workflow:**
1. Discover cluster context (namespace, workloads, Helm releases)
2. Generate or validate deployment manifests and Helm charts
3. Select deployment strategy (rolling update, canary, blue-green)
4. Configure resource requests/limits, health probes, HPA, PDB
5. Validate manifests (kubeval, kubesec, kube-linter)
6. Deploy with rollout verification
7. Troubleshoot common issues (CrashLoopBackOff, OOMKilled, ImagePullBackOff)

**Deployment strategies:**
- **Rolling Update** — zero-downtime default with maxSurge/maxUnavailable control
- **Canary** — progressive traffic shifting (5% -> 20% -> 50% -> 100%) with automated analysis via Argo Rollouts or Flagger
- **Blue-Green** — instant switch with full rollback capability

**Key principles:**
- Always set resource requests AND limits
- All three health probes are mandatory (liveness, readiness, startup)
- Never use `latest` image tag — pin versions
- PodDisruptionBudget required for production workloads

### Observe — Monitoring & Observability

The `observe` skill instruments applications with the three pillars of observability and configures alerting and SLOs.

**Core workflow:**
1. Assess current observability coverage (score out of 10)
2. Design metrics using RED method (requests) and USE method (resources)
3. Configure structured JSON logging with correlation IDs
4. Instrument distributed tracing with OpenTelemetry
5. Define SLOs with error budget tracking and multi-window burn rate alerts
6. Create actionable alert rules with runbook links
7. Design dashboards following the Four Golden Signals

**Supported tools:**
- Metrics: Prometheus, DataDog, CloudWatch
- Logging: ELK Stack, Loki + Grafana, CloudWatch Logs
- Tracing: Jaeger, Zipkin, Tempo, X-Ray, OpenTelemetry
- Alerting: Prometheus Alertmanager, PagerDuty, OpsGenie

**Key principles:**
- Three pillars are mandatory — metrics, logs, and traces
- Structured logs only — no unstructured console.log
- Alerts must be actionable with runbook links
- SLOs drive feature vs. reliability decisions
- Never use high-cardinality labels on metrics

### Secrets — Secrets Management

The `secrets` skill prevents credential exposure, manages secret stores, and enforces rotation policies.

**Core workflow:**
1. Inventory all secrets (env vars, config files, hardcoded values)
2. Scan codebase and git history for leaked secrets (gitleaks, truffleHog)
3. Set up centralized secret stores (Vault, AWS SM, GCP SM, Azure KV)
4. Manage .env files safely (.env.example as template, .gitignore enforcement)
5. Enforce rotation schedules and flag overdue credentials
6. Audit secret access patterns and flag anomalies
7. Install pre-commit hooks to prevent future leaks

**Defense in depth:**
- Pre-commit hooks (gitleaks) catch leaks locally
- CI pipeline scanning catches missed hooks
- GitHub push protection catches everything else
- Secret manager provides rotation, auditing, and access control

**Key principles:**
- Leaked secrets are emergencies — revoke first, then fix code
- Never commit secrets, even temporarily
- .env.example is documentation — keep it in sync
- Rotation is not optional — credentials age like milk
- Each service gets its own identity with least-privilege access

### CICD — CI/CD Pipeline Design

The `cicd` skill creates and optimizes continuous integration and delivery pipelines.

**Core workflow:**
1. Discover project CI/CD requirements (language, tests, deploy targets)
2. Design pipeline architecture (lint -> test -> build -> security -> deploy)
3. Generate platform-specific configuration (GitHub Actions, GitLab CI, CircleCI, Jenkins)
4. Configure caching (dependencies, Docker layers, build artifacts)
5. Set up test sharding for parallel execution
6. Create matrix builds for multi-version testing
7. Build reusable pipeline templates and composite actions
8. Optimize with performance analysis (before/after comparison)

**Optimization techniques:**
- Dependency caching with lockfile hash keys
- Docker BuildKit layer caching
- Test sharding across parallel workers
- Concurrent stages for independent jobs
- Concurrency control to cancel redundant runs
- Shallow clones for faster checkout

**Key principles:**
- Fast feedback first — lint before test, fail on cheapest checks
- Cache aggressively — every second saved multiplies across every push
- Environments as gates — staging auto-deploys, production requires approval
- Timeouts are mandatory — no hung pipelines wasting compute
- Secrets are injected, never stored in pipeline config

### Workflow Integration

The Infrastructure & DevOps skills integrate with the existing Godmode workflow:

```
/godmode:plan    -> Design the feature
/godmode:build   -> Implement with TDD
/godmode:test    -> Verify correctness
/godmode:secure  -> Security audit
/godmode:infra   -> Provision infrastructure
/godmode:k8s     -> Deploy to Kubernetes
/godmode:observe -> Set up monitoring
/godmode:secrets -> Secure credentials
/godmode:cicd    -> Automate the pipeline
/godmode:ship    -> Ship to production
```

### Design Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Infrastructure as code | All infrastructure defined in version-controlled files |
| 2 | Policy as code | Security and compliance rules enforced automatically |
| 3 | Observable by default | Every service ships with metrics, logs, and traces |
| 4 | Secrets are ephemeral | Short-lived credentials, automated rotation, audited access |
| 5 | Pipelines are fast | Caching, sharding, and parallelism by default |
| 6 | Environments are isolated | Separate state, credentials, and configuration per environment |
| 7 | Deployments are reversible | Canary, blue-green, and instant rollback strategies |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/infra/SKILL.md` | Skill | Infrastructure as Code workflow |
| `skills/k8s/SKILL.md` | Skill | Kubernetes & Container Orchestration workflow |
| `skills/observe/SKILL.md` | Skill | Monitoring & Observability workflow |
| `skills/secrets/SKILL.md` | Skill | Secrets Management workflow |
| `skills/cicd/SKILL.md` | Skill | CI/CD Pipeline Design workflow |
| `commands/godmode/infra.md` | Command | Usage reference for `/godmode:infra` |
| `commands/godmode/k8s.md` | Command | Usage reference for `/godmode:k8s` |
| `commands/godmode/observe.md` | Command | Usage reference for `/godmode:observe` |
| `commands/godmode/secrets.md` | Command | Usage reference for `/godmode:secrets` |
| `commands/godmode/cicd.md` | Command | Usage reference for `/godmode:cicd` |

**Iterations 117-126 (10 files, 5 skills, 5 commands)**

---

## 57. Documentation & Knowledge Skills

### Overview
Skills for capturing, maintaining, and discovering technical decisions, project documentation, and proposals. This category ensures institutional knowledge is preserved and accessible.

### Skills in this Category

#### `/godmode:adr` — Architecture Decision Records
**Purpose:** Document, discover, and maintain architectural decisions with structured records.

**Core capabilities:**
- **ADR creation:** Structured template with status, context, decision, alternatives considered (each with pros/cons/why rejected), and consequences (positive, negative, neutral)
- **Status lifecycle:** Proposed -> Accepted -> Deprecated/Superseded. Accepted ADRs are immutable — supersede with a new ADR, never edit
- **Discovery:** Search and list past decisions by keyword, status, or date. Answer "why did we choose X?" from the decision log
- **Audit:** Review all ADRs for staleness by cross-referencing against current codebase. Flag decisions that conflict with actual code
- **Supersession chain:** When replacing a decision, link new ADR to old one, update old ADR status to "Superseded by ADR-XXX"

**Invocation:** `/godmode:adr`, "document this decision", "why did we choose", "architecture decision", "decision log"

**Output:** `docs/adr/<NNN>-<kebab-case-title>.md` with commit `"adr: ADR-<NNN> — <title> (<status>)"`

**Flags:** `--list`, `--audit`, `--status <status>`, `--search <keyword>`, `--supersede <NNN>`, `--template`

#### `/godmode:docs` — Documentation Generation & Maintenance
**Purpose:** Generate and maintain all forms of project documentation with staleness detection.

**Core capabilities:**
- **API documentation:** Scan routes/controllers to generate OpenAPI 3.0 specs with request/response schemas, auth requirements, and error responses
- **Code documentation:** Generate JSDoc (TypeScript/JS) or docstrings (Python) for all public exports. Derive descriptions from actual code, examples from test files
- **README generation:** Produce READMEs from package metadata, config files, and entry points with installation, quick start, API reference, and configuration sections
- **Runbook creation:** Create operational runbooks from CI/CD configs, deploy scripts, and infrastructure code. Every step is a copy-pasteable command with expected output
- **Quality audit:** Cross-reference all docs against codebase to detect stale references, broken links, outdated examples, and coverage gaps
- **Obsolescence detection:** Compare doc modification dates against code modification dates, flag docs older than their subject

**Invocation:** `/godmode:docs`, "generate docs", "update documentation", "write a README", "create runbook"

**Output:** Documentation files in appropriate locations with commit `"docs: <scope> — <summary>"`

**Flags:** `--api`, `--code`, `--readme`, `--runbook <topic>`, `--audit`, `--coverage`, `--fix-links`, `--format <fmt>`

#### `/godmode:rfc` — RFC & Proposal Writing
**Purpose:** Write, manage, and track technical proposals with stakeholder review and decision timelines.

**Core capabilities:**
- **Structured RFC template:** Metadata, summary, problem statement with evidence, proposed solution with implementation plan, alternatives (always including "Do Nothing"), risks with mitigations, security/performance considerations, testing strategy, open questions, decision log
- **RFC classification:** Feature (3-day review), Architecture (5-day), Process (5-day), Deprecation (5-day), Migration (7-day), Standard (7-day)
- **Stakeholder review:** Track reviewer status (pending/approved/concerns), comment counts, blocking issues, and resolution
- **Decision timeline:** Log every event from creation through acceptance/rejection with dates and details
- **Lifecycle management:** Draft -> In Review -> Accepted/Rejected/Withdrawn/Deferred. Accepted RFCs link to ADRs and implementation plans

**Invocation:** `/godmode:rfc`, "write a proposal", "RFC for", "propose a change", "I need team buy-in"

**Output:** `docs/rfcs/<NNN>-<kebab-case-title>.md` with commit `"rfc: RFC-<NNN> — <title> (<status>)"`

**Flags:** `--list`, `--status`, `--template`, `--review <NNN>`, `--accept <NNN>`, `--reject <NNN>`, `--defer <NNN>`

### Skill Interactions
| From | To | When |
|------|----|------|
| `/godmode:think` | `/godmode:adr` | Significant design choice made |
| `/godmode:think` | `/godmode:rfc` | Decision needs broader team input |
| `/godmode:rfc` (accepted) | `/godmode:adr` | Create ADR from accepted RFC |
| `/godmode:rfc` (accepted) | `/godmode:plan` | Create implementation plan |
| `/godmode:ship` | `/godmode:docs` | Pre-ship documentation check |
| `/godmode:review` | `/godmode:docs` | Undocumented public APIs detected |

### Design Principles
1. **Decisions are forever** — ADRs capture the reasoning at the time, not just the outcome
2. **Documentation derives from code** — generated docs are always grounded in actual implementation
3. **Proposals have deadlines** — RFCs without review deadlines never get decided
4. **Staleness is the enemy** — all three skills include audit capabilities to detect rot
5. **Structured templates reduce friction** — consistent formats make writing and reading faster

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/adr/SKILL.md` | Skill | Architecture Decision Records workflow |
| `skills/docs/SKILL.md` | Skill | Documentation Generation & Maintenance workflow |
| `skills/rfc/SKILL.md` | Skill | RFC & Proposal Writing workflow |
| `commands/godmode/adr.md` | Command | Usage reference for `/godmode:adr` |
| `commands/godmode/docs.md` | Command | Usage reference for `/godmode:docs` |
| `commands/godmode/rfc.md` | Command | Usage reference for `/godmode:rfc` |

**Iterations 137-142 (6 files, 3 skills, 3 commands)**

---

## 58. Development Workflow Skills

### Overview
Skills for accelerating the daily development cycle: generating new code from patterns, transforming existing code safely, and collaborating through structured pair programming.

### Skills in this Category

#### `/godmode:scaffold` — Code Generation & Scaffolding
**Purpose:** Generate boilerplate code for any framework by analyzing and matching existing project patterns.

**Core capabilities:**
- **Project scaffolding:** Generate full project skeletons for any framework with proper directory structure, configuration, and tooling
- **CRUD generation:** Full resource CRUD (model, schema, repository, service, controller, routes, tests, migration) from a single command
- **Pattern detection:** Analyze existing code for naming conventions, import style, error handling patterns, DI approach, and test organization before generating anything
- **Template-based generation:** Use existing project files as templates to ensure generated code matches conventions exactly
- **Verification:** Type check, lint, and run tests on generated code before committing. Broken scaffolds are rejected
- **TODO tracking:** Clearly mark generated stubs that require manual business logic with TODO comments

**Invocation:** `/godmode:scaffold`, "scaffold", "generate a new", "create boilerplate", "new component/service/endpoint"

**Output:** Generated files matching project conventions with commit `"scaffold: <type> for <name> — <N> files generated"`

**Flags:** `--crud <resource>`, `--endpoint <path>`, `--component <name>`, `--service <name>`, `--project <framework>`, `--dry-run`, `--from <template>`, `--no-tests`

#### `/godmode:refactor` — Large-Scale Refactoring
**Purpose:** Safely transform codebases using proven refactoring patterns with impact analysis and test verification.

**Core capabilities:**
- **Refactoring pattern library:** Extract (Function, Class, Interface, Module, Variable, Parameter), Inline (Function, Variable, Class), Move (Function, Field, Module), Rename (Variable, Function, File, Module), Simplify (Conditional to Polymorphism, Guards, Pipeline, Constants), Compose (Method, Replace Inheritance, Parameter Object, Factory, Null Object), Architecture (Split Monolith, Repository, Service Layer, Middleware, Facade)
- **Impact analysis:** Map all directly and indirectly affected files, identify dynamic references, calculate blast radius before any changes
- **Risk assessment:** LOW (<10 dependents, >80% coverage), MEDIUM (10-30, 50-80%), HIGH (30+, <50%), CRITICAL (core module, <30%). Never refactor below 60% coverage without writing characterization tests first
- **Atomic execution:** One transformation per commit. Full test suite runs after every step. Tests fail -> revert immediately
- **Migration strategy:** Strangler Pattern for large refactors — create alongside, migrate incrementally, remove old code
- **Autonomous mode:** Chain of refactoring steps with automatic revert on failure and before/after metrics reporting

**Invocation:** `/godmode:refactor`, "refactor this", "extract", "rename", "move", "reorganize", "tech debt"

**Output:** Atomic commits `"refactor: <pattern> — <description>"` with post-refactoring report

**Flags:** `--extract <type>`, `--inline <target>`, `--move <target> <dest>`, `--rename <old> <new>`, `--analyze-only`, `--dry-run`, `--strangler`

#### `/godmode:pair` — Pair Programming Assistance
**Purpose:** Structured pair programming with driver/navigator roles, real-time code review, and teaching capabilities.

**Core capabilities:**
- **Session modes:** Standard (user drives, agent navigates), Reverse (agent drives, user reviews), Teaching (explain concepts while building), Explorer (joint exploration of unfamiliar code), Ping-Pong (alternate test/implementation for TDD)
- **Real-time navigation:** Triage observations by urgency — IMMEDIATE (bugs/security, interrupt), SOON (design, next pause), LATER (style, end of session)
- **Knowledge transfer:** Graduated teaching protocol — SHOW (demonstrate), GUIDE (step-by-step), CHECK (user solo with review), SOLO (user independent)
- **Session structure:** Setup (mode, goal, timebox), checkpoints every 10-15 minutes, wrap-up with summary of work, knowledge transferred, and TODOs
- **Rubber duck enhancement:** Guide through questions before answers — "What should happen when the input is null?" before "Add a null check"
- **Ping-pong TDD:** User writes test, agent implements (or vice versa), both verify, alternate roles

**Invocation:** `/godmode:pair`, "pair with me", "let's code together", "help me learn", "teach me"

**Output:** Session summary with commit `"pair: <what was built> — <N> tests passing"`

**Flags:** `--reverse`, `--teach`, `--explore`, `--ping-pong`, `--timebox <min>`, `--review`

### Skill Interactions
| From | To | When |
|------|----|------|
| `/godmode:plan` | `/godmode:scaffold` | Plan identifies scaffolding tasks |
| `/godmode:scaffold` | `/godmode:build` | Scaffold stubs need business logic |
| `/godmode:review` | `/godmode:refactor` | Maintainability score < 6/10 |
| `/godmode:optimize` | `/godmode:refactor` | Structural issues block performance |
| `/godmode:refactor` | `/godmode:review` | Post-refactoring code review |
| `/godmode:pair` | `/godmode:review` | Post-session code review |

### Safety Guarantees
| Skill | Safety Mechanism |
|-------|-----------------|
| Scaffold | Verification: type check + lint + tests pass before commit |
| Refactor | Tests must pass before AND after every transformation step |
| Pair | Real-time bug detection; session checkpoints every 10-15 min |

### Design Principles
1. **Pattern-match, don't invent** — generated and refactored code must match existing project conventions
2. **Atomic changes** — every scaffold and refactoring step is a single, revertable commit
3. **Tests are non-negotiable** — scaffolds include tests; refactors require tests; pairing produces tests
4. **Verify before committing** — no generated or refactored code is committed without passing checks
5. **Teach, don't just do** — pair programming transfers knowledge, not just produces code
6. **Revert fast** — if any step breaks tests, revert immediately rather than trying to fix forward

### Integration with Core Workflow
```
THINK → PLAN → SCAFFOLD → BUILD → REFACTOR → REVIEW → SHIP
                  ↑                    ↑          ↑
                  │                    │          │
               Generate             Transform   Pair
               boilerplate          structure   program
```

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/scaffold/SKILL.md` | Skill | Code Generation & Scaffolding workflow |
| `skills/refactor/SKILL.md` | Skill | Large-Scale Refactoring workflow |
| `skills/pair/SKILL.md` | Skill | Pair Programming Assistance workflow |
| `commands/godmode/scaffold.md` | Command | Usage reference for `/godmode:scaffold` |
| `commands/godmode/refactor.md` | Command | Usage reference for `/godmode:refactor` |
| `commands/godmode/pair.md` | Command | Usage reference for `/godmode:pair` |

**Iterations 143-148 (6 files, 3 skills, 3 commands)**

---

## 55. Configuration & Environment Skills

Two new skills address the critical gap between code and deployment — managing the configuration and environments that determine how code behaves in each stage of the delivery pipeline.

### 55.1 Config — Environment & Configuration Management (`skills/config/SKILL.md`)

**Purpose:** Audit, validate, and manage configuration across dev/staging/prod environments, feature flags, and A/B test rollouts.

**Key capabilities:**
- **Config inventory:** Scans all config files, environment variables, and secret references across the project.
- **Environment parity checking:** Compares configurations across dev/staging/prod to detect critical drift (missing keys), expected drift (log levels, pool sizes), and suspicious drift (unexplained differences).
- **Validation schema generation:** Produces typed config schemas with presence, type, format, range, and sensitivity checks. Enforces fail-fast startup validation.
- **Feature flag management:** Designs flags with typed schema (release, experiment, ops, permission), lifecycle tracking (owner, creation date, expected removal), and hygiene audits (stale flags, dead flags, flag count).
- **A/B test design:** Calculates required sample size from minimum detectable effect and baseline, defines rollout phases (internal, canary, controlled, full), and sets kill criteria for auto-revert.
- **Secret management audit:** Verifies .gitignore coverage, no hardcoded secrets, rotation policy, separate dev/prod credentials, and encryption at rest.

**Workflow:** Inventory config -> Parity check -> Validate schema -> Audit flags -> Audit secrets -> Report (HEALTHY / NEEDS ATTENTION / CRITICAL).

**Command:** `/godmode:config` (`commands/godmode/config.md`)

### 55.2 Onboard — Codebase Onboarding (`skills/onboard/SKILL.md`)

**Purpose:** Accelerate developer ramp-up by generating architecture walkthroughs, key file reading lists, naming convention analysis, dependency graphs, and guided code tours.

**Key capabilities:**
- **Project discovery:** Auto-detects project type, language, framework, package manager, build system, test framework, and size from file system scanning.
- **Architecture walkthrough:** Generates directory maps with annotated descriptions, data flow diagrams showing request lifecycle, and layer responsibility tables.
- **Key file identification:** Identifies the 7-10 most important files ordered by reading priority, plus most-modified files (from git history) and largest files (complexity hotspots).
- **Naming convention analysis:** Documents file, variable, function, type, API endpoint, and database naming patterns used throughout the codebase.
- **Dependency graph:** Visualizes internal module dependencies (with circular dependency detection, fan-in/fan-out analysis) and external package dependencies (with outdated/vulnerable package flagging).
- **Code tour generation:** Creates a guided walk-through with annotated stops at entry point, configuration, routing, core business logic, data layer, error handling, and testing patterns.

**Workflow:** Discover project -> Architecture walkthrough -> Key files -> Naming conventions -> Dependency graph -> Code tour -> Report.

**Command:** `/godmode:onboard` (`commands/godmode/onboard.md`)

### Integration with Existing Skills

```
/godmode:onboard  ->  /godmode:think  ->  /godmode:config  ->  /godmode:plan  ->  /godmode:build
     |                     |                    |                     |                  |
  Understand          Design a new        Validate config       Plan the           Implement
  the codebase        feature             for the feature       implementation     with TDD
```

- **From `/godmode:onboard`:** After understanding the codebase, use `/godmode:think` to design your first feature
- **From `/godmode:config`:** After validating environments, use `/godmode:ship` to deploy with confidence
- **From `/godmode:config --ab`:** After designing an A/B test, use `/godmode:build` to implement the variants

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/config/SKILL.md` | Skill | Environment and configuration management workflow |
| `skills/onboard/SKILL.md` | Skill | Codebase onboarding and architecture discovery workflow |
| `commands/godmode/config.md` | Command | Usage reference for `/godmode:config` |
| `commands/godmode/onboard.md` | Command | Usage reference for `/godmode:onboard` |

**Iterations 127-130 (4 files, 2 skills, 2 commands)**

---

## 56. Advanced Testing Skills

Three new skills extend Godmode's testing capabilities beyond unit and integration tests into load testing, end-to-end browser testing, and chaos engineering — the trifecta of production readiness validation.

### 56.1 Loadtest — Load Testing & Performance Testing (`skills/loadtest/SKILL.md`)

**Purpose:** Stress-test systems to establish baselines, find breaking points, identify bottlenecks, and validate capacity with statistical rigor.

**Key capabilities:**
- **Multi-tool support:** Generates test scripts for k6 (JavaScript), Artillery (YAML), Locust (Python), and JMeter — matching the team's preferred toolchain.
- **Four test patterns:** Load test (baseline at expected traffic), stress test (find breaking point), spike test (sudden surge response), and soak test (4-8 hour endurance for leak detection).
- **Baseline establishment:** Records P50, P95, P99 response times, throughput, error rate, CPU, memory, DB connections, and network I/O per endpoint.
- **Bottleneck analysis:** Correlates response time degradation with resource saturation (CPU, memory, DB, network) to identify root causes ranked by impact.
- **Statistical significance:** Validates performance comparisons using Welch's t-test with Cohen's d effect size. Requires multiple runs with variance reporting.
- **SLO compliance:** Tests against defined service level objectives (P95 < Xms, error rate < Y%, throughput > N rps) with pass/fail verdicts.

**Workflow:** Define scope and SLOs -> Select test type -> Generate scripts -> Run baseline -> Analyze bottlenecks -> Statistical validation -> Report (MEETS SLOs / NEEDS OPTIMIZATION / CRITICAL).

**Command:** `/godmode:loadtest` (`commands/godmode/loadtest.md`)

### 56.2 E2E — End-to-End Testing (`skills/e2e/SKILL.md`)

**Purpose:** Build maintainable browser-based E2E test suites with page object models, cross-browser coverage, test data isolation, and flakiness remediation.

**Key capabilities:**
- **Framework setup:** Configures Playwright, Cypress, or Selenium with production-grade settings (parallel workers, retries, reporters, web server integration).
- **Page Object Model:** Generates base page class with common methods and per-page classes with locators (using accessible selectors: getByRole, getByLabel), actions, and assertions.
- **Test data management:** Implements static fixtures, dynamic factories (faker-based), and authentication fixtures for isolated, reproducible test data.
- **Cross-browser testing:** Configures and runs tests across Chromium, Firefox, WebKit, and mobile viewports with per-browser issue reporting.
- **Flakiness remediation:** Diagnoses root causes (race conditions, animation interference, test order dependency, network timing, viewport inconsistency) with a structured fix for each pattern.
- **Anti-flakiness rules:** Enforces auto-waiting assertions, test independence, accessible locators, data cleanup, explicit timeouts, animation disabling, API-seeded test data, and failure artifacts (screenshots, videos, traces).

**Workflow:** Assess state -> Design architecture -> Configure framework -> Implement page objects -> Write tests -> Fix flakiness -> Cross-browser run -> Report (SOLID / NEEDS WORK / FRAGILE).

**Command:** `/godmode:e2e` (`commands/godmode/e2e.md`)

### 56.3 Chaos — Chaos Engineering (`skills/chaos/SKILL.md`)

**Purpose:** Test system resilience through controlled failure injection, circuit breaker validation, and structured game day exercises.

**Key capabilities:**
- **Steady state definition:** Establishes health indicators (success rate, latency, error rate, resource usage) and monitoring endpoints as the baseline to compare against during experiments.
- **Failure domain mapping:** Catalogs all failure modes across network (latency, DNS, packet loss), compute (process crash, memory pressure, CPU saturation), storage (DB failover, cache failure, disk full), dependencies (API outages), and data (corruption, replication lag).
- **Experiment design:** Each experiment follows a template: hypothesis, blast radius, duration, injection method, rollback procedure, success/failure criteria, and prerequisites checklist.
- **Network failure injection:** Dependency timeouts (tc/toxiproxy), DNS failure, packet loss — with expected behaviors for circuit breakers, retries, and graceful degradation.
- **Process failure injection:** Process crash (kill -9), memory pressure (stress-ng), CPU saturation — testing auto-restart, load shedding, and health check priority.
- **Storage failure injection:** Database failover, cache flush (cold cache performance), disk full — testing read replica promotion, fallback to direct queries, and write prioritization.
- **Circuit breaker validation:** Tests all state transitions (CLOSED -> OPEN -> HALF-OPEN -> CLOSED/OPEN) with fallback response verification and metrics/logging checks.
- **Game day planning:** Structured timeline with kickoff, experiments, observation periods, rollbacks, and retrospective. Includes safety protocols, escalation paths, and approval requirements.
- **Resilience scorecard:** Grades each failure domain (A = resilient, B = adequate, C = fragile, F = vulnerable) with recovery time measurements against targets.

**Workflow:** Define steady state -> Map failure domains -> Design experiments -> Validate circuit breakers -> Plan game day -> Run experiments -> Generate scorecard (RESILIENT / ADEQUATE / FRAGILE).

**Command:** `/godmode:chaos` (`commands/godmode/chaos.md`)

### Integration with Existing Skills

```
/godmode:loadtest  ->  /godmode:optimize  ->  /godmode:loadtest --compare
     |                      |                        |
  Find bottlenecks     Fix bottlenecks        Verify improvement

/godmode:e2e  ->  /godmode:fix  ->  /godmode:e2e --fix-flaky
     |                 |                    |
  Find failures    Fix bugs           Fix flaky tests

/godmode:chaos  ->  /godmode:fix  ->  /godmode:chaos --scorecard
     |                   |                     |
  Find weakness     Add resilience      Re-score system
```

- **From `/godmode:loadtest` to `/godmode:optimize`:** Load testing reveals bottlenecks; optimize addresses them; re-test verifies the improvement with statistical comparison.
- **From `/godmode:e2e` to `/godmode:ship`:** E2E tests validate user flows before shipping. The ship skill checks E2E status as a pre-flight gate.
- **From `/godmode:chaos` to `/godmode:fix`:** Chaos experiments reveal resilience gaps; fix addresses them; chaos re-scores the system.
- **From `/godmode:loadtest` to `/godmode:ship`:** SLO compliance is a ship pre-condition. Loadtest provides the evidence.
- **From `/godmode:secure` to `/godmode:chaos`:** Security audit identifies theoretical denial-of-service risks; chaos engineering validates them experimentally.

### Design Principles for Advanced Testing Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Measure before optimizing | Loadtest establishes baselines before any optimization work |
| 2 | Statistical rigor | Single runs prove nothing; multiple runs with significance testing required |
| 3 | Stability over speed | E2E reliability trumps E2E execution time; fix flakiness first |
| 4 | Hypothesize before injecting | Every chaos experiment starts with a testable prediction |
| 5 | Production-like environments | Tests against dev SQLite don't predict prod PostgreSQL behavior |
| 6 | Findings are victories | A broken test or failed experiment means you found the problem before users did |
| 7 | Automate for regression | Performance and E2E tests run in CI to catch regressions before production |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/loadtest/SKILL.md` | Skill | Load testing and performance testing workflow |
| `skills/e2e/SKILL.md` | Skill | End-to-end browser testing workflow |
| `skills/chaos/SKILL.md` | Skill | Chaos engineering and resilience testing workflow |
| `commands/godmode/loadtest.md` | Command | Usage reference for `/godmode:loadtest` |
| `commands/godmode/e2e.md` | Command | Usage reference for `/godmode:e2e` |
| `commands/godmode/chaos.md` | Command | Usage reference for `/godmode:chaos` |

**Iterations 131-136 (6 files, 3 skills, 3 commands)**

## 72. Authentication & Identity Skills

### Overview

Two new skills extend Godmode into the authentication, authorization, and identity domain. These skills address the full identity lifecycle: from authentication strategy selection and implementation through permission model design, access control enforcement, and audit logging.

### Skill: `/godmode:auth` — Authentication & Authorization

**Purpose:** Design and implement production-grade authentication systems with security best practices.

**Capabilities:**
- **Auth strategy design:** JWT (RS256/ES256 with refresh token rotation), OAuth2/OIDC (Authorization Code + PKCE), SAML 2.0 federation, API key management (prefixed, hashed, scoped), and mTLS for zero-trust service-to-service authentication
- **Session management:** Stateful (server-side with Redis/PostgreSQL) and stateless (JWT-based) session designs with HttpOnly/Secure/SameSite cookie configuration, idle and absolute timeouts, concurrent session limits, and session fixation prevention
- **Multi-factor authentication:** TOTP (RFC 6238 compatible with authenticator apps), WebAuthn/passkeys (FIDO2 with platform and roaming authenticator support), SMS OTP (fallback only), email magic links, and single-use recovery codes
- **Passwordless auth:** Magic link flows, WebAuthn/passkey-first authentication with conditional mediation, and one-time password delivery
- **Token lifecycle:** Complete issuance, validation, refresh (with rotation), revocation, and cleanup pipeline with per-client-type storage guidance (SPA, SSR, mobile, server, microservice)
- **Social login integration:** Google, GitHub, Apple, Microsoft, Facebook via OIDC/OAuth2 with email-based account linking, verified-email enforcement, and account takeover prevention
- **Security hardening:** Password policy (argon2id/bcrypt), brute force protection (rate limiting, lockout, CAPTCHA), transport security (HTTPS, HSTS, CORS), and account enumeration prevention

**Workflow:** Identity Requirements Discovery -> Auth Strategy Selection -> Session Management Design -> MFA Design -> Passwordless Design -> Token Lifecycle -> Social Login -> Security Hardening -> Implementation Artifacts -> Architecture Report

**Artifacts produced:**
- `docs/auth/<feature>-auth-architecture.md` — Authentication architecture decision document
- `src/auth/` — Implementation code (strategies, middleware, controllers, services, models)
- `tests/auth/` — Integration and unit tests

**Flags:** `--strategy jwt|oauth|saml|session|apikey|mtls`, `--mfa`, `--passwordless`, `--social`, `--tokens`, `--sessions`, `--audit`, `--harden`, `--migrate`

### Skill: `/godmode:rbac` — Permission & Access Control

**Purpose:** Design and implement authorization models that enforce least-privilege access across resources.

**Capabilities:**
- **RBAC (Role-Based Access Control):** Role hierarchy design (strict tree, lattice DAG, scoped roles), permission format (`resource:action`), role inheritance, role assignment with scope and expiry, and constraint rules (separation of duties, prerequisites, cardinality)
- **ABAC (Attribute-Based Access Control):** Policy evaluation over subject, resource, action, and environment attributes with support for Open Policy Agent (Rego), AWS Cedar, or custom policy languages, configurable evaluation order (deny-override), and policy versioning
- **ReBAC (Relationship-Based Access Control):** Google Zanzibar-inspired relationship tuples, type definitions with computed permissions, transitive relationship resolution, and integration with SpiceDB, Auth0 FGA, Ory Keto, or AWS Verified Permissions
- **Resource-based access control:** Resource ownership model, permission evaluation chains (owner -> explicit grant -> role-based -> relationship-based -> default deny), resource-level sharing with grants, and field-level access control with response filtering
- **Permission inheritance and delegation:** Organizational hierarchy inheritance (org -> team -> project -> resource), grant delegation with depth limits, admin impersonation with time limits and audit, temporary privilege elevation with approval workflow, and API key delegation scoped to granting user's permissions
- **Policy engine design:** Authorization decision engine with deny-override evaluation, sub-5ms p99 latency targets, compiled policy caching, middleware integration patterns (Express, NestJS, decorator-based), and programmatic permission checks
- **Audit logging:** Every ALLOW and DENY decision logged with structured schema (subject, resource, action, context), alert rules for repeated denials and privilege escalation, immutable append-only storage, SIEM integration, and automated periodic access reviews

**Workflow:** Requirements Discovery -> Permission Model Selection -> Role Hierarchy Design -> Resource-Based Access Control -> Permission Inheritance & Delegation -> Policy Engine Design -> Audit Logging -> Implementation Artifacts -> Access Control Report

**Artifacts produced:**
- `docs/auth/<feature>-access-control.md` — Access control model documentation
- `src/auth/` — Implementation code (models, middleware, policy engine, audit logger)
- Database migrations for roles, permissions, grants, and audit tables
- `tests/auth/authorization/` — Authorization test suite

**Flags:** `--model rbac|abac|rebac`, `--hierarchy`, `--permissions`, `--delegation`, `--audit`, `--policies`, `--review`, `--migrate`, `--test`, `--matrix`

### Integration with Existing Skills

The identity skills integrate into the Godmode workflow at these points:

```
/godmode:think  ->  /godmode:auth  ->  /godmode:rbac  ->  /godmode:plan  ->  /godmode:build
     |                   |                   |                  |                  |
  Brainstorm        Design auth          Design access      Decompose into     Implement
  the identity      strategy & MFA       control model      tasks with TDD     the system
```

- **From `/godmode:think`:** After brainstorming identity requirements, invoke `/godmode:auth` to formalize the authentication strategy
- **From `/godmode:auth` to `/godmode:rbac`:** After authentication is designed, design the authorization model with roles, permissions, and policies
- **From `/godmode:rbac` to `/godmode:plan`:** After access control is defined, plan the implementation tasks
- **From `/godmode:api`:** API design references `/godmode:auth` for endpoint authentication and `/godmode:rbac` for endpoint authorization
- **From `/godmode:secure`:** Security audit validates authentication controls, session management, and access control enforcement
- **From `/godmode:comply`:** Compliance audit checks auth logging, access reviews, and data access controls against regulatory requirements
- **From `/godmode:ship`:** Ship workflow verifies authentication and authorization are properly configured before deployment

### Design Principles for Identity Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Security by default | Every design choice defaults to the most secure option; weaker options require explicit justification |
| 2 | Default deny | If no policy explicitly grants access, the answer is DENY |
| 3 | Least privilege | Every role has the minimum permissions needed; start with zero and add |
| 4 | Authentication is not authorization | Knowing WHO someone is does not determine WHAT they can do; design both explicitly |
| 5 | Audit everything | Every ALLOW and DENY decision is logged with enough context for investigation |
| 6 | Tokens have lifecycles | Every token has issuance, validation, refresh, revocation, and cleanup |
| 7 | Check permissions, not roles | Code checks `can(user, "delete", resource)`, never `user.role === "admin"` |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/auth/SKILL.md` | Skill | Authentication and authorization design workflow |
| `skills/rbac/SKILL.md` | Skill | Permission and access control design workflow |
| `commands/godmode/auth.md` | Command | Usage reference for `/godmode:auth` |
| `commands/godmode/rbac.md` | Command | Usage reference for `/godmode:rbac` |

**Iterations 187-190 (4 files, 2 skills, 2 commands)**

## 78. Cross-Reference & Navigation

Godmode now includes four cross-referencing documents to help developers navigate the 48 implemented skills efficiently.

### 78.1 Master Skill Index (`docs/skill-index.md`)

Complete alphabetical listing of all 48 skills with one-line descriptions. Organized three ways:

- **By phase:** THINK (5 skills), BUILD (6 skills), OPTIMIZE (7 skills), SHIP (3 skills), META (3 skills)
- **By domain:** API/Backend, Frontend/UI, Infrastructure/DevOps, Quality/Security, ML, Mobile, Documentation/Knowledge, Testing, Incident Management
- **Cross-reference table:** Shows which skills feed into and receive from every other skill
- **"I want to..." mapping:** 48 developer scenarios mapped to the correct skill and command

### 78.2 Skill Chaining Reference (`docs/skill-chains.md`)

All valid skill chains documented with concrete examples:

| Named Chain | Skills | Use Case |
|-------------|--------|----------|
| full-stack | think > plan > build > test > review > optimize > ship | New feature, full quality |
| hotfix | debug > fix > verify > ship | Production bug, fast resolution |
| security-hardening | secure > fix > verify > review > ship | Pre-launch security review |
| performance | optimize > loadtest > verify > ship | Code performance improvement |
| new-api | api > contract > build > test > docs > ship | New API endpoint development |
| incident | incident > debug > fix > verify > deploy | Production incident response |
| ml-pipeline | ml > pipeline > mlops > observe > ship | ML model to production |
| design-exploration | think > predict > scenario > think | Deep architecture exploration |
| test-coverage | scenario > test > e2e > review | Improve test coverage |
| infrastructure | think > infra > k8s > config > secure > deploy | Cloud infrastructure setup |
| mobile-release | think > plan > build > mobile > a11y > visual > ship | Mobile app release |
| data-migration | think > migrate > test > verify > deploy | Database schema changes |
| compliance-audit | comply > secure > secrets > fix > verify > ship | Regulatory compliance |
| frontend-quality | ui > a11y > visual > i18n > e2e > review > ship | Frontend quality sweep |
| onboarding | onboard > docs > pair | New team member ramp-up |
| cost-optimization | cost > infra > config > verify > deploy | Cloud bill reduction |
| observability-setup | observe > loadtest > errortrack > config > deploy | Monitoring setup |

Also includes: conditional transitions, loop patterns, and custom chain definition syntax (YAML).

### 78.3 Decision Tree (`docs/decision-tree.md`)

Flowchart-style "What skill do I need?" navigator with 5 top-level branches:

1. **CREATE** something new — routes through think, plan, build, and domain-specific skills
2. **IMPROVE** existing code — branches into performance, quality, security, testing, observability
3. **FIX/DEBUG** something — routes through debug, fix, incident, errortrack based on symptoms
4. **SHIP** something — routes through ship, deploy, and pre-ship quality gates
5. **LEARN** something — routes through onboard, docs, adr, predict, pair

Each branch terminates at a specific `/godmode:<skill>` command with the exact flags needed.

### 78.4 Quick Reference Card (`docs/quick-reference.md`)

Every command on a single page, organized by use case:

- Orchestrator, Design/Planning, Building/Coding, Testing
- Code Review/Quality, Optimization/Performance, Debugging/Fixing
- Security/Compliance, Accessibility/i18n, API Design
- Infrastructure/DevOps, Monitoring/Incidents, ML, Database
- Mobile, UI/Frontend, Documentation/Knowledge, Shipping/Deployment
- Configuration/Verification, Named Chains

### Navigation Map

```
docs/
├── skill-index.md      "What skills exist?"        → Complete catalog
├── skill-chains.md     "How do skills connect?"    → Named workflows
├── decision-tree.md    "What skill do I need?"     → Interactive navigator
├── quick-reference.md  "What's the command?"       → All flags, one page
├── architecture.md     "How does it work inside?"  → System internals
├── chaining.md         "How do artifacts flow?"    → Artifact pipeline
├── domain-guide.md     "How does my domain use it?" → Domain-specific
└── godmode-design.md   "What's the full design?"   → This document
```

### Cross-Links Between Documents

| Starting From | Links To |
|--------------|----------|
| skill-index.md | skill-chains.md, decision-tree.md, quick-reference.md, architecture.md, chaining.md, domain-guide.md |
| skill-chains.md | skill-index.md, decision-tree.md, quick-reference.md, chaining.md |
| decision-tree.md | skill-index.md, skill-chains.md, quick-reference.md |
| quick-reference.md | skill-index.md, skill-chains.md, decision-tree.md, domain-guide.md |

**Iterations 225-229 (4 files created, 1 file updated)**

## 70. Architecture & Design Pattern Skills

### Overview

Three new skills extend Godmode into the architecture and design pattern domain. These skills address the structural decisions that determine a system's long-term viability: from high-level architecture selection through implementation-level pattern choice to domain modeling with DDD.

### Skill: `/godmode:architect` — Software Architecture Design

**Purpose:** Design system architecture with rigorous pattern evaluation, trade-off analysis, and visual documentation.

**Capabilities:**
- **Architecture pattern selection:** Evaluates monolith (modular), microservices, serverless, event-driven, CQRS, and hexagonal architectures against project requirements
- **Trade-off analysis:** Weighted comparison matrix scoring scalability, simplicity, team fit, time to market, cost, testability, reliability, and maintainability
- **C4 model diagrams:** Produces diagrams at all four C4 levels (System Context, Container, Component, Code) using ASCII art
- **Bounded context mapping:** Strategic DDD view showing context relationships (Partnership, Customer/Supplier, Conformist, ACL, Open Host Service, Shared Kernel)
- **Quality attribute analysis:** Maps how the chosen architecture addresses scalability, reliability, maintainability, security, observability, and performance
- **Architecture Decision Records:** Formal ADRs capturing the decision, context, consequences, and risks with mitigations
- **Migration planning:** Strangler Fig and incremental migration strategies for existing systems

**Workflow:** Context Gathering -> Pattern Evaluation -> Comparison Matrix -> C4 Diagrams -> Bounded Context Map -> Quality Attributes -> ADR -> Artifacts

**Artifacts produced:**
- `docs/architecture/<system>-architecture.md` — Complete architecture document with C4 diagrams
- `docs/adr/<number>-<decision>.md` — Architecture Decision Record

**Flags:** `--quick`, `--compare <p1> <p2> <p3>`, `--c4`, `--adr`, `--context-map`, `--migrate`, `--validate`

### Skill: `/godmode:pattern` — Design Pattern Recommendation

**Purpose:** Recommend the right design pattern for a given problem, detect anti-patterns, and produce language-specific implementations.

**Capabilities:**
- **Gang of Four patterns:** All 23 classic patterns organized by category (Creational, Structural, Behavioral) with modern when-to-use guidance
- **Modern distributed patterns:** Repository, CQRS, Saga (orchestration and choreography), Circuit Breaker, Outbox, Strangler Fig, Event Sourcing, Bulkhead, Sidecar, Backend for Frontend
- **Anti-pattern detection:** Scans for God Object, Spaghetti Code, Shotgun Surgery, Feature Envy, Primitive Obsession, Anemic Domain Model, Circular Dependency, Leaky Abstraction, Distributed Monolith, Golden Hammer
- **Language-specific implementations:** Adapts patterns to TypeScript, Python, Go, Java/Kotlin, and Rust idioms with interfaces, tests, and integration notes
- **Pattern comparison:** Side-by-side evaluation of candidate patterns with confidence rating and rejected alternatives

**Workflow:** Problem Analysis -> Pattern Classification -> Pattern Recommendation -> Language-Specific Implementation -> Anti-Pattern Detection -> Artifacts

**Artifacts produced:**
- `docs/patterns/<feature>-pattern-analysis.md` — Pattern analysis with recommendation and implementation guide

**Flags:** `--detect`, `--gof`, `--modern`, `--implement <pattern>`, `--compare <p1> <p2>`, `--language <lang>`, `--teach`

### Skill: `/godmode:ddd` — Domain-Driven Design

**Purpose:** Apply Domain-Driven Design to model complex business domains with bounded contexts, aggregates, and domain events.

**Capabilities:**
- **Strategic design:** Bounded context identification, context mapping (8 relationship types), ubiquitous language glossary, core/supporting/generic subdomain classification
- **Tactical design:** Aggregate root entities, child entities, value objects, domain events, commands, repository interfaces, and domain services with invariant documentation
- **Event storming facilitation:** Structured 5-phase process (Chaotic Exploration, Timeline, Commands & Actors, Aggregates, Bounded Context Discovery)
- **Aggregate boundary design:** 7 rules for aggregate boundaries (consistency, transaction, size, reference, cascade, invariant, identity) with concrete examples
- **Domain event catalog:** Cross-context event documentation with payloads, schemas, and versioning rules
- **Implementation scaffold:** Directory structure generation following hexagonal architecture (domain/application/infrastructure layers)

**Workflow:** Domain Discovery -> Ubiquitous Language -> Event Storming (5 phases) -> Context Mapping -> Tactical Design -> Domain Event Catalog -> Implementation Scaffold -> Artifacts

**Artifacts produced:**
- `docs/domain/<context>-domain-model.md` — Aggregate designs with entities, value objects, and invariants
- `docs/domain/event-catalog.md` — All domain events with payloads and schema rules
- `docs/domain/context-map.md` — Bounded context map with relationship types
- `docs/domain/ubiquitous-language.md` — Domain vocabulary glossary

**Flags:** `--strategic`, `--tactical`, `--event-storm`, `--aggregate <name>`, `--context-map`, `--language`, `--scaffold`, `--validate`

### Integration with Existing Skills

The architecture and design pattern skills integrate into the Godmode workflow at these points:

```
/godmode:think  ->  /godmode:architect  ->  /godmode:ddd  ->  /godmode:pattern  ->  /godmode:plan
     |                    |                      |                   |                    |
  Brainstorm         Select the             Model the           Choose impl.        Decompose
  the system         architecture           domain              patterns            into tasks
```

- **From `/godmode:think`:** After brainstorming system requirements, invoke `/godmode:architect` to formalize the architecture
- **From `/godmode:architect` to `/godmode:ddd`:** After selecting the architecture pattern, define domain boundaries and aggregates
- **From `/godmode:ddd` to `/godmode:pattern`:** After modeling aggregates, select implementation patterns (Repository, Factory, etc.)
- **From `/godmode:pattern` to `/godmode:plan`:** After choosing patterns, plan the implementation tasks
- **From `/godmode:review`:** Code review can flag architecture violations and refer to `/godmode:architect --validate`
- **From `/godmode:pattern --detect`:** Anti-pattern detection feeds into `/godmode:refactor` for remediation
- **From `/godmode:architect` to `/godmode:api`:** Architecture decisions inform API design (REST vs GraphQL, sync vs async)

### Design Principles for Architecture & Pattern Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Requirements before patterns | Never recommend architecture without understanding scale, team, and constraints |
| 2 | Always compare alternatives | Minimum 3 options evaluated with trade-offs, even when the answer seems obvious |
| 3 | Diagrams are mandatory | C4 diagrams for architecture, context maps for DDD, class diagrams for patterns |
| 4 | Trade-offs are honest | Every pattern has real downsides — never present a solution as having no weaknesses |
| 5 | ADRs capture the "why" | Architecture Decision Records explain reasoning, not just the decision |
| 6 | Events before entities | DDD starts with event storming to discover behavior, not with entity modeling |
| 7 | Simplicity over cleverness | If a function and an interface solve the problem, do not recommend a full pattern |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/architect/SKILL.md` | Skill | Software architecture design workflow |
| `skills/pattern/SKILL.md` | Skill | Design pattern recommendation workflow |
| `skills/ddd/SKILL.md` | Skill | Domain-Driven Design workflow |
| `commands/godmode/architect.md` | Command | Usage reference for `/godmode:architect` |
| `commands/godmode/pattern.md` | Command | Usage reference for `/godmode:pattern` |
| `commands/godmode/ddd.md` | Command | Usage reference for `/godmode:ddd` |

**Iterations 175-180 (6 files, 3 skills, 3 commands)**

---

## 65. Cost Optimization Skills

### `/godmode:cost` — Cloud Cost Optimization

**Purpose:** Analyze, reduce, and govern cloud spending across AWS, GCP, and Azure with evidence-based recommendations backed by actual utilization data and projected dollar savings.

**Core capabilities:**
- **Resource inventory:** Discover all provisioned resources across compute, storage, database, network, containers, and serverless with current monthly costs and month-over-month trends
- **Utilization analysis:** Measure actual CPU, memory, storage, and network usage versus provisioned capacity with IDLE/OVERSIZE/UNDERSIZE/OK verdicts based on 14-day P95 data
- **Waste detection:** Identify resources costing money but providing no value — unattached volumes, old snapshots, idle load balancers, unused Elastic IPs, orphaned ENIs, dev environments running 24/7
- **Right-sizing recommendations:** For each oversized or undersized resource, recommend optimal size with projected monthly savings and percentage reduction, leaving 40%+ headroom above P95 utilization
- **Pricing optimization:** Recommend reserved instances, savings plans, and spot/preemptible instances for stable workloads with 3+ months of predictable usage; identify CI/CD runners and batch jobs eligible for 60-70% spot savings
- **Cost allocation tagging:** Audit tag coverage (team, environment, project, cost-center, owner), identify untagged resources, recommend enforcement via AWS Config / GCP Organization Policy / Azure Policy
- **Budget alerts:** Configure proactive cost monitoring with tiered alerts (50/80/100% of budget), anomaly detection (2x rolling average, $500/day single resource), and weekly cost digests
- **Optimization report:** Produce prioritized action list with savings breakdown (waste elimination, right-sizing, pricing optimization, scheduling), implementation effort (quick wins, medium, long-term), and annual impact projection

**Invocation:** `/godmode:cost`, "reduce cloud costs", "optimize spending", "why is our bill so high?", "right-sizing", "reserved instances"

**Key principle:** Every recommendation must include the projected dollar savings. "This instance is oversized" is not actionable. "$180/month savings by downsizing from m5.2xl to m5.large" is actionable. Production optimizations are conservative; dev/staging can be aggressive.

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/cost/SKILL.md` | Skill | Cloud cost optimization workflow |
| `commands/godmode/cost.md` | Command | Usage reference for `/godmode:cost` |

---

## 66. Compliance & Governance Skills

### `/godmode:comply` — Compliance & Governance

**Purpose:** Systematically evaluate codebase and data flows against regulatory frameworks (GDPR, HIPAA, SOC2, PCI-DSS), validate audit trails, review data retention policies, and audit license compliance across dependencies.

**Core capabilities:**
- **GDPR compliance:** Lawful basis assessment for each data processing activity, data subject rights implementation check (access, rectification, erasure, portability, restriction, objection), consent management validation (freely given, specific, informed, unambiguous, withdrawable, recorded)
- **HIPAA compliance:** Administrative safeguards (risk analysis, workforce controls, incident response, BAAs), physical safeguards (facility access, workstation security), technical safeguards (access control, audit controls, integrity, transmission security, encryption at rest), minimum necessary principle, de-identification, PHI access logging
- **SOC2 compliance:** Trust services criteria assessment across security, availability, processing integrity, confidentiality, and privacy with control counts and gap identification for change management, logical access, encryption, monitoring, incident response, vendor risk, backup, and vulnerability scanning
- **PCI-DSS compliance:** All 12 requirements checked (network security, secure configuration, stored data protection, transmission encryption, malware protection, secure development, access restriction, user identification, physical access, logging, security testing, organizational policies), CDE scope reduction verification, PAN/CVV storage validation
- **Audit trail validation:** Event coverage matrix (authentication, authorization, data access/modification/deletion/export, configuration changes, system errors, admin operations), tamper resistance, retention, searchability, PII redaction, UTC timestamps, correlation IDs
- **Data retention & deletion:** Retention periods per data category with auto-delete status, deletion workflow validation (request, verification, execution, confirmation), cascade to backups/caches/replicas, verifiability, regulatory timeline compliance
- **License compliance:** Dependency license inventory with commercial compatibility assessment (MIT/Apache/BSD: OK; LGPL: conditional; GPL: risk; AGPL: high risk; unlicensed: unknown), attribution requirements, replacement recommendations

**Invocation:** `/godmode:comply`, "GDPR compliance", "audit trail", "are we compliant?", "privacy review", "license audit"

**Key principle:** Each finding must reference the specific regulation article or requirement it violates. "Deletion missing" is not a finding. "GDPR Article 17 violation: deleteUser() sets deleted_at but data persists in backups indefinitely" is a finding.

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/comply/SKILL.md` | Skill | Compliance and governance audit workflow |
| `commands/godmode/comply.md` | Command | Usage reference for `/godmode:comply` |

---

## 67. Deployment Strategy Skills

### `/godmode:deploy` — Advanced Deployment Strategies

**Purpose:** Design and orchestrate sophisticated deployment strategies including blue-green deployments, canary releases, progressive rollouts, automated rollback, feature flag coordination, and zero-downtime migrations.

**Core capabilities:**
- **Deployment assessment:** Characterize change type (code, migration, infrastructure, config), risk level, rollback complexity, backward/forward compatibility, and recommend appropriate strategy with justification
- **Blue-green deployment:** Two identical environments with instant switchover — deploy to idle environment, smoke test, switch load balancer, monitor, keep old environment for instant rollback (< 30 seconds)
- **Canary release:** Percentage-based traffic splitting with automated gates — 1% to 5% to 25% to 50% to 100% with success criteria (error rate, P99 latency, business metrics) and automatic rollback triggers at each stage
- **Progressive rollout:** Multi-stage deployment with configurable gates (auto and manual) — smoke test at 0%, seed at 1%, low at 5%, medium at 25%, high at 50%, full at 100%, each with defined duration and gate criteria
- **Automated rollback:** Trigger matrix (HTTP 5xx rate > 1%, P99 latency > 2x baseline, error log rate > 3x, health check failures, business metric drop > 10%, memory > 90%, CPU > 95%) with detection, decision, execution, investigation, and communication phases
- **Feature flag orchestration:** Coordinated flag rollout plan with dependencies, kill switches (30-second disable without deployment), lifecycle management (create, enable internal, progressive rollout, 100%, cleanup, delete), stale flag detection (100% for 30+ days, 0% for 14+ days)
- **Zero-downtime migrations:** Expand-contract pattern for database schema changes (add nullable column, dual-write, backfill, switch reads, drop old column), strangler fig pattern for service migrations with shadow traffic and bidirectional sync
- **Pre-deployment checklist:** Tests passing, security audit passed, migration tested in staging, rollback procedure tested, monitoring dashboards ready, on-call confirmed, communication sent

**Invocation:** `/godmode:deploy`, "deploy with zero downtime", "canary release", "blue-green deployment", "rollback strategy", "feature flag rollout"

**Key principle:** Strategy matches risk. Low-risk changes use rolling deploys. High-risk changes need canary with automated rollback. Rollback is always planned — if you cannot define rollback, the deployment is not ready.

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/deploy/SKILL.md` | Skill | Advanced deployment strategies workflow |
| `commands/godmode/deploy.md` | Command | Usage reference for `/godmode:deploy` |

---

## 68. Learning & Teaching Skills

### `/godmode:learn` — Learning & Teaching

**Purpose:** Provide interactive, codebase-grounded learning experiences including tutorials, design pattern recommendations, best practices enforcement, codebase knowledge bases, and personalized learning paths.

**Core capabilities:**
- **Interactive code tutorials:** Step-by-step tutorials using actual project code with context, explanations, key insights, and hands-on "TRY IT" exercises; checkpoints with comprehension questions; calibrated to beginner/intermediate/advanced level
- **Design pattern recommendations:** Problem-specific pattern selection with trade-offs (Strategy, Observer, Factory, Repository, CQRS, Circuit Breaker, etc.); ASCII diagrams; before/after code from the actual codebase; real-world examples already in the project; "when NOT to use" guidance
- **Best practices enforcement:** Language- and framework-specific practices (TypeScript, React, Go, Python, etc.) with MUST/SHOULD/MAY levels (RFC 2119); good/bad code examples; codebase compliance audit showing which files follow or violate each practice; prioritized adoption list
- **Codebase knowledge base:** Architecture overview (pattern, entry points, data flow), module map with purposes and key files, dependency graph, conventions (naming, file structure, error handling, testing, configuration), key domain concepts, gotchas and tribal knowledge for new team members
- **Skill assessment and learning path:** 10-dimension assessment (language basics, design patterns, error handling, testing, performance, security, architecture, readability, debugging, tools) scored 1-5 with evidence; personalized 6-week learning path with weekly goals, resources (tutorials, practice tasks, code to study), and verifiable milestones

**Invocation:** `/godmode:learn`, "teach me", "how does this work?", "best practices for", "what pattern should I use?", "explain this code"

**Key principle:** Use the actual codebase. "Here's how YOUR code uses the Observer pattern" is 10x more effective than a textbook example. One concept at a time, hands-on over theory, trade-offs always mentioned.

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/learn/SKILL.md` | Skill | Learning and teaching workflow |
| `commands/godmode/learn.md` | Command | Usage reference for `/godmode:learn` |

---

## 69. Backup & Disaster Recovery Skills

### `/godmode:backup` — Backup & Disaster Recovery

**Purpose:** Design comprehensive backup strategies, define RPO/RTO targets, automate backup verification, test recovery procedures, verify data integrity, and generate disaster recovery runbooks.

**Core capabilities:**
- **Data asset inventory:** Catalog all data stores (databases, file storage, caches, logs, configuration, secrets, queues, search indices) with type, size, growth rate, and criticality classification; identify rebuild-from-source assets that do not need backup
- **RPO/RTO definition:** Three-tier recovery objectives — Tier 1 critical (RPO < 1 min, RTO < 15 min for business-critical data), Tier 2 important (RPO < 1 hour, RTO < 1 hour for tolerant data), Tier 3 operational (RPO < 24 hours, RTO < 4 hours for rebuildable data)
- **Tiered backup strategy:** Tier 1 gets streaming replication + continuous WAL archiving + daily full backups; Tier 2 gets periodic snapshots + cross-region replication + versioning; Tier 3 gets daily backups + rebuild procedures; all encrypted at rest (AES-256) with separate key management
- **Backup verification:** Automated schedule — per-run job completion and size checks, daily file readability and checksum verification, weekly restore test to test environment, monthly full restore with application smoke tests, weekly cross-region accessibility and encryption verification
- **Data integrity verification:** Row count consistency, SHA-256 checksum verification, foreign key integrity checks, application smoke tests against restored data, point-in-time accuracy validation (quarterly), cross-region consistency checks
- **Recovery procedures:** Step-by-step runbooks for primary database failure (automated failover + manual fallback), data corruption (point-in-time recovery, snapshot restore, selective restore), complete region failure (DR activation, DNS failover, return-to-primary procedure), with post-recovery actions and incident reporting
- **DR runbook generation:** Comprehensive document with recovery objectives, scenario index, backup status dashboard, escalation contacts, last test dates, and procedures executable by any on-call engineer

**Invocation:** `/godmode:backup`, "backup strategy", "disaster recovery", "what's our RPO?", "can we recover from", "what if we lose the database?"

**Key principle:** Backups that are not tested are not backups. A backup you have never restored is a hope, not a plan. Separate backup storage from production (different region, different account). Automate verification with alerting.

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/backup/SKILL.md` | Skill | Backup and disaster recovery workflow |
| `commands/godmode/backup.md` | Command | Usage reference for `/godmode:backup` |

**Iterations 165-174 (10 files, 5 skills, 5 commands)**

## 73. Search, Queue & Real-time Skills

### Overview

Three new skills extend Godmode into search engineering, asynchronous job processing, and real-time communication — the backbone of modern production applications. These skills address the full lifecycle from technology selection through production scaling, ensuring developers have structured workflows for features that are notoriously easy to get wrong.

### Skill: `/godmode:search` — Search Implementation & Relevance Engineering

**Purpose:** Design, build, and optimize full-text search functionality with measurable relevance.

**Capabilities:**
- **Engine selection:** Decision framework for Elasticsearch, Algolia, Meilisearch, Typesense, PostgreSQL FTS, and OpenSearch based on data volume, latency, and operational constraints
- **Index design:** Field mappings with searchable/filterable/sortable/facetable classification, weight boosting, and multi-field analysis (search analyzer, autocomplete analyzer, exact match)
- **Text analysis pipeline:** Configurable tokenizer, stemmer, stop words, synonyms, ASCII folding, and edge n-grams for autocomplete — with PostgreSQL tsvector setup and GIN index creation
- **Relevance tuning:** BM25/TF-IDF scoring combined with field boosting, recency decay, popularity signals, and personalization — with function_score queries and measurable test suites
- **Autocomplete:** Query suggestions, instant search (search-as-you-type), completion suggesters with context, and "did you mean" phrase suggestions — all with sub-50ms latency targets
- **Faceted search:** Terms, range, and hierarchical facets with aggregation queries, dynamic facet visibility, URL-encoded filter state, and OR-within/AND-across logic
- **Fuzzy matching:** AUTO fuzziness with prefix length constraints, transposition support, and max expansion limits to balance recall and performance
- **Index optimization:** Shard sizing (10-50GB target), replica management, refresh intervals, bulk indexing, query caching, and hot-warm-cold lifecycle management
- **Search analytics:** Zero-result rate, click-through rate, click position, NDCG, precision@k, and automated zero-result query analysis for continuous improvement

**Workflow:** Requirements Assessment -> Engine Selection -> Index Design -> Analyzer Configuration -> Relevance Tuning -> Autocomplete -> Faceted Search -> Fuzzy/Synonyms -> Optimization -> Analytics -> Artifacts

**Artifacts produced:**
- `search/mappings/<index>-mapping.json` — Index schema and mappings
- `search/analyzers/<index>-analyzers.json` — Text analysis configuration
- `search/synonyms/synonyms.txt` — Synonym dictionary
- `search/tests/relevance-tests.json` — Relevance test suite with expected results

**Flags:** `--engine <name>`, `--tune`, `--autocomplete`, `--facets`, `--index <name>`, `--analyze`, `--synonyms`, `--benchmark`, `--migrate`

### Skill: `/godmode:queue` — Message Queue & Job Processing

**Purpose:** Design, build, and debug asynchronous processing systems with correct delivery guarantees.

**Capabilities:**
- **Technology selection:** Decision framework for Kafka, RabbitMQ, SQS, BullMQ, Celery, Sidekiq, Redis Streams, and PostgreSQL SKIP LOCKED based on volume, ordering, and delivery needs
- **Queue architecture:** Multi-queue topology design with producer routing, priority levels (P0 critical through P4 background), separate worker pools, and dead letter queues
- **Retry strategies:** Exponential backoff with jitter (min(base * 2^attempt + random, max)), retryable vs non-retryable error classification, and configurable attempt limits
- **Dead letter handling:** Structured DLQ with original payload, attempt history, error details, and four processing options (replay, replay-with-fix, skip, escalate)
- **Delivery guarantees:** At-most-once, at-least-once, and exactly-once implementations with idempotency key pattern, distributed locks, and deduplication windows
- **Priority queues:** Separate queues and worker pools per priority level with SLA targets (P0 < 10s through P4 < 24h)
- **Rate limiting:** Token bucket, sliding window, concurrency limits, and leaky bucket patterns for external API call throttling
- **Worker pool design:** Min/max scaling, scale-up/down triggers, concurrency per worker, memory limits, health checks, and graceful shutdown with SIGTERM handling
- **Backpressure handling:** Escalating responses — warn at 1K depth, auto-scale at 10K, load-shed at 100K, circuit-break on downstream failures
- **Job scheduling:** Cron-based recurring jobs with distributed locks, overlap protection, idempotent creation, and timezone-safe UTC scheduling

**Workflow:** Requirements Assessment -> Technology Selection -> Queue Architecture -> Retry Strategy -> Dead Letter Handling -> Delivery Guarantees -> Priority Queues -> Rate Limiting -> Worker Pools -> Monitoring -> Artifacts

**Artifacts produced:**
- `config/queues/<queue-name>.ts` — Queue configuration
- `workers/<queue-name>-worker.ts` — Worker definitions
- `config/queues/retry-policy.ts` — Retry and DLQ configuration
- `config/queues/schedules.ts` — Scheduled job definitions

**Flags:** `--tech <name>`, `--diagnose`, `--dlq`, `--schedule`, `--retry`, `--scale`, `--monitor`, `--migrate`, `--benchmark`

### Skill: `/godmode:realtime` — Real-time Communication & Collaboration

**Purpose:** Design, build, and scale real-time features from notifications to collaborative editing.

**Capabilities:**
- **Protocol selection:** Decision framework for WebSocket, SSE, long polling, WebTransport, and gRPC streaming based on direction, concurrency, and browser support
- **Technology selection:** Socket.io, Pusher, Ably, Supabase Realtime, raw ws, and Redis pub/sub with trade-off analysis for features, cost, and operational complexity
- **Connection architecture:** Full lifecycle design — authentication during handshake, channel subscription with access control, heartbeat/keepalive, graceful disconnect, and multi-server fan-out via Redis pub/sub
- **Pub/sub channels:** Structured channel naming (user:<id>, room:<id>, document:<id>, feed:<type>, presence:<scope>), authorization levels (public, private, presence, user), and standard message format with event type, channel, timestamp, and sender
- **Presence system:** Redis-backed presence tracking with join/leave events, 5-second debounce for reconnections, multi-device support (online if ANY device connected), auto-away after idle, and heartbeat-based expiration
- **Typing indicators:** Debounced client-side emission (2s intervals), 5s server-side auto-expiry, rate limiting, and ephemeral broadcast with no persistence
- **Real-time collaboration:** CRDT (Yjs) and Operational Transform selection framework, Yjs implementation with shared text/map types, awareness API for live cursors and selections, offline editing with automatic merge, and undo/redo per user
- **Client-side resilience:** Exponential backoff reconnection (1s to 30s with 20% jitter), message queuing during disconnection, last-message-ID tracking for gap recovery, token refresh on auth failure, and tab-backgrounding optimization
- **Horizontal scaling:** Redis adapter for Socket.io, sticky sessions via Nginx IP hash or cookie, stateless server design, connection-based auto-scaling (not CPU), and per-instance connection limits with monitoring

**Workflow:** Requirements Assessment -> Protocol Selection -> Connection Architecture -> Channel Design -> Presence System -> Typing Indicators -> Collaboration (CRDT/OT) -> Client Reconnection -> Scaling -> Monitoring -> Artifacts

**Artifacts produced:**
- `realtime/server.ts` — WebSocket/SSE server configuration
- `realtime/channels.ts` — Channel definitions and authorization
- `realtime/presence.ts` — Presence tracking system
- `realtime/client.ts` — Client connection manager with reconnection
- `realtime/infra/` — Nginx config, Redis adapter, scaling configuration

**Flags:** `--protocol <name>`, `--tech <name>`, `--presence`, `--collab`, `--notifications`, `--scale`, `--chat`, `--typing`, `--audit`

### Integration with Existing Skills

The search, queue, and real-time skills integrate into the Godmode workflow at these points:

```
/godmode:think  ->  /godmode:search   ->  /godmode:plan  ->  /godmode:build
     |                   |                      |                  |
  Brainstorm        Design search          Decompose into     Implement
  the feature       index + relevance      tasks with TDD     search API

/godmode:think  ->  /godmode:queue    ->  /godmode:plan  ->  /godmode:build
     |                   |                      |                  |
  Brainstorm        Design queue           Decompose into     Implement
  async needs       architecture           tasks with TDD     workers

/godmode:think  ->  /godmode:realtime ->  /godmode:plan  ->  /godmode:build
     |                   |                      |                  |
  Brainstorm        Design WS/SSE          Decompose into     Implement
  live features     architecture           tasks with TDD     real-time
```

- **From `/godmode:think`:** After brainstorming, invoke the appropriate skill to formalize the architecture
- **From `/godmode:queue` to `/godmode:realtime`:** Queue events can trigger real-time notifications via pub/sub
- **From `/godmode:search` to `/godmode:queue`:** Index updates can be queued as background jobs for large datasets
- **From `/godmode:observe`:** Monitoring covers search latency, queue depth, WebSocket connection counts
- **From `/godmode:ship`:** Pre-ship checks verify search index health, queue worker status, and WebSocket scaling readiness
- **From `/godmode:secure`:** Security audit covers search input sanitization, queue message validation, and WebSocket authentication

### Design Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Simplest tool that works | PostgreSQL FTS before Elasticsearch; SSE before WebSocket; pg SKIP LOCKED before Kafka |
| 2 | Measure before tuning | Search relevance needs NDCG scores; queue health needs depth metrics; real-time needs latency P95 |
| 3 | Design for failure | Retry with backoff, dead letter queues, client reconnection, message recovery on reconnect |
| 4 | Idempotency everywhere | At-least-once delivery means handlers run twice; search re-indexing must be safe to repeat |
| 5 | Scale horizontally | Redis pub/sub for WebSocket fan-out; partitioned queues; sharded search indices |
| 6 | Ephemeral state is not data | Typing indicators, presence, cursor positions — broadcast and forget, never persist |
| 7 | Monitor the leading indicators | Queue depth (not throughput), zero-result rate (not query count), connection count (not CPU) |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/search/SKILL.md` | Skill | Search implementation and relevance engineering workflow |
| `skills/queue/SKILL.md` | Skill | Message queue and job processing workflow |
| `skills/realtime/SKILL.md` | Skill | Real-time communication and collaboration workflow |
| `commands/godmode/search.md` | Command | Usage reference for `/godmode:search` |
| `commands/godmode/queue.md` | Command | Usage reference for `/godmode:queue` |
| `commands/godmode/realtime.md` | Command | Usage reference for `/godmode:realtime` |

**Iterations 191-196 (6 files, 3 skills, 3 commands)**

## 74. Testing Mastery Skills

Three new skills extend Godmode's testing arsenal into deep unit testing mastery, real-dependency integration testing, and output verification through snapshots — covering the full testing spectrum from isolated functions to complex serialized outputs.

### 74.1 Unit Test — Unit Testing Mastery (`skills/unittest/SKILL.md`)

**Purpose:** Write high-quality, isolated unit tests with proper structure, mocking strategies, property-based testing, and mutation testing validation. Goes beyond basic test writing into testing craftsmanship.

**Key capabilities:**
- **Test structure patterns:** Arrange-Act-Assert (AAA) for input/output tests and Given-When-Then (GWT) for behavior-focused BDD-style tests, with framework-specific examples for Jest, Vitest, pytest, Go testing, and JUnit.
- **Mocking decision framework:** A systematic flowchart for choosing when to mock (external services, non-deterministic code) vs when to use real implementations. Covers all five test double types: stubs, mocks, spies, fakes, and dummies with clear use cases for each.
- **Property-based testing:** Identifies and implements property patterns — roundtrip/inverse, invariant preservation, idempotence, oracle/reference, and commutativity — using fast-check (JS/TS) and Hypothesis (Python). Includes shrinking interpretation for minimal failure reproduction.
- **Mutation testing:** Uses Stryker (JS/TS), mutmut (Python), PIT (Java), and go-mutesting (Go) to inject bugs and measure whether tests catch them. Analyzes surviving mutants and generates targeted tests to kill them.
- **Coverage vs confidence:** Distinguishes line coverage, branch coverage, and mutation score as signals of different quality. Sets pragmatic targets: >90% branch + >80% mutation score for critical logic, >80% branch for standard code.
- **Test naming and organization:** Enforces behavior-describing names, file organization mirroring source structure, and within-file ordering (happy path, alternatives, edge cases, errors, concurrency).

**Workflow:** Analyze unit under test -> Map dependencies -> Choose test structure -> Apply mocking strategy -> Write example-based tests -> Write property-based tests -> Run mutation testing -> Report coverage and confidence.

**Command:** `/godmode:unittest` (`commands/godmode/unittest.md`)

### 74.2 Integration — Integration Testing (`skills/integration/SKILL.md`)

**Purpose:** Test how components work together across real boundaries — databases, APIs, message queues, and caches — using disposable containerized infrastructure for isolation and reproducibility.

**Key capabilities:**
- **Testcontainers setup:** Full configuration for PostgreSQL, MySQL, MongoDB, Redis, Kafka, Elasticsearch, and LocalStack containers across Node.js, Python, Go, and Java with proper startup, connection, and teardown patterns.
- **Database seeding strategies:** Three approaches — migration-based seeding for schema, fixture factories with overridable defaults for test data, and SQL file seeding for large reference datasets. Includes Factory Boy (Python), custom builder patterns (TypeScript), and table-driven fixtures (Go).
- **Cleanup strategies:** Four options ranked by trade-off — transaction rollback (fastest, zero cleanup), TRUNCATE (fast, simple), unique data per test (no cleanup needed, best for parallel), and fresh container per test class (most isolated, slowest). Decision matrix for choosing the right strategy.
- **API integration testing:** Real HTTP request/response testing with supertest (Node.js), httpx (Python), httptest (Go), and MockMvc (Java). Covers authenticated endpoints, error responses, and persistence verification.
- **Service-level patterns:** Four integration patterns — service-to-database (transactional integrity), service-to-service (multi-service flows with mock servers for externals), message queue (producer/consumer through real brokers), and cache (hit/miss/invalidation behavior).
- **CI configuration:** Test tagging and separation (unit vs integration), GitHub Actions with service containers, and parallel execution strategies.

**Workflow:** Map integration boundaries -> Set up Testcontainers -> Create seed data and fixtures -> Choose cleanup strategy -> Write integration tests -> Configure CI separation -> Report.

**Command:** `/godmode:integration` (`commands/godmode/integration.md`)

### 74.3 Snapshot — Snapshot & Approval Testing (`skills/snapshot/SKILL.md`)

**Purpose:** Verify complex outputs against known-good baselines using snapshot testing, approval testing, and golden file patterns — with proper stabilization for non-deterministic values and update policies to prevent snapshot rot.

**Key capabilities:**
- **Suitability assessment:** Decision framework for when snapshot testing helps (complex deterministic output, infrequent changes) vs when it harms (non-deterministic output, too-large snapshots, constant changes). Prevents inappropriate snapshot usage.
- **Four strategies:** File-based snapshots for large outputs, inline snapshots for small reviewable outputs (<20 lines), approval testing for human-reviewed baselines, and golden file testing for deterministic artifacts (Go idiom with `-update` flag).
- **Non-deterministic handling:** Four stabilization approaches — value replacement before snapshot, custom serializers, property matchers (Jest), and deterministic injection via dependency inversion. Ensures flake-free snapshots.
- **Update policies:** Strict review-before-update policy with checklist. CI enforcement that fails on outdated snapshots and prevents `.received` file commits. Guards against blind `--updateSnapshot` runs.
- **Domain-specific patterns:** React/UI component snapshots (targeted over full-tree), API response snapshots (with structure stabilization), CLI output snapshots, and configuration/code generation snapshots.
- **Snapshot hygiene:** Detection of snapshot rot (blind updates, massive files, rubber-stamped reviews) with remediation strategies. Maximum size policies, inline migration, and obsolete snapshot cleanup.

**Workflow:** Evaluate suitability -> Choose strategy -> Stabilize non-deterministic values -> Write snapshot tests -> Configure CI enforcement -> Audit for rot -> Report.

**Command:** `/godmode:snapshot` (`commands/godmode/snapshot.md`)

### Integration with Existing Skills

The Testing Mastery skills integrate into the Godmode workflow at these points:

```
/godmode:test  ->  /godmode:unittest  ->  /godmode:integration  ->  /godmode:snapshot
     |                    |                       |                        |
  TDD workflow       Deep unit tests         Real-dependency         Output baseline
  & strategy         with mocking            boundary tests          verification
```

- **From `/godmode:test`:** The TDD skill delegates to `/godmode:unittest` for deep unit testing and to `/godmode:integration` for boundary tests
- **From `/godmode:unittest` to `/godmode:integration`:** When unit tests require heavy mocking, integration tests with real dependencies provide higher confidence
- **From `/godmode:integration` to `/godmode:contract`:** After integration tests pass, contract tests verify API compatibility across services
- **From `/godmode:snapshot`:** Snapshot tests complement behavioral tests from `/godmode:unittest` by verifying output structure
- **From `/godmode:quality`:** Quality analysis identifies test debt that these skills address
- **From `/godmode:review`:** Code review flags test quality issues and refers to specific testing skills

### Design Principles for Testing Mastery Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Test behavior, not implementation | Tests verify what code does, not how it does it |
| 2 | Mock at the boundary | Mock external services, use real implementations for internal logic |
| 3 | Property tests find what you miss | Generative testing discovers edge cases manual tests never cover |
| 4 | Mutation score over line coverage | Killing mutants proves tests actually verify correctness |
| 5 | Snapshots are assertions, not recordings | Every snapshot update is a deliberate behavior change |
| 6 | Real dependencies in integration tests | Testcontainers provide isolated, disposable, real infrastructure |
| 7 | Fast unit tests, thorough integration tests | Seconds for units, minutes for integration, separated in CI |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/unittest/SKILL.md` | Skill | Unit testing mastery with mocking, property testing, mutation testing |
| `skills/integration/SKILL.md` | Skill | Integration testing with Testcontainers and real dependencies |
| `skills/snapshot/SKILL.md` | Skill | Snapshot, approval, and golden file testing |
| `commands/godmode/unittest.md` | Command | Usage reference for `/godmode:unittest` |
| `commands/godmode/integration.md` | Command | Usage reference for `/godmode:integration` |
| `commands/godmode/snapshot.md` | Command | Usage reference for `/godmode:snapshot` |

**Iterations 197-202 (6 files, 3 skills, 3 commands)**

---

## 82. Data Visualization & Reporting Skills

This section covers three interconnected skills for data visualization, automated reporting, and analytics implementation. Together they form a complete data communication pipeline: collect data with analytics, visualize it with charts, and summarize it with reports.

### Skill Overview

| Skill | Command | Description |
|-------|---------|-------------|
| **Chart** | `/godmode:chart` | Data visualization — chart type selection (bar, line, scatter, heatmap, treemap, sankey), D3.js/Chart.js/Recharts/Plotly integration, dashboard design, responsive layouts, accessibility for data visualizations |
| **Report** | `/godmode:report` | Automated report generation — PDF, HTML, Markdown output, sprint retrospectives, code health reports, performance trend reports, metric dashboards |
| **Analytics** | `/godmode:analytics` | Analytics implementation — event tracking (Segment, Amplitude, Mixpanel, PostHog), funnel analysis, A/B test instrumentation, privacy-respecting analytics (Plausible, Umami), data modeling |

### Data Communication Pipeline

```
/godmode:analytics  ->  /godmode:chart  ->  /godmode:report
       |                      |                     |
  Collect data          Visualize data       Summarize & distribute
  (events, funnels,     (charts, dashboards, (PDF, HTML, Markdown
   experiments)          responsive, a11y)    reports with metrics)
```

### How the Skills Connect

- **From `/godmode:analytics` to `/godmode:chart`:** After implementing event tracking, build dashboards to visualize the collected analytics data
- **From `/godmode:chart` to `/godmode:report`:** Charts created by the chart skill can be embedded in generated reports
- **From `/godmode:analytics` to `/godmode:report`:** Analytics data feeds directly into metric dashboards and performance trend reports
- **From `/godmode:report` to `/godmode:plan`:** Action items from retrospectives and code health reports become sprint tasks
- **From `/godmode:optimize` to `/godmode:report`:** Optimization results are summarized in performance reports
- **From `/godmode:secure` to `/godmode:analytics`:** Security audit validates that analytics tracking respects privacy (no PII, consent gates)

### Integration with Existing Skills

| Connected Skill | Relationship |
|----------------|-------------|
| `/godmode:a11y` | Validates chart accessibility (colorblind-safe palettes, ARIA labels, data tables) |
| `/godmode:visual` | Visual regression testing for chart components and dashboard layouts |
| `/godmode:perf` | Performance profiling for chart rendering with large datasets |
| `/godmode:test` | Unit tests for data transformations and analytics event firing |
| `/godmode:secure` | Privacy audit for analytics (PII detection, consent compliance, GDPR) |
| `/godmode:plan` | Converts report action items into sprint tasks |
| `/godmode:optimize` | Acts on report recommendations to improve metrics |
| `/godmode:ui` | UI component architecture for chart components and dashboard layouts |

### Design Principles for Data Visualization & Reporting Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Data story first | Understand what needs to be communicated before choosing chart types or report formats |
| 2 | Accessibility is mandatory | Every chart has a colorblind-safe palette, ARIA labels, and a data table alternative |
| 3 | Privacy by default | No analytics tracking before consent, no PII in events, respect DNT |
| 4 | Automate the boring parts | Data collection and formatting are automated; humans focus on analysis and recommendations |
| 5 | Taxonomy before tracking | Design the event catalog before writing any tracking code |
| 6 | Trend over snapshot | Always show how metrics change over time, not just current values |
| 7 | A/B tests need statistical rigor | Calculate sample size, define metrics, run to completion before analyzing |
| 8 | Reports must be actionable | Every report includes specific next steps; a report without action items should not exist |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/chart/SKILL.md` | Skill | Data visualization workflow — chart selection, library integration, responsive design, accessibility |
| `skills/report/SKILL.md` | Skill | Report generation workflow — sprint retros, code health, performance trends, metric dashboards |
| `skills/analytics/SKILL.md` | Skill | Analytics implementation workflow — event tracking, funnels, A/B tests, privacy compliance |
| `commands/godmode/chart.md` | Command | Usage reference for `/godmode:chart` |
| `commands/godmode/report.md` | Command | Usage reference for `/godmode:report` |
| `commands/godmode/analytics.md` | Command | Usage reference for `/godmode:analytics` |

**Iterations 260-265 (6 files, 3 skills, 3 commands)**

---

## 71. Microservices & Distributed Systems Skills

### Overview

Three new skills extend Godmode into the microservices and distributed systems domain. These skills address the full spectrum of distributed architecture: from service decomposition and inter-service communication through event-driven patterns, caching strategies, and distributed transaction management.

### Skill: `/godmode:micro` — Microservices Design & Management

**Purpose:** Decompose monoliths, design service boundaries, and manage distributed service architectures.

**Capabilities:**
- **Service decomposition:** Domain-driven bounded context analysis with decomposition decision framework scoring business domain alignment, data ownership, team structure, and scaling needs
- **Inter-service communication:** Design sync (REST, gRPC) and async (events, messages) communication patterns with a decision matrix for pattern selection per interaction
- **Service mesh configuration:** Full Istio (VirtualService, DestinationRule, PeerAuthentication, AuthorizationPolicy) and Linkerd (ServiceProfile, TrafficSplit) configuration generation
- **Service discovery & load balancing:** DNS-based, client-side, server-side, and service mesh discovery patterns with load balancing strategy selection (round robin, least request, consistent hash, weighted)
- **Saga pattern:** Choreography-based (event-driven) and orchestration-based (central coordinator) saga design with compensation flows, state machines, and persistence schemas
- **Resilience patterns:** Circuit breaker, timeout, retry with backoff, bulkhead, rate limiting, and fallback configuration per downstream service
- **Architecture validation:** 14-point checklist covering bounded contexts, data ownership, communication patterns, mesh configuration, health checks, and independent deployability

**Workflow:** System Assessment -> Decomposition -> Communication Design -> Service Mesh -> Service Discovery -> Saga Design -> Topology -> Resilience -> Validation -> Artifacts

**Artifacts produced:**
- `docs/architecture/<system>-topology.md` — Service topology diagram
- `docs/architecture/<system>-services.md` — Service catalog and registry
- `docs/architecture/<system>-communication.md` — Communication contracts
- `docs/architecture/<system>-sagas.md` — Saga definitions with compensation flows
- `k8s/mesh/` or `infra/mesh/` — Service mesh configuration

**Flags:** `--decompose`, `--communication`, `--saga <name>`, `--mesh istio|linkerd`, `--topology`, `--validate`, `--resilience`, `--migrate`

### Skill: `/godmode:event` — Event-Driven Architecture

**Purpose:** Design event sourcing, CQRS, message broker topologies, and event processing pipelines with production-grade reliability patterns.

**Capabilities:**
- **Event sourcing:** Event store schema design with aggregate reconstruction, snapshot optimization, and full state replay from immutable event history
- **CQRS implementation:** Separate write model (command handlers + event store) and read model (projections + denormalized query databases) with projection lifecycle management
- **Message broker design:** Complete topology configuration for Kafka (topics, partitions, consumer groups, producer/consumer configs), RabbitMQ (exchanges, queues, bindings, routing), SQS/SNS (topics, queues, filters, visibility), and NATS (subjects, JetStream streams, consumers)
- **Event schema design:** Standard event envelope with correlation/causation IDs, schema registry integration (Avro, JSON Schema, Protobuf), and backward/forward compatibility versioning
- **Dead letter queues:** DLQ design with enriched failure metadata, retry policies with exponential backoff (5 attempts: immediate -> 5 minutes), and replay tooling
- **Idempotency patterns:** Deduplication table design, idempotency key processing, natural idempotency identification, and transactional consume-and-mark-processed

**Workflow:** Assessment -> Event Sourcing -> CQRS -> Broker Design -> Schema Versioning -> DLQ & Retry -> Idempotency -> Validation -> Artifacts

**Artifacts produced:**
- `docs/events/<system>-event-catalog.md` — Event catalog with all event types
- `schemas/<domain>/<event>.avsc` — Schema definitions (Avro, JSON Schema, or Protobuf)
- `docs/events/<system>-broker-topology.md` — Broker topology documentation
- `docs/events/<system>-cqrs.md` — CQRS design with projections
- `infra/messaging/` — DLQ and retry configuration

**Flags:** `--sourcing`, `--cqrs`, `--broker kafka|rabbitmq|sqs|nats`, `--schema`, `--dlq`, `--idempotency`, `--catalog`, `--validate`

### Skill: `/godmode:cache` — Caching Strategy

**Purpose:** Design and implement multi-layer caching with proper invalidation, stampede prevention, and operational monitoring.

**Capabilities:**
- **Cache layer design:** Multi-layer architecture (CDN/edge, application/Redis, database query cache) with hot path analysis identifying cacheable endpoints, QPS, latency, and TTL recommendations
- **Cache invalidation strategies:** TTL-based (per data volatility), event-based (near-real-time via domain events), write-through (synchronous cache + DB write), and write-behind (async flush for write-heavy workloads) with a decision matrix for strategy selection
- **Redis configuration:** Cluster topology (masters + replicas), memory eviction policies (allkeys-lru, volatile-lru, allkeys-lfu), connection pooling, key naming conventions, and data structure selection (strings, hashes, sorted sets, HyperLogLog, etc.)
- **Memcached configuration:** Consistent hashing, multi-node deployment, and side-by-side comparison with Redis for technology selection
- **Varnish / CDN configuration:** VCL rules for HTTP acceleration, CDN cache headers (Cache-Control, Surrogate-Control, Surrogate-Key), conditional requests (ETag), and tag-based purge
- **Cache stampede prevention:** Four patterns — mutex locking, probabilistic early expiration (PER), stale-while-revalidate (background refresh), and proactive pre-warming — with complexity and latency trade-off comparison
- **Cache monitoring:** Hit rate, latency, eviction, memory, and connection metrics with alert thresholds and dashboard layout

**Workflow:** Assessment -> Layer Design -> Invalidation Strategy -> Redis/Memcached Config -> CDN/Varnish Config -> Stampede Prevention -> Monitoring -> Validation -> Artifacts

**Artifacts produced:**
- `docs/caching/<system>-cache-strategy.md` — Cache design documentation
- `infra/cache/` — Redis or Memcached configuration
- `src/lib/cache.ts` — Cache utility module
- `infra/cdn/` or `infra/varnish/` — CDN/Varnish configuration
- `monitoring/dashboards/cache.json` — Cache monitoring dashboard

**Flags:** `--assess`, `--redis`, `--memcached`, `--cdn`, `--varnish`, `--invalidation`, `--stampede`, `--monitor`, `--warmup`, `--validate`, `--benchmark`

### Integration with Existing Skills

The microservices and distributed systems skills integrate into the Godmode workflow at these points:

```
/godmode:architect -> /godmode:micro -> /godmode:event -> /godmode:cache -> /godmode:api -> /godmode:build
       |                   |                  |                |                |               |
  Choose arch.        Decompose         Design event      Add caching     Define APIs     Implement
  style (micro)       services          layer             layers          per service     endpoints
```

- **From `/godmode:architect`:** After choosing a microservices architecture style, invoke `/godmode:micro` to design service boundaries
- **From `/godmode:micro` to `/godmode:event`:** After defining services, design the async event layer for inter-service communication
- **From `/godmode:event` to `/godmode:cache`:** After event infrastructure, add caching layers to reduce load and latency
- **From `/godmode:micro` to `/godmode:api`:** Design REST/gRPC APIs for each service's synchronous interfaces
- **From `/godmode:cache` to `/godmode:perf`:** After caching, benchmark to verify performance improvement
- **From `/godmode:micro` to `/godmode:k8s`:** Deploy the designed services to Kubernetes
- **From `/godmode:observe`:** Monitor service communication latency, event consumer lag, and cache hit rates
- **From `/godmode:micro` to `/godmode:contract`:** Define contracts between services for compatibility testing

### Design Principles for Microservices & Distributed Systems Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Decompose by business capability | Services map to bounded contexts, not technical layers |
| 2 | Each service owns its data | No shared databases — services communicate via APIs or events |
| 3 | Default to asynchronous | Use events unless the caller genuinely needs an immediate response |
| 4 | Events are immutable facts | Once published, events cannot be changed — publish corrective events instead |
| 5 | Every consumer is idempotent | At-least-once delivery means duplicates will happen — handle them |
| 6 | Cache the right things | High-read, low-write data with clear invalidation strategy |
| 7 | Always set a TTL | No cache key lives forever — staleness and memory leaks are inevitable without expiry |
| 8 | Resilience is infrastructure | Circuit breakers, retries, and mTLS belong in the service mesh, not application code |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/micro/SKILL.md` | Skill | Microservices design and management workflow |
| `skills/event/SKILL.md` | Skill | Event-driven architecture workflow |
| `skills/cache/SKILL.md` | Skill | Caching strategy workflow |
| `commands/godmode/micro.md` | Command | Usage reference for `/godmode:micro` |
| `commands/godmode/event.md` | Command | Usage reference for `/godmode:event` |
| `commands/godmode/cache.md` | Command | Usage reference for `/godmode:cache` |

**Iterations 181-186 (6 files, 3 skills, 3 commands)**

---

## 76. Git & Version Control Skills

Three new skills extend Godmode into Git mastery, pull request excellence, and release management — the foundation of every professional development workflow.

### 76.1 Advanced Git Workflows (`/godmode:git`)

**Purpose:** Master advanced Git workflows including branching strategies, merge/rebase decisions, interactive rebase, git bisect, cherry-picking, stashing, worktree management, and commit message conventions.

**Workflow:**
1. **Assess** — Evaluate repository context (team size, release cadence, CI/CD, hosting platform)
2. **Branching Strategy** — Recommend and configure the right model:
   - **GitFlow** — For scheduled release cycles with QA phases and multiple versions in production
   - **Trunk-Based** — For continuous delivery with short-lived branches (< 2 days) and feature flags
   - **GitHub Flow** — Default recommendation for most teams using PR-based workflows
   - **Ship/Show/Ask** — For high-trust senior teams that want speed without bureaucracy
3. **Merge Strategy** — Choose between merge commits, squash merge, and rebase based on team size and history needs
4. **Interactive Rebase** — Restructure commit history before merging (squash WIP, reword messages, split commits, reorder for narrative)
5. **Git Bisect** — Binary search through history to find regressions (manual and automated with test scripts)
6. **Cherry-Pick & Stash** — Selective commit application patterns and work-in-progress management
7. **Worktree Management** — Parallel development without context switching (hotfix while coding, PR review in isolation)
8. **Commit Conventions** — Conventional Commits format with commitlint + husky enforcement

**Branching Decision Matrix:**

| Factor | GitFlow | Trunk-Based | GitHub Flow | Ship/Show/Ask |
|--------|---------|-------------|-------------|---------------|
| Team size | Any | Senior | Any | Senior |
| Release cadence | Scheduled | Continuous | Daily-weekly | Continuous |
| CI/CD required | No | Yes | Recommended | Yes |
| Feature flags | Optional | Required | Optional | Recommended |
| Code review | Optional | Optional | Required | Varies |

**Key principles:** Match workflow to team, consistency beats perfection, history should tell a story, never rebase public branches, bisect before manual search, stashes are temporary, worktrees eliminate context switching.

**Flags:** `--strategy`, `--merge`, `--rebase`, `--bisect`, `--bisect-auto <script>`, `--cherry-pick <SHA>`, `--stash`, `--worktree`, `--conventions`, `--cleanup`, `--audit`

### 76.2 Pull Request Excellence (`/godmode:pr`)

**Purpose:** Create optimally-sized, well-documented pull requests with automated labeling, strategic reviewer assignment, stacked PR patterns for large features, and cycle time metrics.

**Workflow:**
1. **Assess** — Analyze change size (XS/S/M/L/XL), categorize (feature/fix/refactor/docs), determine risk
2. **Size Optimization** — Split large PRs using strategies: by layer, by feature slice, by refactor+feature, by test+implementation
3. **Description Template** — Generate PR descriptions with Summary, Problem, Solution, Changes, Testing, Screenshots, Checklist, and Reviewer Notes sections
4. **Stacked PRs** — Decompose large features into dependent, sequential PRs with correct base branches and merge order
5. **Review Requests** — Configure CODEOWNERS, round-robin assignment, domain expert tagging, and review SLAs
6. **Auto-Labeling** — Set up rules for automatic labels based on file paths, branch names, PR size, and content
7. **Metrics** — Track time to first review, review rounds, total cycle time, PR size distribution, and reviewer load balance

**PR Size Impact:**

| Size | Review Quality | Time to Merge | Bug Escape Rate |
|------|---------------|---------------|-----------------|
| < 50 LOC | Thorough | < 1 hour | Very low |
| 50-200 | Good | < 4 hours | Low |
| 200-500 | Declining | 1-3 days | Moderate |
| 500+ | Rubber stamp | 3+ days | High |

**Key principles:** Small PRs are non-negotiable, description is for the reviewer, self-review first, stacked PRs for large features, automate boring parts, measure and improve, review others promptly.

**Flags:** `--template`, `--split`, `--stack`, `--metrics`, `--labels`, `--codeowners`, `--size-check`, `--self-review`, `--retarget`

### 76.3 Release Management (`/godmode:release`)

**Purpose:** Manage software releases with semantic versioning, automated changelog generation, release notes, branching/tagging, hotfix workflows, and release train scheduling.

**Workflow:**
1. **Assess** — Evaluate current version, release maturity, cadence, and automation level
2. **Semantic Versioning** — Determine correct bump from Conventional Commits (MAJOR for breaking, MINOR for features, PATCH for fixes)
3. **Release Notes** — Generate audience-appropriate notes with Highlights, Breaking Changes, New Features, Bug Fixes, Performance, Deprecations, and Contributors
4. **Changelog Automation** — Maintain Keep a Changelog format with tools (release-please, semantic-release, changesets, git-cliff)
5. **Branching & Tagging** — Three patterns: tag from main (simple), release branches (stabilization), support branches (multiple versions)
6. **Hotfix Workflow** — Emergency production fixes: branch from tag, minimal fix + regression test, expedited review, immediate deploy, cherry-pick to other branches
7. **Release Train** — Scheduled cadence: develop phase, feature freeze, QA, release candidate, ship, monitor
8. **Automation Pipeline** — CI/CD integration with release-please or semantic-release for fully automated versioning, changelog, tagging, and publishing

**Release Automation Tools:**

| Tool | Approach | Best For |
|------|----------|----------|
| release-please | Automated Release PRs | Most teams (recommended) |
| semantic-release | Fully automated on push | CI/CD-mature teams |
| changesets | Per-PR changelog fragments | Monorepos |
| standard-version | Bump + changelog + tag | npm projects |
| git-cliff | Configurable generator | Customization needs |

**Hotfix timeline target:** Bug detected to fix in production within 2 hours.

**Key principles:** Version numbers have meaning, changelog is for humans, automate releases, hotfixes are special, release trains keep cadence, breaking changes require migration guides, every release is tagged.

**Flags:** `--setup`, `--bump <type>`, `--pre-release <tag>`, `--hotfix`, `--notes`, `--changelog`, `--dry-run`, `--schedule`, `--status`, `--history`

### 76.4 Skill Interactions

The three Git & Version Control skills form a development lifecycle pipeline:

```
/godmode:git ──→ /godmode:pr ──→ /godmode:release ──→ /godmode:deploy
(workflows)      (pull requests)   (versioning)         (deployment)
```

Integration with existing skills:
- `/godmode:review` — PR skill feeds into code review before merge
- `/godmode:ship` — Release skill coordinates with shipping workflow
- `/godmode:deploy` — Release tags trigger deployment pipelines
- `/godmode:finish` — Branch cleanup after PR merge

### Design Principles for Git & Version Control Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Match workflow to team | Never recommend GitFlow for a 2-person team or Ship/Show/Ask for juniors |
| 2 | Small PRs over large PRs | Every recommendation prioritizes reviewability and fast cycle time |
| 3 | Automate the ceremony | Labels, assignments, changelogs, and version bumps should not require human effort |
| 4 | History tells a story | Commits on main should be clean, logical, and bisect-friendly |
| 5 | Releases are contracts | Semantic versioning is a promise to users — respect the contract |
| 6 | Hotfixes are sacred | Emergency fixes follow a strict, minimal-change workflow with no scope creep |
| 7 | Measure and improve | Track PR cycle time, review rounds, and release frequency to drive improvement |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/git/SKILL.md` | Skill | Advanced Git workflows |
| `skills/pr/SKILL.md` | Skill | Pull request excellence |
| `skills/release/SKILL.md` | Skill | Release management |
| `commands/godmode/git.md` | Command | Usage reference for `/godmode:git` |
| `commands/godmode/pr.md` | Command | Usage reference for `/godmode:pr` |
| `commands/godmode/release.md` | Command | Usage reference for `/godmode:release` |

**Iterations 211-216 (6 files, 3 skills, 3 commands)**

---

## 83. Security Specialization Skills

Deep security specialization skills that extend beyond the general `/godmode:secure` audit to cover penetration testing, DevSecOps pipeline integration, and cryptographic implementation.

### Skill Overview

| Skill | Command | Purpose |
|-------|---------|---------|
| **Pentest** | `/godmode:pentest` | Authorized penetration testing with reconnaissance, OWASP-methodology exploitation, API security testing, and formal report writing |
| **DevSecOps** | `/godmode:devsecops` | Security integration into CI/CD pipelines — SAST, DAST, SCA, container scanning, secret scanning, and security gates |
| **Crypto** | `/godmode:crypto` | Correct cryptographic implementation — encryption, key management, password hashing, digital signatures, JWT security, TLS hardening |

### Pentest Skill (`/godmode:pentest`)

The penetration testing skill provides structured, authorized security testing following OWASP methodology:

- **Authorization verification** — mandatory scope agreement before any testing begins
- **Reconnaissance** — passive information gathering (tech stack, public exposure, dependency CVEs) and active enumeration (endpoints, input vectors, user roles)
- **Vulnerability assessment** — systematic OWASP Top 10 testing: broken access control, cryptographic failures, injection (SQL, XSS, command, NoSQL, SSTI), insecure design, misconfiguration, vulnerable components, authentication failures, integrity failures, logging gaps, SSRF
- **API security testing** — BOLA, BFLA, mass assignment, rate limiting, data exposure, authentication bypass
- **Web app testing** — DOM XSS, prototype pollution, storage security, WebSocket auth, file upload, CSRF, clickjacking
- **Proof-of-concept creation** — minimal-impact exploitation evidence with reproducible steps
- **Report writing** — executive summary, findings with severity/CVSS, remediation priority (24h/1wk/1mo/ongoing)

Flags: `--recon`, `--assess`, `--api`, `--web`, `--auth`, `--injection`, `--deps`, `--retest`, `--quick`, `--report`

### DevSecOps Skill (`/godmode:devsecops`)

The DevSecOps skill integrates security controls into CI/CD pipelines with a maturity model:

- **Pipeline assessment** — evaluate current security maturity (Level 0-5) and identify gaps
- **SAST integration** — Semgrep (OWASP + CWE rulesets), CodeQL (data flow analysis), SonarQube (quality gates)
- **DAST integration** — OWASP ZAP (baseline + full scan), Burp Suite Enterprise (crawl and audit)
- **SCA** — Snyk, npm/pip/cargo audit, Dependabot/Renovate auto-update PRs, SBOM generation (SPDX/CycloneDX)
- **Container scanning** — Trivy (image + IaC + fs), Snyk Container, hardening checks (non-root, pinned tags, multi-stage builds)
- **Secret scanning** — gitleaks pre-commit + CI, trufflehog scheduled deep scan, GitHub push protection, custom patterns
- **IaC security** — Checkov, tfsec for Terraform/Kubernetes/Dockerfile misconfigurations
- **Security gates** — blocking gates per severity, documented override process with expiry, metrics dashboard
- **Artifact signing** — cosign for containers, sigstore for provenance, GPG for commits

Maturity levels:
- Level 0: No security in pipeline
- Level 1: Basic dependency scanning
- Level 2: SAST + SCA + secret scanning
- Level 3: Full SAST/DAST/SCA + container scanning
- Level 4: Security gates + SBOM + signed artifacts
- Level 5: Continuous verification + policy-as-code

Flags: `--assess`, `--sast`, `--dast`, `--sca`, `--containers`, `--secrets`, `--gates`, `--iac`, `--sbom`, `--metrics`, `--platform <name>`

### Crypto Skill (`/godmode:crypto`)

The cryptography skill ensures correct algorithm selection and implementation:

- **Algorithm selection guide** — definitive recommendations for every use case: passwords (Argon2id), symmetric encryption (AES-256-GCM), asymmetric (X25519, RSA-OAEP), signatures (Ed25519, RS256), hashing (SHA-256, BLAKE3), KDF (HKDF), RNG (CSPRNG)
- **Encryption at rest** — envelope encryption pattern with KMS, application-level field encryption, database-level TDE + column encryption
- **Encryption in transit** — TLS 1.2/1.3 hardening (Nginx/Apache configs), AEAD-only cipher suites, forward secrecy via ECDHE, HSTS with preload, OCSP stapling
- **Password hashing** — Argon2id (m=64MB, t=3, p=4) or bcrypt (cost 12+), hash upgrade migration on login, breach list checking
- **JWT security** — algorithm selection by architecture (HS256 single-service, RS256/ES256 multi-service), mandatory claim verification (iss, aud, exp), JWKS endpoint for key distribution
- **Digital signatures** — Ed25519 for documents, HMAC-SHA256 for API request signing, cosign for container images
- **Key management lifecycle** — generation (CSPRNG, KMS), storage (KMS/Vault), distribution (JWKS, envelopes), rotation (scheduled + emergency), revocation (CRL, OCSP, blacklist), destruction (crypto-shred)

Flags: `--passwords`, `--encrypt`, `--tls`, `--jwt`, `--signatures`, `--keys`, `--audit`, `--migrate`, `--test`

### Integration with Existing Skills

The security specialization skills form a comprehensive security workflow:

```
/godmode:secure  ->  /godmode:pentest  ->  /godmode:fix  ->  /godmode:pentest --retest
     |                                          |
  STRIDE + OWASP              Verify fixes with re-testing
  audit identifies             after remediation
  areas to test

/godmode:devsecops  ->  /godmode:cicd  ->  /godmode:ship
     |                       |                  |
  Security controls     Pipeline config    Deploy through
  integrated into       with gates         secure pipeline
  CI/CD workflow

/godmode:crypto  ->  /godmode:auth  ->  /godmode:secrets
     |                    |                   |
  Algorithm          Token signing       Key storage
  selection and      and password        and rotation
  implementation     hashing             management
```

- **From `/godmode:secure`:** General security audit identifies areas needing deeper testing via `/godmode:pentest`
- **From `/godmode:pentest`:** Findings feed into `/godmode:fix` for remediation, then `/godmode:pentest --retest` for verification
- **From `/godmode:devsecops`:** Pipeline security integrates with `/godmode:cicd` configuration and `/godmode:ship` deployment
- **From `/godmode:crypto`:** Cryptographic implementation supports `/godmode:auth` (password hashing, JWT signing) and `/godmode:secrets` (key management)
- **All three to `/godmode:ship`:** Security specialization skills are pre-ship quality gates

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/pentest/SKILL.md` | Skill | Authorized penetration testing workflow |
| `skills/devsecops/SKILL.md` | Skill | DevSecOps pipeline security integration |
| `skills/crypto/SKILL.md` | Skill | Cryptographic implementation guidance |
| `commands/godmode/pentest.md` | Command | Usage reference for `/godmode:pentest` |
| `commands/godmode/devsecops.md` | Command | Usage reference for `/godmode:devsecops` |
| `commands/godmode/crypto.md` | Command | Usage reference for `/godmode:crypto` |

**Iterations 266-271 (6 files, 3 skills, 3 commands)**

---

## 86. Productivity & Project Management Skills

Four new skills bring structured developer productivity and project management workflows into Godmode — from daily standups and sprint retrospectives through task prioritization and scope management.

### Daily Standup & Progress Tracking (`/godmode:standup`)

**Purpose:** Automated standup report generation from git activity with blocker detection and sprint metrics.

**Workflow:**
1. **Gather** — Scan git log, PRs, branches, and issue references for the lookback period (default: 24 hours)
2. **Report** — Generate structured standup following Yesterday / Today / Blockers / Metrics format
3. **Detect Blockers** — Identify stale PRs (>24h), failing CI, stuck tasks, and dependency issues with severity classification (MEDIUM/HIGH/CRITICAL)
4. **Burndown** — Track sprint progress against ideal burndown with risk assessment (On Track / At Risk / Off Track)
5. **Velocity** — Calculate rolling averages across sprints with confidence ranges for sprint commitment planning

**Blocker Escalation:**
| Severity | Signal | Action |
|----------|--------|--------|
| MEDIUM | PR open >24h, task in progress >3 days | Flag in standup report |
| HIGH | PR open >48h, upstream dependency blocked | Flag with recommended owner |
| CRITICAL | Build failing on main, production issue | Recommend immediate attention, link to `/godmode:incident` |

**Key Principle:** Evidence-based reporting. Every item in "Yesterday" is backed by a commit, PR, or review. No self-reported fluff.

**Chaining:** `/godmode:standup` -> `/godmode:scope` (scope adjustment) | `/godmode:prioritize` (blocker triage) | `/godmode:incident` (critical blockers)

### Retrospective & Team Health (`/godmode:retro`)

**Purpose:** Facilitate sprint retrospectives, track team health metrics, manage action items, and measure continuous improvement.

**Workflow:**
1. **Context** — Gather sprint metrics, git history, incidents, and previous action items
2. **Format** — Choose from 5 retrospective formats (Start/Stop/Continue, 4Ls, Mad/Sad/Glad, Sailboat, What Went Well)
3. **Facilitate** — Guide through Set the Stage, Gather Data, Generate Insights, Define Action Items
4. **Health** — Score team health across 8 dimensions (Delivery Pace, Code Quality, Technical Debt, Testing Confidence, Documentation, CI/CD Reliability, Developer Experience, Process Efficiency)
5. **Improve** — Track improvement trends across sprints, escalate recurring themes (3+ appearances)

**Action Item Rules:**
- Maximum 3 action items per retro (more means nothing gets done)
- Each action has an owner (not "the team"), a deadline, and verifiable completion criteria
- Previous actions are reviewed at the start of every retro

**Health Scoring (1-5):**
| Score | Meaning | Action |
|-------|---------|--------|
| 5 | Excellent | No improvement needed |
| 4 | Good | Minor improvements possible |
| 3 | Adequate | Noticeable room for improvement |
| 2 | Struggling | Needs focused attention |
| 1 | Critical | Blocking team effectiveness |

**Key Principle:** Blameless or useless. The prime directive applies to every retrospective. Focus on systems and processes, not individuals.

**Chaining:** `/godmode:retro` -> `/godmode:prioritize` (prioritize action items) | `/godmode:plan` (plan improvement initiatives)

### Task Prioritization (`/godmode:prioritize`)

**Purpose:** Structured prioritization using established frameworks with dependency awareness and technical debt trade-offs.

**Frameworks:**
| Framework | Best For | Type |
|-----------|----------|------|
| RICE | Large backlogs (>20 items), product features | Quantitative (Reach x Impact x Confidence / Effort) |
| ICE | Quick scoring (5-20 items) | Quantitative (Impact x Confidence x Ease) |
| MoSCoW | Release planning, scope negotiation | Categorical (Must/Should/Could/Won't) |
| Effort-Impact | Visual triage, quick decisions | 2x2 matrix (Quick Wins / Big Bets / Fill-Ins / Money Pit) |

**Dependency-Aware Scheduling:**
- Items that unblock multiple others receive priority bumps
- Critical path items are scheduled first
- Independent items are parallelized
- Blocked items are deferred until blockers resolve

**Technical Debt Allocation:**
| Debt Level | Ratio | Recommended Split |
|------------|-------|-------------------|
| Low (<15%) | <15% of backlog | 80% features / 20% debt |
| Medium | 15-30% | 70% features / 30% debt |
| High | 30-50% | 50% features / 50% debt |
| Critical | >50% | 30% features / 70% debt |

**Key Principle:** Frameworks over gut feeling. Every prioritization uses a named framework with visible scores and reasoning.

**Chaining:** `/godmode:prioritize` -> `/godmode:plan` (plan top items) | `/godmode:scope` (scope highest priority) | `/godmode:refactor` (tackle high-value debt)

### Scope Management (`/godmode:scope`)

**Purpose:** Feature decomposition, MVP definition, scope creep detection, requirements validation, and user story writing.

**Workflow:**
1. **Decompose** — Break features into capabilities with T-shirt size estimates, explicit in/out scope boundaries
2. **MVP** — Identify minimum viable set using the removal test: if removing an item does not break the core flow, it is V2
3. **Creep Detection** — Compare current state to original scope, quantify drift percentage with severity (GREEN/YELLOW/ORANGE/RED)
4. **Validate** — Check requirements for completeness, consistency, testability, and ambiguity
5. **Stories** — Generate INVEST-quality user stories with Gherkin acceptance criteria (GIVEN/WHEN/THEN)
6. **Document** — Produce scope document with problem statement, MVP, stories, assumptions, and open questions

**Scope Creep Severity:**
| Drift | Severity | Action |
|-------|----------|--------|
| 0-10% | GREEN | Normal refinement, continue |
| 10-25% | YELLOW | Review with stakeholders |
| 25-50% | ORANGE | Scope review required |
| >50% | RED | Stop and re-scope |

**MVP Test:** Can the user complete the core flow with only MVP items? Does removing any MVP item break that flow? If both answers are yes, the MVP is correctly scoped.

**Key Principle:** Explicit boundaries. Every scope document has an "Out of Scope" section. What you choose NOT to build is as important as what you build.

**Chaining:** `/godmode:scope` -> `/godmode:think` (design solution) | `/godmode:plan` (plan implementation) | `/godmode:build` (build MVP)

### Workflow Integration

The Productivity & Project Management skills form a sprint lifecycle:

```
/godmode:scope       -> Define what to build
/godmode:prioritize  -> Decide what to build first
/godmode:plan        -> Plan implementation
/godmode:build       -> Execute the plan
/godmode:standup     -> Track daily progress
/godmode:retro       -> Reflect and improve
```

### Design Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Evidence over opinion | Standups from git data, prioritization from frameworks, health from metrics |
| 2 | Explicit boundaries | Every scope has in/out, every sprint has capacity, every retro has max 3 actions |
| 3 | Track over time | Velocity, health, and improvement trends across sprints |
| 4 | Blameless culture | Retros follow the prime directive, blockers name systems not people |
| 5 | Ruthless MVP | Remove items until removing one more would break the core flow |
| 6 | Dependencies are first-class | Prioritization accounts for blocking relationships, not just individual scores |
| 7 | Debt is not optional | Technical debt gets allocated capacity every sprint based on measured ratio |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/standup/SKILL.md` | Skill | Daily standup and progress tracking workflow |
| `skills/retro/SKILL.md` | Skill | Retrospective and team health workflow |
| `skills/prioritize/SKILL.md` | Skill | Task prioritization with scoring frameworks |
| `skills/scope/SKILL.md` | Skill | Scope management with MVP and creep detection |
| `commands/godmode/standup.md` | Command | Usage reference for `/godmode:standup` |
| `commands/godmode/retro.md` | Command | Usage reference for `/godmode:retro` |
| `commands/godmode/prioritize.md` | Command | Usage reference for `/godmode:prioritize` |
| `commands/godmode/scope.md` | Command | Usage reference for `/godmode:scope` |

**Iterations 284-291 (8 files, 4 skills, 4 commands)**

---

## 75. Developer Experience Skills

### Overview

Four new skills extend Godmode into the developer experience domain, covering the entire spectrum of DX concerns: from environment setup and feedback loops through linting, type safety, and monorepo management. These skills address the toolchain, processes, and infrastructure that determine how productive developers are day-to-day.

### Skill: `/godmode:dx` — Developer Experience Optimization

**Purpose:** Audit and improve the full developer experience across environment setup, feedback loops, error messages, CLI tooling, and internal developer portals.

**Capabilities:**
- **DX audit:** Score developer experience across 5 dimensions (environment setup, feedback loops, error messages, CLI/tooling, documentation) with measurable metrics
- **Environment automation:** One-command setup scripts, devcontainer configuration, Docker Compose, Nix flakes, and runtime version management (mise/asdf)
- **Hot reload & feedback loops:** Vite HMR optimization, test watch modes (Jest/Vitest/pytest-watch), incremental type checking, and file watcher tuning
- **Error message improvement:** Audit all error throw sites, classify by actionability, transform cryptic errors into diagnostics with context, remediation steps, and documentation links
- **CLI tool design:** Framework selection (commander, oclif, cobra, click, typer), help text, autocomplete, progress indicators, JSON output, and NO_COLOR support
- **Developer portal:** Service catalog (Backstage-compatible), API discovery, runbook library, environment provisioning, and feature flag management

**Workflow:** DX Audit -> Environment Setup -> Feedback Loop Optimization -> Error Message Improvement -> CLI Design -> Developer Portal -> Improvement Plan -> Commit

**Artifacts produced:**
- `scripts/setup.sh` — One-command development environment setup
- `.devcontainer/devcontainer.json` — VS Code devcontainer configuration
- `src/errors/` — Structured error class hierarchy
- DX audit report with before/after scores

**Flags:** `--setup`, `--feedback`, `--errors`, `--cli`, `--portal`, `--audit-only`, `--quick-wins`, `--before-after`

### Skill: `/godmode:monorepo` — Monorepo Management

**Purpose:** Set up, configure, and optimize monorepo architecture with the right tooling, boundaries, and CI strategies.

**Capabilities:**
- **Tool selection:** Guided decision tree for Turborepo, Nx, Lerna, Bazel, Rush, and pnpm workspaces based on project size, language mix, and team preferences
- **Package boundary enforcement:** Dependency rules preventing apps from importing other apps, detecting circular dependencies, and enforcing declared dependencies with Nx module boundaries or custom checkers
- **Selective builds and testing:** Change detection that only builds and tests affected packages, with path filtering in CI (dorny/paths-filter), Turborepo `--filter`, and Nx `affected`
- **Dependency graph management:** Visualization, health checks (circular deps, orphan packages, hub packages, chain depth), and graph maintenance
- **Shared configuration:** Centralized tsconfig, ESLint, and Prettier configs in a `packages/config/` package that all other packages extend
- **Remote caching:** Turborepo remote cache (Vercel), Nx Cloud, or self-hosted cache for dramatically faster CI and local builds

**Workflow:** Assessment -> Tool Selection -> Package Structure -> Boundary Enforcement -> Selective Builds -> Dependency Graph -> Shared Config -> Commit

**Artifacts produced:**
- `turbo.json` or `nx.json` — Build pipeline configuration
- `pnpm-workspace.yaml` — Workspace definition
- `packages/config/` — Shared tsconfig, ESLint, Prettier configurations
- `.github/workflows/ci.yml` — Selective build CI pipeline
- Dependency graph visualization

**Flags:** `--init <tool>`, `--audit`, `--boundaries`, `--graph`, `--selective`, `--cache`, `--shared-config`, `--migrate`, `--ci`

### Skill: `/godmode:lint` — Linting & Code Standards

**Purpose:** Set up and enforce code linting, formatting, and style standards with automated enforcement at every level.

**Capabilities:**
- **Multi-language tool configuration:** ESLint 9 flat config with typescript-eslint, Prettier, Biome (all-in-one), Ruff (Python), golangci-lint (Go), Stylelint (CSS), shellcheck, and more
- **Custom rule creation:** ESLint custom rules with AST visitors, Ruff/flake8 custom plugins for project-specific conventions (e.g., no direct env access, no print statements)
- **Auto-fix strategies:** Three-layer defense: format-on-save (editor), lint-staged (pre-commit), and enforcement (CI) with `--max-warnings=0`
- **Pre-commit hooks:** Husky + lint-staged for JS/TS, pre-commit framework for Python and multi-language, with hooks that run only on staged files
- **Style guide enforcement:** Comprehensive coding standards document covering indentation, naming conventions, import ordering, error handling, and more — all backed by automated rules
- **Migration support:** Guided migration between tools (e.g., ESLint + Prettier to Biome) with rule mapping and batch auto-fix

**Workflow:** Assess Current State -> Tool Selection -> Configuration -> Custom Rules -> Auto-Fix Setup -> Pre-Commit Hooks -> Style Guide -> CI Enforcement -> Commit

**Artifacts produced:**
- Linter config (`eslint.config.js`, `biome.json`, `pyproject.toml`, `.golangci.yml`)
- Formatter config (`.prettierrc` or integrated in linter)
- Pre-commit hooks (`.husky/` or `.pre-commit-config.yaml`)
- Editor settings (`.vscode/settings.json`, `.editorconfig`)
- Style guide document

**Flags:** `--tool <name>`, `--fix`, `--hooks`, `--ci`, `--custom-rule <name>`, `--migrate <from> <to>`, `--audit`, `--strict`, `--style-guide`

### Skill: `/godmode:type` — Type System & Schema Validation

**Purpose:** Strengthen type safety through TypeScript strict mode, runtime schema validation, and schema-first development patterns.

**Capabilities:**
- **TypeScript strict mode:** Full strict configuration for new projects, 4-phase gradual adoption plan for existing projects (noImplicitAny -> strictFunctionTypes -> full strict -> zero any)
- **Schema validation:** Library selection (Zod, Yup, Joi, Valibot, ArkType, io-ts) with decision tree, schema definition as single source of truth, and type inference from schemas
- **Runtime type checking:** Validation middleware for API boundaries, environment variable validation at startup, and external API response validation
- **Type narrowing:** Discriminated unions for state machines, Result types for error handling without exceptions, custom type guards and assertion functions
- **Branded types:** Domain-safe primitive wrappers (UserId, OrderId, Email, Cents) that prevent accidental mixing at the type level
- **Schema-first development:** Workflow where schemas define entities, types are inferred, business logic is typed, and test factories generate data from schemas

**Workflow:** Type Safety Audit -> Strict Mode Configuration -> Schema Library Selection -> Schema-First Development -> Validation at Boundaries -> Type Narrowing -> Branded Types -> Commit

**Artifacts produced:**
- Updated `tsconfig.json` with strict mode flags
- Schema files at `src/schemas/`
- Validation middleware at `src/middleware/validate.ts`
- Environment validation at `src/config/env.ts`
- Type safety audit with before/after score

**Flags:** `--audit`, `--strict`, `--schemas`, `--validate`, `--eliminate-any`, `--branded`, `--migrate <lib>`, `--env`, `--factory`

### Integration with Existing Skills

The Developer Experience skills integrate into the Godmode workflow at these points:

```
/godmode:dx  ->  /godmode:lint  ->  /godmode:type  ->  /godmode:build
     |                 |                  |                   |
  Optimize env     Enforce code      Strengthen          Build with
  and feedback     standards         type safety         full guardrails

/godmode:monorepo  ->  /godmode:lint  ->  /godmode:dx  ->  /godmode:ship
       |                     |                 |                 |
  Set up workspace     Shared lint         Fast feedback    Ship with
  and boundaries       config              per package      confidence
```

- **From `/godmode:setup`:** After initial project setup, invoke `/godmode:dx` to optimize the development environment
- **From `/godmode:dx` to `/godmode:lint`:** After environment improvements, set up linting and code standards
- **From `/godmode:lint` to `/godmode:type`:** After code standards are enforced, strengthen type safety
- **From `/godmode:monorepo` to `/godmode:lint`:** Monorepo shared config package feeds into centralized lint configuration
- **From `/godmode:type` to `/godmode:build`:** With type safety in place, build features with full guardrails
- **From `/godmode:review`:** Code review can refer to `/godmode:lint` for style issues and `/godmode:type` for type safety gaps
- **From `/godmode:quality`:** Quality analysis identifies technical debt that `/godmode:lint` and `/godmode:type` can address

### Design Principles for Developer Experience Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Measure before improving | Every DX audit produces numeric scores; improvements show before/after deltas |
| 2 | Automate everything repeatable | Format on save, lint on commit, validate on request — humans handle logic, machines handle style |
| 3 | One-command setup | Any developer must go from clone to running in a single command, no tribal knowledge |
| 4 | Schema is the source of truth | Types are inferred from schemas, never written separately; one change updates both |
| 5 | Three layers of defense | Editor (instant), pre-commit (fast), CI (final) — violations caught as early as possible |
| 6 | Feedback speed compounds | Every second saved on save-to-result multiplies across every developer, every day |
| 7 | Boundaries prevent entropy | Package boundaries, lint rules, and type strictness prevent gradual quality degradation |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/dx/SKILL.md` | Skill | Developer experience optimization workflow |
| `skills/monorepo/SKILL.md` | Skill | Monorepo management workflow |
| `skills/lint/SKILL.md` | Skill | Linting and code standards workflow |
| `skills/type/SKILL.md` | Skill | Type system and schema validation workflow |
| `commands/godmode/dx.md` | Command | Usage reference for `/godmode:dx` |
| `commands/godmode/monorepo.md` | Command | Usage reference for `/godmode:monorepo` |
| `commands/godmode/lint.md` | Command | Usage reference for `/godmode:lint` |
| `commands/godmode/type.md` | Command | Usage reference for `/godmode:type` |

**Iterations 203-210 (8 files, 4 skills, 4 commands)**

---

## 87. Web Performance & SEO Skills

Web Performance & SEO skills bring production-grade web optimization capabilities to Godmode. These three skills cover the full lifecycle of making web applications fast, discoverable, and installable — from Lighthouse auditing and bundle optimization to structured data implementation and offline-first architecture.

### Skills Overview

| Skill | Command | Purpose |
|-------|---------|---------|
| SEO | `/godmode:seo` | SEO Optimization — meta tags, structured data, Core Web Vitals, Open Graph, sitemap/robots.txt |
| Webperf | `/godmode:webperf` | Web Performance — Lighthouse, bundle analysis, image optimization, critical CSS, fonts, caching |
| PWA | `/godmode:pwa` | Progressive Web Apps — service workers, offline-first, manifest, push notifications, background sync |

### SEO — SEO Optimization & Technical Auditing

The `seo` skill audits and optimizes search engine visibility. It covers the complete technical SEO stack from crawlability to rich search results.

**Core workflow:**
1. Discover site SEO infrastructure (sitemap, robots.txt, meta tags, rendering mode)
2. Audit meta tags across all pages (title, description, canonical, robots directives)
3. Validate and implement Schema.org structured data (JSON-LD) for rich results
4. Measure Core Web Vitals (LCP, INP, CLS) with optimization recommendations
5. Audit Open Graph and Twitter Card meta for social sharing
6. Validate sitemap.xml completeness and robots.txt correctness
7. Auto-fix common issues (missing meta, canonical tags, image dimensions)
8. Set up Lighthouse CI monitoring for ongoing SEO tracking

**Structured data types:**
- Organization, Article, Product, FAQPage, BreadcrumbList, SearchAction, LocalBusiness, Review

**Key principles:**
- Crawlability is the foundation — fix robots.txt, sitemap, and canonical tags first
- Core Web Vitals directly affect search ranking — they are not optional
- Structured data earns rich results that dramatically improve click-through rates
- Meta tags are the sales pitch — write for humans with natural keyword inclusion
- SSR/SSG is mandatory for SEO-critical pages — do not rely on client-side rendering

### Webperf — Web Performance Optimization

The `webperf` skill measures and optimizes web application performance across the entire delivery stack, from server response to paint completion.

**Core workflow:**
1. Establish performance baseline (Lighthouse scores, Core Web Vitals, bundle sizes)
2. Run Lighthouse diagnostics with opportunity/savings analysis
3. Analyze JavaScript bundles and recommend code splitting strategies
4. Optimize images (WebP/AVIF conversion, responsive srcset, lazy loading)
5. Extract critical CSS and remove unused styles
6. Optimize font loading (subsetting, font-display, preload, fallback metrics)
7. Configure service worker caching strategies (Cache First, Network First, Stale While Revalidate)
8. Set up CDN and HTTP cache headers for optimal delivery

**Optimization areas:**
- **Bundle:** Route-based splitting, tree shaking, lighter library alternatives
- **Images:** WebP/AVIF, responsive srcset, lazy loading, fetchpriority
- **CSS:** Critical CSS extraction, PurgeCSS unused removal
- **Fonts:** Subsetting, font-display: swap, size-adjust fallbacks, woff2
- **Caching:** Service worker strategies, HTTP Cache-Control, CDN edge caching

**Key principles:**
- Measure before optimizing — data drives decisions, not intuition
- JavaScript is the most expensive resource — reduce JS payload first
- Images are the lowest-hanging fruit — format conversion saves the most bytes
- Critical CSS eliminates the biggest cause of slow First Contentful Paint
- Cache everything possible — every cache miss is wasted time

### PWA — Progressive Web App Development

The `pwa` skill builds production-grade Progressive Web Apps with offline support, installability, and native-like capabilities.

**Core workflow:**
1. Assess PWA readiness (HTTPS, service worker, manifest, responsive design)
2. Create web app manifest with icons, screenshots, shortcuts, and share target
3. Implement service worker with Workbox caching strategies
4. Build offline-first architecture with IndexedDB data storage
5. Set up push notifications (VAPID keys, subscription, handler, click routing)
6. Implement background sync for offline mutations with retry queue
7. Handle install prompt with engagement-based timing
8. Test across Chrome, Safari, Firefox, and Edge

**PWA capabilities:**
- **Installability:** Web app manifest, icons (192/512/maskable), install prompt
- **Offline:** Service worker precaching, network-first HTML, offline fallback page
- **Data:** IndexedDB for structured data, sync queue for offline mutations
- **Push:** VAPID-based web push notifications with click actions
- **Sync:** Background sync for offline writes, periodic sync for content updates

**Key principles:**
- Service worker is the foundation — without it, there is no PWA
- Offline is not optional — at minimum serve a branded offline fallback page
- Cache with intention — every strategy is a trade-off between freshness and speed
- Never request notification permission on first visit — ask after engagement
- Update service workers carefully — a broken update can take down the entire app

### Workflow Integration

The Web Performance & SEO skills integrate with the existing Godmode workflow:

```
/godmode:build   -> Implement the feature
/godmode:test    -> Verify correctness
/godmode:a11y    -> Accessibility audit
/godmode:seo     -> SEO optimization
/godmode:webperf -> Performance optimization
/godmode:pwa     -> Progressive Web App features
/godmode:visual  -> Visual regression testing
/godmode:ship    -> Ship to production
```

- **From `/godmode:build`:** After building the feature, run SEO and performance audits
- **From `/godmode:seo` to `/godmode:webperf`:** Core Web Vitals issues found in SEO audit are resolved by webperf
- **From `/godmode:webperf` to `/godmode:pwa`:** Service worker caching strategies bridge into full PWA implementation
- **From `/godmode:pwa` to `/godmode:ship`:** PWA installability and offline support verified before deployment
- **From `/godmode:a11y`:** Accessibility and SEO share concerns (semantic HTML, alt text, headings)

### Design Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Measure before optimizing | Every optimization requires before/after metrics |
| 2 | SEO and performance are inseparable | Fast sites rank better, slow sites lose users |
| 3 | Offline is a feature, not an edge case | PWAs must handle network absence gracefully |
| 4 | Structured data earns visibility | Schema.org markup produces rich search results |
| 5 | Cache with intention | Every caching strategy has explicit TTL and eviction |
| 6 | Progressive enhancement | Core content works without JS, features enhance with it |
| 7 | Test on real devices and networks | Lab scores approximate but field data reflects reality |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/seo/SKILL.md` | Skill | SEO optimization and technical auditing workflow |
| `skills/webperf/SKILL.md` | Skill | Web performance optimization workflow |
| `skills/pwa/SKILL.md` | Skill | Progressive Web App development workflow |
| `commands/godmode/seo.md` | Command | Usage reference for `/godmode:seo` |
| `commands/godmode/webperf.md` | Command | Usage reference for `/godmode:webperf` |
| `commands/godmode/pwa.md` | Command | Usage reference for `/godmode:pwa` |

**Iterations 292-297 (6 files, 3 skills, 3 commands)**

---

## 84. State Management & Data Modeling Skills

Three new skills extend Godmode into application state architecture, data modeling, and ORM/data access optimization. These skills cover the full data lifecycle: from how state is managed on the client, to how data is modeled in the database, to how the application accesses that data through an ORM.

### 84.1 State Management (`/godmode:state`)

**Purpose:** Design and implement application state architecture with the right tool for each category of state.

**Key capabilities:**
- **State classification:** Categorizes all application state into server state, client UI state, client domain state, form state, URL state, persisted state, computed/derived state, and machine state. Correct classification drives correct tool selection.
- **Frontend state libraries:** Comparison matrices for Redux Toolkit, Zustand, Jotai, MobX, Pinia, and Signals with bundle size, DX, TypeScript support, and use-case recommendations.
- **Server state management:** React Query, SWR, Apollo Client, and RTK Query setup with query key factories, staleness configuration, cache invalidation, and garbage collection.
- **Optimistic updates:** Full optimistic mutation pattern with snapshot, optimistic cache update, error rollback, and settlement invalidation.
- **State machines:** XState and Robot for complex workflows (checkout, file upload, WebSocket lifecycle) where invalid state combinations must be prevented.
- **Persistence and hydration:** Storage strategy selection (localStorage, sessionStorage, IndexedDB, cookies, URL params), SSR hydration patterns, and cross-tab synchronization.
- **Cache synchronization:** Real-time cache invalidation via WebSocket/SSE integration with React Query.

**Workflow:** Audit current state -> Classify by category -> Select tools -> Design store architecture -> Implement server state caching -> Add optimistic updates -> Build state machines -> Configure persistence/hydration -> Report.

**Command:** `/godmode:state` (`commands/godmode/state.md`)

### 84.2 Data Modeling & Schema Design (`/godmode:schema`)

**Purpose:** Design, evaluate, and evolve data models and schemas across relational and NoSQL databases.

**Key capabilities:**
- **Entity-relationship modeling:** Entity catalog with attributes and volume estimates, relationship mapping with cardinality (1:1, 1:N, M:N), and text-based ER diagrams.
- **Relational schema design:** Normalization from 1NF through BCNF with practical guidance. Full SQL DDL generation with UUIDs, constraints (CHECK, NOT NULL, UNIQUE, FK), indexes, and automatic `updated_at` triggers.
- **Denormalization trade-offs:** Evidence-based denormalization decisions: when read frequency dominates writes, when joins are proven bottlenecks, when data is point-in-time (order snapshots), and when counter caches eliminate aggregation.
- **NoSQL data modeling:** Document store patterns (embed vs reference decision matrix), key-value design (Redis patterns for caching, sessions, rate limiting, leaderboards), graph database modeling (Neo4j nodes and relationships), and time-series design (TimescaleDB hypertables with compression, retention, and continuous aggregates).
- **Schema evolution:** Safe changes (add nullable column, add index CONCURRENTLY) vs breaking changes with the expand-contract pattern (add new, backfill, dual-write, migrate reads, drop old).
- **Validation schemas:** Zod (TypeScript runtime), JSON Schema, Protobuf, and Avro as single sources of truth with derived types and operation-specific variants (create, update, filter).
- **Multi-tenancy:** Shared schema with row-level security, schema-per-tenant, and database-per-tenant patterns with isolation and complexity trade-offs.

**Workflow:** Understand domain -> Model entities and relationships -> Design schema at correct normalization level -> Evaluate denormalization -> Plan evolution strategy -> Generate validation schemas -> Design multi-tenancy (if needed) -> Report.

**Command:** `/godmode:schema` (`commands/godmode/schema.md`)

### 84.3 ORM & Data Access (`/godmode:orm`)

**Purpose:** Select, configure, and optimize ORMs and data access layers for production performance.

**Key capabilities:**
- **ORM selection:** Framework-specific comparison matrices for TypeScript (Prisma, Drizzle, TypeORM, Sequelize), Python (SQLAlchemy, Django ORM, Tortoise), Go (GORM, Ent, sqlc), Ruby (ActiveRecord, Sequel), Java (Hibernate, jOOQ), C# (EF Core, Dapper), Rust (Diesel, SeaORM), and PHP (Eloquent, Doctrine).
- **N+1 query detection and resolution:** Enable query logging, count queries per request, detect loop-based lazy loading, and apply ORM-idiomatic eager loading fixes (Prisma `include`, Django `select_related`/`prefetch_related`, Rails `includes`, GORM `Preload`, SQLAlchemy `joinedload`/`selectinload`).
- **Connection pooling:** Pool sizing formula (cores * 2 + spindles), configuration for Prisma, Drizzle, SQLAlchemy, Rails, and GORM with min/max connections, idle timeout, max lifetime, statement timeout, and health checks. PgBouncer and serverless pooler guidance.
- **Transaction management:** Basic transactions, nested transactions with savepoints, and distributed transactions with the Saga pattern (execute/compensate steps with reverse-order rollback).
- **Query builder patterns:** Composable dynamic query building with type-safe filter, sort, and pagination. Raw SQL escape hatches for every ORM when the abstraction leaks.
- **Production readiness:** 13-point checklist covering pooling, logging, N+1 detection, timeouts, retries, replica routing, migration sync, and monitoring.

**Workflow:** Detect environment -> Select ORM -> Detect N+1 queries -> Configure connection pool -> Implement transactions -> Build query builders -> Add raw SQL escape hatches -> Verify production readiness -> Report.

**Command:** `/godmode:orm` (`commands/godmode/orm.md`)

### Skill Interactions

The three State Management & Data Modeling skills form a vertical stack from frontend to database:

```
/godmode:state   ->  /godmode:schema  ->  /godmode:orm   ->  /godmode:query
(client state)       (data models)        (data access)       (query optimization)
```

- **State** designs how the frontend manages and caches data
- **Schema** designs the underlying data models and structures
- **ORM** configures how the application reads and writes that data
- **Query** optimizes individual queries when performance issues arise

Each skill can run independently or as part of the data architecture pipeline. The orchestrator (`/godmode`) routes to the appropriate skill based on context.

### Design Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Classify before choosing | Separate server state from client state before selecting a library |
| 2 | Access patterns drive schema | Design schemas for how data is read, not for normalization purity |
| 3 | The ORM is a tool, not a religion | Use the ORM for CRUD, raw SQL for complex queries |
| 4 | Measure before optimizing | N+1 detection requires query logging; denormalization requires EXPLAIN evidence |
| 5 | Minimize state, minimize schema | If it can be computed, don't store it. If it can live in the URL, put it there |
| 6 | Single source of truth | Define schemas once (Zod, Protobuf), derive everything else |
| 7 | Evolution must be backward compatible | Every schema change must deploy without downtime |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/state/SKILL.md` | Skill | State management design and implementation |
| `skills/schema/SKILL.md` | Skill | Data modeling and schema design |
| `skills/orm/SKILL.md` | Skill | ORM and data access optimization |
| `commands/godmode/state.md` | Command | Usage reference for `/godmode:state` |
| `commands/godmode/schema.md` | Command | Usage reference for `/godmode:schema` |
| `commands/godmode/orm.md` | Command | Usage reference for `/godmode:orm` |

**Iterations 272-277 (6 files, 3 skills, 3 commands)**

---

## 85. Error Handling & Resilience Skills

Three new skills extend Godmode into production hardening — building systems that handle failures gracefully, log effectively, and recover automatically.

### System Resilience (`/godmode:resilience`)

**Purpose:** Design and implement fault-tolerant systems using battle-tested resilience patterns.

**Workflow:**
1. **Assess** — Evaluate current resilience posture across all patterns (circuit breakers, retries, timeouts, bulkheads, rate limiting, health checks, degradation)
2. **Circuit Breakers** — State machine implementation (CLOSED/OPEN/HALF-OPEN) with configurable thresholds, monitored exceptions, and fallback strategies
3. **Retry Strategies** — Exponential backoff with jitter (full, equal, decorrelated) and Retry-After header respect. Decision matrix for retryable vs non-retryable errors
4. **Bulkhead Pattern** — Semaphore-based concurrency isolation per dependency. One slow dependency cannot starve others
5. **Rate Limiting** — Token bucket, sliding window, and concurrency-based algorithms with Redis-backed distributed enforcement
6. **Graceful Degradation** — Multi-level degradation strategy mapping each dependency to its fallback behavior (cached data, queued processing, feature disable)
7. **Health Checks** — Liveness (process alive, no dependency checks), readiness (can serve traffic, checks dependencies), startup (initialization complete)
8. **Timeout Management** — Hierarchical timeout budget where each layer's timeout is less than its parent

**Key Patterns:**

| Pattern | Purpose | Failure Mode |
|---------|---------|-------------|
| Circuit Breaker | Fast failure when dependency down | Cascading failures |
| Retry + Backoff | Recover from transient failures | Temporary network issues |
| Bulkhead | Isolate failure domains | Resource exhaustion |
| Rate Limiting | Prevent overload | Traffic spikes |
| Graceful Degradation | Maintain partial functionality | Dependency outage |
| Health Checks | Container lifecycle management | Orchestrator decisions |
| Timeout Budget | Prevent unbounded waits | Slow dependencies |

**Critical Rules:**
- Liveness probes must NEVER check external dependencies (DB outage should not restart pods)
- Retry without backoff causes thundering herd (all clients retry simultaneously)
- Retry non-idempotent operations causes duplicates (double charges, double posts)
- Every external call must have a timeout, and timeout hierarchy must be monotonically decreasing

**Chaining:** `/godmode:resilience` → `/godmode:chaos` (validate) → `/godmode:observe` (monitor) → `/godmode:loadtest` (stress test)

### Error Handling Architecture (`/godmode:errorhandling`)

**Purpose:** Design comprehensive error handling with typed hierarchies, error boundaries, and structured responses.

**Workflow:**
1. **Classify** — Separate operational errors (expected, recoverable: timeouts, rate limits, validation) from programmer errors (bugs: TypeError, null deref, assertion failures)
2. **Error Hierarchy** — Base AppError with code, statusCode, isOperational flag, toLog() for internal details, toResponse() for safe user-facing output
3. **Error Boundaries** — React component boundaries (page + widget level), Express global error handler (registered last), Go panic recovery middleware
4. **Structured Responses** — Consistent JSON format: `{ error: { code, message, requestId } }` with field-level validation details and Retry-After headers
5. **Error Code Registry** — Machine-readable codes (VALIDATION_ERROR, NOT_FOUND, RATE_LIMIT_EXCEEDED) mapped to HTTP status codes
6. **User-Facing Messages** — Helpful and actionable for operational errors, generic "something went wrong" for programmer errors. Never expose stack traces, SQL, or file paths
7. **Global Handlers** — Framework-specific: Express asyncHandler + global middleware, NestJS ExceptionFilter, Next.js error.tsx/global-error.tsx, FastAPI exception_handler, Go middleware

**Error Classification:**

| Category | Handle | Retry? | User Message | Log Level |
|----------|--------|--------|-------------|-----------|
| Operational | Return/degrade | Often | Helpful, specific | WARN |
| Programmer | Log + alert + crash | Never | Generic "oops" | ERROR/FATAL |

**Key Principle:** If you catch a programmer error and "handle" it, you are hiding a bug. If you crash on an operational error, you are overreacting.

**Chaining:** `/godmode:errorhandling` → `/godmode:logging` (structured error logging) → `/godmode:errortrack` (aggregation and tracking)

### Logging & Structured Logging (`/godmode:logging`)

**Purpose:** Implement production-grade structured logging with correlation IDs, PII redaction, and aggregation pipelines.

**Workflow:**
1. **Assess** — Evaluate logging maturity: format, levels, context, correlation, aggregation, PII handling, retention, performance
2. **Log Level Strategy** — FATAL (process exits), ERROR (operation failed), WARN (unexpected but handled), INFO (business events), DEBUG (diagnostics, off in prod)
3. **Structured Format** — JSON logs with consistent fields: timestamp, level, service, environment, version, requestId, traceId, userId
4. **Correlation IDs** — Request-scoped loggers with requestId (per HTTP request), traceId (across services), spanId (per operation). Propagated via X-Request-ID/X-Trace-ID headers
5. **PII Redaction** — Logger-level redaction: mask emails/phones, redact passwords/tokens/cards, anonymize IPs. Allowlist approach (log only explicitly allowed fields)
6. **Log Aggregation** — Pipeline design for ELK Stack (Filebeat → Logstash → Elasticsearch → Kibana), Grafana Loki (Promtail → Loki → Grafana), or AWS CloudWatch
7. **OpenTelemetry** — Unified traces + logs with automatic context propagation
8. **Retention & Rotation** — Per-environment retention (prod ERROR: 365d, INFO: 30d), storage tiering (hot/warm/cold), compliance archival

**Log Level Quick Reference:**

| Level | When | Alert? |
|-------|------|--------|
| FATAL | Process cannot continue | Immediate page |
| ERROR | Operation failed, process continues | Alert within 5m |
| WARN | Unexpected but handled | Dashboard |
| INFO | Business event | — |
| DEBUG | Diagnostic (off in prod) | — |

**Key Rule:** A healthy system should have ZERO ERROR logs in normal operation. If you see ERROR logs during normal traffic, either the errors are miscategorized or you have a bug.

**Chaining:** `/godmode:logging` → `/godmode:observe` (metrics + tracing) → `/godmode:secure` (PII audit) → `/godmode:incident` (better debugging)

### Design Principles for Error Handling & Resilience Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Classify before handling | Operational errors get retries and degradation; programmer errors get alerts and fixes |
| 2 | Fail fast, recover gracefully | Circuit breakers prevent cascading; fallbacks maintain partial service |
| 3 | Log at the boundary | One structured log entry per error at the catch point, not at every level |
| 4 | Users see messages, developers see context | toResponse() for users, toLog() for operators |
| 5 | Redact by default | PII must be explicitly allowed in logs, not explicitly blocked |
| 6 | Correlation is non-negotiable | Every log line includes requestId and traceId for cross-service debugging |
| 7 | Timeouts are mandatory | Every external call has a timeout; timeout hierarchy is monotonically decreasing |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/resilience/SKILL.md` | Skill | System resilience patterns and implementation |
| `skills/errorhandling/SKILL.md` | Skill | Error handling architecture and error boundaries |
| `skills/logging/SKILL.md` | Skill | Structured logging, correlation IDs, and PII redaction |
| `commands/godmode/resilience.md` | Command | Usage reference for `/godmode:resilience` |
| `commands/godmode/errorhandling.md` | Command | Usage reference for `/godmode:errorhandling` |
| `commands/godmode/logging.md` | Command | Usage reference for `/godmode:logging` |

**Iterations 278-283 (6 files, 3 skills, 3 commands)**

## 77. AI & LLM Development Skills

### Overview

Four new skills extend Godmode into the AI/LLM application development domain. These skills cover the full lifecycle of building production AI systems: prompt engineering, retrieval-augmented generation, agent development, and systematic evaluation. Together they form a cohesive toolkit for teams building LLM-powered applications.

### Skill: `/godmode:prompt` — Prompt Engineering

**Purpose:** Design, test, version, and optimize prompts for LLMs with production-grade rigor.

**Capabilities:**
- **Prompt design patterns:** Zero-shot, few-shot, chain-of-thought, ReAct, tree-of-thought, self-consistency, least-to-most, meta-prompting — with selection guidance based on task requirements
- **System prompt design:** Structured 7-section system prompt template (role, task, input format, output format, constraints, examples, edge case handling)
- **Few-shot example design:** Example selection criteria, diversity requirements, token cost analysis, and format demonstration
- **Structured output:** JSON mode, function calling, prompt-based enforcement, and constrained decoding with validation layers and retry strategies
- **Prompt injection prevention:** 4-layer defense model (input sanitization, prompt structure with delimiters, output validation, monitoring) with adversarial testing
- **Prompt testing:** Test suites covering golden set, edge cases, format compliance, safety, injection resistance, consistency, regression, and performance
- **Versioning and A/B testing:** Prompt version registry, A/B test design with traffic splits, sample size calculation, and statistical significance criteria
- **Evaluation:** Accuracy, format compliance, safety rate, injection resistance, consistency score, latency, and cost metrics

**Workflow:** Discovery -> Pattern Selection -> System Prompt Design -> Few-Shot Examples -> Reasoning Design -> Structured Output -> Injection Prevention -> Testing -> Versioning/A/B -> Artifacts

**Artifacts produced:**
- `prompts/<task>/prompt-spec.yaml` — Versioned prompt specification
- `prompts/<task>/system-prompt.md` — System prompt content
- `prompts/<task>/examples.yaml` — Few-shot examples
- `prompts/<task>/tests.yaml` — Test suite

**Flags:** `--pattern <name>`, `--model <name>`, `--optimize`, `--test`, `--compare <v1> <v2>`, `--harden`, `--version`, `--export`, `--json`, `--eval`

### Skill: `/godmode:rag` — Retrieval-Augmented Generation

**Purpose:** Build, optimize, and evaluate RAG systems from document ingestion through retrieval and generation.

**Capabilities:**
- **Embedding model selection:** Comparison matrix of OpenAI, Cohere, Voyage, BGE, GTE, E5, Nomic models with dimensions, MTEB scores, latency, cost, and context window
- **Chunking strategies:** Fixed-size, recursive character, semantic, sentence-based, document-level, hierarchical, code-aware (AST), markdown/HTML headers, sliding window, parent-child — with parameter tuning guidance
- **Vector store design:** Pinecone, Weaviate, Chroma, pgvector, Qdrant, Milvus, LanceDB, Elasticsearch — with selection criteria (scale, latency, filtering, multi-tenancy, cost) and index configuration (HNSW parameters, distance metrics)
- **Ingestion pipeline:** 5-stage pipeline (load, clean, chunk, embed, index) with document loaders for PDF, HTML, Markdown, Docx, code, databases, and APIs
- **Retrieval optimization:** Hybrid search (dense + BM25 with RRF), query preprocessing (expansion, decomposition, routing), reranking (Cohere, Voyage, BGE, ColBERT, LLM-based), advanced patterns (parent-child, contextual compression, multi-index, self-RAG, agentic RAG)
- **Context assembly:** Token budgeting across system prompt, context, history, and output — with citation strategies (inline, footnote)
- **Evaluation:** Retrieval metrics (hit rate, MRR, NDCG, precision, recall) and generation metrics (faithfulness, relevance, completeness, correctness, hallucination rate, citation accuracy)

**Workflow:** Discovery -> Embedding Selection -> Chunking Strategy -> Vector Store -> Ingestion Pipeline -> Retrieval Optimization -> Context Assembly -> Evaluation -> Artifacts

**Artifacts produced:**
- `config/rag/<pipeline>-config.yaml` — Pipeline configuration
- `src/rag/<pipeline>/` — Ingestion and retrieval code
- `tests/rag/<pipeline>/eval.py` — Evaluation suite
- `docs/rag/<pipeline>-eval-results.md` — Evaluation results report

**Flags:** `--ingest <source>`, `--chunk <strategy>`, `--store <name>`, `--embed <model>`, `--eval`, `--diagnose`, `--compare`, `--reindex`, `--hybrid`, `--rerank <model>`, `--stats`

### Skill: `/godmode:agent` — AI Agent Development

**Purpose:** Design, build, and evaluate AI agents with structured architecture, safe tool use, and comprehensive guardrails.

**Capabilities:**
- **Agent architecture patterns:** ReAct, plan-and-execute, reflexion, multi-agent (collaboration and debate), hierarchical, state machine, router — with selection guidance based on task complexity
- **Agent loop design:** Detailed loop templates for each pattern with termination conditions, replanning triggers, error handling, and checkpointing
- **Tool design:** Tool inventory with specifications, risk levels (LOW/MEDIUM/HIGH/CRITICAL), typed parameters, structured returns, rate limits, side effects, and confirmation requirements
- **Memory systems:** Working memory (context window management), conversation memory (session store with summarization), episodic memory (past task retrieval), semantic memory (learned facts), procedural memory (learned workflows)
- **Guardrails:** 5-layer safety model — input guardrails (injection, PII, malice), execution guardrails (steps, tokens, cost, time, loop detection), tool guardrails (risk-based access control), output guardrails (PII, harmful content, hallucination), monitoring guardrails (logging, alerting, kill switch)
- **NEVER list:** Hardcoded, non-overridable safety prohibitions for high-risk actions
- **Multi-agent design:** Agent roster, specialization, communication graph (pipeline vs mesh), and conflict resolution
- **Evaluation:** Task completion rate, tool selection accuracy, error recovery, safety violation rate, efficiency (steps per task), trajectory analysis

**Workflow:** Discovery -> Architecture Selection -> Loop Design -> Tool Design -> Memory Design -> Guardrails -> Evaluation -> Artifacts

**Artifacts produced:**
- `config/agents/<agent>-config.yaml` — Agent configuration
- `src/agents/<agent>/` — Agent implementation
- `src/agents/<agent>/tools/` — Tool definitions
- `src/agents/<agent>/guardrails.py` — Safety guardrails
- `tests/agents/<agent>/` — Test suite
- `docs/agents/<agent>-architecture.md` — Architecture documentation

**Flags:** `--pattern <name>`, `--tools`, `--memory`, `--guardrails`, `--eval`, `--trace <task>`, `--debug`, `--multi`, `--roster`, `--optimize`, `--cost`

### Skill: `/godmode:eval` — AI/LLM Evaluation

**Purpose:** Evaluate, benchmark, and regression-test AI systems with statistical rigor.

**Capabilities:**
- **Evaluation dataset design:** Hand-curated golden sets, production log sampling, synthetic generation, adversarial examples, domain benchmarks, and regression sets — with quality checks (deduplication, expert review, balance, leakage detection, PII handling)
- **Evaluation frameworks:** RAGAS, DeepEval, Promptfoo, LangSmith, Braintrust, Arize Phoenix, Humanloop, and custom frameworks — with pipeline architecture
- **LLM-as-judge:** Scoring rubrics for correctness, relevance, faithfulness, safety, and format compliance — with judge calibration against human scores (Cohen's kappa >= 0.7), bias mitigation (position, verbosity, self-preference, anchoring)
- **Human evaluation protocols:** Evaluator selection and training, blind evaluation, side-by-side comparison, inter-annotator agreement (Fleiss' kappa), adjudication process
- **Benchmark creation:** Category-weighted benchmarks with baseline tracking, saturation detection, and append-only versioning
- **Regression testing:** Production failure collection, CI/CD integration with merge blocking, comparison strategies (exact, semantic, LLM judge, assertion-based, rubric-based), and regression dashboards
- **Statistical significance:** Paired bootstrap, McNemar's, Wilcoxon signed-rank, Mann-Whitney U tests — with sample size requirements, confidence intervals, and Bonferroni correction

**Workflow:** Discovery -> Dataset Design -> Framework Selection -> LLM-as-Judge -> Human Evaluation -> Benchmark Creation -> Regression Testing -> Statistical Analysis -> Report

**Artifacts produced:**
- `evals/<system>/eval-config.yaml` — Evaluation configuration
- `evals/<system>/dataset/` — Versioned evaluation dataset
- `evals/<system>/judges/` — LLM judge prompts
- `evals/<system>/regression/` — Regression test set
- `evals/<system>/results/` — Historical results
- `docs/evals/<system>-eval-report.md` — Evaluation report

**Flags:** `--dataset`, `--judge`, `--human`, `--benchmark`, `--regression`, `--compare <a> <b>`, `--report`, `--ci`, `--calibrate`, `--significance`, `--history`, `--quick`, `--full`

### Integration with Existing Skills

The AI/LLM development skills form a cohesive pipeline and integrate with existing Godmode skills:

```
/godmode:think  ->  /godmode:prompt  ->  /godmode:rag  ->  /godmode:agent  ->  /godmode:eval
     |                    |                   |                   |                   |
  Brainstorm         Design the          Add retrieval       Build agent          Evaluate
  the AI feature     prompts             context             with tools           everything
```

- **From `/godmode:think`:** After brainstorming an AI feature, invoke `/godmode:prompt` to design the core prompts
- **From `/godmode:prompt` to `/godmode:rag`:** After prompt design, add retrieval context for knowledge-grounded generation
- **From `/godmode:rag` to `/godmode:agent`:** After building RAG, wrap it in an agent with tools and memory
- **From `/godmode:agent` to `/godmode:eval`:** After building the agent, evaluate task completion, safety, and efficiency
- **From `/godmode:eval` back to skills:** Evaluation results drive improvements to prompts, retrieval, and agent behavior
- **From `/godmode:ml`:** Fine-tuned models feed into prompts and agents; evaluation metrics shared
- **From `/godmode:mlops`:** Deployed models are evaluated continuously; regression tests run in CI/CD
- **From `/godmode:secure`:** Security audit validates agent guardrails and prompt injection defenses
- **From `/godmode:ship`:** Ship workflow checks evaluation metrics before deployment

### Design Principles for AI/LLM Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Test before shipping | No AI component goes to production without evaluation. Metrics, not vibes. |
| 2 | Version everything | Prompts, datasets, embeddings, and eval results are versioned artifacts. |
| 3 | Defense in depth | Prompt injection, guardrails, output validation — layer defenses, never rely on one. |
| 4 | Evaluate the components | Measure retrieval and generation separately. Diagnose before fixing. |
| 5 | Statistical rigor | Report significance, confidence intervals, and baselines. Do not ship on noise. |
| 6 | Regression tests only grow | Every production failure becomes a regression test. The test set never shrinks. |
| 7 | Safety is non-negotiable | Agent guardrails, prompt injection defenses, and output validation are not optional. |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/prompt/SKILL.md` | Skill | Prompt engineering workflow |
| `skills/rag/SKILL.md` | Skill | RAG pipeline design and optimization |
| `skills/agent/SKILL.md` | Skill | AI agent development workflow |
| `skills/eval/SKILL.md` | Skill | AI/LLM evaluation and benchmarking |
| `commands/godmode/prompt.md` | Command | Usage reference for `/godmode:prompt` |
| `commands/godmode/rag.md` | Command | Usage reference for `/godmode:rag` |
| `commands/godmode/agent.md` | Command | Usage reference for `/godmode:agent` |
| `commands/godmode/eval.md` | Command | Usage reference for `/godmode:eval` |

**Iterations 217-224 (8 files, 4 skills, 4 commands)**

## 95. Open Source & Community Skills

Three skills for managing open source projects end-to-end: from license selection through community scaffolding to changelog automation.

### 95.1 Open Source Project Management (`/godmode:opensource`)

Repository setup and community management for open source projects.

**Repository Scaffolding** — generates or audits all community health files:
- LICENSE, CODE_OF_CONDUCT.md (Contributor Covenant 2.1), CONTRIBUTING.md, SECURITY.md
- `.github/ISSUE_TEMPLATE/` (bug report YAML, feature request YAML, config)
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/CODEOWNERS`, `.github/FUNDING.yml`

**GitHub Actions Automation** — workflows for project management:
- `labeler.yml` — auto-labels PRs by file path
- `stale.yml` — marks and closes inactive issues/PRs (60 days stale, 14 days to close)
- `welcome.yml` — greets first-time contributors on issues and PRs
- `release-drafter.yml` — auto-drafts release notes from merged PRs

**Maintainer Workflows** — structured processes:
- Triage: new issue → bot labels → maintainer triage (48h SLA) → categorize → assign/label
- Review: PR opened → CI runs → CODEOWNERS auto-assigns → code review → merge
- Release: scope determination → changelog → version bump → tag → publish → announce

**Governance Models** — three models matched to project size:
- BDFL (1-20 contributors): single decision authority, fast iteration
- Consensus (10-50 contributors): core team with 72-hour discussion periods
- Steering Committee (50+ contributors): elected committee, working groups, RFC process

| Flag | Description |
|------|-------------|
| `--audit` | Audit only, no file creation |
| `--governance <model>` | Set governance model (bdfl, consensus, committee) |
| `--templates` | Issue and PR templates only |
| `--automation` | GitHub Actions workflows only |
| `--community` | Community channels only |
| `--minimal` | LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT only |

### 95.2 Changelog & Release Notes (`/godmode:changelog`)

Changelog generation and release communication.

**Keep a Changelog Format** — standard sections: Added, Changed, Deprecated, Removed, Fixed, Security. Latest version first, release dates, comparison links.

**Conventional Commits Integration** — commit types (feat, fix, perf, refactor, docs, test, chore, ci, build, style, revert) parsed into changelog entries. Setup includes commitlint, Commitizen, and Husky hooks.

**Auto-Generation Tooling**:
- `conventional-changelog` for local generation
- `release-please` GitHub Action for automated release PRs
- `standard-version` for local bump + changelog + tag

**Audience-Specific Release Notes**:
- Developer-facing: breaking changes with before/after code, new APIs, bug fixes with issue refs
- User-facing: highlights in plain language, capability improvements, upgrade notices

**Breaking Change Communication**:
- Advance notice via deprecation warnings (1-2 releases before)
- Migration guide with step-by-step instructions, codemods, rollback steps
- Release communication across changelog, GitHub Release, blog, community channels
- Support window for previous major version

| Flag | Description |
|------|-------------|
| `--setup` | Configure Conventional Commits + auto-changelog |
| `--release <version>` | Generate changelog for specific version |
| `--migration <from> <to>` | Generate migration guide |
| `--notes` | User-facing release notes |
| `--dev-notes` | Developer-facing release notes |
| `--breaking` | Breaking changes only |
| `--full` | Regenerate from full git history |

### 95.3 License Management (`/godmode:license`)

License selection, compliance, and attribution.

**License Selection Guidance** — comparison matrix covering MIT, Apache 2.0, GPL v3, AGPL v3, MPL 2.0, BSL 1.1, and proprietary. Each profile includes SPDX identifier, permissions, conditions, limitations, best-for scenarios, risks, and notable users.

**License Compatibility Checking** — dependency scanner that cross-references every dependency's license against the project license. Produces compatibility matrix: OK, OK with NOTICE, WARN (consult legal), FAIL (incompatible).

**SPDX Identifiers and File Headers** — standardized `// SPDX-License-Identifier: <id>` headers for all source files with language-specific templates (JS/TS, Python, Go, Rust, Java, HTML, Shell). CI enforcement via `skywalking-eyes` or `addlicense`.

**Third-Party Attribution** — NOTICE file and THIRD_PARTY_LICENSES generation from dependency trees. Covers attribution requirements per license type (MIT needs copyright, Apache 2.0 needs NOTICE file, etc.).

**CLA / DCO Setup**:
- Developer Certificate of Origin (DCO): lightweight, `Signed-off-by` line, used by CNCF/Linux Foundation
- Individual CLA: contributor signs via GitHub bot comment
- Corporate CLA: company signs on behalf of employees
- Automated enforcement via GitHub Actions

| Flag | Description |
|------|-------------|
| `--select` | Interactive license selection |
| `--check` | Dependency compatibility check |
| `--headers` | Add SPDX headers to source files |
| `--attribution` | Generate NOTICE and attribution files |
| `--cla` | Set up CLA enforcement |
| `--dco` | Set up DCO enforcement |
| `--apply <license>` | Apply specific license |
| `--audit` | Report without changes |

### 95.4 Skill Interconnections

```
/godmode:opensource ──→ /godmode:license    (license selection during scaffolding)
/godmode:opensource ──→ /godmode:changelog  (changelog setup during scaffolding)
/godmode:opensource ──→ /godmode:cicd       (CI/CD pipeline after project setup)
/godmode:changelog  ──→ /godmode:ship       (publish release after changelog)
/godmode:license    ──→ /godmode:opensource (full setup after licensing)
/godmode:license    ──→ /godmode:secure     (security audit includes license check)
```

**Open Source Launch Chain:**
```
/godmode:license → /godmode:opensource → /godmode:changelog --setup → /godmode:cicd
```

**Release Chain:**
```
/godmode:changelog → /godmode:ship → /godmode:deploy
```

**Iterations 389-394 (3 skills created, 3 command files created, 1 design doc updated)**

---

## 81. Workflow Automation & Productivity Skills

### Overview

Four new skills extend Godmode into workflow automation, system migration, legacy code modernization, and effort estimation. These skills address the full lifecycle of development productivity: from automating repetitive tasks and planning large-scale technology transitions to safely modernizing legacy codebases and producing accurate effort estimates for planning.

### Skill: `/godmode:automate` — Task Automation

**Purpose:** Automate repetitive workflows with cron jobs, webhooks, GitHub Actions, scripts, and Makefiles/Taskfiles.

**Capabilities:**
- **Cron job design:** Create scheduled jobs with proper lock files, error handling, logging, and failure notifications for crontab, systemd timers, Kubernetes CronJobs, and GitHub Actions schedules
- **Webhook automation:** Design event-driven webhook handlers with signature verification, event routing, and idempotent processing
- **GitHub Actions workflows:** Generate CI/CD workflows for releases, PR automation, dependency updates, and custom automation triggers
- **Script automation:** Create robust Bash and Python automation scripts with argument parsing, dry-run support, logging, and error handling
- **Makefile/Taskfile design:** Generate task runners with help targets, dependency management, and CI helper targets
- **Git hooks:** Create pre-commit, pre-push, and other git hooks for quality enforcement

**Workflow:** Discover Automation Context -> Classify Automation Type -> Design (Cron | Webhook | Workflow | Script | Taskfile) -> Generate with Error Handling -> Report

**Artifacts produced:**
- `.github/workflows/*.yml` — GitHub Actions workflow files
- `Makefile` or `Taskfile.yml` — Task runner configuration
- `scripts/*.sh` or `scripts/*.py` — Automation scripts
- `.githooks/*` — Git hook scripts

**Flags:** `--cron <expression>`, `--webhook <event>`, `--workflow <name>`, `--script <name>`, `--makefile`, `--taskfile`, `--hook <git-hook>`, `--list`, `--audit`, `--dry-run`

### Skill: `/godmode:migration` — System Migration

**Purpose:** Plan and execute large-scale technology migrations with zero-downtime strategies, parallel verification, and documented rollback plans.

**Capabilities:**
- **Migration assessment:** Analyze source state, target state, constraints (downtime budget, timeline, data volume, compliance), and classify migration type (language, framework, API paradigm, architecture, data, infrastructure)
- **Strategy selection:** Choose between strangler fig (incremental replacement via facade), big bang (full rewrite with cutover), parallel run (shadow traffic comparison), and branch by abstraction (interface-based swap)
- **Language/framework migration:** Detailed phased plans for JS-to-TS, REST-to-GraphQL, monolith-to-microservices with conversion order, tracking, and strictness ramp-up
- **Zero-downtime data migration:** Dual-write, backfill, shadow reads, cutover, and cleanup phases with data integrity verification (row counts, checksums, spot checks)
- **Parallel run verification:** Compare old and new system outputs with match rate tracking, latency comparison, and confidence thresholds
- **Rollback planning:** Document trigger conditions, rollback steps, data reconciliation, feature flags, time estimates, and point of no return

**Workflow:** Migration Assessment -> Strategy Selection -> Migration Planning (language/framework/architecture specific) -> Data Migration Design -> Parallel Run Verification -> Rollback Planning -> Tracking & Reporting

**Artifacts produced:**
- `docs/migrations/<name>.md` — Migration plan and tracking document
- Migration code (adapters, abstractions, feature flags, comparison scripts)

**Flags:** `--assess`, `--plan`, `--track`, `--verify`, `--rollback`, `--strategy <name>`, `--phase <N>`, `--report`, `--dry-run`

### Skill: `/godmode:legacy` — Legacy Code Modernization

**Purpose:** Safely understand, stabilize, and incrementally modernize legacy codebases through characterization testing, dependency auditing, and prioritized refactoring.

**Capabilities:**
- **Legacy code characterization:** Assess codebase age, contributors, test coverage, linter config, documentation, type safety, dependency health, code quality signals (dead code, god classes, circular dependencies), and change confidence level
- **Code archaeology:** Understand legacy code through git blame analysis, dependency tracing, runtime behavior observation, comment/naming analysis, and test reverse-engineering
- **Characterization testing:** Add tests that capture current behavior (not intended behavior) as a safety net for refactoring, using inline snapshots and explicit edge case documentation
- **Golden master testing:** Save complex outputs (HTML, PDFs, reports) as golden master files and compare against them on every test run, with UPDATE_GOLDEN support
- **Approval testing:** Snapshot-based verification using Jest snapshots or pytest equivalents for automated behavior documentation
- **Dependency auditing:** Categorize updates (patch/minor/major), identify deprecated and EOL packages, detect known vulnerabilities, and produce upgrade recommendations with priority ordering
- **Technology obsolescence assessment:** Evaluate runtime versions, framework status, and library lifecycle against EOL dates and LTS schedules
- **Dead code removal:** Detect unused code through static analysis, coverage analysis, dependency analysis, git history, and runtime tracking, with safe removal process
- **Incremental modernization:** Prioritize P0 (security) through P4 (modernization) with safe refactoring techniques (extract method, extract class, sprout method, wrap external dependency)

**Workflow:** Legacy Code Characterization -> Understanding (Code Archaeology) -> Adding Tests (Characterization / Golden Master / Approval) -> Incremental Modernization -> Dependency Upgrades -> Obsolescence Assessment -> Dead Code Removal -> Roadmap & Report

**Artifacts produced:**
- `docs/legacy/<project>-assessment.md` — Codebase health assessment
- `docs/legacy/<project>-roadmap.md` — Modernization roadmap
- `tests/` — Characterization tests
- `tests/golden-masters/` — Golden master output files

**Flags:** `--assess`, `--characterize <path>`, `--golden-master <path>`, `--deps`, `--obsolescence`, `--dead-code`, `--roadmap`, `--coverage`, `--understand <path>`, `--dry-run`

### Skill: `/godmode:estimate` — Effort Estimation

**Purpose:** Produce accurate effort estimates using complexity analysis, risk assessment, three-point estimation with confidence intervals, and historical comparison.

**Capabilities:**
- **Complexity analysis:** Analyze tasks across 6 dimensions (code complexity, domain complexity, technical uncertainty, integration complexity, testing complexity, deployment complexity) with LOW/MEDIUM/HIGH ratings
- **Risk factor assessment:** Identify and quantify risks (unclear requirements, legacy code, external dependencies, technology unfamiliarity, cross-team coordination, scope creep) with probability-weighted impact multipliers
- **Three-point estimation:** Produce optimistic, most likely, and pessimistic estimates with PERT weighted average and confidence intervals (68%, 90%, 95%)
- **Task decomposition:** Break large tasks into 1-3 day subtasks with individual estimates, overhead multiplier, and risk adjustment
- **Reference class forecasting:** Compare against similar historical tasks to anchor estimates in reality rather than intuition
- **Sprint planning:** Calculate team capacity (developers, focus factor, PTO), size multiple tasks, assess sprint load, and recommend fit/tight/overloaded status
- **Story point calibration:** Fibonacci scale reference with example tasks at each level and decomposition rules for tasks above 13 points

**Workflow:** Understand Task -> Complexity Analysis -> Risk Factor Assessment -> Three-Point Estimation -> Task Decomposition -> Reference Class Comparison -> Sprint Planning (if applicable) -> Report

**Artifacts produced:**
- Estimation reports (not committed to git — planning artifacts only)
- Sprint planning summaries with capacity and load analysis

**Flags:** `--sprint`, `--quick`, `--decompose`, `--risk`, `--compare <task>`, `--capacity <N>`, `--confidence <N>`, `--points`, `--batch`

### Integration with Existing Skills

The workflow automation and productivity skills integrate into the Godmode workflow at these points:

```
/godmode:plan  ->  /godmode:estimate  ->  /godmode:build  ->  /godmode:automate
     |                    |                     |                    |
  Decompose          Estimate effort       Implement            Automate
  into tasks         for each task         with TDD             repetitive tasks

/godmode:legacy  ->  /godmode:migration  ->  /godmode:plan  ->  /godmode:build
     |                    |                      |                    |
  Assess and          Plan system            Decompose            Execute
  stabilize           migration              migration tasks      phase by phase
```

- **From `/godmode:plan`:** After decomposing work, invoke `/godmode:estimate` to size tasks for sprint planning
- **From `/godmode:estimate` to `/godmode:plan`:** If estimation reveals a task is too large, decompose further with `/godmode:plan`
- **From `/godmode:build` to `/godmode:automate`:** After implementing, automate repetitive workflows (CI, deployment, maintenance)
- **From `/godmode:legacy` to `/godmode:migration`:** After assessing legacy code, plan the system migration strategy
- **From `/godmode:legacy` to `/godmode:test`:** After adding characterization tests, use `/godmode:test` to expand coverage
- **From `/godmode:migration` to `/godmode:plan`:** After migration planning, decompose each phase into implementable tasks
- **From `/godmode:automate` to `/godmode:cicd`:** Automation workflows often integrate with CI/CD pipeline configuration

### Design Principles for Workflow & Productivity Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Ranges over point estimates | Never give a single number; always provide confidence intervals |
| 2 | Tests before refactoring | Add characterization tests before modifying any legacy code |
| 3 | Incremental over big bang | Strangler fig and incremental migration over full rewrites |
| 4 | Error handling is mandatory | Every automation script must handle errors, log, and notify |
| 5 | Reversibility required | Every migration step and automation must have a rollback plan |
| 6 | Evidence over intuition | Use reference class forecasting, not gut feelings, for estimates |
| 7 | Security first | Patch vulnerabilities before modernizing; never hardcode secrets |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/automate/SKILL.md` | Skill | Task automation and workflow orchestration |
| `skills/migration/SKILL.md` | Skill | System migration and technology transition |
| `skills/legacy/SKILL.md` | Skill | Legacy code modernization |
| `skills/estimate/SKILL.md` | Skill | Effort estimation and complexity analysis |
| `commands/godmode/automate.md` | Command | Usage reference for `/godmode:automate` |
| `commands/godmode/migration.md` | Command | Usage reference for `/godmode:migration` |
| `commands/godmode/legacy.md` | Command | Usage reference for `/godmode:legacy` |
| `commands/godmode/estimate.md` | Command | Usage reference for `/godmode:estimate` |

**Iterations 252-259 (8 files, 4 skills, 4 commands)**

---

## 79. Specialized Domain Skills

### Overview

Skills for specialized infrastructure and application domains that are common across modern SaaS and web applications. These skills encode deep operational knowledge for networking, file storage, payment processing, and communication systems — domains where getting the details wrong leads to outages, security breaches, compliance violations, or revenue loss.

### Skills in this Category

#### `/godmode:network` — Network & DNS

**Purpose:** Configure, troubleshoot, and secure networking infrastructure across DNS, SSL/TLS, CDN, load balancers, and VPC design.

**Core capabilities:**
- **DNS configuration:** Record design (A, CNAME, MX, TXT), propagation validation across multiple resolvers, email DNS (SPF, DKIM, DMARC), troubleshooting resolution failures
- **SSL/TLS management:** Let's Encrypt with certbot, Kubernetes cert-manager with ClusterIssuers, certificate monitoring and auto-renewal, TLS version and cipher suite configuration, HSTS enforcement
- **CDN configuration:** CloudFront distributions with cache behaviors, Cloudflare zones with WAF and bot protection, Fastly VCL configuration, cache strategy by asset type (HTML no-cache, hashed assets immutable, API bypass)
- **Load balancer setup:** AWS ALB/NLB with target groups and routing rules, Nginx upstream configuration with least-conn and connection pooling, HAProxy with stick tables and rate limiting, health check design (interval, thresholds, timeout)
- **Network security:** Three-tier VPC architecture (public/private/isolated), security group design with least privilege, Network ACLs for subnet-level deny rules, VPC endpoints for private AWS API access, VPC Flow Logs for forensic analysis
- **Troubleshooting:** 502 Bad Gateway diagnosis (backend health, security groups, port conflicts), DNS resolution failures (propagation, DNSSEC, nameserver delegation), certificate expiry detection and remediation, latency investigation (traceroute, connection timing)

**Invocation:** `/godmode:network`, "configure DNS", "set up SSL", "CDN setup", "load balancer", "firewall rules", "VPC design", "fix 502"

**Output:** Network configuration files in `infra/` with commit `"network: <description> — <components configured>"`

**Flags:** `--dns`, `--ssl`, `--cdn`, `--lb`, `--vpc`, `--security`, `--troubleshoot`, `--domain <name>`, `--provider <name>`

#### `/godmode:storage` — File Storage & CDN

**Purpose:** Design and implement file storage systems with upload architecture, media processing pipelines, cost optimization, and disaster recovery.

**Core capabilities:**
- **Object storage configuration:** S3/GCS/Azure Blob bucket design with folder structure, encryption (SSE-S3, KMS), versioning, block public access, bucket policies enforcing SSL and encryption
- **File upload architecture:** Presigned URL direct-to-storage uploads (card data never touches server pattern for files), multipart uploads for large files with concurrent chunk uploads and retry, resumable uploads via tus protocol for unstable connections, server-side validation (MIME sniffing, file header inspection, virus scanning)
- **Image processing pipeline:** Validation and malware scanning, EXIF stripping for privacy, variant generation (thumbnail, medium, large) with Sharp, WebP/AVIF conversion for size reduction, blur placeholder generation for progressive loading
- **Video processing pipeline:** Transcoding to multiple quality levels (720p, 1080p, 4K), HLS adaptive bitrate streaming with segment-based delivery, thumbnail and preview GIF generation, subtitle extraction and waveform visualization
- **Storage cost optimization:** Lifecycle policies (Standard -> IA -> Glacier -> Deep Archive), incomplete multipart upload cleanup, orphaned file detection and deletion, CDN egress optimization, WebP conversion savings analysis, cost projection with before/after comparison
- **Backup and replication:** Cross-region replication with Replication Time Control, cross-account backup with S3 Object Lock (immutable), RPO/RTO target definition, monthly restore testing protocol

**Invocation:** `/godmode:storage`, "file upload", "S3 bucket", "image processing", "storage costs", "backup strategy"

**Output:** Storage configuration and upload service code with commit `"storage: <description> — <components configured>"`

**Flags:** `--upload`, `--process`, `--optimize`, `--backup`, `--lifecycle`, `--migrate`, `--provider <name>`, `--audit`

#### `/godmode:pay` — Payment & Billing Integration

**Purpose:** Implement payment processing, subscription billing, invoicing, and tax calculation with PCI-DSS compliance and reliable webhook handling.

**Core capabilities:**
- **Payment gateway integration:** Stripe PaymentIntents with client-side card collection (PCI SAQ-A), PayPal Orders API v2 with server-side capture, Braintree drop-in UI, idempotency keys on all write operations, 3D Secure for SCA compliance
- **Subscription billing:** Plan definition with monthly/annual pricing, trial periods with automatic conversion, proration on plan upgrades and downgrades, metered/usage-based billing with usage record reporting, dunning flow with escalating notifications (Day 0-3-7-14-21)
- **Invoice generation:** Sequential invoice numbering (never reused, no gaps), line items with subtotal/tax/discount/total, PDF generation and S3 storage, customer portal for invoice history, multi-entity support with regional prefixes
- **Tax calculation:** US sales tax with nexus tracking and economic nexus rules, EU VAT with B2C rates by country and B2B reverse charge, VAT ID collection and VIES validation, integration with Stripe Tax, TaxJar, or Avalara
- **PCI-DSS compliance:** SAQ-A architecture (card data never touches your server), Stripe.js Elements iframe for card input, API key management via secrets manager, no card data in logs/errors/analytics, 3D Secure enforcement
- **Webhook handling:** Stripe webhook signature verification, idempotent event processing with deduplication, database transaction wrapping, handling for 9+ event types (payment success/failure, subscription lifecycle, disputes), daily reconciliation between provider and database

**Invocation:** `/godmode:pay`, "integrate Stripe", "subscription billing", "payment processing", "invoice system", "PCI compliance", "tax calculation"

**Output:** Payment service code and webhook handlers with commit `"pay: <description> — <components implemented>"`

**Flags:** `--checkout`, `--subscription`, `--invoice`, `--tax`, `--webhooks`, `--pci`, `--migrate`, `--provider <name>`, `--dunning`, `--reconcile`

#### `/godmode:email` — Email & Notification Systems

**Purpose:** Build email delivery and multi-channel notification systems with deliverability monitoring, bounce handling, and user preference management.

**Core capabilities:**
- **Email service integration:** SendGrid, SES, Postmark, and Resend with domain verification and API setup, provider comparison by use case (Resend for DX, Postmark for deliverability, SendGrid for marketing, SES for volume/cost)
- **Email template design:** React Email components with TypeScript props for type-safe templates, MJML for maximum cross-client compatibility (Outlook, Gmail, Apple Mail), responsive single-column layout, blur-up image loading, plain text fallback for every HTML email
- **Notification system architecture:** Event-driven multi-channel routing (email, push, SMS, in-app), per-user per-channel preference management, rate limiting per user (max N notifications/hour), digest batching for low-priority notifications, queue-based async delivery with retry
- **Delivery tracking and bounce handling:** Email lifecycle tracking (queued -> sent -> delivered -> opened -> clicked), hard bounce detection with immediate suppression, soft bounce tracking with escalation after 3 bounces in 30 days, spam complaint handling with automatic unsubscribe and team alerting, deliverability metrics dashboard (delivery rate, bounce rate, spam complaint rate)
- **Email DNS authentication:** SPF, DKIM, and DMARC configuration with progressive DMARC policy (none -> quarantine -> reject over 30 days), bounce domain alignment, subdomain strategy for transactional vs marketing isolation
- **Transactional vs marketing separation:** Separate subdomains (notifications.* vs marketing.*), separate IPs or provider accounts, isolated sender reputation, IP warm-up schedule for new dedicated IPs (50/day to full volume over 30 days)

**Invocation:** `/godmode:email`, "send emails", "notification system", "email templates", "push notifications", "bounce handling", "deliverability"

**Output:** Notification service code and email templates with commit `"email: <description> — <components implemented>"`

**Flags:** `--email`, `--templates`, `--push`, `--sms`, `--inapp`, `--deliverability`, `--provider <name>`, `--dns`, `--preferences`, `--digest`

### Skill Interactions

The specialized domain skills integrate with the core Godmode workflow and each other:

```
/godmode:network ──→ /godmode:storage ──→ /godmode:pay ──→ /godmode:email
(infrastructure)     (file serving)       (billing)        (receipts/alerts)
```

Cross-skill integration:
- **Network -> Storage:** CDN configuration for serving stored files (CloudFront + S3)
- **Network -> Pay:** SSL/TLS for payment pages, WAF rules for checkout protection
- **Storage -> Email:** Email attachments (invoices, receipts) stored in object storage
- **Pay -> Email:** Payment receipts, subscription confirmations, dunning emails all flow through the email system
- **Secure -> All:** Security audit validates each domain (TLS config, bucket policies, PCI compliance, email authentication)
- **Deploy -> Network:** Deployment updates DNS, CDN invalidation, load balancer target groups

### Design Principles for Specialized Domain Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Security by default | TLS everywhere, presigned URLs, PCI SAQ-A, email authentication |
| 2 | Never proxy what you can direct | Direct-to-storage uploads, client-side card tokenization, CDN serving |
| 3 | Cost awareness from day one | Lifecycle policies, CDN egress optimization, provider cost comparison |
| 4 | Compliance is not optional | PCI-DSS for payments, CAN-SPAM/GDPR for email, data residency for storage |
| 5 | Monitor everything | VPC Flow Logs, delivery metrics, payment reconciliation, CDN cache hit ratio |
| 6 | Graceful degradation | Dunning for failed payments, soft bounce retry, CDN origin failover |
| 7 | Separate concerns | Transactional vs marketing email, hot vs cold storage, auth vs application traffic |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/network/SKILL.md` | Skill | Network & DNS workflow |
| `skills/storage/SKILL.md` | Skill | File Storage & CDN workflow |
| `skills/pay/SKILL.md` | Skill | Payment & Billing Integration workflow |
| `skills/email/SKILL.md` | Skill | Email & Notification Systems workflow |
| `commands/godmode/network.md` | Command | Usage reference for `/godmode:network` |
| `commands/godmode/storage.md` | Command | Usage reference for `/godmode:storage` |
| `commands/godmode/pay.md` | Command | Usage reference for `/godmode:pay` |
| `commands/godmode/email.md` | Command | Usage reference for `/godmode:email` |

**Iterations 236-243 (8 files, 4 skills, 4 commands)**

## 95. Open Source & Community Skills

Three skills for managing open source projects end-to-end: from license selection through community scaffolding to changelog automation.

### 95.1 Open Source Project Management (`/godmode:opensource`)

Repository setup and community management for open source projects.

**Repository Scaffolding** — generates or audits all community health files:
- LICENSE, CODE_OF_CONDUCT.md (Contributor Covenant 2.1), CONTRIBUTING.md, SECURITY.md
- `.github/ISSUE_TEMPLATE/` (bug report YAML, feature request YAML, config)
- `.github/PULL_REQUEST_TEMPLATE.md`
- `.github/CODEOWNERS`, `.github/FUNDING.yml`

**GitHub Actions Automation** — workflows for project management:
- `labeler.yml` — auto-labels PRs by file path
- `stale.yml` — marks and closes inactive issues/PRs (60 days stale, 14 days to close)
- `welcome.yml` — greets first-time contributors on issues and PRs
- `release-drafter.yml` — auto-drafts release notes from merged PRs

**Maintainer Workflows** — structured processes:
- Triage: new issue → bot labels → maintainer triage (48h SLA) → categorize → assign/label
- Review: PR opened → CI runs → CODEOWNERS auto-assigns → code review → merge
- Release: scope determination → changelog → version bump → tag → publish → announce

**Governance Models** — three models matched to project size:
- BDFL (1-20 contributors): single decision authority, fast iteration
- Consensus (10-50 contributors): core team with 72-hour discussion periods
- Steering Committee (50+ contributors): elected committee, working groups, RFC process

| Flag | Description |
|------|-------------|
| `--audit` | Audit only, no file creation |
| `--governance <model>` | Set governance model (bdfl, consensus, committee) |
| `--templates` | Issue and PR templates only |
| `--automation` | GitHub Actions workflows only |
| `--community` | Community channels only |
| `--minimal` | LICENSE, README, CONTRIBUTING, CODE_OF_CONDUCT only |

### 95.2 Changelog & Release Notes (`/godmode:changelog`)

Changelog generation and release communication.

**Keep a Changelog Format** — standard sections: Added, Changed, Deprecated, Removed, Fixed, Security. Latest version first, release dates, comparison links.

**Conventional Commits Integration** — commit types (feat, fix, perf, refactor, docs, test, chore, ci, build, style, revert) parsed into changelog entries. Setup includes commitlint, Commitizen, and Husky hooks.

**Auto-Generation Tooling**:
- `conventional-changelog` for local generation
- `release-please` GitHub Action for automated release PRs
- `standard-version` for local bump + changelog + tag

**Audience-Specific Release Notes**:
- Developer-facing: breaking changes with before/after code, new APIs, bug fixes with issue refs
- User-facing: highlights in plain language, capability improvements, upgrade notices

**Breaking Change Communication**:
- Advance notice via deprecation warnings (1-2 releases before)
- Migration guide with step-by-step instructions, codemods, rollback steps
- Release communication across changelog, GitHub Release, blog, community channels
- Support window for previous major version

| Flag | Description |
|------|-------------|
| `--setup` | Configure Conventional Commits + auto-changelog |
| `--release <version>` | Generate changelog for specific version |
| `--migration <from> <to>` | Generate migration guide |
| `--notes` | User-facing release notes |
| `--dev-notes` | Developer-facing release notes |
| `--breaking` | Breaking changes only |
| `--full` | Regenerate from full git history |

### 95.3 License Management (`/godmode:license`)

License selection, compliance, and attribution.

**License Selection Guidance** — comparison matrix covering MIT, Apache 2.0, GPL v3, AGPL v3, MPL 2.0, BSL 1.1, and proprietary. Each profile includes SPDX identifier, permissions, conditions, limitations, best-for scenarios, risks, and notable users.

**License Compatibility Checking** — dependency scanner that cross-references every dependency's license against the project license. Produces compatibility matrix: OK, OK with NOTICE, WARN (consult legal), FAIL (incompatible).

**SPDX Identifiers and File Headers** — standardized `// SPDX-License-Identifier: <id>` headers for all source files with language-specific templates (JS/TS, Python, Go, Rust, Java, HTML, Shell). CI enforcement via `skywalking-eyes` or `addlicense`.

**Third-Party Attribution** — NOTICE file and THIRD_PARTY_LICENSES generation from dependency trees. Covers attribution requirements per license type (MIT needs copyright, Apache 2.0 needs NOTICE file, etc.).

**CLA / DCO Setup**:
- Developer Certificate of Origin (DCO): lightweight, `Signed-off-by` line, used by CNCF/Linux Foundation
- Individual CLA: contributor signs via GitHub bot comment
- Corporate CLA: company signs on behalf of employees
- Automated enforcement via GitHub Actions

| Flag | Description |
|------|-------------|
| `--select` | Interactive license selection |
| `--check` | Dependency compatibility check |
| `--headers` | Add SPDX headers to source files |
| `--attribution` | Generate NOTICE and attribution files |
| `--cla` | Set up CLA enforcement |
| `--dco` | Set up DCO enforcement |
| `--apply <license>` | Apply specific license |
| `--audit` | Report without changes |

### 95.4 Skill Interconnections

```
/godmode:opensource ──→ /godmode:license    (license selection during scaffolding)
/godmode:opensource ──→ /godmode:changelog  (changelog setup during scaffolding)
/godmode:opensource ──→ /godmode:cicd       (CI/CD pipeline after project setup)
/godmode:changelog  ──→ /godmode:ship       (publish release after changelog)
/godmode:license    ──→ /godmode:opensource (full setup after licensing)
/godmode:license    ──→ /godmode:secure     (security audit includes license check)
```

**Open Source Launch Chain:**
```
/godmode:license → /godmode:opensource → /godmode:changelog --setup → /godmode:cicd
```

**Release Chain:**
```
/godmode:changelog → /godmode:ship → /godmode:deploy
```

**Iterations 389-394 (3 skills created, 3 command files created, 1 design doc updated)**

---

## 90. Game & Creative Development Skills

### `/godmode:gamedev` — Game Development Architecture

**Purpose:** Architect, build, and optimize games across engines and frameworks with production-grade game loops, physics, asset pipelines, and performance profiling.

**Core capabilities:**
- **Architecture patterns:** Entity-Component-System (ECS) with archetype storage and system scheduling, component-based architecture (Unity MonoBehaviour, Godot Node), and scene graph hierarchies. Decision matrix comparing cache performance, iteration speed, designer-friendliness, and parallelism across patterns.
- **Game loop design:** Fixed timestep with interpolation — physics at 60Hz deterministic, rendering at VSync with alpha blending between states. Frame time capped at 250ms to prevent spiral of death. Input polling once per frame, fixed update N times per frame, late update for camera/UI, render with interpolation.
- **Physics & collision detection:** Three-phase pipeline — broad phase (spatial hash, quadtree, sweep-and-prune, BVH), narrow phase (AABB, circle, SAT, GJK+EPA), resolution (position correction, impulse-based velocity, iterative constraint solver). Collision layers with bitmask filtering.
- **Asset pipeline management:** Source-to-runtime conversion for sprites (atlas), models (GLTF/GLB), textures (KTX2/Basis), audio (OGG/WebM), levels (JSON), fonts (MSDF), shaders (SPIRV). Loading strategies: eager, level-based, streaming, on-demand, predictive. Git LFS for source assets, hot-reload for development.
- **Engine/framework selection:** Decision matrix across Unity, Unreal, Godot, Bevy, Three.js, Phaser, PixiJS, Babylon.js, PlayCanvas, Excalibur — comparing 2D/3D support, learning curve, performance, language, platform targets, cost, VR/AR, and ideal use cases.
- **Performance optimization:** Frame budget allocation (input, physics, AI, animation, render, post-process). CPU: object pooling, spatial partitioning, LOD for logic, job systems, cache-friendly layout. GPU: draw call batching, texture atlasing, mesh LOD, frustum/occlusion culling, shader audit, resolution scaling. Memory: streaming, compression, budgets per category, leak detection. Network: delta compression, client prediction, entity interpolation.
- **Game-specific patterns:** FSM, HFSM, and behavior trees for AI and game states. Common systems checklist: input (rebindable), camera (follow/shake/zoom), audio (spatial/layers/pooling), save/load (versioned serialization), UI, particles, tweens, events, localization, achievements, debug tools.

**Invocation:** `/godmode:gamedev`, "game architecture", "game loop", "ECS", "entity component system", "collision detection", "game performance", "game engine"

**Key principle:** Fixed timestep is non-negotiable for deterministic physics. Profile before optimizing — the bottleneck is never where you think. Object pooling for anything created at runtime. Separate game logic from rendering to enable headless testing, replays, and multiplayer. Budget every resource at project start and enforce continuously.

---

### `/godmode:animation` — Animation & Motion Design

**Purpose:** Create, audit, and optimize web animations with CSS, Framer Motion, GSAP, and Lottie, ensuring performance, accessibility, and cohesive motion design.

**Core capabilities:**
- **CSS animation foundations:** Transitions for state changes (hover, focus, toggle) with timing guide per interaction type. Keyframe animations for multi-step and looping effects. CSS scroll-driven animations (animation-timeline: scroll()/view()) for native scroll-linked motion. Easing reference: ease-out for entering, ease-in for exiting, spring overshoot via cubic-bezier.
- **Animation library selection:** Decision matrix across Framer Motion, GSAP, Lottie, and CSS-only — comparing React integration, bundle size, spring physics, gesture support, layout animation, SVG, scroll-driven, timeline, performance, designer handoff, and licensing.
- **Framer Motion patterns:** AnimatePresence for enter/exit, staggered lists with variants, layout animations with layoutId for shared elements, whileInView for scroll-triggered, whileHover/whileTap for gestures, drag with constraints and velocity-based swipe detection.
- **GSAP patterns:** Basic tweens, choreographed timelines with overlap control, ScrollTrigger with scrub/pin/markers, stagger with distribution control, DrawSVG for path animation, SplitText for character-level text animation.
- **Lottie integration:** lottie-react and lottie-web setup, playback control, dotLottie compression (50-80% smaller), optimization guidelines (layer limits, keyframe limits, renderer selection).
- **Page transitions & micro-interactions:** Transition patterns (crossfade, slide, shared element, cover, zoom, stagger reveal). View Transition API for modern browsers. Micro-interaction catalog for buttons, form fields, toggles, navigation, and feedback.
- **Performance optimization:** Compositor-only properties (transform, opacity) mandatory. will-change applied sparingly and removed after animation. requestAnimationFrame for JS animations. Layout thrashing prevention. contain:layout paint for animated containers. GPU compositing diagnosis via DevTools.
- **Reduced motion accessibility:** prefers-reduced-motion media query (global), parallax and auto-play disabled, page transitions simplified, loading spinners kept (functional), user toggle in app settings, tested with OS reduced motion enabled.

**Invocation:** `/godmode:animation`, "animate", "motion design", "page transition", "scroll animation", "micro-interaction", "Framer Motion", "GSAP", "Lottie"

**Key principle:** CSS first, libraries second — most hover effects and toggles need zero JavaScript. Compositor-only properties (transform, opacity) are mandatory for 60 FPS. Reduced motion is not optional — it is an accessibility requirement. Exit animations should be faster than entrances. Every animation must serve a UX purpose: indicate state, guide attention, provide feedback, or communicate spatial relationships.

---

### `/godmode:three` — 3D Web Development

**Purpose:** Build, optimize, and ship 3D web experiences with Three.js, React Three Fiber, WebGL/WebGPU, custom shaders, and WebXR for VR/AR.

**Core capabilities:**
- **Three.js / React Three Fiber architecture:** Scene setup with renderer configuration (antialias, pixel ratio capped at 2, color space, tone mapping, shadows). R3F declarative scene graph with Canvas, useFrame, useThree, useLoader, drei helpers. Component patterns with refs, per-frame updates, pointer events, and Suspense-based loading.
- **WebGL/WebGPU fundamentals:** Rendering pipeline (vertex shader, rasterization, fragment shader, depth test, blending). WebGL 2 vs WebGPU comparison: GLSL vs WGSL, compute shaders, multi-threaded command buffers, bind groups, browser support. Selection guidance based on requirements.
- **3D asset optimization:** GLTF optimization pipeline with gltf-transform — cleanup, mesh simplification, Draco compression (80-90% geometry savings), Meshopt (GPU-decodable), KTX2/Basis texture compression (75% GPU memory savings), GLB packing, gzip transfer. Texture format guide per map type. Size budgets for mobile and desktop.
- **Shader programming:** Vertex and fragment shader fundamentals with Three.js ShaderMaterial. Uniform management and animation loop integration. Common techniques: UV scrolling, Fresnel, noise, normal mapping, dissolve, toon shading, screen-space effects, ray marching, PBR custom, instanced shaders. R3F integration with drei shaderMaterial helper.
- **Lighting & materials:** Light type reference (ambient, directional, point, spot, hemisphere, rect area, environment map) with shadow cost and use cases. Three-point and environment-based lighting setups. PBR material property guide with real-world references (plastic, metal, wood, glass, ceramic, fabric, water).
- **VR/AR web experiences (WebXR):** Session types (immersive-vr, immersive-ar, inline). Three.js XR setup with VRButton/ARButton. R3F XR via @react-three/xr with Controllers, Hands, and interaction hooks. Checklist: feature detection, fallback, locomotion, controller/hand models, hit testing, foveated rendering, stereo rendering, accessibility.
- **Performance optimization:** Geometry (LOD, instancing, merged static geometry, frustum/occlusion culling). Textures (KTX2, power-of-2, mipmaps, max 2048). Materials (sharing, transparency avoidance). Draw call budgets (mobile <50, desktop <200). Shadows (map size, cascade, bias, baking). Post-processing (resolution scaling, pass limits, FXAA). Monitoring with renderer.info and r3f-perf.

**Invocation:** `/godmode:three`, "three.js", "react three fiber", "R3F", "3D web", "WebGL", "WebGPU", "WebXR", "shader", "GLTF", "3D"

**Key principle:** GLTF is the standard for web 3D — use GLB for all assets. Compress everything: Draco for geometry, KTX2 for textures, gzip for transfer. Dispose resources explicitly or leak GPU memory. Cap pixel ratio at 2. Use instancing for repeated geometry. Test on mobile — desktop GPUs are 10-50x more powerful.

---

### Integration with Existing Skills

```
/godmode:gamedev  ->  /godmode:three  ->  /godmode:animation
     |                     |                     |
  Game architecture   3D rendering        Motion polish

/godmode:three  ->  /godmode:perf  ->  /godmode:ship
     |                   |                  |
  3D scene          Profile FPS        Deploy to web

/godmode:animation  ->  /godmode:a11y  ->  /godmode:ship
     |                       |                  |
  Motion design       Reduced motion      Ship accessible
```

- **From `/godmode:gamedev` to `/godmode:three`:** Game architecture defines the systems; Three.js implements the 3D rendering layer. ECS or scene graph architecture maps directly to Three.js scene management.
- **From `/godmode:three` to `/godmode:animation`:** 3D scene structure is built first; animation adds motion, transitions, and interaction polish to the 3D experience.
- **From `/godmode:animation` to `/godmode:a11y`:** Motion design implements animations; accessibility audit ensures all animations respect prefers-reduced-motion and do not cause vestibular issues.
- **From `/godmode:gamedev` to `/godmode:perf`:** Game performance profiling with frame timing analysis. Perf skill provides CPU/memory profiling that complements game-specific GPU profiling.

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/gamedev/SKILL.md` | Skill | Game development architecture workflow |
| `skills/animation/SKILL.md` | Skill | Animation and motion design workflow |
| `skills/three/SKILL.md` | Skill | 3D web development workflow |
| `commands/godmode/gamedev.md` | Command | Usage reference for `/godmode:gamedev` |
| `commands/godmode/animation.md` | Command | Usage reference for `/godmode:animation` |
| `commands/godmode/three.md` | Command | Usage reference for `/godmode:three` |

**Iterations 332-337 (3 skills created, 3 command files created, 1 design doc updated)**

## 91. Design System & UI Architecture Skills

Three new skills extend Godmode's frontend capabilities into design system architecture, form engineering, and responsive design — the foundation of every production-quality user interface.

### 91.1 Design System — Design System Architecture (`skills/designsystem/SKILL.md`)

**Purpose:** Build, maintain, and audit design systems with token architecture, component API standards, theme systems, design-to-code pipelines, and versioned distribution.

**Key capabilities:**
- **Three-tier token architecture:** Primitives (raw values) -> Semantic tokens (meaning) -> Component tokens (component-specific). This layering enables theming without touching component code.
- **Token categories:** Colors (neutral scales, brand scales, feedback), spacing (4px base unit, 16-step scale), typography (modular scale 1.25, font stacks, composite text styles), shadows (xs through 2xl + focus ring), borders, motion, z-index.
- **Component API standards:** Enforced prop naming (variant, size, children, className), TypeScript typing (extend native HTML attributes), ref forwarding, compound component pattern, controlled/uncontrolled modes, sensible defaults.
- **Theme system:** Light/dark via CSS custom properties with `data-theme` attribute, system preference detection via `prefers-color-scheme`, localStorage persistence, flash-free SSR, multi-brand theming via `data-brand` attribute.
- **Design-to-code pipeline:** Figma Variables/Tokens Studio export -> W3C Design Token Format -> Style Dictionary transformer -> CSS variables + TypeScript constants + Tailwind config. CI automation via Figma webhook triggers.
- **Versioning and distribution:** Semantic versioning (major = breaking, minor = new features, patch = fixes), conventional changelog, npm publish, Storybook deploy via Chromatic, consumer PR automation.
- **Storybook documentation:** Foundation pages (colors, typography, spacing, shadows), component catalog with autodocs, interactive controls, a11y addon, viewport addon, design addon for Figma links.
- **Maturity scoring:** NONE (0-25) / STARTER (26-50) / GROWING (51-75) / MATURE (76-100) across token coverage, API compliance, theme support, pipeline automation, documentation, and distribution.

**Workflow:** Assess maturity -> Build token architecture -> Define API standards -> Implement theme system -> Configure pipeline -> Set up versioning -> Document in Storybook -> Audit and report.

**Command:** `/godmode:designsystem` (`commands/godmode/designsystem.md`)

### 91.2 Forms — Form Architecture (`skills/forms/SKILL.md`)

**Purpose:** Build complex, accessible, validated forms with state management, multi-step wizards, async validation, file uploads, and focus management.

**Key capabilities:**
- **State management selection:** Decision matrix comparing React Hook Form, Formik, native useState, and server actions across re-renders, bundle size, TypeScript support, complexity handling, and learning curve.
- **Validation patterns:** Zod schemas shared between client and server. Client-side validation on blur (first visit) and onChange (re-validation). Server-side validation with same schema. Async validation with debounce for uniqueness checks.
- **Multi-step wizard forms:** Step-level schema validation, sessionStorage persistence (survives refresh), URL-synced step navigation, visual progress indicator with accessibility (aria-current="step"), back navigation preserving data.
- **File upload handling:** Drag-and-drop zone with keyboard accessibility, file type/size/count validation before upload, upload progress tracking, image preview with URL.createObjectURL, accessible file list with remove buttons.
- **Accessible form design:** Visible labels (never placeholder-as-label), aria-describedby for error messages, aria-invalid on error fields, error summary component linked to fields, focus-on-first-error on submit failure, required field indication (visual + screen reader).
- **Advanced patterns:** Conditional fields (show/hide based on other field values), dynamic field arrays (add/remove rows), autosave with debounce and status indicator, controlled/uncontrolled component modes.
- **Error display strategy:** Show on blur (first visit), re-validate on change (after error), focus first error on submit, inline errors with role="alert", error summary at form top, specific actionable messages.

**Workflow:** Assess requirements -> Choose state management -> Build validation schemas -> Implement form (single-page or wizard) -> Add file uploads -> Ensure accessibility -> Audit and report.

**Command:** `/godmode:forms` (`commands/godmode/forms.md`)

### 91.3 Responsive — Responsive & Adaptive Design (`skills/responsive/SKILL.md`)

**Purpose:** Build interfaces that work across every viewport using CSS Grid, Flexbox, container queries, fluid typography, responsive images, print stylesheets, and touch/pointer adaptation.

**Key capabilities:**
- **Layout strategies:** Mobile-first (min-width, progressive enhancement), desktop-first (max-width, graceful degradation), intrinsic (container queries, component-level responsiveness). Decision matrix for strategy selection.
- **CSS Grid mastery:** Auto-fit/minmax for responsive card grids, named grid areas for complex dashboard layouts, subgrid for cross-card alignment, responsive grid area reassignment at breakpoints.
- **Container queries:** Component-level responsive design independent of viewport. Container query units (cqi). Combined with Grid for sidebar-aware components. Named containers for targeted queries.
- **Flexbox patterns:** Responsive navigation (hamburger on mobile, horizontal on desktop), holy grail layout, wrapping card rows with flex-basis minimum widths.
- **Fluid typography:** clamp()-based type scale that scales continuously between mobile and desktop without breakpoints. Fluid spacing using the same approach.
- **Responsive images:** srcset for resolution switching, `<picture>` for art direction, modern format serving (avif -> webp -> jpg fallback), lazy loading, fetchpriority for LCP images, responsive CSS background images with retina support.
- **Print stylesheets:** Hide navigation and non-essential elements, show link URLs, control page breaks (avoid orphaned headings), repeat table headers, ink-conservation color reset, @page margin control.
- **Touch vs pointer:** Pointer media queries (fine/coarse) for hit target sizing, hover media queries for hover-dependent features, touch-action control, scroll-snap for touch carousels, manipulation hint for double-tap prevention.
- **Responsive data tables:** Horizontal scroll pattern with fade indicator, stack-to-cards pattern on mobile using data-label attributes, column priority hiding.

**Workflow:** Assess requirements -> Choose strategy -> Implement breakpoints -> Build Grid/Flex layouts -> Add container queries -> Implement fluid type -> Optimize images -> Add print styles -> Handle touch/pointer -> Audit all viewports -> Report.

**Command:** `/godmode:responsive` (`commands/godmode/responsive.md`)

### Integration with Existing Skills

```
/godmode:designsystem  ->  /godmode:ui  ->  /godmode:a11y
        |                       |                |
  Build token system     Audit components   Verify accessibility
        |                       |                |
        v                       v                v
/godmode:forms  ->  /godmode:responsive  ->  /godmode:visual
        |                  |                       |
  Build forms        Make responsive       Visual regression test
```

- **From `/godmode:designsystem` to `/godmode:ui`:** Design system provides tokens and API standards; UI skill audits component compliance against those standards.
- **From `/godmode:designsystem` to `/godmode:forms`:** Form components consume design tokens for consistent styling. Form field components follow API standards.
- **From `/godmode:forms` to `/godmode:a11y`:** Forms are the most accessibility-critical UI pattern. Form skill ensures labels, errors, and focus; a11y skill verifies with automated tools and manual checklists.
- **From `/godmode:responsive` to `/godmode:visual`:** Responsive layouts need visual regression testing across viewports. Visual skill captures screenshots at each breakpoint.
- **From `/godmode:responsive` to `/godmode:perf`:** Responsive images and fluid design affect Core Web Vitals (LCP, CLS). Perf skill measures the impact.

### Design Principles for UI Architecture Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Tokens are the single source of truth | Every visual value comes from a token; hardcoded values are violations |
| 2 | Components follow uniform APIs | Same prop naming, typing, composition, and ref forwarding everywhere |
| 3 | Accessibility is a baseline, not a feature | Every form has labels, every error has focus management, every component has keyboard support |
| 4 | Mobile-first forces content prioritization | Start with the smallest viewport to force decisions about what matters |
| 5 | Container queries make components truly reusable | Components respond to their container, not the viewport |
| 6 | Validation runs on both sides | Client validation for UX, server validation for security, shared schema for consistency |
| 7 | The design system is a product | Version it, document it, distribute it, maintain it like any other dependency |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/designsystem/SKILL.md` | Skill | Design system architecture with tokens, themes, pipeline |
| `skills/forms/SKILL.md` | Skill | Form architecture with validation, wizards, uploads |
| `skills/responsive/SKILL.md` | Skill | Responsive design with Grid, container queries, images |
| `commands/godmode/designsystem.md` | Command | Usage reference for `/godmode:designsystem` |
| `commands/godmode/forms.md` | Command | Usage reference for `/godmode:forms` |
| `commands/godmode/responsive.md` | Command | Usage reference for `/godmode:responsive` |

**Iterations 338-343 (6 files, 3 skills, 3 commands)**

---

## 88. Platform-Specific Development Skills

Platform-specific development skills bring specialized capabilities for emerging and niche development platforms to Godmode. These five skills cover blockchain/Web3, IoT and embedded systems, desktop applications, CLI tools, and browser extensions — each with deep, production-grade guidance that goes far beyond general-purpose coding advice.

### Skills Overview

| Skill | Command | Purpose |
|-------|---------|---------|
| Web3 | `/godmode:web3` | Blockchain & Web3 — Smart contracts (Solidity, Rust/Anchor), security auditing, token standards, DApp architecture, gas optimization |
| IoT | `/godmode:iot` | IoT & Embedded Systems — Firmware architecture (FreeRTOS, Zephyr), MQTT/CoAP protocols, OTA updates, power optimization, fleet management |
| Desktop | `/godmode:desktop` | Desktop Applications — Electron, Tauri, Qt architecture, auto-update, cross-platform builds, native API integration, code signing |
| CLI | `/godmode:cli` | CLI Tool Development — Argument parsing (Commander, Clap, Cobra, Click), TUI frameworks, config management, shell completions, distribution |
| Extension | `/godmode:extension` | Browser Extensions — Manifest V3, content scripts, background workers, cross-browser compatibility, store submission, security |

### Web3 — Blockchain & Web3 Development

The `web3` skill covers the full lifecycle of blockchain development from smart contract architecture to mainnet deployment. It supports Solidity (Hardhat/Foundry) and Rust/Anchor (Solana) with deep security auditing.

**Core workflow:**
1. Assess project requirements (chain, language, contract type, upgradeability)
2. Set up smart contract architecture with proper project structure
3. Implement token standards (ERC-20, ERC-721, ERC-1155) with security-first approach
4. Conduct security audit against critical vulnerabilities (reentrancy, access control, oracle manipulation, flash loans, DoS, front-running)
5. Optimize gas consumption (storage packing, calldata, custom errors, unchecked blocks)
6. Design DApp architecture with wallet integration (wagmi, RainbowKit, WalletConnect)
7. Deploy with testnet rehearsal, source verification, multisig transfer, and monitoring

**Key principles:**
- Security is non-negotiable — every contract handles real value
- Audit before deploy — internal minimum, external for significant value
- Gas costs are user costs — measure and optimize every public function
- Events are the indexing API — emit for every state change
- Pin Solidity versions — no floating pragma in production

### IoT — IoT & Embedded Systems

The `iot` skill handles firmware development for constrained devices, from architecture design through fleet-scale deployment. It covers RTOS and bare-metal approaches with production-grade communication and update systems.

**Core workflow:**
1. Assess hardware and connectivity requirements (MCU, RTOS, protocols, power budget)
2. Design firmware architecture (RTOS task model with queues/events, or bare-metal super-loop)
3. Configure communication protocols (MQTT topic hierarchy and QoS, CoAP resource design, BLE GATT services)
4. Implement OTA update system (A/B partitioning, signed firmware, automatic rollback)
5. Optimize power consumption (sleep modes, duty cycling, peripheral gating, battery estimation)
6. Design fleet management (provisioning, device shadow/twin, monitoring, staged rollout)

**Key principles:**
- Memory is scarce — static allocation, no malloc in production
- Power determines product viability — measure from day one
- OTA is not optional — devices without it become permanent liabilities
- Security is hardware-rooted — secure boot, hardware crypto, mTLS
- Connectivity will fail — buffer locally, retry with backoff, never block on network

### Desktop — Desktop Application Development

The `desktop` skill builds production-ready desktop applications for Windows, macOS, and Linux. It covers framework selection, auto-update, native integration, code signing, and distribution.

**Core workflow:**
1. Assess project requirements and select framework (Electron, Tauri, Qt)
2. Set up framework architecture with proper process isolation and security
3. Configure auto-update mechanism (electron-updater, Tauri updater, Sparkle)
4. Set up cross-platform build pipeline with CI/CD
5. Integrate native APIs (system tray, file system, notifications, shortcuts, protocol handlers)
6. Configure code signing (Windows Authenticode, macOS notarization) and create installers
7. Establish distribution channels (direct download, app stores, package managers)

**Key principles:**
- Platform conventions matter — respect each OS's idioms
- Code signing is mandatory — unsigned apps trigger scary warnings
- Auto-update is expected — implement from day one
- Test on all target platforms — rendering and behavior vary significantly
- Bundle size impacts perception — choose the right framework for the complexity

### CLI — CLI Tool Development

The `cli` skill creates professional command-line tools with excellent UX, from argument parsing through package manager distribution. It supports all major CLI ecosystems.

**Core workflow:**
1. Assess project requirements (language, complexity, distribution targets)
2. Set up CLI architecture with chosen parser (Commander, Clap, Cobra, Click)
3. Design argument interface (commands, subcommands, flags, positional args, standard flags)
4. Implement interactive features (prompts, progress bars, spinners, tables, TUI)
5. Configure management (TOML/YAML config files, env vars, XDG compliance, precedence chain)
6. Generate shell completions (bash, zsh, fish, PowerShell)
7. Set up distribution (npm, Homebrew, cargo, pip/pipx, GitHub Releases, Docker)

**Key principles:**
- Error messages are UX — show what went wrong, why, and how to fix it
- Defaults should be safe — destructive commands require confirmation
- Machine-readable output is a feature — always support --json
- Shell completions are expected — generate for all major shells
- Exit codes are meaningful — 0 success, 1 error, 2 usage error
- Respect the terminal — check TTY before colors, support NO_COLOR

### Extension — Browser Extension Development

The `extension` skill builds browser extensions with Manifest V3 for Chrome, Firefox, and Safari. It covers the full extension lifecycle from architecture through store submission.

**Core workflow:**
1. Assess extension requirements (browsers, type, UI surfaces, permissions)
2. Set up MV3 architecture (service worker, content scripts, popup, options, side panel)
3. Implement messaging patterns (typed messages, long-lived connections, external messaging)
4. Handle cross-browser compatibility (polyfills, feature detection, manifest patches)
5. Conduct security audit (permission minimization, CSP, input validation, no eval)
6. Prepare store submissions (Chrome Web Store, Firefox Add-ons, Safari Extensions via Xcode)

**Key principles:**
- Manifest V3 is mandatory — Chrome requires it for all new extensions
- Permissions are trust — request the minimum set, use optional permissions
- Service workers are ephemeral — never rely on in-memory state
- Content scripts are guests — namespace everything, use Shadow DOM
- Store reviews are gatekeepers — follow guidelines before submission

### Guiding Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Platform expertise over generic advice | Each skill provides deep, platform-specific guidance rather than surface-level recommendations |
| 2 | Security is non-negotiable | Smart contract audits, firmware signing, extension CSP, code signing — security is baked into every workflow |
| 3 | Distribution is part of the product | From gas deployment to app stores to package managers — the skill guides you through getting your software to users |
| 4 | Test on the real target | Real hardware for IoT, real browsers for extensions, real OS for desktop — simulators miss critical issues |
| 5 | Standards compliance | ERC token standards, Manifest V3, XDG paths, semver — follow established standards rather than inventing custom approaches |
| 6 | Power users are first-class | Gas optimization, power budgets, shell completions, keyboard shortcuts — expert-level features are not afterthoughts |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/web3/SKILL.md` | Skill | Blockchain & Web3 development workflow |
| `skills/iot/SKILL.md` | Skill | IoT & Embedded Systems development workflow |
| `skills/desktop/SKILL.md` | Skill | Desktop Application development workflow |
| `skills/cli/SKILL.md` | Skill | CLI Tool development workflow |
| `skills/extension/SKILL.md` | Skill | Browser Extension development workflow |
| `commands/godmode/web3.md` | Command | Usage reference for `/godmode:web3` |
| `commands/godmode/iot.md` | Command | Usage reference for `/godmode:iot` |
| `commands/godmode/desktop.md` | Command | Usage reference for `/godmode:desktop` |
| `commands/godmode/cli.md` | Command | Usage reference for `/godmode:cli` |
| `commands/godmode/extension.md` | Command | Usage reference for `/godmode:extension` |

**Iterations 298-307 (10 files, 5 skills, 5 commands)**

---

## 89. Concurrency, Distribution & Scale Skills

Concurrency, distribution, and scale skills bring systems engineering capabilities to Godmode. These four skills cover the full spectrum of building and operating high-performance, fault-tolerant distributed systems.

### Skills Overview

| Skill | Command | Purpose |
|-------|---------|---------|
| Concurrent | `/godmode:concurrent` | Concurrency & Parallelism -- thread safety, race detection, async patterns, actor model, deadlocks |
| Distributed | `/godmode:distributed` | Distributed Systems Design -- CAP theorem, consensus (Raft, Paxos), distributed locks, sharding, consistency |
| Scale | `/godmode:scale` | Scalability Engineering -- auto-scaling, read replicas, connection pooling, rate limiting, capacity planning |
| Reliability | `/godmode:reliability` | Site Reliability Engineering -- SLOs, error budgets, toil elimination, on-call, runbooks, incident management |

### Concurrent -- Concurrency & Parallelism

The `concurrent` skill ensures safe, correct concurrent code across languages and runtimes.

**Core workflow:**
1. Assess concurrency context (language, runtime, workload profile)
2. Inventory all shared mutable state and classify access patterns
3. Detect race conditions (check-then-act, read-modify-write, TOCTOU)
4. Design async/await patterns for the target runtime (Node.js, Python, Go, Rust)
5. Recommend lock-free data structures when locks are measured bottlenecks
6. Design actor systems with supervision trees (Erlang/OTP, Akka)
7. Prevent deadlocks through lock ordering, timeouts, and resource hierarchies
8. Create concurrent testing strategies (race detectors, stress tests, property tests)

**Key principles:**
- Identify shared mutable state before writing concurrent code
- Prefer message passing over shared state
- Always run the race detector -- no exceptions
- Lock ordering prevents deadlocks -- document the order
- Test concurrency with stress and chaos, not single runs
- Every concurrent operation must support cancellation

### Distributed -- Distributed Systems Design

The `distributed` skill designs correct distributed architectures with explicit trade-off analysis.

**Core workflow:**
1. Assess distributed system context (topology, consistency needs, data model)
2. Analyze CAP theorem trade-offs and PACELC classification
3. Select consensus protocols (Raft for most systems, Paxos for leaderless)
4. Design distributed locking (Redlock for efficiency, ZooKeeper/etcd for correctness)
5. Plan sharding with consistent hashing or range partitioning
6. Implement eventual consistency patterns (CRDTs, vector clocks, read repair)
7. Configure leader election with fencing tokens for split-brain prevention
8. Design network partition handling and post-partition reconciliation

**Key principles:**
- CAP is the first conversation -- consistency vs availability during partitions
- Consistency is per-operation, not per-system
- Network partitions are inevitable -- design for them
- Fencing tokens prevent split-brain data corruption
- Prefer Raft over Paxos for new systems (simpler, equally correct)
- Test with real partitions using chaos engineering

### Scale -- Scalability Engineering

The `scale` skill designs systems that handle growth efficiently and cost-effectively.

**Core workflow:**
1. Assess current capacity and identify bottlenecks (CPU, memory, I/O, database)
2. Analyze horizontal vs vertical scaling trade-offs per component
3. Configure auto-scaling (AWS ASG, Kubernetes HPA, KEDA)
4. Design database read replicas with write splitting and lag monitoring
5. Optimize connection pooling at all layers (PgBouncer, RDS Proxy)
6. Implement rate limiting (token bucket) and backpressure patterns
7. Create capacity planning projections with runway dates
8. Design caching layers with invalidation strategies

**Key principles:**
- Measure before scaling -- profile the bottleneck first
- Stateless application tier is a prerequisite for horizontal scaling
- Connection pools are often the hidden bottleneck
- Rate limiting is protection, not punishment
- Capacity planning is continuous -- review quarterly
- Load test at 2x projected peak before relying on the plan

### Reliability -- Site Reliability Engineering

The `reliability` skill implements SRE practices that balance velocity with production stability.

**Core workflow:**
1. Assess service reliability context and business criticality
2. Define SLOs with measurable SLIs (availability, latency, correctness)
3. Calculate error budgets and establish budget policies
4. Configure multi-window burn rate alerts (critical through low severity)
5. Inventory toil and create elimination plan (target: < 50% of team time)
6. Design sustainable on-call rotations with escalation and health metrics
7. Create runbooks for every pageable alert with automation levels
8. Establish incident management process with blameless post-mortems
9. Run production readiness review checklist
10. Assess operational maturity and set improvement targets

**Key principles:**
- SLOs drive every reliability decision
- Error budgets balance velocity and reliability
- Toil is the enemy of engineering -- track and eliminate it
- On-call must be sustainable -- measure health metrics
- Runbooks are mandatory for every pageable alert
- Incidents are learning opportunities -- blameless post-mortems

### Workflow Integration

The Concurrency, Distribution & Scale skills integrate with the existing Godmode workflow:

```
/godmode:plan        -> Design the feature
/godmode:build       -> Implement with TDD
/godmode:concurrent  -> Ensure thread safety and correct concurrency
/godmode:distributed -> Design distributed architecture
/godmode:scale       -> Plan capacity and auto-scaling
/godmode:reliability -> Define SLOs and operational practices
/godmode:chaos       -> Validate fault tolerance
/godmode:loadtest    -> Verify performance at scale
/godmode:observe     -> Monitor SLIs and error budgets
/godmode:ship        -> Ship to production
```

### Design Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Safety before speed | Thread safety analysis before concurrent code |
| 2 | Explicit trade-offs | CAP theorem and consistency level per operation |
| 3 | Measure before scaling | Profile bottlenecks, do not guess |
| 4 | SLOs drive reliability | Error budgets determine velocity vs stability |
| 5 | Automate operations | Runbooks and toil elimination reduce human error |
| 6 | Test at the edges | Chaos testing, stress testing, partition testing |
| 7 | Document decisions | Every architectural choice has written rationale |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/concurrent/SKILL.md` | Skill | Concurrency & Parallelism workflow |
| `skills/distributed/SKILL.md` | Skill | Distributed Systems Design workflow |
| `skills/scale/SKILL.md` | Skill | Scalability Engineering workflow |
| `skills/reliability/SKILL.md` | Skill | Site Reliability Engineering workflow |
| `commands/godmode/concurrent.md` | Command | Usage reference for `/godmode:concurrent` |
| `commands/godmode/distributed.md` | Command | Usage reference for `/godmode:distributed` |
| `commands/godmode/scale.md` | Command | Usage reference for `/godmode:scale` |
| `commands/godmode/reliability.md` | Command | Usage reference for `/godmode:reliability` |

**Iterations 318-325 (8 files, 4 skills, 4 commands)**

## 94. Framework-Specific Skills

Four framework-specific skills providing deep architectural guidance for the most common web development stacks.

### 94.1 Next.js Mastery (`/godmode:nextjs`)

Complete Next.js development skill covering:

- **App Router Architecture** — layouts, loading states, error boundaries, route groups, parallel routes, intercepting routes
- **Server vs Client Components** — decision tree for component boundaries, composition patterns, provider patterns
- **Data Fetching** — Server Component fetches, Server Actions for mutations, revalidation strategies (time-based, on-demand, cache tags), parallel fetching with Suspense streaming
- **Middleware** — auth redirects, A/B testing, geo routing, bot detection; matcher configuration; Edge runtime constraints
- **Rendering Strategy Selection** — SSG, ISR, SSR, Streaming SSR, and client-side fetching; decision flow per route
- **Asset Optimization** — next/image (priority, sizes, fill, blur placeholder), next/font (self-hosted, CSS variables, zero layout shift), next/script (strategy selection)
- **Route Handlers** — CRUD handlers, dynamic routes, streaming responses, webhook handlers
- **16-point best practices audit** with PASS/NEEDS REVISION verdict

Flags: `--audit`, `--migrate`, `--routes`, `--data`, `--optimize`, `--middleware`, `--api`, `--deploy <target>`

### 94.2 React Architecture (`/godmode:react`)

Complete React development skill covering:

- **Component Architecture** — composition patterns, slot pattern, custom hooks, render props, HOCs; component hierarchy (pages, features, UI components, primitives)
- **State Management Selection** — decision tree mapping state categories to tools: TanStack Query (server), URL params (URL), React Hook Form (form), useState (local), Zustand/Jotai (shared), Redux Toolkit (complex global); comparison matrix
- **Performance Optimization** — React.memo, useMemo, useCallback (with measurement-first approach), code splitting with lazy/Suspense, virtualization with @tanstack/react-virtual, Suspense for data fetching
- **Server Components & Concurrent Features** — RSC patterns, useTransition, useDeferredValue, useOptimistic, use() hook
- **Testing with React Testing Library** — query priority (getByRole first), userEvent over fireEvent, MSW for network mocking, hook testing with renderHook, provider wrappers
- **15-point architecture audit** with PASS/NEEDS REVISION verdict

Flags: `--audit`, `--state`, `--perf`, `--test`, `--hooks`, `--migrate <from>`, `--patterns`, `--rsc`

### 94.3 Node.js Backend (`/godmode:node`)

Complete Node.js backend development skill covering:

- **Framework Selection** — Express (ecosystem), Fastify (performance), Hono (edge/multi-runtime), NestJS (enterprise DI); comparison matrix with RPS benchmarks
- **Application Architecture** — layered architecture (controllers, services, repositories), NestJS module architecture, layer dependency rules
- **Middleware Design** — request pipeline ordering, composable middleware, Fastify hooks, Hono middleware, NestJS guards/interceptors/pipes, global error handling
- **Stream Processing** — file upload streaming, CSV parsing with Transform streams, database streaming for large exports, async iterables, pipeline() for error handling
- **Worker Threads & Cluster Mode** — worker pool implementation, CPU-bound task offloading, cluster mode for multi-core scaling, BullMQ for background jobs; decision matrix
- **Memory Management & Event Loop** — heap snapshot analysis, LRU cache bounds, event listener cleanup, closure leak prevention, GC tuning, event loop lag monitoring, batch processing
- **Production Hardening** — graceful shutdown template, health checks, structured logging, unhandled rejection/exception handlers, connection pooling, timeouts
- **16-point production checklist** with PASS/NEEDS REVISION verdict

Flags: `--audit`, `--framework <name>`, `--middleware`, `--streams`, `--workers`, `--perf`, `--production`, `--migrate <from> <to>`

### 94.4 Django & FastAPI (`/godmode:django`)

Complete Python web development skill covering:

- **Django Project Structure** — settings split by environment, app architecture, service layer pattern, selectors for complex reads, Factory Boy for testing
- **Django REST Framework** — ModelSerializer patterns (separate create/read serializers), ViewSets with custom actions, router configuration, custom permissions, pagination, throttling, exception handlers
- **FastAPI Architecture** — Pydantic models for validation (BaseModel inheritance, optional updates), dependency injection (composable deps for auth, roles, pagination, database sessions), async routers
- **Async Django & ASGI** — ASGI configuration, async views, async ORM operations (Django 4.1+), Channels for WebSocket, Uvicorn with Gunicorn workers
- **Admin Customization** — list_display with custom methods, fieldsets, inlines, custom actions (export CSV, bulk status), query optimization in admin, custom admin site
- **Database Optimization** — N+1 prevention (select_related, prefetch_related, Prefetch objects), annotations over Python computation, bulk operations, partial indexes, raw SQL as last resort
- **16-point architecture audit** with PASS/NEEDS REVISION verdict

Flags: `--audit`, `--django`, `--fastapi`, `--drf`, `--admin`, `--async`, `--orm`, `--migrate`, `--deploy <target>`

### 94.5 Cross-References

```
/godmode:nextjs ──→ /godmode:react       (React architecture within Next.js)
/godmode:nextjs ──→ /godmode:deploy      (Vercel, Docker, standalone deployment)
/godmode:nextjs ──→ /godmode:perf        (Core Web Vitals optimization)
/godmode:react  ──→ /godmode:nextjs      (Next.js when SSR/SSG needed)
/godmode:react  ──→ /godmode:a11y        (accessibility audit)
/godmode:react  ──→ /godmode:test        (comprehensive test suites)
/godmode:node   ──→ /godmode:api         (API specification and documentation)
/godmode:node   ──→ /godmode:deploy      (Docker, PM2, Kubernetes deployment)
/godmode:node   ──→ /godmode:observe     (logging, metrics, tracing)
/godmode:django ──→ /godmode:api         (OpenAPI spec generation)
/godmode:django ──→ /godmode:deploy      (Gunicorn, Docker deployment)
/godmode:django ──→ /godmode:migrate     (database migration strategy)
```

**Full-Stack Chains:**
```
/godmode:nextjs → /godmode:react → /godmode:node → /godmode:api → /godmode:test → /godmode:deploy
/godmode:django → /godmode:api → /godmode:test → /godmode:deploy
```

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/nextjs/SKILL.md` | Skill | Next.js mastery with App Router, Server Components, data fetching, optimization |
| `skills/react/SKILL.md` | Skill | React architecture with composition, state management, performance, testing |
| `skills/node/SKILL.md` | Skill | Node.js backend with Express/Fastify/Hono/NestJS, streams, workers, production |
| `skills/django/SKILL.md` | Skill | Django/FastAPI with DRF, Pydantic, async, admin, ORM optimization |
| `commands/godmode/nextjs.md` | Command | Usage reference for `/godmode:nextjs` |
| `commands/godmode/react.md` | Command | Usage reference for `/godmode:react` |
| `commands/godmode/node.md` | Command | Usage reference for `/godmode:node` |
| `commands/godmode/django.md` | Command | Usage reference for `/godmode:django` |

**Iterations 381-388 (4 skills created, 4 command files created, 1 design doc updated)**

---

## 97. Backend Framework Skills

Four framework-specific mastery skills that provide deep, opinionated guidance for the most popular backend frameworks — covering architecture, ORM patterns, authentication, testing, and production configuration.

### 97.1 Spring — Spring Boot Mastery (`skills/spring/SKILL.md`)

**Purpose:** Build production-grade Spring Boot applications with auto-configuration best practices, Spring Security, Spring Data JPA, Actuator monitoring, and Spring Cloud microservices.

**Key capabilities:**
- **Starter selection:** Matches project requirements to the correct Spring Boot starters with version-managed BOM dependencies.
- **Auto-configuration audit:** Enforces critical production settings — OSIV disabled, `ddl-auto: validate`, graceful shutdown, HikariCP pool tuning, actuator endpoint restriction, and 12-factor externalized config.
- **Spring Security:** Component-based `SecurityFilterChain` with deny-by-default, JWT/OAuth2 resource server, method-level security, CORS, and security event auditing.
- **Spring Data JPA:** Entity design with lazy fetching, JOIN FETCH for N+1 prevention, optimistic locking, Specifications for dynamic queries, projections for lightweight reads, and Flyway migrations.
- **Actuator & monitoring:** Health probes for Kubernetes (liveness/readiness), custom health indicators, Micrometer metrics with Prometheus endpoint, and custom business metrics.
- **Spring Cloud:** API Gateway, service discovery (Eureka/Consul), Resilience4j circuit breakers, distributed tracing, and event-driven communication patterns.
- **Testing:** Unit tests with Mockito, controller tests with MockMvc, integration tests with TestContainers, security testing with `SecurityMockMvcConfigurers`, and ArchUnit for architecture rules.

**Workflow:** Assess requirements -> Select starters -> Configure properties -> Security setup -> Data layer -> Actuator -> Spring Cloud (if microservices) -> Testing -> Validation (15 checks).

**Command:** `/godmode:spring` (`commands/godmode/spring.md`)

### 97.2 Rails — Ruby on Rails Mastery (`skills/rails/SKILL.md`)

**Purpose:** Build production-grade Rails applications following the Rails Way — ActiveRecord patterns, Hotwire for modern interactivity, background jobs, and comprehensive RSpec testing.

**Key capabilities:**
- **Rails conventions:** Enforces naming, structure, RESTful routes, and project organization including service objects, query objects, and concerns.
- **ActiveRecord optimization:** Eager loading with `includes`/`preload`/`eager_load`, `strict_loading` for N+1 detection, scopes, counter caches, `find_each` for batch processing, and database indexes on all foreign keys.
- **Hotwire (Turbo + Stimulus):** Turbo Drive for SPA-like navigation, Turbo Frames for partial page updates, Turbo Streams for real-time broadcasts, and Stimulus controllers for JavaScript behavior. Includes decision guide for when to use each.
- **Background jobs:** Solid Queue (Rails 8 default) and Sidekiq configuration with queue priorities, retry policies, idempotency rules, and monitoring.
- **Testing:** RSpec with FactoryBot factories (traits, transients), Shoulda Matchers, request specs, system specs with Capybara, job testing with `have_enqueued_job`, and VCR/WebMock for external APIs.

**Workflow:** Assess requirements -> Architecture decision -> Rails conventions -> ActiveRecord patterns -> Hotwire setup -> Background jobs -> RSpec testing -> Validation (15 checks).

**Command:** `/godmode:rails` (`commands/godmode/rails.md`)

### 97.3 Laravel — Laravel Mastery (`skills/laravel/SKILL.md`)

**Purpose:** Build production-grade Laravel applications with Eloquent ORM mastery, service container patterns, queue-driven architecture, and Pest testing.

**Key capabilities:**
- **Eloquent ORM:** Models with relationships, scopes, PHP 8.1+ backed enum casts, accessor/mutator syntax, API Resources for response shaping, eager loading with `preventLazyLoading()`, and query optimization patterns (`withWhereHas`, `chunkById`, `cursor`).
- **Service container:** Contracts (interfaces) bound in service providers, Action classes for single-responsibility operations, DTOs for typed data transfer, and pipeline pattern for sequential processing.
- **Queue system:** Jobs with retry policies and exponential backoff, `WithoutOverlapping` and `ShouldBeUnique` middleware, events with queued listeners, broadcasting via Laravel Reverb for real-time, and multi-queue priority management.
- **Authentication:** Sanctum for SPA + mobile token auth, Passport for full OAuth2, Policies for model-level authorization, Gates for non-model actions, and token abilities for fine-grained API permissions.
- **Testing:** Pest with expressive syntax, factory states and `afterCreating` hooks, fake facades (`Queue::fake()`, `Event::fake()`, `Mail::fake()`), `Sanctum::actingAs()` for auth, and `assertDatabaseHas` for persistence verification.

**Workflow:** Assess requirements -> Architecture decision -> Eloquent models -> Service container -> Queue + events -> Authentication -> Pest testing -> Validation (15 checks).

**Command:** `/godmode:laravel` (`commands/godmode/laravel.md`)

### 97.4 FastAPI — FastAPI Mastery (`skills/fastapi/SKILL.md`)

**Purpose:** Build production-grade FastAPI applications with Pydantic schemas, async-first architecture, dependency injection, and pytest/HTTPX testing.

**Key capabilities:**
- **Pydantic model design:** Separate Create/Update/Response schemas, field validators and model validators, generic `PaginatedResponse[T]`, discriminated unions, `from_attributes=True` for ORM conversion, and Python 3.12+ type syntax.
- **Dependency injection:** `Annotated` type aliases for clean signatures, yield dependencies for resource lifecycle, nested dependency chains, parameterized dependencies for role-based access, and `dependency_overrides` for testing.
- **Async database access:** SQLAlchemy 2.0 with asyncpg driver, `Mapped[]` type annotations, `selectin` loading for async-safe eager loading, repository pattern for query encapsulation, and Alembic async migrations.
- **Background tasks & WebSockets:** FastAPI `BackgroundTasks` for simple fire-and-forget, Celery/ARQ for complex workflows, `ConnectionManager` for WebSocket channel management, and Redis Pub/Sub for multi-process broadcasting.
- **Testing:** pytest with HTTPX `AsyncClient` and `ASGITransport` (no server needed), async fixtures with transaction rollback, `dependency_overrides` for dependency swapping, Pydantic schema validation tests, and `respx` for mocking external HTTP.

**Workflow:** Assess requirements -> Project structure -> Pydantic schemas -> Dependency injection -> Async database -> Background tasks/WebSockets -> pytest/HTTPX testing -> Validation (15 checks).

**Command:** `/godmode:fastapi` (`commands/godmode/fastapi.md`)

### Integration with Existing Skills

```
/godmode:spring   ->  /godmode:test  ->  /godmode:secure  ->  /godmode:deploy
/godmode:rails    ->  /godmode:test  ->  /godmode:optimize ->  /godmode:ship
/godmode:laravel  ->  /godmode:test  ->  /godmode:observe  ->  /godmode:deploy
/godmode:fastapi  ->  /godmode:test  ->  /godmode:loadtest ->  /godmode:deploy
     |                     |                    |                     |
  Framework-specific    Add coverage      Production checks      Ship it
  best practices        and edge cases    and monitoring
```

- **From `/godmode:scaffold`:** After scaffolding a project, invoke the framework skill for production-grade configuration.
- **From `/godmode:api`:** After designing the API spec, invoke the framework skill to implement it with framework-specific best practices.
- **From framework skill to `/godmode:secure`:** Framework skill configures auth; security skill audits it for vulnerabilities.
- **From framework skill to `/godmode:loadtest`:** Framework skill builds the service; load test validates it handles production traffic.
- **From framework skill to `/godmode:optimize`:** Framework skill establishes patterns; optimize skill tunes queries, caching, and throughput.

### Design Principles for Backend Framework Skills

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Convention over configuration | Each framework has a "right way" — follow it, document deviations |
| 2 | Production from day one | Every setting is production-grade; dev convenience is a profile, not a default |
| 3 | ORM discipline | Eager loading, N+1 prevention, and query optimization are non-negotiable |
| 4 | Security is structural | Authentication and authorization are framework features, not afterthoughts |
| 5 | Test at every layer | Unit, integration, and end-to-end tests use framework-specific tooling |
| 6 | Async when async | FastAPI is async-first; Spring offers reactive; Rails and Laravel are request-per-thread — respect each model |
| 7 | Framework-specific tooling | Use MockMvc not generic HTTP clients; use FactoryBot not raw SQL; use Pest not generic PHPUnit |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/spring/SKILL.md` | Skill | Spring Boot mastery — auto-config, Security, JPA, Actuator, Cloud, TestContainers |
| `skills/rails/SKILL.md` | Skill | Ruby on Rails mastery — ActiveRecord, Hotwire, Sidekiq/Solid Queue, RSpec |
| `skills/laravel/SKILL.md` | Skill | Laravel mastery — Eloquent, service container, queues, events, Sanctum, Pest |
| `skills/fastapi/SKILL.md` | Skill | FastAPI mastery — Pydantic, DI, async SQLAlchemy, WebSockets, pytest/HTTPX |
| `commands/godmode/spring.md` | Command | Usage reference for `/godmode:spring` |
| `commands/godmode/rails.md` | Command | Usage reference for `/godmode:rails` |
| `commands/godmode/laravel.md` | Command | Usage reference for `/godmode:laravel` |
| `commands/godmode/fastapi.md` | Command | Usage reference for `/godmode:fastapi` |

**Iterations 403-410 (8 files, 4 skills, 4 commands)**

---

## 99. Developer Tooling Skills

### Overview
Skills for mastering the developer tooling ecosystem: containerization, terminal productivity, IDE configuration, and package management. This category focuses on the tools and environments developers use daily, optimizing workflows and eliminating friction from development to deployment.

### Skills in this Category

#### `/godmode:docker` — Docker Mastery
**Purpose:** Create, optimize, and secure Docker configurations for containerized applications.

**Core capabilities:**
- **Dockerfile best practices:** Multi-stage builds with proper layer caching, language-specific patterns for Node.js, Python, Go, Rust, Java, and .NET
- **Docker Compose:** Local development environments with health checks, volume management, service dependencies, and profile-based optional services
- **Image size optimization:** Base image selection (Alpine, distroless, scratch), .dockerignore, layer reduction, dependency pruning — targeting 50-90% size reduction
- **Security scanning:** Trivy, Snyk, Docker Scout, and Grype integration with CI pipeline. Non-root users, capability dropping, read-only filesystems, secret mount handling
- **Networking and volumes:** Bridge, overlay, and macvlan networks. Named volumes, bind mounts, tmpfs for secrets, backup strategies
- **BuildKit features:** Cache mounts for fast rebuilds, secret mounts for secure builds, heredocs, multi-platform builds with buildx

**Invocation:** `/godmode:docker`, "Dockerfile", "docker compose", "container image", "multi-stage build", "image size", "docker security"

**Output:** Dockerfile, docker-compose.yml, .dockerignore with commit `"build(docker): Dockerfile — multi-stage <language> with <base image>"`

**Flags:** `--init`, `--optimize`, `--compose`, `--security`, `--scan`, `--slim`, `--buildkit`, `--multi-platform`, `--ci`, `--audit`

#### `/godmode:terminal` — Terminal & Shell Productivity
**Purpose:** Optimize command-line workflows with shell scripting best practices, dotfile management, multiplexers, and modern CLI tools.

**Core capabilities:**
- **Shell scripting:** Strict mode (set -euo pipefail), proper quoting, argument parsing, error handling, trap-based cleanup, ShellCheck linting
- **Dotfile management:** Git bare repo, GNU Stow, chezmoi, and yadm strategies for portable, version-controlled configurations
- **Terminal multiplexers:** tmux configuration with vim-style navigation, development layout scripts, session management
- **Aliases and functions:** Git aliases, modern tool aliases, utility functions (mkcd, extract, killport, fzf-powered branch switching and file opening)
- **Modern CLI tools:** fd (find), ripgrep (grep), bat (cat), eza (ls), delta (diff), zoxide (cd), fzf (fuzzy finder), jq/yq (JSON/YAML), starship (prompt)

**Invocation:** `/godmode:terminal`, "shell script", "bash script", "dotfiles", "tmux", "terminal setup", "CLI tools", "shell alias"

**Output:** Shell configuration files, tmux config, shell scripts with commit `"config: shell — <N aliases, N functions, dotfile management>"`

**Flags:** `--shell`, `--dotfiles`, `--tmux`, `--aliases`, `--tools`, `--script <name>`, `--audit`, `--fzf`, `--prompt`, `--completions`

#### `/godmode:vscode` — IDE & Editor Configuration
**Purpose:** Configure VS Code, Neovim, and JetBrains IDEs for maximum productivity with project-specific settings, debugging, and extensions.

**Core capabilities:**
- **VS Code settings:** Performance optimization, formatting on save, file exclusions, search configuration, language-specific overrides
- **Extension recommendations:** Curated extension sets by project type (TypeScript, React, Python, Go, Rust, Docker/DevOps) with workspace-level recommendations
- **Debug configurations:** Launch.json templates for Node.js, Next.js, Python/Django, Go, Jest, pytest with compound (full-stack) configurations
- **Tasks and automation:** Build, test, lint, type-check, Docker tasks with keyboard shortcuts and problem matchers
- **Workspace management:** Multi-root workspaces for monorepos, settings precedence, shared vs personal configuration
- **Cross-editor support:** Neovim (lazy.nvim, LSP, treesitter, telescope), JetBrains optimization, .editorconfig for universal formatting

**Invocation:** `/godmode:vscode`, "VS Code settings", "editor config", "debug configuration", "launch.json", "IDE setup", "extensions", "Neovim config"

**Output:** .vscode/ directory (settings, launch, tasks, extensions), .editorconfig with commit `"config(ide): VS Code — settings, debug, tasks, extensions"`

**Flags:** `--settings`, `--extensions`, `--debug`, `--tasks`, `--workspace`, `--neovim`, `--jetbrains`, `--editorconfig`, `--snippets`, `--keybindings`, `--performance`

#### `/godmode:npm` — Package Management
**Purpose:** Manage JavaScript/TypeScript dependencies with the right package manager, secure lock files, workspace configuration, and vulnerability remediation.

**Core capabilities:**
- **Package manager selection:** Detailed comparison of npm, yarn, pnpm, and bun with recommendation matrix by project type (application, library, monorepo, CLI)
- **Lock file management:** Commit strategy, CI frozen installs, conflict resolution, regeneration. Rules for never mixing lock files
- **Workspace/monorepo configuration:** pnpm workspaces, Turborepo task orchestration, workspace protocol for internal references, shared dependency management
- **Package publishing:** Dual ESM/CJS exports, TypeScript declarations, semver versioning, dry-run verification, automated publishing with changesets
- **Security auditing:** npm audit with severity-based action plans, override strategies for transitive vulnerabilities, supply chain security with provenance
- **Version resolution:** Peer dependency conflict resolution, deduplication, dependency tree analysis, maintenance routines (weekly, monthly, quarterly)

**Invocation:** `/godmode:npm`, "npm install", "package manager", "lock file", "monorepo workspace", "publish package", "npm audit", "dependency conflict"

**Output:** Package manager configuration, workspace setup, audit report with commit `"deps: <add|update|remove> <package> — <reason>"`

**Flags:** `--audit`, `--outdated`, `--dedupe`, `--workspace`, `--publish`, `--migrate <to>`, `--compare`, `--cleanup`, `--lockfix`, `--overrides`, `--ci`

### Skill Interactions
| From | To | When |
|------|----|------|
| `/godmode:docker` | `/godmode:k8s` | Container ready for orchestration |
| `/godmode:docker` | `/godmode:deploy` | Image ready for deployment |
| `/godmode:docker` | `/godmode:secure` | Security scan finds vulnerabilities |
| `/godmode:terminal` | `/godmode:vscode` | Shell configured, optimize IDE next |
| `/godmode:terminal` | `/godmode:setup` | Terminal part of project setup |
| `/godmode:vscode` | `/godmode:build` | IDE configured, start coding |
| `/godmode:vscode` | `/godmode:terminal` | IDE configured, optimize shell next |
| `/godmode:npm` | `/godmode:build` | Dependencies configured, start coding |
| `/godmode:npm` | `/godmode:secure` | Audit finds vulnerabilities |
| `/godmode:npm` | `/godmode:monorepo` | Workspace setup feeds monorepo config |
| `/godmode:setup` | `/godmode:docker` | Project setup includes containerization |
| `/godmode:setup` | `/godmode:terminal` | Project setup includes shell config |
| `/godmode:setup` | `/godmode:vscode` | Project setup includes IDE config |
| `/godmode:setup` | `/godmode:npm` | Project setup includes dependency management |

### Design Principles
1. **Tools should be invisible** — The best tooling configuration is one you never think about. Format on save, lint on commit, build on push.
2. **Reproducibility is paramount** — Lock files, pinned versions, committed configurations. Every developer gets the same experience.
3. **Security is continuous** — Dependency auditing and container scanning are not one-time tasks. They run in CI on every commit.
4. **Start with defaults, optimize later** — Get a working setup first. Tune performance, add advanced features, and customize after the project is running.
5. **Share team configurations** — .vscode/, .editorconfig, Dockerfile, docker-compose.yml, and workspace configs belong in version control.

### Developer Tooling Chains

**New Project Setup:**
```
/godmode:npm --> /godmode:vscode --> /godmode:docker --> /godmode:terminal
```

**Containerization Pipeline:**
```
/godmode:docker --init --> /godmode:docker --security --> /godmode:k8s
```

**Full Environment Setup:**
```
/godmode:terminal --tools --> /godmode:vscode --settings --> /godmode:npm --workspace --> /godmode:docker --compose
```

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/docker/SKILL.md` | Skill | Docker mastery workflow |
| `skills/terminal/SKILL.md` | Skill | Terminal and shell productivity workflow |
| `skills/vscode/SKILL.md` | Skill | IDE and editor configuration workflow |
| `skills/npm/SKILL.md` | Skill | Package management workflow |
| `commands/godmode/docker.md` | Command | Usage reference for `/godmode:docker` |
| `commands/godmode/terminal.md` | Command | Usage reference for `/godmode:terminal` |
| `commands/godmode/vscode.md` | Command | Usage reference for `/godmode:vscode` |
| `commands/godmode/npm.md` | Command | Usage reference for `/godmode:npm` |

**Iterations 419-426 (8 files, 4 skills, 4 commands)**

---

## 80. Advanced Protocol & Runtime Skills

Four new skills extend Godmode into advanced protocol development and modern runtime environments. These skills address the growing need for high-performance APIs beyond REST, portable computation with WebAssembly, and globally distributed edge computing.

### Skill: `/godmode:graphql` — GraphQL API Development

**Purpose:** Design, build, optimize, and test production-quality GraphQL APIs.

**Capabilities:**
- **Schema design:** SDL-first and code-first approaches with Relay-style pagination, mutation payloads, and proper nullability
- **Resolver architecture:** Thin resolvers delegating to service layer, with clear separation of concerns
- **N+1 detection and DataLoader patterns:** Automatic detection of N+1 queries with batched DataLoader implementations for all relation fields
- **Subscription implementation:** WebSocket and SSE transport with Redis/Kafka/NATS pub/sub backends, connection authentication, and heartbeat management
- **Schema federation:** Apollo Federation v2 with subgraph design, entity references, composition validation, and gateway query planning
- **Performance hardening:** Query complexity analysis, depth limiting, persisted queries, automatic persisted queries (APQ), response caching with @cacheControl, and production allowlisting
- **Testing:** Schema snapshot tests, resolver unit tests, N+1 regression tests, and breaking change detection with graphql-inspector

**Workflow:** Discovery -> Schema Design (SDL or Code-first) -> Resolver Architecture -> N+1 Detection + DataLoaders -> Subscriptions -> Federation -> Performance Hardening -> Testing -> Artifacts

**Flags:** `--sdl`, `--code-first`, `--federation`, `--subscriptions`, `--n+1`, `--perf`, `--test`, `--validate`, `--diff <old> <new>`, `--allowlist`

### Skill: `/godmode:grpc` — gRPC & Protocol Buffers

**Purpose:** Design, build, and optimize gRPC services with production-grade proto file design and code generation.

**Capabilities:**
- **Proto file design:** Proto3 best practices including package naming, enum zero values, field number permanence, FieldMask for partial updates, and idempotency keys
- **Code generation:** buf-based pipeline with linting, breaking change detection, and multi-language generation (Go, TypeScript, Rust, Python, Java)
- **Streaming patterns:** Unary, server-streaming, client-streaming, and bidirectional streaming with flow control, backpressure, and reconnection strategies
- **gRPC-Web:** Browser client access via Envoy proxy, gRPC-Web middleware, or Buf Connect protocol (recommended for new projects)
- **Load balancing:** L7 proxy-based, client-side look-aside, and xDS-based strategies for proper HTTP/2 request distribution
- **Service mesh integration:** Istio, Linkerd, and Consul Connect with per-RPC load balancing, retry policies, circuit breaking, mTLS, and distributed tracing
- **Error handling:** Correct status code usage (16 codes), rich error details with google.rpc.Status, and observability interceptors
- **Testing:** buf lint, buf breaking, grpcurl, ghz load testing, and comprehensive streaming edge case coverage

**Workflow:** Discovery -> Proto File Design -> Proto Best Practices -> Code Generation Pipeline -> Streaming Patterns -> gRPC-Web -> Load Balancing -> Error Handling + Observability -> Testing -> Artifacts

**Flags:** `--proto`, `--generate`, `--streaming`, `--web`, `--mesh`, `--lb`, `--validate`, `--breaking`, `--test`, `--bench`

### Skill: `/godmode:wasm` — WebAssembly Development

**Purpose:** Compile, integrate, optimize, and test WebAssembly modules across browser and server environments.

**Capabilities:**
- **Rust to WASM:** wasm-pack and wasm-bindgen pipeline with release optimizations (LTO, size optimization, panic=abort, wasm-opt)
- **C/C++ to WASM:** Emscripten compilation with memory management, threading, and filesystem configuration
- **Go to WASM:** TinyGo for dramatically smaller binaries (50-500 KB vs 2-10 MB with standard Go)
- **WASI:** WebAssembly System Interface with capability-based security, component model (Preview 2), and WIT interface definitions
- **Browser integration:** Streaming compilation, wasm-bindgen for automatic memory management, Web Workers for non-blocking execution, and bundler configuration (Webpack, Vite, Rollup)
- **Server-side runtimes:** Wasmtime, Wasmer, wazero, and WasmEdge for plugin systems, serverless functions, and embedded computation with sandboxing
- **Performance profiling:** Binary size analysis with twiggy, execution profiling with Chrome DevTools, memory monitoring, and SIMD/threads optimization
- **Testing:** Native unit tests, WASM browser tests (wasm-bindgen-test), integration tests, size regression CI gates, and performance benchmarks

**Workflow:** Discovery -> Compilation Setup -> WASI Configuration -> Browser/Server Integration -> Performance Profiling -> Size Optimization -> Testing -> Artifacts

**Flags:** `--rust`, `--cpp`, `--go`, `--wasi`, `--browser`, `--server`, `--plugin`, `--optimize`, `--profile`, `--test`, `--size`

### Skill: `/godmode:edge` — Edge Computing & Serverless

**Purpose:** Design, build, deploy, and optimize edge functions and serverless applications across global platforms.

**Capabilities:**
- **Edge function design:** Cloudflare Workers (V8 isolates, <1ms cold start), Vercel Edge Functions, Deno Deploy, and Fastly Compute (WASM) with platform-specific constraint awareness
- **Serverless architecture:** AWS Lambda, GCP Cloud Functions, Azure Functions with event-driven patterns, proper IAM, and Infrastructure as Code
- **Cold start optimization:** Bundle size minimization, lazy initialization, provisioned concurrency, runtime selection, SnapStart (Java), and edge runtime migration for latency-critical paths
- **Edge caching:** Cache-first (stale-while-revalidate), network-first (cache fallback), tiered caching (browser + CDN + origin), cache key design, and invalidation strategies (TTL, purge-on-write, versioned URLs)
- **Distributed state:** KV stores for eventually consistent read-heavy data, Durable Objects for strongly consistent coordination, edge SQL (D1/Turso) for relational data, and decision framework for state solution selection
- **Infrastructure as Code:** SAM templates, Serverless Framework, wrangler.toml, and deployment checklists
- **Observability:** Structured logging at edge, key metrics (cold start rate, cache hit rate, cost per invocation), and distributed tracing across edge-to-origin chains
- **Testing:** Local emulators (Miniflare, sam local, vercel dev), unit tests with mocked environments, and chaos testing for origin failure scenarios

**Workflow:** Discovery -> Edge/Serverless Design -> Cold Start Optimization -> Caching Strategy -> Distributed State -> Infrastructure as Code -> Observability -> Testing -> Artifacts

**Flags:** `--cloudflare`, `--vercel`, `--lambda`, `--gcp`, `--deno`, `--cold-start`, `--cache`, `--state`, `--cost`, `--migrate`, `--test`

### Integration with Existing Skills

The protocol and runtime skills integrate into the Godmode workflow:

```
/godmode:think  ->  /godmode:graphql  ->  /godmode:test  ->  /godmode:deploy
     |                   |                      |                    |
  Brainstorm        Design GraphQL          Test resolvers       Deploy with
  the API           schema + resolvers      and N+1 coverage     subscriptions

/godmode:micro  ->  /godmode:grpc  ->  /godmode:deploy  ->  /godmode:observe
     |                   |                   |                     |
  Design             Define proto        Deploy with           Monitor RPC
  microservices      files + streaming   mesh integration      metrics + traces

/godmode:perf  ->  /godmode:wasm  ->  /godmode:edge  ->  /godmode:deploy
     |                   |                 |                    |
  Identify           Compile hot        Deploy WASM to       Ship to
  CPU bottleneck     path to WASM       edge runtime         production
```

- **From `/godmode:api`:** After REST API design, use `/godmode:graphql` or `/godmode:grpc` for alternative protocols
- **From `/godmode:micro`:** Use `/godmode:grpc` for inter-service communication in microservice architectures
- **From `/godmode:perf`:** When performance profiling identifies CPU-bound bottlenecks, use `/godmode:wasm` to offload to WebAssembly
- **From `/godmode:deploy`:** Use `/godmode:edge` for edge deployment strategies and cold start optimization
- **From `/godmode:cache`:** Use `/godmode:edge --cache` for edge-specific caching strategies

### Design Principles

| # | Principle | Implementation |
|---|-----------|---------------|
| 1 | Schema/proto is the contract | GraphQL schemas and proto files are designed before implementation |
| 2 | Performance defenses are mandatory | Every GraphQL API has complexity limits; every gRPC service has health checks |
| 3 | DataLoaders are not optional | Every GraphQL relation field uses a DataLoader — N+1 queries are bugs |
| 4 | L7 load balancing for gRPC | HTTP/2 multiplexing requires application-layer load balancing |
| 5 | Binary size is a feature | WASM binaries have size budgets enforced in CI |
| 6 | Edge for latency, serverless for scale | Choose the right tool based on the actual requirement |
| 7 | State consistency is explicit | Every edge state solution documents its consistency model |
| 8 | Test at every layer | Native + compiled + integrated tests for WASM; local emulators for edge |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/graphql/SKILL.md` | Skill | GraphQL API development workflow |
| `skills/grpc/SKILL.md` | Skill | gRPC and Protocol Buffers workflow |
| `skills/wasm/SKILL.md` | Skill | WebAssembly development workflow |
| `skills/edge/SKILL.md` | Skill | Edge computing and serverless workflow |
| `commands/godmode/graphql.md` | Command | Usage reference for `/godmode:graphql` |
| `commands/godmode/grpc.md` | Command | Usage reference for `/godmode:grpc` |
| `commands/godmode/wasm.md` | Command | Usage reference for `/godmode:wasm` |
| `commands/godmode/edge.md` | Command | Usage reference for `/godmode:edge` |

**Iterations 244-251 (8 files, 4 skills, 4 commands)**

---

## 98. Advanced AI Skills

Four new skills extend Godmode's AI/ML capabilities beyond experiment tracking and deployment into fine-tuning, embeddings, production operations, and multimodal processing.

### 98.1 Model Fine-Tuning (`/godmode:finetune`)

**Purpose:** Guide the full lifecycle of fine-tuning LLMs on custom data -- from method selection through deployment.

**Workflow:**
1. **Discovery** -- Goal, base model, hardware constraints, budget, and justification for fine-tuning vs prompting
2. **Method Selection** -- Decision guide across Full FT, LoRA, QLoRA, DoRA, and Prefix Tuning based on model size and available VRAM
3. **Dataset Preparation** -- Format validation (instruction, conversational, DPO), quality checks (duplicates, contradictions, PII), size guidance per task type
4. **Training Configuration** -- Learning rate, scheduler, batch size, epochs, precision, gradient checkpointing, flash attention, packing
5. **Evaluation During Training** -- Validation loss, perplexity, sample generation, catastrophic forgetting detection, early stopping
6. **Post-Training Evaluation** -- Task metrics, comparison vs alternatives (base + prompting, larger model, RAG), safety evaluation
7. **Model Merging & Export** -- Adapter merging (standard, TIES, DARE, SLERP), export to safetensors/GGUF/ONNX/AWQ, model card generation
8. **Deployment** -- Serving on vLLM, Ollama, TGI, SageMaker, or serverless platforms with performance benchmarks

**Key Principle:** Prompting before fine-tuning. Exhaust prompt engineering and few-shot learning first. Fine-tune only when prompting demonstrably cannot achieve the quality bar.

**Chaining:** `/godmode:prompt` (exhaust first) -> `/godmode:finetune` -> `/godmode:eval` -> `/godmode:mlops` (deploy) -> `/godmode:aiops` (monitor)

### 98.2 Embeddings & Semantic Search (`/godmode:embeddings`)

**Purpose:** Build, optimize, and manage embedding pipelines for similarity search, clustering, classification, and retrieval.

**Workflow:**
1. **Discovery** -- Use case, data type, volume, languages, update frequency, quality and cost targets
2. **Model Selection** -- Comparison across OpenAI, Cohere, Voyage, Jina, and open-source models with MTEB scores, latency, cost, and context window
3. **Dimensionality Reduction** -- Matryoshka truncation, PCA, UMAP, quantization with quality retention measurements
4. **Clustering & Analysis** -- K-Means/HDBSCAN clustering, embedding space diagnostics (isotropy, hubness, collapse), visualization
5. **Search Optimization** -- HNSW/IVF index configuration, distance metric selection, pre/post filtering, caching strategies
6. **Hybrid Search** -- Dense + sparse (BM25/SPLADE) with RRF or weighted fusion, reranking with cross-encoder models
7. **Versioning & Refresh** -- Version registry, refresh triggers, incremental and full re-embedding, atomic index swapping with rollback

**Key Principle:** Hybrid search is the default. Pure semantic search misses exact matches. Pure keyword search misses semantic matches. Combine both with reciprocal rank fusion.

**Chaining:** `/godmode:embeddings` -> `/godmode:rag` (build RAG) -> `/godmode:aiops` (monitor quality) -> `/godmode:embeddings --refresh` (re-index when needed)

### 98.3 AI Operations & Safety (`/godmode:aiops`)

**Purpose:** Provide structured operational controls for AI/LLM applications in production -- guardrails, cost optimization, latency optimization, safety testing, and monitoring.

**Workflow:**
1. **Discovery** -- System architecture, traffic, pain points, priority (cost, latency, quality, safety)
2. **Guardrails** -- Input guards (injection detection, PII redaction, topic restriction, rate limiting, jailbreak detection) and output guards (PII filtering, harmful content blocking, hallucination detection, format validation)
3. **Hallucination Management** -- Detection methods (NLI source comparison, self-consistency, confidence calibration, LLM-as-judge) and mitigation strategies (grounding instructions, citations, temperature, chain-of-thought)
4. **Cost Optimization** -- Model routing (cheap model for simple, expensive for complex), prompt compression, response caching, batch processing, fine-tuned smaller models, context window management
5. **Latency Optimization** -- Streaming responses, semantic caching, parallel processing, smaller models, speculative decoding, KV-cache optimization, edge deployment
6. **Safety Testing** -- Red-team framework covering prompt injection, jailbreaking, data extraction, harmful content, bias, DoS, multi-turn manipulation, tool misuse with safety scorecard
7. **Monitoring** -- LLM-specific metrics (token usage, cost per request, hallucination rate, guardrail triggers), quality scoring (LLM-as-judge, NLI, user feedback), tracing, and alerting

**Key Principle:** Guardrails before launch. No AI system goes to production without input and output guardrails. Even internal tools need basic safety controls.

**Chaining:** `/godmode:rag` or `/godmode:agent` -> `/godmode:aiops` (harden) -> `/godmode:secure` (audit) -> `/godmode:observe` (integrate monitoring) -> `/godmode:deploy` (ship)

### 98.4 Multimodal AI (`/godmode:multimodal`)

**Purpose:** Build AI systems that process multiple data types -- images, audio, video, documents, and text -- together.

**Workflow:**
1. **Discovery** -- Modalities needed, processing types (understanding, extraction, generation, search, transformation), volume, latency, budget
2. **Vision Integration** -- Model selection per use case (general understanding, OCR, object detection, classification, generation, chart understanding, image embedding) with pipeline design
3. **Audio Processing** -- STT model selection (Whisper, Deepgram, Google, Azure) with features (streaming, diarization, timestamps), TTS selection (OpenAI, ElevenLabs, Coqui), streaming architecture
4. **Document Understanding** -- PDF processing (PyMuPDF, pdfplumber, Unstructured, LlamaParse, marker, vision LLM), table extraction, form processing, document pipeline (classify, extract, structure, enrich)
5. **Multi-Modal RAG** -- Embedding strategies (unified space with CLIP, caption + text embed, separate indexes, late fusion), context assembly with images and audio, document-level retrieval
6. **Evaluation** -- Per-modality metrics (OCR accuracy, WER, table accuracy, image understanding) and end-to-end (cross-modal retrieval, latency, cost per modality)

**Key Principle:** Caption first, embed second. For multi-modal RAG, generating text descriptions of images/audio and embedding those descriptions is simpler and often more effective than unified embedding spaces.

**Chaining:** `/godmode:multimodal` -> `/godmode:rag` (integrate) -> `/godmode:embeddings` (optimize) -> `/godmode:aiops` (guardrails for media content) -> `/godmode:deploy` (ship)

### AI Skills Ecosystem

The four new skills complement the existing ML skills to form a complete AI development lifecycle:

```
Experiment & Train:
  /godmode:ml         -- Experiment tracking, evaluation, bias detection
  /godmode:finetune   -- Adapt pre-trained models to custom data

Build & Retrieve:
  /godmode:rag        -- Retrieval-augmented generation pipelines
  /godmode:embeddings -- Embedding creation, search, and management
  /godmode:multimodal -- Process images, audio, documents alongside text

Deploy & Operate:
  /godmode:mlops      -- Model serving, versioning, drift detection
  /godmode:aiops      -- Guardrails, cost, latency, safety, monitoring

Orchestrate:
  /godmode:agent      -- Autonomous AI agents with tools and memory
  /godmode:prompt     -- Prompt engineering and optimization
```

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/finetune/SKILL.md` | Skill | Model fine-tuning with LoRA/QLoRA/full FT, dataset prep, training, merging, deployment |
| `skills/embeddings/SKILL.md` | Skill | Embedding model selection, dimensionality reduction, hybrid search, versioning |
| `skills/aiops/SKILL.md` | Skill | Guardrails, hallucination detection, cost/latency optimization, safety testing, monitoring |
| `skills/multimodal/SKILL.md` | Skill | Vision, audio, document understanding, multi-modal RAG |
| `commands/godmode/finetune.md` | Command | Usage reference for `/godmode:finetune` |
| `commands/godmode/embeddings.md` | Command | Usage reference for `/godmode:embeddings` |
| `commands/godmode/aiops.md` | Command | Usage reference for `/godmode:aiops` |
| `commands/godmode/multimodal.md` | Command | Usage reference for `/godmode:multimodal` |

**Iterations 411-418 (4 skills created, 4 command files created, 1 design doc updated)**

## 93. Compliance Deep-Dive Skills

### Overview

Three deep compliance skills extend Godmode beyond the general `/godmode:comply` surface-level audit into regulation-specific implementation depth. Where `comply` identifies gaps across all frameworks, these skills produce implementable database schemas, API endpoints, middleware patterns, encryption configurations, evidence collection automation, and operational procedures for each specific regulation.

These skills are designed to be invoked after `/godmode:comply` identifies which regulations apply, or directly when the user knows their compliance target.

### Skill: `/godmode:gdpr` — GDPR Compliance

**Purpose:** Implement comprehensive GDPR compliance with production-ready code and operational procedures.

**Capabilities:**
- **Data mapping and classification:** Inventories all personal data fields across the codebase, classifies by GDPR category (identity, financial, behavioral, special category under Article 9), and builds the Article 30 processing activity register with lawful basis for each activity
- **Consent management implementation:** Designs and implements granular per-purpose consent with database schemas (consent_records, consent_types, consent_audit_log), REST API endpoints (record, query, update, withdraw, history, proof), and enforcement middleware that gates processing on valid consent
- **Right to deletion (data erasure workflows):** Implements Article 17 with cascading erasure across primary database, caches, search indices, file storage, CDN, email services, analytics, and third-party systems with tracking, verification, and erasure certificates
- **Data portability exports:** Creates Article 20 compliant export API producing machine-readable JSON/CSV with profile, transaction, content, and consent data, plus direct controller-to-controller transfer endpoint
- **Privacy impact assessments:** Produces Article 35 DPIA templates covering processing description, necessity/proportionality, risk identification, mitigation measures, DPO consultation, and supervisory authority consultation workflow
- **DPO notification procedures:** Documents when and how to notify the DPO, breach notification timelines (72-hour authority, data subject if high risk), breach register maintenance, and notification content requirements under Articles 33-34
- **Cross-border data transfer:** Assesses all data transfers outside the EEA, maps transfer mechanisms (adequacy decisions, SCCs with module selection, BCRs, derogations), and produces Transfer Impact Assessments for Schrems II compliance

### Skill: `/godmode:hipaa` — HIPAA Compliance

**Purpose:** Implement comprehensive HIPAA compliance covering all three safeguard categories with production-ready code and operational procedures.

**Capabilities:**
- **PHI identification and classification:** Scans codebase for all 18 HIPAA identifiers, classifies PHI by category (clinical, demographic, financial, operational) and risk level, maps ePHI flows from collection through storage, processing, transmission, and disposal
- **Encryption requirements (at rest, in transit):** Assesses encryption across all storage locations (database, backups, cache, file storage, mobile, workstations) and transmission channels (client-server, service-to-service, API, email, VPN), with approved algorithm guidance (AES-256-GCM, TLS 1.2+, RSA-2048+) and key management requirements (KMS, rotation, separation of duties)
- **Access control and audit logging:** Implements role-based access control with minimum necessary standard enforcement per job function, break-glass emergency access procedures, automatic session timeout, unique user identification, and comprehensive immutable audit logging with cryptographic chaining and 6-year retention
- **BAA (Business Associate Agreement) technical requirements:** Inventories all PHI-handling vendors, verifies BAA status, documents technical requirements for each business associate, tracks subcontractor BAA chains, and monitors vendor security posture with review schedules
- **Breach notification procedures:** Implements the 4-factor risk assessment for breach determination, documents the 60-day notification timeline (individual, HHS/OCR, media for 500+), tracks breach investigation from discovery through corrective action, and maintains the mandatory breach log

### Skill: `/godmode:soc2` — SOC 2 Compliance

**Purpose:** Prepare for SOC 2 Type I and Type II audits with comprehensive control implementation, evidence automation, and continuous monitoring.

**Capabilities:**
- **Trust Service Criteria (all five categories):** Evaluates all 64 criteria across Security (CC1-CC9 Common Criteria covering control environment, communication, risk assessment, monitoring, control activities, access controls, system operations, change management, risk mitigation), Availability (capacity, environmental protections, recovery), Processing Integrity (input validation, processing accuracy, error handling), Confidentiality (classification, disposal), and Privacy (notice, consent, collection, use, retention, access, disclosure, quality)
- **Evidence collection automation:** Builds automated evidence collection scripts for IAM user/role exports, MFA enrollment, PR approval audit trails, deployment history, uptime metrics, vulnerability scan results, encryption configurations, backup status, and access review records with centralized timestamped evidence repository
- **Control implementation and testing:** Designs controls mapped to identified risks, implements technical and process controls, tests using auditor methodology (inquiry, observation, inspection, reperformance) with appropriate sample sizes, documents results, and tracks remediation of ineffective controls
- **Continuous monitoring setup:** Builds three-layer monitoring across infrastructure (uptime, performance, capacity), security (failed logins, privilege escalation, vulnerability discovery), and compliance (overdue reviews, policy updates, training completion, evidence gaps) with compliance dashboard metrics
- **Audit preparation workflow:** Produces system description narrative, organizes evidence packages by TSC category, prepares Information Request response workflow, and guides through pre-audit, during-audit, and post-audit phases

### Relationship to `/godmode:comply`

| Aspect | `/godmode:comply` | `/godmode:gdpr` / `hipaa` / `soc2` |
|--------|-------------------|--------------------------------------|
| Scope | All regulations, surface-level | Single regulation, implementation depth |
| Output | Findings and checklists | Schemas, APIs, configs, procedures |
| Use case | "Which regulations apply?" | "How do I implement this regulation?" |
| Depth | Gap identification | Gap remediation with code |
| Typical flow | Run comply first | Then run specific regulation skill |

### Principles

| # | Principle | Rationale |
|---|-----------|-----------|
| 1 | Regulation-specific precision | Every finding cites the exact article/section (GDPR Art. 17.1, HIPAA section 164.312(a)(2)(iv), SOC 2 CC6.1) |
| 2 | Implementable output | Produce database schemas, API designs, and middleware patterns, not just checklists |
| 3 | Evidence-based assessment | Every finding references actual code, configuration, or system behavior |
| 4 | Cascading completeness | Compliance across all systems — primary DB, caches, backups, logs, third parties |
| 5 | Continuous over point-in-time | Build monitoring and automation, not just one-time assessments |
| 6 | No legal advice | Identify technical gaps and provide implementation guidance; recommend legal counsel for interpretation |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/gdpr/SKILL.md` | Skill | Deep GDPR compliance — data mapping, consent, erasure, portability, DPIAs, transfers |
| `skills/hipaa/SKILL.md` | Skill | Deep HIPAA compliance — PHI classification, encryption, access control, BAAs, breach notification |
| `skills/soc2/SKILL.md` | Skill | Deep SOC 2 compliance — Trust Service Criteria, evidence automation, control testing, audit prep |
| `commands/godmode/gdpr.md` | Command | Usage reference for `/godmode:gdpr` |
| `commands/godmode/hipaa.md` | Command | Usage reference for `/godmode:hipaa` |
| `commands/godmode/soc2.md` | Command | Usage reference for `/godmode:soc2` |

**Iterations 375-380 (6 files, 3 skills, 3 commands)**

---

## 92. Database Specialization Skills

Three database specialization skills give Godmode deep, production-grade expertise in PostgreSQL, Redis, and NoSQL databases — going far beyond the query optimization and migration skills already in the toolkit. These skills cover architecture, internals, operational tuning, and system design patterns specific to each database technology.

### 92.1 Postgres — PostgreSQL Mastery (`skills/postgres/SKILL.md`)

**Purpose:** Master advanced PostgreSQL features, extensions, replication, partitioning, performance tuning, and connection pooling.

**Key capabilities:**
- **Advanced SQL features:** Recursive and materialized CTEs (with PostgreSQL 12+ optimization fence control), window functions (ROW_NUMBER, PERCENT_RANK, LAG/LEAD, moving averages with RANGE frames), GROUPING SETS/CUBE/ROLLUP for multi-dimensional aggregation, and FILTER clause for conditional aggregation.
- **JSONB mastery:** GIN indexing (full and path-specific), containment operators (@>), SQL/JSON path queries (jsonb_path_query, jsonb_path_exists), JSONB aggregation (jsonb_agg, jsonb_build_object), atomic updates (jsonb_set, deep merge), and key removal.
- **Full-text search:** Weighted tsvector columns with GIN indexes, ts_rank_cd scoring, ts_headline snippet generation, auto-update triggers, prefix matching for autocomplete, phrase search, and pg_trgm for fuzzy matching.
- **Extension management:** pgvector (HNSW and IVFFlat indexes, cosine/L2/inner product distance, search quality tuning), PostGIS (spatial indexes, radius queries, bounding box queries, GeoJSON output), TimescaleDB (hypertables, compression policies, retention policies, continuous aggregates), and an extension selection guide covering 12 extensions.
- **Replication:** Streaming replication (physical, byte-for-byte HA with failover), logical replication (table-level, cross-version, selective sync), with monitoring queries and a comparison matrix.
- **Partitioning:** Declarative range (time-series), list (multi-tenant), and hash (even distribution) partitioning with pg_partman automation, partition pruning verification, and sizing guidelines.
- **VACUUM and autovacuum:** Dead tuple diagnostics, per-table autovacuum threshold tuning (scale factor, cost delay, cost limit), bloat remediation (pg_repack for online compaction), and the trigger formula explained.
- **pg_stat diagnostics:** pg_stat_statements (top queries by time, mean time, cache hit ratio), pg_stat_user_indexes (unused index detection), pg_stat_activity (lock monitoring, connection stats), and a diagnostic checklist with targets.
- **Connection pooling:** PgBouncer (session/transaction/statement modes, pool sizing, monitoring), Supavisor (multi-tenant, prepared statements in transaction mode), and pgcat (sharding) with a comparison matrix.
- **Performance tuning:** Memory (shared_buffers, effective_cache_size, work_mem), WAL (checkpoint tuning, wal_buffers), planner (random_page_cost for SSD, effective_io_concurrency), and parallelism configuration.

**Workflow:** Assess environment -> Apply advanced features (CTEs, windows, JSONB, FTS) -> Configure extensions -> Set up replication -> Design partitioning -> Tune VACUUM/autovacuum -> Configure pooling -> Performance tune -> Report.

**Command:** `/godmode:postgres` (`commands/godmode/postgres.md`)

### 92.2 Redis — Redis Architecture & System Design (`skills/redis/SKILL.md`)

**Purpose:** Design Redis-based systems including caching, queues, pub/sub, session stores, rate limiters, leaderboards, and distributed locks.

**Key capabilities:**
- **Data structure selection:** Complete guide covering strings (cache, counters, locks), hashes (objects, sessions), lists (queues, stacks, bounded collections), sets (membership, tags, set operations), sorted sets (leaderboards, priority queues, time-series indexes, rate limiting), and streams (event sourcing, consumer groups, reliable messaging) with memory encoding details and a decision matrix mapping 16 use cases to structures.
- **Caching strategies:** Cache-aside (lazy loading), write-through, write-behind patterns with code examples, four invalidation strategies (TTL, event, version, tag-based), key design conventions, and cache stampede prevention (probabilistic early expiration, distributed lock on miss, background refresh).
- **Queue and messaging:** Reliable queues with BRPOPLPUSH, priority queues with sorted sets, pub/sub for broadcasts, Redis Streams with consumer groups (XREADGROUP, XACK, XAUTOCLAIM for stuck messages), and a comparison matrix (Streams vs Pub/Sub vs Lists).
- **Session store:** Hash-based session design with TTL sliding, secondary indexes for user-to-session mapping, and session invalidation patterns.
- **Cluster and Sentinel:** Sentinel topology (3-node quorum, automatic failover, client connection via sentinel), Redis Cluster (16384 hash slots, hash tags for multi-key operations, cluster commands, limitations), and replication modes (async, WAIT for sync).
- **Memory optimization:** Encoding thresholds (listpack vs hashtable), key naming conventions, TTL hygiene, value compression, memory analysis commands (MEMORY USAGE, --bigkeys, --memkeys, MEMORY DOCTOR), and a memory report template.
- **Eviction policies:** Eight policies compared (noeviction, allkeys-lru, volatile-lru, allkeys-lfu, volatile-lfu, allkeys-random, volatile-random, volatile-ttl) with recommendations per use case.
- **Lua scripting and Redis Functions:** Atomic rate limiter in Lua, EVAL/EVALSHA for script caching, Redis 7+ Functions with named libraries and persistent registration, distributed lock with fencing tokens.
- **Common patterns:** Sliding window rate limiter, distributed locking (single-node and Redlock), leaderboards with contextual rankings.
- **Persistence:** RDB snapshots, AOF (appendfsync modes), combined RDB+AOF, and recommendations per use case.

**Workflow:** Assess environment -> Select data structures -> Design caching/queue/session strategy -> Configure Cluster or Sentinel -> Optimize memory and eviction -> Write Lua/Functions for atomicity -> Configure persistence -> Report.

**Command:** `/godmode:redis` (`commands/godmode/redis.md`)

### 92.3 NoSQL — NoSQL Database Design (`skills/nosql/SKILL.md`)

**Purpose:** Design data models for document, key-value, wide-column, graph, and time-series databases with database selection guidance.

**Key capabilities:**
- **Database selection:** Decision matrix comparing MongoDB, DynamoDB, Cassandra, Neo4j, InfluxDB, TimescaleDB, Redis, and Elasticsearch across data model fit, access pattern support, consistency, and scale. Includes a decision tree and NoSQL vs SQL comparison with the default advice: "Start with PostgreSQL."
- **MongoDB document modeling:** Five modeling patterns (embedded document, referenced document, bucket pattern for time-series, computed pattern for pre-aggregation, polymorphic pattern for mixed shapes), embedding vs referencing decision guide, compound and partial indexes, text indexes, wildcard indexes, TTL indexes, and multi-stage aggregation pipeline construction with optimization tips ($match early, $project early, allowDiskUse).
- **DynamoDB single-table design:** Composite PK/SK patterns, entity packing in a single table, GSI strategies (inverted index, status index, sparse index, overloaded GSI), LSI vs GSI trade-offs, capacity planning (on-demand vs provisioned, WCU/RCU calculations), and hot partition prevention with sharding workarounds.
- **Cassandra partition key design:** Query-driven table design (one table per query), partition key selection for high cardinality and even distribution, clustering column ordering, time bucketing strategies (day/hour/minute based on data rate), partition size targets (< 100MB, < 100K rows), wide-row pattern, and multi-table write amplification as a normal practice.
- **Neo4j graph modeling:** Node and relationship design principles, five graph patterns (social network, e-commerce recommendations, knowledge graph, fraud detection, dependency graph), Cypher queries for traversals (variable-length paths, shortest path, pattern matching, recommendations), and Graph vs Relational comparison showing where graphs are 100-1000x faster.
- **Time-series databases:** InfluxDB concepts (measurements, tags vs fields, high-cardinality warnings), Flux queries (aggregation windows, anomaly detection, downsampling tasks), and TimescaleDB vs InfluxDB comparison.

**Workflow:** Assess requirements -> Select database (decision matrix) -> Design data model for access patterns -> Build indexes -> Write queries for every access pattern -> Validate model against requirements -> Report.

**Command:** `/godmode:nosql` (`commands/godmode/nosql.md`)

### Skill Chains

**Database Deep-Dive Chain:**
```
/godmode:nosql --compare → /godmode:postgres (if SQL) → /godmode:query → /godmode:migrate
/godmode:nosql --compare → /godmode:nosql --mongodb (if document) → /godmode:query --mongo
/godmode:nosql --compare → /godmode:nosql --dynamodb (if key-value) → /godmode:deploy
```

**Full-Stack Data Chain:**
```
/godmode:schema → /godmode:postgres → /godmode:redis --cache → /godmode:query → /godmode:migrate → /godmode:deploy
```

**Performance Chain:**
```
/godmode:postgres --diagnose → /godmode:postgres --vacuum → /godmode:query → /godmode:redis --cache → /godmode:optimize
```

### Key Design Principles

| # | Principle | Rationale |
|---|-----------|-----------|
| 1 | Start with PostgreSQL | It handles 90% of workloads. Move to NoSQL only when PostgreSQL cannot meet a specific technical requirement. |
| 2 | Access patterns drive NoSQL design | In NoSQL, you design the data model around your queries, not around your entities. List every access pattern first. |
| 3 | Measure before tuning | Run pg_stat_statements, check Redis SLOWLOG, use MongoDB explain() before changing any configuration. |
| 4 | Connection pooling is mandatory | PostgreSQL forks a process per connection (~10MB each). Redis has max_clients limits. Always use poolers. |
| 5 | Denormalization is a feature in NoSQL | Duplicating data across tables (Cassandra) or embedding (MongoDB) trades storage for read performance. Document every decision. |
| 6 | Graph databases for relationships | If queries are "find connections" or "shortest path", a graph database is 100-1000x faster than relational JOINs. |
| 7 | Redis data structure selection matters | Using String for a leaderboard instead of Sorted Set wastes memory and makes operations harder. Choose the right structure. |

### Files Created

| File | Type | Description |
|------|------|-------------|
| `skills/postgres/SKILL.md` | Skill | PostgreSQL mastery with CTEs, JSONB, FTS, extensions, replication, partitioning, tuning |
| `skills/redis/SKILL.md` | Skill | Redis architecture with data structures, caching, queues, Cluster, Sentinel, Lua |
| `skills/nosql/SKILL.md` | Skill | NoSQL design with MongoDB, DynamoDB, Cassandra, Neo4j, time-series databases |
| `commands/godmode/postgres.md` | Command | Usage reference for `/godmode:postgres` |
| `commands/godmode/redis.md` | Command | Usage reference for `/godmode:redis` |
| `commands/godmode/nosql.md` | Command | Usage reference for `/godmode:nosql` |

**Iterations 364-369 (6 files, 3 skills, 3 commands)**
