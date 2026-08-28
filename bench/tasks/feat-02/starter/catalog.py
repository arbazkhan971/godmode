"""Loading, filtering, and rendering for the library catalog tool."""

FIELDS = ("title", "year", "author")


def load_records(path):
    """Read catalog.tsv rows into record dicts, preserving file order."""
    records = []
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line:
                continue
            title, year, author = line.split("\t")
            records.append({"title": title, "year": int(year), "author": author})
    return records


def filter_by_author(records, author):
    """Keep records whose author matches exactly (None keeps everything)."""
    if author is None:
        return list(records)
    return [r for r in records if r["author"] == author]


def render(records):
    """One line per record: TITLE (YEAR) by AUTHOR."""
    return "\n".join("%s (%d) by %s" % (r["title"], r["year"], r["author"])
                     for r in records)
