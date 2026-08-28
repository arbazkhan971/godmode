# Extract the shared validation helper (refactoring)

## Context

`starter/` holds `rosterctl`, a tiny front-desk CLI for the club roster: `main.py` dispatches the `add` and `update` commands, which live in `members.py` and operate on an in-memory roster. The two commands were written six months apart and each carries its own copy of the member-spec validation rules.

## Task

Extract the member-spec validation that is currently duplicated inside `add_member` and `update_member` (`starter/members.py`) into a single shared helper `validate_member(name, email)` that both commands call, instead of each re-implementing the checks. The refactor is purely mechanical: CLI behavior (stdout and exit codes) must stay exactly the same.

Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages.
- Work offline; no network access.
- Put all changes under `starter/`; keep the CLI entrypoint at `starter/main.py`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
