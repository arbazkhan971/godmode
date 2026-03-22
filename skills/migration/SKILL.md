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
+---------------------------------------------------------+
|  Constraints:                                            |
|    Downtime budget:    <zero | minutes | hours | days>   |
|    Timeline:           <weeks, months, quarters>         |
|    Parallel dev:       <must continue shipping features> |
|    Data volume:        <size of data to migrate>         |
|    Compliance:         <regulatory requirements>         |
+---------------------------------------------------------+
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
|                          | CRA -> Vite, Angular -> React |
|  --------------------------------------------------------|
|  API paradigm migration  | REST -> GraphQL,              |
|                          | REST -> gRPC, SOAP -> REST    |
|  --------------------------------------------------------|
|  Architecture migration  | Monolith -> microservices,    |
|                          | Monolith -> modular monolith, |
|                          | Server -> serverless           |
|  --------------------------------------------------------|
|  Data migration          | PostgreSQL -> Aurora,         |
|                          | MongoDB -> PostgreSQL,        |
|                          | On-prem -> cloud              |
|  --------------------------------------------------------|
|  Infrastructure migration| Heroku -> AWS, VMs -> K8s,   |
|                          | Self-hosted -> managed        |
+---------------------------------------------------------+
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
+---------------------------------------------------------+
|  AVOID WHEN:                                             |
|  - Codebase > 50K LOC                                   |
|  - Zero-downtime requirement                            |
|  - Must continue shipping features during migration     |
|  - Team cannot dedicate 100% to migration               |
+---------------------------------------------------------+
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
|  +---------+     +---------+     +------------+          |
|                                                          |
|  Phase 2: Partial migration                              |
|  +---------+     +---------+     +------------+          |
|  | Client  | --> | Facade  | --> | Old System |          |
|  +---------+     +---------+     +------------+          |
|                      |                                   |
|                      +---------> | New System |          |
|                                  +------------+          |
|                                  (feature A, B)          |
|                                                          |
|  Phase 3: Mostly migrated                                |
|  +---------+     +---------+     +------------+          |
|  | Client  | --> | Facade  | --> | Old System |          |
|  +---------+     +---------+     +------------+          |
|                      |           (feature Z only)        |
|                      +---------> | New System |          |
|                                  +------------+          |
|                                  (A, B, C, ..., Y)       |
|                                                          |
|  Phase 4: Complete                                       |
|  +---------+     +------------+                          |
|  | Client  | --> | New System |                          |
|  +---------+     +------------+                          |
|                  (facade removed, old system             |
|                   decommissioned)                         |
+---------------------------------------------------------+
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
|  Conversion order:                                       |
|    1. Shared types/interfaces (create types/ directory)  |
|    2. Utility functions (pure functions, easy to type)   |
|    3. Data models / entities                             |
|    4. Services / business logic                          |
|    5. Controllers / route handlers                       |
|    6. Middleware                                          |
|    7. Configuration files                                |
|    8. Entry points (index.ts, server.ts)                 |
+---------------------------------------------------------+
|  Phase 3: Strictness ramp-up                             |
|  - Enable strict: true                                   |
|  - Enable noImplicitAny                                  |
|  - Enable strictNullChecks                               |
|  - Replace all 'any' with proper types                   |
|  - Add eslint rule: @typescript-eslint/no-explicit-any   |
+---------------------------------------------------------+
|  Phase 4: Cleanup                                        |
|  - Remove allowJs: true                                  |
|  - Remove all @ts-ignore comments                        |
|  - Full type coverage audit                              |
+---------------------------------------------------------+

TRACKING:
  Total files:        <N>
  Converted:          <N> (<percentage>%)
  Remaining:          <N>
  'any' count:        <N> (target: 0)
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
|  - Log REST usage to find remaining consumers            |
|  - Notify consumers of migration timeline                |
+---------------------------------------------------------+
|  Phase 4: REST removal                                   |
|  - Remove REST endpoints with zero traffic               |
|  - Keep REST for external/public APIs if needed          |
|  - Clean up dual-serving code                            |
+---------------------------------------------------------+
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
|  - Compare outputs, fix discrepancies                    |
|  - Switch traffic to new service                         |
|  - Remove module from monolith                           |
+---------------------------------------------------------+
|  Phase 2: Extract next service (repeat)                  |
|  - Each extraction gets easier as patterns emerge        |
|  - Establish service templates and shared libraries      |
|  - Build out infrastructure (service mesh, observability)|
+---------------------------------------------------------+
|  Phase N: Decommission monolith                          |
|  - Last module extracted                                 |
|  - Monolith becomes thin routing layer, then removed     |
+---------------------------------------------------------+

