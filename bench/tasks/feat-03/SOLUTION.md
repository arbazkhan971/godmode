Seeded flaw: roster prints the sorted listing only; no --reverse ordering flag exists.
Fix: index.js parses --reverse into opts.reverse and calls sorted.reverse() after filter+sort, before printing.
Reversal of the already-sorted (stable) sequence gives the exact opposite line order; empty results stay empty, exit 0.
Verification: starter fails at reverse-full (unknown flag ignored, wrong order); solution passes all 7 checks, exit 0.
