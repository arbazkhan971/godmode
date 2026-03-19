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

## Status: ITERATION 43 — CI/CD Integration complete
