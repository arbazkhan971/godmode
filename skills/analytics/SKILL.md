---
name: analytics
description: |
  Analytics implementation skill. Activates when users need to design and implement product analytics, event tracking, funnel analysis, A/B test instrumentation, or privacy-respecting analytics. Supports Segment, Amplitude, Mixpanel, PostHog, Plausible, and Umami. Provides structured event taxonomies, data modeling, funnel design, and experiment instrumentation with full privacy compliance. Triggers on: /godmode:analytics, "add analytics", "track events", "set up A/B testing", "implement funnels", or when the orchestrator detects analytics-related work.
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
Data warehouse: <BigQuery | Snowflake | Redshift | none>
```

If the user hasn't specified, ask: "What do you want to learn about your users? What decisions will this data inform?"

### Step 2: Analytics Platform Selection
Choose the right analytics stack:

```
PLATFORM SELECTION:
┌──────────────────┬──────────────────────────┬──────────────────────────────┐
│  Platform        │  Best For                │  Privacy Model               │
├──────────────────┼──────────────────────────┼──────────────────────────────┤
│  Segment         │  Data routing hub,       │  Third-party, consent needed │
│                  │  multi-destination CDP   │  GDPR tools available        │
├──────────────────┼──────────────────────────┼──────────────────────────────┤
│  Amplitude       │  Product analytics,      │  Third-party, consent needed │
│                  │  behavioral cohorts,     │  SOC 2, GDPR compliant       │
│                  │  journey mapping         │                              │
├──────────────────┼──────────────────────────┼──────────────────────────────┤
│  Mixpanel        │  Event analytics,        │  Third-party, consent needed │
│                  │  funnel analysis,        │  EU data residency available │
│                  │  retention tracking      │                              │
├──────────────────┼──────────────────────────┼──────────────────────────────┤
│  PostHog         │  Self-hosted product     │  Self-hosted = full control  │
│                  │  analytics, session      │  No data leaves your infra   │
│                  │  replay, feature flags   │  GDPR-friendly by default    │
├──────────────────┼──────────────────────────┼──────────────────────────────┤
│  Plausible       │  Privacy-first web       │  No cookies, no personal     │
│                  │  analytics, lightweight, │  data, GDPR compliant        │
│                  │  GDPR-safe by default    │  without consent banner      │
├──────────────────┼──────────────────────────┼──────────────────────────────┤
│  Umami           │  Self-hosted, privacy-   │  Self-hosted, no cookies,    │
│                  │  first, lightweight,     │  GDPR compliant without      │
│                  │  open source             │  consent banner              │
├──────────────────┼──────────────────────────┼──────────────────────────────┤
│  Google          │  Free, large-scale web   │  Third-party, consent needed │
│  Analytics 4     │  analytics, marketing    │  Requires cookie banner      │
│                  │  attribution             │  Privacy concerns            │
└──────────────────┴──────────────────────────┴──────────────────────────────┘

SELECTED: <platform(s)>
JUSTIFICATION: <why — based on goals, privacy, budget, features>
ARCHITECTURE:
  Collection: <client-side | server-side | hybrid>
  Routing: <direct | via Segment CDP | custom pipeline>
  Storage: <platform-managed | self-hosted | data warehouse>
```

### Step 3: Event Taxonomy Design
Design a structured, consistent event naming system:

```
EVENT TAXONOMY:
Naming convention: <Object Action> (e.g., "Button Clicked", "Page Viewed")

Format: <object>_<action> (snake_case) or <Object> <Action> (Title Case)
Selected: <format>

