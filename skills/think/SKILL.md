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

### Step 3: Generate 2-3 Approaches
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

### Step 4: Facilitate Decision
Present a comparison matrix:

```
| Dimension        | Approach A | Approach B | Approach C |
|-----------------|------------|------------|------------|
| Complexity       | Low        | Medium     | High       |
| Performance      | Good       | Best       | Good       |
| Maintainability  | Best       | Good       | Fair       |
| Effort           | 2 hours    | 4 hours    | 8 hours    |
| Risk             | Low        | Medium     | High       |
```

Make a recommendation with reasoning, but let the user decide. Say:
```
"I'd go with Approach B because [specific reason]. But Approach A is the safe bet if [condition]. What do you think?"
```

### Step 5: Write the Spec
Once the user confirms an approach, write a concrete spec:

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

### Step 6: Commit and Transition
1. Save the spec as `docs/specs/<feature-name>.md`
2. Commit: `"spec: <feature-name> — <one-line summary>"`
3. Suggest: "Spec complete. Ready to plan? Run `/godmode:plan` to decompose this into tasks."

## Key Behaviors

1. **One question at a time.** Never ask more than one question per response. Let the conversation flow naturally.
2. **Show, don't just tell.** Use code snippets, diagrams (ASCII), and concrete examples — not abstract descriptions.
3. **Research before proposing.** Always search the codebase first. Proposals that ignore existing patterns are useless.
4. **Spec is the deliverable.** Every think session MUST produce a written spec. A brainstorm without a spec is wasted time.
5. **Stay neutral until asked.** Present options fairly. Only recommend when the user asks or when one option is clearly superior.
6. **Time-box the exploration.** If the user is going in circles after 3 rounds, gently push toward a decision: "We've explored the space well. I'd suggest we go with X and iterate. We can always change direction later."

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
