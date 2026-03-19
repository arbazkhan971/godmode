---
name: feature
description: Feature flag design, gradual rollouts, A/B testing integration, kill switches. Use when user mentions feature flags, toggles, gradual rollout, canary release, LaunchDarkly, Unleash, Flagsmith, or progressive delivery.
---

# Feature -- Feature Flags & Progressive Delivery

## When to Activate
- User invokes `/godmode:feature`
- User says "feature flag", "feature toggle", "feature gate", "feature switch"
- User says "gradual rollout", "percentage rollout", "canary release", "progressive delivery"
- User says "kill switch", "circuit breaker flag", "emergency disable"
- User says "A/B test", "experiment", "variant testing", "split test"
- User says "LaunchDarkly", "Unleash", "Flagsmith", "Split.io", "homegrown flags"
- User says "flag cleanup", "stale flags", "flag debt", "remove old flags"
- When `/godmode:deploy` identifies a need for safer rollout mechanisms
- When `/godmode:release` recommends decoupling deploy from release
- When `/godmode:test` suggests experiment-driven validation

## Workflow

### Step 1: Flag Strategy Assessment
Understand the current state and what flags are needed:

```
FLAG STRATEGY ASSESSMENT:
Project: <name and purpose>
Current Flag System: None | Homegrown | LaunchDarkly | Unleash | Flagsmith | Split.io | Other
Flag Count: <existing flags, if any>
Stale Flags: <flags that should have been cleaned up>

FLAG NEEDS ANALYSIS:
+--------------------------------------------------------------+
|  Flag Purpose             | Count | Example                   |
+--------------------------------------------------------------+
|  Release flags            | --    | new_checkout_flow         |
|  Experiment flags         | --    | pricing_page_variant      |
|  Ops flags (kill switch)  | --    | disable_recommendations   |
|  Permission flags         | --    | enable_beta_features      |
+--------------------------------------------------------------+

ENVIRONMENT MATRIX:
+--------------------------------------------------------------+
|  Environment   | Flag Source      | Evaluation    | Latency   |
+--------------------------------------------------------------+
|  Development   | Local overrides  | Client-side   | 0ms       |
|  Staging       | Flag service     | Server-side   | <5ms      |
|  Production    | Flag service     | Server-side   | <5ms      |
|  Mobile apps   | Flag service     | Client-side   | <50ms     |
+--------------------------------------------------------------+

DECISION CRITERIA:
  Team size: <small (1-5) | medium (5-20) | large (20+)>
  Deploy frequency: <daily | weekly | monthly>
  Experimentation needs: <none | basic | advanced>
  Compliance requirements: <audit trail needed? change approval?>
  Budget: <free/OSS | $500-2K/mo | enterprise>
```

If the user has not specified their needs, ask: "What types of feature flags do you need -- release toggles for safer deploys, A/B experiments, operational kill switches, or permission-based access? Do you have a flag system already?"

### Step 2: Flag Type Design
Define the flag taxonomy and lifecycle for each type:

