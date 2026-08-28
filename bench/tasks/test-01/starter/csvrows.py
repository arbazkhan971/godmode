"""Parse CSV lines: split fields honoring quotes, map rows onto headers."""


def split_fields(line):
    """Split one CSV line into a list of field strings.

    Double-quoted sections may contain commas; a doubled quote ("") inside
    a quoted section is a literal quote character.
    """
    fields = []
    cur = []
    quoted = False
    i = 0
    while i < len(line):
        ch = line[i]
        if quoted:
            if ch == '"':
                if i + 1 < len(line) and line[i + 1] == '"':
                    cur.append('"')
                    i += 1
                else:
                    quoted = False
            else:
                cur.append(ch)
        elif ch == '"':
            quoted = True
        elif ch == ",":
            fields.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
        i += 1
    fields.append("".join(cur))
    return fields


def parse_row(header, line):
    """Map one CSV data line onto the header's keys as a dict."""
    keys = split_fields(header)
    values = split_fields(line)
    return dict(zip(keys, values))
