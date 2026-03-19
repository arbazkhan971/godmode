---
name: think
description: |
  Brainstorming and design skill. Activates when user needs to explore ideas, design a feature, evaluate approaches, or create a spec before building. Triggers on: /godmode:think, "let's brainstorm", "help me design", "what's the best way to", or when godmode orchestrator detects THINK phase. Produces a written spec as output.
---

# Think — Collaborative Design Sessions

## When to Activate
- User invokes `/godmode:think`
- User asks "how should I design/architect/approach X?"
- User wants to explore multiple solutions before committing to one
- Godmode orchestrator routes here (no spec exists yet)
- User says "brainstorm", "think through", "let's design", "explore options"

## Workflow

### Step 1: Understand the Goal
Ask ONE clarifying question to anchor the session. Do not ask a barrage of questions. Pick the single most important unknown.

```
Good: "What's the primary constraint — latency, cost, or correctness?"
Bad:  "What language? What framework? What database? What scale? What team size?"
```

If the user's request is already clear enough, skip this step entirely.

### Step 2: Research the Codebase
Before proposing anything, understand what already exists:

1. Search for related files, modules, and patterns in the codebase
2. Check existing tests for implicit specifications
3. Look at similar features already implemented for patterns to follow
4. Identify integration points and dependencies

Summarize findings:
```
CODEBASE CONTEXT:
- Existing patterns: <what the codebase already does>
- Integration points: <where new code connects>
- Constraints: <tech stack, conventions, dependencies>
- Related code: <file paths of relevant existing code>
```

### Step 3: Multi-Persona Brainstorm
Before generating approaches, simulate 5 expert personas who each independently brainstorm on the design problem. Each persona brings a different lens:

```
BRAINSTORM PANEL:

1. Backend Architect — Focuses on data models, APIs, system boundaries, consistency guarantees
2. Frontend Lead — Focuses on UX implications, state management, latency sensitivity, client complexity
3. DevOps Engineer — Focuses on deployment, observability, infrastructure cost, rollback strategy
4. Security Expert — Focuses on attack surface, data exposure, authentication flows, compliance
5. Product Manager — Focuses on user value, iteration speed, feature flags, rollout risk, success metrics
```

For each persona, produce:
```
### <Persona> Perspective
**Key concern:** <What matters most to this persona>
**Proposed direction:** <1-2 sentence approach suggestion>
**Dealbreaker if ignored:** <One thing that would make the design fail from their POV>
**Question for the team:** <One open question this persona raises>
```

After all 5 perspectives are surfaced, synthesize common themes and divergences before moving to approaches.

### Step 4: Generate 2-3 Approaches
For each approach, provide:

```
## Approach A: <Name>

**How it works:** <2-3 sentence description>

**Pros:**
- <concrete advantage with evidence>
- <concrete advantage with evidence>

**Cons:**
- <concrete disadvantage with evidence>
- <concrete disadvantage with evidence>

**Best when:** <specific condition where this approach wins>

**Rough effort:** <small/medium/large> — <why>
```

Rules for approaches:
- Always include at least one simple/boring approach (the "just do the obvious thing" option)
- Always include at least one creative/unconventional approach
- Back claims with evidence from the codebase, not theory
- Be honest about tradeoffs — no "best of all worlds" fantasies

### Step 5: Design Decision Matrix
Score each approach across 5 dimensions on a 1-5 scale (1 = best, 5 = worst):

```
DESIGN DECISION MATRIX:

| Dimension        | Approach A | Approach B | Approach C |
|-----------------|------------|------------|------------|
| Complexity (1-5) |            |            |            |
| Risk (1-5)       |            |            |            |
| Time (1-5)       |            |            |            |
| Maintainability  |            |            |            |
| Scalability (1-5)|            |            |            |
|-----------------|------------|------------|------------|
| TOTAL (lower=better) |        |            |            |

AUTO-RECOMMENDATION: Approach <X> scores lowest (best) overall.
```

Scoring rules:
- Complexity: 1 = trivial, 5 = requires PhD-level understanding
- Risk: 1 = well-trodden path, 5 = untested/experimental in this codebase
- Time: 1 = hours, 2 = a day, 3 = a few days, 4 = a week, 5 = weeks+
- Maintainability: 1 = any dev can maintain, 5 = only the author understands it
- Scalability: 1 = scales to 100x with no changes, 5 = will break at 2x load

Auto-recommend the lowest-scoring approach, but flag if scores are within 2 points of each other (too close to call — user decides). Say:
```
"I'd go with Approach B because [specific reason]. But Approach A is the safe bet if [condition]. What do you think?"
```

