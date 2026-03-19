---
name: pm
description: |
  Product management skill. Covers the full PM lifecycle: PRD creation, user story writing with acceptance criteria, feature prioritization (RICE, MoSCoW, ICE), sprint planning, backlog grooming, competitive analysis, OKR/KPI definition, go-to-market planning, MVP definition, stakeholder communication, launch readiness checklists, product metrics setup, and customer feedback synthesis. Triggers on: /godmode:pm, "write a PRD", "create user stories", "prioritize features", "plan the launch", "define OKRs", "competitive analysis", "go-to-market", "sprint planning", "backlog grooming", or when product decisions need structured frameworks.
---

# PM — Product Management Workflows

## When to Activate
- User invokes `/godmode:pm`
- User says "write a PRD", "create a product spec", "product requirements"
- User says "write user stories", "acceptance criteria", "define epics"
- User says "prioritize features", "RICE score", "MoSCoW", "ICE framework"
- User says "sprint planning", "groom the backlog", "backlog refinement"
- User says "competitive analysis", "market landscape", "who are the competitors"
- User says "define OKRs", "set KPIs", "success metrics"
- User says "go-to-market plan", "GTM strategy", "launch plan"
- User says "what's the MVP", "scope the feature", "feature scoping"
- User says "stakeholder update", "executive summary", "status report"
- User says "launch checklist", "are we ready to launch"
- User says "product metrics", "analytics setup", "instrumentation plan"
- User says "customer feedback", "synthesize feedback", "user research findings"

## Workflow

### Step 1: Identify the PM Activity
Determine which product management workflow the user needs:

```
PM ACTIVITY ROUTER:
Activity               | Trigger                            | Output
-----------------------|------------------------------------|---------------------------
PRD Creation           | "write a PRD", "product spec"      | Full PRD document
User Stories           | "user stories", "acceptance crit"  | Story set with AC
Feature Prioritization | "prioritize", "RICE", "MoSCoW"    | Ranked feature list
Sprint Planning        | "sprint plan", "backlog groom"     | Sprint-ready backlog
Competitive Analysis   | "competitors", "market landscape"  | Competitive matrix
OKR/KPI Definition     | "OKRs", "KPIs", "success metrics" | OKR tree + KPI dashboard
Go-to-Market           | "GTM", "launch plan", "go-to-mkt"  | GTM strategy doc
MVP Definition         | "MVP", "minimum viable"            | MVP scope document
Stakeholder Comms      | "status update", "exec summary"    | Communication template
Launch Readiness       | "launch checklist", "ready to ship" | Launch readiness report
Product Metrics        | "analytics", "instrumentation"     | Metrics & tracking plan
Feedback Synthesis     | "customer feedback", "user research"| Insight report
```

If unclear, ask: "Which PM activity do you need? Options: PRD, user stories, prioritization, sprint planning, competitive analysis, OKRs, GTM, MVP, stakeholder comms, launch readiness, metrics, or feedback synthesis."

### Step 2: PRD Creation

Write a Product Requirements Document that engineering can build from:

```markdown
# PRD: <Feature/Product Name>

## Metadata
- **Author:** <PM name>
- **Status:** Draft | In Review | Approved | Deprecated
- **Created:** <YYYY-MM-DD>
- **Last Updated:** <YYYY-MM-DD>
- **Reviewers:** <engineering lead, design lead, stakeholders>
- **Target Release:** <version or date>

## 1. Problem Statement
<What problem are we solving? Be specific. Include evidence.>

### Who has this problem?
- **Primary users:** <persona or segment with estimated count>
- **Secondary users:** <persona or segment>

### How do we know this is a problem?
- <Evidence: support tickets, user interviews, analytics data>
- <Evidence: churn data, NPS feedback, competitive loss>
- <Evidence: quantitative metric showing the gap>

### What happens if we do nothing?
<Consequences of inaction: churn, revenue loss, competitive disadvantage>

## 2. Proposed Solution

### Overview
<2-3 sentence description of what we are building>

### User Flows
<Step-by-step user journey through the feature>

1. User navigates to <location>
2. User sees <UI element/state>
3. User performs <action>
4. System responds with <behavior>
5. User achieves <outcome>

### Detailed Requirements

#### Functional Requirements
| ID | Requirement | Priority | Notes |
|----|-------------|----------|-------|
| FR-01 | <requirement> | MUST | <context> |
| FR-02 | <requirement> | MUST | <context> |
| FR-03 | <requirement> | SHOULD | <context> |
| FR-04 | <requirement> | COULD | <context> |

#### Non-Functional Requirements
| ID | Requirement | Target | Notes |
|----|-------------|--------|-------|
| NFR-01 | Performance | <target, e.g., page load < 2s> | <context> |
| NFR-02 | Scalability | <target, e.g., 10K concurrent users> | <context> |
| NFR-03 | Availability | <target, e.g., 99.9% uptime> | <context> |
| NFR-04 | Security | <target, e.g., SOC2 compliant> | <context> |
| NFR-05 | Accessibility | <target, e.g., WCAG 2.1 AA> | <context> |

### Out of Scope
- <Explicitly excluded item 1> -- Reason: <why>
- <Explicitly excluded item 2> -- Reason: <why>

## 3. Success Metrics
| Metric | Current Baseline | Target | Measurement Method |
|--------|-----------------|--------|-------------------|
| <primary metric> | <current value> | <target value> | <how to measure> |
| <secondary metric> | <current value> | <target value> | <how to measure> |
| <guardrail metric> | <current value> | <must not regress> | <how to measure> |

## 4. Design
- **Wireframes/Mocks:** <link to Figma, design files>
- **Design Decisions:** <key design choices and rationale>
- **Edge Cases:** <what happens in unusual states: empty, error, loading, overflow>

## 5. Technical Considerations
- **Architecture Impact:** <new services, schema changes, API changes>
- **Dependencies:** <external services, internal teams, third-party APIs>
- **Migration:** <data migration needs, backward compatibility>
- **Feature Flags:** <rollout strategy, kill switch>

## 6. Timeline & Milestones
| Milestone | Date | Deliverable |
|-----------|------|-------------|
| Design Complete | <date> | Approved mocks |
| API Contract Finalized | <date> | API spec |
| MVP Build Complete | <date> | Feature behind flag |
| Internal Beta | <date> | Dogfooding |
| Public Launch | <date> | GA release |

## 7. Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| <risk> | H/M/L | H/M/L | <strategy> |

## 8. Open Questions
- [ ] <Question> -- Owner: <who> -- Deadline: <when>
- [ ] <Question> -- Owner: <who> -- Deadline: <when>

## 9. Appendix
- <Links to research, user interviews, data analysis>
- <Related PRDs, RFCs, ADRs>
```

Save to `docs/prds/<feature-name>-prd.md`.

### Step 3: User Story Writing

Generate structured user stories with acceptance criteria:

```markdown
## Epic: <Epic Name>
<1-2 sentence epic description>

### Story <ID>: <Title>
**As a** <specific user type/persona>
**I want to** <concrete action or capability>
**So that** <measurable business or user value>

**Acceptance Criteria:**
- [ ] GIVEN <precondition> WHEN <action> THEN <expected result>
- [ ] GIVEN <precondition> WHEN <action> THEN <expected result>
- [ ] GIVEN <edge case> WHEN <action> THEN <graceful handling>
- [ ] GIVEN <error condition> WHEN <action> THEN <error behavior>

**Definition of Done:**
- [ ] Code reviewed and merged
- [ ] Unit tests cover happy path and edge cases
- [ ] Integration tests pass
- [ ] Acceptance criteria verified in staging
- [ ] Analytics events instrumented
- [ ] Documentation updated (if user-facing)

**Size:** <S/M/L/XL> (<story points>)
**Priority:** <MUST / SHOULD / COULD>
**Dependencies:** <other story IDs or "none">
```

Story quality gate (INVEST + AC checklist):
```
STORY QUALITY CHECK:
Story: <title>

INVEST Criteria:
[ ] Independent  — Can be developed without other stories in progress
[ ] Negotiable   — Implementation details are flexible
[ ] Valuable     — Delivers clear user or business value
[ ] Estimable    — Team can size it with reasonable confidence
[ ] Small        — Completable within one sprint (if XL, split it)
[ ] Testable     — Acceptance criteria are specific and verifiable

Acceptance Criteria Quality:
[ ] Uses GIVEN/WHEN/THEN format consistently
[ ] Covers the happy path
[ ] Covers at least 2 edge cases
[ ] Covers at least 1 error case
[ ] Each criterion is independently testable
[ ] No ambiguous language ("fast", "user-friendly", "easy to use")

Result: PASS / NEEDS REFINEMENT
```

If a story fails the quality check, refine it before adding to the backlog.

### Step 4: Feature Prioritization

Apply structured prioritization frameworks. Choose based on context:

