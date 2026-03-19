---
name: strategy
description: |
  Product strategy skill. Activates when user needs to analyze markets, size opportunities, build product roadmaps, define North Star metrics, design growth models, evaluate pricing, make build-vs-buy decisions, assess technical feasibility, analyze competitive moats, or measure product-market fit. Combines quantitative frameworks with strategic reasoning to produce actionable strategy artifacts. Triggers on: /godmode:strategy, "product strategy", "market analysis", "should we build or buy", "what's our moat", "how do we grow", or when the orchestrator detects product-level strategic decisions.
---

# Strategy — Product Strategy

## When to Activate
- User invokes `/godmode:strategy`
- User says "product strategy", "market analysis", "opportunity sizing", "TAM SAM SOM"
- User asks "should we build or buy", "what should we charge", "what's our North Star metric"
- User asks about growth models, acquisition funnels, retention, or virality
- User asks "what's our moat", "how defensible is this", "how do we measure product-market fit"
- When starting a new product or pivoting an existing one
- When `/godmode:think` identifies product direction as the primary concern
- When a product is struggling with growth, retention, or monetization

## Workflow

### Step 1: Product Context & Vision
Understand the product before analyzing strategy:

```
PRODUCT CONTEXT:
Product: <name and one-line description>
Stage: <idea | pre-launch | early (0-1) | growth (1-N) | mature | declining>
Business model: <SaaS | marketplace | transactional | freemium | usage-based | advertising | hardware>
Target customer: <who is the primary user and buyer>
Current state:
  - Users: <current user count or "pre-launch">
  - Revenue: <current MRR/ARR or "pre-revenue">
  - Growth rate: <month-over-month growth or "N/A">
  - Team size: <people working on this product>
  - Runway: <months of funding remaining or "profitable">
Competitive landscape: <crowded | emerging | blue ocean | monopoly-adjacent>
Key question: <the strategic question the user needs answered>
```

### Step 2: Market Analysis & Opportunity Sizing
Quantify the market to determine if the opportunity is worth pursuing:

#### TAM / SAM / SOM Analysis
```
MARKET SIZING:
┌─────────────────────────────────────────────────────────────────────┐
│  TAM (Total Addressable Market)                                     │
│  <description of the broadest relevant market>                      │
│  Method: <top-down from industry reports | bottom-up from units>    │
│  Estimate: $<amount>/year                                           │
│  Basis: <N> potential customers x $<ARPU>/year                      │
├─────────────────────────────────────────────────────────────────────┤
│  SAM (Serviceable Addressable Market)                               │
│  <description of the segment you can realistically serve>           │
│  Constraints: <geography, industry vertical, company size, etc.>    │
│  Estimate: $<amount>/year                                           │
│  Basis: <N> reachable customers x $<ARPU>/year                      │
├─────────────────────────────────────────────────────────────────────┤
│  SOM (Serviceable Obtainable Market)                                │
│  <what you can capture in 2-3 years given current resources>        │
│  Assumptions: <market share %, conversion rate, growth trajectory>  │
│  Estimate: $<amount>/year                                           │
│  Basis: <N> capturable customers x $<ARPU>/year                     │
└─────────────────────────────────────────────────────────────────────┘

MARKET DYNAMICS:
Growth rate: <market CAGR>
Tailwinds: <trends making this market grow>
Headwinds: <trends that could shrink or constrain this market>
Timing: <why now — what changed to create the opportunity>
```

#### Bottom-Up Validation
```
BOTTOM-UP CROSS-CHECK:
Customer segments:
  Segment A: <N> prospects x <conversion>% x $<ARPU> = $<revenue>/year
  Segment B: <N> prospects x <conversion>% x $<ARPU> = $<revenue>/year
  Segment C: <N> prospects x <conversion>% x $<ARPU> = $<revenue>/year
  Total bottom-up SOM: $<amount>/year

Top-down vs bottom-up delta: <percentage>
Confidence: <HIGH if within 2x | MEDIUM if within 5x | LOW if >5x>
```

### Step 3: North Star Metric Definition
Define the single metric that best captures the value the product delivers:

```
NORTH STAR METRIC:
┌─────────────────────────────────────────────────────────────────────┐
│  Metric: <name of the metric>                                       │
│  Definition: <precise, unambiguous calculation>                     │
│  Current value: <number or "unmeasured">                            │
│  Target (6 months): <number>                                        │
│  Target (12 months): <number>                                       │
│                                                                     │
│  Why this metric:                                                   │
│  1. Reflects value delivered to customers: <explanation>             │
│  2. Leading indicator of revenue: <correlation explanation>          │
│  3. Actionable by the team: <what levers move it>                   │
│                                                                     │
│  ALTERNATIVES CONSIDERED:                                           │
│  ┌──────────────────┬──────────────────┬────────────────────────┐   │
│  │ Metric           │ Why Rejected     │ Role Instead           │   │
│  ├──────────────────┼──────────────────┼────────────────────────┤   │
│  │ <metric A>       │ <reason>         │ Input metric           │   │
│  │ <metric B>       │ <reason>         │ Guardrail metric       │   │
│  │ <metric C>       │ <reason>         │ Team-level KPI         │   │
│  └──────────────────┴──────────────────┴────────────────────────┘   │
│                                                                     │
│  METRIC ECOSYSTEM:                                                  │
│  North Star: <metric>                                               │
│    ├── Input metric 1: <metric that feeds into North Star>          │
│    ├── Input metric 2: <metric that feeds into North Star>          │
│    ├── Input metric 3: <metric that feeds into North Star>          │
│    └── Guardrail metrics: <metrics that must not degrade>           │
└─────────────────────────────────────────────────────────────────────┘
```

North Star selection criteria:
- Must reflect value the customer receives, not just business output
- Must be a leading indicator of revenue (not revenue itself, which is lagging)
- Must be measurable with current or near-term instrumentation
- Must be movable by the product team through their own actions
- Must be simple enough that the entire company can understand it

### Step 4: Growth Model Design
Map the full growth engine across all five AARRR stages:

```
GROWTH MODEL:
┌─────────────────────────────────────────────────────────────────────┐
│  ACQUISITION — How do users discover the product?                   │
│                                                                     │
│  Channels:                                                          │
│  ┌──────────────────┬──────────┬──────────┬──────────┬───────────┐ │
│  │ Channel          │ Volume   │ CAC      │ Quality  │ Scalable? │ │
│  ├──────────────────┼──────────┼──────────┼──────────┼───────────┤ │
│  │ <organic search> │ <vol>    │ $<cac>   │ <H/M/L> │ <yes/no>  │ │
│  │ <paid ads>       │ <vol>    │ $<cac>   │ <H/M/L> │ <yes/no>  │ │
│  │ <content/SEO>    │ <vol>    │ $<cac>   │ <H/M/L> │ <yes/no>  │ │
│  │ <referral>       │ <vol>    │ $<cac>   │ <H/M/L> │ <yes/no>  │ │
│  │ <partnerships>   │ <vol>    │ $<cac>   │ <H/M/L> │ <yes/no>  │ │
│  │ <virality>       │ <vol>    │ $<cac>   │ <H/M/L> │ <yes/no>  │ │
│  └──────────────────┴──────────┴──────────┴──────────┴───────────┘ │
│  Primary channel: <channel with best CAC-to-LTV ratio>              │
│  Channel risk: <over-reliance on single channel>                    │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  ACTIVATION — How do users experience the "aha moment"?             │
│                                                                     │
│  Aha moment: <the action that correlates with long-term retention>  │
│  Time-to-value: <how long from signup to aha moment>                │
│  Current activation rate: <% of signups reaching aha moment>        │
│  Target activation rate: <%>                                        │
│                                                                     │
│  Activation funnel:                                                 │
│    Signup ──> <step 1> ──> <step 2> ──> Aha moment                  │
│    100%       <rate>%      <rate>%      <rate>%                     │
│                                                                     │
│  Biggest drop-off: <step with largest falloff>                      │
│  Intervention: <what to do about it>                                │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  RETENTION — How do users come back?                                │
│                                                                     │
│  Usage frequency: <daily | weekly | monthly | transactional>        │
│  Retention curve:                                                   │
│    Day 1: <rate>%                                                   │
│    Day 7: <rate>%                                                   │
│    Day 30: <rate>%                                                  │
│    Day 90: <rate>%                                                  │
│  Curve shape: <flattening (good) | declining (bad) | smile (great)>│
│  Retention driver: <what brings users back — habit, trigger, need>  │
│  Churn risk: <what causes users to leave>                           │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  REFERRAL — How do users bring other users?                         │
│                                                                     │
│  Viral mechanism: <invite, share, embed, word-of-mouth, network fx>│
│  Viral coefficient (K): <number of new users each user brings>      │
│  Viral cycle time: <days from user join to referral conversion>     │
│  K target: <target K value — K > 1 = exponential growth>            │
│  Referral incentive: <what motivates sharing>                       │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  REVENUE — How does the product make money?                         │
│                                                                     │
│  Revenue model: <subscription | transaction | usage | freemium>     │
│  ARPU: $<amount>/<period>                                           │
│  LTV: $<amount> (ARPU x avg lifespan in months)                    │
│  LTV:CAC ratio: <ratio> (target: > 3:1)                            │
│  Payback period: <months to recover CAC>                            │
│  Expansion revenue: <upsell, cross-sell, seat expansion rate>       │
│  Net revenue retention: <percentage — >100% means expansion > churn>│
└─────────────────────────────────────────────────────────────────────┘

GROWTH BOTTLENECK:
Current constraint: <which AARRR stage is the weakest?>
Impact: <what would a 10% improvement here mean for the business?>
Recommended focus: <which stage to invest in next and why>
```

