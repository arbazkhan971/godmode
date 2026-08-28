# Tag intersection is too slow (performance-optimization)

## Context

`starter/` contains a CLI helper from a media-library team: given two tag export
files (one tag per line, distinct within each file), it prints the tags present
in both lists, one per line, sorted ascending. The helper runs as part of a
catalog-sync step that recently outgrew its slot because the exports grew. The
output feeds a reconciler that expects the exact current format.

## Task

Bring the helper's runtime for the benchmark workload within the time budget
enforced by `metric.sh`, while producing byte-identical output to the current
behavior. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Node.js standard library only; no third-party packages and no `package.json`.
- Everything must run offline.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
