---
name: prioritize
description: |
  Task prioritization skill using structured frameworks. Supports ICE/RICE scoring, MoSCoW prioritization, effort-vs-impact matrices, dependency-aware scheduling, and technical debt vs feature trade-offs. Triggers on: /godmode:prioritize, "what should I work on next", "prioritize backlog", "rank these tasks", "effort vs impact", or when multiple competing work items need ordering.
---

# Prioritize — Task Prioritization

## When to Activate
- User invokes `/godmode:prioritize`
- User asks "what should I work on next", "which task is most important", "rank these"
- User has a backlog of items that need ordering
- User needs to decide between features and technical debt
- Sprint planning requires prioritized input
- User is overwhelmed with competing priorities and needs a framework

## Workflow

### Step 1: Inventory Work Items

Collect all items that need prioritization:

1. **From issue tracker** — Open issues, backlog items, feature requests
2. **From git** — Open branches, stale PRs, TODO/FIXME comments in code
3. **From retro actions** — Pending action items from retrospectives
4. **From user input** — Manually provided tasks or ideas
5. **From dependencies** — Blocked/blocking relationships between items

```
WORK ITEM INVENTORY:
Source          | Items | Categories
----------------|-------|------------------------------------------
Issue Tracker   | <N>   | features, bugs, improvements, chores
Git TODOs       | <N>   | technical debt, cleanup, refactoring
Retro Actions   | <N>   | process improvements, tooling
User Input      | <N>   | new ideas, requests
Blocked Items   | <N>   | items waiting on dependencies

Total Items: <N>
```

### Step 2: Choose Prioritization Framework

Select the appropriate framework based on context:

**Framework 1: RICE Scoring**
Best for: Product features and large backlogs. Quantitative and comparable.

```
RICE SCORE = (Reach x Impact x Confidence) / Effort

Component     | Scale         | Description
--------------|---------------|----------------------------------
Reach         | # of users    | How many users will this affect per quarter?
Impact        | 0.25-3        | 3=massive, 2=high, 1=medium, 0.5=low, 0.25=minimal
Confidence    | 0-100%        | How confident are we in reach/impact estimates?
Effort        | person-weeks  | How many person-weeks to implement?
```

**Framework 2: ICE Scoring**
Best for: Quick prioritization of small to medium items. Simpler than RICE.

```
ICE SCORE = Impact x Confidence x Ease

Component     | Scale (1-10) | Description
--------------|-------------|----------------------------------
Impact        | 1-10        | How much will this move the needle?
Confidence    | 1-10        | How sure are we about the impact?
Ease          | 1-10        | How easy is this to implement? (10=trivial)
```

**Framework 3: MoSCoW**
Best for: Release planning and scope negotiation. Categorical, not numerical.

```
Category      | Definition                              | Rule
--------------|-----------------------------------------|---------------------------
MUST have     | Non-negotiable for this release          | Max 60% of capacity
SHOULD have   | Important but not critical               | Next 20% of capacity
COULD have    | Nice to have, included if time permits   | Next 20% of capacity
WON'T have    | Explicitly out of scope this time        | Documented for future
```

**Framework 4: Effort vs Impact Matrix**
Best for: Visual prioritization and quick triage. Two-dimensional.

```
                    HIGH IMPACT
                        |
    Quick Wins          |     Big Bets
    (DO FIRST)          |     (PLAN CAREFULLY)
                        |
  LOW EFFORT -----------+------------ HIGH EFFORT
                        |
    Fill-Ins            |     Money Pit
    (DO IF TIME)        |     (AVOID OR DESCOPE)
                        |
                    LOW IMPACT
```

Default selection logic:
- Backlog > 20 items -> RICE (quantitative comparison at scale)
- Backlog 5-20 items -> ICE (quick scoring)
- Release planning -> MoSCoW (categorical scope)
- Quick triage -> Effort vs Impact matrix

### Step 3: Score and Rank Items

Apply the chosen framework to all work items:

