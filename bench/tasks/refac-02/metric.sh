#!/usr/bin/env bash
# metric refac-02: split build_invoice into named functions (<=20 lines each, >=5 defs) with behavior unchanged. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.py ] || die "missing starter/main.py"

# --- behavior preservation: expected stdout/exit codes captured from the original starter ---
check(){ # check <expected_rc> <expected_stdout_file> <argv...>
  local want_rc="$1" want_out="$2"; shift 2
  "$TO" 10 "$PY" starter/main.py "$@" >"$tmp/got.out" 2>"$tmp/got.err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "behavior: 'main.py $*': exit $rc, want $want_rc"
  cmp -s "$want_out" "$tmp/got.out" || die "behavior: 'main.py $*': stdout mismatch"
}

cat >"$tmp/e1" <<'EOF'
invoice for ACME
month: 3
  trap x1 @300 = 300
  anvil x2 @100 = 200
  rope x5 @4 = 20
subtotal: 520
discount: 52
tax: 37
total: 505
EOF
cat >"$tmp/e2" <<'EOF'
invoice for INITECH
month: 4
  tps report x10 @1 = 10
subtotal: 10
discount: 0
tax: 0
total: 10
EOF
cat >"$tmp/e3" <<'EOF'
invoice for GLOBEX
month: 4
(no charges)
subtotal: 0
discount: 0
tax: 0
total: 0
EOF
cat >"$tmp/e4" <<'EOF'
invoice for GLOBEX
month: 3
  fin x3 @20 = 60
subtotal: 60
discount: 0
tax: 4
total: 64
EOF
printf '%s\n' 'error: unknown customer: NOPE' >"$tmp/e5"
printf '%s\n' 'error: month must be 1-12' >"$tmp/e6"
printf '%s\n' 'error: month must be an integer' >"$tmp/e7"
printf '%s\n' 'usage: main.py invoice <customer> <month 1-12>' >"$tmp/e8"

check 0 "$tmp/e1" invoice ACME 3
check 0 "$tmp/e1" invoice acme 3
check 0 "$tmp/e2" invoice INITECH 4
check 0 "$tmp/e3" invoice GLOBEX 4
check 0 "$tmp/e4" invoice GLOBEX 3
check 1 "$tmp/e5" invoice NOPE 3
check 1 "$tmp/e6" invoice ACME 13
check 1 "$tmp/e7" invoice ACME x
check 2 "$tmp/e8"
check 2 "$tmp/e8" invoice ACME 3 4

# --- structural goal: no function longer than 20 lines; at least 5 named functions ---
cat >"$tmp/struct.py" <<'EOF'
import ast, pathlib, sys
files = sorted(pathlib.Path("starter").rglob("*.py"))
total_defs = 0
for path in files:
    for node in ast.walk(ast.parse(path.read_text())):
        if isinstance(node, ast.FunctionDef):
            total_defs += 1
            span = node.end_lineno - node.lineno + 1
            if span > 20:
                sys.exit("structure: %s:%d function '%s' spans %d lines (max 20)"
                         % (path, node.lineno, node.name, span))
if total_defs < 5:
    sys.exit("structure: starter must define at least 5 named functions, found %d" % total_defs)
EOF
"$TO" 10 "$PY" "$tmp/struct.py" || die "structural goal not met"

echo "METRIC: PASS refac-02"
exit 0
