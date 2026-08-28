#!/usr/bin/env bash
# sigaudit -- report which watchlist signatures occur in a log export.
#
# Usage: bash starter/main.sh PATTERNS HAYSTACK
# Prints each watchlist signature (one per line, watchlist order) that
# occurs anywhere in the export. Exit status 0 after a completed sweep,
# 2 on bad usage.
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/audit.sh
. "$DIR/lib/audit.sh"

usage() {
  printf 'usage: sigaudit PATTERNS HAYSTACK\n' >&2
  exit 2
}

[ "$#" -eq 2 ] || usage
[ -r "$1" ] || { printf 'sigaudit: cannot read %s\n' "$1" >&2; exit 2; }
[ -r "$2" ] || { printf 'sigaudit: cannot read %s\n' "$2" >&2; exit 2; }

audit_sweep "$1" "$2"