**RICE Example:**
```
RICE PRIORITIZATION:
Rank | Item                        | Reach | Impact | Confidence | Effort | RICE Score
-----|-----------------------------| ------|--------|------------|--------|-----------
  1  | Add search functionality    | 5000  | 2      | 80%        | 3 wks  | 2667
  2  | Fix checkout timeout        | 3000  | 3      | 90%        | 1 wk   | 8100
  3  | Dashboard redesign          | 2000  | 1      | 60%        | 4 wks  | 300
  4  | Add dark mode               | 4000  | 0.5    | 70%        | 2 wks  | 700
  ...

Note: Item 2 scores highest despite lower reach because of high impact and low effort.
```

**MoSCoW Example:**
```
MoSCoW PRIORITIZATION:
Category   | Items                                    | Est. Effort | Capacity Used
-----------|------------------------------------------|-------------|---------------
MUST       | Auth fixes, Payment flow, Core API       | 15 pts      | 50%
SHOULD     | Search, Notifications                    | 8 pts       | 27%
COULD      | Dark mode, Dashboard redesign            | 7 pts       | 23%
WON'T      | Mobile app, AI features                  | 20 pts      | (next release)

Total capacity: 30 points
MUST items fit within 60% rule: YES (50%)
```

**Effort vs Impact Matrix Example:**
```
EFFORT VS IMPACT MATRIX:
Quadrant    | Items                              | Action
------------|------------------------------------|--------------------------
Quick Wins  | Fix N+1 query, Add caching headers | DO FIRST (this sprint)
Big Bets    | Search rewrite, Auth overhaul      | PLAN (next 2 sprints)
Fill-Ins    | Update README, Fix typos           | DO IF TIME (end of sprint)
Money Pit   | Full rewrite of legacy module      | AVOID (find incremental path)
```

### Step 4: Dependency-Aware Scheduling

After scoring, adjust ordering based on dependencies:

```
DEPENDENCY ANALYSIS:
Item                    | Depends On          | Blocks           | Adjusted Priority
------------------------|---------------------|------------------|------------------
Core API refactor       | (none)              | Search, Payments | ELEVATED (unblocks 2)
Search functionality    | Core API refactor   | (none)           | HELD (blocked)
Payment flow            | Core API refactor   | Checkout         | HELD (blocked)
Auth fixes              | (none)              | (none)           | UNCHANGED
Fix checkout timeout    | Payment flow        | (none)           | HELD (transitively blocked)

RECOMMENDED ORDER:
1. Auth fixes (no dependencies, high RICE)
2. Core API refactor (unblocks 2 items)
3. Payment flow (unblocked by #2)
4. Search functionality (unblocked by #2)
5. Fix checkout timeout (unblocked by #3)

Critical Path: Core API -> Payment flow -> Checkout timeout
Parallel Track: Auth fixes (independent), Search (after Core API)
```

Scheduling rules:
- Items that unblock multiple others get priority bumps
- Items on the critical path are scheduled first
- Independent items can be parallelized
- Blocked items are not scheduled until blockers are resolved

### Step 5: Technical Debt vs Feature Trade-off

When the backlog contains both features and technical debt, apply the debt ratio framework:

```
TECH DEBT VS FEATURE ANALYSIS:

Current State:
- Feature items: <N> (<total_points> points)
- Tech debt items: <N> (<total_points> points)
- Current debt ratio: <percent>% of backlog is debt

Recommended Allocation:
Debt Level  | Debt Ratio | Recommended Split        | Reasoning
------------|------------|--------------------------|---------------------------
Low (<15%)  | <15%       | 80% features / 20% debt  | Debt under control
Medium      | 15-30%     | 70% features / 30% debt  | Active debt management
High        | 30-50%     | 50% features / 50% debt  | Debt is slowing delivery
Critical    | >50%       | 30% features / 70% debt  | Debt is blocking features

Current recommendation: <split>

HIGH-VALUE DEBT ITEMS (pay off first):
1. <debt item> — Blocks <N> features, saves <time> per sprint
2. <debt item> — Reduces bug rate by <estimate>
3. <debt item> — Improves build time by <estimate>

LOW-VALUE DEBT ITEMS (defer):
1. <debt item> — Cosmetic, no feature impact
2. <debt item> — Rarely touched code path
```

Debt prioritization factors:
- **Interest rate** — How much slower does this debt make us each sprint?
- **Feature blocking** — Does this debt prevent new feature work?
- **Risk** — Is this debt a ticking time bomb (security, data integrity)?
- **Compound effects** — Does paying this debt make other debt easier to pay?

