---
name: rfc
description: |
  RFC and technical proposal writing skill. Activates when the team needs to propose, discuss, and decide on significant technical changes. Provides structured RFC templates with problem statement, proposed solution, alternatives, risks, migration plan, and decision timeline. Manages stakeholder review workflow and tracks proposal lifecycle. Triggers on: /godmode:rfc, "write a proposal", "RFC for", "propose a change", or when /godmode:think produces a decision requiring broader team input.
---

# RFC — Technical Proposals & Requests for Comments

## When to Activate
- User invokes `/godmode:rfc`
- User says "write an RFC", "propose a change", "I need team buy-in for X"
- A design decision from `/godmode:think` is too large for a single-person ADR
- User wants to propose a breaking change, new dependency, or architecture migration
- User says "how do I get approval for this?" or "I need to write a proposal"

## Workflow

### Step 1: Determine RFC Type
Identify the scope and nature of the proposal:

```
RFC CLASSIFICATION:
- FEATURE: New capability or significant enhancement
- ARCHITECTURE: Structural change to the system
- PROCESS: Change to development workflow or practices
- DEPRECATION: Removing or replacing existing functionality
- MIGRATION: Moving from one technology/pattern to another
- STANDARD: Establishing a new convention or standard
```

Each type has different review requirements:
```
REVIEW REQUIREMENTS:
- FEATURE:       2 reviewers, 3-day comment period
- ARCHITECTURE:  3 reviewers, 5-day comment period
- PROCESS:       All team, 5-day comment period
- DEPRECATION:   2 reviewers + affected team leads, 5-day comment period
- MIGRATION:     3 reviewers, 7-day comment period
- STANDARD:      All team, 7-day comment period
```

### Step 2: Research & Evidence Gathering
Before writing the RFC, gather supporting evidence:

```bash
# Understand the current state
find . -name "*.ts" -o -name "*.js" -o -name "*.py" | head -50
git log --oneline --since="3 months ago" -- <relevant-paths>

# Check for related past RFCs or ADRs
ls docs/rfcs/ docs/adr/ 2>/dev/null

# Measure the problem (if applicable)
# Performance metrics, error rates, developer friction data
```

```
EVIDENCE GATHERED:
- Current state: <description with file references>
- Problem evidence: <metrics, error counts, developer complaints>
- Prior art: <what others have done, existing RFCs/ADRs>
- Constraints: <technical limits, timeline, team capacity>
```

### Step 3: Write the RFC
Create the RFC using the structured template:

```markdown
# RFC-<NNN>: <Title>

## Metadata
- **Author:** <name>
- **Status:** Draft | In Review | Accepted | Rejected | Withdrawn
- **Type:** <Feature | Architecture | Process | Deprecation | Migration | Standard>
- **Created:** <YYYY-MM-DD>
- **Review deadline:** <YYYY-MM-DD>
- **Reviewers:** <list of required reviewers>
- **Decision:** <Pending | Approved | Rejected | Deferred>

## Summary
<2-3 sentence executive summary. A busy person should be able to read just this
and understand what you're proposing and why.>

## Problem Statement
<What problem are we solving? Be specific and quantitative where possible.>

### Evidence
- <Metric or observation supporting the problem>
- <Metric or observation supporting the problem>
- <Code reference showing the problem: file:line>

### Impact
- **Who is affected:** <teams, users, systems>
- **Severity:** <How bad is this if we do nothing?>
- **Urgency:** <How soon do we need to act?>

## Proposed Solution

### Overview
<High-level description of the proposed change>

### Detailed Design
<Technical details of the implementation>

#### API Changes
<New/modified API surfaces, if any>

#### Data Model Changes
<Database schema changes, if any>

#### Configuration Changes
<New config options, environment variables, if any>

### Implementation Plan
<Phased rollout plan with milestones>

| Phase | Description | Duration | Deliverable |
|-------|-------------|----------|-------------|
| 1     | <phase>     | <time>   | <output>    |
| 2     | <phase>     | <time>   | <output>    |
| 3     | <phase>     | <time>   | <output>    |

### Migration Strategy
<How existing code/data migrates to the new approach>
<Backward compatibility considerations>
<Rollback plan if migration fails>

## Alternatives Considered

### Alternative 1: <Name>
- **Description:** <How it works>
- **Pros:** <Advantages>
- **Cons:** <Disadvantages>
- **Why not chosen:** <Specific reason>

### Alternative 2: <Name>
- **Description:** <How it works>
- **Pros:** <Advantages>
- **Cons:** <Disadvantages>
- **Why not chosen:** <Specific reason>

### Do Nothing
- **Description:** Keep the current approach
- **Pros:** No effort, no risk of regression
- **Cons:** <Why the status quo is unacceptable>

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| <risk> | <H/M/L> | <H/M/L> | <strategy> |
| <risk> | <H/M/L> | <H/M/L> | <strategy> |

## Security Considerations
<Security implications of the change, if any>

## Performance Considerations
<Performance impact, benchmarks, capacity planning>

## Testing Strategy
<How will the change be tested?>
- Unit tests: <scope>
- Integration tests: <scope>
- Load tests: <scope, if applicable>
- Rollout verification: <canary metrics>

## Open Questions
- [ ] <Question that needs answering before acceptance>
- [ ] <Question that needs answering before acceptance>

## References
- <Related ADRs, RFCs, external docs, benchmarks>
```