**RICE Scoring** -- Best for comparing features across a large backlog:
```
RICE SCORE = (Reach x Impact x Confidence) / Effort

RICE PRIORITIZATION:
Feature                   | Reach    | Impact  | Confidence | Effort   | RICE Score
--------------------------|----------|---------|------------|----------|-----------
<feature 1>               | <users/q>| <0.25-3>| <0-100%>  | <p-weeks>| <score>
<feature 2>               | <users/q>| <0.25-3>| <0-100%>  | <p-weeks>| <score>
<feature 3>               | <users/q>| <0.25-3>| <0-100%>  | <p-weeks>| <score>

Impact scale: 3=massive, 2=high, 1=medium, 0.5=low, 0.25=minimal
Confidence: 100%=data-backed, 80%=strong signal, 50%=gut feel, 20%=speculation
```

**MoSCoW** -- Best for release scoping and stakeholder negotiation:
```
MoSCoW PRIORITIZATION:
Category   | Features                                 | Effort  | Capacity
-----------|------------------------------------------|---------|----------
MUST       | <features that block the release>         | <pts>   | <=60%
SHOULD     | <features important but not blocking>     | <pts>   | ~20%
COULD      | <features included if time permits>       | <pts>   | ~20%
WON'T      | <features explicitly deferred>            | <pts>   | (next cycle)

Rule: MUST items cannot exceed 60% of total capacity. If they do, re-scope.
```

**ICE Scoring** -- Best for quick prioritization of smaller items:
```
ICE SCORE = Impact x Confidence x Ease

ICE PRIORITIZATION:
Feature                   | Impact (1-10) | Confidence (1-10) | Ease (1-10) | ICE Score
--------------------------|---------------|-------------------|-------------|----------
<feature 1>               | <score>       | <score>           | <score>     | <product>
<feature 2>               | <score>       | <score>           | <score>     | <product>
```

Output the final prioritized ranking:
```
PRIORITIZED FEATURES:
Rank | Feature              | Framework | Score  | Action
-----|----------------------|-----------|--------|----------------------------
1    | <feature>            | <method>  | <score>| Build this sprint
2    | <feature>            | <method>  | <score>| Build this sprint
3    | <feature>            | <method>  | <score>| Queue for next sprint
...  | <feature>            | <method>  | <score>| Defer / Revisit in Q<N>
```

### Step 5: Sprint Planning & Backlog Grooming

Prepare a sprint-ready backlog:

```
SPRINT PLANNING:
Sprint: <sprint number or name>
Duration: <N weeks>
Team Capacity: <N story points>
Velocity (last 3 sprints): <avg points completed>

BACKLOG GROOMING CHECKLIST:
[ ] All stories have acceptance criteria
[ ] All stories are estimated (story points)
[ ] All stories pass INVEST criteria
[ ] Dependencies between stories are mapped
[ ] No story exceeds <max_points> points (split if needed)
[ ] Tech debt allocation decided (<X>% of capacity)
[ ] Spike/research stories identified for uncertain items

SPRINT BACKLOG:
Priority | Story                       | Points | Assignee  | Dependencies | Status
---------|-----------------------------|--------|-----------|--------------|--------
1        | <story title>               | <pts>  | <person>  | none         | Ready
2        | <story title>               | <pts>  | <person>  | Story #1     | Ready
3        | <story title>               | <pts>  | <person>  | none         | Ready
4        | <story title> [TECH DEBT]   | <pts>  | <person>  | none         | Ready
5        | <story title>               | <pts>  | <person>  | Story #2     | Blocked

CAPACITY CHECK:
Total committed: <N> points
Team capacity: <M> points
Buffer (20%): <B> points
Utilization: <percent>%
Verdict: <WITHIN CAPACITY / OVER-COMMITTED / UNDER-COMMITTED>

SPRINT GOAL:
<1 sentence: what is the single most important outcome of this sprint?>
```

Grooming rules:
- Never commit to more than 80% of average velocity (keep 20% buffer for unknowns)
- Stories larger than 8 points must be split before entering the sprint
- Every sprint must include at least 1 tech debt item
- Blocked stories do not count toward committed capacity until unblocked

### Step 6: Competitive Analysis

Produce a structured competitive landscape:

```markdown
# Competitive Analysis: <Product/Feature Area>

## Date: <YYYY-MM-DD>

## Market Overview
<2-3 sentences on the market segment, size, trends>

## Competitor Matrix

| Dimension           | Our Product  | Competitor A | Competitor B | Competitor C |
|---------------------|-------------|-------------|-------------|-------------|
| **Positioning**     | <statement> | <statement> | <statement> | <statement> |
| **Target Segment**  | <segment>   | <segment>   | <segment>   | <segment>   |
| **Pricing Model**   | <model>     | <model>     | <model>     | <model>     |
| **Price Point**     | <range>     | <range>     | <range>     | <range>     |

## Feature Comparison

| Feature             | Our Product | Competitor A | Competitor B | Competitor C |
|---------------------|:-----------:|:------------:|:------------:|:------------:|
| <feature 1>         | YES/NO/PARTIAL | YES/NO/PARTIAL | YES/NO/PARTIAL | YES/NO/PARTIAL |
| <feature 2>         | YES/NO/PARTIAL | YES/NO/PARTIAL | YES/NO/PARTIAL | YES/NO/PARTIAL |
| <feature 3>         | YES/NO/PARTIAL | YES/NO/PARTIAL | YES/NO/PARTIAL | YES/NO/PARTIAL |

## SWOT vs Each Competitor

### vs Competitor A
- **Our Strengths:** <what we do better>
- **Our Weaknesses:** <where they beat us>
- **Opportunities:** <gaps we can exploit>
- **Threats:** <risks from their roadmap/momentum>

## Strategic Gaps
| Gap                      | Severity | Opportunity Size | Recommendation          |
|--------------------------|----------|-----------------|------------------------|
| <missing capability>     | H/M/L    | <revenue/users> | Build in Q<N> / Ignore |
| <inferior experience>    | H/M/L    | <revenue/users> | Improve / Deprioritize |

## Key Takeaways
1. <Insight about competitive positioning>
2. <Insight about feature gaps or opportunities>
3. <Recommended strategic response>
```

Save to `docs/competitive/<area>-competitive-analysis.md`.

### Step 7: OKR/KPI Definition

Define measurable objectives and their key results:

```markdown
# OKRs: <Quarter/Period>

## Objective 1: <Ambitious, qualitative goal>
Confidence: <percent> at start of quarter

| Key Result | Baseline | Target | Current | Status |
|------------|----------|--------|---------|--------|
| KR1: <measurable outcome> | <current> | <target> | -- | NOT STARTED |
| KR2: <measurable outcome> | <current> | <target> | -- | NOT STARTED |
| KR3: <measurable outcome> | <current> | <target> | -- | NOT STARTED |

### KPI Dashboard for Objective 1
| KPI | Definition | Source | Frequency | Owner |
|-----|-----------|--------|-----------|-------|
| <metric name> | <exact calculation> | <data source> | Daily/Weekly | <person> |
| <metric name> | <exact calculation> | <data source> | Weekly | <person> |

---

## Objective 2: <Ambitious, qualitative goal>
...
```

OKR quality checklist:
```
OKR QUALITY CHECK:
Objective: <title>

Objective Quality:
[ ] Inspiring and qualitative (not a metric)
[ ] Ambitious but achievable (60-70% confidence of hitting)
[ ] Time-bound (tied to a quarter or period)
[ ] Aligned with company/team strategy

Key Result Quality (for each KR):
[ ] Quantitative and measurable (has a number)
[ ] Has a baseline (where are we today?)
[ ] Has a target (where do we want to be?)
[ ] Outcome-based, not output-based ("reduce churn by 15%" not "ship 5 features")
[ ] Within the team's control to influence
[ ] 2-5 key results per objective (not more)

Overall:
[ ] 2-4 objectives per team per quarter (not more)
[ ] No KR appears under multiple objectives
[ ] At least 1 objective is customer-facing
```

### Step 8: Go-to-Market Planning

Build a GTM strategy for launching a feature or product:

```markdown
# Go-to-Market Plan: <Feature/Product Name>

## Launch Overview
- **Launch Date:** <date>
- **Launch Type:** <Alpha | Beta | GA | Expansion>
- **Target Audience:** <primary segment>
- **One-Liner:** <1 sentence positioning statement>

## Positioning & Messaging

### Positioning Statement
For <target audience> who <need/pain point>,
<product/feature> is a <category>
that <key benefit>.
Unlike <alternative/competitor>,
our product <key differentiator>.

### Key Messages
| Audience        | Pain Point          | Message                          | Proof Point        |
|-----------------|---------------------|----------------------------------|--------------------|
| <persona 1>     | <their problem>     | <how we solve it>                | <data, testimonial>|
| <persona 2>     | <their problem>     | <how we solve it>                | <data, testimonial>|

## Launch Tiers

### Tier 1: Internal Launch (T-4 weeks)
- [ ] Internal announcement and demo
- [ ] Sales/CS enablement materials ready
- [ ] Support team trained on new feature
- [ ] Internal documentation complete
- [ ] FAQ document prepared

### Tier 2: Beta/Early Access (T-2 weeks)
- [ ] Beta users identified and invited
- [ ] Feedback collection mechanism set up
- [ ] Known limitations documented
- [ ] Rollback plan tested

### Tier 3: General Availability (Launch Day)
- [ ] Blog post / announcement published
- [ ] Email campaign sent to target segment
- [ ] In-app announcement or onboarding flow live
- [ ] Help center / docs updated
- [ ] Social media posts scheduled
- [ ] Landing page live (if applicable)

### Tier 4: Post-Launch (T+2 weeks)
- [ ] Collect and analyze early usage data
- [ ] Follow up with beta users for testimonials
- [ ] Address top feedback items
- [ ] Publish case study or success story

## Success Metrics
| Metric | Target (Week 1) | Target (Month 1) | Target (Quarter 1) |
|--------|-----------------|-------------------|---------------------|
| Adoption (% of target users) | <target> | <target> | <target> |
| Activation (completed core flow) | <target> | <target> | <target> |
| Retention (returned after first use) | -- | <target> | <target> |
| NPS / CSAT | -- | <target> | <target> |

## Rollout Strategy
- **Rollout method:** <feature flag % ramp | invite-only | region-based | all-at-once>
- **Ramp schedule:** <e.g., 5% -> 25% -> 50% -> 100% over 2 weeks>
- **Kill switch:** <how to disable if problems arise>
- **Rollback plan:** <steps to revert>
```

Save to `docs/gtm/<feature-name>-gtm.md`.

### Step 9: Stakeholder Communication Templates

Generate communication templates for different audiences:

**Executive Status Update:**
```markdown
# Product Update: <Period>

## TL;DR
<2-3 sentences: what shipped, what's coming, any blockers>

## Shipped This Period
| Feature | Impact | Metric Movement |
|---------|--------|----------------|
| <feature> | <who benefits> | <metric: before -> after> |

## In Progress
| Feature | Status | ETA | Risk Level |
|---------|--------|-----|------------|
| <feature> | On Track / At Risk / Blocked | <date> | GREEN/YELLOW/RED |

## Key Decisions Needed
1. <Decision needed> -- Impact: <what's blocked> -- Deadline: <date>

## Risks & Asks
| Risk | Impact | Ask |
|------|--------|-----|
| <risk> | <consequence> | <what you need from leadership> |
```

**Sprint Review / Demo Notes:**
```markdown
# Sprint <N> Review

## Sprint Goal: <goal>
## Goal Met: YES / PARTIAL / NO

## Demo Items
1. **<Feature>** -- <who demos> -- <what to show>
2. **<Feature>** -- <who demos> -- <what to show>

## Velocity
- Committed: <N> pts | Completed: <M> pts | Carry-over: <K> pts

## Retrospective Highlights
- **Keep doing:** <what worked>
- **Start doing:** <what to try>
- **Stop doing:** <what to drop>
```

**Customer-Facing Changelog:**
```markdown
## <Date> -- <Release Name>

### New
- **<Feature>:** <1-sentence user-facing description>

### Improved
- **<Feature>:** <what got better and why users care>

### Fixed
- **<Bug>:** <what was broken and that it's now resolved>
```

### Step 10: Launch Readiness Checklist

Comprehensive pre-launch gate:

```
LAUNCH READINESS ASSESSMENT:
Feature: <name>
Target Launch Date: <date>

PRODUCT READINESS:
[ ] PRD approved and requirements finalized
[ ] Design reviewed and approved
[ ] All MUST user stories completed and accepted
[ ] Edge cases and error states handled
[ ] Empty states, loading states, and error UI implemented
[ ] Accessibility requirements met (WCAG 2.1 AA)
[ ] Internationalization handled (if applicable)

ENGINEERING READINESS:
[ ] Code reviewed and merged to release branch
[ ] All automated tests passing (unit, integration, e2e)
[ ] Performance benchmarks met (<target load time, throughput>)
[ ] Security review completed (no critical/high findings)
[ ] Feature flag configured and tested (on/off/gradual rollout)
[ ] Database migrations tested and reversible
[ ] API versioning handled (if breaking changes)
[ ] Monitoring and alerting configured

DATA & ANALYTICS READINESS:
[ ] Analytics events instrumented and verified
[ ] Dashboard or report created for success metrics
[ ] A/B test configured (if applicable)
[ ] Data pipeline verified (events flowing to warehouse)
[ ] GDPR/privacy review for new data collection

OPERATIONS READINESS:
[ ] Runbook created for on-call team
[ ] Rollback procedure documented and tested
[ ] Capacity planning verified (can handle expected load)
[ ] Third-party dependencies confirmed (API limits, SLAs)

GO-TO-MARKET READINESS:
[ ] Blog post / announcement drafted
[ ] Help center articles published
[ ] Sales enablement materials distributed
[ ] Support team trained and FAQ prepared
[ ] Email/in-app notification scheduled
[ ] Social media content scheduled (if applicable)

LAUNCH DECISION:
Total checks: <N>
Passed: <M>
Failed: <K>
Blocked: <J>

Verdict: GO / NO-GO / CONDITIONAL GO (list conditions)

Blockers (if NO-GO):
1. <blocker> -- Owner: <who> -- ETA: <when>
```

