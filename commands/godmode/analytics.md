# /godmode:analytics

Analytics implementation for product teams. Designs event taxonomies, implements tracking with Segment, Amplitude, Mixpanel, or PostHog, sets up funnel analysis, instruments A/B tests, and configures privacy-respecting analytics with Plausible or Umami. Full GDPR/CCPA compliance.

## Usage

```
/godmode:analytics                                 # Full analytics design and implementation
/godmode:analytics --platform posthog              # Force a specific analytics platform
/godmode:analytics --taxonomy                      # Design event taxonomy only
/godmode:analytics --funnel onboarding             # Design and instrument a specific funnel
/godmode:analytics --experiment new-pricing         # Design and instrument an A/B test
/godmode:analytics --audit                         # Audit existing analytics for gaps and PII leaks
/godmode:analytics --privacy                       # Focus on privacy compliance (GDPR, CCPA)
/godmode:analytics --migrate mixpanel posthog      # Migrate from one platform to another
/godmode:analytics --validate                      # Validate all events in taxonomy are instrumented
/godmode:analytics --data-model                    # Design analytics data model for warehouse
```

## What It Does

1. Discovers analytics goals, platform requirements, and privacy constraints
2. Selects analytics platform(s) based on needs (Segment, Amplitude, Mixpanel, PostHog, Plausible, Umami)
3. Designs structured event taxonomy with naming conventions and property standards
4. Implements tracking with a provider-agnostic abstraction layer
5. Designs and instruments conversion funnels with drop-off analysis
6. Instruments A/B tests with deterministic assignment, sample size calculation, and results analysis
7. Models analytics data for warehouse storage and querying
8. Implements privacy-compliant tracking (consent management, PII prevention, data deletion, DNT)
9. Validates all events fire correctly and match the taxonomy

## Output
- Analytics config at `src/analytics/config.ts`
- Event taxonomy at `docs/analytics/event-taxonomy.md`
- Tracking module at `src/analytics/index.ts`
- Provider implementations at `src/analytics/providers/<provider>.ts`
- Consent manager at `src/consent/manager.ts`
- Funnel definitions at `docs/analytics/funnels.md`
- Experiment configs at `src/experiments/<experiment>.ts`
- Data model at `docs/analytics/data-model.md`
- Commit: `"analytics: <platform> — <N> events, <M> funnels, <privacy model>"`

## Key Principles

1. **Taxonomy first** — design the event catalog before writing tracking code
2. **Privacy by default** — no tracking before consent, no PII in events, respect DNT
3. **Measure what matters** — track events that answer business questions, not everything
4. **A/B tests need rigor** — calculate sample size, define metrics, run to completion
5. **Vendor abstraction** — use a unified interface so you can swap providers without rewriting
6. **Debug before shipping** — verify every event in staging before deploying to production

## Next Step
After analytics: `/godmode:chart` for analytics dashboards, `/godmode:report` for analytics reports, `/godmode:test` for tracking tests, or `/godmode:secure` for privacy audit.

## Examples

```
/godmode:analytics                                 # Full analytics setup
/godmode:analytics --platform posthog --privacy    # PostHog with GDPR compliance
/godmode:analytics --funnel checkout               # Instrument checkout funnel
/godmode:analytics --experiment new-onboarding     # Set up A/B test
/godmode:analytics --audit                         # Audit existing tracking
```