Save to `docs/rfcs/<NNN>-<kebab-case-title>.md`.

### Step 4: Manage Review Process
Track stakeholder reviews:

```
REVIEW TRACKER:
┌──────────────────────────────────────────────────────────────┐
│  RFC-012: Migrate from REST to GraphQL                        │
│  Status: In Review    Deadline: 2024-04-15                    │
├──────────────────┬────────────┬────────────────────────────────┤
│  Reviewer        │  Status    │  Comments                      │
├──────────────────┼────────────┼────────────────────────────────┤
│  @alice          │  Approved  │  "LGTM with minor suggestion" │
│  @bob            │  Concerns  │  "Performance risk in Phase 2" │
│  @carol          │  Pending   │  (no response yet)             │
├──────────────────┴────────────┴────────────────────────────────┤
│  Comments: 7 total, 2 blocking, 5 resolved                    │
│  Decision: PENDING — waiting on @carol + @bob's concern       │
└──────────────────────────────────────────────────────────────┘
```

When reviewers raise concerns:
1. Acknowledge the concern in the RFC's Open Questions
2. Research and propose a resolution
3. Update the RFC with the resolution
4. Re-request review from the concerned reviewer

### Step 5: Track Decision Timeline
Maintain a decision log within the RFC:

```markdown
## Decision Log
| Date | Event | Details |
|------|-------|---------|
| 2024-04-01 | RFC Created | Draft circulated to reviewers |
| 2024-04-03 | Comment from @bob | Concern about Phase 2 performance |
| 2024-04-05 | Updated | Added benchmarks addressing performance concern |
| 2024-04-08 | @bob approves | Performance concern resolved |
| 2024-04-10 | @carol approves | No concerns |
| 2024-04-10 | ACCEPTED | All reviewers approved, proceeding to Phase 1 |
```

### Step 6: Finalize RFC
When the review period ends:

```
RFC FINALIZATION:
- If all reviewers approve → Status: Accepted
  → Create ADR from the decision
  → Create implementation plan via /godmode:plan
  → Archive RFC

- If blocking concerns unresolved → Status: Deferred
  → Document unresolved concerns
  → Set revisit date

- If proposal rejected → Status: Rejected
  → Document reasons for rejection
  → Preserve for future reference
```

### Step 7: Commit
```
git add docs/rfcs/<NNN>-<title>.md
git commit -m "rfc: RFC-<NNN> — <title> (<status>)"
```

## Key Behaviors

1. **"Do Nothing" is always an alternative.** Every RFC must explicitly evaluate and reject the status quo. If "do nothing" is acceptable, you do not need an RFC.
2. **Evidence, not opinions.** The Problem Statement must include numbers, metrics, or concrete code references. "Our API is slow" is not a problem statement. "P95 latency for /api/users is 2.3s, up from 400ms in Q1" is.
3. **The Summary is the most important section.** Most reviewers will read only the summary. Make it count.
4. **Risks must have mitigations.** Listing risks without mitigations is just worry. Every risk should have a concrete response plan.
5. **RFCs have deadlines.** A review period without a deadline will never end. Set a date and hold to it.
6. **Accept gracefully, reject gracefully.** Both outcomes are valid. Document the reasoning for future teams who will wonder "why didn't we do X?"

