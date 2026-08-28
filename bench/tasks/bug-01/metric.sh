#!/usr/bin/env bash
# metric bug-01: main.py must report every log entry (file and stdin input) with an exact total. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.py ] || die "missing starter/main.py"

# Case 1 (argv): three-entry log; the final entry must be reported.
cat > "$tmp/c1.log" <<'EOF'
2024-01-01T00:00:01Z|INFO|service started
2024-01-01T00:00:04Z|WARN|disk usage 91%
2024-01-01T00:00:09Z|ERROR|probe timeout
EOF
cat > "$tmp/c1.exp" <<'EOF'
2024-01-01T00:00:01Z [INFO] service started
2024-01-01T00:00:04Z [WARN] disk usage 91%
2024-01-01T00:00:09Z [ERROR] probe timeout
total: 3
EOF
"$TO" 10 "$PY" starter/main.py "$tmp/c1.log" > "$tmp/c1.out" 2> "$tmp/c1.err" || die "case1: exit $?, want 0"
if ! diff -u "$tmp/c1.exp" "$tmp/c1.out"; then die "case1: stdout mismatch (3-entry log)"; fi

# Case 2 (argv): single-entry log.
printf '2024-02-29T12:00:00Z|INFO|heartbeat\n' > "$tmp/c2.log"
printf '2024-02-29T12:00:00Z [INFO] heartbeat\ntotal: 1\n' > "$tmp/c2.exp"
"$TO" 10 "$PY" starter/main.py "$tmp/c2.log" > "$tmp/c2.out" 2> "$tmp/c2.err" || die "case2: exit $?, want 0"
if ! diff -u "$tmp/c2.exp" "$tmp/c2.out"; then die "case2: stdout mismatch (1-entry log)"; fi

# Case 3 (stdin): blank line mid-log; the entry after it must still count.
printf '2024-03-01T08:00:00Z|INFO|job queued\n\n2024-03-01T08:00:03Z|INFO|job done\n' > "$tmp/c3.in"
printf '2024-03-01T08:00:00Z [INFO] job queued\n2024-03-01T08:00:03Z [INFO] job done\ntotal: 2\n' > "$tmp/c3.exp"
"$TO" 10 "$PY" starter/main.py - < "$tmp/c3.in" > "$tmp/c3.out" 2> "$tmp/c3.err" || die "case3: exit $?, want 0"
if ! diff -u "$tmp/c3.exp" "$tmp/c3.out"; then die "case3: stdout mismatch (stdin log)"; fi

echo "METRIC: PASS bug-01"
exit 0
