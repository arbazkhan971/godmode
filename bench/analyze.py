#!/usr/bin/env python3
"""bench/analyze.py — deterministic summary tables from the frozen bench/results.tsv.

Strictly read-only over the TSV (never writes it). Stdlib only. Splits the
ledger into scored rows (parent_run empty) and verify rows (parent_run set),
and emits per-arm, per-category, verify, and (with --by-task) per-task tables.
Verify rows never enter arm statistics. No delta column anywhere: n=10 per
cell cannot support one.

Usage: python3 bench/analyze.py [tsv] [--markdown] [--by-task] [--assert-complete]
Exit:  0 ok · 1 data/completeness error ("analyze: ERROR: [tag] ..." on stderr) · 2 usage
"""

import argparse
import csv
import re
import statistics
import sys
from pathlib import Path

CATEGORIES = ["perf", "bug", "test", "feat", "sec", "refac"]
TASK_IDS = [f"{cat}-{i:02d}" for cat in CATEGORIES for i in range(1, 6)]
ARMS = ["plain", "godmode"]
TSV_HEADER = ["task_id", "arm", "run#", "parent_run", "start_ts", "end_ts",
              "exit_code", "metric_pass", "duration_s", "notes"]
TASK_RE = re.compile(r"^(?:perf|bug|test|feat|sec|refac)-[0-9]{2}$")
PARENT_RE = re.compile(r"^(?:perf|bug|test|feat|sec|refac)-[0-9]{2}:godmode:[0-9]+$")
MODEL_RE = re.compile(r"model:([^;\t]+)")
UINT_RE = re.compile(r"^[0-9]+$")
INT_RE = re.compile(r"^-?[0-9]+$")
CENSOR_CODE = 124

DAGGER = "†"
KEEP_REVERT_NOTE = ("keep/revert: n/a — not instrumented (no TSV column; logs contain only "
                    "stray mentions; any count would be fabricated)")
FOOTNOTE_DAGGER = ("† exit-124 durations are right-censored at the 600s cap — recorded value "
                   "is a lower bound; means including them are biased downward for timeouts.")
FOOTNOTE_MID = "mid = median of 2 runs = midpoint of the two values."
RUN_LEVEL_NOTE = "Medians and means are run-level over all scored runs per arm."

ARM_HEADER = ["Runs", "Passes", "Success", "Median s", "Mean s",
              "Mean excl C-124 s", "Max s", "C-124"]
VERIFY_HEADER = ["Runs", "Distinct parents", "Max per parent", "Passes",
                 "Success", "Median s", "Mean s", "Max s"]
APPENDIX_HEADER = ["Task", "Arm", "r1 s", "r2 s", "Pass", "Mid s (mid of 2)", "C-124"]


class DataError(Exception):
    """Validation or completeness failure — printed as analyze: ERROR: [tag] …"""

    def __init__(self, tag, detail):
        super().__init__(detail)
        self.tag = tag
        self.detail = detail


def load_rows(path):
    """Parse and validate the TSV; the first bad row wins."""
    try:
        fh = open(path, newline="", encoding="utf-8")
    except OSError as exc:
        raise DataError("io", f"cannot read {path}: {exc}") from exc
    rows = []
    seen = set()
    with fh:
        reader = csv.reader(fh, delimiter="\t")
        try:
            header = next(reader)
        except StopIteration:
            raise DataError("header", f"{path}: empty file") from None
        if header != TSV_HEADER:
            raise DataError("header",
                            "expected " + "\\t".join(TSV_HEADER) + ", got " + "\\t".join(header))
        for row in reader:
            line = reader.line_num
            if len(row) != 10:
                raise DataError("malformed",
                                f"line {line}: expected 10 fields, got {len(row)}")
            (task_id, arm, run, parent_run, _start_ts, _end_ts,
             exit_code, metric_pass, duration_s, notes) = row
            if not TASK_RE.match(task_id):
                raise DataError("domain", f"line {line}: bad task_id '{task_id}'")
            if arm not in ARMS:
                raise DataError("domain", f"line {line}: bad arm '{arm}'")
            if not UINT_RE.match(run) or int(run) < 1:
                raise DataError("domain", f"line {line}: bad run# '{run}'")
            if metric_pass not in ("0", "1", ""):
                raise DataError("domain", f"line {line}: bad metric_pass '{metric_pass}'")
            if exit_code != "" and not INT_RE.match(exit_code):
                raise DataError("domain", f"line {line}: bad exit_code '{exit_code}'")
            if duration_s != "":
                try:
                    duration = float(duration_s)
                except ValueError:
                    raise DataError("domain",
                                    f"line {line}: bad duration_s '{duration_s}'") from None
            else:
                duration = None
            key = (task_id, arm, run, parent_run)
            if key in seen:
                raise DataError("dup-key", f"line {line}: duplicated key "
                                            f"task_id={task_id} arm={arm} run#={run} "
                                            f"parent_run='{parent_run}'")
            seen.add(key)
            if parent_run != "":
                if not PARENT_RE.match(parent_run):
                    raise DataError("verify-parent", f"line {line}: parent_run "
                                                     f"'{parent_run}' must match "
                                                     "task:godmode:run#")
                if arm != "godmode":
                    raise DataError("verify-parent", f"line {line}: verify row arm must "
                                                     f"be godmode, got '{arm}'")
                if parent_run.split(":", 1)[0] != task_id:
                    raise DataError("verify-parent", f"line {line}: parent task "
                                                     f"'{parent_run.split(':', 1)[0]}' "
                                                     f"!= task_id '{task_id}'")
            rows.append({
                "task_id": task_id, "arm": arm, "run": int(run),
                "parent_run": parent_run,
                "exit_code": int(exit_code) if exit_code != "" else None,
                "metric_pass": int(metric_pass) if metric_pass != "" else None,
                "duration": duration, "notes": notes,
            })
    return rows


