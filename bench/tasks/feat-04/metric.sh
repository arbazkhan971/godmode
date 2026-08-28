#!/usr/bin/env bash
# metric feat-04: add a --min-count threshold filter to the tagstat stdin aggregator. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout
cap(){ "$TO" 10 "$@"; }

# run <label> <expected-exit> <infile> <argv...>: stdout must byte-match $tmp/exp
run(){
  local label="$1" want_rc="$2" infile="$3"; shift 3
  cap "$NODE" starter/index.js "$@" <"$infile" >"$tmp/out" 2>"$tmp/err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "$label: exit $rc want $want_rc"
  if [ -s "$tmp/exp" ]; then
    cap cmp -s "$tmp/exp" "$tmp/out" || die "$label: stdout mismatch"
  else
    [ ! -s "$tmp/out" ] || die "$label: expected empty stdout"
  fi
}

printf '%s\n' 'error' 'warn' 'error' 'info' 'error' 'warn' 'café' 'info' 'warn' 'naïve' 'naïve' >"$tmp/in-a"
printf '%s\n' 'alpha' '' 'beta' 'alpha' '' >"$tmp/in-b"

# --- regression: no flag, aggregation unchanged ---
printf '%s\n' 'error 3' 'warn 3' 'info 2' 'naïve 2' 'café 1' >"$tmp/exp"
run reg-basic 0 "$tmp/in-a"

printf '%s\n' 'alpha 2' 'beta 1' >"$tmp/exp"
run reg-blanks 0 "$tmp/in-b"

# --- new behavior: --min-count ---
printf '%s\n' 'error 3' 'warn 3' 'info 2' 'naïve 2' >"$tmp/exp"
run min-basic 0 "$tmp/in-a" --min-count 2

printf '%s\n' 'error 3' 'warn 3' >"$tmp/exp"
run min-equal 0 "$tmp/in-a" --min-count 3

printf '%s\n' 'error 3' 'warn 3' 'info 2' 'naïve 2' 'café 1' >"$tmp/exp"
run min-zero 0 "$tmp/in-a" --min-count 0

: >"$tmp/exp"
run min-none 0 "$tmp/in-a" --min-count 4

: >"$tmp/exp"
run min-empty-result 0 "$tmp/in-b" --min-count 3

echo "METRIC: PASS feat-04"
exit 0
