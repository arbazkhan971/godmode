# Benchmark Task Corpus Index (M3-B0)

Lead-owned manifest. Implementers report status; only the fleet lead edits this file.

## Frozen contracts (B1 runner must obey)

- **Workspace copylist** (exact): `README.md`, `metric.sh`, `starter/` (directory preserved at workspace root). Everything else in a task dir (`solution/`, `SOLUTION.md`, `expected_effort`, `VERIFICATION.tsv`, this INDEX) is repo-side audit material and is NEVER copied into a run workspace.
- **Task ID regex**: `^(perf|bug|test|feat|sec|refac)-[0-9]{2}$`.
- **metric.sh contract**: invoked as `bash metric.sh` with CWD = workspace root; deterministic; offline; ≤30 s total; immutable during a run (runner SHA256-checksums before/after).
- **expected_effort rubric** (maps to the 10-min per-run budget): `S` ≈ ≤3 min for a competent agent, `M` ≈ 5–8 min, `L` ≈ near the 10-min cap.
- **results.tsv schema** (created in B1, frozen now): `task_id arm run# parent_run start_ts end_ts exit_code metric_pass duration_s notes` (tab-separated, ISO-8601 UTC timestamps).

## Corpus (30 tasks)

| id | category | language | effort | title | status |
|---|---|---|---|---|---|
| perf-01 | performance-optimization | python3 | S | Word-frequency counter is too slow | EMPTY |
| perf-02 | performance-optimization | python3 | M | Record join takes quadratic time | EMPTY |
| perf-03 | performance-optimization | node | S | Tag intersection is too slow | EMPTY |
| perf-04 | performance-optimization | node | L | Config re-parsed for every item | EMPTY |
| perf-05 | performance-optimization | bash | M | Per-line grep sweep is too slow | EMPTY |
| bug-01 | bug-fixing | python3 | S | Log parser drops the final entry | EMPTY |
| bug-02 | bug-fixing | python3 | M | Cart totals leak between orders | EMPTY |
| bug-03 | bug-fixing | node | S | Leaderboard sorts scores as text | EMPTY |
| bug-04 | bug-fixing | node | L | Uploader reports completion too early | EMPTY |
| bug-05 | bug-fixing | bash | S | Backup script mangles paths with spaces | EMPTY |
| test-01 | test-writing | python3 | M | Write tests for the CSV row parser | EMPTY |
| test-02 | test-writing | python3 | M | Write tests for the date-range calculator | EMPTY |
| test-03 | test-writing | node | L | Write tests for the markup tokenizer | EMPTY |
| test-04 | test-writing | node | M | Write tests for the double-ended queue | EMPTY |
| test-05 | test-writing | bash | M | Write a smoke-test suite for the archiver CLI | EMPTY |
| feat-01 | feature-implementation | python3 | S | Add a JSON output mode | EMPTY |
| feat-02 | feature-implementation | python3 | M | Add pagination options | EMPTY |
| feat-03 | feature-implementation | node | S | Add reverse ordering | EMPTY |
| feat-04 | feature-implementation | node | M | Add a minimum-count filter | EMPTY |
| feat-05 | feature-implementation | bash | S | Add a dry-run mode | EMPTY |
| sec-01 | security-hardening | python3 | S | Block path traversal in the file server | EMPTY |
| sec-02 | security-hardening | python3 | M | Stop shell injection in the thumbnail command | EMPTY |
| sec-03 | security-hardening | node | S | Fix regex denial of service | EMPTY |
| sec-04 | security-hardening | node | M | Escape HTML in the template renderer | EMPTY |
| sec-05 | security-hardening | bash | L | Sanitize eval in the log filter | EMPTY |
| refac-01 | refactoring | python3 | M | Extract the shared validation helper | EMPTY |
| refac-02 | refactoring | python3 | L | Split the god-function | EMPTY |
| refac-03 | refactoring | node | M | Unify the record-loading duplication | EMPTY |
| refac-04 | refactoring | node | L | Remove the dead feature-flag branches | EMPTY |
| refac-05 | refactoring | bash | M | Factor out the repeated archive steps | EMPTY |

Status legend: `EMPTY` → `DONE` (implementer shipped + self-verified) → `VERIFIED` (independent gate re-derivation + lead final loop).
