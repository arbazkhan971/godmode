# Factor out the repeated archive steps (refactoring)

## Context

`starter/` holds `archctl`, a tiny bash CLI that packs a source tree into one of three archive types: `bundle` (gzip), `snapshot` (bzip2), and `backup` (plain tar). Each command repeats the same create → verify → report block, differing only in the tar flags, so a fix applied to one copy keeps drifting out of the other two.

## Task

Factor the repeated block out of the three commands into one shared function `make_archive`, invoked once per archive type with whatever differs (the create and list flags). After the refactor each step must exist exactly once under `starter/`: `grep -o '\btar\b' starter/main.sh | wc -l` must output 2 (one create, one listing, inside the shared function), and the `archived` report line and the `error: archive failed` message must each appear exactly once. The refactor is purely mechanical: CLI behavior (stdout and exit codes) must stay exactly the same.

Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Bash and standard coreutils/tar only; no new dependencies.
- Work offline; no network access.
- Put all changes under `starter/`; keep the CLI entrypoint at `starter/main.sh`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
