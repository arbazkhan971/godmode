#!/usr/bin/env python3
"""thumbs -- fingerprint thumbnails for the media pipeline.

Usage:
    main.py thumb <file>    print the digest for one file
    main.py batch <dir>     print "name digest" for each file in <dir>, sorted

Exit codes: 0 ok, 2 usage, 3 backend failure.
"""
import os
import sys

import thumbs


def cmd_thumb(argv):
    if len(argv) != 1:
        sys.stderr.write("usage: main.py thumb <file>\n")
        return 2
    try:
        sys.stdout.write(thumbs.digest(argv[0]) + "\n")
    except RuntimeError as exc:
        sys.stderr.write("thumbs: %s\n" % exc)
        return 3
    return 0


def cmd_batch(argv):
    if len(argv) != 1:
        sys.stderr.write("usage: main.py batch <dir>\n")
        return 2
    try:
        names = sorted(n for n in os.listdir(argv[0])
                       if os.path.isfile(os.path.join(argv[0], n)))
    except OSError as exc:
        sys.stderr.write("thumbs: cannot list %s: %s\n" % (argv[0], exc))
        return 3
    for name in names:
        try:
            digest = thumbs.digest(os.path.join(argv[0], name))
        except RuntimeError as exc:
            sys.stderr.write("thumbs: %s\n" % exc)
            return 3
        sys.stdout.write("%s %s\n" % (name, digest))
    return 0


def main(argv):
    if len(argv) < 2:
        sys.stderr.write("usage: main.py <thumb|batch> ...\n")
        return 2
    if argv[1] == "thumb":
        return cmd_thumb(argv[2:])
    if argv[1] == "batch":
        return cmd_batch(argv[2:])
    sys.stderr.write("thumbs: unknown command %r\n" % argv[1])
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