```
FLAG TYPES:

TYPE 1: RELEASE FLAGS (short-lived)
+--------------------------------------------------------------+
|  Purpose: Decouple deployment from release                    |
|  Lifetime: Days to weeks (remove after full rollout)          |
|  Targeting: Percentage-based, cohort, internal-first          |
|  Default: OFF (new code hidden until enabled)                 |
+--------------------------------------------------------------+
|  Lifecycle:                                                   |
|  CREATE -> INTERNAL -> CANARY (1%) -> RAMP (5/25/50/100%)    |
|            -> FULL ROLLOUT -> CLEANUP (remove flag + old code)|
|                                                               |
|  Example:                                                     |
|  {                                                            |
|    "key": "new_checkout_flow",                                |
|    "type": "release",                                         |
|    "description": "New 3-step checkout replacing legacy 5-step"|
|    "owner": "team-checkout",                                  |
|    "created": "2026-03-01",                                   |
|    "expected_cleanup": "2026-04-01",                          |
|    "rollout": {                                               |
|      "strategy": "percentage",                                |
|      "current_percentage": 25,                                |
|      "stages": [1, 5, 25, 50, 100]                           |
|    }                                                          |
|  }                                                            |
+--------------------------------------------------------------+

TYPE 2: EXPERIMENT FLAGS (short-lived)
+--------------------------------------------------------------+
|  Purpose: A/B testing, measure impact of changes              |
|  Lifetime: Days to weeks (remove after experiment concludes)  |
|  Targeting: Random assignment with sticky bucketing           |
|  Default: CONTROL variant                                     |
+--------------------------------------------------------------+
|  Lifecycle:                                                   |
|  CREATE -> CONFIGURE VARIANTS -> RUN EXPERIMENT               |
|         -> REACH SIGNIFICANCE -> PICK WINNER -> CLEANUP       |
|                                                               |
|  Example:                                                     |
|  {                                                            |
|    "key": "pricing_page_variant",                             |
|    "type": "experiment",                                      |
|    "description": "Test annual vs monthly-first pricing page",|
|    "owner": "team-growth",                                    |
|    "hypothesis": "Showing annual pricing first increases ARPU |
|                   by 10% without reducing conversion",        |
|    "variants": [                                              |
|      { "key": "control", "weight": 50, "desc": "Monthly-first" },|
|      { "key": "treatment", "weight": 50, "desc": "Annual-first" }|
|    ],                                                         |
|    "metrics": {                                               |
|      "primary": "revenue_per_visitor",                        |
|      "secondary": ["conversion_rate", "plan_mix"],            |
|      "guardrail": ["bounce_rate", "support_tickets"]          |
|    },                                                         |
|    "sample_size": 10000,                                      |
|    "significance_level": 0.05                                 |
|  }                                                            |
+--------------------------------------------------------------+

TYPE 3: OPS FLAGS / KILL SWITCHES (long-lived)
+--------------------------------------------------------------+
|  Purpose: Operational control, graceful degradation           |
|  Lifetime: Permanent (part of system resilience)              |
|  Targeting: Global (on/off) or per-region                     |
|  Default: ON (feature active, switch kills it)                |
+--------------------------------------------------------------+
|  Lifecycle:                                                   |
|  CREATE -> ALWAYS AVAILABLE -> TRIGGERED DURING INCIDENT      |
|         -> RESTORED AFTER INCIDENT (never cleaned up)         |
|                                                               |
|  Example:                                                     |
|  {                                                            |
|    "key": "disable_recommendations",                          |
|    "type": "ops",                                             |
|    "description": "Kill switch for recommendation engine --   |
|                    disable if ML service is degraded",        |
|    "owner": "team-platform",                                  |
|    "default": false,                                          |
|    "when_enabled": "Recommendations return empty array,       |
|                     fallback to popular items list"            |
|  }                                                            |
|                                                               |
|  Common kill switches:                                        |
|  - disable_recommendations (ML service degradation)           |
|  - disable_search_suggestions (search overload)               |
|  - disable_email_notifications (email provider outage)        |
|  - force_maintenance_mode (full system degradation)           |
|  - disable_external_payments (payment processor outage)       |
|  - reduce_image_quality (CDN/bandwidth pressure)              |
+--------------------------------------------------------------+

TYPE 4: PERMISSION FLAGS (long-lived)
+--------------------------------------------------------------+
|  Purpose: Entitlements, plan-based access, beta programs      |
|  Lifetime: Permanent (tied to business logic)                 |
|  Targeting: User attributes, subscription plan, org           |
|  Default: OFF (feature gated until entitled)                  |
+--------------------------------------------------------------+
|  Lifecycle:                                                   |
|  CREATE -> GATE BEHIND PLAN/ROLE -> PERMANENT                 |
|                                                               |
|  Example:                                                     |
|  {                                                            |
|    "key": "enable_advanced_analytics",                        |
|    "type": "permission",                                      |
|    "description": "Advanced analytics dashboard for Pro plan",|
|    "owner": "team-billing",                                   |
|    "targeting": {                                             |
|      "rules": [                                               |
|        { "attribute": "plan", "operator": "in",               |
|          "values": ["pro", "enterprise"] },                   |
|        { "attribute": "org_id", "operator": "in",             |
|          "values": ["beta-org-1", "beta-org-2"] }             |
|      ]                                                        |
|    }                                                          |
|  }                                                            |
+--------------------------------------------------------------+

FLAG TYPE SELECTION:
+--------------------------------------------------------------+
|  Question                           | Flag Type              |
+--------------------------------------------------------------+
|  Shipping new code safely?          | Release                |
|  Measuring impact of a change?      | Experiment             |
|  Need an emergency off switch?      | Ops / Kill Switch      |
|  Gating by plan, role, or entitle?  | Permission             |
+--------------------------------------------------------------+
```

### Step 3: SDK & Platform Selection
Choose and configure the flag evaluation system:

#### Managed Platforms
```
PLATFORM COMPARISON:
+--------------------------------------------------------------+
|  Platform      | Strengths           | Pricing     | Best For |
+--------------------------------------------------------------+
|  LaunchDarkly  | Enterprise-grade,   | $$$         | Large    |
|                | streaming updates,  | ~$12/seat/  | teams,   |
|                | rich targeting,     | mo + MAU    | complex  |
|                | audit trail         |             | targeting|
+--------------------------------------------------------------+
|  Unleash       | Open-source core,   | Free (OSS)  | Teams    |
|                | self-hosted option, | $80/mo      | wanting  |
|                | strategy-based,     | (Pro)       | control  |
|                | simple API          |             | and OSS  |
+--------------------------------------------------------------+
|  Flagsmith     | Open-source,        | Free (OSS)  | Startups,|
|                | self-hosted,        | $45/mo      | small    |
|                | remote config,      | (SaaS)      | teams,   |
|                | simple UI           |             | budget   |
+--------------------------------------------------------------+
|  Split.io      | Experimentation-    | $$          | Data-    |
|                | focused, stats      | Custom      | driven   |
|                | engine, attribution |             | teams    |
+--------------------------------------------------------------+
|  Homegrown     | Full control, no    | Engineering | Simple   |
|                | vendor dependency,  | time only   | needs,   |
|                | custom logic        |             | small    |
|                |                     |             | scale    |
+--------------------------------------------------------------+

PLATFORM SELECTION CRITERIA:
  < 5 flags, simple on/off         -> Homegrown or Flagsmith OSS
  5-50 flags, team of 5-20         -> Unleash or Flagsmith
  50+ flags, experimentation needed -> LaunchDarkly or Split.io
  Strict data residency / air-gap  -> Unleash or Flagsmith (self-hosted)
  Enterprise compliance / audit    -> LaunchDarkly
```

