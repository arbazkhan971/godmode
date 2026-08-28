# Add pagination options (feature-implementation)

## Context
`libcat` lists records from the bundled library catalog file and already
supports narrowing the listing to one exact author with a positional argument.
The catalog has grown, and shell consumers now want to page through the listing
instead of always reading every record at once.

## Task
Add `--limit N` and `--offset M` options with this exact contract:

- Each option takes a non-negative integer; either or both may be omitted.
- `--offset M` skips the first M records of the listing that would otherwise be
  printed (after any author narrowing). If M is at least the listing length,
  nothing is printed.
- `--limit N` prints at most the first N records of the offset-adjusted listing.
  `--limit 0` prints nothing.
- With both options the printed window is records M through M+N-1 of the
  narrowed listing.
- Record order, line format, and the exit code (0) are unchanged, including
  when the window is empty.

Without both flags the output must remain byte-identical to today's behavior,
with or without an author argument.

Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Python standard library only; no third-party packages; no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
