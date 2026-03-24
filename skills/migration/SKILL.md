---
name: migration
description: |
  System migration skill. Activates when a developer needs to plan or execute large-scale technology migrations: language/framework transitions (JS to TS, REST to GraphQL, monolith to microservices), data migrations with zero downtime, strangler fig pattern implementation, parallel run verification, and rollback planning. Distinct from /godmode:migrate (database schema changes) — this skill handles system-level architecture migrations. Triggers on: /godmode:migration, "migrate from X to Y", "convert to TypeScript", "move to microservices", "rewrite in", "modernize the stack", or when a project needs systematic technology transition planning.
---

# Migration -- System Migration & Technology Transition

## When to Activate
- User invokes `/godmode:migration`
- User says "migrate from X to Y", "convert to TypeScript", "move to microservices"
- User says "rewrite the API in Go", "switch from REST to GraphQL"
- User says "break up the monolith", "modernize the stack"
- User says "upgrade from React 17 to 19", "move from CRA to Vite"
- User needs zero-downtime data migration between systems
- Project requires gradual technology transition without stopping development
- User says "strangler fig", "parallel run", "feature flag migration"

## Workflow

### Step 1: Migration Assessment
Identify the current state, target state, and constraints:

```
MIGRATION ASSESSMENT:
|  Source State:                                            |
|    Language/Framework: <current tech stack>               |
|    Architecture:       <monolith | modular monolith |    |
|                         microservices | serverless>       |
|    Data stores:        <databases, caches, queues>       |
|    Code size:          <files, LOC, modules>             |
|    Test coverage:      <percentage, if known>            |
|    Team size:          <number of developers>            |
|  Target State:                                           |
|    Language/Framework: <target tech stack>                |
|    Architecture:       <target architecture>              |
  ...
```
Classification of migration types:
```
MIGRATION TYPE CLASSIFICATION:
|  Type                    | Examples                      |
|  Language migration      | JS -> TS, Python 2 -> 3,     |
|                          | Java -> Kotlin                |
|  Framework migration     | Express -> Fastify,           |
```

### Step 2: Migration Strategy Selection
Choose the correct migration strategy based on type and constraints:

#### Strategy: Big Bang
```
BIG BANG MIGRATION:
|  How:     Rewrite everything at once, switch over        |
|  When:    Small codebase, low traffic, acceptable        |
|           downtime, clean break needed                    |
|  Risk:    HIGH — all-or-nothing, no gradual rollback     |
|  Timeline: Short but concentrated                        |
|  Migration Steps:                                                  |
|  1. Build new system in parallel                         |
|  2. Freeze feature development on old system             |
|  3. Migrate all data in a maintenance window             |
|  4. Switch DNS/routing to new system                     |
|  5. Verify and monitor                                   |
  ...
```

#### Strategy: Strangler Fig
```
STRANGLER FIG PATTERN:
|  How:     Incrementally replace old system piece by      |
|           piece, routing traffic through a facade        |
|  When:    Large codebase, zero-downtime, must continue   |
|           shipping features alongside migration          |
|  Risk:    LOW — each piece is independently deployable   |
|           and reversible                                 |
|  Timeline: Long but sustainable                          |
|  Phase 1: Facade                                        |
|  +---------+     +---------+                             |
|  | Client  | --> | Facade  | --> | Old System |          |
```

#### Strategy: Parallel Run
```
PARALLEL RUN:
|  How:     Run old and new systems simultaneously,        |
|           compare outputs, switch when confident         |
|  When:    Data integrity critical, need to verify        |
|           correctness before switching                   |
|  Risk:    MEDIUM — double infrastructure cost, but       |
|           high confidence in correctness                 |
|  Parallel Run Steps:                                                  |
|  1. Build new system alongside old                       |
|  2. Send traffic to BOTH systems (shadow traffic or      |
|     dual-write)                                          |
|  3. Compare outputs/results automatically                |
  ...
```

#### Strategy: Branch by Abstraction
```
BRANCH BY ABSTRACTION:
|  How:     Introduce abstraction layer, swap              |
|           implementation behind it                       |
|  When:    Internal component replacement, same API       |
|           contract, feature-flag controlled               |
|  Risk:    LOW — abstraction isolates change              |
|  Strangler Steps:                                                  |
|  1. Create abstraction layer (interface/adapter)         |
|  2. Route existing code through abstraction              |
|  3. Build new implementation behind same abstraction     |
|  4. Feature flag between old and new implementation      |
|  5. Gradually roll out new implementation                |
  ...
```

