#!/usr/bin/env python3
"""libcat - library catalog lister.

Usage: python3 starter/main.py [--limit N] [--offset M] [AUTHOR]
Prints catalog records, optionally narrowed to one exact author and
windowed with --offset/--limit.
"""
import argparse
import os

from catalog import filter_by_author, load_records, render

DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "catalog.tsv")


def main(argv=None):
    parser = argparse.ArgumentParser(prog="libcat",
                                     description="List library catalog records.")
    parser.add_argument("--limit", type=int, default=None, metavar="N",
                        help="print at most N records")
    parser.add_argument("--offset", type=int, default=None, metavar="M",
                        help="skip the first M records")
    parser.add_argument("author", nargs="?", default=None,
                        help="only records by this exact author")
    args = parser.parse_args(argv)

    records = filter_by_author(load_records(DATA), args.author)
    records = records[args.offset:] if args.offset is not None else records
    if args.limit is not None:
        records = records[:args.limit]
    out = render(records)
    if out:
        print(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
