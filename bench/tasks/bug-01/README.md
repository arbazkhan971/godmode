# Shiplog entry reporter (bug-fixing)

## Context

`starter/` holds a tiny ops tool used by the on-call rotation: `main.py` reads a structured event log and prints a reviewable summary, with parsing helpers in `loglib.py`. Before escalating an incident, the engineer on duty runs it over the deploy window's log to see what the service reported.

## Task

Make the tool summarize logs accurately for both file and stdin input: for any input it is given, every entry present in the log must be reported and the printed total must equal the number of entries in that input. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages.
- Work offline; no network access.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