### Step 11: Product Metrics & Analytics Setup

Define what to measure and how to instrument:

```markdown
# Product Metrics Plan: <Feature Name>

## Metric Framework (Pirate Metrics / AARRR)

### Acquisition
| Metric | Definition | Event Name | Properties | Target |
|--------|-----------|------------|------------|--------|
| <metric> | <how calculated> | <event_name> | <key=value> | <target> |

### Activation
| Metric | Definition | Event Name | Properties | Target |
|--------|-----------|------------|------------|--------|
| <metric> | <how calculated> | <event_name> | <key=value> | <target> |

### Retention
| Metric | Definition | Event Name | Properties | Target |
|--------|-----------|------------|------------|--------|
| <metric> | <how calculated> | <event_name> | <key=value> | <target> |

### Revenue
| Metric | Definition | Event Name | Properties | Target |
|--------|-----------|------------|------------|--------|
| <metric> | <how calculated> | <event_name> | <key=value> | <target> |

### Referral
| Metric | Definition | Event Name | Properties | Target |
|--------|-----------|------------|------------|--------|
| <metric> | <how calculated> | <event_name> | <key=value> | <target> |

## Instrumentation Checklist
| Event | Location (file:line) | Trigger | Properties | Verified |
|-------|---------------------|---------|------------|----------|
| <event_name> | <file path> | <user action> | <props> | [ ] |

## Guardrail Metrics
These must NOT regress when the feature launches:
| Metric | Current Value | Acceptable Range | Alert Threshold |
|--------|--------------|-----------------|-----------------|
| <metric, e.g., page load time> | <value> | <range> | <threshold> |
| <metric, e.g., error rate> | <value> | <range> | <threshold> |
| <metric, e.g., core flow completion> | <value> | <range> | <threshold> |

## Dashboard Specification
Panels to create in <analytics tool>:
1. **<Panel name>:** <chart type> showing <metric> over <time range>
2. **<Panel name>:** <chart type> showing <metric> segmented by <dimension>
3. **<Panel name>:** <funnel> showing <step1 -> step2 -> step3> conversion
```

Save to `docs/metrics/<feature-name>-metrics.md`.

### Step 12: Customer Feedback Synthesis

Synthesize feedback from multiple sources into actionable insights:

```markdown
# Customer Feedback Synthesis: <Topic/Feature Area>

## Date: <YYYY-MM-DD>
## Sources Analyzed: <N sources, N total data points>

## Data Sources
| Source | Count | Date Range | Type |
|--------|-------|------------|------|
| Support tickets | <N> | <range> | Quantitative + Qualitative |
| User interviews | <N> | <range> | Qualitative |
| NPS comments | <N> | <range> | Qualitative |
| App store reviews | <N> | <range> | Qualitative |
| Usage analytics | <N events> | <range> | Quantitative |
| Churn surveys | <N> | <range> | Qualitative |

## Theme Analysis

### Theme 1: <Theme Name> (Mentioned by <N> users, <percent>% of feedback)
**Severity:** Critical / High / Medium / Low
**Sentiment:** Negative / Mixed / Positive
**Representative Quotes:**
- "<verbatim quote>" -- <source, user segment>
- "<verbatim quote>" -- <source, user segment>

**Quantitative Signal:**
- <metric supporting this theme, e.g., "40% drop-off at step 3 of onboarding">

**Recommended Action:** <specific product action>
**Effort:** S / M / L
**Impact:** H / M / L

---

### Theme 2: <Theme Name> (Mentioned by <N> users, <percent>% of feedback)
...

## Priority Matrix

| Theme | Frequency | Severity | Effort | Impact | Action |
|-------|-----------|----------|--------|--------|--------|
| <theme 1> | <N mentions> | Critical | M | H | Build in Q<N> |
| <theme 2> | <N mentions> | High | S | H | Quick win -- next sprint |
| <theme 3> | <N mentions> | Medium | L | M | Defer to V2 |
| <theme 4> | <N mentions> | Low | S | L | Won't fix -- document why |

## Insights Summary
1. <Top insight: what users need most, supported by data>
2. <Second insight: emerging pattern or trend>
3. <Third insight: surprising finding that challenges assumptions>

## Recommended Roadmap Impact
- **Add to roadmap:** <feature/improvement based on feedback>
- **Reprioritize:** <existing item that should move up/down>
- **Investigate further:** <area needing deeper research>
- **No action needed:** <feedback acknowledged but not actionable, with reason>
```

