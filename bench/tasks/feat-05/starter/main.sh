#!/usr/bin/env bash
# sweep - removes stale build artifacts (*.bak, *.tmp) from a directory.
# Usage: bash starter/main.sh DIR
set -u

die(){ echo "sweep: $1" >&2; exit 2; }

[ "$#" -eq 1 ] || die "usage: sweep DIR"
dir="$1"
[ -d "$dir" ] || die "not a directory: $dir"

shopt -s nullglob
bak=( "$dir"/*.bak )
tmp=( "$dir"/*.tmp )
shopt -u nullglob

matched=0
for f in "${bak[@]}" "${tmp[@]}"; do
  [ -f "$f" ] || continue
  echo "deleted $(basename "$f")"
  rm -f "$f"
  matched=1
done

if [ "$matched" -eq 0 ]; then
  echo "nothing to do"
fi
exit 0
