# Add a dry-run mode (feature-implementation)

## Context
`sweep` is a housekeeping script that deletes stale build artifacts — every
`*.bak` and `*.tmp` file directly inside a given directory — reporting each
removal as it happens. Operators want to preview a sweep before trusting it.

## Task
Add a `--dry-run` flag with this exact contract:

- Usage becomes `main.sh [--dry-run] DIR`.
- In dry-run the script performs the same scan but deletes nothing: it prints
  `would delete <name>` for each match instead of `deleted <name>`, and every
  scanned file must still exist afterwards.
- In dry-run the exit code is 3.
- When nothing matches, both modes print exactly `nothing to do` (and nothing
  else); the exit codes stay 0 (normal) and 3 (dry-run).
- Matching and reporting order are unchanged: `*.bak` files first, then `*.tmp`
  files, each group in ascending name order.

Without the flag the script must behave exactly as today, including actually
deleting the matches.

Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Standard bash + coreutils only; no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
