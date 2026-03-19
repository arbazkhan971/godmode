---
name: estimate
description: |
  Effort estimation skill. Activates when a developer or team needs to estimate the effort, complexity, and risk of tasks, features, or projects. Provides complexity analysis, historical data-based estimation, risk factor assessment, confidence intervals instead of point estimates, and sprint planning assistance. Uses evidence-based estimation techniques including reference class forecasting, three-point estimation, and complexity decomposition. Triggers on: /godmode:estimate, "how long will this take", "estimate this feature", "sprint planning", "story points", "size this task", or when planning requires effort forecasts.
---

# Estimate -- Effort Estimation & Complexity Analysis

## When to Activate
- User invokes `/godmode:estimate`
- User says "how long will this take", "estimate this feature"
- User says "sprint planning", "story points", "size this task"
- User says "how complex is this", "can we do this in a sprint"
- User needs to estimate a feature, bug fix, migration, or refactoring
- Sprint planning requires sizing for a backlog of tasks
- Stakeholders need timeline projections for a project
- User says "is this a 1-day or 1-week task"

## Workflow

### Step 1: Understand What Is Being Estimated
Gather context about the task, feature, or project:

```
ESTIMATION CONTEXT:
+---------------------------------------------------------+
|  Task:            <description of work to estimate>      |
|  Type:            <feature | bug fix | refactoring |     |
|                    migration | infrastructure | research> |
|  Scope:           <single file | module | cross-cutting  |
|                    | full system | greenfield>            |
|  Requester:       <developer | PM | stakeholder>        |
|  Purpose:         <sprint planning | roadmap |           |
|                    staffing | commitment>                 |
+---------------------------------------------------------+
|  Codebase context (if applicable):                       |
|    Language/Framework: <detected>                         |
|    Module(s) affected: <paths>                           |
|    Test coverage:      <percentage of affected modules>  |
|    Code familiarity:   <expert | familiar | unfamiliar   |
|                         | legacy | unknown>               |
|    Dependencies:       <other teams, services, APIs>     |
+---------------------------------------------------------+
```

If the task is vague: "This task description is too vague for a reliable estimate. Before estimating, I need to understand: [specific questions]. Shall I help decompose this first with /godmode:plan?"

### Step 2: Complexity Analysis
Analyze the task across multiple complexity dimensions:

```
COMPLEXITY ANALYSIS:
+---------------------------------------------------------+
|  Dimension             | Rating  | Evidence               |
|  --------------------------------------------------------|
|  Code complexity       | LOW     | Single module, clear   |
|                        | MEDIUM  | Multiple modules,      |
|                        |         | some coupling           |
|                        | HIGH    | Cross-cutting, complex  |
|                        |         | state management        |
|  --------------------------------------------------------|
|  Domain complexity     | LOW     | Well-understood domain  |
|                        | MEDIUM  | Some ambiguity in rules |
|                        | HIGH    | Novel domain, complex   |
|                        |         | business logic          |
|  --------------------------------------------------------|
|  Technical uncertainty | LOW     | Known tech, clear path  |
|                        | MEDIUM  | Some unknowns, may need |
|                        |         | spikes or research      |
|                        | HIGH    | New tech, unproven      |
|                        |         | approach, R&D needed    |
|  --------------------------------------------------------|
|  Integration complexity| LOW     | No external deps        |
|                        | MEDIUM  | 1-2 service integrations|
|                        | HIGH    | Multiple services, APIs,|
|                        |         | cross-team coordination |
|  --------------------------------------------------------|
|  Testing complexity    | LOW     | Unit tests sufficient   |
|                        | MEDIUM  | Integration tests needed|
|                        | HIGH    | E2E, performance, or    |
|                        |         | manual testing required |
|  --------------------------------------------------------|
|  Deployment complexity | LOW     | Standard deploy         |
|                        | MEDIUM  | Feature flags, migration|
|                        | HIGH    | Zero-downtime, multi-   |
|                        |         | phase rollout           |
+---------------------------------------------------------+
|  OVERALL COMPLEXITY:   <LOW | MEDIUM | HIGH | VERY HIGH> |
+---------------------------------------------------------+
```

Complexity scoring:
```
LOW across all dimensions:      OVERALL = LOW
Any MEDIUM, no HIGH:            OVERALL = MEDIUM
1-2 HIGH dimensions:            OVERALL = HIGH
3+ HIGH dimensions:             OVERALL = VERY HIGH
```

