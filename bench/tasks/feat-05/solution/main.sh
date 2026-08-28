#!/usr/bin/env bash
# sweep - removes stale build artifacts (*.bak, *.tmp) from a directory.
# Usage: bash starter/main.sh [--dry-run] DIR
set -u

die(){ echo "sweep: $1" >&2; exit 2; }

dry=0
args=()
for a in "$@"; do
  if [ "$a" = "--dry-run" ]; then dry=1; else args+=("$a"); fi
done
[ "${#args[@]}" -eq 1 ] || die "usage: sweep [--dry-run] DIR"
dir="${args[0]}"
[ -d "$dir" ] || die "not a directory: $dir"

shopt -s nullglob
bak=( "$dir"/*.bak )
tmp=( "$dir"/*.tmp )
shopt -u nullglob

matched=0
for f in "${bak[@]}" "${tmp[@]}"; do
  [ -f "$f" ] || continue
  if [ "$dry" -eq 1 ]; then
    echo "would delete $(basename "$f")"
  else
    echo "deleted $(basename "$f")"
    rm -f "$f"
  fi
  matched=1
done

if [ "$matched" -eq 0 ]; then
  echo "nothing to do"
fi
if [ "$dry" -eq 1 ]; then
  exit 3
fi
exit 0
