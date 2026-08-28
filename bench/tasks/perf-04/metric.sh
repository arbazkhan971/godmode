#!/usr/bin/env bash
# metric perf-04: salesroll must render the exact expected report for two seeded
# workloads, each run under a 2s wall-time cap. Immutable during benchmark runs
# (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
NODE=$(command -v node) || die "node not found"
TO=$(command -v timeout) || die "timeout not found"

[ -f starter/index.js ] || die "missing starter/index.js"

CAP=2.5    # wall-time cap per run (seconds)
N=160000   # items per workload (starter ~8.4s at this size: >3x cap; solution ~0.5s)

gen(){ # seed cfg items expected
  "$NODE" -e '
    const [seed, N, cfgP, itemsP, expP] = process.argv.slice(1);
    let s = seed >>> 0;
    const rnd = () => { s = (s * 1664525 + 1013904223) >>> 0; return s; };
    const hex = (n) => { let o = ""; for (let i = 0; i < n; i++) o += (rnd() % 16).toString(16); return o; };
    const taxBps = 1250;
    const fs = require("fs");
    fs.writeFileSync(cfgP, JSON.stringify({ report: { title: "Sales Roll " + seed, currency: "USD", columns: ["sku","qty","net","tax","gross"], taxBps } }, null, 1) + "\n");
    const lines = [], exp = [];
    for (let i = 0; i < +N; i++) {
      const sku = "SKU-" + hex(6);
      const qty = 1 + rnd() % 50;
      const unit = 100 + rnd() % 9900;
      const net = qty * unit;
      const tax = Math.floor(net * taxBps / 10000);
      lines.push(sku + "|" + qty + "|" + unit);
      exp.push([sku, qty, net, tax, net + tax].join("|"));
    }
    fs.writeFileSync(itemsP, lines.join("\n") + "\n");
    fs.writeFileSync(expP, "# Sales Roll " + seed + " (USD)\n" + "sku|qty|net|tax|gross\n" + exp.join("\n") + "\n");
  ' "$1" "$N" "$2" "$3" "$4" || die "generator failed"
}

for seed in 1337 4242; do
  gen "$seed" "$tmp/c$seed.cfg" "$tmp/c$seed.items" "$tmp/c$seed.exp" || die "gen seed $seed"
  "$TO" "$CAP" "$NODE" starter/index.js "$tmp/c$seed.cfg" "$tmp/c$seed.items" \
    > "$tmp/c$seed.out" 2> "$tmp/c$seed.err"
  rc=$?
  [ "$rc" -eq 0 ] || die "seed $seed: exit $rc (crash or over ${CAP}s time cap)"
  if ! diff -u "$tmp/c$seed.exp" "$tmp/c$seed.out" > "$tmp/c$seed.diff"; then
    cat "$tmp/c$seed.diff"; die "seed $seed: stdout mismatch"
  fi
done

echo "METRIC: PASS perf-04"
exit 0
