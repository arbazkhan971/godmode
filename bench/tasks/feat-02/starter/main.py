#!/usr/bin/env python3
"""libcat - library catalog lister.

Usage: python3 starter/main.py [AUTHOR]
Prints catalog records, optionally narrowed to one exact author.
"""
import argparse
import os

from catalog import filter_by_author, load_records, render

DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "catalog.tsv")


def main(argv=None):
    parser = argparse.ArgumentParser(prog="libcat",
                                     description="List library catalog records.")
    parser.add_argument("author", nargs="?", default=None,
                        help="only records by this exact author")
    args = parser.parse_args(argv)

    records = filter_by_author(load_records(DATA), args.author)
    out = render(records)
    if out:
        print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