### Step 6: Generate Prioritized Backlog

Produce the final prioritized output:

```markdown
# Prioritized Backlog — <date>

## Framework: <RICE | ICE | MoSCoW | Effort-Impact>
## Sprint Capacity: <N> points
## Debt Allocation: <split>

### Sprint Candidates (fits in capacity)
| Priority | Item | Score | Effort | Type | Dependencies |
|----------|------|-------|--------|------|-------------|
| 1 | <item> | <score> | <pts> | feature | none |
| 2 | <item> | <score> | <pts> | debt | none |
| 3 | <item> | <score> | <pts> | feature | depends on #1 |

### Next Sprint (overflow)
| Priority | Item | Score | Effort | Type | Dependencies |
|----------|------|-------|--------|------|-------------|
| 4 | <item> | <score> | <pts> | feature | none |
| 5 | <item> | <score> | <pts> | debt | none |

### Explicitly Deferred
| Item | Reason |
|------|--------|
| <item> | Low impact, high effort (Money Pit) |
| <item> | Dependencies not ready until Q3 |
```

Save to `docs/priorities/<date>-backlog.md` and commit.

## Auto-Detection

Before prompting the user, automatically discover work items:

```
AUTO-DETECT SEQUENCE:
1. Scan issue tracker:
   - GitHub Issues: gh issue list --state open --json number,title,labels,assignees
   - Linear: check for .linear/ config or LINEAR_API_KEY
   - Jira: check for JIRA_URL in env or .jira/ config
2. Scan git for work signals:
   - Open branches not merged to main: git branch --no-merged main
   - Stale PRs: gh pr list --state open --json number,title,createdAt
   - TODO/FIXME/HACK comments: grep -rn "TODO\|FIXME\|HACK" src/
3. Detect sprint context:
   - Current sprint from issue tracker metadata
   - Team velocity from recent sprint history
   - Capacity: number of developers x sprint length
4. Detect dependency relationships:
   - Issue links (blocks/blocked-by) from issue tracker
   - Branch dependency chains (stacked branches)
5. Classify items automatically:
   - Label "bug" or branch prefix "fix/" -> bug fix
   - Label "enhancement" or "feat/" -> feature
   - TODO/FIXME in code -> technical debt
   - Label "docs" or "*.md" changes -> documentation
```

## Explicit Loop Protocol

For iterative scoring and re-prioritization:

```
PRIORITIZATION LOOP:
current_iteration = 0
max_iterations = 3
items = collect_all_work_items()

WHILE current_iteration < max_iterations:
  current_iteration += 1

  1. SCORE all items using selected framework:
     - Apply RICE/ICE/MoSCoW/Matrix to each item
     - Record raw scores

  2. ADJUST for dependencies:
     - Identify blocking/blocked relationships
     - Bump items that unblock multiple others
     - Defer items that are transitively blocked

  3. ADJUST for debt ratio:
     - Calculate current tech debt percentage
     - Apply recommended feature/debt split
     - Ensure debt items fill their allocated capacity

  4. VALIDATE with constraints:
     - Total estimated effort <= sprint capacity?
     - Critical path identified?
     - No circular dependencies?
     - Separation of concerns (no two risky items in same sprint)?

  5. EVALUATE:
     - IF all constraints satisfied: STOP — emit final backlog
     - IF capacity exceeded: remove lowest-priority item, re-iterate
     - IF dependency conflict: reorder and re-iterate

  OUTPUT: Ranked backlog with scores, dependencies, and capacity fit
```

## HARD RULES

```
HARD RULES — NEVER VIOLATE:
1. NEVER prioritize without a named framework (RICE, ICE, MoSCoW, or Matrix).
2. NEVER commit to more effort than sprint capacity allows.
3. NEVER schedule a blocked item before its blocker.
4. NEVER defer ALL technical debt — allocate minimum 20% capacity to debt.
5. ALWAYS include confidence scores — high impact + low confidence = risky.
6. ALWAYS show the scoring math — no hidden judgments.
7. ALWAYS identify the critical path and call it out explicitly.
8. NEVER prioritize a single sprint in isolation — show the next sprint overflow.
9. ALWAYS re-prioritize when new information arrives (scope change, bug, outage).
10. NEVER rank items by gut feeling and present it as data-driven.
```

