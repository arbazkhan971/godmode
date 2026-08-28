#!/usr/bin/env bash
# metric feat-05: add a --dry-run preview mode to the sweep artifact cleaner. Immutable during benchmark runs (runner SHA256-checksums this file).
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
  cap bash starter/main.sh "$@" >"$tmp/out" 2>"$tmp/err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "$label: exit $rc want $want_rc"
  cap cmp -s "$tmp/exp" "$tmp/out" || die "$label: stdout mismatch"
}

exists(){ [ -f "$1" ] || die "$2: expected file to exist: $1"; }
gone(){ [ ! -f "$1" ] || die "$2: expected file to be deleted: $1"; }

# mksweep <name> [file...]: scratch dir under $tmp, echo its path
mksweep(){
  local d="$tmp/$1"; shift
  cap mkdir -p "$d"
  local f
  for f in "$@"; do : >"$d/$f"; done
  printf '%s' "$d"
}

# --- regression: normal mode unchanged ---
d="$(mksweep r1 a.bak b.bak c.tmp keep.txt)"
printf '%s\n' 'deleted a.bak' 'deleted b.bak' 'deleted c.tmp' >"$tmp/exp"
run reg-basic 0 "$d"
gone "$d/a.bak" reg-basic; gone "$d/b.bak" reg-basic; gone "$d/c.tmp" reg-basic
exists "$d/keep.txt" reg-basic

d="$(mksweep r2 keep.txt notes.md)"
printf '%s\n' 'nothing to do' >"$tmp/exp"
run reg-none 0 "$d"
exists "$d/keep.txt" reg-none; exists "$d/notes.md" reg-none

# --- new behavior: --dry-run ---
d="$(mksweep d1 a.bak b.bak c.tmp keep.txt)"
printf '%s\n' 'would delete a.bak' 'would delete b.bak' 'would delete c.tmp' >"$tmp/exp"
run dry-basic 3 --dry-run "$d"
exists "$d/a.bak" dry-basic; exists "$d/b.bak" dry-basic
exists "$d/c.tmp" dry-basic; exists "$d/keep.txt" dry-basic

d="$(mksweep d2 z.bak m.bak b.tmp a.tmp)"
printf '%s\n' 'would delete m.bak' 'would delete z.bak' 'would delete a.tmp' 'would delete b.tmp' >"$tmp/exp"
run dry-order 3 --dry-run "$d"
exists "$d/z.bak" dry-order; exists "$d/b.tmp" dry-order

d="$(mksweep d3 résumé.tmp)"
printf '%s\n' 'would delete résumé.tmp' >"$tmp/exp"
run dry-unicode 3 --dry-run "$d"
exists "$d/résumé.tmp" dry-unicode

d="$(mksweep d4 keep.txt notes.md)"
printf '%s\n' 'nothing to do' >"$tmp/exp"
run dry-none 3 --dry-run "$d"
exists "$d/keep.txt" dry-none; exists "$d/notes.md" dry-none

d="$(mksweep d5)"
printf '%s\n' 'nothing to do' >"$tmp/exp"
run dry-empty 3 --dry-run "$d"

echo "METRIC: PASS feat-05"
exit 0
