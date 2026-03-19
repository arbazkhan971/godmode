# Results Logging Format

## Overview
Every optimization iteration produces a log entry. The log is stored in TSV (Tab-Separated Values) format for easy parsing, analysis, and import into spreadsheets.

## File Location
```
.godmode/optimize-results.tsv
```

## TSV Schema

### Header Row
```
iteration	timestamp	hypothesis	change_description	file_changed	baseline_value	measured_value	delta_pct	cumulative_delta_pct	verdict	guard_rails_passed	commit_sha	notes
```

### Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| `iteration` | integer | Sequential iteration number (1, 2, 3...) |
| `timestamp` | ISO 8601 | When the iteration completed (UTC) |
| `hypothesis` | string | Brief description of the theory being tested (quoted) |
| `change_description` | string | What was actually changed (quoted) |
| `file_changed` | string | Primary file modified |
| `baseline_value` | number | The metric value BEFORE this iteration's change |
| `measured_value` | number | The metric value AFTER this iteration's change (median of 3 runs) |
| `delta_pct` | number | Percentage change: `(measured - baseline) / baseline * 100` |
| `cumulative_delta_pct` | number | Total change from original baseline |
| `verdict` | enum | `KEEP`, `REVERT`, `REVERT_GUARD_RAIL`, `REVERT_NO_CHANGE` |
| `guard_rails_passed` | boolean | `true` if all guard rails passed, `false` if any failed |
| `commit_sha` | string | Git commit SHA of the change (or revert) |
| `notes` | string | Optional learning or observation (quoted) |

### Verdict Values

| Verdict | Meaning |
|---------|---------|
| `KEEP` | Metric improved, guard rails passed, change committed |
| `REVERT` | Metric regressed, change reverted |
| `REVERT_GUARD_RAIL` | Guard rails failed, change reverted without measuring |
| `REVERT_NO_CHANGE` | Metric unchanged (within 1% tolerance), change reverted |

### Example Log

```tsv
iteration	timestamp	hypothesis	change_description	file_changed	baseline_value	measured_value	delta_pct	cumulative_delta_pct	verdict	guard_rails_passed	commit_sha	notes
0	2024-01-15T10:20:00Z	"baseline"	"initial measurement"	-	847	847	0	0	BASELINE	true	9a8b7c6	"Starting optimization: reduce /api/products response time"
1	2024-01-15T10:23:00Z	"N+1 query in getUserPosts causes 47 individual queries"	"Add eager loading for posts relation"	src/services/product.ts	847	612	-27.7	-27.7	KEEP	true	abc1234	"Major win — single query now"
2	2024-01-15T10:31:00Z	"Unindexed WHERE clause on products.category_id"	"Add index on products.category_id"	migrations/002_add_index.sql	612	401	-34.5	-52.7	KEEP	true	def5678	"Index scan vs sequential scan"
3	2024-01-15T10:38:00Z	"JSON serialization is slow for large arrays"	"Switch to streaming JSON serializer"	src/controllers/product.ts	401	415	+3.5	-51.0	REVERT	true	ghi9012	"Streaming overhead > serialization savings at this data size"
4	2024-01-15T10:45:00Z	"DB connection pool too small for concurrent requests"	"Increase connection pool from 5 to 20"	src/config/database.ts	401	328	-18.2	-61.3	KEEP	true	jkl3456	""
5	2024-01-15T10:52:00Z	"Response includes unused fields"	"Add field selection to product query"	src/services/product.ts	328	312	-4.9	-63.2	KEEP	true	mno7890	"Minor win — less data over the wire"
6	2024-01-15T10:59:00Z	"No Redis cache for product listing"	"Add Redis cache with 60s TTL"	src/services/product.ts	312	310	-0.6	-63.4	REVERT_NO_CHANGE	true	pqr1234	"Cache overhead ≈ savings. Not worth the complexity."
7	2024-01-15T11:06:00Z	"Middleware chain runs 8 middlewares per request"	"Skip unnecessary middlewares for GET /products"	src/middleware/index.ts	312	-	-	-	REVERT_GUARD_RAIL	false	stu5678	"Skipping auth middleware caused 3 test failures"
8	2024-01-15T11:13:00Z	"Product images loaded separately"	"Batch image URL generation"	src/services/image.ts	312	287	-8.0	-66.1	KEEP	true	vwx9012	""
9	2024-01-15T11:20:00Z	"No gzip compression on responses"	"Enable gzip for responses > 1KB"	src/config/server.ts	287	198	-31.0	-76.6	KEEP	true	yza3456	"Huge win — 3x payload reduction"
```

## Summary Report Format

Generated at the end of an optimization run:

```
OPTIMIZATION SUMMARY
====================
Goal: Reduce /api/products response time
Metric: p95 response time (ms)
Started: 2024-01-15T10:20:00Z
Finished: 2024-01-15T11:20:00Z
Duration: 1h 0m

Results:
  Baseline:    847ms
  Final:       198ms
  Target:      < 200ms ✓ ACHIEVED
  Improvement: 76.6%

Iterations: 9 total
  Kept:        5 (55.6%)
  Reverted:    3 (33.3%)
  Guard fail:  1 (11.1%)

Top improvements (by impact):
  1. iteration 2: Add index on category_id        -34.5%
  2. iteration 9: Enable gzip compression          -31.0%
  3. iteration 1: Add eager loading                -27.7%
  4. iteration 4: Increase connection pool         -18.2%
  5. iteration 8: Batch image URL generation       -8.0%

Lessons learned (from reverts):
  - iteration 3: Streaming JSON not beneficial at current data sizes
  - iteration 6: Redis cache overhead ≈ savings for this query
  - iteration 7: Cannot skip auth middleware (test dependency)

Full log: .godmode/optimize-results.tsv
```

## Analysis Commands

The TSV format supports easy analysis:

```bash
# Count iterations by verdict
awk -F'\t' 'NR>1 {print $11}' .godmode/optimize-results.tsv | sort | uniq -c

# Find the biggest single improvement
awk -F'\t' 'NR>1 && $11=="KEEP" {print $8, $4}' .godmode/optimize-results.tsv | sort -n | head -1

# Calculate total improvement
awk -F'\t' 'END {print $9"%"}' .godmode/optimize-results.tsv

# List all reverted hypotheses (what didn't work)
awk -F'\t' 'NR>1 && $11~/REVERT/ {print $3}' .godmode/optimize-results.tsv

# Show timeline of metric values
awk -F'\t' 'NR>1 && $11!="REVERT_GUARD_RAIL" {print $1, $7}' .godmode/optimize-results.tsv
```
