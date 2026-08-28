#!/usr/bin/env bash
# metric feat-03: add a --reverse ordering flag to the roster contact list tool. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout
cap(){ "$TO" 10 "$@"; }

# run <label> <expected-exit> <argv...>: stdout must byte-match $tmp/exp
run(){
  local label="$1" want_rc="$2"; shift 2
  cap "$NODE" starter/index.js "$@" >"$tmp/out" 2>"$tmp/err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "$label: exit $rc want $want_rc"
  if [ -s "$tmp/exp" ]; then
    cap cmp -s "$tmp/exp" "$tmp/out" || die "$label: stdout mismatch"
  else
    [ ! -s "$tmp/out" ] || die "$label: expected empty stdout"
  fi
}

all_sorted(){
  printf '%s\n' \
    'Curie, Pierre <pierre@example.net>' \
    'Curie, Marie <marie@example.net>' \
    'Dijkstra, Edsger <edsger@example.net>' \
    'Hopper, Grace <grace@example.net>' \
    'Johnson, Katherine <katherine@example.net>' \
    'Knuth, Donald <donald@example.net>' \
    'Lane, Zoë <zoe@example.net>' \
    'Liskov, Barbara <barbara@example.net>' \
    'Lovelace, Ada <ada@example.net>' \
    'Perlman, Radia <radia@example.net>' \
    'Turing, Alan <alan@example.net>'
}

# --- regression: default and search output unchanged ---
all_sorted >"$tmp/exp"
run reg-default 0

printf '%s\n' \
  'Curie, Pierre <pierre@example.net>' \
  'Curie, Marie <marie@example.net>' >"$tmp/exp"
run reg-search-cu 0 --search cu

: >"$tmp/exp"
run reg-search-nomatch 0 --search zzz

# --- new behavior: --reverse ---
printf '%s\n' \
  'Turing, Alan <alan@example.net>' \
  'Perlman, Radia <radia@example.net>' \
  'Lovelace, Ada <ada@example.net>' \
  'Liskov, Barbara <barbara@example.net>' \
  'Lane, Zoë <zoe@example.net>' \
  'Knuth, Donald <donald@example.net>' \
  'Johnson, Katherine <katherine@example.net>' \
  'Hopper, Grace <grace@example.net>' \
  'Dijkstra, Edsger <edsger@example.net>' \
  'Curie, Marie <marie@example.net>' \
  'Curie, Pierre <pierre@example.net>' >"$tmp/exp"
run reverse-full 0 --reverse

printf '%s\n' \
  'Curie, Marie <marie@example.net>' \
  'Curie, Pierre <pierre@example.net>' >"$tmp/exp"
run reverse-search-cu 0 --search cu --reverse

printf '%s\n' 'Knuth, Donald <donald@example.net>' >"$tmp/exp"
run reverse-single 0 --search knuth --reverse

: >"$tmp/exp"
run reverse-empty 0 --search zzz --reverse

echo "METRIC: PASS feat-03"
exit 0
