Seeded flaw: index.js ignores uploadAll's completion callback, prints the summary synchronously, and process.exit() aborts every pending copy — zero artifacts reach the vault.
Fix: keep the onFile progress lines, but move the summary into the onDone callback and let the process exit naturally once it fires (exitCode 0, or 1 on error).
Measured: starter prints only the summary line and exits 0 with an empty vault; solution prints the stored lines then the summary, and all vault files cmp equal (case1: 46/14/20 bytes).
Boundary pinned by case2 (a single-artifact manifest must still settle before the summary) and case3 (stdin manifest, 4 artifacts, non-alphabetical order).
