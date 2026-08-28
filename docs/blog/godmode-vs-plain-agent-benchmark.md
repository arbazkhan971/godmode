# Godmode vs a Plain Agent: What 30 Measured Tasks Showed

> We ran the same agent twice -- once with the godmode skill library installed, once with
> nothing installed -- same model, same prompt, 30 tasks, 2 scored runs per task per arm.
> The plain arm was faster on the median run and faster on most tasks. Every table from the
> frozen results follows, including the ones that cut against us.

---

## TL;DR

Same agent (pi), same model (zai/glm-5.3), same prompt, 30 tasks on 2026-08-28. Labeled by level: godmode passed 60 of 60 scored runs, which is 30 of 30 tasks; plain passed 58 of 60 scored runs, which is 29 of 30 tasks. The entire task-level difference is one task, sec-05, and it turns on the 600-second cap -- at 30 tasks with 2 runs per arm that is not distinguishable from ordinary run-to-run variation.

Speed favored plain: median scored run 37.0 s vs 41.0 s, and plain was faster on the per-task mid comparison on 20/30 tasks. Where godmode leaned ahead: test writing (median 83.0 s vs 89.5 s, mean 82.4 s vs 135.0 s, max 127.0 s vs 372.0 s) and sec-05 itself (415.0 s and 405.0 s against two 600.0 s censored failures).

Two disclosures up front: the 48 verify runs re-ran godmode passes only, across 12 tasks -- plain passes were never re-verified -- and keep/revert telemetry was never instrumented. The verbatim notes sit in Overall results below.

---

## Methodology

**The arms.** Plain is pi with no skills installed; godmode is the same pi, the same model, the same prompt, with the godmode skill library available. Both arms saw this exact task prompt, quoted in full:

```text
Make bash metric.sh exit 0. Do not modify metric.sh.
```

**The tasks.** 30 tasks across 6 categories (5 tasks each): performance, bug fixing, test writing, feature implementation, security hardening, refactoring. Each task is a starter codebase under 200 lines plus a `metric.sh` that grades the workspace mechanically. The task solutions are published in the repo for audit: [bench/tasks/](../../bench/tasks/).

**Runs.** Every run got its own isolated temp workspace and a 600-second cap; durations are agent wall-clock. `metric.sh` was checksummed before and after each run, so a run that edited its own metric could not count as a pass. The scored farm logged 2 scored runs per task per arm -- 60 scored runs per arm, 120 scored rows -- and the frozen results file holds 168 rows: 120 scored + 48 verify. All runs ran on one machine on 2026-08-28 across 4 parallel lanes.

**Censoring.** The results file records 3 exit-124 rows -- runs killed at the cap -- and the analyze output carries this footnote, pasted verbatim:

† exit-124 durations are right-censored at the 600s cap — recorded value is a lower bound; means including them are biased downward for timeouts.

One godmode pass is a censored pass: perf-05 run 2 exited 124 with duration 601.0 recorded at the cap, and the metric was then checked against the final workspace state and passed. The 60/60 run-level count includes it.

**Reading the numbers.** Medians and means are run-level over all scored runs per arm. The per-task Mid column is the midpoint of the 2 runs, per the footnotes.

---

## Overall results

| Arm | Runs | Passes | Success | Median s | Mean s | Mean excl C-124 s | Max s | C-124 |
|---|---|---|---|---|---|---|---|---|
| plain | 60 | 58 | 96.7% | 37.0 | 73.3 | 55.1 | 600.0† | 2 |
| godmode | 60 | 60 | 100.0% | 41.0 | 68.6 | 59.6 | 601.0† | 1 |

Medians and means are run-level over all scored runs per arm.

Run level: plain passed 58 of 60 scored runs, godmode 60 of 60. Task level: plain fully passed 29 of 30 tasks, godmode 30 of 30. Same rows, different levels -- do not mix them unlabeled. The gap at either level is the same single task, sec-05. Plain leads the median (37.0 vs 41.0); the mean including censored rows favors godmode (68.6 vs 73.3) while the mean excluding them favors plain (55.1 vs 59.6) -- with 3 censored rows in play, read both columns.

Notes from the frozen output, verbatim:

- keep/revert: n/a — not instrumented (no TSV column; logs contain only stray mentions; any count would be fabricated)
- model:zai/glm-5.3 — 168 rows
- 3 exit-124 rows recorded at the 600s cap
- per-task mid comparison: plain faster on 20/30, godmode faster on 10/30 (ties on 0/30)

Footnotes, verbatim:

† exit-124 durations are right-censored at the 600s cap — recorded value is a lower bound; means including them are biased downward for timeouts.
mid = median of 2 runs = midpoint of the two values.

---

## Category results

Six categories, 5 tasks each; each table below is that category's rows from the frozen per-category table, copied verbatim.