#### SDK Integration Pattern
```
SDK INTEGRATION:

SERVER-SIDE EVALUATION (recommended for most cases):
  Client -> Your Server -> Flag SDK evaluates locally -> Response

  Advantages:
  - Flag rules never exposed to client
  - Sub-millisecond evaluation (in-memory)
  - Full targeting context available (user, org, plan)
  - Consistent evaluation (no client-side drift)

  PSEUDOCODE (Node.js / LaunchDarkly):
  import LaunchDarkly from "launchdarkly-node-server-sdk"

  const client = LaunchDarkly.init(process.env.LD_SDK_KEY)
  await client.waitForInitialization()

  async function isEnabled(flagKey, user):
    const context = {
      kind: "user",
      key: user.id,
      email: user.email,
      plan: user.plan,
      country: user.country,
      custom: {
        org_id: user.org_id,
        created_at: user.created_at
      }
    }
    return await client.variation(flagKey, context, false)  // false = default

  // Usage in route handler
  app.get("/api/checkout", async (req, res) => {
    const user = req.user
    const useNewCheckout = await isEnabled("new_checkout_flow", user)

    if (useNewCheckout):
      return newCheckoutHandler(req, res)
    else:
      return legacyCheckoutHandler(req, res)
  })

CLIENT-SIDE EVALUATION (mobile apps, SPAs):
  Flag Service -> Client SDK -> Evaluates from cached ruleset

  Advantages:
  - Works offline (cached rules)
  - No server round-trip for flag checks
  - Real-time updates via streaming/SSE

  Disadvantages:
  - Flag rules visible in client bundle (security)
  - Larger SDK payload
  - Targeting context limited to client-known data

  PSEUDOCODE (React / LaunchDarkly):
  import { withLDProvider, useFlags } from "launchdarkly-react-client-sdk"

  function CheckoutPage():
    const { newCheckoutFlow } = useFlags()

    if (newCheckoutFlow):
      return <NewCheckout />
    else:
      return <LegacyCheckout />

  // Wrap app with provider
  export default withLDProvider({
    clientSideID: process.env.REACT_APP_LD_CLIENT_ID,
    context: {
      kind: "user",
      key: user.id,
      plan: user.plan
    }
  })(App)

EVALUATION MODE DECISION:
+--------------------------------------------------------------+
|  Context                          | Mode                      |
+--------------------------------------------------------------+
|  API server, backend service      | Server-side               |
|  Web SPA (React, Vue, Angular)    | Client-side with proxy    |
|  Mobile app (iOS, Android)        | Client-side with cache    |
|  Edge function / CDN worker       | Edge-side (lightweight)   |
|  Server-rendered pages (Next.js)  | Server-side (SSR)         |
+--------------------------------------------------------------+
```

### Step 4: Targeting Rules & Gradual Rollout
Design precise targeting for controlled releases:

```
TARGETING RULES:

RULE TYPES:
+--------------------------------------------------------------+
|  Rule                 | Operator       | Example               |
+--------------------------------------------------------------+
|  User ID              | in / not in    | user_id in [123, 456] |
|  Email                | endsWith       | email endsWith @co.com|
|  Percentage           | rollout %      | 25% of users          |
|  Cohort / Segment     | in segment     | segment = "beta_users"|
|  Geographic           | country in     | country in [US, CA]   |
|  Device               | platform =     | platform = "ios"      |
|  Plan / Tier          | plan in        | plan in [pro, ent]    |
|  Organization         | org_id in      | org_id in [org_123]   |
|  Date / Time          | after / before | after 2026-04-01      |
|  Custom attribute     | any operator   | app_version >= 3.2.0  |
+--------------------------------------------------------------+

TARGETING RULE PRIORITY (evaluated top to bottom):
  1. Individual user overrides (highest priority)
     user_id in [admin_1, admin_2] -> ON

  2. Internal / employee targeting
     email endsWith @ourcompany.com -> ON

  3. Beta segment targeting
     segment = "beta_users" -> ON

  4. Percentage rollout (general population)
     25% of remaining users -> ON

  5. Default rule (lowest priority)
     All others -> OFF

GRADUAL ROLLOUT STRATEGY:
+--------------------------------------------------------------+
|  Stage      | %    | Duration | Gate Criteria                  |
+--------------------------------------------------------------+
|  Internal   | 0.1% | 1 day   | No errors in logs, team tests  |
|  Canary     | 1%   | 1-2 days| Error rate < 0.1%, latency ok  |
|  Early      | 5%   | 2-3 days| No support tickets, metrics ok |
|  Expanding  | 25%  | 3-5 days| Conversion rate stable         |
|  Majority   | 50%  | 3-5 days| All metrics within guardrails  |
|  Full       | 100% | --      | Flag cleanup scheduled         |
+--------------------------------------------------------------+

ROLLOUT GATE CRITERIA (must pass before advancing):
  Error rate:     < baseline + 0.1%
  P95 latency:    < baseline + 10%
  Conversion:     > baseline - 2%
  Support tickets: < baseline + 5%
  Crash rate:     < baseline + 0.05%

PERCENTAGE HASHING (sticky bucketing):
  The same user must always see the same variant.
  Do NOT use random assignment per request.

  PSEUDOCODE:
  function isInRollout(userId, flagKey, percentage):
    // Deterministic hash: same user + flag always = same bucket
    const hash = murmur3(`${flagKey}:${userId}`)
    const bucket = (hash % 10000) / 100  // 0.00 to 99.99

    return bucket < percentage

  PROPERTIES:
  - Deterministic: user sees same result on every request
  - Uniform: users evenly distributed across buckets
  - Independent: different flags hash differently (no correlation)
  - Ramp-safe: increasing % from 25 to 50 adds new users,
    existing 25% stay in treatment (no flipping)
```

### Step 5: Kill Switches & Emergency Controls
Design operational safety mechanisms:

```
KILL SWITCH ARCHITECTURE:

KILL SWITCH REQUIREMENTS:
  1. Toggle must take effect in < 30 seconds globally
  2. No deploy required to activate
  3. Dashboard or CLI accessible by on-call engineer
  4. Audit trail of who toggled and when
  5. Automatic rollback trigger (optional)

KILL SWITCH HIERARCHY:
+--------------------------------------------------------------+
|  Level          | Scope              | Example                 |
+--------------------------------------------------------------+
|  Global         | Entire system      | force_maintenance_mode  |
|  Service        | One microservice   | disable_payment_service |
|  Feature        | One feature        | disable_recommendations |
|  Region         | Geographic scope   | disable_eu_processing   |
|  Client         | One customer/org   | throttle_org_heavy_user |
+--------------------------------------------------------------+

IMPLEMENTATION:

// Kill switch middleware
async function killSwitchMiddleware(req, res, next):
  // Check global maintenance mode (cached locally, refreshed every 10s)
  if (await flags.isEnabled("force_maintenance_mode")):
    return res.status(503).json({
      error: "Service temporarily unavailable",
      retry_after: 300
    })

  // Check feature-level kill switches
  const featureKillSwitches = [
    { flag: "disable_recommendations", path: "/api/recommendations" },
    { flag: "disable_search", path: "/api/search" },
    { flag: "disable_notifications", path: "/api/notifications" }
  ]

  for (const ks of featureKillSwitches):
    if (req.path.startsWith(ks.path) && await flags.isEnabled(ks.flag)):
      return res.status(200).json({
        data: getFallbackResponse(ks.path),
        _degraded: true
      })

  next()

AUTOMATIC KILL SWITCH TRIGGERS:
+--------------------------------------------------------------+
|  Trigger                          | Action                    |
+--------------------------------------------------------------+
|  Error rate > 5% for 2 minutes    | Disable feature flag      |
|  P95 latency > 2x baseline        | Reduce rollout to 0%      |
|  Dependency health check fails    | Enable kill switch         |
|  Memory > 90% on flag service     | Fall back to defaults      |
+--------------------------------------------------------------+

PSEUDOCODE (automatic trigger):
async function monitorAndKill(flagKey, metrics):
  const baseline = await getBaseline(flagKey)
  const current = await getCurrentMetrics(flagKey)

  if (current.error_rate > baseline.error_rate * 2):
    await flags.disable(flagKey)
    await alertOncall({
      severity: "critical",
      message: `Auto-disabled ${flagKey}: error rate ${current.error_rate}%`,
      action: "Review and manually re-enable when resolved"
    })

FALLBACK BEHAVIOR:
  When flag service is unreachable:
  1. Use locally cached flag values (last known good)
  2. Cache TTL: 5 minutes (stale values better than no values)
  3. If cache expired: use hardcoded defaults (conservative)
  4. Log warning: "Flag service unreachable, using cached/default values"
  5. Never crash because the flag service is down
```

### Step 6: Flag Lifecycle Management
Manage flags from creation through cleanup:

```
FLAG LIFECYCLE:

+--------------------------------------------------------------+
|  PHASE 1: CREATE                                              |
|  Owner defines flag with metadata:                            |
|  - Key (snake_case, descriptive)                              |
|  - Type (release | experiment | ops | permission)             |
|  - Owner (team or individual)                                 |
|  - Description (what it does, not just the name)              |
|  - Expected cleanup date (release + experiment flags only)    |
|  - Jira/Linear ticket link                                    |
+--------------------------------------------------------------+
          |
          v
+--------------------------------------------------------------+
|  PHASE 2: CONFIGURE                                           |
|  Set targeting rules, variants, and defaults:                 |
|  - Development: ON for all (test new code path)               |
|  - Staging: ON for all (integration testing)                  |
|  - Production: OFF (not yet released)                         |
+--------------------------------------------------------------+
          |
          v
+--------------------------------------------------------------+
|  PHASE 3: ROLLOUT                                             |
|  Progressive delivery:                                        |
|  - Internal employees first                                   |
|  - Canary 1% -> 5% -> 25% -> 50% -> 100%                    |
|  - Monitor metrics at each gate                               |
|  - Pause or rollback if guardrails breached                   |
+--------------------------------------------------------------+
          |
          v
+--------------------------------------------------------------+
|  PHASE 4: MEASURE                                             |
|  For experiment flags:                                        |
|  - Collect data until statistical significance                |
|  - Analyze primary, secondary, and guardrail metrics          |
|  - Document results and decision                              |
|  For release flags:                                           |
|  - Confirm metrics stable at 100% rollout                     |
|  - Wait 1 week at full rollout before cleanup                 |
+--------------------------------------------------------------+
          |
          v
+--------------------------------------------------------------+
|  PHASE 5: CLEANUP (critical -- most teams skip this)          |
|  Remove the flag and dead code:                               |
|  1. Remove flag checks from code (all branches)               |
|  2. Remove losing variant code (experiments)                  |
|  3. Remove old code path (release flags)                      |
|  4. Delete flag from flag service                             |
|  5. Remove flag from tests                                    |
|  6. Update documentation                                      |
|  Commit: "flag-cleanup: remove <flag_key>, rolled out on <date>"|
+--------------------------------------------------------------+

FLAG NAMING CONVENTION:
  Pattern: <action>_<feature>_<scope>
  Examples:
    enable_new_checkout         (release)
    exp_pricing_annual_first    (experiment, prefix with exp_)
    disable_recommendations     (ops/kill switch, use disable_ prefix)
    enable_advanced_analytics   (permission)
    ops_force_maintenance       (ops, prefix with ops_)

FLAG HYGIENE DASHBOARD:
+--------------------------------------------------------------+
|  Metric                          | Target  | Current          |
+--------------------------------------------------------------+
|  Total active flags              | < 100   | <count>          |
|  Flags older than 30 days        | < 20    | <count>          |
|  Flags older than 90 days        | 0       | <count>          |
|  Flags without owner             | 0       | <count>          |
|  Flags without cleanup date      | 0       | <count>          |
|  Stale flags (100% for 2+ weeks) | 0       | <count>          |
+--------------------------------------------------------------+

STALE FLAG DETECTION:
  A flag is stale when:
  - Release flag at 100% for > 2 weeks
  - Experiment flag concluded > 1 week ago
  - Flag not evaluated in > 30 days
  - Flag created > 90 days ago without cleanup date

  AUTOMATED CLEANUP REMINDERS:
  // Weekly cron: detect and alert on stale flags
  async function detectStaleFlags():
    const flags = await flagService.listAll()
    const stale = flags.filter(f =>
      (f.type === "release" && f.percentage === 100
        && daysSince(f.last_changed) > 14) ||
      (f.type === "experiment" && f.status === "concluded"
        && daysSince(f.concluded_at) > 7) ||
      (daysSince(f.created_at) > 90 && !f.cleanup_date)
    )

    for (const flag of stale):
      await notify(flag.owner, {
        message: `Flag "${flag.key}" is stale. Please clean up.`,
        link: `${FLAG_DASHBOARD_URL}/flags/${flag.key}`,
        ticket: await createCleanupTicket(flag)
      })
```

