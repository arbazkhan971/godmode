#!/usr/bin/env bash
# metric test-02: agent suite must pass pristine daterange.py and fail on 3 seeded mutants. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

IMPL=daterange.py
TESTS=starter/tests

[ -f "starter/$IMPL" ] || die "missing starter/$IMPL"
[ -d "$TESTS" ] || die "no tests yet: write unittest tests under starter/tests/ as test_*.py"
ls "$TESTS"/test_*.py >/dev/null 2>&1 || die "no test_*.py files under $TESTS"

# Metric-owned runner: unittest-discover the copied suite against a variant impl.
cat > "$tmp/run_suite.py" <<'RUNNER'
import os
import sys
import unittest

case = sys.argv[1]
sys.path.append(case)  # never insert(0): stdlib must win over workspace names
os.chdir(case)
suite = unittest.defaultTestLoader.discover(os.path.join(case, "tests"))
result = unittest.TextTestRunner(verbosity=0, stream=open(os.devnull, "w")).run(suite)
sys.exit(0 if result.wasSuccessful() else 1)
RUNNER

run_case(){  # $1=variant label; impl source on stdin; returns the suite's exit status
  local case_dir="$tmp/case-$1"
  mkdir -p "$case_dir/tests"
  cat > "$case_dir/$IMPL"
  cp -r "$TESTS"/. "$case_dir/tests/"
  "$TO" 15 "$PY" "$tmp/run_suite.py" "$case_dir" >/dev/null 2>&1
}

# Variant: pristine implementation -> the suite must pass.
run_case pristine <<'IMPL'
"""Inclusive date ranges: counts, day lists, and month ends from ISO strings."""

from datetime import date, timedelta


def parse_day(text):
    """Parse an ISO 'YYYY-MM-DD' string into a datetime.date."""
    year, month, day = (int(part) for part in text.split("-"))
    return date(year, month, day)


def days_between(start, end):
    """Count the days in the inclusive range [start, end]; a single day is 1."""
    return (parse_day(end) - parse_day(start)).days + 1


def range_days(start, end):
    """List every ISO day string in the inclusive range, in order."""
    cur = parse_day(start)
    stop = parse_day(end)
    out = []
    while cur <= stop:
        out.append(cur.isoformat())
        cur += timedelta(days=1)
    return out


def month_end(month):
    """Return the ISO string for the last day of the given 'YYYY-MM' month."""
    year, mon = (int(part) for part in month.split("-"))
    if mon == 12:
        first_next = date(year + 1, 1, 1)
    else:
        first_next = date(year, mon + 1, 1)
    return (first_next - timedelta(days=1)).isoformat()
IMPL
rc=$?; [ "$rc" -eq 0 ] || die "suite fails on the pristine implementation (rc=$rc) - fix the tests, not the impl"

# Mutant 1: boundary - ranges become exclusive, dropping the final day.
run_case m_boundary <<'IMPL'
"""Inclusive date ranges: counts, day lists, and month ends from ISO strings."""

from datetime import date, timedelta


def parse_day(text):
    """Parse an ISO 'YYYY-MM-DD' string into a datetime.date."""
    year, month, day = (int(part) for part in text.split("-"))
    return date(year, month, day)


def days_between(start, end):
    """Count the days in the inclusive range [start, end]; a single day is 1."""
    return (parse_day(end) - parse_day(start)).days


def range_days(start, end):
    """List every ISO day string in the inclusive range, in order."""
    cur = parse_day(start)
    stop = parse_day(end)
    out = []
    while cur <= stop:
        out.append(cur.isoformat())
        cur += timedelta(days=1)
    return out


def month_end(month):
    """Return the ISO string for the last day of the given 'YYYY-MM' month."""
    year, mon = (int(part) for part in month.split("-"))
    if mon == 12:
        first_next = date(year + 1, 1, 1)
    else:
        first_next = date(year, mon + 1, 1)
    return (first_next - timedelta(days=1)).isoformat()
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_boundary survived - inclusive-boundary counting is untested"

# Mutant 2: month-end lands one day early.
run_case m_monthend <<'IMPL'
"""Inclusive date ranges: counts, day lists, and month ends from ISO strings."""

from datetime import date, timedelta


def parse_day(text):
    """Parse an ISO 'YYYY-MM-DD' string into a datetime.date."""
    year, month, day = (int(part) for part in text.split("-"))
    return date(year, month, day)


def days_between(start, end):
    """Count the days in the inclusive range [start, end]; a single day is 1."""
    return (parse_day(end) - parse_day(start)).days + 1


def range_days(start, end):
    """List every ISO day string in the inclusive range, in order."""
    cur = parse_day(start)
    stop = parse_day(end)
    out = []
    while cur <= stop:
        out.append(cur.isoformat())
        cur += timedelta(days=1)
    return out


def month_end(month):
    """Return the ISO string for the last day of the given 'YYYY-MM' month."""
    year, mon = (int(part) for part in month.split("-"))
    if mon == 12:
        first_next = date(year + 1, 1, 1)
    else:
        first_next = date(year, mon + 1, 1)
    return (first_next - timedelta(days=2)).isoformat()
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_monthend survived - month-end handling is untested"

# Mutant 3: type coercion - day counts come back as strings instead of ints.
run_case m_coercion <<'IMPL'
"""Inclusive date ranges: counts, day lists, and month ends from ISO strings."""

from datetime import date, timedelta


def parse_day(text):
    """Parse an ISO 'YYYY-MM-DD' string into a datetime.date."""
    year, month, day = (int(part) for part in text.split("-"))
    return date(year, month, day)


def days_between(start, end):
    """Count the days in the inclusive range [start, end]; a single day is 1."""
    return str((parse_day(end) - parse_day(start)).days + 1)


def range_days(start, end):
    """List every ISO day string in the inclusive range, in order."""
    cur = parse_day(start)
    stop = parse_day(end)
    out = []
    while cur <= stop:
        out.append(cur.isoformat())
        cur += timedelta(days=1)
    return out


def month_end(month):
    """Return the ISO string for the last day of the given 'YYYY-MM' month."""
    year, mon = (int(part) for part in month.split("-"))
    if mon == 12:
        first_next = date(year + 1, 1, 1)
    else:
        first_next = date(year, mon + 1, 1)
    return (first_next - timedelta(days=1)).isoformat()
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_coercion survived - day-count return type is untested"

echo "METRIC: PASS test-02"
exit 0
