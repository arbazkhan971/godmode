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
Select 5 expert personas relevant to the proposal domain. Each persona has a **name**, **expertise**, **bias** (what they care most about), and **perspective** (optimist/pessimist/pragmatist).

Default panel for backend decisions:
```
1. Systems Architect  — Bias: scalability & maintainability — Pragmatist
2. Security Engineer   — Bias: attack surface & data safety — Pessimist
3. Performance Engineer — Bias: latency & throughput — Pragmatist
4. Product Engineer     — Bias: shipping speed & user impact — Optimist
5. Ops/SRE Engineer     — Bias: operability & failure modes — Pessimist
```

For frontend decisions:
```
1. UX Engineer         — Bias: user experience & accessibility — Optimist
2. Performance Engineer — Bias: bundle size & rendering speed — Pessimist
3. Design Systems Lead  — Bias: consistency & reusability — Pragmatist
4. Product Engineer     — Bias: shipping speed & iteration — Optimist
5. Security Engineer    — Bias: XSS, CSRF, data leakage — Pessimist
```

For ML/data decisions:
```
1. ML Engineer         — Bias: model quality & training efficiency — Pragmatist
2. Data Engineer       — Bias: pipeline reliability & data quality — Pessimist
3. Platform Engineer   — Bias: infrastructure cost & scaling — Pragmatist
4. Product Scientist   — Bias: metrics impact & experiment design — Optimist
5. Security/Privacy Engineer — Bias: PII handling & compliance — Pessimist
```

### Step 3: Independent Evaluations
Each persona evaluates the proposal independently. For each:

```
### <Persona Name> (<Role>)

**Verdict:** <APPROVE | APPROVE WITH CONDITIONS | REJECT>

**Assessment:**
<2-3 sentences from this persona's perspective>

**Risks I see:**
1. <Specific risk with severity: LOW/MEDIUM/HIGH/CRITICAL>
2. <Specific risk with severity>

**What I'd change:**
- <Concrete suggestion>

**Confidence:** <1-10> — <why>
```

Rules:
- Each persona MUST evaluate independently — don't let one persona's opinion color another's
- At least one persona MUST raise a concern (no unanimous rubber-stamping)
- Risks must be SPECIFIC, not generic ("SQL injection via the search endpoint" not "security issues")
- Suggestions must be ACTIONABLE ("add a rate limiter to the /api/search endpoint" not "improve security")

### Step 4: Synthesize Consensus

```
┌─────────────────────────────────────────────┐
│  PREDICT — Expert Consensus                 │
├─────────────────────────────────────────────┤
│  Verdict:  <PROCEED | PROCEED WITH CHANGES  │
│            | RECONSIDER | REJECT>            │
│  Score:    <X/5 approvals>                  │
│  Confidence: <average confidence>/10        │
├─────────────────────────────────────────────┤
│  Top Risks:                                 │
│  1. <Most critical risk> — <mitigation>     │
│  2. <Second risk> — <mitigation>            │
│  3. <Third risk> — <mitigation>             │
├─────────────────────────────────────────────┤
│  Recommended Changes:                       │
│  1. <Highest-impact change>                 │
│  2. <Second change>                         │
│  3. <Third change>                          │
└─────────────────────────────────────────────┘
```

Verdict rules:
- **PROCEED**: 4-5 approvals, no CRITICAL risks
- **PROCEED WITH CHANGES**: 3-4 approvals, or any HIGH risks with clear mitigations
- **RECONSIDER**: 2-3 approvals, or any CRITICAL risk
- **REJECT**: 0-1 approvals, or multiple CRITICAL risks

### Step 5: Update and Transition
1. If a spec exists, append the prediction results to it under a "## Expert Review" section
2. Commit: `"predict: <feature> — <verdict> (<score>/5)"`
3. Based on verdict:
   - PROCEED → "Ready to build. Run `/godmode:plan` to decompose into tasks."
   - PROCEED WITH CHANGES → "Incorporate the recommended changes, then `/godmode:plan`."
   - RECONSIDER → "Revisit the design. Run `/godmode:think` to explore alternatives."
   - REJECT → "This approach has critical flaws. Run `/godmode:think` to start fresh."

## Key Behaviors

1. **Personas must disagree.** If all 5 agree, you're not trying hard enough. Real experts always find different concerns.
2. **Domain-specific panels.** Don't use the backend panel for a CSS refactor. Match the panel to the domain.
3. **Concrete, not abstract.** "This could have performance issues" is useless. "The N+1 query in getUserPosts will add ~200ms per page load at 1000 users" is useful.
4. **Honest confidence scores.** A confidence of 9/10 means "I'm almost certain." Don't inflate scores.
5. **Risks need severity levels.** LOW = nice to fix, MEDIUM = should fix before shipping, HIGH = must fix, CRITICAL = blocks shipping.

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
