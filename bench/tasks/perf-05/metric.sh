#!/usr/bin/env bash
# metric perf-05: sigaudit must report exactly the occurring watchlist
# signatures for two seeded workloads, each sweep under a 4s wall-time cap.
# Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
NODE=$(command -v node) || die "node not found"
TO=$(command -v timeout) || die "timeout not found"

[ -f starter/main.sh ] || die "missing starter/main.sh"

CAP=4          # wall-time cap per sweep (seconds)
NABS=400       # absent signatures (starter full-scans each: ~12s total = 3x cap)
NEMB=60        # embedded signatures
NLINES=200000  # export lines (~50MB)

gen(){ # seed patterns haystack expected
  "$NODE" -e '
    const [seed, nAbs, nEmb, nLines, patP, hayP, expP] = process.argv.slice(1);
    let s = +seed >>> 0;
    const rnd = () => { s = (s * 1664525 + 1013904223) >>> 0; return s; };
    const hex = (n) => { let o = ""; for (let i = 0; i < n; i++) o += (rnd() % 16).toString(16); return o; };
    const fs = require("fs");
    const total = nAbs + nEmb;
    const pats = [];
    for (let i = 0; i < total; i++) pats.push(hex(16));
    // embedded set = last nEmb patterns (watchlist order preserved)
    const embedded = new Set(pats.slice(nAbs));
    // watchlist = all patterns + a duplicated embedded sig + a duplicated absent sig
    const watch = pats.slice();
    watch.push(pats[nAbs], pats[0]);
    const expected = watch.filter((p) => embedded.has(p));
    fs.writeFileSync(patP, watch.join("\n") + "\n");
    // haystack: nLines lines of hex tokens; embedded sigs placed at start/end/mid/full-line
    const tok = () => hex(12);
    const lines = new Array(nLines);
    for (let i = 0; i < nLines; i++) {
      let l = "";
      for (let t = 0; t < 20; t++) l += (t ? " " : "") + tok();
      lines[i] = l;
    }
    const emb = pats.slice(nAbs);
    lines[7] = emb[0] + " " + tok() + " " + tok();            // line start
    lines[11] = tok() + " " + tok() + " " + emb[1];           // line end
    lines[13] = emb[2];                                       // full-line signature
    lines[nLines - 1] = tok() + " " + emb[3] + " " + tok();   // last line, mid
    for (let k = 4; k < emb.length; k++) {
      const at = 20 + Math.floor(rnd() % (nLines - 40));
      const parts = lines[at].split(" ");
      parts.splice(1 + Math.floor(rnd() % (parts.length - 2)), 0, emb[k]);
      lines[at] = parts.join(" ");
    }
    fs.writeFileSync(hayP, lines.join("\n") + "\n");
    fs.writeFileSync(expP, expected.join("\n") + "\n");
  ' "$1" "$NABS" "$NEMB" "$NLINES" "$2" "$3" "$4" || die "generator failed"
}

for seed in 1337 4242; do
  gen "$seed" "$tmp/p$seed" "$tmp/h$seed" "$tmp/e$seed" || die "gen seed $seed"
  "$TO" "$CAP" bash starter/main.sh "$tmp/p$seed" "$tmp/h$seed" \
    > "$tmp/o$seed.out" 2> "$tmp/o$seed.err"
  rc=$?
  [ "$rc" -eq 0 ] || die "seed $seed: exit $rc (crash or over ${CAP}s time cap)"
  if ! diff -u "$tmp/e$seed" "$tmp/o$seed.out" > "$tmp/o$seed.diff"; then
    cat "$tmp/o$seed.diff"; die "seed $seed: stdout mismatch"
  fi
done

echo "METRIC: PASS perf-05"
exit 0
