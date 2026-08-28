# Split the god-function (refactoring)

## Context

`starter/` holds `invocli`, which renders a monthly invoice per customer from a fixed in-house ledger (`ledger.py`). All the work sits in one long function, `build_invoice` in `starter/main.py`, which parses arguments, validates them, selects ledger rows, computes totals, and renders the invoice. Every change to invoicing has to be threaded through this single block, and reviewers keep approving edits to the wrong half of it.

## Task

Refactor `starter/main.py` so the invoice pipeline is decomposed into focused named functions: under `starter/` there must be at least 5 named functions in total, and no function may span more than 20 lines (measured from its `def` line to its last body line). The refactor is purely mechanical: CLI behavior (stdout and exit codes) must stay exactly the same.

Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages.
- Work offline; no network access.
- Put all changes under `starter/`; keep the CLI entrypoint at `starter/main.py`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
