#!/usr/bin/env bash
# metric feat-01: add a --json output mode to the shelf inventory CLI. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0 PYTHONDONTWRITEBYTECODE=1
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout
cap(){ "$TO" 10 "$@"; }

# run <label> <expected-exit> <argv...>: stdout must byte-match $tmp/exp
run(){
  local label="$1" want_rc="$2"; shift 2
  cap "$PY" starter/main.py "$@" >"$tmp/out" 2>"$tmp/err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "$label: exit $rc want $want_rc"
  if [ -s "$tmp/exp" ]; then
    cap cmp -s "$tmp/exp" "$tmp/out" || die "$label: stdout mismatch"
  else
    [ ! -s "$tmp/out" ] || die "$label: expected empty stdout"
  fi
}

# --- new behavior: --json ---
printf '%s\n' '{"items":{"apple":3,"banana":2},"total":5}' >"$tmp/exp"
run json-basic 0 --json apple=3 banana=2

printf '%s\n' '{"items":{},"total":0}' >"$tmp/exp"
run json-empty 0 --json

printf '%s\n' '{"items":{"café":7},"total":7}' >"$tmp/exp"
run json-unicode 0 --json 'café=7'

printf '%s\n' '{"items":{"apple":4},"total":4}' >"$tmp/exp"
run json-duplicate 0 --json apple=3 apple=4

printf '%s\n' '{"items":{"zero":0},"total":0}' >"$tmp/exp"
run json-zero-count 0 --json zero=0

# --- regression: text mode unchanged when flag absent ---
printf '%s\n' 'apple: 3' 'banana: 2' 'TOTAL: 5' >"$tmp/exp"
run text-basic 0 apple=3 banana=2

printf '%s\n' 'TOTAL: 0' >"$tmp/exp"
run text-empty 0

echo "METRIC: PASS feat-01"
exit 0
