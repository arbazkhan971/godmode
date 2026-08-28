#!/usr/bin/env python3
"""Shiplog reporter: print each event-log entry and the entry count.

Usage:
  main.py LOGFILE    read the log from LOGFILE
  main.py -          read the log from stdin
"""
import sys

from loglib import parse_entries


def read_source(arg):
    """Return the raw log text for a path, or stdin when arg is '-'."""
    if arg == "-":
        return sys.stdin.read()
    with open(arg, "r", encoding="utf-8") as fh:
        return fh.read()


def main(argv):
    if len(argv) != 2:
        print("usage: main.py LOGFILE|-", file=sys.stderr)
        return 2
    try:
        text = read_source(argv[1])
    except OSError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1
    entries = parse_entries(text)
    for stamp, level, msg in entries:
        print(f"{stamp} [{level}] {msg}")
    print(f"total: {len(entries)}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
