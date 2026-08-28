Flaw: thumbs.digest() builds "sha256sum <path>" and runs it with shell=True, so
filenames containing spaces break and "; touch ..." executes as a shell command.
Fix: pass the backend an argv list (shell dropped) — the path is one argument.
Verified: starter EXIT=1 (marker created + exit 0), solution EXIT=0; benign digests
byte-identical, payload rejected with exit 3 and no marker.
