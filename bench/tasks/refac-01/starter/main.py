#!/usr/bin/env python3
"""rosterctl - tiny front-desk CLI for the club roster."""
import sys

import members


def main(argv):
    if len(argv) < 2:
        sys.stdout.write(members.USAGE + "\n")
        return 2
    cmd, rest = argv[1], argv[2:]
    if cmd == "add" and len(rest) == 3:
        return members.add_member(rest[0], rest[1], rest[2])
    if cmd == "update" and len(rest) == 3:
        return members.update_member(rest[0], rest[1], rest[2])
    sys.stdout.write(members.USAGE + "\n")
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv))
