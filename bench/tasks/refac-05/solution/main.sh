#!/usr/bin/env bash
# archctl - bundles source trees into archives for the ops toolkit.
set -u

USAGE="usage: main.sh {bundle|snapshot|backup} <srcdir> <outfile>"

make_archive() { # make_archive <src> <out> <create-flag> <list-flag>
  src="$1"; out="$2"; cflag="$3"; lflag="$4"
  if ! tar "$cflag" "$out" "$src" 2>/dev/null; then
    echo "error: archive failed: $out"
    return 1
  fi
  entries=$(tar "$lflag" "$out" | grep -c . )
  echo "archived $src -> $out ($entries entries)"
}

if [ $# -ne 3 ]; then
  echo "$USAGE"
  exit 2
fi
cmd="$1"; src="$2"; out="$3"

case "$cmd" in
  bundle)
    make_archive "$src" "$out" -czf -tzf
    ;;
  snapshot)
    make_archive "$src" "$out" -cjf -tjf
    ;;
  backup)
    make_archive "$src" "$out" -cf -tf
    ;;
  *)
    echo "$USAGE"
    exit 2
    ;;
esac