### Step 5: Feature Prioritization
Apply data-driven frameworks to decide what to build next:

#### RICE Scoring
```
FEATURE PRIORITIZATION (RICE):
┌──────────────────────┬───────┬────────┬────────────┬────────┬───────┐
│ Feature              │ Reach │ Impact │ Confidence │ Effort │ RICE  │
├──────────────────────┼───────┼────────┼────────────┼────────┼───────┤
│ <feature 1>          │ <N>   │ <0-3>  │ <0-100%>   │ <wks>  │ <score>│
│ <feature 2>          │ <N>   │ <0-3>  │ <0-100%>   │ <wks>  │ <score>│
│ <feature 3>          │ <N>   │ <0-3>  │ <0-100%>   │ <wks>  │ <score>│
│ ...                  │       │        │            │        │       │
└──────────────────────┴───────┴────────┴────────────┴────────┴───────┘

Impact scale: 3=massive, 2=high, 1=medium, 0.5=low, 0.25=minimal
RICE = (Reach x Impact x Confidence) / Effort
```

#### Value vs Effort Matrix
```
FEATURE MAP:
                    HIGH VALUE
                        |
    Quick Wins          |     Strategic Bets
    (Ship this sprint)  |     (Roadmap next quarter)
                        |
  LOW EFFORT -----------+------------ HIGH EFFORT
                        |
    Low-Hanging Fruit   |     Icebox
    (Delegate or batch) |     (Revisit with new data)
                        |
                    LOW VALUE

QUICK WINS: <feature list — do immediately>
STRATEGIC BETS: <feature list — plan carefully, high-conviction only>
LOW-HANGING FRUIT: <feature list — batch into a polish sprint>
ICEBOX: <feature list — explicitly deprioritized with reasoning>
```

#### Opportunity Scoring (Outcome-Driven Innovation)
```
OPPORTUNITY SCORING:
┌──────────────────────────┬────────────┬──────────────┬─────────────┐
│ Job-to-be-Done           │ Importance │ Satisfaction │ Opportunity │
├──────────────────────────┼────────────┼──────────────┼─────────────┤
│ <job 1>                  │ <1-10>     │ <1-10>       │ <score>     │
│ <job 2>                  │ <1-10>     │ <1-10>       │ <score>     │
│ <job 3>                  │ <1-10>     │ <1-10>       │ <score>     │
└──────────────────────────┴────────────┴──────────────┴─────────────┘

Opportunity = Importance + max(Importance - Satisfaction, 0)
Overserved (Importance < Satisfaction): reduce investment
Underserved (Importance > Satisfaction): biggest opportunity
```

### Step 6: Product Roadmap Creation
Organize prioritized features into a time-phased roadmap:

```
PRODUCT ROADMAP:
┌─────────────────────────────────────────────────────────────────────┐
│  VISION: <one-sentence product vision>                              │
│  NORTH STAR: <metric> — current: <value> — target: <value>         │
│  PLANNING HORIZON: <3 months | 6 months | 12 months>               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  NOW (Current Quarter)                                              │
│  Theme: <what the team is focused on>                               │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Feature/Initiative  │ Goal / Success Metric  │ Effort │ Owner │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ <feature 1>         │ <outcome metric>       │ <wks>  │ <team>│ │
│  │ <feature 2>         │ <outcome metric>       │ <wks>  │ <team>│ │
│  │ <feature 3>         │ <outcome metric>       │ <wks>  │ <team>│ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  NEXT (Next Quarter)                                                │
│  Theme: <what the team will focus on next>                          │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Feature/Initiative  │ Goal / Hypothesis      │ Effort │ Conf. │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ <initiative 1>      │ <expected outcome>     │ <est>  │ <H/M> │ │
│  │ <initiative 2>      │ <expected outcome>     │ <est>  │ <H/M> │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  LATER (2+ Quarters Out)                                            │
│  Theme: <directional bets, not commitments>                         │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Initiative          │ Hypothesis             │ Depends On      │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ <bet 1>             │ <if X then Y>          │ <prerequisite>  │ │
│  │ <bet 2>             │ <if X then Y>          │ <prerequisite>  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  NOT DOING (Explicitly Out of Scope)                                │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Item                │ Reason                                   │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ <item>              │ <why it's deprioritized>                 │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

Roadmap principles:
- NOW items are commitments with specific metrics and owners
- NEXT items are high-confidence plans with estimated effort
- LATER items are hypotheses, not promises — they will change
- NOT DOING is as important as what you are doing — it prevents scope creep

### Step 7: Pricing Strategy Analysis
Evaluate pricing model, positioning, and willingness-to-pay:

```
PRICING ANALYSIS:
┌─────────────────────────────────────────────────────────────────────┐
│  PRICING MODEL EVALUATION                                           │
│                                                                     │
│  ┌───────────────────┬──────────────────┬──────────────────────┐    │
│  │ Model             │ Pros             │ Cons                 │    │
│  ├───────────────────┼──────────────────┼──────────────────────┤    │
│  │ Flat-rate sub     │ Simple, predict- │ Leaves money on      │    │
│  │                   │ able revenue     │ table with power     │    │
│  │                   │                  │ users                │    │
│  ├───────────────────┼──────────────────┼──────────────────────┤    │
│  │ Tiered            │ Captures diff    │ Tier boundaries      │    │
│  │                   │ willingness to   │ create friction,     │    │
│  │                   │ pay              │ complexity           │    │
│  ├───────────────────┼──────────────────┼──────────────────────┤    │
│  │ Usage-based       │ Aligns cost with │ Revenue harder to    │    │
│  │                   │ value, low entry │ predict, bill shock  │    │
│  ├───────────────────┼──────────────────┼──────────────────────┤    │
│  │ Per-seat          │ Simple, scales   │ Discourages adoption │    │
│  │                   │ with org size    │ within org           │    │
│  ├───────────────────┼──────────────────┼──────────────────────┤    │
│  │ Freemium          │ Reduces friction │ Free users cost      │    │
│  │                   │ for adoption     │ money, conversion    │    │
│  │                   │                  │ can be low           │    │
│  └───────────────────┴──────────────────┴──────────────────────┘    │
│                                                                     │
│  RECOMMENDED MODEL: <model>                                         │
│  Value metric: <what the customer pays for — the unit of value>     │
│  Reasoning: <why this model aligns with how customers get value>    │
│                                                                     │
│  PRICING TIERS:                                                     │
│  ┌───────────┬──────────────┬──────────────┬──────────────────┐     │
│  │ Tier      │ Price        │ Includes     │ Target Segment   │     │
│  ├───────────┼──────────────┼──────────────┼──────────────────┤     │
│  │ Free      │ $0           │ <limits>     │ <who>            │     │
│  │ Pro       │ $<price>/mo  │ <limits>     │ <who>            │     │
│  │ Team      │ $<price>/mo  │ <limits>     │ <who>            │     │
│  │ Enterprise│ Custom       │ <limits>     │ <who>            │     │
│  └───────────┴──────────────┴──────────────┴──────────────────┘     │
│                                                                     │
│  COMPETITIVE PRICING CONTEXT:                                       │
│  ┌───────────────┬──────────────┬───────────────────────────────┐   │
│  │ Competitor    │ Price        │ Positioning                   │   │
│  ├───────────────┼──────────────┼───────────────────────────────┤   │
│  │ <comp A>      │ $<price>     │ <premium | mid | budget>      │   │
│  │ <comp B>      │ $<price>     │ <premium | mid | budget>      │   │
│  │ <comp C>      │ $<price>     │ <premium | mid | budget>      │   │
│  │ YOUR PRODUCT  │ $<price>     │ <where you position>          │   │
│  └───────────────┴──────────────┴───────────────────────────────┘   │
│                                                                     │
│  LTV PROJECTION:                                                    │
│  ARPU: $<amount>/mo                                                 │
│  Avg lifespan: <months>                                             │
│  Gross margin: <%>                                                  │
│  LTV: $<amount>                                                     │
│  LTV:CAC target: > 3:1                                              │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 8: Build vs Buy Decision
Evaluate whether to build in-house, buy/license, or use open source:

```
BUILD VS BUY ANALYSIS:
┌─────────────────────────────────────────────────────────────────────┐
│  Capability: <what needs to be solved>                              │
│  Strategic importance: <core differentiator | important | commodity>│
│                                                                     │
│  ┌──────────────────┬──────────────┬──────────────┬──────────────┐  │
│  │ Criterion        │ Build        │ Buy/License  │ Open Source  │  │
│  ├──────────────────┼──────────────┼──────────────┼──────────────┤  │
│  │ Upfront cost     │ $<eng hours> │ $<license>   │ $<integ hrs> │  │
│  │ Ongoing cost     │ $<maint/yr>  │ $<annual>    │ $<maint/yr>  │  │
│  │ Time to value    │ <weeks>      │ <days/weeks> │ <weeks>      │  │
│  │ Customizability  │ Full         │ Limited      │ Moderate     │  │
│  │ Vendor risk      │ None         │ Lock-in      │ Abandonment  │  │
│  │ Maintenance load │ High         │ Low          │ Medium       │  │
│  │ Competitive edge │ <H/M/L>     │ <H/M/L>     │ <H/M/L>     │  │
│  │ Team capability  │ <H/M/L>     │ N/A          │ <H/M/L>     │  │
│  │ 3-year TCO       │ $<total>     │ $<total>     │ $<total>     │  │
│  └──────────────────┴──────────────┴──────────────┴──────────────┘  │
│                                                                     │
│  DECISION FRAMEWORK:                                                │
│  Core differentiator + team has capability     → BUILD              │
│  Core differentiator + team lacks capability   → BUILD + HIRE       │
│  Important but not differentiating             → BUY if exists      │
│  Commodity / solved problem                    → BUY or OPEN SOURCE │
│                                                                     │
│  RECOMMENDATION: <BUILD | BUY | OPEN SOURCE>                       │
│  Reasoning: <1-2 sentences tied to strategic importance and TCO>    │
│  Risk mitigation: <what to do if the choice doesn't work out>       │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 9: Competitive Moat Analysis
Assess how defensible the product's position is:

```
COMPETITIVE MOAT ANALYSIS:
┌─────────────────────────────────────────────────────────────────────┐
│  MOAT TYPE ASSESSMENT                                               │
│                                                                     │
│  ┌─────────────────────┬──────────┬────────────────────────────┐    │
│  │ Moat Type           │ Strength │ Evidence / Status           │    │
│  ├─────────────────────┼──────────┼────────────────────────────┤    │
│  │ Network effects     │ <0-5>    │ <does value increase with  │    │
│  │                     │          │  more users? how?>          │    │
│  ├─────────────────────┼──────────┼────────────────────────────┤    │
│  │ Switching costs     │ <0-5>    │ <how hard is it to leave?  │    │
│  │                     │          │  data lock-in, integrations,│    │
│  │                     │          │  workflow dependency>       │    │
│  ├─────────────────────┼──────────┼────────────────────────────┤    │
│  │ Economies of scale  │ <0-5>    │ <does unit cost decrease   │    │
│  │                     │          │  with scale? how?>          │    │
│  ├─────────────────────┼──────────┼────────────────────────────┤    │
│  │ Brand / trust       │ <0-5>    │ <brand recognition, NPS,   │    │
│  │                     │          │  community, reputation>     │    │
│  ├─────────────────────┼──────────┼────────────────────────────┤    │
│  │ Data advantage      │ <0-5>    │ <proprietary data that     │    │
│  │                     │          │  improves the product>      │    │
│  ├─────────────────────┼──────────┼────────────────────────────┤    │
│  │ Regulatory / legal  │ <0-5>    │ <patents, licenses,        │    │
│  │                     │          │  compliance barriers>       │    │
│  ├─────────────────────┼──────────┼────────────────────────────┤    │
│  │ Technical IP        │ <0-5>    │ <proprietary tech that is  │    │
│  │                     │          │  hard to replicate>         │    │
│  └─────────────────────┴──────────┴────────────────────────────┘    │
│                                                                     │
│  OVERALL MOAT RATING: <NONE | NARROW | WIDE>                       │
│                                                                     │
│  Primary moat: <strongest moat type and why>                        │
│  Moat trajectory: <strengthening | stable | eroding>                │
│                                                                     │
│  COMPETITIVE LANDSCAPE:                                             │
│  ┌───────────────┬──────────────────┬──────────┬────────────────┐   │
│  │ Competitor    │ Positioning      │ Moat     │ Threat Level   │   │
│  ├───────────────┼──────────────────┼──────────┼────────────────┤   │
│  │ <comp A>      │ <how they win>   │ <type>   │ <HIGH/MED/LOW> │   │
│  │ <comp B>      │ <how they win>   │ <type>   │ <HIGH/MED/LOW> │   │
│  │ <comp C>      │ <how they win>   │ <type>   │ <HIGH/MED/LOW> │   │
│  │ YOUR PRODUCT  │ <how you win>    │ <type>   │ N/A            │   │
│  └───────────────┴──────────────────┴──────────┴────────────────┘   │
│                                                                     │
│  MOAT-BUILDING ACTIONS:                                             │
│  1. <action to strengthen primary moat — expected impact>           │
│  2. <action to build secondary moat — expected impact>              │
│  3. <action to counter competitor threat — expected impact>         │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 10: Technical Feasibility Assessment
Evaluate whether the product strategy is technically achievable:

```
TECHNICAL FEASIBILITY ASSESSMENT:
┌─────────────────────────────────────────────────────────────────────┐
│  INITIATIVE: <feature or product initiative being assessed>         │
│                                                                     │
│  ┌─────────────────────────┬──────────┬────────────────────────┐    │
│  │ Dimension               │ Rating   │ Assessment             │    │
│  ├─────────────────────────┼──────────┼────────────────────────┤    │
│  │ Technical complexity    │ <H/M/L>  │ <known vs novel tech,  │    │
│  │                         │          │  algorithm difficulty>  │    │
│  ├─────────────────────────┼──────────┼────────────────────────┤    │
│  │ Team capability         │ <H/M/L>  │ <does the team have    │    │
│  │                         │          │  the required skills?>  │    │
│  ├─────────────────────────┼──────────┼────────────────────────┤    │
│  │ Infrastructure readiness│ <H/M/L>  │ <can current infra     │    │
│  │                         │          │  support this?>         │    │
│  ├─────────────────────────┼──────────┼────────────────────────┤    │
│  │ Data availability       │ <H/M/L>  │ <do we have the data   │    │
│  │                         │          │  needed?>               │    │
│  ├─────────────────────────┼──────────┼────────────────────────┤    │
│  │ Third-party deps        │ <H/M/L>  │ <external APIs, libs,  │    │
│  │                         │          │  vendor dependencies>   │    │
│  ├─────────────────────────┼──────────┼────────────────────────┤    │
│  │ Timeline confidence     │ <H/M/L>  │ <can we ship in the    │    │
│  │                         │          │  required timeframe?>   │    │
│  └─────────────────────────┴──────────┴────────────────────────┘    │
│                                                                     │
│  FEASIBILITY VERDICT: <FEASIBLE | FEASIBLE WITH CAVEATS | RISKY |  │
│                         NOT FEASIBLE>                               │
│                                                                     │
│  Key risks:                                                         │
│  1. <risk — probability — impact — mitigation>                      │
│  2. <risk — probability — impact — mitigation>                      │
│                                                                     │
│  Recommended approach:                                              │
│  <full build | phased rollout | prototype first | spike then decide>│
│                                                                     │
│  Unknown unknowns to spike:                                         │
│  1. <question that must be answered before committing>              │
│  2. <question that must be answered before committing>              │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 11: Product-Market Fit Measurement
Assess whether the product has achieved product-market fit:

```
PRODUCT-MARKET FIT SCORECARD:
┌─────────────────────────────────────────────────────────────────────┐
│  QUANTITATIVE SIGNALS                                               │
│                                                                     │
│  Sean Ellis Test:                                                   │
│    "How would you feel if you could no longer use <product>?"       │
│    Very disappointed: <percentage>% (target: > 40%)                 │
│    Somewhat disappointed: <percentage>%                              │
│    Not disappointed: <percentage>%                                   │
│    PMF signal: <STRONG | EMERGING | WEAK>                           │
│                                                                     │
│  Retention:                                                         │
│    Week 1: <rate>% | Week 4: <rate>% | Week 12: <rate>%            │
│    Curve shape: <flattening (PMF) | declining (no PMF)>             │
│                                                                     │
│  NPS: <score> (target: > 50 for strong PMF)                        │
│                                                                     │
│  Organic growth: <percentage>% of new users from word-of-mouth      │
│  (target: > 50% for strong PMF)                                     │
│                                                                     │
│  Revenue signals:                                                   │
│    MRR growth rate: <%/month>                                       │
│    Net revenue retention: <%> (target: > 100%)                      │
│    Expansion revenue: <%> of total new MRR                          │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  QUALITATIVE SIGNALS                                                │
│                                                                     │
│  ┌───────────────────────────────┬──────────┬──────────────────┐    │
│  │ Signal                        │ Present? │ Evidence         │    │
│  ├───────────────────────────────┼──────────┼──────────────────┤    │
│  │ Users pull (not pushed)       │ <Y/N>    │ <inbound demand?>│    │
│  │ Users hack workarounds        │ <Y/N>    │ <creative usage?>│    │
│  │ Users refer unprompted        │ <Y/N>    │ <organic refs?>  │    │
│  │ Users complain about downtime │ <Y/N>    │ <dependency?>    │    │
│  │ Sales cycle shortening        │ <Y/N>    │ <faster close?>  │    │
│  │ Usage growing without prompts │ <Y/N>    │ <organic usage?> │    │
│  └───────────────────────────────┴──────────┴──────────────────┘    │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  PMF VERDICT: <PRE-PMF | APPROACHING PMF | PMF ACHIEVED |          │
│                STRONG PMF>                                          │
│                                                                     │
│  If PRE-PMF:                                                        │
│    Biggest gap: <what's missing between product and market need>    │
│    Next experiment: <what to test to move toward PMF>               │
│    Kill criteria: <when to pivot — what signals say "this won't     │
│                    work">                                            │
│                                                                     │
│  If PMF ACHIEVED:                                                   │
│    Growth mode: <ready to scale acquisition and invest in growth>   │
│    Risk: <what could erode PMF — market shift, competitor, churn>   │
└─────────────────────────────────────────────────────────────────────┘
```

### Step 12: Strategy Synthesis & Artifacts
Produce the final strategy document:

1. Save strategy document: `docs/strategy/<product>-strategy.md`
2. Save roadmap: `docs/strategy/<product>-roadmap.md`
3. Commit: `"strategy: <product> — <key strategic insight or decision>"`
4. Suggest next steps:
   - "Strategy defined. Run `/godmode:architect` to design the system architecture."
   - "Growth model mapped. Run `/godmode:analytics` to instrument the funnel."
   - "Pricing analyzed. Run `/godmode:ship` to launch the pricing update."
   - "Pre-PMF identified. Run `/godmode:scenario` to evaluate pivot options."

## Key Behaviors

1. **Data before opinions.** Every strategic recommendation must reference data, benchmarks, or structured frameworks. "I think we should build X" is not strategy. A RICE-scored feature list with market sizing is strategy.
2. **Frameworks are tools, not answers.** RICE, TAM/SAM/SOM, and AARRR are lenses for structured thinking. They do not replace judgment. When the framework output contradicts domain knowledge, investigate the gap rather than blindly following the score.
3. **Quantify everything possible.** Market sizes in dollars. Feature priority in RICE scores. Retention in percentages. Growth in rates. Moat strength in 0-5 ratings. Numbers enable comparison; adjectives enable arguments.
4. **Name the stage, then prescribe.** Strategy for a pre-PMF startup is fundamentally different from strategy for a growth-stage product. Always identify the product stage first and tailor every recommendation to it.
5. **Strategy is about saying no.** A roadmap with 50 items and no "Not Doing" section is not a strategy. Every "yes" must imply a clear "not this." Make trade-offs explicit.
6. **Moats compound, features don't.** Prioritize work that strengthens defensibility over work that adds one-off features. Network effects, switching costs, and data advantages get stronger over time. A new button does not.
7. **Validate before scaling.** Never recommend scaling acquisition before retention is healthy. Pouring users into a leaky bucket is expensive and teaches the wrong lessons. Fix retention first.
8. **Build vs buy defaults to buy for non-core.** The default for anything that is not a core differentiator should be to buy, license, or use open source. Engineering time is the scarcest resource.

## Example Usage

### Full product strategy for a new SaaS
```
User: /godmode:strategy We're building a developer productivity tool that
      automates code review. Pre-launch, team of 5, $500K seed funding.

