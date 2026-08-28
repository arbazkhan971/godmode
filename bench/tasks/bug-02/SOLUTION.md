Seeded flaw: orderkit.add_items has a mutable default argument (cart=[]); the list persists across calls, so items accumulate into later orders.
Fix: default cart to None and build a fresh list per call.
Pinned by metric cases where each later order must equal only its own items (case1 beta $3.75, case2 gamma $12.00, case3 web-1043 $13.00).
