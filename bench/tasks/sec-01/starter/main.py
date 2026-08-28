#!/usr/bin/env python3
"""miniserve -- serve one file out of a document root.

Usage:
    main.py cat <root> <name>

Prints the file's text content on stdout. Exit codes:
    0   served
    2   usage error, not found, or unreadable
"""
import os
import sys

import fsutil


def serve(root, name):
    path = fsutil.resolve(root, name)
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        sys.stdout.write(fh.read())
    return 0


def main(argv):
    if len(argv) != 4 or argv[1] != "cat":
        sys.stderr.write("usage: main.py cat <root> <name>\n")
        return 2
    root, name = argv[2], argv[3]
    try:
        return serve(root, name)
    except OSError as exc:
        sys.stderr.write("miniserve: cannot read %s: %s\n"
                         % (name, exc.strerror or exc))
        return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