def fmt(value, dagger=False):
    """Render a duration/None cell with one decimal; None -> n/a, never dropped."""
    if value is None:
        return "n/a"
    return f"{value:.1f}" + (DAGGER if dagger else "")


def pct(passes, runs):
    return "n/a" if runs == 0 else f"{100.0 * passes / runs:.1f}%"


def time_stats(rows):
    """[median incl censored, mean incl, mean excl 124, max(† if censored)]."""
    durations = [r["duration"] for r in rows if r["duration"] is not None]
    uncensored = [r["duration"] for r in rows
                  if r["duration"] is not None and r["exit_code"] != CENSOR_CODE]
    top = max(durations) if durations else None
    top_censored = top is not None and any(
        r["duration"] == top and r["exit_code"] == CENSOR_CODE for r in rows)
    return [fmt(statistics.median(durations) if durations else None),
            fmt(statistics.mean(durations) if durations else None),
            fmt(statistics.mean(uncensored) if uncensored else None),
            fmt(top, top_censored)]


def arm_row(rows):
    runs = len(rows)
    passes = sum(1 for r in rows if r["metric_pass"] == 1)
    return ([str(runs), str(passes), pct(passes, runs)] + time_stats(rows)
            + [str(sum(1 for r in rows if r["exit_code"] == CENSOR_CODE))])


def verify_row(verify):
    parents = {}
    for r in verify:
        parents[r["parent_run"]] = parents.get(r["parent_run"], 0) + 1
    runs = len(verify)
    passes = sum(1 for r in verify if r["metric_pass"] == 1)
    ts = time_stats(verify)
    return ([str(runs), str(len(parents)),
             str(max(parents.values())) if parents else "n/a",
             str(passes), pct(passes, runs)] + ts[:2] + ts[3:])


def scored_by_task_arm(scored):
    """runs-by-run# for the fixed 30-task universe x 2 arms (appendix/tally shape)."""
    by = {}
    for tid in TASK_IDS:
        for arm in ARMS:
            by[(tid, arm)] = {r["run"]: r for r in scored
                              if r["task_id"] == tid and r["arm"] == arm}
    return by


def appendix_rows(by):
    rows = []
    for tid in TASK_IDS:
        for arm in ARMS:
            runs = by[(tid, arm)]
            r1, r2 = runs.get(1), runs.get(2)
            d1 = r1["duration"] if r1 else None
            d2 = r2["duration"] if r2 else None
            mid = (d1 + d2) / 2 if (d1 is not None and d2 is not None) else None
            passes = sum(1 for r in runs.values() if r["metric_pass"] == 1)
            censored = [f"r{n}" for n in (1, 2)
                        if n in runs and runs[n]["exit_code"] == CENSOR_CODE]
            rows.append([tid, arm, fmt(d1), fmt(d2), f"{passes}/2", fmt(mid),
                         ",".join(censored) if censored else "-"])
    return rows


def faster_tally(by):
    plain_wins = godmode_wins = ties = 0
    for tid in TASK_IDS:
        mids = []
        for arm in ARMS:
            runs = by[(tid, arm)]
            ds = [runs[n]["duration"] for n in (1, 2)
                  if n in runs and runs[n]["duration"] is not None]
            mids.append(statistics.median(ds) if len(ds) == 2 else None)
        p_mid, g_mid = mids
        if p_mid is None or g_mid is None:
            continue
        if p_mid < g_mid:
            plain_wins += 1
        elif g_mid < p_mid:
            godmode_wins += 1
        else:
            ties += 1
    n = plain_wins + godmode_wins + ties
    return (f"per-task mid comparison: plain faster on {plain_wins}/{n}, "
            f"godmode faster on {godmode_wins}/{n} (ties on {ties}/{n})")


