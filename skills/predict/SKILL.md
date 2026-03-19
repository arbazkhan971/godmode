---
name: predict
description: |
  Multi-persona prediction and evaluation skill. Activates when user needs expert opinions on a design decision, architecture choice, or implementation approach. Simulates 5 expert personas who independently evaluate the proposal, then synthesizes consensus. Triggers on: /godmode:predict, "will this work?", "evaluate this approach", "what could go wrong?", or when invoked by /godmode:think --predict.
---

# Predict — Multi-Persona Expert Consensus

## When to Activate
- User invokes `/godmode:predict`
- User asks "will this approach work?" or "what do experts think?"
- User is about to make a major architectural decision
- Invoked by `/godmode:think --predict` after generating approaches
- User asks for a "second opinion" on a design

## Workflow

### Step 1: Define the Proposal
Clearly state what is being evaluated. If the user hasn't been specific, extract the proposal from:
1. The most recent spec in `docs/specs/`
2. The current conversation context
3. Staged or recent code changes

Format:
```
PROPOSAL UNDER EVALUATION:
<Clear, 2-3 sentence description of the approach/decision>

CONTEXT:
- Project: <what the project does>
- Stack: <relevant technologies>
- Scale: <expected usage/load>
- Constraints: <timeline, team size, budget>
```

### Step 2: Assemble the Panel
Select 5 expert personas with specific backgrounds, experience, and battle scars. These are not generic titles — each persona has a **name** (role only, no real names), **specific background**, **years of experience**, **bias** (what they care most about), **perspective** (optimist/pessimist/pragmatist), and **notable past experience** that shapes their judgment.

Default panel (all decisions):
```
1. Staff Backend Engineer (15yr)
   Background: Built distributed systems at scale, migrated monoliths to microservices, debugged production incidents involving data loss. Has seen "clever" architectures collapse under real-world load.
   Bias: correctness, data integrity, system boundaries
   Perspective: Pragmatist
   Shaped by: A migration that took 2 years instead of 6 months because the original design skipped edge cases

2. Frontend Architect (12yr, Design Systems team)
   Background: Led design system teams, built component libraries used by 200+ developers, optimized SPAs from 8s to 1.2s load times. Obsessed with developer ergonomics and user-perceived performance.
   Bias: UX impact, client complexity, state management, bundle size
   Perspective: Pragmatist
   Shaped by: A redesign that shipped 3 months late because the backend API was designed without frontend input

3. SRE / On-Call Engineer (10yr)
   Background: Has been paged at 3am more times than they can count. Wrote postmortems for cascading failures, managed incidents during Black Friday traffic spikes, built alerting systems from scratch.
   Bias: operability, failure modes, observability, rollback strategy, deployment safety
   Perspective: Pessimist
   Shaped by: A 6-hour outage caused by a config change with no rollback plan

4. Security Researcher (11yr)
   Background: Has found and reported CVEs. Performed penetration testing on production systems, discovered SSRF chains, exploited JWT misconfigurations. Thinks adversarially by default.
   Bias: attack surface, credential management, input validation, compliance, data exposure
   Perspective: Pessimist
   Shaped by: A breach that started with a single unsanitized log message leaking PII

5. Product Manager (13yr, shipped to 10M+ users)
   Background: Shipped products used by millions. Managed launches that succeeded and launches that flopped. Knows that technical elegance means nothing if users don't adopt it. Thinks in terms of rollout risk, feature flags, and success metrics.
   Bias: user value, iteration speed, rollout strategy, measurable outcomes, time-to-market
   Perspective: Optimist
   Shaped by: A technically perfect feature that nobody used because it solved the wrong problem
```

For frontend-heavy decisions, the panel shifts emphasis but keeps the same depth:
```
1. Frontend Architect (12yr) — same as above, takes lead
2. UX Engineer (9yr) — Built accessibility-first products, ran A/B tests on interaction patterns
3. Staff Backend Engineer (15yr) — same as above, focuses on API contract
4. Security Researcher (11yr) — same as above, focuses on XSS/CSRF/client-side secrets
5. Product Manager (13yr) — same as above
```

For ML/data decisions:
```
1. ML Engineer (10yr) — Trained models at scale, dealt with data drift, model serving latency
2. Data Engineer (12yr) — Built petabyte-scale pipelines, recovered from corrupt data incidents
3. Staff Backend Engineer (15yr) — same as above, focuses on serving infrastructure
4. Security Researcher (11yr) — same as above, focuses on PII/compliance/model poisoning
5. Product Manager (13yr) — same as above, focuses on experiment design and metrics
```

