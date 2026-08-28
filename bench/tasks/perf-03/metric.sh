#!/usr/bin/env bash
# metric perf-03: tagmeet finishes the 34k x 26k tag-list workload within the 2s cap with the exact expected intersection. Immutable during benchmark runs (runner SHA256-checksums this file).
# Margins measured on authoring host (node 20, 4-core): pristine starter ~6.6s, reference solution ~0.1s, cap 2s.
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

cat > "$tmp/gen_expect.js" <<'JSEOF'
'use strict';
const fs = require('fs');

const A_LEN = 34000;
const B_LEN = 26000;
const OVERLAP = 6000;

const b = [];
for (let i = 0; i < B_LEN; i++) b.push('b' + String(i).padStart(6, '0'));
const a = [];
for (let i = 0; i < OVERLAP; i++) a.push(b[i * 4]);
for (let i = 0; a.length < A_LEN; i++) a.push('a' + String(i).padStart(6, '0'));

fs.writeFileSync(process.argv[2], a.join('\n') + '\n', 'utf8');
fs.writeFileSync(process.argv[3], b.join('\n') + '\n', 'utf8');
const setB = new Set(b);
const expected = a.filter((tag) => setB.has(tag)).sort();
fs.writeFileSync(process.argv[4], expected.map((tag) => tag + '\n').join(''), 'utf8');
JSEOF
"$NODE" "$tmp/gen_expect.js" "$tmp/a.txt" "$tmp/b.txt" "$tmp/expected.txt" || die "input generator failed"

"$TO" 2 "$NODE" starter/index.js "$tmp/a.txt" "$tmp/b.txt" > "$tmp/out.txt" 2> "$tmp/err.txt"
rc=$?
[ "$rc" -eq 124 ] && die "too slow: killed by 2s cap"
[ "$rc" -eq 0 ] || die "starter/index.js exited rc=$rc"

cmp -s "$tmp/out.txt" "$tmp/expected.txt" || die "output does not match expected intersection"
echo "METRIC: PASS"
exit 0
