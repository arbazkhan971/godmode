---
name: research
description: |
  User research skill. Activates when users need to create personas, design surveys, generate interview scripts, map user journeys, identify pain points, conduct competitive UX analysis, plan usability tests, interpret heatmaps and analytics, categorize customer feedback, or apply the Jobs-to-be-Done framework. Provides structured research methodologies, synthesis frameworks, and actionable insight generation. Triggers on: /godmode:research, "create user personas", "design a survey", "user interview", "journey map", "pain points", "competitive analysis", "usability test", "heatmap analysis", "customer feedback", "jobs to be done", or when the orchestrator detects user research work.
---

# Research — User Research

## When to Activate
- User invokes `/godmode:research`
- User says "create personas", "build user personas", "who are our users"
- User says "design a survey", "write survey questions", "questionnaire"
- User says "user interview", "interview script", "interview guide"
- User says "journey map", "user journey", "customer journey", "experience map"
- User says "pain points", "user frustrations", "friction points"
- User says "competitive UX", "competitor analysis", "UX benchmark"
- User says "usability test", "user testing", "test plan"
- User says "heatmap", "analytics interpretation", "click map", "scroll map"
- User says "customer feedback", "categorize feedback", "NPS analysis", "sentiment analysis"
- User says "jobs to be done", "JTBD", "user needs", "outcome-driven"
- When `/godmode:plan` identifies user research as a prerequisite before building features
- When `/godmode:uxdesign` needs research inputs to inform design decisions

## Workflow

### Step 1: Research Objective Discovery
Understand the research context and what decisions the research will inform:

```
RESEARCH DISCOVERY:
Product: <name and description>
Stage: <pre-launch | early growth | mature | pivot>
Research objective:
  - <primary question — e.g., "Why do users abandon onboarding at step 3?">
  - <secondary question — e.g., "What features would retain power users?">
Decision this informs: <what will change based on findings — e.g., "Redesign onboarding flow">
Existing data:
  - Analytics: <available | partial | none>
  - Previous research: <reports, surveys, interviews — or none>
  - Support tickets: <available | none>
  - NPS/CSAT scores: <score if known | none>
Target users: <segments — e.g., "Free tier users who signed up in last 30 days">
Constraints:
  - Budget: <$ range | no budget — guerrilla methods only>
  - Timeline: <days/weeks available>
  - Access to users: <easy — internal tool | moderate — email list | hard — cold outreach>
```

If the user hasn't specified, ask: "What decision will this research inform? What do you need to learn to move forward?"

### Step 2: Research Method Selection
Choose the right methods based on objectives and constraints:

```
RESEARCH METHOD SELECTION:
┌──────────────────────────┬────────────────────────┬──────────────────────────────┐
│  Method                  │  Best For              │  When to Use                 │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  User Personas           │  Aligning teams on     │  Starting a new product,     │
│                          │  who the users are     │  entering new market segment │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Surveys                 │  Quantitative signal   │  Validating hypotheses at    │
│                          │  at scale              │  scale, measuring sentiment  │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  User Interviews         │  Deep qualitative      │  Exploring "why" behind      │
│                          │  understanding         │  behaviors, discovering needs │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Journey Mapping         │  Visualizing end-to-   │  Identifying friction across │
│                          │  end experience        │  multi-step workflows        │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Pain Point Analysis     │  Finding high-impact   │  Prioritizing what to fix    │
│                          │  friction              │  or improve next             │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Competitive UX Analysis │  Benchmarking against  │  Entering competitive market,│
│                          │  alternatives          │  differentiating product     │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Usability Testing       │  Validating design     │  Before launching new flows, │
│                          │  decisions             │  after redesigns             │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Heatmap/Analytics       │  Understanding actual  │  Diagnosing conversion drops,│
│  Interpretation          │  behavior patterns     │  validating assumptions      │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Feedback Categorization │  Structuring qualita-  │  When feedback volume is     │
│                          │  tive signal at scale  │  high and patterns are murky │
├──────────────────────────┼────────────────────────┼──────────────────────────────┤
│  Jobs-to-be-Done (JTBD)  │  Understanding core    │  Product strategy, feature   │
│                          │  motivations           │  prioritization, positioning │
└──────────────────────────┴────────────────────────┴──────────────────────────────┘

SELECTED METHODS: <method 1>, <method 2>
JUSTIFICATION: <why these methods answer the research questions given the constraints>
SEQUENCE: <order of execution — e.g., "Interviews first to generate hypotheses, then survey to validate at scale">
```

### Step 3: User Persona Creation from Data
Build evidence-based personas grounded in real data, not assumptions:

```
DATA SOURCES FOR PERSONAS:
  - Analytics segments: <behavioral clusters from product data>
  - Survey responses: <demographic and attitudinal data>
  - Interview transcripts: <N interviews synthesized>
  - Support tickets: <patterns from N tickets>
  - Sales/CRM data: <deal size, industry, role>
  - Signup form fields: <role, company size, use case>

PERSONA TEMPLATE:
┌─────────────────────────────────────────────────────────────────────┐
│  PERSONA: <Name — descriptive archetype, e.g., "Scaling Sarah">    │
├─────────────────────────────────────────────────────────────────────┤
│  DEMOGRAPHICS                                                       │
│    Role: <job title>                                                │
│    Experience: <years in role>                                      │
│    Company size: <range>                                            │
│    Industry: <sector>                                               │
│    Technical skill: <novice | intermediate | advanced | expert>     │
│                                                                     │
│  SEGMENT SIZE                                                       │
│    % of user base: <N%>                                             │
│    Revenue contribution: <N%>                                       │
│    Growth trend: <growing | stable | declining>                     │
│                                                                     │
│  GOALS                                                              │
│    Primary: <what they are trying to accomplish>                    │
│    Secondary: <supporting goal>                                     │
│    Underlying motivation: <deeper "why" — status, efficiency,      │
│                            risk reduction, growth>                  │
│                                                                     │
│  FRUSTRATIONS                                                       │
│    1. <pain point with severity: HIGH | MEDIUM | LOW>               │
│    2. <pain point with severity>                                    │
│    3. <pain point with severity>                                    │
│                                                                     │
│  BEHAVIORS                                                          │
│    Usage frequency: <daily | weekly | monthly | sporadic>           │
│    Key workflows: <top 3 actions they perform>                      │
│    Feature adoption: <which features they use vs ignore>            │
│    Trigger event: <what causes them to open the product>            │
│                                                                     │
│  TOOLS & CONTEXT                                                    │
│    Current solutions: <what they use today, including competitors>  │
│    Decision-making: <solo | team | committee | manager approval>    │
│    Budget authority: <yes | no | influences>                        │
│                                                                     │
│  QUOTES (from real interviews/feedback)                             │
│    "<verbatim quote that captures their mindset>"                   │
│    "<verbatim quote about a frustration>"                           │
│                                                                     │
│  DESIGN IMPLICATIONS                                                │
│    - <what this persona needs from the product>                     │
│    - <what would make them churN>                                   │
│    - <what would make them upgrade/expand>                          │
└─────────────────────────────────────────────────────────────────────┘
```

