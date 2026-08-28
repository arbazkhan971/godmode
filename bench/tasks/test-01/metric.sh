#!/usr/bin/env bash
# metric test-01: agent suite must pass pristine csvrows.py and fail on 3 seeded mutants. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

IMPL=csvrows.py
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
  # Sourceless variant: compile to csvrows.pyc, then delete csvrows.py so tests
  # can import the impl but cannot open()/assert on its source text (B0: metrics not gameable).
  "$PY" -c "import py_compile,sys; py_compile.compile(sys.argv[1], cfile=sys.argv[2], doraise=True)" \
    "$case_dir/$IMPL" "$case_dir/csvrows.pyc" || die "py_compile failed for variant $1"
  rm -f "$case_dir/$IMPL"
  cp -r "$TESTS"/. "$case_dir/tests/"
  "$TO" 15 "$PY" "$tmp/run_suite.py" "$case_dir" >/dev/null 2>&1
}

# Variant: pristine implementation -> the suite must pass.
run_case pristine <<'IMPL'
"""Parse CSV lines: split fields honoring quotes, map rows onto headers."""


def split_fields(line):
    """Split one CSV line into a list of field strings.

    Double-quoted sections may contain commas; a doubled quote ("") inside
    a quoted section is a literal quote character.
    """
    fields = []
    cur = []
    quoted = False
    i = 0
    while i < len(line):
        ch = line[i]
        if quoted:
            if ch == '"':
                if i + 1 < len(line) and line[i + 1] == '"':
                    cur.append('"')
                    i += 1
                else:
                    quoted = False
            else:
                cur.append(ch)
        elif ch == '"':
            quoted = True
        elif ch == ",":
            fields.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
        i += 1
    fields.append("".join(cur))
    return fields


def parse_row(header, line):
    """Map one CSV data line onto the header's keys as a dict."""
    keys = split_fields(header)
    values = split_fields(line)
    return dict(zip(keys, values))
IMPL
rc=$?; [ "$rc" -eq 0 ] || die "suite fails on the pristine implementation (rc=$rc) - fix the tests, not the impl"

# Mutant 1: opening quotes are ignored -> quoted sections no longer protect commas.
run_case m_quotes <<'IMPL'
"""Parse CSV lines: split fields honoring quotes, map rows onto headers."""


def split_fields(line):
    """Split one CSV line into a list of field strings.

    Double-quoted sections may contain commas; a doubled quote ("") inside
    a quoted section is a literal quote character.
    """
    fields = []
    cur = []
    quoted = False
    i = 0
    while i < len(line):
        ch = line[i]
        if quoted:
            if ch == '"':
                if i + 1 < len(line) and line[i + 1] == '"':
                    cur.append('"')
                    i += 1
                else:
                    quoted = False
            else:
                cur.append(ch)
        elif ch == '"':
            pass
        elif ch == ",":
            fields.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
        i += 1
    fields.append("".join(cur))
    return fields


def parse_row(header, line):
    """Map one CSV data line onto the header's keys as a dict."""
    keys = split_fields(header)
    values = split_fields(line)
    return dict(zip(keys, values))
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_quotes survived - quoted-field handling is untested"

# Mutant 2: an empty interior field becomes the sentinel "EMPTY".
run_case m_empty <<'IMPL'
"""Parse CSV lines: split fields honoring quotes, map rows onto headers."""


def split_fields(line):
    """Split one CSV line into a list of field strings.

    Double-quoted sections may contain commas; a doubled quote ("") inside
    a quoted section is a literal quote character.
    """
    fields = []
    cur = []
    quoted = False
    i = 0
    while i < len(line):
        ch = line[i]
        if quoted:
            if ch == '"':
                if i + 1 < len(line) and line[i + 1] == '"':
                    cur.append('"')
                    i += 1
                else:
                    quoted = False
            else:
                cur.append(ch)
        elif ch == '"':
            quoted = True
        elif ch == ",":
            fields.append("".join(cur) or "EMPTY")
            cur = []
        else:
            cur.append(ch)
        i += 1
    fields.append("".join(cur))
    return fields


def parse_row(header, line):
    """Map one CSV data line onto the header's keys as a dict."""
    keys = split_fields(header)
    values = split_fields(line)
    return dict(zip(keys, values))
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_empty survived - empty-field handling is untested"

# Mutant 3: a trailing empty field (line ends with a comma) is dropped.
run_case m_trailing <<'IMPL'
"""Parse CSV lines: split fields honoring quotes, map rows onto headers."""


def split_fields(line):
    """Split one CSV line into a list of field strings.

    Double-quoted sections may contain commas; a doubled quote ("") inside
    a quoted section is a literal quote character.
    """
    fields = []
    cur = []
    quoted = False
    i = 0
    while i < len(line):
        ch = line[i]
        if quoted:
            if ch == '"':
                if i + 1 < len(line) and line[i + 1] == '"':
                    cur.append('"')
                    i += 1
                else:
                    quoted = False
            else:
                cur.append(ch)
        elif ch == '"':
            quoted = True
        elif ch == ",":
            fields.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
        i += 1
    if cur:
        fields.append("".join(cur))
    return fields


def parse_row(header, line):
    """Map one CSV data line onto the header's keys as a dict."""
    keys = split_fields(header)
    values = split_fields(line)
    return dict(zip(keys, values))
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_trailing survived - trailing-field handling is untested"

echo "METRIC: PASS test-01"
exit 0
