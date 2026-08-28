Seeded flaw: loglib.parse_entries iterates lines[:-1], so the final entry of every log is silently dropped.
Fix: iterate all lines (`for line in lines:`); only blank lines are skipped.
Boundary pinned by metric case 2 (single-entry log -> starter prints "total: 0") and case 1 (final ERROR entry).