EXTRACTION ORDER (by risk):
  1. Stateless services first (notifications, email)
  2. Read-heavy services next (search, reporting)
  3. Write-heavy services (core business logic) last
  4. Shared data services (auth, user management) very last
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
|  BATCH_SIZE = 1000                                       |
|  last_id = 0                                             |
|  while true:                                             |
|    batch = SELECT * FROM old WHERE id > last_id          |
|            ORDER BY id LIMIT BATCH_SIZE                  |
|    if batch is empty: break                              |
|    INSERT INTO new VALUES batch                          |
|    last_id = batch[-1].id                                |
|    log("Migrated up to id={last_id}")                    |
|    sleep(100ms)  # rate limit                            |
|  ```                                                     |
+---------------------------------------------------------+
|  Phase 3: Shadow reads                                   |
|  - Read from BOTH stores, compare results                |
|  - Log discrepancies, do not fail requests               |
|  - Fix discrepancies until match rate > 99.99%           |
+---------------------------------------------------------+
|  Phase 4: Cutover                                        |
|  - Switch reads to new store                             |
|  - Keep dual-write for rollback safety                   |
|  - Monitor error rates and latency                       |
+---------------------------------------------------------+
|  Phase 5: Cleanup                                        |
|  - Stop writing to old store                             |
|  - Remove dual-write code                                |
|  - Decommission old store after retention period         |
+---------------------------------------------------------+

DATA INTEGRITY VERIFICATION:
  Row count match:      old.count() == new.count()
  Checksum match:       MD5(old.data) == MD5(new.data)
  Spot check:           Random sample comparison (1000 rows)
  Edge cases:           NULLs, empty strings, unicode, dates
  Referential integrity: Foreign keys resolve correctly
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
|                                    (shadow response,     |
|                                     compared but not     |
|                                     returned to client)  |
+---------------------------------------------------------+
|  Comparison metrics:                                     |
|    Response match rate:    <percentage>                   |
|    Latency difference:     <old p99> vs <new p99>        |
|    Error rate difference:  <old> vs <new>                |
|    Data consistency:       <percentage of matching data> |
+---------------------------------------------------------+
|  Confidence thresholds:                                  |
|    Response match:   > 99.9%  -> READY for cutover      |
|    Response match:   > 99.0%  -> INVESTIGATE mismatches  |
|    Response match:   < 99.0%  -> NOT READY              |
+---------------------------------------------------------+
```

#### Comparison Script Template
```python
import json
import logging
from dataclasses import dataclass

@dataclass
class ComparisonResult:
    endpoint: str
    match: bool
    old_status: int
    new_status: int
    old_latency_ms: float
    new_latency_ms: float
    diff: str | None = None

def compare_responses(old_response, new_response) -> ComparisonResult:
    """Compare responses from old and new systems."""
    # Normalize responses (ignore timestamps, request IDs, etc.)
    old_body = normalize(old_response.json())
    new_body = normalize(new_response.json())

    match = old_body == new_body
    diff = None
    if not match:
        diff = compute_diff(old_body, new_body)

    return ComparisonResult(
        endpoint=old_response.url,
        match=match,
        old_status=old_response.status_code,
        new_status=new_response.status_code,
        old_latency_ms=old_response.elapsed.total_seconds() * 1000,
        new_latency_ms=new_response.elapsed.total_seconds() * 1000,
        diff=diff,
    )
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
|  Rollback time estimate: <minutes>                       |
|  Data reconciliation needed: <yes/no>                    |
|  Feature flags to flip: <list>                           |
|  Runbook location: <path>                                |
+---------------------------------------------------------+
|  Point of no return:                                     |
|  After <condition>, rollback is no longer possible.      |
|  Example: "After old database is decommissioned" or      |
|  "After old API contract is removed from consumers."     |
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
|    Started:     <date>                                   |
|    Phase:       <current phase>                          |
|    Est. complete: <date>                                 |
+---------------------------------------------------------+
|  Risks:                                                  |
|    - <risk 1 with mitigation>                            |
|    - <risk 2 with mitigation>                            |
+---------------------------------------------------------+
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

## Example Usage

### TypeScript migration
```
User: /godmode:migration Convert our Express.js app to TypeScript