## Key Behaviors

1. **Frameworks over gut feeling.** Every prioritization uses a named framework. "I think this is important" is not a priority — a RICE score of 2667 is.
2. **Dependencies change everything.** A low-priority item that unblocks three high-priority items is itself high priority. Always map dependencies.
3. **Technical debt is not optional.** Ignoring debt is borrowing from future velocity. Allocate based on current debt ratio, not wishful thinking.
4. **Capacity is finite.** Prioritization means saying no. Every "yes" to one item is an implicit "not yet" to another. Make the trade-off explicit.
5. **Re-prioritize regularly.** Priorities change as context changes. A weekly or per-sprint re-prioritization keeps the backlog honest.
6. **Show your work.** Include the scores, the framework, and the reasoning. A prioritized list without rationale is just someone's opinion.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Auto-select framework and prioritize all work items |
| `--framework <type>` | Choose framework: `rice`, `ice`, `moscow`, `matrix` |
| `--capacity <N>` | Set sprint capacity in points |
| `--debt` | Show technical debt vs feature trade-off analysis |
| `--deps` | Show dependency graph and critical path |
| `--top <N>` | Show only top N priorities |
| `--compare` | Compare current vs previous prioritization |
| `--export <format>` | Export as `markdown` (default), `csv`, `json` |
| `--items <list>` | Provide items inline instead of from issue tracker |

## Anti-Patterns

- **Do NOT prioritize without a framework.** "This feels urgent" is not prioritization. Urgency and importance are different axes.
- **Do NOT ignore dependencies.** A perfectly scored backlog that ignores blocking relationships will deadlock the sprint.
- **Do NOT defer all technical debt.** Debt compounds. The longer you wait, the more expensive it gets. Allocate capacity every sprint.
- **Do NOT score items without confidence levels.** High impact with low confidence should rank below medium impact with high confidence.
- **Do NOT exceed capacity.** Committing to 40 points when capacity is 30 is not ambition — it's scope creep dressed as optimism.
- **Do NOT prioritize once and forget.** Re-run prioritization each sprint as new information arrives.

## Chaining

- `/godmode:prioritize` -> `/godmode:plan` (plan the top-priority items)
- `/godmode:prioritize` -> `/godmode:scope` (scope out the highest-priority feature)
- `/godmode:prioritize --debt` -> `/godmode:refactor` (tackle high-value debt)
- `/godmode:standup --velocity` -> `/godmode:prioritize --capacity <velocity>` (use velocity for capacity)
- `/godmode:retro --actions` -> `/godmode:prioritize` (prioritize retro action items)

## Example Usage

### Quick RICE scoring
```
User: /godmode:prioritize --framework rice

Prioritize: Collecting work items from issue tracker and git...

Found 18 items. Applying RICE scoring...

RICE PRIORITIZATION:
Rank | Item                        | Reach | Impact | Confidence | Effort | Score
-----|-----------------------------| ------|--------|------------|--------|------
  1  | Fix checkout timeout        | 3000  | 3      | 90%        | 1 wk   | 8100
  2  | Add search functionality    | 5000  | 2      | 80%        | 3 wks  | 2667
  3  | Add dark mode               | 4000  | 0.5    | 70%        | 2 wks  | 700
  ...

Sprint capacity: 30 pts
Recommended: Items 1-4 (28 pts, 93% capacity)
```

### MoSCoW for release planning
```
User: /godmode:prioritize --framework moscow --capacity 40

Prioritize: Categorizing items for release...

MUST (24 pts, 60%): Auth, Payments, Core API
SHOULD (8 pts, 20%): Search, Notifications
COULD (8 pts, 20%): Dark mode, Dashboard
WON'T (20 pts, deferred): Mobile app, AI features
```

### Technical debt analysis
```
User: /godmode:prioritize --debt

Prioritize: Analyzing tech debt ratio...

Debt ratio: 35% (HIGH)
Recommended: 50% features / 50% debt this sprint

Top debt items to pay off:
1. N+1 query in user list — saves 200ms/request, affects 5000 users/day
2. Legacy auth middleware — blocks OAuth2 feature (MUST have)
3. Missing database indexes — 3 slow queries in dashboard
```
