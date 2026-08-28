#!/usr/bin/env bash
# metric sec-05: logfilter must never execute a hostile test while documented conditionals keep selecting the same lines. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.sh ] || die "missing starter/main.sh"

log="$tmp/app.log"
cat > "$log" <<'EOF'
2024-01-05T10:00:00Z INFO  boot ok
2024-01-05T10:00:01Z WARN  disk usage at 81%
2024-01-05T10:00:02Z ERROR timeout talking to upstream
2024-01-05T10:00:03Z INFO  retry scheduled
2024-01-05T10:00:04Z ERROR retry abandoned
EOF

# hostile tests must be rejected: nonzero exit, diagnostic, no stdout, no side effects
mk="$tmp/marker"
reject() { # reject <test-string>
  local expr=$1 out rc
  rm -f "$mk"
  out="$($TO 5 bash starter/main.sh "$expr" "$log" 2>"$tmp/err")"; rc=$?
  [ "$rc" -eq 2 ] || die "hostile test accepted: exit $rc, want 2 (expr: $expr)"
  [ -z "$out" ] || die "hostile test printed lines to stdout (expr: $expr)"
  [ -s "$tmp/err" ] || die "hostile test gave no diagnostic (expr: $expr)"
  [ ! -e "$mk" ] || die "hostile test executed code: $mk was created (expr: $expr)"
}
reject "x; touch $mk"
reject "\$(touch $mk)"
reject "\`touch $mk\`"
reject "[[ \$line == *x* ]] || touch $mk"

# benign 1: glob match keeps exactly the ERROR lines
want="$tmp/want1"
grep ' ERROR ' "$log" > "$want" 2>/dev/null
out="$($TO 5 bash starter/main.sh '[[ $line == *ERROR* ]]' "$log" 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign 1: exit $rc, want 0"
[ "$out" = "$(cat "$want")" ] || die "benign 1: wrong lines kept: $out"

# benign 2: numeric test joined with a negated glob
want="$tmp/want2"
sed -n '4p' "$log" > "$want"
out="$($TO 5 bash starter/main.sh '[[ $n -ge 3 && $line != *ERROR* ]]' "$log" 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign 2: exit $rc, want 0"
[ "$out" = "$(cat "$want")" ] || die "benign 2: wrong lines kept: $out"

# benign 3: case-sensitive substring glob
want="$tmp/want3"
grep 'retry' "$log" > "$want" 2>/dev/null
out="$($TO 5 bash starter/main.sh '[[ $line == *retry* ]]' "$log" 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign 3: exit $rc, want 0"
[ "$out" = "$(cat "$want")" ] || die "benign 3: wrong lines kept: $out"

# benign 4: stdin mode still works with a numeric test
out="$(printf 'alpha\nbeta\n' | $TO 5 bash starter/main.sh '[[ $n -le 1 ]]' 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign 4: exit $rc, want 0"
[ "$out" = 'alpha' ] || die "benign 4: wrong stdin result: $out"

# usage error still fails cleanly
out="$($TO 5 bash starter/main.sh 2>/dev/null)"; rc=$?
[ "$rc" -eq 2 ] || die "usage: exit $rc, want 2"
[ -z "$out" ] || die "usage: unexpected stdout"

exit 0