Strategy: Gathering product context...

PRODUCT CONTEXT:
Product: CodeBot — Automated code review for engineering teams
Stage: Pre-launch (0-1)
Business model: SaaS (freemium with paid tiers)
Target customer: Engineering teams at mid-market companies (50-500 eng)
Current state: Pre-launch, pre-revenue, 18 months runway
Competitive landscape: Emerging (GitHub Copilot adjacent, few direct competitors)

MARKET SIZING:
TAM: $8.2B/year (global code quality tools market)
SAM: $1.2B/year (automated code review for English-speaking mid-market)
SOM: $12M/year (500 teams x $24K/year in 3 years)

NORTH STAR METRIC: Weekly active code reviews completed
Why: Reflects value delivered (reviews done), correlates with retention
     and expansion, movable by the team.

GROWTH BOTTLENECK: Activation (pre-launch, focus on time-to-first-review)

MOAT: Narrow — data advantage (improves with every codebase it reviews)
MOAT-BUILDING: Focus on proprietary training data from early adopters

Shall I produce the full roadmap and pricing analysis?
```

### Evaluating a pricing change
```
User: /godmode:strategy --pricing We charge $49/user/month but growth is
      stalling. Should we change our pricing model?

Strategy: Analyzing pricing...

Current model: Per-seat ($49/user/month)
Problem: Per-seat discourages adoption — champions can't get budget for
         full team rollout. Only 3 seats per account on average.