Create 3-5 personas. Each must be backed by data, not fiction. If data is insufficient, flag gaps explicitly:

```
DATA CONFIDENCE:
  Persona            | Data Points | Confidence | Gaps
  -------------------|-------------|------------|----------------------------------
  Scaling Sarah      | 42          | HIGH       | None — strong interview + analytics
  Budget-Conscious   | 18          | MEDIUM     | Missing usage frequency data
    Ben              |             |            |
  Enterprise Emma    | 7           | LOW        | Only 2 interviews, need more data
```

### Step 4: Survey Design and Analysis
Design surveys that produce actionable data, not vanity metrics:

```
SURVEY DESIGN:
Objective: <what this survey will answer>
Target audience: <segment>
Distribution: <in-app | email | social | intercept>
Sample size target: <N> (for <confidence level> at <margin of error>)
Estimated response rate: <N%>
Required sends: <N> (sample size / response rate)

QUESTION DESIGN:
┌─────┬──────────────────────────────────────────┬──────────────┬──────────────┐
│  #  │  Question                                │  Type        │  Purpose     │
├─────┼──────────────────────────────────────────┼──────────────┼──────────────┤
│  1  │  <screening question>                    │  Multiple    │  Segment     │
│     │                                          │  choice      │  respondents │
├─────┼──────────────────────────────────────────┼──────────────┼──────────────┤
│  2  │  <behavioral question — what they do>    │  Scale 1-5   │  Measure     │
│     │                                          │              │  frequency   │
├─────┼──────────────────────────────────────────┼──────────────┼──────────────┤
│  3  │  <attitudinal question — what they think>│  Likert      │  Measure     │
│     │                                          │  agree/disagr│  sentiment   │
├─────┼──────────────────────────────────────────┼──────────────┼──────────────┤
│  4  │  <preference question — what they want>  │  Ranking     │  Prioritize  │
│     │                                          │              │  features    │
├─────┼──────────────────────────────────────────┼──────────────┼──────────────┤
│  5  │  <open-ended question — in their words>  │  Free text   │  Discover    │
│     │                                          │              │  unknown     │
└─────┴──────────────────────────────────────────┴──────────────┴──────────────┘

QUESTION RULES:
  1. No leading questions ("Don't you agree that...?")
  2. No double-barreled questions ("Is the app fast and easy to use?")
  3. No jargon — use the language your users use
  4. Mutually exclusive answer options for multiple choice
  5. Include "Other" with free text for unexpected answers
  6. Randomize option order to prevent order bias
  7. Keep it under 12 questions (completion rate drops 15% per extra question)
  8. Put demographic questions last (they feel invasive up front)
  9. Every question maps to a decision — if it does not, cut it

ESTIMATED COMPLETION TIME: <N minutes> (aim for under 5 for high completion rates)
```

#### Survey Analysis Framework
```
SURVEY ANALYSIS:
Responses: <N total> (<response rate>%)
Completion rate: <N%>

QUANTITATIVE RESULTS:
Question                        | Result           | Significance
--------------------------------|------------------|---------------------------
<question 1>                    | <summary stat>   | <notable or not notable>
<question 2>                    | <mean/median/mode>| <comparison to baseline>
<question 3>                    | <distribution>   | <skew or cluster pattern>

SEGMENT COMPARISON:
Segment          | Q1 Result | Q2 Result | Key Difference
-----------------|-----------|-----------|----------------------------
<segment A>      | <value>   | <value>   | <insight>
<segment B>      | <value>   | <value>   | <insight>

OPEN-ENDED THEMES (coded from free-text responses):
Theme                    | Frequency | Example Quote
-------------------------|-----------|-------------------------------
<theme 1>                | <N> (<N%>)| "<verbatim>"
<theme 2>                | <N> (<N%>)| "<verbatim>"
<theme 3>                | <N> (<N%>)| "<verbatim>"

KEY FINDINGS:
1. <actionable finding with supporting data>
2. <actionable finding with supporting data>
3. <actionable finding with supporting data>

LIMITATIONS:
- <response bias, sample size, segment coverage gaps>
```

### Step 5: User Interview Script Generation
Create structured interview guides that elicit genuine insights:

```
INTERVIEW GUIDE:
Research question: <what this interview will explore>
Target participant: <persona or segment>
Duration: <30 | 45 | 60 minutes>
Format: <remote video | in-person | phone>
Number of interviews: <N> (aim for 5-8 per segment for saturation)
Incentive: <$ amount or none>

INTERVIEW STRUCTURE:

OPENING (5 min):
  - Thank participant, explain purpose, confirm consent to record
  - "There are no right or wrong answers — we want to learn from your experience."
  - "Feel free to say 'I don't know' or 'That doesn't apply to me.'"

WARM-UP — CONTEXT (5 min):
  1. "Tell me about your role. What does a typical day look like?"
  2. "What are the biggest challenges you face in <relevant domain>?"

CORE — BEHAVIORS (15-20 min):
  3. "Walk me through the last time you <did the relevant task>. Start from the
      very beginning."
     - Probe: "What happened next?"
     - Probe: "Why did you do it that way?"
     - Probe: "What were you thinking at that point?"
  4. "What tools or methods do you currently use for <task>?"
     - Probe: "What do you like about them?"
     - Probe: "What frustrates you?"
  5. "Can you tell me about a time when <task> went wrong or was particularly
      difficult?"
     - Probe: "How did you handle it?"
     - Probe: "What would have helped?"

CORE — NEEDS & GOALS (10-15 min):
  6. "If you could wave a magic wand and fix one thing about <domain>,
      what would it be?"
  7. "What does success look like for you when it comes to <task>?"
  8. "What information do you wish you had when doing <task>?"

REACTION — CONCEPTS (optional, 5-10 min):
  9. Show prototype/concept: "What is your first reaction?"
     - Probe: "What would you expect to happen if you clicked here?"
     - Probe: "Is anything confusing or missing?"

CLOSING (5 min):
  10. "Is there anything I didn't ask that you think is important?"
  11. "Would you be open to a follow-up conversation?"

INTERVIEWER NOTES:
  - Listen more than talk (80/20 rule)
  - Ask "why" five times to get to root causes
  - Never lead the witness ("Would it be helpful if..." is leading)
  - Silence is okay — let participants fill the pause
  - Record specific quotes, not your interpretation
  - Note body language and tone (hesitation, enthusiasm, confusion)
```

#### Interview Synthesis
```
INTERVIEW SYNTHESIS:
Participants: <N> interviews across <N> segments
Date range: <start> — <end>

AFFINITY MAP (grouped findings):
┌─────────────────────────────────────────────────────────────────────┐
│  THEME 1: <theme name>                                             │
│  Frequency: <N of N participants>                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ "Quote from P1"                                             │   │
│  │ "Quote from P3"                                             │   │
│  │ "Quote from P5"                                             │   │
│  │ Observation: <behavioral pattern>                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────────┤
│  THEME 2: <theme name>                                             │
│  Frequency: <N of N participants>                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ "Quote from P2"                                             │   │
│  │ "Quote from P4"                                             │   │
│  │ Observation: <behavioral pattern>                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘

INSIGHT STATEMENTS:
1. <Insight>: <Users do X because Y, which means Z for our product>
2. <Insight>: <Users expect X but experience Y, creating friction at Z>
3. <Insight>: <Users work around X by doing Y, revealing an unmet need for Z>
```

### Step 6: Journey Mapping
Map the end-to-end user experience across touchpoints:

```
JOURNEY MAP:
Persona: <persona name>
Scenario: <specific goal — e.g., "First-time user completes onboarding and invites a teammate">
Scope: <start point> to <end point>
Time span: <minutes | hours | days | weeks>

┌────────┬────────────┬────────────┬────────────┬────────────┬────────────┐
│        │ PHASE 1    │ PHASE 2    │ PHASE 3    │ PHASE 4    │ PHASE 5    │
│        │ <Awareness>│ <Signup>   │ <Onboard>  │ <First Use>│ <Habit>    │
├────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│ DOING  │ <actions>  │ <actions>  │ <actions>  │ <actions>  │ <actions>  │
│        │ Searches   │ Fills form │ Follows    │ Creates    │ Returns    │
│        │ for tool   │ Verifies   │ tutorial   │ first item │ daily      │
│        │            │ email      │            │            │            │
├────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│THINKING│ <thoughts> │ <thoughts> │ <thoughts> │ <thoughts> │ <thoughts> │
│        │ "Is this   │ "Do I need │ "This is   │ "How do I  │ "This      │
│        │  worth     │  a credit  │  more steps│  share     │  saves me  │
│        │  trying?"  │  card?"    │  than I    │  this?"    │  time"     │
│        │            │            │  expected" │            │            │
├────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│FEELING │ Curious    │ Cautious   │ Frustrated │ Confused   │ Satisfied  │
│        │ Hopeful    │ Impatient  │ Overwhelmed│ then       │ Loyal      │
│        │            │            │            │ Relieved   │            │
│ EMOTION│  ++++      │  +++       │  +         │  +++       │  +++++     │
│ CURVE  │            │            │            │            │            │
├────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│TOUCH-  │ Google     │ Landing    │ Welcome    │ Dashboard  │ Email      │
│POINTS  │ search     │ page       │ email      │ Editor     │ notifs     │
│        │ Blog post  │ Signup     │ In-app     │ Help docs  │ Integra-   │
│        │ Social     │ form       │ tooltips   │            │ tions      │
├────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│PAIN    │ Hard to    │ Too many   │ Tutorial   │ No team-   │ Missing    │
│POINTS  │ compare    │ form       │ too long   │ plate for  │ advanced   │
│        │ options    │ fields     │ No skip    │ first      │ features   │
│        │            │            │ option     │ project    │            │
├────────┼────────────┼────────────┼────────────┼────────────┼────────────┤
│OPPORTU-│ SEO +      │ Social     │ Progress   │ Smart      │ Power-user │
│NITIES  │ comparison │ login      │ bar +      │ templates  │ features   │
│        │ content    │ Fewer      │ skip       │ Guided     │ API access │
│        │            │ fields     │ option     │ creation   │            │
└────────┴────────────┴────────────┴────────────┴────────────┴────────────┘

CRITICAL MOMENTS:
  Moment of truth #1: <phase and touchpoint where experience is won or lost>
  Moment of truth #2: <phase and touchpoint>

BIGGEST DROP-OFF: Phase <N> -> Phase <N+1>
  Evidence: <analytics or interview data supporting this>
  Root cause: <why users leave at this point>
  Recommended fix: <specific improvement>
```