Save to `docs/feedback/<topic>-feedback-synthesis.md`.

## Key Behaviors

1. **PRDs are for alignment, not specification.** A PRD that nobody reads is waste. Keep it focused, link to details instead of embedding them, and write for the audience (engineering, design, stakeholders).
2. **User stories are not tasks.** "As a developer I want to add a database column" is a task wearing a story costume. Stories describe user value. Tasks describe implementation.
3. **Prioritization uses frameworks, not opinions.** "The CEO wants it" is not a prioritization framework. Score every feature with the same method so trade-offs are visible and defensible.
4. **Sprint planning respects velocity.** Committing to 40 points when your average velocity is 28 is not ambition. It is a plan to fail and demoralize the team.
5. **Competitive analysis drives decisions.** A comparison matrix that sits in a drawer is busywork. Every competitive insight should map to a product decision: build, ignore, or differentiate.
6. **OKRs measure outcomes, not outputs.** "Ship 5 features" is an output. "Increase activation rate from 30% to 45%" is an outcome. Measure what matters to users, not what matters to your Gantt chart.
7. **Launch readiness is a gate, not a formality.** If the checklist reveals gaps, delay the launch. Launching with known gaps is not bravery, it is recklessness with user trust.
8. **Feedback synthesis requires evidence, not cherry-picking.** One loud customer is an anecdote. Twenty customers describing the same friction point is a signal. Quantify before acting.

## Example Usage

### Write a PRD
```
User: /godmode:pm Write a PRD for adding team workspaces to our SaaS app

PM: Starting PRD creation...

First, let me understand the problem:
- Who needs this? Teams of 3-15 currently sharing a single account
- What's the pain? No role-based access, no shared dashboards, audit trail gaps
- Evidence? 47 support tickets in Q4, 3 churned accounts cited "no team support"

Writing PRD: Team Workspaces

[Generates full PRD with problem statement, user flows, functional/non-functional
requirements, success metrics (team creation rate, collaboration events per team,
churn reduction), technical considerations (multi-tenancy, RBAC, data isolation),
timeline, and risks]

Saved to docs/prds/team-workspaces-prd.md

Next steps:
- Review with engineering lead for feasibility
- Review with design for UX flows
- Run /godmode:pm --stories to generate user stories from the PRD
```

### Generate user stories from a PRD
```
User: /godmode:pm --stories team-workspaces

PM: Reading PRD from docs/prds/team-workspaces-prd.md...

Generating stories for Epic: Team Workspaces

Story 1: Create a Team Workspace
As a team admin
I want to create a new workspace with a name and invite link
So that my team can collaborate in a shared environment

Acceptance Criteria:
- GIVEN I am on the account settings page WHEN I click "Create Workspace" THEN I see a form with name, description, and plan selection
- GIVEN I submit a valid workspace name WHEN the workspace is created THEN I am redirected to the workspace with an invite link displayed
- GIVEN a workspace name already exists in my org WHEN I try to create it THEN I see an error "Workspace name already taken"
- GIVEN I am on a free plan WHEN I try to create a second workspace THEN I see an upgrade prompt

Size: M (5 pts) | Priority: MUST | Dependencies: none

[Generates 8 more stories covering invites, roles, switching, settings, billing...]

Story quality: 9/9 pass INVEST check. All have AC in GIVEN/WHEN/THEN format.
```

### Prioritize features with RICE
```
User: /godmode:pm --prioritize --framework rice

PM: Collecting feature candidates...

RICE PRIORITIZATION:
Feature                    | Reach  | Impact | Confidence | Effort  | RICE Score
---------------------------|--------|--------|------------|---------|----------
Fix onboarding drop-off    | 8000   | 2      | 90%        | 2 wks   | 7200
Team workspaces            | 2000   | 3      | 70%        | 6 wks   | 700
API rate limiting          | 500    | 2      | 95%        | 1 wk    | 950
Dashboard redesign         | 5000   | 1      | 50%        | 4 wks   | 625
Dark mode                  | 6000   | 0.25   | 80%        | 2 wks   | 600

Recommendation:
1. Fix onboarding drop-off (highest RICE by 7x -- clear winner)
2. API rate limiting (high confidence, low effort)
3. Team workspaces (high impact but large effort brings score down)
```

