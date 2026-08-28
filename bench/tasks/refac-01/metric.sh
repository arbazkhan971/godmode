#!/usr/bin/env bash
# metric refac-01: one shared validate_member helper called by both commands; CLI behavior unchanged. Immutable during benchmark runs (runner SHA256-checksums this file).
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

printf '%s\n' 'added m3: grace <grace@example.org>' >"$tmp/e1"
printf '%s\n' 'error: invalid member spec' >"$tmp/e2"
printf '%s\n' 'error: duplicate id: m1' >"$tmp/e3"
printf '%s\n' 'updated m2: linus2 <linus2@example.org>' >"$tmp/e4"
printf '%s\n' 'error: unknown id: m9' >"$tmp/e5"
printf '%s\n' 'usage: main.py {add|update} <id> <name> <email>' >"$tmp/e6"

check 0 "$tmp/e1" add m3 grace grace@example.org
check 1 "$tmp/e2" add m4 '' g@example.org
check 1 "$tmp/e2" add m5 bob no-at-sign
check 1 "$tmp/e3" add m1 Someone a@example.org
check 0 "$tmp/e4" update m2 linus2 linus2@example.org
check 1 "$tmp/e5" update m9 x y@example.org
check 2 "$tmp/e6"

# --- structural goal: exactly one validate_member, called from both command paths ---
cat >"$tmp/struct.py" <<'EOF'
import ast, pathlib, sys
files = sorted(pathlib.Path("starter").rglob("*.py"))
defs, calls = 0, 0
for path in files:
    for node in ast.walk(ast.parse(path.read_text())):
        if isinstance(node, ast.FunctionDef) and node.name == "validate_member":
            defs += 1
        if (isinstance(node, ast.Call) and isinstance(node.func, ast.Name)
                and node.func.id == "validate_member"):
            calls += 1
if defs != 1:
    sys.exit("structure: expected exactly 1 'def validate_member', found %d" % defs)
if calls < 2:
    sys.exit("structure: validate_member must be called from both commands, found %d call sites" % calls)
msgs = sum(path.read_text().count("error: invalid member spec") for path in files)
if msgs != 1:
    sys.exit("structure: 'error: invalid member spec' must be emitted from exactly one place, found %d" % msgs)
EOF
"$TO" 10 "$PY" "$tmp/struct.py" || die "structural goal not met"

echo "METRIC: PASS refac-01"
exit 0
