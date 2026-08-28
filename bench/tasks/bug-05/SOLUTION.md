Seeded flaw: `for name in $names` word-splits the manifest text, so "final report.txt" is iterated as fragments "final" and "report.txt" and cp fails on the first fragment.
Fix: read the manifest line-wise (mapfile -t, stdin or file) and iterate the quoted array "${names[@]}"; skip blank lines.
Measured: starter case1 backs up plain.txt then exits 1 on the "final" fragment; solution backs up all 3 files with names intact and the vault count equals the manifest count.
Boundary pinned by case2 (both names contain spaces, one with two spaces) and case3 (stdin manifest, 4 names, 2 with spaces).