### Step 7: Flag-Driven A/B Testing
Design experiments with statistical rigor:

```
A/B TESTING WITH FLAGS:

EXPERIMENT SETUP:
  1. Define hypothesis (what you expect and why)
  2. Choose primary metric (one metric that decides winner)
  3. Choose secondary metrics (supporting evidence)
  4. Set guardrail metrics (must not regress)
  5. Calculate required sample size
  6. Configure flag with variants and weights

SAMPLE SIZE CALCULATION:
+--------------------------------------------------------------+
|  Parameter                 | Value    | Meaning               |
+--------------------------------------------------------------+
|  Baseline conversion       | 5.0%     | Current rate           |
|  Minimum detectable effect | 10%      | 5.0% -> 5.5% (rel.)   |
|  Statistical significance  | 95%      | alpha = 0.05           |
|  Statistical power         | 80%      | beta = 0.20            |
|  Required sample per arm   | ~30,000  | 60,000 total           |
|  Daily traffic             | 10,000   | Unique visitors/day    |
|  Estimated duration        | 6 days   | To reach sample size   |
+--------------------------------------------------------------+

VARIANT ASSIGNMENT:
  // Sticky bucketing: user always sees same variant
  function assignVariant(userId, experimentKey, variants):
    const hash = murmur3(`${experimentKey}:${userId}`)
    const bucket = (hash % 10000) / 100  // 0.00 to 99.99

    let cumulative = 0
    for (const variant of variants):
      cumulative += variant.weight
      if (bucket < cumulative):
        return variant.key

    return variants[0].key  // Fallback to control

METRICS COLLECTION:
  // Track exposure events (who saw what)
  function trackExposure(userId, experimentKey, variant):
    analytics.track("experiment_exposure", {
      user_id: userId,
      experiment: experimentKey,
      variant: variant,
      timestamp: Date.now()
    })

  // Track conversion events
  function trackConversion(userId, event, properties):
    analytics.track(event, {
      user_id: userId,
      ...properties,
      timestamp: Date.now()
    })

ANALYSIS FRAMEWORK:
+--------------------------------------------------------------+
|  Metric              | Control  | Treatment | Diff   | Sig?   |
+--------------------------------------------------------------+
|  Conversion rate     | 5.0%     | 5.6%      | +12%   | YES    |
|  Revenue / visitor   | $2.10    | $2.35     | +11.9% | YES    |
|  Bounce rate (guard) | 32%      | 31%       | -3.1%  | NO     |
|  Page load time (g)  | 1.2s     | 1.3s      | +8.3%  | NO     |
+--------------------------------------------------------------+
|  DECISION: Ship treatment -- primary metric significant,      |
|  guardrail metrics within acceptable bounds.                  |
+--------------------------------------------------------------+

COMMON PITFALLS:
  - Peeking: Do not check results before sample size reached
  - Multiple testing: Adjust p-value if testing many variants
  - Selection bias: Use deterministic hashing, not random
  - Novelty effect: Run for at least 1 full business cycle (7 days)
  - Interaction effects: Avoid overlapping experiments on same surface
```

### Step 8: Homegrown Flag System (Database Schema)
Design a self-hosted feature flag system when vendor solutions are not needed:

```
HOMEGROWN FLAG SYSTEM:

DATABASE SCHEMA (PostgreSQL):

-- Flag definitions
CREATE TABLE feature_flags (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key             VARCHAR(255) UNIQUE NOT NULL,
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    type            VARCHAR(50) NOT NULL CHECK (type IN
                      ('release', 'experiment', 'ops', 'permission')),
    owner           VARCHAR(255) NOT NULL,
    enabled         BOOLEAN NOT NULL DEFAULT false,
    archived        BOOLEAN NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    cleanup_by      DATE,
    metadata        JSONB DEFAULT '{}'
);

-- Targeting rules per flag
CREATE TABLE flag_rules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_id         UUID NOT NULL REFERENCES feature_flags(id),
    priority        INTEGER NOT NULL,  -- Lower = higher priority
    attribute       VARCHAR(255) NOT NULL,  -- user_id, email, plan, country
    operator        VARCHAR(50) NOT NULL,   -- in, not_in, equals, contains,
                                            -- starts_with, ends_with, gte, lte
    values          JSONB NOT NULL,         -- ["val1", "val2"]
    variant         VARCHAR(255) DEFAULT 'on',  -- Which variant to serve
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Percentage rollout configuration
CREATE TABLE flag_rollouts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_id         UUID NOT NULL REFERENCES feature_flags(id) UNIQUE,
    percentage      INTEGER NOT NULL CHECK (percentage BETWEEN 0 AND 100),
    hash_salt       VARCHAR(255) NOT NULL,  -- For deterministic bucketing
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Experiment variants
CREATE TABLE flag_variants (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_id         UUID NOT NULL REFERENCES feature_flags(id),
    key             VARCHAR(255) NOT NULL,
    description     TEXT,
    weight          INTEGER NOT NULL CHECK (weight BETWEEN 0 AND 100),
    payload         JSONB DEFAULT '{}',  -- Variant-specific config
    UNIQUE(flag_id, key)
);

-- Audit log (who changed what, when)
CREATE TABLE flag_audit_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_id         UUID NOT NULL REFERENCES feature_flags(id),
    action          VARCHAR(50) NOT NULL,  -- created, enabled, disabled,
                                           -- rule_added, percentage_changed,
                                           -- archived, deleted
    actor           VARCHAR(255) NOT NULL,
    previous_value  JSONB,
    new_value       JSONB,
    timestamp       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Environment overrides (dev, staging, prod)
CREATE TABLE flag_environments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    flag_id         UUID NOT NULL REFERENCES feature_flags(id),
    environment     VARCHAR(50) NOT NULL,  -- development, staging, production
    enabled         BOOLEAN NOT NULL DEFAULT false,
    overrides       JSONB DEFAULT '{}',    -- Environment-specific config
    UNIQUE(flag_id, environment)
);

CREATE INDEX idx_flags_key ON feature_flags(key) WHERE NOT archived;
CREATE INDEX idx_flags_type ON feature_flags(type);
CREATE INDEX idx_rules_flag ON flag_rules(flag_id);
CREATE INDEX idx_audit_flag ON flag_audit_log(flag_id);
CREATE INDEX idx_audit_time ON flag_audit_log(timestamp);
CREATE INDEX idx_env_flag ON flag_environments(flag_id);

EVALUATION ENGINE:

async function evaluateFlag(flagKey, context):
  // Step 1: Get flag (from cache, refresh every 30s)
  const flag = await getCachedFlag(flagKey)
  if (!flag || flag.archived): return { enabled: false, variant: null }

  // Step 2: Check environment override
  const envOverride = flag.environments[context.environment]
  if (envOverride && envOverride.enabled !== undefined):
    if (!envOverride.enabled): return { enabled: false, variant: null }

  // Step 3: Check if flag is globally enabled
  if (!flag.enabled): return { enabled: false, variant: null }

  // Step 4: Evaluate targeting rules (priority order)
  const rules = flag.rules.sort((a, b) => a.priority - b.priority)
  for (const rule of rules):
    if (matchesRule(rule, context)):
      return { enabled: true, variant: rule.variant }

  // Step 5: Check percentage rollout
  if (flag.rollout):
    const bucket = murmur3(`${flag.rollout.hash_salt}:${context.user_id}`)
    const pct = (bucket % 10000) / 100
    if (pct < flag.rollout.percentage):
      return { enabled: true, variant: "on" }

  // Step 6: Default -- not targeted
  return { enabled: false, variant: null }

function matchesRule(rule, context):
  const value = context[rule.attribute]
  switch (rule.operator):
    case "in":        return rule.values.includes(value)
    case "not_in":    return !rule.values.includes(value)
    case "equals":    return value === rule.values[0]
    case "contains":  return value?.includes(rule.values[0])
    case "gte":       return value >= rule.values[0]
    case "lte":       return value <= rule.values[0]
    case "ends_with": return value?.endsWith(rule.values[0])
    default:          return false

CACHING LAYER:
  // In-memory cache with periodic refresh
  let flagCache = new Map()
  let lastRefresh = 0

  async function getCachedFlag(key):
    if (Date.now() - lastRefresh > 30000):  // Refresh every 30s
      const flags = await db.query("SELECT * FROM feature_flags WHERE NOT archived")
      flagCache = new Map(flags.map(f => [f.key, f]))
      // Also load rules, rollouts, variants, environments
      lastRefresh = Date.now()

    return flagCache.get(key)

API ENDPOINTS:
  GET    /api/flags                    -- List all flags
  POST   /api/flags                    -- Create flag
  GET    /api/flags/:key               -- Get flag details
  PUT    /api/flags/:key               -- Update flag
  PATCH  /api/flags/:key/toggle        -- Enable/disable
  PATCH  /api/flags/:key/rollout       -- Update rollout percentage
  POST   /api/flags/:key/rules         -- Add targeting rule
  DELETE /api/flags/:key/rules/:id     -- Remove targeting rule
  GET    /api/flags/:key/audit         -- Get audit log
  POST   /api/evaluate                 -- Evaluate flags for context
  DELETE /api/flags/:key               -- Archive flag
```

### Step 9: Server-Side vs Client-Side Evaluation
Choose the right evaluation model:

```
EVALUATION MODELS:

SERVER-SIDE EVALUATION:
+--------------------------------------------------------------+
|  Flag rules stored and evaluated on your server               |
|  Client sends user context -> server evaluates -> returns     |
|  boolean or variant                                           |
+--------------------------------------------------------------+

  Request flow:
  Client -> API Server -> Flag SDK (in-memory) -> Result
                              |
                              v
                     Flag Service (sync every 30s)

  Advantages:
  - Rules never exposed to client (security)
  - Full context available (DB lookups for targeting)
  - Sub-millisecond evaluation (in-process)
  - No additional client-side bundle size

  Disadvantages:
  - Every flag check requires server round-trip (for SPAs)
  - Server must be available for evaluation

  Best for: APIs, server-rendered pages, backend services

CLIENT-SIDE EVALUATION:
+--------------------------------------------------------------+
|  Flag rules shipped to client, evaluated locally              |
|  Flag service sends ruleset -> client SDK caches and          |
|  evaluates locally per user context                           |
+--------------------------------------------------------------+

  Request flow:
  Flag Service -> Client SDK (cached ruleset) -> Local evaluation
                       |
                       v
              Real-time updates via SSE/WebSocket

  Advantages:
  - No server round-trip for flag checks
  - Works offline (cached rules)
  - Real-time updates (streaming)
  - Reduces server load

  Disadvantages:
  - Flag rules visible in client (security concern)
  - Limited targeting context (only client-known attributes)
  - Larger SDK payload

  Best for: Mobile apps, SPAs, client-heavy applications

HYBRID (recommended for web apps):
+--------------------------------------------------------------+
|  Server evaluates during SSR / API responses                  |
|  Client SDK handles real-time updates for interactive flags   |
+--------------------------------------------------------------+

  Implementation:
  1. Server renders initial page with flags evaluated server-side
  2. Client SDK bootstraps from server-provided values (no flicker)
  3. Client SDK connects to streaming for real-time updates
  4. Interactive flags (UI experiments) evaluated client-side
  5. Business logic flags evaluated server-side

  // Next.js example (hybrid)
  export async function getServerSideProps(context):
    const user = await getUser(context.req)
    const flags = await flagClient.allFlagsState(user)

    return {
      props: {
        flags: flags.toJSON(),  // Pass to client for bootstrap
        user: user
      }
    }

  // Client-side: bootstrap from server values, then stream updates
  const LDProvider = await asyncWithLDProvider({
    clientSideID: process.env.NEXT_PUBLIC_LD_CLIENT_ID,
    context: userContext,
    options: {
      bootstrap: pageProps.flags  // No flicker on initial load
    }
  })
```

