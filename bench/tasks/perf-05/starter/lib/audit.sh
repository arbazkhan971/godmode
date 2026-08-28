#!/usr/bin/env bash
# audit_sweep PATTERNS HAYSTACK -- print every watchlist pattern that
# occurs in the haystack, one per line, preserving watchlist order.
audit_sweep() {
  local patterns=$1 haystack=$2 pat
  while IFS= read -r pat; do
    [ -n "$pat" ] || continue
    if grep -qF -- "$pat" "$haystack"; then
      printf '%s\n' "$pat"
    fi
  done < "$patterns"
}
