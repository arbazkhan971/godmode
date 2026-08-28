#!/usr/bin/env python3
"""Demo CLI: print the inclusive day count for an ISO date range."""
import sys

from daterange import days_between


def main(argv):
    if len(argv) != 3:
        print("usage: python3 main.py START END", file=sys.stderr)
        return 2
    print(days_between(argv[1], argv[2]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