### Step 3: Language/Framework Migration Planning

For JS -> TS, Python 2 -> 3, React class -> hooks, etc.:

#### TypeScript Migration (JS -> TS)
```
JS -> TS MIGRATION PLAN:
|  Phase 1: Setup (Day 1)                                  |
|  - Install typescript, @types/* packages                 |
|  - Create tsconfig.json with allowJs: true               |
|  - Configure strict: false initially                     |
|  - Add ts-check to build pipeline                        |
|  Phase 2: Incremental conversion (Ongoing)               |
|  - Rename .js -> .ts one file at a time                  |
|  - Start with leaf modules (no dependents)               |
|  - Add types to function signatures                      |
|  - Use 'any' as escape hatch, track with lint rule       |
|  - Convert test files alongside source files             |
```

#### REST -> GraphQL Migration
```
REST -> GRAPHQL MIGRATION PLAN:
|  Phase 1: GraphQL alongside REST                         |
|  - Add GraphQL server (Apollo, Mercurius, etc.)          |
|  - Create schema types matching existing REST responses  |
|  - Resolvers call existing service layer                 |
|  - Both REST and GraphQL serve the same data             |
|  Phase 2: Client migration                               |
|  - Migrate one client feature at a time to GraphQL      |
|  - REST endpoints remain available                       |
|  - Track which endpoints are still called via REST       |
|  Phase 3: REST deprecation                               |
|  - Add deprecation headers to REST endpoints             |
```

#### Monolith -> Microservices Migration
```
MONOLITH -> MICROSERVICES PLAN:
|  Phase 0: Prepare the monolith                           |
|  - Identify bounded contexts (DDD analysis)              |
|  - Draw dependency graph between modules                 |
|  - Introduce module boundaries (interfaces, not direct   |
|    function calls)                                       |
|  - Add integration tests at module boundaries            |
|  Phase 1: Extract first service (pick the easiest)       |
|  - Choose a module with minimal dependencies             |
|  - Create service with its own repo, CI/CD, database     |
|  - Implement API (REST/gRPC) matching module interface   |
|  - Deploy behind feature flag                            |
  ...
```

### Step 4: Data Migration with Zero Downtime

For migrating data between systems without downtime:

```
ZERO-DOWNTIME DATA MIGRATION:
|  Phase 1: Dual-write                                     |
|  - Application writes to BOTH old and new data stores   |
|  - Old store remains source of truth for reads           |
|  - Verify writes land correctly in new store             |
|  Phase 2: Backfill                                       |
|  - Migrate historical data from old to new store         |
|  - Run in batches with rate limiting                     |
|  - Track progress: migrated / total records              |
|  - Verify data integrity after each batch                |
|  Backfill script pattern:                                |
|  ```                                                     |
```
### Step 5: Parallel Run Verification

For validating correctness before full cutover:

```
PARALLEL RUN SETUP:
|  Traffic routing:                                        |
|  +---------+     +-----------+     +------------+        |
|  | Client  | --> | Router /  | --> | Old System |        |
|  |         |     | Proxy     |     +------------+        |
|  +---------+     |           |          |                |
|                  |           |     (primary response)    |
|                  |           |                            |
|                  |           | --> +------------+         |
|                  |           |     | New System |         |
|                  +-----------+     +------------+         |
|                                         |                |
```
#### Comparison Script Template
```python
import json
import logging
from dataclasses import dataclass