### Step 3: Independent Evaluations (Structured Prediction Format)
Each persona evaluates the proposal independently using a strict structured format. For each:

```
### <Persona Role> (<Years>yr experience)

**Prediction:** <Will this work? YES / YES WITH CHANGES / NO — in 1 sentence>

**Verdict:** <APPROVE | APPROVE WITH CONDITIONS | REJECT>

**Confidence:** <1-10> — <specific justification rooted in experience>

**Assessment:**
<2-3 sentences from this persona's perspective>

**Biggest Risk:**
<The single most important risk this persona sees, with severity: LOW/MEDIUM/HIGH/CRITICAL>

**Evidence from codebase:**
<Reference to actual code, patterns, or architecture in this project that supports the assessment. Include file paths, function names, or patterns observed. If no relevant code exists, state what's missing.>

**One Thing I'd Change:**
- <The single highest-impact concrete suggestion>

**Timeline Estimate:**
- Optimistic: <best case>
- Realistic: <expected>
- Pessimistic: <if things go wrong>
```

Rules:
- Each persona MUST evaluate independently — don't let one persona's opinion color another's
- At least one persona MUST raise a concern (no unanimous rubber-stamping)
- Risks must be SPECIFIC, not generic ("SQL injection via the search endpoint" not "security issues")
- Suggestions must be ACTIONABLE ("add a rate limiter to the /api/search endpoint" not "improve security")
- **Evidence is mandatory.** Every persona must reference actual code, files, or patterns in the project. Generic advice without project-specific evidence is forbidden. If a persona cannot find relevant code, they must state what they looked for and what was missing — that absence itself is evidence.
- **Confidence must be justified.** "8/10 — I've seen this pattern work at similar scale" is good. "8/10" alone is not.

### Step 4: Consensus Scoring
Aggregate all persona evaluations into a structured consensus:

```
┌─────────────────────────────────────────────────────────────────────┐
│  PREDICT — Expert Consensus                                        │
├─────────────────────────────────────────────────────────────────────┤
│  Verdict:    <PROCEED | PROCEED WITH CHANGES | RECONSIDER | REJECT>│
│  Score:      <X/5 approvals>                                       │
│  Avg Confidence: <average of all 5 confidence scores>/10           │
│  Confidence Range: <lowest> to <highest>                           │
│  Confidence Spread: <highest - lowest>                             │
├─────────────────────────────────────────────────────────────────────┤
│  DISAGREEMENT FLAGS:                                               │
│  <If any two personas differ by >3 points in confidence,           │
│   flag them here with both positions explained>                    │
│  <If spread > 3, flag: "Wide disagreement — investigate before     │
│   proceeding">                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  UNANIMOUS CONCERNS:                                               │
│  <List any risks or concerns raised by 3+ personas>               │
│  <These are non-negotiable — must be addressed regardless of       │
│   verdict>                                                         │
├─────────────────────────────────────────────────────────────────────┤
│  Timeline Consensus:                                               │
│  Optimistic: <min of optimistic estimates>                         │
│  Realistic:  <median of realistic estimates>                       │
│  Pessimistic: <max of pessimistic estimates>                       │
├─────────────────────────────────────────────────────────────────────┤
│  Top Risks:                                                        │
│  1. <Most critical risk> — <mitigation> — raised by: <personas>    │
│  2. <Second risk> — <mitigation> — raised by: <personas>           │
│  3. <Third risk> — <mitigation> — raised by: <personas>            │
├─────────────────────────────────────────────────────────────────────┤
│  Recommended Changes:                                              │
│  1. <Highest-impact change>                                        │
│  2. <Second change>                                                │
│  3. <Third change>                                                 │
└─────────────────────────────────────────────────────────────────────┘
```

Verdict rules:
- **PROCEED**: 4-5 approvals, no CRITICAL risks, avg confidence >= 7
- **PROCEED WITH CHANGES**: 3-4 approvals, or any HIGH risks with clear mitigations
- **RECONSIDER**: 2-3 approvals, or any CRITICAL risk, or avg confidence < 5
- **REJECT**: 0-1 approvals, or multiple CRITICAL risks

### Step 5: Iteration Gate (Consensus Below Threshold)
**HARD RULE: If average confidence is below 7/10, the design goes back to think for revision.**

