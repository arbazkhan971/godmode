---
name: bench
description: Formal benchmark harness. Runs a metric command N times across 2-3 variants (git refs or state-prep shell commands), checks variance, computes delta vs. declared baseline, and emits a reproducible TSV plus a one-paragraph summary. Read-only to source. Inspired by caveman's 3-arm eval.
---

## Activate When
- `/godmode:bench`, "benchmark", "compare variants", "A/B metric"
- User has a metric and wants a statistically-honest comparison between 2-3 code states
- NOT for optimization loops — use `optimize` for that. `bench` measures, never modifies source.

## Inputs
Ask once, cache for the session:
- `metric_cmd` — shell command printing ONE number to stdout (lower-is-better or higher-is-better, user declares `direction`).
- `variants` — list of 2-3 entries. Each variant is a record:
  - `name` — short label (e.g. `main`, `terse_on`, `feature_branch`)
  - `prep` — EITHER a git ref (`git checkout <ref>`) OR an inline shell command that puts the repo into the desired state (e.g. `export GODMODE_TERSE=1`, `git checkout feature-branch`)
  - `teardown` — optional shell command to undo `prep` (default: `git checkout -` for refs, `unset VAR` for env)
- `baseline` — name of the variant all deltas are computed against. Must match one `variants[].name`.
- `N` — runs per variant. Default 5. Minimum 3. Maximum 20.
- `variance_threshold` — stdev/mean ratio that flags a variant noisy. Default 0.05 (5%).

## Workflow
1. Validate inputs — `metric_cmd` must emit a single number; `baseline` must match a variant; `N >= 3`.
2. Snapshot starting git state (`HEAD` sha, branch, dirty bit). Refuse to run if working tree is dirty.
3. FOR each variant in order:
   a. Run `prep`. Abort variant on non-zero exit, mark `prep_failed`.
   b. Run `metric_cmd` N times. Collect numbers into an array.
   c. Compute mean, median, stdev, cv = stdev/mean.
   d. IF cv > variance_threshold: retry the FULL N-run block up to 3 times (variance recovery).
   e. IF cv still > threshold after 3 retries: mark variant `measurement_error`, record best-effort numbers.
   f. Run `teardown`. Fail loud if teardown leaves repo dirty.
4. Restore starting git state exactly (same sha, same branch). Verify with `git rev-parse HEAD`.
5. Compute `delta_pct` for each variant vs. baseline: `(variant.median - baseline.median) / baseline.median * 100`.
6. Emit outputs (see Output Format).

## Math
```
mean   = sum(runs) / N
median = sorted(runs)[N//2]        # for even N, average of middle two
stdev  = sqrt(sum((x - mean)^2) / (N - 1))
cv     = stdev / mean
delta% = (variant.median - baseline.median) / baseline.median * 100
```
All computed with `awk` — no python, no bc, no external deps.

## Output Format
Print to stdout a markdown table:
```
| variant    | runs | mean    | median  | stdev  | delta%  | status   |
|------------|------|---------|---------|--------|---------|----------|
| main       |    5 | 124.40  | 124.00  |  2.10  |   0.00  | baseline |
| terse_on   |    5 |  98.60  |  99.00  |  1.80  | -20.16  | ok       |
| feature    |    5 | 131.20  | 130.00  | 12.40  |  +4.84  | noisy*   |
```

Append one row per variant to `.godmode/bench-results.tsv`:
```
timestamp	run_id	variant	N	mean	median	stdev	cv	delta_pct	status	metric_cmd	git_ref
```
`run_id` is a UUID or `date +%s` — groups all variants from a single invocation.

Write a one-paragraph summary to `.godmode/bench-summary.md`, overwriting any prior version:
```
# Bench <run_id> — <timestamp>
Ran `<metric_cmd>` N=<N> times across <k> variants. Baseline: <baseline>.
Best: <winner> at <median> (<delta>% vs baseline). Worst: <loser> at <median> (<delta>%).
Noisy: <list or "none">. All variants measured from clean HEAD <sha>. Reproduce: re-run
`/godmode:bench` with identical variants file.
```