### Step 10: Validation
Validate the feature flag strategy against best practices:

```
FEATURE FLAG VALIDATION:
+--------------------------------------------------------------+
|  Check                                    | Status             |
+--------------------------------------------------------------+
|  Flag types clearly categorized           | PASS | FAIL        |
|  Naming convention defined and enforced   | PASS | FAIL        |
|  Owner assigned to every flag             | PASS | FAIL        |
|  Cleanup date set for release/exp flags   | PASS | FAIL        |
|  Kill switches defined for critical paths | PASS | FAIL        |
|  Gradual rollout strategy documented      | PASS | FAIL        |
|  Sticky bucketing for consistent UX       | PASS | FAIL        |
|  Fallback behavior when flag service down | PASS | FAIL        |
|  Audit trail for flag changes             | PASS | FAIL        |
|  Stale flag detection automated           | PASS | FAIL        |
|  A/B test statistical rigor defined       | PASS | FAIL        |
|  Server vs client evaluation decided      | PASS | FAIL        |
|  Flag evaluation latency < 5ms            | PASS | FAIL        |
|  No sensitive data in flag targeting rules| PASS | FAIL        |
+--------------------------------------------------------------+

TECHNICAL DEBT CHECK:
+--------------------------------------------------------------+
|  Debt Indicator                   | Threshold | Current       |
+--------------------------------------------------------------+
|  Total active flags               | < 100     | <count>       |
|  Flags without cleanup date       | 0         | <count>       |
|  Flags older than 90 days         | < 5       | <count>       |
|  Flags at 100% for > 2 weeks     | 0         | <count>       |
|  Orphaned flags (no owner)        | 0         | <count>       |
|  Nested flag dependencies         | 0         | <count>       |
+--------------------------------------------------------------+

VERDICT: <PASS | NEEDS REVISION>
```

### Step 11: Artifacts & Commit
Generate the deliverables:

```
FEATURE FLAG STRATEGY COMPLETE:

Artifacts:
- Flag strategy doc: docs/feature-flags/<system>-flag-strategy.md
- Flag service config: src/lib/flags.ts (or equivalent)
- Database schema: migrations/create_feature_flags.sql (if homegrown)
- Kill switch registry: docs/feature-flags/kill-switches.md
- Flag hygiene dashboard: monitoring/dashboards/feature-flags.json
- Validation: <PASS | NEEDS REVISION>

Next steps:
-> /godmode:deploy -- Deploy with feature flags for safe rollout
-> /godmode:test -- Write tests for flag-gated code paths
-> /godmode:observe -- Monitor flag evaluation metrics
-> /godmode:analytics -- Set up experiment metrics collection
```

Commit: `"feature: <system> -- <flag types>, <platform>, <rollout strategy>"`

## Key Behaviors

1. **Flags are temporary by default.** Release and experiment flags must have a cleanup date. A flag that lives forever becomes technical debt that no one understands.
2. **Decouple deploy from release.** The whole point of feature flags is that deploying code does not mean releasing it to users. Ship dark, enable gradually.
3. **Kill switches are not optional.** Every critical feature needs an emergency off switch. When the incident happens at 3 AM, toggling a flag is faster than rolling back a deploy.
4. **Clean up your flags.** A codebase with 500 stale flags is worse than one with no flags. Automate stale flag detection and enforce cleanup within 30 days of full rollout.
5. **Sticky bucketing is mandatory.** A user must see the same variant on every request. Random assignment per request creates inconsistent UX and invalidates experiments.
6. **Test both paths.** Every flag creates a branch in your code. Test the on path, the off path, and the transition between them. Do not ship untested code paths.
7. **Default to off, fail to off.** New flags should default to off. If the flag service is unreachable, serve the safe default (off for new features, on for kill switches).
8. **Flag evaluation must be fast.** In-memory evaluation with periodic sync. Never call an external service per flag check in the request path.

## Example Usage

### Designing a rollout strategy for a new feature
```
User: /godmode:feature Plan a gradual rollout for our new checkout flow

Feature: Assessing rollout strategy...

FLAG DESIGN:
  Key: enable_new_checkout
  Type: release
  Owner: team-checkout
  Cleanup by: 2026-04-15

ROLLOUT PLAN:
  Stage 1: Internal employees (email endsWith @ourcompany.com) -- 1 day
  Stage 2: Canary 1% of users -- 2 days, monitor error rate + latency
  Stage 3: Ramp to 5% -- 2 days, monitor conversion rate
  Stage 4: Ramp to 25% -- 3 days, check support ticket volume
  Stage 5: Ramp to 50% -- 3 days, full metrics review
  Stage 6: 100% -- hold for 1 week, then clean up flag

KILL SWITCH:
  Key: disable_new_checkout
  Fallback: Legacy checkout flow
  Trigger: Error rate > 2% or P95 latency > 3s

MONITORING:
  Primary: Checkout conversion rate
  Secondary: Average order value, cart abandonment rate
  Guardrail: Error rate, P95 latency, support tickets
```

