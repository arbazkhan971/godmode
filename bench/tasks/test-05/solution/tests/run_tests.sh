#!/usr/bin/env bash
# Smoke tests for the miniarch CLI. Run as: bash tests/run_tests.sh
# with the current directory set to the directory that contains tests/.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLI="$ROOT/main.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fail(){ echo "SMOKE FAIL: $1" >&2; exit 1; }
run(){ bash "$CLI" "$@"; }

# usage errors print usage and exit 2
run >/dev/null 2>&1; [ $? -eq 2 ] || fail "no command must exit 2"
run teleport >/dev/null 2>&1; [ $? -eq 2 ] || fail "unknown command must exit 2"
run extract onlyone >/dev/null 2>&1; [ $? -eq 2 ] || fail "extract with one arg must exit 2"

# create packs the named files and list prints them in creation order
printf 'alpha\n' > "$work/a.txt"
printf 'bravo\n' > "$work/b.txt"
( cd "$work" && bash "$CLI" create arch.tar a.txt b.txt ) || fail "create exited nonzero"
[ -f "$work/arch.tar" ] || fail "archive not created"

( cd "$work" && bash "$CLI" list arch.tar ) > "$work/got.txt" || fail "list exited nonzero"
printf 'a.txt\nb.txt\n' > "$work/want.txt"
cmp -s "$work/got.txt" "$work/want.txt" || fail "list output wrong: $(tr '\n' ' ' < "$work/got.txt")"

# extract restores every member with its content, creating the target dir
( cd "$work" && bash "$CLI" extract arch.tar out ) || fail "extract exited nonzero"
[ -f "$work/out/a.txt" ] || fail "out/a.txt missing after extract"
[ -f "$work/out/b.txt" ] || fail "out/b.txt missing after extract"
printf 'alpha\n' > "$work/want_a"
cmp -s "$work/out/a.txt" "$work/want_a" || fail "a.txt content wrong after extract"
printf 'bravo\n' > "$work/want_b"
cmp -s "$work/out/b.txt" "$work/want_b" || fail "b.txt content wrong after extract"

( cd "$work" && bash "$CLI" extract arch.tar fresh/nested ) || fail "extract into missing dir failed"
[ -f "$work/fresh/nested/a.txt" ] || fail "nested extract missing member"

# runtime failures exit nonzero
run list "$work/nope.tar" >/dev/null 2>&1; [ $? -ne 0 ] || fail "list of missing archive must exit nonzero"
( cd "$work" && bash "$CLI" create arch2.tar missing.txt ) >/dev/null 2>&1; [ $? -ne 0 ] || fail "create of missing file must exit nonzero"

echo "smoke: ok"
exit 0
