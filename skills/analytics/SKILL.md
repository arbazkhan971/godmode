---
name: analytics
description: |
  Analytics implementation skill. Activates when users need to design and implement product analytics, event tracking,
    funnel analysis, A/B test instrumentation, or privacy-respecting analytics. Supports Segment, Amplitude, Mixpanel,
    PostHog, Plausible, and Umami. Provides structured event taxonomies, data modeling, funnel design, and experiment
    instrumentation with full privacy compliance. Triggers on: /godmode:analytics, "add analytics", "track events",
    "set up A/B testing", "implement funnels", or when the orchestrator detects analytics-related work.
---

# Analytics — Analytics Implementation

## When to Activate
- User invokes `/godmode:analytics`
- User says "add analytics", "track events", "set up tracking"
- User says "create a funnel", "A/B test", "implement experiments"
- User says "add Segment", "set up Amplitude", "configure Mixpanel", "add PostHog"
- User says "privacy-friendly analytics", "GDPR-compliant tracking", "cookieless analytics"
- When building new features that need usage measurement
- When `/godmode:plan` identifies analytics instrumentation tasks

## Workflow

### Step 1: Analytics Strategy Discovery
Understand what needs to be measured and why:

```
ANALYTICS DISCOVERY:
Project: <name and purpose>
Goals:
  - <business goal 1 — e.g., increase conversion rate>
  - <business goal 2 — e.g., reduce churn>
  - <business goal 3 — e.g., improve feature adoption>
Key questions to answer:
  - <question 1 — e.g., "Where do users drop off in onboarding?">
  - <question 2 — e.g., "Which features correlate with retention?">
  - <question 3 — e.g., "What is our activation rate?">
Platform: <web | mobile | both | server-side>
Framework: <React | Next.js | Vue | React Native | iOS | Android | backend>
Privacy requirements: <GDPR | CCPA | HIPAA | none | strict — no third-party>
Existing analytics: <none | GA4 | Segment | Amplitude | Mixpanel | custom>
Budget: <free tier | startup plan | enterprise>
```
If the user hasn't specified, ask: "What do you want to learn about your users? What decisions will this data inform?"

### Step 2: Analytics Platform Selection
Choose the right analytics stack:

```
PLATFORM SELECTION:
| Platform | Best For | Privacy Model |
|--|--|--|
| Segment | Data routing hub, | Third-party, consent needed |
|  | multi-destination CDP | GDPR tools available |
| Amplitude | Product analytics, | Third-party, consent needed |
|  | behavioral cohorts, | SOC 2, GDPR compliant |
|  | journey mapping |  |
| Mixpanel | Event analytics, | Third-party, consent needed |
|  | funnel analysis, | EU data residency available |
|  | retention tracking |  |
```
### Step 3: Event Taxonomy Design
Design a structured, consistent event naming system:

```
EVENT TAXONOMY:
Naming convention: <Object Action> (e.g., "Button Clicked", "Page Viewed")

Format: <object>_<action> (snake_case) or <Object> <Action> (Title Case)
Selected: <format>

EVENT CATALOG:
| Event Name | Trigger | Properties |
  LIFECYCLE EVENTS
| User Signed Up | Server | method, referral_source, |
|  |  | plan |
| User Logged In | Server | method, mfa_used |
```
### Step 4: Event Property Standards
Define property types and validation:

```
PROPERTY STANDARDS:

GLOBAL PROPERTIES (sent with every event):
  user_id: string (anonymous ID or authenticated user ID)
  session_id: string (unique per session)
  timestamp: ISO 8601 datetime
  platform: "web" | "ios" | "android"
  app_version: string (semver)
  device_type: "desktop" | "tablet" | "mobile"
  browser: string (web only)
  os: string
  locale: string (BCP 47 — e.g., "en-US")
  experiment_ids: string[] (active A/B test assignments)

USER PROPERTIES (set once, updated on change):
```
### Step 5: Implementation
Implement analytics tracking in the codebase:

#### Provider Setup
Configure the selected provider SDK (Segment, Amplitude, PostHog, etc.) with environment-keyed initialization.
Build a unified abstraction layer (`AnalyticsProvider` interface with `track`, `identify`, `page` methods) so
you swap providers without touching component code.

### Step 6: Funnel Analysis Setup
Design and instrument conversion funnels:

```
FUNNEL DESIGN:
Funnel name: <name — e.g., "Onboarding Funnel">
Goal: <what conversion means — e.g., "User completes onboarding">

FUNNEL STEPS:
| Step | Name | Event | Expected % |
|--|--|--|--|
| 1 | Visit landing page | Page Viewed | 100% |
| 2 | Click sign up | CTA Clicked | 30-40% |
| 3 | Complete registration | User Signed Up | 60-70% |
| 4 | Start onboarding flow | Onboarding Started | 80-90% |
| 5 | Complete onboarding | Onboarding Done | 50-60% |
| 6 | First core action | Feature Used | 40-50% |
| 7 | Activation (aha moment) | Activation Done | 30-40% |
```
### Step 7: A/B Test Instrumentation
Design and instrument experiments:

```
EXPERIMENT DESIGN:
Name: <experiment name>
Hypothesis: <if we change X, then Y will improve by Z%>
Primary metric: <metric to optimize — e.g., conversion rate>
Secondary metrics: <guardrail metrics to monitor — e.g., session duration, error rate>
Minimum detectable effect: <smallest meaningful change — e.g., 5% relative improvement>
Required sample size: <calculated based on MDE, baseline, significance level>
Duration: <estimated experiment duration>
Significance level: alpha = 0.05
Power: 1 - beta = 0.80

VARIANTS:
| Variant | Description | Traffic % |
```
#### Experiment Implementation
```typescript
// experiments/ab-test.ts
interface Experiment {
  id: string;
  name: string;
  variants: { id: string; weight: number }[];
  isActive: boolean;
```

### Step 8: Analytics Data Modeling

```
DATA MODEL (3 core tables):
  EVENTS: event_id (PK), event_name (indexed), user_id (indexed), session_id,
          timestamp (partitioned by day), properties (JSONB), context (JSONB)
  USERS:  user_id (PK), traits (JSONB), first_seen, last_seen, event_count
  SESSIONS: session_id (PK), user_id (indexed), started_at, ended_at,
            duration_sec, entry_page, exit_page, device_type, utm_*

COMMON QUERIES:
  - DAU/WAU/MAU: COUNT(DISTINCT user_id) WHERE timestamp >= <period>
  - Retention: cohort analysis grouping by first_seen week
  - Funnel: sequential event matching with time constraints
  - Feature adoption: COUNT(DISTINCT user_id) WHERE event_name = '<feature>'
```
### Step 9: Privacy & Consent
Implement privacy-compliant analytics:

```
PRIVACY IMPLEMENTATION:
| Requirement | Implementation |
|--|--|
| Consent management | Cookie banner with granular |
|  | opt-in/opt-out per category |
| No tracking before consent | Analytics SDK loads only after |
|  | user grants consent |
| Data minimization | Track only necessary events, |
|  | no PII in properties |
| User data deletion | API endpoint to delete all data |
|  | for a user_id (GDPR Art. 17) |
```
### Step 10: Validation & Delivery
Validate the analytics implementation:

```
ANALYTICS VALIDATION:
| Check | Status |
|--|--|
| All events in taxonomy are instrumented | PASS | FAIL |
| Event names follow naming convention | PASS | FAIL |
| Properties match documented schema | PASS | FAIL |
| No PII in any event properties | PASS | FAIL |
| Consent gate works (no tracking before consent) | PASS | FAIL |
| Funnels capture all steps correctly | PASS | FAIL |
| A/B test assignment is deterministic and sticky | PASS | FAIL |
| Data appears in analytics dashboard | PASS | FAIL |
| DNT/opt-out disables all tracking | PASS | FAIL |
| User deletion API works (GDPR compliance) | PASS | FAIL |
| Events fire on correct triggers (not duplicated) | PASS | FAIL |
```
```
ANALYTICS IMPLEMENTATION COMPLETE:

Artifacts:
- Analytics config: src/analytics/config.ts
- Event taxonomy: docs/analytics/event-taxonomy.md
- Tracking module: src/analytics/index.ts
- Provider implementations: src/analytics/providers/<provider>.ts
- Consent manager: src/consent/manager.ts
- Funnel definitions: docs/analytics/funnels.md
- A/B test configs: src/experiments/<experiment>.ts
- Data model: docs/analytics/data-model.md

Platform: <platform(s)>
Events tracked: <N> events across <M> categories
Funnels: <N> funnels defined
```
Commit: `"analytics: <platform> — <N> events, <M> funnels, <privacy model>"`

## Key Behaviors

Never ask to continue. Loop autonomously until all events are instrumented and validated.

```bash
# Validate analytics implementation
npm run test:analytics
npx ts-node scripts/analytics-audit.ts --check-pii --check-taxonomy
```
IF event count > 100: audit for redundancy, merge similar events.
WHEN PII detected in event properties: remove immediately, purge from provider.
IF consent gate bypassed: block deployment, treat as P0 bug.

1. **Taxonomy first, tracking second.** Design catalog before code.
2. **Privacy by default.** No tracking before consent. No PII.
3. **Measure what matters.** Track business questions only.
4. **Consistent naming saves hours.** Enforce naming convention.
5. **A/B tests need rigor.** Calculate sample size before launch.
6. **Abstraction layer.** Unified interface over vendor SDK.
7. **Debug before shipping.** Verify events in staging first.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Full analytics design and implementation workflow |
| `--platform <name>` | Force platform: `segment`, `amplitude`, `mixpanel`, `posthog`, `plausible`, `umami`, `ga4` |
| `--taxonomy` | Design event taxonomy only (no implementation) |

## Auto-Detection

```
AUTO-DETECT:
1. SDKs: grep for '@segment/analytics', 'amplitude', 'mixpanel', 'posthog', 'plausible', 'umami', gtag.js
2. Framework: React/Next.js (app vs pages router), Vue/Nuxt, Mobile SDKs
3. Existing events: grep for '.track(', '.capture(', 'analytics.track', 'gtag('
4. Consent: grep for 'cookie-consent', 'cookiebot', 'onetrust'
5. Data warehouse: BigQuery, Snowflake, Redshift configs
6. Privacy: GDPR/CCPA references, EU deployment regions
7. Auto-configure: recommend platform or audit existing for gaps
```
## Output Format

```
ANALYTICS IMPLEMENTATION REPORT:
  Platform: <Segment | Amplitude | PostHog | etc>
  Events tracked: <N> across <M> categories
  Funnels defined: <N>
  Experiments: <N> A/B tests instrumented
  Privacy model: <GDPR compliant | cookieless | consent-based>
  PII audit: CLEAN | <N> violations found
  Verdict: PASS | NEEDS REVISION
```
## TSV Logging

```
timestamp	skill	action	platform	events	funnels	privacy_model	status
```
## Success Criteria

Complete when ALL true:
1. Event taxonomy designed before tracking code
2. All events follow naming convention (0 violations)
3. 0 PII in event properties (verified with audit)
4. Consent gate blocks tracking until granted
5. DNT/opt-out disables all tracking
6. Funnel steps fire in correct order
7. A/B assignments deterministic and sticky
8. Analytics SDK loads async (< 50ms impact on LCP)
9. Debug/dev events filtered from production

## Error Recovery
| Failure | Action |
|--|--|
| Events not appearing | Check console errors, verify API key, use analytics debugger, check ad blockers/CSP. |