### Performance (perf)

| Category | Arm | Runs | Passes | Success | Median s | Mean s | Mean excl C-124 s | Max s | C-124 |
|---|---|---|---|---|---|---|---|---|---|
| perf | plain | 10 | 10 | 100.0% | 33.5 | 53.3 | 53.3 | 167.0 | 0 |
| perf | godmode | 10 | 10 | 100.0% | 35.0 | 98.7 | 42.9 | 601.0† | 1 |

Medians are close (33.5 vs 35.0); the means flip with censoring -- plain leads including the censored row (53.3 vs 98.7), godmode leads excluding it (53.3 vs 42.9). The censored row is perf-05 run 2.

### Bug fixing (bug)

| Category | Arm | Runs | Passes | Success | Median s | Mean s | Mean excl C-124 s | Max s | C-124 |
|---|---|---|---|---|---|---|---|---|---|
| bug | plain | 10 | 10 | 100.0% | 29.5 | 32.2 | 32.2 | 44.0 | 0 |
| bug | godmode | 10 | 10 | 100.0% | 34.0 | 34.4 | 34.4 | 54.0 | 0 |

All passes both arms; plain faster at the median (29.5 vs 34.0) and the mean (32.2 vs 34.4).

### Test writing (test)

| Category | Arm | Runs | Passes | Success | Median s | Mean s | Mean excl C-124 s | Max s | C-124 |
|---|---|---|---|---|---|---|---|---|---|
| test | plain | 10 | 10 | 100.0% | 89.5 | 135.0 | 135.0 | 372.0 | 0 |
| test | godmode | 10 | 10 | 100.0% | 83.0 | 82.4 | 82.4 | 127.0 | 0 |

The clearest godmode-leaning category, and the only one where godmode leads on median, mean, and max together. Details under Where godmode won.

### Feature implementation (feat)

| Category | Arm | Runs | Passes | Success | Median s | Mean s | Mean excl C-124 s | Max s | C-124 |
|---|---|---|---|---|---|---|---|---|---|
| feat | plain | 10 | 10 | 100.0% | 30.0 | 31.6 | 31.6 | 41.0 | 0 |
| feat | godmode | 10 | 10 | 100.0% | 34.0 | 34.9 | 34.9 | 45.0 | 0 |

### Security hardening (sec)

| Category | Arm | Runs | Passes | Success | Median s | Mean s | Mean excl C-124 s | Max s | C-124 |
|---|---|---|---|---|---|---|---|---|---|
| sec | plain | 10 | 8 | 80.0% | 43.0 | 151.7 | 39.6 | 600.0† | 2 |
| sec | godmode | 10 | 10 | 100.0% | 48.0 | 119.6 | 119.6 | 415.0 | 0 |

The only category with a pass-rate gap: plain 8 passes of 10 runs (80.0%) against godmode 10 of 10. The gap lives entirely in sec-05, below and in the appendix.

### Refactoring (refac)

| Category | Arm | Runs | Passes | Success | Median s | Mean s | Mean excl C-124 s | Max s | C-124 |
|---|---|---|---|---|---|---|---|---|---|
| refac | plain | 10 | 10 | 100.0% | 33.0 | 36.0 | 36.0 | 47.0 | 0 |
| refac | godmode | 10 | 10 | 100.0% | 40.5 | 41.6 | 41.6 | 65.0 | 0 |

The widest median gap among the all-pass categories: 33.0 vs 40.5.

---

## Where godmode won

**Test writing.** Category median 83.0 s vs 89.5 s, mean 82.4 s vs 135.0 s, max 127.0 s vs 372.0 s, with no censored rows on either side. The appendix rows show where the gap comes from: test-03 mids 110.0 s (godmode) vs 231.5 s (plain), and test-04 mids 70.0 s vs 211.0 s. Plain's slowest single run in the category was 372.0 s (test-04 run 2); godmode's slowest was 127.0 s (test-03 run 1).

**sec-05, the only task-level win.** Plain recorded 600.0 s and 600.0 s -- both runs killed at the cap, both censored, 0/2 passes. Godmode finished in 415.0 s and 405.0 s, 2/2 passes. Now the honest part: this is the whole task-level difference between the arms, and it is contingent on the 600-second cap. Godmode needed 415.0 and 405.0 seconds here, so a 400-second cap would have failed both arms on this task and the task-level counts would read 29/30 apiece. A one-task difference, at 30 tasks with 2 runs per arm, is not distinguishable from ordinary run-to-run variation. We report it; we do not lean on it.

---

## Where godmode did not win

**Overall speed.** Plain's median scored run was 37.0 s against godmode's 41.0 s, and on the per-task mid comparison plain was faster on 20/30 tasks, godmode faster on 10/30, with 0/30 ties.