### Setting up A/B testing with flags
```
User: /godmode:feature Set up an A/B test for our pricing page

Feature: Configuring experiment flag...

EXPERIMENT:
  Key: exp_pricing_annual_first
  Type: experiment
  Hypothesis: Showing annual pricing first will increase ARPU by 10%

VARIANTS:
  control (50%):   Monthly pricing shown first (current)
  treatment (50%): Annual pricing shown first (new)

METRICS:
  Primary: Revenue per visitor
  Secondary: Conversion rate, plan distribution
  Guardrail: Bounce rate, support tickets

SAMPLE SIZE: 30,000 per arm (60,000 total)
DURATION: ~6 days at 10,000 visitors/day

DECISION CRITERIA:
  Ship treatment if: primary metric significant at p < 0.05
  AND guardrail metrics within 5% of baseline
```

### Cleaning up stale flags
```
User: /godmode:feature Audit our feature flags for cleanup

Feature: Scanning for stale flags...

STALE FLAG REPORT:
  Total active flags: 87
  Flags needing cleanup: 12

  CRITICAL (remove immediately):
  1. enable_new_dashboard (100% for 45 days, no cleanup date)
  2. exp_onboarding_v2 (concluded 3 weeks ago, winner: treatment)
  3. enable_api_v3 (100% for 60 days, old code still in codebase)

  WARNING (schedule cleanup):
  4. enable_bulk_export (100% for 12 days)
  5. exp_email_subject_lines (concluded 5 days ago)

  ACTION ITEMS:
  - Created 5 cleanup tickets in Linear
  - Estimated effort: 2-4 hours per flag removal
  - Removing these flags deletes ~1,200 lines of dead code
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Full feature flag strategy design workflow |
| `--rollout` | Design gradual rollout plan for a feature |
| `--experiment` | Set up an A/B test experiment with flag |
| `--killswitch` | Design kill switches for critical features |
| `--audit` | Audit existing flags for stale/orphaned flags |
| `--cleanup` | Generate cleanup plan for stale flags |
| `--schema` | Generate database schema for homegrown flags |
| `--sdk` | SDK integration guide for chosen platform |
| `--targeting` | Design targeting rules and segments |
| `--validate` | Validate feature flag strategy |
| `--compare` | Compare flag platforms (LD, Unleash, etc.) |
| `--migrate` | Migrate between flag platforms |

## HARD RULES

1. **NEVER leave release flags at 100% for more than 2 weeks.** A flag at 100% is dead code wrapped in a conditional. Clean it up.
2. **NEVER nest flag checks.** `if (flagA && flagB && !flagC)` creates 8 possible states that are impossible to test. Keep flags independent.
3. **NEVER use flags as permanent configuration.** Feature flags are temporary or targeted toggles. Permanent config belongs in config files or environment variables.
4. **ALWAYS test both the flag-on AND flag-off paths.** The off-path is your fallback during incidents. If it is broken, you have no safety net.
5. **NEVER evaluate flags in hot loops.** Evaluate once per request and pass the result. Calling the flag service 1000 times per request adds latency.
6. **NEVER expose server-side targeting rules to clients.** Targeting rules may contain business logic or internal IDs. Use server-side evaluation for sensitive flags.
7. **NEVER call an experiment winner without sufficient sample size.** Calculate required sample size upfront and wait for statistical significance.
8. **ALWAYS maintain an audit trail.** Every flag change must record who changed it, when, and the previous value.

## Auto-Detection

On activation, detect the feature flag context:

```bash
# Detect flag platforms
grep -r "launchdarkly\|unleash\|flagsmith\|split\|statsig\|growthbook\|posthog" package.json 2>/dev/null

# Detect homegrown flags
grep -rl "featureFlag\|feature_flag\|isEnabled\|isFeatureEnabled\|getFeature" src/ --include="*.ts" --include="*.js" --include="*.py" 2>/dev/null | head -10

# Detect flag config files
find . -name "*feature*flag*" -o -name "*flags*" -o -name "*toggles*" 2>/dev/null | head -5

# Count existing flags
grep -roh "FEATURE_[A-Z_]*\|feature\.[a-z._]*\|flag\.[a-z._]*" src/ 2>/dev/null | sort -u | wc -l
```

## Iteration Protocol

For gradual feature rollout with monitoring:

```
current_percentage = 0
rollout_stages = [1, 5, 25, 50, 100]

WHILE current_percentage < 100:
  next_stage = rollout_stages[next]
  1. Set flag percentage to next_stage
  2. Monitor error rates, latency, and business metrics for observation_window
  3. Compare treatment vs control groups
  4. IF metrics degrade beyond threshold: ROLLBACK to previous stage, investigate
  5. IF metrics stable: advance to next stage
  current_percentage = next_stage
  Report: "Rollout at {current_percentage}%: error_rate={rate}, latency_p99={p99}ms, conversion={conv}%"

AFTER 100%:
  Schedule flag cleanup (max 2 weeks)
  Remove flag code and dead branches
```

## Anti-Patterns

- **Do NOT leave flags forever.** A release flag at 100% for months is dead code wrapped in a conditional. Clean it up within 2 weeks of full rollout.
- **Do NOT nest flag checks.** `if (flagA && flagB && !flagC)` creates 8 possible states that are impossible to test and reason about. Keep flags independent.
- **Do NOT use flags as config.** Feature flags are for temporary or targeted toggles. Permanent configuration belongs in config files or environment variables, not the flag system.
- **Do NOT skip the off path.** If you only test the flag-on path, the flag-off path (your fallback) may be broken when you need it most -- during an incident.
- **Do NOT evaluate flags in hot loops.** Evaluate once per request and pass the result down. Calling the flag service 1000 times per request adds latency and creates dependency risk.
- **Do NOT expose server-side flag rules to clients.** Targeting rules may contain business logic, internal user IDs, or pricing strategies. Use server-side evaluation for sensitive flags.
- **Do NOT run experiments without sufficient sample size.** Calling a winner after 200 users is statistical noise. Calculate required sample size upfront and wait for significance.
- **Do NOT forget the audit trail.** When an incident happens and a flag was changed, you need to know who changed it, when, and what the previous value was.
