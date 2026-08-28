#!/usr/bin/env python3
"""wfreq -- word-frequency reporter.

Usage: python3 main.py WORDS_FILE
Prints every distinct word with its count, most frequent first.
"""
import sys

import wfreq_io


def tally(tokens):
    """Count occurrences of each token."""
    entries = []
    for tok in tokens:
        found = False
        for ent in entries:
            if ent[0] == tok:
                ent[1] += 1
                found = True
                break
        if not found:
            entries.append([tok, 1])
    return entries


def main(argv):
    if len(argv) != 2:
        sys.stderr.write("usage: main.py WORDS_FILE\n")
        return 2
    tokens = wfreq_io.read_tokens(argv[1])
    sys.stdout.write(wfreq_io.format_table(tally(tokens)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
