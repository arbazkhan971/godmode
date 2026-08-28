# Word-frequency counter is too slow (performance-optimization)

## Context

`starter/` contains a small CLI tool from a content-analytics team: it reads a
corpus of tokens (one per line) and prints a frequency table — every distinct
word with its count, most frequent first, ties in alphabetical order. The tool
feeds a batch pipeline that has started missing its processing window as corpora
grew. Its output format is frozen; downstream consumers diff it verbatim.

## Task

Bring the tool's runtime for the benchmark workload within the time budget
enforced by `metric.sh`, while producing byte-identical output to the current
behavior. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Standard library only; no third-party packages.
- Everything must run offline.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
