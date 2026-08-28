# Task perf-05 — Per-line grep sweep is too slow (effort M)

`sigaudit` reports which watchlist signatures occur in a log export.

## Usage

```
bash starter/main.sh PATTERNS HAYSTACK
```

Prints each watchlist signature, one per line in watchlist order, that occurs
anywhere in the export. Exit 0 after a completed sweep, 2 on bad usage.

## Input contract (fixed)

A watchlist signature is a fixed-width 16-character lowercase-hex token.
Watchlist files contain one signature per line, no blank lines, and no
signature is a substring of any other. Exports are plain text, one record per
line, any length.

## Problem

Sweeps are correct but far too slow on real exports (hundreds of signatures
against multi-megabyte logs take many minutes). A full sweep must finish in
well under four seconds on this machine.

## Contract

- Same stdout as the current implementation on the metric's workloads
  (watchlist order preserved, duplicate watchlist entries each reported,
  absent signatures omitted).
- `bash metric.sh` must exit 0 (it checks output correctness and a wall-time
  cap per run).
- Do not modify `metric.sh`.
