"""Inclusive date ranges: counts, day lists, and month ends from ISO strings."""

from datetime import date, timedelta


def parse_day(text):
    """Parse an ISO 'YYYY-MM-DD' string into a datetime.date."""
    year, month, day = (int(part) for part in text.split("-"))
    return date(year, month, day)


def days_between(start, end):
    """Count the days in the inclusive range [start, end]; a single day is 1."""
    return (parse_day(end) - parse_day(start)).days + 1


def range_days(start, end):
    """List every ISO day string in the inclusive range, in order."""
    cur = parse_day(start)
    stop = parse_day(end)
    out = []
    while cur <= stop:
        out.append(cur.isoformat())
        cur += timedelta(days=1)
    return out


def month_end(month):
    """Return the ISO string for the last day of the given 'YYYY-MM' month."""
    year, mon = (int(part) for part in month.split("-"))
    if mon == 12:
        first_next = date(year + 1, 1, 1)
    else:
        first_next = date(year, mon + 1, 1)
    return (first_next - timedelta(days=1)).isoformat()
