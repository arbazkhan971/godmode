# TSV Schema Reference

All godmode iterative skills log structured data to `.godmode/*.tsv` files. These files are **append-only** -- they are never overwritten or truncated. Each run appends new rows, creating a complete audit trail across sessions.

All TSV files use literal tab characters (`\t`) as delimiters. No quoting conventions -- values must not contain tabs or newlines.

---

## Table of Contents

1. [optimize-results.tsv](#optimize-resultstsv)
2. [fix-log.tsv](#fix-logtsv)
3. [build-log.tsv](#build-logtsv)
4. [test-results.tsv](#test-resultstsv)
5. [debug-findings.tsv](#debug-findingstsv)
6. [security-findings.tsv](#security-findingstsv)
7. [ship-log.tsv](#ship-logtsv)
8. [session-log.tsv](#session-logtsv)
9. [review-log.tsv](#review-logtsv)
10. [think-log.tsv](#think-logtsv)
11. [predict-log.tsv](#predict-logtsv)
12. [scenario-log.tsv](#scenario-logtsv)
13. [plan-log.tsv](#plan-logtsv)
14. [verify-log.tsv](#verify-logtsv)
15. [Querying TSV Files](#querying-tsv-files)
16. [Importing into Spreadsheets](#importing-into-spreadsheets)

---

## optimize-results.tsv

**Path:** `.godmode/optimize-results.tsv`
**Written by:** `optimize` skill
**Appended:** Once per agent per round (up to 3 rows per round)

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `round` | integer | Round number (1-indexed, increments each loop iteration) |
| 2 | `agent` | integer | Agent number within the round (1, 2, or 3) |
| 3 | `change` | string | Brief description of the change the agent attempted |
| 4 | `metric_before` | number | Median of 3 metric measurements before the change |
| 5 | `metric_after` | number | Median of 3 metric measurements after the change |
| 6 | `status` | enum | `kept` or `discarded` |

### Example Row

```
3	2	replace linear scan with hash lookup in resolve()	142.5	98.3	kept
```

---

## fix-log.tsv

**Path:** `.godmode/fix-log.tsv`
**Written by:** `fix` skill
**Appended:** Once per fix attempt (kept or reverted)

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `iteration` | integer | Loop iteration number (1-indexed) |
| 2 | `error` | string | The error message or identifier being fixed |
| 3 | `file` | string | File path where the fix was applied |
| 4 | `fix_description` | string | Brief description of what the fix changed |
| 5 | `status` | enum | `kept` or `reverted` |

### Example Row

```
7	TypeError: Cannot read property 'id' of undefined	src/api/users.ts	add null check before accessing user.id	kept
```

---

## build-log.tsv

**Path:** `.godmode/build-log.tsv`
**Written by:** `build` skill
**Appended:** Once per task per round

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `round` | integer | Build round number (1-indexed) |
| 2 | `task_id` | string | Task identifier from `.godmode/plan.yaml` |
| 3 | `agent_time_ms` | integer | Wall-clock time the agent took in milliseconds |
| 4 | `status` | enum | `merged`, `reverted`, or `conflict` |

### Example Row

```
2	task-04	18320	merged
```

---

## test-results.tsv

**Path:** `.godmode/test-results.tsv`
**Written by:** `test` skill
**Appended:** Once per RED-GREEN-REFACTOR iteration

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `iteration` | integer | Loop iteration number (1-indexed) |
| 2 | `test_file` | string | Path to the test file written or modified |
| 3 | `lines_covered` | integer | Number of new source lines covered by this test |
| 4 | `coverage_before` | number | Coverage percentage before this iteration (e.g. `72.4`) |
| 5 | `coverage_after` | number | Coverage percentage after this iteration (e.g. `74.1`) |
| 6 | `delta` | number | Change in coverage percentage (e.g. `1.7`) |

### Example Row

```
5	tests/services/auth.test.ts	14	72.4	74.1	1.7
```

---

## debug-findings.tsv

**Path:** `.godmode/debug-findings.tsv`
**Written by:** `debug` skill
**Appended:** Once per bug investigated

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `iteration` | integer | Loop iteration number (1-indexed) |
| 2 | `symptom` | string | Observable symptom (error message, wrong output, crash) |
| 3 | `root_cause` | string | Proven root cause after investigation |
| 4 | `file_line` | string | Location of the bug, formatted as `file:line` |
| 5 | `fix_commit` | string | Git commit SHA of the fix (short hash), or empty if skipped |
| 6 | `status` | enum | `fixed` or `skipped` |

### Example Row

```
3	test_checkout fails with 500	race condition: cart cleared before total computed	src/checkout/cart.py:87	a3f9c12	fixed
```

---

## security-findings.tsv

**Path:** `.godmode/security-findings.tsv`
**Written by:** `secure` skill
**Appended:** Once per finding per category/persona combination

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `iteration` | integer | Loop iteration number (1-indexed) |
| 2 | `category` | string | OWASP Top 10 category or STRIDE category (e.g. `Injection`, `Spoofing`) |
| 3 | `persona` | string | One of: `External`, `Insider`, `Supply Chain`, `Infra` |
| 4 | `finding` | string | Description of the vulnerability found |
| 5 | `severity` | enum | `Critical`, `High`, `Med`, or `Low` |
| 6 | `file_line` | string | Location, formatted as `file:line` |
| 7 | `status` | enum | `open` or `fixed` |

### Example Row

```
2	Injection	External	SQL injection in search query via unsanitized user input	High	src/api/search.ts:34	open
```

---

## ship-log.tsv

**Path:** `.godmode/ship-log.tsv`
**Written by:** `ship` skill
**Appended:** Once per ship action

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp of the ship action (e.g. `2026-03-20T14:30:00Z`) |
| 2 | `type` | string | Ship type: `PR`, `deploy`, or `release` |
| 3 | `commit_sha` | string | Git commit SHA (short or full) that was shipped |
| 4 | `outcome` | enum | `shipped`, `rolled-back`, or `failed` |
| 5 | `url` | string | URL of the PR, release, or deployment endpoint |

### Example Row

```
2026-03-20T14:30:00Z	PR	e4b2a91	shipped	https://github.com/org/repo/pull/42
```

---

## session-log.tsv

**Path:** `.godmode/session-log.tsv`
**Written by:** `godmode` orchestrator and `finish` skill
**Appended:** Once per skill session completion

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp when the skill session ended |
| 2 | `skill` | string | Name of the skill that ran (e.g. `optimize`, `fix`, `build`) |
| 3 | `iters` | integer | Number of iterations the skill executed |
| 4 | `kept` | integer | Number of changes/results kept |
| 5 | `discarded` | integer | Number of changes/results discarded or reverted |
| 6 | `outcome` | string | Free-text summary of the session result |

### Example Row

```
2026-03-20T15:45:00Z	optimize	12	4	8	142ms to 98ms (31% improvement)
```

---

## review-log.tsv

**Path:** `.godmode/review-log.tsv`
**Written by:** `review` skill
**Appended:** Once per finding from the 4-agent review

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp of the review |
| 2 | `scope` | string | Scope of review (branch name, directory, or file glob) |
| 3 | `category` | string | Review category: `correctness`, `security`, `performance`, or `style` |
| 4 | `severity` | enum | `MUST-FIX`, `SHOULD-FIX`, or `NIT` |
| 5 | `file_line` | string | Location, formatted as `file:line` |
| 6 | `description` | string | Description of the finding and suggested fix |
| 7 | `status` | enum | `open`, `auto-fixed`, or `deferred` |

### Example Row

```
2026-03-20T10:00:00Z	feature/auth	security	MUST-FIX	src/auth/login.ts:55	password compared with == instead of constant-time compare	open
```

---

## think-log.tsv

**Path:** `.godmode/think-log.tsv`
**Written by:** `think` skill
**Appended:** Once per design session

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp of the design session |
| 2 | `feature` | string | Name or short description of the feature being designed |
| 3 | `approaches_considered` | integer | Number of approaches generated (typically 2-3) |
| 4 | `chosen_approach` | string | Name or brief description of the recommended approach |
| 5 | `files_to_modify` | integer | Number of existing files the approach will modify |
| 6 | `files_to_create` | integer | Number of new files the approach will create |
| 7 | `spec_lines` | integer | Line count of the generated `.godmode/spec.md` |

### Example Row

```
2026-03-20T09:00:00Z	user authentication	3	JWT with refresh tokens	8	4	62
```

---

## predict-log.tsv

**Path:** `.godmode/predict-log.tsv`
**Written by:** `predict` skill
**Appended:** Once per persona per evaluation (typically 5 rows per invocation)

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp of the evaluation |
| 2 | `feature` | string | Feature or proposal being evaluated |
| 3 | `persona` | string | One of: `Backend Architect`, `Frontend Lead`, `SRE`, `Security Researcher`, `Product Manager` |
| 4 | `verdict` | enum | `YES`, `REVISE`, or `NO` |
| 5 | `confidence` | integer | Confidence score, 1-10 |
| 6 | `risk_summary` | string | Top risk identified by this persona |
| 7 | `mitigation` | string | Concrete change to mitigate the risk |
| 8 | `gate_result` | enum | `PROCEED`, `REVISE`, or `RETHINK` (same for all personas in one session) |

### Example Row

```
2026-03-20T09:30:00Z	user authentication	SRE	REVISE	6	no rate limiting on login endpoint	add express-rate-limit middleware to /api/auth/*	REVISE
```

---

## scenario-log.tsv

**Path:** `.godmode/scenario-log.tsv`
**Written by:** `scenario` skill
**Appended:** Once per scenario explored (multiple rows per invocation, covering 12 dimensions)

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp of the scenario analysis |
| 2 | `feature` | string | Feature being analyzed |
| 3 | `dimension` | string | One of the 12 dimensions (e.g. `Invalid Input`, `Concurrency`, `Network`, `Scale`) |
| 4 | `scenario` | string | Description of the specific edge case or failure mode |
| 5 | `likelihood` | integer | Likelihood score, 1-5 |
| 6 | `impact` | integer | Impact score, 1-5 |
| 7 | `score` | integer | Computed score: likelihood * impact (1-25) |
| 8 | `severity` | enum | `CRITICAL` (>=20), `HIGH` (12-19), `MEDIUM` (6-11), or `LOW` (<=5) |
| 9 | `test_file` | string | Path to generated test skeleton, or empty if severity < HIGH |
| 10 | `code_ref` | string | Code reference, formatted as `file:line` |

### Example Row

```
2026-03-20T09:15:00Z	checkout flow	Concurrency	two users purchase last item simultaneously	4	5	20	CRITICAL	tests/scenarios/checkout.scenario.test.ts	src/checkout/inventory.ts:44
```

---

## plan-log.tsv

**Path:** `.godmode/plan-log.tsv`
**Written by:** `plan` skill
**Appended:** Once per planning session

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp of the planning session |
| 2 | `feature` | string | Feature being decomposed into tasks |
| 3 | `total_tasks` | integer | Number of tasks in the plan |
| 4 | `total_rounds` | integer | Number of execution rounds (based on dependency graph) |
| 5 | `total_files` | integer | Number of files touched across all tasks |
| 6 | `plan_path` | string | Path to the generated plan file (typically `.godmode/plan.yaml`) |

### Example Row

```
2026-03-20T09:10:00Z	user authentication	8	3	12	.godmode/plan.yaml
```

---

## verify-log.tsv

**Path:** `.godmode/verify-log.tsv`
**Written by:** `verify` skill
**Appended:** Once per claim verified

### Columns

| N | Col | Type | Use |
|--|--|--|--|
| 1 | `timestamp` | ISO-8601 | UTC timestamp of the verification |
| 2 | `claim` | string | The claim being verified (one sentence) |
| 3 | `command` | string | Shell command that was executed |
| 4 | `expected` | string | Expected output or condition |
| 5 | `actual` | string | Actual output or result observed |
| 6 | `verdict` | enum | `PASS` or `FAIL` |
| 7 | `evidence_file` | string | Path to captured output (e.g. `/tmp/verify-output.txt`) |

### Example Row

```
2026-03-20T16:00:00Z	all tests pass	npm test 2>&1	exit 0	exit 0, 48/48 passed	PASS	/tmp/verify-output.txt
```

---

## Querying TSV Files

### View a TSV file with aligned columns

```bash
column -t -s $'\t' .godmode/optimize-results.tsv
```

### Extract specific columns (e.g., round and status from optimize)

```bash
cut -f1,6 .godmode/optimize-results.tsv
```

### Filter rows by value (e.g., only "kept" results)

```bash
awk -F'\t' '$6 == "kept"' .godmode/optimize-results.tsv
```

### Sort by a numeric column (e.g., sort by metric_after ascending)

```bash
sort -t$'\t' -k5 -n .godmode/optimize-results.tsv
```

### Count occurrences (e.g., kept vs discarded in optimize)

```bash
awk -F'\t' '{print $6}' .godmode/optimize-results.tsv | sort | uniq -c
```

### Get the last N rows (e.g., last 10 entries)

```bash
tail -10 .godmode/fix-log.tsv
```

### Filter by date range (for files with ISO-8601 timestamps in column 1)

```bash
awk -F'\t' '$1 >= "2026-03-01" && $1 < "2026-04-01"' .godmode/ship-log.tsv
```

### Cross-file analysis: find all CRITICAL security findings that are still open

```bash
awk -F'\t' '$5 == "Critical" && $7 == "open"' .godmode/security-findings.tsv
```

### Show all sessions for a specific skill

```bash
awk -F'\t' '$2 == "optimize"' .godmode/session-log.tsv
```

### Compute average confidence from predict-log

```bash
awk -F'\t' '{sum += $5; n++} END {print sum/n}' .godmode/predict-log.tsv
```

---

## Importing into Spreadsheets

### Excel

1. Open Excel.
2. Go to **Data** > **From Text/CSV** (or **Get Data** > **From File** > **From Text/CSV**).
3. Select the `.tsv` file.
4. Set delimiter to **Tab**.
5. Click **Load**.

### Google Sheets

1. Open a new Google Sheet.
2. Go to **File** > **Import**.
3. Upload the `.tsv` file.
4. Set separator type to **Tab**.
5. Click **Import data**.

Alternatively, paste TSV content directly:

1. Copy the contents of the `.tsv` file.
2. Paste into cell A1 in Google Sheets.
3. Google Sheets auto-detects tab delimiters and splits into columns.

### Command-line CSV conversion (for tools expecting CSV)

```bash
tr '\t' ',' < .godmode/optimize-results.tsv > optimize-results.csv
```

> **Note:** This simple conversion does not handle commas within field values. For production use, prefer `csvformat` from the `csvkit` package:
> ```bash
> csvformat -t .godmode/optimize-results.tsv > optimize-results.csv
> ```

---

## Append-Only Guarantee

All `.godmode/*.tsv` files are **append-only**. Skills never overwrite or truncate these files. This guarantees:

- **Complete history** -- every iteration, finding, and decision is preserved across sessions.
- **Safe concurrency** -- multiple skills or agents can append without coordination conflicts.
- **Auditability** -- you can trace exactly what happened, when, and in what order.

To reset a log (e.g., starting a fresh optimization campaign), manually delete or archive the file:

```bash
mv .godmode/optimize-results.tsv .godmode/optimize-results.tsv.bak
```