### Step 3: Risk Factor Assessment
Identify factors that could increase effort beyond the base estimate:

```
RISK FACTORS:
+---------------------------------------------------------+
|  Risk                          | Impact | Probability    |
|  --------------------------------------------------------|
|  Unclear requirements          | +50%   | <LOW/MED/HIGH> |
|  Legacy code / no tests        | +30%   | <LOW/MED/HIGH> |
|  External dependency delays    | +40%   | <LOW/MED/HIGH> |
|  Technology unfamiliarity      | +25%   | <LOW/MED/HIGH> |
|  Cross-team coordination       | +30%   | <LOW/MED/HIGH> |
|  Data migration required       | +50%   | <LOW/MED/HIGH> |
|  Performance requirements      | +20%   | <LOW/MED/HIGH> |
|  Security/compliance review    | +15%   | <LOW/MED/HIGH> |
|  Scope creep potential         | +40%   | <LOW/MED/HIGH> |
|  Production incident risk      | +20%   | <LOW/MED/HIGH> |
+---------------------------------------------------------+
|  Total risk adjustment:        +<N>%                     |
|  Risk-adjusted multiplier:     <1.0x - 2.5x>            |
+---------------------------------------------------------+
```

Risk multiplier calculation:
```
For each risk factor:
  If probability HIGH:   Add full impact percentage
  If probability MEDIUM: Add half impact percentage
  If probability LOW:    Add zero

Risk multiplier = 1.0 + (sum of adjusted impacts / 100)

Example:
  Unclear requirements:     HIGH  -> +50%
  Legacy code:              MEDIUM -> +15%
  External deps:            LOW   -> +0%
  Total adjustment: +65%
  Risk multiplier: 1.65x
```

### Step 4: Three-Point Estimation
Never give a single number. Always provide a range with confidence intervals:

```
THREE-POINT ESTIMATE:
+---------------------------------------------------------+
|  Scenario     | Duration | Conditions                    |
|  --------------------------------------------------------|
|  Optimistic   | <time>   | Everything goes right.        |
|  (best case)  |          | No surprises, familiar code,  |
|               |          | clear requirements, no blockers|
|  --------------------------------------------------------|
|  Most likely  | <time>   | Normal conditions. Some minor  |
|               |          | issues, clarifications needed, |
|               |          | typical review/iteration cycles|
|  --------------------------------------------------------|
|  Pessimistic  | <time>   | Things go wrong. Unclear reqs, |
|  (worst case) |          | legacy complications, external |
|               |          | delays, rework needed          |
+---------------------------------------------------------+
|                                                          |
|  PERT estimate: (O + 4*M + P) / 6 = <weighted average>  |
|  Standard deviation: (P - O) / 6 = <uncertainty range>   |
|                                                          |
|  Confidence intervals:                                   |
|    68% confident: PERT +/- 1 SD = <range>               |
|    90% confident: PERT +/- 1.645 SD = <range>           |
|    95% confident: PERT +/- 2 SD = <range>               |
+---------------------------------------------------------+
```

Example:
```
THREE-POINT ESTIMATE: User authentication feature
  Optimistic:   3 days  (clear spec, familiar with auth libraries)
  Most likely:  5 days  (some edge cases, OAuth integration)
  Pessimistic:  10 days (provider issues, security review cycles)

  PERT estimate: (3 + 4*5 + 10) / 6 = 5.5 days
  Standard deviation: (10 - 3) / 6 = 1.17 days

  Confidence intervals:
    68% confident: 4.3 - 6.7 days
    90% confident: 3.6 - 7.4 days
    95% confident: 3.2 - 7.8 days

  Recommendation: Commit to 7 days (90% confidence)
```

### Step 5: Task Decomposition for Accuracy
Break large tasks into smaller, more estimable pieces:

```
TASK DECOMPOSITION:
+---------------------------------------------------------+
|  Parent task: <feature description>                      |
|  Overall estimate: <range>                               |
+---------------------------------------------------------+
|  # | Subtask                    | Estimate | Confidence  |
|  --------------------------------------------------------|
|  1 | Design / spike             | 0.5 days | HIGH        |
|  2 | Database schema changes    | 0.5 days | HIGH        |
|  3 | Backend API endpoints      | 2 days   | MEDIUM      |
|  4 | Frontend components        | 1.5 days | MEDIUM      |
|  5 | Integration and wiring     | 1 day    | MEDIUM      |
|  6 | Tests (unit + integration) | 1.5 days | HIGH        |
|  7 | Code review + iteration    | 1 day    | HIGH        |
|  8 | QA and bug fixes           | 1 day    | LOW         |
+---------------------------------------------------------+
|  Sum of subtasks:      9 days                            |
|  Overhead multiplier:  1.2x (meetings, context switching)|
|  Adjusted total:       10.8 days                         |
|  Risk-adjusted:        10.8 * 1.3 = 14 days             |
|  Rounded:              ~3 weeks (2.5 to 3.5 weeks)      |
+---------------------------------------------------------+
```

Decomposition rules:
```
IF task estimate > 5 days:
  MUST decompose into subtasks

IF any subtask estimate > 3 days:
  MUST decompose that subtask further

IF subtask has LOW confidence:
  ADD spike/research task before it
  INCREASE pessimistic estimate

IF task requires cross-team work:
  ADD coordination overhead (0.5-1 day per team)
```

### Step 6: Reference Class Forecasting
Compare against historical data when available:

```
REFERENCE CLASS COMPARISON:
+---------------------------------------------------------+
|  This task is most similar to:                           |
|                                                          |
|  1. <Past task A> — took <N> days                        |
|     Similarity: <why similar>                            |
|     Differences: <key differences>                       |
|                                                          |
|  2. <Past task B> — took <N> days                        |
|     Similarity: <why similar>                            |
|     Differences: <key differences>                       |
|                                                          |
|  3. <Past task C> — took <N> days                        |
|     Similarity: <why similar>                            |
|     Differences: <key differences>                       |
+---------------------------------------------------------+
|  Historical average for this class: <N> days             |
|  Historical range: <min> - <max> days                    |
|  Adjustment for this specific task: +/- <N> days         |
+---------------------------------------------------------+
```

If no historical data:
```
NO HISTORICAL DATA AVAILABLE.
Using analogous estimation:
  - Similar tasks in other projects typically take <range>
  - Industry benchmarks for this type of work: <range>
  - Recommendation: Add 30% buffer for first-time estimation
```

### Step 7: Sprint Planning Assistance

For sprint planning sessions with multiple tasks:

```
SPRINT PLANNING:
+---------------------------------------------------------+
|  Sprint:          <sprint name/number>                   |
|  Duration:        <N> days (N business days)             |
|  Team capacity:   <N> developer-days                     |
|                   (<N> developers * <N> days * 0.8 focus)|
+---------------------------------------------------------+
|                                                          |
|  CAPACITY CALCULATION:                                   |
|  Developers:      <N>                                    |
|  Sprint days:     <N>                                    |
|  Focus factor:    80% (meetings, reviews, interruptions) |
|  PTO/holidays:    <N> days deducted                      |
|  Available:       <N> developer-days                     |
+---------------------------------------------------------+

TASK SIZING:
+---------------------------------------------------------+
|  # | Task                    | Points | Days | Risk      |
|  --------------------------------------------------------|
|  1 | <task description>      | <N>    | <N>  | LOW       |
|  2 | <task description>      | <N>    | <N>  | MEDIUM    |
|  3 | <task description>      | <N>    | <N>  | HIGH      |
|  4 | <task description>      | <N>    | <N>  | LOW       |
|  ...                                                     |
+---------------------------------------------------------+
|  Total points: <N>                                       |
|  Total days:   <N> developer-days                        |
|  Capacity:     <N> developer-days                        |
|  Load:         <N>% (target: 70-80%)                     |
+---------------------------------------------------------+
|  Recommendation:                                         |
|  <FITS | TIGHT | OVERLOADED>                             |
|  <specific advice>                                       |
+---------------------------------------------------------+
```

#### Story Point Reference
```
STORY POINT SCALE:
+---------------------------------------------------------+
|  Points | Effort          | Example                       |
|  --------------------------------------------------------|
|  1      | Hours           | Fix a typo, update a config   |
|  2      | Half day        | Add a field, write a test     |
|  3      | 1 day           | New API endpoint, component   |
|  5      | 2-3 days        | Feature with multiple files   |
|  8      | 1 week          | Complex feature, integration  |
|  13     | 2 weeks         | Large feature, multiple       |
|         |                 | services involved             |
|  21     | 3+ weeks        | Epic — should be decomposed   |
+---------------------------------------------------------+
|                                                          |
|  IF points > 13: MUST decompose into smaller tasks       |
|  IF points uncertain: ADD spike task (1-2 points) first  |
+---------------------------------------------------------+
```