EVENT CATALOG:
┌─────────────────────────────────┬──────────┬──────────────────────────────┐
│  Event Name                     │  Trigger │  Properties                  │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  LIFECYCLE EVENTS                                                         │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  User Signed Up                 │  Server  │  method, referral_source,    │
│                                 │          │  plan                        │
│  User Logged In                 │  Server  │  method, mfa_used            │
│  User Logged Out                │  Client  │  session_duration            │
│  Account Deleted                │  Server  │  reason, account_age_days    │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  NAVIGATION EVENTS                                                        │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  Page Viewed                    │  Client  │  page_name, page_path,       │
│                                 │          │  referrer                    │
│  Tab Switched                   │  Client  │  tab_name, previous_tab      │
│  Search Performed               │  Client  │  query, results_count,       │
│                                 │          │  filters_applied             │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  FEATURE EVENTS                                                           │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  Feature Used                   │  Client  │  feature_name, context       │
│  <Feature> Created              │  Server  │  <feature-specific props>    │
│  <Feature> Updated              │  Server  │  <fields changed>            │
│  <Feature> Deleted              │  Server  │  <reason if captured>        │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  CONVERSION EVENTS                                                        │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  Trial Started                  │  Server  │  plan, source                │
│  Checkout Started               │  Client  │  plan, billing_cycle         │
│  Payment Completed              │  Server  │  plan, amount, currency      │
│  Subscription Upgraded          │  Server  │  from_plan, to_plan          │
│  Subscription Cancelled         │  Server  │  reason, plan, tenure_days   │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  ENGAGEMENT EVENTS                                                        │
├─────────────────────────────────┼──────────┼──────────────────────────────┤
│  Notification Received          │  Client  │  type, channel               │
│  Notification Clicked           │  Client  │  type, channel               │
│  Share Initiated                │  Client  │  content_type, method        │
│  Feedback Submitted             │  Client  │  type, rating, feature       │
└─────────────────────────────────┴──────────┴──────────────────────────────┘

NAMING RULES:
  1. Use past tense for completed actions ("Signed Up", not "Sign Up")
  2. Use <Object> <Action> format consistently
  3. Never include PII in event properties (no email, name, IP in properties)
  4. Include timestamp and user_id automatically (via SDK)
  5. Properties use snake_case
  6. Boolean properties use is_ prefix (is_first_time, is_premium)
  7. Enum properties have documented allowed values
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
  plan: "free" | "starter" | "pro" | "enterprise"
  account_created_at: ISO 8601 datetime
  company_size: "1-10" | "11-50" | "51-200" | "201-1000" | "1000+"
  role: string
  is_admin: boolean
  feature_flags: string[] (active feature flags)

PROPERTY VALIDATION:
  - Required properties must not be null or empty
  - Enum properties must match allowed values
  - Numeric properties must be within expected ranges
  - String properties have max length limits
  - No PII in any property (email, name, phone, IP, address)
  - No high-cardinality free-text fields (use enums or categories)
```

### Step 5: Implementation
Implement analytics tracking in the codebase:

#### Segment Implementation
```typescript
// analytics/segment.ts
import { AnalyticsBrowser } from '@segment/analytics-next';

export const analytics = AnalyticsBrowser.load({
  writeKey: process.env.SEGMENT_WRITE_KEY!,
});

// Track an event
export function track(event: string, properties?: Record<string, unknown>) {
  analytics.track(event, {
    ...properties,
    timestamp: new Date().toISOString(),
  });
}

// Identify a user
export function identify(userId: string, traits?: Record<string, unknown>) {
  analytics.identify(userId, traits);
}

// Track a page view
export function page(name: string, properties?: Record<string, unknown>) {
  analytics.page(name, properties);
}
```

#### Amplitude Implementation
```typescript
// analytics/amplitude.ts
import * as amplitude from '@amplitude/analytics-browser';

export function initAmplitude() {
  amplitude.init(process.env.AMPLITUDE_API_KEY!, {
    defaultTracking: {
      sessions: true,
      pageViews: true,
      formInteractions: false,
      fileDownloads: false,
    },
  });
}

export function track(event: string, properties?: Record<string, unknown>) {
  amplitude.track(event, properties);
}

export function identify(userId: string, traits?: Record<string, unknown>) {
  amplitude.setUserId(userId);
  if (traits) {
    const identifyEvent = new amplitude.Identify();
    Object.entries(traits).forEach(([key, value]) => {
      identifyEvent.set(key, value as string);
    });
    amplitude.identify(identifyEvent);
  }
}
```

#### PostHog Implementation
```typescript
// analytics/posthog.ts
import posthog from 'posthog-js';

export function initPostHog() {
  posthog.init(process.env.POSTHOG_API_KEY!, {
    api_host: process.env.POSTHOG_HOST || 'https://app.posthog.com',
    capture_pageview: true,
    capture_pageleave: true,
    autocapture: false,  // Prefer explicit tracking
    persistence: 'localStorage',
    respect_dnt: true,
  });
}

export function track(event: string, properties?: Record<string, unknown>) {
  posthog.capture(event, properties);
}