## Example Usage

### Writing a new RFC
```
User: /godmode:rfc We should migrate from Express to Fastify for better performance

RFC: Let me research the current state...

EVIDENCE GATHERED:
- Server: Express 4.18, src/server.ts
- Routes: 14 endpoints in src/routes/
- Middleware: 6 custom middleware in src/middleware/
- Performance: No current benchmarks found
- Dependencies: 4 Express-specific packages

I'll create RFC-003: Migrate HTTP Server from Express to Fastify

[Writes full RFC with problem statement, benchmarks comparison,
migration plan (3 phases), alternatives (Koa, Hono, keep Express),
risks (middleware compatibility, team learning curve), and timeline]

Saved to docs/rfcs/003-migrate-express-to-fastify.md

Next: Share with reviewers and set a 5-day comment period.
Want me to also create a benchmark comparison to support the evidence?
```

### Checking RFC status
```
User: /godmode:rfc --status

RFC: Scanning proposal records...

ACTIVE RFCs:
┌──────┬────────────────────────────────┬────────────┬────────────┐
│  #   │  Title                         │  Status    │  Deadline  │
├──────┼────────────────────────────────┼────────────┼────────────┤
│  001 │  Adopt TypeScript Strict Mode  │  Accepted  │  —         │
│  002 │  Monorepo Migration            │  In Review │  Apr 20    │
│  003 │  Express to Fastify            │  Draft     │  —         │
└──────┴────────────────────────────────┴────────────┴────────────┘
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive RFC creation |
| `--list` | List all RFCs with status |
| `--status` | Show active RFCs and review progress |
| `--template` | Output a blank RFC template |
| `--review <NNN>` | Start or update review for RFC-NNN |
| `--accept <NNN>` | Mark RFC-NNN as accepted |
| `--reject <NNN>` | Mark RFC-NNN as rejected with reason |
| `--defer <NNN>` | Defer RFC-NNN with revisit date |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check for existing RFC directory: docs/rfcs/, rfcs/, docs/proposals/
2. Detect RFC numbering: scan existing RFCs for numbering convention (001, RFC-001, etc.)
3. Check for RFC template: docs/rfcs/template.md, .github/RFC_TEMPLATE.md
4. Detect review process: CODEOWNERS, PR review requirements, approval workflows
5. Check for decision log: docs/decisions/, ADR directory, decision-log.md
6. Detect team communication: Slack webhook, email distribution list for RFC announcements
7. Scan for active RFCs: find drafts, in-review, accepted statuses in RFC metadata
```

## Iterative RFC Writing Loop

```
current_iteration = 0
max_iterations = 8
rfc_sections = [problem, context, options, proposal, risks, migration, open_questions, review]

WHILE rfc_sections is not empty AND current_iteration < max_iterations:
    section = rfc_sections.pop(0)
    1. IF problem: define the problem clearly with evidence (metrics, user reports, incidents)
    2. IF context: document current state, constraints, and prior art
    3. IF options: list all alternatives including "Do Nothing" with pros/cons
    4. IF proposal: detail the recommended approach with concrete implementation steps
    5. IF risks: identify risks with likelihood, impact, and mitigation strategies
    6. IF migration: define rollout plan, backward compatibility, rollback procedure
    7. IF open_questions: list unresolved questions that need input from reviewers
    8. IF review: submit for team review with clear review deadline
    9. Validate: every section is concise, evidence-based, and actionable
    10. current_iteration += 1

POST-LOOP: Verify all open questions are resolved before accepting
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. EVERY RFC must include a "Do Nothing" alternative. If status quo is fine, no RFC needed.
2. NEVER write an RFC after the code is already written. RFC = proposal, not notification.
3. EVERY RFC must have a review deadline. Open-ended reviews never close.
4. NEVER accept an RFC with unresolved open questions. Resolve or explicitly defer each one.
5. EVERY rejected RFC must be preserved with rejection rationale. Future teams need this context.
6. RFC scope must be small enough to explain in < 5 pages. If longer, split into multiple RFCs.
7. EVERY RFC must include a rollback/migration plan. Irreversible decisions need extra scrutiny.
8. NEVER skip the alternatives section. Single-option RFCs are not proposals — they are mandates.
```