**Small-task overhead.** In the three categories where both arms passed everything and runs finish fast -- bug, feat, refac -- the godmode median sits above the plain median each time (plain vs godmode): bug 29.5 vs 34.0, feat 30.0 vs 34.0, refac 33.0 vs 40.5. That reads as a fixed overhead for carrying the skill library, paid on every quick task.

**perf-05.** Godmode run 1 finished in 130.0 s; run 2 was killed at the cap -- exit 124, duration 601.0 recorded at the cap -- with the metric passing on the final workspace state, so it counts as a pass in the 60/60 run-level total while its true duration is unknown and at least the cap. Plain finished the same task in 124.0 s and 167.0 s. The mids read 145.5 s (plain) vs 365.5 s (godmode), godmode's mid built from one real run and one censored one.

---

## Verify stability

| Runs | Distinct parents | Max per parent | Passes | Success | Median s | Mean s | Max s |
|---|---|---|---|---|---|---|---|
| 48 | 24 | 2 | 48 | 100.0% | 39.0 | 39.0 | 72.0 |

verify coverage: perf-01 perf-02 bug-01 bug-02 bug-03 bug-04 bug-05 feat-01 feat-02 feat-03 feat-04 feat-05 (12 tasks)

All 48 verify runs passed, median 39.0 s, max 72.0 s, at most 2 verify runs per parent pass. The coverage line above is pasted verbatim: the 48 verify runs cover 24 of the 60 godmode scored passes, across 12 tasks -- perf-01, perf-02, bug-01 through bug-05, and feat-01 through feat-05.

The asymmetry, stated plainly: plain passes were never re-verified. Replication in this benchmark is one-sided by design -- it tests whether godmode passes reproduce from a clean workspace, and there is no equivalent count for plain.

---

## Threats to validity

- Self-authored corpus. We wrote the tasks, the starters, and the metrics; the solutions are published in the repo for audit ([bench/tasks/](../../bench/tasks/)), but authorship is still ours.
- Arm asymmetry is installed-vs-not. The godmode arm carries the skill library's context overhead as part of the treatment; there is no ablation arm isolating individual skills.
- Small tasks on small codebases. 30 tasks on starters under 200 lines may not transfer to real repositories with real history.
- Cap interaction with the only delta. The single task-level difference depends on the 600-second cap, as spelled out under sec-05.
- Binary metric. Pass/fail with no quality gradation; one gaming hole on test-01 was caught and fixed before the farm ran, and we cannot rule out others.
- One machine, one date. All runs on 2026-08-28 across 4 parallel lanes; lane contention adds noise to wall-clock durations.
- Model stochasticity. No seed or temperature pinning; run-to-run variation is part of every duration in the tables.
- Single model. zai/glm-5.3 only; other models may split differently.
- Verify asymmetry. The verify wave covered godmode passes only, so replication evidence exists for one arm.
- No keep/revert telemetry. The loop's keep/revert decisions were not recorded -- see the verbatim note in Overall results; any keep/revert claim from this dataset would be fabricated.

---

## Reproducing

The frozen results are checked in at [bench/results.tsv](../../bench/results.tsv) (168 rows: 120 scored + 48 verify). Every table in this post is the verbatim output of:

```bash
python3 bench/analyze.py --markdown --by-task bench/results.tsv
```

Scored farm:

```bash
bash bench/run-farm.sh --batch 24 --lanes 4 --runs-per-combo 2
```

Verify wave:

```bash
bash bench/run-farm.sh --verify-wave --runs-per-combo 2
```

---

## Appendix: all 30 tasks

Every scored run, verbatim. Mid is the midpoint of the two runs; † marks exit-124 rows right-censored at the 600-second cap.