export function identify(userId: string, traits?: Record<string, unknown>) {
  posthog.identify(userId, traits);
}
```

#### Privacy-Respecting Analytics (Plausible/Umami)
```typescript
// analytics/plausible.ts — no cookies, no consent needed
export function trackPageview() {
  // Plausible auto-tracks pageviews via script tag
  // Custom events:
  if (window.plausible) {
    window.plausible('pageview');
  }
}

export function trackEvent(name: string, props?: Record<string, string>) {
  if (window.plausible) {
    window.plausible(name, { props });
  }
}

// Installation: add to <head>
// <script defer data-domain="yourdomain.com" src="https://plausible.io/js/script.js"></script>
```

```typescript
// analytics/umami.ts — self-hosted, no cookies
export function trackEvent(name: string, data?: Record<string, unknown>) {
  if (window.umami) {
    window.umami.track(name, data);
  }
}

// Installation: add to <head>
// <script defer src="https://your-umami.com/script.js" data-website-id="<id>"></script>
```

#### Analytics Abstraction Layer
```typescript
// analytics/index.ts — unified interface
interface AnalyticsProvider {
  track(event: string, properties?: Record<string, unknown>): void;
  identify(userId: string, traits?: Record<string, unknown>): void;
  page(name: string, properties?: Record<string, unknown>): void;
}

class Analytics {
  private providers: AnalyticsProvider[] = [];
  private enabled: boolean = true;

  addProvider(provider: AnalyticsProvider) {
    this.providers.push(provider);
  }

  track(event: string, properties?: Record<string, unknown>) {
    if (!this.enabled) return;
    this.validate(event, properties);
    this.providers.forEach(p => p.track(event, properties));
  }

  identify(userId: string, traits?: Record<string, unknown>) {
    if (!this.enabled) return;
    this.providers.forEach(p => p.identify(userId, traits));
  }

  page(name: string, properties?: Record<string, unknown>) {
    if (!this.enabled) return;
    this.providers.forEach(p => p.page(name, properties));
  }

  private validate(event: string, properties?: Record<string, unknown>) {
    // Validate against event taxonomy
    // Check for PII in properties
    // Log warnings for unknown events in development
    if (process.env.NODE_ENV === 'development') {
      if (!EVENT_CATALOG.includes(event)) {
        console.warn(`[Analytics] Unknown event: "${event}". Add it to the event catalog.`);
      }
    }
  }

  disable() { this.enabled = false; }
  enable() { this.enabled = true; }
}

export const analytics = new Analytics();
```

### Step 6: Funnel Analysis Setup
Design and instrument conversion funnels:

```
FUNNEL DESIGN:
Funnel name: <name — e.g., "Onboarding Funnel">
Goal: <what conversion means — e.g., "User completes onboarding">

FUNNEL STEPS:
┌──────┬────────────────────────┬───────────────────┬──────────────┐
│ Step │ Name                   │ Event             │ Expected %   │
├──────┼────────────────────────┼───────────────────┼──────────────┤
│  1   │ Visit landing page     │ Page Viewed       │ 100%         │
│  2   │ Click sign up          │ CTA Clicked       │ 30-40%       │
│  3   │ Complete registration  │ User Signed Up    │ 60-70%       │
│  4   │ Start onboarding flow  │ Onboarding Started│ 80-90%       │
│  5   │ Complete onboarding    │ Onboarding Done   │ 50-60%       │
│  6   │ First core action      │ Feature Used      │ 40-50%       │
│  7   │ Activation (aha moment)│ Activation Done   │ 30-40%       │
└──────┴────────────────────────┴───────────────────┴──────────────┘

DROP-OFF ANALYSIS:
  Biggest drop-off: Step <N> -> Step <N+1> (<pct>% drop)
  Hypotheses for drop-off:
    1. <hypothesis — e.g., "Registration form is too long">
    2. <hypothesis — e.g., "Unclear value proposition at step 3">
  Recommended actions:
    1. <action — e.g., "Reduce form fields, add social login">
    2. <action — e.g., "Add progress indicator and skip option">

INSTRUMENTATION:
  Each funnel step requires:
    - Event tracked at the correct trigger point
    - Properties include funnel_name and step_number
    - Timestamp for time-between-steps analysis
    - User properties for segmentation (plan, cohort, source)
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
┌───────────┬──────────────────────────────────┬──────────────┐
│  Variant  │  Description                     │  Traffic %   │
├───────────┼──────────────────────────────────┼──────────────┤
│  Control  │  Current experience (no change)  │  50%         │
│  Test A   │  <description of change>         │  50%         │
└───────────┴──────────────────────────────────┴──────────────┘