@dataclass
class ComparisonResult:
```

### Step 6: Rollback Planning

Every migration must have a documented rollback plan:

```
ROLLBACK PLAN:
|  Trigger conditions (when to roll back):                 |
|  - Error rate exceeds <threshold> for > 5 minutes        |
|  - Latency p99 exceeds <threshold> for > 5 minutes       |
|  - Data inconsistency detected                           |
|  - Critical bug in new system with no quick fix          |
|  Rollback steps:                                         |
|  1. Switch traffic back to old system (DNS/routing)      |
|  2. Stop dual-writes to new system                       |
|  3. Reconcile any data written only to new system        |
|  4. Notify stakeholders of rollback                      |
|  5. Post-mortem: why did the migration fail?             |
```
### Step 7: Migration Tracking and Reporting

```
MIGRATION PROGRESS:
|  Migration:    <source> -> <target>                      |
|  Strategy:     <big bang | strangler fig | parallel run  |
|                 | branch by abstraction>                 |
|  Status:       <planning | in-progress | verifying |    |
|                 complete | rolled-back>                  |
|  Progress:                                               |
|    Components migrated:  <N> / <total> (<percentage>)    |
|    Data migrated:        <N> / <total> records           |
|    Tests passing:        <N> / <total>                   |
|    Parallel run match:   <percentage>                    |
|  Timeline:                                               |
```
Commit: `"migration: <source> -> <target> -- <phase> (<strategy>)"`

### Step 8: Commit and Report
Save plan, create docs/migrations/<name>.md, commit: `"migration: <source> -> <target> -- <phase> (<strategy>)"`
## Key Behaviors
1. **Assess before migrating.** Understand full scope before starting.
2. **Strangler fig by default.** Incremental over big bang for large codebases.
3. **Parallel run for data integrity.** Match rate > 99.9% before trust.
4. **Every migration reversible.** Rollback plan before starting.
5. **Feature flags control cutover.** Never switch traffic via deployment.
6. **Migrate tests first.** Tests prove behavior preservation.
7. **Track progress visibly.** Large migrations span weeks/months.
8. **One boundary at a time.** Ship, verify, roll back independently.

## Flags & Options

| Flag | Description |
|--|--|
| (none) | Interactive migration assessment and planning |
| `--assess` | Assessment only — analyze scope without planning |
| `--plan` | Generate detailed migration plan |

## Auto-Detection

```
ON project scan:
  IF tsconfig.json allowJs AND *.js + *.ts coexist: SUGGEST JS->TS migration
  IF pages/ AND app/ coexist in Next.js: SUGGEST Router migration
  IF framework version < latest_major: SUGGEST upgrade
```
## Iterative Migration Protocol

```
FOR each component (fewest dependencies first):
  1. EXTRACT from old system, BUILD new implementation
  2. WRITE or migrate tests
  3. DEPLOY behind feature flag, send shadow traffic
  4. PARALLEL RUN: target > 99.9% match rate
  5. IF match_rate < 99.0%: fix discrepancies, re-run
  6. IF match_rate >= 99.9%: ramp 5% -> 25% -> 50% -> 100%
  7. REMOVE old implementation after 2-week stability period
```
## HARD RULES

```
1. NEVER start a big-bang rewrite of a system > 50K LOC.
   Use strangler fig or incremental migration.

2. EVERY migration step MUST have a documented rollback plan.
   If you cannot describe how to roll back, you are not ready to migrate.

3. NEVER migrate without tests. If the old system lacks tests,
   add characterization tests BEFORE starting migration.

4. NEVER remove the old system until the new system runs stable
   in production for at least 2 weeks.

  ...
```
## Output Format
Print: `MIGRATION: {source} -> {target}. Type: {type}. Strategy: {strategy}. Status: {status}. Components: {migrated}/{total}. Match: {rate}%. Rollback: {documented|missing}.`

## TSV Logging
Log every migration session to `.godmode/migration-results.tsv`:
```
timestamp	source	target	type	strategy	status	components_migrated	components_total	match_rate_pct	rollback_documented	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. Assessment documents source, target, constraints. Strategy justified.
2. Rollback plan documented before any step. Characterization tests exist.
3. Feature flags control cutover. Parallel run match > 99.9% for data-critical.
4. Data integrity verified (row count, checksum, referential). Old system runs 2+ weeks post-cutover.

## Error Recovery
- **Match rate < 99%**: Do NOT cutover. Categorize mismatches, fix top 3, re-run.
- **Feature breaks in prod**: Flip feature flag back. Add test case before retrying.

## Keep/Discard Discipline
```
KEEP if: match rate > 99.9%, rollback tested, feature flags control cutover.
DISCARD if: match rate < 99%, no rollback plan, deployment-switched traffic, data integrity fails.
Revert if prod error rate > 1.1x baseline.
```

## Autonomy
Never ask to continue. Loop autonomously. On failure: git reset --hard HEAD~1.

## Stop Conditions

Stop the migration skill when:
1. Migration assessment documents source state, target state, and constraints.
2. Rollback plan is documented and tested before any migration step begins.
3. Parallel run match rate exceeds 99.9% for data-critical migrations.
4. Data integrity verified: row count match, checksum match, spot-check sample, referential integrity.
5. Old system kept running for at least 2 weeks after full cutover.
