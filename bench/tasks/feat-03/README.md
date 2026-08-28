# Add reverse ordering (feature-implementation)

## Context
`roster` prints the bundled contact list as lines sorted by last name and can
narrow the list with a case-insensitive substring search over the full name.
Some consumers want the same listing bottom-up for a newest-first style view.

## Task
Add a `--reverse` flag with this exact contract:

- With `--reverse`, stdout is exactly the same lines the tool would otherwise
  print, in the opposite order: the previous last line becomes the first line.
- The flag composes with the search filter: the narrowed result is what gets
  reversed.
- A result that is already empty stays empty, and the exit code stays 0.

Without `--reverse` the output must remain byte-identical to today's behavior,
with or without a search filter.

Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Node standard library only (plain CommonJS, no packages); no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