def notes_block(rows, by):
    lines = [KEEP_REVERT_NOTE]
    counts = {}
    for r in rows:  # lenient model:([^;\t]+) — survives the ";timeout" suffix
        m = MODEL_RE.search(r["notes"])
        if m:
            counts[m.group(1)] = counts.get(m.group(1), 0) + 1
    for model in sorted(counts):
        lines.append(f"model:{model} — {counts[model]} rows")
    censored = sum(1 for r in rows if r["exit_code"] == CENSOR_CODE)
    lines.append(f"{censored} exit-124 rows recorded at the 600s cap")
    lines.append(faster_tally(by))
    return lines


def render_table(header, body, markdown):
    if markdown:
        lines = ["| " + " | ".join(header) + " |",
                 "|" + "|".join(["---"] * len(header)) + "|"]
        return lines + ["| " + " | ".join(row) + " |" for row in body]
    widths = [len(h) for h in header]
    for row in body:
        for i, cell in enumerate(row):
            widths[i] = max(widths[i], len(cell))

    def text_row(row):
        return "  ".join(c.ljust(widths[i]) for i, c in enumerate(row)).rstrip()

    return ([text_row(header), "  ".join("-" * w for w in widths)]
            + [text_row(row) for row in body])


def task_order(tid):
    return (CATEGORIES.index(tid.split("-", 1)[0]), tid)


def build_output(rows, markdown, by_task):
    scored = [r for r in rows if r["parent_run"] == ""]
    verify = [r for r in rows if r["parent_run"] != ""]
    by = scored_by_task_arm(scored)
    heading = (lambda t: "## " + t) if markdown else (lambda t: t)

    lines = ["# Bench results"] if markdown else []
    lines += [f"{len(rows)} rows: {len(scored)} scored + {len(verify)} verify", ""]

    lines.append(heading("Overall (scored runs only)"))
    lines += render_table(["Arm"] + ARM_HEADER,
                          [[arm] + arm_row([r for r in scored if r["arm"] == arm])
                           for arm in ARMS], markdown)
    lines += ["", RUN_LEVEL_NOTE, ""]

    lines.append(heading("Per category (scored runs only)"))
    cat_body = []
    for cat in CATEGORIES:
        for arm in ARMS:
            rs = [r for r in scored
                  if r["task_id"].split("-", 1)[0] == cat and r["arm"] == arm]
            cat_body.append([cat, arm] + arm_row(rs))
    lines += render_table(["Category", "Arm"] + ARM_HEADER, cat_body, markdown)
    lines.append("")

    lines.append(heading("Verify runs"))
    lines += render_table(VERIFY_HEADER, [verify_row(verify)], markdown)
    coverage = sorted({r["task_id"] for r in verify}, key=task_order)
    cov_line = "verify coverage: " + (" ".join(coverage) if coverage else "none")
    if coverage:
        cov_line += f" ({len(coverage)} tasks)"
    lines += ["", cov_line, ""]

    lines.append(heading("Notes"))
    lines += ["- " + n for n in notes_block(rows, by)]

    if by_task:
        lines += ["", heading("Appendix: per-task scored runs")]
        lines += render_table(APPENDIX_HEADER, appendix_rows(by), markdown)

    lines += ["", heading("Footnotes") if markdown else "Footnotes:",
              FOOTNOTE_DAGGER, FOOTNOTE_MID]
    return lines


def assert_complete(scored):
    problems = []
    for tid in TASK_IDS:
        for arm in ARMS:
            n = sum(1 for r in scored if r["task_id"] == tid and r["arm"] == arm)
            if n < 2:
                problems.append(f"{tid} {arm} runs={n}")
    if problems:
        raise DataError("incomplete", "missing combos: " + "; ".join(problems))


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Deterministic summary tables from a frozen bench results.tsv.")
    parser.add_argument("tsv", nargs="?",
                        help="path to results.tsv (default: results.tsv beside this script)")
    parser.add_argument("--markdown", action="store_true",
                        help="emit markdown tables instead of aligned plain text")
    parser.add_argument("--by-task", dest="by_task", action="store_true",
                        help="append the per-task appendix table (60 rows)")
    parser.add_argument("--assert-complete", dest="assert_complete", action="store_true",
                        help="require all 30 tasks x both arms x >=2 scored runs; "
                             "exit 1 listing every gap")
    args = parser.parse_args(argv)
    path = Path(args.tsv) if args.tsv else Path(__file__).resolve().parent / "results.tsv"
    try:
        rows = load_rows(path)
        if args.assert_complete:
            assert_complete([r for r in rows if r["parent_run"] == ""])
        lines = build_output(rows, args.markdown, args.by_task)
    except DataError as exc:
        print(f"analyze: ERROR: [{exc.tag}] {exc.detail}", file=sys.stderr)
        return 1
    print("\n".join(lines))
    return 0


if __name__ == "__main__":
    sys.exit(main())
