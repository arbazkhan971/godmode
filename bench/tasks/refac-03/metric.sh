#!/usr/bin/env bash
# metric refac-03: single loadRecords helper (readFileSync/JSON.parse once) used by all 3 commands; CLI behavior unchanged. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/index.js ] || die "missing starter/index.js"

# --- behavior preservation: expected stdout/exit codes captured from the original starter ---
printf '{"records":[{"id":"r1","name":"alpha","qty":3},{"id":"r2","name":"beta","qty":5}]}' >"$tmp/records.json"
printf 'nope{' >"$tmp/bad.json"

check(){ # check <expected_rc> <expected_stdout_file> <argv...>
  local want_rc="$1" want_out="$2"; shift 2
  "$TO" 10 "$NODE" starter/index.js "$@" >"$tmp/got.out" 2>"$tmp/got.err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "behavior: 'index.js $*': exit $rc, want $want_rc"
  cmp -s "$want_out" "$tmp/got.out" || die "behavior: 'index.js $*': stdout mismatch"
}

printf '%s\n' 'r1 alpha 3' 'r2 beta 5' >"$tmp/e1"
printf '%s\n' '8' >"$tmp/e2"
printf '%s\n' 'r1,r2' >"$tmp/e3"
printf '%s\n' "error: cannot read $tmp/missing.json" >"$tmp/e4"
printf '%s\n' "error: invalid JSON: $tmp/bad.json" >"$tmp/e5"
printf '%s\n' 'usage: index.js {list|total|ids} <records.json>' >"$tmp/e6"

check 0 "$tmp/e1" list "$tmp/records.json"
check 0 "$tmp/e2" total "$tmp/records.json"
check 0 "$tmp/e3" ids "$tmp/records.json"
check 1 "$tmp/e4" list "$tmp/missing.json"
check 1 "$tmp/e5" total "$tmp/bad.json"
check 1 "$tmp/e4" ids "$tmp/missing.json"
check 2 "$tmp/e6"

# --- structural goal: one loadRecords definition called by all three commands ---
reads=$(grep -ro 'readFileSync' starter | wc -l)
[ "$reads" -eq 1 ] || die "structure: readFileSync must appear exactly once under starter/, found $reads"
parses=$(grep -ro 'JSON\.parse(' starter | wc -l)
[ "$parses" -eq 1 ] || die "structure: JSON.parse( must appear exactly once under starter/, found $parses"
defs=$(grep -ro 'function loadRecords' starter | wc -l)
[ "$defs" -eq 1 ] || die "structure: expected exactly 1 'function loadRecords' definition, found $defs"
uses=$(grep -ro 'loadRecords(' starter | wc -l)
[ "$uses" -ge 4 ] || die "structure: loadRecords must be called from all 3 commands (found $((uses - defs)) call sites)"

echo "METRIC: PASS refac-03"
exit 0
