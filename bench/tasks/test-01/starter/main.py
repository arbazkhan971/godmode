#!/usr/bin/env python3
"""Demo CLI: print each CSV data line as a dict keyed by the header row."""
import sys

from csvrows import parse_row


def main(argv):
    if len(argv) != 2:
        print("usage: python3 main.py FILE.csv", file=sys.stderr)
        return 2
    with open(argv[1], "r", encoding="utf-8") as fh:
        lines = [ln.rstrip("\n") for ln in fh if ln.strip()]
    if not lines:
        return 0
    for line in lines[1:]:
        print(parse_row(lines[0], line))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
