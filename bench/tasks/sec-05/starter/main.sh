#!/usr/bin/env bash
# logfilter -- keep only the lines of a log that satisfy a test.
# Usage: logfilter '<test>' [logfile]   (reads stdin when no file is given)
# The test is evaluated once per line with $line set to the current line
# and $n set to its 1-based number. Tests are bash conditionals such as:
#   ./main.sh '[[ $line == *ERROR* ]]' app.log
#   ./main.sh '[[ $n -ge 3 && $line != *DEBUG* ]]' app.log
set -u

usage() {
  echo "usage: $0 '<test>' [logfile]" >&2
  echo "  test: bash conditional over \$line and \$n, e.g. '[[ \$line == *ERROR* ]]'" >&2
  exit 2
}

[ $# -ge 1 ] && [ $# -le 2 ] || usage
TEST_EXPR=$1
IN=${2:-/dev/stdin}
if [ $# -eq 2 ] && [ ! -f "$IN" ]; then
  echo "$0: cannot read $IN" >&2
  exit 2
fi

n=0
while IFS= read -r line; do
  n=$((n + 1))
  if eval "$TEST_EXPR"; then
    printf '%s\n' "$line"
  fi
done < "$IN"
exit 0
