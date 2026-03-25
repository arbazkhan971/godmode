---
name: migration
description: System migration and technology transition.
---

## Activate When
- `/godmode:migration`, "migrate from X to Y"
- "convert to TypeScript", "move to microservices"
- "upgrade from React 17 to 19", "strangler fig"

## Workflow

### 1. Migration Assessment
```
Source: <language, framework, architecture, data stores>
Target: <target stack and architecture>
Code size: <files, LOC, modules>
Test coverage: <percentage>
Team size: <N developers>
```
```
Type: Language | Framework | Architecture | Data | API
IF codebase > 50K LOC: use Strangler Fig (not Big Bang)
IF data-critical: use Parallel Run
IF internal component swap: use Branch by Abstraction
```

### 2. Strategy Selection
```
BIG BANG: rewrite all, switch over
  WHEN: <10K LOC, acceptable downtime
  Risk: HIGH — all-or-nothing
STRANGLER FIG: replace piece by piece via facade
  WHEN: large codebase, zero-downtime required
  Risk: LOW — each piece reversible
PARALLEL RUN: old+new simultaneously, compare
  WHEN: data integrity critical
  Risk: MEDIUM — double infra cost
BRANCH BY ABSTRACTION: abstraction layer, swap impl
  WHEN: internal component, same API contract
  Risk: LOW — abstraction isolates change
```

IF team < 3: avoid Big Bang (too risky with small team).
IF match_rate < 99.0%: do NOT cutover.
IF match_rate >= 99.9%: ramp 5% -> 25% -> 50% -> 100%.

### 3. Language/Framework Planning

**JS -> TS:**
Phase 1: tsconfig with allowJs:true, strict:false
Phase 2: Rename .js->.ts one file at a time (leaves first)
Phase 3: Enable strict mode incrementally

**REST -> GraphQL:**
Phase 1: GraphQL alongside REST (resolvers call services)
Phase 2: Migrate clients one feature at a time
Phase 3: Deprecate REST endpoints

**Monolith -> Microservices:**
Phase 0: Identify bounded contexts, add module boundaries
Phase 1: Extract easiest module as first service
Phase 2: Feature flag, shadow traffic, ramp

### 4. Zero-Downtime Data Migration
```
Phase 1 — Dual-write: write BOTH stores, old=source
Phase 2 — Backfill: batch historical data, rate-limited
  Track: migrated/total, verify integrity per batch
Phase 3 — Cutover: read from new, stop old writes
Phase 4 — Cleanup: remove old after 2-week stability
```
```bash
# Verify data integrity
psql -c "SELECT count(*) FROM old_table"
psql -c "SELECT count(*) FROM new_table"
# Row counts must match within 0.01%
```

### 5. Parallel Run Verification
```
Route traffic to BOTH systems.
Compare outputs automatically.
Target: > 99.9% match rate before cutover.
IF mismatch > 1%: categorize, fix top 3, re-run.
```

### 6. Rollback Planning
```
Triggers: error rate > 1.1x baseline for 5 min,
  p99 latency > threshold for 5 min,
  data inconsistency detected.
Steps: switch traffic back, stop dual-writes,
  reconcile data, notify stakeholders, post-mortem.
```

### 7. Iterative Protocol
```
FOR each component (fewest dependencies first):
  1. EXTRACT + BUILD new implementation
  2. WRITE/migrate tests
  3. DEPLOY behind feature flag, shadow traffic
  4. PARALLEL RUN: target > 99.9% match
  5. IF match < 99.0%: fix and re-run
  6. IF match >= 99.9%: ramp 5%->25%->50%->100%
  7. REMOVE old after 2-week stability
```


```bash
# Run and verify migrations
npm run migrate:status
python manage.py showmigrations
npx prisma migrate status
```

## Hard Rules
1. NEVER big-bang rewrite > 50K LOC.
2. EVERY step MUST have documented rollback plan.
3. NEVER migrate without tests (add characterization
   tests first if missing).
4. NEVER remove old system until new runs stable 2 weeks.
5. Feature flags control cutover (never deployment).

## TSV Logging
Append `.godmode/migration-results.tsv`:
```
timestamp	source	target	strategy	status	match_rate
```

## Keep/Discard
```
KEEP if: match > 99.9%, rollback tested,
  flags control cutover.
DISCARD if: match < 99%, no rollback,
  deployment-switched. Revert if error > 1.1x.
```

## Stop Conditions
```
STOP when FIRST of:
  - Match rate > 99.9% + rollback tested
  - Data integrity verified + old system kept 2 weeks
  - User requests stop
```

## Autonomous Operation
On failure: git reset --hard HEAD~1. Never pause.

## Error Recovery
| Failure | Action |
|--|--|
| Match < 99% | Categorize mismatches, fix top 3, re-run |
| Feature breaks | Flip flag back, add test before retry |
| Data integrity | Verify checksums, row counts, samples |
