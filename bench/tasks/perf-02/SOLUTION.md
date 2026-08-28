Flaw: join_orders() scans the full customers list for every order — O(O*C), 45k orders x 10k customers.
Fix: build {customer_id: name} dict once, then a single pass over orders; output byte-identical.
Measured: starter 8600 ms vs solution 130 ms; cap 2000 ms (starter killed at cap).
