Flaw: intersect() filters list a with b.includes(tag) — O(A*B), 34k x 26k element scans.
Fix: build a Set from b once, filter with set.has(tag); output byte-identical.
Measured: starter 6440 ms vs solution 80 ms; cap 2000 ms (starter killed at cap).
