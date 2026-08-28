#!/usr/bin/env python3
"""wfreq -- word-frequency reporter.

Usage: python3 main.py WORDS_FILE
Prints every distinct word with its count, most frequent first.
"""
import sys

import wfreq_io


def tally(tokens):
    """Count occurrences of each token."""
    counts = {}
    for tok in tokens:
        counts[tok] = counts.get(tok, 0) + 1
    return list(counts.items())


def main(argv):
    if len(argv) != 2:
        sys.stderr.write("usage: main.py WORDS_FILE\n")
        return 2
    tokens = wfreq_io.read_tokens(argv[1])
    sys.stdout.write(wfreq_io.format_table(tally(tokens)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
