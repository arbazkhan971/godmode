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
+---------------------------------------------------------+
|  Source State:                                            |
|    Language/Framework: <current tech stack>               |
|    Architecture:       <monolith | modular monolith |    |
|                         microservices | serverless>       |
|    Data stores:        <databases, caches, queues>       |
|    Code size:          <files, LOC, modules>             |
|    Test coverage:      <percentage, if known>            |
|    Team size:          <number of developers>            |
+---------------------------------------------------------+
|  Target State:                                           |
|    Language/Framework: <target tech stack>                |
|    Architecture:       <target architecture>              |
|    Rationale:          <why migrate>                      |
```

Classification of migration types:
```
MIGRATION TYPE CLASSIFICATION:
+---------------------------------------------------------+
|  Type                    | Examples                      |
|  --------------------------------------------------------|
|  Language migration      | JS -> TS, Python 2 -> 3,     |
|                          | Java -> Kotlin                |
|  --------------------------------------------------------|
|  Framework migration     | Express -> Fastify,           |
|  --------------------------------------------------------|
|  --------------------------------------------------------|
```

### Step 2: Migration Strategy Selection
Choose the appropriate migration strategy based on type and constraints:

#### Strategy: Big Bang
```
BIG BANG MIGRATION:
+---------------------------------------------------------+
|  How:     Rewrite everything at once, switch over        |
|  When:    Small codebase, low traffic, acceptable        |
|           downtime, clean break needed                    |
|  Risk:    HIGH — all-or-nothing, no gradual rollback     |
|  Timeline: Short but concentrated                        |
+---------------------------------------------------------+
|  Steps:                                                  |
|  1. Build new system in parallel                         |
|  2. Freeze feature development on old system             |
|  3. Migrate all data in a maintenance window             |
|  4. Switch DNS/routing to new system                     |
|  5. Verify and monitor                                   |
|  6. Decommission old system after stability period       |
```

#### Strategy: Strangler Fig
```
STRANGLER FIG PATTERN:
+---------------------------------------------------------+
|  How:     Incrementally replace old system piece by      |
|           piece, routing traffic through a facade        |
|  When:    Large codebase, zero-downtime, must continue   |
|           shipping features alongside migration          |
|  Risk:    LOW — each piece is independently deployable   |
|           and reversible                                 |
|  Timeline: Long but sustainable                          |
+---------------------------------------------------------+
|                                                          |
|  Phase 1: Facade                                        |
|  +---------+     +---------+                             |
|  | Client  | --> | Facade  | --> | Old System |          |
```

#### Strategy: Parallel Run
```
PARALLEL RUN:
+---------------------------------------------------------+
|  How:     Run old and new systems simultaneously,        |
|           compare outputs, switch when confident         |
|  When:    Data integrity critical, need to verify        |
|           correctness before switching                   |
|  Risk:    MEDIUM — double infrastructure cost, but       |
|           high confidence in correctness                 |
+---------------------------------------------------------+
|  Steps:                                                  |
|  1. Build new system alongside old                       |
|  2. Send traffic to BOTH systems (shadow traffic or      |
|     dual-write)                                          |
|  3. Compare outputs/results automatically                |
|  4. Fix discrepancies until match rate > 99.9%           |
|  5. Switch primary to new system                         |
|  6. Keep old system as fallback for N days               |
|  7. Decommission old system                              |
+---------------------------------------------------------+
```

#### Strategy: Branch by Abstraction
```
BRANCH BY ABSTRACTION:
+---------------------------------------------------------+
|  How:     Introduce abstraction layer, swap              |
|           implementation behind it                       |
|  When:    Internal component replacement, same API       |
|           contract, feature-flag controlled               |
|  Risk:    LOW — abstraction isolates change              |
+---------------------------------------------------------+
|  Steps:                                                  |
|  1. Create abstraction layer (interface/adapter)         |
|  2. Route existing code through abstraction              |
|  3. Build new implementation behind same abstraction     |
|  4. Feature flag between old and new implementation      |
|  5. Gradually roll out new implementation                |
|  6. Remove old implementation and abstraction layer      |
+---------------------------------------------------------+
```

### Step 3: Language/Framework Migration Planning

For JS -> TS, Python 2 -> 3, React class -> hooks, etc.:

#### TypeScript Migration (JS -> TS)
```
JS -> TS MIGRATION PLAN:
+---------------------------------------------------------+
|  Phase 1: Setup (Day 1)                                  |
|  - Install typescript, @types/* packages                 |
|  - Create tsconfig.json with allowJs: true               |
|  - Configure strict: false initially                     |
|  - Add ts-check to build pipeline                        |
+---------------------------------------------------------+
|  Phase 2: Incremental conversion (Ongoing)               |
|  - Rename .js -> .ts one file at a time                  |
|  - Start with leaf modules (no dependents)               |
|  - Add types to function signatures                      |
|  - Use 'any' as escape hatch, track with lint rule       |
|  - Convert test files alongside source files             |
|                                                          |
```

#### REST -> GraphQL Migration
```
REST -> GRAPHQL MIGRATION PLAN:
+---------------------------------------------------------+
|  Phase 1: GraphQL alongside REST                         |
|  - Add GraphQL server (Apollo, Mercurius, etc.)          |
|  - Create schema types matching existing REST responses  |
|  - Resolvers call existing service layer                 |
|  - Both REST and GraphQL serve the same data             |
+---------------------------------------------------------+
|  Phase 2: Client migration                               |
|  - Migrate one client feature at a time to GraphQL      |
|  - REST endpoints remain available                       |
|  - Track which endpoints are still called via REST       |
+---------------------------------------------------------+
|  Phase 3: REST deprecation                               |
|  - Add deprecation headers to REST endpoints             |
```

#### Monolith -> Microservices Migration
```
MONOLITH -> MICROSERVICES PLAN:
+---------------------------------------------------------+
|  Phase 0: Prepare the monolith                           |
|  - Identify bounded contexts (DDD analysis)              |
|  - Draw dependency graph between modules                 |
|  - Introduce module boundaries (interfaces, not direct   |
|    function calls)                                       |
|  - Add integration tests at module boundaries            |
+---------------------------------------------------------+
|  Phase 1: Extract first service (pick the easiest)       |
|  - Choose a module with minimal dependencies             |
|  - Create service with its own repo, CI/CD, database     |
|  - Implement API (REST/gRPC) matching module interface   |
|  - Deploy behind feature flag                            |
|  - Parallel run: monolith module + new service           |
```

### Step 4: Data Migration with Zero Downtime

For migrating data between systems without downtime:

```
ZERO-DOWNTIME DATA MIGRATION:
+---------------------------------------------------------+
|  Phase 1: Dual-write                                     |
|  - Application writes to BOTH old and new data stores   |
|  - Old store remains source of truth for reads           |
|  - Verify writes land correctly in new store             |
+---------------------------------------------------------+
|  Phase 2: Backfill                                       |
|  - Migrate historical data from old to new store         |
|  - Run in batches with rate limiting                     |
|  - Track progress: migrated / total records              |
|  - Verify data integrity after each batch                |
|                                                          |
|  Backfill script pattern:                                |
|  ```                                                     |
```

### Step 5: Parallel Run Verification

For validating correctness before full cutover:

```
PARALLEL RUN SETUP:
+---------------------------------------------------------+
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
# ... (condensed)
```

### Step 6: Rollback Planning

Every migration must have a documented rollback plan:

```
ROLLBACK PLAN:
+---------------------------------------------------------+
|  Trigger conditions (when to roll back):                 |
|  - Error rate exceeds <threshold> for > 5 minutes        |
|  - Latency p99 exceeds <threshold> for > 5 minutes       |
|  - Data inconsistency detected                           |
|  - Critical bug in new system with no quick fix          |
+---------------------------------------------------------+
|  Rollback steps:                                         |
|  1. Switch traffic back to old system (DNS/routing)      |
|  2. Stop dual-writes to new system                       |
|  3. Reconcile any data written only to new system        |
|  4. Notify stakeholders of rollback                      |
|  5. Post-mortem: why did the migration fail?             |
+---------------------------------------------------------+
```

### Step 7: Migration Tracking and Reporting

```
MIGRATION PROGRESS:
+---------------------------------------------------------+
|  Migration:    <source> -> <target>                      |
|  Strategy:     <big bang | strangler fig | parallel run  |
|                 | branch by abstraction>                 |
|  Status:       <planning | in-progress | verifying |    |
|                 complete | rolled-back>                  |
+---------------------------------------------------------+
|  Progress:                                               |
|    Components migrated:  <N> / <total> (<percentage>)    |
|    Data migrated:        <N> / <total> records           |
|    Tests passing:        <N> / <total>                   |
|    Parallel run match:   <percentage>                    |
+---------------------------------------------------------+
|  Timeline:                                               |
```

Commit: `"migration: <source> -> <target> -- <phase> (<strategy>)"`

### Step 8: Commit and Report

```
1. Save migration plan and any generated code
2. Create tracking document at docs/migrations/<name>.md
3. Commit: "migration: <source> -> <target> -- <phase> (<strategy>)"
4. Report progress and next steps
```

## Key Behaviors

1. **Assess before migrating.** Never start a migration without understanding the full scope: code size, dependencies, data volume, team capacity, and timeline. Underestimating scope is the number one cause of failed migrations.
2. **Strangler fig by default.** Unless the codebase is small and downtime is acceptable, always prefer incremental migration over big bang rewrites. The strangler fig pattern allows continuous feature development alongside migration.
3. **Parallel run for data integrity.** When data correctness is critical, run old and new systems side by side and compare outputs. Do not trust the new system until the match rate exceeds 99.9%.
4. **Every migration is reversible.** Document the rollback plan before starting. If you cannot describe how to roll back, you are not ready to migrate forward.
5. **Feature flags control the cutover.** Never switch traffic with a deployment. Use feature flags to control which system handles requests. Flags can be flipped instantly; deployments cannot.
6. **Migrate tests first.** Before migrating application code, migrate or create tests. Tests are the safety net that proves the migration preserves behavior.
7. **Track and report progress.** Large migrations span weeks or months. Without visible progress tracking, stakeholders lose confidence and teams lose momentum.
8. **One boundary at a time.** Extract one module, one endpoint, one component at a time. Each extraction is a self-contained unit of work that can be shipped, verified, and rolled back independently.

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive migration assessment and planning |
| `--assess` | Assessment only — analyze scope without planning |
| `--plan` | Generate detailed migration plan |

## Auto-Detection

```
ON project scan:
  IF tsconfig.json exists AND allowJs == true:
    js_count = count(*.js in src/)
    ts_count = count(*.ts in src/)
    IF js_count > 0 AND ts_count > 0:
      pct = ts_count / (js_count + ts_count) * 100
      SUGGEST "JS->TS migration in progress ({pct}% converted). Activate /godmode:migration?"

  IF pages/ AND app/ both exist in Next.js project:
    SUGGEST "Pages Router -> App Router migration detected. Activate /godmode:migration?"

  IF package.json has framework version < latest_major:
    SUGGEST "Framework upgrade available ({current} -> {latest}). Activate /godmode:migration?"

  IF docker-compose.yml has single large service AND code has module boundaries:
    SUGGEST "Monolith with module boundaries detected. Activate /godmode:migration for microservice extraction?"
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

4. NEVER remove the old system until the new system has been stable
   in production for at least 2 weeks.

5. ALWAYS use feature flags for cutover. Never switch traffic via deployment.
   Flags flip in seconds; deployments take minutes.

```

## Output Format
Print on completion:
```
MIGRATION: {source} -> {target}
Type: {language|framework|api|architecture|data|infrastructure}
Strategy: {big_bang|strangler_fig|parallel_run|branch_by_abstraction}
Status: {planning|in_progress|verifying|complete|rolled_back}
Components: {migrated}/{total} ({percentage}%)
Data: {migrated_records}/{total_records} records
Parallel run match: {match_rate}%
Rollback plan: {documented|missing}
Timeline: started {date}, est. complete {date}
Artifacts: {list of files created}
```

## TSV Logging
Log every migration session to `.godmode/migration-results.tsv`:
```
timestamp	source	target	type	strategy	status	components_migrated	components_total	match_rate_pct	rollback_documented	verdict
```
Append one row per session. Create the file with headers on first run.

## Success Criteria
1. Migration assessment completed with source state, target state, and constraints documented.
2. Strategy selected and justified: strangler fig for large systems, big bang only for small codebases with acceptable downtime.
3. Rollback plan documented before any migration step begins.
4. Characterization tests exist for all components being migrated (or added before migration starts).
5. Feature flags control cutover — no traffic switching via deployment.
6. Parallel run match rate exceeds 99.9% before cutover for data-critical migrations.
7. Data integrity verified: row count match, checksum match, spot-check sample, referential integrity.
8. Old system kept running for at least 2 weeks after full cutover.
9. Migration progress tracked with visible dashboard (components migrated, match rates, timeline).

## Error Recovery
```
IF parallel run match rate < 99.0%:
  → Do NOT proceed to cutover
  → Analyze mismatches: categorize by type (data format, timing, business logic, edge case)
  → Fix the top 3 mismatch categories
  → Re-run parallel comparison
  → Repeat until match rate > 99.9%

IF migration breaks a feature in production:
  → Flip feature flag to route traffic back to old system (seconds, not minutes)
  → If feature flag not in place: revert deployment, then add feature flag before retrying
  → Investigate: was this a test coverage gap or a parallel run blind spot?
  → Add test case covering the broken scenario before retrying migration

IF data migration loses records:
  → Stop dual-write immediately
```

## Keep/Discard Discipline

After each migration pass, evaluate:
- **KEEP** if: parallel run match rate > 99.9%, rollback plan documented and tested, feature flags control cutover, characterization tests cover migrated components, old system remains operational as fallback.
- **DISCARD** if: match rate < 99.0% (investigate mismatches first), no rollback plan exists, traffic switched via deployment instead of feature flag, or data integrity verification fails (row count, checksum, spot-check).
- Never proceed to cutover without verified rollback. If you cannot roll back in under 5 minutes, you are not ready.
- Revert immediately if production error rate exceeds 1.1x baseline after cutover.

## Stop Conditions

Stop the migration skill when:
1. Migration assessment documents source state, target state, and constraints.
2. Rollback plan is documented and tested before any migration step begins.
3. Parallel run match rate exceeds 99.9% for data-critical migrations.
4. Data integrity verified: row count match, checksum match, spot-check sample, referential integrity.
5. Old system kept running for at least 2 weeks after full cutover.

