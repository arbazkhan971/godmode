# Example: Building an API Feature End-to-End

This example shows the full Godmode workflow for adding a search endpoint to a REST API.

## Context
- **Project:** E-commerce API (Express.js + PostgreSQL)
- **Feature:** Full-text search for products
- **Goal:** Ship a performant, secure search endpoint

## Session Transcript

### Phase 1: Think

```
> /godmode:think I need to add product search to our API. Users should be
  able to search by name, description, and category.

Godmode: Researching codebase...

CODEBASE CONTEXT:
- Express.js REST API with TypeScript
- PostgreSQL via Prisma ORM
- Existing pattern: controllers in src/controllers/, services in src/services/
- Existing search: none
- Tests: Jest + supertest

One question: Do you need fuzzy matching (typo-tolerant) or exact keyword matching?

> Fuzzy matching would be great, but I'd settle for keyword matching to start.

Godmode: Here are three approaches...

Approach A: PostgreSQL Full-Text Search (pg_trgm + tsvector)
Approach B: Elasticsearch as a dedicated search service
Approach C: LIKE queries with pg_trgm extension for fuzzy matching

[comparison matrix shown]

I'd recommend Approach A — it uses PostgreSQL features you already have,
requires no new infrastructure, and supports fuzzy matching via pg_trgm.

> Let's go with A.

Godmode: Writing spec...
Saved: docs/specs/product-search.md
Commit: "spec: product-search — PostgreSQL full-text search with tsvector"
```

### Phase 2: Plan

```
> /godmode:plan

Godmode: Reading spec... Researching codebase...

IMPLEMENTATION PLAN: 10 tasks in 3 phases

Phase 1: Foundation (Tasks 1-3)
  Task 1: Add search configuration to config.ts
  Task 2: Create search vector migration
  Task 3: Create search service interface

Phase 2: Core (Tasks 4-7)
  Task 4: Implement search service with tsvector query
  Task 5: Create search controller
  Task 6: Add search route with validation
  Task 7: Add pagination to search results

Phase 3: Polish (Tasks 8-10)
  Task 8: Add search highlighting
  Task 9: Add search analytics logging
  Task 10: Add rate limiting to search endpoint

Saved: docs/plans/product-search-plan.md
Branch: feat/product-search
```

### Phase 3: Build

```
> /godmode:build

Godmode: Starting Phase 1...

Task 1: RED — Writing test for search config...
  ✓ Test fails (no config yet)
Task 1: GREEN — Adding searchConfig to config.ts...
  ✓ Test passes
Task 1: COMMIT: "test(red): search config" + "feat: add search config"

Task 2: RED — Writing test for migration...
[continues through all 10 tasks]

Phase 2 review:
✓ Tests: 12 new, all passing
✓ Lint: clean
✓ Coverage: 89%
✓ Code review: APPROVED (8.2/10)

BUILD COMPLETE: 10 tasks, 24 new tests, all passing.
```

### Phase 4: Optimize

```
> /godmode:optimize --goal "search response time" \
    --verify "curl -s -o /dev/null -w '%{time_total}' 'http://localhost:3000/api/products/search?q=test'" \
    --target "< 0.1"

Baseline: 342ms

Iteration 1: Add GIN index on search vector → 342ms → 89ms (-74%) KEEP
Iteration 2: Add query result caching (60s TTL) → 89ms → 23ms (-74%) KEEP
Iteration 3: Precompute tsvector on insert → 23ms → 21ms (-9%) KEEP
Iteration 4: Use websearch_to_tsquery instead of plainto_tsquery → 21ms → 22ms (+5%) REVERT

OPTIMIZATION COMPLETE: 342ms → 21ms (93.9% improvement) ✓ TARGET MET
```

### Phase 5: Secure

```
> /godmode:secure

SECURITY AUDIT:
✓ STRIDE: S✓ T✓ R✓ I✓ D✓ E✓
✓ OWASP: All checks pass

FINDING 1: Search query not sanitized for SQL special characters
Severity: MEDIUM (parameterized query prevents injection, but % and _ in
LIKE fallback could cause unexpected results)
Fix: Added input sanitization for search query

Verdict: CONDITIONAL PASS (1 MEDIUM finding, fixed)
```

### Phase 6: Ship

```
> /godmode:ship --pr

PRE-SHIP: ✓ All 66 tests passing, lint clean, security audit passed
PR #47 created: "Product search: PostgreSQL full-text search with tsvector"
CI: ✓ All checks passing
```

## Results
- **Time spent:** ~45 minutes total
- **Code:** 342 lines across 8 files
- **Tests:** 24 new tests
- **Performance:** 342ms → 21ms (93.9% improvement)
- **Security:** Audited, 1 finding fixed