ASSIGNMENT:
  Method: <random | deterministic hash of user_id>
  Sticky: <yes — same user always sees same variant>
  Exclusions: <users in other active experiments on same surface>
```

#### Experiment Implementation
```typescript
// experiments/ab-test.ts
interface Experiment {
  id: string;
  name: string;
  variants: { id: string; weight: number }[];
  isActive: boolean;
}

function assignVariant(experiment: Experiment, userId: string): string {
  // Deterministic assignment based on user ID hash
  const hash = murmurhash3(userId + experiment.id);
  const normalized = (hash >>> 0) / 0xFFFFFFFF; // 0-1

  let cumulative = 0;
  for (const variant of experiment.variants) {
    cumulative += variant.weight;
    if (normalized < cumulative) return variant.id;
  }
  return experiment.variants[0].id; // fallback to control
}

// Track experiment exposure
function trackExposure(experiment: Experiment, variant: string) {
  analytics.track('Experiment Viewed', {
    experiment_id: experiment.id,
    experiment_name: experiment.name,
    variant_id: variant,
  });
}

// PostHog feature flags (built-in A/B testing)
function getVariant(flagKey: string): string | boolean {
  return posthog.getFeatureFlag(flagKey);
}
```

#### Results Analysis Framework
```
EXPERIMENT RESULTS:
Experiment: <name>
Duration: <start> — <end>
Total participants: <N> (Control: <N>, Test: <N>)

PRIMARY METRIC:
┌───────────┬──────────────┬──────────────┬──────────────┐
│  Variant  │  Conversions │  Rate        │  vs Control  │
├───────────┼──────────────┼──────────────┼──────────────┤
│  Control  │  <N>/<total> │  <pct>%      │  —           │
│  Test A   │  <N>/<total> │  <pct>%      │  <+/- pct>%  │
└───────────┴──────────────┴──────────────┴──────────────┘

STATISTICAL SIGNIFICANCE:
  p-value: <value>
  Confidence interval: [<lower>, <upper>]
  Significant: <YES | NO> (alpha = 0.05)
  Power: <achieved power>

SECONDARY METRICS (guardrails):
  <metric 1>: Control <value> vs Test <value> — <OK | DEGRADED>
  <metric 2>: Control <value> vs Test <value> — <OK | DEGRADED>

SEGMENT ANALYSIS:
  <segment 1>: <direction and magnitude of effect>
  <segment 2>: <direction and magnitude of effect>

RECOMMENDATION: <SHIP IT | ITERATE | KILL IT>
  Rationale: <evidence-based reasoning>
```

### Step 8: Analytics Data Modeling
Design the data model for analytics storage and querying:

```
DATA MODEL:
┌─────────────────────────────────────────────────────────────────────┐
│                        EVENTS TABLE                                 │
├─────────────────────────────────────────────────────────────────────┤
│  event_id       UUID (primary key)                                  │
│  event_name     VARCHAR(100) (indexed)                              │
│  user_id        VARCHAR(100) (indexed)                              │
│  anonymous_id   VARCHAR(100)                                        │
│  session_id     VARCHAR(100)                                        │
│  timestamp      TIMESTAMP (partitioned by day)                      │
│  properties     JSONB                                               │
│  context        JSONB (device, browser, OS, locale)                 │
│  received_at    TIMESTAMP                                           │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        USERS TABLE                                  │
├─────────────────────────────────────────────────────────────────────┤
│  user_id        VARCHAR(100) (primary key)                          │
│  traits         JSONB (plan, role, company, created_at)             │
│  first_seen     TIMESTAMP                                           │
│  last_seen      TIMESTAMP                                           │
│  event_count    INTEGER                                             │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        SESSIONS TABLE                               │
├─────────────────────────────────────────────────────────────────────┤
│  session_id     VARCHAR(100) (primary key)                          │
│  user_id        VARCHAR(100) (indexed)                              │
│  started_at     TIMESTAMP                                           │
│  ended_at       TIMESTAMP                                           │
│  duration_sec   INTEGER                                             │
│  event_count    INTEGER                                             │
│  entry_page     VARCHAR(500)                                        │
│  exit_page      VARCHAR(500)                                        │
│  device_type    VARCHAR(20)                                         │
│  utm_source     VARCHAR(100)                                        │
│  utm_medium     VARCHAR(100)                                        │
│  utm_campaign   VARCHAR(100)                                        │
└─────────────────────────────────────────────────────────────────────┘