RECOMMENDATION: Switch to tiered (team-based) pricing.
  Free: 1 user, 5 reviews/month (acquisition funnel)
  Team ($199/mo): Up to 20 users, unlimited reviews
  Enterprise (custom): SSO, audit logs, dedicated support

Expected impact:
  Seats per account: 3 → 12 (remove per-seat friction)
  ARPU: $147/mo → $199/mo (higher despite lower per-seat)
  Conversion rate: +30% (free tier reduces barrier)
  LTV:CAC improvement: 2.1:1 → 3.8:1
```

### Build vs buy decision
```
User: /godmode:strategy --build-vs-buy Should we build our own auth
      system or use Auth0/Clerk?

Strategy: Evaluating build vs buy...

Capability: Authentication and user management
Strategic importance: COMMODITY (not a differentiator)

RECOMMENDATION: BUY (Auth0 or Clerk)
  Build cost: $120K (8 eng-weeks at $15K/week) + $40K/year maintenance
  Buy cost: $3K/year at current scale, $25K/year at 10K users
  3-year TCO: Build $240K vs Buy $53K
  Time to value: Build 8 weeks vs Buy 2 days

Auth is a commodity. Every week spent on auth is a week not spent on
your core differentiator (automated code review). Buy.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full product strategy analysis across all dimensions |
| `--market` | Market analysis and opportunity sizing (TAM/SAM/SOM) only |
| `--roadmap` | Product roadmap creation only |
| `--prioritize` | Feature prioritization with RICE/value-effort only |
| `--northstar` | North Star metric definition only |
| `--growth` | Growth model design (AARRR funnel) only |
| `--pricing` | Pricing strategy analysis only |
| `--build-vs-buy` | Build vs buy decision framework only |
| `--feasibility` | Technical feasibility assessment only |
| `--moat` | Competitive moat analysis only |
| `--pmf` | Product-market fit measurement only |
| `--quick` | Executive summary — one page, top-line insights only |
| `--stage <stage>` | Override product stage: `idea`, `pre-launch`, `early`, `growth`, `mature` |

## Anti-Patterns

- **Do NOT skip product context.** Strategy without understanding the product's stage, team, and constraints is generic advice. A pre-PMF startup and a growth-stage company need opposite strategies. Ask first.
- **Do NOT present market sizing without a bottom-up cross-check.** Top-down TAM numbers from industry reports are meaningless without a bottom-up validation from customer segments. If the two numbers diverge by more than 5x, the sizing is unreliable.
- **Do NOT recommend scaling before retention is healthy.** Acquisition spend with poor retention is burning money. Fix the leaky bucket before pouring more users in. Always check retention before recommending growth investment.
- **Do NOT define North Star metrics that the team cannot influence.** Revenue, stock price, and market share are outcomes, not North Star metrics. A North Star must be directly movable through product and engineering work.
- **Do NOT build a roadmap without a "Not Doing" section.** A roadmap without explicit exclusions is a wish list, not a strategy. Saying no is the hardest and most important part of product strategy.
- **Do NOT default to "build" for non-core capabilities.** Engineering time is the most expensive resource. If auth, payments, email, search, or analytics are not your core differentiator, buy or use open source. Save engineering time for what makes you unique.
- **Do NOT confuse features with moats.** A feature can be copied in weeks. A moat takes years to build. Prioritize network effects, data advantages, and switching costs over feature lists.
- **Do NOT present a single pricing option.** Always evaluate at least 2-3 pricing models with trade-offs. Pricing decisions have enormous revenue impact and deserve the same rigor as architecture decisions.
- **Do NOT ignore the competitive landscape.** Strategy in a vacuum is fiction. Always analyze who else is solving this problem and what their moat is. Your strategy must account for their existence.
- **Do NOT treat strategy as a one-time exercise.** Product stage changes, markets shift, competitors move. Strategy should be revisited at least quarterly or after any major signal change (PMF shift, funding, competitor launch).
