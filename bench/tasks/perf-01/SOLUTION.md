Flaw: tally() counts via linear scan over a list of [word,count] pairs — O(N*V) for 30k tokens over an 18k vocab.
Fix: single dict pass (O(N)), emit items() to the unchanged formatter; output byte-identical.
Measured: starter 7770 ms vs solution 70 ms; cap 2000 ms (starter killed at cap).
