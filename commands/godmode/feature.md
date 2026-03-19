# /godmode:feature

Design and implement feature flag strategies. Covers flag types (release, experiment, ops, permission), SDK integration (LaunchDarkly, Unleash, Flagsmith, Split.io, homegrown), targeting rules, gradual rollouts, kill switches, A/B testing, and flag lifecycle management.

## Usage

```
/godmode:feature                          # Full feature flag strategy design
/godmode:feature --rollout                # Design gradual rollout plan
/godmode:feature --experiment             # Set up A/B test with flags
/godmode:feature --killswitch             # Design kill switches
/godmode:feature --audit                  # Audit flags for stale/orphaned
/godmode:feature --cleanup                # Generate cleanup plan for stale flags
/godmode:feature --schema                 # Database schema for homegrown flags
/godmode:feature --sdk                    # SDK integration guide
/godmode:feature --targeting              # Design targeting rules and segments
/godmode:feature --validate               # Validate feature flag strategy
/godmode:feature --compare                # Compare flag platforms
/godmode:feature --migrate                # Migrate between flag platforms
```

## What It Does

1. Assesses flag needs and categorizes by type (release, experiment, ops, permission)
2. Selects flag platform (LaunchDarkly, Unleash, Flagsmith, Split.io, or homegrown)
3. Designs targeting rules (user ID, cohort, percentage, geo, plan, device)
4. Plans gradual rollout stages with gate criteria at each stage
5. Implements kill switches with automatic triggers and fallback behavior
6. Manages flag lifecycle from creation through cleanup
7. Configures flag-driven A/B testing with statistical rigor
8. Designs server-side vs client-side evaluation strategy
9. Generates database schema for homegrown flag systems
10. Validates against 14 best-practice checks and detects technical debt

## Output
- Flag strategy doc at `docs/feature-flags/<system>-flag-strategy.md`
- Flag service module at `src/lib/flags.ts`
- Database migration at `migrations/create_feature_flags.sql` (if homegrown)
- Kill switch registry at `docs/feature-flags/kill-switches.md`
- Flag hygiene dashboard at `monitoring/dashboards/feature-flags.json`
- Validation report with PASS/NEEDS REVISION verdict
- Commit: `"feature: <system> -- <flag types>, <platform>, <rollout strategy>"`

## Next Step
After flag design: `/godmode:deploy` for safe rollout, `/godmode:test` for flag-gated code paths, `/godmode:observe` for flag evaluation metrics, or `/godmode:analytics` for experiment metrics.

## Examples

```
/godmode:feature Plan a gradual rollout for our new checkout flow
/godmode:feature --experiment              # Set up A/B test
/godmode:feature --killswitch              # Design kill switches
/godmode:feature --audit                   # Find stale flags to clean up
/godmode:feature --schema                  # Homegrown flag DB schema
/godmode:feature --compare                 # Compare LaunchDarkly vs Unleash
```
