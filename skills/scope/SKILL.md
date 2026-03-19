---
name: scope
description: |
  Scope management skill for feature decomposition, MVP definition, scope creep detection, requirements validation, and user story writing. Helps teams define what to build, what not to build, and when scope is expanding beyond original intent. Triggers on: /godmode:scope, "scope this feature", "define MVP", "write user stories", "scope creep", or when a feature request needs decomposition before planning.
---

# Scope — Scope Management

## When to Activate
- User invokes `/godmode:scope`
- User says "scope this feature", "what's the MVP", "write user stories", "this is getting too big"
- A feature request needs decomposition before planning
- User suspects scope creep in an ongoing project
- Requirements need validation or refinement
- User needs to communicate scope to stakeholders

## Workflow

### Step 1: Feature Scoping and Decomposition

Break a feature or project into well-defined, manageable components:

1. **Understand the problem** — What user problem does this solve? Who is the user?
2. **Identify capabilities** — What distinct capabilities does the solution need?
3. **Map boundaries** — What is explicitly in scope? What is explicitly out of scope?
4. **Estimate complexity** — T-shirt sizing for each component (S/M/L/XL)

```
FEATURE SCOPE:
Feature: <name>
Problem: <1-sentence problem statement>
User: <target user/persona>

IN SCOPE:
- <capability 1> [S/M/L/XL]
- <capability 2> [S/M/L/XL]
- <capability 3> [S/M/L/XL]

OUT OF SCOPE:
- <explicitly excluded item 1> — Reason: <why>
- <explicitly excluded item 2> — Reason: <why>

ASSUMPTIONS:
- <assumption 1>
- <assumption 2>

OPEN QUESTIONS:
- <question 1> — Needs answer from: <who>
- <question 2> — Needs answer from: <who>

Total Complexity: <sum of estimates>
```

### Step 2: Define MVP

Identify the minimum viable product — the smallest set of capabilities that delivers user value:

```
MVP DEFINITION:
Feature: <name>

CORE VALUE PROPOSITION:
<1 sentence: what is the single most important thing this feature does?>

MVP CRITERIA (must satisfy ALL):
1. Solves the core user problem (not a partial solution that frustrates)
2. Can be shipped and used independently
3. Provides enough value to get real user feedback
4. Can be built within <timeframe>

MVP SCOPE:
Must Include (core path):
- <capability> — WHY: <directly serves core value proposition>
- <capability> — WHY: <required for core path to work>
- <capability> — WHY: <users cannot complete flow without this>

Defer to V2:
- <capability> — WHY: <enhances but not required for core flow>
- <capability> — WHY: <optimization, not functionality>
- <capability> — WHY: <secondary user segment>

Defer to V3+:
- <capability> — WHY: <nice to have, low urgency>
- <capability> — WHY: <dependent on V1/V2 learnings>

MVP VALIDATION:
- Can a user complete the core flow with only MVP items? <yes/no>
- Does removing any MVP item break the core flow? <yes/no for each>
- Is this the SMALLEST set that delivers value? <yes/no>
```

The MVP test: If you cannot remove any item without breaking the core user flow, the MVP is correctly scoped. If you can remove an item and the feature still delivers its core value, that item belongs in V2.

### Step 3: Detect Scope Creep

Compare current scope against the original scope definition to identify creep:

```
SCOPE CREEP ANALYSIS:
Feature: <name>
Original Scope Date: <date>
Analysis Date: <date>

ORIGINAL SCOPE (from docs/specs/ or docs/plans/):
- <N> capabilities
- <N> story points estimated
- <N> files expected

CURRENT STATE:
- <N> capabilities (<delta> from original)
- <N> story points (<delta> from original)
- <N> files changed (<delta> from original)

SCOPE CHANGES DETECTED:
| Change | Type | Source | Impact |
|--------|------|--------|--------|
| <added capability> | ADDITION | <commit/PR/conversation> | +<points> |
| <expanded requirement> | EXPANSION | <commit/PR> | +<points> |
| <new edge case> | DISCOVERY | <during build> | +<points> |
| <removed item> | REDUCTION | <decision> | -<points> |

SCOPE CREEP SCORE:
Original: <N> points
Current: <M> points
Creep: <delta> points (<percent>% increase)

Severity:
  0-10%   GREEN   — Normal refinement, no action needed
  10-25%  YELLOW  — Moderate creep, review with stakeholders
  25-50%  ORANGE  — Significant creep, scope review required
  >50%    RED     — Major creep, stop and re-scope before continuing
```

