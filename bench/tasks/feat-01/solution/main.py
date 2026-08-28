#!/usr/bin/env python3
"""shelf - tiny stockroom inventory reporter.

Usage: python3 starter/main.py [--json] NAME=COUNT [NAME=COUNT ...]
Prints one line per item, then a TOTAL line (or one JSON line with --json).
"""
import argparse

from shelf import parse_items, render_json, render_text


def main(argv=None):
    parser = argparse.ArgumentParser(prog="shelf",
                                     description="Report stockroom item counts.")
    parser.add_argument("--json", action="store_true",
                        help="emit a one-line JSON report instead of text")
    parser.add_argument("items", nargs="*", metavar="NAME=COUNT",
                        help="item name and its non-negative count")
    args = parser.parse_args(argv)

    items = parse_items(args.items)
    if args.json:
        print(render_json(items))
    else:
        print(render_text(items))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
