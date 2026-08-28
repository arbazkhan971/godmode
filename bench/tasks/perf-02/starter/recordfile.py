"""Flat-file helpers for the order ledger tool."""


def read_rows(path):
    """Read comma-separated rows from *path*; blank lines are skipped."""
    rows = []
    with open(path, "r", encoding="utf-8") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if line:
                rows.append(line.split(","))
    return rows
