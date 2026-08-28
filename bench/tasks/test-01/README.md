# CSV row parser test suite (test-writing)

## Context

`starter/` holds a small CSV utility from a data-import tool: `csvrows.py` splits CSV lines into fields (double-quoted sections may contain commas and `""`-escaped quotes; empty fields are preserved) and maps data lines onto a header row as dicts. `main.py` is a thin demo CLI that prints each row as a dict. The module ships with zero test coverage and the team wants a safety net before anyone touches it.

## Task

Write a regression suite under `starter/tests/` (files named `test_*.py`) using the standard library's `unittest` module. Import the implementation as `import csvrows` / `from csvrows import ...`. The suite must demonstrate the module's documented behavior by importing and calling it — including its edge cases — not by reading its source text. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages (plain `unittest`, not pytest).
- Work offline; no network access.
- Put all changes under `starter/tests/`.
- Do not modify `starter/csvrows.py` or `starter/main.py`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