```
ITERATION DECISION:

Average confidence: <X>/10

IF confidence >= 7:
  → Proceed to Step 6 (Update and Transition)

IF confidence < 7:
  → LOOP BACK TO THINK.
  → Include in the handback:
    - All risks identified by the panel
    - All disagreement flags
    - All unanimous concerns
    - Specific areas where confidence was lowest and why
  → Message to user: "The expert panel is not confident enough in this design
    (avg: <X>/10). Sending back to /godmode:think with the panel's feedback
    for revision."
```

This loop is not optional. A design with low expert confidence ships bugs, not features.

### Step 6: Update and Transition
1. If a spec exists, append the prediction results to it under a "## Expert Review" section
2. Commit: `"predict: <feature> — <verdict> (<score>/5, confidence <avg>/10)"`
3. Based on verdict:
   - PROCEED → "Ready to build. Run `/godmode:plan` to decompose into tasks."
   - PROCEED WITH CHANGES → "Incorporate the recommended changes, then `/godmode:plan`."
   - RECONSIDER → "Revisit the design. Run `/godmode:think` to explore alternatives." (auto-triggered if confidence < 7)
   - REJECT → "This approach has critical flaws. Run `/godmode:think` to start fresh."

## Key Behaviors

1. **Personas must disagree.** If all 5 agree, you're not trying hard enough. Real experts always find different concerns.
2. **Domain-specific panels.** Don't use the backend panel for a CSS refactor. Match the panel to the domain.
3. **Concrete, not abstract.** "This could have performance issues" is useless. "The N+1 query in getUserPosts will add ~200ms per page load at 1000 users" is useful.
4. **Honest confidence scores.** A confidence of 9/10 means "I'm almost certain." Don't inflate scores.
5. **Risks need severity levels.** LOW = nice to fix, MEDIUM = should fix before shipping, HIGH = must fix, CRITICAL = blocks shipping.
6. **Evidence is non-negotiable.** Every persona must reference actual code, files, or patterns from the project. No generic advice. If they can't find relevant code, they say what they looked for and what was missing.
7. **Confidence below 7 means loop.** This is a hard rule. Do not present a "PROCEED" verdict with average confidence below 7. Send it back to think with the panel's feedback.
8. **Disagreements are signal, not noise.** When personas disagree by more than 3 points, that's the most important part of the evaluation. Highlight it, don't smooth it over.
9. **Personas have scars.** Each persona's judgment is shaped by past experience. Their "shaped by" context should visibly influence their assessment — the SRE who's been paged at 3am should be paranoid about rollback plans, the security researcher should see attack vectors others miss.

## Example Usage

### Evaluating a database choice
```
User: /godmode:predict Should we use MongoDB or PostgreSQL for our e-commerce product catalog?

Predict: Let me assemble the expert panel...

PROPOSAL: Use MongoDB for the product catalog service, chosen for its
flexible schema to handle varying product attributes across categories.

### Systems Architect (Pragmatist)
**Verdict:** APPROVE WITH CONDITIONS
**Assessment:** MongoDB's flexible schema fits well for product catalogs
where categories have different attributes. However, the e-commerce
domain heavily relies on transactions (orders, inventory) which
PostgreSQL handles natively.
**Risks:**
1. Transaction support across collections requires careful design — MEDIUM
2. JOIN-heavy queries for "products + reviews + inventory" get complex — HIGH
**What I'd change:**
- Use MongoDB for catalog, but PostgreSQL for orders/inventory
- Define a clear boundary between the two

### Security Engineer (Pessimist)
**Verdict:** APPROVE WITH CONDITIONS
...
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full 5-persona evaluation |
| `--quick` | 3 personas, shorter assessments |
| `--panel <type>` | Force a specific panel: `backend`, `frontend`, `ml`, `devops`, `security` |
| `--custom "<role1>, <role2>, ..."` | Define custom panel members |
| `--versus "<A>" "<B>"` | Compare two proposals side by side, each persona evaluates both |

## Anti-Patterns

- **Do NOT rubber-stamp.** If all 5 personas approve with no concerns, the evaluation is worthless. Push harder.
- **Do NOT use generic risks.** "Could be slow" is not a risk. "The unindexed full-text search on the 10M-row products table will timeout at p99" is a risk.
- **Do NOT ignore the project context.** A solo developer building a weekend project doesn't need the same advice as a team of 20 building for 1M users.
- **Do NOT create fictional personas with real names.** Use role titles only (e.g., "Systems Architect"), not "Linus Torvalds" or "Dan Abramov."
- **Do NOT let the panel size creep.** 5 personas maximum. More voices doesn't mean better evaluation — it means more noise.