QUERIES (common analytics queries):
  - DAU/WAU/MAU: COUNT(DISTINCT user_id) WHERE timestamp >= <period>
  - Retention: cohort analysis grouping by first_seen week
  - Funnel: sequential event matching with time constraints
  - Feature adoption: COUNT(DISTINCT user_id) WHERE event_name = '<feature>'
  - Session duration: AVG(duration_sec) grouped by cohort/segment
```

### Step 9: Privacy & Consent
Implement privacy-compliant analytics:

```
PRIVACY IMPLEMENTATION:
┌──────────────────────────────────────────────────────────────────────┐
│  Requirement                    │  Implementation                    │
├─────────────────────────────────┼────────────────────────────────────┤
│  Consent management             │  Cookie banner with granular       │
│                                 │  opt-in/opt-out per category       │
├─────────────────────────────────┼────────────────────────────────────┤
│  No tracking before consent     │  Analytics SDK loads only after    │
│                                 │  user grants consent               │
├─────────────────────────────────┼────────────────────────────────────┤
│  Data minimization              │  Track only necessary events,      │
│                                 │  no PII in properties              │
├─────────────────────────────────┼────────────────────────────────────┤
│  User data deletion             │  API endpoint to delete all data   │
│                                 │  for a user_id (GDPR Art. 17)     │
├─────────────────────────────────┼────────────────────────────────────┤
│  Data export                    │  API endpoint to export user data  │
│                                 │  in machine-readable format        │
├─────────────────────────────────┼────────────────────────────────────┤
│  Retention limits               │  Auto-delete raw events after      │
│                                 │  <N> months, keep aggregates       │
├─────────────────────────────────┼────────────────────────────────────┤
│  Do Not Track (DNT)             │  Respect browser DNT header        │
│                                 │  (disable all tracking)            │
├─────────────────────────────────┼────────────────────────────────────┤
│  IP anonymization               │  Strip or hash IP addresses        │
│                                 │  before storage                    │
├─────────────────────────────────┼────────────────────────────────────┤
│  Cookie-free option             │  Plausible/Umami for cookieless    │
│                                 │  tracking (no consent needed)      │
└─────────────────────────────────┴────────────────────────────────────┘

CONSENT IMPLEMENTATION:
```typescript
// consent/manager.ts
type ConsentCategory = 'necessary' | 'analytics' | 'marketing' | 'personalization';

interface ConsentState {
  [key: string]: boolean;
}

class ConsentManager {
  private state: ConsentState = {
    necessary: true,    // Always true, cannot be disabled
    analytics: false,   // Requires opt-in
    marketing: false,   // Requires opt-in
    personalization: false,
  };

  grantConsent(category: ConsentCategory) {
    this.state[category] = true;
    this.persist();
    this.onConsentChange(category, true);
  }

  revokeConsent(category: ConsentCategory) {
    if (category === 'necessary') return; // Cannot revoke
    this.state[category] = false;
    this.persist();
    this.onConsentChange(category, false);
  }

  hasConsent(category: ConsentCategory): boolean {
    return this.state[category] ?? false;
  }

  private onConsentChange(category: ConsentCategory, granted: boolean) {
    if (category === 'analytics') {
      if (granted) {
        analytics.enable();
      } else {
        analytics.disable();
        // Delete existing analytics cookies
      }
    }
  }

  private persist() {
    localStorage.setItem('consent', JSON.stringify(this.state));
  }
}
```

### Step 10: Validation & Delivery
Validate the analytics implementation:

```
ANALYTICS VALIDATION:
┌──────────────────────────────────────────────────────┬──────────────┐
│  Check                                               │  Status      │
├──────────────────────────────────────────────────────┼──────────────┤
│  All events in taxonomy are instrumented             │  PASS | FAIL │
│  Event names follow naming convention                │  PASS | FAIL │
│  Properties match documented schema                  │  PASS | FAIL │
│  No PII in any event properties                      │  PASS | FAIL │
│  Consent gate works (no tracking before consent)     │  PASS | FAIL │
│  Funnels capture all steps correctly                 │  PASS | FAIL │
│  A/B test assignment is deterministic and sticky     │  PASS | FAIL │
│  Data appears in analytics dashboard                 │  PASS | FAIL │
│  DNT/opt-out disables all tracking                   │  PASS | FAIL │
│  User deletion API works (GDPR compliance)           │  PASS | FAIL │
│  Events fire on correct triggers (not duplicated)    │  PASS | FAIL │
│  Debug/dev events are filtered from production       │  PASS | FAIL │
│  Analytics SDK does not block page load              │  PASS | FAIL │
│  Bundle size impact is acceptable                    │  PASS | FAIL │
└──────────────────────────────────────────────────────┴──────────────┘

TESTING:
  - Use analytics debugger (Segment Debugger, Amplitude Event Explorer, PostHog Toolbar)
  - Verify events in real-time event stream
  - Check funnel steps fire in correct order
  - Verify A/B test assignments are balanced (chi-squared test)
  - Test consent flow: grant, revoke, and verify tracking stops/starts
  - Test user data deletion end-to-end

VERDICT: <PASS | NEEDS REVISION>
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
Experiments: <N> A/B tests instrumented
Privacy: <GDPR compliant | cookieless | consent-based>

Next steps:
-> /godmode:chart — Build dashboards for analytics data
-> /godmode:report — Generate analytics reports
-> /godmode:test — Write tests for event tracking
-> /godmode:secure — Audit analytics for privacy compliance
```

Commit: `"analytics: <platform> — <N> events, <M> funnels, <privacy model>"`

## Key Behaviors

1. **Taxonomy first, tracking second.** Design the event catalog before writing any tracking code. Ad-hoc event naming creates an unmaintainable mess.
2. **Privacy by default.** No tracking before consent. No PII in events. Respect DNT. Implement data deletion. These are not optional.
3. **Measure what matters.** Track events that answer business questions. Do not track everything just because you can. More events means more noise.
4. **Consistent naming saves hours.** A well-designed event taxonomy prevents the "we have 47 different events that all mean page view" problem.
5. **A/B tests need rigor.** Calculate sample size before launching. Define success metrics before seeing results. Run to completion, do not peek and stop early.
6. **Abstraction layer over vendor lock-in.** Use a unified analytics interface so you can swap providers without touching every component.
7. **Debug before shipping.** Verify every event fires correctly in a staging environment before deploying to production.

## Example Usage

### Setting Up Product Analytics
```
User: /godmode:analytics Set up product analytics for our SaaS app

Analytics: Starting discovery...

ANALYTICS DISCOVERY:
Project: SaaS project management tool
Goals: Track activation, measure feature adoption, reduce churn
Platform: Next.js web app
Privacy: GDPR compliant (EU customers)

PLATFORM SELECTED: PostHog (self-hosted)
  - Product analytics + session replay + feature flags
  - Self-hosted = GDPR compliant, no data leaves your infra
  - Free tier sufficient for current scale

EVENT TAXONOMY: 24 events across 5 categories
  Lifecycle: 4 events (signup, login, logout, delete)
  Navigation: 3 events (page view, search, tab switch)
  Feature: 8 events (project/task CRUD, comment, share)
  Conversion: 5 events (trial, checkout, payment, upgrade, cancel)
  Engagement: 4 events (notification, share, feedback, invite)

FUNNELS: 3 defined
  1. Onboarding: signup -> create project -> invite member -> first task
  2. Activation: signup -> 3 projects created within 7 days
  3. Upgrade: trial start -> feature limit hit -> checkout -> payment

Implementation complete. Verify with /godmode:test.
```

