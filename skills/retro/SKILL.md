---
name: retro
description: |
  Retrospective and team health skill. Facilitates structured sprint retrospectives, tracks team health metrics over time, manages action items from retros, and measures continuous improvement. Triggers on: /godmode:retro, "let's do a retro", "sprint retrospective", "team health check", "what went well", or when a sprint ends and no retro has been recorded.
---

# Retro — Retrospective & Team Health

## When to Activate
- User invokes `/godmode:retro`
- User says "let's do a retro", "sprint retrospective", "what should we improve"
- A sprint has ended and no retrospective document exists
- User asks about team health, morale, or process improvements
- User wants to review action items from previous retrospectives

## Workflow

### Step 1: Gather Sprint Context

Before facilitating the retrospective, collect data about the sprint:

1. **Sprint metrics** — Pull velocity, burndown, and completion data (from `/godmode:standup --velocity` if available)
2. **Git history** — Review commits, PRs, and merge patterns for the sprint period
3. **Incident history** — Check for any incidents during the sprint
4. **Previous retro actions** — Load action items from the last retrospective and check completion status

```
SPRINT CONTEXT:
Sprint: <name/number>
Duration: <start_date> to <end_date>
Velocity: <completed_points> / <committed_points> (<accuracy>%)
PRs Merged: <count>
Incidents: <count> (SEV breakdown)
Previous Action Items: <completed>/<total> completed
```

### Step 2: Choose Retrospective Format

Select or let the user choose from proven retrospective formats:

```
RETROSPECTIVE FORMATS:

1. Start/Stop/Continue
   - What should we START doing?
   - What should we STOP doing?
   - What should we CONTINUE doing?

2. 4Ls (Liked, Learned, Lacked, Longed For)
   - What did we LIKE?
   - What did we LEARN?
   - What did we LACK?
   - What did we LONG FOR?

3. Mad/Sad/Glad
   - What made us MAD?
   - What made us SAD?
   - What made us GLAD?

4. Sailboat
   - WIND (what propelled us forward)
   - ANCHOR (what held us back)
   - ROCKS (risks we avoided or hit)
   - ISLAND (our goal/destination)

5. What Went Well / What Didn't / Action Items
   - Classic three-column format
   - Best for teams new to retrospectives
```

Default to format 1 (Start/Stop/Continue) unless the user specifies otherwise.

### Step 3: Facilitate the Retrospective

Guide the retrospective through structured phases:

**Phase 1: Set the Stage (2 min)**
- State the prime directive: "Regardless of what we discover, we understand and truly believe that everyone did the best job they could, given what they knew at the time, their skills and abilities, the resources available, and the situation at hand."
- Review the sprint context and previous action items
- Set the format and time expectations

**Phase 2: Gather Data (10 min)**
Prompt the user for input in each category. For solo developers, infer from git data:

```markdown
## Sprint Retrospective — <Sprint Name>
### Date: <date>
### Format: Start/Stop/Continue

#### START (Things we should begin doing)
- <item 1>
- <item 2>

#### STOP (Things we should cease doing)
- <item 1>
- <item 2>

#### CONTINUE (Things that are working well)
- <item 1>
- <item 2>
```

For solo developers, auto-generate suggestions from data:
- **START suggestions** — patterns seen in successful open-source projects but missing here (e.g., "start writing integration tests", "start documenting API changes")
- **STOP suggestions** — anti-patterns detected in git history (e.g., "stop pushing directly to main", "stop skipping CI on small changes")
- **CONTINUE suggestions** — positive patterns detected (e.g., "continue small, focused PRs", "continue writing tests before implementation")

**Phase 3: Generate Insights (5 min)**
Identify themes and patterns across the items:

```
THEMES IDENTIFIED:
1. <Theme name> — <N items relate to this>
   Root cause: <underlying reason>
   Impact: <how this affects the team>

2. <Theme name> — <N items relate to this>
   Root cause: <underlying reason>
   Impact: <how this affects the team>
```

**Phase 4: Define Action Items (5 min)**
Convert insights into concrete, trackable actions:

```markdown
### Action Items

| # | Action | Owner | Deadline | Priority | Status |
|---|--------|-------|----------|----------|--------|
| 1 | <specific action> | <person> | <date> | HIGH | TODO |
| 2 | <specific action> | <person> | <date> | MEDIUM | TODO |
| 3 | <specific action> | <person> | <date> | LOW | TODO |
```

Rules for action items:
- **Maximum 3 action items per retro.** More than 3 means nothing gets done.
- **Each action has an owner.** "The team" is not an owner.
- **Each action has a deadline.** Default to "before next retro."
- **Each action is verifiable.** "Improve code quality" is not an action. "Add pre-commit linting hook to all repos" is an action.

