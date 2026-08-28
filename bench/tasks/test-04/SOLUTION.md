No flaw in the impl; the gap is zero test coverage.
Reference fix: solution/tests/deque_test.js (node:test, 8 cases: both ends, FIFO/LIFO, sentinels, live peeks).
Mutants killed: popBack off-by-one removal (m_popback), popFront returns undefined on empty (m_empty), peekFront reads back end (m_peekfront).
Measured: pristine 8/8 pass in <1s; each mutant run fails (node --test exit != 0); total metric runtime ~3s.
