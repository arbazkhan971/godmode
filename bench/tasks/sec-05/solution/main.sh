#!/usr/bin/env bash
# logfilter -- keep only the lines of a log that satisfy a test.
# Usage: logfilter '<test>' [logfile]   (reads stdin when no file is given)
# The test is evaluated once per line with $line set to the current line
# and $n set to its 1-based number. Supported tests are flat conditionals:
#   [[ $line == *ERROR* ]]
#   [[ $n -ge 3 ]]
#   [[ $n -ge 3 && $line != *DEBUG* ]]   (conditions joined by && or ||)
# Tests are validated against that grammar and evaluated directly; anything
# else is rejected up front so a test string can never execute commands.
set -u

usage() {
  echo "usage: $0 '<test>' [logfile]" >&2
  echo "  test: [[ \$line == GLOB ]] / [[ \$n -ge N ]], joined with && or ||" >&2
  exit 2
}

[ $# -ge 1 ] && [ $# -le 2 ] || usage
TEST_EXPR=$1
IN=${2:-/dev/stdin}
if [ $# -eq 2 ] && [ ! -f "$IN" ]; then
  echo "$0: cannot read $IN" >&2
  exit 2
fi

# Strict grammar: '[[' cond (join cond)* ']]' where cond is
#   $line == GLOB | $line != GLOB | $n -eq|-ne|-lt|-le|-gt|-ge NUM
# and GLOB contains only pattern-safe characters (no spaces, no $, no ()).
cond_re='(\$line (==|!=) [A-Za-z0-9*?._/:+-]+|\$n -(eq|ne|lt|le|gt|ge) [0-9]+)'
GRAMMAR="^\\[\\[ $cond_re( (&&|\\|\\|) $cond_re)* \\]\\]$"
if ! [[ $TEST_EXPR =~ $GRAMMAR ]]; then
  echo "$0: unsupported test: $TEST_EXPR" >&2
  exit 2
fi

cond_rc=1
eval_cond() { # $1 field, $2 operator, $3 argument -> cond_rc: 0 true, 1 false
  if [ "$1" = '$line' ]; then
    case "$2" in
      '==') [[ $line == $3 ]] ;;
      '!=') [[ $line != $3 ]] ;;
      *)    echo "$0: unsupported operator: $2" >&2; exit 2 ;;
    esac
  elif [ "$1" = '$n' ]; then
    case "$2" in
      -eq) (( n == $3 )) ;;
      -ne) (( n != $3 )) ;;
      -lt) (( n <  $3 )) ;;
      -le) (( n <= $3 )) ;;
      -gt) (( n >  $3 )) ;;
      -ge) (( n >= $3 )) ;;
      *)    echo "$0: unsupported operator: $2" >&2; exit 2 ;;
    esac
  else
    echo "$0: unsupported field: $1" >&2
    exit 2
  fi
  cond_rc=$?
}

keep_line() { # -> 0 keep, 1 drop; TEST_EXPR already passed the grammar check
  local body=${TEST_EXPR#"[[ "} i c cur join
  local -a tok
  body=${body%" ]]"}
  read -ra tok <<< "$body"
  eval_cond "${tok[0]}" "${tok[1]}" "${tok[2]}"
  cur=$(( cond_rc == 0 ? 1 : 0 ))
  for (( i = 3; i < ${#tok[@]}; i += 4 )); do
    join=${tok[i]}
    eval_cond "${tok[i+1]}" "${tok[i+2]}" "${tok[i+3]}"
    c=$(( cond_rc == 0 ? 1 : 0 ))
    # [[ ]] folds &&/|| left to right with no precedence; conditions are pure,
    # so eager folding gives the same verdict
    if [ "$join" = '&&' ]; then cur=$(( cur && c )); else cur=$(( cur || c )); fi
  done
  return $(( cur == 0 ? 1 : 0 ))
}

n=0
while IFS= read -r line; do
  n=$((n + 1))
  if keep_line; then
    printf '%s\n' "$line"
  fi
done < "$IN"
exit 0
