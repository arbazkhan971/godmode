"""Item parsing and report rendering for the shelf tool."""


def parse_items(specs):
    """Parse NAME=COUNT strings into an ordered mapping (later duplicates win)."""
    items = {}
    for spec in specs:
        name, sep, count = spec.partition("=")
        if not sep or not name:
            raise ValueError("bad item spec: %r" % spec)
        items[name] = int(count)
    return items


def total(items):
    """Sum of all counts."""
    return sum(items.values())


def render_text(items):
    """Human-readable report: one line per item, then the TOTAL line."""
    lines = ["%s: %d" % (name, count) for name, count in items.items()]
    lines.append("TOTAL: %d" % total(items))
    return "\n".join(lines)
