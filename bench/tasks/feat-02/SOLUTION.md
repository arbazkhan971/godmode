Seeded flaw: lister always prints the entire narrowed listing; no pagination options exist.
Fix: main.py declares --limit/--offset (type=int, default None); window applied AFTER author filtering via records[offset:] then [:limit]; render/exit path untouched.
Offset >= length or limit 0 yields an empty window, so render('') prints nothing and exit stays 0.
Verification: starter fails at limit-4 (argparse exit 2); solution passes all 9 checks, exit 0.