## Output Format
Print on completion:
```
RFC-{NNN}: {title}
Type: {type} | Status: {status}
Reviewers: {N} assigned | Comment period: {N} days
Alternatives: {N} evaluated (including Do Nothing)
Open questions: {N} ({N_resolved} resolved, {N_pending} pending)
Saved to: {file_path}
```

## TSV Logging
Log every RFC session to `.godmode/rfc-results.tsv`:
```
timestamp	rfc_number	title	type	status	reviewers	alternatives_count	open_questions	file_path
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. RFC contains Summary, Problem Statement, Proposed Solution, Alternatives (including Do Nothing), Risks, and Testing Strategy.
2. At least 2 alternatives evaluated with pros, cons, and rejection rationale.
3. Every risk has a corresponding mitigation strategy.
4. Review deadline set with specific date.
5. RFC is under 5 pages. If longer, split into multiple RFCs.
6. Problem Statement contains at least one quantitative metric or concrete code reference.
7. RFC saved to `docs/rfcs/` with correct numbering sequence.

## Error Recovery
```
IF no existing RFC directory or numbering convention found:
  → Create docs/rfcs/ directory
  → Start numbering at 001
  → Create docs/rfcs/README.md with RFC process summary

IF user wants to write RFC after code is already written:
  → Warn: "Code already exists. This RFC documents a decision retroactively."
  → Change RFC type to "Decision Record" and save as ADR instead
  → Suggest: "For future proposals, write RFC before implementation"

IF review deadline passes with unresolved concerns:
  → Status remains "In Review" — do NOT auto-accept
  → Append to Decision Log: "Deadline {date} passed — {N} unresolved concerns"
  → Suggest: extend deadline by 3 days or schedule a synchronous review meeting

IF RFC scope exceeds 5 pages:
  → Split into parent RFC (overview + decision) and child RFCs (detailed design per component)
  → Parent RFC references children: "See RFC-{N+1} for Phase 2 details"

IF all reviewers reject:
  → Set status to Rejected
  → Document rejection rationale in Decision Log
  → Preserve the RFC — do NOT delete it
  → Suggest: "Revisit in {timeframe} or explore alternative approaches"
```

## Anti-Patterns

- **Do NOT write an RFC for trivial changes.** Renaming a variable doesn't need team consensus. RFCs are for decisions that are hard to reverse.
- **Do NOT skip "Do Nothing."** If you can't articulate why the status quo is unacceptable, the status quo is fine.
- **Do NOT write a 20-page RFC.** If it takes 20 pages to explain, your proposal is too big. Split it into smaller RFCs.
- **Do NOT present a fait accompli.** An RFC published after the code is written is not a proposal — it's a notification. Write the RFC BEFORE implementation.
- **Do NOT leave open questions unanswered.** Every open question must be resolved (answered or explicitly deferred) before the RFC can be accepted.
- **Do NOT ignore rejected RFCs.** A rejected RFC is valuable documentation. It explains why a path was NOT taken, saving future teams from re-exploring it.


## Keep/Discard Discipline
```
After EACH RFC section draft:
  KEEP if: section is evidence-based, concise, and actionable
  DISCARD if: section is vague, lacks evidence, or exceeds page budget
  On discard: rewrite section with specific evidence and code references.
  Never keep a section without concrete data or code references.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached: all RFC sections complete AND committed
  - budget_exhausted: max 8 iterations across all sections
  - diminishing_returns: re-edits produce no new information
  - stuck: >5 section rewrites with no quality improvement
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run RFC tasks sequentially: evidence gathering, then RFC drafting, then review tracking.
- Use branch isolation per task: `git checkout -b godmode-rfc-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
