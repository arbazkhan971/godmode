# Add a JSON output mode (feature-implementation)

## Context
`shelf` is a tiny stockroom inventory CLI. It takes `NAME=COUNT` arguments and
prints a human-readable report. Downstream tooling now wants to consume the same
report from scripts, so the CLI needs a machine-readable mode.

## Task
Add a `--json` flag that switches stdout to JSON with this exact contract:

- Output is a single line (plus one trailing newline) of compact JSON:
  `{"items":{...},"total":N}` — no spaces after `:` or `,`.
- `items` maps each item name to its integer count, in first-occurrence order
  of the names on the command line. A repeated name keeps its first position
  and the last count wins.
- `total` is the integer sum of all counts.
- Non-ASCII characters are emitted literally (UTF-8), never as `\uXXXX` escapes.
- With no items the output is exactly `{"items":{},"total":0}`.
- The exit code is 0 in both modes.

Without `--json` the existing text output must remain byte-identical.

Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Python standard library only; no third-party packages; no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
