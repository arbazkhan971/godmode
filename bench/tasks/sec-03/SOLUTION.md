Flaw: nested-quantifier pattern ^([a-zA-Z0-9]+(-[a-zA-Z0-9]+)*)+$ backtracks
exponentially on non-matching runs (2^n partitions of the leading alnum block).
Fix: linear pattern ^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*$ (same language, no nesting).
Measured: crafted 28a+'!' input — starter >8s (killed, keeps scaling 4x per 2 chars),
fixed <50ms with verdict INVALID.
