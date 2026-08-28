"""I/O helpers for the word-frequency tool."""


def read_tokens(path):
    """Read tokens (one per line) from *path*; blank lines are skipped."""
    tokens = []
    with open(path, "r", encoding="utf-8") as fh:
        for line in fh:
            tok = line.strip()
            if tok:
                tokens.append(tok)
    return tokens


def format_table(entries):
    """Render (word, count) pairs: highest count first, ties alphabetical."""
    ranked = sorted(entries, key=lambda e: (-e[1], e[0]))
    return "".join("%s %d\n" % (word, count) for word, count in ranked)
