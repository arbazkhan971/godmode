No flaw in the impl; the gap is zero test coverage.
Reference fix: solution/tests/markup_test.js (node:test, 6 cases: spans, order, escapes, empty line, unclosed).
Mutants killed: escape keeps backslash (m_escape), empty line emits empty text token (m_empty), unclosed ** dropped (m_unclosed).
Measured: pristine 6/6 pass in <1s; each mutant run fails (node --test exit != 0); total metric runtime ~2s.