Creep detection signals:
- New files created that were not in the original plan
- Commits referencing features not in the spec
- PR descriptions that say "while I was in here, I also..."
- TODO comments added for "future" work that creeps into current sprint
- Estimation overruns (task taking 3x original estimate)

### Step 4: Requirements Validation

Validate that requirements are complete, consistent, and testable:

```
REQUIREMENTS VALIDATION:
Feature: <name>

COMPLETENESS CHECK:
| Requirement | Has Acceptance Criteria | Has Edge Cases | Has Error Cases | Status |
|-------------|------------------------|----------------|-----------------|--------|
| <req 1>     | YES/NO                 | YES/NO         | YES/NO          | PASS/FAIL |
| <req 2>     | YES/NO                 | YES/NO         | YES/NO          | PASS/FAIL |

CONSISTENCY CHECK:
| Conflict | Requirements | Resolution |
|----------|-------------|------------|
| <conflict> | Req A vs Req B | <suggested resolution> |

TESTABILITY CHECK:
| Requirement | Testable? | How to Test | Automated? |
|-------------|-----------|-------------|------------|
| <req 1>     | YES/NO    | <method>    | YES/NO     |

AMBIGUITY CHECK:
| Requirement | Ambiguous Terms | Clarification Needed |
|-------------|----------------|---------------------|
| <req 1>     | <term>         | <what needs clarifying> |

GAPS IDENTIFIED:
- <missing requirement 1> — Inferred from: <context>
- <missing requirement 2> — Common in similar features
- <missing non-functional req> — Performance/security/a11y

VALIDATION SCORE:
Complete: <N>/<total> requirements fully specified
Consistent: <N> conflicts found
Testable: <N>/<total> requirements have test criteria
Ambiguity-free: <N> ambiguous terms found

Overall: <READY | NEEDS WORK | NOT READY>
```

### Step 5: Write and Refine User Stories

Generate well-structured user stories from requirements:

```markdown
## User Stories — <Feature Name>

### Epic: <Epic Name>

#### Story 1: <Title>
**As a** <user type>
**I want to** <action/capability>
**So that** <benefit/value>

**Acceptance Criteria:**
- [ ] GIVEN <precondition> WHEN <action> THEN <result>
- [ ] GIVEN <precondition> WHEN <action> THEN <result>
- [ ] GIVEN <edge case> WHEN <action> THEN <graceful handling>

**Technical Notes:**
- <implementation hint or constraint>
- <dependency on other stories>

**Size:** <S/M/L/XL> (<story points>)
**Priority:** <MUST/SHOULD/COULD>

---

#### Story 2: <Title>
...
```

Story quality checklist (INVEST criteria):
- **I**ndependent — Can be developed and delivered separately
- **N**egotiable — Details can be discussed, it is not a contract
- **V**aluable — Delivers value to the user
- **E**stimable — Team can estimate the effort
- **S**mall — Can be completed in one sprint
- **T**estable — Has clear acceptance criteria

Story refinement prompts:
1. "What happens when [edge case]?" — for each story
2. "Can this story be split into smaller stories?" — if estimated L or XL
3. "What does the user do right before and after this?" — to ensure flow continuity
4. "What if the user has no data yet?" — empty state handling
5. "What if this fails?" — error handling requirements

### Step 6: Generate Scope Document

Produce the final scope document:

```markdown
# <Feature Name> — Scope Document

## Problem Statement
<1-2 sentences describing the user problem>

## Target User
<persona or user segment>

## Success Metrics
- <metric 1: how we know this feature succeeded>
- <metric 2>

## MVP Scope
### In Scope (V1)
<list of MVP capabilities with sizes>

### Deferred (V2)
<list of V2 capabilities>

### Out of Scope
<explicitly excluded items with reasons>

## User Stories
<all stories with acceptance criteria>

## Requirements Validation
<validation results and any open items>

## Assumptions
<list of assumptions that, if wrong, change the scope>

## Open Questions
<questions that need answers before build can start>

## Estimated Effort
- Total stories: <N>
- Total points: <N>
- Estimated sprints: <N> (at velocity of <V>)
```

Save to `docs/scopes/<feature-name>-scope.md` and commit.

## Key Behaviors

