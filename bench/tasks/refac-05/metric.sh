#!/usr/bin/env bash
# metric refac-05: single make_archive helper (create+verify+report once) used by all 3 archive types; CLI behavior unchanged. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.sh ] || die "missing starter/main.sh"

# --- behavior preservation: expected stdout/exit codes captured from the original starter ---
mkdir -p "$tmp/src/sub"
printf 'alpha\n' >"$tmp/src/a.txt"
printf 'beta\n'  >"$tmp/src/b.txt"
printf 'gamma\n' >"$tmp/src/sub/c.txt"

check(){ # check <expected_rc> <expected_stdout_file> <argv...>
  local want_rc="$1" want_out="$2"; shift 2
  "$TO" 20 bash starter/main.sh "$@" >"$tmp/got.out" 2>"$tmp/got.err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "behavior: 'main.sh $*': exit $rc, want $want_rc"
  cmp -s "$want_out" "$tmp/got.out" || die "behavior: 'main.sh $*': stdout mismatch"
}

printf '%s\n' "archived $tmp/src -> $tmp/bundle.tar.gz (5 entries)" >"$tmp/e1"
printf '%s\n' "archived $tmp/src -> $tmp/snap.tar.bz2 (5 entries)" >"$tmp/e2"
printf '%s\n' "archived $tmp/src -> $tmp/backup.tar (5 entries)" >"$tmp/e3"
printf '%s\n' "error: archive failed: $tmp/nope.tar.gz" >"$tmp/e4"
printf '%s\n' "archived $tmp/src/a.txt -> $tmp/one.tar.bz2 (1 entries)" >"$tmp/e5"
printf '%s\n' 'usage: main.sh {bundle|snapshot|backup} <srcdir> <outfile>' >"$tmp/e6"

check 0 "$tmp/e1" bundle "$tmp/src" "$tmp/bundle.tar.gz"
check 0 "$tmp/e2" snapshot "$tmp/src" "$tmp/snap.tar.bz2"
check 0 "$tmp/e3" backup "$tmp/src" "$tmp/backup.tar"
check 1 "$tmp/e4" bundle "$tmp/missing" "$tmp/nope.tar.gz"
check 0 "$tmp/e5" snapshot "$tmp/src/a.txt" "$tmp/one.tar.bz2"
check 2 "$tmp/e6"
check 2 "$tmp/e6" frobnicate "$tmp/src" "$tmp/x.tar"

# --- structural goal: one shared make_archive helper; every step exists exactly once ---
"$TO" 10 bash -n starter/main.sh || die "structure: starter/main.sh does not parse"
tars=$(grep -o '\btar\b' starter/main.sh | wc -l)
[ "$tars" -eq 2 ] || die "structure: tar must appear exactly twice under starter/ (one create, one listing, inside the shared function), found $tars"
reports=$(grep -o 'archived ' starter/main.sh | wc -l)
[ "$reports" -eq 1 ] || die "structure: 'archived' report line must appear exactly once, found $reports"
errs=$(grep -c 'error: archive failed' starter/main.sh)
[ "$errs" -eq 1 ] || die "structure: 'error: archive failed' must appear exactly once, found $errs"
defs=$(grep -Ec '^[[:space:]]*(function[[:space:]]+make_archive|make_archive[[:space:]]*\(\))' starter/main.sh)
[ "$defs" -eq 1 ] || die "structure: expected exactly 1 'make_archive' definition, found $defs"
uses=$(grep -o 'make_archive' starter/main.sh | wc -l)
[ "$((uses - defs))" -ge 3 ] || die "structure: make_archive must be called from all 3 archive types (found $((uses - defs)) call sites)"

echo "METRIC: PASS refac-05"
exit 0
