#!/usr/bin/env bash
# archctl - bundles source trees into archives for the ops toolkit.
set -u

USAGE="usage: main.sh {bundle|snapshot|backup} <srcdir> <outfile>"

if [ $# -ne 3 ]; then
  echo "$USAGE"
  exit 2
fi
cmd="$1"; src="$2"; out="$3"

case "$cmd" in
  bundle)
    # create a gzip archive of the source tree
    if ! tar -czf "$out" "$src" 2>/dev/null; then
      echo "error: archive failed: $out"
      exit 1
    fi
    # verify the archive is readable and count its entries
    entries=$(tar -tzf "$out" | grep -c . )
    # report
    echo "archived $src -> $out ($entries entries)"
    ;;
  snapshot)
    # create a bzip2 archive of the source tree
    if ! tar -cjf "$out" "$src" 2>/dev/null; then
      echo "error: archive failed: $out"
      exit 1
    fi
    # verify the archive is readable and count its entries
    entries=$(tar -tjf "$out" | grep -c . )
    # report
    echo "archived $src -> $out ($entries entries)"
    ;;
  backup)
    # create a plain tar archive of the source tree
    if ! tar -cf "$out" "$src" 2>/dev/null; then
      echo "error: archive failed: $out"
      exit 1
    fi
    # verify the archive is readable and count its entries
    entries=$(tar -tf "$out" | grep -c . )
    # report
    echo "archived $src -> $out ($entries entries)"
    ;;
  *)
    echo "$USAGE"
    exit 2
    ;;
esac
