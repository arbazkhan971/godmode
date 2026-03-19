# /godmode:migration

Plan and execute large-scale system migrations. Handles language/framework transitions (JS to TS, REST to GraphQL), architecture evolution (monolith to microservices), data migration with zero downtime, strangler fig pattern, parallel run verification, and rollback planning. Distinct from `/godmode:migrate` (database schema changes).

## Usage

```
/godmode:migration                            # Interactive migration assessment
/godmode:migration --assess                   # Assess migration scope only
/godmode:migration --plan                     # Generate detailed migration plan
/godmode:migration --track                    # Show migration progress dashboard
/godmode:migration --verify                   # Run parallel comparison verification
/godmode:migration --rollback                 # Execute rollback plan
/godmode:migration --strategy <name>          # Force strategy (strangler, bigbang, parallel, abstraction)
/godmode:migration --phase <N>                # Show details for a specific phase
/godmode:migration --report                   # Generate migration progress report
/godmode:migration --dry-run                  # Show plan without making changes
```

## What It Does

1. Assesses current state, target state, and constraints (code size, data volume, team, timeline)
2. Classifies migration type (language, framework, API paradigm, architecture, data, infrastructure)
3. Selects appropriate strategy (strangler fig, big bang, parallel run, branch by abstraction)
4. Generates phased migration plan with dependency ordering
5. Provides data migration patterns with zero-downtime dual-write/backfill/cutover
6. Sets up parallel run verification to compare old and new system outputs
7. Documents rollback plan with trigger conditions and point of no return
8. Tracks progress across phases with reporting

## Output
- Migration plan at `docs/migrations/<name>.md`
- Migration code (abstractions, adapters, feature flags, comparison scripts)
- Commit: `"migration: <source> -> <target> -- <phase> (<strategy>)"`
- Progress report with risks and next steps

## Migration Strategies

| Strategy | Best For | Risk | Downtime |
|----------|----------|------|----------|
| **Strangler Fig** | Large systems, zero-downtime | Low | Zero |
| **Big Bang** | Small codebases, acceptable downtime | High | Hours/days |
| **Parallel Run** | Data-critical systems | Medium | Zero |
| **Branch by Abstraction** | Internal component replacement | Low | Zero |

## Next Step
After planning: `/godmode:plan` to decompose migration phases into tasks, then `/godmode:build` to execute.

## Examples

```
/godmode:migration Convert our Express.js app to TypeScript
/godmode:migration Break up the monolith into microservices
/godmode:migration Switch from REST to GraphQL
/godmode:migration --assess How big is the Python 2 to 3 migration?
/godmode:migration --verify Compare old and new search service outputs
/godmode:migration --track Show progress on the TypeScript conversion
/godmode:migration --rollback Revert to the old payment service
```
