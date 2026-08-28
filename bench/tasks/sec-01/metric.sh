#!/usr/bin/env bash
# metric sec-01: miniserve must serve in-root files exactly and refuse any request that escapes the root. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.py ] || die "missing starter/main.py"

fx="$tmp/fixture"
mkdir -p "$fx/root/docs" "$fx/outside"
printf 'Mini-serve document root.\nSecond line stays intact.\n' > "$fx/root/docs/readme.txt"
printf 'Release notes for v3.\n' > "$fx/root/notes.txt"
printf 'TOPSECRET-9f31-do-not-leak\n' > "$fx/secret.txt"
printf 'ABS-MARKER-7c02-outside-root\n' > "$fx/outside/abs.txt"

# 1) benign relative path serves exact content
out="$($TO 10 "$PY" starter/main.py cat "$fx/root" docs/readme.txt 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign docs/readme.txt: exit $rc, want 0"
[ "$out" = "Mini-serve document root.
Second line stays intact." ] || die "benign docs/readme.txt: wrong content"

# 2) second benign path serves exact content
out="$($TO 10 "$PY" starter/main.py cat "$fx/root" notes.txt 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign notes.txt: exit $rc, want 0"
[ "$out" = "Release notes for v3." ] || die "benign notes.txt: wrong content"

# 3) traversal payload ../secret.txt must be refused without leaking
out="$($TO 10 "$PY" starter/main.py cat "$fx/root" ../secret.txt 2>/dev/null)"; rc=$?
[ "$rc" -ne 0 ] || die "traversal ../secret.txt: served with exit 0, want nonzero"
case "$out" in *TOPSECRET-9f31-do-not-leak*) die "traversal ../secret.txt: secret leaked";; esac

# 4) absolute-path payload must be refused without leaking
out="$($TO 10 "$PY" starter/main.py cat "$fx/root" "$fx/outside/abs.txt" 2>/dev/null)"; rc=$?
[ "$rc" -ne 0 ] || die "absolute-path payload: served with exit 0, want nonzero"
case "$out" in *ABS-MARKER-7c02-outside-root*) die "absolute-path payload: content leaked";; esac

# 5) missing in-root file still fails cleanly
out="$($TO 10 "$PY" starter/main.py cat "$fx/root" missing.txt 2>/dev/null)"; rc=$?
[ "$rc" -ne 0 ] || die "missing.txt: exit 0, want nonzero"
[ -z "$out" ] || die "missing.txt: unexpected stdout"

echo "METRIC: PASS sec-01"
exit 0