| Task | Arm | r1 s | r2 s | Pass | Mid s (mid of 2) | C-124 |
|---|---|---|---|---|---|---|
| perf-01 | plain | 37.0 | 29.0 | 2/2 | 33.0 | - |
| perf-01 | godmode | 42.0 | 32.0 | 2/2 | 37.0 | - |
| perf-02 | plain | 37.0 | 20.0 | 2/2 | 28.5 | - |
| perf-02 | godmode | 30.0 | 19.0 | 2/2 | 24.5 | - |
| perf-03 | plain | 39.0 | 23.0 | 2/2 | 31.0 | - |
| perf-03 | godmode | 38.0 | 29.0 | 2/2 | 33.5 | - |
| perf-04 | plain | 30.0 | 27.0 | 2/2 | 28.5 | - |
| perf-04 | godmode | 40.0 | 26.0 | 2/2 | 33.0 | - |
| perf-05 | plain | 124.0 | 167.0 | 2/2 | 145.5 | - |
| perf-05 | godmode | 130.0 | 601.0 | 2/2 | 365.5 | r2 |
| bug-01 | plain | 40.0 | 28.0 | 2/2 | 34.0 | - |
| bug-01 | godmode | 41.0 | 36.0 | 2/2 | 38.5 | - |
| bug-02 | plain | 27.0 | 26.0 | 2/2 | 26.5 | - |
| bug-02 | godmode | 25.0 | 22.0 | 2/2 | 23.5 | - |
| bug-03 | plain | 28.0 | 22.0 | 2/2 | 25.0 | - |
| bug-03 | godmode | 28.0 | 25.0 | 2/2 | 26.5 | - |
| bug-04 | plain | 41.0 | 44.0 | 2/2 | 42.5 | - |
| bug-04 | godmode | 54.0 | 42.0 | 2/2 | 48.0 | - |
| bug-05 | plain | 35.0 | 31.0 | 2/2 | 33.0 | - |
| bug-05 | godmode | 32.0 | 39.0 | 2/2 | 35.5 | - |
| test-01 | plain | 83.0 | 68.0 | 2/2 | 75.5 | - |
| test-01 | godmode | 81.0 | 54.0 | 2/2 | 67.5 | - |
| test-02 | plain | 40.0 | 95.0 | 2/2 | 67.5 | - |
| test-02 | godmode | 98.0 | 67.0 | 2/2 | 82.5 | - |
| test-03 | plain | 243.0 | 220.0 | 2/2 | 231.5 | - |
| test-03 | godmode | 127.0 | 93.0 | 2/2 | 110.0 | - |
| test-04 | plain | 50.0 | 372.0 | 2/2 | 211.0 | - |
| test-04 | godmode | 87.0 | 53.0 | 2/2 | 70.0 | - |
| test-05 | plain | 88.0 | 91.0 | 2/2 | 89.5 | - |
| test-05 | godmode | 85.0 | 79.0 | 2/2 | 82.0 | - |
| feat-01 | plain | 29.0 | 41.0 | 2/2 | 35.0 | - |
| feat-01 | godmode | 35.0 | 45.0 | 2/2 | 40.0 | - |
| feat-02 | plain | 26.0 | 30.0 | 2/2 | 28.0 | - |
| feat-02 | godmode | 44.0 | 38.0 | 2/2 | 41.0 | - |
| feat-03 | plain | 32.0 | 37.0 | 2/2 | 34.5 | - |
| feat-03 | godmode | 25.0 | 29.0 | 2/2 | 27.0 | - |
| feat-04 | plain | 33.0 | 29.0 | 2/2 | 31.0 | - |
| feat-04 | godmode | 32.0 | 33.0 | 2/2 | 32.5 | - |
| feat-05 | plain | 29.0 | 30.0 | 2/2 | 29.5 | - |
| feat-05 | godmode | 30.0 | 38.0 | 2/2 | 34.0 | - |
| sec-01 | plain | 47.0 | 50.0 | 2/2 | 48.5 | - |
| sec-01 | godmode | 56.0 | 47.0 | 2/2 | 51.5 | - |
| sec-02 | plain | 34.0 | 29.0 | 2/2 | 31.5 | - |
| sec-02 | godmode | 41.0 | 49.0 | 2/2 | 45.0 | - |
| sec-03 | plain | 32.0 | 39.0 | 2/2 | 35.5 | - |
| sec-03 | godmode | 43.0 | 60.0 | 2/2 | 51.5 | - |
| sec-04 | plain | 39.0 | 47.0 | 2/2 | 43.0 | - |
| sec-04 | godmode | 39.0 | 41.0 | 2/2 | 40.0 | - |
| sec-05 | plain | 600.0 | 600.0 | 0/2 | 600.0 | r1,r2 |
| sec-05 | godmode | 415.0 | 405.0 | 2/2 | 410.0 | - |
| refac-01 | plain | 27.0 | 32.0 | 2/2 | 29.5 | - |
| refac-01 | godmode | 32.0 | 34.0 | 2/2 | 33.0 | - |
| refac-02 | plain | 39.0 | 47.0 | 2/2 | 43.0 | - |
| refac-02 | godmode | 61.0 | 65.0 | 2/2 | 63.0 | - |
| refac-03 | plain | 27.0 | 34.0 | 2/2 | 30.5 | - |
| refac-03 | godmode | 21.0 | 22.0 | 2/2 | 21.5 | - |
| refac-04 | plain | 31.0 | 30.0 | 2/2 | 30.5 | - |
| refac-04 | godmode | 36.0 | 45.0 | 2/2 | 40.5 | - |
| refac-05 | plain | 46.0 | 47.0 | 2/2 | 46.5 | - |
| refac-05 | godmode | 50.0 | 50.0 | 2/2 | 50.0 | - |
