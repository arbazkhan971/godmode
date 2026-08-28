Flaw: fsutil.resolve() joins root+name with no containment check, so "../secret.txt"
and absolute-name inputs both escape the document root.
Fix: realpath both sides and reject with PermissionError unless the target stays
inside the root (commonpath check); OSError handling in main.py turns it into exit 2.
Verified: starter EXIT=1 (secret leaked, exit 0), solution EXIT=0.
