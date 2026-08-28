# Add a minimum-count filter (feature-implementation)

## Context
`tagstat` aggregates tag names piped on stdin: every nonblank input line is one
occurrence of a tag. It prints one line per distinct tag as `TAG COUNT`, sorted
by descending count with ties in ascending tag order. Report readers now want
to hide low-volume noise straight from the tool.

## Task
Add a `--min-count N` option with this exact contract:

- N is a non-negative integer; the option may be omitted.
- Only tags whose aggregated count is at least N are printed; a tag whose
  count is exactly N is still printed.
- The sort order and line format are unchanged; filtering applies to the
  aggregated counts, not to raw input lines.
- If no tag meets the threshold, print nothing (empty output) and still exit 0.
- `--min-count 0` produces exactly the same output as omitting the option.

Without the option the output must remain byte-identical to today's behavior.

Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Node standard library only (plain CommonJS, no packages); no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