1. **Explicit boundaries.** Every scope document has an "Out of Scope" section. What you choose NOT to build is as important as what you build.
2. **MVP is ruthlessly small.** The MVP test is simple: can you remove any item and still deliver the core value? If yes, remove it.
3. **Scope creep is detected, not judged.** Some scope growth is legitimate discovery. The skill detects and quantifies it — the team decides whether to accept or push back.
4. **Requirements are validated, not assumed.** Every requirement is checked for completeness, consistency, testability, and ambiguity before planning begins.
5. **User stories follow INVEST.** Stories that fail the INVEST criteria are refined until they pass.
6. **Assumptions are documented.** Every scope depends on assumptions. When assumptions change, scope must be re-evaluated.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full scoping workflow for a feature |
| `--mvp` | Define MVP only (skip full scoping) |
| `--creep` | Detect scope creep against original scope |
| `--validate` | Validate requirements only |
| `--stories` | Generate user stories from existing requirements |
| `--refine <story>` | Refine a specific user story |
| `--compare <v1> <v2>` | Compare scope between two versions |
| `--feature <name>` | Specify the feature to scope |
| `--budget <points>` | Set a point budget and scope to fit |

## Anti-Patterns

- **Do NOT scope without understanding the problem.** "Build a dashboard" is not a problem statement. "Users cannot see their usage metrics, causing surprise billing" is a problem statement.
- **Do NOT include everything in MVP.** The M in MVP means Minimum. If your MVP has 20 stories, it is not an MVP.
- **Do NOT ignore the "Out of Scope" section.** Undefined boundaries guarantee scope creep. If it is not explicitly out, stakeholders will assume it is in.
- **Do NOT write vague acceptance criteria.** "The page loads quickly" is not testable. "The page loads in under 2 seconds on 3G" is testable.
- **Do NOT treat scope as fixed forever.** Scope evolves as you learn. The document should be a living artifact that gets updated, not a contract carved in stone.
- **Do NOT skip the assumptions section.** Hidden assumptions are the number one cause of scope surprises. Document them early so they can be validated.

## Chaining

- `/godmode:scope` -> `/godmode:think` (design the solution after scoping the problem)
- `/godmode:scope` -> `/godmode:plan` (plan implementation of scoped feature)
- `/godmode:scope --creep` -> `/godmode:prioritize` (re-prioritize after scope change)
- `/godmode:scope --stories` -> `/godmode:plan` (convert stories to tasks)
- `/godmode:scope --mvp` -> `/godmode:build` (build the MVP)

## Example Usage

### Scope a new feature
```
User: /godmode:scope Add user notifications

Scope: Let's define the scope for user notifications.

What problem does this solve?
> Users miss important events (new comments, mentions, status changes)
  and have to manually check for updates.

Feature Scope:
IN SCOPE:
- In-app notification center [M]
- Email notification delivery [M]
- Notification preferences per type [S]
- Mark as read/unread [S]
- Real-time push (WebSocket) [L]

OUT OF SCOPE:
- SMS notifications — Reason: Requires Twilio integration, defer to V2
- Notification digests — Reason: Enhancement, not core flow
- Mobile push notifications — Reason: No mobile app yet

MVP: In-app center + email delivery + preferences (3 items, 2 sprints)
V2: Real-time push, SMS
```

### Detect scope creep
```
User: /godmode:scope --creep

Scope: Comparing current state to original scope...

Original: 8 capabilities, 24 points
Current: 12 capabilities, 38 points
Creep: +4 capabilities, +14 points (58% increase) — RED

Additions detected:
- Notification analytics dashboard (+5 pts) — added in PR #92
- Custom notification sounds (+3 pts) — added in commit abc123
- Bulk notification actions (+3 pts) — added in sprint mid-point
- Notification templates (+3 pts) — added by stakeholder request

Recommendation: STOP and re-scope. 58% creep requires stakeholder alignment.
Options: (1) Accept and extend timeline, (2) Defer additions to V2, (3) Cut original scope to make room
```

### Write user stories
```
User: /godmode:scope --stories --feature notifications

Scope: Generating user stories from notification requirements...

### Story 1: View Notification Center
As a logged-in user
I want to see a notification bell with unread count
So that I know when new events require my attention

Acceptance Criteria:
- GIVEN I have 3 unread notifications WHEN I load any page THEN I see a bell icon with "3"
- GIVEN I have 0 notifications WHEN I load any page THEN I see a bell icon with no badge
- GIVEN I click the bell WHEN the dropdown opens THEN I see my 10 most recent notifications
...
```
