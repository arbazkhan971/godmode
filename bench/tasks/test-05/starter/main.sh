#!/usr/bin/env bash
# miniarch: create/extract/list tiny tar archives for a backup script.
set -u

usage() {
  cat >&2 <<'USAGE'
usage: main.sh <command> [args]
  create <archive.tar> <file>...   pack the named files into a new tar archive
  extract <archive.tar> <dir>      unpack every member into dir (created if missing)
  list <archive.tar>               print one member name per line, in creation order
USAGE
}

[ $# -ge 1 ] || { usage; exit 2; }
cmd=$1
shift

case $cmd in
  create)
    [ $# -ge 2 ] || { usage; exit 2; }
    archive=$1
    shift
    tar -cf "$archive" "$@" || exit 1
    ;;
  extract)
    [ $# -eq 2 ] || { usage; exit 2; }
    archive=$1
    dest=$2
    [ -f "$archive" ] || { echo "main.sh: no such archive: $archive" >&2; exit 1; }
    mkdir -p "$dest" || exit 1
    tar -xf "$archive" -C "$dest" || exit 1
    ;;
  list)
    [ $# -eq 1 ] || { usage; exit 2; }
    archive=$1
    [ -f "$archive" ] || { echo "main.sh: no such archive: $archive" >&2; exit 1; }
    tar -tf "$archive"
    ;;
  help)
    usage
    ;;
  *)
    usage
    exit 2
    ;;
esac
exit 0
