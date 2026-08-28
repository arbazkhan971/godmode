Seeded flaw: board.byScoreDesc compares the raw score strings, so "9" outranks "250" and "500" outranks "1000".
Fix: compare Number(score) values (descending) in byScoreDesc.
Pinned by metric cases mixing 1/2/3/4-digit scores: case1 (9 vs 250/100/10), case2 (9/10/100 reorder), case3 (999 vs 1000).
