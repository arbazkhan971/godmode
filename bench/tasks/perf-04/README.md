# Task perf-04 — Config re-parsed for every item (effort L)

`salesroll` renders a per-item sales report under a fixed set of config rules.

## Usage

```
node starter/index.js CONFIG.json ITEMS.txt
```

`ITEMS.txt` has one record per line, `SKU|QTY|UNIT_CENTS` (blank lines ignored,
input order preserved). The report goes to stdout: a header line pair followed
by one line per item. Exit 0 on success, 2 on bad usage.

## Problem

Rendering is correct but far too slow on real exports (tens of thousands of
records take minutes). Reports must render in well under a couple of seconds
on this machine.

## Contract

- Same stdout as the current implementation on the metric's workloads
  (header, per-item lines in input order, exact field values).
- `bash metric.sh` must exit 0 (it checks both output correctness and a
  wall-time cap per run).
- Do not modify `metric.sh`.
