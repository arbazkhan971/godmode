# Archiver CLI smoke tests (test-writing)

## Context

`starter/main.sh` is the tiny archiver CLI behind a backup script: `create ARCHIVE FILE...` packs the named files (kept under the names given on the command line) into a new tar archive, `extract ARCHIVE DIR` unpacks every member into DIR (created if missing), and `list ARCHIVE` prints one member name per line in creation order. Bad usage — a missing or unknown command, or wrong argument counts — prints usage to stderr and exits 2; runtime failures like a missing archive exit 1. The CLI has no tests and ships to users next week.

## Task

Write a smoke-test suite under `starter/tests/` whose single entry point is `starter/tests/run_tests.sh`. The script will be run as `bash tests/run_tests.sh` with the current directory set to the directory containing `tests/`; invoke the CLI from there (for example `bash main.sh list ARCHIVE`, or from a fixture directory via its absolute path). Build fixtures in a private temp directory (`mktemp -d`), exercise the CLI end to end — create/list/extract round-trips, extracted file contents, and exit codes — and exit 0 only if every check passes. Archives are not byte-reproducible, so assert on member names and file contents, not archive bytes. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Bash and standard coreutils/tar only; work offline; no network access.
- Put all changes under `starter/tests/`.
- Do not modify `starter/main.sh`.
- Clean up every temp directory your script creates.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