### Step 4: Track Team Health Metrics

Measure team health across key dimensions over time:

```
TEAM HEALTH CHECK:
Dimension           | Score (1-5) | Trend      | Notes
--------------------|-------------|------------|-------
Delivery Pace       | <score>     | <up/down/stable> | <note>
Code Quality        | <score>     | <up/down/stable> | <note>
Technical Debt      | <score>     | <up/down/stable> | <note>
Testing Confidence  | <score>     | <up/down/stable> | <note>
Documentation       | <score>     | <up/down/stable> | <note>
CI/CD Reliability   | <score>     | <up/down/stable> | <note>
Developer Experience| <score>     | <up/down/stable> | <note>
Process Efficiency  | <score>     | <up/down/stable> | <note>

Overall Health: <average> / 5.0 (<trend>)
```

Scoring guide:
- **5** — Excellent, no improvement needed
- **4** — Good, minor improvements possible
- **3** — Adequate, noticeable room for improvement
- **2** — Struggling, needs focused attention
- **1** — Critical, blocking team effectiveness

Health metrics are inferred from:
- **Delivery Pace** — Velocity trend and sprint accuracy
- **Code Quality** — PR review comments, bug rate, lint violations
- **Technical Debt** — TODOs, FIXME count trends, dependency age
- **Testing Confidence** — Test coverage trends, flaky test count
- **Documentation** — Doc-to-code ratio, stale docs, README freshness
- **CI/CD Reliability** — Build success rate, pipeline duration trends
- **Developer Experience** — Build time, test time, PR merge time
- **Process Efficiency** — Cycle time, lead time, flow efficiency

### Step 5: Track Continuous Improvement

Compare retrospective data across sprints to measure improvement:

```
CONTINUOUS IMPROVEMENT TRACKER:
Sprint    | Health | Velocity | Actions Done | Top Improvement
----------|--------|----------|-------------|------------------
Sprint N  | 3.8    | 34 pts   | 2/3         | Added pre-commit hooks
Sprint N-1| 3.5    | 31 pts   | 3/3         | Reduced PR review time
Sprint N-2| 3.2    | 28 pts   | 1/3         | Fixed flaky tests
Sprint N-3| 3.0    | 30 pts   | 2/3         | Started code reviews

Improvement Trend: POSITIVE (+0.8 health over 4 sprints)
Action Completion Rate: 67% (8/12 actions completed)

Recurring Themes (appeared 3+ times):
- "Testing gaps" — appeared in 4 of 6 retros (needs systemic fix)
- "Documentation lag" — appeared in 3 of 6 retros (improving but not resolved)
```

When recurring themes appear in 3+ consecutive retros:
1. Escalate to a dedicated improvement initiative
2. Recommend a focused sprint or hack day
3. Suggest structural changes (tooling, process, team structure)

### Step 6: Save and Commit

1. Save retrospective to `docs/retros/<sprint-name>-retro.md`
2. Update action items tracker at `docs/retros/action-items.md`
3. Update health metrics at `docs/retros/team-health.md`
4. Commit: `"retro: <sprint-name> — <N> action items, health <score>/5"`

## Key Behaviors

1. **Blameless by default.** The prime directive is not optional. Focus on systems and processes, not individuals.
2. **Data-driven insights.** Back up observations with git data, metrics, and evidence. "We felt slow" should be accompanied by velocity numbers.
3. **Action items are sacred.** Maximum 3 per retro. Each must have an owner, deadline, and verifiable completion criteria.
4. **Track over time.** A single retrospective is a snapshot. The value comes from tracking trends across sprints.
5. **Recurring themes demand escalation.** If the same problem appears 3 times, the retro process alone is not sufficient. Escalate to a dedicated initiative.
6. **Health metrics are holistic.** Velocity is one dimension. Code quality, developer experience, and process efficiency matter just as much.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full retrospective facilitation with default format |
| `--format <type>` | Choose retro format: `ssc` (Start/Stop/Continue), `4l`, `msg` (Mad/Sad/Glad), `sailboat`, `www` (What Went Well) |
| `--sprint <name>` | Specify the sprint to retrospect |
| `--health` | Show team health metrics only (skip full retro) |
| `--actions` | Show pending action items from previous retros |
| `--trends` | Show continuous improvement trends across sprints |
| `--auto` | Auto-generate retro insights from git data (solo developer mode) |
| `--compare <N>` | Compare health metrics across last N sprints |

## Auto-Detection