## Hard Rules
1. READ-ONLY to the codebase. The only files this skill may write are `.godmode/bench-results.tsv` and `.godmode/bench-summary.md`. Touching any source file = abort + fail loud.
2. Refuse to run on a dirty working tree. `git status --porcelain` must be empty.
3. Restore the exact starting HEAD sha after the last variant. Verify and abort if mismatch.
4. Never skip the variance check. `cv > threshold` ALWAYS triggers retry, even if the delta looks conclusive.
5. Never fabricate numbers. If a run produces no number, record `NaN` and count it against N; never silently drop.
6. Commit the results TSV after every run — one commit per `run_id` with message `bench: <run_id> <k> variants`.
7. No external deps beyond `bash`, `awk`, `git`, and standard Unix utilities. No python, no jq, no node.
8. `metric_cmd` runs with `set -e; set -o pipefail`. Non-zero exit = failed run, not a zero measurement.

## Variance Recovery
```
FOR variant in variants:
    runs = collect(N)
    retries = 0
    WHILE cv(runs) > threshold AND retries < 3:
        runs = collect(N)           # full fresh block, NOT append
        retries += 1
    IF cv(runs) > threshold:
        status = "measurement_error"
    ELSE:
        status = "ok"
```
Each retry is a fresh N-run block; never mix runs from different retry attempts.

## Keep / Discard Discipline
```
KEEP a variant's measurement if:
  - N valid numeric samples collected
  - cv <= variance_threshold (possibly after retries)
  - prep and teardown both exited 0
  - git state restored cleanly between variants

DISCARD a variant's measurement if:
  - prep failed (record prep_failed, do NOT retry)
  - >3 retries still noisy (record measurement_error, keep best-effort row, mark unreliable)
  - metric_cmd produced NaN for >=N/2 runs
  - teardown left repo dirty (abort entire run, unsafe to continue)

On DISCARD of a whole run: git reset --hard to the snapshotted starting sha. Summary notes
the abort reason. TSV still gets partial rows with status=aborted.
```

## Stop Conditions
```
STOP when FIRST of:
  - all_measured: every variant has status in {ok, measurement_error, prep_failed}
  - variance_unrecoverable: >=ceil(k/2) variants are measurement_error (comparison is meaningless)
  - budget_exhausted: total metric_cmd invocations > N * k * 4 (N runs * k variants * 4 retries)
  - unsafe_state: teardown failed or HEAD drifted mid-run
On stop: always write summary.md and commit results.tsv, even on abort.
```

## Success Criteria
1. `bench-results.tsv` has exactly one row per variant in the run (k rows per `run_id`).
2. Every row has a `delta_pct` value (0.00 for the baseline row).
3. No variant is marked `measurement_error` unless cv truly exceeded threshold after 3 retries.
4. `bench-summary.md` names the winner, loser, baseline, and flags any noisy variants.
5. `git rev-parse HEAD` after the run matches the snapshotted starting sha.

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|--|--|
| Dirty working tree at start | Abort before first variant. Tell user to stash or commit. |
| `metric_cmd` non-numeric | Pipe through `tail -1 \| awk '{print $NF}'`. If still non-numeric, record NaN. |
| `prep` fails for a variant | Mark `prep_failed`, skip runs, continue to next variant. |
| Variance unrecoverable after 3 retries | Mark `measurement_error`, keep row, emit warning in summary. |
| HEAD drift mid-run | Abort. `git reset --hard <starting_sha>`. Refuse to emit comparison. |
| `teardown` leaves repo dirty | Abort entire run. Do not proceed to next variant. |

## TSV Schema
`.godmode/bench-results.tsv` is append-only. Header written on first create:
```
timestamp	run_id	variant	N	mean	median	stdev	cv	delta_pct	status	metric_cmd	git_ref
```
`status` is one of: `baseline`, `ok`, `measurement_error`, `prep_failed`, `aborted`.
Never rewrite history. One `run_id` groups k rows. Commit every run.
