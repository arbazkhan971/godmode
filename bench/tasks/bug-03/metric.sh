#!/usr/bin/env bash
# metric bug-03: index.js must rank players by points, highest first (file and stdin input). Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/index.js ] || die "missing starter/index.js"

# Case 1 (argv): four players, top three; 1-digit vs multi-digit points must order by value.
cat > "$tmp/c1.csv" <<'EOF'
ada,9
bob,250
carol,100
dave,10
EOF
cat > "$tmp/c1.exp" <<'EOF'
250 bob
100 carol
10 dave
EOF
"$TO" 10 "$NODE" starter/index.js "$tmp/c1.csv" > "$tmp/c1.out" 2> "$tmp/c1.err" || die "case1: exit $?, want 0"
if ! diff -u "$tmp/c1.exp" "$tmp/c1.out"; then die "case1: stdout mismatch (4-player file)"; fi

# Case 2 (argv): exactly three players; the full ranking order must follow the points.
cat > "$tmp/c2.csv" <<'EOF'
zoe,9
yan,10
xu,100
EOF
cat > "$tmp/c2.exp" <<'EOF'
100 xu
10 yan
9 zoe
EOF
"$TO" 10 "$NODE" starter/index.js "$tmp/c2.csv" > "$tmp/c2.out" 2> "$tmp/c2.err" || die "case2: exit $?, want 0"
if ! diff -u "$tmp/c2.exp" "$tmp/c2.out"; then die "case2: stdout mismatch (3-player file)"; fi

# Case 3 (stdin): five players, top three; 4-digit points must outrank 3-digit points.
cat > "$tmp/c3.in" <<'EOF'
ivy,1000
hank,999
gil,500
fay,50
ed,5
EOF
cat > "$tmp/c3.exp" <<'EOF'
1000 ivy
999 hank
500 gil
EOF
"$TO" 10 "$NODE" starter/index.js - < "$tmp/c3.in" > "$tmp/c3.out" 2> "$tmp/c3.err" || die "case3: exit $?, want 0"
if ! diff -u "$tmp/c3.exp" "$tmp/c3.out"; then die "case3: stdout mismatch (stdin results)"; fi

echo "METRIC: PASS bug-03"
exit 0
