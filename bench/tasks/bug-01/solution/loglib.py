"""Parsing helpers for the shiplog reporter."""

ENTRY_SEP = "|"


def parse_entries(text):
    """Parse raw log text into (stamp, level, message) tuples, in file order.

    Blank lines are ignored. Each entry line looks like:

        2024-01-01T00:00:01Z|INFO|service started
    """
    lines = text.splitlines()
    entries = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        parts = line.split(ENTRY_SEP, 2)
        stamp, level = parts[0], parts[1]
        msg = parts[2].strip()
        entries.append((stamp, level, msg))
    return entries
