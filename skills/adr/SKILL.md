---
name: adr
description: |
  Architecture Decision Records skill. Activates when the team needs to document, discover, or maintain architectural decisions. Creates ADRs with structured templates including context, alternatives analysis, consequences, and status tracking (proposed, accepted, deprecated, superseded). Triggers on: /godmode:adr, "document this decision", "why did we choose", "architecture decision", or when a significant design choice is made during /godmode:think.
---

# ADR — Architecture Decision Records

## When to Activate
- User invokes `/godmode:adr`
- User asks "why did we choose X?" or "document this architecture decision"
- A significant design choice is made during `/godmode:think` or `/godmode:plan`
- User wants to review past decisions or check if a decision is still valid
- User says "what decisions have we made?" or "decision log"

## Workflow

### Step 1: Determine Intent
Identify what the user needs:

```
INTENT DETECTION:
- CREATE: User wants to record a new decision
- DISCOVER: User wants to find/understand past decisions
- UPDATE: User wants to change status of an existing ADR
- AUDIT: User wants to review all ADRs for staleness or relevance
```

If creating a new ADR, proceed to Step 2. If discovering, skip to Step 5. If updating, skip to Step 6. If auditing, skip to Step 7.

### Step 2: Gather Context
Research the codebase and conversation to understand the decision:

```bash
# Check for existing ADRs
ls docs/adr/ 2>/dev/null

# Find the next ADR number
ls docs/adr/*.md 2>/dev/null | sort -t'-' -k1 -n | tail -1

# Search for related decisions
grep -r "related" docs/adr/ 2>/dev/null
```

Ask ONE clarifying question if the decision context is unclear:
```
Good: "What's the key constraint driving this decision — performance, team familiarity, or long-term maintainability?"
Bad:  "What are all the options? What did you consider? Who are the stakeholders? What's the timeline?"
```

### Step 3: Analyze Alternatives
For each alternative considered, document:

```
ALTERNATIVES ANALYSIS:

## Alternative 1: <Name>
- Description: <How it works>
- Pros: <Concrete advantages>
- Cons: <Concrete disadvantages>
- Evidence: <Benchmarks, case studies, codebase patterns>

## Alternative 2: <Name>
- Description: <How it works>
- Pros: <Concrete advantages>
- Cons: <Concrete disadvantages>
- Evidence: <Benchmarks, case studies, codebase patterns>

## Alternative 3: <Name> (if applicable)
...
```

Rules for alternatives:
- Always include at least 2 alternatives (the chosen one and the strongest rejected one)
- Back claims with evidence from the codebase, benchmarks, or industry references
- Be honest about tradeoffs of the chosen option — ADRs that don't admit downsides are useless

### Step 4: Write the ADR
Create the ADR using the standard template:

```markdown
# ADR-<NNN>: <Title>

## Status
<Proposed | Accepted | Deprecated | Superseded by ADR-XXX>

## Date
<YYYY-MM-DD>

## Context
<What is the issue that we're seeing that is motivating this decision or change?>
<What are the forces at play (technical, political, social, project)?
Include specific code references where relevant.>

## Decision
<What is the change that we're proposing and/or doing?>

## Alternatives Considered

### <Alternative 1>
- **Description:** <How it works>
- **Pros:** <List>
- **Cons:** <List>
- **Why rejected:** <Specific reason>

### <Alternative 2>
- **Description:** <How it works>
- **Pros:** <List>
- **Cons:** <List>
- **Why rejected:** <Specific reason>

## Consequences

### Positive
- <Concrete positive outcome>
- <Concrete positive outcome>

### Negative
- <Concrete negative outcome and how we'll mitigate it>
- <Concrete negative outcome and how we'll mitigate it>

### Neutral
- <Side effects that are neither good nor bad>

## Related Decisions
- <ADR-XXX: Related decision>

## References
- <Links to specs, RFCs, external docs>
```

Save to `docs/adr/<NNN>-<kebab-case-title>.md` where NNN is zero-padded (001, 002, etc.).

### Step 5: Discover Past Decisions
When the user wants to find or understand decisions:

```bash
# List all ADRs with status
for f in docs/adr/*.md; do
  title=$(head -1 "$f" | sed 's/# //')
  status=$(grep -A1 "## Status" "$f" | tail -1)
  echo "$title — $status"
done

# Search ADRs by keyword
grep -l "<keyword>" docs/adr/*.md
```

Present results:
```
ADR DISCOVERY:
┌──────────────────────────────────────────────────────┐
│  Architecture Decision Records                        │
├──────┬────────────────────────────────┬───────────────┤
│  #   │  Title                         │  Status       │
├──────┼────────────────────────────────┼───────────────┤
│  001 │  Use PostgreSQL over MongoDB   │  Accepted     │
│  002 │  Adopt TypeScript              │  Accepted     │
│  003 │  REST over GraphQL             │  Superseded   │
│  004 │  Move to GraphQL               │  Accepted     │
│  005 │  Redis for caching             │  Accepted     │
└──────┴────────────────────────────────┴───────────────┘
```

