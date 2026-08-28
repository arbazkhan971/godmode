#!/usr/bin/env bash
# metric feat-02: add --limit/--offset pagination to the libcat catalog lister. Immutable during benchmark runs (runner SHA256-checksums this file).
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

all_lines(){
  printf '%s\n' \
    'Neuromancer (1984) by William Gibson' \
    'Count Zero (1986) by William Gibson' \
    'Mona Lisa Overdrive (1988) by William Gibson' \
    'Pride and Prejudice (1813) by Jane Austen' \
    'Emma (1815) by Jane Austen' \
    'Persuasion (1818) by Jane Austen' \
    'Germinal (1885) by Émile Zola' \
    'Nana (1880) by Émile Zola' \
    'The Left Hand of Darkness (1969) by Ursula K. Le Guin' \
    'Dune (1965) by Frank Herbert' \
    'Dune Messiah (1969) by Frank Herbert' \
    'The Dispossessed (1974) by Ursula K. Le Guin'
}

# --- regression: no flags, full listing unchanged ---
all_lines >"$tmp/exp"
run reg-full 0

printf '%s\n' \
  'Pride and Prejudice (1813) by Jane Austen' \
  'Emma (1815) by Jane Austen' \
  'Persuasion (1818) by Jane Austen' >"$tmp/exp"
run reg-author 0 'Jane Austen'

# --- new behavior: pagination ---
printf '%s\n' \
  'Neuromancer (1984) by William Gibson' \
  'Count Zero (1986) by William Gibson' \
  'Mona Lisa Overdrive (1988) by William Gibson' \
  'Pride and Prejudice (1813) by Jane Austen' >"$tmp/exp"
run limit-4 0 --limit 4

printf '%s\n' \
  'Dune Messiah (1969) by Frank Herbert' \
  'The Dispossessed (1974) by Ursula K. Le Guin' >"$tmp/exp"
run offset-10 0 --offset 10

printf '%s\n' \
  'Mona Lisa Overdrive (1988) by William Gibson' \
  'Pride and Prejudice (1813) by Jane Austen' \
  'Emma (1815) by Jane Austen' >"$tmp/exp"
run window-2-3 0 --offset 2 --limit 3

: >"$tmp/exp"
run offset-past-end 0 --offset 99

: >"$tmp/exp"
run limit-0 0 --limit 0

all_lines >"$tmp/exp"
run limit-oversized 0 --limit 99

printf '%s\n' 'Nana (1880) by Émile Zola' >"$tmp/exp"
run author-window-unicode 0 --offset 1 --limit 1 'Émile Zola'

echo "METRIC: PASS feat-02"
exit 0
