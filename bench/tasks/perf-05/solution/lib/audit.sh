#!/usr/bin/env bash
# audit_sweep PATTERNS HAYSTACK -- print every watchlist pattern that
# occurs in the haystack, one per line, preserving watchlist order.
# One pass over the haystack: collect every matched fixed string, then
# replay the watchlist keeping the signatures that were seen.
audit_sweep() {
  local patterns=$1 haystack=$2
  grep -oF -f "$patterns" -- "$haystack" | sort -u | grep -Fxf - -- "$patterns"
}