### Step 7: Pain Point Identification
Systematically find, categorize, and prioritize user pain points:

```
PAIN POINT IDENTIFICATION:
Data sources analyzed:
  - Support tickets: <N> tickets from <date range>
  - User interviews: <N> participants
  - Survey responses: <N> responses
  - App reviews: <N> reviews from <sources>
  - Analytics: <drop-off data, rage clicks, error rates>
  - Session recordings: <N> sessions reviewed

PAIN POINT CATALOG:
┌─────┬──────────────────────────────┬──────────┬──────────┬──────────┬────────┐
│  #  │  Pain Point                  │ Severity │ Frequency│ Segment  │ Source │
├─────┼──────────────────────────────┼──────────┼──────────┼──────────┼────────┤
│  1  │  <description>               │  HIGH    │  Daily   │  All     │ Tickets│
│     │                              │          │          │          │ + Int. │
├─────┼──────────────────────────────┼──────────┼──────────┼──────────┼────────┤
│  2  │  <description>               │  HIGH    │  Weekly  │  New     │ Analyt.│
│     │                              │          │          │  users   │ + Surv.│
├─────┼──────────────────────────────┼──────────┼──────────┼──────────┼────────┤
│  3  │  <description>               │  MEDIUM  │  Daily   │  Power   │ Inter- │
│     │                              │          │          │  users   │ views  │
├─────┼──────────────────────────────┼──────────┼──────────┼──────────┼────────┤
│  4  │  <description>               │  LOW     │  Monthly │  Enter-  │ CRM    │
│     │                              │          │          │  prise   │        │
└─────┴──────────────────────────────┴──────────┴──────────┴──────────┴────────┘

PAIN POINT IMPACT SCORING:
Pain Point    | Users Affected | Revenue Impact | Churn Risk | Fix Effort | Priority
--------------|----------------|----------------|------------|------------|----------
<point 1>     | <N%>           | HIGH           | HIGH       | MEDIUM     | P0
<point 2>     | <N%>           | MEDIUM         | HIGH       | LOW        | P0
<point 3>     | <N%>           | LOW            | LOW        | LOW        | P1
<point 4>     | <N%>           | HIGH           | MEDIUM     | HIGH       | P1

ROOT CAUSE ANALYSIS (for top pain points):
Pain Point: <description>
  Symptom: <what users experience>
  Proximate cause: <immediate technical/design cause>
  Root cause: <underlying reason — e.g., "No user testing before launch">
  Contributing factors:
    - <factor 1>
    - <factor 2>
  Evidence: <data supporting this analysis>
```

### Step 8: Competitive UX Analysis
Benchmark against competitors to identify differentiation opportunities:

```
COMPETITIVE UX ANALYSIS:
Your product: <name>
Competitors analyzed: <competitor 1>, <competitor 2>, <competitor 3>
Analysis date: <date>

UX BENCHMARK MATRIX:
┌──────────────────────┬──────────┬──────────┬──────────┬──────────┐
│  Dimension           │  Ours    │  Comp. 1 │  Comp. 2 │  Comp. 3 │
├──────────────────────┼──────────┼──────────┼──────────┼──────────┤
│  Onboarding time     │  <min>   │  <min>   │  <min>   │  <min>   │
│  Time to value       │  <min>   │  <min>   │  <min>   │  <min>   │
│  Steps to core task  │  <N>     │  <N>     │  <N>     │  <N>     │
│  Learning curve      │  <grade> │  <grade> │  <grade> │  <grade> │
│  Error recovery      │  <grade> │  <grade> │  <grade> │  <grade> │
│  Mobile experience   │  <grade> │  <grade> │  <grade> │  <grade> │
│  Accessibility       │  <grade> │  <grade> │  <grade> │  <grade> │
│  Documentation       │  <grade> │  <grade> │  <grade> │  <grade> │
│  Pricing clarity     │  <grade> │  <grade> │  <grade> │  <grade> │
│  Overall UX quality  │  <grade> │  <grade> │  <grade> │  <grade> │
└──────────────────────┴──────────┴──────────┴──────────┴──────────┘
Grades: A (excellent), B (good), C (adequate), D (poor), F (broken)

FEATURE COMPARISON:
Feature              │  Ours    │  Comp. 1 │  Comp. 2 │  Comp. 3
─────────────────────┼──────────┼──────────┼──────────┼──────────
<feature 1>          │  YES/NO  │  YES/NO  │  YES/NO  │  YES/NO
<feature 2>          │  YES/NO  │  YES/NO  │  YES/NO  │  YES/NO
<feature 3>          │  YES/NO  │  YES/NO  │  YES/NO  │  YES/NO

COMPETITIVE ADVANTAGES (things we do better):
1. <advantage> — evidence: <why/how>
2. <advantage> — evidence: <why/how>

COMPETITIVE GAPS (things competitors do better):
1. <gap> — competitor: <who> — impact: <HIGH | MEDIUM | LOW>
2. <gap> — competitor: <who> — impact: <HIGH | MEDIUM | LOW>

DIFFERENTIATION OPPORTUNITIES:
1. <opportunity> — none of the competitors do this well
2. <opportunity> — underserved segment or use case
3. <opportunity> — emerging need that no one addresses yet

STEAL-WORTHY PATTERNS:
1. <pattern from competitor> — why it works: <explanation>
2. <pattern from competitor> — why it works: <explanation>
```

### Step 9: Usability Test Planning
Plan and structure usability tests that produce valid findings:

```
USABILITY TEST PLAN:
Objective: <what the test will evaluate>
Product/Feature: <what is being tested>
Stage: <prototype | beta | production>
Method: <moderated remote | moderated in-person | unmoderated remote>
Tool: <UserTesting | Maze | Lookback | manual screen share>

PARTICIPANTS:
  Target: <N> participants (5-8 per segment for qualitative, 20+ for quantitative)
  Segments:
    - <segment 1>: <N> participants — recruiting criteria: <criteria>
    - <segment 2>: <N> participants — recruiting criteria: <criteria>
  Screener questions:
    1. <question to filter for right participants>
    2. <question to filter for right participants>
  Incentive: <$ amount and form>

TASKS:
┌──────┬──────────────────────────────────────┬──────────┬──────────────────────┐
│ Task │  Description                         │ Success  │  Metrics             │
│  #   │  (scenario, not instructions)        │ Criteria │                      │
├──────┼──────────────────────────────────────┼──────────┼──────────────────────┤
│  1   │  "You just signed up. Find where to  │ Reaches  │ Time on task,        │
│      │   create your first project."        │ creation │ clicks to complete,  │
│      │                                      │ page     │ error count          │
├──────┼──────────────────────────────────────┼──────────┼──────────────────────┤
│  2   │  "You need to invite a colleague.    │ Invite   │ Time on task,        │
│      │   How would you do that?"            │ sent     │ success rate,        │
│      │                                      │          │ confidence rating    │
├──────┼──────────────────────────────────────┼──────────┼──────────────────────┤
│  3   │  "You want to see how your team is   │ Opens    │ Time on task,        │
│      │   performing this week."             │ report   │ path taken,          │
│      │                                      │ page     │ satisfaction         │
└──────┴──────────────────────────────────────┴──────────┴──────────────────────┘

TASK RULES:
  - Frame as scenarios, not instructions ("Find where to..." not "Click on...")
  - Do not reveal UI labels in the task description
  - Include realistic context and motivation
  - Order from easy to hard (build confidence first)
  - Include at least one discovery task ("How would you...?")

METRICS:
  - Task success rate (% of participants who complete each task)
  - Time on task (seconds to complete)
  - Error rate (wrong clicks, backtracking)
  - System Usability Scale (SUS) score (post-test questionnaire)
  - Single Ease Question (SEQ) per task (1-7 scale)
  - Net Promoter Score (NPS) (post-test)
  - Think-aloud observations (qualitative)

POST-TEST QUESTIONS:
  1. "What was the easiest part of the experience?"
  2. "What was the most frustrating part?"
  3. "How would you describe this product to a colleague?"
  4. SUS questionnaire (10 standard questions)

FACILITATOR GUIDE:
  - Use think-aloud protocol: "Please tell me what you're thinking as you go."
  - Never help or hint. If stuck: "What would you do if I weren't here?"
  - Note hesitations, confused expressions, and verbal frustrations
  - After each task, ask SEQ: "How easy was that on a scale of 1 to 7?"
  - Record session with participant consent
```

#### Usability Test Results Framework
```
USABILITY TEST RESULTS:
Participants: <N> (segments: <breakdown>)
Date: <date range>

TASK RESULTS:
Task │ Success Rate │ Avg Time │ Errors │ SEQ Score │ Severity
─────┼──────────────┼──────────┼────────┼───────────┼──────────
  1  │  <N%>        │  <sec>   │ <avg>  │  <1-7>    │ <PASS | CONCERN | FAIL>
  2  │  <N%>        │  <sec>   │ <avg>  │  <1-7>    │ <PASS | CONCERN | FAIL>
  3  │  <N%>        │  <sec>   │ <avg>  │  <1-7>    │ <PASS | CONCERN | FAIL>

Thresholds: SUCCESS >= 80%, SEQ >= 5.5, CONCERN = 60-79%, FAIL < 60%

OVERALL SCORES:
  SUS Score: <0-100> (<adjective rating: Excellent >80, Good 68-80, OK 51-67, Poor <51>)
  NPS: <-100 to 100> (<detractors/passives/promoters breakdown>)
  Task completion rate: <overall %>

USABILITY ISSUES FOUND:
┌─────┬──────────────────────────────┬──────────┬──────────┬───────────────┐
│  #  │  Issue                       │ Severity │ Task(s)  │ Participants  │
├─────┼──────────────────────────────┼──────────┼──────────┼───────────────┤
│  1  │  <description>               │ CRITICAL │ 1, 2     │ 4/5 (80%)     │
│  2  │  <description>               │ MAJOR    │ 2        │ 3/5 (60%)     │
│  3  │  <description>               │ MINOR    │ 3        │ 2/5 (40%)     │
└─────┴──────────────────────────────┴──────────┴──────────┴───────────────┘
Severity: CRITICAL (blocks task), MAJOR (significant difficulty), MINOR (annoyance)

RECOMMENDATIONS:
1. <fix for issue #1> — expected improvement: <metric impact>
2. <fix for issue #2> — expected improvement: <metric impact>
3. <fix for issue #3> — expected improvement: <metric impact>
```

### Step 10: Heatmap and Analytics Interpretation
Interpret behavioral data from heatmaps, session recordings, and analytics:

```
HEATMAP & ANALYTICS INTERPRETATION:
Page/Screen: <name and URL>
Data period: <date range>
Sample size: <N sessions | N visitors>

CLICK HEATMAP ANALYSIS:
Hot zones (most clicked):
  1. <element> — <N clicks> (<N%> of visitors) — Expected: <YES | NO>
  2. <element> — <N clicks> (<N%> of visitors) — Expected: <YES | NO>
  3. <element> — <N clicks> (<N%> of visitors) — Expected: <YES | NO>
Dead zones (expected clicks, few received):
  1. <element> — <N clicks> (<N%> of visitors) — Problem: <hypothesis>
  2. <element> — <N clicks> (<N%> of visitors) — Problem: <hypothesis>
Rage clicks (repeated frustrated clicks):
  1. <element> — <N rage click sessions> — Cause: <hypothesis>
False affordances (non-interactive elements clicked):
  1. <element> — <N clicks> — Users expect: <interaction>

SCROLL HEATMAP ANALYSIS:
Fold line: <N%> of visitors see above-the-fold content
Scroll depth distribution:
  25%: <N%> of visitors
  50%: <N%> of visitors
  75%: <N%> of visitors
  100%: <N%> of visitors
Content engagement drop-off: <where significant drop occurs>
Implication: <content below <N%> scroll is seen by <M%> — move critical content up>

FUNNEL ANALYTICS:
Step                   │ Visitors │ Conversion │ Drop-off │ Avg Time
───────────────────────┼──────────┼────────────┼──────────┼──────────
<step 1>               │ <N>      │ 100%       │ —        │ <sec>
<step 2>               │ <N>      │ <N%>       │ <N%>     │ <sec>
<step 3>               │ <N>      │ <N%>       │ <N%>     │ <sec>
<step 4>               │ <N>      │ <N%>       │ <N%>     │ <sec>

Biggest leak: Step <N> -> Step <N+1> (<N%> drop)
Hypothesis: <why users drop off here>
Evidence: <supporting data — session recordings, rage clicks, time on step>

BEHAVIORAL SEGMENTS:
Segment            │ % of Users │ Behavior Pattern        │ Outcome
───────────────────┼────────────┼─────────────────────────┼──────────
Completers         │ <N%>       │ <linear, fast path>     │ Convert
Explorers          │ <N%>       │ <browse, compare, slow> │ 50/50
Bouncers           │ <N%>       │ <single page, quick>    │ Leave
Strugglers         │ <N%>       │ <backtrack, rage click>  │ Abandon

INSIGHTS & RECOMMENDATIONS:
1. <insight> -> <recommendation> -> Expected impact: <metric change>
2. <insight> -> <recommendation> -> Expected impact: <metric change>
3. <insight> -> <recommendation> -> Expected impact: <metric change>
```

### Step 11: Customer Feedback Categorization
Structure and analyze qualitative feedback at scale:

```
FEEDBACK CATEGORIZATION:
Sources:
  - Support tickets: <N> from <date range>
  - App store reviews: <N> from <platforms>
  - NPS verbatims: <N> from <surveys>
  - Social mentions: <N> from <channels>
  - In-app feedback: <N> from <widget>
Total feedback items: <N>

TAXONOMY:
Category              │ Subcategory           │ Count │ % of Total │ Trend
──────────────────────┼───────────────────────┼───────┼────────────┼───────
Bug report            │ Crash / data loss     │ <N>   │ <N%>       │ <up/down/flat>
                      │ UI broken             │ <N>   │ <N%>       │
                      │ Performance           │ <N>   │ <N%>       │
──────────────────────┼───────────────────────┼───────┼────────────┼───────
Feature request       │ New capability        │ <N>   │ <N%>       │
                      │ Enhancement           │ <N>   │ <N%>       │
                      │ Integration           │ <N>   │ <N%>       │
──────────────────────┼───────────────────────┼───────┼────────────┼───────
Usability complaint   │ Confusing UI          │ <N>   │ <N%>       │
                      │ Missing guidance      │ <N>   │ <N%>       │
                      │ Workflow friction     │ <N>   │ <N%>       │
──────────────────────┼───────────────────────┼───────┼────────────┼───────
Praise                │ General satisfaction  │ <N>   │ <N%>       │
                      │ Specific feature      │ <N>   │ <N%>       │
──────────────────────┼───────────────────────┼───────┼────────────┼───────
Churn signal          │ Switching to comp.    │ <N>   │ <N%>       │
                      │ Pricing concern       │ <N>   │ <N%>       │
                      │ Missing critical feat.│ <N>   │ <N%>       │

SENTIMENT ANALYSIS:
Overall sentiment: <positive N% | neutral N% | negative N%>
Sentiment by category:
  Bug reports: <avg sentiment score -1 to 1>
  Feature requests: <avg sentiment score>
  Usability: <avg sentiment score>
Sentiment trend (last 3 months): <improving | stable | declining>

TOP REQUESTED FEATURES (from feature requests):
Rank │ Feature              │ Requests │ Segments Requesting    │ Revenue Impact
─────┼──────────────────────┼──────────┼────────────────────────┼──────────────
  1  │ <feature>            │ <N>      │ <segments>             │ <HIGH | MED>
  2  │ <feature>            │ <N>      │ <segments>             │ <HIGH | MED>
  3  │ <feature>            │ <N>      │ <segments>             │ <HIGH | MED>

ACTIONABLE INSIGHTS:
1. <insight with supporting data and recommended action>
2. <insight with supporting data and recommended action>
3. <insight with supporting data and recommended action>

ALERT — URGENT ISSUES:
- <any feedback indicating data loss, security issues, or mass churn signals>
```

### Step 12: Jobs-to-be-Done Framework
Uncover the functional, emotional, and social jobs users are hiring your product for:

```
JOBS-TO-BE-DONE ANALYSIS:
Product: <name>
Data sources: <interviews, surveys, behavioral data, switch interviews>

JOB STATEMENT FORMAT:
  "When <situation>, I want to <motivation>, so I can <expected outcome>."

CORE JOBS:
┌─────┬────────────────────────────────────────────────────────────────────────┐
│  #  │  Job Statement                                                        │
├─────┼────────────────────────────────────────────────────────────────────────┤
│  1  │  "When <situation>, I want to <motivation>,                           │
│     │   so I can <expected outcome>."                                       │
│     │  Type: FUNCTIONAL                                                     │
│     │  Importance: HIGH  Satisfaction: LOW  -> OPPORTUNITY                  │
├─────┼────────────────────────────────────────────────────────────────────────┤
│  2  │  "When <situation>, I want to <motivation>,                           │
│     │   so I can <expected outcome>."                                       │
│     │  Type: FUNCTIONAL                                                     │
│     │  Importance: HIGH  Satisfaction: HIGH -> TABLE STAKES                 │
├─────┼────────────────────────────────────────────────────────────────────────┤
│  3  │  "When <situation>, I want to <motivation>,                           │
│     │   so I can <expected outcome>."                                       │
│     │  Type: EMOTIONAL                                                      │
│     │  Importance: MEDIUM  Satisfaction: LOW  -> OPPORTUNITY                │
├─────┼────────────────────────────────────────────────────────────────────────┤
│  4  │  "When <situation>, I want to <motivation>,                           │
│     │   so I can <expected outcome>."                                       │
│     │  Type: SOCIAL                                                         │
│     │  Importance: MEDIUM  Satisfaction: MEDIUM -> MONITOR                  │
└─────┴────────────────────────────────────────────────────────────────────────┘

Job types:
  FUNCTIONAL — The practical task the user needs to accomplish
  EMOTIONAL — How the user wants to feel (confident, in control, less anxious)
  SOCIAL — How the user wants to be perceived (competent, innovative, reliable)

OPPORTUNITY SCORING:
  Opportunity = Importance + max(Importance - Satisfaction, 0)
  Scale: Importance (1-10), Satisfaction (1-10)

Job                   │ Importance │ Satisfaction │ Opportunity │ Priority
──────────────────────┼────────────┼──────────────┼─────────────┼──────────
<job 1>               │ 9          │ 3            │ 15          │ HIGH
<job 2>               │ 8          │ 8            │ 8           │ LOW
<job 3>               │ 7          │ 4            │ 10          │ MEDIUM
<job 4>               │ 6          │ 5            │ 7           │ LOW

INTERPRETATION:
  Opportunity > 12: UNDERSERVED — high importance, low satisfaction. Build here.
  Opportunity 8-12: SERVED — adequate but room to improve. Iterate.
  Opportunity < 8: OVERSERVED — consider deprioritizing investment.

SWITCH TRIGGERS (why users switch to/from your product):
Push (away from current): <what frustrates them about current solution>
Pull (toward new): <what attracts them to your product>
Anxiety (about switching): <what makes them hesitate>
Habit (staying with current): <what keeps them on current solution>

┌──────────────────────────────────────────────────────────┐
│                    FORCES DIAGRAM                         │
│                                                          │
│  PUSH ──────────────────> <────────────────── PULL       │
│  (pain with current)       (appeal of new)               │
│                                                          │
│  HABIT ─────────────────> <────────────────── ANXIETY    │
│  (comfort of current)      (fear of new)                 │
│                                                          │
│  Switch happens when: PUSH + PULL > HABIT + ANXIETY      │
└──────────────────────────────────────────────────────────┘

PRODUCT IMPLICATIONS:
1. <implication> — increase PULL by: <specific feature/message>
2. <implication> — reduce ANXIETY by: <specific action — trial, migration help>
3. <implication> — address PUSH from competitors by: <differentiation>
```

### Step 13: Research Synthesis and Delivery
Combine all research into actionable outputs:

```
RESEARCH SYNTHESIS:
Project: <name>
Methods used: <list of methods applied>
Data collected: <summary of all data sources and volumes>

KEY FINDINGS (prioritized):
┌─────┬──────────────────────────────────────┬───────────┬──────────────────────┐
│  #  │  Finding                             │ Confidence│  Implication         │
├─────┼──────────────────────────────────────┼───────────┼──────────────────────┤
│  1  │  <finding backed by data>            │  HIGH     │  <what to do>        │
├─────┼──────────────────────────────────────┼───────────┼──────────────────────┤
│  2  │  <finding backed by data>            │  HIGH     │  <what to do>        │
├─────┼──────────────────────────────────────┼───────────┼──────────────────────┤
│  3  │  <finding backed by data>            │  MEDIUM   │  <what to do>        │
├─────┼──────────────────────────────────────┼───────────┼──────────────────────┤
│  4  │  <finding needs more data>           │  LOW      │  <further research>  │
└─────┴──────────────────────────────────────┴───────────┴──────────────────────┘

RECOMMENDATIONS:
Priority │ Recommendation              │ Evidence           │ Expected Impact
─────────┼─────────────────────────────┼────────────────────┼──────────────────
P0       │ <immediate action>          │ <data sources>     │ <metric impact>
P1       │ <next sprint action>        │ <data sources>     │ <metric impact>
P2       │ <future consideration>      │ <data sources>     │ <metric impact>

RESEARCH GAPS (what we still do not know):
1. <open question> — suggested method: <how to answer it>
2. <open question> — suggested method: <how to answer it>

ARTIFACTS DELIVERED:
- Personas: docs/research/personas.md
- Journey map: docs/research/journey-map.md
- Pain points: docs/research/pain-points.md
- Survey results: docs/research/survey-<name>.md
- Interview synthesis: docs/research/interview-synthesis.md
- Competitive analysis: docs/research/competitive-ux.md
- Usability test results: docs/research/usability-<feature>.md
- JTBD analysis: docs/research/jobs-to-be-done.md

Next steps:
-> /godmode:prioritize — Prioritize findings into actionable backlog
-> /godmode:uxdesign — Design solutions for top pain points
-> /godmode:plan — Plan implementation of recommendations
-> /godmode:analytics — Instrument metrics to track improvement
```

Commit: `"research: <method(s)> — <N> findings, <N> personas, <N> recommendations"`

## Key Behaviors

1. **Data over opinions.** Every persona, pain point, and recommendation must be traced back to evidence. Gut feelings are hypotheses, not findings. Label confidence levels honestly.
2. **Ask "why" five times.** Surface-level observations are not insights. A user clicking the wrong button is an observation. Why they expected it to be somewhere else is an insight.
3. **Triangulate across methods.** A single data source can mislead. A pain point found in interviews, confirmed in analytics, and echoed in support tickets is a validated finding.
4. **Research informs decisions, not decorates them.** Every research activity must connect to a decision that will be made differently based on the findings. If no decision depends on the answer, do not ask the question.
5. **Separate observation from interpretation.** Report what users said and did before interpreting what it means. Keeping these distinct prevents confirmation bias.
6. **Small samples reveal big patterns.** Five well-recruited interviews often uncover 80% of usability issues. Do not wait for statistical significance when qualitative signal is strong.
7. **Respect participants.** Honor time commitments, protect privacy, never share identifying information without consent, and report findings that represent what participants actually said.
8. **Personas are living documents.** Update them as new data arrives. Stale personas based on launch-era assumptions are worse than no personas at all.