Migration: Assessing project...

MIGRATION ASSESSMENT:
  Source: JavaScript (Express.js, 142 files, ~18K LOC)
  Target: TypeScript (strict mode)
  Strategy: Incremental conversion with allowJs

JS -> TS MIGRATION PLAN:
  Phase 1: Setup (today)
    - Install typescript, @types/express, @types/node
    - Create tsconfig.json with allowJs: true, strict: false
    - Verify build works with zero changes

  Phase 2: Incremental conversion
    Conversion order (leaf-first):
    1. src/types/ (create shared interfaces) — 0 files to convert
    2. src/utils/ — 12 files
    3. src/models/ — 8 files
    4. src/services/ — 15 files
    5. src/controllers/ — 22 files
    6. src/middleware/ — 6 files
    7. src/config/ — 4 files
    8. src/index.js -> src/index.ts

  Phase 3: Strict mode
    Enable strict: true, eliminate all 'any' types

  Estimated timeline: 3-4 weeks at 5 files/day

Start with Phase 1 setup? [Y/n]
```

### Monolith decomposition
```
User: /godmode:migration Break our monolith into microservices

Migration: Assessing architecture...

MIGRATION ASSESSMENT:
  Source: Node.js monolith (312 files, 45K LOC, 8 modules)
  Target: Microservices
  Strategy: Strangler fig (zero-downtime requirement)

Bounded contexts identified:
  1. Auth (user management, sessions) — HIGH coupling
  2. Notifications (email, SMS, push) — LOW coupling *
  3. Payments (billing, invoices) — MEDIUM coupling
  4. Search (product search, indexing) — LOW coupling *
  5. Orders (cart, checkout, fulfillment) — HIGH coupling
  6. Inventory (stock, warehouses) — MEDIUM coupling
  7. Reporting (analytics, exports) — LOW coupling *
  8. Admin (dashboard, config) — MEDIUM coupling

Recommended extraction order (* = good first candidates):
  1. Notifications (fewest dependencies, stateless)
  2. Search (read-only, can use eventual consistency)
  3. Reporting (read-only, can tolerate stale data)
  4. Inventory -> Payments -> Orders -> Auth -> Admin

Shall I create the detailed plan for extracting Notifications first?
```

## Flags & Options

| Flag | Description |
|------|-------------|
| (none) | Interactive migration assessment and planning |
| `--assess` | Assessment only — analyze scope without planning |
| `--plan` | Generate detailed migration plan |
| `--track` | Show migration progress dashboard |
| `--verify` | Run parallel comparison / verification |
| `--rollback` | Execute rollback plan |
| `--strategy <name>` | Force a specific strategy (strangler, bigbang, parallel, abstraction) |
| `--phase <N>` | Show details for a specific migration phase |
| `--dry-run` | Show migration plan without making changes |
| `--report` | Generate migration progress report |

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
WHEN executing a strangler fig or incremental migration:

current_component = 0
total_components = len(components_to_migrate)
migrated = []
verification_failures = []

WHILE current_component < total_components:
  component = components_to_migrate[current_component]

  1. EXTRACT component from old system
  2. BUILD new implementation
  3. WRITE tests (or migrate existing tests)
  4. DEPLOY behind feature flag (traffic: 0%)
  5. PARALLEL RUN:
     - Send shadow traffic to new implementation
     - Compare outputs with old implementation
     - Target: > 99.9% match rate

  IF match_rate < 99.0%:
    verification_failures.append(component)
    LOG "Component {component} match rate {match_rate}% -- NOT READY"
    FIX discrepancies and re-run parallel comparison
    CONTINUE  # retry same component

  IF match_rate >= 99.9%:
    6. RAMP traffic: 5% -> 25% -> 50% -> 100%
    7. MONITOR error rates and latency at each step
    8. REMOVE old implementation after 2-week stability period
    migrated.append(component)
    current_component += 1

  REPORT "{current_component}/{total_components} components migrated"

FINAL:
  IF len(verification_failures) > 0:
    REPORT "Components needing attention: {verification_failures}"
  REPORT "Migration progress: {len(migrated)}/{total_components}"
```