### Step 6: Update ADR Status
When a decision needs to be revised:

```
STATUS TRANSITIONS:
- Proposed → Accepted (decision confirmed)
- Proposed → Rejected (decision not taken)
- Accepted → Deprecated (no longer relevant)
- Accepted → Superseded by ADR-XXX (replaced by new decision)
```

When superseding:
1. Update the old ADR's status to "Superseded by ADR-XXX"
2. Create the new ADR with a reference to the old one
3. Commit both changes together

### Step 7: Audit ADRs
Review all decisions for staleness:

```
ADR AUDIT:
┌──────────────────────────────────────────────────────────────┐
│  ADR Health Check                                             │
├──────┬───────────────────────────┬──────────┬─────────────────┤
│  #   │  Title                    │  Age     │  Status         │
├──────┼───────────────────────────┼──────────┼─────────────────┤
│  001 │  Use PostgreSQL           │  14 mo   │  OK             │
│  002 │  REST over GraphQL        │  11 mo   │  STALE — review │
│  003 │  Monolith architecture    │  8 mo    │  CONFLICT        │
└──────┴───────────────────────────┴──────────┴─────────────────┘

STALE: ADR-002 references REST but codebase now has GraphQL endpoints
CONFLICT: ADR-003 says monolith but src/services/ has 4 microservices
```

For each stale or conflicting ADR, recommend: keep, update, deprecate, or supersede.

### Step 8: Commit
```
git add docs/adr/<NNN>-<title>.md
git commit -m "adr: ADR-<NNN> — <title> (<status>)"
```

## Key Behaviors

1. **Every ADR has a number.** Sequential, zero-padded, never reused. ADR-001 is ADR-001 forever.
2. **Decisions are immutable once accepted.** Don't edit accepted ADRs — supersede them with a new ADR that references the old one.
3. **Context is king.** The most important section is Context. A decision without context is useless to future readers.
4. **Alternatives must be real.** Don't include straw-man alternatives. Every alternative listed should have been genuinely considered.
5. **Consequences are honest.** Every decision has negative consequences. An ADR that lists only positives is incomplete.
6. **ADRs are living documents until accepted.** Proposed ADRs can be freely edited. Once accepted, they are frozen.

## Example Usage

### Recording a new decision
```
User: /godmode:adr We decided to use Redis for session storage instead of PostgreSQL

ADR: Let me research the codebase for context...

Found: src/config/database.ts uses PostgreSQL via pg driver
Found: No existing session management code
Found: package.json has no Redis dependency

Creating ADR-007: Use Redis for Session Storage

## Status
Accepted

## Context
Our application needs server-side session storage for authenticated users.
Currently, all data is stored in PostgreSQL (see src/config/database.ts).
Session data has different access patterns than business data: high read
frequency, short TTL, and no need for relational queries.

## Decision
Use Redis for session storage via the `ioredis` package.

## Alternatives Considered
### PostgreSQL sessions table
- Pros: Single database, familiar, already configured
- Cons: Row-level locking under high read load, no native TTL
- Why rejected: Session reads would add load to the primary database

## Consequences
### Positive
- Sub-millisecond session lookups
- Native TTL support for automatic session expiry
### Negative
- Additional infrastructure dependency (Redis server)
- Team needs to learn Redis operations and monitoring

Saved to docs/adr/007-use-redis-for-session-storage.md
```

### Discovering past decisions
```
User: /godmode:adr Why did we choose PostgreSQL?

ADR: Searching decision records...

Found ADR-001: Use PostgreSQL over MongoDB (Accepted, 2024-03-15)

Context: Application has relational data with complex queries...
Decision: PostgreSQL chosen for ACID compliance and JOIN support...
Alternatives: MongoDB (rejected: schema flexibility not worth losing JOINs)
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive ADR creation |
| `--list` | List all ADRs with status |
| `--audit` | Audit all ADRs for staleness |
| `--status <status>` | Filter ADRs by status |
| `--search <keyword>` | Search ADRs by keyword |
| `--supersede <NNN>` | Create a new ADR that supersedes ADR-NNN |
| `--template` | Output a blank ADR template |

## Anti-Patterns

- **Do NOT skip the alternatives section.** "We chose X because X is good" is not an ADR. Document what you didn't choose and why.
- **Do NOT edit accepted ADRs.** Supersede them. The history of decisions is as important as the decisions themselves.
- **Do NOT write ADRs for trivial decisions.** "We use 2-space indentation" is a linting rule, not an architecture decision.
- **Do NOT backfill ADRs without research.** If you're documenting a past decision, investigate the actual reasons — don't invent a post-hoc rationalization.
- **Do NOT let ADRs rot.** Run `--audit` periodically. Stale ADRs erode trust in the decision log.
- **Do NOT write vague consequences.** "This might have performance implications" is not useful. "Redis adds ~50MB memory overhead per 100K sessions" is useful.