### Launch readiness check
```
User: /godmode:pm --launch-check team-workspaces

PM: Running launch readiness assessment...

LAUNCH READINESS: Team Workspaces
Passed: 22/26
Failed: 3
Blocked: 1

BLOCKERS:
- [ ] FAIL: Rollback procedure not documented -- Owner: @devops -- ETA: 2 days
- [ ] FAIL: Help center articles not published -- Owner: @support -- ETA: 1 day
- [ ] FAIL: Performance benchmark missed (3.2s load, target <2s) -- Owner: @eng
- [ ] BLOCKED: A/B test config waiting on analytics team

Verdict: NO-GO
Resolve the 3 failures and 1 blocker before launching.
Estimated time to GO: 3-5 days.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive -- asks which PM activity you need |
| `--prd <name>` | Create a PRD for the named feature |
| `--stories [name]` | Generate user stories (from PRD if name given, or from context) |
| `--prioritize` | Prioritize features in the backlog |
| `--framework <type>` | Choose prioritization framework: `rice`, `moscow`, `ice` |
| `--sprint` | Sprint planning and backlog grooming |
| `--competitive <area>` | Competitive analysis for a product area |
| `--okrs [period]` | Define OKRs and KPIs for a period |
| `--gtm <name>` | Go-to-market plan for a feature |
| `--mvp <name>` | Define MVP scope for a feature |
| `--stakeholder-update` | Generate executive status update |
| `--launch-check [name]` | Run launch readiness checklist |
| `--metrics <name>` | Define product metrics and instrumentation plan |
| `--feedback <topic>` | Synthesize customer feedback on a topic |
| `--template <type>` | Output a blank template (prd, story, okr, gtm, launch, competitive) |

## HARD RULES

1. NEVER write a PRD without a measurable success metric. "Improve user experience" is not a metric. Define a number, a baseline, and a target.
2. NEVER skip competitive analysis before defining a new feature. If three competitors already solved the same problem, learn from their approach before reinventing.
3. ALWAYS include acceptance criteria for every user story. A story without AC cannot be estimated, tested, or marked as done.
4. NEVER prioritize features without a scoring framework (RICE, ICE, MoSCoW, or equivalent). Gut-feel prioritization leads to scope creep and stakeholder conflict.
5. ALWAYS define rollback criteria alongside launch criteria. If the feature degrades a key metric by more than X%, have a documented plan to revert.
6. NEVER scope a feature larger than 2 weeks of engineering work without decomposing it into milestones. Large scopes have compounding uncertainty.
7. ALWAYS tie OKRs to user outcomes, not output. "Ship 5 features" is output. "Increase activation rate from 30% to 45%" is an outcome.
8. NEVER approve a launch without verifying the analytics instrumentation works end-to-end. If you cannot measure it, you cannot learn from it.

## Anti-Patterns

- **Do NOT write a PRD after building the feature.** A PRD written post-hoc is documentation, not product management. Write the PRD before writing code so the team builds the right thing.
- **Do NOT write user stories without acceptance criteria.** "As a user I want to log in" with no AC is a wish, not a story. If you cannot define when it is done, you cannot build it or test it.
- **Do NOT prioritize by who shouts loudest.** The HiPPO (Highest Paid Person's Opinion) is not a framework. Use RICE/ICE/MoSCoW so every feature is scored on the same axes and trade-offs are transparent.
- **Do NOT plan sprints beyond team velocity.** Over-committing every sprint is not optimism -- it is a pattern that erodes trust, burns out the team, and makes all estimates meaningless.
- **Do NOT treat competitive analysis as a one-time event.** Markets move. Competitors ship. Refresh the analysis quarterly or when a competitor makes a significant move.
- **Do NOT set OKRs you are 100% confident of hitting.** OKRs at 100% confidence are sandbagging. Aim for 60-70% confidence -- ambitious enough to stretch, realistic enough to not be fantasy.
- **Do NOT launch without a rollback plan.** "We'll figure it out if something goes wrong" is not a plan. Define the rollback steps before you define the launch steps.
- **Do NOT act on feedback from a single user.** One user's feature request is an anecdote. Synthesize across sources and look for patterns before changing the roadmap.
- **Do NOT confuse outputs with outcomes in metrics.** Tracking "number of features shipped" tells you about engineering throughput, not product success. Track what users do, not what you built.
- **Do NOT skip the "Out of Scope" section in any document.** Undefined scope boundaries guarantee scope creep. Every PRD, MVP definition, and sprint plan must explicitly state what is NOT included.