### Implementing A/B Testing
```
User: /godmode:analytics Set up an A/B test for the new onboarding flow

Analytics: Designing experiment...

EXPERIMENT: new-onboarding-flow-v2
Hypothesis: Simplified 3-step onboarding will increase activation by 15%
Primary metric: Activation rate (3 projects in 7 days)
Guardrail: Session duration (should not decrease)

Variants:
  Control (50%): Current 6-step onboarding
  Test A (50%): New 3-step onboarding

Sample size needed: 2,400 users per variant
Estimated duration: 3 weeks at current signup rate

Instrumented with PostHog feature flags.
Run /godmode:report --type experiment when complete.
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full analytics design and implementation workflow |
| `--platform <name>` | Force platform: `segment`, `amplitude`, `mixpanel`, `posthog`, `plausible`, `umami`, `ga4` |
| `--taxonomy` | Design event taxonomy only (no implementation) |
| `--funnel <name>` | Design and instrument a specific funnel |
| `--experiment <name>` | Design and instrument an A/B test |
| `--audit` | Audit existing analytics implementation for gaps, PII leaks, naming issues |
| `--privacy` | Focus on privacy compliance (GDPR, CCPA, consent management) |
| `--migrate <from> <to>` | Migrate analytics from one platform to another |
| `--validate` | Validate that all events in taxonomy are instrumented and firing |
| `--data-model` | Design analytics data model for warehouse |

## Auto-Detection

Before prompting the user, automatically detect the analytics landscape:

```
AUTO-DETECT SEQUENCE:
1. Detect existing analytics SDKs:
   - grep for '@segment/analytics', 'amplitude', 'mixpanel', 'posthog', 'plausible', 'umami'
   - Check for gtag.js, analytics.js, GA4 measurement ID
2. Detect framework and platform:
   - React/Next.js → check for app router vs pages router (affects page tracking)
   - Vue/Nuxt → check for vue-router integration
   - Mobile → check for React Native, Flutter, Swift, Kotlin analytics SDKs
3. Detect existing event tracking:
   - grep for '.track(', '.capture(', 'analytics.track', 'gtag('
   - Count existing tracked events and categorize them
4. Detect consent management:
   - grep for 'cookie-consent', 'cookiebot', 'onetrust', 'consent'
   - Check for consent banners in HTML templates
5. Detect data warehouse:
   - Check for BigQuery, Snowflake, Redshift configs in codebase or infra
6. Detect privacy requirements:
   - Check for GDPR/CCPA references in docs or code
   - Check deployment regions (EU → GDPR likely required)
7. Auto-configure:
   - No analytics → recommend platform based on framework and privacy needs
   - Existing analytics → audit for taxonomy consistency and gaps
```

## Multi-Agent Dispatch

For large-scale analytics implementations across multiple surfaces:

```
PARALLEL ANALYTICS IMPLEMENTATION:
IF platform_count > 1 OR event_count > 30:
  Agent 1 (worktree: analytics-taxonomy):
    - Design complete event taxonomy
    - Define property standards and validation rules
    - Create event catalog documentation
    - Build TypeScript types for all events

  Agent 2 (worktree: analytics-implementation):
    - Implement analytics abstraction layer
    - Add provider-specific integrations
    - Instrument all events from the taxonomy
    - Add consent management integration

  Agent 3 (worktree: analytics-funnels):
    - Design conversion funnels
    - Instrument A/B test framework
    - Set up experiment assignment logic
    - Create funnel visualization configs

  Agent 4 (worktree: analytics-privacy):
    - Implement consent manager
    - Audit all events for PII
    - Add data deletion API endpoint
    - Verify DNT/opt-out behavior
    - Test consent gate end-to-end

  COORDINATOR validates all events fire correctly, taxonomy is consistent
```

## Anti-Patterns

- **Do NOT track events without a taxonomy.** Random event names like "click1", "button_pressed", "user_did_thing" are useless. Design the taxonomy first.
- **Do NOT include PII in event properties.** Never track email, full name, phone number, or IP address in analytics events. Use anonymous IDs.
- **Do NOT track before consent.** In GDPR/CCPA jurisdictions, analytics must not fire until the user has granted consent. No exceptions.
- **Do NOT peek at A/B test results early.** Running statistical tests repeatedly inflates the false positive rate. Define the sample size, run to completion, then analyze.
- **Do NOT use auto-capture as your only tracking.** Auto-captured clicks and page views lack semantic meaning. Supplement with explicit, well-named events.
- **Do NOT create high-cardinality properties.** Properties like "search_query" with millions of unique values bloat storage and slow queries. Categorize instead.
- **Do NOT couple analytics to business logic.** Analytics tracking should be a side effect, not interleaved with core logic. Use an event bus or middleware.
- **Do NOT ship analytics without testing.** Verify events fire correctly, properties are populated, funnels work end-to-end, and consent gates function properly.


## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run analytics tasks sequentially: taxonomy, then implementation, then funnels, then privacy.
- Use branch isolation per task: `git checkout -b godmode-analytics-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
