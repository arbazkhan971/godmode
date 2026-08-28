# perf-04 solution

## Fix
`starter/lib/render.js` called `loadConfig(configPath)` once per item inside the
render loop (one readFileSync + JSON.parse per record). The fix hoists a single
`loadConfig` call before the loop and reuses the parsed rules for the header
and every item. Output is byte-identical: the config file is never mutated
during a run, so per-item re-parsing always produced the same rules.

## Measured margins (2026-08-28, node v24.19.0, idle box)
- Starter, N=160000: ~8.4 s per seed (≈ 3.4x cap; killed at the 2.5 s cap by
  `timeout` → metric exit 124). Linear per-item cost ≈ 51 µs.
- Solution, N=160000: ~0.45 s per seed idle (~cap/5.5); ~1.4 s under a
  simulated 4-lane load (~cap/1.8).
- Metric totals: FAIL path ~3.3 s (dies on seed 1337), PASS path ~2.6 s.
  Commands: pristine ws `bash metric.sh` → exit 1; solution overlay → exit 0.
- Earlier sizing probes on /usr/bin/node v20 measured ~9.8 ms/item; the shipped
  sizing uses the box's default node (v24) numbers above.

## Generator
Seeded LCG (mul 1664525, add 1013904223); seeds 1337 and 4242; config
taxBps=1250; SKUs are `SKU-` + 6 hex chars; qty 1-50; unit 100-9999 cents.
Expected output is computed inside the generator from the same math the report
implements (`net = qty*unit`, `tax = floor(net*taxBps/10000)`), never by
running the starter.