### Step 6: Anti-Pattern Detection
Before finalizing the design, check the proposed approach against known anti-patterns for the detected project type. This is a mandatory gate — do not skip it.

1. **Detect project type** from the codebase (e.g., REST API, CLI tool, SPA, microservice, data pipeline, mobile app)
2. **Check against anti-patterns** relevant to that type:

```
ANTI-PATTERN CHECK:

Project type detected: <type>

| Anti-Pattern | Applies? | Details |
|-------------|----------|---------|
| <anti-pattern name> | YES/NO | <why it does or doesn't apply> |
| <anti-pattern name> | YES/NO | <why it does or doesn't apply> |
| ... | ... | ... |

VIOLATIONS FOUND: <N>
```

Common anti-pattern libraries by project type:
- **REST API:** God endpoint, chatty API, missing pagination, N+1 queries, no idempotency on mutations, synchronous long operations, leaking internal IDs
- **SPA/Frontend:** Prop drilling, state bloat, waterfall requests, no error boundaries, client-side secrets, unthrottled event handlers
- **Microservices:** Distributed monolith, shared database, synchronous chain calls, missing circuit breaker, no saga/compensation for failures
- **CLI tools:** God command, no --help, silent failures, hard-coded paths, no exit codes
- **Data pipelines:** No idempotency, no backpressure, unbounded queues, missing dead letter queue, no schema validation at boundaries

If violations are found, revise the approach to eliminate them before proceeding to the spec.

### Step 7: Write the Spec
Once the user confirms an approach, write a concrete spec in two formats:

#### Markdown Spec (for humans)
```markdown
# <Feature Name> — Specification

## Goal
<One sentence describing what this achieves>

## Approach
<Selected approach with details>

## Key Decisions
- <Decision 1>: <Rationale>
- <Decision 2>: <Rationale>

## Interface
<API signatures, function signatures, or UI descriptions>

## Data Flow
<How data moves through the system>

## Edge Cases
- <Edge case 1>: <How we handle it>
- <Edge case 2>: <How we handle it>

## Success Criteria
- [ ] <Measurable criterion 1>
- [ ] <Measurable criterion 2>
- [ ] <Measurable criterion 3>

## Out of Scope
- <What we're explicitly NOT doing>
```

#### Spec-as-Code (structured YAML)
Also save a machine-readable version alongside the markdown spec:

```yaml
# <feature-name>.spec.yaml
spec_version: "1.0"
feature: "<Feature Name>"
created: "<ISO 8601 date>"

problem:
  statement: "<One sentence problem description>"
  context: "<Why this matters now>"

constraints:
  - "<Constraint 1>"
  - "<Constraint 2>"

approaches:
  - name: "<Approach A>"
    summary: "<2-3 sentences>"
    scores:
      complexity: <1-5>
      risk: <1-5>
      time: <1-5>
      maintainability: <1-5>
      scalability: <1-5>
      total: <sum>
  - name: "<Approach B>"
    summary: "<2-3 sentences>"
    scores:
      complexity: <1-5>
      risk: <1-5>
      time: <1-5>
      maintainability: <1-5>
      scalability: <1-5>
      total: <sum>

selected_approach:
  name: "<Selected Approach>"
  rationale: "<Why this was chosen>"

success_criteria:
  - criterion: "<Measurable criterion 1>"
    metric: "<How to measure>"
  - criterion: "<Measurable criterion 2>"
    metric: "<How to measure>"

edge_cases:
  - case: "<Edge case 1>"
    handling: "<How we handle it>"
  - case: "<Edge case 2>"
    handling: "<How we handle it>"

anti_patterns_checked:
  - pattern: "<Anti-pattern name>"
    status: "clear"  # or "mitigated"
    notes: "<Details>"

out_of_scope:
  - "<What we're explicitly NOT doing>"
```

Save the YAML spec as `docs/specs/<feature-name>.spec.yaml` alongside the markdown spec.

### Step 8: Iteration Gate (HARD RULE)
**Before finalizing, audit the spec for completeness. This is non-negotiable.**

Scan the spec (both markdown and YAML) for any of the following:
- "TBD", "TODO", "to be determined", "to be decided"
- Empty sections or placeholder text
- Vague language: "appropriate", "as needed", "etc.", "and so on"
- Missing edge case handling (edge cases listed without a handling strategy)
- Success criteria that are not measurable
- Unanswered questions from the multi-persona brainstorm

