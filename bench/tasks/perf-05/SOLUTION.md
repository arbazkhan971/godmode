# perf-05 solution

## Fix
`starter/lib/audit.sh` ran one `grep -qF` per watchlist signature — a full
export scan per signature (O(signatures x haystack) I/O). The fix is one
pass: `grep -oF -f PATTERNS HAYSTACK | sort -u | grep -Fxf - PATTERNS` —
collect every matched fixed string in a single scan, then replay the watchlist
keeping the signatures that were seen (watchlist order and duplicates
preserved by the final `grep -Fxf` pass over the watchlist file).

## Semantic equivalence (why the one-pass is safe here)
The input contract pins signatures as fixed-width 16-char lowercase-hex tokens
with no blank lines and no substring relationships between signatures. That
removes the two ways `grep -oF -f` could diverge from per-signature `grep
-qF`: overlapping/substring matches and blank patterns matching everything.
`sort -u` only dedups the candidate set; the watchlist replay decides output
order and duplicate emission.

## Measured margins (2026-08-28, idle box)
- Workload per seed: 462-line watchlist (400 absent + 60 embedded + 2
  duplicates), 200,000-line ~50MB export; edge placements: line start, line
  end, full-line signature, last-line mid, plus ~56 random mid-line slots.
- Starter: >4 s per seed (killed at the cap; projected ~12 s ≈ 3x cap).
- Solution: ~1.6 s per seed (~cap/2.5; leaves ~2.4x headroom).
- Metric totals: FAIL path ~8.8 s (dies on seed 1337), PASS path ~10.3 s
  (dominated by the two ~3.5 s generator passes).
  Commands: pristine ws `bash metric.sh` → exit 1; solution overlay → exit 0.
- Expected output is computed inside the generator (the embedded set is known
  at generation time), never by running the starter or solution.

## Generator
Seeded LCG (mul 1664525, add 1013904223); seeds 1337 and 4242; node -e
generator (the metric harness may use any tool on the box; the task under
test remains pure bash+grep).