### Step 8: Estimation Report

```
EFFORT ESTIMATE:
+---------------------------------------------------------+
|  Task:          <description>                            |
|  Type:          <feature | bug | refactoring | etc.>     |
|  Complexity:    <LOW | MEDIUM | HIGH | VERY HIGH>        |
+---------------------------------------------------------+
|  Estimate:                                               |
|    Best case:     <N> days                               |
|    Most likely:   <N> days                               |
|    Worst case:    <N> days                               |
|    PERT:          <N> days                               |
+---------------------------------------------------------+
|  Confidence intervals:                                   |
|    68% confident: <range>                                |
|    90% confident: <range>                                |
+---------------------------------------------------------+
|  Risk factors:                                           |
|    - <risk 1> (impact: <N>%, probability: <level>)       |
|    - <risk 2> (impact: <N>%, probability: <level>)       |
|  Risk multiplier: <N>x                                   |
+---------------------------------------------------------+
|  Recommendation:                                         |
|    Commit to <N> days (<confidence>% confidence)         |
|    Decompose into <N> subtasks                           |
|    Spike needed for: <unknowns, if any>                  |
+---------------------------------------------------------+
```

Commit: estimates are not committed to git (they are planning artifacts).

## Key Behaviors

1. **Never give a single number.** Effort estimates are inherently uncertain. Always provide a range with confidence intervals. A single number creates false precision and sets up either the team or the stakeholder for disappointment.
2. **Decompose to improve accuracy.** Large tasks are impossible to estimate accurately. Break them into subtasks of 1-3 days each. The sum of small estimates is more accurate than one large estimate.
3. **Risk factors are multiplicative, not additive.** Unclear requirements AND legacy code AND external dependencies do not add up linearly. They compound. A task with three risk factors takes longer than the sum suggests.
4. **Confidence decreases with time horizon.** A 2-day estimate has high confidence. A 2-month estimate has low confidence. For anything over 2 weeks, express the estimate as a range, not a number.
5. **Historical data beats intuition.** If similar tasks have historically taken 2 weeks, your "5-day optimistic estimate" is wrong. Use reference class forecasting to anchor estimates in reality.
6. **Account for overhead.** Developers spend 60-80% of their time writing code. The rest is meetings, code review, context switching, and interruptions. Apply a focus factor (typically 0.7-0.8) to raw estimates.
7. **Spikes reduce uncertainty.** If a task has HIGH technical uncertainty, do not estimate it. Instead, create a time-boxed spike (0.5-1 day) to reduce uncertainty, then estimate the actual work.
8. **Estimates are not commitments.** An estimate says "this is our best forecast." A commitment says "we will deliver by this date." These are different things. Be explicit about which one is being asked for.

## Example Usage

### Estimating a single feature
```
User: /godmode:estimate How long will it take to add OAuth login?

Estimate: Analyzing task...

COMPLEXITY ANALYSIS:
  Code complexity:       MEDIUM (auth module + middleware)
  Domain complexity:     LOW (well-understood OAuth flow)
  Technical uncertainty: LOW (using proven library: passport.js)
  Integration complexity: MEDIUM (Google + GitHub providers)
  Testing complexity:    MEDIUM (integration tests needed)
  Deployment complexity: LOW (feature flag rollout)
  OVERALL: MEDIUM

RISK FACTORS:
  Provider API changes:     LOW  (+0%)
  Session management edge cases: MEDIUM (+10%)
  Security review:          HIGH (+15%)
  Risk multiplier: 1.25x

THREE-POINT ESTIMATE:
  Optimistic:   3 days
  Most likely:  5 days
  Pessimistic:  8 days
  PERT:         5.2 days

  Confidence intervals:
    68% confident: 4.3 - 6.0 days
    90% confident: 3.8 - 6.5 days

  Recommendation: Commit to 6 days (90% confidence)

DECOMPOSITION:
  1. OAuth provider setup + config:     0.5 days
  2. Login/callback endpoints:          1 day
  3. Session management:                1 day
  4. Account linking (existing users):  1 day
  5. Tests (unit + integration):        1 day
  6. Code review + security review:     1 day
  Total: 5.5 days * 1.25x risk = ~7 days
```

