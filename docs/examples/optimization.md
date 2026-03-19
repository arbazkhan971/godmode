# Example: Autonomous Performance Optimization

This example shows Godmode's autonomous optimization loop reducing a slow API endpoint's response time by 85%.

## Context
- **Project:** Content management API (Python/FastAPI + PostgreSQL)
- **Problem:** The `/api/articles` endpoint takes 2.4 seconds at p95
- **Target:** Under 400ms

## Session Transcript

### Setup

```
> /godmode:optimize \
    --goal "reduce /api/articles response time" \
    --verify "curl -s -o /dev/null -w '%{time_total}' http://localhost:8000/api/articles?limit=50 | awk '{printf \"%.0f\", \$1*1000}'" \
    --target "< 400"

Godmode: Setting up optimization loop...

Measuring baseline (3 runs)...
Run 1: 2412ms
Run 2: 2387ms
Run 3: 2445ms
Baseline: 2412ms (median)

Target: < 400ms
Gap: 2012ms (83% improvement needed)

Guard rails:
✓ Tests: pytest → 89 passing
✓ Lint: ruff → clean
```

### Iteration 1: N+1 Query

```
ITERATION 1:
Hypothesis: The articles query executes 51 SQL queries per request (1 for articles
+ 1 per article for author data). This N+1 pattern is the primary bottleneck.
Change: Add eager loading with joinedload() for the author relationship.
File: app/services/article_service.py

[modifies code, commits]

Guard rails: ✓ tests pass, ✓ lint clean
Measurement: 2412ms → 1104ms → 1089ms → 1098ms
Median: 1098ms (from 2412ms, -54.5%)
Verdict: KEEP ✓
Cumulative: -54.5%

Learning: N+1 eliminated. 51 queries → 1 query with JOIN.
```

### Iteration 2: Missing Index

```
ITERATION 2:
Hypothesis: The articles query sorts by published_date DESC but there's no index
on this column, causing a sequential scan on 500K rows.
Change: Add index on articles.published_date.
File: migrations/versions/add_published_date_index.py

[creates migration, runs it, commits]

Guard rails: ✓ tests pass, ✓ lint clean
Measurement: 1098ms → 612ms → 598ms → 605ms
Median: 605ms (from 1098ms, -44.9%)
Verdict: KEEP ✓
Cumulative: -74.9%

Learning: Index scan now used. Query plan confirms index-only scan.
```

### Iteration 3: Over-Fetching Columns

```
ITERATION 3:
Hypothesis: The query SELECTs all 23 columns from the articles table, but the
list endpoint only needs 8 (id, title, slug, excerpt, author_name, published_date,
category, thumbnail_url). The article body (avg 15KB) is fetched but not used.
Change: Add explicit column selection to the list query.
File: app/services/article_service.py

[modifies code, commits]

Guard rails: ✓ tests pass, ✓ lint clean
Measurement: 605ms → 412ms → 398ms → 405ms
Median: 405ms (from 605ms, -33.1%)
Verdict: KEEP ✓
Cumulative: -83.2%

Learning: 15KB per row × 50 rows = 750KB saved from database transfer.
```

### Iteration 4: Response Compression

```
ITERATION 4:
Hypothesis: API response for 50 articles is ~120KB uncompressed. Enabling gzip
should reduce transfer time.
Change: Add GZipMiddleware to FastAPI.
File: app/main.py

[modifies code, commits]

Guard rails: ✓ tests pass, ✓ lint clean
Measurement: 405ms → 387ms → 391ms → 382ms
Median: 387ms (from 405ms, -4.4%)
Verdict: KEEP ✓
Cumulative: -84.0%

Learning: Modest improvement. Response compresses from 120KB to 18KB.
Target nearly reached (387ms, target 400ms). ✓
```

### Iteration 5: Connection Pool

```
ITERATION 5:
Hypothesis: Connection pool size is 5 (default). Under concurrent load, requests
queue for connections. Increasing to 20 might improve p95.
Change: Increase pool_size to 20 in database configuration.
File: app/config/database.py

[modifies code, commits]

Guard rails: ✓ tests pass, ✓ lint clean
Measurement: 387ms → 395ms → 401ms → 398ms
Median: 398ms (from 387ms, +2.8%)
Verdict: REVERT

Learning: Under single-client testing (our verify command), pool size doesn't
matter. This would help under concurrent load but doesn't affect our single-
request measurement. Not useful for this metric/methodology.
```

### Iteration 6: Query Result Caching

```
ITERATION 6:
Hypothesis: The articles list is read-heavy and changes infrequently. A 30-second
Redis cache would eliminate database hits for repeated requests.
Change: Add Redis cache decorator to list_articles().
File: app/services/article_service.py

[modifies code, commits]

Guard rails: ✗ TEST FAILURE — "test_article_creation_appears_in_list" fails
because newly created article doesn't appear when cache is warm.
Verdict: REVERT (guard rail failure)

Learning: Cache invalidation needed. Simple TTL cache breaks the "create then
list" test. Would need cache invalidation on write, which adds complexity.
Skipping for now.
```

### Iteration 7: Pagination Optimization

```
ITERATION 7:
Hypothesis: Using OFFSET-based pagination. For later pages, PostgreSQL still
scans all rows up to the offset. Switching to cursor-based (keyset) pagination
would make all pages equally fast.
Change: Replace OFFSET with WHERE published_date < :cursor.
File: app/services/article_service.py

[modifies code, commits]

Guard rails: ✓ tests pass, ✓ lint clean
Measurement: 387ms → 342ms → 351ms → 348ms
Median: 348ms (from 387ms, -10.1%)
Verdict: KEEP ✓
Cumulative: -85.6%

Learning: Keyset pagination removes OFFSET scan cost. Bigger impact on
later pages, modest improvement on page 1.
```

### Summary

```
OPTIMIZATION COMPLETE ✓

Goal: Reduce /api/articles response time
Target: < 400ms

Results:
  Baseline:    2412ms
  Final:       348ms
  Target:      < 400ms ✓ ACHIEVED
  Improvement: 85.6%

Iterations: 7 total
  Kept:        5 improvements (71.4%)
  Reverted:    2 experiments (28.6%)

Top improvements by impact:
  1. Eliminate N+1 query (eager loading)         -54.5%
  2. Add index on published_date                 -44.9%
  3. Select only needed columns                  -33.1%
  4. Cursor-based pagination                     -10.1%
  5. Response gzip compression                   -4.4%

Reverted experiments:
  - Connection pool increase: No improvement under single-client testing
  - Redis caching: Broke create-then-list test (needs invalidation logic)

Full log: .godmode/optimize-results.tsv
```

## Key Takeaways

1. **The biggest wins came first.** N+1 fix and index creation delivered 75% of the improvement.
2. **Not everything works.** 2 of 7 iterations were reverted, and that's normal (71% keep rate).
3. **Guard rails caught a real bug.** The caching attempt would have shipped a broken feature without test enforcement.
4. **Mechanical verification prevented false claims.** The connection pool change "should" have helped but didn't. Measuring proved it.
5. **Total time:** 25 minutes of autonomous operation for an 85.6% improvement.