```
AUTO-DETECT SEQUENCE:
1. Check git log for sprint/iteration boundaries: tags, merge patterns, date ranges
2. Detect sprint length: analyze commit frequency patterns (1-week, 2-week, etc.)
3. Check for previous retro artifacts: docs/retro*, retrospective*, retro-sprint-*
4. Detect project management tool: Jira, Linear, Shortcut references in commits/PRs
5. Calculate velocity: count merged PRs, closed issues, story points (from commit messages)
6. Check for previous action items: grep retro docs for "Action:", "TODO:", "[ ]"
7. Analyze CI data: build success rate, deploy frequency, test pass rate for the sprint
```

## Iterative Retro Facilitation Loop

```
current_iteration = 0
max_iterations = 6
retro_phases = [context_gather, generate_insights, group_themes, vote_priorities, define_actions, close]

WHILE retro_phases is not empty AND current_iteration < max_iterations:
    phase = retro_phases.pop(0)
    1. IF context_gather: pull velocity, incidents, action item completion from last retro
    2. IF generate_insights: collect Start/Stop/Continue (or chosen format) inputs
    3. IF group_themes: cluster related items, identify recurring patterns across sprints
    4. IF vote_priorities: rank themes by team vote or impact score
    5. IF define_actions: create max 3 SMART action items with owners and due dates
    6. IF close: summarize retro, confirm action items, save artifact
    7. Validate: every action item has an owner, due date, and measurable outcome
    8. IF validation fails → refine action items until they pass SMART criteria
    9. current_iteration += 1

POST-LOOP: Compare with last 3 retros for recurring unresolved themes
```

## HARD RULES

```
MECHANICAL CONSTRAINTS — NEVER VIOLATE:
1. ALWAYS start with the prime directive. Blameless, every time.
2. NEVER create more than 3 action items per retro. Focus beats breadth.
3. EVERY action item must be SMART: Specific, Measurable, Assignable, Realistic, Time-bound.
4. ALWAYS review previous retro action items first. Unfinished items carry forward or are dropped explicitly.
5. NEVER compare teams against each other. Health metrics track a team's own trajectory.
6. EVERY insight must be backed by data. "Felt slow" must reference actual velocity numbers.
7. NEVER skip the retro because "the sprint went fine." Good sprints have improvement opportunities too.
8. Action item owners must be individuals, not "the team." Shared ownership = no ownership.
```

## Anti-Patterns

- **Do NOT skip the prime directive.** Even for solo developers, the blameless mindset matters. Self-blame is just as unproductive as blaming others.
- **Do NOT create more than 3 action items.** Dilution kills follow-through. If everything is a priority, nothing is.
- **Do NOT let action items be vague.** "Be better at testing" is a wish, not an action item. "Add integration test suite for payment module by March 25" is an action item.
- **Do NOT ignore previous action items.** Every retro starts by reviewing whether last sprint's actions were completed. Unfinished actions carry forward or are explicitly dropped.
- **Do NOT retro without data.** Feelings are valid inputs, but they must be accompanied by evidence. "I felt we were slow" should reference actual velocity numbers.
- **Do NOT compare teams.** Health metrics are for tracking a team's own improvement, not benchmarking against other teams.

## Chaining

- `/godmode:retro` -> `/godmode:standup --velocity` (pull sprint data for context)
- `/godmode:retro` -> `/godmode:prioritize` (prioritize action items)
- `/godmode:retro` -> `/godmode:plan` (plan improvement initiatives from recurring themes)
- `/godmode:retro --actions` -> `/godmode:scope` (scope out improvement work)

## Example Usage

### Standard sprint retrospective
```
User: /godmode:retro

Retro: Loading sprint context...

Sprint 14: Mar 5-18, 2026
Velocity: 34/38 points (89% accuracy)
Previous action items: 2/3 completed

Using Start/Stop/Continue format.
Prime Directive: "Regardless of what we discover..."

What should we START doing?
> [User provides input or --auto generates from data]
```

### Team health check
```
User: /godmode:retro --health

Retro: Calculating team health metrics...

TEAM HEALTH CHECK:
Delivery Pace       | 4 | Stable   | 89% sprint accuracy
Code Quality        | 3 | Up       | PR comments down 30%
Technical Debt      | 2 | Down     | TODO count increased 15%
Testing Confidence  | 4 | Up       | Coverage 82% -> 87%
...
Overall Health: 3.6 / 5.0 (Improving)
```

### Continuous improvement trends
```
User: /godmode:retro --trends

Retro: Analyzing last 6 sprints...

[Improvement tracker with health trends, velocity, action completion rates]
Recurring theme detected: "Testing gaps" (4/6 sprints)
Recommendation: Schedule focused testing improvement sprint
```