### Sprint planning
```
User: /godmode:estimate Sprint planning — size these 6 tasks for our 2-week sprint

Estimate: Analyzing tasks for sprint planning...

SPRINT CAPACITY:
  Developers:    3
  Sprint days:   10
  Focus factor:  80%
  PTO:           2 days (Alice out Monday-Tuesday)
  Available:     22 developer-days

TASK SIZING:
  # | Task                         | Points | Days | Risk
  1 | Add OAuth login               | 8      | 6    | LOW
  2 | Fix pagination bug            | 2      | 0.5  | LOW
  3 | Migrate to new email service  | 5      | 3    | MEDIUM
  4 | Dashboard redesign            | 8      | 5    | MEDIUM
  5 | Add export to CSV             | 3      | 1.5  | LOW
  6 | Database index optimization   | 3      | 1    | LOW

  Total: 29 points / 17 developer-days
  Capacity: 22 developer-days
  Load: 77% (within target 70-80%)

  RECOMMENDATION: FITS
  All 6 tasks fit within sprint capacity with 23% buffer.
  Suggest pulling in 1 more small task (2-3 points) or
  keeping buffer for unexpected work.
```

### Quick sizing
```
User: /godmode:estimate Is this a 1-day or 1-week task: add rate limiting to our API

Estimate: Quick assessment...

QUICK ESTIMATE:
  If using existing middleware (express-rate-limit):
    1-2 days (SMALL) — configure middleware, add tests, deploy
  If building custom rate limiting (Redis-based):
    4-6 days (MEDIUM) — design, implement, test, monitor
  If distributed rate limiting across microservices:
    8-12 days (LARGE) — architecture, shared state, consistency

  Most likely scenario: existing middleware
  Estimate: 2 days (90% confidence)
  Suggestion: Start with middleware, upgrade to custom if needed
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive estimation for a single task |
| `--sprint` | Sprint planning mode — size multiple tasks against capacity |
| `--quick` | Quick t-shirt sizing (S/M/L/XL) |
| `--decompose` | Decompose task into subtasks with individual estimates |
| `--risk` | Risk factor analysis only |
| `--compare <task>` | Reference class comparison against similar past tasks |
| `--capacity <N>` | Set team capacity in developer-days |
| `--confidence <N>` | Set target confidence level (default: 90%) |
| `--points` | Output in story points instead of days |
| `--batch` | Estimate multiple tasks at once |

## Anti-Patterns

- **Do NOT give a single point estimate.** "It will take 5 days" is false precision. "It will take 3-8 days, most likely 5" is honest. Stakeholders who demand a single number get the pessimistic end of the range.
- **Do NOT estimate without understanding the codebase.** An estimate for "add a feature" is meaningless without knowing the code's state: test coverage, complexity, dependencies, and technical debt all affect effort.
- **Do NOT estimate tasks larger than 2 weeks without decomposing.** Anything over 2 weeks has too much uncertainty for a single estimate. Decompose into 1-3 day subtasks and estimate each one.
- **Do NOT ignore overhead.** A developer does not write code 8 hours a day. Apply an 80% focus factor minimum. For senior developers with many meetings, use 60-70%.
- **Do NOT conflate estimates with commitments.** An estimate is a forecast with uncertainty. A commitment is a promise. When a stakeholder asks "when will it be done?", clarify: "I can estimate a range with confidence intervals, or I can commit to a specific date with appropriate buffer."
- **Do NOT anchor on the first number you think of.** Anchoring bias makes initial estimates sticky. Instead, analyze complexity, identify risks, decompose, and THEN produce the estimate systematically.
- **Do NOT pad estimates silently.** If you add buffer for risk, say so explicitly. "5 days plus 2 days buffer for legacy code risk" is transparent. "7 days" without explanation erodes trust when the work finishes in 5.
- **Do NOT re-estimate mid-sprint.** If a task is taking longer than estimated, that is useful data for future estimates. Do not revise the original estimate to match reality — that destroys the calibration feedback loop.
- **Do NOT skip the spike.** If technical uncertainty is HIGH, spending 4 hours on a spike is cheaper than being wrong by a factor of 3x on a 2-week estimate.