```
ITERATION GATE CHECK:

| Check | Pass? | Issue |
|-------|-------|-------|
| No TBD/TODO items | YES/NO | <details> |
| All sections filled | YES/NO | <details> |
| No vague language | YES/NO | <details> |
| All edge cases have handlers | YES/NO | <details> |
| All success criteria measurable | YES/NO | <details> |
| All persona questions answered | YES/NO | <details> |
| Anti-pattern check passed | YES/NO | <details> |

RESULT: <PASS — proceed to commit> or <FAIL — loop back to Step N>
```

**If ANY check fails:** Do NOT present the spec. Loop back to the relevant step, investigate, fill the gap, and re-run the iteration gate. Repeat until all checks pass.

**There is no limit to the number of loops.** A spec with "TBD" items is not a spec — it is a draft. Drafts do not leave the think phase.

### Step 9: Commit and Transition
1. Save the markdown spec as `docs/specs/<feature-name>.md`
2. Save the YAML spec as `docs/specs/<feature-name>.spec.yaml`
3. Commit: `"spec: <feature-name> — <one-line summary>"`
4. Suggest: "Spec complete. Ready to plan? Run `/godmode:plan` to decompose this into tasks."

## Key Behaviors

1. **One question at a time.** Never ask more than one question per response. Let the conversation flow naturally.
2. **Show, don't just tell.** Use code snippets, diagrams (ASCII), and concrete examples — not abstract descriptions.
3. **Research before proposing.** Always search the codebase first. Proposals that ignore existing patterns are useless.
4. **Spec is the deliverable.** Every think session MUST produce a written spec (markdown + YAML). A brainstorm without a spec is wasted time.
5. **Stay neutral until asked.** Present options fairly. Only recommend when the user asks or when one option is clearly superior.
6. **Time-box the exploration.** If the user is going in circles after 3 rounds, gently push toward a decision: "We've explored the space well. I'd suggest we go with X and iterate. We can always change direction later."
7. **No TBDs allowed.** The iteration gate is a hard rule. If you find a gap, fill it. Do not present specs with placeholders, open questions, or vague language. Loop until the spec is complete.
8. **Multi-persona brainstorm is mandatory.** Every design session runs through the 5 expert personas before generating approaches. This surfaces blind spots early.
9. **Decision matrix drives the recommendation.** Quantitative scores, not gut feel. If the scores are close, say so — let the user break the tie.
10. **Anti-patterns are a gate, not a suggestion.** If a violation is found, the approach must be revised before the spec is written.

## Example Usage

### New feature design
```
User: /godmode:think I need to add WebSocket support to our REST API

Think: Let me research the codebase first...

CODEBASE CONTEXT:
- Server: Express.js on Node 20, already using http module
- Auth: JWT tokens validated via middleware
- Existing pattern: REST controllers in src/controllers/
- Tests: Jest + supertest for HTTP endpoints
- No existing WebSocket code

One question before we start: Is this for real-time notifications
(server→client), bidirectional messaging (chat-style), or both?

User: Real-time notifications — price updates for a trading dashboard

Think: Got it. Here are three approaches...

## Approach A: Socket.io on Express
**How it works:** Add socket.io alongside Express, sharing the HTTP server...

## Approach B: Server-Sent Events (SSE)
**How it works:** Use native SSE via Express routes, no new dependencies...

## Approach C: Standalone WebSocket Server
**How it works:** Separate ws server on different port, reverse-proxied...
```

### Architecture decision
```
User: /godmode:think Should we use a monorepo or polyrepo for our microservices?

Think: Let me understand the current state...
[researches codebase]

Before I lay out options — how many services are you planning,
and how many developers will be working across them?
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full brainstorm workflow |
| `--quick` | Skip to 2-3 approaches without deep codebase research |
| `--spec-only` | Skip brainstorming, just write a spec from the user's description |
| `--predict` | After generating approaches, run `/godmode:predict` on each to get expert opinions |
| `--scenario` | After selecting an approach, run `/godmode:scenario` to explore edge cases |

## Anti-Patterns

- **Do NOT skip codebase research.** Proposing a Redis cache when the project already uses Memcached is embarrassing. Look first.
- **Do NOT present more than 3 approaches.** Analysis paralysis kills momentum. 2-3 options is the sweet spot.
- **Do NOT write implementation code during THINK.** This phase produces specs, not code. Code examples in specs are fine, but don't start building.
- **Do NOT let the session drag on.** If you're on round 5 and still brainstorming, something is wrong. Push toward a decision.
- **Do NOT ignore the user's preference.** If they clearly favor an approach, help refine it instead of pushing alternatives.
- **Do NOT produce a vague spec.** "We'll handle errors appropriately" is not a spec. "4xx errors return JSON with error code and message; 5xx errors are logged and return generic 500" is a spec.
