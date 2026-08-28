# Date-range calculator test suite (test-writing)

## Context

`starter/` contains a scheduling helper: `daterange.py` works with inclusive day ranges given as ISO `YYYY-MM-DD` strings — counting the days in a range (a single day counts as 1), listing every day of a range in order, and finding a month's last day for `YYYY-MM` inputs. `main.py` is a small demo CLI that prints the day count for a range. There are no tests yet and a refactor is scheduled.

## Task

Write a regression suite under `starter/tests/` (files named `test_*.py`) using the standard library's `unittest` module. Import the implementation as `import daterange` / `from daterange import ...`. The suite must demonstrate the module's documented behavior by importing and calling it — including boundary and calendar edge cases (month lengths, leap years) — not by reading its source text. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages (plain `unittest`, not pytest).
- Work offline; no network access.
- Put all changes under `starter/tests/`.
- Do not modify `starter/daterange.py` or `starter/main.py`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
