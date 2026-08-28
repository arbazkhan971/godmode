#!/usr/bin/env bash
# metric bug-02: main.py must print each order's total from that order's items only (file and stdin input). Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.py ] || die "missing starter/main.py"

# Case 1 (argv): two single-item orders; the second must not include the first's items.
cat > "$tmp/c1.sheet" <<'EOF'
ORDER alpha
mug 2 4.50
ORDER beta
pen 3 1.25
EOF
cat > "$tmp/c1.exp" <<'EOF'
ORDER alpha: $9.00
ORDER beta: $3.75
EOF
"$TO" 10 "$PY" starter/main.py "$tmp/c1.sheet" > "$tmp/c1.out" 2> "$tmp/c1.err" || die "case1: exit $?, want 0"
if ! diff -u "$tmp/c1.exp" "$tmp/c1.out"; then die "case1: stdout mismatch (2-order sheet)"; fi

# Case 2 (argv): three orders; each total must be independent of earlier orders.
cat > "$tmp/c2.sheet" <<'EOF'
ORDER alpha
mug 2 4.50
ORDER beta
pen 3 1.25
ORDER gamma
book 1 12.00
EOF
cat > "$tmp/c2.exp" <<'EOF'
ORDER alpha: $9.00
ORDER beta: $3.75
ORDER gamma: $12.00
EOF
"$TO" 10 "$PY" starter/main.py "$tmp/c2.sheet" > "$tmp/c2.out" 2> "$tmp/c2.err" || die "case2: exit $?, want 0"
if ! diff -u "$tmp/c2.exp" "$tmp/c2.out"; then die "case2: stdout mismatch (3-order sheet)"; fi

# Case 3 (stdin): multi-item first order, single-item second order.
cat > "$tmp/c3.in" <<'EOF'
ORDER web-1042
hoodie 1 20.25
sticker 4 0.75
ORDER web-1043
cap 2 6.50
EOF
cat > "$tmp/c3.exp" <<'EOF'
ORDER web-1042: $23.25
ORDER web-1043: $13.00
EOF
"$TO" 10 "$PY" starter/main.py - < "$tmp/c3.in" > "$tmp/c3.out" 2> "$tmp/c3.err" || die "case3: exit $?, want 0"
if ! diff -u "$tmp/c3.exp" "$tmp/c3.out"; then die "case3: stdout mismatch (stdin sheet)"; fi

echo "METRIC: PASS bug-02"
exit 0