## Multi-Agent Dispatch

```
WHEN executing a large-scale migration (e.g., monolith -> microservices, JS -> TS):

DISPATCH parallel agents in worktrees:

  Agent 1 (migration-executor):
    - Migrate components in priority order
    - Convert files, update imports, fix type errors
    - Output: migrated source files

  Agent 2 (test-migrator):
    - Migrate or rewrite tests for converted components
    - Add characterization tests for components without coverage
    - Output: test files matching migrated components

  Agent 3 (verification):
    - Run parallel comparison between old and new implementations
    - Track match rates and discrepancies
    - Output: verification-report.md

  Agent 4 (documentation):
    - Update migration tracking document
    - Document breaking changes and rollback procedures
    - Output: docs/migrations/<name>.md

MERGE:
  - Verify test agent's tests pass on migration agent's code
  - Verify verification agent confirms match rates
  - Combine all outputs into single migration commit
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

6. NEVER migrate the most coupled module first.
   Start with the module that has the fewest dependencies.

7. EVERY data migration MUST verify: row count match, checksum match,
   spot-check sample, and referential integrity.

8. NEVER skip the parallel run for data-critical migrations.
   "It works in staging" is not sufficient proof.
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
  → Reconcile: compare row counts old vs new, identify missing records
  → Re-run backfill for missing ID ranges
  → Verify: row count match + checksum match before resuming
  → Add continuous integrity check: run comparison every hour during migration

IF team velocity drops during migration (feature development slows):
  → Assess: is the migration consuming too much of the team's capacity?
  → Reduce migration scope: fewer components per sprint, not zero features per sprint
  → Consider: dedicate a sub-team to migration while others continue feature work
  → If still too slow: pause migration, ship critical features, resume migration

IF old system receives updates during migration:
  → This is expected in strangler fig — old system stays operational
  → Ensure dual-write captures changes in both old and new systems
  → If schema changed in old system: update new system's mapping/adapter
  → If new feature added to old system: migrate it as the next component

IF cutover succeeds but latency regresses:
  → Compare: old system p99 vs new system p99
  → Profile new system: is the regression in application code, database, or network?
  → Optimize the hot path in the new system before decommissioning old system
  → If regression > 2x: roll back and fix before retrying cutover
```

## Anti-Patterns

- **Do NOT start a big bang rewrite of a large system.** Rewrites that exceed 3 months almost always fail. The business cannot pause feature development that long, and requirements drift makes the rewrite a moving target.
- **Do NOT migrate without tests.** If the old system has no tests, add characterization tests (golden master, approval tests) before migrating. Without tests, you cannot prove the migration preserves behavior.
- **Do NOT migrate everything at once.** Extract one module, deploy it, verify it, stabilize it. Then extract the next. Trying to extract five services simultaneously creates five integration problems simultaneously.
- **Do NOT skip the parallel run.** "It works in staging" is not sufficient proof for a data-critical migration. Run both systems in production, compare outputs, and fix discrepancies before switching.
- **Do NOT forget the rollback plan.** Every migration step must be reversible. If you deploy the new service and it fails, you need to route traffic back to the old system within minutes, not hours.
- **Do NOT underestimate data migration.** Data migration is always harder than code migration. Edge cases in data (NULLs, encoding issues, orphaned records, corrupted entries) will surface during migration and must be handled.
- **Do NOT migrate the most coupled module first.** Start with the module that has the fewest dependencies. Success with the first extraction builds confidence and establishes patterns for subsequent extractions.
- **Do NOT remove the old system too soon.** Keep the old system running as a fallback for at least 2 weeks after full cutover. Decommission only after monitoring confirms the new system is stable.
- **Do NOT ignore the team.** A migration is a people problem as much as a technical problem. The team needs training on the new technology, clear documentation, and time to ramp up.


## Data Migration Loop

Structured iterative loop for data migration with integrity checks, performance benchmarks, and rollback verification:

```
DATA MIGRATION LOOP:
Source: <source system and version>
Target: <target system and version>
Data volume: <total records, total size>
Downtime budget: <zero | minutes | hours>

INTEGRITY CHECK PROTOCOL:
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Phase    │ Status          │
├──────────────────────────────────────────────────────────────────┤
│  Row count: source == target        │ Per-batch│ PASS|FAIL|SKIP  │
│  Checksum: MD5/SHA256 match         │ Per-batch│ PASS|FAIL|SKIP  │
│  Spot-check: random 1000 rows match │ Per-batch│ PASS|FAIL|SKIP  │
│  Schema match: all columns present  │ Pre-mig  │ PASS|FAIL       │
│  Data types match (or mapped)       │ Pre-mig  │ PASS|FAIL       │
│  NULL handling: NULLs preserved     │ Per-batch│ PASS|FAIL       │
│  Unicode/encoding: UTF-8 preserved  │ Per-batch│ PASS|FAIL       │
│  Date/time: timezone handling OK    │ Per-batch│ PASS|FAIL       │
│  Referential integrity: FKs resolve │ Post-mig │ PASS|FAIL       │
│  Edge cases: empty strings, 0,      │ Post-mig │ PASS|FAIL       │
│    negative numbers, max values     │          │                 │
│  Orphaned records: none created     │ Post-mig │ PASS|FAIL       │
│  Sequence/auto-increment: correct   │ Post-mig │ PASS|FAIL       │
│  Indexes rebuilt and verified       │ Post-mig │ PASS|FAIL       │
│  Constraints re-enabled and valid   │ Post-mig │ PASS|FAIL       │
└──────────────────────────────────────────────────────────────────┘

  Per-batch integrity verification:
    FOR each batch of BATCH_SIZE records:
      1. MIGRATE batch from source to target
      2. COUNT: source_count == target_count for this batch
      3. CHECKSUM: compute hash of (id, key_columns) for random sample
      4. COMPARE: sample matches between source and target
      5. IF any check fails:
         - HALT migration
         - LOG failing records with details
         - FIX data mapping or transformation
         - RE-RUN failed batch (not entire migration)
      6. LOG: { batch_id, records, duration, integrity_status }

PERFORMANCE BENCHMARK PROTOCOL:
┌──────────────────────────────────────────────────────────────────┐
│  Metric                    │ Baseline  │ During Mig │ Acceptable │
├──────────────────────────────────────────────────────────────────┤
│  Source read latency (p99) │ <ms>      │ <ms>       │ < 2x base  │
│  Target write latency (p99)│ <ms>      │ <ms>       │ < 3x base  │
│  Application latency (p99) │ <ms>      │ <ms>       │ < 1.5x base│
│  Application error rate    │ <pct>%    │ <pct>%     │ < 1.1x base│
│  Migration throughput      │ N/A       │ <rec/s>    │ > <target> │
│  Source CPU utilization    │ <pct>%    │ <pct>%     │ < 80%      │
│  Target CPU utilization    │ <pct>%    │ <pct>%     │ < 80%      │
│  Replication lag (if dual) │ <ms>      │ <ms>       │ < 5 min    │
│  Total migration ETA       │ N/A       │ <hours>    │ < budget   │
└──────────────────────────────────────────────────────────────────┘

  Performance tuning during migration:
    1. MEASURE baseline metrics before migration starts (1 hour window)
    2. START migration with conservative batch size and rate limit
    3. MONITOR source and target load continuously
    4. IF source CPU > 60%: reduce batch size or add rate limiting
    5. IF target write latency > 3x baseline: reduce concurrent writers
    6. IF application latency > 1.5x baseline: pause migration, resume off-peak
    7. GRADUALLY increase throughput as system proves stable
    8. LOG: { timestamp, batch_size, throughput, source_cpu, target_cpu, app_latency }

  Migration speed estimation:
    total_records = <N>
    current_throughput = <records/second>
    estimated_completion = total_records / current_throughput
    completed_pct = migrated_records / total_records * 100
    REPORT every 10%: "Migration {completed_pct}% complete. ETA: {estimated_completion}"

ROLLBACK VERIFICATION PROTOCOL:
┌──────────────────────────────────────────────────────────────────┐
│  Check                              │ Status   │ Evidence        │
├──────────────────────────────────────────────────────────────────┤
│  Rollback plan documented           │ PASS|FAIL│ <doc link>      │
│  Rollback tested in staging         │ PASS|FAIL│ <test date>     │
│  Rollback time measured             │ PASS|FAIL│ <minutes>       │
│  Data written to target can be      │ PASS|FAIL│ <reconciliation>│
│    reconciled back to source        │          │                 │
│  Feature flags control read/write   │ PASS|FAIL│ <flag names>    │
│    routing (instant switch)         │          │                 │
│  Dual-write is active during mig    │ PASS|FAIL│ <dual-write>    │
│    (both systems get writes)        │          │                 │
│  Rollback does not lose data        │ PASS|FAIL│ <proof>         │
│    written during migration         │          │                 │
│  Application code handles both      │ PASS|FAIL│ <abstraction>   │
│    source and target transparently  │          │                 │
│  Monitoring alerts configured for   │ PASS|FAIL│ <alert config>  │
│    migration health                 │          │                 │
│  Communication plan for rollback    │ PASS|FAIL│ <stakeholder    │
│    (who to notify, how)             │          │  notification>  │
│  Point of no return identified      │ PASS|FAIL│ <condition>     │
└──────────────────────────────────────────────────────────────────┘

  Rollback drill:
    1. SET UP staging environment mirroring production
    2. RUN migration to 50% completion
    3. TRIGGER rollback (flip feature flag to source)
    4. VERIFY: application serves correctly from source
    5. VERIFY: no data loss (writes during migration are in source)
    6. MEASURE: rollback completion time (must be < 5 minutes)
    7. VERIFY: monitoring detects and alerts on rollback event
    8. DOCUMENT: any issues found during drill, fix before production

MIGRATION ITERATION PROTOCOL:
current_phase = "pre_migration"
phases = [pre_migration, dual_write, backfill, shadow_read, cutover, cleanup]
integrity_failures = 0
max_integrity_failures = 3

WHILE current_phase != "complete":

  IF current_phase == "pre_migration":
    1. RUN schema comparison (source vs target)
    2. RUN integrity check on empty target (schema, constraints, indexes)
    3. TEST rollback procedure in staging
    4. MEASURE baseline performance metrics
    5. VERIFY dual-write code deployed and feature-flagged off
    current_phase = "dual_write"

  IF current_phase == "dual_write":
    1. ENABLE dual-write (new writes go to both source and target)
    2. MONITOR for 24 hours: verify writes land in both systems
    3. COMPARE: random sample of new records match between systems
    4. IF match rate < 99.9%: FIX dual-write logic before proceeding
    current_phase = "backfill"

  IF current_phase == "backfill":
    1. MIGRATE historical data in batches (oldest first)
    2. PER-BATCH integrity checks (count, checksum, spot-check)
    3. MONITOR performance (source CPU, target CPU, app latency)
    4. IF integrity check fails:
       integrity_failures += 1
       IF integrity_failures > max_integrity_failures: HALT and investigate
       FIX and retry failed batch
    5. REPORT progress every 10%
    6. WHEN 100% backfilled: run FULL integrity verification
    current_phase = "shadow_read"

  IF current_phase == "shadow_read":
    1. READ from both source and target, compare results
    2. RETURN source results to application (target is shadow)
    3. LOG every discrepancy with details
    4. TARGET: > 99.99% match rate for 48 hours
    5. IF match rate < 99.9%: investigate and fix discrepancies
    current_phase = "cutover"

  IF current_phase == "cutover":
    1. SWITCH reads to target (feature flag flip)
    2. MONITOR error rate and latency for 4 hours
    3. IF error rate > 1.1x baseline OR latency > 1.5x baseline:
       ROLLBACK to source immediately
    4. KEEP dual-write active for 7 days (rollback safety)
    current_phase = "cleanup"

  IF current_phase == "cleanup":
    1. DISABLE dual-write (target is sole source of truth)
    2. KEEP source running for 14 more days (emergency rollback)
    3. FINAL integrity check: full comparison
    4. DECOMMISSION source after 14-day stability period
    current_phase = "complete"

FINAL:
  REPORT migration summary:
    - Total records migrated: <N>
    - Integrity check failures: <N> (all resolved)
    - Migration duration: <hours/days>
    - Performance impact: <max latency increase during migration>
    - Rollback events: <N> (0 in production is ideal)
    - Data loss: ZERO (verified)
```

## Platform Fallback (Gemini CLI, OpenCode, Codex)
If your platform lacks `Agent()` or `EnterWorktree`:
- Run tech migration tasks sequentially: file migration, then test migration, then verification.
- Use branch isolation per task: `git checkout -b godmode-migration-{task}`, implement, commit, merge back.
- See `adapters/shared/sequential-dispatch.md` for full protocol.
