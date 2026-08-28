#!/usr/bin/env bash
# metric sec-03: skucheck must return the correct verdict for every input within the time cap. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/index.js ] || die "missing starter/index.js"

# crafted adversarial value: 28 'a's then '!' ('!' is outside the SKU alphabet
# and forces total backtracking in a nested-quantifier pattern)
payload="aaaaaaaaaaaaaaaaaaaaaaaaaaaa!"

# 1) crafted payload: verdict INVALID, exit 4, inside the cap
out="$($TO 3 "$NODE" starter/index.js "$payload" 2>/dev/null)"; rc=$?
[ "$rc" -eq 4 ] || die "crafted payload: exit $rc, want 4 (124 = timed out)"
[ "$out" = "INVALID" ] || die "crafted payload: verdict '$out', want INVALID"

# 2) benign valid SKUs
for v in widget-3000-pro alpha42 A1-b2-C3; do
  out="$($TO 3 "$NODE" starter/index.js "$v" 2>/dev/null)"; rc=$?
  [ "$rc" -eq 0 ] || die "valid SKU $v: exit $rc, want 0"
  [ "$out" = "VALID" ] || die "valid SKU $v: verdict '$out', want VALID"
done

# 3) benign invalid values: fast, clean rejection
for v in "widget 3000" "-leading" "trailing-" "double--dash"; do
  out="$($TO 3 "$NODE" starter/index.js "$v" 2>/dev/null)"; rc=$?
  [ "$rc" -eq 4 ] || die "invalid value '$v': exit $rc, want 4"
  [ "$out" = "INVALID" ] || die "invalid value '$v': verdict '$out', want INVALID"
done

exit 0
