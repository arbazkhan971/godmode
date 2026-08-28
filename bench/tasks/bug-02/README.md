# Checkout reconciliation (bug-fixing)

## Context

`starter/` is a small end-of-shift reconciliation tool: `main.py` splits an order sheet into named orders and prints each order's total, with cart helpers in `orderkit.py`. Support runs it over the day's sheet to balance each register drawer before closing.

## Task

Make the tool compute each order's total independently for both file and stdin input: the line printed for an order must reflect only that order's items, regardless of what orders appear before it in the sheet. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages.
- Work offline; no network access.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