## Example Usage

### Building User Personas
```
User: /godmode:research Create personas for our project management SaaS

Research: Starting persona creation...

RESEARCH DISCOVERY:
Product: Project management SaaS
Existing data: 12 user interviews, 340 survey responses, Amplitude analytics

DATA ANALYSIS:
  - 3 behavioral clusters identified in analytics
  - Survey segments: solo users (35%), team leads (45%), executives (20%)
  - Interview themes coded and mapped to clusters

PERSONAS CREATED:
  1. "Scaling Sarah" — Team lead, 50-200 person company, daily user
     Goal: Ship projects on time without micromanaging
     Pain: Cannot see cross-team dependencies at a glance
     Segment: 45% of users, 60% of revenue — HIGH confidence

  2. "Solo Dev Sam" — Individual contributor, freelancer
     Goal: Track personal tasks without overhead
     Pain: Tool feels bloated for solo use
     Segment: 35% of users, 15% of revenue — HIGH confidence

  3. "Executive Eve" — VP/Director, needs reporting not task management
     Goal: Visibility into team progress without learning the tool
     Pain: Reports require too many clicks and filters
     Segment: 20% of users, 25% of revenue — MEDIUM confidence

Saved to docs/research/personas.md
Next: /godmode:uxdesign to design for top persona pain points
```

### Designing and Analyzing a Survey
```
User: /godmode:research --survey Design a churn survey for users who cancelled

Research: Designing churn survey...

SURVEY DESIGN:
Objective: Understand why users cancel and what would bring them back
Target: Users who cancelled in last 30 days (N=280)
Distribution: Email (triggered on cancellation)
Questions: 8 (estimated 3 min completion)

Questions:
  1. Primary reason for cancelling (multiple choice + other)
  2. How long did you use the product? (range)
  3. What did you switch to? (multiple choice + other)
  4. How satisfied were you overall? (1-5 scale)
  5. What one thing would have prevented you from leaving? (free text)
  6. How likely are you to return if we addressed your concern? (1-5)
  7. Which features did you use most? (multi-select)
  8. Anything else you'd like us to know? (free text)

Survey ready for deployment. Run /godmode:research --survey --analyze after collection.
```

### Running a JTBD Analysis
```
User: /godmode:research --jtbd Analyze jobs-to-be-done for our analytics tool

Research: Starting JTBD analysis...

DATA: 8 switch interviews, 200 survey responses, behavioral data

TOP JOBS:
  1. "When my boss asks how a feature is performing, I want to pull
      accurate numbers in under 60 seconds, so I can look prepared."
     Importance: 9  Satisfaction: 3  Opportunity: 15 — UNDERSERVED

  2. "When I launch a new feature, I want to see if users actually
      adopt it, so I can decide whether to invest more or pivot."
     Importance: 8  Satisfaction: 5  Opportunity: 11 — SERVED

  3. "When I present to stakeholders, I want beautiful charts that
      tell a clear story, so I can build confidence in my team's work."
     Importance: 7  Satisfaction: 2  Opportunity: 12 — UNDERSERVED

SWITCH FORCES:
  Push: Current tool requires SQL for basic queries (non-technical users blocked)
  Pull: Promise of self-serve analytics without code
  Anxiety: "Will my historical data migrate cleanly?"
  Habit: Team already knows the current tool's quirks

Recommendation: Focus on job #1 (fast answers) and job #3 (presentation-ready charts).
Reduce anxiety with a one-click data migration tool.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full research workflow — discovery, method selection, execution, synthesis |
| `--personas` | Create user personas from available data |
| `--survey` | Design a survey (add `--analyze` to analyze existing results) |
| `--interview` | Generate user interview script and guide |
| `--journey` | Create a user journey map |
| `--painpoints` | Identify and prioritize pain points |
| `--competitive` | Run competitive UX analysis |
| `--usability` | Plan a usability test (add `--results` to analyze test results) |
| `--heatmap` | Interpret heatmap and behavioral analytics data |
| `--feedback` | Categorize and analyze customer feedback |
| `--jtbd` | Apply Jobs-to-be-Done framework |
| `--synthesize` | Synthesize findings across multiple research activities |
| `--segment <name>` | Focus research on a specific user segment |
| `--compare <before> <after>` | Compare research findings before and after a change |

## Anti-Patterns

- **Do NOT create fictional personas.** Personas must be grounded in data — interviews, analytics, surveys, support tickets. A persona based on assumptions is a character in a novel, not a research artifact.
- **Do NOT write leading survey questions.** "How much do you love our new feature?" is not research. Use neutral phrasing. Pilot the survey with a colleague to catch bias.
- **Do NOT skip screening for usability tests.** Testing with the wrong participants produces wrong conclusions. A developer testing a consumer app is not a valid participant unless developers are your users.
- **Do NOT present opinions as findings.** "I think users want dark mode" is a hypothesis. "7 of 8 interviewees mentioned eye strain during evening use" is a finding. Label the difference.
- **Do NOT collect data you will not analyze.** Every survey question, interview topic, and analytics event must connect to a research question. Collecting data "just in case" wastes participant time and your own.
- **Do NOT do research after the decision is made.** Research that is commissioned to validate a decision already taken is not research — it is theater. If the decision will not change regardless of findings, save everyone's time.
- **Do NOT generalize from one participant.** One user's passionate complaint is an anecdote. Five users independently describing the same friction is a pattern. Track frequency, not volume.
- **Do NOT ignore negative findings.** Research that only confirms what the team wanted to hear is incomplete. Report findings that challenge assumptions — those are the most valuable.
- **Do NOT combine multiple questions into one survey item.** "Is the app fast and easy to use?" conflates two dimensions. Separate them so responses are interpretable.
- **Do NOT use jargon in research instruments.** Surveys and interview scripts must use the language participants use, not internal product terminology. Pilot with someone outside the team.
